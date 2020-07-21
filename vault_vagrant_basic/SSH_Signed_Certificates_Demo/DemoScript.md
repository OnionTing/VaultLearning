# Demo Script Description
In this Demo, we will use the Vagrantfile to build two servers: 
1. 'VaultServer': we will install one Vault server with Consul as backend storage. This server will do the key signing. 
2. 'HostServer': this is the target server that the client/user will ssh to. We will use this server to test the Vault SSH sign function.

## Terminology
* client: referes to the person or machine performing the SSH operation.
* host: refers to the target machine. 

## Set up Demo enviroment
1. Run '$vagrant up' to set up the two servers. 
2. You can run '$vagrant status' to list the two servers that you just created. 

## Demo steps: Client Key Signing 
SSH to 'vaultserver': $vagrant ssh vaultserver
1. Mount the secret engine. You can mount different paths with the same secret engine. 
* '$vault secrets enable -path=dev-ssh-client ssh' 
2. Config Vault with a CA for signing client keys. 
* If you don't have an internal CA, use below CLI to get Vault generate a keypair for you. 

'$vault write dev-ssh-client/config/ca generate_signing_key=true'
* If you have a keypair, use below CLI to specify the public/priviate key.

'$vault write dev-ssh-client/config/ca private_key="aded..." public_key="abcd..."'

Please note:
* You can config Vault with a CA using the '/config/ca' endpoint.
* The client signer public key is accessible via the API at the '/public_key' endpoint.

3. Generate pem file (e.g. dev-user-ca-keys.pem) with either of the method 
below. Then copy the generated pem file to the '/etc/ssh' folder of your host. 
* '$curl -o dev-user-ca-keys.pem http://127.0.0.1:8200/v1/dev-ssh-client/public_key'
* '$vault read -field=public_key dev-ssh-client/config/ca > dev-user-ca-keys.pem'

4. Add the public key to the target host's SSH configuration. In this demo, we will add the 'dev-user-ca-keys.pem' file to the 'hostsever'.
* Copy the pem file to the shared folder (/vagrant) in vm. '$cp dev-user-ca-keys.pem /vagrant/' 
* In another terminal, ssh to 'hostserver': '$vagrant ssh hostserver' 
* Copy the pem file from the shared folder to the 'etc/ssh' folder: '$ sudo cp /vagrant/dev-user-ca-keys.pem /etc/ssh/'
* Edit the '/etc/ssh/sshd_config' file: '$sudo vim /etc/ssh/sshd_configg'
* Add 'TrustedUserCAKeys /etc/ssh/dev-user-ca-keys.pem' to the 'sshd_config' file.
* Restart the SSH service to pick up the change: '$sudo systemctl restart ssh.service'.

5. Create a named Vault role for signing client keys on 'vaultserver'
'$vault write dev-ssh-client/roles/my-role -<<"EOH"
{
   "allow_user_certificates": true,
   "allowed_users": "*",
   "default_extensions": [
     {
      "permit-pty": ""
     }
  ],
  "key_type": "ca",
  "default_user": "ubuntu",
  "ttl": "30m0s"
}
EOH
'

## Demo steps: Client SSH Authentication
In below steps, we will use a user running on the 'vaultserver' to try to ssh auth to the 'hostserver' - which is managed by 'vaultserver'.
1. In the 'vaultserver'. generate the SSH public key with below command:
* $ssh-keygen -t rsa -C "user1@example.com"
* Use the default file to save the key -- /home/vagrant/.ssh/id_rsa
2. Ask Vault to sign your public key. 
* $vault write dev-ssh-client/sign/my-role public_key=@$HOME/.ssh/id_rsa.pub 
* You will get a serial_number and a signed_key. The signed key is another public key.
3. Save the resulting signed public key to disk. 
* $vault write -field=signed_key dev-ssh-client/sign/my-role public_key=@$HOME/.ssh/id_rsa.pub > signed-cert.pub
4. Now you can ssh to the host machine 'hostserver' using the signed key. 
* $ssh -i signed-cert.pub -i ~/.ssh/id_rsa user@192.168.0.101