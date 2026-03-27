unit UTakvimProje;
  		
{ Bu kod Sablon Duzenleyici tarafindan uretildi }		
{ Tarih : 03/12/2010 10:55:53}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxTextEdit, ComCtrls, StdCtrls, UFrameYoneticisi, Menus,
  cxLookAndFeelPainters, cxButtons, UGentegreFrameYonetimi, dxSkinsCore,
  cxLabel, UTakvimProjeAramaFrame,DateUtils, cxStyles, cxGraphics, cxScheduler,
  cxSchedulerStorage, cxSchedulerCustomControls, cxSchedulerCustomResourceView,
  cxSchedulerDayView, cxSchedulerDateNavigator, cxSchedulerHolidays,
  cxSchedulerTimeGridView, cxSchedulerUtils, cxSchedulerWeekView,
  cxSchedulerYearView, cxSchedulerGanttView, dxSkinscxPCPainter, cxCustomData,
  cxFilter, cxData, cxDataStorage, DB, cxDBData, cxCurrencyEdit, FireDAC.Comp.Client,
  cxSchedulerDBStorage, ToolWin, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  ExtCtrls, dxSkinLondonLiquidSky, cxCheckBox, Spin, cxLookAndFeels,
  dxSkinscxSchedulerPainter, cxNavigator, cxSchedulerTreeListBrowser,
  cxSchedulerRibbonStyleEventEditor, cxSchedulerRecurrence, dxSkinLiquidSky,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;  //dxSkinscxScheduler3Painter,
type
  TTakvimProje = class(TFrame, IIcerikBilgiFrame, IBilgiFrame)
    Scheduler: TcxScheduler;
    pnlControls: TPanel;
    Memo1: TMemo;
    GridToplam: TcxGrid;
    ToplamView: TcxGridDBTableView;
    ToplamViewYON: TcxGridDBColumn;
    ToplamViewTUR: TcxGridDBColumn;
    ToplamViewTUTAR: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    ToolBar1: TToolBar;
    AylikTus: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    MemoPlanSQL: TMemo;
    SchedulerDBStorage: TcxSchedulerDBStorage;
    SchedulerDataSource: TDataSource;
    AraQuery1: TFDQuery;
    PopupMenu1: TPopupMenu;
    BilgileriDegisMenu: TMenuItem;
    N3: TMenuItem;
    ButariheProjeekle: TMenuItem;
    Query1: TFDQuery;
    DtsToplam: TDataSource;
    TabToplam: TFDQuery;
    N1: TMenuItem;
    ProjeyiSil1: TMenuItem;
    YillikTus: TToolButton;
    MemoBaslangic: TMemo;
    MemoBitis: TMemo;
    dtsTakvimKaynaklari: TDataSource;
    tabTakvimKaynaklari: TFDQuery;
    CheckSorumluGrupla: TcxCheckBox;
    edTakvimSayisi: TSpinEdit;
    procedure YenileTusClick(Sender: TObject);
    procedure AylikTusClick(Sender: TObject);
    procedure ButariheProjeekleClick(Sender: TObject);
    procedure BilgileriDegisMenuClick(Sender: TObject);
    procedure ProjeyiSil1Click(Sender: TObject);
    procedure SchedulerDblClick(Sender: TObject);
    procedure EditSorumluPropertiesEditValueChanged(Sender: TObject);
    procedure KaynaklariYukle;
    procedure CheckSorumluGruplaPropertiesEditValueChanged(Sender: TObject);
    procedure edTakvimSayisiChange(Sender: TObject);
  private
    { Private declarations }
    FFrameBilgi : TIcerikFrameBilgi;
    FTakvimProjeler : TTakvimProjeAramaFrame;
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
    function GetFrameBilgi : TIcerikFrameBilgi;
    procedure SetFrameBilgi(AValue : TIcerikFrameBilgi);

    { Gezinme ve yazdirma destegi }
    function GezinmeAktifMi : Boolean;
    function YazdirmaAktifMi : Boolean;
    function EkranAdiAl : string;
    procedure SetTakvimProje(const Value: TTakvimProjeAramaFrame);
  public
    { Public declarations }

  published
    property TakvimProjeler : TTakvimProjeAramaFrame read FTakvimProjeler write SetTakvimProje;
  end;

implementation

{$R *.dfm}

uses UAnaForm, Utablo, FetaKurulusSiniflari, PrjConst,LocOnFly;
{ TTakvimProje }
var
 KaynakKomut:string;

