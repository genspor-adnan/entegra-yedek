unit URapSyf;
{$H+}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Printers, ExtCtrls,  ComCtrls, DB, DBTables, quickrpt,Qrctrls, JPEG,DBarcode,
  DBarQrp, QRExport, UPrinter, TeeProcs, TeEngine, Chart, DBChart, QrTee,Series; {TeeProcs, TeEngine, Chart, DBChart}
Const
   BandSayisi=30;
type
  TRapSyf = class(TForm)
  private
    { Private declarations }
    procedure DENEMEx(sender: TObject);
  public
    { Public declarations }
      BandSay: Integer;
      QRBnd: Array [1..BandSayisi] Of TQRCustomBand;
      RaporSyf: TQuickRep;
      EkranAdi: String;
      MyDataSets:TList;
      RapTabAYAR:TTable;
      Dosyano, GelisNo,Kartno : String[16];
      procedure MakeItalic(sender: TObject; Value: String);
      procedure BeforeAlanPrint(sender: TObject; var Value: String);
      procedure BeforeBandPrint(Sender: TQRCustomBand;  var PrintBand: Boolean);
      procedure BeforePrint(Sender: TCustomQuickRep; var PrintReport: Boolean);

      function DokumYap(mPrevMi1 : smallint; mEkranAdi : String) : integer;
      function TabloBul(TabloAd : String):TComponent;
      function BandBul(BandNo : String):TQRCustomBand;
      function CntrlBul(CntrlNo : String):TQRPrintable;
      Procedure GrafikHemogram;
  end;

var
  RapSyf: TRapSyf;
  GlobalRichEdit:TRichEdit;
  GlobalFiyat:String;
  GlobalQuery : TQuery;
  GlobalImage : TImage;

  Dokuluyor : Boolean;
  QRBndSay: Array [1..BandSayisi] Of Integer;
  KopyaSay : Integer;
  ResimDizi : Array [11..48] Of TBitmap;
Type
  TMyEndPage = procedure(Sender: TQuickRep);

Var
  GlobalEndPage:TMyEndPage;


Procedure RaporDokumBasla(TabloYeri:TComponent);

implementation
uses  qrprntr, UTablo;
Var
   RapTabloGost:TComponent;
   i, mPrevmi : smallint;


{$R *.DFM}

Function UpStr(St:String):String;
Var
   K:Integer;
Begin
   For k:=1 To Length(St) Do
      St[k]:=UpCase(St[k]);
   UpStr:=St;
End;
procedure TRapSyf.MakeItalic(sender: TObject; Value: String);
Var
   BulTable:TTable;
Begin
   if ((Value='IF(RAKAMSONUC>0,RAKAMSONUC,YAZISONUC)') or
       (Value='BIRIM') or
       (Value='NDACIKLAMA') or
       (Value='ND')) Then
   begin
      BulTable := TTable(TabloBul('LABDOKUM'));
      If (BulTable <> Nil) Then
         if (BulTable.FieldByName('NDACIKLAMA').AsString = 'SI') then
            TQRDbText(sender).Font.Style:=TQRDbText(sender).Font.Style + [fsItalic]
         else
            TQRDbText(sender).Font.Style:=TQRDbText(sender).Font.Style - [fsItalic];
   end;
End;

procedure TRapSyf.BeforeAlanPrint(sender: TObject; var Value: String);
Begin
if (Sender is TQRDbText)  Then
   MakeItalic(Sender, TQRDbText(Sender).DataField)
else if (Sender is TQRExpr) Then
   MakeItalic(Sender, TQRExpr(Sender).Expression);
End;

procedure TRapSyf.BeforePrint(Sender: TCustomQuickRep;  var PrintReport: Boolean);
Var
   k:Integer;
begin
   For k:=1 to BandSayisi do
      QRBndSay[k]:=0;
   If MyDataSets<>Nil Then Begin
      If Raporsyf.alldatasets <> Nil Then
         For k:=0 To MyDataSets.Count-1 Do
            Raporsyf.alldatasets.Add(MyDataSets.Items[k]);
      RapSyf.MyDataSets.Free;
   End;
end;

procedure TRapSyf.BeforeBandPrint(Sender: TQRCustomBand;  var PrintBand: Boolean);
Var
   k:Integer;
begin
   For k:=1 to BandSay do
      If Sender.Name = QRBnd[K].Name Then
         Inc(QrBndSay[k]);
   PrintBand:=True;
end;

function TRapSyf.BandBul(BandNo : String):TQRCustomBand;
Var
   Bnd:TQRCustomBand;
   K:Integer;
Begin
   Bnd:=Nil;
   For k:=1 To  BandSay Do
      If QRBnd[K].Name = 'B'+BandNo Then
         Bnd:=QRBnd[K];
   BandBul:=Bnd;
End;

function TRapSyf.CntrlBul(CntrlNo : String):TQRPrintable;
Var
   K,l:Integer;
Begin
   CntrlBul:=Nil;
   For k:=1 To  BandSay Do Begin
      For l:=0 To QRBnd[K].ControlCount-1 Do
         If QRBnd[K].Controls[l].Name = 'B'+CntrlNo Then
            CntrlBul:=TQRPrintable(QRBnd[K].Controls[l]);
   End;
End;

Function TRapSyf.TabloBul(TabloAd:String):TComponent;
Var
   K:Integer;
Begin
   TabloBul := Nil;
   if TabloAd = 'SORGU' then
      TabloBul := GlobalQuery
   else
      For k:=0 To RapTabloGost.ComponentCount-1 Do
         If (RapTabloGost.Components[k] Is TTable) Or (RapTabloGost.Components[k] Is TQuery) Then
            If UpStr(RapTabloGost.Components[k].Name) = (UpStr(TabloAd))  Then
               TabloBul := RapTabloGost.Components[k];
End;

procedure TRapSyf.DENEMEx(sender: TObject);
begin
  //
end;

Procedure TRapSyf.GrafikHemogram;
Var
  QCntrlType : TQRNewComponentClass;
  QCntrl: TQRCustomLabel;
  BulTable : TComponent;
  Bnd:TQRCustomBand;
  Oran : Real;
  ss:TStringlist;

