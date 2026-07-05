unit URehberHareket;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel,
  Vcl.ComCtrls, dxCore, cxDateUtils, cxDropDownEdit, cxTextEdit,
  cxMaskEdit, cxCalendar, cxDBEdit, Data.DB, FireDAC.Comp.Client, Utablo,
  Vcl.StdCtrls, Vcl.ExtCtrls, UAnaForm, Vcl.Buttons, cxImageComboBox,
  PrjConst, cxMemo, UTabloGiris, FetaKurulusSiniflari, dxSkinsCore,
  dxSkinLondonLiquidSky, UGirisKutusuEx, cxButtonEdit, dxCoreGraphics,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TRehberPersonelHareket = class(TForm)
    cxLabel1: TcxLabel;
    DateEditHareketTarih: TcxDBDateEdit;
    cxLabel2: TcxLabel;
    ComboHareketTur: TcxDBImageComboBox;
    TabHareket: TFDQuery;
    DtsHareketler: TDataSource;
    lblPoziyon: TcxLabel;
    CombohareketPozisyon: TcxDBImageComboBox;
    Panel1: TPanel;
    BitBtnKaydet: TBitBtn;
    BitBtnIptal: TBitBtn;
    MemoHareketAciklama: TcxDBMemo;
    cxLabel3: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    Memo1: TMemo;
    cxLabel8: TcxLabel;
    cxLabel9: TcxLabel;
    ButtonEditHareketMeslek: TcxButtonEdit;
    pnlSube: TPanel;
    cxLabel4: TcxLabel;
    ComboHareketSube: TcxDBImageComboBox;
    cxLabel7: TcxLabel;
    lblMeslekZorunluGosterge: TcxLabel;
    procedure BitBtnKaydetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabHareketNewRecord(DataSet: TDataSet);
    procedure TabHareketBeforePost(DataSet: TDataSet);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabHareketAfterOpen(DataSet: TDataSet);
    procedure ComboTurPropertiesEditValueChanged(Sender: TObject);
    procedure TabHareketAfterPost(DataSet: TDataSet);
    procedure TabHareketBeforeEdit(DataSet: TDataSet);
  private
    procedure TabActiveControl(Query:TFDQuery);
    function BoslukKontrol:Boolean;
    procedure TurDoldur(DoldurmaTuru: Integer);
    { Private declarations }
  public
    Islem,Tur,DoldurmaTuru,RehberID:Integer;
    YeniKayit:Boolean;
    { Public declarations }
    procedure DisaridanEkle(RehberID: Integer);
  end;

var
  RehberPersonelHareket: TRehberPersonelHareket;

implementation

uses ULog;
var
  MeslekKayitVar:Boolean;

{$R *.dfm}

procedure TRehberPersonelHareket.BitBtnKaydetClick(Sender: TObject);
var
  RehberID:Integer;
  procedure Guncelle(Durum :string);
  begin
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE REHBER SET DURUM='+Durum+' WHERE ID=&REHBERID',['&REHBERID'],[RehberID]);
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE KULLANICI SET DURUM='+Durum+' WHERE REHBERID=&REHBERID',['&REHBERID'],[RehberID]);
  end;
begin
  TabActiveControl(TabHareket);
  RehberID := TabHareket.FieldByName('RehberID').AsInteger;

  if not BoslukKontrol then
  begin
    ModalResult := mrNone;
    Abort;
  end;

  if DtsHareketler.State in [dsEdit,dsInsert] then
  TabHareket.Post;

  //en son hareketse pozisyon güncellenir
  Tablo.TablodanSorguAc(1,'select isnull(max(TARIH), getdate()-1000) from PERS_HAREKET where REHBERID='+IntToStr(RehberID));
  if Tablo.Query1.Fields[0].AsDateTime<=TabHareket.FieldByName('TARIH').AsDateTime then
     Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'UPDATE KULLANICI SET ROLID='+IntToStr(ComboHareketPozisyon.EditValue)+' WHERE REHBERID=&REHBERID',['&REHBERID'],[RehberID]);
  if ComboHareketTur.EditValue = '99' then
     Guncelle('0')
  else if ComboHareketTur.EditValue = '1' then
     Guncelle('1');
end;

procedure TRehberPersonelHareket.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_F4) and (ssAlt in Shift) then
  Key := 0;
end;

