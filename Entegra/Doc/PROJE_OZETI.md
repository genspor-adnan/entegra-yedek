# Gentegre / Entegra — Proje Özeti

*Kaynak: repodaki `architecture.md`, `ui-guidelines.md`, `error-handling.md`, `ebelge-akis.md`, `loglama-sistemi.md`, `belge-depolama.md`, `postgres-gecis-maliyeti.md`, `CLAUDE.md` ve `.claude/agents` dokümanları. Tarih: 2026-08-12.*

## 1. Proje nedir

Gentegre (eski adıyla Entegra), **Feta Bilgisayar / Genyazılım** tarafından geliştirilen kapsamlı bir **masaüstü ERP** uygulamasıdır. Finans, stok, CRM, proje yönetimi, evrak/doküman takip, kalite ve İK modüllerini tek çatı altında toplar. Kod, yorumlar, tanımlayıcılar ve arayüz metinleri ağırlıklı olarak **Türkçe**'dir.

**Teknoloji yığını:**

| Katman | Teknoloji |
|--------|-----------|
| Dil / IDE | Delphi 13.1 (Embarcadero RAD Studio 37.0), VCL, Win32 hedefi |
| Bileşenler | DevExpress (cx*/dx*), FastReport, JVCL, FireDAC (yeni), ADO (eski) |
| Veritabanı | Microsoft SQL Server (60+ tablo, aktif dev DB: `BILIM` + `GENDEPO`) |
| Kod hacmi | 400+ Pascal birimi, 266 form (U*.pas), 113 frame, ~565 bin satır |

**Üç giriş noktası:** `Gentegre.dpr` (modern, aktif geliştirilen), `entegra.dpr` (legacy), `Rehber.dpr` (bağımsız adres defteri).

## 2. Mimari

Uygulama **frame tabanlı, katmanlı** bir mimari kullanır. Arayüz üç panele ayrılır: solda arama/filtre (`AramaFrame`, 35+), ortada içerik ve liste (`IcerikFrame` + `ListeFrame`, 30+'şar), sağda görev/aksiyon (`GorevFrame`). Bu paneller `UGenelAnaSekmeFrame` tarafından orkestre edilir; sekme yapısı kod içinde sabit değil, **`entegra_sekmeconfig.xml`** ile veri-güdümlü tanımlanır ve frame'ler `UFrameYoneticisi` / `UGentegreFrameYonetimi` fabrikası ile dinamik yüklenir.

Temel tasarım kalıpları: merkezi veri modülü (`Utablo.pas` — `FDConnection`, paylaşılan sorgular, `cxEditRepository1`, stil ve ikon depoları burada), wizard kalıbı (çok adımlı iş akışları — `UFaturaWizard`, `UStokWizard`, `UProjeWizard`), moduller arası bildirim için event bus (`UMultiCastEvent.pas`), ve grid/liste ekranlarının giderek `sp_Prog_<Modül>_Liste_Json2` sunucu-taraflı SP'lerine kayması.

**Entegrasyonlar:** GİB e-Fatura/e-Arşiv/e-İrsaliye (`eFaturaApi/`), banka ekstre indirme (TEB, ING, Garanti), ITS (depo yönetim), UTS (ürün takip / seri no), POS-adisyon yazıcıları (TCP üzerinden, `Rest/`), SMS ve e-posta gönderimi.

## 3. Kritik konvansiyonlar

**Veri erişimi:** Ad-hoc SQL elle `TFDQuery` bloklarıyla değil, `Veritabani` sınıfı üzerinden yazılır — `VeriVarMi` (varlık kontrolü), `BasitKomutÇalıştır` (ExecSQL), `SorguBaslat` (dataset). Parametreler `&ad` token'larıyla geçilir. Elle yazılan sorgular hem kod kokusudur hem de `PgSqlCevir` PG diyalekt dönüşümünü atlar. Sadece blob streaming veya uzun ömürlü dataset'ler için ham `TFDQuery` kullanılır.

**Hata yönetimi:** Standart transaction akışı `StartTransaction → try → Commit / except → (InTransaction ise) Rollback → raise`. Yakalanmamış hatalar `UKimlik.pas` içindeki `Application.OnException` ile toplanır; kullanıcıya `UHataDialog`'un `ShowErrorDialog`'u ile gösterilir (yeşil=başarı, gümüş=bilgi, kırmızı=hata). Sessiz `except` sadece kritik olmayan işlerde (yazıcı, oturum ayarı) kullanılır.

**Arayüz standartları:** Tema *London Liquid Sky*, font *Trebuchet MS* + `TURKISH_CHARSET`, içerik alanları `clWhite`, formlar `clBtnFace`. Tüm ortak bileşen/stil/ikon tanımları `Utablo.dfm` içindeki `cxEditRepository1`, `cxStyleRepository1` ve `PNGImageList*` içindedir.

## 4. Öne çıkan alt sistemler

**Loglama / Audit (ISLEMLOG):** "Kim, ne zaman, hangi kayıtta ne yaptı" denetim sistemi. Tüm kart/detay ekle-değiştir-sil işlemleri ayrı `GENDEPO` deposundaki yıllık `LOG<yyyy>` tablolarına (sıkıştırılmış JSON) yazılır, `ISLEMLOG` view'i birleştirir, uygulama içinde **UInfo** ekranından okunur. Kritik kurallar: ekleme logu form **kapanırken tek sefer** yazılır (AfterPost'ta değil), silme logu **DELETE'ten önce** yazılır, silinen kayıt **"Geri Al"** ile diriltilebilir. Merkez: `Ortak/ULog.pas`.

