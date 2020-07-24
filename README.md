
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

### Adding certs to macOS

https://tosbourn.com/getting-os-x-to-trust-self-signed-ssl-certificates/


### badssl.com

Self-signed: https://self-signed.badssl.com

Extract certificate:

1. Run the command:
    ```shell script
    echo | openssl s_client -servername self-signed.badssl.com -connect self-signed.badssl.com:443
    ```
2. Extract content within and including the following tags: `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE----`

## Questions

On macOS, when a user installs a self-signed cert at the system level does this satisfy the following?

- Requests from `pack`? ✅
- Requests from within a docker container?
    - ... with network=`bridged`? ❌
    - ... with network=`host`? ❌