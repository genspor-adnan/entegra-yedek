unit UDosyaMigrasyon;

// Mevcut IMAJ belge/resim icerigini (klasor .OBJ / IMAJ.BELGE) DOSYA (FILESTREAM,
//  hash-dedup) deposuna tasir. Her satir: icerigi oku (ICDIS -> sp_Imaj_Okuma, bos ise
//  BELGE fallback) -> HamIcerikYaz (sikisik dokuman decompress / ham resim kopya) ->
//  ULog.DosyaKaydet (dedup) -> IMAJ.DOSYAID + BOYUT(KB). BELGE ve ICDIS'e DOKUNULMAZ
//  (yedek kalir; gorutuleme DOSYAID-once). Geri alma = DOSYAID=NULL (tam reversible).
// Harici .OBJ dosyalari DISKTE KALIR (geri donus guvenligi). Zaten tasinmis (DOSYAID>0)
//  satirlar atlanir -> islem resume-edilebilir/idempotent. Hata/kayip satirlari loglanir,
//  FSonID ile atlanir (sonsuz donguye girmez).

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, System.Generics.Collections,
  Data.DB, FireDAC.Comp.Client;

type
  TDosyaMigrasyonDlg = class(TForm)
    PanelUst: TPanel;
    PanelAlt: TPanel;
    ProgressBar1: TProgressBar;
    MemoLog: TMemo;
    lblToplam: TLabel;
    lblIstatistik: TLabel;
    lblDurum: TLabel;
    btnBaslat: TButton;
    btnDurdur: TButton;
    btnKapat: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnBaslatClick(Sender: TObject);
    procedure btnDurdurClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
  private
    FQBatch, FQMeta, FQRead: TFDQuery;
    FDurduruldu, FIsliyor: Boolean;
    FToplam, FIslenen, FBasarili, FAtlanan, FKayip, FHata: Integer;
    FSonID: Integer;
    FDokumanDizin: string;   // GENINI(-10006): harici .OBJ kok dizini (sp_Imaj_Okuma yolu)
    procedure Log(const AMsg: string);
    procedure IstatistikGuncelle;
    function SatirIsle(AID: Integer): Boolean;  // True=basarili
  public
  end;

var
  DosyaMigrasyonDlg: TDosyaMigrasyonDlg;

implementation

{$R *.dfm}

uses Utablo, ULog, UBinarySave, PrjConst, FetaKurulusSiniflari;

function MimeAl(const AUzanti: string): string;
begin
  if AUzanti = '.pdf' then Result := 'application/pdf'
  else if (AUzanti = '.jpg') or (AUzanti = '.jpeg') then Result := 'image/jpeg'
  else if AUzanti = '.png' then Result := 'image/png'
  else if AUzanti = '.gif' then Result := 'image/gif'
  else if AUzanti = '.bmp' then Result := 'image/bmp'
  else if AUzanti = '.tif' then Result := 'image/tiff'
  else if AUzanti = '.doc' then Result := 'application/msword'
  else if AUzanti = '.docx' then Result := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
  else if AUzanti = '.xls' then Result := 'application/vnd.ms-excel'
  else if AUzanti = '.xlsx' then Result := 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  else if AUzanti = '.xml' then Result := 'text/xml'
  else if AUzanti = '.txt' then Result := 'text/plain'
  else if AUzanti = '.zip' then Result := 'application/zip'
  else Result := 'application/octet-stream';
end;

