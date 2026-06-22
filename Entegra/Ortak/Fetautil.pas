unit Fetautil;
                                     
interface

uses Graphics, Forms, SysUtils, Messages, Classes,  DBGrids, cxCurrencyEdit, Menus,
  comctrls, StdCtrls, UFDCompatHelpers, FireDAC.Comp.Client, {$IFNDEF NO_UTABLO}UCombo,uTablo,{$ENDIF}Math,comobj,WINDOWS,CONTROLS,
  NB30,Variants,Grids,Db, JvRichEdit, ActiveX, OleCtnrs, ExtCtrls, CheckLst,DdeMan, cxTreeView,JPeg;

type
  TGenotipBilgi = record
    ProgramKodlari: array[1..20] of Word;     
    CokKullanici: Word;
    Ad: array[0..49] of Char;                          
    Bos: array[0..49] of Byte;
    Crc: Word;
  end;
                                     
type                                
  Pdizi = array[0..255] of Byte;

                   
{$IFNDEF NO_UTABLO}
function PopUpSubMenuIslemleri(Menu1: TMenuItem; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string; Tag1:Integer=0): TMenuItem;
function PopUpMenuIslemleri(Menu1: TPopUpMenu; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string; Tag1:Integer=0): TMenuItem;
function INIToComboList1(ComboBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
function INIToList1(ListBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
function INIToGrid1(Grid: TDBGrid; Kolon: Integer; AnahtarKelime: string; Ini: TIni): Bool;
procedure ComboDropDown(Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);overload;
procedure ComboDropDown(SectionName: string;Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);overload;
function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TFDConnection; Degis: Boolean): string;
function TarihBul():TDateTime;
{$ENDIF}

procedure ModalDialog(Handel: THandle; YordamAd: TFarProc; DialogAd: PChar; BabaDialog: HWnd);
function Atasi(Kod:string):string;
function DirName(Exename: string): string;
function StrToReal(OkuS: string): Real;
function TarihFarki(tarih1, tarih2: string): Integer;
function Birlestir(st: TStringList): string;
procedure Parcala(st: string; var s: TStringList);
function CmToPixelToCm(Canvas: TCanvas; Cm: Real; YatayDusey, CmPixel: Integer): Real;
function IsDateOk(tarih1: string): Boolean;
//Function GAY2AGY(tar: String):String;
//Function GAY2AGY_Saat(tar: String):String;
function IsFileOpen(FileName: string): Integer;
function UpStr(St: string): string;
function FetaSetSize(FileName: string; Sz: Integer): Boolean;
function FetaGetSysDir: string;
procedure Sifrele(Yon: Integer; PSif: Pointer; Size: Integer);
function CrcHesapla(PSif: Pointer; Size: Integer): Word;
procedure AgacYapisiKod(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1: string; Yenile: Char);
procedure AgacYapisi(TreeView1: TcxTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
function AgactaBul(TreeView1: TcxTreeView; Alan1: string): TTreeNode;
procedure AgacYapisinaCevir(TreeView1: TcxTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
procedure ComboChange(Sender: TObject; var Ekle: Boolean; var Tut: string);
procedure GetFileList(FileExt: string; Target: TStrings);
function RevPos(Substr: string; S: string): Integer;
procedure adjpath(var s: string);
function Benzestir(giren: string): TStringlist;
procedure ParcalaPar(par: char; st: string; var s: TStringList);
function Float_ToStr(n:real):string;
function GetFileVersion(FileName: string) : string;
Function checkTCId(tcId: String):Boolean;
function TariheGunEkle(Tarih: TDateTime; Ekleme: SmallInt): SmallInt;
function TurkceDegisBoslukBirakma(AString: string): string;


{ver 1.0}
function GetMACAdress: string;
procedure LogaEkle(s :string);
{ 15.11.2008 23:25 değiştirildi }
function _query_exec(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant;
  UseDataSource: TDataSource = nil) : TADOQuery;
{ver 1.1}
function StringGridToRTF(Title: string;grid : TStringGrid): string;
function DbGridToRTF(Title,ABlockName: string;grid : TDBGrid;ExtraFields: array of string): string;
{ver 1.2}
function GetDelimitedString(var s : string): string;overload;
function GetDelimitedString(var s : string;delimiter : string): string;overload;
function LeadingZero(value: Integer;lz: byte): string;Overload;
function IIf(condition: Boolean;IfTrue: string;IfFalse: string): string;
function Select(index: Integer;values: array of string): string;
function _Default(str,defaultValue : string): string;
{ver 1.3}
function MinInt(A,B: Integer): Integer;
{ver 1.4}                                      
function CaseOf(AValue: string;AValues: array of string) : integer;
function SubString(AValue: string;StartIndex: Integer;Count : integer = 0): string;
{ver 1.5}
procedure EnableDisableSubControls(Control : TWinControl;Enabled: Boolean);
{ver 1.6}
function DbTableToRtf(ATitle,ABlockName: string;ATable: TDataset;Fields: array of string; ColumnWidths: array of integer): string;
{ver 1.7}
function __FindComponent(AName: string;ARoot: TComponent): TComponent;
function TCKimlikDogrula(TCNo: Int64): boolean;
function ComponentToString(Component: TComponent): string;
function StringToComponent(Value: string): TComponent;
function GetGenotipConnectionString: String;
{ver 1.8}
procedure LockControl(c: TWinControl; bLock: Boolean);
{ver 1.9}
// The same version of GetDelimitedString but it is for ScriptEngine
function GetDelimitedStringEx(var s : string;delimiter : string): string;
{ver 2.0}
/// <summary>
/// Kolon içindeki değerlerin en büyüğünü döndürür.
/// </summary>
/// <param name="cnn">Bağlantı nesnesi</param>
/// <param name="TableName">Tablo adı</param>
/// <param name="ColumnName">Kolon adı</param>
/// <param name="WhereClause">Sorgunun WHERE kısmı</param>
/// <returns>Sorgu içindeki kolonun en büyük değeri döner. Eğer sorgudan hiç kayıt dönmezse sonuç 0 döner. </returns>
function FindMaximumOfColumn(cnn: TADOConnection;TableName,ColumnName,WhereClause: string): Integer;
function TurkishToEnglishCharset(st :string) :string;
{ver 2.1}
procedure TrimSpaces(ACtrl : TRichEdit);
function RemoveBlock(AEditor: TCustomRichEdit;ABlockName: string): Boolean;
{ver 2.2}
function DataExists(cnn: TADOConnection;ASQL: string;AParams: array of string;AParamValues: array of Variant): Boolean;
{ver 2.3}
function ControlToString(AComponent : TComponent) : string;
function FindParam(AEditor: TRichEdit; AString: string;var APos: integer): Integer;overload;
function FindParam_Jv(AEditor: TJvCustomRichEdit; AString: string;var APos: integer): Integer;overload;
procedure InternalReplace(AEditor: TRichEdit; AParam: string;AValue: string);
{ver 2.4}
function FindParam(AEditor: TRichEdit;
  AString: string;AStartPos: Integer;var APos: integer): Integer;overload;
function FindVariables(AEditor: TRichEdit): string;
{ver 2.5}
function VersionToInteger(AVersion: string): Integer;
{ver 2.6}
function GetTableRecordCount(cnn: TADOConnection;ATableName: string): Integer;
{ver 2.7}
procedure DeleteFiles(Path: string;Mask: string);
{ver 2.8}
function RemoveMenuShortCutSign(S: string): string;
{ver 2.9} // 09/05/2008 10:47:16
{ver 3.0} // 12/05/2008 10:28:00
function TrimStringWithEllipsis(ASource: string;ALength: Integer): string;
{ver 3.1} // 16/05/2008 10:46:52
function GetOleClassDisplayName(const AClassName: string): string;
{ver 3.2} // 28/05/2008 14:03:03
function StreamToHexString(AStream: TStream;ByteCountPerLine: Byte): string;
procedure HexStringToStream(AHexString: string;ADestination: TStream);
{ver 3.3} // 19/06/2008 11:35:42
function TurkishUpperCaseChar(st: char): Char;
function TurkishUppercaseString(st: string): string;
{ver 3.4} // 08/07/2008 14:51:36
procedure GetOleObjectContentAsImage(AOleObject: IOleObject;AImage: TImage);
{ver 3.5} // 15/09/2008 17:32:52
function StringToStringList(ASource: string;ADelimiter: string = ';'): TStringList;
{ver 3.6} // 18/10/2008 12:42:17
procedure FillStringListFromDataSet(ADestList: TStrings;
  ASourceDataSet : TDataSet;ASourceField: string);
{ver 3.7} // 20/10/2008 15:57:53
function IsNullOrEmpty(AField: TField) : Boolean;
{ver 3.8} // 21/10/2008 15:33:46
procedure StringdenIsarete(ADegerListesi: string; AKontrol: TCheckListBox; AKaynakTablo: TDataSet; AKaynakAlan: string);
function IsarettenStringe(AKontrol: TCheckListBox; AKaynakTablo: TDataSet; AKaynakAlan: string): string;
{ver 3.9} // 22/10/2008 14:55:30
{$IFNDEF NO_UTABLO}
function VersiyonKontrolu(Modul, Versiyon : String; i:integer; GenotipIni:TIni;GenRegIni : TRegIni; RgstryLC:char) : Integer;
{$ENDIF}
{ver 4.0} // 18/11/2008 09:35:34
function _query_cmd(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant; UseDataSource: TDataSource = nil) : TADOCommand;
{ver 4.1} // 25/11/2008 13:30:59
function IlkHarfleriBuyuk(Str: string): string;
function IlkHarfiKucuk(s : string): string;
{ver 4.2} // 25/11/2008 13:30:59
function LeadingZero(ANumber: string;ADigit: Integer): string;Overload;
function FinishingSpace(ANumber: string;ADigit: Integer): string;
{ver 4.3} // 25/11/2008 13:30:59
function GetCurrentSessionID: Cardinal;
function GetCurrentSID: string;
function GetCurrentUserName :string;
function GetCurrentComputerName :string;
function VeritabaniListesiGetir:TStringlist;
function FCurrToStr(Para:Currency):string;
function FStrToCurrDef(Para:string;Def: Currency):Currency;
function FExtToStr(Sayi:Extended;OndalikDigitSayisi:integer=6):string;
procedure FormatDuzenle(prop:TcxCurrencyEditProperties;Dig:Integer);
function ResizeJPG(var oJPG: TJpegImage; Percent, Quality: integer): integer;
function JPGKucult(var oJPG: TJpegImage; Pixel:integer): integer;
function RoundN(x: Extended; d: Integer): Extended;
function SifreKontrolu(OncekiSifre,inputStr,inputStr2 : string) : string;

const
  DataFile = 'Datgen.dll';
var
  GenotipBilgi: TGenotipBilgi;
  ProgramTerminating : Boolean;

const
  SID_REVISION  = 1;

  FILENAME_ADVAPI32     = 'ADVAPI32.DLL';

  PROC_CONVERTSIDTOSTRINGSIDA   = 'ConvertSidToStringSidA';


type
  TConvertSidToStringSidA = function (Sid: PSID;
    var StringSid: LPSTR): BOOL; stdcall;

implementation

uses Dialogs{$IFNDEF NO_UTABLO},oPENsqlsERVER,UMesaj{$ENDIF},Registry, SynRegExpr, StrUtils, Prjconst, UGenSifre;

var
  PixPerInch: TPoint;

function IlkHarfiKucuk(s : string): string;
begin
  if (Length(s) > 0) then
    s[1] := LowerCase(S)[1];
  Result := s;
end;

function IlkHarfleriBuyuk(Str: string): string;

  function IlkHarfBuyuk(S: string): string;
  begin
    if (Length(S) > 0) then begin
      S[1] := UpCase(S[1]);
      Result := s;
    end else
      Result := '';
  end;
var
  r : TRegExpr;
  s : string;
  i : Integer;
  fp : Integer;
  lp : Integer;
begin
  str := LowerCase(Str);
  r := TRegExpr.Create;
  try
    if (Pos('_',Str) = 0) then begin
      r.Expression := '((no)|(No)|(nO)|(NO))$';
      if (r.Exec(Str)) then begin
        if (Length(Str) > 2) then begin
          s := IlkHarfBuyuk(Copy(Str,0,r.MatchPos[0] - 1)) + 'No';
          Result := s;
        end else Result := 'No';
      end else Result := IlkHarfBuyuk(Str);
    end else begin
      r.Expression := '_';
      r.InputString := Str;
      s := '';
      fp := 1;
      while (r.ExecPos(fp)) do begin
        s := s + IlkHarfleriBuyuk(Copy(Str,fp,r.MatchPos[0] - fp));
        fp := r.MatchPos[0] + 1;
      end;
      if (fp < Length(Str)) then
        s := s + IlkHarfleriBuyuk(Copy(Str,fp,100));
      Result := s;
    end;
  finally
    r.Free;
  end;
end;

function PopUpSubMenuIslemleri(Menu1: TMenuItem; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string; Tag1:Integer=0): TMenuItem;
var
  NewItem: TMenuItem;
  i: integer;
  silindi: boolean;
  c: string[1];
  bas: string;
begin
  if IslemTuru = 'Ekle' then
  begin
    NewItem := TMenuItem.Create(Menu1);
    NewItem.Caption := Baslik1;
    NewItem.OnClick := RaporSecClick;
    NewItem.Tag:= Tag1;
    Menu1.Add(NewItem);
    PopUpSubMenuIslemleri := NewItem;

{    SubMenuItem := PopupStokBoyutBarkod.CreateMenuItem;
    SubMenuItem.Caption := Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Description;
    SubMenuItem.Tag := Tablo.RepStokKartBarkodAyarlar.Properties.Items[i].Value;
    SubMenuItem.OnClick := BtnBarkodUretClick;
    ret1.Add(SubMenuItem);     }
  end
end;



function PopUpMenuIslemleri(Menu1: TPopUpMenu; RaporSecClick: TNotifyEvent; IslemTuru, Baslik1, Baslik2: string; Tag1:Integer=0): TMenuItem;
var
  NewItem: TMenuItem;
  i: integer;
  silindi: boolean;
  c: string[1];
  bas: string;
begin
  if IslemTuru = 'Ekle' then
  begin
    NewItem := TMenuItem.Create(Menu1);
    NewItem.Caption := Baslik1;
    NewItem.OnClick := RaporSecClick;
    NewItem.Tag:= Tag1;
//      c := copy(Baslik1,1,1);
//      NewItem.ShortCut := ShortCut(Word(c), [ssCtrl, ssAlt]);
    Menu1.Items.Add(NewItem);
    PopUpMenuIslemleri := NewItem;
  end
  else if IslemTuru = 'Sil' then
  begin
    silindi := False; i := 0;
    while (not silindi) or (i < Menu1.Items.count) do
    begin
      bas := Menu1.Items[i].caption;
      Delete(bas, pos('&', bas), 1);
      if bas = Baslik1 then
      begin
        Menu1.Items.Delete(i); //     Menu1.Items.Remove(Menu1.Items[i]);
        silindi := True;
      end;
      inc(i);
    end
  end
  else if IslemTuru = 'Degistir' then
  begin
    i := 0;
    while i < Menu1.Items.count do
    begin
      bas := Menu1.Items[i].caption;
      Delete(bas, pos('&', bas), 1);
      if bas = Baslik1 then
        Menu1.Items[i].caption := Baslik2;
      inc(i);
    end;
  end
end;



function _query_cmd(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant;
  UseDataSource: TDataSource = nil) : TADOCommand;
var
  i     : Integer;
  fieldName: string;
  field : TField;
begin
  if ((Length(paramNames) > 0)) then
    begin
      if (Length(params) > 0) then begin
        for i := Low(paramNames) to High(paramNames) do
          begin
            if ((VarType(params[i]) in [vtString,vtWideString,vtPChar,vtPWideChar,
              vtChar]) or (VarType(params[i]) = varString)) then
              sql := StringReplace(sql,paramNames[i],#39 + StringReplace(params[i],#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
            else
              if Pos('*datetime*',paramNames[i]) > 0 then
                sql := StringReplace(sql,StringReplace(paramNames[i],'*datetime*','',[rfReplaceAll]),#39 + FormatDateTime('yyyymmdd hh:nn:ss',params[i]) + #39,[rfReplaceAll])
              else
                sql := StringReplace(sql,paramNames[i],params[i],[rfReplaceAll]);
          end;
      end else if Assigned(UseDataSource) then begin
        for i := Low(paramNames) to High(paramNames) do begin
          { $ işaretini kaldırıyoruz }
          fieldName := SubString(paramNames[i],2);
          { alanı buluyoruz }
          field := UseDataSource.DataSet.FieldByName(fieldName);
          { tipine göre sql içinde yerine koyuyoruz }
          case field.DataType of
            ftString: begin
              sql := StringReplace(sql,paramNames[i],#39 + StringReplace(field.AsString,#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
            end;
            ftDateTime: begin
              sql := StringReplace(sql,paramNames[i],#39 + FormatDateTime('yyyymmdd hh:nn:ss',field.AsDateTime) + #39,[rfReplaceAll])
            end;
            ftBoolean: begin
              sql := StringReplace(sql,paramNames[i],IIf(field.AsBoolean,'1','0'),[rfReplaceAll]);
            end;
          else
            sql := StringReplace(sql,paramNames[i],field.AsString,[rfReplaceAll]);
          end;
        end;
      end;
    end;
  Result := TADOCommand.Create(nil);
  Result.Connection := cnn;
  Result.CommandText.Text := sql;
end;


{$IFNDEF NO_UTABLO }
function VersiyonKontrolu(Modul, Versiyon : String; i:integer; GenotipIni:TIni;GenRegIni : TRegIni; RgstryLC:char) : Integer;
var s, vers, Dizin, Modulexe, eskiad:String;
    f : file;
begin
    // vers := GenotipIni.ReadString('Versiyonlar',Modul,'xx');
     if (vers = 'xx')or (vers < Versiyon) then begin
         if Application.MessageBox(Pchar('Bu yeni bir sürüm. Sisteme kayıt edilsin mi'), 'O N A Y', MB_YESNO)<>IDYES then begin
               VersiyonKontrolu := 1;
               exit;
         end
         else
         //   GenotipIni.WriteString('Versiyonlar', Modul, Versiyon)
     end
     else if vers > Versiyon then begin
         if (i = 1)and(Application.MessageBox(Pchar('Yeni '+Modul+' sürümü bulundu, yüklensin mi'), 'O N A Y', MB_YESNO)<>IDYES) then begin
               VersiyonKontrolu := 1;
               exit;
         end;
     //    Dizin := GenotipIni.ReadString('Versiyonlar', 'YeniVersDizini', '---');
         if Modul = 'Kayıt Kabul' then
            Modulexe := 'KayitKabul.exe'
         else
            Modulexe := Modul+'.exe';

         while not FileExists(Dizin+Modulexe) do begin
            if not MesajStrAl('Dizinde '+Modulexe+' bulunamadı..', 'Yeni sürüm için server kaynak dizini girin (Ör:\\server\prg\)', 'E', nil, Dizin, '', 'E', nil, Dizin) then begin
               VersiyonKontrolu := 1;
               exit;
            end;
      //      GenotipIni.WriteString('Versiyonlar', 'YeniVersDizini', Dizin);
            //if Modul = 'Kayıt Kabul' then
            //   Dizin := Dizin+'KayitKabul.exe'
            //else
            //   Dizin := Dizin+Modul+'.exe';
         end;
         AssignFile(f, Application.EXEName);
         //Exename := ExtractFileName(Application.EXEName);
         s := STRingreplace(Versiyon, '.', '-', [rfReplaceAll]);
         eskiad := copy(Application.EXEName,1,length(Application.EXEName)-4)+s+'.exe';
         if FileExists(eskiad) then
            DeleteFile(PChar(eskiad));
         rename(f, eskiad);

         GetDir(0, s);
         s := s+'\'+ExtractFileName(Application.EXEName);
         copyfile(PChar(Dizin+Modulexe),PChar(s), true);
         sleep(5000);
         if not FileExists(s)then begin
           //Kopyalanamazsa eski haline geri getirilir..
           AssignFile(f, s);
           rename(f, s);
           Showmessage(vers+' sürümü bilgisayarınıza yüklenemedi..');
           VersiyonKontrolu:= 1;
         end else begin
           Showmessage(vers+' sürümü bilgisayarınıza yüklendi, programa tekrar girin..');
           VersiyonKontrolu:= 9;
         end;
     end;
end;
{$ENDIF}



procedure StringdenIsarete(ADegerListesi: string;
  AKontrol: TCheckListBox; AKaynakTablo: TDataSet; AKaynakAlan: string);
var
  i : Integer;
  liste : TStringList;
begin
  AKaynakTablo.First;
  i := 0;
  liste := StringToStringList(ADegerListesi);
  try
    if (liste.Count = 0) then begin
      { Hiç seçili değer yok öyleyse tüm checkleri kaldırıyoruz }
      for i := 0 to AKontrol.Items.Count - 1 do
        AKontrol.Checked[i] := False;
    end;
    with AKaynakTablo do begin
      while not Eof do begin
        if (liste.IndexOf(FieldByName(AKaynakAlan).AsString) > -1) then
          AKontrol.Checked[i] := True;
        i := i + 1;
        Next;
      end;
    end;
  finally
    liste.Free;
  end;
end;


function GetCurrentUserName :string;
const
  cnMaxUserNameLen = 254;
var
  sUserName :string;
  dwUserNameLen :DWord;
begin
  dwUserNameLen := cnMaxUserNameLen - 1;
  SetLength(sUserName, cnMaxUserNameLen);
  GetUserName(
    PChar(sUserName),
    dwUserNameLen);
  SetLength(sUserName, dwUserNameLen);
  Result := sUserName;
end;

function GetCurrentSessionID: Cardinal;
// Getting the session id from the current process
type
  TProcessIdToSessionId = function(dwProcessId: DWORD; pSessionId: DWORD): BOOL; stdcall;
var
  ProcessIdToSessionId: TProcessIdToSessionId;
  hWTSapi32dll: THandle;
  Lib : THandle;
  pSessionId : DWord;
begin
  Result := 0;
  Lib := GetModuleHandle('kernel32');
  if Lib <> 0 then
  begin
    ProcessIdToSessionId := GetProcAddress(Lib, 'ProcessIdToSessionId');
    if Assigned(ProcessIdToSessionId) then
    begin
      ProcessIdToSessionId(GetCurrentProcessId(), DWORD(@pSessionId));
      Result:= pSessionId;
    end;
  end;
  //ShowMessage('Proces:'+inttostr(GetCurrentProcessId())+' Session:'+inttostr(pSessionId));
end;

function IsarettenStringe(AKontrol: TCheckListBox;
  AKaynakTablo: TDataSet; AKaynakAlan: string): string;
var
  i : Integer;
begin
  AKaynakTablo.First;
  i := 0;
  Result := '';
  with AKaynakTablo do begin
    while not Eof do begin
      if (AKontrol.Checked[i]) then
        Result := Result + AKaynakTablo.FieldByName(AKaynakAlan).AsString + ';';
      i := i + 1;
      Next;
    end;
  end;
end;

function IsNullOrEmpty(AField: TField) : Boolean;
begin
  Result := (AField.AsString = '') OR (AField.IsNull); 
end;

procedure FillStringListFromDataSet(ADestList: TStrings;ASourceDataSet : TDataSet;ASourceField: string);
begin
  ADestList.Clear;
  ASourceDataSet.First;
  with ASourceDataSet do begin
    while not Eof do begin
      ADestList.Add(ASourceDataSet.FieldByName(ASourceField).AsString);
      Next;
    end;
  end;
end;

function StringToStringList(ASource: string;ADelimiter: string = ';'): TStringList;
begin
  Result := TStringList.Create;
  while Length(ASource) > 0 do begin
    Result.Add(GetDelimitedString(ASource,ADelimiter));
  end;
end;


function HimetricToPixels(const P: TPoint): TPoint;
begin
  Result.X := MulDiv(P.X, PixPerInch.X, 2540);
  Result.Y := MulDiv(P.Y, PixPerInch.Y, 2540);
end;


procedure GetOleObjectContentAsImage(AOleObject: IOleObject;AImage: TImage);
var
  ViewObject2: IViewObject2;
  FViewSize : TPoint;
  S: TPoint;
  R: TRect;
  Bitmap : Graphics.TBitmap;
begin
  if (AOleObject = nil) then Exit;
  PixPerInch.X := GetDeviceCaps(GetDC(0), LOGPIXELSX);
  PixPerInch.Y := GetDeviceCaps(GetDC(0), LOGPIXELSY);
//  if Succeeded(AOleObject.QueryInterface(IViewObject2, ViewObject2)) then
//  begin
//    ViewObject2.GetExtent(DVASPECT_CONTENT, -1, nil, FViewSize);
//  end else begin
    AOleObject.GetExtent(DVASPECT_CONTENT,FViewSize);
//  end;
  S := HimetricToPixels(FViewSize);
  R.Left := 0;
  R.Top := 0;
  R.Right := S.X;
  R.Bottom :=S.Y;
  Bitmap := Graphics.TBitmap.Create;
  Bitmap.PixelFormat := pf24bit;
  Bitmap.Width := S.X;
  Bitmap.Height := S.Y;
  OleDraw(AOleObject,DVASPECT_CONTENT,Bitmap.Canvas.Handle,R);
  AImage.Picture.Assign(Bitmap); 
end;

function StreamToHexString(AStream: TStream;ByteCountPerLine: Byte): string;
var
  i : Integer;
  ABuffer: array[0..255] of Byte;
  read : Integer;
  function ConvertToString(ACount: Byte): string;
  var
    i : Byte;
  begin
    Result := '';
    for i := 0 to ACount - 1 do begin
      Result := Result + IntToHex(ABuffer[i],2);
    end;
    if Result <> '' then
      Result := Result + #13#10;
  end;
begin
  Result := '';
  repeat
    read := AStream.Read(ABuffer,ByteCountPerLine);
    if read > 0 then begin
      Result := Result + ConvertToString(read);
    end;
  until read = 0;
end;

procedure HexStringToStream(AHexString: string;ADestination: TStream);
var
  i : Integer;
  s : string;
  w : byte;
begin
  // Dizede istenmeyen karakterleri siliyoruz
  AHexString := Trim(AHexString);
  AHexString := StringReplace(AHexString,#13,'',[rfReplaceAll]);
  AHexString := StringReplace(AHexString,#10,'',[rfReplaceAll]);
  // dize temizleme tamam
  // şimdi tek tek çevirip stream e yazıyoruz
  for i := 0 to (Length(AHexString) div 2) - 1 do begin
    // hex olarak dizeye atıyoruz örn $55
    s := '$' + Copy(AHexString,(i * 2) + 1, 2);
    // byte'a dönüştürüp w ye atıyoruz
    w := StrToInt(s);
    // stream'a yazıyoruz
    ADestination.Write(w,1);
  end;
end;


function GetOleClassDisplayName(const AClassName: string): string;
var
  reg : TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if (reg.OpenKey(AClassName,False)) then begin
      Result := reg.ReadString('');
      reg.CloseKey;
    end else
      Result := '';
  finally
    reg.Free;
  end;
end;

function RemoveMenuShortCutSign(S: string): string;
begin
  Result := StringReplace(S,'&','',[rfReplaceAll]);
end;

function TrimStringWithEllipsis(ASource: string;ALength: Integer): string;
begin
  if (Length(ASource) > ALength) then
    Result := Copy(ASource,1,ALength - 3) + '...'
  else
    Result := ASource;
end;



procedure DeleteFiles(Path: string;Mask: string);
var
  SR: TSearchRec;
begin
  if (FindFirst(IncludeTrailingBackslash(Path) + Mask,faArchive,SR) = 0) then
    begin
      repeat
        if ((SR.Attr and faArchive) = faArchive) then
          begin
            SysUtils.DeleteFile(IncludeTrailingBackslash(Path) +
              SR.Name);
          end;
      until SysUtils.FindNext(SR) <> 0;
      SysUtils.FindClose(SR);
    end;
end;

function VersionToInteger(AVersion: string): Integer;
var
  parts : TStringList;
  i     : Integer;
begin
  Result := 0;
  parts := TStringList.Create;
  try
    parts.Delimiter := '.';
    parts.DelimitedText := AVersion;
    Result := StrToIntDef(parts[0],1) * 4000;
    Result := Result + StrToIntDef(parts[1],1) * 400;
    Result := Result + StrToIntDef(parts[2],0) + StrToIntDef(parts[3],0);
  finally
    parts.Free;
  end;
end;

function FindVariables(AEditor: TRichEdit): string;
var
  APos : Integer;
  ASpacePos : Integer;
  ACurPos   : Integer;
  AList     : TStringList;
begin
  AList := TStringList.Create;
  AList.Delimiter := '.';
  try
    ACurPos := 0;
    while FindParam(AEditor,'@@',ACurPos,APos) > -1 do begin
      ASpacePos := AEditor.FindText(#13#10,APos,MaxInt,[]);
      if (ASpacePos = -1) then begin
        ASpacePos := AEditor.FindText(' ',APos,MaxInt,[]);
        if (ASpacePos = -1) then begin
          ASpacePos := AEditor.FindText(#9,APos,MaxInt,[]);
          if (ASpacePos = -1) then Continue;
        end;
      end;
      AEditor.SelStart := APos + 2; // skip @@
      AEditor.SelLength := ( ASpacePos - APos ) - 2;
      ACurPos := ASpacePos;
      AList.DelimitedText := AEditor.SelText;
      for APos := 0 to AList.Count - 1 do
        ShowMessage(AList[APos]);
    end;
  finally
    AList.Free;
  end;
end;

function FindParam(AEditor: TRichEdit;
  AString: string;var APos: integer): Integer;overload;
begin
  APos := AEditor.FindText(AString,0,MaxInt,[]);
  Result := APos;
end;

function FindParam_Jv(AEditor: TJvCustomRichEdit;
  AString: string;var APos: integer): Integer;overload;
begin
  APos := AEditor.FindText(AString,0,MaxInt,[]);
  Result := APos;
end;

function FindParam(AEditor: TRichEdit;
  AString: string;AStartPos: Integer;var APos: integer): Integer;overload;
begin
  APos := AEditor.FindText(AString,AStartPos,MaxInt,[]);
  Result := APos;
end;

procedure InternalReplace(AEditor: TRichEdit;
  AParam: string;AValue: string);
var
  APos : integer;
  AName: string;
begin
  AName := '$' + AParam + '$';
  while (FindParam(AEditor,AName,APos) > -1) do
    begin
      AEditor.SelStart := APos;
      AEditor.SelLength := Length(AName);
      AEditor.SelText := AValue;
    end;
end;

function ControlToString(AComponent : TComponent) : string;
begin
  Result := '';
  if (not Assigned(AComponent)) then Exit;
  if (AComponent is TEdit) then
    Result := TEdit(AComponent).Text
  else
    if (AComponent is TComboBox) then
      Result := TComboBox(AComponent).Text
    else
      if (AComponent is TMemo) then
        Result := TMemo(AComponent).Text
      else
        if (AComponent is TGroupBox) then
          Result := TGroupBox(AComponent).Caption
        else
          if (AComponent is TRadioButton) then
            Result := TRadioButton(AComponent).Caption
          else
            if (AComponent is TCheckBox) then
              Result := TCheckBox(AComponent).Caption;
end;



function DataExists(cnn: TADOConnection;ASQL: string;AParams: array of string;AParamValues: array of Variant): Boolean;
var
  tmp : TADOQuery;
begin
  Result := False;
  tmp := _query_exec(cnn,ASQL,AParams,AParamValues);
  try
    tmp.Open;
    Result := not tmp.IsEmpty;
  finally
    tmp.Free;
  end;
end;

function GetTableRecordCount(cnn: TADOConnection;ATableName: string): Integer;
begin
  Result := 0;
  with _query_exec(cnn,'SELECT COUNT(*) FROM ' + ATableName,[],[]) do
  try
    Open;
    Result := Fields[0].AsInteger;
    Close;
  finally
    Free;
  end;
end;

function RemoveBlock(AEditor: TCustomRichEdit;ABlockName: string): Boolean;
var
  APos : Integer;
  ALastPos : Integer;
begin
  Result := False;
  APos := AEditor.FindText('>>' + ABlockName, 0, maxint, []);
  if (APos >= 0) then
    begin
      ALastPos := AEditor.FindText('<<' + ABlockName,APos + Length(ABlockName) + 2,MaxInt,[]);
      if (ALastPos >= 0) then
        begin
          AEditor.SelStart := APos;
          AEditor.SelLength := (ALastPos - APos) + Length(ABlockName) + 2;
          AEditor.SelText := '';
          Result := True;
          Exit;
        end;
    end;
end;

procedure TrimSpaces(ACtrl : TRichEdit);
var
  i : integer;
  a : Boolean;
begin
  a := True;
  for i := ACtrl.Lines.Count - 1 downto 0 do
    if (Trim(ACtrl.Lines[i]) = '') and A then
      ACtrl.Lines.Delete(i)
    else
      if ((Trim(ACtrl.Lines[i]) <> '') and A) then
        Break;
end;

procedure LockControl(c: TWinControl; bLock: Boolean);
begin
if (c = nil) or (c.Handle = 0) then Exit;
if bLock then
SendMessage(c.Handle, WM_SETREDRAW, 0, 0)
else
begin
SendMessage(c.Handle, WM_SETREDRAW, 1, 0);
RedrawWindow(c.Handle, nil, 0,
RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
end;
end;

function TurkishUpperCaseChar(st: char): Char;
begin
  case st of
    'ç': Result := 'Ç';
    'ö': Result := 'Ö';
    'ş': Result := 'Ş';
    'i': Result := 'İ';
    'ı': Result := 'I';
    'ğ': Result := 'Ğ';
    'ü': Result := 'Ü';
  else
    Result := Upcase(st);
  end;
end;

function TurkishUppercaseString(st: string): string;
var
  i : Integer;
begin
  Result := '';
  for i := 1 to Length(st) do
    Result := Result + TurkishUpperCaseChar(st[i]);
end;

function TurkishToEnglishCharset(st :string) :string;
var
  xi : Integer;
  ch, ch2 : Char;
begin
  st := Trim(st);
  FillChar(Result, Sizeof(Result), 0);
  for xi := 1 to length(st) do
    begin
      ch := st[xi];
      case ch of
        'Ç' :ch2 := 'C';
        'Ğ' :ch2 := 'Ğ';
        'İ' :ch2 := 'I';
        'Ö' :ch2 := 'O';
        'Ş' :ch2 := 'S';
        'Ü' :ch2 := 'U';
        ' ' :ch2 := '_';
        'ç' :ch2 := 'c';
        'ğ' :ch2 := 'g';
        'ı' :ch2 := 'i';
        'ö' :ch2 := 'o';
        'ş' :ch2 := 's';
        'ü' :ch2 := 'u';
      else
        ch2 := ch;
      end;
      Result := Result + ch2;
    end;
end;

function FindMaximumOfColumn(cnn: TADOConnection;TableName,ColumnName,WhereClause: string): Integer;
var
  qry : TADOQuery;
begin
  qry := _query_exec(cnn,Format(
    'SELECT MAX(%s) FROM %s %s',[ColumnName,TableName,WhereClause]),[],[]);
  try
    qry.Open;
    if (not qry.IsEmpty) and (not qry.Fields[0].IsNull) then
      Result := qry.Fields[0].AsInteger
    else
      Result := 0;
  finally
    qry.Free;
  end;
end;

function GetGenotipConnectionString: String;
var
  reg : TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey('Software\GENOTIP',False) then
      begin
        Result := reg.ReadString('ConnectionString');
        reg.CloseKey;
      end
    else
      Result := '';
  finally
    reg.Free;
  end;
end;


function ComponentToString(Component: TComponent): string;

var
  BinStream:TMemoryStream;
  StrStream: TStringStream;
  s: string;
begin
  BinStream := TMemoryStream.Create;
  try
    StrStream := TStringStream.Create(s);
    try
      BinStream.WriteComponent(Component);
      BinStream.Seek(0, soFromBeginning);
      ObjectBinaryToText(BinStream, StrStream);
      StrStream.Seek(0, soFromBeginning);
      Result:= StrStream.DataString;
    finally
      StrStream.Free;

    end;
  finally
    BinStream.Free
  end;
end;

function StringToComponent(Value: string): TComponent;
var
  StrStream:TStringStream;
  BinStream: TMemoryStream;
begin
  StrStream := TStringStream.Create(Value);
  try
    BinStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, BinStream);
      BinStream.Seek(0, soFromBeginning);
      Result := BinStream.ReadComponent(nil);

    finally
      BinStream.Free;
    end;
  finally
    StrStream.Free;
  end;
end;


function TCKimlikDogrula(TCNo: Int64): boolean;
type
  TinyInt = smallint;
var
  ATCNO: Int64;
  BTCNO: Int64;
  C1: Tinyint;
  C2: Tinyint;
  C3: Tinyint;
  C4: Tinyint;
  C5: Tinyint;
  C6: Tinyint;
  C7: Tinyint;
  C8: Tinyint;
  C9: Tinyint;
  Q1: Integer;
  Q2: Integer;
begin
  ATCNO := TcNo div 100;
  BTCNO := TcNo div 100;
  if (Length(IntToStr(TcNo)) = 11) then
    begin
      C1 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C2 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C3 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C4 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C5 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C6 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C7 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C8 := ATCNO mod 10; ATCNO := ATCNO div 10;
      C9 := ATCNO mod 10; ATCNO := ATCNO div 10;
      Q1 := ((10-((((C1+C3+C5+C7+C9)*3)+(C2+C4+C6+C8))  mod  10)) mod 10);
      Q2 := ((10-(((((C2+C4+C6+C8)+Q1)*3)+(C1+C3+C5+C7+C9)) mod 10)) mod 10);
      if ((BTCNO * 100) + (Q1 * 10) + Q2 = TcNo) then
        Result := True
      else
        Result := False;
    end
  else
    Result := False;
end;


function __FindComponent(AName: string;ARoot: TComponent): TComponent;
var
  i : integer;
begin
  Result := nil;
  if (not Assigned(ARoot)) then Exit;
  if (ARoot.ComponentCount > 0) then
    begin
      for i := 0 to ARoot.ComponentCount - 1 do
        begin
          if (ARoot.Components[i].ComponentCount > 0) then
            begin
              Result := __FindComponent(AName,ARoot.Components[i]);
              if (Assigned(Result)) then Exit;
            end
          else
            if (ARoot.Components[i].Name = AName) then
              begin
                Result := ARoot.Components[i];
                Exit
              end;
        end;
    end;
  if (ARoot.Name = AName) then
    begin
      Result := ARoot;
      Exit;
    end;
end;


procedure EnableDisableSubControls(Control : TWinControl;Enabled: Boolean);
var
  i : integer;
begin
  Control.Enabled := Enabled;
  for i := 0 to Control.ControlCount - 1 do
    Control.Controls[i].Enabled := Enabled;
  Control.Repaint;
end;


function MinInt(A,B: Integer): Integer;
begin
  if (A < B) then
    Result := A
  else
    Result := B;
end;


function GetDelimitedString(var s : string): string;overload;
begin
  if (Pos(';',s) > 0) then
    begin
      Result := Copy(s,1,Pos(';',s) - 1);
      Delete(s,1,Pos(';',s));
    end
  else                          
    begin
      Result := s;
      s := '';
    end;
end;

function GetDelimitedString(var s : string;delimiter : string): string;overload;
begin
  if (Pos(delimiter,s) > 0) then
    begin
      Result := Copy(s,1,Pos(delimiter,s) - 1);
      Delete(s,1,Pos(delimiter,s));
    end
  else
    begin
      Result := s;
      s := '';
    end;
end;

function GetDelimitedStringEx(var s : string;delimiter : string): string;
begin
  if (Pos(delimiter,s) > 0) then
    begin
      Result := Copy(s,1,Pos(delimiter,s) - 1);
      Delete(s,1,Pos(delimiter,s));
    end
  else
    begin
      Result := s;
      s := '';
    end;
end;

procedure FormatDuzenle(prop:TcxCurrencyEditProperties;Dig:Integer);
var s : string;
    i : SmallInt;
begin
  prop.DecimalPlaces := Dig;
  s := '';
  for i := 1 to Dig do
    s := s + '0';
  prop.DisplayFormat := ',0.' + s + ';-,0.' + s;
  prop.EditFormat := ',0.' + s + ';-,0.' + s;
end;

function LeadingZero(value: Integer;lz: byte): string;
var
  i: Integer;
  j: Integer;
begin
  Result := IntToStr(value);
  j := Length(Result);
  for i := 1 to lz - j do
    Result := '0' + Result;
end;
function IIf(condition: Boolean;IfTrue: string;IfFalse: string): string;
begin
  if (condition) then
    Result := IfTrue
  else
    Result := IfFalse;
end;
 
function Select(index: Integer;values: array of string): string;
begin
  if ((index >= Low(values)) and (index <= High(values))) then
    Result := values[index]
  else
    Result := '';
end;

function CaseOf(AValue: string;AValues: array of string) : integer;
var
  i : integer;
begin
  Result := -1;
  for i := Low(AValues) to High(AValues) do
    if (AValue = AValues[i]) then
      begin
        Result := i;
        Exit;
      end;
end;

function SubString(AValue: string;StartIndex: Integer;Count : integer = 0): string;
begin
  (*
     Senaryo 1:
       AValue = Merhaba dünya
       StartIndex = 4
       Count = 0

       Değerler
         Length(AValue) = 13
         Length(AValue) - StartIndex = 9
         alınması gereken karakter sayısı = 10
  *)  
  if (Count > 0) then
    Result := Copy(AValue,StartIndex,Count)
  else
    Result := Copy(AValue,StartIndex,(Length(AValue) - StartIndex) + 1);
end;

function _Default(str,defaultValue : string): string;
begin
  Result := IIf(Length(str) = 0,defaultValue,str);
end;


//function RTFtoBitmap(myRTF: TRichEdit; GiveSpaceForBorder: Integer): TBitmap;
//
//  // using myRTF parameter with your TRichEdit control name,
//  // default name "RichEdit1".
//  // For GiveSpaceForBorder parameter, sometimes you need to draw
//  // the RichEdit control with rectangle colorfull border, so you need
//  // to give space for it.
//var
//  myRect: TRect;
//  temp: TBitmap;
//begin
//  temp := TBitmap.Create;
//
//  myRect := myRTF.ClientRect;
//  // if you are using PRF_NONCLIENT parameter in myRTF.perform command
//  // using this statement
//  // myRect := Rect(0,0,MyRTF.Width,MyRTF.Height);
//
//  temp.Width  := myRect.Right;
//  temp.Height := myRect.Bottom;
//  with temp.Canvas do
//  begin
//    Lock;
//    try
//      myRTF.Perform(WM_PRINT, Handle, PRF_CLIENT);
//      //you can trying to change PRF_CLIENT with
//      //PRF_CHILDREN or PRF_CLIENT or PRF_NONCLIENT or PRF_ERASEBKGND
//      //or combine them. See what happen...
//    finally
//      Unlock
//    end;
//  end;
//  Result := TBitmap.Create;
//  Result := CreateEmptyBmp(clWhite,
//    temp.Width + GiveSpaceForBorder * 2,
//    temp.Height + GiveSpaceForBorder * 2);
//  Result.Canvas.Lock;
//  Result.Canvas.Draw(GiveSpaceForBorder, GiveSpaceForBorder, temp);
//  Result.Canvas.Unlock;
//  temp.Free;
//end;

function GetRTFColor(Color : TColor): string;
begin
  FmtStr( Result, '\red%d\green%d\blue%d;', [ GetRValue( Color ), GetGValue( Color ), GetBValue( Color ) ] );
end;

Function GetRTFFont( Index: Integer; Font: TFont ): String;
Var
  DC: HDC;
  TxtMetrics: TTextMetric;
  RTFFont: HFont;
  TempStr: String;
Begin
  Result := '{\f' + IntToStr( Index ) + '\';

  DC := GetDC( 0 );
  RTFFont := SelectObject( DC, Font.Handle );
  GetTextMetrics( DC, TxtMetrics );
  SelectObject( DC, RTFFont );
  ReleaseDC( 0, DC );

  TempStr := 'froman'; // *** Roman Style ***

  Case ( ( ( TxtMetrics.tmPitchAndFamily ) Shr 4 ) Shl 4 ) Of

    FF_DECORATIVE: TempStr := 'fdecorative';
    FF_DONTCARE: TempStr := 'fdontcare';
    FF_MODERN: TempStr := 'fmodern';
    FF_SCRIPT: TempStr := 'fscript';
    FF_SWISS: TempStr := 'fswiss';

  End;

  Result := Result + TempStr + '\';

  TempStr := 'fcharset1'; // *** DEFAULT_CHARSET ***

  Case TxtMetrics.tmCharSet Of

    ANSI_CHARSET: TempStr := 'fcharset0';
    SYMBOL_CHARSET: TempStr := 'fcharset2';
    SHIFTJIS_CHARSET: TempStr := 'fcharset128';
    OEM_CHARSET: TempStr := 'fcharset255';

  End;

  Result := Result + TempStr + ' ' + Font.Name + ';}';
End;

Function GetRTFFontInfo( Font: TFont ): String;
Begin
  Result := Format( '\fs%d', [ Font.Size * 2 ] );
  If fsBold In Font.Style Then Result := Result + '\b';
  If fsItalic In Font.Style Then Result := Result + '\c';
  If fsUnderline In Font.Style Then Result := Result + '\ul';
  If fsStrikeOut In Font.Style Then Result := Result + '\strike';
End;

//function ConvertTurkishToRtf(S : string): string;
//var
//  i : integer;
//begin
//  Result := S;Exit;
//  for i := 1 to Length(s) do
//    case s[i] of
//      'ö': Result := Result + '\''f6';
//      'ç': Result := Result + '\''e7';
//      'ş': Result := Result + '\''fe';
//      'ı': Result := Result + '\''fd';
//      'ğ': Result := Result + '\''f0';
//      'ü': Result := Result + '\''fc';
//      'Ö': Result := Result + '\''d6';
//      'Ç': Result := Result + '\''c7';
//      'Ş': Result := Result + '\''de';
//      'İ': Result := Result + '\''dd';
//      'Ğ': Result := Result + '\''d0';
//      'Ü': Result := Result + '\''dc';
//    else
//      Result := Result + s[i];
//    end;
//end;

function GetStringGridCells(grid : TStringGrid;RowNumber: Integer): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to grid.ColCount - 1 do
    begin
      Result := Result + Format( '%s%s\cell ', [ '', grid.Cells[i,RowNumber]]);
    end;
end;



function GetDBGridCells(grid: TDBGrid;ColumnHeader: Boolean;ExtraFields: array of string): string;
var
  i: integer;
  DataSet : TDataSet;
  s       : string;
begin
  Result := '';
  DataSet := grid.DataSource.DataSet;
  for i := 0 to grid.Columns.Count - 1 do
    begin
      if (grid.Columns[i].Visible) then
        begin
          if (ColumnHeader) then
            begin
              Result := Result + Format( '%s%s\cell ', [ '',
                grid.Columns.Items[i].Title.Caption]);
            end
          else
            begin
              Result := Result + Format( '%s%s\cell ', [ '',
                grid.Columns.Items[i].Field.AsString]);
            end;
        end;
    end;
  for i := 0 to Length(ExtraFields) - 1 do
    begin
      s := ExtraFields[i];
      if (ColumnHeader) then
        begin
          Result := Result + Format( '%s%s\cell ', [ '',
            GetDelimitedString(S)]);
        end
      else
        begin
          GetDelimitedString(S);
          Result := Result + Format( '%s%s\cell ', [ '',
            DataSet.FieldByName(GetDelimitedString(S)).AsString]);
        end;
    end;                                                       
end;

function DbGridToRTF(Title,ABlockName: string;grid : TDBGrid;ExtraFields: array of string): string;
  function GetVisibleColumnCount: integer;
  var
    i : Integer;
  begin
    Result := 0;
    for i := 0 to grid.Columns.Count - 1 do
      if (grid.Columns[i].Visible) then
        Result := Result + 1;
  end;
var
  ColHeader : String;
  i         : integer;
  x         : integer;
  temp      : integer;
  AFont     : TFont;
  blockFont : TFont;
begin
            // *** Standard Headers ***
  Result := Result + '{\rtf1\ansi\ansicpg1254\deff0\deflang1055\deff0\deftab720'#13#10 ;

           // *** Font Table ***
  AFont := TFont.Create;
  blockFont := TFont.Create;
  try
    AFont.Assign(grid.Font);
    AFont.Name := 'Times New Roman';
    AFont.Size := 12;
    Afont.Style := [fsBold];

    blockFont.Name := 'Tahoma';
    blockFont.Color := clWhite;
    blockFont.Size := 2;

    Result := Result + '{\fonttbl' ;
    Result := Result + GetRTFFont( 0, grid.Font ) ;
    Result := Result + GetRTFFont( 1, grid.Font ) ;
    Result := Result + GetRTFFont( 2, grid.Font ) ;
    Result := Result + GetRTFFont( 3, AFont );
    Result := Result + GetRTFFont( 4, blockFont ) + '}'#13#10;

             // *** Color Table ***

    Result := Result + '{\colortbl' ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clSilver );
    Result := Result + GetRTFColor( clNavy ) + '}'#13#10 ;

    Result := Result + Format( '\margl%d\margr%d\margt%d\margb%d', [ 461, 562, 101,101 ] ) ;

    if (Length(ABlockName) > 0) then
      Result := Result + Format( '\pard\plain\f4%s\cf3 %s'#13#10, [ GetRTFFontInfo( blockFont ),
         '>>' + ABlockName + '\par' ]);

    // Başlık Bilgisi
    if (Length(Title) > 0) then
      Result := Result + Format( '\par \par \pard\plain\f3%s\cf6 %s'#13#10, [ GetRTFFontInfo( AFont ),
         '             -------  '+Title+'  -------\par' ] );
    Result := Result + '\par \pard\plain\cgrid'#13#10 ;
    Result := Result + '{\stylesheet{\nowidctlpar\widctlpar\adjustright \fs20\cgrid \snext0 Normal;}'#13#10 ;
    Result := Result + '{\*\cs10 \additive Default Paragraph Font;}}'#13#10 ;
    Result := Result + '{\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang{\pntxta.}}'#13#10 ;
    Result := Result + '{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang{\pntxta .}}'#13#10 ;
    Result := Result + '{\*\pnseclvl3\pndec\pnstart1' + '\pnindent720\pnhang{\pntxta.}}'#13#10 ;
    Result := Result + '{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}'#13#10 ;
    Result := Result + '{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}'#13#10 ;
    ColHeader :=  GetDBGridCells( grid, True, ExtraFields );
    Result := Result + '\trowd\trgaph108\trrh260\trleft0';
    temp := 0;
    for i := 0 to grid.Columns.Count - 1 do
      begin
        if (grid.Columns[i].Visible) then begin
          Result := Result + '\clvertalc';
          Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
          Result := Result + ' \clcbpat5' ;
          Temp := Temp + grid.Columns[i].Width + 8;
          Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
            + 108.0));
        end;
      end;
    for i := 0 to Length(ExtraFields) - 1 do
      begin
        Result := Result + '\clvertalc';
        Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
        Result := Result + ' \clcbpat5' ;
        Temp := Temp + 101;
        Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
          + 108.0));
      end;

    Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl' ;
    grid.Font.Style := [fsBold];
    Result := Result + Format( ' {\f1%s\cf1\cgrid0 ', [ GetRTFFontInfo( grid.Font ) ] ) ;
    grid.Font.Style := [];
    Result := Result + ColHeader;
    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    grid.DataSource.DataSet.First;

    while not grid.DataSource.DataSet.Eof do
      begin
        Result := Result + '\trowd\trgaph108\trrh260\trleft0' ;
        Temp := 0;
        For X := 0 To grid.Columns.Count - 1 Do
        Begin
          if (grid.Columns[X].Visible) then begin
            Result := Result + '\clvertalc' ;
            Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
            Result := Result + ' \clcbpat4' ;
            Temp := Temp + grid.Columns[X].Width + 8;
            Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
              + 108.0));
          end;
        End;
        for i := 0 to Length(ExtraFields) - 1 do
          begin
            Result := Result + '\clvertalc';
            Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
            Result := Result + ' \clcbpat4' ;
            Temp := Temp + 101;
            Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
              + 108.0));
          end;
        Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl\adjustright' ;
        Result := Result + Format( ' {\f2%s\cf2\cgrid0 ', [ GetRTFFontInfo( grid.Font ) ] );
        Result := Result + GetDBGridCells(grid, False, ExtraFields);
        Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
        grid.DataSource.DataSet.Next;
      end;
