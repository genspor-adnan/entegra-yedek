unit UHavaleEFT;

(*
  Değişiklikler
  2010-05-17
  1 - ilk açılışta en üstteki bankanın ve bu bankaya gönderilecek havale/eftlerin tümünün seçili gelmesi sağlandı.
  2 - banka seçimi değiştirildiğinde yeni  bankaya gönderilecek havale/eftlerin tümünün seçili gelmesi sağlandı.
  3 - Talimat önizleme sayfasının tam ekran gelmesi sağlandı.
  4 - Seçili havale olmaması durumuna hata mesajı eklendi "secimyokhata"
  *)
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, cxStyles, dxSkinscxPCPainter, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxImage, cxTextEdit,
  cxLookAndFeelPainters, cxCheckBox, cxDBEdit, cxGroupBox, StdCtrls, cxPC,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxControls, cxGridCustomView, cxGrid, cxContainer, cxLabel,
  ExtCtrls, ComCtrls, ToolWin, FireDAC.Comp.Client, Menus, JvWizard, cxButtons, JvExControls,
  fs_ijs, frxOLE, frxClass, frxPreview, frxDBSet, frxExportPDF, Types, ImgList,
  cxMaskEdit, cxDropDownEdit,
  IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTP,
  GIFImg,JvInstallLabel, PngImageList,UGunlukTakvim, cxImageComboBox,
  dxSkinLondonLiquidSky, cxLookAndFeels, cxNavigator, IdGlobal, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;//  ScBridge, ScSSHClient, ScSFTPClient, ScSSHChannel,ScIndy,ScSFTPUtils,scsshutil,

