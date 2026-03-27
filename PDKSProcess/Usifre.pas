unit USifre;

interface

uses  StdCtrls, Buttons, Controls, Classes, Forms, dbtables, Dialogs, ADODb,
  Grids, DBGrids, Graphics, ExtCtrls, sysutils, Windows, ImgList, ComCtrls,
  ToolWin, jpeg, Messages, cxControls, cxContainer, cxEdit, cxImage,
  cxDBEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, DB, cxGraphics,Menus,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, cxLookAndFeels, cxLookAndFeelPainters;

type
  TPasswordDlg = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image2: TImage;
    CancelBtn: TSpeedButton;
    OKBtn: TSpeedButton;
    ImageList1: TImageList;
    cxDBImage1: TcxDBImage;
    ComboAd: TcxLookupComboBox;
    Password: TcxTextEdit;
    Uzmanlik: TcxComboBox;
    cbLanguages: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2DblClick(Sender: TObject);
    procedure cbLanguagesChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboAdPropertiesChange(Sender: TObject);
  private
    { Private declarations }
//    FDLLList : TDllInfoList;
//    procedure OnLangSwitch(Sender: TMenuItem; AInfo: TDLLInfoItem; var Restart : boolean);
    procedure PopulateComboBox(CB : TComboBox);
  public

    { Public declarations }
    Modul, Sifre : String;
    TabKullan : TADOQuery;

  end;
resourcestring
  SLangChanged = 'Language was changed to "%s".'#13#10'You should restart application to apply the changes';
  
var
  PasswordDlg : TPasswordDlg;

  procedure PasswordEkrani(Modul:String);
implementation

uses UTablo, UCombo, UPaylasim, UMesaj, FetaUtil, UGenSifre;//, USifDeg;,

var
   kapat : Boolean;
   YanlisSay : SmallInt;
   s, BilgisayarKodu : String[20];
   DebugMode :Boolean;
   SuperSifresiPasif : Boolean;
{$R *.DFM}