//    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    Result := Result + '\pard\nowidctlpar\widctlpar\adjustright {'#13#10;
    if (Length(ABlockName) > 0) then begin
      Result := Result + Format( '\pard\plain\f4%s\cf3 %s'#13#10, [ GetRTFFontInfo( blockFont ),
         '<<'+ ABlockName + '\par' ]);
      Result := Result + Format( '\pard\plain\f3%s\cf0 %s'#13#10, [ GetRTFFontInfo( AFont ),
         '\par' ]);
    end;
    Result := Result + '}}';
  finally
    AFont.Free;
  end;
end;

function GetDbTableCells(ATable: TDataset;ColumnHeader: Boolean;Fields: array of string): string;
var
  i       : integer;
  s       : string;
begin
  Result := '';
  for i := 0 to Length(Fields) - 1 do
    begin
      s := Fields[i];
      if (ColumnHeader) then
        begin
          Result := Result + Format( '%s%s\cell ', [ '',
            GetDelimitedString(S)]);
        end
      else
        begin
          GetDelimitedString(S);
          Result := Result + Format( '%s%s\cell ', [ '',
            ATable.FieldByName(S).AsString]);
        end;
    end;
end;


function DbTableToRtf(ATitle,ABlockName: string;ATable: TDataset;Fields: array of string;
  ColumnWidths: array of integer): string;
