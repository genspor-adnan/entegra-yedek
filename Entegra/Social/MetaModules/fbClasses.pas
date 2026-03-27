unit fbClasses;

interface

uses
 System.Classes, System.Generics.Collections;

type
  TfbItemType = (fbMessage, fmComment, fbLike, fbLeadForm, fbLeadItem, fbLeadData,fbApplicationForm, fbConversation);

  TfbItem = class
    private
    fItemType: TfbItemType;
    fText: string;
    fItemID: string;
    fItemUser: string;
    fParentItem: TfbItem;
    fOwnerItemName: string;
    fUpdateTime: string;
    fPlatform: string;
    fLink: string;
    fLocale: string;
    fStatus: boolean;
    published
      /// TFbItemType
      ///  fbMessage : Mesaj iletisi
      ///  fbComment : Yorum içeriði
      ///  fbLike    : Beðeni
      property ItemType : TfbItemType read fItemType write fItemType;
      property Text : string read fText write fText;
      property ItemId : string read fItemID write fItemId;
      property Link : string read fLink write fLink;
      property ItemUser : string read fItemUser write fItemUser;
      property OwnerItemName : string read fOwnerItemName write fOwnerItemName;
      property ParentItem : TfbItem  read fParentItem write fParentItem;
      property UpdateTime : string read fUpdateTime write fUpdateTime;
      // MESSENGER | INSTAGRAM
      property &Platform : string read fPlatform write fPlatform;
      property Status : boolean read fStatus write fStatus;
      property Locale : string read fLocale write fLocale;
  end;

  TFbItems = class
    private
      fItems : TList<TfbItem>;

    procedure SetItem(Index: integer; const Value: TFbItem);
    function GetItem(Index: integer): TFbItem;
    function GetCount: integer;

    public
      constructor Create;
      destructor Destroy; override;
      property Item[Index :integer]  : TFbItem read GetItem write SetItem; default;
      property Count : integer read GetCount;

      function Add : TfbItem; overload;
      function Add(_NewItem : TfbItem) : integer; overload;
      function IndexOf( _ItemId : string) : integer;
      procedure Clear;
     published
      property Items : TList<TfbItem> read FItems write fItems;
  end;

implementation

{ TFbItems }

function TFbItems.Add: TfbItem;
begin
  Result := TfbItem.Create;
  FItems.Add(Result);
end;

function TFbItems.Add(_NewItem: TfbItem): integer;
begin
    Result := FItems.Add(_NewItem);
end;

procedure TFbItems.Clear;
begin
  FITems.Clear;
end;

constructor TFbItems.Create;
begin
  FItems := TList<TfbItem>.Create;
end;

destructor TFbItems.Destroy;
begin
  while FItems.Count>0 do
  begin
      FItems.Delete(0);
  end;
  FItems.Clear;
  FItems.Free;

  inherited;
end;




function TFbItems.GetCount: integer;
begin
   Result := FItems.Count;
end;

function TFbItems.GetItem(Index: integer): TFbItem;
begin
  Result := FItems[index];
end;

function TFbItems.IndexOf(_ItemId: string): integer;
var
 i : integer;
begin
 Result := -1;
 for i := 0 to FItems.Count-1 do
    if FItems[i].fItemID=_ItemId then
     Exit(i);
end;

procedure TFbItems.SetItem(Index: integer; const Value: TFbItem);
begin
  FItems[index] := Value;
end;

end.
