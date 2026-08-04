unit UFastRap;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, frxClass, frBaseGraphicsTypes, frxExportPDF, frxDesgn, DB, FireDAC.Comp.Client, ExtDlgs,UDokum,
  frxExportXLS, frxExportMail, frxExportCSV,  frxExportRTF,
  frxExportHTML, Menus, ImgList,URaporAraclari,FetaClassExtensionsConsts,
  dxSkinsCore,   cxControls, cxContainer, cxEdit, cxTextEdit, cxMemo,
  ECXMLParser, dxSkinLondonLiquidSky, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  frxExportImage, dxSkinOffice2013White, dxSkinLiquidSky, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  System.ImageList, System.RegularExpressions, TypInfo, frCoreClasses, frxFDComponents, frxADOComponents,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, frxSmartMemo; //   frxExportImage,

type
  TFastRaporDlg = class(TForm)
    //frxDesigner1: TfrxDesigner;
    frxReport1: TfrxReport;
    TabYeniAyar: TFDQuery;
    ImageList1: TImageList;
    pmDokumAyarlar: TPopupMenu;
    mnuAyarlar: TMenuItem;
    MenuItem1: TMenuItem;
    mnuVarsayilanYap: TMenuItem;
    mnuKopyala: TMenuItem;
    mnuAdDegistir: TMenuItem;
    mnuSil: TMenuItem;
    MenuItem2: TMenuItem;
    mnuDokumKaydet: TMenuItem;
    mnuDokumAl: TMenuItem;
    MenuItem3: TMenuItem;
    mnuYeniRapor: TMenuItem;
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    cxMemo1: TcxMemo;
    Tablo1: TFDTable;
    XML: TECXMLParser;
    frxDesigner1: TfrxDesigner;
    function frxDesigner1SaveReport(Report: TfrxReport;
      SaveAs: Boolean): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure mnuAyarlarClick(Sender: TObject);
    procedure mnuDokumKaydetClick(Sender: TObject);
    procedure mnuDokumAlClick(Sender: TObject);
    procedure mnuSilClick(Sender: TObject);
    procedure mnuAdDegistirClick(Sender: TObject);
    procedure mnuVarsayilanYapClick(Sender: TObject);
    procedure mnuYeniRaporClick(Sender: TObject);
    procedure mnuKopyalaClick(Sender: TObject);
    procedure RaporSecClick(Sender: TObject);



  private
    { Private declarations }

  public
    { Public declarations }
    EkranAdi, RaporAdi : string;
    FiligranYazi : string; //Tek seferlik taslak/filigran yazisi; FastRapor calistiginda tuketilir ve temizlenir
    procedure DegiskenleriEkle(Frx:TfrxReport = nil);
    function FastRapor(Prev: SmallInt; EkranAdi1, RaporAdi1 : String; PDFYol:String=''):String;
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
FetaKurulusSiniflari, FetaClassExtensions, ComCtrls, UGirisKutusuEx, UGenelAnaSekmeFrame,
UVeriMotor;
{$R *.dfm}

procedure TFastRaporDlg.RaporKaydet(frxReport1: TfrxReport);
var
  Kaynak: TStream;
  Hedef: TStream;
  Q: TFDQuery;
  DokumID: Integer;
  VarMi: Boolean;
begin
  Kaynak := TMemoryStream.Create;
  Hedef := TMemoryStream.Create;
  Q := TFDQuery.Create(nil);
  frxReport1.Variables.Clear;
  try
    DokumID := frxReport1.Tag;
    frxReport1.SaveToStream(Kaynak);
    if (Kaynak.Size > 0) then
    begin
      Kaynak.Position := 0;
      ZCompressStream(Kaynak, Hedef);
      Hedef.Position := 0;

      Q.Connection := Tablo.FDCnn;
      Q.SQL.Text := 'select ID from AYARLARYENI where DOKUMID = :DOKUMID';
      Q.ParamByName('DOKUMID').AsInteger := DokumID;
      Q.Open;
      VarMi := not Q.IsEmpty;
      Q.Close;

      if VarMi then
        Q.SQL.Text := 'update AYARLARYENI set AYARLAR = :AYARLAR, DEGISTIREN = :KULLANAN, DEGISTIRMETARIHI = ' + DbSimdi + ' where DOKUMID = :DOKUMID'
      else
        Q.SQL.Text := 'insert into AYARLARYENI (DOKUMID, AYARLAR, EKLEYEN, EKLEMETARIHI) values (:DOKUMID, :AYARLAR, :KULLANAN, ' + DbSimdi + ')';
      Q.ParamByName('DOKUMID').AsInteger := DokumID;
      Q.ParamByName('KULLANAN').AsInteger := StrToIntDef(Kullanan, 0);
      Q.ParamByName('AYARLAR').LoadFromStream(Hedef, ftBlob);
      Q.ExecSQL;
    end;
  finally
    Q.Free;
    Kaynak.Free;
    Hedef.Free;
  end;
