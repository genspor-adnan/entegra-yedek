unit UAlarm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, Menus, cxLookAndFeelPainters,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLabel, StdCtrls, cxButtons,
  cxContainer, cxDBLabel, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, FireDAC.Comp.Client,
  cxCalendar, cxProgressBar, cxImageComboBox, GIFImg, ExtCtrls,
  dxSkinLondonLiquidSky, cxCheckBox, JvExExtCtrls, JvExtComponent, JvPanel,
  cxSplitter,MMSystem, cxLookAndFeels, cxNavigator, dxSkinLiquidSky,
  dxDateRanges, dxScrollbarAnnotations;
type
  TAlarmDlg = class(TForm)
    pnlAnimsat: TPanel;
    Image1: TImage;
    cxGrid1: TcxGrid;
    tvAktiviteAnimsat: TcxGridDBTableView;
    tvAktiviteAnimsatKONUSU: TcxGridDBColumn;
    tvAktiviteAnimsatTARIH: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    cxDBLabel2: TcxDBLabel;
    cxButton1: TcxButton;
    cxButton2: TcxButton;
    OgeAcTus: TcxButton;
    cxButton4: TcxButton;
    ComboAnimsatmaZamani: TcxImageComboBox;
    cxDBLabel1: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    DtsAlarmDetay: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    Procedure Yenile;
    procedure cxButton2Click(Sender: TObject);
    procedure TabAlarmDetayAfterScroll(DataSet: TDataSet);
    procedure cxButton4Click(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure OgeAcTusClick(Sender: TObject);
    procedure tvAktiviteAnimsatFocusedRecordChanged(
      Sender: TcxCustomGridTableView; APrevFocusedRecord,
      AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
  private
    { Private declarations }
    AktiviteID:Integer;
  public
    RehbID:Integer;
    { Public declarations }
  end;

var
  AlarmDlg: TAlarmDlg;

implementation

{$R *.dfm}

Uses
 Utablo,FetaKurulusSiniflari,PrjConst,LocOnFly, UGorevDlg, UVeriMotor;


procedure TAlarmDlg.cxButton1Click(Sender: TObject);
begin
  if Application.MessageBox(PChar(ALGorevler_animsaticilardan_cikartilsinmi),PChar(SGenotipOnay),MB_YESNO)=IDYES then begin
     DtsAlarmDetay.DataSet.First;
     while Not DtsAlarmDetay.DataSet.Eof do begin
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update GOREVLER set ANIMSAT=0 where ID=&AktiviteID',['&AktiviteID'],[AktiviteID]);
        Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from ANIMSAT where TUR=1 and ID=&AktiviteID  and PERSONEL=&Personel ',['&AktiviteID','&Personel'],[AktiviteID,Kullanan]);
        DtsAlarmDetay.DataSet.Next;
     end;
  end;
  Yenile;
end;

procedure TAlarmDlg.cxButton2Click(Sender: TObject);
var
  Komut:String;
begin
   case ComboAnimsatmaZamani.editvalue of
     100..199: Komut:= DbTarihEkle('MINUTE',copy(IntToStr(ComboAnimsatmaZamani.editvalue),2,2),'GETDATE()');
     200..299: Komut:= DbTarihEkle('HOUR',copy(IntToStr(ComboAnimsatmaZamani.editvalue),2,2),'GETDATE()');
     300..399: Komut:= DbTarihEkle('DAY',copy(IntToStr(ComboAnimsatmaZamani.editvalue),2,2),'GETDATE()');
   end;
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'update ANIMSAT set TARIH='+Komut+'  where TUR=1 and ID=&AktiviteID and PERSONEL=&Personel ',['&AktiviteID','&Personel'],[AktiviteID,Kullanan]);

  Yenile;
end;

procedure TAlarmDlg.OgeAcTusClick(Sender: TObject);
Var
  Turu:Integer;
  AtamaYapildi, YorumYapildi : Boolean;
  GorevDlg1 : TGorevDlg;
begin
//  Turu:=((DtsAlarmDetay.DataSet) as TFDQuery).FieldByName('TURU').AsInteger;
//  Tablo.AktiviteGoster('D',nil,Turu,AktiviteID,-2,Tablo.GENINI.BugunTrh);
  if Tablo.GorevSihirbazBaslat(GorevDlg1, 'D',AktiviteID,AtamaYapildi, YorumYapildi) > 0 then
     Yenile;
end;

procedure TAlarmDlg.cxButton4Click(Sender: TObject);
begin
//  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update AKTIVITELER set ANIMSAT=0 where ID=&AktiviteID',['&AktiviteID'],[AktiviteID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'Update GOREVLER set ANIMSAT=0 where ID=&AktiviteID',['&AktiviteID'],[AktiviteID]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from ANIMSAT where TUR=1 and ID=&AktiviteID and PERSONEL=&Personel ',['&AktiviteID','&Personel'],[AktiviteID,Kullanan]);
  Yenile;
end;

procedure TAlarmDlg.tvAktiviteAnimsatFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord,
  AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
Var
  DataSet:TFDQuery;
begin
  AktiviteID:=((DtsAlarmDetay.DataSet) as TFDQuery).FieldByName('ID').AsInteger;

end;

procedure TAlarmDlg.FormCreate(Sender: TObject);
//Var
  //ComboProperty1,ComboProperty2:TcxCustomImageComboBoxProperties;
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //DurumIçeriği
  {if Tablo.TablodanSorguAc(1,'select ANAHTAR,DEGER from REHERINI where BOLUM = ''Görev_Durum''')then begin
    Tablo.Query1.First;
    ComboProperty1:=(cxGrid1DBTableView1DURUM.Properties) as TcxCustomImageComboBoxProperties ;
    while Not Tablo.Query1.Eof do begin
      With ComboProperty1.Items.Add do begin
         Description:= Tablo.Query1.fields[0].AsString;
         Value:= Tablo.Query1.fields[1].AsInteger;
      end;
      Tablo.Query1.Next;
    end;
  end;
  if Tablo.TablodanSorguAc(2,'select FIRMA,ID from REHBER where DURUM=1 and KULLANICIID>-2') then begin
    Tablo.Query2.First;
    ComboProperty2:=(cxGrid1DBTableView1GOREVATAYAN.Properties) as TcxCustomImageComboBoxProperties ;
    while Not Tablo.Query2.Eof do begin
      With ComboProperty2.Items.Add do begin
         Description:= Tablo.Query2.fields[0].AsString;
         Value:= Tablo.Query2.fields[1].AsInteger;
      end;
      Tablo.Query2.Next;
    end;
    cxGrid1DBTableView1GOREVLIPERSONEL.Properties:=cxGrid1DBTableView1GOREVATAYAN.Properties;
  end;   }
  ComboAnimsatmaZamani.ItemIndex:=0;
 { StringReplace(TabAlarmDetay.SQL.Text,'DATEDIFF(DAY,7,BITISTARIHI)','DATEDIFF(DAY,'
  +TabAlarmDetay.FieldByName('ANIMSATMAYABASLA').AsString
  +',BITISTARIHI)',[rfReplaceAll]) }
  Tablo.GridTurkcelestir;
end;

Procedure TAlarmDlg.Yenile;
Begin
 if DtsAlarmDetay.DataSet<>nil then
 begin
      DtsAlarmDetay.DataSet.Close;
    //  DtsAlarmDetay.DataSet.Params[0].Value:=Kullanan; //rehberid
      DtsAlarmDetay.DataSet.Open;
      if DtsAlarmDetay.DataSet.RecordCount=0 then
         Close
      else
         AlarmDlg.Caption:=inttostr(DtsAlarmDetay.DataSet.RecordCount)+' Aktivite.';
     // cxGrid1DBTableView1.ApplyBestFit(nil);
      TabAlarmDetayAfterScroll(DtsAlarmDetay.DataSet);
 end;
End;

procedure TAlarmDlg.FormShow(Sender: TObject);
begin
  Yenile;
  if tvAktiviteAnimsat.DataController.RecordCount>0 then begin
    tvAktiviteAnimsat.ApplyBestFit(nil);
    //lbGorevSayisi.Caption:= 'Süresi geçen '+inttostr(tvGorevHatirlat.DataController.RecordCount)+' adet göreviniz var';
  end else begin
    //lbGorevSayisi.Caption:= '';

  end;
  PlaySound('GorevAnimsatici.wav', 0, SND_FILENAME + SND_ASYNC);
end;

procedure TAlarmDlg.TabAlarmDetayAfterScroll(DataSet: TDataSet);
begin
  AktiviteID:=DtsAlarmDetay.DataSet.Fields[0].AsInteger;
  cxLabel1.Caption:='Bitiş Tarihi: '+DtsAlarmDetay.DataSet.FieldByName('TARIH').AsString;

end;

end.





