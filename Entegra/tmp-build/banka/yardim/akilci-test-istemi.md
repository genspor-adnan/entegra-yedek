---
id: akilci-test-istemi
baslik: Akılcı test istemi kuralları (branş, tekrar süresi, basamak, refleks, reflektif)
modul: lab
ekran: lab-akilci-kural
rota: /lab-akilci-kural
surec: akilci-istem
roller: hekim, lab_uzmani, lab_teknisyen, kayit_kabul, yonetici
dil: tr
surum: 1
urun_modu: 2
yetki: lab
erisim: kullanici
ozet: Bakanlık Akılcı Test İstemi kılavuzunun (EK-2) sistemde nasıl uygulandığı - hangi uyarı neden çıkar, gerekçe nasıl seçilir, kurallar nereden düzenlenir.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Sağlık Bakanlığı "Akılcı Test İstemi Uygulamaları" kılavuzu (EK-2) laboratuvar testlerinin gereksiz tekrarını, yetkisiz branştan istemini ve tesis basamağına uymayan istemleri önler. Sistem bu kuralları istem anında kendisi uygular; hekim yalnız uyarıya karar verir. Kural kaynağı Bakanlığın "Akılcı Test İstem Listesi" (2.224 test) ve SKRS "AKILCI TEST İSTEM LİSTESİ" (tekrar süreleri) listeleridir.

## Ekrana giriş yolları
- Kural kataloğu: Laboratuvar › Ayarlar › **Akılcı İstem Kuralları** (`/lab-akilci-kural`).
- Refleks kuralları: Laboratuvar › Ayarlar › **Refleks Test Kuralları** (`/lab-refleks-kural`).
- Karar günlüğü: Laboratuvar › **Akılcı İstem Kararları** (`/lab-akilci-gerekce`).
- Uyarıların kendisi istem sırasında çıkar: Muayene kartı › İstem düğmesi, Laboratuvar › İstemler › Yeni.

## Ön koşullar
- Şube kartında **Sağlık Tesisi Basamağı** doğru olmalı (varsayılan 2; 3. basamak hastanede 3; 0 = basamak kısıtı denetlenmez).
- Hekimin bölümü (personel kartı › Bölüm) SKRS klinik koduna bağlı bir bölüm olmalı; bölümsüz hekimde branş kısıtı "branşı tanımsız" uyarısı verir.
- Testin hizmet kataloğunda SUT koduyla kayıtlı olması (kural SUT koduna göre eşleşir).

## Alanlar
Kural kartı: SUT Kodu (zorunlu), Test, Hizmet (katalog), Aktif, Tekrar aralığı (gün, 0 = yok), Süre notu (Bakanlık metni), Bayraklar (salt okunur), Tüm branşlar isteyebilir, Yetkili branş kodları (SKRS klinik, virgülle), Bakanlık listesindeki branş metni (salt okunur), Refleks test, Basamak (Kapsam dışı / 2. ve 3. basamak / Yalnız 3. basamak), İsteme kapalı, Not, Kaynak sürümü.
Refleks kuralı kartı: Kaynak tetkik, Koşul (> >= < <= / yüksek / düşük / anormal / pozitif), Eşik değer, Eklenecek tetkik, Açıklama, Aktif.

## Liste kolonları ve çipler
Akılcı İstem Kuralları: SUT Kodu, Test, Katalogda, Tekrar (gün), Tüm Branşlar, Yetkili Branşlar, Basamak, Refleks, Kapalı, Aktif. Çipler: Aktif · Süre kısıtlı · Branş kısıtlı · Yalnız 3. basamak · Refleks · Tümü.
Akılcı İstem Kararları: Tarih, Hasta, Hekim, Test, Kural (sure / brans / basamak / refleks / reflektif), Karar (devam / iptal), Gerekçe, Açıklama, İstem No. Çipler: Gerekçeli devam · Vazgeçme · Refleks · Reflektif · Tümü.

## İşlemler (düğmeler)
- `lab-akilci-kural.yeni / .duzenle / .sil` — kural ekle / düzenle / sil (yetki `lab.tetkik`).
- `lab-refleks-kural.yeni / .duzenle / .sil` — refleks kuralı (yetki `lab.tetkik`).
- `lab.reflektif` "🔁 Reflektif tetkik ekle" — Laboratuvar › İstemler listesinde, yalnız laboratuvar uzmanı (yetki `lab.onay`): seçili isteme sonuç sonrası ek tetkik ekler.
- Karar günlüğünde yalnız Yazdır; kayıtlar değiştirilemez (Bakanlık analizine gider).

