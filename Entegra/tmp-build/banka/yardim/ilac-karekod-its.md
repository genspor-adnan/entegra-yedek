---
id: ilac-karekod-its
baslik: İlaç kataloğu, karekod okutma ve İTS bildirimi
modul: stok
ekran: ilac
rota: /ilac
surec: its
roller: eczaci, depo_gorevlisi, satinalma, hekim
dil: tr
surum: 1
urun_modu: 2
yetki: katalog
erisim: kullanici
ozet: İlaç Kataloğu, mal kabulde karekod okutma (Karekod / Seri sekmesi) ve İTS Bildirimleri kuyruğu; eczane ekranlarına kısa bakış.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
İlaç kataloğu barkod (GTIN) esaslıdır; e-reçete ve sarf bu kataloğu okur. Kutular mal kabulde karekod okutularak sayılır, kabul kararından sonra İTS'e mal alım bildirimi kuyruğa alınır ve **İTS Bildirimleri** ekranından gönderilir / izlenir. İTS ilaç içindir; tıbbi cihaz bildirimi ÜTS ile ayrı ekrandadır.

## Ekrana giriş yolları
- **Muayene › Muayene Ayarları › İlaç Kataloğu** (`/ilac`, salt katalog + fiyat girişi).
- **Satınalma › Mal Kabul** (`/satinalma-kabul`): tutanak kartında **Karekod / Seri** ve **İTS Bildirimi** sekmeleri.
- **Stok & Hizmet › İTS › Bildirimler** (`/its-bildirim`): bildirim kuyruğu.
- Eczane grubu: Eczacı Kontrolü, Ünite Doz, Hazırlama, İadeler, İmha, Kontrollü Defter, Miad & Tüketim.

## Ön koşullar
- İlaç kataloğu senkronla dolar; fiyat dolmaz (TİTCK fiyat listesi kurumsal hesap ister) — fiyat **₺ Fiyat Gir** ile elle girilir.
- Karekod okutmak için **satinalma.kabul** Değiştir; İTS bildirimi için `uts.bildir` aksiyon yetkisi; kuyruk ekranı **stok**.
- GTIN'in stok kartıyla eşleşmesi için ilaç kataloğu stok bağı ya da kurumun stok barkod listesi dolu olmalı; yoksa her kutu "beklenmeyen" çıkar.
- Gerçek gönderim için İTS entegrasyon hesabı aktif olmalı; değilse bildirim kuyrukta bekler.

## Alanlar
İlaç Kataloğu (salt görünüm): Barkod, Kısa Ad, İlaç, Etken Madde, ATC, Fiyat, Kamu Fiyatı, Aktif.
Karekod / Seri sekmesi (salt okunur, okuyucudan dolar): İlaç, GTIN, Seri No, Lot / Parti, SKT, Durum; üstte "okutulan / beklenen" sayacı (payda muayenede sayılan miktar, yalnız karekodlu kalemler).
İTS Bildirimi sekmesi (salt okunur): Durum, Kutu, Kalem, Gönderen GLN, İTS Bildirim No, Test, Deneme, Hata, Not.

## Liste kolonları ve çipler
İTS Bildirimleri: İşlem (tarih) · Karşı GLN · Karşı Taraf · Belge · İTS No · Deneme · Hata · Oluşturma. Çipler: **Bekleyen · Gönderildi · Hatalı · Tümü**.
Mal Kabul listesinde "Karekod" kolonu ve **"Karekod eksik"** çipi; "İTS" rozeti (— / Bildirilmedi / Taslak / Kuyrukta / Gönderiliyor / Gönderildi / HATALI) ve **"İTS bildirilmedi"** çipi.

## İşlemler (düğmeler)
- İlaç Kataloğu: `ilac.fiyat` **₺ Fiyat Gir** (tutar sıfırdan büyük), **🖨️ Yazdır**.
- Mal Kabul: `satinalma-kabul.karekod` **🔦 Karekod Oku** (kutular tek tek), `satinalma-kabul.karekod-ozet` **📋 Karekod Özeti** (sağ tuş), `satinalma-kabul.its-gonder` **📡 İTS Bildir** (muayene bittikten sonra kuyruğa alır).
- İTS Bildirimleri: `its.gonder` **📤 Şimdi Gönder**, `its.iptal` **✖ İptal Et** (sağ tuş; yalnız taslak / kuyrukta / hatalı; gerekçe zorunlu), **🖨️ Yazdır**.

