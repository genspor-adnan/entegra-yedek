unit UImport;
{Cari : 110
Cari Personel Temel :120
Fatura Giriş  : 11
Fatura Çıkış  : 15
İrsaliye Giriş  : 10
İrsaliye Çıkış  : 14
Stok Kart     : 150
Stok Çevrim   : 160
Stok Fiyat    : 170
Çek Giriş
Çek Çıkış
PDKS Giriş
PDKS Çıkış
}
interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ComCtrls, ExtCtrls, dxSkinsCore, dxSkinLondonLiquidSky,
  dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxPC, ToolWin, cxDropDownEdit, cxImageComboBox, cxDBEdit, cxMaskEdit,
  cxSpinEdit, cxContainer, cxTextEdit, FireDAC.Comp.Client, Dialogs, cxButtonEdit, cxMemo,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinXmas2008Blue, Menus, cxLookAndFeels,
  cxLookAndFeelPainters, cxPCdxBarPopupMenu, cxNavigator, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, dxBarBuiltInMenu;

type
  TImportDlg = class(TForm)
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    ToolButton2: TToolButton;
    DokumTus: TToolButton;
    cxTabControl1: TcxTabControl;
    ToolButton5: TToolButton;
    btnKapat: TToolButton;
    ToolButton6: TToolButton;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBSpinEdit1: TcxDBSpinEdit;
    cxDBSpinEdit2: TcxDBSpinEdit;
    cxDBImageComboBox1: TcxDBImageComboBox;
    cxDBImageComboBox2: TcxDBImageComboBox;
    DtsImport: TDataSource;
    TabDetay: TFDQuery;
    DtsDetay: TDataSource;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton4: TToolButton;
    Label7: TLabel;
    ComboMODUL: TcxDBComboBox;
    OpenDialog1: TOpenDialog;
    cxDBButtonEdit1: TcxDBButtonEdit;
    cxDBImageComboBox3: TcxDBImageComboBox;
    Label8: TLabel;
    cxPageControl1: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    ToolBar3: TToolBar;
    DetayEkleTus: TToolButton;
    DetaySilTus: TToolButton;
    DetayKaydetTus: TToolButton;
    DetayIptalTus: TToolButton;
    GridBanka: TcxGrid;
    GridBankaDBTableView1: TcxGridDBTableView;
    GridBankaDBTableView1ALAN: TcxGridDBColumn;
    GridBankaDBTableView1TUR: TcxGridDBColumn;
    GridBankaDBTableView1ZORUNLU: TcxGridDBColumn;
    GridBankaDBTableView1KOLON: TcxGridDBColumn;
    GridBankaDBTableView1KURAL: TcxGridDBColumn;
    GridBankaDBTableView1VARSAYILAN: TcxGridDBColumn;
    GridBankaDBTableView1ISLEM: TcxGridDBColumn;
    GridBankaLevel1: TcxGridLevel;
    Memo1: TcxMemo;
    Label9: TLabel;
    cxDBSpinEdit3: TcxDBSpinEdit;
    PmSagClick: TPopupMenu;
    lgilieklemekiinExcel1: TMenuItem;
    lgiliyiExcelden1: TMenuItem;
    N1: TMenuItem;
    letiimiinExcelolutur1: TMenuItem;
    Exceldeniletiimaktar1: TMenuItem;
    N2: TMenuItem;
    Geniniyeekle1: TMenuItem;
    TabImport: TFDQuery;
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure DetayEkleTusClick(Sender: TObject);
    procedure TabDetayNewRecord(DataSet: TDataSet);
    procedure TabImportAfterScroll(DataSet: TDataSet);
    procedure DtsImportStateChange(Sender: TObject);
    procedure DtsDetayStateChange(Sender: TObject);
    procedure DokumTusClick(Sender: TObject);
    procedure cxDBButtonEdit1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabImportBeforePost(DataSet: TDataSet);
    procedure DetaySilTusClick(Sender: TObject);
    procedure DetayKaydetTusClick(Sender: TObject);
    procedure DetayIptalTusClick(Sender: TObject);
    procedure GridBankaDBTableView1VARSAYILANPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure TabImportNewRecord(DataSet: TDataSet);
    procedure lgilieklemekiinExcel1Click(Sender: TObject);
    procedure lgiliyiExcelden1Click(Sender: TObject);
  private
    { Private declarations }
    procedure ExceldenOku;
    function ListeBolumAdiGetir(Modul, Alan : string) : integer;
  public
    { Public declarations }
    ImportId : Integer;
  end;

var
  ImportDlg: TImportDlg;

implementation
uses Utablo, ComObj, Variants, FetaKurulusSiniflari, PrjConst, UBekletme,UGirisKutusuEx;
{$R *.dfm}

var
  BagliOlduguTablo, HedefTabloAdi, OncekiFatNo, SimdikiFatNo : string;
  KodKolonNo : Integer;
  SonEklenenRehberIletisimId : Integer;
  SKTKolon,LotKolon: Variant;
  Excel, kitap, sayfa: olevariant;

procedure TImportDlg.cxDBButtonEdit1Click(Sender: TObject);
begin
   if OpenDialog1.Execute then begin
      TabImport.Edit;
      TabImport.FieldByName('DOSYAADI').AsString := OpenDialog1.FileName
   end;
end;

procedure TImportDlg.DetayEkleTusClick(Sender: TObject);
var s,Zorunlu : string;
    i : Integer;
   procedure DetayaEkle(Yeri:Integer); //burada alanlar ekleniyor
   var  i : Integer;
   begin
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text := 'select top 1 * from '+s;
         Tablo.Query1.Open;
         for i := 1 to Tablo.Query1.FieldCount - 1 do begin
             TabDetay.Append;
             if (i = 1) and ((s = 'STOKFIYAT')or(s = 'STOKCEVRIM')) then
                TabDetay.FieldByName('ALAN').AsString := 'KOD' //stokid alanı yerine kod görünsün
             else
                TabDetay.FieldByName('ALAN').AsString := Tablo.Query1.Fields[i].FieldName;
            TabDetay.FieldByName('YERI').AsInteger := Yeri;
            TabDetay.FieldByName('ZORUNLU').AsBoolean := pos(TabDetay.FieldByName('ALAN').AsString+',', Zorunlu)>0;
            //if Pos('var') then
            TabDetay.Post;
         end;
   end;
   procedure RehberAyarEkle(s:string);
   begin
         Tablo.Query1.Close;       // varsayılanlar listeleniyor         isnull(VARSAYILAN,'''')<>'''' and
         Tablo.Query1.SQL.Text := 'select DISTINCT SIRA, ETIKET, YERI from REHBERAYAR where  YERI in ('+s+') order by 2,1';
         Tablo.Query1.Open;
         while not Tablo.Query1.eof do begin
             TabDetay.Append;
             TabDetay.FieldByName('SIRA').AsString := Tablo.Query1.Fields[0].AsString;
             TabDetay.FieldByName('ALAN').AsString := Tablo.Query1.Fields[1].AsString;
             TabDetay.FieldByName('YERI').AsString := Tablo.Query1.Fields[2].AsString;
             TabDetay.post;
             Tablo.Query1.Next;
        end;   end;
