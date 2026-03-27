unit UHizliGirisTahsilat;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, JvExControls, JvButton, JvNavigationPane, dxSkinsCore,
  dxSkinLondonLiquidSky, cxLabel, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxCurrencyEdit, StdCtrls, ExtCtrls, Menus, cxLookAndFeelPainters, cxButtons,
  dxSkinscxPCPainter, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridCardView, cxGridDBCardView, cxClasses,
  cxGridCustomView, cxGrid, cxCheckBox, cxImage, cxGridTableView, cxGridDBTableView, FireDAC.Comp.Client,
  cxLookAndFeels, cxNavigator, cxGridCustomLayoutView, dxSkinLiquidSky,
  cxSplitter, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans,
  dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
   dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
   dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxDateRanges, dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  THizliGirisTahsilatDlg = class(TForm)
    PanelTahsilat: TPanel;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    Panel3: TPanel;
    PanelTutar: TPanel;
    Panel4: TPanel;
    cxCurrencyEdit1: TcxCurrencyEdit;
    cxCurrencyEdit2: TcxCurrencyEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel6: TcxLabel;
    ToplamTutar: TcxCurrencyEdit;
    Panel6: TPanel;
    cxLabel12: TcxLabel;
    KalanTutar: TcxCurrencyEdit;
    KaydetTus: TJvNavPanelButton;
    TabResim: TFDQuery;
    DtsResim: TDataSource;
    cxGridResim: TcxGrid;
    GridResimView: TcxGridDBTableView;
    cxGridDBColumnRESIM: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    DigerMenu: TPopupMenu;
    DigerYeniMenu: TMenuItem;
    DigerSilMenu: TMenuItem;
    cxSplitter1: TcxSplitter;
    cxSplitter2: TcxSplitter;
    PanelKalanlar: TPanel;
    BtnKalanIskonto: TJvNavPanelButton;
    cxLabel9: TcxLabel;
    EditParaUstu: TcxCurrencyEdit;
    BtnKalanAcikHesap: TJvNavPanelButton;
    Panel1: TPanel;
    BtnNum1: TJvNavPanelButton;
    BtnNum8: TJvNavPanelButton;
    BtnNum7: TJvNavPanelButton;
    BtnNum6: TJvNavPanelButton;
    BtnNum4: TJvNavPanelButton;
    BtnNum5: TJvNavPanelButton;
    BtnNum2: TJvNavPanelButton;
    BtnNum3: TJvNavPanelButton;
    BtnNum9: TJvNavPanelButton;
    BtnNum0: TJvNavPanelButton;
    BtnNumComma: TJvNavPanelButton;
    BtnNumBspc: TJvNavPanelButton;
    GridTahsilatlar: TcxGrid;
    GridTahsilatlarView: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    GridTahsilatlarViewTAHSILAD: TcxGridDBColumn;
    GridTahsilatlarViewTUTAR: TcxGridDBColumn;
    GridTahsilatlarViewKUR: TcxGridDBColumn;
    GridTahsilatlarViewID: TcxGridDBColumn;
    EditOdenen: TcxTextEdit;
    procedure BtnNumSlsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnTutar5Click(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cxGridTahsilatlarDBCardView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure DigerYeniMenuClick(Sender: TObject);
    procedure DigerSilMenuClick(Sender: TObject);
    procedure cxGridFaturaDBCardView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure BtnSagaTusClick(Sender: TObject);
    procedure cxGridDBCardView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure GridResimViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure GridTahsilatlarViewDataControllerDataChanged(Sender: TObject);
    procedure GridTahsilatlarViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);

  private
    TusBasili:Boolean;
    { Private declarations }
    procedure KalanParaUstu;
    procedure YanaGecir(Tbl, Tbl2 : TFDQuery; GecTbl,GecTbl2:String; EdGecTpl,EdGecTpl2:Tcxcurrencyedit );
  public
    { Public declarations }
    GeciciTablo, GeciciTablo2  : string[50];
    ToplamNakit: currency;
    Cagiran:Smallint;  //1-Hizligirişten   2-Hızlıgiriş ana menüden
    IskontOran:Real;
  end;

var
  HizliGirisTahsilatDlg: THizliGirisTahsilatDlg;

implementation

Uses Utablo, UHizliGiris, UHizliGirisKKTahsilat, PrjConst, UHizliGirisAnaMenu, UGirisKutusuEx, Jpeg,
     FetaKurulusSiniflari, LocOnFly,Fetautil;
