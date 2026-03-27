unit UYedekCalistir;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, StdCtrls, Buttons, cxMaskEdit,
  cxButtonEdit, cxTextEdit, cxControls, cxContainer, cxEdit, cxCheckBox,
  ExtCtrls, ExtDlgs, JvBaseDlg,UTablo, JvBrowseFolder, ComCtrls, ToolWin,DateUtils,
  cxProgressBar, Spin, cxGraphics, cxDropDownEdit,StrUtils, cxLabel, dxSkinscxPCPainter, cxPC,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsDefaultPainters, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013White, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinValentine, dxSkinVS2010, dxSkinWhiteprint, dxSkinXmas2008Blue;

type
  TYedekCalistirDlg = class(TForm)
    ToolBar3: TToolBar;
    btnKaydet: TToolButton;
    ToolButton1: TToolButton;
    btnkapat: TToolButton;
    gbServerBilgileri: TGroupBox;
    Label1: TcxLabel;
    Label9: TcxLabel;
    CheckTarihSaat: TcxCheckBox;
    ServerDizin: TcxButtonEdit;
    BakcupAdi: TcxTextEdit;
    gbTerminalBilgileri: TGroupBox;
    cxLabel2: TcxLabel;
    WinrarDizin: TcxButtonEdit;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    Label2: TcxLabel;
    CheckTutulacakGun: TcxCheckBox;
    txtTutulacakGun: TSpinEdit;
    CheckprgKapanirkenYedek: TcxCheckBox;
    OpenDialog1: TOpenDialog;
    cxLabel1: TcxLabel;
    cxLabel3: TcxLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnKaydetClick(Sender: TObject);
    procedure btnkapatClick(Sender: TObject);
    procedure YedeklemeCalistir(YedekDizin, WinrarExeDizin:string);
    procedure FormShow(Sender: TObject);
    procedure CheckprgKapanirkenYedekClick(Sender: TObject);
    procedure CheckTutulacakGunClick(Sender: TObject);
    procedure WinrarDizinPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ServerDizinPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  YedekCalistirDlg: TYedekCalistirDlg;
   PaylasimAdiilkKisim,TerminalKayit,SimdiYedeklemi,Hatalar:String;

implementation
uses  UAnaForm,UCombo,Fetautil,UBekletme, FetaKurulusSiniflari,Kazip,PrjConst,LocOnFly;

{$R *.dfm}

procedure TYedekCalistirDlg.btnkapatClick(Sender: TObject);
begin
ModalResult:=mrCancel;
end;

procedure TYedekCalistirDlg.btnKaydetClick(Sender: TObject);
begin
   Tablo.GENINI.WriteString( Ops_Yedekleme_YedeklemeDizin, ServerDizin.Text);
   Tablo.GENINI.WriteString( Ops_Yedekleme_Winrar,WinrarDizin.Text);
   Tablo.GENINI.WriteBoolean( Ops_Yedekleme_Kapanirken,CheckprgKapanirkenYedek.Checked);
   Tablo.GENINI.WriteBoolean( Ops_Yedekleme_TutulacakCheck,CheckTutulacakGun.Checked);
   Tablo.GENINI.WriteString( Ops_Yedekleme_TutulacakGun,txtTutulacakGun.Text);
   ModalResult:=mrOk;
end;

procedure TYedekCalistirDlg.FormCreate(Sender: TObject);
begin
  LocalizerOnFly.ProcessContainer(Self);
end;

procedure TYedekCalistirDlg.FormShow(Sender: TObject);
begin
  ServerDizin.Text:=Tablo.GENINI.ReadString(Ops_Yedekleme_YedeklemeDizin, 'D:\');
  WinrarDizin.Text:= Tablo.GENINI.ReadString( Ops_Yedekleme_Winrar,'');
  CheckprgKapanirkenYedek.Checked:= Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Kapanirken,False);
  CheckTutulacakGun.Checked:= Tablo.GENINI.ReadBoolean( Ops_Yedekleme_TutulacakCheck,False);
  txtTutulacakGun.Text:=Tablo.GENINI.ReadString( Ops_Yedekleme_TutulacakGun,'5');
end;

procedure TYedekCalistirDlg.ServerDizinPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if OpenDialog1.Execute then
     ServerDizin.Text:=ExtractFileDir(OpenDialog1.FileName);
end;

