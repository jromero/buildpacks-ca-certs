

### Tools

#### badssl.com

badssl.com is a [chromium project](https://github.com/chromium/badssl.com) that provide various configuration permutations of SSL to enable easier development and testing.

A useful configuration used throughout this repo is:

* Self-signed: https://self-signed.badssl.com

The certificate can be extracted via:

1. Run the command:
    ```shell script
    echo | openssl s_client -servername self-signed.badssl.com -connect self-signed.badssl.com:443
    ```
2. Extract content within and including the following tags: `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE----`


### Generate Self-Signed Cert

From: https://devcenter.heroku.com/articles/ssl-certificate-self#generate-private-key-and-certificate-signing-request

```shell
$ openssl genrsa -des3 -passout pass:x -out server.pass.key 2048
$ openssl rsa -passin pass:x -in server.pass.key -out server.key
$ rm server.pass.key
$ openssl req -new -key server.key -out server.csr
Country Name (2 letter code) []:US
State or Province Name (full name) []:Texas
Locality Name (eg, city) []:
Organization Name (eg, company) []:Buildpacks
Organizational Unit Name (eg, section) []:
Common Name (eg, fully qualified host name) []:secure.local
Email Address []:root@jromero.codes

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:

$ openssl x509 -req -sha256 -days 365 -in server.csr -signkey server.key -out server.crt
```

### Local Development

#### Adding certs to macOS

Manually: https://tosbourn.com/getting-os-x-to-trust-self-signed-ssl-certificates/

```shell script
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/badssl.pem
```

Alternatively,

```shell script
mkdir -p ~/.docker/certs.d/
cp certs/badssl.pem ~/.docker/certs.d/badssl.crt
```

#### Accessing Docker VM

```shell script
screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty
```
_Stopped working in  2.3.0.4_

OR

```shell script
docker run -it --rm --privileged --pid=host justincormack/nsenter1
```


> NOTE: To work within the docker VM filesystem: `chroot /containers/services/docker/rootfs`

#### Questions

On macOS, when a user installs a self-signed cert at the system level does this satisfy the following?

- Requests from `pack`? ✅
- Requests from within a docker container?
    - ... with network=`bridged`? ❌
    - ... with network=`host`? ❌

### Debian

Running `update-ca-certificates` yields the following change:

```text
└── etc
    └── ssl
        └── certs
            ├── badssl.pem → /usr/local/share/ca-certificates/badssl.crt # link with changed extension .pem`
            ├── c275f070.0 → badssl.pem                                  # link as hashed by http://manpages.ubuntu.com/manpages/focal/en/man1/c_rehash.1ssl.html
            └── ca-certificates.crt                                      # cert concatenated into this file
```

> **Important**: `c275f070.0` is required for OpenSSL when configured with only `CAPath`.
>
> - It is the same contents (typically a link to the original file) with a [specific name based on a hashing algorithm](http://manpages.ubuntu.com/manpages/focal/en/man1/c_rehash.1ssl.html).
> - [Explanation](https://stackoverflow.com/a/34095441) of hash algo

## Solutions

To test these solutions you should be able to run:

```shell script
echo | openssl s_client -CAfile /etc/ssl/certs/ca-certificates.crt -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif
```

OR

```shell script
wget -O - https://self-signed.badssl.com
```

---

```shell script
echo | openssl s_client -CAfile /etc/ssl/certs/ca-certificates.crt -servername google.com -connect google.com:443 | grep Verif
```

### Extending builders

[Extending the builder](extended-builder) allows for more specific (and preferred) forms installation of CA certs. 

```shell script
./extended-builder/extend.sh gcr.io/paketo-buildpacks/builder:base extended-builder
```

To verify:

```shell script
docker run -it --rm extended-builder /bin/bash
echo | openssl s_client -CAfile /etc/ssl/certs/ca-certificates.crt -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif
```

### Using volume mounts

On a [debian](#debian) based image, users are able to mount a directory with preconfigured contents of `/etc/ssl/certs`.

#### Option 1 - local certs dir

The following command will overwrite the `/etc/ssl/certs` with the contents of [certs](certs).

```shell script
docker run --volume="${PWD}/certs:/etc/ssl/certs:rw" -it --rm gcr.io/paketo-buildpacks/builder:base /bin/bash
```

To verify:

```shell script
echo | openssl s_client -CAfile /etc/ssl/certs/ca-certificates.crt -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif
```

#### Option 2 - mount docker VM certs


Prerequisite: cert is installed at the OS level.

* For macOS: `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain certs/badssl.pem`
* For Windows: https://support.kaspersky.com/CyberTrace/1.0/en-US/174127.htm

The following command will overwrite the `/etc/ssl/certs` and `/usr/share/ca-certificates/` with the contents of the docker VM. The docker VM inherits system certificates. Effectively this command inherits all system certs.

> **NOTE:** This is only possible when the directories `/etc/` and `/usr/` not being shared by the host.

```shell script
docker run --volume="/etc/ssl/certs:/etc/ssl/certs:ro" --volume="/usr/share/ca-certificates/:/usr/share/ca-certificates/:ro" -it --rm gcr.io/paketo-buildpacks/builder:base /bin/bash
```

To verify:

```shell script
echo | openssl s_client -CAfile /etc/ssl/certs/ca-certificates.crt -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif
```
