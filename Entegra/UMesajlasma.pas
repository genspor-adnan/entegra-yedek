unit UMesajlasma;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinMetropolis, dxSkinMetropolisDark, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinSevenClassic,
  dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, Data.DB, cxDBData, cxContainer, Vcl.Menus, cxMemo, Vcl.StdCtrls,
  cxButtons, cxTextEdit, cxMaskEdit, cxButtonEdit, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, JvExControls, JvLED, Vcl.ExtCtrls, FireDAC.Comp.Client,
  cxGridCardView, cxGridDBCardView, cxGridCustomLayoutView, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, cxImage, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, cxRichEdit;

type
  TMesajlasmaDlg = class(TForm)
    MesajMenu: TPopupMenu;
    KonusmaGecmisiMenu: TMenuItem;
    DtsMesajKisiler: TDataSource;
    TabMesajKisiler: TFDQuery;
    pnlMesajlasma: TPanel;
    Panel18: TPanel;
    Label12: TLabel;
    MesajLED: TJvLED;
    ScrollBox2: TScrollBox;
    GridPersonel: TcxGrid;
    GridPersonelDBTableViewKisiler: TcxGridDBTableView;
    GridPersonelDBTableViewKisilerColumn1: TcxGridDBColumn;
    Panel10: TPanel;
    MesajPersonAra: TcxButtonEdit;
    PanelChat: TPanel;
    Panel4: TPanel;
    MemoChat: TcxRichEdit;
    GridMesaj: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    TabMesajlar: TFDQuery;
    DtsMesajlar: TDataSource;
    GridMesajLevel1: TcxGridLevel;
    GridMesajDBCardView1: TcxGridDBCardView;
    GridMesajDBCardView1Row1: TcxGridDBCardViewRow;
    GridMesajDBCardView1Row2: TcxGridDBCardViewRow;
    GridMesajDBCardView1Row3: TcxGridDBCardViewRow;
    LabelYeniKisi: TLabel;
    Label2: TLabel;
    GridPersonelDBTableViewKisilerColumn2: TcxGridDBColumn;
    GridPersonelDBTableViewKisilerColumn3: TcxGridDBColumn;
    GridPersonelDBTableViewKisilerColumn4: TcxGridDBColumn;
    GridPersonelCardView1: TcxGridCardView;
    GridPersonelCardView1Row1: TcxGridCardViewRow;
    GridPersonelCardView1Row2: TcxGridCardViewRow;
    GridPersonelCardView1Row3: TcxGridCardViewRow;
    GridPersonelCardView1Row4: TcxGridCardViewRow;
    GridPersonelLevel1: TcxGridLevel;
    GridPersonelDBCardView1: TcxGridDBCardView;
    GridPersonelDBCardView1Row1: TcxGridDBCardViewRow;
    GridPersonelDBCardView1Row2: TcxGridDBCardViewRow;
    GridPersonelDBCardView1Row3: TcxGridDBCardViewRow;
    GridPersonelDBCardView1Row4: TcxGridDBCardViewRow;
    BtnMesajGonder: TcxButton;
    BtnDosyaGonder: TcxButton;
    GridPersonelDBCardView1Row5: TcxGridDBCardViewRow;
    LabelYeniGrup: TLabel;
    Label3: TLabel;
    GridMesajDBCardView1Row4: TcxGridDBCardViewRow;
    procedure FormShow(Sender: TObject);
    procedure BtnMesajGonderClick(Sender: TObject);
    procedure LabelYeniKisiClick(Sender: TObject);
    procedure MemoChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GridPersonelDBCardView1CellClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure LabelYeniGrupClick(Sender: TObject);
    procedure GridPersonelDBCardView1CellDblClick(
      Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
  private
    { Private declarations }
    function GrupBilgiAc(IslOp:char; ID:Integer; Ad:String):integer;
    procedure MesajEkle(ID, Grup : Integer; Mesaj:string);
  public
    { Public declarations }
  end;

var
  MesajlasmaDlg: TMesajlasmaDlg;

implementation

{$R *.dfm}

uses UTablo, FetaClassExtensions, FetaKurulusSiniflari, UAnaForm, UMesajGrup;

procedure TMesajlasmaDlg.MesajEkle(ID, Grup : Integer; Mesaj:string);
var MesajLogID, MesajLogKullaniciID, Grupmu : Integer;
    MsgStr:String;
begin
    if Grup=99 then begin  //bakalım bu mesaj gruba mı
       Grupmu:=1;          //gruba ise türe grup adının rehber id sini veriyoruz.
       Tablo.tablodanSorguAc(9, 'select ALICILAR=G.DEGER, SERVERID=0 from GENINI G where G.BOLUM=99 and G.DIL='+IntToStr(ID));
    end else begin
       Grupmu:=0;          // tek kişiye mesaj ise tür 0 olur
       Tablo.tablodanSorguAc(9, 'select ALICILAR=REHBERID, SERVERID=0 from KULLANICI K where K.REHBERID = '+IntToStr(ID) );
    end;

    //mesaj gönderen bilgisi ve mesaj içeriği
    MesajLogID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
      'insert into MESAJLOG(GONDERENID,ALANID,GRUP,MESAJ)values(&GonderenID,&AlanID,&Grup,&Mesaj) select scope_identity() ', ['&GonderenID','&AlanID','&Grup', '&Mesaj'],
      [Kullanan, ID, Grupmu, Mesaj], true);
    //mesaj alıcıları  eğer grupsa üyelerin hepsine
    while not Tablo.Query9.eof do begin
      if Tablo.Query9.Fields[0].AsString <> kullanan then begin//kendisi hariç diğer kişilere gitmeli
         MesajLogKullaniciID := Veritabani.BasitKomutÇalıştır(Tablo.FDCnn,
           'insert into MESAJLOGKULLANICI(MESAJLOGID,ALICIID)values(&MesajLogID,&AliciID) select scope_identity()', ['&MesajLogID', '&AliciID'],
           [MesajLogID, Tablo.Query9.Fields[0].AsInteger], true);
         ///
         MsgStr := Format('SEND %d %s %s %s', [Tablo.Query9.FieldByName('SERVERID').AsInteger, VarToStr(MesajLogID), VarToStr(MesajLogKullaniciID), Dize.SatirSonuEncode(Mesaj)]);
         // MsgClient.Socket.WriteLn('SEND ' + IntToStr(PageControlChat.ActivePage.Tag) + ' LOGID '+ VarToStr(MesajLogID) + ' LOGKULID '+ VarToStr(MesajLogKullaniciID) +' '+ MemoChat.Text);
         AnaForm.MsgClient.Socket.WriteLn(MsgStr);
      end;
      Tablo.Query9.next;
    end;

   TabloYenile(TabMesajKisiler, [Kullanan]);
   TabMesajKisiler.First;

   TabloYenile(TabMesajlar, [StrToInt(Kullanan), TabMesajKisiler.FieldByName('REHBERID').AsInteger]);
   TabMesajlar.Last;
   TabloYenile(TabMesajKisiler, [Kullanan]);
   MemoChat.Clear;
   MemoChat.SetFocus;
