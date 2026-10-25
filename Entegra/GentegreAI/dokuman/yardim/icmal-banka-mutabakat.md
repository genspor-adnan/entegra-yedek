---
id: icmal-banka-mutabakat
baslik: Banka Mutabakat İcmali
modul: finans
ekran: banka-mutabakat
rota: /banka-mutabakat
surec: icmal
roller: muhasebe, finans, yonetim
dil: tr
surum: 1
urun_modu: 0
yetki: finans.banka_mutabakat
erisim: kullanici
ozet: Banka, kredi kartı ve POS hesaplarında seçilen günün sonundaki banka bakiyesini sistem bakiyesiyle karşılaştırır; farkı iki listeyle açıklar (bankada olup sistemde işlenmemiş hareketler, sistemde olup bankaya düşmemiş kayıtlar), açıklanmayan farkı gösterir. API'siz hesaba elle gün sonu bakiyesi girilir, açıklanmayan fark 0 olan gün onaylanır ve tutanağı basılır.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
"Bankadaki para ile sistemdeki para tutuyor mu; tutmuyorsa farkın her kuruşu neden?" sorusunu cevaplar. Muhasebe her sabah (dünün gün sonu) ve ay sonunda kullanır. Rakamlar sunucuda hesaplanır; ekran toplama yapmaz.

## Bu ekranda neler yapabilirsiniz
- **Mutabakat gününü seçmek** — "📅 Mutabakat günü" kutusu; varsayılan dünün gün sonudur. Yanındaki listeden "Dün (gün sonu)" ya da "Ay sonu" hızlı seçimi yapılır. Onay her gün için ayrı tutulur.
- **Hesaba, şubeye göre süzmek** — "🏦 Hesap" ve "🏢 Şube" listeleri; "Kredi kartı / POS hesapları dahil" kutusu kaldırılırsa yalnız banka hesapları görünür.
- **Hesapları karşılaştırmak** — Hesaplar sekmesinde her hesabın banka bakiyesi, kaynağı (API / elle / ekstre), sistem bakiyesi, fark, işlenmemiş ve yoldaki kayıtlar, açıklanmayan fark ve durum rozeti (tutuyor / açıklandı / açıklanmayan fark / bakiye girilmedi / onaylı / bozuldu). Satıra tıklayınca o hesabın Mutabakat Tablosu açılır.
- **Mutabakat tablosunu okumak** — banka bakiyesi ± sistemde olup bankaya düşmemişler = düzeltilmiş banka bakiyesi; sistem bakiyesi ± bankada olup işlenmemişler = düzeltilmiş sistem bakiyesi; ikisinin farkı açıklanmayan farktır.
- **Bankadan çekmek** — "🔄 Bankadan Çek (tümü)" API'si bağlı bütün hesapların yeni hareketlerini çeker (Banka Hareketleri ile aynı işlem).
- **İşlenmemiş hareketleri işlemek** — İşlenmemiş sekmesinde öneri hazır satırları işaretleyip "✓ Seçilenleri İşle" ya da satırdaki "✓ İşle"; öneriyle kasa işlemi yazılır. Öneri yoksa "seç…" Banka Hareketleri ekranını açar.
- **Var olan kasa işlemine eşleştirmek** — işlenmemiş harekete tıklayıp "🔗 Eşleştir…" (ya da satırdaki 🔗): aynı hesapta tutarı tutan, banka hareketiyle eşleşmemiş kesin kasa işlemleri listelenir, "🔗 Bağla" ile hareket o işleme bağlanır. Yeni kasa işlemi açılmaz.
- **Bankaya düşmemiş kayıtları izlemek** — "Sistemde var, bankada yok" sekmesi; 3 iş gününü (çekte vade + 1 günü) aşan kayıt kırmızıdır.
- **API'siz hesaba banka bakiyesi girmek** — "✍ Banka bakiyesi gir": hesap, gün, gün sonu bakiyesi, kaynak (elle / ekstre) ve not girip "💾 Kaydet". Hesap ve gün başına bir değerdir; değişiklik işlem günlüğüne yazılır.
- **Mutabakatı onaylamak** — açıklanmayan farkı 0 olan hesaplar için "🔒 Mutabakatı Onayla" (hepsi) ya da satırdaki "🔒 onayla". Onay o günün bakiyelerini ve açıklama listelerini dondurur.
- **Günlük bakiyeye bakmak** — Günlük Bakiye sekmesi seçili hesabın son 10 / 20 / 31 gününün banka ve sistem gün sonu bakiyesini, farkını ve onay durumunu gösterir.
- **Geçmiş onayları görmek** — Mutabakat Geçmişi sekmesi; satıra tıklayınca hesaplar açılır, çift tıklayınca o gün icmalde açılır.
- **Tutanak almak** — "🖨 Mutabakat Tutanağı ▾" menüsü ya da "🖨 Mutabakat Tutanağı (A4)" sekmesi; tutanak seçili hesap içindir.
- **İlgili ekranlara geçmek** — "🔄 Banka Hareketleri" ve "📄 Hesap Ekstresi" düğmeleri.

