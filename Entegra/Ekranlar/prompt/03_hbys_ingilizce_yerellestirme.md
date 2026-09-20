# HBYS İngilizce Yerelleştirme Promptu

GentegreAI içindeki HBYS modülünü İngilizceye (`en-US`) hazırla.

## Amaç

HBYS'de kullanıcıya görünen tüm metinlerin çevrilebilir olmasını ve eksiksiz İngilizce çevirisinin eklenmesini sağla. Kapsama ekran başlıkları, menüler, sekmeler, kart/form alanları, grid kolon başlıkları, filtreler, butonlar, işlem/ad katalogları, doğrulama ve hata mesajları, onay pencereleri, bildirimler, boş durum metinleri, ipuçları, durum adları, yazdırma/rapor metinleri ve API'den dönen kullanıcı mesajları dahildir.

## Mimari kurallar

- Yalnızca `GentegreAI/` web ürününde çalış. Delphi uygulamasına dokunma.
- Önce kökteki `AGENTS.md` ile ilgili `GentegreAI/**/OKUBENI.md` dosyalarını tamamen oku.
- `GentegreAI/dokuman/01_API_SOZLESMELERI.md`, `GentegreAI/dokuman/00_TARIHCE.md` ve gerekiyorsa `GentegreAI/db/GUNCEL.md` dosyalarını incele.
- HBYS ekranlarının metadata'sı büyük ölçüde sunucudan gelir. Kolon adları, etiketler, gruplar, zorunluluk bilgileri ve işlem kataloğu için istemcide ikinci bir iş kuralı veya bağımsız metadata kopyası oluşturma.
- API ve web arasındaki alan adları birebir aynıdır. Sözleşme alanlarını çevirme veya yeniden adlandırma; yalnızca kullanıcıya gösterilen metinleri yerelleştir.
- Veritabanı migration geçmişini değiştirme. DB değişikliği gerekirse `db/GUNCEL.md` dosyasını kontrol et ve yeni, sıradaki numarayla migration oluştur.
- `mantik` alanlarının `smallint` olduğu kuralını koru.
- Para hesaplarını, yetki kontrolünü, şube filtresini ve diğer iş kurallarını değiştirme.
- Tasarım ve yerleşimi mümkün olduğunca koru. Uzayan çevirilerde kırılma ve taşmayı düzelt; anlam kaybettirecek kısaltma yapma.

## Uygulama yaklaşımı

1. Mevcut yerelleştirme altyapısını ve kullanıcıya görünen metin kaynaklarını araştır:
   - `web/src` içindeki sabit metinler
   - sunucudan gelen kaynak, kart ve liste metadata etiketleri
   - API doğrulama, hata ve başarı mesajları
   - DB fonksiyonları, view'lar veya katalog kayıtlarından gelen başlıklar
   - rapor ve yazdırma metinleri
2. Bulguları dosya ve kategori bazında özetle. Var olan i18n sistemini genişlet; yoksa proje yapısına uygun, merkezi ve tip güvenli bir çözüm kur.
3. Varsayılan dili Türkçe (`tr-TR`) olarak koru. İngilizceyi `en-US` locale koduyla ekle ve dil seçimini kalıcı hale getir.
4. Tarayıcı dili yalnızca ilk varsayılanı belirleyebilir; kullanıcının seçimi öncelikli ve kalıcı olmalıdır.
5. Yerelleştirme anahtarları kararlı ve anlam tabanlı olsun. Türkçe metni anahtar olarak kullanma.
6. Dinamik değerlerde string birleştirme yerine adlandırılmış parametreler kullan. Örnek: `{hastaAdi} adlı hastanın kaydı bulunamadı`.
7. Çoğul, tarih, saat, sayı ve para biçimlendirmelerinde locale-aware yöntemler kullan. Türkiye'ye özgü iş kurallarını değiştirme.
8. API hata kodlarını ve makine sözleşmesini sabit tut. Kullanıcı metnini hata koduna göre yerelleştir; istemciyi ham sunucu cümlesine bağımlı yapma.
9. Sunucu metadata'sının çevrilmesi gerekiyorsa istemcide alan adına göre dağınık eşleme yapma. Metadata sözleşmesini geriye uyumlu genişlet veya merkezi bir çeviri anahtarı mekanizması kur.
10. Bilinmeyen veya eksik anahtarda güvenli biçimde Türkçeye geri dön. Geliştirme ortamında eksik çeviri kolay fark edilsin.
11. Klinik kısaltmaları, ilaç/adlandırma standartlarını ve özel isimleri körlemesine çevirme. Belirsiz tıbbi terimleri listele; doğrulanmadan anlam değiştirecek çeviri yapma.
12. Kod içi loglar, teknik sabitler, endpoint'ler, izin kodları, kaynak adları, DB kolonları ve alan kimlikleri kullanıcı metni değilse çevrilmemelidir.

