# Digitalocean specific instructions

```shell
source .env
terraform apply -auto-approve -var="do_token=${DO_TOKEN}" -var-file="variables.tfvars"
terraform destroy -auto-approve -var="do_token=${DO_TOKEN}" -var-file="variables.tfvars"
```
