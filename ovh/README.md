# OVH Specific Setup Instructions

Link to [OVH Cloud](https://www.ovhcloud.com/de/)

**At the time of testing GPU instances could not be created in region GRA9**

## Requirements

- an OVH Account
- OVH Public Cloud Project
- access to a OVH region that supports GPU instances (optional)
- An API User and the openrc.sh file which needs to be put into $BASEPATH/config/
- API Keys for $BASEPATH/config/config.sh

OVH also needs the openstack client, which is needed for the `openrc.sh` file.
```shell
pip3 install python-openstackclient
```

## openrc.sh

The openrc.sh.example file is being changed to work with long running jobs. You still need to fill in your own data from your openstack OVH user.

```shell
export OS_TENANT_ID="your-tenant-id"
export OS_TENANT_NAME="your-tenant-name"
export OS_USERNAME="user-somerandomstring"
# With Keystone you pass the keystone password.
#echo "Please enter your OpenStack Password: "
#read -sr OS_PASSWORD_INPUT
#export OS_PASSWORD=$OS_PASSWORD_INPUT
export OS_PASSWORD="youropenstackuserpassword"
```
