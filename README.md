
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