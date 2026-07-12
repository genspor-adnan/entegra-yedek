unit UIzleme;

interface

uses
  Windows, Messages, SysUtils,  System.DateUtils, Variants, Classes, Graphics, Controls, Forms, cxGrid,
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
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TIzlemeDlg = class(TForm)
    GridFatIzlemView: TcxGridDBTableView;
    GridFatIzlemLevel1: TcxGridLevel;
    GridFatIzlem: TcxGrid;
    PanelAlt: TPanel;
    TabIzlem: TFDQuery;
    DtsIzlem: TDataSource;
    GridFatIzlemViewSERINO: TcxGridDBColumn;
    GridFatIzlemViewMIKTAR: TcxGridDBColumn;
    KaydetTus: TBitBtn;
    CancelBtn: TBitBtn;
    GridFatIzlemViewDURUM: TcxGridDBColumn;
    ToolBar5: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    GridFatIzlemViewSEC: TcxGridDBColumn;
    KaydetBtn: TToolButton;
    IptalBtn: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    Panel1: TPanel;
    LblGerekliMiktar: TcxLabel;
    LblSecilenMiktar: TcxLabel;
    GridFatIzlemViewLOTNO: TcxGridDBColumn;
    GridFatIzlemViewSKT: TcxGridDBColumn;
    ChecktumKayitlar: TcxCheckBox;
    EditAra: TcxTextEdit;
    cxLabel1: TcxLabel;
    SQLGiren: TMemo;
    SQLDonusKaynak: TMemo;
    SQLCikanUpdate: TMemo;
    GridFatIzlemViewURT: TcxGridDBColumn;
    SQLDonusCikanHedef_2: TMemo;
    SQLDonusCikanHedefUpdate: TMemo;
    SQLCikan: TMemo;
    EditBarkod: TcxTextEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    ComboBarkod: TcxImageComboBox;
    BtnTopluSerino: TToolButton;
    Memo1: TMemo;
    PopupSeriNo: TPopupMenu;
    Listedentoplualma1: TMenuItem;
    N1: TMenuItem;
    Balamabitivererek1: TMenuItem;
    LabelSec: TcxLabel;
    cxLabel5: TcxLabel;
    GridFatIzlemViewID: TcxGridDBColumn;
    LblKalanMiktar: TcxLabel;
    SQLDonusCikanHedef: TMemo;
    BtnLotNoVer: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure TabIzlemNewRecord(DataSet: TDataSet);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure TabIzlemAfterPost(DataSet: TDataSet);
    Procedure BarkoddanMiktarGetir;
    function YeniBoyutOlustur(StokID:integer;Boyut1,Boyut2,Boyut3:string):integer;
    function BoyutDegeriGetir(Bolum:integer;Anahtar:string):integer;
    procedure DtsIzlemStateChange(Sender: TObject);
    procedure KaydetBtnClick(Sender: TObject);
    procedure IptalBtnClick(Sender: TObject);
    procedure GridFatIzlemViewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TabIzlemBeforePost(DataSet: TDataSet);
    procedure ChecktumKayitlarPropertiesEditValueChanged(Sender: TObject);
    procedure EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditAraPropertiesEditValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridFatIzlemViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure TabIzlemAfterOpen(DataSet: TDataSet);
    procedure TabIzlemAfterDelete(DataSet: TDataSet);
    procedure FormDestroy(Sender: TObject);
    procedure TabIzlemBeforeDelete(DataSet: TDataSet);
    procedure TabIzlemBeforeEdit(DataSet: TDataSet);
    procedure cxLabel1DblClick(Sender: TObject);
    procedure ComboBarkodPropertiesInitPopup(Sender: TObject);
    procedure EditBarkodKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBarkodPropertiesCloseUp(Sender: TObject);
    procedure Listedentoplualma1Click(Sender: TObject);
    procedure Balamabitivererek1Click(Sender: TObject);
    procedure GridFatIzlemViewCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridFatIzlemViewSECPropertiesChange(Sender: TObject);
    procedure LabelSecClick(Sender: TObject);
    procedure BtnLotNoVerClick(Sender: TObject);
    procedure GridFatIzlemViewCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure LblKalanMiktarClick(Sender: TObject);
  private
    Kaydedilebilir : boolean;
    procedure TempTabloOlustur;
    function BuSeriNoKullanilmismiKontrolu(IzlemNo:string) : Boolean;
    { Private declarations }
    procedure SayiGetir;
  public
    { Public declarations }
    StokID,IzlemTur,IslemTur,IslemTip,BaslikID,SatirID, KaynakBaslikID, KaynakSatirID, RehberId,GirDepo,CikDepo:Integer;
    GerekliMiktar,KALAN : real;
    UretimNo : string;
    IslemOp:char;
    DonusumHedef, DonusumKaynak, Degisemez, StokDurumDegis : Boolean;
    //IzlemAktif:boolean;
    Barkod:String;
  end;

var
  IzlemeDlg: TIzlemeDlg;
  TabloAdi:string;

implementation

uses UVeriMotor,UGirisKutusuEx,Utablo,LocOnfly,FetaUtil, UAnaForm;



{$R *.dfm}

var OncekiIzlem : string;
const
izl_Yok = 0;
izl_SeriNo = 1;
izl_LotNo = 2;
izl_SKT = 3;
izl_Karekod = 4;
izl_LotNo_SKT = 5;
izl_SeriNo_LotNo =6;

var     Bas,Bit : Int64;
  KalanMiktar : real;

procedure TIzlemeDlg.FormShow(Sender: TObject);
var
  MenuItem:TMenuItem;
begin
  GridFatIzlemView.OptionsData.editing := not Degisemez;
  KaydetTus.Enabled := not Degisemez;

  ComboBarkod.Tag := StrToIntDef(GenRegIni.RegReadString('IzlemBarkodTipi', 'DefaultBarkodId',  '1','C'),0);
  ComboBarkod.EditValue := ComboBarkod.Tag;
  //  ComboBarkod.Text := GenRegIni.RegReadString('IzlemBarkodTipi', 'DefaultBarkodAd',  '0','C');


  TempTabloOlustur;

  LblGerekliMiktar.Caption := ' Gerekli Miktar: ' + FloatToStr(GerekliMiktar);

  //serinolarda adet sabit 1 olmalı, değişemez
  GridFatIzlemViewMIKTAR.Options.Editing :=  IzlemTur <> 1;

  GridFatIzlemViewSERINO.Visible := IzlemTur in [izl_SeriNo, izl_Karekod, izl_SeriNo_LotNo];
  GridFatIzlemViewLOTNO.Visible := IzlemTur in [izl_LotNo, izl_LotNo_SKT, izl_SeriNo_LotNo];
  GridFatIzlemViewSKT.Visible := IzlemTur in [izl_SeriNo, izl_SKT, izl_LotNo_SKT]; //izl_SeriNo, AO 10/05/21  kaldırmıştık geri ekledik
  GridFatIzlemViewURT.Visible := (GridFatIzlemViewSKT.Visible) or (IzlemTur=izl_LotNo);
  GridFatIzlemViewMIKTAR.Visible := IzlemTur in [izl_LotNo,izl_SKT, izl_LotNo_SKT];
  GridFatIzlemViewDURUM.Visible := (DonusumKaynak)or(KaynakSatirID>0)or((IzlemTur in [izl_LotNo, izl_SKT, izl_LotNo_SKT])and( IslemTur in [KasaTur_DigerCikisFisi,
                                                                               KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,KasaTur_Giden_Konsinye,
                                                                               KasaTur_StokSayimIslemi, KasaTur_StokTransferi, KasaTur_Uretim_Sarf]));//yenigiriş
  GridFatIzlemViewSEC.Visible := (KaynakSatirID>0)or( IslemTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,
                                                                      KasaTur_Giden_Konsinye, KasaTur_StokTransferi, KasaTur_Uretim_Sarf]); //stok sayımında seçim yok

//  GridFatIzlemViewSERINO.Options.Editing := (GridFatIzlemViewSERINO.Visible)and( not GridFatIzlemViewDURUM.Visible);
//  GridFatIzlemViewLOTNO.Options.Editing := (GridFatIzlemViewLOTNO.Visible)and(not GridFatIzlemViewDURUM.Visible);
//  GridFatIzlemViewSKT.Options.Editing:= (GridFatIzlemViewSKT.Visible)and(not GridFatIzlemViewDURUM.Visible);
// üretim veya sayım ise giriş yapılabilir
  GridFatIzlemViewSERINO.Options.Editing := ((not GridFatIzlemViewDURUM.Visible)and(not GridFatIzlemViewSEC.Visible)) or (IslemTur = 99);
  GridFatIzlemViewLOTNO.Options.Editing  := GridFatIzlemViewSERINO.Options.Editing;
  if tabizlem.state <> dsInsert then begin
     GridFatIzlemViewSKT.Options.Editing    := False;  //GridFatIzlemViewSERINO.Options.Editing;
     GridFatIzlemViewURT.Options.Editing    := False;  //GridFatIzlemViewSERINO.Options.Editing;
  end;
  if IzlemTur=izl_SeriNo then  //Serino
     GridFatIzlemViewSERINO.Caption := 'Serino'
   else if IzlemTur=izl_Karekod then  //Karekod
     GridFatIzlemViewSERINO.Caption := 'Karekod';

  //seçim kolonu varsa ekle sil butonları görünmez
  EkleTus.visible := not GridFatIzlemViewSEC.Visible;
  SilTus.visible := EkleTus.visible;
  BtnTopluSerino.visible := not GridFatIzlemViewSEC.Visible;
  //satır ekleme yada silmeyi istemediğimiz durumlar..
  (*if IslemTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,KasaTur_Uretim_Urun,KasaTur_StokTransferi,119] then begin
    if IzlemTur=4 then begin
      EkleTus.Visible := False;
      SilTus.Visible := False;
      GridFatIzlemView.OptionsData.Appending := False;
      GridFatIzlemView.OptionsData.Deleting := False;
    end else if IzlemTur=2 then begin
      ChecktumKayitlar.Visible := True;
    end;
  end; *)

  BtnLotNoVer.enabled := UretimNo<>'0';
  if BtnLotNoVer.enabled then
     Caption := Urun
  else
     Caption := Sarf;

  if GridFatIzlemViewDURUM.Visible then
     //TcxCurrencyEditProperties(GridFatIzlemViewDURUM).DecimalPlaces := OndalikDijitSayMik;
     Tablo.OndalikKisimAyarla(GridFatIzlemViewDURUM, OndalikDijitSayMik);
  Caption := Caption + ' : ' +Tablo.AciklamaGetir('STOKLAR','KOD+'' ''+STOKADI',StokID)+' '+Caption;
  BarkoddanMiktarGetir;

