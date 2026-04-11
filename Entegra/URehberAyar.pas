unit URehberAyar;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, dxSkinsCore,  dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxCheckBox, cxButtonEdit, FireDAC.Comp.Client, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView,
  cxGrid, cxImageComboBox, cxExtEditRepositoryItems, cxEditRepositoryItems,
  cxShellEditRepositoryItems, cxDBEditRepository, cxDBExtLookupComboBox,
  dxSkinLondonLiquidSky, cxDropDownEdit, cxLabel, cxDBLookupComboBox, dxSkinLiquidSky,
  dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom,
  dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxDateRanges, dxScrollbarAnnotations,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TRehberAyarDlg = class(TForm)
    ToolBar1: TToolBar;
    EkleTus: TToolButton;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
    btnKapat: TToolButton;
    GridAyar: TcxGrid;
    GridAyarView: TcxGridDBTableView;
    GridAyarLevel1: TcxGridLevel;
    TabAyar: TFDQuery;
    DtsAyar: TDataSource;
    GridAyarViewYERI: TcxGridDBColumn;
    GridAyarViewSIRA: TcxGridDBColumn;
    GridAyarViewETIKET: TcxGridDBColumn;
    GridAyarViewGIRIS: TcxGridDBColumn;
    GridAyarViewKAYNAK: TcxGridDBColumn;
    GridAyarViewVARSAYILAN: TcxGridDBColumn;
    GridAyarViewZORUNLU: TcxGridDBColumn;
    GridAyarViewLIMIT: TcxGridDBColumn;
    GridAyarViewLIMITALT: TcxGridDBColumn;
    GridAyarViewLIMITUST: TcxGridDBColumn;
    GridAyarViewLIMITBIRIM: TcxGridDBColumn;
    GridAyarViewLIMITNOT: TcxGridDBColumn;
    procedure btnKapatClick(Sender: TObject);
    procedure EkleTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabAyarNewRecord(DataSet: TDataSet);
    procedure DtsAyarStateChange(Sender: TObject);
    procedure TabAyarBeforeDelete(DataSet: TDataSet);
    procedure GridAyarViewVARSAYILANGetPropertiesForEdit(
      Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
      var AProperties: TcxCustomEditProperties);
    procedure FormCreate(Sender: TObject);
    procedure GridAyarViewKAYNAKPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure TabAyarAfterScroll(DataSet: TDataSet);
    procedure GridAyarViewGIRISPropertiesCloseUp(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RehberAyarKopyala(nereden,nereye:Integer;bolum:String);
    procedure TabAyarBeforePost(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    Yer : SmallInt;
    Bolum : string;
   {1 kurum iletiþim
    2 kurum ticari
    3 personel temel
    4 personel iletiþim
    5 personel ücret}
  end;

var
  RehberAyarDlg: TRehberAyarDlg;

implementation

{$R *.dfm}
uses PrjConst, Utablo, UCombo,UComboImgDuzenle,FetaKurulusSiniflari,LocOnFly;

procedure TRehberAyarDlg.btnKapatClick(Sender: TObject);
begin
   Close;
end;

procedure TRehberAyarDlg.DtsAyarStateChange(Sender: TObject);
begin
  Tablo.NavTusGoruntule(DtsAyar, EkleTus,SilTus,KaydetTus,IptalTus);
end;

procedure TRehberAyarDlg.EkleTusClick(Sender: TObject);
begin
   TabAyar.Append;
end;

procedure TRehberAyarDlg.RehberAyarKopyala(nereden,nereye:Integer;bolum:String);
begin
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'delete from REHBERAYAR where YERI=&Yeri and BOLUM=&Bolum AND SUBEID='+IntToStr(SubeId)+' ',['&Yeri','&Bolum'],[nereye,bolum]);
  Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn,'insert into REHBERAYAR(YERI,SIRA,ETIKET,GIRIS,KAYNAK,VARSAYILAN,ZORUNLU,BOLUM,SUBEID) '
          +'select &Nereye,SIRA,ETIKET,GIRIS,KAYNAK,VARSAYILAN,ZORUNLU,BOLUM,SUBEID from REHBERAYAR where YERI=&Nereden and BOLUM=&Bolum'
          ,['&Nereye','&Nereden','&Bolum'],[nereye,nereden,bolum]);

end;

procedure TRehberAyarDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Yer = TabNo_EKIPMAN then
    RehberAyarKopyala(TabNo_EKIPMAN,TabNo_EKIPMANREHBER,Bolum);
end;

procedure TRehberAyarDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Bolum:='';

  Tablo.GridTurkcelestir;

end;

procedure TRehberAyarDlg.FormShow(Sender: TObject);
var  i : integer;
  LProps: TcxImageComboBoxProperties;
  LSrcProps: TcxImageComboBoxProperties;
