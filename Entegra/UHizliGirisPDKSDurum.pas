unit UHizliGirisPDKSDurum;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, ExtCtrls,UTablo, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxLabel,
  cxGraphics, cxLookAndFeels, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  THizliGirisPDKSDurumDlg = class(TForm)
    Panel2: TPanel;
    BtnKapat: TcxButton;
    OrtaPanel: TPanel;
    lbKasaAcKapaBilgi: TcxLabel;
    procedure BtnKapatClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure ButtonlarClick(Sender: TObject);
    { Private declarations }
  public
    { Public declarations }
    ButtonTag :integer;
  end;

var
  HizliGirisPDKSDurumDlg: THizliGirisPDKSDurumDlg;


implementation
Uses
PrjConst;

{$R *.dfm}

procedure THizliGirisPDKSDurumDlg.BtnKapatClick(Sender: TObject);
begin
  ModalResult := mrClose;
end;
procedure THizliGirisPDKSDurumDlg.ButtonlarClick(Sender: TObject);
begin
  ButtonTag:=TButton(Sender).Tag;
end;

procedure THizliGirisPDKSDurumDlg.FormShow(Sender: TObject);
var
c : TcxButton;
FormYukseklik : integer;
begin
   FormYukseklik := 0;
   Tablo.TablodanSorguAc(1,'Select * from GENINI Where BOLUM='+IntToStr(Ops_CariKart_PDKSDurum)+' Order by DEGER Desc ');
   while not Tablo.Query1.Eof do begin
      c := TcxButton.Create(Self);
      c.Parent      := TPanel(OrtaPanel);
      c.Name        := 'btn'+StringReplace(Tablo.Query1.FieldByName('ANAHTAR').AsString,' ','_',[rfReplaceAll]);
      c.Tag         := Tablo.Query1.FieldByName('DEGER').AsInteger;
      c.Caption     := Tablo.Query1.FieldByName('ANAHTAR').AsString;
      c.Align       := alTop;
      c.Height      := 70;
      c.ModalResult := mrClose;
      FormYukseklik := FormYukseklik + 70;
      c.OnClick     := ButtonlarClick;
      c.Show;
      Tablo.Query1.Next;
   end;
   HizliGirisPDKSDurumDlg.Height := FormYukseklik + 42;
end;

end.
