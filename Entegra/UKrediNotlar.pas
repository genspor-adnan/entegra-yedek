unit UKrediNotlar;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Buttons, ExtCtrls,db, ComCtrls, RichEdit ;

type
  TKrediNotlarDlg = class(TForm)
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    MemoKrediNotlar: TDBRichEdit;
    Panel2: TPanel;
    FontName: TComboBox;
    FontSize: TEdit;
    UpDown1: TUpDown;
    ColorButton: TSpeedButton;
    BoldButton: TSpeedButton;
    ItalicButton: TSpeedButton;
    UnderlineButton: TSpeedButton;
    LeftAlign: TSpeedButton;
    CenterAlign: TSpeedButton;
    RightAlign: TSpeedButton;
    Ruler: TPanel;
    FirstInd: TLabel;
    LeftInd: TLabel;
    RulerLine: TBevel;
    RightInd: TLabel;
    ColorDialog1: TColorDialog;
    BulletsButton: TSpeedButton;
    UndoButton: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FontNameChange(Sender: TObject);
    procedure FontSizeChange(Sender: TObject);
    procedure ColorButtonClick(Sender: TObject);
    procedure BoldButtonClick(Sender: TObject);
    procedure ItalicButtonClick(Sender: TObject);
    procedure UnderlineButtonClick(Sender: TObject);
    procedure LeftAlignClick(Sender: TObject);
    procedure CenterAlignClick(Sender: TObject);
    procedure RightAlignClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SelectionChange(Sender :TObject);
    procedure BulletsButtonClick(Sender: TObject);
    procedure UndoButtonClick(Sender: TObject);
    procedure RightIndMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RightIndMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure RightIndMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FUpdating :Boolean;
    FDragOfs :Integer;
    FDragging :Boolean;
    function CurrText :TTextAttributes;
    procedure GetFontNames;
    procedure SetupRuler;
    procedure SetEditRect;
    procedure UpdateCursorPos;
    function FUpdating_SetUpdate :Boolean;
  public
    { Public declarations }
  end;

var
  KrediNotlarDlg: TKrediNotlarDlg;

implementation
 uses Utablo,PrjConst,LocOnFly;
{$R *.DFM}

const
  RulerAdj = 4 / 3;
  GutterWid = 6;

function EnumFontsProc(var LogFont :TLogFont; var TextMetric :TTextMetric;
  FontType :Integer; Data :Pointer) :Integer; stdcall;
begin
  TStrings(Data).Add(LogFont.lfFaceName);
  Result := 1;
end;
procedure TKrediNotlarDlg.SelectionChange(Sender :TObject);
begin
  with MemoKrediNotlar.Paragraph do
  try
    FUpdating := True;
    FirstInd.Left := Trunc(FirstIndent * RulerAdj) - 4 + GutterWid;
    LeftInd.Left := Trunc((LeftIndent + FirstIndent) * RulerAdj) - 4 + GutterWid;
    RightInd.Left := Ruler.ClientWidth - 6 - Trunc((RightIndent + GutterWid) * RulerAdj);
    BoldButton.Down := fsBold in MemoKrediNotlar.SelAttributes.Style;
    ItalicButton.Down := fsItalic in MemoKrediNotlar.SelAttributes.Style;
    UnderlineButton.Down := fsUnderline in MemoKrediNotlar.SelAttributes.Style;
    BulletsButton.Down := Boolean(Numbering);
    FontSize.Text := IntToStr(MemoKrediNotlar.SelAttributes.Size);
    FontName.Text := MemoKrediNotlar.SelAttributes.Name;
    case Ord(Alignment) of
      0 :LeftAlign.Down := True;
      1 :RightAlign.Down := True;
      2 :CenterAlign.Down := True;
    end;
    UpdateCursorPos;
  finally
    FUpdating := False;
  end;

end;
function TKrediNotlarDlg.FUpdating_SetUpdate :Boolean;
begin
  FUpdating_SetUpdate := FUpdating;
  { TODO -oDeveloper -cKrediNotlarDlg : Kredi notlar kapatıldı! }
//  if not FUpdating then
//    if Tablo.TabRehber.Active then
//      Tablo.TabRehber.Edit;
end;
procedure TKrediNotlarDlg.UnderlineButtonClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  if UnderlineButton.Down then
    CurrText.Style := CurrText.Style + [fsUnderline]
  else
    CurrText.Style := CurrText.Style - [fsUnderline];
end;

procedure TKrediNotlarDlg.UndoButtonClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  with MemoKrediNotlar do
    if HandleAllocated then SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TKrediNotlarDlg.UpdateCursorPos;
var
  CharPos :TPoint;
