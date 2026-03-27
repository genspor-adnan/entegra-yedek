unit UHataListesi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ImgList;

type
  ThataListesiForm = class(TForm)
    Label1: TLabel;
    kapatButton: TButton;
    hataListView: TListView;
    hataListViewImageList: TImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  hataListesiForm: ThataListesiForm;

  procedure AddError(msg : string);
  procedure AddInfo(msg: string);
  
implementation

{$R *.dfm}

procedure AddCustomItem(description: string;imageIndex: integer);
var
  item : TListItem;
begin
  if (not hataListesiForm.Visible) then
    hataListesiForm.Show;
  item := hataListesiForm.hataListView.Items.Add;
  item.Caption := description;
  item.ImageIndex := imageIndex;
  hataListesiForm.Update;
end;

procedure AddError(msg : string);
begin
  AddCustomItem(msg,1);
end;

procedure AddInfo(msg: string);
begin
  AddCustomItem(msg,0);
end;

end.
