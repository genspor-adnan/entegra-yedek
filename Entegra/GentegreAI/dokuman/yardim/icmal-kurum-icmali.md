---
id: icmal-kurum-icmali
baslik: Kurum İcmali
modul: kurum_sigorta
ekran: kurum-icmali
rota: /kurum-icmali
surec: icmal
roller: faturalama, muhasebe, yonetim
dil: tr
surum: 1
urun_modu: 2
yetki: kurum.icmal_ozet
erisim: kullanici
ozet: Ödeyen kurumların (SGK, özel sigorta, kurumu öder) seçilen dönemdeki başvurularını, kurum payını, Medula kesintisini, icmal / fatura durumunu ve kurum carisini gösterir; dönem icmali buradan oluşturulup faturalanır.
guncelleme: 2026-10-25
dogrulama: insan-dogrulama-bekliyor
---

## Amaç
Kurum İcmali "bu ay hangi kuruma ne kadar fatura keseceğim, ne kadarı kesildi, ne kadarı tahsil edildi?" sorusunu cevaplar. SGK ve özel sigorta payı hasta hasta faturalanmaz; dönem sonunda toplanıp kuruma tek fatura kesilir. Faturalama ve muhasebe birimi dönemi burada kapatır, yönetim kurum alacağını izler. Eski "Kurum İcmalleri" listesi bu ekranın **İcmaller** sekmesidir.

## Bu ekranda neler yapabilirsiniz
- **Dönemi değiştirme** — şeritteki 📅 Dönem tarihlerini girin ya da ‹ › oklarıyla bir ay geri / ileri gidin (varsayılan geçen ay).
- **Kurum seçme** — Dönemdeki Kurumlar sekmesinde satıra tıklayın (yalnız o kurum), Ctrl ile ekleyip çıkarın, Shift ile aralık seçin; seçim diğer sekmeleri süzer, "temizle" bütün kurumlara döner.
- **Sekmeler arasında geçiş** — Dönemdeki Kurumlar, Başvurular, Hizmet Grupları, Kesinti & İtiraz, İcmaller, Cari & Tahsilat.
- **Hasta icmaline geçme** — Başvurular sekmesinde hasta adına tıklayın; o hastanın Hasta İcmali açılır, ↩ Geri Dön ile aynı süzgeçlere dönersiniz.
- **İcmal oluşturma** — 🔒 İcmal Oluştur (Kesinleştir) ya da İcmaller sekmesindeki ＋ İcmal Oluştur; dönemin açık kurum payı icmale bağlanır (tek kurum seçili değilse kurum sorulur).
- **Kuruma fatura kesme** — hazırlanmış icmal varken 🧾 Kuruma Fatura Kes; İcmaller sekmesinde birden çok icmal işaretleyip 🧾 Faturala.
- **İcmal kayıtlarını izleme** — İcmaller sekmesinde Hazırlanıyor / Faturalandı / Tahsil edildi / Tümü çipleri; satıra tıklayınca satırları açılır, çift tıklayınca o kurum ve döneme geçilir; ↗ Faturayı Aç, 🖨️ İcmali Yazdır.
- **Kurum carisini görme** — tek kurum seçiliyken Cari & Tahsilat sekmesi kurumun dönem hareketlerini ve bakiyesini gösterir.
- **Çıktı alma** — "Kurum İcmali" menüsünden Baskı Önizleme, Yazıcıya Yazdır ya da Gönder › PDF / Word / Excel / HTML.

## Ekrana giriş
- Sol menü **Kurumlar & Sigorta › Kurum İcmali** (yalnız HBYS).
- Eski adres `/kurum-icmal` buraya İcmaller sekmesi açık olarak yönlenir.
- Alacak Yaşlandırma ekranındaki **🏢 Kurum İcmali** düğmesi ya da kurum adına tıklama (kurum seçili açılır).
- Dönem, seçili kurumlar ve sekme adres çubuğunda tutulur; geri dönüşte ekran aynı haliyle açılır.

## Süzgeçler
- **Dönem** (başlangıç – bitiş): başvuru tarihine göre; ‹ › tam ay kaydırır.
- **Kurum seçimi**: Dönemdeki Kurumlar sekmesindeki onay kutuları; hiçbiri seçili değilse bütün kurumlar. Tek kurum seçiliyken cari, açık kurum payı ve dönem adım çubuğu (Açık → Kesinleşti → Faturalandı → Tahsil edildi) açılır.
- İcmaller sekmesinde ayrıca durum çipleri ve **Yalnız seçili kurum** kutusu vardır; bu sekme dönemden bağımsızdır.
- Şube süzgeci sunucuda uygulanır.

