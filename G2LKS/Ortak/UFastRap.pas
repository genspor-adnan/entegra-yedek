unit UFastRap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frxClass, frxExportPDF, frxDesgn, DB, ADODB, ExtDlgs,
  frxExportXLS, frxExportMail, frxExportCSV,  frxExportRTF,
  frxExportHTML, Menus, ImgList,FetaClassExtensionsConsts,
  dxSkinsCore,   cxControls, cxContainer, cxEdit, cxTextEdit, cxMemo,
  ECXMLParser, cxGraphics, frxExportImage, cxLookAndFeels,
  cxLookAndFeelPainters, System.ImageList, frxExportBaseDialog;

type
  TFastRaporDlg = class(TForm)
    //frxDesigner1: TfrxDesigner;
    frxReport1: TfrxReport;
    frxPDFExport1: TfrxPDFExport;
    TabYeniAyar: TADOQuery;
    frxHTMLExport1: TfrxHTMLExport;
    frxRTFExport1: TfrxRTFExport;
    frxJPEGExport1: TfrxJPEGExport;
    frxCSVExport1: TfrxCSVExport;
    ImageList1: TImageList;
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    cxMemo1: TcxMemo;
    Tablo1: TADOTable;
    XML: TECXMLParser;
    frxDesigner1: TfrxDesigner;
    frxXLSExport1: TfrxXLSExport;
    frxMailExport1: TfrxMailExport;
    function frxDesigner1SaveReport(Report: TfrxReport;
      SaveAs: Boolean): Boolean;
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }

  public
    { Public declarations }
    EkranAdi, RaporAdi : string;
    procedure DegiskenleriEkle(Frx:TfrxReport = nil);
    procedure FastRapor(Prev: SmallInt; EkranAdi1, RaporAdi1 : String);
    procedure RaporKaydet(frxReport1: TfrxReport);
    procedure RaporOku(var frxReport1: TfrxReport);
    procedure FastReportTextKaydet(DosyaAdi : String; DokumId:Integer); //  RaporAdi1,  EkranAdi1
    procedure FastReportTextOku(EkranAdi1, RaporAdi1, DosyaAdi : String);
    procedure XMLOku(RaporAdi1, DosyaAdi : String);
    procedure FastRaporDesign(EkranAdi1, RaporAdi1, Ver : String; DokumId : Integer; Frx:TfrxReport = nil);
end;

var
  FastRaporDlg: TFastRaporDlg;

    function XMLBolum(FXml : TECXMLParser; DokumId:Integer; TabloAdi:String):Integer;
    procedure XML2Rapor(FXml : TECXMLParser; DokumId : Integer);

implementation

uses Utablo,//,LocOnFly,
//Compress,
ZlibEx,
FetaKurulusSiniflari, FetaClassExtensions, ComCtrls;
{$R *.dfm}

procedure TFastRaporDlg.RaporKaydet(frxReport1: TfrxReport);
var
  Kaynak: TStream;
  Hedef: TStream;
begin
  Kaynak := TMemoryStream.Create;
  Hedef := TMemoryStream.Create;
  frxReport1.Variables.Clear;
  try
    frxReport1.SaveToStream(Kaynak);
    if (Kaynak.Size > 0) then
    begin
      Kaynak.Position := 0;
      ZCompressStream(Kaynak, Hedef);
      Hedef.Position := 0;
      (TabYeniAyar.FieldByName('AYARLAR') as TBlobField).LoadFromStream(Hedef);
    end;
  finally
    Kaynak.Free;
    Hedef.Free;
  end;
end;

