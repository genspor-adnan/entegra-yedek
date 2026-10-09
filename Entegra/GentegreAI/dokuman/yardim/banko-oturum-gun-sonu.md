---
id: banko-oturum-gun-sonu
baslik: Banko oturumu (vardiya) açma, tahsilat ve gün sonu kasa teslimi
modul: kayit_kabul
ekran: banko-oturum
rota: /banko-oturum
surec: banko
roller: banko_gorevlisi, banko_sorumlusu, vezne, sekreter
dil: tr
surum: 1
urun_modu: 2
yetki: banko_oturum
erisim: kullanici
ozet: Banko vardiyasını devir sayımıyla açma, gün içi nakit / POS tahsilatı, oturum kartı sekmeleri (Ödeme Türleri, Vardiya İşlemleri, POS Gün Sonu, Açık Borçlar, Teslim Geçmişi), gün sonu sayımı, fark nedeni ve sorumlu onayı.
guncelleme: 2026-10-10
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Banko oturumu, bir görevlinin bir bankodaki **vardiyasıdır**. Gün içinde aldığınız her tahsilat oturum numarasını taşır; akşam kasayı sayıp teslim edersiniz. Böylece "kim, hangi kasadan, ne aldı" sorusu her gün kapanır. Akış altı adımdır: **Oturum talebi → Sorumlu onayı (isteğe bağlı) → Devir sayımı → Gün içi işlem → Gün sonu sayım → Teslim & kapanış**.

## Ekrana giriş yolları
- Sol menü **Kayıt Kabul › Banko Oturumları › ＋ Yeni Oturum Aç** (görevlinin olağan yolu).
- Sorumlu / yönetici: **Finans › Bankolar** listesinde bankoyu seçip **🔓 Oturum Aç**.
- Açık oturumunuz varken **Banko Oturumları** listesinde satırı seçip **✎ Düzenle** oturum kartını açar.
- Sorumlu onayları: **Kayıt Kabul › Banko Onayları**.

## Ön koşullar
- **banko_oturum** yetkisi; onay kuyruğu için **banko_onay**; kapanmış oturumu yeniden açmak için ayrı **banko_oturum.yeniden_ac** yetkisi.
- Banko tanımlı, aktif ve **kasalı** olmalı (danışma bankosunda kasa yoktur, oturum açılmaz).
- Bir bankoda aynı anda tek canlı oturum; bir görevli de aynı anda tek oturum yürütür.

## Oturumu açma (sabah)
1. **Kayıt Kabul › Banko Oturumları › ＋ Yeni Oturum Aç**.
2. **Banko** seçin; **Vardiya** seçilince saat aralığı önerilir (değiştirilebilir).
3. **Sistem devri** önceki oturumun kasada bıraktığı tutardır, elle değiştirilemez.
4. Kasadaki parayı sayıp **Kasada bulunan (devir sayımı)** alanına yazın. Fark varsa **Not** alanına açıklayın — fark açılışta yazılır, başkasının farkını devralmazsınız.
5. **🔓 Oturumu Aç**. Bankoda açılış onayı açıksa düğme **📨 Onaya Gönder** olur; sorumlu onaylayana kadar tahsilat ve başvuru kaydı yapılamaz (hasta kaydı ve randevu açık kalır).

## Gün içinde tahsilat
- Kabul penceresinde **💵 Tahsilat Al** ya da başvuru kartının **Tahsilat** sekmesinde **💵 Nakit** / **💳 POS**; Banka, Çek, Senet **⋯** menüsündedir.
- Nakit tahsilat açık oturumunuzun bankosunun **kasasına** girer.
- POS'ta bankonuzda tek çalışan cihaz varsa kendiliğinden seçilir; birden çoksa hangi terminalden çektiğinizi seçersiniz.
- Hasta avans bırakıyorsa **💰 Avans Al**; sonraki başvuruda **⋯ › 💰 Avans Kullan**.

## Oturum kartı
Üst şeritte Vardiya, Devir, Nakit tahsilat, Nakit iade, POS, İşlem sayısı ve durum rozeti; altında özet kutuları: Başvuru, Tahsilat, Tahsil Edilen, Açık Borç, **Kasada Olması Gereken** (yalnız nakit: devir + nakit − iade), Sayım Farkı.
Sekmeler:
- **Ödeme Türleri**: türe göre döküm (nakit sayılır; POS / havale kasada para olarak durmaz); çek / senet ayrı tabloda, nakit sayımına girmez.
- **Vardiya İşlemleri**: saat, başvuru, hasta, tür, tutar, iade ve durum (tahsil / kısmi / iade / iptal).
- **POS Gün Sonu**: her terminal için cihazın gün sonu fişindeki toplamı girip **💳 POS Gün Sonunu Kaydet**; ekran kasa kaydıyla farkı gösterir.
- **Açık Borçlar**: "Hastadan alınacak" ve "Kurum tahakkuku" (kurum payı vezneden tahsil edilmez).
- **Teslim Geçmişi**: bu bankonun önceki oturumları.

