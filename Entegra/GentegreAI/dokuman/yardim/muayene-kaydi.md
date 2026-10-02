---
id: muayene-kaydi
baslik: Muayene kaydı (hekim akışı)
modul: muayene
ekran: muayene
rota: /muayene
surec: muayene
roller: hekim, hemsire
dil: tr
surum: 1
urun_modu: 2
yetki: muayene
erisim: kullanici
ozet: Hekim Çalışma Listesi'nden hastayı muayeneye alma, muayene kartının sekmeleri (anamnez, bulgu, ICD-10 tanı, istem, rapor), reçete ve muayeneyi tamamlama kuralları.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Muayene, başvurudan doğan hekim kaydıdır: şikâyet, hikâye, vital bulgular, fizik muayene bulguları, ICD-10 tanılar, istemler, rapor ve karar burada tutulur. **▶ Muayeneye Al** başlangıç zamanını yazar; **✔ Tamamla** kaydı kilitler, başvuruyu tahakkuka döndürür ve e-Nabız paketlerini üretir.

## Ekrana giriş yolları
- Sol menü: **Muayene › Çalışma Listesi** (günün hastaları; satır = başvuru) ve **Muayene › Muayeneler** (muayene kayıtları).
- Çalışma Listesi'nde **🩺 Muayeneye Al** muayene kartını açar.
- Komut paleti (Ctrl+K) › "Muayene". Kart adresi `/muayene/[kayıt no]`.
- Reçeteler ayrı ekrandır: **Muayene › Reçeteler**.

## Ön koşullar
- **muayene** yetkisi; hekim kullanıcı yalnız kendi hastalarını görür (planlı hekim kısıtı), banko / yönetici tümünü görür.
- Hastanın açık başvurusu (protokolü) olmalı; muayene başvurudan açılır.
- Şablon kullanılacaksa **Muayene › Muayene Ayarları › Muayene Şablonları** tanımlı olmalı.

## Alanlar
Üst şerit: hasta, protokol, muayene no, kayıt tarihi ve durum (sekmelerde sabit); Tür, Bölüm, Hekim, Başlama, Bitiş "Bugün" kutusundan açılan pencerede.
**Muayene** sekmesi: solda **Şikâyet (tamamlamada zorunlu)**, Hikâye, altında **reçete ilaç gridi** (＋ İlaç, işaretlileri 🗑 Sil, önceki reçeteyi kopyala, e-İmzala), altında **Değerlendirme / Plan (zorunlu)** ve **Çıkış Şekli (zorunlu, e-Nabız)**; sağda **tanı gridi** (＋ ICD-10 ile eklenir; Tür, Taraf) ve altında bugünkü sonuçlar.
**Şablon Muayene** (fizik muayene): Muayene Şablonu, Muayene Bulguları; detay "Bulgular" (Sistem, Normal, Bulgu, Değer, Taraf) ve "Vital Bulgular" (Tansiyon, Nabız, SpO₂, Ateş, Solunum, Ağrı VAS, Boy / Kilo, BKİ, Bel çevresi, Parmak glukoz, GKS, ölçüm zamanı).
**Vital Bulgular** sekmesi: e-Nabız gönderim bilgileri ve sağ panelde **vital bulgular** (son ölçüm, düzenlenebilir).
**Sevk / Konsültasyon**: Karar, Sevk edilen tesis, Klinik, Sevk nedeni, Sevk notu, Ambulans, Ambulans saati, Kontrol (gün), Vaka Türü.
**Rapor** detayı: Tür, Alt tür, Rapor No, Başlangıç, Bitiş, Süre (gün), Tanı, Açıklama, İmza, Durum.
**İstem & Sonuçlar**: açılan lab / radyoloji istemleri, onaylı sonuçlar, "Gördüm" işareti ve her istemde **🖨 Sonuç Raporu**.
Kronik işaretlenen tanı Tıbbi Özet'e (Kronik Tanılar) kendiliğinden düşer.

