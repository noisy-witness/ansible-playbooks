#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
set -e # fail on first error
set -x


# Generate CA
CA_SUBJECT="/C=PL/ST=DOLNOSLASKIE/L=OLAWA/O=Wise Team"
CA_CN="WiseVaultCA"

openssl genrsa -out CA.key 2048
openssl req -new -sha256 -key CA.key -out CA.csr -subj "${CA_SUBJECT}/CN=${CA_CN}"
openssl x509 -signkey CA.key -in CA.csr -req -days 3650 -out CA.pem
openssl x509 -outform pem -in CA.pem -out CA.crt -sha256




# Generate intermediary CA
INTERMEDIARY_CA_SUBJECT="${CA_SUBJECT}"
INTERMEDIARY_CA_CN="WiseVaultIntermediaryCA"

openssl genrsa -out CA_Intermediary.key 2048
openssl req -new -sha256 -key CA_Intermediary.key -out CA_Intermediary.csr \
    -subj "${WISE_SUBJECT}/CN=${INTERMEDIARY_CA_CN}"

openssl x509 -req -in CA_Intermediary.csr -CA CA.pem -CAkey CA.key -CAcreateserial -out CA_Intermediary.crt \
   -days 3650 -sha256

cat CA_Intermediary.crt CA.crt > CA_Intermediary.bundle.crt



# Generate server cert
SERVER_CERT_SUBJECT="${CA_SUBJECT}"
SERVER_CERT_CN="vault.dev.wise.vote"
SERVER_CERT_SUBJECTALTNAMES="DNS:vault.dev.wise.vote"
cat > "certgen.conf" <<- EOM
[ req ]
default_bits = 2048
prompt = no
encrypt_key = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[ dn ]
CN = vault.dev.wise.vote
emailAddress = ssl@example.com
O = Wise Team
OU = Wise
L = Olawa
ST = Dolnoslaskie
C = PL

[ req_ext ]
subjectAltName = DNS: vault.dev.wise.vote, IP: 51.38.133.176, IP: 2001:41d0:0601:1100:0000:0000:0000:24cd
EOM

openssl genrsa -out privateKey.key 2048

#openssl req -new -sha256 -key privateKey.key -out certificate_sr.csr -subj "${SERVER_CERT_SUBJECT}/subjectAltName=${SERVER_CERT_SUBJECTALTNAMES}"
openssl req -new -sha256 -key privateKey.key -out certificate_sr.csr -config certgen.conf

openssl x509 -req -in certificate_sr.csr -CA CA_Intermediary.crt -CAkey CA_Intermediary.key -CAcreateserial -out certificate.crt -days 3650 -sha256 \
    -extfile certgen.conf -extensions req_ext

cat certificate.crt CA_Intermediary.bundle.crt > certificate.bundle.crt


chmod -R 750 "${DIR}"
chown -R vault:vault "${DIR}"