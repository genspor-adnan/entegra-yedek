unit UBankaSecimi;
{ Bu ekran? 4 ama?la kullanmaktay?z
1. Cagiran 1..20 aras? kullan?l?r
   T?m banka ve onlar?n ?ubelerini g?rmek i?in.
   Kullan?ld??? yerler : ?ek giri?inde, Firma tan?m? ekran?nda o firman?n ?al??t??? bankan?n se?imi yap?ld???nda
   RehberId kullan?lmaz ??nk? t?m liste gelmelidir
   D?nen ?nemli de?erler : SUBEID

2. Cagiran 21..40 aras? kullan?l?r
   Bizim ?al??t???m?z yani hesab?m?z?n oldu?u bankalar?n ve onlar?n ?ubelerini g?rmek i?in.
   Kullan?ld??? yerler : Planlama yaparken hangi hesaptan ?deme yapaca??m?z? se?mek i?in
   RehberId = -1 olmal?d?r. ??nk? sadece bizim firmam?za sahip hesaplar gelmelidir

3. Cagiran 41..60 aras? kullan?l?r
   M??terilerin ?al??t??? bankalar ve onlar?n ?ubelerini g?rmek i?in.
   Kullan?ld??? yerler : Planlama yaparken (havale/EFT i?in) m??terinin hangi hesab?na ?deme yapaca??m?z? se?mek i?in
   RehberId = M??terininId olmal?d?r. ??nk? sadece m??teriye ait hesaplar gelmelidir

4. Merkez bankas?ndan banka ve ?ube listesini g?ncellemek i?in
   Kullan?ld??? yerler : Se?enekler b?l?m?nden girildi?inde g?ncelle tu?u ??kar, se?me tu?u kaybolur
}

interface

uses
  cxImage, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
    dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, cxContainer,
  cxLabel, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, ExtCtrls,
  ComCtrls, ToolWin, XMLIntf, xmldom, msxmldom, XMLDoc, StdCtrls, FireDAC.Comp.Client,
  cxRadioGroup, cxLookAndFeelPainters, cxCheckBox, cxDBEdit,
  cxGroupBox, cxPC, dxSkinLondonLiquidSky, cxLookAndFeels, cxNavigator,
  cxPCdxBarPopupMenu, dxSkinLiquidSky, Vcl.Menus, Vcl.Imaging.jpeg, dxBarBuiltInMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations;

type

