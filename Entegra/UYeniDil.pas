unit UYeniDil;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ComCtrls,
  ToolWin, FireDAC.Comp.Client, cxLookAndFeelPainters, cxContainer, cxGroupBox, StdCtrls,
  Buttons, ExtCtrls, Menus, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxLookAndFeels, cxNavigator;

type
  TYeniDilDlg = class(TForm)
    GridGenIniYeniDil: TcxGrid;
    GridGenIniYeniDilDBTableView1: TcxGridDBTableView;
    GridGenIniYeniDilDBTableView1DEGER: TcxGridDBColumn;
    GridGenIniYeniDilDBTableView1SIRA: TcxGridDBColumn;
    GridGenIniYeniDilDBTableView1BOLUM: TcxGridDBColumn;
    GridGenIniYeniDilLevel1: TcxGridLevel;
    TabDiller: TFDQuery;
    DtsDiller: TDataSource;
    GENINIKullanimdakiDil: TFDQuery;
    GENINITumDiller: TFDQuery;
    Query1: TFDQuery;
    Query2: TFDQuery;
    ToolBarProblem: TToolBar;
    BtnYeni: TToolButton;
    BtnSil: TToolButton;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure DillerKontrolu;
    procedure BtnYeniClick(Sender: TObject);
    function  DilIDsiGetir(DilAdi:string):Integer;
    Function YeniDilEkle : boolean;
    procedure DilKaydet;
    procedure DtsDillerStateChange(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
    procedure TabDillerAfterPost(DataSet: TDataSet);
    procedure BtnSilClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  YeniDilDlg: TYeniDilDlg;

implementation

uses Utablo,FetaKurulusSiniflari,UGirisKutusuEx,Fetautil,UDilDuzenle,UOpsDlg,PrjConst;
{$R *.dfm}

procedure TYeniDilDlg.FormCreate(Sender: TObject);
begin
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TabloYenile(GENINITumDiller,[]);
  TabloYenile(GENINIKullanimdakiDil,[Dil]);
  DillerKontrolu;
end;

procedure TYeniDilDlg.TabDillerAfterPost(DataSet: TDataSet);
begin
DilKaydet;
end;

procedure TYeniDilDlg.DilKaydet;
Var
I:integer;
begin
  if TabDiller.State in [dsEdit,dsInsert] then
    TabDiller.Post;

Query2.SQL.Text:='delete from GENINI where BOLUM = -1';
   for I := 0 to TabDiller.FieldCount - 4 do begin//son iki field anahtar değil.. onlara gitmeye gerek yok!!
      Query2.SQL.Add('insert into GENINI(BOLUM,ANAHTAR,DEGER,DIL,SIRA)'
                +' select '
                +'BOLUM'+',['
                +TabDiller.Fields[i].FieldName+'],'
                +'DEGER,'
                +inttostr(DilIDsiGetir(TabDiller.Fields[i].FieldName))+','
                +'SIRA '
                +'from ##GENINI_'+IntToStr(SPID)+'_  WHERE BOLUM = -1');
    end;
   Query2.ExecSQL;
   ModalResult := mrOk;

end;

function TYeniDilDlg.DilIDsiGetir(DilAdi:string):Integer;
var i:Integer;
begin
  Result := 0;
  for I := 0 to Length(DilAdlari) - 1 do
    if DilAdlari[i]=DilAdi then
      Result := Diller[i];
end;


Function TYeniDilDlg.YeniDilEkle : boolean;
var
ydil,YSQL:string;
YDeger,Ysira,I:integer;
st:TStringList;
begin
st:=TStringList.Create;
 if Tablo.ListedenBilgiGetir('Dil seçimi yapınız.','select ANAHTAR,DEGER,DIL,SIRA from GENINI Where ANAHTAR like ''%<ara>%'' AND BOLUM = '+inttostr(Ops_Desteklenen_Diller),st,[]) = False then begin
  Result:= false;
  Exit;
 end;
  YDil:=st.Strings[0];
   YDeger:=strtoint(st.Strings[1]);
    YSira:=strtoint(st.Strings[3]);
    tablo.TablodanSorguAc(9,'SELECT * FROM GENINI WHERE BOLUM = -1 AND DEGER='+st.Strings[2]+' AND DIL= '+st.Strings[2]);
    if Tablo.Query9.FieldByName('SIRA').AsInteger <> 0 then begin
      ShowMessage(YDil+' Dili önce eklendi.');
      Result:= false;
      Exit;
    end;

    Tablo.TablodanSorguAc(6,'SELECT Adet= count(DEGER) from GENINI WHERE BOLUM= -1 AND  DIL= '+st.Strings[2]);
    for I := 1 to Tablo.Query6.FieldByName('Adet').AsInteger  do begin
    tablo.Query2.SQL.Text:= 'UPDATE GENINI SET SIRA='+ inttostr(I)+' WHERE BOLUM = -1 AND SIRA = 0 AND DIL='+st.Strings[2]+' AND DEGER='+inttostr(I* -1);
     tablo.Query2.SQL.Add ('UPDATE GENINI SET SIRA= '+inttostr(YDeger * -1)+' WHERE BOLUM= -1 AND SIRA = 0 and DEGER ='+st.Strings[2]+' AND DIL='+inttostr(I* -1));
   // tablo.Query2.SQL.Add('UPDATE GENINI SET SIRA= '+inttostr(I)+' WHERE BOLUM = -1 AND DIL='+st.Strings[2]+' AND DEGER='+inttostr(I* -1));
    //tablo.Query2.SQL.Add ('UPDATE   ##GENINI_' + IntToStr(SPID) + '_   SET SIRA= '+inttostr(I)+' WHERE BOLUM= -1  and DEGER ='+st.Strings[2]+' AND DEGER='+inttostr(I* -1));
    Tablo.Query2.ExecSQL;
    end;
    TabloYenile(GENINITumDiller,[]);
    TabloYenile(GENINIKullanimdakiDil,[Dil]);
    OpsiyonDlg.DillerYenile;
     //tablo.Query2.SQL.Text:='UPDATE GENINI SET SIRA= '+Tablo.Query9.FieldByName('DEGER').AsString+' WHERE BOLUM = -1 AND DIL='+st.Strings[2];
    // Tablo.Query2.ExecSQL;

          st.Free;
          result:=True;
end;

procedure TYeniDilDlg.BtnKaydetClick(Sender: TObject);
Var
I:integer;
begin
for I := 0 to GridGenIniYeniDilDBTableView1.ColumnCount - 1 do
    if not BoslukKontrol(GridGenIniYeniDilDBTableView1.Columns[i].EditValue,'Bölüm '+GridGenIniYeniDilDBTableView1.Columns[i].Caption) then
      Abort;
  for I := 0 to GridGenIniYeniDilDBTableView1.ColumnCount - 3 do
    if not BoslukKontrol(GridGenIniYeniDilDBTableView1.Columns[i].EditValue,'Değer '+GridGenIniYeniDilDBTableView1.Columns[i].Caption) then
      Abort;
    DilKaydet;
end;

procedure TYeniDilDlg.BtnSilClick(Sender: TObject);
var
SDil,m:string;
st:TStringList;
begin
st:=TStringList.Create;
 if Tablo.ListedenBilgiGetir('Silinecek dil seçimini yapınız.','select ANAHTAR,DEGER,DIL,SIRA from GENINI Where ANAHTAR like ''%<ara>%''  AND BOLUM = '+inttostr(Ops_Desteklenen_Diller),st,[]) = False then begin
  Exit;
 end;
//Sdil:=GridGenIniYeniDilDBTableView1.DataController.GetItemFieldName(GridGenIniYeniDilDBTableView1.Controller.FocusedColumnIndex);
Sdil:=st.Strings[0];
m:=Sdil+' Dil seçeneğini silmek istediğiinizden emin misiniz?';
  tablo.TablodanSorguAc(9,'SELECT * FROM GENINI WHERE BOLUM = -1 AND DEGER='+st.Strings[2]+' AND DIL= '+st.Strings[2]);
    if Tablo.Query9.FieldByName('SIRA').AsInteger = 0 then begin
      ShowMessage(Sdil+' Dili daha önce silindi.');
      Exit;
    end;

if Application.MessageBox(PChar(m),'Dil Ekranı', MB_YESNO+ MB_ICONQUESTION) = ID_NO then Abort
 else
 begin
  tablo.TablodanSorguAc(8,'SELECT DIL FROM GENINI WHERE  BOLUM= -1 AND ANAHTAR = '+''''+ Sdil+'''');
   tablo.Query4.SQL.Text:='UPDATE GENINI SET SIRA= 0 WHERE BOLUM = -1 AND DIL='+Tablo.Query8.FieldByName('DIL').AsString;
   tablo.Query4.SQL.Add ('UPDATE GENINI SET SIRA= 0 WHERE BOLUM= -1  and DEGER ='+Tablo.Query8.FieldByName('DIL').AsString);
    tablo.Query4.SQL.Add ('UPDATE   ##GENINI_' + IntToStr(SPID) + '_   SET SIRA= 0 WHERE BOLUM= -1  and DEGER ='+Tablo.Query8.FieldByName('DIL').AsString);
  Tablo.Query4.ExecSQL;
 end;
 TabloYenile(GENINITumDiller,[]);
    TabloYenile(GENINIKullanimdakiDil,[Dil]);
    OpsiyonDlg.DillerYenile;
    tablo.Query4.SQL.Text:='UPDATE GENINI SET SIRA= 0 WHERE BOLUM = -1 AND DIL='+Tablo.Query8.FieldByName('DIL').AsString;
    Tablo.Query4.ExecSQL;
end;

procedure TYeniDilDlg.BtnYeniClick(Sender: TObject);
begin
    if YeniDilEkle then
    begin
     TabloYenile(GENINITumDiller,[]);
      TabloYenile(GENINIKullanimdakiDil,[Dil]);
       OpsiyonDlg.DillerYenile;
    end;
end;

procedure TYeniDilDlg.DillerKontrolu;
var
I:integer;
sqltext:string;
begin
TabDiller.Close;
 TabDiller.SQL.Text:='SELECT * FROM ##GENINI_' + IntToStr(SPID) + '_ WHERE BOLUM = -1 AND SIRA <> 0 order by SIRA';
  // TabDiller.ExecSQL;
   // TabDiller.Close;
    // TabDiller.sql.Text := 'select * from ##GENINI_' + IntToStr(SPID) + '_ order by SIRA ';
      TabDiller.Open;
     GridGenIniYeniDilDBTableView1.DataController.CreateAllItems(True);
    for I := 3 to GridGenIniYeniDilDBTableView1.ColumnCount - 1 do
   GridGenIniYeniDilDBTableView1.Columns[i].Index := GridGenIniYeniDilDBTableView1.Columns[i].Index  -3;

   for I :=3  to GridGenIniYeniDilDBTableView1.ColumnCount - 1 do Begin
      Tablo.TablodanSorguAc(5,'SELECT * FROM GENINI WHERE BOLUM= -1 AND DIL='+ inttostr((I-2) * -1)+' AND DEGER = '+inttostr((I-2)* -1));
     if Tablo.Query5.FieldByName('SIRA').AsInteger = 0 then begin
     GridGenIniYeniDilDBTableView1.Columns[i-3].Visible:= false;
     end;
    End;


end;
procedure TYeniDilDlg.DtsDillerStateChange(Sender: TObject);
begin
   BtnYeni.Visible := DtsDiller.State = dsBrowse;
   BtnSil.Visible := (DtsDiller.State=dsBrowse)and(TabDiller.RecordCount>0);
   BtnKaydet.Visible := DtsDiller.State in [dsEdit,dsInsert];
   BtnIptal.Visible := DtsDiller.State in [dsEdit,dsInsert];

end;

end.