type
  THavaleEFTEkrani = class(TForm)
    TabGonderen: TFDQuery;
    DtsGonderen: TDataSource;
    DtsAlici: TDataSource;
    TabAlici: TFDQuery;
    ToolBar1: TToolBar;
    btnKapat: TToolButton;
    Panel1: TPanel;
    Panel2: TPanel;
    cxLabel1: TcxLabel;
    cxGrid3: TcxGrid;
    GridViewBanka: TcxGridDBTableView;
    GridViewBankaLOGO: TcxGridDBColumn;
    GridViewBankaBANKAKODU: TcxGridDBColumn;
    GridViewBankaBANKAADI: TcxGridDBColumn;
    GridViewBankaSUBEKODU: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    GridViewBankaSUBEADI: TcxGridDBColumn;
    GridViewBankaHESAPNO: TcxGridDBColumn;
    GridViewBankaMUSTERINO: TcxGridDBColumn;
    GridViewBankaEMAIL: TcxGridDBColumn;
    HavaleWizard: TJvWizard;
    SayfaTalimat3: TJvWizardInteriorPage;
    SayfaDurumGoruntule5: TJvWizardInteriorPage;
    SayfaGiris1: TJvWizardWelcomePage;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1UNVAN: TcxGridDBColumn;
    cxGridDBTableView1BANKAADI: TcxGridDBColumn;
    cxGridDBTableView1BANKAKODU: TcxGridDBColumn;
    cxGridDBTableView1SUBEKODU: TcxGridDBColumn;
    cxGridDBTableView1SUBEADI: TcxGridDBColumn;
    cxGridDBTableView1HESAPNO1: TcxGridDBColumn;
    cxGridDBTableView1IBAN: TcxGridDBColumn;
    cxGridDBTableView1ACIKLAMA: TcxGridDBColumn;
    cxGridDBTableView1TUTAR: TcxGridDBColumn;
    cxGridDBTableView1DOVIZ: TcxGridDBColumn;
    cxGridDBTableView1DURUM: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    SayfaSon6: TJvWizardInteriorPage;
    SayfaIslemSecimi2: TJvWizardInteriorPage;
    cxGridDBTableView1SEC: TcxGridDBColumn;
    GridViewBankaKUR: TcxGridDBColumn;
    frxPreview1: TfrxPreview;
    frxReport1: TfrxReport;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    ToolBar2: TToolBar;
    YaziciYaz: TToolButton;
    frxTalimat: TfrxDBDataset;
    frxPDFExport1: TfrxPDFExport;
    Label1: TcxLabel;
    Label2: TcxLabel;
    {ScSSHClient1: TScSSHClient;
    ScFileStorage1: TScFileStorage;
    ScSSHChannel1: TScSSHChannel;}
    IdFTP1: TIdFTP;
    TabBankaAyar: TFDQuery;
    LabelDosyalarHazirlaniyor: TcxLabel;
    LabelDosyalarHazirlandi: TcxLabel;
    LabelPDFHazir: TcxLabel;
    LabelTextHazir: TcxLabel;
    LabelPDFTamam: TcxLabel;
    LabelTXTTamam: TcxLabel;
    LabelPDFIptal: TcxLabel;
    LabelTXTIptal: TcxLabel;
    SayfaImzalamaIslemleri4: TJvWizardInteriorPage;
    //ScSFTPClient1: TScSFTPClient;
    cxButton1: TcxButton;
    ImageSertifika: TcxImage;
    JvInstallLabel1: TJvInstallLabel;
    imgListYukleme: TPngImageList;
    JvInstallLabel2: TJvInstallLabel;
    DtsBankaAyar: TDataSource;
    ComboOperator: TcxDBImageComboBox;
    EditTelefon: TcxDBTextEdit;
    procedure btnKapatClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SayfaGiris1NextButtonClick(Sender: TObject; var Stop: Boolean);
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    procedure ImzaTusClick(Sender: TObject);
    procedure YaziciYazMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure GridViewBankaCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure cxGridDBTableView1StylesGetContentStyle
      (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure cxGridDBTableView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    //procedure ScSSHClient1BeforeConnect(Sender: TObject);
    //procedure ScSSHClient1ServerKeyValidate(Sender: TObject; NewServerKey: TScKey; var Accept: Boolean);
    procedure frxTalimatNext(Sender: TObject);
    procedure IdFTP1Connected(Sender: TObject);
    procedure IdFTP1DataChannelCreate(ASender: TObject;
      ADataChannel: TIdTCPConnection);
    procedure SayfaIslemSecimi2Page(Sender: TObject);
    procedure SayfaTalimat3Page(Sender: TObject);
    procedure SayfaDurumGoruntule5Page(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure SayfaImzalamaIslemleri4EnterPage(Sender: TObject;
      const FromPage: TJvWizardCustomPage);
//    procedure ScSFTPClient1Success(Sender: TObject; Operation: TScSFTPOperation;
//      const FileName: string; const Handle: TBytes; const Message: string);
//    procedure ScSFTPClient1Disconnect(Sender: TObject);
    procedure IdFTP1AfterPut(Sender: TObject);
    procedure IdFTP1Disconnected(Sender: TObject);
    procedure IdFTP1WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure IdFTP1WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
    procedure IdFTP1Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure IdFTP1AfterClientLogin(Sender: TObject);
    procedure IdFTP1BannerBeforeLogin(ASender: TObject; const AMsg: string);
    procedure IdFTP1BannerAfterLogin(ASender: TObject; const AMsg: string);
    procedure SayfaImzalamaIslemleri4Page(Sender: TObject);
    //procedure ScSSHClient1BeforeDisconnect(Sender: TObject);
    //procedure ScSSHClient1AfterConnect(Sender: TObject);
    //procedure ScSSHClient1AfterDisconnect(Sender: TObject);
    //procedure ScSFTPClient1CreateLocalFile(Sender: TObject; const LocalFileName,
    //  RemoteFileName: string; Attrs: TScSFTPFileAttributes;
    //  var Handle: Cardinal);
    procedure HavaleWizardCancelButtonClick(Sender: TObject);
    procedure HavaleWizardFinishButtonClick(Sender: TObject);


  private
    { Private declarations }
    FSimdikiAdim : Integer;
    GFTPDosyaAdi : string;
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    procedure FTPyeGonder(FTPDosya : TStream ;FTPDosyaYeri:String ; FTPDosyaAdi: String);
    procedure DurumlariSifirla(JvInstallLabel:TJvInstallLabel);
    procedure AdimDegistir(JvInstallLabel:TJvInstallLabel;AYeniAdim, AEskiAdim: Integer);
  public
    { Public declarations }
    Tarih: TDateTime;
  end;

//Resourcestring
//  Logayazamadihata = 'Dosya imza log veritabanına kaydedilemedi.';
//  yanlistelnohata = 'Geçerli bir telefon numarası giriniz.';
//  yanlisoperatorhata = 'Elektronik imza türkcell ve avea için kullanılmaktadır, operatör seçiminizi yapınız.';
//  eimzahata = 'Elektronik imza başarısız.';
//  secimyokhata = 'En az bir Havale/EFT seçmelisiniz.';
//  bankadanodemeyokhata = 'Seçtiğiniz tarihte banka üzerinden ödemeniz bulunmamaktadır. Başka bir tarih seçin yada ödeme türünüzü düzeltin.';
//  Dosyaturuhata = 'Yanlış türde bir dosya oluşturuldu.';
//  Eminmisin = 'Havale/Eft Sihirbazından çıkmak istediğinize emin misiniz?';

const
  IMZA_ADIM_DOSYATURU = 0;
  IMZA_ADIM_BAGLANTI_KUR = 1;
  IMZA_ADIM_DOSYA_GONDER = 2;
  IMZA_ADIM_PARMAK_IZI = 3;
  IMZA_ADIM_IMZALAYAN = 4;
  IMZA_ADIM_DOSYA_KAYDET = 5;
  IMZA_ADIM_ISLEM_TAMAM = 6;
  FTP_ADIM_CONNECTING = 0;
  FTP_ADIM_AUTHENTICATING = 1;
  FTP_ADIM_VERIFY_KEY = 2;
  FTP_ADIM_CONNECTED = 3;
  FTP_ADIM_SYNCING = 4;
  FTP_ADIM_CREATING_FILE = 5;
  FTP_ADIM_FILENAME = 6;
  FTP_ADIM_SENDING = 7;
  FTP_ADIM_SENT = 8;
  FTP_ADIM_DISCONNECT = 9;
  FTP_ADIM_FINISH = 10;
var
  HavaleEFTEkrani: THavaleEFTEkrani;
  TextDosyaAdi,PDFDosyaAdi,FTPDosyaYeri:string;
  FTPDosya: TStream ;
  iii : Integer;

implementation

uses PrjConst,Banka_TEB, Banka_Garanti, Banka_YKB,Banka_Finans, Banka_Deniz, Banka_HSBC, Banka_Ak,Banka_ING,UFastRap, MSS_Sender, Utablo, ZlibEx,
  URaporAraclari ,UFtpBilgileri,UBinarySave,LocOnFly; //,ScCLRSocket, ScCLRClasses;

{$R *.dfm}
function LeadingZero(ANumber: string;ADigit: Integer): string;
begin
  Result := ANumber;
  while Length(Result) < ADigit do   //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalı
    Result := '0' + Result;
end;
procedure ImzalamaIslemleri(DosyaAdi:String); // (Tablo1:TFDQuery; AlanAdi, DosyaAdi:string);
var
  tmpdosyaadi,mes, telno, DosyaTuru: string;
  tempfile: TFileStream;
  fs, fs2: TMemoryStream;
  byt: TByteDynArray;
  pTemp: pointer;
  HResult: HashResult;
  SR: SignatureByteResult;
  gsmop: Integer;

  procedure CopyToStream(const InArray: TByteDynArray; outStram: TStream);
  var
    pTemp: pointer;
  begin
    pTemp := @InArray[0];
    outStram.Write(pTemp^, Length(InArray));
  end;

  procedure LogaYaz;
  var
    CompressedStream_: TMemoryStream;
  begin
    HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,IMZA_ADIM_DOSYA_KAYDET,IMZA_ADIM_IMZALAYAN);
    Tablo.Query1.Close;
    Tablo.Query1.SQL.text := 'Insert into IMZALOG (TARIH,EK,SUBEID) values(:Tarih, :Dosya,'+IntToStr(SubeId)+')';
    Tablo.Query1.Params[0].Value := now;
    // dosyayı zipleyip kaydedelim
    CompressedStream_ := TMemoryStream.Create;
    CompressedStream_.Clear;
    CompressedStream_.Position := 0;
    ZCompressStream(fs, CompressedStream_);
    try
      Tablo.Query1.Params[1].LoadFromStream(CompressedStream_, ftBlob);
      CompressedStream_.free;
      Tablo.Query1.ExecSQL;
    except
      ShowMessage(Logayazamadihata);
    end;
  end;

begin
  HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,IMZA_ADIM_DOSYATURU,-1);
  fs := TMemoryStream.Create;
  HavaleEFTEkrani.JvInstallLabel1.Lines[IMZA_ADIM_DOSYATURU] := ' ' ;
  DosyaTuru := ExtractFileExt(Dosyaadi);
  if DosyaTuru = '.pdf' then begin
     HavaleEFTEkrani.JvInstallLabel1.Lines[IMZA_ADIM_DOSYATURU] := 'PDF dosya onay için hazırlanıyor...' ;
     fs.loadfromfile('PDFDosya\'+DosyaAdi);
     tmpdosyaadi := 'PDFDosyaOK\'
  End else if DosyaTuru = '.txt' then begin
     HavaleEFTEkrani.JvInstallLabel1.Lines[IMZA_ADIM_DOSYATURU] := 'Text dosya onay için hazırlanıyor...' ;
     fs.loadfromfile('TextDosya\'+DosyaAdi);
     tmpdosyaadi := 'TextDosyaOK\'
  End Else
     raise exception.Create(Dosyaturuhata);
  HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,IMZA_ADIM_BAGLANTI_KUR,IMZA_ADIM_DOSYATURU);
  /// / web servis bizden imzalanacak olan datayı TByteDynArray tipinde istiyor. Onun için fs içindeki datayı buna çeviririz
  // TMemoryStream --> TByteDynArray;
  fs.Position := 0;
  SetLength(byt, fs.Size);
  pTemp := @byt[0];
  fs.Position := 0;
  fs.Read(pTemp^, fs.Size);
  // Artık burada E-İmza firmasına dosyayı gönderebiliriz..

  if Length(HavaleEFTEkrani.EditTelefon.text) = 11 then
    telno := HavaleEFTEkrani.EditTelefon.text
  else
    raise exception.Create(yanlistelnohata);

  if HavaleEFTEkrani.ComboOperator.text = 'TürkCell' then
    gsmop := 1
  Else if HavaleEFTEkrani.ComboOperator.text = 'Avea' then
    gsmop := 2
  Else
    raise exception.Create(yanlisoperatorhata);

  HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,IMZA_ADIM_DOSYA_GONDER,IMZA_ADIM_BAGLANTI_KUR);
  HResult := EImza.GetHashForGsmOperator(byt, telno, gsmop);

  HavaleEFTEkrani.JvInstallLabel1.Lines[IMZA_ADIM_PARMAK_IZI] := 'Parmakizi :'+ HResult.Parmakizi;
  HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,IMZA_ADIM_PARMAK_IZI,IMZA_ADIM_DOSYA_GONDER);
  // byt:benim pdf dosyam,yani talimat;;; 1 : Turkcell 2:Avea
  if HResult.ResultCode = 0 then
  begin
    // Gelen parmakizini ekranda gösterelim, Aynı parmakizi cep telefonunda da görünecek
    //HavaleEFTEkrani.LabelParmakIzi.Caption := '   Parmak İzi : ' + HResult.Parmakizi;
    SR := EImza.GetSignatureByte('E-imza mesaji', HResult.ApTransId);
    // Burda bekleniyor.  telefona mesaj gidiyor ve alttakiler dönüyor
    case SR.ResultCode of
      0:  mes := 'Başarılı';
      1:  mes := 'Turkcell e gönderilemedi';
      2:  mes := 'İşlem zamanaşımına uğradı';
      3:  mes := 'Cevap geldi ancak imza geçersiz';
      9:  mes := 'Genel Hata';
    end;
    HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,IMZA_ADIM_IMZALAYAN,IMZA_ADIM_PARMAK_IZI);
    HavaleEFTEkrani.JvInstallLabel1.Lines[IMZA_ADIM_IMZALAYAN] := SR.SignerName + ' Tarafından İmzalandı.';
    // showmessage(SR.Message_); //Doğrulama logu (hata olduğunda EGA ya bildireceğiz
    //ShowMessage(SR.SignerName); // İmzalanmış data
    // SR.FSignedData;    //gelen Data  base 64   (  xxx.P7B olarak kaydedersem içini görmüş olurum)
    // datayı çevirip kaydedelim
    fs2 := TMemoryStream.Create;
    CopyToStream(SR.SignedData, fs2);

  end
  else
    raise exception.Create(eimzahata); // h.result.message_
  fs2.Position := 0;
  // İmzalı dosya olarak kaydedelim
  //  tmpdosyaadi := GetEnvironmentVariable('Temp') + '\' + FormatDateTime('ddmmyyhhnnss_', now);

  tempfile := TFileStream.Create(tmpdosyaadi+DosyaAdi, fmCreate);
  tempfile.CopyFrom(fs2, fs2.Size);
  // İmzalı dosyayı loga yazalım
  LogaYaz;
  tempfile.free;
  fs.free;
  fs2.free;
  HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,IMZA_ADIM_ISLEM_TAMAM,IMZA_ADIM_DOSYA_KAYDET);
  HavaleEFTEkrani.AdimDegistir(HavaleEFTEkrani.JvInstallLabel1,-1,IMZA_ADIM_ISLEM_TAMAM);
  HavaleEFTEkrani.ImageSertifika.Visible := True;
