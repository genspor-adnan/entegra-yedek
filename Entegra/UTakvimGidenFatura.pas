unit UTakvimGidenFatura;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy, dxSkinGlassOceans,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black, dxSkinOffice2007Blue,
  dxSkinOffice2007Green, dxSkinOffice2007Pink, dxSkinOffice2007Silver,
  dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver, dxSkinSpringTime,
  dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinXmas2008Blue, cxGraphics, DB, FireDAC.Comp.Client, StdCtrls, cxDBEdit, cxCurrencyEdit,
  cxDBLabel, cxDropDownEdit, cxCalendar, cxImageComboBox, ComCtrls, ToolWin,
  cxTextEdit, cxMaskEdit, cxButtonEdit, cxControls, cxContainer, cxEdit,
  cxLabel, ExtCtrls, Menus, cxLookAndFeelPainters, dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxDBData, cxImage, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, cxButtons, cxMemo, jpeg, GIFImg,JvDBImage, DBCtrls,
  UGirisKutusuEx,UBelgeIslemleri;

type
  TTakvimGidenFaturaDlg = class(TForm)
    ToolBar1: TToolBar;
    SilTus: TToolButton;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    ToolButton1: TToolButton;
    btnIptal: TToolButton;
    ToolBarAlt: TToolBar;
    NakitTus: TToolButton;
    HavaleTus: TToolButton;
    CekTus: TToolButton;
    SenetTus: TToolButton;
    Panel1: TPanel;
    cxLabel9: TcxLabel;
    LabelTARIH: TcxDBLabel;
    cxLabel12: TcxLabel;
    LabelFaturaTarihi: TcxLabel;
    cxLabel8: TcxLabel;
    LabelMasrafAd: TcxLabel;
    TabKasa: TFDQuery;
    DtsKasa: TDataSource;
    CariSecTus: TcxButton;
    LabelPlansiz: TcxLabel;
    GridPlan: TcxGrid;
    GridPlanView: TcxGridDBTableView;
    GridPlanLevel1: TcxGridLevel;
    LabelPlanli: TcxLabel;
    ImageMALIYE: TImage;
    cxTextEdit1: TcxTextEdit;
    LabelADRES: TcxDBLabel;
    LabelFATURABASLIK: TcxDBLabel;
    LabelILCE: TcxDBLabel;
    LabelVERGIDAI: TcxDBLabel;
    LabelVERGINO: TcxDBLabel;
    LabelIL: TcxDBLabel;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    LabelFATURA_MATRAHI: TcxDBLabel;
    LabelKDV_TUTARI: TcxDBLabel;
    LabelFATURA_TUTARI: TcxDBLabel;
    Shape1: TShape;
    Shape2: TShape;
    LabelMASRAFID: TcxLabel;
    LabelCariKod: TcxLabel;
    LabelMasrafKod: TcxLabel;
    cxLabel3: TcxLabel;
    LabelFNO: TcxDBLabel;
    LabelCariAd: TcxLabel;
    BelgeTus: TToolButton;
    ToolButton3: TToolButton;
    Logo: TJvDBImage;
    cxDBImage1: TJvDBImage;
    procedure TabKasaAfterOpen(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
    procedure CariSecTusClick(Sender: TObject);
    procedure DtsKasaStateChange(Sender: TObject);
    procedure LabelMasrafAdClick(Sender: TObject);
    procedure LabelFATURABASLIKClick(Sender: TObject);
    procedure BelgeTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ID : Integer;
  end;

var
  TakvimGidenFaturaDlg: TTakvimGidenFaturaDlg;

implementation

{$R *.dfm}

uses UTablo, UTakvimIslemleri, PrjConst, ULOGO,UResim;

procedure TTakvimGidenFaturaDlg.BelgeTusClick(Sender: TObject);
begin
   if TabKasa.State in [dsEdit, dsInsert] then
      TabKasa.Post;
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.Yeri := 1;
   ResimDlg.YerId := TabKasa.fieldbyname('ID').AsInteger;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;
   { Application.CreateForm(TBelgeIslemleriDlg,BelgeIslemleriDlg);
    BelgeIslemleriDlg.Yeri:= 1;
    BelgeIslemleriDlg.Yer_Id := TabKasa.fieldbyname('ID').AsInteger;
    BelgeIslemleriDlg.ShowModal;
    BelgeIslemleriDlg.Destroy; }
end;

procedure TTakvimGidenFaturaDlg.btnIptalClick(Sender: TObject);
begin
   Close;
end;

procedure TTakvimGidenFaturaDlg.CariSecTusClick(Sender: TObject);
begin
   GridPlan.Visible := not GridPlan.Visible;
   if GridPlan.Visible then
      Height := 472
   else
      Height := 300
end;

procedure TTakvimGidenFaturaDlg.DtsKasaStateChange(Sender: TObject);
begin
   KaydetTus.visible := DtsKasa.State = dsEdit;
   IptalTus.visible := DtsKasa.State = dsEdit;
   SilTus.visible := DtsKasa.State <> dsEdit;
end;

procedure TTakvimGidenFaturaDlg.FormShow(Sender: TObject);
begin
   //DurumListele(ComboDURUM, FaturaGirenStatuList);
   TabKasa.Close;
   TabKasa.Params[0].Value := ID;
   TabKasa.Open;
   //Logo.Picture.Assign(Tabkasa.FieldByName('LOGO'));
   if TabKasa.FieldByName('TUR').AsInteger=11 then begin //11 gelen fatura veya 12 gelen fiþ
       Caption := SGelenFaturaBilgileri ;
       LabelFaturaTarihi.Caption := SFaturaTarihi;
       cxLabel3.Caption := SFaturaNo;
   end else begin //Fiþ
       Caption := SGelenFisBilgileri ;
       LabelFaturaTarihi.Caption := SFisTarihi;
       cxLabel3.Caption := SFisNo;
   end;
end;

procedure TTakvimGidenFaturaDlg.IptalTusClick(Sender: TObject);
begin
   TabKasa.Cancel;
end;

procedure TTakvimGidenFaturaDlg.KaydetTusClick(Sender: TObject);
begin
   TabKasa.Post;
   //TakvimOnayDlg.Tag := -1;
   Close;
end;

procedure TTakvimGidenFaturaDlg.LabelFATURABASLIKClick(Sender: TObject);
var
   alanTuru,alanAdi,alanOwner : String;
   eskiad : Variant;
   ctrls : TGirdiDenetimleri;
begin
   alanAdi := TcxDBLabel(Sender).DataBinding.DataField ;
   eskiad := TcxDBLabel(Sender).Caption;
   case TcxDBLabel(Sender).Tag of
      //edit bilgi giriþi
      1 : ctrls := TGirdiDenetimleri.Create.Edit(('Yeni '+alanAdi+' Deðeri'),@eskiad);
      //date bilgi giriþi
      2 : ctrls := TGirdiDenetimleri.Create.DateTimePicker(('Yeni '+alanAdi+' Deðeri'),@eskiad);
   end;
   if TGirisKutusuEx.BilgiAlEx('Yeni bilgiyi girin',ctrls) = mrOK then begin
     if Trim(eskiad) = '' then begin
        MessageDlg(('Yeni '+alanAdi+' Deðeri Boþ Olamaz.'),mtError,[mbOK],0);
        Exit; End
      else begin
        TabKasa.Edit;
        TabKasa.FieldByName(alanAdi).AsVariant:= eskiad;
        TabKasa.Post;
     end;
   end;

end;

procedure TTakvimGidenFaturaDlg.LabelMasrafAdClick(Sender: TObject);
begin
  MasrafMrkSecimi(TabKasa.FieldByName('TUR').AsInteger, TabKasa, LabelMasrafKod, LabelMasrafAd);

end;

procedure TTakvimGidenFaturaDlg.SilTusClick(Sender: TObject);
begin
   SilmeIslemler(TabKasa.FieldByName('TUR').AsInteger, ID);
   Close;
end;

procedure TTakvimGidenFaturaDlg.TabKasaAfterOpen(DataSet: TDataSet);
begin
   RehberBilgileri(TabKasa.FieldByName('REHBERID').AsString,LabelCariKod, LabelCariAd );
   MasrafBilgileri(TabKasa.FieldByName('MASRAFID').AsString,LabelMASRAFID,LabelMasrafAd);

   LabelPlanli.Visible := TabKasa.FieldByName('ODEMEPLANI').AsBoolean;
   LabelPlansiz.Visible :=  not LabelPlanli.Visible;
end;

end.
