unit UProgramSonuDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,PrjConst,
  Dialogs, dxGDIPlusClasses, StdCtrls, ExtCtrls, Menus, cxLookAndFeelPainters, cxButtons,
  cxGraphics, cxLookAndFeels, dxSkinsCore, dxSkinLiquidSky, dxSkinLondonLiquidSky;

type
  TProgramSonuDialog = class(TForm)
    Label1: TLabel;
    uygulamaAdiLabel: TLabel;
    programdanCikButton: TcxButton;
    baskaKullaniciyaGecButton: TcxButton;
    geriDonButton: TcxButton;
    ProgramRestartBtn: TcxButton;
    procedure programdanCikButtonClicked(Sender: TObject);
    procedure baskaKullaniciyaGecButtonClicked(Sender: TObject);
    procedure geriDonButtonClicked(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ProgramRestartBtnClick(Sender: TObject);
  private
    FModulAdi: string;
    procedure SetModulAdi(const Value: string);

    { Private declarations }

  public
    { Public declarations }
    property ModulAdi: string read FModulAdi write SetModulAdi;
  end;


  function AskForApplicationExit: Boolean;

implementation
uses
  UTablo, UYedekCalistir, UBekletme, FetaKurulusSiniflari, ULog;

{$R *.dfm}

function AskForApplicationExit: Boolean;
var
  prgExit : TProgramSonuDialog;
begin
  prgExit := TProgramSonuDialog.Create(Application);
  try
    Result := prgExit.ShowModal = mrOK;
  finally
    prgExit.Free;
  end;
end;

procedure TProgramSonuDialog.programdanCikButtonClicked(Sender: TObject);

    procedure YedekAl;
    var SonYedekTarihi:string;
    begin
        SonYedekTarihi := Tablo.GENINI.ReadString( StrToInt(inttoStr(Ops_Yedekleme_SonYedek_Cikis)),'01' + FormatSettings.DateSeparator + '01' + FormatSettings.DateSeparator + '1900');
        SonYedekTarihi := Tablo.SistemTarihFormatinaCevirme(SonYedekTarihi);
        if SonYedekTarihi <> Formatdatetime('dd'+FormatSettings.DateSeparator+'mm'+FormatSettings.DateSeparator+'yyyy', Tablo.GENINI.BugunTrh) then
           YedekCalistirDlg.YedeklemeCalistir(Tablo.GENINI.ReadString(Ops_Yedekleme_YedeklemeDizin, 'D:\'), Tablo.GENINI.ReadString( Ops_Yedekleme_Winrar,''));
    end;

begin
  if (Tablo.GetOnlineStatus) then begin  // R Yedekleme-'+kullanan,'Kapanirken', False)
    try
      ULog.LogYaz(liEkle, -1, StrToIntDef(Kullanan, 0),
      TLogKurucu.Yeni.Deger('Olay', 'Çıkış').Deger('Kullanıcı', Kullanan),
      '', -1, StrToIntDef(Kullanan, 0), StrToIntDef(Kullanan, 0));
      if Tablo.GENINI.ReadBoolean(Ops_Yedekleme_Kapanirken, False) then
         YedekAl;
    except
      RestartProgram := False;
      ModalResult := mrOK;
    end;
  end;
  RestartProgram := False;
  ModalResult := mrOK;
end;

procedure TProgramSonuDialog.ProgramRestartBtnClick(Sender: TObject);
begin
  try
    ULog.LogYaz(liEkle, -1, StrToIntDef(Kullanan, 0),
      TLogKurucu.Yeni.Deger('Olay', 'Çıkış').Deger('Kullanıcı', Kullanan),
      '', -1, StrToIntDef(Kullanan, 0), StrToIntDef(Kullanan, 0));
  finally
    RestartProgram := True;
    RestartParameters := '/Kullanici:'+IntToStr(KullaniciID)+' /Sifre:'+SifreliSifre;
    ModalResult := mrOK;
  end;
end;

procedure TProgramSonuDialog.baskaKullaniciyaGecButtonClicked(
  Sender: TObject);
begin
  try
    ULog.LogYaz(liEkle, -1, StrToIntDef(Kullanan, 0),
      TLogKurucu.Yeni.Deger('Olay', 'Çıkış').Deger('Kullanıcı', Kullanan),
      '', -1, StrToIntDef(Kullanan, 0), StrToIntDef(Kullanan, 0));
  finally
    RestartProgram := True;
    ModalResult := mrOK;
  end;
end;

procedure TProgramSonuDialog.FormCreate(Sender: TObject);
begin
  UygulamaAdiLabel.caption:= Application.Title;
end;

procedure TProgramSonuDialog.geriDonButtonClicked(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TProgramSonuDialog.SetModulAdi(const Value: string);
begin
  FModulAdi := Value;
  uygulamaAdiLabel.Caption := Value;
end;

end.

