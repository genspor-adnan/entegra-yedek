# 17 — Kalite Güvence Önerileri (13.10.2026)

Kullanıcı: "proje çok büyüdü.. sistemin düzgün kullanılabilmesi, hataların çabuk
fark edilip eksiklerin hızla giderilebilmesi için ne tür öneriler sunarsın?
senin işleyiş esnasında nasıl katkın olur?"

## 1. Bu oturumda görülenler (neden gerekli)

Sorunların çoğu **sessizce birikti**; kullanıcıya hata olarak dönüyordu ama kimse
görmüyordu:

| Bulgu | Etki | Ne zamandan beri | Nasıl yakalandı |
|---|---|---|---|
| `DokumanDeposu` kaynak beyaz listesinde `ariza`, `duyuru`, `izin`, `avans`, `belge-talep`, `rad-cihaz`, `demirbas` yoktu | Bu ekranların **Belgeler** sekmeleri "Bilinmeyen kaynak" ile 500 veriyordu (kalibrasyon sertifikası dahil) | 04.10.2026 (demirbaş 10.10) | Eğitim belgesi eklerken tesadüfen; `hata_log`'da kayıtlıydı |
| `kalite_gosterge_deger`, `kalite_denetim_bulgu`, `kalite_komite_uye` tablolarında `ekleyen` / `degistiren` kolonları yoktu | Dönem değeri düzeltmek ve denetim bulgusu eklemek 500 | 1051 / 1053'ten beri | "Değer Gir" ekranını denerken |
| Vite geliştirme sunucusu bazı dosya değişikliklerini görmedi | Eski kod sunuldu, ekran "düzelmemiş" göründü | aralıklı | Ekran görüntüsü karşılaştırması |
| xUnit'te **362 test atlanıyor** | Veritabanı testleri hiç çalışmıyor | `GENTEGRE_TEST_DB` tanımlı değil | Test özetinde "Atlanan: 362" |
| 1048–1074 migration'ları yalnız dev veritabanında | Sunucular geride; yayın günü risk büyük | uzun süredir | — |

## 2. Hataları çabuk yakalamak için

1. **Hata günlüğünü izlemek.** `hata_log` her 500'ü izleme numarası ve yığınla
   tutuyor. Günlük özet: yeni hata türleri, en çok tekrarlananlar, hangi ekran.
   Beyaz liste hatası ilk gün görünürdü.
2. **Bütün ekranları dolaşan duman testi.** Menü tanımlarından (`LISTELER`)
   otomatik üretilen Playwright betiği: her menü satırını aç, ilk kaydın kartını
   aç, konsol / sunucu hatası var mı bak. Birkaç dakika; her commit ya da her
   yayın öncesi.
3. **Katalog tutarlılık testleri** ("bir yere eklendi, öbür yere eklenmedi" türü):
   - her `DokumanUclari.FizikselKaynak` hedefi `DokumanDeposu` beyaz listesinde mi,
   - her `DetayTanimi` tablosunda `ekleyen` / `degistiren` kolonları var mı,
   - her `YetkiKodu` veritabanında var ve aktif mi,
   - her liste kolonu görünümde gerçekten var mı,
   - her kart bir kez okunup yazılabiliyor mu (kart + detay ekle / düzelt / sil).
4. **Veritabanı testlerini açmak.** Bir test veritabanı + `GENTEGRE_TEST_DB`;
   atlanan 362 test çalışır.
5. **Migration takibi.** Her sunucuda hangi migration'ın uygulandığını gösteren
   sorgu / ekran; "dev'de var, sunucuda yok" farkı görünür.

## 3. Sistemin düzgün kullanılması için

1. **Düzenli yayın** (örn. haftalık): önce yedek, sonra migration, sonra duman
   testi. Uzun aralık hem riski hem geri bildirim gecikmesini büyütüyor.
