---
id: sterilizasyon-dongu-ve-paket
baslik: Sterilizasyon döngüsü, serbest bırakma ve paket kullanımı
modul: steril
ekran: steril-pano
rota: /steril-pano
surec: sterilizasyon
roller: steril_sorumlu, dis_asistan, hemsire
dil: tr
surum: 1
urun_modu: 2
yetki: steril.pano
erisim: kullanici
ozet: Diş › Sterilizasyon panosundan döngü açma, indikatör ve parametre girişi, serbest bırakma / karantina / başarısız kararı, etiket, paket okutma ve geri çağırma.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Sterilizasyon modülü setlerin (birim) kirli toplamadan steril depoya ve seansta kullanıma kadar izini tutar. Günün akışı: kirli toplama → yıkama → sayım & paketleme → **döngü** (otoklav + program) → parametre + indikatör → **serbest bırakma** → etiket → steril depo → **kullanım** (seansta barkod) → izlenebilirlik / geri çağırma. Kayıt defteri döngü serbest bırakılınca kendiliğinden oluşur.

## Ekrana giriş yolları
- Sol menü **Diş › Sterilizasyon**: **Sterilizasyon Panosu**, **Döngüler** (`/steril-dongu`), **Steril Depo · Paketler** (`/steril-paket`), **Setler · Döner Aletler** (`/steril-birim`), **Kullanım Kayıtları**, **İzlenebilirlik · Kayıt Defteri**; Ayarlar: Set tanımları, Cihazlar, Programlar, Bakım · Validasyon, Test takvimi · Kurallar.
- Döngü kartı: `/steril-dongu/[kayıt no]` (özel pencere); alan düzeltme için gizli "Döngü (kart)".
- Diş seans kartı › Malzeme & sarf › "Sterilizasyon · kullanılan paketler" kutusu.

## Ön koşullar
- Yetkiler: **steril.pano**, **steril.dongu** (döngü aç / bitir / serbest), **steril.birim** (hazırlama adımları), **steril.kullanim** (okutma), **steril.izleme**, **steril.ayar**.
- Cihaz (otoklav) aktif ve bakımı geçmemiş olmalı; program tanımlı olmalı.
- Kurum kuralları (Test takvimi · Kurallar): Bowie-Dick kuralı (uyarı / onay / engel), karantina kullanımı (uyarı / engel), biyolojik test sıklığı, raf ömrü.
- Döner alet son kullanımdan sonra yağlanmadan paketlenemez / yüklenemez.

## Alanlar
Döngü kartı: **Cihaz (zorunlu)**, Sayaç no, Program, Başlangıç / Bitiş, Durum, Operatör; Parametre: Tepe sıcaklık (°C), Plato (dk), Tepe basınç (bar), Kurutma (dk), Cihaz hata kodu; Not: Bowie-Dick onay notu, Karar notu, Onaylayan, Onay zamanı. Detay "İndikatörler": İndikatör türü (Bowie-Dick, Helix / PCD, Sınıf 4, Sınıf 5, Sınıf 6, Biyolojik, Vakum testi), Lot, Konum, Sonuç (Bekliyor / Geçti / Kaldı / İnkübasyonda), Not.
Paket: barkod (cihaz + sayaç ile benzersiz), paket türü, SKT (paket türü / set raf ömrüne göre).

## Liste kolonları ve çipler
Döngüler: Başlangıç · Cihaz · Döngü no · Program · Bitiş · Süre · Paket · Durum · Operatör · Onaylayan; çipler **Çalışıyor / bekliyor · Karantina · Serbest · Başarısız · Test · Tümü**.
Paketler: Paket barkodu · İçerik · Paket türü · Cihaz · Döngü · Steril tarihi · SKT · Kalan gün · Raf · Durum; çipler **Steril · Karantina · Sterilde · Bloke · Kullanıldı · Tümü**.
Birimler: çipler **Hazırlıkta · Steril depoda · Kullanımda · Arızalı · Döner aletler · Tümü**.

## İşlemler (düğmeler)
Pano: **♨️ Yeni Döngü** → "Yük: birim barkodu okut" → **▶ Döngüyü başlat** (BD yoksa "Onay notu"); barkod kutusu: paket → kullanım, birim → kirli.
Döngü kartı: **⏹ Döngü bitti — parametreleri kaydet**, **＋ İndikatör ekle (biyolojik / sınıf 6 / vakum)**, **✅ Serbest bırak**, **🖨 Etiketleri yazdır** (onaydan sonra).
Döngüler listesi: `steril.dongu-kart` **♨️ Döngü kartı**, `steril.dongu-yeni` **＋ Yeni döngü (pano)**, `steril.dongu-duzenle` **✎ Düzenle (parametre / not)**, `steril-dongu.sil` **🗑 Sil** (paketi olan silinmez; iptal edin), `steril.izle-dongu` **🔍 Paketleri izle**.
Paketler: `steril.izle` **🔍 İzlenebilirlik**, `steril.okut` **📷 Kullanım kaydı (okut)**, **♨️ Döngü kartı**.
Birimler: **🧺 Kirli toplandı**, **🧼 Yıkamaya al**, **🔢 Sayım**, **📦 Paketle**, **🛢 Yağlandı**, **🔧 Arıza / bakım**, **🔍 İzlenebilirlik**.
Geri çağırmalar: **🚨 Geri çağırma panosu**, **✔ Kapat**.

