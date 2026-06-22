{-------------------------------------------------------------------------------
Hata Kontrol unit
-----------------------------
29/09/2005 Necdet ÇETİNKAYA
           Oluşturma


-------------------------------------------------------------------------------}
unit UHata;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, Buttons, AppEvnts;
type
  THataDlg = class(TForm)
    edHataModul: TEdit;
    edHataSinifi: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    mHataMesaj: TMemo;
    Label3: TLabel;
    Label4: TLabel;
    mHataAyrinti: TMemo;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    dlgboxSave: TSaveDialog;
    ApplicationEvents1: TApplicationEvents;
    procedure SpeedButton2Click(Sender: TObject);
    procedure HatayiDosyayaz(DosyaIsmi:string);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HataDlg: THataDlg;
  hatalikomut:WideString;
implementation

{$R *.dfm}

procedure   THataDlg.HatayiDosyayaz(DosyaIsmi:string);
var
   hataDos:TextFile;
begin
   AssignFile(hataDos, dlgboxSave.FileName);

   Rewrite(hataDos);

   Writeln(hataDos,'Hata Tarihi');
   Writeln(hataDos,'----------------------------------------------------------');
   Writeln(hataDos,FormatDateTime('dd/mm/yyyy hh:mm:ss',now) ) ;
   Writeln(hataDos,'');
   Writeln(hataDos,'Hatayı Gönderen Modül');
   Writeln(hataDos,'----------------------------------------------------------');
   Writeln(hataDos,edHataModul.text);
   Writeln(hataDos,'');
   Writeln(hataDos,'Hata Kaynağı');
   Writeln(hataDos,'----------------------------------------------------------');
   Writeln(hataDos,edHataSinifi.text);
   Writeln(hataDos,'');
   Writeln(hataDos,'Hata Mesajı');
   Writeln(hataDos,'----------------------------------------------------------');
   Writeln(hataDos,mHataMesaj.text);
   Writeln(hataDos,'');
   Writeln(hataDos,'Hata Ayrıntı');
   Writeln(hataDos,'----------------------------------------------------------');
   Writeln(hataDos,mHataAyrinti.text);
   Writeln(hataDos,'');
   CloseFile(hataDos);


end;

procedure THataDlg.SpeedButton2Click(Sender: TObject);
begin
if dlgboxSave.Execute then
begin
      HatayiDosyayaz(dlgboxSave.FileName);
end;
end;

procedure THataDlg.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
   if HataDlg = nil then
      Application.CreateForm(THataDlg, HataDlg);
      HataDlg.edHataModul.Text:= Application.ExeName;
      HataDlg.edHataSinifi.Text:=E.ClassName;
      HataDlg.mHataMesaj.Text:=E.Message;
      HataDlg.mHataAyrinti.Text:= hatalikomut;
      hataDlg.ShowModal;

end;

end.