## Gün sonu (akşam)
1. Sağ üstteki **🔒 Gün Sonu**'na basın.
2. **POS Gün Sonu** panelinde cihaz toplamlarını girin.
3. Kasadaki nakdi sayıp **Sayılan nakit** alanına yazın; ekran Sayılan / Olması gereken / Fark gösterir.
4. Fark varsa **Fark nedeni** (Para üstü hatası · Eksik tahsilat · Fazla tahsilat · Kayıt dışı ödeme · Sayım hatası · Diğer) ve **Açıklama** zorunludur.
5. **Kasada bırakılan (yarının devri)**'ni yazın (öneri banko hedefinden gelir, sayımı aşamaz); **Teslim edilecek** kendiliğinden hesaplanır.
6. **🔒 Oturumu Kapat**; gün sonu onayı açıksa **📨 Teslime Gönder (onaya)**. Vazgeçmek için **↻ Vazgeç**.
7. Kapanışta tutanak numarası (TT-yyyy-nnnnnn) verilir; **Banko Oturumları** listesinde **🧾 Teslim Tutanağı** ile yazdırılır.

## Sorumlu onayı
**Kayıt Kabul › Banko Onayları**: bekleyen açılış ve teslimler; **✔ Onayla** / **✖ Reddet**. Sorumlu kendi oturumunu onaylayamaz ("siz" rozetli satırda düğmeler kapalı). Reddedilen teslim oturumu kapatmaz, açık duruma döndürür; görevli yeniden sayar.

## Durumlar
Açılış onayı bekliyor (1) · Açık (2) · Teslime gönderildi (3) · Kapandı (4) · Reddedildi (5). Liste çipleri: **Açık · Onay bekleyen · Teslimde · Farklı kapanan · Tümü**.

## Sık karşılaşılan sorunlar
- **"Tahsilat için açık banko oturumu gerekiyor."** → vardiyanızı açın; kapalı oturuma tahsilat yazılmaz.
- **"Yeni oturum açılamaz: açık bir oturumunuz var"** → önce mevcut oturumu gün sonuyla kapatın.
- **"Seçtiğiniz bankoda oturum açılamıyor"** → bankoda başka canlı oturum var, banko pasif, danışma türünde ya da başka şubede.
- **Teslim düğmesi kapalı** → fark var ama neden / açıklama boş, ya da bırakılan tutar sayılandan fazla.
- **POS farkı** → cihaz fişindeki toplamı yeniden kontrol edin; terminale bağlanmamış POS tahsilatı ayrı satırda görünür.
- **Yanlış kapatılan oturum** → kapanan oturum düzeltilmez; yetkili kişi **🔓 Yeniden Aç** kullanır (gerekçe loga yazılır). Hatalı tahsilat iade / düzeltme fişiyle çözülür.

## Yapılmaması gerekenler
- Başkasının oturumunda tahsilat almayın; her görevli kendi oturumunu açar.
- Sayımı tahmini yazmayın; fark ayrı fişle muhasebeleşir ve geçmişte kalır.
- Olmayan parayı yarına devretmeyin; sistem buna izin vermez.

## Örnek sorular
- Banko oturumu nasıl açılır?
- Vardiyamı nasıl kapatırım?
- Gün sonu kasa sayımı nasıl yapılır?
- Kasa farkı çıktı, ne yapmalıyım?
- POS gün sonu toplamını nereye girerim?
- Açık borçları nereden görürüm?
- Teslim tutanağını nasıl yazdırırım?
- Neden tahsilat alamıyorum?

## Kaynaklar
- web/src/sayfalar/banko/BankoOturumu.tsx, BankoOnayKuyrugu.tsx, BankoTutanak.tsx
- web/src/bilesenler/belge/TahsilatSekmesi.tsx, web/src/bilesenler/banko/PosSecModali.tsx
- web/src/sayfalar/listeTanimlari.Ticari.ts (banko, banko-oturum, banko-onay, banko-oturumlar)
- api/src/Gentegre.Cekirdek/Katalog/AksiyonKatalogu.Lab.cs (banko-liste, banko-oturum-liste)
- api/src/Gentegre.Veri/Depolar/KasaDeposu.Yazma.cs (oturum zorunluluğu)
- db/987, 992-997, 1002, 1005; dokuman/00_TARIHCE.md (08.10.2026 banko vardiyası)

## Doğrulama durumu
Kod incelemesiyle yazıldı. Bu ekranlar (`/banko-oturum`, `/banko-oturumlar`, `/banko-onay`) henüz yardım ekran kataloğunda yok; asistan ekran bağlamını tanımaz, belge yalnız soruyla bulunur. İnsan doğrulaması bekliyor.
