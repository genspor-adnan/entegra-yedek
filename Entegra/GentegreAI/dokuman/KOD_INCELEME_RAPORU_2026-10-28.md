# GentegreAI kod inceleme raporu

Tarih: 28.10.2026. İncelenen sürüm: çalışma ağacının mevcut hali; commit edilmemiş değişiklikler dahil.

## Değerlendirme

**Mimari temel iyi; güvenlik kuralları bütün uçlarda tutarlı uygulanmadığı için mevcut kodu üretim için güvenli kabul etmiyorum.** Sorun, yalnızca kodun büyüklüğü veya yapay zekâyla yazılması değil: ortak korumaları atlayan özel iş akışları var. Merkezi bir yetki sisteminin bulunması, onu kullanmayan uçları korumuyor.

İnceleme sonucunda **5 yüksek öncelikli (P1), 2 orta öncelikli (P2) bulgu** kaydedildi. P1 bulguları, ilgili işlevlerin müşteri kullanımına açılmasından önce ele alınmalı. Bunlar kod üzerinden saptanan sorunlardır; canlı sistemde saldırı yapılarak doğrulanmış olaylar değildir.

## Kapsam ve yöntem

- API başlangıcı, JWT üretimi/doğrulaması, hesap ve oturum kapıları, refresh rotation, parola değiştirme ve oturum iptali incelendi.
- Liste/kart katalogları, merkezi kayıt erişimi ve radyoloji özel uçları karşılaştırıldı.
- HTML basan web ekranları, masraf formu ve acil yatak etiketi; yeni rapor HTML temizleyicisi okundu.
- Yayın sırasında üretilen ayarlar ve yeni konteyner başlatma komutu incelendi.
- Mevcut API ve web testleri çalıştırıldı.

Bu, risk odaklı bir kaynak kod incelemesidir. Bütün ERP/HBYS modüllerinin tüm satırları incelenmedi. Canlı sunucu, gerçek müşteri verisi, yük testi, tarayıcı üzerinden uçtan uca saldırı doğrulaması ve bağımlılık CVE taraması kapsam dışında kaldı. Aşağıdaki liste tüm açıkların tükendiği anlamına gelmez. İşlev kodu değiştirilmedi; bu rapor eklendi.

## Bulgular

### B01 — P1: Yayın akışı depodaki JWT anahtarını devralıyor

**Yer:** `api/src/Gentegre.Api/appsettings.json:13`, `api/src/Gentegre.Api/Program.cs:247`, `yayin/yayinla.ps1:260`, `yayin/sunucu-guncelle.sh:116`.

Ana yapılandırmada geliştirme ibaresi taşıyan sabit bir imza anahtarı bulunuyor. `dotnet publish` sonrasında üretilen Production ayarı bağlantı dizesi, CORS ve AllowedHosts'u değiştiriyor; JWT anahtarını değiştirmiyor. Yeni konteyner oluşturma komutunda da anahtar için ortam değişkeni verilmiyor. Böylece depodaki yayın akışı ek bir dış müdahale yoksa bilinen anahtarla çalışıyor. Anahtarın değeri bu rapora alınmadı.

**Etki:** Anahtarı bilen biri geçerli imzalı token üretebilir. `OturumKapisi` ve `BaglamCozucu` kullanıcının güncel kaydını kontrol ettiği için rastgele bir yönetici rolü yazmak tek başına yeterli değildir; fakat mevcut aktif ve yetkili bir kullanıcının kimliğiyle token üretmek parola doğrulamasını aşabilir. Aynı anahtarın kurulumlar arasında paylaşılması etkiyi büyütür. Canlı konteynerlerin elle verilmiş ayrı anahtar kullanıp kullanmadığı doğrulanmadı.

**Düzeltme:** Her kurulum için kriptografik rastgele ayrı anahtar üretin, secret olarak sağlayın ve Production başlangıcında geliştirme/boş anahtarı reddedin. Mevcut anahtarı kullanmış kurulumlarda anahtar dönüşümüyle eski token'ları geçersizleştirin.

**Kabul testi:** Secret verilmeden Production başlamamalı; geliştirme anahtarıyla imzalanmış token reddedilmeli; A kurulumunun token'ı B kurulumunda geçmemeli.

### B02 — P1: Radyoloji özel uçlarında kayıt kapsamı atlanıyor

**Yer:** `api/src/Gentegre.Api/Uclar/RadyolojiUclari.Rapor.cs:27`, `:304`; `RadyolojiUclari.OnayVeBulgu.cs:25`; karşılaştırma: `api/src/Gentegre.Cekirdek/Katalog/KaynakKatalogu.Radyoloji.cs:151`, `api/src/Gentegre.Api/AraKatman/KayitErisimi.cs:75`.

