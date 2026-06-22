unit UOpsiyonITS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxLookAndFeelPainters, dxSkinsCore,  cxListBox, cxControls, cxContainer,
  cxEdit, cxGroupBox, dxSkinLondonLiquidSky, cxCheckBox, cxTextEdit, cxMaskEdit,PrjConst,UGENINIDuzenle,
  cxSpinEdit, cxLabel, ComCtrls, ToolWin, cxStyles, dxSkinscxPCPainter, cxCustomData, cxGraphics,
  cxFilter, cxData, cxDataStorage, DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses,cxGridCustomView, cxGrid, cxButtonEdit, StdCtrls,UKodAgaci, Buttons, ExtCtrls, cxDropDownEdit, cxImageComboBox;

type
  TOpsiyonITSDlg = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    Panel1: TPanel;
    btnKapat: TBitBtn;
    btnKaydet: TBitBtn;
    cxGroupBox1: TcxGroupBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    ComboImalatci: TcxImageComboBox;
    ComboDepocu: TcxImageComboBox;
    ComboEtiket: TcxImageComboBox;
    procedure btnKaydetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonITSDlg: TOpsiyonITSDlg;

implementation

uses UCombo, Utablo,LocOnFly;

{$R *.dfm}

procedure TOpsiyonITSDlg.btnKaydetClick(Sender: TObject);
begin
  Tablo.GENINI.WriteInteger(Ops_ITSOpsiyon_Imalatci,ComboImalatci.EditValue);
  Tablo.GENINI.WriteInteger(Ops_ITSOpsiyon_Depocu,ComboDepocu.EditValue);
  Tablo.GENINI.WriteInteger(Ops_ITSOpsiyon_Etiket,ComboEtiket.EditValue);
end;

procedure TOpsiyonITSDlg.FormCreate(Sender: TObject);
begin
   LocalizerOnFly.ProcessContainer(Self);

  ComboImalatci.EditValue := Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Imalatci,31);
  ComboDepocu.EditValue := Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Depocu,32);
  ComboEtiket.EditValue := Tablo.GENINI.ReadInteger(Ops_ITSOpsiyon_Etiket,30);

end;

end.

