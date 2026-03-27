unit UTakvimGidenCek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, DB, FireDAC.Comp.Client, cxDBLabel, cxImage, cxDBEdit, cxLabel,
  cxControls, cxContainer, cxEdit, cxTextEdit, ExtCtrls, ComCtrls, ToolWin,UTakvimIslemleri,
  Utablo,UGirisKutusuEx,UResim, DBCtrls, JvDBImage,UParaDegisiklik,
  dxSkinLondonLiquidSky;

type
  TTakvimGidenCekDlg = class(TForm)
    Shape4: TShape;
    tlb1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    SilTus: TToolButton;
    btn1: TToolButton;
    Iptal: TToolButton;
    pnl1: TPanel;
    cxTextEdit1: TcxTextEdit;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxDBImage1: TcxDBImage;
    cxLabel8: TcxLabel;
    LabelKASIDEYERI: TcxDBLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    cxLabel12: TcxLabel;
    LabelYAZIYLA: TcxDBLabel;
    LabelKASIDETARIHI: TcxDBLabel;
    cxLabel7: TcxLabel;
    LabelTUTAR: TcxDBLabel;
    LabelFIRMA: TcxDBLabel;
    LabelADRES: TcxDBLabel;
    LabelVERGI: TcxDBLabel;
    TabCEK: TFDQuery;
    DtsCEK: TDataSource;
    LabelCirolu: TcxLabel;
    LabelDiyez: TcxLabel;
    LabelTLDiyez: TcxLabel;
    BelgeTus: TToolButton;
    ToolButton2: TToolButton;
    LabelVergiNo: TcxDBLabel;
    ImageGon: TJvDBImage;
    LabelHitap: TcxLabel;
    procedure KaydetTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure IptalClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabCEKAfterPost(DataSet: TDataSet);
    procedure LabelKASIDETARIHIClick(Sender: TObject);
    procedure DtsCEKStateChange(Sender: TObject);
    procedure BelgeTusClick(Sender: TObject);
    procedure LabelTUTARClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ID : Integer;
  end;

var
  TakvimGidenCekDlg: TTakvimGidenCekDlg;

implementation

{$R *.dfm}

procedure TTakvimGidenCekDlg.IptalClick(Sender: TObject);
begin
   Close;
end;

procedure TTakvimGidenCekDlg.IptalTusClick(Sender: TObject);
begin
   TabCek.Cancel;
end;

procedure TTakvimGidenCekDlg.KaydetTusClick(Sender: TObject);
begin
   TabCek.Post;
   //TakvimOnayDlg.Tag := -1;
   Close;
end;

procedure TTakvimGidenCekDlg.SilTusClick(Sender: TObject);
begin
   SilmeIslemler(TabCek.FieldByName('TUR').AsInteger, ID);
   Close;
end;

procedure TTakvimGidenCekDlg.BelgeTusClick(Sender: TObject);
begin
   if TabCek.State in [dsEdit, dsInsert] then
      TabCek.Post;
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.Yeri := 3;
   ResimDlg.YerId := TabCek.fieldbyname('ID').AsInteger;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;

    {Application.CreateForm(TBelgeIslemleriDlg,BelgeIslemleriDlg);
    BelgeIslemleriDlg.Yeri:= 3;
    BelgeIslemleriDlg.Yer_Id := TabCEK.fieldbyname('ID').AsInteger;
    BelgeIslemleriDlg.ShowModal;
    BelgeIslemleriDlg.Destroy;}
end;

procedure TTakvimGidenCekDlg.DtsCEKStateChange(Sender: TObject);
begin
   KaydetTus.visible := DtsCek.State = dsEdit;
   IptalTus.visible := DtsCek.State = dsEdit;
   SilTus.visible := DtsCek.State <> dsEdit;
end;

procedure TTakvimGidenCekDlg.FormShow(Sender: TObject);
var
  hitap:SmallInt;
begin
   TabCek.Close;
   TabCek.Params[0].Value := ID;
   TabCek.Open;
   //cirosu var yok kontrol
   if TabCek.FieldByName('CIROLU').AsBoolean   then
      LabelCIROLU.Caption:='(Cirolu)';
   LabelTLDiyez.Left:=LabelTUTAR.Left+LabelTUTAR.Width;
   LabelDiyez.Left:=LabelTUTAR.Left-LabelDiyez.Width;
   LabelVergiNo.Left:=LabelVERGI.left+LabelVERGI.Width+2;
   Hitap := TabCek.FieldByName('HITAP').AsInteger;
   case  Hitap of
      0:LabelHitap.Caption := ('HAMÝLÝNE ('+tabcek.FieldByName('FIRMA').AsString+')'  );
      //1:LabelHitap.Caption := TabCek.FieldByName('FIRMA').AsString;
      Else LabelHitap.Caption := TabCek.FieldByName('FIRMA').AsString ;
   end;
end;

Procedure TTakvimGidenCekDlg.TabCEKAfterPost(DataSet: TDataSet);
begin
   LabelTLDiyez.Left:=LabelTUTAR.Left+LabelTUTAR.Width;
   LabelDiyez.Left:=LabelTUTAR.Left-LabelDiyez.Width;
end;

procedure TTakvimGidenCekDlg.LabelKASIDETARIHIClick(Sender: TObject);
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
        TabCEK.Edit;
        TabCEK.FieldByName(alanAdi).AsVariant:= eskiad;
        {TabCEK.Post;
        TabCEK.Close;
        TabCEK.Open;}
     end;
   end;

end;

procedure TTakvimGidenCekDlg.LabelTUTARClick(Sender: TObject);
begin
  Application.CreateForm(TParaDegisiklikDlg,Paradegisiklikdlg);
  Paradegisiklikdlg.KurTarihi := TabCEK.FieldByName('TARIH').AsDateTime; //KasaTarihi.Date;
  Paradegisiklikdlg.GirenTutar := TabCEK.FieldByName(LabelTutar.DataBinding.DataField).AsCurrency; //EditTahsilatTutar.Value;
  Paradegisiklikdlg.GirenKur := TabCEK.FieldByName('KUR').AsString; //ComboKurTah.Text;
  Paradegisiklikdlg.CikanTutar := TabCEK.FieldByName('DOVIZ_TUTARI').AsCurrency; //EditDovizTutar.Value;
  Paradegisiklikdlg.CikanKur := TabCEK.FieldByName('DOVIZ_KURU').AsString; //ComboDovizTutar.Text;
  Paradegisiklikdlg.ShowModal;
  if Paradegisiklikdlg.ModalResult = mrOk then begin
     if DtsCEK.State <> dsEdit then
        TabCEK.Edit;
     TabCEK.FieldByName(LabelTutar.DataBinding.DataField).Value := Paradegisiklikdlg.GirenTutar;
     TabCEK.FieldByName('KUR').Value := Paradegisiklikdlg.GirenKur;
     TabCEK.FieldByName('DOVIZ_TUTARI').Value := Paradegisiklikdlg.CikanTutar;
     TabCEK.FieldByName('DOVIZ_KURU').Value := Paradegisiklikdlg.CikanKur;
     TabCEK.Post;
  end;
  Paradegisiklikdlg.Free;
  FormShow(Self);
end;

end.

