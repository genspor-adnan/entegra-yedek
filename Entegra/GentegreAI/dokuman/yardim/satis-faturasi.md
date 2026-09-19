---
id: satis-faturasi
baslik: Satış faturası kesme (ERP)
modul: erp_satis
ekran: belge
rota: /belge
surec: satis
roller: satis, muhasebe, on_muhasebe
dil: tr
surum: 1
urun_modu: 1
yetki: belge
erisim: kullanici
ozet: Satış › Satış Faturaları ekranında cariye fatura açma, kalem girme, kaydetme / kesinleştirme, silme-iptal ayrımı ve e-Fatura / e-Arşiv menüsü.
guncelleme: 2026-09-19
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Satış faturası, müşteriye (cari) kesilen belgedir; kalemleri stok / hizmet satırlarıdır, tutarları sunucuda hesaplanır, kesinleşince stok, cari ve muhasebe fişini etkiler. Sipariş ve irsaliye faturaya dönüşür; fatura zincirin sonudur, başka belgeye dönüşmez. HBYS kurulumunda aynı ekran **Kurumlar & Sigorta › Faturalar** adıyla vardır.

## Ekrana giriş yolları
- Sol menü **Satış › Satış Faturaları** (`/belge`, yalnız ERP modu).
- **Satış › Satış Siparişleri** ya da **Satış İrsaliyeleri** listesinde **⇢ Belge Kes / 🧾 Faturaya Dönüştür**.
- Komut paleti (Ctrl+K) › "Fatura". Kart adresi `/belge/[kayıt no]`.

## Ön koşullar
- **belge** yetkisi (Gör / Ekle / Değiştir / Sil); kesinleştirme `belge.kesinlestir`, iptal `belge.iptal`, e-Belge `ebelge.gonder` aksiyon yetkileri.
- Cari kartı kayıtlı olmalı (VKN / TCKN, unvan, vergi dairesi; e-Belge için adres zorunlu).
- Stok / hizmet kartları ve KDV oranları tanımlı; fiyat listesi kullanılıyorsa satış fiyatı listeden gelir.
- Firma / şube bilgileri (gönderici unvan, VKN, adres) e-Belge için dolu olmalı.

## Alanlar
Başlık: cari (müşteri), belge tarihi, belge no (seri + numara), belge tipi (Fatura / İade / Revize), vade, şube, açıklama; e-Belge kutusu: senaryo, ETTN / Zarf No, Alias (URN), XSLT tasarımı, durum.
Sevk bilgileri: Sevk Adresi, Sevk Zamanı, Teslim Şekli, Taşıyıcı Bilgileri, Araç Plakası.
Kalem penceresi: stok / hizmet, miktar, giriş birimi, fiyat (KDV Dahil / Hariç), iskonto, satır açıklaması, döviz ve günlük kur (değiştirilebilir), yerel para karşılığı.
Kart düğmeleri: **💾 Kaydet**, **✖ İptal (kaydetme)**, **↩ Geri Dön**; sekmeler: kalemler, tahsilat, e-Fatura / e-Arşiv, sevk / e-İrsaliye, türetilen belgeler (adlar doğrulanacak).

## Liste kolonları ve çipler
Kolonlar: Belge No · Tarih · Cari · Matrah · KDV · Genel Toplam · Şube · Fiş No · Vade · Konusu; altta Matrah, KDV ve Genel Toplam toplamı. Tür kolonları bu ekranda gizlidir (hepsi satış faturası).
Çipler: **Tümü · Fatura · İade** (iade ayrı tür değil, belge tipidir). Araç çubuğunda **E-Fatura** kutusu (menü).

## İşlemler (düğmeler)
- `belge.yeni` **＋ Yeni** (Ctrl+N), `belge.ac` **Belgeyi Aç** (Enter), `belge.sil` **🗑 Sil** (Del; yalnız izi olmayan belge).
- `belge.kesinlestir` **Kesinleştir**, `belge.iptal` **Belgeyi İptal Et** (sağ tuş; kesin / izli belgede).
- E-Fatura menüsü: `ebelge.hazirla` **Hazırla**, `ebelge.onizle` **Ön İzle**, `ebelge.gonder` **Gönder**, `ebelge.seri` **Seri Değiştir**, `ebelge.sifirla` **Hazırı Geri Al**, `ebelge.iptal` **İptal Et / İptal Talebi**, **PDF / HTML / XML Kaydet**, `ebelge.durum` **Durum Sorgula**, `ebelge.mesajlar` **Mesaj Geçmişini Göster**.
- `belge.fis-gor` **Muhasebe Fişini Aç**, `belge.kaynak-ac` **Kaynak Belgeyi Aç**, `belge.hedef-ac` **Hedef Belgeyi Aç**, `belge.uts-bildir` **🩺 ÜTS Bildir** (tıbbi cihaz), `genel.yazdir` **🖨️ Yazdır**.