procedure TYedekCalistirDlg.SpeedButton1Click(Sender: TObject);
begin
  SimdiYedeklemi:='?imdi';
  if not BoslukKontrol(ServerDizin.text, 'Yedekleme dizini') then Abort;
  if not BoslukKontrol(WinrarDizin.text, 'Winrar dizini') then Abort;
  if (txtTutulacakGun.Text = '') or (StrToInt(txtTutulacakGun.Text) = 0) then begin
    Application.MessageBox(PChar(Minimum_gun_sayisi),PChar(Uyari),0);
    Abort;
  end;

  YedeklemeCalistir(ServerDizin.Text,WinrarDizin.Text);

  if FileExists(TerminalKayit) Then begin // Dosya varsa
    Application.MessageBox(PCHAR(Yedek_Alindi),PCHAR(Uyari),0)
  end Else begin  //Dosya Yoksa
    if Hatalar = '1' then
      Application.MessageBox(PChar(Yedek_alma_basarisiz_server_kontrol_edin),PCHAR(Uyari),0)
    else if Hatalar = '2' then
      Application.MessageBox(PCHAR(Yedek_Alindi_Sikistirma_Basarisiz_server_kontrol),PCHAR(Uyari),0);
  end;

end;
procedure TYedekCalistirDlg.WinrarDizinPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
   if OpenDialog1.Execute then
      WinrarDizin.Text:=OpenDialog1.FileName;
end;

procedure TYedekCalistirDlg.CheckTutulacakGunClick(Sender: TObject);
begin
   Tablo.GENINI.WriteBoolean( Ops_Yedekleme_TutulacakCheck,CheckTutulacakGun.Checked);
   Tablo.GENINI.WriteString( Ops_Yedekleme_TutulacakCheck,txtTutulacakGun.Text);
end;

procedure TYedekCalistirDlg.CheckprgKapanirkenYedekClick(Sender: TObject);
begin
   Tablo.GENINI.WriteBoolean( Ops_Yedekleme_Kapanirken,CheckprgKapanirkenYedek.Checked);
end;