end;

(*procedure TIzlemeDlg.TempTabloOlustur;
var s:String;
begin
  TabloAdi := '##TmpIzleme_'+IntToStr(SPID)+'_'+FormatDateTime('yyyymmddhhnnsszzz',Tablo.GENINI.BugunTrhSaat);
  TabIzlem.SQL.Text := 'create table '+TabloAdi+'(';
  TabIzlem.SQL.Add('[ID] [int] IDENTITY(1,1) NOT NULL,');
  TabIzlem.SQL.Add('[STOKID] [int] NOT NULL,');
  TabIzlem.SQL.Add('[SERINO] [nvarchar](64) NULL,');
  TabIzlem.SQL.Add('[IZLEMID] [int] NULL,');
  TabIzlem.SQL.Add('[DURUM] [float] NULL,');
  TabIzlem.SQL.Add('[KALAN] [float] NULL,');
  TabIzlem.SQL.Add('[SEC] [bit] NULL ,');
  TabIzlem.SQL.Add('[LOTNO] [nvarchar](50) NULL,');
  TabIzlem.SQL.Add('[SKT] datetime NULL)');
  TabIzlem.ExecSQL;

  TabIzlem.SQL.Text := 'declare @StokID int, @BaslikTur int, @BaslikID int, @SatirID int, @GirDepoID int, @CikDepoID int, @Dil int, @RehberId int, @IzlemTur int';
  TabIzlem.SQL.Add('set @StokID='+IntToStr(StokID));

  //Bakalım bu fatura ve irsaliyeden dönüştürülmüş ise irsaliye ID sinden izlemeaçılacak
  if IslemTur in [11,15] then begin
      Tablo.TablodanSorguAc(1,'select ID from FATBASLIK FB where FATURANO=(select IRSALIYENO from FATBASLIK where ID='+IntToStr(BaslikID)+') and TUR=10');
      if Tablo.Query1.RecordCount > 0 then begin
         BaslikID:=StrToIntDef(Tablo.Query1.Fields[0].AsString,0);
         Tablo.TablodanSorguAc(1,'select YERID from FATURA where ID='+IntToStr(SatirID));
         SatirID :=StrToIntDef(Tablo.Query1.Fields[0].AsString,0);
         IslemTur:= IslemTur-1;
      end;
  end;

  TabIzlem.SQL.Add('set @BaslikTur='+IntToStr(IslemTur));
  TabIzlem.SQL.Add('set @BaslikID='+IntToStr(BaslikID));
  TabIzlem.SQL.Add('set @SatirID='+IntToStr(SatirID));
  TabIzlem.SQL.Add('set @GirDepoID='+IntToStr(GirDepo));
  TabIzlem.SQL.Add('set @CikDepoID='+IntToStr(CikDepo));
  TabIzlem.SQL.Add('set @Dil='+IntToStr(Dil));
  TabIzlem.SQL.Add('set @RehberId='+IntToStr(RehberId));
  TabIzlem.SQL.Add('set @IzlemTur='+IntToStr(IzlemTur));
  TabIzlem.SQL.Add('insert into '+TabloAdi);
  TabIzlem.SQL.Add('(STOKID,SERINO,IZLEMID,DURUM,KALAN,SEC,LOTNO,SKT)');
  case IzlemTur of
    izl_SeriNo, izl_Karekod, izl_SeriNo_LotNo:begin //Serino Karekod
      if IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,KasaTur_Uretim_Urun,109] then begin
        TabIzlem.SQL.Add(MemoSerinoGir.Lines.Text)
      end else begin
        TabIzlem.SQL.Add(MemoSerinoCik.Lines.Text);
        if GridFatIzlemViewMIKTAR.Properties <> nil then
           GridFatIzlemViewMIKTAR.Properties.ReadOnly := True;
      end;
    end;
    izl_LotNo, izl_SKT, izl_LotNo_SKT :begin //SKT
      if IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,KasaTur_Uretim_Urun,109] then begin
         if IslemTip = 2 then //İade ise
            s := ' and FB.REHBERID=@RehberId'
         else //normal giriş
            s := ' and SI1.BELGETUR=@BaslikTur and SI1.BASLIKID=@BaslikID and SI1.SATIRID=@SatirID ';
         TabIzlem.SQL.Add(StringReplace( MemoSKTGir.Lines.Text, '--AraSatir', s, []));
      end else begin
        if ChecktumKayitlar.Checked = False then begin
           TabIzlem.SQL.Add(StringReplace(MemoSKTCik.Lines.Text,'--having','having',[]));
        end else if ChecktumKayitlar.Checked = True then begin
           TabIzlem.SQL.Add(StringReplace(MemoSKTCik.Lines.Text,'having','--having',[]));
        end;
      end;
    end;
    {4:begin //Boyut
      if IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,KasaTur_Uretim_Urun,109] then begin
        TabIzlem.SQL.Add(MemoBoyutGir.Lines.Text);
      end else begin
        TabIzlem.SQL.Add(MemoBoyutCik.Lines.Text);
      end;
    end; }
  end;
  if not IzlemAktif then begin
    TabIzlem.SQL.Text := StringReplace(TabIzlem.SQL.Text,'SI.DURUM=1 and',' ',[rfReplaceAll]);
    TabIzlem.SQL.Text := StringReplace(TabIzlem.SQL.Text,'SI1.DURUM=1 and',' ',[rfReplaceAll]);
    TabIzlem.SQL.Text := StringReplace(TabIzlem.SQL.Text,'SI2.DURUM=1 and',' ',[rfReplaceAll]);
    TabIzlem.SQL.Text := StringReplace(TabIzlem.SQL.Text,'SI3.DURUM=1 and',' ',[rfReplaceAll]);
  end;
  TabIzlem.ExecSQL;

  if IslemTur=KasaTur_StokSayimIslemi then //99 ise hepsini işaretleyelim tüm satırların şu anki değerlerini girsinler
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update '+TabloAdi+' set SEC=1' ,[],[]);

  TabIzlem.SQL.Text := 'select * from '+TabloAdi;
  TabIzlem.Open;
  case TabIzlem.RecordCount of
    0 : TabIzlem.Append;
    1 : begin//tek kayıt varsaişaretleyelim
         TabIzlem.Edit;
         TabIzlem.FieldByName('SEC').AsBoolean := True;
         TabIzlem.Post
      end;
  end;
  //

end;   *)
procedure TIzlemeDlg.TempTabloOlustur;
var s, KomutDeclare, KomutInsert:String;
begin
  TabloAdi := '##TmpIzleme_'+IntToStr(SPID)+'_'+FormatDateTime('yyyymmddhhnnsszzz',Tablo.GENINI.BugunTrhSaat);
  TabIzlem.SQL.Text := 'create table '+TabloAdi+'(';
  TabIzlem.SQL.Add('[ID] [int] IDENTITY(1,1) NOT NULL,');
  TabIzlem.SQL.Add('[STOKID] [int] NOT NULL,');
  TabIzlem.SQL.Add('[SERINO] [nvarchar](64) NULL,');
  TabIzlem.SQL.Add('[DURUM] [float] NULL,');
  TabIzlem.SQL.Add('[KALAN] [float] NULL,');
  TabIzlem.SQL.Add('[SEC] [bit] NULL ,');
  TabIzlem.SQL.Add('[LOTNO] [nvarchar](50) NULL,');
  TabIzlem.SQL.Add('[SKT] datetime NULL,');
  TabIzlem.SQL.Add('[URT] datetime NULL,');
  TabIzlem.SQL.Add('[IZLEMID] [int] NULL,');
  TabIzlem.SQL.Add('[BASLIKID] [int] NULL,');
  TabIzlem.SQL.Add('[SATIRID] [int] NULL,');
  TabIzlem.SQL.Add('[UPDID] [int] NULL,');
  TabIzlem.SQL.Add('SERILOTID [int] NULL)');
  TabIzlem.ExecSQL;

//  KomutDeclare := ' declare @StokID int, @BaslikTur int, @BaslikID int, @SatirID int, @GirDepoID int, @CikDepoID int, @Dil int, @RehberId int, @IzlemTur int'+
  KomutDeclare := ' declare @StokID int, @BaslikTur int, @BaslikID int, @SatirID int, @RehberId int, @IzlemTur int, @DepoID int '+
                 ' set @StokID='+IntToStr(StokID)+

  //Bakalım bu fatura ve irsaliyeden dönüştürülmüş ise irsaliye ID sinden izlemeaçılacak
{  if IslemTur in [11,15] then begin
      Tablo.TablodanSorguAc(1,'select ID from FATBASLIK FB where FATURANO=(select IRSALIYENO from FATBASLIK where ID='+IntToStr(BaslikID)+') and TUR=10');
      if Tablo.Query1.RecordCount > 0 then begin
         BaslikID:=StrToIntDef(Tablo.Query1.Fields[0].AsString,0);
         Tablo.TablodanSorguAc(1,'select YERID from FATURA where ID='+IntToStr(SatirID));
         SatirID :=StrToIntDef(Tablo.Query1.Fields[0].AsString,0);
         IslemTur:= IslemTur-1;
      end;
  end; }

  ' set @BaslikTur='+IntToStr(IslemTur)+
  ' set @BaslikID='+IntToStr(BaslikID)+
  ' set @SatirID='+IntToStr(SatirID)+
