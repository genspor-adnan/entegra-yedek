unit UHizliGirisPDKS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, cxLookAndFeelPainters, dxSkinsCore, dxSkinLondonLiquidSky, cxControls, cxContainer, cxEdit, cxLabel, StdCtrls, cxButtons,
  ExtCtrls, ComCtrls, ToolWin, cxGraphics, cxDropDownEdit, cxImageComboBox, cxTextEdit, cxMaskEdit, cxCalendar, cxStyles, dxSkinscxPCPainter,
  cxCustomData, cxFilter, cxData, cxDataStorage, DB, cxDBData, FireDAC.Comp.Client, cxGridCustomTableView, cxGridCardView, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridTableView, cxGridDBTableView, cxGrid , Utablo, cxGridDBCardView, cxTimeEdit,Generics.Collections, JvExControls, JvButton, JvNavigationPane, cxLookAndFeels, dxCore, cxDateUtils, cxNavigator, cxGridCustomLayoutView, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  THizliGirisPDKSDlg = class(TForm)
    ToolBar1: TToolBar;
    YeniTus: TToolButton;
    Panel1: TPanel;
    Panel3: TPanel;
    LblSube: TcxLabel;
    cxLabel1: TcxLabel;
    DateTarih: TcxDateEdit;
    ComboSube: TcxImageComboBox;
    TabPDKS: TFDQuery;
    dtsTabPDKS: TDataSource;
    ToolButton1: TToolButton;
    btnGirisSaat: TToolButton;
    btnCikisSaat: TToolButton;
    pmGridStil: TPopupMenu;
    StilOlutur1: TMenuItem;
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    cxLabel9: TcxLabel;
    BtnTumunuSec: TToolButton;
    BtnTumunuBirak: TToolButton;
    PersonelEkleTus: TToolButton;
    GridPDKS: TcxGrid;
    GridPDKSDBTableView1: TcxGridDBTableView;
    GridPDKSView: TcxGridDBCardView;
    GridPDKSViewFIRMA: TcxGridDBCardViewRow;
    GridPDKSViewDURUM: TcxGridDBCardViewRow;
    GridPDKSViewGIRIS: TcxGridDBCardViewRow;
    GridPDKSViewCIKIS: TcxGridDBCardViewRow;
    GridPDKSViewID: TcxGridDBCardViewRow;
    GridPDKSLevel1: TcxGridLevel;
    Panel2: TPanel;
    cxLabel2: TcxLabel;
    lblKayitSayisi: TcxLabel;
    cxLabel3: TcxLabel;
    lblSeciliKayit: TcxLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure YenileClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure btnGirisSaatClick(Sender: TObject);
    procedure GridPDKSViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure GridPDKSViewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure GridDzenleme1Click(Sender: TObject);
    procedure StilOlutur1Click(Sender: TObject);
    procedure AlanYnetimi1Click(Sender: TObject);
    procedure pmGridStilPopup(Sender: TObject);
    procedure GridPDKSViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure KapatTusClick(Sender: TObject);
    procedure BtnTumunuSecClick(Sender: TObject);
    procedure BtnTumunuBirakClick(Sender: TObject);
    procedure PersonelEkleTusClick(Sender: TObject);
  private
    { Private declarations }
    FSel : TList<Integer>;
    procedure SecimiYenile;
    procedure OlmayanlariEkle(Sender: TObject);
  public
    KartNoKontrol:Boolean;
    { Public declarations }
  end;

var
  HizliGirisPDKSDlg: THizliGirisPDKSDlg;


implementation
Uses
UHizliGirisPDKSDurum,FetaKurulusSiniflari,FetaClassExtensions,UGirisKutusuEx,PrjConst,UAnaForm,UOpsDlg,LocOnFly;
{$R *.dfm}

procedure THizliGirisPDKSDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //GridPDKSView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\HizliGirisPDKSGridi',true,false,[gsoUseFilter],'HizliGirisPDKSGridi');
  //Tablo.GridAyarRestore('HizliGirisPDKSGridi',GridPDKSView );

  FSel := TList<integer>.Create;
  DateTarih.Date := Tablo.GENINI.BugunTrh;
  DateTarih.Enabled := RolID='-1';

  Tablo.GridTurkcelestir;
end;

procedure THizliGirisPDKSDlg.FormDestroy(Sender: TObject);
begin
  FSel.Free;
end;


procedure THizliGirisPDKSDlg.OlmayanlariEkle(Sender: TObject);
begin
    Tablo.PDKSEkle(True,DateTarih.Date,ComboSube.EditValue,0,KartNoKontrol);
  // YenileClick(Self);
    YenileClick(self);
end;