`GET /api/radyoloji/istem/{id}/rapor` kaynak yetkisini kontrol edip `where i.id = @p0` ile hasta ve rapor bilgilerini okuyor. Kaydetme ve onay uçları da aksiyon izninden sonra doğrudan kimlikle çalışıyor. Grup `RequireAuthorization()` kullanıyor; ancak kayıt erişimi sağlayan bir endpoint filtresi yok. Bu uçlarda `KayitErisimi` çağrısı, aktif şube veya portal sahiplik filtresi bulunmuyor. Oysa liste kataloğu şube ve portal koşullarını açıkça tanımlıyor.

**Etki:** İlgili kaynak/aksiyon izni olan kullanıcı, listesinde bulunmayan başka şubeye ait istemi kimliğini değiştirerek okuyabilir; yazma/onay yetkisi varsa kapsam dışındaki rapor üzerinde işlem yapabilir. Portal hesabında istismar, ayrıca uçtaki kaynak yetkisinin o hesaba verilmiş olmasına bağlıdır. Bu açık anonim erişim değildir.

**Düzeltme:** İstem kimliği kullanan her uçta `radyoloji-istem` için merkezi kayıt erişimini zorunlu tutun. Rapor kimliği alan uçlarda önce bağlı istemi çözün, sonra aynı kapıyı uygulayın. Kaynak okuma iznini de listeyle uyumlu hale getirin. Geçmiş tetkik listelerini ayrıca aynı erişim kurallarıyla süzün.

**Kabul testi:** A şubesinde çalışan, B şubesine izni olmayan kullanıcı B istemini okuyamamalı/yazamamalı/onaylayamamalı; yanıt 404 olmalı. Başka hastanın portal kimliğiyle aynı denemeleri tekrarlayın.

### B03 — P1: Yazdırma ekranlarında kalıcı XSS riski

**Yer:** `web/src/sayfalar/ik/MasrafKarti.tsx:250`, `web/src/bilesenler/acil/AcilYatakSekmeleri.tsx:107`; etkiyi artıran saklama: `web/src/api/cekirdek.ts:43`.

Masraf formunda `belgeNo`, `aciklama`, `konu`, personel adı gibi değerler HTML kaçışından geçirilmeden `document.write` içine yerleştiriliyor. Acil yatak etiketinde de `deger.kod` ve `deger.ad` doğrudan HTML'e yazılıyor. Bunlar kullanıcı tarafından değiştirilebilen metinler. Örneğin yatak adı için `<svg onload="window.__reviewXss=1">` gibi kısa bir değer metin yerine olay işleyicisi olarak yorumlanır.

**Etki:** Zararlı değer içeren kaydı yazdıran kullanıcının açılan aynı kökenli penceresinde JavaScript çalışabilir. Access ve refresh token'ları localStorage'da tutulduğu için, başarılı XSS oturum ele geçirmeye ve mağdurun yetkileriyle API çağrılarına dönüşebilir. Kod yolu doğrulandı; tarayıcıda gerçek oturumla istismar çalıştırılmadı.

**Düzeltme:** Yazdırılacak düz metni React/DOM `textContent` ile üretin veya ortak HTML kaçış yardımcısını bütün interpolasyonlarda uygulayın. Zengin HTML gereken yerleri ayrı beyaz liste temizliğinden geçirin. CSP ek savunma sağlar; kaçışın yerine geçmez. Token saklama tercihini ayrıca gözden geçirin; cookie'ye geçilecekse CSRF tasarımıyla birlikte ele alın.

**Kabul testi:** Kaydedilmiş ad/açıklamalardaki `<svg onload=...>` ve `<img onerror=...>` yazdırmada düz metin görünmeli; hiçbir işaretleyici çalışmamalı. Diğer `document.write` kullanan ekranları aynı testle tarayın.

### B04 — P1: Radyoloji raporunda kayıp güncelleme ve onayla yarışma

**Yer:** `api/src/Gentegre.Api/Uclar/RadyolojiUclari.Rapor.cs:313`, `:345`, `:360`; `RadyolojiUclari.cs:34`; `RadyolojiUclari.OnayVeBulgu.cs:37`.

