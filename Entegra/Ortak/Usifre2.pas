unit USifre;

interface

uses  StdCtrls, Buttons, Controls, Classes, Forms, dbtables, Dialogs, UFDCompatHelpers,
  Grids, DBGrids, Graphics, ExtCtrls, sysutils, Windows, ImgList, ComCtrls,
  ToolWin, Ping, jpeg;

type
  TPasswordDlg = class(TForm)
    Image1: TImage;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image2: TImage;
    Password: TEdit;
    Uzmanlik: TComboBox;
    ComboAd: TComboBox;
    ToolBar1: TToolBar;
    CancelBtn: TToolButton;
    OKBtn: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboAdChange(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Image2DblClick(Sender: TObject);
  private
    { Private declarations }
    procedure ServisGetir(sa:String);
  public
    { Public declarations }
    Modul, Sifre : String;
    TabKullan : TADOTable;
  end;

var
  PasswordDlg : TPasswordDlg;

  procedure PasswordEkrani(Modul:String);
implementation

uses UTablo, UCombo, UPaylasim, ULisans, UMesaj, FetaUtil;//, USifDeg;

var
   kapat : Boolean;
   YanlisSay : SmallInt;
   s, BilgisayarKodu : String[3];

{$R *.DFM}

procedure ServerAcikMi;
var p   : TPing;
    sl  : TStringList;
begin
  sl:=TStringList.Create;
  p:=TPing.Create(nil);
  try
    Session.GetAliasParams('GENOTIPSQL', sl);
    p.Address:=sl.Values['SERVER NAME'];
    if p.Address='.' then p.Address := '127.0.0.1';
    if P.Ping = 0 then
       if Application.MessageBox(PChar('''+p.Address+'' adlı bilgisayara ulaşılamıyor.'#13'Kablolarınızı kontrol edin..'#13'Devam etsin mi?'), 'Dikkat! Network hatası!!!',MB_YESNO)<>IDYES then
          halt;
  finally
    sl.Free;
    p.Free;
  end;
end;

procedure PasswordEkrani(Modul:String);
begin
   //ServerAcikMi;
   LisansKontrolu;
   MemAc;
   Tablo.TabKullan.Open;
   s := MemReadString;
   if (Modul='Muayene')and(NOT GenotipIni.ReadBool('GenelOpsiyon', 'UzmanlikSabit', False)) then
       s:=''
   else if (Modul='Servis')or(Modul='Ameliyat') then
       s:='';
   if (s <> '')and(s <> '0') then begin
      KullanAdi := GenRegIni.RegReadString('','KullanAdi', 'xxx','C');
      Kullanan  := GenRegIni.RegReadString('','KullanKodu', 'xxx','C');
      if Tablo.TabKullan.Locate('KULLANICIADI',KullanAdi, []) then
          Super := Tablo.TabKullan.FieldByName('SUPER').AsString='1';

      if Tablo.KullaniciBilgisi(KullanAdi, Modul) then
         if not (Tablo.TabKulHar.FieldByName('GORME').AsString='1') then begin
            Showmessage('Modülü kullanma yetki kodu bulunamadı..');
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
         GenRegIni.RegWriteString('','Muayene', PasswordDlg.Uzmanlik.Items[PasswordDlg.Uzmanlik.ItemIndex],'C')
      else if Modul = 'Servis' then
         GenRegIni.RegWriteString('','SERVIS', PasswordDlg.Uzmanlik.Items[PasswordDlg.Uzmanlik.ItemIndex],'C')
      else if Modul = 'Ameliyat' then
         GenRegIni.RegWriteString('','AMELIYATHANE', PasswordDlg.Uzmanlik.Items[PasswordDlg.Uzmanlik.ItemIndex],'C');
      PasswordDlg.Destroy;
      PasswordDlg := Nil;
   end;
   MemWriteString('000');
end;

procedure TPasswordDlg.FormCreate(Sender: TObject);
begin
  YanlisSay := 0;
  Tablo.TabKullan.First;
  TabKullan := Tablo.TabKullan;
  ComboAd.Clear;
  Tablo.TabKullan.first;
  while not Tablo.TabKullan.eof do begin
     if Tablo.TabKullan.FieldByName('GORUNMESIN').AsString<> '1' then
        ComboAd.Items.Add(Tablo.TabKullan.FieldByName('KULLANICIADI').AsString);
     Tablo.TabKullan.next;
  end;
  ComboAd.Text := GenRegIni.RegReadString('','KullanAdi', '','C');
  BilgisayarKodu := GenRegIni.RegReadString('','BilgisayarKodu', '','C');
end;

procedure TPasswordDlg.ServisGetir(sa:String); //// SERVİS, AMELIYATHANE
begin
   Uzmanlik.Clear;
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select EKRAN From KULHAR where KULLANICIADI='''+ComboAd.Text+''' and EKRAN like'''+copy(sa,1,1)+'/%'' and GORME=1';
   Tablo.Query1.Open;
   if Tablo.Query1.RecordCount >0 then
      while not Tablo.Query1.eof do begin
         Uzmanlik.Items.Add(copy(Tablo.Query1.Fields[0].AsString,3,100));
         Tablo.Query1.next;
      end
   else
      GenotipIni.ReadSection(sa, Uzmanlik.Items);
                                                                            //'Servis'
   Uzmanlik.ItemIndex := Uzmanlik.Items.IndexOf(GenRegIni.RegReadString('',sa, PasswordDlg.Uzmanlik.Items[0],'C'));
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
        Uzmanlik.Items.Add(Tablo.Query1.Fields[0].AsString);
        Tablo.Query1.Next;
      end;
      Uzmanlik.ItemIndex := Uzmanlik.Items.IndexOf(GenRegIni.RegReadString('','Muayene', PasswordDlg.Uzmanlik.Items[0],'C'));
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
         Uzmanlik.Items.Add(Tablo.Query1.Fields[0].AsString);
         Tablo.Query1.Next;
      end;

   end;

   TabKullan.Open;

//   Uzmanlik.ItemIndex := 0;
   Password.Text := '';
end;

procedure TPasswordDlg.OKBtnClick(Sender: TObject);
begin
   Sifresizler := 0;
   KullanAdi := ComboAd.Text;
   Sifre := PassWord.Text;
   if (Sifre<>'')and(GenotipIni.ReadString('GenelOpsiyon', Sifre, '') <>'') then begin
      KullanAdi := GenotipIni.ReadString('GenelOpsiyon', Sifre, '');
      if Tablo.KullaniciBilgisi(KullanAdi, 'Geçici') then Sifresizler := 4
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Kimlik-Grup') then Sifresizler := 1
      else if Tablo.KullaniciBilgisi(KullanAdi, 'Fat.No suz') then Sifresizler := 2
      else if Tablo.KullaniciBilgisi(KullanAdi, 'KDV (Hariç)') then Sifresizler := 3
   end;
   Kapat := True;
   if TabKullan.RecordCount > 0 then  {kütük boş değilse}
      if (TabKullan.Locate('KULLANICIADI',KullanAdi, []))and(Sifre = TabKullan.FieldByName('SIFRE').AsString) then begin
          if BilgisayarKodu<>'' then
             Kullanan:= BilgisayarKodu
          else
             Kullanan := TabKullan.FieldByName('KULLANICI').AsString;
          Super := TabKullan.FieldByName('SUPER').AsString='1';
          if Tablo.KullaniciBilgisi(KullanAdi, Modul) then begin
             if not (Tablo.TabKulHar.FieldByName('GORME').AsString='1') then
                Kapat := False;
          end;

          if (Modul='KULLANAN') and (not super) then
             Kapat := False;
      end
      else begin
             Kapat := False;
           end;
   if not Kapat then begin
      Inc(YanlisSay);
      MessageDlg('Geçersiz Kullanıcı Adı veya Şifre', mtInformation, [mbOK], 0);
      if YanlisSay > 4 then Begin
         TabKullan.Edit;
         TabKullan.FieldByName('GORUNMESIN').AsString := 'X';
         TabKullan.Post;
         FormCreate(Self);
      end;
   end;
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

procedure TPasswordDlg.ComboAdChange(Sender: TObject);
begin
   if Modul = 'Muayene' then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select UZMANLIK From DOKTOR Where DOKTOR='''+ComboAd.Text+'''';
      Tablo.Query1.Open;
      Uzmanlik.ItemIndex := Uzmanlik.Items.IndexOf(Tablo.Query1.Fields[0].AsString);
   end
   else if Modul = 'Servis' then ServisGetir('SERVIS')
   else if Modul = 'Ameliyat' then ServisGetir('AMELIYATHANE');
end;

procedure TPasswordDlg.Image1Click(Sender: TObject);
var Sifre1, Sifre2:String;
begin
   if (ComboAd.Text = '')or(Password.Text = '')then begin
      showmessage('Önce Kullanıcı Adı ve Parolayı Giriniz..');
      exit;
   end;

   KullanAdi := ComboAd.Text;
   Sifre := PassWord.Text;
   if (TabKullan.Locate('KULLANICIADI',KullanAdi ,[]))and(Sifre = TabKullan.FieldByName('SIFRE').AsString) then begin
      Sifre1:=''; Sifre1:='';
      if not MesajStrAl('', 'Yeni şifreyi giriniz : ','P',nil,Sifre1, 'Yeni şifreyi bir kez daha giriniz :','P',nil, Sifre2) then
         exit;

      if Sifre1 <> Sifre2 then
         showmessage('Şifre Girişleri Uyumsuz!!! Değiştirilemedi...')
      else begin
            Tablo.Query1.Close;
            Tablo.Query1.SQL.Text := 'UPDATE KULLAN SET SIFRE='''+Sifre1+''' where KULLANICIADI = ''' + KullanAdi +'''';
            Tablo.Query1.ExecSQL;
            showmessage('Şifre başarıyla değiştirildi...');
          end;
    end
    else
       showmessage('Geçersiz Şifre...')
end;

procedure TPasswordDlg.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then OKBtn.Click
  else if Key = #27 then CancelBtn.Click;
end;

procedure TPasswordDlg.Image2DblClick(Sender: TObject);
begin
    VTSifreKontrolu(GenRegIni, Tablo.FDCnn, True);
end;

end.



