#!/bin/bash
set -e

echo "=== Yeaaaaaaaa OS Build Script ==="
echo "Running inside Fedora container..."

# Install build tools
dnf install -y \
    livecd-tools \
    pykickstart \
    squashfs-tools \
    xorriso \
    syslinux \
    syslinux-nonlinux \
    grub2-tools \
    grub2-tools-extra \
    grub2-efi-x64 \
    shim-x64 \
    curl \
    wget

echo "=== Build tools installed ==="

cd /workspace

# Flatten kickstart
ksflatten -c kickstart/yeaaaaaaaa.ks -o /tmp/flat-yeaaaaaaaa.ks 2>/dev/null || \
    cp kickstart/yeaaaaaaaa.ks /tmp/flat-yeaaaaaaaa.ks

echo "=== Starting ISO build ==="

mkdir -p /var/cache/live
mkdir -p /workspace/output

# Build the live ISO
livecd-creator \
    --verbose \
    --config=/tmp/flat-yeaaaaaaaa.ks \
    --fslabel="Yeaaaaaaaa" \
    --cache=/var/cache/live

echo "=== livecd-creator finished ==="

# Move ISO to output
mv Yeaaaaaaaa*.iso /workspace/output/ 2>/dev/null || \
    find / -maxdepth 3 -name "*.iso" -size +50M -exec mv {} /workspace/output/ \; 2>/dev/null

cp /workspace/output/*.iso /workspace/ 2>/dev/null || true

echo "=== Build complete ==="
ls -lh /workspace/output/