//  ' set @GirDepoID='+IntToStr(GirDepo)+
//  ' set @CikDepoID='+IntToStr(CikDepo)+
//  ' set @Dil='+IntToStr(Dil)+

  ' set @RehberId='+IntToStr(RehberId)+
  ' set @IzlemTur='+IntToStr(IzlemTur);
  if (IslemTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,KasaTur_Giden_Konsinye,KasaTur_StokSayimIslemi,KasaTur_Uretim_Sarf, KasaTur_StokTransferi]) then
     KomutDeclare:=KomutDeclare+' set @DepoID='+IntToStr(CikDepo)
  else
     KomutDeclare:=KomutDeclare+' set @DepoID='+IntToStr(GirDepo);
{  KomutInsert := ' insert into '+TabloAdi+ ' (STOKID,SERINO,DURUM,KALAN,SEC,LOTNO,SKT)';

  //üretim, irs ve fat giriş ise satır boş gelir
  if IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,KasaTur_Uretim_Urun, KasaTur_StokSayimIslemi] then
     KomutInsert := KomutInsert+' select * from (SELECT STOKID,SERINO,DURUM,KALAN=SUM(KALAN),SEC=1,LOTNO,SKT ')
  else
     KomutInsert := KomutInsert+' select * from (SELECT STOKID,SERINO,DURUM=SUM(KALAN),KALAN=0,SEC=0,LOTNO,SKT ');

  KomutInsert := KomutInsert + ' from STOKIZLEME SI1 where SI1.STOKID=@StokID and SI1.IZLEMTUR=@IzlemTur ');

  if IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,KasaTur_Uretim_Urun,KasaTur_StokSayimIslemi] then
    	KomutInsert := KomutInsert + 'and SI1.BELGETUR=@BaslikTur and SI1.BASLIKID=@BaslikID and SI1.SATIRID=@SatirID ');

  KomutInsert := KomutInsert + 'group by 	STOKID,SERINO,DURUM,LOTNO,SKT '+
                    ' ) as List where DURUM > 0 '); }
  if IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,KasaTur_Uretim,KasaTur_Uretim_Urun, KasaTur_Gelen_Konsinye] then begin
     //girişler
     if KaynakSatirID <= 0 then begin //direk giriş varsa
        {if (IslemTur = KasaTur_Gelen_Konsinye)and(IslemTip=2) then begin //konsinye iade alınırsa
           //KomutDeclare := ' declare @BaslikID int, @SatirID int set @BaslikID='+IntToStr(KaynakBaslikID)+ ' set @SatirID='+IntToStr(KaynakSatirID);
           TabIzlem.SQL.Text := KomutDeclare+' '+ StringReplace(SQLDonusCikanHedef.text, ':TabloAdi', TabloAdi, []);
           TabIzlem.ExecSQL;
        end
        else }if DonusumKaynak then begin
           TabIzlem.SQL.Text := KomutDeclare+ StringReplace(SQLDonusKaynak.text, ':TabloAdi', TabloAdi, []);
           TabIzlem.ExecSQL;
        end
        else begin        //Normal Çıkış belgesi (Kons.Çıkış veya İrsaliye çıkış veya Fatura Çıkış)
            TabIzlem.SQL.Text := KomutDeclare+ StringReplace(SQLGiren.text, ':TabloAdi', TabloAdi, []);
            TabIzlem.ExecSQL;
            Tablo.Query1.SQL.Text := KomutDeclare+' '+ StringReplace(SQLCikanUpdate.text, ':TabloAdi', TabloAdi, []);
            Tablo.Query1.ExecSQL;
         end
     end
     else begin //dönüşümden çıkış varsa, esas belgedeki izlemler gelmelidir
         KomutDeclare := ' declare @BaslikID int, @SatirID int set @BaslikID='+IntToStr(KaynakBaslikID)+ ' set @SatirID='+IntToStr(KaynakSatirID);
         TabIzlem.SQL.Text := KomutDeclare+' '+ StringReplace(SQLDonusCikanHedef.text, ':TabloAdi', TabloAdi, []);
         TabIzlem.ExecSQL;
         KomutDeclare := ' declare @SatirID int set @SatirID='+IntToStr(SatirID);
         Tablo.Query1.SQL.Text := KomutDeclare+' '+ StringReplace(SQLDonusCikanHedefUpdate.text, ':TabloAdi', TabloAdi, []);
         Tablo.Query1.ExecSQL;
     end;
  //çıkışlar
  end else begin
     if KaynakSatirID <= 0 then begin //direk çıkış varsa
        { if DonusumKaynak then begin //dönüşmüş belge (Kons.Çıkış veya İrsaliye çıkış) ise kaynak görüntülenir.
            TabIzlem.SQL.Text := KomutDeclare+' '+ StringReplace(SQLDonusKaynak.text, ':TabloAdi', TabloAdi, []);
            TabIzlem.ExecSQL;
         end else }
         begin        //Normal Çıkış belgesi (Kons.Çıkış veya İrsaliye çıkış veya Fatura Çıkış)
            TabIzlem.SQL.Text := KomutDeclare+ StringReplace(SQLCikan.text, ':TabloAdi', TabloAdi, []);
            TabIzlem.ExecSQL;
            Tablo.Query1.SQL.Text := KomutDeclare+' '+ StringReplace(SQLCikanUpdate.text, ':TabloAdi', TabloAdi, []);
            Tablo.Query1.ExecSQL;
         end
     end else begin //dönüşümden çıkış varsa, esas belgedeki izlemler gelmelidir
         KomutDeclare := ' declare @BaslikID int, @SatirID int set @BaslikID='+IntToStr(KaynakBaslikID)+ ' set @SatirID='+IntToStr(KaynakSatirID);
         TabIzlem.SQL.Text := KomutDeclare+' '+ StringReplace(SQLDonusCikanHedef.text, ':TabloAdi', TabloAdi, []);
         TabIzlem.ExecSQL;
         // 11/05/2022 AO kaldırıldı
         KomutDeclare := ' declare @SatirID int set @SatirID='+IntToStr(SatirID);
         Tablo.Query1.SQL.Text := KomutDeclare+' '+ StringReplace(SQLDonusCikanHedefUpdate.text, ':TabloAdi', TabloAdi, []);
         Tablo.Query1.ExecSQL;
     end;
  end;


  if IslemTur=KasaTur_StokSayimIslemi then //99 ise hepsini işaretleyelim tüm satırların şu anki değerlerini girsinler
     veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update '+TabloAdi+' set SEC=1' ,[],[]);

  TabIzlem.SQL.Text := 'select * from '+TabloAdi;

  TabIzlem.Open;
  case TabIzlem.RecordCount of
    0 : TabIzlem.Append;
   { 1 : begin//tek kayıt varsaişaretleyelim
         TabIzlem.Edit;
         TabIzlem.FieldByName('SEC').AsBoolean := True;
         TabIzlem.Post
      end;}
  end;
  //

end;

procedure TIzlemeDlg.KaydetTusClick(Sender: TObject);
  function CikisMiktarKontrolEt : boolean;
  var SeriLot : string;
  begin
    Result := True;
    if (GridFatIzlemViewSEC.Visible = False)or(IslemTur < 14) then
        exit;
    if IslemOp='D' then exit; //eğer faturada değişiklşk yapılıyorsa lotno miktarını kontrol etmesine gerek yok..
    //lot miktarını kontrol edelim..
    TabIzlem.First;
     while (Result)and( not TabIzlem.eof) do begin
        if TabIzlem.FieldByName('SEC').AsBoolean= True then begin
           //if TabIzlem.FieldByName('LOTNO').AsString<>'' then
           //   SeriLot := TabIzlem.FieldByName('LOTNO').AsString
           //else
           //   SeriLot := TabIzlem.FieldByName('SERINO').AsString;
           Tablo.TablodanSorguAc(1,'select * from STOKDURUMIZLEME SD where SD.STOKID='+TabIzlem.FieldByName('STOKID').AsString+
           ' and SERILOTID='''+TabIzlem.FieldByName('SERILOTID').AsString+''' and SD.DEPOID='+IntToStr(CikDepo));
           if Tablo.Query1.FieldByName('KALAN').AsFloat < TabIzlem.FieldByName('KALAN').AsFloat then begin
              showmessage(Yetersiz_Miktar);
              Result:=False;
           end;
        end;
        TabIzlem.Next;
     end;
  end;
begin
  if TabIzlem.State in [dsEdit,dsInsert] then
     TabIzlem.Post;
  if (KaydetTus.Enabled)and(CikisMiktarKontrolEt) then begin
     Tablo.TablodanSorguAc(2,'select sum(KALAN) from '+TabloAdi+' where SEC=1');
     KALAN := Tablo.Query2.Fields[0].AsFloat;
     //before post olayında serino bilgileri alınıyor
     //after post olayında destroy edip Kaydetme (STOKIZLEM tablosuna) gerçekleşiyor
     Kaydedilebilir := True;
     ModalResult := MrOk;
  end;
end;

procedure TIzlemeDlg.CancelBtnClick(Sender: TObject);
begin
  Kaydedilebilir :=False;
  ModalResult := mrCancel;
end;

procedure TIzlemeDlg.ChecktumKayitlarPropertiesEditValueChanged(Sender: TObject);
begin
  ChecktumKayitlar.PostEditValue;
  TempTabloOlustur;
end;

procedure TIzlemeDlg.ComboBarkodPropertiesCloseUp(Sender: TObject);
begin
   ComboBarkod.Tag := ComboBarkod.editvalue;
   GenRegIni.RegWriteString('IzlemBarkodTipi', 'DefaultBarkodId',  IntToStr(ComboBarkod.editvalue),'C');
   GenRegIni.RegWriteString('IzlemBarkodTipi', 'DefaultBarkodAd',  ComboBarkod.Text,'C');
end;

procedure TIzlemeDlg.ComboBarkodPropertiesInitPopup(Sender: TObject);
begin
  //Tablo.TablodanSorguAc(1,'select distinct BA.ID,BA.AD,BA.BASLANGIC from (select ID=0,AD=''Kullanıcı'',BASLANGIC='''' union all select ID,AD,BASLANGIC from BARKODAYARLAR) BA inner join STOKBARKOD SB on SB.BARKODTIPI=BA.ID where SB.STOKID='+IntToStr(StokID));
  {Tablo.TablodanSorguAc(1,'select distinct BA.ID,BA.AD,BA.BASLANGIC from (select ID=0,AD=''Kullanıcı'',BASLANGIC='''' union all select ID,AD,BASLANGIC from BARKODAYARLAR) BA  ');
  if Tablo.Query1.RecordCount>0 then begin
    Tablo.Query1.First;
    while not Tablo.Query1.Eof do begin
      {MenuItem := TMenuItem.Create(PopupBarkod);
      MenuItem.Tag := Tablo.Query1.FieldByName('ID').AsInteger;
      MenuItem.Caption := Tablo.Query1.FieldByName('AD').AsString;
      MenuItem.Hint := Tablo.Query1.FieldByName('BASLANGIC').AsString;
      MenuItem.RadioItem := True;
      MenuItem.OnClick := BarkodMenuClick;
      PopupBarkod.Items.Add(MenuItem);


      Tablo.Query1.Next;
    end;
  end;

  ComboBarkod.Properties.Items := Tablo.imgComboboxInit('select distinct BA.ID,BA.AD from (select ID=0,AD=''Kullanıcı'',BASLANGIC='''' union all select ID,AD,BASLANGIC from BARKODAYARLAR) BA ').Items;
         }
