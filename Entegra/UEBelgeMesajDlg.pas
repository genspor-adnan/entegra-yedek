unit UEBelgeMesajDlg;

// Bir FATBASLIK kaydina ait tum islem gecmisi ve hata mesajlarini gosteren modal.
// Kaynaklar:
//   - EBELGEMESAJ  -> her islem icin yazilan log
//   - EBELGEKUYRUK -> bekleyen/hata kalmis gonderim isleri
// Tarihe gore sondan basa (yeniden eskiye) listelenir. cxGrid ile gosterilir.

interface

uses
  System.Classes, System.SysUtils, System.Variants, FireDAC.Comp.Client,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Clipbrd,
  Data.DB, Vcl.Graphics,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  cxClasses, cxGridLevel, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid;

type
  TEBelgeMesajDlg = class
  public
    class procedure Goster(AOwner: TComponent; AConnection: TFDConnection;
      AFatBaslikID: Integer; const AFaturaNo: string = '';
      const ABaslik: string = '');
  end;

implementation

type
  // "Kopyala" butonu icin yardimci: secili (veya odakli) satir(lar)i
  // baslik satiriyla birlikte sekme ayracli metin olarak panoya kopyalar.
  TMesajKopyalaYardimci = class
  public
    View: TcxGridDBTableView;
    procedure Click(Sender: TObject);
  end;

