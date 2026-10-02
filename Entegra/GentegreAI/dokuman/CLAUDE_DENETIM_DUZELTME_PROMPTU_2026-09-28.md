# Claude uygulama promptu — Gentegre AI denetim bulguları

Aşağıdaki metni Claude'a görev olarak ver. Dosya yolları aksi belirtilmedikçe `GentegreAI/` köküne göredir.

---

Gentegre AI projesindeki denetim bulgularını doğrula, düzelt ve testlerle kanıtla. Yalnız öneri veya plan sunup durma; kapsam içindeki kod, test, migration araçları ve dokümantasyon işlerini uygula. Ana kanıt belgesi aynı dizindeki `DENETIM_2026-09-28.md` dosyasıdır. Rapor tarihsel bir incelemedir: satır numaraları, sayımlar ve sorunlar değişmiş olabilir. Her bulgunun güncel durumunu inceleyerek karar ver; doğru olmayan veya zaten çözülmüş bulgu için gereksiz değişiklik yapma, kanıtını kaydet.

## 1. Kapsam ve çalışma kuralları

- Yalnız `GentegreAI/` üzerinde çalış. Delphi uygulaması, ortak Delphi birimleri ve kardeş projeler kapsam dışı.
- Başlamadan geçerli `AGENTS.md`, ilgili `OKUBENI.md`, `dokuman/01_API_SOZLESMELERI.md` ve denetim raporunu oku. DB nesnesi için `db/GUNCEL.md` indeksine bak; indeks eskiyse gerçek en son tanımı da doğrula.
- Mevcut kullanıcı değişikliklerini koru. Dal değiştirme, reset/restore yapma, ilgisiz dosyaları düzenleme. Commit/push/yayınlama bu göreve dahil değil.
- Mevcut üç katmanı, sunucu kaynaklı metaveriyi, katalog beyaz listesini, parametreli SQL'i, `xmin` eşzamanlılığını, merkezi para hesabını ve transaction içindeki audit logunu koru.
- Türkçe alan adlarını, mesajları ve sözleşmeyi koru. API değişikliği gerekiyorsa React tüketicisini ve testleri birlikte güncelle.
- Gönderilmiş migration dosyalarını değiştirme. Gereken DB değişikliklerini mevcut en yüksek numaradan sonraki yeni dosyalara yaz; rapordaki 922 sayısını sabit kabul etme. Yeni dosyalar tekrar çalışmaya dayanıklı olmalı.
- Güvenlik kontrolünü yalnız arayüze veya tek bir örnek uca ekleyerek işi bitirme. Aynı sorumluluğu taşıyan çağrı yerlerini tara, mevcut ortak denetimi kullan veya dar kapsamlı ortak bir kapı oluştur.
- Geniş mimari yeniden yazımı, yeni framework ve ilgisiz bağımlılık yükseltmeleri yapma. Her değişiklik bir bulguya veya kabul kriterine bağlı olsun.
- Olağan kod/test düzenlemeleri için tekrar onay isteme. Üretime bağlanma, gerçek SMS/e-posta/entegratör çağrısı yapma ve çalışan kullanıcı API'sini durdurma. Test sunucusunda arka plan entegrasyonlarını devre dışı bırak veya taklit et.
- Bütünleşme, eşzamanlılık ve migration testleri için ayrı, açıkça test amaçlı PostgreSQL veritabanı kullan. Test bağlantısını `GENTEGRE_TEST_DB` ile açıkça ver ve hedefi doğrula. Paylaşılan geliştirme DB'sine fixture yazma; varsayılan bağlantıya sessiz düşme.
- Paylaşılan DB'de yalnız salt okunur analiz yap. Gerçek veriyi değiştirecek uzlaştırma/onarım için önce yedek, etkilenecek kayıtlar, uygulanacak dosya ve doğrulama planını hazırla; uygulama yetkisi ayrıca gerekli. Bundan bağımsız kod/test işlerine devam et.

## 2. Başlangıç ve izlenebilirlik

