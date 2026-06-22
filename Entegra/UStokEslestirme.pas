unit UStokEslestirme;

// Cari bazli stok/hizmet eslestirme tablosu CRUD ekrani.
// Gelen e-fatura UBL'sindeki urun/hizmet bilgilerini bizim STOKLAR veya
// MASRAFGELIR tablomuza eslestirir. Sonraki gelen fatura cekiminde
// _UBLDetaylariEkle bu tablodan lookup yapip URUNID'i otomatik atar.
//
// Acilis: MenuEslesmeTablosunuAcClick -> TStokEslestirmeDlg.Goster(...)

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxClasses, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, cxDBData, cxContainer, cxLabel, cxTextEdit, cxMaskEdit,
  cxButtonEdit, cxImageComboBox, cxCheckBox, cxButtons,
  cxGridLevel, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxPC,
  dxSkinsCore, dxSkinscxPCPainter, dxSkinLondonLiquidSky,
  dxScrollbarAnnotations, dxCoreGraphics, dxDateRanges, Vcl.Menus,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TStokEslestirmeDlg = class(TForm)
    PanelUst: TPanel;
    lblCari: TcxLabel;
    beCari: TcxButtonEdit;
    lblBilgi: TcxLabel;
    PanelAlt: TPanel;
    btnYeni: TcxButton;
    btnSil: TcxButton;
    btnKaydet: TcxButton;
    btnKapat: TcxButton;
    Grid: TcxGrid;
    GridView: TcxGridDBTableView;
    GridLevel: TcxGridLevel;
    Q: TFDQuery;
    DS: TDataSource;
    GridViewID: TcxGridDBColumn;
    GridViewGELEN_KOD: TcxGridDBColumn;
    GridViewGELEN_AD: TcxGridDBColumn;
    GridViewESLESME_TURU: TcxGridDBColumn;
    GridViewTIP: TcxGridDBColumn;
    GridViewURUNID: TcxGridDBColumn;
    GridViewKARSILIK_KOD: TcxGridDBColumn;
    GridViewKARSILIK_AD: TcxGridDBColumn;
    GridViewAKTIF: TcxGridDBColumn;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure beCariPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnYeniClick(Sender: TObject);
    procedure btnSilClick(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure GridViewKARSILIK_KODPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure GridViewCellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo;
      AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure QCalcFields(DataSet: TDataSet);
  private
    FConnection: TFDConnection;
    FRehberID: Integer;
    procedure CariYukle;
    procedure ListeYenile;
    procedure UrunBilgisiAl(ATip, AUrunID: Integer;
      out AKod, AAd: string);
  public
    class procedure Goster(AOwner: TComponent; AConnection: TFDConnection;
      ARehberID: Integer; const ACariAdi: string);
    /// Verilen FATBASLIK'in mevcut FATURA satirlarini, STOK_ESLESTIRME'deki
    /// ESLESME_TURU=2 (KDV Gruplu) kaydina gore KDV oranlarina ayirip tek
    /// satirla yeniden olusturur. Eslesme yoksa false doner.
    /// AInteraktif=True: onay dialogu + sonuc/hata ShowMessage
    /// AInteraktif=False: dialogsuz; AMesaj/AKayitSayisi ile bilgi alinir
    class function FaturayiEslestir(AConn: TFDConnection;
      AFatBaslikID, ARehberID, AKullanan: Integer;
      out AMesaj: string; out AKayitSayisi: Integer;
      AInteraktif: Boolean = True): Boolean; overload;
    /// Kisa form: AInteraktif=True ile cagrir, sonuc/hata mesajlarini gosterir.
    class function FaturayiEslestir(AConn: TFDConnection;
      AFatBaslikID, ARehberID, AKullanan: Integer): Boolean; overload;
    /// FATBASLIK'in her FATURA satirini STOK_ESLESTIRME'deki kayitlara karsi
    /// eslestirir; URUNID + TUR'u UPDATE eder. Oncelik:
    ///   1) ESLESME_TURU=1 (Urun No)  : IZLEMEKODU = GELEN_KOD
    ///   2) ESLESME_TURU=4 (Ad Tam)   : ACIKLAMA = GELEN_AD
    ///   3) ESLESME_TURU=3 (Ad LIKE)  : ACIKLAMA LIKE '%' + GELEN_AD + '%'
    ///   4) ESLESME_TURU=0 (Kod)      : IZLEMEKODU = GELEN_KOD (legacy)
    /// Birden fazla eslesmede EKLEMETARIHI DESC; AKTIF=1 zorunlu.
    class function SatirlariEslestir(AConn: TFDConnection;
      AFatBaslikID, ARehberID, AKullanan: Integer;
      out AGuncellenenSayi: Integer): Boolean;
  end;

implementation

{$R *.dfm}

uses
  Utablo, UStokHizmetAra, FetaKurulusSiniflari;

class procedure TStokEslestirmeDlg.Goster(AOwner: TComponent;
  AConnection: TFDConnection; ARehberID: Integer; const ACariAdi: string);
var
  Dlg: TStokEslestirmeDlg;
begin
  Dlg := TStokEslestirmeDlg.Create(AOwner);
  try
    Dlg.FConnection := AConnection;
    Dlg.FRehberID := ARehberID;
    if ACariAdi <> '' then
      Dlg.beCari.Text := IntToStr(ARehberID) + ' - ' + ACariAdi
    else
      Dlg.CariYukle;
    Dlg.ListeYenile;
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TStokEslestirmeDlg.FormCreate(Sender: TObject);
begin
  Caption := 'Stok / Hizmet Eslestirme';
end;

procedure TStokEslestirmeDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Q.Active then begin
    if Q.State in [dsEdit, dsInsert] then Q.Cancel;
    Q.Close;
  end;
end;

procedure TStokEslestirmeDlg.CariYukle;
begin
  if FRehberID <= 0 then begin
    beCari.Text := '';
    Exit;
  end;
  Tablo.TablodanSorguAc(1,
    'SELECT KOD, FIRMA FROM REHBER WHERE ID=' + IntToStr(FRehberID));
  if not Tablo.Query1.Eof then
    beCari.Text := Tablo.Query1.Fields[0].AsString + ' - ' +
                   Tablo.Query1.Fields[1].AsString;
  Tablo.Query1.Close;
end;

procedure TStokEslestirmeDlg.beCariPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  LRehberID: Integer;
begin
  LRehberID := Tablo.RehberAra_IDGetir(-1);
  if LRehberID > 0 then begin
    FRehberID := LRehberID;
    CariYukle;
    ListeYenile;
  end;
end;

procedure TStokEslestirmeDlg.ListeYenile;
var
  i: Integer;
  F: TStringField;
begin
  if Q.Active then Q.Close;
  Q.Connection := FConnection;
  Q.SQL.Text :=
    'SELECT E.ID, E.REHBERID, E.GELEN_KOD, E.GELEN_AD, E.ESLESME_TURU, ' +
    '       E.TIP, E.URUNID, E.AKTIF ' +
    'FROM STOK_ESLESTIRME E WHERE E.REHBERID = :R ORDER BY E.ID';
  // Ilk acilisli ayarlar: persistent DB field'lari + calc field'lar.
  // Calc field'lar tek basina dataset'e eklendiginde DB field'lar
  // auto-discover edilmiyor; once tum DB field'larini persistent yapip
  // sonra calc field'lari ekliyoruz.
  if Q.FieldCount = 0 then begin
    Q.FieldDefs.Update;
    for i := 0 to Q.FieldDefs.Count - 1 do
      if Q.FindField(Q.FieldDefs[i].Name) = nil then
        Q.FieldDefs[i].CreateField(Q);
    if Q.FindField('KARSILIK_KOD') = nil then begin
      F := TStringField.Create(Q);
      F.FieldName := 'KARSILIK_KOD';
      F.Calculated := True;
      F.Size := 50;
      F.DataSet := Q;
    end;
    if Q.FindField('KARSILIK_AD') = nil then begin
      F := TStringField.Create(Q);
      F.FieldName := 'KARSILIK_AD';
      F.Calculated := True;
      F.Size := 250;
      F.DataSet := Q;
    end;
  end;
  Q.ParamByName('R').AsInteger := FRehberID;
  if FRehberID > 0 then Q.Open;
end;

procedure TStokEslestirmeDlg.UrunBilgisiAl(ATip, AUrunID: Integer;
  out AKod, AAd: string);
begin
  AKod := ''; AAd := '';
  if AUrunID <= 0 then Exit;
  if ATip = 1 then
    Tablo.TablodanSorguAc(1,
      'SELECT KOD, STOKADI FROM STOKLAR WHERE ID=' + IntToStr(AUrunID))
  else
    Tablo.TablodanSorguAc(1,
      'SELECT KOD, AD FROM MASRAFGELIR WHERE ID=' + IntToStr(AUrunID));
  if not Tablo.Query1.Eof then begin
    AKod := Tablo.Query1.Fields[0].AsString;
    AAd := Tablo.Query1.Fields[1].AsString;
  end;
  Tablo.Query1.Close;
end;

procedure TStokEslestirmeDlg.QCalcFields(DataSet: TDataSet);
var
  LKod, LAd: string;
begin
  UrunBilgisiAl(DataSet.FieldByName('TIP').AsInteger,
                DataSet.FieldByName('URUNID').AsInteger, LKod, LAd);
  if DataSet.FindField('KARSILIK_KOD') <> nil then
    DataSet.FieldByName('KARSILIK_KOD').AsString := LKod;
  if DataSet.FindField('KARSILIK_AD') <> nil then
    DataSet.FieldByName('KARSILIK_AD').AsString := LAd;
end;

procedure TStokEslestirmeDlg.btnYeniClick(Sender: TObject);
begin
  if FRehberID <= 0 then begin
    ShowMessage('Once cari secin.');
    Exit;
  end;
  if not Q.Active then ListeYenile;
  Q.Append;
  Q.FieldByName('REHBERID').AsInteger := FRehberID;
  Q.FieldByName('ESLESME_TURU').AsInteger := 0; // Kod
  Q.FieldByName('TIP').AsInteger := 1;          // Stok
  Q.FieldByName('URUNID').AsInteger := 0;
  Q.FieldByName('AKTIF').AsBoolean := True;
end;

procedure TStokEslestirmeDlg.btnSilClick(Sender: TObject);
begin
  if (not Q.Active) or Q.IsEmpty then Exit;
  if Application.MessageBox(
      'Bu eslestirme silinsin mi?', 'Onay',
      MB_YESNO + MB_ICONQUESTION) = ID_YES then
    Q.Delete;
end;

procedure TStokEslestirmeDlg.btnKaydetClick(Sender: TObject);
begin
  if Q.State in [dsEdit, dsInsert] then Q.Post;
  Q.ApplyUpdates;
  Q.CommitUpdates;
  ShowMessage('Kaydedildi.');
end;

procedure TStokEslestirmeDlg.btnKapatClick(Sender: TObject);
begin
  if Q.State in [dsEdit, dsInsert] then begin
    if Application.MessageBox(
        'Kaydedilmemis degisiklikler var. Kaydet?', 'Onay',
        MB_YESNOCANCEL + MB_ICONQUESTION) = ID_YES then
    begin
      Q.Post; Q.ApplyUpdates; Q.CommitUpdates;
    end else
      Q.Cancel;
  end;
  Close;
end;

procedure TStokEslestirmeDlg.GridViewCellClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
// KARSILIK_KOD hucresine tek tikla -> dogrudan secim dialogunu ac.
// (cxGrid button-edit sadece edit modunda gozuktugu icin click handler kullanildi)
begin
  if AButton <> mbLeft then Exit;
  if ACellViewInfo = nil then Exit;
  if ACellViewInfo.Item = GridViewKARSILIK_KOD then begin
    GridViewKARSILIK_KODPropertiesButtonClick(nil, 0);
    AHandled := True;
  end;
end;

procedure TStokEslestirmeDlg.GridViewKARSILIK_KODPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
// Aktif satirin TIP'ine gore secim ekrani:
//   TIP=0 (Hizmet) -> MasrafMerkeziSecimEkrani (MASRAFGELIR)
//   TIP=1 (Stok)   -> UStokHizmetAra (STOKLAR sekmesi)
var
  LTip: Integer;
  // Hizmet
  LMasrafID, LMasrafKodu, LMasrafAd: string;
  // Stok
  AraDlg: TStokHizmetAraDlg;
begin
  if (not Q.Active) or Q.IsEmpty then begin
    btnYeniClick(nil);
    if Q.IsEmpty then Exit;
  end;
  if not (Q.State in [dsEdit, dsInsert]) then
    Q.Edit;

  LTip := Q.FieldByName('TIP').AsInteger;

  if LTip = 0 then begin
    // HIZMET / MASRAF secimi
    LMasrafID := ''; LMasrafKodu := ''; LMasrafAd := '';
    if Tablo.MasrafMerkeziSecimEkrani(0, LMasrafID, LMasrafKodu, LMasrafAd) then begin
      Q.FieldByName('URUNID').AsInteger := StrToIntDef(LMasrafID, 0);
      if Q.State in [dsEdit, dsInsert] then Q.Post;
    end;
    Exit;
  end;

  // STOK secimi (UStokHizmetAra) - stokhizmetaracagirantur=18 (TabNo_DEMIRBAS)
  // ile BtnSecClick hicbir INSERT/Update yapmadan dogrudan ModalResult=mrOk
  // donduruyor. Secimi AraDlg.TabStokListe'den okuyoruz.
  Application.CreateForm(TStokHizmetAraDlg, AraDlg);
  try
    AraDlg.FatBasID  := 0;
    AraDlg.RehberId := FRehberID;
    AraDlg.TabDetayGiris := nil;
    AraDlg.TabGiris := nil;
    AraDlg.KalanAdetGetir := False;
    AraDlg.stokhizmetaracagirantur := 18; // TabNo_DEMIRBAS = sade secim modu
    if AraDlg.ShowModal = mrOk then begin
      if (AraDlg.TabStokListe <> nil) and AraDlg.TabStokListe.Active and
         (not AraDlg.TabStokListe.IsEmpty) then begin
        Q.FieldByName('TIP').AsInteger := 1;
        Q.FieldByName('URUNID').AsInteger :=
          AraDlg.TabStokListe.FieldByName('ID').AsInteger;
        if Q.State in [dsEdit, dsInsert] then Q.Post;
      end;
    end;
  finally
    FreeAndNil(AraDlg);
  end;
end;

class function TStokEslestirmeDlg.FaturayiEslestir(AConn: TFDConnection;
  AFatBaslikID, ARehberID, AKullanan: Integer; out AMesaj: string;
  out AKayitSayisi: Integer; AInteraktif: Boolean): Boolean;
var
  LQ: TFDQuery;
  LTip, LUrunID, LKdv: Integer;
  LFmt: TFormatSettings;
  LToplamStr: string;
begin
  Result := False;
  AMesaj := '';
  AKayitSayisi := 0;

  if AConn = nil then begin
    AMesaj := 'Baglanti bos.';
    Exit;
  end;
  if (AFatBaslikID <= 0) or (ARehberID <= 0) then begin
    AMesaj := 'FATBASLIK veya REHBERID bos.';
    Exit;
  end;

  // KDV Gruplu eslesme var mi?
  Tablo.TablodanSorguAc(1,
    'SELECT TOP 1 TIP, URUNID FROM STOK_ESLESTIRME ' +
    'WHERE REHBERID=' + IntToStr(ARehberID) +
    ' AND ESLESME_TURU=2 AND AKTIF=1 ORDER BY ID DESC');
  if Tablo.Query1.Eof then begin
    Tablo.Query1.Close;
    AMesaj := 'Bu cari icin KDV Gruplu eslesme tanimi yok.';
    Exit;
  end;
  LTip := Tablo.Query1.FieldByName('TIP').AsInteger;
  LUrunID := Tablo.Query1.FieldByName('URUNID').AsInteger;
  Tablo.Query1.Close;

  if AInteraktif then begin
    if Application.MessageBox(
         'Mevcut fatura satirlari silinip KDV oranina gore tek satirla yeniden olusturulacak.' + sLineBreak +
         'Devam edilsin mi?',
         'KDV Gruplu Eslestirme', MB_YESNO + MB_ICONQUESTION) <> ID_YES then begin
      AMesaj := 'Iptal edildi.';
      Exit;
    end;
  end;

  LFmt := TFormatSettings.Create;
  LFmt.DecimalSeparator := '.';
  LFmt.ThousandSeparator := #0;

  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConn;
    LQ.SQL.Text :=
      'SELECT ISNULL(KDV,0) AS KDV, SUM(ISNULL(TUTAR,0)) AS TOPLAM ' +
      'FROM FATURA WHERE FATBASID=' + IntToStr(AFatBaslikID) +
      ' GROUP BY ISNULL(KDV,0) ORDER BY KDV';
    LQ.Open;
    if LQ.Eof then begin
      LQ.Close;
      AMesaj := 'Faturada satir yok.';
      Exit;
    end;

    AConn.StartTransaction;
    try
       Veritabani.BasitKomutÇalıştır(AConn,
        'DELETE FROM FATURA WHERE FATBASID=&FID',
        ['&FID'], [AFatBaslikID]);

      LQ.First;
      while not LQ.Eof do begin
        LToplamStr := CurrToStr(LQ.FieldByName('TOPLAM').AsCurrency, LFmt);
        LKdv := LQ.FieldByName('KDV').AsInteger;
        Veritabani.BasitKomutÇalıştır(AConn,
          'INSERT INTO FATURA (FATBASID, REHBERID, TUR, URUNID, ACIKLAMA, ' +
          ' ADET, MIKTAR, BIRIMFIYAT, TUTAR, KDV, KUR, DOVIZ_KURU, ' +
          ' DOVIZ_TUTARI, DOVIZ_BIRIMFIYAT, DOVIZKURDEGERI, EKLEYEN, ' +
          ' EKLEMETARIHI, SUBEID, GIRDEPO, CIKDEPO, STOKDURUMDEGIS, IZLEME) ' +
          'VALUES (&FID, &RID, &TUR, &URUNID, &ACK, ' +
          ' 1, 1, ' + LToplamStr + ', ' + LToplamStr + ', ' + IntToStr(LKdv) +
          ', ''TL'', ''TL'', ' +
          ' ' + LToplamStr + ', ' + LToplamStr + ', 1, &KUL, GETDATE(), ' +
          ' -1, 1, 0, 1, 0)',
          ['&FID', '&RID', '&TUR', '&URUNID', '&ACK', '&KUL'],
          [AFatBaslikID, ARehberID, LTip, LUrunID,
           'KDV %' + IntToStr(LKdv) + ' grubu',
           AKullanan]);
        Inc(AKayitSayisi);
        LQ.Next;
      end;
      LQ.Close;

      AConn.Commit;
      Result := True;
      AMesaj := 'Eslestirme tamamlandi. Olusturulan satir: ' + IntToStr(AKayitSayisi);
    except
      on E: Exception do begin
        if AConn.InTransaction then AConn.Rollback;
        AMesaj := 'Hata: ' + E.Message;
      end;
    end;
  finally
    LQ.Free;
  end;
end;

class function TStokEslestirmeDlg.FaturayiEslestir(AConn: TFDConnection;
  AFatBaslikID, ARehberID, AKullanan: Integer): Boolean;
// Kisa form: interaktif (onay dialogu + ShowMessage)
var
  LMesaj: string;
  LKayit: Integer;
begin
  Result := FaturayiEslestir(AConn, AFatBaslikID, ARehberID, AKullanan,
                             LMesaj, LKayit, True);
  if LMesaj <> '' then ShowMessage(LMesaj);
end;

class function TStokEslestirmeDlg.SatirlariEslestir(AConn: TFDConnection;
  AFatBaslikID, ARehberID, AKullanan: Integer;
  out AGuncellenenSayi: Integer): Boolean;
// Tek UPDATE + CROSS APPLY ile satir basina TOP 1 eslesme:
// Oncelik: ESLESME_TURU 1 (UrunNo) > 4 (Ad Tam) > 3 (Ad LIKE) > 0 (Kod legacy)
// Coklu eslesmede EKLEMETARIHI DESC. Sadece URUNID=0/NULL satirlar guncellenir.
var
  LQ: TFDQuery;
begin
  Result := False;
  AGuncellenenSayi := 0;
  if (AConn = nil) or (AFatBaslikID <= 0) or (ARehberID <= 0) then Exit;

  LQ := TFDQuery.Create(nil);
  try
    LQ.Connection := AConn;
    LQ.SQL.Text :=
      'UPDATE F SET F.TUR = M.TIP, F.URUNID = M.URUNID ' +
      'FROM FATURA F ' +
      'CROSS APPLY ( ' +
      '  SELECT TOP 1 E.TIP, E.URUNID ' +
      '  FROM STOK_ESLESTIRME E ' +
      '  WHERE E.REHBERID = :REHBERID AND E.AKTIF = 1 ' +
      '    AND ( ' +
      '      (E.ESLESME_TURU IN (0,1) AND ISNULL(F.IZLEMEKODU, N'''') <> N'''' ' +
      '        AND E.GELEN_KOD = F.IZLEMEKODU) ' +
      '      OR (E.ESLESME_TURU = 4 AND E.GELEN_AD = F.ACIKLAMA) ' +
      '      OR (E.ESLESME_TURU = 3 AND ISNULL(E.GELEN_AD, N'''') <> N'''' ' +
      '        AND F.ACIKLAMA LIKE N''%'' + E.GELEN_AD + N''%'') ' +
      '    ) ' +
      '  ORDER BY ' +
      '    CASE E.ESLESME_TURU ' +
      '      WHEN 1 THEN 1 WHEN 4 THEN 2 WHEN 3 THEN 3 WHEN 0 THEN 4 ' +
      '      ELSE 99 END, ' +
      '    E.EKLEMETARIHI DESC ' +
      ') M ' +
      'WHERE F.FATBASID = :FATBASID ' +
      '  AND (ISNULL(F.URUNID, 0) = 0)';
    LQ.ParamByName('REHBERID').AsInteger := ARehberID;
    LQ.ParamByName('FATBASID').AsInteger := AFatBaslikID;
    LQ.ExecSQL;
    AGuncellenenSayi := LQ.RowsAffected;
    Result := True;
  finally
    LQ.Free;
  end;
end;

end.
