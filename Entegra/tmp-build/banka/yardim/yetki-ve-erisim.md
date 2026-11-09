---
id: yetki-ve-erisim
baslik: Yetki, rol, şube ve "neden göremiyorum"
modul: yonetim
ekran:
rota:
surec: yetki
roller: yonetici, bilgi_islem, tum_kullanicilar
dil: tr
surum: 1
urun_modu: 0
yetki:
erisim: kullanici
ozet: Ekran ve düğmelerin neden görünmediği; rol / yetki matrisi, modül ayarı, ürün modu, şube kapsamı, portal kullanıcıları ve "yetkisiz" ile "bulunamadı" ayrımı.
guncelleme: 2026-09-19
dogrulama: kod-incelemesi
---

## Amaç
Bir ekranın menüde görünmesi, bir düğmenin çalışması ve bir kaydın listelenmesi üç ayrı süzgeçten geçer: **rol yetkisi**, **modül / ürün modu** ve **şube kapsamı**. Bu belge "ekranı göremiyorum", "düğme yok", "kayıt bulunamadı" sorularının hangi süzgece takıldığını ayırt etmek içindir.

## Ekrana giriş yolları
- **Yönetim › Güvenlik › Roller** (`/rol`): rol kartı ve Yetki Matrisi sekmesi.
- **Yönetim › Güvenlik › Kullanıcılar** (`/kullanici`): hesap, rol atama, parola sıfırlama, kilit çözme, oturum kapatma, aktif / pasif.
- Kurum profili / modül ayarları (Yönetim altında; kurum tipine göre açık modüller).
- **Yönetim › Firma / Şubeler** (`/sube`).

## Ön koşullar
- Rol ve kullanıcı yönetimi için **rol** ve **kullanici** yetkileri; modül ayarı için **ayar**.
- Hesap personel kartından açılır; kullanıcı ekranından yeni hesap açılmaz ve hesap silinmez (pasife alınır).

## Alanlar
Rol kartı: Kod, Ad, Üst Rol, Aktif, Sistem Rolü (salt okunur), Amaç; **Yetki Matrisi**: her yetki satırı × Gör / Ekle / Değiştir / Sil kutuları; bazı yetkiler değer (ör. iskonto tavanı) ve kapsam alır.
Kullanıcı kartı: Kullanıcı Kodu, Durum, E-posta, Cep Telefonu, Arayüz Dili; Güvenlik sekmesi salt okunur (Parola Tarihi, Son Giriş, Son Giriş IP, Hatalı Giriş, Kilit Bitişi, 2 Adımlı Doğrulama, Varsayılan parola); ana rol ve ek roller "Kullanıcı Rolü" kutusundan.

## Liste kolonları ve çipler
Roller: Aktif / Pasif / Tümü çipleri (pasif rol silinmez, geri açılabilir). Kullanıcılar listesinde eylemler: **🔑 Parola Sıfırla**, **🔓 Kilidi Çöz**, **⎋ Oturumları Kapat**, **🚫 Aktif / Pasif**, **👥 Personelden Toplu Aç**.

## İşlemler (düğmeler)
- Menü: yalnız rolünüzde **Gör** hakkı olan ve kurumda **modülü açık** ekranlar çizilir; ürün moduna uymayan (HBYS ekranı ERP kurulumunda) hiç görünmez.
- Araç çubuğu / sağ tuş / komut paleti aynı katalogdan üretilir: yetkisiz düğme hiç gelmez; koşul nedeniyle kapalı düğme gri gelir ve nedenini yazar ("pasif sebep").
- Alan yetkisi: yetkisiz alan (ör. maliyet, risk) yanıttan çıkarılır; ekranda gizlenmez, hiç gelmez.

## Adım adım
"Ekranı menüde göremiyorum" için sırayla:
1. Kurumda modül açık mı? (Yönetim › Modül / Kurum Profili). Kapalıysa yetki verilse de menü çizilmez.
2. Ürün modu uygun mu? HBYS ekranları yalnız GenoTIP AI (HBYS) kurulumunda, ERP ekranları yalnız Gentegre AI'da görünür.
3. Rolünüzde ekranın yetkisi Gör işaretli mi? **Yönetim › Güvenlik › Roller** › rol › **Yetki Matrisi**.
4. Değişiklikten sonra sayfayı yenileyin; menü yetki sürümüne göre tazelenir (yeni oturum gerekmez).
"Düğme yok / gri" için: yetkisizse hiç gelmez; gri ise üzerine gelince sebep yazar (ör. "Belge zaten gönderilmiş").
"Kayıt bulunamadı" için: kayıt yok **ya da** başka şubenin / portal kapsamının dışında; üst şeritten şubeyi değiştirin (yetkiniz varsa).

