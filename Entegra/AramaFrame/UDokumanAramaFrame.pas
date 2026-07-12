unit UDokumanAramaFrame;

{ Bu kod Sablon Duzenleyici tarafindan uretildi }
{ Tarih : 05/01/2010 09:41:54}
interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UGentegreFrameYonetimi, Menus,UKodAgaci,Utablo,
  cxLookAndFeelPainters, cxButtons, dxSkinsCore, UFrameYoneticisi,
  dxSkinLondonLiquidSky, cxPC, cxGraphics, cxCustomData, cxStyles,
  cxTL, cxTLdxBarBuiltInMenu,cxInplaceContainer, cxTLData, cxDBTL, ImgList, DB, FireDAC.Comp.Client,
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
  dxSkinVisualStudio2013Light, dxScrollbarAnnotations, System.ImageList,
  cxFilter, dxCoreGraphics, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TDokumanAramaFrame = class(TFrame, IAramaBilgiFrame, IBilgiFrame)
    PageArama: TcxPageControl;
    TabSheetKlasor: TcxTabSheet;
    TreeKlasorler: TcxDBTreeList;
    TabKlasorler: TFDQuery;
    DtsKlasorler: TDataSource;
    KlasorlerColumn1: TcxDBTreeListColumn;
    ToolBar2: TToolBar;
    YeniKlasorTus: TToolButton;
    KlasorSilTus: TToolButton;
    ToolButton3: TToolButton;
    KlasorYeniAdTus: TToolButton;
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
    ToolButton1: TToolButton;
    AgacTus: TToolButton;
    TumKlasorleriSecMenu: TMenuItem;
    KlasorlerID: TcxDBTreeListColumn;
    ToolButton2: TToolButton;
    KlasorKesTus: TToolButton;
    KlasorYapisTus: TToolButton;
    ToolButton4: TToolButton;
    KlasorlerAD: TcxDBTreeListColumn;
    LabelYapis: TcxLabel;
    N2: TMenuItem;
    YeniKlasrOlusturMenu: TMenuItem;
    KlasrSilMenu: TMenuItem;
    KlasrBilgiiniDzenleMenu: TMenuItem;
    KlasrKesMenu: TMenuItem;
    KlasrYaptrMenu: TMenuItem;
    N3: TMenuItem;
    BtnKlasrleriAcMenu: TMenuItem;
    N4: TMenuItem;
    GeriAlTus: TToolButton;
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
    KodAgaciLokasyonDlg:TKodAgaciDlg;
  end;

implementation

{$R *.dfm}

uses UGirisKutusuEx, PrjConst, FetaKurulusSiniflari, UDokumanListeFrame, UDokumanYetki,LocOnFly, UVeriMotor;
{ TDokumanAramaFrame }

var
   DYetkisonuc :DokumanYetkiSonuc;
   Kapali : Boolean;

procedure TDokumanAramaFrame.AgacTusClick(Sender: TObject);
begin
   if Kapali then
      TreeKlasorler.FullExpand
   else
      TreeKlasorler.FullCollapse;
   Kapali := not Kapali;
end;

procedure TDokumanAramaFrame.AraKurumKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TDokumanAramaFrame.AraKurumPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TDokumanAramaFrame.AraLokasyonPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID from LOKASYON where DURUM=1 and TUR='+IntToStr(Lokasyon_Dokuman)+'  and REHBERID=-1' ;
  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[],['TUR'],[IntToStr(Lokasyon_Dokuman)],['Kod','A��klama',''],[True,True,False]) then begin
    AraLokasyon.Text:=LokAciklama;
    AraLokasyon.Tag:=LokID;
  end else
  begin
    AraLokasyon.Text:='';
    AraLokasyon.Tag:=0;
  end;
end;

procedure TDokumanAramaFrame.AraYetkiliKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key in [ VK_DELETE,VK_BACK] then begin
    TcxButtonEdit(Sender).Tag := 0;
    TcxButtonEdit(Sender).Text := '';
  end ;
end;

procedure TDokumanAramaFrame.Baslatildi;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil y�kleniyor.
  TabKlasorler.Close;
