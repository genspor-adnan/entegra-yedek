unit UHatSMSSec;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Mask, Buttons, Db, UFDCompatHelpers, ComCtrls;

type
  THatSMSSecDlg = class(TForm)
    Label2: TLabel;
    lbKalKarakter: TLabel;
    Panel1: TPanel;
    TabControl1: TTabControl;
    mMesaj: TMemo;
    Label3: TLabel;
    TabSMS: TADOQuery;
    DtsSMS: TDataSource;
    cbHazirMesaj: TComboBox;
    Label4: TLabel;
    sbKaydet: TSpeedButton;
    sbTamam: TBitBtn;
    sbDuzenle: TSpeedButton;
    procedure mMesajChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbHazirMesajChange(Sender: TObject);
    procedure sbKaydetClick(Sender: TObject);
    procedure cbHazirMesajDropDown(Sender: TObject);
    procedure sbDuzenleClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HatSMSSecDlg: THatSMSSecDlg;
  tussay: integer;
  XmlBody, XmlHeader, XmlTum, SMSMesaj1: TStrings;
  vbReferans, vbDosyano, ad, soyad, kulllanici: string[50];
  vbHata: smallint;
  vbBasTarZaman, vbBitTarZaman: string[50];
  GondermeZamanli: boolean;
  ILETI_KAYITNO, ILETI_GSMNO, ILETI_EPOSTA, SMSSonucMSG, EpostaSonucMsg: string;

implementation
uses Utablo, UTabDok, UHazirSMS, umesaj, UCombo, UHatirlatma;

var
  AjandaIni: TIni;

{$R *.DFM}

procedure THatSMSSecDlg.mMesajChange(Sender: TObject);
begin
  lbKalKarakter.Caption := IntToStr(160 - Length(mMesaj.Text));

end;

procedure THatSMSSecDlg.FormCreate(Sender: TObject);
begin
//  if AjandaIni = nil then
//    AjandaIni := TIni.Create('AJANDAINI', tablo.IniSQL);
  cbHazirMesajDropDown(nil);
end;




procedure THatSMSSecDlg.FormShow(Sender: TObject);
begin

  mMesaj.MaxLength := 160;
  lbKalKarakter.Visible := True;
  mMesajChange(nil);
  mmesaj.SetFocus;
end;

procedure THatSMSSecDlg.cbHazirMesajChange(Sender: TObject);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select MESAJ FROM SMSPOSTAHAZMESAJ where BASLIK=''' + cbHazirMesaj.Text + '''';
  Tablo.Query1.Open;
  mMesaj.Text := Tablo.Query1.Fields[0].AsString;
end;

procedure THatSMSSecDlg.sbKaydetClick(Sender: TObject);
var msgbaslik: boolean; Baslik: string;
begin
  if mMesaj.Text = '' then exit;
  msgbaslik := False;
  while not msgbaslik do begin
    if MesajStrAl('Hazır Mesaj', 'Mesaj Başlığı Giriniz :', 'E', nil, Baslik, '', 'E', nil, Baslik) then
    begin
      if Baslik = '' then
        raise Exception.Create('Mesaj başlığı boş bırakılamaz');

      Tablo.Query2.Close;
      Tablo.Query2.SQL.Text := 'select * FROM SMSPOSTAHAZMESAJ WHERE BASLIK=''' + Baslik + '''';
      tablo.Query2.Open;
      if tablo.Query2.RecordCount > 0 then begin
        if Application.MessageBox('Aynı mesaj başlığı ile kayıtlı mesaj var. Üzerine kaydedilsin mi?', 'U Y A R I', MB_YESNO + MB_ICONQUESTION) = IDYES then
        begin
          Tablo.Query2.Close;
          Tablo.Query2.SQL.Text := 'update SMSPOSTAHAZMESAJ set MESAJ=''' + mMesaj.Text + ''' WHERE BASLIK=''' + Baslik + '''';
          tablo.Query2.ExecSQL;
          msgbaslik := True;
        end //if Application.MessageBox
        else
          msgbaslik := False;
      end // if tablo.Query2.RecordCount > 0 then begin
      else
      begin
        Tablo.Query1.Close;
        Tablo.Query1.SQL.Text := 'INSERT INTO SMSPOSTAHAZMESAJ (BASLIK,MESAJ,DURUM ) ' +
          ' VALUES (''' + Baslik + ''',''' + mMesaj.Text + ''',''Aktif'')';
        Tablo.Query1.ExecSQL;
        msgbaslik := True;
      end; // not if tablo.Query2.RecordCount > 0 then
    end
    else
      exit; // if MesajStrAl('') then
  end; //  While


end;

procedure THatSMSSecDlg.cbHazirMesajDropDown(Sender: TObject);
begin
  Tablo.Query1.Close;
  Tablo.Query1.SQL.Text := 'select DISTINCT BASLIK FROM SMSPOSTAHAZMESAJ WHERE durum=''Aktif'' order BY BASLIK';
  Tablo.Query1.Open;
  cbHazirMesaj.Clear;
  while not tablo.Query1.Eof do
  begin
    cbHazirMesaj.Items.Add(Tablo.Query1.Fields[0].AsString);
    Tablo.Query1.next;
  end;

end;

procedure THatSMSSecDlg.sbDuzenleClick(Sender: TObject);
begin
  if HazirSMSDlg = nil then
    Application.CreateForm(THazirSMSDlg, HazirSMSDlg);
  HazirSMSDlg.showmodal;
end;

end.


