---
id: basvuru-acma
baslik: Hastaya başvuru (protokol) açma
modul: kayit_kabul
ekran: belge
rota: /basvuru
surec: basvuru
roller: kayit_kabul, banko
dil: tr
surum: 1
urun_modu: 2
yetki: belge
erisim: kullanici
ozet: Kayıt Kabul › Başvurular ekranında protokol açma, ödeyen kurum / bölüm / hekim seçimi, tahsilat ve kapanmamış başvuru kuralı.
guncelleme: 2026-09-19
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Başvuru, hastanın o günkü kabulünün belgesidir (protokol). Kalemler (muayene, tetkik, işlem) bu belgeye yazılır, ödeyen kurum ve provizyon burada belirlenir, tahsilat buradan alınır ve belge sonunda faturaya / tahakkuka dönüştürülür. Teknik olarak satış siparişi ile aynı belge türüdür; HBYS kurulumunda "Başvuru" adıyla ve kendi ekranıyla görünür.

## Ekrana giriş yolları
- Sol menü: **Kayıt Kabul › Başvurular**.
- Hasta kartındaki **＋ Yeni Başvuru** düğmesi (önerilen yol: önce hastayı bul, sonra başvuru aç).
- Randevu listesinde **➜ Başvuruya Dönüştür** (hasta geldiğinde).
- Komut paleti (Ctrl+K) › "Başvuru".

