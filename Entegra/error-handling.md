# Entegra - Hata Yonetimi Rehberi

## Genel Bakis

Uygulama, standart Delphi exception mekanizmasi uzerine kurulu bir hata yonetim yapisi kullanir. Ozel exception siniflari tanimlanmamis olup, genel `Exception` sinifi ile hata yakalama yapilir. Kullaniciya yonelik hata gosterimi icin hem standart VCL dialoglari hem de ozel hata dialog bilesenleri kullanilir.

---

## Exception Yakalama Kaliplari

### Standart Try/Except
```pascal
try
  // Islem
except
  on E: Exception do
  begin
    ShowMessage(E.Message);
  end;
end;
```

### Transaction ile Birlikte
```pascal
Connection.StartTransaction;
try
  Query.ExecSQL;
  Connection.Commit;
except
  if Connection.InTransaction then
    Connection.Rollback;
  raise;  // Hatayi ust katmana ilet
end;
```

### Kaynak Temizligi (Finally)
```pascal
tmp := SorguBaslat(cnn, ASQL, AParams, AParamValues);
try
  tmp.Open;
  Result := not tmp.IsEmpty;
finally
  tmp.Free;
end;
```

---

## Hata Dialog Turleri

### Ozel Hata Dialogu (UHataDialog)

**Dosya:** `Ortak/UHataDialog.pas`

**Kullanim:**
```pascal
ShowErrorDialog(description, causes, resolution, errortype);
```

**Dialog Turleri:**

| errortype | Renk | Kullanim |
|-----------|------|----------|
| `'imageOk'` | Yesil | Basarili islem bildirimi |
| `'imageInformation'` | Gumus | Bilgilendirme mesaji |
| Diger (varsayilan) | Kirmizi | Hata bildirimi |

**Ozellikler:**
- Genisletilebilir detay alani (SetExpanded)
- Uc alanli gosterim: Aciklama, Nedenler, Cozum
- Modal form tabanlı dialog

### Standart VCL Dialoglari

```pascal
// Mesaj kutusu (Evet/Hayir secimi)
Application.MessageBox(PChar(Mesaj), PChar(Baslik), MB_YESNO)

// Bilgilendirme dialogu
MessageDlg('Mesaj', mtError, [mbOK], 0);

// Basit mesaj
ShowMessage('Hata olustu');
```

---

## Veritabani Hata Yonetimi

### Transaction Yonetimi

**Standart Akis:**
```
StartTransaction → IslemYap → Commit
                          ↓ (hata)
              InTransaction kontrol → Rollback → raise
```

**Ornek (Ortak/UCombo.pas):**
```pascal
tmpTable.Connection.StartTransaction;
try
  tmpTable.ExecSQL;
  tmpTable.Connection.Commit;
except
  if tmpTable.Connection.InTransaction then
    tmpTable.Connection.Rollback;
  raise;
end;
```

**Onemli:** Rollback oncesi `InTransaction` kontrolu yapilir, boylece zaten geri alinmis bir transaction uzerinde tekrar rollback cagirilmaz.

### Veritabani Dogrulama Yardimcilari

**Dosya:** `Ortak/FetaKurulusSiniflari.pas`

| Fonksiyon | Aciklama |
|-----------|----------|
| `Veritabani.VeriVarMi()` | Kayit var mi kontrolu (Boolean doner) |
| `Veritabani.BasitKomutCalistir()` | Parametreli SQL calistirma |
| `Veritabani.SorguBaslat()` | Parametreli sorgu baslatma |
| `Veritabani.KayitSayisi()` | Kayit sayisi dondurme |
| `Veritabani.TabloKayitSayisi()` | Tablo kayit sayisi |

**VeriVarMi Kullanim Ornegi:**
```pascal
if Veritabani.VeriVarMi(Tablo.FDCnn,
  'SELECT * FROM FATURA WHERE ID=:ID', ['ID'], [FaturaID]) then
begin
  // Kayit mevcut, isleme devam et
end;
```

---

## Global Hata Yakalama

### Application.OnException

**Dosya:** `Ortak/UKimlik.pas`

```pascal
procedure TKimlikDlg.AppException(Sender: TObject; E: Exception);
begin
  if pos('Key violation', E.Message) > 0 then
    ShowMessage('Tekrarlayan kayit hatasi!')
  else if pos('not a valid date', E.Message) > 0 then
    // Tarih format hatasi
  else
    ShowMessage(E.Message);
end;
```

**Isleyis:**
- `FormCreate` icinde `Application.OnException` atanir
- Yakalanmamis tum hatalar buraya duser
- Hata mesajina gore ozel islem yapilir
- Bilinmeyen hatalar dogrudan kullaniciya gosterilir

