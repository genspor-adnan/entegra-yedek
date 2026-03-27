unit UMaasListe;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxLookAndFeels,
  cxLookAndFeelPainters, Menus, dxSkinsCore, dxSkinLondonLiquidSky,
  cxControls, cxStyles, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, Data.DB, cxDBData, cxButtonEdit,
  cxDropDownEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, Vcl.StdCtrls,
  cxButtons, Vcl.ExtCtrls, dxmdaset, Vcl.ComCtrls, Vcl.ToolWin, cxContainer,
  cxLabel, cxTextEdit, cxMaskEdit, cxImageComboBox, cxDBEdit, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  cxCalendar, cxCurrencyEdit, dxSkinLiquidSky, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxCore, cxDateUtils, JvExControls, JvNavigationPane, UPirim,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxDateRanges,
  dxScrollbarAnnotations;

type
  TMaasListeDlg = class(TForm)
    DtsMaasListe: TDataSource;
    MAASLISTE: TdxMemData;
    GridMaas: TcxGrid;
    GridMaasTV: TcxGridDBTableView;
    GridMaasLevel1: TcxGridLevel;
    MAASLISTEID: TIntegerField;
    MAASLISTEFIRMA: TStringField;
    GridMaasTVRecId: TcxGridDBColumn;
    GridMaasTVID: TcxGridDBColumn;
    GridMaasTVFIRMA: TcxGridDBColumn;
    GridMaasTVDEPARTMAN: TcxGridDBColumn;
    MAASLISTEISEGIRIS: TDateField;
    GridMaasTVColumn1: TcxGridDBColumn;
    MAASLISTESUBE: TIntegerField;
    GridMaasTVSUBE: TcxGridDBColumn;
    PopupMenu1: TPopupMenu;
    ExceldenBilgiekle1: TMenuItem;
    ExceleGnder1: TMenuItem;
    Panel11: TPanel;
    PanelPrim: TJvNavPanelHeader;
    ToolBar1: TToolBar;
    KaydetTus: TToolButton;
    btnKapat: TToolButton;
    CalendarEkstreBit: TcxDateEdit;
    Label2: TcxLabel;
    CalendarEkstreBas: TcxDateEdit;
    Label1: TcxLabel;
    JvNavPanelHeader1: TJvNavPanelHeader;
    ComboSube: TcxImageComboBox;
    LblSube: TcxLabel;
    PrimHesaplaTus: TcxButton;
    GridMaasTVColumn2: TcxGridDBColumn;
    MAASLISTEPERYOT: TSmallintField;
    PrimOranlariMenu: TMenuItem;
    AraCizgi1Menu: TMenuItem;
    PrimListesiMenu: TMenuItem;
    cxLabel5: TcxLabel;
    EditDepartman: TcxButtonEdit;
    cxLabel1: TcxLabel;
    EditGorev: TcxButtonEdit;
    GridMaasTVColumn3: TcxGridDBColumn;
    procedure MAASLISTEBeforePost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridMaasTVCanFocusRecord(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; var AAllow: Boolean);
    procedure GridMaasTVStylesGetContentStyle(Sender: TcxCustomGridTableView;
      ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem;
      var AStyle: TcxStyle);
    procedure ComboSubePropertiesCloseUp(Sender: TObject);
    procedure ExceldenBilgiekle1Click(Sender: TObject);
    procedure PrimHesaplaTusClick(Sender: TObject);
    procedure PrimOranlariMenuClick(Sender: TObject);
    procedure PrimListesiMenuClick(Sender: TObject);
    procedure CalendarEkstreBitPropertiesCloseUp(Sender: TObject);
    procedure EditDepartmanPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
  private
    { Private declarations }
    procedure GridDoldur;
  public
    { Public declarations }
  end;

var
  MaasListeDlg: TMaasListeDlg;

implementation

{$R *.dfm}

uses UTablo, FetaKurulusSiniflari, UAnaForm, UBekletme, ComObj, PrjConst, UPOS, fetautil,
  FetaClassExtensions;

const BasSutunu=8;
var Basladi, OdemeEksiOlamaz: Boolean;
    TSutunu, KSutunu, MaasSutunu, PrimSutunu : Smallint;