procedure TFastRaporDlg.RaporOku(var frxReport1: TfrxReport);
var
  TempStream: TStream;
  Stream2: TStream;
  DegiskenAdList, DegiskenDegerList : TStringList;

  procedure OncekiDegiskenleriKaydet;
  var i : SmallInt;
  begin
     DegiskenAdList := TStringList.Create;
     DegiskenDegerList := TStringList.Create;
     for i := 0 to frxReport1.Variables.Count-1 do begin
       DegiskenAdList.Add( frxReport1.Variables.Items[i].name);
       if frxReport1.Variables.Items[i].value <> Null then
         DegiskenDegerList.Add( frxReport1.Variables.Items[i].value);
     end;
  end;
  procedure OncekiDegiskenleriYukle;
  var i : SmallInt;
      Baslik : string;
  begin
     frxReport1.Variables.Clear;
     Baslik := DegiskenAdList.Strings[0];
     frxReport1.Variables[' '+Baslik] := '';
     for i := 1 to DegiskenAdList.Count-1 do
        frxReport1.Variables.AddVariable(Baslik, DegiskenAdList.Strings[i], DegiskenDegerList.Strings[i]);
     DegiskenAdList.Destroy;
     DegiskenDegerList.Destroy;
  end;
begin
 //A if frxReport1.Variables.Count>0 then //Lokal deðiþkenler varsa diziye alýnýz
 //A    OncekiDegiskenleriKaydet;


  if TabYeniAyar.IsEmpty then begin
    frxReport1.Clear;
    Exit;
  end;
  TempStream := TMemoryStream.Create;
  Stream2 := TMemoryStream.Create;
  try
    TBlobField(FastRaporDlg.TabYeniAyar.FieldByName('AYARLAR')).SaveToStream(Stream2);
    if (Stream2.Size > 0) then begin
      Stream2.Position := 0;
      ZDecompressStream(Stream2, TempStream);
      if TempStream.Size > 0 then begin
        TempStream.Position := 0;
        frxReport1.LoadFromStream(TempStream);
      end;
    end else frxReport1.Clear;
  finally
    TempStream.Free;
    Stream2.Free;
  end;
//  if (frxReport1.Variables.Count>0) and (Assigned(DegiskenAdList)) and (DegiskenAdList <> nil) and (DegiskenAdList.Count>0) then
//A  if (DegiskenAdList <> nil) and (DegiskenAdList.Count>0) then
//A     OncekiDegiskenleriYukle;  //Lokal deðiþkenler tekrar yüklenir
end;

