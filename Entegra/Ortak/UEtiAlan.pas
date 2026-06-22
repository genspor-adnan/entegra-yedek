unit UEtiAlan;

interface       

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, DBCtrls;

type
  TEtiketAlanDlg = class(TForm)
    Bevel1: TBevel;
    Label8: TLabel;
    OKTus: TSpeedButton;
    Label9: TLabel;
    SolaOkTus: TSpeedButton;
    FieldList: TDBMemo;
    ComboTablolar: TComboBox;
    FieldListBox: TListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    Label4: TLabel;
    Label5: TLabel;
    procedure OKTusClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboTablolarChange(Sender: TObject);
    procedure SolaOkTusClick(Sender: TObject);
  private
    { Private declarations }
    function SatirBul: Integer;
  public
    { Public declarations }
  end;

var
  EtiketAlanDlg: TEtiketAlanDlg;

implementation

uses UDokum, FetaUtil;

{$R *.DFM}

procedure TEtiketAlanDlg.OKTusClick(Sender: TObject);
begin
  TabloDokum.TabDokum.Edit;
  FieldList.Lines.Add('{' + FieldListBox.Items[FieldListBox.ItemIndex] + '}');
end;

procedure TEtiketAlanDlg.BitBtn1Click(Sender: TObject);
begin
  TabloDokum.TabDokum.Post;
end;

procedure TEtiketAlanDlg.BitBtn2Click(Sender: TObject);
begin
  TabloDokum.TabDokum.Cancel;
end;

procedure TEtiketAlanDlg.FormShow(Sender: TObject);
begin
  TabloDokum.Ini.ReadSection('TABLEADLARI', ComboTablolar.Items);
  ComboTablolar.Text := ComboTablolar.Items[0];
  ComboTablolarChange(self);
end;

procedure TEtiketAlanDlg.ComboTablolarChange(Sender: TObject);
begin
  FieldListBox.Clear;
  TabloDokum.Table1.close;
  TabloDokum.Table1.TableName := ComboTablolar.Text;
//   TabloDokum.Table1.SQL.Text := ' select top 1 * from '+ComboTablolar.Text;
  TabloDokum.Table1.open;
  TabloDokum.Table1.GetFieldNames(FieldListBox.Items);
end;

function TEtiketAlanDlg.SatirBul: Integer;
var
  k, uz: Integer;
  TopChar: Integer;
begin
  TopChar := 0;
  for k := 0 to FieldList.Lines.Count - 1 do begin
    Uz := Length(FieldList.Lines[k]);
    TopChar := TopChar + Uz + 2;
    if (TopChar > FieldList.SelStart) then begin
      SatirBul := k;
      Exit;
    end;
  end;
  SatirBul := -1;

end;

procedure TEtiketAlanDlg.SolaOkTusClick(Sender: TObject);
var s: string[50];
begin
  if FieldList.Lines[SatirBul] = '' then exit;
  FieldList.Lines.Delete(SatirBul);
end;

end.
