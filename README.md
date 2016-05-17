
# `rancher/os` installer

The container can be used directly, but there is a wrapper in RancherOS CLI, `ros install`, that handles calling things in the right order.

## Building

First, build RancherOS minimal set of artifacts: `initrd`, `vmlinuz`. You will also need the `.dtb` file for the board you're targeting (e.g. Estuary D02's would be `hip05-d02.dtb`). Copy those files into `./dist/artifacts` of this repo. Then run the following:

```
docker build -t rancher/os:v0.4.5_arm64 --build-arg VERSION=v0.4.5 .
```

The image name and `VERSION` are customizable.

## Basics

When booting, RancherOS looks for a device labeled `RANCHER_STATE`. If it finds a volume with that label, the OS will mount the device and use it to store state.

The scripts in this container will create an EFI disk partition (for GRUB2 boot loader and its configuration) and RancherOS state partition (labeled RANCHER_STATE).

The following steps are performed during install:

1. ) Partition device with EFI (200MB) and Linux partitions (the rest of the disk size).
2. ) Format EFI partition as vfat, RancherOS state as ext4 and label as `RANCHER_STATE`
3. ) Install grub2 (actually,just copy grubaa46.efi) and grub.cfg on EFI partition
4. ) Place kernel, initrd and device-tree file into `/boot` on the state partition.
5. ) Seed the cloud-config data so that authorized_keys or other RancherOS configuration can be set.


## Usage

```
 # Partition disk without prompting of any sort:
 docker run --privileged -it --entrypoint=/scripts/set-disk-partitions rancher/os:<version> <device>


 # install 
 docker run --privileged -it -v /home:/home -v /opt:/opt \
        rancher/os:<version> -d <device> -t <install_type> -c <cloud-config file> \
        -i /custom/dist/dir \
        -f </src/path1:/dst/path1,/src/path2:/dst/path2,/src/path3:/dst/path3>
```

The installation process requires a cloud config file. It needs to be placed in either `/home/rancher/` or `/opt/`. The installer make use of the user-volumes to facilitate files being available between system containers. `-i` and `-f` options are optional. 

By providing `-i` (or `DIST` env var) you specify the path to your custom `vmlinuz` and `initrd`. 
  
`-f` allows you to copy arbitrary files to the target root filesystem.

