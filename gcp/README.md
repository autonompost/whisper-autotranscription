# GCP specific instructions

## Requirements

- A Google Cloud Account
- A GCP Project needed for `project_id` Terraform variable
- Install gcloud CLI as documented at [Install the Google Cloud CLI](https://cloud.google.com/sdk/docs/install-sdk)
- Enough resouce quotas for GPU use globally and per region

With `gcloud` command installed and available in your $PATH, login in the CLI

```shell
gcloud auth login
```

## Additional Setup Information for GPU Usage

In order to use a GPU `number_gpus` needs to be set at least to `1`.

```shell
number_gpus = 1
gpu_type = "nvidia-tesla-a100"
```
The use of GPUs is directly bound which machine-type needs to be used. An overview of all available options can be found at [GPU platforms](https://cloud.google.com/compute/docs/gpus/).

## Available Machine-Types (instance_type)

You can get all machine-types, which is needed for the `instance_type` Terraform variable for example with:
```shell
gcloud compute machine-types list -zones europe-west4-a
```