## Ön koşullar
- Hasta kartı açılmış olmalı (hasta yoksa önce Hasta Listesi'nden kaydedin).
- Rolünüzde **belge** yetkisi (Gör / Ekle); tahsilat için **kasa_islem** Ekle; belge kesmek için `belge.donustur` aksiyon yetkisi.
- Ödeyen kurum SGK ya da özel sigorta ise provizyon adımı gerekir; kurum bilgisi eksikken fatura kesilemez.

## Alanlar
Kart "Başvuru" sekmesinde üstte hasta şeridi: Dosya No / SYS Takip No, Doğum / Cinsiyet, Doktor / Personel, Kapanma, Açık Belge, Açık Tahsilat, Avans.
Başvuru alanları: Hasta, Ödeyen Kurum (kurum), Sözleşme / Poliçe / Alt Kurum, Bölüm (poliklinik), Hekim, başvuru türü ve tarih (zorunluluk işaretleri doğrulanacak).
"Provizyon" sekmesi: Özel Sigorta Provizyonu / Tamamlayıcı Sigorta Provizyonu, Sigorta Şirketi, Müstehaklık (Müstehak / Müstehak değil / Sorgulanmadı), Sevkli mi?, Karşılama %, Onaylanan Tutar, Hastadan / Kurumdan payı, Hastaya kesilecek / Kuruma kesilecek.
"Kalemler" sekmesi: hizmet satırları (miktar, fiyat, iskonto); "Tahsilat" sekmesi: alınan ödemeler; "Önceki Başvurular" kutusu: hastanın geçmiş protokolleri (çift tık açar).
Kart düğmeleri: **💾 Kaydet**, **✖ İptal (kaydetme)**, **↩ Geri Dön**.

## Liste kolonları ve çipler
Kolonlar: Tarih · Tamamlanma (aşama çizgisi) · Protokol No · Hasta · Kurum · Sözleşme · Poliklinik · Doktor · Genel Toplam · Tahsilat; altta Genel Toplam ve Tahsilat toplamı.
Çip yok; şeritte üç seçim kutusu: **Tamamlanma**, **Tahsilat**, **Dönüşüm** (Açık / Kısmi / Kapanan). Sağında tarih aralığı, Ödeyen, Bölüm ağacı ve Doktor süzgeci.
Matrah / KDV bu ekranda gizlidir; hastaya söylenen rakam Genel Toplam, yanında tahsil edilen tutardır.

## İşlemler (düğmeler)
- `belge.yeni` **＋ Yeni Başvuru** (Ctrl+N): boş başvuru kartı.
- `belge.ac` **Aç** (Enter): seçili başvuruyu açar.
- `belge.sil` **🗑 Sil** (Del): yalnız izi olmayan başvuru silinir; kesin belgede "İptal Et" kullanılır.
- `belge.donustur` **⇢ Belge Kes**: başvuruyu fatura / fiş / tahakkuk belgesine dönüştürür.
- `kasa.tahsilat.yeni` **＋ Tahsilat**: Nakit / Banka / POS / Çek / Senet ile hasta ödemesi alır.
- `belge.iptal` **İptal Et** (sağ tuş): kesinleşmiş başvuruyu iptal eder.
- `belge.fis-gor` **Muhasebe Fişini Aç**, `belge.hedef-ac` **Hedef Belgeyi Aç** (sağ tuş): fiş ve dönüşüm zinciri.
- `genel.yazdir` **🖨️ Yazdır**.

## Adım adım
1. **Kayıt Kabul › Hasta Listesi**'nde hastayı bulun, kartı açın, **＋ Yeni Başvuru**'ya basın (ya da Başvurular ekranında **＋ Yeni Başvuru**).
2. Hastanın kapanmamış başvurusu varsa sistem "Bu hastanın kapanmamış başvurusu var - o başvuru açıldı." der ve o kartı getirir; yeni protokol açmaz.
3. Ödeyen kurumu (SGK / özel / anlaşmalı kurum) ve sözleşme / poliçeyi seçin; sigortalı hastada "Provizyon" sekmesinden provizyon alın.
4. Bölüm (poliklinik) ve hekimi seçin; hekim listesi çalışma planına göre gelir.
5. "Kalemler" sekmesinde hizmetleri ekleyin; iskonto kurum eşiğini aşıyorsa "İskonto Onayı İste" akışına gidin.
6. **💾 Kaydet**: protokol numarası otomatik verilir.
7. Ödeme alınacaksa listede **＋ Tahsilat**; gün sonunda **⇢ Belge Kes** ile fatura / tahakkuk üretin.

## Durumlar
- **Tamamlanma yüzdesi** kartın üstündeki aşama şeridinden gelir (provizyon, ücretlendirme, tahsilat, dönüşüm). %100 = başvuru kapanmış.
- Dönüşüm: Açık / Kısmi / Kapanan. Tahsilat: alınan tutar Genel Toplam'dan azsa açık borç vardır.

## Yetki
- Liste ve kart **belge** yetkisi; başvuru tahsilatı **kasa_islem**; belge kesme `belge.donustur`; iptal `belge.iptal`.
- İskonto tavanı rolün `basvuru.iskonto` değerinden gelir; kurum eşiğinin (varsayılan %10) üstündeki iskonto onaylanmış talep ister ve kişi kendi talebini onaylayamaz.
- Hekim kullanıcı yalnız kendi hastalarını görür; banko / yönetici tümünü görür. Şube süzgeci sunucuda uygulanır.

## Sık görülen hata ve uyarılar
- **"Bu hastanın kapanmamış başvurusu var - o başvuru açıldı."** → bilgi mesajı; açık protokole devam edin, ikinci protokol açmayın.
- **"Önce hasta seçin." / "Önce başvuruyu kaydedin." / "Önce sigorta şirketini seçin."** (provizyon sekmesi) → sırayı tamamlayın: hasta → kaydet → sigorta → provizyon.
- **"Poliçe numarası girilmeli."** → Kurum / Ödeyen satırında poliçe no boş.
- **İskonto eşiği aşıldı (IS_KURALI 422)** → eşik üstü iskonto onaysız yazılamaz; iskonto talebi açın.
- **Silinemez (IS_KURALI)** → belgenin izi var (tahsilat, dönüşüm); "İptal Et" kullanın.
- **CAKISMA (409)** → aynı kartı başka kullanıcı değiştirdi; kartı yenileyip tekrar kaydedin.

## Diğer modüllere etkisi
- Muayene başvurudan doğar; Hekim Çalışma Listesi satırları başvurudur.
- Lab ve radyoloji istemleri başvuruya bağlanır; diş seansı ücreti başvuru satırına düşer.
- Tahsilat kasa modülüne, kesilen belge muhasebe fişine ve e-Belge kuyruğuna gider.
- Başvuru açılınca e-Nabız "Hasta Kayıt (Kabul)" paketi, kapanınca "Hasta Çıkış" paketi üretilir.

## Yapılmaması gerekenler
- Açık başvurusu olan hastaya aynı gün ikinci protokol açmayın (ücretler bölünür, tahsilat karışır).
- Eşik üstü iskontoyu kalem satırına elle yazmaya çalışmayın; sistem reddeder.
- Kurum bilgisi eksikken "Belge Kes" yapmayın; fatura kesilemez.

## Örnek sorular
- Hastaya başvuru nasıl açılır?
- Protokol numarası nereden verilir?
- Kapanmamış başvurusu var uyarısı ne demek?
- Başvuruda ödeyen kurumu ve poliçeyi nereden seçerim?
- Provizyon nereden alınır?
- Başvurudan tahsilat nasıl alınır?
- Başvuruyu faturaya nasıl çeviririm?
- Başvuru neden silinmiyor?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Klinik.ts (belge / basvuru girdisi)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (basvuru-liste)
- web/src/bilesenler/belge/basvuru/*.tsx, web/src/sayfalar/BelgeKarti.tsx
- dokuman/00_TARIHCE.md (788 açık başvuru, 783 iskonto kuralları)
- db/447_ai_rehber.sql (basvuru-ac konusu)

## Doğrulama durumu
Liste, aksiyonlar ve açık başvuru kuralı kod incelemesiyle yazıldı. Başvuru kartındaki alanların zorunluluk işaretleri ve sekme adları kart kataloğunda doğrulanamadı; insan doğrulaması bekliyor.
