unit UComboDB;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Db, DBTables, Registry, Grids, DBGrids, ucOMBO, UFDCompatHelpers;

type
  TDBListeAyarlaDlg = class(TForm)
    Bevel1: TBevel;
    ListBox1: TListBox;
    Label1: TLabel;
    EkleTus: TBitBtn;
    SilTus: TBitBtn;
    DegistirTus: TBitBtn;
    UstTus: TSpeedButton;
    AltTus: TSpeedButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    DBGrid1: TDBGrid;
    SecTus: TSpeedButton;
    Label2: TLabel;
    Bevel2: TBevel;
    DataSource1: TDataSource;
    ListeQuery: TADOQuery;
    Edit1: TEdit;
    Label3: TLabel;
    SpeedButton1: TSpeedButton;
    Edit2: TEdit;
    procedure FormShow(Sender: TObject);
    procedure UstTusClick(Sender: TObject);
    procedure AltTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid1TitleClick(Column: TColumn);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Edit2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DBListeAyarlaDlg: TDBListeAyarlaDlg;
  Function DBComboIniDuzenle(AnahtarKelime1, SQLKomut1:String; Ini1 : TIni):integer;

implementation
uses UMesaj, UListe;
{$R *.DFM}
var
   j : integer;
   AnahtarKelime, Baslik, SQLKomut : String;
   Ini : TIni;

Function DBComboIniDuzenle(AnahtarKelime1, SQLKomut1:String; Ini1 : TIni):integer;
var K: Word;
Begin
    SQLKomut := SQLKomut1;
    Application.CreateForm(TDBListeAyarlaDlg, DBListeAyarlaDlg);
    Baslik :='';
    AnahtarKelime := AnahtarKelime1;
    Ini := Ini1;
//    DBListeAyarlaDlg.ListeQuery.SQL.Text := SQLKomut;
//    DBListeAyarlaDlg.ListeQuery.Open;
    DBListeAyarlaDlg.Edit1KeyUp(DBListeAyarlaDlg.Edit1, K, [ssShift]);
    DBComboIniDuzenle := DBListeAyarlaDlg.ShowModal;
    DBListeAyarlaDlg.Free;
End;

procedure TDBListeAyarlaDlg.FormShow(Sender: TObject);
begin
//   Ini.ReadSection(AnahtarKelime, ListBox1.Items);
   Ini.ReadSectionValues(AnahtarKelime, ListBox1.Items);
   ListBox1.ItemIndex := 0;
end;

procedure TDBListeAyarlaDlg.UstTusClick(Sender: TObject);
begin
   if (ListBox1.Items.Count < 2)or(ListBox1.ItemIndex = 0) then exit;
   ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex-1) ;
end;

procedure TDBListeAyarlaDlg.AltTusClick(Sender: TObject);
begin
   if (ListBox1.Items.Count < 2)or(ListBox1.ItemIndex = ListBox1.Items.Count-1) then exit;
   ListBox1.Items.Exchange(ListBox1.ItemIndex, ListBox1.ItemIndex+1) ;
end;

procedure TDBListeAyarlaDlg.SilTusClick(Sender: TObject);
begin
   if ListBox1.Items.Count = 0 then exit;
   ListBox1.Items.Delete(ListBox1.ItemIndex) ;
   ListBox1.SetFocus;
end;

procedure TDBListeAyarlaDlg.EkleTusClick(Sender: TObject);
var MesajOkunan : String;
begin
  if TBitBtn(Sender).Name = 'EkleTus' then
     MesajOkunan := ''
  else
     MesajOkunan := ListBox1.Items[ListBox1.ItemIndex];

  if MesajStrAl('', 'Listeye Yeni Bilgiyi Giriniz..', 'E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then
     if TBitBtn(Sender).Name = 'EkleTus' then
        ListBox1.Items.Add(MesajOkunan)
     else
        ListBox1.Items.Strings[ListBox1.ItemIndex] := MesajOkunan;
end;

procedure TDBListeAyarlaDlg.BitBtn2Click(Sender: TObject);
var i,yer : integer;
begin
   Ini.EraseSection(AnahtarKelime);
   for i := 0 to ListBox1.Items.Count - 1  do begin
       yer := pos('=',ListBox1.Items[i]);
       if yer = 0 then
          Ini.WriteString(AnahtarKelime, ListBox1.Items[i],'')
       else
          Ini.WriteString(AnahtarKelime, copy(ListBox1.Items[i],1,yer-1), copy(ListBox1.Items[i],yer+1, length(ListBox1.Items[i])))
   end;
end;

procedure TDBListeAyarlaDlg.SecTusClick(Sender: TObject);
begin
   if ListeQuery.FieldCount>1 then
      ListBox1.Items.Add(ListeQuery.Fields[0].AsString+'='+ListeQuery.Fields[1].AsString)
   else
      ListBox1.Items.Add(ListeQuery.Fields[0].AsString);
end;

procedure TDBListeAyarlaDlg.Edit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 38 then ListeQuery.Prior
   else if Key = 40 then ListeQuery.next
   else begin
//     StringReplace(SQLKomut,'Edit1',Edit1.Text,[rfReplaceAll]);
     ListeQuery.SQL.Text := copy(SQLKomut,1,pos('"',SQLKomut))+Edit1.Text+copy(SQLKomut,pos('%',SQLKomut),length(SQLKomut)-pos('%',SQLKomut)+1)+Baslik;
     ListeQuery.SQL.Text := StringReplace(ListeQuery.SQL.Text, '"', '''', [rfReplaceAll]);
     ListeQuery.Open;
  end;

end;

procedure TDBListeAyarlaDlg.DBGrid1TitleClick(Column: TColumn);
VAR k : wORD;
begin
   Baslik := ' order by '+Column.FieldName;
   Edit1KeyUp(DBListeAyarlaDlg.Edit1, K, []);
end;

procedure TDBListeAyarlaDlg.SpeedButton1Click(Sender: TObject);
begin
   ListBox1.Sorted := False;
   ListBox1.Sorted := True;
end;

procedure TDBListeAyarlaDlg.Edit2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if Key = 38 then ListeQuery.Prior
   else if Key = 40 then ListeQuery.next
   else begin
//     StringReplace(SQLKomut,'Edit1',Edit1.Text,[rfReplaceAll]);
     ListeQuery.SQL.Text := 'select KOD,ISLEMADI from ISLEMLER where KOD like '''+Edit2.Text+'%'' order by KOD';
     ListeQuery.Open;
  end;
end;

end.

