# e-Belge Akışı Teknik Doküman

Bu dosya `UFaturalar.MenuEFatura` ve `UOpsiyonFatura`’da yapılan e-Belge entegrasyonunun davranışını, hangi tabloları/sabitleri kullandığını, hangi REST endpoint’lerine gittiğini ve karar mantığını özetler. AI okuyabilir tablolu form.

## 1. Kodlama Şemaları (Sabitler)

### 1.1 `FATBASLIK.TUR` (uygulama belge tipi)
`UEBelgeAliasServis.pas` üstünde tanımlı:
```
EBelgeTuruEIrsaliye = 14
EBelgeTuruEFatura   = 15
EBelgeTuruEArsiv    = 16   // Sadece dahili enum; FATBASLIK’a yazılmaz
```
> Not: `TUR=15` hem e-Fatura hem e-Arşiv için. Ayrım `EFATURADURUM`’da.

### 1.2 `REHBERALIAS.BELGETURU` / `EBELGE.BELGETURU` (RAlias kodları)
```
RAlias_EIrsaliyeGIB   = 140   // GİB Portal alias (özel entegratörü yok)
RAlias_EIrsaliyeKendi = 141   // Özel entegratör alias’ı
RAlias_EArsiv         = 150   // Müşteri mail adresi
RAlias_EFatura        = 151   // GİB doğrulanmış URN
```
DB CHECK: `CK_REHBERALIAS_BELGETURU IN (140, 141, 150, 151)`.

### 1.3 `FATBASLIK.EFATURADURUM`
| Değer | Anlamı |
|---|---|
| 0 | Oluşmamış (yeni kayıt veya iptal sonrası) |
| 1 | e-Fatura oluştu, gönderilmedi |
| 2 | e-Fatura gönderildi |
| 11 | e-Arşiv oluştu, gönderilmedi |
| 12 | e-Arşiv gönderildi |
| 51 | e-İrsaliye oluştu, gönderilmedi |
| 52 | e-İrsaliye gönderildi |

Gelen (alış) tarafında EFATURADURUM **negatif**tir (gelen kutusu kategorisi); detay `EFATURASONUC`’ta:
| Değer | Anlamı |
|---|---|
| -1 | Gelen e-Fatura (gelen kutusu) |
| -11 | Gelen e-Arşiv |
| -2 / -12 | Sistemde (tasnif kategorisi) |
| -3 / -13 | Tasnif dışı |

### 1.3.1 `FATBASLIK.EFATURASONUC` — izibiz/GİB sonuç durumu
Kaynak: `UFaturalar.pas` (sekme filtreleri), `UEBelgeOlusturucu.pas`, `UEBelgeGelen.pas`.
| Değer | Anlamı | Nerede set edilir |
|---|---|---|
| 0 | Sonuç yok / yeni | `UEBelgeOlusturucu.pas:2467` (oluşturma sonrası) |
| 1 | İşlemde (InProcessing) — gönderim başladı | `:2793` |
| 2 | Kabul / Başarılı (Accepted) | `:3091` (`2+0`) |
| 3 | Red / Hata (Rejected) | `:2809, :3707` |
| 4 | İptal | giden sekme filtresi |
| 5 | Süresi Geçti | giden sekme filtresi |
| 6 | Yanıt Bekliyor (WaitingForResponse) | `:2906` |
| 9 | Gönderim / iletişim hatası (log) | `:3735` |
| 11 | Yanıt Gerekmez / Alındı | `UEBelgeGelen.pas:481,499` |
| 12 | Kanunen Kabul / Cevap Süresi Doldu | `UEBelgeGelen.pas:484,497` |

> 7 ve 8'in açık adı yok; yalnızca "Bekleyen" grubunda yer tutucu (`NULL,0,1,6,7,8,9`).

### 1.3.2 İzibiz inbox `statusCode` → eşleme (gelen, GİB uyumlu)
Kaynak: `UEBelgeGelen.pas:426-444` (`_IzibizStatusEsle`).
| statusCode | İzibiz/GİB | → EFATURADURUM / EFATURASONUC |
|---|---|---|
| 100 | New | -1 / 0 |
| 106 | WaitingForResponse | -1 / 6 |
| 107, 126 | Rejected | -1 / 3 |
| 108 | Accepted | -1 / 2 |
| 109 | ResponseTimeExpired (kanunen kabul) | -1 / 12 |
| 113 | Received | -1 / 0 |