end;

procedure TIzlemeDlg.GridFatIzlemViewCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridFatIzlem;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridFatIzlemView;
  //AnaForm.pmGridStil.Tags.Values[GridFatIzlem.Name]:='GridFatIzlemGridi';
end;

procedure TIzlemeDlg.GridFatIzlemViewCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
{  if GridFatIzlemViewSEC.Visible then begin
     if TabIzlem.state = dsbrowse then
        TabIzlem.Edit;
     TabIzlem.FieldByName('SEC').AsBoolean := not TabIzlem.FieldByName('SEC').AsBoolean;
     if TabIzlem.FieldByName('SEC').AsBoolean=True then
        TabIzlem.FieldByName('KALAN').AsInteger:= TabIzlem.FieldByName('DURUM').AsInteger
     else
        TabIzlem.FieldByName('KALAN').AsInteger:= 0;
     //SayiGetir;
     try
       TabIzlem.Post;
     except

     end;
  end;}
end;

procedure TIzlemeDlg.GridFatIzlemViewCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
if (KalanMiktar>0.001)and(GridFatIzlemViewSEC.Visible) then begin
     if TabIzlem.state = dsbrowse then
        TabIzlem.Edit;
     TabIzlem.FieldByName('SEC').AsBoolean := not TabIzlem.FieldByName('SEC').AsBoolean;
     if TabIzlem.FieldByName('SEC').AsBoolean=True then begin
        if TabIzlem.FieldByName('DURUM').AsFloat > KalanMiktar then
           TabIzlem.FieldByName('KALAN').AsFloat:= KalanMiktar
        else
           TabIzlem.FieldByName('KALAN').AsFloat:= TabIzlem.FieldByName('DURUM').AsFloat
     end
     else
        TabIzlem.FieldByName('KALAN').AsFloat:= 0;
     //SayiGetir;
     try
       TabIzlem.Post;
     except

     end;
  end;
end;

procedure TIzlemeDlg.GridFatIzlemViewKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=13 then begin
    if TabIzlem.State=dsInsert then begin
      TabIzlem.Post;
      TabIzlem.Append;
    end else if TabIzlem.State=dsEdit then begin
      TabIzlem.Post;
      if not TabIzlem.Eof then
        TabIzlem.Next;
    end else if TabIzlem.State=dsBrowse then begin
      if not TabIzlem.Eof then
        TabIzlem.Next;
    end;
  end;
end;

procedure TIzlemeDlg.GridFatIzlemViewSECPropertiesChange(Sender: TObject);
begin
        if IzlemTur in [izl_SeriNo, izl_Karekod, izl_SeriNo_LotNo] then begin
           if TabIzlem.FieldByName('SEC').AsBoolean then
              TabIzlem.FieldByName('KALAN').AsFloat := 1.0
           else
              TabIzlem.FieldByName('KALAN').AsFloat := 0.0;
           TabIzlem.Post;
        end;
end;

procedure TIzlemeDlg.cxLabel1DblClick(Sender: TObject);
var Adet : Variant;
begin
   Adet := '0';
   if TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi,TGirdiDenetimleri.Create.Edit(BGYeni_bilgi_girisi,@Adet)) <> mrOk then
        Abort;
   //Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKIZLEME SET ADET='+VarToStr(Adet)+', KALAN='+VarToStr(Adet)+
   //    '  WHERE ID = '+TabIzlem.FieldByName('IZLEMID').AsString,[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update STOKIZLEMEDEPO SET ADET=CASE WHEN ADET<0 THEN -1*'+VarToStr(Adet)+
      ' ELSE '+VarToStr(Adet)+' END  WHERE IZLEMID = '+TabIzlem.FieldByName('UPDID').AsString,[],[]);
end;

procedure TIzlemeDlg.DtsIzlemStateChange(Sender: TObject);
begin
  EkleTus.Visible := (DtsIzlem.State = dsBrowse)and(not GridFatIzlemViewSEC.Visible);
  SilTus.Visible  := (DtsIzlem.State = dsBrowse)and(not GridFatIzlemViewSEC.Visible);
  KaydetBtn.Visible := DtsIzlem.State in [dsEdit,dsInsert];
  IptalBtn.Visible := DtsIzlem.State in [dsEdit,dsInsert];
  //BtnBarkod.Visible := DtsIzlem.State = dsBrowse;
end;

procedure TIzlemeDlg.EditAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  EditAra.PostEditValue;
end;

procedure TIzlemeDlg.EditAraPropertiesEditValueChanged(Sender: TObject);
begin
  TabIzlem.Close;
  TabIzlem.SQL.Text := 'select * from '+TabloAdi+' where (SERINO like '''+VarToStr(EditAra.EditValue)+'%'') or (LOTNO like '''+VarToStr(EditAra.EditValue)+'%'')' ;
  TabIzlem.Open;
end;

procedure TIzlemeDlg.EditBarkodKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
var
  OBarkod,SKT,URT, BGun,BAy,BYil, UrunNo, BLot,BSrn,BMik,BChc,Format:string;
  j,SondanSil, isrt:integer;
  function BulveAdeteEkle : Boolean;
  begin //çıkış için okutacağız
        Result := False;
        if TabIzlem.state in [dsEdit, dsInsert] then
           TabIzlem.cancel;

        TabIzlem.First;
        if (BSrn<>'')and(TabIzlem.locate('SERINO', BSrn, [])) then
            Result := True
        else if (BLot<>'')and(TabIzlem.locate('LOTNO', BLot, [])) then
           Result := True;

        if Result=False then
           exit;

        TabIzlem.Edit;
        TabIzlem.FieldByName('KALAN').AsFloat:= TabIzlem.FieldByName('KALAN').AsFloat + 1.0;
        TabIzlem.Post;
  end;

  procedure BarkodOku;
  var i : integer;
  begin
    if VarToStr(OBarkod)<>'' then begin
      BGun:='';
      BAy:='';
      BYil:='';
      BLot:='';
      BSrn:='';
      BMik:='';
      BChc:='';
      Format:='';
      Tablo.TablodanSorguAc(1,'select * from BARKODAYARLAR where ID='+IntToStr(ComboBarkod.Tag));
      Format := Tablo.Query1.FieldByName('BASLANGIC').AsString;
      SondanSil := Tablo.Query1.FieldByName('SONDANSIL').AsInteger;
      if Length(Format)>Length(VarToStr(OBarkod)) then
        j:=Length(VarToStr(OBarkod))
      else
        j:=Length(Format);
      for i := 1 to j-SondanSil do begin //format hint içinde yazıyor..
        if Copy(Format,i,1)='G' then
          BGun := BGun + Copy(VarToStr(OBarkod),i,1)
        else if Copy(Format,i,1)='A' then
          BAy  := BAy  + Copy(VarToStr(OBarkod),i,1)
        else if Copy(Format,i,1)='Y' then
          BYil := BYil + Copy(VarToStr(OBarkod),i,1)
        else if Copy(Format,i,1)='L' then
          BLot := BLot + Copy(VarToStr(OBarkod),i,1)
        else if Copy(Format,i,1)='S' then
          BSrn := BSrn + Copy(VarToStr(OBarkod),i,1)
        else if Copy(Format,i,1)='C' then
          BChc := BChc + Copy(VarToStr(OBarkod),i,1)
        else if Copy(Format,i,1)='#' then
          BMik := BMik + Copy(VarToStr(OBarkod),i,1);
      end;
      if Length(BYil)=2 then
        BYil := '20' + BYil;
      if Length(BGun)<>2 then
        BGun := '01';
    end;
  end;

  function TarihBul(Tur, BTarih:string):string;
  begin
     if length(BTarih)=6 then begin //yyaagg
         BYil := '20'+Copy(BTarih,1,2);
         BAy := Copy(BTarih,3,2);
         BGun := Copy(BTarih,5,2);
     end
     else if length(BTarih)=10 then begin //aa.gg.yyyy veya yyyy.gg.aa
        BTarih := StringReplace(BTarih,'/','.',[rfReplaceAll]);
        isrt := pos('.',BTarih);
        if isrt=3 then begin
           BYil := Copy(BTarih,7,4);
           BAy := Copy(BTarih,4,2);
           BGun := Copy(BTarih,1,2);
        end
        else begin
           BYil := Copy(BTarih,1,4);
           BAy := Copy(BTarih,6,2);
           BGun := Copy(BTarih,9,2);
        end;
     end;
     if BGun = '' then begin
        if Tur='SKT' then
           BYil:='2990'
        else
           BYil := '1990';
        Result := '01'+FormatSettings.DateSeparator+'01'+FormatSettings.DateSeparator+BYil+' 00:00'
     end else
        Result := BGun+FormatSettings.DateSeparator+BAy+FormatSettings.DateSeparator+BYil+' 00:00';
  end;
begin
  if Key <> 13 then exit;
    SKT := '';
    URT :='';