end;

procedure THavaleEFTEkrani.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxTalimat);

end;

procedure THavaleEFTEkrani.YaziciYazMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    YazdirmayaHazirla(FastRaporDlg.frxReport1);
end;

procedure THavaleEFTEkrani.AdimDegistir(JvInstallLabel:TJvInstallLabel;AYeniAdim, AEskiAdim: Integer);
begin
  if AYeniAdim > -1 then
    JvInstallLabel.SetStyle(AYeniAdim,1,[fsBold]);
  if (AEskiAdim > -1) then
    JvInstallLabel.SetStyle(AEskiAdim ,2,[]);
  Application.HandleMessage;
  JvInstallLabel.Refresh;
end;

procedure THavaleEFTEkrani.BaskiOnizlemeMenuClick(Sender: TObject);
var
  s: string;
begin
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, 'HavaleEFTEkrani', s)
end;

procedure THavaleEFTEkrani.btnKapatClick(Sender: TObject);
begin
     if MessageDlg(Eminmisin, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        Close;
end;

procedure THavaleEFTEkrani.cxButton1Click(Sender: TObject);
begin
  //  HavaleWizard.ActivePage := SayfaDurumGoruntule5;
  if TabBankaAyar.FieldByName('TALIMAT_IMZALA').AsBoolean = false then Begin
      If TabBankaAyar.FieldByName('TEXT_IMZALA').AsBoolean = True then
         ImzalamaIslemleri(TextDosyaAdi)
      {else
         HavaleWizard.ActivePage := SayfaDurumGoruntule5;}
  End else if TabBankaAyar.FieldByName('TALIMAT_IMZALA').AsBoolean = True then Begin
      If TabBankaAyar.FieldByName('TEXT_IMZALA').AsBoolean = True then
         ImzalamaIslemleri(TextDosyaAdi);
      ImzalamaIslemleri(PDFDosyaAdi);
  End;
  SayfaImzalamaIslemleri4.EnabledButtons := [bkNext, bkCancel];
end;

procedure THavaleEFTEkrani.cxGridDBTableView1CellClick
  (Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
Var
  clmsec: TcxGridDBColumn;
begin
  clmsec := cxGridDBTableView1SEC;
  if clmsec.EditValue = True then
    clmsec.EditValue := False
  else
    clmsec.EditValue := True;
  // sağ tarafta banka işaretlendiğinde içerikteki tüm havalelerin seçili gelmesi sağlandı.
  cxGridDBTableView1.DataController.SelectAll;

end;

procedure THavaleEFTEkrani.cxGridDBTableView1StylesGetContentStyle
  (Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
Var
  AColumn1: TcxCustomGridTableItem;
  s: string;
Begin
  AColumn1 := (Sender as TcxGridDBTableView).Columns[0];
  if ARecord.Values[AColumn1.Index] = null then
    exit;
  s := VarToStr(ARecord.Values[AColumn1.Index]);
  if VarToStr(ARecord.Values[AColumn1.Index]) = 'True' then
  Begin
    // Tablo.cxStyleKuyruk.Color := clRed;
    ARecord.Selected := True;
  End
  else
  Begin
    ARecord.Selected := False;
    // Tablo.cxStyleKuyruk.Color := clWhite;
  End;

  // AStyle := Tablo.;
end;

procedure THavaleEFTEkrani.DurumlariSifirla(JvInstallLabel:TJvInstallLabel);
Var
  i : Integer;
begin
  for i := 0 to JvInstallLabel.Lines.Count - 1 do
    JvInstallLabel.SetStyle(i,0,[]);
  FSimdikiAdim := -1;
end;

procedure THavaleEFTEkrani.FormCreate(Sender: TObject);
Var
  ra: string;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TRaporAraclari.RaporPopupMenuHazirla('HavaleEFTEkrani',PopupMenuYaz,ra,FastRaporDlg.RaporSecClick);
  YaziciYaz.Caption := ra;

Tablo.GridTurkcelestir;


end;

procedure THavaleEFTEkrani.FormShow(Sender: TObject);
Var
  Hesap:string;
begin
  TabGonderen.DisableControls;
  TabGonderen.Close;
  TabGonderen.Params[0].Value := Tarih;
  TabGonderen.Open;
  TabGonderen.EnableControls;
  // ilk bankanın seçili gelmesi ve o banka hareketlerinin sağ tarafta gözükmesi..
  TabGonderen.first;
  Hesap:= TabGonderen.FieldByName('HESAPID').AsString;
  if not TabGonderen.ControlsDisabled then
  begin
    TabAlici.Close;
    TabAlici.Params[0].Value := Tarih;
    TabAlici.Params[1].Value := Hesap;
    TabAlici.Open;
    TabAlici.First;
    while not HavaleEFTEkrani.TabAlici.eof do
    begin
      cxGridDBTableView1SEC.EditValue := True;
      TabAlici.next;
    end;
  end;
end;

procedure THavaleEFTEkrani.frxTalimatNext(Sender: TObject);
begin
  //tıklı olmayan satırlar preview da gözükmesin.
  if cxGridDBTableView1SEC.EditValue <> True then  begin
     Tabalici.next;
  end;
end;

procedure THavaleEFTEkrani.GridViewBankaCellClick
  (Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if not TabGonderen.ControlsDisabled then
  begin
    TabAlici.Close;
    TabAlici.Params[0].Value := Tarih;
    TabAlici.Params[1].Value := TabGonderen.FieldByName('HESAPID').AsString;
    TabAlici.Open;
    while not HavaleEFTEkrani.TabAlici.eof do
    begin
      cxGridDBTableView1SEC.EditValue := True;
      TabAlici.next;
    end;
  end;
end;


procedure THavaleEFTEkrani.HavaleWizardCancelButtonClick(Sender: TObject);
begin
  if MessageDlg(Eminmisin, mtInformation, [mbYes, mbNo], 0) = mrYes then
     //Application.MessageBox('MB_OKCANCEL+MB_ICONSTOP','başlık',MB_OKCANCEL+MB_ICONINFORMATION);
     Close
  else
    ModalResult:= mrNone;
end;

procedure THavaleEFTEkrani.HavaleWizardFinishButtonClick(Sender: TObject);
begin
  Close;
end;

function YeniDesenDosyasiOlustur(BankaKodu : Integer):String;
begin
 { // İşaretlilerden Text oluşturalım
  case BankaKodu of
   10:   Result := TEB_Dosya_Olustur; // TC ZIRAAT BANK A.S.
   12:   Result := TEB_Dosya_Olustur; // HALK BANKASI
   15:   Result := TEB_Dosya_Olustur; // T.VAKIFLAR BANKASI T.A.O.
   32:   Result := TEB_Dosya_Olustur; // T.EKONOMİ BANKASI A.S.
   46:   Result := Ak_Dosya_Olustur ;// AKBANK T.A.S.
   59:   Result := TEB_Dosya_Olustur; // ŞEKERBANK T.A.S.
   62:   Result := Garanti_Dosya_Olustur; // T.GARANTİ BANKASI A.S.
   64:   Result := TEB_Dosya_Olustur; // T.IŞ BANKASI A.S.
   67:   Result := YKB_Dosya_Olustur; // YAPI VE KREDI BANKASI A.S.
   71:   Result := TEB_Dosya_Olustur; // FORTIS BANK A.S.
   92:   Result := TEB_Dosya_Olustur; // CITIBANK A.S.
   96:   Result := TEB_Dosya_Olustur; // TURKISHBANK
   99:   Result := ING_Dosya_Olustur; // ING BANK A.S.
   100:  Result := TEB_Dosya_Olustur; // ADABANK A.S.
   109:  Result := TEB_Dosya_Olustur; // TEKSTIL BANKASI A.S.
   111:  Result := Finans_Dosya_Olustur; // FINANSBANK A.S.
   123:  Result := HSBC_Dosya_Olustur; // HSBC BANK A.S.
   124:  Result := TEB_Dosya_Olustur; // ALTERNATIFBANK A.S.
   125:  Result := TEB_Dosya_Olustur; // EUROBANK TEKFEN A.S.
   134:  Result := Deniz_Dosya_Olustur; // DENIZ BANK A.S.
   135:  Result := TEB_Dosya_Olustur; // ANADOLUBANK A.S.
   141:  Result := TEB_Dosya_Olustur; // NUROL YATIRIM BANKASI A.S.
   142:  Result := TEB_Dosya_Olustur; // BANKPOZITIF KREDI VE KALK.BANK.A.S.
   203:  Result := TEB_Dosya_Olustur; // ALBARAKA TURK KATILIM BANKASI A.S.
   205:  Result := TEB_Dosya_Olustur; // KUVEYT TURK KATILIM BANKASI A.S.
   206:  Result := TEB_Dosya_Olustur; // TURKIYE FINANS KATILIM BANKASI A.S.
   208:  Result := TEB_Dosya_Olustur; // ASYA KATILIM BANKASI A.S.
  end;
      TextDosyaAdi:=Result;}
end;

procedure THavaleEFTEkrani.IdFTP1AfterClientLogin(Sender: TObject);//4
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_SYNCING,FTP_ADIM_CONNECTED);
end;

procedure THavaleEFTEkrani.IdFTP1AfterPut(Sender: TObject); //9
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_DISCONNECT,FTP_ADIM_SENT);
end;

procedure THavaleEFTEkrani.IdFTP1BannerAfterLogin(ASender: TObject;//3
  const AMsg: string);
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_CONNECTED,FTP_ADIM_VERIFY_KEY);
end;

procedure THavaleEFTEkrani.IdFTP1BannerBeforeLogin(ASender: TObject; //2
  const AMsg: string);
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_VERIFY_KEY,FTP_ADIM_AUTHENTICATING);
end;