**Belge / Medya depolama:** Üç katman — iş kaydı → `IMAJ` (metadata/ilişki) → içerik. Eski yapı (`IMAJ.BELGE` blob veya diskte `.OBJ`) yerini yeni `GENDEPO.DOSYA` (FILESTREAM + SHA-256 hash-dedup + refcount) yapısına bırakıyor. FILESTREAM, SQL Express'in 10 GB limitine sayılmadığı için tercih edildi; migrasyon aracı geri-alınabilir (BELGE'ye dokunmaz).

**e-Belge akışı:** GİB e-Fatura/e-Arşiv/e-İrsaliye entegrasyonu. `FATBASLIK.TUR` (14/15/16), `REHBERALIAS.BELGETURU` (140/141/150/151) ve `EFATURADURUM`/`EFATURASONUC` durum kodlarıyla belge tipi ve süreç izlenir; izibiz/GİB inbox statü eşlemeleri `UEBelgeGelen.pas`'te. Karar mantığı `UFaturalar.MenuEFatura` / `UOpsiyonFatura` / `UEBelgeOlusturucu`'da.

## 5. PostgreSQL geçiş çalışması

Devam eden ama **`pg/` klasörü ve `pg-migration` branch'ine izole** bir çaba, uygulamayı SQL Server'dan PostgreSQL'e taşımayı hedefliyor. Müşteri/sürüm derlemeleri stabil `backup/…` branch'lerinden çıkar; `pg/` üretime ulaşmaz.

Envanter değerlendirmesi bunu **stratejik, yüksek riskli, 6–18 aylık çok kişili bir re-platform** olarak tanımlıyor: ~331 sunucu nesnesi (182 SP + 121 fonksiyon + 28 trigger, 42'si cursor'lu), ~7.600 satır-içi T-SQL, cross-database depo mimarisi (`DepoTablo`, 62 yer), Türkçe case-insensitive collation (en sinsi bug kaynağı) ve FILESTREAM başlıca engeller.

Bu nedenle **her yeni kod bugün iki motorda da çalışacak şekilde** yazılıyor: engine-farklı mantıkta SQL yerine Pascal tercih ediliyor, gerçek diyalekt boşlukları için merkezi `PgSqlCevir` + seam helper kullanılıyor, `bit → smallint` gibi tuzaklara dikkat ediliyor. Test altyapısı olmadığı için güvenlik ağı **differential testing** (aynı girdiyi iki motorda çalıştırıp `db_diff.ps1` ile karşılaştırma).

## 6. Aktif mühendislik çalışmaları (`Doc/` klasörü)

`Doc/` klasörü, iki büyük yeniden yapılandırma çalışmasının planlama/karar/sonuç dokümanlarını içerir. Her ikisi de 2026-08 tarihli, "önce canlı veriden envanter, sonra karar, sonra kod, sonra differential test" disipliniyle yürütülmüş.

### 6.1 Belge Dönüşüm SP'leştirme (`BelgeDonusum_*`)

Amaç: sipariş/irsaliye/fatura/fiş/konsinye/üretim belgeleri arası dönüşüm mantığını Delphi tarafında dinamik SQL üretmek yerine, **tek transaction altında SQL Server stored procedure'lerine** taşımak. `Utablo.BelgeDonustur` ince bir istemciye dönüşüyor.

Kapsam **22 dönüşüm rotası** (406–478 arası kodlar); adisyon (404/405) ve teklif→sipariş (412/413) kapsam dışı. Mimari, uygulamanın yalnızca iki SP'yi çağırdığı (`sp_Prog_BelgeDonusum_Kaynak_Json2` okuma + `sp_Prog_BelgeDonusum_Uygula_Json2` ana/transaction sahibi), ana SP'nin JSON'u bir kez `#temp` tablolara açıp alt SP'leri (`Dogrula`, `Kaydet`, `IzlemeAktar`, `UretimAktar`, `Sonlandir`) aynı session'da çağırdığı bir yapı. Belge üretimi için ikiz nesne yazmak yerine kanonik `sp_Api_Belge_Kaydet_Json` genişletilerek kullanılıyor. Idempotency `BELGEDONUSUMISLEM` tablosu + `@IstekID` ile sağlanıyor (aynı istek tekrar gelirse önceki sonuç dönüyor).

