unit UTasimaBirimi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,UTablo, cxGraphics,UPaketleme,cxControls,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, cxLabel, ComCtrls, ToolWin, cxSpinEdit;

type
  TTasimaBirimiGirisDlg = class(TForm)
    ImgComboTasimaBirimi: TcxImageComboBox;
    cxLabel2: TcxLabel;
    ToolBar1: TToolBar;
    BtnKaydet: TToolButton;
    BtnYazdýr: TToolButton;
    BtnVazgeç: TToolButton;
    LblUstTasýmaBirimi: TcxLabel;
    cxLabel3: TcxLabel;
    EdtAdet: TcxSpinEdit;
    procedure BtnVazgeçClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
  private
    { Private declarations }
    procedure TasimaBirimiDoldur(UstTasimaBirimi:String; ImgCom: TcxImageComboBox);
  public
    { Public declarations }
  end;

var
  TasimaBirimiGirisDlg: TTasimaBirimiGirisDlg;

implementation

Uses UItsAraclari;

{$R *.dfm}

procedure TTasimaBirimiGirisDlg.BtnKaydetClick(Sender: TObject);
var
Tasima_birimi : string;
I : byte;
begin
for I := 0 to StrToInt(EdtAdet.Text) - 1 do
begin
Tasima_birimi := Tablo.SSCCOlustur(ImgComboTasimaBirimi.EditValue);

  if Tasima_birimi<>'' then
  begin
    if PaketlemeDlg.TabTasimaBirimi.FieldByName('ID').AsString<>'' then
      begin
        Tablo.Query1.Close;
        TABLO.Query1.SQL.TEXT := 'INSERT INTO ITS_TASIMA_BIRIMI (USTID,TASIMA_BIRIMI,SSCC,PAKETID ) ' +
                         ' VALUES('+PaketlemeDlg.TabTasimaBirimi.FieldByName('ID').AsString+','''+ImgComboTasimaBirimi.EditingValue+''','''+Tasima_birimi+''','+PaketlemeDlg.LblPaketId.Caption+')  ' ;
        Tablo.Query1.ExecSQL;
      end
    else
      begin
        Tablo.Query1.Close;
        TABLO.Query1.SQL.TEXT := 'INSERT INTO ITS_TASIMA_BIRIMI (TASIMA_BIRIMI,SSCC,PAKETID ) ' +
                         ' VALUES('''+ImgComboTasimaBirimi.EditingValue+''','''+Tasima_birimi+''','+PaketlemeDlg.LblPaketId.Caption+')  ' +
                         'SELECT SCOPE_IDENTITY() as ID ';
        Tablo.Query1.Open;
        Tablo.Query2.Close;
        Tablo.Query2.SQL.Text := 'UPDATE ITS_TASIMA_BIRIMI SET USTID = -1 WHERE ID = '+TABLO.Query1.FieldByName('ID').AsString +' ';
        Tablo.Query2.ExecSQL;
      end;
  end;
end;
Close;
end;

procedure TTasimaBirimiGirisDlg.BtnVazgeçClick(Sender: TObject);
begin
Close;
end;

procedure TTasimaBirimiGirisDlg.FormShow(Sender: TObject);
begin
  TasimaBirimiDoldur(PaketlemeDlg.TabTasimaBirimi.FieldByName('TASIMA_BIRIMI').AsString,ImgComboTasimaBirimi);
end;

procedure TTasimaBirimiGirisDlg.TasimaBirimiDoldur(UstTasimaBirimi:String; ImgCom: TcxImageComboBox);
var
TasimaBirimiSýra : Byte;
I : Byte;
Item  : TcxImageComboBoxItem;
begin
TasimaBirimiSýra :=  Tablo.TasimiBirimToTasimaSira(UstTasimaBirimi);
ImgCom.Properties.Items.Clear;
    if TasimaBirimiSýra = 0  then
    begin
      for I := Low(TasimaBirimi)  to High(TasimaBirimi)  do
      begin
        Item := ImgCom.Properties.Items.Add;
        Item.Value := TasimaBirimi[I].BirimTipi;
        Item.Description := TasimaBirimi[I].BirimSabit;
      end;
    end else
    begin
      for I := Low(TasimaBirimi)  to High(TasimaBirimi)  do
      begin
        if TasimaBirimiSýra > TasimaBirimi[I].BirimSira  then
        begin
          Item := ImgCom.Properties.Items.Add;
          Item.Value := TasimaBirimi[I].BirimTipi;
          Item.Description := TasimaBirimi[I].BirimSabit;
        end;
      end;
    end;

end;

end.
