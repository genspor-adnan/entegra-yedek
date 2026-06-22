unit UAcilisKaydi;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxControls, cxContainer, cxEdit, cxTextEdit, cxCurrencyEdit,
  ComCtrls, StdCtrls, Buttons, dxSkinsCore,  ToolWin, cxGraphics, cxDropDownEdit,
  cxCalendar, cxMaskEdit, cxLabel, DB, FireDAC.Comp.Client, cxImageComboBox,
  dxSkinLondonLiquidSky, cxLookAndFeels, cxLookAndFeelPainters, dxCore,
  cxDateUtils, dxSkinLiquidSky, cxDBEdit, Vcl.ExtCtrls, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light;

type
  TAcilisKaydiDlg = class(TForm)
    Label8: TcxLabel;
    Label10: TcxLabel;
    Label11: TcxLabel;
    EditAcik: TcxTextEdit;
    EditBorc: TcxCurrencyEdit;
    EditAlacak: TcxCurrencyEdit;
    Label1: TcxLabel;
    LabelId: TcxLabel;
    LabelKod: TcxLabel;
    LabelAd: TcxLabel;
    ComboKur: TcxComboBox;
    Label2: TcxLabel;
    ToolBar1: TToolBar;
    btnKaydet: TToolButton;
    ToolButton1: TToolButton;
    btnKapat: TToolButton;
    DateTimePickerOdemeBasl: TcxDateEdit;
    btnYeni: TToolButton;
    TabAcilis: TFDQuery;
    cxLabel1: TcxLabel;
    ComboTur: TcxImageComboBox;
    Panel1: TPanel;
    cxLabel4: TcxLabel;
    cxLabel6: TcxLabel;
    EditKulKur: TcxCurrencyEdit;
    EditYerelPara: TcxCurrencyEdit;
    procedure btnKaydetClick(Sender: TObject);
    procedure btnKapatClick(Sender: TObject);
    procedure btnYeniClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboKurPropertiesEditValueChanged(Sender: TObject);
    procedure EditKulKurKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditYerelParaKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    procedure YeniEkle(Doviz:String);
  public
    { Public declarations }
     Kur : String[10];
     Cagiran, Acilis_Devir : SmallInt; //1:Cari, 2:Kasa, 3 : Banka    1:acilis 2:devir
     KasaId : Integer;
     Kilit:Boolean;
  end;

var
  AcilisKaydiDlg: TAcilisKaydiDlg;

implementation

uses Utablo, UMesaj, UAnaForm,FetaKurulusSiniflari,PrjConst,LocOnFly;

{$R *.dfm}

var YeniKayit : Boolean;

procedure TAcilisKaydiDlg.btnKapatClick(Sender: TObject);
begin
   Close;
end;

procedure TAcilisKaydiDlg.FormCreate(Sender: TObject);
begin
  if CokluDilVar then LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TAcilisKaydiDlg.FormShow(Sender: TObject);
