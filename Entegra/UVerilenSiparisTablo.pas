unit UVerilenSiparisTablo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,UTablo,
  Dialogs, ComCtrls, ToolWin, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData, cxButtonEdit, cxTextEdit, cxImageComboBox, cxCurrencyEdit, cxSpinEdit, cxCalendar, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, Menus, cxLookAndFeelPainters, StdCtrls, cxButtons, Grids, ExtCtrls, cxLookAndFeels, cxNavigator,
  dxSkinLiquidSky;

type
  TVerilenSiparisTabloDlg = class(TForm)
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    TabDetay: TFDQuery;
    DtsTabDetay: TDataSource;
    TabDetayKOD: TWideStringField;
    TabDetayAD: TWideStringField;
    TabDetayACIKLAMA: TWideStringField;
    TabDetayADET: TFloatField;
    TabDetayBIRIM: TWideStringField;
    TabDetayTESLIMTARIHI: TDateTimeField;
    TabDetayDEPODA: TFloatField;
    TabDetayYOLDAGELEN: TFloatField;
    TabDetayYOLDAGIDECEK: TFloatField;
    TabDetayFARK: TFloatField;
    TabDetayYENISIPARISADET: TIntegerField;
    TabDetayFIRMA: TStringField;
    TabDetayID: TAutoIncField;
    TabDetayTEKLIFID: TIntegerField;
    TabDetaySIPBIRIMFIYAT: TBCDField;
    GridSiparis: TcxGrid;
    GridSiparisView: TcxGridDBTableView;
    GridSiparisViewAD: TcxGridDBColumn;
    GridSiparisViewBIRIM: TcxGridDBColumn;
    GridSiparisViewTESLIMTARIHI: TcxGridDBColumn;
    GridSiparisLevel1: TcxGridLevel;
    GridSiparisViewKOD: TcxGridDBColumn;
    GridSiparisViewACIKLAMA: TcxGridDBColumn;
    GridSiparisViewADET: TcxGridDBColumn;
    GridSiparisViewDEPODA: TcxGridDBColumn;
    GridSiparisViewYOLDAGELEN: TcxGridDBColumn;
    GridSiparisViewYOLDAGIDECEK: TcxGridDBColumn;
    GridSiparisViewFARK: TcxGridDBColumn;
    GridSiparisViewYENISIPARISADET: TcxGridDBColumn;
    GridSiparisViewFIRMA: TcxGridDBColumn;
    GridSiparisViewSIPBIRIMFIYAT: TcxGridDBColumn;
    GridSiparisTableView1: TcxGridTableView;
    GridTESLIMTARIHI: TcxGridColumn;
    GridKOD: TcxGridColumn;
    GridAD: TcxGridColumn;
    GridACIKLAMA: TcxGridColumn;
    GridADET: TcxGridColumn;
    GridBIRIM: TcxGridColumn;
    GridDEPODA: TcxGridColumn;
    GridYOLDAGELEN: TcxGridColumn;
    GridYOLDAGIDECEK: TcxGridColumn;
    GridFARK: TcxGridColumn;
    GridYENISIPARISADET: TcxGridColumn;
    GridFIRMA: TcxGridColumn;
    GridSIPBIRIMFIYAT: TcxGridColumn;
    GridID: TcxGridColumn;
    GridTEKLIFID: TcxGridColumn;
    GridSTOKID: TcxGridColumn;
    GridKDV: TcxGridColumn;
    GridRehberID: TcxGridColumn;
    TabDetayURUNID: TIntegerField;
    TabDetayKDV: TSmallintField;
    btnTamam: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure btnTamamClick(Sender: TObject);
    procedure GridFIRMAPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GridSiparisTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    TeklifId:integer;
  end;

var
  VerilenSiparisTabloDlg: TVerilenSiparisTabloDlg;


implementation
uses
PrjConst,FetaKurulusSiniflari,UAnaForm,FetaClassExtensions;

{$R *.dfm}



