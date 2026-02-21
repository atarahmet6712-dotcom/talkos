#!/bin/bash
# TalkOS ISO Build Script
# Run this on a Debian/Ubuntu system as root

set -e

BUILD_DIR="talkos-build"

echo "====================================="
echo "  TalkOS (Debian 12) ISO Çıkarıcı    "
echo "====================================="

if [ "$EUID" -ne 0 ]; then
  echo "[-] Lütfen scripti root yetkisiyle çalıştırın (sudo ./build.sh)"
  exit 1
fi

echo "[*] Paket bağımlılıkları kontrol ediliyor..."
apt-get update -qq
apt-get install -y -qq live-build debootstrap squashfs-tools xorriso sudo curl gnupg

cd $BUILD_DIR

echo "[*] Eski build varsa temizleniyor..."
lb clean --purge || true

echo "[*] lb config çalıştırılıyor..."
lb config

echo "[*] lb build başlatılıyor..."
lb build 2>&1 | tee -a build.log

if [ -f live-image-amd64.hybrid.iso ]; then
    mv live-image-amd64.hybrid.iso ../TalkOS-amd64-bookworm.iso
    echo "[+] BAŞARILI: TalkOS-amd64-bookworm.iso oluşturuldu!"
else
    echo "[-] HATA: ISO dosyası oluşturulamadı."
    exit 1
fi
