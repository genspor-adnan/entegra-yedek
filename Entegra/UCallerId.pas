unit UCallerId;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinLondonLiquidSky, cxLabel, Vcl.ExtCtrls, cxImage, cxDBEdit, cxStyles,
  dxSkinscxPCPainter, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, Data.DB, cxDBData, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid, cxTextEdit,
  Vcl.Menus, Vcl.StdCtrls, cxButtons, FireDAC.Comp.Client, JvTimer, cxMemo,UTouchKeyboardWindow,
  JvExControls, JvButton, JvNavigationPane, dxSkinBlue, dxSkinBlueprint,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinHighContrast,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013White, dxSkinSevenClassic, dxSkinSharpPlus,
  dxSkinTheAsphaltWorld, dxSkinVS2010, dxSkinWhiteprint, cxSplitter;

type
  TCallerIdDlg = class(TForm)
    Panel1: TPanel;
    LabelTarih: TcxLabel;
    LabelSaat: TcxLabel;
    LabelTelAd: TcxLabel;
    cxDBImage1: TcxDBImage;
    LabelNumara: TcxLabel;
    Panel2: TPanel;
    cxLabel3: TcxLabel;
    TextAra: TcxTextEdit;
    gridCari: TcxGrid;
    tvCari: TcxGridDBTableView;
    gridCariLevel1: TcxGridLevel;
    Panel3: TPanel;
    DuzenleTus: TcxButton;
    NumaraEkleTus: TcxButton;
    YeniKartTus: TcxButton;
    DtsCari: TDataSource;
    TabCari: TFDQuery;
    JvTimer1: TJvTimer;
    tvCariFIRMA: TcxGridDBColumn;
    tvCariCEP: TcxGridDBColumn;
    tvCariISTEL: TcxGridDBColumn;
    tvCariEVTEL: TcxGridDBColumn;
    tvCariNOTLAR: TcxGridDBColumn;
    SecTus: TcxButton;
    SQLListe: TcxMemo;
    JvNavPanelButton1: TJvNavPanelButton;
    cxSplitter1: TcxSplitter;
    DtsAdres: TDataSource;
    TabAdres: TFDQuery;
    Panel4: TPanel;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    AdresEkleTus: TcxButton;
    procedure FormShow(Sender: TObject);
    procedure cxButton1Click(Sender: TObject);
    procedure TextAraKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure JvTimer1Timer(Sender: TObject);
    procedure SecTusClick(Sender: TObject);
    procedure TabCariAfterOpen(DataSet: TDataSet);
    procedure JvNavPanelButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NumaraEkleTusClick(Sender: TObject);
    procedure TabCariAfterScroll(DataSet: TDataSet);
    procedure AdresEkleTusClick(Sender: TObject);
  private
    { Private declarations }
    Klavye1 : TKeyboardWindow;
  public
    { Public declarations }
    TelNo : String;
  end;

var
  CallerIdDlg: TCallerIdDlg;

function CariIdGetir(TelNo:String; var AdresSira:Integer):Integer;

implementation

{$R *.dfm}

uses UTablo, UCariEkle, UGirisKutusuEx;

var Tarih:TDateTime;
    RehberId : Integer;

function CariIdGetir(TelNo:String; var AdresSira:Integer):Integer;
var ID : Integer;
begin
   Application.CreateForm(TCallerIdDlg, CallerIdDlg);
   CallerIdDlg.TelNo:=TelNo;
   CallerIdDlg.ShowModal;
   if CallerIdDlg.ModalResult=mrOk then begin
      if (CallerIdDlg.TabAdres.active=False)or(CallerIdDlg.TabAdres.IsEmpty) then begin
          Tablo.TablodanSorguAc(1,' SELECT SIRA FROM REHBERAYAR RA WHERE RA.YERI=1 and RA.VARSAYILAN=2 ');
          AdresSira := StrToIntDef(Tablo.Query1.Fields[0].AsString,0);
      end else
          AdresSira := CallerIdDlg.TabAdres.Fields[0].AsInteger;
      Result := RehberId;
   end else
      Result:=0;
   CallerIdDlg.Destroy;
end;

procedure TCallerIdDlg.AdresEkleTusClick(Sender: TObject);
var Bilgi : Variant;
    i : smallint;
    function HangiAdres:Integer;
    begin
       if TabAdres.FieldByName('VARSAYILAN').AsInteger <> 2 then result := 2
        else if TabAdres.FieldByName('VARSAYILAN').AsInteger <> 102 then result := 102
        else result := 112;
    end;
begin
   Bilgi := ''; i:=0;
   if TGirisKutusuEx.BilgiAlEx('Adres' , TGirdiDenetimleri.Create.Memo('Adres' , @Bilgi)) = mrOk then begin
      case TabAdres.recordcount of
       0  : i:=2;
       1  : i := HangiAdres;
       2  : begin
              if TabAdres.FieldByName('VARSAYILAN').AsInteger <> 2 then i := 2
              else if (TabAdres.FieldByName('VARSAYILAN').AsInteger <> 2)and(TabAdres.FieldByName('VARSAYILAN').AsInteger<>102) then i := 102
              else i:= 112;
              //if i=0 then begin
              //   TabAdres.next;
              //   if TabAdres.FieldByName('VARSAYILAN').AsInteger <> 102 then i := 102
              //   else i := 112;
              //end;
            end;
       3  : i:=112;
      end;

      Tablo.RehberBilgiGuncelle(TabCari.FieldByName('ID').AsInteger,1,i, Bilgi);
      TabCariAfterScroll(TabAdres);
   end;
