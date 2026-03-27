unit uEvrakAramaFrame;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,UKodAgaci,Utablo,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxPC, cxGraphics, cxCustomData, cxStyles,
  cxTL, cxTLdxBarBuiltInMenu,cxInplaceContainer, cxTLData, cxDBTL, ImgList, DB, UFDCompatHelpers,
  cxImageComboBox, dxSkinscxPCPainter, PngImageList, ToolWin, cxLabel, cxCheckBox,
  cxDropDownEdit, cxCalendar, cxDBEdit, Buttons, dxSkinLiquidSky,
  cxLookAndFeels, cxPCdxBarPopupMenu, dxCore, cxDateUtils, dxBarBuiltInMenu,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxScrollbarAnnotations, System.ImageList, cxFilter, dxCoreGraphics;

type
  TEvrakAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    PageArama: TcxPageControl;
    TabSheetKlasor: TcxTabSheet;
    TreeKlasorler: TcxDBTreeList;
    TabKlasorler: TFDQuery;
    DtsKlasorler: TDataSource;
    KlasorlerColumn1: TcxDBTreeListColumn;
    PNGImageList1: TPngImageList;
    PopupCopKutusuIslemleri: TPopupMenu;
    GeriYukleMenu: TMenuItem;
    N1: TMenuItem;
    KutuyuBosalt: TMenuItem;
    TabSheetArama: TcxTabSheet;
    LabelTumKayitlar: TcxLabel;
    cxLabel1: TcxLabel;
    AraDokuman: TcxTextEdit;
    cxLabel2: TcxLabel;
    dateDokumanBit: TcxDateEdit;
    dateDokumanBas: TcxDateEdit;
    checkTarih: TcxCheckBox;
    AraKurum: TcxButtonEdit;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel6: TcxLabel;
    cxLabel5: TcxLabel;
    AraSorumlu: TcxButtonEdit;
    cxLabel7: TcxLabel;
    AraLokasyon: TcxButtonEdit;
    Label9: TcxLabel;
    AraKategori: TcxImageComboBox;
    AraBolumu: TcxImageComboBox;
    AraModul: TcxImageComboBox;
    AraKonusu: TcxTextEdit;
    YenileTus: TSpeedButton;
    cxLabel8: TcxLabel;
    AraAnahtar: TcxTextEdit;
    YetkilendirmeMenu: TMenuItem;
    checkPasif: TcxCheckBox;
    TumKlasorleriSecMenu: TMenuItem;
    KlasorlerID: TcxDBTreeListColumn;
    KlasorlerAD: TcxDBTreeListColumn;
    N2: TMenuItem;
    YeniKlasrOlusturMenu: TMenuItem;
    KlasrSilMenu: TMenuItem;
    KlasrBilgiiniDzenleMenu: TMenuItem;
    KlasrKesMenu: TMenuItem;
    KlasrYaptrMenu: TMenuItem;
    N3: TMenuItem;
    BtnKlasrleriAcMenu: TMenuItem;
    N4: TMenuItem;
    procedure YeniKlasorTusClick(Sender: TObject);
    procedure KlasorSilTusClick(Sender: TObject);
    procedure KlasorYeniAdTusClick(Sender: TObject);
    procedure TabKlasorlerAfterOpen(DataSet: TDataSet);
    procedure TreeKlasorlerResize(Sender: TObject);
    procedure PopupCopKutusuIslemleriPopup(Sender: TObject);
    procedure KutuyuBosaltClick(Sender: TObject);
    procedure GeriYukleMenuClick(Sender: TObject);
    procedure checkTarihPropertiesEditValueChanged(Sender: TObject);
    procedure AraKurumPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxLabel2Click(Sender: TObject);
    procedure EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AraLokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure AraKurumKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AraYetkiliKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PageAramaChange(Sender: TObject);
    procedure YetkilendirmeMenuClick(Sender: TObject);
    procedure TabKlasorlerBeforeOpen(DataSet: TDataSet);
    procedure AgacTusClick(Sender: TObject);
    procedure TumKlasorleriSecMenuClick(Sender: TObject);
    procedure KlasorKesTusClick(Sender: TObject);
    procedure KlasorYapisTusClick(Sender: TObject);
    procedure TreeKlasorlerSelectionChanged(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TAramaFrameBilgi;
    procedure GorunurOlacak;
    procedure GorunmezOlacak;
    procedure Gorunmez;
    procedure Gorunur;
    function GetKapatilabilir: Boolean;
    procedure TusAsagi(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TusYukari(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TusBasili(Sender: TObject; var Key: Char);
    procedure Baslatildi;
    procedure Kapatiliyor(var AKapansin: Boolean);
    procedure EkranYazdir(Sender: TObject);
    procedure YaziciYazdir(Sender: TObject);
    procedure FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    function GetFrameBilgi : TAramaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAramaFrameBilgi);
    function RecursiveText(Id,UstId :Integer):string;
  public
    { Public declarations  }
    KodAgaciLokasyonDlg : TKodAgaciDlg;
    Procedure InitEvrakKlasorler;
  end;

implementation

{$R *.dfm}

uses {$IFDEF 3Dparty}
  uUtility_my,
  uDebugUtils,
  {$ENDIF 3Dparty}

   UGirisKutusuEx, PrjConst, FetaKurulusSiniflari, UDokumanListeFrame, UDokumanYetki, LocOnFly, uEvrakModule;


var
   DYetkisonuc :DokumanYetkiSonuc;
   Kapali : Boolean;

{ TEvrakAramaFrame }
procedure TEvrakAramaFrame.AgacTusClick(Sender: TObject);
begin
   if Kapali then
      TreeKlasorler.FullExpand
   else
      TreeKlasorler.FullCollapse;
   Kapali := not Kapali;
end;

procedure TEvrakAramaFrame.AraKurumKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TEvrakAramaFrame.AraKurumPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(-1);
  if ID>-2 then begin
    AraKurum.Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    AraKurum.Tag:=ID;
  end else
  begin
    AraKurum.Text:='';
    AraKurum.Tag:=0;
  end;
end;

procedure TEvrakAramaFrame.AraLokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID from LOKASYON where DURUM=1 and TUR='+IntToStr(Lokasyon_Dokuman)+'  and REHBERID=-1' ;
  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[],['TUR'],[IntToStr(Lokasyon_Dokuman)],['Kod','Açýklama',''],[True,True,False]) then begin
    AraLokasyon.Text:=LokAciklama;
    AraLokasyon.Tag:=LokID;
  end else
  begin
    AraLokasyon.Text:='';
    AraLokasyon.Tag:=0;
  end;
end;

procedure TEvrakAramaFrame.AraYetkiliKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TEvrakAramaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  TabKlasorler.Close;
//  TabKlasorler.sql.Text := ' select * from DOKUMANKLASOR ';
//  if TamYetkili = False then
//     TabKlasorler.sql.Add(' where ID<>-1');
//  TabKlasorler.sql.Add(' order by USTID, AD');

  TabKlasorler.ParamCheck;
  TabKlasorler.Open;
  if TabKlasorler.RecordCount=0 then begin
    TabKlasorler.Append;
    TabKlasorler.FieldByName('AD').AsString := 'Belgelerim';
    TabKlasorler.FieldByName('USTID').AsInteger := -1;
    TabKlasorler.Post;
  end;
  {
   "DOKUAMNKLASOR"  Evrak yapýsý için varsayýlan Veriler oluþacak
  }
  InitEvrakKlasorler;

  TreeKlasorler.FullExpand;
  Kapali:=True;


  //yetkili deðilse popupmenü çýkmasýn
  if TamYetkili = False then
     TreeKlasorler.PopupMenu := nil;
end;

procedure TEvrakAramaFrame.checkTarihPropertiesEditValueChanged(Sender: TObject);
begin
  dateDokumanBas.Enabled := checkTarih.Checked;
  dateDokumanBit.Enabled := checkTarih.Checked;
end;

procedure TEvrakAramaFrame.cxLabel2Click(Sender: TObject);
begin
  Tablo.LabelClickCombobox(Sender);
end;

procedure TEvrakAramaFrame.EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  ID: Integer;
begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID>0 then begin
    AraSorumlu.Text:=Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
    AraSorumlu.Tag:=ID;
  end else
  begin
    AraSorumlu.Text:='';
    AraSorumlu.Tag:=0;
  end;
end;

procedure TEvrakAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TEvrakAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TEvrakAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TEvrakAramaFrame.GeriYukleMenuClick(Sender: TObject);
var ust:integer;
begin
  {if TabKlasorler.FieldByName('ID').AsInteger=-1 then begin
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update DOKUMANKLASOR set USTID=ESKIUSTID where USTID=-1',[],[]);
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update DOKUMAN set KLASOR=ESKIKLASOR where KLASOR=-1',[],[]);
  end else if TabKlasorler.FieldByName('USTID').AsInteger=-1 then begin
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update DOKUMANKLASOR set USTID=ESKIUSTID where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
  end;}
  //önce bakalým altýna alacaðýmýz üst klasör hala var mý
  if TabKlasorler.FieldByName('ESKIUSTID').AsInteger<>0 then begin
     Tablo.TablodanSorguAc(1, 'select AD from DOKUMANKLASOR where DURUM<>0 and ID='+TabKlasorler.FieldByName('ESKIUSTID').AsString);
     if Tablo.Query1.RecordCount > 0 then begin
        Ust := TabKlasorler.FieldByName('ESKIUSTID').AsInteger;
        showmessage(Tablo.Query1.Fields[0].asstring+' klasörünün altýna geri yüklendi..');
     end else
        Ust:=0;
  end
  else
     Ust:=0;

  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                ' update DOKUMAN set DURUM=1 where KLASOR in(SELECT ID FROM REACH) ',[],[]); //Dökümanlar
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
             ' update DOKUMANKLASOR set DURUM=1 where ID in(SELECT ID FROM REACH) ',[],[]);
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'update DOKUMANKLASOR set USTID='+IntToStr(Ust)+' where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
  TabloYenile(TabKlasorler,[]);
