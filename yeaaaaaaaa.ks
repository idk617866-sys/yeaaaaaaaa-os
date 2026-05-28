# Yeaaaaaaaa OS - Fedora-based KDE Plasma Custom Distribution
# Kickstart configuration file

#--------------------------------------
# INSTALLATION SOURCE
#--------------------------------------
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-39&arch=x86_64
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f39&arch=x86_64

#--------------------------------------
# SYSTEM CONFIGURATION
#--------------------------------------
lang en_US.UTF-8
keyboard us
timezone UTC
selinux --enforcing
firewall --enabled --service=mdns
network --bootproto=dhcp --device=link --activate
rootpw --lock
shutdown

#--------------------------------------
# BOOTLOADER
#--------------------------------------
bootloader --location=none

#--------------------------------------
# DISK (for live image)
#--------------------------------------
zerombr
clearpart --all
part / --size 8192 --fstype ext4

#--------------------------------------
# PACKAGES
#--------------------------------------
%packages
# === KDE Plasma Desktop ===
@kde-desktop
@base-x
@fonts
@hardware-support
@multimedia
@networkmanager-submodules
@printing

# === KDE Core ===
plasma-desktop
plasma-workspace
plasma-nm
plasma-pa
kde-settings
kde-settings-plasma

# === KDE Applications ===
dolphin
konsole
kate
gwenview
okular
ark
spectacle
kcalc
kwrite

# === System Tools ===
firefox
thunderbird
libreoffice-writer
libreoffice-calc
libreoffice-impress
gimp
htop
neofetch
git
curl
wget

# === Theming ===
papirus-icon-theme
breeze-gtk
plymouth-theme-spinner

# === Firmware & Drivers ===
linux-firmware
mesa-dri-drivers
 # xorg-x11-drv-libinput

# === Live image tools ===
dracut-live
grub2-efi-x64
grub2-tools
shim-x64
syslinux

# === Remove unwanted ===
-@dial-up
-@input-methods
-gfs2-utils
-reiserfs-utils

%end

#--------------------------------------
# POST-INSTALL CUSTOMIZATION
#--------------------------------------
%post

echo "=== Yeaaaaaaaa OS Post-Install Customization ==="

# ----- Create Yeaaaaaaaa branding directory -----
mkdir -p /usr/share/yeaaaaaaaa
mkdir -p /usr/share/wallpapers/Yeaaaaaaaa/contents/images
mkdir -p /usr/share/icons/yeaaaaaaaa-start
mkdir -p /usr/share/plymouth/themes/yeaaaaaaaa

