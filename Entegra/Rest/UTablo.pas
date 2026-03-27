unit UTablo;

interface

uses
  System.SysUtils, System.Classes, Data.DB, FireDAC.Comp.Client, frxClass, frxDBSet,cxDropDownEdit,vcl.dialogs,vcl.forms,
  UGENINIDuzenle, UCombo, cxEditRepositoryItems, cxImageComboBox, Winapi.Windows, IdTCPServer,
  cxEdit, IdContext, IdBaseComponent, IdComponent;

type
  TTablo = class(TDataModule)
    frxDetay: TfrxDBDataset;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    FDCnn: TFDConnection;
    TabBizim: TFDQuery;
    DtsBizim: TDataSource;
    frxMusteri: TfrxDBDataset;
    TabMusteri: TFDQuery;
    frxBizim: TfrxDBDataset;
    TabSevkAdresi: TFDQuery;
    frxFatBasDetay: TfrxDBDataset;
    TabHazirlayanDetay: TFDQuery;
    frxHazirlayanDetay: TfrxDBDataset;
    Query1: TFDQuery;
    Query9: TFDQuery;
    Query2: TFDQuery;
    Query3: TFDQuery;
    cxEditRepository1: TcxEditRepository;
    RepDiller: TcxEditRepositoryImageComboBoxItem;
    RepDilCeviri: TcxEditRepositoryImageComboBoxItem;
    TabFatBas: TFDQuery;
    DtsFatBas: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
     procedure Yazdir(Baslik:string; BaskiTipi:SmallInt);
     procedure YazdirmayaHazirla(AFastReport: TfrxReport);
  public
    { Public declarations }
     GENINI: TGENINIDuzenleDlg;
     Database_Name:string;
     Procedure AdisyonYaz(FatBasId1, Kullanan1 : Integer);
     Procedure HesapYaz(FatBasId1, Kullanan1:Integer);
     function EkranAdiAl: string;
     function TablodanSorguAc(SorguNo: Integer; SQLText: String; HataGoster:boolean=False): Boolean;
     procedure Dilislemleri;
     procedure DilislemleriCeviri;
     function imgComboboxInit(Komut: string): TcxImageComboBoxProperties;
     function ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string):string;
  end;

var
  Tablo: TTablo;
  DokumDegiskenListesi: TStringList;
  Dil, SPID, SubeId: Integer;
  Diller: array of Integer;
  DilAdlari: array of string;
  DillerCeviri: array of Integer;
  DilAdlariCeviri: array of string;
  Kullanan, KullanAdi,strng,ServerAdi,SubeIDYazi : String;

  GenRegIni: TRegIni;
  OzelTarihKullan, BuBilgTarihi, RestartProgram,CokluDilVar : Boolean;
  OzelTarih : TDateTime;
  KategoriBasKodList, SiparisYazdirList, HesapYazdirList :TcxCustomComboBoxProperties;

  procedure TabloYenile(TabloAdi: TFDQuery; p: array of Variant;LocateID:integer=0);
  function BoslukKontrol(KontrolIci, Ad: String): Boolean;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}
uses
    FetaKurulusSiniflari, UFastRap, fetaUtil, prjconst;

var
  FatBasId,  Cagiran, RehberId: Integer; //1:Sat?? 2:Sipari? 3:Transfer  7:yemek butonu

function TTablo.EkranAdiAl: string;
begin
      Result := 'HizliSatisDlg'+IntToStr(Cagiran);
end;

function TTablo.TablodanSorguAc(SorguNo: Integer; SQLText: String; HataGoster:boolean=False): Boolean;
var
  QueryX: TFDQuery;
Begin
  Result := False;
  case SorguNo of
 //   0: QueryX := Query0;
    1: QueryX := Query1;
    2: QueryX := Query2;
    3: QueryX := Query3;
{    4: QueryX := Query4;
    5: QueryX := Query5;
    6: QueryX := Query6;
    7: QueryX := Query7;
    8: QueryX := Query8;  }
    9: QueryX := Query9;
  end;
  QueryX.Close;
  QueryX.SQL.Text := SQLText;
  try
    QueryX.Open;
    Result := True;
  Except
    on E: Exception do
      if HataGoster then
        ShowMessage(E.Message);
  end;
