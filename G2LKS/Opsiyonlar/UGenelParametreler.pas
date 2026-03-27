unit UGenelParametreler;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst,Db,ADODB, Grids, ValEdit, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridCustomTableView, cxGridTableView, cxControls, cxGridCustomView,
  cxClasses, cxGridLevel, cxGrid, cxDropDownEdit, cxDBLookupComboBox,
  ExtCtrls, AppEvnts, Spin, JvExStdCtrls, JvGroupBox;

{$I options.inc}

type
  TGenelParametrelerForm = class(TFrame)
    kurumListesiCheckListBox: TCheckListBox;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    kasaKoduEdit: TEdit;
    kasaKoduGetirButton: TButton;
    Label3: TLabel;
    kasaMuhasebeKoduEdit: TEdit;
    faturalamaModeliRadioGroup: TRadioGroup;
    hastaIcinKodOlusturGroupBox: TJvGroupBox;
    Label4: TLabel;
    dosyaNoOnEkiEdit: TEdit;
    GroupBox3: TJvGroupBox;
    hesapPlaniOnEkiEdit: TEdit;
    Label5: TLabel;
    hastaAdiIlkHarfKullanCheckBox: TCheckBox;
    Label6: TLabel;
    OnEkSonrasiSifirSayisiSpinEdit: TSpinEdit;
    faturaKalemleriniDonusturmeGroupBox: TJvGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    faturaKalemKodEdit: TEdit;
    Label9: TLabel;
    faturaKalemMuhKodEdit: TEdit;
    checkStokOnayliAktarim: TCheckBox;
    procedure kasaKoduGetirButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure SaveContentMsg(var Msg: TMessage);message WM_SAVECONTENT;
    procedure LoadOptions;
    procedure SaveOptions;
  public
    { Public declarations }
    constructor Create(AOwner : TComponent);override;

  end;

implementation
uses
  UTablo,UOpsiyon,FetaUtil, ECXMLParser, ULksVeriArama, UKurumEslestirmeleri;

{$R *.dfm}

{ TGenelParametrelerForm }

constructor TGenelParametrelerForm.Create(AOwner: TComponent);
begin
  inherited;
  LoadOptions;
end;

procedure TGenelParametrelerForm.LoadOptions;

procedure FillList;
begin
  kurumListesiCheckListBox.Items.Clear;
  with _query_exec(Tablo.cnn,'SELECT KURUM FROM KURUM',[],[]) do
  try
    Open;
    while not Eof do begin
      kurumListesiCheckListBox.Items.Add(Fields[0].AsString);
      Next;
    end;
  finally
    Free;
  end;
end;

var
  ANode : TXMLItem;
  i : Integer;
  j : Integer;
begin
  FillList;
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=referansli_kurumlar/REFERANSLAR'
    ,Tablo.configuration.Root);
  for i := 0 to ANode.Count - 1 do begin
    j := kurumListesiCheckListBox.Items.IndexOf(ANode[i].Params.Values['adi']);
    if (j >= 0) and (ANode[i].Params.Values['kullan'] = '1') then
      kurumListesiCheckListBox.Checked[j] := True;
  end;

  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=kasa_kodu'
    ,Tablo.configuration.Root);
  kasaKoduEdit.Text := ANode.Params.Values['kasakodu'];
  kasaMuhasebeKoduEdit.Text := ANode.Params.Values['kasamuhasebekodu'];

  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=faturalama_modeli'
    ,Tablo.configuration.Root);
  faturalamaModeliRadioGroup.ItemIndex := StrToIntDef(ANode.Params.Values['model'],1);
  hastaIcinKodOlusturGroupBox.Checked := StrToIntDef(ANode.Params.Values['hasta_icin_yeni_kayit_olustur'],0) = 1;

  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=on_ekler'
    ,Tablo.configuration.Root);
  dosyaNoOnEkiEdit.Text := ANode.Params.Values['dosyano_onek'];
  hesapPlaniOnEkiEdit.Text := ANode.Params.Values['hesapplani_onek'];
  hastaAdiIlkHarfKullanCheckBox.Checked := ANode.Params.Values['hasta_ilk_harf_kullan'] = '1';
  OnEkSonrasiSifirSayisiSpinEdit.Value := StrToIntDef(ANode.Params.Values['on_ek_sonrasi_sifir_sayisi'],4);

  // Fatura Kalemlerini Dönüþtürme
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=fatura_kalemleri'
    ,Tablo.configuration.Root);
  faturaKalemleriniDonusturmeGroupBox.Checked := ANode.Params.Values['fatura_kalemleri_donusmesin'] = '1';
  faturaKalemKodEdit.Text := ANode.Params.Values['sabit_fatura_kalemi_kod'];
  faturaKalemMuhKodEdit.Text := ANode.Params.Values['sabit_fatura_kalemi_muh_kod'];
 // checkStokOnayliAktarim.Checked:=  GenotipIni.ReadBool('G2LKS','StokOnayliAktarim',False);
