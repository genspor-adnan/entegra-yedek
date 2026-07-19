# İşlem Loglama (Audit) Sistemi — ISLEMLOG

> Gentegre'de tüm kart/detay ekleme–değiştirme–silme işlemlerinin denetim (audit) kaydı:
> nereye, nasıl yazılır; nasıl okunur/çözümlenir (UInfo); nasıl geri alınır.
> Çekirdek: `Ortak/ULog.pas` + `GENDEPO` log tabloları. 2026-07 itibarıyla.

---

## 1. Amaç ve genel mimari

"Kim, ne zaman, hangi kayıtta ne yaptı" sorusunu yanıtlar. Her kart ve detay değişikliği
**GENDEPO** deposundaki yıllık log tablolarına yazılır; uygulama içinde **UInfo** ekranından
okunur/çözümlenir; silinen bir kayıt **Geri Al** ile diriltilebilir.

```
Form/Wizard  --->  ULog.pas merkezi yardımcıları  --->  GENDEPO.LOG<yyyy>
(kart+detay)       (LogKartEkle/Degisti/Sil...)         (ISLEMLOG view birleştirir)
                                                                |
                                    UInfo ekranı  <----  LOGCOZUM (ID→ad) +
                                    (Liste/İçerik)       LOGREFERANS (kart adı/kodu) +
                                                         TABLOLAR (TABLOID→ad)
```

- **Depo:** loglar `GENDEPO`'da (ana iş DB'sinden ayrı). Ana DB'de `ISLEMLOG` **synonym**'i
  vardır. ULog otonom bir bağlantı (`LogBaglantisi`, MARS) ile doğrudan depoya yazar.
- **Yıllık tablo:** `LOG2026`, `LOG2027`... Hepsini birleştiren `ISLEMLOG` **view**'i
  (`IslemLogViewKur` çalışma anında yeniden kurar / self-heal).
- **Çok-instance:** depo adı sabit değil; `@depo` GENINI'den çözülür ([[gendepo-update-scriptleri]]).

---

## 2. Log tablosu şeması (`LOG<yyyy>` / `ISLEMLOG`)

| Kolon | Tip | Açıklama |
|-------|-----|----------|
| ID | bigint identity | |
| TARIH | datetime2 | İşlem zamanı |
| IP / ISTASYON | varchar | Kaynak makine |
| KULLANICIID | int | Kim |
| SUBEID | smallint | Şube |
| **ISLEMTIPI** | tinyint | **0=sil, 1=ekle, 2=değiştir** (grup/kart modu; **Liste gruplaması bunu kullanır**) |
| **ALTISLEMTIPI** | tinyint | Satırın **gerçek** tipi (override edilince kaybolmasın; İçerik bunu gösterir) |
| **USTTABLOID / USTKAYITID** | int / bigint | **Master (kart)** — detaylar buna bağlanır (grup anahtarı) |
| **TABLOID / KAYITID** | int / bigint | Bu satırın tablosu ve kaydı |
| REHBERID / STOKID | bigint | Kart adı/kodu çözümü için referans |
| **BILGI** | varbinary(max) | **Sıkıştırılmış JSON** `{alan:değer}` (`DECOMPRESS(BILGI)` ile okunur) |

- **Kart satırı:** `TABLOID = USTTABLOID` (ve `KAYITID = USTKAYITID`).
- **Detay satırı:** `USTTABLOID/USTKAYITID` = kart; `TABLOID/KAYITID` = detay tablosu/satırı.
- **Grup:** gün + `USTKAYITID` + `USTTABLOID` + `ISLEMTIPI` → UInfo Liste'de **tek satır**;
  o grubun tüm alan değişiklikleri İçerik'te toplanır.

### TABLOID (modül kodları — örnekler)

TABLOID→ad eşlemesi `GENDEPO.TABLOLAR` (`sql_tablolar_kur.sql`). Örnekler:
cari=71, stok=88, proje=70, görev=33, fırsat=170, teklif=97/98, servis=83, demirbaş=18,
doküman=321, fatura=28/29/30 (+FATURA detay), sipariş=91/92, üretim fişi=144/145,
çek/senet=315/316/318/319 (+CEKHAREKET=317), POS=69, banka=7, kredi=47, rol=80, yetki=484,
GENINI/ayar=485, sistem=900.

---

## 3. Ne loglanır — kart + detay + silme

