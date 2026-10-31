# GentegreAI — düzeltme sonrası takip incelemesi

Tarih: 28.10.2026. İncelenen: çalışma ağacındaki mevcut değişiklikler. Önceki rapor: [KOD_INCELEME_RAPORU_2026-10-28.md](KOD_INCELEME_RAPORU_2026-10-28.md).

**Sonuç: Düzeltmelerin çoğu doğru yönde uygulanmış; bütün bulgular kapandı denemez.** Radyoloji kayıt filtresinin dışında kalan bir hasta geçmişi sorgusu var. Ayrıca rapor kaydetmedeki sürüm kontrolü, onay işleminin hangi içerik sürümünü onayladığını henüz güvenceye almıyor.

Bu inceleme kod ve yerel testlerle sınırlıdır; canlı kurulumların secret/rol geçişi doğrulanmadı. Uygulama kodu değiştirilmedi.

## Kalan bulgular

### T01 — P1: `istem-secenekleri?hastaId=...` kayıt kapısını atlıyor

**Yer:** `api/src/Gentegre.Api/AraKatman/RadyolojiKayitKapisi.cs:24`; `api/src/Gentegre.Api/Uclar/RadyolojiUclari.cs:217`.

Yeni filtre URL'deki `id` değerini ve yalnız `/istem/{id}`, `/rapor/{id}`, `/hasta/{id}` desenlerini denetliyor. `GET /api/radyoloji/istem-secenekleri?hastaId=...` yolunda route `id` yok; filtre doğrudan handler'a geçiyor. Handler `radyoloji` okuma izninden sonra hasta kimliğine göre son 12 aylık tetkikleri, tetkik adını ve son tarihini getiriyor. Sorguda şube, portal sahipliği veya merkezi kayıt kapsamı koşulu yok.

**Etki:** İlgili kaynak iznine sahip kişi, başka hastanın kimliğini sorgu parametresine yazarak tetkik geçmişi öğrenebilir. Kendi erişebildiği hastada da başka şubeye ait istemler hesaba katılır. `/istem/{id}/rapor` geçmişine sonradan eklenen kapsam filtresi bu ayrı endpoint'i korumuyor. Önceki B02 bu nedenle kısmen açık.

**Düzeltme:** `hastaId` için merkezi hasta erişimini doğrulayın; geçmişi de görünür `radyoloji-istem` kayıtlarından, şube ve portal koşulları uygulanmış olarak üretin. Toplamaya başlamadan önce satır kapsamını uygulayın. Diğer özel uçların sorgu/body kimliklerini de filtre kapsamı açısından kontrol edin. Örneğin `/hekim/{id}/ozet` içindeki istem/tutar toplamları da şu anda aktif şube koşulu içermiyor (`RadyolojiUclari.cs:239`).

**Kabul testi:** A şubesine yetkili kullanıcının, B şubesindeki hastanın yalnız B'de bulunan tetkiklerini bu sorgudan alamadığını doğrulayın. Portal başka hastanın geçmişini görememeli. Aynı hasta A ve B'de işlem görmüşse A yanıtında B kayıtları bulunmamalı. Mevcut `RadyolojiErisimTestleri` yalnız kimlikli istem/rapor yollarını test ediyor; bu sorgu yolu için test yok.

### T02 — P2: Onay, kullanıcının gördüğü rapor sürümüne bağlanmıyor

**Yer:** `api/src/Gentegre.Api/Uclar/RadyolojiUclari.OnayVeBulgu.cs:25`; `web/src/sayfalar/RadyolojiRapor.tsx:382`; `web/src/api/uclar/radyoloji.ts:56`.

Kaydetme artık `surum` doğruluyor ve istem/rapor satırlarını kilitliyor. Onay endpoint'i ise yalnız `id` ve `hedef` alıyor; beklenen `surum` taşımıyor. Web'in kaydet → raporu oku → onayla adımları ayrı HTTP istekleri. Satır kilidi yalnız son isteğin transaction'ını koruyor.

**Senaryo:** Uzman A metni kaydeder; B bu kaydı okuyup değiştirir ve kaydeder; ardından A'nın onay isteği gelir. A'nın isteği B'nin son metnini kilitleyip onaylayabilir. A'ya yeni metin gösterilip kabul ettirilmez. Bu, önceki kontrol/yazım yarışıyla aynı sorun değildir: eklenen kilitler eski yarışı gideriyor; kalan sorun içerik sürümüne bağlı onay eksikliğidir.

