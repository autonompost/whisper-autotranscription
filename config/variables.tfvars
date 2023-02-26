# variables.tfvars depending on which cloud provider you want to use
ssh_public_key_name = "whisper-ssh-key"
instance_name = "vm-whisper"

# do
#region = "fra1"
#instance_type = "s-1vcpu-2gb"
#os_image = "ubuntu-22-04-x64"

# hetzner
#number_vms = 2
#region = "fsn1"
#instance_type = "ccx21"
#os_image = "debian-11"

# linode
#region = "eu-central"
#instance_type = "g1-gpu-rtx6000-1"
#os_image = "linode/debian11"

# ovh
# ran into errors even in the interface #region = "GRA9"
#region = "BHS5"
#instance_type = "t1-45" # GPU Instance
#os_image = "Debian 11"
##instance_type = "b2-7" # for testing

# gcp
#instance_type = "a2-highgpu-1g"
instance_type = "n1-standard-4"
os_image = "debian-cloud/debian-11"
region = "europe-west4"
zone = "europe-west4-a"
project_id = "whisper-378417"
number_gpus = 0
gpu_type = "nvidia-tesla-t4"
#gpu_type = "nvidia-tesla-a100"