procedure TMesajKopyalaYardimci.Click(Sender: TObject);
var
  i, c: Integer;
  SB: TStringBuilder;

  procedure SatirEkle(ARec: TcxCustomGridRecord);
  var k: Integer;
  begin
    if ARec = nil then Exit;
    for k := 0 to View.ColumnCount - 1 do begin
      if k > 0 then SB.Append(#9);
      SB.Append(VarToStr(ARec.DisplayTexts[View.Columns[k].Index]));
    end;
    SB.AppendLine;
  end;

begin
  if (View = nil) or (View.ColumnCount = 0) then Exit;
  SB := TStringBuilder.Create;
  try
    // Baslik satiri
    for c := 0 to View.ColumnCount - 1 do begin
      if c > 0 then SB.Append(#9);
      SB.Append(View.Columns[c].Caption);
    end;
    SB.AppendLine;
    // Secili satirlar; secim yoksa odakli satir
    if View.Controller.SelectedRecordCount > 0 then begin
      for i := 0 to View.Controller.SelectedRecordCount - 1 do
        SatirEkle(View.Controller.SelectedRecords[i]);
    end else
      SatirEkle(View.Controller.FocusedRecord);
    Clipboard.AsText := SB.ToString;
  finally
    SB.Free;
  end;
end;

class procedure TEBelgeMesajDlg.Goster(AOwner: TComponent;
  AConnection: TFDConnection; AFatBaslikID: Integer;
  const AFaturaNo, ABaslik: string);
var
  LForm: TForm;
  LQ: TFDQuery;
  LDS: TDataSource;
  LGrid: TcxGrid;
  LView: TcxGridDBTableView;
  LLevel: TcxGridLevel;
  LBtn, LBtnKopya: TButton;
  LPnlBaslik, LPnlAlt: TPanel;
  LLblBaslik: TLabel;
  LSatBilgi: string;
  LKopyala: TMesajKopyalaYardimci;

  function AddCol(const AField, ACaption: string; AWidth: Integer): TcxGridDBColumn;
  begin
    Result := LView.CreateColumn;
    Result.DataBinding.FieldName := AField;
    Result.Caption := ACaption;
    Result.Width := AWidth;
  end;

begin
  LForm := TForm.Create(AOwner);
  try
    LForm.Caption := 'eBelge Mesaj/Islem Gecmisi';
    LForm.Width := 1100;
    LForm.Height := 600;
    LForm.Position := poScreenCenter;
    LForm.BorderStyle := bsSizeable;
    LForm.Font.Name := 'Trebuchet MS';
    LForm.Font.Size := 9;

    // Ust bilgi paneli
    LPnlBaslik := TPanel.Create(LForm);
    LPnlBaslik.Parent := LForm;
    LPnlBaslik.Align := alTop;
    LPnlBaslik.Height := 60;
    LPnlBaslik.BevelOuter := bvNone;
    LPnlBaslik.Color := clBtnFace;
    LPnlBaslik.ParentBackground := False;

    LLblBaslik := TLabel.Create(LForm);
    LLblBaslik.Parent := LPnlBaslik;
    LLblBaslik.AutoSize := False;
    LLblBaslik.Align := alClient;
    LLblBaslik.AlignWithMargins := True;
    LLblBaslik.Margins.Left := 12;
    LLblBaslik.Margins.Top := 8;
    LLblBaslik.Margins.Right := 12;
    LLblBaslik.Margins.Bottom := 8;
    LLblBaslik.Font.Style := [fsBold];
    LSatBilgi := 'FATBASLIK ID: ' + IntToStr(AFatBaslikID);
    if Trim(AFaturaNo) <> '' then
      LSatBilgi := LSatBilgi + '   |   Belge No: ' + AFaturaNo;
    if Trim(ABaslik) <> '' then
      LSatBilgi := LSatBilgi + '   |   ' + ABaslik;
    LSatBilgi := LSatBilgi + sLineBreak +
                 'Kronolojik islem gecmisi (yeniden eskiye) - satir secip Ctrl+C ' +
                 'veya Kopyala ile panoya alabilirsiniz';
    LLblBaslik.Caption := LSatBilgi;
    LLblBaslik.WordWrap := True;

    // Alt buton paneli
    LPnlAlt := TPanel.Create(LForm);
    LPnlAlt.Parent := LForm;
    LPnlAlt.Align := alBottom;
    LPnlAlt.Height := 42;
    LPnlAlt.BevelOuter := bvNone;
    LPnlAlt.ParentBackground := False;

    LBtn := TButton.Create(LForm);
    LBtn.Parent := LPnlAlt;
    LBtn.Caption := 'Kapat';
    LBtn.ModalResult := mrClose;
    LBtn.Width := 100;
    LBtn.Height := 28;
    LBtn.Top := 8;
    LBtn.Anchors := [akTop, akRight];
    LBtn.Left := LPnlAlt.ClientWidth - LBtn.Width - 12;

    // Veri sorgusu: EBELGEMESAJ + EBELGEKUYRUK birlestir
    LQ := TFDQuery.Create(LForm);
    LQ.Connection := AConnection;
    LQ.SQL.Text :=
      'SELECT KAYNAK, TARIH, TIPI, MESAJ, HTTPKODU, HATAKODU, SERVISKODU ' +
      'FROM (' +
      '  SELECT ' +
      '    KAYNAK = CAST(N''Mesaj'' AS NVARCHAR(20)), ' +
      '    TARIH  = M.EKLEMETARIHI, ' +
      '    TIPI   = CAST(CASE M.MESAJTIPI ' +
      '              WHEN 1 THEN N''Bilgi'' ' +
      '              WHEN 2 THEN N''Yanit'' ' +
      '              WHEN 3 THEN N''Uyari'' ' +
      '              WHEN 9 THEN N''Hata''  ' +
      '              ELSE CAST(M.MESAJTIPI AS NVARCHAR(10)) END AS NVARCHAR(20)), ' +
      '    MESAJ  = CAST(ISNULL(M.MESAJ, N'''') AS NVARCHAR(MAX)), ' +
      '    HTTPKODU = CAST(M.HTTPKODU AS NVARCHAR(10)), ' +
      '    HATAKODU = CAST(M.HATAKODU AS NVARCHAR(50)), ' +
      '    SERVISKODU = CAST(M.SERVISKODU AS NVARCHAR(50)) ' +
      '  FROM EBELGEMESAJ M ' +
      '    INNER JOIN EBELGE E ON E.ID = M.EBELGEID ' +
      '  WHERE E.FATBASLIKID = :FID1 ' +
      '  UNION ALL ' +
      '  SELECT ' +
      '    CAST(N''Kuyruk'' AS NVARCHAR(20)) AS KAYNAK, ' +
      '    COALESCE(K.SON_DENEME_TARIHI, K.EKLEMETARIHI) AS TARIH, ' +
      '    CAST(CASE K.DURUM ' +
      '      WHEN 0 THEN N''Bekliyor'' ' +
      '      WHEN 1 THEN N''Islemde''  ' +
      '      WHEN 9 THEN N''Hata''     ' +
      '      ELSE CAST(K.DURUM AS NVARCHAR(10)) END AS NVARCHAR(20)) AS TIPI, ' +
      '    CAST(COALESCE(K.SON_HATA, N''Kuyruga alindi.'') AS NVARCHAR(MAX)) AS MESAJ, ' +
      '    CAST(NULL AS NVARCHAR(10)) AS HTTPKODU, ' +
      '    CAST(NULL AS NVARCHAR(50)) AS HATAKODU, ' +
      '    CAST(NULL AS NVARCHAR(50)) AS SERVISKODU ' +
      '  FROM EBELGEKUYRUK K ' +
      '    INNER JOIN EBELGE E ON E.ID = K.EBELGEID ' +
      '  WHERE E.FATBASLIKID = :FID2 ' +
      ') T ' +
      'ORDER BY TARIH DESC, KAYNAK';
    LQ.ParamByName('FID1').AsInteger := AFatBaslikID;
    LQ.ParamByName('FID2').AsInteger := AFatBaslikID;

    LDS := TDataSource.Create(LForm);

    try
      LQ.Open;
      LDS.DataSet := LQ;
    except
      on E: Exception do
        LLblBaslik.Caption := LLblBaslik.Caption + sLineBreak +
                              'SORGU HATA: ' + E.Message;
    end;

    // cxGrid kur
    LGrid := TcxGrid.Create(LForm);
    LGrid.Parent := LForm;
    LGrid.Align := alClient;
    LGrid.LookAndFeel.Kind := lfFlat;

    LView := TcxGridDBTableView.Create(LGrid);
    LView.DataController.DataSource := LDS;
    LView.DataController.KeyFieldNames := '';
    LView.OptionsView.GroupByBox := False;
    LView.OptionsView.Indicator := True;
    LView.OptionsView.ColumnAutoWidth := False;
    LView.OptionsView.HeaderAutoHeight := True;
    LView.OptionsView.CellAutoHeight := True;       // MESAJ kolonu uzun ise satir buyur
    LView.OptionsCustomize.ColumnHorzSizing := True;
    LView.OptionsBehavior.CellHints := True;        // hucre uzunsa hint goster
    LView.OptionsBehavior.AlwaysShowEditor := False;
    LView.OptionsData.Editing := False;
    LView.OptionsData.Deleting := False;
    LView.OptionsSelection.MultiSelect := True;     // birden fazla satir secilebilsin
    LView.OptionsSelection.CellSelect := True;      // hucre secip Ctrl+C ile kopyalanabilsin

    // "Kopyala" butonu (Kapat'in soluna). Secili satir(lar)i panoya alir.
    LKopyala := TMesajKopyalaYardimci.Create;
    LKopyala.View := LView;
    LBtnKopya := TButton.Create(LForm);
    LBtnKopya.Parent := LPnlAlt;
    LBtnKopya.Caption := 'Kopyala';
    LBtnKopya.Width := 100;
    LBtnKopya.Height := 28;
    LBtnKopya.Top := 8;
    LBtnKopya.Anchors := [akTop, akRight];
    LBtnKopya.Left := LBtn.Left - LBtnKopya.Width - 8;
    LBtnKopya.OnClick := LKopyala.Click;

    if LQ.Active then begin
      AddCol('TARIH',      'Tarih',      130);
      AddCol('KAYNAK',     'Kaynak',      70);
      AddCol('TIPI',       'Tip',         80);
      AddCol('MESAJ',      'Mesaj',      560);
      AddCol('HTTPKODU',   'HTTP',        60);
      AddCol('HATAKODU',   'Hata Kodu',  120);
      AddCol('SERVISKODU', 'Servis',     100);
    end;

    LLevel := LGrid.Levels.Add;
    LLevel.GridView := LView;

    // Grid kapanis AV'sinden korunmak icin focus'u butona ver.
    LForm.ActiveControl := LBtn;
    try
      LForm.ShowModal;
    finally
      // Destruction sirasi: data baglantisini kes, level/grid'i bizzat manuel free et,
      // sonra TForm.Free kalan bilesenleri toparlasin. Bu sira cxGrid'in
      // DataController -> DataSource -> Query zincirinin yarim kalmasini onler.
      try if Assigned(LQ) and LQ.Active then LQ.Close; except end;
      try if Assigned(LView) then LView.DataController.DataSource := nil; except end;
      try if Assigned(LDS) then LDS.DataSet := nil; except end;
      try if Assigned(LLevel) then LLevel.GridView := nil; except end;
      try if Assigned(LView) then LView.Free; except end;
      LView := nil;
      LLevel := nil;
      try if Assigned(LGrid) then LGrid.Free; except end;
      LGrid := nil;
      try LKopyala.Free; except end;
      LKopyala := nil;
    end;
  finally
    LForm.Free;
  end;
end;

end.