/// <summary>
/// Eğer tür 0'sa tüm kayıtlar, 1'se sadece işe giriş, 2'se giriş olmadan, 99'sa sadece işten ayrılma türü gözükecek.
/// </summary>
procedure TRehberPersonelHareket.TurDoldur(DoldurmaTuru:Integer);
begin
  ComboHareketTur.Properties.OnEditValueChanged := nil;
  case DoldurmaTuru of
    0 : ComboHareketTur.Properties.Items := Tablo.imgComboboxInit(' SELECT DEGER, ANAHTAR ' +
                                                                  ' FROM GENINI ' +
                                                                  ' WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_PersonelHareketTur)).Items;
    1 :
    begin
      ComboHareketTur.Properties.Items := Tablo.imgComboboxInit(' SELECT DEGER, ANAHTAR ' +
                                                                ' FROM GENINI ' +
                                                                ' WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_PersonelHareketTur)+
                                                                ' AND DEGER=1').Items;
      TabHareket.Edit;
      TabHareket.FieldByName('TUR').Value := 1;
    end;

    2 : ComboHareketTur.Properties.Items := Tablo.imgComboboxInit(' SELECT DEGER, ANAHTAR ' +
                                                                 ' FROM GENINI ' +
                                                                 ' WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_PersonelHareketTur)+
                                                                 ' AND DEGER!=1').Items;
                                                                 
    3 : ComboHareketTur.Properties.Items := Tablo.imgComboboxInit(' SELECT DEGER, ANAHTAR ' +
                                                                 ' FROM GENINI ' +
                                                                 ' WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_PersonelHareketTur)+
                                                                 ' AND DEGER!=99').Items;

    4 : ComboHareketTur.Properties.Items := Tablo.imgComboboxInit(' SELECT DEGER, ANAHTAR ' +
                                                                 ' FROM GENINI ' +
                                                                 ' WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_PersonelHareketTur)+
                                                                 ' AND DEGER NOT IN (1,99)').Items;

    99 : ComboHareketTur.Properties.Items := Tablo.imgComboboxInit(' SELECT DEGER, ANAHTAR '+
                                                                   ' FROM GENINI ' +
                                                                   ' WHERE BOLUM='+IntToStr(Ops_OpsiyonCari_PersonelHareketTur) +
                                                                   ' AND DEGER=99').Items;
  end;
  ComboHareketTur.Properties.ImmediatePost := False;
  ComboHareketTur.Properties.ImmediateUpdateText := False;
end;

procedure TRehberPersonelHareket.FormShow(Sender: TObject);
var
  IseBaslamis, IstenCikmis, KayitDurumu:Boolean;
  TurNo:Integer;
begin

  if TabHareket.Active then
  begin
    if not TabHareket.FieldByName('REHBERID').IsNull then
    begin
//      Tablo.TablodanSorguAc(1,' SELECT * FROM PERS_HAREKET '+
//                              ' WHERE TUR=1 AND REHBERID='+IntToStr(RehberID));
//      IseBaslamis := (Tablo.Query1.RecordCount > 0);
//      Tablo.TablodanSorguAc(2,' SELECT * FROM PERS_HAREKET '+
//                              ' WHERE TUR=99 AND REHBERID='+IntToStr(RehberID));
//      IstenCikmis := (Tablo.Query2.RecordCount > 0);
//      Tablo.TablodanSorguAc(3,' SELECT TOP 1 * FROM PERS_HAREKET '+
//                              ' WHERE REHBERID='+IntToStr(RehberID));
//      KayitDurumu := (Tablo.Query3.RecordCount > 0);
      Tablo.TablodanSorguAc(4,' SELECT TOP 1 * ' +
                              ' FROM PERS_HAREKET ' +
                              ' WHERE REHBERID='+TabHareket.FieldByName('REHBERID').AsString+
                              ' ORDER BY TARIH,ID DESC');

      TurNo := TabHareket.FieldByName('TUR').AsInteger;
      if (TurNo = 99) and (YeniKayit) then   //son kayıt çıkış ancak yeniden giriş yapılacak
         TurDoldur(1)
      else if (TurNo = 99) and (not YeniKayit) then
         TurDoldur(99)
      else if (TurNo = 1) or (Tablo.Query4.FieldByName('TUR').AsInteger = 99) or Tablo.Query4.IsEmpty then
      begin
        if (not YeniKayit) or (YeniKayit and (Tablo.Query4.FieldByName('TUR').AsInteger = 99)) then
          TurDoldur(1)
        else if (YeniKayit and (Tablo.Query4.FieldByName('TUR').AsInteger = 1)) then
           TurDoldur(2)
        else if YeniKayit then
          TurDoldur(1);
      end
      else if (TurNo <> 99) and (TurNo <> 1) then
      begin
        if (Tablo.Query4.FieldByName('TUR').AsInteger <> 99) and (YeniKayit) then
          TurDoldur(2)
        else TurDoldur(4)
      end;
    end;
  end;

  if YeniKayit then
     TabHareket.FieldByName('ACIKLAMA').AsString := '';

  if SubeVarmi then
    ComboHareketSube.Properties.Items := Tablo.imgComboboxInit('SELECT ID, FIRMA FROM REHBER WHERE ID<0 AND DURUM=1').Items
  else
    pnlSube.Visible := SubeVarmi;

  MeslekKayitVar := Tablo.TablodanSorguAc(1,'SELECT TOP 1 * FROM MESLEKKODLARI');

  //lblMeslekZorunluGosterge.Visible := MeslekKayitVar;

  ComboHareketPozisyon.Properties.Items := Tablo.imgComboboxInit('SELECT ID, ROL FROM ROLLER WHERE ID>-1').Items;

  case islem of
    1:
    begin
      if SubeId < 0 then
      begin
        TabHareket.Edit;
        TabHareket.FieldByName('SUBEID').Value := SubeId;
      end;
      RehberPersonelHareket.BorderIcons := [];
      BitBtnIptal.Enabled := False;
      if Tur > 0 then
      begin
        ComboHareketTur.Enabled := False;
        ComboHareketTur.EditValue := Tur;
      end;
    end;
  end;
  ComboHareketTur.Properties.OnEditValueChanged:= ComboTurPropertiesEditValueChanged;

end;

procedure TRehberPersonelHareket.TabActiveControl(Query: TFDQuery);
begin
  if not Query.Active then Abort;
end;

procedure TRehberPersonelHareket.TabHareketAfterOpen(DataSet: TDataSet);
begin
  if not TabHareket.FieldByName('MESLEKID').IsNull then
  ButtonEditHareketMeslek.Text := Tablo.AciklamaGetir('MESLEKKODLARI','AD', TabHareket.FieldByName('MESLEKID').AsString);
end;

procedure TRehberPersonelHareket.TabHareketAfterPost(DataSet: TDataSet);
begin
  YeniKayit := True;
  LogKartDegisti(TabHareket, TabNo_REHBERPERSONELHAREKET, TabHareket.FieldByName('ID').AsInteger);
end;

procedure TRehberPersonelHareket.TabHareketBeforeEdit(DataSet: TDataSet);
begin
  if LogGun > 0 then
  Tablo.OncekiLogBelirle(TabHareket);
end;

procedure TRehberPersonelHareket.TabHareketBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsHareketler);
end;

