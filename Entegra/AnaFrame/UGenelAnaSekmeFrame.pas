unit UGenelAnaSekmeFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UGentegreFrameYonetimi, StdCtrls, JvExControls, JvButton, JvNavigationPane,
  ExtCtrls, JvPageList,  cxControls, cxPC, JvExExtCtrls, ECXMLParser,
  JvExtComponent, JvPanel, dxSkinsCore, dxSkinscxPCPainter, Menus, cxLookAndFeelPainters,
  cxButtons, cxContainer, cxEdit, cxGroupBox, cxPropertiesStore, FetaKurulusSiniflari,
  UFrameYoneticisi, ComCtrls, ToolWin,DBCtrls, FetaClassExtensionsConsts, ImgList, dxSkinLondonLiquidSky, cxSplitter,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters,dxSkinValentine, dxSkinXmas2008Blue, cxGraphics, cxLookAndFeels,
  cxPCdxBarPopupMenu, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxBarBuiltInMenu, cxClasses, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, System.ImageList;

type
  TGenelAnaSekmeFrame = class(TFrame, IAnaBilgiFrame, IBilgiFrame)
    pnl2: TPanel;
    pnlGorev: TPanel;
    JvPanel1: TJvPanel;
    cxGroupBox1: TcxGroupBox;
    ScrollBox2: TScrollBox;
    pcArama: TcxPageControl;
    cxPropertiesStore1: TcxPropertiesStore;
    pcIcerik: TcxPageControl;
    pmMevcutDokumler: TPopupMenu;
    pmDokumAyarlar: TPopupMenu;
    mnuSayfaAyarlar: TMenuItem;
    mnuVarsayilanYap: TMenuItem;
    mnuKopyala: TMenuItem;
    mnuAdDegistir: TMenuItem;
    mnuSil: TMenuItem;
    mnuDokumKaydet: TMenuItem;
    mnuDokumAl: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    N3: TMenuItem;
    mnuYeniRapor: TMenuItem;
    ImageList1: TImageList;
    mnuSQLAyarlar: TMenuItem;
    mnuListeyiYenile: TMenuItem;
    cxSplitter1: TcxSplitter;
    cxSplitter2: TcxSplitter;
    XML: TECXMLParser;
    procedure pnlBaslikPaint(Sender: TObject);
    procedure pnlYazdirmaPaint(Sender: TObject);
    procedure EkranYazClick(Sender: TObject);
    procedure YaziciYazClick(Sender: TObject);
    procedure mnuSayfaAyarlarClick(Sender: TObject);
    procedure mnuVarsayilanYapClick(Sender: TObject);
    procedure mnuKopyalaClick(Sender: TObject);
    procedure pmDokumAyarlarPopup(Sender: TObject);
    procedure mnuAdDegistirClick(Sender: TObject);
    procedure mnuSilClick(Sender: TObject);
    procedure mnuDokumKaydetClick(Sender: TObject);
    procedure mnuDokumAlClick(Sender: TObject);
    procedure mnuYeniRaporClick(Sender: TObject);
    procedure mnuSQLAyarlarClick(Sender: TObject);
    procedure mnuListeyiYenileClick(Sender: TObject);
  private
    { Private declarations }
    //FFrameBilgi : TAnaFrameBilgi;
    { IAnaBilgiFrame üyeleri            }
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

    function GetFrameBilgi : TAnaFrameBilgi;
    procedure SetFrameBilgi(AValue : TAnaFrameBilgi);
    {********************************}
    procedure RehberErisimTamamlandi(Sender: TObject);
    procedure MesajAlicisi(AMesaj: Variant);
    procedure IcerikFrameAktifOlacak(Sender: TIcerikFrameBilgi);

    procedure YazdirmaBilgileriniYenile(YaziciYaz : TToolbutton;PopupMenuYaz : TPopupMenu); //(Sender: TIcerikFrameBilgi);

  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;
    destructor Destroy; override;
    procedure RaporSecClick(Sender: TObject);
    procedure JVRaporSecClick(Sender: TObject);

  published
  end;

  function DokumIDGetir(raporAdi, Grubu : string) : Integer;