## Liste kolonları ve çipler
Muayeneler: Muayene No · Tarih / Saat · Protokol · Hasta · Dosya No · Kimlik No · Bölüm · Hekim · Muayeneye Alındı · Tamamlandı · Bitiş. Çipler: **Açık · Sonuç Bekleyen · Tamamlanan · Tümü**.
Çalışma Listesi çipleri: **Bekleyen · Çağrıldı · Muayenede · Sonuç Bekleyen · Tamamlanan · Tümü**; üstte günün özet kutuları (muayene, açık, tamamlanan, ortalama süre).

## İşlemler (düğmeler)
Çalışma Listesi: `hekim.cagir` **📢 Sıradakini Çağır**, `hekim.secileni-cagir` **🔔 Seçileni Çağır**, `hekim.al` **🩺 Muayeneye Al**.
Muayeneler: `muayene.al` **▶ Muayeneye Al** (başlangıç zamanını yazar; ikinci basış ezmez), `muayene.tamamla` **✔ Tamamla**, `kart.duzenle` **✎ Düzenle** (F2), **🖨️ Yazdır**.
Sağ tuş / kart araç çubuğu: `muayene.istem` **🔬 İstem Aç** (Laboratuvar: tetkik / panel; Görüntüleme: modaliteli hizmet), `muayene.sablon` **📋 Şablon Uygula**, `muayene.normal` **☑ Tümü Normal**, `muayene.taniOnceki` **🕘 Önceki Tanılar**, `muayene.taniSik` **⭐ Sık Tanılarım**, `muayene.ozet` **🧾 Özeti Derle**; rapor için "İmzala" (imzalanan rapor değiştirilemez).

## Adım adım
1. **Muayene › Çalışma Listesi**'ni açın; **📢 Sıradakini Çağır** ya da satırı seçip **🔔 Seçileni Çağır**.
2. Hasta girince **🩺 Muayeneye Al**; kart açılır ve başlangıç zamanı yazılır.
3. Muayene sekmesinde Şikâyet ve hikâyeyi yazın, sağdaki tanı gridinden tanıları ekleyin; reçeteler şikâyetin altında görünür.
4. Şablon Muayene sekmesinde **📋 Şablon Uygula**, normal sistemleri **☑ Tümü Normal** ile işaretleyin, bulguları yazın.
5. Muayene sekmesindeki tanı gridinde ICD-10 arayın ya da **🕘 Önceki Tanılar / ⭐ Sık Tanılarım**'dan seçin; en az bir **ana** tanı olmalı.
6. Gerekirse **🔬 İstem Aç** ile lab / görüntüleme isteyin; sonuçları aynı kartın İstem & Sonuçlar sekmesinde görüp "Gördüm" işaretleyin.
7. Değerlendirme / Plan ve Çıkış Şekli'ni doldurun; reçete için Reçeteler ekranını kullanın.
8. **✔ Tamamla**: onay sorusundan sonra kayıt kilitlenir.

## Durumlar
- **Açık (1)**: hekim çalışıyor. **Sonuç Bekleyen (2)**: istem sonucu bekleniyor. **Tamamlanan (3)**: kilitli; istem eklenemez, alan değişmez.
- Reçete: Taslak → İmzalı → Medula Kabul (imzalanınca değişmez).

## Yetki
- Liste, kart ve aksiyonlar **muayene** yetkisi; muayene kapatma için Değiştir hakkı.
- Hekim kısıtı: aktif çalışma şablonu olan hekim yalnız kendi hastalarını listeler.
- Muayene şablonları, makrolar, ICD-10 ve ilaç kataloğu **katalog** / **muayene** yetkileriyle "Muayene Ayarları" altındadır.
- Şablon kartının **Sık Tanılar · Reçete Şablonları · İstem Panelleri · Metin Makroları · Kurallar** sekmeleri o bölüm/doktora özeldir: ICD aramasında **📋 Şablon Tanıları**, reçetede **📋 Şablondan…** olarak çıkar; paneller istem ekranında **⭐ Şablon Panelleri** kategorisidir; makro kısayolu alanda yazılıp boşluk basılınca metne açılır; aktif kurallar (hikâye / bulgu / vital / ek tanı zorunlu) **Tamamla**'da denetlenir.

