unit UFaturaGorevFrame;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  ImgList, PngImageList, ExtCtrls, UMaliyetlerListeFrame,
  cxGraphics, cxLookAndFeels, dxSkinsCore, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, System.ImageList;

type
  TFaturaGorevFrame = class(TFrame)
    PNGImageList1: TPngImageList;
    BtnMaliyetler: TJvNavPanelButton;
    Panel3: TPanel;
    btnOzelDokumler: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    PanelAlisBelgeleri: TPanel;
    btnAlisFaturalari: TJvNavPanelButton;
    btnSatinalmaTalepleri: TcxButton;
    btnVerilenSiparisler: TcxButton;
    btnIrsaliyeler: TcxButton;
    btnFaturalar: TcxButton;
    btnFisler: TcxButton;
    btnTahakkuklar: TcxButton;
    btnGiderPusulalari: TcxButton;
    btnKonsinyeler: TcxButton;
    PanelSatisBelgeleri: TPanel;
    btnSatisFaturalari: TJvNavPanelButton;
    btAlinanSiparisler: TcxButton;
    btIrsaliyeler: TcxButton;
    btFaturalar: TcxButton;
    btFisler: TcxButton;
    btTahakkuklar: TcxButton;
    btAdisyonlar: TcxButton;
    btKonsinyeler: TcxButton;
    btnGirisFisi: TcxButton;
    btCikisFisi: TcxButton;
    procedure btnAlisFaturalariClick(Sender: TObject);
    procedure BtnMaliyetlerClick(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnVerilenSiparislerClick(Sender: TObject);
    procedure btnUpAndDown(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
    procedure TumKucukResimleriDuzenle;
  public
    FMenuTur : SmallInt; //Tur: Giren:0,Çıkan:1  AltTur: sipariş:0,irsaliye:1,Fat:2,fiş:3,Tahakkuk:4,Tümü:-1
    FAltTur : SmallInt;
    { Public declarations }
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
    property MenuTur : Smallint read FMenuTur;
    property AltTur : Smallint read FAltTur;
  end;

implementation

uses JvJVCLUtils, UFaturalar, FetaKurulusSiniflari, UGenelGirisSayfasiFrame,
  UDokumGirisFrame,Utablo, UFaturaTransferListe,JclSysInfo,LocOnFly,PrjConst;



{$R *.dfm}

{ TFaturaGorevFrame }

procedure TFaturaGorevFrame.btnAlisFaturalariClick(Sender: TObject);
begin
//kapalı boy 54
//açık boy 222
//her bir buton 24
  //başlangıçta panel boyutları 54 olmalıdır!!

  TumKucukResimleriDuzenle;
  if (sender as TJvNavPanelButton).tag = 2 then begin
    if PanelAlisBelgeleri.height = 54 then begin
      PanelAlisBelgeleri.height := 54+(24*PanelAlisBelgeleri.Tag);
      PanelSatisBelgeleri.height := 54;
    end else begin
      PanelAlisBelgeleri.height := 54;
    end;
    with FFrameBilgi.IcerikGit(TGenelGirisSayfasiFrame) do begin
      //InitIslemler;
    end;
  end else if (sender as TJvNavPanelButton).tag = 3 then begin
    if PanelSatisBelgeleri.height = 54 then begin
      PanelAlisBelgeleri.height := 54;
      PanelSatisBelgeleri.height := 54+(24*PanelSatisBelgeleri.Tag);
    end else begin
      PanelSatisBelgeleri.height := 54;
    end;
    with FFrameBilgi.IcerikGit(TGenelGirisSayfasiFrame) do begin
      //InitIslemler;
    end;
  end else begin
    PanelAlisBelgeleri.height := 54;
    PanelSatisBelgeleri.height := 54;
  end;
  if Sender.ClassName='TJvNavPanelButton' then begin
    Tablo.FBtnIndex := -1;
    FAltTur := -1;
  end;
  btnUpAndDown(Sender);
end;

procedure TFaturaGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnAlisFaturalari.Down := False;
  btnSatisFaturalari.Down := False;
  BtnMaliyetler.Down := False;
  btnDokumler.Down := False;
  btnOzelDokumler.Down := False;
  if Sender.ClassName = 'TJvNavPanelButton' then
    (Sender as TJvNavPanelButton).Down := True;
end;

procedure TFaturaGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'F';
  btnUpAndDown(Sender);
end;

procedure TFaturaGorevFrame.BtnMaliyetlerClick(Sender: TObject);
begin
  btnAlisFaturalariClick(Sender);
  with FFrameBilgi.IcerikGit(TMaliyetlerListeFrame) do begin
    //AramaYap(Sender);
  end;

  btnUpAndDown(Sender);
end;


procedure TFaturaGorevFrame.TumKucukResimleriDuzenle;
begin
  btnSatinalmaTalepleri.OptionsImage.ImageIndex := 3;
  btnVerilenSiparisler.OptionsImage.ImageIndex := 3;
  btnIrsaliyeler.OptionsImage.ImageIndex := 3;
  btnFaturalar.OptionsImage.ImageIndex := 3;
  btnFisler.OptionsImage.ImageIndex := 3;
  btnTahakkuklar.OptionsImage.ImageIndex := 3;
  btnGiderPusulalari.OptionsImage.ImageIndex := 3;
  btnKonsinyeler.OptionsImage.ImageIndex := 3;
  btnGirisFisi.OptionsImage.ImageIndex := 3;
  btAlinanSiparisler.OptionsImage.ImageIndex := 3;
  btIrsaliyeler.OptionsImage.ImageIndex := 3;
  btFaturalar.OptionsImage.ImageIndex := 3;
  btFisler.OptionsImage.ImageIndex := 3;
  btTahakkuklar.OptionsImage.ImageIndex := 3;
  btAdisyonlar.OptionsImage.ImageIndex := 3;
  btKonsinyeler.OptionsImage.ImageIndex := 3;
  btCikisFisi.OptionsImage.ImageIndex := 3;
end;

procedure TFaturaGorevFrame.btnVerilenSiparislerClick(Sender: TObject);
begin
  TumKucukResimleriDuzenle;
  (sender as TcxButton).OptionsImage.ImageIndex := 2;
    with FFrameBilgi.IcerikGit(TFaturalarDlg) do begin
      if TFaturalarDlg(Ornek).Basladi then begin
        with TFaturalarDlg(Ornek) do begin
          FAltTur := TComponent(Sender).Tag;
          if FAltTur in [3,8,9,10,11,12,13,101,109] then
            FMenuTur := 0
          else
            FMenuTur := 1;
          SQLEk := ' and F.TUR ='+IntToStr((sender as TcxButton).Tag); //arama buna göre yapılacak..
          InitIslemler;
        end;
      end;
    end;
end;

procedure TFaturaGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
var
  VisibleCount:integer;
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  PanelAlisBelgeleri.Visible := Tablo.YetkiVarmi(2401,YetkiTur_Gorme);
  PanelSatisBelgeleri.Visible := Tablo.YetkiVarmi(2411,YetkiTur_Gorme);
  Panel3.Visible := Tablo.YetkiVarmi(2499,YetkiTur_Gorme);

  //alış belgeleri
  VisibleCount := 0;
  btnSatinalmaTalepleri.visible := Tablo.YetkiVarmi(240111,YetkiTur_Gorme);
  if btnSatinalmaTalepleri.visible then
     VisibleCount:=VisibleCount+1;
  btnVerilenSiparisler.visible := Tablo.YetkiVarmi(240111,YetkiTur_Gorme);
  if btnVerilenSiparisler.visible then
     VisibleCount:=VisibleCount+1;
  btnIrsaliyeler.visible := Tablo.YetkiVarmi(240121,YetkiTur_Gorme);
  if btnIrsaliyeler.visible then
     VisibleCount:=VisibleCount+1;
  btnFaturalar.visible := Tablo.YetkiVarmi(240131,YetkiTur_Gorme);
  if btnFaturalar.visible then
     VisibleCount:=VisibleCount+1;
  btnFisler.visible := Tablo.YetkiVarmi(240141,YetkiTur_Gorme);
  if btnFisler.visible then
     VisibleCount:=VisibleCount+1;
  btnTahakkuklar.visible := Tablo.YetkiVarmi(240151,YetkiTur_Gorme);
  if btnTahakkuklar.visible then
     VisibleCount:=VisibleCount+1;
  btnGiderPusulalari.visible := Tablo.YetkiVarmi(240161,YetkiTur_Gorme);
  if btnGiderPusulalari.visible then
     VisibleCount:=VisibleCount+1;
  btnKonsinyeler.visible := Tablo.YetkiVarmi(240171,YetkiTur_Gorme); //eklenecek
  if btnKonsinyeler.visible then
     VisibleCount:=VisibleCount+1;
  btnGirisFisi.visible := False;//Tablo.YetkiVarmi(2712,YetkiTur_Gorme); //giriş fişi
  if btnGirisFisi.visible then
     VisibleCount:=VisibleCount+1;
  PanelAlisBelgeleri.Tag := VisibleCount;
  VisibleCount := 0;
  //satış belgeleri
  btAlinanSiparisler.visible := Tablo.YetkiVarmi(241111,YetkiTur_Gorme);
  if btAlinanSiparisler.visible then
     VisibleCount:=VisibleCount+1;
  btIrsaliyeler.visible := Tablo.YetkiVarmi(241121,YetkiTur_Gorme);
  if btIrsaliyeler.visible then
     VisibleCount:=VisibleCount+1;
  btFaturalar.visible := Tablo.YetkiVarmi(241131,YetkiTur_Gorme);
  if btFaturalar.visible then
     VisibleCount:=VisibleCount+1;
  btFisler.visible := Tablo.YetkiVarmi(241141,YetkiTur_Gorme);
  if btFisler.visible then
     VisibleCount:=VisibleCount+1;
  btTahakkuklar.visible := Tablo.YetkiVarmi(241151,YetkiTur_Gorme);
  if btTahakkuklar.visible then
     VisibleCount:=VisibleCount+1;
  btAdisyonlar.visible := False;//Tablo.YetkiVarmi(241171,YetkiTur_Gorme); //eklenecek
  if btAdisyonlar.visible then
     VisibleCount:=VisibleCount+1;
  btKonsinyeler.visible := Tablo.YetkiVarmi(241161,YetkiTur_Gorme);
  if btKonsinyeler.visible then
     VisibleCount:=VisibleCount+1;
  btCikisFisi.visible := False;//Tablo.YetkiVarmi(2713,YetkiTur_Gorme);
  if btCikisFisi.visible then
     VisibleCount:=VisibleCount+1;
  PanelSatisBelgeleri.Tag := VisibleCount;
  VisibleCount := 0;

  BtnMaliyetler.Visible := Tablo.YetkiVarmi(242112,YetkiTur_Gorme);
  FAltTur := -1;
end;

initialization
  RegisterClass(TFaturaGorevFrame);
end.
