FROM registry.fedoraproject.org/fedora:44

RUN dnf install -y --setopt=install_weak_deps=False guestfs-tools
RUN rpm -q libguestfs guestfs-tools

# Docker blocks the user namespace passt requires. Disable it so
# libguestfs uses QEMU SLIRP networking instead.
RUN chmod a-x /usr/bin/passt
ENV LIBGUESTFS_BACKEND=direct
RUN dnf install -y  wget 
RUN dnf install -y e2fsprogs 
RUN dnf install -y curl
RUN dnf install -y qemu-img
