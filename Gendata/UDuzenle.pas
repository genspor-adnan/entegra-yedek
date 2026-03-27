unit UDuzenle;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, Grids, DBGrids, ImgList, ComCtrls, ToolWin, StdCtrls;

type
  TDuzenleDlg = class(TForm)
    ToolBar1: TToolBar;
    KaydetTus: TToolButton;
    ImageList1: TImageList;
    DataSource1: TDataSource;
    TabAlan: TQuery;
    Grid1: TStringGrid;
    ToolButton1: TToolButton;
    Ekle: TToolButton;
    Sil: TToolButton;
    TabIndex: TQuery;
    ToolButton2: TToolButton;
    IndexTus: TToolButton;
    Memo1: TMemo;
    procedure FormShow(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure EkleClick(Sender: TObject);
    procedure SilClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IndexTusClick(Sender: TObject);
    procedure Grid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure IndeksleriAl;
    procedure IkincilIndeksEkle;
    procedure IkincilIndeksSil;
  public
    { Public declarations }
    YeniEski : char;
  end;

var
  DuzenleDlg: TDuzenleDlg;

implementation
uses UTablo, UListeDinamik;

{$R *.DFM}
var s, AnaIndexAlan, AnaIndexAd: string;
    i : integer;
    AlanList, OncekiIndexList, IndexList: TStringList;

procedure TDuzenleDlg.FormShow(Sender: TObject);
begin
   Grid1.RowCount := 2;
   AlanList := TStringList.Create;
   IndexList := TStringList.Create;
   OncekiIndexList := TStringList.Create;
   Grid1.Cells[0,0] := 'ÝNDEX';
   Grid1.Cells[1,0] := 'ALAN ADI';
   Grid1.Cells[2,0] := 'ALAN TÝPÝ';
   Grid1.Cells[3,0] := 'UZUNLUK';
   Grid1.Cells[4,0] := 'DUYARLILIK';
   Grid1.Cells[5,0] := 'ÖLÇEK';
   Grid1.Cells[6,0] := 'BOÞLUK';
   Grid1.Cells[7,0] := 'ARTIÞ';
   Grid1.Cells[2,1] := 'VARCHAR';
   Grid1.Cells[3,1] := '10';
   Grid1.Cells[6,1] := 'VAR';
   Grid1.Cells[7,1] := 'YOK';
   if YeniEski = 'Y' then exit;
   //Ýndexleri bulalým
   IndeksleriAl;

   TabAlan.SQL.Text := 'USE '+Database+' EXEC sp_columns @table_name = '''+TabloAdi+'''';
   TabAlan.Open;
   while not TabAlan.eof do begin
      //Satýr Ekle
     Grid1.RowCount := Grid1.RowCount + 1;
     Grid1.Row :=  Grid1.RowCount -1;

     Grid1.Cells[1,Grid1.Row-1] := TabAlan.FieldByName('COLUMN_NAME').AsString;
     if pos(Grid1.Cells[1,Grid1.Row-1], AnaIndexAlan)>0 then
        Grid1.Cells[0,Grid1.Row-1] := '*'
     else
        Grid1.Cells[0,Grid1.Row-1] := '';

     s := TabAlan.FieldByName('TYPE_NAME').AsString;
     if pos('IDENTITY', UpperCase(s)) > 0 then begin
        Grid1.Cells[7,Grid1.Row-1] := 'VAR';
        s := copy(s,1,pos(' ',s))
     end else
        Grid1.Cells[7,Grid1.Row-1] := 'YOK';

     Grid1.Cells[2,Grid1.Row-1] := s;
     Grid1.Cells[3,Grid1.Row-1] := TabAlan.FieldByName('LENGTH').AsString;
     if s='numeric' then begin
        Grid1.Cells[4,Grid1.Row-1] := TabAlan.FieldByName('PRECISION').AsString;
        Grid1.Cells[5,Grid1.Row-1] := TabAlan.FieldByName('SCALE').AsString;
     end;
     if TabAlan.FieldByName('IS_NULLABLE').AsString = 'NO' then
        Grid1.Cells[6,Grid1.Row-1] := 'YOK'
     else
        Grid1.Cells[6,Grid1.Row-1] := 'VAR';
     TabAlan.Next;
   end;
   Grid1.RowCount := Grid1.RowCount - 1;
end;

procedure TDuzenleDlg.KaydetTusClick(Sender: TObject);
begin
    AnaIndexAlan := '';
    for i:=0 to Grid1.RowCount-1 do
       if Grid1.Cells[0, i] = '*' then begin
           AnaIndexAlan := AnaIndexAlan + Grid1.Cells[1, i]+',';
           if UpperCase(Grid1.Cells[6,i])='VAR' then
              raise exception.Create('Ýndeks olan alanda boþluk olamaz...');
    end;
    Delete(AnaIndexAlan,Length(AnaIndexAlan),1);

    Tablo.Query1.SQL.Clear;
    Tablo.Query1.SQL.Add('USE '+Database);
{    Tablo.Query1.SQL.Add('BEGIN TRANSACTION');
    Tablo.Query1.SQL.Add('SET QUOTED_IDENTIFIER ON');
    Tablo.Query1.SQL.Add('SET TRANSACTION ISOLATION LEVEL SERIALIZABLE');
    Tablo.Query1.SQL.Add('SET ARITHABORT ON');
    Tablo.Query1.SQL.Add('SET NUMERIC_ROUNDABORT OFF');
    Tablo.Query1.SQL.Add('SET CONCAT_NULL_YIELDS_NULL ON');
    Tablo.Query1.SQL.Add('SET ANSI_NULLS ON');
    Tablo.Query1.SQL.Add('SET ANSI_PADDING ON');
    Tablo.Query1.SQL.Add('SET ANSI_WARNINGS ON');
    Tablo.Query1.SQL.Add('COMMIT');
    Tablo.Query1.SQL.Add('BEGIN TRANSACTION');
}    if YeniEski = 'E' then
       Tablo.Query1.SQL.Add('CREATE TABLE dbo.Tmp_'+TabloAdi)
    else
       Tablo.Query1.SQL.Add('CREATE TABLE dbo.'+TabloAdi);
    Tablo.Query1.SQL.Add('(');
    for i := 1 to Grid1.RowCount-1 do begin
       s := Grid1.Cells[1,i]+' '+Grid1.Cells[2,i];
       if UpperCase(Grid1.Cells[2,i]) = 'VARCHAR' then
          s :=s+'('+Grid1.Cells[3,i]+') ' //length
       else if UpperCase(Grid1.Cells[2,i]) = 'NUMERIC' then
          s :=s+'('+Grid1.Cells[4,i]+','+Grid1.Cells[5,i]+') '; //length
       if UpperCase(Grid1.Cells[6,i]) = 'YOK' then
          s := s+' NOT ';
       s := s+' NULL ';
       if UpperCase(Grid1.Cells[7,i]) = 'VAR' then
          s := s + ' IDENTITY (1, 1)';
//       if i = 1 then s := s + ' PRIMARY KEY CLUSTERED';
       if i = 1 then s := s + ' CONSTRAINT PK_'+TabloAdi+' PRIMARY KEY NONCLUSTERED';

       if i < Grid1.RowCount-1 then s:=s+',';
       Tablo.Query1.SQL.Add(s);
    end;
    Tablo.Query1.SQL.Add(')  ON [PRIMARY]');
    MEMO1.TEXT := MEMO1.TEXT+#13+#10+Tablo.Query1.SQL.TEXT;
    Tablo.Query1.ExecSQL;

    if YeniEski = 'E' then begin
       Tablo.Query1.SQL.Clear;
       Tablo.Query1.SQL.Add('USE '+Database);
       Tablo.Query1.SQL.Add('IF EXISTS(SELECT * FROM dbo.'+TabloAdi+')');
       AlanList.Clear;
       for i := 1 to Grid1.RowCount-1 do begin
          AlanList.Add(Grid1.Cells[1,i]);
          TabAlan.Next;
          if i < Grid1.RowCount-1 then AlanList[i-1]:=AlanList[i-1]+',';
       end;
       Tablo.Query1.SQL.Add('EXEC(''INSERT INTO dbo.Tmp_'+TabloAdi+' (');
       Tablo.Query1.SQL.AddStrings(AlanList);
       Tablo.Query1.SQL.Add(') SELECT ');
       Tablo.Query1.SQL.AddStrings(AlanList);
       Tablo.Query1.SQL.Add(' FROM dbo.'+TabloAdi+' TABLOCKX'')');
       Tablo.Query1.ExecSQL;

       Tablo.Query1.SQL.Clear;
       Tablo.Query1.SQL.Add('USE '+Database);
       Tablo.Query1.SQL.Add('DROP TABLE dbo.'+TabloAdi);
       Tablo.Query1.ExecSQL;

       Tablo.Query1.SQL.Clear;
       Tablo.Query1.SQL.Add('USE '+Database);
       Tablo.Query1.SQL.Add('EXECUTE sp_rename N''dbo.Tmp_'+TabloAdi+''', N'''+TabloAdi+''', ''OBJECT''');
    MEMO1.Lines.ADD('');
    MEMO1.TEXT := MEMO1.TEXT+Tablo.Query1.SQL.TEXT;
       Tablo.Query1.ExecSQL;
    end;

{    Tablo.Query1.SQL.Clear;
    Tablo.Query1.SQL.Add('USE '+Database);
    Tablo.Query1.SQL.Add('DROP INDEX '+TabloAdi+'.PK_'+TabloAdi);
    Tablo.Query1.ExecSQL;  }

//    if YeniEski = 'Y' then exit;

    Tablo.Query1.SQL.Clear;
    AnaIndexAlan := '';
    for i:=0 to Grid1.RowCount-1 do
     if Grid1.Cells[0, i] = '*' then
        AnaIndexAlan := AnaIndexAlan + Grid1.Cells[1, i]+',';


    if AnaIndexAlan <> '' then begin
       if Trim(AnaIndexAd) = '' then
          AnaIndexAd := 'PK_'+TabloAdi;
       Delete(AnaIndexAlan,Length(AnaIndexAlan),1);
       Tablo.Query1.SQL.Add('USE '+Database);
       Tablo.Query1.SQL.Add('ALTER TABLE dbo.'+TabloAdi+'  CONSTRAINT');
       Tablo.Query1.SQL.Add(AnaIndexAd+' PRIMARY KEY CLUSTERED');
       Tablo.Query1.SQL.Add('('+AnaIndexAlan+') ON [PRIMARY]');
       Tablo.Query1.SQL := Tablo.Query1.SQL;


    MEMO1.Lines.ADD('');
    MEMO1.TEXT := MEMO1.TEXT+Tablo.Query1.SQL.TEXT;

       Tablo.Query1.ExecSQL;

       IkincilIndeksEkle;


{       Tablo.Query1.SQL.Clear;
       Tablo.Query1.SQL.Add('COMMIT');
    MEMO1.Lines.ADD('');
    MEMO1.TEXT := MEMO1.TEXT+Tablo.Query1.SQL.TEXT;}
       Tablo.Query1.ExecSQL;
    end;
    ShowMessage('Deðiþtirildi..');
end;

procedure TDuzenleDlg.IndeksleriAl;
begin
   TabIndex.SQL.Text := 'USE '+Database+' EXEC sp_helpindex '''+TabloAdi+'''';
   TabIndex.Open;
   AnaIndexAlan := '';  AnaIndexAd:=''; IndexList.Clear;
   while not TabIndex.eof do begin
      if pos('unique', TabIndex.FieldByName('INDEX_DESCRIPTION').AsString)>0 then begin
         AnaIndexAlan := TabIndex.FieldByName('INDEX_KEYS').AsString;
         AnaIndexAd := TabIndex.FieldByName('INDEX_NAME').AsString;
      end
      else IndexList.Add(TabIndex.FieldByName('INDEX_NAME').AsString+'='+TabIndex.FieldByName('INDEX_KEYS').AsString);
      TabIndex.next;
   end;
end;

procedure TDuzenleDlg.IkincilIndeksEkle;
var indad, indalan : string;
begin
   //Ýkincil Ýndexleri ekleyelim
   for i:=0 to IndexList.Count-1 do begin
       indad := copy(IndexList.Strings[i], 1, pos('=', IndexList.Strings[i])-1);
       indalan := copy(IndexList.Strings[i], pos('=', IndexList.Strings[i])+1, length(IndexList.Strings[i])-pos('=', IndexList.Strings[i]));

       Tablo.Query1.SQL.Clear;
       Tablo.Query1.SQL.Add('USE '+Database);
       Tablo.Query1.SQL.Add('CREATE INDEX ['+indad+'] ON [dbo].['+TabloAdi+'] (');
       while pos(',', indalan)>0 do begin
             s:=Trim(copy(indalan,1,pos(',', indalan)-1));
             Delete(indalan,1,pos(',', indalan));
             Tablo.Query1.SQL.Add('['+s+'],');
       end;
       indalan := Trim(indalan);
       Tablo.Query1.SQL.Add('['+indalan+']');
       Tablo.Query1.SQL.Add(')');
      Tablo.Query1.ExecSQL;
   end;
end;

procedure TDuzenleDlg.IkincilIndeksSil;
var indad, indalan : string;
begin
   //Ýkincil Ýndexleri silelim
   for i:=0 to OncekiIndexList.Count-1 do begin
       indad := copy(OncekiIndexList.Strings[i], 1, pos('=', OncekiIndexList.Strings[i])-1);
       indalan := copy(OncekiIndexList.Strings[i], pos('=', OncekiIndexList.Strings[i])+1, length(OncekiIndexList.Strings[i])-pos('=', OncekiIndexList.Strings[i]));

       Tablo.Query1.SQL.Clear;
       Tablo.Query1.SQL.Add('USE '+Database);
       Tablo.Query1.SQL.Add('DROP INDEX [dbo].['+TabloAdi+'].['+indad+']');
       Tablo.Query1.ExecSQL;
   end;
end;

procedure TDuzenleDlg.IndexTusClick(Sender: TObject);
begin
   IndeksleriAl;
   OncekiIndexList.Clear;
   OncekiIndexList.AddStrings(IndexList);
   if ListeDuzenle(IndexList) = MROK then begin
      IkincilIndeksSil;
      IkincilIndeksEkle;
   end;
end;

procedure TDuzenleDlg.EkleClick(Sender: TObject);
var satir : integer;
begin
   Satir := Grid1.Row;
   Grid1.RowCount := Grid1.RowCount + 1;
   for i := Grid1.RowCount-1 downto Grid1.Row+1  do
       Grid1.Rows[i] := Grid1.Rows[i-1];

   for i := 0 to Grid1.Colcount-1  do
       Grid1.Cells[i, Grid1.Row] := '';
   Grid1.Cells[2,Grid1.Row] := 'VARCHAR';
   Grid1.Cells[3,Grid1.Row] := '10';
   Grid1.Cells[6,Grid1.Row] := 'VAR';
   Grid1.Cells[7,Grid1.Row] := 'YOK';
//   Grid1.RowCount := Grid1.RowCount + 1;
//   Grid1.Row :=  Grid1.RowCount -1;
end;

procedure TDuzenleDlg.SilClick(Sender: TObject);
var Sonsatir : Boolean;
begin
//   Sonsatir := Grid1.Row = Grid1.RowCount-1;
   for i := Grid1.Row to Grid1.RowCount -1 do
       Grid1.Rows[i] := Grid1.Rows[i+1];
   Grid1.RowCount := Grid1.RowCount - 1;
//   if Sonsatir then Grid1.Row := Grid1.RowCount-1;
   Grid1.Refresh;
end;

procedure TDuzenleDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   AlanList.Free;
   IndexList.Free;
   OncekiIndexList.Free;
end;

procedure TDuzenleDlg.Grid1KeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
   if (Key <> 40)or(Grid1.Row<>Grid1.RowCount-1) then exit;
   Grid1.RowCount := Grid1.RowCount + 1;
   Grid1.Cells[2,Grid1.RowCount] := 'VARCHAR';
   Grid1.Cells[3,Grid1.RowCount] := '10';
   Grid1.Cells[6,Grid1.RowCount] := 'VAR';
   Grid1.Cells[7,Grid1.RowCount] := 'YOK';
end;

end.

USE yyy
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
CREATE TABLE dbo.Tmp_ANT
(
(15)  NOT  NULL ,
GELISNO smallint NOT  NULL ,
TARIH datetime NOT  NULL ,
ATES numeric NULL ,
NABIZ smallint NULL ,
(10)  NULL ,
(3)  NULL ,
(3)  NULL
)  ON [PRIMARY]
GO
IF EXISTS(SELECT * FROM dbo.ANT)
EXEC('INSERT INTO dbo.Tmp_ANT (DOSYANO,GELISNO,TARIH,ATES,NABIZ,TANSIYON,DR,HEM) SELECT DOSYANO,GELISNO,TARIH,ATES,NABIZ,TANSIYON,DR,HEM FROM dbo.ANT TABLOCKX
GO
DROP TABLE dbo.ANT
GO
EXECUTE sp_rename N'dbo.Tmp_ANT', N'ANT', 'OBJECT'
GO
ALTER TABLE dbo.ANT ADD CONSTRAINT
PK_ANT PRIMARY KEY NONCLUSTERED
(DOSYANO,TARIH,SIRANO
) ON [PRIMARY]
GO
COMMIT

{
    Memo1.Lines.Add('USE '+Database);
    Memo1.Lines.Add('BEGIN TRANSACTION');
    Memo1.Lines.Add('SET QUOTED_IDENTIFIER ON');
    Memo1.Lines.Add('SET TRANSACTION ISOLATION LEVEL SERIALIZABLE');
    Memo1.Lines.Add('SET ARITHABORT ON');
    Memo1.Lines.Add('SET NUMERIC_ROUNDABORT OFF');
    Memo1.Lines.Add('SET CONCAT_NULL_YIELDS_NULL ON');
    Memo1.Lines.Add('SET ANSI_NULLS ON');
    Memo1.Lines.Add('SET ANSI_PADDING ON');
    Memo1.Lines.Add('SET ANSI_WARNINGS ON');
    Memo1.Lines.Add('COMMIT');
    Memo1.Lines.Add('BEGIN TRANSACTION');
    Memo1.Lines.Add('USE '+Database);
    Memo1.Lines.Add('CREATE TABLE dbo.Tmp_'+TabloAdi);
    Memo1.Lines.Add('(');
    for i := 1 to Grid1.RowCount-1 do begin
       s := Grid1.Cells[1,i]+' '+Grid1.Cells[2,i];
       if Grid1.Cells[2,i] = 'varchar' then
          s :=s+'('+Grid1.Cells[3,i]+') '; //length
       if Grid1.Cells[4,i] = 'NO' then
          s := s+' NOT ';
       s := s+' NULL ';
       if i < Grid1.RowCount-1 then s:=s+',';
       Memo1.Lines.Add(s);
    end;

    Memo1.Lines.Add(')  ON [PRIMARY]');
    Memo1.Lines.Add('GO');
//    Memo1.Lines.Add('IF EXISTS(SELECT * FROM dbo.'+TabloAdi+')');
    Memo1.Lines.Add('USE '+Database);
    Memo1.Lines.Add('SELECT * FROM dbo.'+TabloAdi);

    s:='';
    for i := 1 to Grid1.RowCount-1 do begin
       s := s+Grid1.Cells[1,i];
       TabAlan.Next;
       if i < Grid1.RowCount-1 then s:=s+',';
    end;
    Memo1.Lines.Add('EXEC(''INSERT INTO dbo.Tmp_'+TabloAdi+' ('+s+') SELECT '+s+' FROM dbo.'+TabloAdi+' TABLOCKX'')');
    Memo1.Lines.Add('GO');
    Memo1.Lines.Add('USE '+Database);
    Memo1.Lines.Add('DROP TABLE dbo.'+TabloAdi);
    Memo1.Lines.Add('GO');
    Memo1.Lines.Add('USE '+Database);
    Memo1.Lines.Add('EXECUTE sp_rename N''dbo.Tmp_'+TabloAdi+''', N'''+TabloAdi+''', ''OBJECT''');
    Memo1.Lines.Add('GO');
    Memo1.Lines.Add('USE '+Database);
    Memo1.Lines.Add('ALTER TABLE dbo.'+TabloAdi+' ADD CONSTRAINT');
    Memo1.Lines.Add('PK_'+TabloAdi+' PRIMARY KEY NONCLUSTERED');
    Memo1.Lines.Add('(DOSYANO,TARIH,SIRANO');
    Memo1.Lines.Add(') ON [PRIMARY]');
    Memo1.Lines.Add('GO');
    Memo1.Lines.Add('COMMIT');
    Tablo.Query1.Sql.AddStrings(Memo1.Lines);
    Tablo.Query1.ExecSQL;
}

{       TabIndex.First; //Ýkincil Ýndexleri ekleyelim
       while not TabIndex.eof do begin
          if pos('unique', TabIndex.FieldByName('INDEX_DESCRIPTION').AsString)=0 then begin
             Index := TabIndex.FieldByName('INDEX_KEYS').AsString;
             Tablo.Query1.SQL.Clear;
             Tablo.Query1.SQL.Add('USE '+Database);
             Tablo.Query1.SQL.Add('CREATE INDEX ['+TabIndex.FieldByName('INDEX_NAME').AsString+'] ON [dbo].['+TabloAdi+'] (');
             while pos(',', Index)>0 do begin
                s:=copy(Index,1,pos(',', Index)-1);
                Delete(Index,1,pos(',', Index)+1);
                Tablo.Query1.SQL.Add('['+s+'],');
             end;
             Tablo.Query1.SQL.Add('['+Index+']');
             Tablo.Query1.SQL.Add(')');
             Tablo.Query1.ExecSQL;
          end;
          TabIndex.next;
       end;
}
