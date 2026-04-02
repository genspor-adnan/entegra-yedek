{
----------------------------------------------------------------------------------
Made By : Luis Alberto Lujan

Version : 1.0
0 Bugs Detected

Please send comments or bugs to: alberto@webchapin.com

If you want copy source code please put my name in "Thaks area"

}
unit DBNavLink;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, DB,
  Dialogs, JvLinkLabel, Graphics;

type
  TNavigateBtn = (nbFirst, nbPrior, nbNext, nbLast,
                  nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh);

  TDBNavClickBtn = procedure( var Operate:Boolean; Sender:TObject )of object;
  TDBNavClickSM  = procedure( Sender:TObject ) of object;
  TDBNavDeleteQuery = procedure (Sender : TObject ;var DeleteRecord : Boolean) of object;

  TMyNavDataLink = class;

  TDBNavLink = class(TJvLinkLabel)
  private
    FDataLink       : TMYNavDataLink;
    FConfirmDelete  : Boolean;
    FBeforeAction   : TDBNavClickBtn;
    FAfterAction    : TDBNavClickSM;
    FBtnFunction    : TNavigateBtn;
    FDeleteQuery    : TDBNavDeleteQuery;
    FActive: Boolean;
    function GetDataSource:TDataSource;
    procedure SetDataSource(Value: TDataSource);
    procedure SetBtnFunction(Value: TNavigateBtn);
    procedure CambioActivado;
    procedure CambioInfo;
    procedure CambioEdit;
    procedure SetActive(const Value: Boolean);
  protected
    procedure DoLinkClicked(LinkNumber: Integer; LinkText, LinkParam: string); override;
    procedure EnabledChanged;override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ConfirmDelete : Boolean read FConfirmDelete write FConfirmDelete default True;
    property BeforeAction  : TDBNavClickBtn read FBeforeAction write FBeforeAction;
    property AfterAction   : TDBNavClickSM read FAfterAction write FAfterAction;
    property BtnFunction   : TNavigateBtn read FBtnFunction write SetBtnFunction;
    property DeleteQuery   : TDBNavDeleteQuery read FDeleteQuery write FDeleteQuery;
    property Active        : Boolean read FActive write SetActive;
  end;

  TMyNavDataLink = class(TDataLink)
  private
    FNavigator : TDBNavLink;
  protected
    procedure EditingChanged; override;
    procedure DataSetChanged; override;
    procedure ActiveChanged; override;
  public
    constructor Create(ANav: TDBNavLink);
    destructor Destroy; override;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Data Controls', [TDBNavLink]);
end;

constructor TMyNavDataLink.Create(ANav: TDBNavLink);
begin
  inherited Create;
  FNavigator    := ANav;
  VisualControl := True;
end;

destructor TMyNavDataLink.Destroy;
begin
  FNavigator := nil;
  inherited Destroy;
end;

procedure TMyNavDataLink.ActiveChanged;
begin
  if FNavigator <> nil then FNavigator.CambioActivado;
end;

procedure TMyNavDataLink.DataSetChanged;
begin
  if FNavigator <> nil then FNavigator.CambioInfo;
end;

procedure TMyNavDataLink.EditingChanged;
begin
  if FNavigator <> nil then FNavigator.CambioEdit;
end;

procedure TDBNavLink.CambioActivado;
begin
  if not FDataLink.Active then
    Enabled := False
  else
  begin
    CambioInfo;
    CambioEdit;
  end;
end;

procedure TDBNavLink.CambioEdit;
var
  CanModify: Boolean;
begin
  if (not Active) then Exit;
  CanModify := FDataLink.Active and FDataLink.DataSet.CanModify;
  case FBtnFunction of
  //nuevo
    nbInsert  : Enabled := CanModify;
  //editar
    nbEdit    : Enabled := CanModify and not FDataLink.Editing;
  //ok
    nbPost    : Enabled := CanModify and FDataLink.Editing;
  //cancel
    nbCancel  : Enabled := CanModify and FDataLink.Editing;
  //refrescar
    nbRefresh : Enabled := CanModify;
  end;
end;

procedure TDBNavLink.CambioInfo;
var
  UpEnable, DnEnable: Boolean;
