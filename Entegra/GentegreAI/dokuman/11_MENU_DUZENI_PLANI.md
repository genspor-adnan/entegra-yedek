# Menü Düzeni — Yeniden Tasarım Planı

Tarih: 15.09.2026 · Durum: **UYGULANDI** (kullanıcı onayı: "menüleri ideal mockup gibi yap")
· Mockup: `Ekranlar/Ayarlar/menu_duzeni.html`

> **Uygulama notu (15.09.2026).** 137 menü öğesi yeniden gruplandı, 12 öğe menüden
> çıkarıldı (rota ve yetki kodu KORUNDU). Grup başına `📊 Dökümler` öğesi eklendi
> (`listeTanimlari.Dokumler.ts`) ve `/dokumler?grup=…` süzgeciyle çalışıyor; döküm
> kendi menü grubunu söylüyor (`dokum_tanimi.menu_grup`, göç 690) çünkü `belge`
> kaynağı üç grupta birden kullanılıyor. Boş açılan grup kalmasın diye altı yeni
> standart döküm eklendi (göç 689). `Mesajlar` ve `Yapay Zeka` üst çubuğa alındı.
> Yeni testler: `menuDuzeni.test.ts` (6 kural).
>
> **Yapılmayan:** Pano grubu (Günün Özeti / Bekleyen İşlerim ekranları yok) ve
> `⚙ Ayarlar` için tek `/ayarlar?sekme=` ekranı (Ayarlar Dizini henüz yok) - grup
> içi Ayarlar şimdilik var olan ayar ekranlarını toplayan bir ALT GRUP.
(Şimdiki Menü · Önerilen HBYS · Önerilen ERP · Kabuk Önizleme · Menüden Çıkanlar · Kurallar)

Kaynak: `web/src/sayfalar/listeTanimlari.*.ts` (`menuGrup / menuAltGrup / menuSira / menuAd /
urunModu / modul`) + `web/src/sayfalar/Kabuk.tsx` (`GRUP_SIRA`, `GRUP_IKON`, `ALTGRUP_IKON`).

## 1. Bugün

18 ana grup, 149 menü öğesi:
İletişim & AI · Randevu · Kayıt Kabul · Muayene · Laboratuvar · Radyoloji · e-Nabız · Cari ·
CRM · Stok & Hizmet · Üretim · Muhasebe · Satış · Alış · Kasa · Banka · İK · Doküman · Yönetim.

Sorunlar:
- 18 grup 1000px ekrana sığmıyor; tek/iki öğeli gruplar (İletişim, Randevu, e-Nabız, Üretim).
- Ayarlar 7 yerde: grup altı "Ayarlar" alt grupları + Yönetim › Modül Ayarları + Randevu Ayarları.
- Aynı cins şey ayrı gruplarda: Kasa / Banka; Cari / CRM; Cari altında Sigorta (HBYS).
- Yanlış yerde: Yönetim › Fiyat Listesi Satırları; İK › Roller; Satış › e-Belge (`menuSira 999`).
- Kayıt-bağımlı listeler menüde: Muayene › Tıbbi Özet · Kronik · Geçmiş · Alerji · İlaçlar
  ("hangi hasta?"); Muhasebe › Fiş Satırları; İK › Hakediş Satırları; Kasa › Kasa Hareketleri.
- İki ayrı "Kod Eşleme" (Sigorta, e-Nabız) aynı adla.
- Mesajlar / Yapay Zeka ana grup — araç, iş akışı değil.

## 2. İlkeler

1. **Grup = iş akışı ya da rol**, dosya değil. Tavan: HBYS 13, ERP 10.
2. **Her grupta aynı desen:** günlük iş listeleri → tanımlar → **📊 Dökümler** → **⚙ Ayarlar**
   (son iki öğe hep aynı).
3. **Ayarlar iki giriş, tek ekran:** modül altındaki ⚙ ve Yönetim › Ayarlar Dizini aynı
   `/ayarlar?sekme=<grup>` yoluna gider (bkz. `Ekranlar/Ayarlar/ayarlar_dizini.html`).
4. **Dökümler iki giriş:** grup içi 📊 Dökümler = o kaynağın kayıtlı dökümleri (çalıştırma);
   Yönetim › Dökümler & İstatistik = tasarımcı (bkz. `10_DOKUM_ISTATISTIK_PLANI.md`).
5. **Kayıt-bağımlı liste menüde olmaz** — kartın sekmesi olur; rota silinmez.
6. **Araç olan menüde durmaz:** 💬 Mesajlar (rozet), 🔔 Bildirimler, ✨ AI paneli, 🔍 Ctrl+K
   hızlı arama (ekran adı + kayıt) üst çubukta.
7. **Ürün modu / modül / yetki yalnız süzer, sıra sabit** (bugünkü kural korunur).
8. **Ad kısa, grup adı tekrar etmez:** "Satış › Faturalar". Başlık çubuğu tam yolu gösterir.
9. Alt grup tavanı: grup başına 4, alt grup başına 10 öğe.

