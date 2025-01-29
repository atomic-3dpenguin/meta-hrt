DESCRIPTION = "hrt Default Build Configuration Setup"
LICENSE = "MIT"
PR = "r1"

SRC_URI = "file://bblayers.conf.sample \\
           file://local.conf.sample"

S = "\${WORKDIR}"

do_install() {
    install -d ${D}conf
    install -m 0644 \${S}/bblayers.conf.sample ${D}conf/bblayers.conf
    install -m 0644 \${S}/local.conf.sample ${D}conf/local.conf
}

FILES_${PN} = "conf"