procedure TDosyaMigrasyonDlg.FormCreate(Sender: TObject);
begin
  FQBatch := TFDQuery.Create(Self); FQBatch.Connection := Tablo.FDCnn;
  FQMeta  := TFDQuery.Create(Self); FQMeta.Connection  := Tablo.FDCnn;
  FQRead  := TFDQuery.Create(Self); FQRead.Connection  := Tablo.FDCnn;
  FDurduruldu := False; FIsliyor := False;
  FToplam := 0; FIslenen := 0; FBasarili := 0; FAtlanan := 0; FKayip := 0; FHata := 0;
  FSonID := 0;
  // Harici .OBJ kok dizini (sp_Imaj_Okuma ile ayni kaynak: GENINI BOLUM=-10006).
  //  Boylece sp cagirmadan ONCE dosya var mi diye bakip yok olani atlayabiliriz
  //  (OPENROWSET BULK yok dosyada exception firlatir -> hata dialogu).
  FDokumanDizin := '';
  try
    FQMeta.Close;
    FQMeta.SQL.Text := 'select ANAHTAR from GENINI where BOLUM=-10006 and DIL=0';
    FQMeta.Open;
    if not FQMeta.IsEmpty then FDokumanDizin := FQMeta.Fields[0].AsString;
    FQMeta.Close;
  except
  end;
  if (FDokumanDizin <> '') and (FDokumanDizin[Length(FDokumanDizin)] <> '\') then
    FDokumanDizin := FDokumanDizin + '\';
  IstatistikGuncelle;
  Log('Hazir. "Baslat" ile tasima baslar. Zaten tasinmis (DOSYAID dolu) satirlar atlanir.');
  if FDokumanDizin <> '' then
    Log('Harici dokuman dizini: ' + FDokumanDizin);
end;

procedure TDosyaMigrasyonDlg.FormDestroy(Sender: TObject);
begin
  FQBatch.Free; FQMeta.Free; FQRead.Free;
end;

procedure TDosyaMigrasyonDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FIsliyor then
  begin
    CanClose := False;
    if MessageDlg('Tasima suruyor. Durdurulup kapatilsin mi?', mtConfirmation,
                  [mbYes, mbNo], 0) = mrYes then
      FDurduruldu := True;
  end;
end;

procedure TDosyaMigrasyonDlg.Log(const AMsg: string);
begin
  if MemoLog.Lines.Count > 2000 then   // asiri buyumeyi engelle
    MemoLog.Lines.Delete(0);
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + '  ' + AMsg);
end;

procedure TDosyaMigrasyonDlg.IstatistikGuncelle;
begin
  lblToplam.Caption := Format('Tasinacak toplam: %d', [FToplam]);
  lblIstatistik.Caption := Format('Islenen: %d   Basarili: %d   Kayip: %d   Hata: %d',
    [FIslenen, FBasarili, FKayip, FHata]);
end;

function TDosyaMigrasyonDlg.SatirIsle(AID: Integer): Boolean;
var
  LIcDis: Boolean;
  LYeri: Integer;
  LBelgeAdi, LUzanti, LMime: string;
  LRead, LRaw: TMemoryStream;
  LBlob: TStream;
  LDosyaID: Int64;
  LBoyutKB: Integer;
  LEkleme: TDateTime;
  LObjPath, LObjAdi: string;
  LDosyaYok: Boolean;
