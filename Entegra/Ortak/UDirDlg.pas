unit UDirDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, FileCtrl;

type
  TDirDlg = class(TForm)
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    Yol: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    Bevel1: TBevel;
    procedure DirectoryListBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DirDlg: TDirDlg;

implementation

{$R *.DFM}

procedure TDirDlg.DirectoryListBox1Change(Sender: TObject);
begin
   Yol.Text := DirDlg.DirectoryListBox1.Directory;
end;

end.

