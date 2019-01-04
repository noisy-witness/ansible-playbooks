#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${DIR}"
set -e # fail on first error
set -x

# Configuration for staging
# VAULT_DOMAIN="vault.staging.wise.vote"
# VAULT_IPV4="51.38.133.176"
# VAULT_IPV6="2001:41d0:0601:1100:0000:0000:0000:24cd"
# CERT_EMAIL="contact@wiseteam.io"
# CN_MOD=""

# Configuration for production
VAULT_DOMAIN="vault.wise.vote"
VAULT_IPV4="51.38.98.112"
VAULT_IPV6="2001:41d0:0701:1100:0000:0000:0000:1381"
CERT_EMAIL="contact@wiseteam.io"
CN_MOD="_staging"


# Source: https://jamielinux.com/docs/openssl-certificate-authority/appendix/root-configuration-file.html
CA_DIR="${DIR}/ca"
mkdir -p "${CA_DIR}/certs"
mkdir -p "${CA_DIR}/crl"
mkdir -p "${CA_DIR}/newcerts"
mkdir -p "${CA_DIR}/private"
touch "${CA_DIR}/index.txt"
echo "unique_subject = yes/no" > "${CA_DIR}/index.txt.attr"
echo 1000 > "${CA_DIR}/serial"

echo "
[ ca ]
# OpenSSL root CA configuration file.
# Copy to /root/ca/openssl.cnf.

[ ca ]
# man ca
default_ca = CA_default

[ CA_default ]
# Directory and file locations.
dir               = ${CA_DIR}
certs             = \$dir/certs
crl_dir           = \$dir/crl
new_certs_dir     = \$dir/newcerts
database          = \$dir/index.txt
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

# The root key and root certificate.
private_key       = \$dir/private/ca.key.pem
certificate       = \$dir/certs/ca.cert.pem

# For certificate revocation lists.
crlnumber         = \$dir/crlnumber
crl               = \$dir/crl/ca.crl.pem
crl_extensions    = crl_ext
default_crl_days  = 30

# SHA-1 is deprecated, so use SHA-2 instead.
default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 375
preserve          = no
policy            = policy_strict

[ policy_strict ]
# The root CA should only sign intermediate certificates that match.
# See the POLICY FORMAT section of man ca.
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ policy_loose ]
# Allow the intermediate CA to sign a more diverse range of certificates.
# See the POLICY FORMAT section of the ca man page.
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
# Options for the req tool (man req).
default_bits        = 2048
distinguished_name  = req_distinguished_name
string_mask         = utf8only

# SHA-1 is deprecated, so use SHA-2 instead.
default_md          = sha256

# Extension to add when the -x509 option is used.
x509_extensions     = v3_ca

[ req_distinguished_name ]
# See <https://en.wikipedia.org/wiki/Certificate_signing_request>.
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
0.organizationName              = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name
emailAddress                    = Email Address

# Optionally, specify some defaults.
countryName_default             = GB
stateOrProvinceName_default     = England
localityName_default            =
0.organizationName_default      = Alice Ltd
organizationalUnitName_default  =
emailAddress_default            =

[ v3_ca ]
# Extensions for a typical CA (man x509v3_config).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
# Extensions for a typical intermediate CA (man x509v3_config).
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
# Extensions for client certificates (man x509v3_config).
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = \"OpenSSL Generated Client Certificate\"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ server_cert ]
# Extensions for server certificates (man x509v3_config).
basicConstraints = CA:FALSE
nsCertType = server
nsComment = \"OpenSSL Generated Server Certificate\"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer:always
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth

[ crl_ext ]
# Extension for CRLs (man x509v3_config).
authorityKeyIdentifier=keyid:always

[ ocsp ]
# Extension for OCSP signing certificates (man ocsp).
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, OCSPSigning
" > "${DIR}/openssl.conf"




# Generate CA
CA_SUBJECT="/C=PL/ST=DOLNOSLASKIE/L=OLAWA/O=Wise Team/emailAddress=${CERT_EMAIL}"
CA_CN="WiseVaultCA${CN_MOD}"

openssl genrsa -out CA.key 2048
#openssl req -new -sha256 -key CA.key -out CA.csr -config openssl.conf -extensions v3_ca \
#     -subj "${CA_SUBJECT}/CN=${CA_CN}"
# openssl x509 -signkey CA.key -in CA.csr -req -days 3650  -config openssl.conf -extensions v3_ca \
#     -out CA.pem