Git durumunu ve mevcut doğrulama komutlarını incele. Denetimdeki 12 bulgu için `doğrulandı / zaten çözülmüş / doğrulanamadı` durumunu kaydet. Kısa bir uygulama sırası çıkar ve aşağıdaki fazlara geç.

Her bulgu için sonuç kaydında şu bilgiler bulunsun: neden, değişen dosyalar, davranış öncesi/sonrası, test komutu ve sonucu, kalan risk/engel. Denetim raporunu tarihsel kanıt olarak koru; ilerleme ve sonucu ayrı `dokuman/DENETIM_DUZELTME_SONUCU_2026-09-28.md` dosyasında tut.

## 3. Faz A — şube, kayıt ve rol erişimi

### Bulgu 1: Şubesiz kullanıcıda filtre kalkması

Başlangıç noktaları: `IstekBaglami.cs`, `SorguUretici.cs`, `ListeUclari.cs`.

Şube gerektiren kaynakta aktif/yetkili şube yoksa erişim kapalı olsun. `null` şube bütün şubeleri gösterme anlamına gelmesin; şubesiz bağlam varsayılan olarak yazabilir olmasın. Meşru şubeler arası ortak kartlar ve ilk kurulum/yönetim akışları için mevcut sözleşmeyi incele; gerekiyorsa açık ve yetkilendirilmiş istisna kullan.

Kabul:

- Son şube yetkisi kaldırıldığında mevcut tokenla yapılan sonraki istekte şubeye bağlı veri dönmez.
- Yetkisiz `X-Sube-Id` reddedilir; yanlış biçimli başlık sessizce yetki genişletmez.
- Yetkili şube verisi görünür; ortak kaynakların meşru erişimi korunur.
- Salt okunur ve yazılabilir şube senaryoları ayrı test edilir.

### Bulgu 2: Yazma aksiyonlarında salt okunur şube

`AksiyonIste` çağrılarını incele; yazma yapan aksiyonları ortak bir yazma denetimine bağla. Sadece POST/GET ayrımına güvenme. Okuma aksiyonlarının salt okunur şubede çalışmasını koru. İlk somut regresyon `/api/fiyat-listesi/{id}/uret` olsun.

Kabul: Aksiyon yetkisi bulunan salt okuyucu yazamaz; reddedilen istekte iş verisi ve audit logunda yazma yan etkisi oluşmaz. Aynı işlem yazılabilir şubede başarıyla tamamlanır.

### Bulgu 3: Laboratuvar grafik kaydına erişim

`LabUclari.Grafik.cs` içindeki okuma, yükleme, değiştirme ve silme akışlarını incele. İstem satırı/hasta ilişkisini kullanarak şube, portal, hekim ve kayıt kapsamını mevcut ürün kurallarına göre doğrula. Grafik içeriği/doküman indirme yollarının aynı kapsamı uyguladığını kontrol et. RLS'yi topluca açarak geçiştirme.

Kabul:

- A şubesindeki kullanıcı B şubesinin satır ID'siyle grafik üstverisi, seri veya dosya içeriği alamaz/değiştiremez.
- Hasta/dış kurum portal hesabı başka kişinin kapsamındaki grafiğe ulaşamaz.
- Kaynak ve tetkik yetkileri ayrıca uygulanır; var olmayan ve kapsam dışı kayıtlar sözleşmeye uygun davranır, varlık bilgisi sızdırmaz.
- Yerel DB boş olsa bile izole test fixture'ı ile izinli ve izinsiz yollar gerçekten denenir.

### Bulgu 7: JWT'de kalan eski rol

Tetkik izinlerini tokenın eski `RolId` değerinden değil DB'deki güncel etkili rol kümesinden çöz. Ana/ek rol birleşimi ve izin kaldırma davranışı mevcut sözleşmeyle tutarlı olsun. Liste, grafik, rapor ve ilgili özel uçların aynı karar yolunu kullanmasını sağla. Yetki önbelleğinin rol değişikliğinde doğru geçersizleştiğini doğrula.

