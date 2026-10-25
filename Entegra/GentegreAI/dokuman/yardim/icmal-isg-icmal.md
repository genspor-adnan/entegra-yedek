---
id: icmal-isg-icmal
baslik: İSG / OSGB İcmali
modul: isg
ekran: isg-icmal
rota: /isg-icmal
surec: icmal
roller: isyeri_hekimi, osgb_sorumlu_muduru, muhasebe, yonetici
dil: tr
surum: 1
urun_modu: 2
yetki: isg.icmal
erisim: kullanici
ozet: Seçilen dönemde firma başına plan / gerçekleşen hizmet süresini, Ek-2 muayene türü ve kanaatlerini, geciken periyodik muayeneleri, ziyaret ve defter imzalarını, iş kazası / meslek hastalığı olaylarını ve hizmet bedeli / tahsilat / sözleşme durumunu gösterir.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Firmalara mevzuatın istediği hizmet süresini verdik mi, periyodik muayenesi geciken çalışan var mı, olaylar SGK'ya zamanında bildirildi mi, hizmet bedelleri faturalanıp tahsil edildi mi?" sorusunu cevaplar. OSGB sorumlu müdürü, işyeri hekimleri ve muhasebe kullanır.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirmek** — "📅 Dönem" tarih kutuları ya da ‹ › okları; varsayılan geçen ay.
- **İşyeri hekimine göre süzmek** — "🩺 İşyeri hekimi" listesi.
- **Tehlike sınıfına göre süzmek** — "⚠ Tehlike sınıfı": Az tehlikeli / Tehlikeli / Çok tehlikeli.
- **Sekmeler arasında geçmek** — Firmalar, Muayeneler, Ziyaretler, Olaylar, Hizmet Bedeli & Sözleşme.
- **Firma seçmek** — Firmalar sekmesinde satıra tıklayın (Ctrl ile ekle / çıkar, Shift ile aralık); diğer sekmeler ve A4 yalnız seçili firmalarla hesaplanır.
- **Firmanın bölümlerini açmak** — firma adının yanındaki ▸ işaretine tıklayın.
- **Çıktı almak** — "🖨️ İSG / OSGB İcmali ▾" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.
- **İlgili ekrana geçmek** — "🏭 Firmalar", "📅 Periyodik Takvim" ve "📊 Firma Panosu" düğmeleri.

## Ekrana giriş
- Sol menü **İşyeri Hekimliği › İSG / OSGB İcmali** (`/isg-icmal`, yalnız HBYS modu).
- `isg.icmal` görme yetkisi gerekir (haklar ilk tanımda İSG panosu yetkisinden kopyalanmıştır).

## Süzgeçler
- **Dönem**: ziyaret, muayene, olay ve cari hareketler bu aralıkta alınır. Varsayılan bir önceki takvim ayı.
- **İşyeri hekimi** ve **Tehlike sınıfı** firmaları süzer.
- **Firma seçimi**: Firmalar sekmesi her zaman tüm kümeyi gösterir; seçim yapılınca sunucudan yalnız seçili firmalar için ayrı icmal istenir ve diğer sekmeler / A4 onu gösterir. Üst özet kutuları tüm kümeye aittir.
- Süzgeçler adres çubuğunda tutulur; değişince seçim sıfırlanır.
- Şeritte rozetler: "N geciken periyodik muayene", "N firmada süre eksik", "N sözleşme 60 gün içinde bitiyor", "N SGK bildirimi geç".

## Özet ve sekmeler
Özet kutuları: **Firma / Çalışan** (çok tehlikeli, hekim sayısı) · **Hizmet Süresi** (karşılama %, gerçekleşen / plan dk) · **Muayene** (işe giriş, periyodik) · **Geciken Periyodik** (90+ gün) · **Ziyaret** (dk, eksik defter imzası) · **İş Kazası / MH Şüphesi** (gün kaybı, ramak kala) · **Faturalanan / Tahsil** (açık bakiye) · **Sözleşme Bitişi** (60 gün içinde).

Sekmeler:
- **Firmalar** — Firma, NACE, Tehlike, Çalışan, İşyeri Hekimi, Plan dk, Gerçekleşen dk, Karşılama, Muayene, Geciken, Kaza.
- **Muayeneler** — firma başına muayene türü (işe giriş, periyodik, işe dönüş, erken kontrol, iş değişikliği) ve kanaat (çalışır, şu koşulla, çalışamaz, bekliyor), süre; altta geciken periyodik muayeneler (çalışan, son muayene, olması gereken, gecikme).
- **Ziyaretler** — ziyaret listesi (tür, hekim, süre, defter imzası) ve firma bazında süre (ziyaret dk + muayene dk ↔ plan, eksik).
- **Olaylar** — iş kazası / meslek hastalığı şüphesi / ramak kala: tarih, firma, bölüm, çalışan, bulgu, gün kaybı, SGK bildirimi, durum.
- **Hizmet Bedeli & Sözleşme** — aylık bedel, devreden, faturalanan, tahsil edilen, bakiye, sözleşme bitişi ve kalan gün.

## Rakamlar nereden gelir
- Uç: `GET /api/isg-icmal` (`IsgIcmalUclari.cs`); ekran hesap yapmaz.
- **Plan süre** = sözleşme dakikası (yoksa çalışan × tehlike katsayısı) × dönemin ay oranı; **gerçekleşen** = ziyaret süresi + tamamlanmış Ek-2 muayene süresi. Karşılama %100'ün altındaysa mevzuat açığıdır.
- **Geciken periyodik**: aktif çalışanın vadesi (hekimin verdiği sonraki tarih, yoksa son muayene + periyot) bugünden önce. Dönemden bağımsız, **bugün** itibarıyla.
- **SGK bildirimi**: iş kazası ve meslek hastalığı şüphesinde olaydan sonra 3 iş günü (hafta sonu atlanır, resmî tatil düşülmez); bildirilmemiş ve süresi geçen de geç sayılır. Ramak kala bildirim gerektirmez.
- **Hizmet bedeli**: aylık bedel firma kartından; devreden / faturalanan / tahsil / bakiye firmanın carisinden (cari ekstre, yerel tutar).

## Çıktı
"İŞYERİ HEKİMLİĞİ DÖNEM HİZMET İCMALİ" başlıklı A4: antet, dönem, firma tablosu (seçim varsa yalnız seçili firmalar) ve özet; Sorumlu Müdür imza alanı. A4'te çalışan bilgisi basılmaz. Dosya adı "İSG OSGB İcmali <başlangıç> - <bitiş>".

## Dikkat edilecekler
- Çalışan adı yalnız ekrandaki geciken muayene ve olay listelerinde görünür; TC kimlik hiçbir yerde yoktur.
- Firma ile fatura arasında doğrudan bağ yoktur; tutarlar firmanın cari hesabından bulunur.
- Bu ekran kayıt değiştirmez; muayene planlamak için Periyodik Takvim'e geçin.

## Örnek sorular
- Hangi firmalarda hizmet süresi eksik kaldı?
- Periyodik muayenesi geciken çalışanlar kimler?
- SGK'ya geç bildirilen iş kazası var mı?
- Sözleşmesi yakında biten firmalar hangileri?
- Bu ay hangi firmadan ne kadar tahsilat yaptık?
