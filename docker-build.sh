#!/bin/bash
# =============================================
#  TalkOS ISO Builder - WSL/Docker/Linux icin
#  Bu script root yetkisiyle calistirilmalidir
# =============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/talkos-build"
OUTPUT_ISO="${SCRIPT_DIR}/TalkOS-amd64-bookworm.iso"

echo "============================================"
echo "  TalkOS ISO Builder"
echo "  Build dizini: ${BUILD_DIR}"
echo "============================================"
echo ""

# Root kontrolu
if [ "$(id -u)" -ne 0 ]; then
    echo "[-] Bu script root yetkisiyle calistirilmali!"
    echo "    sudo bash $0"
    exit 1
fi

# ==========================================
# 1. BAGIMLILIKLARI KUR
# ==========================================
echo "[1/5] Paket bagimliliklari kuruluyor..."
apt-get update -qq

# live-build ve diger araclari kur
apt-get install -y -qq \
    debootstrap squashfs-tools xorriso curl gnupg git gettext \
    cpio genisoimage syslinux syslinux-common isolinux \
    dosfstools mtools grub-pc-bin grub-efi-amd64-bin \
    debian-archive-keyring dos2unix

# live-build'i Debian'dan kur (Ubuntu'daki eski olabilir)
if ! command -v lb &>/dev/null || ! lb --version 2>/dev/null | grep -q "2025"; then
    echo "[*] Guncel live-build kuruluyor..."
    apt-get remove -y live-build 2>/dev/null || true
    if [ -d /tmp/live-build ]; then
        rm -rf /tmp/live-build
    fi
    git clone --depth=1 https://salsa.debian.org/live-team/live-build.git /tmp/live-build
    cd /tmp/live-build
    make install
    cd "${SCRIPT_DIR}"
    echo "[+] live-build kuruldu"
fi

# ==========================================
# 2. DEBIAN KEYRING KONTROLU
# ==========================================
echo "[2/5] Debian archive keyring kontrol ediliyor..."
if [ ! -f /usr/share/keyrings/debian-archive-keyring.gpg ]; then
    echo "[*] Keyring bulunamadi, Debian'dan indiriliyor..."
    curl -sL -o /tmp/debian-archive-keyring.deb \
        "http://deb.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2023.4_all.deb"
    dpkg -i /tmp/debian-archive-keyring.deb || apt-get install -f -y
fi
echo "[+] Keyring: $(ls -la /usr/share/keyrings/debian-archive-keyring.gpg)"

# ==========================================
# 3. DOSYA HAZIRLIGI
# ==========================================
echo "[3/5] Build dosyalari hazirlaniyor..."

# CRLF -> LF donusumu (Windows'tan gelen dosyalar icin)
find "${BUILD_DIR}" -type f \( \
    -name "*.chroot" -o -name "*.binary" -o -name "*.sh" -o \
    -name "*.list.*" -o -path "*/auto/*" \
\) -exec dos2unix {} \; 2>/dev/null || true

# auto script'lere calisma izni ver
chmod +x "${BUILD_DIR}/auto/"*

# hook'lara calisma izni ver
find "${BUILD_DIR}/config/hooks" -type f -name "*.chroot" -exec chmod +x {} \;
find "${BUILD_DIR}/config/hooks" -type f -name "*.binary" -exec chmod +x {} \;

# custom binary'lere calisma izni ver
find "${BUILD_DIR}/config/includes.chroot" -path "*/bin/*" -type f -exec chmod +x {} \;

echo "[+] Dosyalar hazir"

# ==========================================
# 4. BUILD
# ==========================================
echo "[4/5] ISO build baslatiliyor..."
echo "       Bu islem 30-60 dakika surebilir..."
echo ""

cd "${BUILD_DIR}"

# Onceki build varsa temizle
lb clean --purge 2>/dev/null || true

# lb config calistir
echo "[*] lb config calistiriliyor..."
lb config
echo "[+] lb config tamamlandi"

# lb build calistir
echo "[*] lb build calistiriliyor..."
lb build 2>&1 | tee build.log

echo "[+] lb build tamamlandi"

# ==========================================
# 5. ISO KONTROL
# ==========================================
echo "[5/5] ISO dosyasi kontrol ediliyor..."

# ISO dosyasini bul
ISO_FILE=$(find "${BUILD_DIR}" -maxdepth 1 -name "*.iso" 2>/dev/null | head -1)

if [ -n "${ISO_FILE}" ]; then
    mv "${ISO_FILE}" "${OUTPUT_ISO}"
    ISO_SIZE=$(du -h "${OUTPUT_ISO}" | cut -f1)
    echo ""
    echo "============================================"
    echo "  ✅ BASARILI!"
    echo "  ISO: ${OUTPUT_ISO}"
    echo "  Boyut: ${ISO_SIZE}"
    echo "============================================"
    exit 0
else
    echo ""
    echo "============================================"
    echo "  ❌ HATA: ISO dosyasi olusturulamadi!"
    echo "  Son 50 satir build log:"
    echo "============================================"
    tail -50 "${BUILD_DIR}/build.log" 2>/dev/null || echo "Log bulunamadi"
    exit 1
fi
