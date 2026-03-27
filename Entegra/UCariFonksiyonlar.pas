unit UCariFonksiyonlar;

interface

uses FireDAC.Comp.Client, SysUtils, DB, FetaKurulusSiniflari, cxEdit, Forms,
  Windows, Dialogs, Variants, jpeg;

procedure PersonelVarsayilanYap(RehberId, RehberPerId: Integer);
procedure Ekle(Table1: TFDQuery; Yeri, Yeri_Id: Integer; Logislem: string; Bolum: string = '');
procedure CariIlgiliSil(RehberId, PerId: Integer; Varsayilan: Boolean);
procedure CariIletisimSil(RehberId, IletId: Integer; Varsayilan: Boolean);

implementation

uses Utablo, PrjConst;

procedure PersonelVarsayilanYap(RehberId, RehberPerId: Integer);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' update REHBER set STATU = (case when ID=' +
    IntToStr(RehberPerId) + ' then 1 else 0 end) where GRUP=334 and BAGID=' +
    IntToStr(RehberId);
  Tablo.Query1.ExecSQL;
end;

procedure Ekle(Table1: TFDQuery; Yeri, Yeri_Id: Integer; Logislem: string; Bolum: string = '');
var
  bilgi, orj: string;
  RehberBilgiID: Integer;
  Pic: TJPEGImage;
  VLogID: Variant;
  LogTur: Integer;
  procedure LogHarEkle(const AAlanAdi, AEskiDeger, AYeniDeger: string);
  begin
    Veritabani.BasitKomutÇalýþtýr(
      Tablo.FDCnn,
      'insert into [LOGHAR] (LOGID, TABLOALANADI, ESKIALANDEGERI, YENIALANDEGERI) ' +
      'values (&LOGID, &TABLOALANADI, &ESKIALANDEGERI, &YENIALANDEGERI)',
      ['&LOGID', '&TABLOALANADI', '&ESKIALANDEGERI', '&YENIALANDEGERI'],
      [LogID, AAlanAdi, AEskiDeger, AYeniDeger]
    );
  end;
