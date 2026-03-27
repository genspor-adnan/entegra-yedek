unit UStokLokasyon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, cxGrid,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLiquidSky, dxSkinscxPCPainter, FireDAC.Comp.Client, cxEdit,
  cxCustomData, cxGraphics, cxFilter, cxClasses, cxDataStorage, cxDBData, ExtCtrls,
  cxGridTableView, cxControls, cxData, DB, cxGridLevel, cxGridCustomView, cxGridCustomTableView,
  cxGridDBTableView, cxContainer, cxLabel, StdCtrls, Buttons, ComCtrls, ToolWin, FetaKurulusSiniflari,
  dxSkinLondonLiquidSky, cxTextEdit, cxLookAndFeels, cxLookAndFeelPainters, cxNavigator,
  cxImageComboBox, cxButtonEdit, cxMemo, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray;

type
  TStokLokasyonDlg = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    PanelAlt: TPanel;
    Tablokasyon: TFDQuery;
    DtsLokasyon: TDataSource;
    cxGrid1DBTableView1MIKTAR: TcxGridDBColumn;
    KaydetTus: TBitBtn;
    CancelBtn: TBitBtn;
    ToolBar5: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetBtn: TToolButton;
    IptalBtn: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    cxGrid1DBTableView1KOD: TcxGridDBColumn;
    cxGrid1DBTableView1ACIKLAMA: TcxGridDBColumn;
    Panel1: TPanel;
    LblGerekliMiktar: TcxLabel;
    LblSecileniMiktar: TcxLabel;
    cxGrid1DBTableView1DURUM: TcxGridDBColumn;
    MemoGiris: TcxMemo;
    MemoCikis: TcxMemo;
    procedure FormShow(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure TablokasyonNewRecord(DataSet: TDataSet);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TablokasyonAfterPost(DataSet: TDataSet);
    procedure DtsLokasyonStateChange(Sender: TObject);
    procedure KaydetBtnClick(Sender: TObject);
    procedure IptalBtnClick(Sender: TObject);
    procedure cxGrid1DBTableView1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure cxGrid1DBTableView1Column1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure TablokasyonBeforePost(DataSet: TDataSet);
    procedure TablokasyonAfterOpen(DataSet: TDataSet);
    procedure TablokasyonAfterDelete(DataSet: TDataSet);
  private
    procedure TempTabloOlustur;
    { Private declarations }
  public
    { Public declarations }
    StokID:Integer;
    IslemTur:Integer;
    BaslikID:Integer;
    SatirID:Integer;
    GirDepo:Integer;
    CikDepo:Integer;
    Miktar:Extended;
    Durum:Boolean;
  end;

var
  StokLokasyonDlg: TStokLokasyonDlg;
  TabloAdi:string;

implementation

uses   Utablo, UKodAgaci;


{$R *.dfm}



procedure TStokLokasyonDlg.FormShow(Sender: TObject);
begin
  TempTabloOlustur;
  Caption := Tablo.AciklamaGetir('STOKLAR','KOD+'' ''+STOKADI',StokID)+' '+Caption;
  Tablo.TablodanSorguAc(2,'select sum(MIKTAR) from '+TabloAdi+' ');
  LblSecileniMiktar.Caption := ' Seçilen Miktar:'+Tablo.Query2.Fields[0].AsString;
  LblGerekliMiktar.Caption := ' Gerekli Miktar:'+floattostr(Miktar);

  {if (GirDepo>0) and (CikDepo>0) then begin//transfer
    cxGrid1DBTableView1DURUM.Visible := True;
    cxGrid1DBTableView1MIKTAR.Visible := True;
  end else }if CikDepo>0 then begin//çıkış
    cxGrid1DBTableView1DURUM.Visible := True;
    cxGrid1DBTableView1MIKTAR.Visible := True;
  end else if GirDepo>0 then begin//giriş
    cxGrid1DBTableView1DURUM.Visible := False;
    cxGrid1DBTableView1MIKTAR.Visible := True;
  end else begin
    ShowMessage('Depo seçiminiz hatalı!');
    Abort;
  end;
end;

procedure TStokLokasyonDlg.TempTabloOlustur;
begin
  TabloAdi := '##TmpStokLokasyon_'+IntToStr(SPID)+'_'+FormatDateTime('yyyymmddhhnnss',Now);
  TabLokasyon.Close;
  TabLokasyon.SQL.Text := 'create table '+TabloAdi+'(';
  TabLokasyon.SQL.Add('[ID] [int] IDENTITY(1,1) NOT NULL,');
  TabLokasyon.SQL.Add('[GIRISLOKASYONID] [int] NULL,');
  TabLokasyon.SQL.Add('[CIKISLOKASYONID] [int] NULL,');
  TabLokasyon.SQL.Add('[KOD] [nvarchar](100) NULL,');
  TabLokasyon.SQL.Add('[ACIKLAMA] [nvarchar](250) NULL,');
  TabLokasyon.SQL.Add('[DURUM] float NULL, ');
  TabLokasyon.SQL.Add('[MIKTAR] float NULL) ');
  TabLokasyon.ExecSQL;

  TabLokasyon.Close;
  if GirDepo>0 then //giriş
    TabLokasyon.SQL.Text := StringReplace(MemoGiris.Lines.Text,'<TabloAdi>',TabloAdi,[rfReplaceAll])
  else
    TabLokasyon.SQL.Text := StringReplace(MemoCikis.Lines.Text,'<TabloAdi>',TabloAdi,[rfReplaceAll]);
  TabLokasyon.Params[0].Value := IslemTur;//:PBT
  TabLokasyon.Params[1].Value := BaslikID;//:PBID
  TabLokasyon.Params[2].Value := SatirID;//:PSID
  TabLokasyon.Params[3].Value := StokID;//:PSTID
  TabLokasyon.Params[4].Value := GirDepo;//:PGDepo
  TabLokasyon.Params[5].Value := CikDepo;//:PCDepo
  TabLokasyon.ExecSQL;

  TabLokasyon.Close;
  TabLokasyon.SQL.Text := 'select * from '+TabloAdi;
  TabLokasyon.Open;
end;

procedure TStokLokasyonDlg.KaydetTusClick(Sender: TObject);
begin
  if TabLokasyon.State in [dsEdit,dsInsert] then
    TabLokasyon.Post;
  ModalResult := MrOk;
end;

procedure TStokLokasyonDlg.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TStokLokasyonDlg.cxGrid1DBTableView1Column1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  LokID:Integer;
  LokKod,LokAciklama,sqltext:string;
  KodAgaciLokasyonDlg:TKodAgaciDlg;
  Depo:integer;
  slist : TStringList;
begin
  if KodAgaciLokasyonDlg = nil then
    Application.CreateForm(TKodAgaciDlg,KodAgaciLokasyonDlg);
  if GirDepo>0 then
    Depo := GirDepo
  else
    Depo := CikDepo;
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,EN,BOY,DERINLIK,YERI,YERID,ID from LOKASYON where DURUM=1 and YERI='+IntToStr(TabNo_DEPOLAR)+'  and YERID='+IntToStr(Depo);
  Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,False,False,False,True,LokID,LokKod,LokAciklama,slist,[nil,nil,nil],['YERI','YERID'],[TabNo_DEPOLAR,GirDepo],['Kod','Açıklama','',''],[True,True,True,True,True,False,False],True);
  if LokID>0 then begin
    TabLokasyon.Edit;
    if GirDepo>0 then begin
      Tablokasyon.FieldByName('GIRISLOKASYONID').AsInteger := LokID;
      Tablokasyon.FieldByName('CIKISLOKASYONID').AsInteger := 0;
    end else begin
      Tablokasyon.FieldByName('GIRISLOKASYONID').AsInteger := 0;
      Tablokasyon.FieldByName('CIKISLOKASYONID').AsInteger := LokID;
    end;
    Tablokasyon.FieldByName('KOD').AsString := LokKod;
    Tablokasyon.FieldByName('ACIKLAMA').AsString := LokAciklama;
    TabLokasyon.Post;
  end;
  FreeAndNil(KodAgaciLokasyonDlg);
  Tablokasyon.Close;
  TabLokasyon.Open;
  //LokID,LokKod,LokAciklama den güncelleme yapılacak..