Rapor kaydetme isteğinde sürüm damgası yok. Mevcut rapor ve `kilit` düz SELECT ile okunuyor; ardından başlık güncelleniyor, bütün bölümler silinip tekrar yazılıyor. `xmin` koşulu veya `FOR UPDATE` bulunmuyor. Onay uygunluğu da onay transaction'ı başlamadan kontrol ediliyor. İncelenen migration tanımlarında rapor metnini bu yarışmaya karşı koruyan bir kilit trigger'ı bulunmadı.

**Etki:** Aynı raporu açan iki kişinin kayıtlarından sonuncusu öncekinin metnini sessizce ezebilir. Ayrıca kaydetme işlemi `kilit=0` gördükten sonra başka işlem raporu onaylarsa, kaydetmenin koşulsuz UPDATE'i onaylı raporun bölümlerini değiştirebilir. Transaction kullanılması, eski sürümü yazmayı veya kontrol ile yazım arasındaki yarışı tek başına önlemez.

**Düzeltme:** Rapor sözleşmesine sürüm ekleyin; aynı transaction içinde rapor satırını kilitleyin, güncel kilit/durum/sürümü doğrulayın, sonra detayları yazın. Onay da aynı satır kilidi altında uygunluğu tekrar kontrol etmeli. Eski sürüme 409 dönün; gerekirse parent sürümünü ilerleten DB koruması ekleyin.

**Kabul testi:** İki istemci aynı sürümü kaydettiğinde yalnız biri başarılı olmalı. Kontrollü eşzamanlı onay/kaydet senaryosunda onaylanmış içerik değişmemeli.

### B05 — P1: Oturum iptali eldeki access token'ı durdurmuyor

**Yer:** `api/src/Gentegre.Api/AraKatman/OturumKapisi.cs:37`, `api/src/Gentegre.Veri/Depolar/KullaniciDeposu.cs:491`, `api/src/Gentegre.Api/Servisler/JwtUretici.cs:42`, `KimlikServisi.cs:247`, `:307`.

Çıkış, cihaz oturumu kapatma ve parola değişimi `oturum` satırlarını iptal ediyor. Ancak access token oturum/aile kimliği taşımıyor; her istekteki kapı yalnız hesabın aktifliğini, rol atanmasını ve parola değiştirme bayrağını kontrol ediyor. Oturum iptal durumu veya parola sonrası token sürümü doğrulanmıyor.

**Etki:** Çalınmış access token, kullanıcı cihazı kapatsa veya parolasını değiştirse de token süresi sonuna kadar çalışabilir. Varsayılan süre 30 dakika; gerçek süre DB ayarından değişebilir. Refresh'i iptal etmek yeni access token alınmasını engeller, mevcut olanı durdurmaz. Bu, güvenlik ekranındaki “oturumu kapat” davranışını eksik bırakır.

**Düzeltme:** JWT'ye doğrulanabilir oturum/aile kimliği bağlayın ve isteklerde iptal kontrolü yapın. Parola değişimi gibi bütün oturumları kapsayan olaylar için kullanıcı token sürümü veya geçerlilik başlangıcı ekleyin. Çok kısa access süresi yalnız maruziyeti azaltır.

**Kabul testi:** Access token'ı saklayın; başka cihazdan oturumu kapatın ve aynı token ile korumalı ucu çağırın: 401 olmalı. Parola değişimi ve refresh tekrar kullanımından sonraki aile iptalinde de deneyin.

### B06 — P2: Kilitli raporda “ön rapor” isteği istem durumunu geriye alıyor

**Yer:** `api/src/Gentegre.Api/Uclar/RadyolojiUclari.OnayVeBulgu.cs:63`.

`hedef` onay değilse rapor UPDATE'i `coalesce(kilit, 0) = 0` koşuluyla çalışıyor. Güncellenen satır sayısı kontrol edilmeden bağlı istemin durumu 4 yapılıyor ve değişiklik logu yazılıyor. Kilitli raporda ilk UPDATE sıfır satır etkilerken ikinci UPDATE çalışır. Ayrıca tanımsız bir `hedef` değeri de aynı kola düşüyor.

**Etki:** Onaylı rapor kilitli/onaylı kalırken istem “ön rapor” durumuna gerileyebilir. İş listesi ve denetim izi gerçek rapor durumuyla çelişir. Bu hata için eşzamanlı istek gerekmez.

**Düzeltme:** Hedef değerleri beyaz listeyle doğrulayın; geçişi mevcut durum/kilit koşuluyla atomik yapın. Etkilenen satır yoksa transaction'ı sonlandırın; istem ve logu değiştirmeyin.

**Kabul testi:** Onaylı rapora ön rapor geçişi ve tanımsız hedef gönderildiğinde hata dönmeli; rapor, istem ve log değişmemeli.

