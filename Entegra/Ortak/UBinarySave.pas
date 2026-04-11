unit UBinarySave;


interface
uses DB, Classes, Graphics, OleCtnrs, MSS_Sender,
  ZLibEx, system.variants,

  //Compress,ZLib,
   UFDCompatHelpers, FireDAC.Comp.Client, CONTROLS,SysUtils,ShellAPI, Windows, Dialogs, Utablo, Types;

  function LoadFromBlob(const AField: TField; const Stream: TStream): boolean;
  function SaveToBlob(const Stream: TStream; const AField: TField): boolean;
  procedure OleStreamdenKaydet(OleContainer1: TOleContainer; Tablo1:TFDQuery; AlanAdi:string);
//  procedure OleTablodanKaydet( Tablo1:TADOTable;OkunanDosyaAdi, AlanAdi:string);
  procedure OLEOku(OleContainer1: TOleContainer;Tablo1:TFDQuery; AlanAdi:string);
  function KutuktenOku(Tablo1:TFDQuery; AlanAdi, Uzanti:string; DokumaniAc:Boolean; DokumanAd:String='') : string;
  function KutugeYaz(Tablo1:TFDQuery; DosyaAdi:string):boolean;


implementation
uses FetaKurulusSiniflari, PrjConst, FetaUtil;
(*
Question/Problem/Abstract:

How to get binary data in a workable format into or out of an MSSQL Image (Blob) field using ADO components.
Answer:
The main problem I faced when trying to do this was to deal with the fact that TField.Value returns a varOleStr no matter what was written into it,
so the data needed to be converted into a more usable format.
Note that there is no checking here that the TField is in fact of the correct type, and that the stream must be created and free-ed elsewhere manually.
Also, additional memory equal to the size of the stream/blob is required, so be cautious if large amounts of data are involved.
For ease of use in my own application, I incorporated this functionality into my descendent of TADOQuery.
*)

function LoadFromBlob(const AField: TField; const Stream: TStream): boolean;
var
  ResultStr: string;
  PResultStr: PChar;
begin
  Result := false;
  if (Assigned(AField)) and (Assigned(Stream)) then begin
    try
      ResultStr := AField.Value;
      PResultStr := PChar(ResultStr);
      Stream.Write(PResultStr^, Length(ResultStr));
      Stream.Seek(0,0);
      Result := true;
    except
    end;
  end;
end;

function SaveToBlob(const Stream: TStream; const AField: TField): boolean;
var
  FieldStr: string;
  PFieldStr: PChar;
begin
  Result := false;
  if (Assigned(AField)) and (Assigned(Stream)) then begin
    try
      Stream.Seek(0,0);
      SetLength(FieldStr, Stream.Size);
      PFieldStr := PChar(FieldStr);
      Stream.Read(PFieldStr^, Stream.Size);
      AField.Value := FieldStr;
      Result := true;
    except
    end;
  end;
end;


procedure OleStreamdenKaydet(OleContainer1: TOleContainer; Tablo1:TFDQuery; AlanAdi:string);
var
  TmpStream: TStream;
  Stream2: TStream;
begin
    //Stream2 := TabOle.CreateBlobStream(TabOle.FieldByName('RAPORBILGI'), bmReadWrite);
    Stream2 := TMemoryStream.Create;
    OleContainer1.SaveToStream(Stream2);

    TmpStream := Tablo1.CreateBlobStream(Tablo1.FieldByName(AlanAdi), bmReadWrite);

    if (Stream2.Size <> 0) then
    begin
      Stream2.Position := 0;
      TmpStream.Position := 0;
      ZCompressStream(Stream2, TmpStream);

    end
    else
      TmpStream := Stream2;

    FillChar(Stream2, sizeof(Stream2), 0);
    //Tablo1.FieldByName('RAPORBILGI').SetData(nil);
    Stream2.Free;
    TmpStream.Free;
end;

