#!/bin/bash
set -e
echo "----------------------------------------"
echo "[*] 1. Aşama: Dosyalar Linux ortamına taşınıyor (İzin hatalarını önlemek için)..."
rm -rf ~/talkos-build-env
mkdir -p ~/talkos-build-env

# Kopyalama
cp -a "$(wslpath -a 'C:\Users\ahmet\Downloads\talkos')/talkos-build" "$(wslpath -a 'C:\Users\ahmet\Downloads\talkos')/build.sh" ~/talkos-build-env/
cd ~/talkos-build-env

echo "----------------------------------------"
echo "[*] 2. Aşama: ISO Derleme yetkisi için Linux şifreniz istenebilir:"
sudo bash ./build.sh

echo "----------------------------------------"
echo "[*] 3. Aşama: ISO dosyası tekrar Windows klasörüne alınıyor..."
if [ -f *.iso ]; then
    cp *.iso "$(wslpath -a 'C:\Users\ahmet\Downloads\talkos')/"
    chmod 777 "$(wslpath -a 'C:\Users\ahmet\Downloads\talkos')/"*.iso 2>/dev/null || true
    echo "[+] BAŞARILI: ISO dosyanız Windows klasörünüze çıkarıldı!"
else
    echo "[-] BAŞARISIZ: .iso dosyası oluşturulamadı. Logları kontrol edin."
fi
