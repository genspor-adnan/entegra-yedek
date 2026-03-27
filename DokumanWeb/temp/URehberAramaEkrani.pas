unit URehberAramaEkrani;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxStyles,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB,
  cxDBData, cxImageComboBox, cxMaskEdit, cxDropDownEdit, cxContainer,
  cxTextEdit, StdCtrls, ExtCtrls, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxControls, cxGridCustomView,
  cxGrid, ComCtrls, ToolWin, ADODB, cxLabel;

type
  TRehberAramaEkrani = class(TForm)
    AraQuery1: TADOQuery;
    dsAra: TDataSource;
    ToolBar2: TToolBar;
    YeniTus: TToolButton;
    ToolButton2: TToolButton;
    SecTus: TToolButton;
    KapatTus: TToolButton;
    GridCariArama: TcxGrid;
    GridCariAramaDBTableView1: TcxGridDBTableView;
    GridCariAramaDBTableView1ID: TcxGridDBColumn;
    GridCariAramaDBTableView1GRUP: TcxGridDBColumn;
    GridCariAramaDBTableView1KOD1: TcxGridDBColumn;
    GridCariAramaDBTableView1FIRMA1: TcxGridDBColumn;
    GridCariAramaDBTableView1ADSOYAD1: TcxGridDBColumn;
    GridCariAramaLevel1: TcxGridLevel;
    Panel1: TPanel;
    LabelPNO: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label12: TLabel;
    rbIcindeGecen: TRadioButton;
    rbBaslayan: TRadioButton;
    AraFirma: TcxTextEdit;
    AraYetkili: TcxTextEdit;
    AraKod: TcxTextEdit;
    ComboGrup: TcxImageComboBox;
    ToolBar1: TToolBar;
    LabelSon: TcxLabel;
    LabelSIK: TcxLabel;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
    procedure KapatTusClick(Sender: TObject);
    procedure AraTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure rbBaslayanClick(Sender: TObject);
    procedure rbIcindeGecenClick(Sender: TObject);
    procedure LabelSonClick(Sender: TObject);
    procedure AraQuery1AfterOpen(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RehberAramaEkrani: TRehberAramaEkrani;

implementation

uses Utablo,PrjConst;

{$R *.dfm}

procedure TRehberAramaEkrani.AraQuery1AfterOpen(DataSet: TDataSet);
begin
   SecTus.Visible := AraQuery1.RecordCount > 0;
end;

procedure TRehberAramaEkrani.AraTusClick(Sender: TObject);
var
  s, Fir,Yet,Kod,TFirma,TYet,TKod, Grup :string;
begin
  s := '';
  Fir := ' R.FIRMA ';
  Yet := ' P.ADSOYAD ';
  Kod := ' R.KOD ';
  if rbBaslayan.Checked then
  begin
    TFirma := Trim(AraFirma.Text) + '%';
    TYet := Trim(AraYetkili.Text) + '%';
    TKod := Trim(AraKod.Text) + '%';
  end
  else if rbIcindeGecen.Checked then
  begin
    TFirma := '%' + Trim(AraFirma.Text) + '%';
    TYet := '%' + Trim(AraYetkili.Text) + '%';
    TKod := '%' + Trim(AraKod.Text) + '%';
  end;
  if ComboGrup.Text <> '' then
     Grup := ' and GRUP='+IntToStr(ComboGrup.Properties.Items[ComboGrup.ItemIndex].Value)
  else
     Grup := '';
  AraQuery1.Close;
  if AraFirma.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Fir + ' LIKE ''' + TFirma +''''+ Grup + ' ORDER BY FIRMA'  //   and ' + gorulmeyecekkod
  else if AraYetkili.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and ' + Yet + ' LIKE ''' + TYet +''''+ Grup +'  ORDER BY FIRMA'             // and gorulmeyecekkod
  else if AraKod.Text <> '' then
    s := 'where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 and ' + Kod + ' LIKE ''' + TKod+'''' + Grup + '  ORDER BY ' + Kod     // and gorulmeyecekkod
  else if ComboGrup.Text <> '' then
    s := ' where R.ID > 0 and DURUM=1 and isnull(P.VARSAYILAN,1) = 1 '+Grup+ ' ORDER BY FIRMA'
  else
    Exit;
  AraQuery1.SQL.Text := ' select R.ID,KOD,FIRMA,GRUP,ADSOYAD '+
                        ' from REHBER R left outer join REHBERPERSONEL P on R.ID=P.REHBERID ';
  AraQuery1.SQL.Add(s);
  AraQuery1.open;
end;

procedure TRehberAramaEkrani.LabelSonClick(Sender: TObject);
begin
   AraQuery1.Close;
   AraQuery1.SQL.Text := ' select top 25 R.ID,R.KOD,R.FIRMA,R.GRUP, P.ADSOYAD from KULLANICI_REHBER K inner join REHBER R on K.REHBERID=R.ID '+
    ' left outer join REHBERPERSONEL P on K.REHBERID = P.REHBERID and  1 = CASE WHEN isnull (P.VARSAYILAN,1) = 1 THEN 1 ELSE 0 END '+
    ' where KULID = '+IntToStr(KullananID);
   if TcxLabel(Sender).Tag = 1 then
      AraQuery1.SQL.Add( 'order by K.DEGISTIRMETARIHI desc')
   else
      AraQuery1.SQL.Add(' order by SAY desc');
   AraQuery1.Open;
end;

procedure TRehberAramaEkrani.FormCreate(Sender: TObject);
begin
  // Kur kombosunu dolduralým
   if GenRegIni.RegReadString('', 'FirmaAramaTipi', '1', 'C') = '1' then
      rbBaslayan.Checked := True
   else //if GenRegIni.RegReadString('', 'FirmaAramaTipi', '0', 'C') = '1' then
      rbIcindeGecen.Checked := True;
   Tablo.GENINI.ReadImageSection(Ops_CariKart_Grup,TcxImageComboBoxProperties(ComboGrup.Properties).Items); //    CariKart_Grup
   ComboGrup.Properties.Items.Add;
   ComboGrup.Properties.Items[ComboGrup.ItemIndex].Description:='';
   ComboGrup.Properties.Items[ComboGrup.ItemIndex].Value:=-1;
   TcxImageComboBoxProperties(GridCariAramaDBTableView1GRUP.Properties).Items.Assign(ComboGrup.Properties.Items);
end;

procedure TRehberAramaEkrani.FormShow(Sender: TObject);
begin
   if ComboGrup.EditValue = 335 then begin
      LabelSon.Visible := False;
      LabelSIK.Visible := False;
      Caption:= RAEPersonelAramaEkrani;
      if (not AraQuery1.Active)or(AraQuery1.RecordCount<1) then
           AraTusClick(Self);
      //AramaEkr.Subtitle.Text := 'Kullanýcý eklemek için personel listesinden seçin. Yoksa + ile ekleyin.';
   end
   else begin
      Caption:= RAEAramaEkrani;
      LabelSon.Visible := True;
      LabelSIK.Visible := True;
   end;

   if AraFirma.Visible then
      AraFirma.SetFocus;
end;

procedure TRehberAramaEkrani.KapatTusClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TRehberAramaEkrani.rbBaslayanClick(Sender: TObject);
begin
  if rbBaslayan.Checked then
     GenRegIni.RegWriteString('', 'FirmaAramaTipi', '1', 'C');
  AraTusClick(Self) ;
end;

procedure TRehberAramaEkrani.rbIcindeGecenClick(Sender: TObject);
begin
  if rbIcindeGecen.Checked then
     GenRegIni.RegWriteString('', 'FirmaAramaTipi', '0', 'C');
  AraTusClick(Self);
end;

procedure TRehberAramaEkrani.SecTusClick(Sender: TObject);
begin
   if SecTus.Visible  then
      ModalResult := mrOk;
end;

procedure TRehberAramaEkrani.YeniTusClick(Sender: TObject);
var  ID : Integer;
begin
   ID := Tablo.RehberSihirbazBaslat(0,-100,-100,-100,StrToDate('01'+DateSeparator+'01'+DateSeparator+'1900'));
   if ID<>-99 then begin
      AraQuery1.Close;
      AraQuery1.SQL.Text := ' select * from REHBER where ID = '+ IntToStr(ID);
      AraQuery1.open;
   end;
end;

end.