End;

procedure TabloYenile(TabloAdi: TFDQuery; p: array of Variant;LocateID:integer=0);
var
  i: Byte;
  IDField: TField;
  ID: integer;
  AfterScroll : TDataSetNotifyEvent;
begin
  try
    if TabloAdi.State in [dsEdit,dsInsert] then
      TabloAdi.Post;
  finally
    ID := 0;
    AfterScroll := TabloAdi.AfterScroll;
    TabloAdi.AfterScroll := Nil;
    if TabloAdi.Active then begin
      IDField := TabloAdi.FindField('ID');
      if (TabloAdi.RecordCount>0)and(IDField <> nil) then
        ID := IDField.AsInteger;
      TabloAdi.Close;
    end;
    if length(p) > 0 then
      for i := 0 to High(p) do begin
        TabloAdi.Params[i].Value := p[i];
      end;
    TabloAdi.Prepared := True;
    TabloAdi.Open;
    if LocateID<>0 then
      TabloAdi.Locate('ID',LocateID,[])
    else if (IDField <> nil)and(TabloAdi.RecordCount>0)and(ID>0) then
      TabloAdi.Locate('ID',ID,[]);
    if Assigned(AfterScroll) then begin
      TabloAdi.AfterScroll := AfterScroll;
      AfterScroll(TabloAdi);
    end;
  end;
end;

function BoslukKontrol(KontrolIci, Ad: String): Boolean;
Begin
  if KontrolIci = '' then Begin
    Application.MessageBox(PChar(Ad + BosBirakilamaz), PChar(Uyari),  MB_OK + MB_ICONERROR);
    Result := False;
  End else
    Result := True;
end;

function TTablo.imgComboboxInit(Komut: string): TcxImageComboBoxProperties;
var
  i: integer;
  cmblist: TcxImageComboBoxProperties;
begin
  i := 0;
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := Komut;
  Tablo.Query1.Open;
  cmblist := TcxImageComboBoxProperties.Create(Self);
  cmblist.ImmediatePost := True;
  while not Tablo.Query1.Eof do
  begin
    cmblist.Items.Add;
    cmblist.Items[i].Description := Tablo.Query1.Fields[1].AsString;
    cmblist.Items[i].Value := Tablo.Query1.Fields[0].AsString;
    Inc(i);
    Tablo.Query1.Next;
  end;
    Result := cmblist;
end;
procedure TTablo.YazdirmayaHazirla(AFastReport: TfrxReport);
begin
  AFastReport.EnabledDataSets.Clear;
  AFastReport.EnabledDataSets.Add(frxDetay);
  AFastReport.EnabledDataSets.Add(frxFatBasDetay);
  AFastReport.EnabledDataSets.Add(Tablo.frxBizim);
  TabloYenile(TabHazirlayanDetay,[Kullanan]);
  AFastReport.EnabledDataSets.Add(frxHazirlayanDetay);
  TabloYenile(Tablo.TabBizim,[]);
  Tablo.TabMusteri.Close;
  Tablo.TabMusteri.SQL.Text := StringReplace(Tablo.TabBizim.SQL.Text, '-1', IntToStr(RehberId), [rfReplaceAll]);
  Tablo.TabMusteri.Open;
  AFastReport.EnabledDataSets.Add(Tablo.frxMusteri);
end;

procedure TTablo.Yazdir(Baslik:string; BaskiTipi:SmallInt);
//var
//  s: string;
begin
   if DtsDetay.State in [dsInsert,dsEdit] then
       TabDetay.Post;
   //s := YaziciYaz.Caption;
   Delete(Baslik, pos('&',Baslik), 1);
   Application.CreateForm(TFastRaporDlg, FastRaporDlg);
   YazdirmayaHazirla(FastRaporDlg.frxReport1);
   FastRaporDlg.FastRapor(BaskiTipi, EkranAdiAl, Baslik); //EkranAdi
   FastRaporDlg.Destroy;
   FastRaporDlg := nil;
