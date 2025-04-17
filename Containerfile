# Query kernel version for building kmod
FROM ghcr.io/ublue-os/kinoite-main:41 as kernel-query

# BUILD NVIDIA KMOD

# Export kernel version to file for use in later stages
# See https://github.com/coreos/layering-examples/blob/main/build-zfs-module/Containerfile for another example
RUN rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' > /kernel-version.txt && \
    echo "Detected kernel version: $(cat /kernel-version.txt)"

FROM fedora:41 as nvidia-base

COPY build-kmod-nvidia.sh /tmp/build-kmod-nvidia.sh
COPY certs /tmp/certs
COPY --from=kernel-query /kernel-version.txt /kernel-version.txt

RUN /tmp/build-kmod-nvidia.sh

# Build system image
FROM ghcr.io/ublue-os/kinoite-main:41

# Copy kernel version from kernel-query stage
COPY --from=kernel-query /kernel-version.txt /kernel-version.txt

# See https://pagure.io/releng/issue/11047 for final location
# Copy kmod rpm from previous stage
COPY --from=nvidia-base /var/cache/akmods/nvidia-470xx /tmp/nvidia

# END OF BUILD NVIDIA KMOD

### 3. MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

COPY build.sh /tmp/build.sh

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
## NOTES:
# - /var/lib/alternatives is required to prevent failure with some RPM installs
# - All RUN commands must end with ostree container commit
#   see: https://coreos.github.io/rpm-ostree/container/#using-ostree-container-commit
