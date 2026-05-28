#!/bin/bash
set -e

echo "=== Yeaaaaaaaa OS Build Script ==="
echo "Running inside Fedora container..."

# Install build tools
dnf install -y \
    livecd-tools \
    spin-kickstarts \
    pykickstart \
    lorax \
    squashfs-tools \
    xorriso \
    syslinux \
    grub2-tools \
    grub2-efi-x64 \
    shim-x64 \
    curl \
    wget

# Navigate to workspace
cd /workspace

# Flatten kickstart (resolve %include directives)
ksflatten -c kickstart/yeaaaaaaaa.ks -o /tmp/flat-yeaaaaaaaa.ks 2>/dev/null || \
    cp kickstart/yeaaaaaaaa.ks /tmp/flat-yeaaaaaaaa.ks

echo "=== Starting ISO build ==="

# Build the live ISO
livecd-creator \
    --verbose \
    --config=/tmp/flat-yeaaaaaaaa.ks \
    --fslabel="Yeaaaaaaaa" \
    --cache=/var/cache/live \
    --tmpdir=/var/tmp

# Move result
mkdir -p /workspace/output
mv /var/tmp/Yeaaaaaaaa*.iso /workspace/output/ 2>/dev/null || \
    mv Yeaaaaaaaa*.iso /workspace/output/ 2>/dev/null || \
    find / -name "*.iso" -size +100M -exec mv {} /workspace/output/ \; 2>/dev/null

# Also copy to workspace root for artifact upload
cp /workspace/output/*.iso /workspace/ 2>/dev/null || true

echo "=== Build complete ==="
ls -lh /workspace/output/