begin
   if TabImport.state in [dsEdit, dsInsert] then
      TabImport.Post;

   if TabImport.FieldByName('MODUL').AsString = 'Cari' then begin
      s := 'REHBER';
      Zorunlu := 'KOD,FIRMA,STATU,DURUM,GRUP,'
   end else if TabImport.FieldByName('MODUL').AsString = 'Cari Personel Temel' then begin
        s := 'REHBER_PER_TEMEL';
        Zorunlu := 'KOD';
        TabDetay.Append;
        TabDetay.FieldByName('ALAN').AsString := 'KOD';
        TabDetay.FieldByName('YERI').AsInteger := 0;
        TabDetay.FieldByName('ZORUNLU').AsBoolean := True;
        TabDetay.post;
        RehberAyarEkle('3');
        exit;
   end else if (TabImport.FieldByName('MODUL').AsString = 'Fatura Giriş')or(TabImport.FieldByName('MODUL').AsString = 'Fatura Çıkış') then begin
      s := 'FATBASLIK';
      Zorunlu := '(TUR,TIPI,REHBERID,FATURATARIH,FATURANO,GIRISDEPO,KDVDURUM,FATURA_MATRAHI,KDV_TUTARI,EKVERGI,FATURA_TUTARI,KUR,DURUM,)';
      DetayaEkle(1);
      s := 'FATURA';
      Zorunlu := '(TUR,KOD,AD,ADET,BIRIM,BIRIMFIYAT,KUR,ISKONTO,KDV,)';
      DetayaEkle(2);
      Exit;
   end else if TabImport.FieldByName('MODUL').AsString = 'Stok Kart' then begin
      s := 'STOKLAR';
      Zorunlu := '(KOD,STOKADI,ANABIRIM,KDV,DURUM,TIPI,STATU,IZLEME,)'
   end
   else if TabImport.FieldByName('MODUL').AsString='Stok Çevrim' then begin
      s := 'STOKCEVRIM';
      Zorunlu := '(ADET1,BIRIM1,ADET2,BIRIM2,)'
   end
   else if TabImport.FieldByName('MODUL').AsString='Stok Fiyat' then begin
      s := 'STOKFIYAT';
      Zorunlu := '(KOD,FIYATADI,BIRIM,FIYAT,KUR,)'
   end else if (TabImport.FieldByName('MODUL').AsString = 'Çek Giriş')or(TabImport.FieldByName('MODUL').AsString = 'Çek Çıkış') then begin
      s := 'CEKLER';
      Zorunlu := '(KOD,REHBERID,BANKASUBELERID,TUR,DURUM,TARIH,ODEMEYERI,VADE,SERINO,TUTAR,KUR,MAKBUZNO,BASKASININ,ANIMSAT,)';
   end else if (TabImport.FieldByName('MODUL').AsString = 'PDKS Giriş')or(TabImport.FieldByName('MODUL').AsString = 'PDKS Çıkış') then begin
      s := 'PERS_PDKS';
      Zorunlu := '(KARTNO,GIRIS,CIKIS,EKLEMETARIHI],)';
   end;
   DetayaEkle(0);

   if s = 'REHBER' then begin//Kurum İletişim bilgilerini ekleyelim
        RehberAyarEkle('1,2');
        //şimdi borç alacak ekleyelim
        TabDetay.Append;
        TabDetay.FieldByName('ALAN').AsString := 'Yetkili';
        TabDetay.FieldByName('YERI').AsInteger:= 20;
        TabDetay.post;
        TabDetay.Append;
        TabDetay.FieldByName('ALAN').AsString := 'Yetkili Cep Tel';
        TabDetay.FieldByName('YERI').AsInteger:= 24;
        TabDetay.post;
        TabDetay.Append;
        TabDetay.FieldByName('ALAN').AsString := 'Yetkili E-Posta';
        TabDetay.FieldByName('YERI').AsInteger:= 25;
        TabDetay.post;
        //şimdi borç alacak ekleyelim
        TabDetay.Append;
        TabDetay.FieldByName('ALAN').AsString := 'Borç (veya Bakiye)';
        TabDetay.FieldByName('YERI').AsInteger:= 21;
        TabDetay.post;
        TabDetay.Append;
        TabDetay.FieldByName('ALAN').AsString := 'Alacak';
        TabDetay.FieldByName('YERI').AsInteger:= 22;
        TabDetay.post;
        TabDetay.Append;
        TabDetay.FieldByName('ALAN').AsString := 'Para Birimi';
        TabDetay.FieldByName('YERI').AsInteger := 23;
        TabDetay.post;
   end;
end;

procedure TImportDlg.DetayIptalTusClick(Sender: TObject);
begin
   TabDetay.Cancel;
end;

procedure TImportDlg.DetayKaydetTusClick(Sender: TObject);
begin
   TabDetay.Post;
end;

procedure TImportDlg.DetaySilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabDetay.Delete;
end;