end;

procedure TGenelParametrelerForm.SaveContentMsg(var Msg: TMessage);
begin
  SaveOptions;
end;

procedure TGenelParametrelerForm.SaveOptions;
var
  ANode : TXMLItem;
  i     : Integer;
begin
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=referansli_kurumlar'
    ,Tablo.configuration.Root);
  ANode.Clear;
  ANode.Name := 'AYAR';
  ANode.Params.Add('adi=referansli_kurumlar');
  with ANode.New do begin
    Name := 'REFERANSLAR';
    for i := 0 to kurumListesiCheckListBox.Items.Count - 1 do begin
      if (kurumListesiCheckListBox.Checked[i]) then
        with New do begin
          Name := 'REFERANS';
          Params.Add('adi=' + kurumListesiCheckListBox.Items[i]);
          Params.Add('kullan=1');  
        end;
    end;//for
  end;//with
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=kasa_kodu'
    ,Tablo.configuration.Root);
  ANode.Params.Values['kasakodu'] := kasaKoduEdit.Text;
  ANode.Params.Values['kasamuhasebekodu'] := kasaMuhasebeKoduEdit.Text;
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=on_ekler'
    ,Tablo.configuration.Root);
  ANode.Params.Values['dosyano_onek'] := dosyaNoOnEkiEdit.Text;
  ANode.Params.Values['hesapplani_onek'] := hesapPlaniOnEkiEdit.Text;
  ANode.Params.Values['on_ek_sonrasi_sifir_sayisi'] := IntToStr(OnEkSonrasiSifirSayisiSpinEdit.Value);
  if (hastaAdiIlkHarfKullanCheckBox.Checked) then
    ANode.Params.Values['hasta_ilk_harf_kullan'] := '1'
  else
    ANode.Params.Values['hasta_ilk_harf_kullan'] := '0';
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=faturalama_modeli'
    ,Tablo.configuration.Root);
  ANode.Params.Values['model'] := IntToStr(faturalamaModeliRadioGroup.ItemIndex);
  if hastaIcinKodOlusturGroupBox.Checked then
    ANode.Params.Values['hasta_icin_yeni_kayit_olustur'] := '1'
  else
    ANode.Params.Values['hasta_icin_yeni_kayit_olustur'] := '0';
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=fatura_kalemleri'
    ,Tablo.configuration.Root);
  if (faturaKalemleriniDonusturmeGroupBox.Checked) then
    ANode.Params.Values['fatura_kalemleri_donusmesin'] := '1'
  else
    ANode.Params.Values['fatura_kalemleri_donusmesin'] := '0';
  ANode.Params.Values['sabit_fatura_kalemi_kod'] := faturaKalemKodEdit.Text;
  ANode.Params.Values['sabit_fatura_kalemi_muh_kod'] := faturaKalemMuhKodEdit.Text;
 // GenotipIni.WriteBool('G2LKS','StokOnayliAktarim',checkStokOnayliAktarim.Checked);
end;

const
  listQueryKasa  : string =
    'SELECT C.CODE,C.NAME AS [DEFINITION_], muh.CODE AS [MUHCODE] FROM LG_%firmcode%_KSCARD C (NOLOCK) ' +
    'RIGHT OUTER JOIN LG_%firmcode%_CRDACREF ref (NOLOCK) ON c.LOGICALREF = ref.CARDREF LEFT OUTER JOIN ' +
    'LG_%firmcode%_EMUHACC muh (NOLOCK) ON ref.ACCOUNTREF = muh.LOGICALREF  WHERE ' +
    '(C.ACTIVE = 0) and (ref.TRCODE = 8)ORDER BY C.NAME';

procedure TGenelParametrelerForm.kasaKoduGetirButtonClick(Sender: TObject);
var
  ANode : TXMLItem;
  firmNo: Integer;
  Result  : TReturnValues;
  KurumEsleme: TkurumEslemeForm;
begin
  ANode := Tablo.GetNode('LKS/AYARLAR/GENEL_AYARLAR/AYAR?adi=firma_numarasi',Tablo.configuration.Root);
  if (Assigned(ANode)) then begin
    if Tablo.TryToConnectDatabase then begin
      firmNo := StrToIntDef(ANode.Params.Values['firma'],1);
      Result := ShowAraForm(Tablo.lksConnection,StringReplace(listQueryKasa,'%firmcode%',LeadingZero(firmNo,3),
        [rfReplaceAll]),kasaKoduEdit.Text);
      if ((Length(Result) > 0) and (Result[0] <> '')) then begin
        kasaKoduEdit.Text := Result[0];
        kasaMuhasebeKoduEdit.Text := Result[2];
      end;
    end;
  end;
end;

initialization
  //RegisterOption(2,'Genel/Parametreler',TGenelParametrelerForm);

end.
    
