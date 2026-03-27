unit UScanner;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, SCANNERLib_TLB, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxTrackBar, Vcl.ComCtrls, Vcl.ToolWin, Vcl.ExtCtrls, Vcl.ImgList, PngImageList,
  dxSkinLiquidSky, dxSkinLondonLiquidSky;

type
  TScannerDlg = class(TForm)
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    cboimagesource: TComboBox;
    Label2: TLabel;
    cbopixeltype: TComboBox;
    cbodpi: TComboBox;
    Label3: TLabel;
    chkshowui: TCheckBox;
    chkclearimage: TCheckBox;
    chkenablefeeder: TCheckBox;
    chkenableduplex: TCheckBox;
    GroupBox2: TGroupBox;
    chkdefaultcap: TCheckBox;
    Label1: TLabel;
    txtcapleft: TEdit;
    Label4: TLabel;
    txtcaptop: TEdit;
    Label5: TLabel;
    txtcapwidth: TEdit;
    Label6: TLabel;
    txtcapheight: TEdit;
    Label7: TLabel;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    chkautosaveallpages: TCheckBox;
    PNGImageList2: TPngImageList;
    Panel2: TPanel;
    Label12: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    ToolBar2: TToolBar;
    OncekiTus: TToolButton;
    SonrakiTus: TToolButton;
    ToolButton3: TToolButton;
    SilTus: TToolButton;
    ToolButton4: TToolButton;
    FitTus: TToolButton;
    AspectTus: TToolButton;
    ToolButton2: TToolButton;
    Cevir90: TToolButton;
    Cevir180: TToolButton;
    Cevir270: TToolButton;
    ToolButton1: TToolButton;
    KucukTus: TToolButton;
    cxTrackBar1: TcxTrackBar;
    BuyukTus: TToolButton;
    Scanner1: TScanner;
    Panel1: TPanel;
    Label11: TLabel;
    GroupBox4: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    chksavetosingle: TCheckBox;
    cbotifcompression: TComboBox;
    Button19: TButton;
    txtpdfjpegquality2: TEdit;
    Button2: TButton;
    ListBox1: TListBox;
    Label8: TLabel;
    lblcurrentpage: TLabel;
    Label9: TLabel;
    lbltotalpage: TLabel;
    Label10: TLabel;
    txtpageno: TEdit;
    Button4: TButton;
    Button6: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Scanner1EndScan(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure chkenablefeederClick(Sender: TObject);
    procedure Scanner1EndAllScan(Sender: TObject);
    procedure Scanner1ScanningError(Sender: TObject);
    procedure Cevir90Click(Sender: TObject);
    procedure Cevir180Click(Sender: TObject);
    procedure Cevir270Click(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure FitTusClick(Sender: TObject);
    procedure cxTrackBar1PropertiesChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     Tur : string[5];
     DosyaAdi : string;
  end;

var
  ScannerDlg: TScannerDlg;

implementation

uses UGirisKutusuEx, PrjConst;

{$R *.dfm}

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


     if chkdefaultcap.Checked then
            scanner1.SetCaptureArea(0,0,0,0)
     else
            scanner1.SetCaptureArea(strtofloat(txtcapleft.text),strtofloat(txtcaptop.text),strtofloat(txtcapwidth.text),strtofloat(txtcapheight.text) );



scanner1.Scan;


end;

procedure TScannerDlg.Button2Click(Sender: TObject);
var iresult : bool;
    FontID, FontID2 : Integer;
    s : string;
    Ad:Variant;
begin

//  SaveDialog1.Filter :='PDF File|*.pdf';
//   SaveDialog1.DefaultExt :='pdf';

   scanner1.View := 5;
   scanner1.TIFCompression:=cbotifcompression.ItemIndex;

   //pdf/a setting

   Scanner1.PDFAuthor := 'my author';
   Scanner1.PDFCreator := 'Created from Scanner ActiveX';
   Scanner1.PDFKeyword := 'my keyword';
   Scanner1.PDFProducer := 'my producer';
   Scanner1.PDFTitle := 'my title';
   Scanner1.PDFSubject := 'my subject';



   Scanner1.PDFJPEGQuality := strtoint(txtpdfjpegquality2.Text);





   //if SaveDialog1.Execute then

   Tur := 'pdf';

   //ekrandan dosya adý sorup o adla kaydederiz
   if TGirisKutusuEx.BilgiAlEx(DosyaAdiniGirin,TGirdiDenetimleri.Create.Edit(Tur+' '+DosyaAdiniGirin, @Ad)) = mrOk  then begin
      DosyaAdi := GetEnvironmentVariable('Temp');
      DosyaAdi:=DosyaAdi+'\'+VarToStr(Ad);
      if pos('.'+Tur, DosyaAdi)=0 then
         DosyaAdi := DosyaAdi+'.'+Tur;
      try
        scanner1.SaveAllPage2PDF(DosyaAdi, chksavetosingle.Checked,1);
        modalResult := mrOk;
      finally
       modalResult := mrOk;
      end;
   end;


{   s := GetEnvironmentVariable('Temp');
   try
     scanner1.SaveAllPage2PDF(s+'\tmpscan.pdf', chksavetosingle.Checked,1);
     modalResult := mrOk;
   finally
     modalResult := mrOk;
   end;}
end;

procedure TScannerDlg.FitTusClick(Sender: TObject);
begin
    Scanner1.View := 10;
    Scanner1.SetFocus;
end;

procedure TScannerDlg.FormActivate(Sender: TObject);
var
 iCount: Integer;
 i : Integer;
begin
    Scanner1.LicenseKey:='9950';
    cbotifcompression.Items.Add('LZW');
    cbotifcompression.Items.Add('CITT3');
    cbotifcompression.Items.Add('CITT4');
    cbotifcompression.Items.Add('RLE');
    cbotifcompression.Items.Add('None');
    cbotifcompression.Items.Add('JPEG');
    cbotifcompression.ItemIndex:=0;

    cbodpi.Items.Add('Onscreen Viewing 96dpi');
    cbodpi.Items.Add('Fax 200dpi');
    cbodpi.Items.Add('OCR Text 300dpi');
    cbodpi.Items.Add('Laser Print Fine 600dpi');
    cbodpi.ItemIndex:=0;


    cbopixeltype.Items.Add('Default');
    cbopixeltype.Items.Add('Gray Color');
    cbopixeltype.Items.Add('Black & White Color');
    cbopixeltype.Items.Add('True Color');
    cbopixeltype.ItemIndex:=0;

    iCount :=scanner1.GetNumImageSources();

    for i := 0 To iCount-1 do
       begin
           cboimagesource.Items.Add(scanner1.GetImageSourceName(i));
       end;

       if  cboimagesource.Items.Count > 0 then
              cboimagesource.ItemIndex:=0;
end;



procedure TScannerDlg.FormShow(Sender: TObject);
begin
//  Scanner1.LicenseKey:='9950';
end;

procedure TScannerDlg.Scanner1EndScan(Sender: TObject);
begin
      lbltotalpage.Caption := Format('%d', [Scanner1.TotalPage] );
     lblcurrentpage.Caption := Format('%d', [Scanner1.GetActivePageNo] );
end;

procedure TScannerDlg.Button4Click(Sender: TObject);
begin
      scanner1.SetActivePageNo(strtoint(txtpageno.text));
      lblcurrentpage.Caption :=  Format('%d', [Scanner1.GetActivePageNo] );
end;

procedure TScannerDlg.Button6Click(Sender: TObject);
begin
Scanner1.ApplyChange;
end;

procedure TScannerDlg.Cevir180Click(Sender: TObject);
begin
  Scanner1.Rotate180;
end;

procedure TScannerDlg.Cevir270Click(Sender: TObject);
begin
  scanner1.Rotate270();
end;

procedure TScannerDlg.Cevir90Click(Sender: TObject);
begin
   scanner1.Rotate90();
end;

procedure TScannerDlg.Button19Click(Sender: TObject);
var iresult : bool ;
    Ad: Variant;
begin
  SaveDialog1.Filter :='TIF File|*.tif';
  SaveDialog1.DefaultExt :='tif';

  scanner1.View:=5;
  scanner1.TIFCompression:=cbotifcompression.ItemIndex;


   Tur := 'TIF';
   //ekrandan dosya adý sorup o adla kaydederiz
   if TGirisKutusuEx.BilgiAlEx(DosyaAdiniGirin,TGirdiDenetimleri.Create.Edit(Tur+' '+DosyaAdiniGirin, @Ad)) = mrOk  then begin
      DosyaAdi := GetEnvironmentVariable('Temp');
      DosyaAdi:=DosyaAdi+'\'+VarToStr(Ad);
      if pos('.'+Tur, DosyaAdi)=0 then
         DosyaAdi := DosyaAdi+'.'+Tur;
      scanner1.SaveAllPage2PDF(DosyaAdi, chksavetosingle.Checked,1);
   end;

  //if iresult Then
  // ShowMessage('save c:\testmultitif.tif complete"');


end;

procedure TScannerDlg.chkenablefeederClick(Sender: TObject);
begin

 if chkenablefeeder.Checked then
    chkautosaveallpages.Enabled := true

 else
    chkautosaveallpages.Enabled := false;


end;

procedure TScannerDlg.cxTrackBar1PropertiesChange(Sender: TObject);
begin
   Scanner1.View := cxTrackBar1.Position;
   Scanner1.SetFocus;
end;

procedure TScannerDlg.Scanner1EndAllScan(Sender: TObject);
begin

  if chkautosaveallpages.Checked then
             Button2Click(self);


end;

procedure TScannerDlg.Scanner1ScanningError(Sender: TObject);
begin
ListBox1.Items.Add('Error occur, may be paper jam');
end;

procedure TScannerDlg.SilTusClick(Sender: TObject);
begin
  Scanner1.DeletePage (Scanner1.GetActivePageNo);
  Scanner1.SetActivePageNo (1);
  lbltotalpage.Caption := Format('%d', [Scanner1.TotalPage] );
  lblcurrentpage.Caption := Format('%d', [Scanner1.GetActivePageNo] );
end;

end.