begin
   i:=Yer;
   if i=4 then //Kurum ve pers iletiþim ayný olacak
      i:=1;

   LProps := TcxImageComboBoxProperties(GridAyarViewVARSAYILAN.Properties);
   LSrcProps := Tablo.imgComboboxInit('select 0,'''' union all select NO,ADI from REHBERVARSAYILAN where YERI='+IntToStr(i)+' order by 2');
   LProps.Items.BeginUpdate;
   try
     LProps.Items.Clear;
     LProps.Items.Assign(LSrcProps.Items);
   finally
     LProps.Items.EndUpdate;
   end;
   TabAyar.Close;
   if TabAyar.FindParam('YERI') = nil then
     TabAyar.Params.Add.Name := 'YERI';
   if TabAyar.FindParam('Bolum') = nil then
     TabAyar.Params.Add.Name := 'Bolum';
   TabAyar.ParamByName('YERI').Value := Yer;
   TabAyar.ParamByName('Bolum').Value := Bolum;
   TabAyar.Open;
end;

procedure TRehberAyarDlg.GridAyarViewGIRISPropertiesCloseUp(Sender: TObject);
begin
  //TabAyar.FieldByName('KAYNAK').AsString:='';
  if GridAyarViewGIRIS.EditValue=10 then
    GridAyarViewKAYNAK.EditValue:='9\(999\)999 99 99';//'0\(000\)000 00 00' --Eksik no girildiðinde yada boþ olduðunda hata vermesi engellendi.
end;

procedure TRehberAyarDlg.GridAyarViewKAYNAKPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if (TabAyar.FieldByName('GIRIS').AsInteger in [4,6,8,9])and(Pos(Uppercase(TabAyar.FieldByName('KAYNAK').AsString),'SELECT')=0) then begin
      if trim(TabAyar.FieldByName('KAYNAK').AsString)='' then begin
         showmessage(Kaynak_doldur);
         Abort;
      end;
    Tablo.TablodanSorguAc(7,'select DEGER from GENINI where DIL='+IntToStr(Dil)+' AND  BOLUM=0 and ANAHTAR='''+TabAyar.FieldByName('KAYNAK').AsString+'''');
    Tablo.GeniniBaslat(Tablo.Query7.Fields[0].AsInteger, TabAyar.FieldByName('KAYNAK').AsString);
  end;
end;

procedure TRehberAyarDlg.GridAyarViewVARSAYILANGetPropertiesForEdit(
  Sender: TcxCustomGridTableItem; ARecord: TcxCustomGridRecord;
  var AProperties: TcxCustomEditProperties);
begin
 {  Tablo.cxEditRepository1ImageComboBoxItem1.Properties.Items.Clear;    //img combobox
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'SELECT ADI,NO FROM REHBERVARSAYILAN';// WHERE YERI = '+IntToStr(Yer);
   Tablo.Query1.Open;
   Tablo.Query1.First;
   while Not Tablo.Query1.Eof do begin
     with Tablo.cxEditRepository1ImageComboBoxItem1.Properties.Items.Add do begin
       Description := Tablo.Query1.Fields[0].AsString;
       Value := Tablo.Query1.Fields[1].AsString;
     end;
      Tablo.Query1.Next;
   end;
   Tablo.cxEditRepository1ImageComboBoxItem1.Properties.Sorted:=True;
   AProperties := Tablo.cxEditRepository1ImageComboBoxItem1.Properties; }
end;

procedure TRehberAyarDlg.IptalTusClick(Sender: TObject);
begin
   TabAyar.Cancel;
end;

procedure TRehberAyarDlg.KaydetTusClick(Sender: TObject);
begin
   TabAyar.Post;
end;

procedure TRehberAyarDlg.SilTusClick(Sender: TObject);
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
      TabAyar.Delete;
end;

procedure TRehberAyarDlg.TabAyarAfterScroll(DataSet: TDataSet);
begin
  if (TabAyar.FieldByName('GIRIS').AsInteger in [4,6,8])then //and (TabAyar.FieldByName('KAYNAK').AsString <> '') and (Pos('SELECT',UpperCase(TabAyar.FieldByName('KAYNAK').AsString)) = 0)then
    (GridAyarViewKAYNAK.Properties as TcxButtonEditProperties).Buttons[0].Enabled:=True
  else
    (GridAyarViewKAYNAK.Properties as TcxButtonEditProperties).Buttons[0].Enabled:=False;
end;

procedure TRehberAyarDlg.TabAyarBeforeDelete(DataSet: TDataSet);
begin
   //Varsayýlan kýsmý dolu ise ve data girilmiþse silinemez ve SIRA ve Varsayýlan kýsmý deðiþtirilemez
   if TabAyar.FieldByName('VARSAYILAN').AsString <> '' then begin
      Tablo.Query1.Close;    //resimleri silinir
      if Yer=5 then //ÝK Tahakkuk
         Tablo.Query1.SQL.Text := ' select top 1 ID from PLANMAAS where YERI='+IntToStr(Yer)+' and SIRA ='+TabAyar.FieldByName('SIRA').AsString
      else
         Tablo.Query1.SQL.Text := ' select top 1 ID from REHBERBILGI where YERI='+IntToStr(Yer)+' and SIRA ='+TabAyar.FieldByName('SIRA').AsString;
      Tablo.Query1.Open;
      if Tablo.Query1.RecordCount>0 then
         raise Exception.Create(RGirilmisBilgiVar);
   end
end;

procedure TRehberAyarDlg.TabAyarBeforePost(DataSet: TDataSet);
var
  Mesaj:String;
begin
  Mesaj := '';
  if TabAyar.FieldbyName('SIRA').AsString = '' then
    Mesaj := Mesaj + 'SIRA ';
  if TabAyar.FieldbyName('ETIKET').AsString = '' then
    Mesaj := Mesaj + 'ETIKET ';
  if TabAyar.FieldbyName('GIRIS').AsString = '' then
    Mesaj := Mesaj + 'GIRIS ';
  if (TabAyar.FieldByName('GIRIS').AsInteger in [4,6,8])and(TabAyar.FieldbyName('KAYNAK').AsString = '') then
    Mesaj := Mesaj + 'KAYNAK ';
  if Mesaj <> '' then begin
    Mesaj := Mesaj + 'Alanlarý boþ býrakýlamaz.';
    ShowMessage(Mesaj);
    Abort;
  end;
end;

procedure TRehberAyarDlg.TabAyarNewRecord(DataSet: TDataSet);
begin
   TabAyar.FieldByName('YERI').AsInteger := Yer;
   TabAyar.FieldByName('BOLUM').AsString := Bolum;
   TabAyar.FieldByName('SUBEID').AsInteger := SubeID;
end;

end.