var
   OdemeTuru: Integer;
   OdemeAdi  : string[50];
   ToplamTahsilat : Real;
{$R *.dfm}


procedure THizliGirisTahsilatDlg.KalanParaUstu;
var ToplamAlinan : Real;
    i : smallint;
begin
   ToplamTahsilat := 0;


   //GridTahsilatlarView.Controller.SelectAll;
   for i := 0 to GridTahsilatlarView.ViewData.RecordCount -1 do
      if GridTahsilatlarView.ViewData.GetRecordByIndex(i).Values[GridTahsilatlarViewTUTAR.Index]<>null then
         ToplamTahsilat := ToplamTahsilat + GridTahsilatlarView.ViewData.GetRecordByIndex(i).Values[GridTahsilatlarViewTUTAR.Index];

//   for i := 0 to GridTahsilatlarView.Controller.SelectedRecordCount-1 do
//      if GridTahsilatlarView.Controller.SelectedRecords[i].Values[GridTahsilatlarViewTUTAR.Index]<>null then
//         ToplamTahsil := ToplamTahsil + GridTahsilatlarView.Controller.SelectedRecords[i].Values[GridTahsilatlarViewTUTAR.Index];


   KalanTutar.EditValue := ToplamTutar.EditValue - ToplamTahsilat;
   if KalanTutar.EditValue<0 then
      KalanTutar.EditValue:=0;

   EditParaUstu.EditValue := 0;
   if ToplamTahsilat > ToplamTutar.EditValue then
      EditParaUstu.EditValue := ToplamTahsilat - ToplamTutar.EditValue;
(*   if ToplamTahsilat > 0 then begin
      ToplamAlinan := ToplamTahsilat-HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').Value;// + EditOdenen.Value;
      if {(Cagiran=1)and}(ToplamAlinan > ToplamTutar.EditValue)and(ToplamTutar.EditValue>0) then
         EditParaUstu.EditValue := ToplamAlinan - ToplamTutar.EditValue;
   end;
   EditOdenen.EditValue := KalanTutar.Value;
   if PanelTahsilat.Visible then
      EditOdenen.SetFocus;
   EditOdenen.SelectAll;
   HesapAyirTus.Visible := ToplamTutar.Value=KalanTutar.Value;
   KaydetTus.visible := ToplamTahsilat>0;
   PanelKalanlar.visible := KalanTutar.EditValue > 0.01;  *)
end;

procedure THizliGirisTahsilatDlg.BtnNumSlsClick(Sender: TObject);
var
  Key:Word;
begin

  if not TusBasili then begin
    (Sender as TJvNavPanelButton).Down := True;
    if (Sender as TJvNavPanelButton).Tag = 55 then //geri tuşu '  ‹'
      if EditOdenen.SelLength>0 then
        EditOdenen.ClearSelection
      else
        EditOdenen.Text := Copy(EditOdenen.Text,1,Length(EditOdenen.Text)-1)
    else if (Sender as TJvNavPanelButton).Caption= '-' then
      if Copy(EditOdenen.Text,1,1)='-' then
        EditOdenen.Text := Copy(EditOdenen.Text,2,Length(EditOdenen.Text)-1)
      else
        EditOdenen.Text := (Sender as TJvNavPanelButton).Caption+EditOdenen.Text
    else if (Sender as TJvNavPanelButton).Caption <> 'Ent' Then begin
      EditOdenen.ClearSelection;
      EditOdenen.Text := Copy(EditOdenen.Text,1,EditOdenen.CursorPos)
                        +(Sender as TJvNavPanelButton).Caption
                        +Copy(EditOdenen.Text,EditOdenen.CursorPos+1,Length(EditOdenen.Text));
    end;
    if (Sender as TJvNavPanelButton).Caption <> 'Ent' then begin
      EditOdenen.SetFocus;
      EditOdenen.SelStart:= Length(EditOdenen.Text);
    end;
    HizliGirisAnaMenu.TabTahDetay.Edit;
    HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsString:= EditOdenen.text;

  end;

end;

procedure THizliGirisTahsilatDlg.BtnSagaTusClick(Sender: TObject);
var OdenenId : string;
begin                                     (*
   EditOdenen.EditValue := EditGeciciToplam2.EditValue;
   BtnNumEnter.Click;
   OdenenId :='';
   while not TabDetay2.eof do begin
       OdenenId := OdenenId +TabDetay2.FieldByName('ID').AsString;
       TabDetay2.Delete;
       TabDetay2.first;
       if not TabDetay2.eof  then
          OdenenId := OdenenId + ','
   end;
   EditGeciciToplam2.Value := 0;
   HizliGirisAnaMenu.TabTahDetay.Edit;
   HizliGirisAnaMenu.TabTahDetay.FieldByName('ACIKLAMA').Value := OdenenId;
   HizliGirisAnaMenu.TabTahDetay.post;  *)
