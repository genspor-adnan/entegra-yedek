unit UTakvimSenet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore,  cxControls, cxContainer, cxEdit, cxLabel, GIFImg,
  ExtCtrls, JvExExtCtrls, JvImage, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxCalendar, cxDBEdit, DB, FireDAC.Comp.Client, cxCurrencyEdit, Utablo, UGirisKutusuEx,
  cxDBLabel,UParaDegisiklik, dxSkinLondonLiquidSky, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTakvimSenetDlg = class(TForm)
    JvImage1: TJvImage;
    JvImage2: TJvImage;
    JvImage3: TJvImage;
    JvImage4: TJvImage;
    JvImage5: TJvImage;
    JvImage6: TJvImage;
    JvImage7: TJvImage;
    JvImage8: TJvImage;
    JvImage9: TJvImage;
    JvImage11: TJvImage;
    JvImage12: TJvImage;
    JvImage13: TJvImage;
    JvImage14: TJvImage;
    JvImage10: TJvImage;
    JvImage15: TJvImage;
    JvImage16: TJvImage;
    JvImage17: TJvImage;
    JvImage18: TJvImage;
    cxLabel3: TcxLabel;
    JvImage19: TJvImage;
    JvImage20: TJvImage;
    cxLabel4: TcxLabel;
    LabelTutar: TcxLabel;
    LabelKur: TcxLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    cxLabel12: TcxLabel;
    cxLabel13: TcxLabel;
    cxLabel14: TcxLabel;
    cxLabel15: TcxLabel;
    cxLabel16: TcxLabel;
    cxLabel17: TcxLabel;
    cxLabel18: TcxLabel;
    cxLabel19: TcxLabel;
    cxLabel20: TcxLabel;
    cxLabel22: TcxLabel;
    cxLabel21: TcxLabel;
    cxLabel23: TcxLabel;
    cxLabel25: TcxLabel;
    cxLabel26: TcxLabel;
    cxLabel27: TcxLabel;
    cxDBDateEdit1: TcxDBLabel;
    cxDBDateEdit3: TcxDBLabel;
    DtsSenetler: TDataSource;
    EditKur1: TcxDBLabel;
    cxDBTextEdit1: TcxDBLabel;
    LabelOdeIsim: TcxDBLabel;
    LabelOdeAdres: TcxDBLabel;
    LabelOdeVD: TcxDBLabel;
    LabelOdeKefil: TcxDBLabel;
    LabelOdeIlce: TcxDBLabel;
    TabSenetler: TFDQuery;
    cxDBTextEdit7: TcxDBLabel;
    cxDBTextEdit8: TcxDBLabel;
    LabelAlFirma: TcxDBLabel;
    LabelOdeIl: TcxDBLabel;
    cxDBTextEdit2: TcxDBLabel;
    procedure FormShow(Sender: TObject);
    procedure LabelOdeKefilClick(Sender: TObject);
    procedure EditKur1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    Tur,ID:Integer;
    { Public declarations }
  end;

var
  TakvimSenetDlg: TTakvimSenetDlg;


implementation

  Uses LocOnFly,PrjConst;

{$R *.dfm}