# ----- Custom Wallpaper -----
# Generate a branded wallpaper (gradient with text)
cat > /tmp/create-wallpaper.py << 'PYEOF'
try:
    from PIL import Image, ImageDraw, ImageFont
    img = Image.new('RGB', (3840, 2160))
    draw = ImageDraw.Draw(img)
    # Dark purple-to-blue gradient
    for y in range(2160):
        r = int(20 + (y/2160) * 15)
        g = int(10 + (y/2160) * 20)
        b = int(40 + (y/2160) * 80)
        draw.line([(0, y), (3840, y)], fill=(r, g, b))
    # Add branding text
    try:
        font = ImageFont.truetype("/usr/share/fonts/google-noto/NotoSans-Bold.ttf", 120)
    except:
        font = ImageFont.load_default()
    draw.text((3840//2 - 400, 2160//2 - 60), "Yeaaaaaaaa", fill=(255, 255, 255), font=font)
    draw.text((3840//2 - 200, 2160//2 + 80), "OS", fill=(200, 200, 255), font=font)
    img.save('/usr/share/wallpapers/Yeaaaaaaaa/contents/images/3840x2160.png')
    img.resize((1920, 1080)).save('/usr/share/wallpapers/Yeaaaaaaaa/contents/images/1920x1080.png')
    print("Wallpaper created successfully")
except Exception as e:
    print(f"PIL not available, creating fallback: {e}")
    import subprocess
    # Fallback: use ImageMagick if available
    subprocess.run(['convert', '-size', '3840x2160',
        'gradient:#1a0a28-#1e1e5f', '-gravity', 'center',
        '-pointsize', '120', '-fill', 'white',
        '-annotate', '+0-40', 'Yeaaaaaaaa',
        '-pointsize', '80', '-fill', '#c8c8ff',
        '-annotate', '+0+80', 'OS',
        '/usr/share/wallpapers/Yeaaaaaaaa/contents/images/3840x2160.png'], check=False)
    subprocess.run(['convert',
        '/usr/share/wallpapers/Yeaaaaaaaa/contents/images/3840x2160.png',
        '-resize', '1920x1080',
        '/usr/share/wallpapers/Yeaaaaaaaa/contents/images/1920x1080.png'], check=False)
PYEOF

dnf install -y python3-pillow ImageMagick 2>/dev/null || true
python3 /tmp/create-wallpaper.py || true

# Wallpaper metadata
cat > /usr/share/wallpapers/Yeaaaaaaaa/metadata.json << 'EOF'
{
    "KPlugin": {
        "Id": "Yeaaaaaaaa",
        "Name": "Yeaaaaaaaa OS Default",
        "Authors": [{ "Name": "Yeaaaaaaaa Team" }]
    }
}
EOF

# ----- Custom Start Menu Icon (Application Launcher) -----
# Create a custom SVG icon for the start menu
cat > /usr/share/icons/yeaaaaaaaa-start/yeaaaaaaaa-logo.svg << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#6c3fa0;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#2196f3;stop-opacity:1" />
    </linearGradient>
  </defs>
  <circle cx="24" cy="24" r="22" fill="url(#bg)" stroke="#fff" stroke-width="1"/>
  <text x="24" y="20" text-anchor="middle" font-family="sans-serif" font-size="7" font-weight="bold" fill="#ffffff">Yeaaa</text>
  <text x="24" y="30" text-anchor="middle" font-family="sans-serif" font-size="7" font-weight="bold" fill="#ffffff">aaaaa</text>
  <text x="24" y="40" text-anchor="middle" font-family="sans-serif" font-size="5" fill="#c8c8ff">OS</text>
</svg>
EOF

# Install the icon in hicolor theme
mkdir -p /usr/share/icons/hicolor/scalable/apps
cp /usr/share/icons/yeaaaaaaaa-start/yeaaaaaaaa-logo.svg /usr/share/icons/hicolor/scalable/apps/yeaaaaaaaa-start.svg

# Also create PNG versions
dnf install -y librsvg2-tools 2>/dev/null || true
for size in 16 22 24 32 48 64 128 256; do
    mkdir -p /usr/share/icons/hicolor/${size}x${size}/apps
    rsvg-convert -w $size -h $size \
        /usr/share/icons/yeaaaaaaaa-start/yeaaaaaaaa-logo.svg \
        -o /usr/share/icons/hicolor/${size}x${size}/apps/yeaaaaaaaa-start.png 2>/dev/null || true
done

# ----- SDDM Theme -----
mkdir -p /usr/share/sddm/themes/yeaaaaaaaa
cat > /usr/share/sddm/themes/yeaaaaaaaa/theme.conf << 'EOF'
[General]
background=/usr/share/wallpapers/Yeaaaaaaaa/contents/images/1920x1080.png
type=image
color=#1a0a28
fontSize=12
EOF

cat > /usr/share/sddm/themes/yeaaaaaaaa/metadata.desktop << 'EOF'
[SddmGreeterTheme]
Name=Yeaaaaaaaa
Description=Yeaaaaaaaa OS Login Theme
Author=Yeaaaaaaaa Team
Version=1.0
Website=https://github.com/user/yeaaaaaaaa-os
Theme-Id=yeaaaaaaaa
EOF

# Create a minimal Main.qml for SDDM
cat > /usr/share/sddm/themes/yeaaaaaaaa/Main.qml << 'QMLEOF'
import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080

    Image {
        anchors.fill: parent
        source: "file:///usr/share/wallpapers/Yeaaaaaaaa/contents/images/1920x1080.png"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.centerIn: parent
        width: 400
        height: 300
        color: "#80000000"
        radius: 12

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                text: "Yeaaaaaaaa OS"
                color: "white"
                font.pixelSize: 28
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextInput {
                id: userField
                width: 250
                height: 36
                color: "white"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    anchors.fill: parent
                    color: "#40ffffff"
                    radius: 6
                    z: -1
                }
            }

            TextInput {
                id: passField
                width: 250
                height: 36
                color: "white"
                echoMode: TextInput.Password
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                Rectangle {
                    anchors.fill: parent
                    color: "#40ffffff"
                    radius: 6
                    z: -1
                }
            }

            Rectangle {
                width: 120
                height: 36
                color: "#6c3fa0"
                radius: 6
                anchors.horizontalCenter: parent.horizontalCenter
                Text {
                    anchors.centerIn: parent
                    text: "Login"
                    color: "white"
                    font.pixelSize: 14
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: sddm.login(userField.text, passField.text, 0)
                }
            }
        }
    }
}
QMLEOF

# Configure SDDM to use our theme
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/yeaaaaaaaa.conf << 'EOF'
[Theme]
Current=yeaaaaaaaa

[General]
InputMethod=
EOF

# ----- GRUB Theme -----
mkdir -p /boot/grub2/themes/yeaaaaaaaa
cat > /boot/grub2/themes/yeaaaaaaaa/theme.txt << 'EOF'
# Yeaaaaaaaa OS GRUB Theme
title-text: "Yeaaaaaaaa OS"
title-color: "#ffffff"
title-font: "DejaVu Sans Bold 24"
desktop-color: "#1a0a28"
message-color: "#c8c8ff"
message-bg-color: "#000000"
terminal-font: "DejaVu Sans 12"

+ boot_menu {
    left = 25%
    top = 25%
    width = 50%
    height = 50%
    item_color = "#cccccc"
    selected_item_color = "#ffffff"
    item_height = 36
    item_padding = 12
    item_spacing = 4
    selected_item_pixmap_style = "select_*.png"
}

+ label {
    left = 50%-100
    top = 90%
    width = 200
    text = "Yeaaaaaaaa OS"
    color = "#c8c8ff"
    align = "center"
}
EOF

# Set GRUB theme in config
cat > /etc/default/grub << 'EOF'
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Yeaaaaaaaa OS"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="gfxterm"
GRUB_CMDLINE_LINUX=""
GRUB_DISABLE_RECOVERY="true"
GRUB_THEME="/boot/grub2/themes/yeaaaaaaaa/theme.txt"
GRUB_GFXMODE=1920x1080
EOF

# ----- Plymouth Boot Splash -----
cat > /usr/share/plymouth/themes/yeaaaaaaaa/yeaaaaaaaa.plymouth << 'EOF'
[Plymouth Theme]
Name=Yeaaaaaaaa
Description=Yeaaaaaaaa OS Boot Splash
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/yeaaaaaaaa
ScriptFile=/usr/share/plymouth/themes/yeaaaaaaaa/yeaaaaaaaa.script
EOF

cat > /usr/share/plymouth/themes/yeaaaaaaaa/yeaaaaaaaa.script << 'EOF'
Window.SetBackgroundTopColor(0.10, 0.04, 0.16);
Window.SetBackgroundBottomColor(0.12, 0.12, 0.37);

logo.image = Image("logo.png");
logo.sprite = Sprite(logo.image);
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);
logo.sprite.SetOpacity(1);
EOF

