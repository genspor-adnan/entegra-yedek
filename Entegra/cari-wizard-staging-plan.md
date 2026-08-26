# Cari Wizard — Bellek-Staging Veri Katmanı (Referans Desen / POC)

## Context (neden)

Bugünkü cari wizard'ı (`URehberWizard.pas`) veriyi **anlık** yazıyor: adım adım
ilerlerken önce `REHBER` satırını INSERT edip identity ID'yi alıyor, çocuk tabloları
(`REHBERILETISIM`, `REHBERBILGI`, `REHBERADRES`, `REHBERTEMSILCI`, `IMAJ` …) doğrudan
`Veritabani.BasitKomutÇalıştır INSERT` ile yazıyor, kullanıcı **iptal** ederse
8 ayrı `DELETE` ile elle cascade geri alıyor (URehberWizard.pas ~2409-2417). Sakıncalar:
tek sarmalayıcı transaction yok, uygulama yarıda çökerse **yetim kayıt** kalır,
ID'yi baştan almak zorunlu, iptal mantığı kırılgan.

Kullanıcının önerisi doğru yönde: editörleri canlı tabloya değil **bir bellek
dataset'ine** bağlayıp yalnızca **Kaydet**'te tek transaction ile yazmak. Bu plan o
deseni, çoğaltılabilir küçük bir **referans/POC** olarak kurar (bir başlık + bir
detay). Onaylanınca aynı kalıp diğer cari alanlarına ve öbür kart/wizard'lara yayılır.

**Arayüz kararı:** POC formu, **`Ekranlar/cari_karti.html` mockup'ı kroki alınarak**
DevExpress-native, **sekmeli kart** (`cxPageControl`) olarak kurulur. Bu mockup zaten
DevExpress diliyle çizildiği için (~birebir taşınır) ve editörler `TDataSource` üzerinden
doğrudan `TFDMemTable`'a bağlandığı için staging deseni buraya kusursuz oturur — en az
kod. (Modern `cariwizard-modern.html` + WebView2 yolu ayrı/sonraki adım: görsellik kazancı
var ama JS↔Delphi köprüsü nedeniyle bağlama maliyeti yüksek.)

## Karar: hangi bellek bileşeni

**TdxMemData değil, `TFDMemTable` (FireDAC).** Gerekçe: FireDAC zaten sizin veri
kütüphaneniz; `TFDMemTable` şemayı bir sorgudan klonlayabilir (`CopyDataSet` / `.Data`),
nested detail destekler ve okuma tarafında `PgSqlCevir` akışıyla uyumludur. `TdxMemData`
salt bir DevExpress UI tamponudur, DB'ye yazma entegrasyonu yoktur. Kalıcılaştırmayı her
iki durumda da elle (Pascal) yapacağımız için tek veri kütüphanesinde kalmak sadeleştirir.

FireDAC'ın `CachedUpdates + ApplyUpdates` otomatik-anahtar geri alma yolu da mümkün ama
**motora bağımlıdır** (MSSQL `SCOPE_IDENTITY` vs PG `RETURNING`) ve satır-satır ISLEMLOG
loglamayı zorlaştırır — CLAUDE.md'nin "motor-ayrımlı mantığı Pascal'da tut" kuralına
aykırı. Bu yüzden **açık Pascal persister** tercih ediyoruz.

## POC kapsamı

Tek bir temsili dilim: **`REHBER` (başlık) + `REHBERILETISIM` (İlgili Kişiler, 1:N)** —
`cari_karti.html`'in **Genel** sekmesindeki "Kart Bilgileri" alanları + "İlgili Kişiler"
grid'i. Bu ikili mevcut wizard'da zaten kullanılıyor, gerçek kolonları biliniyor
(`REHBERILETISIM([REHBERID],[AD],[VARSAYILAN],[AKTIF],[SUBEID])` — URehberWizard.pas:1364).
Form sekmeli kart; kalıcılaştırma **toolbar'daki "💾 Kaydet"** ile tetiklenir.
Sadece "Kaydet'te yaz" (taslak/kurtarma yok).

## Tasarım

### 1) Bellek dataset'leri (staging)
- `MemRehber: TFDMemTable` — düzenlenen başlık alanlarının bir alt kümesi
  (ör. `GRUPID, KOD, UNVAN, VKN, DURUM`). Kart wizard'ı olduğu için tek satır.
- `MemIletisim: TFDMemTable` — detay (`AD, VARSAYILAN, AKTIF, SUBEID`). FK yok;
  bellekte "yeni cariye ait" olarak durur, gerçek `REHBERID` ancak Bitir'de atanır.
- Şema kurulumu: `select ... where 1=0` sorgusundan `CopyDataSet` ile klonla ya da
  `FieldDefs` ile açıkça tanımla; sonra `CreateDataSet`.

### 2) Bağlama (binding)
- Başlık editörleri (`cxDBTextEdit`/`cxDBComboBox` …) → `TDataSource` → `MemRehber`.
- İlgili Kişiler `cxGrid` → `TDataSource` → `MemIletisim`.
- Sekmeler (`cxPageControl`) yalnızca görünüm değiştirir; **DB'ye hiçbir yazma yok**.

### 3) Doğrulama
- "💾 Kaydet"e basıldığında, yazma öncesi zorunlu-alan kontrolü — bellek dataset'i
  üzerinden, error-handling.md'deki `if Field='' then ShowMessage; Exit` kalıbıyla.
  (İstenirse sekme değişiminde de hafif kontrol eklenebilir.)

