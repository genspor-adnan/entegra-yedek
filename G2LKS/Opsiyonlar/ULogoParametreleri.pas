unit ULogoParametreleri;

interface

// PR00432_SI0_FN99_PN1_ID1739_DT18112007_TM1313.XML satýþ faturalarý
// PR00601_SI0_FN99_PN1_ID1854_DT18112007_TM1313.XML kasa fiþleri
// PR00701_SI0_FN99_PN1_ID1858_DT18112007_TM1313.XML cari hesap fiþleri

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxSpinEdit;

{$I options.inc}

type
  TlogoParametreleriForm = class(TFrame)
    Label1: TLabel;
    sunucuAdiEdit: TEdit;
    Label2: TLabel;
    sirketNoSpinEdit: TcxSpinEdit;
    Label3: TLabel;
    logoOzelKoduEdit: TEdit;
    Label4: TLabel;
    veritabaniEdit: TEdit;
    kasaIslemTipiComboBox: TComboBox;
    Label6: TLabel;
    satisFaturaTipiComboBox: TComboBox;
    Label7: TLabel;
    faturaKalemiTipiComboBox: TComboBox;
    nakitIcinKasaIslemiEkleCheckBox: TCheckBox;
    kasaIslemiCariKullanCheckBox: TCheckBox;
    faturaNoIcinBelgeNoKullan: TCheckBox;
  private
    { Private declarations }
    procedure SaveContentMsg(var Msg: TMessage);message WM_SAVECONTENT;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
  end;

implementation
uses
  UOpsiyon,UTablo, ECXMLParser, FetaUtil;

{$R *.dfm}

{ TlogoParametreleriForm }

constructor TlogoParametreleriForm.Create(AOwner: TComponent);
var
  node : TXMLItem;
begin
  inherited;
  // sunucu adý ve veritabaný
  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=sunucu_adi'
    ,Tablo.configuration.Root);
  sunucuAdiEdit.Text := node.Params.Values['sunucu'];
  veritabaniEdit.Text := node.Params.Values['veritabani'];

  // firma numarasý
  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
  sirketNoSpinEdit.Value := StrToIntDef(node.Params.Values['firma'],1);
  // logo özel kodu
  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=logo_ozel_kod'
    ,Tablo.configuration.Root);
  logoOzelKoduEdit.Text := node.Params.Values['ozelkod'];
  // fatura ile ilgili parametereler
  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=donusum_parametereleri'
    ,Tablo.configuration.Root);
  kasaIslemTipiComboBox.ItemIndex := StrToIntDef(node.Params.Values['kasa_islem_tipi'],0);
  nakitIcinKasaIslemiEkleCheckBox.Checked := StrToIntDef(node.Params.Values['nakit_fatura_kasa_islemi_kullan'],1) = 1;
  satisFaturaTipiComboBox.ItemIndex := StrToIntDef(node.Params.Values['satis_fatura_tipi'],0);
  faturaKalemiTipiComboBox.ItemIndex := StrToIntDef(node.Params.Values['fatura_kalemi_tipi'],0);
  kasaIslemiCariKullanCheckBox.Checked := StrToIntDef(node.Params.Values['kasa_islemi_cari_kullan'],1) = 1;
  faturaNoIcinBelgeNoKullan.Checked := StrToIntDef(node.Params.Values['faturano_icin_belgeno_kullan'],1) = 1;
end;

procedure TlogoParametreleriForm.SaveContentMsg(var Msg: TMessage);
var
  node : TXMLItem;
begin
  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=sunucu_adi',Tablo.configuration.Root);
  node.Params.Values['sunucu'] := sunucuAdiEdit.Text;
  node.Params.Values['veritabani'] := veritabaniEdit.Text;

  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
  node.Params.Values['firma'] := IntToStr(sirketNoSpinEdit.Value);

  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=logo_ozel_kod',Tablo.configuration.Root);
  node.Params.Values['ozelkod'] := logoOzelKoduEdit.Text;
  
  // fatura ile ilgili parametreler
  node := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=donusum_parametereleri'
    ,Tablo.configuration.Root);
  node.Params.Values['kasa_islem_tipi'] := IntToStr(kasaIslemTipiComboBox.ItemIndex);
  node.Params.Values['satis_fatura_tipi'] := IntToStr(satisFaturaTipiComboBox.ItemIndex);
  node.Params.Values['fatura_kalemi_tipi'] := IntToStr(faturaKalemiTipiComboBox.ItemIndex);
  node.Params.Values['nakit_fatura_kasa_islemi_kullan'] := IIf(nakitIcinKasaIslemiEkleCheckBox.Checked,'1','0');
  node.Params.Values['kasa_islemi_cari_kullan'] := IIf(kasaIslemiCariKullanCheckBox.Checked,'1','0');
  node.Params.Values['faturano_icin_belgeno_kullan'] := IIf(faturaNoIcinBelgeNoKullan.Checked,'1','0');
end;

initialization
  //RegisterOption(1,'Genel/Logo Parametreleri',TlogoParametreleriForm);

end.
