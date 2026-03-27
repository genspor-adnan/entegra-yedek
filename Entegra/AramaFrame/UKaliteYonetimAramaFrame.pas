unit UKaliteYonetimAramaFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 07/12/2010 10:47:20 }
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus, UFrameYoneticisi,
  dxSkinsCore, cxCheckBox, cxMaskEdit, cxDropDownEdit, cxCalendar,
  ExtCtrls, cxControls, cxContainer, cxEdit, cxTextEdit, cxGraphics, cxLabel,
  cxImageComboBox, cxDBEdit, cxButtonEdit, Buttons, dxSkinLondonLiquidSky, DB,UKodAgaci,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, DateUtils, CategoryButtons;

type
    TKaliteYonetimAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    PanelKaliteYonetim: TPanel;
    KaliteYonetimMenu: TCategoryButtons;
    PanelKaliteKontrol: TPanel;
    KaliteKontrolMenu: TCategoryButtons;
    procedure TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
    procedure KaliteYonetimMenuCategories0Items0Click(Sender: TObject);
    procedure KaliteYonetimMenuCategories0Items1Click(Sender: TObject);
    procedure KaliteYonetimMenuCategories0Items2Click(Sender: TObject);
    procedure KaliteYonetimMenuCategories0Items3Click(Sender: TObject);
    procedure KaliteYonetimMenuCategories0Items4Click(Sender: TObject);
    procedure KaliteKontrolMenuCategories0Items0Click(Sender: TObject);
    procedure KaliteKontrolMenuCategories0Items1Click(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);
  public
    { Public declarations }
    KADlg:TKodAgaciDLG;
    VarsHint:String;
  end;

implementation

{$R *.dfm}
uses FetaKurulusSiniflari, FetaClassExtensions, UDokum, UDokumGirisFrame, UAnaform, Utablo,LocOnFly,PrjConst,
JclSysInfo,UGirisKutusuEx,UKaliteToplanti,UKYToplantiListeDlg,UKYDuzelticiVeOnleyiciFaalListeDlg,UKYEgitimListeDlg,
 UKYDenetimListeDlg, UKYSapmaOlayListeDlg, UKYKontrolListeDlg;
//,UKYDokumanListeDlg,UKYEgitimListeDlg,UKYEkipmanListeDlg,UKYIcDenetimListeDlg,UKYSurecTakipListeDlg,UKYToplantiListeDlg;
{ TKaliteYonetimAramaFrame }

procedure TKaliteYonetimAramaFrame.Baslatildi;
var
   i:Integer;
  st:string;
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
    Tablo.FBtnIndex := -1;

    TumTusResimleriniDegistir(KaliteYonetimMenu,9);
    st:='';
    KaliteYonetimMenu.Categories[0].Collapsed:=False;
    KaliteYonetimMenu.Visible := True;
    PanelKaliteYonetim.Visible:=True;
    PanelKaliteYonetim.height :=160;

    if KaliteYonetimMenu.Categories[0].items[0].ImageIndex = 9 then
      st := st + '8,';
    if KaliteYonetimMenu.Categories[0].items[1].ImageIndex = 9 then
      st := st + '9,';
    if KaliteYonetimMenu.Categories[0].items[2].ImageIndex = 9 then
      st := st + '10,';
    if KaliteYonetimMenu.Categories[0].items[3].ImageIndex = 9 then
      st := st + '11,';
    if KaliteYonetimMenu.Categories[0].items[4].ImageIndex = 9 then
      st := st + '12,';
//        if KaliteYonetimMenu.Categories[0].items[4].ImageIndex = 9 then
//          st := st + '13,';
//        if KaliteYonetimMenu.Categories[0].items[5].ImageIndex = 9 then
//          st := st + '8,';

    if KaliteKontrolKullanimda then begin
        TumTusResimleriniDegistir(KaliteKontrolMenu, 9);
        st:='';
        KaliteKontrolMenu.Categories[0].Collapsed:=False;
        KaliteKontrolMenu.Visible := True;
        PanelKaliteKontrol.Visible:=True;
        PanelKaliteKontrol.height :=90;

        if KaliteKontrolMenu.Categories[0].items[0].ImageIndex = 9 then
          st := st + '21,';
        if KaliteKontrolMenu.Categories[0].items[1].ImageIndex = 9 then
          st := st + '22,';
    end
    else
        KaliteKontrolMenu.visible := False;
end;

procedure TKaliteYonetimAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TKaliteYonetimAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TKaliteYonetimAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TKaliteYonetimAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TKaliteYonetimAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TKaliteYonetimAramaFrame.Gorunmez;
begin

end;

procedure TKaliteYonetimAramaFrame.GorunmezOlacak;
begin

end;

procedure TKaliteYonetimAramaFrame.Gorunur;
begin

end;

procedure TKaliteYonetimAramaFrame.GorunurOlacak;
begin

end;

procedure TKaliteYonetimAramaFrame.TumTusResimleriniDegistir(Menu: TCategoryButtons; ImajIndex: Integer);
var i:Integer;
begin
  for I := 0 to Menu.Categories[0].Items.Count - 1 do
    Menu.Categories[0].items[i].ImageIndex:=ImajIndex;
end;

procedure TKaliteYonetimAramaFrame.KaliteYonetimMenuCategories0Items0Click(Sender: TObject);
begin
  with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKYSapmaOlayListeDlg).Ornek as TKYSapmaOlayListeDlg do begin
  end;
end;

procedure TKaliteYonetimAramaFrame.KaliteYonetimMenuCategories0Items1Click(
  Sender: TObject);
begin
   with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKYDuzelticiVeOnleyiciFaalListeDlg).Ornek as TKYDuzelticiVeOnleyiciFaalListeDlg do begin
   end;
end;

procedure TKaliteYonetimAramaFrame.KaliteYonetimMenuCategories0Items2Click(
  Sender: TObject);
begin
 with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKYDenetimListeDlg).Ornek as TKYDenetimListeDlg do begin
  end;
end;

procedure TKaliteYonetimAramaFrame.KaliteYonetimMenuCategories0Items3Click(Sender: TObject);
begin
  with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKYEgitimListeDlg).Ornek as TKYEgitimListeDlg do begin
  end;
end;

procedure TKaliteYonetimAramaFrame.KaliteYonetimMenuCategories0Items4Click(
  Sender: TObject);
begin
  with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKYToplantiListeDlg).Ornek as TKYToplantiListeDlg do begin
   //TabToplanti.Close;
   //TabToplanti.Open;
   TabloYenile(TabToplanti,[]);
  end;
end;

procedure TKaliteYonetimAramaFrame.KaliteKontrolMenuCategories0Items0Click(Sender: TObject);
begin
  with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKYKontrolListeDlg).Ornek as TKYKontrolListeDlg do begin
    LabelSecim.caption:='StokGiris';
    Secili_TabNo:= TabNo_STOKKALITE;
    InitIslemler;
  end;
end;

procedure TKaliteYonetimAramaFrame.KaliteKontrolMenuCategories0Items1Click(
  Sender: TObject);
begin
   with FFrameBilgi.AnaFrameBilgi.IcerikGit(TKYKontrolListeDlg).Ornek as TKYKontrolListeDlg do begin
      LabelSecim.caption:='Uretim';
      Secili_TabNo:= TabNo_URETIMKALITE;
      InitIslemler;
   end;
end;

procedure TKaliteYonetimAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TKaliteYonetimAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TKaliteYonetimAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKaliteYonetimAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TKaliteYonetimAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TKaliteYonetimAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TKaliteYonetimAramaFrame);
end.


