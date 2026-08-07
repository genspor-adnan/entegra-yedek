unit Ubelgegiris;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, System.Classes, Vcl.Graphics,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator, Data.DB,
  cxDBData, Vcl.ExtCtrls, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, dxmdaset,
  cxButtonEdit, cxDropDownEdit, cxContainer, cxLabel, cxTextEdit, cxMaskEdit,
  Vcl.ComCtrls, dxCore, cxDateUtils, cxCalendar, Vcl.Menus, Vcl.StdCtrls,
  cxButtons, cxCurrencyEdit, FireDAC.Comp.Client, dxSkinLondonLiquidSky,Math,
  cxDBLookupComboBox, cxImageComboBox, dxSkinLiquidSky, dxSkinscxPCPainter,
  dxSkinBlue, dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxDateRanges, dxScrollbarAnnotations, dxCoreGraphics,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  Tbelgegirisdlg = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    Panel1: TPanel;
    dxMemData1: TdxMemData;
    dxMemData1s_no: TIntegerField;
    dxMemData1cr_kod: TStringField;
    dxMemData1cr_ad: TStringField;
    dxMemData1belge_no: TStringField;
    DataSource1: TDataSource;
    cxGrid1DBTableView1RecId: TcxGridDBColumn;
    cxGrid1DBTableView1s_no: TcxGridDBColumn;
    cxGrid1DBTableView1cr_kod: TcxGridDBColumn;
    cxGrid1DBTableView1cr_ad: TcxGridDBColumn;
    cxGrid1DBTableView1belge_no: TcxGridDBColumn;
    dxMemData1belgetip: TStringField;
    cxGrid1DBTableView1belgetip: TcxGridDBColumn;
    dxMemData1belgetarih: TDateTimeField;
    dxMemData1mkod: TStringField;
    dxMemData1mad: TStringField;
    cxGrid1DBTableView1belgetarih: TcxGridDBColumn;
    cxGrid1DBTableView1mkod: TcxGridDBColumn;
    cxGrid1DBTableView1mad: TcxGridDBColumn;
    dxMemData1aciklama: TStringField;
    dxMemData1adet: TFloatField;
    dxMemData1b_fiyat: TCurrencyField;
    dxMemData1kdv: TIntegerField;
    dxMemData1p_birim: TStringField;
    cxGrid1DBTableView1aciklama: TcxGridDBColumn;
    cxGrid1DBTableView1adet: TcxGridDBColumn;
    cxGrid1DBTableView1b_fiyat: TcxGridDBColumn;
    cxGrid1DBTableView1kdv: TcxGridDBColumn;
    cxGrid1DBTableView1tutar: TcxGridDBColumn;
    cxGrid1DBTableView1p_birim: TcxGridDBColumn;
    dxMemData1kdvdrm: TStringField;
    dxMemData1ctutar: TCurrencyField;
    dxMemData1baslik: TIntegerField;
    dxMemData1cr_id: TIntegerField;
    dxMemData1m_id: TIntegerField;
    Panel3: TPanel;
    Panel16: TPanel;
    cxLabel25: TcxLabel;
    Panel4: TPanel;
    cxLabel3: TcxLabel;
    cxTextEdit2: TcxTextEdit;
    cxButtonEdit1: TcxButtonEdit;
    Panel5: TPanel;
    cxLabel4: TcxLabel;
    cxTextEdit3: TcxTextEdit;
    Panel6: TPanel;
    cxLabel5: TcxLabel;
    Panel7: TPanel;
    cxLabel6: TcxLabel;
    Panel8: TPanel;
    cxLabel7: TcxLabel;
    cxButtonEdit2: TcxButtonEdit;
    cxComboBox1: TcxComboBox;
    cxDateEdit1: TcxDateEdit;
    Panel9: TPanel;
    cxLabel8: TcxLabel;
    cxTextEdit4: TcxTextEdit;
    Panel10: TPanel;
    cxLabel9: TcxLabel;
    cxTextEdit5: TcxTextEdit;
    Panel11: TPanel;
    cxLabel10: TcxLabel;
    Panel12: TPanel;
    cxLabel11: TcxLabel;
    cxCurrencyEdit1: TcxCurrencyEdit;
    cxCurrencyEdit2: TcxCurrencyEdit;
    Panel13: TPanel;
    cxLabel12: TcxLabel;
    ComboKDV: TcxComboBox;
    Panel14: TPanel;
    cxLabel13: TcxLabel;
    cxComboBox3: TcxComboBox;
    Panel15: TPanel;
    cxLabel14: TcxLabel;
    cxComboBox4: TcxComboBox;
    dxMemData1ckdvtut: TCurrencyField;
    cxGrid1DBTableView1ckdvtut: TcxGridDBColumn;
    Panel28: TPanel;
    Panel29: TPanel;
    cxLabel23: TcxLabel;
    cxLabel40: TcxLabel;
    cxLabel42: TcxLabel;
    Panel30: TPanel;
    cxCurrencyEdit9: TcxCurrencyEdit;
    cxCurrencyEdit10: TcxCurrencyEdit;
    cxLabel15: TcxLabel;
    cxCurrencyEdit3: TcxCurrencyEdit;
    cxCurrencyEdit4: TcxCurrencyEdit;
    cxLabel16: TcxLabel;
    cxCurrencyEdit5: TcxCurrencyEdit;
    Panel17: TPanel;
    PopupMenu1: TPopupMenu;
    SatrSil1: TMenuItem;
    ftbaslik: TFDQuery;
    fisno: TFDQuery;
    fisnoID: TIntegerField;
    ftdetay: TFDQuery;
    cxTextEdit1: TcxTextEdit;
    dxMemData1ctoplam: TCurrencyField;
    cxGrid1DBTableView1ctoplam: TcxGridDBColumn;
    dxMemData2: TdxMemData;
    dxMemData2sno: TIntegerField;
    dxMemData2toplam: TFloatField;
    dxMemData2kdvtoplam: TFloatField;
    dxMemData2geneltoplam: TFloatField;
    Panel2: TPanel;
    cxLabel17: TcxLabel;
    ComboOdeme: TcxImageComboBox;
    dxMemData1kasa_kodu: TStringField;
    dxMemData1kasa_id: TIntegerField;
    cxGrid1DBTableView1kasa_id: TcxGridDBColumn;
    F5KaydetTus: TcxButton;
    kasakayit: TFDQuery;
    dxMemData1kasareh_id: TIntegerField;
    DataSource2: TDataSource;
    Panel18: TPanel;
    cxButton2: TcxButton;
    F8BelgeyeDevamTus: TcxButton;
    cxButton4: TcxButton;
    BeditProje: TcxButtonEdit;
    LabelProje: TcxLabel;
    dxMemData1taksit: TSmallintField;
    Labeltaksit: TcxLabel;
    dxMemData1ProjeId: TIntegerField;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure dxMemData1CalcFields(DataSet: TDataSet);
    procedure cxButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure cxButtonEdit2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormShow(Sender: TObject);
    procedure cxComboBox1PropertiesChange(Sender: TObject);
    procedure SatrSil1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure F5KaydetTusClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dxMemData1AfterPost(DataSet: TDataSet);
    procedure cxButton2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure F8BelgeyeDevamTusClick(Sender: TObject);
    procedure cxButton4Click(Sender: TObject);
    procedure BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ComboOdemePropertiesCloseUp(Sender: TObject);

  private
  procedure baslikekle;
  procedure detayekle;
  procedure temizle;
  procedure hesapla;
  procedure kontrol;
  procedure fisnobul;
  procedure kasayukle;
  Procedure kasakaydet;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  belgegirisdlg: Tbelgegirisdlg;

