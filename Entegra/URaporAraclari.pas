unit URaporAraclari;

interface
uses
//  SysUtils,Windows,Classes,Messages,Dialogs, UTablo, DB,
//  FireDAC.Comp.Client, FetaClassExtensions, Menus, UMultiCastEvent, UCombo ; URaporSart,

SysUtils,Windows,Classes,Messages,Dialogs,DB,Graphics,Printers,Variants,
FireDAC.Comp.Client, FetaClassExtensions, frxClass, frxDesgn, frxFDComponents, frxDBSet,
 ECXMLParser, Generics.Collections, frxCross, frxBarcode,
frxOLE, frxDMPClass, frxDCtrl, frxGradient, frxChBox, frxRich, frxChart, Menus, UTablo, UCombo;


type
  TRaporAraclari = class(TObject)
  private
    class var FModul : string;
    class var FIni : TIni;

  public

    {$REGION 'Döküm ve Rapor İşlemleri'}
    class procedure DokumKopyala(AKaynakDokumAdi,AHedefDokumAdi : string; AHedefTablo: TDataSet);
    class procedure RaporKopyala(EskiDokId : Integer; AHedefRaporAdi : string);
    class procedure RaporAdDegistir(AEkranAdi, AEskiRaporAdi,AYeniRaporAdi: string);
    class procedure RaporSil(DokumId : Integer);
    class procedure RaporVarsayilanYap(AEkranAdi, ARaporAdi: string);
    class procedure Tasi(ATablo,ADegisecekAlan,EskiDegeri,YeniDegeri: string;AHedefTablo : TDataSet);
    class function DokumVarMi(ARaporAdi : string): Boolean;
    class function RaporVarMi(AEkranAdi, ARaporAdi : string): Boolean;
    class procedure YeniRapor(AEkranAdi, ARaporAdi : string);
    {$ENDREGION}

    class procedure RaporPopupMenuHazirla(AEkranAdi: string;APopup: TPopupMenu;
      var ASeciliRapor: string;ASecOlayi : TNotifyEvent);

    {$REGION 'Sabit Özellikler'}
    class property Modul : string read FModul write FModul;
    class property Ini : TIni read FIni write FIni;
    {$ENDREGION}

  end;


implementation

uses FetaClassExtensionsConsts;

function SqlWithParams(const ASQL: string; const AParamNames: array of string;
  const AParamValues: array of Variant): string;
var
  i: Integer;
  V: Variant;
  S: string;
begin
  Result := ASQL;
  for i := Low(AParamNames) to High(AParamNames) do
  begin
    if i > High(AParamValues) then
      Break;
    V := AParamValues[i];
    if VarIsNull(V) then
      S := 'NULL'
    else if VarIsStr(V) then
      S := QuotedStr(VarToStr(V))
    else if VarIsNumeric(V) then
      S := StringReplace(VarToStr(V), ',', '.', [rfReplaceAll])
    else if VarType(V) = varDate then
      S := QuotedStr(FormatDateTime('yyyymmdd hh:nn:ss', V))
    else
      S := QuotedStr(VarToStr(V));
    Result := StringReplace(Result, AParamNames[i], S, [rfReplaceAll]);
  end;
end;

function NewFDQuery(const ASQL: string; const AParamNames: array of string;
  const AParamValues: array of Variant): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Tablo.FDCnn;
  Result.SQL.Text := SqlWithParams(ASQL, AParamNames, AParamValues);
end;

procedure ExecFD(const ASQL: string; const AParamNames: array of string;
  const AParamValues: array of Variant);
begin
  with NewFDQuery(ASQL, AParamNames, AParamValues) do
  try
    ExecSQL;
  finally
    Free;
  end;
end;

function ExistsFD(const ASQL: string; const AParamNames: array of string;
  const AParamValues: array of Variant): Boolean;
begin
  with NewFDQuery(ASQL, AParamNames, AParamValues) do
  try
    Open;
    Result := not IsEmpty;
  finally
    Free;
  end;
end;
{ TYazdirmaYoneticisi }

class procedure TRaporAraclari.DokumKopyala(AKaynakDokumAdi,
  AHedefDokumAdi: string;AHedefTablo: TDataSet);