procedure Sayiyaz(x,y:real;s:string;b:tbitmap);
begin
  b.Canvas.Pixels[ round(x) ,round(y)  ] := clBlack;
  b.Canvas.Pixels[ round(x) ,round(y)+1] := clBlack;
  b.Canvas.TextOut( round(x-b.Canvas.TextWidth(S)/2), round(y) + 3 ,S);
end;

procedure HemogramGrafik(Tetkik:String; st:TStrings; Oran:Real; Bitmap:TBitmap );
var
  i : integer;
  yy : real ;
  dy : real ;
  mmGrafik, mmEsikler : TStringList;
begin
  yy := 3.28125*oran;
  dy := 1*oran;
  Bitmap.Width :=0;
  Bitmap.Height:=0;
  Bitmap.Width := round( 420 * oran );
  Bitmap.Height:= round( 300 * oran )+20;
  (* Burası hertetkik için farklı olan bir iş olan aşağıdaki sayıların *)
  (* yazılması işlemi yapılıyor.                                       *)

  if Tetkik= 'WBC' THEN
  begin
    Sayiyaz( 50*oran,300*oran+2, '50',Bitmap);
    Sayiyaz(100*oran,300*oran+2,'100',Bitmap);
    Sayiyaz(200*oran,300*oran+2,'200',Bitmap);
    Sayiyaz(300*oran,300*oran+2,'300',Bitmap);
    Sayiyaz(400*oran,300*oran+2,'400',Bitmap);
  end;

  if Tetkik = 'RBC' THEN
  begin
    Sayiyaz(1.68* 30*oran,300*oran+2, '30',Bitmap); // 1.68 Özel Bir Hesaplama Sonucu bulundu ... Şöyleki
    Sayiyaz(1.68*100*oran,300*oran+2,'100',Bitmap); // Scan ettiğim rapordan oranlama ile bulunduç
    Sayiyaz(1.68*200*oran,300*oran+2,'200',Bitmap);
  end;

  if Tetkik = 'PLT' THEN
  begin
    Sayiyaz(13.5*  2*oran,300*oran+2,  '2',Bitmap); // 13.5 yukarıdaki usul ile bulundu.
    Sayiyaz(13.5*  5*oran,300*oran+2,  '5',Bitmap);
    Sayiyaz(13.5* 10*oran,300*oran+2, '10',Bitmap);
    Sayiyaz(13.5* 20*oran,300*oran+2, '20',Bitmap);
    Sayiyaz(13.5* 30*oran,300*oran+2, '30',Bitmap);
  end;


  mmGrafik:=TStringList.Create;
  mmEsikler:=TStringList.Create;
  mmGrafik.CommaText:=  st.Values['GRAFİK' ];
  mmEsikler.CommaText:= st.Values['EŞİKLER'];

  (* Aşağıda Grafiğin çizgileri çizdiriliyor.*)
  Bitmap.Canvas.moveTo(round(420*oran),round(300*oran+2 ));
  Bitmap.Canvas.LineTo(1,round(300*oran+2));
  Bitmap.Canvas.moveTo(1,round(300*oran+2));
  Bitmap.Canvas.LineTo(1,1 );
  (******************************************)

  (* Aşağıda eşikler çizdiriliyor.*)
  Bitmap.Canvas.Pen.Style:=psDash;  // Çizgi çizgi yapılıyor.
  for i := 0 to mmEsikler.Count-1 do
  begin
    Bitmap.Canvas.moveTo( round(yy * StrToInt(mmEsikler[i])) ,round(300*oran+2) );
    Bitmap.Canvas.LineTo( round(yy * StrToInt(mmEsikler[i])) ,1 );
  end;
  (*******************************)

  (* Aşağıda grafik çizdiriliyor.*)
  Bitmap.Canvas.Pen.Style:=psSolid; // Kalem düz yapılıyor.
  Bitmap.Canvas.moveTo(1,round(300*oran) );     // Başlangıç koordinatına konumlanılıyor.
  for i := 0 to mmGrafik.Count-1 do
  begin
    Bitmap.Canvas.LineTo(
                              round(yy*i) +1,   // Yatay uzaklık yy katsayısıyla çarpılıyor.
     round(300*oran-dy*StrToInt(mmGrafik[i])));
  end;
  (*******************************)

end;

Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

     QCntrlType := TQRImage;
     QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
     With TQRImage(QCntrl) Do Begin
//        Picture.Bitmap := ResimDizi[11];
//        Picture.Bitmap.LoadFromFile('C:\SRC\GEN95\GOZ.BMP');
        Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
        Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
        Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
        Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
        Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);

        if RapTabAYAR.FieldByName('OZELLIK').AsString<>'' then
           Oran:= RapTabAYAR.FieldByName('OZELLIK').AsFloat;

        Tablo.Query1.SQL.Text := 'select ACIKLAMA2 from LABSONUC where DOSYANO = "'+Dosyano+
          '" AND GELISNO = '+Gelisno+' AND KARTNO = '+Kartno+
          ' and KOD="'+RapTabAYAR.FieldByName('ALANADI').AsString+'"';
        Tablo.Query1.Open;
        ss := TStringlist.Create;
        ss.Assign(Tablo.Query1.Fields[0]);

        ResimDizi[11] := Tbitmap.Create;

        HemogramGrafik(RapTabAYAR.FieldByName('TABLO').AsString , ss, Oran,ResimDizi[11]);
        Picture.Bitmap := ResimDizi[11];
        //stretch := True;
        ss.free;
        ResimDizi[11].free;
     end;
End;

