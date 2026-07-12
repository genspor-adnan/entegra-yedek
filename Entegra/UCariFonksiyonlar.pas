unit UCariFonksiyonlar;

interface

uses FireDAC.Comp.Client, SysUtils, DB, FetaKurulusSiniflari, cxEdit, Forms,
  Windows, Dialogs, Variants, jpeg;

procedure PersonelVarsayilanYap(RehberId, RehberPerId: Integer);
procedure Ekle(Table1: TFDQuery; Yeri, Yeri_Id: Integer; Logislem: string; Bolum: string = ''; AUstTabloID: Integer = 0; AUstKayitID: Integer = 0; ADetayTabloID: Integer = 0; ABaslik: string = '');
procedure CariIlgiliSil(RehberId, PerId: Integer; Varsayilan: Boolean; AUstTabloID: Integer = 71);
procedure CariIletisimSil(RehberId, IletId: Integer; Varsayilan: Boolean; AUstTabloID: Integer = 71);

implementation

uses Utablo, PrjConst, ULog, UVeriMotor;

procedure PersonelVarsayilanYap(RehberId, RehberPerId: Integer);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := ' update REHBER set STATU = (case when ID=' +
    IntToStr(RehberPerId) + ' then 1 else 0 end) where GRUP=334 and BAGID=' +
    IntToStr(RehberId);
  Tablo.Query1.ExecSQL;
end;

procedure Ekle(Table1: TFDQuery; Yeri, Yeri_Id: Integer; Logislem: string; Bolum: string = ''; AUstTabloID: Integer = 0; AUstKayitID: Integer = 0; ADetayTabloID: Integer = 0; ABaslik: string = '');
var
  bilgi, orj: string;
  RehberBilgiID: Integer;
  HedefKayitID: Integer;
  Pic: TJPEGImage;
