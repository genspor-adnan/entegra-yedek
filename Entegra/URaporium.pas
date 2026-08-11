unit URaporium;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxImageComboBox, Menus, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxControls, cxGridCustomView, cxGrid, ExtCtrls, cxLookAndFeelPainters,
  StdCtrls, cxButtons, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, cxContainer, cxLabel,RaporiumWS,Utablo,XSBuiltIns, cxMemo, cxCheckBox, ComCtrls, cxLookAndFeels, dxCore, cxDateUtils, cxNavigator,
  cxProgressBar,  IdComponent, IdTCPConnection, IdTCPClient, ECXMLParser, UFastRap, FetaKurulusSiniflari,
  IdHTTP, fetautil, dxSkinLiquidSky, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations;

type
  TRaporiumDlg = class(TForm)
    Splitter1: TSplitter;
    Panel1: TPanel;
    RaporiumGrid: TcxGrid;
    RaporiumGridLevel3: TcxGridLevel;
    Panel2: TPanel;
    RaporiumGridTableView: TcxGridTableView;
    RaporiumGridTvSec: TcxGridColumn;
    RaporiumGridTvTarih: TcxGridColumn;
    RaporiumGridTvModul: TcxGridColumn;
    RaporiumGridTvRaporAdi: TcxGridColumn;
    RaporiumGridTvDurum: TcxGridColumn;
    RaporiumGridTvGrubu: TcxGridColumn;
    RaporiumGridTvID: TcxGridColumn;
    RaporiumGridTvSqlVersiyon: TcxGridColumn;
    RaporiumGridTvEkranVersiyon: TcxGridColumn;
    cxProgressBar1: TcxProgressBar;
    TamamTus: TcxButton;
    procedure FormCreate(Sender: TObject);
    procedure RaporiumGridTableViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
    procedure TamamTusClick(Sender: TObject);
  private
    { Private declarations }
    // Sunucudan XML ceker. Doner: '' = BASARILI; aksi halde kullaniciya
    //   gosterilecek HATA metni (HTTP kodu / baglanti hatasi).
    function DokumanSorgula(var FXml : TECXMLParser; versiyon:string; dokumid, islemNo:smallint):string;
    procedure RaporUpdate;
    procedure ListeyeEkle(RaporNo,EkleDegis:String);
  public
    { Public declarations }
  end;

var
  RaporiumDlg: TRaporiumDlg;

implementation
uses
UAnaForm,FetaClassExtensions,UVersiyonGuncelle,PrjConst,LocOnFly;

{$R *.dfm}
var
  XmlListe, XmlRapor : TECXMLParser;
  a : TXMLItem;
  //s : string;
  Ad,RaporID,RaporNo,Vers,PrgVers:String;

procedure TRaporiumDlg.ListeyeEkle(RaporNo,EkleDegis:String);
var recId:integer;
begin
  //  while RaporiumGridTableView.DataController.RecordCount>0 do               //  grid temizleniyor
  //  RaporiumGridTableView.DataController.DeleteRecord(0);
      Tablo.TablodanSorguAc(8,'select RAPORADI, GRUBU, MODUL, DEGISTIRMETARIHI from DOKUMLER where RAPORNO='+RaporNo);

      RaporiumGridTableView.DataController.BeginFullUpdate;

      recId := RaporiumGridTableView.DataController.AppendRecord;
      with RaporiumGridTableView.DataController do  begin
        //SetValue(recid, RaporiumGridTvSec.Index, False );
        SetValue(recId, RaporiumGridTvRaporAdi.Index,Tablo.Query8.FieldByName('RAPORADI').AsString);
        SetValue(recId, RaporiumGridTvTarih.Index, Tablo.Query8.FieldByName('DEGISTIRMETARIHI').AsDateTime);
        //SetValue(recId, RaporiumGridTvID.Index,Gresult[gezici].ID);
        SetValue(recId, RaporiumGridTvModul.Index, Tablo.Query8.FieldByName('MODUL').AsString);
        SetValue(recId, RaporiumGridTvDurum.Index, EkleDegis);
        SetValue(recId, RaporiumGridTvGrubu.Index, Tablo.Query8.FieldByName('GRUBU').AsString);
        //SetValue(recId, RaporiumGridTvSqlVersiyon.Index,'');
        //SetValue(recId, RaporiumGridTvEkranVersiyon.Index,'');
        Post;
      end;
    RaporiumGridTableView.DataController.EndFullUpdate;
    RaporiumGridTableView.ApplyBestFit(nil);
end;


procedure TRaporiumDlg.FormActivate(Sender: TObject);
begin
   RaporUpdate
end;

procedure TRaporiumDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  //RaporiumGridTableView.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\RaporiumGridi',true,false,[gsoUseFilter],'RaporiumGridi');
  Tablo.GridTurkcelestir;
end;

