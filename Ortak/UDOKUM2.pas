unit UDokum;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, Db, StdCtrls, Outline, DBCtrls, Grids, DBGrids, Mask, Buttons,
  ExtCtrls, Menus, comctrls;

type
  TDokumDlg = class(TForm)
    ScrollBox1: TScrollBox;
    Label1: TLabel;
    Label2: TLabel;
    Label10: TLabel;
    EditRAPORADI: TDBEdit;
    EditACIKLAMA: TDBEdit;
    DBGrid1: TDBGrid;
    BitBtn1: TBitBtn;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    DokumYapisi: TMenuItem;
    GBox1: TGroupBox;
    DtsDokumler: TDataSource;
    EtiketAyarlar1: TMenuItem;
    ToplamSayi: TCheckBox;
    SpeedButton1: TSpeedButton;
      procedure FormCreate(Sender: TObject);
    function  KomutOlustur : Boolean;
    procedure OKBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure DtsDokumlerStateChange(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure TableAdListesiOlustur;
    procedure DokumYapisiClick(Sender: TObject);
    procedure DtsDokumlerDataChange(Sender: TObject; Field: TField);
    procedure YeniRapor1Click(Sender: TObject);
    procedure RaporuKaydet1Click(Sender: TObject);
    procedure EtiketAyarlar1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Label1DblClick(Sender: TObject);
private
    { Private declarations }
    function FieldListe : String;
    procedure SartlarOlustur;
    procedure ComBoxDropDown(Sender: TObject);
  public
    procedure IlkSayfaYapisiOlustur;
    procedure GenelDokumler_EkranYazici(Sender : TObject);
    { Public declarations }
  end;

var
  DokumDlg: TDokumDlg;

implementation

uses URapSyf, UAyar, UTablo, UTabDok, FetaUtil, UDokSart, UEtiket, Utabrap,
  UEtiAlan, UAnaForm;

var
    EskiRapor, OncekiLabKodu : String[20];
    GroupByList, TableBagList, komut, TableAdlari : TStringList;
    kom : String[100];
    EnBuyukKartNo, i, j : integer;
    Label55 : TLabel;
    ComBox : TComboBox;
    ScrollBox2 : TScrollBox;
    Tut : TComponent;

{$R *.DFM}

procedure TDokumDlg.FormCreate(Sender: TObject);
begin
//   GetDir(0, directory);
//   TabloDokum.TabDokum.DatabaseName := directory;
//   TabloDokum.TabDokum2.DatabaseName := directory;

   TabloDokum.TabDokum.Open;
   TabloDokum.TabDokum2.Open;
   TabloDokum.RaporTabloSec(TabloDokum.TabKosul, DtsDokumler, 'RAPORADI');
   TabloDokum.RaporTabloSec(TabloDokum.TabKosul2, DtsDokumler, 'RAPORADI');
//   TabloDokum.TabKosul.DatabaseName := directory;
//   TabloDokum.TabKosul2.DatabaseName := directory;

//   if TabloDokum.DataDosyaYolu = '' then TabloDokum.DataDosyaYolu := directory;
//   TabloDokum.Table1.Close;
   TabloDokum.Table1.DatabaseName := TabloDokum.DataDosyaYolu;
   TabloDokum.Query1.DatabaseName := TabloDokum.DataDosyaYolu;

   TableAdlari := TStringList.Create;
   GroupByList := TStringlist.Create;
   Komut := TStringlist.Create;
   TableBagList := TStringlist.Create;
   EskiRapor := '';
end;

function TDokumDlg.FieldListe : String;
var sat   : String;
    i,Ind : integer;
    FList : TStringList;
begin
  TableBagList.Clear;
  FList := TStringList.Create;
  FList.Assign(TabloDokum.TabDokum.FieldByName('FIELDLIST'));
  Ind := 0;
  for i := 0 to FList.Count - 1 do begin
      sat := FList.Strings[i];
      Sat := trim(Sat);
      if sat <> '' then begin komut.add(sat + ',');
                              Ind := komut.IndexOf(sat + ',');
                        end;
  end;
  if Ind = 0 then komut.add('*')
  else begin
         sat := komut.Strings[Ind];
         Delete(sat, Pos(',', sat), 1); {ilk virgülü sil}
         komut.Strings[Ind] := sat;
       end;
   FList.Destroy;
end;

function komutsatiri(TabAd, FIELD, EQUAL, VALUE : String ) : Boolean;
var FieldTipi : TFieldType;
    YilS, AyS, GunS, NeTarih : String[25];
begin
   kom := '(';
   if(EQUAL = 'Baþlayan') Or (EQUAL = 'Ýçinde geçen') then
        kom := kom + TabAd + '.' + FIELD + ' LIKE '
   else if EQUAL = 'Gün/Ay' then
        kom := kom + 'EXTRACT(DAY FROM ' + TabAd + '.' + FIELD + ') ='+copy(VALUE,1,Pos('/',VALUE)-1)+
                ' AND EXTRACT(MONTH FROM ' + TabAd + '.' + FIELD + ') ='+copy(VALUE,Pos('/',VALUE)+1,Length(VALUE))
   else
        kom := kom + TabAd + '.' + FIELD + EQUAL;
   TabloDokum.Table1.Close;
   TabloDokum.Table1.TableName := TabAd;
   TabloDokum.Table1.Open;
(*   Table.GetFieldNames(TABLE1Box(Components[ind+1]).Items);*)
   FieldTipi := TabloDokum.Table1.FieldByName(FIELD).DataType;
   TabloDokum.Table1.Close;
   if  (FieldTipi = FtString) Or (FieldTipi = FtMemo) Or (FieldTipi = FtDate)then kom := kom + '"';
   if EQUAL  = 'Ýçinde geçen' then  kom := kom + '%';
   if (FieldTipi = FtDate)or(FieldTipi = FtDateTime) then  begin
      Yils :='';
      GunS  := Copy(VALUE, 1, Pos('/',VALUE)-1);
      Delete(VALUE, 1, Pos('/',VALUE));
      if Pos('/',VALUE)>0 then begin
         AyS := Copy(VALUE, 1, Pos('/',VALUE)-1);
         Delete(VALUE, 1, Pos('/',VALUE));
         YilS := VALUE;
      end
      else AyS := VALUE;
      VALUE := AyS + '/' + GunS + '/' + YilS;
      if (FieldTipi = FtDateTime)then
        if EQUAL = '>' then VALUE := '"'+VALUE + ', 23:59:00"'
        else if EQUAL = '>=' then VALUE := '"'+VALUE + ', 00:00:00"'
        else if EQUAL = '<'  then VALUE := '"'+VALUE + ', 00:00:00"'
        else if EQUAL = '<=' then VALUE := '"'+VALUE + ', 23:59:00"'
        else if EQUAL = '=' then begin
           NeTarih := copy(kom,pos('(',kom)+1,pos('=',kom)-2);
           kom := '(('+NeTarih+'>="'+VALUE + ', 00:00:00")and('+NeTarih+'<="'+VALUE + ', 23:59:00")';
           VALUE := '';
        end
        else if EQUAL = 'Gün/Ay' then VALUE := ''
   end;
   kom := kom + VALUE;
   if (EQUAL  = 'Baþlayan') Or (EQUAL = 'Ýçinde geçen') then kom := kom + '%';
   if  (FieldTipi = FtString) Or (FieldTipi = FtMemo) Or (FieldTipi = FtDate)then kom := kom + '"';
   kom := kom + ')';
   komut.Add(kom);
   komutsatiri := TRUE;
end;

procedure TDokumDlg.TableAdListesiOlustur;
var index1, TabAd, sat : String[100];
    Simge : char;
    i, j, k, IndexAlanSay : Integer;
    FList, IndexList : TStringList;
    bulundu : boolean;
    procedure ListedeYoksaEkle(TabloAd : String);
    begin
      bulundu := false;
      k := 0;
      while (not bulundu)and(k <= TableAdlari.Count-1) do
         if TabloAd = TableAdlari.Strings[k] then
            bulundu := true
         else
            inc(k);
         if not bulundu then
            TableAdlari.Add(TabloAd);
    end;

    function IndexAlanAl(TabloAd:String; IndexAlanSira:integer) : String;
    begin
      TabloDokum.Table1.Close;
      TabloDokum.Table1.TableName := TabloAd;
      TabloDokum.Table1.open;
      TabloDokum.Table1.IndexDefs.Update;
      index1 := TabloDokum.Table1.IndexDefs.Items[0].Fields;
      IndexAlanAl := index1;
      IndexAlanSay := 0;
      while pos(';', index1) > 0 do begin //Ýndex Alan Sayýsýný belirle 'kod;sýrano'
         inc(IndexAlanSay);
         if IndexAlanSira = IndexAlanSay then
            IndexAlanAl := copy(index1, 1, pos(';', index1)-1);
         delete(index1, 1, pos(';', index1));
      end;{while}
    end;
begin
   FList := TStringList.Create;
   IndexList := TStringList.Create;
   TableAdlari.Clear;
   TableBagList.Clear;
   FList.Assign(TabloDokum.TabDokum.FieldByName('FIELDLIST'));
   {Field'lerden Table Adlarý belirlenir}
   TabloDokum.TabKosul.First;
   while not TabloDokum.TabKosul.eof do begin
      ListedeYoksaEkle(TabloDokum.TabKosul.FieldByName('TABLO').AsString);
      TabloDokum.TabKosul.next;
   end;{while}

   for i := 0 to FList.Count - 1 do begin
       sat := FList.Strings[i];
       Sat := Trim(sat);
       while (sat <> '')and(Pos('.', sat)>0) do begin
          TabAd := Copy(sat, 1, Pos('.', sat)-1);
          Delete(sat, 1, Pos('.', sat));
          simge := '.';
          if Rev_Pos(' ', TabAd)<length(tabad) then simge := ' '
          else if Rev_Pos('(', TabAd)<length(tabad) then simge := '('
          else if Rev_Pos('+', TabAd)<length(tabad) then simge := '+';
          if simge <> '.' then Delete(TabAd,1,Rev_Pos(simge, TabAd));
          Trim(TabAd);
          ListedeYoksaEkle(TabAd);
       end;
   end;{for}


   if TableAdlari.Count = 0 then {boþsa}
      TableAdlari.Add('STOK');

   if TableAdlari.Count > 1 then {Tablolar arasýndaki baðý kur}
      for k := 1 to TableAdlari.Count-1 do begin
          TableBagList.Add('('+TableAdlari.Strings[0]+'.'+IndexAlanAl(TableAdlari.Strings[0]+'.db', 1)+'='+
          TableAdlari.Strings[k]+'.'+IndexAlanAl(TableAdlari.Strings[k]+'.db', 1)+')');
          if k < TableAdlari.Count-1 then TableBagList.Add(' AND ');
//    TableBagList.Add('And(Siparis.SiparisNo = '+TabAd+'.SiparisNo)');
   end;

//   if DataDosyaYolu <> '' then
//      for i := 0 to TableAdlari.Count-1 do
//          TableAdlari.Strings[i] := DataDosyaYolu+TableAdlari.Strings[i];

   for i := 0 to TableAdlari.Count-2 do
     TableAdlari.Strings[i] := TableAdlari.Strings[i]+',';

  FList.Destroy;

end;

function TDokumDlg.KomutOlustur : Boolean;
var komutvar : Boolean;
    CInd, SonInd : Integer;
    TabAd, FieldAd, EqAd, ValAd, AndOrAd : String[80];
begin //  ANDOR1 TABLE1, FIELD1, EQUAL1, VALUE1
   komutvar := False;
   komut.add('Select ');
   if TabloDokum.TabDokum.FieldByName('AYNIKAYITLAR').AsString = 'A' then
      komut.add('distinct ');
   if ToplamSayi.Checked then
      komut.add(' count (*) from ')
   else begin
      FieldListe;
      komut.add(' from ');
   end;
   TableAdListesiOlustur;
   komut.AddStrings(TableAdlari);

   if TabloDokum.TabKosul.RecordCount > 0 then begin {koþul var}
      komut.add(' where ');
      TabloDokum.TabKosul.First;
      while not TabloDokum.TabKosul.eof do begin
        if TabloDokum.TabKosul.FieldByName('BAGLAC').AsString = 'VE' then
           komut.add(' AND ')
        else if TabloDokum.TabKosul.FieldByName('BAGLAC').AsString = 'VEYA' then
           komut.add(' OR ');
        TabAd   := TabloDokum.TabKosul.FieldByName('TABLO').AsString;
        FieldAd := TabloDokum.TabKosul.FieldByName('ALAN').AsString;
        EqAd    := TabloDokum.TabKosul.FieldByName('ESITLIK').AsString;
        ValAd   := TabloDokum.TabKosul.FieldByName('DEGER').AsString;
        komutvar:= komutsatiri(TabAd, FieldAd, EqAd, ValAd);
        TabloDokum.TabKosul.next;
      end;
//      komut.Add(')');
   end;{if}
   if (TabloDokum.TabKosul.RecordCount = 0{koþul yoksa})and(TableBagList.Count > 0{birden fazla table varsa})then
       komut.add(' where ')
   else if (TabloDokum.TabKosul.RecordCount > 0{koþul var})and(TableBagList.Count > 0{birden fazla table varsa})then
       komut.add('and');

   komut.AddStrings(TableBagList);

   GroupByList.Assign(TabloDokum.TabDokum.FieldByName('GRUPBY'));
   if GroupByList.Count > 0 then begin
      komut.add('GROUP BY');
      for i := 0 to GroupByList.Count-2 do
         komut.Add(GroupByList.Strings[i]+',');
      komut.Add(GroupByList.Strings[GroupByList.Count-1]);
   end;

   if (not ToplamSayi.Checked)and(TabloDokum.TabDokum.FieldByName('SIRALAMA1').AsString <> '') then
      if TabloDokum.TabDokum.FieldByName('YON1').AsString = '-' then
         komut.Add('ORDER BY '+TabloDokum.TabDokum.FieldByName('SIRALAMA1').AsString+' DESC')
      else
         komut.Add('ORDER BY '+TabloDokum.TabDokum.FieldByName('SIRALAMA1').AsString+' ASC');
   if (not ToplamSayi.Checked)and(TabloDokum.TabDokum.FieldByName('SIRALAMA2').AsString <> '') then
      if TabloDokum.TabDokum.FieldByName('YON1').AsString = '-' then
         komut.Add('ORDER BY '+TabloDokum.TabDokum.FieldByName('SIRALAMA2').AsString+' DESC')
      else
         komut.Add('ORDER BY '+TabloDokum.TabDokum.FieldByName('SIRALAMA2').AsString+' ASC');

   KomutOlustur := true;
//   if Komutvar then komut.add(' AND ')
end;

procedure TDokumDlg.OKBtnClick(Sender: TObject);
begin
  Komut.Clear;
//  TabloDokum.TabDokum.Refresh;
//  DokumSartDlg.TabDokum.FindKey([TabDokum.FieldByName('RAPORADI').AsString]);
  if TabloDokum.TabDokum.FieldByName('SQL').AsString <> '' then begin
     Komut.Assign(TabloDokum.TabDokum.FieldByName('SQL'));
     TabloDokum.Query1.Close;
     TabloDokum.Query1.SQL.Clear;
     TabloDokum.Query1.SQL := Komut;
     TabloDokum.Query1.open;
  end
  else begin
//   i := StrToInt(Copy(TComboBox(Sender).Name, 6,length(TComboBox(Sender).Name)));
   i := 1;
   TabloDokum.TabKosul.First;
   while not TabloDokum.TabKosul.eof do begin
      Tut := ScrollBox2.FindChildControl('Combo'+IntToStr(i));
      If (Tut <> Nil) Then Begin
         TabloDokum.TabKosul.edit;
         TabloDokum.TabKosul.FieldByName('DEGER').AsString := TComBoBox(Tut).Text;
         TabloDokum.TabKosul.post;
         TabloDokum.TabKosul.Next;
      End;
      inc(i, 5);
   end;
//   TabloDokum.Ini.ReadSection(TabloDokum.TabKosul.FieldByName('ALAN').AsString, TComboBox(Sender).Items);
   if KomutOlustur then begin
      TabloDokum.Query1.Close;
      TabloDokum.Query1.SQL.Clear;
      TabloDokum.Query1.SQL := Komut;
      TabloDokum.Query1.open;
   end;
  end;
end;

procedure TDokumDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//   TabloDokum.TabDokum.Close;
   TableAdlari.Free;
   GroupByList.Free;
   Komut.Free;
   TableBagList.Free;
//   Dokum := Nil;
   Action := caFree;
end;

procedure TDokumDlg.FormShow(Sender: TObject);
begin
  TabloDokum.TabDokum.Refresh;
//  EditRAPORADI.Enabled := False;
end;

procedure TDokumDlg.DtsDokumlerStateChange(Sender: TObject);
begin
  if  DtsDokumler.State in [dsEdit, dsInsert] then
      AnaForm.ToolBarNavigator.VisibleButtons := [nbPost, nbCancel]
  else
      AnaForm.ToolBarNavigator.VisibleButtons := [nbFirst,nbPrior,nbNext,nbLast,nbInsert, nbDelete];

//  if DokumSartDlg = nil then exit;
  try
  if  DtsDokumler.State in [dsEdit, dsInsert] then
      DokumSartDlg.DBNavigator.VisibleButtons := [nbPost, nbCancel]
  else
      if DokumSartDlg<> nil then DokumSartDlg.DBNavigator.VisibleButtons := [];
  except
    exit;
  end;
end;

procedure TDokumDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Tablo.F_Tuslari('GenelDokumler', Key, AnaForm.ToolBarNavigator);
end;

procedure TDokumDlg.FormDeactivate(Sender: TObject);
begin
   if DtsDokumler.State in [dsEdit, dsInsert] then
        if MessageDlg('Döküm Ekraný Deðiþti !!! '+#13#10+'Yapýlan Deðiþiklikler Kaydedilsin mi?',
                      mtConfirmation, [mbYes,mbNo], 0) = mrYES then
           AnaForm.ToolBarNavigator.BtnClick(nbPost)
        else
           AnaForm.ToolBarNavigator.BtnClick(nbCancel);
end;

procedure TDokumDlg.IlkSayfaYapisiOlustur;
Var
   Sayac,GlobBandNo,Solyer,K:Integer;
   FList : TStringList;
   AyarAd : String[40];

   Procedure DegerAta(AlanTuru, TabloAd, AlanAdi:String;Sol,Ust:Integer;Boy:Real);
   Begin
      RapTablo.Ayarlar.Append;
      RapTablo.Ayarlar.FieldByName('EKRANADI').AsString := Ayarad;
      RapTablo.Ayarlar.FieldByName('SIRANO').AsInteger:= Sayac;
      RapTablo.Ayarlar.FieldByName('ALANTURU').AsString := ALANTURU;
      RapTablo.Ayarlar.FieldByName('TABLO').AsString := TABLOAD;
      RapTablo.Ayarlar.FieldByName('ALANADI').AsString := ALANADI;
      RapTablo.Ayarlar.FieldByName('SOL').AsInteger := SOL;
      RapTablo.Ayarlar.FieldByName('UST').AsInteger := UST;
      RapTablo.Ayarlar.FieldByName('BOY').AsFloat := BOY;
      If GlobBandNo<>0 Then
         RapTablo.Ayarlar.FieldByName('BANDNO').AsInteger := GlobBandNo;
      If AlanTuru = 'ÇERÇEVE' THEN Begin
         RapTablo.Ayarlar.FieldByName('SOL').AsString := '';
         RapTablo.Ayarlar.FieldByName('UST').AsString := '';
         RapTablo.Ayarlar.FieldByName('BOY').AsString := '';
         RapTablo.Ayarlar.FieldByName('EN').AsString  := '1';
      End;
      RapTablo.Ayarlar.Post;
      Inc(Sayac);
   End;

   Function Noktasiz(Noktali:String):String;
   Var
      Yer:Integer;
   Begin
      Yer:=Pos('.',Noktali);
      If Yer>0 Then
         Delete(Noktali,1,Yer);
      Noktasiz:=Noktali;
   End;

Begin
   Application.CreateForm(TAyarlarDlg, AyarlarDlg);
//   RapTablo.Ayarlar.Open;
//   If RapTablo.Ayarlar.FindKey([TabloDokum.TabDokum.FieldByName('RAPORADI').AsString,10]) Then
//      raise hata.create('Þu anda rapor ayarlarý var. Yeniden oluþturmak istiyorsanýz rapor ayarlarýný silin.');

   AyarAd := TabloDokum.TabDokum.FieldByName('RAPORADI').AsString;
   FList := TStringList.Create;
   FList.Assign(TabloDokum.TabDokum.FieldByName('FIELDLIST'));
   GlobBandNo:=0;
   Sayac:=1;
   DegerAta('SAYFA', 'YAZICI', '(yazýcý ismi)',0,0,0);
   DegerAta('SAYFA', 'BOYUT', 'A4',0,0,0);

   // Yedi tane band ekleniyor
   Sayac:=10;
   DegerAta('BAND', 'SAYFABAÞI', '',0,0,3);
   DegerAta('BAND', 'DETAY', 'SORGU',0,0,0.5);
   DegerAta('BAND', 'SAYFASONU', '',0,0,2);

   Sayac:=20;
   GlobBandNo:=10;
   SolYer:=0;
   DegerAta('SABÝT', '', 'Dr. Ad Soyad',0,0,0);
   For k:=0 To FList.Count-1 Do Begin
      DegerAta('SABÝT', '', Noktasiz(FList.Strings[k]),SolYer,2,0);
      SolYer:=SolYer+3
   End;
   GlobBandNo:=11;
   Sayac:=50;
   SolYer:=0;
   For k:=0 To FList.Count-1 Do Begin
      DegerAta('ALAN', 'SORGU', Noktasiz(FList.Strings[k]),Solyer,0,0);
      SolYer:=SolYer+3
   End;

   GlobBandNo:=12;
   Sayac:=80;
   DegerAta('SABÝT', '', 'SABÝT',0,0,0);
   GlobBandNo:=10;
   DegerAta('ÇERÇEVE', '', '',0,0,0);
   FList.Destroy;
   AyarlarDlg.Destroy;
End;

procedure TDokumDlg.DokumYapisiClick(Sender: TObject);
begin
  Application.CreateForm(TDokumSartDlg, DokumSartDlg);
//  DokumSartDlg.TabDokum.FindKey([TabDokum.FieldByName('RAPORADI').AsString]);
  DokumSartDlg.ShowModal;
  DokumSartDlg.Destroy;
  SartlarOlustur;
end;

procedure TDokumDlg.SartlarOlustur;
   procedure LabelCreate(Ad, Baslik : String; LeftArtis, TopArtis : Integer);
   begin
     with TLabel.Create(Label55) do begin
       Name := Ad;
       Parent := ScrollBox2;
       Caption := Baslik;
       Left := 16 + LeftArtis;
       Top := 10 + TopArtis;
       Height := 17;
       AutoSize:=True;
     end;
   end;
   procedure ComboCreate(Ad, Baslik : String; LeftArtis, TopArtis : Integer);
   begin
     with TComboBox.Create(ComBox) do begin
       Name := Ad;
       Parent := ScrollBox2;
       Text := Baslik;
       Left := 16 + LeftArtis;
       Top := 10 + TopArtis;
       Width := 150;
       Height := 13;
       OnDropDown := ComBoxDropDown
     end;
   end;
begin
//  if EskiRapor = TabloDokum.TabDokum.FieldByName('RAPORADI').AsString then exit;
  EskiRapor := TabloDokum.TabDokum.FieldByName('RAPORADI').AsString;


  if ScrollBox2 <> nil then begin
     ScrollBox2.Free;
//     inherited Destroy;
     ScrollBox2 := nil;
//     Tut := GBox1.FindChildControl('ScrollBox2');
//     Tut.Destroy;
  end;

  ScrollBox2 := TScrollBox.Create(ScrollBox2);
  with ScrollBox2 do begin
     Name := 'ScrollBox2';
     Parent := GBox1;
     Align := alClient;
//     Left := 64;
//     Top := 26;
//     Width := 633;
//     Height := 125;
  end;

{  Tut := ScrollBox2.FindChildControl('Lab1');
  while Tut <> nil do begin
     Tut.Free;
     Tut := ScrollBox2.FindChildControl('Lab2');
  end;}
  i:=1;
 TabloDokum.TabKosul.First;
  while not TabloDokum.TabKosul.eof do begin
    LabelCreate('Lab'+IntToStr(i+1),TabloDokum.TabKosul.FieldByName('BAGLAC').AsString, 0, i*6);
    LabelCreate('Lab'+IntToStr(i+2),TabloDokum.TabKosul.FieldByName('TABLO').AsString, 100, i*6);
    LabelCreate('Lab'+IntToStr(i+3),TabloDokum.TabKosul.FieldByName('ALAN').AsString, 200, i*6);
    LabelCreate('Lab'+IntToStr(i+4),TabloDokum.TabKosul.FieldByName('ESITLIK').AsString, 350, i*6);
    ComboCreate('Combo'+IntToStr(i),TabloDokum.TabKosul.FieldByName('DEGER').AsString, 400, i*6);
    Inc(i, 5);
   TabloDokum.TabKosul.Next;
 end;{while}
end;
{
   LabelBaglac.Caption :=TabloDokum.TabKosul.FieldByName('BAGLAC').AsString;
   LabelTablo.Caption :=TabloDokum.TabKosul.FieldByName('TABLO').AsString;
   LabelAlan.Caption :=TabloDokum.TabKosul.FieldByName('ALAN').AsString;
   LabelEsitlik.Caption :=TabloDokum.TabKosul.FieldByName('ESITLIK').AsString;
   ComboDeger.Text :=TabloDokum.TabKosul.FieldByName('DEGER').AsString;
}

procedure TDokumDlg.DtsDokumlerDataChange(Sender: TObject; Field: TField);
begin
   if TabloDokum.TabKosul.Active then
      SartlarOlustur;
end;

procedure TDokumDlg.ComBoxDropDown(Sender: TObject);
begin
   i := StrToInt(Copy(TComboBox(Sender).Name, 6,length(TComboBox(Sender).Name)));
   j := 1;
  TabloDokum.TabKosul.First;
   while j < i do begin
     TabloDokum.TabKosul.Next;
      inc(j, 5);
   end;
   TabloDokum.Ini.ReadSection(TabloDokum.TabKosul.FieldByName('ALAN').AsString, TComboBox(Sender).Items);
end;

procedure TDokumDlg.YeniRapor1Click(Sender: TObject);
begin
   TabloDokum.TabDokum.Insert;
end;

procedure TDokumDlg.RaporuKaydet1Click(Sender: TObject);
begin
   TabloDokum.TabDokum.Post;
end;

procedure TDokumDlg.EtiketAyarlar1Click(Sender: TObject);
begin
  Application.CreateForm(TEtiketAlanDlg, EtiketAlanDlg);
  EtiketAlanDlg.ShowModal;
  EtiketAlanDlg.Destroy;
end;

procedure TDokumDlg.GenelDokumler_EkranYazici(Sender : TObject);
var AyarTablo : string[20];
begin
   If not TabloDokum.Query1.Active Then
      raise Hata.Create('Önce sonuçlarý listeleyiniz');

   TabloDokum.RaporTabloSec(RapTablo.Kosullar, DtsDokumler, 'RAPORADI');

   if (TabloDokum.TabDokum.FieldByName('DOKUMTIPI').AsString = 'E')or(AnaForm.EkranYaz.Caption = 'Etiket')  then
      AyarTablo := 'Etiket_'
   else
      AyarTablo := TabloDokum.TabDokum.FieldByName('RAPORADI').AsString;

   GlobalQuery := TabloDokum.Query1;
   if TToolButton(Sender).Name = 'EkranYaz' then
      RapSyf.DokumYap(True, AyarTablo)
   else
      RapSyf.DokumYap(False, AyarTablo);
end;

procedure TDokumDlg.SpeedButton1Click(Sender: TObject);
begin
  Application.CreateForm(TEtiket, Etiket);
  Etiket.ShowModal;
  Etiket.Destroy;
end;

procedure TDokumDlg.Label1DblClick(Sender: TObject);
begin
  TabloDokum.TabDokum.Edit;
  TabloDokum.TabDokum.FieldByName('SQL').Assign(Komut);
  TabloDokum.TabDokum.Post;
end;

End.

{
   TabloDokum.TabDokum2.Open;
   TabloDokum.TabKosul2.Open;
   TabloDokum.TabDokum2.Insert;
   TabloDokum.TabDokum2.Fields[0].ASString := YeniEkranAdi;
   for i := 1 to 15 do
     TabloDokum.TabDokum2.Fields[i].AsString := TabloDokum.TabDokum.Fields[i].AsString;
   try
      TabloDokum.TabDokum2.Post;
   except
      TabloDokum.TabDokum2.Cancel;
      showmessage('Bu adla kayýtlý rapora rastlandý!');
      exit;
   end;

   TabloDokum.TabKosul.SetRange([TabloDokum.TabDokum.FieldByName('RAPORADI').ASString, 0],[TabloDokum.TabDokum.FieldByName('RAPORADI').ASString, 999]);
   while not TabloDokum.TabKosul.eof do begin
     TabloDokum.TabKosul2.Insert;
     TabloDokum.TabKosul2.Fields[0].ASString := YeniEkranAdi;
     for i := 1 to 6 do
         TabloDokum.TabKosul2.Fields[i].AsString :=TabloDokum.TabKosul.Fields[i].AsString;
     TabloDokum.TabKosul2.Post;
     TabloDokum.TabKosul.Next;
    end;

    RapTablo.Ayarlar.SetRange([TabloDokum.TabDokum.FieldByName('RAPORADI').ASString, 0],[TabloDokum.TabDokum.FieldByName('RAPORADI').ASString, 999]);
    while not RapTablo.Ayarlar.eof do begin
      RapTablo.Ayarlar2.Insert;
      RapTablo.Ayarlar2.Fields[0].ASString := YeniEkranAdi;
      for i := 1 to 15 do
          RapTablo.Ayarlar2.Fields[i].AsString := RapTablo.Ayarlar.Fields[i].AsString;
      RapTablo.Ayarlar2.Post;
      RapTablo.Ayarlar.Next;
     end;
end;
}