begin
  if Table1.State in [dsEdit, dsInsert] then
    Table1.Post;

  Table1.First;
  while not Table1.Eof do
  begin
    if (Table1.FieldByName('ZORUNLU').AsBoolean) and (Trim(Table1.FieldByName('BILGI').AsString) = '') then
      raise Exception.Create(Table1.FieldByName('ETIKET').AsString + ' girilmesi zorunlu alandýr!');
    Table1.Next;
  end;

  if Logislem = 'Silme' then
    LogTur := 1
  else
    LogTur := 0;

  if LogID = 0 then
  begin
    VLogID := Veritabani.BasitKomutÇalýþtýr(
      Tablo.FDCnn,
      'insert into [LOG] (TARIH, TABLOID, SATIRID, EKLEYEN, TUR, PCADI) ' +
      'values (&TARIH, &TABLOID, &SATIRID, &EKLEYEN, &TUR, &PCADI) ' +
      'SELECT SCOPE_IDENTITY()',
      ['&TARIH*datetime*', '&TABLOID', '&SATIRID', '&EKLEYEN', '&TUR', '&PCADI'],
      [Now, Yeri, Yeri_Id, Kullanan, LogTur, Tablo.ClientName],
      True
    );
    if not (VarIsNull(VLogID) or VarIsEmpty(VLogID)) then
      LogID := VLogID;
  end;

  Table1.First;
  while not Table1.Eof do
  begin
    RehberBilgiID := 0;
    bilgi := Trim(Table1.FieldByName('BILGI').AsString);
    orj := Trim(Table1.FieldByName('ORJINAL').AsString);

    if (bilgi <> orj) or (StrToIntDef(Table1.FieldByName('GIRIS').AsString, 0) in [11, 12]) then
    begin
      if Logislem = 'Silme' then
        LogHarEkle(Table1.FieldByName('ETIKET').AsString, orj, '')
      else
        LogHarEkle(Table1.FieldByName('ETIKET').AsString, orj, bilgi);

      Tablo.Query1.Close;
      if (orj = '') and (bilgi <> '') then
      begin
        Tablo.Query1.SQL.Text := ' insert into REHBERBILGI (YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,SUBEID) values (' +
          IntToStr(Yeri) + ',' + IntToStr(Yeri_Id) + ',' + Table1.FieldByName('SIRA').AsString + ',''' +
          Table1.FieldByName('ETIKET').AsString + ''',''' + Table1.FieldByName('BILGI').AsString + ''',''' +
          Kullanan + ''',' + IntToStr(SubeId) + ') select scope_identity()';
        Tablo.Query1.Open;
        RehberBilgiID := Tablo.Query1.Fields[0].AsInteger;
      end
      else if (orj <> '') and (bilgi = '') then
      begin
        Tablo.Query1.SQL.Text := ' delete from REHBERBILGI where YERI=' + IntToStr(Yeri) +
          ' and YER_ID=' + IntToStr(Yeri_Id) + ' and SIRA=' + Table1.FieldByName('SIRA').AsString +
          ' and ETIKET=''' + Table1.FieldByName('ETIKET').AsString + '''';
        Tablo.Query1.ExecSQL;
        RehberBilgiID := 0;
      end
      else if (orj <> '') and (bilgi <> '') then
      begin
        Tablo.Query1.SQL.Text := ' update REHBERBILGI set BILGI=''' + Table1.FieldByName('BILGI').AsString +
          ''', DEGISTIREN=''' + Kullanan + ''' where YERI=' + IntToStr(Yeri) + ' and YER_ID=' +
          IntToStr(Yeri_Id) + ' and SIRA=' + Table1.FieldByName('SIRA').AsString + ' and ETIKET=''' +
          Table1.FieldByName('ETIKET').AsString + '''';
        Tablo.Query1.ExecSQL;
        if Table1.FieldList.Find('RESIM') <> nil then
          RehberBilgiID := Table1.FieldByName('RBID').AsInteger;
      end;
    end;

    if Table1.FieldList.Find('RESIM') <> nil then
    begin
      if Table1.FieldByName('ESKIRESIM').AsBytes <> Table1.FieldByName('RESIM').AsBytes then
      begin
        if (RehberBilgiID = 0) and (Table1.FieldByName('RBID').Value <> null) then
          RehberBilgiID := Table1.FieldByName('RBID').AsInteger;
        Tablo.Query1.Close;

        if (Table1.FieldByName('ESKIRESIM').Value = null) and (Table1.FieldByName('RESIM').Value <> null) then
        begin
          Pic := TJPEGImage.Create;
          try
            Pic.LoadFromStream(Table1.CreateBlobStream(Table1.FieldByName('RESIM'), bmRead));
            Tablo.Query1.SQL.Text := 'insert into REHBERBILGIRESIM(REHBERBILGIID,RESIM,EKLEYEN)values(' +
              IntToStr(RehberBilgiID) + ',:PResim,' + Kullanan + ')';
            Tablo.Query1.ParamByName('PResim').Assign(Pic);
            Tablo.Query1.ExecSQL;
          finally
            Pic.Free;
          end;
        end
        else if (Table1.FieldByName('ESKIRESIM').Value <> null) and (Table1.FieldByName('RESIM').Value = null) then
        begin
          Tablo.Query1.SQL.Text := ' delete from REHBERBILGIRESIM where REHBERBILGIID=' + IntToStr(RehberBilgiID);
          Tablo.Query1.ExecSQL;
        end
        else if (Table1.FieldByName('ESKIRESIM').Value <> null) and (Table1.FieldByName('RESIM').Value <> null) then
        begin
          Pic := TJPEGImage.Create;
          try
            Pic.LoadFromStream(Table1.CreateBlobStream(Table1.FieldByName('RESIM'), bmRead));
            Tablo.Query1.SQL.Text := ' update REHBERBILGIRESIM set RESIM=:PResim,DEGISTIREN=' +
              Kullanan + ',DEGISTIRMETARIHI=GetDate() where REHBERBILGIID=' + IntToStr(RehberBilgiID);
            Tablo.Query1.ParamByName('PResim').Assign(Pic);
            Tablo.Query1.ExecSQL;
          finally
            Pic.Free;
          end;
        end;
      end;
    end;
    Table1.Next;
  end;
end;

procedure CariIletisimSil(RehberId, IletId: Integer; Varsayilan: Boolean);
var
  ID: Integer;
begin
  if Varsayilan then
  begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := ' select top 1 ID from REHBERILETISIM where REHBERID=' +
      IntToStr(RehberId) + ' and ID<>' + IntToStr(IletId) + ' order by 1';
    Tablo.Query1.Open;
    ID := Tablo.Query1.Fields[0].AsInteger;
  end
  else
    ID := -1;

  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=1 and YER_ID=&id ', ['&id'], [IletId]);
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from IMAJ where YERI=11 and YER_ID=&id ', ['&id'], [IletId]);
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBERILETISIM where ID=&id ', ['&id'], [IletId]);
  if ID > 0 then
    PersonelVarsayilanYap(RehberId, ID);
end;

procedure CariIlgiliSil(RehberId, PerId: Integer; Varsayilan: Boolean);
  function Silme_Kontrolu(Tablo1, Alan, Mesaj: String): Boolean;
  begin
    if Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from ' + Tablo1 + ' where REHBERID =  &SId and ' + Alan + '=' + IntToStr(PerId) + ' ', ['&SId'], [PerId]) then
      raise Exception.Create(Mesaj);
    Result := True;
  end;
var
  ID: Integer;
begin
  Silme_Kontrolu('PROJELER', 'ILGILI', RDProjeVerisiVarSilinemez);
  Silme_Kontrolu('GOREVLER', 'MUS_ILGILI', RDAktiviteVerisiVarSilinemez);
  Silme_Kontrolu('GOREVLER', 'MUS_ILGILI2', RDAktiviteVerisiVarSilinemez);
  Silme_Kontrolu('TEKLIF', 'MUS_ILGILI', RDTeklifVerisiVarSilinemez);
  Silme_Kontrolu('SERVIS', 'MUS_ILGILI', RDServisVerisiVarSilinemez);

  if Varsayilan then
  begin
    Tablo.TablodanSorguAc(1, ' select top 1 ID from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberId) + ' and ID<>' + IntToStr(PerId) + ' order by 1');
    ID := Tablo.Query1.Fields[0].AsInteger;
  end
  else
    ID := -1;

  Tablo.Query1.SQL.Text := ' delete from REHBERBILGI where YERI = 1 and YER_ID=(select ID from REHBERILETISIM where REHBERID=' + IntToStr(PerId) + ')';
  Tablo.Query1.ExecSQL;
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from IMAJ where YERI=12 and YER_ID=&id ', ['&id'], [PerId]);
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBERILETISIM where REHBERID=&id ', ['&id'], [PerId]);
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, ' delete from REHBER where ID=&id ', ['&id'], [PerId]);
  if ID > 0 then
    PersonelVarsayilanYap(RehberId, ID);
end;

end.