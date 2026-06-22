unit UHizliGirisBaski;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvButton, JvNavigationPane, ExtCtrls, UHizliGiris,
  Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, dxSkinsCore, Utablo,
  dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxLabel, PrjConst,
  cxGraphics, cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  THizliGirisBaskiDlg = class(TForm)
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    LblOnay: TcxLabel;
    Panel5: TPanel;
    BtnBelgesiz: TJvNavPanelButton;
    PanelFis: TPanel;
    BtnFisDok: TJvNavPanelButton;
    BtnFisBaski: TJvNavPanelButton;
    PanelFatura: TPanel;
    BtnFaturaDok: TJvNavPanelButton;
    BtnFaturaBaski: TJvNavPanelButton;
    PanelIrsaliye: TPanel;
    BtnIrsaliyeDok: TJvNavPanelButton;
    BtnIrsaliyeBaski: TJvNavPanelButton;
    procedure BtnFisDokClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    R, BaskiAl : Boolean;
    Say, BelgeTuru : Smallint;

    { Public declarations }
  end;

var
  HizliGirisBaskiDlg: THizliGirisBaskiDlg;

implementation
  Uses LocOnFly;

{$R *.dfm}

procedure THizliGirisBaskiDlg.BtnFisDokClick(Sender: TObject);
begin
  BelgeTuru := TJvNavPanelButton(Sender).Tag;
  BaskiAl := TJvNavPanelButton(Sender).GroupIndex=2;
  R := TJvNavPanelButton(Sender).Name='BtnBelgesiz';
  ModalResult := mrOk;
end;

procedure THizliGirisBaskiDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  BaskiAl := False;
  Say := 0;
  BtnFisDok.Visible := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FisGiris,True);
  BtnFisBaski.Visible := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FisBaski,False);

  if (BtnFisDok.Visible) then inc(Say);
  if (BtnFisBaski.Visible) then inc(Say);

  BtnFaturaDok.Visible := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FaturaGiris,True);
  BtnFaturaBaski.Visible := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_FaturaBaski,False);
  if (BtnFaturaDok.Visible) then inc(Say);
  if (BtnFaturaBaski.Visible) then inc(Say);

  BtnIrsaliyeDok.Visible := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_Irsaliye,True);
  BtnIrsaliyeBaski.Visible := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_IrsaliyeBaski,False);
  if (BtnIrsaliyeDok.Visible) then inc(Say);
  if (BtnIrsaliyeBaski.Visible) then inc(Say);

  BtnBelgesiz.Visible := Tablo.GENINI.ReadBoolean(Ops_HizliGiris_BelgesizGiris,True);
  if BtnBelgesiz.Visible then inc(Say);

  if (BtnIrsaliyeDok.Visible=False) And (BtnIrsaliyeBaski.Visible=False) then
    PanelIrsaliye.visible := False;
  if (BtnFisDok.Visible=False) And (BtnFisBaski.Visible=False) then
    PanelFis.visible := False;
  if (BtnFaturaDok.Visible=False) And (BtnFaturaBaski.Visible=False) then
    PanelFatura.visible := False;
  if (BtnFisDok.Visible=True) And (BtnFisBaski.Visible=False) then
    BtnFisDok.Align := alClient;
  if (BtnFaturaDok.Visible=True) And (BtnFaturaBaski.Visible=False) then
    BtnFaturaDok.Align := alClient;
end;

procedure THizliGirisBaskiDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 115 then  //F4
    BtnFaturaDok.Click
  else if Key = 116 then  //F5
    BtnBelgesiz.Click
  else if Key = 116 then  //F10
    BtnFisBaski.Click
  else if Key = 116 then  //F11
    BtnFaturaBaski.Click
  else if Key = 13 then//ENTER
    BtnFisDok.Click
  else if Key = 27 then//Esc
    BtnBelgesiz.Click
end;

procedure THizliGirisBaskiDlg.KapatTusClick(Sender: TObject);
begin
  BaskiAl := False;
  ModalResult:=mrCancel;
end;

end.
