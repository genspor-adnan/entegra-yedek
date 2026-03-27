unit UCodingWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,SynEditHighlighter, SynHighlighterPas,
  ImgList, Menus, SynEdit, ToolWin, JvDockTree,
  JvDockControlForm, JvDockVIDStyle, JvDockVSNetStyle, JvComponentBase,
  SynEditMiscClasses, SynEditSearch;

type
  TCodingWindow = class(TForm)
    sourceEditor: TSynEdit;
    SynPasSyn1: TSynPasSyn;
    mainToolBar: TToolBar;
    StdImageList: TImageList;
    kaydetToolButton: TToolButton;
    convertToStringToolButton: TToolButton;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    compileToolButton: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure kaydetToolButtonClick(Sender: TObject);
    procedure sourceEditorChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure convertToStringToolButtonClick(Sender: TObject);
    procedure compileToolButtonClick(Sender: TObject);
  private
    FModified: Boolean;
    procedure SetModified(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    property Modified : Boolean read FModified write SetModified;
  end;

var
  CodingWindow: TCodingWindow;

implementation
uses
  ULKSTransformator;

{$R *.dfm}

procedure TCodingWindow.FormCreate(Sender: TObject);
begin
  if (FileExists(ExtractFilePath(ParamStr(0)) + 'trans.kod')) then
    sourceEditor.Lines.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'trans.kod');
  Modified := False;
end;

procedure TCodingWindow.kaydetToolButtonClick(Sender: TObject);
begin
  sourceEditor.Lines.SaveToFile(ExtractFilePath(ParamStr(0)) + 'trans.kod');
  Modified := False;
end;

procedure TCodingWindow.SetModified(const Value: Boolean);
begin
  FModified := Value;
  kaydetToolButton.Enabled := Value;
end;

procedure TCodingWindow.sourceEditorChange(Sender: TObject);
begin
  Modified := True;
end;

procedure TCodingWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((ssCtrl in Shift) and (Key = Ord('S'))) then
    kaydetToolButton.Click;
end;

procedure TCodingWindow.convertToStringToolButtonClick(Sender: TObject);
var
  src: TStringList;
  i  : integer;
  s  : string;
  b  : string;
  bsay: Integer;
begin
  if sourceEditor.SelLength = 0 then Exit;
  src := TStringList.Create;
  try
    src.Text := sourceEditor.SelText;
    for i := 0 to src.Count - 1 do
      begin
        s := TrimRight(src[i]);
        b := '';
        for bsay := 1 to Length(s) do
          if (s[bsay] = ' ') then
            b := b + ' '
          else
            break;
        s := Trim(s);
        src[i] := b + ''''+StringReplace(s,'''','''''',[rfReplaceAll])+' '' +';
      end;
    sourceEditor.SelText := src.Text;
  finally
    src.Free;
  end;          
end;

procedure TCodingWindow.compileToolButtonClick(Sender: TObject);
var
  lks : TLksTransformator;
  mesaj : string;
  i     : integer;
begin
  lks := TLksTransformator.Create(sourceEditor.Text);
  try
    if not lks.Engine.Compile then
      begin
        mesaj := '';
        for i := 0 to lks.Engine.CompilerMessageCount - 1 do
          mesaj := mesaj + lks.Engine.CompilerErrorToStr(I);
         MessageDlg(mesaj,mtError,[mbOK],0);
      end;
  finally
    lks.Free;
  end;
end;

end.