end;

procedure TStokLokasyonDlg.cxGrid1DBTableView1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=13 then begin
    if TabLokasyon.State=dsInsert then begin
      TabLokasyon.Post;
      TabLokasyon.Append;
    end else if TabLokasyon.State=dsEdit then begin
      TabLokasyon.Post;
      if not TabLokasyon.Eof then
        TabLokasyon.Next;
    end else if TabLokasyon.State=dsBrowse then begin
      if not TabLokasyon.Eof then
        TabLokasyon.Next;
    end;
  end;
end;

procedure TStokLokasyonDlg.DtsLokasyonStateChange(Sender: TObject);
begin
  EkleTus.Visible := DtsLokasyon.State = dsBrowse;
  SilTus.Visible := DtsLokasyon.State = dsBrowse;
  KaydetBtn.Visible := DtsLokasyon.State in [dsEdit,dsInsert];
  IptalBtn.Visible := DtsLokasyon.State in [dsEdit,dsInsert];
end;

procedure TStokLokasyonDlg.EkleTusClick(Sender: TObject);
begin
  TabLokasyon.Append;
end;

procedure TStokLokasyonDlg.SilTusClick(Sender: TObject);
begin
  TabLokasyon.Delete;
end;

procedure TStokLokasyonDlg.KaydetBtnClick(Sender: TObject);
begin
  TabLokasyon.Post;