## Adım adım
1. Seans bitince set **🧺 Kirli toplandı** → **🧼 Yıkamaya al** → **🔢 Sayım** (eksik alet görev açar) → döner alet **🛢 Yağlandı** → **📦 Paketle**.
2. **Sterilizasyon Panosu › ♨️ Yeni Döngü**: cihaz ve program seçin, paketlenmiş birimlerin barkodunu okutun, **▶ Döngüyü başlat**. Bugün Bowie-Dick yoksa kurum kuralına göre onay notu yazın.
3. Döngü bitince kartta **⏹ Döngü bitti — parametreleri kaydet** (tepe °C, plato, basınç); döngü "indikatör bekliyor" olur.
4. İndikatör sonuçlarını girin (sınıf 5 zorunlu; biyolojik varsa "İnkübasyonda").
5. **✅ Serbest bırak**: parametre ✓ + günün BD / Helix ✓ + sınıf 5 ✓ → serbest; biri kaldı → başarısız; biyolojik bekliyorsa → karantina.
6. **🖨 Etiketleri yazdır**; paketler steril depoya, kayıt defteri satırı kendiliğinden oluşur.
7. Seansta paket barkodunu okutun (seans kartı ya da **📷 Kullanım kaydı**); paket kapanır, birim kirliye döner.
8. Biyolojik pozitif çıkarsa geri çağırma panosu açılır: etkilenen döngüler / paketler bloke, hastalar listelenir, hekim onayıyla bilgilendirme gönderilir, **✔ Kapat**.

## Durumlar
- Döngü: Yükleniyor → Çalışıyor → İndikatör bekliyor → **Serbest** / **Karantina** / **Başarısız** / İptal; **Test** (Bowie-Dick / vakum, yük konmaz).
- Paket: Sterilde → Karantina → **Steril** → Kullanıldı; İptal (başarısız döngü), Süresi doldu, Bloke (geri çağırma), Etiket bekliyor.
- Birim: Kirli → Yıkamada → Sayım / paketleme bekliyor → Paketlendi → Sterilde → Steril depoda → Kullanımda; Arızalı; Yeniden işlenecek.

## Yetki
- Döngü açma / bitirme / serbest bırakma **steril.dongu**; hazırlama adımları **steril.birim**; okutma **steril.kullanim**; izleme ve geri çağırma **steril.izleme**; tanımlar **steril.ayar**. Rol örneği: "steril_sorumlu".

## Sık görülen hata ve uyarılar
- **BD_ONAY** → bugün bu cihazda Bowie-Dick yok; test döngüsü çalıştırın ya da onay notu yazın. Kural "engel" ise döngü açılmaz.
- **SERBEST_EKSIK** ("Serbest bırakılamaz: parametre girilmemiş; sınıf 5/6 entegratör sonucu girilmedi; günün Bowie-Dick sonucu yok …") → eksikleri kartta girin.
- **KARANTINA** ("… karantinada (biyolojik sonuç bekleniyor). Kullanmak için onaylayın.") → bekleyin ya da onayla kullanın; implant kiti karantinada kullanılamaz.
- **"… KULLANILAMAZ: raf ömrü doldu / paket daha önce kullanıldı / geri çağırma ile BLOKE / döngü henüz serbest bırakılmadı"** → onayla aşılmaz; başka paket.
- **"… döner alet son kullanımdan sonra yağlanmadı"** / **"yıkanmadan / sayılmadan yüklenemez"** / **"Test programına yük konmaz"** / **"Yük boş"** / **"İmplant kiti içeren yükte biyolojik indikatör zorunlu"**.
- **"… üzerinde çalışan döngü var; önce onu bitirin."** / **"kullanım dışı (bakım gerekli / pasif)"** / **"Biyolojik indikatör pozitif; döngü serbest bırakılamaz (geri çağırma)."**
- **"Paketi olan döngü silinemez; iptal edin."**

## Diğer modüllere etkisi
- Diş seansı: kullanılan paketler seans kartında listelenir; seans bitirmede kurum kuralına göre "paket okutulmadı" uyarı ya da engel olur.
- Geri çağırma hastalara bildirim şablonuyla SMS gönderir ve kullanım kayıtlarından hasta / hekim / ünite bilgisini alır.
- Sayımda eksik alet görev açar; arıza kaydı cihaz / set bakımına düşer.

## Yapılmaması gerekenler
- Kayıt defterine elle satır eklemeye çalışmayın; serbest bırakmada kendiliğinden oluşur.
- Etiketi onaydan önce basmaya çalışmayın; etiket onaysız basılmaz.
- Karantina paketini implantta kullanmayın; sistem yasaklar.

## Örnek sorular
- Yeni sterilizasyon döngüsü nasıl açılır?
- Bowie-Dick testi yapılmadan döngü açabilir miyim?
- Döngüyü nasıl serbest bırakırım?
- SERBEST_EKSIK ne demek?
- Karantinadaki paketi kullanabilir miyim?
- Paket barkodunu seansta nereden okuturum?
- Geri çağırma nasıl açılır ve kapanır?
- Döner alet neden yüklenemiyor?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Steril.ts; web/src/sayfalar/steril/SterilPano.tsx, SterilDonguKarti.tsx
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (steril-*-liste), KartKatalogu.Steril.cs, KaynakKatalogu.Steril.cs
- api/src/Gentegre.Api/Uclar/SterilUclari.Islem.cs; api/src/Gentegre.Api/Servisler/Yardim/HataAciklamalari.cs
- db/868_sterilizasyon.sql; dokuman/00_TARIHCE.md (868, seans "kullanılan paketler")

## Doğrulama durumu
Kod incelemesiyle yazıldı.
