# Gentegre AI mockup — sunucuda yayınlama

Bu klasör, ekran tasarımlarını `46.36.201.170` sunucusunda yayınlamak için gereken
her şeyi içerir. SSH bağlantısını **sizin makineniz** kurar (bulut oturumunun
sunucuya erişimi yok), o yüzden aşağıdaki tek betiği çalıştırmanız gerekiyor.

## Klasör içeriği

| Dosya | Ne işe yarar |
|---|---|
| `gentegre-v4.tar.gz` | `yayinla.ps1` tarafından **her çalıştırmada yeniden üretilir**: web uygulaması (`index.html`), `gentegre_data.js`, `gengrid.js` ve `gentegre_data.js` içinde geçen ~108 ekran dosyası |
| `gentegre-mockup.tar.gz` | Eski paket (17.08.2026) — kullanılmıyor, arşiv |
| `kur.sh` | Sunucuda çalışan kurulum betiği — nginx kurar, dosyaları yerleştirir, parola korumasını açar |
| `yayinla.ps1` | Windows tarafı: paketi kopyalar ve `kur.sh`'ı sunucuda çalıştırır |
| `site/` | 17.08.2026 tarihli eski kopya — **kaynak değil**. Yayın artık doğrudan `Ekranlar\` klasöründen paketlenir |

## Yayınlama (tek adım)

`yayinla.ps1` dosyasına **sağ tık → "PowerShell ile çalıştır"**.

Ya da PowerShell'de:

```powershell
cd "C:\Users\HP\Entegra\Entegra\Ekranlar\_yayin"
powershell -ExecutionPolicy Bypass -File .\yayinla.ps1
```

Sunucu parolanız bir kez sorulur. Betik sırayla:

1. `gentegre-mockup.tar.gz` ve `kur.sh` dosyalarını sunucudaki ev dizinine kopyalar
2. Sunucuda `kur.sh`'ı çalıştırır

`kur.sh` sunucuda şunları yapar:

- `nginx` ve `apache2-utils` kurulu değilse kurar (`sudo` parolası istenebilir)
- Dosyaları `/var/www/gentegre-mockup` altına açar
- `.htpasswd` ile parola korumasını kurar
- 80 portundaki varsayılan nginx sitesini devre dışı bırakır
- `nginx -t` ile yapılandırmayı doğrular ve nginx'i yeniden yükler
- `ufw` aktifse 80 portunu açar

## Sonuç

| | |
|---|---|
| **Adres** | http://46.36.201.170/ |
| **Kullanıcı adı** | `gentegre` |
| **Parola** | `bEV6uIrKF2A7Gd` |

Bu adresi ve bilgileri paylaştığınız kişiler ekranları görebilir.
Parolayı değiştirmek isterseniz `kur.sh` içindeki `PAROLA=` satırını düzenleyip
betiği tekrar çalıştırın — ya da doğrudan sunucuda:

```bash
sudo htpasswd /etc/nginx/.htpasswd-gentegre gentegre
```

## Güncelleme

Ekranlarda değişiklik yaptığınızda paketi yeniden üretip aynı betiği çalıştırmanız
yeterli. Paketi yeniden üretmek için (Git Bash / WSL):

```bash
cd "/c/Users/HP/Entegra/Entegra/Ekranlar/_yayin"
rm -rf site && mkdir site
cp ../*.html ../*.js site/
cp index.html site/index.html
tar czf gentegre-mockup.tar.gz site
```

Sonra tekrar `yayinla.ps1`.

## Notlar

- Her sayfa tek dosya, dış bağımlılığı yok — sunucuda PHP/Node/veritabanı gerekmez.
- Açılış sayfası (`index.html`) ana uygulamaya ve öne çıkan ekranlara link verir;
  ziyaretçi `gentegre_v4_web.html` kabuğundan tüm modülleri gezebilir.
- Sayfalara `noindex, nofollow` etiketi ve `robots.txt` eklendi; arama motorlarına kapalı.
- Parola sorulmadan önce hiçbir dosya servis edilmez (`robots.txt` hariç).
- `alis_izlem_ag.html` ~3 MB olduğu için nginx tarafında gzip açıldı.

## Sorun giderme

| Belirti | Bakılacak yer |
|---|---|
| `ssh bulunamadi` | Windows Ayarlar → Uygulamalar → İsteğe bağlı özellikler → **OpenSSH Client** ekleyin |
| `Permission denied` | Sunucu kullanıcı adı/parolası; `ssh gentegre@46.36.201.170` ile elle deneyin |
| `sudo: a password is required` | `kur.sh`'ı sunucuda elle çalıştırın: `ssh -t gentegre@46.36.201.170 'bash ~/kur.sh'` |
| Sayfa açılmıyor | `sudo systemctl status nginx` · `sudo tail -50 /var/log/nginx/gentegre-mockup.error.log` |
| 80 portu doluysa | `kur.sh` başındaki `PORT=` değerini 8080 yapın; adres `http://46.36.201.170:8080/` olur |

---

## Alan adi: gentegreai.com

### 1. DNS kaydi (alan adini aldiginiz panelde)

| Tur | Ad  | Deger          | TTL  |
|-----|-----|----------------|------|
| A   | @   | 46.36.201.170  | 3600 |
| A   | www | 46.36.201.170  | 3600 |

Baska bir sey (CNAME, yonlendirme/forwarding, park sayfasi) eklemeyin.
Panelde "parking" / "yonlendirme" acikse kapatin — A kaydini ezer.

Yayilma suresi genelde 5-30 dakika, en kotu ihtimalle 24 saat.
Kontrol: komut satirinda `nslookup gentegreai.com` -> 46.36.201.170 gormelisiniz.

### 2. Kurulum

DNS yayildiktan sonra:

    powershell -ExecutionPolicy Bypass -File "C:\Users\HP\Entegra\Entegra\Ekranlar\_yayin\alanadi.ps1"

Betik once DNS'i kontrol eder; hazir degilse hicbir sey yapmadan durur.
Hazirsa sunucuda `alanadi.sh` calisir ve sunlari yapar:

- nginx'i `gentegreai.com` + `www.gentegreai.com` icin yapilandirir
- Let's Encrypt sertifikasi alir (ucretsiz, webroot dogrulamasi)
- `http://` -> `https://` ve `www.` -> koksuz adrese 301 yonlendirmesi kurar
- 443 portunu acar, otomatik yenilemeyi kurar (certbot.timer)
- Basic auth (kullanici `gentegre`) aynen korunur

Sonuc: **https://gentegreai.com/**

### 3. Sonrasi

- Mockup guncellemesi: eskisi gibi `yayinla.ps1`. `alanadi.ps1` bir daha
  gerekmez (yalniz alan adi veya sertifika ile ilgili bir sey degisirse).
- Sertifika 90 gunde bir kendiliginden yenilenir. Kontrol:
  `ssh gentegre@46.36.201.170 'sudo certbot certificates'`
- Sertifika alinamazsa: `/var/log/letsencrypt/letsencrypt.log`.
  En sik sebep DNS'in henuz yayilmamis olmasi veya 80 portunun kapali olmasi.
