# Install Hashicopr Vault for wise

> Source: https://www.digitalocean.com/community/tutorials/how-to-securely-manage-secrets-with-hashicorp-vault-on-ubuntu-16-04

### 1. Prepare

```bash
$ sudo apt-get update
$sudo apt-get install unzip
```

### 2. Download and install hashi vault

```bash
# - Download HashiVault .zip from it's site
# - Verify signatures
$ unzip vault_*.zip
$ sudo cp vault /usr/local/bin/
# Vault needs a capability to disable swap
$ sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault
```

### 3. Create vault user and setup ownerships

```bash
$ sudo useradd -r -d /var/lib/vault -s /bin/nologin vault
$ sudo install -o vault -g vault -m 750 -d /var/lib/vault
# - copy vault-config.*.hcl to /etc/vault/config.hcl
$ sudo chown vault:vault /etc/vault/config.hcl
$ sudo chmod 640 /etc/vault/config.hcl
```

### 4. Generate CA, IntermediaryCA and server certificates

```bash
mkdir /etc/vault/cert
# - copy generate-vault-cert-chain.sh to /etc/vault/cert/certgen.sh
vim /etc/vault/cert/certgen.sh # <- set the configuration (domain, ip, email)
chmod +x /etc/vault/cert/certgen.sh
cd /etc/vault/cert
./certgen.sh
# - copy everything from /pub_cert to ansible-playbooks repository and place under /wise.vote/roles/common/files/vault/certs/{domain}/
# - install CA.crt on your own computer (for OSX use install-ca-osx.sh)
```

### 5. Setup systemd service

```bash
# - copy vault.systemd.service to /etc/systemd/system/vault.service
$ sudo systemctl start vault
$ sudo systemctl status vault
```

### 6. Generate sealing keys, distribute them and unseal

Go to [https://vault.wise.vote:8200/ui](https://vault.wise.vote:8200/ui) or [https://vault.staging.wise.vote:8200/ui](https://vault.staging.wise.vote:8200/ui) .

### 7. Done!