end;

procedure TFastRaporDlg.RaporOku(var frxReport1: TfrxReport);
var
  TempStream: TStream;
  Stream2: TStream;
  FlNm, DumpDir: string;
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
 //A if frxReport1.Variables.Count>0 then //Lokal değişkenler varsa diziye alınız
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
        with TStringList.Create do
        try
          LoadFromStream(TempStream);
          // Sablona GOMULU veritabani baglantilarini pasiflestir: eski tasarimlarda
          // TfrxADODatabase Connected="True" + eski musteri sunucusunun baglanti dizesi
          // kayitli kalabiliyor -> yuklerken ADO baglanmaya calisir, DBNETLIB
          // "SQL Server yok veya erisim engellendi" ile onizleme patlar. Rapor verisi
          // zaten uygulamanin dataset'lerinden gelir; gomulu baglanti kalintidir.
          Text := TRegEx.Replace(Text,
            '(<Tfrx(ADO|FD)Database\b[^>]*?)\sConnected="True"', '$1 Connected="False"',
            [roIgnoreCase]);
          Text := TRegEx.Replace(Text,
            '(<Tfrx(ADO|FD)Database\b[^>]*?)\sLoginPrompt="True"', '$1 LoginPrompt="False"',
            [roIgnoreCase]);
          // FireDAC report definitions are kept as-is; only unstable visual metadata is stripped.
          Text := TRegEx.Replace(Text, '\sPropData="[^"]*"', '', [roIgnoreCase]);
          Text := TRegEx.Replace(Text, '\sStyle="[^"]*"', '', [roIgnoreCase]);
          Text := TRegEx.Replace(Text, '\sFrame\.Typ="[^"]*"', '', [roIgnoreCase]);
          Text := TRegEx.Replace(Text, '\sFont\.Style="[^"]*"', '', [roIgnoreCase]);
          Text := TRegEx.Replace(Text, '\sFrame\.Style="[^"]*"', '', [roIgnoreCase]);
          Text := TRegEx.Replace(Text, '\sFrame\.Width="[^"]*"', '', [roIgnoreCase]);
          Text := TRegEx.Replace(Text, '\sFont\.Charset="[^"]*"', '', [roIgnoreCase]);
          TempStream.Size := 0;
          SaveToStream(TempStream);
          DumpDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Temp';
          ForceDirectories(DumpDir);
          FlNm := IncludeTrailingPathDelimiter(DumpDir) + 'fr_last_load.fr3';
          try
            TempStream.Position := 0;
            with TFileStream.Create(FlNm, fmCreate) do
            try
              CopyFrom(TempStream, 0);
            finally
              Free;
            end;
          except
          end;
        finally
          Free;
        end;

        TempStream.Position := 0;
        try
          frxReport1.LoadFromStream(TempStream);
        except
          on E: Exception do begin
            DumpDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Temp';
            ForceDirectories(DumpDir);
            FlNm := IncludeTrailingPathDelimiter(DumpDir) + 'fr_load_invalid.fr3';
            try
              TempStream.Position := 0;
              with TFileStream.Create(FlNm, fmCreate) do
              try
                CopyFrom(TempStream, 0);
              finally
                Free;
              end;
            except
            end;
            raise Exception.Create('UFastRap LoadFromStream error: ' + E.Message + ' | dump: ' + FlNm);
          end;
        end;
      end;
    end else frxReport1.Clear;
  finally
    TempStream.Free;
    Stream2.Free;
  end;