Kabul: Token değişmeden ana rol değişikliği, ek rol ekleme/çıkarma ve tetkik kısıt değişikliği sonraki istekte doğru sonucu verir. Genel kaynak izni ve tetkik izni birbirinin yerine geçmez.

## 4. Faz B — kimlik ve oturum

### Bulgu 4: Zorunlu parola değişimi

`parola_degismeli` sunucuda uygulanmalı. Parola değişimine ihtiyaç duyan oturum iş uçlarına erişemesin. Parola ekranının gerektirdiği sınırlı profil, parola değiştirme ve çıkış yollarını açıkça tanımla; bütün `/api/kimlik/*` grubuna sınırsız istisna verme. Bayrağın sonradan açılmasıyla mevcut tokenın davranışını da ele al.

Kabul: Arayüz atlanarak yapılan API çağrısı reddedilir; parola değiştirme tamamlanınca geçerli oturum akışı çalışır. Refresh veya şube değiştirme, parola kapısını aşamaz. Gerçek kullanıcı parolalarını topluca değiştirme.

### Bulgu 5: İlk parola belirlemenin korunması

Mevcut davet/parola sıfırlama servislerini incele ve uygun parçaları yeniden kullan. İlk parola akışında hesap ve istemci bazlı deneme sınırı, süre ve kilit denetimi uygula. TCKN son dört hanesini tek başına yeterli hesap sahipliği kanıtı olarak bırakma; süreli, tek kullanımlık doğrulama/davet yoluna bağla. Gerçek bildirim göndermeden taklit sağlayıcıyla doğrula. Kayıtlı iletişim kanalı olmayan kullanıcı için güvenli yönetici akışını tanımla.

Proxy arkasında IP çözümünü ele alırsan yalnız güvenilen proxyleri kabul et; istemcinin gönderdiği `X-Forwarded-For` değerine doğrudan güvenme. Hesap varlığı, TCKN, token veya parolayı hata/log yanıtında açığa çıkarma.

Kabul: Eşik sonrası denemeler reddedilir; süresi geçmiş/yeniden kullanılan doğrulama reddedilir; eşzamanlı kullanım iki ayrı başarı üretmez; saldırgan başka kullanıcının parolasını ayarlayamaz.

### Bulgu 6: Atomik refresh rotation

Eski token doğrulaması/tüketilmesi ve yeni oturum kaydı aynı bağlantı ve transaction içinde olsun. Koşullu yazma sonucunu veya satır kilidini kontrol et. Tekrar kullanım tespitindeki aile iptali, hata yanıtı dönerken yanlışlıkla rollback edilmesin. Yeni tokenın istemciye dönmesi DB commit başarısından sonra olsun.

Kabul:

- Aynı tokenla gerçekten eşzamanlı isteklerde en fazla bir yenileme başarılı olur; iki geçerli dal oluşmaz.
- İptal edilmiş tokenın tekrar kullanımı mevcut sözleşmedeki aile iptalini kalıcı yapar.
- Yeni kayıt/commit öncesi hata eski tokenı yarım işlemle tüketmez.
- Süresi dolmuş token, pasif hesap ve iptal edilmiş aile reddedilir.
- Testler zamanlama için rastgele bekleme yerine bariyer/kontrollü eşzamanlılık kullanır.

Ayrı sekmelerde refresh yarışını da değerlendir. Gerekliyse istemciler arası koordinasyon ekle; sunucunun tekrar kullanım korumasını kaldırarak oturum sorununu gizleme.

## 5. Faz C — web oturumu ve testler

### Bulgu 11: Geçici `/ben` hatası

`OturumBaglami.tsx` içindeki her hatada temizleme davranışını düzelt. Ağ hatası, timeout ve 5xx halinde tokenları koru; kullanıcıya güvenli yeniden deneme durumu göster. Kimlik reddi ile iş yetkisi reddini ayır; her 403'ü otomatik oturum kapatma sayma. Profil doğrulanmadan korunmuş ekranları açma.