function TRapSyf.DokumYap(mPrevMi1 : smallint; mEkranAdi : String) : integer;
var
   Renk : String[30];
   Procedure SetFont(QCntrlFont: TFont; FontName:String;Punto:Integer;Ozellik,Renk:String);
   Var
      Sty:TFontStyles;
   Begin
      If FontName <> '' Then
         QCntrlFont.Name := FontName;
      If Punto > 0 Then
         QCntrlFont.Size := Punto;
      Sty:=[];
      If Pos('BOLD', Ozellik)>0 Then
         Sty:=Sty + [fsBold];
      If Pos('ITALIK', Ozellik)>0 Then
         Sty:=Sty + [fsItalic];
      If Pos('UNDERLINE', Ozellik)>0 Then
         Sty:=Sty + [fsUnderline];
      If Pos('NORMAL', Ozellik)>0 Then
         Sty:=[];

      QCntrlFont.Style:=Sty;
      If Renk <> '' Then Begin
         Try
            QCntrlFont.Color:= StringToColor(Renk);
         Except
            QCntrlFont.Color:= clBlack;
         End;
      End;
   End;

   Procedure SetCntrl(QCntrl:TQRCustomLabel);
   Begin
      With QCntrl Do Begin
         AutoSize := True;
         Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
         If RapTabAYAR.FieldByName('YANASIK').AsString = 'SAĞ' Then
            Alignment := taRightJustify
         Else If RapTabAYAR.FieldByName('YANASIK').AsString = 'ORT' Then
            Alignment := taCenter
         Else
            Alignment := taLeftJustify;

         Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
         Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
         If RapTabAYAR.FieldByName('EN').AsString <> '' Then Begin
            Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
            AutoSize := False;
         End;
         If RapTabAYAR.FieldByName('BOY').AsString <> '' Then Begin
            If RapTabAYAR.FieldByName('BOY').AsFloat > 0 Then
               Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10)
            Else
               AutoStretch := True;
         End;
         Renk := RapTabAYAR.FieldByName('RENK').AsString;
         if pos(',', Renk)>0 then begin
            Color := StringToColor(copy(Renk, pos(',', Renk)+1, length(Renk)-pos(',', Renk)));// ,clblack
            Renk:=copy(Renk, 1, pos(',', Renk));
         end;
         SetFont(TQRCustomLabel(QCntrl).Font,
                 RapTabAYAR.FieldByName('FONT').AsString,
                 RapTabAYAR.FieldByName('PUNTO').AsInteger,
                 RapTabAYAR.FieldByName('OZELLIK').AsString,
                 Renk);

      End;
   End;

   Procedure SetRichCntrl(QCntrl:TQRCustomRichText);
   Begin
      With QCntrl Do Begin
         Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
         Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
         Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
         If RapTabAYAR.FieldByName('EN').AsString <> '' Then Begin
            Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
         End;
         If RapTabAYAR.FieldByName('BOY').AsString <> '' Then Begin
            Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
            If RapTabAYAR.FieldByName('BOY').AsFloat > 0 Then
               Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10)
            Else
               AutoStretch := True;
         End;

         SetFont(QCntrl.Font,
                 RapTabAYAR.FieldByName('FONT').AsString,
                 RapTabAYAR.FieldByName('PUNTO').AsInteger,
                 RapTabAYAR.FieldByName('OZELLIK').AsString,
                 RapTabAYAR.FieldByName('RENK').AsString);
      End;
   End;

   Procedure SayfaAyarlar;
   {TPRINTERSETTINGS }
   Var
      Bulundu,k,Yer:Integer;
      St1, printeradi:String;
      BulTable:TComponent;
      SaklaPS:TQRPaperSize;

      Function PaperSizeBul(Tur:String):TQRPaperSize;
      Begin
         If Tur='KULLANICI' Then
            PaperSizeBul:=Custom
         Else If (Tur='LETTER')or(Tur='MEKTUP 21.59X27.94CM')or(Tur='FORM 21.59X27.94CM') Then
            PaperSizeBul:=Letter
         Else If Tur='LEGAL 21.59X35.56CM' Then
            PaperSizeBul:=Legal
         Else If (Tur='A3')or(Tur='A3 29.7X42CM') Then
            PaperSizeBul:=A3
         Else If (Tur='A4')or(Tur='A4 21X29.7CM') Then
            PaperSizeBul:=A4
         Else If (Tur='A5')or(Tur='A5 14.8X21CM') Then
            PaperSizeBul:=A5
         Else If (Tur='B4')or(Tur='B4 25X35.4CM') Then
            PaperSizeBul:=B4
         Else If(Tur='B5')or(Tur='B5 18.2X25.7CM') Then
            PaperSizeBul:=B5
         Else If Tur='QUARTO 21.5X27.5CM' Then
            PaperSizeBul:=QUARTO
         Else If Tur='UYGULAMA 19X25.4CM' Then
            PaperSizeBul:=Executive
         Else If Tur='FOLYO 21.59X25.4CM' Then
            PaperSizeBul:=Folio
         Else If Tur='TABLOID 27.94X43.18CM' Then
            PaperSizeBul:=Tabloid
{          Else If Tur='ZARF-9 9.84X24.13CM' Then
            PaperSizeBul:=Envelope#9
         Else If Tur='ZARF-10 10.47X22.54CM' Then
            PaperSizeBul:=Envelope#10}
         Else
            PaperSizeBul:=Default
      End;


   Begin
      If RapTabAYAR.FieldByName('TABLO').AsString='BOYUT' Then Begin
         SaklaPS:=PaperSizeBul(UpStr(RapTabAYAR.FieldByName('ALANADI').AsString));
         RaporSyf.PrinterSettings.PaperSize := SaklaPS;
         RaporSyf.Page.PaperSize := SaklaPS;
         if RapTabAYAR.FieldByName('OZELLIK').AsString <> '' then
            Kopyasay := RapTabAYAR.FieldByName('OZELLIK').AsInteger;
         If SaklaPS = Custom Then Begin
            RaporSyf.Page.Length := RapTabAYAR.FieldByName('BOY').AsFloat*10;
            RaporSyf.Page.Width  := RapTabAYAR.FieldByName('EN').AsFloat*10;
         End;
         If RapTabAYAR.FieldByName('YANASIK').AsString <> '' Then Begin
            RaporSyf.Page.Orientation := poLandscape;
            RaporSyf.PrinterSettings.Orientation := poLandscape;
         End;
         If RapTabAYAR.FieldByName('BANDNO').AsString <> '' Then
            RapSyf.RaporSyf.PrinterSettings.Copies:=RapTabAYAR.FieldByName('BANDNO').AsInteger;

      End
      Else If RapTabAYAR.FieldByName('TABLO').AsString='BOŞLUK' Then Begin
         RaporSyf.Page.LeftMargin := RapTabAYAR.FieldByName('SOL').AsFloat*10;
         RaporSyf.Page.TopMargin := RapTabAYAR.FieldByName('UST').AsFloat*10;
         RaporSyf.Page.RightMargin := RapTabAYAR.FieldByName('BOY').AsFloat*10;
         RaporSyf.Page.BottomMargin:= RapTabAYAR.FieldByName('EN').AsFloat*10;
      End
      Else If RapTabAYAR.FieldByName('TABLO').AsString='KOLON' Then Begin
         RaporSyf.Page.Columns := RapTabAYAR.FieldByName('BANDNO').AsInteger;
         RaporSyf.Page.ColumnSpace := RapTabAYAR.FieldByName('SOL').AsFloat*10;
      End
      Else If RapTabAYAR.FieldByName('TABLO').AsString='YAZICI' Then Begin
         printeradi := RapTabAYAR.FieldByName('ALANADI').AsString;
         if (mPrevmi=1)and(Uppercase(RapTabAYAR.FieldByName('OZELLIK').AsString) = 'EKRAN') then begin //Print Dialog çağrılıyor mu?
             RapSyf.RaporSyf.PrinterSetup;
             if RapSyf.RaporSyf.PrinterSettings.PrinterIndex < 0 then abort;
         end;
         //            RapSyf.PrintDialog1.Execute;
            {Application.CreateForm(TPrinterDlg, PrinterDlg);
            for i := 0 to PrinterDlg.ListBox1.Items.Count-1 do
              if pos(printeradi, PrinterDlg.ListBox1.Items[i])>0 then
                 PrinterDlg.ListBox1.ItemIndex := i;

            PrinterDlg.ShowModal;
            KopyaSay := StrToInt(PrinterDlg.Kopya.Text); //Kopyasayısı
            printeradi := PrinterDlg.ListBox1.Items[PrinterDlg.ListBox1.ItemIndex];

            Yer := Pos(' on ',printeradi);
            If Yer>0 Then
               Delete(printeradi, Yer, Length(printeradi)-Yer+1);

            PrinterDlg.Destroy;
         end;}

         Bulundu:=-1;
         For k:=0 To Printer.Printers.Count-1 Do Begin
            St1:=QRPrinter.Printers.Strings[k];
            Yer := Pos(' on ',St1);
            If Yer>0 Then
               Delete(St1, Yer, Length(St1)-Yer+1);
            If pos(printeradi, St1)>0 Then
               Bulundu:=K;
         End;
         RapSyf.RaporSyf.PrinterSettings.PrinterIndex:=Bulundu;
      End
      Else If RapTabAYAR.FieldByName('TABLO').AsString='TABLO' Then Begin
         BulTable := TabloBul(RapTabAYAR.FieldByName('ALANADI').AsString);
         If BulTable <> Nil Then Begin
            If MyDataSets = Nil Then
               MyDataSets := Tlist.Create;
            MyDataSets.Add(TDataset(BulTable));
         End;
      End
   End;

   Procedure BandAyarlar;
   Var
      Tur:TQRBandType;
      Gr1:TQRGroup;
      Gr2:TQRSubDetail;
      Gr3:TQRChildBand;
      BulTable:TComponent;
      Bnd:TQRCustomBand;
   Begin
      If RapTabAYAR.FieldByName('TABLO').AsString='GRUP' Then Begin
         Gr1 := TQRGroup.Create(RapSyf);
         Gr1.Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
         Gr1.BandType := RbGroupHeader;
         if RapTabAYAR.FieldByName('YANASIK').AsString ='YSF'then
            Gr1.ForceNewPage := True;

         Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

         Gr1.Parent := RapSyf.RaporSyf;
         If Bnd.BandType = RbDetail Then
            Gr1.Master := RapSyf.RaporSyf
         Else
            Gr1.Master := TQrSubDetail(Bnd);

         Gr1.Expression := RapTabAYAR.FieldByName('ALANADI').AsString;
         If RapTabAYAR.FieldByName('EN').AsString <> '' Then
            Gr1.Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
         If RapTabAYAR.FieldByName('BOY').AsString <> '' Then
            Gr1.Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
         If BandSay < BandSayisi Then Begin
            BandSay:=BandSay+1;
            QRBnd[Bandsay]:=Gr1;
         End;
      End
      Else If RapTabAYAR.FieldByName('TABLO').AsString='ARADETAY' Then Begin
         Gr2 := TQRSubDetail.Create(RapSyf);
         Gr2.Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
         Gr2.Parent := RapSyf.RaporSyf;
         Gr2.BandType := rbSubDetail;
         If RapTabAYAR.FieldByName('EN').AsString <> '' Then
            Gr2.Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
         If RapTabAYAR.FieldByName('BOY').AsString <> '' Then
            Gr2.Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
         BulTable := TabloBul(RapTabAYAR.FieldByName('ALANADI').AsString);
         If BulTable <> Nil Then
            Gr2.Dataset:=TDataSet(BulTable);
         Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
         If Bnd.BandType = RbDetail Then
            Gr2.Master := RapSyf.RaporSyf
         Else
            Gr2.Master := Bnd;
         If BandSay < BandSayisi Then Begin
            BandSay:=BandSay+1;
            QRBnd[Bandsay]:=Gr2;
         End;
      End
      Else If RapTabAYAR.FieldByName('TABLO').AsString='ÇOCUK' Then Begin
         Gr3 := TQRChildBand.Create(RapSyf);
         Gr3.Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
         Gr3.Parent := RapSyf.RaporSyf;
         Gr3.BandType := rbChild;
         If RapTabAYAR.FieldByName('EN').AsString <> '' Then
            Gr3.Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
         If RapTabAYAR.FieldByName('BOY').AsString <> '' Then
            Gr3.Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
         Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
         If Bnd <> Nil Then Begin
            Gr3.ParentBand := Bnd;
            Bnd.HasChild := True;
         End;
         If BandSay < BandSayisi Then Begin
            BandSay:=BandSay+1;
            QRBnd[Bandsay]:=Gr3;
         End;
      End
      Else Begin
         If RapTabAYAR.FieldByName('TABLO').AsString='GRUPBAŞI' Then
            Tur := RbGroupHeader
         Else If RapTabAYAR.FieldByName('TABLO').AsString='GRUPSONU' Then
            Tur := RbGroupFooter
         Else If RapTabAYAR.FieldByName('TABLO').AsString='SAYFABAŞI' Then Begin
             Tur := RbPageHeader;
            if RapTabAYAR.FieldByName('FORMAT').AsString='' Then
               RapSyf.RaporSyf.Options := RapSyf.RaporSyf.Options + [FirstPageHeader];
         End
         Else If RapTabAYAR.FieldByName('TABLO').AsString='SAYFASONU' Then Begin
            Tur := RbPageFooter;
            if RapTabAYAR.FieldByName('FORMAT').AsString='' Then
               RapSyf.RaporSyf.Options := RapSyf.RaporSyf.Options + [LastPageFooter];
         End
         Else If RapTabAYAR.FieldByName('TABLO').AsString='DETAY' Then Begin
            Tur := RbDetail;
            BulTable := TabloBul(RapTabAYAR.FieldByName('ALANADI').AsString);
            If BulTable <> Nil Then
               RapSyf.RaporSyf.Dataset:=TDataset(BulTable);
         End
         Else If RapTabAYAR.FieldByName('TABLO').AsString='RAPORBAŞI' Then Begin
            Tur := RbTitle;
            RapSyf.RaporSyf.Options:=RapSyf.RaporSyf.Options-[FirstPageHeader];
         End
         Else If RapTabAYAR.FieldByName('TABLO').AsString='KOLONBAŞI' Then
            Tur := RbColumnHeader
         Else If RapTabAYAR.FieldByName('TABLO').AsString='RAPORSONU' Then
            Tur := RbSummary
         Else
            Tur := RbDetail;

         If BandSay < BandSayisi Then Begin
            BandSay:=BandSay+1;
            QRBnd[Bandsay]:=RapSyf.RaporSyf.CreateBand(Tur);
            With QRBnd[Bandsay] Do Begin
               Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
               If RapTabAYAR.FieldByName('YANASIK').AsString <> '' Then
                  AlignToBottom := True;
               If RapTabAYAR.FieldByName('EN').AsString <> '' Then
                  Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
               If RapTabAYAR.FieldByName('BOY').AsString <> '' Then
                  Size.Length := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);

               If RapTabAYAR.FieldByName('RENK').AsString <> '' Then Begin
                  Try
                     Color:= StringToColor(RapTabAYAR.FieldByName('RENK').AsString);
                  Except
                     Color:= clBlack;
                  End;
               End;
            End;
            If RapTabAYAR.FieldByName('TABLO').AsString='GRUPSONU' Then Begin
               Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
               If (Bnd Is TQRGroup) Then
                   TQRGroup(Bnd).FooterBand := TQRBand(QRBnd[BandSay]);
               If (Bnd Is TQRSubDetail) Then
                   TQRSubDetail(Bnd).FooterBand := TQRBand(QRBnd[BandSay]);
            End;
            If RapTabAYAR.FieldByName('TABLO').AsString='GRUPBAŞI' Then Begin
               Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
               If (Bnd Is TQRSubDetail) Then
                   TQRSubDetail(Bnd).HeaderBand := TQRBand(QRBnd[BandSay]);
             End;
         End;
      End;
      QRBnd[Bandsay].BeforePrint:= BeforeBandPrint;
     // QRBnd[Bandsay]. OnStartPage := DENEMEx;
            //RapSyf.RaporSyf.OnStartPage := DENEMEx;
   End;

   Procedure SabitAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRCustomLabel;
      Bnd:TQRCustomBand;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then Begin
         QCntrlType := TQRLabel;
         QCntrl:=TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
         With TQRLabel(QCntrl) Do Begin
            SetCntrl(QCntrl);
            Caption := RapTabAYAR.FieldByName('ALANADI').AsString;
         End;
      End;
   End;

   Procedure AlanAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRCustomLabel;
      BulTable : TComponent;
      Bnd:TQRCustomBand;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

      BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);

      If (Bnd <> Nil) And (BulTable <> Nil) Then Begin
         QCntrlType := TQRDbText;
         QCntrl:=TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
         With TQRDbText(QCntrl) Do Begin
            Dataset := TDataset(BulTable);
            DataField := RapTabAYAR.FieldByName('ALANADI').AsString;
            SetCntrl(QCntrl);
            Mask :=RapTabAYAR.FieldByName('FORMAT').AsString;
            if mEkranAdi='Lab_' Then
               TQRDbText(QCntrl).OnPrint := BeforeAlanPrint;

         End;
      End;
   End;

   Procedure ResimAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRCustomLabel;
      BulTable : TComponent;
      Bnd:TQRCustomBand;
      procedure ResimGoster;
       var
        bmp : TBitmap;
        jpg : TJPEGImage;
        stbmp : TStream;
        stjpg : TStream;
        Tablo1 : TQuery;
       begin
        {if Tablo.TabKimlik.FieldByName('RESIM').IsNull then begin
           Resim.Picture.Assign(Nil);
           exit;
        end;  }
        jpg := TJPEGImage.Create;
        bmp := TBitmap.Create;
        Tablo1 := TQuery(BulTable);
        stjpg := TBlobStream.Create(TBlobField(Tablo1.FieldByName(RapTabAYAR.FieldByName('ALANADI').AsString)), bmRead);
        stbmp := TMemoryStream.Create;
        jpg.LoadFromStream(stjpg);
        if Jpg.PixelFormat = jf24bit then
           Bmp.PixelFormat := pf24bit
        else
           Bmp.PixelFormat := pf8bit;
        Bmp.Width := Jpg.Width;
        Bmp.Height := Jpg.Height;
        Bmp.Canvas.Draw(0,0,Jpg);
        Bmp.SaveToStream(stbmp);
        TQRImage(QCntrl).Picture.Assign(bmp);
        bmp.free;
        jpg.free;
        stjpg.free;
        stbmp.free;
      end;

      procedure ResimGetir;
      begin
         QCntrlType := TQRImage;
         QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
         With TQRImage(QCntrl) Do Begin
            if RapTabAYAR.FieldByName('ALANADI').AsString <> '' then
                 Picture.Bitmap := ResimDizi[RapTabAYAR.FieldByName('ALANADI').AsInteger]
            else
               Picture.Bitmap.LoadFromFile('C:\GEN95\');// := GlobalImage.Picture.Bitmap;
            Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
            Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
            Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
            Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
            stretch := RapTabAYAR.FieldByName('FORMAT').AsString<>'';
         End;
      End;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

      BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);

      If (Bnd <> Nil) And (BulTable <> Nil) Then Begin
         QCntrlType := TQRImage;   //TQRDbImage;
         QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
         With TQRImage(QCntrl) Do Begin
            ResimGoster;
            //Dataset := TDataset(BulTable);
            //DataField := RapTabAYAR.FieldByName('ALANADI').AsString;
            Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
            Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
            Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
            Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
            stretch := RapTabAYAR.FieldByName('FORMAT').AsString<>'';
         End;
      End
      else if BulTable = Nil then ResimGetir;
   End;

   Procedure YaziAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRPrintable;
      BulTable : TComponent;
      Bnd:TQRCustomBand;
      Sty:TFontStyles;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);

      BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);

      If (Bnd <> Nil) Then Begin
         IF BulTable <> Nil Then
            QCntrlType := TQRDbRichText
         Else
            QCntrlType := TQRRichText;
         QCntrl:=Bnd.AddPrintable(QCntrlType);
         IF BulTable <> Nil Then Begin
            TQRDbRichText(QCntrl).Dataset := TDataset(BulTable);
            TQRDbRichText(QCntrl).DataField := RapTabAYAR.FieldByName('ALANADI').AsString;
         End
         Else Begin
            TQRRichText(QCntrl).ParentRichEdit := GlobalRichEdit;

            If RapTabAYAR.FieldByName('FONT').AsString <> '' Then
               GlobalRichEdit.DefAttributes.Name := RapTabAYAR.FieldByName('FONT').AsString;
            If RapTabAYAR.FieldByName('PUNTO').AsInteger <> 0 Then
               GlobalRichEdit.DefAttributes.Size := RapTabAYAR.FieldByName('PUNTO').AsInteger;

            If RapTabAYAR.FieldByName('RENK').AsString<> '' Then Begin
                  Try
                     GlobalRichEdit.DefAttributes.Color:= StringToColor(RapTabAYAR.FieldByName('RENK').AsString);
                  Except
                     GlobalRichEdit.DefAttributes.Color:= clBlack;
                  End;
            End;

            Sty:=[];
            If Pos('BOLD', RapTabAYAR.FieldByName('OZELLIK').AsString)>0 Then
               Sty:=Sty + [fsBold];
            If Pos('ITALIK', RapTabAYAR.FieldByName('OZELLIK').AsString)>0 Then
               Sty:=Sty + [fsItalic];
            If Pos('UNDERLINE', RapTabAYAR.FieldByName('OZELLIK').AsString)>0 Then
               Sty:=Sty + [fsUnderline];
            If Pos('NORMAL', RapTabAYAR.FieldByName('OZELLIK').AsString)>0 Then
               Sty:=[];

            GlobalRichEdit.DefAttributes.Style:=Sty;
         End;
         SetRichCntrl(TQrCustomRichText(QCntrl));
      End;
   End;

   Procedure HesapAyarlar(ClearFormula:Boolean);
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRCustomLabel;
      Bnd:TQRCustomBand;
      Bnd2:TQRCustomBand;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then Begin
         QCntrlType := TQRExpr;
         QCntrl:=TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
         With TQRExpr(QCntrl) Do Begin
            SetCntrl(QCntrl);
            Mask :=RapTabAYAR.FieldByName('FORMAT').AsString;
            If Mask = 'YAZI' Then Begin
               Mask :='';
               Name := 'Y'+RapTabAYAR.FieldByName('SIRANO').AsString;
            End;

            Expression := RapTabAYAR.FieldByName('ALANADI').AsString;

            Bnd2:=BandBul(RapTabAYAR.FieldByName('TABLO').AsString);
            If (Bnd2 = Nil) Or (Bnd2.BandType = RbDetail) Then
               Master := RapSyf.RaporSyf
            Else
               Master := Bnd2;

            If ClearFormula Then
               ResetAfterPrint:=True;
            if mEkranAdi='Lab_' Then
               TQRDbText(QCntrl).OnPrint := BeforeAlanPrint;
      End;
      End;
   End;

   Procedure SistemAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRCustomLabel;
      Bnd:TQRCustomBand;
      Dt:TQRSysDataType;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then Begin
         QCntrlType := TQRSysData;
         QCntrl:=TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
         With TQRSysData(QCntrl) Do Begin
            SetCntrl(QCntrl);
{}
            Dt:=qrsPageNumber;
            If RapTabAYAR.FieldByName('TABLO').AsString='TARİH' Then
               Dt:=qrsDate
            Else If RapTabAYAR.FieldByName('TABLO').AsString='SAAT' Then
               Dt:=qrsTime
            Else If RapTabAYAR.FieldByName('TABLO').AsString='TARİHSAAT' Then
               Dt:=qrsDateTime
            Else If RapTabAYAR.FieldByName('TABLO').AsString='DETAYSAYI' Then
               Dt:=qrsDetailCount
            Else If RapTabAYAR.FieldByName('TABLO').AsString='DETAYNO' Then
               Dt:=qrsDetailNo
            Else If RapTabAYAR.FieldByName('TABLO').AsString='BAŞLIK' Then
               Dt:=qrsReportTitle
            Else If RapTabAYAR.FieldByName('TABLO').AsString='SAYFANO' Then
               Dt:=qrsPageNumber