Ayrıca durum **metni** (`responseStatus`, `documentStatus.label`, `status`…) `_IzibizStatusMetinEsle` (`UEBelgeGelen.pas:469-502`) ile eşlenir: Accepted→2, Rejected→3, WaitingForResponse→6, InProcessing→1, DeemedAccepted/ResponseTimeExpired→12, ResponseIsNotRequired/Received→11.

### 1.4 XSLT eşlemesi (`DOKUMLER.GRUBU='XSLT'`)
| RAPORID | Anlamı | GENINI Anahtarı | Global |
|---|---|---|---|
| 1 | e-Fatura | `Ops_FaturaOpsiyon_EFaturaXSLT` (-24076) | `VarsayilanEFaturaXSLT` |
| 2 | e-Arşiv | `Ops_FaturaOpsiyon_EArsivFaturaXSLT` (-24077) | `VarsayilanEArsivFaturaXSLT` |
| 3 | e-SMM | `Ops_FaturaOpsiyon_ESMMXSLT` (-24078) | `VarsayilanESMMXSLT` |
| 4 | e-İrsaliye | `Ops_FaturaOpsiyon_EIrsaliyeXSLT` (-24079) | `VarsayilanEIrsaliyeXSLT` |

## 2. `UFaturalar` Menüsü (`pmBelgeDonustur > eFatura1`)

### 2.1 Görünüm
`pmBelgeDonusturPopup` (IcerikFrame/UFaturalar.pas) — `FATBASLIK.TUR` değerine göre:
| TUR | `eFatura1.Visible` | `eFatura1.Caption` |
|---|---|---|
| 15 | True | `e-Fatura` |
| 14 | True | `e-İrsaliye` |
| Diğer | False | — |

### 2.2 Menü Öğeleri (`MenuOlustur`, `MenuOnizle`, `MenuGonder`, `MenuHTMLKaydet`, `MenuPDFKaydet`, `MenuIptalEt`)

#### MenuOlusturClick (UFaturalar.pas)
1. FATBASLIK aktif/dolu kontrol.
2. `FATURANO=0` ise yeni 16 karakterlik seri+yıl+9 hane no üretir (`FATBASLIK` updlock+holdlock altında, race-free).
3. Cariye ait mail adres(ler)i `REHBERBILGI INNER JOIN REHBERILETISIM` ile virgüllü listede.
4. `TEBelgeAliasServis.AliasIslemiYap(Connection, RehberID, FATBASLIK.TUR, VKN, CariAdi, RehberMail)` çağrılır.
5. Dönen `TAliasYonetimSonuc`:
   - `Basari=False` → "iptal" mesajı, çık.
   - `BelgeTuru` ∈ {140,141,150,151} → `Alias` saklanır, `Olustur` çağrılır.
6. `TEBelgeOlusturucu.Olustur(Cnn, FATBASLIK.ID, Alias, BelgeTuru)` → `LEBelgeID` döner.
7. `FATBASLIK.EFATURADURUM` güncellenir:
   | AliasSonuc.BelgeTuru | EFATURADURUM |
   |---|---|
   | 151 | 1 |
   | 150 | 11 |
   | 140 / 141 | 51 |

#### MenuIptalEtClick
- `EFATURADURUM ∈ [2,12,52]` → reddedilir ("gönderilmiş iptal edilemez").
- `EFATURADURUM = 0` → "henüz oluşmamış" uyarısı.
- `EFATURADURUM ∈ [1,11,51]`:
  1. `EBELGEHAREKET` ve `EBELGE` satırları silinir (`FATBASLIKID` üzerinden).
  2. `FATBASLIK SET EFATURADURUM=0, EFATURASONUC=0, FATURANO='0'` (yeniden numara alabilsin).
- Diğer durumlar → "Bilinmeyen eFatura durumu" mesajı.

#### MenuGonderClick → `TEBelgeOlusturucu.Gonder`
- `TEBelgeKimlik.Yukle` ile kimlik (TEST/ÜRETİM modu) cache’li okunur.
- Endpoint seçimi (`UEBelgeOlusturucu.pas`):
  | Durum | Endpoint |
  |---|---|
  | `LBaslik.Tur = 14` (e-İrsaliye) | `/v2/edespatches/send` |
  | `LBaslik.EArsivMi = True` | `/v1/earchives` |
  | Aksi (e-Fatura) | `/v1/einvoices` |
