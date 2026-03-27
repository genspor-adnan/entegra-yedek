unit UOzelNotlar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Buttons, ExtCtrls,db ;

type
  TOzelNotlarDlg = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    dbmOzelNotlar: TDBMemo;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OzelNotlarDlg: TOzelNotlarDlg;

implementation
 uses Utablo;
{$R *.DFM}

procedure TOzelNotlarDlg.BitBtn1Click(Sender: TObject);
begin
//   Tablo.TabRehber.Post;

end;

procedure TOzelNotlarDlg.BitBtn2Click(Sender: TObject);
begin
//   if Tablo.TabRehber.State in [dsEdit, dsInsert] then
//    if MessageDlg('Deðiþiklik yapýldý kaydetmek ister misiniz',mtConfirmation,mbYesNoCancel,0 ) = mryes
//    then
//      Tablo.TabRehber.Post
//    ELSE
//      Tablo.TabRehber.Cancel;
//       Self.Close;
end;

end.