var
  ColHeader : String;
  i         : integer;
  x         : integer;
  temp      : integer;
  AFont     : TFont;
  gridFont  : TFont;
  blockFont : TFont;
begin
            // *** Standard Headers ***
  Result := Result + '{\rtf1\ansi\ansicpg1254\deff0\deflang1055\deff0\deftab720'#13#10 ;

           // *** Font Table ***
  AFont := TFont.Create;
  gridFont := TFont.Create;
  blockFont := TFont.Create;
  try
    AFont.Name := 'Times New Roman';
    AFont.Size := 12;
    Afont.Style := [fsBold];

    blockFont.Name := 'Tahoma';
    blockFont.Color := clWhite;
    blockFont.Size := 2;

    gridFont.Name := 'Tahoma';
    gridFont.Size := 10;

    Result := Result + '{\fonttbl' ;
    Result := Result + GetRTFFont( 0, gridFont ) ;
    Result := Result + GetRTFFont( 1, gridFont ) ;
    Result := Result + GetRTFFont( 2, gridFont ) ;
    Result := Result + GetRTFFont( 3, AFont ) ;
    Result := Result + GetRTFFont( 4, blockFont ) + '}'#13#10 ;

             // *** Color Table ***

    Result := Result + '{\colortbl' ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clSilver );
    Result := Result + GetRTFColor( clNavy ) + '}'#13#10 ;

    Result := Result + Format( '\margl%d\margr%d\margt%d\margb%d', [ 461, 562, 101,101 ] ) ;

    if (Length(ABlockName) > 0) then
      Result := Result + Format( '\pard\plain\f4%s\cf3 %s'#13#10, [ GetRTFFontInfo( blockFont ),
         '>>' + ABlockName + '\par' ]);
    // Başlık Bilgisi
    if (Length(ATitle) > 0) then
      Result := Result + Format( '\pard\plain\f3%s\cf6 %s'#13#10, [ GetRTFFontInfo( AFont ),
         '             -------  ' + ATitle + '  -------\par' ] );
    Result := Result + '\par \pard\plain\cgrid'#13#10 ;
    Result := Result + '{\stylesheet{\nowidctlpar\widctlpar\adjustright \fs20\cgrid \snext0 Normal;}'#13#10 ;
    Result := Result + '{\*\cs10 \additive Default Paragraph Font;}}'#13#10 ;
    Result := Result + '{\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang{\pntxta.}}'#13#10 ;
    Result := Result + '{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang{\pntxta .}}'#13#10 ;
    Result := Result + '{\*\pnseclvl3\pndec\pnstart1' + '\pnindent720\pnhang{\pntxta.}}'#13#10 ;
    Result := Result + '{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}'#13#10 ;
    Result := Result + '{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}'#13#10 ;
    ColHeader :=  GetDBTableCells( ATable,True,Fields );
    Result := Result + '\trowd\trgaph108\trrh260\trleft0';
    temp := 0;
    for i := 0 to Length(Fields) - 1 do
      begin
        Result := Result + '\clvertalc';
        Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
        Result := Result + ' \clcbpat5' ;
        Temp := Temp + ColumnWidths[i] + 8;
        Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
          + 108.0));
      end;
    Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl' ;
    gridFont.Style := [fsBold];
    Result := Result + Format( ' {\f1%s\cf1\cgrid0 ', [ GetRTFFontInfo( gridFont ) ] ) ;
    gridFont.Style := [];
    Result := Result + ColHeader;
    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    ATable.First;
    while not ATable.Eof do
      begin
        Result := Result + '\trowd\trgaph108\trrh260\trleft0' ;
        Temp := 0;
        For X := 0 To Length(Fields) - 1 Do
        Begin
          Result := Result + '\clvertalc' ;
          Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
          Result := Result + ' \clcbpat4' ;
          Temp := Temp + ColumnWidths[X] + 8;
          Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
            + 108.0));
        End;
        Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl\adjustright' ;
        Result := Result + Format( ' {\f2%s\cf2\cgrid0 ', [ GetRTFFontInfo( gridFont ) ] );
        Result := Result + GetDBTableCells(ATable, False, Fields);
        Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
        ATable.Next;
      end;
