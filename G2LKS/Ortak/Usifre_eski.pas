unit USifre;

interface

uses  StdCtrls, Buttons, Controls, Classes, Forms, dbtables, Dialogs, ADODb,
  Grids, DBGrids, Graphics, ExtCtrls, sysutils, Windows, ImgList, ComCtrls,
  ToolWin, jpeg, Messages, cxControls, cxContainer, cxEdit, cxImage,
  cxDBEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, DB, cxGraphics, dxSkinsCore ,
  dxSkinsDefaultPainters, dxSkinBlue;

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
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image2DblClick(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboAdPropertiesChange(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    procedure ServisGetir(sa:String);
  public

    { Public declarations }
    Modul, Sifre : String;
    TabKullan : TADOQuery;

  end;

var
  PasswordDlg : TPasswordDlg;

  procedure PasswordEkrani(Modul:String);
implementation

uses UTablo, UCombo, UPaylasim, UMesaj, FetaUtil;//, ULisans;//, USifDeg;,

var
   kapat : Boolean;
   YanlisSay : SmallInt;
   s, BilgisayarKodu : String;

{$R *.DFM}



procedure PasswordEkrani(Modul:String);
begin
  //ServerAcikMi;
   
//  idris  if GenotipIni.ReadBool('GenelOpsiyon', 'Fetakey', True) then  // Fetakey:=0
//    begin
//      if DebugMode then LogaEkle( 'LisansKntrl;');
//     // LisansKntrl;
//    end
//   else
//    begin
////      if DebugMode then LogaEkle( 'LisansKontrolu;');
////      LisansKontrolu;
//    end;

   if DebugMode then LogaEkle( 'MemAc;');
   MemAc;
   if DebugMode then LogaEkle( 'Tablo.TabKullan.Open;');
   Tablo.TabKullan.Open;
   if DebugMode then LogaEkle( 's := MemReadString;');
   s := MemReadString;

   if DebugMode then LogaEkle( 'if (Modul=Muayene)and(NOT GenotipIni.ReadBool(GenelOpsiyon, UzmanlikSabit, False)) then');
// idris  if (Modul='Muayene')and(NOT GenotipIni.ReadBool('GenelOpsiyon', 'UzmanlikSabit', False)) then
//       s:=''
//   else if (Modul='Servis')or(Modul='Ameliyat') then
//       s:='';

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
      if Tablo.KullaniciBilgisi(KullanAdi, Modul) then
         if not (Tablo.TabKulHar.FieldByName('GORME').AsString='1') then begin
            Showmessage('Modülü kullanma yetki kodu bulunamadý..');
            halt;
          end;
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

procedure TPasswordDlg.FormCreate(Sender: TObject);
begin
  Tablo.TabKullan.Open;
  YanlisSay := 0;
  Tablo.TabKullan.First;
  TabKullan := Tablo.TabKullan;
{  ComboAd.Clear;
  Tablo.TabKullan.first;
  while not Tablo.TabKullan.eof do begin
     if Tablo.TabKullan.FieldByName('GORUNMESIN').AsString<> '1' then
        ComboAd.Items.Add(Tablo.TabKullan.FieldByName('KULLANICIADI').AsString);
     Tablo.TabKullan.next;
  end;  }
///  ComboAd.ItemIndex := ComboAd.Properties.Items.IndexOf(GenRegIni.RegReadString('','KullanAdi', '','C'));
//  Tablo.TabKullan.Locate('KULLANICIADI',GenRegIni.RegReadString('','KullanAdi', '','C'), []);
  s := GenRegIni.RegReadString('','KullanAdi', '','C');
  ComboAd.EditValue := s;
  BilgisayarKodu := GenRegIni.RegReadString('','BilgisayarKodu', '','C');
end;

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
      ServisGetir('SERVIS');
   end
   else if Modul = 'Ameliyat' then begin
      Label2.Visible := True;
      Uzmanlik.Visible := True;
      Label2.Caption := 'Ameliyathane';
      Uzmanlik.Visible := True;
      ServisGetir('AMELIYATHANE');
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
end;

procedure TPasswordDlg.OKBtnClick(Sender: TObject);
        procedure Girisim;
        begin
          if TabKullan.FieldByName('VATANDASLIKNO').AsString='' then
             raise Exception.Create('Kullanýcýnýn T.C. Kimlik No girilmemiþ. Kullanan modülünden ekleyin!');
          if BilgisayarKodu<>'' then
             Kullanan:= BilgisayarKodu
          else
             Kullanan := TabKullan.FieldByName('KULLANICI').AsString;
          Super := TabKullan.FieldByName('SUPER').AsString='1';
          if Tablo.KullaniciBilgisi(KullanAdi, Modul) then begin
 //              if KullaniciBilgi.Gorme[Modul]='1' then
             if not (   Tablo.TabKulHar.FieldByName('GORME').AsString='1') then
 //             if not (  KullaniciBilgi.Gorme[''] ='0') then
                Kapat := False;
          end;

          if (Modul='KULLANAN') and (not super) then
             Kapat := False;
      end;
begin
   Sifresizler := 0;
   KullanAdi := ComboAd.Text;
   Sifre := PassWord.Text;
   if (Sifre<>'')and(GenotipIni.ReadString('GenelOpsiyon', Sifre, '') <>'') then begin
      KullanAdi := GenotipIni.ReadString('GenelOpsiyon', Sifre, '');
      Sifresizler := 0;
      if Tablo.KullaniciBilgisi(KullanAdi, 'Geçici') then
        Sifresizler := 4
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup') then Sifresizler := 1
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Fat.No suz') then Sifresizler := 2
      else if Tablo.KullaniciBilgisi(KullanAdi, 'KDV (Hariç)') then Sifresizler := 3
   end;
   Kapat := True;
   if TabKullan.RecordCount > 0 then  {kütük boþ deðilse}
      if (TabKullan.Locate('KULLANICIADI',KullanAdi, []))and(Sifre = TabKullan.FieldByName('SIFRE').AsString) then
          Girisim
      else begin
             if Sifre='' then Sifre:='!!!xyz';
             Tablo.Query1.Close;
             Tablo.Query1.SQL.Text := ' select SIFRE, isnull(SUPER,0) from KULLAN where SIFRE='''+Sifre+'''';
             Tablo.Query1.Open;
             if ((Tablo.Query1.Fields[1].AsString = '1') and (not(SuperSifresiPasif))) then
                Girisim
             else
                Kapat := False;
           end;
   if not Kapat then begin
      Inc(YanlisSay);
      MessageDlg('Geçersiz Kullanýcý Adý veya Þifre', mtInformation, [mbOK], 0);
      if YanlisSay > 4 then Begin
         TabKullan.Edit;
         TabKullan.FieldByName('GORUNMESIN').AsString := 'X';
         TabKullan.Post;
         FormCreate(Self);
      end;
   end;
//   Tablo.LogGirisCikis('Giriþ');
   ModalResult := mrOK;
//   Close;
end;

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

procedure TPasswordDlg.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then OKBtn.Click
  else if Key = 27 then CancelBtn.Click;
end;

procedure TPasswordDlg.Image2DblClick(Sender: TObject);
begin
    VTSifreKontrolu(GenRegIni, Tablo.cnn, True);
end;

procedure TPasswordDlg.Image1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   releasecapture;
   perform(wm_syscommand,$f012,0);
end;

procedure TPasswordDlg.ComboAdPropertiesChange(Sender: TObject);
begin
   Tablo.TabKullan.Locate('KULLANICIADI', ComboAd.Text, [loCaseInsensitive]);
   if Modul = 'Muayene' then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select UZMANLIK From DOKTOR Where DOKTOR='''+ComboAd.Text+'''';
      Tablo.Query1.Open;
      Uzmanlik.ItemIndex := Uzmanlik.Properties.Items.IndexOf(Tablo.Query1.Fields[0].AsString);
   end
   else if Modul = 'Servis' then ServisGetir('SERVIS')
   else if Modul = 'Ameliyat' then ServisGetir('AMELIYATHANE');

end;

end.

