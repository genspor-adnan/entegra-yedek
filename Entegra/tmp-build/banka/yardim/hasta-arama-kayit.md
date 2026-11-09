---
id: hasta-arama-kayit
baslik: Hasta arama ve yeni hasta kaydı
modul: kayit_kabul
ekran: hasta
rota: /hasta
surec: hasta
roller: kayit_kabul, banko, hemsire, hekim
dil: tr
surum: 1
urun_modu: 2
yetki: hasta
erisim: kullanici
ozet: Kayıt Kabul › Hasta Listesi ekranında hasta arama, yeni hasta kartı açma ve aynı kimlik / aynı telefon (mükerrer) kuralları.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Hasta Listesi, kayıt kabulün ilk durağıdır: hasta önce burada aranır, yoksa yeni kart açılır, sonra hastaya başvuru (protokol) açılır. Hasta bir "taraf" kaydıdır; aynı kayıt hastaya fatura kesilirken cari olarak da kullanılır. Bu ekran yalnız HBYS (GenoTIP AI) kurulumunda vardır.

## Ekrana giriş yolları
- Sol menü: **Kayıt Kabul › Hasta Listesi** (ekran başlığı "Hastalar").
- Komut paleti: Ctrl+K (yedek: F1 ya da Ctrl+Shift+P) › "Hasta" yazıp seçin.
- Kart adresi: `/hasta/[kayıt no]`; listede satıra çift tık kartı açar.
- Başvuru kartındaki hasta şeridi ve çağrı merkezi "Kişi kartı" düğmesi de bu karta getirir.

## Ön koşullar
- Rolünüzde **hasta** yetkisinin Gör hakkı olmalı; yeni kayıt için Ekle, düzeltme için Değiştir hakkı gerekir.
- Aktif şubede yazma hakkınız yoksa üst şeritte "salt okuma" rozeti görünür; kayıt açamazsınız.
- Kimlik no elle girilecekse 11 haneli ve geçerli olmalı (kimliksiz hasta için "Kimliksiz Hasta" işaretlenir).

## Alanlar
Kart üst şeridi (Kimlik): **Dosya No** (boş bırakılırsa sistem üretir), **Kimlik No** (11 hane, doğrulanır), **Durum** (Aktif / Pasif / Aday / Vefat), Telefon, e-posta, Şube.
"Hasta Bilgisi" sekmesi: **Doğum Tarihi (zorunlu)**, **Cinsiyet (zorunlu)** — laboratuvar referans aralıkları ve e-Nabız için gerekir; Doğum Yeri, Uyruğu, Kan Grubu, Meslek (arama penceresi), Kayıt Tipi (açılışta vatandaş kaydı), Kurum / Ödeyen, Pasaport No, Medeni Hal, Ana Adı, Baba Adı, Anne / Baba Kimlik No, Kimliksiz Hasta, Yabancı Hasta Türü, Ülkeye Giriş Tarihi, Vefat, Vefat Tarihi, Mahremiyet Notu (dosya açılırken gösterilen uyarı).
"Kurum / Ödeyen" sekmesi (birden çok satır): **Kurum Türü (zorunlu)**, Kurum / Sigorta (yalnız anlaşmalı kurumlar), Poliçe No, Geçerlilik, Kapsam, Açıklama, Aktif — yeni satır eklenince öncekiler kendiliğinden pasife düşer.
"Adres / Fatura Bilgisi": adresler, Fatura Unvanı, Vergi Dairesi, e-Fatura mükellefi, Alias / e-Posta.
Hasta yakını, personel kartındaki acil kişiler bölümüyle aynı yerde tutulur.

## Liste kolonları ve çipler
Kolonlar: Dosya No · Ad Soyad · Kimlik No · Cinsiyet · Yaş · Telefon · İlçe · İl · Sigorta / Kurum · Son Başvuru. Doğum Tarihi ve Kurum Id kolon seçicisinden açılabilir; Açık Borç listede gösterilmez (başvuru şeridinde okunur).
Çipler: durum çipleri (Aktif / Tümü — tam liste doğrulanacak). Listenin üstündeki arama kutusu ad, dosya no ve kimlik no ile arar.
"Hasta Ekstresi" sekmesi hastanın hesap hareketlerini (Protokol No kolonuyla) gösterir.

## İşlemler (düğmeler)
- `hasta.yeni` **＋ Yeni** (Ctrl+N): boş hasta kartı açar.
- `hasta.duzenle` **✎ Düzenle** (Enter): seçili kartı açar.
- `hasta.sil` **🗑 Sil** (Del, sağ tuş menüsünde): kayıt izi olan hasta silinemez, sistem sebebini söyler.
- `form.hasta-formlar` **📋 Formlar**: hastanın onam / değerlendirme / beyan formları.
- `kullanici.portal-davet` **📨 Portal Daveti Gönder**: SMS / e-posta ile tek kullanımlık hesap açma bağlantısı.
- `kullanici.portal` **🔑 Portal Erişimi**: parolasız portal hesabı açar; kişi ilk girişte parolasını kendi koyar.
- `genel.yazdir` **🖨️ Yazdır**: listeyi yazdırır / dışa aktarır.
- Kart içinde **＋ Yeni Başvuru**: kart kapanır, başvuru kartı bu hastayla açılır.