## 3. Önerilen — HBYS (13 grup, 129 öğe)

| Grup | Öğeler | Alt gruplar |
|---|---|---|
| 🏠 Pano | Günün Özeti · Bekleyen İşlerim · Dökümlerim | — |
| 📅 Randevu | Randevular · Ajanda (hekim/gün) · Bekleme Listesi · Dökümler · Ayarlar | — |
| 🚑 Kayıt Kabul | Hastalar · Başvurular · İskonto Onayı · Provizyonlar · Vezne (Tahsilat) · Kasa Teslim · Dökümler · Ayarlar | — |
| 🩺 Muayene | Çalışma Listesi · Muayeneler · Reçeteler · Hakedişlerim · Dökümler | Ayarlar: Muayene Şablonları · Metin Makroları · ICD-10 · İlaç Kataloğu · Klinik Kataloglar |
| 🧪 Laboratuvar | İstemler · Numune Kabul · Sonuçlar · Dış Lab Gönderimleri · Dökümler | Biyokimya (KK, lot, dış kalite, cihaz, cihaz mesaj/olay) · Mikrobiyoloji (kültür listesi) · Genetik (vaka, varyant, run) · Ayarlar (tetkik kataloğu, panel, serum indeksi, Westgard, cihaz eşleme, organizma, antibiyotik, besiyeri, gen, genetik panel, dış laboratuvarlar) |
| ☢️ Radyoloji | Çalışma Listesi · Pano · Kritik Bulgular · Konsültasyonlar · Sonuç Teslim · Dökümler | Ayarlar: Rapor Şablonları · Çekim Protokolleri · Cihazlar |
| 🏛️ Kurumlar & Sigorta | Anlaşmalı Kurumlar · Kurum İcmalleri · Kurum Hesapları · İstek Günlüğü · Dış Doktorlar · Dökümler | Ayarlar: Kod Eşleme (SUT/Kurum) · Fiyat Listeleri |
| 💓 e-Nabız | Veri Kalitesi · Gönderim Kuyruğu | Ayarlar: Kod Eşleme |
| 💰 Finans | Kasa İşlemleri · Kasa Hesapları · Banka Hesapları · POS · Kredi Kartı · Çek / Senet · Vade / Planlar · Masraflar · Cari Ekstre · Hesap Ekstresi · Dökümler | Ayarlar: Kasa Ayarları · Banka Tanımları · Krediler · İşlem Türleri |
| 📦 Stok & Hizmet | Stoklar · Hizmetler · Stoktan Talep · Stok Transfer · Giriş / Çıkış Fişi · Alış Faturaları · Dökümler | İTS / ÜTS · Ayarlar (Kategoriler, Kampanyalar, Stok Ayarları, Tedarikçiler) |
| ⚖️ Muhasebe | Muhasebe Fişleri · e-Belge · Dökümler | Ayarlar: Hesap Planı · Masraf Merkezleri |
| 👥 İK & Prim | Personel · Bölüm / Görev · Hakedişler · Prim Planları · Dökümler | — |
| 🧭 Yönetim | Ayarlar Dizini · Dökümler & İstatistik · Kurum Profili · Firma / Şubeler | Güvenlik (Roller, Kullanıcılar, Giriş Kayıtları, İşlem Günlüğü) · Platform (Bildirim Şablonları, Bildirim Kuyruğu, Zamanlanmış İşler, Onam Metinleri, Onam Kayıtları) · Doküman (Dokümanlar, Onay Kuyruğu, Kategoriler · Klasörler) · Veri (İçeri Alma, Dışarı Aktarma) |

Sıra hasta akışı: Randevu → Kayıt Kabul → Muayene → Lab → Radyoloji → Kurumlar → e-Nabız;
sonra para, malzeme, muhasebe, İK; Yönetim en sonda.

## 4. Önerilen — ERP (10 grup, 84 öğe)

| Grup | Öğeler | Alt gruplar |
|---|---|---|
| 🏠 Pano | Günün Özeti · Bekleyen İşlerim · Dökümlerim | — |
| 🤝 Cari & CRM | Müşteriler · Tedarikçiler · Kişiler · Aday Müşteriler · Satış Fırsatları · Projeler · Görevler · Cari Ekstre · Dökümler | — |
| 🛍️ Satış | Teklifler · Siparişler · İrsaliyeler · Faturalar · Fişler · Tahakkuklar · Açık Satırlar · Dökümler | Ayarlar: Satış Belgeleri · Fiyat Listeleri · Kampanyalar |
| 🛒 Alış | Gelen Kutusu · Siparişler · İrsaliyeler · Faturalar · Fişler · Tahakkuklar · Konsinyeler · Dökümler | Ayarlar: Alış Belgeleri |
| 📦 Stok & Hizmet | Stoklar · Hizmetler · Stoktan Talep · Stok Transfer · Giriş / Çıkış Fişi · Dökümler | ÜTS · Ayarlar (Kategoriler, Stok Ayarları) |
| 🏭 Üretim | Üretim Emirleri · Ürün Ağaçları · Dökümler | Ayarlar: İş Merkezleri |
| 💰 Finans | HBYS ile aynı | aynı |
| ⚖️ Muhasebe | HBYS ile aynı | aynı |
| 👥 İK | Personel · Bölüm / Görev · Dökümler | — |
| 🧭 Yönetim | HBYS ile aynı (Onam hariç) | aynı |

