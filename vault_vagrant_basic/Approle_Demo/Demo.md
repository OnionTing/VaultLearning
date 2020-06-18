# About this demo
In this demo, we will use consul as storage for vault. Please use https://github.com/OnionTing/VaultLearning to set up the demo enviroment. 


# Demo steps

## step1: enable Approle
* SSH to the VM :'$ vagrant ssh'
* Check the Vault status, it has been initialized and unsealed: '$ vault status' 
* enable approle auth method: '$ vault auth enable approle'

## step2: create the policy for the role 
Create the policy 'jenkins-policy.hcl' to set the proper permission for the role. You can find this file in the synced folder. 

'$ cd /vagrant/Approle_Demo' 

We name the police as 'jenkins'. Run the following command: '$ vault policy write jenkins jenkins-policy.hcl' 

## step3: create a new AppRole with the Jenkins policy 
Set the token ttl to be 1 hour and can be renew up to 4 hours of its first creation. And the policy attached to it is the Jenkins. Note, you can attached multiple policies to the approle.

'$vault write auth/approle/role/jenkins_approle token_policies="jenkins" token_ttl=1h token_max_ttl=4h'

Read the jenkins_approle we just created to verify: 

'$vault read auth/approle/role/jenkins_approle'

## step4: get RoleID and SecretID
From the above steps, we have created an Approle (jenkins_approle) which operates in pull mode. 

* Retrieve the RoleID for jenkins_approle: '$vault read auth/approle/role/jenkins_approle/role-id'
* Generate a SecretID for jenkins_approle: '$vault write -f auth/approle/role/jenkins_approle/secret-id'

Note: you can sepeicify ttl and other parameters when generating SecretID.

Save the RoleID and SecretID.

## step5: Use the RoleID and SecretID to login
The client (e.g. Jenkins, other app) could use the RoleID and SecretID that we generated in above steps to login. 

* If you want to use CLI, Run: '$vault write auth/approle/login role_id="[the RoleID]" secret_id="[the SecreteID]"' . You will get the token. 
* If you want to use API call (Curl), please update the 'payload.json' file with your RoleID and SecretID first, then Run: '$curl --request POST --data @payload.json http://127.0.0.1:8200/v1/auth/approle/login | jq' . You will get the token.

## step6: Read secrets using the Approle token
The approle have read permission for secrets stored in path 'secret/data/mysql/*'. 

* Use the Admin token (not the Jenkins_approle token) to create the secrets. You can use the 'mysqldata.json' file. Run command: '$vault kv put secret/data/mysql/webapp @mysqldata.json'

You can test if you have saved the kv pair by running: 'vault kv get secret/data/mysql/webapp'

* Login with the token from 'step5', read the kv. Please replace the token value with your token value from step5.

'$VAULT_TOKEN=s.aaaabbbbbb vault kv get secret/data/mysql/webapp' 

or '$vault login s.aaaaabbbbb' 'vault kv get secret/data/mysql/webapp'


# Distroy the demo
'$ exit'
'$vagrant destroy'