//            Else If RapTabAYAR.FieldByName('TABLO').AsString='SAYFASAYI' Then Begin
//               Dt:=qrsPageCount;
//               {TQuickRep.Options.TwoPass;}
//            End
//            Else If RapTabAYAR.FieldByName('TABLO').AsString='KOLONNO' Then
//               Dt:=qrsColumnNo
            ;
            Data := Dt;

         End;
      End;
   End;

   Procedure LogoAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRImage;
      Bnd:TQRCustomBand;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then Begin
         QCntrlType := TQRImage;
         QCntrl:=TQRImage(Bnd.AddPrintable(QCntrlType));
         With QCntrl Do Begin
            Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
            Try
               Picture.LoadFromFile(RapTabAYAR.FieldByName('ALANADI').AsString);
            Except
            End;
            Stretch := False;
            Width := Picture.Width;
            Height := Picture.Height;

            Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
            Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
            If RapTabAYAR.FieldByName('EN').AsString <> '' Then Begin
               Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
               Stretch := True;
            End;
            If RapTabAYAR.FieldByName('BOY').AsString <> '' Then Begin
               Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
               Stretch := True;
            End;
         End;
      End;
   End;

   Procedure GrafikAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRChart;
      DBChart : TQRDBChart;
      Bnd:TQRCustomBand;
      Seri: TFastLineSeries;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then Begin
         QCntrlType := TQRChart;
         QCntrl:=TQRChart(Bnd.AddPrintable(QCntrlType));
         DBChart := TQRDBChart.Create(QCntrl);
         QCntrl.InsertControl(DBChart);

         With DBChart Do Begin
            Name := 'DB'+RapTabAYAR.FieldByName('SIRANO').AsString;
            Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
            Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
            If RapTabAYAR.FieldByName('EN').AsString <> '' Then Begin
               Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
            End;
            If RapTabAYAR.FieldByName('BOY').AsString <> '' Then Begin
               Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
            End;
            DBChart.Title.Text.Add('dENEME');
            Seri := TFastLineSeries.Create(DBChart);
            Seri.AddXY(1,10, '', ClRed);
            Seri.AddXY(2,23, '', ClRed);
            Seri.AddXY(3,5, '', ClRed);
            Seri.AddXY(4,10, '', ClRed);
            Seri.AddXY(5,-10, '', ClRed);
            Seri.AddXY(6,20, '', ClRed);
            DBChart.AddSeries(Seri);
         End;

         With QCntrl Do Begin
            Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