//  if (frxReport1.Variables.Count>0) and (Assigned(DegiskenAdList)) and (DegiskenAdList <> nil) and (DegiskenAdList.Count>0) then
//A  if (DegiskenAdList <> nil) and (DegiskenAdList.Count>0) then
//A     OncekiDegiskenleriYukle;  //Lokal değişkenler tekrar yüklenir
end;

function TFastRaporDlg.FastRapor(Prev: SmallInt; EkranAdi1, RaporAdi1 : String; PDFYol:String=''):String;
var
  i: integer;
  LFiligran: string;
  WMPage: TfrxReportPage;
  WMMemo: TfrxMemoView;
  FlNm, DumpDir: string;
  PDFExport: TfrxPDFExport;
  RTFExport: TfrxRTFExport;
  XLSExport: TfrxXLSExport;
  CSVExport: TfrxCSVExport;
  HTMLExport: TfrxHTMLExport;
  MailExport: TfrxMailExport;
  JPGExport: TfrxJPEGExport;
  procedure YeniRapor;
  var YeniDokId : Integer;
  begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      ' insert into DOKUMLER(RAPORADI,MODUL,GRUBU,SAYAC,EKLEYEN ) '+
      ' Values (&RaporAdi1, ''-'', &EkranAdi1,0,&Ekleyen)', ['&RaporAdi1','&EkranAdi1','&Ekleyen'],[RaporAdi1,EkranAdi1,Kullanan]);
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' select @@IDENTITY from DOKUMLER ';
      Tablo.Query1.Open;
      YeniDokId := Tablo.Query1.Fields[0].AsInteger;

    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
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
  Result := '';
  LFiligran := FiligranYazi;  //tek seferlik kullan; baska raporlara sizmasin diye hemen temizle
  FiligranYazi := '';
  RaporAdi := RaporAdi1;
  EkranAdi := EkranAdi1;
  AyarTablosunuAc;
  if TabYeniAyar.RecordCount > 0 then begin

    RaporOku(frxReport1);
    try
      frxReport1.EnabledDataSets.Add(Tablo.frxBizim);
    except
    end;
    DegiskenleriEkle;
    frxReport1.FileName := EkranAdi1 + '.' + RaporAdi1 + '.fr3';
    try
      frxReport1.PrepareReport(True);
    except
      on E: Exception do begin
        FlNm  := '';
        try
          DumpDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Temp';
          ForceDirectories(DumpDir);
          FlNm := IncludeTrailingPathDelimiter(DumpDir) + 'fr_invalid_' +
            StringReplace(EkranAdi1 + '_' + RaporAdi1, ' ', '_', [rfReplaceAll]) + '.fr3';
          frxReport1.SaveToFile(FlNm);
        except
          FlNm := '';
        end;
        if FlNm <> '' then
          raise Exception.Create('UFastRap PrepareReport error [' + EkranAdi1 + '/' + RaporAdi1 + ']: ' + E.Message + ' | dump: ' + FlNm)
        else
          raise Exception.Create('UFastRap PrepareReport error [' + EkranAdi1 + '/' + RaporAdi1 + ']: ' + E.Message);
      end;
    end;
