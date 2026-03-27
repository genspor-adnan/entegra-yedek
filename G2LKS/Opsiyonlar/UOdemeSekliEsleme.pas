unit UOdemeSekliEsleme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ComCtrls, StdCtrls,ADODB,DB,UTablo, ExtCtrls;
const
  WM_SAVECONTENT = WM_USER + 456;

type

  TEditingMode = (emNormal,emInsertNew,emEdit);

  TodemeSekliEslemeForm = class(TFrame)
    eslemeListView: TListView;
    Label1: TLabel;
    ekleButton: TButton;
    silButton: TButton;
    degistirButton: TButton;
    Label2: TLabel;
    Label3: TLabel;
    logoOdemeTipiComboBox: TComboBox;
    genotipOdemeTipiComboBox: TComboBox;
    logoHesapKoduEdit: TEdit;
    Label4: TLabel;
    Bevel1: TBevel;
    kaydetButton: TButton;
    iptalButton: TButton;
    GroupBox1: TGroupBox;
    procedure ekleButtonClick(Sender: TObject);
    procedure silButtonClick(Sender: TObject);
    procedure kaydetButtonClick(Sender: TObject);
    procedure iptalButtonClick(Sender: TObject);
    procedure degistirButtonClick(Sender: TObject);
    procedure eslemeListViewSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure eslemeListViewDblClick(Sender: TObject);
  private
    { Private declarations }
    FModified : Boolean;
    FEditingMode: TEditingMode;
    procedure LoadFromDatabase;
    procedure AutomaticCreation;
    procedure SaveToDatabase;
    procedure SaveContentMsg(var Msg: TMessage);message WM_SAVECONTENT;
    procedure SetEditingMode(const Value: TEditingMode);
    procedure AddNew;
    function IsInList(odemeTipi : string): Boolean;
    procedure EnableDisableAddButton;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy;override;
    property EditingMode : TEditingMode read FEditingMode write SetEditingMode;
  end;

implementation
uses
  UOpsiyon;

{$R *.dfm}

{ TodemeSekliEslemeForm }


function _query_exec(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant) : TADOQuery;
var
  i     : Integer;
begin
  if ((Length(paramNames) > 0)) then
    begin
      for i := Low(paramNames) to High(paramNames) do
        begin
          sql := StringReplace(sql,paramNames[i],params[i],[rfReplaceAll]);
        end;
    end;
  Result := TADOQuery.Create(nil);
  Result.Connection := cnn;
  Result.SQL.Text := sql;
end;

procedure FillFromDatabase(sql : string;list : TStrings);
var
  temp : TADOQuery;
begin
  temp := _query_exec(Tablo.cnn,sql,[],[]);
  try
    temp.Open;
    list.Clear;
    while not temp.Eof do
      begin
        list.Add(temp.Fields[0].AsString);
        temp.Next;
      end;
  finally
    temp.Free;
  end;
end;

procedure TodemeSekliEslemeForm.AutomaticCreation;
var
  temp  : TStringList;
  item  : TListItem;
begin
  temp := TStringList.Create;
  try
    eslemeListView.Items.Clear;
    FillFromDatabase('SELECT ANAHTAR FROM GENOTIPINI WHERE ' +
      'BOLUM=''TAHSILAT_TURU''',temp);
    while temp.Count > 0 do
      begin
        item := eslemeListView.Items.Add;
        item.Caption := temp[0];
        item.SubItems.Add('(E�leme)');
        item.SubItems.Add('');
        temp.Delete(0);
      end;
  finally
    temp.Free;
  end;
  SaveToDatabase;
end;

constructor TodemeSekliEslemeForm.Create(AOwner: TComponent);
begin
  inherited;       
  FillFromDatabase('SELECT ANAHTAR FROM GENOTIPINI WHERE ' +
      'BOLUM=''TAHSILAT_TURU''',genotipOdemeTipiComboBox.Items);
  LoadFromDatabase;
  EditingMode := emNormal;