//  while TGirisKutusuEx.BilgiAlEx(BGYeni_Barkod_gir, TGirdiDenetimleri.Create.Edit(BGBarkod_no, @OBarkod)) = mrOk do begin
    OBarkod := EditBarkod.Text;
    if ComboBarkod.EditValue = 100 then begin //karekod seçilmişse
       UrunNo := Tablo.KarekodOku(01, OBarkod);
       //�r�n no yu okuduk bakal�m okunan bu �r�ne mi ait
       if pos('0', UrunNo)=1 then  //ba��nda s�f�r varsa atal�m
          UrunNo := copy(UrunNo, 2, 300);
       Tablo.TablodanSorguAc(1,'select ID from STOKLAR where ID='+IntToStr(StokId)+' and URUNNO='''+UrunNo+''' or  URUNNO=''0'+UrunNo+'''');
       if Tablo.Query1.Recordcount < 1 then begin
          showmessage(KarekodAitDegil);
          exit;
       end;
       BLot := Tablo.KarekodOku(10, OBarkod);
       BSrn := Tablo.KarekodOku(21, OBarkod);
       if GridFatIzlemViewSEC.Visible=False then begin //giri� ise
           SKT := TarihBul('SKT',Tablo.KarekodOku(17, OBarkod));
           URT := TarihBul('URT',Tablo.KarekodOku(11, OBarkod));
       end;
    end
    else
       BarkodOku;

   if GridFatIzlemViewSEC.Visible then begin//çıkış için okutacağız
      if BLot<>'' then
         BulveAdeteEkle
   end else //okuduklarımız daha önceden eklenmemişse insert edelim..
         if BulveAdeteEkle=False then begin
            if TabIzlem.state in [dsBrowse] then
               TabIzlem.Append;
            if (GridFatIzlemViewSERINO.Visible)and(BSrn<>'') then
              TabIzlem.FieldByName('SERINO').AsString := BSrn;
            if (GridFatIzlemViewSKT.Visible)and(SKT<>'') then    ///  (BAy<>'')
              TabIzlem.FieldByName('SKT').AsString := SKT;//BGun+FormatSettings.DateSeparator+BAy+FormatSettings.DateSeparator+BYil+' 00:00';
            if (GridFatIzlemViewSKT.Visible)and(URT<>'') then
              TabIzlem.FieldByName('URT').AsString := URT;
            if (GridFatIzlemViewLOTNO.Visible)and(BLot<>'') then
              TabIzlem.FieldByName('LOTNO').AsString := BLot;
            if (GridFatIzlemViewMIKTAR.Visible)and(BSrn<>'') then
              TabIzlem.FieldByName('KALAN').AsFloat := StrToFloat(BMik);
            TabIzlem.Post;
      end;



      EditBarkod.SelStart  := 0;
      EditBarkod.SelLength  := 200;

end;

procedure TIzlemeDlg.EkleTusClick(Sender: TObject);
begin
  TabIzlem.Append;
end;

procedure TIzlemeDlg.SilTusClick(Sender: TObject);
begin
  TabIzlem.Delete;
end;

procedure TIzlemeDlg.KaydetBtnClick(Sender: TObject);
begin
  TabIzlem.Post;
end;

procedure TIzlemeDlg.IptalBtnClick(Sender: TObject);
begin
  TabIzlem.Cancel;
end;

procedure TIzlemeDlg.SayiGetir;
begin
  if KALAN<>GerekliMiktar then begin  //serino lu bloklardan üretim yapılıyor
    Tablo.TablodanSorguAc(2,'select count(*) from '+TabloAdi+' where SEC=1');
    LblSecilenMiktar.Caption := ' Seçilen:'+Tablo.Query2.Fields[0].AsString;//GridFatIzlemView.DataController.Summary.FooterSummaryTexts[0];
    KaydetTus.Enabled := (Degisemez=False)and(abs(GerekliMiktar - Tablo.Query2.Fields[0].AsInteger)<0.0000001);
  end else begin
    Tablo.TablodanSorguAc(2,'select sum(KALAN) from '+TabloAdi+' where SEC=1');
    LblSecilenMiktar.Caption := ' Seçilen:'+Tablo.Query2.Fields[0].AsString;//GridFatIzlemView.DataController.Summary.FooterSummaryTexts[0];
    KaydetTus.Enabled := (Degisemez=False)and(abs(KALAN - Tablo.Query2.Fields[0].AsFloat)<0.0000001);
    SilTus.Enabled := Tablo.Query2.Fields[0].AsFloat>0;
  end;
  KalanMiktar := KALAN-Tablo.Query2.Fields[0].AsFloat;
  LblKalanMiktar.Caption := ' Kalan: '+Format('%.'+IntToStr(OndalikDijitSayMik)+'f', [KalanMiktar]);

  EkleTus.Enabled := not KaydetTus.Enabled;
end;

procedure TIzlemeDlg.TabIzlemAfterDelete(DataSet: TDataSet);
begin
   SayiGetir;
end;

procedure TIzlemeDlg.TabIzlemAfterOpen(DataSet: TDataSet);
begin
   SayiGetir
end;

procedure TIzlemeDlg.TabIzlemAfterPost(DataSet: TDataSet);
begin
   SayiGetir;
end;

procedure TIzlemeDlg.LabelSecClick(Sender: TObject);
var I : integer;
    Sec, Secim : Boolean;
    stlist : TStringList;
begin
   Secim :=  TcxLabel(Sender).Name <> 'LabelSec';
   stlist:=TStringList.Create;
   for I := 0 to GridFatIzlemView.Controller.SelectedRecordCount-1 do begin
          Sec := StrToBool(VarToStr(GridFatIzlemView.Controller.SelectedRows[i].Values[GridFatIzlemViewSEC.Index]));
          if Sec=Secim then
             stlist.Add(  VarToStr(GridFatIzlemView.Controller.SelectedRows[i].Values[GridFatIzlemViewID.Index])) ;


   end;
   TabIzlem.First;
   while not TabIzlem.eof do begin
     if  stlist.IndexOf( TabIzlem.FieldByName('ID').AsString)>=0  then begin
         TabIzlem.Edit;
         TabIzlem.FieldByName('SEC').AsBoolean := not Secim;
         if TabIzlem.FieldByName('SEC').AsBoolean=True then
            TabIzlem.FieldByName('KALAN').AsFloat := 1.0
         else
            TabIzlem.FieldByName('KALAN').AsFloat := 0.0;
         TabIzlem.Post;
     end;
     TabIzlem.next;
   end;
   stlist.Free;
end;

procedure TIzlemeDlg.LblKalanMiktarClick(Sender: TObject);
begin
   TabIzlem.Edit;
   TabIzlem.FieldByName('KALAN').AsFloat := Kalan;
   TabIzlem.Post;
end;

procedure TIzlemeDlg.Listedentoplualma1Click(Sender: TObject);
var MemoYorum, SKT, URT, Lotno : Variant;
    Liste:TStringList;
    I:smallint;
    ctrls : TGirdiDenetimleri;
    Alanlar,Degerler:string;
begin
    MemoYorum:=''; SKT:=Tablo.GENINI.BugunTrh; URT:=SKT;
    if GridFatIzlemViewLOTNO.Visible then  //serino ve lotno birlikte ise
       ctrls := TGirdiDenetimleri.Create.DateTimePicker('SKT' , @SKT, dtkDate).DateTimePicker('ÜRT' , @URT, dtkDate).Memo('İşlem' , @MemoYorum).Edit('Lot No' , @Lotno)
    else
       ctrls := TGirdiDenetimleri.Create.DateTimePicker('SKT' , @SKT, dtkDate).DateTimePicker('ÜRT' , @URT, dtkDate).Memo('İşlem' , @MemoYorum);

   Alanlar := 'STOKID,SERINO,';
   if GridFatIzlemViewLOTNO.Visible then
      Alanlar := Alanlar + 'LOTNO,';
   Alanlar := Alanlar + 'SKT,URT,SEC,KALAN';

    if TGirisKutusuEx.BilgiAlEx('Seri No listesi', ctrls) = mrOk then begin
      if Trim(VarToStr(MemoYorum))<>'' then begin //eğer yorum düzenlenebiliyorsa
         memo1.Text := Trim(VarToStr(MemoYorum));
         for I := 0 to memo1.Lines.Count-1 do
           if trim(memo1.lines[I])<>'' then begin
              Degerler := IntToStr(StokId)+','''+ trim(memo1.lines[I])+'''';
              if GridFatIzlemViewLOTNO.Visible then
                 Degerler := Degerler + ','''+ VarToStr(LotNo)  +'''';
              Degerler := Degerler + ','''+FormatDateTime('yyyy-mm-dd', SKT)+''','''+FormatDateTime('yyyy-mm-dd', URT)+''',1,1.0';
              Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into '+TabloAdi+
                    '('+Alanlar+')values('+Degerler+')', [], []);
           end;
         TabloYenile(TabIzlem, []);
      end;
    end;
end;


procedure TIzlemeDlg.Balamabitivererek1Click(Sender: TObject);
var Basla, SKT, URT, Onek, Sonek, Lotno:Variant;
    Liste:TStringList;
    j,Fark,DigitSay:integer;
    ctrls : TGirdiDenetimleri;
    SNo, Alanlar,Degerler:string;
    I_Sno : real;
begin
//Adnan 29/09/2021
    Basla:=''; SKT:=Tablo.GENINI.BugunTrh; URT:=SKT; Onek :=''; Sonek:='';
    if GridFatIzlemViewLOTNO.Visible then  //serino ve lotno birlikte ise
       ctrls := TGirdiDenetimleri.Create.DateTimePicker('SKT' , @SKT, dtkDate).DateTimePicker('ÜRT' , @URT, dtkDate)
         .Edit('Ön Ek' , @Onek).Edit('Başlama No' , @Basla).Edit('Son Ek' , @Sonek).Edit('Lot No' , @Lotno)
    else                                    //sadece serino var ise
       ctrls := TGirdiDenetimleri.Create.DateTimePicker('SKT' , @SKT, dtkDate).DateTimePicker('ÜRT' , @URT, dtkDate)
         .Edit('Ön Ek' , @Onek).Edit('Başlama No' , @Basla).Edit('Son Ek' , @Sonek);

    if TGirisKutusuEx.BilgiAlEx('Seri No listesi', ctrls) = mrOk then begin
      if (Trim(VarToStr(Basla))<>'') then begin
         DigitSay := Length(Basla);
         Bas := StrToInt64(VarToStr(Basla));
         //Bit := Bas+Kalan-1;
         I_SNo := 0.0;
         Alanlar := 'STOKID,SERINO,';
         if GridFatIzlemViewLOTNO.Visible then
            Alanlar := Alanlar + 'LOTNO,';
         Alanlar := Alanlar + 'SKT,URT,SEC,KALAN';
         while I_SNo < Kalan do begin
             SNo := floatToStr(Bas+I_SNo);
             Fark := DigitSay - Length(SNo)-1;
             for J := 0 to Fark do
                 Sno:='0'+SNo;
             if SNo<>'' then begin
                Degerler := IntToStr(StokId)+','''+ VarToStr(Onek)+SNo+VarToStr(Sonek)+'''';
                if GridFatIzlemViewLOTNO.Visible then
                   Degerler := Degerler + ','''+ VarToStr(LotNo)  +'''';
                Degerler := Degerler + ','''+FormatDateTime('yyyy-mm-dd', SKT)+''','''+FormatDateTime('yyyy-mm-dd', URT)+''',1,1.0';
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'insert into '+TabloAdi+
                  '('+Alanlar+')values('+Degerler+')', [], []);
             end;
             I_SNo := I_SNo + 1.0
         end;
         TabloYenile(TabIzlem, []);
      end;
    end;
end;

Procedure TIzlemeDlg.BarkoddanMiktarGetir;
var
  i,j,BoyutID:integer;
  Boyut1,Boyut2,Boyut3,Alan1,Alan2,Alan3:string;
begin
  Tablo.TablodanSorguAc(2,'select sum(KALAN) from '+TabloAdi+' where SEC=1');
  if (Barkod <> '') and (Tablo.Query2.Fields[0].AsInteger=0) then begin
    case IzlemTur of
      1:begin

        end;
      2:begin

        end;
      3:begin

        end;
      (*4:begin //boyut barkodu
          Tablo.TablodanSorguAc(3,' select * from STOKBARKOD where STOKID='+IntToStr(StokID)+' and BARKOD = '''+Barkod+''' and YERI=342');
          if Tablo.Query3.RecordCount = 1 then //bu boyut için direk oluşturulmuş bir barkodsa burada gelecektir..
             BoyutID := Tablo.Query3.FieldByName('YERID').AsInteger
          else if Tablo.Query3.RecordCount = 0 then begin //boyut stoğun barkodunda gizli..
            Tablo.TablodanSorguAc(4,' select * from STOKBARKOD where STOKID='+IntToStr(StokID)+' and BARKOD like ''%O%'' and LEN(BARKOD)=LEN('''+Barkod+''') '); //'O','P','Q' boyutları temsil eder..
            if Tablo.Query4.RecordCount = 1 then begin //içine 'O','P','Q' gibi değişkenler eklenmiş bir barkod tanımı var ise
              for i := 1 to Length(Barkod) do begin //format hint içinde yazıyor..
                if Copy(Tablo.Query4.FieldByName('BARKOD').AsString,i,1)='O' then begin
                  Boyut1 := Boyut1 + Copy(Barkod,i,1);
                  Alan1 := Alan1+'O';
                end else if Copy(Tablo.Query4.FieldByName('BARKOD').AsString,i,1)='P' then begin
                  Boyut2 := Boyut2 + Copy(Barkod,i,1);
                  Alan2 := Alan2+'P';
                end else if Copy(Tablo.Query4.FieldByName('BARKOD').AsString,i,1)='Q' then begin
                  Boyut3 := Boyut3 + Copy(Barkod,i,1);
                  Alan3 := Alan3+'Q';
                end;
              end;//boyutlar belirlendikten sonra değerlerini bulalım..
              Tablo.TablodanSorguAc(5,'select S.ID from STOKBOYUTKOMBINASYON S left outer join '+
                                       'GENINI G1 on G1.BOLUM=S.BOLUM1 and G1.DEGER=S.DEGER1 and G1.DIL=-1 left outer join '+
                                       'GENINI G2 on G2.BOLUM=S.BOLUM2 and G2.DEGER=S.DEGER2 and G2.DIL=-1 left outer join '+
                                       'GENINI G3 on G3.BOLUM=S.BOLUM3 and G3.DEGER=S.DEGER3 and G3.DIL=-1 '+
                                       'where S.STOKID='+IntToStr(StokID)+' and isnull(G1.ANAHTAR,'''')='''+Boyut1+''' and isnull(G2.ANAHTAR,'''')='''+Boyut2+''' and isnull(G3.ANAHTAR,'''')='''+Boyut3+'''');
              //barkod uygun ve bu barkodun boyut tanımı var ise..;
              if (Tablo.Query5.RecordCount = 0)and(Tablo.GENINI.ReadBoolean(Ops_StokOpsiyon_OtomatikBoyutOlusturma, False)) then begin
                //bu durumda elimizde formata uygun bir boyut var fakat bu boyutun tanımlı bir kombinasyonu yok..
                BoyutID := YeniBoyutOlustur(StokID,Boyut1,Boyut2,Boyut3);
                //barkod da oluşturmamız lazım;
                Tablo.Query3.Append;
                Tablo.Query3.FieldByName('BARKOD').AsString := StringReplace(StringReplace(StringReplace(Tablo.Query4.FieldByName('BARKOD').AsString,Alan1,Boyut1,[]),Alan2,Boyut2,[]),Alan3,Boyut3,[]);
                Tablo.Query3.FieldByName('STOKID').AsInteger := StokID;
                Tablo.Query3.FieldByName('BARKODTIPI').AsInteger := 0;
                Tablo.Query3.FieldByName('BARKODBIRIMI').AsInteger := Tablo.Query4.FieldByName('BARKODBIRIMI').AsInteger;
                Tablo.Query3.FieldByName('YERI').AsInteger := 342;
                Tablo.Query3.FieldByName('YERID').AsInteger := BoyutID;
                Tablo.Query3.Post;
                TabIzlem.Close;
                TabIzlem.Open;
              end else
                BoyutID := Tablo.Query5.FieldByName('ID').AsInteger;
            end else
              BoyutID := 0;
          end else
            BoyutID := 0;
          if BoyutID<>0 then begin
            if TabIzlem.Locate('IZLEMID',BoyutID,[]) then begin
              TabIzlem.Edit;
              TabIzlem.FieldByName('KALAN').AsFloat := KALAN;
              TabIzlem.Post;
              TabIzlem.Locate('IZLEMID',BoyutID,[]);
            end;
          end;
        end;  *)
    end;
  end;
end;

function TIzlemeDlg.BoyutDegeriGetir(Bolum:integer;Anahtar:string):integer;
var SQLText:string;
begin
  Tablo.Query0.Close;
  Tablo.Query0.SQL.Text := 'select * from GENINI where BOLUM='+IntToStr(Bolum)+' and ANAHTAR='''+Anahtar+'''';
  Tablo.Query0.Open;
  if Tablo.Query0.RecordCount=0 then begin //bu anahtar yok insert edelim..
    SQLText := 'insert into GENINI(BOLUM,ANAHTAR,DEGER,SIRA,DIL)values(';
    SQLText := SQLText + IntToStr(Bolum)+','''+Anahtar+''',';
    SQLText := SQLText + '(select max(DEGER) from GENINI where DEGER is not null and BOLUM='+IntToStr(Bolum)+')+1,';
    SQLText := SQLText + '(select max(DEGER) from GENINI where DEGER is not null and BOLUM='+IntToStr(Bolum)+')+1,'+IntToStr(Dil)+')';
    veritabani.BasitKomutÇalıştır(Tablo.FDCnn,SQLText,[],[]);
    //tekrar açalım..
    Tablo.Query0.Close;
    Tablo.Query0.SQL.Text := 'select * from GENINI where BOLUM='+IntToStr(Bolum)+' and ANAHTAR='''+Anahtar+'''';
    Tablo.Query0.Open;
  end;
  Result := Tablo.Query0.FieldByName('DEGER').AsInteger;
end;

procedure TIzlemeDlg.BtnLotNoVerClick(Sender: TObject);
var s : string;
i:integer;
begin
   s:= Trim(Tablo.GENINI.ReadString(Ops_EditUretLotNoOnek, ''));
   if s<>'' then begin
      s := StringReplace(s, 'YYYY', IntToStr(CurrentYear), [rfReplaceAll]);
      s := StringReplace(s, 'YY', copy(IntToStr(CurrentYear), 3, 10), [rfReplaceAll]);
      s := StringReplace(s, 'MM', IntToStr(MonthOf(Tablo.GENINI.buguntrh)), [rfReplaceAll]);
      s := StringReplace(s, 'DD', IntToStr(DayOf(Tablo.GENINI.buguntrh)), [rfReplaceAll]);
   end;
   TabIzlem.Edit;
   TabIzlem.FieldByName('LOTNO').AsString := s+UretimNo;
   TabIzlem.Post;
end;

function TIzlemeDlg.YeniBoyutOlustur(StokID:integer;Boyut1,Boyut2,Boyut3:string):integer;
var
  Deger1,Deger2,Deger3:Variant;
begin
  Tablo.TablodanSorguAc(6,'select * from STOKLAR where ID='+IntToStr(StokID));
  Tablo.TablodanSorguAc(7,'select * from STOKBOYUTGRUPLARI where ID='+Tablo.Query6.FieldByName('BOYUTGRUBU').AsString);
  Tablo.TablodanSorguAc(8,'select * from STOKBOYUTKOMBINASYON where STOKID='+IntToStr(StokID));
  if (Tablo.Query6.RecordCount=1)and(Tablo.Query7.RecordCount=1) then begin
    Tablo.Query9.Close;
    Tablo.Query9.SQL.Text := 'insert into STOKBOYUTKOMBINASYON(STOKID,SBGID,BOLUM1,DEGER1,BOLUM2,DEGER2,BOLUM3,DEGER3,EKLEYEN)';
    Tablo.Query9.SQL.Add('values('+IntToStr(StokID)+','+Tablo.Query7.FieldByName('ID').AsString);
    if Tablo.Query7.FieldByName('BOYUT1').Value <> null then begin
      Tablo.Query9.SQL.Add(','+Tablo.Query7.FieldByName('BOYUT1').AsString+','+IntToStr(BoyutDegeriGetir(Tablo.Query7.FieldByName('BOYUT1').AsInteger,Boyut1)));
    end else
      Tablo.Query9.SQL.Add(',null,null');
    if Tablo.Query7.FieldByName('BOYUT2').Value <> null then begin
      Tablo.Query9.SQL.Add(','+Tablo.Query7.FieldByName('BOYUT2').AsString+','+IntToStr(BoyutDegeriGetir(Tablo.Query7.FieldByName('BOYUT2').AsInteger,Boyut2)));
    end else
      Tablo.Query9.SQL.Add(',null,null');
    if Tablo.Query7.FieldByName('BOYUT3').Value <> null then begin
      Tablo.Query9.SQL.Add(','+Tablo.Query7.FieldByName('BOYUT3').AsString+','+IntToStr(BoyutDegeriGetir(Tablo.Query7.FieldByName('BOYUT3').AsInteger,Boyut3)));
    end else
      Tablo.Query9.SQL.Add(',null,null');
    Tablo.Query9.SQL.Add(','+Kullanan+') select scope_identity()');
    Tablo.Query9.Open;
    Result := Tablo.Query9.Fields[0].AsInteger;
  end else
    Result := 0;
end;

function TIzlemeDlg.BuSeriNoKullanilmismiKontrolu(IzlemNo:string) : Boolean;
begin
   //serino ve giriş ise silmeden önce kullanılmış mı diye kontrol ederiz
   if (IzlemTur=izl_SeriNo)and(IzlemNo<>'')and(IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,
          KasaTur_Gelen_Konsinye,KasaTur_Uretim_Urun]) then begin//yenigiriş
       Tablo.TablodanSorguAc(1,'select * from STOKIZLEME SI inner join STOKSERILOT SSL on SI.SERILOTID=SSL.ID where SI.STOKID='+IntToStr(StokID)+' and BELGETUR in ('+
           IntToStr(KasaTur_DigerCikisFisi)+','+IntToStr(KasaTur_SatisFaturasi)+','+IntToStr(KasaTur_SatisFisi)+','+
           IntToStr(KasaTur_SatisIrsaliyesi)+','+IntToStr(KasaTur_Uretim_Urun)+','+IntToStr(KasaTur_StokTransferi)+',119) '+
           ' and SERINO='''+IzlemNo+'''');
       if Tablo.Query1.RecordCount>0 then begin
          showmessage(Hareketgormussilinemez+Tablo.Query1.FieldByName('BASLIKID').AsString+' '+Tablo.Query1.FieldByName('SATIRID').AsString);
          Result := True;
       end
       else
          Result := False;
   end;

end;
procedure TIzlemeDlg.TabIzlemBeforeDelete(DataSet: TDataSet);
begin
   if BuSeriNoKullanilmismiKontrolu(TabIzlem.FieldByName('SERINO').AsString)=True then
      Abort;
end;

procedure TIzlemeDlg.TabIzlemBeforeEdit(DataSet: TDataSet);
begin
   OncekiIzlem := TabIzlem.FieldByName('SERINO').AsString;
end;

procedure TIzlemeDlg.TabIzlemBeforePost(DataSet: TDataSet);
var Fark : Real;
    function LotNoKontrolu : boolean;
    //var I,say : integer;
        //Lotno, Girilen : string;
    begin
         Result := True;
         //sonra önceki girişlere de bakalım bu lotnodan girilmiş mi
         Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'* from STOKSERILOT SI where SI.STOKID='+IntToStr(StokID)+
             ' and LOTNO='''+TabIzlem.FieldByName('LOTNO').AsString+''' '+DbSinir(1));
         if (Tablo.Query1.RecordCount > 0) and //daha önceden girilmiş lot bulundu
            (Tablo.Query1.FieldByName('SKT').AsDateTime-TabIzlem.FieldByName('SKT').AsDateTime<>0)and
            (Tablo.Query1.FieldByName('URT').AsDateTime-TabIzlem.FieldByName('URT').AsDateTime<>0) then begin
            if Application.MessageBox(PChar('Bu lot üründe tarih uyuşmazlığı var. Önceki girilen alınsın mı?'+#13#10+
               ' (SKT:'+FormatDateTime('dd/mm/yyyy', Tablo.Query1.FieldByName('SKT').AsDateTime)+
               ' ÜRT:'+FormatDateTime('dd/mm/yyyy', Tablo.Query1.FieldByName('URT').AsDateTime)+')'),
               PChar('UYARI!'), MB_YESNO)=ID_YES then begin
               TabIzlem.FieldByName('SKT').AsDateTime := Tablo.Query1.FieldByName('SKT').AsDateTime;
               TabIzlem.FieldByName('URT').AsDateTime := Tablo.Query1.FieldByName('URT').AsDateTime;
            end
            else
               Result := False;
         end;
    end;
    function SeriNoKontrolu : boolean;
    var I,say : integer;
        Serino, Girilen : string;
    begin
         //önce bu ekranda gridde kontrol edelim daha önce var mı
             GridFatIzlemView.Controller.SelectAll;
             Girilen := TabIzlem.FieldByName('SERINO').AsString;
             say:=0;
             for I := 0 to GridFatIzlemView.Controller.SelectedRecordCount-1 do begin
                Serino := VarToStr(GridFatIzlemView.Controller.SelectedRows[i].Values[GridFatIzlemViewSERINO.Index]);
                if Serino = Girilen then
                   inc(say);
             end;
             GridFatIzlemView.Controller.ClearSelection;
             //sonra önceki girişlere de bakalım bu serinodan girilmiş mi
             Tablo.TablodanSorguAc(1,'select * from STOKIZLEME SI inner join STOKSERILOT SSL on SI.SERILOTID=SSL.ID  where SI.STOKID='+IntToStr(StokID)+' and SI.BELGETUR in ('+
                 IntToStr(KasaTur_DigerGirisFisi)+','+IntToStr(KasaTur_AlisFaturasi)+','+IntToStr(KasaTur_AlisFisi)+','+
                 IntToStr(KasaTur_AlisIrsaliyesi)+','+IntToStr(KasaTur_Uretim_Urun)+','+IntToStr(KasaTur_Gelen_Konsinye)+',119) '+
                 ' and SSL.SERINO='''+Girilen+''' ');
             say := say + Tablo.Query1.RecordCount;
             if say>1 then //1 tane kendisi olmalı
                showmessage(kullanilmisserino);
             Result := Say=1;
    end;
begin
   if ((IzlemTur in [izl_SeriNo,izl_Karekod,izl_SeriNo_LotNo] )and(TabIzlem.FieldByName('SERINO').AsString=''))or
      ((IzlemTur in [izl_LotNo, izl_LotNo_SKT])and(TabIzlem.FieldByName('LOTNO').AsString='')) then begin
      Showmessage(IZBilgi_gir);
      Abort;
   end;
   if (IzlemTur in [izl_SKT, izl_LotNo_SKT])and (IslemTur <> KasaTur_Gelen_Konsinye)
       and(IslemTur <> KasaTur_DigerCikisFisi)and(IslemTur <> KasaTur_StokTransferi) then begin //iade konsinye ise konsinyeden çıkış anadepoya giriş olmalı
      if TabIzlem.FieldByName('SKT').AsString='' then begin
         Showmessage(IZBilgi_gir);
         Abort;
      end else if TabIzlem.FieldByName('SKT').AsDateTime<Tablo.GENINI.BugunTrh then begin
         Showmessage(SKTKucukOlamaz);
       //  Abort;
      end;
      if (TabIzlem.FieldByName('URT').AsString<>'')and(TabIzlem.FieldByName('URT').AsDateTime>Tablo.GENINI.BugunTrh) then begin
         Showmessage(URTKucukOlamaz);
      // Abort;
      end;
   end;

//   if (GridFatIzlemViewDURUM.Visible)and(TabIzlem.FieldByName('KALAN').AsFloat>TabIzlem.FieldByName('DURUM').AsFloat) then begin //1 tane kendisi olmalı
// 20.05.2024 AO üstteki satır çalışmadı alta çevirdim..
   if (GridFatIzlemViewDURUM.Visible)and(IslemTur <> 99) then begin //28.11.2024 AO  üretim veya sayım değilse kontrol edelim.  eskiden bu vardı :
         Fark := TabIzlem.FieldByName('KALAN').AsFloat - TabIzlem.FieldByName('DURUM').AsFloat;
         if Fark > 0.00000001 then begin //1 tane kendisi olmalı
            showmessage(MiktarBuyuk);
            abort;
         end;
   end;

   if GridFatIzlemViewSEC.Visible then
      TabIzlem.FieldByName('SEC').AsBoolean := TabIzlem.FieldByName('KALAN').AsFloat>0;

  case IzlemTur of
   izl_SeriNo, izl_Karekod, izl_LotNo_SKT, izl_SeriNo_LotNo : begin
         // serino girişi sadece 1 tane olmalı
         if (TabIzlem.FieldByName('LOTNO').AsString<>'')and(GridFatIzlemViewLOTNO.Options.Editing=True) then begin//yenigiriş
             if LotNoKontrolu=False then
                Abort;
         end
         else if (TabIzlem.FieldByName('SERINO').AsString<>'')and(GridFatIzlemViewSERINO.Options.Editing=True) then begin//yenigiriş
              //and(IslemTur in [KasaTur_DigerGirisFisi,KasaTur_AlisFaturasi,KasaTur_AlisFisi,KasaTur_AlisIrsaliyesi,
              //  KasaTur_Gelen_Konsinye,KasaTur_Uretim_Urun])
             if SeriNoKontrolu=False then
                Abort;
         end;
         //giriş fişlerindeki seri no değiştirmede başka yerde kullanılmış mı, kontrolü
         if (OncekiIzlem<>TabIzlem.FieldByName('SERINO').AsString)and
            (BuSeriNoKullanilmismiKontrolu(TabIzlem.FieldByName('SERINO').AsString)=True) then
            Abort;
       end;
  end;
end;

procedure TIzlemeDlg.TabIzlemNewRecord(DataSet: TDataSet);
begin
  GridFatIzlemViewSKT.Options.Editing := True;  //GridFatIzlemViewSERINO.Options.Editing;
  GridFatIzlemViewURT.Options.Editing := True;  //GridFatIzlemViewSERINO.Options.Editing;

  TabIzlem.FieldByName('STOKID').AsInteger := StokID;
  TabIzlem.FieldByName('IZLEMID').AsInteger := 0;
  if GerekliMiktar<>KALAN then
     TabIzlem.FieldByName('KALAN').AsFloat := KALAN
  else
     TabIzlem.FieldByName('KALAN').AsFloat := 1;
  if IslemTur=6 then
     TabIzlem.FieldByName('URT').AsDateTime := Tablo.GENINI.BugunTrh
  else
     TabIzlem.FieldByName('URT').AsDateTime := EncodeDate(1990, 1, 1);
  TabIzlem.FieldByName('SEC').AsBoolean := True;
  //TabIzlem.FieldByName('SKT').AsDateTime := Tablo.GENINI.BugunTrh;
end;

procedure TIzlemeDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  Tablo.GridAyarRestore('GridFatIzlemGridi', GridFatIzlemView);
end;

procedure TIzlemeDlg.FormDestroy(Sender: TObject);
var s:string;  //Komut
    Carpan:String[10];
    ID : Integer;//, DonusId, SeriLotId
  //  kalan, fark : real; }

    function Insert(Tur : char; IDD:Integer=0):integer; //where:string
    //var SKT, URT : String[20];
    (*
        Procedure DepoInsert(IzlemId,DepoId:Integer; Miktars:real);
        begin
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into STOKIZLEMEDEPO (IZLEMID, DEPOID, ADET) values('+
                      IntToStr(IzlemId)+','+IntToStr(DepoId)+','+stringreplace(FloatToStr(Miktars),',','.',[])+')', [], []);
        end;
              *)
    begin

      case Tur of
        'G' : s:='';
        'C' : s:=' where SEC = 1 and KALAN <> 0.0 '; //Çıkış ise
        'D' : s:=' where ID='+IntToStr(IDD); //Dönüşüm ise
      end;
      Tablo.TablodanSorguAc(8, 'select * from '+TabloAdi+s);
      Tablo.IzlemBilgisiKaydet(Tablo.Query8, IslemTur,IslemTip, KaynakSatirID, BaslikID, SatirID, IzlemTur, GirDepo, CikDepo, StokDurumDegis);
      (* 27.11.2024 AO
      Tablo.Query8.First;
      while not Tablo.Query8.Eof do begin
        //Giriş ise hepsini kaydet çıkış ise işaretli ve kalanı sıfırdan büyük olanlar
        //if (Tur='G')or( (Tur='C')and(Tablo.Query8.FieldByName('SEC').AsBoolean=True)and(Tablo.Query8.FieldByName('KALAN').AsInteger>0) ) then begin
                //Komut := 'insert into STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,IZLEMTUR,KALAN,ADET,SERINO,' +
                //                            'EKLEYEN,LOTNO,SKT,URT,DONUSID)';
                //daha önce bu serilotlar var mı bakalım yoksa tabloya ekleyelim
                Tablo.TablodanSorguAc(1, 'select '+DbUst(1)+'ID from STOKSERILOT where STOKID='+Tablo.Query8.FieldByName('STOKID').AsString+
                  ' and SERINO='''+Tablo.Query8.FieldByName('SERINO').AsString+''' and LOTNO='''+Tablo.Query8.FieldByName('LOTNO').AsString+''' '+DbSinir(1));
                if Tablo.Query1.RecordCount>0 then
                    SeriLotId := Tablo.Query1.Fields[0].AsInteger
                else begin
                    if Tablo.Query8.FieldByName('SKT').AsString<>'' then
                       SKT:=FormatDateTime('yyyy-mm-dd', Tablo.Query8.FieldByName('SKT').AsDateTime)
                    else
                       SKT:='1990-01-01';
                    if Tablo.Query8.FieldByName('URT').AsString<>'' then
                       URT:=FormatDateTime('yyyy-mm-dd', Tablo.Query8.FieldByName('URT').AsDateTime)
                    else
                       URT:='1990-01-01';
                    Komut := 'INSERT INTO [STOKSERILOT] ([STOKID],[SERINO],[LOTNO],[URT],[SKT])';
                    Komut := Komut + ' values('+Tablo.Query8.FieldByName('STOKID').AsString+','''+ Tablo.Query8.FieldByName('SERINO').AsString+''','+
                                   ''''+Tablo.Query8.FieldByName('LOTNO').AsString+''','''+URT+''','''+SKT+''')';
                    SeriLotId := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,Komut+' select scope_identity()',[],[],True);
                end;
                //////
                Komut := 'insert into STOKIZLEME(STOKID,BELGETUR,BASLIKID,SATIRID,IZLEMTUR,KALAN,ADET, EKLEYEN, DONUSID, SERILOTID)';
                {27.11.2024 AO syok sayım fişi depoları etkilememeli, sadece hangi lottan ne kadar var bilgisi bulunmalıdı
                if IslemTur=KasaTur_StokSayimIslemi then //99 eğer sayım varsa lotu 5 olan üründen sistemde 10 varsa ve sayımda 8 gelmişse  8-10=-2 ekleriz (Yani çıkarırız)
                   Miktar := Tablo.Query8.FieldByName('KALAN').AsFloat - Tablo.Query8.FieldByName('DURUM').AsFloat// '(KALAN-DURUM)'
                else }
                   kalan := Tablo.Query8.FieldByName('KALAN').AsFloat;//'KALAN';

                if IslemTur=KasaTur_StokSayimIslemi then
                   fark := kalan - Tablo.Query8.FieldByName('DURUM').AsFloat
                else
                   fark := kalan;

                if KaynakSatirID>0 then //dönüşüm varsa
                   DonusId := Tablo.Query8.FieldByName('IZLEMID').AsInteger //'IZLEMID'
                else
                   DonusId := 0;
                //   29/09/2021
                Komut := Komut + ' values('+Tablo.Query8.FieldByName('STOKID').AsString+','+IntToStr(IslemTur)+','+IntToStr(BaslikID)+','+IntToStr(SatirID)+','+
                                   IntToStr(IzlemTur)+','+stringreplace( FloatToStr(fark), ',', '.', [])+','+stringreplace(FloatToStr(kalan),',','.',[])+','+Kullanan+','+IntToStr(DonusId)+','+IntToStr(SeriLotId)+')';
    {           Komut := Komut + ' select STOKID,'+IntToStr(DepoID)+','+IntToStr(IslemTur)+','+IntToStr(BaslikID)+','+IntToStr(SatirID)+','+
                                         IntToStr(IzlemTur)+','+s+','+s+', isnull(SERINO,''''),'+Kullanan+',isnull(LOTNO,''''),isnull(SKT,''1990-01-01''),isnull(URT,''1990-01-01''),'+DonusId+
                          ' from '+TabloAdi; }
               Result := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,Komut+' select scope_identity()',[],[],True);

               // depo ayarlanır
               if StokDurumDegis=False then  //dönüşüm varsa ve daha önce irsaliye ile çıkıldıysa depodan çıkış yapılmaz
                  kalan := 0;


               if IslemTur <> KasaTur_StokSayimIslemi then  begin //27.11.2024 AO sayımda depolarda artma eksilme olmayacak, giriş çıkış fişleriyle olacak
                   if (IslemTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,
                                            KasaTur_Giden_Konsinye, {KasaTur_StokSayimIslemi,} KasaTur_StokTransferi, KasaTur_Uretim_Sarf]) then
                      DepoInsert(Result, CikDepo, -1.0*kalan)
                   else
                      DepoInsert(Result, GirDepo, kalan);

                   if IslemTur in [KasaTur_Giden_Konsinye, KasaTur_StokTransferi] then
                      DepoInsert(Result, GirDepo, kalan)
                   else if (IslemTur in [KasaTur_Gelen_Konsinye])and(IslemTip=2)  then  //iade konsinye ise konsinyeden çıkış anadepoya giriş olmalı
                      DepoInsert(Result, CikDepo, -1*kalan);
                end;


        //end;
        Tablo.Query8.Next
      end;   *)
    end;
