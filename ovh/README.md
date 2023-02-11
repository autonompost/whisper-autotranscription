# OVH Whisper Autotranslate

todo...

The Terraform part is based on the [Complete and Official Documentation](https://github.com/ovh/docs/blob/develop/pages/platform/public-cloud/how_to_use_terraform/guide.en-us.md)

## Requirements

- an OVH Account
- OVH Public Cloud Project
- access to a OVH region that supports GPU instances (optional)
- Python3 + pip3
- Terraform ~>0.14.0 # download from [here](https://developer.hashicorp.com/terraform/downloads)
- Ansible >= 2.13.4 # see in the install section
- Bash

```shell
# git clone the project
git clone https://codeberg.org/ybaumy/ovh-whisper-autotranslate.git

# generate a ssh key
ssh-keygen -t rsa -b 4096 -f ./id_rsa

# install ansible and the openstack client which is needed for openrc.sh
pip3 install python-openstackclient ansible

# modify your .env file
cp .env_example .env
chmod 600 .env

# download your OVH user openrc.sh file


terraform apply  -auto-approve -var-file="variables.tfvars"
terraform destroy -auto-approve -var-file="variables.tfvars"
```
