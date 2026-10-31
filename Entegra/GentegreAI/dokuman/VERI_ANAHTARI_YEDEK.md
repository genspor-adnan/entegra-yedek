# Veri şifreleme anahtarı (`.veri_anahtari`) — alma, saklama, geri yükleme

Kod inceleme 30.10.2026 **K28**: entegrasyon sırları (e-Belge, e-Nabız, SMS/SMTP, ÜTS, İTS, sigorta,
Garanti, SKRS şifre/token'ları, `ayarlar.client_secret`, santral anahtarları) DB'de **AES-256-GCM** ile
şifreli durur. Anahtar DB'de **değil**, sunucuda kurulum klasöründedir.

> **Anahtar kaybolursa kayıtlı şifreler çözülemez** — DB yedeği tek başına onları geri getirmez.
> Şifrelerin hepsi Yönetim › Ayarlar › Genel › Entegrasyon'dan yeniden girilir.

## Nerede

Dosya, K28 değişikliği içeren **ilk yayında** sunucu tarafından otomatik üretilir
(`yayin/sunucu-guncelle.sh`). Yayın çıktısında şu satır görünür:

```
kurulum VERI SIFRELEME anahtari URETILDI (…/.veri_anahtari) - YEDEGINI ALIN
```

Sunucu: `gentegre@46.36.201.170`. Her kurulumun anahtarı **ayrıdır**:

| Kurulum | Dosya |
|---|---|
| hbys  | `~/gentegre-ai/.veri_anahtari` |
| erp   | `~/gentegre-erp/.veri_anahtari` |
| bilim | `~/gentegre-bilim/.veri_anahtari` |
| feta  | `~/gentegre-feta/.veri_anahtari` |
| zone  | `~/gentegre-zone/.veri_anahtari` |
| medx  | `~/gentegre-medx/.veri_anahtari` |

Yayın her seferinde bu dosyayı okuyup `api/appsettings.Gizli.json`'a (`Guvenlik:VeriAnahtari`) yazar;
dosya varsa **yeniden üretilmez**.

## Alma (yayından sonra, kendi bilgisayarında — PowerShell)

```powershell
mkdir $HOME\gentegre-anahtarlar -Force
foreach ($k in 'gentegre-ai','gentegre-erp','gentegre-bilim','gentegre-feta','gentegre-zone','gentegre-medx') {
  scp "gentegre@46.36.201.170:~/$k/.veri_anahtari" "$HOME\gentegre-anahtarlar\$k.veri_anahtari"
}
```

Henüz yayınlanmamış kurulum için `No such file` çıkar — o kurulum yayınlanınca tekrar çalıştırılır.
Yeni bir kurulum eklendiğinde (yeni müşteri) onun anahtarı da aynı şekilde alınır.

## Saklama

- İçerik **tek satır, 44 karakter** (base64, 32 bayt). Parola yöneticisine (Bitwarden / 1Password /
  KeePass) **her kurulum için ayrı kayıt** olarak konur; ardından yerel kopya silinebilir.
- **Sunucu yedeğiyle aynı yerde tutulmaz** — amaç sunucu kaybolsa da anahtarın elde olması.
- Git'e, e-postaya, sohbete **yapıştırılmaz**.

## Geri yükleme (sunucu yeniden kurulursa)

Yayından **önce** dosya yerine konur:

```powershell
scp "$HOME\gentegre-anahtarlar\gentegre-feta.veri_anahtari" "gentegre@46.36.201.170:~/gentegre-feta/.veri_anahtari"
ssh gentegre@46.36.201.170 "chmod 600 ~/gentegre-feta/.veri_anahtari"
```

Dosya yerindeyse yayın onu kullanır. Yoksa yeni anahtar üretilir ve DB'deki eski şifreler çözülemez
(ekran "Kayıtlı şifre / token bu kurulumun anahtarıyla çözülemedi … yeniden girin" der).

## Notlar

- Bir kurulumun DB'si başka bir kuruluma taşınırsa (ör. FETA DB'si ZONE'a) şifreler çözülmez;
  ya anahtar da taşınır ya şifreler yeniden girilir.
- Geliştirme ortamı depodaki geliştirme anahtarını kullanır (`appsettings.json`); üretimde o anahtarla
  API **açılmaz**.
- Anahtar dönüşümü (değiştirme) için hazır araç yok: dosya değişirse eski şifreli değerler okunamaz.