- Başarılı → `FATBASLIK.EFATURADURUM` SQL CASE ile 1→2, 11→12, 51→52.
- Başarısız → `EFATURASONUC=0`, hata `EBELGEHAREKET`’e MESAJTIPI=9 olarak log’lanır.

#### MenuOnizle / MenuHTMLKaydet / MenuPDFKaydet
- Tümü `VerileriOku` → `UBLXMLUret` → `XSLTOnizlemeUret(Tur, EArsivMi, UBLXML)`.
- XSLT seçimi:
  - `Tur=14` → `VarsayilanEIrsaliyeXSLT`
  - `EArsivMi=True` → `VarsayilanEArsivFaturaXSLT`
  - Aksi → `VarsayilanEFaturaXSLT`
- MSXML2.DOMDocument.6.0 ile transform.

## 3. `TEBelgeAliasServis.AliasIslemiYap` — Alias Karar Ağacı

İmza: `AliasIslemiYap(Cnn, RehberID, AFatBaslikTur, VKN, CariAdi, RehberMail)`

`AFatBaslikTur` parametresine göre çift kod seti:
| TUR | `LKodMukellef` | `LKodGenel` | `LIzibizFiltreTur` |
|---|---|---|---|
| 14 (İrsaliye) | 141 | 140 | 14 |
| 15 (Fatura) | 151 | 150 | 15 |

### Adımlar
1. **Mevcut aktif REHBERALIAS satırı** (filter `BELGETURU IN (LKodMukellef, LKodGenel) AND AKTIF=1`).
2. **`TEBelgeKimlik.Yukle`** — test/üretim modu okunur.
3. **Cache atlama**: TEST modunda Branch A devre dışı. ÜRETİM’de `LMevcutBelgeTuru = LKodMukellef AND SONKONTROL ≤ 30 gün` → `Branch A`: mevcut alias dönülür.
4. **TEST modu**: Modal dialog (Yes/No/Cancel):
   - Fatura: EVET=151 (mükellef varsay, alias=`urn:mail:defaultpk@izibiz.com.tr`), HAYIR=150 (e-Arşiv branch), CANCEL=iptal.
   - İrsaliye: EVET=141, HAYIR=140, CANCEL=iptal.
5. **ÜRETIM modu**: `SaglayiciOlustur` → Izibiz REST `/v1/aliases?vkn=...` → `LKayitlar` döner. `BelgeTuru = LIzibizFiltreTur` filtresi ile alias bulunur.
6. **Sonuç**:
   - `LIzibizAlias <> ''` → `RAliasUpsert(LKodMukellef, LIzibizAlias)` (varsa reactivate, yoksa eskiyi pasifle + INSERT).
   - `LIzibizAlias = ''` + İrsaliye → `RAliasUpsert(LKodGenel, LGIBAlias)`.
     - `LGIBAlias`: TEST → `urn:mail:defaultpk@izibiz.com.tr`, ÜRETİM → `Ops_FaturaOpsiyon_EIrsaliyeGIBAlias` (default `irsaliyepk@gib.gov.tr`).
   - `LIzibizAlias = ''` + Fatura → `MailOnayAl` modal → girilen mail → `RAliasUpsert(LKodGenel, mail)`.

### `RAliasUpsert` helper
Aynı `(RehberID, BelgeTuru, Alias)` triplet’i varsa → `AKTIF=1, VARSAYILAN=1, SONKONTROL=now`, diğer aynı türdeki VARSAYILAN’ları sıfırla. Yoksa → eski ID pasifle, varsayılanları sıfırla, INSERT.

### Çıktı: `TAliasYonetimSonuc`
```
Basari: Boolean
BelgeTuru: SmallInt   // 140/141/150/151
Alias: string
Mesaj: string
```

## 4. `UOpsiyonFatura` — Form Davranışı

### 4.1 E-Belge sekmesi (`TabSheet1`)
- `OnShow = TabSheetEBelgeShow` → `TabXSLT.Active = False` ise `TabXSLT.Open` (XSLT grid hazır gelir).

