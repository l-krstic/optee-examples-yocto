UPSTREAM_CHECK_GITTAGREGEX = "^(?P<pver>\d+(\.\d+)+)$"

COMPATIBLE_MACHINE ?= "invalid"
COMPATIBLE_MACHINE_qemuarm64 ?= "qemuarm64"
# Please add supported machines below or set it in .bbappend or .conf

OPTEEMACHINE ?= "${MACHINE}"
OPTEEMACHINE_aarch64_qemuall ?= "vexpress-qemu_armv8a"

OPTEE_ARCH = "null"
OPTEE_ARCH_armv7a = "arm32"
OPTEE_ARCH_aarch64 = "arm64"
OPTEE_CORE = "${@d.getVar('OPTEE_ARCH').upper()}"

OPTEE_TOOLCHAIN = "${@d.getVar('TOOLCHAIN') or 'gcc'}"
OPTEE_COMPILER = "${@bb.utils.contains("BBFILE_COLLECTIONS", "clang-layer", "${OPTEE_TOOLCHAIN}", "gcc", d)}"

# Set here but not passed to EXTRA_OEMAKE by default as that breaks
# the optee-os build
TA_DEV_KIT_DIR = "${STAGING_INCDIR}/optee/export-user_ta_arm64"

EXTRA_OEMAKE += " \
	V=1 \
	LIBGCC_LOCATE_CFLAGS=--sysroot=${STAGING_DIR_HOST} \
	COMPILER=${OPTEE_COMPILER} \
	OPTEE_CLIENT_EXPORT=${STAGING_DIR_HOST}${prefix} \
	TEEC_EXPORT=${STAGING_DIR_HOST}${prefix} \
"