end;

destructor TodemeSekliEslemeForm.Destroy;
begin

  inherited;
end;

procedure ParseDelimitedString(S: string;list: TStrings);
var
  i : integer;
begin
  list.Clear;
  while(Pos(',',S) > 0) do
    begin
      list.Add(Copy(S,1,Pos(',',S) - 1));
      Delete(S,1,Pos(',',S));
    end;
  if (S <> '') then
    list.Add(S); 
end;

procedure TodemeSekliEslemeForm.LoadFromDatabase;
var
  temp    : TADOQuery;
  params  : TStringList;
  item    : TListItem;
  i       : integer;
begin
  temp := _query_exec(Tablo.cnn,'SELECT DEGER FROM GENOTIPINI ' +
    'WHERE (BOLUM = ''G2LKS'') and (ANAHTAR=''E�leme'')ORDER BY SIRANO',[],[]);
  params := TStringList.Create;
  try
    temp.Open;
    while not temp.Eof do
      begin
        ParseDelimitedString(temp.FieldByName('DEGER').AsString,params);
        if (params.Count < 3) then
          params.Add('');
        item := eslemeListView.Items.Add;
        for i := 0 to params.Count - 1 do
          begin
            if (i = 0) then
              begin
                item.Caption := params[i];
              end
            else
              begin
                item.SubItems.Add(params[i]); 
              end;
          end;
        temp.Next;
      end;
  finally
    temp.Free;
    params.Free;
  end;
  if (eslemeListView.Items.Count = 0) then
    AutomaticCreation;
  FModified := False;
end;

function ItemToDelimitedString(Item: TListItem): string;
var
  i: Integer;
begin
  Result := Item.Caption + ',' + Item.SubItems[0] + ',' + Item.SubItems[1];
//  for i := 0 to Item.SubItems.Count - 1 do
//    Result := Result + ',' + Item.SubItems[i];
end;

procedure TodemeSekliEslemeForm.SaveToDatabase;
var
  temp : TADOQuery;
  i    : integer;
begin
  Tablo.CNN.ExecSQL('DELETE FROM GENOTIPINI WHERE (BOLUM=''G2LKS'')' +
    ' and (ANAHTAR = ''E�leme'')');
  temp := _query_exec(Tablo.cnn,'SELECT TOP 1 * FROM GENOTIPINI',[],[]);
  try
    temp.Open;
    for i := 0 to eslemeListView.Items.Count - 1 do
      begin
        with temp do
          begin
            Append;
              FieldByName('BOLUM').AsString := 'G2LKS';
              FieldByName('ANAHTAR').AsString := 'E�leme';
              FieldByName('DEGER').AsString := ItemToDelimitedString(
                eslemeListView.Items[i]);
            Post;
          end;
      end;
  finally
    temp.Free;
  end;
  FModified := False;
end;

procedure TodemeSekliEslemeForm.ekleButtonClick(Sender: TObject);
begin
  AddNew;
end;

procedure TodemeSekliEslemeForm.silButtonClick(Sender: TObject);
begin
  if (MessageDlg('Se�ili ��eyi silmek istiyor musunuz ?',mtConfirmation,
    [mbYes,mbNo],0) = mrNo) then Exit;
  eslemeListView.Selected.Delete;
  FModified := True;
  EnableDisableAddButton;
end;

procedure TodemeSekliEslemeForm.SetEditingMode(const Value: TEditingMode);
begin
  FEditingMode := Value;
  case Value of
    emNormal:
      begin
        Height := 228;
        EnableDisableAddButton;
        degistirButton.Enabled := eslemeListView.SelCount > 0;
        silButton.Enabled := degistirButton.Enabled;
        eslemeListView.Enabled := True;
      end;
    emInsertNew,
    emEdit :
      begin
        Height := 350;
        ekleButton.Enabled := False;
        degistirButton.Enabled := False;
        silButton.Enabled := False;
        eslemeListView.Enabled := False;
      end;
  end;
