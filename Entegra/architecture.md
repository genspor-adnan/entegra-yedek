# Entegra - Mimari Dokumantasyonu

## Genel Bakis

Entegra, Delphi ile gelistirilmis kapsamli bir **is yonetim sistemidir** (ERP). Finans, stok, CRM, proje, dokuman takip, kalite ve IK modullerini icerir. Veritabani olarak **Microsoft SQL Server** kullanir.

---

## Proje Dosyalari

| Proje | Aciklama |
|-------|----------|
| **Gentegre.dpr** | Ana uygulama (modern Frame tabanli mimari, aktif gelistirme) |
| **entegra.dpr** | Eski (legacy) uygulama |
| **Rehber.dpr** | Bagimsiz adres defteri modulu |

---

## Dizin Yapisi

```
entegra/
├── AnaFrame/              # Ana sekme container frame
├── AramaFrame/            # Arama/filtreleme frameleri (35+)
├── AracCubuguFrame/       # Arac cubugu frameleri
├── ListeFrame/            # Veri listeleme/grid frameleri (30+)
├── IcerikFrame/           # Icerik goruntuleme frameleri (30+)
├── GorevFrame/            # Gorev/aksiyon frameleri
├── GirisSayfaFrame/       # Dashboard/giris sayfalari
├── Ortak/                 # Paylasilan yardimci kutuphaneler (50+)
│   ├── Fetautil.pas       # Temel yardimci fonksiyonlar
│   ├── FetaKurulusSiniflari.pas  # Is nesnesi siniflari
│   ├── FetaClassExtensions.pas   # Sinif uzantilari
│   ├── UFrameYoneticisi.pas      # Frame yasam dongusu yonetimi
│   ├── UFastRap.pas       # FastReport entegrasyonu
│   └── ...
├── Rest/                  # REST API / Adisyon yazici entegrasyonu
├── 3dparty/               # Ucuncu parti kutuphaneler
│   ├── GenYazilim/        # Barkod, goruntu bilesenleri
│   ├── SuperObjects/      # JSON kutuphanesi
│   └── DelphiJSON_Tree/   # JSON agac yapisi
├── EvrakTakip/            # Evrak/dokuman takip modulu
├── Social/                # Sosyal/CRM ozellikleri
├── ItsServisler/          # Depo yonetim sistemi entegrasyonu
├── UTS/                   # Urun takip sistemi (seri no/barkod)
├── Bankalar/ (Archive)    # Banka entegrasyonlari (TEB, ING, Garanti)
├── XML/                   # XML islemleri
├── eFaturaApi/            # E-Fatura entegrasyonu
└── Archive/               # Eski/arsivlenmis kodlar
```

---

## Mimari Yapi

### Katmanli Mimari

```
Kullanici Arayuzu (UI)
    │
    ├── AramaFrame    → Arama/filtreleme panelleri
    ├── IcerikFrame   → Ana icerik alani
    ├── ListeFrame    → Grid/tablo gosterimi
    ├── GorevFrame    → Gorev/aksiyon panelleri
    └── GirisSayfaFrame → Dashboard
    │
Frame Yonetimi
    │
    ├── UGentegreFrameYonetimi.pas  → Frame olusturma/yonetim
    └── UGenelAnaSekmeFrame.pas     → Sekme koordinasyonu
    │
Veri Katmani
    │
    ├── Utablo.pas (TDataModule)    → Merkezi veri erisimi
    ├── FireDAC (FDConnection/FDQuery)
    └── ADO (eski kod icin)
    │
SQL Server Veritabani (60+ tablo)
```

### UI Akisi

```
UAnaForm (Ana pencere + menu)
    ↓
TGenelAnaSekmeFrame (Sekme yonetimi)
    ├── AramaFrame  (Sol panel - arama)
    ├── IcerikFrame (Orta panel - icerik)
    ├── ListeFrame  (Orta panel - liste)
    └── GorevFrame  (Sag panel - gorevler)
```

Sekmeler **entegra_sekmeconfig.xml** dosyasiyla yapilandirilir.

---

## Veritabani Tablolari

### Musteri/Cari Yonetimi
| Tablo | Aciklama |
|-------|----------|
| REHBER | Musteri/tedarikci ana kayit (KOD, FIRMA, ADSOYAD, EMAIL, CEP...) |
| REHCARI | Cari hesap baglantilari |
| REHBERBILGI | Ek iletisim bilgileri |
| REHBERILETISIM | Iletisim detaylari |
| REHBERPERSONEL | Firma personelleri |
| REHBERAYAR | Musteri bazli ayarlar |
| FIRMALAR | Firma ana kaydi |