procedure TTakvimProje.AylikTusClick(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0: Scheduler.ViewDay.Active := True;
    1: Scheduler.SelectWorkDays(Date);
    2: Scheduler.ViewWeek.Active := True;
    3: Scheduler.GoToDate(Scheduler.SelectedDays[0], vmMonth);
    4: Scheduler.ViewTimeGrid.Active := True;
    5: Scheduler.ViewYear.Active := True;
  end;
end;

procedure TTakvimProje.Baslatildi;
begin
    if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.

    Tablo.GridTurkcelestir;

    edTakvimSayisi.Value:=3;
    Scheduler.OptionsView.GroupingKind:= gkNone;
    KaynakKomut:=  '                                     '+
           '   DECLARE @TARIH SMALLDATETIME,     '+
           '       @SAHIPREHBERID INT,           '+
           '       @YETKIALANI INT               '+
           '   SET @SAHIPREHBERID = '+Kullanan+'     '+
           '   SET @YETKIALANI = 1                   '+
           '   SELECT Reh.ID REHBERID, Reh.FIRMA PERSONEL                   '+
           '         FROM KULLANICI Kul                 '+
           '                   Inner Join REHBER Reh on Reh.ID = Kul.REHBERID ';
    if PersonelYetkiKontrol then
            KaynakKomut:= KaynakKomut+ ' Inner Join YETKIALANI Alan ON Alan.REHBERID = Kul.REHBERID ';


    if PersonelYetkiKontrol then
            KaynakKomut:= KaynakKomut+ '    AND Alan.SAHIPREHBERID = @SAHIPREHBERID    '+
                         '     AND Alan.ALANTURU = @YETKIALANI           ';

            KaynakKomut:= KaynakKomut+ ' ORDER BY PERSONEL	' ;
end;

procedure TTakvimProje.BilgileriDegisMenuClick(Sender: TObject);
var AKT_ID, REH_ID : String[15];
    Tur : SmallInt;
    s : string;

var
  selectedEvent : TcxSchedulerControlEvent;
begin
  if Scheduler.SelectedEventCount = 0 then Exit;
  selectedEvent := Scheduler.SelectedEvents[0];
   AKT_ID := selectedEvent.GetCustomFieldValueByName('AKT_ID');
   REH_ID := selectedEvent.GetCustomFieldValueByName('REH_ID');
   Tur := selectedEvent.GetCustomFieldValueByName('TUR');
   if Tablo.ProjeSihirbazBaslat('D',StrToIntDef(AKT_ID,-1),StrToIntDef(REH_ID,-1), Tablo.GENINI.BugunTrh) > 0 then
      FTakvimProjeler.YenileTus.Click;
end;

procedure TTakvimProje.ButariheProjeekleClick(Sender: TObject);
var Trh : TDateTime;

begin
    Trh := Scheduler.SelStart;
    if Tablo.ProjeSihirbazBaslat('E',-1,-1, Trh) > 0 then
       FTakvimProjeler.YenileTus.Click;
end;

procedure TTakvimProje.CheckSorumluGruplaPropertiesEditValueChanged(
  Sender: TObject);
begin
  edTakvimSayisi.Visible:= CheckSorumluGrupla.Checked;

  if CheckSorumluGrupla.Checked then
   begin

    Scheduler.OptionsView.ResourcesPerPage:= edTakvimSayisi.Value;
    Scheduler.OptionsView.GroupingKind:= gkByResource;
   end
  else
    Scheduler.OptionsView.GroupingKind:= gkNone;
end;

function TTakvimProje.EkranAdiAl: string;
begin
  Result := ClassName;
end;

procedure TTakvimProje.KaynaklariYukle;
var
 i,say : Integer;
 APCheckStates:^TcxCheckStates;
begin
     i:=0;
     say:=0;

     if FTakvimProjeler.editSorumlu.Text='' then
      begin

         tabTakvimKaynaklari.Close;
         tabTakvimKaynaklari.SQL.Text:= KaynakKomut;
         tabTakvimKaynaklari.Open;
         tabTakvimKaynaklari.First;

        while SchedulerDBStorage.Resources.Items.Count>0 do
         SchedulerDBStorage.Resources.Items.Delete(0);

        while not tabTakvimKaynaklari.Eof do
         begin
            SchedulerDBStorage.Resources.Items.Add;
            SchedulerDBStorage.Resources.Items[tabTakvimKaynaklari.RecNo-1].Name:= tabTakvimKaynaklari.FieldByName('PERSONEL').AsString;
            SchedulerDBStorage.Resources.Items[tabTakvimKaynaklari.RecNo-1].ResourceID:=tabTakvimKaynaklari.FieldByName('REHBERID').AsInteger;
            tabTakvimKaynaklari.Next;
         end;
      end
     else
      begin
        // eğer seçili sorumlu varsa takvim kaynakları seçilenlerden dolsun
        while SchedulerDBStorage.Resources.Items.Count>0 do
         SchedulerDBStorage.Resources.Items.Delete(0);

         New(APCheckStates);
         try
          with FTakvimProjeler.editSorumlu do
            begin
             CalculateCheckStates(Value, Properties.Items,Properties.EditValueFormat , APCheckStates^);
              for i := 0 to Properties.Items.Count - 1 do
                if APCheckStates^[I] = cbsChecked then
                 begin
                   SchedulerDBStorage.Resources.Items.Add;
                   SchedulerDBStorage.Resources.Items[say].Name:=  Properties.Items[i].Description ;
                   SchedulerDBStorage.Resources.Items[say].ResourceID:= StrToInt(Properties.Items[i].ShortDescription);
                   say:=say+1;
                 end;

            end;
         finally
          Dispose(APCheckStates);
         end;
      end;
end;

procedure TTakvimProje.EditSorumluPropertiesEditValueChanged(
  Sender: TObject);
  begin
     KaynaklariYukle;

     YenileTusClick(Self);
  end;
procedure TTakvimProje.edTakvimSayisiChange(Sender: TObject);
begin
   CheckSorumluGruplaPropertiesEditValueChanged(Self);
end;

procedure TTakvimProje.SetTakvimProje(const Value: TTakvimProjeAramaFrame);
begin
  FTakvimProjeler := Value;
  with FTakvimProjeler do begin
    dateProjeBitis.Date := EndOfTheYear(StrToDate('31'+FormatSettings.DateSeparator+'12'+FormatSettings.DateSeparator+IntToStr(CariYil+1))); //Date+60;
    dateProjeBaslangic.Date:= StartOfTheYear(StrToDate('01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+IntToStr(CariYil-1))); //Date-40;
    checkTarih.Checked:=True;
    YenileTus.Click;

  end;
  AylikTus.Click;//   clSpeedButton1.Click;
end;

procedure TTakvimProje.EkranYazdir(Sender: TObject);
begin

end;

procedure TTakvimProje.FareTekerlekAsagi(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TTakvimProje.FareTekerlekYukari(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin

end;

function TTakvimProje.GetFrameBilgi: TIcerikFrameBilgi;
begin
  Result := FFrameBilgi;
end;

function TTakvimProje.GetKapatilabilir: Boolean;
begin

end;

function TTakvimProje.GezinmeAktifMi: Boolean;
begin
  Result := True;
end;

procedure TTakvimProje.Gorunmez;
begin

end;

procedure TTakvimProje.GorunmezOlacak;
begin

end;

procedure TTakvimProje.Gorunur;
begin
     FTakvimProjeler.editSorumlu.Properties:= Tablo.CheckComboboxInit(KaynakKomut);
     FTakvimProjeler.editSorumlu.Properties.OnEditValueChanged:= EditSorumluPropertiesEditValueChanged;

end;

procedure TTakvimProje.GorunurOlacak;
begin

end;

procedure TTakvimProje.Kapatiliyor(var AKapansin: Boolean);
begin

end;

procedure TTakvimProje.ProjeyiSil1Click(Sender: TObject);
var
  selectedEvent : TcxSchedulerControlEvent;
  AKT_ID : String[15];
  GoogleTakvimSonuc:boolean;
begin
  if Scheduler.SelectedEventCount = 0 then Exit;
  selectedEvent := Scheduler.SelectedEvents[0];
   AKT_ID := selectedEvent.GetCustomFieldValueByName('AKT_ID');
   Tablo.TablodanSorguAc(5,'select * from projeler where ID='+AKT_ID);
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin
      //Google Calendar İçinden Siliniyor
     if (GCalendarAktif = true) and ( Tablo.Query5.FieldByName('GOOGLEOLAYID').AsString <> '') then
      begin
        GoogleTakvimSonuc:= Tablo.GoogleTakvimSil(Tablo.Query5.FieldByName('GOOGLEHESAPID').AsInteger,
                                                  Tablo.Query5.FieldByName('GOOGLEOLAYID').AsString);
        if GoogleTakvimSonuc= false then
           Showmessage(AKGoogle_takvim_silinemedi);
      end;
      // Programdan Siliniyor
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from IMAJ where YERI=&yeri and YER_ID=&yer_id ',['&yeri', '&yer_id'],
         [41, AKT_ID]);
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PROJELER where Id=&id ',['&id'],[AKT_ID]);
      FTakvimProjeler.YenileTus.Click;


   Abort;
   end;
end;

procedure TTakvimProje.SchedulerDblClick(Sender: TObject);
begin
  if Scheduler.CurrentView.HitTest.Event <> nil then
    BilgileriDegisMenu.Click
  else
    ButariheProjeekle.Click;
end;

procedure TTakvimProje.SetFrameBilgi(AValue: TIcerikFrameBilgi);
begin
  FFrameBilgi := AValue;
end;

procedure TTakvimProje.TusAsagi(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TTakvimProje.TusBasili(Sender: TObject; var Key: Char);
begin

end;

procedure TTakvimProje.TusYukari(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

function TTakvimProje.YazdirmaAktifMi: Boolean;
begin
  Result := False;
end;

procedure TTakvimProje.YaziciYazdir(Sender: TObject);
begin

end;

procedure TTakvimProje.YenileTusClick(Sender: TObject);
var s, tarih : String[100];
  function AramaKriterleri(BasBit:string) : string;
  begin
   Result:='';

    if FTakvimProjeler.checkTarih.Checked then begin
     Result:= Result+ ' AND P.'+BasBit+' >= '''+FormatDateTime('yyyy-mm-dd 00:00',FTakvimProjeler.dateProjeBaslangic.Date) +''' ';
     Result:= Result+'  AND P.'+BasBit+' <= '''+FormatDateTime('yyyy-mm-dd 23:59',FTakvimProjeler.dateProjeBitis.Date) +''' ';
    end;

    if StringReplace(FTakvimProjeler.AraFirma.Text,' ','',[rfReplaceAll])<>'' then
     Result:= Result+' AND ISNULL(R1.FIRMA,'''') LIKE ''%'+FTakvimProjeler.AraFirma.Text+'%'' ';
    if StringReplace(FTakvimProjeler.editSorumlu.Text,' ','',[rfReplaceAll])<>'' then
     Result:= Result+' AND PRJ_SORUMLUSU_ID IN ( '+FTakvimProjeler.editSorumlu.Text+') ';
    if StringReplace(FTakvimProjeler.AraYetkili.Text,' ','',[rfReplaceAll])<>'' then
     Result:= Result+' AND ISNULL(RP.ADSOYAD,'''') LIKE ''%'+FTakvimProjeler.AraYetkili.Text+'%'' ';
    if StringReplace(FTakvimProjeler.ComboKonusu.Text,' ','',[rfReplaceAll])<>'' then
     Result:= Result+' AND ISNULL(P.KONUSU,'''') LIKE ''%'+FTakvimProjeler.ComboKonusu.Text+'%'' ';
    if FTakvimProjeler.ComboTuru.EditValue>0 then
     Result:= Result+' AND P.TURU ='+VarToStr(FTakvimProjeler.ComboTuru.EditValue)+' ';
    if FTakvimProjeler.ComboTipi.EditValue>0 then
     Result:= Result+' AND P.TIPI ='+VarToStr(FTakvimProjeler.ComboTipi.EditValue)+' ';
    if FTakvimProjeler.comboAsama.EditValue>0 then
     Result:= Result+' AND P.ASAMA='+VarToStr(FTakvimProjeler.comboAsama.EditValue)+'';
    if FTakvimProjeler.comboSonuc.EditValue>0 then
     Result:= Result+' AND P.SONUC='+VarToStr(FTakvimProjeler.comboSonuc.EditValue)+'';

    if not(FTakvimProjeler.checkKapaliGoster.Checked) then
     Result:= Result+' AND P.DURUM <> 2 ';

  end;
begin

Query1.Close;
   AraQuery1.SQL.Text:= MemoPlanSQL.Text+ ' '+ MemoBaslangic.Text+' '+ AramaKriterleri('BASLAMATARIHI') + ' '+ MemoBitis.Text+' '+ AramaKriterleri('BITISTARIHI') ;
   //AraQuery1.SQL.Text:= MemoPlanSQL.Text+ ' '+ MemoBaslangic.Text+' '+ AramaKriterleri('BASLAMATARIHI') + ' ';
   AraQuery1.SQL.Add('  ORDER BY 2 select * from ##Proje_SPID_ ');
   AraQuery1.SQL.Text := StringReplace(AraQuery1.SQL.Text, 'SPID', IntToStr(SPID), [RFrEPLACEaLL]) ;
   //AraQuery1.SQL.Text:=StringReplace(AraQuery1.SQL.Text,'@PERSONEL',Kullanan,[rfReplaceAll]);
   TabloYenile(AraQuery1, [Kullanan, SubeId]); //MemoBitis
end;

initialization
  RegisterClass(TTakvimProje);
end.