procedure THizliGirisPDKSDlg.FormShow(Sender: TObject);
begin
   WindowState := wsMaximized;
   ComboSube.EditValue := SubeId;
   if not SubeVarmi then begin
      LblSube.Visible:=False;
      ComboSube.Visible:=False;
   end;
   KartNoKontrol:=Tablo.GENINI.ReadBoolean(Ops_OpsiyonCari_KartNoTakipTuru, False);
   //Tablo.PDKSEkle(True,DateTarih.Date,0,0,KartNoKontrol);
   YenileClick(self);
end;

procedure THizliGirisPDKSDlg.GridDzenleme1Click(Sender: TObject);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridPDKS;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridPDKSView;
  AnaForm.pmGridStil.Tags.Values[GridPDKS.Name] := 'HizliGirisPDKSGridi';
end;

procedure THizliGirisPDKSDlg.GridPDKSViewMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SecimiYenile;
end;

procedure THizliGirisPDKSDlg.GridPDKSViewMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FSel.Contains(GridPDKSView.Controller.FocusedRecordIndex) then begin
    FSel.Remove(GridPDKSView.Controller.FocusedRecordIndex);
    GridPDKSView.Controller.FocusedCard.Selected := False;
    lblSeciliKayit.Caption:=intToStr(FSel.Count);
  end
  else
  begin
    FSel.Add(GridPDKSView.Controller.FocusedRecordIndex);
    lblSeciliKayit.Caption:=intToStr(FSel.Count);
  end;
  SecimiYenile;
end;

procedure THizliGirisPDKSDlg.GridPDKSViewStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure THizliGirisPDKSDlg.KapatTusClick(Sender: TObject);
begin
  Close;
end;

procedure THizliGirisPDKSDlg.pmGridStilPopup(Sender: TObject);
var
  i: Integer;
begin
  cagirangrid :='GridPDKSView';
  gridalanlari := Tstringlist.Create;

  for i := 0 to GridPDKSView.RowCount - 1 do
    gridalanlari.Add(GridPDKSView.Rows[i].DataBinding.FieldName);

end;

procedure THizliGirisPDKSDlg.SecimiYenile;
var
  i : Integer;
begin
  for I := 0 to FSel.Count - 1 do begin
    GridPDKSView.ViewData.Records[FSel[i]].Selected := True;
  end;
end;

procedure THizliGirisPDKSDlg.StilOlutur1Click(Sender: TObject);
var
  i: integer;
begin
  Application.CreateForm(TOpsiyonDlg, OpsiyonDlg);

  for i := 0 to OpsiyonDlg.PageControl1.PageCount - 1 do
    OpsiyonDlg.PageControl1.Pages[i].TabVisible := OpsiyonDlg.PageControl1.Pages[i].Name = 'shtStiller';

  OpsiyonDlg.pageStil.ActivePage := OpsiyonDlg.shtStilKosullari;
  (OpsiyonDlg.clmStilKosulGridAdi.Properties as TcxComboBoxProperties).Items.Clear;
  (OpsiyonDlg.clmStilKosulGridAdi.Properties as TcxComboBoxProperties).Items.Add(cagirangrid);
  (OpsiyonDlg.clmStilKosulAlanAdi.Properties as TcxComboBoxProperties).Items := gridalanlari;

  OpsiyonDlg.ShowModal;
  FreeAndNil(OpsiyonDlg);
  FreeAndNil(gridalanlari);
  cagirangrid := '';
end;

procedure THizliGirisPDKSDlg.PersonelEkleTusClick(Sender: TObject);
begin
    Tablo.PDKSEkle(True,DateTarih.Date,0,0,KartNoKontrol);
    YenileClick(self);
end;

procedure THizliGirisPDKSDlg.AlanYnetimi1Click(Sender: TObject);
begin
(((Sender as TMenuitem).GetParentComponent as TPopupMenu).PopupComponent as TcxGridDBTableView).Controller.Customization := True;
end;

procedure THizliGirisPDKSDlg.btnGirisSaatClick(Sender: TObject);
var
  i,PERSID,Recordindex : integer;
  Saat,Tarih ,GirisCikisSaat  : variant;