---

## Girdi Dogrulama Kaliplari

### Islem Oncesi Kontroller
```pascal
// Bos alan kontrolu
if TabFatbaslik.FieldByName('BASLIK').AsString = '' then begin
  ShowMessage('Baslik bos olamaz!');
  Exit;
end;

// Kayit varlik kontrolu
if Veritabani.VeriVarMi(Tablo.FDCnn, 'SELECT * FROM ...', [], []) then begin
  ShowMessage('Bu kayit zaten mevcut!');
  Exit;
end;

// Dataset bos kontrolu
if DataSet.IsEmpty then begin
  ShowMessage('Listelenecek kayit bulunamadi.');
  Exit;
end;
```

### Dogrulama Noktalari
- Alan varlik kontrolleri (bos/null)
- Tekrarlayan kayit tespiti (`VeriVarMi`)
- Iliski butunlugu (foreign key)
- Tarih format dogrulamasi
- String format dogrulamasi

---

## Sessiz Hata Yonetimi

Bazi kritik olmayan islemlerde hatalar sessizce yutulur:

```pascal
try
  Connection.ExecSQL('SET NOCOUNT ON');
except
  // Oturum seviyesi ayar — hata yok sayilir
end;
```

**Sessiz hata kullanilan alanlar:**
- Yazici ayarlari
- UI render islemleri
- Oturum/baglanti parametreleri
- Opsiyonel servis cagrilari

**Uyari:** Bu kalip sadece kritik olmayan islemlerde kullanilmalidir. Is mantigi iceren kodlarda hatalar mutlaka yakalanip islenmeli veya ust katmana iletilmelidir.

---

## SQL Parametre Guvenligi

### Parametreli Sorgular (Guvenli)
```pascal
tmpTable.SQL.Text := 'SELECT * FROM REHBER WHERE ID = :ID';
tmpTable.ParamByName('ID').AsInteger := RehberID;
tmpTable.Open;
```

### String Birlestirme (Dikkatli Kullanim)
```pascal
// Kodda her iki yontem de mevcut
SQL.Text := 'SELECT * FROM KASA WHERE FATURAID=' + IntToStr(ID);
```

**Oneri:** Yeni gelistirmelerde parametreli sorgular tercih edilmelidir.

---

## Hata Kurtarma Mekanizmalari

### Kullanici Girdi Tekrari
```pascal
repeat
  // Kullanicidan girdi al
until VarToStr(Deger) <> '';
```

### Varsayilan Deger Atama
```pascal
// Null/bos deger icin varsayilan
VarToStrDef(Deger, '');
ISNULL(Alan, 0)  // SQL tarafinda
```

### Islem Iptali
- Basarisiz islemler dogrudan iptal edilir (rollback)
- Otomatik yeniden deneme mekanizmasi yoktur
- Kurtarma icin kullanici etkilesimi gerekir

---

## Anahtar Dosyalar

| Dosya | Sorumluluk |
|-------|------------|
| `Ortak/UHataDialog.pas` | Ozel hata dialogu (3 tip: basari, bilgi, hata) |
| `Ortak/Umesaj.pas` | Girdi dialoglari ve mesaj kutulari |
| `Ortak/FetaKurulusSiniflari.pas` | Veritabani yardimci fonksiyonlari (VeriVarMi, BasitKomutCalistir) |
| `Ortak/UCombo.pas` | INI/ayar yonetimi, transaction ornekleri |
| `Ortak/UKimlik.pas` | Application.OnException global handler |
| `Utablo.pas` | Merkezi veri modulu (22+ except blogu) |
| `UFaturaWizard.pas` | Is mantigi dogrulama ornekleri |

---

## En Iyi Uygulamalar Ozeti

1. **Transaction:** Her zaman `StartTransaction` → `try` → `Commit` / `except` → `Rollback` → `raise` sirasiyla kullanin
2. **InTransaction:** Rollback oncesi mutlaka `InTransaction` kontrolu yapin
3. **Finally:** Olusturulan nesneleri `finally` blogu icinde serbest birakin
4. **raise:** Transaction rollback sonrasi `raise` ile hatayi ust katmana iletin
5. **VeriVarMi:** Islem oncesi kayit varlik kontrolu icin kullanin
6. **Parametreli Sorgu:** SQL injection onlemek icin parametreli sorgulari tercih edin
7. **Sessiz Hata:** Sadece kritik olmayan islemlerde bos except blogu kullanin
8. **Global Handler:** Yakalanmamis hatalar `Application.OnException` ile yonetilir
