

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

https://tosbourn.com/getting-os-x-to-trust-self-signed-ssl-certificates/

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

## Solutions

To test these solutions you should be able to run:

```shell script
echo | openssl s_client -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif
```

### Extending builders

[Extending the builder](extended-builder) allows for more specific (and preferred) forms installation of CA certs. 

```shell script
./extended-builder/extend.sh gcr.io/paketo-buildpacks/builder:base extended-builder
```

To verify:

```shell script
docker run -it --rm extended-builder /bin/bash
echo | openssl s_client -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif
```

### Using volume mounts

On a [debian](#debian) based image, users are able to mount a directory with preconfigured contents of `/etc/ssl/certs`.

> **Important**: `c275f070.0` is required. It is the same contents (typically a link to the original file) with a [specific name based on a hashing algorithm](http://manpages.ubuntu.com/manpages/focal/en/man1/c_rehash.1ssl.html).
>
Running this command should allow requests to https://self-signed.badssl.com

```shell script
docker run --volume="${PWD}/certs:/etc/ssl/certs:rw" -it --rm gcr.io/paketo-buildpacks/builder:base /bin/bash
```

To verify:

```shell script
echo | openssl s_client -servername self-signed.badssl.com -connect self-signed.badssl.com:443 | grep Verif
```