**Düzeltme:** Onay isteğine beklenen rapor sürümünü ekleyin; transaction ve satır kilidi altında güncel sürümle karşılaştırın. Uyuşmazlıkta 409 dönüp uzmana yeni metni gösterin. Kaydetme yanıtında yeni sürümü döndürmek ve onayı o sürüme bağlamak akışı kolaylaştırır.

**Kabul testi:** A'nın gördüğü/kaydettiği sürümden sonra B metni değiştirsin. A'nın eski sürümle onayı 409 dönmeli; B'nin raporu onaysız kalmalı. Mevcut `RadyolojiRaporYarisTestleri` eski sürümle kaydetmeyi ve kilitli raporu test ediyor; onay için bu araya giren değişiklik senaryosunu kapsamıyor.

## Önceki 7 bulgunun durumu

| Bulgu | Takip sonucu |
|---|---|
| B01 — sabit üretim JWT anahtarı | Kodda giderilmiş: Production anahtar kontrolü, kurulum başına rastgele kalıcı anahtar ve Gizli ayar dosyası eklenmiş. Canlı anahtar dönüşümü doğrulanmadı. |
| B02 — radyoloji kayıt kapsamı | **Kısmen giderilmiş.** Grup filtresi istem/rapor/hasta route kimliklerini koruyor; rapor geçmişi ayrıca süzülüyor. T01 açık. |
| B03 — yazdırma XSS | Önceki raporda belirtilen masraf formu ve yatak etiketi `h()` ile kaçırılıyor. İzin/avans çıktıları da düzeltilmiş. Bu, bütün HTML işleyen ekranların güvenli olduğuna dair genel bir sertifika değildir. |
| B04 — rapor ezilmesi/onaylı içeriğe yarış | Kaydetmede `xmin` sürümü ve aynı sırada istem/rapor kilitleri eklenmiş; onay uygunluğu kilit altına taşınmış. Eski bulgunun temel nedenleri giderilmiş. Ek onay sürümü açığı T02'de. |
| B05 — access token iptal olmaması | JWT aile kimliği taşıyor; kapı her istekte kullanıcının açık aile satırını doğruluyor; şube değişimi aynı aileyi koruyor. Kod düzeltmesi mevcut. |
| B06 — kilitli raporu ön rapora alma | Hedef beyaz listesi, kilit altında ret ve etkilenen satır kontrolü eklenmiş. Önceki hata kodda giderilmiş. |
| B07 — postgres ile uygulama bağlantısı | Varsayılan yayın akışında kurulum başına sınırlı rol eklenmiş; migration rolü ayrılmış. Gerçek sunucu rol yetkileri ve diğer DB'lerin CONNECT durumu doğrulanmadı. `-SuperRolIleBaglan` açık bir acil durum istisnası olarak duruyor. |

## Doğrulama

- Web: `npm test -- --reporter=dot` → **143 dosyada 1.005 test geçti.** jsdom `Window.alert` uyarıları testleri düşürmedi.
- Standart API test komutu: çalışan bir süreç `Gentegre.Veri.dll` dosyasını kilitlediğinden MSB3021/MSB3027 ile derleme aşamasında durdu. Bu bir C# derleme hatası olarak sınıflandırılmadı.
- Önceden derlenmiş DLL ile `--no-build` denemesinde 8 test geçti; mevcut kaynakların tamamını doğruladığı kabul edilmedi.
- Güncel kaynaklar ayrı `bin/Review` çıktı klasöründe yeniden başarıyla derlendi. `gentegre_ai_test` üzerinde `GENTEGRE_TEST_ZORUNLU=1` ile **17 hedefli test geçti, 0 atlandı, 0 başarısız**. Seçim: `RadyolojiErisimTestleri`, `RadyolojiRaporYarisTestleri`, `OturumGuvenligiTestleri`, `UretimAnahtariTestleri`. Testler mevcut istem/rapor kapsam kapısını, eski sürümle kayıt reddini, kilitli rapor geçişini ve oturum iptalini doğruluyor; T01/T02 senaryolarını kapsamıyor.
- Bütün API test paketi güncel derlemeyle tekrar çalıştırılmadı. `GENTEGRE_TEST_API_DB` sağlanmadığı için sınırlı uygulama rolü kabul testleri bu hedefli koşuya dahil edilmedi; API bütünleşme testleri test DB bağlantısının mevcut rolünü kullandı.

Canlı sisteme yayın yapılmadı, çalışan kullanıcı API'si durdurulmadı. Test bağlantısı yalnız `gentegre_ai_test` veritabanına yönlendirildi; ortak geliştirme DB'si test fixture hedefi yapılmadı.
