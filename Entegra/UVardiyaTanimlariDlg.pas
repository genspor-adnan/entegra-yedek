unit UVardiyaTanimlariDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, DateUtils,
  Dialogs, cxStyles, dxSkinsCore, dxSkinLondonLiquidSky, dxSkinscxPCPainter, cxCustomData, cxGraphics, cxFilter, cxData, cxDataStorage,
  cxEdit, DB, cxDBData, ComCtrls, ToolWin, cxGridLevel, cxClasses, cxControls, cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, FireDAC.Comp.Client, cxTimeEdit, cxCalendar, cxSpinEdit, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxImageComboBox, Menus,
  cxLookAndFeels, cxLookAndFeelPainters, cxNavigator, cxCheckBox, dxSkinBlue,
  dxSkinBlueprint, dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle,
  dxSkinHighContrast, dxSkinMetropolis, dxSkinMetropolisDark,
  dxSkinOffice2010Black, dxSkinOffice2010Blue, dxSkinOffice2010Silver,
  dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray, dxSkinOffice2013White,
  dxSkinSevenClassic, dxSkinSharpPlus, dxSkinTheAsphaltWorld, dxSkinVS2010,
  dxSkinWhiteprint;

type
  TVardiyaTanimlariDlg = class(TForm)
    VardiyaTanim: TcxGrid;
    VardiyaTanimTV: TcxGridDBTableView;
    cxGridLevel9: TcxGridLevel;
    ToolBar9: TToolBar;
    BtnKaydet: TToolButton;
    BtnIptal: TToolButton;
    TabVardiya: TFDQuery;
    dtsTabVardiya: TDataSource;
    VardiyaTanimTVAY: TcxGridDBColumn;
    VardiyaTanimTVGUN: TcxGridDBColumn;
    VardiyaTanimTVGIRIS: TcxGridDBColumn;
    VardiyaTanimTVCIKIS: TcxGridDBColumn;
    VardiyaTanimTVGUNADI: TcxGridDBColumn;
    ToolButton1: TToolButton;
    BtnKapat: TToolButton;
    ToolButton2: TToolButton;
    ComboYil: TcxSpinEdit;
    ComboAy: TcxImageComboBox;
    PmSagClick: TPopupMenu;
    PmTabloyuOlustur: TMenuItem;
    VardiyaTanimTVISGUNU: TcxGridDBColumn;
    procedure BtnKaydetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabVardiyaNewRecord(DataSet: TDataSet);
    procedure TabVardiyaAfterRefresh(DataSet: TDataSet);
    procedure dtsTabVardiyaStateChange(Sender: TObject);
    procedure BtnIptalClick(Sender: TObject);
    procedure BtnKapatClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboAyPropertiesCloseUp(Sender: TObject);
    procedure ComboYilClick(Sender: TObject);
    procedure PmSagClickPopup(Sender: TObject);
    procedure PmTabloyuOlusturClick(Sender: TObject);
    procedure ComboAyPropertiesChange(Sender: TObject);
  private
    procedure YenileClick;
    { Private declarations }
  public
    { Public declarations }
    RehberId:integer;
    VardiyaTuru:string;
  end;

var
  VardiyaTanimlariDlg: TVardiyaTanimlariDlg;


implementation
Uses
Utablo,FetaKurulusSiniflari,PrjConst;

{$R *.dfm}

procedure TVardiyaTanimlariDlg.BtnIptalClick(Sender: TObject);
begin
TabVardiya.Cancel;
end;

procedure TVardiyaTanimlariDlg.BtnKapatClick(Sender: TObject);
begin
  Close;
  ModalResult := mrCancel;
end;

procedure TVardiyaTanimlariDlg.BtnKaydetClick(Sender: TObject);
begin
  TabVardiya.Post;
end;

procedure TVardiyaTanimlariDlg.ComboAyPropertiesChange(Sender: TObject);
begin
 YenileClick;
end;

procedure TVardiyaTanimlariDlg.ComboAyPropertiesCloseUp(Sender: TObject);
begin
 // YenileClick;
end;

procedure TVardiyaTanimlariDlg.ComboYilClick(Sender: TObject);
begin
  YenileClick;
end;

procedure TVardiyaTanimlariDlg.dtsTabVardiyaStateChange(Sender: TObject);
begin

  BtnKaydet.Visible := (dtsTabVardiya.State in [dsEdit,dsInsert]);
  BtnIptal.Visible := (dtsTabVardiya.State in [dsEdit,dsInsert]);
end;

procedure TVardiyaTanimlariDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if TabVardiya.State in [dsInsert, dsEdit] then begin
     if  Application.MessageBox('Vardiya tanımları kayıt edilsin mi?',PChar(Uyari),MB_YESNO )= mrNo then
       exit
     else
       TabVardiya.Post;
  end;
end;

procedure TVardiyaTanimlariDlg.FormShow(Sender: TObject);
var
  VardiyaTuruS:string;
  i,Ay:integer;