procedure TVerilenSiparisTabloDlg.btnTamamClick(Sender: TObject);
var
  Gezici: Integer;
  TeklifID,Tur,RehID,FirmaRehID,VarsDepoID,DonusTipi:integer;
  belgeno: TBelgeNo;
  DepoField,Deger:string;
  IDDeger,RehIDDeger:array of Integer;
  TeklifNoDeger : Array of String;
  i, j: integer;
  listedevar: Boolean;
begin
  Tur:=9;
  FirmaRehID:=-1; //Kendi Firma bilgilerimiz
  VarsDepoID:=StrToInt(GenRegIni.RegReadString('StokOpsiyon','StokVarsayilanDepo','1','C'));
  DepoField:='[GIRISDEPO]';
  DonusTipi:=TabNo_DONUSUM_TEKLIF_ALIS_SIPARIS;
    //Firma Başlık bilgileri
  Tablo.TablodanSorguAc(3,'Select REHBERILETID,FIYAT_LISTESI,TEKLIFNO from TEKLIF Where ID='+TabDetay.FieldByName('TEKLIFID').AsString+' ');
  TabloYenile(Tablo.tabCariBilgileri, [FirmaRehID,Tablo.Query3.FieldByName('REHBERILETID').AsInteger]);
  if GridSiparisTableView1.DataController.RecordCount > 0 then begin
    for Gezici := 0 to GridSiparisTableView1.DataController.RecordCount - 1 do begin
      with GridSiparisTableView1.DataController do begin
         if (GetValue(Gezici,GridYENISIPARISADET.Index) > 0) and (GetValue(Gezici,GridFIRMA.Index) <> '') then  begin
           belgeno:= SiradakiBelgeNumarasi(Tur,Tablo.GENINI.BugunTrhSaat);
           RehID:= GetValue(Gezici,GridRehberID.Index);
           Tablo.TablodanSorguAc(6,'Select top 1 * from SIPARISDETAY SD LEFT OUTER JOIN SIPARIS S on S.ID=SD.SIPARISID Where S.TUR='+inttoStr(Tur)+' and SD.EKLEMETARIHI='''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''' and SD.REHBERID='+IntToStr(RehID)+' order by SD.ID desc');

           if Tablo.Query6.RecordCount > 0 then  begin
             // birbirine eşit ise aynı teklif noyu kullanacak.

              //SiparişDetay tablosuna kayıt
               Tablo.Query2.Close;
              Tablo.Query2.SQL.Text:='INSERT INTO [SIPARISDETAY]([SIPARISID],[REHBERID],[TUR],[URUNID],[ADET],[BIRIM],[MIKTAR]'+
              ' ,[BIRIMFIYAT],[TUTAR],[ISKONTO],[KDV],[MASRAFID],[KUR],[DOVIZ_TUTARI],[DOVIZ_KURU],[TESLIMTARIHI],[ISKONTO2],[IZLEME],'+
              ' [MF],[DOVIZ_BIRIMFIYAT],[YERI],[YERID],[EKLEYEN],[EKLEMETARIHI],DOVIZKURDEGERI,[SUBEID],[PROJEID])'+
              ' values ('+Tablo.Query6.FieldByName('SIPARISID').AsString+','+IntToStr(RehID)+',1,'+IntToStr(GetValue(Gezici,GridSTOKID.Index))+','+FloatToStr(GetValue(Gezici,GridYENISIPARISADET.Index))+','+IntToStr(GetValue(Gezici,GridBIRIM.Index))+','+FloatToStr(GetValue(Gezici,GridYENISIPARISADET.Index))+','+FloatToStr(GetValue(Gezici,GridSIPBIRIMFIYAT.Index))+','+
              ' '+FloatToStr((GetValue(Gezici,GridYENISIPARISADET.Index)* GetValue(Gezici,GridSIPBIRIMFIYAT.Index))*( 1 + GetValue(Gezici,GridKDV.Index)/100.0)) +','+
              ' 0,'+IntToStr(GetValue(Gezici,GridKDV.Index))+','+
              ' -1,''TL'','+
              ' '+FloatToStr((GetValue(Gezici,GridYENISIPARISADET.Index)* GetValue(Gezici,GridSIPBIRIMFIYAT.Index))*( 1 + GetValue(Gezici,GridKDV.Index)/100.0)) +','+
              ' ''TL'','''+FormatDateTime('yyyy-mm-dd hh:nn',GetValue(Gezici,GridTESLIMTARIHI.Index))+''',0,0,0,'+
              ' 1,'+IntToStr(DonusTipi)+','+IntToStr(GetValue(Gezici,GridID.Index))+','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+
              ' 1,'+IntToStr(SubeId)+',-1) '+
              ' select scope_identity() ';
              Tablo.Query2.Open;
              //yeni satırın toplamları yapılıyor ve TEKLIF tablosu güncelleniyor.                                                                             isnull(SUM(SD.TUTAR*(1+SD.KDV/100)),0)
              Tablo.TablodanSorguAc(4,'Select SIPARIS_MATRAHI = isnull(SUM(SD.TUTAR),0) ,KDV_TUTARI = isnull(SUM(SD.KDV*(Sd.TUTAR/100.0)),0),'+
                 ' SIPARIS_TUTARI = isnull(SUM(SD.TUTAR),0) + isnull(SUM(SD.KDV*(Sd.TUTAR/100.0)),0) from SIPARISDETAY SD Where SIPARISID='+Tablo.Query6.FieldByName('SIPARISID').AsString+' ');
              veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update SIPARIS set SIPARIS_MATRAHI='+Tablo.Query4.FieldByName('SIPARIS_MATRAHI').AsString+' ,KDV_TUTARI='+Tablo.Query4.FieldByName('KDV_TUTARI').AsString+', SIPARIS_TUTARI='+Tablo.Query4.FieldByName('SIPARIS_TUTARI').AsString+',DOVIZ_TUTARI='+Tablo.Query4.FieldByName('SIPARIS_TUTARI').AsString+' '+
                 ' Where ID='+Tablo.Query6.FieldByName('SIPARISID').AsString+' ' ,[],[]);

            end else begin
               // Sipariş Tablosuna kayıt
              Tablo.Query1.Close;
              Tablo.Query1.SQL.Text:='INSERT INTO [SIPARIS] ([TARIH],[TUR],[TIPI],[REHBERID],[PROJEID],[AKTIVITEID],[SIPARISTARIH],[SIPARISSERI],'+
              ' [KOCANNO],[SIPARISNO],'+DepoField+',[BASLIK],[ADRES],[ILCE],[IL],[VD],[VNO],[KDVDURUM],[SIPARIS_MATRAHI],[KDV_TUTARI],'+
              ' [SIPARIS_TUTARI],[KUR],[DOVIZ_TUTARI],[DOVIZ_CINSI],[DURUM],[EKLEYEN],[EKLEMETARIHI],'+
              ' [FIYAT_LISTESI],[YERI],[YERID],[TEKLIFNO],DOVIZKUR,[REHBERILETID],[SUBEID])'+
              ' values ('''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','+IntToStr(Tur)+',1,'+IntToStr(RehID)+',-1,-1,'''+FormatDateTime('yyyy-mm-dd hh:nn',Tablo.GENINI.BugunTrhSaat)+''','''+belgeno.Serino+''','+IntToStr(KocannoBul(Tur))+','''+belgeno.BelgeNo+''','+IntToStr(VarsDepoID)+','+
              ' '''+Tablo.tabCariBilgileri.FieldByName('FIRMA').AsString+''', '''+Tablo.tabCariBilgileri.FieldByName('ADRES').AsString+''','+
              ' '''+Tablo.tabCariBilgileri.FieldByName('ILCE').AsString+''', '''+Tablo.tabCariBilgileri.FieldByName('IL').AsString+''', '+
              ' '''+Tablo.tabCariBilgileri.FieldByName('VERGIDAI').AsString+''', '''+Tablo.tabCariBilgileri.FieldByName('VERGINO').AsString+''', ''Hariç'','+
              ' '+FloatToStr(GetValue(Gezici,GridYENISIPARISADET.Index)* GetValue(Gezici,GridSIPBIRIMFIYAT.Index))+' ,'+
              ' '+FloatToStr(GetValue(Gezici,GridKDV.Index)*(GetValue(Gezici,GridYENISIPARISADET.Index) * GetValue(Gezici,GridSIPBIRIMFIYAT.Index)/100.0))+','+       //KDV*(TUTAR/100.0)
              ' '+FloatToStr((GetValue(Gezici,GridYENISIPARISADET.Index)* GetValue(Gezici,GridSIPBIRIMFIYAT.Index))*( 1 + GetValue(Gezici,GridKDV.Index)/100.0))+' ,'+
              ' ''TL'','+FloatToStr(GetValue(Gezici,GridKDV.Index)*(GetValue(Gezici,GridYENISIPARISADET.Index) * GetValue(Gezici,GridSIPBIRIMFIYAT.Index)/100.0))+' ,'+
              ' ''TL'',1,'+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+
              ' '+Tablo.Query3.FieldByName('FIYAT_LISTESI').AsString+','+IntToStr(DonusTipi)+','+TabDetay.FieldByName('TEKLIFID').AsString+','''+Tablo.Query3.FieldByName('TEKLIFNO').AsString+''',1,'+Tablo.Query3.FieldByName('REHBERILETID').AsString+','+IntToStr(SubeId)+') '+
              '  select scope_identity() ';
              Tablo.Query1.Open;

              //SiparişDetay tablosuna kayıt
              Tablo.Query2.Close;
              Tablo.Query2.SQL.Text:='INSERT INTO [SIPARISDETAY]([SIPARISID],[REHBERID],[TUR],[URUNID],[ADET],[BIRIM],[MIKTAR]'+
              ' ,[BIRIMFIYAT],[TUTAR],[ISKONTO],[KDV],[MASRAFID],[KUR],[DOVIZ_TUTARI],[DOVIZ_KURU],[TESLIMTARIHI],[ISKONTO2],[IZLEME],'+
              ' [MF],[DOVIZ_BIRIMFIYAT],[YERI],[YERID],[EKLEYEN],[EKLEMETARIHI],DOVIZKURDEGERI,[SUBEID],[PROJEID])'+
              ' values ('+Tablo.Query1.fields[0].AsString+','+IntToStr(RehID)+',1,'+IntToStr(GetValue(Gezici,GridSTOKID.Index))+','+FloatToStr(GetValue(Gezici,GridYENISIPARISADET.Index))+','+IntToStr(GetValue(Gezici,GridBIRIM.Index))+','+FloatToStr(GetValue(Gezici,GridYENISIPARISADET.Index))+','+FloatToStr(GetValue(Gezici,GridSIPBIRIMFIYAT.Index))+','+
              ' '+FloatToStr((GetValue(Gezici,GridYENISIPARISADET.Index)* GetValue(Gezici,GridSIPBIRIMFIYAT.Index))*( 1 + GetValue(Gezici,GridKDV.Index)/100.0)) +','+
              ' 0,'+IntToStr(GetValue(Gezici,GridKDV.Index))+','+
              ' -1,''TL'','+
              ' '+FloatToStr((GetValue(Gezici,GridYENISIPARISADET.Index)* GetValue(Gezici,GridSIPBIRIMFIYAT.Index))*( 1 + GetValue(Gezici,GridKDV.Index)/100.0)) +','+
              ' ''TL'','''+FormatDateTime('yyyy-mm-dd hh:nn',GetValue(Gezici,GridTESLIMTARIHI.Index))+''',0,0,0,'+
              ' 1,'+IntToStr(DonusTipi)+','+IntToStr(GetValue(Gezici,GridID.Index))+','+Kullanan+','''+FormatDateTime('yyyy-mm-dd hh:nn:ss',Tablo.GENINI.BugunTrhSaat)+''','+
              ' 1,'+IntToStr(SubeId)+',-1)';
             // ' select scope_identity() ';
              Tablo.Query2.ExecSQL;

           end;
         end else
           Application.MessageBox('Yeni Sipariş ve Firma girilmiş olmalı.',PChar(Uyari),MB_OK);

      end;

    end;
  end;

  ModalResult:=mrOk;
end;

procedure TVerilenSiparisTabloDlg.FormCreate(Sender: TObject);
begin
//  GridSiparisTableView1.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\VerilenSiparisTabloGridi',true,False,[gsoUseFilter],'VerilenSiparisTabloGridi');
end;

procedure TVerilenSiparisTabloDlg.FormShow(Sender: TObject);
var
  sirano, i: Integer;
begin

TabDetay.Close;
TabDetay.Params[0].Value:=TeklifId;
TabDetay.Open;
  while not TabDetay.Eof do begin
   GridSiparisTableView1.DataController.BeginFullUpdate;
   with GridSiparisTableView1.DataController do
    begin
      sirano := GridSiparisTableView1.DataController.AppendRecord;
      SetValue(sirano, GridTESLIMTARIHI.Index, FormatDateTime('yyyy-mm-dd 00:00:00',TabDetay.FieldByName('TESLIMTARIHI').AsDateTime));
      SetValue(sirano, GridKOD.Index, TabDetay.FieldByName('KOD').AsString);
      SetValue(sirano, GridAD.Index, TabDetay.FieldByName('AD').AsString);
      SetValue(sirano, GridACIKLAMA.Index, TabDetay.FieldByName('ACIKLAMA').AsString);
      SetValue(sirano, GridADET.Index, TabDetay.FieldByName('ADET').AsFloat);
      SetValue(sirano, GridBIRIM.Index, TabDetay.FieldByName('BIRIM').AsInteger);
      SetValue(sirano, GridDEPODA.Index, TabDetay.FieldByName('DEPODA').AsFloat);
      SetValue(sirano, GridYOLDAGELEN.Index, TabDetay.FieldByName('YOLDAGELEN').AsFloat);
      SetValue(sirano, GridYOLDAGIDECEK.Index, TabDetay.FieldByName('YOLDAGIDECEK').AsFloat);
      SetValue(sirano, GridFARK.Index, TabDetay.FieldByName('FARK').AsFloat);
      SetValue(sirano, GridYENISIPARISADET.Index, TabDetay.FieldByName('YENISIPARISADET').AsFloat);
      SetValue(sirano, GridFIRMA.Index, TabDetay.FieldByName('FIRMA').AsString);
      tablo.TablodanSorguAc(1,'Select FIYAT from STOKFIYAT Where STOKID='+TabDetay.FieldByName('URUNID').AsString+' and FIYATADI='+GenRegIni.RegReadString('StokHizliGiris', 'VarsayilanFiyatAlis', '10', 'C')+'  ');
      SetValue(sirano, GridSIPBIRIMFIYAT.Index, Tablo.Query1.FieldByName('FIYAT').AsFloat);
      SetValue(sirano, GridID.Index, TabDetay.FieldByName('ID').AsInteger);
      SetValue(sirano, GridTEKLIFID.Index, TabDetay.FieldByName('TEKLIFID').AsInteger);
      SetValue(sirano, GridSTOKID.Index, TabDetay.FieldByName('URUNID').AsInteger);
      SetValue(sirano, GridKDV.Index, TabDetay.FieldByName('KDV').AsInteger);
      Post;
    end;
    GridSiparisTableView1.DataController.EndFullUpdate;
    TabDetay.Next;
  end;
   GridSiparisTableView1.ApplyBestFit();
end;

procedure TVerilenSiparisTabloDlg.GridFIRMAPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  RehID:integer;
begin
  RehID := Tablo.RehberAra_IDGetir(-1);
  if RehID < 1 then
    exit
  else begin
   GridSiparisTableView1.DataController.SetValue(GridSiparisTableView1.DataController.FocusedRecordIndex,GridRehberID.Index,RehID);
   GridSiparisTableView1.DataController.SetValue(GridSiparisTableView1.DataController.FocusedRecordIndex,GridFIRMA.Index,Tablo.AciklamaGetir('REHBER', 'FIRMA', RehID))
  end;
end;

procedure TVerilenSiparisTabloDlg.GridSiparisTableView1CanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
//  AnaForm.cxGridPopupMenu1.Grid:=GridSiparis;
//  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridSiparisTableView1;
//  AnaForm.pmGridStil.Tags.Values[GridSiparis.Name]:='VerilenSiparisTabloGridi';
end;

procedure TVerilenSiparisTabloDlg.ToolButton3Click(Sender: TObject);
begin
  ModalResult:=mrAbort;
end;

end.