begin
  if Table1.State in [dsEdit, dsInsert] then
    Table1.Post;

  Table1.First;
  while not Table1.Eof do
  begin
    if (Table1.FieldByName('ZORUNLU').AsBoolean) and (Trim(Table1.FieldByName('BILGI').AsString) = '') then
      raise Exception.Create(Table1.FieldByName('ETIKET').AsString + ' girilmesi zorunlu alandır!');
    Table1.Next;
  end;

  // ISLEMLOG grup basligi (detayin ustunde gosterilir): iletisim(75)->REHBERILETISIM.AD
  // ("Merkez" gibi), ilgili(81)->caller'in verdigi kisi adi (ABaslik).
  var LBaslikEtiket: string := '';
  var LBaslikDeger: string := ABaslik;
  case ADetayTabloID of
    75: begin
          LBaslikEtiket := 'İletişim';
          if LBaslikDeger = '' then
            LBaslikDeger := VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
              'select AD from REHBERILETISIM where ID=&id', ['&id'], [Yeri_Id], True));
        end;
    79: begin   // ticari: baslik = cari adi (YER_ID=cari REHBER.ID)
          LBaslikEtiket := 'Ticari';
          if LBaslikDeger = '' then
            LBaslikDeger := VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
              'select FIRMA from REHBER where ID=&id', ['&id'], [Yeri_Id], True));
        end;
    81: LBaslikEtiket := 'İlgili';
    370, 372: LBaslikEtiket := 'Şablon';   // stok(370)/proje(372) detay: baslik = sablon/bolum adi (ABaslik)
    86: begin   // ozluk: baslik = personel adi (YER_ID=personel REHBER.ID)
          LBaslikEtiket := 'Özlük';
          if LBaslikDeger = '' then
            LBaslikDeger := VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
              'select FIRMA from REHBER where ID=&id', ['&id'], [Yeri_Id], True));
        end;
  end;

  // ISLEMLOG: islem tipine gore TEK satirda topla (KAYITID = container = Yeri_Id).
  var LDetayTab: Integer := ADetayTabloID;
  if LDetayTab <= 0 then LDetayTab := TabNo_REHBERBILGI;
  var LLogAktif: Boolean := (AUstTabloID > 0) and (LogGun > 0);
  var LKEkle: TLogKurucu := nil;
  var LKDegis: TLogKurucu := nil;
  var LKSil: TLogKurucu := nil;
  var LEkleVar: Boolean := False;
  var LDegisVar: Boolean := False;
  var LSilVar: Boolean := False;
  if LLogAktif then
  begin
    LKEkle := TLogKurucu.Yeni;
    LKDegis := TLogKurucu.Yeni;
    LKSil := TLogKurucu.Yeni;
    if (LBaslikEtiket <> '') and (LBaslikDeger <> '') then
    begin   // baslik (iletisim/ilgili adi) her tipin en ustunde
      LKEkle.Deger(LBaslikEtiket, LBaslikDeger);
      LKDegis.Deger(LBaslikEtiket, LBaslikDeger);
      LKSil.Deger(LBaslikEtiket, LBaslikDeger);
    end;
  end;

  Table1.First;
  while not Table1.Eof do
  begin
    RehberBilgiID := 0;
    bilgi := Trim(Table1.FieldByName('BILGI').AsString);
    orj := Trim(Table1.FieldByName('ORJINAL').AsString);


    if (bilgi <> orj) or (StrToIntDef(Table1.FieldByName('GIRIS').AsString, 0) in [11, 12]) then
    begin
      Tablo.Query1.Close;
      if (orj = '') and (bilgi <> '') then
      begin
        Tablo.Query1.SQL.Text := 'select '+DbUst(1)+'ID from REHBERBILGI where YERI=:PYERI and YER_ID=:PYERID and SIRA=:PSIRA and ETIKET=:PETIKET order by ID '+DbSinir(1);
        Tablo.Query1.ParamByName('PYERI').AsInteger := Yeri;
        Tablo.Query1.ParamByName('PYERID').AsInteger := Yeri_Id;
        Tablo.Query1.ParamByName('PSIRA').AsInteger := Table1.FieldByName('SIRA').AsInteger;
        Tablo.Query1.ParamByName('PETIKET').AsString := Table1.FieldByName('ETIKET').AsString;
        Tablo.Query1.Open;
        if Tablo.Query1.RecordCount > 0 then
        begin
          RehberBilgiID := Tablo.Query1.Fields[0].AsInteger;
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := ' update REHBERBILGI set BILGI=:PBILGI, DEGISTIREN=:PDEGISTIREN where ID=:PID';
          Tablo.Query1.ParamByName('PBILGI').AsString := Table1.FieldByName('BILGI').AsString;
          Tablo.Query1.ParamByName('PDEGISTIREN').AsString := Kullanan;
          Tablo.Query1.ParamByName('PID').AsInteger := RehberBilgiID;
          Tablo.Query1.ExecSQL;
        end
        else
        begin
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := ' insert into REHBERBILGI (YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,SUBEID) values (' +
            IntToStr(Yeri) + ',' + IntToStr(Yeri_Id) + ',' + Table1.FieldByName('SIRA').AsString + ',''' +
            Table1.FieldByName('ETIKET').AsString + ''',''' + Table1.FieldByName('BILGI').AsString + ''',''' +
            Kullanan + ''',' + IntToStr(SubeId) + ') select scope_identity()';
          Tablo.Query1.Open;
          RehberBilgiID := Tablo.Query1.Fields[0].AsInteger;
        end;
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
        if (Table1.FindField('RBID') <> nil) and not VarIsNull(Table1.FieldByName('RBID').Value) and
           not VarIsEmpty(Table1.FieldByName('RBID').Value) and (Table1.FieldByName('RBID').AsInteger > 0) then
        begin
          Tablo.Query1.SQL.Text := ' update REHBERBILGI set BILGI=:PBILGI, DEGISTIREN=:PDEGISTIREN where ID=:PID';
          Tablo.Query1.ParamByName('PBILGI').AsString := Table1.FieldByName('BILGI').AsString;
          Tablo.Query1.ParamByName('PDEGISTIREN').AsString := Kullanan;
          Tablo.Query1.ParamByName('PID').AsInteger := Table1.FieldByName('RBID').AsInteger;
          RehberBilgiID := Table1.FieldByName('RBID').AsInteger;
        end
        else if (Table1.FindField('ID') <> nil) and not VarIsNull(Table1.FieldByName('ID').Value) and
                not VarIsEmpty(Table1.FieldByName('ID').Value) and (Table1.FieldByName('ID').AsInteger > 0) then
        begin
          Tablo.Query1.SQL.Text := ' update REHBERBILGI set BILGI=:PBILGI, DEGISTIREN=:PDEGISTIREN where ID=:PID';
          Tablo.Query1.ParamByName('PBILGI').AsString := Table1.FieldByName('BILGI').AsString;
          Tablo.Query1.ParamByName('PDEGISTIREN').AsString := Kullanan;
          Tablo.Query1.ParamByName('PID').AsInteger := Table1.FieldByName('ID').AsInteger;
          RehberBilgiID := Table1.FieldByName('ID').AsInteger;
        end
        else
        begin
          HedefKayitID := 0;
          Tablo.Query1.SQL.Text := 'select '+DbUst(1)+'ID from REHBERBILGI where YERI=:PYERI and YER_ID=:PYERID and SIRA=:PSIRA and ETIKET=:PETIKET order by ID '+DbSinir(1);
          Tablo.Query1.ParamByName('PYERI').AsInteger := Yeri;
          Tablo.Query1.ParamByName('PYERID').AsInteger := Yeri_Id;
          Tablo.Query1.ParamByName('PSIRA').AsInteger := Table1.FieldByName('SIRA').AsInteger;
          Tablo.Query1.ParamByName('PETIKET').AsString := Table1.FieldByName('ETIKET').AsString;
          Tablo.Query1.Open;
          if not Tablo.Query1.IsEmpty then
            HedefKayitID := Tablo.Query1.Fields[0].AsInteger;
          Tablo.Query1.Close;

          if HedefKayitID > 0 then
          begin
            Tablo.Query1.SQL.Text := ' update REHBERBILGI set BILGI=:PBILGI, DEGISTIREN=:PDEGISTIREN where ID=:PID';
            Tablo.Query1.ParamByName('PBILGI').AsString := Table1.FieldByName('BILGI').AsString;
            Tablo.Query1.ParamByName('PDEGISTIREN').AsString := Kullanan;
            Tablo.Query1.ParamByName('PID').AsInteger := HedefKayitID;
            RehberBilgiID := HedefKayitID;
          end;
        end;
        if Pos('UPDATE REHBERBILGI', UpperCase(Tablo.Query1.SQL.Text)) > 0 then begin
          Tablo.Query1.ExecSQL;
        end;
      end;
      // ---- YENI ISLEMLOG: islem tipine gore biriktir (dongu sonunda tek satir yazilir) ----
      if LLogAktif then
      begin
        // Alan adi = ETIKET degeri (Adres, Cep Tel...), deger = BILGI.
        var LEtiket: string := Table1.FieldByName('ETIKET').AsString;
        if (Logislem = 'Silme') or ((orj <> '') and (bilgi = '')) then begin
          LKSil.Deger(LEtiket, orj); LSilVar := True;
        end
        else if orj = '' then begin
          LKEkle.Deger(LEtiket, bilgi); LEkleVar := True;
        end
        else begin
          LKDegis.Alan(LEtiket, orj, bilgi); LDegisVar := True;
        end;
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

  // ISLEMLOG: her islem tipi icin TEK satir. KAYITID = container (Yeri_Id):
  // iletisim->REHBERILETISIM.ID (Merkez), ilgili->kisi ID, ticari/ozluk->master ID.
  if LLogAktif then
  try
    // REHBERID/STOKID: LogYaz ust tablodan otomatik turetir (71/73/74->REHBERID, 88->STOKID).
    if LEkleVar  then LogYaz(liEkle,     LDetayTab, Yeri_Id, LKEkle.JSON,  '', AUstTabloID, AUstKayitID);
    if LDegisVar then LogYaz(liDegistir, LDetayTab, Yeri_Id, LKDegis.JSON, '', AUstTabloID, AUstKayitID);
    if LSilVar   then LogYaz(liSil,      LDetayTab, Yeri_Id, LKSil.JSON,   '', AUstTabloID, AUstKayitID);
  except
  end;
  if Assigned(LKEkle)  then LKEkle.Free;
  if Assigned(LKDegis) then LKDegis.Free;
  if Assigned(LKSil)   then LKSil.Free;
end;

// Silinen detay (iletisim 75 / ilgili 81) icin ISLEMLOG: baslik + silinecek REHBERBILGI
// alanlari tek kayitta (liSil). Silmeden ONCE cagrilmali (veriler hala DB'de).
procedure _DetaySilLog(ADetayTabNo, AKayitID, AUstTabloID, AUstKayitID: Integer;
  const ABaslikEtiket, ABaslikDeger, ABilgiWhere: string);
begin
  if LogGun <= 0 then Exit;
  try
    var LK: TLogKurucu := TLogKurucu.Yeni;
    try
      if ABaslikDeger <> '' then LK.Deger(ABaslikEtiket, ABaslikDeger);
      Tablo.TablodanSorguAc(2, 'select ETIKET, BILGI from REHBERBILGI where ' + ABilgiWhere);
      while not Tablo.Query2.Eof do
      begin
        LK.Deger(Tablo.Query2.FieldByName('ETIKET').AsString, Tablo.Query2.FieldByName('BILGI').AsString);
        Tablo.Query2.Next;
      end;
      LogYaz(liSil, ADetayTabNo, AKayitID, LK.JSON, '', AUstTabloID, AUstKayitID, AUstKayitID);
    finally
      LK.Free;
    end;
  except
  end;
end;

procedure CariIletisimSil(RehberId, IletId: Integer; Varsayilan: Boolean; AUstTabloID: Integer = 71);
var
  ID: Integer;
begin
  // SILME logu (75 iletisim): silmeden ONCE - baslik REHBERILETISIM.AD + bilgiler.
  _DetaySilLog(75, IletId, AUstTabloID, RehberId, 'İletişim',
    VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'select AD from REHBERILETISIM where ID=&id', ['&id'], [IletId], True)),
    'YERI=1 and YER_ID=' + IntToStr(IletId));

  if Varsayilan then
  begin
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := ' select '+DbUst(1)+'ID from REHBERILETISIM where REHBERID=' +
      IntToStr(RehberId) + ' and ID<>' + IntToStr(IletId) + ' order by 1 '+DbSinir(1);
    Tablo.Query1.Open;
    ID := Tablo.Query1.Fields[0].AsInteger;
  end
  else
    ID := -1;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERBILGI where YERI=1 and YER_ID=&id ', ['&id'], [IletId]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=11 and YER_ID=&id ', ['&id'], [IletId]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERILETISIM where ID=&id ', ['&id'], [IletId]);
  if ID > 0 then
    PersonelVarsayilanYap(RehberId, ID);
end;

procedure CariIlgiliSil(RehberId, PerId: Integer; Varsayilan: Boolean; AUstTabloID: Integer = 71);
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

  // SILME logu (81 ilgili): silmeden ONCE - baslik REHBER.FIRMA (kisi adi) + bilgiler.
  _DetaySilLog(81, PerId, AUstTabloID, RehberId, 'İlgili',
    VarToStr(Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'select FIRMA from REHBER where ID=&id', ['&id'], [PerId], True)),
    'YERI=1 and YER_ID in (select ID from REHBERILETISIM where REHBERID=' + IntToStr(PerId) + ')');

  if Varsayilan then
  begin
    Tablo.TablodanSorguAc(1, ' select '+DbUst(1)+'ID from REHBER where GRUP=334 and BAGID=' + IntToStr(RehberId) + ' and ID<>' + IntToStr(PerId) + ' order by 1 '+DbSinir(1));
    ID := Tablo.Query1.Fields[0].AsInteger;
  end
  else
    ID := -1;

  Tablo.Query1.SQL.Text := ' delete from REHBERBILGI where YERI = 1 and YER_ID=(select ID from REHBERILETISIM where REHBERID=' + IntToStr(PerId) + ')';
  Tablo.Query1.ExecSQL;
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=12 and YER_ID=&id ', ['&id'], [PerId]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBERILETISIM where REHBERID=&id ', ['&id'], [PerId]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from REHBER where ID=&id ', ['&id'], [PerId]);
  if ID > 0 then
    PersonelVarsayilanYap(RehberId, ID);
end;

end.