//  TabKlasorler.sql.Text := ' select * from DOKUMANKLASOR ';
//  if TamYetkili = False then
//     TabKlasorler.sql.Add(' where ID<>-1');
//  TabKlasorler.sql.Add(' order by USTID, AD');
  TabKlasorler.Open;
  if TabKlasorler.IsEmpty then begin
    TabKlasorler.Append;
    TabKlasorler.FieldByName('AD').AsString := 'Belgelerim';
    TabKlasorler.FieldByName('USTID').AsInteger := -1;
    TabKlasorler.Post;
  end;
  TreeKlasorler.FullCollapse;
  Kapali:=True;


  //yetkili de�ilse popupmen� ��kmas�n
  if TamYetkili = False then
     TreeKlasorler.PopupMenu := nil;
end;

procedure TDokumanAramaFrame.checkTarihPropertiesEditValueChanged(Sender: TObject);
begin
  dateDokumanBas.Enabled := checkTarih.Checked;
  dateDokumanBit.Enabled := checkTarih.Checked;
end;

procedure TDokumanAramaFrame.cxLabel2Click(Sender: TObject);
begin
  Tablo.LabelClickCombobox(Sender);
end;

procedure TDokumanAramaFrame.EditSorumluPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TDokumanAramaFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TDokumanAramaFrame.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumanAramaFrame.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TDokumanAramaFrame.GeriYukleMenuClick(Sender: TObject);
var ust:integer;
begin
  {if TabKlasorler.FieldByName('ID').AsInteger=-1 then begin
     Veritabani.BasitKomut�al��t�r(Tablo.FDCnn,'update DOKUMANKLASOR set USTID=ESKIUSTID where USTID=-1',[],[]);
     Veritabani.BasitKomut�al��t�r(Tablo.FDCnn,'update DOKUMAN set KLASOR=ESKIKLASOR where KLASOR=-1',[],[]);
  end else if TabKlasorler.FieldByName('USTID').AsInteger=-1 then begin
     Veritabani.BasitKomut�al��t�r(Tablo.FDCnn,'update DOKUMANKLASOR set USTID=ESKIUSTID where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
  end;}
  //�nce bakal�m alt�na alaca��m�z �st klas�r hala var m�
  if TabKlasorler.FieldByName('ESKIUSTID').AsInteger<>0 then begin
     Tablo.TablodanSorguAc(1, 'select AD from DOKUMANKLASOR where DURUM<>0 and ID='+TabKlasorler.FieldByName('ESKIUSTID').AsString);
     if not Tablo.Query1.IsEmpty then begin
        Ust := TabKlasorler.FieldByName('ESKIUSTID').AsInteger;
        showmessage(Tablo.Query1.Fields[0].asstring+' klas�r�n�n alt�na geri y�klendi..');
     end else
        Ust:=0;
  end
  else
     Ust:=0;

  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                ' update DOKUMAN set DURUM=1 where KLASOR in(SELECT ID FROM REACH) ',[],[]); //D�k�manlar
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
             ' update DOKUMANKLASOR set DURUM=1 where ID in(SELECT ID FROM REACH) ',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update DOKUMANKLASOR set USTID='+IntToStr(Ust)+' where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
  TabloYenile(TabKlasorler,[]);
end;

function TDokumanAramaFrame.GetFrameBilgi: TAramaFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TDokumanAramaFrame.GetKapatilabilir: Boolean;
begin

end;

procedure TDokumanAramaFrame.Gorunmez;
begin

end;

procedure TDokumanAramaFrame.GorunmezOlacak;
begin

end;

procedure TDokumanAramaFrame.Gorunur;
begin

end;

procedure TDokumanAramaFrame.GorunurOlacak;
begin

end;

procedure TDokumanAramaFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TDokumanAramaFrame.KlasorKesTusClick(Sender: TObject);
begin
   if TabKlasorler.FieldByName('ID').AsInteger < 0 then begin
      showmessage(DOKGeriDonusumIslem);
      exit;
   end;
   KlasorYapisTus.Tag := TabKlasorler.FieldByName('ID').AsInteger;
   KlasorYapisTus.Enabled:=True;
   LabelYapis.Visible:=True;
end;