procedure TTakvimSenetDlg.EditKur1Click(Sender: TObject);
begin
  Application.CreateForm(TParaDegisiklikDlg,Paradegisiklikdlg);
  Paradegisiklikdlg.KurTarihi := TabSenetler.FieldByName('TARIH').AsDateTime; //KasaTarihi.Date;
  Paradegisiklikdlg.GirenTutar := TabSenetler.FieldByName('TUTAR').AsCurrency; //EditTahsilatTutar.Value;
  Paradegisiklikdlg.GirenKur := TabSenetler.FieldByName('KUR').AsString; //ComboKurTah.Text;
  Paradegisiklikdlg.CikanTutar := TabSenetler.FieldByName('DOVIZ_TUTARI').AsCurrency; //EditDovizTutar.Value;
  Paradegisiklikdlg.CikanKur := TabSenetler.FieldByName('DOVIZ_KURU').AsString; //ComboDovizTutar.Text;
  Paradegisiklikdlg.ShowModal;
  if Paradegisiklikdlg.ModalResult = mrOk then begin
     if DtsSenetler.State <> dsEdit then
        TabSenetler.Edit;
     TabSenetler.FieldByName('TUTAR').Value := Paradegisiklikdlg.GirenTutar;
     TabSenetler.FieldByName('KUR').Value := Paradegisiklikdlg.GirenKur;
     TabSenetler.FieldByName('DOVIZ_TUTARI').Value := Paradegisiklikdlg.CikanTutar;
     TabSenetler.FieldByName('DOVIZ_KURU').Value := Paradegisiklikdlg.CikanKur;
     TabSenetler.Post;
  end;
  Paradegisiklikdlg.Free;
  FormShow(Self);
end;

procedure TTakvimSenetDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTakvimSenetDlg.FormShow(Sender: TObject);
begin
  TabSenetler.Close;
  case Tur of
    24:begin //giren
      //ödeyecek tarafın bilgileri
      LabelOdeIsim.DataBinding.DataSource:=DtsSenetler;
      LabelOdeAdres.DataBinding.DataSource:=DtsSenetler;
      LabelOdeIlce.DataBinding.DataSource:=DtsSenetler;
      LabelOdeIl.DataBinding.DataSource:=DtsSenetler;
      LabelOdeVD.DataBinding.DataSource:=DtsSenetler;
      //ödenecek tarafın bilgileri
      LabelAlFirma.DataBinding.DataSource:=Tablo.DtsBizim;
    End;
    34:Begin//çıkan
      //ödeyecek tarafın bilgileri
      LabelOdeIsim.DataBinding.DataSource:=Tablo.DtsBizim;
      LabelOdeAdres.DataBinding.DataSource:=Tablo.DtsBizim;
      LabelOdeIlce.DataBinding.DataSource:=Tablo.DtsBizim;
      LabelOdeIl.DataBinding.DataSource:=Tablo.DtsBizim;
      LabelOdeVD.DataBinding.DataSource:=Tablo.DtsBizim;
      //ödenecek tarafın bilgileri
      LabelAlFirma.DataBinding.DataSource:=DtsSenetler;
    End;
  end;
  TabSenetler.Params[0].Value:=ID;
  TabSenetler.Open;
end;

procedure TTakvimSenetDlg.LabelOdeKefilClick(Sender: TObject);
Var
   alanTuru,alanAdi,alanOwner : String;
   eskiad : Variant;
   ctrls : TGirdiDenetimleri;
   tab : TDataSet;
begin
   alanAdi := TcxDBLabel(Sender).DataBinding.DataField ;
   eskiad := TcxDBLabel(Sender).Caption;
   tab := (TcxDBLabel(Sender).DataBinding.DataSource.DataSet as TFDQuery);
      //edit bilgi girişi
   case TcxDBLabel(Sender).Tag of
      0:ctrls := TGirdiDenetimleri.Create.Edit(('Yeni '+alanAdi+' Değeri'),@eskiad);  //1 alacakli,3borclu ise
      1:ctrls := TGirdiDenetimleri.Create.DateTimePicker(('Yeni '+alanAdi+' Değeri'),@eskiad)
   end;
   if TGirisKutusuEx.BilgiAlEx(BGBilgi_gir,ctrls) = mrOK then begin
     if Trim(eskiad) = '' then begin
        MessageDlg((BGYeni+alanAdi+BGDegeri_bos_olamaz),mtError,[mbOK],0);
        Exit;
     End else begin
        tab.Edit;
        tab.FieldByName(alanAdi).AsVariant:= eskiad;
        tab.Post;
        tab.Close;
        tab.Open;
     end;
   end;
end;

end.



