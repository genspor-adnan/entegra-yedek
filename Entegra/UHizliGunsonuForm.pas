unit UHizliGunsonuForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxTextEdit, cxDBEdit, cxDBLabel, JvExControls, JvButton, JvNavigationPane,
  cxLabel, Data.DB, FireDAC.Comp.Client;

type
  THizliGunsonuForm = class(TForm)
    Label5: TcxLabel;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxDBLabel4: TcxDBLabel;
    cxLabel3: TcxLabel;
    cxDBLabel5: TcxDBLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    cxDBLabel6: TcxDBLabel;
    cxLabel4: TcxLabel;
    cxDBLabel7: TcxDBLabel;
    cxDBTextEdit4: TcxDBTextEdit;
    cxDBLabel8: TcxDBLabel;
    cxLabel5: TcxLabel;
    cxDBLabel9: TcxDBLabel;
    cxDBTextEdit5: TcxDBTextEdit;
    cxDBLabel10: TcxDBLabel;
    cxLabel6: TcxLabel;
    cxDBLabel11: TcxDBLabel;
    cxDBTextEdit6: TcxDBTextEdit;
    cxDBLabel12: TcxDBLabel;
    cxLabel7: TcxLabel;
    cxDBLabel13: TcxDBLabel;
    cxDBTextEdit7: TcxDBTextEdit;
    cxDBLabel14: TcxDBLabel;
    cxLabel8: TcxLabel;
    cxDBLabel15: TcxDBLabel;
    cxDBTextEdit8: TcxDBTextEdit;
    cxDBLabel16: TcxDBLabel;
    cxLabel9: TcxLabel;
    cxDBLabel17: TcxDBLabel;
    cxDBTextEdit9: TcxDBTextEdit;
    cxDBLabel18: TcxDBLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    cxLabel13: TcxLabel;
    cxLabel14: TcxLabel;
    cxLabel15: TcxLabel;
    cxLabel16: TcxLabel;
    cxLabel17: TcxLabel;
    cxLabel18: TcxLabel;
    JvNavPanelHeader1: TJvNavPanelHeader;
    JvNavPanelButton1: TJvNavPanelButton;
    cxLabel12: TcxLabel;
    cxDBLabel21: TcxDBLabel;
    cxLabel19: TcxLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBLabel2: TcxDBLabel;
    DtsGunSonuStokDetay: TDataSource;
    TabGunSonuStokDetay: TFDQuery;
    LabelGirenToplam: TcxLabel;
    LabelCikanToplam: TcxLabel;
    procedure cxDBTextEdit2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HizliGunsonuForm: THizliGunsonuForm;

implementation

{$R *.dfm}

uses UTablo;


procedure THizliGunsonuForm.cxDBTextEdit2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var s:string[20];
    Giren, Cikan : Real;
begin
     s:= TcxDBTextEdit(Sender).DataBinding.Datafield;
     s:=copy(s,1, length(s)-2);

     DtsGunSonuStokDetay.DataSet.Edit;
     DtsGunSonuStokDetay.DataSet.FieldByName(s).AsFloat:=DtsGunSonuStokDetay.DataSet.FieldByName(s+'_1').AsFloat+StrToFloatDef( TcxDBTextEdit(Sender).Text, 0);



//     Tablo.TablodanSorguAc(1,'select GIR=ROUND(DEVIR,2)+ROUND([GIREN],2)+ROUND([IADE],2)+ROUND([URETIM],2) from STOKGUNSONU where ID='+TcxDBTextEdit(Sender).DataBinding.Datasource.DataSet.Fields[0].asString);
     Giren :=  DtsGunSonuStokDetay.DataSet.FieldByName('GELEN').AsFloat+DtsGunSonuStokDetay.DataSet.FieldByName('IADE').AsFloat+
                                 DtsGunSonuStokDetay.DataSet.FieldByName('DEVIR').AsFloat+DtsGunSonuStokDetay.DataSet.FieldByName('URETIM').AsFloat;
     LabelGirenToplam.Caption :=FormatFloat('0.##', Giren);

//     Tablo.TablodanSorguAc(2,'select CIK = ROUND([SATIS],2)+ROUND([BOZUK],2)+ROUND([TRANSFER],2)+ROUND([SARF],2)+ROUND([KAYIP],2) from STOKGUNSONU where ID='+TcxDBTextEdit(Sender).DataBinding.Datasource.DataSet.Fields[0].asString);

     Cikan := DtsGunSonuStokDetay.DataSet.FieldByName('SATIS').AsFloat+DtsGunSonuStokDetay.DataSet.FieldByName('BOZUK').AsFloat+
                                 DtsGunSonuStokDetay.DataSet.FieldByName('GIDEN').AsFloat+DtsGunSonuStokDetay.DataSet.FieldByName('SARF').AsFloat+
                                 DtsGunSonuStokDetay.DataSet.FieldByName('KAYIP').AsFloat;
     LabelCikanToplam.Caption  := FormatFloat('0.##',Cikan);

     DtsGunSonuStokDetay.DataSet.FieldByName('KALAN').AsFloat := Giren - Cikan;
end;

procedure THizliGunsonuForm.JvNavPanelButton1Click(Sender: TObject);
begin
    DtsGunSonuStokDetay.DataSet.Post;
    modalresult := mrOk;
end;

procedure THizliGunsonuForm.KapatTusClick(Sender: TObject);
begin
    modalresult := mrcancel;
end;

end.

