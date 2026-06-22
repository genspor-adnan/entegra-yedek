unit UCxUtils;

(*
  cx component setine ait ortak kullanılan objeler ve procedure leri içerir
  Hakan Arslantaş
  24-01-2008
*)

interface

uses
  SysUtils, Classes, Types, cxGrid, cxGridCustomPopupMenu, cxGridPopupMenu,
  Controls, Forms, Menus, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxButtonEdit, cxDropDownEdit, Variants, cxCalendar, cxPropertiesStore,
  cxCheckBox, cxContainer, cxTextEdit, cxMaskEdit, cxDBEdit,Dialogs,
  cxGridExportLink;

type

  TGridMouseUp = procedure(Sender :TObject;
      Button :TMouseButton; Shift :TShiftState; X, Y :Integer) of object;

  TcxUtils = class(TDataModule)
    cxBuildinMenu :TcxGridPopupMenu;
    procedure GridMouseUp (Sender :TObject;
      Button :TMouseButton; Shift :TShiftState; X, Y :Integer);
    procedure cxBuildinMenuPopup(ASenderMenu :TComponent;
      AHitTest :TcxCustomGridHitTest; X, Y :Integer;
      var AllowPopup :Boolean);
    procedure ApplyDefaultValues(sender : TObject);
    procedure ExportToExcel(sender : TObject);
  private
    { Private declarations }
    FSaveGridPopUp : TPopupMenu;
  public
    { Public declarations }
    procedure cxGridLoadFromRegistry(cxGrid :TcxGrid; AsDefaults :Boolean = False);
    procedure cxGridSaveToRegistry(cxGrid :TcxGrid; AsDefaults :Boolean = False);
    function FindGridFormName(cxGrid :TcxGrid) :string;
    procedure SetcxGridPopupMenu(cxGrid :TCxGrid; DefaultMenus :TPopupMenu = nil; SaveRegDefaultProp : Boolean = False);
  end;

var
  cxUtils :TcxUtils;


implementation

{$R *.dfm}
var
  USaveGridEvent : TGridMouseUp;
  USavecxGrid : TCxGrid;

function TcxUtils.FindGridFormName(cxGrid :TcxGrid) :string;
var
  prnt :TWinControl;
begin
  prnt := cxGrid.Parent;
  while Assigned(prnt.Parent) do
    prnt := prnt.Parent;
  Result := prnt.Name;
end;

procedure TcxUtils.cxGridSaveToRegistry(cxGrid :TcxGrid; AsDefaults :Boolean = False);
var
  AStoreKey, ASaveViewName :string;
  AOptions :TcxGridStorageOptions;
  sl :TStringList;
  FormName :string;
  xi :Integer;
begin
  AOptions := [gsoUseFilter];
  FormName := FindGridFormName(cxGrid);
  for xi := 0 to cxGrid.ViewCount - 1 do
  begin
    AStoreKey := FormName + '_' + cxGrid.Name + '_' + cxGrid.Views[xi].Name;
    if AsDefaults then AStoreKey := AStoreKey + '_Defaults';
    cxGrid.Views[xi].StoreToRegistry(AStoreKey, False, AOptions, '')
  end;
end;

procedure TcxUtils.cxGridLoadFromRegistry(cxGrid :TcxGrid; AsDefaults :Boolean = False);
var
  AStoreKey, ASaveViewName :string;
  AOptions :TcxGridStorageOptions;
  sl :TStringList;
  FormName :string;
  xi :Integer;
begin
  AOptions := [gsoUseFilter];
  FormName := FindGridFormName(cxGrid);
  for xi := 0 to cxGrid.ViewCount - 1 do
  begin
    AStoreKey := FormName + '_' + cxGrid.Name + '_' + cxGrid.Views[xi].Name;
    if AsDefaults then AStoreKey := AStoreKey + '_Defaults';
    cxGrid.Views[xi].RestoreFromRegistry(AStoreKey, False, False, AOptions, '');


  end;
end;

