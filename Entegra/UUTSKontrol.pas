unit UUTSKontrol;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, cxGrid,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLiquidSky, dxSkinscxPCPainter, FireDAC.Comp.Client, cxEdit,
  cxCustomData, cxGraphics, cxFilter, cxClasses, cxDataStorage, cxDBData, ExtCtrls,
  cxGridTableView, cxControls, cxData, DB, cxGridLevel, cxGridCustomView, cxGridCustomTableView,
  cxGridDBTableView, cxContainer, cxLabel, StdCtrls, Buttons, ComCtrls, ToolWin, FetaKurulusSiniflari,
  dxSkinLondonLiquidSky, cxTextEdit, cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, cxCheckBox,
  Vcl.Menus, PrjConst, JvTimer, cxCurrencyEdit, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, cxCalendar,
  cxMaskEdit, cxDropDownEdit, cxImageComboBox, dxDateRanges,
  dxScrollbarAnnotations;

type
  TUTSKontrolDlg = class(TForm)
    GridUTSKontrolView: TcxGridDBTableView;
    GridUTSKontrolLevel1: TcxGridLevel;
    GridUTSKontrol: TcxGrid;
    PanelAlt: TPanel;
    TabUTSKontrol: TFDQuery;
    DtsUTSKontrol: TDataSource;
    GridUTSKontrolViewSERINO: TcxGridDBColumn;
    ToolBar5: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetBtn: TToolButton;
    IptalBtn: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Panel1: TPanel;
    GridUTSKontrolViewLOTNO: TcxGridDBColumn;
    GridUTSKontrolViewSKT: TcxGridDBColumn;
    SQLCikanUpdate: TMemo;
    GridUTSKontrolViewURT: TcxGridDBColumn;
    BtnTopluSerino: TToolButton;
    PopupSeriNo: TPopupMenu;
    Listedentoplualma1: TMenuItem;
    N1: TMenuItem;
    Balamabitivererek1: TMenuItem;
    GridUTSKontrolViewID: TcxGridDBColumn;
    BtnLotNoVer: TToolButton;
    CancelBtn: TBitBtn;
    UTSKontrolBtn: TBitBtn;
    GridUTSKontrolViewTARIH: TcxGridDBColumn;
    GridUTSKontrolViewUNO: TcxGridDBColumn;
    GridUTSKontrolViewKOD: TcxGridDBColumn;
    GridUTSKontrolViewAD: TcxGridDBColumn;
    GridUTSKontrolViewADET: TcxGridDBColumn;
    GridUTSKontrolViewGELENADET: TcxGridDBColumn;
    GridUTSKontrolViewASKIADET: TcxGridDBColumn;
    GridUTSKontrolViewACIKADET: TcxGridDBColumn;
    GridUTSKontrolViewGELENURT: TcxGridDBColumn;
    GridUTSKontrolViewGELENSKT: TcxGridDBColumn;
    GridUTSKontrolViewSONUC: TcxGridDBColumn;
    GridUTSKontrolViewEKLEYEN: TcxGridDBColumn;
    LabelKontrolTarihi: TcxLabel;
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridUTSKontrolViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FormShow(Sender: TObject);
    procedure UTSKontrolBtnClick(Sender: TObject);
    procedure TabUTSKontrolAfterOpen(DataSet: TDataSet);
  private
    { Private declarations }
    procedure UTSdenAdetKontrol;
  public
    { Public declarations }
    BaslikID:Integer;
    KontrolUygun : Boolean;
  end;

var
  UTSKontrolDlg: TUTSKontrolDlg;
  TabloAdi:string;

implementation

uses UGirisKutusuEx,Utablo,LocOnfly,FetaUtil, UAnaForm, Models, RestUTS;

VAR
 UTSFirmaNo : string;

{$R *.dfm}


procedure TUTSKontrolDlg.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TUTSKontrolDlg.GridUTSKontrolViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridUTSKontrol;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridUTSKontrolView;
  //AnaForm.pmGridStil.Tags.Values[GridFatIzlem.Name]:='GridFatIzlemGridi';
end;

procedure TUTSKontrolDlg.TabUTSKontrolAfterOpen(DataSet: TDataSet);
begin
   if TabUTSKontrol.FieldByName('DEGISTIREN').AsString<>'' then
      LabelKontrolTarihi.Caption := 'Kontrol Tarihi : '+FormatDateTime('dd/mm/yyyy hh:nn', TabUTSKontrol.FieldByName('DEGISTIRMETARIHI').AsDateTime)
   else
      LabelKontrolTarihi.Caption := 'Kontrol Tarihi : --';
   GridUTSKontrolView.ApplyBestFit(nil)
end;

procedure TUTSKontrolDlg.UTSdenAdetKontrol;
var
	       k : TUrunSonuc;
         aski : TAskiSonuc;
         i,j,n,GelenAdet,AskiAdet,Sonuc : Integer;
         Adres,GelenURT,GelenSKT : string;
    procedure Sorgula(BildirimTur:Integer);
    var
       TMU : TM_Verme;   //TM_Urun;
    begin
        TMU := TM_Verme.Create; ///TM_Urun.Create;
        TMU.UNO := TabUTSKontrol.FieldByName('UNO').AsString;//'08680734652908';//EditUNO.Text;
        TMU.LNO := TabUTSKontrol.FieldByName('LOTNO').AsString;//'231316';//EditLNO.Text;
        TMU.SNO := '';//EditSNO.Text;
        Tablo.TablodanSorguAc(1,'  select ADRESSORGU from [UTS_BILDIRIM_TUR] where ID='+IntToStr(BildirimTur));
        Adres := Tablo.Query1.Fields[0].AsString;  //  utsServer

        case BildirimTur of
        45 : begin //tekil sorgu
                 k := TUrunSonuc(utsTalkMC(Adres, //'/UTS/uh/rest/bildirim/alma/bekleyenler/sorgula',
                                  TMU, TUrunSonuc));         //     TModel.Create
                 if k = nil then raise Exception.Create('Okunamadı');
             end;
        52 : begin
                 //TMU.KUN := UTSFirmaNo;
                 TMU.ADT := 100;
                 aski := TAskiSonuc(utsTalkMC(Adres, TMU, TAskiSonuc)); //askı sorgu
             end;
        end;
        //TMU.Free;
    end;