procedure THavaleEFTEkrani.IdFTP1Connected(Sender: TObject);  //1
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_AUTHENTICATING,FTP_ADIM_CONNECTING);

end;

procedure THavaleEFTEkrani.IdFTP1DataChannelCreate(ASender: TObject;//5
  ADataChannel: TIdTCPConnection);
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_CREATING_FILE,FTP_ADIM_SYNCING);
end;

procedure THavaleEFTEkrani.IdFTP1Disconnected(Sender: TObject); //10
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_FINISH,FTP_ADIM_DISCONNECT);
end;

procedure THavaleEFTEkrani.IdFTP1Work(ASender: TObject; AWorkMode: TWorkMode;//7
  AWorkCount: Int64);
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_SENDING,FTP_ADIM_FILENAME);
end;

procedure THavaleEFTEkrani.IdFTP1WorkBegin(ASender: TObject; //6
  AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  JvInstallLabel2.Lines[FTP_ADIM_FILENAME] := GFTPDosyaAdi;
  AdimDegistir(JvInstallLabel2,FTP_ADIM_FILENAME,FTP_ADIM_CREATING_FILE);
end;

procedure THavaleEFTEkrani.IdFTP1WorkEnd(ASender: TObject;  //8
  AWorkMode: TWorkMode);
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_SENT,FTP_ADIM_SENDING);
end;