begin
  if (not Active) then Exit;
  UpEnable := FDataLink.Active and not FDataLink.DataSet.BOF;
  DnEnable := FDataLink.Active and not FDataLink.DataSet.EOF;
  case FBtnFunction of
  //primero
    nbFirst : Enabled := UpEnable;
  //anterior
    nbPrior : Enabled := UpEnable;
  //siguiente
    nbNext  : Enabled := DnEnable;
  //ultimo
    nbLast  : Enabled := DnEnable;
  //eliminar
    nbDelete : Enabled := FDataLink.Active and FDataLink.DataSet.CanModify and
                          not (FDataLink.DataSet.BOF and FDataLink.DataSet.EOF);
  end;
end;

function TDBNavLink.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBNavLink.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if not (csLoading in ComponentState) then
    CambioActivado;
  if Value <> nil then Value.FreeNotification(Self);
end;

constructor TDBNavLink.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink       := TMyNavDataLink.Create(Self);
  FConfirmDelete  := True;
  SetBtnFunction(nbFirst);
  ShowHint        := True;
  Enabled         := False;
  Height          := 43;
  Width           := 53;
end;

destructor TDBNavLink.Destroy;
begin
  FDataLink.Free;
  inherited Destroy;
end;

procedure TDBNavLink.SetBtnFunction(Value: TNavigateBtn);
begin
  FBtnFunction := Value;
  {
  case FBtnFunction of
    nbFirst   : Caption := 'Ýlk Kayýt';
    nbPrior   : Caption := 'Önceki Kayýt';
    nbNext    : Caption := 'Sonraki Kayýt';
    nbLast    : Caption := 'Son Kayýt';
    nbInsert  : Caption := 'Ekle';
    nbDelete  : Caption := 'Sil';
    nbEdit    : Caption := 'Düzenle';
    nbPost    : Caption := 'Onayla';
    nbCancel  : Caption := 'Ýptal';
    nbRefresh : Caption := 'Yenile';
  end;
  }

  case FBtnFunction of
    nbFirst   : Hint := 'Ýlk kayýda konumlanýr';
    nbPrior   : Hint := 'Önceki kayýda konumlanýr';
    nbNext    : Hint := 'Sonraki kayýda konumlanýr';
    nbLast    : Hint := 'Son kayýda konumlanýr';
    nbInsert  : Hint := 'Yeni kayýt ekler';
    nbDelete  : Hint := 'Geçerli kayýdý siler';
    nbEdit    : Hint := 'Geçerli kayýdý düzenlemek için açar.';
    nbPost    : Hint := 'Yapýlan deðiþiklikleri gönderir';
    nbCancel  : Hint := 'Yapýlan deðiþiklikleri iptal eder';
    nbRefresh : Hint := 'Geçerli verileri tekrar getirir';
  end;
end;

procedure TDBNavLink.DoLinkClicked(LinkNumber: Integer; LinkText,
  LinkParam: string);
var Operar:Boolean;
begin
  inherited;
  Operar := True;
  if Assigned(FBeforeAction) then
    FBeforeAction(Operar,Self);

  if Operar then
  begin
    case FBtnFunction of
    nbInsert : DataSource.DataSet.Insert;
    nbEdit   : DataSource.DataSet.Edit;
    nbPost   : DataSource.DataSet.Post;
    nbCancel : DataSource.DataSet.Cancel;
    nbDelete : if FConfirmDelete then
                 begin
                   if (Assigned(FDeleteQuery)) then
                     begin
                       FDeleteQuery(Self,Operar);
                       if (Operar) then
                         DataSource.DataSet.Delete;
                     end;
                 end
               else
                 DataSource.DataSet.Delete;
    nbRefresh: DataSource.DataSet.Refresh;
    nbFirst  : DataSource.DataSet.First;
    nbPrior  : DataSource.DataSet.Prior;
    nbNext   : DataSource.DataSet.Next;
    nbLast   : DataSource.DataSet.Last;
    end;//case
  end;

  if Assigned(FAfterAction) then
    FAfterAction(Self);
end;

procedure TDBNavLink.EnabledChanged;
begin
  inherited;
  if Enabled then
    LinkColor := clBlue
  else
    LinkColor := clGray;
end;

procedure TDBNavLink.SetActive(const Value: Boolean);
begin
  FActive := Value;
  if (not Value) then
    Enabled := False
  else
    begin
      CambioActivado;
    end;
end;

end.
