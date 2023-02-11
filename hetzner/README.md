# Hetzer Cloud specific instructions

```shell
source .env
terraform apply -auto-approve -var="hcloud_token=${HCLOUD_TOKEN}"  -var-file="variables.tfvars"
terraform destroy -auto-approve -var="hcloud_token=${HCLOUD_TOKEN}"  -var-file="variables.tfvars"
```
