unit UUcrAra;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms,
  Buttons, Db, DBTables, Grids, DBGrids, StdCtrls, ExtCtrls, ComCtrls, ToolWin, DBCtrls,
  Spin, Menus, UFDCompatHelpers, Dialogs;

type
  TUcretAraDlg = class(TForm)
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    AraKod: TEdit;
    AraStokAdi: TEdit;
    Label1: TLabel;
    LabelAdi: TLabel;
    ComboBirim: TComboBox;
    LabelBirim: TLabel;
    DataSource1: TDataSource;
    TreeMua: TTreeView;
    TreeLab: TTreeView;
    TreeTed: TTreeView;
    TreeSto: TTreeView;
    TreeEcz: TTreeView;
    TreeDig: TTreeView;
    QueryIslem: TADOQuery;
    Label4: TLabel;
    PanelHesap: TPanel;
    DBGrid2: TDBGrid;
    TabHesapla: TADOQuery;
    DtsHesapla: TDataSource;
    TabHesaplaSIRANO: TSmallintField;
    TabHesaplaKOD: TStringField;
    TabHesaplaACIKLAMA: TStringField;
    TabHesaplaADET: TSmallintField;
    TabHesaplaISKONTO: TFloatField;
    TabHesaplaKULLANICI: TStringField;
    QueryPaket: TADOQuery;
    TabHesaplaTUR: TStringField;
    ComboYer: TComboBox;
    LabelYer: TLabel;
    Adet: TEdit;
    UpDown1: TUpDown;
    PopupUcret: TPopupMenu;
    Y00: TMenuItem;
    Y10: TMenuItem;
    Y15: TMenuItem;
    Y20: TMenuItem;
    Y25: TMenuItem;
    Y30: TMenuItem;
    Y35: TMenuItem;
    Y40: TMenuItem;
    Y45: TMenuItem;
    Ozel: TMenuItem;
    HepsiniSil1: TMenuItem;
    N1: TMenuItem;
    LabelButceKodu: TLabel;
    AraButceKodu: TEdit;
    Label2: TLabel;
    ComboDOKTOR: TEdit;
    ComboPol: TEdit;
    Label3: TLabel;
    LabelDoktorKod: TLabel;
    DoktorSecTus: TButton;
    ToolBar1: TToolBar;
    ListeTus: TToolButton;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    AgacTus: TToolButton;
    ToolBar2: TToolBar;
    KapatTus: TToolButton;
    EkleTus: TToolButton;
    TabHesaplaBIRIM: TStringField;
    Panel3: TPanel;
    Panel4: TPanel;
    LabelPOLIKLINIK: TLabel;
    LabelDOKTOR: TLabel;
    LabelKURUM: TLabel;
    SilTus: TSpeedButton;
    ComboKurum: TComboBox;
    NavUcrAra: TDBNavigator;
    ToolBar3: TToolBar;
    EkranYaz: TToolButton;
    YaziciYaz: TToolButton;
    KimlikEkleTus: TToolButton;
    GelisEkleTus: TToolButton;
    LabelToplam: TLabel;
    LabelBirimToplam: TLabel;
    ToolButton2: TToolButton;
    TabHesaplaBIRIMFIYAT: TBCDField;
    TabHesaplaTUTAR: TBCDField;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Label5: TLabel;
    PopupMenu1: TPopupMenu;
    IsleminUcretiniSorMenu: TMenuItem;
    ExceleGnder1: TMenuItem;
    N2: TMenuItem;
    LabelKatkiToplam: TLabel;
    ComboKesYuzde: TComboBox;
    Label7: TLabel;
    ComboKesAcik: TComboBox;
    Label8: TLabel;
    CheckAcil: TCheckBox;
    Label6: TLabel;
    Shape1: TShape;
    Shape2: TShape;
    procedure EkleTusClick(Sender: TObject);
    procedure AgacTusClick(Sender: TObject);
    procedure TreeDigDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AgacTusMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure TabHesaplaAfterPost(DataSet: TDataSet);
    procedure SilTusClick(Sender: TObject);
    procedure ComboKurumChange(Sender: TObject);
    procedure KimlikEkleTusClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboYerChange(Sender: TObject);
    procedure ListeTusClick(Sender: TObject);
    procedure TabHesaplaNewRecord(DataSet: TDataSet);
    procedure TabHesaplaBeforeEdit(DataSet: TDataSet);
    procedure Y00Click(Sender: TObject);
    procedure TabHesaplaADETChange(Sender: TField);
    procedure QueryIslemAfterScroll(DataSet: TDataSet);
    procedure DoktorSecTusClick(Sender: TObject);
    procedure ComboPolExit(Sender: TObject);
    procedure GelisEkleTusClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AraKodKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DBGrid2DblClick(Sender: TObject);
    procedure YaziciYazMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RadioButton1Click(Sender: TObject);
    procedure IsleminUcretiniSorMenuClick(Sender: TObject);
    procedure ExceleGnder1Click(Sender: TObject);
    procedure AraKodKeyPress(Sender: TObject; var Key: Char);
  private
    { private declarations }
    TutAranan : TEdit;
    procedure GelisEkle(PNO:String);
    procedure HesapUcretSatirDoldur;
    procedure KatkiPayiEkle(Tab1 :  tdataset);
    function FisBilgisi : Boolean;
 public
    { public declarations }
    Depo, OzKodu : String;
    Iskon : real;
    Cagiran, DigitSay : integer;
    CagTabloAdi:TADOQuery;
    SonListeFiyatAdi, SonAgacFiyatAdi,AnaKod,SonNo, DR2,SKT, PolSiraNo : String[30];
    procedure AraBul(TabloAdi, Kod, Ad, Grup : String);
    procedure FiyatDegistir;
    procedure UcretEkleme(Table1 : tdataset; Kodu, Turu,DoktorKodu : String);
    function DahaOnceEklenmediKontrolu(Kod:string):boolean;
    procedure FaturaUcretSatirDoldur;
    function Paket_Kontrolu(OprTuru:String): Boolean;
  end;

var
  UcretAraDlg: TUcretAraDlg;
  KurumKDVDurum, FiyatAdTut:String[30];

implementation

uses UTablo, FetaUtil, UCombo, umESAJ, UParaBilgi, Udoktor, UTetkik,
     Udokhak, TDetay, Utabrap, UDokum, UAyar, UTabDok, UListe, UGelis,
  UPaketKart, UVeriMotor;

{$R *.DFM}

var
   s, st : String;
   Kod  : String[35];
   UcrTutar, Tutar, AlinanFiyat : Currency;
   PaketNO, j : Smallint;
   YeniKayit, DoktorSor, FisBilgisiAl,YerineKodVarKontrolu, PaketYuzde, FiyatGoster, IslemdensonraKapat, KurumIskeBak: Boolean;
   stlist : Tstringlist;
   FisTuru, FisNo : String;

procedure TUcretAraDlg.FormCreate(Sender: TObject);
var Dirctory : string;
   procedure doldur(alan, table1:String; Combo1:TComboBox);
   begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select '+alan+' from '+table1 +' order by '+alan;
      Tablo.Query1.Open;
      Combo1.Items.Add('');
      while not Tablo.Query1.eof do begin
         Combo1.Items.Add(Tablo.Query1.Fields[0].AsString);
         Tablo.Query1.next;
      end;
   end;