begin
  CharPos.Y := SendMessage(MemoKrediNotlar.Handle, EM_EXLINEFROMCHAR, 0,
    MemoKrediNotlar.SelStart);
  CharPos.X := (MemoKrediNotlar.SelStart -
    SendMessage(MemoKrediNotlar.Handle, EM_LINEINDEX, CharPos.Y, 0));
  Inc(CharPos.Y);
  Inc(CharPos.X);
end;

procedure TKrediNotlarDlg.GetFontNames;
var
  DC :HDC;
begin
  DC := GetDC(0);
  EnumFonts(DC, nil, @EnumFontsProc, Pointer(FontName.Items));
  ReleaseDC(0, DC);
  FontName.Sorted := True;
end;

procedure TKrediNotlarDlg.ItalicButtonClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  if ItalicButton.Down then
    CurrText.Style := CurrText.Style + [fsItalic]
  else
    CurrText.Style := CurrText.Style - [fsItalic];
end;

procedure TKrediNotlarDlg.LeftAlignClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  MemoKrediNotlar.Paragraph.Alignment := TAlignment(TControl(Sender).Tag);
end;

procedure TKrediNotlarDlg.RightAlignClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  MemoKrediNotlar.Paragraph.Alignment := TAlignment(TControl(Sender).Tag);
end;

procedure TKrediNotlarDlg.RightIndMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FDragOfs := (TLabel(Sender).Width div 2);
  TLabel(Sender).Left := TLabel(Sender).Left + X - FDragOfs;
  FDragging := True;

end;

procedure TKrediNotlarDlg.RightIndMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if FDragging then
    TLabel(Sender).Left := TLabel(Sender).Left + X - FDragOfs
end;

procedure TKrediNotlarDlg.RightIndMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FUpdating_SetUpdate then Exit;
  FDragging := False;
  MemoKrediNotlar.Paragraph.RightIndent := Trunc((Ruler.ClientWidth - RightInd.Left + FDragOfs - 2) / RulerAdj) - 2 * GutterWid;
  SelectionChange(Sender);
end;

procedure TKrediNotlarDlg.CenterAlignClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  MemoKrediNotlar.Paragraph.Alignment := TAlignment(TControl(Sender).Tag);
end;

procedure TKrediNotlarDlg.ColorButtonClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
   ColorDialog1.Color := CurrText.Color;
  if  ColorDialog1.Execute then
    CurrText.Color := ColorDialog1.Color;
  MemoKrediNotlar.SetFocus;
end;

function TKrediNotlarDlg.CurrText :TTextAttributes;
begin
  if MemoKrediNotlar.SelLength > 0 then
    Result := MemoKrediNotlar.SelAttributes
  else
    Result := MemoKrediNotlar.DefAttributes;
end;

procedure TKrediNotlarDlg.SetupRuler;
var
  I :Integer;
  S :string;
begin
  SetLength(S, 201);
  I := 1;
  while I < 200 do
  begin
    S[I] := #9;
    S[I + 1] := '|';
    Inc(I, 2);
  end;
  Ruler.Caption := S;
end;

procedure TKrediNotlarDlg.SetEditRect;
var
  R :TRect;
begin
  with MemoKrediNotlar do
  begin
    R := Rect(GutterWid, 0, ClientWidth - GutterWid, ClientHeight);
    SendMessage(Handle, EM_SETRECT, 0, Longint(@R));
  end;
end;


procedure TKrediNotlarDlg.BitBtn1Click(Sender: TObject);
begin
//   Tablo.TabRehber.Post;

end;

procedure TKrediNotlarDlg.BitBtn2Click(Sender: TObject);
begin
{   if Tablo.TabRehber.State in [dsEdit, dsInsert] then
    if MessageDlg('Değişiklik yapıldı kaydetmek ister misiniz',mtConfirmation,mbYesNoCancel,0 ) = mryes
    then
      Tablo.TabRehber.Post
    ELSE
      Tablo.TabRehber.Cancel;
       Self.Close; }
end;

procedure TKrediNotlarDlg.BoldButtonClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  if BoldButton.Down then
    CurrText.Style := CurrText.Style + [fsBold]
  else
    CurrText.Style := CurrText.Style - [fsBold];
end;

procedure TKrediNotlarDlg.BulletsButtonClick(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  MemoKrediNotlar.Paragraph.Numbering := TNumberingStyle(BulletsButton.Down);
end;

procedure TKrediNotlarDlg.FontNameChange(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  CurrText.Name := FontName.Items[FontName.ItemIndex];
end;

procedure TKrediNotlarDlg.FontSizeChange(Sender: TObject);
begin
  if FUpdating_SetUpdate then Exit;
  CurrText.Size := StrToInt(FontSize.Text);
end;

procedure TKrediNotlarDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  GetFontNames;
  SetupRuler;
  SelectionChange(Self);
end;

end.
