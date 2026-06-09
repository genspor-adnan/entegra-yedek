unit UDoviz;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, DBGrids, Grids, ExtCtrls, Buttons, //DBTables,
  ComCtrls, FireDAC.Comp.Client, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, Dialogs, cxStyles, dxSkinsCore, dxSkinscxPCPainter, cxCustomData,
  cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, cxDBData, ToolWin,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxControls,
  cxGridCustomView, cxClasses, cxGridLevel, cxGrid, cxContainer, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, Menus, dxSkinLondonLiquidSky, cxLabel,
  xmldom, XMLIntf, msxmldom, XMLDoc, WINInet, cxLookAndFeels,
  cxLookAndFeelPainters, cxNavigator, dxCore, cxDateUtils, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxDateRanges, dxScrollbarAnnotations,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;
                        //  555   238 46 78
type
  TDovizDlg = class(TForm)
    Panel2: TPanel;
    DtsDoviz: TDataSource;
    TabDoviz: TFDQuery;
    IdHTTP1: TIdHTTP;
    DBGrid1: TcxGrid;
    DBGrid1Level1: TcxGridLevel;
    DBGrid1DBTableView1: TcxGridDBTableView;
    DBGrid1DBTableView1TARIH1: TcxGridDBColumn;
    DBGrid1DBTableView1CINSI1: TcxGridDBColumn;
    DBGrid1DBTableView1ALIS1: TcxGridDBColumn;
    DBGrid1DBTableView1SATIS1: TcxGridDBColumn;
    DBGrid1DBTableView1EFALIS1: TcxGridDBColumn;
    DBGrid1DBTableView1EFSATIS1: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    Panel1: TPanel;
    Label2: TcxLabel;
    ToolBar2: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    ToolButton2: TToolButton;
    btnKapat: TToolButton;
    DateDovizTarihi: TcxDateEdit;
    PopupMenu1: TPopupMenu;
    KurGetirMenu: TMenuItem;
    N1: TMenuItem;
    MBGuncelleMenu: TMenuItem;
    Label1: TcxLabel;
    ComboKur: TcxComboBox;
    XMLDocument1: TXMLDocument;
    ADOQuery1: TFDQuery;
    ADOQuery2: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure DtSDovizStateChange(Sender: TObject);
    procedure TabDovizNewRecord(DataSet: TDataSet);
    procedure TabDovizBeforeEdit(DataSet: TDataSet);
    procedure TabDovizAfterPost(DataSet: TDataSet);
    procedure DBNavigator1BeforeAction(Sender: TObject;
      Button: TNavigateBtn);
    procedure btnKapatClick(Sender: TObject);
    procedure KurGetirMenuClick(Sender: TObject);
    procedure MBGuncelleMenuClick(Sender: TObject);
    procedure ComboKurPropertiesChange(Sender: TObject);
    procedure TabDovizBeforePost(DataSet: TDataSet);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure ChangeCalistir;
    function GetInetFile (const fileURL, FileName: String): boolean;
    procedure XMLDovizGuncelle;
    procedure DateDovizTarihiPropertiesChange(Sender: TObject);
    procedure DateDovizTarihiPropertiesCloseUp(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

 type
  PRSSFeedData = ^TRSSFeedData;
  TRSSFeedData = record
    Isim : string;
    alis : string;
    satis : string;
    efalis : string;
    efsatis : string;
    units : string;
  end;

var
  DovizDlg: TDovizDlg;

implementation

uses UTablo, UCombo, PrjConst, LocOnFly, FetaKurulusSiniflari;

{$R *.DFM}
var
   YeniKayit : Boolean;
   str:string;

procedure TDovizDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil y�kleniyor.
  //ADOQuery2.Close;
  //ADOQuery2.Open;
  DateDovizTarihi.Date := Tablo.GENINI.BugunTrh;
 Tablo.GENINI.ReadSection(Ops_KURLAR, ComboKur.Properties, True);
 ComboKurPropertiesChange(Self);

 Tablo.GridTurkcelestir;


end;

function TDovizDlg.GetInetFile (const fileURL, FileName: String): boolean;
const
  BufferSize = 1024;
var
  hSession, hURL: HInternet;
  Buffer: array[1..BufferSize] of Byte;
  BufferLen: DWORD;
  f: File;
  sAppName : string;
  wideChars   : array[0..51] of WideChar;
begin
 result := false;
 sAppName := ExtractFileName(Application.ExeName) ;

  if ProxyAdres<>'' then begin
      StringToWideChar(ProxyAdres+':'+ProxyPort, wideChars, 52);
      hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, wideChars, nil, 0)
  end else
     hSession := InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0) ;

 try
  hURL := InternetOpenURL(hSession, PChar(fileURL), nil, 0, 0, 0) ;
  try
   AssignFile(f, FileName) ;
   Rewrite(f,1) ;
   repeat

      InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) ;
    try
      BlockWrite(f, Buffer, BufferLen)
    except

    end;
   until BufferLen = 0;
   CloseFile(f) ;
   result := True;
  finally
   InternetCloseHandle(hURL)
  end
 finally
  InternetCloseHandle(hSession)
 end
