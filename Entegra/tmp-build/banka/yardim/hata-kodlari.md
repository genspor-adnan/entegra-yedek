---
id: hata-kodlari
baslik: Hata kodları ve engel kodları
modul: genel
ekran:
rota:
surec: hata
roller: tum_kullanicilar
dil: tr
surum: 1
urun_modu: 0
yetki:
erisim: kullanici
ozet: Ekranda görülen hata kodlarının (DOGRULAMA, YETKISIZ, ILK_PAROLA, YASAK, BULUNAMADI, CAKISMA, IS_KURALI, SUNUCU) ve sterilizasyon engel kodlarının (BD_ONAY, KARANTINA, SERBEST_EKSIK) anlamı ve yapılacaklar.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Sistem her hatayı aynı biçimde gösterir: bir **kod**, kullanıcıya dönük **mesaj**, destek için **izleme numarası** ve gerekiyorsa hatalı **alan listesi**. Kod, hatanın sınıfını söyler; mesaj kuralın kendisini. Bu belge kod → ne oldu → ne yapılır sırasıyla okunur.

## Ekrana giriş yolları
- Hata, işlem yapılan ekranda kırmızı uyarı olarak çıkar; alan hataları formda ilgili alanı işaretler.
- Yardım paneline son görülen hata kodu bağlam olarak gider; tanınmayan kod için asistan açıklama uydurmaz.

## Ön koşullar
—

## Alanlar
Hata gövdesi: kod, mesaj, izleme no, alanlar (alan adı + mesaj), çakışmada güncel değer ve çakışan alanlar; iş kuralı engelinde bazen **engel kodu** ve adet.

## Liste kolonları ve çipler
—

## İşlemler (düğmeler)
- Engel kodu taşıyan iş kuralı hataları ekranda **onay sorusuna** dönüşür ("yine de devam?"); onaylanırsa işlem kayda geçerek yapılır.
- Çakışmada ekran sunucunun döndürdüğü güncel değerleri gösterir; "yenile" sonrası değişiklik tekrar yapılır.

## Adım adım
1. Kodu okuyun: 4xx kullanıcı / kural tarafı, 500 sunucu tarafı.
2. Mesajdaki ön koşulu yerine getirin (alan doldurma, sıra, yetki).
3. Aynı hata sürüyorsa izleme numarasını destek ekibine iletin; kayıt sunucu günlüğünde bu numarayla bulunur.

## Durumlar
| Kod | HTTP | Ne oldu | Ne yapılır |
|---|---|---|---|
| **DOGRULAMA** | 400 | Formdaki bir ya da birkaç alan kurala uymuyor (zorunlu boş, uzunluk, biçim); hatalı alanlar kırmızı işaretli | İşaretli alanları düzeltip yeniden kaydedin. Kimlik no ve telefon biçimi şubenin ülkesine göre denetlenir |
| **YETKISIZ** | 401 | Oturum kapanmış / süresi dolmuş; sunucu kim olduğunuzu doğrulayamıyor | Yeniden giriş yapın; sık tekrarlıyorsa yönetici oturum süresini uzatabilir |
| **ILK_PAROLA** | 401 | Hesap açılmış ama parola hiç tanımlanmamış | Giriş ekranındaki "Parola belirle" adımı ya da "Şifremi Unuttum" ile kod isteyin |
| **YASAK** | 403 | Bu işlem / ekran için rolünüzde yetki yok ya da bulunduğunuz şubede yalnız görüntüleme hakkınız var | Yöneticiden ilgili yetkiyi (Yönetim › Roller) ya da şube yazma hakkını isteyin |
| **BULUNAMADI** | 404 | Kayıt yok ya da sizin kapsamınızın (şube / portal) dışında; ikisi aynı mesajla döner | Kayıt numarasını ve aktif şubeyi kontrol edin; başka şubenin kaydıysa şube değiştirin |
| **CAKISMA** | 409 | Siz kartı açtıktan sonra başkası aynı kaydı değiştirmiş; sizin sürümünüz eskidi | Kartı yenileyin (güncel değerler gösterilir), değişikliği güncel sürüm üzerine yeniden yapın |
| **IS_KURALI** | 422 | İşlem kurumsal bir kurala takıldı (faturası olan cari silinemez, kapanmış başvuruya istem açılamaz…); mesaj kuralı söyler | Ön koşulu yerine getirin ya da işlemi yapmayın; bazı kurallar onayla aşılabilir |
| **SUNUCU** | 500 | Beklenmeyen sunucu hatası; ayrıntı güvenlik gereği gösterilmez | Bir kez daha deneyin; sürüyorsa izleme numarasını destek ekibine iletin |

