# Demo Script Description
In this Demo, we will use the Vagrantfile (in the ./vault_vagrant_basic path) to build up one Vault server with Consul as backend storage. 

## Demo steps
1. Mount the secret engine. You can mount different paths with the same secret engine. 
* '$vault secrets enable -path=dev-ssh-client ssh' 
2. 