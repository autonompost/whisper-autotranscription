# variables.tfvars depending on which cloud provider you want to use
# do
#number_vms = 2
#region = "fra1"
#ssh_public_key_name = "whisper-ssh-key"
#instance_name = "vm-whisper"
#instance_type = "s-1vcpu-2gb"
#os_image = "ubuntu-22-04-x64"
# hetzner
number_vms = 2
region = "fsn1"
ssh_public_key_name = "whisper-ssh-key"
instance_name = "vm-whisper"
instance_type = "ccx21"
os_image = "ubuntu-22.04"
# linode 
#number_vms = 2
#region = "eu-central"
#ssh_public_key_name = "whisper-ssh-key"
#instance_name = "vm-whisper"
#instance_type = "g6-standard-1"
#os_image = "linode/ubuntu22.04"
# ovh
#number_vms = 2
#region = "GRA9"
#ssh_public_key_name = "whisper-ssh-key"
#instance_name = "vm-whisper"
#instance_type = "b2-7" # for testing
##instance_type = "t1-45" # GPU Instance
#os_image = "Ubuntu 22.04"
