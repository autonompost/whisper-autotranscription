# Autotranscription with Whisper


This will let you bulk transcribe audio files using a cloud provider of your choice. The project is using `terraform` to create a number of instances and uses `ansible` to configure and transcribe the files in parallel using whisper.

**You should really use a cloud provider which supports GPU's. Even on instances with 16 CPU's the transcribe process is horribly slow**

> of course you can use a service like [replicate](https://replicate.com/), I will have to see what costs like a bulk transcripts would cost on replicate and than compare it

Also, some general remarks can be found here [testing](./testing.md).

## General Setup Steps

This project has been testing with the following versions:

- Terraform 1.3.9
- Ansible 2.13.4
- Python 3.10.10
- openstack client 6.0.0

In order to use this project, first create your config files as described in the section below.

```shell
Usage: ./whisper-autotranscription.sh [-f CONFIGFILE] [-n NUMBER VMS] [-h]
  -f CONFIGFILE Specify a config file (optional. will use config/config.sh if not specified))
  -n NUMVMS     Specify a number of VMS to create (optional. will use 1 if not specified))
  -m MODE       Specify the mode whisper|whisperx (optional. will use whisper if not specified)
  -h            Display this help message
```

### whisperX Usage (Not recommended yet)

There is also the possibility to use [whisperX](https://github.com/m-bain/whisperX) instead of `whisper`.

For this you need a [huggingface account](https://huggingface.co) and a token.

You will also need to accept the Terms and Conditions for [speaker-diarization](https://huggingface.co/pyannote/speaker-diarization) and [segmentation](https://huggingface.co/pyannote/segmentation).

**whisperX only works with .wav files currently because of a bug in [python-soundfile](https://github.com/m-bain/whisperX/issues/41)**

Copy `config/ansible_secrets.yaml_example` to `config/ansible_secrets.yaml` and add you token to `config/ansible_secrets.yaml`.

### Files

Files that need to be processed need to be put in `files_upload` directory `$SRC_DIR`. After the transcription the files will first be downloaded to `files_download` directory `$DST_DIR` and then copied to the originating directories in `files_upload` or `$SRC_DIR`.

If the variable `CLEANUP` is set to `true`, the files in `files_download` will be deleted.

### config.sh

The file `config/config.sh_example` needs to be copied over to `config/config.sh`

```shell
cp config/config.sh_example config/config.sh
```

Adjust the values according to your needs.

### Terraform Variables

The terraform tfvars file `config/variables.tfvars_example` needs to be copied over to `config/variables.tfvars`

```shell
cp config/variables.tfvars_example config/variables.tfvars
```

Adjust the values according to your needs.

### Ansible Variables

The file `templates/ansible_vars.yaml_example` needs to be copied over to `templates/ansible_vars.yaml`.

```shell
cp templates/ansible_vars.yaml_example templates/ansible_vars.yaml
```

In the `templates/ansible_vars.yaml` file the model size can be set and also the path to download the files to. This needs to be the same as the `DST_DIR` from the `config/config.sh`.

**DO NOT CHANGE the variable for THREADS, this is done in the `whisper-autotranscription.sh` script which will get the value according to `instance_type`**

**Change `whisper_parameters` if you want to optimize your whisper settings**.

```shell
instance_threads: THREADS
whisper_model_size: "medium"
whisper_retry_count: 3
whisper_retry_delay: 10
file_directory: "/pathto/whisper-autotranscription/files_download"
whisper_parameters: "--language de --extend_duration 0.1"
```

### secrets.sh

The file `config/secrets.sh_example` needs to be copied over to `config/secrets.sh`.

```shell
cp config/secrets.sh_example config/secrets.sh
```

Edit the file and add the API Token(s) of your Cloud Provider

```shell
DO_TOKEN=
HCLOUD_TOKEN=
LINODE_TOKEN=
OVH_APPLICATION_KEY=
OVH_APPLICATION_SECRET=
OVH_CONSUMER_KEY=
```

For `GCP` use `gcloud auth login` in order to use terraform.

### Cloud Provider Specific Instructions

- [OVH](./ovh/README.md)
- [GCP](./gcp/README.md)
- [Hetzner Cloud](./hetzner/README.md)

#### Not full tested cloud providers

- [Linode](./linode/README.md)
- [Digitalocean](./digitalocean/README.md)


## Roadmap

### Version 1

- [x] Provision multiple VMs for parallel processing
- [x] Supported Cloud Providers
	- [x] Hetzner Cloud (mostly used for testing)
	- [x] OVH (GPU)
  - [x] GCP (GPU) (using spot instances)
- [x] Use OpenAI Whisper
- [x] Upload/Download files from/to local filsystem
- [x] Autodetect language
- [x] GPU instance support with Nvidia Cuda
- [x] use [whisperX](https://github.com/m-bain/whisperX) instead of whisper

### Version 1.1

- [ ] more CLI script parameters to reduce the config file mess
- [ ] option for maximum number of files to transcribe
- [ ] upload only files from files_upload that have not been transcribed
- [ ] Supported Cloud Providers
  - [ ] AWS (GPU)

### Version 2

- [ ] [Obsidian audio-notes](https://github.com/jjmaldonis/obsidian-audio-notes) plugin support
- [ ] automatic translation with DeepL to a specified language for transcripts
- [ ] use rclone directly on the remote system without any local files
- [ ] automatically create summaries for transcripts
- [ ] [whisperX](https://github.com/m-bain/whisperX) diarization (currently not so great)
- [ ] [Speaker Identification](https://github.com/lablab-ai/Whisper-transcription_and_diarization-speaker-identification-)
- [ ] Supported Cloud Providers
  - [ ] Azure (GPU)
  - [ ] Linode (GPU) (not yet fully tested since I did not get any GPU instance access)

## Version 3

- [ ] Use DeepL Write API to automatically correct grammar

## Contributing

Feel free to fork and open up a pull request either to fix errors or add functionality.
