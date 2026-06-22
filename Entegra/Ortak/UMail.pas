unit UMail;

interface

uses
  uEncrypt, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, ExtCtrls, DBCtrls, Menus;

type
  TMailForm = class(TForm)
    GroupBox1: TGroupBox;
    DBGrid1: TDBGrid;
    MailNavigator: TDBNavigator;
    PopupMenu1: TPopupMenu;
    MNParola: TMenuItem;
    IFALSE: TImage;
    ITRUE: TImage;
    procedure DBGrid1CellClick(Column: TColumn);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure MNParolaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MailForm: TMailForm;
  SonColumn: TColumn;

implementation

uses uTablo, UCombo, uParolaTanim;

{$R *.dfm}

procedure TMailForm.DBGrid1CellClick(Column: TColumn);
begin
  SonColumn := Column;
//  if Column.FieldName = 'SERVERADRES' then
//    GenotipIni.ReadSection(column.FieldName, Column.PickList);
  if Column.FieldName = 'KIMLIKDOG' then
  begin
    DBGrid1.Options := [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit];
    Tablo.TabMail.Edit;
    Tablo.TabMail.FieldByName('KIMLIKDOG').AsBoolean := not Tablo.TabMail.FieldByName('KIMLIKDOG').AsBoolean;
  end
  else
    DBGrid1.Options := [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit];
end;

procedure TMailForm.DBGrid1DblClick(Sender: TObject);
begin
//  if SonColumn.FieldName = 'SERVERADRES' then
//  begin
//    ComboIniDuzenle(SonColumn.FieldName, GenotipIni);
//    GenotipIni.ReadSection(soncolumn.FieldName, sonColumn.PickList);
//  end;

end;

procedure TMailForm.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var Icon: TBitmap;
begin
  if (Tablo.TabMail.FieldByName('SIFRE').AsString) <> '' then
  begin
    DBGrid1.Canvas.Brush.Color := clInfoBk;
    DBGrid1.Canvas.Font.Color := clNavy;
    DBGrid1.Canvas.TextRect(Rect, rect.Left, rect.Top, Column.Field.AsString);
  end;

  if Column.FieldName = 'KIMLIKDOG' then
  begin
    dbgrid1.Canvas.FillRect(rect);
    Icon := TBitmap.Create;
    if Column.Field.AsBoolean then
      Icon.Assign(ITRUE.Picture)
    else
      Icon.Assign(IFALSE.Picture);
    DBGrid1.Canvas.Draw(round((Rect.Left + Rect.Right - Icon.Width) / 2), Rect.Top, Icon);
  end;

end;

procedure TMailForm.MNParolaClick(Sender: TObject);
begin
  Tablo.TabMail.edit;
  Tablo.TabMail.Post;
  Application.CreateForm(TParolaTanim, ParolaTanim);
  ParolaTanim.showmodal;
  ParolaTanim.Destroy;
end;

procedure TMailForm.FormCreate(Sender: TObject);
begin
  Tablo.TabMail.Open;
  SonColumn := DBGrid1.Columns[0];
//  GenotipIni.ReadSection('SERVERADRES', DBGrid1.Columns[3].PickList);
end;

procedure TMailForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  tablo.TabMail.Close;
end;

end.
