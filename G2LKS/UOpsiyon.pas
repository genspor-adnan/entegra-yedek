unit UOpsiyon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls;

{$I options.inc}

type
  POptionFrameRecord = ^TOptionFrameRecord;

  TOpsiyonDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    menuTreeView: TTreeView;
    Splitter1: TSplitter;
    contentScrollBox: TScrollBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure menuTreeViewChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: Boolean);
  private
    { Private declarations }
    m_Root: TTreeNode;
    m_CurrentOption: POptionFrameRecord;
    procedure LoadOptions;
    procedure SendSaveSettingMessage;
  public
    { Public declarations }

  end;

  TOptionFrameClass = class of TFrame;

  TOptionFrameRecord = record
    _class: TOptionFrameClass;
    _path: string[220];
    _object: TFrame;
    _pageIndex: Integer;
  end;

function FindOptionInstanceByClass(AClass: TOptionFrameClass): TFrame;

var
  OpsiyonDlg: TOpsiyonDlg;

procedure RegisterOption(AIndex: Integer; optionPath: string;
  optionClass: TOptionFrameClass);

implementation

uses UTablo;

{$R *.DFM}

var
  OptionsClasses: TList;

function IndexOfString(source: string; stringList: array of string): Integer;
var
  i: integer;
begin
  Result := -1;
  for i := Low(stringList) to High(stringList) do
    if (source = stringList[i]) then
    begin
      Result := i;
      break;
    end;
end;

function FindOptionInstanceByClass(AClass: TOptionFrameClass): TFrame;
var
  i: integer;
  rec: POptionFrameRecord;
begin
  Result := nil;
  for i := 0 to OptionsClasses.Count - 1 do
  begin
    rec := OptionsClasses[i];
    if (rec^._class = AClass) then
    begin
      Result := rec^._object;
    end;
  end;
end;

procedure TOpsiyonDlg.BitBtn1Click(Sender: TObject);
begin
  SendSaveSettingMessage;
  ModalResult := mrOK;
end;

procedure TOpsiyonDlg.FormCreate(Sender: TObject);
begin
  m_Root := menuTreeView.Items.Add(nil, 'Gentegrasyon');
  m_CurrentOption := nil;
  LoadOptions;
  m_Root.Expand(true);
end;

procedure TOpsiyonDlg.BitBtn2Click(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure RegisterOption(AIndex: Integer; optionPath: string;
  optionClass: TOptionFrameClass);
var
  rec: POptionFrameRecord;
begin
  New(rec);
  rec._class := optionClass;
  rec._path := optionPath;
  rec._pageIndex := AIndex;
  OptionsClasses.Add(rec);
end;

procedure RemoveAllOptions;
var
  rec: POptionFrameRecord;
begin
  while OptionsClasses.Count > 0 do
  begin
    rec := OptionsClasses.Extract(OptionsClasses[0]);
    { we don't need to free the object.
      because we added that object to contentScrollBox object.
      contentScrollBox is responsible to free this object
      if (Assigned(rec._object)) then
      begin
      rec._object.Free;
      rec._object := nil;
      end; }
    Dispose(rec);
  end;
end;

procedure SplitIntoNodes(path: string; nodes: TStrings);
begin
  nodes.Clear;
  while (Pos('/', path) > 0) do
  begin
    nodes.Add(Copy(path, 1, Pos('/', path) - 1));
    Delete(path, 1, Pos('/', path));
  end;
  if (path <> '') then
    nodes.Add(path);
end;

function ExtractNodeFromPath(var path: string): string;
begin
  if (Pos('/', path) > 0) then
  begin
    Result := Copy(path, 1, Pos('/', path) - 1);
    Delete(path, 1, Pos('/', path));
  end
  else
  begin
    Result := path;
    path := '';
  end;
end;

function FindChild(Root: TTreeNode; text: string): TTreeNode;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to Root.Count - 1 do
    if (AnsiUpperCase(Root.Item[i].text) = AnsiUpperCase(text)) then
    begin
      Result := Root.Item[i];
      break;
    end;
end;

function AddPathToTree(path: string; rootNode: TTreeNode): TTreeNode;
var
  Node: string;
  child: TTreeNode;
begin
  Node := ExtractNodeFromPath(path);
  if (Length(Node) > 0) then
  begin
    child := FindChild(rootNode, Node);
    if (Assigned(child)) then
    begin
      Result := AddPathToTree(path, child);
    end
    else
    begin
      child := rootNode.Owner.AddChildFirst(rootNode, Node);
      Result := AddPathToTree(path, child);
    end;
  end
  else
    Result := rootNode;
end;

function SortOptionPages(Item1, Item2: Pointer): Integer;
var
  P1, P2: POptionFrameRecord;
begin
  P1 := Item1;
  P2 := Item2;
  if (P1^._pageIndex > P2^._pageIndex) then
    Result := 1
  else if (P1^._pageIndex < P2^._pageIndex) then
    Result := -1
  else if (P1^._pageIndex = P2^._pageIndex) then
    Result := 0;
end;

procedure TOpsiyonDlg.LoadOptions;
var
  rec: POptionFrameRecord;
  i: integer;
  nodes: TStringList;
  j: integer;
  node1: TTreeNode;
  node2: TTreeNode;
  path: string;
begin
  nodes := TStringList.Create;
  try
    OptionsClasses.Sort(@SortOptionPages);
    for i := OptionsClasses.Count - 1 downto 0 do
    begin
      rec := OptionsClasses[i];
      if (Assigned(rec)) then
      begin
        SplitIntoNodes(rec._path, nodes);
        node1 := AddPathToTree(rec._path, m_Root);
        if (Assigned(node1)) then
        begin
          rec._object := TFrame(rec._class.NewInstance);
          try
            rec._object.Create(nil);
            rec._object.Parent := contentScrollBox;
            rec._object.Visible := False;
            node1.Data := rec;
          except
            rec._object := nil;
            raise;
          end;
        end;
      end;
    end;
  finally
    nodes.Free;
  end;
end;

procedure TOpsiyonDlg.menuTreeViewChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: Boolean);
begin
  if (Node.Data = nil) then
    Exit;
  if (Assigned(m_CurrentOption)) then
  begin
    // Send Hide Message
    SendMessage(m_CurrentOption._object.Handle, WM_HIDEOPTION, 0, 0);
    m_CurrentOption._object.Visible := False;
  end;
  m_CurrentOption := Node.Data;
  // Send Show Message
  SendMessage(m_CurrentOption._object.Handle, WM_SHOWOPTION, 0, 0);
  m_CurrentOption._object.Visible := true;
end;

procedure TOpsiyonDlg.SendSaveSettingMessage;
var
  i: integer;
  rec: POptionFrameRecord;
begin
  for i := 0 to OptionsClasses.Count - 1 do
  begin
    rec := OptionsClasses[i];
    SendMessage(rec._object.Handle, WM_SAVECONTENT, 0, 0);
  end;
end;

initialization

OptionsClasses := TList.Create;

finalization

RemoveAllOptions;
OptionsClasses.Free;

end.
