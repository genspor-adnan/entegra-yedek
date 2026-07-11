# Belge / Medya Depolama Sistemi (DOSYA / FILESTREAM)

> Gentegre'de tüm belge, resim ve medya içeriğinin nasıl saklandığı ve okunduğu.
> Eski (IMAJ.BELGE + klasör) yapıdan yeni (GENDEPO.DOSYA / FILESTREAM + hash-dedup)
> yapıya geçişi anlatır. 2026-07 itibarıyla.

---

## 1. Kavramsal model

Belge/medya **üç katmanlı**:

```
İş kaydı            IMAJ                          İçerik
(DOKUMAN,           (evrensel ek/metadata         (asıl byte'lar)
 STOKLAR,     --->   tablosu; YERI + YER_ID  --->  ESKİ: IMAJ.BELGE / klasör .OBJ
 REHBER,            ile hangi kayda ait,          YENİ: GENDEPO.DOSYA (FILESTREAM)
 GOREVYORUM...)     VARSAYILAN, sürüm, onay...)
```

- **İş kayıtları** (DOKUMAN, STOKLAR, REHBER, PROJELER, GOREVYORUM, MEKAN...) içeriğin
  kendisini **tutmaz**; sadece IMAJ üzerinden ilişkilenir.
  - `DOKUMAN` = doküman kartı (ad, klasör, tür, sürüm, tarih...) — **blob YOK**, içeriği IMAJ'da (YERI=1).
  - `GOREVYORUM` = yorum/mesaj metni (`YORUM` nvarchar) — **blob YOK**; ekli medya (ATAC bit) IMAJ'da.
- **IMAJ** = evrensel ek tablosu. Bir satır = bir ek. `YERI` (bağlam) + `YER_ID` (kaydın ID'si)
  ile hangi kayda ait olduğu belli olur.
- **İçerik** (asıl byte'lar) = eskiden IMAJ.BELGE veya diskte `.OBJ`, **yeni** DOSYA tablosunda.

### IMAJ.YERI (bağlam kodları — hangi modül)

| YERI | Nereye ait |
|------|------------|
| 1 | Doküman (DOKUMAN.ID) |
| 11 | İK / personel |
| 12 | Cari (REHBER iletişim) |
| 13 | Profil resmi |
| 41 | Proje |
| 71 / 72 / 88 | Stok / rehber resmi |
| 121 | Mekân / masa zemini |
| (yorum tabno) | GOREVYORUM'a ekli medya |

IMAJ **tek evrensel tablo** olduğu için, IMAJ'ı çözmek tüm modülleri (doküman, stok resmi,
İK, cari, proje, yorum medyası...) **aynı anda** kapsar.

---

## 2. ESKİ sistem (IMAJ.BELGE + klasör .OBJ)

### Depolama: iki mod

`IMAJ` satırının `ICDIS` (bit) alanı içeriğin nerede olduğunu söyler:

- **ICDIS = 0 → Veritabanı içi:** içerik doğrudan `IMAJ.BELGE` (varbinary(max)) kolonunda.
- **ICDIS = 1 → Diskte klasör:** içerik harici `.OBJ` dosyası olarak diskte; `IMAJ.BELGE` boş.
  - Yol: `<GENINI BOLUM=-10006 dizini>\<yyyy>-<mm>\<6 haneli ID>.OBJ`
    (ör. `C:\Gentegre\DOKUMAN\2021-09\001018.OBJ`)
  - Okuma: `sp_Imaj_Okuma <ID>` → `OPENROWSET(BULK ..., SINGLE_BLOB)` ile diskten okur.
  - Yazma: `sp_Imaj_Kaydetme` / `fn_Imaj_KayitliObjNesnesiniOku`.

Mod, Opsiyon > Doküman'daki `Dokuman_Kayit_Yeri` (0=VT, 1=Klasör) ile seçilir.

### Sıkıştırma (KRİTİK fark)

- **Dokümanlar ZLib ile SIKIŞTIRILIR** (`KutugeYaz` sıkıştırır, `KutuktenOku` açar).
- **Resimler HAM** saklanır (JPEG, sıkıştırma yok).

### Okuma/yazma fonksiyonları (eski)

| İşlem | Fonksiyon | Ne yapardı |
|-------|-----------|------------|
| Doküman aç | `Utablo.DokumanBelgeyiAc` | ICDIS'e bakıp sp_Imaj_Okuma **veya** IMAJ.BELGE → `KutuktenOku` (decompress) → temp dosya → ShellExecute |
| Doküman yaz | `UBinarySave.KutugeYaz` | Dosyayı ZLib sıkıştır → IMAJ.BELGE'ye (veya klasöre .OBJ) |
| Resim getir | `UResim.ResimGetir` | IMAJ.BELGE → TJpegImage |
| Resim yönetimi | `UResim.TResimDlg` (grid `TabResim = select * from IMAJ`) | BeforeOpen: klasördeki .OBJ'yi BELGE'ye çeker; AfterScroll: BELGE'yi gösterir |
| Resim kaydet | `UResim.ImajTablosunaResimKaydet` | JPEG → IMAJ.BELGE; küçük thumbnail → STOKLAR/REHBER.RESIM |
| Silme | `DokumanSil` + modül cascade'leri | `delete from IMAJ where YERI=.. and YER_ID=..` (blob satırla gider) |

### Eski sistemin sorunları

- **SQL Express 10 GB limiti:** IMAJ.BELGE veri dosyasında → blob'lar 10 GB'a sayılır, dolar.
- **Tekilleştirme yok:** aynı dosya 10 kayda eklenirse 10 kez saklanır.
- **Klasör modu kırılgan:** OS yolu + OPENROWSET yetkisi + dosya kaybı riski (~42 GB, 12.764 dosya).
- **Yedek şişer:** blob'lar ana DB'de → yedekler devasa.

---

## 3. YENİ sistem (GENDEPO.DOSYA / FILESTREAM + hash-dedup)

### Yeni içerik deposu: `GENDEPO.dbo.DOSYA`

| Kolon | Tip | Açıklama |
|-------|-----|----------|
| ID | bigint identity | Anahtar (IMAJ.DOSYAID buna işaret eder) |
| DOSYAGUID | uniqueidentifier ROWGUIDCOL | FILESTREAM zorunlu |
| HASH | binary(32) UNIQUE | İçeriğin SHA-256'sı (tekilleştirme anahtarı) |
| BOYUT | bigint | Byte |
| UZANTI / MIMETYPE | nvarchar | `.pdf`, `application/pdf`... |
| **ICERIK** | **varbinary(max) FILESTREAM** | Asıl byte'lar (diskte container'da) |
| REFSAYAC | int | Kaç IMAJ satırı bu içeriği kullanıyor (refcount) |
| EKLEME | datetime2 | |

