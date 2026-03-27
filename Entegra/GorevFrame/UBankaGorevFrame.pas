unit UBankaGorevFrame;
 
{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 25/01/2010 11:04:25}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,
  cxLookAndFeelPainters, cxButtons, JvExControls, JvButton, JvNavigationPane,
  CategoryButtons, ExtCtrls, ImgList, PngImageList;

type
  TBankaGorevFrame = class(TFrame)
    btnBankaTanimlari: TJvNavPanelButton;
    btnBankaKredileri: TJvNavPanelButton;
    BtnKrediler: TJvNavPanelButton;
    PanelCek: TPanel;
    btnVerilenCek: TJvNavPanelButton;
    btnAlinanCek: TJvNavPanelButton;
    PanelSenet: TPanel;
    btnVerilenSenet: TJvNavPanelButton;
    btnAlinanSenet: TJvNavPanelButton;
    Panel3: TPanel;
    JvNavPanelButton2: TJvNavPanelButton;
    btnDokumler: TJvNavPanelButton;
    procedure btnBankaTanimlariClick(Sender: TObject);
    procedure btnBankaKredileriClick(Sender: TObject);
    procedure BtnKredilerClick(Sender: TObject);
    procedure btnAlinanCekClick(Sender: TObject);
    procedure btnDokumlerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnUpAndDown(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi: TAnaFrameBilgi;
    procedure SetFrameBilgi(const Value: TAnaFrameBilgi);
  public
    { Public declarations }
  published
    property FrameBilgi : TAnaFrameBilgi read FFrameBilgi write SetFrameBilgi;
  end;

implementation

uses UBankaKredileriListeFrame, UTeminatMektuplariListeFrame,UPOSListeFrame, UKrediKartiListeFrame,
  UVadeliHesaplarListeFrame,  UDokumGirisFrame,UGenelGirisSayfasiFrame,UTablo, // UBankaCekleriListeFrame,
  UDBSListeFrame, UBankalarListeFrame, UKrediHesapMakineDlg, UCekListeFrame,
  UCekAramaFrame,LocOnFly;

{$R *.dfm}

{ TBankaGorevFrame }

procedure TBankaGorevFrame.btnBankaKredileriClick(Sender: TObject);
begin
  with TBankalarListeFrame(FFrameBilgi.IcerikGit('Banka Kredileri Tanýmlama').Ornek) do begin
  end;
  btnUpAndDown(Sender);
end;

procedure TBankaGorevFrame.btnBankaTanimlariClick(Sender: TObject);
begin
  with FFrameBilgi.IcerikGit(TBankalarListeFrame).Ornek as TBankalarListeFrame do begin
  end;
  btnUpAndDown(Sender);
end;



procedure TBankaGorevFrame.btnDokumlerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=0
   else
      TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Durum:=9;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).Standart := TJVNavPanelButton(Sender).Tag;
  TDokumGirisFrame(FFrameBilgi.IcerikGit(TDokumGirisFrame).Ornek).DokumEkranAdi := 'B';
  btnUpAndDown(Sender);
end;

procedure TBankaGorevFrame.btnUpAndDown(Sender: TObject);
begin
  btnBankaTanimlari.Down := False;
  //BtnTalimatlar.Down := False;
  BtnKrediler.Down := False;
  btnAlinanCek.Down := False;
  btnVerilenCek.Down := False;
  btnAlinanSenet.Down := False;
  btnVerilenSenet.Down := False;
  btnBankaKredileri.Down := False;
  btnDokumler.Down := False;
  JvNavPanelButton2.Down := False;
  if Sender.ClassName = 'TJvNavPanelButton' then
    (Sender as TJvNavPanelButton).Down := True;
end;

procedure TBankaGorevFrame.BtnKredilerClick(Sender: TObject);
begin
  {Burasý Talimat Çaðýrma bölümü idi

  with FFrameBilgi.IcerikGit(TTalimatlarListeFrame).Ornek as TTalimatlarListeFrame do begin
  end;
  btnUpAndDown(Sender);}
  with FFrameBilgi.IcerikGit(TBankaKredileriListeFrame).Ornek as TBankaKredileriListeFrame do begin
   end;
  btnUpAndDown(Sender);
end;

procedure TBankaGorevFrame.btnAlinanCekClick(Sender: TObject);
begin
  with FFrameBilgi.IcerikGit(TCekListeFrame).Ornek as TCekListeFrame do begin
    CekSenetTur := TComponent(Sender).Tag;
    if TComponent(Sender).Tag in [Sbt_Cek_Gelen, Sbt_Senet_Gelen] then
       CekTur := 130
    else
       CekTur := 140;
    //SQLEk := ' and C.TUR='+inttoStr(TComponent(Sender).Tag)+' ';
    if POS('Cek', TComponent(Sender).Name)>0 then
       CekTurAd:='Çek'
    else
       CekTurAd:='Senet';

    Arama.SheetAlinanCekler.Caption := 'Alýnan '+CekTurAd+'ler';
    Arama.SheetVerilenCekler.Caption := 'Verilen '+CekTurAd+'ler';
    SheetHesapListe.Caption := CekTurAd+' Hesaplarý';

    case CekTur of
     130 : begin  //alýnan çek / senet
       GridTviewDURUM.RepositoryItem := Tablo.RepCekDurum_Alinan;
       TabloNo := TabNo_CEKLER_Alinan;
       Arama.SheetAlinanCekler.Visible := True;
       Arama.SheetAlinanCekler.TabVisible := False;
       if Arama.PCCekTurleri.ActivePage <> Arama.SheetAlinanCekler then
          Arama.PCCekTurleri.ActivePage := Arama.SheetAlinanCekler;
       Arama.SheetVerilenCekler.Visible := False;
       Arama.SheetVerilenCekler.TabVisible := False;
    end;
    140 : begin //verilen çek / senet
      GridTviewDURUM.RepositoryItem := Tablo.RepCekDurum_Verilen;
      TabloNo := TabNo_CEKLER_Verilen;
      Arama.SheetVerilenCekler.Visible := True;
      Arama.SheetVerilenCekler.TabVisible := False;
      if Arama.PCCekTurleri.ActivePage <> Arama.SheetVerilenCekler then
         Arama.PCCekTurleri.ActivePage := Arama.SheetVerilenCekler;
      Arama.SheetAlinanCekler.Visible := False;
      Arama.SheetAlinanCekler.TabVisible := False;
    end;
    end;
    //YenileTusClick(Sender);
    PageControlCekChange(Self);
  end;
  btnUpAndDown(Sender);
end;

procedure TBankaGorevFrame.SetFrameBilgi(const Value: TAnaFrameBilgi);
begin
  FFrameBilgi := Value;
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //BtnTalimatlar.Visible := Tablo.YetkiVarmi(2511,YetkiTur_Gorme);
  BtnKrediler.Visible := Tablo.YetkiVarmi(253120,YetkiTur_Gorme);
  PanelCek.Visible := Tablo.YetkiVarmi(2551,YetkiTur_Gorme);
  PanelSenet.Visible := PanelCek.Visible;
  btnDokumler.Visible := Tablo.YetkiVarmi(2599,YetkiTur_Gorme);
end;

initialization
  RegisterClass(TBankaGorevFrame);
end.
