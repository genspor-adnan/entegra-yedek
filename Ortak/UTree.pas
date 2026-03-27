unit UTree;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, ComCtrls, dbtables;

type
  TTreeDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Tree1: TTreeView;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    Table1: TTable;
    KeyAlan1, Alan1 : String;
  public
    { Public declarations }
  end;

  procedure AgacOlustur(Table2:TTable; KeyAlan2, Alan2 : String);

var
  TreeDlg: TTreeDlg;

implementation

{$R *.DFM}

procedure AgacOlustur(Table2:TTable; KeyAlan2, Alan2 : String);
begin
   Application.CreateForm(TTreeDlg, TreeDlg);
   TreeDlg.Table1   := Table2;
   TreeDlg.KeyAlan1 := KeyAlan2;
   TreeDlg.Alan1    := Alan2;
   TreeDlg.Showmodal;
   TreeDlg.Destroy;
end;


procedure TTreeDlg.FormShow(Sender: TObject);
var
  j, Sev, OncekiSev : integer;
  seviye : array[0..5] of TTreeNode;
  OncekiKey, OncekiAlan : String[40];

  function GecenSay(st:string):integer;
  begin
     j:=0;
     while pos('.', st) >0 do begin
        inc(j);
        delete(st, 1, pos('.', st));
     end;
     GecenSay := j;
  end;

  procedure Ekleme;
  begin
   with Tree1.Items do begin
    Sev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
    if (Sev > OncekiSev)or(OncekiSev = 0) then
      Seviye[OncekiSev] := Add(Seviye[OncekiSev], OncekiKey+' '+OncekiAlan) { Add a root node }
    else
      AddChild(Seviye[OncekiSev-1], OncekiKey+' '+OncekiAlan); { Add a child }
   end;{do}
  end;{proc}
//  A N A   P R O G R A M
begin
    for Sev := 0 to 5 do seviye[Sev] := nil;
   Table1.First;
   Tree1.Items.Clear;
   OncekiSev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
   OncekiKey := Table1.FieldByName(KeyAlan1).AsString;
   OncekiAlan:= Table1.FieldByName(Alan1).AsString;
   Table1.next;
   while not Table1.eof do begin
      Ekleme;
      OncekiSev := Sev;
      OncekiKey := Table1.FieldByName(KeyAlan1).AsString;
      OncekiAlan:= Table1.FieldByName(Alan1).AsString;
      Table1.next;
   end;{while}
   Ekleme;
end;
end.


