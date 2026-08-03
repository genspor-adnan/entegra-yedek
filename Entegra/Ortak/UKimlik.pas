unit UKimlik;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DBCtrls, Mask, ExtCtrls, Buttons, Db, menus, UCombo, DBTables,
  UFDCompatHelpers;

type
  TKimlikDlg = class(TForm)
    Panel1: TPanel;
    LabelKURUM: TLabel;
    LabelREFERANS: TLabel;
    LabelGIRISTARIH: TLabel;
    LabelCIKISTARIH: TLabel;
    LabelPOLIKLINIK: TLabel;
    LabelDOKTOR: TLabel;
    TextGelisNo: TDBText;
    LabelTEDAVI: TLabel;
    LabelKatilimYuzde: TLabel;
    DoktorSecTus: TSpeedButton;
    LabelYATGUNSAY: TDBText;
    RehberAraTus: TSpeedButton;
    ComboKURUM: TDBComboBox;
    ComboREFERANS: TDBComboBox;
    EditGIRISTARIH: TDBEdit;
    EditCIKISTARIH: TDBEdit;
    ComboPOLIKLINIK: TDBComboBox;
    ComboDOKTOR: TDBEdit;
    ComboTEDAVI: TDBComboBox;
    EditKatilimYuzde: TDBEdit;
    Panel2: TPanel;
    EvAdresiCercevesi: TBevel;
    AdSoyadCercevesi: TBevel;
    LabelAD: TLabel;
    LabelSOYAD: TLabel;
    LabelDOGUMYER: TLabel;
    LabelDOGUMTARIH: TLabel;
    LabelMESLEK: TLabel;
    LabelCINSIYET: TLabel;
    LabelKANGRUP: TLabel;
    LabelEVADRES: TLabel;
    LabelYAS: TLabel;
    EditYAS: TLabel;
    LabelTelefonlar: TLabel;
    LabelMEDENIHAL: TLabel;
    LabelISTEL: TLabel;
    LabelEVTEL: TLabel;
    LabelEVIL: TLabel;
    LabelEVILCE: TLabel;
    LabelEPOSTA: TLabel;
    LabelCEPTEL: TLabel;
    LabelDOSYANO: TLabel;
    EditAD: TDBEdit;
    EditSOYAD: TDBEdit;
    EditDOGUMYER: TDBEdit;
    EditDOGUMTARIH: TDBEdit;
    EditEVILCE: TDBEdit;
    ComboEVIL: TDBComboBox;
    ComboCINSIYET: TDBComboBox;
    ComboMEDENIHAL: TDBComboBox;
    ComboKANGRUP: TDBComboBox;
    ComboMESLEK: TDBComboBox;
    MemoEVADRES: TDBMemo;
    EditEVTEL: TDBEdit;
    EditISTEL: TDBEdit;
    EditEPOSTA: TDBEdit;
    EditCEPTEL: TDBEdit;
    EditDOSYANO: TDBEdit;
    GroupNOTLAR: TGroupBox;
    LabelNOTLAR: TLabel;
    MemoNOTLAR: TDBMemo;
    KapatTus: TBitBtn;
    ToolBarNavigator: TDBNavigator;
    DtsKimlik: TDataSource;
    DtsGelisler: TDataSource;
    EditPROTOKOLNO: TDBEdit;
    TabKimlik: TADOQuery;
    TabGelisler: TADOQuery;
    LabelDOKTORKOD: TDBText;
    DBText2: TDBText;
    procedure FormCreate(Sender: TObject);
    procedure DtsKimlikStateChange(Sender: TObject);
    procedure DoktorSecTusClick(Sender: TObject);
    procedure ComboPOLIKLINIKExit(Sender: TObject);
    procedure ComboKURUMClick(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboKURUMEnter(Sender: TObject);
    procedure DtsGelislerStateChange(Sender: TObject);
    procedure EditSOYADExit(Sender: TObject);
    procedure EditDOGUMTARIHExit(Sender: TObject);
    procedure TabKimlikAfterCancel(DataSet: TDataSet);
    procedure TabKimlikAfterPost(DataSet: TDataSet);
    procedure TabKimlikBeforeEdit(DataSet: TDataSet);
    procedure TabKimlikBeforePost(DataSet: TDataSet);
    procedure TabKimlikNewRecord(DataSet: TDataSet);
    procedure TabGelislerAfterPost(DataSet: TDataSet);
    procedure TabGelislerBeforeEdit(DataSet: TDataSet);
    procedure TabGelislerBeforePost(DataSet: TDataSet);
    procedure FormShow(Sender: TObject);
    procedure TabKimlikAfterScroll(DataSet: TDataSet);
    procedure TabKimlikAfterOpen(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
   function EskiAdSoyadVar:BOOL;
   procedure AppException(Sender: TObject; E: Exception);
   Function YeniDosyaNo : String;
  public
    { Public declarations }
    KimlikEklendi : Boolean;
    Ad,Soyad,Tel,Kurum, Polk, Dr, DrKod : String[50];
    procedure ControlGoruntule;
    function Gelis_Ekle : SmallInt;
  end;

var
  KimlikDlg: TKimlikDlg;

implementation

{$R *.DFM}
uses UTablo, UAraDlg, Udoktor, UVeriMotor;

var
   dtar, DosyanoRakSay : SmallInt;
   gun, ay, yil : Word;
   KimlikZorunlu : TStringList;
   PNO,DosyanoRakOnek, AktifYas : String[20];
   YeniEklenenKayit, TELEFONMASK : Boolean;
   TELEFONMASKEDIT : String[40];


procedure TKimlikDlg.FormCreate(Sender: TObject);
var Onkod : String[10];
    i : Smallint;
begin
   Application.OnException := AppException;

   KimlikZorunlu := TStringList.Create;
   GenotipIni.ReadSection('KIMLIK_ZORUNLU', KimlikZorunlu);
   DosyanoRakOnek := GenotipIni.ReadString('GenelOpsiyon', 'ONEK', '');
   DosyanoRakSay  := GenotipIni.ReadInteger('GenelOpsiyon', 'DOSYANO', 5);

   GenotipIni.ReadSection('CINSIYET', ComboCINSIYET.Items);
   GenotipIni.ReadSection('MEDENIHAL', ComboMEDENIHAL.Items);
   GenotipIni.ReadSection('IL', ComboEVIL.Items);
   GenotipIni.ReadSection('KANGRUP', ComboKANGRUP.Items);
   GenotipIni.ReadSection('MESLEK', ComboMESLEK.Items);
//   Tablo.YetkiTuslariBelirle('Kimlik', '', False, Tablo.DtsKimlik, AnaForm.ToolBarNavigator);
//   AnaForm.ControlGoruntule(KimlikDlg, 'GOR');
   if not KimlikDlg.LabelMEDENIHAL.Visible then
      KimlikDlg.LabelCINSIYET.Alignment := taRightJustify;
   ControlGoruntule;

   if ComboPOLIKLINIK.Visible then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select AD from POLIKLNK order by AD ';
      Tablo.Query1.Open;
      while not Tablo.Query1.eof do begin
        ComboPOLIKLINIK.Items.Add(Tablo.Query1.Fields[0].AsString);
        Tablo.Query1.next;
      end;
   end;
   if ComboKURUM.Visible then begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select KURUM from KURUM order by KURUM ';
      Tablo.Query1.Open;
      while not Tablo.Query1.eof do begin
        ComboKURUM.Items.Add(Tablo.Query1.Fields[0].AsString);
        Tablo.Query1.next;
      end;
   end;

   TELEFONMASK := GenotipIni.ReadBool('GenelOpsiyon', 'TELEFONMASK', False);
   if TELEFONMASK then begin
      TELEFONMASKEDIT := GenotipIni.ReadString('GenelOpsiyon', 'TELEFONMASKEDIT', '!\(999\)000 00 00;1;_');
      if pos('X', TELEFONMASKEDIT)>0 then begin
         s := trim(TELEFONMASKEDIT);
         TELEFONMASKEDIT := '!\';
         Onkod:='';
         for i := 1 to length(s) do
            if s[i] ='X' then TELEFONMASKEDIT := TELEFONMASKEDIT+'9'
            else if s[i] in ['0'..'9'] then begin
                    TELEFONMASKEDIT := TELEFONMASKEDIT+'9';
                    Onkod:=OnKod+s[i];
            end
            else TELEFONMASKEDIT := TELEFONMASKEDIT+s[i];
         TELEFONMASKEDIT := TELEFONMASKEDIT+';1;_';
      end;
   end;
end;

procedure TKimlikDlg.EditDOGUMTARIHExit(Sender: TObject);
var t3,tarih, tarih1 : TDateTime;
begin
   if EditDOGUMTARIH.Text = '' then exit;
   ShortDateFormat := 'dd/MM/YYYY';
   EditYAS.Caption := '';
   AktifYas := '';

   if pos('.', EditDOGUMTARIH.Text)>0 then
      raise exception.Create('Doğum tarihi için ''.'' yerine ''/'' kullanılmalı..');

  { if pos('/', EditDOGUMTARIH.Text)=0 then begin
      dtar := StrToInt(EditDOGUMTARIH.Text); //1985 veya 26
      if (dtar > 1900)and(dtar < 2020) then
          EditDOGUMTARIH.Text := '01/01/' + EditDOGUMTARIH.Text + ' 00:00:00'
      else if (dtar >= 0)and(dtar < 100) then
          DecodeDate(Date , yil, ay, gun);
          Dec(yil, dtar);
          EditDOGUMTARIH.Text := '01/01/' + IntToStr(yil) + ' 00:00:00';
   end; }
   if (length(EditDOGUMTARIH.Text)>10)and(copy(EditDOGUMTARIH.Text, 12,2)<> '00') then begin
              dtar := strtoint(copy(EditDOGUMTARIH.Text, 12,2));
              DecodeDate(Date , yil, ay, gun);
              Dec(yil, dtar);
              EditDOGUMTARIH.Text := '01/01/' + IntToStr(yil);// + ' 00:00:00';
          end;

   tarih:= StrToDate(EditDOGUMTARIH.Text); //12/7/1988
   if Date < Tarih Then exit
   else if Date = Tarih then begin
      gun:= 0; ay:= 0; yil := 0;
   end
   else If Date > Tarih then begin
      T3 := Date - Tarih + 1;
      DecodeDate(t3 , yil, ay, gun);
      Dec(yil,1900);
      Dec(ay);
   end;

   if yil = 0 Then
   If Ay = 0 Then
      AktifYas := Format('%d gün', [gun])
   Else
      AktifYas := Format('%d ay %d gün', [ay, gun])
   else if (yil > 0)and(yil < 2) Then
      AktifYas := Format('%d yıl %d ay', [yil, ay])
   else if (yil >= 0)and(yil < 5) Then
      AktifYas := Format('%d yıl %d ay', [yil, ay])
   else
      AktifYas := Format('%d', [yil]);

   EditYAS.Caption := AktifYas;
end;

procedure TKimlikDlg.AppException(Sender: TObject; E: Exception);
begin
  // PG guvenlik agi: PG'de basarisiz bir sorgu transaction'i abORT eder ve SONRAKI tum komutlar
  //   "current transaction is aborted" ile reddedilir -> baglanti (Tablo.FDCnn) donuncaya kadar
  //   kitlenir (MSSQL'de her komut autocommit oldugu icin bu olmaz). Ele alinmayan bir hata global
  //   handler'a dustuyse islem zaten bitti -> acik/abort transaction'i geri al ki oturum kilitlenmesin.
  //   YALNIZ vmPG (MSSQL davranisi aynen korunur); rollback'i sarmala (tx yoksa hata vermesin).
  if (AktifVeriMotor = vmPG) and Assigned(Tablo) and Assigned(Tablo.FDCnn) then
    try
      if Tablo.FDCnn.InTransaction then
        Tablo.FDCnn.Rollback;
    except
      // rollback basarisiz olsa da asil hatayi gostermeye devam et
    end;

  if pos('Key violation', E.Message) > 0  then
     showmessage('Aynı numara ya da isimle kayıtlı bilgi var!!!')
  else if pos('not a valid date', E.Message) > 0  then begin
          dtar := StrToInt(EditDOGUMTARIH.Text); //1985 veya 26
          if (dtar > 1900)and(dtar < 2020) then
              EditDOGUMTARIH.Text := '01/01/' + EditDOGUMTARIH.Text + ' 00:00:00'
          else if (dtar >= 0)and(dtar < 100) then begin
              DecodeDate(Date , yil, ay, gun);
              Dec(yil, dtar);
              EditDOGUMTARIH.Text := '01/01/' + IntToStr(yil) + ' 00:00:00';
          end;
          perform(cm_dialogkey,vk_tab,0);
       end
  else showmessage(E.Message);
end;


procedure TKimlikDlg.DtsKimlikStateChange(Sender: TObject);
begin
   Tablo.YetkiTuslariBelirle('Kimlik', '', 'A',  DtsKimlik, KimlikDlg.ToolBarNavigator);
   if DtsKimlik.State = dsInsert then EditAD.SetFocus;;
end;

procedure TKimlikDlg.ControlGoruntule;
var ii : integer;
    gg : Boolean;
    DtsKimlik : TDataSource;
begin
  {Tuşları görüntüle/görüntüleme}

   for ii := 0 To KimlikDlg.ComponentCount - 1 do begin
       if GenotipIni.ReadInteger('GOR', KimlikDlg.Components[ii].Name, 1)=0 then
          gg :=False
       else gg := True;
       if not((KimlikDlg.Components[ii] is TPopupMenu)or(KimlikDlg.Components[ii] is TDataSource)or(KimlikDlg.Components[ii] is TADOQuery)
           or(KimlikDlg.Components[ii] is TMenuItem))then
           try
            TWinControl(KimlikDlg.Components[ii]).Visible := gg;
{            if (gg)and(KimlikDlg.Components[ii] is TDBEdit)and(TDBEdit(KimlikDlg.Components[ii]).DataSource = nil) then
                TDBEdit(KimlikDlg.Components[ii]).DataSource := DtsKimlik
            else if (gg)and(KimlikDlg.Components[ii] is TDBMemo)and(TDBMemo(KimlikDlg.Components[ii]).DataSource = nil) then
                TDBMemo(KimlikDlg.Components[ii]).DataSource := DtsKimlik
            else if (gg)and(KimlikDlg.Components[ii] is TDBComboBox)and(TDBComboBox(KimlikDlg.Components[ii]).DataSource = nil) then
                TDBComboBox(KimlikDlg.Components[ii]).DataSource := DtsKimlik }
           except
            showmessage(KimlikDlg.Components[ii].Name);
           end;
   end;
   if EditPROTOKOLNO.Visible then EditPROTOKOLNO.DataField := 'PROTOKOLNO';
   if not ComboDOKTOR.Visible then DoktorSecTus.Visible := False;
end;

procedure TKimlikDlg.ComboPOLIKLINIKExit(Sender: TObject);
begin
   if (TabGelisler.State = dsBrowse)or(ComboDOKTOR.Text<>'') then exit;
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text := 'Select DOKTORKOD, DOKTOR From DOKTOR Where UZMANLIK='''+ComboPOLIKLINIK.Text+''' AND DURUM<>''PASİF'' order by DOKTORKOD';
   Tablo.Query3.Open;
   LabelDOKTORKOD.Field.AsString := Tablo.Query3.Fields[0].AsString;
   ComboDOKTOR.Field.AsString := Tablo.Query3.Fields[1].AsString;
end;

procedure TKimlikDlg.DoktorSecTusClick(Sender: TObject);
begin
   DoktorDlg.DBGrid1.ReadOnly := True;
//   DoktorDlg.DBGrid1.Options := [dgTitles,dgIndicator,dgColumnResize,dgColLines,dgRowLines,dgTabs,dgRowSelect,dgAlwaysShowSelection,dgConfirmDelete,dgCancelOnExit];

   DoktorDlg.DBNavigator.VisibleButtons :=[];
   DoktorDlg.ShowModal;

   TabGelisler.Edit;
   LabelDOKTORKOD.Field.AsString := DoktorDlg.TabDoktor.Fields[0].AsString;
   ComboDOKTOR.Field.AsString := DoktorDlg.TabDoktor.Fields[1].AsString;
   ComboPOLIKLINIK.Field.AsString := DoktorDlg.TabDoktor.Fields[2].AsString;
   DoktorDlg.DBGrid1.ReadOnly := False;
end;

procedure TKimlikDlg.ComboKURUMClick(Sender: TObject);
begin
   Tablo.Query3.Close;
   Tablo.Query3.SQL.Text := 'Select FATURA,KATKIYUZDE, KDV  From KURUM where KURUM = '''+TabGelisler.FieldByName('KURUM').AsString+'''';
   Tablo.Query3.Open;
   EditKatilimYuzde.Text := Tablo.Query3.Fields[1].AsString;
   TabGelisler.FieldByName('KDVDURUM').AsString := Tablo.Query3.Fields[2].AsString;
end;

procedure TKimlikDlg.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
//   Tablo.F_Tuslari('Kimlik', Key, ToolBarNavigator);
end;

procedure TKimlikDlg.ComboKURUMEnter(Sender: TObject);
begin
   if DtsKimlik.State in [dsInsert, dsEdit] then
      TabKimlik.Post;
end;

procedure TKimlikDlg.DtsGelislerStateChange(Sender: TObject);
begin
   if DtsGelisler.State = dsEdit then TabKimlik.Edit;
end;

function TKimlikDlg.EskiAdSoyadVar:BOOL;
begin
  AraDlg.AraQuery1.Close;
  AraDlg.AraQuery1.SQL.Text :='select * from KIMLIK '+
                    'where AD = '''+EditAD.Text+''' AND SOYAD = '''+EditSoyad.Text+'''';
  AraDlg.AraQuery1.open;

  if AraDlg.AraQuery1.RecordCount = 0 then exit;

  AraDlg.ShowModal;
  case AraDlg.ModalResult of
    idCANCEL : begin
                EskiAdSoyadVar := FALSE;
                exit;
               end;
    idOK     : begin
                TabKimlik.Cancel;
                TabKimlik.Close;
                TabKimlik.Parameters.ParamByName('PDosyaNo').Value := AraDlg.AraQuery1.FieldByname('DOSYANO').AsString;
                TabKimlik.Open;
//                Tablo.TabGelisler.Close;
//                Tablo.TabGelisler.ParamByName('PDosyaNo').AsString := AraDlg.AraQuery1.FieldByName('DOSYANO').AsString;
//                Tablo.TabGelisler.Open;
                EskiAdSoyadVar := TRUE;
                end;
    end;{case}
end;

procedure TKimlikDlg.EditSOYADExit(Sender: TObject);
begin
  if (TabKimlik.state = dsInsert)and(GenotipIni.ReadInteger('GenelOpsiyon', 'AYNI KAYITLARI BUL', 0) = 1)and
     (EskiAdSoyadVar) then Abort;
end;

Function TKimlikDlg.YeniDosyaNo : String;
var Rakam : longint;
    i : smallint;
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select MAX(DOSYANO) from KIMLIK';
   if DosyanoRakOnek <> '' then Tablo.Query1.SQL.Add(' Where DOSYANO LIKE '''+DosyanoRakOnek+'%''');
   Tablo.Query1.Open;
   if Tablo.Query1.Fields[0].AsString = '' then
      PNO := '1'
   else
      PNO := Tablo.Query1.FieldS[0].AsString;
   Delete(PNO,1,length(DosyanoRakOnek));
   try
     Rakam := StrToInt(PNo);
     Inc(Rakam);
     PNo := IntToStr(Rakam);
   except
     raise exception.Create('Dosya Numarasında Rakam Dışında Karakter Var!');
   end;
   for i:=1 to DosyanoRakSay-length(PNo) do insert('0',PNo,1);
   PNO := DosyanoRakOnek+PNO;
   YeniDosyaNo := PNO;
end;

procedure TKimlikDlg.TabKimlikAfterCancel(DataSet: TDataSet);
begin
   TabGelisler.Cancel;
   Panel1.Visible := False;
end;

procedure TKimlikDlg.TabKimlikAfterPost(DataSet: TDataSet);
begin
   if YeniEklenenKayit then begin
      KimlikEklendi := True;
      TabKimlik.Close;
      TabKimlik.Parameters[0].Value:= PNO;
      TabKimlik.Open;
      Gelis_Ekle;
      TabGelisler.Cancel;             
      TabGelisler.Close;
      TabGelisler.Parameters[0].Value := PNO;
      TabGelisler.Parameters[1].Value:= 1;
      TabGelisler.Open;
      TabGelisler.Last;
//      LogIslemleri('Kimlik', 'Ekleme', TabKimlik, True);
   end
   else
     if TabGelisler.State in [dsEdit, DsInsert] then TabGelisler.Post;
//     LogIslemleri('Kimlik', 'Değiş', TabKimlik, True);
   Panel1.Visible := True;
end;

procedure TKimlikDlg.TabKimlikBeforeEdit(DataSet: TDataSet);
begin
   YeniEklenenKayit := False;
end;

procedure TKimlikDlg.TabKimlikBeforePost(DataSet: TDataSet);
var i : smallint;
begin
   for i := 0 to KimlikZorunlu.Count-1 do
     if TabKimlik.FieldByName(KimlikZorunlu.Strings[i]).AsString = '' then
        if (pos('TEL',KimlikZorunlu.Strings[i])>0)and(TabKimlik.FieldByName('EVTEL').AsString='')and
           (TabKimlik.FieldByName('ISTEL').AsString='')and(TabKimlik.FieldByName('CEPTEL').AsString='')then
           raise Exception.Create(KimlikZorunlu.Strings[i]+' Dolu Olmalı!!!!')
        else if pos('TEL',KimlikZorunlu.Strings[i])=0  then
                raise Exception.Create(KimlikZorunlu.Strings[i]+' Dolu Olmalı!!!!');

   if YeniEklenenKayit then begin
      TabKimlik.Fields[1].AsString := TrimLeft(TabKimlik.Fields[1].AsString);
      TabKimlik.Fields[2].AsString := TrimLeft(TabKimlik.Fields[2].AsString);
      TabKimlik.Fields[0].AsString := YeniDosyaNo;
   end;
end;

procedure TKimlikDlg.TabKimlikNewRecord(DataSet: TDataSet);
begin
   YeniEklenenKayit :=True;
   Panel1.Visible := False;
   TabKimlik.FieldByName('AD').AsString := Ad;
   TabKimlik.FieldByName('SOYAD').AsString := SoyAd;
   if pos('EV',uppercase(Tel))>0 then
      TabKimlik.FieldByName('EVTEL').AsString := copy(Tel,1,15)
   else if (pos('İŞ',Tel)>0)or(pos('iş',Tel)>0) then
      TabKimlik.FieldByName('ISTEL').AsString := copy(Tel,1,15)
   else if pos('CEP',uppercase(Tel))>0 then
      TabKimlik.FieldByName('CEPTEL').AsString := copy(Tel,1,15);

//   TabGelisler.Insert;
end;

procedure TKimlikDlg.TabGelislerAfterPost(DataSet: TDataSet);
begin
{ if YeniEklenenKayit then begin
      TabGelisler.Close;
      TabGelisler.Parameters[0].AsString := PNO;
      TabGelisler.Open;
//      LogIslemleri('Kimlik', 'Ekleme', TabKimlik, True);
   end;}
end;

procedure TKimlikDlg.TabGelislerBeforeEdit(DataSet: TDataSet);
begin
   YeniEklenenKayit := False;
end;

procedure TKimlikDlg.TabGelislerBeforePost(DataSet: TDataSet);
begin
{   if YeniEklenenKayit then begin
      TabGelisler.Fields[0].AsString := PNO;
      TabGelisler.Fields[1].AsInteger := 1;
      TabGelisler.FieldByName('KURUM').AsString := GenotipIni.ReadString('GenelOpsiyon', 'VarsayKurum', '');
      TabGelisler.FieldByName('GIRISTARIH').AsDateTime := now;
      if GenotipIni.ReadBool('GenelOpsiyon', 'EKOTOMATIK', False) then begin
         Query3.SQL.Text := 'Insert Into EK (DOSYANO,GELISNO) VALUES ('''+TabKimlik.Fields[0].AsString+''', 1)';
         Query3.ExecSQL;
      end;
   end;   }
end;

Function Protokolno:Integer;
begin
   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select MAX(CAST(PROTOKOLNO as INT))   from GELISLER ';
   Tablo.Query1.Open;
   if Tablo.Query1.Fields[0].AsString = '' then
      Protokolno := 1
   else
      Protokolno := Tablo.Query1.Fields[0].AsInteger + 1;
end;

function TKimlikDlg.Gelis_Ekle : SmallInt;
var s : String[5];
begin
   Tablo.Query4.Close;
   Tablo.Query4.SQL.Text := 'Select KDV  From KURUM where KURUM = '''+GenotipIni.ReadString('GenelOpsiyon', 'VarsayKurum', '')+'''';
   Tablo.Query4.Open;

   Tablo.Query1.Close;
   Tablo.Query1.SQL.Text := 'Select MAX(GELISNO) from GELISLER WHERE DOSYANO = '''+TabKimlik.Fields[0].AsString+'''';
   Tablo.Query1.Open;
   if Tablo.Query1.Fields[0].AsString = '' then
      s := '1'
   else
      s := IntToStr(Tablo.Query1.FieldS[0].AsInteger + 1);

   if Kurum='' then
      Kurum := GenotipIni.ReadString('GenelOpsiyon', 'VarsayKurum', '');

   Tablo.Query3.Close;
   if KimlikDlg.EditPROTOKOLNO.Visible then
      Tablo.Query3.SQL.Text := 'Insert Into GELISLER (DOSYANO,GELISNO,GIRISTARIH, POLIKLINIK, DOKTOR,DOKTORKOD,KURUM, KDVDURUM,PROTOKOLNO,KULLANICI) VALUES ('''+TabKimlik.Fields[0].AsString+
                         ''','+s+','''+FormatDateTime('mm/dd/yyyy hh:mm', Now)+''','''+Polk+''','''+Dr+''','''+DrKod+''','''+Kurum+''','''+
                         Tablo.Query4.Fields[0].AsString+''','+IntToStr(Protokolno)+','''+Kullanan+''')'
   else
      Tablo.Query3.SQL.Text := 'Insert Into GELISLER (DOSYANO,GELISNO,GIRISTARIH, POLIKLINIK, DOKTOR,DOKTORKOD,KURUM, KDVDURUM, KULLANICI) VALUES ('''+TabKimlik.Fields[0].AsString+
                         ''','+s+','''+FormatDateTime('mm/dd/yyyy hh:mm', Now)+''','''+Polk+''','''+Dr+''','''+DrKod+''','''+Kurum+''','''+
                         Tablo.Query4.Fields[0].AsString+''','''+Kullanan+''')';

   Tablo.Query3.ExecSQL;

   if GenotipIni.ReadBool('GenelOpsiyon', 'EKOTOMATIK', False) then begin
      Tablo.Query3.Close;
      Tablo.Query3.SQL.Text := 'Insert Into EK (DOSYANO,GELISNO) VALUES ('''+TabKimlik.Fields[0].AsString+''', '+s+')';
      Tablo.Query3.ExecSQL;
   end;
   Gelis_Ekle := StrToInt(s);
end;

procedure TKimlikDlg.FormShow(Sender: TObject);
var i : smallint;
begin
   TabKimlik.Close;
   TabKimlik.Parameters[0].Value := Tablo.TabKimlik.Fields[0].AsString;
   TabKimlik.Open;
   if Tablo.TabKimlik.Fields[0].AsString='' then
      TabKimlik.Append
   else begin
      Tablo.Query1.Close;
      Tablo.Query1.SQL.Text := 'Select isnull(GELISNO,0) from GELISLER where DOSYANO='''+TabKimlik.Parameters[0].Value+
         ''' and GIRISTARIH >='''+FormatDateTime('mm/dd/yyyy 00:00', now)+''' and GIRISTARIH <='''+FormatDateTime('mm/dd/yyyy 23:59', now)+'''';
      Tablo.Query1.Open;
      if Tablo.Query1.RecordCount>0 then
         i := Tablo.Query1.Fields[0].AsInteger
      else
         i := Gelis_Ekle;

      TabGelisler.Cancel;
      TabGelisler.Close;
      TabGelisler.Parameters[0].Value := TabKimlik.Parameters[0].Value;
      TabGelisler.Parameters[1].Value:= i;
      TabGelisler.Open;
      TabGelisler.Last;
   end;
end;

procedure TKimlikDlg.TabKimlikAfterScroll(DataSet: TDataSet);
begin
//   TabGelisler.Parameters[0].AsString := Tablo.TabGelisler.Fields[0].AsString;
//   TabGelisler.Parameters[1].AsString := Tablo.TabGelisler.Fields[1].AsString;
//   TabGelisler.Open;
//   EditDOGUMTARIHExit(Self);
end;

procedure TKimlikDlg.TabKimlikAfterOpen(DataSet: TDataSet);
begin
      if TELEFONMASK then begin
         EditEVTEL.Field.EditMask := TELEFONMASKEDIT; //'!\(999\)000 00 00;1;_';
         EditISTEL.Field.EditMask := TELEFONMASKEDIT; //'!\(999\)000 00 00;1;_';
         EditCEPTEL.Field.EditMask := TELEFONMASKEDIT; //'!\(999\)000 00 00;1;_';
      end;
end;

procedure TKimlikDlg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   if TabKimlik.State in [dsEdit,dsInsert] then
      if Application.MessageBox('İşlemler kaydedilmedi. Kayıt edilsin mi? ', 'GenoTIP ONAY', MB_YESNO)=IDYES then
         TabKimlik.Post;
end;

end.