procedure TRaporiumDlg.RaporiumGridTableViewCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=RaporiumGrid;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=RaporiumGridTableView;
  AnaForm.pmGridStil.Tags.Values[RaporiumGrid.Name] := 'RaporiumGridi';

end;

function TRaporiumDlg.DokumanSorgula(var FXml : TECXMLParser; versiyon:string; dokumid, islemNo:smallint):string;
// Rapor sunucusundan (GenYazilim) XML ceker.
//   Doner: '' = basarili, aksi halde HATA metni.
// ONCEKI DAVRANIS (hata kaynagi): exception YUTULUYORDU, Result hic atanmiyordu ve
//   HTTP durum kodu kontrol edilmiyordu. Sunucu 503/404 verince ya da baglanti
//   kopunca ekran SESSIZCE kapaniyor, kullanici "guncelleme yok" saniyordu.
//   Ayrica hata halinde FXml ONCEKI cagrinin icerigiyle KALIYOR (FreeAndNil basarili
//   dalda) -> ayni liste tekrar islenebiliyordu. IdHTTP ve TStringList de sizdiriliyordu.
var
  GonderilecekString : String;
  ResponseStream: TMemoryStream;
  InputStringList : TStringList;
  IdHttp1 : TIDHTTP;
  XMLString : string;
begin
  Result := '';
  IdHttp1 := TIDHTTP.Create(nil);
  ResponseStream := TMemoryStream.Create;
  InputStringList := TStringList.Create;
  try
    IdHttp1.HTTPOptions := [];
    IdHttp1.ConnectTimeout := 15000;
    IdHttp1.ReadTimeout    := 30000;
    if ProxyAdres <> '' then begin
       IdHTTP1.ProxyParams.ProxyServer := ProxyAdres;
       IdHTTP1.ProxyParams.ProxyPort   := StrToIntDef(ProxyPort, 0);
    end;

    XMLString :=
      '  <Raporium>                                          '+
      '    <versiyon>'+Versiyon+'</versiyon>      '+
      '    <dokumid>'+IntToStr(dokumid)+'</dokumid>             '+
      '    <islemNo>'+IntToStr(islemNo)+'</islemNo>             '+
      '    <Sektor>'+IntToStr(Sektor)+'</Sektor>             '+
      '  </Raporium>    ';
    InputStringList.Add(XMLString);

    // Onceki icerik her durumda birakilir: hata halinde ESKI liste ile devam
    //   edilmesin (bkz. yukaridaki not).
    if Assigned(FXml) then
      FreeAndNil(FXml);

    GonderilecekString := 'http://' +
      Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress, 'genupdate.genyazilim.com') +
      '/Dokuman/GetReport.asmx/DokumanSorgula';
    try
      IdHttp1.Request.Accept := '*/*';
      IdHttp1.Request.ContentType := 'text/xml';
      IdHTTP1.Post(GonderilecekString, InputStringList, ResponseStream);

      if IdHttp1.ResponseCode <> 200 then
      begin
        Result := 'Rapor sunucusu yanıt vermedi (HTTP ' + IntToStr(IdHttp1.ResponseCode) + ').';
        Exit;
      end;
      if ResponseStream.Size = 0 then
      begin
        Result := 'Rapor sunucusundan boş yanıt geldi.';
        Exit;
      end;

      FXml := TECXMLParser.Create(nil);
      ResponseStream.Position := 0;
      try
        FXml.LoadFromStream(ResponseStream, TEncoding.UTF8);
      except
        // 503/404 sayfalari HTML doner - XML olarak cozulemez.
        FreeAndNil(FXml);
        Result := 'Rapor sunucusundan geçersiz yanıt geldi (XML değil).';
        Exit;
      end;
    except
      on E: Exception do
      begin
        if Assigned(FXml) then FreeAndNil(FXml);
        Result := 'Rapor sunucusuna ulaşılamadı: ' + E.Message;
      end;
    end;
  finally
    InputStringList.Free;
    ResponseStream.Free;
    IdHttp1.Free;
  end;
end;

procedure TRaporiumDlg.Panel1DblClick(Sender: TObject);
var i,say:smallint;
begin
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,' delete from AYARLARYENI WHERE EXISTS (SELECT ID FROM DOKUMLER D '+
     ' WHERE D.ID=AYARLARYENI.DOKUMID AND isnull(MODUL,'''')<>'''' and MODUL<>''-'' AND STANDART=1)',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from KOSULLAR WHERE EXISTS (SELECT ID FROM DOKUMLER D'+
     ' WHERE D.ID=KOSULLAR.DOKUMID AND isnull(MODUL,'''')<>'''' and MODUL<>''-'' AND STANDART=1)',[],[]);
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from DOKUMLER WHERE isnull(MODUL,'''')<>'''' and MODUL<>''-'' AND STANDART=1 ',[],[]);
  {DokumanSorgula(XmlListe,IntToStr(KomutNo),0,2);
  cxProgressBar1.Properties.Max := XmlListe.root.count;
  say:=0;
  for a in XmlListe.Root do begin
    ad := A.Text;
    i:=pos(',',Ad);
    RaporNo:=copy(Ad,1,i-1);
    Vers := copy(Ad,i+1, revpos(',',Ad)-i-1);
    PrgVers := copy(Ad, revpos(',',Ad)+1, 10);
    DokumanSorgula(XmlRapor,'0',StrToInt(RaporNo),1);
    //XmlRapor.SaveToFile('D:\Raporium\'+RaporNo+'.frd');
    inc(say);
    cxProgressBar1.Position := say;
    cxProgressBar1.Update;
  end;}
