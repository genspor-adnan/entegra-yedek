unit UAraIslem;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Db, DBTables, Grids, DBGrids, UFDCompatHelpers;

type
  TAraIslemDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Edit1: TEdit;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Query1: TADOQuery;
    Edit2: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure Edit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure Edit2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AraIslemDlg: TAraIslemDlg;

  function AraIslemGetir:String;

implementation

{$R *.DFM}

function AraIslemGetir:String;
begin
   Application.CreateForm(TAraIslemDlg, AraIslemDlg);
   AraIslemDlg.ShowModal;
   if AraIslemDlg.ModalResult = mrOK then
      if AraIslemDlg.Query1.RecordCount>0 then
         AraIslemGetir := AraIslemDlg.Query1.Fields[0].AsString
      else
         AraIslemGetir := AraIslemDlg.Edit1.Text;
   AraIslemDlg.Destroy;
end;

procedure TAraIslemDlg.Edit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 38 then Query1.Prior
   else if Key = 40 then Query1.next
   else begin
     Query1.SQL.Text := 'Select KOD, ISLEMADI from ISLEMLER where ISLEMADI like '''+Edit1.Text+'%'' and FIYAT_LISTE=''E'' order by ISLEMADI';
     Query1.Open;
  end;
end;

procedure TAraIslemDlg.DBGrid1DblClick(Sender: TObject);
begin
   OKBtn.Click;
end;

procedure TAraIslemDlg.Edit2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 38 then Query1.Prior
   else if Key = 40 then Query1.next
   else begin
     Query1.SQL.Text := 'Select KOD, ISLEMADI from ISLEMLER where KOD like '''+Edit2.Text+'%'' and FIYAT_LISTE=''E'' order by KOD';
     Query1.Open;
  end;
end;

end.

