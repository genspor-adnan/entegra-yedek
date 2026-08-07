unit UReplikasyon;

interface
uses FireDAC.Comp.Client, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxControls, cxContainer, cxEdit, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, DB, Utablo, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, cxLookAndFeelPainters, Menus, cxMemo, cxRichEdit, cxLabel, StdCtrls,
  cxButtons, cxGroupBox, Registry, RegStr, cxImageComboBox,
  cxCheckBox, cxGridCustomPopupMenu, cxGridPopupMenu, Fetautil, dxSkinsCore,
  dxSkinscxPCPainter, dxSkinLondonLiquidSky, cxLookAndFeels, cxNavigator, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TReplikasyonDlg = class(TForm)
    CNNEntegra: TFDConnection;
    CNNGenotip: TFDConnection;
    TabAktarilacak: TFDQuery;
    DtsAktarilacak: TDataSource;
    cxGrid1: TcxGrid;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGroupBox1: TcxGroupBox;
    BtnEntCnn: TcxButton;
    cxGroupBox3: TcxGroupBox;
    cxGroupBox4: TcxGroupBox;
    cxButton2: TcxButton;
    cxRichEdit1: TcxRichEdit;
    cxGrid1DBTableView1NAME: TcxGridDBColumn;
    cxImageComboBox1: TcxImageComboBox;
    PopupMenu1: TPopupMenu;
    cxGridPopupMenu1: TcxGridPopupMenu;
    mnSe1: TMenuItem;
    mnTemizle1: TMenuItem;
    ADOQuery1: TFDQuery;
    DataSource1: TDataSource;
    BtnGenCnn: TcxButton;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    TabBizim: TFDQuery;
    //function DBConnect: boolean;
    procedure cxImageComboBox1PropertiesEditValueChanged(Sender: TObject);
    procedure cxButton2Click(Sender: TObject);
    function RehberSatiriniAl(Kod,GenoCnn,EntegCnn:string): boolean;
    function RehberSatiriniVer(Kod,GenoCnn,EntegCnn:string): boolean;
    procedure mnSe1Click(Sender: TObject);
    procedure mnTemizle1Click(Sender: TObject);
    function GenotipdanRehberiEntegrayaGuncelle(Kod,GenoCnn,EntegCnn: String): boolean;
    function EntegradanRehberiGenotipaGuncelle(Kod,GenoCnn,EntegCnn: String): boolean;
    function RehberHareketiVarmi(Kod,GenoCnn,EntegCnn:String ;Sil:boolean): boolean;
    procedure ConnectionlariDuzelt(cnn:TFDConnection);
    procedure FormCreate(Sender: TObject);
    procedure CNNEntegraAfterConnect(Sender: TObject);
    procedure CNNGenotipAfterConnect(Sender: TObject);
    procedure CNNEntegraAfterDisconnect(Sender: TObject);
    procedure CNNGenotipAfterDisconnect(Sender: TObject);
    procedure BtnGenCnnClick(Sender: TObject);
    procedure BtnEntCnnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cxButton3Click(Sender: TObject);
    procedure cxButton4Click(Sender: TObject);
    procedure AciklamaYaz;
    procedure FormShow(Sender: TObject);
    Function StokFaturasiAl(GirNo:Integer;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
    Function DevirBankaCekSenet(GirNo:Integer;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
    Function DevirBankaKasaCari(Kod,Kur:string;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
    Function StokFaturasiGuncelle(GirNo:Integer;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
    Function StokFaturasiSil(GirNo:Integer;GenoCnn,EntegCnn:String):boolean;
    Function GentegreCariYilDevir(GirNo:Integer;GenoCnn,EntegCnn: String):boolean;
    Procedure HizliConnection(CNNGen, CNNEnt: string);
    Function StokKartEkleGenotipdanEntegraya(StokKod,GenoCnn,EntegCnn: String):boolean;
    Function StokKartEkleEntegradanGenotipa(StokKod,GenoCnn,EntegCnn: String):boolean;
    Function GeninidenDegerGetir(Bolum:integer;Anahtar:string):string;
    Function GeninidenAnahtarGetir(Bolum,Deger:integer):string;
  private
    { Private declarations }
  public

    CnnStrEntegra,CnnStrGenotip:string;
    Bugun:TDateTime;
    { Public declarations }
  end;

var
  ReplikasyonDlg: TReplikasyonDlg;

implementation
uses PrjConst, LocOnFly, UVeriMotor;

{$R *.dfm}


procedure TReplikasyonDlg.BtnEntCnnClick(Sender: TObject);
begin
   //bağlantı oluşturulacak ve bağlanırsa;
   CNNEntegra.ConnectionString:=Tablo.FDCnn.ConnectionString;
   CNNEntegra.Connected:=True;
   if CNNGenotip.Connected And CNNEntegra.Connected then
     cxGroupBox3.Enabled:=True
    else
     cxGroupBox3.Enabled:=False;
end;

procedure TReplikasyonDlg.BtnGenCnnClick(Sender: TObject);
begin
   //bağlantı oluşturulacak ve bağlanırsa;
   Tablo.DBConnect(CNNGenotip);
   if CNNGenotip.Connected And CNNEntegra.Connected then
     cxGroupBox3.Enabled:=True
    else
     cxGroupBox3.Enabled:=False;
end;

procedure TReplikasyonDlg.CNNEntegraAfterConnect(Sender: TObject);
begin
  cxLabel2.Caption:=RBagli ;
  CnnStrEntegra:=CNNEntegra.ConnectionString;
end;

procedure TReplikasyonDlg.CNNEntegraAfterDisconnect(Sender: TObject);
begin
  cxLabel2.Caption:=RBaglantiYok
end;

procedure TReplikasyonDlg.CNNGenotipAfterConnect(Sender: TObject);
begin
  cxLabel1.Caption:=RBagli;
  CnnStrGenotip:=CNNGenotip.ConnectionString;
end;

procedure TReplikasyonDlg.CNNGenotipAfterDisconnect(Sender: TObject);
begin
  cxLabel1.Caption:=RBaglantiYok
end;

procedure TReplikasyonDlg.cxButton2Click(Sender: TObject);
var
  i:Integer;
begin
  i:=0;
  if cxImageComboBox1.Text = RGenotipdanRehberAl then  begin
    TabAktarilacak.first;
    //ilk satırdan son satıra kadar aktarım
    while not TabAktarilacak.Eof do begin
      //ilk sütundaki seç değeri değiştirilenler aktarılmaz..
      try
        if cxGrid1DBTableView1NAME.EditValue=True then begin
          if RehberSatiriniAl(TabAktarilacak.FieldByName('KOD').AsString,CnnStrGenotip,CnnStrEntegra) then
             cxGrid1DBTableView1NAME.EditValue:=True
          Else
             cxGrid1DBTableView1NAME.EditValue:=False;
        end;
      finally
        TabAktarilacak.Next;
      end;
    end;
  end
  else if cxImageComboBox1.Text = RGenotipeRehberVer then  begin
    TabAktarilacak.first;
    //ilk satırdan son satıra kadar aktarım
    while not TabAktarilacak.Eof do begin
      //ilk sütundaki seç değeri değiştirilenler aktarılmaz..
      try
        if cxGrid1DBTableView1NAME.EditValue=True then begin
          if RehberSatiriniVer(TabAktarilacak.FieldByName('KOD').AsString,CnnStrGenotip,CnnStrEntegra) then
             cxGrid1DBTableView1NAME.EditValue:=True
          Else
             cxGrid1DBTableView1NAME.EditValue:=False;
        end;
      finally
        TabAktarilacak.Next;
      end;
    end;
  end
  else if cxImageComboBox1.Text = RGenotipdanStokFaturasiAl then  begin
    TabAktarilacak.first;
    //ilk satırdan son satıra kadar aktarım
    while not TabAktarilacak.Eof do begin
      //ilk sütundaki seç değeri değiştirilenler aktarılmaz..
      try
        if cxGrid1DBTableView1NAME.EditValue=True then begin
          if StokFaturasiAl(TabAktarilacak.FieldByName('GIRNO').AsInteger,True,True,CnnStrGenotip,CnnStrEntegra) then
             cxGrid1DBTableView1NAME.EditValue:=True
          Else
             cxGrid1DBTableView1NAME.EditValue:=False;
        end;
      finally
        TabAktarilacak.Next;
      end;
    end;
  end
  else if cxImageComboBox1.Text =RGentegreDevirCariBankaKasa then  begin
    TabAktarilacak.first;
    //ilk satırdan son satıra kadar aktarım
    while not TabAktarilacak.Eof do begin
      //ilk sütundaki seç değeri değiştirilenler aktarılmaz..
      try
        if cxGrid1DBTableView1NAME.EditValue=True then begin
        //kod ve kur a göre
          if DevirBankaKasaCari(TabAktarilacak.FieldByName('KOD').AsString,TabAktarilacak.FieldByName('KUR').AsString,True,True,CnnStrGenotip,CnnStrEntegra) then
             cxGrid1DBTableView1NAME.EditValue:=True
          Else
             cxGrid1DBTableView1NAME.EditValue:=False;
        end;
      finally
        TabAktarilacak.Next;
      end;
    end;
  end
  else if cxImageComboBox1.Text = RGentegreDevirCekSenet then  begin
    TabAktarilacak.first;
    //ilk satırdan son satıra kadar aktarım
    while not TabAktarilacak.Eof do begin
      //ilk sütundaki seç değeri değiştirilenler aktarılmaz..
      try
        if cxGrid1DBTableView1NAME.EditValue=True then begin
          if DevirBankaCekSenet(TabAktarilacak.FieldByName('ANAHTAR').AsInteger,True,True,CnnStrGenotip,CnnStrEntegra) then
             cxGrid1DBTableView1NAME.EditValue:=True
          Else
             cxGrid1DBTableView1NAME.EditValue:=False;
        end;
      finally
        TabAktarilacak.Next;
      end;
    End;
  end
  else if cxImageComboBox1.Text = RGentegreDevirCariYılDetay then begin
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    Tablo.Query1.SQL.Text:=' select VirmanDurum=reverse(substring(REVERSE(ACIKLAMA),1,3)),  '
              +' SIRANO,TARIH,ACIKLAMA, '
              +' CARIKOD=isnull(CARIKOD,''''),CARIAD, '
              +' HESAPKODU=isnull(HESAPKODU,''''),HESAPADI, '
              +' BORC,CIKAN,KUR,MASRAFKOD,MASRAFAD,KURDEF=isnull(KUR,''TL'') '
              +' from KASA where  year(TARIH)=Year(GetDate()) AND ACIKLAMA <>''DEVİR'' ';
    Tablo.Query1.Open;
    Tablo.Query1.First;
    while not Tablo.Query1.Eof do begin
      try
        GentegreCariYilDevir(Tablo.Query1.FieldByName('SIRANO').AsInteger,CnnStrGenotip,CnnStrEntegra);
      finally
        Tablo.Query1.Next;
      end;
    end;
  end;
  ConnectionlariDuzelt(Tablo.FDCnn);
  if i>0 then
    ShowMessage(RHataliSatirSayisi+inttostr(i))
  else
    ShowMessage(RAktarimBasarili)
end;

Function TReplikasyonDlg.GentegreCariYilDevir(GirNo:Integer;GenoCnn,EntegCnn: String):boolean;
Var
  rehid,hesapid,masrafid,tur:Integer;
Begin
  Result:=False;
  try
    //Tablo.HizliConnection(GenoCnn,EntegCnn);
    if True then begin
      Tablo.Query3.Close;
      Tablo.Query3.Connection:=Tablo.FDCnn;
      Tablo.Query3.SQL.Text:='SELECT ID FROM REHBER WHERE KOD = '''+Tablo.Query1.FieldByName('CARIKOD').AsString+'''';
      Tablo.Query3.Open;
      try
        rehid:=Tablo.Query3.fields[0].AsInteger;
      Except
        rehid:=0
      end;
      Tablo.Query3.Close;
      Tablo.Query3.Connection:=Tablo.FDCnn;
      Tablo.Query3.SQL.Text:='SELECT ID FROM BANKAHESAPLAR WHERE HESAPKODU = '''+Tablo.Query1.FieldByName('HESAPKODU').AsString+''''
                            +' union all '
                            +'SELECT ID FROM KASALAR WHERE KASAKODU = '''+Tablo.Query1.FieldByName('HESAPKODU').AsString+'''';
      Tablo.Query3.Open;
      try
        hesapid:=Tablo.Query3.fields[0].AsInteger;
      Except
        hesapid:=0
      end;
      Tablo.Query3.Close;
      Tablo.Query3.Connection:=Tablo.FDCnn;
      Tablo.Query3.SQL.Text:='SELECT ID FROM REHBER WHERE KOD = '''+Tablo.Query1.FieldByName('MASRAFKOD').AsString+'''';
      Tablo.Query3.Open;
      try
        masrafid:=Tablo.Query3.fields[0].AsInteger;
      Except
        masrafid:=0
      end;
      //işlem türünü bulalım..;
      if Tablo.Query1.FieldByName('VirmanDurum').AsString = '<--' then begin    //çıkan virmandaki
        tur:=0;
        //virman durumları
        if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='100' then begin //kasadan
           Tablo.Query4.Close;
           Tablo.Query4.Connection:=Tablo.FDCnn;
           Tablo.Query4.SQL.Text:= 'select KURDEF=isnull(KUR,''TL''),* from KASA where SIRANO = '+inttostr(Tablo.Query1.FieldByName('SIRANO').AsInteger+1);
           Tablo.Query4.Open;
           if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='100' then begin //kasadan kasaya
             tur:=40;
             //kur değiştirme durumlarında;
             if Tablo.Query1.FieldByName('KURDEF').AsString <> Tablo.Query4.FieldByName('KURDEF').AsString then begin
               if Tablo.Query1.FieldByName('KURDEF').AsString='TL' then begin  // TL ile döviz alınmış
                 tur:= 45;
               end Else begin  // döviz bozdurulmuş
                 tur:= 46;
               end;
             end;
           end else if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='102' then begin //kasadan bankaya
             tur:=41;
           end;
        end Else if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='102' then begin //bankadan
           Tablo.Query4.Close;
           Tablo.Query4.Connection:=Tablo.FDCnn;
           Tablo.Query4.SQL.Text:= 'select KURDEF=isnull(KUR,''TL''),* from KASA where SIRANO = '+inttostr(Tablo.Query1.FieldByName('SIRANO').AsInteger+1);
           Tablo.Query4.Open;
           if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='100' then begin //bankadan kasaya
             tur:=42;
           end else if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='102' then begin //bankadan bankaya
             tur:=43;
             //kur değiştirme durumlarında;
             if Tablo.Query1.FieldByName('KURDEF').AsString <> Tablo.Query4.FieldByName('KURDEF').AsString then begin
               if Tablo.Query1.FieldByName('KURDEF').AsString='TL' then begin // TL ile döviz alınmış
                 tur:= 47;
               end Else begin  // döviz bozdurulmuş
                 tur:= 48;
               end;
             end;
           end;
        end;
      end Else if Tablo.Query1.FieldByName('VirmanDurum').AsString = '-->' then begin   //BORC virmandaki
        // virmandaki ikinci satır bu bölüm birşey yapılmadan geçilir.. işlem zaten üst tarafta yapıldı..
        exit;
      end Else begin   // virman değil ise;
        if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='100' then begin //kasadan
           if Tablo.Query1.FieldByName('BORC').AsInteger>0 then begin //kasaya para girişi
             tur:=21
           end Else if Tablo.Query1.FieldByName('ALACAK').AsInteger>0 then begin //kasadan para çıkışı
             tur:=31
           end;
        end Else if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='102' then begin //bankadan   (BORC yada çıkan)
           if Tablo.Query1.FieldByName('BORC').AsInteger>0 then begin //kasaya para girişi
             tur:=22
           end Else if Tablo.Query1.FieldByName('ALACAK').AsInteger>0 then begin //kasadan para çıkışı
             tur:=32
           end;
        end;
      end;
      Tablo.Query2.Close;
      Tablo.Query2.Connection:=Tablo.FDCnn;
      Tablo.Query2.SQL.Text:= 'INSERT INTO KASA (TUR,ISLEMTARIHI,REHBERID,HESAPID,MASRAFID,BORC,ALACAK,KUR,ACIKLAMA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU) VALUES ( '
                             +inttostr(tur)+','''
                             +formatdatetime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('TARIH').AsDateTime) +''','
                             +inttostr(rehid)+','
                             +inttostr(hesapid)+','
                             +inttostr(masrafid)+','
                             +FExtToStr(Tablo.Query1.FieldByName('BORC').AsFloat)+','
                             +FExtToStr(Tablo.Query1.FieldByName('ALACAK').AsFloat)+','''
                             +Tablo.Query1.FieldByName('KUR').AsString+''','''
                             +Tablo.Query1.FieldByName('ACIKLAMA').AsString+''','+IntToStr(SubeId)+',0,''TL'')'
                             +' select SCOPE_IDENTITY()';
      Tablo.Query2.Open;
      if tur in [40..48] then begin //virmanlar için ikinci satır insert
        Tablo.Query5.Close;
        Tablo.Query5.Connection:=Tablo.FDCnn;
        Tablo.Query5.SQL.Text := 'INSERT INTO KASA (TUR,ISLEMTARIHI,REHBERID,HESAPID,MASRAFID,BORC,ALACAK,KUR,ACIKLAMA,GERIDONUSID,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU) VALUES ( '
                               +inttostr(tur)+','''
                               +formatdatetime('yyyy-mm-dd hh:nn',Tablo.Query4.FieldByName('TARIH').AsDateTime) +''','
                               +inttostr(rehid)+','
                               +inttostr(hesapid)+','
                               +inttostr(masrafid)+','
                               +FExtToStr(Tablo.Query4.FieldByName('BORC').AsFloat)+','
                               +FExtToStr(Tablo.Query4.FieldByName('ALACAK').AsFloat)+','''
                               +Tablo.Query4.FieldByName('KUR').AsString+''','''
                               +(Tablo.Query4.FieldByName('ACIKLAMA').AsString)+''','
                               +Tablo.Query2.fields[0].asstring+','+IntToStr(SubeId)+',0,''TL'')'
                               +' select SCOPE_IDENTITY()';
        Tablo.Query5.Open;
        Tablo.Query6.Close;
        Tablo.Query6.Connection:=Tablo.FDCnn;
        Tablo.Query6.SQL.Text := 'UPDATE KASA SET GERIDONUSID = '
                               +Tablo.Query5.fields[0].asstring
                               +' where ID = '
                               +Tablo.Query2.fields[0].asstring;
        Tablo.Query6.ExecSQL;
      end;
    end;
      Result := False;
  Except
    ShowMessage(RAktarimHatasi+' SIRANO='+Tablo.Query1.fieldbyname('SIRANO').asstring);
    Result := False;
  end;
End;

Procedure TReplikasyonDlg.HizliConnection( CNNGen, CNNEnt: string);
Begin
  if ReplikasyonDlg=nil then
    Application.CreateForm(TReplikasyonDlg,ReplikasyonDlg);
  if ReplikasyonDlg.CNNEntegra.Connected = False then begin
    if CNNEnt <> '' then
      ReplikasyonDlg.CNNEntegra.ConnectionString := CNNEnt
    Else
      ReplikasyonDlg.CNNEntegra.ConnectionString := Tablo.FDCnn.ConnectionString;
    if ReplikasyonDlg.CNNEntegra.ConnectionString <> '' then begin
      try
        ReplikasyonDlg.CNNEntegra.Connected;
      except
        ShowMessage(REntegraBaglantiHatasi);
      end;
    end;
  end;
  if ReplikasyonDlg.CNNGenotip.Connected = False then begin
    if CNNGen <> '' then begin
      ReplikasyonDlg.CNNGenotip.ConnectionString := CNNGen;
      try
        ReplikasyonDlg.CNNGenotip.Connected;
      except
        ShowMessage(GenotipBaglantiHatasi);
      end;
    end Else begin
      Tablo.TablodanSorguAc(4,'select * from BAGLANTILAR where TUR like ''%2%'' ');
      if not Tablo.Query4.IsEmpty then
        Tablo.BaglantiAc(Tablo.Query4.FieldByName('ID').AsInteger,ReplikasyonDlg.CNNGenotip)
      Else if GetGenotipConnectionString<>'' then begin
        ReplikasyonDlg.CNNGenotip.ConnectionString := GetGenotipConnectionString;
        try
          ReplikasyonDlg.CNNGenotip.Connected;
        except
          ShowMessage(GenotipBaglantiHatasi);
        end;
      end;
    end;
    try
      ReplikasyonDlg.CNNGenotip.Connected;
    except
      ShowMessage(GenotipBaglantiHatasi);
    end;
  end;
End;

Function TReplikasyonDlg.StokFaturasiSil(GirNo:Integer;GenoCnn,EntegCnn: String):boolean;
VAR
  ID:Integer;
Begin
  Result:=False;
  try
    HizliConnection(GenoCnn,EntegCnn);
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    Tablo.Query1.sql.text:='select ID,DURUM FROM FATBASLIK WHERE OZELKOD = '+inttostr(Girno);
    Tablo.Query1.Open;

    if not Tablo.Query1.IsEmpty then begin
      if Tablo.Query1.fields[1].AsInteger =0 then begin
        Tablo.Query1.First;
        Result:=Tablo.query1.recordcount=0;
        while Not Tablo.Query1.Eof do begin
          ID:=Tablo.Query1.fields[0].AsINTEGER;
          Tablo.Query4.Close;
          Tablo.Query4.Connection:=Tablo.FDCnn;
          Tablo.Query4.SQL.Text:='DELETE FROM FATBASLIK WHERE ID='+INTTOSTR(ID);
          Tablo.Query4.ExecSQL;

          Tablo.Query2.Close;
          Tablo.Query2.Connection:=Tablo.FDCnn;
          Tablo.Query2.SQL.Text:='DELETE FROM FATURA WHERE FATBASID = '+INTTOSTR(ID);
          Tablo.Query2.ExecSQL;
          Tablo.Query2.SQL.Text:='DELETE FROM KASA WHERE FATURAID = '+INTTOSTR(ID);
          Tablo.Query2.ExecSQL;

          Tablo.Query1.Next;
          Result:=True;
        end;
      end
      Else begin
        Result := False;
        ShowMessage(RFaturaSilinmeyeUygunDegildir);
      end;
    end Else begin
        Result := true;
//        ShowMessage('Faturanın Entegra kaydı bulunamadı.');
    end;
  Except
    ShowMessage(REntegraFaturaSilmeHatasi);
    Result := False;
  end;
  ConnectionlariDuzelt(Tablo.FDCnn);
End;

Function TReplikasyonDlg.StokFaturasiGuncelle(GirNo:Integer;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
Begin
  try
    HizliConnection(GenoCnn,EntegCnn);
    if True then begin

      Result := True;
    end Else
      Result := False;
  Except
    ShowMessage(RAktarimHatasi);
    Result := False;
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
End;

Function TReplikasyonDlg.DevirBankaKasaCari(Kod,Kur:string;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
Begin
  try
    HizliConnection(GenoCnn,EntegCnn);
    if True then begin
      if Copy((Kod),0,3)  ='100' then begin  //kasa kayıtları
        try
          Tablo.Query2.Close;
          Tablo.Query2.Connection:=Tablo.FDCnn;
          Tablo.Query2.sql.text:=  'INSERT INTO KASALAR(KASAKODU,KASAADI,KUR,HESAPACIKLAMA,DURUM,SUBEID) VALUES ('''
                +TabAktarilacak.FieldByName('KOD').AsString+''','''
                +TabAktarilacak.FieldByName('AD').AsString+''','''
                +TabAktarilacak.FieldByName('KUR').AsString+''','''
                +'Gentegre Aktarımı'',1,'+IntToStr(SubeId)+') '
                +' select SCOPE_IDENTITY()';
          Tablo.Query2.Open;
        Except
          Tablo.Query2.Close;
          Tablo.Query2.sql.text:= 'select ID from KASALAR where KASAKODU='''+kod+'''';
          Tablo.Query2.Open;
        end;
        Tablo.Query3.Close;
        Tablo.Query3.Connection:=Tablo.FDCnn;
        Tablo.Query3.sql.text:=  'INSERT INTO KASA(ISLEMTARIHI,REHBERID,HESAPID,BORC,ALACAK,KUR,HESAPTURU,DURUM,ACIKLAMA,TUR,KASA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU) VALUES ('''
              +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''',0,'
              +Tablo.Query2.Fields[0].AsString+','
              +TabAktarilacak.FieldByName('BORC').AsString+','
              +TabAktarilacak.FieldByName('ALACAK').AsString+','''
              +TabAktarilacak.FieldByName('KUR').AsString+''',''K'',-1,''Açılış Fişi'',1,0,'+IntToStr(SubeId)+',0,''TL'')'
              +' select SCOPE_IDENTITY()';
        Tablo.Query3.Open;
      end else if Copy((Kod),0,3)='102' then begin  //banka hesapları
        try
          Tablo.Query2.Close;
          Tablo.Query2.Connection:=Tablo.FDCnn;
          Tablo.Query2.sql.text:=  'insert into BANKAHESAPLAR(HESAPKODU,HESAPADI,DURUM,REHBERID,GUNLUKAKSIYONDAGOSTER,HESAPNO,BANKASUBELERID,SUBEID)values ('''
                +TabAktarilacak.FieldByName('KOD').AsString+''','''
                +TabAktarilacak.FieldByName('AD').AsString+''',1,-1,1,0,1,'+IntToStr(SubeId)+') '
                +' select SCOPE_IDENTITY()';
          Tablo.Query2.Open;
        Except
          Tablo.Query2.Close;
          Tablo.Query2.sql.text:= 'select ID from BANKAHESAPLAR where HESAPKODU='''+kod+'''';
          Tablo.Query2.Open;
        end;
        Tablo.Query3.Close;
        Tablo.Query3.Connection:=Tablo.FDCnn;
        Tablo.Query3.sql.text:= 'INSERT INTO KASA(ISLEMTARIHI,PLANTARIHI,MASRAFID,HESAPID,REHBERID,BORC,ALACAK,KUR,HESAPTURU,DURUM,ACIKLAMA,TUR,KASA,FATURAID,CEKSENETID,GERIDONUSID,KREDIID,DOVIZ_TUTARI,DOVIZ_KURU,SUBEID) VALUES ('''
              +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','''
              +'1900-01-01 00:00:00.000'+''',0,'
              +Tablo.Query2.Fields[0].AsString+','
              +'0'+','
              +TabAktarilacak.FieldByName('BORC').AsString+','
              +TabAktarilacak.FieldByName('ALACAK').AsString+','''
              +TabAktarilacak.FieldByName('KUR').AsString+''',''B'',-1,''Açılış Fişi'',1,0,-1,-1,-1,-1,0,'''','+IntToStr(SubeId)+')'
              +' select SCOPE_IDENTITY()';
        Tablo.Query3.Open;
      end else if Copy((Kod),0,3)='120' then begin
        Tablo.Query2.Close;
        Tablo.Query2.Connection:=Tablo.FDCnn;
        Tablo.Query2.SQL.Text:='Select ID from REHBER where KOD = '''+kod+'''';
        Tablo.Query2.Open;
        if not Tablo.Query2.IsEmpty then Begin
          Tablo.Query3.Close;
          Tablo.Query3.Connection:=Tablo.FDCnn;
          Tablo.Query3.sql.text:=  'INSERT INTO KASA(ISLEMTARIHI,REHBERID,HESAPID,BORC,ALACAK,KUR,HESAPTURU,DURUM,ACIKLAMA,TUR,KASA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU) VALUES ('''
              +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','
              +Tablo.Query2.Fields[0].AsString+','
              +'0'+','
              +TabAktarilacak.FieldByName('BORC').AsString+','
              +TabAktarilacak.FieldByName('ALACAK').AsString+','''
              +TabAktarilacak.FieldByName('KUR').AsString+''',''K'',-1,''Açılış Fişi'',1,0,'+IntToStr(SubeId)+',0,''TL'')'
              +' select SCOPE_IDENTITY()';
          Tablo.Query3.Open;
        End;
      end else if Copy((Kod),0,3)='320' then begin
        Tablo.Query2.Close;
        Tablo.Query2.Connection:=Tablo.FDCnn;
        Tablo.Query2.SQL.Text:='Select ID from REHBER where KOD = '''+kod+'''';
        Tablo.Query2.Open;
        if not Tablo.Query2.IsEmpty then Begin
          Tablo.Query3.Close;
          Tablo.Query3.Connection:=Tablo.FDCnn;
          Tablo.Query3.sql.text:=  'INSERT INTO KASA(ISLEMTARIHI,REHBERID,HESAPID,BORC,ALACAK,KUR,HESAPTURU,DURUM,ACIKLAMA,TUR,KASA,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU) VALUES ('''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','
                +'0'+','
                +Tablo.Query2.Fields[0].AsString+','
                +TabAktarilacak.FieldByName('BORC').AsString+','
                +TabAktarilacak.FieldByName('ALACAK').AsString+','''
                +TabAktarilacak.FieldByName('KUR').AsString+''',''K'',-1,''Açılış Fişi'',1,0,'+IntToStr(SubeId)+',0,''TL'')'
                +' select SCOPE_IDENTITY()';
          Tablo.Query3.Open;
        End;
      end;

    end else
    Result := False;
  Except
    ShowMessage(RAktarimHatasi);
    Result := False;
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
End;

Function TReplikasyonDlg.GeninidenDegerGetir(Bolum:integer;Anahtar:string):string;
begin
  ADOQuery1.Close;
  ADOQuery1.Connection:=Tablo.FDCnn;
  ADOQuery1.SQL.Text:='select DEGER from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM='+IntToStr(Bolum)+' and ANAHTAR='''+Anahtar+'';
  ADOQuery1.Open;
  if not ADOQuery1.IsEmpty then
    Result := ADOQuery1.Fields[0].AsString
  else
    Result := '';
end;

Function TReplikasyonDlg.GeninidenAnahtarGetir(Bolum,Deger:integer):string;
begin
  ADOQuery1.Close;
  ADOQuery1.Connection:=Tablo.FDCnn;
  ADOQuery1.SQL.Text:='select ANAHTAR from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM='+IntToStr(Bolum)+' and DEGER='+inttoStr(Deger)+' ';
  ADOQuery1.Open;
  if not ADOQuery1.IsEmpty then
    Result := ADOQuery1.Fields[0].AsString
  else
    Result := '';
end;



Function TReplikasyonDlg.StokKartEkleEntegradanGenotipa(StokKod,GenoCnn,EntegCnn: String):boolean;
var
  yeri,uretici,ureticiadi,satici,saticiadi:string;
  sktvar,serinovar:Boolean;
Begin
  try
    HizliConnection(GenoCnn,EntegCnn);
    if StokKod<>'' then begin
       yeri:='';
       Tablo.Query1.Close;
       Tablo.Query1.Connection:=Tablo.FDCnn;
       Tablo.Query1.SQL.Text:='select * from STOKLAR where KOD='''+StokKod+'';
       Tablo.Query1.Open;
       Tablo.Query1.FetchAll;
       if Tablo.Query1.RecordCount<>1 then
          raise Exception.Create(inttostr(Tablo.Query1.RecordCount)+' tane kayıt var!!!');
       if Tablo.Query1.FieldByName('YERI').AsString<>'' then begin
         Tablo.Query3.Close;
         Tablo.Query3.Connection:=Tablo.FDCnn;
         Tablo.Query3.SQL.Text:='select ACIKLAMA from LOKASYON where ID='''+Tablo.Query1.FieldByName('YERI').AsString+'';
         Tablo.Query3.Open;
         Tablo.Query3.FetchAll;
         if Tablo.Query3.RecordCount=1 then
            yeri := Tablo.Query3.Fields[0].AsString;
       end;
       if Tablo.Query1.FieldByName('URETICIID').AsString<>'' then begin
         uretici := '';
         ureticiadi := '';
         Tablo.Query3.Close;
         Tablo.Query3.Connection:=Tablo.FDCnn;
         Tablo.Query3.SQL.Text:='select KOD,FIRMA from REHBER where ID='''+Tablo.Query1.FieldByName('URETICIID').AsString+'';
         Tablo.Query3.Open;
         Tablo.Query3.FetchAll;
         if Tablo.Query3.RecordCount=1 then begin
            uretici := Tablo.Query3.Fields[0].AsString;
            ureticiadi := Tablo.Query3.Fields[1].AsString;
         end;
       end;
       if Tablo.Query1.FieldByName('SATICIID').AsString<>'' then begin
         satici := '';
         saticiadi := '';
         Tablo.Query3.Close;
         Tablo.Query3.Connection:=Tablo.FDCnn;
         Tablo.Query3.SQL.Text:='select KOD,FIRMA from REHBER where ID='''+Tablo.Query1.FieldByName('SATICIID').AsString+'';
         Tablo.Query3.Open;
         Tablo.Query3.FetchAll;
         if Tablo.Query3.RecordCount=1 then begin
            satici := Tablo.Query3.Fields[0].AsString;
            saticiadi := Tablo.Query3.Fields[1].AsString;
         end;
       end;
       sktvar:=Tablo.Query1.FieldByName('IZLEME').AsString='2';
       serinovar:=Tablo.Query1.FieldByName('IZLEME').AsString='1';
       Tablo.Query2.Close;
       Tablo.Query2.Connection:=Tablo.FDCnn;
       Tablo.Query2.SQL.Text:=' INSERT INTO STOKKART '
           +' (KOD,STOKADI,GRUBU,OZELLIK,OZELKOD,BUTCEKODU,MUHKODU,ANABIRIM '
           +'  ,BIRIM2,BIRIM3,BIRIM2MIKTAR,BIRIM3MIKTAR,MINSTOK,YERI '
           +'  ,URETICI,URETICIADI,SATICI,SATICIADI,ISKONTO,KDV,SKT_VAR  '
           +'  ,BARKOD,FIYAT_TARIHI,SERITAKIP,TEKNIKSARTNAME,AKTIF,SUBEID ) '
           +' VALUES (:PKOD,:PSTOKADI,:PGRUBU,:POZELLIK,:POZELKOD,:PBUTCEKODU,:PMUHKODU '
           +'  ,:PANABIRIM,:PBIRIM2,:PBIRIM3,:PBIRIM2MIKTAR,:PBIRIM3MIKTAR,:PMINSTOK,:PYERI '
           +'  ,:PURETICI,:PURETICIADI,:PSATICI,:PSATICIADI,:PISKONTO,:PKDV,:PSKT_VAR '
           +'  ,:PBARKOD,:PFIYAT_TARIHI,:PSERITAKIP,:PTEKNIKSARTNAME,:PAKTIF,PSUBEID ) '
           +' select scope_identity() '  ;
       Tablo.Query2.ParamByName('PKOD').Value            := StokKod;
       Tablo.Query2.ParamByName('PSTOKADI').Value        := Tablo.Query1.FieldByName('STOKADI').AsString;
       Tablo.Query2.ParamByName('PGRUBU').Value          := GeninidenAnahtarGetir(Ops_StokKart_Grubu,Tablo.Query1.FieldByName('GRUBU').AsInteger);  // StokKart_Grubu
       Tablo.Query2.ParamByName('POZELLIK').Value        := GeninidenAnahtarGetir(Ops_StokKart_Ozellik,Tablo.Query1.FieldByName('OZELLIK').AsInteger);   //  StokKart_Özellik
       Tablo.Query2.ParamByName('POZELKOD').Value        := Tablo.Query1.FieldByName('OZELKOD').AsString;
       Tablo.Query2.ParamByName('PBUTCEKODU').Value      := '';
       Tablo.Query2.ParamByName('PMUHKODU').Value        := Tablo.Query1.FieldByName('MUHKODU').AsString;
       Tablo.Query2.ParamByName('PANABIRIM').Value       := GeninidenAnahtarGetir(Ops_StokKart_Anabirim,Tablo.Query1.FieldByName('ANABIRIM').AsInteger);   // StokKart_Anabirim
       Tablo.Query2.ParamByName('PBIRIM2').Value         := GeninidenAnahtarGetir(Ops_StokKart_Anabirim,Tablo.Query1.FieldByName('PBIRIM2').AsInteger);   //   StokKart_Anabirim
       Tablo.Query2.ParamByName('PBIRIM2MIKTAR').Value   := Tablo.Query1.FieldByName('PBIRIM2MIKTAR').AsInteger;
       Tablo.Query2.ParamByName('PMINSTOK').Value        := Tablo.Query1.FieldByName('PMINSTOK').AsInteger;
       Tablo.Query2.ParamByName('PYERI').Value           := yeri;
       Tablo.Query2.ParamByName('PURETICI').Value        := uretici;
       Tablo.Query2.ParamByName('PURETICIADI').Value     := ureticiadi;
       Tablo.Query2.ParamByName('PSATICI').Value         := satici;
       Tablo.Query2.ParamByName('PSATICIADI').Value      := saticiadi;
       Tablo.Query2.ParamByName('PISKONTO').Value        := 0;
       Tablo.Query2.ParamByName('PKDV').Value            := Tablo.Query1.FieldByName('KDV').AsInteger;
       Tablo.Query2.ParamByName('PSKT_VAR').Value        := sktvar;
       Tablo.Query2.ParamByName('PBARKOD').Value         := Tablo.Query1.FieldByName('BARKOD').AsString;
       Tablo.Query2.ParamByName('PSERITAKIP').Value      := serinovar;
       Tablo.Query2.ParamByName('PAKTIF').Value          := Tablo.Query1.FieldByName('DURUM').AsInteger;
       Tablo.Query2.ParamByName('PSUBEID').Value         := Tablo.Query1.FieldByName('SUBEID').AsInteger;
       Tablo.Query2.Open;
       Result := True;
    end;
  Except
    ShowMessage(RAktarimHatasi);
    Result := False;
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
End;

Function TReplikasyonDlg.StokKartEkleGenotipdanEntegraya(StokKod,GenoCnn,EntegCnn: String):boolean;
var
  LokasyonID,UreticiID,SaticiID:Integer;
Begin
  try
    HizliConnection(GenoCnn,EntegCnn);
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    Tablo.Query1.SQL.Text:='select * from STOKKART where KOD='''+StokKod+'';
    Tablo.Query1.Open;
     if Tablo.Query1.RecordCount<>1 then
        raise Exception.Create(inttostr(Tablo.Query1.RecordCount)+' tane kayıt var!!!');
     if Tablo.Query1.FieldByName('YERI').AsString<>'' then begin
       Tablo.Query3.Close;
       Tablo.Query3.Connection:=Tablo.FDCnn;
       Tablo.Query3.SQL.Text:='select ID from LOKASYON where ACIKLAMA='''+Tablo.Query1.FieldByName('YERI').AsString+'';
       Tablo.Query3.Open;
       if Tablo.Query3.RecordCount=1 then
          LokasyonID := Tablo.Query3.Fields[0].AsInteger;
     end;
     if Tablo.Query1.FieldByName('URETICI').AsString<>'' then begin
       Tablo.Query3.Close;
       Tablo.Query3.Connection:=Tablo.FDCnn;
       Tablo.Query3.SQL.Text:='select ID from REHBER where KOD='''+Tablo.Query1.FieldByName('URETICI').AsString+'''';
       Tablo.Query3.Open;
       Tablo.Query3.FetchAll;
       if Tablo.Query3.RecordCount=1 then
          UreticiID := Tablo.Query3.Fields[0].AsInteger;
     end;
     if Tablo.Query1.FieldByName('SATICI').AsString<>'' then begin
       Tablo.Query3.Close;
       Tablo.Query3.Connection:=Tablo.FDCnn;
       Tablo.Query3.SQL.Text:='select ID from REHBER where KOD='''+Tablo.Query1.FieldByName('SATICI').AsString+'''';
       Tablo.Query3.Open;
       Tablo.Query3.FetchAll;
       if Tablo.Query3.RecordCount=1 then
          SaticiID := Tablo.Query3.Fields[0].AsInteger;
     end;
      Tablo.Query2.Close;
      Tablo.Query2.Connection:=Tablo.FDCnn;
      Tablo.Query2.SQL.Text:=
        'INSERT INTO STOKLAR (KOD,STOKADI,TIPI,GRUBU,OZELLIK,OZELKOD,MUHKODU  '+
                   ',ANABIRIM,BIRIM2,BIRIM2MIKTAR,MINSTOK,YERI,URETICIID,SATICIID  '+
                   ',KDV,BARKOD,DURUM,SUBEID) '+
        'VALUES (:PKOD,:PSTOKADI,:PTIPI,:PGRUBU,:POZELLIK,:POZELKOD,:PMUHKODU  '+
                   ',:PANABIRIM,:PBIRIM2,:PBIRIM2MIKTAR,:PMINSTOK,:PYERI,:PURETICIID,:PSATICIID  '+
                   ',:PKDV,:PBARKOD,:PDURUM,:PSUBEID  select SCOPE_IDENTITY() ' ;
      Tablo.Query2.ParamByName('PKOD').Value          := StokKod;
      Tablo.Query2.ParamByName('PSTOKADI').Value      := Tablo.Query1.FieldByName('STOKADI').AsString;
      Tablo.Query2.ParamByName('PTIPI').Value         := 1;
      Tablo.Query2.ParamByName('PGRUBU').Value        := GeninidenDegerGetir(Ops_StokKart_Grubu,Tablo.Query1.FieldByName('GRUBU').AsString);  //    StokKart_Grubu
      Tablo.Query2.ParamByName('POZELLIK').Value      := '';
      Tablo.Query2.ParamByName('POZELKOD').Value      := Tablo.Query1.FieldByName('OZELKOD').AsString;
      Tablo.Query2.ParamByName('PMUHKODU').Value      := Tablo.Query1.FieldByName('MUHKODU').AsString;
      Tablo.Query2.ParamByName('PANABIRIM').Value     := GeninidenDegerGetir(Ops_StokKart_Anabirim,Tablo.Query1.FieldByName('ANABIRIM').AsString);     //StokKart_Anabirim
      Tablo.Query2.ParamByName('PBIRIM2').Value       := GeninidenDegerGetir(Ops_StokKart_Anabirim,Tablo.Query1.FieldByName('BIRIM2').AsString);     //StokKart_Anabirim
      Tablo.Query2.ParamByName('PBIRIM2MIKTAR').Value := Tablo.Query1.FieldByName('BIRIM2MIKTAR').AsInteger;
      Tablo.Query2.ParamByName('PMINSTOK').Value      := Tablo.Query1.FieldByName('MINSTOK').AsInteger;
      Tablo.Query2.ParamByName('PYERI').Value         := LokasyonID;
      Tablo.Query2.ParamByName('PURETICIID').Value    := UreticiID;
      Tablo.Query2.ParamByName('PSATICIID').Value     := SaticiID;
      Tablo.Query2.ParamByName('PKDV').Value          := Tablo.Query1.FieldByName('KDV').AsInteger;
      Tablo.Query2.ParamByName('PBARKOD').Value       := Tablo.Query1.FieldByName('BARKOD').AsString;
      Tablo.Query2.ParamByName('PDURUM').Value        := Tablo.Query1.FieldByName('AKTIF').AsInteger;
      Tablo.Query2.ParamByName('PSUBEID').Value       := Tablo.Query1.FieldByName('SUBEID').AsInteger;
      Tablo.Query2.Open;
  Except
    ShowMessage(RAktarimHatasi);
    Result := False;
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
End;

Function TReplikasyonDlg.DevirBankaCekSenet(GirNo:Integer;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
Begin
  try
    HizliConnection(GenoCnn,EntegCnn);
    if True then begin
      Tablo.Query1.Close;
      Tablo.Query1.Connection:=Tablo.FDCnn;
      Tablo.Query1.sql.text:= 'select KURDEF= case when ISNULL(KUR,'''')='''' then ''TL'' ELSE KUR END,* from KASA '
          +' where SIRANO = '+inttostr(GirNo);
      Tablo.Query1.Open;
      //rehberid sini bulalım
      Tablo.Query3.Close;
      Tablo.Query3.Connection:=Tablo.FDCnn;
      Tablo.Query3.sql.text:= 'select ID from REHBER '
          +' where KOD = '''+tablo.Query1.FieldByName('CARIKOD').AsString+'''';
      Tablo.Query3.Open;
      if not Tablo.Query3.IsEmpty then Begin
        if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='101' then begin
          Tablo.Query2.Close;
          Tablo.Query2.Connection:=Tablo.FDCnn;
          Tablo.Query2.sql.text:= 'INSERT INTO CEKLER (KOD,REHBERID,TUR,DURUM,TARIH,VADE,TUTAR,KUR,ACIKLAMA,SERINO,SUBEID) VALUES ('
                +''''+tablo.Query1.FieldByName('HESAPKODU').AsString+''','+Tablo.Query3.Fields[0].AsString+',23,1,'''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('TARIH').AsDateTime) +''','''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('VADE').AsDateTime) +''','
                +Tablo.Query1.FieldByName('BORC').AsString+','''
                +Tablo.Query1.FieldByName('KURDEF').AsString+''','''
                +Tablo.Query1.FieldByName('ACIKLAMA').AsString+''',0,'+IntToStr(SubeId)+')';
          Tablo.Query2.ExecSQL;
        end else if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='103' then begin
          Tablo.Query2.Close;
          Tablo.Query2.Connection:=Tablo.FDCnn;
          Tablo.Query2.sql.text:= 'INSERT INTO CEKLER (KOD,REHBERID,TUR,DURUM,TARIH,VADE,TUTAR,KUR,ACIKLAMA,SERINO,SUBEID) VALUES ('
                +''''+tablo.Query1.FieldByName('HESAPKODU').AsString+''','+Tablo.Query3.Fields[0].AsString+',33,1,'''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('TARIH').AsDateTime) +''','''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('VADE').AsDateTime) +''','
                +Tablo.Query1.FieldByName('ALACAK').AsString+','''
                +Tablo.Query1.FieldByName('KURDEF').AsString+''','''
                +Tablo.Query1.FieldByName('ACIKLAMA').AsString+''',0,'+IntToStr(SubeId)+')';
          Tablo.Query2.ExecSQL;
        end else if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='121' then begin
          Tablo.Query2.Close;
          Tablo.Query2.Connection:=Tablo.FDCnn;
          Tablo.Query2.sql.text:= 'INSERT INTO SENETLER (KOD,REHBERID,TUR,DURUM,TARIH,VADE,TUTAR,KUR,ACIKLAMA,SUBEID) VALUES ('
                +''''+tablo.Query1.FieldByName('HESAPKODU').AsString+''','+Tablo.Query3.Fields[0].AsString+',24,1,'''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('TARIH').AsDateTime) +''','''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('VADE').AsDateTime) +''','
                +Tablo.Query1.FieldByName('BORC').AsString+','''
                +Tablo.Query1.FieldByName('KURDEF').AsString+''','''
                +Tablo.Query1.FieldByName('ACIKLAMA').AsString+''','+IntToStr(SubeId)+')';
          Tablo.Query2.ExecSQL;

        end else if Copy(Tablo.Query1.FieldByName('HESAPKODU').AsString,0,3)='321' then begin
          Tablo.Query2.Close;
          Tablo.Query2.Connection:=Tablo.FDCnn;
          Tablo.Query2.sql.text:= 'INSERT INTO SENETLER (KOD,REHBERID,TUR,DURUM,TARIH,VADE,TUTAR,KUR,ACIKLAMA,SUBEID) VALUES ('
                +''''+tablo.Query1.FieldByName('HESAPKODU').AsString+''','+Tablo.Query3.Fields[0].AsString+',34,1,'''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('TARIH').AsDateTime) +''','''
                +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('VADE').AsDateTime) +''','
                +Tablo.Query1.FieldByName('ALACAK').AsString+','''
                +Tablo.Query1.FieldByName('KURDEF').AsString+''','''
                +Tablo.Query1.FieldByName('ACIKLAMA').AsString+''','+IntToStr(SubeId)+')';
          Tablo.Query2.ExecSQL;
        end;
      end Else
        Result := False;
    end else
    Result := False;
  Except
    ShowMessage(RAktarimHatasi);
    Result := False;
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
End;

Function TReplikasyonDlg.StokFaturasiAl(GirNo:Integer;SatirEkle,PlanEkle:Boolean;GenoCnn,EntegCnn: String):boolean;
Var
  Kod:string;
  FBID,RehID,MasrafID,HesapID,Vergino:Integer;
  Plan:Boolean ;
  KDVTutari,FaturaMatrahi:Currency;
  FatOdemeTarihi:TDateTime;
begin
  try
    if True then begin
     HizliConnection(GenoCnn,EntegCnn);
     //****************************************************
     (*                     Fatbaşlık                    *)
     //****************************************************
      Tablo.Query1.Close;
      Tablo.Query1.Connection:=Tablo.FDCnn;
      Tablo.Query1.SQL.Text:='SELECT * FROM STOKGIRIS WHERE GIRNO = '+inttostr(Girno);
      Tablo.Query1.Open;

      FatOdemeTarihi:=Tablo.Query1.FieldByName('ODEME_TARIHI').AsDateTime;
      Plan := Tablo.Query1.FieldByName('FIRMAKODU').AsString <> '';
      Kod:=Tablo.Query1.FieldByName('FIRMAKODU').AsString;
      if Kod='' then begin
         ShowMessage(RFaturadaEslesmeicinFirmaKoduYok);
         raise Exception.Create(RFaturadaEslesmeicinFirmaKoduYok);
      end;
      Tablo.Query2.Close; //rehberID
      Tablo.Query2.Connection:=Tablo.FDCnn;
      Tablo.Query2.SQL.Text:='SELECT ID FROM REHBER WHERE KOD = '''+Kod+'''';
      Tablo.Query2.Open;
      if Tablo.Query2.IsEmpty then begin
         ShowMessage(ROnceRehberKayitlariniziAktarin);
         raise Exception.Create(ROnceRehberKayitlariniziAktarin);
      end
      Else
         RehID:=Tablo.Query2.fields[0].AsInteger;
      Tablo.Query2.Close; //MasrafID
      Tablo.Query2.Connection:=Tablo.FDCnn;
      Tablo.Query2.SQL.Text:='SELECT ID FROM MASRAFGELIR WHERE KOD = '''+Tablo.Query1.FieldByName('MASRAFMERKEZKOD').AsString+'''';
      Tablo.Query2.Open;
      MasrafID:=Tablo.Query2.fields[0].AsInteger;

      Tablo.Query2.Close;
      Tablo.Query2.Connection:=Tablo.FDCnn;
      Tablo.Query2.SQL.Text:='INSERT INTO FATBASLIK (TARIH,TUR,REHBERID,FATURATARIH,FATURANO,BASLIK,ADRES,ILCE,IL,VD,VNO ' //11 param
                            +',KDVDURUM,FATURA_TUTARI,KUR,DOVIZ_TUTARI,KASA,KULLANICI,MASRAFID,ACIKLAMA '
                            +',DURUM,ODEMEPLANI,EKLEYEN,OZELKOD,SUBEID) '
                            +'VALUES(:PTARIH,:PTUR,:PREHBERID,:PFATURATARIH,:PFATURANO,:PBASLIK,:PADRES,:PILCE '
                            +',:PIL,:PVD,:PVNO,:PKDVDURUM,:PFATURA_TUTARI,:PKUR,:PDOVIZ_TUTARI,:PKASA,:PKULLANICI '
                            +',:PMASRAFID,:PACIKLAMA,:PDURUM,:PODEMEPLANI '
                            +',:PEKLEYEN,:OZELKOD,:SUBEID) select SCOPE_IDENTITY() ';
      Tablo.Query2.Params[0].Value := FormatDateTime('yyyy-mm-dd hh:nn',Bugun);  //tarih
      Tablo.Query2.Params[1].Value := 11;                                                          // tür
      Tablo.Query2.Params[2].Value := RehID;                                                       //rehberid
      Tablo.Query2.Params[3].Value := FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('BELGETARIH').AsDateTime); //fattarih
      Tablo.Query2.Params[4].Value := Tablo.Query1.FieldByName('BELGENO').AsInteger;
      TabBizim.Close;
      TabBizim.Connection:=Tablo.FDCnn;
      TabBizim.Params[0].Value := -1;
      TabBizim.Open;
      Tablo.Query2.Params[5].Value :=  TabBizim.FieldByName('FATURABASLIK').AsString;
      Tablo.Query2.Params[6].Value :=  TabBizim.FieldByName('ADRES').AsString;
      Tablo.Query2.Params[7].Value :=  TabBizim.FieldByName('ILCE').AsString;
      Tablo.Query2.Params[8].Value :=  TabBizim.FieldByName('IL').AsString;
      Tablo.Query2.Params[9].Value :=  TabBizim.FieldByName('VERGIDAI').AsString;
      if TabBizim.FieldByName('VERGINO').Value=null then
        Vergino:=0
      else
        Vergino:=TabBizim.FieldByName('VERGINO').AsInteger;
      Tablo.Query2.Params[10].Value := Vergino;
      Tablo.Query2.Params[11].Value := 0;         //kdv
      Tablo.Query2.Params[12].Value := Tablo.Query1.FieldByName('TUTAR').AsCurrency;  //top tutar, diğerleri satırlarda hesaplanıcak..
      Tablo.Query2.Params[13].Value := Tablo.Query1.FieldByName('DOVIZTIPI').AsString ; //kur
      Tablo.Query2.Params[14].Value := 0.00;  //döv tutarı
      Tablo.Query2.Params[15].Value := 0; //kasa
      Tablo.Query2.Params[16].Value := Tablo.Query1.FieldByName('KULLANICI').AsString ; //genotıp kullanıcısı
      Tablo.Query2.Params[17].Value := MasrafID;
      Tablo.Query2.Params[18].Value := 'Genotıp Stok Notları: '+Tablo.Query1.FieldByName('NOTLAR').AsString ;
      Tablo.Query2.Params[19].Value := 0;
      Tablo.Query2.Params[20].Value := Plan;
      Tablo.Query2.Params[21].Value := Kullanan ;
//      Tablo.Query2.Params[22].Value := FormatDateTime('yyyy-mm-dd hh:nn',genotipini.BugunTrh);
      Tablo.Query2.Params[22].Value := IntToStr(GirNo);
      Tablo.Query2.Params[23].Value := SubeId;
      Tablo.Query2.Open;
      FBID:=Tablo.Query2.Fields[0].AsInteger;
     //****************************************************
     (*                  Fatura Satırları                *)
     //****************************************************
     KDVTutari:=0.0;
     FaturaMatrahi:=0.0;
     if SatirEkle then begin
        Tablo.Query3.Close;
        Tablo.Query3.Connection:=Tablo.FDCnn;
        Tablo.Query3.SQL.Text:='SELECT * FROM STOKGIRHAR WHERE GIRNO = '+inttostr(Girno);
        Tablo.Query3.Open;
        Tablo.Query3.First;

        Tablo.Query4.Close;
        Tablo.Query4.Connection:=Tablo.FDCnn;
        Tablo.Query4.SQL.Text:='INSERT INTO FATURA '
             +'(FATBASID,REHBERID,KOD,ACIKLAMA,MASRAFID,ADET,BIRIM,MIKTAR,BIRIMFIYAT,TUTAR,ISKONTO,KDV '
             +',KULLANICI,EKLEYEN,SUBEID) '
             +'VALUES(:PFATBASID,:PREHBERID,:PKOD,:PACIKLAMA,:PMASRAFID,:PADET,:PBIRIM,:PMIKTAR,:PBIRIMFIYAT '
             +',:PTUTAR,:PISKONTO,:PKDV,:PKULLANICI,:PEKLEYEN,:PSUBEID ) ';
        while Not Tablo.Query3.Eof do begin
           //masrafmerkezkod varsa id sini bulalım
          Tablo.Query5.Close;
          Tablo.Query5.Connection:=Tablo.FDCnn;
          Tablo.Query5.SQL.Text:='SELECT ID FROM MASRAFGELIR WHERE KOD = '''+Tablo.Query3.FieldByName('MASRAFMERKEZKOD').AsString+'''';
          Tablo.Query5.Open;
          Tablo.Query4.Params[0].Value := FBID;
          Tablo.Query4.Params[1].Value := RehID;
          Tablo.Query4.Params[2].Value := Tablo.Query3.FieldByName('STOKKOD').AsString;
          Tablo.Query4.Params[3].Value := Copy(Tablo.Query3.FieldByName('STOKAD').AsString,0,100);
          Tablo.Query4.Params[4].Value := Tablo.Query5.FieldByName('ID').AsInteger;
          Tablo.Query4.Params[5].Value := Tablo.Query3.FieldByName('ADET').AsInteger;
          Tablo.Query4.Params[6].Value := Tablo.Query3.FieldByName('BIRIM').AsString;
          Tablo.Query4.Params[7].Value := Tablo.Query3.FieldByName('MIKTAR').AsInteger;
          Tablo.Query4.Params[8].Value := Tablo.Query3.FieldByName('BIRIMFIYAT').AsCurrency;
          Tablo.Query4.Params[9].Value := Tablo.Query3.FieldByName('TUTAR').AsCurrency;
          Tablo.Query4.Params[10].Value := Tablo.Query3.FieldByName('ISK1').AsInteger+Tablo.Query3.FieldByName('ISK2').AsInteger;
          Tablo.Query4.Params[11].Value := Tablo.Query3.FieldByName('KDV').AsInteger;
          Tablo.Query4.Params[12].Value := Tablo.Query3.FieldByName('KULLANICI').AsString;
          Tablo.Query4.Params[13].Value := Kullanan;
          Tablo.Query4.Params[14].Value := Tablo.Query3.FieldByName('SUBEID').AsString;
          Tablo.Query4.ExecSQL;
          KDVTutari:=KDVTutari + (Tablo.Query3.FieldByName('KDV').AsInteger*Tablo.Query3.FieldByName('TUTAR').AsCurrency/100);
          FaturaMatrahi:= FaturaMatrahi + Tablo.Query3.FieldByName('TUTAR').AsCurrency;
          Tablo.Query3.Next;
        end;
     end Else begin
        KDVTutari:=0.0;
        FaturaMatrahi:=Tablo.Query3.FieldByName('TUTAR').AsCurrency;
     end;

     //****************************************************
     (*        fatura toplam alanları güncelle           *)
     //****************************************************
      // Toplamlar sunucuda: burada matrah SUM(TUTAR) idi (iskonto uygulanmamis) ve
      //   iskontolar ISK1+ISK2 TOPLANARAK tek alana yaziliyordu - carpimsal iskonto
      //   kuralina aykiriydi (SP/TOPLAM_FORMUL_KARSILASTIRMA.md §3 C6).
      Tablo.BelgeToplamHesapla(FBID);

     //****************************************************
     (*                       Plan                       *)
     //****************************************************
     if plan and PlanEkle then
      if FatOdemeTarihi>0 then
     begin
        //hesapkodunu idye çevirelim
        Tablo.Query5.Close;
        Tablo.Query5.Connection:=Tablo.FDCnn;
        Tablo.Query5.SQL.Text:= 'SELECT ID FROM KASALAR WHERE KASAKODU = '''+Tablo.Query1.FieldByName('HESAPKODU').AsString+'''';

        Tablo.Query6.Close;
        Tablo.Query6.Connection:=Tablo.FDCnn;
        Tablo.Query6.SQL.Text:='INSERT INTO KASA(TUR,PLANTARIHI,ISLEMTARIHI,REHBERID,HESAPID,BORC,ALACAK,KUR '
             +' ,ACIKLAMA,FATURAID,EKLEYEN,SUBEID,DOVIZ_TUTARI,DOVIZ_KURU) VALUES ('
             +' 71,'''
             +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('ODEME_TARIHI').AsDateTime)+''','''
             +FormatDateTime('yyyy-mm-dd hh:nn',Tablo.Query1.FieldByName('BELGETARIH').AsDateTime)+''', '
             +inttostr(RehID)+', '
             +inttostr(HesapID)+', '
             +inttostr(0)+', '
             +Tablo.Query1.FieldByName('TUTAR').AsString+','''
             +Tablo.Query1.FieldByName('DOVIZTIPI').AsString+''','''
             +'Genotıp Stok Aktarımı.'+''','
             +inttostr(FBID)+','''
             +Kullanan+''','+IntToStr(SubeId)+',0,''TL'')';

        Tablo.Query6.ExecSQL;
     end else
       ShowMessage(ROdemeTarihiGirilmemis);
     Result := True;
    end else
    Result := False;
  Except
    ShowMessage(RAktarimHatasi);
    Result := False;
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
end;

procedure TReplikasyonDlg.cxButton3Click(Sender: TObject);
begin
  EntegradanRehberiGenotipaGuncelle('120.01','','')
end;

procedure TReplikasyonDlg.cxButton4Click(Sender: TObject);
begin
  RehberHareketiVarmi('120.01','','',True);
end;


function TReplikasyonDlg.RehberSatiriniVer(Kod,GenoCnn,EntegCnn:string): boolean;
Var
  aramadaciksin:string;
  RehID:Integer;
Begin
  try
    HizliConnection(GenoCnn,EntegCnn);
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    Tablo.Query1.SQL.Text:='SELECT KOD FROM REHBER';
    Tablo.Query1.Open;
    //aynı kaydın bizde olup olmadığı koduna bakılarak kontrol edilir..  //
    if not Tablo.Query1.Locate('KOD',Kod,[]) then begin
       if TabAktarilacak.State = dsInactive then begin
          TabAktarilacak.Close;
          TabAktarilacak.Connection:=Tablo.FDCnn;
          TabAktarilacak.SQL.Text:= 'SELECT STATU,KOD,FIRMA,GRUP,DURUM,NOTLAR,ARAMADACIKSIN,C_ILGILI,C_TICARI,C_SOZLESME,C_GORUSME,EKLEYEN,SUBEID, '
              +'ISTEL=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=40 '+DbSinir(1)+'), '
              +'CEP=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=42 '+DbSinir(1)+'),   '
              +'FAX=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=41 '+DbSinir(1)+'),   '
              +'ADRES=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=2 '+DbSinir(1)+'),   '
              +'ILCE=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=6 '+DbSinir(1)+'),     '
              +'IL=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=8 '+DbSinir(1)+'),        '
              +'PK=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=4 '+DbSinir(1)+'),         '
              +'VERGIDAI=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20 '+DbSinir(1)+'),   '
              +'VERGINO=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22 '+DbSinir(1)+'),     '
              +'WEB=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=48 '+DbSinir(1)+'),          '
              +'EMAIL=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=46 '+DbSinir(1)+'),        '
              +'FATURABASLIK=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=10 '+DbSinir(1)+')   '
              +'FROM REHBER R WHERE KOD='''+Kod+'''';
          TabAktarilacak.Open;
       end;

       if TabAktarilacak.FieldByName('DURUM').Asinteger = 0 then
          aramadaciksin:='H'
       Else
          aramadaciksin:='';
       Tablo.Query5.Close;
       Tablo.Query5.Connection:=Tablo.FDCnn;
       Tablo.Query5.SQL.Text:='INSERT INTO REHBER(KOD,FIRMA,GRUP,ISTEL,CEP,FAX,EMAIL '
              +',WEB,ADRES,ILCE,IL,PK,VERGIDAI,VERGINO,NOTLAR,FATURABASLIK,ARAMADACIKSIN,SUBEID) '
              +'VALUES(:KOD,:FIRMA,:GRUP,:ISTEL,:CEP,:FAX,:EMAIL, '
              +':WEB,:ADRES,:ILCE,:IL,:PK,:VERGIDAI,:VERGINO,:NOTLAR,:FATURABASLIK,:ARAMADACIKSIN,:SUBEID) ';
       Tablo.Query5.Params[0].Value:=Copy(TabAktarilacak.FieldByName('KOD').AsString,1,20);
       Tablo.Query5.Params[1].Value:=Copy(TabAktarilacak.FieldByName('FIRMA').AsString,1,50);
       Tablo.Query5.Params[2].Value:=Copy(TabAktarilacak.FieldByName('GRUP').AsString,1,10);
       Tablo.Query5.Params[3].Value:=Copy(TabAktarilacak.FieldByName('ISTEL').AsString,1,20);
       Tablo.Query5.Params[4].Value:=Copy(TabAktarilacak.FieldByName('CEP').AsString,1,20);
       Tablo.Query5.Params[5].Value:=Copy(TabAktarilacak.FieldByName('FAX').AsString,1,20);
       Tablo.Query5.Params[6].Value:=Copy(TabAktarilacak.FieldByName('EMAIL').AsString,1,50);
       Tablo.Query5.Params[7].Value:=Copy(TabAktarilacak.FieldByName('WEB').AsString,1,50);
       Tablo.Query5.Params[8].Value:=Copy(TabAktarilacak.FieldByName('ADRES').AsString,1,50);
       Tablo.Query5.Params[9].Value:=Copy(TabAktarilacak.FieldByName('ILCE').AsString,1,20);
       Tablo.Query5.Params[10].Value:=Copy(TabAktarilacak.FieldByName('IL').AsString,1,25);
       Tablo.Query5.Params[11].Value:=Copy(TabAktarilacak.FieldByName('PK').AsString,1,6);
       Tablo.Query5.Params[12].Value:=Copy(TabAktarilacak.FieldByName('VERGIDAI').AsString,1,15);
       Tablo.Query5.Params[13].Value:=Copy(TabAktarilacak.FieldByName('VERGINO').AsString,1,15);
       Tablo.Query5.Params[14].Value:=Copy(TabAktarilacak.FieldByName('NOTLAR').AsString,1,150);
       Tablo.Query5.Params[15].Value:=Copy(TabAktarilacak.FieldByName('FATURABASLIK').AsString,1,100);
       Tablo.Query5.Params[16].Value:='1';
       Tablo.Query5.Params[17].Value:=TabAktarilacak.FieldByName('SUBEID').AsString;
       Tablo.Query5.ExecSQL;
       Result := True;
    end Else
       Result := False;
  Except
    ShowMessage(RAktarimHatasi);
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
End;

function TReplikasyonDlg.RehberSatiriniAl(Kod,GenoCnn,EntegCnn:string): boolean;
Var
  aramadaciksin,SQLParam,Grup:string;
  RehID:Integer;
Begin
  Try
    HizliConnection(GenoCnn,EntegCnn);
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    Tablo.Query1.SQL.Text:='SELECT KOD FROM REHBER';
    Tablo.Query1.Open;
    //aynı kaydın bizde olup olmadığı koduna bakılarak kontrol edilir..  //
    if not Tablo.Query1.Locate('KOD',TabAktarilacak.FieldByName('KOD').AsString,[]) then begin
       if TabAktarilacak.FieldByName('ARAMADACIKSIN').AsString='H' then
          aramadaciksin:='0'
       Else
          aramadaciksin:='1';
       Grup:=Copy(TabAktarilacak.FieldByName('KOD').AsString,0,3);
       Tablo.Query2.Close;
       Tablo.Query2.Connection:=Tablo.FDCnn;
       Tablo.Query2.SQL.Text:='INSERT INTO REHBER ' +
             '([KOD],[FIRMA],[GRUP],[DURUM],[NOTLAR],[ARAMADACIKSIN]' +
             ',[C_ILGILI],[C_TICARI],[C_SOZLESME],[C_GORUSME],[EKLEYEN],[SUBEID]) ' +
             'VALUES ('''+
             TabAktarilacak.FieldByName('KOD').AsString+''','''+
             TabAktarilacak.FieldByName('FIRMA').AsString+''','''+
             Grup+''','+'1,'''+
             TabAktarilacak.FieldByName('NOTLAR').AsString+''','+aramadaciksin+','+
             '1,1,1,1,'''+Kullanan+''','+IntToStr(SubeId)+' )';
       Tablo.Query2.ExecSQL;
       //eklediğimiz satırı açıp aldığı ID yi bulalım
       Tablo.Query3.Close;
       Tablo.Query3.Connection:=Tablo.FDCnn;
       Tablo.Query3.SQL.Text:='select * from REHBER where KOD = '''+TabAktarilacak.FieldByName('KOD').AsString+'''';
       Tablo.Query3.Open;
       RehID := Tablo.Query3.FieldByName('ID').AsInteger;
       // eklenecek alanları bulalım(varsayılanı dolu olanlar..
       Tablo.Query4.Close;
       Tablo.Query4.Connection:=Tablo.FDCnn;
       Tablo.Query4.SQL.Text:='select DISTINCT VARSAYILAN, YERI, ETIKET,SIRA from REHBERAYAR where isnull(VARSAYILAN,'''')<>'''' ';
       Tablo.Query4.Open;
       while not Tablo.Query4.Eof do begin
         SQLParam:='';
         case Tablo.Query4.FieldByName('YERI').AsInteger of
           1: begin
               case Tablo.Query4.FieldByName('VARSAYILAN').AsInteger of
                  2:	SQLParam := 'EVADRES';//  Adres
                  4:	SQLParam := 'EVPK';//  Adres PK
                  6:	SQLParam := 'EVILCE';//  Adres ILCE
                  8:	SQLParam := 'EVIL';//  Adres IL
                  40: SQLParam := 'ISTEL';//  İş Tel
                  42: SQLParam := 'CEP';//	Cep Tel
                  44: SQLParam := 'EVTEL';//	Ev Tel
                  46: SQLParam := 'EMAIL';//	E-Posta
                  48: SQLParam := 'WEB';//	Web
               end;
           end;
           2: begin
               case Tablo.Query4.FieldByName('VARSAYILAN').AsInteger of
                  10: SQLParam := 'FATURABASLIK';//	Fatura Başlığı
                  20: SQLParam := 'VERGIDAI';//	Vergi Dairesi
                  22: SQLParam := 'VERGINO';//	Vergi No
               end;
           end;
         end;
         if SQLParam<>'' then begin
           Tablo.Query5.Close;
           Tablo.Query5.Connection:=Tablo.FDCnn;
           Tablo.Query5.SQL.Text := 'INSERT INTO REHBERBILGI(YERI,SIRA,YER_ID,ETIKET,BILGI,EKLEYEN,SUBEID) VALUES('+
                             Tablo.Query4.FieldbyName('YERI').AsString+','+Tablo.Query4.FieldByName('SIRA').AsString+','+inttostr(RehID)+','''+
                             Tablo.Query4.FieldbyName('ETIKET').AsString+''','''+TabAktarilacak.FieldByName(SQLParam).AsString+''','''+Kullanan+''','+IntToStr(SubeId)+')' ;
           Tablo.Query5.ExecSQL;
         end;
         // ilgili satır insert edilir..
         Tablo.Query4.Next;
       end;
       Result := True;
    end Else
       Result := False;
  Except
    ShowMessage(RAktarimHatasi);
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
End;

procedure TReplikasyonDlg.AciklamaYaz;
Begin
  cxRichEdit1.Lines.Clear;
  if cxImageComboBox1.Text = RGenotipdanRehberAl then  begin
     cxRichEdit1.Lines.Add(RDigerTumAlanlarOpsiyoneldir);
     cxRichEdit1.Lines.Add(RHesapPlaniniYapilandir);
     cxRichEdit1.Lines.Add(RBirSonrakiKayittanDevamEdilecek);
     cxRichEdit1.Lines.Add(REklenecekOpsiyonelAlanlar);
     cxRichEdit1.Lines.Add(RAdresBilgileri);
  end else  if cxImageComboBox1.Text = RGenotipeRehberVer then  begin
     cxRichEdit1.Lines.Add(REklenecekAlanlar);
     cxRichEdit1.Lines.Add(RAdresBilgileri2);
  end else  if cxImageComboBox1.Text = RGenotipdanStokFaturasiAl then begin
     cxRichEdit1.Lines.Add(RBuBolumeGecmedenOnce);
     cxRichEdit1.Lines.Add(RRehberAktarımınıTamamla);
     cxRichEdit1.Lines.Add(REntegradaTanımlıOlmasıGerek);
     cxRichEdit1.Lines.Add(RRehberAktariminiziTamamla);
     cxRichEdit1.Lines.Add(RBirlikteAktarilacaktir);
  end else if cxImageComboBox1.Text = RGentegreDevirCariBankaKasa then begin
     cxRichEdit1.Lines.Add(RBuBolumeGecmedenOnce);
     cxRichEdit1.Lines.Add(RRehberAktarımınıTamamla);
     cxRichEdit1.Lines.Add(RCariDevirKayitlariAktarilmayacak);
     cxRichEdit1.Lines.Add(RBankaTanimlamalariYenidenDuzenle);
     cxRichEdit1.Lines.Add(RLogayaTiklayarakYap);
  end else if cxImageComboBox1.Text = RGentegreDevirCekSenet then begin
     cxRichEdit1.Lines.Add(RBuBolumeGecmedenOnce);
     cxRichEdit1.Lines.Add(RRehberAktarımınıTamamla);
     cxRichEdit1.Lines.Add(RCekVeSenetlericerisinden);
     cxRichEdit1.Lines.Add(RTumVerilerAktarilacaktir);
  end else if cxImageComboBox1.Text = RGentegreDevirCariYılDetay then begin
     cxRichEdit1.Lines.Add(RBuBolumeGecmedenOnce);
     cxRichEdit1.Lines.Add(RDuzenlemeleriTamamlamisOlmali);
     cxRichEdit1.Lines.Add(RKayitlarSistemUzerineEklenebilir);
  end;
End;

procedure TReplikasyonDlg.cxImageComboBox1PropertiesEditValueChanged(
  Sender: TObject);
Var
i:Integer;
begin
  AciklamaYaz;
  Try
    if cxImageComboBox1.Text = RGenotipdanRehberAl then  begin
      cxGrid1DBTableView1.DataController.KeyFieldNames := 'KOD';
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      TabAktarilacak.Close;
      TabAktarilacak.Connection:=Tablo.FDCnn;
      //CNNGenotip.ConnectionString;
      TabAktarilacak.SQL.Text:='select * from REHBER WHERE KOD LIKE ''120.%'' OR KOD LIKE ''320.%'' OR KOD LIKE ''335.%'' ';
      TabAktarilacak.Open;
      cxButton2.Enabled:=True;
      //grid içerisine seçilen yeni tabloyu açarız(Tüm Kayıtlar)
      for i := 0 to TabAktarilacak.FieldCount-1 do begin
        cxGrid1DBTableView1.CreateColumn;
        with cxGrid1DBTableView1.Columns[i+1] do begin
          DataBinding.FieldName := TabAktarilacak.Fields[i].FieldName;
          Caption := TabAktarilacak.Fields[i].FieldName;
          Width := 80;
          //Properties.ReadOnly:=True;
        end;
      end;
    end else  if cxImageComboBox1.Text = RGenotipeRehberVer then  begin
      cxGrid1DBTableView1.DataController.KeyFieldNames := 'KOD';
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      TabAktarilacak.Close;
      TabAktarilacak.Connection:=Tablo.FDCnn;
      TabAktarilacak.SQL.Text:= 'SELECT KOD,FIRMA,GRUP,DURUM,NOTLAR,ISNULL(ARAMADACIKSIN,''True''),C_ILGILI,C_TICARI,C_SOZLESME,C_GORUSME,EKLEYEN, '
          +'ISTEL=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=40 '+DbSinir(1)+'), '
          +'CEP=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=42 '+DbSinir(1)+'),   '
          +'FAX=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=41 '+DbSinir(1)+'),   '
          +'ADRES=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=2 '+DbSinir(1)+'),   '
          +'ILCE=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=6 '+DbSinir(1)+'),     '
          +'IL=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=8 '+DbSinir(1)+'),        '
          +'PK=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=4 '+DbSinir(1)+'),         '
          +'VERGIDAI=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20 '+DbSinir(1)+'),   '
          +'VERGINO=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22 '+DbSinir(1)+'),     '
          +'WEB=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=48 '+DbSinir(1)+'),          '
          +'EMAIL=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=46 '+DbSinir(1)+'),        '
          +'FATURABASLIK=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=10 '+DbSinir(1)+')   '
          +'FROM REHBER R ';
      TabAktarilacak.Open;
      Tablo.Query1.Close;
      Tablo.Query1.Connection:=Tablo.FDCnn;
      Tablo.Query1.SQL.Text:='select * from REHBER';
      Tablo.Query1.Open;
      //grid içerisine seçilen yeni tabloyu açarız(Tüm Kayıtlar)
      for i := 0 to TabAktarilacak.FieldCount-1 do begin
        cxGrid1DBTableView1.CreateColumn;
        with cxGrid1DBTableView1.Columns[i+1] do begin
          DataBinding.FieldName := TabAktarilacak.Fields[i].FieldName;
          Caption := TabAktarilacak.Fields[i].FieldName;
          Width := 80;
        end;
      end;
      cxButton2.Enabled:=True;
    end else  if cxImageComboBox1.Text = RGenotipdanStokFaturasiAl then begin
      cxGrid1DBTableView1.DataController.KeyFieldNames := 'GIRNO';
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      TabAktarilacak.Close;
      TabAktarilacak.Connection:=Tablo.FDCnn;
      //CNNGenotip.ConnectionString;
      TabAktarilacak.SQL.Text:='select * from STOKGIRIS where BELGETIPI =''FATURA''';
      TabAktarilacak.Open;
      cxButton2.Enabled:=True;
      //grid içerisine seçilen yeni tabloyu açarız(Tüm Kayıtlar)
      for i := 0 to TabAktarilacak.FieldCount-1 do begin
        cxGrid1DBTableView1.CreateColumn;
        with cxGrid1DBTableView1.Columns[i+1] do begin
          DataBinding.FieldName := TabAktarilacak.Fields[i].FieldName;
          Caption := TabAktarilacak.Fields[i].FieldName;
          Width := 80;
          //Properties.ReadOnly:=True;
        end;
      end;
    end else if cxImageComboBox1.Text = RGentegreDevirCariBankaKasa then begin
      cxGrid1DBTableView1.DataController.KeyFieldNames := 'ANAHTAR';
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      TabAktarilacak.Close;
      TabAktarilacak.Connection:=Tablo.FDCnn;
      //CNNGenotip.ConnectionString;
      TabAktarilacak.SQL.Text:=
        //banka ve kasalar
          'select KOD=R.KOD,AD=R.FIRMA,BORC=sum(ISNULL(BORC,0)),ALACAK=sum(ISNULL(ALACAK,0)),  '
          +'  KUR=CASE WHEN ISNULL(KUR,'''')='''' THEN ''TL'' ELSE KUR END, '
          +'  ANAHTAR= R.KOD+KUR '
          +'from KASA K INNER JOIN REHBER R ON K.HESAPKODU=R.KOD '
          +'where ISNULL(ACIKLAMA,'''')<> ''DEVİR''  '
          +'group by R.KOD,R.FIRMA,KUR  '
          +'having (ISNULL(R.KOD,'''') LIKE ''100.%'' or ISNULL(R.KOD,'''') LIKE ''102.%'') '
          +'AND ISNULL(R.FIRMA,'''')<>'''' '
          +'union all '
        //cari hesaplar
          +'select KOD=R.KOD,AD=R.FIRMA,BORC=sum(ISNULL(BORC,0)),ALACAK=sum(ISNULL(ALACAK,0)), '
          +'  KUR=CASE WHEN ISNULL(KUR,'''')='''' THEN ''TL'' ELSE KUR END,  '
          +'  ANAHTAR= R.KOD+KUR '
          +'from KASA K INNER JOIN REHBER R ON K.CARIKOD=R.KOD '
          +'where ISNULL(ACIKLAMA,'''')<> ''DEVİR'' '
          +'group by R.KOD,R.FIRMA,KUR '
          +'having (ISNULL(R.KOD,'''') LIKE ''120.%'' or ISNULL(R.KOD,'''') LIKE ''320.%'') '
          +'and (ISNULL(R.KOD,'''')NOT IN ('''',''VİRMAN'') AND ISNULL(R.FIRMA,'''')NOT IN ('''',''VİRMAN'')) '
          +'order by 1 ';

      TabAktarilacak.Open;
      cxButton2.Enabled:=True;
      //grid içerisine seçilen yeni tabloyu açarız(Tüm Kayıtlar)
      for i := 0 to TabAktarilacak.FieldCount-1 do begin
        cxGrid1DBTableView1.CreateColumn;
        with cxGrid1DBTableView1.Columns[i+1] do begin
          DataBinding.FieldName := TabAktarilacak.Fields[i].FieldName;
          Caption := TabAktarilacak.Fields[i].FieldName;
          Width := 80;
          //Properties.ReadOnly:=True;
        end;
      end;
    end else if cxImageComboBox1.Text = RGentegreDevirCekSenet then begin
      cxGrid1DBTableView1.DataController.KeyFieldNames := 'ANAHTAR';
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      TabAktarilacak.Close;
      TabAktarilacak.Connection:=Tablo.FDCnn;
      //CNNGenotip.ConnectionString;
      TabAktarilacak.SQL.Text:=
           'select KOD=HESAPKODU,AD=''ÇEK-''+CARIAD,BORC,ALACAK,VADE, '
          +'KUR=CASE WHEN ISNULL(KUR,'''')='''' THEN ''TL'' ELSE KUR END,  '
          +'ANAHTAR=SIRANO '
          +'from KASA '
          +'where ISNULL(ACIKLAMA,'''')<> ''DEVİR'' AND isnull(VADE,''1900-01-01 00:00'')<>''1900-01-01 00:00'' and '
          +'(ISNULL(HESAPKODU,'''') LIKE ''101%'' OR ISNULL(HESAPKODU,'''') LIKE ''103%'' ) AND '
          +'(BORC<>0 OR ALACAK<>0) AND CARIAD<>''VİRMAN'' AND '
          +'ACIKLAMA <> ''DEVİR'' AND ISNULL(CEKSENETID,0)=0 AND ISNULL(DURUM,0)=0 '

          +'union all '

          +'select KOD=HESAPKODU,AD=''SNT-''+CARIAD,BORC,ALACAK,VADE, '
          +'KUR=CASE WHEN ISNULL(KUR,'''')='''' THEN ''TL'' ELSE KUR END,  '
          +'ANAHTAR=SIRANO '
          +'from KASA '
          +'where ISNULL(ACIKLAMA,'''')<> ''DEVİR'' AND isnull(VADE,''1900-01-01 00:00'')<>''1900-01-01 00:00'' and '
          +'(ISNULL(HESAPKODU,'''') LIKE ''121%'' OR ISNULL(HESAPKODU,'''') LIKE ''321%'' ) AND '
          +'(BORC<>0 OR ALACAK<>0) AND CARIAD<>''VİRMAN'' AND '
          +'ACIKLAMA <> ''DEVİR'' AND ISNULL(CEKSENETID,0)=0 AND ISNULL(DURUM,0)=0 '
          +' ORDER BY 1';
      TabAktarilacak.Open;
      cxButton2.Enabled:=True;
      //grid içerisine seçilen yeni tabloyu açarız(Tüm Kayıtlar)
      for i := 0 to TabAktarilacak.FieldCount-1 do begin
        cxGrid1DBTableView1.CreateColumn;
        with cxGrid1DBTableView1.Columns[i+1] do begin
          DataBinding.FieldName := TabAktarilacak.Fields[i].FieldName;
          Caption := TabAktarilacak.Fields[i].FieldName;
          Width := 80;
          //Properties.ReadOnly:=True;
        end;
      end;
    end else if cxImageComboBox1.Text = RGentegreDevirCariYılDetay then begin
      TabAktarilacak.Close;
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      cxButton2.Enabled:=True;
    end else if cxImageComboBox1.Text = RGenotipdanStokKartAl then begin
      TabAktarilacak.Close;
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      TabAktarilacak.Close;
      TabAktarilacak.Connection:=Tablo.FDCnn;
      TabAktarilacak.SQL.Text:='select * from STOKKART where AKTIF=1';
      TabAktarilacak.Open;
      cxButton2.Enabled:=True;
    end else if cxImageComboBox1.Text = RGenotipaStokKartVer then begin
      TabAktarilacak.Close;
      //bir önce açılmış olan tabloyu sileriz,
      if cxGrid1DBTableView1.ColumnCount > 1 then begin
         for I := (-cxGrid1DBTableView1.ColumnCount)+1 to -1 do
             cxGrid1DBTableView1.Columns[-i].Free;
      end;
      TabAktarilacak.Close;
      TabAktarilacak.Connection:=Tablo.FDCnn;
      TabAktarilacak.SQL.Text:='select * from STOKLAR where DURUM=1';
      TabAktarilacak.Open;
      cxButton2.Enabled:=True;
    end;
  Except
    ShowMessage(RAktarimHatasi);
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
end;

function TReplikasyonDlg.GenotipdanRehberiEntegrayaGuncelle(Kod,GenoCnn,EntegCnn: String): boolean;
Var
  aramadaciksin,SQLParam:string;
  RehID:Integer;
Begin
  Try
   HizliConnection(GenoCnn,EntegCnn);
   TabAktarilacak.Close;
   TabAktarilacak.Connection:=Tablo.FDCnn;
   TabAktarilacak.SQL.Text:='select * from REHBER WHERE KOD = '''+KOD+'''';
   TabAktarilacak.Open;
   if TabAktarilacak.FieldByName('ARAMADACIKSIN').AsString='H' then
      aramadaciksin:='0'
   Else
      aramadaciksin:='1';
   Tablo.Query2.Close;
   Tablo.Query2.Connection:=Tablo.FDCnn;
   Tablo.Query2.SQL.Text:='UPDATE REHBER SET ' +
                     ' FIRMA = '''+TabAktarilacak.FieldByName('FIRMA').AsString+''''+
                     ',GRUP = '''+TabAktarilacak.FieldByName('GRUP').AsString+''''+
                     ',DURUM = 1'+
                     ',NOTLAR = '''+TabAktarilacak.FieldByName('NOTLAR').AsString+''''+
                     ',ARAMADACIKSIN = '+aramadaciksin+
                     ',DEGISTIREN = '''+Kullanan+''''+
                     ',DEGISTIRMETARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn',Bugun)+''''+
                     ' WHERE KOD = '''+KOD+'''';
   Tablo.Query2.ExecSQL;
   //değiştirdiğimiz satırı açıp aldığı ID yi bulalım
   Tablo.Query3.Close;
   Tablo.Query3.Connection:=Tablo.FDCnn;
   Tablo.Query3.SQL.Text:='select * from REHBER where KOD = '''+TabAktarilacak.FieldByName('KOD').AsString+'''';
   Tablo.Query3.Open;
   RehID := Tablo.Query3.FieldByName('ID').AsInteger;
   // değiştirilecek alanları bulalım(varsayılanı dolu olanlar)..
   Tablo.Query4.Close;
   Tablo.Query4.Connection:=Tablo.FDCnn;
   Tablo.Query4.SQL.Text:='select  RA.VARSAYILAN, RB.YERI, RB.ETIKET,RB.BILGI '+
                          ' from REHBERAYAR RA inner join REHBERBILGI RB on RA.YERI=RB.YERI AND RA.ETIKET=RB.ETIKET '+
                          ' where isnull(RA.VARSAYILAN,'''')<>'''' AND RB.YER_ID = ' + inttostr(RehID);
   Tablo.Query4.Open;
   while not Tablo.Query4.Eof do begin
     case Tablo.Query4.FieldByName('VARSAYILAN').AsInteger of
        2:	SQLParam := 'EVADRES';//  Adres
        4:	SQLParam := 'EVPK';//  Adres PK
        6:	SQLParam := 'EVILCE';//  Adres ILCE
        8:	SQLParam := 'EVIL';//  Adres IL
        10: SQLParam := 'FATURABASLIK';//	Fatura Başlığı
        12: SQLParam := 'EVADRES';//	Fatura Adresi
        14: SQLParam := 'EVPK';//	Fatura Adresi PK
        16: SQLParam := 'EVILCE';//	Fatura Adresi ILCE
        18: SQLParam := 'EVIL';//	Fatura Adresi IL
        20: SQLParam := 'VERGIDAI';//	Vergi Dairesi
        22: SQLParam := 'VERGINO';//	Vergi No
       // 32: SQLParam := '';//	Masraf Merkezi
       // 34: SQLParam := '';//	Gelir Merkezi
       // 36: SQLParam := '';//	Tahakkuk
        40: SQLParam := 'ISTEL';//  İş Tel
        42: SQLParam := 'CEP';//	Cep Tel
        44: SQLParam := 'EVTEL';//	Ev Tel
        46: SQLParam := 'EMAIL';//	E-Posta
        48: SQLParam := 'WEB';//	Web
       //50: SQLParam := '';//	T.C.Kimlik No
       //52: SQLParam := '';//	Baba Ad
     end;
     // ilgili satır update edilir..
     Tablo.Query5.Close;
     Tablo.Query5.Connection:=Tablo.FDCnn;
     Tablo.Query5.SQL.Text := 'UPDATE REHBERBILGI SET BILGI = '''+TabAktarilacak.FieldByName(SQLParam).AsString+''',DEGISTIREN = '''+
                       Kullanan+''',DEGISTIRMETARIHI = '''+FormatDateTime('yyyy-mm-dd hh:nn',Bugun) +
                       ''' WHERE ETIKET = '''+Tablo.Query4.FieldByName('ETIKET').AsString +
                       ''' AND YER_ID = ' + inttostr(RehID);
     Tablo.Query5.ExecSQL;
     Tablo.Query4.Next;
   end;
  Except
    ShowMessage(RAktarimHatasi);
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
end;

function TReplikasyonDlg.EntegradanRehberiGenotipaGuncelle(Kod,GenoCnn,EntegCnn: String): boolean;
Var
  aramadaciksin:string;
begin
  Try
    HizliConnection(GenoCnn,EntegCnn);
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    Tablo.Query1.SQL.Text:=  'SELECT STATU,KOD,FIRMA,GRUP,DURUM,NOTLAR,ARAMADACIKSIN,C_ILGILI,C_TICARI,C_SOZLESME,C_GORUSME,EKLEYEN, '
        +'ISTEL=(SELECT '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=40 '+DbSinir(1)+'), '
        +'CEP=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=42 '+DbSinir(1)+'),   '
        +'FAX=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=64 '+DbSinir(1)+'),   '
        +'ADRES=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=2 '+DbSinir(1)+'),   '
        +'ILCE=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=6 '+DbSinir(1)+'),     '
        +'IL=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=8 '+DbSinir(1)+'),        '
        +'PK=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=4 '+DbSinir(1)+'),         '
        +'VERGIDAI=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=20 '+DbSinir(1)+'),   '
        +'VERGINO=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=22 '+DbSinir(1)+'),     '
        +'WEB=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=48 '+DbSinir(1)+'),          '
        +'EMAIL=(SELECT  '+DbUst(1)+'BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=46 '+DbSinir(1)+'),        '
        +'FATURABASLIK=(SELECT '+DbUst(1)+' BILGI FROM REHBERAYAR RA INNER JOIN REHBERBILGI RB ON RA.SIRA=RB.SIRA AND RA.YERI=RB.YERI WHERE RB.YER_ID=R.ID AND RA.VARSAYILAN=10 '+DbSinir(1)+')   '
        +'FROM REHBER R WHERE R.KOD = '''+Kod+'''';
    Tablo.Query1.Open;
    if Tablo.Query1.FieldByName('DURUM').AsInteger = 0 then
      aramadaciksin:='H'
    Else
      aramadaciksin:='';
    TabAktarilacak.Close;
    TabAktarilacak.Connection:=Tablo.FDCnn;
    TabAktarilacak.SQL.Text := 'UPDATE REHBER SET '+
                  '  FIRMA=  :P100 '+
                  ' ,GRUP=  :P101 '+
                  ' ,ISTEL= :P102 '+
                  ' ,CEP= :P103 '+
                  ' ,FAX= :P104 '+
                  ' ,EMAIL= :P105 '+
                  ' ,WEB= :P106 '+
                  ' ,ADRES= :P107 '+
                  ' ,ILCE= :P108 '+
                  ' ,IL= :P109 '+
                  ' ,PK= :P110 ' +
                  ' ,VERGIDAI= :P111 ' +
                  ' ,VERGINO= :P112 ' +
                  ' ,NOTLAR= :P113 ' +
                  ' ,FATURABASLIK= :P114 ' +
                  ' ,ARAMADACIKSIN= :P115 '+
                  ' WHERE KOD='''+Kod+'''';
    TabAktarilacak.Params[0].Value := ''+Copy(Tablo.Query1.FieldByName('FIRMA').AsString,1,50)+'';
    TabAktarilacak.Params[1].Value := ''+Copy(Tablo.Query1.FieldByName('GRUP').AsString,1,10)+'';
    TabAktarilacak.Params[2].Value := ''+Copy(Tablo.Query1.FieldByName('ISTEL').AsString,1,20)+'';
    TabAktarilacak.Params[3].Value := ''+Copy(Tablo.Query1.FieldByName('CEP').AsString,1,20)+'';
    TabAktarilacak.Params[4].Value := ''+Copy(Tablo.Query1.FieldByName('FAX').AsString,1,20)+'';
    TabAktarilacak.Params[5].Value := ''+Copy(Tablo.Query1.FieldByName('EMAIL').AsString,1,50)+'';
    TabAktarilacak.Params[6].Value := ''+Copy(Tablo.Query1.FieldByName('WEB').AsString,1,50)+'';
    TabAktarilacak.Params[7].Value := ''+Copy(Tablo.Query1.FieldByName('ADRES').AsString,1,50)+'';
    TabAktarilacak.Params[8].Value := ''+Copy(Tablo.Query1.FieldByName('ILCE').AsString,1,20)+'';
    TabAktarilacak.Params[9].Value := ''+Copy(Tablo.Query1.FieldByName('IL').AsString,1,25)+'';
    TabAktarilacak.Params[10].Value := ''+Copy(Tablo.Query1.FieldByName('PK').AsString,1,6)+'';
    TabAktarilacak.Params[11].Value := ''+Copy(Tablo.Query1.FieldByName('VERGIDAI').AsString,1,15)+'';
    TabAktarilacak.Params[12].Value := ''+Copy(Tablo.Query1.FieldByName('VERGINO').AsString,1,15)+'';
    TabAktarilacak.Params[13].Value := ''+Copy(Tablo.Query1.FieldByName('NOTLAR').AsString,1,150)+'';
    TabAktarilacak.Params[14].Value := ''+Copy(Tablo.Query1.FieldByName('FATURABASLIK').AsString,1,100)+'';
    TabAktarilacak.Params[15].Value := '1';
    TabAktarilacak.ExecSQL;
    Result:=True;
  Except
    Result:=False;
    ShowMessage(RAktarimHatasi);
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
end;

procedure TReplikasyonDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   ConnectionlariDuzelt(Tablo.FDCnn);
end;

procedure TReplikasyonDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  ReplikasyonDlg.HizliConnection('','');
  Bugun := Tablo.GENINI.BugunTrhSaat;

  Tablo.GridTurkcelestir;

end;

procedure TReplikasyonDlg.FormShow(Sender: TObject);
begin
  HizliConnection(CnnStrGenotip,CnnStrEntegra);
  BtnEntCnnClick(Self);
end;

function TReplikasyonDlg.RehberHareketiVarmi(Kod,GenoCnn,EntegCnn:String ;Sil:boolean): boolean;
var
  i:Integer;
begin
  Try
    HizliConnection(GenoCnn,EntegCnn);
    i:=0;
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=Tablo.FDCnn;
    Tablo.Query1.SQL.Text:='SELECT ID FROM REHBER WHERE KOD = '''+ Kod +'''' ;
    Tablo.Query1.Open;

    Tablo.Query2.Close;
    Tablo.Query2.Connection:=Tablo.FDCnn;
    Tablo.Query2.SQL.Text:=  ' SELECT REHBERID FROM KASA WHERE REHBERID = '+ Tablo.Query1.fields[0].asstring
                            +   ' union all '
                            +' SELECT REHBERID FROM SENETLER WHERE REHBERID = '+ Tablo.Query1.fields[0].asstring
                            +   ' union all '
                            +' SELECT REHBERID FROM CEKLER WHERE REHBERID = '+ Tablo.Query1.fields[0].asstring
                            +   ' union all '
                            +' SELECT REHBERID FROM FATBASLIK WHERE REHBERID = '+ Tablo.Query1.fields[0].asstring;
    Tablo.Query2.Open;
    Tablo.Query3.Close;
    Tablo.Query3.Connection:=Tablo.FDCnn;
    Tablo.Query3.SQL.Text:=  ' SELECT REFERANSKOD as REHBERKOD FROM GELISLER WHERE REFERANSKOD = '''+ Kod +''' union all '
                            +' SELECT FIRMAKODU as REHBERKOD FROM STOKGIRIS WHERE FIRMAKODU = '''+ Kod +'''';
    Tablo.Query2.FetchAll;
    Tablo.Query3.Open;
    Tablo.Query3.FetchAll;
    i:= Tablo.Query2.RecordCount+Tablo.Query3.RecordCount;
    Result := i > 0;
    if Sil=True then Begin
      if Result=False then Begin
        Tablo.Query3.Close;
        Tablo.Query3.Connection:=Tablo.FDCnn;
        Tablo.Query3.SQL.Text:='DELETE FROM REHBER WHERE ID = '+Tablo.Query1.fields[0].asstring ;
        Tablo.Query3.ExecSQL;
        Tablo.Query3.Close;
        Tablo.Query3.SQL.Text:='DELETE FROM REHBERBILGI WHERE YER_ID = '+Tablo.Query1.fields[0].asstring ;
        Tablo.Query3.ExecSQL;
        Tablo.Query4.Close;
        Tablo.Query4.Connection:=Tablo.FDCnn;
        Tablo.Query4.SQL.Text:='DELETE FROM REHBER WHERE KOD = '''+Kod+'''' ;
        Tablo.Query4.ExecSQL;
      End;
    End;
  Except
    ShowMessage(RAktarimHatasi);
  end;
    ConnectionlariDuzelt(Tablo.FDCnn);
end;

procedure TReplikasyonDlg.mnSe1Click(Sender: TObject);
begin
   TabAktarilacak.First;
   while not TabAktarilacak.Eof do begin
     cxGrid1DBTableView1NAME.EditValue:=True;
     TabAktarilacak.Next;
   end;
end;

procedure TReplikasyonDlg.mnTemizle1Click(Sender: TObject);
begin
   TabAktarilacak.First;
   while not TabAktarilacak.Eof do begin
     cxGrid1DBTableView1NAME.EditValue:=False;
     TabAktarilacak.Next;
   end;
end;

procedure TReplikasyonDlg.ConnectionlariDuzelt(cnn:TFDConnection);
Begin
  if Tablo.Query1.Connection<>cnn then begin
    Tablo.Query1.Close;
    Tablo.Query1.Connection:=cnn;
  end;
  if Tablo.Query2.Connection<>cnn then begin
    Tablo.Query2.Close;
    Tablo.Query2.Connection:=cnn;
  end;
  if Tablo.Query3.Connection<>cnn then begin
    Tablo.Query3.Close;
    Tablo.Query3.Connection:=cnn;
  end;
  if Tablo.Query4.Connection<>cnn then begin
    Tablo.Query4.Close;
    Tablo.Query4.Connection:=cnn;
  end;
  if Tablo.Query5.Connection<>cnn then begin
    Tablo.Query5.Close;
    Tablo.Query5.Connection:=cnn;
  end;
  if Tablo.Query6.Connection<>cnn then begin
    Tablo.Query6.Close;
    Tablo.Query6.Connection:=cnn;
  end;
End;

end.