begin
  if Kilit then begin
     btnYeni.Enabled :=False;
     btnKaydet.Enabled :=False; ;
  end;

   ComboTur.EditValue := Acilis_Devir;

   EditBorc.Enabled := Acilis_Devir <> 0;
   EditAlacak.Enabled := Acilis_Devir <> 0;


   case Acilis_Devir of
    0 : Caption := 'Mutabakat Kaydı Ekranı';
    1 : Caption := 'Açılış Kaydı Ekranı';
    2 : Caption := 'Devir Kaydı Ekranı';
   end;

                //Tablo.TablodanSorguAc(5,'select K.ID from KASA K inner join BANKAHESAPLAR B on B.ID=K.HESAPID where K.TUR=1 and K.HESAPTURU=''B'' and B.HESAPKODU='''+Kod+''' ');
                //HESAPTURU:='B';
                //Tablo.TablodanSorguAc(5,'select K.ID from KASA K inner join KASALAR KS on KS.ID=K.HESAPID where K.TUR=1 and K.HESAPTURU=''K'' and KS.KASAKODU='''+Kod+''' ');
                //HESAPTURU:='K';
   btnYeni.visible := Cagiran=1;  //sadece müşteri için birden fazla açılış fişi olabilir, her para birimi için
   TabAcilis.Close;

   case Cagiran of
     0 : begin  // Mutabakat kaydı
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR, isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC,ALACAK,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where K.TUR='+IntToStr(Acilis_Devir)+' and ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else
              TabAcilis.SQL.Add(' REHBERID = '+LabelId.Caption);

           TabAcilis.SQL.Add(' order by 3 desc ');
         end;
     1 : begin  // Müşteri açılışı
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR, isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC,ALACAK,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where K.TUR='+IntToStr(Acilis_Devir)+' and ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else begin
              if Acilis_Devir = 0 then //mutabakat ise
                 TabAcilis.SQL.Add(' REHBERID = -99999')
              else
                 TabAcilis.SQL.Add(' REHBERID = '+LabelId.Caption);
           end;
           TabAcilis.SQL.Add(' order by 3 desc ');
         end;
     2 : begin // 2-Kasa
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR,isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC=ALACAK,ALACAK=BORC,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where K.TUR='+IntToStr(Acilis_Devir)+' and HESAPTURU=''K'' and ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else
              TabAcilis.SQL.Add(' HESAPID  = '+LabelId.Caption);
           TabAcilis.SQL.Add(' order by 3 desc ');
         end;
     3 : begin // 3-Banka açılışı
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR,isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC=ALACAK,ALACAK=BORC,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where K.TUR='+IntToStr(Acilis_Devir)+' and HESAPTURU=''B'' and ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else
              TabAcilis.SQL.Add(' HESAPID  = '+LabelId.Caption);
           TabAcilis.SQL.Add(' order by 3 desc ');
         end;
     4 :begin   //Kredi Kartı açılışı
          // ComboKur.RepositoryItem.Properties.ReadOnly:=True;
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR,isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC,ALACAK,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where K.TUR='+IntToStr(Acilis_Devir)+' and HESAPTURU=''V'' and ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else
              TabAcilis.SQL.Add(' HESAPID  = '+LabelId.Caption);
           TabAcilis.SQL.Add(' order by 3 desc ');
        end;
     5 :begin   //POS açılışı
          // ComboKur.RepositoryItem.Properties.ReadOnly:=True;
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR,isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC=ALACAK,ALACAK=BORC,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where K.TUR='+IntToStr(Acilis_Devir)+' and HESAPTURU=''P'' and ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else
              TabAcilis.SQL.Add(' HESAPID  = '+LabelId.Caption);
           TabAcilis.SQL.Add(' order by 3 desc ');
        end;
     6 :begin   //Rotatif Kredi açılışı
          // ComboKur.RepositoryItem.Properties.ReadOnly:=True;
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR,isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC=ALACAK,ALACAK=BORC,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else
              TabAcilis.SQL.Add(' K.ID  = '+LabelId.Caption);
           TabAcilis.SQL.Add(' order by 3 desc ');
        end;
     7 :begin   //masrafgelir açılışı
          // ComboKur.RepositoryItem.Properties.ReadOnly:=True;
           TabAcilis.SQL.Text := 'select top 1 isnull(ID,0), KUR,isnull(ISLEMTARIHI,'''+IntToStr(CariYil)+'-01-01''),BORC,ALACAK,DOVIZ_TUTARI,ACIKLAMA,ID from KASA K where ';
           if KasaId > 0 then
              TabAcilis.SQL.Add(' K.ID = '+IntToStr(KasaId))
           else
              TabAcilis.SQL.Add(' MASRAFID  = '+LabelId.Caption);
           TabAcilis.SQL.Add(' order by 3 desc ');
        end;
   end;
   TabAcilis.Open;


   if TabAcilis.RecordCount > 0 then begin
       YeniKayit := False;
       DateTimePickerOdemeBasl.Date := TabAcilis.Fields[2].AsDateTime;
       if TabAcilis.Fields[1].AsString <>'' then
         ComboKur.EditValue := TabAcilis.Fields[1].AsString
       else
         ComboKur.EditValue := CariDoviz;

       EditBorc.Value :=   TabAcilis.Fields[3].AsCurrency;       // alacağı borca
       EditAlacak.Value :=     TabAcilis.Fields[4].AsCurrency;   //borcu alacağa atıyoruz
       EditYerelPara.Value   :=     TabAcilis.Fields[5].AsCurrency;
       if abs(EditBorc.Value-EditAlacak.Value)<>0 then
          EditKulKur.EditValue := EditYerelPara.Value  / abs(EditBorc.Value-EditAlacak.Value) ;
       EditAcik.Text := TabAcilis.Fields[6].AsString;
   end
   else begin
       btnYeni.click;
       if  Kur <>'' then
         ComboKur.EditValue := Kur
       else
         ComboKur.EditValue := CariDoviz;
   end;
   //Eğer ilk kez giriş yapılıyorsa kur girilebilsin değiştirme yapılıyorsa kur değişemesin
