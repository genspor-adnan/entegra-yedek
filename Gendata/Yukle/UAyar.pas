unit UAyar;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Dialogs;

type
  TAyarDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    SaveDialog1: TSaveDialog;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    SpeedButton1: TSpeedButton;
    Yol: TEdit;
    GroupBox2: TGroupBox;
    labelDatabase: TLabel;
    Veritabani: TEdit;
    Label3: TLabel;
    Meta: TEdit;
    Label4: TLabel;
    Log: TEdit;
    procedure OKBtnClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure YolChange(Sender: TObject);
    procedure VeritabaniChange(Sender: TObject);
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
   YedekIni.WriteString('Yukle', 'Dizin', Yol.Text);
//   YedekIni.WriteString('Yukle', 'Yedekadi', Adi.Text);
   YedekIni.WriteString('Yukle', 'Database', Veritabani.Text);
   YedekIni.WriteString('Yukle', 'Metadizin', Meta.Text);
   YedekIni.WriteString('Yukle', 'Logdizin', Log.Text);
end;

procedure TAyarDlg.SpeedButton1Click(Sender: TObject);
begin
   if SaveDialog1.Execute then
      Yol.Text := SaveDialog1.FileName;
end;

procedure TAyarDlg.VeritabaniChange(Sender: TObject);
var s:string;
function Rev_Pos(Substr: string; S: string): Integer;
var i,j,k:integer;
begin
   result:=0;
   k := length(substr) - 1;
   for i := length(s)- k downto 1 do
   begin
      for j := 0 to k do
      begin
         if s[i+j] <> substr[j+1] then break;
         if j = k then
         begin
            result := i;
            exit;
         end;
      end;
   end;
//   if length(s)+1
//   result := length(s)+1;
end;
begin
   s := Meta.Text;
   s := copy(s,1,Rev_Pos('\', s));
   Meta.Text :=s+VeriTabani.Text+'.MDF';

   s := Log.Text;
   s := copy(s,1,Rev_Pos('\', s));
   Log.Text :=s+VeriTabani.Text+'_Log.LDF'
end;

procedure TAyarDlg.YolChange(Sender: TObject);
var MetaLogic, LogLogic : String[40];
begin
   Tablo.Query1.SQL.Text := ' RESTORE FILELISTONLY FROM DISK ='''+Yol.Text+'''';
   Tablo.Query1.Open;
   if pos('.MDF', Uppercase(Tablo.Query1.FieldByName('PhysicalName').AsString))>0 then begin
      Meta.Text := Tablo.Query1.FieldByName('PhysicalName').AsString;
      MetaLogic := Tablo.Query1.FieldByName('LogicalName').AsString;
      YedekIni.WriteString('Yukle', 'MetaLogic', MetaLogic);
   end;
   Tablo.Query1.Next;
   if pos('.LDF', Uppercase(Tablo.Query1.FieldByName('PhysicalName').AsString))>0 then begin
      Log.Text := Tablo.Query1.FieldByName('PhysicalName').AsString;
      LogLogic := Tablo.Query1.FieldByName('LogicalName').AsString;
      YedekIni.WriteString('Yukle', 'LogLogic', LogLogic);
   end;

end;

end.