end;

procedure TodemeSekliEslemeForm.AddNew;
begin
  genotipOdemeTipiComboBox.ItemIndex := -1;
  logoOdemeTipiComboBox.ItemIndex := 0;
  logoHesapKoduEdit.Text := '';
  EditingMode := emInsertNew;
end;

procedure TodemeSekliEslemeForm.kaydetButtonClick(Sender: TObject);
var
  item : TListItem;
begin
  if ((genotipOdemeTipiComboBox.ItemIndex = -1) or
     (logoOdemeTipiComboBox.ItemIndex = -1)) then
    begin
      MessageDlg('GenoTIP �deme tipi ve Logo �deme tipi se�ili olmal�',mtError,
        [mbOK],0);
      Exit;
    end;
  if ((EditingMode = emInsertNew) and (IsInList(genotipOdemeTipiComboBox.Text))) then
    begin
      MessageDlg('Bu �deme tipi zaten kay�tl� : ' + genotipOdemeTipiComboBox.Text,
        mtError,[mbOK],0);
      Exit;
    end;
  case EditingMode of
    emInsertNew:
      begin
        item := eslemeListView.Items.Add;
        item.Caption := genotipOdemeTipiComboBox.Text;
        item.SubItems.Add(logoOdemeTipiComboBox.Text);
        item.SubItems.Add(logoHesapKoduEdit.Text);
      end;
    emEdit:
      begin
        item := eslemeListView.Selected;
        item.Caption := genotipOdemeTipiComboBox.Text;
        item.SubItems[0] := logoOdemeTipiComboBox.Text;
        item.SubItems[1] := logoHesapKoduEdit.Text;
      end;
    end;
  EditingMode := emNormal;
  FModified := True;
  EnableDisableAddButton;
end;

function TodemeSekliEslemeForm.IsInList(odemeTipi: string): Boolean;
var
  i : integer;
begin
  Result := False;
  for i := 0 to eslemeListView.Items.Count - 1 do
    begin
      if (eslemeListView.Items[i].Caption = odemeTipi) then
        begin
          Result := True;
          Exit;
        end;
    end;
end;

procedure TodemeSekliEslemeForm.iptalButtonClick(Sender: TObject);
begin
  EditingMode := emNormal;
end;

procedure TodemeSekliEslemeForm.degistirButtonClick(Sender: TObject);
var
  item : TListItem;
begin
  item := eslemeListView.Selected;
  genotipOdemeTipiComboBox.ItemIndex :=
    genotipOdemeTipiComboBox.Items.IndexOf(item.Caption);
  logoOdemeTipiComboBox.ItemIndex :=
    logoOdemeTipiComboBox.Items.IndexOf(item.SubItems[0]);
  logoHesapKoduEdit.Text := item.SubItems[1];
  EditingMode := emEdit;
end;

procedure TodemeSekliEslemeForm.eslemeListViewSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  degistirButton.Enabled := (eslemeListView.Selected <> nil);
  silButton.Enabled := degistirButton.Enabled;
end;

procedure TodemeSekliEslemeForm.EnableDisableAddButton;
var
  i       : integer;
  enable  : boolean;
begin
  enable := false;
  for i := 0 to genotipOdemeTipiComboBox.Items.Count - 1 do
    if (not IsInList(genotipOdemeTipiComboBox.Items[i])) then
      begin
        enable := true;
        break;
      end;
  ekleButton.Enabled := enable;
end;

procedure TodemeSekliEslemeForm.SaveContentMsg(var Msg: TMessage);
begin
  SaveToDatabase;
end;

procedure TodemeSekliEslemeForm.eslemeListViewDblClick(Sender: TObject);
begin
  if (Assigned(eslemeListView.Selected) and
     (degistirButton.Enabled)) then
     degistirButton.Click;
end;

initialization
  RegisterOption('E�le�tirme/�deme Tipleri',TodemeSekliEslemeForm);

end.

