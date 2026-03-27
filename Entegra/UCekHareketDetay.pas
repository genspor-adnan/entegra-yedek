unit UCekHareketDetay;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, Vcl.ComCtrls, dxCore, cxDateUtils, Vcl.StdCtrls,
  Vcl.Buttons, Vcl.ExtCtrls, cxCurrencyEdit, cxCheckBox, cxTextEdit, cxMaskEdit,
  cxDropDownEdit, cxCalendar, cxLabel, cxMemo, UTablo, PrjConst, cxDBEdit,
  cxButtonEdit, FetaKurulusSiniflari;

type
  TCekHareketDetayDlg = class(TForm)
    cxLabel1: TcxLabel;
    DateTarih: TcxDateEdit;
    EdDovizTutari: TcxCurrencyEdit;
    ServisHarPanelAlt: TPanel;
    KaydetTus: TBitBtn;
    IptalTus: TBitBtn;
    LabelDovizTuru: TcxLabel;
    cxLabel3: TcxLabel;
    PanelKarsilik: TPanel;
    EditKulKur: TcxCurrencyEdit;
    CbDovizKuru: TcxComboBox;
    cbKur: TcxComboBox;
    EdTutar: TcxCurrencyEdit;
    memoAciklama: TcxMemo;
    cxLabel2: TcxLabel;
    cxLabel4: TcxLabel;
    edCekTutar: TcxCurrencyEdit;
    cbCekKur: TcxComboBox;
    CheckExtredeKullan: TcxCheckBox;
    edIsKur: TcxCurrencyEdit;
    BeditProje: TcxButtonEdit;
    cxLabel5: TcxLabel;
    EditMM: TcxButtonEdit;
    cxLabel6: TcxLabel;
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure LabelDovizTuruClick(Sender: TObject);
    procedure EdTutarPropertiesEditValueChanged(Sender: TObject);
    procedure cbKurPropertiesEditValueChanged(Sender: TObject);
    procedure EditKulKurPropertiesEditValueChanged(Sender: TObject);
    procedure DateTarihPropertiesEditValueChanged(Sender: TObject);
    procedure EdDovizTutariPropertiesEditValueChanged(Sender: TObject);
    procedure edIsKurPropertiesEditValueChanged(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure EdDovizTutariKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edIsKurKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DateTarihKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditKulKurKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbKurKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BeditProjePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditMMPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
  public
    RehberId, IslemTuru: integer;

    { Public declarations }
  end;

var
  CekHareketDetayDlg: TCekHareketDetayDlg;
implementation

{$R *.dfm}

procedure TCekHareketDetayDlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  st: Tstringlist;
  SQL : string;
begin
  SQL:='SELECT P.ID,P.PROJEKODU,P.KONUSU,P.PROJEADI,R.FIRMA   ';
  SQL:= SQL + ' FROM PROJELER P inner join REHBER R on P.REHBERID=R.ID  ';
  SQL:= SQL + ' where  (P.KONUSU like ''%<ara>%'' or P.PROJEKODU like ''%<ara>%'' or P.PROJEADI like ''%<ara>%'' or R.FIRMA like ''%<ara>%'') and P.DURUM=1  ';
  if AButtonIndex < 2 then begin
    if AButtonIndex = 1 then
      SQL:=SQL+'and REHBERID=' + IntToStr(RehberId);
    try
      st := Tstringlist.create;
      if Tablo.ListedenBilgiGetir(ProjeSecimi,SQL, st, []) then begin
        BeditProje.Text := st.Strings[1];
        BeditProje.Tag := StrToIntDef(st.Strings[0],0);
      end;
    finally
      st.free;
    end
  end else begin
    BeditProje.Text := '';
    BeditProje.Tag := 0;
  end;
end;

procedure TCekHareketDetayDlg.cbKurKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  cbKur.PostEditValue;
end;

procedure TCekHareketDetayDlg.cbKurPropertiesEditValueChanged(Sender: TObject);
begin
  if not DovizTakibi then exit;
  if (cbKur.EditValue <> '') and (VarToStr(DateTarih.EditValue) <> '') then begin
    EditKulKur.EditValue := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', DateTarih.Date), VarToStr(cbKur.EditValue), Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
  end;
end;

procedure TCekHareketDetayDlg.DateTarihKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  DateTarih.PostEditValue;
end;

procedure TCekHareketDetayDlg.DateTarihPropertiesEditValueChanged( Sender: TObject);
begin
  if not DovizTakibi then exit;
  if (cbKur.EditValue <> '') and (VarToStr(DateTarih.EditValue) <> '') then begin
    EdIsKur.EditValue := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', DateTarih.Date), VarToStr(cbCekKur.EditValue), Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
    EditKulKur.EditValue := DovizKuruBul(formatdatetime('yyyy-mm-dd 00:00', DateTarih.Date), VarToStr(cbKur.EditValue), Tablo.GENINI.ReadString(Ops_GenelOpsiyon_VarsayilanDoviz,'ALIS'));
  end;
end;

procedure TCekHareketDetayDlg.edIsKurKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //edIsKur.PostEditValue;
end;

procedure TCekHareketDetayDlg.EdDovizTutariKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //EdDovizTutari.PostEditValue;
end;

procedure TCekHareketDetayDlg.EdDovizTutariPropertiesEditValueChanged(Sender: TObject);
var KurDegeri,DovTutari:Extended;
begin

  if (cbKur.EditValue <> '') and (VarToStr(EditKulKur.EditValue) <> '') then begin
    if (EdDovizTutari.EditValue>0.0) and (edCekTutar.EditValue>0.0) then
      edIsKur.EditValue := EdDovizTutari.EditValue / edCekTutar.EditValue;
    KurDegeri := EditKulKur.EditValue;
    DovTutari := EdDovizTutari.EditValue;
    EdTutar.EditValue := DovTutari / KurDegeri;
  end;
end;

procedure TCekHareketDetayDlg.edIsKurPropertiesEditValueChanged(Sender: TObject);
var KurDegeri,DovTutari:Extended;
begin

  if (VarToStr(edIsKur.EditValue) <> '') and (VarToStr(edCekTutar.EditValue) <> '') then begin
    KurDegeri := edIsKur.EditValue;
    DovTutari :=edCekTutar.EditValue;
    EdDovizTutari.EditValue := DovTutari * KurDegeri;
  end;
end;

procedure TCekHareketDetayDlg.EditKulKurKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //EditKulKur.PostEditValue;
end;

procedure TCekHareketDetayDlg.EditKulKurPropertiesEditValueChanged(Sender: TObject);
var KurDegeri,DovTutari:Extended;
begin
  if (cbKur.EditValue <> '') and (VarToStr(EditKulKur.EditValue) <> '') then begin
    KurDegeri := EditKulKur.EditValue;
    DovTutari :=EdDovizTutari.EditValue;
    EdTutar.EditValue := DovTutari / KurDegeri;
  end;
end;

procedure TCekHareketDetayDlg.EditMMPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  MASRAFID, MASRAFKODU, MASRAFMERKEZI, SqlText : string;
  i : SmallInt;
begin
  if AButtonIndex = 0 then begin
    if IslemTuru in [140,131,132,133,134,137] then
      i := 0
    else if IslemTuru in [130,141] then
      i := 1
    else i := -99;
    if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      EditMM.Tag := StrToIntDef(MASRAFID,0);
      EditMM.Hint := MASRAFKODU;
      EditMM.Text := MASRAFMERKEZI;
    end;
  end else if AButtonIndex = 1 then  begin
    EditMM.Tag := 0;
    EditMM.Hint := '';
    EditMM.Text := '';
  end;
end;

procedure TCekHareketDetayDlg.EdTutarPropertiesEditValueChanged(Sender: TObject);
begin
  //EdTutar.PostEditValue;
end;

procedure TCekHareketDetayDlg.FormShow(Sender: TObject);
begin
  if VarToStr(cbCekKur.EditValue)=CariDoviz then begin
    edIsKur.Enabled := False;
    EdDovizTutari.Enabled := False;
  end;
end;

procedure TCekHareketDetayDlg.IptalTusClick(Sender: TObject);
begin
  ModalResult := MrCancel;
end;

procedure TCekHareketDetayDlg.KaydetTusClick(Sender: TObject);
begin
  ModalResult := MrOk;
end;

procedure TCekHareketDetayDlg.LabelDovizTuruClick(Sender: TObject);
begin
  //PanelKarsilik.Visible := not PanelKarsilik.Visible;
end;

end.
