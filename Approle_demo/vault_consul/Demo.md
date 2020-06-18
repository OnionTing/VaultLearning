# About this demo
In this demo, we will use consul as storage for vault. Please use https://github.com/OnionTing/VaultLearning to set up the demo enviroment. 


# Demo steps

## step1 enable Approle
* SSH to the VM :'$ vagrant ssh'
* Check the Vault status, it has been initialized and unsealed: '$ vault status' 
* enable approle auth method: '$ vault auth enable approle'