implementation

uses FetaClassExtensions, JvJVCLUtils, UFastRap, URaporAraclari, UDokum,
  UGirisKutusuEx, Utablo, UDokumSart ,LocOnFly,PrjConst;

const
  AdimMiktari = 8;
  AcilmisHali = 34;
  KapanmisHali = 10;

{$R *.dfm}

{ TCariFrame }

procedure TGenelAnaSekmeFrame.Baslatildi;
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

type
  TDBNavigatorAccesor = class(TDBNavigator);

constructor TGenelAnaSekmeFrame.Create(AOwner: TComponent);
begin
  inherited;
//  pnlYazdirma.Height := AcilmisHali;
//  TDBNavigatorAccesor(GenelNavigator).Color := clWhite;
end;

destructor TGenelAnaSekmeFrame.Destroy;
begin

  inherited;
end;

procedure TGenelAnaSekmeFrame.YazdirmaBilgileriniYenile(YaziciYaz : TToolbutton;PopupMenuYaz : TPopupMenu);
var
  ra: string;

//  if Sender.YazdirmaDestegi then
  begin

  TRaporAraclari.RaporPopupMenuHazirla('MakbuzWizardDlg', PopupMenuYaz, ra, RaporSecClick); // TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).
  YaziciYaz.Caption := ra;


//    if Sender.Etiketler.AsBoolean['DökümEkraný'] then
//    begin
//      EkranYaz.Caption := 'Liste';
//      YaziciYaz.Caption := 'Liste';
//      EkranYaz.Kind := cxbkStandard;
//      YaziciYaz.Kind := cxbkStandard;
//    end
//    else
//    begin
//      TRaporAraclari.RaporPopupMenuHazirla(Sender.AracCubuguDestegi.EkranAdiAl, pmMevcutDokumler, s, RaporSecClick);
//      if s <> '' then
//      begin
//        if Sender.AktifRaporAdi = '' then
//          Sender.AktifRaporAdi := s;
//        EkranYaz.Kind := cxbkDropDownButton;
//        YaziciYaz.Kind := cxbkDropDownButton;
//      end
//      else
//      begin
//        Sender.AktifRaporAdi := 'Rapor';
//        EkranYaz.Kind := cxbkStandard;
//        YaziciYaz.Kind := cxbkStandard;
//      end;
//      EkranYaz.Caption := Sender.AktifRaporAdi;
//      YaziciYaz.Caption := Sender.AktifRaporAdi;
//    end;
//  end;
end;

procedure TGenelAnaSekmeFrame.EkranYazClick(Sender: TObject);
var
  ekranAdi : string;
begin
  {FastRaporDlg.frxReport1.DataSets.Clear;
  with FFrameBilgi.IcerikFrameYoneticisi.AktifFrame do begin
    AracCubuguDestegi.YazdirmayaHazirla(FastRaporDlg.frxReport1);
    BilgiFrameIntf.EkranYazdir(FastRaporDlg);
    if Etiketler.AsBoolean['DökümEkraný'] then
      ekranAdi := TDokumDlg(Ornek).TabDokum.AsString['RAPORADI']
    else  // ekranAdi := TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption;
      ekranAdi := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;
    Delete(ekranAdi, pos('&',ekranAdi), 1);
    FastRaporDlg.FastRapor(1,FFrameBilgi.AktifIcerik.
    AracCubuguDestegi.EkranAdiAl,ekranAdi);
  end;  }
end;

procedure TGenelAnaSekmeFrame.EkranYazdir(Sender: TObject);
begin

end;

