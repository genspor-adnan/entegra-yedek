unit UFaturaKapama;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter,
  cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  FireDAC.Comp.Client, Menus, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Utablo, ExtCtrls,
  Fetautil, FetaKurulusSiniflari, cxLookAndFeels, cxLookAndFeelPainters, dxSkinLiquidSky,
  cxNavigator, cxContainer, cxLabel, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxSplitter,
  System.Generics.Collections, Vcl.StdCtrls, cxButtons, cxRadioGroup,
  JvExControls, JvNavigationPane;

type

  TVurguYonetici = class;

  TFaturaKapamaDlg = class(TForm)
    PopupBorc: TPopupMenu;
    TabBorc: TFDQuery;
    DtsBorc: TDataSource;
    Panel1: TPanel;
    GridBASolDBTableViewBorc: TcxGridDBTableView;
    GridBASolLevel1: TcxGridLevel;
    GridBASol: TcxGrid;
    GridBASag: TcxGrid;
    GridBASagDBTableViewAlacak: TcxGridDBTableView;
    GridBASagLevel1: TcxGridLevel;
    TabAlacak: TFDQuery;
    PopupAlacak: TPopupMenu;
    DtsAlacak: TDataSource;
    GridBASagDBTableViewAlacakTARIH: TcxGridDBColumn;
    GridBASagDBTableViewAlacakANAHTAR: TcxGridDBColumn;
    GridBASagDBTableViewAlacakTUTAR: TcxGridDBColumn;
    GridBASagDBTableViewAlacakKUR: TcxGridDBColumn;
    GridBASagDBTableViewAlacakKAPANAN: TcxGridDBColumn;
    GridBASolDBTableViewBorcTARIH: TcxGridDBColumn;
    GridBASolDBTableViewBorcANAHTAR: TcxGridDBColumn;
    GridBASolDBTableViewBorcTUTAR: TcxGridDBColumn;
    GridBASolDBTableViewBorcKUR: TcxGridDBColumn;
    GridBASolDBTableViewBorcKAPANAN: TcxGridDBColumn;
    GridBASagDBTableViewAlacakKALAN: TcxGridDBColumn;
    GridBASolDBTableViewBorcKALAN: TcxGridDBColumn;
    Busatrnbalantlarnsil1: TMenuItem;
    Busatrnbalantlarnsil2: TMenuItem;
    GridBASagDBTableViewAlacakVADE: TcxGridDBColumn;
    GridBASolDBTableViewBorcVADE: TcxGridDBColumn;
    cxStyleRepository1: TcxStyleRepository;
    cxStyleSeciliHucre: TcxStyle;
    GridBASagDBTableViewAlacakTUR: TcxGridDBColumn;
    GridBASagDBTableViewAlacakID: TcxGridDBColumn;
    GridBASolDBTableViewBorcTUR: TcxGridDBColumn;
    GridBASolDBTableViewBorcID: TcxGridDBColumn;
    TabCapraz: TFDQuery;
    cxStyle1: TcxStyle;
    GridBASolDBTableViewBorcBELGENO: TcxGridDBColumn;
    GridBASagDBTableViewAlacakBELGENO: TcxGridDBColumn;
    cxSplitter1: TcxSplitter;
    JvNavPanelHeader4: TJvNavPanelHeader;
    Label1: TcxLabel;
    Label2: TcxLabel;
    RadioModIzle: TcxRadioButton;
    RadioModEsle: TcxRadioButton;
    cxComboBox1: TcxComboBox;
    BtnEslestir: TcxButton;
    MemoAlacakSQL: TMemo;
    LabelAyrim: TcxLabel;
    RadioRenk: TcxRadioButton;
    RadioSuzme: TcxRadioButton;
    procedure BtnEslestirClick(Sender: TObject);
    procedure Yenile;
    procedure FormShow(Sender: TObject);
    procedure Busatrnbalantlarnsil1Click(Sender: TObject);
    procedure Busatrnbalantlarnsil2Click(Sender: TObject);
    procedure cxComboBox1PropertiesEditValueChanged(Sender: TObject);
    procedure GridBASagDBTableViewAlacakCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure TabCaprazAfterOpen(DataSet: TDataSet);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioModIzleClick(Sender: TObject);
    procedure RadioRenkClick(Sender: TObject);
    procedure TabBorcAfterScroll(DataSet: TDataSet);
    procedure GridBASolDBTableViewBorcCanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
    procedure GridBASagDBTableViewAlacakStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridBASolDBTableViewBorcStylesGetContentStyle(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure GridBASagDBTableViewAlacakCanFocusRecord(
      Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
      var AAllow: Boolean);
  private
    { Private declarations }
    FVurguYonetici : TVurguYonetici;
    procedure RepaintGridView(AGridView:TcxGridDBTableView);
  public
    { Public declarations }
    RehberID:Integer;
  end;

  TVurguBilgi = class
  public
    HedefTur : Integer;
    HedefId  : Integer;

    constructor Create(AHedefId, AHedefTur: Integer);
  end;

  TVurguKipi = (vkYok,vkBorc,vkAlacak);

  TVurguYonetici = class
  private
    FKip : TVurguKipi;
    FVurguStili : TcxStyle;
    FVurguBilgi : TObjectList<TVurguBilgi>;
  public
    constructor Create;
    destructor Destroy;override;
    procedure VurgulariYukle(AKaynakId,AKaynakTur: Integer;AKip: TVurguKipi);
    function Vurgula(AHedefId, AHedefTur: Integer;AKip: TVurguKipi): Boolean;
    property Kip : TVurguKipi read FKip;
    property VurguStili : TcxStyle read FVurguStili write FVurguStili;
  end;

  TVurguAlan = record
    KaynakId: string;
    KaynakTur: string;
    HedefId: string;
    HedefTur: string;
  end;

const
  VurguAlanlar: array[TVurguKipi] of TVurguAlan =
   (
     (KaynakId:''; KaynakTur: ''; HedefId: '';HedefTur: ''),
     (KaynakId:'BORCID'; KaynakTur: 'BORCTUR'; HedefId: 'ALACAKID';HedefTur: 'ALACAKTUR'),
     (KaynakId:'ALACAKID'; KaynakTur: 'ALACAKTUR'; HedefId: 'BORCID';HedefTur: 'BORCTUR')
   );


var
  FaturaKapamaDlg: TFaturaKapamaDlg;

implementation

   Uses LocOnFly,PrjConst, FetaClassExtensions, UAnaForm;
{$R *.dfm}

procedure TFaturaKapamaDlg.BtnEslestirClick(Sender: TObject);
var Tutar: Currency;
begin
  if (TabAlacak.RecordCount>0)and(TabBorc.RecordCount>0) then begin
    if TabAlacak.FieldByName('KALAN').AsCurrency>TabBorc.FieldByName('KALAN').AsCurrency then
      Tutar := TabBorc.FieldByName('KALAN').AsCurrency
    else
      Tutar := TabAlacak.FieldByName('KALAN').AsCurrency;
    if Tutar > 0 then begin
      //o satır için daha önceden girilmiş bir eşleştirme var ise önce o eşleştirmeyi sileriz..
      Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from BORCKAPATMA where REHBERID=&RID and BORCTUR=&BT and BORCID=&BID and ALACAKTUR=&AT and ALACAKID=&AID '
                                  ,['&RID','&BT','&BID','&AT','&AID']
                                  ,[RehberID,TabBorc.FieldByName('TUR').AsInteger,TabBorc.FieldByName('ID').AsInteger,TabAlacak.FieldByName('TUR').AsInteger,TabAlacak.FieldByName('ID').AsInteger]);
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'insert into BORCKAPATMA(REHBERID,BORCTUR,BORCID,ALACAKTUR,ALACAKID,BORCTUTAR,ALACAKTUTAR,TUTAR,EKLEYEN) ';
      Tablo.Query1.SQL.Add('values(:P0,:P1,:P2,:P3,:P4,:P5,:P6,:P7,:P8)');
      Tablo.Query1.Params[0].Value := RehberID;
      Tablo.Query1.Params[1].Value := TabBorc.FieldByName('TUR').AsInteger;
      Tablo.Query1.Params[2].Value := TabBorc.FieldByName('ID').AsInteger;
      Tablo.Query1.Params[3].Value := TabAlacak.FieldByName('TUR').AsInteger;
      Tablo.Query1.Params[4].Value := TabAlacak.FieldByName('ID').AsInteger;
      Tablo.Query1.Params[5].Value := TabBorc.FieldByName('TUTAR').AsCurrency;
      Tablo.Query1.Params[6].Value := TabAlacak.FieldByName('TUTAR').AsCurrency;
      Tablo.Query1.Params[7].Value := Tutar;
      Tablo.Query1.Params[8].Value := Kullanan;
      Tablo.Query1.ExecSQL;
      Yenile;
    end;
  end;