**İki kilit özellik:**
1. **FILESTREAM** → içerik byte'ları `<db klasörü>\<depo>_FS` dizininde dosya olarak durur,
   **SQL Express 10 GB limitine SAYILMAZ.** (Bu, 10 GB engelini aşmanın yolu.)
2. **Hash-dedup** → aynı içerik (aynı SHA-256) **tek** DOSYA satırı; `REFSAYAC` ile sayılır.
   İçerik **HAM** saklanır (PDF zaten sıkışık; dedup daha çok kazandırır).

### IMAJ artık sadece referans

- **IMAJ tablosu KALDI** (ilişki + metadata katmanı: YERI/YER_ID, VARSAYILAN, sürüm, onay,
  belge adı, tarih...). Blob'u artık **tutmaz**.
- Yeni kolon **`IMAJ.DOSYAID → DOSYA.ID`**.
- `IMAJ.BELGE` işlevsizleşti — geçişte **yedek** olarak duruyor (ileride `BELGE_KOPYA`'ya
  rename edilip, kullanılmadığı doğrulanınca düşürülecek).

### Neden IMAJ kaldırılmadı?

DOSYA dedup'lı (tek içerik → tek satır). Ama "bu içerik hangi kayda ait, varsayılan mı,
hangi sürüm, kim onayladı" gibi **kullanım-başı** bilgi kayda özeldir; dedup'lı DOSYA'da
tutulamaz (aynı JPEG 2 stokta = 1 DOSYA + 2 IMAJ). Klasik: **junction/metadata (IMAJ)
+ tekilleştirilmiş içerik (DOSYA).**

### Yardımcılar (`Ortak/ULog.pas`)

| Fonksiyon | İş |
|-----------|-----|
| `DosyaKaydet(stream, uzanti, mime): Int64` | SHA-256 → varsa REFSAYAC++ ve mevcut ID (dedup), yoksa yeni satır. DOSYA.ID döner |
| `DosyaGetir(id, dest): Boolean` | ICERIK → stream |
| `DosyaReferansAzalt(id)` | REFSAYAC-- ; 0'a inince satır + FILESTREAM dosyası silinir |
| `DosyaIleImajGuncelle(imajId, dosya, degistiren)` | Düzenle: yeni içeriği DOSYA'ya yaz, IMAJ.DOSYAID'yi güncelle, eski referansı azalt |
| `DepoTablo('DOSYA')` | `[depo].dbo.DOSYA` tam adını çözer |

### Okuma — "DOSYAID önce"

Görüntüleme yolları önce DOSYAID'ye bakar, yoksa eski davranışa düşer (geçiş uyumu):

- `Utablo.DokumanBelgeyiAc`: `DOSYAID>0` → DOSYA.ICERIK; değilse eski ICDIS/BELGE.
  `UBinarySave.KutuktenOku` artık **zlib header'ı kontrol eder** → sıkışıksa (eski doküman)
  decompress, ham ise (DOSYA/resim) doğrudan kopya. (Eskiden ham içerikte decompress hatası verirdi.)
