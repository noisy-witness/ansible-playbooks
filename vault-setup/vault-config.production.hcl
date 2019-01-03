backend "file" {
    path = "/var/lib/vault"
}
api_addr="https://vault.wise.vote:8200/"
ui = true
default_lease_ttl = "4h",
max_lease_ttl = "24h",
listener "tcp" {
    address = "0.0.0.0:8200"
    tls_disable = 0,
    tls_cert_file = "/etc/vault/cert/certificate.bundle.crt",
    tls_key_file = "/etc/vault/cert/privateKey.key"
}