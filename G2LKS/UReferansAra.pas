unit UReferansAra;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, DB, Grids, DBGrids, ADODB;

type
  TReferansAraDlg = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    SecBtn: TSpeedButton;
    EditKodAra: TEdit;
    EditKurumAra: TEdit;
    Panel2: TPanel;
    EditAnaKurumAra: TEdit;
    Label3: TLabel;
    TabReferans: TADOQuery;
    DBGrid1: TDBGrid;
    DtsReferans: TDataSource;
    SpeedButton1: TSpeedButton;
    procedure EditKodAraKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure SecBtnClick(Sender: TObject);
    procedure TabReferansAfterOpen(DataSet: TDataSet);
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ReferansAraDlg: TReferansAraDlg;

implementation

Uses UTablo;

{$R *.dfm}

procedure TReferansAraDlg.EditKodAraKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 13 then SecBtn.Click
    else if Key = 40 then TabReferans.Next
    else if Key = 38 then TabReferans.Prior
    else TabloYenile(TabReferans,[EditKodAra.Text+'%', EditKurumAra.Text+'%', EditAnaKurumAra.Text+'%' ]);
end;

procedure TReferansAraDlg.DBGrid1DblClick(Sender: TObject);
begin
  SecBtn.Click;
end;

procedure TReferansAraDlg.SecBtnClick(Sender: TObject);
begin
  ModalResult:= mrOk;
end;

procedure TReferansAraDlg.TabReferansAfterOpen(DataSet: TDataSet);
begin
   SecBtn.Enabled:= True;
end;

procedure TReferansAraDlg.FormActivate(Sender: TObject);
begin
  EditKurumAra.SetFocus;
end;

procedure TReferansAraDlg.SpeedButton1Click(Sender: TObject);
begin
  Close;
end;

end.
