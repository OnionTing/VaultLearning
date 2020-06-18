# Create a read-only permission on 'secret/data/mysql' path
path "secret/data/mysql/*" {
    capabilities = ["read"]
}
