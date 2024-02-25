inherit externalsrc

EXTERNALSRC = "/home/lukak/Projects/MSc/optee_examples_external_src"
EXTERNALSRC_BUILD = "${EXTERNALSRC}"

do_compile() {
    export CFLAGS="${CFLAGS} --sysroot=${STAGING_DIR_HOST}"
    oe_runmake -C ${S}
}
do_compile[cleandirs] = "${B}"

do_install () {
    mkdir -p ${D}${nonarch_base_libdir}/optee_armtz
    mkdir -p ${D}${bindir}
    install -D -p -m0755 ${B}/ca/* ${D}${bindir}
    install -D -p -m0444 ${B}/ta/* ${D}${nonarch_base_libdir}/optee_armtz
}