begin
  if DokumVarMi(AHedefDokumAdi) then
    raise Exception.Create('Bu adla kayıtlı döküm var!!!');
  { İlk önce alt tablolar kopyalanıyor }
  with NewFDQuery('SELECT TOP 0 * FROM KOSULLAR',[],[]) do
  try
    Open;
    Tasi('KOSULLAR','RAPORADI', AKaynakDokumAdi, AHedefDokumAdi, TFDQuery(CurrentInstance));
  finally
    Free;
  end;
  with NewFDQuery('Select TOP 0 * from AYARLARYENI',[],[]) do
  try
    Open;
    Tasi('AYARLARYENI','RAPORADI', AKaynakDokumAdi, AHedefDokumAdi, TFDQuery(CurrentInstance));
  finally
    Free;
  end;
  { En son olarak ana tablo kopyalanıyor }
  Tasi('DOKUMLER', 'RAPORADI',AKaynakDokumAdi, AHedefDokumAdi, AHedefTablo);
end;

class function TRaporAraclari.DokumVarMi(ARaporAdi: string): Boolean;
begin
  Result := ExistsFD('Select RAPORADI From DOKUMLER Where RAPORADI = &raporadi',['&raporadi'],[ARaporAdi]);
end;

class procedure TRaporAraclari.RaporAdDegistir(AEkranAdi, AEskiRaporAdi, AYeniRaporAdi: string);
begin
  ExecFD('UPDATE DOKUMLER SET RAPORADI = &yenirapor WHERE GRUBU=&ekran '+ 'AND RAPORADI = &eskirapor',['&yenirapor','&ekran','&eskirapor'], [AYeniRaporAdi,AEkranAdi,AEskiRaporAdi]);
end;

