unit UMutabakat;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.StdCtrls, cxCheckBox,
  cxDBEdit, cxCurrencyEdit, Vcl.ExtCtrls, cxDropDownEdit, cxCalendar,
  cxTextEdit, cxMaskEdit, cxImageComboBox, cxLabel, JvExExtCtrls,
  JvExtComponent, JvPanel, Data.DB, FireDAC.Comp.Client;

type
  TMutabakatDlg = class(TForm)
    UstPanel: TJvPanel;
    LblSube: TcxLabel;
    ComboSube: TcxDBImageComboBox;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    BaslikLabel: TcxLabel;
    LabelTarih: TcxLabel;
    EditTarih: TcxDBDateEdit;
    EditKayitTarih: TcxDBDateEdit;
    Panel1: TPanel;
    Label15: TcxLabel;
    LabelTutar: TcxLabel;
    EditTutar: TcxDBCurrencyEdit;
    ComboKur: TcxDBComboBox;
    LabelKarsilik: TcxLabel;
    EditAciklama: TcxDBTextEdit;
    PanelKarsilik: TPanel;
    EditDovTutar: TcxDBCurrencyEdit;
    ComboDovKur: TcxDBComboBox;
    EditKulKur: TcxCurrencyEdit;
    cxDBCheckBox1: TcxDBCheckBox;
    lblMasrafKod: TcxLabel;
    lblBankaMasrafKod: TcxLabel;
    SqlMemoMasrafKalemi: TMemo;
    AltPanel: TPanel;
    tamamButton: TButton;
    iptalButton: TButton;
    TabKasa: TFDQuery;
    DtsKasa: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MutabakatDlg: TMutabakatDlg;

implementation

{$R *.dfm}

end.

