unit UScanner;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxTrackBar, StdCtrls, OleCtrls, SCANNERLib_TLB, cxLookAndFeelPainters, cxGroupBox, cxRadioGroup, ComCtrls, ToolWin, ExtCtrls, ImgList, PngImageList,
  cxGraphics, cxLookAndFeels, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint;

type
  TScannerDlg = class(TForm)
    Panel1: TPanel;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    cbopixeltype: TComboBox;
    cbodpi: TComboBox;
    chkclearimage: TCheckBox;
    chkenablefeeder: TCheckBox;
    chkpdfusejpegcomp2: TCheckBox;
    txtpdfjpegquality2: TEdit;
    Button2: TButton;
    Panel2: TPanel;
    lblcurrentpage: TLabel;
    Label9: TLabel;
    lbltotalpage: TLabel;
    ToolBar2: TToolBar;
    OncekiTus: TToolButton;
    SonrakiTus: TToolButton;
    FitTus: TToolButton;
    Cevir90: TToolButton;
    ToolButton3: TToolButton;
    Cevir180: TToolButton;
    Cevir270: TToolButton;
    KucukTus: TToolButton;
    SilTus: TToolButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    Scanner1: TScanner;
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Scanner1EndScan(Sender: TObject);
    procedure cxTrackBar1PropertiesChange(Sender: TObject);
    procedure FitTusClick(Sender: TObject);
    procedure AspectTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure OncekiTusClick(Sender: TObject);
    procedure SonrakiTusClick(Sender: TObject);
    procedure Cevir90Click(Sender: TObject);
    procedure Cevir180Click(Sender: TObject);
    procedure Cevir270Click(Sender: TObject);
    procedure KucukTusClick(Sender: TObject);
    procedure BuyukTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Tur : string[5];
  end;

var
  ScannerDlg: TScannerDlg;

implementation
//Uses LocOnFly;

{$R *.dfm}

procedure TScannerDlg.AspectTusClick(Sender: TObject);
begin
    Scanner1.View := 10;
    Scanner1.SetFocus;
end;

procedure TScannerDlg.Button1Click(Sender: TObject);
begin

  if RadioButton1.Checked then
    scanner1.SelectImageSourceByIndex(cboimagesource.ItemIndex)
  else
      begin
          if scanner1.SelectImageSource <> true then
              exit;

      end;

  if chkshowui.Checked then
    scanner1.ShowTwainUI:=true
  else
    scanner1.ShowTwainUI:=false;

  if chkclearimage.Checked then
    scanner1.ClearImageBuffer:=true
  else
    scanner1.ClearImageBuffer:=false;


  if chkenableduplex.Checked then
    scanner1.DuplexEnabled:=true
  else
    scanner1.DuplexEnabled:=false;

  if chkenablefeeder.Checked then
    scanner1.FeederEnabled:=true
  else
    scanner1.FeederEnabled:=false;


    case cbodpi.ItemIndex of
                0: scanner1.DPI:=96;
                1: scanner1.DPI:=200;
                2: scanner1.DPI:=300;
                3: scanner1.DPI:=600;
    end;


    case cbopixeltype.ItemIndex of
                0: scanner1.PixelType:=-1;
                1: scanner1.PixelType:=0;
                2: scanner1.PixelType:=1;
                3: scanner1.PixelType:=2;
    end;


   //  if chkdefaultcap.Checked then
            scanner1.SetCaptureArea(0,0,0,0);
   //  else
   //         scanner1.SetCaptureArea(strtofloat(txtcapleft.text),strtofloat(txtcaptop.text),strtofloat(txtcapwidth.text),strtofloat(txtcapheight.text) );



    scanner1.Scan;

end;

procedure TScannerDlg.Button2Click(Sender: TObject);
var iresult : bool ;
    FontID : Integer ;
    FontID2 : Integer ;
    function PDFKaydet : Boolean;
    begin
       Scanner1.PDFAuthor := 'my author';
       Scanner1.PDFCreator := 'Created from Scanner Pro ActiveX';
       Scanner1.PDFKeyword := 'my keyword';
       Scanner1.PDFProducer := 'my producer';
       Scanner1.PDFTitle := 'my title';
       Scanner1.PDFSubject := 'my subject';
       //////scanner1.PDFOutputPDFA:=true;

         If chkpdfusejpegcomp2.Checked Then
          begin
            Scanner1.PDFUseJPEGCompression := True;
            Scanner1.PDFJPEGQuality := strtoint(txtpdfjpegquality2.Text);
          end
        Else
           Scanner1.PDFUseJPEGCompression := False;
       Tur := 'pdf';
       Result := Scanner1.SaveAllPage2PDF('c:\tmpscan.pdf' , True, 1);
    end;

    function TIFKaydet: Boolean;
    var iresult : bool ;
    begin
       scanner1.TIFCompression:=cbotifcompression.ItemIndex;
       Tur := 'tif';
       Result := Scanner1.SaveAllPage2Tif('c:\tmpscan.tif' , True, 1);
    end;

    function DocKaydet: Boolean;
    var iresult : bool ;
    begin
       //scanner1.DocCompression:=cbotifcompression.ItemIndex;
       Tur := 'doc';
       Result := Scanner1.SaveAllPage2Docx('c:\tmpscan.doc' , True, 1);
    end;