end;

procedure TFaturaKapamaDlg.Busatrnbalantlarnsil1Click(Sender: TObject);
begin  //Alacak Satırı
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from BORCKAPATMA where REHBERID=&RID and ALACAKTUR=&AT and ALACAKID=&AID '
                              ,['&RID','&AT','&AID']
                              ,[RehberID,TabAlacak.FieldByName('TUR').AsInteger,TabAlacak.FieldByName('ID').AsInteger]);
  Yenile;
end;

procedure TFaturaKapamaDlg.Busatrnbalantlarnsil2Click(Sender: TObject);
begin  //Borç satırı
  Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,'delete from BORCKAPATMA where REHBERID=&RID and BORCTUR=&BT and BORCID=&BID '
                              ,['&RID','&BT','&BID']
                              ,[RehberID,TabBorc.FieldByName('TUR').AsInteger,TabBorc.FieldByName('ID').AsInteger]);
  Yenile;
end;

procedure TFaturaKapamaDlg.cxComboBox1PropertiesEditValueChanged(Sender: TObject);
begin
  Yenile;
end;

procedure TFaturaKapamaDlg.GridBASolDBTableViewBorcCanFocusRecord(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridBASol;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridBASolDBTableViewBorc;
  AnaForm.pmGridStil.Tags.Values[GridBASol.Name]:='FaturaKapamaGridiBorc';
end;

procedure TFaturaKapamaDlg.GridBASolDBTableViewBorcStylesGetContentStyle(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var BorcTur,BorcID:variant;
begin
  if (RadioModIzle.Checked)and(RadioRenk.Checked)and(FVurguYonetici.FKip = vkAlacak) then begin
    BorcTur := GridBASolDBTableViewBorc.DataController.GetValue(ARecord.Index,GridBASolDBTableViewBorcTUR.Index);
    BorcID := GridBASolDBTableViewBorc.DataController.GetValue(ARecord.Index,GridBASolDBTableViewBorcID.Index);
    if FVurguYonetici.Vurgula(BorcId,BorcTur,vkAlacak) then
      AStyle := cxStyleSeciliHucre;

    {if TabCapraz.Locate('BORCTUR;BORCID',VarArrayOf([BorcTur,BorcID]),[]) then begin
      GridBASolDBTableViewBorc.Styles.Content := cxStyleSeciliHucre;
    end else begin
      GridBASolDBTableViewBorc.Styles.Content := cxStyle1;
    end; }
  end;
end;

procedure TFaturaKapamaDlg.GridBASagDBTableViewAlacakStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
var AlacakTur,AlacakID:variant;
begin
  if (RadioModIzle.Checked)and(RadioRenk.Checked)and(FVurguYonetici.FKip = vkBorc) then begin
    AlacakTur := GridBASagDBTableViewAlacak.DataController.GetValue(ARecord.Index,GridBASagDBTableViewAlacakTUR.Index);
    AlacakID := GridBASagDBTableViewAlacak.DataController.GetValue(ARecord.Index,GridBASagDBTableViewAlacakID.Index);
    if FVurguYonetici.Vurgula(AlacakId,AlacakTur,vkBorc) then
      AStyle := cxStyleSeciliHucre;
    {if TabCapraz.Locate('ALACAKTUR;ALACAKID',VarArrayOf([AlacakTur,AlacakID]),[]) then begin
      GridBASagDBTableViewAlacak.Styles.Content := cxStyleSeciliHucre;
    end else begin
      GridBASagDBTableViewAlacak.Styles.Content := cxStyle1;
    end; }
  end;
end;

procedure TFaturaKapamaDlg.RadioModIzleClick(Sender: TObject);
begin
   BtnEslestir.Visible := RadioModEsle.Checked;
   LabelAyrim.Visible := RadioModIzle.Checked;
   RadioRenk.Visible := RadioModIzle.Checked;
   RadioSuzme.Visible := RadioModIzle.Checked;
   if RadioModEsle.Checked then
      Yenile;
end;

procedure TFaturaKapamaDlg.RadioRenkClick(Sender: TObject);
begin
   //GridBASolDBTableViewBorcCell.Click;
   Yenile;
end;

procedure TFaturaKapamaDlg.GridBASagDBTableViewAlacakCanFocusRecord(
  Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord;
  var AAllow: Boolean);
begin
  AnaForm.cxGridPopupMenu1.Grid:=GridBASag;
  AnaForm.cxGridPopupMenu1.PopupMenus[0].GridView:=GridBASagDBTableViewAlacak;
  AnaForm.pmGridStil.Tags.Values[GridBASag.Name]:='FaturaKapamaGridiAlacak';
end;

procedure TFaturaKapamaDlg.GridBASagDBTableViewAlacakCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  AlacakTur,AlacakID:Integer;
begin
  if TabAlacak.RecordCount>0 then begin
    AlacakTur := GridBASagDBTableViewAlacak.DataController.GetValue(ACellViewInfo.GridRecord.Index,GridBASagDBTableViewAlacakTUR.Index);
    AlacakID := GridBASagDBTableViewAlacak.DataController.GetValue(ACellViewInfo.GridRecord.Index,GridBASagDBTableViewAlacakID.Index);
    FVurguYonetici.VurgulariYukle(AlacakId,AlacakTur,vkAlacak);
    RepaintGridView(GridBASolDBTableViewBorc);
    RepaintGridView(GridBASagDBTableViewAlacak);
    {TabCapraz.Close;
    TabCapraz.SQL.Text := 'select * from BORCKAPATMA where ALACAKTUR='+AlacakTur+' and ALACAKID='+AlacakID;
    TabCapraz.Open; }
  end;
{    TabCapraz.Last;
    TabBorc.Locate('TUR;ID', VarArrayOf([TabCapraz.FieldByName('BORCTUR').Value,TabCapraz.FieldByName('BORCID').Value]),[loCaseInsensitive]);
  TabCapraz.Close; }
end;

procedure TFaturaKapamaDlg.FormCreate(Sender: TObject);
begin
  FVurguYonetici := TVurguYonetici.Create;
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Tablo.GridTurkcelestir;
  RadioModIzle.Checked :=True;
end;

procedure TFaturaKapamaDlg.FormDestroy(Sender: TObject);
begin
  FVurguYonetici.Free;
end;

procedure TFaturaKapamaDlg.FormShow(Sender: TObject);
begin
  cxComboBox1.EditValue := CariDoviz;
  cxComboBox1.PostEditValue;
end;

procedure TFaturaKapamaDlg.RepaintGridView(AGridView: TcxGridDBTableView);
var
  i: Integer;
begin
  for I := 0 to AGRidView.DataController.FilteredRecordCount - 1 do begin
    AGridView.ViewData.GetRecordByRecordIndex(AGRidView.DataController.FilteredRecordIndex[i]).Invalidate;
  end;

end;

procedure TFaturaKapamaDlg.TabBorcAfterScroll(DataSet: TDataSet);
var
  BorcTur,BorcID:Integer;
begin
  if (RadioModIzle.Checked)and(TabBorc.RecordCount>0) then begin
    //BorcTur := GridBASolDBTableViewBorc.DataController.GetValue(ACellViewInfo.GridRecord.Index,GridBASolDBTableViewBorcTUR.Index);
    //BorcID := GridBASolDBTableViewBorc.DataController.GetValue(ACellViewInfo.GridRecord.Index,GridBASolDBTableViewBorcID.Index);
    BorcTur := TabBorc.FieldByName('TUR').AsInteger;
    BorcID := TabBorc.FieldByName('ID').AsInteger;

    if RadioSuzme.Checked  then begin
        TabCapraz.Close;
        TabCapraz.SQL.Text := 'select * from BORCKAPATMA where BORCTUR='+IntToStr(BorcTur)+' and BORCID='+IntToStr(BorcID);
        TabCapraz.Open;
        TabCapraz.Last;
      //TabAlacak.Locate('TUR;ID', VarArrayOf([TabCapraz.FieldByName('ALACAKTUR').Value,TabCapraz.FieldByName('ALACAKID').Value]),[loCaseInsensitive]);
      //TabCapraz.Close;
        if TabCapraz.FieldByName('BORCTUR').AsString='' then
           BorcTur := 0
        else
           BorcTur := TabCapraz.FieldByName('BORCTUR').AsInteger;
        if TabCapraz.FieldByName('BORCID').AsString='' then
           BorcId := 0
        else
           BorcId := TabCapraz.FieldByName('BORCID').AsInteger;

        TabAlacak.SQL.Text := StringReplace( MemoAlacakSQL.Text, '--KOSUL', ' where BORCTUR = '+IntToStr(BorcTur)+' and BORCID = '+IntToStr(BorcId),[]);
        TabloYenile(TabAlacak,[RehberID,cxComboBox1.EditValue]);
    end else begin
        FVurguYonetici.VurgulariYukle(BorcId,BorcTur,vkBorc);
        RepaintGridView(GridBASolDBTableViewBorc);
        RepaintGridView(GridBASagDBTableViewAlacak);
    end;
  end;end;

procedure TFaturaKapamaDlg.TabCaprazAfterOpen(DataSet: TDataSet);
begin
  GridBASolDBTableViewBorc.DataController.Refresh;
  GridBASagDBTableViewAlacak.DataController.Refresh;
end;

procedure TFaturaKapamaDlg.Yenile;
begin
  TabloYenile(TabBorc,[RehberID,cxComboBox1.EditValue]);
  GridBASolDBTableViewBorc.ApplyBestFit();
  TabAlacak.SQL.Text := MemoAlacakSQL.Text;
  TabloYenile(TabAlacak,[RehberID,cxComboBox1.EditValue]);
  GridBASagDBTableViewAlacak.ApplyBestFit();
end;

{ TVurguYonetici }

constructor TVurguYonetici.Create;
begin
  FVurguBilgi := TObjectList<TVurguBilgi>.Create;
  FKip := vkYok;
end;

destructor TVurguYonetici.Destroy;
begin
  FVurguBilgi.Free;
  inherited;
end;


function TVurguYonetici.Vurgula(AHedefId, AHedefTur: Integer;
  AKip: TVurguKipi): Boolean;
var
  vb : TVurguBilgi;
begin
  Result := False;
  if (AKip <> FKip) then Exit;
  for vb in FVurguBilgi do begin
    if (vb.HedefId = AHedefId) and (vb.HedefTur = AHedefTur) then Exit(True);
  end;
end;

procedure TVurguYonetici.VurgulariYukle(AKaynakId, AKaynakTur: Integer;
  AKip: TVurguKipi);
var
  vurguAlan : TVurguAlan;
  vb        : TVurguBilgi;
begin
  FKip := AKip;
  FVurguBilgi.Clear;
  if (AKip = vkYok) then Exit;
  vurguAlan := VurguAlanlar[FKip];
  with Veritabani.SorguBaslat(Tablo.FDCnn,
    Format('SELECT %s,%s FROM BORCKAPATMA WHERE %s = %d AND %s = %d ',
      [
        vurguAlan.HedefId,
        vurguAlan.HedefTur,
        vurguAlan.KaynakId,
        AKaynakId,
        vurguAlan.KaynakTur,
        AKaynakTur
      ]
    ),[],[]) do
  try
    Open;
    while not Eof do begin
      vb := TVurguBilgi.Create( Fields[0].AsInteger, Fields[1].AsInteger );
      FVurguBilgi.Add(vb);
      Next;
    end;
  finally
    Free;
  end;
end;

{ TVurguBilgi }

constructor TVurguBilgi.Create(AHedefId, AHedefTur: Integer);
begin
  HedefTur := AHedefTur;
  HedefId := AHedefId;
end;

end.






