# KTS Denetimi — Madde Madde İş Listesi

Kaynak: `Ekranlar/Dis Klinigi/` altındaki üç **Kayıt Tescil Sistemi Denetim
Sonuç Raporu** (FETA BİLGİSAYAR LTD. ŞTİ., denetim tarihi **26.08.2025**):

| Rapor | Denetim türü | Sonuç |
|---|---|---|
| `…Denetim Raporu_HBYS.pdf` | Hastane Bilgi Yönetim Sistemi | **Başarısız** — "Üreticinin denetim sonucunda eksiklikleri tespit edilmiş ve başarısız bulunmuştur." |
| `…Denetim Raporu_DHBS.pdf` | Diş Hekimliği Bilgi Sistemi | Denetim **yapılmamış** — tüm maddeler "Denetlenmedi" |
| `…Denetim Raporu_LBYS.pdf` | Laboratuvar Bilgi Yönetim Sistemi | Denetim **yapılmamış** — tüm maddeler "Denetlenmedi" |

**Denetim ÖNCEKİ ürüne yapıldı.** Bu liste bir kusur listesi değil;
Gentegre AI için **gereksinim ve kabul kriteri** listesidir. Denetlenmemiş iki
raporun soru listesi, bir sonraki denetimde ne sorulacağının kanıtıdır.

Durum sütunu **19.09.2026 itibarıyla kod ve migration okunarak** çıkarıldı
(çalışan sistemde deneyerek değil). "Yok" = koda bakıldı, karşılığı bulunamadı.

**19.09.2026 akşamı yapılanlar.** Sıranın 9. kalemi (diş): D1 · D7 (zaten vardı) ·
D8 · D9 tamam, D18 kapalı kurulu (`db/874` · `875` · `876`). Ardından sıranın
1. kalemi: **H7 / D14 e-Nabız hasta mesajı** (`db/877`) - ürün tarafı bitti,
Bakanlık metot adı beklendiği için gönderim kapısı kapalı. H1 · D16 · D17 artık
tek çağrı uzaklıkta (H1/D16 aynı gece kapandı). Hemen ardından **H6 / D15 e-Nabız hekim erişimi** (`db/878`)
tamamlandı - kılavuzdaki `DoktorEHRErisimi` tam tanımlı olduğu için bu madde
**kapandı**; kalan tek şey hesap bilgilerinin kurulumda girilmesi.

**19.09.2026 gecesi büyük açılım — USS paket listesi bulundu.** `rehber.enabiz.gov.tr`
menüsündeki paket listesi ve her paketin şema sayfası tarayıcıdan okundu. Daha önce
"numarası bilinmiyor" diye kapalı kurduğumuz kalemlerin numaraları belli oldu:

| USS paketi | Hangi madde | Durum |
|---|---|---|
| **252** Konsültasyon Kayıt | H2 · D20 | **açıldı** (880) |
| **203** Ağız ve Diş Sağlığı Veri Seti | D18 | numara yazıldı, elemanları SKRS eşlemesi bekliyor (876/880) |
| **411** Doktor Mesajı Paketi | H7 · D14 | **881'de bağlandı** - mesaj artık bu paketle gidiyor |
| **214** Bulaşıcı Hastalık Bildirim | H5 (BZBH) | **882'de bağlandı** |
| **221/207/209/224/223** izlem paketleri | H10 | **898-902'de bağlandı** (SKRS ad/kod ile) |
| **409** Radyoloji Sonuç Kayıt | H10 · D19 | **883'te bağlandı** |
| **268** Hekim Puan Bilgisi | H15 · D21 | şema hazır, yapılmadı |
| **407** Gün Sonu · **408** Ay Sonu | H13 · D24 | **884 / 885'te bağlandı** |
| **201** Patoloji Kayıt · **112** Rapor · **109** Epikriz | ileride | — |

Kısaltma: **V** var · **K** kısmi · **Y** yok.

---

## 1. HBYS — "Hatalı" bulunan 5 madde (en yüksek öncelik)