end;

function TEvrakAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TEvrakAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TEvrakAramaFrame.Gorunmez;
begin

end;

procedure TEvrakAramaFrame.GorunmezOlacak;
begin

end;

procedure TEvrakAramaFrame.Gorunur;
begin

end;

procedure TEvrakAramaFrame.GorunurOlacak;
begin

end;

{
 Evrak Klasörleri oluþturacaktýr,
 ID     USTID   TUR   RESIM     AD              ...                 DURUM
-1001	-1000	1	7	Gelen Evrak                         1
-1101	-1001	2	5	Bütün Evraklar                      1
-1102	-1001	3	1	Üzerinde çalýþtýklarým              1
-1103	-1001	4	12	Teslim almadýklarým                 1
-1104	-1001	5	11	Havale ettiklerim                   1
-1105	-1001	6	19	Dosyaya kaldýrdýklarým              1
-1106	-1001	7	0	Ýptal ettiklerim                    1
-2001	-2000	8	8	Giden Evrak                         1
-2101	-2001	9	20	Bütün Evraklar                      1
-2102	-2001	10	1	Üzerinde çalýþtýklarým              1
-2103	-2001	11	3	Ýmzada Bekleyenler                  1
-2104	-2001	12	18	Havale Ettiklerim                   1
-2105	-2001	13	19	Dosyaya kaldýrdýklarým              1
-2106	-2001	14	13	Ýptal ettiklerim                    1
}
type
   recEvrakKlasor = record
     ID : integer;
     USTID : integer;
     TUR : integer;
     RESIM : integer;
     AD : String;
   end;

