
unit UDemirbasHareket;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxGraphics, cxStyles,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid,UKodAgaci,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, Buttons,
  cxDropDownEdit, cxImageComboBox, cxDBEdit, cxLabel, cxDBLabel, cxMemo,UGentegreFrameYonetimi,
  cxContainer, cxTextEdit, cxMaskEdit, cxCalendar, StdCtrls, ExtCtrls,UFrameYoneticisi,
  JvExExtCtrls, JvExtComponent, JvPanel, cxButtonEdit, ComCtrls, ToolWin, Menus,UTablo,
  frxClass, frxDBSet, cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TDemirbasHareketDlg = class(TForm , IPopupDialog)
    JvPanel1: TJvPanel;
    DateTutanakTarih: TcxDBDateEdit;
    editBelgeNo: TcxDBTextEdit;
    memoNotlar: TcxDBMemo;
    cbDurum: TcxDBImageComboBox;
    TabTutanak: TFDQuery;
    dtsTutanak: TDataSource;
    dtsTutanakDetay: TDataSource;
    TabTutanakDetay: TFDQuery;
    cbZimmetVeren: TcxButtonEdit;
    cbZimmetAlan: TcxButtonEdit;
    cbDuzenleyen: TcxButtonEdit;
    ToolBar3: TToolBar;
    btnKaydet: TToolButton;
    btnSil1: TToolButton;
    ToolButton1: TToolButton;
    btnkapat: TToolButton;
    BELokasyon: TcxButtonEdit;
    YaziciYaz: TToolButton;
    PopupMenuYaz: TPopupMenu;
    BaskiOnizlemeMenu: TMenuItem;
    YazcyaYazdr1: TMenuItem;
    N1: TMenuItem;
    Gnder1: TMenuItem;
    PDF1: TMenuItem;
    Word1: TMenuItem;
    Excel2: TMenuItem;
    CSV1: TMenuItem;
    ext1: TMenuItem;
    HTML2: TMenuItem;
    JPG1: TMenuItem;
    N2: TMenuItem;
    EMail1: TMenuItem;
    N3: TMenuItem;
    frxReport1: TfrxReport;
    frxTutanakDetay: TfrxDBDataset;
    frxTutanakBas: TfrxDBDataset;
    TabTutanakYaz: TFDQuery;
    lblZimmeteVeren: TcxLabel;
    Tarih: TcxLabel;
    lblZimmetAlan: TcxLabel;
    lbLokasyon: TcxLabel;
    Label5: TcxLabel;
    LblTutanakID: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    Label3: TcxLabel;
    cxDBLabel2: TcxDBLabel;
    cxDBLabel3: TcxDBLabel;
    PanelGrid: TPanel;
    ToolBarDetay: TToolBar;
    btnYeni: TToolButton;
    btnSil: TToolButton;
    gridTutanakDetay: TcxGrid;
    tvTutanakDetay: TcxGridDBTableView;
    clmId: TcxGridDBColumn;
    clmDemirbasId: TcxGridDBColumn;
    clmStokKodu: TcxGridDBColumn;
    clmDemirbasAdi: TcxGridDBColumn;
    clmSerino: TcxGridDBColumn;
    clmAlimTarihi: TcxGridDBColumn;
    tvTutanakDetayDURUM: TcxGridDBColumn;
    gridTutanakDetayLevel1: TcxGridLevel;
    tvTutanakDetayLOKASYONADI: TcxGridDBColumn;
    procedure TabTutanakNewRecord(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DemirbasBilgiGuncelle (demirbasid, durum, zimmetpersonel, lokasyon:Integer;zimmettarihi: TDateTime);
    procedure cbZimmetVerenPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbZimmetAlanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cbDuzenleyenPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure dtsTutanakStateChange(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnYeniClick(Sender: TObject);
    procedure btnSilClick(Sender: TObject);
    procedure BELokasyonPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure btnSil1Click(Sender: TObject);//Zimmet_alan,Zimmet_Lokasyon:String);
    procedure YazdirmayaHazirla(AFastReport: TfrxReport);
    function EkranAdiAl: string;
    procedure BaskiOnizlemeMenuClick(Sender: TObject);
    Function FormNoGetirFunc: string;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnkapatClick(Sender: TObject);
    procedure TabTutanakBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
    KodAgaciLokasyonDlg:TKodAgaciDlg;
    procedure DemirbasHareketCaseof;

  public
    { Public declarations }
    TutanakID, Tutanak_Tipi, ZimmetId, LokasyonId:integer;
    //HareketOp:char;
    //KaydetCount:integer;
    IslemOp:char;
    DemirbasIDList:TStringList;
  end;

var
  DemirbasHareketDlg: TDemirbasHareketDlg;

  procedure DemirbasHareketBaslat(IslemOp:char;TutanakID,Tutanak_Tipi,ZimmetId, LokasyonId:Integer; DemirbasIDList:TStringList);//;Zimmet_alan,Zimmet_Lokasyon:String);
  procedure TutanakDetayEkle(TutanakId, demirbasid, Tutanak_tipi:integer);

implementation
uses  UDemirbasListeDlg,Ucombo,UDemirbasWizard,UGenelAnaSekmeFrame,URaporAraclari,UFastRap,
      PrjConst,LocOnFly, FetaKurulusSiniflari;

{$R *.dfm}

var
  Tutanaktipi:Integer;


procedure TutanakDetayEkle(TutanakId, Demirbasid, Tutanak_tipi:integer);
begin
   // Tutanak detay tablosuna ilgili kayıt atılıyor
    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' INSERT INTO DEMIRBAS_TUTANAK_DETAY ( TUTANAKID, DEMIRBASID, EKLEYEN,SUBEID )'+
                            '  VALUES ('+IntToStr(TutanakId)+',' + IntToStr(demirbasid)+','''+Kullanan+''','+inttostr(SubeID)+' ) ',[],[]);
end;

procedure DemirbasHareketBaslat(IslemOp:char; TutanakID,Tutanak_Tipi, ZimmetId, LokasyonId:Integer; DemirbasIDList:TStringList);//;Zimmet_alan,Zimmet_Lokasyon:String);
var i : smallint;
begin
  Application.CreateForm(TDemirbasHareketDlg, DemirbasHareketDlg);
  DemirbasHareketDlg.IslemOp := IslemOp;
  DemirbasHareketDlg.TutanakID := TutanakID;
  DemirbasHareketDlg.DemirbasIDList := DemirbasIDList;
  DemirbasHareketDlg.Tutanak_Tipi := Tutanak_Tipi;
  DemirbasHareketDlg.ZimmetId := ZimmetId;
  DemirbasHareketDlg.LokasyonId := LokasyonId;
  DemirbasHareketDlg.ShowModal;
  FreeAndNil(DemirbasHareketDlg);
end;

function TDemirbasHareketDlg.EkranAdiAl: string;
begin
  Result := 'DemirbasHareketDlg_'+IntToStr(Tutanak_Tipi);
end;
procedure TDemirbasHareketDlg.btnYeniClick(Sender: TObject);
  var
  st:TStringList;
  SqlText:string;
  begin
  if dtsTutanak.State in [dsEdit, dsInsert] then
    begin
      Application.MessageBox(PChar(DDUst_bilgi_kayit),PChar(Uyari), MB_OK+ MB_ICONWARNING);
      Abort;
    end;
     Tutanaktipi:= TabTutanak.FieldByName('TIP').AsInteger;
     SqlText:='Select ID,STOKKODU,SERINO from DEMIRBAS';
     if tutanaktipi=1 then SqlText:='Select ID,STOKKODU,SERINO from DEMIRBAS Where DURUM in (4)';
     if (tutanaktipi=5) or (tutanaktipi=0) then SqlText:='Select ID,STOKKODU,SERINO from DEMIRBAS Where ZIMMETLIPERSONELID='+TabTutanak.FieldByName('ZIMMETVERENID').AsString+'';

     st:=TStringList.Create;
     if Tablo.ListedenBilgiGetir('Demirbaş Listesi',SqlText,st,[]) then begin
       TutanakDetayEkle(1, StrToInt(st.Strings[0]),Tutanaktipi);
       TabloYenile(TabTutanakDetay,[TabTutanak.FieldByName('ID').AsInteger]);
     end;


end;
Function TDemirbasHareketDlg.FormNoGetirFunc: string;
var
  say, i: smallint;
  s: String;
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select Num=isnull(max( cast(BELGENO as int)),0)+1 from DEMIRBAS_TUTANAK';
  Tablo.Query1.Open;

  s := Tablo.Query1.Fields[0].AsString;
  say := length(s);
  for i := 0 to 4 - say do
    s := '0' + s;
  Result := s;
end;
procedure TDemirbasHareketDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if TabTutanak.State in [dsEdit, dsInsert] then begin
      if Application.MessageBox(PChar(DDKaydedilsinmi),PChar(Uyari), MB_YESNO) = IDYES then
          btnKaydet.Click
      else begin
          if IslemOp='E' then begin
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from DEMIRBAS_TUTANAK_DETAY where TUTANAKID=&TId and DEMIRBASID=&DId', ['&TId','&DId'],
                 [TabTutanak.Fields[0].AsInteger, TabTutanakDetay.FieldByName('DEMIRBASID').AsInteger]);
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'if not exists(select * from DEMIRBAS_TUTANAK_DETAY where TUTANAKID=&TId) '+
                 ' delete from DEMIRBAS_TUTANAK where ID=&TId ', ['&TId'], [TabTutanak.Fields[0].AsInteger]);
          end;
          ModalResult := mrOk;
      end;
   end;


{  if IslemOp='D' then begin
    if TabTutanak.State in [dsEdit] then   //
    begin
      if Application.MessageBox(PChar(DDKaydedilsinmi),PChar(Uyari), MB_YESNO) = IDYES then
        btnKaydet.Click
      else  ModalResult := mrOk;

    end else
    begin
      ModalResult := mrOk;
    end;
  end else
  begin
    if TabTutanak.State in [dsEdit] then   //
    begin
      if Application.MessageBox(PChar(DDKaydedilsinmi),PChar(Uyari), MB_YESNO) = IDYES then
        btnKaydet.Click
      else  begin
//        if tutanakcagiran <> 0 then
           TutanakSilIptal;
          ModalResult := mrOk;
      end;
    end else
    begin
    if ModalResult=mrCancel then
       TutanakSilIptal;
      ModalResult := mrOk;
    end;
  end; }
end;

procedure TDemirbasHareketDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TDemirbasHareketDlg.DemirbasHareketCaseof;
begin
    if Tutanak_Tipi in [2,3] then begin //kayıp veya hurdaysa görünmesin
        lblZimmeteVeren.Visible := False;
        cbZimmetVeren.Visible := False;
        lblZimmetAlan.Visible := False;
        cbZimmetAlan.Visible := False;
        lbLokasyon.Visible := False;
        BELokasyon.Visible := False;
    end;

  //Tablo.TablodanSorguAc(1,'select ZIMMMETLIPERSONEL from DEMIRBAS where ID=')

  case Tutanak_Tipi of
    9: begin // iade tutanağı düzenleniyor    .Önceden değeri =0 idi.
        DemirbasHareketDlg.caption := TZimmetIadeKaydi;
        DemirbasHareketDlg.lblZimmeteVeren.caption := TZimmetIadeVeren;
        DemirbasHareketDlg.lblZimmetAlan.caption := TZimmetIadeAlani;
        //DemirbasHareketDlg.TabTutanak.FieldByName('ZIMMETVERENID').AsInteger := ZimmetliPersonel;
        //DemirbasHareketDlg.TabTutanak.FieldByName('DUZENLEYENID').AsInteger := KullananID;
      end;
    1:
      begin // Zimmet tutanağı düzenleniyor
        DemirbasHareketDlg.caption := TYeniZimmetKaydi;
        //if Durum = 6 then
        //  DemirbasHareketDlg.TabTutanak.FieldByName('ZIMMETVERENID').AsInteger := KullananID
        //else
        //  DemirbasHareketDlg.TabTutanak.FieldByName('ZIMMETVERENID').AsInteger := ZimmetliPersonel;
        //DemirbasHareketDlg.TabTutanak.FieldByName('DUZENLEYENID').AsInteger := KullananID;
      end;
    2:begin // kayıp tutanağı düzenleniyor
        caption := TDemirbasKayipKaydi;
      end;
    3:begin // Hurda tutanağı düzenleniyor
        DemirbasHareketDlg.caption := TDemirbasHurdaKaydi;
      end;
    5:
      begin // Transfer Tutanağı düzenleniyor
        DemirbasHareketDlg.caption := TZimmetTransferKaydi;
        //DemirbasHareketDlg.cbZimmetVeren.Enabled := False;
        //DemirbasHareketDlg.TabTutanak.FieldByName('ZIMMETVERENID').AsInteger := ZimmetliPersonel;
        //DemirbasHareketDlg.TabTutanak.FieldByName('DUZENLEYENID').AsInteger := KullananID;
        // tutanaktipi:=1;
      end;
  end;
end;

procedure TDemirbasHareketDlg.FormShow(Sender: TObject);
var ra : string;
    aktifFrame : TGenelAnaSekmeFrame;
    i:Smallint;
begin
  aktifFrame := TGenelAnaSekmeFrame(UTablo.AnaFrameYoneticisi.AktifFrame.Ornek);
  TRaporAraclari.RaporPopupMenuHazirla(EkranAdiAl, PopupMenuYaz, ra, aktifFrame.RaporSecClick);
  YaziciYaz.Caption := ra;
  YaziciYaz.PopupMenu := TGenelAnaSekmeFrame(aktifFrame).pmDokumAyarlar;
  PopupMenuYaz.Images := TGenelAnaSekmeFrame(aktifFrame).ImageList1;

  //KaydetCount:=1;

  TabloYenile(TabTutanak,[TutanakID]);

  case IslemOp of
    'E' : begin
            TabTutanak.Append;
            TabTutanak.Post;
            TutanakID := TabTutanak.FieldByName('ID').AsInteger;
            for i := 0 to DemirbasIDList.Count-1 do
               TutanakDetayEkle(TutanakID, StrToIntDef(DemirbasIDList.Strings[i],0), Tutanak_Tipi);
            TabTutanak.Edit;
           end;
    'D' : begin
            if TabTutanak.FieldByName('LOKASYONID').AsString <> '' then
               BELokasyon.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA', TabTutanak.FieldByName('LOKASYONID').AsString);
          end;
  end;

  DemirbasHareketCaseof;
  TabloYenile(TabTutanakDetay,[TutanakID]);

  if TabTutanak.FieldByName('ZIMMETVERENID').AsString <> '' then begin
      if ZimmetBirime then
         cbZimmetVeren.Text := Tablo.AciklamaGetir('ROLLER', 'ROL', TabTutanak.FieldByName('ZIMMETVERENID').AsString)
      else
         cbZimmetVeren.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTutanak.FieldByName('ZIMMETVERENID').AsString);
  end;
  if TabTutanak.FieldByName('ZIMMETALANID').AsString <> '' then begin
      if ZimmetBirime then
         cbZimmetAlan.Text := Tablo.AciklamaGetir('ROLLER', 'ROL', TabTutanak.FieldByName('ZIMMETALANID').AsString)
      else
         cbZimmetAlan.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTutanak.FieldByName('ZIMMETALANID').AsString);
  end;
  if TabTutanak.FieldByName('DUZENLEYENID').AsString <> '' then
  cbDuzenleyen.Text := Tablo.AciklamaGetir('REHBER','FIRMA', TabTutanak.FieldByName('DUZENLEYENID').AsString);
end;

procedure TDemirbasHareketDlg.YazdirmayaHazirla(AFastReport: TfrxReport);
var
   DokumAdi, Ekranadi : String[30];
begin
   DokumAdi := YaziciYaz.Caption;
   Ekranadi := EkranAdiAl;
   Delete(DokumAdi, pos('&',DokumAdi), 1);
   Tabloyenile(TabTutanakYaz, [TabTutanak.Fields[0].AsInteger]);
   AFastReport.EnabledDataSets.Clear;
   AFastReport.EnabledDataSets.Add(frxTutanakBas);
   AFastReport.EnabledDataSets.Add(frxTutanakDetay);
end;

procedure TDemirbasHareketDlg.BaskiOnizlemeMenuClick(Sender: TObject);
var s:string;
begin
  if TabTutanak.State in [dsEdit, dsInsert] then
     TabTutanak.Post;
  s := YaziciYaz.Caption;
  Delete(s, pos('&', s), 1);
  YazdirmayaHazirla(FastRaporDlg.frxReport1);
  FastRaporDlg.FastRapor(TMenuItem(Sender).Tag, EkranAdiAl, s);
end;

procedure TDemirbasHareketDlg.BELokasyonPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
LokID:Integer;
LokKod,LokAciklama,sqltext:string;
  slist : TStringList;
begin
//  sqltext:='select ROOTKOD=REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))),KOD,ACIKLAMA,TUR,ID from LOKASYON where DURUM=1 and TUR='+IntToStr(Lokasyon_Genel)+' ' ;
//  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,[],['TUR'],[IntToStr(Lokasyon_Genel)],['Kod','Açıklama',''],[True,True,False]) then begin

  Tablo.TablodanSorguAc(1,'select ID from DEPOLAR where VARSAYILAN=3 and SUBEID='+IntToStr(SubeId));
  if Tablo.Query1.RecordCount<1 then
     raise Exception.Create(DDSube_Demirbas_depo_tanimla);
  //sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID from LOKASYON where DURUM=1 and YERI='+IntToStr(TabNo_DEPOLAR)+'  and YERID='+Tablo.Query1.Fields[0].AsString; //and TUR='+IntToStr(Lokasyon_Genel)+' and REHBERID=-1' ;
  sqltext:='select ROOTKOD= case when CHARINDEX(''.'',KOD,1)=0 then '''' else REVERSE( SUBSTRING(REVERSE(KOD),CHARINDEX(''.'',REVERSE(KOD),1)+1,LEN(KOD)-(CHARINDEX(''.'',REVERSE(KOD),1)-1))) end,KOD,ACIKLAMA,TUR,ID,YERI,YERID from LOKASYON where DURUM=1 and YERI='+IntToStr(TabNo_DEMIRBAS)+' and YERID=0'; //and TUR='+IntToStr(Lokasyon_Genel)+' and REHBERID=-1' ;
  if Tablo.KodAgacindanSec(KodAgaciLokasyonDlg,sqltext,True,True,True,True,LokID,LokKod,LokAciklama,slist,[],['TUR','YERI','YERID'],[IntToStr(Lokasyon_Demirbas),TabNo_DEMIRBAS,0],['Kod','Açıklama',''],[True,True,False,False,False]) then begin
    BELokasyon.Text:=LokAciklama;
    BELokasyon.Tag:=LokID;
    if not (dtsTutanak.State in [dsEdit,dsInsert]) then
       TabTutanak.Edit;
    TabTutanak.FieldByName('LOKASYONID').Value:=LokID;
  end;
end;

procedure TDemirbasHareketDlg.btnkapatClick(Sender: TObject);
begin
   ModalResult:=mrCancel;
end;

procedure TDemirbasHareketDlg.btnKaydetClick(Sender: TObject);
var
   LokId, islemTipi:integer;
begin
  if TabTutanak.State in [dsEdit,dsInsert] then
     TabTutanak.Post;

     TabTutanakDetay.First;
     while not TabTutanakDetay.Eof do
       begin

         if TabTutanak.FieldByName('LOKASYONID').AsString='0' then //çok demirbaş seçilmişse ve burada yeni lokasyon bilgisi girilmemşse
             LokId := TabTutanakDetay.FieldByName('LOKASYONID').AsInteger
         else
             LokId := TabTutanak.FieldByName('LOKASYONID').AsInteger;

         if TabTutanakDetay.FieldByName('DURUM').AsInteger <> 6 then  begin
             if cbDurum.EditingValue=5 then
               islemTipi:=1
             else
               islemTipi:=cbDurum.EditingValue;
           end ELSE begin
             islemTipi:=6;
         end;

         DemirbasBilgiGuncelle(TabTutanakDetay.FieldByName('DEMIRBASID').AsInteger,
         islemTipi,
         TabTutanak.FieldByName('ZIMMETALANID').AsInteger,
         LokId,
         TabTutanak.FieldByName('TARIH').AsDateTime);
         TabTutanakDetay.Next;
       end;
 end;

procedure TDemirbasHareketDlg.btnSil1Click(Sender: TObject);
begin
    TabTutanak.cancel;
end;

procedure TDemirbasHareketDlg.btnSilClick(Sender: TObject);

procedure TutanakDetaySil ;
begin
  DemirbasBilgiGuncelle(TabTutanakDetay.FieldByName('DEMIRBASID').AsInteger,
                             0, // yeni demirbaş olarak
                             0,
                             0,
                             Null
                            );
  Tablo.Query6.Close;
  Tablo.Query6.SQL.Text:= 'DELETE FROM DEMIRBAS_TUTANAK_DETAY WHERE ID = '+TabTutanakDetay.FieldByName('ID').AsString+' ';
  Tablo.Query6.ExecSQL;

end;
begin
  if dtsTutanak.State in [dsEdit, dsInsert] then
    begin
      Application.MessageBox(PChar(DDUst_bilgiyi_kaydet),PChar(Uyari), MB_OK+ MB_ICONWARNING);
      Abort;
    end;
  if TabTutanakDetay.RecordCount<=0 then Abort;

  if Application.MessageBox(PChar(DDKayit_demirbastan_cikarilacak_onay),PChar(Onay), MB_YESNO+ MB_ICONQUESTION)= ID_NO then abort;
  TutanakDetaySil;
  TabloYenile(TabTutanakDetay,[TabTutanak.FieldByName('ID').AsInteger]);
end;

procedure TDemirbasHareketDlg.cbDuzenleyenPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var ID : Integer;
  begin
  ID := Tablo.RehberAra_IDGetir(335);
  if ID > 0 then begin
      TabTutanak.Edit;
      TabTutanak.FieldByName('DUZENLEYENID').AsInteger:= ID;
      cbDuzenleyen.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
   end;
end;

procedure TDemirbasHareketDlg.cbZimmetAlanPropertiesButtonClick(Sender: TObject;AButtonIndex: Integer);
var ID : Integer;
begin
  if ZimmetBirime then
     ID := Tablo.RolAra_IDGetir
  else
     ID := Tablo.RehberAra_IDGetir(335);

  if ID <> -99 then begin
      TabTutanak.Edit;
      TabTutanak.FieldByName('ZIMMETALANID').AsInteger:= ID;
      if ZimmetBirime then
         cbZimmetAlan.Text := Tablo.AciklamaGetir('ROLLER', 'ROL', ID)
      else
         cbZimmetAlan.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
   end;
end;


procedure TDemirbasHareketDlg.cbZimmetVerenPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var ID : Integer;
  begin
  {
  if tutanaktipi=1 then  begin
  if Application.MessageBox('Transfer yapmak istiyor musunuz ?','UYARI' , MB_YESNO) = IDYES then  begin
    cbTip.EditValue:=5;
  //  tutanaktipi:=5;
    TabTutanak.FieldByName('TIP').AsInteger:=5;
  end  else Abort;
  end;
      }
  if ZimmetBirime then
     ID := Tablo.RolAra_IDGetir
  else
     ID := Tablo.RehberAra_IDGetir(335);
  if ID <> -99 then begin
 {
  tablo.Query1.Close;
  Tablo.Query1.SQL.Text:='Select * from DEMIRBAS Where ZIMMETLIPERSONELID=:A0';
  tablo.Query1.Params[0].Value:=ID;
  Tablo.Query1.Open;   }
 // if Tablo.Query1.RecordCount<>0 then
  //  begin
      TabTutanak.Edit;
      TabTutanak.FieldByName('ZIMMETVERENID').AsInteger:= ID;
      if ZimmetBirime then
         cbZimmetVeren.Text := Tablo.AciklamaGetir('ROLLER', 'ROL', ID)
      else
         cbZimmetVeren.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', ID);
   // end else
    //Application.MessageBox('Bu Personele zimmetli Demirbaş bulunmuyor','UYARI',0);
   end;

end;

procedure TDemirbasHareketDlg.DemirbasBilgiGuncelle (demirbasid, durum, zimmetpersonel, lokasyon:Integer;zimmettarihi: TDateTime);
begin
//
 Tablo.Query4.Close;
 Tablo.Query4.SQL.Text:= 'UPDATE DEMIRBAS SET DURUM = '+inttostr(durum);
 if not (Tutanak_Tipi in [2,3]) then //hurda veya kayıpsa alttaki bilgiler değişmez
    Tablo.Query4.SQL.Add(', ZIMMETLIPERSONELID = '+ IntToStr(zimmetpersonel)+' ,' +
                         ' LOKASYONID = '+inttostr(lokasyon)+' , '+
                         ' ZIMMETTARIHI = '''+formatdatetime('yyyy-mm-dd hh:nn',zimmettarihi)+'''');
 Tablo.Query4.SQL.Add(', DEGISTIREN = '''+Kullanan+''' , '+
                         ' DEGISTIRMETARIHI = GETDATE() '+
                         ' WHERE ID = '+inttostr(demirbasid));
 Tablo.Query4.ExecSQL;
 cbDurum.EditValue := Durum;
end;

procedure TDemirbasHareketDlg.dtsTutanakStateChange(Sender: TObject);
begin
   btnKaydet.Visible := dtsTutanak.State in [dsEdit,dsInsert];
   btnSil1.Visible   := (IslemOp='D')and(dtsTutanak.State in [dsEdit,dsInsert]);
end;

procedure TDemirbasHareketDlg.TabTutanakBeforePost(DataSet: TDataSet);
begin
   if Active then begin  //ekran açıksa
      if (cbZimmetVeren.Visible)and(not BoslukKontrol(cbZimmetVeren.text, 'Zimmet Veren')) then Abort;
      if (cbZimmetAlan.Visible)and(not BoslukKontrol(cbZimmetAlan.text, 'Zimmet Alan')) then Abort;
   end;
end;

procedure TDemirbasHareketDlg.TabTutanakNewRecord(DataSet: TDataSet);
begin
  TabTutanak.FieldByName('BELGENO').AsString :=FormNoGetirFunc;
  TabTutanak.FieldByName('EKLEYEN').AsString:= Kullanan;
  TabTutanak.FieldByName('TIP').AsInteger:= tutanaktipi;
  TabTutanak.FieldByName('TARIH').AsDateTime:= Tablo.GENINI.BugunTrhSaat;

  TabTutanak.FieldByName('LOKASYONID').AsInteger := ZimmetId;
  BELokasyon.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA', TabTutanak.FieldByName('LOKASYONID').AsString);

  TabTutanak.FieldByName('LOKASYONID').AsInteger := LokasyonId;
  BELokasyon.Text := Tablo.AciklamaGetir('LOKASYON','ACIKLAMA', TabTutanak.FieldByName('LOKASYONID').AsString);

  TabTutanak.FieldByName('DUZENLEYENID').AsString:= Kullanan;
  cbDuzenleyen.Text := Tablo.AciklamaGetir('REHBER', 'FIRMA', Kullanan);
  TabTutanak.FieldByName('SUBEID').AsInteger := SubeID;
end;

end.