# Copy logo for plymouth
cp /usr/share/icons/hicolor/256x256/apps/yeaaaaaaaa-start.png \
   /usr/share/plymouth/themes/yeaaaaaaaa/logo.png 2>/dev/null || true

# Set plymouth theme
plymouth-set-default-theme yeaaaaaaaa 2>/dev/null || true

# ----- KDE Plasma Configuration (Default for all users) -----
mkdir -p /etc/skel/.config
mkdir -p /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc.d
mkdir -p /etc/skel/.local/share/plasma/look-and-feel/yeaaaaaaaa

# Set default wallpaper
cat > /etc/skel/.config/plasmarc << 'EOF'
[Wallpapers]
usersWallpapers=/usr/share/wallpapers/Yeaaaaaaaa/contents/images/1920x1080.png
EOF

# KDE Global settings - dark theme with accent color
cat > /etc/skel/.config/kdeglobals << 'EOF'
[General]
ColorScheme=BreezeDark
Name=Breeze Dark
widgetStyle=kvantum

[Icons]
Theme=Papirus-Dark

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
SingleClick=false
AnimationDurationFactor=0.5
EOF

# Set the custom start icon in the panel
cat > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc << 'EOF'
[Containments][2][Applets][3]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][2][Applets][3][Configuration][General]
icon=yeaaaaaaaa-start
favoritesPortedToKAstats=true
EOF