begin
  if VardiyaTuru = 'Sabit' then begin
    VardiyaTanimTVGUN.Visible:=False;
    ComboAy.Visible:=False;
    ComboYil.Visible:=False;
    VardiyaTuruS := ' and AY = 0 and YIL = 0 '
  end else begin
    VardiyaTuruS := ' and AY = '+IntToStr(MonthOf(Date))+' and YIL='+IntToStr(YearOf(Date))+' ' ;
    ComboAy.Visible:=True;
    ComboYil.Visible:=True;
    ComboAy.EditValue := MonthOf(Date);
    ComboYil.EditText := intToStr(YearOf(Date));
    VardiyaTanimTVGUN.Visible:=True;
  end;
  Caption:= Tablo.AciklamaGetir('REHBER', 'FIRMA', RehberId) +'  Vardiya Tanımları' ;

  TabVardiya.Close;
  TabVardiya.SQL.Text := ' Select * from PERS_VARDIYATANIM Where REHBERID='+IntToStr(RehberId)+' '+VardiyaTuruS+' ';
  TabVardiya.Open;

  if TabVardiya.RecordCount < 1 then begin
    if VardiyaTuru = 'Sabit' then begin
      Tablo.TablodanSorguAc(3,'Select * from PERS_VARDIYATANIM Where REHBERID = -1');
      if Tablo.Query3.RecordCount > 0 then begin
        while not Tablo.Query3.Eof do  begin
          Tablo.SQLSatiriKopyala('PERS_VARDIYATANIM', Tablo.Query3.FieldByName('ID').AsInteger, ['REHBERID'], [RehberId]);
          Tablo.Query3.Next;
        end;
        TabloYenile(TabVardiya,[]);
      end else begin
        for I := 1 to 7 do begin
          TabVardiya.Insert;
          TabVardiya.FieldByName('AY').Value := 0;
          TabVardiya.FieldByName('YIL').Value := 0;
          TabVardiya.FieldByName('GUN').Value := i;
          TabVardiya.FieldByName('GIRIS').Value := '1900-01-01 09:00:00';
          TabVardiya.FieldByName('CIKIS').Value := '1900-01-01 18:00:00';
          case i of
            2: TabVardiya.FieldByName('GUNADI').AsString:='Pazartesi';
            3: TabVardiya.FieldByName('GUNADI').AsString:='Salı';
            4: TabVardiya.FieldByName('GUNADI').AsString:='Çarşamba';
            5: TabVardiya.FieldByName('GUNADI').AsString:='Perşembe';
            6: TabVardiya.FieldByName('GUNADI').AsString:='Cuma';
            7: TabVardiya.FieldByName('GUNADI').AsString:='Cumartesi';
            1: TabVardiya.FieldByName('GUNADI').AsString:='Pazar';
          end;
          TabVardiya.Post;
        end;
      end;
    end else begin
      for I := 1 to DaysInAMonth(StrToInt(ComboYil.EditText),ComboAy.EditValue)  do begin
        TabVardiya.Insert;
        TabVardiya.FieldByName('AY').Value := ComboAy.EditValue;
        TabVardiya.FieldByName('GUN').Value := i;
        TabVardiya.FieldByName('YIL').Value := StrToInt(ComboYil.EditText);
        TabVardiya.FieldByName('GUNADI').AsString := FormatDateTime('dddd',StrToDate(''+IntToStr(i)+FormatSettings.DateSeparator+IntToStr(ComboAy.EditValue)+FormatSettings.DateSeparator+ComboYil.EditText+' '));
        TabVardiya.FieldByName('GIRIS').Value := '1900-01-01 00:00:00';
        TabVardiya.FieldByName('CIKIS').Value := '1900-01-01 00:00:00';
        TabVardiya.Post;
      end;
    end;
  end;
end;
procedure TVardiyaTanimlariDlg.PmSagClickPopup(Sender: TObject);
begin
  if VardiyaTuru = 'Sabit' then
    PmTabloyuOlustur.Visible:=False
  else
      PmTabloyuOlustur.Visible:=True;
end;

procedure TVardiyaTanimlariDlg.PmTabloyuOlusturClick(Sender: TObject);
var
  i:integer;
begin
  if TabVardiya.RecordCount < 1 then begin
    for I := 1 to DaysInAMonth(StrToInt(ComboYil.EditText),ComboAy.EditValue)  do begin
      TabVardiya.Insert;
      TabVardiya.FieldByName('AY').Value := ComboAy.EditValue;
      TabVardiya.FieldByName('GUN').Value := i;
      TabVardiya.FieldByName('YIL').Value := StrToInt(ComboYil.EditText);
      TabVardiya.FieldByName('GUNADI').AsString:=FormatDateTime('dddd',StrToDate(''+IntToStr(i)+FormatSettings.DateSeparator+IntToStr(ComboAy.EditValue)+FormatSettings.DateSeparator+ComboYil.EditText+' '));
      TabVardiya.FieldByName('GIRIS').Value := '1900-01-01 00:00:00';
      TabVardiya.FieldByName('CIKIS').Value := '1900-01-01 00:00:00';
      TabVardiya.Post;
    end;
  end;
end;
procedure TVardiyaTanimlariDlg.TabVardiyaAfterRefresh(DataSet: TDataSet);
begin
  YenileClick;
end;
procedure TVardiyaTanimlariDlg.YenileClick;
var
  VardiyaTuruS:string;
begin
  if VardiyaTuru = 'Sabit' then
    VardiyaTuruS := ' and AY = 0 and YIL = 0 '
  else
    VardiyaTuruS := ' and AY = '+IntToStr(ComboAy.EditValue)+' and YIL='+ComboYil.EditText+' ' ;

  TabVardiya.Close;
  TabVardiya.SQL.Text:=' Select * from PERS_VARDIYATANIM Where REHBERID='+IntToStr(RehberId)+' '+VardiyaTuruS+' ';
  TabVardiya.Open;
end;
procedure TVardiyaTanimlariDlg.TabVardiyaNewRecord(DataSet: TDataSet);
begin
    TabVardiya.FieldByName('REHBERID').Value := RehberId;
    TabVardiya.FieldByName('ISGUNU').Value := False;
end;

end.