procedure THavaleEFTEkrani.ImzaTusClick(Sender: TObject);
begin
  SayfaTalimat3.EnabledButtons := [bkNext, bkCancel];
end;


Function SSH_HataGoster(ErrorCode:integer):string;
Begin
//SFTP toolunun gönderdiği hata kodu
//EScSFTPError.ErrorCode ile gelen hata kodunun açıklaması
  Case ErrorCode of
     0:	  Result :=	'SSH_FX_OK '	;
     1:	  Result :=	'SSH_FX_EOF '	;
     2:	  Result :=	'SSH_FX_NO_SUCH_FILE '	;
     3:	  Result :=	'SSH_FX_PERMISSION_DENIED '	;
     4:	  Result :=	'SSH_FX_FAILURE '	;
     5:	  Result :=	'SSH_FX_BAD_MESSAGE '	;
     6:	  Result :=	'SSH_FX_NO_CONNECTION '	;
     7:	  Result :=	'SSH_FX_CONNECTION_LOST '	;
     8:	  Result :=	'SSH_FX_OP_UNSUPPORTED '	;
     9:	  Result :=	'SSH_FX_INVALID_HANDLE '	;
     10:	Result :=	'SSH_FX_NO_SUCH_PATH '	;
     11:	Result :=	'SSH_FX_FILE_ALREADY_EXISTS '	;
     12:	Result :=	'SSH_FX_WRITE_PROTECT '	;
     13:	Result :=	'SSH_FX_NO_MEDIA '	;
     14:	Result :=	'SSH_FX_NO_SPACE_ON_FILESYSTEM '	;
     15:	Result :=	'SSH_FX_QUOTA_EXCEEDED '	;
     16:	Result :=	'SSH_FX_UNKNOWN_PRINCIPAL '	;
     17:	Result :=	'SSH_FX_LOCK_CONFLICT '	;
     18:	Result :=	'SSH_FX_DIR_NOT_EMPTY '	;
     19:	Result :=	'SSH_FX_NOT_A_DIRECTORY '	;
     20:	Result :=	'SSH_FX_INVALID_FILENAME '	;
     21:	Result :=	'SSH_FX_LINK_LOOP '	;
     22:	Result :=	'SSH_FX_CANNOT_DELETE '	;
     23:	Result :=	'SSH_FX_INVALID_PARAMETER '	;
     24:	Result :=	'SSH_FX_FILE_IS_A_DIRECTORY '	;
     25:	Result :=	'SSH_FX_BYTE_RANGE_LOCK_CONFLICT '	;
     26:	Result :=	'SSH_FX_BYTE_RANGE_LOCK_REFUSED '	;
     27:	Result :=	'SSH_FX_DELETE_PENDING '	;
     28:	Result :=	'SSH_FX_FILE_CORRUPT '	;
     29:	Result :=	'SSH_FX_OWNER_INVALID '	;
     30:	Result :=	'SSH_FX_GROUP_INVALID '	;
    Else  Result := 'SSH_FX_UNKNOWN' ;
  End;
