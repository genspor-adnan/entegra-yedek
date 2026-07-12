unit URezervasyon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, dxSkinsCore, dxSkinLondonLiquidSky, cxSpinEdit, cxDBEdit, cxButtonEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, cxControls, cxContainer, cxEdit, cxLabel, ComCtrls, JvExComCtrls, JvDateTimePicker, JvExControls, JvButton, JvNavigationPane, DB, FireDAC.Comp.Client,
  cxGraphics, cxLookAndFeels, cxLookAndFeelPainters;

type
  TRezervasyonDlg = class(TForm)
    PanelBaslik: TJvNavPanelHeader;
    KapatTus: TJvNavPanelButton;
    RezTarih: TJvDateTimePicker;
    cxLabel1: TcxLabel;
    cxDBDateEdit1: TcxDBDateEdit;
    cxLabel2: TcxLabel;
    cxLabel3: TcxLabel;
    cxLabel4: TcxLabel;
    cxLabel5: TcxLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBSpinEdit1: TcxDBSpinEdit;
    cxDBTextEdit2: TcxDBTextEdit;
    IptalTus: TJvNavPanelButton;
    KaydetTus: TJvNavPanelButton;
    EditKime: TcxButtonEdit;
    cxDBTextEdit3: TcxDBTextEdit;
    DtsRezervasyon: TDataSource;
    TabRezervasyon: TFDQuery;
    cxLabel6: TcxLabel;
    cxDBTextEdit4: TcxDBTextEdit;
    cxDBTextEdit5: TcxDBTextEdit;
    JvNavPanelButton1: TJvNavPanelButton;
    JvNavPanelButton2: TJvNavPanelButton;
    procedure KapatTusClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure KaydetTusClick(Sender: TObject);
    procedure TabRezervasyonNewRecord(DataSet: TDataSet);
  private
    { Private declarations }
  public
    { Public declarations }
    RezID, MekanID ,MasaID, RehberID   : Integer;
    MasaNo : String[20];
    Tarih : TDateTime;
  end;

var
  RezervasyonDlg: TRezervasyonDlg;

implementation

uses Utablo, UVeriMotor;

{$R *.dfm}
//Durumlar
//(0:gelmedi 1:geldi 2:rezerve 3 :iptal edildi)

procedure TRezervasyonDlg.FormShow(Sender: TObject);
begin
   TabRezervasyon.Close;
   TabRezervasyon.SQL.Text := 'select '+DbUst(1)+'* from REZERVASYON where ';
   if RezID = 0 then  //önceki rez. bilgileri açılır
      TabRezervasyon.SQL.Add(' MASAID='+IntToStr(MasaID)+' and DURUM=2 order by ID desc '+DbSinir(1))//and TARIH between '''+FormatDateTime('yyyy-mm-dd 00:00', Tarih)+''' and '''+FormatDateTime('yyyy-mm-dd 23:59', Tarih)+'''')
   else
      TabRezervasyon.SQL.Add(' 1=2 '+DbSinir(1));

   TabRezervasyon.Open;

   if TabRezervasyon.RecordCount<1 then begin  //şimdi yapılıyor
      TabRezervasyon.Append;
      TabRezervasyon.FieldByName('TARIH').AsDateTime := Tarih;
      TabRezervasyon.FieldByName('MASAID').AsInteger := MasaID;
      TabRezervasyon.FieldByName('MASANO').AsString := MasaNo;
      TabRezervasyon.FieldByName('REHBERID').AsInteger := RehberID;
   end;
   if TabRezervasyon.FieldByName('REHBERID').AsString <>'' then
      EditKime.Text := Tablo.AciklamaGetir('REHBERPERSONEL','ADSOYAD', TabRezervasyon.FieldByName('REHBERID').AsString);
end;

procedure TRezervasyonDlg.KapatTusClick(Sender: TObject);
begin
   Close;
end;

procedure TRezervasyonDlg.KaydetTusClick(Sender: TObject);
begin
    if (TJvNavPanelButton(Sender).Tag = 3)and(TabRezervasyon.FieldByName('ID').AsString = '') then //daha girişteyken iptal edilirse
       TabRezervasyon.Cancel
    else begin
      TabRezervasyon.Edit;
      TabRezervasyon.FieldByName('DEGISTIREN').AsString := Kullanan;
      TabRezervasyon.FieldByName('DEGISTIRMETARIHI').AsDateTime := Tablo.GENINI.BugunTrhSaat;
      TabRezervasyon.FieldByName('DURUM').AsInteger := TJvNavPanelButton(Sender).Tag; //0:gelmedi 1:geldi 2:rezerve 3 :iptal edildi)
      TabRezervasyon.Post;
    end;
    ModalResult := mrOk;
end;

procedure TRezervasyonDlg.TabRezervasyonNewRecord(DataSet: TDataSet);
begin
   TabRezervasyon.FieldByName('MEKANID').AsInteger := MekanID;
   TabRezervasyon.FieldByName('EKLEYEN').AsString := Kullanan;
end;

end.

