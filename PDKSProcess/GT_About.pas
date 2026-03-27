unit GT_About;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, jpeg;

type
  TAboutBox = class(TForm)
    Panel2: TPanel;
    Label1: TLabel;
    Panel3: TPanel;
    Label2: TLabel;
    Label4: TLabel;
    Image3: TImage;
    Image1: TImage;
    Label3: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Label5: TLabel;
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

uses UVersiyon;

{$R *.DFM}

procedure TAboutBox.Button4Click(Sender: TObject);
begin
//  if Super then begin
  Application.CreateForm(TVersiyonDlg, VersiyonDlg);
  VersiyonDlg.ShowModal;
  VersiyonDlg.Destroy;
//   end
//   else
//      showmessage('Bu bölüme girmeye yetkili deðilsiniz..');
end;

procedure TAboutBox.Button5Click(Sender: TObject);
begin
  WinExec('dxDiag', SW_SHOW);
end;

procedure TAboutBox.Button3Click(Sender: TObject);
begin
  AboutBox.Close;
end;

end.