## Sık görülen hata ve uyarılar
- **"Muayene tamamlanamaz: Ana tanı zorunlu. Şikayet zorunlu. Değerlendirme / plan zorunlu."** (DOGRULAMA) → eksikler tek seferde sayılır; hepsini doldurup tekrar deneyin.
- **"Muayene başlatılmamış - 'Muayeneye Al' ile başlangıç zamanı yazılmalı."** → önce ▶ Muayeneye Al.
- **"Çıkış şekli seçilmeli (e-Nabız çıkış bildiriminin zorunlu alanı)."** → Muayene sekmesinde (reçetenin altında) Çıkış Şekli'ni seçin.
- **"Muayene zaten tamamlanmış." / "Tamamlanmış muayeneye istem eklenemez."** (IS_KURALI) → kapanmış kayıt; yeni işlem için yeni başvuru / muayene.
- **"Tanımlı şablon yok." / "Tetkik kataloğu boş." / "Modalitesi tanımlı radyoloji tetkiki yok"** → ilgili ayar ekranından tanım eksik.
- **"İmzalanacak taslak rapor yok."** → Rapor sekmesinde taslak satır ekleyin.

## Diğer modüllere etkisi
- Tamamlama başvuruyu tahakkuka döndürür ve e-Nabız "Muayene Bilgisi" (103) + "Hasta Çıkış" (106) paketlerini kuyruğa atar; paket üretimi başarısız olsa da muayene kapanır.
- İstemler laboratuvar / radyoloji çalışma listelerine düşer; onaylı sonuçlar karta döner.
- Kronik tanı, alerji ve kullanılan ilaçlar Tıbbi Özet şeridini besler; reçete ilaç kataloğunu okur.
- Prim / hakediş muayeneyi yapan hekime yazılır.

## Yapılmaması gerekenler
- Kartı açar açmaz Tamamla'ya basmayın; zorunlu alanlar ve çıkış şekli olmadan kapanmaz.
- Tanı kodunu elle uydurmayın; ICD-10 kataloğu senkronla dolar, e-Nabız ve provizyon aynı kodu bekler.
- Tamamlanmış muayeneyi "düzeltmek" için yeniden açmaya çalışmayın; kayıt kilitlidir.

## Örnek sorular
- Hastayı muayeneye nasıl alırım?
- Muayene neden tamamlanmıyor, "ana tanı zorunlu" ne demek?
- ICD-10 tanıyı nereden eklerim?
- Muayene kartından laboratuvar istemi nasıl açılır?
- Sonuçları nerede görürüm?
- Muayene şablonu nasıl uygulanır?
- Reçeteyi nereden yazarım?
- Çıkış şekli neden isteniyor?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Klinik.ts (hekim-listesi, muayene, recete, muayene-sablon)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (hekim-liste, muayene-liste)
- api/src/Gentegre.Cekirdek/Katalog/KartKatalogu.Saglik.cs (muayene kartı), KaynakKatalogu.Saglik.cs
- api/src/Gentegre.Api/Uclar/MuayeneUclari.cs (al / tamamla kuralları)
- web/src/sayfalar/liste/muayeneAksiyonlari.ts
- dokuman/01_API_SOZLESMELERI.md §9.8; dokuman/00_TARIHCE.md (hekim kısıtı)

## Doğrulama durumu
Kod incelemesiyle yazıldı. Reçete yazımının muayene kartı içinde ayrı bir sekmede mi yoksa yalnız Reçeteler ekranında mı olduğu doğrulanacak.