procedure TImportDlg.ExceldenOku;
var
    tut, FaturaNo, ilgili: string;
    sat, Bitis, FatNoKolonu : Integer;
    BagliId, RehberId : Integer;
    function BagliIdGetir(Kod:string) : Integer;
    begin
      if BagliOlduguTablo='' then
         Result := 0
      else begin
         Tablo.Query1.Close;
         Tablo.Query1.SQL.Text := 'select ID from '+BagliOlduguTablo+' where KOD = '''+Trim(Kod)+''' ';
         Tablo.Query1.Open;
         if Tablo.Query1.RecordCount>0 then
            Result := Tablo.Query1.Fields[0].AsInteger
         else begin
            Result := -1;
            Memo1.Lines.Add(BagliOlduguTablo+' tablosunda bulunamayan : '+Trim(Kod));
         end;
      end;
    end;

    function  IniListedenKarsilikGetir(tut, Varsayilan: string ): string;
    var  yenideger : string;
        Deger,Liste:Integer;
    begin
        if tut = '' then
           tut := Varsayilan
        else begin
           Liste := ListeBolumAdiGetir(TabImport.FieldByName('MODUL').AsString, Tablo.Query6.FieldByName('ALAN').AsString);
           Deger := Tablo.GenIni.ReadStringDiller(Liste, Tut, 0); /// ( Liste, tut, '#yok#');
           if Deger =  0then begin//ekleyelim
              //Tablo.TablodanSorguAc(1,' select isnull(max(DEGER),50)+1 from GENINI where BOLUM = '+IntToStr(Liste));
              //yenideger := Tablo.Query1.Fields[0].AsString;
              Tut :=IntToStr( Tablo.GenIni.WriteStrDiller(Liste, tut));// ,   yenideger

           end else
              Tut := IntToStr(Deger);
        end;
        Result := Tut
    end;

    function  RehberdenKarsilikGetir(tut:string): string;
    var  yenideger : string;
        Deger,Liste:Integer;
    begin
        if tut = '' then
           tut := '0'
        else begin
            Tablo.Query4.Close;
            Tablo.Query4.SQL.Text:='select top 1 ID from REHBER RA where FIRMA='''+tut+'''';
            Tablo.Query4.Open;
            if Tablo.Query4.RecordCount>0 then //ekleyelim
               Tut := Tablo.Query4.fields[0].AsString
            else
               tut := '0';
        end;
        Result := Tut
    end;

    function TutDegeriniGetir : string;
    begin
        if (Tablo.Query6.FieldByName('KOLON').AsString = '')or(Tablo.Query6.FieldByName('KOLON').AsString = '0') then
           tut := ''
        else
           tut := Trim(sayfa.Cells[Sat, Tablo.Query6.FieldByName('KOLON').AsInteger].Value);

        if tut='' then
           case Tablo.Query6.FieldByName('KURAL').AsInteger of
             1 : tut := Tablo.Query6.FieldByName('VARSAYILAN').AsString; //1 : varsayılanı al
             2 : ;//boş kalsın
             3 : ;//ekrandan sorsun
             4 : begin //dursun
                   Tablo.Query5.Cancel;
                   ShowMessage(Tablo.Query6.FieldByName('ALAN').AsString+' verisi '+IntToStr(sat)+'. satırda bulunamadı! Aktarım durduruldu!');
                   Exit;
                 end;


           end
        else
               if (Tablo.Query6.FieldByName('TUR').AsString = '4')or(Tablo.Query6.FieldByName('TUR').AsString = '5') then begin
                  if (FormatSettings.Decimalseparator=',')and(Pos('.', tut)>0) then
                      tut := StringReplace(tut, '.', ',',[rfReplaceAll])
                  else if (FormatSettings.Decimalseparator='.')and(Pos(',', tut)>0) then
                      tut := StringReplace(tut, ',', '.',[rfReplaceAll])
               end
               else if Tablo.Query6.FieldByName('TUR').AsString = '11' then     //iniden liste
                       tut := IniListedenKarsilikGetir(tut, Tablo.Query6.FieldByName('VARSAYILAN').AsString)
               else if Tablo.Query6.FieldByName('TUR').AsString = '15' then     //iniden liste
                       tut := RehberdenKarsilikGetir(tut);

        Result := tut;
    end;

    procedure Kurum_Iletisim_Ekle(RehberId, IletisimId : Integer);
    var borc,alacak : Currency;
        kur : string;
        s : string;
        SonEklenenRehberId :Integer;
    begin
       SonEklenenRehberId := -1;
       Tablo.Query6.First;
       while not Tablo.Query6.eof do begin
          if Tablo.Query6.FieldbyName('YERI').asinteger = 1 then begin
            Tablo.Query4.Close;
            Tablo.Query4.SQL.Text:='select RA.YERI,RA.ETIKET,RA.SIRA from REHBERAYAR RA where RA.YERI='+Tablo.Query6.FieldbyName('YERI').AsString+' and RA.ETIKET='''+Tablo.Query6.FieldbyName('ALAN').AsString+'''';
            Tablo.Query4.Open;
            Tablo.Query3.Close;
            s:= TutDegeriniGetir;
            if s<>'' then begin
              Tablo.Query3.SQL.Text := 'IF NOT EXISTS (select YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN FROM REHBERBILGI '+
                             ' WHERE YERI='+Tablo.Query6.FieldbyName('YERI').AsString+' AND SIRA='+Tablo.Query4.FieldByName('SIRA').AsString+' AND YER_ID='+inttostr(IletisimId)+')'+
                             ' INSERT INTO REHBERBILGI(YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN,SUBEID)VALUES('+Tablo.Query6.FieldbyName('YERI').AsString+','+Tablo.Query4.FieldbyName('SIRA').AsString+','+inttostr(SonEklenenRehberIletisimId)+','''+
                             Tablo.Query4.FieldByName('ETIKET').AsString+''','''+s+''','''+Kullanan+''','+IntToStr(SubeId)+')' ;
              Tablo.Query3.ExecSQL;
            end;
             // end;
             // if Tablo.Query5.FieldByName('YERI').AsString='' then
             // Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
          end
          else if Tablo.Query6.FieldbyName('YERI').asinteger in[2] then begin
            Tablo.Query4.Close;
            Tablo.Query4.SQL.Text:='select RA.YERI,RA.ETIKET,RA.SIRA from REHBERAYAR RA where RA.YERI=2 and RA.ETIKET='''+Tablo.Query6.FieldbyName('ALAN').AsString+'''';
            Tablo.Query4.Open;
            Tablo.Query3.Close;
            s:= TutDegeriniGetir;
            if s<>'' then begin
              Tablo.Query3.SQL.Text := 'IF NOT EXISTS (select YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN FROM REHBERBILGI '+
                             ' WHERE YERI=2 AND SIRA='+Tablo.Query4.FieldByName('SIRA').AsString+' AND YER_ID='+inttostr(RehberId)+')'+
                             ' INSERT INTO REHBERBILGI(YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN,SUBEID)VALUES('+Tablo.Query6.FieldbyName('YERI').AsString+','+Tablo.Query4.FieldbyName('SIRA').AsString+','+inttostr(RehberId)+','''+
                             Tablo.Query4.FieldByName('ETIKET').AsString+''','''+s+''','''+Kullanan+''','+IntToStr(SubeId)+')' ;
              Tablo.Query3.ExecSQL;
            end;
             // end;
             // if Tablo.Query5.FieldByName('YERI').AsString='' then
             // Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
          end
          else if Tablo.Query6.FieldbyName('YERI').asinteger=20 then begin //Yetkili
           ilgili := TutDegeriniGetir;
           if ilgili <> '' then begin
              Tablo.Query3.Close;        //önce ilgili eklenmiş mi ona bakalım
              Tablo.Query3.SQL.Text := 'SELECT ID FROM REHBERPERSONEL WHERE REHBERID='+inttostr(RehberId)+' AND ADSOYAD='''+ilgili+''' ';
              Tablo.Query3.Open;
              if Tablo.Query3.RecordCount>0 then // eklenmişse
                 SonEklenenRehberId := Tablo.Query3.Fields[0].AsInteger
              else begin
                  Tablo.Query3.Close;           //eklenmemiş
                  Tablo.Query3.SQL.Text := 'INSERT INTO REHBERPERSONEL(REHBERID,ADSOYAD,VARSAYILAN,EKLEYEN,SUBEID) VALUES('+
                                 inttostr(RehberId)+','''+ilgili+''',1,'''+Kullanan+''','+IntToStr(SubeId)+') select scope_identity() ' ;
                  Tablo.Query3.Open;
                  SonEklenenRehberId := Tablo.Query3.Fields[0].AsInteger;
              end;
           end;
          end
          else if Tablo.Query6.FieldbyName('YERI').asinteger=24 then begin //Yetkili Cep Tel
            ilgili := TutDegeriniGetir;
            if (SonEklenenRehberId>0)and(ilgili<>'') then begin //önce yetkilinin eklenmiş olması lazım
              Tablo.Query4.Close;
              Tablo.Query4.SQL.Text:='select RA.YERI,RA.ETIKET,RA.SIRA from REHBERAYAR RA where RA.YERI=4 and RA.VARSAYILAN = 42';
              Tablo.Query4.Open;
              if Tablo.Query4.RecordCount<1 then
                 raise Exception.Create('Cari opsiyonlarda personel iletişimde Cep Tel için varsayılan alanı doldurun!');


              Tablo.Query3.Close;
              Tablo.Query3.SQL.Text := 'IF NOT EXISTS (select YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN FROM REHBERBILGI '+
                             ' WHERE YERI=4 AND SIRA='+Tablo.Query4.FieldByName('SIRA').AsString+' AND YER_ID='+inttostr(SonEklenenRehberId)+')'+
                             ' INSERT INTO REHBERBILGI(YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN,SUBEID ) VALUES(4,'+Tablo.Query4.FieldByName('SIRA').AsString+
                             ','+inttostr(SonEklenenRehberId)+','''+Tablo.Query4.FieldByName('ETIKET').AsString+''','''+ilgili+''','+Kullanan+','+IntToStr(SubeId)+')' ;
              Tablo.Query3.ExecSQL;
            end;
          end
          else if Tablo.Query6.FieldbyName('YERI').asinteger=25 then begin //Yetkili E-Posta
           ilgili := TutDegeriniGetir;
           if (SonEklenenRehberId>0)and(ilgili<>'') then begin //önce yetkilinin eklenmiş olması lazım

              Tablo.Query4.Close;
              Tablo.Query4.SQL.Text:='select RA.YERI,RA.ETIKET,RA.SIRA from REHBERAYAR RA where RA.YERI=4 and RA.VARSAYILAN = 46';
              Tablo.Query4.Open;
              if Tablo.Query4.RecordCount<1 then
                 raise Exception.Create('Cari opsiyonlarda personel iletişimde E-Posta için varsayılan alanı doldurun!');


              Tablo.Query3.Close;
              Tablo.Query3.SQL.Text := 'IF NOT EXISTS (select YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN FROM REHBERBILGI '+
                             ' WHERE YERI=4 AND SIRA='+Tablo.Query4.FieldByName('SIRA').AsString+' AND YER_ID='+inttostr(SonEklenenRehberId)+')'+
                             ' INSERT INTO REHBERBILGI(YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN,SUBEID) VALUES(4,'+Tablo.Query4.FieldByName('SIRA').AsString+
                             ','+inttostr(SonEklenenRehberId)+','''+Tablo.Query4.FieldByName('ETIKET').AsString+''','''+ilgili+''','+Kullanan+','+IntToStr(SubeId)+')' ;
              Tablo.Query3.ExecSQL;
           end;
          end
          else if Tablo.Query6.FieldbyName('YERI').asinteger=21 then begin //borc,alacak,kur
                  borc := StrToCurrDef(TutDegeriniGetir,0.0);
                  Tablo.Query6.Next;
                  alacak:= StrToCurrDef(TutDegeriniGetir,0.0);
                  Tablo.Query6.Next;
                  kur:= TutDegeriniGetir;
                  Tablo.Query6.Next;
                  if Borc=alacak then
                     alacak := 0;
                  if Borc<0 then begin
                     alacak := abs(borc);
                     borc := 0;
                  end;
                  Tablo.KasaKaydet(1001, Tablo.GenIni.BugunTrh, Tablo.GenIni.BugunTrh, RehberId, 'Açılış Fişi',
                                    0, Kur,'', 0,Borc,Alacak,0,-1, -1,-1,-1,-1, SubeId,' ');

          end;
          Tablo.Query6.Next;
       end;
      // Tablo.Query5.Post;

    end;
   function Kurum_Ticari_Ekle(RehberId : Integer):boolean;
   begin


   end;

   function FaturadakiKodlarStoktaveCarideVarmi(TabloAdi, ArananAlan:String)  : Boolean;
   var kodKolonu : Integer;
       Hata : Boolean;
   begin
     Tablo.TablodanSorguAc(1,'select KOLON from IMPORTDETAY where ALAN='''+ArananAlan+''' and IMPORTID='+TabDetay.FieldByName('IMPORTID').AsString);
     kodKolonu := Tablo.Query1.Fields[0].AsInteger;
     Hata := False;
     sat := TabImport.FieldByName('BASLA').AsInteger;
     while sat <= TabImport.FieldByName('BITIS').AsInteger do begin
         //Memo1.Lines.Add(inttostr(sat)+' '+inttostr(kodKolonu));
         tut := VarToStr(sayfa.Cells[Sat, kodKolonu].Value);
         //Memo1.Lines.Add(tut);
         if not Veritabani.VeriVarMi(Tablo.FDCnn, 'select ID from '+TabloAdi+' where KOD =  &SId', ['&SId'],[Tut]) then begin
            Memo1.Lines.Add(tut + ' kodlu ürün '+TabloAdi+' tanımlı değil, tanımlayın.');
            Hata := True;
         end;
         inc(Sat);
     end;
      Result := Hata;
   end;

    function FatBaslikIdGetir : Integer;
    begin
         Tablo.Query6.Close;
         Tablo.Query6.SQL.Text := 'select * from IMPORTDETAY where IMPORTID='+TabImport.Fields[0].AsString+' and (isnull(KOLON,0)<>0 or ZORUNLU=1) and YERI=1';
         Tablo.Query6.Open;
         Tablo.Query5.Close;
         Tablo.Query5.SQL.Text := 'select * from FATBASLIK where  REHBERID='+IntToStr(RehberId)+' and FATURANO='''+FaturaNo+''' ';
         Tablo.Query5.Open;
         if Tablo.Query5.RecordCount>0 then //daha önceden kayıt var, şimdi ne yapmak lazım?
            Result := Tablo.Query5.Fields[0].AsInteger
         else begin //yok ekleyelim
                       Tablo.Query6.First;
                       Tablo.Query5.Append;
                       Tablo.Query5.FieldByName('ACIKLAMA').AsString := '';//default değer; null kalmamalı
                       while not Tablo.Query6.eof do begin
                          if Tablo.Query6.FieldByName('ALAN').AsString ='REHBERID' then begin
                             Tablo.TablodanSorguAc(2,'select ID from REHBER where KOD = '''+TutDegeriniGetir+''' ');
                             Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := Tablo.Query2.Fields[0].AsString;
                         end else
                             Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
                          Tablo.Query6.Next;
                       end;
                       Tablo.Query5.Post;
                       Tablo.Query6.First;
                       Result := Tablo.Query5.Fields[0].AsInteger;
         end;
    end;

    procedure FaturaSatirEkle;
    var SKTIzlemEkle:Boolean;
        skt, lotno : String;

     function ExcellHucre(Sat,Sut:Integer):String;
     begin
        Tut := string(sayfa.Cells[Sat, Sut].Value);
        Result := Tut;
     end;

     procedure SKT_IzlemEkle;
      begin
        if SKTKolon = '' then
           if TGirisKutusuEx.BilgiAlEx('Reçete Tanım Bilgileri.', TGirdiDenetimleri.Create.Edit('Exceldeki SKT Kolon No Giriniz.', @SKTKolon).Edit('Exceldeki Lot Kolon No Giriniz.', @LotKolon)) = mrOk then begin
             if (SKTKolon='')then SKTKolon:='0';
             if (LotKolon='') then LotKolon:='0';
           end;
        Tablo.TablodanSorguAc(1,'select TUR,GIRISDEPO=isnull(GIRISDEPO,0),CIKISDEPO=isnull(CIKISDEPO,0) from FATBASLIK where ID='+Tablo.Query5.FieldByName('FATBASID').AsString);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into STOKIZLEME (STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,IZLEMTUR,MIKTAR,'+
           'IZLEMID,SKT,ACIKLAMA)values('+Tablo.Query5.FieldByName('URUNID').AsString+','+Tablo.Query1.FieldByName('TUR').AsString+','+
           Tablo.Query5.FieldByName('FATBASID').AsString+','+Tablo.Query5.FieldByName('ID').AsString+','+
           Tablo.Query1.FieldByName('GIRISDEPO').AsString+','+Tablo.Query1.FieldByName('CIKISDEPO').AsString+',2,'+Tablo.Query5.FieldByName('ADET').AsString+',0,'+
           ''''+FormatDateTime('yyyy-mm-dd', StrToDate(ExcellHucre(Sat,SKTKolon)))+''','''+ExcellHucre(Sat,LotKolon)+''')',[],[]);
     end;

     begin
         Tablo.Query6.Close;
         Tablo.Query6.SQL.Text := 'select * from IMPORTDETAY where IMPORTID='+TabImport.Fields[0].AsString+' and (isnull(KOLON,0)<>0 or ZORUNLU=1) and YERI=2';
         Tablo.Query6.Open;
         Tablo.Query6.First;
         {tut := sayfa.Cells[Sat, KodKolonNo].Value;
         Tablo.Query5.Close;
         Tablo.Query5.SQL.Text := 'select * from FATURA where FATBASID = '+IntToStr(BagliId)+' and KOD =  '''+tut+''' ';
         Tablo.Query5.Open;
         if Tablo.Query5.RecordCount>0 then begin //daha önceden kayıt var, şimdi ne yapmak lazım?
                     Tablo.Query5.Edit;
                     if (HedefTabloAdi='STOKFIYAT')or(HedefTabloAdi='STOKCEVRIM') then
                        Tablo.Query6.Next; //KOD alanını geçelim
                     while not Tablo.Query6.eof do begin
                        Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
                        Tablo.Query6.Next;
                     end;
                     Tablo.Query5.Post;
         end
         else }begin
         Tablo.Query5.Close;
         Tablo.Query5.SQL.Text := 'select * from FATURA where 1=2 ';
         Tablo.Query5.Open;
                 Tablo.Query6.First;
                 Tablo.Query5.Append;
                 SKTIzlemEkle:=False;
                 while not Tablo.Query6.eof do begin
                    if Tablo.Query6.FieldByName('ALAN').AsString='URUNID' then begin
                       Tablo.TablodanSorguAc(1,'select ID from STOKLAR where KOD='''+TutDegeriniGetir+''' ');
                       Tablo.Query5.FieldByName('URUNID').AsInteger := Tablo.Query1.Fields[0].AsInteger;
                    end
                    else if Tablo.Query6.FieldByName('ALAN').AsString='REHBERID' then begin
                       Tablo.TablodanSorguAc(2,'select ID from REHBER where KOD = '''+TutDegeriniGetir+'''' );
                       Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := Tablo.Query2.Fields[0].AsString;
                    end else if Tablo.Query6.FieldByName('ALAN').AsString='IZLEME' then begin
                       SKTIzlemEkle:= TutDegeriniGetir='2'; //SKT ve LOT var
                       Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
                    end else
                       Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
                    Tablo.Query6.Next;
                 end;
                 //
                 Tablo.Query5.FieldByName('FATBASID').AsInteger := BagliId;
                 if (Tablo.Query5.FieldByName('ADET').AsString <> '') and (Tablo.Query5.FieldByName('BIRIMFIYAT').AsString <> '') then
                     Tablo.Query5.FieldByName('TUTAR').AsCurrency := (100 - Tablo.Query5.FieldByName('ISKONTO').AsFloat) * Tablo.Query5.FieldByName('ADET').AsFloat * Tablo.Query5.FieldByName('BIRIMFIYAT').AsFloat / 100;
                 if Tablo.Query5.FieldByName('TUR').AsInteger=1 then //stoksa
                    Tablo.Query5.FieldByName('MIKTAR').AsFloat := Tablo.Query5.FieldByName('ADET').AsFloat * Tablo.StokCarpan(Tablo.Query5.FieldByName('URUNID').AsInteger, Tablo.Query5.FieldByName('BIRIM').AsInteger);
                 Tablo.Query5.Post;
                 if SKTIzlemEkle then
                    SKT_IzlemEkle;
                 Tablo.Query6.First;
         end;
     end;

   procedure FaturaImport;
        procedure FaturaTutarHesapla(Tablo1 : TFDQuery);
        begin
          Tablo1.Edit;
          Tablo.Query1.Close;
          if Tablo1.FieldByName('KDVDURUM').AsString = 'Hariç' then
             Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' + ' isnull(SUM(ROUND( TUTAR*KDV/100.0,2 )),0) AS KDVTOPLAM ' + ' from FATURA where FATBASID=' + IntToStr(BagliId)
           else
             Tablo.Query1.SQL.Text := 'Select isnull(SUM(ROUND(TUTAR,2)),0) AS ARATOPLAM,' + '  ROUND(isnull(SUM(TUTAR-(TUTAR/(1+(KDV/100.0)))),0),2) AS KDVTOPLAM ' + ' from FATURA where FATBASID=' + IntToStr(BagliId);
          Tablo.Query1.Open;

          Tablo1.FieldByName('FATURA_MATRAHI').AsCurrency  := Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency;
          Tablo1.FieldByName('KDV_TUTARI').AsCurrency  := Tablo.Query1.FieldByName('KDVTOPLAM').Value;
          if Tablo1.FieldByName('KDVDURUM').AsString = 'Hariç' then
             Tablo1.FieldByName('FATURA_TUTARI').AsCurrency  := Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency + Tablo.Query1.FieldByName('KDVTOPLAM').AsCurrency
          else
             Tablo1.FieldByName('FATURA_TUTARI').AsCurrency  := Tablo.Query1.FieldByName('ARATOPLAM').AsCurrency;
          //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' update FATBASLIK set FATURA_MATRAHI='+Tablo1.FieldByName('FATURA_MATRAHI').AsCurrency +', KDV_TUTARI='+
          //      Tablo1.FieldByName('KDV_TUTARI').AsCurrency+', FATURA_TUTARI='+Tablo1.FieldByName('FATURA_TUTARI').AsCurrency+'   where ID =&id ',['&id'],[BagliId]);
          Tablo1.Post;
        end;
   begin
      if (FaturadakiKodlarStoktaveCarideVarmi('STOKLAR','URUNID'))or(FaturadakiKodlarStoktaveCarideVarmi('REHBER','REHBERID')) then begin
          cxPageControl1.ActivePageIndex := 1;
          Exit;
      end else begin
          //stoklar tanımlı şimdi de excelde tek fatura girişi mi var yoksa çok fat.girişi mi (Eğer kolon numarası varsa çok fat.var demektir)
          SKTKolon :=''; LotKolon:='';
          Tablo.TablodanSorguAc(1,'select KOLON, VARSAYILAN from IMPORTDETAY where ALAN=''FATURANO'' and IMPORTID='+TabDetay.FieldByName('IMPORTID').AsString);
          FatNoKolonu := StrToIntDef(Tablo.Query1.Fields[0].AsString, 0);
          FaturaNo := Tablo.Query1.Fields[1].AsString;
          Tablo.TablodanSorguAc(1,'select top 1 KOLON, VARSAYILAN from IMPORTDETAY where ALAN=''REHBERID'' and IMPORTID='+TabDetay.FieldByName('IMPORTID').AsString);
          RehberId := Tablo.Query1.Fields[0].AsInteger;
          cxPageControl1.ActivePageIndex := 0;
      end;

      Sat := TabImport.FieldByName('BASLA').AsInteger;
      OncekiFatNo := '-1';
      SimdikiFatNo := sayfa.Cells[Sat, FatNoKolonu].Value;
      while sat <= TabImport.FieldByName('BITIS').AsInteger do begin
          if SimdikiFatNo <> OncekiFatNo then begin //önce başlık oluşturulur
             BagliId := FatBaslikIdGetir;
             OncekiFatNo := SimdikiFatNo;
          end;
          FaturaSatirEkle;
          inc(sat);
          SimdikiFatNo := sayfa.Cells[Sat, FatNoKolonu].Value;
          if (SimdikiFatNo <> OncekiFatNo)or(sat>TabImport.FieldByName('BITIS').AsInteger)  then begin   //eğer sonraki satır başka faturaya aitse toplamları kaydederiz
                Tablo.Query4.Close;
                Tablo.Query4.SQL.Text := 'select * from FATBASLIK where ID = '+IntToStr(BagliId);
                Tablo.Query4.Open;
                if TabImport.FieldByName('MODUL').AsString = 'Fatura Giriş' then
                   Tablo.FaturaBaslik(Tablo.Query4,-1)
                else
                   Tablo.FaturaBaslik(Tablo.Query4,Tablo.Query4.fieldbyname('REHBERID').asinteger);
                FaturaTutarHesapla(Tablo.Query4);
          end;
      end;
      //
   end;
   procedure RehberBilgiDoldur;
   var s:string;
   begin
       Sat := TabImport.FieldByName('BASLA').AsInteger;
       while sat <= TabImport.FieldByName('BITIS').AsInteger do begin
           //önce bu kodlu verinin üst tablosu var mı kontrol edelim Örneğin stok tablosunda bu kodlu kart var mı
           Tablo.Query6.First;
           tut := sayfa.Cells[Sat, Tablo.Query6.FieldByName('KOLON').AsInteger].Value;
           BagliId := BagliIdGetir(tut);
           if BagliId >= 0 then begin
              Tablo.Query6.next;//KOD sonrası ilk alan gelsin
              while not Tablo.Query6.Eof do begin
                    //Tablo.Query4.Close;
                    //Tablo.Query4.SQL.Text:='select RA.YERI,RA.ETIKET,RA.SIRA from REHBERAYAR RA where RA.YER_ID='+BagliId+' and RA.YERI='+Tablo.Query6.FieldbyName('YERI').AsString+' and RA.SIRA='+Tablo.Query6.FieldbyName('SIRA').AsString;
                    //Tablo.Query4.Open;
                    if Tablo.Query6.FieldByName('TUR').AsString = '11' then     //iniden liste
                       s:= IniListedenKarsilikGetir(tut, Tablo.Query6.FieldByName('VARSAYILAN').AsString)
                    else
                       s:= TutDegeriniGetir;
                    if s<>'' then begin
                      Tablo.Query3.Close;
                      Tablo.Query3.SQL.Text := 'IF NOT EXISTS (select YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN FROM REHBERBILGI '+
                                     ' WHERE YERI='+Tablo.Query6.FieldbyName('YERI').AsString+' AND SIRA='+Tablo.Query6.FieldByName('SIRA').AsString+' AND YER_ID='+inttostr(BagliId)+')'+//  RehberId
                                     ' INSERT INTO REHBERBILGI(YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN,SUBEID)VALUES('+Tablo.Query6.FieldbyName('YERI').AsString+','+Tablo.Query6.FieldbyName('SIRA').AsString+','+inttostr(BagliId)+','''+
                                     Tablo.Query6.FieldByName('ALAN').AsString+''','''+s+''','''+Kullanan+''','+IntToStr(SubeId)+')' ;
                      Tablo.Query3.ExecSQL;
                    end;
                    Tablo.Query6.next;
              end;
           end;
           inc(sat);
       end;
   end;
begin
   Memo1.Clear;
   //ilk iş kolonu dolu olanları alalım ki içlerine veri koyacağız
   //excel i açalım
   Excel := CreateOleObject('Excel.Application');
    //Excel kitabı ekranda görülmesin Excel.visible:=false;
   kitap:=Excel.Workbooks.Open(TabImport.FieldByName('DOSYAADI').AsString);
         //birinci sayfayı seç
   sat := StrToIntDef(TabImport.FieldByName('SAYFA').AsString,1);
   sayfa:= kitap.worksheets[sat];

   Tablo.TablodanSorguAc(1,'select KOLON, VARSAYILAN from IMPORTDETAY where ALAN=''KOD'' and IMPORTID='+TabDetay.FieldByName('IMPORTID').AsString);
   KodKolonNo:= Tablo.Query1.Fields[0].AsInteger;

   Tablo.Query6.Close;
   Tablo.Query6.SQL.Text := 'select * from IMPORTDETAY where IMPORTID='+TabImport.Fields[0].AsString+' and (isnull(KOLON,0)<>0 or ZORUNLU=1) ';
   Tablo.Query6.Open;

   //Fatura girişi yapılıyorsa kodlar stokta tanımlı mı bakalım
   if (TabImport.FieldByName('MODUL').AsString='Fatura Giriş')or(TabImport.FieldByName('MODUL').AsString='Fatura Çıkış') then begin
      FaturaImport;
      exit;
   end else
   if (TabImport.FieldByName('MODUL').AsString='Cari Personel Temel')then
      RehberBilgiDoldur
   else
   begin
       Sat := TabImport.FieldByName('BASLA').AsInteger;
       while sat <= TabImport.FieldByName('BITIS').AsInteger do begin
           //önce bu kodlu verinin üst tablosu var mı kontrol edelim Örneğin stok tablosunda bu kodlu kart var mı
           Tablo.Query6.First;
           tut := sayfa.Cells[Sat, Tablo.Query6.FieldByName('KOLON').AsInteger].Value;
           BagliId := BagliIdGetir(tut);
           if BagliId >= 0 then begin
                   //sonra bu kodlu veri var mı kontrol edelim Örneğin stok kartı açılmış ama fiyat girilmiş mi
                   Tablo.Query5.Close;
                   Tablo.Query5.SQL.Text := 'select * from '+HedefTabloAdi+' where ';
                   if HedefTabloAdi='STOKFIYAT' then begin
                      Tablo.Query5.SQL.Add(' STOKID =  '+IntToStr(BagliId));
                      Tablo.Query6.Next;
                      Tablo.Query5.SQL.Add(' and FIYATADI='+TutDegeriniGetir);
                      Tablo.Query6.Next;
                      Tablo.Query5.SQL.Add(' and BIRIM='+TutDegeriniGetir)

                   end else if (HedefTabloAdi='STOKCEVRIM')or(HedefTabloAdi='PERS_PDKS') then
                      Tablo.Query5.SQL.Add(' 1=2 ')//STOKCEVRIM tablosuna sürekli eklenmesi lazım
                   else
                      Tablo.Query5.SQL.Add(' KOD =  '''+tut+''' ');
                   Tablo.Query5.Open;
                   if Tablo.Query5.RecordCount>0 then begin //daha önceden kayıt var, şimdi ne yapmak lazım?
                      case TabImport.FieldByName('KURAL').AsInteger of //kurallara bakmak lazım
                         1 : ;//sonrakine geçsin
                         2 : ;//boşluk varsa doldursun
                         3 : begin
                               Tablo.Query5.Edit;
                               if (HedefTabloAdi='STOKFIYAT')or(HedefTabloAdi='STOKCEVRIM') then
                                  Tablo.Query6.Next; //KOD alanını geçelim
                               while not Tablo.Query6.eof do begin
                                  Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
                                  Tablo.Query6.Next;
                               end;
                               Tablo.Query5.Post;
                             end;//doluysa da değiştirsin;
                      end;
                      if HedefTabloAdi='REHBER' then //kurum iletişim ve
                         Kurum_Iletisim_Ekle(Tablo.Query5.Fields[0].asInteger,Tablo.Query5.Fields[0].asInteger);
                   end
                   else begin
                           Tablo.Query6.First;
                           Tablo.Query5.Append;
                           if (HedefTabloAdi='STOKFIYAT')or(HedefTabloAdi='STOKCEVRIM') then begin
                              Tablo.Query5.FieldByName('STOKID').AsInteger :=  BagliId;
                              Tablo.Query6.Next;
                           end
                           else if (HedefTabloAdi='CEKLER')or(HedefTabloAdi='SENETLER') then begin
                              Tablo.Query5.FieldByName('REHBERID').AsInteger :=  BagliId;
                              Tablo.Query6.Next;
                              Tut := TutDegeriniGetir;
                              Tablo.TablodanSorguAc(1,' select BANKASUBELERID from BANKAHESAPLAR where HESAPNO='''+Tut+'''');
                              if Tablo.Query1.RecordCount>0 then
                                 Tablo.Query5.FieldByName('BANKASUBELERID').AsString :=  Tablo.Query1.Fields[0].AsString
                              else
                                 Memo1.Lines.Add('Tanımsız banka hesabı : '+Tut);
                              Tablo.Query6.Next;
                           end
                           else if (HedefTabloAdi='PERS_PDKS') then begin
                              Tablo.Query5.FieldByName('REHBERID').AsInteger :=  BagliId;
                              Tablo.Query6.Next;
                           end;

                           while not Tablo.Query6.eof do begin
                              if (Tablo.Query6.FieldByName('YERI').AsString='')or(Tablo.Query6.FieldByName('YERI').AsString='0') then
                                 Tablo.Query5.FieldByName(Tablo.Query6.FieldByName('ALAN').AsString).AsString := TutDegeriniGetir;
                              Tablo.Query6.Next;
                           end;
                           Tablo.Query5.Post;

                           if HedefTabloAdi='REHBER' then begin//kurum iletişim ve
                              //Her rehber satırı eklendiğinde hemen merkez iletişim satırı eklenmeli ve adres tel buna bağlanmalı
                              Tablo.Query3.Close;           //eklenmemiş
                              Tablo.Query3.SQL.Text := 'INSERT INTO REHBERILETISIM(REHBERID,AD,VARSAYILAN,AKTIF,EKLEYEN,EKLEMETARIHI ) VALUES('+ Tablo.Query5.Fields[0].AsString+',''Merkez'',1,1,'''+Kullanan+''','''+FormatDateTime('yyyy-mm-dd hh:nn', tablo.genini.BugunTrhSaat)+''') select scope_identity() ' ;
                              Tablo.Query3.Open;
                              SonEklenenRehberIletisimId := Tablo.Query3.Fields[0].AsInteger;
                              Kurum_Iletisim_Ekle(Tablo.Query5.Fields[0].asInteger, SonEklenenRehberIletisimId);
                              Kurum_Ticari_Ekle(Tablo.Query5.Fields[0].asInteger);//
                            end;
                           Tablo.Query6.First;
                   end;
           end;
           Inc(sat);
       end;
   end;
   //Burada barkodları başka tabloya taşıyalım
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'insert into STOKBARKOD ([BARKOD],[STOKID],[BARKODBIRIMI],[VARSAYILAN],[EKLEMETARIHI]) '+
                            ' select XBARKODX,ID,ANABIRIM,BARKODBIRIMI=1,EKLEMETARIHI=GETDATE() from STOKLAR where XBARKODX is not null';
   Tablo.Query1.ExecSQL;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := ' update STOKLAR set XBARKODX=null ';
   Tablo.Query1.ExecSQL;
   if Memo1.Lines.Count>0 then begin
      cxPageControl1.ActivePageIndex:=1;
      ShowMessage('Bir kısmı aktarılamadı..');
   end else
      ShowMessage('Aktarım başarıyla tamamlandı..');
    // Excel dosyası kapatılıyor.
   if not VarIsEmpty(Excel) then begin
       Excel.DisplayAlerts:= False;
       //Excel mesajlarını görünteleme
       Excel.Quit;
       Excel := Unassigned;
   end;
end;

procedure TImportDlg.FormShow(Sender: TObject);
begin
   TabImport.Close;
   TabImport.Params[0].Value := ImportId;
   TabImport.Open;
end;

function TImportDlg.ListeBolumAdiGetir(Modul, Alan : string) : integer;
var  Liste : Integer;
  stList : TStringList;
begin
   stlist := TStringList.Create;
   if Modul='Cari' then begin
       if Alan = 'STATU' then Liste := -2209  //'CariKart_Statü'
       else if Alan = 'GRUP' then Liste := -2202   //'CariKart_Grup'
       else if Alan = 'KATEGORI' then Liste := -2204   //'CariKart_Kategori'
       else if Alan = 'SINIF' then Liste := -2203   //'CariKart_Sınıf'
       else if Alan = 'DURUM' then Liste := -2201;//'CariKart_Durum'
   end else if Modul='Cari Personel Temel' then begin
  //     if Alan = 'BOLUM' then Liste := -2209  //'CariKart_Statü'
  //     else if Alan = 'GOREV' then Liste := -2202   //'CariKart_Grup'
  //     else if Alan = 'CINSIYET' then Liste := -2204   //'CariKart_Kategori'
  //     else if Alan = 'MEDENIHAL' then Liste := -2203   //'CariKart_Sınıf'
   end
{   else if Pos('Fatura', Modul)>0 then begin
       TabDetay.Edit;
       if Alan = 'REHBERID' then begin
          ID := Tablo.RehberAra_IDGetir(-1);
          if ID>-2 then begin
             TabDetay.FieldByName('VARSAYILAN').AsString := IntToStr(ID);
             TabDetay.FieldByName('ISLEM').AsString := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
             Liste := '-';
          end;
       end
      //TUR,TIPI,REHBERID,GIRISDEPO,KDVDURUM,KUR,DURUM,';
      //TUR,BIRIM,';
       else if Alan = 'GIRISDEPO' then begin
              Liste := '-';
              Tablo.ListedenBilgiGetir(Alan, 'SELECT ID, DEPOADI FROM DEPOLAR WHERE DURUM=1 ORDER BY 2 ', stlist,[]);
              TabDetay.FieldByName('VARSAYILAN').AsString := stlist.Strings[0];
              TabDetay.FieldByName('ISLEM').AsString := stlist.Strings[1];
       end
       else if Alan = 'KDVDURUM' then begin
              Liste := '-';
              Tablo.ListedenBilgiGetir(Alan, 'select ''Hariç'' union all select ''Dahil'' ', stlist,[]);
              TabDetay.FieldByName('VARSAYILAN').AsString := stlist.Strings[0];
       end
       else if (Alan = 'TUR')and(TabDetay.FieldByName('YERI').AsString='1') then begin
              Liste := '-';
              Tablo.ListedenBilgiGetir(Alan, 'select 11,''Fatura'' union all select 12,''Fiş'' ', stlist,[]);
              TabDetay.FieldByName('VARSAYILAN').AsString := stlist.Strings[0];
              TabDetay.FieldByName('ISLEM').AsString := stlist.Strings[1];
       end
       else if (Alan = 'TUR')and(TabDetay.FieldByName('YERI').AsString='2') then
                Liste := 'FatGelDetay_Tür'
       else if Alan = 'BIRIM' then Liste := 'StokKart_Anabirim'
       else if Alan = 'KUR' then Liste := 'KURLAR'
   end }
   else if Modul = 'Stok Kart' then begin
       if Alan = 'TIPI' then Liste := -2703//'StokKart_Tipi'
       else if Alan = 'MARKA' then Liste := -2701//'StokKart_Marka'
       else if Alan = 'MODEL' then Liste := 0
       else if Alan = 'GRUBU' then Liste := -2704//'StokKart_Grubu'
       else if Alan = 'OZELLIK' then Liste := -2705//'StokKart_Özellik'
       else if Alan = 'ANABIRIM' then Liste := -2702//'StokKart_Anabirim'
       else if Alan = 'BIRIM2' then Liste := -2702//'StokKart_Anabirim'
       else if Alan = 'DURUM' then Liste :=-2708// 'StokKart_Durum'
       else if Alan = 'IZLEME' then Liste := -2706//'StokKart_Izleme'
       else if Alan = 'ICERIK' then Liste := -2718;//'StokKart_Icerik'
   end
   else if TabImport.FieldByName('MODUL').AsString='Stok Çevrim' then begin
       if (Alan = 'BIRIM1')or(Alan = 'BIRIM2') then
            Liste := -2702//'StokKart_Anabirim'
   end
   else if TabImport.FieldByName('MODUL').AsString='Stok Fiyat' then begin
       if Alan = 'FIYATADI' then begin
         Tablo.ListedenBilgiGetir('Fiyat Listesi', 'SELECT BOLUM,ANAHTAR,DEGER FROM GENINI WHERE BOLUM in (-1007,-1008) ORDER BY 1 ', stlist,[]);
         Liste := StrToInt(stList.Strings[0]);    // -1007//'StokFiyat_Fiyatad'
       end else if Alan = 'BIRIM' then Liste := -2702//'StokKart_Anabirim'
       else if Alan = 'KUR' then Liste := -1004;//'KURLAR'
   end;
   Result := Liste;
end;

procedure TImportDlg.GridBankaDBTableView1VARSAYILANPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var Alan  : String[25];
   stlist : TStringList;
   ID,Liste : Integer;
begin //STATU,GRUP,KATEGORI,SINIF,DURUM,, Stok:  TIPI,MARKA,MODEL,GRUBU,OZELLIK,ANABIRIM,BIRIM2,DURUM,IZLEME  stokfiyat: FIYATADI,BIRIM,KUR
   stlist := TStringList.Create;
   Liste := -1;
   Liste := ListeBolumAdiGetir(TabImport.FieldByName('MODUL').AsString, TabDetay.FieldByName('ALAN').AsString);
   if Pos('Fatura', TabImport.FieldByName('MODUL').AsString)>0 then begin
       TabDetay.Edit;
       if Alan = 'REHBERID' then begin
          ID := Tablo.RehberAra_IDGetir(-1);
          if ID>-2 then begin
             TabDetay.FieldByName('VARSAYILAN').AsString := IntToStr(ID);
             TabDetay.FieldByName('ISLEM').AsString := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
             Liste := 0;
          end;
       end
      //TUR,TIPI,REHBERID,GIRISDEPO,KDVDURUM,KUR,DURUM,';
      //TUR,BIRIM,';
       else if Alan = 'GIRISDEPO' then begin
              Liste := 0;
              Tablo.ListedenBilgiGetir(TabDetay.FieldByName('ALAN').AsString, 'SELECT ID, DEPOADI FROM DEPOLAR WHERE DURUM=1 ORDER BY 2 ', stlist,[]);
              TabDetay.FieldByName('VARSAYILAN').AsString := stlist.Strings[0];
              TabDetay.FieldByName('ISLEM').AsString := stlist.Strings[1];
       end
       else if Alan = 'KDVDURUM' then begin
              Liste := 0;
              Tablo.ListedenBilgiGetir(TabDetay.FieldByName('ALAN').AsString, 'select ''Hariç'' union all select ''Dahil'' ', stlist,[]);
              TabDetay.FieldByName('VARSAYILAN').AsString := stlist.Strings[0];
       end
       else if (Alan = 'TUR')and(TabDetay.FieldByName('YERI').AsString='1') then begin
              Liste := 0;
              Tablo.ListedenBilgiGetir(TabDetay.FieldByName('ALAN').AsString, 'select 11,''Fatura'' union all select 12,''Fiş'' ', stlist,[]);
              TabDetay.FieldByName('VARSAYILAN').AsString := stlist.Strings[0];
              TabDetay.FieldByName('ISLEM').AsString := stlist.Strings[1];
       end
       else if (Alan = 'TUR')and(TabDetay.FieldByName('YERI').AsString='2') then
                Liste := 0//'FatGelDetay_Tür'
       else if Alan = 'BIRIM' then Liste := -2702//'StokKart_Anabirim'
       else if Alan = 'KUR' then Liste := -1004;//'KURLAR'
   end;

   if Liste=-1 then
      ShowMessage('Liste bulunamadı!')
   else if Liste <> 0 then begin
       TabDetay.Edit;
       Tablo.ListedenBilgiGetir(TabDetay.FieldByName('ALAN').AsString, 'select ANAHTAR,DEGER from GENINI where BOLUM = '+IntToStr(Liste)+' ', stlist,[]);
       TabDetay.FieldByName('VARSAYILAN').AsString := stlist.Strings[1];
       TabDetay.FieldByName('ISLEM').AsString := stlist.Strings[0];
   end;
   if TabDetay.State in [dsEdit, dsInsert] then
      TabDetay.post;
   stlist.Free;
end;

procedure TImportDlg.DokumTusClick(Sender: TObject);
   function  ZorunluAlanKontrolu : Boolean;
   begin
      TabDetay.First;
      while not TabDetay.eof do begin
        if (TabDetay.FieldByName('ZORUNLU').AsBoolean)and(TabDetay.FieldByName('KOLON').AsString = '') then
           if not((TabDetay.FieldByName('KURAL').AsInteger=1)and((TabDetay.FieldByName('VARSAYILAN').AsString<>''))) then begin
               ShowMessage(TabDetay.FieldByName('ALAN').AsString+' zorunlu alandır!');
               Result := False;
               exit;
           end;
        TabDetay.Next;
      end;
      Result := True;
   end;

begin
   if not ZorunluAlanKontrolu then
      exit;
   if TabImport.FieldByName('MODUL').AsString='Cari' then begin
       HedefTabloAdi:='REHBER';
       BagliOlduguTablo:= '';
       //AramaAlani := 'KOD';
   end else if TabImport.FieldByName('MODUL').AsString='Cari Personel Temel' then begin
       HedefTabloAdi:='REHBERBILGI';
       BagliOlduguTablo:= 'REHBER';
       //AramaAlani := 'KOD';
   end else if (TabImport.FieldByName('MODUL').AsString='Fatura Giriş')or(TabImport.FieldByName('MODUL').AsString='Fatura Çıkış') then begin
       HedefTabloAdi:='FATURA';
       BagliOlduguTablo := 'FATBASLIK';
       //AramaAlani := 'KOD;FIYATADI';
   end
   else if TabImport.FieldByName('MODUL').AsString='Stok Kart' then  begin
       HedefTabloAdi:='STOKLAR';
       BagliOlduguTablo:='';
       //AramaAlani := 'KOD';
   end
   else if TabImport.FieldByName('MODUL').AsString='Stok Çevrim' then begin
       HedefTabloAdi := 'STOKCEVRIM';
       BagliOlduguTablo := 'STOKLAR';
       //AramaAlani := 'KOD;FIYATADI';
   end
   else if TabImport.FieldByName('MODUL').AsString='Stok Fiyat' then begin
       HedefTabloAdi:='STOKFIYAT';
       BagliOlduguTablo := 'STOKLAR';
       //AramaAlani := 'KOD;FIYATADI';
   end else if (TabImport.FieldByName('MODUL').AsString='Çek Giriş')or(TabImport.FieldByName('MODUL').AsString='Çek Çıkış') then begin
       HedefTabloAdi:='CEKLER';
       BagliOlduguTablo := 'REHBER';
   end else if (TabImport.FieldByName('MODUL').AsString='PDKS Giriş')or(TabImport.FieldByName('MODUL').AsString='PDKS Çıkış') then begin
       HedefTabloAdi:='PERS_PDKS';
       BagliOlduguTablo := '';
   end;

   case  TabImport.FieldByName('DOSYATURU').AsInteger of
     1:ExceldenOku;//Excel
   end;
end;

procedure TImportDlg.btnKapatClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TImportDlg.DtsDetayStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsDetay, DetayEkleTus,DetaySilTus,DetayKaydetTus,DetayIptalTus);
end;

procedure TImportDlg.DtsImportStateChange(Sender: TObject);
begin
   Tablo.NavTusGoruntule(DtsImport, EkleTus,SilTus,KaydetTus,IptalTus);
end;

procedure TImportDlg.SilTusClick(Sender: TObject);
begin
   if TabDetay.RecordCount > 0  then
      raise Exception.Create('Önce alttaki detay satırları silin!');
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabImport.Delete;
end;

procedure TImportDlg.TabDetayNewRecord(DataSet: TDataSet);
begin
   TabDetay.FieldByName('IMPORTID').AsInteger := TabImport.Fields[0].AsInteger ;
   TabDetay.FieldByName('SUBEID').AsInteger :=SubeId
end;

procedure TImportDlg.TabImportAfterScroll(DataSet: TDataSet);
begin
   TabDetay.Close;
   TabDetay.Params[0].Value := TabImport.Fields[0].AsInteger;
   TabDetay.Open;
end;

procedure TImportDlg.TabImportBeforePost(DataSet: TDataSet);
begin
   if not BoslukKontrol(TabImport.FieldByName('MODUL').AsString, 'Modül') then Abort;
   if not BoslukKontrol(TabImport.FieldByName('ADI').AsString, 'Adı') then Abort;
   if not BoslukKontrol(TabImport.FieldByName('IMPORT').AsString, 'Tipi') then Abort;
   if not BoslukKontrol(TabImport.FieldByName('DOSYATURU').AsString, 'Dosya Türü') then Abort;
   if not BoslukKontrol(TabImport.FieldByName('BASLA').AsString, 'Başlama') then Abort;
   if not BoslukKontrol(TabImport.FieldByName('BITIS').AsString, 'Bitiş') then Abort;
   if not BoslukKontrol(TabImport.FieldByName('DOSYAADI').AsString, 'Dosya Adı') then Abort;
   if not BoslukKontrol(TabImport.FieldByName('KURAL').AsString, 'Kural') then Abort;
end;

procedure TImportDlg.TabImportNewRecord(DataSet: TDataSet);
begin
   TabImport.FieldByName('SAYFA').AsInteger := 1;
   TabImport.FieldByName('SUBEID').AsInteger := SubeId;
end;

procedure TImportDlg.KaydetTusClick(Sender: TObject);
begin
   TabImport.Post;
end;

procedure TImportDlg.lgilieklemekiinExcel1Click(Sender: TObject);
var
  book,excel,sheet:variant;
  i:integer;
  isimAciklama :String;
begin
 case TMenuItem(Sender).Tag of
    1: isimAciklama :='İletişim Ad';
    4: isimAciklama :='Ad Soyad';
 end;

  i:=3;
  try
    excel:=createoleobject('excel.application');
    book:=excel.workbooks.add;
    excel.visible:=true;
    sheet:=book.worksheets[1];
  except
     raise exception.Create('Excel Açılamadı..');
  end;
  Tablo.TablodanSorguAc(1,' Select RB.SIRA, RB.ETIKET from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI '+
    ' where RB.YERI= '+IntToStr(TMenuItem(Sender).Tag)+' Group by RB.SIRA, RB.ETIKET'+
    ' union all '+
    ' select  SIRA, ETIKET from REHBERAYAR  where  YERI= '+IntToStr(TMenuItem(Sender).Tag)+'  and ETIKET not in (select ETIKET from REHBERBILGI where  YERI= '+IntToStr(TMenuItem(Sender).Tag)+' )  Group by SIRA, ETIKET Order by 1');
  sheet.cells[1,1]:='Cari Kod';
  sheet.cells[1,2]:=isimAciklama;
  Tablo.Query1.First;
  while not Tablo.Query1.Eof do begin
    sheet.cells[1,i]:= Tablo.Query1.FieldByName('ETIKET').AsString;
    inc(i);
    Tablo.Query1.Next;
  end;
end;

procedure TImportDlg.lgiliyiExcelden1Click(Sender: TObject);
var
    book:variant;
    excel,sheet:variant;
    satir, sutun,i,RehID, OncekiId:integer;
    BekletmeDlgAciklama,isimAciklama :String;
    Varsayilan:string[1];

  procedure RehberBilgiEkle(Yer_ID,Sira,Etiket,Bilgi:String);
    begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into REHBERBILGI(YERI,YER_ID,SIRA,ETIKET,BILGI,EKLEYEN,EKLEMETARIHI,SUBEID)'+
      ' values ('+IntToStr(TMenuItem(Sender).Tag)+','+Yer_ID+','+Sira+','''+Etiket+''','''+Bilgi+''','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+')',[],[]);
    end;
    function excelsonsatir(AColumn: Integer): Integer;
    const
      xlUp = 3;
    begin
        Result := excel.Range[Char(96 + AColumn) + IntToStr(65536)].end[xlUp].Rows.Row;
    end;
begin
case TMenuItem(Sender).Tag of
  1:begin
    BekletmeDlgAciklama :='İletişim';
    isimAciklama :='İletişim Ad';
  end;
  4:begin
    BekletmeDlgAciklama :='İlgili';
    isimAciklama :='Ad Soyad';
  end;
end;

  excel := CreateOleObject('Excel.Application');
  OpenDialog1.Title:='Excel Dosyasını Aç';
  OpenDialog1.Filter:='Excel Dosyaları *.xls';



  if OpenDialog1.Execute then begin
    book:= Excel.WorkBooks.Open(OpenDialog1.FileName);
    Application.CreateForm(TBekletmeDlg,BekletmeDlg);

    try
      Screen.Cursor:= crHourGlass;
      sheet:=book.worksheets[1];
      BekletmeDlg.Caption := BekletmeDlgAciklama + ' verileri aktarılıyor.Bekleyiniz...';
      BekletmeDlg.cxProgressBar1.Properties.Max:=excelsonsatir(1)+1;
      BekletmeDlg.Show;
      OncekiId:=0;
      for satir := 2 to excelsonsatir(1)+1 do begin

        BekletmeDlg.cxProgressBar1.Position:=satir;
        BekletmeDlg.cxProgressBar1.Refresh;
        Tablo.TablodanSorguAc(5,'Select ID from REHBER Where KOD ='''+trim(VarToStr(sheet.cells[satir,1]))+''' ');
         if Tablo.Query5.RecordCount > 0 then begin
           if VarToStr(sheet.cells[satir,2]) <> '' then begin
              sutun:=3;
              if TMenuItem(Sender).Tag = 4 then begin
                if Tablo.Query5.FieldByName('ID').AsInteger = OncekiId then
                   Varsayilan := '0'
                else
                   Varsayilan := '1';
                Tablo.TablodanSorguAc(3,'insert into REHBERPERSONEL(REHBERID,ADSOYAD,VARSAYILAN,NEREDE,EKLEYEN,EKLEMETARIHI,SUBEID) values('+Tablo.Query5.FieldByName('ID').AsString
                +','''+ VarToStr(sheet.cells[satir,2])+''','+Varsayilan+',1,'''+Kullanan+''','''+
                FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+') select scope_identity() ');
                OncekiId := Tablo.Query5.FieldByName('ID').AsInteger;
              end else if TMenuItem(Sender).Tag = 1 then begin
                Tablo.TablodanSorguAc(3,'insert into REHBERILETISIM(REHBERID,AD,VARSAYILAN,AKTIF,EKLEYEN,EKLEMETARIHI,SUBEID) values('+Tablo.Query5.FieldByName('ID').AsString
                +','''+ VarToStr(sheet.cells[satir,2])+''',0,1,'''+Kullanan+''','''+
                FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(SubeId)+') select scope_identity() ');
              end;


              Tablo.TablodanSorguAc(1,' Select 0 as SIRA,''Cari Kod'' as ETIKET union all  Select 1 as SIRA,'''+isimAciklama+''' as ETIKET'+
                '  union all '+
                ' Select RB.SIRA, RB.ETIKET from REHBERBILGI RB INNER JOIN REHBERAYAR RA ON RB.SIRA=RA.SIRA AND RB.YERI=RA.YERI where RB.YERI='+inttostr(TMenuItem(Sender).Tag)+' Group by RB.SIRA, RB.ETIKET'+
                '  union all '+
                ' select  SIRA, ETIKET from REHBERAYAR where YERI='+inttostr(TMenuItem(Sender).Tag)+' and ETIKET not in (select ETIKET from REHBERBILGI where  YERI='+inttostr(TMenuItem(Sender).Tag)+' ) Group by SIRA, ETIKET Order by 1');
              Tablo.Query1.First;
              while not Tablo.Query1.Eof do begin
                  for I := 3 to Tablo.Query1.RecordCount do begin
                    if VarToStr(sheet.cells[1,i]) = Tablo.Query1.FieldByName('ETIKET').AsString then begin
                      if vartostr(sheet.cells[satir,sutun])<>'' then
                        RehberBilgiEkle(Tablo.Query3.Fields[0].AsString,Tablo.Query1.FieldByName('SIRA').AsString,Tablo.Query1.FieldByName('ETIKET').AsString,sheet.cells[satir,sutun]);

                      inc(sutun);
                    end;
                  end;
                Tablo.Query1.Next;
              end;
           end;
         end;
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERPERSONEL set VARSAYILAN=1 where ID in( '+
                  'select ID from( select distinct RP1.REHBERID, '+
                  'ID=(select top 1 RP2.ID from REHBERPERSONEL RP2 where RP2.REHBERID=RP1.REHBERID order by VARSAYILAN desc) '+
                  'from REHBERPERSONEL RP1 )as asd )',[],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update REHBERPERSONEL set VARSAYILAN=0 where ID not in( '+
                  'select ID from( select distinct RP1.REHBERID, '+
                  'ID=(select top 1 RP2.ID from REHBERPERSONEL RP2 where RP2.REHBERID=RP1.REHBERID order by VARSAYILAN desc) '+
                  'from REHBERPERSONEL RP1 )as asd )',[],[]);
      excel.DisplayAlerts := False;
      excel.quit;
      excel:=Unassigned;
      BekletmeDlg.Destroy;
      Application.Messagebox(PChar(BekletmeDlgAciklama + ' verileri kaydedilmiştir.'),Pchar(Uyari),MB_OK);
    finally
      Screen.Cursor:=crDefault;
    end;
  end;
end;


procedure TImportDlg.IptalTusClick(Sender: TObject);
begin
   TabImport.Cancel;
end;

procedure TImportDlg.EkleTusClick(Sender: TObject);
begin
   TabImport.Append;
end;

end.







