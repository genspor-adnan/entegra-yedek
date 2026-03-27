unit URapSyf;
{$H+}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Printers, ExtCtrls, ComCtrls, DB, ADODB, DBTables, quickrpt, Qrctrls, JPEG, qrpdffilt,
  EanQr, EanSpecs,QRExport, UPrinter, {TeeProcs, TeEngine, Chart, DBChart, Series,} UPreview,
  EanKod, EanDB, EanDBQR, clipbrd, StdCtrls, QRBarCode , Barcode ;
   //pQRBarCode,pQRDBBarcode;    {DBarcode,}{DBarQrp,}

const                         
  BandSayisi = 30;
type
  TRapSyf = class(TForm)
    TabKosBic: TADODataSet;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure DENEMEx(sender: TObject);
  public
    { Public declarations }
    query: TADOQuery;
    BandSay: Integer;
    QRBnd: array[1..BandSayisi] of TQRCustomBand;
    RaporSyf: TQuickRep;
    EkranAdi: string;
    MyDataSets: TList;
    RapTabAYAR: TADOQuery;
    Dosyano, GelisNo, Kartno: string[16];
    procedure MakeItalic(sender: TObject; Value: string);
    procedure BeforeAlanPrint(sender: TObject; var Value: string);
    procedure BeforeBandPrint(Sender: TQRCustomBand; var PrintBand: Boolean);
    procedure AfterBandPrint(Sender: TQRCustomBand; BandPrinted: Boolean);
    procedure BeforePrint(Sender: TCustomQuickRep; var PrintReport: Boolean);

    function DokumYap(mPrevMi1: smallint; mEkranAdi: string): integer;
    function TabloBul(TabloAd: string): TComponent;
    function BandBul(BandNo: string): TQRCustomBand;
    function CntrlBul(CntrlNo: string): TQRPrintable;
    procedure GrafikHemogram;
    procedure RaporSyfPreview(Sender: TObject);
    function CreateRotatedFont(Font: TFont; Degrees: Integer): HFONT;
    procedure QLabel1Print(sender: TObject;
      var Value: string);
    procedure  QuickRepApplyPrinterSettings(Sender: TObject; var Cancel: Boolean; DevMode: Pointer);
  end;

var
  RapSyf: TRapSyf;
  GlobalRichEdit: TRichEdit;
  GlobalFiyat: string;
  GlobalQuery: TADOQuery;
  GlobalImage: TImage;

  OnIzForm: TPreview;

  Dokuluyor: Boolean;
  QRBndSay: array[1..BandSayisi] of Integer;
  QRBndSaySil: array[1..BandSayisi] of Integer;
  KopyaSay: Integer;
  ResimDizi: array[11..48] of TBitmap;
  BandSaySil: boolean;
  printeradi:string;

  DublexYazdir : Boolean = False;

type
  TMyEndPage = procedure(Sender: TQuickRep);

var
  GlobalEndPage: TMyEndPage;
  Raporadi: string;
  FDuplex : Smallint;//--------------------------------->
  FBin : integer;//-------------------------------------->


procedure RaporDokumBasla(TabloYeri: TComponent);

implementation
uses qrprntr, UTablo;
var
  RapTabloGost: TComponent;
  i, mPrevmi: smallint;
  InetPubYolu: string;

{$R *.DFM}

procedure TRapSyf.QLabel1Print(sender: TObject;
  var Value: string);
begin
  TQRLabel(Sender).Font.Handle := CreateRotatedFont(TQRDBText(Sender).Font, 90);
end;

function TRapSyf.CreateRotatedFont(Font: TFont; Degrees: Integer): HFONT;
var
  LF: TLogFont;