Kabul: 502/503 veya ağ kesintisi refresh tokenı silmez; geçerli yeniden deneme oturumu geri yükler. Kesin oturum reddinde temizleme ve girişe dönüş çalışır. Sonsuz yenileme döngüsü oluşmaz.

### Bulgu 12: API test taklitleri

`basvuruEkrani.test.tsx` ve `basvuruKapat.test.tsx` taklitlerine eksik `basvuruBekleyenIstem` sözleşmesini doğru yanıtla ekle. Mevcut test yardımcılarını kullan; uygunsa ortak, tip denetimli fabrika oluştur. Testleri atlama, assertion silme veya üretim koduna sessiz fallback ekleyerek testleri yeşile çevirme.

Kabul: Web testlerinin tamamı çalışır. Başvuru görüntüleme, tahsilat ve kaydedilmemiş değişiklik uyarısı davranışları korunur.

## 6. Faz D — migration ve kurulum

### Bulgu 8: Defter/şema tutarsızlığı

Önce salt okunur uzlaştırma aracı/raporu hazırla: diskteki dosyalar, defterdekiler, kayıtlı olmayan fakat etkisi görülenler ve gerçekten eksik olduğu kanıtlananlar. Bir tablonun veya fonksiyonun bulunması migrationın tamamının uygulanmış olduğunu kanıtlamaz. Raporun 267 sayısını güncel ölçümle yeniden belirle.

İçerik özeti eklenirse geçmişte kaydedilmeyen hash'i bugün hesaplayıp "uygulanan içerik doğrulandı" gibi sunma. Eski kayıtlar için doğrulanmamış durumunu açıkça taşı. Genel `TemelAl`, tüm dosyaları yeniden çalıştırma veya gelişigüzel defter doldurma yapma.

Kabul: Araç salt okunur çalışır ve belirsiz dosyaları açıkça işaretler. Paylaşılan DB'ye uygulanacak plan ayrı, gözden geçirilebilir ve yedekli hazırlanır. İzole test DB'sinde bekleyen, uygulanmış ve değiştirilmiş dosya durumları ayrılır.

### Bulgu 9: Boş PostgreSQL kurulumu

`db/kur.ps1 -SadeceSema` güncel şemayı MSSQL kaynağı olmadan kurabilsin. Gerekli şube/kurulum tohumlarını ve migration bağımlılıklarını açıkça yönet. Yalnız dosya adına bakarak bütün DML dosyalarını atlama; şema için gerekli referans/tohum verisi korunmalı. Aktarım gerektiren dosyalar "uygulandı" ile karıştırılmadan izlenmeli.

Kabul: İzole boş DB'de güncel şema kurulur; ikinci çalıştırma zararsızdır; temel kimlik/liste/kart sözleşmesi çalışır. Test gerçek migration zincirini kullanır. Tarihsel dosya hatalarını değiştirmeden çözülemeyen bağımlılık varsa kanıtı ve ileriye dönük çözümü raporla.

### Bulgu 10: Migration atomikliği ve yayın geri alması

Yerel kurulum ve sunucu güncelleme betiğinde transactiona uygun dosyayı defter kaydıyla birlikte tek işlemde uygula. SQL ve defter hataları süreçte başarısız çıkış kodu vermeli. Migration içindeki açık transactionlar, psql komutları ve transaction dışında çalışması gereken ifadeleri incele; körlemesine bütün dosyalara `BEGIN/COMMIT` sarma. Eşzamanlı iki güncelleyicinin aynı dosyayı çalıştırmasını engelle.

Kabul:

- Test migrationının ortasında oluşturulan hata, önceki ifadeleri ve defter kaydını geri alır.
- Başarılı çalıştırma tek defter kaydı bırakır; tekrar çalıştırma aynı değişikliği uygulamaz.
- Transaction dışı istisnalar açıkça tanımlı ve testlidir.
- API/web geri alma, DB'nin de geri alındığı şeklinde raporlanmaz; şema uyumluluğu ve yedekten dönüş sınırları belgelenir.
- Yayın betiği düzenlenir/test edilir; üretime dağıtım yapılmaz.

