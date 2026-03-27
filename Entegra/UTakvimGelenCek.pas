unit UTakvimGelenCek;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, Menus, cxLookAndFeelPainters, DB, FireDAC.Comp.Client, DBCtrls, cxImage,
  cxDBEdit, cxTextEdit, StdCtrls, cxButtons, cxDBLabel, cxControls, cxContainer,
  cxEdit, cxLabel, ExtCtrls, ComCtrls, ToolWin,UTakvimIslemleri,Utablo,UGirisKutusuEx,UResim,
  JvDBImage, UParaDegisiklik, dxSkinLondonLiquidSky;

type
    TTakvimGelenCekDlg = class(TForm)
    tlb1: TToolBar;
    KaydetTus: TToolButton;
    IptalTus: TToolButton;
    SilTus: TToolButton;
    btn1: TToolButton;
    Iptal: TToolButton;
    pnl1: TPanel;
    cxTextEdit1: TcxTextEdit;
    TabCEK: TFDQuery;
    DtsCEK: TDataSource;
    Shape4: TShape;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxLabel6: TcxLabel;
    cxDBImage1: TcxDBImage;
    LabelTUTAR: TcxDBLabel;
    LabelYAZIYLA: TcxDBLabel;
    LabelKASIDETARIHI: TcxDBLabel;
    LabelKASIDEYERI: TcxDBLabel;
    cxLabel8: TcxLabel;
    cxLabel10: TcxLabel;
    cxLabel11: TcxLabel;
    cxLabel12: TcxLabel;
    cxLabel7: TcxLabel;
    LabelFIRMA: TcxDBLabel;
    LabelADRES: TcxDBLabel;
    LabelVERGI: TcxDBLabel;
    LabelCIROLU: TcxLabel;
    LabelHitap: TcxLabel;
    LabelDiyez: TcxLabel;
    LabelTLDiyez: TcxLabel;
    BelgeTus: TToolButton;
    ToolButton2: TToolButton;
    ImageGon: TJvDBImage;
    procedure IptalClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure IptalTusClick(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LabelHitapClick(Sender: TObject);
    procedure LabelKASIDEYERIClick(Sender: TObject);
    procedure TabCEKAfterPost(DataSet: TDataSet);
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
  TakvimGelenCekDlg: TTakvimGelenCekDlg;

implementation

uses FetaClassExtensions, FetaKurulusSiniflari;

{$R *.dfm}

procedure TTakvimGelenCekDlg.IptalClick(Sender: TObject);
begin
   Close;
end;

procedure TTakvimGelenCekDlg.IptalTusClick(Sender: TObject);
begin
   TabCek.Cancel;
end;

procedure TTakvimGelenCekDlg.KaydetTusClick(Sender: TObject);
begin
   TabCek.Post;
   //TakvimOnayDlg.Tag := -1;
   Close;
end;

procedure TTakvimGelenCekDlg.SilTusClick(Sender: TObject);
begin
   SilmeIslemler(TabCek.FieldByName('TUR').AsInteger, ID);
   Close;
end;

procedure TTakvimGelenCekDlg.DtsCEKStateChange(Sender: TObject);
begin
   KaydetTus.visible := DtsCek.State = dsEdit;
   IptalTus.visible := DtsCek.State = dsEdit;
   SilTus.visible := DtsCek.State <> dsEdit;
end;

procedure TTakvimGelenCekDlg.FormShow(Sender: TObject);
Var
  Hitap,Ciro:SmallInt;
begin
   TabCek.Close;
   TabCek.Params[0].Value := ID;
   TabCek.Open;
   //cirosu var yok kontrol
   Ciro:= 0;//TabCek.FieldByName('CIROLU').AsBoolean;
   if  Ciro > 0  then
      LabelCIROLU.Caption:='(Cirolu)';

   //Hitap kýsmý
   Hitap := TabCek.FieldByName('HITAP').AsInteger;
   case  Hitap of
      0:LabelHitap.Caption := ('HAMÝLÝNE ('+tablo.tabbizim.FieldByName('FIRMA').AsString+')'  );
      //1:LabelHitap.Caption := TabCek.FieldByName('FIRMA').AsString;
      Else LabelHitap.Caption := tablo.tabbizim.FieldByName('FIRMA').AsString ;
   end;
   LabelTLDiyez.Left:=LabelTUTAR.Left+LabelTUTAR.Width;
   LabelDiyez.Left:=LabelTUTAR.Left-LabelDiyez.Width;
end;


procedure TTakvimGelenCekDlg.LabelHitapClick(Sender: TObject);
Var
  yeniad : string;
  htp : Integer;
  eskiad : Variant;
  hitap : Variant;
  lst : TStringList;
  cmb : TComboBox;
  edt : TEdit;
begin

   Htp := TabCek.FieldByName('HITAP').AsInteger;
   hitap := 'Hamiline';
   lst := Dize.StringListOlarak('Hamiline;Þahsa');

   case  Htp of
      0:LabelHitap.Caption := ('HAMÝLÝNE ('+tablo.tabbizim.FieldByName('FIRMA').AsString+')'  );
      //1:LabelHitap.Caption := TabCek.FieldByName('FIRMA').AsString;
      Else LabelHitap.Caption := TabCek.FieldByName('FIRMA').AsString ;
   end;

   if TGirisKutusuEx.BilgiAlEx('Hitap/Kime',TGirdiDenetimleri.Create.
     ComboBox('Hitap',@hitap,lst,csDropDownList,False,procedure(AForm: TForm)
             begin
               cmb := TComboBox(AForm.FindComponent('Denetim0'));
               edt := TEdit(AForm.FindComponent('Denetim1'));
               edt.Visible := cmb.ItemIndex > 0;
             end).Edit('Yeni Adý',@eskiad)) = mrOk then
                   begin
                     if cmb.SelText='Hamiline' then begin
                            { DökümDlg açýk }
                       TabCek.Edit;
                       TabCek.FieldByName('HITAP').AsInteger := 0;
                       TabCek.Post;
                     end else begin
                       //tablo.tabbizim.Edit;
                       TabCek.Edit;
                       TabCek.FieldByName('HITAP').AsInteger := 1;
                       //tablo.tabbizim.FieldByName('FIRMA').AsString;
                       TabCek.Post;
                       //tablo.tabbizim.Post;
                     end;
                   end;
  lst.Free;
end;


procedure TTakvimGelenCekDlg.LabelKASIDEYERIClick(Sender: TObject);
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
        TabCEK.Open; }
     end;
   end;
end;

procedure TTakvimGelenCekDlg.LabelTUTARClick(Sender: TObject);
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

procedure TTakvimGelenCekDlg.TabCEKAfterPost(DataSet: TDataSet);
begin
   LabelTLDiyez.Left:=LabelTUTAR.Left+LabelTUTAR.Width;
   LabelDiyez.Left:=LabelTUTAR.Left-LabelDiyez.Width;
end;

procedure TTakvimGelenCekDlg.BelgeTusClick(Sender: TObject);
begin

   if TabCek.State in [dsEdit, dsInsert] then
      TabCek.Post;
   Application.CreateForm(TResimDlg, ResimDlg);
   ResimDlg.Yeri := 3;
   ResimDlg.YerId := TabCek.fieldbyname('ID').AsInteger;
   ResimDlg.ShowModal;
   ResimDlg.Destroy;

end;

end.



