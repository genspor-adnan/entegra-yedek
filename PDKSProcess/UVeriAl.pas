unit UVeriAl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, ComCtrls, ExtCtrls, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, StdCtrls, DBTables, ADODB, dxSkinsCore, dxSkinBlack, dxSkinBlue,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinFoggy,
  dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky,
  dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven, dxSkinSharp, dxSkinSilver,
  dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinXmas2008Blue, dxSkinscxPCPainter, DBCtrls, DBClient,
  Menus, cxLookAndFeelPainters, cxButtons;

type
  TFrmVeriAktarým = class(TForm)
    pnl1: TPanel;
    dtp1: TDateTimePicker;
    dtp2: TDateTimePicker;
    btn1: TButton;
    btn2: TButton;
    ds1: TDataSource;
    qry1: TADOQuery;
    cxGrid1: TcxGrid;
    CihazTV: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    CihazTVFIRMA: TcxGridDBColumn;
    CihazTVKARTNO: TcxGridDBColumn;
    CihazTVTARIH: TcxGridDBColumn;
    procedure btn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure dtp1Change(Sender: TObject);
    procedure dtp2Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmVeriAktarým: TFrmVeriAktarým;

implementation
Uses uAnaForm,utablo,FetaKurulusSiniflari;

{$R *.dfm}

procedure TFrmVeriAktarým.btn1Click(Sender: TObject);
begin
   VeriBasTarih  :=dtp1.DateTime;
   VeriBitTarih  := dtp2.DateTime;
   AnaForm.SaveGLogs();
   qry1.close;
   qry1.Parameters[0].Value:= FormatDateTime('yyyy-mm-dd 00:01:00',dtp1.DateTime);
   qry1.Parameters[1].Value:= FormatDateTime('yyyy-mm-dd 23:59:59',dtp2.DateTime);
   qry1.open;
   AnaForm.CZKEMPDKS.RegEvent(DevID,32767);
end;

procedure TFrmVeriAktarým.btn2Click(Sender: TObject);
var
  i:integer;
  GunAdi:String;
begin
   if Tablo.TablodanSorguAc(4,'Select  R.ID from REHBER R Where  R.GRUP=335 and DURUM=1 and ID not in(Select REHBERID from PERS_VARDIYATANIM Where REHBERID=R.ID)') then begin
      while not Tablo.Query4.Eof do  begin
        Tablo.TablodanSorguAc(3,'Select * from PERS_VARDIYATANIM Where REHBERID = -1');
        if Tablo.Query3.RecordCount > 0 then begin
          while not Tablo.Query3.Eof do  begin
            Tablo.SQLSatiriKopyala('PERS_VARDIYATANIM', Tablo.Query3.FieldByName('ID').AsInteger, ['REHBERID'], [Tablo.Query4.FieldByName('ID').AsInteger]);
            Tablo.Query3.Next;
          end;
        end else begin
          for I := 1 to 7 do begin
            case i of
              2: GunAdi:='Pazartesi';
              3: GunAdi:='Salý';
              4: GunAdi:='Çarþamba';
              5: GunAdi:='Perþembe';
              6: GunAdi:='Cuma';
              7: GunAdi:='Cumartesi';
              1: GunAdi:='Pazar';
            end;
          Veritabani.BasitKomutÇalýþtýr(Tablo.cnn,'insert into PERS_VARDIYATANIM(REHBERID,AY,YIL,GUN,GUNADI,GIRIS,CIKIS) '+
          ' values(-1,0,0,'+IntToStr(i)+','''+GunAdi+''',''1900-01-01 09:00:00'',''1900-01-01 09:00:00'') ',[],[]);
          end;
        end;
        Tablo.Query4.Next;
      end;
   end;

  Tablo.Query5.Close;
  Tablo.Query5.SQL.Text := 'Delete from PERS_PDKS WHERE GIRIS > = ''' + FormatDateTime('yyyy-mm-dd 00:00',dtp1.Date) + ''' ';
  Tablo.Query5.ExecSQL;

  qry1.First;
  while not qry1.Eof do
  begin
      Anaform.KartKontrolZamanli(qry1.FieldByName('KARTNO').AsString,1,
      FormatDateTime('yyyy-mm-dd hh:nn:00',qry1.FieldByName('TARIH').AsDateTime));
      qry1.Next
  end;
  Showmessage('Kayýtlar güncellendi.');
end;

procedure TFrmVeriAktarým.dtp1Change(Sender: TObject);
begin
   qry1.close;
   qry1.Parameters[0].Value:= FormatDateTime('yyyy-mm-dd 00:01:00',dtp1.DateTime);
   qry1.Parameters[1].Value:= FormatDateTime('yyyy-mm-dd 23:59:59',dtp2.DateTime);
   qry1.open;
end;

procedure TFrmVeriAktarým.dtp2Change(Sender: TObject);
begin
   qry1.close;
   qry1.Parameters[0].Value:= FormatDateTime('yyyy-mm-dd 00:01:00',dtp1.DateTime);
   qry1.Parameters[1].Value:= FormatDateTime('yyyy-mm-dd 23:59:59',dtp2.DateTime);
   qry1.open;
end;

procedure TFrmVeriAktarým.FormShow(Sender: TObject);
begin
   dtp2.DateTime:= now();
   dtp1.DateTime:= now()-10;
   qry1.close;
   qry1.Parameters[0].Value:= FormatDateTime('yyyy-mm-dd hh:nn:ss',dtp1.DateTime);
   qry1.Parameters[1].Value:= FormatDateTime('yyyy-mm-dd hh:nn:ss',dtp2.DateTime);
   qry1.open;
end;

end.