procedure TcxUtils.SetcxGridPopupMenu(cxGrid :TCxGrid; DefaultMenus :TPopupMenu = nil; SaveRegDefaultProp : Boolean = False);
var
  MnCnt :Integer;
  xi, jn :Integer;
  JumpedPopupMenu :array[0..99] of TMenuItem;
  LastAdded : TMenuItem;

  procedure AddMenu(menuItem :TMenuItem; InsertIndex :Integer = -1; ParentItem :TMenuItem = nil);
  begin
    if not Assigned(ParentItem) then
      ParentItem := TPopupMenu(cxUtils.cxBuildinMenu.BuiltInPopupMenus[0].PopupMenu).Items;
    if InsertIndex > -1 then
      ParentItem.Insert(InsertIndex, menuItem)
    else
      ParentItem.Add(menuItem);
  end;

  function AddBuiltinPopupMenus(MenuCaption :string; OnClickEvent :TNotifyEvent = nil; InsertIndex :Integer = -1; ParentMenu :TMenuItem = nil) :TMenuItem;
  begin
    Result := TMenuItem.Create(nil); //cxBuildinMenu.BuiltInPopupMenus[0].PopupMenu);
    Result.Caption := MenuCaption;
    Result.OnClick := OnClickEvent;

    AddMenu(Result, InsertIndex, ParentMenu);
  end;

  procedure CloneMenu(CopyMenu :TPopupMenu);
  var
    MenuItemIndex :Integer;
    JumpedMenuIndex :Integer;
    MenuItem :TMenuItem;
    ParentMenu :TMenuItem;
    yi : Integer;

    procedure AddJumpMenu(Menu :TMenuItem);
    begin
      Inc(JumpedMenuIndex);
      JumpedPopupMenu[JumpedMenuIndex] := Menu;
      MenuItemIndex := 0;
    end;

    function GetNextMenu :TMenuItem;
    var siplingCount : Integer;
        MnItem : TMenuItem;
    begin
      Result := nil;
      siplingCount := 0;

      if (JumpedMenuIndex >= 0) then
      begin
        if (MenuItemIndex < JumpedPopupMenu[JumpedMenuIndex].Count) then
          Result := JumpedPopupMenu[JumpedMenuIndex].Items[MenuItemIndex];
        while not assigned(Result) and (JumpedMenuIndex >= 0) do
        begin
          ParentMenu := nil;
          if (JumpedMenuIndex = 0) then
          begin
            siplingCount := CopyMenu.items.Count;
            MenuItemIndex := CopyMenu.items.IndexOf(JumpedPopupMenu[JumpedMenuIndex]);
            Result := CopyMenu.items[MenuItemIndex + 1];
          end
          else
          begin
            siplingCount := JumpedPopupMenu[JumpedMenuIndex].Parent.Count;
            MenuItemIndex := JumpedPopupMenu[JumpedMenuIndex].Parent.IndexOf(JumpedPopupMenu[JumpedMenuIndex]);
            Result := JumpedPopupMenu[JumpedMenuIndex].Parent.Items[MenuItemIndex + 1];
            if JumpedMenuIndex > 1 then
              ParentMenu := JumpedPopupMenu[JumpedMenuIndex - 1];
          end;

          dec(JumpedMenuIndex);
          inc(MenuItemIndex);
        end;
      end
      else if (MenuItemIndex < CopyMenu.Items.Count) then
      begin
        Result := CopyMenu.Items[MenuItemIndex];
        ParentMenu := nil;
      end;

      if Assigned(Result) then
        Inc(MenuItemIndex);
    end;

    Function GetCurrentJumpedMenu : TMenuItem;
    begin
      Result := nil;
      if Assigned(JumpedPopupMenu[JumpedMenuIndex]) then
         Result := JumpedPopupMenu[JumpedMenuIndex];
    end;

  begin
    MenuItem := nil;
    JumpedMenuIndex := -1;
    ParentMenu := nil;
    for yi := -1 to 99 do JumpedPopupMenu[yi] := nil;
    MenuItemIndex := 1;
    MenuItem := CopyMenu.Items[0];
    while Assigned(MenuItem) do
    begin
      LastAdded := AddBuiltinPopupMenus(MenuItem.Caption, MenuItem.OnClick, -1, ParentMenu);

      if MenuItem.Count > 0 then
      begin
        AddJumpMenu(MenuItem);
        ParentMenu := LastAdded;
      end;

      MenuItem := GetNextMenu;
    end;
  end;

  procedure AddAdditionalMenus;
  begin
    AddBuiltinPopupMenus('Ön değerlere dön', ApplyDefaultValues);
    AddBuiltinPopupMenus('Excel''e Aktar', ExportToExcel);
  end;