procedure TGenelAnaSekmeFrame.FareTekerlekAsagi(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TGenelAnaSekmeFrame.FareTekerlekYukari(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

function TGenelAnaSekmeFrame.GetFrameBilgi: TAnaFrameBilgi;
begin
//  Result := FFrameBilgi;
end;


function TGenelAnaSekmeFrame.GetKapatilabilir: Boolean;
begin

end;


procedure TGenelAnaSekmeFrame.Gorunmez;
begin

end;

procedure TGenelAnaSekmeFrame.GorunmezOlacak;
begin

end;

procedure TGenelAnaSekmeFrame.Gorunur;
begin

end;

procedure TGenelAnaSekmeFrame.GorunurOlacak;
begin

end;

procedure TGenelAnaSekmeFrame.IcerikFrameAktifOlacak(Sender: TIcerikFrameBilgi);
begin
//  YazdirmaBilgileriniYenile(Sender);
end;

procedure TGenelAnaSekmeFrame.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TGenelAnaSekmeFrame.MesajAlicisi(AMesaj: Variant);
begin
  
end;
procedure TGenelAnaSekmeFrame.mnuAdDegistirClick(Sender: TObject);
var
  yeniad, Ekranadi: string;
  dokumAdi : Variant;
  kaynakDokum : string;
  dokumEkran : TDokumDlg;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   if Ekranadi = 'DokumDlg' then begin
      dokumEkran := TDokumDlg(Dlg);
      kaynakDokum := dokumEkran.TabDokum.AsString['RAPORADI'];
   end
   else
    kaynakDokum := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption; // TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption;
  Delete(kaynakDokum, pos('&',kaynakDokum), 1);
  dokumAdi:= kaynakDokum;
  if TGirisKutusuEx.BilgiAlEx(BGDokum_Rapor_Ad_Degistir, TGirdiDenetimleri.Create.Edit(BGYeni_ad,@dokumAdi)) = mrOk then begin
    if Trim(dokumAdi) = '' then begin
      MessageDlg('Döküm/Rapor adý boþ olamaz!',mtError,[mbOK],0);
      Exit;
    end;

    if length(dokumAdi)>14 then begin
        showmessage(max14karakter);
        exit
    end;

    if Ekranadi = 'DokumDlg' then begin  // Assigned(dokumEkran)
      { DökümDlg açýk }
      dokumEkran.TabDokum.Edit;
      dokumEkran.TabDokum.AsString['RAPORADI'] := dokumAdi;
      dokumEkran.TabDokum.Post;
    end else begin
      { Normal Rapor }
      TRaporAraclari.RaporAdDegistir(EkranAdi, kaynakDokum,dokumAdi);
      TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption := dokumAdi;//   TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption := dokumAdi;
    end;
  end;
end;

function DokumIDGetir(raporAdi, Grubu : string) : Integer;
begin
   Delete(raporAdi, pos('&',raporAdi), 1);
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'SELECT D.ID FROM DOKUMLER D WHERE D.RAPORADI = '''+RaporAdi+''' and D.GRUBU = '''+Grubu+''' ';
   Tablo.Query1.Open;
   Result := Tablo.Query1.Fields[0].AsInteger;
end;


procedure TGenelAnaSekmeFrame.mnuSayfaAyarlarClick(Sender: TObject);
var
  raporAdi, ekranadi,Ver : string;
  RaporId : Integer;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   pd.YazdirmayaHazirla(FastRaporDlg.frxReport1);
   if Ekranadi = 'DokumDlg' then begin
      raporAdi := TDokumDlg(Dlg).TabDokum.AsString['RAPORADI'];
      RaporId := TDokumDlg(Dlg).TabDokum.AsInteger['ID'];
      Ver := TDokumDlg(Dlg).TabDokum.AsString['VERSIYON'];
   end else begin
      RaporAdi := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;
      Delete(raporAdi, pos('&',raporAdi), 1);
      Tablo.TablodanSorguAc(1, 'SELECT D.ID, VERSIYON FROM DOKUMLER D WHERE D.RAPORADI = '''+RaporAdi+''' and D.GRUBU = '''+Ekranadi+''' ');
      RaporId := Tablo.Query1.Fields[0].AsInteger;
      Ver := Tablo.Query1.Fields[0].AsString;
   end;
   FastRaporDlg.FastRaporDesign(Ekranadi,raporAdi,Ver, RaporId);  // FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl
end;


procedure TGenelAnaSekmeFrame.mnuDokumAlClick(Sender: TObject);
var
  dokumAdi    : Variant;
  kaynakDokum, Ekranadi: string;
  i, iVer : SmallInt;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
  c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
  Dlg := c.Owner;
  Dlg.GetInterface(IPopupDialog,pd);
  Ekranadi := pd.EkranAdiAl;
  if dlgOpen.Execute then begin
    kaynakDokum := ExtractFileName(dlgOpen.FileName);
    //kaynakDokum := TDokumDlg(FFrameBilgi.AktifIcerik.Ornek).TabDokum.AsString['RAPORADI'];
    i := Pos('#',  kaynakDokum);
    if i > 0 then
      kaynakDokum := Copy(kaynakDokum, 1, i-2)
    else begin
      i := Pos('.FR',  UpperCase(kaynakDokum));
      if i > 0 then
        kaynakDokum := Copy(kaynakDokum, 1, i-1);
    end;
    FastRaporDlg.XMLOku(kaynakDokum, dlgOpen.FileName);//(EkranAdi1, RaporAdi1, DosyaAdi : String)
    if Ekranadi = 'DokumDlg' then
      TDokumDlg(Dlg).EkranDegisveKonumlan(0)
      //TDokumDlg(Dlg).TabDokumAfterDelete(TDokumDlg(Dlg).TabDokum)
    else begin
      c := (TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Owner;
      TPopupMenu(c.FindComponent('PopupMenuYaz')).Items.ItemOperation(moAdd, kaynakDokum, RaporSecClick);
    end;
  end;
end;

procedure TGenelAnaSekmeFrame.mnuDokumKaydetClick(Sender: TObject);
var
  dokumAdi    : Variant;
  kaynakDokum, Ekranadi, Ver : string;
  RaporId: Integer;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   if Ekranadi = 'DokumDlg' then begin
     kaynakDokum := TDokumDlg(Dlg).TabDokum.AsString['RAPORADI'];
     Ver := TDokumDlg(Dlg).TabDokum.AsString['VERSIYON'];
     dlgSave.FileName := kaynakDokum + '.frd'; //döküm ayarlarý
     dlgSave.Filter := '.frd';
     RaporId := TDokumDlg(Dlg).TabDokum.AsInteger['ID'];
   end else begin                                                                  //sayfayý kaydetme
     kaynakDokum := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;  // kaynakDokum := TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption;
     Ver := '';
     Delete(kaynakDokum, pos('&',kaynakDokum), 1);
     dlgSave.Filter := '.frs';
     dlgSave.FileName := kaynakDokum+'.frs';//sayfa ayarlarý
     RaporId := DokumIDGetir(kaynakDokum, EkranAdi);
   end;

  if dlgSave.Execute then begin
     Ver := StringReplace(Ver, '.', '-',[]);
     Ver := StringReplace(dlgSave.FileName, '.FR', ' #'+Ver+'.FR',[rfIgnoreCase]);
     FastRaporDlg.FastReportTextKaydet(Ver, RaporId); //  FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl, kaynakDokum
  end;
end;

procedure TGenelAnaSekmeFrame.mnuKopyalaClick(Sender: TObject);
var
  yeniad, Ekranadi : string;
  dokumAdi : Variant;
  kaynakDokum : string;
  dokumEkran : TDokumDlg;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   if Ekranadi = 'DokumDlg' then begin
      dokumEkran := TDokumDlg(Dlg);
      kaynakDokum := dokumEkran.TabDokum.AsString['RAPORADI'];
  end
  else
      kaynakDokum := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;  //  kaynakDokum := TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption;
  Delete(kaynakDokum, pos('&',kaynakDokum), 1);
  dokumAdi := kaynakDokum + '1';
  if TGirisKutusuEx.BilgiAlEx(BGDokum_Rapor_Kopyala,
    TGirdiDenetimleri.Create.Edit(BGYeni_ad,@dokumAdi)) = mrOk then begin
    if Trim(dokumAdi) = '' then begin
      MessageDlg('Döküm/Rapor adý boþ olamaz!',mtError,[mbOK],0);
      Exit;
    end;
    if Ekranadi = 'DokumDlg' then begin  // Assigned(dokumEkran)
      { DökümDlg açýk }
      TRaporAraclari.RaporKopyala(dokumEkran.TabDokum.AsInteger['ID'], dokumAdi);    // kaynakDokum,dokumAdi, dokumEkran.TabDokum
      TDokumDlg(Dlg).EkranDegisveKonumlan(0)
    end else begin
      { Normal Rapor }
      TRaporAraclari.RaporKopyala(DokumIDGetir(kaynakDokum,EkranAdi),dokumAdi);// FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl,    dokumAdi
      c := (TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Owner;
      TPopupMenu(c.FindComponent('PopupMenuYaz')).Items.ItemOperation(moAdd, dokumAdi, RaporSecClick);
    end;
  end;
end;

procedure TGenelAnaSekmeFrame.mnuListeyiYenileClick(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
    pd : IPopupDialog;
    c, Dlg : TComponent;
    Ekranadi : String[50];
    PopupMenuYaz : TPopupMenu;
begin
   //TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz,ra,
   //TGenelAnaSekmeFrame(FFrameBilgi.AnaFrameBilgi.Ornek).RaporSecClick);
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   PopupMenuYaz := ((TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Owner).FindComponent('PopupMenuYaz') as TPopupMenu;

   aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
   //eski yazdýrma menülerini silelim
   while PopupMenuYaz.Items.Count > 5 do
         PopupMenuYaz.Items.Delete(PopupMenuYaz.Items.Count-1);
   //yenileri ekleyelim
   TRaporAraclari.RaporPopupMenuHazirla(EkranAdi, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
end;

procedure TGenelAnaSekmeFrame.mnuSilClick(Sender: TObject);
var PM : TPopupMenu;
  pd : IPopupDialog;
  c, Dlg : TComponent;
  Ekranadi : String[50];
begin
  if MessageDlg('Geçerli dökümü silmek istiyor musunuz?',
     mtConfirmation,[mbYes,mbNo],0) = mrNo then Exit;
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   if Ekranadi = 'DokumDlg' then begin
      TDokumDlg(Dlg).TabDokum.Delete;
   end else begin
      TRaporAraclari.RaporSil(DokumIDGetir(TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption,EkranAdi));// TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption
      PM := ((TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Owner).FindComponent('PopupMenuYaz') as TPopupMenu;
      if PM.Items.Count>5 then begin
         TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption := PM.Items[5].Caption;  // TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption := PM.Items[5].Caption;
         PM.Items.Delete(5);
      end
      else
         TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption :='';
   end;
end;

procedure TGenelAnaSekmeFrame.mnuSQLAyarlarClick(Sender: TObject);
var
  raporAdi, ekranadi : string;
  RaporId : Integer;
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   //pd.YazdirmayaHazirla(FastRaporDlg.frxReport1);
   Application.CreateForm(TDokumSartDlg, DokumSartDlg);
   if (Ekranadi = 'DokumDlg') or (ekranadi='HizliGirisDokumDlg') then begin
      //raporAdi := TDokumDlg(Dlg).TabDokum.AsString['RAPORADI'];
      //RaporId := TDokumDlg(Dlg).TabDokum.AsInteger['ID'];
      DokumSartDlg.DtsKosul.DataSet := TDokumDlg(Dlg).TabKosul;
      DokumSartDlg.DtsDokumler.DataSet := TDokumDlg(Dlg).TabDokum;
      DokumSartDlg.ShowModal;
      DokumSartDlg.Destroy;
      TDokumDlg(Dlg).SartlarOlustur(
        TDokumDlg(Dlg).ScrollBox2,TDokumDlg(Dlg).GBox1,
        TDokumDlg(Dlg).Panel1,TDokumDlg(Dlg).TabKosul,
        TDokumDlg(Dlg).ButonClick,
        TDokumDlg(Dlg).ComBoxInitPopup
      );
   end else begin
      RaporAdi := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;
      Delete(raporAdi, pos('&',raporAdi), 1);
      RaporId := DokumIDGetir(RaporAdi, Ekranadi);
      if (not Tablo.TabDokum.Active)or
         (RaporId <> Tablo.TabDokum.Fields[0].AsInteger)  then
         Tablo.DokumTablosuAc(RaporId);
      DokumSartDlg.DtsKosul.DataSet := Tablo.TabKosul;
      DokumSartDlg.DtsDokumler.DataSet := Tablo.TabDokum;
      DokumSartDlg.ShowModal;
      DokumSartDlg.Destroy;
   end;
//   FastRaporDlg.FastRaporDesign(Ekranadi,raporAdi, RaporId);  // FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl
end;

procedure TGenelAnaSekmeFrame.mnuVarsayilanYapClick(Sender: TObject);
var  Ekranadi : String[40];
  pd : IPopupDialog;
  c, Dlg : TComponent;
begin
   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   if Ekranadi <> 'DokumDlg' then
      TRaporAraclari.RaporVarsayilanYap(Ekranadi,  TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption)
//    TRaporAraclari.RaporVarsayilanYap( //FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl, TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption);
//    FFrameBilgi.AktifIcerik.AracCubuguDestegi.EkranAdiAl, TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption);
end;

procedure TGenelAnaSekmeFrame.mnuYeniRaporClick(Sender: TObject);
var
  dokumAdi : Variant;
  TB : TToolButton;
  pd : IPopupDialog;
  c, Dlg : TComponent;
  Ekranadi : string[50];
begin
  dokumAdi := 'YeniRapor';
  if TGirisKutusuEx.BilgiAlEx(BGYeni_rapor, TGirdiDenetimleri.Create.Edit(BGYeni_ad,@dokumAdi)) = mrOk then begin
     if length(dokumAdi)>14 then begin
        showmessage(max14karakter);
        exit
     end
     else begin
        c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
        Dlg := c.Owner;
        Dlg.GetInterface(IPopupDialog,pd);
        Ekranadi := pd.EkranAdiAl;

        TRaporAraclari.YeniRapor(EkranAdi, dokumAdi);
    //    YazdirmaBilgileriniYenile(FFrameBilgi.AktifIcerik);
        //?FFrameBilgi.AktifIcerik.AktifRaporAdi := dokumAdi;
        //Önce eski dökümü aþaðý menüye indirelim
        //TB := TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz'));  yerine aþaðýdaki yapýldý 12/2/2011 ao
        TB :=TToolButton( TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent);
    //    TPopupMenu(FFrameBilgi.AktifIcerik.Ornek.FindComponent('PopupMenuYaz')).Items.ItemOperation(moAdd, TB.Caption, RaporSecClick); yerine aþaðýdaki yapýldý
        TPopupMenu(TMenuItem(sender).GetParentComponent).Items.ItemOperation(moAdd, TB.Caption, RaporSecClick);
        TB.Caption := dokumAdi;
        mnuSayfaAyarlar.Click;
      end;
  end;
end;

type
  t = class(TJvPanel);

procedure TGenelAnaSekmeFrame.pmDokumAyarlarPopup(Sender: TObject);
var sec:Boolean;
  pd : IPopupDialog;
  c, Dlg : TComponent;
  Ekranadi : string;
begin
   c := TMenuItem(sender);
   c := TPopupMenu(c).PopupComponent;
//   c := TToolButton(TPopupMenu(TMenuItem(sender).PopupComponent).GetParentComponent;
//   c := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).GetParentComponent;
   Dlg := c.Owner;
   Dlg.GetInterface(IPopupDialog,pd);
   Ekranadi := pd.EkranAdiAl;
   if Ekranadi = 'DokumDlg' then
      Sec := TRaporAraclari.DokumVarMi(TDokumDlg(Dlg).TabDokum.AsString['RAPORADI'])
   else //mnuSil.Enabled := TPopupMenu(FFrameBilgi.AktifIcerik.Ornek.FindComponent('PopupMenuYaz')).Items.Count > 5;
      Sec := TToolButton(c).Caption <> '';
      //TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption = '';
   mnuSayfaAyarlar.Enabled := Sec;
   mnuSQLAyarlar.Enabled := Sec;
   mnuKopyala.Enabled := Sec;
   mnuSil.Enabled := Sec;
   mnuAdDegistir.Enabled := Sec;
   mnuVarsayilanYap.Enabled := Sec;
   mnuDokumKaydet.Enabled := Sec;
end;

procedure TGenelAnaSekmeFrame.pnlBaslikPaint(Sender: TObject);
begin
//  GradientFillRect(pnlBaslik.Canvas,pnlBaslik.ClientRect,$00F1EDE9,$00CDBBAC,fdTopToBottom,255);
//  t(pnlBaslik).DrawCaption;
end;

procedure TGenelAnaSekmeFrame.pnlYazdirmaPaint(Sender: TObject);
begin
//  GradientFillRect(TJvPanel(Sender).Canvas,TJvPanel(Sender).ClientRect,clWhite,$00D6D6D6,fdTopToBottom,255);
//  if TJvPanel(Sender).Height = KapanmisHali then begin
//    TJvPanel(Sender).Caption := 'Gezinme ve Yazdýrma';
//    t(TJvPanel(Sender)).DrawCaption;
//  end;

  //  t(pnlBaslik).DrawCaption;
end;

procedure TGenelAnaSekmeFrame.RaporSecClick(Sender: TObject);
var
  s : String;
  yy : TToolButton;
begin
  yy := TPopupMenu(TMenuItem(sender).GetParentComponent).Owner.FindComponent('YaziciYaz') as TToolButton;//
  s := TMenuItem(Sender).CaptionShortCutLess;
  TMenuItem(Sender).Caption := yy.Caption;
  yy.Caption := s;
end;

procedure TGenelAnaSekmeFrame.JVRaporSecClick(Sender: TObject);
var
  s : String;
  yy : TJvNavPanelButton;
begin
  yy := TPopupMenu(TMenuItem(sender).GetParentComponent).Owner.FindComponent('YaziciYaz') as TJvNavPanelButton;// TToolButton
  s := TMenuItem(Sender).CaptionShortCutLess;
  TMenuItem(Sender).Caption := yy.Caption;
  yy.Caption := s;
end;

procedure TGenelAnaSekmeFrame.RehberErisimTamamlandi(Sender: TObject);
begin
  //
end;

{TKurumDlg(FFrameYoneticisi.FrameBul(TKurumDlg).Git.Ornek).
    RehbereGit(TRehberAraDlg(Sender).AraQuery1.AsInteger[0]);  }

procedure TGenelAnaSekmeFrame.SetFrameBilgi(AValue: TAnaFrameBilgi);
begin
  //FFrameBilgi := AValue;
end;


procedure TGenelAnaSekmeFrame.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
end;

procedure TGenelAnaSekmeFrame.TusBasili(Sender: TObject; var Key: Char);
begin
end;

procedure TGenelAnaSekmeFrame.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
end;

procedure TGenelAnaSekmeFrame.YaziciYazClick(Sender: TObject);
var
  ekranAdi : string;
begin
//  if not FFrameBilgi.AktifIcerikYazdirmaDestekli then Exit;
{  with FFrameBilgi.IcerikFrameYoneticisi.AktifFrame do begin
    AracCubuguDestegi.YazdirmayaHazirla(FastRaporDlg.frxReport1);
    BilgiFrameIntf.YaziciYazdir(FastRaporDlg);
    if Etiketler.AsBoolean['DökümEkraný'] then
      ekranAdi := TDokumDlg(Ornek).TabDokum.AsString['RAPORADI']
    else
      ekranAdi := TToolButton(TPopupMenu(TMenuItem(sender).GetParentComponent).PopupComponent).Caption;  // ekranAdi := TToolButton(FFrameBilgi.AktifIcerik.Ornek.FindComponent('YaziciYaz')).Caption;
    Delete(ekranAdi, pos('&',ekranAdi), 1);
    FastRaporDlg.FastRapor(0,FFrameBilgi.AktifIcerik.
      AracCubuguDestegi.EkranAdiAl,ekranAdi);
  end; }
end;

procedure TGenelAnaSekmeFrame.YaziciYazdir(Sender: TObject);
begin

end;

initialization
  RegisterClass(TGenelAnaSekmeFrame);

end.