end;

procedure TMesajlasmaDlg.FormShow(Sender: TObject);
begin
  TabloYenile(TabMesajKisiler, [Kullanan]);
  //if TabMesajKisiler.recordcount > 0 then
  //   TabloYenile(TabMesajlar, [TabMesajKisiler.FieldByName('REHBERID').AsInteger, StrToInt(Kullanan)]);
end;

procedure TMesajlasmaDlg.GridPersonelDBCardView1CellClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var AktifRehberId:integer;
begin
   AktifRehberId := MesajlasmaDlg.TabMesajKisiler.FieldByName('REHBERID').AsInteger;
   AnaForm.OkunduUpdate(AktifRehberId);
   TabloYenile(TabMesajKisiler, [Kullanan]);
   MesajlasmaDlg.TabMesajKisiler.Locate('REHBERID', AktifRehberId, []);
   TabloYenile(TabMesajlar, [StrToInt(Kullanan), AktifRehberId]);
   TabMesajlar.Last;
   MemoChat.Clear;
   MemoChat.SetFocus;
end;

procedure TMesajlasmaDlg.GridPersonelDBCardView1CellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
   GrupBilgiAc('D', TabMesajKisiler.FieldByName('REHBERID').AsInteger, TabMesajKisiler.FieldByName('FIRMA').AsString);
end;

function TMesajlasmaDlg.GrupBilgiAc(IslOp:char; ID:Integer; Ad:String):integer;
begin
      Application.CreateForm(TMesajGrupDlg, MesajGrupDlg);
      MesajGrupDlg.ListeId:=ID;
      MesajGrupDlg.IslemOp:=IslOp;
      MesajGrupDlg.ListeBaslik.Text := Ad;
      MesajGrupDlg.ShowModal;
      if MesajGrupDlg.ModalResult = mrOk then begin
         Result := MesajGrupDlg.ListeId;
         TabloYenile(TabMesajKisiler, [Kullanan]);
         TabMesajKisiler.First;
      end
      else
         Result := 0;
      MesajGrupDlg.Destroy;
end;

procedure TMesajlasmaDlg.LabelYeniGrupClick(Sender: TObject);
var Id:Integer;
begin
   Id := GrupBilgiAc('E', -9999, '');
   if Id > 0 then
       MesajEkle(ID, 99, 'Gruba eklendiniz..');
end;

procedure TMesajlasmaDlg.LabelYeniKisiClick(Sender: TObject);
var Id : Integer;
begin
    Id := Tablo.RehberAra_IDGetir(335);
    if Id > 0 then
       MesajEkle(ID, 0, '');
end;

procedure TMesajlasmaDlg.BtnMesajGonderClick(Sender: TObject);
begin
  MesajEkle(TabMesajKisiler.FieldByName('REHBERID').AsInteger,TabMesajKisiler.FieldByName('GRUP').AsInteger, MemoChat.text);
end;

procedure TMesajlasmaDlg.MemoChatKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   BtnMesajGonder.enabled := trim(MemoChat.text)<>'';
end;

end.