End;

procedure THavaleEFTEkrani.FTPyeGonder(FTPDosya : TStream ;FTPDosyaYeri:String ; FTPDosyaAdi: String);
var
  i:Integer;
  GuvenlikTuru,Destination:String;
 // SSHStream : TScSSHStream;
begin
  GFTPDosyaAdi := FTPDosyaAdi;
  //ftp ye gönderilmeyecekse bu sayfayı geçmesi gerekiyor..
  GuvenlikTuru := TabBankaAyar.FieldByName('FTP_GUVENLIK_TURU').AsString;
  AdimDegistir(JvInstallLabel2,FTP_ADIM_CONNECTING,-1);
  if GuvenlikTuru='Yok' then
    i:=0
  Else if GuvenlikTuru='SSH' then
    i:=1
  Else if GuvenlikTuru='SSL' then
    i:=2
  Else
    raise exception.Create(FTPhatali);

  case i of
    0:Begin
        IdFTP1.Host := TabBankaAyar.FieldByName('FTP_ADRES').AsString;
        IdFTP1.Username := TabBankaAyar.FieldByName('FTP_USER').AsString;
        IdFTP1.Password := TabBankaAyar.FieldByName('FTP_PASSWORD').AsString;
        IdFTP1.Port := TabBankaAyar.FieldByName('FTP_PORT').Value;
        Destination:= TabBankaAyar.FieldByName('FTP_DIZIN').AsString;
        try
          IdFTP1.Connect;
        Except
          raise exception.Create('Bağlantıda Hata');
        end;
        FTPDosyaAdi:=Destination+FTPDosyaAdi;
        IdFTP1.Put(FTPDosya,FTPDosyaAdi,False);
        FTPDosya.Free;
        IdFTP1.Disconnect;
      End;

    1:Begin {
        FTPDosya.Free;
        if False then begin
           ScSSHClient1.Authentication := atPassword;
           ScSSHClient1.User := TabBankaAyar.FieldByName('FTP_USER').AsString  ;
           ScSSHClient1.Password := TabBankaAyar.FieldByName('FTP_PASSWORD').AsString;
        end else if True then begin
           ScSSHClient1.Authentication := atPublicKey;
           ScSSHClient1.User := TabBankaAyar.FieldByName('FTP_USER').AsString;
           Tablo.query1.Close;
           Tablo.query1.SQL.Text := 'select * from BANKAFTP where BANKAKODU = '+ TabGonderen.FieldByName('BANKAKODU').AsString +'';
           Tablo.query1.Open;
           KutuktenOku(Tablo.query1,'FTP_PRIVATE_KEY','TempKey.key', True);
           ScSSHClient1.PrivateKeyName := 'TempKey.key';
        end;


        ScSSHClient1.HostName := TabBankaAyar.FieldByName('FTP_ADRES').AsString  ;
        //ScSSHClient1.HostKeyAlgorithms.Assign(TabBankaAyar.FieldByName('FTP_HOST_KEY_ALGORITHM').asstring) ;//yada ssh-dss  yada ikisi birden...
        ScSSHClient1.Port := TabBankaAyar.FieldByName('FTP_PORT').AsInteger;
        ScSSHClient1.HostKeyName := TabBankaAyar.FieldByName('FTP_HOST_KEY_NAME').AsString;
        ScFileStorage1.Password := TabBankaAyar.FieldByName('FTP_HOST_KEY_PASSWORD').AsString;

        Destination := TabBankaAyar.FieldByName('FTP_DIZIN').AsString;
        Destination := StringReplace(Destination,'/','\',[rfReplaceAll]);
        if Copy(Destination,1,1)<>'\' then
          Destination := '\'+Destination;
        if Copy(Destination,Length(Destination)-1,1)<>'/' then
          Destination := Destination+'\';
        try
          ScSSHClient1.Connect;
        Except
          raise exception.Create('Bağlantıda Hata');
        end;
        ScSFTPClient1.Initialize;
        try
          ScSFTPClient1.UploadFile(FTPDosyaYeri,Destination+FTPDosyaAdi,False);
        Except
          //raise exception.Create(SSH_HataGoster(EScSFTPError.ErrorCode));
          raise exception.Create('Bağlantıda Hata');
        end;
        ScSFTPClient1.Disconnect;
        ScSSHClient1.Disconnect;
        AdimDegistir(JvInstallLabel2,FTP_ADIM_FINISH,FTP_ADIM_DISCONNECT);} //10
      End;

    2:Begin
        raise exception.Create('Bağlantıda Hata');
      End;
  End ;
    HavaleEFTEkrani.AdimDegistir(JvInstallLabel2,-1,FTP_ADIM_FINISH); //11
end;


procedure THavaleEFTEkrani.SayfaDurumGoruntule5Page(Sender: TObject);
begin
  if TabBankaAyar.FieldByName('TALIMAT_GONDER').AsInteger > 0 then Begin
     if TabBankaAyar.FieldByName('TALIMAT_IMZALA').AsBoolean = false then Begin //doğru dosyayı bulalım..
        FTPDosya := TFileStream.Create('PDFDosya\'+PDFDosyaAdi,fmOpenRead);
        FTPDosyaYeri := 'PDFDosya\'+PDFDosyaAdi
     End else if TabBankaAyar.FieldByName('TALIMAT_IMZALA').AsBoolean = True then Begin
        FTPDosya := TFileStream.Create('PDFDosyaOK\'+PDFDosyaAdi,fmOpenRead);
        FTPDosyaYeri := 'PDFDosyaOK\'+PDFDosyaAdi
     End;
     FTPyeGonder(FTPDosya,FTPDosyaYeri,PDFDosyaAdi); //dosya ve dosyaadı ile
  End;

  if TabBankaAyar.FieldByName('TEXT_GONDER').AsInteger > 0then Begin
     if TabBankaAyar.FieldByName('TEXT_IMZALA').AsBoolean = false then Begin
        FTPDosya := TFileStream.Create('TextDosya\'+TextDosyaAdi,fmOpenRead);
        FTPDosyaYeri := 'TextDosya\'+TextDosyaAdi
     End Else if TabBankaAyar.FieldByName('TEXT_IMZALA').AsBoolean = True then Begin
        FTPDosya := TFileStream.Create('TextDosyaOK\'+TextDosyaAdi,fmOpenRead);
        FTPDosyaYeri := 'TextDosyaOK\'+TextDosyaAdi
     End;
     FTPyeGonder(FTPDosya,FTPDosyaYeri,TextDosyaAdi); //dosya ve dosyaadı ile
  End;

end;

procedure THavaleEFTEkrani.SayfaGiris1NextButtonClick
  (Sender: TObject; var Stop: Boolean);
var
  say: Integer;
begin
  // işaretli varmı kontrolü
  say := 0;
  TabAlici.First;

  while not TabAlici.eof do
  begin
    if cxGridDBTableView1SEC.EditValue = True then
      inc(say);
    HavaleEFTEkrani.TabAlici.next;
  end;
  if say = 0 then
    raise exception.Create(secimyokhata);
  cxgrid3.visible:=False;
end;

procedure THavaleEFTEkrani.SayfaImzalamaIslemleri4EnterPage(Sender: TObject;
  const FromPage: TJvWizardCustomPage);
begin
   WindowState := wsNormal;
   HavaleEFTEkrani.ClientHeight := 500;
   HavaleEFTEkrani.ClientWidth :=  900;
   DurumlariSifirla(JvInstallLabel1);
   DurumlariSifirla(JvInstallLabel2);
end;

procedure THavaleEFTEkrani.SayfaImzalamaIslemleri4Page(Sender: TObject);
begin
  if TabBankaAyar.FieldByName('TALIMAT_IMZALA').AsBoolean = False then Begin
      If TabBankaAyar.FieldByName('TEXT_IMZALA').AsBoolean = False then
         HavaleWizard.ActivePage := SayfaDurumGoruntule5;
  End;
end;

procedure THavaleEFTEkrani.SayfaIslemSecimi2Page(Sender: TObject);
begin
  LabelDosyalarHazirlaniyor.Visible := True;
  if not TabBankaAyar.active then Begin
    TabBankaAyar.close;
    TabBankaAyar.Params[0].value:=TabGonderen.fieldbyname('BANKAKODU').asinteger;
    TabBankaAyar.open;
  End;
  //text dosya  TEXT_OLUSTUR=TRUE
  LabelTextHazir.Visible := True;
  if TabBankaAyar.FieldByName('TEXT_OLUSTUR').AsBoolean=True then Begin
     TextDosyaAdi := YeniDesenDosyasiOlustur(TabGonderen.FieldByName('BANKAKODU').AsInteger);
     LabelTXTTamam.Visible := True
  End Else Begin
     LabelTXTIptal.Visible := True
  End;
    //pdf dosya  TALIMAT_OLUSTUR=TRUE
  LabelPDFHazir.Visible:=True;
  if TabBankaAyar.FieldByName('TALIMAT_OLUSTUR').AsBoolean=True then begin
      FastRaporDlg.RaporAdi := 'Talimat';
      FastRaporDlg.EkranAdi := 'HavaleEFTEkrani';
      FastRaporDlg.TabYeniAyar.Close;
      FastRaporDlg.TabYeniAyar.SQL.text :=
        'SELECT * FROM AYARLARYENI WHERE GRUBU=''HavaleEFTEkrani'' and MODUL = ''Talimat'' ';
      FastRaporDlg.TabYeniAyar.Open;
      // Baskı önizlee ekranımız zaten mevcut. Bu önizlemeyi PDF olarak kaydederiz,
      frxPDFExport1.DefaultPath := 'PDFDosya\';
      PDFDosyaAdi:= Trim(TabGonderen.FieldByName('BANKAADI').AsString)+FormatDateTime('yyyymmddhhnnss', Tablo.GENINI.BuguntrhSaat)+'.pdf';
      frxPDFExport1.FileName := PDFDosyaAdi;
      FastRaporDlg.RaporOku(frxReport1);
      //raporu almak için hazırlarız,
      //frxReport1.PrepareReport;
      frxReport1.Export(frxPDFExport1);
      // ve göstermek için tekrar hazırlarız.(aksi taktirde patlıyor..)
      frxReport1.PrepareReport;
      LabelPDFTamam.Visible:=True;
      HavaleWizard.ActivePage := SayfaTalimat3;
  end else begin;
     HavaleWizard.ActivePage := SayfaImzalamaIslemleri4;
     LabelPDFIptal.Visible:=True;
  end;

end;

procedure THavaleEFTEkrani.SayfaTalimat3Page(Sender: TObject);
begin
   WindowState := wsMaximized;
end;

(*procedure THavaleEFTEkrani.ScSFTPClient1CreateLocalFile(Sender: TObject;
  {$IFNDEF CLR}const{$ENDIF} LocalFileName, RemoteFileName: string;
  Attrs: TScSFTPFileAttributes; var Handle: {$IFDEF CLR}Stream{$ELSE}Cardinal{$ENDIF});
{$IFNDEF CLR}
var
  dwFlags: DWORD;
{$ENDIF}
begin
{$IFDEF CLR}
  Handle := System.IO.FileStream.Create(LocalFileName, System.IO.FileMode.Create,
    System.IO.FileAccess.ReadWrite, System.IO.FileShare.None);
{$ELSE}
  if aAttrs in Attrs.ValidAttributes then begin
    dwFlags := 0;
    if faReadonly in Attrs.Attrs then
      dwFlags := dwFlags or FILE_ATTRIBUTE_READONLY;
    if faSystem in Attrs.Attrs then
      dwFlags := dwFlags or FILE_ATTRIBUTE_SYSTEM;
    if faHidden in Attrs.Attrs then
      dwFlags := dwFlags or FILE_ATTRIBUTE_HIDDEN;
    if faArchive in Attrs.Attrs then
      dwFlags := dwFlags or FILE_ATTRIBUTE_ARCHIVE;
    if faCompressed in Attrs.Attrs then
      dwFlags := dwFlags or FILE_ATTRIBUTE_COMPRESSED;
  end
  else
    dwFlags := FILE_ATTRIBUTE_NORMAL;

  Handle := CreateFile(PChar(LocalFileName),
    GENERIC_READ or GENERIC_WRITE, 0, nil, CREATE_NEW, dwFlags, 0);
{$ENDIF}

end;


procedure THavaleEFTEkrani.ScSFTPClient1Disconnect(Sender: TObject); //5
begin
  JvInstallLabel2.Lines[FTP_ADIM_FILENAME] := GFTPDosyaAdi; //6
  AdimDegistir(JvInstallLabel2,FTP_ADIM_FILENAME,FTP_ADIM_CREATING_FILE); //6
end;

procedure THavaleEFTEkrani.ScSFTPClient1Success(Sender: TObject;         //4   (2 kez geliyor)
  Operation: TScSFTPOperation; const FileName: string; const Handle: TBytes;
  const Message: string);
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_SYNCING,FTP_ADIM_CONNECTED);//4
  AdimDegistir(JvInstallLabel2,FTP_ADIM_CREATING_FILE,FTP_ADIM_SYNCING); //5
end;

procedure THavaleEFTEkrani.ScSSHClient1AfterConnect(Sender: TObject); //3
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_CONNECTED,FTP_ADIM_VERIFY_KEY);
end;

procedure THavaleEFTEkrani.ScSSHClient1AfterDisconnect(Sender: TObject); //7
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_DISCONNECT,FTP_ADIM_SENT); //9
end;

procedure THavaleEFTEkrani.ScSSHClient1BeforeConnect(Sender: TObject);//1
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_AUTHENTICATING,FTP_ADIM_CONNECTING);
end;

procedure THavaleEFTEkrani.ScSSHClient1BeforeDisconnect(Sender: TObject); //6
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_SENDING,FTP_ADIM_FILENAME);//7
  AdimDegistir(JvInstallLabel2,FTP_ADIM_SENT,FTP_ADIM_SENDING);//8
end;

procedure THavaleEFTEkrani.ScSSHClient1ServerKeyValidate(Sender: TObject;//2
  NewServerKey: TScKey; var Accept: Boolean);
begin
  AdimDegistir(JvInstallLabel2,FTP_ADIM_VERIFY_KEY,FTP_ADIM_AUTHENTICATING);
  Accept:=True;
end; *)

end.