- `UResim.ResimGetir` + `TResimDlg` (`TabResimAfterScroll`, `ResmiVarsayilanyap`):
  `DOSYAID>0` → `DosyaGetir`. `TabResimBeforeOpen` DOSYAID'li satırları klasör-yüklemeden hariç tutar.

### Yazma — hep DOSYA'ya

- **Yeni doküman:** `KutugeYaz`, `INSERT ... IMAJ ... :PBELGE` desenini tanır → ham dosyayı
  DOSYA'ya (dedup) yazar; IMAJ'a DOSYAID konur (BELGE null, ICDIS=0). Non-IMAJ blob'lar dokunulmaz.
- **Yeni resim:** `ImajTablosunaResimKaydet` → JPEG'i `DosyaKaydet` → IMAJ (DOSYAID ile).
- **Düzenle (Üstüne Kaydet):** `DosyaIleImajGuncelle` (mod'dan bağımsız — ekleme de DOSYA'ya gittiği için).

### Silme — IMAJ DELETE trigger'ı

`TG_IMAJ_DosyaRefAzalt` (IMAJ AFTER DELETE):
- Silinen satırların DOSYAID'lerine göre `DOSYA.REFSAYAC`'ı azaltır (set-bazlı, COUNT kadar).
- REFSAYAC 0'a inince içeriği siler (FILESTREAM dosyası GC ile gider).
- **Dedup-güvenli:** paylaşılan içerik başka referans varken silinmez; sadece **son** referans gidince boşalır.
- **Hangi yoldan silinirse silinsin** çalışır (DokumanSil, kart-silme cascade `delete from IMAJ`,
  resim grid delete) → kod tek tek değiştirilmedi, trigger merkezi hallediyor.

### Migrasyon (`UDosyaMigrasyon`)

Opsiyon > Doküman > "Belgeleri DOSYA deposuna taşı" butonu. Mevcut IMAJ içeriğini DOSYA'ya taşır:

1. İçeriği oku: ICDIS ise klasör `.OBJ` (`sp_Imaj_Okuma`; **önce `FileExists`** — yoksa atla+logla),
   boşsa IMAJ.BELGE fallback.
2. `HamIcerikYaz` (sıkışık doküman → decompress; ham resim → kopya).
3. `DosyaKaydet` (hash-dedup) → `update IMAJ set DOSYAID, BOYUT`.
4. **BELGE ve ICDIS'e DOKUNMAZ** (yedek kalır); harici `.OBJ` **diskte kalır**.
   → Geri alma = tek satır `DOSYAID=NULL` (tam reversible).

Batch + resume (DOSYAID dolu satır atlanır), kayıp-dosya raporu.

---

## 4. Eski ↔ Yeni karşılaştırma

| Konu | ESKİ | YENİ |
|------|------|------|
| İçerik yeri | IMAJ.BELGE (VT) veya diskte .OBJ | GENDEPO.DOSYA.ICERIK (FILESTREAM) |
| 10 GB limiti | Sayılır (dolar) | **Sayılmaz** |
| Tekilleştirme | Yok | **SHA-256 hash-dedup** (REFSAYAC) |
| Sıkıştırma | Doküman ZLib / resim ham | Hep ham (dedup kazandırır) |
| IMAJ rolü | Metadata + blob | Sadece metadata + **DOSYAID** referans |
| Silme | delete IMAJ → blob gider | trigger: refcount--, 0'da içerik gider (paylaşımı korur) |
| Klasör/OS | Gerekli (klasör modu) | Gerekmez (FILESTREAM SQL'in içinde) |

---

## 5. Dağıtım / kurulum

- **`GenDepoUpdate3.sql`** (müşteri): FILESTREAM SQL seviyesi (`sp_configure`), `@depo`'da FILESTREAM
  filegroup + DOSYA tablosu + ana DB synonym, IMAJ.DOSYAID kolonu, IMAJ DELETE trigger'ı.
  - **Ön koşul:** FILESTREAM'in **Windows/Config Manager** tarafı + servis restart her müşteride
    **elle** açılmalı (script SQL tarafını açar, OS tarafını açamaz). Kapalıysa DOSYA atlanır (uyarır).
- **Depo Kopyala** (`UOPSDLG`): backup/restore + `sys.tables` boşaltma jenerik; FILESTREAM için
  RESTORE MOVE'da Type='S' → dizin yolu (`<depo>_FS`).

---

## 6. Geçiş durumu (2026-07)

- ✅ DOSYA tablosu + FILESTREAM + dedup + refcount trigger
- ✅ Yeni resim/doküman kaydı → DOSYA; düzenle → DOSYA; görüntüleme DOSYAID-önce
- ✅ Migrasyon aracı (BELGE'ye dokunmaz, reversible)
- ✅ Depo Kopyala FILESTREAM uyumu
- ⏳ Tam migrasyon sonrası: `IMAJ.BELGE → BELGE_KOPYA` rename (kullanılmadığını doğrula) → düşür
- ⏳ İsteğe bağlı: migrasyon sonrası eski `.OBJ` dosyalarını temizleme adımı
