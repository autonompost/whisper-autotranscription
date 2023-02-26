# variables.tfvars depending on which cloud provider you want to use
# do
#number_vms = 2
#region = "fra1"
#ssh_public_key_name = "whisper-ssh-key"
#instance_name = "vm-whisper"
#instance_type = "s-1vcpu-2gb"
#os_image = "ubuntu-22-04-x64"
# hetzner
#number_vms = 2
#region = "fsn1"
#ssh_public_key_name = "whisper-ssh-key"
#instance_name = "vm-whisper"
#instance_type = "ccx21"
#os_image = "debian-11"
# linode
region = "eu-central"
ssh_public_key_name = "whisper-ssh-key"
instance_name = "vm-whisper"
instance_type = "g1-gpu-rtx6000-1"
os_image = "linode/debian11"
# ovh
# ran into errors even in the interface #region = "GRA9" 
#region = "BHS5"
#ssh_public_key_name = "whisper-ssh-key"
#instance_name = "vm-whisper"
#instance_type = "t1-45" # GPU Instance
#os_image = "Debian 11"
##instance_type = "b2-7" # for testing