Bu çalışma yol boyunca **eski koddaki gizli hataları** ortaya çıkardı ve bunlar bilinçli "onaylı davranış değişikliği" olarak differential teste dahil edildi: çift dönüşüm (aynı sipariş satırının hem irsaliyeye hem faturaya çevrilip kalanın iki kez tüketilmesi — canlı veride kanıtlandı), stok yetersizliğinde sessizce eksik belge oluşması (artık tam rollback), izlemeli üründe boş başlık kalması, kısmi izlemede kaynak kalanının sıfırlanması, çok satırlı INSERT'te tek-satır varsayımı yapan trigger'lar (`Trg_Fatura_MasrafID_Guncelle` set-bazlıya çevrildi). Adım 1–6 ve 8 tamamlandı (GenDepoUpdate 87–93 + 113–114); kalan iş differential testler ve eski dalların temizliği.

### 6.2 Seri/Lot (İzleme) alt sistemi yeniden tasarımı (`Izleme_*`, `Sayim_*`)

`UIzleme` ekranı "kırılgan" olduğu için yeniden tasarlandı. Kök sebep: ekran **kendi yazıyordu ve bunu `FormDestroy`'da (form yok edilirken, mrOk'tan sonra) yapıyordu** — hata olursa kullanıcıya mesaj gitmiyor, çağıranın transaction'ına giremiyordu. Ayrıca liste 7 gömülü DFM memo sorgusundan, metin birleştirmeli geçici tablolarla ve SERINO+LOTNO+SKT metin+COLLATE eşleştirmesiyle üretiliyordu.

Yeni çekirdek ilke: **"ekran seçer, yazmaz."** Okuma/kural/yazma/taşıma dört kanonik SP'ye taşındı (`sp_Prog_Izleme_Aday/Dogrula/Yaz/Aktar_Json`), eşleştirme metin üçlüsü yerine `SERILOTID` ile yapılıyor, yazma çağıranın transaction'ında oluyor. Altı çağıran (fatura/transfer/üretim wizard'ları, belge dönüşümü) bu desene taşındı.

Bu çalışma da bir dizi **canlı hata** ortaya çıkardı: kısmi taşımada kalanın sıfırlanması, izlemeli üründe adet kilidi (2022'den beri), sipariş kaynaklı izlemeli ürünün hiç işlenmemesi, alış yolunun hiç sınanmamış olması (4 ayrı hata), silme sırasının bakiyeyi bozması. Ayrıca **Sayım ekranı ayrıldı** (`UStokSayim`): incelemede sayım izlem verisinin hiçbir yere kaydedilmediği (4.200 izlemli kalem, `STOKIZLEME`'de sıfır kayıt; kod artık var olmayan kolonlara yazıyordu) ve izlemli ürünlerde sayım farkının fişe hiç yazılmadığı bulundu — yani kaldırılan çalışan bir işlev değildi. İzleme A1–A8 tamamlandı (GenDepoUpdate 94–114).

**Önemli not (dağıtım riski):** Bu SP'lerin çoğu şu an yalnızca dev DB'de (`BILIM`); `GenUpdate/GUNCELLEMELER`'e eklenmedi ve PG portları yapılmadı. Müşteriye bu haliyle çıkarsa exe SP'leri arar, bulamaz. Ayrıca `rapor_ado_envanter_ekspert.txt`, FastReport şablonlarında hâlâ ADO nesnesi (sökümü riskli) kullanan 8 rapor tespit eder.

## 7. Derleme ve geliştirme notları

Derleme `build.bat` ile (önce `ensure_utf8_bom.ps1`, sonra `rsvars.bat` + `msbuild Gentegre.dproj`). Pratikte kullanıcı RAD Studio IDE'sinden derler. **Otomatik test yok** — değişiklikler ilgili ekranı çalıştırarak doğrulanır. DB değişiklikleri `GenUpdate/` altında yeni numaralı `GenDepoUpdateN.sql` dosyalarına yazılır (mevcut dosyalar düzenlenmez), müşterilere `UVersiyonGuncelle.pas` ile dağıtılır. Commit'ler küratörlü değil, tüm-ağaç checkpoint'leridir; dated `backup/YYYYMMDD` branch'leri yedektir.

`.claude/agents/sayfalayici` adında özel bir ajan da mevcut: bir liste ekranını merkezi `TSayfaliListe` sayfalama desenine bağlayan, 3 noktada değişiklik yapan tek-işlevli yardımcı (`.md` ve `.toml` formatlarında).
