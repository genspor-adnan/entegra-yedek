unit uPreview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Printers, QRPrntr, ComCtrls, StdCtrls, Buttons, ExtCtrls,
  QuickRpt, jpeg, IdMessage, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdMessageClient, IdSMTP, IdExplicitTLSClientServerBase,
  IdSMTPBase, IdAttachmentFile, {QRXMLSFilt,QRPDFFilt, QRExport, QRWebFilt,}
  cxLookAndFeelPainters, cxButtons, Menus, ImgList,ShellAPI, QRExport,
  grimgctrl, QRPDFFilt, cxGraphics, cxLookAndFeels;

type
  TPreview = class(TForm)
    Panel1: TPanel;
    spdZoomIn: TSpeedButton;
    spdZoomOut: TSpeedButton;
    SpdPrinter: TSpeedButton;
    SpdPrint: TSpeedButton;
    SpdEposta: TSpeedButton;
    SpdKapat: TSpeedButton;
    BtnIlkkay: TSpeedButton;
    BtnGeri: TSpeedButton;
    BtnIleri: TSpeedButton;
    BtnSon: TSpeedButton;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    prOniz: TQRPreview;
    IndyMail: TIdSMTP;
    IndyMessage: TIdMessage;
    Edit1: TEdit;
    lsZoomList: TComboBox;
    ImageList1: TImageList;
    PopupRaporExport: TPopupMenu;
    Excel1: TMenuItem;
    Pdf1: TMenuItem;
    Html1: TMenuItem;
    RTF1: TMenuItem;
    sdExportkaydet: TSaveDialog;
    cxExportTus: TcxButton;
    Txt1: TMenuItem;
    WMF1: TMenuItem;
    procedure SPDZoomInClick(Sender: TObject);
    procedure SPDZoomOutClick(Sender: TObject);
    procedure LSZoomListChange(Sender: TObject);
    procedure SPDPrintClick(Sender: TObject);
    procedure BTNIlkKayClick(Sender: TObject);
    procedure BTNGeriClick(Sender: TObject);
    procedure BTNIleriClick(Sender: TObject);
    procedure BTNSonKayClick(Sender: TObject);
    procedure PROnIzProgressUpdate(Sender: TObject; Progress: Integer);
    procedure SPDPrinterClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RaporuJpegOlarakKaydet(QuickRep: TQuickRep);
    procedure SPDKapatClick(Sender: TObject);
    procedure SpdEpostaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxExportTusClick(Sender: TObject);
    procedure Excel1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Preview: TPreview;
  Raporadi: string;
  Resim:TBitmap;


implementation

uses UAnaForm, URapSyf, UMail, uMailGonder;


{$R *.dfm}

procedure TPreview.RaporuJpegOlarakKaydet(QuickRep: TQuickRep);
var
  JPG: TJPEGImage;
  BMP: TImage;
  mf: TMetafile;
  i: integer;
begin
  //QuickRep.Prepare;

