---
id: icmal-babs-icmali
baslik: Ba / Bs İcmali
modul: muhasebe
ekran: babs-icmali
rota: /babs-icmali
surec: icmal
roller: muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: muhasebe.babs_icmali
erisim: kullanici
ozet: Aylık Form Ba (mal ve hizmet alımları) ve Form Bs (mal ve hizmet satışları) listesini çıkarır — eşiği aşan carilerin VKN bazında belge sayısı ve KDV hariç tutarı, eşik altında kalanlar, eksik / hatalı vergi numarası uyarıları, cari mutabakat gönderimi ve yanıtları, KDV İcmali ile kıyas.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bu ay Ba / Bs'ye kimler giriyor, tutarlar doğru mu, cari bizimle aynı tutarı mı bildirecek?" sorusunu cevaplar. Muhasebe her ay, bildirimin son gününden (izleyen ayın son günü) önce bakar. Kural KDV İcmali'ninkiyle aynıdır — ikinci bir hesap yoktur.

## Bu ekranda neler yapabilirsiniz
- **Form Ba ve Form Bs listesini görmek** — "Form Ba" / "Form Bs" sekmeleri: eşiği aşan her cari için sıra, unvan, VKN / TCKN, belge sayısı ve KDV hariç tutar. Aynı vergi numarasıyla açılmış birden çok cari tek satırda toplanır ("2 cari" rozeti). ▸ işaretine tıklayınca satırın belgeleri açılır; belgeye tıklayınca belge kartı, unvana tıklayınca cari kartı açılır.
- **Eşiğe yakın carileri izlemek** — "Eşik Altı" sekmesi: bildirime girmeyen cariler, eşiğe kalan tutarla; eşiğin %10 yakınındakiler sarı.
- **Bildirimi bozacak kayıtları düzeltmek** — "Uyarılar" sekmesi: eşiği aşan ama vergi numarası boş / hatalı cari (bildirime giremez — cari kartına vergi no girin), aynı VKN'li birden çok cari, yurt dışı cariler (Ba / Bs dışı), bu döneme tarihli taslak faturalar, mutabakattan sonra tutarı değişen cariler.
- **Cariye mutabakat göndermek** — Form Ba / Bs sekmesinde carileri seçip "✉ Mutabakat gönder": bizim tutar ve belge sayısı kaydedilir, e-posta adresi varsa mektup e-posta kuyruğuna alınır (adresi olmayana Form Ba / Bs çıktısı verilir). Tutar sunucuda yeniden hesaplanır. Daha önce gönderilmiş cariye yeniden gönderirseniz önceki yanıt sıfırlanır. Yalnız `muhasebe.babs_mutabakat` yetkisi olan kullanıcıda görünür.
- **Yanıtı işlemek** — "Mutabakat" sekmesinde "Yanıt işle": mutabık ya da fark var (carinin tutarı ve belge sayısıyla). Yanıt geri alınabilir. Hepsi loglanır.
- **KDV İcmali ile kıyaslamak** — "KDV İcmali ile Kıyas" sekmesi: Ba / Bs eşik üstü + eşik altı + nihai tüketici + yurt dışı + fiş toplamı, KDV İcmali'ndeki hesaplanan / indirilecek matrahla aynı olmalı.
- **Döküm almak** — "📤 Excel dökümü" Form Ba ve Form Bs'yi ayrı sayfalarda .xlsx olarak indirir; "Form Ba" / "Form Bs" çıktı menüleri A4 ön izleme, yazdırma ve PDF verir.

## Ekrana giriş
Muhasebe › İcmaller › Ba / Bs İcmali. Varsayılan dönem geçen aydır (bildirimi verilecek ay).

## Süzgeçler
- **Dönem** — ay (belge tarihine göre).
- **Mükellef** — şubenin vergi numarası; aynı VKN'li şubeler tek bildirimdir. Birden çok şubesi olan mükellefte şube süzgeci açılır.
- **Eşik** — Genel Ayarlar › İcmal Eşikleri › `muhasebe.babs_sinir` (boşsa 5.000 TL, KDV hariç). Mevzuat değişirse buradan güncellenir.

## Rakamlar nereden gelir
- Yalnız **kesin faturalar** (satış 15, alış 11); fiş, taslak ve tahakkuk girmez. Gider pusulası ve serbest meslek makbuzu henüz ayrı belge türü olmadığından dahil değildir.
- **Bs** = satış faturaları + düzenlediğimiz alış iadesi faturaları; **Ba** = alış faturaları + aldığımız satış iadesi faturaları. Tutar faturanın KDV hariç saklı matrahı; dövizli faturada belge kuruyla TL.
- Gruplama **vergi numarasına** göredir (GİB VKN bazında ister); vergi numarası boş / hatalı cari kendi satırında kalır ve bildirime giremez.
- **Nihai tüketici** (11111111111) Ba / Bs'ye girmez. **Yurt dışı** (VKN 2222222222 ya da ihracat faturası) ayrı listelenir, gümrük beyannamesiyle izlenir.
- Aynı kural KDV İcmali'nin "Ba / Bs Ön Kontrol" sekmesini de besler; orada liste cari bazındadır, burada VKN bazında.

## Çıktı
"Form Ba" / "Form Bs" çıktı menüsü (yazdır, PDF, Excel) ve "📤 Excel dökümü" (iki sayfa). Bu dökümler **e-Beyanname'ye yüklenecek XML dosyası değildir**; bildirim müşavirin / e-Beyanname'nin kendi ekranında bu listeden hazırlanır.

## Dikkat edilecekler
- Kırmızı uyarılar (eksik / hatalı VKN) düzeltilmeden o cari bildirime yazılamaz.
- Mutabakat gönderildikten sonra fatura eklenir, silinir ya da değişirse satır "tutar değişti" olur — yeniden gönderin.
- Mektupta tek kullanımlık yanıt bağlantısı yoktur; carinin yanıtı bu ekrandan elle işlenir.
- Kayıt kapsamınız sınırlıysa yalnız erişebildiğiniz carilerin belgeleri sayılır ("kapsam sınırlı" rozeti).

## Örnek sorular
- Eylül'de Form Bs'ye hangi müşteriler giriyor?
- Vergi numarası eksik olduğu için Ba / Bs'ye yazılamayan cari var mı?
- Hangi tedarikçiler mutabakat mektubuna yanıt vermedi?
- Bu ay Ba / Bs toplamı KDV İcmali ile tutuyor mu?