## Durumlar
- **Şube yazma**: aktif şubede yalnız görüntüleme hakkınız varsa üst şeritte "salt okuma" rozeti görünür; kayıt yazamazsınız.
- **Hekim kısıtı**: aktif çalışma şablonu olan hekim, Çalışma Listesi ve Muayeneler'de yalnız kendi hastalarını görür.
- **Portal kullanıcıları**: hasta kendi kartı / randevusu / sonucu; dış doktor ve dış kurum yalnız kendi gönderdiği hasta ve istemler; parolasız açılan hesap ilk girişte parola koyar.
- **Hesap kilidi**: art arda hatalı giriş hesabı geçici kilitler; parola sorunu değildir, yönetici **🔓 Kilidi Çöz** ile açar.

## Yetki
- Yetki her istekte sunucuda rolden çözülür; oturuma gömülmez. Şube süzgeci sunucuda eklenir, istekte gönderilmez.
- Yazma isteğinde yetkisiz alan gelirse istek reddedilir (403), sessizce yok sayılmaz.
- Sistem rolleri (Yönetici, Salt okuyucu, İskonto Onaylayanlar…) silinemez, pasife alınamaz.
- Kendi iskonto talebini kimse onaylayamaz; eşik üstü iskonto onaylı talep ister.

## Sık görülen hata ve uyarılar
- **YETKISIZ (401)** → oturum yok / süresi dolmuş; yeniden giriş yapın. **ILK_PAROLA (401)** → parola hiç belirlenmemiş; "Parola belirle" adımı ya da "Şifremi Unuttum".
- **YASAK (403)** → rolünüzde yetki yok ya da şubede yalnız görüntüleme; yöneticiden yetki / şube yazma hakkı isteyin. Asistan yetkiniz olmayan işlemin adımlarını anlatmaz.
- **BULUNAMADI (404)** → kayıt yok ya da kapsam dışı; ikisi aynı mesajla döner. Kayıt numarasını ve aktif şubeyi kontrol edin.
- **"Bu rol kullanıcılara atanmış; önce kullanıcıların rolünü değiştirin."** (IS_KURALI) → rol silinemez.
- Menüde ekran yok ama yetki var → çoğunlukla modül kapalıdır; modül ayarına bakın.

## Diğer modüllere etkisi
- Rol değişikliği tüm ekranları anında etkiler (bir sonraki istekte).
- Kullanıcı pasife alınınca oturumları kapanır; geçmiş kayıtlar (işlem günlüğü, belgeler) hesaba bağlı kalır.
- Dış kurum / dış doktor portal rolleri laboratuvar ve radyoloji listelerini kapsamla süzer.

## Yapılmaması gerekenler
- Yetki vermek için kullanıcıya yönetici parolası vermeyin; rol matrisi kullanın.
- Menüde görünmeyen ekranın adresini elle yazıp kullanmaya çalışmayın; sunucu 403 döner.
- Hesabı silmeyin; pasife alın.

## Örnek sorular
- Ekranı menüde neden göremiyorum?
- Yetkim yok mu yoksa kayıt mı yok, nasıl anlarım?
- Kullanıcıya yetki nasıl verilir?
- Düğme neden gri, neden hiç yok?
- Başka şubenin kaydını nasıl görürüm?
- Hesabım kilitlendi, ne yapmalıyım?
- Hekim olarak neden tüm hastaları görmüyorum?
- Portal kullanıcısı neleri görebilir?

## Kaynaklar
- dokuman/01_API_SOZLESMELERI.md §1.1, §1.2, §7, §8
- web/src/sayfalar/listeTanimlari.ts (modulAcikMi, urunModu), listeTanimlari.Yonetim.ts (rol, kullanici, sube)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.cs (kullanici-liste, rol-liste), KartKatalogu.Cari.Hasta.cs (Kullanici, Rol, PortalKosullari)
- api/src/Gentegre.Api/Servisler/Yardim/HataAciklamalari.cs, EkranBaglami.cs
- db/447_ai_rehber.sql (kullanici-yetki, modul-ayari konuları); dokuman/00_TARIHCE.md (hekim kısıtı, 783 iskonto)

## Doğrulama durumu
Kod incelemesiyle yazıldı. Modül ayarı ekranının menü yolu ("Yönetim › Modül Ayarları" / Kurum Profili) doğrulanacak.