## 7. Faz E — veri kalitesi ve bakım borcu

- `NOT VALID` kısıtlarını ve aykırı kayıt sayılarını yeniden ölç. Eski veriyi korumak için bilinçli bırakılan kısıtları hata diye topluca değiştirme. Doğum tarihi/cinsiyet uydurma, kişisel veri örneklerini rapora kopyalama. Doğrulanmış gerçek bilgi gerektiren kayıtları açık iş olarak raporla. Uygun kısıtlar için yeni, önkoşulları kontrol eden doğrulama migrationı hazırla ve izole DB'de dene.
- Test projesini çözüm/CI doğrulama akışına dahil et. DB bağlantısı yokken testlerin normal dönüp başarılı görünmesini düzelt: yerelde açık skip mümkün, zorunlu bütünleşme/CI aşamasında erişilemeyen DB başarısız olmalı. Kurulu xUnit sürümünün gerçek desteğini kullan.
- API nullable uyarılarını incele; gerçek null durumunu ele al veya kanıtlanmış değişmezi kodda açıklaştır. Toplu `!`, `#pragma` veya warning kapatma ile temiz görünüm yaratma.
- Web rota bazlı yüklemesini mevcut router ile iyileştir. Loading/error sınırlarını ekle; giriş, derin bağlantı, portal ve yetki kapıları korunmalı. Önce/sonra ana JS ve gzip boyutlarını ölç; paketi sırf uyarı sınırını yükselterek küçülmüş sayma.
- Yeni migrationlardan sonra `araclar/guncel_indeks.ps1` ile `db/GUNCEL.md` üret. `OKUBENI.md` ve etkilenen API sözleşmesi bölümlerini gerçek davranışla eşitle; statik sayıları gereksiz yere çoğaltma.

## 8. Son doğrulama ve teslim

Çalışan API DLL'leri kilitliyse ayrı çıktı yolu kullan; kullanıcı sürecini kapatma. Aynı proje için derleme ve test derlemesini çakıştırma. Önce etkilenen testleri, ardından tamamlanma aşamasında bütün API/web testlerini uygun ortamda çalıştır. Gereksiz tekrarlı tam test koşuları yapma.

Temel kapılar:

```text
api/: dotnet build -p:OutputPath=bin/AuditFix/
api/: dotnet test tests/Gentegre.Testler -p:OutputPath=bin/AuditFixTests/ --logger "console;verbosity=normal"
web/: npm run build
web/: npm test
```

API test koşusundan önce `GENTEGRE_TEST_DB` izole test DB'sine açıkça ayarlanmış olmalı. Sonuçta `[ATLANDI]`, skip, keşfedilen/çalışan test sayısı ve gerçek DB bağlantısını kontrol et. Yeşil çıkış kodunu tek başına yeterli sayma. Yeni güvenlik testleri gerçek erişim kararını ve yan etkileri doğrulasın; yalnız kaynak metninde anahtar sözcük arayan testlerle yetinme.

Sonuç dosyasında her bulgu için `düzeltildi ve doğrulandı / zaten çözülmüş / açık / dış işlem bekliyor` durumunu yaz. Değişen dosyaları, migrationları, test sayılarını, derleme uyarılarını ve paket boyutu farkını belirt. Gerçek veriye müdahale, üretim yayını veya eksik dış erişim gerektiren işleri tamamlanmış gösterme. Engelli alt işi ayırıp bağımsız yetkili işleri tamamla.

Tamamlanma ölçütü: Doğrulanan kapsam içi kod açıkları giderilmiş, eski davranıştaki açığı yakalayan testler eklenmiş, API/web derleme ve test kapıları gerçek çalışmayla doğrulanmış, migration araçları izole DB'de sınanmış ve kalan dış işlemler somut uygulanabilir planla teslim edilmiş olsun.