begin
  Result := False;
  // 1) meta
  FQMeta.Close;
  FQMeta.SQL.Text := 'select ICDIS, YERI, BELGEADI, EKLEMETARIHI from IMAJ where ID=' + IntToStr(AID);
  FQMeta.Open;
  LIcDis    := FQMeta.FieldByName('ICDIS').AsBoolean;
  LYeri     := FQMeta.FieldByName('YERI').AsInteger;
  LBelgeAdi := FQMeta.FieldByName('BELGEADI').AsString;
  LEkleme   := FQMeta.FieldByName('EKLEMETARIHI').AsDateTime;
  FQMeta.Close;

  // Harici .OBJ yolunu sp_Imaj_Okuma mantigi ile hesapla:
  //  <dizin><yyyy>-<mm>\<6haneID>.OBJ  (ör. C:\Gentegre\DOKUMAN\2021-09\001018.OBJ)
  LObjAdi := Format('%.6d', [AID]) + '.OBJ';
  LObjPath := '';
  if (FDokumanDizin <> '') and (LEkleme > 0) then
    LObjPath := FDokumanDizin + FormatDateTime('yyyy-mm', LEkleme) + '\' + LObjAdi;

  LRead := TMemoryStream.Create;
  try
    // 2) icerigi oku: once harici .OBJ (ICDIS), bos ise IMAJ.BELGE fallback
    if LIcDis then
    begin
      // sp_Imaj_Okuma OPENROWSET BULK -> dosya yoksa exception firlatir. Bu yuzden ONCE
      //  Delphi tarafinda FileExists ile bak; yoksa sp'yi HIC cagirma (hata dialogu olmasin),
      //  BELGE fallback denenir, o da bossa KAYIP (dosya adi loglanir).
      LDosyaYok := (LObjPath <> '') and (not FileExists(LObjPath));
      if not LDosyaYok then
      begin
        FQRead.Close;
        FQRead.SQL.Text := 'DECLARE @S varbinary(MAX) exec sp_Imaj_Okuma ' + IntToStr(AID) +
                           ' ,@S OUTPUT select ICERIK=@S';
        try
          FQRead.Open;
          if (FQRead.Fields.Count > 0) and (not FQRead.Fields[0].IsNull) then
          begin
            LBlob := FQRead.CreateBlobStream(FQRead.Fields[0], bmRead);
            try LRead.CopyFrom(LBlob, LBlob.Size); finally LBlob.Free; end;
          end;
        except
          on E: Exception do
            Log(Format('  UYARI ID=%d harici okuma hatasi (%s): %s',
              [AID, LObjAdi, E.Message]));
        end;
        FQRead.Close;
      end;
    end;

    if LRead.Size = 0 then   // fallback: IMAJ.BELGE
    begin
      FQRead.Close;
      FQRead.SQL.Text := 'select BELGE from IMAJ where ID=' + IntToStr(AID);
      FQRead.Open;
      if not FQRead.Fields[0].IsNull then
      begin
        LBlob := FQRead.CreateBlobStream(FQRead.Fields[0], bmRead);
        try LRead.CopyFrom(LBlob, LBlob.Size); finally LBlob.Free; end;
      end;
      FQRead.Close;
    end;

    if LRead.Size = 0 then
    begin
      Inc(FKayip);
      if LObjPath <> '' then
        Log(Format('KAYIP ID=%d (%s) - dosya bulunamadi: %s', [AID, LBelgeAdi, LObjPath]))
      else
        Log(Format('KAYIP ID=%d (%s) - icerik okunamadi (dosya yok?)', [AID, LBelgeAdi]));
      Exit;
    end;

    // 3) HAM icerige cevir (sikisik dokuman decompress / ham resim kopya)
    LRaw := TMemoryStream.Create;
    try
      HamIcerikYaz(LRead, LRaw);
      if LRaw.Size = 0 then
      begin
        Inc(FKayip);
        Log(Format('KAYIP ID=%d (%s) - icerik bos', [AID, LBelgeAdi]));
        Exit;
      end;

      LUzanti := LowerCase(ExtractFileExt(LBelgeAdi));
      if LUzanti = '' then
        if LYeri = 1 then LUzanti := '' else LUzanti := '.jpg';
      LMime := MimeAl(LUzanti);

      // 4) DOSYA'ya yaz (hash-dedup) + IMAJ'i referansa cevir
      LRaw.Position := 0;
      LDosyaID := ULog.DosyaKaydet(LRaw, LUzanti, LMime);
      if LDosyaID <= 0 then
      begin
        Inc(FHata);
        Log(Format('HATA ID=%d (%s) - DosyaKaydet basarisiz', [AID, LBelgeAdi]));
        Exit;
      end;
      LBoyutKB := (LRaw.Size + 1023) div 1024;

      try
        // NOT: BELGE ve ICDIS'e DOKUNULMAZ (yedek kalir; gorutuleme zaten DOSYAID-once).
        //  -> Geri alma = sadece DOSYAID=NULL; satir AYNEN eski haline doner (tam reversible).
        //  BELGE tam migrasyon sonrasi BELGE_KOPYA'ya rename edilip kullanilmadigi dogrulanacak.
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
          'update IMAJ set DOSYAID=&D, BOYUT=&B where ID=&I',
          ['&D', '&B', '&I'], [LDosyaID, LBoyutKB, AID]);
      except
        on E: Exception do
        begin
          ULog.DosyaReferansAzalt(LDosyaID);  // IMAJ guncellenemedi -> ref geri al
          Inc(FHata);
          Log(Format('HATA ID=%d (%s) - IMAJ guncelleme: %s', [AID, LBelgeAdi, E.Message]));
          Exit;
        end;
      end;

      Inc(FBasarili);
      Result := True;
    finally
      LRaw.Free;
    end;
  finally
    LRead.Free;
  end;