### 4) Kalıcılaştırma — tek transaction (deseni taşıyan çekirdek)
Yeni yeniden-kullanılabilir birim: **`Ortak/UCariStagingKaydedici.pas`** — iki
memtable'ı alıp tek transaction'da yazan bir yordam. Kart formunun **"💾 Kaydet"**
buton `OnClick`'i (mockup toolbar'ı) bunu çağırır:

```pascal
Tablo.FDCnn.StartTransaction;
try
  // 1) BAŞLIK — INSERT + yeni identity'yi al (motor-ayrımı burada, tek yerde)
  LRehberID := YeniRehberEkle(MemRehber);        // içeride BasitKomutÇalıştır(...,True)
                                                 // MSSQL: 'INSERT ...; SELECT SCOPE_IDENTITY()'
                                                 // PG seam: 'INSERT ... RETURNING ID'
  // 2) DETAY — gerçek FK ile döngü
  MemIletisim.First;
  while not MemIletisim.Eof do begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'INSERT INTO REHBERILETISIM([REHBERID],[AD],[VARSAYILAN],[AKTIF],[SUBEID]) '+
      'VALUES(&R,&AD,&VS,&AK,&SB)',
      ['&R','&AD','&VS','&AK','&SB'],
      [LRehberID, MemIletisim.FieldByName('AD').AsString,
       MemIletisim.FieldByName('VARSAYILAN').AsInteger,
       MemIletisim.FieldByName('AKTIF').AsInteger, LSubeID]);
    MemIletisim.Next;
  end;
  // 3) EKLEME LOGU — Kaydet'te tek sefer (ISLEMLOG kuralı: FEkleLogland guard)
  //    ULog.OturumBaslatPlan('REHBER', LRehberID, [...SnapTablo...]) + ekleme logu
  Tablo.FDCnn.Commit;
except
  if Tablo.FDCnn.InTransaction then Tablo.FDCnn.Rollback;
  raise;   // üst katmana ilet (UHataDialog/AppException gösterir)
end;
```

- **Kapat/İptal** = formu kapat, memtable'ları at. DB'ye hiç dokunulmadığı için cascade-DELETE
  YOK, yetim kayıt YOK.
- **Identity**: yalnızca `YeniRehberEkle` içinde; motor-ayrımlı tek satır (dual-engine kuralı).
- **ISLEMLOG**: ekleme logu "Kaydet'te tek sefer" (URehberWizard.pas:2052,2066 ile aynı mantık,
  `FEkleLogland` guard); POC'ta minimum `ULog` çağrısı, tam snapshot planı yayılım aşamasına bırakılabilir.
- **Kısa transaction**: kullanıcı düşünme süresi transaction dışında → SQL Express kilit/`RESOURCE_SEMAPHORE`
  riski yok (CLAUDE.md notu).

## Dosyalar

Yeni:
- `Ortak/UCariStagingKaydedici.pas` — memtable→DB tek-transaction persister + `YeniRehberEkle`
  (identity seam). Asıl yeniden-kullanılabilir parça budur.
- `UCariStagingPoc.pas` / `.dfm` — `cari_karti.html` kroki alınan `cxPageControl` **kart**
  formu (Genel sekmesi: başlık alanları + İlgili Kişiler grid'i), memtable'lara bağlı,
  "💾 Kaydet"te persister'ı çağırır. Mevcut `URehberWizard`'a dokunmaz.

Yeniden kullanılan (değişmez):
- `Ortak/FetaKurulusSiniflari.pas` — `Veritabani.BasitKomutÇalıştır` (scalar için `,True`).
- `Utablo.pas` — `Tablo.FDCnn` bağlantı + `WizardTurkcelestir`.
- `Ortak/ULog.pas` — ekleme logu (`OturumBaslatPlan`, `FEkleLogland` deseni).
- `Ortak/UHataDialog.pas` — hata gösterimi (raise sonrası).

## Doğrulama (uçtan uca)

1. Derle: `rsvars.bat` + `msbuild Gentegre.dproj /t:Build /p:Config=Debug /p:Platform=Win32`
   (ya da IDE'de F9).
2. POC kart formunu aç, bir cari + 2 ilgili kişi gir, **💾 Kaydet**.
3. Kayıtları **`mssql-bilim` MCP** ile doğrula (yeni kurduğumuz): "BILIM'de REHBER'in son
   eklenen ID'sini ve o REHBERID'ye bağlı REHBERILETISIM satırlarını göster" → 1 başlık + 2 detay,
   FK doğru.
4. **İptal** senaryosu: yeni cari gir, kişiler ekle, Kaydet yerine kapat → REHBER/REHBERILETISIM'de
   **hiç** satır oluşmadığını MCP ile doğrula.
5. **Rollback** senaryosu: detay INSERT'ine kasıtlı hata enjekte et (ör. geçersiz kolon) → başlık
   dahil hiçbir şeyin yazılmadığını doğrula (atomiklik).
6. ISLEMLOG: Kaydet sonrası tek bir ekleme logu düştüğünü kontrol et.

## Yayılım (onay sonrası, bu POC'un dışında)

Desen çalışınca: (a) `cari_karti.html`'in diğer sekmelerini + detaylarını ekle
(`REHBERADRES`, `REHBERBANKA`, `REHBERBILGI`, Fatura/Mali/Ekstre sekmeleri), (b) **Düzenle**
modu için memtable'ları açılışta DB'den doldur + Kaydet'te diff/upsert (LogKartDegisti),
(c) aynı `UCariStagingKaydedici` kalıbını stok/teklif gibi master-detail ekranlara uyarla,
(d) `URehberWizard`'ın anlık-INSERT + cascade-delete mantığını bu desenle değiştir.