procedure TYedekCalistirDlg.YedeklemeCalistir(YedekDizin, WinrarExeDizin:string);
var
   Yol,DokumanYol, WRar,GENYEDEK: String; // AdTarih,YolAdi,RarZip,Tarih,Ters,PaylasilanKlasor,SonYedekDokumanTarih, :
   i,J,Fark:integer;
   kzip:TKAZip;
   ZipFile,filename:TFileStream;

    procedure DosyaRarZipOlustur(Tur:integer);
    begin
          DokumanYol := Tablo.GENINI.ReadString(Ops_Dokuman_Dizin,'C:\GenDokuman\');
          if DokumanYol = '' then DokumanYol:= 'C:\GenDokuman\';

          if DokumanYol[length(DokumanYol)] = '\' then
             DokumanYol := copy(DokumanYol,1,length(DokumanYol)-1);

          WRar := '"'+WinrarExeDizin+'"  a -ep1 -r ' +Yol+GENYEDEK+'_dok.zip '+DokumanYol;      // -pasd^ad  C:\Program Files\WinRAR\Rar.exe
          Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'EXEC MASTER..xp_cmdshell '''+WRar+''' ',[],[]);

{            Zipfile := TFileStream.Create(Yol+'GenDokuman.zip',fmCreate);        // 'D:\Deneme\idris.rar'

            kzip := TKAZip.Create(nil);
            Zipfile.Position:=0;
              try
                kzip.CreateZip(Zipfile);
                Zipfile.Free;

                kzip.Open(Yol+'GenDokuman.zip');

                kzip.AddFolder(DokumanYol,'','*.*',True);
                kzip.Close;
              finally
               kzip.Free;
              end;    }
    end;
begin

  if (YedekDizin = '') then begin
    Showmessage(Tanimlama_eksik_hatali);
    Abort;
    exit;
  end;

  GENYEDEK := 'GENYEDEK'+FormatDateTime('_ddmmyyyyhhnnss', Tablo.GENINI.BugunTrhSaat);
//    Yol := YedekDizin+ '\'+GENYEDEK;  //   WinrarExeDizin
    if YedekDizin[length(YedekDizin)-1]<>'\' then
       Yol := YedekDizin+ '\';  //   WinrarExeDizin


    Application.CreateForm(TBekletmeDlg,BekletmeDlg);
    BekletmeDlg.Show;
   while i<5 do begin
    BekletmeDlg.cxProgressBar1.Position:=i;
    BekletmeDlg.cxProgressBar1.Refresh;
    sleep(25);
    inc(i);
   end;
     try
      Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'BACKUP DATABASE [' + trim(copy(ServerAdi,pos('/', ServerAdi)+1,50)) + '] TO DISK =''' + Yol+ GENYEDEK+'.BAK' + ''' WITH RETAINDAYS=1', [], []);
    Except
      Hatalar := '1';
      BekletmeDlg.Destroy;
      Exit;
    end;
                                         //  -pasd^ad
    WRar := '"'+WinrarExeDizin+'"  a -ep1 -df ' +Yol+GENYEDEK+'.zip '+ Yol+ GENYEDEK+'.BAK' ;      //  C:\Program Files\WinRAR\Rar.exe
    Veritabani.BasitKomutÇalýþtýr(Tablo.FDCnn, 'EXEC MASTER..xp_cmdshell '''+WRar+''' ',[],[]);



{    if not Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Backup,True) then begin

      if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Rar,False) then
       RarZip:='.rar'
      else if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Zip,False) then
       RarZip:='.zip';
       DosyaRarZipOlustur(0);
    end;   }

    ////////D?k?man Yedekle
{      SonYedekDokumanTarih := Tablo.GENINI.ReadString( Ops_Yedekleme_SonYedek_DokumanTarih,'01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + '1900');
      SonYedekDokumanTarih := Tablo.SistemTarihFormatinaCevirme(SonYedekDokumanTarih);
      Fark := HoursBetween(Now,StrToDateTime(SonYedekDokumanTarih));

       if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Gunluk,True)  then begin
         if Fark > 24 then begin
           DosyaRarZipOlustur(1);
           Tablo.GENINI.WriteString( Ops_Yedekleme_SonYedek_DokumanTarih,Formatdatetime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh))
         end;
       end else if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Haftalik,True)  then begin
         if Fark > 168 then begin
           DosyaRarZipOlustur(1);
           Tablo.GENINI.WriteString( Ops_Yedekleme_SonYedek_DokumanTarih,Formatdatetime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh))
         end;
       end else if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Aylik,True)  then begin
          if Fark > 720 then begin
            DosyaRarZipOlustur(1);
            Tablo.GENINI.WriteString( Ops_Yedekleme_SonYedek_DokumanTarih,Formatdatetime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh))
         end;
       end;}

     DosyaRarZipOlustur(1);

    /// ////D?k?man Yedekle
    i:=0;
    while i<1 do begin
      BekletmeDlg.cxProgressBar1.Position:=i;
      BekletmeDlg.cxProgressBar1.Refresh;
      sleep(25);
      inc(i);
    end;
    BekletmeDlg.Destroy;
    //yedek al?nma zaman? kydedilir
    Tablo.GENINI.WriteString( Ops_Yedekleme_SonYedek_Cikis,Formatdatetime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh));


{  if YedekDlgHostName<>YedekDlgMachineName then begin
   // MoveFile(PWideChar('\\'+MachineName+'\'+PaylasimAdi+'\'+AdTarih+''), PWideChar(''+WinrarExeDizin+'\'+AdTarih+''));
   if not Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Backup,True) then begin
     if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_TerminaledeYedekle,True) then begin
       CopyFile(PWideChar('\\'+YedekDlgMachineName+'\'+PaylasilanKlasor+'\'+GENYEDEK+'\'+Ad+RarZip+''), PWideChar(''+WinrarExeDizin+'\'+GENYEDEK+'\'+Ad+RarZip+''),True);
       WinExec(PAnsiChar('CMD /C net use '+Surucu+': /delete'),sw_hide);
       DeleteFile('\\'+YedekDlgMachineName+'\'+PaylasilanKlasor+'\'+GENYEDEK+'');
       TerminalKayit := ''+WinrarExeDizin+'\'+GENYEDEK+'\'+Ad+RarZip+''
     end;
   end else begin
     if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_TerminaledeYedekle,True) then begin
       CopyFile(PWideChar('\\'+YedekDlgMachineName+'\'+PaylasilanKlasor+'\'+GENYEDEK+''), PWideChar(''+WinrarExeDizin+'\'+GENYEDEK+''),True);
       WinExec(PAnsiChar('CMD /C net use '+Surucu+': /delete'),sw_hide);
       TerminalKayit:=''+WinrarExeDizin+'\'+GENYEDEK+'';
     end;
   end;
  end else begin
   if not Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Backup,True) then begin
     DeleteFile(''+YedekDizin+'\'+GENYEDEK+''); // WinrarExeDizin
     TerminalKayit := ''+YedekDizin+'\'+GENYEDEK+'\'+Ad+RarZip+''    // WinrarExeDizin
   end else begin
     TerminalKayit:=''+YedekDizin+'\'+GENYEDEK+'';       // WinrarExeDizin
   end;
  end;

  if Tablo.GENINI.ReadBoolean( Ops_Yedekleme_TutulacakCheck,False) then  begin
    for i := StrToInt(Tablo.GENINI.ReadString( Ops_Yedekleme_TutulacakGun)+ Kullanan),'5')) to 365 do begin
      Tarih:=Formatdatetime('ddmmyyyy', Tablo.GENINI.BugunTrh-i);
       if YedekDlgHostName <> YedekDlgMachineName then begin
       if not Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Backup,True) then
         DeleteFiles(WinrarExeDizin+'\'+GENYEDEK,'*_' + Tarih + RarZip)
       else
         DeleteFiles(WinrarExeDizin+'\'+GENYEDEK,'*_' + Tarih + '*.bak');
       end else begin
       if not Tablo.GENINI.ReadBoolean( Ops_Yedekleme_Backup,True) then
         DeleteFiles(YedekDizin+'\'+GENYEDEK,'*_' + Tarih + RarZip)
       else
         DeleteFiles(YedekDizin+'\'+GENYEDEK,'*_' + Tarih + '*.bak');
       end;

    end;
  end;    }

end;

end.



