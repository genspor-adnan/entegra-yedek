unit UValueList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ValEdit, StdCtrls, Buttons;

type
  TValueListDlg = class(TForm)
    Label1: TLabel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    ValueListEditor1: TValueListEditor;
    procedure ValueListEditor1StringsChange(Sender: TObject);
    procedure ValueListEditor1StringsChanging(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ValueListDlg: TValueListDlg;

implementation

Uses UTablo;

{$R *.dfm}

var  Onceki : String;
     Olustu : Boolean;
procedure TValueListDlg.FormCreate(Sender: TObject);
begin
   Olustu := False;
end;

procedure TValueListDlg.FormShow(Sender: TObject);
begin
   Olustu :=True
end;

procedure TValueListDlg.ValueListEditor1StringsChange(Sender: TObject);
begin
   if (Olustu)and(Onceki <> ValueListEditor1.Cells[1,1]) then  begin
      if ValueListEditor1.Cells[1,1]='' then
         ValueListEditor1.ItemProps[1].PickList.Clear
      else
         GenotipIni.ReadSection(ValueListEditor1.Cells[1,1], ValueListEditor1.ItemProps[1].PickList);
   end;
end;

procedure TValueListDlg.ValueListEditor1StringsChanging(Sender: TObject);
begin
   Onceki := ValueListEditor1.Cells[1,1];
end;

procedure TValueListDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var Degervar : boolean;
    i : Smallint;
begin
{   Degervar:=True;
   for i := 1 to ValueListEditor1.rowcount -1 do
       if ValueListEditor1.Cells[1,i] = '' then Degervar:=False;
   if not Degervar then ShowMessage('Boş satır olmamalı...');
   CanClose := Degervar;  }
   CanClose := True;
end;

end.