begin
        Sorgula(45);//tekil ürün sorgusu
        GelenAdet := 0;
        AskiAdet := 0;
        n := length(k.SNC);
        if n > 0 then begin
           GelenURT := k.SNC[i].URT;
           GelenSKT := k.SNC[i].SKT;


           for j := 0 to n-1 do
                 GelenAdet := GelenAdet + k.SNC[j].ADT;
        //
           Sorgula(52);//giden askı sorgusu
           n := length(aski.SNC.LST);

           if n > 0 then
              for j := 0 to n-1 do
                 AskiAdet := AskiAdet + aski.SNC.LST[j].ADT;
        end;
        if TabUTSKontrol.FieldByName('ADET').AsInteger > (GelenAdet - AskiAdet) then
           Sonuc:=0
        else Sonuc:=1;

        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSKONTROL set GELENADET='+ IntToStr(GelenAdet)+ ',ASKIADET = '+ IntToStr(AskiAdet)+
            ', ACIKADET ='+IntToStr(GelenAdet - AskiAdet) +', GELENURT = '''+ GelenURT+ ''', GELENSKT = '''+GelenSKT +''', SONUC='+IntToStr(Sonuc)+
            ', DEGISTIREN='+Kullanan+', DEGISTIRMETARIHI=getdate() where ID='+TabUTSKontrol.FieldByName('ID').AsString,[],[]);



       // Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update UTSKONTROL set ASKIADET = '+ IntToStr(Adet) + ', ACIKADET =' +
       //     TabUTSKontrol.FieldByName('GELENADET').AsInteger-TabUTSKontrol.FieldByName('ASKIADET').AsInteger;
end;

procedure TUTSKontrolDlg.UTSKontrolBtnClick(Sender: TObject);
begin
   if TabUTSKontrol.FieldByName('DEGISTIREN').AsString <>'' then begin
       if Application.MessageBox(PChar(DahaOnceKontrolEdilmis+' '+Devam_Etmek), PChar(Uyari),  MB_YESNO)=ID_NO then
          exit;
   end;

   RestUts.utsToken   := Tablo.GENINI.ReadString(Ops_EditUTSToken,'');
   UTSFirmaNo := Tablo.GENINI.ReadString(Ops_EditUTSFirmaNo,'');
   //;// ;
   if Tablo.GENINI.ReadBoolean(Ops_CheckTest,False)=True then
      RestUts.utsServer :=  TEST_UTS_SERVER
   else
      RestUts.utsServer := MAIN_UTS_SERVER;

  TabUTSKontrol.First;
   while not TabUTSKontrol.eof do begin
      UTSdenAdetKontrol;
      TabUTSKontrol.next;
   end;
   TabloYenile(TabUTSKontrol,[BaslikID]);
end;

procedure TUTSKontrolDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  Tablo.GridAyarRestore('GridUTSKontrolGridi', GridUTSKontrolView);
end;

procedure TUTSKontrolDlg.FormDestroy(Sender: TObject);
begin
//    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where STOKID=&StkID and BASLIKID=&BlgID and SATIRID=&StrID',['&StkID','&BlgID','&StrID'],[StokID,BaslikID,SatirID]);
end;

procedure TUTSKontrolDlg.FormShow(Sender: TObject);
   procedure Ekle;
   begin
           Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into UTSKONTROL (TARIH, IZLEMID, EKLEYEN, EKLEMETARIHI) '+
                     ' select TARIH=getdate(), SI.ID,'+Kullanan+', getdate() from STOKIZLEME SI '+
                     ' where SI.BASLIKID='+IntToStr(BaslikID)+' order by SI.ID ',[],[])
   end;
begin
//  yoksa insert edelim
   //UTSKontrolBtn.Enabled := KontrolUygun;
   //ilk iş burada kontrol satırları var mı diye bakıyoruz
   Tablo.TablodanSorguAc(1, 'Select * from UTSKONTROL UK inner join STOKIZLEME SI on SI.ID = UK.IZLEMID where BASLIKID='+IntToStr(BaslikID));
   if Tablo.Query1.RecordCount< 1 then
      //hiç satır yoksa ekliyoruz
      Ekle
   else begin//varsa satır sayısında değişiklik var mı? diye nakıyoruz
      Tablo.TablodanSorguAc(2,'select count(*) from STOKIZLEME SI where SI.BASLIKID='+IntToStr(BaslikID));
      if Tablo.Query2.Fields[0].AsInteger <> Tablo.Query1.RecordCount then begin
         Showmessage('Satır sayısı değişmiş.. Güncelleme yapılacaktır..');
         Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete UTSKONTROL from UTSKONTROL UK inner join STOKIZLEME SI on SI.ID = UK.IZLEMID where BASLIKID='+IntToStr(BaslikID),[],[]);
         Ekle;
      end;
   end;
   TabloYenile(TabUTSKontrol,[BaslikID]);
end;

end.