begin
  FillChar(LF, SizeOf(LF), #0);
  with LF do
  begin
    lfHeight := Font.Height;
    lfWidth := 0;
    lfEscapement := Degrees * 10;
    lfOrientation := 0;
    if fsBold in Font.Style then
      lfWeight := FW_BOLD
    else
      lfWeight := FW_NORMAL;
    lfItalic := Byte(fsItalic in Font.Style);
    lfUnderline := Byte(fsUnderline in Font.Style);
    lfStrikeOut := Byte(fsStrikeOut in Font.Style);
    lfCharSet := DEFAULT_CHARSET;
    StrPCopy(lfFaceName, Font.Name);
    lfQuality := DEFAULT_QUALITY;

    lfOutPrecision := OUT_DEFAULT_PRECIS;
    lfClipPrecision := CLIP_DEFAULT_PRECIS;
    case Font.Pitch of
      fpVariable: lfPitchAndFamily := VARIABLE_PITCH;
      fpFixed: lfPitchAndFamily := FIXED_PITCH;
    else
      lfPitchAndFamily := DEFAULT_PITCH;
    end;
  end;
  Font.Size := 5; //---
  Result := CreateFontIndirect(LF);

end;

function SayiYazi(Sayi: Extended): string;
const
  Yuzler: array[1..3, 0..9] of string = (
    ('', 'YÜZ', 'ÝKÝYÜZ', 'ÜÇYÜZ', 'DÖRTYÜZ', 'BEÞYÜZ', 'ALTIYÜZ', 'YEDÝYÜZ', 'SEKÝZYÜZ', 'DOKUZYÜZ'),
    ('', 'ON', 'YÝRMÝ', 'OTUZ', 'KIRK', 'ELLÝ', 'ALTMIÞ', 'YETMÝÞ', 'SEKSEN', 'DOKSAN'),
    ('', 'BÝR', 'ÝKÝ', 'ÜÇ', 'DÖRT', 'BEÞ', 'ALTI', 'YEDÝ', 'SEKÝZ', 'DOKUZ'));
  Binler: array[1..8] of string =
  ('KATTRÝLYAR', 'TRÝLYAR', 'KATTRÝLYON', 'TRÝLYON', 'MÝLYAR', 'MÝLYON', 'BÝN', '');
var
  FloR: TFloatRec;
  FloV: TFloatValue;
  i, y, z: Integer;
  Parca: string;
  ASt: string[24];
  EkSt: string[26];
  AraSonuc, Sonuc: string;
  n, hane: Integer;
begin
  Sonuc := '';
  FloV := fvExtended;
  FloatToDecimal(FloR, Sayi, FloV, 18, 0);
  for I := 0 to length(flor.Digits)-1 do
    ASt :=ast + inttostr(FloR.Digits[i]); // gözden geçir muhammet

  n := length(ASt);
  if FloR.Exponent <> Length(ASt) then
  begin
    EkSt := '';
    FillChar(EkSt, FloR.Exponent - n + 1, '0');
    EkSt[0] := AnsiChar(FloR.Exponent - n);
    ASt := ASt + EkSt;
  end;
  n := Length(ASt);
  if n < 24 then
  begin
    EkSt := '';
    FillChar(EkSt, 24 - n + 1, '0');
    EkSt[0] := AnsiChar(24 - n);
    ASt := EkSt + ASt;
  end;
  n := Length(ASt);
  i := 1;
  hane := 1;
  while i < n do
  begin
    Parca := Copy(ASt, i, 3);
    AraSonuc := '';
    for y := 1 to 3 do
    begin
      z := StrToInt(Copy(Parca, y, 1));
      AraSonuc := AraSonuc + Yuzler[y, z];
    end;
    if AraSonuc <> '' then AraSonuc := AraSonuc + Binler[hane];
    if AraSonuc = 'BÝRBÝN' then AraSonuc := 'BÝN';
    i := i + 3;
    Inc(hane);
    Sonuc := Sonuc + AraSonuc;
  end;
  SayiYazi := Sonuc;
end;

function UpStr(St: string): string;
var
  K: Integer;
begin
  for k := 1 to Length(St) do
    St[k] := UpCase(St[k]);
  UpStr := St;
end;


procedure RaporuJpegOlarakKaydet(QuickRep: TQuickRep; DosyaAdi: string);
var
  JPG: TJPEGImage;
  BMP: TImage;
  mf: TMetafile;
  i: integer;
begin
  QuickRep.Prepare;

  JPG := TJpegImage.Create;
  BMP := TImage.Create(nil);
  i := 1;
  bmp.Height := 0;
  while i <= QuickRep.QRPrinter.PageCount do
  begin
    JPG := TJpegImage.Create;
    BMP := TImage.Create(nil);
    mf := QuickRep.Printer.GetPage(i);
    bmp.Height := bmp.Height + mf.Height;
    bmp.Width := mf.Width;
    bmp.Canvas.Draw(0, bmp.Height - mf.Height, mf);
    JPG.Assign(bmp.picture.bitmap);
    JPG.SaveToFile(DosyaAdi + '-' + inttostr(i) + '.jpg');
    JPG.Free;
    bmp.Free;
    i:=i+1;
  end;
end;

procedure TRapSyf.MakeItalic(sender: TObject; Value: string);
var
  BulTable: TADOTable;
begin
  if ((Value = 'IF(RAKAMSONUC>0,RAKAMSONUC,YAZISONUC)') or
    (Value = 'BIRIM') or
    (Value = 'NDACIKLAMA') or
    (Value = 'ND')) then
  begin
    BulTable := TADOTable(TabloBul('LABDOKUM'));
    if (BulTable <> nil) then
      if (BulTable.FieldByName('NDACIKLAMA').AsString = 'SI') then
        TQRDbText(sender).Font.Style := TQRDbText(sender).Font.Style + [fsItalic]
      else
        TQRDbText(sender).Font.Style := TQRDbText(sender).Font.Style - [fsItalic];
  end;
end;

procedure TRapSyf.BeforeAlanPrint(sender: TObject; var Value: string);
begin
  if (Sender is TQRDbText) then
    MakeItalic(Sender, TQRDbText(Sender).DataField)
  else if (Sender is TQRExpr) then
    MakeItalic(Sender, TQRExpr(Sender).Expression);
end;

procedure TRapSyf.BeforePrint(Sender: TCustomQuickRep; var PrintReport: Boolean);
var
  k: Integer;
begin
  for k := 1 to BandSayisi do
    QRBndSay[k] := 0;
  for k := 1 to BandSayisi do
    QRBndSaySil[k] := 0;
  if MyDataSets <> nil then
  begin
    if Raporsyf.alldatasets <> nil then
      for k := 0 to MyDataSets.Count - 1 do
        Raporsyf.alldatasets.Add(MyDataSets.Items[k]);
  end;
end;

{procedure TRapSyf.BeforeBandPrint(Sender: TQRCustomBand;  var PrintBand: Boolean);
Var
   k:Integer;
begin
   For k:=1 to BandSay do
      If Sender.Name = QRBnd[K].Name Then
         Inc(QrBndSay[k]);
   PrintBand:=True;
end;
}

procedure TRapSyf.AfterBandPrint(Sender: TQRCustomBand; BandPrinted: Boolean);
var
  k: integer;
begin
  if not BandSaySil then
    exit;
  if sender is TQRBand then
    if (Sender as TQRBand).BandType = rbGroupFooter then
      for k := 1 to BandSay do
        if QRBnd[K].BandType = rbDetail then
          QRBndSaySil[k] := 0;
end;

procedure TRapSyf.BeforeBandPrint(Sender: TQRCustomBand; var PrintBand: Boolean);
  Procedure cevir(Src:Timage; Dst: TQRImage);
  var x,y: integer;
  begin
//    Dst.Width:= Src.Height;
//    Dst.Height:= Src.Width;
    For x:= 0 to Src.Width-1 do
    begin
      For y:= 0 to Src.Height-1 do
      begin
        Dst.Canvas.Pixels[y,(Src.Width-1)-x]:= Src.Canvas.Pixels[x,y];
      end;
    end;
  end;

  function Esitlik(IlkDeger, SonDeger: string): boolean;
  begin
    if pos('''', SonDeger) > 0 then
      SonDeger := copy(sondeger, 2, length(sondeger) - 2);
    if pos('''', IlkDeger) > 0 then
      IlkDeger := copy(IlkDeger, 2, length(IlkDeger) - 2);
    if ilkdeger = sondeger then
      result := true
    else
      Result := false;
  end;
  function BuyukEsit(IlkDeger, SonDeger: string): boolean;
  begin
    if pos('''', SonDeger) > 0 then
      SonDeger := copy(sondeger, 2, length(sondeger) - 2);
    if pos('''', IlkDeger) > 0 then
      IlkDeger := copy(IlkDeger, 2, length(IlkDeger) - 2);
    if ilkdeger >= sondeger then
      result := true
    else
      Result := false;
  end;
  function KucukEsit(IlkDeger, SonDeger: string): boolean;
  begin
    if pos('''', SonDeger) > 0 then
      SonDeger := copy(sondeger, 2, length(sondeger) - 2);
    if pos('''', IlkDeger) > 0 then
      IlkDeger := copy(IlkDeger, 2, length(IlkDeger) - 2);
    if ilkdeger <= sondeger then
      result := true
    else
      Result := false;
  end;
  function Kucuk(IlkDeger, SonDeger: string): boolean;
  begin
    if pos('''', SonDeger) > 0 then
      SonDeger := copy(sondeger, 2, length(sondeger) - 2);
    if pos('''', IlkDeger) > 0 then
      IlkDeger := copy(IlkDeger, 2, length(IlkDeger) - 2);
    if ilkdeger < sondeger then
      result := true
    else
      Result := false;
  end;
  function Buyuk(IlkDeger, SonDeger: string): boolean;
  begin
    if pos('''', SonDeger) > 0 then
      SonDeger := copy(sondeger, 2, length(sondeger) - 2);
    if pos('''', IlkDeger) > 0 then
      IlkDeger := copy(IlkDeger, 2, length(IlkDeger) - 2);
    if ilkdeger > sondeger then
      result := true
    else
      Result := false;
  end;
  function Arasinda(Deger, IlkDeger, SonDeger: integer): boolean;
  begin
    if (deger >= ilkdeger) and (deger <= sondeger) then
      result := true
    else
      Result := false;
  end;
  function NotEsit(IlkDeger, SonDeger: string): boolean;
  begin
    if ilkdeger <> sondeger then
      result := true
    else
      Result := false;
  end;
var
  k: Integer;
  Ayrac: string;
  YALANADI, YSORGU: string;
  AYYER: byte;
  BulTable: TComponent;
  RenkNe, YRenk, YArka, NYRenk, NYArka: string;
  OzelNe, YOzel: string;
  YFontStyle, NYFontStyle: TFontStyles;
  FontNe, YFontName, NYFontName: string;
  Sonuc: boolean;
  Ara1, Ara2: string;
  AndNerde: integer;
begin
  for k := 1 to BandSay do
    if Sender.Name = QRBnd[K].Name then
    begin
      Inc(QrBndSay[k]);
      Inc(QrBndSaySil[k]);
    end;
//sayýtoyazý
  TabKosBic.Close;
  TabKosBic.CommandText := 'Select * from AYARLAR where RAPORADI=''' + Raporadi + ''' and ALANTURU=''SABÝT'' and ISNULL(TABLO,'''')<>''''';
  TabKosBic.Open;

  while not TabKosBic.Eof do
  begin
    BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
    TQRLabel(FindComponent('B' + TabKosBic.fieldbyname('SIRANO').AsString)).Caption := SayiYazi(TDataSet(BulTable).fieldbyname(TabKosBic.fieldbyname('ALANADI').AsString).AsFloat);
    TabKosBic.Next;
  end;


//barcode lar...
(*  TabKosBic.Close; 16.53 te kapatýldý 3/10 2007
  TabKosBic.CommandText := 'Select * from AYARLAR where RAPORADI=''' + Raporadi + ''' and ALANTURU=''BARKOD''';
  TabKosBic.Open;

  while not TabKosBic.Eof do
  begin
    BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
    //StBarCode1.Code:=TDataSet(BulTable).fieldbyname(TabKosBic.fieldbyname('ALANADI').AsString).AsString;
    TStBarCode(FindComponent('BR' + TabKosBic.fieldbyname('SIRANO').AsString)).Code := TDataSet(BulTable).fieldbyname(TabKosBic.fieldbyname('ALANADI').AsString).AsString;
    Application.ProcessMessages;
//    StBarCode1.CopyToClipboard;
    TStBarCode(FindComponent('BR' + TabKosBic.fieldbyname('SIRANO').AsString)).CopyToClipboard;
    Application.ProcessMessages;
    TQRImage(FindComponent('B' + TabKosBic.fieldbyname('SIRANO').AsString)).Picture.Assign(clipboard);
    Application.ProcessMessages;
    if TabKosBic.FieldByName('YANASIK').AsString ='YAN' then
    begin
      Image1.Height:=TStBarCode(FindComponent('BR' + TabKosBic.fieldbyname('SIRANO').AsString)).Width;
      Application.ProcessMessages;
      Image1.Width:=TStBarCode(FindComponent('BR' + TabKosBic.fieldbyname('SIRANO').AsString)).Height;
      Application.ProcessMessages;
      Image1.Picture.Assign(Clipboard);
      Application.ProcessMessages;
      cevir(Image1, TQRImage(FindComponent('B' + TabKosBic.fieldbyname('SIRANO').AsString)));
      Application.ProcessMessages;
    end;
    TabKosBic.Next;
  end;
*)
//koþullu biçimlendirme....

  if Sender.ClassName <> 'TQRBand' then
    exit;
  PrintBand := True;
  if ((Sender as TQRBand).BandType = rbDetail) or ((Sender as TQRBand).BandType = rbSubDetail) then
  begin
    TabKosBic.Close;
    TabKosBic.CommandText := 'Select * from AYARLAR where RAPORADI=''' + Raporadi + ''' and ALANTURU=''KOSULBICIM''';
    TabKosBic.Open;

    while not TabKosBic.Eof do
    begin
      RenkNe := TabKosBic.fieldbyname('RENK').AsString;
      OzelNe := TabKosBic.fieldbyname('OZELLIK').AsString;
      FontNe := TabKosBic.fieldbyname('FONT').AsString;
      if pos(',', renkne) > 0 then
      begin
        YRenk := copy(renkne, 1, pos(',', renkne) - 1);
        renkne := copy(renkne, pos(',', renkne) + 1, length(renkne) - pos(',', renkne));
      end;
      if pos(',', renkne) > 0 then
      begin
        YArka := copy(renkne, 1, pos(',', renkne) - 1);
        renkne := copy(renkne, pos(',', renkne) + 1, length(renkne) - pos(',', renkne));
      end;
      if pos(',', renkne) > 0 then
      begin
        NYRenk := copy(renkne, 1, pos(',', renkne) - 1);
        renkne := copy(renkne, pos(',', renkne) + 1, length(renkne) - pos(',', renkne));
      end;
      if renkne <> '' then
        NYArka := renkne;
      if pos(',', OzelNe) > 0 then
      begin
        YOzel := copy(OzelNe, 1, pos(',', OzelNe) - 1);
        if YOzel = 'BOLD' then
          YFontStyle := [FSBold]
        else if YOzel = 'ITALIC' then
          YFontStyle := [FSitalic];
        OzelNe := copy(OzelNe, pos(',', OzelNe) + 1, length(OzelNe) - pos(',', OzelNe));
      end;
      if OzelNe <> '' then
      begin
        if OzelNe = 'BOLD' then
          NYFontStyle := [FSBold]
        else if OzelNe = 'ITALIC' then
          NYFontStyle := [FSitalic];
      end;

      if pos(',', Fontne) > 0 then
      begin
        YFontName := copy(Fontne, 1, pos(',', Fontne) - 1);
        Fontne := copy(Fontne, pos(',', Fontne) + 1, length(Fontne) - pos(',', Fontne));
      end;
      if Fontne <> '' then
        NYFontName := Fontne;

      sonuc := false;

      AYYER := pos('>=', TabKosBic.fieldbyname('ALANADI').AsString);
      if AYYER > 0 then
      begin
        BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
        YALANADI := trim(copy(TabKosBic.fieldbyname('ALANADI').AsString, 1, AYYER - 1));
        Ara1 := YALANADI;
        if Pos('T.', YALANADI) > 0 then
          Ara1 := TDataset(BulTable).FieldByName(copy(YALANADI, 3, length(YALANADI) - 2)).asstring;
        YSORGU := copy(TabKosBic.fieldbyname('ALANADI').AsString, AYYER + 2, length(TabKosBic.fieldbyname('ALANADI').AsString) - ayyer - 1);
        Ara2 := YSORGU;
        if pos('T.', YSORGU) > 0 then
          Ara2 := TDataset(BulTable).FieldByName(copy(YSORGU, 3, length(YSORGU) - 2)).asstring;
        sonuc := BuyukEsit(Ara1, Ara2);
      end;

      if AYYER = 0 then
      begin
        AYYER := pos('<=', TabKosBic.fieldbyname('ALANADI').AsString);
        if AYYER > 0 then
        begin
          BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
          YALANADI := trim(copy(TabKosBic.fieldbyname('ALANADI').AsString, 1, AYYER - 1));
          Ara1 := YALANADI;
          if Pos('T.', YALANADI) > 0 then
            Ara1 := TDataset(BulTable).FieldByName(copy(YALANADI, 3, length(YALANADI) - 2)).asstring;
          YSORGU := copy(TabKosBic.fieldbyname('ALANADI').AsString, AYYER + 2, length(TabKosBic.fieldbyname('ALANADI').AsString) - ayyer - 1);
          Ara2 := YSORGU;
          if pos('T.', YSORGU) > 0 then
            Ara2 := TDataset(BulTable).FieldByName(copy(YSORGU, 3, length(YSORGU) - 2)).asstring;
          sonuc := KucukEsit(Ara1, Ara2);
        end;
      end;

      if AYYER = 0 then
      begin
        AYYER := pos('<>', TabKosBic.fieldbyname('ALANADI').AsString);
        if AYYER > 0 then
        begin
          BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
          YALANADI := trim(copy(TabKosBic.fieldbyname('ALANADI').AsString, 1, AYYER - 1));
          Ara1 := YALANADI;
          if Pos('T.', YALANADI) > 0 then
            Ara1 := TDataset(BulTable).FieldByName(copy(YALANADI, 3, length(YALANADI) - 2)).asstring;
          YSORGU := copy(TabKosBic.fieldbyname('ALANADI').AsString, AYYER + 2, length(TabKosBic.fieldbyname('ALANADI').AsString) - ayyer - 1);
          Ara2 := YSORGU;
          if pos('T.', YSORGU) > 0 then
            Ara2 := TDataset(BulTable).FieldByName(copy(YSORGU, 3, length(YSORGU) - 2)).asstring;
          sonuc := NotEsit(Ara1, Ara2);
        end;
      end;

      if AYYER = 0 then
      begin
        AYYER := pos('=', TabKosBic.fieldbyname('ALANADI').AsString);
        if AYYER > 0 then
        begin
          BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
          YALANADI := trim(copy(TabKosBic.fieldbyname('ALANADI').AsString, 1, AYYER - 1));
          Ara1 := YALANADI;
          if Pos('T.', YALANADI) > 0 then
            Ara1 := TDataset(BulTable).FieldByName(copy(YALANADI, 3, length(YALANADI) - 2)).asstring;
          YSORGU := copy(TabKosBic.fieldbyname('ALANADI').AsString, AYYER + 1, length(TabKosBic.fieldbyname('ALANADI').AsString) - ayyer);
          Ara2 := YSORGU;
          if pos('T.', YSORGU) > 0 then
            Ara2 := TDataset(BulTable).FieldByName(copy(YSORGU, 3, length(YSORGU) - 2)).asstring;
          sonuc := Esitlik(Ara1, Ara2);
        end;
      end;

      if AYYER = 0 then
      begin
        AYYER := pos('<', TabKosBic.fieldbyname('ALANADI').AsString);
        if AYYER > 0 then
        begin
          BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
          YALANADI := trim(copy(TabKosBic.fieldbyname('ALANADI').AsString, 1, AYYER - 1));
          Ara1 := YALANADI;
          if Pos('T.', YALANADI) > 0 then
            Ara1 := TDataset(BulTable).FieldByName(copy(YALANADI, 3, length(YALANADI) - 2)).asstring;
          YSORGU := copy(TabKosBic.fieldbyname('ALANADI').AsString, AYYER + 1, length(TabKosBic.fieldbyname('ALANADI').AsString) - ayyer);
          Ara2 := YSORGU;
          if pos('T.', YSORGU) > 0 then
            Ara2 := TDataset(BulTable).FieldByName(copy(YSORGU, 3, length(YSORGU) - 2)).asstring;
          sonuc := Kucuk(Ara1, Ara2);
        end;
      end;
      if AYYER = 0 then
      begin
        AYYER := pos('>', TabKosBic.fieldbyname('ALANADI').AsString);
        if AYYER > 0 then
        begin
          BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
          YALANADI := trim(copy(TabKosBic.fieldbyname('ALANADI').AsString, 1, AYYER - 1));
          Ara1 := YALANADI;
          if Pos('T.', YALANADI) > 0 then
            Ara1 := TDataset(BulTable).FieldByName(copy(YALANADI, 3, length(YALANADI) - 2)).asstring;
          YSORGU := copy(TabKosBic.fieldbyname('ALANADI').AsString, AYYER + 1, length(TabKosBic.fieldbyname('ALANADI').AsString) - ayyer);
          Ara2 := YSORGU;
          if pos('T.', YSORGU) > 0 then
            Ara2 := TDataset(BulTable).FieldByName(copy(YSORGU, 3, length(YSORGU) - 2)).asstring;
          sonuc := Buyuk(Ara1, Ara2);
        end;
      end;

      if AYYER = 0 then
      begin
        AYYER := pos('BETWEEN', UpperCase(TabKosBic.fieldbyname('ALANADI').AsString));
        if AYYER > 0 then
        begin
          BulTable := TabloBul(TabKosBic.FieldByName('TABLO').AsString);
          YALANADI := trim(copy(TabKosBic.fieldbyname('ALANADI').AsString, 1, AYYER - 1));
          if pos('T.', YALANADI) > 0 then
            YALANADI := copy(YALANADI, 3, length(YALANADI) - 2);
          YSORGU := copy(TabKosBic.fieldbyname('ALANADI').AsString, AYYER + 1, length(TabKosBic.fieldbyname('ALANADI').AsString) - ayyer);
          andnerde := pos('AND', UpperCase(TabKosBic.fieldbyname('ALANADI').AsString));
          if AndNerde > 0 then
          begin
            Ara1 := copy(TabKosBic.fieldbyname('ALANADI').AsString, ayyer + 8, AndNerde - (ayyer + 9));
            Ara2 := copy(TabKosBic.fieldbyname('ALANADI').AsString, AndNerde + 4, length(TabKosBic.fieldbyname('ALANADI').AsString) - (AndNerde + 3));
            if pos('''', Ara1) > 0 then
              Ara1 := copy(Ara1, 2, length(Ara1) - 2);
            if pos('''', Ara2) > 0 then
              Ara2 := copy(Ara2, 2, length(Ara2) - 2);
            if pos('''', TDataset(BulTable).FieldByName(YALANADI).AsString) > 0 then
              YSORGU := copy(TDataset(BulTable).FieldByName(YALANADI).AsString, 2, length(TDataset(BulTable).FieldByName(YALANADI).AsString) - 2)
            else
              YSORGU := TDataset(BulTable).FieldByName(YALANADI).AsString;
            if pos('T.', Ara1) > 0 then
              Ara1 := TDataset(BulTable).FieldByName(copy(Ara1, 3, length(Ara1) - 2)).asstring;
            if pos('T.', Ara2) > 0 then
              Ara2 := TDataset(BulTable).FieldByName(copy(Ara2, 3, length(Ara2) - 2)).asstring;
            if pos('T.', YSORGU) > 0 then
              YSORGU := TDataset(BulTable).FieldByName(copy(YSORGU, 3, length(YSORGU) - 2)).asstring;
            if (Ara1 <> '') and (Ara2 <> '') then
              sonuc := Arasinda(strtoint(Ysorgu), strtoint(ara1), strtoint(ara2))
            else
              sonuc := false;
          end
          else
            sonuc := false;
        end;
      end;


      if FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString).ClassName = 'TQRDBText' then
      begin
        if sonuc then
        begin
          if YArka <> '' then
          begin
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Color := StringToColor(YArka);
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Transparent := false;
          end;
          if YRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Font.Color := StringToColor(YRenk);
          if YFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Font.Name := YFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Font.Style := YFontStyle;
        end
        else
        begin
          if NYArka <> '' then
          begin
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Color := StringToColor(NYArka);
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Transparent := false;
          end;
          if NYRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Font.Color := StringToColor(NYRenk);
          if NYFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Font.Name := NYFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBText).Font.Style := NYFontStyle;
        end;
      end
      else if FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString).ClassName = 'TQRLabel' then
      begin
        if sonuc then
        begin
          if YArka <> '' then
          begin
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Color := StringToColor(YArka);
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Transparent := false;
          end;
          if YRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Font.Color := StringToColor(YRenk);
          if YFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Font.Name := YFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Font.Style := YFontStyle;
        end
        else
        begin
          if NYArka <> '' then
          begin
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Color := StringToColor(NYArka);
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Transparent := false;
          end;
          if NYRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Font.Color := StringToColor(NYRenk);
          if NYFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Font.Name := NYFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRLabel).Font.Style := NYFontStyle;
        end;
      end
      else if FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString).ClassName = 'TQRExpr' then
      begin
        if sonuc then
        begin
          if YArka <> '' then
          begin
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Color := StringToColor(YArka);
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Transparent := false;
          end;
          if YRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Font.Color := StringToColor(YRenk);
          if YFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Font.Name := YFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Font.Style := YFontStyle;
        end
        else
        begin
          if NYArka <> '' then
          begin
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Color := StringToColor(NYArka);
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Transparent := false;
          end;
          if NYRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Font.Color := StringToColor(NYRenk);
          if NYFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Font.Name := NYFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRExpr).Font.Style := NYFontStyle;
        end;
      end
      else if FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString).ClassName = 'TQRDBRichText' then
      begin
        if sonuc then
        begin
          if YArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Color := StringToColor(YArka);
          if YRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Font.Color := StringToColor(YRenk);
          if YFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Font.Name := YFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Font.Style := YFontStyle;
        end
        else
        begin
          if NYArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Color := StringToColor(NYArka);
          if NYRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Font.Color := StringToColor(NYRenk);
          if NYFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Font.Name := NYFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRDBRichText).Font.Style := NYFontStyle;
        end;
      end
      else if FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString).ClassName = 'TQRRichText' then
      begin
        if sonuc then
        begin
          if YArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Color := StringToColor(YArka);
          if YRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Font.Color := StringToColor(YRenk);
          if YFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Font.Name := YFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Font.Style := YFontStyle;
        end
        else
        begin
          if NYArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Color := StringToColor(NYArka);
          if NYRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Font.Color := StringToColor(NYRenk);
          if NYFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Font.Name := NYFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRRichText).Font.Style := NYFontStyle;
        end;
      end
      else if FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString).ClassName = 'TQRBand' then
      begin
        if sonuc then
        begin
          if YArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Color := StringToColor(YArka);
          if YRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Font.Color := StringToColor(YRenk);
          if YFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Font.Name := YFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Font.Style := YFontStyle;
        end
        else
        begin
          if NYArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Color := StringToColor(NYArka);
          if NYRenk <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Font.Color := StringToColor(NYRenk);
          if NYFontName <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Font.Name := NYFontName;
          (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRBand).Font.Style := NYFontStyle;
        end
      end
      else if FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString).ClassName = 'TQRShape' then
      begin
        if sonuc then
        begin
          if YArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRShape).Brush.Color := StringToColor(YArka);
        end
        else
        begin
          if NYArka <> '' then
            (FindComponent('B' + TabKosBic.fieldbyname('BANDNO').AsString) as TQRShape).Brush.Color := StringToColor(NYArka);
        end;
      end;
      TabKosBic.Next;
    end;
  end;
end;




function TRapSyf.BandBul(BandNo: string): TQRCustomBand;
var
  Bnd: TQRCustomBand;
  K: Integer;
begin
  Bnd := nil;
  for k := 1 to BandSay do
    if QRBnd[K].Name = 'B' + BandNo then
      Bnd := QRBnd[K];
  BandBul := Bnd;
end;

function TRapSyf.CntrlBul(CntrlNo: string): TQRPrintable;
var
  K, l: Integer;
begin
  CntrlBul := nil;
  for k := 1 to BandSay do
  begin
    for l := 0 to QRBnd[K].ControlCount - 1 do
      if QRBnd[K].Controls[l].Name = 'B' + CntrlNo then
        CntrlBul := TQRPrintable(QRBnd[K].Controls[l]);
  end;
end;

function TRapSyf.TabloBul(TabloAd: string): TComponent;
var
  K: Integer;
begin
  TabloBul := nil;
  if TabloAd = 'SORGU' then
    TabloBul := GlobalQuery
  else
    for k := 0 to RapTabloGost.ComponentCount - 1 do
      if (RapTabloGost.Components[k] is TADOTable) or (RapTabloGost.Components[k] is TADOQuery) then
        if UpStr(RapTabloGost.Components[k].Name) = (UpStr(TabloAd)) then
          TabloBul := RapTabloGost.Components[k];
end;

procedure TRapSyf.DENEMEx(sender: TObject);
begin
  //
end;

procedure TRapSyf.GrafikHemogram;
var
  QCntrlType: TQRNewComponentClass;
  QCntrl: TQRCustomLabel;
  BulTable: TComponent;
  Bnd: TQRCustomBand;
  Oran: Real;
  ss: TStringlist;

  procedure Sayiyaz(x, y: real; s: string; b: tbitmap);
  begin
    b.Canvas.Pixels[round(x), round(y)] := clBlack;
    b.Canvas.Pixels[round(x), round(y) + 1] := clBlack;
    b.Canvas.TextOut(round(x - b.Canvas.TextWidth(S) / 2), round(y) + 3, S);
  end;

  procedure HemogramGrafik(Tetkik: string; st: TStrings; Oran: Real; Bitmap: TBitmap);
  var
    i: integer;
    yy: real;
    dy: real;
    mmGrafik, mmEsikler: TStringList;
  begin
    yy := 3.28125 * oran;
    dy := 1 * oran;
    Bitmap.Width := 0;
    Bitmap.Height := 0;
    Bitmap.Width := round(420 * oran);
    Bitmap.Height := round(300 * oran) + 20;
  (* Burasý hertetkik için farklý olan bir iþ olan aþaðýdaki sayýlarýn *)
  (* yazýlmasý iþlemi yapýlýyor.                                       *)

    if Tetkik = 'WBC' then
    begin
      Sayiyaz(50 * oran, 300 * oran + 2, '50', Bitmap);
      Sayiyaz(100 * oran, 300 * oran + 2, '100', Bitmap);
      Sayiyaz(200 * oran, 300 * oran + 2, '200', Bitmap);
      Sayiyaz(300 * oran, 300 * oran + 2, '300', Bitmap);
      Sayiyaz(400 * oran, 300 * oran + 2, '400', Bitmap);
    end;

    if Tetkik = 'RBC' then
    begin
      Sayiyaz(1.68 * 30 * oran, 300 * oran + 2, '30', Bitmap); // 1.68 Özel Bir Hesaplama Sonucu bulundu ... Þöyleki
      Sayiyaz(1.68 * 100 * oran, 300 * oran + 2, '100', Bitmap); // Scan ettiðim rapordan oranlama ile bulunduç
      Sayiyaz(1.68 * 200 * oran, 300 * oran + 2, '200', Bitmap);
    end;

    if Tetkik = 'PLT' then
    begin
      Sayiyaz(13.5 * 2 * oran, 300 * oran + 2, '2', Bitmap); // 13.5 yukarýdaki usul ile bulundu.
      Sayiyaz(13.5 * 5 * oran, 300 * oran + 2, '5', Bitmap);
      Sayiyaz(13.5 * 10 * oran, 300 * oran + 2, '10', Bitmap);
      Sayiyaz(13.5 * 20 * oran, 300 * oran + 2, '20', Bitmap);
      Sayiyaz(13.5 * 30 * oran, 300 * oran + 2, '30', Bitmap);
    end;


    mmGrafik := TStringList.Create;
    mmEsikler := TStringList.Create;
    mmGrafik.CommaText := st.Values['GRAFÝK'];
    mmEsikler.CommaText := st.Values['EÞÝKLER'];

  (* Aþaðýda Grafiðin çizgileri çizdiriliyor.*)
    Bitmap.Canvas.moveTo(round(420 * oran), round(300 * oran + 2));
    Bitmap.Canvas.LineTo(1, round(300 * oran + 2));
    Bitmap.Canvas.moveTo(1, round(300 * oran + 2));
    Bitmap.Canvas.LineTo(1, 1);
  (******************************************)

  (* Aþaðýda eþikler çizdiriliyor.*)
    Bitmap.Canvas.Pen.Style := psDash; // Çizgi çizgi yapýlýyor.
    for i := 0 to mmEsikler.Count - 1 do
    begin
      Bitmap.Canvas.moveTo(round(yy * StrToInt(mmEsikler[i])), round(300 * oran + 2));
      Bitmap.Canvas.LineTo(round(yy * StrToInt(mmEsikler[i])), 1);
    end;
  (*******************************)

  (* Aþaðýda grafik çizdiriliyor.*)
    Bitmap.Canvas.Pen.Style := psSolid; // Kalem düz yapýlýyor.
    Bitmap.Canvas.moveTo(1, round(300 * oran)); // Baþlangýç koordinatýna konumlanýlýyor.
    for i := 0 to mmGrafik.Count - 1 do
    begin
      Bitmap.Canvas.LineTo(
        round(yy * i) + 1, // Yatay uzaklýk yy katsayýsýyla çarpýlýyor.
        round(300 * oran - dy * StrToInt(mmGrafik[i])));
    end;
  (*******************************)

  end;

begin
  Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

  QCntrlType := TQRImage;
  QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
  with TQRImage(QCntrl) do
  begin
//        Picture.Bitmap := ResimDizi[11];
//        Picture.Bitmap.LoadFromFile('C:\SRC\GEN95\GOZ.BMP');
    Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
    Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
    Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
    Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
    Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);

    if RapTabAYAR.FieldByName('OZELLIK').AsString <> '' then
      Oran := RapTabAYAR.FieldByName('OZELLIK').AsFloat;

    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'select ACIKLAMA2 from LABSONUC where DOSYANO = ''' + Dosyano +
      ''' AND GELISNO = ' + Gelisno + ' AND KARTNO = ' + Kartno +
      ' and KOD=''' + RapTabAYAR.FieldByName('ALANADI').AsString + '''';
    Tablo.Query1.Open;
    ss := TStringlist.Create;
    ss.Assign(Tablo.Query1.Fields[0]);

    ResimDizi[11] := Tbitmap.Create;

    HemogramGrafik(RapTabAYAR.FieldByName('TABLO').AsString, ss, Oran, ResimDizi[11]);
    Picture.Bitmap := ResimDizi[11];
        //stretch := True;
    ss.free;
    ResimDizi[11].free;
  end;
end;

  procedure GetPrinterSettings;
  var
    hDevMode: THandle;
    Device,Driver,Port: array [0..1024] of Char;
    DevMode : PDevMode;
  begin
      Printers.Printer.GetPrinter (Device,Driver,Port,hDevMode);
      FBin := -1;
      if hDevMode <> 0 then
      begin
      DevMode := GlobalLock (hDevMode);
      // here we can catch members of DevMode
      FBin := DevMode^.DMDEFAULTSOURCE;
      FDuplex := DevMode^.dmDuplex;
      GlobalUnlock (hDevMode);
      end;
  end;

  procedure TRapSyf.QuickRepApplyPrinterSettings(Sender: TObject; var Cancel: Boolean; DevMode: Pointer);
  begin
      GetPrinterSettings;
      if DublexYazdir then
        PDevMode(DevMode)^.dmDuplex := 2
      else
        PDevMode(DevMode)^.dmDuplex := 0;
      PDevMode(DevMode)^.dmDefaultSource := FBin;
  end;

function TRapSyf.DokumYap(mPrevMi1: smallint; mEkranAdi: string): integer;
var
  Renk: string[30];
  SayfaAdi, s: string[80];
  procedure SetFont(QCntrlFont: TFont; FontName: string; Punto: Integer; Ozellik, Renk: string);
  var
    Sty: TFontStyles;
  begin
    if FontName <> '' then
      QCntrlFont.Name := FontName;
    if Punto > 0 then
      QCntrlFont.Size := Punto;
    Sty := [];
    if Pos('BOLD', Ozellik) > 0 then
      Sty := Sty + [fsBold];
    if Pos('ITALIK', Ozellik) > 0 then
      Sty := Sty + [fsItalic];
    if Pos('UNDERLINE', Ozellik) > 0 then
      Sty := Sty + [fsUnderline];
    if Pos('NORMAL', Ozellik) > 0 then
      Sty := [];

    QCntrlFont.Style := Sty;
    if Renk <> '' then
    begin
      try
        QCntrlFont.Color := StringToColor(Renk);
      except
        QCntrlFont.Color := clBlack;
      end;
    end;
  end;

  procedure SetCntrl(QCntrl: TQRCustomLabel);
  begin
    with QCntrl do
    begin
      AutoSize := True;
      Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
      if RapTabAYAR.FieldByName('YANASIK').AsString = 'SAÐ' then
        Alignment := taRightJustify
      else if RapTabAYAR.FieldByName('YANASIK').AsString = 'ORT' then
        Alignment := taCenter
      else
        Alignment := taLeftJustify;
      Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
      Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
      if RapTabAYAR.FieldByName('EN').AsString <> '' then
      begin
        Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
        AutoSize := False;
      end;
      if RapTabAYAR.FieldByName('BOY').AsString <> '' then
      begin
        if RapTabAYAR.FieldByName('BOY').AsFloat > 0 then
          Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10)
        else
          AutoStretch := True;
      end;
      Renk := RapTabAYAR.FieldByName('RENK').AsString;
      if pos(',', Renk) > 0 then
      begin
        Color := StringToColor(copy(Renk, pos(',', Renk) + 1, length(Renk) - pos(',', Renk))); // ,clblack
        Renk := copy(Renk, 1, pos(',', Renk) - 1);
      end;
      SetFont(TQRCustomLabel(QCntrl).Font,
        RapTabAYAR.FieldByName('FONT').AsString,
        RapTabAYAR.FieldByName('PUNTO').AsInteger,
        RapTabAYAR.FieldByName('OZELLIK').AsString,
        Renk);

    end;
  end;

  procedure SetRichCntrl(QCntrl: TQRCustomRichText);
  begin
    with QCntrl do
    begin
      Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
      Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
      Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
      if RapTabAYAR.FieldByName('EN').AsString <> '' then
      begin
        Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
      end;
      if RapTabAYAR.FieldByName('BOY').AsString <> '' then
      begin
        Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
        if RapTabAYAR.FieldByName('BOY').AsFloat > 0 then
          Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10)
        else
          AutoStretch := True;
      end;

      SetFont(QCntrl.Font,
        RapTabAYAR.FieldByName('FONT').AsString,
        RapTabAYAR.FieldByName('PUNTO').AsInteger,
        RapTabAYAR.FieldByName('OZELLIK').AsString,
        RapTabAYAR.FieldByName('RENK').AsString);
    end;
  end;

  procedure SayfaAyarlar;
   {TPRINTERSETTINGS }
  var
    Bulundu, k, Yer: Integer;
    St1: string;
    BulTable: TComponent;
    SaklaPS: TQRPaperSize;
    nPrinter:TPrinter;

    function PaperSizeBul(Tur: string): TQRPaperSize;
    begin
      if pos('KULLANICI', Tur) > 0 then
        PaperSizeBul := Custom
      else if (Tur = 'LETTER') or (Tur = 'MEKTUP 21.59X27.94CM') or (Tur = 'FORM 21.59X27.94CM') then
        PaperSizeBul := Letter
      else if Tur = 'LEGAL 21.59X35.56CM' then
        PaperSizeBul := Legal
      else if (Tur = 'A3') or (Tur = 'A3 29.7X42CM') then
        PaperSizeBul := A3
      else if (Tur = 'A4') or (Tur = 'A4 21X29.7CM') then
        PaperSizeBul := A4
      else if (Tur = 'A5') or (Tur = 'A5 14.8X21CM') then
        PaperSizeBul := A5
      else if (Tur = 'B4') or (Tur = 'B4 25X35.4CM') then
        PaperSizeBul := B4
      else if (Tur = 'B5') or (Tur = 'B5 18.2X25.7CM') then
        PaperSizeBul := B5
      else if Tur = 'QUARTO 21.5X27.5CM' then
        PaperSizeBul := QUARTO
      else if Tur = 'UYGULAMA 19X25.4CM' then
        PaperSizeBul := Executive
      else if Tur = 'FOLYO 21.59X25.4CM' then
        PaperSizeBul := Folio
      else if Tur = 'TABLOID 27.94X43.18CM' then
        PaperSizeBul := Tabloid
{          Else If Tur='ZARF-9 9.84X24.13CM' Then
            PaperSizeBul:=Envelope#9
         Else If Tur='ZARF-10 10.47X22.54CM' Then
            PaperSizeBul:=Envelope#10}
      else
        PaperSizeBul := Default
    end;

  var
    prnName : string;

  begin
    if printeradi = '' then
      printeradi := GenRegIni.RegReadString('Yazýcýlar', RapTabAYAR.FieldByName('RAPORADI').AsString + '_Yzc', '', 'C');
    SayfaAdi := GenRegIni.RegReadString('Yazýcýlar', RapTabAYAR.FieldByName('RAPORADI').AsString + '_Syf', '', 'C');
    if SayfaAdi <> '' then
    begin
      SaklaPS := PaperSizeBul(UpStr(SayfaAdi));
      RaporSyf.PrinterSettings.PaperSize := SaklaPS;
      RaporSyf.Page.PaperSize := SaklaPS;
      if SaklaPS = Custom then
      begin
        delete(SayfaAdi, 1, pos(',', SayfaAdi)); //KULLANICI, 15,20
        s := copy(SayfaAdi, 1, pos(',', SayfaAdi) - 1); //15,20
        RaporSyf.Page.Length := StrToInt(s) * 10;
        s := copy(SayfaAdi, pos(',', SayfaAdi) + 1, 100); //15,20
        RaporSyf.Page.Width := StrToInt(s) * 10;
      end;
    end;

    if (SayfaAdi = '') and (RapTabAYAR.FieldByName('TABLO').AsString = 'BOYUT') then
    begin
      SaklaPS := PaperSizeBul(UpStr(RapTabAYAR.FieldByName('ALANADI').AsString));
      RaporSyf.PrinterSettings.PaperSize := SaklaPS;
      RaporSyf.Page.PaperSize := SaklaPS;
      if RapTabAYAR.FieldByName('OZELLIK').AsString <> '' then
        Kopyasay := RapTabAYAR.FieldByName('OZELLIK').AsInteger;
      if SaklaPS = Custom then
      begin
        RaporSyf.Page.Length := RapTabAYAR.FieldByName('BOY').AsFloat * 10;
        RaporSyf.Page.Width := RapTabAYAR.FieldByName('EN').AsFloat * 10;
      end;
      if RapTabAYAR.FieldByName('YANASIK').AsString <> '' then
      begin
        RaporSyf.Page.Orientation := poLandscape;
        RaporSyf.PrinterSettings.Orientation := poLandscape;
      end;
      if RapTabAYAR.FieldByName('BANDNO').AsString <> '' then
        RapSyf.RaporSyf.PrinterSettings.Copies := RapTabAYAR.FieldByName('BANDNO').AsInteger;

    end
    else if RapTabAYAR.FieldByName('TABLO').AsString = 'BOÞLUK' then
    begin
      RaporSyf.Page.LeftMargin := RapTabAYAR.FieldByName('SOL').AsFloat * 10;
      RaporSyf.Page.TopMargin := RapTabAYAR.FieldByName('UST').AsFloat * 10;
      RaporSyf.Page.RightMargin := RapTabAYAR.FieldByName('BOY').AsFloat * 10;
      RaporSyf.Page.BottomMargin := RapTabAYAR.FieldByName('EN').AsFloat * 10;
    end
    else if RapTabAYAR.FieldByName('TABLO').AsString = 'KOLON' then
    begin
      RaporSyf.Page.Columns := RapTabAYAR.FieldByName('BANDNO').AsInteger;
      RaporSyf.Page.ColumnSpace := RapTabAYAR.FieldByName('SOL').AsFloat * 10;
    end
    else if (printeradi = '') and (RapTabAYAR.FieldByName('TABLO').AsString = 'YAZICI') then
    begin
      printeradi := RapTabAYAR.FieldByName('ALANADI').AsString;
      if (mPrevmi = 1) and (Pos('EKRAN',Uppercase(RapTabAYAR.FieldByName('OZELLIK').AsString)) > 0) then
      begin //Print Dialog çaðrýlýyor mu?
        RapSyf.RaporSyf.PrinterSetup;
        if RapSyf.RaporSyf.PrinterSettings.PrinterIndex < 0 then abort;
      end;
      if Pos('DUPLEX',Uppercase(RapTabAYAR.FieldByName('OZELLIK').AsString)) > 0 then begin
        DublexYazdir := True;
      end else DublexYazdir := False;
         //            RapSyf.PrintDialog1.Execute;
            {Application.CreateForm(TPrinterDlg, PrinterDlg);
            for i := 0 to PrinterDlg.ListBox1.Items.Count-1 do
              if pos(printeradi, PrinterDlg.ListBox1.Items[i])>0 then
                 PrinterDlg.ListBox1.ItemIndex := i;

            PrinterDlg.ShowModal;
            KopyaSay := StrToInt(PrinterDlg.Kopya.Text); //Kopyasayýsý
            printeradi := PrinterDlg.ListBox1.Items[PrinterDlg.ListBox1.ItemIndex];

            Yer := Pos(' on ',printeradi);
            If Yer>0 Then
               Delete(printeradi, Yer, Length(printeradi)-Yer+1);

            PrinterDlg.Destroy;
         end;}
    end
    else if RapTabAYAR.FieldByName('TABLO').AsString = 'TABLO' then
    begin
      BulTable := TabloBul(RapTabAYAR.FieldByName('ALANADI').AsString);
      if BulTable <> nil then
      begin
        if MyDataSets = nil then
          MyDataSets := Tlist.Create;
        MyDataSets.Add(TadoDataset(BulTable));
      end;
    end;
    
    prnName := GenRegIni.RegReadString('Muayene\DokumanYazicilari',Raporadi,'','C');
    if (prnName <> '') and (prnName <> '(Yok)') then begin
      RapSyf.RaporSyf.PrinterSettings.PrinterIndex :=
        Printer.Printers.IndexOf(prnName);
    end else begin
      Bulundu := -1;
      for k := 0 to Printer.Printers.Count - 1 do
      begin
        St1 := QRPrinter.Printers.Strings[k];
        Yer := Pos(' on ', St1);
        if Yer > 0 then
          Delete(St1, Yer, Length(St1) - Yer + 1);
        if pos(printeradi, St1) > 0 then
          Bulundu := K;
      end;
      RapSyf.RaporSyf.PrinterSettings.PrinterIndex := Bulundu;
    end;

    {
    Bulundu := -1;
    nPrinter:=TPrinter.Create();
    for k := 0 to nPrinter.Printers.Count - 1 do
    begin
      St1 := nPrinter.Printers[k];
      Yer := Pos(' on ', St1);
      if Yer > 0 then
        Delete(St1, Yer, Length(St1) - Yer + 1);
      if pos(printeradi, St1) > 0 then
        Bulundu := K;
    end;
    nPrinter.Free;
    RapSyf.RaporSyf.PrinterSettings.PrinterIndex := Bulundu;
    }
  end;

  procedure BandAyarlar;
  var
    Tur: TQRBandType;
    Gr1: TQRGroup;
    Gr2: TQRSubDetail;
    Gr3: TQRChildBand;
    BulTable: TComponent;
    Bnd: TQRCustomBand;
  begin
    if RapTabAYAR.FieldByName('TABLO').AsString = 'GRUP' then
    begin
      Gr1 := TQRGroup.Create(RapSyf);
      Gr1.Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
      Gr1.BandType := RbGroupHeader;
      if RapTabAYAR.FieldByName('YANASIK').AsString = 'YSF' then
        Gr1.ForceNewPage := True;

      Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

      Gr1.Parent := RapSyf.RaporSyf;
      if Bnd.BandType = RbDetail then
        Gr1.Master := RapSyf.RaporSyf
      else
        Gr1.Master := TQrSubDetail(Bnd);

      Gr1.Expression := RapTabAYAR.FieldByName('ALANADI').AsString;
      if RapTabAYAR.FieldByName('EN').AsString <> '' then
        Gr1.Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
      if RapTabAYAR.FieldByName('BOY').AsString <> '' then
        Gr1.Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
      if BandSay < BandSayisi then
      begin
        BandSay := BandSay + 1;
        QRBnd[Bandsay] := Gr1;
      end;
    end
    else if RapTabAYAR.FieldByName('TABLO').AsString = 'ARADETAY' then
    begin
      Gr2 := TQRSubDetail.Create(RapSyf);
      Gr2.Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
      Gr2.Parent := RapSyf.RaporSyf;
      Gr2.BandType := rbSubDetail;
      if RapTabAYAR.FieldByName('EN').AsString <> '' then
        Gr2.Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
      if RapTabAYAR.FieldByName('BOY').AsString <> '' then
        Gr2.Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
      BulTable := TabloBul(RapTabAYAR.FieldByName('ALANADI').AsString);
      if BulTable <> nil then
        Gr2.Dataset := TADODataSet(BulTable);
      Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      if Bnd.BandType = RbDetail then
        Gr2.Master := RapSyf.RaporSyf
      else
        Gr2.Master := Bnd;
      if BandSay < BandSayisi then
      begin
        BandSay := BandSay + 1;
        QRBnd[Bandsay] := Gr2;
      end;
    end
    else if RapTabAYAR.FieldByName('TABLO').AsString = 'ÇOCUK' then
    begin
      Gr3 := TQRChildBand.Create(RapSyf);
      Gr3.Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
      Gr3.Parent := RapSyf.RaporSyf;
      Gr3.BandType := rbChild;
      if RapTabAYAR.FieldByName('EN').AsString <> '' then
        Gr3.Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
      if RapTabAYAR.FieldByName('BOY').AsString <> '' then
        Gr3.Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
      Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      if Bnd <> nil then
      begin
        Gr3.ParentBand := Bnd;
        Bnd.HasChild := True;
      end;
      if BandSay < BandSayisi then
      begin
        BandSay := BandSay + 1;
        QRBnd[Bandsay] := Gr3;
      end;
    end
    else
    begin
      if RapTabAYAR.FieldByName('TABLO').AsString = 'GRUPBAÞI' then
        Tur := RbGroupHeader
      else if RapTabAYAR.FieldByName('TABLO').AsString = 'GRUPSONU' then
        Tur := RbGroupFooter
      else if RapTabAYAR.FieldByName('TABLO').AsString = 'SAYFABAÞI' then
      begin
        Tur := RbPageHeader;
        RapSyf.RaporSyf.Options := RapSyf.RaporSyf.Options - [FirstPageHeader];
        if RapTabAYAR.FieldByName('FORMAT').AsString = '' then
          RapSyf.RaporSyf.Options := RapSyf.RaporSyf.Options + [FirstPageHeader];
      end
      else if RapTabAYAR.FieldByName('TABLO').AsString = 'SAYFASONU' then
      begin
        Tur := RbPageFooter;
        RapSyf.RaporSyf.Options := RapSyf.RaporSyf.Options - [LastPageFooter];
        if RapTabAYAR.FieldByName('FORMAT').AsString = '' then
          RapSyf.RaporSyf.Options := RapSyf.RaporSyf.Options + [LastPageFooter];
      end
      else if RapTabAYAR.FieldByName('TABLO').AsString = 'DETAY' then
      begin
        Tur := RbDetail;
        BulTable := TabloBul(RapTabAYAR.FieldByName('ALANADI').AsString);
        if BulTable <> nil then
          RapSyf.RaporSyf.Dataset := TADODataSet(BulTable);
      end
      else if RapTabAYAR.FieldByName('TABLO').AsString = 'RAPORBAÞI' then
      begin
        Tur := RbTitle;
        RapSyf.RaporSyf.Options := RapSyf.RaporSyf.Options - [FirstPageHeader];
      end
      else if RapTabAYAR.FieldByName('TABLO').AsString = 'KOLONBAÞI' then
        Tur := RbColumnHeader
      else if RapTabAYAR.FieldByName('TABLO').AsString = 'RAPORSONU' then
        Tur := RbSummary
      else
        Tur := RbDetail;

      if BandSay < BandSayisi then
      begin
        BandSay := BandSay + 1;
        QRBnd[Bandsay] := RapSyf.RaporSyf.CreateBand(Tur);
        with QRBnd[Bandsay] do
        begin
          Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
          if RapTabAYAR.FieldByName('YANASIK').AsString <> '' then
            AlignToBottom := True;
          if RapTabAYAR.FieldByName('EN').AsString <> '' then
            Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
          if RapTabAYAR.FieldByName('BOY').AsString <> '' then
            Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);

          if RapTabAYAR.FieldByName('RENK').AsString <> '' then
          begin
            try
              Color := StringToColor(RapTabAYAR.FieldByName('RENK').AsString);
            except
              Color := clBlack;
            end;
          end;
        end;
        if RapTabAYAR.FieldByName('TABLO').AsString = 'GRUPSONU' then
        begin
          Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
          if (Bnd is TQRGroup) then
            TQRGroup(Bnd).FooterBand := TQRBand(QRBnd[BandSay]);
          if (Bnd is TQRSubDetail) then
            TQRSubDetail(Bnd).FooterBand := TQRBand(QRBnd[BandSay]);
        end;
        if RapTabAYAR.FieldByName('TABLO').AsString = 'GRUPBAÞI' then
        begin
          Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
          if (Bnd is TQRSubDetail) then
            TQRSubDetail(Bnd).HeaderBand := TQRBand(QRBnd[BandSay]);
        end;
      end;
    end;
    QRBnd[Bandsay].BeforePrint := BeforeBandPrint;
    QRBnd[Bandsay].AfterPrint := AfterBandPrint;
     // QRBnd[Bandsay]. OnStartPage := DENEMEx;
            //RapSyf.RaporSyf.OnStartPage := DENEMEx;
  end;

  procedure SabitAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRCustomLabel;
    Bnd: TQRCustomBand;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRLabel;
      QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
      with TQRLabel(QCntrl) do
      begin
        SetCntrl(QCntrl);
        Transparent := RapTabAYAR.FieldByName('TRANSPARENT').AsBoolean;
        Caption := RapTabAYAR.FieldByName('ALANADI').AsString;
      end;
    end;
  end;

  procedure DikeySabitAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRCustomLabel;
    Bnd: TQRCustomBand;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRLabel;
      QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
      with TQRLabel(QCntrl) do
      begin
        SetCntrl(QCntrl);
        OnPrint := QLabel1Print;
        Transparent := RapTabAYAR.FieldByName('TRANSPARENT').AsBoolean; ;
        Caption := RapTabAYAR.FieldByName('ALANADI').AsString;
      end;
    end;
  end;


  procedure AlanAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRCustomLabel;
    BulTable: TComponent;
    Bnd: TQRCustomBand;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

    BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);

    if (Bnd <> nil) and (BulTable <> nil) then
    begin
      QCntrlType := TQRDbText;
      QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
      with TQRDbText(QCntrl) do
      begin
        Transparent := RapTabAYAR.FieldByName('TRANSPARENT').AsBoolean; ;
        Dataset := TADODataSet(BulTable);
        DataField := RapTabAYAR.FieldByName('ALANADI').AsString;
        SetCntrl(QCntrl);
        Mask := RapTabAYAR.FieldByName('FORMAT').AsString;
        if mEkranAdi = 'Lab_' then
          TQRDbText(QCntrl).OnPrint := BeforeAlanPrint;

      end;
    end;
  end;

  procedure ResimAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRCustomLabel;
    BulTable: TComponent;
    Bnd: TQRCustomBand;
    procedure ResimGoster;
    var
      bmp: TBitmap;
      jpg: TJPEGImage;
      stbmp: TStream;
      stjpg: TStream;
      Tablo1: TADOQuery;
    begin
        {if Tablo.TabKimlik.FieldByName('RESIM').IsNull then begin
           Resim.Picture.Assign(Nil);
           exit;
        end;  }
      jpg := TJPEGImage.Create;
      bmp := TBitmap.Create;
      Tablo1 := TADOQuery(BulTable);
      stjpg := TADOBlobStream.Create(TBlobField(Tablo1.FieldByName(RapTabAYAR.FieldByName('ALANADI').AsString)), bmRead);
      stbmp := TMemoryStream.Create;
      jpg.LoadFromStream(stjpg);
      if Jpg.PixelFormat = jf24bit then
        Bmp.PixelFormat := pf24bit
      else
        Bmp.PixelFormat := pf8bit;
      Bmp.Width := Jpg.Width;
      Bmp.Height := Jpg.Height;
      Bmp.Canvas.Draw(0, 0, Jpg);
      Bmp.SaveToStream(stbmp);
      TQRImage(QCntrl).Picture.Assign(bmp);
      bmp.free;
      jpg.free;
      stjpg.free;
      stbmp.free;
    end;

    procedure ResimGetir;
    var
      Yol: string;
    begin
      yol := ExtractFileDir(Application.ExeName) + '\BMP\';
      QCntrlType := TQRImage;
      QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
      with TQRImage(QCntrl) do
      begin
        if RapTabAYAR.FieldByName('ALANADI').AsString <> '' then
          Picture.Bitmap := ResimDizi[RapTabAYAR.FieldByName('ALANADI').AsInteger]
        else
//          Picture.Bitmap.LoadFromFile(yol);     := GlobalImage.Picture.Bitmap;
          Picture.Bitmap := GlobalImage.Picture.Bitmap;
        Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
        Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
        Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
        Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
        stretch := RapTabAYAR.FieldByName('FORMAT').AsString <> '';
      end;
    end;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

    BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);

    if (Bnd <> nil) and (BulTable <> nil) then
    begin
      QCntrlType := TQRDBImage; //TQRDbImage;
      QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
      with TQRDBImage(QCntrl) do
      begin
        Dataset := TADODataSet(BulTable);
        DataField := RapTabAYAR.FieldByName('ALANADI').AsString;
        Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
        Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
        Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
        Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
        stretch := RapTabAYAR.FieldByName('FORMAT').AsString <> '';
        SetCntrl(QCntrl);
      end;
    end
    else if BulTable = nil then
      ResimGetir;
  end;

  procedure YaziAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRPrintable;
    BulTable: TComponent;
    Bnd: TQRCustomBand;
    Sty: TFontStyles;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

    BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);

    if (Bnd <> nil) then
    begin
      if BulTable <> nil then
        QCntrlType := TQRDbRichText
      else
        QCntrlType := TQRRichText;
      QCntrl := Bnd.AddPrintable(QCntrlType);
      if BulTable <> nil then
      begin
        TQRDbRichText(QCntrl).Dataset := TADODataSet(BulTable);
        TQRDbRichText(QCntrl).DataField := RapTabAYAR.FieldByName('ALANADI').AsString;
      end
      else
      begin
        TQRRichText(QCntrl).ParentRichEdit := GlobalRichEdit;
        if RapTabAYAR.FieldByName('FONT').AsString <> '' then
          GlobalRichEdit.DefAttributes.Name := RapTabAYAR.FieldByName('FONT').AsString;
        if RapTabAYAR.FieldByName('PUNTO').AsInteger <> 0 then
          GlobalRichEdit.DefAttributes.Size := RapTabAYAR.FieldByName('PUNTO').AsInteger;

        if RapTabAYAR.FieldByName('RENK').AsString <> '' then
        begin
          try
            GlobalRichEdit.DefAttributes.Color := StringToColor(RapTabAYAR.FieldByName('RENK').AsString);
          except
            GlobalRichEdit.DefAttributes.Color := clBlack;
          end;
        end;

        Sty := [];
        if Pos('BOLD', RapTabAYAR.FieldByName('OZELLIK').AsString) > 0 then
          Sty := Sty + [fsBold];
        if Pos('ITALIK', RapTabAYAR.FieldByName('OZELLIK').AsString) > 0 then
          Sty := Sty + [fsItalic];
        if Pos('UNDERLINE', RapTabAYAR.FieldByName('OZELLIK').AsString) > 0 then
          Sty := Sty + [fsUnderline];
        if Pos('NORMAL', RapTabAYAR.FieldByName('OZELLIK').AsString) > 0 then
          Sty := [];

        GlobalRichEdit.DefAttributes.Style := Sty;
      end;
      SetRichCntrl(TQrCustomRichText(QCntrl));
    end;
  end;

  procedure HesapAyarlar(ClearFormula: Boolean);
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRCustomLabel;
    Bnd: TQRCustomBand;
    Bnd2: TQRCustomBand;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRExpr;
      QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
      with TQRExpr(QCntrl) do
      begin
        SetCntrl(QCntrl);
        Mask := RapTabAYAR.FieldByName('FORMAT').AsString;
        Transparent := RapTabAYAR.FieldByName('TRANSPARENT').AsBoolean; ;
        if Mask = 'YAZI' then
        begin
          Mask := '';
          Name := 'Y' + RapTabAYAR.FieldByName('SIRANO').AsString;
        end;

        Expression := RapTabAYAR.FieldByName('ALANADI').AsString;

        if pos('BandSaySil', RapTabAYAR.FieldByName('ALANADI').AsString) > 0 then
          BandSaySil := true;

        Bnd2 := BandBul(RapTabAYAR.FieldByName('TABLO').AsString);
        if (Bnd2 = nil) or (Bnd2.BandType = RbDetail) then
          Master := RapSyf.RaporSyf
        else
          Master := Bnd2;

        if ClearFormula then
          ResetAfterPrint := True;
        if mEkranAdi = 'Lab_' then
          TQRDbText(QCntrl).OnPrint := BeforeAlanPrint;
      end;
    end;
  end;

  procedure SistemAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRCustomLabel;
    Bnd: TQRCustomBand;
    Dt: TQRSysDataType;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRSysData;
      QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
      with TQRSysData(QCntrl) do
      begin
        SetCntrl(QCntrl);
        Transparent := RapTabAYAR.FieldByName('TRANSPARENT').AsBoolean; ;
        dt := qrsPageNumber;
        if RapTabAYAR.FieldByName('TABLO').AsString = 'TARÝH' then
          Dt := qrsDate
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'SAAT' then
          Dt := qrsTime
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'TARÝHSAAT' then
          Dt := qrsDateTime
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'DETAYSAYI' then
          Dt := qrsDetailCount
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'DETAYNO' then
          Dt := qrsDetailNo
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'BAÞLIK' then
          Dt := qrsReportTitle
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'SAYFANO' then
          Dt := qrsPageNumber
//            Else If RapTabAYAR.FieldByName('TABLO').AsString='SAYFASAYI' Then Begin
//               Dt:=qrsPageCount;
//               {TQuickRep.Options.TwoPass;}
//            End
//            Else If RapTabAYAR.FieldByName('TABLO').AsString='KOLONNO' Then
//               Dt:=qrsColumnNo
          ;
        Data := Dt;

      end;
    end;
  end;

  procedure BarcodeResim;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRImage;
    Bnd: TQRCustomBand;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRImage;
      QCntrl := TQRImage(Bnd.AddPrintable(QCntrlType));
      with QCntrl do
      begin
        Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
        try
//        Picture.Assign(Clipboard);

          Picture.LoadFromFile(RapTabAYAR.FieldByName('ALANADI').AsString);
        except
        end;
        Stretch := False;
        Width := Picture.Width;
        Height := Picture.Height;

        Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
        Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
        if RapTabAYAR.FieldByName('EN').AsString <> '' then
        begin
          Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
          //Stretch := True;
        end;
        if RapTabAYAR.FieldByName('BOY').AsString <> '' then
        begin
          Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
          //Stretch := True;
        end;
        if RapTabAYAR.FieldByName('YANASIK').AsString='YAN' then
        begin
          if RapTabAYAR.FieldByName('BOY').AsString <> '' then
            size.Width := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
          if RapTabAYAR.FieldByName('EN').AsString <> '' then
            size.Height := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
        end;
      end;
    end;
  end;

  procedure LogoAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRImage;
    Bnd: TQRCustomBand;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRImage;
      QCntrl := TQRImage(Bnd.AddPrintable(QCntrlType));
      with QCntrl do
      begin
        Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
        try
          //cture.Assign(Clipboard);
          Picture.LoadFromFile(RapTabAYAR.FieldByName('ALANADI').AsString);
        except
        end;
        Stretch := False;
        Width := Picture.Width;
        Height := Picture.Height;

        Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
        Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
        if RapTabAYAR.FieldByName('EN').AsString <> '' then
        begin
          Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
          Stretch := True;
        end;
        if RapTabAYAR.FieldByName('BOY').AsString <> '' then
        begin
          Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
          Stretch := True;
        end;
      end;
    end;
  end;

  function AlanAdi(s: string; no: integer): string;
  var
    i, vs: integer;
  begin
    Result := '';
    vs := 1;
    for i := 1 to Length(s) do
    begin
      if vs = no then
      begin
        if pos(',', copy(s, i, maxint)) > 0 then
          Result := copy(s, i, pos(',', copy(s, i, maxint)) - 1)
        else
          Result := copy(s, i, maxint);
        exit;
      end;
      if s[i] = ',' then
        inc(vs);
    end;
  end;

(*  procedure GrafikAyarlar;    burasý 4/3/2008
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRChart;
    DBChart: TQRDBChart;
    Bnd: TQRCustomBand;
    seri: TChartSeries;
    BaslikAlani: string;
    XAlani: string;
    YAlani: string;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRChart;
      QCntrl := TQRChart(Bnd.AddPrintable(QCntrlType));
      DBChart := TQRDBChart.Create(QCntrl);
      QCntrl.InsertControl(DBChart);

      QCntrl.Name := 'DB' + RapTabAYAR.FieldByName('SIRANO').AsString;
      QCntrl.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
      QCntrl.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
      QCntrl.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
      QCntrl.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);

      DBChart.Name := 'DC' + RapTabAYAR.FieldByName('SIRANO').AsString;
      DBChart.Title.Text.Text := RapTabAYAR.FieldByName('ALANADI').AsString;
      DBChart.View3D := RapTabAYAR.FieldByName('OZELLIK').AsString = '3D';

      Query.Close;
      Query.SQL.Text := 'select * from AYARLAR ' +
        'where RAPORADI = ''' + RapTabAYAR.FieldByName('RAPORADI').AsString + ''' AND ' +
        'BANDNO = ' + RapTabAYAR.FieldByName('SIRANO').AsString;
      Query.Open;

      while not Query.Eof do
      begin

        BaslikAlani := AlanAdi(Query.FieldByName('ALANADI').AsString, 1);
        XAlani := AlanAdi(Query.FieldByName('ALANADI').AsString, 2);
        YAlani := AlanAdi(Query.FieldByName('ALANADI').AsString, 3);

        if Query.FieldByName('ALANTURU').AsString = 'TPointSeries' then
          seri := TPointSeries.Create(DBChart);
        if Query.FieldByName('ALANTURU').AsString = 'TLineSeries' then
          seri := TLineSeries.Create(DBChart);
        if Query.FieldByName('ALANTURU').AsString = 'TAreaSeries' then
          seri := TAreaSeries.Create(DBChart);
        if Query.FieldByName('ALANTURU').AsString = 'TBarSeries' then
          seri := TBarSeries.Create(DBChart);
        if Query.FieldByName('ALANTURU').AsString = 'TFastLineSeries' then
          seri := TFastLineSeries.Create(DBChart);
        if Query.FieldByName('ALANTURU').AsString = 'TPieSeries' then
          seri := TPieSeries.Create(DBChart);
        if Query.FieldByName('ALANTURU').AsString = 'THorizBarSeries' then
          seri := THorizBarSeries.Create(DBChart);

        with seri do
        begin
          //Marks.ArrowLength := 8;
          Marks.Visible := false;
          Marks.Transparent := True;
          //Marks.Style := smsValue;

          ParentChart := DBChart;
          DataSource := TabloBul(Query.FieldByName('TABLO').AsString);
          if trim(Query.FieldByName('RENK').AsString) = '' then
            ColorEachPoint := Query.RecordCount = 0
          else
            SeriesColor := StringToColor(Query.FieldByName('RENK').AsString);
          XLabelsSource := BaslikAlani;
          Title := Query.FieldByName('FONT').AsString;
          XValues.Name := 'X';
          XValues.Order := loAscending;
          XValues.ValueSource := XAlani;
          YValues.Name := 'Y';
          YValues.Order := loNone;
          YValues.ValueSource := YAlani;
        end;
        if Query.FieldByName('ALANTURU').AsString = 'TPieSeries' then
          with TPieSeries(seri) do
          begin
            PieValues.Name := 'Pie';
            PieValues.Multiplier := 1;
            PieValues.Order := loNone;
            PieValues.ValueSource := XAlani;
          end;

        Query.Next;
      end;

      Query.Close;
    end;
  end;
*) (*
  procedure BarkodAyarlar;    //3/10/2007 de baþka modül 16.53 vers
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRDBBarcode;
    Bnd: TQRCustomBand;
    BulTable: TComponent;
    MyRect, MyOther: TRect;
    St: string[20];

  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);
      if BulTable <> nil then
      begin
        BarcodeResim;
//        QCntrlType := T;
        QCntrl :=TQRDBBarCode.Create(self);
{
            TQREan(QCntrl).DataSource:=TDataSource.Create(self);
            TQREan(QCntrl).DataSource.DataSet:=TDataSet(BulTable);
            TQREan(QCntrl).DataField:=RapTabAYAR.FieldByName('ALANADI').AsString;
}
//            ShowMessage(findcomponent('Dts'+RapTabAYAR.FieldByName('TABLO').AsString).Name);
   //         QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
        st := RapTabAYAR.FieldByName('FONT').AsString;
        st := Uppercase(Trim(st));
        //if st = 'CODABAR' then
        //  TQRDBBarcode(QCntrl).BarType := bcCodabar
        //else
        if st = 'CODE128A' then
          TQRDBBarcode(QCntrl).BarType := bcCode128A
//            else if st = 'CODE128B' then TDBEan(QCntrl).TypBarCode := bsCode128B
//            else if st = 'CODE128C' then TDBEan(QCntrl).TypBarCode := bsCode128C
        else if st = 'CODE39' then
          TQRDBBarcode(QCntrl).BarType := 'bcCode39'
        else if st = 'EAN13' then
          TQRDBBarcode(QCntrl).BarType := 'bcEan_13'
        else if st = 'EAN8' then
          TQRDBBarcode(QCntrl).BarType := 'bcEAN_8'
        else if st = 'UPCA' then
          TQRDBBarcode(QCntrl).BarType := 'bcUPC_A'
        else if st = 'UPCE' then
          TQRDBBarcode(QCntrl).BarType := 'bcUPC_E';
      end;
      with TQRDBBarcode(QCntrl) do
      begin
        if RapSyf.FindComponent( 'BR' + RapTabAYAR.FieldByName('SIRANO').AsString )<>nil then
          RapSyf.FindComponent( 'BR' + RapTabAYAR.FieldByName('SIRANO').AsString ).Free;
        TQRDBBarcode(QCntrl).Name := 'BR' + RapTabAYAR.FieldByName('SIRANO').AsString;
        left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
        top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
        {if RapTabAYAR.FieldByName('YANASIK').AsString = 'YAN' then
          Angle := 90;}
        if RapTabAYAR.FieldByName('PUNTO').AsString <> '' then
          showcode := true
        else
          ShowCode:=false;
        if RapTabAYAR.FieldByName('EN').AsString <> '' then
          Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
        if RapTabAYAR.FieldByName('BOY').AsString <> '' then
          Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
        {if RapTabAYAR.FieldByName('FORMAT').AsString <> '' then
          LabelMask := RapTabAYAR.FieldByName('FORMAT').AsString;}
            //BarCode:='987';
      end;
    end;
  end; *)

   procedure BarkodAyarlarEAN;
   var
      QCntrlType: TQRNewComponentClass;
      QCntrl: TQrDBEan; //TQRCustomLabel;
      Bnd: TQRCustomBand;
      BulTable: TComponent;
      MyRect, MyOther: TRect;
      St: string[20];

   begin
      Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      if Bnd <> nil then begin
         BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);
         if BulTable <> nil then begin
            QCntrlType := TQrDBEan;
            QCntrl := TqrDBEan(Bnd.AddPrintable(QCntrlType));

            TQRDBEan(QCntrl).DataSource:=TDataSource.Create(self);
            TQRDBEan(QCntrl).DataSource.DataSet:=TDataSet(BulTable);
            TQRDBEan(QCntrl).DataField:=RapTabAYAR.FieldByName('ALANADI').AsString;

            st := RapTabAYAR.FieldByName('FONT').AsString;
            st := Uppercase(Trim(st));
            if st = 'CODABAR' then TQrDBEan(QCntrl).TypBarCode := bcCodabar
            else if st = 'CODE128A' then TQrDBEan(QCntrl).TypBarCode := bcCode128
            else if st = 'CODE25INTERLEAVED' then TQrDBEan(QCntrl).TypBarCode := bc25Interleaved
            else if st = 'CODE39' then TQrDBEan(QCntrl).TypBarCode := bcCode39Standard//     bcCode39Full
            else if st = 'EAN13' then TQrDBEan(QCntrl).TypBarCode := bcEan13
            else if st = 'EAN8' then TQrDBEan(QCntrl).TypBarCode := bcEAN8
            else if st = 'UPCA' then TQrDBEan(QCntrl).TypBarCode := bcUPCA
            else if st = 'UPCE' then TQrDBEan(QCntrl).TypBarCode := bcUPCE0;
         end;
         with TQrDBEan(QCntrl) do begin
            Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
            left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
            top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
            FontAutoSize := False;
            font.size := RapTabAYAR.FieldByName('PUNTO').AsInteger;
            if RapTabAYAR.FieldByName('YANASIK').AsString = 'YAN' then
               Angle := 90;

            ShowLabels := pos('BAÞLIK',RapTabAYAR.fieldbyname('OZELLIK').AsString)>0;
            if RapTabAYAR.FieldByName('EN').AsString <> '' then
               Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
            if RapTabAYAR.FieldByName('BOY').AsString <> '' then
               Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
            if RapTabAYAR.FieldByName('FORMAT').AsString <> '' then
               LabelMask := RapTabAYAR.FieldByName('FORMAT').AsString;
            //BarCode:='987';
         end;
      end;
   end;

 procedure BarkodAyarlarQR;
   var
      QCntrlType: TQRNewComponentClass;
      QCntrl: TQrBarcode; //TQRCustomLabel;
      Bnd: TQRCustomBand;
      BulTable: TComponent;
      MyRect, MyOther: TRect;
      St: string[20];
      TabloAdi :  TDataSet;
      AlanAdi : String;

   begin
      Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      if Bnd <> nil then begin
         BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);
         if BulTable <> nil then begin
            QCntrlType := TQrBarcode;
            QCntrl := TQrBarcode(Bnd.AddPrintable(QCntrlType));

            //Burayý iptal ettik before printte text ine deðer atýyoruz
            //TQrBarcode(QCntrl).DataSource:=TDataSource.Create(self);
            //TQrBarcode(QCntrl).DataSource.DataSet:=TDataSet(BulTable);
            //TQrBarcode(QCntrl).DataField:=RapTabAYAR.FieldByName('ALANADI').AsString;

            st := RapTabAYAR.FieldByName('FONT').AsString;
            st := Uppercase(Trim(st));
            if st = 'CODABAR' then TQrBarcode(QCntrl).BarTip := bcCodeCodabar
            else if st = 'CODE128A' then TQrBarcode(QCntrl).BarTip := bcCode128A
            else if st = 'CODE25INTERLEAVED' then TQrBarcode(QCntrl).BarTip := bccode_2_5_Interleaved
            else if st = 'CODE39' then TQrBarcode(QCntrl).BarTip := bcCode39//     bcCode39Full
            else if st = 'EAN13' then TQrBarcode(QCntrl).BarTip := bcCodeEAN13
            else if st = 'EAN8' then TQrBarcode(QCntrl).BarTip := bcCodeEAN8;
//            else if st = 'UPCA' then TQrBarcode(QCntrl).BarTip := bcUPCA
//            else if st = 'UPCE' then TQrBarcode(QCntrl).BarTip := bcUPCE0;
         end;
         //QRBarcode
        with TQrBarcode(QCntrl) do begin
          Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
          //Burda bilgiyi alýp texte atalým
          TabloAdi := TDataSet(BulTable);
          AlanAdi := RapTabAYAR.FieldByName('ALANADI').AsString;
          //Text := TabloAdi.FieldByName(AlanAdi).AsString;
          DataSet := TabloAdi;
          DataField:= AlanAdi;
          left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
          top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
          //FontAutoSize := False;
          font.size := RapTabAYAR.FieldByName('PUNTO').AsInteger;
          if RapTabAYAR.FieldByName('YANASIK').AsString = 'YAN' then
            Angle := 90;

          ShowText := pos('BAÞLIK',RapTabAYAR.fieldbyname('OZELLIK').AsString)>0;

          i := pos('Modül:', RapTabAYAR.FieldByName('OZELLIK').AsString);
          if i > 0 then //Ratio:3 veya 2 Çizgi kalýnlýklarýný belirtir..
            Modul := StrToIntDef(copy(RapTabAYAR.FieldByName('OZELLIK').AsString,i+6,1), 3)
          else
            Modul := 2;

          if RapTabAYAR.FieldByName('EN').AsString <> '' then
            Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
          if RapTabAYAR.FieldByName('BOY').AsString <> '' then
            Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
          CheckSum := False;

          i:=pos('Ratio:', RapTabAYAR.FieldByName('FORMAT').AsString);
          if i > 0 then //Ratio:3 veya 2 Çizgi kalýnlýklarýný belirtir..
            Ratio := StrToIntDef(copy(RapTabAYAR.FieldByName('FORMAT').AsString,i+6,1), 3)
          else
            Ratio := 3;

          //BarCode:='987';
          end;
      end;
   end;


  function StringToStyle(St: string): TPenStyle;
  begin
    if St = 'DÜZ' then
      StringToStyle := psSolid
    else if St = 'KESÝKLÝ' then
      StringToStyle := psDash
    else if St = 'NOKTALI' then
      StringToStyle := psDot
    else if St = 'KESÝKLÝNOKTALI' then
      StringToStyle := psDashDot
    else
      StringToStyle := psSolid
  end;

  procedure CizimAyarlar;
  var
    QCntrlType: TQRNewComponentClass;
    QCntrl: TQRShape;
    Bnd: TQRCustomBand;
    Renk1, Renk2: string;
  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      QCntrlType := TQRShape;
      QCntrl := TQRShape(Bnd.AddPrintable(QCntrlType));
      with QCntrl do
      begin
        Name := 'B' + RapTabAYAR.FieldByName('SIRANO').AsString;
        if RapTabAYAR.FieldByName('TABLO').AsString = 'DÝKDÖRTGEN' then
          Shape := qrsRectangle
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'DAÝRE' then
          Shape := qrsCircle
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'DÝKÇÝZGÝ' then
          Shape := qrsVertLine
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'YATAYÇÝZGÝ' then
          Shape := qrsHorLine
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'ÜSTALT' then
          Shape := qrsTopAndBottom
        else if RapTabAYAR.FieldByName('TABLO').AsString = 'SAÐSOL' then
          Shape := qrsRightAndLeft;
        Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat * 10);
        Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat * 10);
        Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat * 10);
        Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat * 10);
        TQRShape(QCntrl).Pen.Width := RapTabAYAR.FieldByName('PUNTO').AsInteger;
        if RapTabAYAR.FieldByName('RENK').AsString <> '' then
        begin
          renk1 := ''; renk2 := '';
          if pos(',', RapTabAYAR.FieldByName('RENK').AsString) > 0 then
          begin
            Renk1 := copy(RapTabAYAR.FieldByName('RENK').AsString, 1, pos(',', RapTabAYAR.FieldByName('RENK').AsString) - 1);
            renk2 := copy(RapTabAYAR.FieldByName('RENK').AsString, pos(',', RapTabAYAR.FieldByName('RENK').AsString) + 1, length(RapTabAYAR.FieldByName('RENK').AsString) - pos(',', RapTabAYAR.FieldByName('RENK').AsString));
          end
          else
            Renk1 := RapTabAYAR.FieldByName('RENK').AsString;
          TQRShape(QCntrl).Pen.Color := StringToColor(renk1);
          if Renk2 <> '' then
            TQRShape(QCntrl).Brush.Color := StringToColor(renk2);
        end;
        TQRShape(QCntrl).Pen.Style := StringToStyle(RapTabAYAR.FieldByName('ALANADI').AsString)
      end;
    end;
  end;

  procedure CerceveAyarlar;
  var
    QCntrl: TQRPrintable;
    Bnd: TQRCustomBand;
    procedure SetFrame(Frm: TQrFrame);
    begin
      if RapTabAYAR.FieldByName('SOL').AsString <> '' then
        Frm.DrawLeft := True;
      if RapTabAYAR.FieldByName('UST').AsString <> '' then
        Frm.DrawTop := True;
      if RapTabAYAR.FieldByName('EN').AsString <> '' then
        Frm.DrawBottom := True;
      if RapTabAYAR.FieldByName('BOY').AsString <> '' then
        Frm.DrawRight := True;
      if RapTabAYAR.FieldByName('PUNTO').AsString <> '' then
        Frm.Width := RapTabAYAR.FieldByName('PUNTO').AsInteger;
      if RapTabAYAR.FieldByName('RENK').AsString <> '' then
      begin
        try
          Frm.Color := StringToColor(RapTabAYAR.FieldByName('RENK').AsString);
        except
          Frm.Color := clWhite;
        end;
      end;
    end;

  begin
    Bnd := BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
    if Bnd <> nil then
    begin
      SetFrame(Bnd.Frame);
      if RapTabAYAR.FieldByName('YANASIK').AsString = 'KB' then
        Bnd.ForceNewColumn := True;
      if RapTabAYAR.FieldByName('YANASIK').AsString = 'SB' then
        Bnd.ForceNewPage := True;
    end
    else
    begin
      QCntrl := CntrlBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      if QCntrl <> nil then
        SetFrame(QCntrl.Frame);
    end;
  end;


var
  k: Integer;
//  AExportFilter: TQRHTMLDocumentFilter;
//   AExportFilter : TQRRTFExportFilter;
begin
  printeradi:='';
  KopyaSay := 1;
  mPrevmi := mPrevmi1;
  Dokumyap := 0;
  if dokuluyor then exit;
  dokuluyor := true;
  Screen.Cursor := crHourglass;
  try
    if RaporSyf <> nil then
    begin
      while raporsyf.Componentcount <> 0 do
      begin
        RapSyf.raporsyf.Components[0].Free;
      end;
      RapSyf.raporsyf.Free;
      RapSyf.raporsyf := nil;
    end;
    EkranAdi := mEkranAdi;
    RapSyf.RaporSyf := TQuickRep.Create(Self);
    RaporSyf.Options := [];

{    if DublexYazdir then
       RaporSyf.OnApplyPrinterSettings := QuickRepApplyPrinterSettings;
 }
 //Y   RaporSyf.PrinterSettings.PrintMetaFile:=true;
    RapSyf.RaporSyf.Parent := Self;
    RapSyf.RaporSyf.Font.Charset := TURKISH_CHARSET;
    OnIzForm := tpreview.create(self);
    upreview.Raporadi := EkranAdi;
    RapTabAYAR := TADOQuery(TabloBul('AYARLAR'));
    if RapTabAYAR = nil then
    begin
      RapSyf.RaporSyf.Free;
      RapSyf.RaporSyf := nil;
      dokuluyor := false;
      Screen.Cursor := crDefault;
      ShowMessage('Döküm ayarlarý tablosu bulunamadý...');
      Exit;
    end;


    Raporadi := EkranAdi;
    RapTabAYAR.Close;
    RapTabAYAR.SQL.Text := 'select * from AYARLAR where RAPORADI=''' + EkranAdi + ''' order by SIRANO';
    RapTabAYAR.Open;
    RapTabAYAR.First;
    BandSay := 0;
    RapSyf.MyDataSets := nil;
    RapSyf.RaporSyf.BeforePrint := RapSyf.BeforePrint;

    RapSyf.RaporSyf.OnPreview := RapSyf.RaporSyfPreview;

    RapSyf.RaporSyf.Options := [];
    bandsaysil := falsE;

    for k := 1 to BandSayisi do
    begin
      QRBndSay[k] := 0;
      QRBndSaySil[k] := 0;
    end;
    while not RapTabAYAR.Eof do
    begin
      if (RapTabAYAR.FieldByName('ALANTURU').AsString = 'SAYFA') or
        (RapTabAYAR.FieldByName('ALANTURU').AsString = 'KAÐIT') then
        SayfaAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'BAND' then
        BandAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'SABÝT' then
        SabitAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'DÝKEYSABÝT' then
        DikeySabitAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'ALAN' then
        AlanAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'YAZI' then
        YaziAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'HESAP' then
        HesapAyarlar(False)
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'HESAPSÝL' then
        HesapAyarlar(True)
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'SÝSTEM' then
        SistemAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'LOGO' then
        LogoAyarlar
//      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'GRAFÝK' then
//        GrafikAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'ÇÝZÝM' then
        CizimAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'RESÝM' then
        ResimAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'ÇERÇEVE' then
        CerceveAyarlar
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'BARKOD' then
        BarkodAyarlarEAN
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'BARKODQR' then
        BarkodAyarlarQR
      else if RapTabAYAR.FieldByName('ALANTURU').AsString = 'HEMOGRAM' then
        GrafikHemogram;
      RapTabAYAR.Next;
    end;

//   RapTabAYAR.CancelRange;
    RapTabAYAR.Close;
{   If GlobalEndPage<>Nil Then
      RapSyf.RaporSyf.OnEndPage:=GlobalEndPage;}

//   RapSyf.RaporSyf.PrinterSettings.ApplySettings;
    RapSyf.RaporSyf.PrinterSettings.Copies := KopyaSay; //?????????//
    case mPrevmi of
      0:
        begin
          Screen.Cursor := crDefault;
          RapSyf.RaporSyf.Preview;
        end;
      1: begin
           if DublexYazdir then
              RaporSyf.OnApplyPrinterSettings := QuickRepApplyPrinterSettings;
           RapSyf.RaporSyf.Print;
         end;
      2: RaporuJpegOlarakKaydet(RaporSyf, ExtractFileDir(Application.ExeName) + '\MailRoot\' + Raporadi);
{      2: begin
          AExportFilter := TQRHTMLDocumentFilter.Create('c:\REPORT.htm');
          try
            RaporSyf.ExportToFilter(AExportFilter)
          finally
            AExportFilter.Free;
          end;
        end;}
//      3:  RaporuJpegOlarakKaydet(RapSyf.RaporSyf, '.\MailRoot\'+TABLO.TabLabSonucDOSYANO.AsString+'_'+TABLO.TabLabSonucGELISNO.AsString+'_'+TABLO.TabLabSonucKARTNO.AsString+'_'+EkranAdi+'.jpg');

     {2 : begin
          AExportFilter := TQRRTFExportFilter.Create('c:\REPORT.rtf');
          try
           RaporSyf. ExportToFilter(AExportFilter)
          finally
           AExportFilter.Free;
          end;
         end;}
      4:
        begin
           //GetDir(0,s);
          if InetPubYolu = '' then
          begin
            Tablo.Query5.Close;
            Tablo.Query5.SQL.Text := 'select DEGER from LABINI where BOLUM=''LABYAZ'' order by SIRANO';
            Tablo.Query5.open;
            InetPubYolu := Tablo.Query5.Fields[0].AsString;
            Tablo.Query5.next;
            if not Tablo.Query5.eof then
              InetPubYolu := InetPubYolu + Tablo.Query5.Fields[0].AsString;
          end;
          RapSyf.RaporSyf.Prepare;
//           RapSyf.RaporSyf.QRPrinter.Save('\\gelisimweb\Inetpub\wwwroot\LISNET\rapor\'+Dosyano+'-'+GelisNo+'-'+Kartno+'-'+mEkranAdi+'.qrp');
          RapSyf.RaporSyf.QRPrinter.Save(InetPubYolu + Dosyano + '-' + GelisNo + '-' + Kartno + '-' + mEkranAdi + '.qrp'); {\\gelisimweb\Inetpub\wwwroot\LISNET\rapor\}
          Sleep(500);
          Tablo.Query6.Close;
          Tablo.Query6.SQL.Text := 'Insert Into LABYAZ (DOSYANO, GELISNO, KARTNO, AD)values(''' + Dosyano + ''',' + GelisNo +
            ',' + Kartno + ',''' + Dosyano + '-' + GelisNo + '-' + Kartno + '-' + mEkranAdi + '.qrp' + ''')';
          Tablo.Query6.ExecSQL;
        end;
        // Teklif Listesinin kurum dosyasý için
        20 : begin // html export
               TeklifDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabTeklifKurumlari.fieldbyname('FIRMA').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.html';
             //  RaporSyf.ExportToFilter((TQRHTMLDocumentFilter.Create(Teklifdosyaadi)));
            end;
        21 : begin  // rtf
               TeklifDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabTeklifKurumlari.fieldbyname('FIRMA').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.rtf';
               RaporSyf.ExportToFilter((TQRRTFExportFilter.Create(Teklifdosyaadi)));
            end;
        22 : begin  //XLS
               TeklifDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabTeklifKurumlari.fieldbyname('FIRMA').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.xls';
               RaporSyf.ExportToFilter((TQRXLSFilter.Create(Teklifdosyaadi)));
            end;
        23 : begin   // pdf export
               TeklifDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabTeklifKurumlari.fieldbyname('FIRMA').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.pdf';
               RaporSyf.ExportToFilter((TQRPDFDocumentFilter.Create(Teklifdosyaadi)));
            end;
        // Teklif Listesinin kurum dosyasý için son
        // Sipariþ Listesinin kurum dosyasý için
        24 : begin // html export
               SiparisDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabSiparisKurum.fieldbyname('FirmaAdi').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.html';
           //    RaporSyf.ExportToFilter((TQRHTMLDocumentFilter.Create(SiparisDosyaadi)));
            end;
        25 : begin  // rtf
               SiparisDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabSiparisKurum.fieldbyname('FirmaAdi').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.rtf';
               RaporSyf.ExportToFilter((TQRRTFExportFilter.Create(SiparisDosyaadi)));
            end;
        26 : begin  //XLS
               SiparisDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabSiparisKurum.fieldbyname('FirmaAdi').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.xls';
               RaporSyf.ExportToFilter((TQRXLSFilter.Create(SiparisDosyaadi)));
            end;
        27 : begin   // pdf export
               SiparisDosyaadi:=GenRegIni.RegReadString('SATINALMA','EklentiYol',ExtractFileDir(Application.ExeName),'C')+ Tablo.TabSiparisKurum.fieldbyname('FirmaAdi').AsString+'_Alým_'+inttostr(SeciliAlim)+'_'+EkranAdi+'.pdf';
               RaporSyf.ExportToFilter((TQRPDFDocumentFilter.Create(SiparisDosyaadi)));
            end;
        // Sipariþ Listesinin kurum dosyasý için


    end; {case}
    if RapSyf.RaporSyf <> nil then
    begin
      RapSyf.RaporSyf.Free;
      RapSyf.RaporSyf := nil;
    end;
    if RapSyf.MyDataSets <> nil then
    begin
      RapSyf.MyDataSets.Free;
      RapSyf.MyDataSets := nil;
    end;
    dokuluyor := false;
    Screen.Cursor := crDefault;
  except on E: Exception do
    begin
      RapSyf.RaporSyf.Free;
      RapSyf.RaporSyf := nil;
      dokuluyor := false;
      Screen.Cursor := crDefault;
      if pos('abort', E.Message) > 0 then
        ShowMessage('Ýþlem iptal edildi..')
      else
        ShowMessage(E.Message);
    end;
  end;
end;

procedure RaporDokumBasla(TabloYeri: TComponent);
begin
  RapTabloGost := TabloYeri;
end;

procedure TRapSyf.RaporSyfPreview(Sender: TObject);
begin
  OnIzForm.PROnIz.QRPrinter := TQRPrinter(sender);
  OnIzForm.Show;
end;

procedure TRapSyf.FormCreate(Sender: TObject);
begin
  Query := TAdoquery.create(self);
  query.Connection := Tablo.cnn;
end;

begin
  dokuluyor := false;
  InetPubYolu := '';

end.

