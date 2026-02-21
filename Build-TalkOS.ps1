# Build-TalkOS.ps1
Write-Host "========================================"
Write-Host " TalkOS ISO Derleme Asistanı (Windows) "
Write-Host "========================================"

try {
    $wslCmd = Get-Command "wsl.exe" -ErrorAction Stop
} catch {
    Write-Host "[!] HATA: WSL yüklü değil! Lütfen PowerShell'i Yönetici olarak açıp 'wsl --install -d Debian' komutunu çalıştırın ve yeniden başlatın."
    Read-Host "Çıkmak için Enter'a basın..."
    exit
}

wsl.exe -l -q 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] HATA: WSL var ama sisteminizde hiçbir Linux dağıtımı (Debian/Ubuntu) kurulu değil!"
    Write-Host "Lütfen PowerShell'i *YÖNETİCİ* (Administrator) olarak açıp şu komutu çalıştırın:"
    Write-Host "    wsl --install -d Debian"
    Write-Host "Bilgisayar yeniden başladıktan sonra tekrar bu dosyayı çalıştırın."
    Read-Host "Çıkmak için Enter'a basın..."
    exit
}

$ProjectDir = (Get-Item -Path ".\").FullName
$LinuxPath = "`$(wslpath -a '$ProjectDir')"
$InternalPath = "~/talkos-build-env"

Write-Host "[*] WSL algılandı. Windows NTFS diskinden Linux Ext4 ortamına taşıma ve derleme işlemi başlıyor..."
Write-Host "[!] DİKKAT: Bu işlem internet hızınıza ve bilgisayarınıza bağlı olarak 15-30 dk sürebilir."

$BashScript = @"
#!/bin/bash
set -e
echo "----------------------------------------"
echo "[*] 1. Aşama: Dosyalar Linux ortamına taşınıyor (İzin hatalarını önlemek için)..."
rm -rf $InternalPath
mkdir -p $InternalPath

# Kopyalama
cp -a "$LinuxPath/talkos-build" "$LinuxPath/build.sh" $InternalPath/
cd $InternalPath

echo "----------------------------------------"
echo "[*] 2. Aşama: ISO Derleme yetkisi için Linux şifreniz istenebilir:"
sudo bash ./build.sh

echo "----------------------------------------"
echo "[*] 3. Aşama: ISO dosyası tekrar Windows klasörüne alınıyor..."
if [ -f *.iso ]; then
    cp *.iso "$LinuxPath/"
    chmod 777 "$LinuxPath/"*.iso 2>/dev/null || true
    echo "[+] BAŞARILI: ISO dosyanız Windows klasörünüze çıkarıldı!"
else
    echo "[-] BAŞARISIZ: .iso dosyası oluşturulamadı. Logları kontrol edin."
fi
"@

Set-Content -Path ".\wsl-run.sh" -Value $BashScript
# Dosyanın satır sonlarını LF (\n) yapalım ki Linux bash hata vermesin
$text = [IO.File]::ReadAllText(".\wsl-run.sh")
$text = $text -replace "`r`n","`n"
[IO.File]::WriteAllText(".\wsl-run.sh", $text)

Write-Host ""
Write-Host ">>> WSL (LINUX) BASH SCRIPT'I ÇALIŞTIRILIYOR <<<"
wsl bash ./wsl-run.sh

Write-Host "----------------------------------------"
Read-Host "Çıkmak için Enter'a basın..."