Yeniden denetimde bunlar **kesin** sorulur.

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| H1 | Numune reddinde hastanın e-Nabız profiline otomatik mesaj | **V** (879 + 881) | **Yapıldı.** Ret akışı zaten vardı (433); eksik olan bilgilendirmeydi. Ret AYNI İŞLEMDE hastaya e-Nabız mesajı kuyruğa alıyor (`kaynak = 2`), metin ret kriterinin şablonundan. Üç kapı: kurum ayarı `lab.ret_enabiz_bildir`, kriterin `hasta_bilgilendir` bayrağı, hastanın kimlik numarası. Mesaj 411 paketine dönüşüp USS kuyruğuna giriyor; SKRS türü "NUMUNE REDDI" (kod 2) - Bakanlığın kendi listesindeki tür. |
| H2 | Konsültasyon kayıt paketi gönderimi | **V** (880) | **Yapıldı ve paket AÇIK.** USS paketi **252 Konsültasyon Kayıt**; şema rehberden okundu (KONSULTASYON_BILGISI + TANI_BILGISI + zorunlu KONSULTASYON_NOTU_BILGISI + SYSTakipNo). Kaynak, `ust_muayene_id` ile bağlı konsültasyon muayenesi; paket muayene tamamlanırken doğuyor. Dev'de 12 alanla üretildi, eksik alan yok. |
| H3 | VEM mantıksal kontroller | **Y** | VEM (Veri Erişim Modülü) altyapısı **hiç yok**. Bakanlığın VEM script'leri + doküman setine göre görünüm/sorgu katmanı kurulmalı. Tek başına büyük bir iş kalemi. |
| H4 | VEM sorgu listesinden rasgele sorgular | **Y** | H3'ün parçası — aynı altyapı. |
| H5 | BZBH (Bildirimi Zorunlu Bulaşıcı Hastalık) iş akışı | **V** (882) | **Yapıldı.** Tanı → taslak → bildirim → **214 Bulaşıcı Hastalık Bildirim** paketi. Hastalık listesi ICD önekiyle eşleşen ayrı tanım ekranı (34 çekirdek Grup A kaydıyla tohumlandı, `dogrulandi = 0` - tebliğe göre gözden geçirilecek). Muayene tamamlanınca eşleşen her tanı için bekleyen bildirim açılıyor ve hekime uyarı düşüyor; vaka tipi (SKRS: şüpheli/olası/kesin) ve belirti başlangıcı girilince paket üretiliyor. Pano gecikmeyi (Grup A: 24 saat) kırmızı gösteriyor; "bildirim gerekmiyor" kararı gerekçesiz kapatılamıyor. |

## 2. HBYS — "Başarılı" bulunmuştu, yeni üründe henüz yok