## Kapsam denetimi

Tüm HBYS route ve ekranlarını çıkar. Her ekran için şunları kontrol et:

- Sayfa ve sekme başlığı
- Grid kolonları
- Arama ve filtre alanları
- Form alanları ve yardım metinleri
- Buton ve menüler
- Doğrulama, hata, başarı ve onay mesajları
- Durum ve işlem adları
- Boş, yükleniyor ve yetkisiz durumları
- Rapor ve yazdırma çıktıları

Ham Türkçe kullanıcı metinlerini tara; teknik metinleri yanlış pozitif olarak değiştirme. Sonuçta `çevrildi`, `bilerek çevrilmedi` ve `insan/tıbbi terminoloji onayı gerekiyor` listelerini hazırla.

## Çeviri kalitesi

- İngilizce metinleri doğal, kısa ve sağlık yazılımı bağlamına uygun yaz.
- Aynı kavramı tüm ekranlarda aynı İngilizce terimle karşıla.
- Hasta güvenliğini etkileyebilecek tıbbi terimleri otomatik varsayımla çevirmeden işaretle.
- Türkçe kurum ve mevzuat terimlerinde gerekiyorsa özgün adı koruyup İngilizce açıklama ekle.
- e-Nabız gibi özel ürün ve servis adlarını çevirmeden koru.
- UI metinlerinde gereksiz Title Case kullanma; seçilen İngilizce stilini tutarlı uygula.
- Placeholder, değişken ve biçimlendirme işaretlerini eksiksiz koru.

## Doğrulama

- Değişiklikleri uygula; yalnızca analiz raporu verme.
- Web için `npm run build` çalıştır.
- API değiştiyse `dotnet build` çalıştır.
- İlgili testleri çalıştır. DB bağlantısı olmayan testlerin `[ATLANDI]` ile sahte yeşil verebildiğini kontrol et ve açıkça raporla.
- Türkçe ve İngilizce için hasta arama/kayıt, randevu, muayene, laboratuvar, radyoloji, ilaç/karekod ve e-Nabız akışlarını doğrula.
- Türkçe fallback'i, eksik anahtar davranışını, değişkenli mesajları, çoğulları, tarih/sayı biçimlerini ve uzun grid başlıklarını test et.
- Mevcut kullanıcı değişikliklerini geri alma veya kapsam dışı dosyaları düzenleme.

## Teslimat

- Değiştirilen dosyaları ve kurulan yerelleştirme mimarisini kısa biçimde açıkla.
- Dil dosyalarının yerini ve yeni dil/metin ekleme yöntemini belirt.
- Çeviri kapsam raporunu sun.
- Otomatik çevrilmesi riskli tıbbi terimleri ayrı listele.
- Build/test komutlarını ve sonuçlarını, varsa `[ATLANDI]` testlerini belirt.
- Kalan ham kullanıcı metinlerini dosya ve satır numarasıyla raporla.

Hedef dil: İngilizce  
Hedef locale: `en-US`  
Varsayılan dil ve fallback locale: `tr-TR`