//    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    Result := Result + '\pard\nowidctlpar\widctlpar\adjustright {'#13#10;
    if (Length(ABlockName) > 0) then begin
      Result := Result + Format( '\pard\plain\f4%s\cf3 %s'#13#10, [ GetRTFFontInfo( blockFont ),
         '<<'+ ABlockName + '\par' ]);
      Result := Result + Format( '\pard\plain\f3%s\cf0 %s'#13#10, [ GetRTFFontInfo( AFont ),
         '\par' ]);
    end;
    Result := Result + '}}';
  finally
    AFont.Free;
    blockFont.Free;
    gridFont.Free;
  end;
end;

function StringGridToRTF(Title: string;grid : TStringGrid): string;
var
  ColHeader : String;
  i         : integer;
  x         : integer;
  AFont     : TFont;
begin
            // *** Standard Headers ***
  Result := Result + '{\rtf1\ansi\deff0\deftab720'#13#10 ;

           // *** Font Table ***
  AFont := TFont.Create;
  try
    AFont.Assign(grid.Font);
    AFont.Name := 'Times New Roman';
    AFont.Size := 12;
    Afont.Style := [fsBold];
    Result := Result + '{\fonttbl' ;
    Result := Result + GetRTFFont( 0, grid.Font ) ;
    Result := Result + GetRTFFont( 1, grid.Font ) ;
    Result := Result + GetRTFFont( 2, grid.Font ) ;
    Result := Result + GetRTFFont( 3, AFont ) + '}'#13#10 ;

             // *** Color Table ***

    Result := Result + '{\colortbl' ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clSilver );
    Result := Result + GetRTFColor( clNavy ) + '}'#13#10 ;

    Result := Result + Format( '\margl%d\margr%d\margt%d\margb%d', [ 461, 562, 101,101 ] ) ;

    // Başlık Bilgisi

    Result := Result + Format( '\par \par \pard\plain\f3%s\cf6 %s'#13#10, [ GetRTFFontInfo( AFont ),
       '             -------  '+Title+'  -------\par' ] );
    Result := Result + '\par \pard\plain\cgrid'#13#10 ;
    Result := Result + '{\stylesheet{\nowidctlpar\widctlpar\adjustright \fs20\cgrid \snext0 Normal;}'#13#10 ;
    Result := Result + '{\*\cs10 \additive Default Paragraph Font;}}'#13#10 ;
    Result := Result + '{\*\pnseclvl1\pnucrm\pnstart1\pnindent720\pnhang{\pntxta.}}'#13#10 ;
    Result := Result + '{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang{\pntxta .}}'#13#10 ;
    Result := Result + '{\*\pnseclvl3\pndec\pnstart1' + '\pnindent720\pnhang{\pntxta.}}'#13#10 ;
    Result := Result + '{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl5\pndec\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}'#13#10 ;
    Result := Result + '{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta)}}'#13#10 ;
    Result := Result + '{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}'#13#10 ;
    ColHeader :=  GetStringGridCells( grid, 0 );
    Result := Result + '\trowd\trgaph108\trrh260\trleft0';
    for i := 0 to grid.ColCount - 1 do
      begin
        Result := Result + '\clvertalc';
        Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
        Result := Result + ' \clcbpat5' ;
        Result := Result + '\cltxlrtb\cellx' + IntToStr( Round( ( ( ( ( i + 1 ) * 100 ) / Screen.Pixelsperinch ) * 1400 ) ) ) ;
      end;
    Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl' ;
    grid.Font.Style := [fsBold];
    Result := Result + Format( ' {\f1%s\cf1\cgrid0 ', [ GetRTFFontInfo( grid.Font ) ] ) ;
    grid.Font.Style := [];
    Result := Result + ColHeader;
    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    for i := 1 to grid.RowCount - 1 do
      begin
        Result := Result + '\trowd\trgaph108\trrh260\trleft0' ;
        For X := 0 To grid.ColCount - 1 Do
        Begin
          Result := Result + '\clvertalc' ;
          Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
          Result := Result + ' \clcbpat4' ;
          Result := Result + '\cltxlrtb\cellx' + IntToStr( Round( ( ( ( ( X + 1 ) * 100 ) / Screen.Pixelsperinch ) * 1400 ) ) );
        End;
        Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl\adjustright' ;
        Result := Result + Format( ' {\f2%s\cf2\cgrid0 ', [ GetRTFFontInfo( grid.Font ) ] );
        Result := Result + GetStringGridCells(grid,i);
      end;
    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    Result := Result + '\pard\nowidctlpar\widctlpar\adjustright {'#13#10;
    //Result := Result + Format( '\par \pard\plain\f0%s\cf0 %s'#13#10, [ GetRTFFontInfo( grid.Font ), 'Footerim tekerleğim' ] );
    Result := Result + '}}';
  finally
    AFont.Free;
  end;