end;

procedure TDosyaMigrasyonDlg.btnBaslatClick(Sender: TObject);
var
  LID: Integer;
begin
  if FIsliyor then Exit;
  FDurduruldu := False;
  FIsliyor := True;
  // her calistirmada bastan tam gecis (tasinmis satirlar DOSYAID ile zaten haric)
  FSonID := 0; FIslenen := 0; FBasarili := 0; FAtlanan := 0; FKayip := 0; FHata := 0;
  btnBaslat.Enabled := False;
  btnDurdur.Enabled := True;
  btnKapat.Enabled := False;
  try
    // toplam (henuz tasinmamis)
    FQBatch.Close;
    FQBatch.SQL.Text := 'select count(*) from IMAJ where DOSYAID is null or DOSYAID=0';
    FQBatch.Open;
    FToplam := FQBatch.Fields[0].AsInteger;
    FQBatch.Close;
    IstatistikGuncelle;
    ProgressBar1.Position := 0;
    ProgressBar1.Max := FToplam;
    Log(Format('Baslatildi. Toplam %d satir taşınacak...', [FToplam]));

    repeat
      // sonraki grup (FSonID: basarisiz satirda takilmadan ilerle)
      FQBatch.Close;
      FQBatch.SQL.Text :=
        'select top 25 ID from IMAJ where (DOSYAID is null or DOSYAID=0) and ID>' +
        IntToStr(FSonID) + ' order by ID';
      FQBatch.Open;
      if FQBatch.IsEmpty then
      begin
        FQBatch.Close;
        Break;
      end;
      // grubu listeye al (ayni baglantida ikinci sorgu acmamak icin)
      var LIDler := TList<Integer>.Create;
      try
        while not FQBatch.Eof do
        begin
          LIDler.Add(FQBatch.FieldByName('ID').AsInteger);
          FQBatch.Next;
        end;
        FQBatch.Close;

        for LID in LIDler do
        begin
          try
            SatirIsle(LID);
          except
            on E: Exception do
            begin
              Inc(FHata);
              Log(Format('HATA ID=%d - %s', [LID, E.Message]));
            end;
          end;
          FSonID := LID;
          Inc(FIslenen);
          if ProgressBar1.Position < ProgressBar1.Max then
            ProgressBar1.Position := ProgressBar1.Position + 1;
          if (FIslenen mod 5) = 0 then
          begin
            IstatistikGuncelle;
            lblDurum.Caption := Format('Son islenen ID: %d', [FSonID]);
            Application.ProcessMessages;   // UI responsive + Durdur aninda etkili
          end;
          if FDurduruldu then Break;
        end;
      finally
        LIDler.Free;
      end;

      IstatistikGuncelle;
      lblDurum.Caption := Format('Son islenen ID: %d', [FSonID]);
      Application.ProcessMessages;
    until FDurduruldu;

    if FDurduruldu then
      Log(Format('DURDURULDU. Islenen: %d, Basarili: %d, Kayip: %d, Hata: %d',
        [FIslenen, FBasarili, FKayip, FHata]))
    else
      Log(Format('BITTI. Islenen: %d, Basarili: %d, Kayip: %d, Hata: %d',
        [FIslenen, FBasarili, FKayip, FHata]));
    IstatistikGuncelle;
  finally
    FIsliyor := False;
    btnBaslat.Enabled := True;
    btnDurdur.Enabled := False;
    btnKapat.Enabled := True;
  end;
end;

procedure TDosyaMigrasyonDlg.btnDurdurClick(Sender: TObject);
begin
  FDurduruldu := True;
  Log('Durduruluyor... (mevcut grup bitince durur)');
end;

procedure TDosyaMigrasyonDlg.btnKapatClick(Sender: TObject);
begin
  Close;
end;

end.