//            Try
//               Picture.LoadFromFile(RapTabAYAR.FieldByName('ALANADI').AsString);
//            Except
//            End;
//            Stretch := False;
//            Width := Picture.Width;
//            Height := Picture.Height;

            Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
            Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
            If RapTabAYAR.FieldByName('EN').AsString <> '' Then Begin
               Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
//               Stretch := True;
            End;
            If RapTabAYAR.FieldByName('BOY').AsString <> '' Then Begin
               Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
//               Stretch := True;
            End;
//            QCntrl.Series.Add( (1);
         End;
      End;
   End;

   Procedure BarkodAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRDuckBarcode;//TQRCustomLabel;
      Bnd:TQRCustomBand;
      BulTable : TComponent;
      MyRect, MyOther: TRect;
      St:String[20];
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then Begin
         BulTable := TabloBul(RapTabAYAR.FieldByName('TABLO').AsString);
         IF BulTable <> Nil Then Begin
            QCntrlType := TQRDuckBarcode;
            QCntrl:=TQRDuckBarcode(Bnd.AddPrintable(QCntrlType));
   //         QCntrl := TQRCustomLabel(Bnd.AddPrintable(QCntrlType));
            TQRDuckBarcode(QCntrl).DataSet := TDataset(BulTable);
            TQRDuckBarcode(QCntrl).DataField := RapTabAYAR.FieldByName('ALANADI').AsString;
            st := RapTabAYAR.FieldByName('FONT').AsString;
            if st = 'Codabar' then TQRDuckBarcode(QCntrl).Style := bsCodabar
            else if st = 'Code128A' then TQRDuckBarcode(QCntrl).Style := bsCode128A
            else if st = 'Code128B' then TQRDuckBarcode(QCntrl).Style := bsCode128B
            else if st = 'Code128C' then TQRDuckBarcode(QCntrl).Style := bsCode128C
            else if st = 'Code25Interleaved' then TQRDuckBarcode(QCntrl).Style := bsCode25Interleaved
            else if st = 'Code39' then TQRDuckBarcode(QCntrl).Style := bsCode39
            else if st = 'EAN13' then TQRDuckBarcode(QCntrl).Style := bsEAN13
            else if st = 'EAN8' then TQRDuckBarcode(QCntrl).Style := bsEAN8
            else if st = 'UPCA' then TQRDuckBarcode(QCntrl).Style := bsUPCA
            else if st = 'UPCE' then TQRDuckBarcode(QCntrl).Style := bsUPCE;
         End;
         With TQRDuckBarcode(QCntrl) Do Begin
            Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
            Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
            Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
            If RapTabAYAR.FieldByName('EN').AsString <> '' Then
               Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
            If RapTabAYAR.FieldByName('BOY').AsString <> '' Then
               Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
        End;
      End;
   End;

   Function StringToStyle(St:String):TPenStyle;
   Begin
      If St='DÜZ' Then
         StringToStyle:=psSolid
      else If St='KESİKLİ' Then
         StringToStyle:=psDash
      else If St='NOKTALI' Then
         StringToStyle:=psDot
      else If St='KESİKLİNOKTALI' Then
         StringToStyle:=psDashDot
      else
         StringToStyle:=psSolid
   End;

   Procedure CizimAyarlar;
   Var
      QCntrlType : TQRNewComponentClass;
      QCntrl: TQRShape;
      Bnd:TQRCustomBand;
   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then Begin
         QCntrlType := TQRShape;
         QCntrl:=TQRShape(Bnd.AddPrintable(QCntrlType));
         With QCntrl Do Begin
            Name := 'B'+RapTabAYAR.FieldByName('SIRANO').AsString;
            If RapTabAYAR.FieldByName('TABLO').AsString='DİKDÖRTGEN' Then
               Shape := qrsRectangle
            Else If RapTabAYAR.FieldByName('TABLO').AsString='DAİRE' Then
               Shape := qrsCircle
            Else If RapTabAYAR.FieldByName('TABLO').AsString='DİKÇİZGİ' Then
               Shape := qrsVertLine
            Else If RapTabAYAR.FieldByName('TABLO').AsString='YATAYÇİZGİ' Then
               Shape := qrsHorLine
            Else If RapTabAYAR.FieldByName('TABLO').AsString='ÜSTALT' Then
               Shape := qrsTopAndBottom
            Else If RapTabAYAR.FieldByName('TABLO').AsString='SAĞSOL' Then
               Shape := qrsRightAndLeft;
            Size.Left := Round(RapTabAYAR.FieldByName('SOL').AsFloat*10);
            Size.Top := Round(RapTabAYAR.FieldByName('UST').AsFloat*10);
            Size.Width := Round(RapTabAYAR.FieldByName('EN').AsFloat*10);
            Size.Height := Round(RapTabAYAR.FieldByName('BOY').AsFloat*10);
            TQRShape(QCntrl).Pen.Width:=RapTabAYAR.FieldByName('PUNTO').AsInteger;
            If RapTabAYAR.FieldByName('RENK').AsString <> '' Then
                TQRShape(QCntrl).Pen.Color:=StringToColor(RapTabAYAR.FieldByName('RENK').AsString);
            TQRShape(QCntrl).Pen.Style:=StringToStyle(RapTabAYAR.FieldByName('ALANADI').AsString)
         End;
      End;
   End;

   Procedure CerceveAyarlar;
   Var
      QCntrl: TQRPrintable;
      Bnd:TQRCustomBand;
      Procedure SetFrame(Frm:TQrFrame);
      Begin
         If RapTabAYAR.FieldByName('SOL').AsString <> '' Then
            Frm.DrawLeft := True;
         If RapTabAYAR.FieldByName('UST').AsString <> '' Then
            Frm.DrawTop := True;
         If RapTabAYAR.FieldByName('EN').AsString <> '' Then
            Frm.DrawBottom := True;
         If RapTabAYAR.FieldByName('BOY').AsString <> '' Then
            Frm.DrawRight := True;
         If RapTabAYAR.FieldByName('PUNTO').AsString <> '' Then
            Frm.Width:=RapTabAYAR.FieldByName('PUNTO').AsInteger;
         If RapTabAYAR.FieldByName('RENK').AsString <> '' Then Begin
            Try
               Frm.Color:= StringToColor(RapTabAYAR.FieldByName('RENK').AsString);
            Except
               Frm.Color:= clWhite;
            End;
         End;
      End;

   Begin
      Bnd:=BandBul(RapTabAYAR.FieldByName('BANDNO').AsString);
      If Bnd <> Nil Then begin
         SetFrame(Bnd.Frame);
         if RapTabAYAR.FieldByName('YANASIK').AsString = 'KB' then
            Bnd.ForceNewColumn := True;
         if RapTabAYAR.FieldByName('YANASIK').AsString = 'SB' then
            Bnd.ForceNewPage := True;
      end
      Else Begin
         QCntrl:=CntrlBul(RapTabAYAR.FieldByName('BANDNO').AsString);
         If QCntrl <> Nil Then
            SetFrame(QCntrl.Frame);
      End;
   End;