// yazıcı ayarlanır
    frxReport1.PrintOptions.ShowDialog := (TabYeniAyar.FieldByName('YAZICI').AsString='')or(TabYeniAyar.FieldByName('YAZICI').AsString='Dialog');
    if (TabYeniAyar.FieldByName('YAZICI').AsString<>'')and(TabYeniAyar.FieldByName('YAZICI').AsString<>'Dialog')and(TabYeniAyar.FieldByName('YAZICI').AsString<>'Default') then begin
       frxReport1.PrintOptions.Printer := TabYeniAyar.FieldByName('YAZICI').AsString;
       frxReport1.SelectPrinter;
    end;
    //Taslak filigrani: hazirlanmis sayfalara capraz yazi ekle (yalnizca PDF: 2,11 ve HTML: 7,17)
    if (LFiligran <> '') and (Prev in [2, 7, 11, 17]) then
      for i := 0 to frxReport1.PreviewPages.Count - 1 do begin
        WMPage := frxReport1.PreviewPages.Page[i];
        WMMemo := TfrxMemoView.Create(WMPage);
        WMMemo.Parent := WMPage;
        WMMemo.CreateUniqueName;
        WMMemo.Left := 0;
        WMMemo.Top := 0;
        WMMemo.Width := WMPage.Width;
        WMMemo.Height := WMPage.Height;
        WMMemo.Text := LFiligran;
        WMMemo.Font.Name := 'Arial';
        WMMemo.Font.Size := 60;
        WMMemo.Font.Color := clSilver;
        WMMemo.Font.Style := [fsBold];
        WMMemo.HAlign := haCenter;
        WMMemo.VAlign := vaCenter;
        WMMemo.Rotation := 45;
        WMMemo.Color := clNone;
        WMMemo.Frame.Typ := [];
        frxReport1.PreviewPages.ModifyPage(i, WMPage);
      end;

    case Prev of
      0: try
           frxReport1.ShowReport();
         except
           on E: Exception do
             raise Exception.Create('UFastRap ShowReport error [' + EkranAdi1 + '/' + RaporAdi1 + ']: ' + E.Message);
         end;
      1: begin
           frxReport1.PrintOptions.Copies := StrToIntDef(TabYeniAyar.FieldByName('KOPYASAY').AsString,1);
           frxReport1.Print;
         end;
      2: try
           PDFExport:=TfrxPDFExport.Create(nil);
           if PDFYol<>'' then begin
              PDFExport.ShowDialog := False;
              PDFExport.ShowProgress := False;
              PDFExport.FileName := PDFYol;//'c:\report.pdf';
           end else begin
              PDFExport.ShowProgress := True;
              PDFExport.OverwritePrompt := True;
           end;
           frxReport1.Export(PDFExport);  //(frxPDFExport);
           Result := PDFExport.FileName;
         finally
           FreeAndNil(PDFExport);
         end;
      3: try
           RTFExport:=TfrxRTFExport.Create(nil);
           //PDFExport.ShowDialog := False;
           RTFExport.ShowProgress := True;
           RTFExport.OverwritePrompt := True;
           //PDFExport.FileName := 'c:\report.pdf';
           frxReport1.Export(RTFExport);  //(frxPDFExport);
           Result := RTFExport.FileName;
         finally
           FreeAndNil(RTFExport);
         end;
      4: try
           XLSExport:=TfrxXLSExport.Create(nil);
           //PDFExport.ShowDialog := False;
           XLSExport.ShowProgress := True;
           XLSExport.OverwritePrompt := True;
           //PDFExport.FileName := 'c:\report.pdf';
           frxReport1.Export(XLSExport);  //(frxPDFExport);
           Result := XLSExport.FileName;
         finally
           FreeAndNil(XLSExport);
         end;
      5: try
           CSVExport:=TfrxCSVExport.Create(nil);
           //PDFExport.ShowDialog := False;
           CSVExport.ShowProgress := True;
           CSVExport.OverwritePrompt := True;
           //PDFExport.FileName := 'c:\report.pdf';
           frxReport1.Export(CSVExport);  //(frxPDFExport);
           Result := CSVExport.FileName;
         finally
           FreeAndNil(CSVExport);
         end;
      7: try
           HTMLExport:=TfrxHTMLExport.Create(nil);
           //PDFExport.ShowDialog := False;
           HTMLExport.ShowProgress := True;
           HTMLExport.OverwritePrompt := True;
           //PDFExport.FileName := 'c:\report.pdf';
           frxReport1.Export(HTMLExport);  //(frxPDFExport);
           Result := HTMLExport.FileName;
         finally
           FreeAndNil(HTMLExport);
         end;
      8: try
           JPGExport:=TfrxJPEGExport.Create(nil);
           //JPGExport.ShowDialog := False;
           JPGExport.ShowProgress := True;
           JPGExport.OverwritePrompt := True;
           //JPGExport.FileName := 'c:\report.pdf';
           frxReport1.Export(JPGExport);  //(frxPDFExport);
           Result := JPGExport.FileName;
         finally
           FreeAndNil(JPGExport);
         end;
      9: try
           MailExport:=TfrxMailExport.Create(nil);
           //PDFExport.ShowDialog := False;
           MailExport.ShowProgress := True;
           MailExport.OverwritePrompt := True;
           //PDFExport.FileName := 'c:\report.pdf';
           frxReport1.Export(MailExport);  //(frxPDFExport);
           Result := MailExport.FileName;
         finally
           FreeAndNil(MailExport);
         end;
     10: begin
           try
             JPGExport:=TfrxJPEGExport.Create(nil);
             JPGExport.DefaultPath:=GetEnvironmentVariable('Temp');
             JPGExport.OverwritePrompt := False;
             JPGExport.FileName:=StringReplace (EkranAdi, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+ '.' + StringReplace (RaporAdi, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+FormatDateTime('yyyymmdd',Tablo.GENINI.BuguntrhSaat)+'.jpg';
             JPGExport.ShowDialog:=False;
             frxReport1.Export(JPGExport);
             Result := JPGExport.FileName;
           finally
             FreeAndNil(JPGExport);
           end;
         end;
     11:begin
          for i:=1 to frxReport1.PreviewPages.Count do begin
            try
              PDFExport:=TfrxPDFExport.Create(nil);
              PDFExport.ShowProgress := True;
              PDFExport.OverwritePrompt := True;
              if i = 1 then begin
                PDFExport.ShowDialog := True;
                PDFExport.PageNumbers:=inttostr(i);
                frxReport1.Export(PDFExport);
                FlNm := PDFExport.FileName;
                Result := PDFExport.FileName;
              end else begin
                PDFExport.ShowDialog := False;
                PDFExport.FileName := StringReplace(FlNm,'.pdf','_',[])+inttostr(i)+'.pdf';
                PDFExport.PageNumbers:=inttostr(i);
                frxReport1.Export(PDFExport);
              end
            finally
              FreeAndNil(PDFExport);
            end;
          end;
        end;
     17:begin
         try
           HTMLExport:=TfrxHTMLExport.Create(nil);
           HTMLExport.ShowProgress := True;
           HTMLExport.OverwritePrompt := True;
           HTMLExport.DefaultPath:=GetEnvironmentVariable('Temp');
           HTMLExport.FileName:=StringReplace (EkranAdi, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+ '.' + StringReplace (RaporAdi, ' ' , '_' ,[RfReplaceAll, rfIgnoreCase])+FormatDateTime('yyyymmddhhnnss',Tablo.GENINI.BuguntrhSaat)+'.html';
           HTMLExport.ShowDialog:=False;
           frxReport1.Export(HTMLExport);
           Result := HTMLExport.FileName;
         finally
           FreeAndNil(HTMLExport);
         end;

       end;
    end;

  end else if MessageDlg('Döküm/Rapor ayarları bulunamadı. Oluşturulsun mu?', mtConfirmation, [mbYes, mbNo], 0) = mrYES then begin
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
  Frx.Variables[' Döküm Değişkenleri'] := '';
  // Klasöre değişkenleri tanımla
  Frx.Variables.AddVariable('Döküm Değişkenleri','Kullanıcı Kodu',Kullanan + #13#10);
  Frx.Variables.AddVariable('Döküm Değişkenleri','Kullanıcı Adı',KullanAdi + #13#10);
  Frx.Variables.AddVariable('Döküm Değişkenleri','Entegra','Gen Entegre İşletme Bilgi Yönetim Sistemleri'#13#10);
  Frx.Variables.AddVariable('Döküm Değişkenleri','Kurum Adı', Tablo.TabBizim.FieldByName('FIRMA').AsString + #13#10);
  Frx.Variables.AddVariable('Döküm Değişkenleri','Rapor Adı',RaporAdi + #13#10);
  for i := 0 to DokumDegiskenListesi.Count-1 do  //sırayla dökümdeki koşulları da ekleyelim
    Frx.Variables.AddVariable('Döküm Değişkenleri', copy(DokumDegiskenListesi.Strings[i], 1, Pos('$@$', DokumDegiskenListesi.Strings[i])-1),copy(DokumDegiskenListesi.Strings[i], Pos('$@$', DokumDegiskenListesi.Strings[i])+3, 255)+ #13#10);
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
  RaporOku(frxReport1); //Ayarlar okunduğunda değişkenler sıfırlanır

  Frx.FileName := EkranAdi1 + '.' + RaporAdi1 + '.fr3';
  Frx.Tag := DokumId; //DokumId'yi burda tutalım ki ayarları save ettiğimizde yeni kayıtsa dokumıd'ye girelim
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
   RaporKaydet(frxReport1);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update DOKUMLER set VERSIYON='''+VersiyonGetir(frxReport1.ReportOptions.VersionRelease)+'''  where ID=&id ',['&id'],[frxReport1.Tag]);
   if TabYeniAyar.Active then
     TabYeniAyar.Refresh;
end;

procedure TFastRaporDlg.mnuAdDegistirClick(Sender: TObject);
var
  PM : TPopupMenu;
  dokumAdi : Variant;
  EkranAdi,YeniRaporAdi,EskiRaporAdi: string;
  Dlg : TComponent;
Begin
    Dlg := pmDokumAyarlar.PopUpComponent.Owner;
    dokumAdi := TToolButton(Dlg.FindComponent('YaziciYaz')).Caption;
    if TGirisKutusuEx.BilgiAlEx('Döküm/Rapor Ad Değiştir',
       TGirdiDenetimleri.Create.Edit('Yeni Adı',@dokumAdi)) = mrOk then begin
       if Trim(dokumAdi) = '' then
        MessageDlg('Döküm/Rapor adı boş olamaz!',mtError,[mbOK],0)
       else begin { Normal Rapor }
        EkranAdi:=TForm(Dlg).Name;
        YeniRaporAdi:= Trim(dokumAdi);
        EskiRaporAdi:=TToolButton(Dlg.FindComponent('YaziciYaz')).Caption;
        TRaporAraclari.RaporAdDegistir(EkranAdi,YeniRaporAdi,EskiRaporAdi);

        TToolButton(Dlg.FindComponent('YaziciYaz')).Caption := dokumAdi;
        //YazdirmaBilgileriniYenile(FFrameBilgi.AktifIcerik)

       end;
    end;
end;

procedure TFastRaporDlg.mnuAyarlarClick(Sender: TObject);
var
   EkranAdi, raporAdi : string;
   Dlg : TComponent;
begin
   Dlg := pmDokumAyarlar.PopUpComponent.Owner;
   frxReport1.DataSets.Clear;
   EkranAdi := TForm(Dlg).Name;
   raporAdi := TToolButton(Dlg.FindComponent('YaziciYaz')).Caption;
   FastRaporDesign(EkranAdi, raporAdi,'', 0);
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
            //Tablo.Query9.FieldByName('RAPORADI').AsString := RaporAdi   //sadece dokumde raporadı var
            //a := Fxml.Root.NamedItem['DOKUMLER1'];
            if a[0].Name = 'RAPORADI' then begin
               Tablo.Query9.FieldByName('RAPORADI').AsString := a[0].Text;
               Tablo.Query9.FieldByName('DURUM').AsInteger := 9;
            end
            else if a[1].Name = 'RAPORADI' then
               Tablo.Query9.FieldByName('RAPORADI').AsString := a[1].Text;
         end else
            Tablo.Query9.FieldByName('DOKUMID').AsInteger := DokumId;  // ayarlar ve koşullar dökümlere bağlı; buraya önce eklenmiş olan dokumid si veririz
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
               if Pos(FormatSettings.DateSeparator, a[i].text)<1 then //eğer bilgisayarda tarih ayracı / ama gelen datada . ise
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
      //DokumId Onceden belli ise yani sıfırdan büyükse döküm üzerinde update yapıyoruz
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
     begin    //döküm alıyoruz ama daha önceden kayıtlı mı kontrol edelim
          a := xml.Root.NamedItem['DOKUMLER1'];
          if a.Count < 1 then begin
             showmessage(DosyaAdi+' Geçersiz rapor formatı!');
             Result := False;
          end;

          if a[1].Name = 'RAPORADI' then
             Ad := a[1].Text;
          if a[2].Name = 'GRUBU' then //bu varsa ekran dökümü
             Grubu := a[2].Text
          else if a[2].Name = 'MODUL' then //bu varsa genel dökümdür
             Grubu := '';
          Tablo.TablodanSorguAc(1,'select ID from DOKUMLER where RAPORADI = '''+Ad+''' and isnull(GRUBU,'''')='''+Grubu+'''');
          if Tablo.Query1.recordcount > 0 then begin
             if Application.MessageBox('Bu döküm zaten mevcut. Üzerine yazılsın mı?', 'Onay', MB_YESNO) = IDYES then begin
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM KOSULLAR WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM AYARLARYENI WHERE DOKUMID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM DOKUMLER WHERE ID = &DID', ['&DID'],[Tablo.Query1.Fields[0].AsInteger]);
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

procedure TFastRaporDlg.mnuDokumAlClick(Sender: TObject);
var
  dokumAdi    : Variant;
  eskiraporAdi , Ekranadi, yeniad: string;
  kaynakDokum : string;
  i : SmallInt;
  Dlg : TComponent;
begin
  Dlg := pmDokumAyarlar.PopUpComponent.Owner;
  EkranAdi := TForm(Dlg).Name ;
  if dlgOpen.Execute then begin
     eskiraporAdi := TToolButton(Dlg.FindComponent('YaziciYaz')).Caption;
     kaynakDokum := ExtractFileName(dlgOpen.FileName);
     i := Pos('.FR3',  UpperCase(kaynakDokum));
     if i > 0 then begin
        kaynakDokum := Copy(kaynakDokum,1,i-1);
        FastRaporDlg.FastReportTextOku(Ekranadi, kaynakDokum,dlgOpen.FileName);
        TPopupMenu(dlg.FindComponent('PopupMenuYaz')).Items.ItemOperation(moAdd, kaynakDokum, RaporSecClick);
     end;
  end;
end;


procedure TFastRaporDlg.mnuDokumKaydetClick(Sender: TObject);
var
  dokumAdi : Variant;
  raporAdi : string;
  Dlg : TComponent;
begin
  Dlg := pmDokumAyarlar.PopUpComponent.Owner;
  raporAdi := TToolButton(Dlg.FindComponent('YaziciYaz')).Caption;
  dokumadi := TForm(Dlg).Name;
  dlgSave.FileName := raporAdi + '.fr3';
  if dlgSave.Execute then begin
    FastRaporDlg.FastReportTextKaydet(dlgSave.FileName,0); // dokumadi,raporAdi
  end;
end;

procedure TFastRaporDlg.RaporSecClick(Sender: TObject);
var
  s : String;
  yy : TToolButton;
  Dlg : TComponent;
begin
  Dlg := pmDokumAyarlar.PopUpComponent.Owner;
  yy := TToolButton(dlg.FindComponent('YaziciYaz'));
  s := TMenuItem(Sender).CaptionShortCutLess;
  TMenuItem(Sender).Caption := yy.Caption;
  yy.Caption := s;
end;

procedure TFastRaporDlg.mnuKopyalaClick(Sender: TObject);
var
  yeniad : string;
  dokumAdi : Variant;
  kaynakDokum : string;
  Dlg : TComponent;
  dokumEkran : TDokumDlg;
begin
//  if not FFrameBilgi.AktifIcerikYazdirmaDestekli then Exit;
    Dlg := pmDokumAyarlar.PopUpComponent.Owner;
    dokumEkran := TDokumDlg(Dlg);

  kaynakDokum := TToolButton(Dlg.FindComponent('YaziciYaz')).Caption;
  dokumAdi := kaynakDokum + '1';
  if TGirisKutusuEx.BilgiAlEx('Döküm/Rapor Kopyalama', TGirdiDenetimleri.Create.Edit('Yeni Döküm Adı',@dokumAdi)) = mrOk then begin
    if Trim(dokumAdi) = '' then
      MessageDlg('Döküm/Rapor adı boş olamaz!',mtError,[mbOK],0)
    else begin
      { Normal Rapor }
      TRaporAraclari.RaporKopyala( 0,dokumAdi); //  TForm(Dlg).Name, kaynakDokum,
      TPopupMenu(Dlg.FindComponent('PopupMenuYaz')).Items.ItemOperation(moAdd, dokumAdi, RaporSecClick);
    end
  end;
    //YazdirmaBilgileriniYenile(FFrameBilgi.AktifIcerik);
end;


procedure TFastRaporDlg.mnuSilClick(Sender: TObject);
var
  PM : TPopupMenu;
  dokumAdi : Variant;
  raporAdi,EkranAdi : string;
  Dlg : TComponent;
   // s : String;
begin
  //if not FFrameBilgi.AktifIcerikYazdirmaDestekli then Exit;
  Dlg := pmDokumAyarlar.PopUpComponent.Owner;
  PM := TPopupMenu(dlg.FindComponent('PopupMenuYaz'));
  if MessageDlg('Geçerli dökümü/raporu silmek istiyor musunuz?', mtConfirmation,[mbYes,mbNo],0) = mrNo then Exit
  else begin
     raporadi:= TToolButton(Dlg.FindComponent('YaziciYaz')).Caption ;
     EkranAdi := TForm(Dlg).Name;
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE AYARLARYENI WHERE EKRAN=&ekran AND RAPORADI = &raporadi',['&raporadi','&ekran'],[raporAdi,EkranAdi]);
  end;
  if pm.Items.Count>4 then begin
     TToolButton(Dlg.FindComponent('YaziciYaz')).Caption := PM.Items[5].Caption;
     PM.Items.Delete(5);
     //YazdirmaBilgileriniYenile(FFrameBilgi.AktifIcerik);
  end;
End;


procedure TFastRaporDlg.mnuVarsayilanYapClick(Sender: TObject);
Var
  Dlg : TComponent;
  ekranadi, raporadi : string;
begin
  Dlg := pmDokumAyarlar.PopUpComponent.Owner;
  EkranAdi := TForm(Dlg).Name;
  raporAdi := TToolButton(Dlg.FindComponent('YaziciYaz')).Caption;
//  if not FFrameBilgi.AktifIcerikYazdirmaDestekli then Exit;
  TRaporAraclari.RaporVarsayilanYap(EkranAdi,raporAdi);
end;

procedure TFastRaporDlg.mnuYeniRaporClick(Sender: TObject);
var
  dokumAdi : Variant;
  TB : TToolButton;
  raporAdi, EkranAdi: string;
  Dlg : TComponent;
begin
//  if not FFrameBilgi.AktifIcerikYazdirmaDestekli then Exit;
  dokumAdi := 'YeniRapor';
  Dlg := pmDokumAyarlar.PopUpComponent.Owner;
  if  TGirisKutusuEx.BilgiAlEx('Yeni Rapor',
      TGirdiDenetimleri.Create.Edit('Yeni Rapor Adı',@dokumAdi)) = mrOk then begin
      TRaporAraclari.YeniRapor(TForm(Dlg).Name,dokumAdi);
      //YazdirmaBilgileriniYenile(FFrameBilgi.AktifIcerik);
      //FFrameBilgi.AktifIcerik.AktifRaporAdi := dokumAdi;
      //Önce eski dökümü aşağı menüye indirelim
      TB := TToolButton(TForm(Dlg));
      TPopupMenu(TForm(Dlg)).Items.ItemOperation(moAdd, TB.Caption, RaporSecClick);
      TB.Caption := dokumAdi;
      mnuAyarlar.Click;
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
             for i := BaslAlani to Tablo.Query1.FieldCount-1 do     //ID ve DOKUMID alanlarını almamak için BASLID kullanıyoruz
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
    raise exception.create('Aynı isimde rapor zaten var!');
  frxReport1.LoadFromFile(DosyaAdi);
  frxDesigner1SaveReport(frxReport1, False);
end;
procedure TFastRaporDlg.FormCreate(Sender: TObject);
begin
   //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   TabYeniAyar.Connection := Tablo.FDCnn;
   Tablo1.Connection := Tablo.FDCnn;
   frxReport1.EngineOptions.UseGlobalDataSetList := False;
end;

end.












