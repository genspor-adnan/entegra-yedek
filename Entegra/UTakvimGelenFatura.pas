unit UTakvimGelenFatura;

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
  cxGridDBTableView, cxGrid, cxButtons, cxMemo, GIFImg, DBCtrls,UGirisKutusuEx,
  JvDBImage;

type
  TTakvimGelenFaturaDlg = class(TForm)
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
    TabKasa: TFDQuery;
    DtsKasa: TDataSource;
    GridPlan: TcxGrid;
    GridPlanView: TcxGridDBTableView;
    GridPlanLevel1: TcxGridLevel;
    pnl2: TPanel;
    pnl1: TPanel;
    imgMALIYE: TImage;
    shp1: TShape;
    shp2: TShape;
    LabelMasrafKod1: TcxLabel;
    LabelDURUM: TcxDBLabel;
    LabelFTARIH: TcxDBLabel;
    LabelTARIH: TcxDBLabel;
    LabelMasrafKod2: TcxLabel;
    LabelACIKLAMA: TcxDBLabel;
    LabelFaturaTarihi: TcxLabel;
    LabelMasrafKod3: TcxLabel;
    LabelKur: TcxDBLabel;
    LabelMasrafAd: TcxLabel;
    LabelREHBERID: TcxDBLabel;
    CariSecTus: TcxButton;
    LabelPlansiz: TcxLabel;
    LabelPlanli: TcxLabel;
    LabelMasrafKodLabelCariAd: TcxLabel;
    cxTextEdit1: TcxTextEdit;
    LabelADRES: TcxDBLabel;
    LabelFATURABASLIK: TcxDBLabel;
    LabelILCE: TcxDBLabel;
    LabelVERGIDAI: TcxDBLabel;
    LabelVERGINO: TcxDBLabel;
    LabelIL: TcxDBLabel;
    LabelMasrafKod4: TcxLabel;
    LabelMasrafKod5: TcxLabel;
    LabelFATURA_MATRAHI: TcxDBLabel;
    LabelKDV_TUTARI: TcxDBLabel;
    LabelFATURA_TUTARI: TcxDBLabel;
    LabelMASRAFID: TcxLabel;
    LabelCariKod: TcxLabel;
    LabelMasrafKod: TcxLabel;
    LabelMasrafKod6: TcxLabel;
    LabelFNO: TcxDBLabel;
    LabelCariAd: TcxLabel;
    BelgeTus: TToolButton;
    ToolButton2: TToolButton;
    Logo: TJvDBImage;
    cxDBImage1: TJvDBImage;
    procedure TabKasaAfterOpen(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure EditMasrafKodPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure KaydetTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure btnIptalClick(Sender: TObject);
    procedure CariSecTusClick(Sender: TObject);
    procedure DtsKasaStateChange(Sender: TObject);
    procedure LabelFTARIHClick(Sender: TObject);
    procedure BelgeTusClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ID : Integer;
  end;

var
  TakvimGelenFaturaDlg: TTakvimGelenFaturaDlg;

implementation

{$R *.dfm}

uses UTablo, UTakvimIslemleri, PrjConst, ULOGO,UResim;

procedure TTakvimGelenFaturaDlg.BelgeTusClick(Sender: TObject);
begin
   if TabKasa.State in [dsEdit, dsInsert] then
      TabKasa.Post;
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.Yeri := 1;
   ResimDlg.YerId := TabKasa.fieldbyname('ID').AsInteger;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;
    {Application.CreateForm(TBelgeIslemleriDlg,BelgeIslemleriDlg);
    BelgeIslemleriDlg.Yeri:= 1;
    BelgeIslemleriDlg.Yer_Id := TabKasa.fieldbyname('ID').AsInteger;
    BelgeIslemleriDlg.ShowModal;
    BelgeIslemleriDlg.Destroy; }
end;

procedure TTakvimGelenFaturaDlg.btnIptalClick(Sender: TObject);
begin
   Close;
end;



procedure TTakvimGelenFaturaDlg.CariSecTusClick(Sender: TObject);
begin
   GridPlan.Visible := not GridPlan.Visible;
   if GridPlan.Visible then
      Height := 472
   else
      Height := 290
end;

procedure TTakvimGelenFaturaDlg.DtsKasaStateChange(Sender: TObject);
begin
   KaydetTus.visible := DtsKasa.State = dsEdit;
   IptalTus.visible := DtsKasa.State = dsEdit;
   SilTus.visible := DtsKasa.State <> dsEdit;
end;

procedure TTakvimGelenFaturaDlg.EditMasrafKodPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  MasrafMrkSecimi(TabKasa.FieldByName('TUR').AsInteger, TabKasa, LabelMasrafKod, LabelMasrafAd);
end;

procedure TTakvimGelenFaturaDlg.FormShow(Sender: TObject);
begin
   Tablo.TabBizim.Close;
   Tablo.TabBizim.Open;
   TabKasa.Close;
   TabKasa.Params[0].Value := ID;
   TabKasa.Open;

   if TabKasa.FieldByName('TUR').AsInteger=15 then begin //11 gelen fatura veya 12 gelen fiþ
       Caption := SGelenFaturaBilgileri ;
       LabelFaturaTarihi.Caption := SFaturaTarihi;
       LabelMasrafKod6.Caption := SFaturaNo;
   end else begin //Fiþ
       Caption := SGelenFisBilgileri ;
       LabelFaturaTarihi.Caption := SFisTarihi;
       LabelMasrafKod6.Caption := SFisNo;
   end;

end;

procedure TTakvimGelenFaturaDlg.IptalTusClick(Sender: TObject);
begin
   TabKasa.Cancel;
end;

procedure TTakvimGelenFaturaDlg.KaydetTusClick(Sender: TObject);
begin
   TabKasa.Post;
   //TakvimOnayDlg.Tag := -1;
   Close;
end;

procedure TTakvimGelenFaturaDlg.LabelFTARIHClick(Sender: TObject);
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

procedure TTakvimGelenFaturaDlg.SilTusClick(Sender: TObject);
begin
   SilmeIslemler(TabKasa.FieldByName('TUR').AsInteger, ID);
   Close;
end;

procedure TTakvimGelenFaturaDlg.TabKasaAfterOpen(DataSet: TDataSet);
begin
   RehberBilgileri(TabKasa.FieldByName('REHBERID').AsString,LabelCariKod, LabelCariAd );
   MasrafBilgileri(TabKasa.FieldByName('MASRAFID').AsString,LabelMasrafKod, LabelMasrafAd);

   LabelPlanli.Visible := TabKasa.FieldByName('ODEMEPLANI').AsBoolean;
   LabelPlansiz.Visible :=  not LabelPlanli.Visible;
end;

end.