Var
   k:Integer;
   AExportFilter : TQRHTMLDocumentFilter;
//   AExportFilter : TQRRTFExportFilter;
Begin
KopyaSay := 1;
mPrevmi := mPrevmi1;
Dokumyap:=0;
if dokuluyor then exit;
dokuluyor := true;
Screen.Cursor := crHourglass;
try
   EkranAdi := mEkranAdi;
   RapSyf.RaporSyf := TQuickRep.Create(Self);
   RapSyf.RaporSyf.Parent := Self;
   RapSyf.RaporSyf.Font.Charset := TURKISH_CHARSET;
   RapTabAYAR := TTable(TabloBul('AYARLAR'));
   If RapTabAYAR = Nil Then Begin
      RapSyf.RaporSyf.Free;
      dokuluyor := false;
      Screen.Cursor := crDefault;
      ShowMessage('Döküm ayarları tablosu bulunamadı...');
      Exit;
   End;
   RapTabAYAR.Open;
   RapTabAYAR.SetRange([EkranAdi,1],[EkranAdi,30000]);
   RapTabAYAR.First;
   BandSay:=0;
   RapSyf.MyDataSets:=Nil;
   RapSyf.RaporSyf.BeforePrint := RapSyf.BeforePrint;
   RapSyf.RaporSyf.Options := [];

   For k:=1 to BandSayisi do
      QRBndSay[k]:=0;
   While Not RapTabAYAR.Eof Do Begin
      If (RapTabAYAR.FieldByName('ALANTURU').AsString='SAYFA') Or
         (RapTabAYAR.FieldByName('ALANTURU').AsString='KAĞIT') Then
         SayfaAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='BAND' Then
         BandAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='SABİT' Then
         SabitAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='ALAN' Then
         AlanAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='YAZI' Then
         YaziAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='HESAP' Then
         HesapAyarlar(False)
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='HESAPSİL' Then
         HesapAyarlar(True)
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='SİSTEM' Then
         SistemAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='LOGO' Then
         LogoAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='GRAFİK' Then
         GrafikAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='ÇİZİM' Then
         CizimAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='RESİM' Then
         ResimAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='ÇERÇEVE' Then
         CerceveAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='BARKOD' Then
         BarkodAyarlar
      Else If RapTabAYAR.FieldByName('ALANTURU').AsString='HEMOGRAM' Then
         GrafikHemogram;

      RapTabAYAR.Next;
   End;

   RapTabAYAR.CancelRange;