### Fatura/Satis
| Tablo | Aciklama |
|-------|----------|
| FATBASLIK | Fatura baslik (REHBERID, FATURATARIH, FATURA_TUTARI, TUR) |
| FATURA | Fatura satirlari (FATBASID, URUNID, MIKTAR, FIYAT...) |

**Fatura Turleri (TUR):**
- 10, 11, 12, 14, 15, 16 → Satis belgeleri
- Diger turler → Alis belgeleri

### Kasa/Finans
| Tablo | Aciklama |
|-------|----------|
| KASA | Kasa hareketleri (REHBERID, FATURAID, BORC, ALACAK, KUR) |
| KASALAR | Kasa tanimlari |
| BANKALAR | Banka tanimlari |
| BANKAHESAPLAR | Banka hesaplari |
| DOVIZ | Doviz kurlari |
| KREDIKARTI | Kredi karti tanimlari |
| POS | POS cihaz tanimlari |

### Cek/Senet
| Tablo | Aciklama |
|-------|----------|
| CEKLER | Cek ana kaydi |
| SENETLER | Senet ana kaydi |
| CEKHAREKET | Cek hareketleri |

### Stok/Depo
| Tablo | Aciklama |
|-------|----------|
| STOKLAR | Stok/urun ana kaydi (STOKADI, STOKKODU, BIRIM...) |
| STOKFIYAT | Stok fiyatlari |
| STOKBARKOD | Barkod tanimlari |
| STOKDURUM | Stok durumlari |
| STOKSAYIM | Sayim kayitlari |

### Proje/Gorev
| Tablo | Aciklama |
|-------|----------|
| PROJELER | Proje ana kaydi |
| PROJEBUTCE | Proje butceleri |
| GOREVLER | Gorev kayitlari |
| GOREVKULLANICI | Gorev atamalari |

### Dokuman
| Tablo | Aciklama |
|-------|----------|
| DOKUMAN | Dokuman ana kaydi |
| DOKUMANKLASOR | Klasor yapisi |
| DOKUMANYETKI | Erisim yetkileri |

### Demirbas
| Tablo | Aciklama |
|-------|----------|
| DEMIRBAS | Demirbas ana kaydi |
| DEMIRBASTAKIP | Demirbas takibi |

### Sistem
| Tablo | Aciklama |
|-------|----------|
| KULLAN | Kullanici tanimlari |
| KULHAR | Kullanici hareketleri |
| AYARLAR | Genel ayarlar |
| ROLLER | Kullanici rolleri |
| LOG | Aktivite loglari |

---

## Temel Tasarim Kaliplari

1. **Frame Tabanli UI** — Sekmeler XML konfigurasyonla tanimlanir, frameler dinamik yuklenir
2. **Wizard Kalıbı** — Karmasik islemler icin adim adim giris (UFaturaWizard, UStokWizard, UProjeWizard...)
3. **Merkezi Veri Modulu** — Utablo.pas tum veritabani erisimini yonetir
4. **Observer Kalıbı** — UMultiCastEvent.pas ile moduller arasi bildirim
5. **Fabrika Kalıbı** — UGentegreFrameYonetimi ile dinamik frame olusturma

---

## Entegrasyonlar

| Sistem | Aciklama |
|--------|----------|
| **E-Fatura** | eFaturaApi/ - GIB e-fatura entegrasyonu |
| **Bankalar** | TEB, ING, Garanti ekstre indirme |
| **ITS** | Depo yonetim sistemi (mal alma, satis, iade) |
| **UTS** | Urun takip sistemi (seri no/barkod) |
| **POS/Adisyon** | Rest/UBaglanti.pas - TCP uzerinden yazici iletisimi |
| **SMS** | Ortak/USMS.pas - SMS gonderimi |
| **E-Posta** | UMailGonderim.pas, UMailYaz.pas |

---

## Konfigürasyon Dosyalari

| Dosya | Aciklama |
|-------|----------|
| entegra_sekmeconfig.xml | Ana sekme yapilandirmasi |
| SekmeConfig.xml | Alternatif sekme ayarlari |
| GenoTIP.ini | Uygulama genel ayarlari (DB baglanti, modul tanimlari) |
| Entegra.cfg / Gentegre.cfg | Derleyici ayarlari |
| doviz.xml | Gunluk doviz kurlari |

---

## Istatistikler

| Metrik | Sayi |
|--------|------|
| Ana proje (.dpr) | 3 |
| Pascal birimleri | 400+ |
| Form birimleri (U*.pas) | 266 |
| Frame birimleri | 113 |
| Veritabani tablolari | 60+ |
| Ucuncu parti kutuphane | 50+ |
| Konfigürasyon dosyasi | 20+ |
