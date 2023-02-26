# Autotranscription with Whisper

This will let you bulk transcribe audio files using a cloud provider of your choice. The project is using `terraform` to create a number of instances and uses `ansible` to configure and transcribe the files in parallel using whisper.

**You should really use a cloud provider which supports GPU's. Even on instances with 16 CPU's the transcribe process is horribly slow**

> of course you can use a service like [replicate](https://replicate.com/), I will have to see what costs like a bulk transcripts would cost on replicate and than compare it

## Version 1

- [x] Provision multiple VMs for parallel processing
- [x] Supported Cloud Providers
	- [x] Hetzner Cloud (mostly used for testing)
	- [x] OVH (GPU)
  - [x] GCP (GPU) (using spot instances)
- [x] Use OpenAI Whisper
- [x] Upload/Download files from/to local filsystem
- [x] Autodetect language
- [x] GPU instance support with Nvidia Cuda

## Version 1.1

- [ ] Supported Cloud Providers
  - [ ] AWS (GPU)

## Version 2

- [ ] [Obsidian audio-notes](https://github.com/jjmaldonis/obsidian-audio-notes) plugin support
- [ ] automatic translation with DeepL to a specified language for transcripts
- [ ] use rclone directly on the remote system without any local files
- [ ] automatically create summaries for transcripts
- [ ] Supported Cloud Providers
  - [ ] Azure (GPU)
	- [ ] Linode (GPU) (not yet fully tested since I did not get any GPU instance access)

## Version 3

- [ ] [Speaker Identification](https://github.com/lablab-ai/Whisper-transcription_and_diarization-speaker-identification-)
- [ ] Use DeepL Write API to automatically correct grammar

## General Setup Steps

In order to use this project 

### Global Config

```shell
```

### Terraform Variables

```shell
```

### Ansible Variables

```shell
```

### Cloud Provider Specific Instructions

- [OVH](./ovh/README.md)
- [GCP](./gcp/README.md)
- [Hetzner Cloud](./hetzner/README.md)

#### Not full tested cloud providers

- [Linode](./linode/README.md)
- [Digitalocean](./digitalocean/README.md)

## Contributing

Feel free to fork and open up a pull request either to fix errors or add functionality.