begin
  cxBuildinMenu.Grid := cxGrid;
  USavecxGrid := cxGrid;

  if Assigned(cxGrid.PopupMenu) then
  begin
    DefaultMenus := TPopupMenu(cxGrid.PopupMenu);
    FSaveGridPopUp := DefaultMenus;
    @USaveGridEvent := @cxGrid.Levels[0].GridView.OnMouseUp;
    cxGrid.Levels[0].GridView.OnMouseUp := GridMouseUp;
    cxGrid.PopupMenu := nil;
  end;

  if not Assigned(DefaultMenus) or (DefaultMenus.Items.Count = 0) then
    Exit;

  AddBuiltinPopupMenus('-', nil);
  AddAdditionalMenus;
  AddBuiltinPopupMenus('-', nil);
  CloneMenu(DefaultMenus);
  if SaveRegDefaultProp then
    cxGridSaveToRegistry(cxGrid, true);
end;

procedure TcxUtils.cxBuildinMenuPopup(ASenderMenu :TComponent;
  AHitTest :TcxCustomGridHitTest; X, Y :Integer; var AllowPopup :Boolean);
begin
  if (AHitTest.HitTestCode = htGridBase) and Assigned(FSaveGridPopUp) then
    FSaveGridPopUp.Popup(x, y);
end;

procedure TcxUtils.GridMouseUp(Sender :TObject; Button :TMouseButton; Shift :TShiftState; X, Y :Integer);
var
  AMousePos: TPoint;
  AHitTest : TcxCustomGridHitTest;
  AHitType : TcxGridViewHitType;
begin
  USaveGridEvent(sender, button, shift, x, y);

  if (Button <> mbRight) then
    Exit;
  AMousePos := Mouse.CursorPos;

  {AMousePos := cxBuildinMenu.Grid.ScreenToClient(AMousePos);
  AMousePos := cxBuildinMenu.Grid.ScreenToClient(AMousePos);
  AMousePos.X := X + cxBuildinMenu.Grid.Left;
  AMousePos.Y := Y + cxBuildinMenu.Grid.Top;
  }
//  AMousePos := cxBuildinMenu.Grid.ScreenToClient(AMousePos);
  AHitTest := cxBuildinMenu.Grid.ViewInfo.GetHitTest(X, Y);
  AHitType := GetHitTypeByHitCode(AHitTest.HitTestCode);

  case AHitType of
    {
    gvhtGridNone, gvhtGridTab, gvhtNone, gvhtTab, gvhtCell,
    gvhtExpandButton, gvhtRecord, gvhtNavigator, gvhtPreview, gvhtColumnHeader,
    gvhtColumnHeaderFilterButton, gvhtFilter, gvhtFooter, gvhtFooterCell,
    gvhtGroupFooter, gvhtGroupFooterCell, gvhtGroupByBox, gvhtIndicator,
    gvhtRowIndicator, gvhtRowLevelIndent, gvhtBand, gvhtBandHeader,
  	gvhtRowCaption, gvhtSeparator
    }
    gvhtNone : FSaveGridPopUp.Popup(AMousePos.x, AMousePos.y);
  end;
end;

procedure TcxUtils.ApplyDefaultValues(sender: TObject);
begin
  cxGridLoadFromRegistry(cxBuildinMenu.Grid, true);
end;

procedure TcxUtils.ExportToExcel(sender : TObject);
var Dizin : String;
    SaveDialog : TSaveDialog;
begin
  SaveDialog := TSaveDialog.Create(self);
  SaveDialog.Filter := 'Excel|*.xls';

  if SaveDialog.Execute then
  begin
    //Dizin := copy(SaveDialog.FileName, 1, Pos('\', SaveDialog.FileName));
    if FileExists(SaveDialog.FileName) then
      if MessageDlg(SaveDialog.FileName + ' adlı dosya zaten var! Üzerine yazılsın mı?',
        mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
        exit;
    ExportGridToExcel(SaveDialog.FileName, cxBuildinMenu.Grid, True, True);
    Showmessage('Veriler Excel''e aktarıldı.');
  end;
end;

initialization
  Application.CreateForm(TcxUtils, cxUtils);
finalization
  //cxUtils.Free;
end.