procedure PasswordEkrani(Modul:String);
begin
  //ServerAcikMi;

    if GENINI.ReadBoolean(Ops_Fetakey, True) then  // Fetakey:=0
    begin
      if DebugMode then LogaEkle( 'LisansKntrl;');
      //LisansKntrl;
    end
   else
    begin
      if DebugMode then LogaEkle( 'LisansKontrolu;');
      //LisansKntrl;
    end;
   if DebugMode then LogaEkle( 'MemAc;');
   MemAc;
   if DebugMode then LogaEkle( 'Tablo.TabKullan.Open;');
   Tablo.TabKullan.Open;
   if DebugMode then LogaEkle( 's := MemReadString;');
   s := MemReadString;

   if DebugMode then LogaEkle( 'if (Modul=Muayene)and(NOT GenotipIni.ReadBool(GenelOpsiyon, UzmanlikSabit, False)) then');
   if (Modul='Muayene')and(NOT GENINI.ReadBoolean(Ops_UzmanlikSabit, False)) then
       s:=''
   else if (Modul='Servis')or(Modul='Ameliyat') then
       s:='';

   if (s <> '')and(s <> '0') then begin

      KullanAdi := GenRegIni.RegReadString('','KullanAdi', 'xxx','C');
      Kullanan  := GenRegIni.RegReadString('','KullanKodu', 'xxx','C');
      if Tablo.TabKullan.Locate('KULLANICIADI',KullanAdi, []) then
          Super := Tablo.TabKullan.FieldByName('SUPER').AsString='1';


      {if (Tablo.KullaniciBilgisi(KullanAdi, 'Geçici'))and(Tablo.TabKulHar.FieldByName('GORME').AsString='0') then Sifresizler := 4
      else if (Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup'))and(Tablo.TabKulHar.FieldByName('GORME').AsString='0') then Sifresizler := 1
      else if (Tablo.KullaniciBilgisi(KullanAdi, 'Fat.No suz'))and(Tablo.TabKulHar.FieldByName('GORME').AsString='0') then Sifresizler := 2
      else if (Tablo.KullaniciBilgisi(KullanAdi, 'KDV (Hariç)'))and(Tablo.TabKulHar.FieldByName('GORME').AsString='0') then Sifresizler := 3
      else Sifresizler := 0; }

      Sifresizler := 0;
//      if Tablo.KullaniciBilgisi(KullanAdi, Modul) then
//         if not (Tablo.TabYetki.FieldByName('GORME').AsString='1') then begin
//            Showmessage('Modülü kullanma yetki kodu bulunamadý..');
//            halt;
//          end;
   end
   else begin
      Application.CreateForm(TPasswordDlg, PasswordDlg);
      PasswordDlg.Modul := Modul;
      PasswordDlg.ShowModal;
      if PasswordDlg.ModalResult = idCANCEL then Halt;
      GenRegIni.RegWriteString('','KullanAdi', KullanAdi,'C');
      GenRegIni.RegWriteString('','KullanKodu', Kullanan,'C');
      if Modul = 'Muayene' then
         GenRegIni.RegWriteString('','Muayene', PasswordDlg.Uzmanlik.Properties.Items[PasswordDlg.Uzmanlik.ItemIndex],'C')
      else if Modul = 'Servis' then
         GenRegIni.RegWriteString('','SERVIS', PasswordDlg.Uzmanlik.Properties.Items[PasswordDlg.Uzmanlik.ItemIndex],'C')
      else if Modul = 'Ameliyat' then
         GenRegIni.RegWriteString('','AMELIYATHANE', PasswordDlg.Uzmanlik.Properties.Items[PasswordDlg.Uzmanlik.ItemIndex],'C');
      PasswordDlg.Destroy;
      PasswordDlg := Nil;
   end;
   MemWriteString('000');
 end;
//procedure TPasswordDlg.OnLangSwitch(Sender: TMenuItem; AInfo: TDLLInfoItem; var Restart : boolean);
//begin
//  MessageBox(0, PChar(Format(SLangChanged, [AInfo.EnglishName])),
//            'Dikkat', MB_OK + MB_ICONEXCLAMATION);
//  Restart := False;
//end;

procedure TPasswordDlg.PopulateComboBox(CB : TComboBox);
//var
//  I : integer;
//  CurInfo : TDLLInfoItem;
begin
//  FDLLList.Clear;
//  if not Localizer.GetDllsInfo(FDLLList) then Exit; //can't get list of resource DLLs
//  CurInfo := Localizer.GetCurrentInfo;
//  for I := 0 to FDLLList.Count - 1 do
//  begin
//    CB.Items.Add(FDLLList[I].EnglishName);
//    if CurInfo.Locale = FDLLList[I].Locale then
//       CB.ItemIndex := I;
//  end;
end;

procedure TPasswordDlg.FormCreate(Sender: TObject);
begin
  Tablo.TabKullan.Open;
  YanlisSay := 0;
  Tablo.TabKullan.First;
  TabKullan := Tablo.TabKullan;
 { ComboAd.Clear;
  Tablo.TabKullan.first;
  while not Tablo.TabKullan.eof do begin
     if Tablo.TabKullan.FieldByName('GORUNMESIN').AsString<> '1' then
        ComboAd.Properties.Items.Add(Tablo.TabKullan.FieldByName('KULLANICIADI').AsString);
     Tablo.TabKullan.next;
  end;
  ComboAd.EditValue  := GenRegIni.RegReadString('','KullanAdi', '','C');
  //ComboAd.ItemIndex := ComboAd.Properties.Items.IndexOf(GenRegIni.RegReadString('','KullanAdi', '','C'));
 Tablo.TabKullan.Locate('KULLANICIADI',GenRegIni.RegReadString('','KullanAdi', '','C'), []);
   }
  ComboAd.EditValue  := GenRegIni.RegReadString('','KullanAdi', '','C');;
  BilgisayarKodu := GenRegIni.RegReadString('','BilgisayarKodu', '','C');
end;
  procedure TPasswordDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then OKBtn.Click
  else if Key = 27 then CancelBtn.Click;
end;

{
procedure TPasswordDlg.ServisGetir(sa:String); //// SERVÝS, AMELIYATHANE
begin
   Uzmanlik.Properties.Items.Clear;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select EKRAN From KULHAR where KULLANICIADI='''+ComboAd.Text+''' and BILGI = ''SERVÝS'' and GORME=1';
   Tablo.Query1.Open;

   if Tablo.Query1.RecordCount >0 then
      while not Tablo.Query1.eof do begin
         Uzmanlik.Properties.Items.Add(copy(Tablo.Query1.Fields[0].AsString,3,100));
         Tablo.Query1.next;
      end
   else begin //GenotipIni.ReadSection(sa, Uzmanlik.Properties.Items);
     Tablo.Query1.Close;
     Tablo.Query1.SQL.Text := 'Select AD From SERVISLER where AKTIF=1 order by 1';
     Tablo.Query1.Open;
      while not Tablo.Query1.eof do begin
         Uzmanlik.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
         Tablo.Query1.next;
      end
   end;
                                                                            //'Servis'
   Uzmanlik.ItemIndex := Uzmanlik.Properties.Items.IndexOf(GenRegIni.RegReadString('',sa, PasswordDlg.Uzmanlik.Properties.Items[0],'C'));
   if Uzmanlik.text = '' then Uzmanlik.ItemIndex := 0;
end;
   }
procedure TPasswordDlg.FormShow(Sender: TObject);
begin

   if Modul = 'Muayene' then begin
      Label2.Visible := True;
      Uzmanlik.Visible := True;
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select AD From POLIKLNK';
      Tablo.Query1.Open;
      while not Tablo.Query1.eof do begin
        Uzmanlik.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
        Tablo.Query1.Next;
      end;
      Uzmanlik.ItemIndex := Uzmanlik.Properties.Items.IndexOf(GenRegIni.RegReadString('','Muayene', PasswordDlg.Uzmanlik.Properties.Items[0],'C'));
   end
   else if Modul = 'Servis' then begin
      Label2.Visible := True;
      Uzmanlik.Visible := True;
      Label2.Caption := 'Servis';
      Uzmanlik.Visible := True;
      //ServisGetir('SERVIS');
   end
   else if Modul = 'Ameliyat' then begin
      Label2.Visible := True;
      Uzmanlik.Visible := True;
      Label2.Caption := 'Ameliyathane';
      Uzmanlik.Visible := True;
      //ServisGetir('AMELIYATHANE');
//      GenotipIni.ReadSection('AMELIYATHANE', Uzmanlik.Items);
//      Uzmanlik.ItemIndex := Uzmanlik.Items.IndexOf(GenRegIni.RegReadString('','Ameliyat', PasswordDlg.Uzmanlik.Items[0],'C'));
   end
   else if Modul = 'Muhasebe' then begin
      Label2.Visible := True;
      Uzmanlik.Visible := True;
      Label2.Caption := 'Firma';
      Uzmanlik.Visible := True;
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select FIRMAADI From MUHFIRMA';
      Tablo.Query1.Open;
      while not Tablo.Query1.eof do begin
         Uzmanlik.Properties.Items.Add(Tablo.Query1.Fields[0].AsString);
         Tablo.Query1.Next;
      end;

   end;

   TabKullan.Open;

//   Uzmanlik.ItemIndex := 0;
   Password.Text := '';

   if ComboAd.Text='' then
      ComboAd.SetFocus
   else
      PassWord.SetFocus;
   //Dil
  //Localizer.InitReg('Software\Feta\genotip');
  //FDLLList := TDllInfoList.Create;
  //Localizer.OnLangSwitch := OnLangSwitch;
  //PopulateComboBox(cbLanguages);
end;

procedure TPasswordDlg.OKBtnClick(Sender: TObject);
begin
   Sifresizler := 0;
   KullanAdi := ComboAd.Text;
   Sifre := UGenSifre.sifre(PassWord.Text);
   if (Sifre <> '')and(GENINI.ReadString(Ops_PassWord, Sifre) <>'') then begin
      KullanAdi := GENINI.ReadString(Ops_PassWord, Sifre);
      Sifresizler := 0;
   end;
   Kapat := True;
   if (TabKullan.Locate('FIRMA', ComboAd.text, []))and(Sifre = TabKullan.FieldByName('SIFRE').AsString) then begin
      if BilgisayarKodu <> '' then
        Kullanan:= BilgisayarKodu
      else begin
        Kullanan := TabKullan.FieldByName('REHBERID').AsString;
      end;
      ModalResult := mrOK;
   end
   else
       Kapat := False;
   if not Kapat then begin
      Inc(YanlisSay);
      Password.Text:='';
      MessageDlg('Geçersiz Kullanýcý Adý veya Þifre', mtInformation, [mbOK], 0);
      Password.SetFocus;
   end;
end;
{   Sifre := UGenSifre.sifre(PassWord.Text);
//   if (Sifre <>'') and ( Tablo.GENINI.ReadString(Ops_GenelOpsiyon_Sifre,'')<>'') then begin    //  GenelOpsiyon', Sifre, '')
//      KullanAdi := Tablo.GENINI.ReadString(Ops_GenelOpsiyon_Sifre,'');
//      if Tablo.KullaniciBilgisi(KullanAdi, 'Geçici') then Sifresizler := 4
//      else if Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup') then Sifresizler := 1
//      else if Tablo.KullaniciBilgisi(KullanAdi, 'Fat.No suz') then Sifresizler := 2
//      else if Tablo.KullaniciBilgisi(KullanAdi, 'KDV (Hariç)') then Sifresizler := 3
   end;
 //  if SubeVarmi then begin

      Tablo.RepSubelerOrtak.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' ').Items;
      Tablo.RepSubelerKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
      Tablo.RepSubelerOrtakKendiSubesi.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' union all Select ID,FIRMA from REHBER Where ID = '+IntToStr(SubeId)+' ').Items;
      Tablo.RepSubelerOrtakTumSubeler.Properties.Items := Tablo.imgComboboxInit('Select 0,''Ortak'' union all Select ID,FIRMA from REHBER Where ID < 0').Items;