procedure OLEOku(OleContainer1: TOleContainer;Tablo1:TFDQuery; AlanAdi:string);
var
  TempStream: TMemoryStream;
  Stream2: TMemoryStream;

  Stream_ :TStream;
  ms : TMemoryStream;
begin
  ms := TMemoryStream.Create;
  Stream_:= Tablo1.CreateBlobStream(Tablo1.FieldByName(AlanAdi), bmRead);
  Stream_.Position:=0;
  ms.Position:=0;
  ZDecompressStream( Stream_, ms);
  if ms.Size > 0 then begin
     ms.Position := 0;
     OleContainer1.LoadFromStream(TStream(ms));
  end;
  ms.Free;
  Stream_.Free;

{        TempStream := TMemoryStream.Create;
        Stream2 := TMemoryStream.Create;

          Stream2.Position := 0;
          if (Stream2.Size = 0) then
          begin
            Stream2 := TMemoryStream.Create;
            try
              TBlobField(Tablo1.FieldByName(AlanAdi)).SaveToStream(Stream2);           //Stream2 := TabOle.CreateBlobStream(, bmRead);
              if (Stream2.Size <> 0) then
              begin
                Stream2.Position := 0;
                ZDecompressStream(Stream2, TempStream);
              end;
            finally
              Stream2.Free;
            end;
            if TempStream.Size > 0 then
            begin
              TempStream.Position := 0;
              OleContainer1.LoadFromStream(TempStream);
            end;
          end
          else
            OleContainer1.LoadFromStream(Stream2);
          TempStream.Free; }
end;

// 2/3/2010
//Emreden aldýðým yeni yöntem
function KutuktenOku(Tablo1:TFDQuery; AlanAdi, Uzanti:string; DokumaniAc : Boolean; DokumanAd:String='') : string;
var
  Stream_ :TStream;
  tempfile,fs : TFileStream;
  uzanti1 :string;
begin
  try
    Stream_:= Tablo1.CreateBlobStream(Tablo1.FieldByName(AlanAdi), bmRead);
  except
    showmessage(DOKEklenmis_dok_bulunamadi);
    result:='';
    exit;
  end;
  Stream_.Position:=0;

  if DokumanAd='' then begin //dokümanýn adý önceden verilmemiþse burada oluþtururuz..
      uzanti1:=copy(Uzanti,pos('1', Uzanti)+1,100);
      if uzanti= '1'+uzanti1 then
         DokumanAd := uzanti1 //+Tablo1.FieldByName('DosyaAdi').AsString
      else begin
         if pos('.',Uzanti)=0 then
            Uzanti:='.'+Uzanti;
         DokumanAd := 'tmp'+FormatDateTime('yyyyMMddhhnnss',Now)+Uzanti;
      end;
  end;
  //baþýna windows geçici dizini koyalým..
  DokumanAd := GetEnvironmentVariable('Temp')+'\'+DokumanAd;

  tempfile:= TFileStream.Create(DokumanAd, fmCreate );
  try
    ZDecompressStream( Stream_, tempfile);
  except
    Stream_.Position:=0;
    tempfile.CopyFrom( Stream_, Stream_.Size);
    Stream_.Free;
    tempfile.Free;
    result := '';
    exit;
  end;
  Stream_.Free;
  tempfile.Free;
  if DokumaniAc then
     ShellExecute(0 {Handle}, 'open',pchar(DokumanAd),nil,nil,SW_SHOWNORMAL);
  result := DokumanAd;
end;

function KutugeYaz(Tablo1:TFDQuery; DosyaAdi:string):boolean;
var
  CompressedStream_ :TMemoryStream;
  fs : TFileStream;
  tempfile : TFileStream;
  ImajID : integer;
