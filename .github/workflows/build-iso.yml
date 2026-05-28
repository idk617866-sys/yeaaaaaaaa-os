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

# Navigate to workspace
cd /workspace

# Flatten kickstart (resolve %include directives)
ksflatten -c kickstart/yeaaaaaaaa.ks -o /tmp/flat-yeaaaaaaaa.ks 2>/dev/null || \
    cp kickstart/yeaaaaaaaa.ks /tmp/flat-yeaaaaaaaa.ks

echo "=== Kickstart flattened ==="
echo "=== Starting ISO build (this takes a while) ==="

# Create cache directory
mkdir -p /var/cache/live
mkdir -p /workspace/output

# Build the live ISO
# Using --tmpdir to control where temp files go
livecd-creator \
    --verbose \
    --config=/tmp/flat-yeaaaaaaaa.ks \
    --fslabel="Yeaaaaaaaa" \
    --cache=/var/cache/live

echo "=== livecd-creator finished ==="

# Find and move the ISO
find / -maxdepth 3 -name "*.iso" -size +50M 2>/dev/null | head -5
mv Yeaaaaaaaa*.iso /workspace/output/ 2>/dev/null || \
    mv /var/tmp/Yeaaaaaaaa*.iso /workspace/output/ 2>/dev/null || \
    mv livecd-*.iso /workspace/output/ 2>/dev/null || \
    find / -maxdepth 3 -name "*.iso" -size +50M -exec mv {} /workspace/output/ \; 2>/dev/null

# Copy to workspace root as well
cp /workspace/output/*.iso /workspace/ 2>/dev/null || true

echo "=== Build complete ==="
ls -lh /workspace/output/ 2>/dev/null || echo "Warning: no output found"
ls -lh /workspace/*.iso 2>/dev/null || echo "Warning: no ISO in workspace root"