end;

procedure TRaporiumDlg.RaporUpdate;
var i,say:smallint;
    EkleDegis:string;
    LHata:string;
    procedure Sil(ID:String);
    begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM KOSULLAR WHERE DOKUMID = &DID', ['&DID'],[ID]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM AYARLARYENI WHERE DOKUMID = &DID', ['&DID'],[ID]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM DOKUMLER WHERE ID = &DID', ['&DID'],[ID]);
    end;
begin
  //Once bu versiyondan dusuk rapor listesini alalim
  LHata := DokumanSorgula(XmlListe, IntToStr(KomutNo), 0, 2);
  if LHata <> '' then
  begin
    // Sessiz kapanma YOK: sunucu kapali/erisilemez oldugunda kullanici bunu
    //   "guncelleme yok" saniyordu (hatanin asil belirtisi buydu).
    Tablo.UyariGoster(Uyari, LHata);
    Close;
    Exit;
  end;
  if not Assigned(XmlListe) then
  begin
    Close;
    Exit;
  end;

  cxProgressBar1.Properties.Max := XmlListe.root.count;
  say:=0;
  for a in XmlListe.Root do begin
    ad := A.Text;
    i:=pos(',',Ad);
    if i <= 1 then Continue;        // beklenen bicim: RAPORNO,VERSIYON,PRGVERSIYON
    RaporNo:=copy(Ad,1,i-1);
    if StrToIntDef(RaporNo, 0) <= 0 then Continue;
    RaporId:='0';
    Vers := copy(Ad,i+1, revpos(',',Ad)-i-1);
    PrgVers := copy(Ad, revpos(',',Ad)+1, 10);
    EkleDegis := '';
    Tablo.TablodanSorguAc(7,'select ID, VERSIYON,MODUL from DOKUMLER where RAPORNO='+RaporNo+' and STANDART=1 ');//bu döküm varmı
    if (Tablo.Query7.RecordCount>0) then begin
       RaporID := Tablo.Query7.Fields[0].AsString;
       if PrgVers='-1' then begin //silinmiş
          Sil(RaporID);
          EkleDegis := 'Silindi';
       end else if (Tablo.Query7.Fields[1].AsString<>Vers) then  //vers aynı ise hiç dokunmadan devam edelim
       begin
          Sil(RaporID);
          EkleDegis := 'Değişti';
       end;
  end
    else if PrgVers <> '-1' then //daha önce silinmiş olan ve serverda silindi görünen tekrar eklenmesin
          EkleDegis := 'Eklendi';

    if (EkleDegis = 'Eklendi')or(EkleDegis = 'Değişti') then begin
       LHata := DokumanSorgula(XmlRapor,'0',StrToIntDef(RaporNo,0),1);
       if (LHata <> '') or (not Assigned(XmlRapor)) then
       begin
         // Tek rapor cekilemedi: tum guncellemeyi iptal etme, bu raporu ATLA.
         inc(say);
         cxProgressBar1.Position := say;
         Continue;
       end;
       //XmlRapor.SaveToFile('D:\GenDokuman\deneme'+ID+'.frd');
       XML2Rapor(XmlRapor,StrToIntDef(RaporId,0));
       ListeyeEkle(RaporNo,EkleDegis);
    end
    else if (EkleDegis = 'Silindi')then begin
      // ListeyeEkle(ID,EkleDegis);
    end;
    inc(say);
    cxProgressBar1.Position := say;
    cxProgressBar1.Update;
  end;
  if RaporiumGridTableView.DataController.RecordCount>0 then
     TamamTus.Visible := True
  else
     Close;
end;

procedure TRaporiumDlg.TamamTusClick(Sender: TObject);
begin
   //Şimdi yeni eklenen raporlar için yetki verelim
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into YETKI(MODULID,ROLID,TUR,HAK)'+
      ' select MODULID=cast((cast(M.MODULID as varchar(4))+cast(D.ID as varchar(10))) as int),-1,1,1'+
      ' from MODUL M inner join DOKUMLER D on M.DOKUMTUR=D.MODUL'+
      ' where LEN(M.MODULID)=4 and M.MODULID like ''__99'' '+
      ' and cast((cast(M.MODULID as varchar(4))+cast(D.ID as varchar(10))) as int) not in (select MODULID from YETKI where ROLID=-1 and MODULID like ''__99%'') ', [],[]);
   close;
end;

end.



