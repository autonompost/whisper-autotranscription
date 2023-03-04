# variables.tfvars depending on which cloud provider you want to use
# THOSE CAN BE CHANGED BUT DO HAVE TO BE CHANGED
ssh_public_key_name = "whisper-ssh-key"
instance_name = "vm-whisper"

# digitalocean
#region = "fra1"
#instance_type = "s-1vcpu-2gb"
#os_image = "ubuntu-22-04-x64"

# hetzner
#number_vms = 1
#region = "fsn1"
#instance_type = "ccx21"
#os_image = "debian-11"

# linode
#region = "eu-central"
#instance_type = "g1-gpu-rtx6000-1"
#os_image = "linode/debian11"

# ovh
# ran into errors even in the interface #region = "GRA9"
region = "BHS5"
instance_type = "t1-45" # GPU Instance
os_image = "Debian 11"
##instance_type = "b2-7" # for testing

# gcp
#instance_type = "a2-highgpu-1g"
#instance_type = "n1-standard-4"
#os_image = "debian-cloud/debian-11"
#region = "asia-east1"
#zone = "asia-east1-a"
#project_id = "whisper-378417"
#number_gpus = 1
#gpu_type = "nvidia-tesla-t4"
#gpu_type = "nvidia-tesla-a100"
