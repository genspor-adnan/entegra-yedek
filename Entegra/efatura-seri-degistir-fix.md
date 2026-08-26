# Fix: e-Arşiv / e-İrsaliye "Seri Değiştir" yanlış seri getiriyor

## Kök neden
`TEBelgeOlusturucu.MenuSeriDegistir` (UEBelgeOlusturucu.pas ~3765), belge **hazırlanmadan
önce** (EFATURADURUM=0) seri seçtiriyor ve belge türünü o an `EFATURADURUM`'dan çıkarıyor:

```pascal
case LBaslik.EFaturaDurum of
  11, 12: LBelgeTuru := RAlias_EArsiv;
  51, 52: LBelgeTuru := RAlias_EIrsaliyeKendi;
else
  LBelgeTuru := RAlias_EFatura;   // durum 0 -> e-Arsiv de olsa e-Fatura sayiliyor
end;
...
if LFatNoYok then
  Result := MenuHazirla(AConnection, AFatBaslikID)   // <-- hazirlama EN SONDA
```

`EFATURADURUM` bir **durum**dur (0=henüz oluşmamış, 1=e-Fatura, 11=e-Arşiv…), tür değil.
Belge daha hazırlanmadığı için durum 0; e-Arşiv/e-İrsaliye taslakları `else` dalına düşüp
**e-Fatura serilerini** getiriyor. e-Fatura'da tesadüfen doğru çalışıyor (else zaten e-Fatura).

Diğer işlemler (Önizle/Gönder) bu hatayı yaşamıyor çünkü **önce hazırlıyorlar**: durum 0 ise
`MenuHazirla` çağırıp yeniden okuyorlar, sonra iş yapıyorlar (bkz. MenuOnizle, satır 3696-3703).
`MenuSeriDegistir` bu deseni izlemiyor — hazırlamayı en sona bıraktığı için tek bozuk olan bu.

## Çözüm
`MenuSeriDegistir`'i, Önizle/Gönder ile **aynı "önce hazırla" desenine** çevir. Hazırlamadan
sonra `EFATURADURUM` belge türünü doğru verir, mevcut `case` bloğu doğru seriyi getirir.
Alias/İzibiz mantığına dokunmaya gerek yok — `MenuHazirla` türü zaten doğru çözüyor.

### `MenuSeriDegistir` gövdesini aşağıdakiyle değiştir
(Var bloğundan `LFatNoYok: Boolean;` kaldırılır; başka değişken eklenmez.)

```pascal
begin
  Result := False;
  if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
    Exit;

  if not (LBaslik.Tur in [EBelgeTuruEIrsaliye, EBelgeTuruEFatura]) then begin
    ShowMessage('Bu islem yalnizca e-Fatura/e-Irsaliye belgeleri icin kullanilabilir.');
    Exit;
  end;
  if GonderilmisEngeli(LBaslik.EFaturaDurum) then
    Exit;

  // Henuz hazirlanmamissa ONCE hazirla (Onizle/Gonder ile ayni desen): tur/durum/seri
  // dogru atanir, sonra yeniden oku. Boylece seri secimi DOGRU belge turu uzerinden yapilir.
  if LBaslik.EFaturaDurum = 0 then begin
    if not MenuHazirla(AConnection, AFatBaslikID) then
      Exit;
    if not MenuBaslikOku(AConnection, AFatBaslikID, LBaslik) then
      Exit;
    if LBaslik.EFaturaDurum = 0 then
      Exit;
  end;

  LFatNo := Trim(LBaslik.FaturaNo);
  LYil := YearOf(LBaslik.FaturaTarih);

  // Artik EFATURADURUM belge turunu dogru veriyor.
  case LBaslik.EFaturaDurum of
    11, 12: LBelgeTuru := RAlias_EArsiv;
     1,  2: LBelgeTuru := RAlias_EFatura;
    51, 52: LBelgeTuru := RAlias_EIrsaliyeKendi;
  else
    LBelgeTuru := RAlias_EFatura;
  end;

  if Length(LFatNo) >= 3 then
    LMevcutSeri := Copy(LFatNo, 1, 3)
  else
    LMevcutSeri := Trim(LBaslik.FaturaSeri);

  if not SeriSecimi(AConnection, LBaslik.Tur, LBelgeTuru, LBaslik.Senaryo,
    StrToIntDef(Kullanan, 0), LMevcutSeri, LYeniSeri) then
    Exit;
  if not SonrakiSiraNo(LBaslik.ID, LBaslik.Tur, LYeniSeri, LYil, LSonrakiSeq) then
    Exit;

  LYeniNo := BelgeNoUret(LYeniSeri, LYil, LSonrakiSeq);

  Veritabani.BasitKomutÇalıştır(AConnection,
    'update FATBASLIK set FATURANO=&NO, FATURASERI=&SERI where ID=&ID',
    ['&NO', '&SERI', '&ID'], [LYeniNo, LYeniSeri, LBaslik.ID]);

  ShowMessage('Yeni Belge No: ' + LYeniNo);
  Result := True;
end;
```

## Değişikliğin özeti
1. Tür/Gönderilmiş kontrolleri en başa alındı.
2. **Durum 0 ise önce `MenuHazirla` + yeniden `MenuBaslikOku`** (Önizle/Gönder deseni).
3. Tür artık doğru durumdan okunuyor; `1,2 → e-Fatura` satırı da eklendi (netlik için).
4. Sondaki "`if LFatNoYok then MenuHazirla`" **kaldırıldı** (hazırlama artık başta) —
   `LFatNoYok` değişkeni de gereksizleşti.

## Neden bu doğru
- Çalışan Önizle/Gönder ile **aynı** akış; "seri değiştir" artık belgeyi hangi türle
  keseceğinle aynı serileri gösterir.
- e-Arşiv **ve** e-İrsaliye taslakları düzelir.
- Riski düşük: yeni tür-belirleme mantığı yok, mevcut ve çalışan `MenuHazirla` kullanılıyor.

## Doğrulama (mssql-bilim MCP + uygulama)
1. Derle (IDE F9 veya rsvars+msbuild).
2. e-Fatura mükellefi cari → taslak fatura → "Seri Değiştir": önce hazırlanır, sonra
   yalnız **e-Fatura** serileri arasında seçtirir.
3. e-Fatura mükellefi **olmayan** cari (e-Arşiv) → "Seri Değiştir": önce hazırlanır, sonra
   yalnız **e-Arşiv** serileri gelir. (Asıl düzelen senaryo.)
4. e-İrsaliye taslağı → yalnız e-İrsaliye serileri.
5. Zaten hazırlanmış (durum 11) e-Arşiv → tekrar hazırlamaz, doğrudan e-Arşiv serileri.
6. FATBASLIK.FATURANO/FATURASERI'nin doğru seriyle güncellendiğini MCP ile kontrol et.