{     <record num="1">
          <BKOD>0001</BKOD>
          <SKOD/>
          <NAME>T.C.MERKEZ BANKASI A.?.</NAME>
          <CITY/>
     </record>
}
  PRSSFeedData = ^TRSSFeedData;
  TRSSFeedData = record
    BKOD : string;
    SKOD : string;
    NAME : string;
    CITY : string;
  end;

  TBankaSecimDlg = class(TForm)
    ToolBar1: TToolBar;
    btnKapat: TToolButton;
    Panel1: TPanel;
    Panel2: TPanel;
    cxGridBanka: TcxGrid;
    GridViewBanka: TcxGridDBTableView;
    cxGridLevel3: TcxGridLevel;
    Panel3: TPanel;
    Panel4: TPanel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    GuncelleTus: TToolButton;
    XMLDocument1: TXMLDocument;
    GridViewBankaBANKAKODU: TcxGridDBColumn;
    GridViewBankaBANKAADI: TcxGridDBColumn;
    DtsBankalar: TDataSource;
    TabBankalar: TFDQuery;
    DtsSubeler: TDataSource;
    TabSubeler: TFDQuery;
    cxRadioButton1: TcxRadioButton;
    cxRadioButton2: TcxRadioButton;
    GridViewBankaSEC: TcxGridDBColumn;
    SecTus: TToolButton;
    GridViewBankaColumn1: TcxGridDBColumn;
    GridViewBankaLOGO: TcxGridDBColumn;
    cxPageControl1: TcxPageControl;
    EditAra: TcxTextEdit;
    cxLabel10: TcxLabel;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1BANKAADI: TcxGridDBColumn;
    cxGridDBTableView1BANKAKODU: TcxGridDBColumn;
    cxGridDBTableView1SUBEKODU: TcxGridDBColumn;
    cxGridDBTableView1SUBEADI: TcxGridDBColumn;
    cxGridDBTableView1ILNO: TcxGridDBColumn;
    cxGridDBTableView1ILADI: TcxGridDBColumn;
    cxGridDBTableView1HESAPKODU1: TcxGridDBColumn;
    cxGridDBTableView1HESAPADI: TcxGridDBColumn;
    cxGridDBTableView1HESAPNO1: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    Memo1: TMemo;
    YeniTus: TToolButton;
    cxGridDBTableView1Column1: TcxGridDBColumn;
    cxGridDBTableView1Column2: TcxGridDBColumn;
    PopupSube: TPopupMenu;
    ubeEkle2: TMenuItem;
    PopupBanka: TPopupMenu;
    BankaMenu: TMenuItem;
    N1: TMenuItem;
    BankaSilMenu: TMenuItem;
    procedure btnKapatClick(Sender: TObject);
    procedure GuncelleTusClick(Sender: TObject);
    procedure cxRadioButton2Click(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridViewBankaCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure TabBankalarBeforeEdit(DataSet: TDataSet);
    procedure TabBankalarAfterPost(DataSet: TDataSet);
    procedure YeniTusClick(Sender: TObject);
    procedure cxGridDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridViewBankaCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure ubeEkle2Click(Sender: TObject);
    procedure BankaMenuClick(Sender: TObject);
    procedure BankaSilMenuClick(Sender: TObject);
  private
    { Private declarations }
    procedure XMLDBGuncelle;
  public
    { Public declarations }
    Cagiran : SmallInt;
    RehberId : String;
    Kur:String;
  end;

var
  BankaSecimDlg: TBankaSecimDlg;

implementation

uses UAnaForm,Utablo, Fetautil,FetaClassExtensions,UBekletme,
  FetaKurulusSiniflari, FetaClassExtensionsConsts, UGirisKutusuEx,
  PrjConst,LocOnFly;

{$R *.dfm}
  var aralist : TStringlist;

procedure TBankaSecimDlg.BankaMenuClick(Sender: TObject);
var
  Denetimler:TGirdiDenetimleri;
  MResult:TModalResult;
  BankaKodu,BankaAdi,BankaAdi2:Variant;
  Pic : TJpegImage;
  Donus,KayitKontrol:Boolean;
begin
  Donus := True;
  while Donus do begin
      Denetimler  := TGirdiDenetimleri.Create.Edit(BGBanka_kod,@BankaKodu).Edit(BGBanka_adi,@BankaAdi);
      MResult := TGirisKutusuEx.BilgiAlEx(BGYeni_banka,Denetimler);
      if (MResult = mrOk) then begin
          if (VarToStr(BankaKodu)<>'')and(VarToStr(BankaAdi)<>'') then begin
              Donus := False;
              Tablo.TablodanSorguAc(1,'SELECT BANKAKODU,BANKAADI FROM BANKALAR WHERE BANKAKODU='+VarToStr(BankaKodu));
              if not Tablo.Query1.IsEmpty then begin
                 MResult := Application.MessageBox(PChar(VarToStr(BankaKodu)+BBanka_kodu+Tablo.Query1.FieldByName(BBanka_adi).AsString+BBanka_ismi_degistirilsinmi),PChar(PrjConst.Onay),MB_YESNO+MB_ICONINFORMATION);
                 if MResult = mrYes then
                    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE BANKALAR SET BankaADI=&BankaADI '+
                      ' WHERE BANKAKODU=&BANKAKODU',['&BankaADI','&BANKAKODU'],[BankaAdi,BankaKodu]);
              end else begin
                  Tablo.OpenPictureDialog1.Execute;
                  if Tablo.OpenPictureDialog1.Files.Count>0 then begin
                      Pic := TJpegImage.Create;
                      Pic.LoadFromFile(Tablo.OpenPictureDialog1.Files[0]);
                      Tablo.Query1.Close;
                      Tablo.Query1.SQL.Text := 'INSERT INTO BANKALAR(BANKAKODU,BankaADI,SEC,LOGO) VALUES('+BankaKodu+','''+BankaAdi+''',0,:PRM1)';
                      Tablo.Query1.Params[0].Assign(Pic);
                      Tablo.Query1.ExecSQL;
                  end;
              end
          end
          else
            ShowMessage(BZorunlu_alan_doldur);
      end
      else
        Donus := False;
  end;
  TabloYenile(TabBankalar,[]);
end;

procedure TBankaSecimDlg.BankaSilMenuClick(Sender: TObject);
begin
   Tablo.TablodanSorguAc(1,'select top 1 * from BANKASUBELER where BANKAKODU= ' + TabBankalar.FieldByName('BANKAKODU').AsString);
   if not Tablo.Query1.IsEmpty then
      raise Exception.Create(BSube_var_silinemez)
   else begin
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'delete from BANKALAR where BANKAKODU= ' + TabBankalar.FieldByName('BANKAKODU').AsString,[],[]);
      TabloYenile(TabBankalar,[]);
   end;
end;

procedure TBankaSecimDlg.btnKapatClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TBankaSecimDlg.XMLDBGuncelle;
var
  nd, nd2 : IXMLNode;
  SQLResult :string;
  islem,yuzde,Say:integer;
  procedure ProcessItem();
  var
    rssFeedData : PRSSFeedData;
    rssid, subesayi : integer;
    kur : string;
    I:Integer;
  begin
    New(rssFeedData);
//   if  (ADOQuery2.Locate ('ANAHTAR', nd.ChildNodes.FindNode('Isim').Text,[loPartialKey])) then begin
//   kur:= ADOQuery2.FieldByName('DEGER').AsString;

    with nd.ChildNodes.FindNode('banka').ChildNodes do begin
      rssFeedData.BKOD := FindNode('bKd').Text;
      rssFeedData.NAME := StringReplace(FindNode('bAd').Text, '''', ' ', []) ;
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:= ' IF NOT EXISTS (SELECT BANKAKODU FROM BANKALAR WHERE BANKAKODU ='+rssFeedData.BKOD+' ) BEGIN ' +
                           ' INSERT INTO BANKALAR (BANKAKODU,BANKAADI) '+
                           ' VALUES ('+rssFeedData.BKOD+', '''+Trim(rssFeedData.NAME)+''')  END ELSE '+
                           ' UPDATE BANKALAR SET BANKAADI ='''+Trim(rssFeedData.NAME)+''' where BANKAKODU ='+rssFeedData.BKOD+' ';
      try
         Tablo.Query1.ExecSQL;
      except
         Memo1.Lines.Add(rssFeedData.BKOD+','+Trim(rssFeedData.NAME)+' aktar?lamad?..');
      end;
    end;

    I := 2;
    while nd.ChildNodes.FindSibling(nd, I) <> nil do begin
      nd2 := nd.ChildNodes.FindSibling(nd, I);
      rssFeedData.BKOD := nd2.ChildNodes.FindNode('bKd').Text;
      rssFeedData.SKOD := nd2.ChildNodes.FindNode('sKd').Text;
      rssFeedData.CITY := nd2.ChildNodes.FindNode('sIlKd').Text;
      rssFeedData.NAME := StringReplace(nd2.ChildNodes.FindNode('sAd').Text, '''', ' ', []) ;
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:= ' IF NOT EXISTS (SELECT BANKAKODU, SUBEKODU FROM BANKASUBELER '+
                           ' WHERE BANKAKODU ='+rssFeedData.BKOD+' AND SUBEKODU = '+rssFeedData.SKOD+' ) BEGIN ' +
                           ' INSERT INTO BANKASUBELER (BANKAKODU,SUBEKODU,SUBEADI,ILNO) '+
                           ' VALUES ('+rssFeedData.BKOD+','+rssFeedData.SKOD+','''+Trim(rssFeedData.NAME)+''','+rssFeedData.CITY+') END ELSE '+
                           ' UPDATE BANKASUBELER SET SUBEADI='''+Trim(rssFeedData.NAME)+''',ILNO='+rssFeedData.CITY+' '+
                           ' WHERE BANKAKODU ='+rssFeedData.BKOD+' AND SUBEKODU = '+rssFeedData.SKOD+' ';
      try
         Tablo.Query1.ExecSQL;
      except
         Memo1.Lines.Add(rssFeedData.BKOD+','+rssFeedData.SKOD+','+Trim(rssFeedData.NAME)+','+rssFeedData.CITY+' aktar?lamad?..');
      end;
      Inc(I)
    end;
  end;

begin
  //  SQLResult := 'delete from DOVIZ where TARIH='''+FormatdateTime('yyyy-mm-dd', GenotipIni.BugunTrh)+''' and CINSI IN (select DEGER from GENOTIPINI (nolock) WHERE BOLUM=''DovizEslestir'')';
  //  tablo.CNN.ExecSQL(SQLResult);
  say:=0;
   //Okunacak dosya yolu  //
  Memo1.Visible := True;
  XMLDocument1.FileName := ExtractFileDir( Application.ExeName)+'\XML\banka.xml';
  XMLDocument1.Active := true;
  nd := XMLDocument1.DocumentElement;
  nd := nd.ChildNodes.First;
  islem := XMLDocument1.DocumentElement.ChildNodes.Count;
  Application.CreateForm(TBekletmeDlg,BekletmeDlg);
  BekletmeDlg.cxProgressBar1.Properties.Max :=(islem);
  BekletmeDlg.Caption:='G?ncelleniyor...';
  BekletmeDlg.Show;
  while nd <> nil do begin
    ProcessItem();
    inc(Say,1);
    nd := nd.NextSibling;
    BekletmeDlg.cxProgressBar1.Position:=Say;
    BekletmeDlg.cxProgressBar1.Refresh;
  end;
  BekletmeDlg.Destroy;
  XMLDocument1.Active := false;
  ShowMessage(BAktarim_tamam);
  Memo1.Visible := False;
end;

procedure TBankaSecimDlg.YeniTusClick(Sender: TObject);
var ID:Integer;
    Key : Word;
begin
   if Tablo.YetkiVarmi(2501,YetkiTur_Degistirme) then begin
     ID := Tablo.BankaTanimSihirbazBaslat('E', 1, -1, StrToIntdef(RehberId,0));
     if ID > 0 then
        //EditAraKeyUp(Self, Key, [ssShift]);
        FormShow(self);
   end else
     raise Exception.Create(Yetkisiz_Islem);
end;

procedure TBankaSecimDlg.GridViewBankaCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=cxGridBanka;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridViewBanka;
AnaForm.pmGridStil.Tags.Values[cxGridBanka.Name] := 'BankalarGridi';
end;

procedure TBankaSecimDlg.GridViewBankaCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  K : Word;
begin
  K:=0;
  EditAraKeyUp(Self, K, [ssShift]);
  EditAra.setfocus;
end;

procedure TBankaSecimDlg.cxGridDBTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
AnaForm.cxGridPopupMenu1.Grid:=cxGrid1;
AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=cxGridDBTableView1;
AnaForm.pmGridStil.Tags.Values[cxGrid1.Name] := 'BankaSubelerGridi';
end;

procedure TBankaSecimDlg.cxRadioButton2Click(Sender: TObject);
begin
   TabBankalar.close;
   if Cagiran = 21 then begin  //Bizde hesab? olan ?al??t???m?z bankalar
      TabBankalar.SQL.Text := 'select * from BANKALAR B where B.BANKAKODU in '+
                   ' ( select distinct BS.BANKAKODU from BANKAHESAPLAR BH '+
                   '    inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID '+
                   '    where BH.CEKHESABI=1 AND BH.DURUM=1 AND REHBERID='+RehberId;
     if Kur<>'' then
      TabBankalar.SQL.Add(' and BH.KUR='''+Kur+''' ');
     TabBankalar.SQL.Add(' ) ');
   end else if Cagiran > 20 then begin  //Bizde hesab? olan ?al??t???m?z bankalar
      TabBankalar.SQL.Text := 'select * from BANKALAR B where B.BANKAKODU in '+
                   ' ( select distinct BS.BANKAKODU from BANKAHESAPLAR BH '+
                   '    inner join BANKASUBELER BS on BH.BANKASUBELERID = BS.ID '+
                   '    where REHBERID='+RehberId+' AND BH.DURUM=1  ';
     if Kur<>'' then
      TabBankalar.SQL.Add(' and BH.KUR='''+Kur+''' ');
     TabBankalar.SQL.Add(' ) ');
   end else begin
       TabBankalar.SQL.Text := 'select * from BANKALAR ';
       if (TcxRadioButton(Sender).Name = 'cxRadioButton1')OR(TcxRadioButton(Sender).Name = 'BankaSecimDlg') then
          TabBankalar.SQL.Add(' where SEC = 1 ');
   end;
   TabBankalar.SQL.Add('  order by BANKAADI  ');
   TabBankalar.Open;
end;

procedure TBankaSecimDlg.EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var i : SmallInt;
begin
  if (Key = 13)and(SecTus.visible) then
     SecTus.Click
  else if Key = 38 then
     TabSubeler.Prior
  else if Key = 40 then
     TabSubeler.next
  else begin
     //A??klama i?in sayfa ba??n? okuyun
     aralist := Benzestir(UpStr(EditAra.Text));
     TabSubeler.Close;
     if Cagiran > 20 then begin  //Bizde hesab? olan bizim ?al??t???m?z ve m??terilerin ?al??t??? bankalar
       TabSubeler.SQL.Text :=' SELECT BS.ID as SUBEID, BS.BANKAKODU,BANKAADI,SUBEKODU,SUBEADI,BS.ILNO,ILADI,BH.ID as HESAPID, BH.HESAPKODU,BH.HESAPADI,BH.HESAPNO, BH.KUR'+
                   ' FROM BANKAHESAPLAR BH '+
                   ' inner join BANKASUBELER BS on BS.ID = BH.BANKASUBELERID '+
                   ' inner join BANKALAR B on BS.BANKAKODU = B.BANKAKODU '+
                   ' LEFT OUTER join ILLER I ON BS.ILNO=I.ILNO ';
       TabSubeler.SQL.Add(' where BH.DURUM=1 and REHBERID = '+RehberId);
       if Cagiran in [21..39] then //Bizim hesab?m?z oldu?u i?in hesapad? ile ?a??rabiliriz
          TabSubeler.SQL.Add(' and BH.HESAPADI like ''%'+EditAra.Text+'%'' ');
       if Cagiran = 21 then //Bizim ?ekimiz oldu?u i?in ?ek hesab? olan ?ube listesi gelmeli
          TabSubeler.SQL.Add(' and BH.CEKHESABI=1 ');
       if Cagiran = 22 then //Bizim Hesap Hareketlerini online takip etti?imiz ?ube listesi gelmeli
          TabSubeler.SQL.Add(' and BH.ONLINEHESAPHAREKETI=1 ');
       if GridViewBanka.DataController.GetSelectedCount>0 then //E?er sol taraftan banka se?imi yap?lm??sa
          TabSubeler.SQL.Add(' and BS.BANKAKODU = '+TabBankalar.Fields[0].AsString);
       if Kur<>'' then
          TabSubeler.SQL.Add(' and BH.KUR='''+Kur+''' ');
     end else begin             //cagiran 1..20 aras? sadece  bankalar ve ?ubelerin listesi
       TabSubeler.SQL.Text :='  SELECT B.ID as SUBEID, BANKAKODU,SUBEKODU,SUBEADI,B.ILNO,ILADI, HESAPID=NULL, HESAPKODU=NULL, HESAPADI=NULL, HESAPNO=NULL, KUR=NULL FROM BANKASUBELER B LEFT OUTER JOIN ILLER I ON B.ILNO=I.ILNO WHERE BANKAKODU='+TabBankalar.Fields[0].AsString;
       TabSubeler.SQL.Add(' and (B.SUBEKODU like ''%'+EditAra.Text+'%'' ');
       for i := 0 to aralist.Count - 1 do
          TabSubeler.SQL.Add(' or B.SUBEADI like ''%'+aralist.strings[i]+'%'' ');
       TabSubeler.SQL.Add(') order by SUBEADI ');
     end;
     TabSubeler.Open;
  end;
end;

procedure TBankaSecimDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y?kleniyor.
  Tablo.GridTurkcelestir;
end;

procedure TBankaSecimDlg.FormShow(Sender: TObject);
var Key: Word;
begin
  //GridViewBanka.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\BankalarGridi',true,false,[gsoUseFilter],'');
      Tablo.GridAyarRestore('BankalarGridi',GridViewBanka );

  //cxGridDBTableView1.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\BankaSubelerGridi',true,false,[gsoUseFilter],'');
      Tablo.GridAyarRestore('BankaSubelerGridi',cxGridDBTableView1 );

   cxPageControl1.ActivePageIndex := 0;
   case Cagiran of
     1: begin
        GuncelleTus.Visible := True;
        SecTus.Visible := False;
     end;
     2,3, 4, 20..99: begin
        GuncelleTus.Visible := False;
        SecTus.Visible := True;
     end;
   end;
   if Cagiran > 20 then //Bizim banka hesap listemiz
      EditAraKeyUp(Self, Key, [ssShift])
   else begin
     cxGridDBTableView1BANKAADI.visible := False;
     cxGridDBTableView1HESAPKODU1.visible := False;
     cxGridDBTableView1HESAPADI.visible := False;
     cxGridDBTableView1HESAPNO1.visible := False;
   end;

   YeniTus.visible := Cagiran = 41;

   cxRadioButton2Click(Self);
   EditAra.setfocus;
   aralist := TStringlist.create;
end;

procedure TBankaSecimDlg.GuncelleTusClick(Sender: TObject);
begin
//              http://www.tcmb.gov.tr/kurlar/today.xml
  if not DirectoryExists(ExtractFileDir(Application.ExeName)+'\XML') then
    //CreateDirectory(ExtractFileDir(Application.ExeName)+'\XML');
    CreateDir(ExtractFileDir(Application.ExeName)+'\XML');

//  if Tablo.GetInetFile('http://eft.tcmb.gov.tr/bankasubelistesi/cif.xml',ExtractFileDir(Application.ExeName)+'\XML\banka.xml') then
  if Tablo.GetInetFile('http://eftemkt.tcmb.gov.tr/bankasubelistesi/bankaSubeTumListe.xml',ExtractFileDir(Application.ExeName)+'\XML\banka.xml') then
      XMLDBGuncelle;
end;

procedure TBankaSecimDlg.IptalTusClick(Sender: TObject);
begin
   TabBankalar.cancel;
end;

procedure TBankaSecimDlg.KaydetTusClick(Sender: TObject);
begin
   TabBankalar.Post;
end;

procedure TBankaSecimDlg.SecTusClick(Sender: TObject);
begin
   ModalResult := mrOk;
end;

procedure TBankaSecimDlg.TabBankalarAfterPost(DataSet: TDataSet);
begin
   KaydetTus.visible := False;
   IptalTus.visible := False;
end;

procedure TBankaSecimDlg.TabBankalarBeforeEdit(DataSet: TDataSet);
begin
   KaydetTus.visible := True;
   IptalTus.visible := True;
end;

procedure TBankaSecimDlg.ubeEkle2Click(Sender: TObject);
var
  Denetimler:TGirdiDenetimleri;
  MResult:TModalResult;
  SubeKodu,SubeAdi,SubeAdi2,Il:Variant;
  IlKodu,BankaKodu:string;
  Donus,KayitKontrol:Boolean;
begin
  Il:='?stanbul';
  Donus := True;
  while Donus do begin
    if not TabBankalar.FieldByName('BANKAKODU').IsNullOrEmpty then begin
      Denetimler  := TGirdiDenetimleri.Create.Edit(BGSube_Kod,@SubeKodu).Edit(BGSube_Ad,@SubeAdi).ComboBox('?l *',@Il,Tablo.ComboboxInit('SELECT ILADI FROM ILLER where ILNO<100 ').Items,TComboBoxStyle.csDropDownList);
      MResult := TGirisKutusuEx.BilgiAlEx(BGYeni_sube,Denetimler);
      if MResult = mrOk then begin
        Tablo.TablodanSorguAc(1,'SELECT ILNO FROM ILLER WHERE ILNO<100 and ILADI='''+VarToStr(Il)+'''');
        BankaKodu := TabBankalar.FieldByName('BANKAKODU').AsString;
        if (SubeAdi <> '') and (SubeKodu <> '') and (Il <> '') then begin
          Tablo.TablodanSorguAc(2,'SELECT * FROM BANKASUBELER WHERE BANKAKODU='''+BankaKodu+''' AND SUBEKODU='''+SubeKodu+'''');
          KayitKontrol := not Tablo.Query2.IsEmpty;
          if KayitKontrol then begin
            MResult := Application.MessageBox(PChar(VarToStr(SubeKodu)+BSube_kodu+Tablo.Query2.FieldByName(BSube_adi).AsString+BSube_adi_degistirilsinmi),PChar(PrjConst.Onay),MB_YESNO+MB_ICONINFORMATION);
            if MResult = mrYes then begin
              Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'UPDATE BANKASUBELER SET SUBEADI=&SUBEADI '+
              ' WHERE SUBEKODU=&SUBEKODU AND BANKAKODU=&BANKAKODU',['&SUBEADI','&SUBEKODU','&BANKAKODU'],[SubeAdi,SubeKodu,BankaKodu]);
              Donus := False;
            end else Donus := False;
          end else begin
            Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO BANKASUBELER(SUBEADI,SUBEKODU,BANKAKODU,ILNO) '+
            ' VALUES(&SUBEADI,&SUBEKODU,&BANKAKODU,&ILNO)',['&SUBEADI','&SUBEKODU','&BANKAKODU','&ILNO'],[SubeAdi,SubeKodu,BankaKodu,Tablo.Query1.FieldByName('ILNO').AsString]);
            Donus := False;
          end;
        end
        else begin
          ShowMessage(BZorunlu_alan_doldur);
          Donus := True;
        end;
      end else Donus := False;
    end;
  end;
  TabloYenile(TabSubeler,[]);
end;

end.







