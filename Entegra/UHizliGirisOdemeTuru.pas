unit UHizliGirisOdemeTuru;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit,
  cxLabel, JvExControls, JvButton, JvNavigationPane, ExtCtrls, UCombo, Utablo,
  UGentegreFrameYonetimi,frxClass,frxDBSet, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinLiquidSky;

type
  THizliGirisOdemeTipiDlg = class(TForm)
    Panel1: TPanel;
    LblOnay: TcxLabel;
    BtnOdemeYok: TJvNavPanelButton;
    Panel2: TPanel;
    BtnNakit: TJvNavPanelButton;
    BtnKK: TJvNavPanelButton;
    BtnIC: TJvNavPanelButton;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnOdemeYokClick(Sender: TObject);
    procedure BtnICClick(Sender: TObject);
    procedure BtnKKClick(Sender: TObject);
    procedure BtnNakitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HizliGirisOdemeTipiDlg: THizliGirisOdemeTipiDlg;

implementation

uses
PrjConst, LocOnFly;

{$R *.dfm}

procedure THizliGirisOdemeTipiDlg.BtnICClick(Sender: TObject);
begin
  ModalResult := mrClose;
end;


procedure THizliGirisOdemeTipiDlg.BtnKKClick(Sender: TObject);
begin
  ModalResult := mrNo;
end;

procedure THizliGirisOdemeTipiDlg.BtnNakitClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure THizliGirisOdemeTipiDlg.BtnOdemeYokClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure THizliGirisOdemeTipiDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  BtnNakit.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurNakit,True);  //RehberIni.ReadBool('StokHizliGiris', 'OdeTurNakit', True);
  // BtnIC.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurHC,True);  //:= RehberIni.ReadBool('StokHizliGiris', 'OdeTurHC', True);
  BtnKK.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurPOS,True);  //RehberIni.ReadBool('StokHizliGiris', 'OdeTurPOS', True);
  BtnIC.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_OdeTurIC,True);  //RehberIni.ReadBool('StokHizliGiris', 'OdeTurIC', True);
end;

procedure THizliGirisOdemeTipiDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 115 then  //F4
    BtnNakit.Click
  else if Key = 116 then//F5
    BtnKK.Click
  else if Key = 13 then//ENTER
    BtnIC.Click
  else if Key = 27 then//Esc
    BtnOdemeYok.Click
end;

end.