end;

procedure TAcilisKaydiDlg.btnKaydetClick(Sender: TObject);
var s, Saat : string;
begin
   {if not BoslukKontrol(ComboKur.EditingValue, 'Para Birimi') then Abort;
   s := 'select KUR from KASA where ISLEMTARIHI >= '''+IntToStr(CariYil)+'-01-01'' and (TUR=1 or TUR = 2) and KUR='''+ComboKur.EditingValue+''' and REHBERID='+LabelId.Caption;
   if KasaId > 0 then //Kasa bilgisi var ve değişiklik yapılıyorsa
      s := s + ' and ID<>'+ IntToStr(KasaId);
   s := s +' order by KUR';
   if Veritabani.VeriVarMi(Tablo.FDCnn,s,[],[]) then begin
      Application.MessageBox(PChar(ComboKur.Text +' kurlu Açılış Fişi daha önce girilmiştir.'),PChar(Uyari),MB_OK);
      Abort;
   end;}
  if not BoslukKontrol(DateTimePickerOdemeBasl.Text, KontrolTarihi) then
     Abort;
  if not TarihKontrol(DateTimePickerOdemeBasl.Date, KontrolTarihi) then
     Abort;

  if (ComboTur.EditValue=0)and(EditBorc.Value>0.0)and(EditAlacak.Value>0.0) then begin//mutabakat
     ShowMessage(BorcAlacak);
     Abort;
  end;

   if TabAcilis.FieldByName('ID').AsString<>'' then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := ' delete from KASA where ID ='+TabAcilis.FieldByName('ID').AsString;//IntToStr(KasaId);//TabAcilis.FieldByName('ID').AsString;
      Tablo.Query1.ExecSQL;
   end;

   if ComboKur.Text = CariDoviz then
      EditYerelPara.Value := abs(EditBorc.Value - EditAlacak.Value);
   DateTimePickerOdemeBasl.PostEditValue;
   case Cagiran of
     {0 : // Müşteri mutabakatı
         begin //  kaydederken borcu alacağa, alacağı da borca kaydediyoruz.
             Tablo.KasaKaydet(1000+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)),StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToInt(LabelId.Caption),EditAcik.Text,
                            0, ComboKur.Text,CariDoviz, 0,EditBorc.Value,EditAlacak.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,' ');
         end; }
     1 : // Müşteri açılışı / devri / mutabakatı
         begin //  kaydederken borcu alacağa, alacağı da borca kaydediyoruz.
             if ComboTur.EditValue=0 then // mutabakatsa saat ve dakika olmalı
                Saat := ' hh:mm'
             else
                Saat := '';
             Tablo.KasaKaydet(1000+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy'+Saat, DateTimePickerOdemeBasl.Date)),StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToInt(LabelId.Caption),EditAcik.Text,
                            0, ComboKur.Text,CariDoviz, 0,EditBorc.Value,EditAlacak.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,' ');
         end;
     2 : begin //2001-Kasa açılış 2002:devir   3001-Banka açılışı 3002 : devir
             Tablo.KasaKaydet((Cagiran*1000)+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)),0,EditAcik.Text,
                             StrToInt(LabelId.Caption),ComboKur.Text,CariDoviz, 0,EditAlacak.Value,EditBorc.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,'K');
//                   Tablo.KasaUpdate('+', AcilisTuru, StrToInt(LabelId.Caption), EditBorc.Value, EditAlacak.Value);
         end;
     3 : begin //2001-Kasa açılış 2002:devir   3001-Banka açılışı 3002 : devir
             Tablo.KasaKaydet((Cagiran*1000)+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)),0,EditAcik.Text,
                            StrToInt(LabelId.Caption),ComboKur.Text,CariDoviz, 0,EditAlacak.Value,EditBorc.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,'B');
//                   Tablo.KasaUpdate('+', AcilisTuru, StrToInt(LabelId.Caption), EditBorc.Value, EditAlacak.Value);
         end;
     4 : begin
             //2001-Kasa açılış 2002:devir   3001-Banka açılışı 3002 : devir   4001-Kredi Karti Açılışı 4002-Devir
            Tablo.KasaKaydet((Cagiran*1000)+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)),0,EditAcik.Text,
                    StrToInt(LabelId.Caption),ComboKur.Text,CariDoviz, 0,EditBorc.Value,EditAlacak.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,'V');
         end;
     5 : begin
             //2001-Kasa açılış 2002:devir   3001-Banka açılışı 3002 : devir   4001-Kredi Karti Açılışı 4002-Devir
            Tablo.KasaKaydet((Cagiran*1000)+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)),0,EditAcik.Text,
                    StrToInt(LabelId.Caption),ComboKur.Text,CariDoviz, 0,EditAlacak.Value,EditBorc.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,'P');
         end;
     6 : begin //Kredi
             //2001-Kasa açılış 2002:devir   3001-Banka açılışı 3002 : devir   4001-Kredi Karti Açılışı 4002-Devir
            Tablo.KasaKaydet((Cagiran*1000)+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)),0,EditAcik.Text,
                    StrToInt(LabelId.Caption),ComboKur.Text,CariDoviz, 0,EditAlacak.Value,EditBorc.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,'R');
         end;
     7 : begin //MasrafMerkezi
            Tablo.KasaKaydet((Cagiran*1000)+ComboTur.EditValue, StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)), StrToDateTime(FormatDateTime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', DateTimePickerOdemeBasl.Date)),0,EditAcik.Text,
                    0,ComboKur.Text,CariDoviz,StrToInt(LabelId.Caption),EditBorc.Value,EditAlacak.Value,EditYerelPara.Value,-1, -1,-1,-1,-1, SubeId,'_');
         end;
   end;
   ModalResult := mrOk;
end;

procedure TAcilisKaydiDlg.YeniEkle(Doviz:String);
begin

   //ComboKur.ItemIndex := ComboKur.Properties.Items.count-1;
   DateTimePickerOdemeBasl.Date := Tablo.GENINI.BugunTrhSaat;
   ComboKur.Text:= CariDoviz;
   EditBorc.Value := 0;
   EditAlacak.Value := 0;
   case ComboTur.Properties.Items[ComboTur.ItemIndex].Value of
     0 : EditAcik.Text := 'Mutabakat Kaydı';
     1 : EditAcik.Text := 'Açılış Fişi';
     2 : EditAcik.Text := 'Devir Fişi';
   end;
   YeniKayit := True;
end;

procedure TAcilisKaydiDlg.btnYeniClick(Sender: TObject);
var liste : TStringList;
    s : string;
    I : Smallint;
begin
   //Kur seçtir
   liste := TStringList.create;

{   //daha önceki dövizleri listeden çıkaralım ki yeniden eklenmesin
   for I := 0 to ComboKur.Properties.Items.Count - 1 do begin
       s := ComboKur.Properties.Items[I];
       liste.delete(liste.IndexOf(s));
   end;

   if not MesajStrAl('', 'Para Birimini Seçiniz :', 'C', liste, s, '', 'C', nil, s) then begin
      liste.destroy;
      exit;
   end;
   liste.destroy;  }
   YeniEkle(s);
end;

procedure TAcilisKaydiDlg.ComboKurPropertiesEditValueChanged(Sender: TObject);
var
   Kur, Dovizkuru:String;
   Tutar, Doviztutari : Extended;
begin
   Panel1.Visible := (ComboKur.Text<>CariDoviz)and(Acilis_Devir <> 0);
   if (Panel1.Visible)and(ComboKur.Text<>'')and(EditBorc.Text<>'')and(EditAlacak.Text<>'')and((EditBorc.Value>0)or(EditAlacak.Value>0)) then begin
       Kur:= ComboKur.Text;
       Dovizkuru := CariDoviz;
       Tutar := Abs(EditBorc.Value-EditAlacak.Value);
       Tablo.DovizKuruSecimi(False, DateTimePickerOdemeBasl.Date, Kur, Dovizkuru, Tutar, Doviztutari);
       EditYerelPara.Value := Doviztutari;
       if Doviztutari<>0 then
          EditKulKur.EditValue := Doviztutari / Tutar;
   end;
end;

procedure TAcilisKaydiDlg.EditKulKurKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (ComboKur.Text<>'')and(EditBorc.Text<>'')and(EditAlacak.Text<>'')and((EditBorc.Value>0)or(EditAlacak.Value>0)) then
       EditYerelPara.Value := Abs(EditBorc.Value-EditAlacak.Value) *  EditKulKur.value;
end;

procedure TAcilisKaydiDlg.EditYerelParaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   if (ComboKur.Text<>'')and(EditBorc.Text<>'')and(EditAlacak.Text<>'')and((EditBorc.Value>0)or(EditAlacak.Value>0)) then
      EditKulKur.Value := EditYerelPara.value / Abs(EditBorc.Value-EditAlacak.Value);
end;

end.


