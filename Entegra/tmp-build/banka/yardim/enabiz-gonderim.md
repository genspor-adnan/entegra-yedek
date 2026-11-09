---
id: enabiz-gonderim
baslik: e-Nabız gönderim kuyruğu
modul: enabiz
ekran: enabiz-paket
rota: /enabiz-paket
surec: enabiz
roller: bilgi_islem, kayit_kabul, hekim
dil: tr
surum: 1
urun_modu: 2
yetki: entegrasyon
erisim: kullanici
ozet: e-Nabız › Gönderim Kuyruğu ekranında paketlerin durumu, eksik alan düzeltme ve kaynaktan yeniden üretme, gönderme, iptal; Veri Kalitesi panosu ve Kod Eşleme.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Sağlık Bakanlığı e-Nabız (USS) paketleri iş olayları oldukça sistem tarafından üretilir ve kuyruğa girer: başvuru açılınca Hasta Kayıt (101), muayene tamamlanınca Muayene Bilgisi (103) ve Hasta Çıkış (106), sonuç onaylanınca Laboratuvar Sonuç (105), işlem yapılınca Hasta İşlem Bilgisi (102). Bu ekran "şu an ne bekliyor" sorusunun cevabıdır; paket elle düzeltilmez, kaynağı düzeltilip yeniden üretilir.

## Ekrana giriş yolları
- Sol menü: **e-Nabız › Gönderim Kuyruğu** (ekran başlığı "e-Nabız Kuyruğu"); aynı grupta **Veri Kalitesi** (`/enabiz-pano`) ve Ayarlar › **Kod Eşleme** (`/enabiz-kod-esleme`).
- Komut paleti (Ctrl+K) › "e-Nabız".

## Ön koşullar
- **entegrasyon** yetkisi (Gör kuyruk / pano; Değiştir gönder / yeniden üret / iptal).
- USS entegrasyon hesabı tanımlı ve açık olmalı; kapalıyken paketler üretilir ama gönderilmez (kapı açılınca gönderilir).
- Yerel kodların SKRS karşılıkları **Kod Eşleme**'de tanımlı olmalı (klinik, başvuru türü, geliş / çıkış şekli, muayene türü, sonuç birimi, tetkik, radyoloji modalitesi).

## Alanlar
Liste satırının altında açılan paket kartı (salt okunur): her USS alanı için alan adı · değer · kaynak alan · SKRS listesi · geçerli mi · sorun; geçersiz alanlar üstte; son 20 gönderim denemesi (zaman, sonuç, HTTP kodu, USS kodu / mesajı, süre).
Kod Eşleme kartı: Eşleme Türü, Bölüm (klinik eşlemesi için), Yerel Kod, SKRS listesi / kodu / adı, Aktif.

## Liste kolonları ve çipler
Kolonlar: Paket No · USS · Paket Türü · Hasta · Hekim · Olay (tarih) · Deneme · Hata · USS Kimlik · Başvuru Id.
Çipler: **Eksik Alan · Bekleyen · Gönderildi · Hatalı · Tümü**; tarih süzgeci olay tarihine göre.
"Eksik Alan" bir hata değildir: paket üretilmiş ama zorunlu alanı boş olduğu için kuyruğa girmemiştir.

## İşlemler (düğmeler)
- `enabiz.gonder` **📤 Şimdi Gönder**: zamanlanmış işi beklemeden gönderir.
- `enabiz.yeniden-uret` **↻ Kaynaktan Yeniden Üret**: hasta kartı / başvuru / muayene düzeltildikten sonra paketi yeniden üretir; kalan eksikleri mesajda sayar.
- `enabiz.iptal` **✖ İptal Et** (sağ tuş): onay sorar; gönderilmeyecek paketi kapatır.
- `genel.yazdir` **🖨️ Yazdır**.
- Veri Kalitesi panosunda her sayaç ilgili listeye götürür ("neyi düzeltirsem kaç paket kurtulur").