end;

Procedure TTablo.HesapYaz(FatBasId1, Kullanan1:Integer);
var i : smallint;
begin
   FatBasId :=FatBasId1;
   Kullanan:= IntToStr(Kullanan1);

   Query1.Close;
   Query1.SQL.Text:= 'select REHBERID from FATBASLIK where ID='+IntToStr(FatBasId);
   Query1.Open;
   RehberId:= Query1.Fields[0].AsInteger;

   TabDetay.close;
   TabDetay.SQL.Text:= 'select  F.*,AD=S.STOKADI, ACIKLAMA2=ACIKLAMA,BIRIMAD=(select top 1 ANAHTAR from GENINI G where BOLUM=-2702 and G.DEGER=F.BIRIM and DIL=-1)  from FATURA F inner join STOKLAR S on F.URUNID=S.ID '+
                       ' where FATBASID='+IntToStr(FatBasId);
   TabDetay.Open;


   TabloYenile(TabFatBas,[FatBasId]);

   Yazdir(HesapYazdirList.Items[0], 1);
end;


Procedure TTablo.AdisyonYaz(FatBasId1, Kullanan1:Integer);
var i : smallint;
begin
   FatBasId := FatBasId1;
   Kullanan := IntToStr(Kullanan1);

   Query1.Close;
   Query1.SQL.Text:= 'select REHBERID from FATBASLIK where ID='+IntToStr(FatBasId);
   Query1.Open;
   RehberId:= Query1.Fields[0].AsInteger;

   TabloYenile(TabFatBas,[FatBasId]);

   //s?rayla t?m yaz?c?lara bakal?m  mutfak, bar,fastfood gibi
   for i := 0 to SiparisYazdirList.Items.Count - 1 do begin
       TabDetay.close;
       TabDetay.SQL.Text:= 'select F.*,AD=S.STOKADI, ACIKLAMA2=ACIKLAMA,BIRIMAD=(select top 1 ANAHTAR from GENINI G where BOLUM=-2702 and G.DEGER=F.BIRIM and DIL=-1)  from FATURA F inner join STOKLAR S on F.URUNID=S.ID '+
          ' where F.FATBASID= '+IntToStr(FatBasId)+' and F.IZLEME < 2 and CAST(S.KATEGORI AS VARCHAR(10)) '+
          '  in ( SELECT KATEGORI=DEGER  FROM KOSULLAR K inner join DOKUMLER D on K.DOKUMID=D.ID '+
          ' WHERE D.RAPORADI = '''+SiparisYazdirList.Items[i]+''' and D.GRUBU = '''+EkranAdiAl+''') ';
       TabDetay.Open;
       if TabDetay.RecordCount > 0 then
           Yazdir(SiparisYazdirList.Items[i], 1);
   end;

//      showmessage('G?nderim verisi bulunamad?. Ya daha ?nce g?nderilmi?, ya da g?nderim listesinde yok!')
   //yazd?rmadan (mutfaktan) sonra update ile durumu (IZLEME) 2 yap?l?r. Renk i?in
   //Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update ' + AktifFatTabloAdi +' set IZLEME=2' ,[],[]);
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update FATURA set IZLEME=2 where FATBASID='+IntToStr(FatBasId),[],[]);// EskiSiparisID
end;

procedure TTablo.Dilislemleri;
begin
  Dil := StrToIntDef(GenRegIni.RegReadString('DilAyarlari', 'KullanimdakiDil','-1', 'C'), 0);
  TablodanSorguAc(1,'select * from GENINI where  bolum = -1 and DIL=DEGER order by SIRA ');
  CokluDilVar:=False;
  // bunun i?in procedure yap?lacak.
  Query1.FetchAll;
  SetLength(Diller, Query1.RecordCount);
  SetLength(DilAdlari, Query1.RecordCount);
  RepDiller.Properties.Items.Clear;
  Query1.First;
  while not Query1.Eof do begin
    Diller[Query1.RecNo - 1] := Query1.FieldByName('DEGER').AsInteger;
    DilAdlari[Query1.RecNo - 1] := Query1.FieldByName('ANAHTAR').AsString;
    with RepDiller.Properties.Items.Add do begin
      Description := Query1.FieldByName('ANAHTAR').AsString;
      Value := Query1.FieldByName('DEGER').AsInteger;
    end;
    Query1.Next;
  end;
end;

procedure TTablo.DilislemleriCeviri;
begin
  //DilCeviri := StrToIntDef(GenRegIni.RegReadString('DilAyarlari', 'KullanimdakiDil','-1', 'C'), 0);
  TablodanSorguAc(2,'select * from GENINI where bolum = -1013 and DIL=DEGER order by SIRA ');
  // bunun i?in procedure yap?lacak.
  Query2.FetchAll;
  SetLength(DillerCeviri, Query2.RecordCount);
  SetLength(DilAdlariCeviri, Query2.RecordCount);
  RepDilCeviri.Properties.Items.Clear;
  Query2.First;
  while not Query2.Eof do begin
    DillerCeviri[Query2.RecNo - 1] := Query2.FieldByName('DEGER').AsInteger;
    DilAdlariCeviri[Query2.RecNo - 1] := Query2.FieldByName('ANAHTAR').AsString;
    with RepDilCeviri.Properties.Items.Add do begin
      Description := Query2.FieldByName('ANAHTAR').AsString;
      Value := Query2.FieldByName('DEGER').AsInteger;
    end;
    Query2.Next;
  end;
end;

function TTablo.ConnectionStringOlustur(ServerName, UserN, Pass, DBName: string)
  : String;
begin
  Result := 'Provider=SQLOLEDB.1;Password=' + Pass + ';Persist Security Info=True;User ID=' + UserN + ';Initial Catalog=' +
    DBName + ';Data Source=' + ServerName + ';Use Procedure for Prepare=1;Auto Translate=True;Packet Size=8192' +
    ';Application Name=' + Application.Title + ';Workstation ID=' + GetCurrentComputerName +';Use Encryption for Data=False;Tag with column collation when possible=False';
End;

procedure TTablo.DataModuleCreate(Sender: TObject);
begin
    Cagiran := 7; //1:Sat?? 2:Sipari? 3:Transfer  7:yemek butonu
  DokumDegiskenListesi := TStringList.Create;
  { Frameler taraf?ndan kullan?lacak event ba?latmalar? }
   GenRegIni := TRegIni.Create('GENTEGRE2');
   strng := VTSifreKontrolu(GenRegIni, Tablo.FDCnn, False);
   if strng = '' then begin
      RestartProgram := False;
      Application.Terminate;
      Halt
   end else
      ServerAdi := strng;
   Dilislemleri;
   DilislemleriCeviri;

   GENINI := TGENINIDuzenleDlg.Create(Application);
   KategoriBasKodList := TcxCustomComboBoxProperties.Create(nil);
   Tablo.GENINI.ReadSection(Ops_HizliSatisCafeKod, KategoriBasKodList);

   SiparisYazdirList := TcxCustomComboBoxProperties.Create(nil);

   HesapYazdirList := TcxCustomComboBoxProperties.Create(nil);

   //Application.CreateForm(TFastRaporDlg, FastRaporDlg);

//   if ParamStr(1) = '' then
//      Application.MessageBox('Program Parametre tan?m? yap?lmam??, Program kapanacakt?r','H A T A', MB_OK+ MB_ICONERROR )
//   else
//      Tablo.AdisyonYaz(StrToInt(ParamStr(1)),StrToInt(ParamStr(2)));
//   Application.Terminate;
end;

end.