function TDokumanAramaFrame.RecursiveText(Id,UstId :Integer):string;
begin
   Result := ' WITH REACH(ID,USTID,AD)AS( '+
             ' SELECT ID,USTID,AD '+
             ' FROM DOKUMANKLASOR '+
             ' WHERE ID='+IntToStr(Id)+' and USTID= '+IntToStr(UstId)+
             ' UNION ALL '+
             ' SELECT DK.ID,DK.USTID,DK.AD '+
             ' FROM REACH R inner join DOKUMANKLASOR DK on R.ID=DK.USTID ) ';
end;

procedure TDokumanAramaFrame.KlasorSilTusClick(Sender: TObject);
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
                                ' select ID from REACH '); //klas�rler
   Tablo.TablodanSorguAc(3,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                ' select ID from DOKUMAN where KLASOR in(SELECT ID FROM REACH) '); //D�k�manlar
   Tablo.Query2.FetchAll;
   Tablo.Query3.FetchAll;
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

   if TabKlasorler.FieldByName('USTID').AsInteger=-1 then begin//��p kutusu bo�alt�l�r
      while not Tablo.Query3.eof do begin
             Tablo.DokumanSil(True, Tablo.Query3.Fields[0].AsInteger, 1,-1);
             Tablo.Query3.Next;
      end;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                          ' DELETE from DOKUMANKLASOR where ID in(SELECT ID FROM REACH) ',[],[]);
//        Veritabani.BasitKomut�al��t�r(Tablo.FDCnn,RecursiveText+' select ID from DOKUMAN where KLASOR in(SELECT ID FROM REACH) ',[],[]);
//        Veritabani.BasitKomut�al��t�r(Tablo.FDCnn,RecursiveText+' select ID from IMAJ where YERI=1 and YER_ID in (select ID from DOKUMAN where KLASOR in(SELECT ID FROM REACH)) ',[],[]);
      TabloYenile(TabKlasorler,[]);
    end else begin //��p kutusuna at�l�r
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
                                ' update DOKUMAN set DURUM=0 where KLASOR in(SELECT ID FROM REACH) ',[],[]); //D�k�manlar
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,RecursiveText(TabKlasorler.FieldByName('ID').AsInteger, TabKlasorler.FieldByName('USTID').AsInteger)+
             ' update DOKUMANKLASOR set DURUM=0 where ID in(SELECT ID FROM REACH) ',[],[]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKLASOR set ESKIUSTID=USTID,  USTID=-1 where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
         TabloYenile(TabKlasorler,[]);
    end
end;

procedure TDokumanAramaFrame.KlasorYapisTusClick(Sender: TObject);
var i : integer;
begin
   if Sender.ClassName='TcxLabel' then
      i:=0
   else
      i:=TabKlasorler.FieldByName('ID').AsInteger;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKLASOR set USTID='+inttostr(i)+' where ID='+IntToStr(KlasorYapisTus.tag),[],[]);
   KlasorYapisTus.Enabled := False;
   LabelYapis.Visible:= False;
   TabloYenile(TabKlasorler,[]);
end;

