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

## Modül loglama kontrol listesi (yeni modül eklerken)

1. `TABLOLAR`'a TABLOID→ad (dev + GenDepoKur + sql_tablolar) + gerekiyorsa `LOGCOZUM` ID→ad.
2. Kart ekleme: `LogKartEkle` (FormClose/Destroy fallback, `FEkleLogland`).
3. Kart değiştirme: `LogKartDegisti`; Modified değilse Cancel.
4. Kart silme: `LogKartSil` (DELETE'ten önce).
5. Detay: `FDetSnap` + `LogSnapshotAl` (açılışta) + `LogDiffKaydet`+`LogSnapshotAl` (finish);
   veya grid-tanım deseninde `LogDetaySatirPost` (BeforeEdit'te OncekiLogBelirle, NewRecord'da Clear).
6. Grup tutarlılığı: metot başında `LogUstModu:=yeniMi?1:2`, FormClose'da `-1`.
7. Test: UInfo Liste'de tek satır mı, İçerik doğru ad/tip mi, Geri Al çalışıyor mu.