end;

procedure TDovizDlg.IptalTusClick(Sender: TObject);
begin
  TabDoviz.Cancel;
end;

procedure TDovizDlg.KaydetTusClick(Sender: TObject);
begin
  TabDoviz.Post;
end;

procedure TDovizDlg.KurGetirMenuClick(Sender: TObject);
var i : smallint;
begin
{   for i := 0 to ComboKur.Properties.Items.Count - 1 do
      if (ComboKur.Properties.Items[i] <> '') then begin         //  and (ComboKur.Properties.Items[i] <>'TL')
         Tablo.Query5.Close;
         Tablo.Query5.SQL.Text := ' SELECT  isnull(ALIS,0),isnull(SATIS,0),isnull(EFALIS,0),isnull(EFSATIS,0) FROM DOVIZ D1'+
                                  ' WHERE TARIH=(SELECT MAX(TARIH) FROM DOVIZ D2 WHERE D1.CINSI=D2.CINSI )'+
                                  ' AND CINSI='''+ComboKur.Properties.Items[i]+'''';
         Tablo.Query5.Open;

         TabDoviz.Append;
         TabDoviz.Fields[0].AsString := ComboKur.Properties.Items[i];
         if ComboKur.Properties.Items[i]='TL' then begin
           TabDoviz.Fields[2].AsCurrency:= 1;
           TabDoviz.Fields[3].AsCurrency:= 1;
           TabDoviz.Fields[4].AsCurrency:= 1;
           TabDoviz.Fields[5].AsCurrency:= 1;
         end else begin
           TabDoviz.Fields[2].AsCurrency:= Tablo.Query5.Fields[0].AsCurrency;
           TabDoviz.Fields[3].AsCurrency:= Tablo.Query5.Fields[1].AsCurrency;
           TabDoviz.Fields[4].AsCurrency:= Tablo.Query5.Fields[2].AsCurrency;
           TabDoviz.Fields[5].AsCurrency:= Tablo.Query5.Fields[3].AsCurrency;
         end;

         TabDoviz.Post;
      end;
    TabDoviz.Close;
    TabDoviz.Open;      }
  if GetInetFile('http://www.tcmb.gov.tr/kurlar/today.xml', ExtractFileDir( Application.ExeName)+'\doviz.xml') then  begin
    XMLDovizGuncelle;
    DateDovizTarihi.Date := Tablo.GENINI.BugunTrh;
  end;
end;
procedure TDovizDlg.XMLDovizGuncelle;
var
  nd : IXMLNode;
 SQLResult :string;
  procedure ProcessItem();
  var
    rssFeedData : PRSSFeedData;
    rssid : integer;
    kur : string;
  begin
    New(rssFeedData);

   str := nd.ChildNodes.FindNode('Isim').Text;
//   if  (ADOQuery2.Locate ('AKTARIMADI', str,[loPartialKey])) then begin
   ADOQuery2.close;
   ADOQuery2.sql.Text:='select  * from DOVIZCINSLERI  where DIL=-1 and AKTARIMADI='''+str+''' ';
   ADOQuery2.open;
   if ADOQuery2.RecordCount > 0 then begin
        kur:= ADOQuery2.FieldByName('DOVIZ').AsString;
        with nd.ChildNodes do
        begin
          rssFeedData.Isim:= FindNode('Isim').Text;
          rssFeedData.alis := FindNode('ForexBuying').Text;
          rssFeedData.satis := FindNode('ForexSelling').Text;
          rssFeedData.efalis := FindNode('BanknoteBuying').Text;
          rssFeedData.efsatis := FindNode('BanknoteSelling').Text;
          rssFeedData.units := FindNode('Unit').Text;
        end;

        ADOQuery1.Close;
        ADOQuery1.SQL.Text:= 'INSERT INTO DOVIZ (TARIH, CINSI, ALIS, SATIS, EFALIS, EFSATIS) '+
                             ' VALUES ('''
                             +FormatdateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)+''', '''
                             +kur+''','
                             +rssFeedData.alis+'/'+rssFeedData.units+', '
                             +rssFeedData.satis+'/'+rssFeedData.units+', '
                             +rssFeedData.efalis+'/'+rssFeedData.units+', '
                             +rssFeedData.efsatis+'/'+rssFeedData.units+' )';
        ADOQuery1.ExecSQL;
   end;


  end;
begin
  SQLResult := 'delete from DOVIZ where TARIH='''+FormatdateTime('yyyy-mm-dd', Tablo.GENINI.BugunTrh)+''' and CINSI IN (select ANAHTAR from GENINI (nolock) WHERE DIL='+IntToStr(Dil)+'AND BOLUM='+IntToStr(Ops_DovizEslestir)+') ';    //  DovizEslestir
  tablo.FDCnn.ExecSQL(SQLResult);

   //Okunacak dosya yolu
  XMLDocument1.FileName := ExtractFileDir( Application.ExeName)+'\doviz.xml';
  XMLDocument1.Active := true;

  nd := XMLDocument1.DocumentElement;
  nd := nd.ChildNodes.First;

  while nd <> nil do
  begin
    ProcessItem();
    nd  := nd.NextSibling;
  end;
  XMLDocument1.Active := false;

end;

procedure TDovizDlg.MBGuncelleMenuClick(Sender: TObject);
begin

//  Tablo.DovizGuncelle(True);

     if GetInetFile('http://www.tcmb.gov.tr/kurlar/today.xml', ExtractFileDir( Application.ExeName)+'\doviz.xml') then
      begin
         XMLDovizGuncelle;
      end;
  DateDovizTarihi.Date := Tablo.GENINI.BugunTrh;
  ComboKurPropertiesChange(nil);
end;

procedure TDovizDlg.SilTusClick(Sender: TObject);
begin
  if TabDoviz.RecordCount<=0 then abort;
  
  if Application.MessageBox(PChar(KKayit_silinsinmi),PChar(Onay),MB_YESNO+ MB_ICONQUESTION) = ID_NO then Abort;
  TabDoviz.Delete;
end;

procedure TDovizDlg.DtSDovizStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtSDoviz, EkleTus,SilTus,KaydetTus,IptalTus)
end;


procedure TDovizDlg.EkleTusClick(Sender: TObject);
begin
  TabDoviz.Append;
end;

procedure TDovizDlg.TabDovizNewRecord(DataSet: TDataSet);
begin
   YeniKayit := True;
   if ComboKur.Text = 'Hepsi' then
      TabDoviz.Fields[0].AsString := ''
   else
      TabDoviz.Fields[0].AsString := ComboKur.Text;
   TabDoviz.Fields[1].AsString:= FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateDovizTarihi.Date);
end;

procedure TDovizDlg.btnKapatClick(Sender: TObject);
begin
   close;
end;

procedure TDovizDlg.ChangeCalistir;
begin
   TabDoviz.Close;
   TabDoviz.SQL.Text := 'Select * From DOVIZ  where TARIH >='''+FormatDateTime('yyyy-mm-dd', DateDovizTarihi.Date)+
                        ' 00:00''  and TARIH<='''+FormatDateTime('yyyy-mm-dd', DateDovizTarihi.Date)+' 23:59'' and CINSI<>''TL''  ';
   if (ComboKur.Text <> '')and(ComboKur.Text <> 'Hepsi') then
      TabDoviz.SQL.Add(' and CINSI = '''+ComboKur.Text+''' ');
   TabDoviz.Open;
end;

procedure TDovizDlg.ComboKurPropertiesChange(Sender: TObject);
begin
  ChangeCalistir;
end;

procedure TDovizDlg.TabDovizBeforeEdit(DataSet: TDataSet);
begin
   YeniKayit := False;
end;

procedure TDovizDlg.TabDovizBeforePost(DataSet: TDataSet);
begin
  EkleyenDegistiren(DtsDoviz);

  if TabDoviz.FieldByName('CINSI').IsNull or TabDoviz.FieldByName('TARIH').IsNull then
    Exit;


    if SameText(Trim(TabDoviz.FieldByName('CINSI').OldValue), Trim(TabDoviz.FieldByName('CINSI').AsString)) and
       (Trunc(TabDoviz.FieldByName('TARIH').OldValue) = Trunc(TabDoviz.FieldByName('TARIH').AsDateTime)) then
      Exit;

    if Veritabani.VeriVarMi(
      Tablo.FDCnn,
      'select top 1 1 from DOVIZ where CINSI = &CINSI and cast(TARIH as date) = &TARIH',
      ['&CINSI', '&TARIH*datetime*'],
      [Trim(TabDoviz.FieldByName('CINSI').AsString), TabDoviz.FieldByName('TARIH').AsDateTime]
    ) then
    begin
      MessageBox(0, PChar('Bu tarih ve döviz cinsinde kayıt zaten var!'), PChar(Onay), MB_OK or MB_ICONWARNING);
      Abort;
    end;

 
end;

procedure TDovizDlg.TabDovizAfterPost(DataSet: TDataSet);
begin
   if YeniKayit then begin
      TabDoviz.Close;
      TabDoviz.Open;
   end;
end;

procedure TDovizDlg.DateDovizTarihiPropertiesCloseUp(Sender: TObject);
begin
     DateDovizTarihi.PostEditValue;
     ChangeCalistir;
end;

procedure TDovizDlg.DateDovizTarihiPropertiesChange(Sender: TObject);
begin
     DateDovizTarihi.PostEditValue;
     ChangeCalistir;
end;

procedure TDovizDlg.DBNavigator1BeforeAction(Sender: TObject;
  Button: TNavigateBtn);
begin
   if (Button=nbDelete)and(Application.MessageBox(PChar(KKayit_silinsinmi),PChar(Onay), MB_YESNO)<>IDYES) then abort;
end;


end.




