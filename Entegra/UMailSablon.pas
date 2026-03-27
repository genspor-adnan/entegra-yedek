unit UMailSablon;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit,
  cxMemo, cxRichEdit, cxLabel, cxMaskEdit, cxDropDownEdit, cxImageComboBox,
  Vcl.StdCtrls, Vcl.ComCtrls, PrjConst, Vcl.ExtCtrls, Vcl.ToolWin,
  Data.DB, FireDAC.Comp.Client, cxDBEdit, cxDBRichEdit, FetaKurulusSiniflari,
  Vcl.DBCtrls, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxNavigator, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, Vcl.Buttons, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxGroupBox, Vcl.StdActns, System.Actions, Vcl.ActnList, Vcl.ExtActns,
  JvComponentBase, JvRichEditToHtml, JvExStdCtrls, JvRichEdit, JvDBRichEdit,
  Vcl.OleCtrls, SHDocVw, dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, Vcl.CategoryButtons, cxCheckBox, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray;

type
  TMailSablon = class(TForm)
    dtsMailSablonu: TDataSource;
    TabMailSablon: TFDQuery;
    Panel1: TPanel;
    Panel2: TPanel;
    ToolBar1: TToolBar;
    MailSablonKaydet: TToolButton;
    MailSablonIptal: TToolButton;
    cxGroupBox1: TcxGroupBox;
    SolMenu: TCategoryButtons;
    Panel3: TPanel;
    cxlblModul: TcxLabel;
    txtKonu: TcxDBTextEdit;
    cxlbl1: TcxLabel;
    cxGroupBox2: TcxGroupBox;
    cxDBCheckBox1: TcxDBCheckBox;
    cxDBCheckBox2: TcxDBCheckBox;
    cxDBCheckBox3: TcxDBCheckBox;
    cxDBRichEdit1: TcxDBRichEdit;
    ComoDokum: TcxDBImageComboBox;
    ToolButton1: TToolButton;
    JvRichEdit1: TJvRichEdit;
    KapatTus: TToolButton;
    procedure MailSablonKaydetClick(Sender: TObject);
    procedure MailSablonIptalClick(Sender: TObject);
    procedure TabMailSablonBeforePost(DataSet: TDataSet);
    procedure comboSablonAdiPropertiesEditValueChanged(Sender: TObject);
    procedure dtsMailSablonuStateChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SolMenuButtonClicked(Sender: TObject; const Button: TButtonItem);
    procedure KapatTusClick(Sender: TObject);
  private
    procedure CikisIslemleri;
    { Private declarations }
  public
    { Public declarations }
    ModulID:Integer;
  end;

var
  MailSablon: TMailSablon;

implementation

{$R *.dfm}

uses Utablo;

procedure TMailSablon.CikisIslemleri;
begin
  if dtsMailSablonu.State in [dsEdit,dsInsert] then
  begin
    if Application.MessageBox(PChar(PrjConst.KayitIslemi),PChar(PrjConst.Uyari),MB_YESNO+MB_ICONWARNING) = IDYES then
    begin
      TabMailSablon.Post;
    end;
  end;
end;


procedure TMailSablon.comboSablonAdiPropertiesEditValueChanged(  Sender: TObject);
begin
  //if (comboModul.EditValue > -1) and (comboSablonAdi.EditValue > -1) and (comboModul.EditValue <> null) and (comboSablonAdi.EditValue <> null) then
  //begin
  //  if TabMailSablon.Active then TabMailSablon.Close;
  //  TabMailSablon.SQL.Text := 'SELECT * FROM MAILSABLON WHERE ID=:ID AND MODULID=:MODULID';
  //  TabMailSablon.ParamByName('MODULID').Value := comboModul.EditValue;
  //  TabMailSablon.ParamByName('ID').Value := comboSablonAdi.EditValue;
  //  TabMailSablon.Open;
  //end;
end;

procedure TMailSablon.dtsMailSablonuStateChange(Sender: TObject);
begin
   MailSablonKaydet.Visible :=  dtsMailSablonu.State in [dsEdit,dsInsert];
   MailSablonIptal.Visible :=  MailSablonKaydet.Visible
end;

procedure TMailSablon.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CikisIslemleri;
end;

procedure TMailSablon.FormCreate(Sender: TObject);
begin
  //comboModul.Properties.Items := Tablo.imgComboboxInit('SELECT MODULID, MODULADI FROM MODUL WHERE LEN(MODULID)=2').Items;
end;

procedure TMailSablon.FormShow(Sender: TObject);
var Items:TcxImageComboBoxItems;
begin
   TabloYenile( TabMailSablon, [ModulID]);
   SolMenu.Categories[0].Caption := 'Servis';
   while not TabMailSablon.eof do begin
      with SolMenu.Categories[0].Items.Add do begin
        ImageIndex:= 18;
        Caption:=TabMailSablon.Fields[1].AsString;
        Hint:=TabMailSablon.Fields[0].AsString;
      end;
      TabMailSablon.next;
   end;

   Tablo.TablodanSorguAc(1,'select ID,RAPORADI from DOKUMLER where GRUBU = ''Servis-Genel''');
   while not Tablo.Query1.eof do begin
      Items := TcxImageComboBoxProperties(ComoDokum.Properties).Items;
      with Items.Add do begin
        Description:=Tablo.Query1.Fields[1].AsString;
        Value:=Tablo.Query1.Fields[0].AsInteger;
        Tag:=Tablo.Query1.Fields[0].AsInteger;
      end;
      Tablo.Query1.next;
   end;
end;

procedure TMailSablon.KapatTusClick(Sender: TObject);
begin
  CikisIslemleri;
end;

procedure TMailSablon.MailSablonIptalClick(Sender: TObject);
begin
  if TabMailSablon.Active then
     TabMailSablon.Cancel;
end;

procedure TMailSablon.MailSablonKaydetClick(Sender: TObject);
begin
  if TabMailSablon.Active then
     TabMailSablon.Post;
end;

procedure TMailSablon.SolMenuButtonClicked(Sender: TObject; const Button: TButtonItem);
begin
   TabMailSablon.Locate('ID', StrToIntDef(Button.Hint,0),[]);
end;

procedure TMailSablon.TabMailSablonBeforePost(DataSet: TDataSet);
begin
    TabMailSablon.FieldByName('DEGISTIREN').Value := Kullanan;
    TabMailSablon.FieldByName('DEGISTIRMETARIHI').Value := Now;
end;

end.


