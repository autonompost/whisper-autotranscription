# Autotranscription with Whisper

## Version 1

- [x] Provision multiple VMs for parallel processing
- [x] Supported Cloud Platforms
	- [x] Hetzner Cloud
	- [x] Linode (GPU)
	- [x] OVH (GPU)
	- [x] Digitalocean
- [x] Use OpenAI Whisper
- [x] Upload/Download files from/to local filsystem
- [x] Autodetect language
- [ ] GPU instance support with Nvidia Cuda

## Version 2

- [ ] Obsidian audio-files plugin support
- [ ] automatic translation to specified language for transcripts
- [ ] use rclone directly on the remote system without any local files
- [ ] use ChatGPT to create summaries for transcripts
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