## Adım adım
1. **Kayıt Kabul › Hasta Listesi** ekranını açın; arama kutusuna ad, dosya no ya da kimlik no yazın.
2. Hasta bulunduysa satıra çift tıklayın (ya da **✎ Düzenle**); yeni kayıt açmayın.
3. Bulunamadıysa **＋ Yeni** düğmesine basın.
4. Kimlik No, ad soyad, telefon ve "Hasta Bilgisi" sekmesinde Doğum Tarihi ile Cinsiyet'i girin.
5. Ödeyen kurum varsa "Kurum / Ödeyen" sekmesine satır ekleyin (SGK / özel sigorta / anlaşmalı kurum, poliçe no).
6. **Kaydet**'e basın; Dosya No boşsa sistem üretir.
7. Hastaya işlem açılacaksa kartın üstündeki **＋ Yeni Başvuru** düğmesini kullanın.

## Durumlar
- **Aktif**: normal hasta. **Pasif**: listede varsayılan çipte görünmez. **Aday**: henüz hizmet almamış kayıt. **Vefat**: vefat işaretli; vefat tarihi girilir.

## Yetki
- Liste ve kart **hasta** yetkisine bağlıdır (personel yetkisinden ayrıdır; banko görevlisine personel özlük kaydı açmak gerekmez).
- Portal düğmeleri ayrıca **kullanici.portal** aksiyon yetkisi ister; Formlar için form yetkisi gerekir.
- Portalden giren hasta yalnız kendi kartını; dış doktor / dış kurum yalnız kendi gönderdiği hastayı görür.

## Sık görülen hata ve uyarılar
- **"Bu kimlik numarası ile kayıtlı hasta var: … Yeni kayıt açılmaz, o kart kullanılır."** (DOGRULAMA, kimlik alanı işaretli) → Kaydet'e basınca sistem aynı kimlik numaralı hastayı bulmuş; ekran mevcut kartı açar. Yeni kayıt yerine o kartı kullanın. Düzenlemede de aynı kural (kendi kaydı hariç) geçerlidir.
- **Aynı telefon uyarısı** → aynı numaraya (son 10 hane) kayıtlı hasta(lar) listelenir ve onay sorulur: "Kapat" kaydetmez, "Tamam" kaydeder. Aile bireyleri aynı numarayı paylaşabildiği için bu bir engel değil uyarıdır.
- **Kimlik No biçim hatası** (DOGRULAMA) → 11 hane ve geçerli olmalı; kimliği belirsiz hastada alanı boş bırakıp "Kimliksiz Hasta" işaretleyin.
- **Doğum Tarihi / Cinsiyet zorunlu** → boş bırakılamaz; kimliksiz acil kaydında istisna sunucu tarafında uygulanır.
- **YASAK (403)** → hasta yetkiniz ya da şube yazma hakkınız yok; yöneticinize başvurun.

## Diğer modüllere etkisi
- Başvuru, randevu, laboratuvar istemi, radyoloji istemi ve çağrı merkezi hastayı bu karttan seçer.
- Doğum tarihi ve cinsiyet laboratuvar referans aralığını ve bayrağı belirler; Kurum / Ödeyen başvuruda ödeyen kurum varsayılanıdır.
- Kimlik No Medula provizyonuna, e-Nabız paketlerine ve e-Belge alıcı bilgisine gider.
- Hasta aynı zamanda müşteri bayrağı taşır: fatura kesilirken cari olarak seçilebilir.

## Yapılmaması gerekenler
- Aynı hastaya ikinci kart açmaya çalışmayın; sistem engeller, aramayı önce yapın.
- Kimlik no yerine dosya no uydurmayın; otomatik numaralama açıkken Dosya No'yu boş bırakın.
- Vefat eden hastayı silmeyin; Durum'u "Vefat" yapın.
- Mahremiyet Notu'na klinik bilgi yazmayın; o alan dosya açılırken gösterilen uyarıdır.

## Örnek sorular
- Yeni hasta kaydını nereden açarım?
- Aynı kimlik numarasıyla ikinci hasta kaydı neden açılmıyor?
- Telefon numarası aynı olan hasta uyarısı ne demek, devam edebilir miyim?
- Hasta kartında doğum tarihi neden zorunlu?
- Kimliği olmayan hastayı nasıl kaydederim?
- Hastaya portal erişimi nasıl verilir?
- Hastanın önceki başvurularını nerede görürüm?
- Hasta listesinde hangi kolonlar var, kimlik no ile arayabilir miyim?

## Kaynaklar
- web/src/sayfalar/listeTanimlari.Klinik.ts (hasta girdisi)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (hasta-liste)
- api/src/Gentegre.Cekirdek/Katalog/KartKatalogu.Cari.Hasta.cs
- api/src/Gentegre.Cekirdek/Katalog/KaynakKatalogu.Cari.cs (Hasta)
- api/src/Gentegre.Api/Uclar/HastaUclari.cs (mükerrer kuralı)
- dokuman/00_TARIHCE.md ("Hasta kaydında mükerrer kontrolü", 788 "açık başvuru varsa o açılır")
- db/447_ai_rehber.sql (hasta-kayit konusu)

## Doğrulama durumu
Kod incelemesiyle yazıldı. Rehber kataloğundaki (447) "MERNİS'ten Getir" adımı kodda doğrulanamadı; durum çiplerinin tam listesi doğrulanacak.

## Kod-belge çelişkileri
- Rehber kataloğu (447) Hasta Listesi ekranını **personel** yetkisine bağlı gösterir; güncel ekran tanımı ve kart **hasta** yetkisini kullanır (684 değişikliği). Menüde görünmeme sorununda "hasta" yetkisine bakılmalı.
- Rehber adımı "MERNİS'ten Getir" düğmesinden söz eder; kartta böyle bir aksiyon bulunamadı (doğrulanacak).
