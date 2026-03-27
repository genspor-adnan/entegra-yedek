unit UDeAktivasyon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxTextEdit, cxControls, cxContainer, cxEdit, cxLabel, ExtCtrls, ComCtrls, ToolWin, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage, DB, cxDBData, cxCheckBox, cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxMaskEdit, cxDropDownEdit, cxImageComboBox;

type
  TDeAktivasyonDlg = class(TForm)
    Panel1: TPanel;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    BtnSatisYazdir: TToolButton;
    BtnSatisBildir: TToolButton;
    GridDeAktivasyon: TcxGrid;
    TvDeaktivasyon: TcxGridDBTableView;
    cxGridDBColumn24: TcxGridDBColumn;
    cxGridDBColumn35: TcxGridDBColumn;
    cxGridDBColumn36: TcxGridDBColumn;
    cxGridDBColumn37: TcxGridDBColumn;
    cxGridDBColumn38: TcxGridDBColumn;
    cxGridDBColumn39: TcxGridDBColumn;
    cxGridDBColumn40: TcxGridDBColumn;
    cxGridDBColumn41: TcxGridDBColumn;
    cxGridLevel5: TcxGridLevel;
    TxtDeAktivasyonAciklama: TcxTextEdit;
    cxLabel1: TcxLabel;
    LBLDeAktivasyonSebebi: TcxLabel;
    CmbDeAktivasyonTipi: TcxImageComboBox;
    procedure FormShow(Sender: TObject);
    procedure BtnSatisBildirClick(Sender: TObject);
  private
    { Private declarations }
    procedure DeAktivasyonGonder;
    PROCEDURE BildirimGüncelle;
  public
    { Public declarations }
  end;

var
  DeAktivasyonDlg: TDeAktivasyonDlg;

implementation

Uses UItsBildirim,UTablo,UitsBusiness,UItsAraclari,PrjConst, UBekletme;

{$R *.dfm}

procedure TDeAktivasyonDlg.BildirimGüncelle;
begin
  Tablo.Query1.close;
  Tablo.Query1.sql.text := ' SELECT  COUNT(S.ID) AS SAY from STOKID S INNER JOIN  KAREKOD K ON S.ID = K.STOKIDID ' +
                            ' WHERE left(ISNULL(DEAKTIVASYON_DURUM,0),5) <> ''00000'' '+
                            ' AND S.CIKFATBASID = '+Tablo.TabSatis.Fieldbyname('CIKFATBASID').asstring+' ';
  Tablo.Query1.OPEN;
  if Tablo.Query1.FieldByName('SAY').AsInteger = 0 then
    BildirimGuncelle(5,Tablo.TabDeAktivasyon.Fieldbyname('CIKFATBASID').asinteger,9)
  else
    BildirimGuncelle(5,Tablo.TabDeAktivasyon.Fieldbyname('CIKFATBASID').asinteger,3);
end;

procedure TDeAktivasyonDlg.BtnSatisBildirClick(Sender: TObject);
begin
DeAktivasyonGonder;
BildirimGüncelle;
end;

procedure TDeAktivasyonDlg.DeAktivasyonGonder;
var
  DeAktivasyonIstek  : TDeAktivasyonIstek;
  Urun        : TUrun;
  Yanit       : TUretimBildirimYanit;
  Baslik      : String;
  HataDurumMesaj : string;
  i, j:Integer;
begin

    i:=1;
    DeAktivasyonIstek := TDeAktivasyonIstek.Create;
    Tablo.TabDeAktivasyon.First;
    DeAktivasyonIstek.FR :=   GLNFirma;                                                  //   GlnKodu
    DeAktivasyonIstek.DS :=   CmbDeAktivasyonTipi.EditingValue;  //  Bu alan Deaktivasyon Sebebine ait kodu içerir. Ýki karakterlik bir alandýr. Bu alan boþ olamaz.
    DeAktivasyonIstek.ISACIKLAMA :=  TxtDeAktivasyonAciklama.Text;

    DeAktivasyonIstek.BelgeDD := Tablo.TabDeAktivasyon.FieldByName('BELGETARIH').AsDateTime;
    DeAktivasyonIstek.BelgeDN := Tablo.TabDeAktivasyon.FieldByName('BELGENO').AsString;
    Application.CreateForm(TBekletmeDlg, BekletmeDlg);
    BekletmeDlg.Show;
    BekletmeDlg.cxProgressBar1.Properties.Max:= Tablo.TabDeAktivasyon.RecordCount ;
    Tablo.BekletmeyiIlerlet(i,'Datebase Ýþlemleri','Baþlanýyor...',BekletmeDlg);
    j:= Tablo.TabDeAktivasyon.RecordCount div 100;
     if j<=1 then j:=2;

     tablo.TabDeAktivasyon.DisableControls;

     while not (Tablo.TabDeAktivasyon.Eof) do
     begin
      //if Tablo.TabUretim.FieldByName('SEC').AsBoolean then
      //begin
        Urun      := TUrun.Create;
        Urun.GTIN := Tablo.TabDeAktivasyon.FieldByName('URUNBARKOD').AsString;
        Urun.BN   := Tablo.TabDeAktivasyon.FieldByName('LOTNO').AsString;
        Urun.SN   := Tablo.TabDeAktivasyon.FieldByName('SIRANO').AsString;
        Urun.XD   := Tablo.TabDeAktivasyon.FieldByName('SONKULLANIM').AsDateTime;
        DeAktivasyonIstek.Urunler.Add(Urun);
        i:=i+1;
      //end;
       Tablo.TabDeAktivasyon.Next;
       if (I mod j) = 0 then
         begin
         BekletmeDlg.cxProgressBar1.Position := I;
         BekletmeDlg.LabelUstTaraf.Caption := 'SýraNo  : '+inttostr(I);
         Application.ProcessMessages;
         end;
     end;

      BekletmeDlg.cxProgressBar1.Position := I;
      BekletmeDlg.LabelUstTaraf.Caption := 'Sonlandýrýlýyor.';
      BekletmeDlg.close;


      HataDurumMesaj := XMLGelenIsle(XMLGonder(DeAktivasyonIstek),DeAktivasyonIstek.Urunler);
      DeAktivasyonIstek.Free;

     Tablo.TabDeAktivasyon.EnableControls;
    ShowMessage(Its_Islem_Gonderildi+' '+HataDurumMesaj);
end;

procedure TDeAktivasyonDlg.FormShow(Sender: TObject);
begin
  Tablo.TabDeAktivasyon.Close;
  Tablo.TabDeAktivasyon.Parameters.ParamByName('CIKFATBASID').Value:=  ITSBildirimDlg.TabDeAktivasyon.FieldByName('ID').AsString;
  Tablo.TabDeAktivasyon.Open;
end;

end.
