# Query kernel version for building kmod
FROM ghcr.io/ublue-os/kinoite-main:42 as kernel-query

# Export kernel version to file for use in later stages
# See https://github.com/coreos/layering-examples/blob/main/build-zfs-module/Containerfile for another example
RUN rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' > /kernel-version.txt && \
    echo "Detected kernel version: $(cat /kernel-version.txt)"

# BUILD VISTA-THEME-PLASMA

COPY compile-vistathemeplasma.sh /tmp/compile-vistathemeplasma.sh
COPY vistathemeplasma/compile-patched.sh /tmp/compile-patched.sh
RUN /tmp/compile-vistathemeplasma.sh

# BUILD NVIDIA KMOD

FROM fedora:42 as nvidia-base

COPY build-kmod-nvidia.sh /tmp/build-kmod-nvidia.sh
COPY certs /tmp/certs
COPY --from=kernel-query /kernel-version.txt /kernel-version.txt

RUN /tmp/build-kmod-nvidia.sh

# Build system image
FROM ghcr.io/ublue-os/kinoite-main:42

# Copy kernel version from kernel-query stage
COPY --from=kernel-query /kernel-version.txt /kernel-version.txt

# See https://pagure.io/releng/issue/11047 for final location
# Copy kmod rpm from previous stage
COPY --from=nvidia-base /var/cache/akmods/nvidia-470xx /tmp/nvidia
COPY --from=kernel-query /tmp/vistathemeplasma /tmp/vistathemeplasma
COPY --from=kernel-query /tmp/usr /tmp/vistathemeplasma/usr

# END OF BUILD NVIDIA KMOD

### 3. MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY build.sh /tmp/build.sh
COPY install-vistathemeplasma.sh /tmp/install-vistathemeplasma.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
