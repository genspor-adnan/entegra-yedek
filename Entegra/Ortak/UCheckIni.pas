unit UCheckIni;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, CheckLst, ExtCtrls, UCombo;

type
  TCheck_IniListDlg = class(TForm)
    Bevel1: TBevel;
    CheckListBox1: TCheckListBox;
    KapatTus: TBitBtn;
    KaydetTus: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Check_IniListDlg: TCheck_IniListDlg;

function Check_IniList(Ini : TIni; Bolum:String; Tum1 : TStringList):boolean;
implementation


{$R *.DFM}
uses UTablo;

var i : smallint;

function Check_IniList(Ini : TIni; Bolum:String; Tum1 : TStringList):boolean;
begin
   Application.CreateForm(TCheck_IniListDlg, Check_IniListDlg);
   for i := 0 to Tum1.Count-1 do begin
       Check_IniListDlg.CheckListBox1.Items.Add(Tum1.Strings[i]);
       Check_IniListDlg.CheckListBox1.checked[i] := Ini.ReadBool(Bolum, Check_IniListDlg.CheckListBox1.Items[i], False);
   end;
   Check_IniListDlg.ShowModal;

   if Check_IniListDlg.ModalResult = mrOK then begin
      Ini.EraseSection(Bolum);
      for i := 0 to Check_IniListDlg.CheckListBox1.Items.Count - 1 do
        if Check_IniListDlg.CheckListBox1.checked[i] then
           Ini.WriteBool(Bolum, Check_IniListDlg.CheckListBox1.Items[i], True);
   end;
   Check_IniListDlg.Destroy;
end;

end.