begin
   scanner1.View:=5;
   case cxRadioGroup1.ItemIndex of
     0 :iresult := TIFKaydet;
     1 :iresult := DocKaydet;
     2 :iresult := PDFKaydet;
   end;

   if iresult then //geçici olarak c ye yazılan dosyayı buraya alalım
      ModalResult := mrOk
   else
      ShowMessage('Kaydedilemedi..');
end;

procedure TScannerDlg.BuyukTusClick(Sender: TObject);
begin
   cxTrackBar1.Position := cxTrackBar1.Position+1;
end;

procedure TScannerDlg.Cevir180Click(Sender: TObject);
begin
  scanner1.Rotate180();
end;

procedure TScannerDlg.Cevir270Click(Sender: TObject);
begin
  scanner1.Rotate270();
end;

procedure TScannerDlg.Cevir90Click(Sender: TObject);
begin
  scanner1.Rotate90();
end;

procedure TScannerDlg.cxTrackBar1PropertiesChange(Sender: TObject);
begin
   Scanner1.View := cxTrackBar1.Position;
   Scanner1.SetFocus;
end;

procedure TScannerDlg.FitTusClick(Sender: TObject);
begin
    Scanner1.View := 9;
    Scanner1.SetFocus;
end;

procedure TScannerDlg.FormActivate(Sender: TObject);
 var
 iCount: Integer;
 i : Integer;
begin
    cbodpi.Items.Add('Ekran görünümü 96dpi');
    cbodpi.Items.Add('Fax 200dpi');
    cbodpi.Items.Add('OCR Text 300dpi');
    cbodpi.Items.Add('Lazer Yazıcı kaliteli 600dpi');
    cbodpi.ItemIndex:=0;


    cbopixeltype.Items.Add('Varsayılan');
    cbopixeltype.Items.Add('Gri Tonlama');
    cbopixeltype.Items.Add('Siyah & Beyaz');
    cbopixeltype.Items.Add('Gerçek Renkler');
    cbopixeltype.ItemIndex:=0;

    cbotifcompression.Items.Add('LZW');
    cbotifcompression.Items.Add('CITT3');
    cbotifcompression.Items.Add('CITT4');
    cbotifcompression.Items.Add('RLE');
    cbotifcompression.Items.Add('None');
    cbotifcompression.Items.Add('JPEG');
    cbotifcompression.ItemIndex:=0;


    iCount :=scanner1.GetNumImageSources();

    for i := 0 To iCount-1 do
       begin
           cboimagesource.Items.Add(scanner1.GetImageSourceName(i));
       end;

       if  cboimagesource.Items.Count > 0 then
              cboimagesource.ItemIndex:=0;
end;

procedure TScannerDlg.FormCreate(Sender: TObject);
begin
//LocalizerOnFly.ProcessContainer(Self);
end;

procedure TScannerDlg.KucukTusClick(Sender: TObject);
begin
   cxTrackBar1.Position := cxTrackBar1.Position-1;
end;

procedure TScannerDlg.OncekiTusClick(Sender: TObject);
begin
   if Scanner1.GetActivePageNo > 0 then begin
      Scanner1.SetActivePageNo(Scanner1.GetActivePageNo-1);
      lblcurrentpage.Caption := Format('%d', [Scanner1.GetActivePageNo] );
   end;
end;

procedure TScannerDlg.Scanner1EndScan(Sender: TObject);
begin
   lbltotalpage.Caption := Format('%d', [Scanner1.TotalPage] );
   lblcurrentpage.Caption := Format('%d', [Scanner1.GetActivePageNo] );
end;

procedure TScannerDlg.SilTusClick(Sender: TObject);
begin
  Scanner1.DeletePage (Scanner1.GetActivePageNo);
  Scanner1.SetActivePageNo (1);
  lbltotalpage.Caption := Format('%d', [Scanner1.TotalPage] );
  lblcurrentpage.Caption := Format('%d', [Scanner1.GetActivePageNo] );
end;

procedure TScannerDlg.SonrakiTusClick(Sender: TObject);
begin
   if Scanner1.GetActivePageNo < strtoint(lbltotalpage.Caption) then begin
      Scanner1.SetActivePageNo(Scanner1.GetActivePageNo+1);
      lblcurrentpage.Caption := Format('%d', [Scanner1.GetActivePageNo] );
   end;
end;

end.