begin
    if Kaydedilebilir=False then
       exit;
    // Önce eski kayıtları silelim
//    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEMEDEPO where IZLEMID in '+
//       '(select ID from STOKIZLEME where STOKID=&StkID and BASLIKID=&BlgID and SATIRID=&StrID)',['&StkID','&BlgID','&StrID'],[StokID,BaslikID,SatirID]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKIZLEME where STOKID=&StkID and BASLIKID=&BlgID and SATIRID=&StrID',['&StkID','&BlgID','&StrID'],[StokID,BaslikID,SatirID]);
{    if (IslemTur in [KasaTur_DigerCikisFisi,KasaTur_SatisFaturasi,KasaTur_SatisFisi,KasaTur_SatisIrsaliyesi,KasaTur_Giden_Konsinye,KasaTur_StokSayimIslemi]) then begin
       Carpan :='-1*';
       DepoId := CikDepo;
    end else begin
       Carpan :='';
       DepoId := GirDepo;
    end;   }
    //////
    if KaynakSatirId>0 then begin//dönüşüm varsa
       TabIzlem.First;
       while not TabIzlem.eof do begin
          if (TabIzlem.FieldByName('SEC').AsString='True')and(TabIzlem.FieldByName('KALAN').AsFloat > 0) then begin
              //ID := Insert(' where ID='+TabIzlem.Fields[0].AsString);
              ID := Insert('D', TabIzlem.Fields[0].AsInteger);
          end;
          TabIzlem.Next;
       end;
    end
    else begin
            //çıkış kayıtları ise eksi ile çarpalım
            if GridFatIzlemViewSEC.Visible then begin
               Insert('C');//' where SEC = 1 and KALAN <> 0 ');
{               if IslemTur=KasaTur_StokTransferi then begin //sadece transfer işlemi için stokizlemde 2 satır oluşturulur
                  Carpan :='-1*';
                  DepoId := CikDepo;
                  Insert(' where SEC = 1 and KALAN <> 0 ');
               end  }
            end else
               Insert('G');
    end;
end;

end.

{
select *  FROM FATURA WHERE URUNID=7762
select * FROM STOKSERILOT WHERE STOKID=7762
select * FROM STOKIZLEME WHERE STOKID=7762
select * FROM STOKDURUM WHERE STOKID=7762
select * FROM STOKDURUMIZLEME WHERE STOKID=7762
select * FROM STOKIZLEMEDEPO where IZLEMID=34


--DELETE FROM FATURA WHERE URUNID=7762
--DELETE FROM STOKSERILOT WHERE STOKID=7762
--DELETE FROM STOKIZLEME WHERE STOKID=7762
--DELETE FROM STOKDURUM WHERE STOKID=7762
--DELETE FROM STOKDURUMIZLEME WHERE STOKID=7762
}