procedure TFastRaporDlg.FastRapor(Prev: SmallInt; EkranAdi1, RaporAdi1 : String);
var
  i:integer;
  FlNm:string;
    procedure YeniRapor;
    var YeniDokId : Integer;
    begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,
        ' insert into DOKUMLER(RAPORADI,MODUL,GRUBU,SAYAC,EKLEYEN ) '+
        ' Values (&RaporAdi1, ''-'', &EkranAdi1,0,&Ekleyen)', ['&RaporAdi1','&EkranAdi1','&Ekleyen'],[RaporAdi1,EkranAdi1,Kullanan]);
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := ' select @@IDENTITY from DOKUMLER ';
        Tablo.Query1.Open;
        YeniDokId := Tablo.Query1.Fields[0].AsInteger;

      Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,
        ' insert into AYARLARYENI (DOKUMID,EKLEYEN ) '+
        ' Values (&YeniDokId, &Ekleyen)',['&YeniDokId','&Ekleyen'],[YeniDokId, Kullanan]);
    end;

    procedure AyarTablosunuAc;
    begin
      TabYeniAyar.Close;
      TabYeniAyar.SQL.Text := 'SELECT * FROM AYARLARYENI A inner join DOKUMLER D on A.DOKUMID=D.ID WHERE D.RAPORADI = '''+RaporAdi+''' and ';
      if EkranAdi = 'DokumDlg' then
         TabYeniAyar.SQL.Add('D.MODUL <> ''-'' ')
      else
         TabYeniAyar.SQL.Add('D.GRUBU = '''+EkranAdi+''' ');
      TabYeniAyar.Open;
    end;
begin
  RaporAdi := RaporAdi1;
  EkranAdi := EkranAdi1;
  AyarTablosunuAc;
  if TabYeniAyar.RecordCount > 0 then begin

    RaporOku(frxReport1);
    DegiskenleriEkle;
    frxReport1.FileName := EkranAdi1 + '.' + RaporAdi1 + '.fr3';
    frxReport1.PrepareReport(True);
// yazýcý ayarlanýr
    frxReport1.PrintOptions.ShowDialog := (TabYeniAyar.FieldByName('YAZICI').AsString='')or(TabYeniAyar.FieldByName('YAZICI').AsString='Dialog');
    if (TabYeniAyar.FieldByName('YAZICI').AsString<>'')and(TabYeniAyar.FieldByName('YAZICI').AsString<>'Dialog')and(TabYeniAyar.FieldByName('YAZICI').AsString<>'Default') then begin
       frxReport1.PrintOptions.Printer := TabYeniAyar.FieldByName('YAZICI').AsString;
       frxReport1.SelectPrinter;
    end;
    case Prev of
      0: frxReport1.ShowReport();
      1: begin
           frxReport1.PrintOptions.Copies := StrToIntDef(TabYeniAyar.FieldByName('KOPYASAY').AsString,1);
           frxReport1.Print;
         end;
      2: frxReport1.Export(frxPDFExport1);
      3: frxReport1.Export(frxRTFExport1);
      4: frxReport1.Export(frxXLSExport1);
      5: frxReport1.Export(frxCSVExport1);
      6: frxReport1.Export(frxHTMLExport1);
      8: frxReport1.Export(frxJPEGExport1);
//      8: frxReport1.Export(frxTXTExport1);
      9: frxReport1.Export(frxMailExport1);
     10:begin
         frxJPEGExport1.DefaultPath:=GetEnvironmentVariable('Temp');
         frxJPEGExport1.FileName:=StringReplace (EkranAdi, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+ '.' + StringReplace (RaporAdi, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+FormatDateTime('yyyymmddhhnnss',Tablo.GENINI.BuguntrhSaat)+'.jpg';
         FastRaporDlg.frxJPEGExport1.ShowDialog:=False;
         frxReport1.Export(frxJPEGExport1);
         FastRaporDlg.frxJPEGExport1.ShowDialog:=True;
        end;
     11:begin
            for i:=1 to frxReport1.PreviewPages.Count do begin
              if i>1 then begin
                frxPDFExport1.ShowDialog:=False;
                frxPDFExport1.FileName:=StringReplace(FlNm,'.pdf','_',[])+inttostr(i)+'.pdf';
              end;
              frxPDFExport1.PageNumbers:=inttostr(i);
              frxReport1.Export(frxPDFExport1);
              if i=1 then
                FlNm := frxPDFExport1.FileName;
            end;
            frxPDFExport1.ShowDialog:=True;
        end;
    end;
    
  end else if MessageDlg('Döküm/Rapor ayarlarý bulunamadý. Oluþturulsun mu?', mtConfirmation, [mbYes, mbNo], 0) = mrYES then begin
      YeniRapor;
      AyarTablosunuAc;
      frxReport1.FileName := EkranAdi1 + '.' + RaporAdi1 + '.fr3';
      frxReport1.DesignReport;
  end;
end;

procedure TFastRaporDlg.DegiskenleriEkle(Frx:TfrxReport = nil);
var
    i : SmallInt;
begin
  if Frx=nil then
    Frx:=frxReport1;

  Frx.Variables.Clear;
  Frx.Variables[' Döküm Deðiþkenleri'] := '';
  // Klasöre deðiþkenleri tanýmla
  Frx.Variables.AddVariable('Döküm Deðiþkenleri','Kullanýcý Kodu',Kullanan + #13#10);
  Frx.Variables.AddVariable('Döküm Deðiþkenleri','Kullanýcý Adý',KullanAdi + #13#10);
  Frx.Variables.AddVariable('Döküm Deðiþkenleri','Entegra','Gen Entegre Ýþletme Bilgi Yönetim Sistemleri'#13#10);
  Frx.Variables.AddVariable('Döküm Deðiþkenleri','Kurum Adý', Tablo.TabBizim.FieldByName('FIRMA').AsString + #13#10);
  Frx.Variables.AddVariable('Döküm Deðiþkenleri','Rapor Adý',RaporAdi + #13#10);
  for i := 0 to DokumDegiskenListesi.Count-1 do  //sýrayla dökümdeki koþullarý da ekleyelim
    Frx.Variables.AddVariable('Döküm Deðiþkenleri', copy(DokumDegiskenListesi.Strings[i], 1, Pos('$@$', DokumDegiskenListesi.Strings[i])-1),copy(DokumDegiskenListesi.Strings[i], Pos('$@$', DokumDegiskenListesi.Strings[i])+3, 255)+ #13#10);
  DokumDegiskenListesi.Clear;
end;

procedure TFastRaporDlg.FastRaporDesign(EkranAdi1, RaporAdi1, Ver : String; DokumId : Integer ; Frx:TfrxReport = nil);
begin
  if Frx=nil then
    Frx:=frxReport1;
  RaporAdi := RaporAdi1;
  EkranAdi := EkranAdi1;
  TabYeniAyar.Close;
  TabYeniAyar.SQL.Text := 'SELECT * FROM AYARLARYENI WHERE DOKUMID='+IntToStr(DokumId);//EKRAN='''+EkranAdi+''' and RAPORADI = '''+RaporAdi+''' ';
  TabYeniAyar.Open;
  RaporOku(frxReport1); //Ayarlar okunduðunda deðiþkenler sýfýrlanýr

  Frx.FileName := EkranAdi1 + '.' + RaporAdi1 + '.fr3';
  Frx.Tag := DokumId; //DokumId'yi burda tutalým ki ayarlarý save ettiðimizde yeni kayýtsa dokumýd'ye girelim
  Frx.ReportOptions.VersionRelease := Ver;

  DegiskenleriEkle(Frx);
  Frx.DesignReport;
end;

function TFastRaporDlg.frxDesigner1SaveReport(Report: TfrxReport; SaveAs: Boolean): Boolean;
  function VersiyonGetir(Ver:string) : string;
  var i : SmallInt;
  begin
     if Ver = '' then
        Result := '1.1'
     else begin
        i := StrToIntDef(Copy(Ver,pos('.', Ver)+1),10);
        Inc(i);
        Result := Copy(Ver,1,pos('.', Ver)-1)+'.'+IntToStr(i);
     end;
  end;
begin
   if TabYeniAyar.RecordCount > 0 then
      TabYeniAyar.edit
   else begin
      TabYeniAyar.Append;
      TabYeniAyar.FieldByName('DOKUMID').AsInteger := frxReport1.Tag;//EkranAdi;
   end;
   RaporKaydet(frxReport1);
   TabYeniAyar.Post;
   Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, ' update DOKUMLER set VERSIYON='''+VersiyonGetir(frxReport1.ReportOptions.VersionRelease)+'''  where ID=&id ',['&id'],[frxReport1.Tag]);
end;




function XMLBolum(FXml : TECXMLParser; DokumId:Integer; TabloAdi:String):Integer;
var
 i, Say : Integer;
// RaporAdi : Variant;
 fld : TField;
 stream : TMemoryStream;
 a : TXMLItem;
begin
// RaporAdi := RaporAdi1;
 //Tablo1.TableName := TabloAdi;
 Tablo.TablodanSorguAc(9, 'select * from '+TabloAdi+' where ID='+IntToStr(DokumId));
 Say := 1;
 while True do begin
     a := Fxml.Root.NamedItem[TabloAdi + IntToStr(Say)];
     if a.Count > 0 then begin
         if (TabloAdi = 'DOKUMLER')and(DokumId>0) then
             Tablo.Query9.edit //daha önceden varsa güncelleme
         else
             Tablo.Query9.Append;
         if TabloAdi = 'DOKUMLER' then begin
            //Tablo.Query9.FieldByName('RAPORADI').AsString := RaporAdi   //sadece dokumde raporadý var
            //a := Fxml.Root.NamedItem['DOKUMLER1'];
            if a[0].Name = 'RAPORADI' then
               Tablo.Query9.FieldByName('RAPORADI').AsString := a[0].Text
            else if a[1].Name = 'RAPORADI' then
               Tablo.Query9.FieldByName('RAPORADI').AsString := a[1].Text;
         end else
            Tablo.Query9.FieldByName('DOKUMID').AsInteger := DokumId;  // ayarlar ve koþullar dökümlere baðlý; buraya önce eklenmiþ olan dokumid si veririz
         for i := 0 to a.Count - 1 do begin
             fld := Tablo.Query9.FieldByName(a[i].Name);
             if fld.FieldName = 'RAPORADI' then Continue;
             if (fld.IsBlob) then begin
              stream := TMemoryStream.Create;
              try
                stream.FromHexString(a[i].Text);
                stream.Position := 0;
                if (fld.FieldName='SQL')or(fld.FieldName='COMBOICERIK') then begin
                  with TStreamReader.Create(stream,TEncoding.UTF8) do
                  try
                    fld.AsString := ReadToEnd;
                  finally
                    Free;
                  end;
                end else
                  TBlobField(fld).LoadFromStream(stream);
              finally
                stream.Free;
              end;
             end else if (fld.DataType = ftDateTime) then begin
               if Pos(FormatSettings.DateSeparator, a[i].text)<1 then //eðer bilgisayarda tarih ayracý / ama gelen datada . ise
                  if FormatSettings.DateSeparator='.' then
                     a[i].text := StringReplace(a[i].text,'/','.',[rfReplaceAll])
                  else
                     a[i].text := StringReplace(a[i].text,'.','/',[rfReplaceAll]);
               fld.AsString := a[i].text;
             end else
               fld.AsString := a[i].text;
         end;
         Tablo.Query9.Post;
         Inc(say);
     end
     else
       Break;
 end;
 if TabloAdi = 'DOKUMLER' then  //döküm tablosuna eklendikten sonra ID döndürelerek
    result := Tablo.Query9.FieldByName('ID').AsInteger;
 //Tablo1.Close;
end;

procedure XML2Rapor(FXml : TECXMLParser; DokumId : Integer);
var xmlstream : TStringStream;
begin
      //DokumId Onceden belli ise yani sýfýrdan büyükse döküm üzerinde update yapýyoruz
      DokumId := XMLBolum(FXml, DokumId,'DOKUMLER');
      XMLBolum(FXml, DokumId,'AYARLARYENI');
      XMLBolum(FXml, DokumId,'KOSULLAR');
  // end;
end;


procedure TFastRaporDlg.XMLOku(RaporAdi1, DosyaAdi : String);
var DokumId : Integer;
    a : TXMLItem;
     function DahaOncedenVarMi : Boolean;
     var Ad, Grubu : string[50];
     begin    //döküm alýyoruz ama daha önceden kayýtlý mý kontrol edelim
          a := xml.Root.NamedItem['DOKUMLER1'];
          if a.Count < 1 then begin
             showmessage(DosyaAdi+' Geçersiz rapor formatý!');
             Result := False;
          end;

          if a[0].Name = 'RAPORADI' then
             Ad := a[0].Text;
          if a[1].Name = 'GRUBU' then //bu varsa ekran dökümü
             Grubu := a[1].Text
          else if a[1].Name = 'MODUL' then //bu varsa genel dökümdür
             Grubu := '';
          Tablo.TablodanSorguAc(1,'select ID from DOKUMLER where RAPORADI = '''+Ad+''' and isnull(GRUBU,'''')='''+Grubu+'''');
          if Tablo.Query1.recordcount > 0 then begin
             if Application.MessageBox('Bu döküm zaten mevcut. Üzerine yazýlsýn mý?', 'Onay', MB_YESNO) = IDYES then begin
                Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, 'DELETE FROM KOSULLAR WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
                Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, 'DELETE FROM AYARLARYENI WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
                Veritabani.BasitKomutÇalýþtýr(Tablo.cnn, 'DELETE FROM DOKUMLER WHERE ID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
                Result := True
             end
             else
              Result := False
          end
          else
              Result := True;
     end;
begin
   xml.LoadFromFile(DosyaAdi);
   if DahaOncedenVarMi then begin
      DokumId := XMLBolum(xml,0, 'DOKUMLER');
      XMLBolum(xml,DokumId, 'AYARLARYENI');
      XMLBolum(xml,DokumId,'KOSULLAR');
   end;
end;

procedure TFastRaporDlg.FastReportTextKaydet( DosyaAdi : String; DokumId:Integer);// EkranAdi1, RaporAdi1,
  procedure XMLYaz;
       procedure XMLBolum(TabloAdi, IDSI:String; BaslAlani : SmallInt);
       var
         say, i : Integer;
         baslik,a : TXMLItem;
         stream : TMemoryStream;
       begin
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text := 'SELECT * FROM '+TabloAdi+' WHERE '+IDSI+' = '+IntToStr(DokumId);
//         if TabloAdi = 'AYARLARYENI' then
//            Tablo.Query1.SQL.Add( ' and EKRAN='''+EkranAdi1+''' ');
         Tablo.Query1.Open;
         say := 1;
         while not Tablo.Query1.eof do begin
             //a := xml.Root.NamedItem[TabloAdi];
           {  baslik := xml.Root.NamedItem['root'];
             with baslik.New do begin
                   Name := TabloAdi+IntToStr(Say);
                   Text := '';
             end; }

             a := xml.Root.NamedItem[TabloAdi+IntToStr(Say)];
             for i := BaslAlani to Tablo.Query1.FieldCount-1 do     //ID ve DOKUMID alanlarýný almamak için BASLID kullanýyoruz
                if Tablo.Query1.Fields[i].AsString <> '' then
                    with a.New do begin
                      Name := Tablo.Query1.Fields[i].FieldName;
                      if Tablo.Query1.Fields[i].IsBlob then begin
                        stream := TMemoryStream.Create;
                        try
                          TBlobField(Tablo.Query1.Fields[i]).SaveToStream(stream);
                          stream.Position := 0;
                          Text := stream.ToHexString(24);
                        finally
                          stream.Free;
                        end;
                      end else
                        Text := Tablo.Query1.Fields[i].AsString;
                    end;
            Tablo.Query1.Next;
            Inc(say);
         end;
       end;
  begin
      cxMemo1.Lines.SaveToFile(DosyaAdi);
      xml.LoadFromFile(DosyaAdi);
      XMLBolum('DOKUMLER','ID',1);
      XMLBolum('AYARLARYENI','DOKUMID',2);
      XMLBolum('KOSULLAR','DOKUMID',2);
      xml.SaveToFile(DosyaAdi);
  end;
begin
//  RaporAdi := RaporAdi1;
//  EkranAdi := EkranAdi1;
//  TabYeniAyar.Close;
//  TabYeniAyar.SQL.Text := 'SELECT * FROM AYARLARYENI WHERE EKRAN='''+EkranAdi+''' and RAPORADI = '''+RaporAdi+''' ';
//  TabYeniAyar.Open;
//  RaporOku(frxReport1);
  XMLYaz;
  //frxReport1.saveToFile(DosyaAdi) ;
end;

procedure TFastRaporDlg.FastReportTextOku(EkranAdi1, RaporAdi1, DosyaAdi : String);
begin
  EkranAdi := EkranAdi1;
  RaporAdi := RaporAdi1;
  TabYeniAyar.Close;
  TabYeniAyar.SQL.Text := 'SELECT * FROM AYARLARYENI WHERE EKRAN='''+EkranAdi+''' and RAPORADI = '''+RaporAdi+''' ';
  TabYeniAyar.Open;
  if TabYeniAyar.recordcount > 0 then
    raise exception.create('Ayný isimde rapor zaten var!');
  frxReport1.LoadFromFile(DosyaAdi);
  frxDesigner1SaveReport(frxReport1, False);
end;
procedure TFastRaporDlg.FormCreate(Sender: TObject);
begin
   //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   frxReport1.EngineOptions.UseGlobalDataSetList := False;
end;

end.