const
   constEvrakKlasor : array [1..15] of recEvrakKlasor=(
    (ID:-1001; USTID:-1000; TUR:1;  RESIM:7; AD:'Gelen Evrak'),
    (ID:-1101; USTID:-1001; TUR:2;  RESIM:5; AD:'Bütün Evraklar'),
    (ID:-1102; USTID:-1001; TUR:3;  RESIM:1; AD:'Üzerinde çalýþtýklarým'),
    (ID:-1103; USTID:-1001; TUR:4;  RESIM:12;AD:'Teslim almadýklarým'),
    (ID:-1104; USTID:-1001; TUR:5;  RESIM:11;AD:'Havale ettiklerim'),
    (ID:-1105; USTID:-1001; TUR:6;  RESIM:19;AD:'Dosyaya kaldýrdýklarým'),
    (ID:-1106; USTID:-1001; TUR:7;  RESIM:0; AD:'Ýptal ettiklerim'),

    (ID:-2001; USTID:-2000; TUR:8;  RESIM:8; AD:'Giden Evrak'),
    (ID:-2101; USTID:-2001; TUR:9;  RESIM:20;AD:'Bütün Evraklar'),
    (ID:-2102; USTID:-2001; TUR:10; RESIM:1; AD:'Üzerinde çalýþtýklarým'),
    (ID:-2103; USTID:-2001; TUR:11; RESIM:1; AD:'Gönderilen Ýþler'),
    (ID:-2104; USTID:-2001; TUR:12; RESIM:2; AD:'Ýmzada Bekleyenler'),
    (ID:-2105; USTID:-2001; TUR:13; RESIM:3; AD:'Havale Ettiklerim'),
    (ID:-2106; USTID:-2001; TUR:14; RESIM:4; AD:'DosyDosyaya kaldýrdýklarým'),
    (ID:-2107; USTID:-2001; TUR:15; RESIM:5; AD:'Ýptal ettiklerim ')
   );

