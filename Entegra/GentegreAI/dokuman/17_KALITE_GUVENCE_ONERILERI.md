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

## 5. Önerilen ilk adımlar

| Sıra | İş | Tahmini | Getirisi |
|---|---|---|---|
| 1 | Katalog tutarlılık testleri (2.3) | ~2 saat | Bu oturumdaki hataların çoğunu derlemede yakalar |
| 2 | Bütün ekranları dolaşan duman testi (2.2) | ~2 saat | Ekran açılmıyor / 500 türünü yayından önce yakalar |
| 3 | `hata_log` günlük özeti (2.1) | ~1 saat | Kullanıcıya çıkan hatayı aynı gün görmek |
| 4 | Test veritabanı + `GENTEGRE_TEST_DB` (2.4) | ~1 saat | 362 atlanan test çalışır |
| 5 | Migration durum sorgusu (2.5) + yayın takvimi (3.1) | ~1 saat | Sunucu farkı görünür |
