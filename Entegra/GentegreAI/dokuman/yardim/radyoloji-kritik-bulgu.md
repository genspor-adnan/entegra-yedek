---
id: radyoloji-kritik-bulgu
baslik: Kritik bulgu bildirimi ve takibi (Radyoloji › Kritik Bulgular)
modul: radyoloji
ekran: radyoloji-kritik
rota: /radyoloji-kritik
surec: radyoloji
roller: radyolog, radyoloji teknisyeni, hekim
dil: tr
surum: 1
urun_modu: 2
yetki: radyoloji
erisim: kullanici
ozet: Kritik bulgu nedir, radyolog nasıl bildirir (bulgu, bildirilen kişi, yol, geri bildirim), neden bildirim kaydı olmadan rapor onaylanamaz, Kritik Bulgular listesindeki Bildirilmedi · Teyit Bekleyen · Teyitli · Kapatılan çipleri ve teyit alınınca kapatma.
guncelleme: 2026-11-15
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
**Kritik bulgu**, hastayı bekletmeyecek bir radyolojik bulgudur: pnömotoraks, akut kanama, serbest hava, kitle şüphesi gibi.
Bildirim mekanizması, radyoloğun isteyen hekime **anında haber verdiğini kayıt altına alır**: kime, ne zaman, hangi yolla söylendi,
karşı taraf ne dedi. Rapor okunana kadar beklenmez; denetimde (SKS / JCI kritik sonuç bildirimi şartı) izi vardır.

## Ekran kılavuzu

### Kritik bulgu nedir
Hastayı bekletmeyecek bulgu: pnömotoraks, akut kanama, serbest hava, kitle şüphesi vb. Rapor okunana kadar beklenemez; radyolog isteyen hekime hemen haber verir ve bunu sistemde kaydeder. Amaç hasta güvenliği ve "kime, ne zaman, nasıl söylendi" sorusunun izlenebilir olması (SKS · JCI kritik sonuç bildirimi şartı).

### Nasıl bildirilir
- Rapor ekranında sağ panelde **Bu tetkikte kritik bulgu var** kutusu işaretlenir. Şablonda "kritik ifade geçerse sor" açıksa Sonuç bölümünde kritik ifade yazılınca sistem kendisi sorar.
- **⚠ Kritik Bulgu Bildir** düğmesi küçük bir form açar: bulgu özeti, haber verilen kişi (isteyen hekim / servis), yol (**Telefon · SMS · Yüz yüze · e-Posta**), karşı tarafın geri bildirimi.
- Kaydedilince zaman ve kaydeden kullanıcı yazılır. Aynı tetkikte birden çok bildirim olabilir (ulaşılamadı, ikinci arama vb.).

### Onay kapısı
Kritik işaretli tetkikte **bildirim kaydı olmadan rapor onaylanamaz ve e-imzalanamaz**. Boş bulgu ya da boş "bildirilen kişi" kayıt sayılmaz. Mesaj: "Kritik bulgu bildirimi kaydedilmeden rapor onaylanamaz."

### Takip ve kapatma
**Radyoloji › Kritik Bulgular** listesi kritik işaretli istemleri çiplerle ayırır:
- **Bildirilmedi**: işaret var, bildirim kaydı yok - en tehlikeli durum, önce bu temizlenir.
- **Teyit Bekleyen**: haber verildi, karşı taraf "aldım" demedi.
- **Teyitli** ve **Kapatılan**.
İsteyen hekim teyit edince satır seçilip **✔ Kapat (teyit alındı)** ile kapatılır; bildirim kaydı yoksa kapatma reddedilir ("Bu istemde bildirim kaydı yok - önce kritik bulgu bildirimini kaydedin.").

### Nerede görünür
Rapor üst şeridinde ve çıktıda kritik bulgu rozeti; Radyoloji panosunda açık kritik bulgu sayacı; hekim tarafında istemin durumu. Teletıp ve e-Nabız içeriğine ayrıca gitmez - kurum içi güvenlik sürecidir.

### Değişmez kurallar
- Kritik işaretini kaldırmak için önce kaydedilmiş bildirim kapatılır.
- Bildirim kayıtları silinmez, yalnız kapatılır: "ne zaman haber verildi" sorusunun cevabı korunur.

## Adım adım
1. Raporda kritik bulgu görüldü → **Bu tetkikte kritik bulgu var** işaretle.
2. İsteyen hekimi ara / yaz → **⚠ Kritik Bulgu Bildir** → bulgu, kişi, yol, geri bildirim → **Kaydet**.
3. Raporu normal akışla onayla (kayıt yoksa onay kapısı durdurur).
4. Hekim teyit edince **Radyoloji › Kritik Bulgular** → satır → **✔ Kapat (teyit alındı)**.

## Sık karşılaşılan sorunlar
- **"Kritik bulgu bildirimi kaydedilmeden rapor onaylanamaz."** → önce ⚠ Kritik Bulgu Bildir ile kaydı girin.
- **"Bu istemde bildirim kaydı yok - önce kritik bulgu bildirimini kaydedin."** → kapatmadan önce bildirim kaydı gerekir.
- **Kritik işareti kaldırılamıyor** → açık bildirimi kapatın, sonra işareti kaldırın.

## Örnek sorular
- Kritik bulgu nedir?
- Kritik bulgu nasıl bildirilir?
- Kritik bulgu bildirimi olmadan rapor neden onaylanmıyor?
- Teyit alınınca ne yapılır?

## Kaynaklar
- web/src/sayfalar/RadyolojiRapor.tsx (kritik kutusu, bildirim formu), listeTanimlari.Radyoloji.ts (radyoloji-kritik çipleri)
- api/src/Gentegre.Api/Uclar/RadyolojiUclari.OnayVeBulgu.cs (/istem/{id}/kritik-bulgu, /kritik-kapat)
- db/1206_radyoloji_onay_kritik_dolu.sql, 1342 (fn_radyoloji_rapor_onaylanabilir)

## Doğrulama durumu
Kod incelemesi ve 15.11.2026 kullanıcı açıklamasından yazıldı; insan doğrulaması bekliyor.
