# GitHub'a Yükle ve ISO Derlet - TalkOS
# Bu scripti çalıştırarak projeyi GitHub'a yükleyin ve ISO otomatik derlensin

Write-Host "========================================"
Write-Host "  TalkOS -> GitHub Yükleyici"
Write-Host "========================================"

# Git kurulu mu?
try { git --version | Out-Null } catch {
    Write-Host "[!] Git bulunamadı! https://git-scm.com/download/win adresinden yükleyip tekrar deneyin."
    Read-Host "Çıkmak için Enter'a basın..."
    exit
}

$RepoUrl = Read-Host "GitHub repo URL'nizi girin (örnek: https://github.com/kullaniciadi/talkos.git)"
if ([string]::IsNullOrWhiteSpace($RepoUrl)) {
    Write-Host "[!] URL boş bırakılamaz."
    Read-Host "Çıkmak için Enter'a basın..."
    exit
}

# Git kimliği ayarla
$GitName  = Read-Host "Adınızı girin (örnek: Ahmet Yilmaz)"
$GitEmail = Read-Host "E-posta adresinizi girin (örnek: ahmet@gmail.com)"
Write-Host "[*] Git kimliği ayarlanıyor..."
git config --global user.name  "$GitName"
git config --global user.email "$GitEmail"

Write-Host "[*] Git deposu başlatılıyor..."
git init
Write-Host "[*] Dosyalar ekleniyor..."
git add -A
Write-Host "[*] Commit oluşturuluyor..."
git commit -m "TalkOS v1.0 - initial commit"
if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Commit başarısız! Yukarıdaki hataları inceleyin."
    Read-Host "Çıkmak için Enter'a basın..."
    exit
}

git remote remove origin 2>$null
git remote add origin $RepoUrl
git branch -M main
Write-Host "[*] GitHub'a yükleniyor (kullanıcı adı ve Personal Access Token isteyecektir)..."
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[+] BAŞARILI! Proje GitHub'a yüklendi."
    Write-Host "    Şimdi GitHub reponuza gidin: $RepoUrl"
    Write-Host "    'Actions' sekmesine tıklayın."
    Write-Host "    'TalkOS ISO Build' > 'Run workflow' butonuna basın."
    Write-Host "    ~20-30 dk sonra 'Artifacts' altında .iso dosyanız hazır olacak!"
} else {
    Write-Host ""
    Write-Host "[!] Yükleme başarısız! GitHub Personal Access Token gerekiyor olabilir."
    Write-Host "    GitHub > Settings > Developer settings > Personal access tokens > Generate new token"
    Write-Host "    Şifre yerine bu token'i girin."
}

Read-Host "Çıkmak için Enter'a basın..."