begin
   PaketNo := -1;
   FiyatAdi := 'x!';
   SonListeFiyatAdi := '';
   TutAranan := AraStokAdi;
   GetDir(0, Dirctory);
   AlinanFiyat := -1;
   YerineKodVarKontrolu := GenotipIni.ReadBool('GenelOpsiyon', 'YerineKodVarKontrolu', False);
   Dirctory := copy(Dirctory, 1, RevPos('\', Dirctory));
   TabHesapla.Close;
   TabHesapla.Parameters[0].Value:= Kullanan;
   TabHesapla.Open;

   FiyatGoster := GenotipIni.ReadBool('GenelOpsiyon', 'FIYATGÖR', False);
   if FiyatGoster then begin
      DBGrid1.Columns[7].Visible := True;
      DBGrid1.Columns[7].Width:= 40;
   end;

   IslemdensonraKapat := GenotipIni.ReadBool('GenelOpsiyon', 'IslemdensonraKapat', False);

   KurumIskeBak := GenotipIni.ReadBool('GenelOpsiyon', 'KurumIskFiyat', False);

   doldur('KURUM','KURUM where DURUM<>''Pasif''', ComboKurum);

   ComboKurum.ItemIndex := ComboKurum.Items.IndexOf(VarsayKurum);

   RadioButton1.Checked := GenotipIni.ReadBool('GenelOpsiyon', 'UcretAdSeçimi', True);

   DoktorSor := GenotipIni.ReadBool('GenelOpsiyon', 'DoktorSor', False);
   FisBilgisiAl := GenotipIni.ReadBool('GenelOpsiyon', 'FisBilgisiSor', False);

   if Resmi then begin
      LabelButceKodu.Visible := True;
      AraButceKodu.Visible := True;

      AraStokAdi.Left := 181;
      AraStokAdi.Width := 217;
      LabelAdi.Left := 181;
      DBGrid1.Columns[1].Visible := True;
      DBGrid1.Columns[1].Width:= 64;
   end;

   if (StokVar)or(EczaneVar) then begin
      LabelBirim.Visible := True;
      LabelYer.Visible := True;
      ComboBirim.Visible := True;
      ComboYer.Visible := True;

      Tablo.Query4.Close;
      Tablo.Query4.SQL.Text:= 'SELECT ID, TUR FROM STOKKULLANICI WHERE KULLANICI ='''+Sube+ ''' or KULLANICI ='''+KullanAdi+'''  ORDER BY TUR ';
      Tablo.Query4.Open;
      if not Tablo.Query4.IsEmpty then begin
         Tablo.Query5.Close;
         Tablo.Query5.SQL.Text:= 'SELECT DEPO FROM STOKKULLANICIDEPO WHERE KULLANICIID='+Tablo.Query4.Fields[0].AsString+' AND '+
                               '  TUR = ''Çıkış'' and ISNULL(CIKISLISTE,'''')=''T'' ORDER BY 1 ';
         Tablo.Query5.Open;
         if not Tablo.Query5.IsEmpty then
           while not Tablo.Query5.eof do begin
             ComboYer.Items.Add(Tablo.Query5.Fields[0].AsString);
             Tablo.Query5.next;
           end
      end
      else
        GenotipIni.ReadSection('StokCikisYeri', ComboYer.Items);
      GenotipIni.ReadSection('ANABIRIM', ComboBirim.Items);
      ComboBirim.ItemIndex := 0;
      ComboYer.ItemIndex := 0;
      DBGrid1.Columns[4].Visible := True;
      DBGrid1.Columns[5].Visible := True;
      DBGrid1.Columns[6].Visible := True;
      DBGrid1.Columns[2].Width:= 230;
      DBGrid1.Columns[4].Width:= 70;
      DBGrid1.Columns[5].Width:= 45;
      DBGrid1.Columns[6].Width:= 64;
   end;
end;

procedure TUcretAraDlg.AraBul;
var Brkd, FiyatG:String;
    st2,stx:String;
begin
   if FiyatAdTut='' then exit;
   s := '';
   if AraStokAdi.Text <> '' then begin
      if RadioButton1.Checked then
         s:=' and ISLEMADI LIKE '''+AraStokAdi.Text+'%'' '
      else
         s:=' and ISLEMADI LIKE ''%'+AraStokAdi.Text+'%'' ';
      TutAranan := AraStokAdi;
   end else if AraButceKodu.Text <> '' then begin
      s:=' and ISLEMLER.ButceKodu LIKE '''+AraButceKodu.Text+'%'' ';
      TutAranan := AraButceKodu;
   end else if AraKod.Text <> '' then begin
      s:=' and ISLEMLER.KOD LIKE '''+AraKOD.Text+'%''';
      TutAranan := AraKod;
   end;
                                           //varchar(8) ', convert(money,KATSAYI*isnull(CARPAN,1.0))+isnull(SEC,'''') AS FIYAT '
   if FiyatGoster then FiyatG :=', convert(varchar(18), convert(money, KATSAYI*isnull(CARPAN,1.0)))+isnull(SEC,'''')AS FIYAT  '
   else FiyatG:='';

   QueryIslem.Close;
   QueryIslem.SQL.Text := 'Select ISLEMLER.KOD,ISLEMLER.ButceKodu,ISLEMADI AS AD, TUR, '+
           'cast(''01'+dateseparator+'01'+dateseparator+'1900'' as DATETIME) as SKT, CAST(0 AS DOUBLE PRECISION) AS ADET, '+
           'CAST('''' AS VARCHAR(8)) as ANABIRIM'+FiyatG+' From ISLEMLER,FIYATLAR'+
           ' where FIYATLAR.KOD='+TabloAdi+'.KOD and'+
           ' (FIYATLAR.FIYATADI = '''+FiyatAdTut+'''';
   if KurumIskeBak then QueryIslem.SQL.Add(' or  FIYATLAR.FIYATADI =( select '+DbUst(1)+'FIYAT from KURUMISK where KURUM='''+ //Kastamonu için eklendi...
                                 Tablo.TabGelisler.FieldByName('KURUM').AsString+''' and charindex(KURUMISK.KOD,ISLEMLER.KOD)=1 '+DbSinir(1)+') ');
   QueryIslem.SQL.Add(' ) ');

   if not UcretDuzenleme then
      QueryIslem.SQL.Add(' and FIYAT_LISTE=''E'' ');
   QueryIslem.SQL.Add(s);


   if StokVar then begin
      if FiyatGoster then FiyatG :=',convert(varchar(8),FIYAT)'
      else FiyatG:='';

      st := '';
      if AraStokAdi.Text <> '' then begin
           st:=' and (STOKKART.STOKADI LIKE '''+AraStokAdi.Text+'%'' or BARKOD='''+AraStokAdi.Text+''')';
           Brkd := AraStokAdi.Text;
      end else if AraButceKodu.Text <> '' then begin
           st:=' and (STOKKART.ButceKodu LIKE '''+AraButceKodu.Text+'%'' or BARKOD='''+AraButceKodu.Text+''')';
           Brkd := AraButceKodu.Text;
      end else begin
           st:=' and (STOKKART.KOD LIKE '''+AraKOD.Text+'%'' or BARKOD='''+ AraKOD.Text+''')';
           Brkd := AraKOD.Text;
      end;

      stx:=' and 1 = case when not exists (select * from STOKFIYAT SF '+
                                 ' WHERE sf.kod = STOKKART.kod and '+
                                 ' SF.FIYATADI = '''+FiyatAdTut+''' ) '+
                                 ' THEN CASE WHEN STOKFIYAT.FIYATADI ='''' THEN 1 '+
                                 ' ELSE 0 END ELSE 0 END ';

      if StokKontrol then begin
          st2:= ' Union ALL Select STOKKART.KOD, ButceKodu, STOKADI AS AD, cast(''STOK'' as varchar(5)) AS TUR,SKT, KALAN AS ADET,ANABIRIM'+FiyatG+' From STOKKART, STOKFIYAT, STOKDURUM'+
           ' where STOKKART.KOD = STOKFIYAT.KOD and STOKKART.KOD = STOKDURUM.KOD and STOKDURUM.YER = '''+ComboYer.Items[ComboYer.ItemIndex]+''''+
           ' and STOKDURUM.KALAN>0.0 '+ st;
         QueryIslem.SQL.Text := QueryIslem.SQL.Text + St2 + ' and FIYATADI = '''+FiyatAdTut+''' '+St2+stx
      end else begin
           st2 := ' Union ALL Select STOKKART.KOD, ButceKodu, STOKADI AS AD, cast(''STOK'' as varchar(5)) AS TUR,cast(''01'+dateseparator+'01'+dateseparator+'1900'' as datetime) as SKT, 0 AS ADET, ANABIRIM'+FiyatG+' From STOKKART, STOKFIYAT'+
           ' where STOKKART.KOD = STOKFIYAT.KOD  '+ st;
         QueryIslem.SQL.Text := QueryIslem.SQL.Text + st2  +' and FIYATADI = '''+FiyatAdTut+''' '+St2+stx
      end;
   end;
{   if EczaneVar then begin
      if FiyatGoster then FiyatG :=',FIYAT'
      else FiyatG:='';

      st := '';
      if AraStokAdi.Text <> '' then
           st:=' and ECZKART.ILACADI LIKE '''+AraStokAdi.Text+'%'' '
      else if AraButceKodu.Text <> '' then
           st:=' and ECZKART.ButceKodu LIKE '''+AraButceKodu.Text+'%'''
      else
           st:=' and ECZKART.KOD LIKE '''+AraKOD.Text+'%''';

      QueryIslem.SQL.Text := QueryIslem.SQL.Text +
           ' Union ALL Select ECZKART.KOD, ButceKodu, ILACADI AS AD, cast(''ECZ'' as varchar(5)) AS TUR,SKT, KALAN AS ADET,ANABIRIM From ECZKART, ECZFIYAT, STOKDURUM'+
           ' where ECZKART.KOD = ECZFIYAT.KOD and ECZKART.KOD = STOKDURUM.KOD and STOKDURUM.YER = '''+ComboYer.Items[ComboYer.ItemIndex]+''''+ st;
   end;}

   QueryIslem.Close;
   if AraStokAdi.Text <> '' then
      QueryIslem.SQL.Text := QueryIslem.SQL.Text + ' Order by ISLEMADI'
   else if AraButceKodu.Text <> '' then
      QueryIslem.SQL.Text := QueryIslem.SQL.Text + ' Order by ISLEMLER.ButceKodu'
   else
      QueryIslem.SQL.Text := QueryIslem.SQL.Text + ' Order by ISLEMLER.KOD';
   QueryIslem.open;
end;


procedure TUcretAraDlg.ComboYerChange(Sender: TObject);
begin
   AraBul('ISLEMLER', 'KOD', 'ISLEMADI', 'GRUP')
end;

procedure TUcretAraDlg.KatkiPayiEkle(Tab1 : tdataset);
var Ad, Tur, Birim, Grup, OzelKod, ButceKodu, Dr, MuhKodu,s: String;
    KDV : Integer;
    Isk : Real;
    Birimfiyat, DoktorPayi:Currency;
    tar : TDateTime;
begin
   Birim := Tab1.FieldByName('BIRIM').AsString;
//   Dr := Tablo.TabGelisler.FieldByName('DOKTORKOD').AsString;
   Dr := LabelDoktorKod.Caption;
   if Tab1=Tablo.TabPara then
      tar := Tab1.FieldByName('TARIH').AsDateTime
   else
      tar := GenotipINI.BugunTrh;

   s := Tab1.FieldByName('KOD').AsString;
   if s='' then exit;
   if s[length(s)-1]= 'K' then
      s := copy(s,1,length(s)-1);

   Tur := Tab1.FieldByName('TUR').AsString;

   KatkiBilgiGetir(s, Tur, Ad, Dr,Birim, OzelKod, ButceKodu, MuhKodu,Grup, tar, KDV, Isk, Birimfiyat, Tablo.TabGelisler.FieldByName('KURUM').AsString,Tablo.TabGelisler.FieldByName('KDVDURUM').AsString,True);
   if Birimfiyat>0.01 then begin
      Tablo.TabPara.Append;
      Tablo.TabParaKOD.AsString := s+'K';
      Tablo.TabParaTUR.AsString := Tur; //'KATKI';
      Tablo.TabParaACIKLAMA.AsString := Ad;
      Tablo.TabParaDR.AsString := Dr;
      Tablo.TabParaDR2.AsString := UcretAraDlg.DR2;
      Tablo.TabParaADET.AsString := Adet.Text;
      Tablo.TabParaOZELKOD.AsString := OzelKod;
      Tablo.TabParaBUTCEKODU.AsString := ButceKodu;
      Tablo.TabParaMUHKODU.AsString := MuhKodu;
      Tablo.TabParaBIRIMFIYAT.AsCurrency:= Birimfiyat;
      Tablo.TabParaKDV.AsInteger := KDV;
      Tablo.TabParaISKONTO.AsFloat := 0;
      Tablo.TabParaBIRIM.AsString := Birim;
      Tablo.TabPara.Post;
   end;
end;

procedure TUcretAraDlg.UcretEkleme(Table1 : tdataset; Kodu, Turu,DoktorKodu : String);
     procedure Ekleme;
     begin
      if Table1.State in [dsBrowse] then
         Table1.Append;
    //        Tablo.TabParaYER.Value := ComboDepo.Text; //
      Table1.FieldByName('ADET').AsFloat := StrToFloat(Adet.Text);
      Table1.FieldByName('TUR').AsString := Turu;
      if ((StokVar)or(EczaneVar))and(Table1 = Tablo.TabPara)and((Turu='STOK')or(Turu='ECZ')or(Turu='STBAĞ')) then begin
         Table1.FieldByName('SKT').AsString := DBGrid1.Fields[4].AsString;
         Table1.FieldByName('BIRIM').AsString := ComboBirim.Items[ComboBirim.ItemIndex];
         Table1.FieldByName('YER').AsString := ComboYer.Items[ComboYer.ItemIndex];
      end;
      Table1.FieldByName('KOD').AsString := Kodu;
      if Table1 = TabHesapla then
         HesapUcretSatirDoldur
      else if Table1 = Tablo.TabFatura then
         FaturaUcretSatirDoldur
      else if (PaketKartDlg<>nil)and(Table1 = PaketKartDlg.TabPaketPara) then
         Tablo.UcretSatirDoldur(PaketKartDlg.TabPaketPara, '', AlinanFiyat)
      else begin
//         Tablo.Query5.SQL.Text := 'Insert Into LOG (TARIH, DOSYANO, ADSOYAD)values('''+FORMATDATETIME('MM/DD/YYYY hh:nn:ss',GenotipINI.BugunTrh)+''','''+Tablo.TabKimlik.FieldByName('DOSYANO').AsString+''','''+DoktorKodu+''')';
//         Tablo.Query5.eXECSQL;

         if UcretDuzenleme then begin
            Tablo.TabParaDR2.AsString := DR2;
            Tablo.TabParaSKT.AsString := SKT;
            if SIRANOVer then
               Tablo.TabPara.FieldByName('POLSIRANO').AsString := UcretAraDlg.PolSiraNo;
         end;
         Tablo.UcretSatirDoldur(Tablo.TabPara, DoktorKodu, AlinanFiyat);
          if (FisBilgisiAl)and(Tablo.TabGelisler.FieldByName('TEDAVI').AsString='Ayakta') then begin
             Tablo.TabParaOZELKOD.AsString := FisTuru;
             Tablo.TabParaMUHKODU.AsString := FisNo;
          end;
      end;

      if (PaketNO>-1) then begin //paket işlemse
         if Iskon>-2 then
            if PaketYuzde then
               Table1.FieldByName('BIRIMFIYAT').AsFloat := (100.0-Iskon)*Table1.FieldByName('BIRIMFIYAT').AsFloat/100.0
            else
               Table1.FieldByName('BIRIMFIYAT').AsFloat := Iskon;
         Table1.FieldByName('PAKETNO').AsFloat := PaketNO;
         if OzKodu<>'' then
            Table1.FieldByName('ADET').AsString := OzKodu;
      end;
      Table1.Post;
      Table1.Last;
      UcrTutar := UcrTutar + Table1.FieldByName('TUTAR').AsCurrency*(100-Table1.FieldByName('ISKONTO').AsCurrency)/100;
      AraStokAdi.Text := '';
      AraButceKodu.Text := '';
      AraKod.Text := '';
      if not TutAranan.Enabled then
         TutAranan.SetFocus;
     end;

     procedure HesaplaKatkiPayiEkle;
      var Ad, Tur, Birim, Grup, OzelKod, ButceKodu, Dr, MuhKodu: String;
          KDV : Integer;
          Isk : Real;
          Birimfiyat, DoktorPayi:Currency;
      begin
         Birim := '';
         Dr := '';
         KatkiBilgiGetir(TabHesaplaKOD.AsString, TabHesaplaTUR.AsString, Ad, Dr,Birim, OzelKod, ButceKodu, MuhKodu,Grup, GenotipINI.BugunTrh, KDV, Isk, Birimfiyat, ComboKURUM.Text,'Dahil',True);
         if Birimfiyat>0.01 then begin
            TabHesapla.Append;
            TabHesaplaKOD.AsString := Kodu+'K';
            TabHesaplaTUR.AsString := 'KATKI';
            TabHesaplaADET.AsString := Adet.Text;
            TabHesaplaACIKLAMA.AsString := Ad;
            TabHesaplaBIRIMFIYAT.AsCurrency:= Birimfiyat;
            TabHesaplaISKONTO.AsFloat := 0;
            TabHesapla.Post;
         end;
     end;

     procedure TTBBirimOlustur(Fiyat, Kod : String; Birim, Carpan : Real);
     var i:smallint;
        Br,Fiy : Currency;
       procedure ParaEkle(Kodu,Acik,Birimi:String;bf:currency);
       begin
           Tablo.TabPara.Append;
           Tablo.TabPara.FieldByName('KOD').AsString := Kodu;
           Tablo.TabPara.FieldByName('TUR').AsString := 'OPR';
           Tablo.TabPara.FieldByName('ACIKLAMA').AsString := Acik;
           Tablo.TabPara.FieldByName('ADET').AsString := '1';
           Tablo.TabPara.FieldByName('BIRIM').AsString := Birimi;
           Tablo.TabPara.FieldByName('BIRIMFIYAT').AsCurrency := bf;
           Tablo.TabPara.Post
       end;
     begin
       Tablo.Query5.Close;
       Tablo.Query5.SQL.Text := 'Select * From OPRBIRIM Where FIYATADI='''+Fiyat+''' and ALTBIRIM <= '+FloatToStr(Birim)+' Order By ALTBIRIM';
       Tablo.Query5.Open;
       Tablo.Query5.Last;
       ///Opr Birimleri girilmişse
       if Tablo.Query5.RecordCount>0 then begin
            Tablo.TabPara.Edit;
            Tablo.TabPara.FieldByName('BIRIMFIYAT').AsCurrency :=0.0;
            Tablo.TabPara.Post;
       end
       else
         exit;

       ParaEkle(Kod+'.01','OPR.DR.ÜCRETİ',FloatToStr(birim),Birim*Carpan);
       for i:= 4 to 12 do
           if Tablo.Query5.Fields[i].AsCurrency > 0 then begin
              Birim := Tablo.Query5.Fields[i].AsFloat;
              if Birim>10000 then begin
                 Fiy  := Birim;
                 Br := 0.0;
              end else if Birim<1 then begin  //demekki yüzde...
                 Fiy:= Birim*Tablo.Query4.FieldByName('BIRIM').AsFloat*Carpan;
                 Br := Birim*Tablo.Query4.FieldByName('BIRIM').AsFloat;
              end else begin
                 Fiy:= Birim*Carpan;
                 Br := Birim;
              end;

              ParaEkle(Kod+'.0'+IntToStr(i-2), Tablo.Query5.Fields[i].FieldName,FloatToStr(Br),Fiy);
           end;
     end;

     procedure OperasyonEkle;
     var AMELIYAT_TURU,Dr,IslemKodu:String[20];
         GecFiyat:String;
         Butce,Katki,BirimFiyat,IskMik:Currency;
         Isk:Real;
         i,KDV:smallint;

         function Ameliyat_Turunu_Getir : String; //Genel/lokal anestezimi, müdahale mi?
         begin
            Application.CreateForm(TListeDlg, ListeDlg);
            ListeDlg.Label1.Caption := 'Ameliyat Tipini Seçin';
            GenotipIni.ReadSection('Ameliyat_Türleri',ListeDlg.ListAmac.Items);
            ListeDlg.ListAmac.ItemIndex := 0;
            if ListeDlg.ListAmac.Items.count > 1 then
               ListeDlg.ShowModal;
            if ListeDlg.ListAmac.Items.count = 0 then
               result := ''
            else
               result := ListeDlg.ListAmac.Items[ListeDlg.ListAmac.ItemIndex];
            ListeDlg.Destroy;
         end;

         procedure Dagilimi_Yap;
         var ButceKodu : String[20];
         begin
         if (Tablo.Query5.IsEmpty)and(Fiyatadi<>'TTB') then begin
              Tablo.Query5.Close;
              Tablo.Query5.SQL.Text :='SELECT ISNULL(KATSAYI,1.0)*ISNULL(CARPAN,1.0) from FIYATLAR WHERE KOD='''+Kodu+''' and FIYATADI='''+FiyatAdi+'''';
              Tablo.Query5.Open;
              Butce:= Tablo.Query5.Fields[0].AsCurrency;
              if Katkiadi<>'' then begin
                 Tablo.Query5.Close;
                 Tablo.Query5.SQL.Text :='SELECT ISNULL(KATSAYI,1.0)*ISNULL(CARPAN,1.0) from FIYATLAR WHERE KOD='''+Kodu+''' and FIYATADI='''+KatkiAdi+'''';
                 Tablo.Query5.Open;
                 Katki := Tablo.Query5.Fields[0].AsCurrency
              end else
                 Katki:=0;
              Tablo.Query5.Close;
              Tablo.Query5.SQL.Text :=
              ' Select '''' AS ISLEMKODU, ANAHTAR AS ISLEMADI, SUBSTRING(DEGER,1,CHARINDEX('','', DEGER)-1) AS GRUP,'+
              ' CAST(SUBSTRING(DEGER,CHARINDEX('','', DEGER)+1,20) AS FLOAT) AS YUZDE, 1.0 AS ADET,'''' AS BIRIM,'''' AS KDV,'+
              ' CAST(SUBSTRING(DEGER,CHARINDEX('','', DEGER)+1,20) AS FLOAT)*('+FloatToStr(Butce+Katki)+')/100 AS BIRIMFIYAT,'+
              ' CAST(SUBSTRING(DEGER,CHARINDEX('','', DEGER)+1,20) AS FLOAT)*('+FloatToStr(Butce+Katki)+')/100 AS TUTAR,'+
              ' 0.0 AS ISKONTO,'''' AS OZELKOD, '''' AS BUTCEKODU, '''' AS MUHKODU'+
              ' From GENOTIPINI where BOLUM = '''+AMELIYAT_TURU+'_Dagilimi'' '+
              ' order by SIRANO';
            Tablo.Query5.Open;
         end;

         if Tablo.Query5.RecordCount>0 then begin //Tek ameliyat fiyatı yok dağılım var onuniçin üstteki fayatı sıfırlıyoruz..
            Table1.Edit;
            if Table1 <> TabHesapla then begin
               KDV := Table1.FieldByName('KDV').AsInteger;
               ButceKodu := Table1.FieldByName('BUTCEKODU').AsString;
            end;
            Table1.FieldByName('BIRIMFIYAT').AsCurrency :=0.0;
            Table1.Post;
            ///Türünü ekliyoruz Ör : (Genel Anestezi)
            Table1.Append;
            Table1.FieldByName('KOD').AsString := Kodu+'.00';
            Table1.FieldByName('TUR').AsString := 'OPR';
            Table1.FieldByName('BUTCEKODU').AsString := ButceKodu;
            Table1.FieldByName('ACIKLAMA').AsString := '('+AMELIYAT_TURU+')';
            Table1.FieldByName('PAKETNO').AsInteger := Paketno;
            Table1.Post;
         end;
         i := 0;
         while not Tablo.Query5.eof do begin

            BirimFiyat := Tablo.Query5.FieldByName('BIRIMFIYAT').AsCurrency;
            GecFiyat:=FiyatAdi;

            if Table1 = TabHesapla then
               Iskonto_Getir(ComboKurum.Items[ComboKurum.ItemIndex], Kodu, GecFiyat, Isk, IskMik)
            else
               Iskonto_Getir(Tablo.TabGelisler.FieldByName('KURUM').AsString, Kodu, GecFiyat, Isk, IskMik);

            if IskMik > 0.01 then begin
               BirimFiyat := IskMik;
               Tutar := BirimFiyat;
               Isk := 0;
            end else
               Tutar := (100-Isk)*BirimFiyat/100;


            IslemKodu := Tablo.Query5.FieldByName('ISLEMKODU').AsString;
            if IslemKodu='' then
               IslemKodu := Kodu+'.0'+intToStr(i+1);

            Tablo.Query2.Close;
            Tablo.Query2.SQL.Text := 'Select ISLEMLER.KOD, ISLEMADI AS AD, TUR, OZELKOD, BUTCEKODU, MUHKODU, KDV '+
                 ' From ISLEMLER where ISLEMLER.KOD = '''+IslemKodu+'''';
            Tablo.Query2.SQL.Add(' Union ALL Select STOKKART.KOD, STOKADI AS AD, CAST(''STOK'' AS VARCHAR(5)) AS TUR, OZELKOD, BUTCEKODU, MUHKODU, KDV'+
                 ' From STOKKART where STOKKART.KOD = '''+IslemKodu+'''');
            Tablo.Query2.open;
            //Dr.Kodunu Getir
            Dr := DrKod_Getir(Kodu, Dr);

            inc(i);
            s:=Tablo.Query2.FieldByName('TUR').AsString;
            if s='' then s:='OPR';
            Table1.Append;
            Table1.FieldByName('TUR').AsString := s;
            Table1.FieldByName('KOD').AsString := IslemKodu;
            Table1.FieldByName('ACIKLAMA').AsString := Tablo.Query5.FieldByName('ISLEMADI').AsString;
            Table1.FieldByName('ADET').AsString := Tablo.Query5.FieldByName('ADET').AsString;
            Table1.FieldByName('BIRIM').AsString := Tablo.Query5.FieldByName('BIRIM').AsString;
            Table1.FieldByName('PAKETNO').AsInteger := Paketno;

            if Tablo.Query5.FieldByName('BIRIMFIYAT').AsString<>'' then
               Table1.FieldByName('BIRIMFIYAT').AsCurrency := Tablo.Query5.FieldByName('BIRIMFIYAT').AsCurrency
            else
               Table1.FieldByName('BIRIMFIYAT').AsCurrency := BirimFiyat;

            if Tablo.Query5.FieldByName('TUTAR').AsString<>'' then
               Table1.FieldByName('TUTAR').AsCurrency := Tablo.Query5.FieldByName('TUTAR').AsCurrency
            else
               Table1.FieldByName('TUTAR').AsCurrency := Tutar;

            if Tablo.Query5.FieldByName('ISKONTO').AsString<>'' then
               Table1.FieldByName('ISKONTO').AsString := Tablo.Query5.FieldByName('ISKONTO').AsString
            else
               Table1.FieldByName('ISKONTO').AsFloat := Isk;

            if Table1 = Tablo.TabPara then begin
                Table1.FieldByName('DR').AsString := Dr;

                if Tablo.Query5.FieldByName('KDV').AsString<>'' then
                   Table1.FieldByName('KDV').AsString := Tablo.Query5.FieldByName('KDV').AsString
                else
                   Table1.FieldByName('KDV').AsString := Tablo.Query2.FieldByName('KDV').AsString;
                if Table1.FieldByName('KDV').AsString='' then Table1.FieldByName('KDV').AsInteger := KDV;

                if Tablo.Query5.FieldByName('OZELKOD').AsString<>'' then
                   Table1.FieldByName('OZELKOD').AsString := Tablo.Query5.FieldByName('OZELKOD').AsString
                else
                   Table1.FieldByName('OZELKOD').AsString := Tablo.Query2.FieldByName('OZELKOD').AsString;

                if Tablo.Query5.FieldByName('BUTCEKODU').AsString<>'' then
                   Table1.FieldByName('BUTCEKODU').AsString := Tablo.Query5.FieldByName('BUTCEKODU').AsString
                else
                   Table1.FieldByName('BUTCEKODU').AsString := Tablo.Query2.FieldByName('BUTCEKODU').AsString;

                if Tablo.Query5.FieldByName('MUHKODU').AsString<>'' then
                   Table1.FieldByName('MUHKODU').AsString := Tablo.Query5.FieldByName('MUHKODU').AsString
                else
                   Table1.FieldByName('MUHKODU').AsString := Tablo.Query2.FieldByName('MUHKODU').AsString;
            end;{if}
            Table1.Post;
            Tablo.Query5.next;
         end;{while}
        end;{proc}

     begin
         if Fiyatadi<>'TTB' then
            AMELIYAT_TURU := Ameliyat_Turunu_Getir;

         //Daha önceden girilmiş ameliyat var mı???
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text := 'select * from PARA '+
                             ' WHERE DOSYANO = '''+Tablo.TabGelisler.Fields[0].AsString+''''+
                             ' AND GELISNO = '+Tablo.TabGelisler.Fields[1].AsString+' and KOD='''+Kodu+'.00'' ';
         Tablo.Query1.Open;
         if not Tablo.Query1.IsEmpty then  begin
             // DahaOncedenAmeliyatVar;
             GelisDlg.PREOP_SARF_KALAN;
             Paket_Kontrolu(AMELIYAT_TURU);
         end;

         //Eğer paketse ve Resmi kurumsa diğer işlemlerin fiyatı ödenmeyeceği için ücreti sıfırlanacak
         if (pos('P', QueryIslem.FieldByName('BUTCEKODU').AsString)=1)and(not Tablo.TabPara.IsEmpty)and(FiyatAdi='Bütçe') then begin
            if Paket_Kontrolu(AMELIYAT_TURU) = False then
               exit;
         end;
         if Tablo.TabPara.State=dsBrowse then
            Tablo.TabPara.Append;
         PaketNO := Tablo.TabPara.FieldByName('SIRANO').AsInteger;
         Iskon:=-2;
         Ekleme;  //Adını ekliyor sadece
         Tablo.Query5.Close;
         Tablo.Query5.SQL.Text := 'Select * From AMELIYATFIYAT Where '+  // KOD, ISLEMKODU, ISLEMADI, BIRIM, BIRIMFIYAT
           'KOD = '''+Kodu+''' and FIYATADI = '''+Fiyatadi+''' and TURU='''+AMELIYAT_TURU+'''';///// and isnull(GRUP,'''')='''' order by SIRANO';
         Tablo.Query5.Open;

         if (Tablo.Query5.IsEmpty)and(Fiyatadi='TTB') then begin
            ///Daha önce ameliyat kartı oluşturulmamışsa
            Tablo.Query4.Close;
            Tablo.Query4.SQL.Text := 'Select * From ISLEMLER where ISLEMLER.KOD = '''+Kodu+'''';
            Tablo.Query4.Open;
            TTBBirimOlustur('TTB', Tablo.Query4.FieldByName('KOD').AsString, Tablo.Query4.FieldByName('BIRIM').AsFloat, StrToFloat(GenotipIni.ReadString('GenelOpsiyon', 'TTBKATSAYISI', '2242000')));
            exit;
         end;

         Dagilimi_Yap;
     end;
begin
  PaketNO:=-1;
  if Trim(Adet.Text)='' then Adet.Text:='1';
  if (Turu = 'PAKET')and(not UcretDuzenleme) then begin
     QueryPaket.Close;
     QueryPaket.SQL.Text := 'Select GRUP, BIRIM, TUR, OZELKOD,KOD,ISLEMADI, KDV from ISLEMLER where KOD like '''+Kodu+'%'' order by KOD';
     QueryPaket.Open;
     if Tablo.TabPara.State=dsBrowse then
        Tablo.TabPara.Append;
     Tablo.TabPara.FieldByName('KOD').AsString := QueryPaket.FieldByName('KOD').AsString;
     Tablo.TabPara.FieldByName('TUR').AsString := QueryPaket.FieldByName('TUR').AsString;
     Tablo.TabPara.FieldByName('ACIKLAMA').AsString := QueryPaket.FieldByName('ISLEMADI').AsString;
     Tablo.TabPara.FieldByName('KDV').AsString := QueryPaket.FieldByName('KDV').AsString;
     Tablo.TabPara.FieldByName('ADET').AsString := '1';
     PaketNO := Tablo.TabPara.FieldByName('SIRANO').AsInteger;
     Tablo.TabPara.FieldByName('PAKETNO').AsInteger := PaketNO;
     Tablo.TabPara.Post;
     QueryPaket.First;
     QueryPaket.Next;
     while not QueryPaket.eof do begin
        Kodu := QueryPaket.Fields[0].AsString;
        if QueryPaket.Fields[1].AsString='' then
           Iskon:= -2 //aynen orjinal fiyatı al
        else
          if pos('%',QueryPaket.Fields[1].AsString)>0 then begin //yüzdeli
             PaketYuzde := True;
             s:= QueryPaket.Fields[1].AsString;
             Delete(s, pos('%',s), 1);
             Iskon := StrToFloat(s);
          end
        else begin
           Iskon:= QueryPaket.Fields[1].AsFloat;
           PaketYuzde := False;
        end;
        Turu := QueryPaket.Fields[2].AsString;
        OzKodu :=  QueryPaket.Fields[3].AsString;
        Ekleme;
        if (KatkiAdi<>'')and(Table1.FieldByName('ACIKLAMA').AsString<>'KATKI PAYI') then //Katkı payı var mı?
           KatkiPayiEkle(Tablo.TabPara);
        QueryPaket.next;
     end;
  end
  else if (Turu = 'PANEL') then begin
     QueryPaket.Close;
     QueryPaket.SQL.Text := 'Select GRUP, BIRIM, TUR, OZELKOD,KOD,ISLEMADI from ISLEMLER where KOD like '''+Kodu+'.%'' order by KOD';
     QueryPaket.Open;
     if Tablo.TabPara.State=dsBrowse then
        Tablo.TabPara.Append;
     while not QueryPaket.eof do begin
        Kodu := QueryPaket.Fields[0].AsString;
        PaketNO:=0;
        if QueryPaket.Fields[1].AsString='' then
           Iskon:= -2 //aynen orjinal fiyatı al
        else
          if pos('%',QueryPaket.Fields[1].AsString)>0 then begin //yüzdeli
             PaketYuzde := True;
             s:= QueryPaket.Fields[1].AsString;
             Delete(s, pos('%',s), 1);
             Iskon := StrToFloat(s);
          end
        else begin
           Iskon:= QueryPaket.Fields[1].AsFloat;
           PaketYuzde := False;
        end;
        Turu := QueryPaket.Fields[2].AsString;
        OzKodu :=  QueryPaket.Fields[3].AsString;
        Ekleme;
        if (KatkiAdi<>'')and(Table1.FieldByName('ACIKLAMA').AsString<>'KATKI PAYI') then //Katkı payı var mı?
           KatkiPayiEkle(Tablo.TabPara);
        QueryPaket.next;
     end;
  end
  else if Turu = 'OPR' then
     OperasyonEkle
  else begin
     Ekleme;
     if (KatkiAdi<>'')and(Table1.FieldByName('ACIKLAMA').AsString<>'KATKI PAYI') then //Katkı payı var mı?
        case Cagiran of
          1 : HesaplaKatkiPayiEkle;
          0 : KatkiPayiEkle(Tablo.TabPara);
        end;
  end;
  Adet.Text := '1';
end;

function TUcretAraDlg.Paket_Kontrolu(OprTuru:String): Boolean;
var Bulundu : Boolean;
    i : smallint;
begin
   if Application.MessageBox('Paket işlem ekleniyor. Bu işlemden önce eklenenlerin fiyatı sıfırlanacak!! Eklemeyi onaylıyor musunuz?', 'O N A Y', MB_YESNO)=IDYES then begin
      Tablo.Query4.Close;
      Tablo.Query4.SQL.Text := ' Select ANAHTAR AS ISLEMADI, SUBSTRING(DEGER,1,CHARINDEX('','', DEGER)-1) AS GRUP, '+
                               ' CAST(SUBSTRING(DEGER,CHARINDEX('','', DEGER)+1,20) AS FLOAT) AS YUZDE '+
                               ' From GENOTIPINI where BOLUM = '''+OprTuru+'_Dagilimi'' '+
                               ' and SUBSTRING(DEGER,1,CHARINDEX('','', DEGER)-1)<>'''' order by SIRANO';
      Tablo.Query4.Open;

      s:='';
      Tablo.Query6.Close;
      Tablo.Query6.SQL.Text := 'select sum(TUTAR) from PARA '+
                            '         where DOSYANO='''+Tablo.TabGelisler.Fields[0].AsString+
                            ''' AND GELISNO='+Tablo.TabGelisler.Fields[1].AsString+' and TUR<>''OPR'' and ACIKLAMA<>''KATKI PAYI'' ';
      j:=0;
      if not Tablo.Query4.IsEmpty then
         Tablo.Query6.SQL.Add(' and (  ');
      while not Tablo.Query4.eof do begin  //grupları al F-H   veya B
         if j > 0 then Tablo.Query6.SQL.Add(' or ');
         inc(j);
         if pos('-', Tablo.Query4.FieldByName('GRUP').AsString)>0 then begin
            stlist := TStringList.Create;
            ParcalaPar('-',Tablo.Query4.FieldByName('GRUP').AsString, stlist);
            for i := 0 to stlist.count-1 do begin
              if i > 0 then Tablo.Query6.SQL.Add(' or ');
              Tablo.Query6.SQL.Add('  KOD not like '''+stlist.strings[i]+'%''');
            end;
            stlist.free;
         end
         else
            Tablo.Query6.SQL.Add(' KOD not like '''+Tablo.Query4.FieldByName('GRUP').AsString+'%''');
         Tablo.Query4.next;
      end;
      if not Tablo.Query4.IsEmpty then
         Tablo.Query6.SQL.Add(')');
      Tablo.Query6.Open;

      if (Tablo.Query6.Fields[0].AsString<>''){and(pos('P', QueryIslem.FieldByName('BUTCEKODU').AsString)=1)} then begin
         Tablodokum.Query1.Close;
         Tablodokum.Query1.SQL.Text := 'update TAHSILAT  set TAHSIL=TAHSIL-'+Tablo.Query6.Fields[0].AsString+ //Tahsilattan da kamu düşelim
                            '  where DOSYANO='''+Tablo.TabGelisler.Fields[0].AsString+
                            ''' AND GELISNO='+Tablo.TabGelisler.Fields[1].AsString+' and TUR=''KAMU'' '+
                            '  AND SIRANO=(SELECT MAX(SIRANO) FROM TAHSILAT '+
                            '  where DOSYANO='''+Tablo.TabGelisler.Fields[0].AsString+
                            ''' AND GELISNO='+Tablo.TabGelisler.Fields[1].AsString+' and TUR=''KAMU'' )';
         Tablodokum.Query1.ExecSQL;
         Tablo.TabTahsilat.Close;
         Tablo.TabTahsilat.Open;
         Tablo.Query6.Close;
         Tablo.Query6.SQL.Text := 'update PARA set BIRIMFIYAT=0.0, ISKONTO=0.0, TUTAR=0.0, DOKTORPAYI=0.0'+copy(Tablo.Query6.SQL.Text,30,length(Tablo.Query6.SQL.Text)-30);
         Tablo.Query6.ExecSQL;
      end;
      Paket_Kontrolu := True;
   end
   else
      Paket_Kontrolu := False;
end;

function TUcretAraDlg.DahaOnceEklenmediKontrolu(Kod:string):boolean;
var Bulundu : Boolean;
    Noktasiz :String[20];
   procedure Islem(Kod:string);
   begin
     Tablo.Query3.Close;
     if Tablo.Query1.fields[2].AsString = 'A' then begin

        Tablo.Query3.SQL.Text := 'Select GELISNO from PARA, '+DokListesi+' where PARA.DR='+DokListesi+'.DOKTORKOD and DOSYANO='''+
          Tablo.TabGelisler.Fields[0].AsString+''' and TARIH>='''+FormatDateTime('MM/DD/YYYY 00:00', GenotipINI.BugunTrh-Tablo.Query1.fields[1].AsInteger)+
          ''' and TARIH<'''+FormatDateTime('MM/DD/YYYY hh:nn:ss:zz', GenotipINI.BugunTrh)+
          ''' and UZMANLIK='''+ComboPol.Text+''' and KOD = '''+Kod+'''';
     end
     else
        Tablo.Query3.SQL.Text := 'Select GELISNO from PARA where DOSYANO='''+Tablo.TabGelisler.Fields[0].AsString+
          ''' and TARIH>='''+FormatDateTime('MM/DD/YYYY 00:00', GenotipINI.BugunTrh-Tablo.Query1.fields[1].AsInteger)+
          ''' and TARIH<'''+FormatDateTime('MM/DD/YYYY hh:nn:ss:zz', GenotipINI.BugunTrh)+''' and KOD = '''+Kod+'''';
     Tablo.Query3.Open;
     Bulundu := Tablo.Query3.Fields[0].AsString<>'';
   end;
begin
  if UcretDuzenleme then begin
     DahaOnceEklenmediKontrolu := True;
     exit;
  end
  else
     Bulundu := False;
  if pos('.',Kod)>0 then Noktasiz := copy(Kod,1,pos('.',Kod)-1)
  else Noktasiz := Kod;

  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'Select * from #ISLEM_UYARI where (KOD like '''+Noktasiz+'%'' or KOD=''*TÜM*'') and (KURUM='''+Tablo.TabGelisler.FieldByName('KURUM').AsString+''' OR KURUM=''*TÜM*'')  order by KOD desc';
  Tablo.Query1.Open;
  while not Tablo.Query1.eof do begin
    if (pos(Noktasiz, Tablo.Query1.fields[0].AsString)>0)or(Tablo.Query1.fields[0].AsString = '*TÜM*') then
       Islem(Kod);
    Tablo.Query1.next;
 end;
 if Bulundu then begin
    if Tablo.Query1.fields[4].AsString='U' then
       DahaOnceEklenmediKontrolu := Application.MessageBox(PChar('Bu işlem daha önce '+Tablo.Query3.Fields[0].AsString+'. gelişte eklenmiş!! Eklemeyi onaylıyor musunuz?'), 'O N A Y', MB_YESNO)=IDYES
    else begin
       ShowMessage(PChar('Bu işlem daha önce '+Tablo.Query3.Fields[0].AsString+'. gelişte eklenmiş!!' ));
       DahaOnceEklenmediKontrolu := False;
    end
 end
 else
    DahaOnceEklenmediKontrolu := True;
end;

procedure TUcretAraDlg.EkleTusClick(Sender: TObject);
var Key: Word;
    i : smallint;
begin
   case Cagiran of
   0 : begin
         if (SSKProvVar)and(pos('SSK', Tablo.TabGelisler.FieldByName('KURUM').AsString)>0) then begin
             IslemDonus :=SSKPrvHastayaIslemEkle(Tablo.TabGelisler.Fields[0].AsString,DBGrid1.Fields[0].AsString, LabelDoktorKod.Caption,
                                 ComboKesAcik.Text,ComboKesYuzde.Text,Tablo.TabGelisler.Fields[1].AsInteger,1,StrToInt(adet.Text), CheckAcil.checked);
             if not IslemDonus.IslemEklendi then
                exit;
         end;
         if AgacTus.Down then begin
            AraStokAdi.Text := TreeMua.Selected.Text;
            AraKodKeyUp(Self, Key, [ssShift]);
         end;
         if YerineKodVarKontrolu then begin
            s := GenotipIni.ReadString(Tablo.TabGelisler.FieldByName('KURUM').AsString,DBGrid1.Fields[0].AsString,'x');
            if s<>'x' then begin
               QueryIslem.Close;
               QueryIslem.SQL.Text:='Select ISLEMLER.KOD,ISLEMLER.ButceKodu,ISLEMADI AS AD, TUR, '+
                 'cast(''01'+dateseparator+'01'+dateseparator+'1900'' as DATETIME) as SKT, CAST(0 AS DOUBLE PRECISION) AS ADET, '+
                 'CAST('''' AS VARCHAR(8)) as ANABIRIM From ISLEMLER WHERE KOD='''+s+'''';
               QueryIslem.Open;
            end;
         end;
         if IslemUyari then begin
            if DahaOnceEklenmediKontrolu(DBGrid1.Fields[0].AsString) then
               UcretEkleme(Tablo.TabPara, DBGrid1.Fields[0].AsString, DBGrid1.Fields[3].AsString, LabelDoktorKod.Caption);
         end else
               UcretEkleme(Tablo.TabPara, DBGrid1.Fields[0].AsString, DBGrid1.Fields[3].AsString, LabelDoktorKod.Caption);
         if UcretAraDlg.Visible then TutAranan.Setfocus;
         AlinanFiyat:=-1;
       end;
   1 : begin     //Hesaplama için çağırma
         if AgacTus.Down then begin
            AraStokAdi.Text := TreeMua.Selected.Text;
            AraKodKeyUp(Self, Key, [ssShift]);
         end;
         UcretEkleme(TabHesapla, DBGrid1.Fields[0].AsString, DBGrid1.Fields[3].AsString, LabelDoktorKod.Caption);
         if UcretAraDlg.Visible then TutAranan.Setfocus;
       end;
   2 : begin
     if HakedisDlg.TabDokYuzde.State in [dsBrowse] then
        HakedisDlg.TabDokYuzde.Append;
     if AgacTus.Down then
       HakedisDlg.TabDokYuzde.FieldByName('KOD').AsString := copy(TreeMua.Selected.Text,1,pos(' ',TreeMua.Selected.Text)-1)
     else
       HakedisDlg.TabDokYuzde.FieldByName('KOD').AsString := DBGrid1.Fields[0].AsString; //
     HakedisDlg.TabDokYuzde.Post;
   End;
   3 : Begin
     if CagTabloAdi.State in [dsBrowse] then
        CagTabloAdi.Append;
     if AgacTus.Down then
       CagTabloAdi.FieldByName('KOD').AsString := copy(TreeMua.Selected.Text,1,pos(' ',TreeMua.Selected.Text)-1)
     else
       CagTabloAdi.FieldByName('KOD').AsString := DBGrid1.Fields[0].AsString; //
     CagTabloAdi.FieldByName('ISLEMADI').AsString := DBGrid1.Fields[2].AsString; //
     CagTabloAdi.FieldByName('ISKONTO').AsFloat := 0;
     CagTabloAdi.Post;
   End;
   4 : begin
         if AgacTus.Down then begin
            AraStokAdi.Text := TreeMua.Selected.Text;
            AraKodKeyUp(Self, Key, [ssShift]);
         end;
         UcretEkleme(Tablo.TabFatura, DBGrid1.Fields[0].AsString, DBGrid1.Fields[3].AsString, LabelDoktorKod.Caption);
       end;
   6 : Begin
     if CagTabloAdi.State in [dsBrowse] then
        CagTabloAdi.Append;

     i := strToInt(SonNo);
     inc(i);
     SonNo:=IntToStr(i);
     for i:= 1 to DigitSay-Length(SonNo) do
         SonNo := '0'+SonNo;
     CagTabloAdi.FieldByName('KOD').AsString := AnaKod+'.'+SonNo;
     CagTabloAdi.FieldByName('GRUP').AsString := QueryIslem.FieldByName('KOD').AsString; //
     CagTabloAdi.FieldByName('ISLEMADI').AsString := QueryIslem.FieldByName('AD').AsString; //
     CagTabloAdi.FieldByName('TUR').AsString := QueryIslem.FieldByName('TUR').AsString; //
     CagTabloAdi.FieldByName('KDV').AsInteger := 8; //
     CagTabloAdi.Post;
   End;
   7 : begin
         if AgacTus.Down then begin
            AraStokAdi.Text := TreeMua.Selected.Text;
            AraKodKeyUp(Self, Key, [ssShift]);
         end;
         UcretEkleme(PaketKartDlg.TabPaketPara, DBGrid1.Fields[0].AsString, DBGrid1.Fields[3].AsString, LabelDoktorKod.Caption);
       end;
  End;{case}
  if (IslemdensonraKapat)and(cagiran=0) then
     KapatTus.Click;
end;

procedure TUcretAraDlg.AgacTusClick(Sender: TObject);
var Key: Word;
begin
   AraKod.Text := ''; AraStokAdi.Text := '';
   AraBul('ISLEMLER', 'KOD', 'ISLEMADI', 'GRUP');
   AgacTus.Down := True;
   ListeTus.Down := False;
   AraStokAdi.Text := '';
   AraKodKeyUp(Self, Key, [ssShift]);
   if SonAgacFiyatAdi <> SonListeFiyatAdi then begin
      SonAgacFiyatAdi := SonListeFiyatAdi;
      AgacYapisi(TreeMua, QueryIslem, 'KOD', 'AD', 'Y')
   end else
      AgacYapisi(TreeMua, QueryIslem, 'KOD', 'AD', ' ')
end;

procedure TUcretAraDlg.AgacTusMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button = mbRight then
      AgacYapisi(TreeMua, QueryIslem, 'KOD', 'ISLEMADI', 'Y')
end;

procedure TUcretAraDlg.TreeDigDblClick(Sender: TObject);
begin
   If TTreeView(Sender).Selected.HasChildren then exit;
   EkleTus.Click;
end;

procedure TUcretAraDlg.FiyatDegistir;
var fiytut, fiy : string[40];
begin
   if (Cagiran = 0)and(not Tablo.TabGelisler.active) then exit;
   if (Cagiran = 0)or(Cagiran = 4) then
      s := Tablo.TabGelisler.FieldByName('KURUM').AsString
   else
      s := ComboKurum.Items[ComboKurum.ItemIndex];
   Tablo.Query4.Close;
   Tablo.Query4.SQL.Text := 'Select FIYATADI, KDV, KATKIADI, FATURA, FIYATADI_YATAN, KATKIADI_YATAN  From KURUM where KURUM ='''+s+'''';
   Tablo.Query4.Open;
   if {(Tablo.Query4.Fields[5].AsString='')or}(pos('AYAK', uppercase(Tablo.TabGelisler.FieldByName('TEDAVI').AsString))>0) then
       KatkiAdi:= Tablo.Query4.Fields[2].AsString       //  KatkiAdi := Tablo.Query4.Fields[2].AsString;
   else
       KatkiAdi:= Tablo.Query4.Fields[5].AsString;
   if (Tablo.Query4.Fields[4].AsString='')or(pos('AYAK', uppercase(Tablo.TabGelisler.FieldByName('TEDAVI').AsString))>0) then
       fiy := Tablo.Query4.Fields[0].AsString       //  KatkiAdi := Tablo.Query4.Fields[2].AsString;
   else
       fiy := Tablo.Query4.Fields[4].AsString;

   KurumKDVDurum := Tablo.Query4.Fields[1].AsString;
   if KurumKDVDurum = '' then KurumKDVDurum := 'Dahil';
   if (Cagiran=0)and(OncekiButceAdi<>'')and(pos('Kamu',Tablo.Query4.Fields[3].AsString)>0)and(Tablo.TabGelisler.FieldByName('GIRISTARIH').AsDateTime<OncekiTarih) then
      fiytut := OncekiButceAdi
   else
      fiytut := fiy;   //Tablo.Query4.Fields[0].AsString;
//   if (Cagiran>0)and((FiyatAdi <> fiytut) then begin
   FiyatAdi := fiytut;
   if Cagiran > 0 then begin
      TabHesapla.First;
      while not TabHesapla.eof do begin
        if TabHesapla.FieldByName('ACIKLAMA').AsString<>'KATKI PAYI' then begin
           TabHesapla.Edit;
           HesapUcretSatirDoldur;
           TabHesapla.Post;
        end;
        TabHesapla.next;
      end;
   end;
  // end;
end;

function TUcretAraDlg.FisBilgisi : Boolean;
begin
      stlist := Tstringlist.Create;
      GenotipIni.ReadSection('FIS_TÜRÜ', stlist);
      FisNo := '';
      if not MesajStrAl('','Fiş Türünü Girin :','C', stlist, FisTuru, 'Numarası : ', 'E', nil, FisNo) then
         FisNo := '';
      stlist.free;
      FisBilgisi := FisNo<>'';
end;

procedure TUcretAraDlg.FormActivate(Sender: TObject);
var   Key : word;
begin
    PanelHesap.Visible := cagiran=1;

   if not Tablo.TabGelisler.Active then begin
      Tablo.TabGelisler.Close;
      Tablo.TabGelisler.Parameters[0].Value:= Tablo.TabKimlik.Fields[0].AsString;
      Tablo.TabGelisler.Open;
      Tablo.TabGelisler.Last;
   end;
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text := 'Select KATKIADI, KATKIADI_YATAN from KURUM where KURUM='''+Tablo.TabGelisler.FieldByName('KURUM').AsString+'''';
   Tablo.Query3.Open;
   if {(Tablo.Query3.Fields[1].AsString='')or}(pos('AYAK', uppercase(Tablo.TabGelisler.FieldByName('TEDAVI').AsString))>0) then
         KatkiAdi:= Tablo.Query3.Fields[0].AsString
   else
         KatkiAdi:= Tablo.Query3.Fields[1].AsString;
//   else
//      KatkiAdi:= '';

   UcrTutar := 0;
   FiyatDegistir;

   if pos('<>', FiyatAdi)>0 then //Poliklinik-TTB iki fiyat var; düşük olanı seçilecek
      FiyatAdTut := copy(FiyatAdi,1,pos('<>', FiyatAdi)-1)
   else
      FiyatAdTut := FiyatAdi;

   if not Tablo.TabGelisler.Active then exit;

   if (DoktorSor)and(Cagiran=0)and(not UcretDuzenleme) then
      DoktorSecTus.Click;

   if UcretAraDlg.Visible then TutAranan.SetFocus;
//   if Cagiran<>1 then begin
      {if Tablo.TabPara.RecordCount > 0 then begin
         Tablo.TabPara.Last;
         Tablo.Query1.SQL.Text := 'Select UZMANLIK, DOKTOR, DOKTORKOD from DOKTOR where DOKTORKOD='''+Tablo.TabPara.FieldByName('DR').AsString+'''';
         Tablo.Query1.Open;
         ComboPol.Text := Tablo.Query1.Fields[0].AsString;
         ComboDOKTOR.Text := Tablo.Query1.Fields[1].AsString;
         LabelDoktorKod.Caption := Tablo.Query1.Fields[2].AsString;
      end else begin }
//         ComboPol.Text := Tablo.TabGelisler.FieldByName('POLIKLINIK').AsString;
      //end;
//   end;
    Key:=0;
    AraKodKeyUp(Self, Key, [ssShift]);

    if (SSKProvVar)and(cagiran=0)and(pos('SSK', Tablo.TabGelisler.FieldByName('KURUM').AsString)>0) then 
       Panel1.Height := 129
    else
       Panel1.Height := 80;
end;

procedure TUcretAraDlg.TabHesaplaNewRecord(DataSet: TDataSet);
begin
   YeniKayit:=True;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select isnull(MAX(SIRANO),0) from HESAPLA  Where KULLANICI ='''+Kullanan+'''';
   Tablo.Query1.Open;
   TabHesapla.Fields[1].AsInteger := Tablo.Query1.Fields[0].AsInteger+1;
   TabHesapla.Fields[0].AsString := Kullanan;
end;

procedure TUcretAraDlg.TabHesaplaAfterPost(DataSet: TDataSet);
begin
   if YeniKayit then begin
      TabHesapla.Close;
      TabHesapla.Open;
   end;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select SUM(TUTAR) from HESAPLA Where KULLANICI ='''+Kullanan+'''';
   Tablo.Query1.Open;
   LabelToplam.Caption := format(' Toplam : %-10m',[Tablo.Query1.Fields[0].AsCurrency]);
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select SUM(CASE WHEN 1=ISNUMERIC(BIRIM) THEN cast(BIRIM as float)ELSE 0 END) from HESAPLA  Where KULLANICI ='''+Kullanan+'''';
   try
     Tablo.Query1.Open;
     LabelBirimToplam.Caption := format('%-10m',[Tablo.Query1.Fields[0].AsCurrency]);
   except
   end;

   if KatkiAdi<>'' then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select KATKI_PAYI= SUM(CASE  WHEN ACIKLAMA=''KATKI PAYI'' THEN TUTAR ELSE 0 END),';
      Tablo.Query1.SQL.Add(' KURUM_PAYI= SUM(CASE  WHEN ACIKLAMA<>''KATKI PAYI'' THEN TUTAR   ELSE 0 END) ');
      Tablo.Query1.SQL.Add(' from HESAPLA ');
      Tablo.Query1.SQL.Add(' Where KULLANICI = '''+Kullanan+'''');
      Tablo.Query1.Open;
      LabelKatkiToplam.Caption := format('Katkı : %-10m',[Tablo.Query1.Fields[0].AsCurrency]);
      LabelBirimToplam.Caption := format('Kurum : %-10m',[Tablo.Query1.Fields[1].AsCurrency]);
   end
   else
      LabelKatkiToplam.Caption := '';
end;

procedure TUcretAraDlg.TabHesaplaBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit:=False;
end;

procedure TUcretAraDlg.SilTusClick(Sender: TObject);
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Delete from HESAPLA Where KULLANICI ='''+Kullanan+'''';
   Tablo.Query1.ExecSQL;
   LabelToplam.Caption := '0';
   LabelBirimToplam.Caption:= '0';
   TabHesapla.Close;
   TabHesapla.Open;
end;

procedure TUcretAraDlg.ComboKurumChange(Sender: TObject);
begin
   FiyatDegistir;
end;

procedure TUcretAraDlg.GelisEkle(PNO:String);
begin
   Tablo.TabGelisler.Close;
   Tablo.TabGelisler.Parameters[0].Value := PNO;
   Tablo.TabGelisler.Open;
   Tablo.TabGelisler.Last;
   TabHesapla.First;
   while not TabHesapla.eof do begin
      if TabHesapla.FieldByName('TUR').AsString='KATKI' then
         KatkiPayiEkle(TabHesapla)
      else begin
         Tablo.TabPara.Append;
         Tablo.TabPara.FieldByName('KOD').AsString := TabHesapla.FieldByName('KOD').AsString;
         Tablo.TabPara.FieldByName('ADET').AsFloat := StrToFloat(Adet.Text);
         Tablo.TabPara.FieldByName('TUR').AsString := TabHesapla.FieldByName('TUR').AsString;
         Tablo.UcretSatirDoldur(Tablo.TabPara, '', AlinanFiyat);
         Tablo.TabPara.FieldByName('ISKONTO').AsString := TabHesapla.FieldByName('ISKONTO').AsString;
         Tablo.TabPara.Post;
      end;
      TabHesapla.next;
   end;
end;

procedure TUcretAraDlg.KimlikEkleTusClick(Sender: TObject);
var PNO : String[15];
begin
   PNO := Tablo.YeniDosyaNo;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Insert Into KIMLIK (DOSYANO)Values('''+PNO+''')';
   Tablo.Query1.ExecSQL;

   Tablo.TabKimlik.Close;
   Tablo.TabKimlik.Parameters[0].Value := PNO;
   Tablo.TabKimlik.Open;
   Tablo.KimlikdenSonraGelisEkle(ComboKurum.Items[ComboKurum.ItemIndex]);
   GelisEkle(PNO);
end;

procedure TUcretAraDlg.GelisEkleTusClick(Sender: TObject);
begin
   GelisEkle(Tablo.TabKimlik.Parameters[0].Value);
end;

procedure TUcretAraDlg.HesapUcretSatirDoldur;
var Ad, Dr, Birim, Grup, OzelKod, ButceKodu, MuhKodu: String;
    KDV : Integer;
    Isk : Real;
    Birimfiyat, DoktorPayi:Currency;
begin

   Ad := TabHesapla.FieldByName('ACIKLAMA').AsString;
   Birim := ComboBirim.Text;
   Dr:='';
   if TabHesapla.FieldByName('KOD').AsString<>'' then
      ParaBilgiGetir(TabHesapla.FieldByName('KOD').AsString, TabHesapla.FieldByName('TUR').AsString, Ad, Dr,Birim, OzelKod,ButceKodu,
                     MuhKodu,Grup, GenotipINI.BugunTrh, KDV, Isk, Birimfiyat, ComboKurum.Text, 'Dahil',True);

   TabHesapla.FieldbyName('BIRIM').AsString := Birim;
   TabHesapla.FieldbyName('ACIKLAMA').AsString := Ad;
   TabHesapla.FieldbyName('BIRIMFIYAT').AsCurrency := Birimfiyat;
   TabHesapla.FieldbyName('ISKONTO').AsCurrency := Isk;
   TabHesapla.FieldbyName('TUTAR').AsFloat:= TabHesaplaADET.AsFloat*(Birimfiyat*(100-Isk))/100;
end;

procedure TUcretAraDlg.FaturaUcretSatirDoldur;
var Ad, Dr, Birim, Grup, OzelKod, ButceKodu, MuhKodu: String;
    KDV : Integer;
    Isk : Real;
    Birimfiyat, DoktorPayi:Currency;
begin
   Ad := Tablo.TabFatura.FieldByName('ACIKLAMA').AsString;
   Birim := ComboBirim.Text;
   Dr:='';
   if Tablo.TabFatura.FieldByName('KOD').AsString<>'' then
      ParaBilgiGetir(Tablo.TabFatura.FieldByName('KOD').AsString, Tablo.TabFatura.FieldByName('TUR').AsString, Ad, Dr,Birim, OzelKod,ButceKodu,
                     MuhKodu,Grup, GenotipINI.BugunTrh, KDV, Isk, Birimfiyat, ComboKurum.Text, 'Dahil',True);

   Tablo.TabFatura.FieldbyName('ACIKLAMA').AsString := Ad;
   Tablo.TabFatura.FieldbyName('BIRIMFIYAT').AsCurrency := Birimfiyat;
   Tablo.TabFatura.FieldbyName('ISKONTO').AsCurrency := Isk;
   Tablo.TabFatura.FieldbyName('TUTAR').AsFloat:= Tablo.TabFatura.FieldbyName('ADET').AsFloat*(Birimfiyat*(100-Isk))/100;
   Tablo.TabFatura.FieldbyName('KDV').AsInteger := KDV;
   Tablo.TabFatura.FieldbyName('OZELKOD').AsString := OzelKod;
   Tablo.TabFatura.FieldbyName('BUTCEKODU').AsString := ButceKodu;
   Tablo.TabFatura.FieldbyName('MUHKODU').AsString := MuhKodu;
end;

procedure TUcretAraDlg.Button1Click(Sender: TObject);
//VAR S : string[20];
begin
{    tablo.Query1.SQL.Text := 'Select KOD From ISLEMLER where Kod Like '''+Edit1.Text+'%''';
    tablo.Query1.Open;
    tablo.Query1.first;
    while not tablo.Query1.eof do begin
      s:= tablo.Query1.Fields[0].AsString; //A.1
      if s[Length(s)-1] = '.' then Insert('00', s, Length(s))
      else if s[Length(s)-2] = '.' then Insert('0', s, Length(s)-1);

      tablo.Query2.SQL.Text := 'Update ISLEMLER set KOD='''+s+''' where Kod ='''+tablo.Query1.Fields[0].AsString+'''';
      tablo.Query2.execSQL;
      tablo.Query2.SQL.Text := 'Update FIYATLAR set KOD='''+s+''' where Kod ='''+tablo.Query1.Fields[0].AsString+'''';
      tablo.Query2.execSQL;
      tablo.Query2.SQL.Text := 'Update TETND set KOD='''+s+''' where Kod ='''+tablo.Query1.Fields[0].AsString+'''';
      tablo.Query2.execSQL;
      tablo.Query1.next;
    end;
 }
end;

procedure TUcretAraDlg.Button2Click(Sender: TObject);
begin
{    tablo.Query1.SQL.Text := 'Select * From FIYATLAR where FIYATADI = ''TTB'' AND KOD LIKE ''L.%''';
    tablo.Query1.Open;
    tablo.Query1.first;
    while not tablo.Query1.eof do begin
      if tablo.Query1.Fieldbyname('KATSAYI').AsString <> '' then begin
         tablo.Query2.SQL.Text := 'Update FIYATLAR SET KATSAYI = '+tablo.Query1.Fieldbyname('KATSAYI').AsString+
         ' where KOD='''+tablo.Query1.Fieldbyname('KOD').AsString+''' and FIYATADI=''SONOMED''';
         tablo.Query2.execSQL;
      end;
      tablo.Query1.next;
    end;}
