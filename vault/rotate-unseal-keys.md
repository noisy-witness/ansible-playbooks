# Generating Vault unseal keys

This is a guide to secure vault key rotation.

Let's start with some definitions:

- **vault**: HashiCopr's vault (https://www.vaultproject.io/) installed at https://vault.wise.vote:8200/
- **ui**: GUI for vault available at https://vault.wise.vote:8200/ui/
- **sealing/unsealing**: https://www.vaultproject.io/docs/concepts/seal.html . In short: vault always writes all the secrets encrypted and wrapped hierarchically to disk. When it is restarted it needs to load encryption keys to RAM memory. In order to do so, it requires the master key. It would not be safe for us to posess a single master key. To make the process more secure vault uses Shamir's secret sharing algorithm (https://en.wikipedia.org/wiki/Shamir%27s_Secret_Sharing). It allows to create a pool of N keys in such a way that any n keys are enough to generate the master key. (n < N, both configurable). At each reboot 'n' of us must go to the 'ui' and enter his key portion. When enough keys are inputted Vault unseals, and becomes accessible to all servers. Unseal keys can be changed.
- Operator — a person who possesses the unseal key
- Initiator — the person who initiates the rekey



## Guide

Basing on the Vault rekey guide: https://learn.hashicorp.com/vault/operations/ops-rekeying-and-rotating . Using the `vault operator` utility with gpg: https://www.vaultproject.io/docs/concepts/pgp-gpg-keybase.html

### 1. Operator: Generate GPG keys if you don't already have one

If you do not have a gpg key:

1. Install gpg

2. Save the gpg batch file to `genkey.gpgbatch` (please enter your data)

   ```
   Key-Type: 1
   Key-Length: 2048
   Subkey-Type: 1
   Subkey-Length: 2048
   Name-Real: Krzysztof Szumny
   Name-Email: noisy@wiseteam.io
   Expire-Date: 0
   ```

3. Generate the key:

   ```bash
   $ gpg --batch --gen-key genkey.gpgbatch
   ```

4. List keys

   ```bash
   $ gpg --list-secret-keys
   ```



### 2. Operator: Export the key to vault-acceptable format

1. List keys

   ```bash
   $ gpg --list-secret-keys
   ```

2. Export key by name

   ```bash
   $ gpg --export "Krzysztof Szumny" | base64 > krzysztofszumny.asc.base64
   ```

3. Send the exported key file to the Initiator.



### 3. Initiator: Perform rekey

```bash
# 1. Configure:
$ export VAULT_ADDR="https://vault.staging.wise.vote:8200"
$ export VAULT_SKIP_VERIFY="true"

# 2. Initialise
$  vault operator rekey -init -key-shares=4 -key-threshold=2 -pgp-keys="krzysztofszumny.asc.base64,patrykperduta.asc.base64,bartlomiejgornicki.asc.base64,jedrzejlewandowski.asc.base64,"
# Save the nonce

# 3. Input all the previous unseal keys
$ vault operator rekey -nonce=(...nonce from init)
$ vault operator rekey -nonce=(...nonce from init)
* ...

# 4. The final command will contain encrypted keys (in order of provided keys):
Key 1 fingerprint: c61d48d6d51b3beb7a624b1eba1b42c364027747; value: wcBMAxjAUvju8QlvAQgAavujT9ODVIv8BM55DR09935nVmyOXRt3GqzQtSBP0YWscQyIGO8LmOkmZFGBU0W7kUeGB0FV11UaSqRdZ7EnVxOtfj7t98DXAEDIaw0/9r7c/7XD25vj/w1zjemwuh1aa8HvkctEtbLcTRxgeb0NE9cfYMXVzWoDp8QKwVOteoBqrjQkfhfdxx63Oji3HfM4NKW2c3gva2ylU6ZgGdf6jL14CNnrdBoGFv0fOlrkNoDatLMDuLz0kxS3p0pGnJ71/EJaWYbrBBkpZrgc/OfyP5rn6K2/bv0fuCLK5Bc9sXMts7XP0S0ZM79Lt8hOMzVJt69c96HFp2j9uqp9SmZXUtLgAeQM3j31/F/hTfDJfKIyPPtb4aZw4Gzg4eGcT+Bi4pnxzWPgFuYuY9PVxyyJUg7ebEVJp0fr6JFT9uoi76YjgBjElkLjyc2SPAnk7b92ggoPPRCa4Tkw0gqCchFL28kPuWWdN9Bv4IfhrTLgTOQEYKmMpwbbB10vcVEyyvs34iSQI03h028A
...

# 5. Write keys to the files:
vaultwisevote_unseal.krzysztofszumny.enc.key
vaultwisevote_unseal.patrykperduta.enc.key
vaultwisevote_unseal.bartlomiejgornicki.enc.key
vaultwisevote_unseal.jedrzejlewandowski.enc.key

# 6. Send the keys
```

In future, in next rekeys we should extend this process so thet rekey is initiated by the initiator and then sequentially performed by the rest of Operators.



### 4. Operator: Decrypt key and save it to your password manager

```bash
$ cat vaultwisevote_unseal.krzysztofszumny.enc.key | base64 --decode | gpg -dq 
```



### 5. Operator: Unseal via the UI

Open: https://vault.wise.vote:8200/ui/ and enter your key