//   end;
   Kapat := True;
   if (TabKullanici.Locate('FIRMA', ComboAd.text, []))and(Sifre = TabKullanici.FieldByName('SIFRE').AsString) then begin
      if BilgisayarKodu <> '' then
        Kullanan:= BilgisayarKodu
      else begin
        Kullanan := TabKullanici.FieldByName('REHBERID').AsString;
        KullananID := TabKullanici.FieldByName('ID').AsInteger;
        RolID := TabKullanici.FieldByName('ROLID').AsString;
      end;

      //Super := TabKullan.FieldByName('SUPER').AsString='1';
//     if Tablo.KullaniciBilgisi(KullanAdi, Modul) then begin
//       if not (Tablo.TabKulHar.FieldByName('GORME').AsString='1') then
//          Kapat := False;
//      end;
      //yetkiler açýlýr.(serkan)
      Tablo.TabYetki.Close;
      Tablo.TabYetki.Parameters[0].Value := RolID;
      Tablo.TabYetki.Open;
      ModalResult := mrOK;
         // if (Modul='KULLANAN') and (not super) then
         //    Kapat := False;
   end
   else
       Kapat := False;

   if not Kapat then begin
      Inc(YanlisSay);
      Password.Text:='';
      MessageDlg('Geçersiz Kullanýcý Adý veya Þifre', mtInformation, [mbOK], 0);
      Password.SetFocus;
   end;}
