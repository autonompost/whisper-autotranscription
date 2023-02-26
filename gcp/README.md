# GCP specific instructions

```shell
source .env
terraform apply -auto-approve -var-file="variables.tfvars"
terraform destroy -auto-approve -var-file="variables.tfvars"
```