openssl req -config openssl.conf \
      -key CA.key \
      -new -x509 -days 3650 -sha256 -extensions v3_ca \
      -subj "${CA_SUBJECT}/CN=${CA_CN}" \
      -out CA.pem

openssl x509 -outform pem -in CA.pem -out CA.crt -sha256




# Generate intermediary CA
INTERMEDIARY_CA_SUBJECT="${CA_SUBJECT}"
INTERMEDIARY_CA_CN="WiseVaultIntermediaryCA${CN_MOD}"

INTERMEDIARY_CA_DIR="${CA_DIR}/intermediate"
mkdir -p "${INTERMEDIARY_CA_DIR}"
mkdir -p "${INTERMEDIARY_CA_DIR}/certs"
mkdir -p "${INTERMEDIARY_CA_DIR}/crl"
mkdir -p "${INTERMEDIARY_CA_DIR}/newcerts"
mkdir -p "${INTERMEDIARY_CA_DIR}/private"
touch "${INTERMEDIARY_CA_DIR}/index.txt"
echo "unique_subject = yes/no" > "${INTERMEDIARY_CA_DIR}/index.txt.attr"
echo 1000 > "${INTERMEDIARY_CA_DIR}/serial"
echo 1000 > "${INTERMEDIARY_CA_DIR}/crlnumber"

echo "
[ CA_default ]
dir             = ${INTERMEDIARY_CA_DIR}
private_key     = \$dir/private/intermediate.key.pem
certificate     = \$dir/certs/intermediate.cert.pem
crl             = \$dir/crl/intermediate.crl.pem
policy          = policy_loose

[ req ]
default_bits = 2048
prompt = no
encrypt_key = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = ${VAULT_DOMAIN}
emailAddress = ${CERT_EMAIL}
O = Wise Team
OU = Wise
L = Olawa
ST = Dolnoslaskie
C = PL
" > openssl.intermediate.conf

openssl genrsa -out CA_Intermediary.key 2048
#openssl req -new -sha256 -key CA_Intermediary.key -out CA_Intermediary.csr \
#    -config openssl.conf -extensions v3_ca \
#    -subj "${WISE_SUBJECT}/CN=${INTERMEDIARY_CA_CN}"

#openssl x509 -req -in CA_Intermediary.csr -CA CA.pem -CAkey CA.key -CAcreateserial -out CA_Intermediary.crt \
#   -days 3650 -sha256

openssl req -config openssl.intermediate.conf -new -sha256 \
      -subj "${INTERMEDIARY_CA_SUBJECT}/CN=${INTERMEDIARY_CA_CN}" \
      -key CA_Intermediary.key \
      -out CA_Intermediary.csr

openssl ca -config openssl.conf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -cert CA.pem -keyfile CA.key \
      -in CA_Intermediary.csr \
      -out CA_Intermediary.crt

cat CA_Intermediary.crt CA.crt > CA_Intermediary.bundle.crt



# Generate server cert'
echo "
[ req ]
default_bits = 2048
prompt = no
encrypt_key = no
default_md = sha256
distinguished_name = dn
req_extensions = req_ext

[ dn ]
CN = ${VAULT_DOMAIN}
emailAddress = ${CERT_EMAIL}
O = Wise Team
OU = Wise
L = Olawa
ST = Dolnoslaskie
C = PL

[ req_ext ]
subjectAltName = DNS: ${VAULT_DOMAIN}, IP: ${VAULT_IPV4}, IP: ${VAULT_IPV6}, IP: 0.0.0.0, IP: 127.0.0.1, DNS: localhost
" > certgen.conf

openssl genrsa -out privateKey.key 2048

openssl req -new -sha256 -key privateKey.key -out certificate_sr.csr -config certgen.conf

openssl x509 -req -in certificate_sr.csr -CA CA_Intermediary.crt -CAkey CA_Intermediary.key -CAcreateserial -out certificate.crt -days 3650 -sha256 \
    -extfile certgen.conf -extensions req_ext

cat certificate.crt CA_Intermediary.bundle.crt > certificate.bundle.crt


chmod -R 750 "${DIR}"
chown -R vault:vault "${DIR}"

rm CA.key CA_Intermediary.key
rm -rf "${CA_DIR}"

PUB_CERT_DIR="/pub_cert"
mkdir -p "${PUB_CERT_DIR}"
rm -rf "${PUB_CERT_DIR}/*"
cp CA.crt CA.pem CA_Intermediary.crt CA_Intermediary.bundle.crt certificate.crt certificate.bundle.crt "${PUB_CERT_DIR}"
chmod -R 0777 "${PUB_CERT_DIR}"
