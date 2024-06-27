## 1. BUILD ARGS
# These allow changing the produced image by passing different build args to adjust
# the source from which your image is built.
# Build args can be provided on the commandline when building locally with:
#   podman build -f Containerfile --build-arg FEDORA_VERSION=40 -t local-image

# SOURCE_IMAGE arg can be anything from ublue upstream which matches your desired version:
# See list here: https://github.com/orgs/ublue-os/packages?repo_name=main
# - "silverblue"
# - "kinoite"
# - "sericea"
# - "onyx"
# - "lazurite"
# - "vauxite"
# - "base"
#
#  "aurora", "bazzite", "bluefin" or "ucore" may also be used but have different suffixes.
ARG SOURCE_IMAGE="kinoite"

## SOURCE_SUFFIX arg should include a hyphen and the appropriate suffix name
# These examples all work for silverblue/kinoite/sericea/onyx/lazurite/vauxite/base
# - "-main"
# - "-nvidia"
# - "-asus"
# - "-asus-nvidia"
# - "-surface"
# - "-surface-nvidia"
#
# aurora, bazzite and bluefin each have unique suffixes. Please check the specific image.
# ucore has the following possible suffixes
# - stable
# - stable-nvidia
# - stable-zfs
# - stable-nvidia-zfs
# - (and the above with testing rather than stable)
ARG SOURCE_SUFFIX="-main"

## SOURCE_TAG arg must be a version built for the specific image: eg, 39, 40, gts, latest
ARG SOURCE_TAG="40"


### 2. SOURCE IMAGE
## this is a standard Containerfile FROM using the build ARGs above to select the right upstream image
FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG} as kernel-query

# BUILD NVIDIA KMOD

# Export kernel version to file for use in later stages
# See https://github.com/coreos/layering-examples/blob/main/build-zfs-module/Containerfile for another example
RUN rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' > /kernel-version.txt && \
    echo "Detected kernel version: $(cat /kernel-version.txt)"

FROM fedora:40 as nvidia-base
ARG RPMFUSION_FREE="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-40.noarch.rpm"
ARG RPMFUSION_NON_FREE="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-40.noarch.rpm"

# Copy kernel version from kernel-query stage
COPY --from=kernel-query /kernel-version.txt /kernel-version.txt

RUN KERNEL_VERSION=$(cat /kernel-version.txt) && \
    dnf install -y $RPMFUSION_FREE $RPMFUSION_NON_FREE fedora-repos-archive && \
    dnf install -y mock xorg-x11-drv-nvidia-470xx{,-cuda} binutils kernel-devel-$KERNEL_VERSION kernel-$KERNEL_VERSION && \
    akmods --force

FROM ghcr.io/ublue-os/${SOURCE_IMAGE}${SOURCE_SUFFIX}:${SOURCE_TAG}

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
