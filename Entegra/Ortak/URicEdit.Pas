unit URicEdit;

interface

uses forms, Classes, Controls, comctrls, db, dbtables, WinTypes, SysUtils, Graphics,
     stdctrls, Messages, windows, richedit, dbctrls;
     // DBCtrls, Menus, entinit, ToolWin, Mask, ExtCtrls, Buttons, Dialogs, WinProcs;


// Rich Edit Ýþlemlerini açan kapatan nesneler
     procedure RichEditAc(RchEdt:TDBRichEdit;mRicDts:TDataSource);
     procedure RichEditKapa;


// AnaForm Dan gelen eventlar
    procedure FontNameChange1(Sender: TObject);
    procedure FontSizeChange1(Sender: TObject);
    procedure ColorButtonClick1(Sender: TObject);
    procedure BoldButtonClick1(Sender: TObject);
    procedure ItalicButtonClick1(Sender: TObject);
    procedure UnderlineButtonClick1(Sender: TObject);

    procedure AlignButtonClick1(Sender: TObject);

    procedure BulletsButtonClick1(Sender: TObject);

    procedure RulerResize1(Sender: TObject);
    procedure RulerItemMouseDown1(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RulerItemMouseMove1(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FirstIndMouseUp1(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LeftIndMouseUp1(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RightIndMouseUp1(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

    procedure UndoButtonClick1(Sender: TObject);











    procedure InitRicEdit1(Sender:TObject);
    procedure RichEditChange1(Sender: TObject);
    procedure SelectionChange1(Sender: TObject);
    procedure FormShow1(Sender: TObject);
    procedure FormPaint1(Sender: TObject);
    procedure FormResize1(Sender: TObject);
    function CurrText1: TTextAttributes;
    procedure GetFontNames1;
    procedure SetupRuler1;
    procedure SetEditRect1;
    procedure UpdateCursorPos1;
    function FUpdating_SetUpdate1:Boolean;
    Procedure EnableDisableEditButtons1(Datasource1 : TDatasource);

var
    FUpdating: Boolean;
    FDragOfs: Integer;
    FDragging: Boolean;
    CagiranModul : String[20];
    MemoEdit1 : TDBRichEdit;
    RicDts : TDataSource;

implementation
uses UAnaForm, UTablo;
const
   RulerAdj = 4/3;
   GutterWid = 6;

procedure RichEditAc(RchEdt:TDBRichEdit;mRicDts:TDataSource);
Begin
   MemoEdit1 := RchEdt;
   RicDts := mRicDts;
   AnaForm.Ruler.Visible:=True;
   AnaForm.Toolbar3.Visible:=True;
   InitRicEdit1(RchEdt.Parent);
End;

procedure RichEditKapa;
Begin
   MemoEdit1 := Nil;
   RicDts := Nil;
   AnaForm.Ruler.Visible:=False;
   AnaForm.Toolbar3.Visible:=False;
End;

procedure InitRicEdit1(Sender:TObject);
begin
   GetFontNames1;
   SetupRuler1;
   SelectionChange1(Sender);
end;

Procedure EnableDisableEditButtons1;
  Procedure EnableDisable(EnDis:Boolean);
  Begin
    AnaForm.FontName.Enabled := EnDis;
    AnaForm.FontSize.Enabled := EnDis;
    AnaForm.UpDown1.Enabled := EnDis;

    AnaForm.ColorButton.Enabled := EnDis;
    AnaForm.BoldButton.Enabled := EnDis;
    AnaForm.ItalicButton.Enabled := EnDis;
    AnaForm.UnderlineButton.Enabled := EnDis;

    AnaForm.LeftAlign.Enabled := EnDis;
    AnaForm.CenterAlign.Enabled := EnDis;
    AnaForm.RightAlign.Enabled := EnDis;

    AnaForm.BulletsButton.Enabled := EnDis;

    AnaForm.UndoButton.Enabled := EnDis;
  End;
begin
   if RicDts.State in [dsEdit, dsInsert] then
      EnableDisable(True)
   else
      EnableDisable(False);
end;

function FUpdating_SetUpdate1:Boolean;
Begin
   if (MemoEdit1 = Nil) Then Exit;
   FUpdating_SetUpdate1:=FUpdating;
   If Not FUpdating Then
      If RicDts.DataSet.Active Then
         RicDts.Edit;
End;

function EnumFontsProc1(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
begin
  TStrings(Data).Add(LogFont.lfFaceName);
  Result := 1;
end;

procedure UpdateCursorPos1;
var
  CharPos: TPoint;
begin
  CharPos.Y := SendMessage(MemoEdit1.Handle, EM_EXLINEFROMCHAR, 0,
    MemoEdit1.SelStart);
  CharPos.X := (MemoEdit1.SelStart -
    SendMessage(MemoEdit1.Handle, EM_LINEINDEX, CharPos.Y, 0));
  Inc(CharPos.Y);
  Inc(CharPos.X);
end;


procedure GetFontNames1;
var
  DC: HDC;
begin
  DC := GetDC(0);
  EnumFonts(DC, nil, @EnumFontsProc1, Pointer(AnaForm.FontName.Items));
  ReleaseDC(0, DC);
  AnaForm.FontName.Sorted := True;
end;

function CurrText1: TTextAttributes;
begin
  if (MemoEdit1 = Nil) Then Exit;
  if MemoEdit1.SelLength > 0 then Result := MemoEdit1.SelAttributes
  else Result := MemoEdit1.DefAttributes;
end;

procedure SetupRuler1;
var
  I: Integer;
  S: String;
begin
  SetLength(S, 201);
  I := 1;
  while I < 200 do
  begin
    S[I] := #9;
    S[I+1] := '|';
    Inc(I, 2);
  end;
  AnaForm.Ruler.Caption := S;
end;

procedure SetEditRect1;
var
  R: TRect;
begin
  with MemoEdit1 do
  begin
    R := Rect(GutterWid, 0, ClientWidth-GutterWid, ClientHeight);
    SendMessage(Handle, EM_SETRECT, 0, Longint(@R));
  end;
end;

procedure UndoButtonClick1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  with MemoEdit1 do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure FontNameChange1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  CurrText1.Name := AnaForm.FontName.Items[AnaForm.FontName.ItemIndex];

end;

procedure FontSizeChange1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  CurrText1.Size := StrToInt(AnaForm.FontSize.Text);

end;

procedure BoldButtonClick1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  if AnaForm.BoldButton.Down then
    CurrText1.Style := CurrText1.Style + [fsBold]
  else
    CurrText1.Style := CurrText1.Style - [fsBold];

end;

procedure ItalicButtonClick1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  if AnaForm.ItalicButton.Down then
    CurrText1.Style := CurrText1.Style + [fsItalic]
  else
    CurrText1.Style := CurrText1.Style - [fsItalic];

end;

procedure UnderlineButtonClick1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  if AnaForm.UnderlineButton.Down then
    CurrText1.Style := CurrText1.Style + [fsUnderline]
  else
    CurrText1.Style := CurrText1.Style - [fsUnderline];
end;

procedure AlignButtonClick1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  MemoEdit1.Paragraph.Alignment := TAlignment(TControl(Sender).Tag);
end;

procedure BulletsButtonClick1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  MemoEdit1.Paragraph.Numbering := TNumberingStyle(AnaForm.BulletsButton.Down);

end;

procedure RulerResize1(Sender: TObject);
begin
  AnaForm.RulerLine.Width := MemoEdit1.ClientWidth - (AnaForm.RulerLine.Left*2);
end;

procedure RulerItemMouseDown1(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragOfs := (TLabel(Sender).Width div 2);
  TLabel(Sender).Left := TLabel(Sender).Left+X-FDragOfs;
  FDragging := True;

end;

procedure RulerItemMouseMove1(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDragging then
    TLabel(Sender).Left :=  TLabel(Sender).Left+X-FDragOfs
end;

procedure FirstIndMouseUp1(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FUpdating_SetUpdate1 then Exit;
  FDragging := False;
  MemoEdit1.Paragraph.FirstIndent := Trunc((AnaForm.FirstInd.Left+FDragOfs-GutterWid) / RulerAdj);
  LeftIndMouseUp1(Sender, Button, Shift, X, Y);

end;

procedure LeftIndMouseUp1(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FUpdating_SetUpdate1 then Exit;
  FDragging := False;
  MemoEdit1.Paragraph.LeftIndent := Trunc((AnaForm.LeftInd.Left+FDragOfs-GutterWid) / RulerAdj)-MemoEdit1.Paragraph.FirstIndent;
  SelectionChange1(Sender);
end;

procedure RightIndMouseUp1(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FUpdating_SetUpdate1 then Exit;
  FDragging := False;
  MemoEdit1.Paragraph.RightIndent := Trunc((AnaForm.Ruler.ClientWidth-AnaForm.RightInd.Left+FDragOfs-2) / RulerAdj)-2*GutterWid;
  SelectionChange1(Sender);
end;

procedure RichEditChange1(Sender: TObject);
begin
  AnaForm.UndoButton.Enabled := SendMessage(MemoEdit1.Handle, EM_CANUNDO, 0, 0) <> 0;
end;

procedure SelectionChange1(Sender: TObject);
begin
  with MemoEdit1.Paragraph do
  try
    FUpdating := True;
    AnaForm.FirstInd.Left := Trunc(FirstIndent*RulerAdj)-4+GutterWid;
    AnaForm.LeftInd.Left := Trunc((LeftIndent+FirstIndent)*RulerAdj)-4+GutterWid;
    AnaForm.RightInd.Left := AnaForm.Ruler.ClientWidth-6-Trunc((RightIndent+GutterWid)*RulerAdj);
    AnaForm.BoldButton.Down := fsBold in MemoEdit1.SelAttributes.Style;
    AnaForm.ItalicButton.Down := fsItalic in MemoEdit1.SelAttributes.Style;
    AnaForm.UnderlineButton.Down := fsUnderline in MemoEdit1.SelAttributes.Style;
    AnaForm.BulletsButton.Down := Boolean(Numbering);
    AnaForm.FontSize.Text := IntToStr(MemoEdit1.SelAttributes.Size);
    AnaForm.FontName.Text := MemoEdit1.SelAttributes.Name;
    case Ord(Alignment) of
      0: AnaForm.LeftAlign.Down := True;
      1: AnaForm.RightAlign.Down := True;
      2: AnaForm.CenterAlign.Down := True;
    end;
    UpdateCursorPos1;
  finally
    FUpdating := False;
  end;
end;

procedure FormShow1(Sender: TObject);
begin
  RichEditChange1(nil);
  MemoEdit1.SetFocus;
end;

procedure FormPaint1(Sender: TObject);
begin
  SetEditRect1;
end;

procedure FormResize1(Sender: TObject);
begin
  SetEditRect1;
  SelectionChange1(Sender);
end;

procedure ColorButtonClick1(Sender: TObject);
begin
  if FUpdating_SetUpdate1 then Exit;
  Tablo.ColorDialog1.Color:=CurrText1.Color;
  if Tablo.ColorDialog1.Execute then
     CurrText1.Color:=Tablo.ColorDialog1.Color;
  MemoEdit1.SetFocus;
end;

end.