## Adım adım
1. **Satınalma › Mal Kabul**'de tutanağı açın; kalemleri sayın.
2. **🔦 Karekod Oku** ile her kutuyu okutun. Her kod kendi sonucuyla döner: **yazıldı** (eşleşti), **mükerrer** (aynı GTIN + seri daha önce okutulmuş), **beklenmeyen** (katalogda yok ya da bu tutanakta o kalem yok; kayda geçer, işaretlenir), **okunamadı** (yazılmaz).
3. Miad çelişkisi uyarıysa kutu üstündeki tarih doğrudur; muayene satırındaki elle yazılan SKT'yi düzeltin.
4. Muayene kararını verin (Kabul / Kısmi Kabul / Ret). Açık tutanak bildirilemez.
5. **📡 İTS Bildir**: kabul edilen kutular bildirime girer; reddedilen ve beklenmeyen kutular ayrı bir iptal kaydına taşınır, not alanına sebebi yazılır.
6. **Stok & Hizmet › İTS › Bildirimler**'de satırı seçip **📤 Şimdi Gönder**; hata varsa "Hata" kolonunu okuyup düzeltin ve tekrar gönderin.

## Durumlar
- İTS bildirimi: **Hazırlanıyor (0)** → **Bekliyor (1)** → **Gönderiliyor (2)** → **Gönderildi (3)** / **Hatalı (4)** / **İptal (5)**. Liste en ileri bildirimi gösterir (iptal hariç). "Test" bayrağı test ortamına giden bildirimi ayırır.
- Karekod satırı: yazıldı / mükerrer / beklenmeyen; miadı geçmiş kutu ayrıca işaretlenir.

## Yetki
- Katalog: **katalog** Gör, fiyat girişi Değiştir. Mal kabul karekod: **satinalma.kabul**. İTS bildir: `uts.bildir`. Kuyruk: **stok** Gör / Değiştir.
- Kontrollü Defter salt okunurdur: satır silinmez, düzeltme ayrı satırla yapılır (**eczane.kontrollu**).

## Sık görülen hata ve uyarılar
- **"En az bir karekod okutulmalı."** (DOGRULAMA) → boş bildirim açılmaz.
- **"Muayenesi tamamlanmamış tutanak İTS'e bildirilemez"** / **"Kararı verilmiş tutanağa karekod eklenemez"** → sırayı koruyun: okut → karar → bildir.
- **"zaten kuyrukta"** → aynı tutanak ikinci kez kuyruğa alınmaz.
- **"Kuyruğa alınacak taslak bildirim yok."** → kabul edilen karekodlu kutu yok (tamamı ret ya da hiç okutulmamış).
- **"İptal gerekçesi zorunlu."** / gönderilmiş bildirim iptal edilemez → İTS'te kayıt oluşmuştur; geri alma ayrı bir bildirim türüdür (iade / deaktivasyon).
- **"Tutar sıfırdan büyük olmalı."** (fiyat girişi).
- Her kutu "beklenmeyen" çıkıyor → stok kartları kataloğa / barkod listesine bağlı değil.

## Diğer modüllere etkisi
- Kabul edilen kutular stok girişini ve seri / lot izini oluşturur; miad ekranı (Eczane › Miad & Tüketim) bu verilere bakar.
- Reçete ve sarf ilaç kataloğundaki barkodu okur; fiyat girilmemiş ilacın çıkışı fiyatsız kalır.
- ÜTS (tıbbi cihaz) bildirimi belge listesindeki **🩺 ÜTS Bildir** ile ayrı kuyrukta yürür.

## Yapılmaması gerekenler
- Karekodu elle satır olarak eklemeyin; sekme salt okunurdur, kutu okutulmadan "okutuldu" denmez.
- Gönderilmiş bildirimin satırını silmeye çalışmayın; karşı tarafta kayıt vardır.
- Beklenmeyen kutuyu görmezden gelmeyin: ya katalog güncellenmeli ya sevkiyat sorgulanmalı.

## Örnek sorular
- Mal kabulde karekodu nasıl okuturum?
- "Mükerrer" karekod ne demek?
- İTS bildirimini nasıl gönderirim?
- İTS bildirimi neden iptal edilemiyor?
- İlaç fiyatını nereden girerim?
- Her kutu neden "beklenmeyen" çıkıyor?
- İTS ile ÜTS farkı ne?
- Miad çelişkisi uyarısında ne yapmalıyım?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Yonetim.ts (ilac), listeTanimlari.Klinik.ts (its-bildirim), listeTanimlari.Satinalma.ts (satinalma-kabul), listeTanimlari.Eczane.ts
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (ilac-liste, its-liste, satinalma-kabul-liste)
- api/src/Gentegre.Cekirdek/Katalog/KaynakKatalogu.Onam.cs (ilac), KaynakKatalogu.Saglik.LabIts.cs (its-bildirim)
- api/src/Gentegre.Api/Uclar/ItsUclari.cs, SatinalmaUclari.Its.cs; web/src/sayfalar/liste/itsAksiyonlari.ts, ilacAksiyonlari.ts
- dokuman/00_TARIHCE.md (734/735 Karekod / Seri, 736 İTS Bildirimi sekmesi); db/427_its_bildirim.sql

## Doğrulama durumu
Kod incelemesiyle yazıldı. Eczane ekranlarının karekod okutma akışı (ünite doz teslimi) bu belgede ele alınmadı; kaynak bulunamadı.