Sıra ticari akış: Cari → Satış → Alış → Stok → Üretim → Finans → Muhasebe → İK → Yönetim.

## 5. Menüden çıkan / taşınan

| Öğe | Eski | Yeni | Neden |
|---|---|---|---|
| Mesajlar · Yapay Zeka | İletişim & AI | Üst çubuk 💬 ✨ | Araç; bir grup eksilir |
| Tıbbi Özet · Kronik · Geçmiş · Alerji · İlaçlar | Muayene | Hasta kartı sekmeleri | Hastasız anlamı yok |
| Fiş Satırları · Hakediş Satırları · Fiyat Listesi Satırları · Kasa Hareketleri | Muhasebe / İK / Yönetim / Kasa | İlgili kartın Satırlar/Hareketler sekmesi + Dökümler | Bağımsız ekran değil |
| Satış Konsinyeler | Satış | Siparişler cipi "Konsinye" | Nadir; cip yeter |
| Kod Eşleme ×2 | Cari › Sigorta, e-Nabız | Her modülün Ayarlar'ı | Aynı ad karışıyordu |
| Doküman | ana grup | Yönetim › Doküman | Günlük iş değil |
| CRM | ana grup | ERP: Cari & CRM · HBYS: yok | Aynı kişiler |
| Kasa + Banka | iki grup | Finans | "Tahsilat nerede" iki gruba bakılıyordu |
| Modül Ayarları | Yönetim | Grup içi ⚙ + Ayarlar Dizini | Tek kaynak, iki giriş |
| Roller | İK | Yönetim › Güvenlik | Rol = yetki |
| Anlaşmalı Kurumlar · İcmaller · Dış Doktorlar · Sigorta | Cari | HBYS: Kurumlar & Sigorta | "Cari" HBYS'te yabancı |
| Tedarikçi (HBYS) | Cari | Stok & Hizmet › Ayarlar | Yalnız alış için |
| Alış (HBYS) | ana grup | Stok & Hizmet › Alış Faturaları | İlaç/sarf girişi |
| e-Belge | Satış (999) | Muhasebe | Fatura sonrası süreç |

Rota ve yetki kodları **değişmez**; kayıtlı roller bozulmaz.

## 6. Uygulama

| Yer | Değişiklik |
|---|---|
| `Kabuk.tsx` | `GRUP_SIRA` yeni sıra (tek liste, mod süzer); `GRUP_IKON` (+Pano 🏠, Kurumlar & Sigorta 🏛️, Finans 💰, İK & Prim 👥); `ALTGRUP_IKON` (+Ayarlar ⚙️, Güvenlik 🛡️, Platform 🧩, Doküman 📁, Veri ⬆); üst çubuk 💬 🔔 ✨ Ctrl+K |
| `listeTanimlari.*.ts` | `menuGrup / menuAltGrup / menuSira / menuAd` güncellenir; sekmeye inen 9 liste için `menuGrup` kaldırılır (rota kalır); her grupta ⚙ Ayarlar (`/ayarlar?sekme=…`) ve 📊 Dökümler (`/dokumler?kaynak=…`) öğeleri |
| `db/NNN_menu_yeniden.sql` | Yetki matrisi grupları menüden türediği için yeniden üretim (682 deseni); `ceviri`ye yeni grup adları (EN) |
| `RolYetkiMatrisi.tsx` | `GRUP_ADI` / `EK_GRUP` yeni adlar |
| Kartlar | Hasta kartına tıbbi sekmeler (varsa aynen); fiş / hakediş / fiyat listesi / kasa hesabı kartlarına Satırlar-Hareketler sekmesi |
| Testler | `kabukMenu.test.tsx`: grup tavanı, her grupta son iki öğe Dökümler + Ayarlar, modla süzme, yetkisiz öğe çizilmez |

Bağımlılık: Ayarlar Dizini ekranı (`/ayarlar`) ve Dökümler (`10_DOKUM_ISTATISTIK_PLANI.md`
Aşama A) olmadan ⚙/📊 öğeleri boşa gider — önce onlar, ya da ilk sürümde bu iki öğe gizli.

## 7. Açık kararlar

1. Pano › "Bekleyen İşlerim" kapsamı (onay kuyrukları + görevler + kritik bulgular?) — ayrı plan.
2. HBYS'te CRM tamamen kapalı mı, yoksa kurum profili modülü ile açılabilir mi?
3. Üst çubuk Ctrl+K kayıt araması hangi kaynakları tarar (hasta, başvuru, cari, stok)?
4. Vezne (Tahsilat) Kayıt Kabul'de mi Finans'ta mı — banko rolü Kayıt Kabul'de bulur; iki yerde göstermek kural 2'yi bozar.