procedure TMaasListeDlg.KaydetTusClick(Sender: TObject);
var i : SmallInt;
    s : String;
     procedure Islem(Tutar:Currency; Yer,YerId,Sira:Integer;Etiket:String);
     begin
        if Sira>=0 then
              s:=' and SIRA='+IntToStr(MAASLISTE.Fields[i].Tag)
        else
              s:='';
        if Tutar>0 then begin
             //önce bakalım daha önce kayıtlı mı
             Tablo.TablodanSorguAc(1,'SELECT TOP 1 ID  FROM dbo.PLANMAAS WHERE YER='+IntToStr(Yer)+' AND YERID='+IntToStr(YerId)+s);
             if Tablo.Query1.RecordCount > 0 then
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update PLANMAAS set TUTAR='+Float_ToStr(Tutar)+',DEGISTIREN='+Kullanan+' where ID='+Tablo.Query1.Fields[0].AsString,[],[])
             else
                Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into PLANMAAS(YER,YERID,SIRA,ETIKET,TUTAR,KUR,EKLEYEN)values('+IntToStr(Yer)+','+
                   IntToStr(YerId)+','+IntToStr(Sira)+','''+Etiket+''','+Float_ToStr(Tutar)+','''+CariDoviz+''','+Kullanan+')',[],[])
        end else
             Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from PLANMAAS where YER='+IntToStr(Yer)+' and YERID='+IntToStr(YerId)+s,[],[]);
     end;
begin
//    Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from PLANMAAS where YER in (0,51)',[],[]);
    if MAASLISTE.state in [dsEdit,dsInsert] then
       MAASLISTE.post;
    MAASLISTE.DisableControls;
    MAASLISTE.first;
    while not MAASLISTE.EOF do begin
      if MAASLISTE.FieldByName('DEGIS').AsCurrency>0.0 then begin //değiştiyse
          //bankadan ödenecek kısmı kaydedelim
          Islem(MAASLISTE.FieldByName('BANKA').AsCurrency, 51, MAASLISTE.FieldByName('ID').AsInteger,-1,'');
          //tahakkukları kaydedelim
          for i := BasSutunu to TSutunu-1 do
              Islem(MAASLISTE.Fields[i].AsCurrency, 0, MAASLISTE.FieldByName('ID').AsInteger,MAASLISTE.Fields[i].Tag,MAASLISTE.Fields[i].FieldName);
          for i := TSutunu+1 to KSutunu-1 do
              Islem(MAASLISTE.Fields[i].AsCurrency, 91, MAASLISTE.FieldByName('ID').AsInteger,MAASLISTE.Fields[i].Tag,MAASLISTE.Fields[i].FieldName);
{            if MAASLISTE.Fields[i].AsCurrency > 0 then begin
               //önce bakalım daha önce kayıtlı mı
               Tablo.TablodanSorguAc(1,'SELECT TOP 1 ID  FROM dbo.PLANMAAS WHERE YER=0 AND YERID='+MAASLISTE.FieldByName('ID').AsString+' and SIRA='+IntToStr(MAASLISTE.Fields[i].Tag));
               if Tablo.Query1.RecordCount > 0 then
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'update PLANMAAS set TUTAR='+MAASLISTE.Fields[i].AsString+',DEGISTIREN='+Kullanan+' where ID='+Tablo.Query1.Fields[0].AsString,[],[])
               else
                  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'insert into PLANMAAS(YER,YERID,SIRA,ETIKET,TUTAR,KUR,EKLEYEN)values(0,'+
                    MAASLISTE.FieldByName('ID').AsString+','+IntToStr(MAASLISTE.Fields[i].Tag)+','''+MAASLISTE.Fields[i].FieldName+''','+MAASLISTE.Fields[i].AsString+','''+CariDoviz+''','+Kullanan+')',[],[])
            end else
               Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'delete from PLANMAAS where YER=0 and YERID='+MAASLISTE.FieldByName('ID').AsString+' and SIRA='+IntToStr(MAASLISTE.Fields[i].Tag),[],[]);
               }
      end;
      MAASLISTE.Next;
    end;
//    MAASLISTE.EnableControls;
    Close;
end;

procedure TMaasListeDlg.btnKapatClick(Sender: TObject);
begin
    Close;
end;

procedure TMaasListeDlg.CalendarEkstreBitPropertiesCloseUp(Sender: TObject);
begin
   GridDoldur
end;

procedure TMaasListeDlg.ComboSubePropertiesCloseUp(Sender: TObject);
begin
   GridDoldur
end;

procedure TMaasListeDlg.EditDepartmanPropertiesButtonClick(Sender: TObject;  AButtonIndex: Integer);
begin
   tablo.EditDepartmanSec(TcxButtonEdit(Sender), AButtonIndex, strtoint(TcxButtonEdit(Sender).hint), nil, '');
   GridDoldur;
end;

procedure TMaasListeDlg.ExceldenBilgiekle1Click(Sender: TObject);
var
    book:variant;
    excel,sheet:variant;
    satir, sutun,i,RehID,kolon:integer;
    kolonlist:TStringList;
    function excelsonsatir(AColumn: Integer): Integer;
    const
      xlUp = 3;
    begin
        Result := excel.Range[Char(96 + AColumn) + IntToStr(65536)].end[xlUp].Rows.Row;
    end;
begin

  excel := CreateOleObject('Excel.Application');
  Tablo.OpenDialog1.Title := 'Excel Dosyasını Aç';
  Tablo.OpenDialog1.Filter := 'Excel Dosyaları *.xls';

  if Tablo.OpenDialog1.Execute then begin
    book := Excel.WorkBooks.Open(Tablo.OpenDialog1.FileName);
    Application.CreateForm(TBekletmeDlg,BekletmeDlg);

    try
      Screen.Cursor := crHourGlass;
      sheet := book.worksheets[1];
      BekletmeDlg.Caption := 'Excelden veriler aktarılıyor.Bekleyiniz...';
      BekletmeDlg.cxProgressBar1.Properties.Max := excelsonsatir(1)+1;
      BekletmeDlg.Show;
      //ÖNCE kolonadlarını listeye alalım
      kolonlist:=TStringList.Create;
      kolon := 3;
      while VarToStr(sheet.cells[1,kolon]) <> '' do begin
//         kolonlist.add('['+VarToStr(sheet.cells[1,kolon])+']');
         kolonlist.add(VarToStr(sheet.cells[1,kolon]));
         inc(kolon);
      end;
      //
      for kolon := 0 to kolonlist.count-1 do begin
          for satir := 2 to excelsonsatir(1)+1 do begin
            BekletmeDlg.cxProgressBar1.Position := satir;
            BekletmeDlg.cxProgressBar1.Refresh;

            if VarToStr(sheet.cells[satir,1]) <> '' then begin

               MAASLISTE.Locate('TCNO', VarToStr(sheet.cells[satir,1]), []);
               MAASLISTE.edit;
               MAASLISTE.FieldByName(kolonlist[kolon]).AsCurrency := StrTofloatdef( VarToStr(sheet.cells[satir,kolon+3]),0);
               MAASLISTE.post;
            end;
          end;
      end;

      excel.DisplayAlerts := False;
      excel.quit;
      excel := Unassigned;
      BekletmeDlg.Destroy;
      kolonlist.free;
      Application.Messagebox(PChar(Kaydedildi),Pchar(Uyari),MB_OK);
    finally
      Screen.Cursor:=crDefault;
    end;
  end;
end;

procedure TMaasListeDlg.FormActivate(Sender: TObject);
begin
   Basladi:=True;
end;

procedure TMaasListeDlg.FormCreate(Sender: TObject);
begin
   Basladi:=False;
   LblSube.Visible:=SubeVarmi;
   ComboSube.Visible:=SubeVarmi;
   GridMaasTVSUBE.Visible:=SubeVarmi;
   OdemeEksiOlamaz := Tablo.GENINI.ReadBoolean(Ops_IK_OdemeEksiOlamaz, False);
end;

procedure TMaasListeDlg.GridDoldur;
var
   S:String;
   i:integer;
   fld, fld2: TField;
   aval: Variant;
begin
  MAASLISTE.close;
  Tablo.TablodanSorguAc(1, 'select SIRA,ETIKET,VARSAYILAN from REHBERAYAR where YERI=5 and VARSAYILAN in (11,12,13,15)  order by  3');//tahakkuk
   //Daha önce girilmişmaaş bilgilerini alalım
   S:='select * from(select R.ID,FIRMA, '+
//      ' SUBE=(SELECT TOP 1 SUBEID FROM PERS_HAREKET PH WHERE PH.REHBERID=R.ID ORDER BY ID DESC), '+
//      ' POZISYON=(SELECT TOP 1 POZISYON FROM PERS_HAREKET PH WHERE PH.REHBERID=R.ID ORDER BY ID DESC),'+
      ' SUBE=R.SUBEID, '+
     // ' POZISYON=R.SINIF,'+
      ' DEPARTMAN=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2251 AND DEGER = ROL.DEPARTMAN AND DIL=-1 ),'+
      ' GOREV=(SELECT TOP 1 ANAHTAR FROM GENINI WHERE BOLUM=-2252 AND DEGER = ROL.GOREVID AND DIL=-1 ),'+
      ' ISEGIRIS=(SELECT TOP 1 TARIH FROM PERS_HAREKET PH WHERE PH.REHBERID=R.ID AND TUR=1 ),PERYOT,';
//      ' ISEGIRIS=R.GIRISTARIHI,';


   while not Tablo.Query1.EOF do begin
      //MAAS=(select isnull(TUTAR,0) from PLANMAAS PM where R.ID=PM.YERID and YER=0 and SIRA=10),
      S:=S+' ['+Tablo.Query1.FieldByName('ETIKET').AsString+']=cast(isnull((select top 1 isnull(TUTAR,0) from PLANMAAS PM where R.ID=PM.YERID and YER=0 and SIRA='+Tablo.Query1.FieldByName('SIRA').AsString+'),0.0) as money),';
      Tablo.Query1.Next;
    end;
    S:=S+' TAHTOPLAM=0.0,';
   Tablo.TablodanSorguAc(1, 'select SIRA,ETIKET,VARSAYILAN from REHBERAYAR where YERI=6  order by  3'); //kesinti     and VARSAYILAN =33
   while not Tablo.Query1.EOF do begin
      //MAAS=(select isnull(TUTAR,0) from PLANMAAS PM where R.ID=PM.YERID and YER=0 and SIRA=10),
      S:=S+' ['+Tablo.Query1.FieldByName('ETIKET').AsString+']=cast(isnull((select top 1 isnull(TUTAR,0) from PLANMAAS PM where R.ID=PM.YERID and YER=91 and SIRA='+Tablo.Query1.FieldByName('SIRA').AsString+'),0.0) as money),';
      Tablo.Query1.Next;
    end;
    S:=S+' KESTOPLAM=0.0,TOPLAM=0.0, BANKA=cast(isnull((SELECT TOP 1 isnull(TUTAR,0.0) ';
    S:=S+' FROM PLANMAAS PM where R.ID=PM.YERID and YER=51),0.0) as float),KASA=0.0,DEGIS=0.0, ';
    S:=S+' TCNO=(select convert(nvarchar(15),BILGI) from REHBERBILGI where YERI=3 and SIRA=22 and YER_ID=R.ID)';
    S:=S+' from REHBER R inner join ROLLER ROL on ROL.ID=R.SINIF where R.GRUP=335 and R.DURUM=1 ) as TT   where 1=1 ';
    if PanelPrim.Visible then
       S:=S+' and ISEGIRIS<='''+FormatDateTime('yyyy-mm-dd 23:59', CalendarEkstreBit.Date)+''' ';
    if (SubeVarmi)and(ComboSube.EditValue<>null) then
       S:=S+' and SUBE='+IntToStr(ComboSube.EditValue);
    if EditDepartman.Text<>'' then
       S:=S+' and DEPARTMAN='''+EditDepartman.Text+''' ';
    if EditGorev.Text<>'' then
       S:=S+' and GOREV='''+EditGorev.Text+''' ';

    S:=S+' order by 2 ';

   //Tablodan bilgileri select edelim
   Tablo.TablodanSorguAc(1 ,S);

    MAASLISTE.Open;
    MAASLISTE.DisableControls;
    while not Tablo.Query1.EOF do begin
      MAASLISTE.append;
      for i := 0 to Tablo.Query1.FieldCount-1 do begin
         fld := MAASLISTE.Fields[i+1];
         fld2 := Tablo.Query1.Fields[i];
         if (fld.DataType = ftCurrency) and not fld2.IsNull then begin
           VarCast(aval,fld2.AsCurrency,varCurrency);
           fld.AsVariant := aval;
         end
         else
           fld.value := fld2.Value;
      end;
      //burada işe giriş tarihini kontrol edelim. bu ay içinde başlamışsa maaşını ona göre hesaplayalım
      if (MAASLISTE.FieldByName('ISEGIRIS').AsDateTime > CalendarEkstreBas.Date)and(MAASLISTE.FieldByName('ISEGIRIS').AsDateTime <= CalendarEkstreBit.Date) then
          MAASLISTE.Fields[MaasSutunu].AsCurrency := (MAASLISTE.Fields[MaasSutunu].AsCurrency/30)*(CalendarEkstreBit.Date -  MAASLISTE.FieldByName('ISEGIRIS').AsDateTime+1);
      MAASLISTE.post;
      //MAASLISTEAfterPost(MAASLISTE);
      Tablo.Query1.Next;
    end;
    MAASLISTE.EnableControls;
    GridMaasTV.ApplyBestFit(nil);
end;

procedure TMaasListeDlg.FormShow(Sender: TObject);
var GridCol : TcxGridDBColumn;
    index :Integer;
    field : TCurrencyField;

    procedure CreateField(AMemData: TDataSet; AFieldName: string; AFieldType: TFieldType; SIRANO:Integer);
    begin
      if (AMemData = nil) or (AFieldName = '') then
        Exit;
      with AMemData.FieldDefs.AddFieldDef do
      begin
        Name := AFieldName;
        DataType := AFieldType;
        field := TCurrencyField(CreateField(AMemData));
        field.Tag := SIRANO;
      end;

    end;
    procedure KolonOlustur(Ad:string; SIRANO:Integer);
    begin
      CreateField(MAASLISTE,Ad,ftBCD, SIRANO);
      GridCol:=GridMaasTV.CreateColumn;
      GridCol.DataBinding.FieldName:=Ad;
      GridCol.PropertiesClass := TcxCurrencyEditProperties;
      with TcxCurrencyEditProperties(GRidCol.Properties) do begin
        DisplayFormat := ',0.00;';
      end;
      if Ad='TOPLAM' then
         GridCol.Styles.Content := Tablo.cxStyle10
      else if (Ad='KesToplam')or(Ad='TahToplam') then
         GridCol.Styles.Content := Tablo.cxstSecili;

      if (Ad='TOPLAM')or(Ad='KASA')or(Ad='KASAODE')or(Ad='KesToplam')or(Ad='TahToplam') then
         GridCol.Options.Editing:=False;
      if Ad='DEGIS' then
         GridCol.Visible:=False;
      {index := GridMaasTV.GetColumnByFieldName(Ad).index;
      GridMaasTV.Columns[index].Summary.Footerkind := skSum;
      GridMaasTV.Columns[index].Summary.FooterFormat :='###,###,###.00';// ',0.00;';   }
      with TcxGridDBTableSummaryItem( GridMaasTV.DataController.Summary.FooterSummaryItems.Add ) do begin
        Column := GridCol;
        FieldName := Ad;
        Format := '###,###,###.00';
        Kind := skSum;
      end;
    end;
begin
   //Tahakkukların listesini alalım Ör:Maaş,Agi,Yol,Yemek vb..
   //GridMaasTV.RestoreFromRegistry('SOFTWARE\GENTEGRE2\Gridler\MaasCarsafListeGridi',true,false,[gsoUseFilter],'MaasCarsafListeGridi');
   Tablo.GridAyarRestore('MaasCarsafListeGridi',GridMaasTV );


  Tablo.TablodanSorguAc(1, 'select SIRA,ETIKET,VARSAYILAN from REHBERAYAR where YERI=5 and VARSAYILAN in (11,12,13,15)  order by  3');
  //Bu listeye göre gride kolonlar ekleyelim
  MaasSutunu := BasSutunu;
   while not Tablo.Query1.EOF do begin
      //Eğer prim sütunu belirirse en üstte de hesaplama için prim baneli görünmeli
      if Tablo.Query1.FieldByName('VARSAYILAN').AsInteger = 13 then begin
         PanelPrim.Visible := True;
         PrimSutunu := MAASLISTE.fieldcount;
         Tablo.tablodansorguac(2, 'select TARIH,DEGISTIRMETARIHI from PLANMAAS where YER=0 and YERID=-99  ');
         if Tablo.Query2.RecordCount > 0 then begin
            CalendarEkstreBas.Date := Tablo.Query2.Fields[0].AsDateTime;
            CalendarEkstreBit.Date := Tablo.Query2.Fields[1].AsDateTime;
        end;
      end;

      KolonOlustur( Tablo.Query1.FieldByName('ETIKET').AsString, Tablo.Query1.FieldByName('SIRA').AsInteger);
      Tablo.Query1.Next;
    end;
    //Tahakkuk toplam sütunu
    TSutunu:=BasSutunu+Tablo.Query1.RecordCount;
    KolonOlustur('TahToplam',0);

  Tablo.TablodanSorguAc(1, ' select SIRA,ETIKET,VARSAYILAN,* from REHBERAYAR where YERI=6  order by  3');//and VARSAYILAN =33
  //Bu listeye göre gride kolonlar ekleyelim
   while not Tablo.Query1.EOF do begin
      KolonOlustur( Tablo.Query1.FieldByName('ETIKET').AsString, Tablo.Query1.FieldByName('SIRA').AsInteger);
      Tablo.Query1.Next;
    end;
    //kesinti toplam sütunu
    KolonOlustur('KesToplam',0);
    if Tablo.Query1.RecordCount<1 then begin //kesinti yoksa ara toplamlara gerek yok
       MAASLISTE.Fields[TSutunu].Visible:=False;
       MAASLISTE.Fields[TSutunu+1].Visible:=False;
    end;

    KSutunu:=1+TSutunu+Tablo.Query1.RecordCount;



    KolonOlustur('TOPLAM',0);
    KolonOlustur('BANKA',0);
    KolonOlustur('KASA',0);
    KolonOlustur('KASAODE',0);
    KolonOlustur('DEGIS',0);
    CreateField(MAASLISTE,'TCNO',ftString, 0);
   //Gride bilgiler gelsin
    GridDoldur;

    AraCizgi1Menu.visible :=  PanelPrim.visible;
    PrimOranlariMenu.visible :=  PanelPrim.visible;
    PrimListesiMenu.visible :=  PanelPrim.visible;
end;

procedure TMaasListeDlg.GridMaasTVCanFocusRecord(Sender: TcxCustomGridTableView;
                        ARecord: TcxCustomGridRecord; var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid := GridMaas;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView := GridMaasTV;
  AnaForm.pmGridStil.Tags.Values[GridMaas.Name]:='MaasCarsafListeGridi';
end;

procedure TMaasListeDlg.GridMaasTVStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
                        AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
  Tablo.GridStilYonetim.StilDenetle(Sender.Name, AStyle, Sender, ARecord);
end;

procedure TMaasListeDlg.MAASLISTEBeforePost(DataSet: TDataSet);
var i : smallint;
    Tutar:Currency;
begin
   Tutar := 0;
   for i := BasSutunu to TSutunu-1 do  //MAASLISTE.FieldCount-5 son toplam sütununu almayacak
       if (i <> PrimSutunu)or  // (MAASLISTE.Fields[i].FieldName <> 'Prim')
          ((i = PrimSutunu)and(MAASLISTE.FieldByName('PERYOT').AsInteger=2)) then //maaş + prim ise toplanacak
       Tutar  := Tutar + MAASLISTE.Fields[i].AsCurrency;

   //maaş yada prim seçili ise ve prim büyükse maaş yerine primi koyarız
   if (MAASLISTE.FieldByName('PERYOT').AsInteger=1) and(MAASLISTE.Fields[PrimSutunu].AsCurrency>MAASLISTE.Fields[MaasSutunu].AsCurrency) then //maaş ya da prim ise
       Tutar := Tutar - MAASLISTE.Fields[MaasSutunu].AsCurrency + MAASLISTE.Fields[PrimSutunu].AsCurrency;
   MAASLISTE.FieldByName('TAHTOPLAM').AsCurrency := Tutar;
   Tutar := 0;
   for i := TSutunu+1 to KSutunu-1 do  //MAASLISTE.FieldCount-5 son toplam sütununu almayacak
       Tutar  := Tutar + MAASLISTE.Fields[i].AsCurrency;
   MAASLISTE.FieldByName('KESTOPLAM').AsCurrency := Tutar;
   MAASLISTE.FieldByName('TOPLAM').AsCurrency := MAASLISTE.FieldByName('TAHTOPLAM').AsCurrency-MAASLISTE.FieldByName('KESTOPLAM').AsCurrency;
   MAASLISTE.FieldByName('KASA').AsCurrency := MAASLISTE.FieldByName('TOPLAM').AsCurrency - MAASLISTE.FieldByName('BANKA').AsCurrency;
   MAASLISTE.FieldByName('KASAODE').AsCurrency := MAASLISTE.FieldByName('KASA').AsCurrency;
   if MAASLISTE.FieldByName('KASAODE').AsCurrency < 0 then
      MAASLISTE.FieldByName('KASAODE').AsCurrency := 0;

   if Basladi then
      MAASLISTE.FieldByName('DEGIS').AsCurrency := 1.0;
end;

procedure TMaasListeDlg.PrimHesaplaTusClick(Sender: TObject);
begin
   //prim başlama ve bitiş tarihlerini kaydedelim
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' delete from PLANMAAS where YER=0 and YERID=-99',[],[]);
   Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, ' insert into PLANMAAS(YER,YERID,EKLEYEN,TARIH,DEGISTIRMETARIHI)values(0,-99,'+Kullanan+','+
      ''''+FormatDateTime('yyyy-mm-dd',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd',CalendarEkstreBit.Date)+''')',[],[]);

   //primleri hesaplayalım
   MAASLISTE.First;
   while not MAASLISTE.Eof do begin
      MAASLISTE.edit;
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'exec P_Pirim_Liste_Guncelle '+MAASLISTE.FieldByName('ID').AsString+','+
        ''''+FormatDateTime('yyyy-mm-dd 00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+'''',[],[]);

      MAASLISTE.FieldByName('PRIM').Value := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'select sum(PIRIM) from PERS_PIRIM_LISTE where REHBERID='+MAASLISTE.FieldByName('ID').AsString+' and TARIH between '+
        ''''+FormatDateTime('yyyy-mm-dd 00:00',CalendarEkstreBas.Date)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+'''',[],[],True);
      MAASLISTE.Post;
      MAASLISTE.Next;
   end;
end;

procedure TMaasListeDlg.PrimListesiMenuClick(Sender: TObject);
begin
  Tablo.ListedenBilgiGetir('Prim Listesi',
      'select * from [dbo].[fn_Prim_Detay_Liste]('+MAASLISTE.FieldByName('ID').AsString+','+
        ''''+FormatDateTime('yyyy-mm-dd 00:00',CalendarEkstreBas.Date)+''','''+FormatDateTime('yyyy-mm-dd 23:59',CalendarEkstreBit.Date)+''')',
      nil,[]);
end;

procedure TMaasListeDlg.PrimOranlariMenuClick(Sender: TObject);
begin
  Application.CreateForm(TPirimDlg,PirimDlg);
  PirimDlg.RehberID := MAASLISTE.FieldByName('ID').AsInteger;
  PirimDlg.ShowModal;
  FreeAndNil(PirimDlg);
end;

end.


