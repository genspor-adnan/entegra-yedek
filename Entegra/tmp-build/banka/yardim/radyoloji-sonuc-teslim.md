---
id: radyoloji-sonuc-teslim
baslik: Radyoloji sonucunu teslim etme (rapor, film, CD, portal, e-Nabız)
modul: radyoloji
ekran: radyoloji-teslim
rota: /radyoloji-teslim
surec: radyoloji
roller: banko_gorevlisi, doktor_sekreteri, rad_teknisyen, radyolog
dil: tr
surum: 1
urun_modu: 2
yetki: radyoloji.teslim
erisim: kullanici
ozet: Onaylı radyoloji sonucunun hastaya ya da yakınına teslimi (rapor / film / CD / dijital), teslim alan ve kimlik kaydı, Sonuç Teslim listesi, portal erişimi ve e-Nabız 409 Radyoloji Sonuç paketi.
guncelleme: 2026-10-10
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Sonuç kişisel sağlık verisidir: kime, ne zaman, ne verildiği kayda geçmelidir. **Sonuç Teslim** listesi raporu onaylanmış ama henüz teslim edilmemiş işleri gösterir; teslimde hangi kalemlerin (rapor, film, CD, dijital) kime verildiği yazılır.

## Ekrana giriş yolları
- Sol menü **Radyoloji › Sonuç Teslim**.
- **Radyoloji › Çalışma Listesi**'nde satır seçip **📦 Sonuç Teslim Et**.

## Ön koşullar
- **radyoloji.teslim** yetkisi ve `rad.teslim` aksiyon yetkisi.
- Rapor onaylı olmalı (onaysız rapor teslim listesine düşmez).

## Liste ve çipler
Çipler: **Teslim Bekleyen · Teslim Edilen · Tümü**. Düğmeler: **📦 Teslim Et**, **👁 İstemi Aç**, **📄 Raporu Aç**.

## Teslim penceresi
- **Teslim edilen (zorunlu, en az biri)**: Rapor (basılı) · Film · CD / DVD · Dijital bağlantı / e-posta. Kabulde "Sonuç için CD hazırla" işaretlendiyse CD kutusu işaretli gelir.
- **Teslim Alan (zorunlu)**: ad soyad.
- **Yakınlık**: hasta dışında biri alıyorsa (Eşi, Oğlu …).
- **Kimlik**: "Kimlik doğrulandı" kutusu.
- **Açıklama**.

## Adım adım
1. **Radyoloji › Sonuç Teslim**, çip **Teslim Bekleyen**; hastayı adı ya da Accession No ile bulun.
2. Gerekirse **🖨 Çıktı** için **📄 Raporu Aç** ile raporu yazdırın.
3. **📦 Teslim Et**; verilen kalemleri işaretleyin.
4. Teslim alanın adını yazın; hasta değilse yakınlığını yazın ve kimliğini kontrol edip **Kimlik doğrulandı**'yı işaretleyin.
5. **✔ Teslim Et** → "Teslim kaydedildi." Satır **Teslim Edilen** çipine geçer, istemin akış şeridinde **Teslim** adımı tamamlanır.

## Portal
- Kurumda hasta portalı açıksa hasta yalnız **kendi** radyoloji istemlerini ve onaylı raporlarını portaldan görür.
- Dış doktor portalı kendi gönderdiği hastaları, dış kurum portalı kendi kurumunun isteklerini görür.
- Portal hesabı verme işi yönetimdedir; bkz. `yetki-ve-erisim`.

## e-Nabız
- Rapor **onaylandığında** e-Nabız'a **409 Radyoloji Sonuç Kayıt** paketi kendiliğinden üretilir; teslimi beklemez. Onaysız rapor gönderilmez.
- Rapor bölümleri başlık + açıklama olarak gider; "yazdırılmaz" bölümler gönderilmez.
- Paketin durumu **e-Nabız › Gönderim Kuyruğu**'ndadır; hata alırsa oradan düzeltilip yeniden gönderilir. Tetkik hizmetinde LOINC kodu yoksa veri kalitesinde eksik sayılır. Ayrıntı: `enabiz-gonderim`.

## Sık karşılaşılan sorunlar
- **"Teslim alan kişi yazılmalı."** → Teslim Alan alanını doldurun.
- **"En az bir teslim kalemi seçilmeli."** → en az bir kutu işaretleyin.
- **Hasta Teslim Bekleyen'de yok** → rapor henüz onaylanmamış; radyoloğa sorun ya da Çalışma Listesi'nde **Onay Bekleyen** çipine bakın.
- **Aynı sonucun CD'si sonradan istendi** → yeni bir teslim kaydı girin; ilk kayıt geçmişte kalır.

## Yapılmaması gerekenler
- Kimliğini görmediğiniz kişiye sonuç vermeyin; yakınlık ve kimlik alanlarını boş bırakmayın.
- Teslimi kaydetmeden raporu elden vermeyin; "kime verdik" sorusu ancak kayıtla cevaplanır.

## Örnek sorular
- Radyoloji sonucu nasıl teslim edilir?
- Raporu hasta yakınına verirken ne yazmalıyım?
- CD teslimini nereye kaydederim?
- Teslim bekleyen sonuçları nereden görürüm?
- Rapor e-Nabız'a ne zaman gider?
- Hasta raporunu portaldan görebilir mi?

## Kaynaklar
- web/src/bilesenler/radyoloji/TeslimModali.tsx
- web/src/sayfalar/listeTanimlari.Radyoloji.ts (radyoloji-teslim)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.Klinik.cs (radyoloji-teslim-liste)
- api/src/Gentegre.Cekirdek/Katalog/KaynakKatalogu.Radyoloji.cs (portal koşulları)
- dokuman/00_TARIHCE.md (304, 318 teslim; 794-805 portal; 883 409 paketi)

## Doğrulama durumu
Kod incelemesiyle yazıldı. Hasta portalında radyoloji raporunun görünmesi rolün yetkisine bağlıdır; kurum kurulumunda doğrulanmalı. İnsan doğrulaması bekliyor.
