unit UAyar;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Dialogs;

type
  TAyarDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    labelDatabase: TLabel;
    Veritabani: TEdit;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    SaveDialog1: TSaveDialog;
    Yol: TEdit;
    Adi: TEdit;
    Label1: TLabel;
    procedure OKBtnClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AyarDlg: TAyarDlg;

implementation

{$R *.DFM}
uses UTablo;

procedure TAyarDlg.OKBtnClick(Sender: TObject);
begin
   YedekIni.WriteString('Yedekle', 'Database', Veritabani.Text);
   YedekIni.WriteString('Yedekle', 'Dizin', Yol.Text);
   YedekIni.WriteString('Yedekle', 'Yedekadi', Adi.Text);
end;

procedure TAyarDlg.SpeedButton1Click(Sender: TObject);
begin
   if SaveDialog1.Execute then
      Yol.Text := SaveDialog1.FileName;
end;

end.
