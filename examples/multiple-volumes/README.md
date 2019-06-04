# example: Create VMs with Local and Network Filesystems

## Recommends

- [direnv](https://github.com/direnv/direnv)
- [tfenv](https://github.com/tfutils/tfenv)

## Before use

Edit the `.envrc` file with `direnv edit .` command.

```
export PROJECT_UUID='YOUR_UNIQ_STRING'
export GOOGLE_CREDENTIALS="${PWD}/gcp-service-account-key.json"
export CLOUDSDK_CORE_PROJECT="YOUR-GCP-PROJECT-ID"
export TF_VAR_gcp_project_id="YOUR-GCP-PROJECT-ID"
export TF_VAR_current_external_ipaddr="$(curl -Ls ifconfig.io)/32"
```

Create a Cloud Storage bucket for save tfstate.

see https://cloud.google.com/storage/docs/gsutil

```shellsession
$ gsutil mb gs://${PROJECT_UUID}/
Creating gs://YOUR_UNIQ_STRING/...
$ gsutil acl set private gs://${PROJECT_UUID}/
Setting ACL on gs://YOUR_UNIQ_STRING/...
$ gsutil versioning set on gs://${PROJECT_UUID}/
Enabling versioning for gs://YOUR_UNIQ_STRING/...
```
```shellsession
$ gsutil ls -Lb gs://${PROJECT_UUID}/
gs://YOUR_UNIQ_STRING/ :
        Storage class:                  STANDARD
        Location constraint:            US
        Versioning enabled:             True
(omitted)
        Bucket Policy Only enabled:     False
        ACL:
          [
            {
              "entity": "project-owners-012345678901",
              "projectTeam": {
                "projectNumber": "012345678901",
                "team": "owners"
              },
              "role": "OWNER"
            }
          ]
        Default ACL:
(omitted)
```

## How to use

1. Install Terraform via tfenv.

```shellsession
$ tfenv install min-required
```

or

```shellsession
$ tfenv use min-required
```

2. `terraform init`

```shellsession
$ terraform init -backend-config="bucket=${PROJECT_UUID}"
```

3. `terraform apply`

```shellsession
$ terraform apply
```
```
Outputs:

google_compute_instance-multiple-volumes-instances = {
  "instance-01" = "35.226.*.66"
  "instance-02" = "104.198.*.1"
}
```

After running the `terraform apply` command, probably you should reset the GCE instance.

```shellsession
$ gcloud compute instances reset $GCE_INSTANCE_NAME
```

4. Login via SSH

```shellsession
$ ssh -l $YOUR_NAME $IPADDR hostname
gpu-instance-1
```

### Additional samples: Using Local SSDs and Persistent Disks

List block devices.

```shellsession
$ lsblk 
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0     7:0    0 88.4M  1 loop /snap/core/6964
loop1     7:1    0 58.9M  1 loop /snap/google-cloud-sdk/84
sda       8:0    0   10G  0 disk 
├─sda1    8:1    0  9.9G  0 part /
├─sda14   8:14   0    4M  0 part 
└─sda15   8:15   0  106M  0 part /boot/efi
sdb       8:16   0  500G  0 disk 
sdc       8:32   0  500G  0 disk 
nvme0n1 259:0    0  375G  0 disk 
```

Create a partition on the block device.

```shellsession
$ sudo gdisk /dev/sdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries.

Command (? for help): n
Partition number (1-128, default 1): 
First sector (34-1048575966, default = 2048) or {+-}size{KMGTP}: 
Last sector (2048-1048575966, default = 1048575966) or {+-}size{KMGTP}: 
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 
Changed type of partition to 'Linux filesystem'

Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): y
OK; writing new GUID partition table (GPT) to /dev/sdb.
The operation has completed successfully.
```

Check the partition.

```shellsession
$ sudo gdisk -l /dev/sdb
GPT fdisk (gdisk) version 1.0.3

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.
Disk /dev/sdb: 1048576000 sectors, 500.0 GiB
Model: PersistentDisk  
Sector size (logical/physical): 512/4096 bytes
Disk identifier (GUID): E18A394A-0228-446F-8B8F-27456C66923C
Partition table holds up to 128 entries
Main partition table begins at sector 2 and ends at sector 33
First usable sector is 34, last usable sector is 1048575966
Partitions will be aligned on 2048-sector boundaries
Total free space is 2014 sectors (1007.0 KiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048      1048575966   500.0 GiB   8300  Linux filesystem
```

Format the partition.

```shellsession
$ sudo mkfs.ext4 /dev/sdb1
mke2fs 1.44.1 (24-Mar-2018)
Discarding device blocks: done                            
Creating filesystem with 131071739 4k blocks and 32768000 inodes
Filesystem UUID: 5d495373-6573-4523-8149-8959b268f814
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
        102400000

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done
```

Mount the partition.

```shellsession
$ sudo mkdir -p /mnt/pd-ssd
$ sudo mount /dev/sdb1 /mnt/pd-ssd
```

```shellsession
$ lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
loop0         7:0    0 88.4M  1 loop /snap/core/6964
loop1         7:1    0 58.9M  1 loop /snap/google-cloud-sdk/84
sda           8:0    0   10G  0 disk 
├─sda1        8:1    0  9.9G  0 part /
├─sda14       8:14   0    4M  0 part 
└─sda15       8:15   0  106M  0 part /boot/efi
sdb           8:16   0  500G  0 disk 
└─sdb1        8:17   0  500G  0 part /mnt/pd-ssd
sdc           8:32   0  500G  0 disk 
└─sdc1        8:33   0  500G  0 part 
nvme0n1     259:0    0  375G  0 disk 
└─nvme0n1p1 259:2    0  375G  0 part 
```

### Additional samples: Using Cloud Filestore

Install `nfs-common` package.

```shellsession
$ sudo apt update
$ sudo apt install -y --no-install-recommends nfs-common
```

Mount Cloud Filestore fileshare.

```shellsession
$ sudo mkdir -p /mnt/filestore-standard
$ sudo mount 10.121.215.122:/default /mnt/filestore-standard
```

```shellsession
$ df -h --type=nfs
Filesystem               Size  Used Avail Use% Mounted on
10.121.215.122:/default 1007G   76M  956G   1% /mnt/filestore-standard
10.249.22.218:/default   2.5T   88M  2.4T   1% /mnt/filestore-premium
```

### Additional samples: Benchmarking filesystems

```shellsession
$ sudo chmod a+rwx /mnt/*
```

Install `fio` package.

```shellsession
$ sudo apt update
$ sudo apt install -y --no-install-recommends fio
```

```shellsession
(your-local)$ tar c sample-files | ssh -l $YOUR_NAME $IPADDR tar x
```

```shellsession
$ sh ~/sample-files/generate_fio.sh > exec.sh
$ . exec.sh
```

## Links

- [Adding Local SSDs](https://cloud.google.com/compute/docs/disks/local-ssd)
- [Adding or Resizing Zonal Persistent Disks](https://cloud.google.com/compute/docs/disks/add-persistent-disk)
- [Mounting Fileshares on Compute Engine Clients](https://cloud.google.com/filestore/docs/mounting-fileshares)
