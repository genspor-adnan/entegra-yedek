unit UDilDuzenle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls,
  ToolWin, FireDAC.Comp.Client, cxLookAndFeelPainters, cxContainer, cxGroupBox, StdCtrls,
  Buttons, ExtCtrls, Menus, cxLookAndFeels, dxSkinsCore, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxNavigator;

type
  TDilDuzenleDlg = class(TForm)
    GridGenIniDiller: TcxGrid;
    GridGenIniDillerDBTableView1: TcxGridDBTableView;
    GridGenIniDillerLevel1: TcxGridLevel;
    TabGenIniDiller: TFDQuery;
    GENINITumDiller: TFDQuery;
    GENINIKullanimdakiDil: TFDQuery;
    DtsGenIniDiller: TDataSource;
    ToolBarProblem: TToolBar;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    TabKomutCalistir: TFDQuery;
    TabTumDillerKontrol: TFDQuery;
    Query1: TFDQuery;
    Panel1: TPanel;
    KaydetTus: TBitBtn;
    IptalTus: TBitBtn;
    PopYeniDil: TPopupMenu;
    YeniDilEkle1: TMenuItem;
    Query2: TFDQuery;
    TabBolumler: TFDQuery;
    DtsBolumler: TDataSource;
    GridGenIniDillerDBTableView1SIRA: TcxGridDBColumn;
    GridGenIniDillerDBTableView1DEGER: TcxGridDBColumn;
    GridGenIniDillerDBTableView1BOLUM: TcxGridDBColumn;
    GridGenIniDillerLevel2: TcxGridLevel;
    GridGenIniDillerDBTableView2: TcxGridDBTableView;
    GridGenIniDillerDBTableView2SIRA: TcxGridDBColumn;
    GridGenIniDillerDBTableView2DEGER: TcxGridDBColumn;
    GridGenIniDillerDBTableView2BOLUM: TcxGridDBColumn;
    GridGenIniDillerDBTableView1Grup: TcxGridDBColumn;
    GridGenIniDillerDBTableView2Grup: TcxGridDBColumn;
    procedure GenIniAcDiller;
    procedure FormShow(Sender: TObject);
    procedure TumDillerKontrol;
    procedure BtnKaydetClick(Sender: TObject);
    function  DilIDsiGetir(DilAdi:string):Integer;
    procedure BtnIptalClick(Sender: TObject);
    procedure TabGenIniDillerAfterScroll(DataSet: TDataSet);
    procedure KaydetTusClick(Sender: TObject);
    procedure YeniDilEkle1Click(Sender: TObject);
    procedure YeniDilEkle;
    procedure IptalTusClick(Sender: TObject);
    procedure TabBolumlerAfterScroll(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
   Bolum:Integer;

    { Public declarations }
  end;

var
  DilDuzenleDlg: TDilDuzenleDlg;

implementation
uses Utablo,FetaKurulusSiniflari,UGirisKutusuEx,Fetautil,UYeniDil,UOpsDlg;//,LocOnFly;

{$R *.dfm}

procedure TDilDuzenleDlg.BtnIptalClick(Sender: TObject);
begin
TabGenIniDiller.Cancel;
end;

procedure TDilDuzenleDlg.BtnKaydetClick(Sender: TObject);

begin
  TabGenIniDiller.Post;
end;

function TDilDuzenleDlg.DilIDsiGetir(DilAdi:string):Integer;
var i:Integer;
begin
  Result := 0;
  for I := 0 to Length(DilAdlari) - 1 do
    if DilAdlari[i]=DilAdi then
      Result := Diller[i];
end;


procedure TDilDuzenleDlg.FormCreate(Sender: TObject);
begin
//LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TDilDuzenleDlg.FormShow(Sender: TObject);
begin
  TumDillerKontrol;
  TabloYenile(GENINITumDiller,[]);
  TabloYenile(GENINIKullanimdakiDil,[Dil]);
  GenIniAcDiller;


end;
procedure TDilDuzenleDlg.YeniDilEkle;
var
ydil,YSQL:string;
YDeger,Ysira,I:integer;
begin
YeniDilDlg.Close;
 OpsiyonDlg.DillerYenile;
  Application.CreateForm(TYeniDilDlg,YeniDilDlg);
YeniDilDlg.Show;
end;

procedure TDilDuzenleDlg.GenIniAcDiller;
var
  SQLSubText: string;
  i: Integer;
begin
 Tablo.DilislemleriCeviri;
  TabGenIniDiller.Close;
  TabGenIniDiller.sql.Text := ' IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE name LIKE ''##GENINI_' + IntToStr(SPID) + '_%'') ';
  TabGenIniDiller.sql.Add(' DROP TABLE ##GENINI_' + IntToStr(SPID) + '_ ');
  TabGenIniDiller.sql.Add(' CREATE TABLE ##GENINI_' + IntToStr(SPID) + '_ ( ');
  for I := 0 to Length(DilAdlariCeviri) - 1 do
    TabGenIniDiller.sql.Add(' [' + DilAdlariCeviri[i] + '] nvarchar(50) collate SQL_Latin1_General_CP1254_CI_AS,');
  TabGenIniDiller.sql.Add(' SIRA float, DEGER int,BOLUM int )');
  TabGenIniDiller.ExecSQL;
  TabGenIniDiller.SQL.Clear;
  GENINIKullanimdakiDil.First;
  while not GENINIKullanimdakiDil.Eof do
  begin
    SQLSubText := ' insert into ##GENINI_' + IntToStr(SPID) + '_ (';
    for I := 0 to Length(DilAdlariCeviri) - 1 do
      SQLSubText := SQLSubText + '[' + DilAdlariCeviri[i] + '],';
    SQLSubText := SQLSubText + 'SIRA,DEGER,BOLUM) VALUES (';
    for I := 0 to Length(DillerCeviri) - 1 do
      if GENINITumDiller.Locate('BOLUM;DEGER;DIL', VarArrayOf([GENINIKullanimdakiDil.FieldByName('BOLUM').Value,GENINIKullanimdakiDil.FieldByName('DEGER').Value, DillerCeviri[i]]), []) then
        SQLSubText := SQLSubText + '''' + GENINITumDiller.FieldByName('ANAHTAR').AsString + ''','
      else
        SQLSubText := SQLSubText + ''''',';
    SQLSubText := SQLSubText + VarToStrDef(GENINITumDiller.FieldByName('SIRA').Value, 'null') + ',' + VarToStrDef(GENINIKullanimdakiDil.FieldByName('DEGER').Value, 'null') +','+ VarToStrDef(GENINIKullanimdakiDil.FieldByName('BOLUM').Value, 'null')+')';
    TabGenIniDiller.sql.Add(SQLSubText);
    GENINIKullanimdakiDil.Next;
  end;
  TabGenIniDiller.ExecSQL;
   Tablo.Query6.SQL.Text:='DELETE from ##GENINI_' + IntToStr(SPID) + '_ WHERE BOLUM= -1013';
    Tablo.Query6.ExecSQL;
  TabBolumler.Close;
   TabBolumler.SQL.Text:='select *,GRUP=cast(BOLUM as VARCHAR(10))+''-''+cast(DEGER as VARCHAR(10)) from ##GENINI_' + IntToStr(SPID) + '_ WHERE BOLUM= 0 order by  DEGER  ';
    TabBolumler.Open;
  TabGenIniDiller.Close;
    TabGenIniDiller.sql.Text := 'select  *,GRUP=cast(BOLUM as VARCHAR(10))+''-''+cast(DEGER as VARCHAR(10)) from ##GENINI_' + IntToStr(SPID) + '_ WHERE BOLUM <> 0   order by  BOLUM ';
  TabGenIniDiller.Open;
   GridGenIniDillerDBTableView1.DataController.CreateAllItems(True);
   GridGenIniDillerDBTableView2.DataController.CreateAllItems(True);

    for I := 3 to GridGenIniDillerDBTableView1.ColumnCount - 1 do
     GridGenIniDillerDBTableView1.Columns[i].Index := GridGenIniDillerDBTableView1.Columns[i].Index - 3;

    for I :=3  to GridGenIniDillerDBTableView2.ColumnCount - 1 do
     GridGenIniDillerDBTableView2.Columns[i].Index := GridGenIniDillerDBTableView2.Columns[i].Index - 3;

    for I :=3  to GridGenIniDillerDBTableView1.ColumnCount - 1 do Begin
      Tablo.TablodanSorguAc(4,'SELECT * FROM GENINI WHERE BOLUM= -1 AND DIL='+ inttostr((I-3) * -1)+' AND DEGER = '+inttostr((I-3)* -1));
     if Tablo.Query4.FieldByName('SIRA').AsInteger = 0 then begin
     GridGenIniDillerDBTableView1.Columns[i-3].Visible:= false;
     GridGenIniDillerDBTableView2.Columns[i-3].Visible:= false;
     end;
    End;




end;
procedure TDilDuzenleDlg.IptalTusClick(Sender: TObject);
begin
ModalResult:=mrCancel;
Close;
end;

procedure TDilDuzenleDlg.KaydetTusClick(Sender: TObject);
Var
I:integer;
begin
  if TabGenIniDiller.State in [dsEdit,dsInsert] then
    TabGenIniDiller.Post;

Query1.SQL.Text:='delete from GENINI where DIL<>0 and BOLUM <> -1013';
   for I := 0 to TabGenIniDiller.FieldCount - 4 do begin//son iki field anahtar değil.. onlara gitmeye gerek yok!!
      Query1.SQL.Add('insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)'
                +' select '
                +'BOLUM'+',['
                +TabGenIniDiller.Fields[i].FieldName+'],'
                +'DEGER,'
                +inttostr(DilIDsiGetir(TabGenIniDiller.Fields[i].FieldName))+','
                +'SIRA ' //'ROW_NUMBER() OVER(ORDER BY ['+TabGenIniDiller.Fields[i].FieldName+']) AS [SIRA] '
                +'from ##GENINI_'+IntToStr(SPID)+'_');
    end;
   Query1.ExecSQL;

   ModalResult := mrOk;
end;

procedure TDilDuzenleDlg.TabBolumlerAfterScroll(DataSet: TDataSet);
var
i:integer;
begin
 for I := 0 to GridGenIniDillerDBTableView2.ColumnCount - 1 do
      GridGenIniDillerDBTableView2.Columns[i].Options.Editing:=True;
end;

procedure TDilDuzenleDlg.TabGenIniDillerAfterScroll(DataSet: TDataSet);
var
i:integer;
begin
   for I := 0 to GridGenIniDillerDBTableView1.ColumnCount - 1 do
      GridGenIniDillerDBTableView1.Columns[i].Options.Editing:=True;

end;

procedure TDilDuzenleDlg.TumDillerKontrol;
var
i: Integer;
begin
   for I := 0 to Length(DillerCeviri) - 1 do
    if DillerCeviri[i] <> -1 then // türkçe haricinde dillerin kontrolu yapılıyor boş içerik dolduruluyor
     begin
      TabKomutCalistir.SQL.Text:='INSERT INTO GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA) '+
                                  'select    BOLUM,ANAHTAR,DEGER,'+inttostr(DillerCeviri[i])+',SIRA  from GENINI G '+
                                   'where G.DIL=-1 and BOLUM <> -1013 and cast(G.BOLUM as varchar(20))+cast(G.DEGER as varchar(20)) not in( '+
                                    'SELECT cast(G1.BOLUM as varchar(20))+cast(G1.DEGER as varchar(20)) '+
                                     'FROM GENINI G1 '+
                                      'inner join GENINI G2 on G1.BOLUM=G2.BOLUM and G1.DEGER=G2.DEGER '+
                                       'WHERE '+
                                        'G1.DIL=-1 and G2.DIL='+inttostr(DillerCeviri[i])+')';
      TabKomutCalistir.ExecSQL;
     end;


end;
procedure TDilDuzenleDlg.YeniDilEkle1Click(Sender: TObject);
begin
//YeniDilEkle;
Application.CreateForm(TYeniDilDlg,YeniDilDlg);
YeniDilDlg.Show;
end;

end.