//  bmp.Height:=0;
  for i := uMailGonder.MinN to uMailGonder.MaxN do
  begin
    JPG := TJpegImage.Create;
    BMP := TImage.Create(nil);
    mf := QuickRep.Printer.GetPage(i);
    bmp.Height := bmp.Height + mf.Height;
    bmp.Width := mf.Width;
    bmp.Canvas.Draw(0, bmp.Height - mf.Height, mf);
    JPG.Assign(bmp.picture.bitmap);
    JPG.SaveToFile(ExtractFilePath(Application.ExeName) + '\MailRoot\' + Raporadi + '-' + inttostr(i) + '.jpg');
    JPG.Free;
    bmp.Free;
  end;
end;

procedure TPreview.SPDZoomInClick(Sender: TObject);
begin
  if LSZoomList.ItemIndex <> 13 then
    lszoomlist.ItemIndex := lszoomlist.ItemIndex + 1;
  proniz.Zoom := strtoint(copy(LSZoomList.Items.Strings[LSZoomList.itemindex], 2, length(LSZoomList.Items.Strings[LSZoomList.itemindex]) - 1));
end;

procedure TPreview.SPDZoomOutClick(Sender: TObject);
begin
  if LSZoomList.ItemIndex <> 0 then
    lszoomlist.ItemIndex := lszoomlist.ItemIndex - 1;
  proniz.Zoom := strtoint(copy(LSZoomList.Items.Strings[LSZoomList.itemindex], 2, length(LSZoomList.Items.Strings[LSZoomList.itemindex]) - 1));
end;

procedure TPreview.LSZoomListChange(Sender: TObject);
begin
  proniz.Zoom := strtoint(copy(LSZoomList.Items.Strings[LSZoomList.itemindex], 2, length(LSZoomList.Items.Strings[LSZoomList.itemindex]) - 1));
end;

procedure TPreview.SPDPrintClick(Sender: TObject);
var
AraDeg:String;
begin
{  URapSyf.dokuluyor := false;
  AraDeg:=AnaForm.YaziciYaz.Caption;
  AnaForm.YaziciYaz.Caption:=Raporadi;
  anaform.EkranYazClick(anaform.YaziciYaz);
  AnaForm.YaziciYaz.Caption:=AraDeg;}
//  PROnIz.QRPrinter.Print;
//exit;
//close;
//anaform.EkranYazClick(anaform.EkranYaz);

  URapSyf.dokuluyor := false;
//Y  PROnIz.QRPrinter.PrintMetafile:=true;
  RapSyf.RaporSyf.Print;
//  PROnIz.QRPrinter.Print;
end;

procedure TPreview.BTNIlkKayClick(Sender: TObject);
begin
  PROnIz.PageNumber := 1;
  Label1.Caption := 'Sayfa : ' + inttostr(PROnIz.PageNumber) + '/' + inttostr(PROnIz.QRPrinter.PageCount);
end;

procedure TPreview.BTNGeriClick(Sender: TObject);
begin
  if PROnIz.PageNumber > 1 then
    PROnIz.PageNumber := PROnIz.PageNumber - 1;
  Label1.Caption := 'Sayfa : ' + inttostr(PROnIz.PageNumber) + '/' + inttostr(PROnIz.QRPrinter.PageCount);
end;

procedure TPreview.BTNIleriClick(Sender: TObject);
begin
  if PROnIz.PageNumber < PROnIz.QRPrinter.PageCount then
    PROnIz.PageNumber := PROnIz.PageNumber + 1;
  Label1.Caption := 'Sayfa : ' + inttostr(PROnIz.PageNumber) + '/' + inttostr(PROnIz.QRPrinter.PageCount);
end;

procedure TPreview.BTNSonKayClick(Sender: TObject);
begin
  PROnIz.PageNumber := PROnIz.QRPrinter.PageCount;
  Label1.Caption := 'Sayfa : ' + inttostr(PROnIz.PageNumber) + '/' + inttostr(PROnIz.QRPrinter.PageCount);
end;

procedure TPreview.PROnIzProgressUpdate(Sender: TObject;
  Progress: Integer);
begin
  Progressbar1.Visible := true;
  Progressbar1.Position := progress;
  Label1.Caption := 'Sayfa : ' + inttostr(PROnIz.PageNumber) + '/' + inttostr(PROnIz.QRPrinter.PageCount);
  if Progress = 100 then
    ProgressBar1.Visible := false;
end;

procedure TPreview.SPDPrinterClick(Sender: TObject);
begin
  PROnIz.QRPrinter.PrintSetup;

end;

procedure TPreview.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  action := cafree;
  Preview := nil;
end;

procedure TPreview.SPDEpostaClick(Sender: TObject);
var
  i: integer;
begin
  umailgonder.MaxSay := PROnIz.QRPrinter.PageCount;
  Application.CreateForm(TMailGonder, MailGonder);
  MailGonder.Showmodal;
  MailGonder.Destroy;

  if not uMailGonder.OkV then
    exit;

  RaporuJpegOlarakKaydet(RapSyf.RaporSyf);

  with IndyMessage do
  begin
    From.Address := umailgonder.FromAdres;
    From.Name := umailgonder.FromName;
    Subject := umailgonder.Subject;
    Sender.Address := umailgonder.SenderAdres;
    Sender.Name := umailgonder.SenderName;
    ReplyTo[0].Address := umailgonder.FromAdres;
    ReplyTo[0].Name := umailgonder.FromName;
    Recipients[0].Address := umailgonder.SenderAdres;
    Recipients[0].Name := umailgonder.SenderName;
    ReceiptRecipient.Address := umailgonder.SenderAdres;
    ReceiptRecipient.Name := umailgonder.SenderName;
    Body.Text := umailgonder.Note;
  end;
  IndyMail.UserName := umailgonder.UserName;
  IndyMail.Password := umailgonder.Password;
  IndyMail.Host := umailgonder.ServerName;
  IndyMessage.Recipients.EMailAddresses := umailgonder.SenderAdres;
  IndyMessage.MessageParts.Clear;
  for i := umailgonder.MinN to umailgonder.MaxN do
    TIdAttachmentFile.Create(IndyMessage.MessageParts, ExtractFilePath(Application.ExeName) + '\MailRoot\' + Raporadi + '-' + inttostr(i) + '.jpg');

  IndyMail.Port := 25;
  try
    if IndyMail.Connected then
      IndyMail.Disconnect;
    {  idris
    if umailgonder.Kimlik then
      IndyMail.AuthType := atDefault
    else
      IndyMail.AuthType := atNone;
       }
    IndyMail.Connect;
    IndyMail.Send(IndyMessage);
    IndyMail.Disconnect;
  {for i:=umailgonder.MinN to umailgonder.MaxN do
    DeleteFile(ExtractFilePath(Application.ExeName) + '\MailRoot\' + Raporadi + '-' + inttostr(i) + '.jpg');}
    Application.MessageBox('Mail baþarý ile gönderildi...', 'Uyarý !!!', 64);
  except
    Application.MessageBox('Mail gönderilemedi', 'Uyarý !!!', MB_ICONSTOP)
  end;

end;

procedure TPreview.SPDKapatClick(Sender: TObject);
begin
  Close;
end;

procedure TPreview.FormCreate(Sender: TObject);
begin
  lsZoomList.ItemIndex := 9;
end;


procedure TPreview.Excel1Click(Sender: TObject);
begin
  resim:= TBitmap.Create;
  cxExportTus.Caption := TMenuItem(Sender).Caption;
  ImageList1.GetBitmap(TMenuItem(Sender).ImageIndex,resim);
  cxExportTus.Glyph:= resim;
  resim.Free;

end;

procedure TPreview.cxExportTusClick(Sender: TObject);
var s,baslik :string;
    aPDFFilt : TQRPDFDocumentFilter;
begin
    s:= AnaForm.EkranYaz.Caption;
    baslik:= StringReplace(cxExportTus.Caption ,'&','',[rfReplaceAll]) ;

    if baslik = 'Excel' then
    begin
      sdExportkaydet.FilterIndex :=1 ;
      If sdExportkaydet.Execute then
      begin
        s:=sdExportkaydet.FileName +'.xls';
        prOniz.QRPrinter.ExportToFilter( (TQRXLSFilter.Create(s)));
      end;
    end
    else if  baslik = 'Pdf' then
    begin
      sdExportkaydet.FilterIndex :=2 ;
      If sdExportkaydet.Execute then
      begin

//        s:=sdExportkaydet.FileName +'.pdf';
//        prOniz.QRPrinter.ExportToFilter( (TQRPDFDocumentFilter.Create(s)));
        s:=sdExportkaydet.FileName +'.pdf';
        aPDFFilt := TQRPDFDocumentFilter.Create(s);
        aPDFFilt.AddFontMap( 'Arial:Arial Tur' );
        aPDFFilt.AddFontMap( 'Times-new-roman:Times-new-roman Tur' );
        //aPDFFilt := prOniz.QRPrinter.ExportToFilter( (TQRPDFDocumentFilter.Create(s)));
        prOniz.QRPrinter.ExportToFilter( aPDFFilt );
        aPDFFilt.free;
      end;
    end
    else if  baslik = 'Html' then
    begin
      sdExportkaydet.FilterIndex :=3 ;
      If sdExportkaydet.Execute then
      begin
        s:=sdExportkaydet.FileName +'.html';
       // prOniz.QRPrinter.ExportToFilter( (TQRHTMLDocumentFilter.Create(s)));
      end;
    end
    else if  baslik = 'Rtf' then
    begin
      sdExportkaydet.FilterIndex :=4;
      If sdExportkaydet.Execute then
      begin
        s:=sdExportkaydet.FileName +'.rtf';
        prOniz.QRPrinter.ExportToFilter( (TQRRTFExportFilter.Create(s)));
      end;
    end
    else if  baslik = 'Txt' then
    begin
      sdExportkaydet.FilterIndex :=5;
      If sdExportkaydet.Execute then
      begin
        s:=sdExportkaydet.FileName +'.txt';
        prOniz.QRPrinter.ExportToFilter( (TQRAsciiExportFilter.Create(s)));
      end;
    end
    else if  baslik = 'Resim' then
    begin
      sdExportkaydet.FilterIndex :=6;
      If sdExportkaydet.Execute then
      begin
        s:=sdExportkaydet.FileName +'.wmf';
        prOniz.QRPrinter.ExportToFilter( (TQRWMFExportFilter.Create(s)));
      end;
    end;
{    else if  baslik = 'Xml' then
    begin
      prOniz.QRPrinter.ExportToFilter( (TQRXDocumentFilter.Create(s+'.xml')));
      s:= ExtractFileDir( Application.ExeName)+'\'+ s+'.xml'  ;
    end ;}
    ShellExecute(Handle, 'open', pchar(s),nil,nil,SW_SHOWNORMAL) ;
end;


end.