implementation

{$R *.dfm}

uses PrjConst,Utablo, FetaKurulusSiniflari, fetautil,LocOnfly, UGirisKutusuEx, UVeriMotor;

var
  k:smallint;
  cr_id,s_no, VarsDepo:integer;
  son_kod,m_id:string;
 function FStrToCurrDef(Para:string;Def: Currency):Currency;
begin
Para:=StringReplace(Para,',',FormatSettings.Decimalseparator,[rfReplaceAll]);
Para:=StringReplace(Para,'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
Result := StrToCurrDef(Para, Def);
end;

Procedure Tbelgegirisdlg.kasakaydet;
begin

end;
Procedure Tbelgegirisdlg.kasayukle;
begin
  {kasa.close;
  kasa.sql.clear;
  kasa.sql.add('Select * from KASALAR where kur='''+cxcombobox3.text+''' and KASATUR<>196');
  kasa.open;
  kasa.First;
  ComboOdeme.properties.Items.Clear;
  ComboOdeme.properties.Items.add('Açık Hesap');
  TcxComboBoxProperties(cxGrid1DBTableView1kasa_adi.properties).Items.Add('Açık Hesap');
    while not  kasa.eof  do begin
      ComboOdeme.properties.Items.add(kasa.Fields[2].AsString) ;
      TcxComboBoxProperties(cxGrid1DBTableView1kasa_adi.properties).Items.Add(kasa.Fields[2].AsString);
      kasa.Next;
    end;
  ComboOdeme.ItemIndex:=-1;   }
  ComboOdeme.Properties.Items := Tablo.imgComboboxInit( 'SELECT 0 AS DEGER, ''Açık Hesap'' AS ACIKLAMA, 0 as TAG union all '+
     'Select DEGER=ID,ACIKLAMA=KASAADI, 2 as TAG  from KASALAR  WHERE DURUM=1 AND KASATUR in (100,195) AND SUBEID=-1 union all '+
     'Select DEGER=ID,ACIKLAMA=ADI, 1 as TAG  from KREDIKARTI  WHERE DURUM=1 AND SUBEID=-1 ORDER BY 3,2',True).Items;

  tcximagecomboboxProperties(cxGrid1DBTableView1kasa_id.Properties).Items := ComboOdeme.Properties.Items;
end;
Procedure Tbelgegirisdlg.fisnobul;
begin
  fisno.Close;
  fisno.SQL.Clear;
  fisno.SQL.Add('select max(ID) as ID from FATBASLIK');
  fisno.Open;
end;
Procedure Tbelgegirisdlg.kontrol;
begin
 k:=0;
  if cxbuttonedit1.Text='' then Application.MessageBox(pchar(DMusteri_kod_girilmemis),pchar(DBos_alan),MB_ICONINFORMATION+MB_ok)
  else
  if cxbuttonedit2.Text='' then Application.MessageBox(pchar(DMasraf_kod_girilmemis),pchar(DBos_alan),MB_ICONINFORMATION+MB_ok)
  else
  if cxcurrencyedit2.Value=0 then Application.MessageBox(pchar(DFiyat_girilmemis),pchar(DBos_alan),MB_ICONINFORMATION+MB_ok)
  else
  if ComboOdeme.Text='' then Application.MessageBox(pchar(DOdeme_girilmemis),pchar(DBos_alan),MB_ICONINFORMATION+MB_ok)
  else  begin
  k:=1;
  end;

  end;

Procedure Tbelgegirisdlg.hesapla;
var
toplam,kdv10,kdv20,kdv1,gtoplam:double;
begin
  toplam:=0;
  kdv10:=0;
  kdv20:=0;
  dxmemdata1.DisableControls;
  dxmemdata1.First;
   While not dxmemdata1.eof Do begin
        toplam:=toplam+dxmemdata1ctutar.AsFloat;
        if dxmemdata1kdv.AsString='10' then kdv10:=kdv10+dxmemdata1ckdvtut.AsFloat;
        if dxmemdata1kdv.AsString='20' then kdv20:=kdv20+dxmemdata1ckdvtut.AsFloat;
        if dxmemdata1kdv.AsString='1' then kdv1:=kdv1+dxmemdata1ckdvtut.AsFloat;
        dxmemdata1.Next;
   end;

  cxcurrencyedit9.Value:=toplam;
  cxcurrencyedit10.Value:=kdv1;
  cxcurrencyedit3.Value:=kdv10;
  cxcurrencyedit4.Value:=kdv20;
  cxcurrencyedit5.Value:=toplam+kdv1+kdv10+kdv20;
    if kdv1=0 then begin
    cxcurrencyedit10.Visible:=false;
    cxlabel40.Visible:=false;
    end
    else begin
    cxcurrencyedit10.Visible:=true;
    cxlabel40.Visible:=true;
    end;
      if kdv10=0 then begin
      cxcurrencyedit3.Visible:=false;
      cxlabel42.Visible:=false;
      end
      else begin
      cxcurrencyedit3.Visible:=true;
      cxlabel42.Visible:=true;
      end;
  dxmemdata1.EnableControls;

end;

procedure Tbelgegirisdlg.SatrSil1Click(Sender: TObject);
var
  noal:string;
  a:integer;
begin
  dxmemdata1.Delete;
  { if dxmemdata1baslik.AsInteger=0 then begin

      noal:=dxmemdata1s_no.AsString;
      dxmemdata1.First;
      while not dxmemdata1.Eof do begin
        if dxmemdata1s_no.AsString=noal then begin
            dxmemdata2.Locate('sno',noal,[]);
            dxmemdata2.edit;
            dxmemdata2toplam.AsFloat:=dxmemdata2toplam.AsFloat-dxmemdata1ctutar.AsFloat;
            dxmemdata2kdvtoplam.AsFloat:=dxmemdata2kdvtoplam.AsFloat-dxmemdata1ckdvtut.AsFloat;
            dxmemdata2geneltoplam.AsFloat:=dxmemdata2geneltoplam.AsFloat-dxmemdata1ctoplam.AsFloat;
            dxmemdata2.Post;
            dxmemdata1.Delete;
            a:=1;
        end;
        if a=0 then dxmemdata1.Next;
        a:=0;
      end;
    end;
      if dxmemdata1baslik.AsInteger=1 then begin
         noal:=dxmemdata1s_no.AsString;
         dxmemdata2.Locate('sno',noal,[]);
          dxmemdata2.edit;
          dxmemdata2toplam.AsFloat:=dxmemdata2toplam.AsFloat-dxmemdata1ctutar.AsFloat;
          dxmemdata2kdvtoplam.AsFloat:=dxmemdata2kdvtoplam.AsFloat-dxmemdata1ckdvtut.AsFloat;
          dxmemdata2geneltoplam.AsFloat:=dxmemdata2geneltoplam.AsFloat-dxmemdata1ctoplam.AsFloat;
          dxmemdata2.Post;
          dxmemdata1.Delete;
      end;
  if dxmemdata1.RecordCount>0 then
    hesapla
  else begin
    cxcurrencyedit9.Value:=0;
    cxcurrencyedit10.Value:=0;
    cxcurrencyedit3.Value:=0;
    cxcurrencyedit4.Value:=0;
    cxcurrencyedit5.Value:=0;
  end; }
end;

procedure Tbelgegirisdlg.temizle;
begin
  cxbuttonedit1.Clear;
  cxtextedit2.Clear;
  cxtextedit3.Clear;
  cxcombobox1.ItemIndex:=0;
  cxbuttonedit2.Clear;
  cxtextedit4.Clear;
  cxtextedit5.Clear;
  cxcurrencyedit1.Value:=1;
  cxcurrencyedit2.Value:=0;

end;
procedure Tbelgegirisdlg.detayekle;
var
   k1,k2,k3:double;
begin
 kontrol;
 if k=1 then begin
       if cxcombobox4.ItemIndex=0 then begin
          {if strtoint(comboKDV.Text) >=10 then begin
            if formatsettings.decimalseparator='.' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value/strtofloat('1.'+comboKDV.Text);
            if formatsettings.decimalseparator=',' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value/strtofloat('1,'+comboKDV.Text);
            end;
          if strtoint(comboKDV.Text) <10 then begin
            if formatsettings.decimalseparator=',' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value /strtofloat('1,0'+comboKDV.Text);
            if formatsettings.decimalseparator='.' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value /strtofloat('1.0'+comboKDV.Text);
            end;  }
          //25.09.2023 ao
          cxcurrencyedit2.Value:=cxcurrencyedit2.Value/((100.0+StrToInt(comboKDV.Text))/100.0);
       end;
    if cxbuttonedit1.Text<>cxtextedit1.Text then s_no:=s_no+1;
    if cxbuttonedit1.Text<>cxtextedit1.Text then s_no:=s_no;

    if cr_id<1 then begin
       showmessage('Cari için müşteri seçimi yapılmalıdır!');
       exit;
    end;

    dxmemdata1.Append;
    dxmemdata1s_no.AsInteger:=s_no;
//    dxmemdata1baslik.AsInteger:=0;
    dxmemdata1cr_id.AsInteger:=cr_id;
    dxmemdata1m_id.AsString:=m_id;
    dxmemdata1cr_kod.AsString:=cxbuttonedit1.Text;
    dxmemdata1cr_ad.AsString:=cxtextedit2.Text;
    dxmemdata1belge_no.AsString:=cxtextedit3.Text;
    dxmemdata1belgetip.AsString:=cxcombobox1.Text;
    dxmemdata1belgetarih.Value:=cxdateedit1.Date;
    dxmemdata1mkod.AsString:=cxbuttonedit2.Text;
    dxmemdata1mad.AsString:=cxtextedit4.Text;
    dxmemdata1aciklama.AsString:=cxtextedit5.Text;
    dxmemdata1adet.AsFloat:=cxcurrencyedit1.Value;
    dxmemdata1b_fiyat.AsFloat:=cxcurrencyedit2.Value;
    dxmemdata1kdv.AsString:=comboKDV.Text;
    dxmemdata1ProjeId.asinteger := BeditProje.Tag;
    dxmemdata1p_birim.AsString:=cxcombobox3.Text;
    dxmemdata1kdvdrm.AsString:=cxcombobox4.Text;
    dxmemdata1kasa_id.asinteger:=ComboOdeme.editvalue;
    if ComboOdeme.Properties.Items[ComboOdeme.ItemIndex].Tag=1 then begin
       dxmemdata1kasa_kodu.asstring:='V';
       dxMemData1taksit.asinteger := StrToIntDef(Labeltaksit.Caption, 1)
    end else
       dxmemdata1kasa_kodu.asstring:='K';
    dxmemdata1kasa_id.asinteger:=ComboOdeme.editvalue;
    //dxmemdata1kasareh_id.AsString:=kasaREHBERID.AsString;
//    if cxbuttonedit1.Text=cxtextedit1.Text then dxmemdata1baslik.AsInteger:=1;
//    if cxbuttonedit1.Text<>cxtextedit1.Text then dxmemdata1baslik.AsInteger:=0;
//    if cxcombobox1.ItemIndex=2 then dxmemdata1baslik.AsInteger:=2;
    dxmemdata1.Post;
    //ComboOdeme.enabled:=false;
    cxtextedit1.Text:=cxbuttonedit1.Text;
    cxbuttonedit2.Clear;
    cxtextedit4.Clear;
    cxtextedit5.Clear;
    cxcurrencyedit2.Value:=0;
    cxcurrencyedit1.Value:=1;
    hesapla;
    cxbuttonedit2.SetFocus;
 end;

end;
procedure Tbelgegirisdlg.baslikekle;


begin
 kontrol;
 if k=1 then begin
       if cxcombobox4.ItemIndex=0 then begin
          if strtoint(comboKDV.Text) >=10 then begin
            if formatsettings.decimalseparator='.' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value/strtofloat('1.'+comboKDV.Text);
            if formatsettings.decimalseparator=',' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value/strtofloat('1,'+comboKDV.Text);
            end;
          if strtoint(comboKDV.Text) <10 then begin
            if formatsettings.decimalseparator=',' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value /strtofloat('1,0'+comboKDV.Text);
            if formatsettings.decimalseparator='.' then cxcurrencyedit2.Value:=cxcurrencyedit2.Value /strtofloat('1.0'+comboKDV.Text);
            end;
       end;
    if cxbuttonedit1.Text<>cxtextedit1.Text then s_no:=s_no+1;
    if cxbuttonedit1.Text<>cxtextedit1.Text then s_no:=s_no;
    dxmemdata1.Append;
    dxmemdata1s_no.AsInteger:=s_no;
//    dxmemdata1baslik.AsInteger:=0;
    dxmemdata1cr_id.AsInteger:=cr_id;
    dxmemdata1m_id.AsString:=m_id;
    dxmemdata1cr_kod.AsString:=cxbuttonedit1.Text;
    dxmemdata1cr_ad.AsString:=cxtextedit2.Text;
    dxmemdata1belge_no.AsString:=cxtextedit3.Text;
    dxmemdata1belgetip.AsString:=cxcombobox1.Text;
    dxmemdata1belgetarih.Value:=cxdateedit1.Date;
    dxmemdata1mkod.AsString:=cxbuttonedit2.Text;
    dxmemdata1mad.AsString:=cxtextedit4.Text;
    dxmemdata1aciklama.AsString:=cxtextedit5.Text;
    dxmemdata1adet.AsFloat:=cxcurrencyedit1.Value;
    dxmemdata1b_fiyat.AsFloat:=cxcurrencyedit2.Value;
    dxmemdata1kdv.AsString:=comboKDV.Text;
    dxmemdata1p_birim.AsString:=cxcombobox3.Text;
    dxmemdata1kdvdrm.AsString:=cxcombobox4.Text;
    dxmemdata1kasa_id.asinteger:=ComboOdeme.editvalue;
    dxmemdata1ProjeId.asinteger:=BeditProje.editvalue;
    if ComboOdeme.Properties.Items[ComboOdeme.ItemIndex].Tag=1 then begin
       dxmemdata1kasa_kodu.asstring:='V';
       dxMemData1taksit.asinteger := StrToIntDef(Labeltaksit.Caption, 1)
    end else
       dxmemdata1kasa_kodu.asstring:='K';
    dxmemdata1kasa_id.asinteger:=ComboOdeme.editvalue;
    //dxmemdata1kasareh_id.AsString:=kasaREHBERID.AsString;
//    if cxbuttonedit1.Text=cxtextedit1.Text then dxmemdata1baslik.AsInteger:=1;
//    if cxbuttonedit1.Text<>cxtextedit1.Text then dxmemdata1baslik.AsInteger:=0;
//    if cxcombobox1.ItemIndex=2 then dxmemdata1baslik.AsInteger:=2;

    dxmemdata1.Post;
    cxtextedit1.Text:=cxbuttonedit1.Text;
    //ComboOdeme.enabled:=true;
    temizle;
    hesapla;
    cxbuttonedit1.SetFocus;
 end;
end;

procedure Tbelgegirisdlg.F5KaydetTusClick(Sender: TObject);
var
   etiketler, bilgiler: TArrayOfString;
   fisnumarasi, OncekiFirma, KasaKayitID, KasaTur:integer;
   sqltext, OncekiBelgeNo,OncekiBelgeTip:string;
   Tutar, KDV, Toplam : Currency;
  function YeniKasaKaydet:integer;
  begin
    kasakayit.append;
    if dxmemdata1kasa_kodu.asstring='K' then
       kasakayit.fieldbyname('TUR').asinteger:=31
    else //kredikartı
       kasakayit.fieldbyname('TUR').asinteger:=35;
    kasakayit.fieldbyname('ISLEMTARIHI').value:=dxmemdata1belgetarih.value;
    kasakayit.fieldbyname('PLANTARIHI').value:=dxmemdata1belgetarih.value;
    kasakayit.fieldbyname('BELGENO').asstring:=dxmemdata1belge_no.asstring;
    kasakayit.fieldbyname('REHBERID').asinteger:=dxmemdata1cr_id.AsInteger;//dxmemdata1kasareh_id.asinteger;
    kasakayit.fieldbyname('HESAPID').asinteger:=dxmemdata1kasa_id.asinteger;
    kasakayit.fieldbyname('BORC').asfloat:=dxmemdata1ctoplam.AsFloat;
    kasakayit.fieldbyname('ALACAK').asfloat:=0;
    kasakayit.fieldbyname('KUR').asstring:=dxmemdata1p_birim.AsString;
    kasakayit.fieldbyname('HESAPTURU').asstring:=dxmemdata1kasa_kodu.asstring;//'K';
    kasakayit.fieldbyname('DOVIZ_TUTARI').asfloat:=dxmemdata1ctoplam.AsFloat;
    kasakayit.fieldbyname('DOVIZ_KURU').asstring:=dxmemdata1p_birim.AsString;
    kasakayit.fieldbyname('FATURAID').asinteger := fisnumarasi;
    Tablo.TablodanSorguAc(1, ' select KASATUR from KASALAR where ID ='+dxmemdata1kasa_id.AsString);
    kasakayit.fieldbyname('KASA').asinteger := Tablo.Query1.Fields[0].AsInteger;
    kasakayit.fieldbyname('EKLEYEN').asstring:=kullanan;
    kasakayit.fieldbyname('EKLEMETARIHI').value:=tablo.genini.buguntrhsaat;
    kasakayit.fieldbyname('DEGISTIREN').AsString:=kullanan;
    kasakayit.fieldbyname('DEGISTIRMETARIHI').Value:=tablo.genini.buguntrhsaat;
    kasakayit.post;
    Result := kasakayit.FieldByName('ID').AsInteger;

    if dxmemdata1kasa_kodu.asstring='V' then
       Tablo.KrediKartiKaydet(35,dxmemdata1kasa_id.asinteger, kasakayit.FieldByName('ID').AsInteger, dxMemData1taksit.asinteger, dxmemdata1belgetarih.value, dxmemdata1ctoplam.AsFloat,
             dxmemdata1p_birim.AsString, dxmemdata1aciklama.AsString);

  end;

  Procedure FaturaOlustur;
  begin
              //Yeni belge geldi. Önceki belgeye toplamları atalım
              KasaKayitID := 0;
              if OncekiFirma <> 0 then //İlk belge değilse
                 // Toplamlar sunucuda (sp_Api_Belge_ToplamHesapla_Json). Burada Pascal'da
                 //   biriktirilen Tutar/KDV/Toplam yaziliyordu; iskonto/OTV/KDV muafiyeti
                 //   ve gercek doviz karsiligi hesaba girmiyor, DOVIZ_TUTARI'na TL toplam
                 //   yaziliyordu (SP/TOPLAM_FORMUL_KARSILASTIRMA.md).
                 Tablo.BelgeToplamHesapla(fisnumarasi);
              OncekiFirma := dxmemdata1cr_id.AsInteger;
              OncekiBelgeTip := dxmemdata1belgetip.AsString;
              OncekiBelgeNo := dxmemdata1belge_no.AsString;
              Tutar := 0; KDV:=0; Toplam:=0;

              dxmemdata2.Locate('sno',dxmemdata1s_no.AsString,[]);


              ftbaslik.Insert;
              ftbaslik.fieldbyname('TARIH').value:=cxdateedit1.Date;
              if dxmemdata1belgetip.AsString='Fatura' then
                 ftbaslik.fieldbyname('TUR').AsString:='11'
              else if dxmemdata1belgetip.AsString='Fiş' then
                 ftbaslik.fieldbyname('TUR').AsString:='12'
              else if dxmemdata1belgetip.AsString='Tahakkuk' then
                 ftbaslik.fieldbyname('TUR').AsString:='13';
              ftbaslik.fieldbyname('TIPI').AsString:='1';

              {if (dxmemdata1baslik.AsInteger=0) and (dxmemdata1belgetip.AsString='Fatura') then ftbaslik.fieldbyname('TUR').AsString:='11';
              if (dxmemdata1baslik.AsInteger=0) and (dxmemdata1belgetip.AsString='Fiş') then ftbaslik.fieldbyname('TUR').AsString:='12';
              if dxmemdata1baslik.AsInteger=0 then ftbaslik.fieldbyname('TIPI').AsString:='1';
              if (dxmemdata1baslik.AsInteger=2) and (cxcombobox1.ItemIndex=2) then ftbaslik.fieldbyname('TUR').AsString:='13';}
              ftbaslik.fieldbyname('REHBERID').AsInteger:=dxmemdata1cr_id.AsInteger;
              ftbaslik.fieldbyname('BASLIK').AsString:=Tablo.TabBizim.fieldbyname('FIRMA').AsString;
              ftbaslik.fieldbyname('ADRES').AsString:=Tablo.TabBizim.fieldbyname('ADRES').AsString;
              ftbaslik.fieldbyname('ILCE').AsString:=Tablo.TabBizim.fieldbyname('ILCE').AsString;
              ftbaslik.fieldbyname('IL').AsString:=Tablo.TabBizim.fieldbyname('IL').AsString;
              ftbaslik.fieldbyname('VD').AsString:=Tablo.TabBizim.fieldbyname('VERGIDAI').AsString;
              ftbaslik.fieldbyname('VNO').AsString:=Tablo.TabBizim.fieldbyname('VERGINO').AsString;


              ftbaslik.fieldbyname('GIRISDEPO').AsInteger := VarsDepo;
              ftbaslik.fieldbyname('FATURATARIH').Value := dxmemdata1belgetarih.value;
              ftbaslik.fieldbyname('FATURANO').AsString := dxmemdata1belge_no.AsString;
              //ftbaslik.fieldbyname('PROJEID').AsInteger := dxmemdata1ProjeId.asinteger;

              ftbaslik.fieldbyname('KDVDURUM').AsString:='Hariç';
{              ftbaslik.fieldbyname('FATURA_MATRAHI').AsFloat:=dxmemdata2toplam.AsFloat;
              ftbaslik.fieldbyname('KDV_TUTARI').AsFloat:=dxmemdata2kdvtoplam.AsFloat;
              ftbaslik.fieldbyname('FATURA_TUTARI').AsFloat:=dxmemdata2geneltoplam.AsFloat;
              ftbaslik.fieldbyname('DOVIZ_TUTARI').AsFloat:=dxmemdata2geneltoplam.AsFloat;}
              Tablo.RehberEkBilgileriniGetir(dxmemdata1cr_id.AsInteger, 2, [RehVars_FiyatListeAdi,
                       RehVars_Stok_Vade, RehVars_GLN, RehVars_FiyatListeAdiAlis], etiketler,bilgiler);

              ftbaslik.FieldByName('FIYAT_LISTESI').Value := StrToIntDef( bilgiler[3],VarsAlisFiyatID);//VarsAlisFiyatID

              ftbaslik.fieldbyname('KUR').AsString:=dxmemdata1p_birim.AsString;
              ftbaslik.fieldbyname('RAPORDOVIZ').AsString:=dxmemdata1p_birim.AsString;
              ftbaslik.fieldbyname('FATURADOVIZI').AsString:=dxmemdata1p_birim.AsString;
              ftbaslik.fieldbyname('DOVIZ_CINSI').AsString:=dxmemdata1p_birim.AsString;
              ftbaslik.fieldbyname('DOVIZKUR').AsString:='1';

              ftbaslik.fieldbyname('EKSTREDEKULLAN').AsBoolean := False;

              ftbaslik.fieldbyname('ACIK_KAPALI').AsBoolean := ComboOdeme.Properties.Items[ComboOdeme.ItemIndex].Tag<>0;

              ftbaslik.fieldbyname('EKVERGI').AsString:='0';
              ftbaslik.fieldbyname('DURUM').AsString:='0';


              ftbaslik.fieldbyname('EKLEMETARIHI').Value:=tablo.genini.buguntrhsaat;
              ftbaslik.fieldbyname('EKLEYEN').AsString:=kullanan;
              ftbaslik.fieldbyname('DEGISTIREN').AsString:=kullanan;
              ftbaslik.fieldbyname('DEGISTIRMETARIHI').Value:=tablo.genini.buguntrhsaat;
              ftbaslik.fieldbyname('aciklama').AsString:=dxmemdata1aciklama.AsString;
              if dxmemdata1baslik.AsInteger=2 then ftbaslik.fieldbyname('MASRAFID').AsInteger:=dxmemdata1m_id.AsInteger;

              ftbaslik.Post;
              fisnobul;
              fisnumarasi:=fisnoID.AsInteger;
              if dxmemdata1kasa_id.AsInteger<>0 then begin //'Açık Hesap' değilse
                KasaKayitID := YeniKasaKaydet;
              end;
  end;

  procedure InsertYap;
  begin
          ftdetay.Insert;
          ftdetay.fieldbyname('FATBASID').AsInteger:=fisnumarasi;
          ftdetay.fieldbyname('REHBERID').AsInteger:=dxmemdata1cr_id.AsInteger;
          ftdetay.fieldbyname('TUR').AsInteger:=0;
          ftdetay.fieldbyname('URUNID').AsInteger:=dxmemdata1m_id.AsInteger;
          ftdetay.fieldbyname('ACIKLAMA').AsString:=dxmemdata1aciklama.AsString;
          ftdetay.fieldbyname('ADET').AsFloat:=dxmemdata1adet.AsFloat;
          ftdetay.fieldbyname('MF').AsInteger:=0;
          ftdetay.fieldbyname('BIRIM').AsInteger:=51;
          ftdetay.fieldbyname('MIKTAR').AsFloat:=dxmemdata1adet.AsFloat;
          ftdetay.fieldbyname('BIRIMFIYAT').AsFloat:=dxmemdata1b_fiyat.AsFloat;
          ftdetay.fieldbyname('TUTAR').AsFloat:=dxmemdata1ctutar.AsFloat;
          ftdetay.fieldbyname('KUR').AsString:=dxmemdata1p_birim.AsString;
          ftdetay.fieldbyname('ISKONTO').AsFloat:=0;
          ftdetay.fieldbyname('KDV').AsInteger:=dxmemdata1KDV.AsInteger;
          ftdetay.fieldbyname('MASRAFID').AsInteger:=dxmemdata1m_id.AsInteger;
          ftdetay.fieldbyname('DOVIZ_TUTARI').AsFloat:=dxmemdata1ctutar.AsFloat;
          ftdetay.fieldbyname('DOVIZ_KURU').AsString:=dxmemdata1p_birim.AsString;
          ftdetay.fieldbyname('EKLEMETARIHI').Value:=tablo.genini.buguntrhsaat;
          ftdetay.fieldbyname('DOVIZ_BIRIMFIYAT').AsFloat:=dxmemdata1b_fiyat.AsFloat;
          ftdetay.fieldbyname('EKLEYEN').asstring:=kullanan;
          ftdetay.fieldbyname('DOVIZKURDEGERI').AsString := '1';
          ftdetay.fieldbyname('PROJEID').AsInteger := dxmemdata1ProjeId.asinteger;
  end;
begin
  if dxmemdata1.RecordCount=0 then Application.MessageBox(pchar(DGiris_yapin),pchar(DBos_alan),MB_ICONINFORMATION+MB_ok)
  else begin
    ftbaslik.Open;
    ftdetay.Open;
    kasakayit.open;

    OncekiFirma:=0;
    OncekiBelgeNo:='0';
    OncekiBelgeTip:='0';
    Tutar := 0; KDV:=0; Toplam:=0;
    dxmemdata1.First;
    While not dxmemdata1.eof Do begin
          //if (dxmemdata1baslik.AsInteger=0) or (dxmemdata1baslik.AsInteger=2) then begin
          if (OncekiFirma<>dxmemdata1cr_id.AsInteger)or(OncekiBelgeTip<>dxmemdata1belgetip.AsString)or(OncekiBelgeNo<>dxmemdata1belge_no.AsString) then
              FaturaOlustur
          else begin
              if dxmemdata1kasa_id.AsInteger<>0 then begin //'Açık Hesap' değilse

                if dxmemdata1kasa_kodu.asstring='K' then
                   KasaTur:=31
                else if dxmemdata1kasa_kodu.asstring='V' then
                   KasaTur:=35
                else
                   KasaTur:=0;
                if kasakayit.Locate('REHBERID;TUR;HESAPID',VarArrayOf([dxmemdata1cr_id.AsInteger,KasaTur,dxmemdata1kasa_id.asinteger]),[]) then begin
                  kasakayit.edit;
                  kasakayit.fieldbyname('BORC').asfloat:=kasakayit.fieldbyname('BORC').asfloat+dxmemdata1ctoplam.AsFloat;
                  kasakayit.fieldbyname('DOVIZ_TUTARI').asfloat:=kasakayit.fieldbyname('DOVIZ_TUTARI').asfloat+dxmemdata1ctoplam.AsFloat;
                  kasakayit.post;
                end else begin
                  KasaKayitID := YeniKasaKaydet;
                end;
              end;
          end;

          InsertYap;

          Tutar:=Tutar+dxmemdata1ctutar.AsFloat;
          KDV:=KDV+dxmemdata1ckdvtut.AsFloat;
          Toplam:=Toplam+dxmemdata1ctoplam.AsFloat;

          ftdetay.Post;
          dxmemdata1.Next;
      end;
      //Son belge bitince toplamları yazalım
      Tablo.BelgeToplamHesapla(fisnumarasi);

     Application.MessageBox(pchar(DKayit_yapildi),pchar(Kaydet),MB_ICONINFORMATION+MB_ok);
     dxmemdata1.Close;
     dxmemdata2.close;
     ftbaslik.close;
     ftdetay.close;
     kasakayit.close;
     dxmemdata1.Open;
     dxmemdata2.open;
     //ComboOdeme.enabled:=true;
     hesapla;
     s_no:=0;
  end;
end;

procedure Tbelgegirisdlg.BeditProjePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   Tablo.EditButtonaPROJEIDGonder(BEditProje, nil, AButtonIndex,ProjeSecimi, cr_id);
end;

procedure Tbelgegirisdlg.ComboOdemePropertiesCloseUp(Sender: TObject);
var Taksit:variant;
begin
   if ComboOdeme.Properties.Items[ComboOdeme.ItemIndex].Tag=1 then begin
      Taksit := 1;
      TGirisKutusuEx.BilgiAlEx(BGYeni_bilgi_girisi, TGirdiDenetimleri.Create.Edit('Taksit sayısını girin', @Taksit));
      Labeltaksit.Caption := VarToStr(Taksit);
   end;
end;

procedure Tbelgegirisdlg.cxButton2Click(Sender: TObject);
begin
  temizle;
end;

procedure Tbelgegirisdlg.F8BelgeyeDevamTusClick(Sender: TObject);
begin
  detayekle;
end;

procedure Tbelgegirisdlg.cxButton4Click(Sender: TObject);
begin
  baslikekle;
end;

procedure Tbelgegirisdlg.cxButtonEdit1PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  Id: Integer;
  Kodu, Ad:string;
begin
  Id := Tablo.RehberAra_IDGetir(-1);
  if Id<0 then
     Id:=0;
  Kodu := Tablo.AciklamaGetir('REHBER', 'KOD', Id);
  Ad := Tablo.AciklamaGetir('REHBER', 'FIRMA', Id);
  cr_id:=id;
  cxbuttonedit1.Text:=Kodu;
  cxtextedit2.Text:=Ad;
  cxtextedit3.SetFocus;
end;

procedure Tbelgegirisdlg.cxButtonEdit2PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
var
  MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
  i : SmallInt;

begin
  if Tablo.MasrafMerkeziSecimEkrani(0, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
     cxbuttonedit2.Text:=MASRAFKODU;
     cxtextedit4.Text:=MASRAFMERKEZI;
     m_id:=MASRAFID;
     cxtextedit5.SetFocus;
  end;
end;

procedure Tbelgegirisdlg.cxComboBox1PropertiesChange(Sender: TObject);
begin
if cxcombobox1.ItemIndex=0 then cxcombobox4.ItemIndex:=0;
if cxcombobox1.ItemIndex=1 then cxcombobox4.ItemIndex:=1;
end;

procedure Tbelgegirisdlg.dxMemData1AfterPost(DataSet: TDataSet);
begin
  {dxmemdata2.Locate('sno',s_no,[]);
  if dxmemdata2sno.AsString=dxmemdata1s_no.AsString then begin
    dxmemdata2.edit;
  //  dxmemdata2.FieldByName('sno').AsInteger:=dxmemdata1.FieldByName('s_no').AsInteger;
    dxmemdata2toplam.AsFloat:=dxmemdata2toplam.AsFloat+dxmemdata1ctutar.AsFloat;
    dxmemdata2kdvtoplam.AsFloat:=dxmemdata2kdvtoplam.AsFloat+dxmemdata1ckdvtut.AsFloat;
    dxmemdata2geneltoplam.AsFloat:=dxmemdata2geneltoplam.AsFloat+dxmemdata1ctoplam.AsFloat;
    dxmemdata2.Post;
  end;

  if dxmemdata2sno.AsString<>dxmemdata1s_no.AsString then begin
    dxmemdata2.Append;

    dxmemdata2.FieldByName('sno').AsInteger:=dxmemdata1.FieldByName('s_no').AsInteger;
    dxmemdata2toplam.AsFloat:=dxmemdata1ctutar.AsFloat;
    dxmemdata2kdvtoplam.AsFloat:=dxmemdata2kdvtoplam.AsFloat+dxmemdata1ckdvtut.AsFloat;
    dxmemdata2geneltoplam.AsFloat:=dxmemdata2geneltoplam.AsFloat+dxmemdata1ctoplam.AsFloat;
    dxmemdata2.Post;
  end;}

end;

procedure Tbelgegirisdlg.dxMemData1CalcFields(DataSet: TDataSet);
begin
dxmemdata1ctutar.AsFloat:=dxmemdata1adet.AsFloat * dxmemdata1b_fiyat.AsFloat;
dxmemdata1ckdvtut.AsFloat:=(dxmemdata1ctutar.AsFloat * dxmemdata1kdv.AsFloat/ 100 );
dxmemdata1ctoplam.AsFloat:=dxmemdata1ckdvtut.AsFloat + dxmemdata1ctutar.AsFloat;
end;

procedure Tbelgegirisdlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
action:=Cafree;
end;

procedure Tbelgegirisdlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    CanClose := (dxmemdata1.RecordCount<1)or((dxmemdata1.RecordCount>0)and(Application.MessageBox(pchar(DKaydedilmedi_cikis_olacakmi),pchar(Onay),MB_YESNO)=IDYES));

end;

procedure Tbelgegirisdlg.FormCreate(Sender: TObject);
begin
    LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
    ftdetay.Connection:=Tablo.FDCnn;
    ftbaslik.Connection:=Tablo.FDCnn;
    fisno.Connection:=Tablo.FDCnn;

    Tablo.GridTurkcelestir;
    ComboKDV.Text := '20';
end;

procedure Tbelgegirisdlg.FormDestroy(Sender: TObject);
begin
    belgegirisdlg:=nil;
end;

procedure Tbelgegirisdlg.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (key=VK_F9) then cxbutton4.Click
  else if (key=VK_F8) then  F8BelgeyeDevamTus.Click
  else if (key=VK_F5) then F5KaydetTus.Click;
end;

procedure Tbelgegirisdlg.FormShow(Sender: TObject);
begin
  Tablo.TablodanSorguAc(1,'select '+DbUst(1)+'ID from DEPOLAR where VARSAYILAN=1 and SUBEID=-1 '+DbSinir(1));
  VarsDepo := Tablo.Query1.Fields[0].AsInteger;
  s_no:=0;
  cxcombobox1.ItemIndex:=0;
  dxmemdata1.Open;
  dxmemdata2.Open;
  cxdateedit1.Date:=Tablo.GENINI.BugunTrhSaat;
  kasayukle;
end;

end.