procedure TEvrakAramaFrame.InitEvrakKlasorler;
var
  i : integer;
  newID : integer;
  insertSQL : string;
begin
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'SET IDENTITY_INSERT '+'DOKUMANKLASOR'+' ON',[],[]);
    try
      for i := 1 to High(constEvrakKlasor) do
       begin
         newID := constEvrakKlasor[i].ID;
         insertSQL :=
           'IF NOT EXISTS(SELECT ID FROM DOKUMANKLASOR WHERE ID='+newID.ToString+' AND USTID='+constEvrakKlasor[i].USTID.ToString+' ) '+
           ' BEGIN INSERT INTO DOKUMANKLASOR(ID,USTID,TUR,RESIM,AD,DURUM) '+
              'VALUES('+newID.ToString+','+constEvrakKlasor[i].USTID.ToString+','+constEvrakKlasor[i].TUR.ToString+','+
                       constEvrakKlasor[i].RESIM.ToString+','+QuotedStr(constEvrakKlasor[i].AD)+',1) '+
             'END;';

         // UNUTMA {$IFDEF 3Dparty} _LogEkle(UnitName+' InitEvrakKlasorler', i.ToString+' '+constEvrakKlasor[i].ID.ToString+' '+constEvrakKlasor[i].AD+sLineBreak+insertSql); {$endif}
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, insertSQL, [],[]);
       end;
    finally
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'SET IDENTITY_INSERT '+'DOKUMANKLASOR'+' OFF',[],[]);
    end;

end;

procedure TEvrakAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TEvrakAramaFrame.KlasorKesTusClick(Sender: TObject);
begin
   {
   if TabKlasorler.FieldByName('ID').AsInteger < 0 then begin
      showmessage(DOKGeriDonusumIslem);
      exit;
   end;
   KlasorYapisTus.Tag := TabKlasorler.FieldByName('ID').AsInteger;
   KlasorYapisTus.Enabled:=True;
   LabelYapis.Visible:=True;
   }
end;

function TEvrakAramaFrame.RecursiveText(Id,UstId :Integer):string;
begin
   Result := ' WITH REACH(ID,USTID,AD)AS( '+
             ' SELECT ID,USTID,AD '+
             ' FROM DOKUMANKLASOR '+
             ' WHERE ID='+IntToStr(Id)+' and USTID= '+IntToStr(UstId)+
             ' UNION ALL '+
             ' SELECT DK.ID,DK.USTID,DK.AD '+
             ' FROM REACH R inner join DOKUMANKLASOR DK on R.ID=DK.USTID ) ';
end;

procedure TEvrakAramaFrame.KlasorSilTusClick(Sender: TObject);
var
  SilmeSorusu,SilmeParametre : string;
begin
   if TabKlasorler.FieldByName('ID').AsInteger < 0 then begin
      showmessage(DOKGeriDonusumIslem);
      exit;
   end;

   DYetkisonuc:=Tablo.DokumanYetkiKontrol(322,TabKlasorler.FieldByName('ID').AsInteger);
   if DYetkisonuc.Sil = False  then begin
      showmessage(Yetkisiz_Islem);
      exit;
   end;

   SilmeParametre := '';
   Tablo.TablodanSorguAc(2,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                ' select ID from REACH '); //klasörler
   Tablo.TablodanSorguAc(3,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                ' select ID from DOKUMAN where KLASOR in(SELECT ID FROM REACH) '); //Dökümanlar