### 4.2 XSLT Grid (`GridXSLT`/`TabXSLT`)
- Dataset: `select * from DOKUMLER where GRUBU='XSLT'`.
- `TabXSLT.UpdateOptions.UpdateTableName = 'DOKUMLER'`.
- `TabXSLTNewRecord` default’ları: `GRUBU='XSLT'`, `VERSIYON='1.0'`, `EKLEYEN`, `EKLEMETARIHI`, `PRGVERSIYON=2000`, `SEKTOR='(0)'`, `DURUM=9`, `STANDART=False`.
- `TabXSLTBeforePost`: `RAPORADI` boş olamaz; `GRUBU='XSLT'`, `DEGISTIREN`, `DEGISTIRMETARIHI` set edilir.

### 4.3 `LabelXSLTYukleClick` — “Dosyadan XSLT Yükle”
1. `TOpenDialog` (filter `*.xslt;*.xsl`).
2. Dosya UTF-8 olarak `TStringList.LoadFromFile` (fallback: default encoding).
3. `TabXSLT.Append`, `RAPORADI = ChangeFileExt(ExtractFileName, '')`, `SQL = içerik`.
4. NewRecord default’ları otomatik.

### 4.4 Combo’ların doldurulması (`XSLTCombosYenile`)
```
ComboEFaturaXSLT       ← DOKUMLER where RAPORID=1
ComboEArsivFaturaXSLT  ← DOKUMLER where RAPORID=2
ComboESMMXSLT          ← DOKUMLER where RAPORID=3
ComboEIrsaliyeXSLT     ← DOKUMLER where RAPORID=4
```

### 4.5 FormShow okuma / KaydetTus yazma (`Tablo.GENINI`)
| Alan | Anahtar |
|---|---|
| `ComboEFaturaXSLT` | `Ops_FaturaOpsiyon_EFaturaXSLT` |
| `ComboEArsivFaturaXSLT` | `Ops_FaturaOpsiyon_EArsivFaturaXSLT` |
| `ComboESMMXSLT` | `Ops_FaturaOpsiyon_ESMMXSLT` |
| `ComboEIrsaliyeXSLT` | `Ops_FaturaOpsiyon_EIrsaliyeXSLT` |
| `CheckTestAktif` | `Ops_FaturaOpsiyon_EBelgeTestAktif` |
| `EditVergiNo` | `Ops_FaturaOpsiyon_EBelgeVergiNo` |
| `EditEnt_KullaniciTest` | `Ops_FaturaOpsiyon_EBelgeKullanici` |
| `EditEnt_SifreTest` | `Ops_FaturaOpsiyon_EBelgeSifre` |
| `CheckEArsivFaturaAktif` | `Ops_FaturaOpsiyon_EArsivFaturaAktif` |
| `CheckESMMAktif` | `Ops_FaturaOpsiyon_ESMMAktif` |
| `URLEFaturaTest` / `URLEArsivFaturaTest` / `URLEArsivUretim` / `URLESMMTest` / `URLESMMUretim` / `URLEIrsaliyeTest` / `URLEIrsaliyeUretim` | İlgili `Ops_FaturaOpsiyon_*URL` |
| **`EditEIrsaliyeGIBAlias`** | `Ops_FaturaOpsiyon_EIrsaliyeGIBAlias` (-24105), default `irsaliyepk@gib.gov.tr` |

## 5. `TEBelgeOlusturucu` — Olustur/Gonder

### 5.1 `TEBelgeBaslik` (kayıt)
- `Tur`: 14 / 15 (FATBASLIK.TUR’dan)
- `EFaturaDurum`: VerileriOku’dan FATBASLIK.EFATURADURUM
- `EArsivMi`: `EFaturaDurum IN [11,12]` (read-side) ya da `Olustur(...,150)` çağrısı (create-side)
- `EBelgeBelgeTuru`: 140/141/150/151 — EBELGE.BELGETURU değeri

### 5.2 `Olustur(Cnn, FatBaslikID, AliciAlias, ABelgeTuruOverride)`
- `ABelgeTuruOverride > 0` → `LBaslik.EBelgeBelgeTuru := override`, `LBaslik.EArsivMi := (override = RAlias_EArsiv)`.
- `LBaslik.Tur` DEĞİŞMEZ (15 kalır).
- `UBLXMLUret` ile UBL üretilir:
  | Tur / EArsivMi | Root | ProfileID | LineType |
  |---|---|---|---|
  | Tur=14 | DespatchAdvice | TEMELIRSALIYE | DespatchLine |
  | EArsivMi=True | Invoice | EARSIVFATURA | InvoiceLine |
  | Aksi | Invoice | TEMELFATURA | InvoiceLine |
