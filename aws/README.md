# AWS specific instructions (not tested)

todo

```shell

terraform apply -auto-approve -var="access_key=${AWS_ACCESS_KEY_ID}" -var="secret_key=${AWS_SECRET_KEY_ID}" -var-file="../config/variables.tfvars"
terraform destroy -auto-approve -var="access_key=${AWS_ACCESS_KEY_ID}" -var="secret_key=${AWS_SECRET_KEY_ID}" -var-file="../config/variables.tfvars"
```
