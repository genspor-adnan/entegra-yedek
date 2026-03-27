unit USecForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer,
  cxCheckListBox, StdCtrls, Buttons, ExtCtrls, cxLabel, cxEdit, cxTextEdit,
  cxDBEdit, dxSkinscxPCPainter, Menus, ComCtrls, ToolWin, cxPC, cxGraphics,
  cxLookAndFeels, cxLookAndFeelPainters, cxPCdxBarPopupMenu, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxBarBuiltInMenu, cxCheckBox, cxCustomListBox;

type
  TSecimDlg = class(TForm)
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    CheckListSorun: TcxCheckListBox;
    CheckListTeslim: TcxCheckListBox;
    ToolBar5: TToolBar;
    SatirEkle: TToolButton;
    SatirSil: TToolButton;
    ToolButton4: TToolButton;
    PopupMenu1: TPopupMenu;
    Sorunlistesi1: TMenuItem;
    eslimalnanlistesi1: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure Sorunlistesi1Click(Sender: TObject);
    procedure eslimalnanlistesi1Click(Sender: TObject);
    procedure SatirEkleClick(Sender: TObject);
    procedure SatirSilClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure Doldur(s:string; CheckList: TcxCheckListBox);
  public
    { Public declarations }
    Ekran : string;
  end;

var
  SecimDlg: TSecimDlg;

implementation

uses Utablo, UCombo,PrjConst,LocOnFly;
{$R *.dfm}

procedure TSecimDlg.Doldur(s:string; CheckList: TcxCheckListBox);
var st : TStringList;
    Ch : TcxCheckListBoxItem;
    I  : SmallInt;
begin
   st:=TStringList.Create;
   RehberIni.ReadSection(s,st);
   for I := 0 to st.Count - 1 do begin
      Ch := CheckList.Items.add;
      Ch.Text := st.Strings[I];
   end;
   st.Free;
end;

procedure TSecimDlg.eslimalnanlistesi1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Servis_TeslimAl);
   CheckListTeslim.Clear;
   Doldur('Servis_TeslimAl', CheckListTeslim);   //           Ops_Servis_TeslimAl
end;

procedure TSecimDlg.FormCreate(Sender: TObject);
begin
LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TSecimDlg.FormShow(Sender: TObject);
begin
   cxPageControl1.ActivePageIndex := 0;
   Doldur('Servis_Sorunlar', CheckListSorun);    //     Ops_Servis_Sorunlar
   Doldur('Servis_TeslimAl', CheckListTeslim);     //    Ops_Servis_TeslimAl
end;

procedure TSecimDlg.SatirEkleClick(Sender: TObject);
begin
   ModalResult := mrOk;
end;

procedure TSecimDlg.SatirSilClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TSecimDlg.Sorunlistesi1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_Servis_Sorunlar);
   CheckListSorun.Clear;
   Doldur('Servis_Sorunlar', CheckListSorun);    // Ops_Servis_Sorunlar
end;

end.