end;

procedure THizliGirisTahsilatDlg.BtnTutar5Click(Sender: TObject);
begin
  //EditOdenen.EditValue := strtocurr((Sender as TJvNavPanelButton).Caption)
end;

procedure THizliGirisTahsilatDlg.YanaGecir(Tbl, Tbl2 : TFDQuery; GecTbl,GecTbl2:String; EdGecTpl,EdGecTpl2:Tcxcurrencyedit);
begin           (*
   //Önce bakalım sağ tarafa geçmiş mi
   if Veritabani.VeriVarMi(Tablo.FDCnn,'SELECT * from '+GecTbl2+' where ID='+Tbl.FieldByName('ID').AsString,[],[]) then
      //varsa sayısının artıralım
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+GecTbl2+' set ADET=ADET+1, MIKTAR=MIKTAR+1, TUTAR=TUTAR+'+FCurrToStr(Tbl.FieldByName('BIRIMFIYAT').AsCurrency)+' where ID='+Tbl.FieldByName('ID').AsString, [],[])
   else begin// yoksa ekleyelim
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,StringReplace(MemoAdisyonSatir.Text, 'TABLOADI', StringReplace(GecTbl2, '&', '', [rfReplaceAll]), [rfReplaceAll])+
      ' '+GecTbl+' where ID='+Tbl.FieldByName('ID').AsString, [],[]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+GecTbl2+' set ADET=1, MIKTAR=1, TUTAR='+FCurrToStr(Tbl.FieldByName('BIRIMFIYAT').AsCurrency)+' where ID='+Tbl.FieldByName('ID').AsString, [],[])
   end;
   Tbl2.Close;
   Tbl2.Open;

   EdGecTpl.Value := EdGecTpl.Value-Tbl.FieldByName('BIRIMFIYAT').Value;
   EdGecTpl2.Value := EdGecTpl2.Value+Tbl.FieldByName('BIRIMFIYAT').Value;

  if Tbl.FieldByName('ADET').Value > 1 then begin
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+GecTbl+' set ADET=ADET-1, MIKTAR=MIKTAR-1, TUTAR=TUTAR-'+FCurrToStr(Tbl.FieldByName('BIRIMFIYAT').AsCurrency)+' where ID='+Tbl.FieldByName('ID').AsString, [],[])
     //Tbl.edit;
     //Tbl.FieldByName('ADET').Value := Tbl.FieldByName('ADET').Value - 1;
     //Tbl.post;
  end else
     Tbl.Delete;
  Tbl.Close;
  Tbl.Open;   *)
end;

procedure THizliGirisTahsilatDlg.cxGridDBCardView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   //YanaGecir(TabDetay2,TabDetay,GeciciTablo2,GeciciTablo,EditGeciciToplam2, EditGeciciToplam );
end;

procedure THizliGirisTahsilatDlg.cxGridFaturaDBCardView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   //YanaGecir(TabDetay,TabDetay2,GeciciTablo,GeciciTablo2,EditGeciciToplam, EditGeciciToplam2 );
end;

procedure THizliGirisTahsilatDlg.cxGridTahsilatlarDBCardView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
(*  procedure Sola_Al;
  var OdenenId : TStringList;
      i : smallint;
  begin //en sağda tahsilat miktarı tıklanırsa  o tahsilata ait ürünler bir sol tarfa geçer
      OdenenId := TStringList.Create;
      Parcala(HizliGirisAnaMenu.TabTahDetay.FieldByName('ACIKLAMA').AsString, OdenenId);
      for i:=0 to OdenenId.Count-1 do
          Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,StringReplace(MemoAdisyonSatir.Text, 'TABLOADI', StringReplace(GeciciTablo2, '&', '', [rfReplaceAll]), [rfReplaceAll])+
          ' '+HizliGirisDlg.AktifFatTabloAdi+' where ID='+OdenenId.Strings[i], [],[]);
//      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update '+TabDetay2+' set ADET=1, MIKTAR=1, TUTAR='+FCurrToStr(HizliGirisAnaMenu.TabTahDetay.FieldByName('BIRIMFIYAT').AsCurrency)+' where ID='+HizliGirisAnaMenu.TabTahDetay.FieldByName('ID').AsString, [],[]);
      OdenenId.Destroy;
      TabDetay2.Close;
      TabDetay2.Open;
      EditGeciciToplam2.Value:=EditGeciciToplam2.Value+HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').Value;
   end;      *)