end;


{$IFNDEF NO_UTABLO}
// completely changed by Erhan 26.10.2007
function TarihBul():TDateTime;
var
  tempQuery : TFDQuery;
begin
  tempQuery := TFDQuery.Create(nil);
  try
    tempQuery.Connection := Tablo.FDCnn;
    tempQuery.SQL.Text := 'select GetDate()';
    tempQuery.Open;
    Result := tempQuery.Fields[0].AsDateTime;
  finally
    tempQuery.Free;
  end;
end;
{$ENDIF}      

function _query_exec(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant;
  UseDataSource: TDataSource = nil) : TADOQuery;
var
  i     : Integer;
  fieldName: string;
  field : TField;
begin
  if ((Length(paramNames) > 0)) then
    begin
      if (Length(params) > 0) then begin
        for i := Low(paramNames) to High(paramNames) do
          begin
            if ((VarType(params[i]) in [vtString,vtUnicodeString,vtWideString,vtPChar,vtPWideChar,
              vtChar]) or (VarType(params[i]) = varString) or (VarType(params[i]) = varUString)) then
              sql := StringReplace(sql,paramNames[i],#39 + StringReplace(params[i],#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
            else
              if Pos('*datetime*',paramNames[i]) > 0 then
                sql := StringReplace(sql,StringReplace(paramNames[i],'*datetime*','',[rfReplaceAll]),#39 + FormatDateTime('yyyymmdd hh:nn:ss',params[i]) + #39,[rfReplaceAll])
              else
                sql := StringReplace(sql,paramNames[i],params[i],[rfReplaceAll]);
          end;
      end else if Assigned(UseDataSource) then begin
        for i := Low(paramNames) to High(paramNames) do begin
          { $ işaretini kaldırıyoruz }
          fieldName := SubString(paramNames[i],2);
          { alanı buluyoruz }
          field := UseDataSource.DataSet.FieldByName(fieldName);
          { tipine göre sql içinde yerine koyuyoruz }
          case field.DataType of
            ftString: begin
              sql := StringReplace(sql,paramNames[i],#39 + StringReplace(field.AsString,#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
            end;
            ftDateTime: begin
              sql := StringReplace(sql,paramNames[i],#39 + FormatDateTime('yyyymmdd hh:nn:ss',field.AsDateTime) + #39,[rfReplaceAll])
            end;
            ftBoolean: begin
              sql := StringReplace(sql,paramNames[i],IIf(field.AsBoolean,'1','0'),[rfReplaceAll]);
            end;
          else
            sql := StringReplace(sql,paramNames[i],field.AsString,[rfReplaceAll]);
          end;
        end;       
      end;
    end;
  Result := TADOQuery.Create(nil);
  Result.Connection := cnn; 
  Result.SQL.Text := sql;
end;

function GetFileVersion(FileName: string) : string;
{ Helper function to get the actual file version information }
var
  Info: Pointer;
  InfoSize: DWORD;
  FileInfo: PVSFixedFileInfo;
  FileInfoSize: DWORD;
  Tmp: DWORD;
begin
  // Get the size of the FileVersionInformatioin
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Tmp);
  // If InfoSize = 0, then the file may not exist, or
  // it may not have file version information in it.
  if InfoSize = 0 then begin
    Result := '';
    Exit;
  end;
  // Allocate memory for the file version information
  GetMem(Info, InfoSize);
  try
    // Get the information
    GetFileVersionInfo(PChar(FileName), 0, InfoSize, Info);
    // Query the information for the version
    VerQueryValue(Info, '\', Pointer(FileInfo), FileInfoSize);
    // Now fill in the version information
    Result := IntToStr(FileInfo.dwFileVersionMS shr 16) + '.';
    Result := Result + IntToStr(FileInfo.dwFileVersionMS and $FFFF) + '.';
    Result := Result + IntToStr(FileInfo.dwFileVersionLS shr 16) + '.';
    Result := Result + IntToStr(FileInfo.dwFileVersionLS and $FFFF);
  finally
    FreeMem(Info, FileInfoSize);
  end;
end;

procedure LogaEkle(s :string);
var
  dizin,Dosya :string;
  PktKytYeri :string;
  f :TextFile;
begin
  // PktKytYeri := 'Log';
  // dizin := PktKytYeri + '\';
  Dosya := FormatDateTime('yyyymmdd', now) + '.txt';
  AssignFile(F, dosya);
  {$I-}
  Append(F);
  {$I+}
  if IOResult > 0 then
    Rewrite(f);
  s:= stringreplace ( s,#13,' ',[rfReplaceAll]) ;
  s:= stringreplace ( s,#10,' ',[rfReplaceAll]) ;
  Writeln(f, FormatDateTime('HH:NN:SS.ZZZ', now)+#9+ s + #13+#10);
  CloseFile(f);
end;

function FCurrToStr(Para:Currency):string;
begin
  if Para=0.0 then
     Result := '0.0'
  else begin
     Result := FormatCurr('##########.##', Para);
     Result:=StringReplace(Result,',','.',[rfReplaceAll]);
     if pos('.', Result)=0 then //tamsayı ise sonuna .0  ekleyelim
        Result:=Result+'.0'
  end;

//     Result := StringReplace(FormatCurr('##########'+FormatSettings.Decimalseparator+'##', Para),',','.',[rfReplaceAll]);
//     Result := StringReplace(FormatCurr('##########.##', Para),'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
end;

function FStrToCurrDef(Para:string;Def: Currency):Currency;
begin
     Para:=StringReplace(Para,',',FormatSettings.Decimalseparator,[rfReplaceAll]);
     Para:=StringReplace(Para,'.',FormatSettings.Decimalseparator,[rfReplaceAll]);
     Result := StrToCurrDef(Para, Def);
end;

function FExtToStr(Sayi:Extended;OndalikDigitSayisi:integer=6):string;
var format:string;
begin
  while Length(format)<OndalikDigitSayisi do
    format := format+'#';
  if OndalikDigitSayisi>0 then
    format := '.' + format;
  format := '############0'+format;
  Result := StringReplace(FormatFloat(format,Sayi),',','.',[rfReplaceAll]);
end;

function VeritabaniListesiGetir:TStringlist;
begin
  Tablo.Query3.SQL.Text := ' select distinct DATABASE_NAME=db_name(s_mf.database_id) from sys.master_files s_mf where '+
                      ' s_mf.state = 0 and  has_dbaccess(db_name(s_mf.database_id)) = 1 '+
                      ' and  db_name(s_mf.database_id) not in (''master'',''model'',''msdb'',''Northwind'',''tempdb'')  order by 1' ;
  Tablo.Query3.Open;
  Result:=TStringlist.Create;
  while not Tablo.Query3.Eof do begin
    Result.Add(Tablo.Query3.Fields[0].AsString);
    Tablo.Query3.Next;
  end;
end;

function GetMACAdress: string;
var
  NCB: PNCB;
  Adapter: PAdapterStatus;

  URetCode: PAnsiChar;
  RetCode: Ansichar;
  I: integer;
  Lenum: PlanaEnum;
  _SystemID: string;
  TMPSTR: string;
begin
  Result := '';
  _SystemID := '';
  Getmem(NCB, SizeOf(TNCB));
  Fillchar(NCB^, SizeOf(TNCB), 0);

  Getmem(Lenum, SizeOf(TLanaEnum));
  Fillchar(Lenum^, SizeOf(TLanaEnum), 0);

  Getmem(Adapter, SizeOf(TAdapterStatus));
  Fillchar(Adapter^, SizeOf(TAdapterStatus), 0);

  Lenum.Length := chr(0);
  NCB.ncb_command := chr(NCBENUM);
  NCB.ncb_buffer := Pointer(Lenum);
  NCB.ncb_length := SizeOf(Lenum);
  RetCode := Netbios(NCB);

  i := 0;
  repeat
    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command := chr(NCBRESET);
    Ncb.ncb_lana_num := lenum.lana[I];
    RetCode := Netbios(Ncb);

    Fillchar(NCB^, SizeOf(TNCB), 0);
    Ncb.ncb_command := chr(NCBASTAT);
    Ncb.ncb_lana_num := lenum.lana[I];
    // Must be 16
    Ncb.ncb_callname := '* ';

    Ncb.ncb_buffer := Pointer(Adapter);

    Ncb.ncb_length := SizeOf(TAdapterStatus);
    RetCode := Netbios(Ncb);
    //---- calc _systemId from mac-address[2-5] XOR mac-address[1]...
    if (RetCode = chr(0)) or (RetCode = chr(6)) then
    begin
    _SystemId := IntToHex(Ord(Adapter.adapter_address[0]), 2) + '-' +
    IntToHex(Ord(Adapter.adapter_address[1]), 2) + '-' +
    IntToHex(Ord(Adapter.adapter_address[2]), 2) + '-' +
    IntToHex(Ord(Adapter.adapter_address[3]), 2) + '-' +
    IntToHex(Ord(Adapter.adapter_address[4]), 2) + '-' +
    IntToHex(Ord(Adapter.adapter_address[5]), 2);
    end;
    Inc(i);
  until (I >= Ord(Lenum.Length)) or (_SystemID <> '00-00-00-00-00-00');
  FreeMem(NCB);
  FreeMem(Adapter);
  FreeMem(Lenum);
  GetMacAdress := _SystemID;
end;

function TariheGunEkle(Tarih: TDateTime; Ekleme: SmallInt): SmallInt;
var Gun, i, j, m: SmallInt;
begin
  Gun := Ekleme;
  i := Gun div 5;
//    m := Gun Mod 5;

  j := DayOfWeek(Tarih);
  if (i > 0) and (j >= 3) and (j <= 6) then
    inc(i);

  Gun := Gun + i * 2; //Kaç haftasonu varsa ekliyorum
  j := DayOfWeek(Tarih + Gun);
  if i > 0 then begin //arada haftasonu varsa
    if j = 1 then //pazar
      inc(Gun)
    else if j = 7 then //c.tesi
      inc(Gun, 2)
  end else begin
    if (j = 1) or (j = 7) then
      inc(Gun, 2);
  end;
  TariheGunEkle := Gun;
end;

{$IFNDEF NO_UTABLO }
function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TFDConnection; Degis: Boolean): string;
var cst, DB_Pass, Ser_Name, DB_Name, s2: string;
   i: smallint;
   e: eoleexception;
   tut: Boolean;
   function IsConnectionStringValid(const AConnStr: string): Boolean;
   begin
     Result :=
       ((Pos('Server=', AConnStr) > 0) or (Pos('Data Source=', AConnStr) > 0)) and
       ((Pos('Database=', AConnStr) > 0) or (Pos('Initial Catalog=', AConnStr) > 0));
   end;

   function TryDecodeConnectionString(var AConnStr: string): Boolean;
   var
     LDecoded: string;
   begin
     Result := False;
     LDecoded := Trim(AConnStr);
     if LDecoded = '' then
       Exit;

     if IsConnectionStringValid(LDecoded) then
     begin
       AConnStr := LDecoded;
       Exit(True);
     end;

     try
       LDecoded := DeSifre(LDecoded);
     except
       Exit(False);
     end;

     if not IsConnectionStringValid(LDecoded) then
     begin
       try
         LDecoded := DeSifre(LDecoded);
       except
         Exit(False);
       end;
     end;

     Result := IsConnectionStringValid(LDecoded);
     if Result then
       AConnStr := LDecoded;
   end;

   procedure ResetStoredConnectionString;
   begin
     try
       if cst <> '' then
         GenRegIni.RegWriteString('', 'ConnectionString_Bozuk', cst, 'C');
       GenRegIni.RegWriteString('', 'ConnectionString', '', 'C');
     except
       // Registry temizlenemese bile yeniden bilgi giris ekranina duselim.
     end;
   end;
   function GetConnectionValue(const AConnStr, AKey1: string; const AKey2: string = ''): string;
   var
     LItems: TStringList;
     I: Integer;
     LName: string;
   begin
     Result :=  '';
     LItems := StringToStringList(AConnStr);
     try
       for I := 0 to LItems.Count - 1 do begin
         LName := Trim(LItems.Names[I]);
         if SameText(LName, AKey1) or ((AKey2 <> '') and SameText(LName, AKey2)) then begin
           Result := Trim(LItems.ValueFromIndex[I]);
           Exit;
         end;
       end;
     finally
       LItems.Free;
     end;
   end;

   procedure bilgial;
   begin
      if OpenSQLServerForm = nil then
         Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
      if cst <> '' then begin
         Ser_Name := GetConnectionValue(cst, 'Server', 'Data Source');
         DB_Name := GetConnectionValue(cst, 'Database', 'Initial Catalog');
      end;
      OpenSQLServerForm.cboServers.Text := Ser_Name;
      OpenSQLServerForm.cboDatabases.Text := DB_Name;
      OpenSQLServerForm.ledPassword.Text := DB_Pass;
      OpenSQLServerForm.ledUserName.Text := 'sa';
      OpenSQLServerForm.ShowModal;
      if OpenSQLServerForm.ModalResult = mrOK then begin
         if cnn.Connected then
            cnn.Connected := False;

         cst := BuildFireDACConnectionString(
            OpenSQLServerForm.cboServers.Text,
            OpenSQLServerForm.cboDatabases.Text,
            OpenSQLServerForm.ledUserName.Text,
            OpenSQLServerForm.ledPassword.Text,
            OpenSQLServerForm.yetkilendirmeComboBox.ItemIndex = 0,
            StrToIntDef(OpenSQLServerForm.EditTimeOut.Text, 15));
         ApplyFireDACConnectionString(cnn, cst, StrToIntDef(OpenSQLServerForm.EditTimeOut.Text, 15));
         if cst <> '' then begin
            cst := Sifre(cst);
            GenRegIni.RegWriteString('', 'ConnectionString', cst, 'C');
         end;
      end
      else
         cst:='';
   end;
begin
  cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
//  cst2 := GenRegIni.RegReadString('', 'ConnectionString2', '', 'C');
  if (cst = ''){and(cst2 = '')} then begin
    bilgial;
    cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
   // cst2 := GenRegIni.RegReadString('', 'ConnectionString2', '', 'C');
  end
  else begin
    cst := DeSifre(cst);
    if (Pos('Server=', cst)=0) and (Pos('Database=', cst)=0) then
       cst := DeSifre(cst);
    Ser_Name := GetConnectionValue(cst, 'Server', 'Data Source');
    DB_Name := GetConnectionValue(cst, 'Database', 'Initial Catalog');
    Tablo.Database_Name := DB_Name;
    if (Ser_Name = '')or(DB_Name = '') then begin
       bilgial;
       cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
    end;
  end;
//  else if cst2 <> '' then begin
//    Ser_Name := copy(cst2, pos('Data Source=', cst2) + 12,    pos(';Use Procedure', cst2) - pos('Data Source=', cst2) - 12);
//    DB_Name := copy(cst2, pos('Initial Catalog=', cst2) + 16, pos(';Data Source=', cst2) - pos('Initial Catalog=', cst2) - 16);
//    Tablo.Database_Name := DB_Name;
//  end;
  if (Degis) then
    bilgial;

  if not TryDecodeConnectionString(cst) then
  begin
    ResetStoredConnectionString;
    cst := '';
  end;
  if (OpenSQLServerForm <> nil)and(OpenSQLServerForm.ModalResult = 2) then begin
    VTSifreKontrolu := '';
    exit;
    //Halt;
  end;
  if Assigned(OpenSQLServerForm) then
    FreeAndNil(OpenSQLServerForm);
  try
  //  cnn.ConnectionString := cst;
  //  cnn.ConnectOptions := coConnectUnspecified;
  //  cnn.Open;
    except
 //     bilgial;
    end;

// burada ortak parser ile baglanti parametrelerini uyguluyoruz
    if Assigned(cnn) then
    begin
      if cnn.Connected then
        cnn.Connected := False;
      cnn.LoginPrompt := False;
      ApplyFireDACConnectionString(cnn, cst);
    end;

    if Assigned(Tablo) and Assigned(Tablo.FDCnn) and (Tablo.FDCnn <> cnn) then
    begin
      if Tablo.FDCnn.Connected then
        Tablo.FDCnn.Connected := False;
      Tablo.FDCnn.LoginPrompt := False;
      ApplyFireDACConnectionString(Tablo.FDCnn, cst);
    end;

    try
      if Assigned(cnn) then
        cnn.Connected := True
      else if Assigned(Tablo) and Assigned(Tablo.FDCnn) then
        Tablo.FDCnn.Connected := True;
    except
      on E: Exception do
        ShowMessage('Bağlantı Hatası!' + E.Message);
    end;


  if cst<>'' then
    Result := Ser_Name + ' / ' + DB_Name
  else
    Result:='';
end;
{$ENDIF}

function Float_ToStr(n:real):string;
var s : string[20];
begin
    s := FloatToStr(n);

    if Pos(',', s)>0 then
       s := StringReplace(s, ',', '.', [rfReplaceAll]);
    Result := s;
end;
{Şifreleme ile ilgili yordamlar}

function FetaSetSize(FileName: string; Sz: Integer): Boolean;
var
  MyFile: TFileStream;
begin
  FetaSetSize := False;
  try
    MyFile := TFileStream.Create(FileName, fmOpenRead);
  except
    Exit;
  end;
  MyFile.Destroy;
  try
    MyFile := TFileStream.Create(FileName, fmOpenReadWrite);
  except
    Exit;
  end;
  MyFile.Size := Sz;
  MyFile.Destroy;
  FetaSetSize := True;
end;

function RevPos(Substr: string; S: string): Integer;
{ rev_pos: Finds the rightmost location of (Substr) in (S)

  Warning:
  a) rev_pos returns the length of (S) if it can not find
     the (Substr) in (S)
     ( that is the way it should work )
  b) function is not tested for (Substr)'s having more than one      character.
}
var i, j, k: integer;
begin
  result := 0;
  k := length(substr) - 1;
  for i := length(s) - k downto 1 do
  begin
    for j := 0 to k do
    begin
      if s[i + j] <> substr[j + 1] then break;
      if j = k then
      begin
        result := i;
        exit;
      end;
    end;
  end;
//   if length(s)+1
//   result := length(s)+1;
end;

{ adjpath: adjusts a PATH, it appends '\' if there is none.'}

procedure adjpath(var s: string);
begin
  if s[length(s)] <> '\' then s := s + '\';
  s := AnsiUpperCaseFileName(s);
end;

function FetaGetSysDir: string;
var
  Bf: array[0..255] of Char;
begin
  GetSystemDirectory(Bf, 250);
  FetaGetSysDir := StrPas(Bf);
end;

procedure Sifrele(Yon: Integer; PSif: Pointer; Size: Integer);
var
  Sonuc: Integer;
  k: Integer;
  p: ^PDizi;
begin
  p := PSif;
  for k := 0 to Size - 1 do begin
    Sonuc := P^[k] + Yon * (k * k mod 200);
    if Sonuc > 255 then
      Sonuc := Sonuc - 255;
    if Sonuc < 0 then
      Sonuc := Sonuc + 255;
    P^[k] := Sonuc;
  end;
end;

function CrcHesapla(PSif: Pointer; Size: Integer): Word;
var
  p: ^PDizi;
  Crc: Word;
  k: Integer;
begin
  Crc := 0;
  p := PSif;
  for k := 0 to Size - 1 do begin
    Crc := (Crc + Ord(P^[k]) * Ord(P^[k])) mod Word($FFFF);
  end;
  CrcHesapla := Crc;
end;

{INI'deki Bilgileri Combo Box'a Ekler...}

function TarihFarki(tarih1, tarih2: string): Integer;
var
  t1, t2: TDateTime;
begin
  TarihFarki := 0;
//   ShortDateFormat := 'dd/MM/YYYY';
//   tarih1 := copy(tarih1, 1, pos(' ', tarih1)-1);
//   tarih2 := copy(tarih2, 1, pos(' ', tarih2)-1);
  try
    t1 := StrToDateTime(FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', StrToDateTime(tarih1)));
    t2 := StrToDateTime(FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', StrToDateTime(tarih2)));
  except
    on exception do
      Exit;
  end;
  TarihFarki := StrToInt(FloatToStr(Abs(t2 - t1)));
end;

{Function GAY2AGY(tar: String):String;
Var
   Yil,Ay,Gun:Word;
Begin
  If Tar <> '' then begin
     try
       DecodeDate(StrToDate(Tar), Yil, Ay, Gun);
       GAY2AGY := IntToStr(Ay) + '/' + IntToStr(Gun) + '/' + IntToStr(Yil);
     except
       GAY2AGY := tar;
     end;
  end
  Else
     GAY2AGY := '';
End;

Function GAY2AGY_Saat(tar: String):String;
Var
   Yil,Ay,Gun:Word;
   Saat : String[10];
Begin
  If Tar <> '' then begin
     Saat := copy(Tar, pos(' ', Tar), Length(Tar));
     DecodeDate(StrToDateTime(Tar), Yil, Ay, Gun);
     GAY2AGY_Saat := IntToStr(Ay) + '/' + IntToStr(Gun) + '/' + IntToStr(Yil)+Saat;;
  end
  Else
     GAY2AGY_Saat := '';
End;
}

function IsDateOk(tarih1: string): Boolean;
var
  t1: TDateTime;
begin
  IsDateOk := True;
  //ShortDateFormat := 'dd/MM/YYYY';
  try
    t1 := StrToDate(Tarih1);
  except
    on exception do IsDateOk := False;
  end;
end;

{$IFNDEF NO_UTABLO}
function INIToComboList1(ComboBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
var {1:ComboBox;2:ListBox}
  i, say: Integer;
  X: array[0..250] of char;
begin
  SendMessage(ComboBox, cb_ResetContent, 0, 0); {ComboBox.Items.Clear;}
  say := Ini.ReadInteger(AnahtarKelime, 'SAYI', 0);
  if (say <= 0) or (say > 500) then begin
    INIToComboList1 := False;
    Exit;
  end;
  for i := 1 to say do begin
    StrPCopy(X, Ini.ReadString(AnahtarKelime, IntToStr(i), ''));
    SendMessage(ComboBox, cb_Addstring, 0, LongInt(@X)); {ComboBox.Items.Add(X);}
  end;
  INIToComboList1 := True;
end;

function INIToList1(ListBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
var {1:ComboBox;2:ListBox}
  i, say: Integer;
  X: array[0..250] of char;
begin
  SendMessage(ListBox, lb_ResetContent, 0, 0); {ComboBox.Items.Clear;}
  say := Ini.ReadInteger(AnahtarKelime, 'SAYI', 0);
  if (say <= 0) or (say > 500) then begin
    INIToList1 := False;
    Exit;
  end;
  for i := 1 to say do begin
    StrPCopy(X, Ini.ReadString(AnahtarKelime, IntToStr(i), ''));
    SendMessage(ListBox, lb_Addstring, 0, LongInt(@X)); {ComboBox.Items.Add(X);}
  end;
  INIToList1 := True;
end;

function INIToGrid1(Grid: TDBGrid; Kolon: Integer; AnahtarKelime: string; Ini: TIni): Bool;
var
  i, say: Integer;
begin
  Grid.Columns[Kolon].Picklist.Clear; {ComboBox.Items.Clear;}
  say := Ini.ReadInteger(AnahtarKelime, 'SAYI', 0);
  if (say <= 0) or (say > 500) then begin
    INIToGrid1 := False;
    Exit;
  end;
  for i := 1 to say do
    Grid.Columns[Kolon].Picklist.Add(Ini.ReadString(AnahtarKelime, IntToStr(i), ''));
  INIToGrid1 := True;
end;
{$ENDIF}

procedure ModalDialog(Handel: THandle; YordamAd: TFarProc; DialogAd: PChar; BabaDialog: HWnd);
var AnMuProc: TFarProc;
begin
  AnMuProc := MakeProcInstance(YordamAd, Handel);
  if DialogBox(Handel, DialogAd, BabaDialog, AnMuProc) = -1 then
    Messagebox(0, 'Dialog Box oluşturulamadı..', DialogAd, mb_OK);
  FreeProcInstance(AnMuProc);
end;

function Atasi(Kod:string):string;
var
  i,Position:integer;
begin
  Position := 0;
  for I := 1 to Length(Kod) do begin
    if Copy(Kod,i,1)='.' then
      Position := i;
  end;
  Exit(Copy(Kod,0,Position-1));

end;

function DirName(Exename: string): string;
var
  k: Integer;
begin
  k := Length(Exename);
  while (k > 0) and (Exename[k] <> '\') do Dec(k);
  if k > 1 then
    Dirname := Copy(Exename, 1, k - 1)
  else
    Dirname := '';
end;

function StrToReal(OkuS: string): Real;
var
  Val, Bol: Real;
  k: Integer;
begin
  Val := 0;
  Bol := 0;
  for k := 1 to Length(Okus) do begin
    if (OkuS[k] >= '0') and (OkuS[k] <= '9') then begin
      Val := 10 * Val + (Ord(OkuS[k]) - 48);
      Bol := Bol * 10;
    end
    else if (OkuS[k] = '.') then
      Bol := 1;
  end;
  if Bol <> 0 then
    StrToReal := Val / Bol
  else
    StrToReal := Val;
end;

function Birlestir(st: TStringList): string;
var i : smallint;
begin
  Result:='';
  for i:= 0 to st.count-1 do begin
    Result:= Result+st[i];
    if i<St.Count-1 then
       Result:=Result+','
  end;
end;

procedure Parcala(st: string; var s: TStringList);
begin
  s.clear;
  while Pos(',', st) > 0 do begin
    s.Add(copy(st, 1, Pos(',', st) - 1));
    Delete(st, 1, Pos(',', st));
  end;
  s.add(st);
end;

procedure ParcalaPar(par: char; st: string; var s: TStringList);
begin
  s.clear;
  while Pos(par, st) > 0 do begin
    s.Add(copy(st, 1, Pos(par, st) - 1));
    Delete(st, 1, Pos(par, st));
  end;
  s.add(st);
end;


function CmToPixelToCm(Canvas: TCanvas; Cm: Real; YatayDusey, CmPixel: Integer): Real;
{1-Yatay; Diger-Dusey}{1-CmToPixel; 2-PixelToCm}
var
  Res: Integer;
  Sakla: Real;
begin
  if YatayDusey = 1 then
    Res := LogPixelSx
  else
    Res := LogPixelSy;
  Sakla := GetDeviceCaps(Canvas.Handle, Res);

  if CmPixel = 1 then CmToPixelToCm := Cm * Sakla / 2.54
  else CmToPixelToCm := Cm * 2.54 / Sakla;
end;

function IsFileOpen(FileName: string): Integer;
{ 0: File Not Found;
  1: File Exist And Not Open
  2: File Exist And Using by another process}
var
  l: integer;
  DirInfo: TSearchRec;
  DosError: Integer;
  Fn: array[0..50] of AnsiChar;
begin
{$I-}
  DosError := FindFirst(FileName, faArchive, DirInfo);
  if DosError = 0 then begin
    StrPCopy(Fn, Filename);
    l := _lopen(FN, OF_READ or OF_SHARE_EXCLUSIVE);
    if l = -1 then
      IsFileOpen := 2
    else begin
      IsFileOpen := 1;
      _LClose(l);
    end;
  end
  else
    IsFileOpen := 0;
end;

function UpStr(St: string): string;
var
  CSt: string;
  i: integer;
begin
  CSt := St;
  CSt:=StringReplace(CSt,'ç','Ç',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'ü','Ü',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'ğ','Ğ',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'ş','Ş',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'ö','Ö',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'ı','I',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'i','İ',[rfReplaceAll]);
{  if St <> '' then
    for i := 0 to Length(CSt) do
      case CSt[i] of
        'ç': CSt[i] := 'Ç';
        'ü': CSt[i] := 'Ü';
        'ğ': CSt[i] := 'Ğ';
        'ş': CSt[i] := 'Ş';
        'ö': CSt[i] := 'Ö';
        'ı': CSt[i] := 'I';
        'i': CSt[i] := 'İ';
//     else if CSt[i] in ['a'..'z'] then CSt[i] := UpperCase(StrPCopy(CSt[i]));
      end;}
  UpStr := UpperCase(Cst);
end;

procedure AgacYapisiKod(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1: string; Yenile: Char);
var
  j, Sev: integer;
  seviye: array[0..10] of TTreeNode;
  stlist: TStringList;

  function GecenSay(st: string): integer;
  begin
    j := 0;
    while pos('.', st) > 0 do begin
      inc(j);
      delete(st, 1, pos('.', st));
    end;
    GecenSay := j;
  end;


//  A N A   P R O G R A M
begin
  TreeView1.BringToFront;
  if (Yenile <> 'Y') and (TreeView1.TopItem <> nil) then exit;

  stlist := TStringList.Create;
  for Sev := 0 to 10 do seviye[Sev] := nil;
  Table1.First;
  TreeView1.Items.Clear;
  while not Table1.eof do begin
    stlist.Clear;
    ParcalaPar('.', Table1.FieldByName(KeyAlan1).AsString, stlist);
    Sev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
    Seviye[Sev + 1] := TreeView1.Items.AddChild(Seviye[Sev], stlist.Strings[stlist.Count - 1]); { Add a child };
    Table1.next;
  end; {while}
  stlist.free;
end;

procedure AgacYapisi(TreeView1: TcxTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
var
  j, Sev: integer;
  seviye: array[0..10] of TTreeNode;

  function GecenSay(st: string): integer;
  begin
    if Table1.FieldByName(KeyAlan1).AsString<>'' then
       j := 1
    else
       j := 0;
    while pos('.', st) > 0 do begin
      inc(j);
      delete(st, 1, pos('.', st));
    end;
    Result := j;
  end;

//  A N A   P R O G R A M
begin
  TreeView1.BringToFront;
  if (Yenile <> 'Y') and (TreeView1.TopItem <> nil) then exit;

  for Sev := 0 to 10 do seviye[Sev] := nil;
  Table1.First;
  TreeView1.Items.Clear;
  while not Table1.eof do begin
    Sev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
    Seviye[Sev + 1] := TreeView1.Items.AddChild(Seviye[Sev], Table1.FieldByName(Alan1).AsString); { Add a child };
    Table1.next;
  end; {while}
end;

function AgactaBul(TreeView1: TcxTreeView; Alan1: string): TTreeNode;
var t: TTreeNode;
  bulundu: Boolean;
begin
  t := TreeView1.TopItem;
  bulundu := false;
  while (not bulundu) and (t <> nil) do begin
    if Alan1 = t.Text then
      bulundu := true
    else
      t := t.GetNext;
  end; {while}
  Result := t;
end;

procedure AgacYapisinaCevir(TreeView1: TcxTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
var
  nod: TTreeNode;
//  A N A   P R O G R A M
begin
  TreeView1.BringToFront;
  if (Yenile <> 'Y') and (TreeView1.TopItem <> nil) then exit;
  Table1.First;
  TreeView1.Items.Clear;
  while not Table1.eof do begin
    //Sev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
    //Seviye[Sev + 1] := TreeView1.Items.AddChild(Seviye[Sev], Table1.FieldByName(Alan1).AsString); { Add a child };
    if Table1.FieldByName(KeyAlan1).AsString = '' then //grubu boşsa
       TreeView1.Items.AddChild(nil, Table1.FieldByName(Alan1).AsString) { Add a child }
    else begin
       nod := AgactaBul(TreeView1,Table1.FieldByName(KeyAlan1).AsString);
       if nod = nil  then //bulunamadıysa eklesin
          TreeView1.Items.AddChild(nod, Table1.FieldByName(KeyAlan1).AsString) { Add a child }
       else
          TreeView1.Items.AddChild(nod, Table1.FieldByName(Alan1).AsString) { Add a child };
    end;
    Table1.next;
  end; {while}
end;

{$IFNDEF NO_UTABLO}
procedure ComboDropDown(Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);overload;
begin
  Ekle := True;
  Tut := TComboBox(Sender).Text;

//   if BransIni.SectionExists(TComboBox(Sender).Hint) then
//      BransIni.ReadSection(TComboBox(Sender).Hint, TComboBox(Sender).Items)
//   else
  BransIni.ReadSection(TComboBox(Sender).Name, TComboBox(Sender).Items);
end;

procedure ComboDropDown(SectionName: string;Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);overload;
begin
  Ekle := True;
  Tut := TComboBox(Sender).Text;

//   if BransIni.SectionExists(TComboBox(Sender).Hint) then
//      BransIni.ReadSection(TComboBox(Sender).Hint, TComboBox(Sender).Items)
//   else
  BransIni.ReadSection(SectionName, TComboBox(Sender).Items);
end;
{$ENDIF}

procedure ComboChange(Sender: TObject; var Ekle: Boolean; var Tut: string);
var Tut2: string;
begin
  if (Ekle) and (TComboBox(Sender).ItemIndex <> -1) then begin
    Ekle := False;
    Tut2 := TComboBox(Sender).Items[TComboBox(Sender).ItemIndex];
    if Tut <> '' then
      Tut := Tut + '; ' + Tut2
    else
      Tut := Tut2;
    TComboBox(Sender).Items[TComboBox(Sender).Items.Count - 1] := Tut;
    TComboBox(Sender).ItemIndex := TComboBox(Sender).Items.Count - 1;
  end;
end;

procedure GetFileList(FileExt: string; Target: TStrings);
var SearchRec: TSearchRec;
  ListeSonu: Boolean;
  FileSpecs: string;
begin
  ListeSonu := False;
  GetDir(0, FileSpecs);
  FileSpecs := FileSpecs + '\*.' + FileExt;
  Target.Clear;
  if FindFirst(FileSpecs, faAnyFile, SearchRec) = 0 then begin
    while not ListeSonu do
    begin
      Target.Add(SearchRec.Name);
      ListeSonu := (FindNext(SearchRec) <> 0);
    end;
  end;
//    FindClose(SearchRec);
end;

function Benzestir(giren: string): TStringlist;
var
  tx, temp: string;
  dg, ydg: char;
  yer: array of Integer;
  tb, i, k, toplamkelime, periyot, sart: integer;
begin

  SetLength(yer, 50);
  result := TstringList.Create;
  tb := 0;

  for i := 1 to length(giren) do begin
    if (giren[i] = 'Ü') or (giren[i] = 'U') or
      (giren[i] = 'Ş') or (giren[i] = 'S') or
      (giren[i] = 'Ç') or (giren[i] = 'C') or
      (giren[i] = 'İ') or (giren[i] = 'I') or
      (giren[i] = 'Ö') or (giren[i] = 'O') or
      (giren[i] = 'Ğ') or (giren[i] = 'G') then
    begin
      tb := tb + 1;
      yer[tb] := i;
    end;
  end;

  toplamkelime := trunc(power(2, tb));

  for i := 1 to toplamkelime do
  begin
    result.Add(giren);
  end;

  for i := 1 to tb do begin

    periyot := trunc(toplamkelime / power(2, i));
    sart := periyot + 1;

    for k := 1 to toplamkelime do begin
      if k >= sart then
      begin
        temp := Result.Strings[k - 1];
        dg := temp[yer[i]];
        ydg := '?';
        case dg of
          'İ': ydg := 'I';
          'I': ydg := 'İ';
          'Ş': ydg := 'S';
          'S': ydg := 'Ş';
          'Ö': ydg := 'O';
          'O': ydg := 'Ö';
          'Ü': ydg := 'U';
          'U': ydg := 'Ü';
          'Ğ': ydg := 'G';
          'G': ydg := 'Ğ';
          'Ç': ydg := 'C';
          'C': ydg := 'Ç';
        end;
        temp[yer[i]] := ydg;
        Result.Strings[k - 1] := temp;

        if k = (sart + periyot - 1) then sart := k + periyot + 1;
      end;
    end;
  end;
end;

Function checkTCId(tcId: String):Boolean;
Var
tmp, tmp1,
odd_sum, even_sum,
ChkDigit2, ChkDigit1,
total : Int64;
d : Array[01..11] of Int64;
n : Integer;
begin
  if NOT Length(tcId) = 11 then Result := False
  else
  begin
      tmp := Trunc(StrToInt64(tcId) / 100);
      tmp1 := Trunc(StrToInt64(tcId) / 100);
      for n := 1 to 9 do
      begin
          d[n] := tmp1 mod 10;
          tmp1 := Trunc(tmp1 / 10);
      end;
          odd_sum := d[9]+d[7]+d[5]+d[3]+d[1];
          even_sum := d[8]+d[6]+d[4]+d[2];
          total := (odd_sum * 3) + even_sum;
          ChkDigit1 := (10 - (total mod 10)) mod 10;
          odd_sum := ChkDigit1+d[8]+d[6]+d[4]+d[2];
          even_sum := d[9]+d[7]+d[5]+d[3]+d[1];
          total := (odd_sum * 3) + even_sum;
          ChkDigit2 := (10 - (total mod 10)) mod 10;
          tmp := (tmp*100)+(ChkDigit1*10)+ChkDigit2;
      if NOT (tmp = StrToInt64(tcId))
      then Result := False
      else Result := True;
  end;
end;

function LeadingZero(ANumber: string;ADigit: Integer): string;
begin
  Result := ANumber;
  while Length(Result) < ADigit do   //hesapno 123 gibiyse 8 karakter olana kadar önüne 0 konmalı
    Result := '0' + Result;
end;

function FinishingSpace(ANumber: string;ADigit: Integer): string;
begin
  Result := ANumber;
  while Length(Result) < ADigit do   //isim ali gibiyse 8 karakter olana kadar sonuna boşluk konmalı
    Result :=Result + ' ';
end;
(*
Function GetPrinterDC(En,Boy : String; Netlik:Integer):HDC;
Var
  k,l,j:Integer;
  ht1,ht2:THandle;
  s:Array[0..32]Of Char;
  cb:Word;
Begin
  GetPrinterDC:=0;
  GetProfileString('Windows','device','',szD,sizeOf(szD));
  szDP:=szD;
  k:=0;l:=0;
  While (szD[k]<>#0) And (l=0) Do Begin
     If szD[k]=',' Then l:=k;
     Inc(k);
  End;
  If l<>0 Then Begin
     szD[l]:=#0;
     Inc(l);
     szdP:=@szD[l];
  End;
  k:=l;l:=0;j:=0;
  While (szD[k]<>#0) And (l=0) Do Begin
     If szD[k]=',' Then l:=k
     Else szDrv[j]:=szD[k];
     Inc(k);
     Inc(j);
  End;
  Dec(j);
  StrCopy(s,'.DRV');
  Move(s[0],szDrv[j],4);
  szDP:=@szDRV[0];
  If l<>0 Then Begin
     szD[l]:=#0;
     Inc(l);
     szPP:=@szD[l];
  End;


    { Load the device driver and find the ExtDeviceMode() function }
    hDriver:=LoadLibrary(szDP);
    If hDriver<32 Then
       Begin Str(hdriver,s);
             StrCat(s,' : Hdriver Hatası');
             MessageBox(0,s,'GENOTIP',mb_OK);
       End;
    PAdr:=GetProcAddress(hDriver,'ExtDeviceMode');
    If PAdr<>NIL Then begin
       DMInp:=Nil;
       DMOutp:=Nil;
       Cb := TExtDevMode(Padr)(0,hDriver,DMInp,szD,szPP,DMOutp,PChar(0),0);
       hT1 := LocalAlloc (LHND,cb);
       If ht1=0 Then Messagebox(0,'Local Alloc Hatası','GetprinterDC',mb_OK);
       DMInp := LocalLock (hT1);
       If DMInp=nil Then Messagebox(0,'Local Lock Hatası','GetprinterDC',mb_OK);
       hT2 := LocalAlloc (LHND,cb);
       If ht2=0 Then Messagebox(0,'Local Alloc Hatası','GetprinterDC',mb_OK);
       DMOutp := LocalLock (hT2);
       If DMOutp=nil Then Messagebox(0,'Local Lock Hatası','GetprinterDC',mb_OK);
       TExtDevMode(Padr)(0,hDriver,DMInp,szD,szPP,DMOutp,PChar(0),DM_COPY);
       {Header Information}
       StrCopy(DMInp^.dmDeviceName,szD);
       DMInp^.dmSpecVersion:=DM_SPECVERSION;
       DMInp^.dmDriverVersion:=0;
       DMInp^.dmSize:=SizeOf(TDevMode);
       DMInp^.dmDriverExtra:=0;
       {Device-Independent Settings}
       If (StrToInt(En)<>0) And (StrToInt(Boy)<>0) Then
          DMInp^.dmFields:=DM_PAPERSIZE or DM_PAPERLENGTH or DM_PAPERWIDTH or DM_PRINTQUALITY
       Else
          DMInp^.dmFields:=DM_PRINTQUALITY;
       DMInp^.dmPapersize:=DMPAPER_USER;
       DMInp^.dmPaperLength:=StrToInt(Boy);
       DMInp^.dmPaperWidth:=StrToInt(En);
       Case Netlik Of
        2:DMInp^.dmPrintQuality:=-2;
        3:DMInp^.dmPrintQuality:=-3;
        4:DMInp^.dmPrintQuality:=-4;
       End;
      { DMInp^.dmPaperSize:=dmPaper_B5 DMPAPER_A5};
       If TExtDevMode(Padr)(0,hDriver,DMInp,szD,szPP,DMInp,PChar(0),DM_MODIFY Or DM_COPY)<0 Then
          MessageBox(0,'Ext Device Mode Hatası','GENOTIP',mb_OK);
       IF TExtDevMode(Padr)(0,hDriver,DMOutp,szD,szPP,DMInp,PChar(0),DM_COPY Or DM_MODIFY)<0 Then
          MessageBox(0,'Ext Device Mode Hatası-2','GENOTIP',mb_OK);
       GetPrinterDC:=CreateDC(szDP,szD,szPP,DMOutp);
  {     GetPrinterDC:=CreateDC(szDP,szD,szPP,PChar(0));}
       LocalUnlock(hT2);
       LocalFree(hT2);
       LocalUnlock(hT1);
       LocalFree(hT1);
       FreeLibrary(hDriver);
    End
    {Else If GetProcAddress(hDriver,'DeviceMode')<>NIL Then
       DeviceMode(Dialog,hDriver,szD,szPP)};
End;
*)

function TurkceDegisBoslukBirakma(AString: string): string;
var s:string;
begin
    s := StringReplace(Astring,' ','_',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'ç','c',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'ş','s',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'ı','i',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'ğ','g',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'ö','o',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'ü','u',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'Ç','C',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'Ş','S',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'İ','I',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'Ğ','G',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'Ö','O',[rfReplaceAll, rfIgnoreCase]);
    s := StringReplace(s,'Ü','U',[rfReplaceAll, rfIgnoreCase]);
    Result := s;
end;

function WinGetSidStr (Sid : PSid) : string;
var
  SidToStr      : TConvertSidToStringSidA;
  h             : LongWord;
  Buf           : array [0..MAX_PATH - 1] of char;
  p             : PAnsiChar;
begin
  h := LoadLibrary (FILENAME_ADVAPI32);
  if h <> 0 then
  try
    @SidToStr := GetProcAddress (h, PROC_CONVERTSIDTOSTRINGSIDA);
    if @SidToStr <> nil then
    begin
      FillChar (Buf, SizeOf(Buf), 0);

      if SidToStr (Sid, p) then
        Result := '[' + string(p) + ']';

      LocalFree (LongWord(p));
    end;
  finally
    FreeLibrary (h);
  end;
end;

function GetSidStr (Sid : PSid) : string;
var
  Psia          : PSIDIdentifierAuthority;
  SubAuthCount  : LongWord;
  i             : LongWord;
begin
  if IsValidSid (Sid) then
  begin
    //
    // Win 2000+ contains ConvertSidToStringSidA() in advapi32.dll so we just
    // use it if we can
    //
    if (Win32Platform = VER_PLATFORM_WIN32_NT) and
      (Win32MajorVersion >= 5) then
      Result := WinGetSidStr (Sid)
    else
    begin
      Psia := GetSidIdentifierAuthority (Sid);
      SubAuthCount := GetSidSubAuthorityCount (Sid)^;
      Result := Format('[S-%u-', [SID_REVISION]);
      if ((Psia.Value[0] <> 0) or (Psia.Value[1] <> 0)) then
        Result := Result + Format ('%.2x%.2x%.2x%.2x%.2x%.2x', [Psia.Value[0],
          Psia.Value[1], Psia.Value[2], Psia.Value[3], Psia.Value[4],
          Psia.Value[5]])
      else
        Result := Result + Format ('%u', [LongWord(Psia.Value[5]) +
          LongWord(Psia.Value[4] shl 8) + LongWord(Psia.Value[3] shl 16) +
          LongWord(Psia.Value[2] shl 24)]);

      for i := 0 to SubAuthCount - 1 do
        Result := Result + Format ('-%u', [GetSidSubAuthority(Sid, i)^]);

      Result := Result + ']';
    end;
  end;
end;

function GetLocalUserSidStr (const UserName : string) : string;
var
  RefDomain     : array [0..MAX_PATH - 1] of char;      // enough
  RefDomainSize : LongWord;
  Snu           : SID_NAME_USE;
  Sid           : PSid;
  SidSize       : LongWord;
begin
  SidSize := 0;
  RefDomainSize := SizeOf(RefDomain);
  Sid := nil;
  FillChar (RefDomain, SizeOf(RefDomain), 0);
  LookupAccountName (nil, PChar(UserName), Sid, SidSize, RefDomain,
  RefDomainSize, Snu);
  Sid := AllocMem (SidSize);
  try
    RefDomainSize := SizeOf(RefDomain);
    if LookupAccountName (nil, PChar(UserName), Sid, SidSize, RefDomain,
      RefDomainSize, Snu) then
      Result := GetSidStr (Sid);
  finally
    FreeMem (Sid, SidSize);
  end;
end;

function GetCurrentSID:string;
begin
  Result:=GetLocalUserSidStr(GetCurrentUserName);
end;

function GetCurrentComputerName :string;
var
   buffer: array[0..255] of char;
   size: dword;
begin
  Size:=256;
  if GetComputerName(buffer, size) then
   Result := buffer
  else
   Result := ''
end;

function ResizeJPG(var oJPG: TJpegImage; Percent, Quality: integer): integer;
var
  oBmp: Graphics.TBitmap;
  Size : Integer;
begin
  oBmp:=Graphics.TBitmap.Create;
  oBmp.Width:=Round(oJPG.Width*Percent/100);
  oBmp.Height:=Round(oJPG.Height*Percent/100);
  oBmp.Canvas.StretchDraw(Rect(0,0,oBmp.Width-1,oBmp.Height-1),oJPG);
  Size := Round((oBmp.Width * oBmp.Height)/1024);
  oJPG.Assign(oBmp);
  //oJPG.CompressionQuality:=Quality;
  //oJPG.Compress;
  oBmp.Free;
  result := Size;
end;

function JPGKucult(var oJPG: TJpegImage; Pixel:integer): integer;
var
  Size, Percent: Integer;
begin
  if (oJPG.Width<=Pixel)and(oJPG.Height<=Pixel) then
      Exit;
  if oJPG.Width > oJPG.Height then
     Size := oJPG.Width
  else
     Size := oJPG.Height;

  Percent := Round(Pixel*100 / Size);
  result := ResizeJPG(oJPG,Percent,0);
end;

function RoundN(x: Extended; d: Integer): Extended;
  // RoundN(123.456, 0) = 123.00
  // RoundN(123.456, 2) = 123.46
  // RoundN(123456, -3) = 123000
  const
    t: array [0..12] of int64 = (1, 10, 100, 1000, 10000, 100000,
        1000000, 10000000, 100000000, 1000000000, 10000000000,
        100000000000, 1000000000000);
  begin
    if Abs(d)=12 then
      raise ERangeError.Create('RoundN: Value must be in -12..12');
    if d = 0 then
      Result := Int(x) + Int(Frac(x) * 2)
    else if d > 0 then begin
      x := x * t[d];
      Result := (Int(x) + Int(Frac(x) * 2)) / t[d];
    end else begin  // d       x := x / t[-d];
      Result := (Int(x) + Int(Frac(x) * 2)) * t[-d];
    end;
  end;

function SifreKontrolu(OncekiSifre,inputStr,inputStr2 : string):string;
var
  isbefore, issame, isLongEnough, hasDigit, hasLower, hasUpper, hasSpecial: Boolean;
  i: Integer;
  s: string;
begin

  isbefore := OncekiSifre <> Sifre(inputStr);

  issame := inputStr = inputStr2;

  // En az 8 karakter olup olmadığını kontrol ediyoruz
  isLongEnough := Length(inputStr) >= 8;

  // Başlangıçta tüm kontrol flag'lerini false olarak ayarlıyoruz
  hasDigit := False;
  hasLower := False;
  hasUpper := False;
  hasSpecial := False;

  // String'in her karakterini kontrol ediyoruz
  for i := 1 to Length(inputStr) do
  begin
    // Eğer karakter bir rakam ise
    if CharInSet(inputStr[i], ['0'..'9']) then
      hasDigit := True;

    // Eğer karakter küçük harf (a-z, ğüşöç) ise
    if CharInSet(inputStr[i], ['a'..'z', 'ğ', 'ü', 'ş', 'ö', 'ç']) then
      hasLower := True;

    // Eğer karakter büyük harf (A-Z, ĞÜŞİÖÇ) ise
    if CharInSet(inputStr[i], ['A'..'Z', 'Ğ', 'Ü', 'Ş', 'İ', 'Ö', 'Ç']) then
      hasUpper := True;

    // Eğer karakter özel bir karakterse (alfabetik olmayan ve rakam olmayan)
    if not CharInSet(inputStr[i], ['a'..'z', 'A'..'Z', '0'..'9', 'ğ', 'ü', 'ş', 'ö', 'ç', 'Ğ', 'Ü', 'Ş', 'İ', 'Ö', 'Ç']) then
      hasSpecial := True;
  end;

  // Sonuçları ekrana yazdırıyoruz
  s:= GirdiginizSifre+#32#10;

  if not isBefore then
     s:=s+' '+OncekiSifreileAyni+#32#10;

  if not isSame then
     s:=s+' '+AyniDegil+#32#10;

  if not isLongEnough then
     s:=s+' '+SifreKisa+#32#10;

  if not hasDigit then
    s:=s+' '+HicRakamYok+#32#10;

  if not hasLower then
    s:=s+' '+HicKucukHarfYok+#32#10;

  if not hasUpper then
    s:=s+' '+HicBuyukHarfYok+#32#10;

  if not hasSpecial then
    s:=s+' '+HicOzelKarakterYok;

  if (isBefore)and(isSame)and(isLongEnough)and(hasDigit)and(hasLower)and(hasUpper)and(hasSpecial) then
     result := ''
  else
     result := s;
end;
end.








