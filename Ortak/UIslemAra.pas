unit UIslemAra;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Db, DBTables, Grids, DBGrids, UFDCompatHelpers;

type
  TIslemAraDlg = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    DBGrid1: TDBGrid;
    DtsIslem: TDataSource;
    TabIslem: TADOQuery;
    Edit2: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    OKBtn: TBitBtn;
    BitBtn2: TBitBtn;
    procedure Edit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure Edit2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Edit3KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  IslemAraDlg: TIslemAraDlg;

implementation

{$R *.DFM}

procedure TIslemAraDlg.Edit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{  if Key = 38 then Query1.Prior
  else if Key = 40 then Query1.next
  else begin
    Query1.SQL.Text := 'Select * from ISLEMLER where ISLEMADI like ''' + Edit1.Text + '%'' and FIYAT_LISTE=''E'' order by ISLEMADI';
    Query1.Open;
  end;
}
end;

procedure TIslemAraDlg.DBGrid1DblClick(Sender: TObject);
begin
  OKBtn.Click;
end;

procedure TIslemAraDlg.Edit2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 38 then TabIslem.Prior
  else if Key = 40 then TabIslem.next
  else begin
    TabIslem.Close;
    TabIslem.SQL.Text := 'Select * from ISLEMLER where ISNULL(KOD,'''') like ''' + Edit2.Text + '%'' and ISNULL(BUTCEKODU,'''') like ''' + Edit3.Text +
      '%'' and ISNULL(ISLEMADI,'''') like ''' + Edit1.Text + '%'' and FIYAT_LISTE=''E'' order by KOD';
    TabIslem.Open;
  end;
end;

procedure TIslemAraDlg.Edit3KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{  if Key = 38 then Query1.Prior
  else if Key = 40 then Query1.next
  else begin
    Query1.SQL.Text := 'Select * from ISLEMLER where BUTCEKODU like ''' + Edit3.Text + '%'' and FIYAT_LISTE=''E'' order by KOD';
    Query1.Open;
  end;
}
end;

procedure TIslemAraDlg.FormShow(Sender: TObject);
var Key: word;
begin

  edit1.SetFocus;
  Key := 0;
  Edit2KeyUp(Self, Key, [ssShift]);
end;

end.


