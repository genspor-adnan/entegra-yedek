unit UYukle3;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TYukle3 = class(TForm)
    Son: TButton;
    Button2: TButton;
    Image1: TImage;
    SaveDialog1: TSaveDialog;
    Button1: TButton;
    Label1: TLabel;
    Meta: TEdit;
    Log: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Yukle3: TYukle3;
  YukleYol : String;

implementation

uses UTablo;

{$R *.DFM}
var MetaLogic, LogLogic : String[40];

procedure TYukle3.FormShow(Sender: TObject);
begin
   Tablo.Query1.SQL.Text := ' RESTORE FILELISTONLY FROM DISK ='''+YukleYol+'''';
   Tablo.Query1.Open;
   if pos('.MDF', Uppercase(Tablo.Query1.FieldByName('PhysicalName').AsString))>0 then begin
      Meta.Text := Tablo.Query1.FieldByName('PhysicalName').AsString;
      MetaLogic := Tablo.Query1.FieldByName('LogicalName').AsString;
   end;
   Tablo.Query1.Next;
   if pos('.LDF', Uppercase(Tablo.Query1.FieldByName('PhysicalName').AsString))>0 then begin
      Log.Text := Tablo.Query1.FieldByName('PhysicalName').AsString;
      LogLogic := Tablo.Query1.FieldByName('LogicalName').AsString;
   end;
end;

procedure TYukle3.SpeedButton2Click(Sender: TObject);
begin
   if not SaveDialog1.Execute then exit;
   Meta.Text := SaveDialog1.FileName;
end;

procedure TYukle3.SpeedButton1Click(Sender: TObject);
begin
   if not SaveDialog1.Execute then exit;
   Log.Text := SaveDialog1.FileName;
end;

procedure TYukle3.SonClick(Sender: TObject);
begin
   Tablo.Query1.SQL.Text := 'RESTORE DATABASE '+Database+' FROM DISK ='''+YukleYol+''''+
              ' WITH MOVE '''+MetaLogic+''' TO '''+Meta.Text+''','+
              ' MOVE '''+LogLogic+''' TO '''+Log.Text+'''';
   Tablo.Query1.ExecSQL;
end;

end.