// Returns the 0-based index of Value if it's found in the array,
// -1 if not. (Similar to TStrings.IndexOf)
function AScan(const Ar: array of string; const Value: string): Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  for i := Low(Ar) to High(Ar) do
  if SameText(Ar[i], Value) then
  begin
    Result := i;
    Break
  end;
end;

function AScan(const Ar: array of Integer; const Value: Integer): Integer; overload;
var
  i: Integer;
begin
  Result := -1;
  for i := Low(Ar) to High(Ar) do
  if (Ar[i] = Value) then
  begin
    Result := i;
    Break
  end;
end;

function TRehberPersonelHareket.BoslukKontrol:Boolean;
var
  Count,I:Integer;
  boslar:array of string;
begin

  Count := 0;
  if DateEditHareketTarih.Text = '' then Count := Count + 1;
  if (ComboHareketSube.Text = '') and SubeVarmi then Count := Count + 1;
  if ComboHareketTur.Text = '' then Count := Count + 1;
  if ComboHareketPozisyon.Text = '' then Count := Count + 1;
  //if (ButtonEditHareketMeslek.Text = '') and MeslekKayitVar then Count := Count + 1;

  SetLength(boslar,Count);

  for I := 0 to High(boslar) do
  begin
    if (DateEditHareketTarih.Text = '') and (AScan(boslar,'Tarih') = -1) then boslar[I] := 'Tarih';
    if SubeVarmi and (ComboHareketSube.Text = '') and (AScan(boslar,'Şube') = -1) then boslar[I] := 'Şube';
    if (ComboHareketTur.Text = '') and (AScan(boslar,'Tür') = -1) then boslar[I] := 'Tür';
    if (ComboHareketPozisyon.Text = '') and (AScan(boslar,'Pozisyon') = -1) then boslar[I] := 'Pozisyon';
  //  if (ButtonEditHareketMeslek.Text = '') and (AScan(boslar,'Meslek') = -1) and MeslekKayitVar then boslar[I] := 'Meslek';
  end;

  if High(boslar) > -1 then
  begin
    ShowMessage(string.Join(',',boslar)+' alanını doldurunuz.');
    Result := False;
  end
  else
  begin
    Result := True
  end;

