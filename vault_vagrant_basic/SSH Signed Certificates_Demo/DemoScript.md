# Demo Script Description
In this Demo, we will use the Vagrantfile (in the ./vault_vagrant_basic path) to build up one Vault server with Consul as backend storage. 

## Demo steps
1. Mount the secret engine. You can mount different paths with the same secret engine. 
* '$vault secrets enable -path=dev-ssh-client ssh' 
2. Config Vault with a CA for signing client keys. 
* If you don't have an internal CA, use below CLI to get Vault generate a keypair for you. 

'$vault write dev-ssh-client/config/ca generate_signing_key=true'
* If you have a keypair, use below CLI to specify the public/priviate key.

'$vault write dev-ssh-client/config/ca private_key="aded..." public_key="abcd..."'
3. 