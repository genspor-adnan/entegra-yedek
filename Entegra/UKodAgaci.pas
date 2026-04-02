unit UKodAgaci;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxGraphics, cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu,
  dxSkinsCore, dxSkinLondonLiquidSky, ComCtrls, ToolWin, cxControls,UAnaForm,
  cxInplaceContainer, cxTLData, cxDBTL, DB, FireDAC.Comp.Client, PrjConst,
  cxContainer, cxEdit, cxTextEdit, ExtCtrls, cxMaskEdit,UGirisKutusuEx,
  cxLookAndFeels, cxLookAndFeelPainters, cxCheckBox, dxSkinLiquidSky, cxFilter,
  dxScrollbarAnnotations, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet;

type
  TKodAgaciDlg = class(TForm)
    DtsKodAgaci: TDataSource;
    cxDBTreeList1: TcxDBTreeList;
    ToolBar3: TToolBar;
    YeniTus: TToolButton;
    SilTus: TToolButton;
    SecTus: TToolButton;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    Panel1: TPanel;
    EditKod: TcxTextEdit;
    EditAciklama: TcxTextEdit;
    BtnKapat: TToolButton;
    cxDBTreeList1cxDBTreeListSEC: TcxDBTreeListColumn;
    BtnDuzenle: TToolButton;
    TabKodAgaci: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure cxDBTreeList1DblClick(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
    procedure YeniTusClick(Sender: TObject);
    procedure SilTusClick(Sender: TObject);
    procedure DtsKodAgaciStateChange(Sender: TObject);
    procedure BtnKaydetClick(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure AramaYap;
    procedure EditKodKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BtnKapatClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabKodAgaciNewRecord(DataSet: TDataSet);
    procedure BtnDuzenleClick(Sender: TObject);
    procedure cxDBTreeList1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure cxDBTreeList1CustomDrawDataCell(Sender: TcxCustomTreeList;
      ACanvas: TcxCanvas; AViewInfo: TcxTreeListEditCellViewInfo;
      var ADone: Boolean);
    procedure cxDBTreeList1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);

  private
    P: PBoolean;
    { Private declarations }
  public
    Sonuc_ID:Integer;
    Sonuc_Kod,Sonuc_Aciklama:string;
    RepList : Array Of TcxEditRepositoryItem;
    VarsAlanlar,ColBasliklar:Array of string;
    VarsDegerler:Array of Variant;
    ColVisibility:array of Boolean;
    FullExp, SadeceCocukSec, CokluSecim, Ekleme, Silme:Boolean;
    Sonuc_Liste:TStringList;
      { Public declarations }
  end;

var
  KodAgaciDlg: TKodAgaciDlg;
  SQLicerik:string;

implementation
Uses
Utablo,LocOnFly;

{$R *.dfm}

procedure TKodAgaciDlg.BtnDuzenleClick(Sender: TObject);
begin
  cxDBTreeList1.OptionsData.Editing := True;
  cxDBTreeList1.OptionsData.Deleting := True;
  TabKodAgaci.Close;
  TabKodAgaci.Open;
  BtnDuzenle.Visible := False;
  YeniTus.Visible := Ekleme;
  SilTus.Visible := Silme;
  DtsKodAgaci.OnStateChange := DtsKodAgaciStateChange;
  cxDBTreeList1.OptionsSelection.CellSelect := True;
  cxDBTreeList1.OnDblClick := Nil;
end;

procedure TKodAgaciDlg.BtnIptalClick(Sender: TObject);
begin
  TabKodAgaci.Cancel;
  cxDBTreeList1.Refresh;
end;

procedure TKodAgaciDlg.BtnKapatClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
end;

procedure TKodAgaciDlg.BtnKaydetClick(Sender: TObject);
begin
  try
    cxDBTreeList1.Post;
    //TabKodAgaci.Post;
    //cxDBTreeList1.GotoPrev;
    //cxDBTreeList1.GotoNext;
  finally
    TabKodAgaci.Close;
    TabKodAgaci.Open;
    cxDBTreeList1.FullExpand;
    cxDBTreeList1.ApplyBestFit;
  end;
  cxDBTreeList1.Refresh;

end;

procedure TKodAgaciDlg.cxDBTreeList1CustomDrawDataCell(
  Sender: TcxCustomTreeList; ACanvas: TcxCanvas;
  AViewInfo: TcxTreeListEditCellViewInfo; var ADone: Boolean);
begin
    if CokluSecim then
       with TcxDBTreeListColumn(AViewInfo.Column) do
         if (DataBinding.FieldName = '') and (Properties is TcxCheckBoxProperties) then
            with AViewInfo.Node do
              TcxCustomCheckBoxViewInfo(AViewInfo.EditViewInfo).State :=
                   TcxCheckBoxState(not((Data = nil) or ((Data <> nil) and (PBoolean(Data)^ = False))))
end;

procedure TKodAgaciDlg.cxDBTreeList1DblClick(Sender: TObject);
begin
  if cxDBTreeList1.Selections[0].HasChildren then
     cxDBTreeList1.Selections[0].Expanded:=True
  else begin
    SecTusClick(Self);
  end;
end;

procedure TKodAgaciDlg.cxDBTreeList1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
  var Sonuc_ID : Integer;
begin
    if TabKodAgaci.FindField('ID') <> nil then
      Sonuc_ID := TabKodAgaci.FieldByName('ID').AsInteger
    else
      Sonuc_ID := -99;
end;

procedure TKodAgaciDlg.cxDBTreeList1MouseDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ANode: TcxTreeListNode;
  AColumn: TcxTreeListColumn;
begin
  if CokluSecim then
      with TcxTreeList(Sender) do
      begin
        HitTest.ReCalculate(Point(X, Y));
        if HitTest.HitAtNode and (HitTest.HitColumn <> nil) then
        begin
          ANode := HitTest.HitNode;
          AColumn := HitTest.HitColumn;
          if (TcxDBTreeListColumn(AColumn).DataBinding.FieldName = '') and (AColumn.Properties is TcxCheckBoxProperties) then
            if ANode.Data = nil then
            begin
              New(P);
              P^ := True;
              ANode.Data := P;
            end
            else
              PBoolean(ANode.Data)^ := not PBoolean(ANode.Data)^;
        end;
      end;
end;

procedure TKodAgaciDlg.DtsKodAgaciStateChange(Sender: TObject);
begin
  //SecTus.Visible:=DtsKodAgaci.State=dsBrowse;
  YeniTus.Visible:=DtsKodAgaci.State=dsBrowse;
  SilTus.Visible:=DtsKodAgaci.State=dsBrowse;
  BtnKaydet.Visible:=DtsKodAgaci.State in [dsEdit,dsInsert];
  BtnIptal.Visible:=DtsKodAgaci.State in [dsEdit,dsInsert];
  SecTus.Enabled:=DtsKodAgaci.State=dsBrowse;
end;

procedure TKodAgaciDlg.EditKodKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    cxDBTreeList1DblClick(Self)
  else if Key = 38 then
    cxDBTreeList1.GotoPrev
  else if Key = 40 then
    cxDBTreeList1.GotoNext
  else
    AramaYap;
end;

procedure TKodAgaciDlg.FormCreate(Sender: TObject);
var
  I : Integer;
begin
  LocalizerOnFly.ProcessContainer(Self);//Dil yükleniyor.
  Sonuc_ID:=-99;
  Sonuc_Kod:='';
  Sonuc_Aciklama:='';

  for I := 0 to cxDBTreeList1.ColumnCount - 1 do
      cxDBTreeList1.Columns[0].Destroy;
  cxDBTreeList1.Clear;
end;

procedure TKodAgaciDlg.FormShow(Sender: TObject);
var
  i,j,Basla:integer;
  Col : TcxTreeListColumn;
begin
//  cxDBTreeList1cxDBTreeListSEC.visible := CokluSecim;
  if CokluSecim then begin//çoklu seçimse baþýna seçme koyalým
     Col := cxDBTreeList1.CreateColumn();
     Col.Caption.Text := 'Seç';
     col.Options.Editing := False;
     Col.PropertiesClass := TcxCheckBoxProperties;
     Basla:=1
  end else
     Basla:=0;

  BtnDuzenle.visible := Ekleme or Silme;
  if Silme=False then

  TabKodAgaci.Close;
  TabKodAgaci.SQL.Text := SQLicerik;
  TabKodAgaci.Open;
  if TabKodAgaci.Active then begin
    cxDBTreeList1.DataController.KeyField:='KOD';
    cxDBTreeList1.DataController.ParentField:='ROOTKOD';
    CxDBTreeList1.DataController.CreateAllItems;
    for i := (1 - cxDBTreeList1.ColumnCount+Basla) to 0 do begin
      if (((cxDBTreeList1.Columns[-i] as TcxDBTreeListColumn ).DataBinding.FieldName = 'ID') or
          ((cxDBTreeList1.Columns[-i] as TcxDBTreeListColumn ).DataBinding.FieldName = 'ROOTKOD')) then
         cxDBTreeList1.Columns[-i].Destroy
      else
        cxDBTreeList1.Columns[-i].MinWidth:=100;
    end;
    cxDBTreeList1.FullExpand;
    cxDBTreeList1.ApplyBestFit;
    if not FullExp then
      cxDBTreeList1.FullCollapse;
  end;
  //repository bilgilerini yerleþtirelim...

  if (cxDBTreeList1.ColumnCount>0)and(Length(RepList) <> 0) then
    for I := Basla to Length(RepList) - 1 do
      try
        cxDBTreeList1.Columns[i].RepositoryItem:=RepList[i];
      except
        cxDBTreeList1.Columns[i].RepositoryItem:=nil;
      end;
  //column baþlýklarý
  if (cxDBTreeList1.ColumnCount>0) and (Length(ColBasliklar) <> 0) then
    for I := Basla to Length(ColBasliklar) - 1 do
       cxDBTreeList1.Columns[i].Caption.Text:=ColBasliklar[i];
  //column görünür,görünmez...
  if (cxDBTreeList1.ColumnCount>0) and (Length(ColVisibility) <> 0) then
    for I := Basla to Length(ColVisibility) - 1 do
       cxDBTreeList1.Columns[i].Visible:=ColVisibility[i];
  EditKod.SetFocus;
end;

procedure TKodAgaciDlg.AramaYap;
begin
  if SQLicerik='' then
     SQLicerik:=TabKodAgaci.SQL.Text;
  TabKodAgaci.SQL.Text:='SELECT * FROM ( '+SQLicerik+' ) AS XXX ';
  TabKodAgaci.SQL.Text:=TabKodAgaci.SQL.Text+' WHERE KOD LIKE ''%'+EditKod.Text+'%'' AND ACIKLAMA LIKE ''%'+EditAciklama.Text+'%'' ORDER BY KOD';
  TabKodAgaci.Close;
  TabKodAgaci.Open;
  cxDBTreeList1.FullExpand;
  cxDBTreeList1.ApplyBestFit;
end;

procedure TKodAgaciDlg.SecTusClick(Sender: TObject);
var  iInd   : integer;
begin
   if CokluSecim then begin
      Sonuc_Liste := TStringList.create;
      for iInd := 0 to pred(cxDBTreeList1.Count+1) do
        if (cxDBTreeList1.AbsoluteItems[iInd].Data <> nil) and (PBoolean(cxDBTreeList1.AbsoluteItems[iInd].Data)^ = True) then
           Sonuc_Liste.Add(cxDBTreeList1.AbsoluteItems[iInd].Texts[1]);
   end;

   if (SadeceCocukSec)and(cxDBTreeList1.Selections[0].HasChildren) then
       cxDBTreeList1.Selections[0].Expanded:=True
   else
       ModalResult:=mrOk;
end;

procedure TKodAgaciDlg.SilTusClick(Sender: TObject);
begin
  if Application.MessageBox(PChar(SSilmeSorusu), PChar(SGenotipOnay), MB_YESNO) = IDYES then
    TabKodAgaci.Delete;
end;

procedure TKodAgaciDlg.TabKodAgaciNewRecord(DataSet: TDataSet);
var
  i:Integer;
begin
  if (cxDBTreeList1.ColumnCount>0)and(Length(VarsAlanlar) <> 0)and(Length(VarsDegerler) <> 0)and(Length(VarsDegerler)=Length(VarsAlanlar)) then
    for I := 0 to Length(VarsAlanlar) - 1 do begin
      TabKodAgaci.FieldByName(VarsAlanlar[i]).Value := VarsDegerler[i];
    end;
{  //varsayýlan alaný deðeri falan varsa oraya dokundurtmayalým...
  if (cxDBTreeList1.ColumnCount>0)and(Length(VarsAlanlar) <> 0)and(Length(VarsDegerler) <> 0)and(Length(VarsDegerler)=Length(VarsAlanlar)) then
    for I := 0 to Length(VarsAlanlar) - 1 do
      for j := 0 to cxDBTreeList1.ColumnCount - 1 do begin
        if (cxDBTreeList1.Columns[j] as TcxDBTreeListColumn).DataBinding.FieldName = VarsAlanlar[i] then
           (cxDBTreeList1.Columns[j] as TcxDBTreeListColumn).Options.Editing := False;
      end;}
end;


procedure TKodAgaciDlg.YeniTusClick(Sender: TObject);
var KodAdi,AciklamaAdi : Variant;
begin
   TabKodAgaci.Append;
end;

end.