## Adım adım
1. **Satış › Satış Faturaları › ＋ Yeni**.
2. Cari alanından müşteriyi seçin; kayıtlı değilse önce **Cari › Müşteriler**'den kart açın.
3. Kalemler sekmesinde satır ekleyin: stok / hizmet, miktar, fiyat (Dahil / Hariç), iskonto; dövizli belgede kuru kontrol edin.
4. İskonto ve KDV'yi gözden geçirip **💾 Kaydet**; belge numarası seri sayacından verilir.
5. Belge kesinleşecekse **Kesinleştir** (stok / cari / fiş etkisi).
6. e-Fatura / e-Arşiv için listede belgeyi seçin › E-Fatura menüsü › **Hazırla** → **Ön İzle** → **Gönder**; sonucu **Durum Sorgula** ve **Satış › e-Belge** kuyruğundan izleyin.
7. Yanlış belge: gönderilmemiş ve izsizse **🗑 Sil**; aksi hâlde **Belgeyi İptal Et** ya da iade faturası.

## Durumlar
- Taslak (kesinleşmemiş) → Kesin; İptal. e-Belge: hazırlanmadı → hazırlandı → gönderildi → GİB kabul / ret; ret durumunda mesaj geçmişinde yazar.
- Belge tipi: Fatura / İade / Revize.

## Yetki
- Liste ve kart **belge**; kesinleştirme, iptal, dönüşüm ve e-Belge ayrı aksiyon yetkileri; dışa aktarma `veri.disa-aktar`.
- Maliyet kolonu (Ort. Maliyet) alan yetkisine bağlıdır; yetkisiz rolde hiç gelmez. Şube süzgeci sunucuda.

## Sık görülen hata ve uyarılar
- **Silinemez (IS_KURALI)** → belgenin izi var (kesin, e-Belge, tahsilat, dönüşüm); iptal edin.
- **"Önce belgeyi kaydedin."** → e-Belge / sevk sekmeleri kayıtlı belge ister.
- **Aynı belge numarası** → seri + numara ikinci kez girilemez (mükerrer fatura cari ve KDV'yi iki kere yazar).
- **VKN / TCKN yanlış** → GİB gönderimi reddeder; cari kartını düzeltip **Hazırı Geri Al** › tekrar hazırlayın.
- **Alıcı e-Fatura mükellefi** → belge e-Arşiv değil e-Fatura olarak gider; senaryo sistemce belirlenir.
- **"… henüz bağlanmadı"** uyarıları → o ucu bu sürümde kapalı olan işlem (ör. tasarım listesi, XML indirme); yönetici bilgilendirilmeli.
- **CAKISMA (409)** → kartı yenileyip değişikliği tekrar yapın.

## Diğer modüllere etkisi
- Kesinleşen fatura stok çıkışı, cari borç ve muhasebe fişi üretir; tahsilat Kasa İşlemleri'nden belgeye dağıtılır (dağıtılmazsa cari düşer ama fatura açık görünür).
- e-Belge kuyruğu (**Satış › e-Belge**) gönderim ve GİB yanıtını tutar; gelen e-Belgeler **Alış › Gelen Kutusu**'nda.
- Tıbbi cihaz satırları ÜTS bildirimine, ilaç alışları İTS bildirimine konu olur.

## Yapılmaması gerekenler
- Kalem tutarını elle "düzeltmeyin"; miktar, fiyat ve iskonto alanlarını kullanın, toplamlar sunucuda hesaplanır.
- Gönderilmiş e-Belgeyi silmeyin; iade ya da iptal talebi ile düzeltin.
- Faturayı başka belgeye dönüştürmeye çalışmayın; dönüşüm sipariş ve irsaliyeden faturaya doğrudur.

## Örnek sorular
- Cariye fatura nasıl kesilir?
- Fatura kalemine iskonto nasıl girilir?
- Fatura neden silinmiyor?
- e-Fatura nasıl gönderilir?
- e-Arşiv mi e-Fatura mı gideceğine kim karar veriyor?
- Faturayı nasıl iptal ederim?
- Siparişten fatura nasıl oluşturulur?
- Fatura numarası nereden verilir?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Ticari.ts (Satış Faturaları, Faturalar)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (belge-liste, belge-kart), KaynakKatalogu.Belge.cs
- web/src/sayfalar/BelgeKarti.tsx, web/src/bilesenler/belge/BelgeSekmeleri.tsx, KalemPenceresi.tsx, BelgeAracCubugu.tsx
- dokuman/01_API_SOZLESMELERI.md §4 (belge kaydetme), §9 (e-Belge uçları)
- db/447_ai_rehber.sql (satis-fatura, efatura-gonder, cari-kart konuları)

## Doğrulama durumu
Liste, aksiyonlar ve e-Belge menüsü kod incelemesiyle yazıldı. Belge kartı sekme adları ve zorunlu alan işaretleri kart tanımında doğrulanamadı; insan doğrulaması bekliyor.

## Kod-belge çelişkileri
- Rehber kataloğu (447) "Değişiklikleri Kaydet" düğmesinden söz eder; kartta düğme adı **💾 Kaydet**'tir.
- Rehber "e-Fatura Gönder"i kart aksiyonu olarak verir; listede adımlar ayrı düğmelerdir (Hazırla › Ön İzle › Gönder), kartta tek **e-Fatura Gönder** düğmesi vardır.
