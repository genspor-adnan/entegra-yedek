unit UOpsiyonKalite;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxLabel, cxControls, cxContainer, cxEdit, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxImageComboBox,Utablo, StdCtrls, Buttons,PrjConst,
  ExtCtrls, cxPC, cxLookAndFeelPainters, cxCheckBox, cxGroupBox, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxButtonEdit,UKodAgaci, cxLookAndFeels, cxPCdxBarPopupMenu, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinOffice2016Colorful, dxSkinOffice2016Dark, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxBarBuiltInMenu, Vcl.Menus, cxButtons;

type
  TOpsiyonKaliteDlg = class(TForm)
    Panel1: TPanel;
    CancelBtn: TBitBtn;
    KaydetTus: TBitBtn;
    cxPageControl1: TcxPageControl;
    SheetToplanti: TcxTabSheet;
    cxLabel5: TcxLabel;
    ComboBilgiRapor: TcxImageComboBox;
    CheckKaliteKontrol: TcxCheckBox;
    BtnStokKaliteParametreleri: TcxButton;
    cxButton1: TcxButton;
    BtnKaliteTestListesi: TcxButton;
    procedure CancelBtnClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckKaliteKontrolClick(Sender: TObject);
    procedure BtnStokKaliteParametreleriClick(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure BtnKaliteTestListesiClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpsiyonKaliteDlg: TOpsiyonKaliteDlg;

implementation

Uses FetaKurulusSiniflari, UKaliteParametre; //LocOnFly;

{$R *.dfm}

procedure TOpsiyonKaliteDlg.BtnKaliteTestListesiClick(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_KaliteTestleri);
   //Tablo.GENINI.ReadImageSection(Ops_KaliteOlcuAletleri, Tablo.RepKaliteOlcuAleti.Properties.Items, True);
end;

procedure TOpsiyonKaliteDlg.BtnStokKaliteParametreleriClick(Sender: TObject);
begin
  Application.CreateForm(TKaliteParametreDlg,KaliteParametreDlg);
  KaliteParametreDlg.ShowModal;
  FreeAndNil(KaliteParametreDlg);
end;

procedure TOpsiyonKaliteDlg.CancelBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TOpsiyonKaliteDlg.CheckKaliteKontrolClick(Sender: TObject);
begin
   if CheckKaliteKontrol.Checked then begin
      try
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'IF NOT EXISTS (SELECT * FROM sys.columns  WHERE object_id = OBJECT_ID(''STOKLAR'') AND name = ''KALITEKONTROLAKTIF'')'+
                      ' alter table STOKLAR add KALITEKONTROLAKTIF bit',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'IF NOT EXISTS (SELECT * FROM sys.columns  WHERE object_id = OBJECT_ID(''STOKLAR'') AND name = ''KALITEKONTROL'')'+
                      'alter table STOKLAR add KALITEKONTROL nvarchar(30)',[],[]);
       Veritabani.BasitKomutÇalıştır(Tablo.FDCnn, 'IF NOT EXISTS (SELECT * FROM sys.columns  WHERE object_id = OBJECT_ID(''STOKLAR'') AND name = ''KALITESABLONID '')'+
                      'alter table STOKLAR add KALITESABLONID  int',[],[]);
      finally

      end;
   end;
end;

procedure TOpsiyonKaliteDlg.cxButton1Click(Sender: TObject);
begin
   Tablo.GeniniBaslat(Ops_KaliteOlcuAletleri);
   Tablo.GENINI.ReadImageSection(Ops_KaliteOlcuAletleri, Tablo.RepKaliteOlcuAleti.Properties.Items, True);
end;

procedure TOpsiyonKaliteDlg.FormCreate(Sender: TObject);
begin
  //LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
end;

procedure TOpsiyonKaliteDlg.FormShow(Sender: TObject);
begin
   ComboBilgiRapor.EditValue  := Tablo.GENINI.ReadInteger(Ops_OpsiyonKalite_BilgilendirmeMailrapor,-1);
   CheckKaliteKontrol.Checked := Tablo.GENINI.ReadBoolean(Ops_CheckKaliteKontrol, False);
End;

procedure TOpsiyonKaliteDlg.KaydetTusClick(Sender: TObject);
begin
   Tablo.GENINI.WriteInteger(Ops_OpsiyonKalite_BilgilendirmeMailrapor,ComboBilgiRapor.EditValue);//  Opsiyon Servis  E-Posta İle Bilgilendirme  Kullanılacak Rapor
   Tablo.GENINI.WriteBoolean(Ops_CheckKaliteKontrol, CheckKaliteKontrol.Checked);

   ModalResult := mrOk;
end;

end.