- **Ekleme (ISLEMTIPI=1):** kart eklendiğinde **form/wizard KAPANIRKEN TEK SEFER** (AfterPost'ta
  DEĞİL → mükerrer/3x olurdu). `FEkleLogland` bayrağı + FormClose/Destroy fallback.
- **Değiştirme (ISLEMTIPI=2):** eski↔yeni **diff**; sadece değişen alanlar.
- **Silme (ISLEMTIPI=0):** **SQL DELETE'ten ÖNCE**, kayıt hâlâ dururken (sonra olursa cursor
  kayıp → yanlış ID loglanır).
- **Detaylar:** master (kart) ile `USTTABLOID/USTKAYITID` üzerinden bağlanır → aynı grupta.

---

## 4. Merkezi yardımcılar (`Ortak/ULog.pas`)

Yeni bir modülü loglarken **ham `OncekiLogBelirle`+`LogIslemleri` çağırma**; bu yardımcıları kullan:

| Fonksiyon | Ne zaman |
|-----------|----------|
| `LogKartEkle(Ds, TabNo, eklemeModu, zatenLogland): Boolean` | Kart ekleme — TEK SEFER (kaydet + kapanış fallback aynı çağrı; True dönerse `FEkleLogland:=True`) |
| `LogKartDegisti(Ds, TabNo, ID [, UstTabNo, UstID])` | Kart değiştirme (üst paramlarla detay için de) |
| `LogKartSil(Ds, TabNo, ID [, UstTabNo, UstID])` | Silme — **silmeden önce** |
| `LogDetaySatirPost(Ds, DetayTabNo, UstTabNo, UstID)` | Grid detay AfterPost (LogOnceki dolu→değiştir, boş→ekle) |
| `LogDiffKaydet(DetayDs, FDetSnap, DetayTabNo, UstTabNo, UstID)` | Detay dataset'in açılış snapshot'ına göre diff'i |
| `LogSnapshotAl(DetayDs, FDetSnap)` | Detay snapshot al/tazele (mükerrer save'i önler) |
| `LogDetaylariSil(detayTablo, ustKolon, detayTabNo, ustTabNo, ustID)` | Detayları silmeden önce topluca logla |
| `LogKayitSil(tablo, tabNo, kayitID, ustTabNo, ustID)` | Tek kaydı sil-logla; **WHERE anahtarı (kayitID) ≠ grup anahtarı (ustID)** (ör. karta dolaylı bağlı master). Silmeden önce |
| `LogUserAcilis(userTablo, kartID)` / `LogUserKaydet(userTablo, userTabNo, ustTabNo, kartID, yeniMi)` | Kart ek-alan (`_USER`) audit: açılışta baseline, finish'te ekle/diff (bkz. §11) |

Alt seviye: `LogYaz`, `LogKayitEkle`, `OncekiLogBelirle`, `LogIslemleri`, `LogReferansGuncelle`.

---

## 5. Kritik kurallar (bunları re-derive etme)

1. **Ekleme form kapanırken** ([[loglama-ekleme-form-kapanirken]]): AfterPost'ta değil; `FEkleLogland`
   bayrağı + FormClose/Destroy fallback. Ekle/değiştir ayrımı **State ile değil `IslemOp` ile**
   (kart Finish'ten önce Post edilmiş olabilir).
2. **Modified değilse Post etme** ([[kart-modified-degilse-post-etme]]): Finish'te kart değişmediyse
   `Cancel`; yoksa AutoEdit boş "değişiklik" loglar.
3. **Silme DELETE'ten önce**, kayıt dururken (liste-silme handler'larında YenileClick'ten önce).
4. **LogUstModu (grup tutarlılığı):** mevcut kartı düzenleyip alt detay eklenince UInfo'da iki
   satır çıkardı (kart=değiş + detay=ekle ayrı grup). `ULog.LogUstModu` (-1 kapalı, 0/1/2)
   detay satırının ISLEMTIPI'sini **ana kartın moduna** çevirir → tek grup/tek satır.
   Metot başında set (`yeniMi→1 değilse 2`), FormClose/Destroy'da `-1` reset.
5. **ALTISLEMTIPI:** override, detayın gerçek tipini (ekle/sil) gizliyordu → İçerik'te hepsi
   "Değişti" görünüyordu. `LOG<yyyy>.ALTISLEMTIPI` = satırın gerçek tipi; `ISLEMTIPI` = grup modu.
   İçerik `ISNULL(ALTISLEMTIPI, ISLEMTIPI)` gösterir.
6. **LogOnceki kontaminasyonu (çöp diff):** detay diff için kart snapshot'ı `LogOnceki`'yi kirletmesin
   → kart BeforeEdit'te `FKartSnap.Assign(LogOnceki)` sonrası `LogOnceki.Clear`. Detay için ayrı
   `FDetSnap` (TObjectDictionary) kullan → global `LogOnceki`'den etkilenmez.
7. **LogIslemleri(Islem=4) ekleme'yi kaçırır** (LogOnceki boş) → ekleme için daima `LogKayitEkle`.

---

## 6. Çözümleme ve görüntüleme (UInfo)

Log JSON'u ham ID'ler tutar (ör. `REHBERID:5900`). UInfo görüntülerken okunur ada çevirir.

- **LOGCOZUM** (`sql_logcozum_doldur.sql`): `ALAN` (JSON alanı) → `KAYNAKTABLO`/`IDKOLON`/`ADKOLON`
  ile ID→ad. `TABLOID` NULL=genel/dolu=modüle özel; `FILTRE`'de `{ALAN}` = kardeş alan değeri.
  `UInfo.DegerCoz` **değer sayısal değilse çözmez** (firma adı → convert hatası engeli).
  - Belge TUR/TIPI: `TUR→ISLEMTURLERI.AD`, `TIPI→ISLEMTURLERI.ACIKLAMA` (FILTRE `TUR={TUR}`).
- **LOGREFERANS** (GENDEPO): kart satırının **adı/kodu** (silinse bile kalıcı; canlı kart yoksa
  yedek). `LogReferansGuncelle` FIRMA/STOKADI/HESAPADI...(ad) + KOD/KODU/SERINO...(kod).
- **UInfo Liste KOD/AD önceliği:** kart satırı için COALESCE: kartın kendi LOGREFERANS'ı (LRk) →
  bağlı cari (LRc, 71/73/74) → stok (LRs, 88). Detay-only grupta ELSE dalı master kartın LRk'sini
  çözer. Özel: çek/senet→cari; üretim fişi→üretilen stok. Farklı collation → `COLLATE DATABASE_DEFAULT`.
- Ayrıntı: [[logcozum-uinfo-cozumleme]].

---

## 7. Geri Al (silmeyi diriltme)

UInfo Liste'de seçili kayıt **Silme** ise "Geri Al" (BtnGeriAl) görünür.
`ULog.LogGeriAl(UstTabloID, UstKayitID, Gun)`: silme grubunu (kart + tüm detaylar) log JSON'larından
**aynı ID ile** tabloya geri INSERT eder. Kart ID şu an başka kayıttaysa hiçbir şey eklemez
(referans bütünlüğü). Başarılı her insert "Ekleme (Geri Al)" olarak loglanır.

- Teknik: `GeriKayitEkle` — boş şablon dataset ile kültür-aware parse + dinamik `INSERT ([ID],...)`
  + `SET IDENTITY_INSERT ON/OFF` (aynı bağlantı, finally'de OFF). Ayrıntı: [[uinfo-geri-al]].

---

## 8. Özel loglama alanları

- **Opsiyonlar/Ayar (GENINI):** tüm `TOpsiyon*Dlg` formları GENINI (BOLUM negatif int) yazar.
  `ULog.LogAyarModu` bayrağı (Screen.OnActiveFormChange ile opsiyon formu açıkken True) → `AyarLogla`
  eski↔yeni diff'i `TabNo_AYAR=485`'e yazar. Bir opsiyon oturumu (`LogAyarOturum`) tek Liste satırı;
  İçerik'te tüm değişen opsiyonlar. AYARADI (BOLUM→ad/seksiyon), MODUL="Seçenekler".
- **Yetki/Rol:** ROLLER(80) ekle/değiş/sil; YETKI(484) gör/ekle/değiş/sil diff (UKullaniciYetki).
- **E-fatura menü:** hazırla/gönder/sıfırla/seri/önizle... her biri bir satır ([[efatura-menu-loglama]]).
- **Sistem/login (kayıt-bağımsız):** TABLOID=900 "Sistem" (e-fatura güncelle butonu vb.).

---

## 9. Dağıtım / kurulum

- **Yeni müşteri:** `GenDepoKur*.sql` (GENDEPO + LOG<yyyy> + ISLEMLOG view + LOGREFERANS + LOGCOZUM +
  TABLOLAR + synonym'ler) + `sql_ayaradi_doldur.sql`.
- **Mevcut müşteri:** `GenDepoUpdateN.sql` (idempotent, gün değişince yeni dosya).
- **Şema değişimi (kolon/index/veri):** ilgili `sql_*` kaynaklarını da güncelle
  ([[gendepo-update-scriptleri]]).
- **Collation:** GENDEPO artık ana DB ile aynı CP1254; yeni log nesnelerinde açık COLLATE
  ([[gendepo-collation-cp1254]]).

---

## 10. İlişkili: Geri-alınabilir oturum (snapshot)

Ayrı ama akraba mekanizma: form/wizard **İptal = ilk hale dön**. `GENDEPO.SNAPSHOT` + `OturumBaslat/
GeriAl/Bitir`; loglama altyapısını (GeriKayitEkle) yeniden kullanır ama audit log DEĞİL, geri-alma
amaçlıdır. Ayrıntı: [[geri-alinabilir-oturum-snapshot]].

---

## 11. `_USER` (kart ek kullanıcı alanları) + ID'siz/bileşik detaylar

Kullanıcı-tanımlı ek alanlar artık kartın gövdesinde değil, `<KART>_USER` yan tablosunda tutulur
(kart ile **1:1**, `_USER.ID = kart.ID`). Formda `CodexDts<TABLO>USER` dataseti
(`Utablo.UserDataSourceHazirla` açar/oluşturur, `UserDataSourceKaydet` post eder).

**Tablolar & TABLOID (500–512 bloğu):** DEMIRBAS_USER=500, DOKUMAN=501, FATBASLIK=502, FATURA=503,
REHBER=504, SERVIS=505, SERVISHAREKET=506, SIPARIS=507, STOKLAR=508, TEKLIF=509, URETIMEMRI=510,
URETIMOPERASYONPERSONEL=511, **DEMIRBAS_TUTANAK (master, hareket) = 512**.
`Utablo.TabNo_*_USER` sabitleri + `TABLOLAR` kaydı (`sql_tablolar_kur.sql` / `GenDepoUpdate41.sql`).
FK `_USER.ID → kart.ID ON DELETE CASCADE` (`GenDepoUpdate40.sql`) → kart silinince `_USER` otomatik gider.

### Wizard entegrasyonu (kart-seviye `_USER`, demirbaş referans deseni)

- **Açılış (edit):** `LogUserAcilis('<T>_USER', kartID)` — baseline (pozisyonel snapshot).
- **İptal geri-al:** `OturumBaslatPlan([...])` dizisine `SnapTablo(1,'<T>_USER','ID='+kartID)`.
- **Finish:** `UserDataSourceKaydet` `_USER`'i post ettikten **SONRA**, `LogUstModu` set iken:
  `LogUserKaydet('<T>_USER', TabNo_<T>_USER, kartTabNo, kartID, yeniMi)` → yeni kart=tam EKLE,
  düzenleme=açılış↔son **alan diff**. Kart grubuna bağlanır (UInfo'da kartla tek satır).
- **Silme (kart delete'inden ÖNCE):** `LogDetaylariSil('<T>_USER','ID',TabNo_<T>_USER,kartTabNo,kartID)`.

> **KRİTİK:** `LogUserKaydet` MUTLAKA `UserDataSourceKaydet`'ten **sonra** çalışmalı (yoksa DB'de eski
> değeri okur, değişikliği kaçırır). Save ayrı metotta olan wizard'larda (Fatura `KaydetTusClick`→`LogKaydet`,
> Servis `Kaydet`) çağrı save'den sonra gelir; Rehber/IK'da **Destroy fallback'e değil finish'e** koy.

### ID'siz / bileşik anahtarlı detaylar (ör. `DEMIRBAS_TUTANAK_DETAY` = TUTANAKID+DEMIRBASID, ID yok)

- `LogDetaylariSil` `FindField('ID')` ile toleranslı → ID kolonu yoksa `KAYITID=0`, **çökmez**
  (eskiden `Field 'ID' not found` atıyordu).
- `GeriKayitVarMi` `COL_LENGTH(tablo,'ID')` ile ID yoksa `False` döner → `GeriKayitEkle` (dinamik INSERT,
  JSON kolonlarını yazar, IDENTITY sadece varsa) satırı geri ekler.
- **Master kayıt** (ID'li ama karta doğrudan kolonla bağlı DEĞİL): `LogKayitSil` — `WHERE ID=kayitID`
  ama grup `ustID`. Örnek: demirbaş silinince `DEMIRBAS_TUTANAK` master'ı (512, ID=tutanakID) demirbaş
  grubuna loglanır. Geri Al sırası: **kart → master → detay-link → `_USER`** (master detaydan ÖNCE
  loglandığı için log-ID sırası FK'yı korur).

### Delete-audit yayılımı ve KAPSAM

Kart-seviye `_USER`'in "Geri Al"da dirilmesi için **her silme yolunda** `LogDetaylariSil('<T>_USER',...)`
gerekir (FK cascade satırı siler → **log fiziksel DELETE'ten ÖNCE** yazılmalı).

**Sıralama kuralı (kritik):** `_USER` logu, parent tablosunun DELETE'inden önce çalışmalı. Kart-seviye
`_USER` (parent = kart, en son silinir) için log satırını kartın kendi `delete from <KART>`'ından hemen
öncesine koy → güvenli. **Satır-seviye** `_USER` (FATURA_USER→FATURA satırı gibi) parent satır ERKEN bir
döngüde siliniyorsa, loglama o silmeden önceye alınmalı (bkz. `TTablo.FaturaSil`: kart+satır+FATURA_USER
loglaması `delete from FATURA` döngüsünden önce; sıra **satır → satır-`_USER`** ki restore'da FK korunsun).
Kural bozulursa `_USER` DB sorgusu boş döner (cascade gitmiştir) → sessizce loglanmaz.

**Kapsanan (birincil, kullanıcı-yüzü silme yolları):** merkezi `Utablo` helper'ları
(Stok/Fatura[FATBASLIK+FATURA_USER]/Sipariş/ÜretimEmri, cari REHBER, ServisSil→SERVISHAREKET_USER,
FATBASLIK ikincil: tahakkuk/kasa/KASA-toplu) + liste-frame'ler (IK, Servis[+hareket], Teklif, Doküman)
+ demirbaş (liste + DEMIRBAS_TUTANAK master + wizard FormCloseQuery).

**KAPSAM DIŞI (bilerek):** ~25 **toplu/anahtar-bazlı** (REHBER by KOD, FATBASLIK günsonu/sayım/MODUL,
URETIMEMRI by URETIMPLANID, DOKUMAN by MODUL), **cascade/alt-silme** (UKasa2, banka-REHBER, UMekanMasaGor,
UTahakkukDlg) ve **ölü/kopya** (`UReharadlg.adnan/.my`) silme yolları. Bunlar nadir + ek alan olası değil +
toplu-grup semantiği audit modeline oturmuyor. **Yeni bir birincil silme yolu eklenince** `_USER` (ve
gerekiyorsa kart) log satırını unutma; sıralama kuralına dikkat et.

## Modül loglama kontrol listesi (yeni modül eklerken)

1. `TABLOLAR`'a TABLOID→ad (dev + GenDepoKur + sql_tablolar) + gerekiyorsa `LOGCOZUM` ID→ad.
2. Kart ekleme: `LogKartEkle` (FormClose/Destroy fallback, `FEkleLogland`).
3. Kart değiştirme: `LogKartDegisti`; Modified değilse Cancel.
4. Kart silme: `LogKartSil` (DELETE'ten önce).
5. Detay: `FDetSnap` + `LogSnapshotAl` (açılışta) + `LogDiffKaydet`+`LogSnapshotAl` (finish);
   veya grid-tanım deseninde `LogDetaySatirPost` (BeforeEdit'te OncekiLogBelirle, NewRecord'da Clear).
6. Grup tutarlılığı: metot başında `LogUstModu:=yeniMi?1:2`, FormClose'da `-1`.
7. `_USER` ek-alan tablosu varsa (bkz. §11): açılış `LogUserAcilis`, finish `LogUserKaydet` (UserDataSourceKaydet'ten SONRA), İptal için `SnapTablo('<T>_USER')`, silmede `LogDetaylariSil('<T>_USER',...)`. TABLOLAR'a `<T>_USER` TABLOID'i ekle.
8. Test: UInfo Liste'de tek satır mı, İçerik doğru ad/tip mi, Geri Al çalışıyor mu (kart + `_USER` + detaylar geri geliyor mu).
