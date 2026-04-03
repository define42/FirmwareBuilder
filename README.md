# MyFW Buildroot + RAUC example

This is a starter repo for a Buildroot-based x86_64 appliance with:

- GRUB EFI boot
- A/B rootfs partitions
- writable `/data`
- RAUC system config
- signed `.raucb` bundle generation helper

## What is included

- `Makefile`: thin wrapper around Buildroot
- `br2-external/`: external tree with config and board files
- `genimage.cfg`: initial provisioning image layout
- `make-bundle.sh`: produces a signed RAUC bundle from `rootfs.ext4`
- placeholder cert files in `certs/`

## Important

- You still need to clone Buildroot into `./buildroot`
- The cert files are placeholders; replace them before creating bundles
- The RAUC package symbols can vary by Buildroot release, so enable `rauc` and `host-rauc` in `make menuconfig` if needed
- The GRUB slot logic here is a starter template, not a production-grade rollback policy

## Quick start

```bash
git clone https://github.com/buildroot/buildroot.git
make build
make bundle VERSION=1.0.1
```

Outputs should land in `output/images/`.

## Provisioning

Flash the initial image once:

```bash
sudo dd if=output/images/myfw.img of=/dev/sdX bs=4M status=progress oflag=sync
sync
```

## Updating

Copy a bundle to the device and install it:

```bash
rauc install /data/update-1.0.1.raucb
reboot
```
