# faculty-master
MSc thesis repo

&middot; Project is being developped on Varisicte's SOM, powered by
the i.MX8M Mini. 

&middot; Yocto version is Hardknott 5.10.72.

&middot; Required changes in conf/local.conf are:

```text
TEE_CFG_DDR_SIZE = "0x80000000"
DISTRO_FEATURES_append += " systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"
VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"
MACHINE_FEATURES:append = " optee"
DISTRO_FEATURES:append = " optee"
IMAGE_INSTALL:append = " \
        optee-os \
        optee-client \
        optee-test \
        optee-examples \
"
```

&middot; After creating your own layer, add it in conf/bblayers.conf,
and copy all files from meta-master/

&middot; This layer contains .bbappend file for optee-os, together with patch
that bypass python module errors in script sign_encrypt.py.

&middot; Also, this layer contains optee-examples recipe, and files required to
build it. This recipe also requires a patch, that passes ldflags during
linking phase.

**optee-examples_3.11.0.bb** with **optee-examples.inc** is recipe that builds
examples from git.

**optee.inc** is used for setting up build system of optee-examples.

**optee-examples_%.bbappend** is used when someone wants to build application,
beside those on git.

&middot; Update path to external sources, according to your system, in file
**optee-examples_%.bbappend** !

**IMPORTANT** When building examples, ther are signed using:
```text
optee-os/keys/default_ta.pem
```
**NEVER DEPLOY an optee_os binary with this key in production. Instead, REPLACE 
this key as soon as possible with a public key and keep the private part of 
the key offline, preferably on an HSM.**