Eski üründe geçen ama Gentegre AI'da karşılığı olmayan maddeler. Yeniden
denetimde **geriye gidiş** sayılır.

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| H6 | Hekim ekranından hastanın e-Nabız profiline erişim (SMS onayı, sisteme giriş) | **V** (878) | **Yapıldı.** `DoktorEHRErisimi` çağrılır (ortak SOAP istemcisi, WS-Security), dönen `AccessKey` paylaşım adresine eklenir, adres yeni sekmede açılır - e-Devlet girişi ve SMS onayı o ekranda. Her deneme `enabiz_erisim`'e ve ISLEMLOG'a yazılır (KVKK izi); **anahtarın kendisi saklanmaz**, yalnız ilk 8 karakteri. Düğme: muayene kartı + diş hasta kartı, yetki `enabiz.erisim`. Kalan tek şey kurulum: `ENABIZ_HBYS` hesabına kullanıcı/şifre/kurum kodu girip aktif etmek. |
| H7 | Hekim ekranından e-Nabız profiline **düz metin mesaj** | **V** (877 + 881) | **Kapı kalktı.** Mesaj artık **411 Doktor Mesajı** USS paketiyle gidiyor - 101/102/103 ile aynı kuyruk, aynı `SYSSendMessage`. Mesaj türü SKRS "HASTA MESAJLARI" listesinden (1 randevu iptali · 2 numune reddi · 3 panik değer · 4 doktorun mesajı · 5 protez randevu iptali). Ekran, kuyruk ve yetki 877'den; değişen yalnız taşıma. Kalan: kurulumda `enabiz.gonder` işinin açılması. |
| H8 | e-Nabız butonu Bakanlık standardına uygun mu (resim, yer, hint) | **V** (H8) | **Yapıldı.** Düğme iki ekranda ayrı ayrı yazılmıştı (muayene kartı ve diş hasta kartı): farklı emoji, farklı konum, **ipucu yok**, pop-up mantığı kopyalanmış — aynı düğmenin iki görünümü "standarda uygun mu" sorusunu cevapsız bırakır. Artık tek bileşen (`web/src/bilesenler/EnabizButonu.tsx`): **resim** (kurum resmî logoyu `public/enabiz-logo.png` olarak koyarsa o, yoksa metin işareti — marka çizilip taklit edilmez), **yer** (muayene kartı + **hasta kartı** + diş hasta kartı, aynı araç çubuğu konumunda), **hint** (ne olacağını ve e-Devlet/SMS onayını söyleyen `title`). Yetkisiz kullanıcıda düğme hiç çizilmez; sekme istekten ÖNCE açılır (tarayıcı `await` sonrası pop-up'ı engelliyor), hata gelince kapanır. 6 birim testi. |

## 3. HBYS — "Denetlenmedi": bir sonraki denetimin gündemi

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| H9 | PACS/RBS için istem ve raporların HL7 ile gönderim/alımı | **K** | HL7 **ORU** (sonuç) var: cihaz dinleyici + telerad. **ORM** (istem) yok. PACS istem mesajı üretimi ve alımı eklenmeli. |
| H10 | USS paketleri: Gebe İzlem · Aşı · Bebek/Çocuk İzlem · Gebelik Sonucu · Doğum Bildirim · Radyoloji Sonuç | **V** (883 + 898–902) | **Tamamlandı.** **409** (883), **207 Aşı** (898), **209 Bebek/Çocuk İzlem** (899), **221 Gebe İzlem** (900), **223 Gebelik Bildirim** (901) ve **224 Gebelik Sonucu** (902). Beşinin ortak sorunu paket değil kaynak veriydi; her modül kendi ekranıyla birlikte kuruldu, her şema rehberden okundu. 902: `gebelik_sonuc` (doğum · düşük · tıbbi tahliye), kayıt **dosyayı kapatıyor ve paketi doğuruyor**; `v_gebelik_sonucsuz` "kapandı ama bildirilmedi" dosyaları sayıyor. **Not:** listedeki "Doğum Bildirim" ayrı bir USS paketi olarak rehberde yok — doğum bilgisi 224 ile gidiyor. SKRS kod listeleri çekildi (`skrs-kod-listeleri` ucu, ~6.400 değer): paketler artık SKRS **adını** `deger`'e, **kodunu** `skrs_kod`'a koyuyor; liste boşsa ham değere düşüyor. SKRS'nin `ADI/KODU` ~ `adi/kodu` (büyük/küçük) tutarsızlığı için ad okuması duyarsız yapıldı. |
| H11 | Hastanın çıkış bilgisi | **V** | 106 paketi kurulu ve canlıda çalıştı. İş yok. |
| H12 | LOINC standardına göre veri gönderimi | **V** | 530 eşleme + 872 resmî LOINC. İş yok. |
| H13 | Gün sonu gönderimi + %95-103 oran + KDS veri uyumu | **K** (884) | **Gün sonu (407) ve ay sonu (408) yapıldı:** on ölçüt HBYS verisinden sayılıyor; 407 tesis toplamını gece 01:00'de, 408 aynı ölçütleri KLİNİK kırılımıyla ayın 2'sinde gönderiyor. İkisi de ekrandan elle hesaplanabiliyor. **Gönderim oranı ekranı geldi** (üretilen/gönderilen, gün ve paket türü bazında, %95-103 dışı kırmızı). **Kalan:** oranın Bakanlık tarafındaki sayıyla karşılaştırılması (geri bildirim raporu okunmalı) ve KDS ekranı uyumu - ikisi de USS'den veri ÇEKMEYİ gerektiriyor (sorgulama paketleri 402/405). |
| H14 | Lab sonuç paketinde istemi olup sonucu olmayan kayıt var mı | **K** | 105 paketi var; tutarlılık denetimi yok. İstem-sonuç farkı raporu. |
| H15 | İşleme ait hekim puan bilgisi | **Y** (muaf) | Eski denetimde **Muaf**. DHBS listesinde muafiyet yok — D22 ile birlikte karara bağlanmalı. |
| H16 | İlaç adı ile barkodu aynı ya da boş gönderim var mı | **K** | 102 paketi ilaç taşıyor, İTS/karekod tarafı var. Gönderim öncesi "ad = barkod ya da boş" denetimi yok. Küçük doğrulama işi. |
| H17 | MKYS entegrasyonu | **Y** (muaf) | Kodda hiç yok. Muafiyet yeni üründe de geçerli mi — karar gerekir. |
| H18 | MHRS çalışma cetveli · randevu bildirimi · randevu verme | **K/Y** | Çalışma planı (718) var; **MHRS entegrasyonu yok** — MHRS yalnız randevu *kaynak kodu* olarak geçiyor. Eski denetimde muaf. |

---

## 4. LBYS — hiç denetlenmedi, tam checklist

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| L1 | Sonuçlar boş/anlamsız gönderilebiliyor mu (gönderilmemeli) | **V** (893) | **Yapıldı.** `fn_lab_sonuc_dogrula` tek karar noktası; **üç sınır ayrıldı**: panik (gerçek ama hayati — bildirilir), **ölçülebilir** aralık (cihazın aralığı, dışı **uyarı**), **mantık** sınırı (fizyolojik olarak imkânsız — **engel**). Engeller: boş sonuç, sayısal tetkike metin, imkânsız değer, metin/seçenek tetkikte tanımlı değer listesi dışı. Uyarıda sonuç **yazılır ama oto-onaylanmaz** ve uyarı sonucun yorumuna düşer. İşaretli değerler (`<0.01`, `>1000`) sayı sayılır, uyarı üretmez. **Boş sonuç onaylanamaz** (onay yolunda da kapı kapalı). `olculebilir_alt/ust` kolonları vardı ama hiçbir yerde okunmuyordu — artık işliyor. Sınırlar **tohumlanmadı**: uydurulmuş sınır gerçek sonucu reddettirirdi, kurum tetkik kartından yazar (yazmazsa yalnız boş-sonuç engeli çalışır). |
| L2 | Hekime panik bildirimi | **V** (894) | **Genişletildi.** Bildirim kaydı (kim/kime/kanal/okuma-geri teyidi) ve panodaki "açık panik" sayacı vardı; eksik olan **bildirim YAPILMAZSA ne olduğuydu** — bekleme süresi ölçülmüyordu, `lab_panik_bildirim.yukseltme` kolonu vardı ama hiçbir yerde yazılmıyordu, hekim kendiliğinden haberdar edilmiyordu. 894: `v_lab_panik_acik` (geçen dakika + durum: bildirilmedi / teyit bekliyor), saat başı çalışan **`lab.panik`** zamanlı işi (`fn_lab_panik_tara`) eşiği aşanı hekime bildiriyor (kanal **push**, SMS değil) ve süresi iyice geçeni **yükseltiyor**; eşikler ayardan (`lab.panik_bildirim_dk` 30, `lab.panik_yukseltme_dk` 60). Ekran: **Laboratuvar › Panik Değerler** (en uzun bekleyen üstte) + "Okuma-Geri Teyidi" aksiyonu. Kayıt bildirimle değil **teyitle** kapanır. |
| L3 | Yaş, cinsiyet, **cihaz** vb. referans aralığı | **V** (888) | **Yapıldı.** Yaş bandı (gün cinsinden, çocuk bantları dahil) + cinsiyet + "cinsiyet bilinmiyor" birleşimi + geçerlilik tarihi zaten vardı (642/644); eklenen **cihaz/yöntem boyutu**: `lab_tetkik_referans.cihaz_id` (boş = tüm cihazlar) ve `yontem`. Cihaza özel satır genel satırı **ezer** (yöntem farkı yaş bandı darlığından daha belirleyici). Seçim `fn_lab_referans(..., cihaz)` ile; sonuç yazılırken ölçümün yapıldığı cihaz geçiliyor ve aralık `lab_sonuc.referans_*` alanlarına donuyor. Tetkik kartında cihaz/yöntem alanları, tetkik özetinde hangi aralığın hangi cihaza ait olduğu görünüyor. |
| L4 | En az 2 seviye onay (teknik + klinik) | **V** (895) | **Genişletildi.** İki aşama tanımlıydı (teknik → uzman, yetkileri de ayrı) ama **ikincisi birincisini beklemiyordu**: uzman doğrudan yayınlayabiliyor, aynı kişi iki aşamayı da verebiliyor, oto-onay ikisini birden atlıyordu. 895: `fn_lab_onay_kontrol` tek karar noktası — teknik onay zorunluluğu ve **dört göz** kuralı; çift onay zorunluyken **oto-onay devre dışı**. Kurallar **ayar** (`lab.cift_onay_zorunlu`, `lab.onay_ayni_kisi`) ve tetkik bazlı istisna var (`lab_tetkik.cift_onay`: kurum ayarını izle / zorunlu / muaf) — kan grubu ile idrar pH aynı özeni gerektirmiyor. **Varsayılan kapalı**: kurulu laboratuvarın akışı bir güncellemeyle durmasın. `v_lab_cift_onay` denetim dökümü. |
| L5 | Bakteriyoloji sonuçlarında antibiyogram kısıtlaması | **V** (887) | **Yapıldı — ilk değerlendirmem yanlıştı, kısıtlamanın büyük kısmı zaten vardı.** 436/437 kademeli (basamaklı) bildirimi kuruyor ve rapor yalnız `bildir = 1` yazıyor; 509 da organizma kurallarını (doğal/intrinsik direnç + organizmaya özel panel) tanımlıyordu. Gerçek boşluk: **509'un kuralları hiçbir yerde işlemiyordu** (`fn_lab_antibiyogram_paneli` çağrılmıyordu, bildirim motoru genel basamağı okuyordu) ve **gizleme gerekçesi görünmüyordu**. 887: motor doğal dirençli ajanı hiç raporlamıyor (üst basamakta seçenek kalmasa bile) ve organizmaya özel basamağı kullanıyor; `kisit_neden` satıra yazılıyor, ekranda "Kısıtlı" rozetinin altında gerekçe çıkıyor; antibiyogram girişi artık tam katalog yerine organizma panelini soruyor ve kısıtlanan ajanı sebebiyle söylüyor. |
| L6 | Ret kriterleri tanımlanabiliyor mu | **V** (879) | **Yapıldı.** Ret nedenleri koda gömülüydü (8 sabit kod, sunucuda ve ekranda ayrı ayrı). Artık `lab_ret_nedeni` tanım tablosu + Laboratuvar › Ayarlar › **Numune Ret Kriterleri** ekranı; 15 kriterle tohumlandı (433'ün 9 kodu + 6 standart preanalitik kriter). Ret penceresi ve kabuldeki kalite listesi aynı tanımdan üretiliyor. Kod uzayı korundu - geçmiş numunelerin ret sebebi aynı kodlara bağlı. |
| L7 | Test seviyesinde yetki kısıtlaması | **V** (889) | **Yapıldı.** `lab_tetkik_kisit` (tetkik × rol × **iste/gör/onayla**) + `fn_lab_tetkik_izin` tek karar noktası. **Kısıtı olmayan tetkik herkese açık** — kural tanımlanana kadar hiçbir ekran değişmez; bir satır eklenince tetkik kapanır ve yalnız listelenen roller kalır. Uygulandığı yerler: istem açma (yetkisiz tetkik 403, başvurudan açılan sessiz istemde atlanır), sonuç girişi ve düzeltme, onay, `lab-sonuc` / `lab-kultur` listeleri (SorguUretici süzgeci), istem detayı ve rapor — raporda kaç tetkikin gizlendiği yazılır (sessizce eksik rapor, yanlış rapordur). Tanım tetkik kartındaki **Yetki Kısıtları** sekmesinde; ayrı `lab.tetkik_kisit` yetkisi (kataloğu düzenleyen herkes kısıtı kaldıramasın). |
| L8 | Test tekrarı elektronik olarak istenebiliyor mu | **V** (891) | **Yapıldı.** Tekrar *çalışıldığında* iz zaten kalıyordu (`tekrar_no`, düzeltme yolu, ret sonrası "tekrar numune bekliyor"); eksik olan **talebin kendisiydi** — iş telefonla söyleniyor, kuyruğa düşmüyor, gerekçesi kayıtta durmuyordu. `lab_tekrar_istegi`: **iki tür** (aynı numuneden tekrar çalışma / yeni numune), kod listesinden **zorunlu gerekçe**, aynı satırda tek açık talep. Tür 2 satırı "tekrar numune bekliyor"a, tür 1 "çalışılıyor"a alır; **onaylı sonuç iptal edilmez**. Talebi **sistem kapatır** (aynı satıra yeni sonuç yazılınca); iptal elle ve gerekçeli, satır eski durumuna döner. Ekran: sonuç kuyruğunda **🔁 Tekrar İste** (ayrı aksiyon yetkisi `lab.tekrar.iste`) + **Laboratuvar › Tekrar Talepleri** listesi; talep satırında tüpün arşiv yeri de görünür (890). |
| L9 | Onaylarken eski sonuçlara ve tekrarlara kolay erişim | **V** (886) | **Yapıldı.** Delta motoru zaten vardı (433 sonucu yazarken önceki değeri, yüzde farkını ve uyarı bayrağını satıra yazıyor); eksik olan ERİŞİMDİ. Sonuç satırındaki 📈 düğmesi pencereyi açıyor: aynı hastanın aynı tetkikteki **onaylı** önceki sonuçları (başka istemlerden), **bu istemdeki tekrar çalışmaları** (onaysız olanlar dahil) ve sonucun kendi delta bilgisi (kural tanımlı değilse bunu da söylüyor). |
| L10 | Cihazlardan grafik tipli sonuç alma ve raporda gösterme | **V** (892) | **Yapıldı.** HL7 çözümleyici artık **OBX-2 değer tipini** okuyor: `ED` gömülü görüntü (base64 → PNG/JPEG/PDF) ve `NA` sayı dizisi. Görüntü **doküman deposuna** yazılıyor (hash-dedup/erişim günlüğü orada; ikinci blob deposu açılmadı), sayı dizisi `jsonb` olarak duruyor — seriyi görüntüye çevirmek veriyi dondurmak olurdu, ekran ve rapor kendisi çiziyor (SVG). `lab_sonuc_grafik`: tür (elektroforez / kromatogram / jel / kalibrasyon / reaksiyon), **raporda** bayrağı, kaynak (cihaz / elle). Cihaz mesajı işlenirken grafik sonuca bağlanıyor ve sayısı mesajda söyleniyor; bağlantısız cihazın kâğıt çıktısı **elle yüklenebiliyor** (`lab.grafik.yukle`). İstem detayındaki 〰️ düğmesi grafikleri açıyor; rapor çıktısında "Grafik Sonuçlar" bölümü yalnız `raporda = 1` olanları basıyor. Test yetkisi (889) grafiklere de uygulanıyor. |
| L11 | Kalite kontrol sonuçları sistem üzerinde | **V** | 442 + `KaliteKontrolServisi`. İş yok. |
| L12 | Levey-Jennings grafikleri | **V** | Var. İş yok. |
| L13 | Offline ve yazılımsal numune arşivleme | **V** (890) | **Yapıldı.** Önceden yalnız serbest metin `saklama_yeri` vardı (bir ekrandan istemin bütün tüplerine aynı metin). Şimdi: **konum ağacı** (ünite > raf > kutu, göz kutunun satır × sütun ızgarasında), `lab_numune_arsiv` (ne zaman/kim koydu, imha hedefi, ne zaman/kim/niçin çıkardı), **saklama politikası** (tetkike özel kural genel kuralı ezer; politika yoksa imha hedefi yazılmaz). Bir gözde bir tüp, bir tüp bir yerde (kısmi benzersiz index). Ekran: **Laboratuvar › Numune Arşivi** — barkod okut, ızgarada göz seç, yerleştir/çıkar; süresi dolanlar sekmesi ve ayrı yetkiyle (`lab.arsiv.imha`) imha. Kutu dökümü yazdırılabilir (offline arşiv). Hareketler 433'ün kendi zincir kodlarına yazılır (6 saklamaya · 2 taşındı · 8 imha). |
| L14 | Lab sonucu gönderiminde LOINC | **V** | H12 ile aynı. İş yok. |
| L15 | Karar sınırının altında/üstünde olduğunu gösteren sembol | **V** (896) | **Sembol vardı, kavram yoktu.** `fn_lab_bayrak` referans aralığına göre L/H/LL/HH üretiyor ve rapor bunları ↓ ↑ ↓↓ ↑↑ ile basıyordu (doğrulandı). Ama **karar sınırı referans aralığı değildir**: referans sağlıklı popülasyonun dağılımı, karar sınırı kılavuzun eşiğidir — LDL 115 mg/dL referans aralığında "normal" görünür ama hedefin üstündedir. 896: `lab_karar_siniri` (tetkik × yön × eşik × yaş/cinsiyet × dayanak), `fn_lab_karar_notu` yalnız **dışında kalınan** sınırları yazıyor, not `lab_sonuc.karar_notu`'na **donuyor** (kılavuz değişse eski rapor kendi eşiğiyle okunur). **Bayrağı ezmiyor** — ayrı bilgi, ⚑ sembolüyle bayrağın yanında. Tanım tetkik kartındaki **Klinik Karar Sınırları** sekmesinde; sınır **tohumlanmadı** (hangi kılavuz kurumun kararı). |
| L16 | LBYS VEM (6 madde) | **Y** | H3/H4 ile aynı altyapı. |

---

## 5. DHBS — hiç denetlenmedi, diş için tam checklist

### 5.1 Protez / laboratuvar

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| D1 | Protez iş süreçlerini takip için **barkotlama** | **V** (874) | **Yapıldı.** Barkot gövdesi `isemri_no`'nun kendisi (ikinci numara üretilmedi); Code 128 etiket sayfası (`/dis-lab/etiket`), kanban'da okutma kutusu, okutmayla açılan aşama satırı `kaynak = 2` ile işaretleniyor - denetimde "barkotla takip" iddiasının kanıtı bu. |
| D2 | Ölçü takip işlemleri | **V** | `dis.lab_asama` 9 aşamalı (ölçü bekliyor → gönderildi → tasarım onayı → üretim → geldi → prova → geri gönderildi → teslim → iptal). |
| D3 | Ölçü takibinde **uyarı sistemi** | **K** | `beklenen_tarih` var; geciken iş emri için uyarı/bildirim yok. İş: gecikme bildirimi + panoda uyarı. |
| D4 | Ölçü **ret** işlemleri | **K** | "Geri gönderildi" aşaması var; ret sebebi ve ret kaydı ayrı tutulmuyor. İş: ret sebebi + kimin reddettiği. |
| D5 | Protez raporları | **K** | Liste/pano var; denetimin beklediği protez raporu seti (iş emri dökümü, lab performansı, gecikme) tanımlanmalı. |
| D6 | Devam eden protez işlemleri fatura ekranına **düşmemeli** | **?** | Kuralın uygulandığı doğrulanmadı. İş: teslim edilmemiş iş emrinin ücretlendirmeye girmediğinin testle sabitlenmesi. |

### 5.2 Diş şeması / klinik

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| D7 | Oral diagnoz (mevcut ağız yapısı) · planlama · tedavi'nin **diş şeması üzerinden karşılaştırılması** | **V** | **Listede yanlış "kısmi" yazılmıştı; 706'dan beri var:** şemada katman çipleri (Mevcut durum · Planlanan · Tamamlanan) ve üç katmanın ayrı çizimi (planlanan kesikli kırmızı, tamamlanan yeşil çerçeve). İş yok. |
| D8 | Diş resminin üzerine gelince o dişe yapılmış işlemlerin görünmesi | **V** (874) | **Yapıldı.** Dişin SVG ipucunda son beş işlem; ayrıca şemanın altında sabit yükseklikli şerit (dokunmatikte ve baskıda ipucu yoktur). Veri kartla zaten geliyordu - ek istek açılmadı. |
| D9 | Ortodonti **ICON Skor** formu ekranı ve raporları | **V** (875) | **Yapıldı.** `dis_icon_skor` + beş bileşen formu (hasta kartı "📐 Ortodonti (ICON)" sekmesi) + yazdırılabilir rapor. Ağırlıklar ve eşikler şemada: toplam `fn_dis_icon_toplam` ile üretilmiş kolon, karmaşıklık/iyileşme fonksiyon; ekrandaki canlı önizleme de aynı fonksiyonu çağırır. **Kurulumda doğrulanmalı:** ağırlıklar (7/5/5/4/3), ihtiyaç eşiği 43 ve bantlar indeksin yayımlanmış tanımındandır. |

### 5.3 Sterilizasyon (868 sayesinde büyük ölçüde hazır)

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| D10 | Bowie-Dick · biyolojik · kimyasal indikatör sonuç ekranı ve takibi | **V** | `steril_dongu_indikator`, tür listesi Bowie-Dick/Helix/Sınıf 4-5-6/Biyolojik/Vakum. İş yok. |
| D11 | İndikatör olumsuzsa **alet girişi engelleniyor mu** | **V** | Engel kodları (`BD_ONAY`, `KARANTINA`, `SERBEST_EKSIK`) serbest bırakmayı durduruyor. Denetimde gösterilecek senaryo hazırlanmalı. |
| D12 | Her alete özgü **raf ömrü** + süresi geçende engelleme ve uyarı | **K** | `steril_set.raf_omru_ay` **set bazlı** var. "Her alete özgü" (birim bazlı istisna) ve raf ömrü dolmuş pakette **kullanım engeli + uyarı** doğrulanmalı. |
| D13 | Aletin geçmiş bilgisi takip edilebiliyor mu | **V** | `steril_paket_kullanim` (hasta/seans/hekim/okutan) + `steril_olay` + geri çağırma. İş yok. |

### 5.4 DHBS e-Nabız / USS (çoğu HBYS maddeleriyle ortak)

| # | Denetim maddesi | Durum | Yapılacak iş |
|---|---|---|---|
| D14 | Doktor ekranından hastanın e-Nabız hesabına mesaj | **V** (877 + 881) | H7 ile birlikte kapandı; diş hasta kartında "💬 e-Nabız Mesajı". |
| D15 | Doktor ekranından e-Nabız profiline erişim (SMS onayı, giriş) | **V** (878) | H6 ile birlikte: diş hasta kartında "🔓 e-Nabız Kayıtları". |
| D16 | Kan laboratuvarı varsa numune reddinde otomatik e-Nabız mesajı | **V** (879) | H1 ile birlikte kapandı. |
| D17 | Ameliyat/işlem randevusu iptalinde otomatik e-Nabız mesajı | **K** | Mesaj altyapısı hazır (877, `kaynak = 3`); randevu iptali olayına bağlanması kaldı - tek çağrı. |
| D18 | ADSM'den **Ağız ve Diş Sağlığı veri paketi** gönderimi | **K** (876) | **Yarım - bilerek.** Paket türü, içerik görünümü (`v_dis_agiz_dis_paket`: yapılan diş işlemleri + mevcut odontogram + DMFT), üretici dalı ve seans bitişi tetiği kuruldu; paket **kapalı** (`aktif = 0`, `uss_paket_kodu = '000'`). Sebep 105'tekinin aynısı: rehber paketin ADINI veriyor, USS numarasını ve eleman adlarını vermiyor. Açmak için numara rehberden yazılır, `aktif = 1` yapılır, USS'nin saydığı eksik eleman adları üretici dalına eklenir. |
| D19 | Radyoloji sonuç veri paketi | **V** (883) | H10 ile birlikte: 409 paketi rapor onayında üretiliyor. |
| D20 | Konsültasyon kayıt paketi | **V** (880) | H2 ile birlikte kapandı. |
| D21 | İşleme ait hekim puan bilgisi | **Y** | H15 — DHBS'de muafiyet yok. |
| D22 | İlaç adı ile barkodu aynı/boş gönderim | **K** | H16. |
| D23 | Reçete bilgileri ve ilaçlar e-Nabız'da görünüyor mu | **K** | 102 paketi ilaç taşıyor; reçete olarak göründüğü canlıda doğrulanmadı. |
| D24 | Gün sonu gönderimi · %95-103 oranı · KDS uyumu | **K** (884) | H13 ile aynı: gün sonu ve oran ekranı geldi, karşılaştırma tarafı kaldı. |
| D25 | Hastanın çıkış bilgisi | **V** | H11. |
| D26 | e-Nabız butonu standardı | **Y** | H8. |
| D27 | Yataklı tedavi kurumuysa uygunsuz klinik yatışı gönderimi | **K** | Yatış tarafı yalnız `700_yatis_tahakkuk`; klinik yatış kuralı yok. Diş kliniği yataklı değilse **muafiyet istenebilir**. |
| D28 | DHBS VEM (6 madde) | **Y** | H3/H4. |
| D29 | MKYS · MHRS (4 madde) | **Y** | H17/H18. |

---

## 6. Sıra önerisi

Bağımlılığa göre, en çok maddeyi birden kapatan önce:

1. ~~**H7** — e-Nabız hasta mesajı~~ — **877'de yapıldı** (gönderim metodu bekleniyor).
2. ~~**H6** — e-Nabız profil erişimi (SMS onaylı)~~ — **878'de yapıldı**, H6 + D15 kapandı.
3. ~~**H1 + L6** — numune reddi~~ — **879'da yapıldı**; D16 ile birlikte kapandı.
4. ~~**H2** — konsültasyon paketi~~ — **880'de yapıldı** (USS 252); D20 ile birlikte kapandı.
5. ~~**H13** — gün sonu + oran~~ — **884'te yapıldı**; kalan yalnız Bakanlık geri bildirimiyle karşılaştırma.
6. **H3/H4** — VEM. Tek başına büyük; eski denetimde **iki madde birden buradan kesildi**.
7. **H10** — altısından biri (409 radyoloji) **883'te yapıldı**; kalan beşi izlem modülü istiyor (§ 7.1).
8. ~~**H5** — BZBH~~ — **882'de yapıldı**.
9. Diş kalemleri: **D1** (barkot) → **D7/D8** (şema karşılaştırma + diş geçmişi) → **D9** (ICON) → **D18** (ADSM paketi).
10. Lab kalemleri: ~~**L9**~~ **886**, ~~**L5**~~ **887**, ~~**L3**~~ **888**, ~~**L7**~~ **889**, ~~**L13**~~ **890**, ~~**L8**~~ **891**, ~~**L10**~~ **892'de yapıldı**.
11. Karara bağlanacaklar (kod işi olmayabilir): **H15/D21** hekim puan, **H17/D29** MKYS-MHRS muafiyeti, **D27** yataklı tedavi muafiyeti.

---

## 7. Doğrulanmamış tek madde

**D6** (devam eden protezin faturaya düşmemesi) koda bakılarak kesinleştirilemedi;
onaylanırsa önce davranış çalıştırılarak görülmeli, sonra test yazılmalı.

---

## 7.1 H10'un kalan beş paketi — neden yazılamadı, ne gerekiyor

409 (Radyoloji Sonuç) yazılabildi çünkü kaynağı vardı: onaylanmış radyoloji
raporu. Kalan beş paket **bizde hiç tutulmayan veriyi** istiyor; paketi yazmak
değil, o veriyi toplayan ekranı açmak gerekiyor.

| USS paketi | Ne ister | Bizdeki karşılığı | Gereken iş |
|---|---|---|---|
| ~~**207** Aşı Veri Seti~~ | uygulanan aşı, doz sırası, lot, uygulama yolu | **898'de yapıldı** | — (SKRS aşı listesi çekildi: ad+kod) |
| ~~**221** Gebe İzlem~~ | izlem sırası, TA/kilo, FKS, risk, öneri | **900'de yapıldı** | — |
| ~~**223** Gebelik Bildirim~~ | son adet tarihi + bir önceki doğum durumu | **901'de yapıldı** | — |
| ~~**224** Gebelik Sonucu~~ | sonlanma tarihi/sonucu, doğum yöntemi, bebek sayıları, sezaryen endikasyonu | **902'de yapıldı** | — |
| ~~**209** Bebek/Çocuk İzlem~~ | izlem ayı, boy/kilo/baş çevresi, taramalar, D vit/demir | **899'da yapıldı** | — (WHO/Bakanlık LMS eğri verisi yüklenecek) |

**Öneri:** bunlar tek tek "paket" işi değil, **iki modül**: (1) *gebelik &
doğum dosyası* (223 · 221 · 224), (2) *aşı ve bebek/çocuk izlemi* (207 · 209).
Her modül kendi ekranıyla birlikte planlanmalı; paketleri bu turdaki
252/411/214/409 deseniyle bağlamak sonra birkaç saatlik iş.

**Not:** kurum bir ADSM / diş kliniği ya da özel dal merkeziyse bu beş paket
için muafiyet isteyebilir - gebe izlemi yapmayan bir kurumdan gebe izlem
paketi beklenmez. Muafiyet kararı kurum tipine göre verilmeli (§ 11).