## Adım adım
1. Hekim muayene kartından ya da Laboratuvar › İstemler'den tetkik seçer ve istemi gönderir.
2. Sistem her tetkik için kuralı denetler: kapalı test ya da basamağa uymayan test **engel**dir, istem açılmaz; mesaj "Talep edilen test sağlık tesisinizde çalışılmamaktadır… üçüncü basamak sağlık tesisine sevki önerilmektedir" gelir.
3. Test hekimin branşına açık değilse ya da tekrar aralığı dolmamışsa **uyarı** penceresi açılır: "Bu testin … tarihinde yapılmış bir sonucu bulunmaktadır (tekrar aralığı N gün, K gün kaldı). Tekrar istemek istediğinizden emin misiniz?" Pencerede hastanın son iki sonucu (tarih, değer, birim, bayrak) görünür.
4. Hekim gerekçe seçer: süre için Klinik uyumsuzluk · Tedavinin takibi · Replasman tedavisinin takibi · Yeni hastalık gelişimi; branş için Klinik bulgulara dayalı gereklilik · Yetkin branş konsültasyonu · Tesiste ilgili branş yok · Multidisipliner tedavi. Gerekçe seçilince istem açılır ve karar kayda geçer.
5. Hekim "Hayır" derse o tetkik istemden çıkar, vazgeçme de kayda geçer; kalan tetkiklerle istem açılır.
6. Sonuç girildiğinde refleks kuralı tutarsa (örn. TSH yüksek) tanımlı ikincil test aynı isteme, aynı numuneye otomatik eklenir; sonuç mesajı "Refleks test eklendi: …" der.
7. Laboratuvar uzmanı gerekli görürse istem listesinde "Reflektif tetkik ekle" ile ek test ister; kayıt "Laboratuvar Uzmanı Reflektif İstemi" olarak düşer ve yeni tüp planı üretilir.

## Durumlar
- Kural seviyesi: **engel** (kapalı, basamak) · **uyarı** (branş, süre).
- Karar: **devam** (gerekçeli) · **iptal** (vazgeçme) · **refleks** (sistem ekledi) · **reflektif** (lab uzmanı ekledi).
- İstem satırı kaynağı: hekim/banko · refleks · reflektif.
- Başvuru ücretinden otomatik açılan (banko) istemde uyarı sorulmaz: engelli test atlanır ve "otomatik" notuyla kaydedilir.

## Yetki
- Uyarıyı görmek ve gerekçe seçmek: istem açabilen herkes (`lab` ekle ya da `muayene` değiştir).
- Kural ve refleks kuralı düzenlemek: `lab.tetkik`.
- Reflektif istem: `lab.onay` (laboratuvar uzmanı).
- Karar günlüğünü görmek: `lab`. Dış hekim / dış kurum / hasta portalı yalnız kendi kayıtlarını görür.

## Sık görülen hata ve uyarılar
- `AKILCI_ENGEL` — test bu tesiste istenemez (yalnız 3. basamak) ya da listede kapalı. Ne yapılır: testi çıkarın; 3. basamak testi için sevk önerin; şube basamağı yanlışsa yönetici şube kartından düzeltir.
- `AKILCI_UYARI` — branş kısıtı ya da tekrar aralığı. Ne yapılır: gerekçe seçin (karar kaydedilir) ya da "Hayır" ile vazgeçin.
- "Akılcı istem gerekçesi seçilmeli" (doğrulama) — geçersiz gerekçe kodu; listeden seçin.
- "İstemde tetkik kalmadı; istem açılmadı" — bütün tetkiklerden vazgeçildi.
- "Panelin bir tetkiğinden vazgeçildi; paneli tek tek tetkik olarak isteyin" — panel bölünmez; kalan tetkikleri tek tek seçin.

## Diğer modüllere etkisi
- Kararlar `Akılcı İstem Kararları` listesinde birikir; Bakanlık analizi ve kalite denetimi için dışa aktarılabilir.
- Refleks ve reflektif tetkikler ücretlendirmeye normal istem satırı gibi girer (panelden değil, tetkik olarak).
- Şube kartındaki basamak alanı yalnız bu kısıtı etkiler; kurum profilindeki "Basamak" metni bilgi amaçlıdır.

## Yapılmaması gerekenler
- Uyarıyı geçmek için rastgele gerekçe seçmeyin; gerekçe Bakanlığa raporlanır.
- Kural kataloğunda Bakanlık kurallarını silmeyin; kurum farkı varsa pasife alın ya da notla düzenleyin.
- Şube basamağını 0 yapmak kısıtı tamamen kapatır; yalnız kılavuz kapsamı dışındaki kurumda kullanın.
- Laboratuvar istem KARTINDAN (form) satır eklerken kural denetimi yoktur; hekim istemini muayene kartından ya da istem düğmesinden açın.

## Örnek sorular
- Akılcı test istemi uyarısı neden çıktı?
- Tekrar aralığı dolmadan test istersem ne olur?
- Akılcı test istemi uyarısında hangi gerekçeyi seçmeliyim?
- Bu testi hangi branşlar isteyebilir?
- Basamak kısıtı nedir, "üçüncü basamağa sevk" mesajı ne demek?
- Refleks test nasıl tanımlanır?
- Reflektif istemi kim, nereden yapar?
- Akılcı istem kararları nerede görünür?
- Şube basamağı nereden değiştirilir?

## Kaynaklar
- Ekranlar/Lab/EK2_Akılcı test istemi.pdf (Bakanlık iş kuralı kılavuzu), Akılcı Test İstem Listesi.xlsx
- SKRS: AKILCI TEST İSTEM LİSTESİ, AKILCI TEST İSTEM GEREKÇESİ, AKILCI TEST İSTEM KLİNİK GEREKÇESİ
- db/873_akilci_test_istemi.sql, api LabServisi.Akilci.cs, dokuman/01_API_SOZLESMELERI.md §9.18

## Doğrulama durumu
kod-incelemesi (19.09.2026) — akış xUnit `AkilciIstemTestleri` ve API duman testiyle doğrulandı; refleks kural örnekleri kurum tanımlar.