begin
    case TButton(Sender).Tag of
      3:begin
          //Çoklu Seçimli olacak
          Saat:='09:00:00';
          if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.DateTimePicker(BGGiris_saat_gir, @Saat,dtkTime)) <> mrOk then
             Abort;

          for I := 0 to GridPDKSView.DataController.GetSelectedCount - 1 do begin
             GirisCikisSaat:= Saat;
             Recordindex := GridPDKSView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
             PERSID := GridPDKSView.DataController.Values[Recordindex,GridPDKSViewID.Index];
             Tarih  := FormatDateTime('yyyy-mm-dd 00:00:00',StrToDateTime(GridPDKSView.DataController.Values[Recordindex,GridPDKSViewGIRIS.Index]));
             GirisCikisSaat := FormatDateTime('yyyy-mm-dd hh:nn:ss',VarToDateTime(Tarih)+StrToFloat(vartoStr(GirisCikisSaat)));
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set DURUM = 1 ,GIRIS ='''+vartoStr(GirisCikisSaat)+''' Where ID ='+IntToStr(PERSID)+' ',[],[]);
          end;
          FSel.Clear;
          YenileClick(Self);
      end;
      4:begin
         Saat:='18:00:00';
         if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.DateTimePicker(BGCikis_saat_gir, @Saat,dtkTime)) <> mrOk then
          Abort;

          for I := 0 to GridPDKSView.DataController.GetSelectedCount - 1 do begin
             GirisCikisSaat:= Saat;
             Recordindex := GridPDKSView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
             PERSID :=GridPDKSView.DataController.Values[Recordindex,GridPDKSViewID.Index];
             Tarih  := FormatDateTime('yyyy-mm-dd 00:00:00',StrToDateTime(GridPDKSView.DataController.Values[Recordindex,GridPDKSViewGIRIS.Index]));
             GirisCikisSaat := FormatDateTime('yyyy-mm-dd hh:nn:ss',VarToDateTime(Tarih)+StrToFloat(vartoStr(GirisCikisSaat)));
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set CIKIS ='''+vartoStr(GirisCikisSaat)+''' Where ID ='+IntToStr(PERSID)+' ',[],[]);
          end;
         FSel.Clear;
         YenileClick(Self);
      end;
    end;
end;

procedure THizliGirisPDKSDlg.BtnTumunuBirakClick(Sender: TObject);
var
  i : Integer;
begin
  FSel.Clear;
  for I := 0 to GridPDKSView.ViewData.RecordCount - 1 do begin
    GridPDKSView.ViewData.Records[i].Selected := False;
    lblSeciliKayit.Caption:=intToStr(FSel.Count);
  end;
end;

procedure THizliGirisPDKSDlg.BtnTumunuSecClick(Sender: TObject);
var
  i : Integer;
begin
  FSel.Clear;
  for I := 0 to GridPDKSView.ViewData.RecordCount - 1 do begin
    GridPDKSView.ViewData.Records[i].Selected := True;
    FSel.Add(GridPDKSView.ViewData.Records[i].Index);
    lblSeciliKayit.Caption:=intToStr(FSel.Count);
  end;

end;

procedure THizliGirisPDKSDlg.YenileClick(Sender: TObject);
var
  Sql1 : String;
begin
        Sql1 :='SELECT' + #13#10 +
                'PP.ID,R.FIRMA,PV.GUNADI,PP.GIRIS,PP.CIKIS,PP.SUBEID,PP.DURUM,' + #13#10 +
                '(convert(varchar,PV.GIRIS,108) +'' / ''+convert(varchar,PV.CIKIS,108)) as VARGIRISCIKIS,' + #13#10 +
                'GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP.GIRIS),''00:00''),' + #13#10 +
                'CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)),''00:00''),' + #13#10 +
                'CALFARK= CASE WHEN charindex(''*'',dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)))=0' + #13#10 +
                'THEN dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE ''00:00'' END,' + #13#10 +
                'CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),''00:00'')' + #13#10 +
                'from PERS_PDKS PP' + #13#10 +
                'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID' + #13#10 +
                'left outer join PERS_VARDIYATANIM PV on' + #13#10 +
                'PV.REHBERID=CASE WHEN EXISTS(SELECT TOP 1 ISNULL(REHBERID,-1) FROM dbo.PERS_VARDIYATANIM WHERE REHBERID=PP.REHBERID)THEN' + #13#10 +
                'PP.REHBERID ELSE -1 END and PV.GUN=DATEPART(WEEKDAY,PP.GIRIS) Where PP.REHBERID <> 0 ';
      Sql1 := Sql1 + ' AND (PP.GIRIS between CONVERT(DATETIME,''' + FormatDateTime('yyyy-mm-dd', DateTarih.Date) + ' 00:00:00'',102) ' +
      ' and CONVERT(DATETIME,''' + FormatDateTime('yyy-mm-dd', DateTarih.Date)+ ' 23:59'',102))';
    if ComboSube.EditValue <> 0 then begin
      Sql1 := Sql1 + ' and PP.SUBEID = '+VarToStr(ComboSube.EditValue)+'  ';
      TabPDKS.Close;
      TabPDKS.Sql.Text := Sql1 + ' ORDER BY R.FIRMA,PP.GIRIS,PP.CIKIS ';
      TabPDKS.Open;
  end;
  PersonelEkleTus.Visible := DateTarih.Date<=Tablo.GENINI.BugunTrh;
  lblKayitSayisi.Caption:=IntToStr(TabPDKS.RecordCount);
