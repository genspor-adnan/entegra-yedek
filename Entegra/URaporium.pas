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
  var
    GonderilecekString ,GelenCevap : String;
    DonenDeger:TStringlist;
    ResponseStream: TMemoryStream;
    InputStringList : TStringList;
    IdHttp1 : TIDHTTP;
    XMLString : string;
    xmlstream : TStringStream;

begin
    IdHttp1 :=   TIDHTTP.Create(nil);
    //IdHttp1.ProxyParams.ProxyPort := 8888;
    //IdHttp1.ProxyParams.ProxyServer:='localhost';
    IdHttp1.HTTPOptions := [];
    if ProxyAdres<>'' then begin
       IdHTTP1.ProxyParams.ProxyServer:=ProxyAdres;
       IdHTTP1.ProxyParams.ProxyPort:=StrToIntDef(ProxyPort,0);
    end;

    DonenDeger :=   TStringList.Create();
    ResponseStream := TMemoryStream.Create;
    InputStringList := TStringList.Create;



    XMLString :=
     // '<?xml version=“1.0” encoding=“utf-8” ?>                  '+
      '  <Raporium>                                          '+
      '    <versiyon>'+Versiyon+'</versiyon>      '+
      '    <dokumid>'+IntToStr(dokumid)+'</dokumid>             '+
      '    <islemNo>'+IntToStr(islemNo)+'</islemNo>             '+
      '    <Sektor>'+IntToStr(Sektor)+'</Sektor>             '+
      '  </Raporium>    ';


    InputStringList.Add(XMLString);
      try
       IdHttp1.Request.Accept := '*/*';
       //IdHttp1.Request.ContentType := 'text/xml; charset=utf-8';
       IdHttp1.Request.ContentType := 'text/xml';
        //IdHTTP1.Post('http://'+GenYazilimIPAdress+':8090/Gentegre/GetReport.asmx/DokumanSorgula', InputStringList, ResponseStream);
        //IdHTTP1.Post('http://genlisans.genyazilim.com/Gentegredokum/GetReport.asmx/DokumanSorgula', InputStringList, ResponseStream);

        //Result:=MemoryStreamToString(ResponseStream);
        //GelenCevap:= IdHttp1.ResponseText;
        //IdHTTP1.Post('http://genlisans.genyazilim.com/GentegreDokuman/GetReport.asmx/DokumanSorgula', InputStringList, ResponseStream);
        GonderilecekString := 'http://'+Tablo.GENINI.ReadString(Ops_GenelOpsiyon_GenYazilimIPAdress,'genupdate.genyazilim.com')+'/Dokuman/GetReport.asmx/DokumanSorgula';
        IdHTTP1.Post(GonderilecekString, InputStringList, ResponseStream);

        //XMLString:=MemoryStreamToString(ResponseStream);
        //xmlstream:= TStringStream.Create(XMLString,TEncoding.UTF8);
        if (Assigned(FXml)) then
        FreeAndNil(FXml);
        FXml:= TECXMLParser.Create(nil);
        ResponseStream.Position :=0;
        FXml.LoadFromStream(ResponseStream,TEncoding.UTF8);
        GelenCevap:= IdHttp1.ResponseText;
      except
            on E: Exception do
            GelenCevap:=  E.Message;
      end;
      ResponseStream.Free;
      InputStringList.Free;
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
    procedure Sil(ID:String);
    begin
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM KOSULLAR WHERE DOKUMID = &DID', ['&DID'],[ID]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM AYARLARYENI WHERE DOKUMID = &DID', ['&DID'],[ID]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'DELETE FROM DOKUMLER WHERE ID = &DID', ['&DID'],[ID]);
    end;
begin        //http://genlisans.genyazilim.com:8090/Gentegrelisans/GentegreLisans.asmx/LisansCevirUpdate
  //DokumanSorgula('1.1', StrToDateTime('01/01/2013'), 379, 4)
  //Önce bu verssiyondan düşük rapor listesini alalım
  DokumanSorgula(XmlListe,IntToStr(KomutNo),0,2);

  //UPDATE:M.Y.
  if Not Assigned(XmlListe) then
   Exit;

  cxProgressBar1.Properties.Max := XmlListe.root.count;
  say:=0;
  for a in XmlListe.Root do begin
    ad := A.Text;
    i:=pos(',',Ad);
    RaporNo:=copy(Ad,1,i-1);
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
       DokumanSorgula(XmlRapor,'0',StrToInt(RaporNo),1);
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
      ' select MODULID=convert(int,(convert(nvarchar(4),M.MODULID)+convert(nvarchar(10),D.ID))),-1,1,1'+
      ' from MODUL M inner join DOKUMLER D on M.DOKUMTUR=D.MODUL'+
      ' where LEN(M.MODULID)=4 and M.MODULID like ''__99'' '+
      ' and convert(int,(convert(nvarchar(4),M.MODULID)+convert(nvarchar(10),D.ID))) not in (select MODULID from YETKI where ROLID=-1 and MODULID like ''__99%'') ', [],[]);
   close;
end;

end.