Engel kodları (iş kuralı içinde, onayla aşılabilen):
| Engel | Ne oldu | Ne yapılır |
|---|---|---|
| **BD_ONAY** | Sterilizasyon: bugün bu cihazda Bowie-Dick testi yapılmadan yükleme döngüsü başlatılmak isteniyor | Önce test döngüsünü çalıştırın ya da kurum kuralı izin veriyorsa onay notu yazarak devam edin |
| **KARANTINA** | Okutulan steril paketin biyolojik indikatör sonucu henüz gelmedi; paket karantinada | Sonucu bekleyin ya da acil durumda "yine de kullan" onayı verin; kullanım kayda geçer, sonuç pozitif çıkarsa geri çağırma açılır |
| **SERBEST_EKSIK** | Döngü serbest bırakılmak isteniyor ama zorunlu indikatör ya da parametre girilmemiş | Döngü kartında eksik indikatör sonucunu / parametreyi girin, sonra serbest bırakın |

## Yetki
- YASAK ile BULUNAMADI farkı: yetkisiz **işlem** 403 döner; kapsam dışı **kayıt** 404 döner (var olup göremediğiniz kayıt "yok" görünür).
- Yetkisiz düğme menüde hiç görünmez; 403 alıyorsanız düğme başka yoldan (eski link, elle adres) çağrılmıştır.

## Sık görülen hata ve uyarılar
- "Kayıt edilemedi: 2 alanda hata var." (DOGRULAMA) → alan listesine bakın.
- "Bu kaydı başka bir kullanıcı değiştirdi." (CAKISMA) → yenile, tekrar dene.
- "Bu cariye ait fatura var, silinemez." (IS_KURALI) → silme yerine pasife alma / iptal.
- Sterilizasyonda "… KULLANILAMAZ: raf ömrü doldu / geri çağırma ile BLOKE / paket daha önce kullanıldı" (IS_KURALI, engel kodsuz) → onayla aşılamaz; başka paket kullanın.

## Diğer modüllere etkisi
- İzleme numarası sunucu günlüğüyle eşleşir; destek talebinde kodla birlikte verilmelidir.
- Onayla aşılan engeller (BD_ONAY, KARANTINA) işlem günlüğüne onay notuyla yazılır.

## Yapılmaması gerekenler
- 500 hatasında aynı işlemi art arda çok kez tekrarlamayın; izleme numarasını iletin.
- 404'ü "kayıt silinmiş" diye yorumlamayın; önce şube kapsamını kontrol edin.
- Engel kodunu onaylarken gerekçesiz "devam" demeyin; onay notu denetim izidir.

## Örnek sorular
- DOGRULAMA hatası ne demek?
- 403 YASAK ile 404 BULUNAMADI farkı ne?
- CAKISMA hatası aldım, ne yapmalıyım?
- IS_KURALI 422 nedir?
- BD_ONAY engeli nasıl aşılır?
- KARANTINA uyarısı çıktı, paketi kullanabilir miyim?
- SERBEST_EKSIK ne demek?
- İzleme numarası nedir, kime verilir?

## Kaynaklar
- dokuman/01_API_SOZLESMELERI.md §1.2, §1.3, §7, §8
- api/src/Gentegre.Api/Servisler/Yardim/HataAciklamalari.cs
- api/src/Gentegre.Api/Uclar/SterilUclari.Islem.cs (engel kodları)
- dokuman/00_TARIHCE.md (868 sterilizasyon: engel kodları ekranda onay sorusuna dönüşür)

## Doğrulama durumu
Kod incelemesiyle yazıldı.
