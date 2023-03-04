# testing and personal remarks


## OVH

In order to use GPU instances I had to pay 200 Euro upfront. Which is fair I think. But OVH has its other _quirks_, so to speak.

Occasionally I had the problem that one VM had issues when getting initialized. I added an Ansible task to the cuda role to check that the `nvidia-smi` command shows at least one GPU.

```shell
[   95.405974] NVRM: GPU 0000:00:06.0: GPU does not have the necessary power cables connected.
[   95.408202] NVRM: GPU 0000:00:06.0: RmInitAdapter failed! (0x24:0x1c:1428)
```

```shell
root@vm-whisper-0:~# nvidia-smi --query-gpu=count --format=csv,noheader
No devices were found
root@vm-whisper-0:~# echo $?
6
```

## GCP

Imagine being a global cloud provider and even if I am a private customer, denying access to more than one GPU (Tesla T4 in that matter) is kind of ridiculous.

Anyways. If you create small bulks of audio files and use GCP (I configured the terraform code to use Spot instances) you pay for a n1-standard-4 + Tesla T4 card around 0,15 Dollar an hour. This is cheap.

So, even if your transcription process gets interrupted because the Spot instance gets killed, you will be cheaper than anything I have seen so far. Well, pending AWS and Azure comparision.