//   RapTabAYAR.Close;
{   If GlobalEndPage<>Nil Then
      RapSyf.RaporSyf.OnEndPage:=GlobalEndPage;}

//   RapSyf.RaporSyf.PrinterSettings.ApplySettings;
   RapSyf.RaporSyf.PrinterSettings.Copies:=KopyaSay; //?????????//
   case mPrevmi of
     0 : begin
           Screen.Cursor := crDefault;
           RapSyf.RaporSyf.Preview;
         end;
     1 : RapSyf.RaporSyf.Print;
     2 : begin
          AExportFilter :=  TQRHTMLDocumentFilter.Create('c:\REPORT.htm');
          try
           RaporSyf. ExportToFilter(AExportFilter)
          finally
           AExportFilter.Free;
          end;
         end;
     4 : begin
           //GetDir(0,s);
           RapSyf.RaporSyf.Prepare;
           RapSyf.RaporSyf.QRPrinter.Save('\\gelisimweb\Inetpub\wwwroot\LISNET\rapor\'+Dosyano+'-'+GelisNo+'-'+Kartno+'-'+mEkranAdi+'.qrp');
           Tablo.Query6.SQL.Text := 'Insert Into LABYAZ (DOSYANO, GELISNO, KARTNO, AD)values("'+Dosyano+'",'+GelisNo+
                ','+Kartno+',"'+Dosyano+'-'+GelisNo+'-'+Kartno+'-'+mEkranAdi+'.qrp'+'")';
           Tablo.Query6.ExecSQL;     
         end;
     {2 : begin
          AExportFilter := TQRRTFExportFilter.Create('c:\REPORT.rtf');
          try
           RaporSyf. ExportToFilter(AExportFilter)
          finally
           AExportFilter.Free;
          end;
         end;}
   end;{case}

   RapSyf.RaporSyf.Free;
   dokuluyor := false;
   Screen.Cursor := crDefault;
except On E:Exception Do Begin
   RapSyf.RaporSyf.Free;
   dokuluyor := false;
   Screen.Cursor := crDefault;
   if pos('abort', E.Message)>0 then
      ShowMessage('İşlem iptal edildi..')
   else
      ShowMessage(E.Message);
   End;
end;
End;

Procedure RaporDokumBasla(TabloYeri:TComponent);
Begin
   RapTabloGost:=TabloYeri;
End;

begin
   dokuluyor := false;
end.
