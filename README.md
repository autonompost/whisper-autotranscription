# Autotranscription with Whisper

## Version 1

- [ ] Provision single VM
- [ ] Supported Cloud Platforms
	- [ ] Hetzner Cloud
	- [ ] Linode (GPU)
	- [ ] OVH (GPU)
	- [ ] Digitalocean
- [ ] Install Whisper via Pip
- [ ] Upload files from local filsystem
- [ ] Use config parameter to specify model type
- [ ] Autodetect language
- [ ] Upload completed files via rclone

## Version 2

- [ ] Terraform Modules for multiple VMs for all supported cloud providers
- [ ] Use Docker Whisper Web Image https://github.com/ahmetoner/whisper-asr-webservice
- [ ] tbd

The Terraform part is based on the [Complete and Official Documentation](https://github.com/ovh/docs/blob/develop/pages/platform/public-cloud/how_to_use_terraform/guide.en-us.md)

## Setup Steps

```shell
# cookiecutter
pip3 install cookiecutter

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

```