begin                    (*
   if HizliGirisAnaMenu.TabTahDetay.RecordCount > 0 then begin
      if PanelHesapAyir.Visible then
         Sola_Al;
      ToplamTahsilat := ToplamTahsilat - HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').Value;
      if HizliGirisAnaMenu.TabTahDetay.FieldByName('TUR').AsInteger=21 then
         ToplamNakit := ToplamNakit - HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').Value;
      HizliGirisAnaMenu.TabTahDetay.Delete;
   end;
   if HizliGirisAnaMenu.TabTahDetay.RecordCount = 0 then
      ToplamTahsilat := 0;
   KalanParaUstu;      *)
end;

procedure THizliGirisTahsilatDlg.DigerSilMenuClick(Sender: TObject);
var s:string;
begin
   if not OdemeTuru in [21] then Exit;
   s := 'TUTAR';
   if Application.MessageBox(PChar(TabResim.FieldByName(s).AsString+HGsilinsinmi), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PARA_KUPON where ID=&Id ', ['&Id'], [TabResim.FieldByName('ID').AsInteger]);
   TabloYenile(TabResim, []);
   {   if OdemeTuru = 26 then
         BtnDigerOdeme.Click
      else
         BtnNakitOdeme.Click;}
   end;
end;

procedure THizliGirisTahsilatDlg.DigerYeniMenuClick(Sender: TObject);
var  YeniAd  : Variant;
     Pic : TJpegImage;
     s : string;
begin
   OdemeTuru := TMenuItem(Sender).Tag;
   if OdemeTuru > 100 then exit; //silmeler burda değil
   YeniAd := '';
   s := ' Miktarını girin ';
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit(s, @YeniAd)) <> mrOk then
      Abort;
   YeniAd := trim(YeniAd);
   if YeniAd<>'' then begin
      Tablo.OpenPictureDialog1.Execute;
      if Tablo.OpenPictureDialog1.Files.Count>0 then begin
          Pic := TJpegImage.Create;
          Pic.LoadFromFile(Tablo.OpenPictureDialog1.Files[0]);
          Tablo.Query1.Close;
          Tablo.Query1.SQL.Text := ' insert into PARA_KUPON (TUR,TUTAR,KUR,RESIM,DURUM)values(21,'''+YeniAd+''','''+CariDoviz+''',:Prm1,1)';
          Tablo.Query1.Params[0].Assign(Pic);
          Tablo.Query1.ExecSQL;
          Pic.Free;
          TabloYenile(TabResim, [])

      end;
   end;
end;

procedure THizliGirisTahsilatDlg.FormCreate(Sender: TObject);
begin
  Tablo.GridTurkcelestir;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  BtnNumComma.Caption:=FormatSettings.Decimalseparator;

  BtnKalanAcikHesap.visible := CheckKalanAcik;
  BtnKalanIskonto.visible := CheckKalanIsk;
  PanelKalanlar.visible :=BtnKalanAcikHesap.visible or  BtnKalanIskonto.visible;
  if BtnKalanIskonto.visible=False then
     BtnKalanAcikHesap.Align := alClient;

  HizliGirisAnaMenu.TabTahDetay.Open;
  HizliGirisAnaMenu.TabTahDetay.Edit;
  GridTahsilatlarView.DataController.DataSource := HizliGirisAnaMenu.DtsTahDetay;
  TabloYenile(TabResim, []);

  (*
  PanelHesapAyir.Width := 445;
  PanelTahsilat.Width := 352;
  Width := 890;


  BtnNakitOdeme.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurNakit, True); //   StokHizliGiris OdeTurNakit
  BtnHCOdeme.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurHC, True); // StokHizliGiris  OdeTurHC
  BtnKKOdeme.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurPOS, True); // StokHizliGiris ', 'OdeTurPOS
  BtnICOdeme.Visible := Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurIC, True); // StokHizliGiris     'OdeTurIC
  BtnDigerOdeme.Visible:= Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurKupon, True); // StokHizliGiris  OdeTurKupon
  BtnAcikHesap.Visible := {(Cagiran=1)and}(Tablo.GENINI.ReadBoolean(Ops_StokHizliGiris_TahTurAcikHesap, True));
  *)
end;

procedure THizliGirisTahsilatDlg.FormDestroy(Sender: TObject);
begin
  if GeciciTablo <> '' then
     HizliGirisDlg.TempTablolariYokEt(GeciciTablo);
  if GeciciTablo2 <> '' then
     HizliGirisDlg.TempTablolariYokEt(GeciciTablo2);
end;

procedure THizliGirisTahsilatDlg.FormShow(Sender: TObject);
begin
   if Cagiran=1 then  //hızlıgirişten çağrılıyorsa
      ToplamTutar.EditValue := HizliGirisDlg.EditToplamTutar.EditValue;

   KalanTutar.EditValue := ToplamTutar.EditValue;
   HizliGirisAnaMenu.TabTahDetay.Last;
   while not HizliGirisAnaMenu.TabTahDetay.Bof do begin
      HizliGirisAnaMenu.TabTahDetay.Edit;
      HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency := 0;
      HizliGirisAnaMenu.TabTahDetay.Post;
      HizliGirisAnaMenu.TabTahDetay.prior;
   end;


   //ToplamNakit :=0;

//   while HizliGirisAnaMenu.TabTahDetay.RecordCount > 0 do
//         HizliGirisAnaMenu.TabTahDetay.Delete;
   OdemeTuru := 21;
   (*
   EditOdenen.EditValue := ToplamTutar.Value;
   ToplamTahsilat := 0;
   BtnNakitOdeme.Click;
   EditOdenen.SetFocus;
   EditOdenen.SelectAll;
   BtnNakitOdeme.Down := True;
   *)
end;

procedure THizliGirisTahsilatDlg.GridResimViewCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
(*
   if OdemeTuru = 21 then begin
      EditOdenen.EditValue := TabResim.FieldByName('TUTAR').AsCurrency;
   end;
   *)
   HizliGirisAnaMenu.TabTahDetay.First;
   HizliGirisAnaMenu.TabTahDetay.Edit;
   HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency := HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency + TabResim.FieldByName('TUTAR').AsCurrency;
   //BtnNumEnter.Click;
   KalanParaUstu;
end;

procedure THizliGirisTahsilatDlg.GridTahsilatlarViewCellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   if ACellViewInfo.Item.Index = 1 then begin
      HizliGirisAnaMenu.TabTahDetay.Edit;
      if HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency>0.01 then
         HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency := 0
      else
         HizliGirisAnaMenu.TabTahDetay.FieldByName('TUTAR').AsCurrency := KalanTutar.EditValue;
      KalanParaUstu
   end;
end;

procedure THizliGirisTahsilatDlg.GridTahsilatlarViewDataControllerDataChanged(
  Sender: TObject);
begin
   KalanParaUstu;
end;

procedure THizliGirisTahsilatDlg.KapatTusClick(Sender: TObject);
begin
//   if HizliGirisAnaMenu.TabTahDetay.RecordCount>0 then
//      raise Exception.Create(HGKapatmak_icin_sil);
   ModalResult := mrCancel;
end;

procedure THizliGirisTahsilatDlg.KaydetTusClick(Sender: TObject);
begin
   if HizliGirisAnaMenu.TabTahDetay.state = dsEdit then
      HizliGirisAnaMenu.TabTahDetay.Post;
   IskontOran:=0;
//   if (PanelHesapAyir.Visible) then begin
//       if(TabDetay2.RecordCount>0) then
//          raise exception.Create(HGsecililer_var_kapatilamaz);
//   end else begin
       if (KalanTutar.Value > 0)and(TJvNavIconButton(Sender).Name='KaydetTus') then {or(PanelHesapAyir.Visible)or(Cagiran=2)} //hızlıgiriş ana menüden çağrılıyorsa)
          raise exception.Create(HGsifirdan_buyuk_kapatilmaz)
       else if (KalanTutar.Value > 0)and(TJvNavIconButton(Sender).Name='BtnKalanIskonto') then
           IskontOran := (KalanTutar.Value / ToplamTutar.EditValue)*100;
//   end;
   ModalResult := mrOk
end;

end.

{
   case OdemeTuru of
     21 : TabResim.SQL.Text :=' select * from PARA_KUPON where TUR = 21 and DURUM = 1 order by TUTAR '; //Nakit
     25 : TabResim.SQL.Text :=' select ID,ADI, RESIM from POS where DURUM = 1 and SUBEID='+IntToStr(SubeId);                        //POS
     26 : TabResim.SQL.Text :=' select * from PARA_KUPON where TUR = 26 and DURUM = 1 order by ADI  ';   //Kupon

   end;
   }