end;

procedure TStokLokasyonDlg.IptalBtnClick(Sender: TObject);
begin
  TabLokasyon.Cancel;
end;

procedure TStokLokasyonDlg.TablokasyonAfterDelete(DataSet: TDataSet);
begin
  Tablo.TablodanSorguAc(2,'select sum(MIKTAR) from '+TabloAdi+' ');
  LblSecileniMiktar.Caption := ' Seçilen Miktar:'+Tablo.Query2.Fields[0].AsString;
  KaydetTus.Enabled := Miktar=Tablo.Query2.Fields[0].AsFloat;
end;

procedure TStokLokasyonDlg.TablokasyonAfterOpen(DataSet: TDataSet);
begin
  Tablo.TablodanSorguAc(2,'select sum(MIKTAR) from '+TabloAdi+' ');
  LblSecileniMiktar.Caption := ' Seçilen Miktar:'+Tablo.Query2.Fields[0].AsString;
  KaydetTus.Enabled := Miktar=Tablo.Query2.Fields[0].AsFloat;
end;

procedure TStokLokasyonDlg.TablokasyonAfterPost(DataSet: TDataSet);
begin
  Tablo.TablodanSorguAc(2,'select sum(MIKTAR) from '+TabloAdi+' ');
  LblSecileniMiktar.Caption := ' Seçilen Miktar:'+Tablo.Query2.Fields[0].AsString;
  KaydetTus.Enabled := Miktar=Tablo.Query2.Fields[0].AsFloat;
  TabloYenile(Tablokasyon,[]);
end;

procedure TStokLokasyonDlg.TablokasyonBeforePost(DataSet: TDataSet);
begin
  if (GirDepo>0)and(Tablokasyon.FieldByName('MIKTAR').AsFloat<>0.0) then begin
    if Tablokasyon.FieldByName('GIRISLOKASYONID').AsInteger = 0 then begin
      ShowMessage('Giriş Lokasyonu Seçmelisiniz!');
      Abort;
    end;
  end;
  if (CikDepo>0)and(Tablokasyon.FieldByName('MIKTAR').AsFloat<>0.0) then begin
    if Tablokasyon.FieldByName('CIKISLOKASYONID').AsInteger = 0 then begin
      ShowMessage('Çıkış Lokasyonu Seçmelisiniz!');
      Abort;
    end;
  end;
end;

procedure TStokLokasyonDlg.TablokasyonNewRecord(DataSet: TDataSet);
begin
  Tablo.TablodanSorguAc(2,'select sum(MIKTAR) from '+TabloAdi+' ');
  TabLokasyon.FieldByName('MIKTAR').AsFloat := Miktar - Tablo.Query2.Fields[0].AsFloat;
end;

procedure TStokLokasyonDlg.FormCreate(Sender: TObject);
begin
  StokID:=0;
  IslemTur:=0;
  BaslikID:=0;
  SatirID:=0;
  GirDepo:=0;
  CikDepo:=0;
  Miktar:=0.0;
end;

procedure TStokLokasyonDlg.FormDestroy(Sender: TObject);
var Drm:string;
begin
  if Durum then
    Drm:='1'
  else
    Drm:='0';
  if ModalResult=mrOk then begin
    //Önce eski kayıtları silelim
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from STOKLOKASYON where STOKID=&StkID and BELGETUR=&BTur and BASLIKID=&BlgID and SATIRID=&StrID',['&StkID','&BTur','&BlgID','&StrID'],[StokID,IslemTur,BaslikID,SatirID]);
    //tempteki bilgileri gerçek tabloya alalım..
    Tablo.Query1.Close;
    Tablo.Query1.SQL.Text := 'insert into STOKLOKASYON(STOKID,BELGETUR,BASLIKID,SATIRID,GIRISDEPO,CIKISDEPO,MIKTAR,GIRISLOKASYONID,CIKISLOKASYONID,EKLEYEN,DURUM)';
    Tablo.Query1.SQL.Add('select '+IntToStr(StokID)+','+IntToStr(IslemTur)+','+IntToStr(BaslikID)+','+IntToStr(SatirID)+','+IntToStr(GirDepo)+','+IntToStr(CikDepo)+',MIKTAR,GIRISLOKASYONID,CIKISLOKASYONID,'+Kullanan+','+Drm+' from '+TabloAdi);
    Tablo.Query1.SQL.Add('where MIKTAR <> 0.0 ');
    Tablo.Query1.ExecSQL;
  end;
end;

end.