//      Tablo.TablodanSorguAc(4,RecursiveText+' select ID from IMAJ where YERI=1 and YER_ID in (select ID from DOKUMAN where KLASOR in(SELECT ID FROM REACH)) '); //belgeler
   if Tablo.Query2.RecordCount>0 then
         SilmeParametre := ' '+IntToStr(Tablo.Query2.RecordCount)+' '+DYKlasoru;
   if Tablo.Query3.RecordCount>0 then
         SilmeParametre := SilmeParametre + ' ' + IntToStr(Tablo.Query3.RecordCount)+' '+DYDokumani;
//      if Tablo.Query4.RecordCount>0 then
//         SilmeParametre := SilmeParametre + ' ' + IntToStr(Tablo.Query4.RecordCount)+DYBelgeyi;
   SilmeSorusu := StringReplace(DYIcerikSilmeSorusu,'&Parametre&',SilmeParametre,[rfReplaceAll]);
   if (SilmeParametre = '')or(Application.MessageBox(PChar(SilmeSorusu), PChar(SGenotipOnay), MB_YESNO) <> IDYES) then
       exit;

   if TabKlasorler.FieldByName('USTID').AsInteger=-1 then begin//çöp kutusu boþaltýlýr
      while not Tablo.Query3.eof do begin
             Tablo.DokumanSil(True, Tablo.Query3.Fields[0].AsInteger, 1,-1);
             Tablo.Query3.Next;
      end;
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                          ' DELETE from DOKUMANKLASOR where ID in(SELECT ID FROM REACH) ',[],[]);
//        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,RecursiveText+' select ID from DOKUMAN where KLASOR in(SELECT ID FROM REACH) ',[],[]);
//        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,RecursiveText+' select ID from IMAJ where YERI=1 and YER_ID in (select ID from DOKUMAN where KLASOR in(SELECT ID FROM REACH)) ',[],[]);
      TabloYenile(TabKlasorler,[]);
    end else begin //çöp kutusuna atýlýr
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                ' update DOKUMAN set DURUM=0 where KLASOR in(SELECT ID FROM REACH) ',[],[]); //Dökümanlar
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
             ' update DOKUMANKLASOR set DURUM=0 where ID in(SELECT ID FROM REACH) ',[],[]);
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update DOKUMANKLASOR set ESKIUSTID=USTID,  USTID=-1 where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
         TabloYenile(TabKlasorler,[]);
    end
end;

procedure TEvrakAramaFrame.KlasorYapisTusClick(Sender: TObject);
var i : integer;
begin
   {
   if Sender.ClassName='TcxLabel' then
      i:=0
   else
      i:=TabKlasorler.FieldByName('ID').AsInteger;
   Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update DOKUMANKLASOR set USTID='+inttostr(i)+' where ID='+IntToStr(KlasorYapisTus.tag),[],[]);
   KlasorYapisTus.Enabled := False;
   LabelYapis.Visible:= False;
   TabloYenile(TabKlasorler,[]);
   }
end;

procedure TEvrakAramaFrame.KlasorYeniAdTusClick(Sender: TObject);
var
  Bilgi,Resim : Variant;
  ctrls : TGirdiDenetimleri;