- `EBelgeEkle` → `EBELGE.BELGETURU = LBaslik.EBelgeBelgeTuru` (140/141/150/151).

### 5.3 `Gonder(Cnn, FatBaslikID, User, Sifre, BaseURL, TestModu, AYanitMesaj)`
1. `VerileriOku` → `LBaslik` (EArsivMi EFATURADURUM’dan derive).
2. `TIzibizRest.Login` → session token (TEBelgeKimlik token cache, 25 dk TTL).
3. `_IzibizJSONOlustur` body üretir.
4. Endpoint seçimi (bkz. 2.2 MenuGonderClick).
5. `TIzibizRest.SendInvoice` → 2xx başarılı.
6. Başarı: `EBELGE.DURUM=2, UUID güncellenir`, `FATBASLIK.EFATURADURUM` CASE ile yükseltilir.
7. `EBELGEHAREKET`’e MESAJTIPI=1 (info), =2 (response), =3 (request body), =9 (hata) log’lar.

### 5.4 `_IzibizJSONOlustur` — Belge türüne göre body farkları

#### Ortak
- `documentAction=SEND`, `assignNumber` ("true"/"false" string), `seriePrefix=FATURANO[1..3]`.
- `content`: `profile`, `documentTypeCode`, `documentNo`, `uuid`, `issueDate`, `issueTime`, `currencyCode`, `notes=[]`.
- `supplierParty`: name, identifier, schemeId, taxOffice, address (country=TR, city, subCity, streetName, postalCode).
- TEST modunda supplier VKN, `Ops_FaturaOpsiyon_EBelgeVergiNo` ile override edilir.

#### e-Fatura
- `xsltName="DEFAULT"`
- `customerParty`: schemeId(VKN), identifier, name, taxOffice, address.
- `taxTotal`, `legalMonetaryTotal`
- Lines: `taxTotal` per satır

#### e-Arşiv (`EArsivMi`)
- `xsltName="DEFAULT"`
- `profile="EARSIVFATURA"`
- TCKN ise customerParty: schemeId="TCKN", identifier, **firstName**, **lastName** (cac:Person)
- VKN ise: name + taxOffice
- `customerParty.address.email = AliciAlias` (mail buradan iletilir)
- `additionalReferences`: `[{documentTypeCode:SendingType, documentType:ELEKTRONIK, id:"1", issueDate}]`
- `taxTotal`, `legalMonetaryTotal` var

#### e-İrsaliye (`Tur=14`)
- `xsltName` YOK. **`compressed:"false"`** eklenir (base64 parse hatası önler).
- `profile="TEMELIRSALIYE"`, `documentTypeCode="SEVK"`
- `customerParty`: schemeId açıktan; TCKN ise firstName/lastName, VKN ise name+taxOffice.
- `taxTotal` YOK, `legalMonetaryTotal` YOK
- `shipment`:
  - `id=1`
  - `goodsItems=[{currencyId, valueAmount=Matrah}]`
  - `shipmentStages=[{licensePlateID, driverPerson{firstName, familyName, identifier(TC), title, nationalityID="TR"}}]`
  - `delivery`:
    - `deliveryAddress`: country, city, subCity, streetName, **postalZone (zorunlu)**
    - `despatch`: actualDespatchDate, actualDespatchTime
- `additionalReferences=[{documentType:"XSLT", id:UUID, issueDate, attachment{characterSetCode:"UTF-8", encodingCode:"Base64", filename, mimeCode:"application/xml", content:base64(DOKUMLER.SQL)}}]`
  - XSLT içeriği `VarsayilanEIrsaliyeXSLT > 0` ise DOKUMLER’den okunup base64’lenir.
- Lines: `taxTotal` YOK; `currencyId` eklenir; itemName, itemPrice, quantity, unitCode, lineExtensionAmount.

> **TEST placeholder’lar**: `licensePlateID="34 TEST 0000"`, driver Test/Surucu/11111111111, `postalZone="34000"`. Üretim için FATBASLIK/REHBER alanlarından okuma gerekecek.

## 6. `UFaturaWizard` Etkileşimi

### 6.1 `FATBASLIKNewRecord`
- Mevcut akış sonunda `EFATURADURUM:=0` zorlanır (Olustur 1/11/51 set edene kadar).