## Adım adım
1. **e-Nabız › Gönderim Kuyruğu**'nu açın; önce **Eksik Alan** ve **Hatalı** çiplerine bakın.
2. Satırı seçin; altta açılan kartta geçersiz alanı ve "sorun" açıklamasını okuyun (ör. çıkış şekli boş, klinik kodu eşlenmemiş).
3. Eksiği kaynağında düzeltin: hasta kartı (kimlik, doğum tarihi, cinsiyet), başvuru (kurum, klinik) ya da muayene (çıkış şekli, tanı). Kod eksikse **Kod Eşleme**'ye satır ekleyin.
4. Kuyruğa dönüp **↻ Kaynaktan Yeniden Üret**.
5. Paket "Bekleyen"e düşünce zamanlanmış iş gönderir; acilse **📤 Şimdi Gönder**.
6. USS reddettiyse "Hata" kolonundaki USS mesajını okuyun, düzeltip yeniden üretin.

## Durumlar
- **Eksik Alan (0)**: kuyruğa girmedi. **Bekliyor (1)**: gönderilecek. **Gönderiliyor (2)**. **Gönderildi (3)**: USS kimliği alındı. **Hatalı (4)**: USS ret / ağ hatası; deneme sayısı artar.

## Yetki
- Tümü **entegrasyon**: kuyruk, pano ve kart Gör; gönder / yeniden üret / iptal Değiştir. Kod Eşleme kartı da aynı yetkidedir.

## Sık görülen hata ve uyarılar
- **"Eksik Alan"** → paket üretildi, zorunlu alan boş; kaynağı düzeltip yeniden üretin.
- **USS "… eksik elemanlar var: CIKIS_SEKLI"** gibi mesajlar → muayene kartında Çıkış Şekli boş bırakılmış; artık muayene tamamlanırken engellenir, eski paketlerde yeniden üretin.
- **Eşlenmemiş kod** → USS bilmediği kodu reddeder; Kod Eşleme'ye ekleyin.
- **"Silme paketi üretilemedi."** (IS_KURALI) → iptal edilen kayıt için silme paketi oluşturulamadı; kaynağı kontrol edin.
- **"Önce bir paket seçin."** → satır seçmeden düğmeye basıldı.

## Diğer modüllere etkisi
- Muayene tamamlama e-Nabız'a bağlı değildir: paket üretilemese de muayene kapanır; eksik burada görünür.
- Hasta kartındaki kimlik / doğum tarihi / cinsiyet, başvurudaki kurum ve klinik, muayenedeki tanı ve çıkış şekli doğrudan paket alanıdır.
- Kod Eşleme yoksa paketler "Eksik Alan"da birikir; Veri Kalitesi panosu eksikleri alan bazında sayar.

## Yapılmaması gerekenler
- Paketi elle düzeltmeye çalışmayın; kart salt okunurdur ve USS'ye giden veri ile hasta dosyası ayrışırdı.
- "Eksik Alan"ı hata sanıp iptal etmeyin; düzeltip yeniden üretin.
- Kendi SKRS kodu uydurmayın; kod listeleri SKRS'ye birebir uydurulur.

## Örnek sorular
- e-Nabız paketi neden gönderilmedi?
- "Eksik alan" ne demek, nasıl düzeltirim?
- Paketi nasıl yeniden üretirim?
- e-Nabız kod eşlemesi nereden yapılır?
- Hangi olaylar e-Nabız paketi üretir?
- Hatalı paketteki USS mesajını nerede görürüm?
- Veri kalitesi panosu neyi gösterir?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Enabiz.ts
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (enabiz-liste)
- api/src/Gentegre.Cekirdek/Katalog/KaynakKatalogu.Saglik.Enabiz.cs, KartKatalogu.Saglik.LabIstem.cs (enabiz-kod-esleme)
- api/src/Gentegre.Api/Uclar/EnabizUclari.cs, MuayeneUclari.cs (tamamlama → paket); web/src/sayfalar/liste/enabizAksiyonlari.ts
- dokuman/01_API_SOZLESMELERI.md §9.16; db/415_enabiz_cekirdek.sql, db/452_ai_rehber_enabiz_menusu.sql

## Doğrulama durumu
Kod incelemesiyle yazıldı.