end;

procedure TCallerIdDlg.cxButton1Click(Sender: TObject);
begin
  Application.CreateForm(TCariEkleDlg, CariEkleDlg);
  CariEkleDlg.EditCepTel.text := TelNo;
  CariEkleDlg.ShowModal;
  if CariEkleDlg.ModalResult=mrOk then
      RehberId := CariEkleDlg.RehberId
   else
      RehberId := 0;
  CariEkleDlg.Destroy;
  ModalResult := mrOk;
end;

procedure TCallerIdDlg.TabCariAfterOpen(DataSet: TDataSet);
begin
   DuzenleTus.Enabled := not TabCari.IsEmpty;
   SecTus.Enabled := DuzenleTus.Enabled;
end;

procedure TCallerIdDlg.TabCariAfterScroll(DataSet: TDataSet);
begin
   TabloYenile( TabAdres, [TabCari.FieldByName('ILETID').AsInteger]);
end;

procedure TCallerIdDlg.TextAraKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  JvTimer1.Enabled := False;
  JvTimer1.Interval := 700;
  JvTimer1.Enabled := True;
end;

procedure TCallerIdDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Klavye1<>nil then
     FreeAndNil(Klavye1);
end;

procedure TCallerIdDlg.FormShow(Sender: TObject);
begin
    Tarih := Tablo.GENINI.BugunTrhSaat;
    LabelTarih.Caption := FormatDateTime('dd/mm/yyyy', Tarih);
    LabelSaat.Caption := FormatDateTime('hh:nn', Tarih);
    NumaraEkleTus.Visible := TelNo<>'';

    if TelNo<>'' then begin
       Tablo.TablodanSorguAc(2,' select RI.REHBERID from REHBERBILGI RB inner join REHBERILETISIM RI on RB.YER_ID=RI.ID   where BILGI='''+Telno+''' ');
       if not Tablo.Query2.IsEmpty then begin
          TabCari.SQL.Text := SQLListe.Text;
          TabCari.SQL.add('  where ID = '+Tablo.Query2.fields[0].AsString);
          TabloYenile(TabCari, []);
          LabelTelAd.Caption := TabCari.FieldByName('FIRMA').AsString;
          YeniKartTus.Enabled:=False;
          DuzenleTus.Enabled:=True;
       end
       else begin
          LabelTelAd.Caption := 'Bilinmeyen Numara';
          YeniKartTus.Enabled:= True;
          DuzenleTus.Enabled:= False;
       end;
       LabelNumara.Caption := TelNo;
    end;
end;

procedure TCallerIdDlg.JvNavPanelButton1Click(Sender: TObject);
begin
  if Klavye1=nil then begin
    JvNavPanelButton1.Down:=True;
    Klavye1 := TKeyboardWindow.Create(Application);
    Klavye1.ShowKeyboard(Self);
    Klavye1.Top := Top + Height;
  end else begin
    Klavye1.HideKeyboard;
    FreeAndNil(Klavye1);
    JvNavPanelButton1.Down:=False;
  end;
end;

procedure TCallerIdDlg.JvTimer1Timer(Sender: TObject);
var TNo:String[20];
begin
  JvTimer1.Enabled := False;
  TNo := Trim(StringReplace(TextAra.text,'''','',[rfreplaceall]));

  TabCari.SQL.Text := SQLListe.Text;
  TabCari.SQL.Add(' where ( FIRMA like ''%'+TNo+'%'' or CEP like ''%'+TNo+'%'' or ISTEL like ''%'+TNo+'%'' '+
    ' or EVTEL like ''%'+TNo+'%'' or ADRES1 like ''%'+TNo+'%'' or ADRES2 like ''%'+TNo+'%'' or ADRES3 like ''%'+TNo+'%'')');
  TabloYenile(TabCari, []);
end;

procedure TCallerIdDlg.NumaraEkleTusClick(Sender: TObject);
var Alan, RNo : integer;
begin
   if TabCari.FieldByName('CEP').asString='' then
      Alan := 42
   else if TabCari.FieldByName('ISTEL').asString='' then
      Alan := 40
   else
      Alan := 44;
   RNo := TabCari.FieldByName('ID').AsInteger;
   Tablo.RehberBilgiGuncelle(RNo,1,Alan, TelNo);
   TabloYenile(TabCari, []);
   TabCari.Locate('ID',RNo,[]);
end;

procedure TCallerIdDlg.SecTusClick(Sender: TObject);
begin
   if TabAdres.IsEmpty then
      AdresEkleTus.Click;
   RehberId := TabCari.Fields[0].AsInteger;
   ModalResult := mrOk;
end;

end.