### 6.2 `FATBASLIKBeforePost`
- `FATURANO='0'` → daha önce kullanılmış mı kontrolü atlanır (Olustur henüz no üretmedi).

## 7. SQL Şema Bağımlılıkları

### 7.1 REHBERALIAS
- CHECK: `BELGETURU IN (140,141,150,151)`
- UNIQUE `UQ_REHBERALIAS`: (REHBERID, BELGETURU, ALIAS)
- UNIQUE `UX_REHBERALIAS_VARSAYILAN`: (REHBERID, BELGETURU) where VARSAYILAN=1

### 7.2 `sp_Prog_EBelge_GidenFatura` (SP)
- `EBELGE` JOIN: `E.FATBASLIKID = FB.ID AND E.YON = 1 AND ((FB.TUR=14 AND E.BELGETURU IN (140,141)) OR (FB.TUR=15 AND E.BELGETURU IN (150,151)))`.
- `REHBERALIAS` JOIN aynı çeviri: FB.TUR=14 → 140/141, FB.TUR=15 → 150/151.

### 7.3 EBELGEHAREKET MESAJTIPI değerleri
- 1: bilgi
- 2: response (gönderim sonucu / login)
- 3: request body (debug)
- 9: hata

## 8. `TEBelgeKimlik` Cache

`UEBelgeKimlik.pas`:
- `Yukle(out User, Sifre, URL, TestModu)`: GENINI’den bir kez okur, cache’ler. Test/Üretim moduna göre `Ent_Kullanici/Ent_Sifre/Ent_Adres` veya `EBelgeKullanici/EBelgeSifre/EFaturaTestURL` set edilir.
- `Sifirla`: opsiyon kaydedildikten sonra çağrılır.
- `TokenSet(token, dk=25)` / `TokenAl`: 25 dk TTL’li session token cache (alias servisi + Gonder ortak).

## 9. UMailOnayDlg

- Modal: cariAdı + mevcutMail göster, virgülle ayrılmış mail girişi alır.
- Validation (`EmailGecerliMi`):
  - Trim boş değil, ≤254 char
  - Boşluk yok, tam 1 `@`, ardışık `.` yok
  - Regex: `^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$`
- Result `mrOk` → kullanıcıya geri.

## 10. Bilinen Eksikler / TODO

| Konu | Mevcut | Yapılacak |
|---|---|---|
| İrsaliye taşıma alanları | Hardcoded test placeholder | FATBASLIK’tan plaka, sürücü, posta kodu oku |
| İrsaliye carrierParty | Şu an yok | Üçüncü taraf nakliyeci durumu için |
| `supplierParty.physicalLocation` (depo) | Yok | İhtiyaç olursa eklenir |
| Üretim alias sorgu | Çalışıyor | Gerçek müşterilerle daha fazla test |
| ESMM akışı | Yok | İlerde eklenecek |

## 11. Dosya/Konum Referansı

| Dosya | Rol |
|---|---|
| `UEBelgeAliasServis.pas` | Alias karar ağacı, REHBERALIAS upsert, Izibiz alias sorgusu |
| `UEBelgeOlusturucu.pas` | UBL/JSON üretim, Olustur/Gonder/Onizle/HTML/PDF |
| `UEBelgeKimlik.pas` | Ortak kimlik + token cache |
| `UIzibizRest.pas` | THTTPClient wrapper: Login, SendInvoice |
| `UMailOnayDlg.pas/.dfm` | e-Arşiv mail onay dialog |
| `IcerikFrame/UFaturalar.pas` | MenuOlustur/Gonder/IptalEt/Onizle/HTML/PDF, eFatura1 menüsü |
| `UOpsiyonFatura.pas/.dfm` | XSLT yönetimi, GIB alias config, kimlik bilgileri |
| `UFaturaWizard.pas` | Belge oluşturma wizardı (EFATURADURUM=0 default, FATURANO=0 bypass) |
| `PrjConst.pas` | `Ops_FaturaOpsiyon_*` GENINI anahtarları |

## 12. Encoding Notu

Dosyalar Windows-1254 (cp1254) ile saklanır. `Edit` aracı bazı dosyalarda `BasitKomutÇalıştır` gibi Türkçe karakterli identifier’ları UTF-8/U+FFFD’ye bozar; build hatası alındığında python script ile cp1254’e geri çevrilir.