end;

procedure TUcretAraDlg.ListeTusClick(Sender: TObject);
begin
   AgacTus.Down := False;
   ListeTus.Down := True;
   DBGrid1.BringToFront;
end;

procedure TUcretAraDlg.Y00Click(Sender: TObject);
var Yuzde, Sec : String[15];
    MesajOkunan : String;
begin
   if (TMenuItem(Sender).Tag = 1)and(TMenuItem(Sender).Name <> 'Ozel') then
      Yuzde :=  copy(TMenuItem(Sender).Name,2,2);
   if TMenuItem(Sender).Name = 'Ozel' then begin
      MesajOkunan := '';
      if MesajStrAl('','İndirim Yüzdesini Giriniz :','E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then
         Yuzde := MesajOkunan
      else
         Yuzde := '-1';
   end;

   if Yuzde = '-1' then exit;

   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text := 'Select KOD From KURUMISK where KURUM = '''+ComboKurum.Items[ComboKurum.ItemIndex]+''' and ISKONTO = 0';
   Tablo.Query3.Open;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Clear;
   Tablo.Query1.SQL.Add('Update HESAPLA Set ISKONTO ='+Yuzde);
   Tablo.Query1.SQL.Add('Where KULLANICI ='''+Kullanan+'''');

   Tablo.Query3.First; //İskontosu 0 olanları ekle
   while not Tablo.Query3.eof do begin
     Tablo.Query1.SQL.Add('and not KOD LIKE '''+Tablo.Query3.Fields[0].AsString+'%''');
     Tablo.Query3.Next;
   end;

   Tablo.Query1.ExecSQL;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Clear;
   Tablo.Query1.SQL.Add('Update HESAPLA Set TUTAR = ADET*BIRIMFIYAT*(100-ISKONTO)/100');
   Tablo.Query1.SQL.Add(' Where KULLANICI ='''+Kullanan+'''');
   Tablo.Query3.First; //İskontosu 0 olanları ekle
   while not Tablo.Query3.eof do begin
     Tablo.Query1.SQL.Add('and not KOD LIKE '''+Tablo.Query3.Fields[0].AsString+'''');
     Tablo.Query3.Next;
   end;
   Tablo.Query1.ExecSQL;
//   tABLO.ToplamUcretHesapla;
   TabHesapla.Close;
   TabHesapla.Open;
   TabHesaplaAfterPost(TabHesapla);
end;

procedure TUcretAraDlg.TabHesaplaADETChange(Sender: TField);
begin
   if (TabHesaplaADET.AsString = '')or(TabHesaplaBIRIMFIYAT.AsString = '') then exit;
   TabHesaplaTUTAR.AsCurrency := (100-TabHesaplaISKONTO.AsFloat)*TabHesaplaADET.AsFloat * TabHesaplaBIRIMFIYAT.AsFloat/100;
end;

procedure TUcretAraDlg.QueryIslemAfterScroll(DataSet: TDataSet);
begin
   if (StokVar)and(not UcretDuzenleme) then
      ComboBirim.ItemIndex := ComboBirim.Items.IndexOf(QueryIslem.FieldByName('ANABIRIM').AsString);
end;

procedure TUcretAraDlg.DoktorSecTusClick(Sender: TObject);
begin
   DoktorDlg.DBNavigator.VisibleButtons :=[];
   DoktorDlg.ShowModal;

   if DoktorDlg.TabDoktor.Fields[1].AsString<> '' then begin
      LabelDOKTORKOD.Caption:= DoktorDlg.TabDoktor.Fields[0].AsString;
      ComboDOKTOR.Text := Trim(DoktorDlg.TabDoktor.Fields[1].AsString);
      if DokListesi='DOKTORLAR' then begin
         Tablo.Query5.Close;
         Tablo.Query5.SQL.Text := 'select isnull(INDIRIMKURUMU,'''') from DOKTORLAR where DOKTORKOD='''+DoktorDlg.TabDoktor.Fields[0].AsString+'''';
         Tablo.Query5.Open;
         if Tablo.Query5.Fields[0].AsString <> '' then
            ComboKURUM.ItemIndex := ComboKURUM.Items.Indexof(Trim(Tablo.Query5.Fields[0].AsString));
      end;
    end
   else begin
      LabelDOKTORKOD.Caption := '';
      ComboDOKTOR.Text := Trim(DoktorDlg.AramaAd.Text);
   end;
   TutAranan.Setfocus;
//   ComboPol.ItemIndex:= ComboPol.Items.IndexOf(DoktorDlg.TabDoktor.Fields[2].AsString);


{
   ComboDOKTOR.Text := DoktorDlg.TabDoktor.Fields[1].AsString;

   Tablo.Query4.SQL.Text := 'Select UZMANLIK From DOKTOR where DOKTOR = '''+ComboDOKTOR.Text+'''';
   Tablo.Query4.Open;
   ComboPol.ItemIndex:= ComboPol.Items.IndexOf(Tablo.Query4.Fields[0].AsString);}
//   ComboPol.Text := Tablo.Query4.Fields[0].AsString;
end;

procedure TUcretAraDlg.ComboPolExit(Sender: TObject);
begin
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text := 'Select DOKTOR From DOKTOR Where UZMANLIK='''+ComboPOL.Text+''' AND DURUM<>''PASİF''';
   Tablo.Query3.Open;
   ComboDOKTOR.Text:= Tablo.Query3.Fields[0].AsString;
end;

procedure TUcretAraDlg.ToolButton1Click(Sender: TObject);
begin
   if TetkikDlg=nil then
      Application.CreateForm(TTetkikDlg, TetkikDlg);
   TetkikDlg.Show;
end;

procedure TUcretAraDlg.KapatTusClick(Sender: TObject);
begin
   Close;
end;

procedure TUcretAraDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   case Key of
     VK_F11, VK_Escape : KapatTus.Click;
//     VK_Return : EkleTus.Click;
     70 : if Shift = [ssCtrl] then
             if not FisBilgisi then begin
                UcretAraDlg.Close ;
                exit;
              end;
   end;
end;

procedure TUcretAraDlg.AraKodKeyPress(Sender: TObject; var Key: Char);
begin
 if (key = #13)and(not QueryIslem.IsEmpty) then
     EkleTus.Click;
end;

procedure TUcretAraDlg.AraKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (Key = 13)or(Key = 9) then exit
   else if (Shift = [ssAlt])and(Key = 65) then AgacTus.Click
   else if (Shift = [ssAlt])and(Key = 76) then ListeTus.Click
   else if Key = 38 then QueryIslem.Prior
   else if Key = 40 then QueryIslem.next
   else AraBul('ISLEMLER', 'KOD', 'ISLEMADI', 'GRUP');
end;

procedure TUcretAraDlg.DBGrid2DblClick(Sender: TObject);
begin
   Application.CreateForm(TTetkikDetayDlg, TetkikDetayDlg);
   TetkikDetayDlg.Kodu := TabHesapla.FieldByName('KOD').AsString;
   TetkikDetayDlg.ShowModal;
   TetkikDetayDlg.Destroy;
end;

procedure TUcretAraDlg.YaziciYazMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if Button=mbLeft then begin
      RapTablo.Hesapla.Close;
      RapTablo.Hesapla.Parameters[0].Value:= TabHesapla.Fields[0].AsString;
      RapTablo.Hesapla.Open;

      TabloDokum.Ekran_Yazici_Islemi(Sender);
   end
   else
      AyarlarDlgEkran('Ücr._');

end;

procedure TUcretAraDlg.FormPaint(Sender: TObject);
begin
   if (FisBilgisiAl)and(Cagiran=0)and(Tablo.TabGelisler.FieldByName('TEDAVI').AsString='Ayakta') then
       if not FisBilgisi then begin
           UcretAraDlg.Close ;
           exit;
       end;
end;

procedure TUcretAraDlg.FormClose(Sender: TObject; var Action: TCloseAction);
var gno : Smallint;
begin
   if Cagiran = 0 then begin
      gno := Tablo.TabGelisler.Fields[1].AsInteger;
      Tablo.TabGelisler.Close;
      Tablo.TabGelisler.Open;
      Tablo.TabGelisler.Locate('GELISNO',gno,[]);
   end;
{  if Cagiran = 0 then
     ParaTablosunuGuncelle  }
end;

procedure TUcretAraDlg.RadioButton1Click(Sender: TObject);
begin
   AraBul('ISLEMLER', 'KOD', 'ISLEMADI', 'GRUP');
   GenotipIni.WriteBool('GenelOpsiyon', 'UcretAdSeçimi', UcretAraDlg.RadioButton1.Checked);
end;

procedure TUcretAraDlg.IsleminUcretiniSorMenuClick(Sender: TObject);
var MesajOkunan : String;
begin
   MesajOkunan := '';
   if MesajStrAl('','Ücreti Giriniz :','E', nil,MesajOkunan, '', 'E', nil,MesajOkunan) then begin
      MesajOkunan := Trim(MesajOkunan);
      if MesajOkunan='' then
         AlinanFiyat := 0.0
      else
         AlinanFiyat := StrToFloat(MesajOkunan);
      EkleTus.Click;
   end;
end;

procedure TUcretAraDlg.ExceleGnder1Click(Sender: TObject);
begin
    DokumDlg.ExceleYazdir(TabHesapla, DBGrid2);
end;

end.