## Ekrana giriş
- Sol menü **Finans › İcmaller › Banka Mutabakat İcmali** (`/banka-mutabakat`).
- `finans.banka_mutabakat` görme yetkisi gerekir.
- Elle bakiye girmek ve eşleştirmek için **Banka Hareketleri** (`banka.hareket`) değiştirme yetkisi; işlemek için ayrıca kasa işlemi ekleme yetkisi; bankadan çekmek için `banka.hareket` ekleme yetkisi; onaylamak için **banka.mutabakat_onay** aksiyon yetkisi gerekir. Hepsi şubede yazma hakkı ister.

## Rakamlar nereden gelir
- **Banka bakiyesi:** API'li hesapta günün sonuna kadarki son banka hareketinin işlem sonrası bakiyesi; hareket bakiyesi yoksa ve o günden sonra hareket gelmemişse son çekimin bakiyesi. Son çekim gün bitmeden yapıldıysa "çekim eksik" yazar ve onay verilmez. API'siz hesapta o gün için girilen gün sonu bakiyesi (kredi kartında ekstre bakiyesi); girilmemişse "bakiye girilmedi".
- **Sistem bakiyesi:** hesap ekstresiyle aynı küme — kesin kasa işlemleri, mutabakat gününün sonuna kadar.
- **Tarih esası işlem tarihidir** (bankanın ekstresi gibi). Valörü günden sonra olan hareket "valör bekleyen" bilgisidir, fark sayılmaz.
- **İşlenmemiş:** günün sonuna kadarki banka hareketlerinden sistemde karşılığı olmayanlar (bekliyor, öneri hazır, seçim bekliyor, yoksayılan; işlenmiş ama kasa işlemi o günden sonra tarihli olanlar).
- **Yolda:** banka hareketi akışı başladıktan sonraki, o güne kadar eşleşen banka hareketi olmayan kesin kasa işlemleri. Akışı olmayan (yalnız elle bakiyeli) hesapta bu liste çıkarılamaz.
- Toplamlar TL karşılığıdır (dövizli hesap o günün kuruyla); kuru olmayan döviz toplama girmez ve şeritte "Kur yok" yazar.

## Dikkat edilecekler
- Onay yalnız açıklanmayan fark tam 0 iken verilir.
- Genel Ayarlar'da **dört göz** açıksa onaylayan, o günün hazırlayanından farklı olmalıdır. Hazırlayan: API'siz hesapta o günün bakiyesini son giren, API'li hesapta o güne kadarki banka hareketlerini en son işleyen / eşleştiren kişi.
- Onaylanmış güne geriye dönük kasa işlemi girilirse kayıt engellenmez; o günün onayı "bozuldu" olur, icmalde kırmızı rozetle görünür ve yeniden onay ister. Elle bakiye değişirse de aynıdır.
- Eşleştirmede tutar farkı Genel Ayarlar'daki eşleştirme toleransı (kuruş; boşsa 0) dışındaysa bağlama yapılmaz; fark banka masrafıysa ayrı masraf işlemi girin.
- Yoksayılan banka hareketi bankada vardır, sistemde yoktur: farkı açıklar ama işlenene kadar listede kalır.
- İş günü sayımında hafta sonu düşülür; resmî tatiller düşülmez.

## Örnek sorular
- Dün gün sonunda bankadaki para sistemle tutuyor mu?
- Garanti hesabındaki fark neden?
- Bankaya düşmemiş verilen çekler hangileri?
- İşlenmemiş banka hareketlerini buradan işleyebilir miyim?
- API'si olmayan hesabın bakiyesini nereye girerim?
- Ay sonu banka mutabakat tutanağını nasıl alırım?
- Onaylı mutabakat neden "bozuldu" oldu?