end;

procedure TRehberPersonelHareket.ComboTurPropertiesEditValueChanged(
  Sender: TObject);
var
  ctrls:TGirdiDenetimleri;
  Deger:Variant;
  st:TStringList;
begin
  if (ComboHareketTur.EditValue = '99') then
  begin
    if (TabHareket.FieldByName('TUR').AsString <> '99') then
    begin
      Deger := ' ';
      ctrls := TGirdiDenetimleri.Create.ComboBox(('Nedeni'),@Deger,Tablo.ComboboxInit('SELECT ANAHTAR FROM dbo.GENINI WHERE BOLUM=-3503').Items);
      if TGirisKutusuEx.BilgiAlEx('İşten Ayrılma Nedeni',ctrls) = mrOk then
        TabHareket.FieldByName('ACIKLAMA').Value := VarToStr(Deger);
    end;
    if TabHareket.FieldByName('TUR').Value <> '99' then
    TabHareket.FieldByName('TUR').Value := '99';
  end;
end;

procedure TRehberPersonelHareket.cxButtonEdit1PropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  st:TStringList;
begin
  st := TStringList.Create;
  if Tablo.ListedenBilgiGetir('Meslek seçin','SELECT ID, KOD, AD FROM MESLEKKODLARI WHERE AD LIKE ''%<ara>%''',st,[]) then
  begin
    TabHareket.Edit;
    TabHareket.FieldByName('MESLEKID').Value := st[0];
    ButtonEditHareketMeslek.Text := Tablo.AciklamaGetir('MESLEKKODLARI', 'AD', st[0]);
  end;
end;

procedure TRehberPersonelHareket.DisaridanEkle(RehberID: Integer);
begin
  if TabHareket.Active then TabHareket.Close;
  TabHareket.SQL.Text := Memo1.Text;
  TabHareket.Open;
  TabHareket.Append;
  TabHareket.FieldByName('REHBERID').Value := RehberID;
  TabHareket.FieldByName('EKLEYEN').Value := Kullanan;
end;

procedure TRehberPersonelHareket.TabHareketNewRecord(DataSet: TDataSet);
begin
  YeniKayit := True;
  TabHareket.FieldByName('TARIH').Value := FormatDateTime('yyyy-MM-dd',Now);
  TabHareket.FieldByName('EKLEYEN').Value := Kullanan;
  TabHareket.FieldByName('EKLEMETARIHI').Value := Now;

  if RehberID > 0 then
  begin
    Tablo.TablodanSorguAc(4,'SELECT TOP 1 TUR,POZISYON,ACIKLAMA,SUBEID,MESLEKID FROM PERS_HAREKET WHERE REHBERID='+ IntToStr(RehberID) +' ORDER BY ID DESC');

    if not Tablo.Query4.IsEmpty then
    begin
      if not Tablo.Query4.Fields[2].IsNull then
      TabHareket.FieldByName('ACIKLAMA').Value := Tablo.Query4.Fields[2].AsString;
      if not Tablo.Query4.Fields[0].IsNull then
      TabHareket.FieldByName('TUR').Value := Tablo.Query4.Fields[0].AsString;
      if not Tablo.Query4.Fields[1].IsNull then
      TabHareket.FieldByName('POZISYON').Value := Tablo.Query4.Fields[1].AsString;
      if not Tablo.Query4.Fields[3].IsNull then
      TabHareket.FieldByName('SUBEID').Value := Tablo.Query4.Fields[3].AsString;
      if not Tablo.Query4.Fields[4].IsNull then
      begin
        TabHareket.FieldByName('MESLEKID').Value := Tablo.Query4.Fields[4].AsString;
        ButtonEditHareketMeslek.Text := Tablo.AciklamaGetir('MESLEKKODLARI','AD',Tablo.Query4.Fields[4].AsString);
      end;
    end;
  end;
end;

end.



