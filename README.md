# TalkOS

TalkOS, Debian 12 (Bookworm) tabanlı, hafif ve geliştirici dostu bir Türk Linux dağıtımıdır.

## ISO Otomatik Derleme (GitHub Actions)

ISO dosyasını oluşturmak için GitHub'a yüklemeniz yeterli — geri kalanını bulut sunucusu halleder!

### Adımlar

1. [github.com](https://github.com) adresinden ücretsiz hesap oluşturun.
2. Yeni bir "repository" (depo) oluşturun, adını `talkos` koyun.
3. Bu klasördeki tüm dosyaları o depoya yükleyin (GitHub Desktop veya `git push` ile).
4. Yükleme tamamlandığında **Actions** sekmesine tıklayın.
5. **"TalkOS ISO Build"** iş akışını bulun ve **"Run workflow"** butonuna tıklayın.
6. 20-30 dakika bekleyin, ISO hazır olduğunda **Artifacts** bölümünden `TalkOS-ISO` dosyasını indirin!

## Proje Yapısı

```
talkos/
├── .github/workflows/build-iso.yml   # ISO build otomasyonu
├── talkos-build/
│   ├── auto/config                   # Debian live-build ayarları
│   ├── auto/build
│   ├── auto/clean
│   └── config/
│       ├── package-lists/            # Yüklenecek paketler
│       ├── hooks/normal/             # Sistem kurulum scriptler
│       └── includes.chroot/          # ISO içi dosyalar
│           ├── usr/local/bin/talkos-calculator
│           ├── usr/local/bin/talkos-store
│           └── etc/calamares/        # Kurulum sihirbazı
└── Build-TalkOS.ps1                  # WSL varsa Windows üzerinden build
```

## TalkOS Hakkında

- **Masaüstü:** XFCE (Özelleştirilmiş, koyu tema)
- **Dil:** Türkçe (Varsayılan)
- **Minimum RAM:** 2GB
- **Güvenlik:** UFW, AppArmor aktif
- **Geliştirici Araçları:** Git, GCC, Python3, VS Code

> **Slogan:** Hızlı. Özgür. Geliştirici Odaklı.
