unit UOpsiyonUretimDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxSkinsCore, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox,
  cxDBEdit, cxLabel, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  cxCheckBox, cxGroupBox, cxRadioGroup;

type
  TOpsiyonUretimDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cxLabel1: TcxLabel;
    CBSenaryo: TcxImageComboBox;
    CheckCariSor: TcxCheckBox;
    cxRadioGroup1: TcxRadioGroup;
    EditSekme1: TcxTextEdit;
    cxLabel2: TcxLabel;
    EditSekme2: TcxTextEdit;
    cxLabel3: TcxLabel;
    EditSekme3: TcxTextEdit;
    cxLabel4: TcxLabel;
    cxRadioGroup2: TcxRadioGroup;
    EditIsEmriSekme1: TcxTextEdit;
    cxLabel5: TcxLabel;
    EditIsEmriSekme2: TcxTextEdit;
    cxLabel6: TcxLabel;
    cxRadioGroup3: TcxRadioGroup;
    EditUretLotNoOnek: TcxTextEdit;
    cxLabel8: TcxLabel;
    cxLabel7: TcxLabel;
    RadioGroupLotKaynak: TcxRadioGroup;
    procedure KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonUretimDlg: TOpsiyonUretimDlg;

implementation

uses UTablo, prjconst, LocOnFly;

{$R *.dfm}

procedure TOpsiyonUretimDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
   CBSenaryo.EditValue := Tablo.GENINI.ReadInteger(Ops_Uretim_Senaryo, 1);
   CheckCariSor.Checked := Tablo.GENINI.ReadBoolean(Ops_CheckCariSor, False);
   EditSekme1.Text := Tablo.GENINI.ReadString(Ops_UEmriEditSekme1, '');
   EditSekme2.Text := Tablo.GENINI.ReadString(Ops_UEmriEditSekme2, '');
   EditSekme3.Text := Tablo.GENINI.ReadString(Ops_UEmriEditSekme3, '');

   EditIsEmriSekme1.Text := Tablo.GENINI.ReadString(Ops_EditIsEmriSekme1, '');
   EditIsEmriSekme2.Text := Tablo.GENINI.ReadString(Ops_EditIsEmriSekme2, '');
   EditUretLotNoOnek.Text:= Tablo.GENINI.ReadString(Ops_EditUretLotNoOnek, '');

   RadioGroupLotKaynak.ItemIndex := Tablo.GENINI.ReadInteger(Ops_RadioGroupLotKaynak, 1);
end;

procedure TOpsiyonUretimDlg.KaydetTusClick(Sender: TObject);
begin
   Tablo.GENINI.WriteInteger(Ops_Uretim_Senaryo, CBSenaryo.EditValue);
   Tablo.GENINI.WriteBoolean(Ops_CheckCariSor, CheckCariSor.Checked);
   Tablo.GENINI.WriteString(Ops_UEmriEditSekme1, EditSekme1.Text);
   Tablo.GENINI.WriteString(Ops_UEmriEditSekme2, EditSekme2.Text);
   Tablo.GENINI.WriteString(Ops_UEmriEditSekme3, EditSekme3.Text);

   Tablo.GENINI.WriteString(Ops_EditIsEmriSekme1, EditIsEmriSekme1.Text);
   Tablo.GENINI.WriteString(Ops_EditIsEmriSekme2, EditIsEmriSekme2.Text);

   Tablo.GENINI.WriteString(Ops_EditUretLotNoOnek, EditUretLotNoOnek.Text);

   Tablo.GENINI.WriteInteger(Ops_RadioGroupLotKaynak, RadioGroupLotKaynak.ItemIndex);
end;

end.