2. **Örnek veri / demo.** Her modüle küçük, gerçekçi örnek veri (kalite modülüne
   13.10.2026'da girildi). Eğitim, satış ve testte boş ekran yerine dolu ekran.
3. **Ekrandan geri bildirim.** "Sorun bildir" düğmesi: ekran adı + son izleme
   numarası + kullanıcı notu bir listeye. Hata "çalışmıyor" yerine izleme
   numarasıyla gelir, kaynağı doğrudan `hata_log`'dan bulunur.
4. **Kullanılmayan ekranları görmek.** `islem_log`'dan ekran kullanım sıklığı;
   büyüyen projede sadeleştirmeye nereden başlanacağını gösterir.
5. **Mockup – kod takibi.** Hangi mockup kodlandı / kısmen / yok: tek sayfa
   (kalite ekranları 12–13.10.2026'da tek tek elle karşılaştırıldı).

## 4. Claude'un katkısı (işleyiş sırasında)

- **Her değişiklikten sonra:** derleme + testler + ilgili ekranların tarayıcıda
  duman testi (yapılıyor; ortak betik olursa her seferinde bütün sistem).
- **Oturum başında:** son 24 saatin `hata_log` özeti ve "dev'de olup sunucuda
  olmayan migration" listesi.
- **Hata bulunca:** yalnız düzeltmek değil, aynı türü yakalayacak testi de yazmak.
- **Paralel denetim:** büyük işlerde bir ajan kod incelemesi, biri ekran
  dolaşması; istenirse düzenli aralıklarla (`/loop`).
- **Kalıcı notlar:** öğrenilen tuzakları (beyaz liste, detay kolonları, Vite'ın
  eski dosya sunması) belleğe yazmak.

## 5. Kurulanlar (13.10.2026)

- **Katalog tutarlılık testleri** - `KatalogSemaTestleri` (liste SQL'i, kart /
  detay kolonları, yetki kodları; test DB'si) + `DokumanKaynakBeyazListeTestleri`
  (DB gerekmez). İlk koşu: **21 tabloda** kartın yazdığı `ekleyen` /
  `degistiren` / `sube_id` eksikti (acil, ameliyat, lab, çağrı, personel,
  sterilizasyon...) - hepsi 1075 ile eklendi. Beyaz liste testi eksik
  "demirbas" ile denendi, yakalıyor.
- **Test DB'si** `gentegre_ai_test` dev DB'den yenilendi (934. migration'da
  kalmıştı). `GENTEGRE_TEST_DB` ile **653 testin 638'i geçiyor, 15'i kırmızı**
  (önceden 362'si atlanıyordu). Kırmızılar bugüne dek hiç koşmamış eski testler:
  - 3 test yok olan rol id'si (0) ile kullanıcı açmaya çalışıyor (fixture),
  - rol / yetki beklentileri veriyle uyuşmuyor (iskonto tavanı, rehber ekranı,
    "steril" modül kodu, banko şefi rolleri, YZ kontör),
  - **portal kapsamı**: `dis_doktor` ve `dis_istem_kurumu` rolleri `departman`
    listesini kapsam kuralı olmadan görüyor - gözden geçirilmeli.

  **Düzeltildi (13.10.2026) - 653 / 653 yeşil:**
  - 10 test 1000 / 1001'deki rol kodu değişikliğini izlememişti
    (`kayit_kabul` → `banko_gorevlisi`, `kayit_kabul_sorumlu` →
    `banko_sorumlusu`); "rol_id 0" hatası da bundandı. Testler güncellendi.
  - `steril_sorumlu` rolü 908'de kaldırılan `steril` modülüne bağlıydı; artık `dis`.
  - Portal: `departman` yetkisi dış doktor / dış kurum rollerinden alındı (1077).
    Bu portallarda bölüm süzgeci kullanan ekran yok; hasta portalı (randevu) korundu.
  - Üst yönetim salt-okuma testi, her role verilen self-servis `ariza.talep`
    (911) yetkisini dışlıyor.
- **Duman testi** - `npm run duman` (web/duman/menu.duman.ts). Bütün menü 377
  ekran, ~5 dk. İlk koşuda **4 gerçek hata**:
  1. İK › İzin Hakedişi: menü katalogda olmayan kaynağa bağlı
     ("Bilinmeyen liste kaynagi: personelIzinHak") - ekran hiç açılmıyor.
  2. Kronik Tanılar kartı 500: kod çözümleyici ICD kodu "I10"u sayıya
     çevirmeye çalışıyor.
  3. Platform › Zamanlanmış İşler: satıra çift tık `/zamanli-is/undefined`
     açıyor (kimlik kolonu `kod`, çift tık `id` kullanıyor).
  4. e-Nabız Gün Sonu: React "key" uyarısı.

  **Dördü de düzeltildi (13.10.2026):** İzin Hakedişi liste kaynağı eklendi;
  kart kod çözümleyicisi metin kimlikli lookup'ı (ICD) sayıya çevirmiyor;
  `zamanli_is`'e sayısal `id` (1076) - kart artık açılıyor; e-Nabız gün sonunda
  anahtarlı Fragment. Duman testi sonrası: **377 ekran, 0 hata.**
  Betik ayrıca sayfanın kendi yönlenmesine karşı yeniden deniyor (yanlış alarm).

- **Hata günlüğü özeti (§2.1, 1078)** - hata_log türüne göre gün gün:
  imza = kod + HTTP + yöntem + yol + mesaj (sayılar normalize), "yeni" = o gün
  ilk kez görülen tür.
  - Ekran: **Yönetim › Güvenlik › Hata Özeti** (`hata_ozet` yetkisi; yönetici +
    bilgi işlem, salt okunur). Çipler: Tümü / Sunucu / Yeni.
  - Zamanlı iş `hata.ozet` her sabah dünün tek satır özetini işin son
    sonucuna yazar (kimseye mesaj göndermez).
  - Terminal: `db/araclar/hata_ozet.ps1` (`-Gun 7`, `-Hepsi`) - 5xx ve yeni
    türler, izleme numarasıyla.
  - Zamanlı işlerin saati UTC yorumlanıyordu (ekranda 07:30 = yerel 10:30,
    bütün günlük / haftalık / aylık işler 3 saat geç). **1079 ile düzeldi:**
    saat kurumun duvar saati (`Kurulus:SaatDilimi`); kartta zamanlama
    değişince sıradaki zaman bir dakika içinde yeniden hesaplanıyor.
  - `AiKontorTestleri` aralıklı kırmızıydı (flaky): `ModelTestleri` aynı tek
    satırlık `ai_kontor` bakiyesini paralel olarak 10'a sabitliyordu. İkisi
    `KontorKoleksiyonu`nda sırayla koşuyor; üç tam koşu 658 / 658.

## 6. Önerilen ilk adımlar (13.10.2026 öncesi plan)

| Sıra | İş | Tahmini | Getirisi |
|---|---|---|---|
| 1 | Katalog tutarlılık testleri (2.3) | ~2 saat | Bu oturumdaki hataların çoğunu derlemede yakalar |
| 2 | Bütün ekranları dolaşan duman testi (2.2) | ~2 saat | Ekran açılmıyor / 500 türünü yayından önce yakalar |
| 3 | `hata_log` günlük özeti (2.1) | ~1 saat | Kullanıcıya çıkan hatayı aynı gün görmek |
| 4 | Test veritabanı + `GENTEGRE_TEST_DB` (2.4) | ~1 saat | 362 atlanan test çalışır |
| 5 | Migration durum sorgusu (2.5) + yayın takvimi (3.1) | ~1 saat | Sunucu farkı görünür |
