# Linode specific instructions

**Support must be contacted if GPU instances should be used, since they have limited availability. Since I did not get access to GPU instance types, this has not been tested with Linode.**

## Requirements

- A Linode Account
- A Linode API Token which can be created as documented at [Guides - Linode API Keys and Tokens](https://www.linode.com/docs/products/tools/cloud-manager/guides/cloud-api-keys/)

Add the API token to the `config/secrets.sh` at `LINODE_TOKEN`.

## linode instance types available as of 2023-02-11

```
g6-nanode-1
g6-standard-1
g6-standard-2
g6-standard-4
g6-standard-6
g6-standard-8
g6-standard-16
g6-standard-20
g6-standard-24
g6-standard-32
g7-highmem-1
g7-highmem-2
g7-highmem-4
g7-highmem-8
g7-highmem-16
g6-dedicated-2
g6-dedicated-4
g6-dedicated-8
g6-dedicated-16
g6-dedicated-32
g6-dedicated-48
g6-dedicated-50
g6-dedicated-56
g6-dedicated-64
g1-gpu-rtx6000-1
g1-gpu-rtx6000-2
g1-gpu-rtx6000-3
g1-gpu-rtx6000-4
```
