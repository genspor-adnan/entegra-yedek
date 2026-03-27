unit UTakvimOnay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, FireDAC.Comp.Client, cxCurrencyEdit, cxTextEdit, cxDBEdit, cxControls,
  cxContainer, cxEdit, cxLabel, cxGraphics, cxButtonEdit, cxDropDownEdit,
  cxCalendar, cxMaskEdit, cxImageComboBox, Buttons, ExtCtrls, StdCtrls,
  dxSkinsCore, ComCtrls, ToolWin, cxDBLabel, dxSkinLondonLiquidSky,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TTakvimOnayDlg = class(TForm)
    TabKasa: TFDQuery;
    DtsKasa: TDataSource;
    MemoKasa: TMemo;
    MemoCek: TMemo;
    MemoKredi: TMemo;
    MemoFat: TMemo;
    MemoPlan: TMemo;
    ToolBar1: TToolBar;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    ToolButton1: TToolButton;
    btnIptal: TToolButton;
    ToolBarAlt: TToolBar;
    NakitTus: TToolButton;
    HavaleTus: TToolButton;
    CekTus: TToolButton;
    SenetTus: TToolButton;
    MemoPersonel: TMemo;
    IptalTus: TToolButton;
    Panel1: TPanel;
    cxLabel1: TcxLabel;
    ComboTUR: TcxDBImageComboBox;
    cxLabel9: TcxLabel;
    ComboDURUM: TcxDBImageComboBox;
    cxLabel13: TcxLabel;
    cxDBDateEdit1: TcxDBDateEdit;
    cxDBLabel1: TcxDBLabel;
    cxLabel12: TcxLabel;
    EditMasrafKod: TcxButtonEdit;
    cxLabel10: TcxLabel;
    cxDBTextEdit5: TcxDBTextEdit;
    cxLabel5: TcxLabel;
    cxLabel2: TcxLabel;
    Panel2: TPanel;
    cxLabel14: TcxLabel;
    cxLabel3: TcxLabel;
    EditCariKod: TcxButtonEdit;
    cxLabel4: TcxLabel;
    EditCariAd: TcxTextEdit;
    EditREHBERID: TcxDBTextEdit;
    EditMASRAFID: TcxDBTextEdit;
    Panel3: TPanel;
    cxLabel6: TcxLabel;
    cxLabel7: TcxLabel;
    EditHesapAdi: TcxTextEdit;
    EditHesapKodu: TcxButtonEdit;
    cxDBTextEdit2: TcxDBTextEdit;
    ComboBoxODEMEYERI: TcxDBImageComboBox;
    Label17: TcxLabel;
    cxLabel8: TcxLabel;
    EditTutar: TcxDBCurrencyEdit;
    cxDBComboBox1: TcxDBComboBox;
    cxLabel15: TcxLabel;
    EditHESAPID: TcxDBTextEdit;
    PanelMusBankaHesap: TPanel;
    cxLabel17: TcxLabel;
    EditMusHesapKodu: TcxButtonEdit;
    EditMUSTERIHESAPID: TcxDBTextEdit;
    cxLabel16: TcxLabel;
    EditMusHesapAdi: TcxTextEdit;
    cxButtonEdit1: TcxButtonEdit;
    cxLabel18: TcxLabel;
    LabelMasrafAd: TcxLabel;
    procedure cxDBButtonEdit1PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure btnIptalClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure NakitTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DtsKasaStateChange(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure TabKasaAfterOpen(DataSet: TDataSet);
    procedure EditMasrafKodPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure EditMusHesapKoduPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
     Sirano, TUR : SmallInt;
     procedure InitIslemler;
     
  end;

var
  TakvimOnayDlg: TTakvimOnayDlg;

implementation

uses Utablo, PrjConst,LocOnFly;

{$R *.dfm}

procedure TTakvimOnayDlg.btnIptalClick(Sender: TObject);
begin
   Close;
end;

procedure TTakvimOnayDlg.cxDBButtonEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR,KASAID,KASAKODU,KASAADI: String;
begin
   HESAPID := '-1';
   case ComboBoxODEMEYERI.ItemIndex of
     0 : if Tablo.KasaHesapEkrani(KASAID,KASAKODU,KASAADI,KUR) then begin
            TabKasa.Edit;
            TabKasa.FieldByName('HESAPID').AsString := KASAID;
            TabKasa.FieldByName('KUR').AsString := KUR;
            EditHesapKodu.Text := KASAKODU;
            EditHesapAdi.Text := KASAADI;
         end;
     1 : if Tablo.BankaHesapEkrani(35, HESAPID, HESAPKODU,HESAPNO, HESAPADI, KUR) then begin
            TabKasa.Edit;
            TabKasa.FieldByName('HESAPID').AsString := HESAPID;
            TabKasa.FieldByName('KUR').AsString := KUR;
            EditHesapKodu.Text := HESAPKODU;
            EditHesapAdi.Text := HESAPADI;
         end;
   end;
end;

procedure TTakvimOnayDlg.DtsKasaStateChange(Sender: TObject);
begin
   if DtsKasa.State = dsEdit then begin
      KaydetTus.visible := True;
      IptalTus.visible := True;
      SilTus.visible := False;
   end
   else begin
      KaydetTus.visible := False;
      IptalTus.visible := False;
      SilTus.visible := True;
   end
end;

procedure TTakvimOnayDlg.EditMasrafKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var MASRAFID, MASRAFKODU, MASRAFMERKEZI: string;
    i : SmallInt;
begin
   if TUR in [11,12,21,22,23,61] then
      i := 1
   else
      i := 0;

   if Tablo.MasrafMerkeziSecimEkrani(i, MASRAFID, MASRAFKODU, MASRAFMERKEZI) then begin
      TabKasa.Edit;
      TabKasa.FieldByName('MASRAFID').AsString := MASRAFID;
      EditMasrafKod.Text := MASRAFKODU;
      LabelMasrafAd.Caption := MASRAFMERKEZI;
   end
end;

procedure TTakvimOnayDlg.EditMusHesapKoduPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var HESAPID, HESAPNO,HESAPKODU, HESAPADI, KUR : String;
begin
   HESAPID := TabKasa.FieldByName('REHBERID').AsString;
   if Tablo.BankaHesapEkrani(41, HESAPID, HESAPKODU,HESAPNO, HESAPADI, KUR) then begin
      TabKasa.Edit;
      TabKasa.FieldByName('MUSTERIHESAPID').AsString := HESAPID;
      EditMusHesapKodu.Text := HESAPNO;
      EditMusHesapAdi.Text := HESAPADI;
   end;
end;

procedure TTakvimOnayDlg.FormCreate(Sender: TObject);
begin
   if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TTakvimOnayDlg.InitIslemler;
    procedure DurumListele(List : TstringList);
     var I : SmallInt;
     begin
        ComboDURUM.Properties.Items.clear;
        for I := 0 to List.Count - 1 do begin
          ComboDURUM.Properties.Items.Add;
          ComboDURUM.Properties.Items[i].Description:=Copy(List.Strings[I],2,Length(List.Strings[I])-1);  //1Devam Ediyor
          ComboDURUM.Properties.Items[i].Value:=StrToInt(List.Strings[I][1]);
        end;
     end;
begin
   TabKasa.Close;
   if not(TUR  in [61, 71]) then begin   //plan giren / çýkan
      KaydetTus.Visible := False;
      //TabKasa.LockType := ltReadOnly;
    end else begin
      KaydetTus.Visible := True;
      //TabKasa.LockType := ltOptimistic;
    end;

   if TUR in [11,12,21,22,23,61] then
      EditTutar.DataBinding.DataField := 'BORC'
   else
      EditTutar.DataBinding.DataField := 'ALACAK';

   if not (TUR in [71,72]) then begin //Ödeme planý deðilse müþteri hesap bilgileri görünmesin
      TakvimOnayDlg.Height := TakvimOnayDlg.Height -  PanelMusBankaHesap.Height;
      PanelMusBankaHesap.visible := False;
   end;

   TabKasa.Params[0].Value := Sirano;
   case TUR of
    61,71,72 : TabKasa.SQL.Text := MemoPlan.Text+IntToStr(Sirano);
    73 : TabKasa.SQL.Text := MemoPersonel.Text+IntToStr(Sirano);
    23,33 : TabKasa.SQL.Text := MemoCek.Text+IntToStr(Sirano);
    58 : TabKasa.SQL.Text := MemoKredi.Text+IntToStr(Sirano);
    11,12,15,16 : TabKasa.SQL.Text := MemoFat.Text+IntToStr(Sirano);
    21,22,31,32 : TabKasa.SQL.Text := MemoKasa.Text+IntToStr(Sirano);
   end;
   TabKasa.Open;
end;

procedure TTakvimOnayDlg.IptalTusClick(Sender: TObject);
begin
   TabKasa.Cancel;
end;

procedure TTakvimOnayDlg.KaydetTusClick(Sender: TObject);
begin
   TabKasa.Post;
   TakvimOnayDlg.Tag := -1;
   Close;
end;

procedure TTakvimOnayDlg.NakitTusClick(Sender: TObject);
begin
   case TUR of
    71 :  TakvimOnayDlg.Tag := 21; //gelir planý --> nakit tahsilat
    72 :  TakvimOnayDlg.Tag := 31; //gider planý --> nakit ödeme
    else TakvimOnayDlg.Tag  := 0;
   end;
   close;
end;

procedure TTakvimOnayDlg.SilTusClick(Sender: TObject);
var s : string[20];
begin
   if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then begin

      case TUR of
          61,71,72 : s := 'KASA';
          23 : s := 'CEKLER';
          33 : s := 'SENETLER';
          58 : s := 'PLANKREDI';
          11,12,15,16 : s := 'FATBASLIK';
          21,22,31,32 : s := 'KASA';
      end;
      Tablo.Query1.SQL.Text := 'delete from '+s+' where ID= '+IntToStr(Sirano);
      Tablo.Query1.execSQL;
      Close;
   end;
end;

procedure TTakvimOnayDlg.TabKasaAfterOpen(DataSet: TDataSet);
begin
  //Ýþlem bölümü
   if TabKasa.FieldByName('MASRAFID').AsString<>'' then begin
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select KOD, AD from MASRAFGELIR where ID= '+TabKasa.FieldByName('MASRAFID').AsString;
       Tablo.Query1.Open;
       EditMasrafKod.Text := Tablo.Query1.Fields[0].AsString;
       LabelMasrafAd.Caption := Tablo.Query1.Fields[1].AsString;
   end;
  //Müþteri bölümü
   //RehberId den kod ve adý bulup getirelim
   if TabKasa.FieldByName('REHBERID').AsString<>'' then begin
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select KOD, FIRMA from REHBER where ID= '+TabKasa.FieldByName('REHBERID').AsString;
       Tablo.Query1.Open;
       EditCariKod.Text := Tablo.Query1.Fields[0].AsString;
       EditCariAd.Text := Tablo.Query1.Fields[1].AsString;
   end;

   if TabKasa.FieldByName('MUSTERIHESAPID').AsString<>'' then begin
       Tablo.Query1.Close;
       Tablo.Query1.SQL.Text := 'select HESAPNO as HESAPKODU, RTRIM(B.BANKAADI)+''/''+BS.SUBEADI as HESAPADI '+
                             ' from BANKAHESAPLAR BH '+
                             ' inner join BANKASUBELER BS on BS.ID = BH.BANKASUBELERID '+
                             ' inner join BANKALAR B on BS.BANKAKODU = B.BANKAKODU where BH.ID= '+TabKasa.FieldByName('MUSTERIHESAPID').AsString;
       Tablo.Query1.Open;
       EditMusHesapKodu.Text := Tablo.Query1.Fields[0].AsString;
       EditMusHesapAdi.Text := Tablo.Query1.Fields[1].AsString;
   end;
  //Bizim bölümümüz
   //HesapId den kod ve adý bulup getirelim
   if (TabKasa.FieldByName('HESAPTURU').AsString<>'')and(TabKasa.FieldByName('HESAPID').AsString<>'') then begin
       Tablo.Query1.Close;
       case TabKasa.FieldByName('HESAPTURU').AsString[1] of
         'B' : Tablo.Query1.SQL.Text := ' select HESAPKODU, HESAPADI from BANKAHESAPLAR  where ID='+TabKasa.FieldByName('HESAPID').AsString;
         'K' : Tablo.Query1.SQL.Text := ' select KASAKODU, KASAADI from KASALAR where ID='+TabKasa.FieldByName('HESAPID').AsString;
       end;
       Tablo.Query1.Open;
       EditHesapKodu.Text := Tablo.Query1.Fields[0].AsString;
       EditHesapAdi.Text := Tablo.Query1.Fields[1].AsString;
   end;
end;

end.

