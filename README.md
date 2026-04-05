# MyFW Buildroot + RAUC example

This is a starter repo for a Buildroot-based x86_64 appliance with:

- GRUB EFI boot
- A/B rootfs partitions
- writable `/data`
- NetForge preinstalled and started at boot
- RAUC system config
- signed `.raucb` bundle generation helper
- a top-level `Makefile` that can download and unpack Buildroot automatically when `./buildroot` is missing

## What is included

- `Makefile`: wrapper around Buildroot with bootstrap logic
- `br2-external/`: external tree with config and board files
- `genimage.cfg`: initial provisioning image layout
- `make-bundle.sh`: produces a signed RAUC bundle from `rootfs.ext4`
- placeholder cert files in `certs/`
- generated development certs under `output/generated-certs/`

## Expected layout

After extracting the zip, the repo should look like this:

```text
myfw-buildroot-rauc-example/
├── Makefile
└── br2-external/
```

On first `make`, the wrapper Makefile is expected to create or use:

```text
myfw-buildroot-rauc-example/
├── buildroot/
├── dl/
├── output/
└── .tmp/
```

## Important

- The top-level `Makefile` expects either `curl` or `wget`, plus `tar`
- `make` and `make bundle` auto-generate development certs in `output/generated-certs/`
- The checked-in cert files are placeholders only; replace the generated development cert flow before shipping real bundles
- The exact RAUC package symbols can vary by Buildroot release, so if the defconfig does not enable them automatically, run `make menuconfig` and enable `rauc` and `host-rauc`
- The GRUB slot logic here is a starter template, not a production-grade rollback policy
- The initial install image is `output/images/myfw.img`
- Later updates are `.raucb` bundles built from the current `rootfs.ext4`

## Quick start

From the repo root:

```bash
make
make bundle VERSION=1.0.1
```

On the first run, `make` should:

1. download a Buildroot release tarball if `./buildroot` is missing
2. unpack it into `./buildroot`
3. load `myfw_x86_64_rauc_defconfig`
4. build the firmware artifacts into `output/images/`

Typical outputs are:

```text
output/images/
├── bzImage
├── rootfs.ext4
├── myfw.img
└── update-1.0.1.raucb
```

## Provisioning

Flash the initial image once:

```bash
sudo dd if=output/images/myfw.img of=/dev/sdX bs=4M status=progress oflag=sync
sync
```

## NetForge

The image now includes `NetForge v1.0.2` and starts it automatically at boot.

Runtime configuration lives in:

- `/etc/default/netforge`
- `/data/etc/default/netforge`
- `/etc/default/mgmt-network`
- `/data/etc/default/mgmt-network`
- `/etc/netforge/namespaces.json.example`
- `/data/netforge/namespaces.json`

`/etc/default/netforge` is the image default. If you want settings to survive
RAUC rootfs updates, put overrides in `/data/etc/default/netforge` and keep your
namespace JSON in `/data/netforge/namespaces.json`.

The image assumes a two-port appliance layout. By default, the first NIC is
left for host management traffic and NetForge uses `PARENT_NIC=enp0s4`. Override
that in `/data/etc/default/netforge` if your hardware exposes a different
predictable NIC name. If no namespace JSON exists, NetForge falls back to its
built-in demo namespaces.

The management NIC is brought up earlier in boot with DHCP. By default, it uses
the first NIC that is not reserved for NetForge. Override that selection in
`/data/etc/default/mgmt-network`.

## Updating

Copy a bundle to the device and install it:

```bash
rauc install /data/update-1.0.1.raucb
reboot
```

## Useful targets

```bash
make           # bootstrap Buildroot if missing, then build
make menuconfig
make bundle VERSION=1.0.1
make show
make clean
make distclean
make realclean
```

## Troubleshooting

If you see an error like this:

```text
make[1]: *** /path/to/repo/buildroot: No such file or directory. Stop.
```

then your current `Makefile` does not yet include the bootstrap logic, or the repo contents are older than this README. In that case, update the top-level `Makefile` so it downloads and extracts Buildroot before calling `make -C ./buildroot`.