class procedure TRaporAraclari.RaporKopyala(EskiDokId : Integer; AHedefRaporAdi: string);
var YeniDokId : Integer;
begin
   YeniDokId := Tablo.SatirKopyala('DOKUMLER', EskiDokId);
   ExecFD('UPDATE DOKUMLER SET RAPORADI='''+AHedefRaporAdi+''',SAYAC=0,RAPORNO=0,EKLEYEN='+Kullanan+
      ',EKLEMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''',DEGISTIREN='+Kullanan+
      ',DEGISTIRMETARIHI='''+FormatDateTime('mm/dd/yyyy hh:nn',Tablo.GENINI.BugunTrhSaat)+''' WHERE ID = &ID', ['&ID'],[YeniDokId]);

  ExecFD(' insert into AYARLARYENI (DOKUMID,GRUBU,MODUL,ACIKLAMA,AYARLAR,EKLEYEN) '+
    ' Select DOKUMID=&YeniDokId, GRUBU, MODUL, ACIKLAMA, AYARLAR, EKLEYEN=&Ekleyen  from AYARLARYENI '+
    ' Where DOKUMID=&EskiDokId ',['&YeniDokId','&EskiDokId','&Ekleyen'],[YeniDokId, EskiDokId, Kullanan]);

  ExecFD(' insert into KOSULLAR(DOKUMID,BAGLAC,TABLO,ALAN,KOD_ADI,ACIKLAMA,ESITLIK,DEGER,ICERIKTURU,COMBOICERIK,EKLEYEN) '+
    ' Select DOKUMID=&YeniDokId, BAGLAC,TABLO,ALAN,KOD_ADI,ACIKLAMA,ESITLIK,DEGER,ICERIKTURU,COMBOICERIK, EKLEYEN=&Ekleyen  from KOSULLAR '+
    ' Where DOKUMID=&EskiDokId ',['&YeniDokId','&EskiDokId','&Ekleyen'],[YeniDokId, EskiDokId, Kullanan]);
end;

class procedure TRaporAraclari.RaporPopupMenuHazirla(AEkranAdi: string; APopup: TPopupMenu;var ASeciliRapor: string;ASecOlayi : TNotifyEvent);
begin
  with NewFDQuery('Select RAPORADI,VARSAYILAN from DOKUMLER where GRUBU = &EkranAdi order By 2 desc,1 asc',['&EkranAdi'],[AEkranAdi]) do
  try
    Open;
    //APopup.Items.Clear;
    if not IsEmpty then begin
      ASeciliRapor := AsString[0];
      Next;
      while not Eof do begin
        APopup.Items.ItemOperation(moAdd,AsString[0],ASecOlayi);
        Next;
      end;
    end;   
  finally
    Free;
  end;
end;

class procedure TRaporAraclari.RaporSil(DokumId : Integer);
begin
  ExecFD('DELETE from AYARLARYENI WHERE DOKUMID=&DokumId',['&DokumId'],[DokumId]);
  ExecFD('DELETE from KOSULLAR WHERE DOKUMID=&DokumId',['&DokumId'],[DokumId]);
  ExecFD('DELETE from DOKUMLER WHERE ID=&DokumId',['&DokumId'],[DokumId]);
end;

class function TRaporAraclari.RaporVarMi(AEkranAdi, ARaporAdi: string): Boolean;
begin
  Result := ExistsFD('Select RAPORADI From AYARLARYENI Where RAPORADI = &raporadi AND EKRAN = &ekran', ['&ekran','&raporadi'],[AEkranAdi,ARaporAdi]);
end;

class procedure TRaporAraclari.RaporVarsayilanYap(AEkranAdi, ARaporAdi: string);
begin
  //önce bu ekrandakilerin hepsi sıfırlanır
  ExecFD('UPDATE DOKUMLER SET VARSAYILAN = 0  WHERE GRUBU =&ekran',['&ekran'],[AEkranAdi]);
  // sonra bu varsayılan yapılır
  ExecFD('UPDATE DOKUMLER SET VARSAYILAN = 1  WHERE GRUBU=&ekran '+ 'AND RAPORADI = &raporadi',['&raporadi','&ekran'],[ARaporAdi,AEkranAdi]);
end;

class procedure TRaporAraclari.Tasi(ATablo, ADegisecekAlan,EskiDegeri, YeniDegeri: string;
  AHedefTablo: TDataSet);
var
  i : Integer;
  stream : TMemoryStream;
begin
  with NewFDQuery('Select * From ' + ATablo + ' Where RAPORADI = &EskiDeger',['&EskiDeger'],[EskiDegeri]) do
  try
    Open;
    while not eof do begin
      AHedefTablo.Append;
      AHedefTablo.AsString[ADegisecekAlan] := YeniDegeri;
      for i := 0 to AHedefTablo.Fields.Count - 1 do
        if not AnsiSameText(AHedefTablo.Fields[i].FieldName, ADegisecekAlan) then begin
          if Fields[i].IsBlob then begin
            stream := TMemoryStream.Create;
            try
              TBlobField(Fields[i]).SaveToStream(stream);
              stream.Position := 0;
              TBlobField(AHedefTablo.Fields[i]).LoadFromStream(stream);
            finally
              stream.Free;
            end;
          end else AHedefTablo.Fields[i].AsVariant := Fields[i].AsVariant;
        end;
      AHedefTablo.Post;
      Next;
    end;
  finally
    Free;
  end;
end;

class procedure TRaporAraclari.YeniRapor(AEkranAdi, ARaporAdi: string);
var RaporId : Integer;
begin
  with NewFDQuery('SELECT TOP 0 * FROM DOKUMLER',[],[]) do
  try
    Open;
    Append;
      AsString['RAPORADI'] := ARaporAdi;
      AsString['GRUBU'] := AEkranAdi;
      AsString['MODUL'] := '-';
      AsBoolean['VARSAYILAN'] := False;
      AsInteger['SAYAC'] := 0;
      AsString['EKLEYEN'] := Kullanan;
    Post;
    RaporId := AsInteger['ID'];
  finally
    Free;
  end;

  with NewFDQuery('SELECT TOP 0 * FROM AYARLARYENI',[],[]) do
  try
    Open;
    Append;
      AsInteger['DOKUMID'] := RaporId;
      AsString['EKLEYEN'] := Kullanan;
    Post;
  finally
    Free;
  end;
end;

end.