# Kvantum theme config
mkdir -p /etc/skel/.config/Kvantum
cat > /etc/skel/.config/Kvantum/kvantum.kvconfig << 'EOF'
[General]
theme=KvArcDark
EOF

# ----- OS Branding -----
# Custom /etc/os-release
cat > /etc/os-release << 'EOF'
NAME="Yeaaaaaaaa OS"
VERSION="1.0 (Plasma)"
ID=yeaaaaaaaa
ID_LIKE=fedora
VERSION_ID=1.0
PRETTY_NAME="Yeaaaaaaaa OS 1.0"
ANSI_COLOR="0;35"
HOME_URL="https://github.com/user/yeaaaaaaaa-os"
BUG_REPORT_URL="https://github.com/user/yeaaaaaaaa-os/issues"
VARIANT="KDE Plasma"
VARIANT_ID=kde
EOF

# Custom issue banner
cat > /etc/issue << 'EOF'

  ██╗   ██╗███████╗ █████╗  █████╗  █████╗  █████╗  █████╗  █████╗  █████╗
  ╚██╗ ██╔╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗██╔══██╗
   ╚████╔╝ █████╗  ███████║███████║███████║███████║███████║███████║███████║
    ╚██╔╝  ██╔══╝  ██╔══██║██╔══██║██╔══██║██╔══██║██╔══██║██╔══██║██╔══██║
     ██║   ███████╗██║  ██║██║  ██║██║  ██║██║  ██║██║  ██║██║  ██║██║  ██║
     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
                                    OS v1.0

EOF

# ----- Neofetch custom config -----
mkdir -p /etc/skel/.config/neofetch
cat > /etc/skel/.config/neofetch/config.conf << 'EOF'
print_info() {
    info title
    info underline
    info "OS" distro
    info "Host" model
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "DE" de
    info "Theme" theme
    info "Icons" icons
    info "Terminal" term
    info "CPU" cpu
    info "GPU" gpu
    info "Memory" memory
    info cols
}
ascii_distro="auto"
EOF

# ----- Create live user for the live session -----
useradd -m -G wheel -s /bin/bash liveuser 2>/dev/null || true
echo "liveuser:" | chpasswd
echo "liveuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/liveuser

# Auto-login for live session
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf << 'EOF'
[Autologin]
User=liveuser
Session=plasma
EOF

# Copy skel to liveuser
cp -r /etc/skel/.config /home/liveuser/ 2>/dev/null || true
cp -r /etc/skel/.local /home/liveuser/ 2>/dev/null || true
chown -R liveuser:liveuser /home/liveuser

# ----- Enable services -----
systemctl enable sddm.service 2>/dev/null || true
systemctl enable NetworkManager.service 2>/dev/null || true
systemctl set-default graphical.target

# ----- Update icon cache -----
gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true

echo "=== Yeaaaaaaaa OS customization complete ==="

%end

#--------------------------------------
# POST (nochroot) - Live image specific
#--------------------------------------
%post --nochroot

# Copy the Anaconda installer desktop shortcut
if [ -f /usr/share/applications/liveinst.desktop ]; then
    cp /usr/share/applications/liveinst.desktop \
       $INSTALL_ROOT/home/liveuser/Desktop/ 2>/dev/null || true
fi

%end