### B07 — P2: Üretim API'si veritabanına postgres hesabıyla bağlanacak şekilde yayımlanıyor

**Yer:** `yayin/yayinla.ps1:262`.

Üretilen Production bağlantı dizesi `Username=postgres` kullanıyor. Bu rolün canlı sunucudaki yetkileri sorgulanmadı; standart PostgreSQL kurulumunda postgres bir süper kullanıcıdır. Yayın akışı uygulamaya ayrılmış sınırlı bir rol oluşturmuyor/kullanmıyor.

**Etki:** API sürecindeki bir açık veya sızan bağlantı bilgisi, uygulamanın ihtiyaç duyduğu veri yetkilerinden çok daha geniş bir yetkiye dönüşebilir. Aynı PG kümesindeki diğer kurulumların izolasyonu da zarar görebilir.

**Düzeltme:** Uygulama çalışma rolünü migration/yönetim rolünden ayırın. Her kurulum için yalnız kendi DB'sinde gereken tablo/sequence/fonksiyon izinlerine sahip, süper kullanıcı olmayan rol kullanın; diğer DB'lere erişimini kısıtlayın.

**Kabul testi:** Uygulama rolü tablo/rol/veritabanı oluşturamamalı, başka kurulumun DB'sine erişememeli; normal API işlemleri çalışmalı. Göçler ayrı rol ile uygulanmalı.

## İyi kurulmuş parçalar

- Çekirdek, veri ve API katmanları ayrılmış; ortak katalogların liste/form üretimini yönlendirmesi tekrarları azaltıyor.
- Liste sorgularındaki beyaz liste ve parametre yaklaşımı güçlü bir temel. Bu incelemede bir SQL injection bulgusu kaydedilmedi; bütün sorguların denetlendiği anlamına gelmez.
- Şube yazma kontrolü ile kayıt/portal kapsamını merkezileştiren yardımcılar mevcut. B02'nin çözümü için yeni bir sistem icat etmek gerekmiyor.
- Refresh rotation satır kilidi ve transaction kullanıyor; tekrar kullanımda aile iptali hata dönmeden commit ediliyor.
- Finans hesaplarının ortak kurala ve DB dip toplamına dayanması, farklı ekranların farklı tutar üretme riskini azaltıyor.
- Rapor HTML'i için sunucuda beyaz liste temizliği eklenmiş. Bu koruma, B03'teki düz metin yazdırma yollarında kullanılmıyor.
- DB testleri ortak geliştirme DB'sine sessizce bağlanmıyor; atlanan testler görünür. Bu önemli bir veri güvenliği tercihi.

## Çalıştırılan doğrulamalar

| Kontrol | Sonuç |
|---|---|
| API: `dotnet test tests\Gentegre.Testler --no-restore --verbosity quiet` | 829 toplam: **420 geçti, 409 atlandı, 0 başarısız** |
| Web: `npm test -- --reporter=dot` | **142 dosyada 1.003 test geçti** |

API test çalıştırması başarılı derlendi; test kodunda nullable/analyzer uyarıları görüldü. Web testlerinde jsdom `Window.alert` uygulanmadı uyarıları çıktı; testler başarısız olmadı. Web üretim derlemesi ayrıca çalıştırılmadı.

**409 atlanan DB testi güvenlik veya iş akışı kanıtı sayılamaz.** Bu çalıştırmada test DB bağlantısı sağlanmadığı için gerçek HTTP/DB bütünleşmesi doğrulanmadı. İzole, güncel şemalı bir test DB ile `GENTEGRE_TEST_DB` ve `GENTEGRE_TEST_ZORUNLU=1` kullanılarak tekrar çalıştırılmalı. Paylaşılan geliştirme DB'sine fixture yazılmadı.

## Önerilen düzeltme sırası

1. JWT secret yönetimi ve mevcut kurulumlarda anahtar dönüşümü (B01).
2. Radyoloji kayıt erişim kapısı ve olumsuz yetki testleri (B02).
3. HTML yazdırma yollarında kaçış ve regresyon testleri (B03).
4. Rapor sürüm/kilit/geçiş işlemlerinin atomik hale getirilmesi (B04, B06).
5. Gerçek access token iptali (B05).
6. Üretim DB rol ayrımı (B07).

Her düzeltmenin kabul testini izole DB ile yayın kontrolüne ekleyin. Özellikle yalnız başarılı senaryoyu değil, başka şube/başka hasta/eski sürüm/iptal edilmiş oturum isteklerini de test edin. Mevcut yeşil test sayısı, bu sınırların korunduğunu tek başına göstermiyor.