## Özet ve sekmeler
- Kutular: **Başvuru** (hasta, provizyonlu, red sayısı), **Toplam Hizmet**, **Kurum Payı**, **Hasta Payı** (bilgi, kurumdan istenmez), **Kesinti**, **Faturalanan** (tek kurumda açık pay da yazılır), **Kurumdan Tahsil**, tek kurumda **Kurum Bakiyesi** ya da birden çok kurumda **Net Alacak**.
- **Dönemdeki Kurumlar**: Kurum, Tür, Başvuru, Toplam Hizmet, Kurum Payı, Kesinti, Net Alacak, Pay, Dönem Durumu.
- **Başvurular**: Tarih, Protokol No, Hasta, (çok kurumda) Kurum, Poliçe / Provizyon No, Bölüm, Toplam, Kurum Payı, Hasta Payı, Kesinti, Net, Provizyon rozeti (Alınmadı / Onaylı / Red / Kısmi onay / İptal).
- **Hizmet Grupları**: grup başına kalem, tutar, kurum / hasta payı ve kurum payı dağılımı.
- **Kesinti & İtiraz**: Protokol No, Hasta, SUT Kodu, Kesinti Kodu, Açıklama, Kesinti, İade, İtiraz.
- **İcmaller**: Kurum, Dönem, Başvuru, Satır, Kurum Payı, Kesinti, Fatura No / Tarihi, Fatura (KDV dahil), Tahsil, Durum.
- **Cari & Tahsilat**: Tarih, Belge, Açıklama, Borç, Alacak, Bakiye.

## Rakamlar nereden gelir
Özet `GET /api/kurum-icmal/ozet?kurumlar=&bas=&bit=` ucundan gelir; bu uç yalnız okur.
- Kurum = taraf_kurum türü 2–4 (ÖSS, SGK, kurumu öder); "Özel (Ücretli)" kurum sayılmaz. İptal başvuru girmez.
- Toplam = başvurunun genel toplamı; kurum payı = satır dağılımındaki SGK + ÖSS payı; hasta payı = toplam − kurum payı (Hasta İcmali ile aynı kural).
- Kesinti = Medula kesintisi, kabul edilen itirazın iadesi düşülmüş; Net = kurum payı − kesinti.
- Faturalanan = faturası kesilmiş dönem icmallerinin tutarı; Kurumdan Tahsil = icmal faturalarına yapılan tahsilat / çek-senet / kupon.
- Açık kurum payı = henüz bir icmale bağlanmamış faturalanabilir pay (icmal oluşturma önizlemesiyle aynı küme).
- İcmal oluşturma ve faturalama Kurum İcmalleri uçlarıyla (289) yapılır.

## Çıktı
**Kurum İcmali** açılır menüsü: 🔍 Baskı Önizleme, 🖨️ Yazıcıya Yazdır, 📤 Gönder ▸ PDF / Word / Excel / HTML. A4 belge seçili kurum (ya da "Tüm kurumlar") ve dönem için hazırlanır; dosya adı kurum adı ve dönemi taşır. İcmaller sekmesindeki **🖨️ İcmali Yazdır** ekranı işaretli icmalin kurum ve dönemine geçirip A4'ü basar.

## Dikkat edilecekler
- İcmal oluşturulunca satırlar o icmale **kilitlenir**; dönem içinde sonradan girilen başvuru yeni bir icmale düşer, adım çubuğu dönemi açık gösterir.
- "Açık kurum payı yok" uyarısı: pay başka bir icmalde, kurum tahakkukuyla kapanmış ya da başvurular kesinleşmemiştir.
- Faturalama her icmal için kuruma **tek fatura** keser ve satırların kurum payını kapatır; onay sorusu tutarı gösterir.
- Hasta payı bu ekranda yalnız bilgi amaçlıdır; hastadan alınacak tutar Hasta İcmali'ndedir.
- Kurum Bakiyesi ve Cari & Tahsilat yalnız tek kurum seçiliyken gelir.

## Örnek sorular
- Geçen ay SGK'ya ne kadar fatura keseceğim?
- İcmal Oluştur neden "açık kurum payı yok" diyor?
- Bir kurumun icmalini nasıl faturalarım?
- Hangi başvurularda Medula kesintisi var?
- Kurumun bize borcu ne kadar?
- Birden çok kurumu birlikte nasıl görürüm?