begin
   if TabKlasorler.FieldByName('ID').AsInteger < 0 then begin
      showmessage(DOKGeriDonusumIslem);
      exit;
   end;

  DYetkisonuc:=Tablo.DokumanYetkiKontrol(322,TabKlasorler.FieldByName('ID').AsInteger);
  if DYetkisonuc.Degistir = True  then begin
    Bilgi := TabKlasorler.FieldByName('AD').AsString;
    Resim := TabKlasorler.FieldByName('RESIM').AsInteger;
    ctrls := TGirdiDenetimleri.Create.Edit(TKlasorAdiniGirin, @Bilgi).ImageComboBox(TKlasorResiminiSeciniz,@Resim,Tablo.FDCnn,'SELECT top 15 A=ROW_NUMBER()OVER(ORDER BY ID)-1,B=''''  FROM BANKASUBELER order by ID',True,Tablo.KlasorResimleri);
    if (TGirisKutusuEx.BilgiAlEx('', ctrls) = mrOk)and(trim(Bilgi) <> '') then
        Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'update DOKUMANKLASOR set AD='''+trim(string(Bilgi))+''', RESIM='+IntToStr(Integer(Resim))+' where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
    TabloYenile(TabKlasorler,[]);
    //TabKlasorler.Locate('ID', TabKlasorler.Fields[0].AsInteger,[]);
  end else ShowMessage(Yetkisiz_Islem);
end;

procedure TEvrakAramaFrame.KutuyuBosaltClick(Sender: TObject);
begin
{  if TabKlasorler.FieldByName('ID').AsInteger = -1 then
     KlasorSilTusClick(Self)
  else
    //  if Application.MessageBox(' Klasörünü boþalt', PChar(SGenotipOnay),MB_YESNO) = IDYES then
  if MessageDlg(TabKlasorler.FieldByName('AD').AsString +' Klasörünü boþalt',mtInformation,[MByes,Mbno],0) = mrYes then Begin
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' update DOKUMAN set ESKIKLASOR=KLASOR , KLASOR=-1 where ID=(select top 1 DOKUMAN.ID from DOKUMANKLASOR  where DOKUMANKLASOR.ID = dokuman.klasor and DOKUMANKLASOR.ID=&DokID)',['&DokID'], [TabKlasorler.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,' update DOKUMANKISAYOL set ESKIKLASOR=KLASOR , KLASOR=-1 where KLASOR=(select top 1 DOKUMANKLASOR.ID from DOKUMANKLASOR where DOKUMANKLASOR.ID = DOKUMANKISAYOL.KLASOR and DOKUMANKLASOR.ID=&DokID )', ['&DokID'], [TabKlasorler.FieldByName('ID').AsInteger]);
     TabloYenile(TabKlasorler,[]);
  end;  }
end;


procedure TEvrakAramaFrame.PageAramaChange(Sender: TObject);
begin
//  if TabKlasorler.RecordCount > 1 then
//    TcxDBTreeList(Sender).FocusedColumn.ItemIndex:=1;
//    TreeKlasorler.Items[1].Index;
end;

procedure TEvrakAramaFrame.PopupCopKutusuIslemleriPopup(Sender: TObject);
begin
//   GeriYukle.Visible := (TabKlasorler.FieldByName('ID').AsInteger <> -1);//and(TabKlasorler.FieldByName('USTID').AsInteger = -1);
//   GeriYukle.Visible := TabKlasorler.FieldByName('USTID').AsInteger = -1;
//   GeriYukleMenu.Visible := TabKlasorler.FieldByName('DURUM').AsInteger = 0;
   //KutuyuBosalt.Visible := TabKlasorler.FieldByName('ID').AsInteger = -1;
//   YetkilendirmeMenu.Visible:=false;

//  if TabKlasorler.FieldByName('ID').AsInteger <> -1  then begin
    //KutuyuBosalt.Visible:= True;
    //KutuyuBosalt.Caption := (TabKlasorler.FieldByName('AD').AsString + ' Klasörünü Boþalt');
     //yonetici degil ise yetkilebdirme menüsünü göremesin
//    if TamYetkili then
//       YetkilendirmeMenu.Visible:=True;
//  end;

end;

procedure TEvrakAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TEvrakAramaFrame.TabKlasorlerAfterOpen(DataSet: TDataSet);
begin
{  TabKlasorler.DisableControls;
  (Tablo.repDokumanKlasor.Properties as TcxImageComboBoxProperties).Items.Clear;
  while not TabKlasorler.Eof do begin
    with (Tablo.repDokumanKlasor.Properties as TcxImageComboBoxProperties).Items.Add do begin
      Description := TabKlasorler.FieldByName('AD').AsString;
      Value := TabKlasorler.FieldByName('ID').AsInteger;
      ImageIndex := TabKlasorler.FieldByName('RESIM').AsInteger;
    end;
    TabKlasorler.Next;
  end;
  TabKlasorler.EnableControls;  }
end;

procedure TEvrakAramaFrame.TabKlasorlerBeforeOpen(DataSet: TDataSet);
begin
  if not TamYetkili then begin
    TabKlasorler.SQL.Clear;
    TabKlasorler.SQL.Text:='select DK.* from DOKUMANKLASOR DK INNER JOIN DOKUMANYETKI DY ON DK.ID=DY.YERID'+
                     ' WHERE  GOR=1  AND (DY.REHBERID = '+Kullanan+' OR DY.REHBERID=0) ';
    if TamYetkili then
       TabKlasorler.SQL.Add(' union '+
                     ' select  DK.*   from DOKUMANKLASOR  DK where ID = -1 ');
    TabKlasorler.SQL.Add(' order by RESIM desc') ;
    {
    ToolBar2.Enabled:=False;
    }
  end;
end;

procedure TEvrakAramaFrame.TreeKlasorlerResize(Sender: TObject);
begin
  KlasorlerColumn1.Width := TreeKlasorler.Width-10;
end;

procedure TEvrakAramaFrame.TreeKlasorlerSelectionChanged(Sender: TObject);
begin
{
   GeriAlTus.Visible := TabKlasorler.FieldByName('DURUM').AsInteger = 0;
   YeniKlasorTus.Visible := not GeriAlTus.Visible;
   KlasorSilTus.Visible := (not GeriAlTus.Visible)and(TabKlasorler.FieldByName('ID').AsInteger > 0);
   KlasorYeniAdTus.Visible := KlasorSilTus.Visible;
   KlasorKesTus.Visible := KlasorSilTus.Visible;
   KlasorYapisTus.Visible := not GeriAlTus.Visible;

   GeriYukleMenu.Visible := GeriAlTus.Visible;
   YetkilendirmeMenu.Visible := not GeriAlTus.Visible;
   YeniKlasrOlusturMenu.Visible := YeniKlasorTus.Visible;
   KlasrSilMenu.Visible := KlasorSilTus.Visible;
   KlasrBilgiiniDzenleMenu.Visible := KlasorYeniAdTus.Visible;
   KlasrKesMenu.Visible := KlasorKesTus.Visible;
   KlasrYaptrMenu.Visible := KlasorYapisTus.Visible; }
   //BtnKlasrleriAcMenu.Visible :=
end;

procedure TEvrakAramaFrame.TumKlasorleriSecMenuClick(Sender: TObject);
begin
   {TreeKlasorler.FullExpand;
   TreeKlasorler.SelectAll; }
end;

procedure TEvrakAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TEvrakAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TEvrakAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TEvrakAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TEvrakAramaFrame.YeniKlasorTusClick(Sender: TObject);
var
  Bilgi,Resim : Variant;
  ctrls : TGirdiDenetimleri;
  UstId,YERID : Integer;
  LocateID : integer;
begin
  Bilgi := '';
  Resim := 0;
  ctrls := TGirdiDenetimleri.Create.Edit(TKlasorAdiniGirin, @Bilgi).ImageComboBox(TKlasorResiminiSeciniz,@Resim,Tablo.FDCnn,'SELECT top 15 ROW_NUMBER() OVER(ORDER BY ID)-1,'''' FROM BANKASUBELER order by ID',True,Tablo.KlasorResimleri);
  if (TGirisKutusuEx.BilgiAlEx('', ctrls) = mrOk)and(trim(Bilgi) <> '') then begin
    if TToolButton(Sender).Tag = 0 then
       UstId := TabKlasorler.FieldByName('USTID').AsInteger
    else
       UstId := TabKlasorler.FieldByName('ID').AsInteger;
    Tablo.TablodanSorguAc(4, 'insert into DOKUMANKLASOR (AD,RESIM,USTID,SUBEID,DURUM)values('''+trim(string(Bilgi))+''','+IntToStr(Integer(Resim))+','+IntToStr(UstId)+','+IntToStr(SubeID)+',1) SELECT SCOPE_IDENTITY() AS InsertedRowId ');
    Tablo.Query4.open;
    LocateID := Tablo.Query4.Fields[0].AsInteger;
    Tablo.TablodanSorguAc(8,'SELECT top 1 * FROM dokumanklasor order by ID desc');
    Tablo.Query8.Open;
    if ustId = 0 then begin
      Tablo.Query5.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR) '+
                              ' VALUES(0,322,'+inttostr(Tablo.Query8.FieldByName('ID').AsInteger)+',1,0,0,0,5)';
      Tablo.Query5.ExecSQL;
      Tablo.Query5.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR) '+
                              ' VALUES('+Kullanan+',322,'+inttostr(Tablo.Query8.FieldByName('ID').AsInteger)+',1,1,1,1,1)';
      Tablo.Query5.ExecSQL;
    end else begin
      Tablo.Query5.SQL.Text:='INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR) '+
                ' SELECT REHBERID,322,'+inttostr(Tablo.Query8.FieldByName('ID').AsInteger)+
                ',GOR,EKLE,SIL,DEGISTIR,5  FROM DOKUMANYETKI '+
                ' WHERE YERI = 322 AND YERID = '+TabKlasorler.FieldByName('USTID').AsString;                                // DOKUMAN.FieldByName('KLASOR').AsString;
                Tablo.Query5.ExecSQL;
    end;
    TabloYenile(TabKlasorler,[],LocateID);

  //    YenileKlasorClick(Tablo.Query4.Fields[0].AsInteger);
  end;
end;

procedure TEvrakAramaFrame.YetkilendirmeMenuClick(Sender: TObject);
var I : smallint;
    s : string;
begin
  Application.CreateForm(TDokumanYetki,DokumanYetki);
  if TreeKlasorler.SelectionCount=1 then
     DokumanYetki.DokumanYetkiID:=TabKlasorler.FieldByName('ID').AsInteger
  else
     DokumanYetki.DokumanYetkiID:=0; //birden fazla seçim varsa klasör ID sýfýr alýrýz
  dokumanyetki.DokumanYetkiTur:=322;
  DokumanYetki.Caption:= DokumanYetki.Caption+' ('+TabKlasorler.FieldByName('AD').AsString+')';
  DokumanYetki.CheckAltKlasor.checked := True;
  DokumanYetki.ShowModal;
  //Eðer çoklu seçim varsa, yapýlan yetkilendirmeyi tüm klasörlere uygularýz
  if (DokumanYetki.ModalResult= mrOK)and(DokumanYetki.CheckAltKlasor.checked) then begin
      s:='';
      for I := 0 to TreeKlasorler.SelectionCount-1 do begin
          if I>0 then
             s:=s+',';
          s := s + IntToStr(TreeKlasorler.Selections[i].Values[KlasorlerID.ItemIndex]);
      end;
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text:='WITH REACH(ID,USTID,AD)AS(SELECT ID,USTID,AD FROM DOKUMANKLASOR WHERE ';
      if TreeKlasorler.SelectionCount>1 then Tablo.Query1.SQL.Add('ID in ('+s+') or ');
      Tablo.Query1.SQL.Add(' USTID in ('+s+') '+
                           ' UNION ALL ' +
                           ' SELECT DK.ID,DK.USTID,DK.AD FROM REACH R inner join DOKUMANKLASOR DK on R.ID=DK.USTID )'+
                           ' select distinct ID,USTID,AD from REACH');
      Tablo.Query1.open;
      if TreeKlasorler.SelectionCount>1 then
         s:=' AND EKLEYEN='+Kullanan //birden fazla seçim varsa þimdi ekleneneri alalým
      else
         s:='';
      while not Tablo.Query1.Eof do begin
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from DOKUMANYETKI where YERI=322 and YERID = &KlasorID',['&KlasorID'],[Tablo.Query1.Fields[0].asstring]);
         Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR,EKLEYEN) '+
                ' SELECT REHBERID,322,&KlasorID'+
                ',GOR,EKLE,SIL,DEGISTIR,5,'+Kullanan+'  FROM DOKUMANYETKI '+
                ' WHERE YERI = 322 AND YERID = '+IntToStr(DokumanYetki.DokumanYetkiID)+s,['&KlasorID'],[Tablo.Query1.Fields[0].asstring]);
         Tablo.Query1.next;
      end;
      //YETKÝLENDÝRME YAPILDI GEÇÝCÝ ORTAK YETKÝLERÝ SÝLELÝM
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from DOKUMANYETKI where YERI=322 and YERID=0 and EKLEYEN=&Ekleyen',['&Ekleyen'],[Kullanan]);
  end;
end;

initialization
  RegisterClass(TEvrakAramaFrame);
end.