procedure TDokumanAramaFrame.KlasorYeniAdTusClick(Sender: TObject);
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
    ctrls := TGirdiDenetimleri.Create.Edit(TKlasorAdiniGirin, @Bilgi).ImageComboBox(TKlasorResiminiSeciniz,@Resim,Tablo.FDCnn,'SELECT '+DbUst(15)+'A=ROW_NUMBER()OVER(ORDER BY ID)-1,B=''''  FROM BANKASUBELER order by ID '+DbSinir(15),True,Tablo.KlasorResimleri);
    if (TGirisKutusuEx.BilgiAlEx('', ctrls) = mrOk)and(trim(Bilgi) <> '') then
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update DOKUMANKLASOR set AD='''+trim(string(Bilgi))+''', RESIM='+IntToStr(Integer(Resim))+' where ID='+TabKlasorler.FieldByName('ID').AsString,[],[]);
    TabloYenile(TabKlasorler,[]);
    //TabKlasorler.Locate('ID', TabKlasorler.Fields[0].AsInteger,[]);
  end else ShowMessage(Yetkisiz_Islem);
end;

procedure TDokumanAramaFrame.KutuyuBosaltClick(Sender: TObject);
begin
{  if TabKlasorler.FieldByName('ID').AsInteger = -1 then
     KlasorSilTusClick(Self)
  else
    //  if Application.MessageBox(' Klas�r�n� bo�alt', PChar(SGenotipOnay),MB_YESNO) = IDYES then
  if MessageDlg(TabKlasorler.FieldByName('AD').AsString +' Klas�r�n� bo�alt',mtInformation,[MByes,Mbno],0) = mrYes then Begin
     Veritabani.BasitKomut�al��t�r(Tablo.FDCnn,' update DOKUMAN set ESKIKLASOR=KLASOR , KLASOR=-1 where ID=(select top 1 DOKUMAN.ID from DOKUMANKLASOR  where DOKUMANKLASOR.ID = dokuman.klasor and DOKUMANKLASOR.ID=&DokID)',['&DokID'], [TabKlasorler.FieldByName('ID').AsInteger]);
     Veritabani.BasitKomut�al��t�r(Tablo.FDCnn,' update DOKUMANKISAYOL set ESKIKLASOR=KLASOR , KLASOR=-1 where KLASOR=(select top 1 DOKUMANKLASOR.ID from DOKUMANKLASOR where DOKUMANKLASOR.ID = DOKUMANKISAYOL.KLASOR and DOKUMANKLASOR.ID=&DokID )', ['&DokID'], [TabKlasorler.FieldByName('ID').AsInteger]);
     TabloYenile(TabKlasorler,[]);
  end;  }
end;


procedure TDokumanAramaFrame.PageAramaChange(Sender: TObject);
begin
//  if TabKlasorler.RecordCount > 1 then
//    TcxDBTreeList(Sender).FocusedColumn.ItemIndex:=1;
//    TreeKlasorler.Items[1].Index;
end;

procedure TDokumanAramaFrame.PopupCopKutusuIslemleriPopup(Sender: TObject);
begin
//   GeriYukle.Visible := (TabKlasorler.FieldByName('ID').AsInteger <> -1);//and(TabKlasorler.FieldByName('USTID').AsInteger = -1);
//   GeriYukle.Visible := TabKlasorler.FieldByName('USTID').AsInteger = -1;
//   GeriYukleMenu.Visible := TabKlasorler.FieldByName('DURUM').AsInteger = 0;
   //KutuyuBosalt.Visible := TabKlasorler.FieldByName('ID').AsInteger = -1;
//   YetkilendirmeMenu.Visible:=false;

//  if TabKlasorler.FieldByName('ID').AsInteger <> -1  then begin
    //KutuyuBosalt.Visible:= True;
    //KutuyuBosalt.Caption := (TabKlasorler.FieldByName('AD').AsString + ' Klas�r�n� Bo�alt');
     //yonetici degil ise yetkilebdirme men�s�n� g�remesin
//    if TamYetkili then
//       YetkilendirmeMenu.Visible:=True;
//  end;

end;

procedure TDokumanAramaFrame.SetFrameBilgi(AValue: TAramaFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TDokumanAramaFrame.TabKlasorlerAfterOpen(DataSet: TDataSet);
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

procedure TDokumanAramaFrame.TabKlasorlerBeforeOpen(DataSet: TDataSet);
begin
  if not TamYetkili then begin
    TabKlasorler.SQL.Clear;
    TabKlasorler.SQL.Text:='select distinct DK.*, isnull(DK.USTID,-1) as USTID_PARENT, isnull(DK.RESIM,0) as RESIM_INDEX from DOKUMANKLASOR DK INNER JOIN DOKUMANYETKI DY ON DK.ID=DY.YERID  and YERI=322 '+
                     ' WHERE  GOR=1  AND DY.REHBERID in ('+Kullanan+', 0) ';
    if TamYetkili then
       TabKlasorler.SQL.Add(' union '+
                     ' select  DK.*, isnull(DK.USTID,-1) as USTID_PARENT, isnull(DK.RESIM,0) as RESIM_INDEX   from DOKUMANKLASOR  DK where ID = -1 ');
    TabKlasorler.SQL.Add(' order by RESIM desc') ;
    ToolBar2.Enabled:=False;
  end;
end;

procedure TDokumanAramaFrame.TreeKlasorlerResize(Sender: TObject);
begin
  KlasorlerColumn1.Width := TreeKlasorler.Width-10;
end;

procedure TDokumanAramaFrame.TreeKlasorlerSelectionChanged(Sender: TObject);
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

procedure TDokumanAramaFrame.TumKlasorleriSecMenuClick(Sender: TObject);
begin
   {TreeKlasorler.FullExpand;
   TreeKlasorler.SelectAll; }
end;

procedure TDokumanAramaFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumanAramaFrame.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TDokumanAramaFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TDokumanAramaFrame.YaziciYazdir(Sender: TObject);
begin

end;

procedure TDokumanAramaFrame.YeniKlasorTusClick(Sender: TObject);
var
  Bilgi,Resim : Variant;
  ctrls : TGirdiDenetimleri;
  UstId,YERID : Integer;
  LocateID : integer;
begin
  Bilgi := '';
  Resim := 0;
  ctrls := TGirdiDenetimleri.Create.Edit(TKlasorAdiniGirin, @Bilgi).ImageComboBox(TKlasorResiminiSeciniz,@Resim,Tablo.FDCnn,'SELECT '+DbUst(15)+'ROW_NUMBER() OVER(ORDER BY ID)-1,'''' FROM BANKASUBELER order by ID '+DbSinir(15),True,Tablo.KlasorResimleri);
  if (TGirisKutusuEx.BilgiAlEx('', ctrls) = mrOk)and(trim(Bilgi) <> '') then begin
    if TToolButton(Sender).Tag = 0 then
       UstId := TabKlasorler.FieldByName('USTID').AsInteger
    else
       UstId := TabKlasorler.FieldByName('ID').AsInteger;
    Tablo.TablodanSorguAc(4, 'insert into DOKUMANKLASOR (AD,RESIM,USTID,SUBEID,DURUM)values('''+trim(string(Bilgi))+''','+IntToStr(Integer(Resim))+','+IntToStr(UstId)+','+IntToStr(SubeID)+',1) SELECT SCOPE_IDENTITY() AS InsertedRowId ');
    Tablo.Query4.open;
    LocateID := Tablo.Query4.Fields[0].AsInteger;
    Tablo.TablodanSorguAc(8,'SELECT '+DbUst(1)+'* FROM dokumanklasor order by ID desc '+DbSinir(1));
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

procedure TDokumanAramaFrame.YetkilendirmeMenuClick(Sender: TObject);
var I : smallint;
    s : string;
begin
  Application.CreateForm(TDokumanYetki,DokumanYetki);
  if TreeKlasorler.SelectionCount=1 then
     DokumanYetki.DokumanYetkiID:=TabKlasorler.FieldByName('ID').AsInteger
  else
     DokumanYetki.DokumanYetkiID:=0; //birden fazla se�im varsa klas�r ID s�f�r al�r�z
  dokumanyetki.DokumanYetkiTur:=322;
  DokumanYetki.Caption:= DokumanYetki.Caption+' ('+TabKlasorler.FieldByName('AD').AsString+')';
  DokumanYetki.CheckAltKlasor.checked := True;
  DokumanYetki.ShowModal;
  //E�er �oklu se�im varsa, yap�lan yetkilendirmeyi t�m klas�rlere uygular�z
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
         s:=' AND EKLEYEN='+Kullanan //birden fazla se�im varsa �imdi ekleneneri alal�m
      else
         s:='';
      while not Tablo.Query1.Eof do begin
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMANYETKI where YERI=322 and YERID = &KlasorID',['&KlasorID'],[Tablo.Query1.Fields[0].asstring]);
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'INSERT INTO DOKUMANYETKI(REHBERID,YERI,YERID,GOR,EKLE,SIL,DEGISTIR,TUR,EKLEYEN) '+
                ' SELECT REHBERID,322,&KlasorID'+
                ',GOR,EKLE,SIL,DEGISTIR,5,'+Kullanan+'  FROM DOKUMANYETKI '+
                ' WHERE YERI = 322 AND YERID = '+IntToStr(DokumanYetki.DokumanYetkiID)+s,['&KlasorID'],[Tablo.Query1.Fields[0].asstring]);
         Tablo.Query1.next;
      end;
      //YETK�LEND�RME YAPILDI GE��C� ORTAK YETK�LER� S�LEL�M
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMANYETKI where YERI=322 and YERID=0 and EKLEYEN=&Ekleyen',['&Ekleyen'],[Kullanan]);
  end;
end;

initialization
  RegisterClass(TDokumanAramaFrame);
end.