procedure TPasswordDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   if not Kapat then begin
      CanClose := FALSE;
      PassWord.Text := ''
   end;
end;

procedure TPasswordDlg.CancelBtnClick(Sender: TObject);
begin
  Kapat := True;
  ModalResult := mrCancel;
  Close;
end;

procedure TPasswordDlg.Image1Click(Sender: TObject);
var Sifre1, Sifre2:String;
begin
   if (ComboAd.Text = '')or(Password.Text = '')then begin
      showmessage('Önce Kullanýcý Adý ve Parolayý Giriniz..');
      exit;
   end;

   KullanAdi := ComboAd.Text;
   Sifre := PassWord.Text;
   if (TabKullan.Locate('KULLANICIADI',KullanAdi ,[]))and(Sifre = TabKullan.FieldByName('SIFRE').AsString) then begin
      Sifre1:=''; Sifre1:='';
      if not MesajStrAl('', 'Yeni þifreyi giriniz : ','P',nil,Sifre1, 'Yeni þifreyi bir kez daha giriniz :','P',nil, Sifre2) then
         exit;

      if Sifre1 <> Sifre2 then
         showmessage('Þifre Giriþleri Uyumsuz!!! Deðiþtirilemedi...')
      else begin
            Tablo.Query1.Close;
            Tablo.Query1.SQL.Text := 'UPDATE KULLAN SET SIFRE='''+Sifre1+''' where KULLANICIADI = ''' + KullanAdi +'''';
            Tablo.Query1.ExecSQL;
            showmessage('Þifre baþarýyla deðiþtirildi...');
          end;
    end
    else
       showmessage('Geçersiz Þifre...')
end;


procedure TPasswordDlg.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   releasecapture;
   perform(wm_syscommand,$f012,0);
end;

procedure TPasswordDlg.Image2DblClick(Sender: TObject);
begin
    VTSifreKontrolu(GenRegIni, Tablo.cnn, True);
end;

procedure TPasswordDlg.cbLanguagesChange(Sender: TObject);
var
  FileName : string;
  Index : integer;
  bRestart : boolean;
begin
//  Index := TComboBox(Sender).ItemIndex;
//  FileName := FDLLList[Index].FileName;
//
//  Localizer. SwitchToFile(FileName);
//
//  bRestart := False;
//  OnLangSwitch(nil, FDLLList[Index], bRestart);
end;
procedure TPasswordDlg.ComboAdPropertiesChange(Sender: TObject);
begin
    Tablo.TabKullan.Locate('FIRMA', ComboAd.Text, [loCaseInsensitive]);
//   if Modul = 'Muayene' then begin
//      Tablo.Query1.Close;
//      Tablo.Query1.SQL.Text := 'Select UZMANLIK From DOKTOR Where DOKTOR='''+ComboAd.Text+'''';
//      Tablo.Query1.Open;
//      Uzmanlik.ItemIndex := Uzmanlik.Properties.Items.IndexOf(Tablo.Query1.Fields[0].AsString);
//   end
  // else if Modul = 'Servis' then ServisGetir('SERVIS')
  // else if Modul = 'Ameliyat' then ServisGetir('AMELIYATHANE');
end;
procedure TPasswordDlg.FormDestroy(Sender: TObject);
begin
//  FDLLList.Free;
end;
end.

