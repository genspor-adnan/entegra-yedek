unit UYatan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, StdCtrls, Buttons, Grids, DBGrids, ExtCtrls, ComCtrls,
  Menus, ImgList, ToolWin;

type
  TYatanHastaListDlg = class(TForm)
    Panel2: TPanel;
    DtsYatan: TDataSource;
    TabYatan: TQuery;
    ListView1: TListView;
    ImageList1: TImageList;
    ImageList2: TImageList;
    PopupMenuGor: TPopupMenu;
    Byk1: TMenuItem;
    Kk1: TMenuItem;
    Liste1: TMenuItem;
    Ayrnt1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    Panel1: TPanel;
    Calendar1: TDateTimePicker;
    ToolButton5: TToolButton;
    PopupMenudol: TPopupMenu;
    BosDolu: TMenuItem;
    Bos: TMenuItem;
    Dolu: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Calendar1Change(Sender: TObject);
    procedure Byk1Click(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure BosClick(Sender: TObject);
    procedure DoluClick(Sender: TObject);
    procedure BosDoluClick(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    procedure BosOdalar;
    procedure DoluOdalar;
    function BuYataktaYatanVar(Oda : String) : Boolean;
  public
    { Public declarations }
  end;

var
  YatanHastaListDlg: TYatanHastaListDlg;

implementation

uses UTablo, UCombo;
{$R *.DFM}

var BasTar, BitTar:string[100];
    Odalar : TStringList;
    ServisIni : TIni;
    i, ColumnToSort : integer;

procedure TYatanHastaListDlg.FormCreate(Sender: TObject);
begin
   Odalar := TStringList.Create;
   ServisIni := TIni.Create('SERVISINI', Tablo.IniSQL);
   ServisIni.ReadSection('ODA', Odalar );
   Calendar1.Date := Date;
   Calendar1Change(Self);
end;

procedure TYatanHastaListDlg.Calendar1Change(Sender: TObject);
begin
 {  TabCari.Close;
   TabCari.SQL.Text := 'Select * From CARIHAR Where TARIH >= "'+FormatDateTime('mm/dd/yyyy', Calendar1.Date)+' 00:00:00" and'+
                                                  ' TARIH <= "'+FormatDateTime('mm/dd/yyyy', Calendar1.Date)+' 23:59:00" Order By TARIH, SIRANO';
   TabCari.Open;
   }
   BasTar := ' AND GIRISTARIH <= "'+FormatDateTime('mm/dd/yyyy', Calendar1.Date)+' 23:59:00"';
   if FormatDateTime('mm/dd/yyyy', Calendar1.Date) =FormatDateTime('mm/dd/yyyy', Date) then
{     BitTar := ' AND CIKISTARIH IS NULL '
   else
      BitTar := ' AND CIKISTARIH >= "'+FormatDateTime('mm/dd/yyyy', Calendar1.Date)+' 23:59:00"';}
   BitTar := 'AND (CIKISTARIH IS NULL OR CIKISTARIH <= "'+FormatDateTime('mm/dd/yyyy', Calendar1.Date)+' 00:00:00")';
   TabYatan.SQL.Text := 'Select ODA, KIMLIK.DOSYANO, AD, SOYAD, UZMANLIK, SERVIS.DOKTOR,  GIRISTARIH, CIKISTARIH FROM KIMLIK,SERVIS,DOKTOR'+
        ' Where SERVIS.DOKTOR=DOKTOR.DOKTOR AND SERVIS.DOSYANO = KIMLIK.DOSYANO '+BasTar+' '+BitTar+'order by ODA';
   TabYatan.Open;

   DoluOdalar;
end;

procedure TYatanHastaListDlg.Byk1Click(Sender: TObject);
begin
   case TMenuItem(Sender).Tag of
     1 :  ListView1.ViewStyle := vsIcon;
     2 :  ListView1.ViewStyle := vsSmallIcon;
     3 :  ListView1.ViewStyle := vsList;
     4 :  ListView1.ViewStyle := vsReport;
   end;
end;

procedure TYatanHastaListDlg.DoluOdalar;
begin
   TabYatan.First;
   while not TabYatan.eof do begin
     ListView1.Items.Add;
     ListView1.Items[ListView1.Items.Count-1].Caption := TabYatan.Fields[0].AsString+' '+TabYatan.Fields[2].AsString+' '+
               TabYatan.Fields[3].AsString+' '+TabYatan.Fields[4].AsString;
     ListView1.Items[ListView1.Items.Count-1].SubItems.Add(TabYatan.Fields[1].AsString);
     ListView1.Items[ListView1.Items.Count-1].SubItems.Add(TabYatan.Fields[2].AsString);
     ListView1.Items[ListView1.Items.Count-1].SubItems.Add(TabYatan.Fields[3].AsString);
     ListView1.Items[ListView1.Items.Count-1].SubItems.Add(TabYatan.Fields[4].AsString);
     ListView1.Items[ListView1.Items.Count-1].SubItems.Add(TabYatan.Fields[5].AsString);
     ListView1.Items[ListView1.Items.Count-1].SubItems.Add(TabYatan.Fields[6].AsString);
     ListView1.Items[ListView1.Items.Count-1].SubItems.Add(TabYatan.Fields[7].AsString);
     TabYatan.next;
   end;
end;
procedure TYatanHastaListDlg.ToolButton2Click(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TYatanHastaListDlg.ToolButton1Click(Sender: TObject);
begin
   ModalResult := mrOK;
end;

function TYatanHastaListDlg.BuYataktaYatanVar(Oda : String) : Boolean;
begin
   BuYataktaYatanVar := False;
   TabYatan.First;
   while not TabYatan.eof do begin
     if Oda = TabYatan.Fields[0].AsString then
        BuYataktaYatanVar := true;
     TabYatan.next;
   end;
end;

procedure TYatanHastaListDlg.BosOdalar;
begin
   for i := 0 to Odalar.Count-1 do
     if not BuYataktaYatanVar(Odalar.Strings[i]) then begin
        ListView1.Items.Add;
        ListView1.Items[ListView1.Items.Count-1].Caption := Odalar.Strings[i];
     end;
end;

procedure TYatanHastaListDlg.BosClick(Sender: TObject);
begin
   ListView1.Items.Clear;
   BosOdalar
end;

procedure TYatanHastaListDlg.DoluClick(Sender: TObject);
begin
   ListView1.Items.Clear;
   DoluOdalar;
end;

procedure TYatanHastaListDlg.BosDoluClick(Sender: TObject);
begin
   ListView1.Items.Clear;
   BosOdalar;
   DoluOdalar;
end;

procedure TYatanHastaListDlg.ListView1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  ColumnToSort := Column.Index;
  (Sender as TCustomListView).AlphaSort;
end;

procedure TYatanHastaListDlg.ListView1Compare(Sender: TObject; Item1,
          Item2: TListItem; Data: Integer; var Compare: Integer);
var
  ix: Integer;
begin
  if ColumnToSort = 0 then
    Compare := CompareText(Item1.Caption,Item2.Caption)
  else begin
   ix := ColumnToSort - 1;
   Compare := CompareText(Item1.SubItems[ix],Item2.SubItems[ix]);
  end;
end;

procedure TYatanHastaListDlg.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   ServisIni.Free;
   Odalar.Free;
end;

end.
