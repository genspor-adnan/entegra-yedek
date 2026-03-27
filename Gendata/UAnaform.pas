unit UAnaform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, DBTables, Buttons, ImgList, ComCtrls, ToolWin, ExtCtrls,
  Menus;

type
  TAnaForm = class(TForm)
    ToolBar1: TToolBar;
    YedekleTus: TToolButton;
    YukleTus: TToolButton;
    ToolButton3: TToolButton;
    AyarlamaTus: TToolButton;
    ImageList1: TImageList;
    Tr: TTreeView;
    KomutTus: TToolButton;
    ToolButton6: TToolButton;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    Sil1: TMenuItem;
    PopupMenu2: TPopupMenu;
    TabloDuzenle: TMenuItem;
    YeniTablo1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    TabloyuSil1: TMenuItem;
    ScrollBox1: TScrollBox;
    LV: TListView;
    ToolBar2: TToolBar;
    YeniTablo: TToolButton;
    TabloSil: TToolButton;
    ToolButton4: TToolButton;
    TabloyuDuzenle: TToolButton;
    procedure KomutTusClick(Sender: TObject);
    procedure AyarlamaTusClick(Sender: TObject);
    procedure TrClick(Sender: TObject);
    procedure YedekleTusClick(Sender: TObject);
    procedure YukleTusClick(Sender: TObject);
    procedure Sil1Click(Sender: TObject);
    procedure TabloDuzenleClick(Sender: TObject);
    procedure YeniTablo1Click(Sender: TObject);
    procedure TabloyuSil1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AnaForm: TAnaForm;

implementation

uses UTablo, USQL, UYedek1, UYedek2, UYukle1, UYukle2, UYukle3, UDuzenle, UMesaj;

{$R *.DFM}
var i : integer;

procedure TAnaForm.KomutTusClick(Sender: TObject);
begin
//   TABLO.Query2.ExecSQL;
   SQLDlg.ShowModal;
end;

procedure TAnaForm.AyarlamaTusClick(Sender: TObject);
begin
   Tr.Items.Clear;
   Tablo.Query1.SQL.Text := 'sp_helpdb';
   Tablo.Query1.Open;
   while not Tablo.Query1.eof do begin
      Tr.Items.Add(nil,Tablo.Query1.fields[0].AsString);
      Tablo.Query1.next;
   end;
end;

procedure TAnaForm.TrClick(Sender: TObject);
begin
   Database := Tr.Selected. Text;
   LV.Items.Clear;
   Tablo.Query1.SQL.Text := 'USE '+Database+' EXEC sp_tables';
   Tablo.Query1.Open;
   while not Tablo.Query1.eof do begin
      if Tablo.Query1.fieldByName('TABLE_TYPE').AsString = 'TABLE' then begin
         LV.Items.Add;
         LV.Items[LV.Items.Count-1].Caption := Tablo.Query1.fieldByName('TABLE_NAME').AsString;
//         LV.Items[LV.Items.Count-1].SubItems.Add(Tablo.Query1.fieldByName('TABLE_TYPE').AsString);
         LV.Items[LV.Items.Count-1].SubItems.Add(Tablo.Query1.fieldByName('TABLE_OWNER').AsString);
      end;
      Tablo.Query1.next;
   end;
end;

procedure TAnaForm.YedekleTusClick(Sender: TObject);
begin
   Yedek1.ShowModal;
   if Yedek1.ModalResult = mrOK then begin
      for i := 0 to Yedek1.CheckListBox1.Items.Count-1 do
      if Yedek1.CheckListBox1.Checked[i] then
         Database := Yedek1.CheckListBox1.Items[i];
      Yedek2.ShowModal;
      if Yedek1.ModalResult = mrRetry then YedekleTus.Click;
   end;
end;

procedure TAnaForm.YukleTusClick(Sender: TObject);
begin
   Yukle1.ShowModal;
   if Yukle1.ModalResult = mrCancel then exit;
   YukleYol := Yukle1.Ad.Text;
   Yukle2.ShowModal;
   if Yukle2.ModalResult = mrRetry then YukleTus.Click
   else if Yukle2.ModalResult = mrCancel then exit;;
   Database := Yukle2.Ad.Text;
//   if Yukle3.ModalResult = mrRetry then YukleTus.Click;
   Yukle3.ShowModal;
end;

procedure TAnaForm.Sil1Click(Sender: TObject);
var s : PChar;//Array[0..50] of char;
begin
   StrPCopy(s, Tr.Selected.Text+' Silinecektir. Onaylýyor musunuz?');
   if Application.MessageBox(s,'DÝKKAT!!!',MB_OKCANCEL) <> IDOK then exit;
   Tablo.Query1.SQL.Text := 'DROP DATABASE '+Tr.Selected. Text;
   Tablo.Query1.ExecSQL;
//   AyarlamaTus.Click;
end;

procedure TAnaForm.TabloDuzenleClick(Sender: TObject);
begin
   TabloAdi := LV.Selected.Caption;
   DuzenleDlg.YeniEski := 'E';
   DuzenleDlg.ShowModal;
end;

procedure TAnaForm.YeniTablo1Click(Sender: TObject);
var MesajOkunan : string;
begin
   if not MesajStrAl('', 'Yeni Dosya Adýný Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then exit;
   if Trim(MesajOkunan) = '' then exit;
   TabloAdi := MesajOkunan;
   DuzenleDlg.YeniEski := 'Y';
   DuzenleDlg.ShowModal;

end;

procedure TAnaForm.TabloyuSil1Click(Sender: TObject);
var s : PChar;//Array[0..50] of char;
begin
   TabloAdi := LV.Selected.Caption;
   StrPCopy(s, TabloAdi+' Silinecektir. Onaylýyor musunuz?');
   if Application.MessageBox(s,'DÝKKAT!!!',MB_OKCANCEL) <> IDOK then exit;
   Tablo.Query1.SQL.Text := 'USE '+Database+' DROP TABLE  '+TabloAdi;
   Tablo.Query1.ExecSQL;
//   Tr.SetFocus;
//   TrClick(Self);
//   AyarlamaTus.Click;
end;

end.