end;

{procedure THizliGirisPDKSDlg.YenileClick(Sender: TObject);
var
  Sql1 : String;
begin
     Sql1 :=  'SELECT' + #13#10 +
              'PP.ID,R.FIRMA,PV.GUNADI,PP.GIRIS,PP.CIKIS,PP.SUBEID,PP.DURUM,' + #13#10 +
              '(convert(varchar,PV.GIRIS,108) +'' / ''+convert(varchar,PV.CIKIS,108)) as VARGIRISCIKIS,' + #13#10 +
              'GIRFARK=isnull(dbo.fn_GIRFARK(convert(varchar,PV.GIRIS,108),PP.GIRIS),''00:00''),' + #13#10 +
              'CALSURE=isnull(dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)),''00:00''),' + #13#10 +
              'CALFARK= CASE WHEN charindex(''*'',dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS)))=0' + #13#10 +
              'THEN dbo.fn_CALFARK(dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),dbo.fn_SaatOlarak(DATEDIFF(mi,PP.GIRIS,PP.CIKIS))) ELSE ''00:00'' END,' + #13#10 +
              'CIKFARK=isnull(dbo.fn_CIKFARK(convert(varchar,PV.GIRIS,108),dbo.fn_SaatOlarak(DATEDIFF(mi,PV.GIRIS,PV.CIKIS)),PP.GIRIS,PP.CIKIS),''00:00'')' + #13#10 +
              'from PERS_PDKS PP' + #13#10 +
              'LEFT OUTER JOIN REHBER R on R.ID=PP.REHBERID' + #13#10 +
              'left outer join PERS_VARDIYATANIM PV on' + #13#10 +
              'PV.REHBERID=CASE WHEN EXISTS(SELECT TOP 1 ISNULL(REHBERID,-1) FROM dbo.PERS_VARDIYATANIM WHERE REHBERID=PP.REHBERID)THEN' + #13#10 +
              'PP.REHBERID ELSE -1 END and PV.GUN=DATEPART(WEEKDAY,PP.GIRIS) Where AY = 0 and PP.REHBERID <> 0  and PP.REHBERID <> 0' + #13#10 +
              ' and PP.GIRIS between '''+FormatDateTime('yyyy-mm-dd 00:00', DateTarih.Date)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59', DateTarih.Date)+''' '+
              ' ORDER BY R.FIRMA,PP.GIRIS,PP.CIKIS ';
  TabPDKS.Close;
  TabPDKS.Sql.Text := Sql1;
  TabPDKS.Open;
  PersonelEkleTus.Visible := (TabPDKS.RecordCount < 1)and(DateTarih.Date<Tablo.GENINI.BugunTrh);
  lblKayitSayisi.Caption:=IntToStr(TabPDKS.RecordCount);
end;}

procedure THizliGirisPDKSDlg.YeniTusClick(Sender: TObject);
Var
  Recordindex,i,PERSID : integer;
  GirisSaat : String;
begin
  Application.CreateForm(THizliGirisPDKSDurumDlg, HizliGirisPDKSDurumDlg);
  HizliGirisPDKSDurumDlg.ShowModal;

  if HizliGirisPDKSDurumDlg.ModalResult = mrClose then begin
    if HizliGirisPDKSDurumDlg.ButtonTag > 0 then begin
      for I := 0 to GridPDKSView.DataController.GetSelectedCount - 1 do begin
         Recordindex := GridPDKSView.DataController.DataControllerInfo.Selection[i]^.RecordIndex;
         PERSID      := GridPDKSView.DataController.Values[Recordindex,GridPDKSViewID.Index];
         GirisSaat   := (GridPDKSView.DataController.Values[Recordindex,GridPDKSViewGIRIS.Index]);
         if HizliGirisPDKSDurumDlg.ButtonTag = 1 then begin  /// Geldi seçilince saat boşsa şimdiki saati atsın
           if Length(GirisSaat) < 11 then
              GirisSaat := 'GIRIS = '''+FormatDateTime('yyyy-mm-dd hh:nn:ss', DateTarih.Date)+''','
           else  GirisSaat := '';
         end else GirisSaat := '';
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update PERS_PDKS set '+GirisSaat+' DURUM ='+IntToStr(HizliGirisPDKSDurumDlg.ButtonTag)+' Where ID ='+IntToStr(PERSID)+' ',[],[]);
      end;
       FSel.Clear;
       YenileClick(Sender);
    end;
  end;
  HizliGirisPDKSDurumDlg.Free;
end;

end.