begin
  CompressedStream_:= TMemoryStream.Create;
  CompressedStream_.Position:=0;
  fs:= TFileStream.Create(DosyaAdi, fmOpenRead );
  fs.Position := 0;
  ZCompressStream(fs, CompressedStream_);
  try
     if Dokuman_Kayit_Yeri=0 then begin//Eðer doküman veritabaný içinde BELGE alanýnda tutulacaksa burada içine gömeriz.. (Record oluþturmadan)
        Tablo1.Params[0].LoadFromStream(CompressedStream_ , ftBlob);  //tabloya belgeyi kaydediyor
        if pos('update', Tablo1.SQL.Text)=1 then
           Tablo1.ExecSQL
        else
           Tablo1.Open;
     end else if Dokuman_Kayit_Yeri=1 then begin//Eðer doküman veritabaný dýþýnda klasörde tutulacaksa burada klasöre kaydediyoruz.. (Record oluþturduktan sonra)

        with Tablo.Query1.Params.ParamByName('PBELGE') do
        begin
          DataType := ftBlob;
          ParamType := ptInput;
          LoadFromStream(CompressedStream_, ftBlob);
        end;

        Tablo1.Open;
        ImajID := Tablo.Query1.Fields[0].AsInteger;
        Tablo.Query5.Close;
        Tablo.Query5.SQL.Text:='DECLARE @BELGE varbinary(MAX) SELECT @BELGE=CONVERT(VARBINARY(MAX), :PBELGE)  EXEC [sp_Imaj_Kaydetme] '+IntToStr(ImajID)+',@BELGE ';  //  Tablo1.Fields[0].AsString
        Tablo.Query5.Params[0].LoadFromStream(CompressedStream_ , ftBlob);
        Tablo.Query5.ExecSQL;
        ///Burada kütüðe yazýlan okunabiliyor mu kontrol edelim
        try
          tablo.Query5.Close;                                                             //Tablo1.Fields[0].AsString
          tablo.Query5.SQL.Text := ' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '+IntToStr(ImajID)+' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI='''+ExtractFileExt(DosyaAdi)+'''';
          tablo.Query5.Open;
        except
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' delete from GOREVYORUM where ID in (select MODULID from DOKUMAN where MODUL=210 and ID in (select YER_ID from IMAJ where YERI=1 and ID= &Id)) ',['&Id'] , [ImajID]);    // Tablo1.Fields[0].AsInteger
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' delete from DOKUMAN where ID in (select YER_ID from IMAJ where YERI=1 and ID= &Id) ',['&Id'] , [ImajID]);Tablo1.Fields[0].AsInteger;
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' delete from IMAJ  where ID= &Id ',['&Id'] , [ImajID]);// Tablo1.Fields[0].AsInteger
          showmessage('Doküman eklemede hata oluþtu!');
          fs.Free;
          //Stream_.Free;
          CompressedStream_.Free;
          Result:=False;
          exit;
        end;

        //Tablo.TablodanSorguAc(5,' DECLARE @SONUC varbinary(MAX) exec sp_Imaj_Okuma '+Tablo1.Fields[0].AsString+' ,@SONUC OUTPUT select BELGE=@SONUC, BELGEADI='''+ExtractFileExt(DosyaAdi)+'''' );
        if KutuktenOku(Tablo.Query5, 'BELGE',ExtractFileExt(DosyaAdi), False)='' then begin

           Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' delete from DOKUMAN where ID in (select YER_ID from IMAJ where YERI=1 and ID= &Id) ',['&Id'] , [Tablo1.Fields[0].AsInteger]);
           Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' delete from IMAJ  where ID= &Id ',['&Id'] , [Tablo1.Fields[0].AsInteger]);
            showmessage('Doküman eklemede hata oluþtu!');
              fs.Free;
              //Stream_.Free;
              CompressedStream_.Free;
              Result:=False;
              exit;
        end;
        //Kontrol sonu
     end;
  except
      ShowMessage('Dosya kaydedilemedi');
      fs.Free;
      //Stream_.Free;
      CompressedStream_.Free;
      Result:=False;
      exit;
  end;

  fs.Free;
  //Stream_.Free;
  CompressedStream_.Free;
  Result:=True;
end;

end.






