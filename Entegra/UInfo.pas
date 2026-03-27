unit UInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, Vcl.ComCtrls, dxCore, cxDateUtils,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, cxMaskEdit, cxDropDownEdit, cxCalendar,  DateUtils,
  cxTextEdit;

type
  TInfoDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EditEkleyen: TcxTextEdit;
    EditEklemeTrh: TcxDateEdit;
    EditDegistiren: TcxTextEdit;
    EditDegistirmeTrh: TcxDateEdit;
    cxButton1: TcxButton;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    TabloAd:String; ID:Integer
  end;

var
  InfoDlg: TInfoDlg;

implementation

   uses UTablo;
{$R *.dfm}

procedure TInfoDlg.FormShow(Sender: TObject);
begin
   Tablo.TablodanSorguAc(1,'select EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI from '+TabloAd+' where ID ='+IntToStr(ID));

   EditEkleyen.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('EKLEYEN').AsInteger);
   EditDegistiren.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Tablo.Query1.FieldByName('DEGISTIREN').AsInteger);
   EditEklemeTrh.EditValue := Tablo.Query1.FieldByName('EKLEMETARIHI').AsDateTime;
   if YearOf(Tablo.Query1.FieldByName('DEGISTIRMETARIHI').AsDateTime) > 2000  then
      EditDegistirmeTrh.EditValue := Tablo.Query1.FieldByName('DEGISTIRMETARIHI').AsDateTime;
end;

end.
