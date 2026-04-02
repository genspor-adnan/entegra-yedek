unit Fetautil;

interface

uses Forms, SysUtils, Messages, Classes, Graphics, DBGrids,
  comctrls, StdCtrls, UFDCompatHelpers, {$IFNDEF NO_UTABLO}UCombo,uTablo,{$ENDIF}Math,comobj,WINDOWS,CONTROLS,
  NB30,Variants,Grids,Db, JvRichEdit, ActiveX, OleCtnrs, ExtCtrls, CheckLst,DdeMan;

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
function INIToComboList1(ComboBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
function INIToList1(ListBox: HWnd; AnahtarKelime: string; Ini: TIni): Bool;
function INIToGrid1(Grid: TDBGrid; Kolon: Integer; AnahtarKelime: string; Ini: TIni): Bool;
procedure ComboDropDown(Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);overload;
procedure ComboDropDown(SectionName: string;Sender: TObject; var Ekle: Boolean; var Tut: string; BransIni: TIni);overload;
function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TADOConnection; Degis: Boolean): string;
function TarihBul():TDateTime;
{$ENDIF}

procedure ModalDialog(Handel: THandle; YordamAd: TFarProc; DialogAd: PChar; BabaDialog: HWnd);
function DirName(Exename: string): string;
function StrToReal(OkuS: string): Real;
function TarihFarki(tarih1, tarih2: string): Integer;
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
procedure AgacYapisi(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
function AgactaBul(TreeView1: TTreeView; Alan1: string): TTreeNode;
procedure ComboChange(Sender: TObject; var Ekle: Boolean; var Tut: string);
procedure GetFileList(FileExt: string; Target: TStrings);
function RevPos(Substr: string; S: string): Integer;
procedure adjpath(var s: string);
function YasHesapla(Dtarih, Bugun: TDateTime; var YYil, YAy, YGun: Word): string;
function Benzestir(giren: string): TStringlist;
procedure ParcalaPar(par: char; st: string; var s: TStringList);
function Virgulle(S: Currency): string;
function GetFileVersion(FileName: string) : string;
function GetParamIndex(prm :string; CaseInSensetive :Boolean = True) :Integer;


function Duyarlilik_Cur(R: Currency): Currency;
function Duyarlilik_Float(R: Real): Real;
function TariheGunEkle(Tarih: TDateTime; Ekleme: SmallInt): SmallInt;
procedure PacsCalistir(Ini: TIni;dosyaNo,gelisNo: string;DdeConv: TDdeClientConv);

{ver 1.0}
function GetMACAdress: string;
procedure LogaEkle(s :string);
function _query_exec(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant) : TADOQuery;
{ver 1.1}
function StringGridToRTF(Title: string;grid : TStringGrid): string;
function DbGridToRTF(Title,ABlockName: string;grid : TDBGrid;ExtraFields: array of string): string;
{ver 1.2}
function GetDelimitedString(var s : string): string;overload;
function GetDelimitedString(var s : string;delimiter : string): string;overload;
function LeadingZero(value: Integer;lz: byte): string;
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
function DbTableToRtf(ATitle,ABlockName: string;ATable: TDataset;Fields: array of string;
  ColumnWidths: array of integer): string;
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
/// Kolon içindeki deðerlerin en büyüðünü döndürür.
/// </summary>
/// <param name="cnn">Baðlantý nesnesi</param>
/// <param name="TableName">Tablo adý</param>
/// <param name="ColumnName">Kolon adý</param>
/// <param name="WhereClause">Sorgunun WHERE kýsmý</param>
/// <returns>Sorgu içindeki kolonun en büyük deðeri döner. Eðer sorgudan hiç kayýt dönmezse sonuç 0 döner. </returns>
function FindMaximumOfColumn(cnn: TADOConnection;TableName,ColumnName,WhereClause: string): Integer;
function TurkishToEnglishCharset(st :string) :string;
{ver 2.1}
procedure TrimSpaces(ACtrl : TRichEdit);
function RemoveBlock(AEditor: TCustomRichEdit;ABlockName: string): Boolean;
{ver 2.2}
function DataExists(cnn: TADOConnection;ASQL: string;AParams: array of string;AParamValues: array of Variant): Boolean;
{ver 2.3}
function ControlToString(AComponent : TComponent) : string;
function FindParam(AEditor: TRichEdit;
  AString: string;var APos: integer): Integer;overload;
function FindParam_Jv(AEditor: TJvCustomRichEdit;
  AString: string;var APos: integer): Integer;overload;
procedure InternalReplace(AEditor: TRichEdit;
  AParam: string;AValue: string);
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
function DoCommands(ASource: string;AVariables: TStringList): string;
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
function StringToStringList(ASource: string): TStringList;
{ver 3.6} // 18/10/2008 12:42:17
procedure FillStringListFromDataSet(ADestList: TStrings;
  ASourceDataSet : TDataSet;ASourceField: string);
{ver 3.7} // 20/10/2008 15:57:53
function IsNullOrEmpty(AField: TField) : Boolean;
{ver 3.8} // 21/10/2008 15:33:46
procedure StringdenIsarete(ADegerListesi: string;
  AKontrol: TCheckListBox; AKaynakTablo: TDataSet; AKaynakAlan: string);
function IsarettenStringe(AKontrol: TCheckListBox;
  AKaynakTablo: TDataSet; AKaynakAlan: string): string;
{ver 3.9} // 22/10/2008 14:55:30
{$IFNDEF NO_UTABLO}
function VersiyonKontrolu(Modul, Versiyon : String; i:integer; GenotipIni:TIni;GenRegIni : TRegIni; RgstryLC:char) : Integer;
{$ENDIF}

const
  DataFile = 'Datgen.dll';
var
  GenotipBilgi: TGenotipBilgi;
  ProgramTerminating : Boolean;

implementation

uses Dialogs{$IFNDEF NO_UTABLO},oPENsqlsERVER,UMesaj{$ENDIF},Registry;

var
  PixPerInch: TPoint;

{$IFNDEF NO_UTABLO }
function VersiyonKontrolu(Modul, Versiyon : String; i:integer; GenotipIni:TIni;GenRegIni : TRegIni; RgstryLC:char) : Integer;
var s, vers, Dizin, Modulexe, eskiad:String;
    f : file;
begin
     vers := GenotipIni.ReadString('Versiyonlar',Modul,'xx');
     if (vers = 'xx')or (vers < Versiyon) then begin
         if Application.MessageBox(Pchar('Bu yeni bir sürüm. Sisteme kayýt edilsin mi'), 'O N A Y', MB_YESNO)<>IDYES then begin
               VersiyonKontrolu := 1;
               exit;
         end
         else
            GenotipIni.WriteString('Versiyonlar', Modul, Versiyon)
     end
     else if vers > Versiyon then begin
         if (i = 1)and(Application.MessageBox(Pchar('Yeni '+Modul+' sürümü bulundu, yüklensin mi'), 'O N A Y', MB_YESNO)<>IDYES) then begin
               VersiyonKontrolu := 1;
               exit;
         end;
         Dizin := GenotipIni.ReadString('Versiyonlar', 'YeniVersDizini', '---');
         if Modul = 'Kayýt Kabul' then
            Modulexe := 'KayitKabul.exe'
         else
            Modulexe := Modul+'.exe';

         while not FileExists(Dizin+Modulexe) do begin
            if not MesajStrAl('Dizinde '+Modulexe+' bulunamadý..', 'Yeni sürüm için server kaynak dizini girin (Ör:\\server\prg\)', 'E', nil, Dizin, '', 'E', nil, Dizin) then begin
               VersiyonKontrolu := 1;
               exit;
            end;
            GenotipIni.WriteString('Versiyonlar', 'YeniVersDizini', Dizin);
            //if Modul = 'Kayýt Kabul' then
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
           Showmessage(vers+' sürümü bilgisayarýnýza yüklenemedi..');
           VersiyonKontrolu:= 1;
         end else begin
           Showmessage(vers+' sürümü bilgisayarýnýza yüklendi, programa tekrar girin..');
           VersiyonKontrolu:= 9;
         end;
     end;
end;
{$ENDIF}

function GetParamIndex(prm :string; CaseInSensetive :Boolean = True) :Integer;
var
  xi :Integer;
begin
  xi := 0;
  Result := 0;
  for xi := 1 to ParamCount do
    if (
      (CaseInSensetive and (UpperCase(ParamStr(xi)) = UpperCase(prm))) or
      (not CaseInSensetive and (ParamStr(xi) = prm))
      ) then
    begin
      Result := xi;
      Exit;
    end;
end;


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

function StringToStringList(ASource: string): TStringList;
begin
  Result := TStringList.Create;
  while Length(ASource) > 0 do begin
    Result.Add(GetDelimitedString(ASource,';'));
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
  // þimdi tek tek çevirip stream e yazýyoruz
  for i := 0 to (Length(AHexString) div 2) - 1 do begin
    // hex olarak dizeye atýyoruz örn $55
    s := '$' + Copy(AHexString,(i * 2) + 1, 2);
    // byte'a dönüþtürüp w ye atýyoruz
    w := StrToInt(s);
    // stream'a yazýyoruz
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

function DoCommands(ASource: string;AVariables: TStringList): string;

  function DoTableFieldValue(p: TParser): string;
  var
    i : Integer;
  begin
    if (not Assigned(AVariables)) then
      raise EInvalidOperation.Create('Ýç hata ! : 1000');
    Result := '';
    if (p.Token = '@') then begin
      if p.NextToken = '@' then begin
        // Deðiþken
        // bundan sonra sembol gelmeli!!!
        p.NextToken;
        p.CheckToken(toSymbol);
        i := AVariables.IndexOf(p.TokenString);
        if (i > -1) and (Assigned(AVariables.Objects[i])) then begin
          p.NextToken;
          p.CheckToken('.');
          p.NextToken;
          p.CheckToken(toSymbol);
          Result := TDataSet(AVariables.Objects[i]).FieldByName(p.TokenString).AsString;
        end;
      end;
    end;
  end;

  function DoStatement(p: TParser): string;
  const
    toGreater = 0;
    toGreaterEqual = 1;
    toLess = 2;
    toLessEqual = 3;
    toEqual = 4;
    toNotEqual = 5;        
  var
    tmp1 : string;
    tmp2 : string;
    floatValue : Double;
    YasGun,YasAy,YasYil : Word;
    byteValue : Byte;
  begin
    case p.Token of
      '@': begin
        Result := DoTableFieldValue(p);
      end;
      toString: begin
        Result := p.TokenString;
      end;
      '~': begin // deðiþken
        if (not Assigned(AVariables)) then
          raise Exception.Create('Ýç hata 1000'); 
        p.NextToken;
        p.CheckToken(toSymbol);
        Result := AVariables.Values[p.TokenString];
      end;
      toSymbol: begin
        if p.TokenString = 'IF' then begin
          p.NextToken;
          p.CheckToken('(');
          p.NextToken;
          Result := DoStatement(p);
          p.NextToken;
          p.CheckToken(')');
          p.NextToken;
          tmp1 := DoStatement(p); // IF TRUE
          p.NextToken;
          p.CheckTokenSymbol('ELSE');
          p.NextToken;
          tmp2 := DoStatement(p);
          if (Result <> '') then
            Result := tmp1
          else
            Result := tmp2;
        end else if p.TokenString = 'ADD' then begin
          p.NextToken;
          p.CheckToken('(');
          p.NextToken;
          Result := DoStatement(p);
          p.NextToken;
          p.CheckToken(',');
          p.NextToken;
          Result := Result + DoStatement(p);
          p.NextToken;
          p.CheckToken(')');
        end else if p.TokenString = 'YAS' then begin
          p.NextToken;
          p.CheckToken('(');
          p.NextToken;
          tmp1 := DoStatement(p);
          floatValue := StrToDateDef(tmp1,Date);
          tmp2 := YasHesapla(floatValue, Date, YasYil, YasAy, YasGun);
          p.NextToken;
          p.CheckToken(',');
          p.NextToken;
          tmp1 := DoStatement(p);
          if tmp1 = '0' then // branþ çocuk deðilse
            Result := tmp2
          else
            Result := IntToStr(YasYil) + 'y ' + IntToStr(YasAy) + 'a ' + IntToStr(YasGun) + 'g';
          p.NextToken;
          p.CheckToken(')');
        end else if p.TokenString = 'SET' then begin
          p.NextToken;
          p.CheckToken(toSymbol);
          tmp1 := p.TokenString;
          p.NextToken;
          p.CheckToken('=');
          p.NextToken;
          tmp2 := DoStatement(p);
          if AVariables.IndexOf(p.TokenString) = -1 then
            AVariables.Add(tmp1 + '=' + tmp2)
          else
            AVariables.Values[tmp1] := tmp2;
          Result := '';
        end else if p.TokenString = 'COMPARE' then begin
          p.NextToken;
          p.CheckToken('(');
          p.NextToken;
          tmp1 := DoStatement(p);
          p.NextToken;
          byteValue := 255;
          case p.Token of
            '>': begin
              if p.NextToken = '=' then
                byteValue := toGreaterEqual
              else
                byteValue := toGreater;
            end;
            '<': begin
              if (p.NextToken = '>') then
                byteValue := toNotEqual
              else
                if p.Token = '=' then
                  byteValue := toLessEqual
                else
                  byteValue := toLess;
            end;
            '=': begin
              byteValue := toEqual;
            end;
          end;
          if byteValue = 255 then
            raise Exception.Create('Invalid expression!');
          if not (byteValue in [toLess,toGreater]) then
            p.NextToken;
          tmp2 := DoStatement(p);
          case byteValue of
            toLess: Result := IIf(tmp1 < tmp2,'1','');
            toLessEqual: Result := IIf(tmp1 <= tmp2,'1','');
            toEqual: Result := IIf(tmp1 = tmp2,'1','');
            toNotEqual: Result := IIf(tmp1 <> tmp2,'1','');
            toGreater: Result := IIf(tmp1 > tmp2,'1','');
            toGreaterEqual: Result := IIf(tmp1 >= tmp2,'1','');
          end;
          p.NextToken;
          p.CheckToken(')');
        end else if p.TokenString = 'TARIH' then begin
          Result := DateToStr(Date);
        end else if p.TokenString = 'TARIHF' then begin
          p.NextToken;
          p.CheckToken('(');
          p.NextToken;
          tmp1 := DoStatement(p);
          Result := FormatDateTime(tmp1,Now);
          p.NextToken;
          p.CheckToken(')');
        end else if p.TokenString = 'SAAT' then begin
          Result := TimeToStr(Time);
        end else if p.TokenString = 'FORMATDATETIME' then begin
          p.NextToken;
          p.CheckToken('(');
          p.NextToken;
          tmp1 := DoStatement(p); // tarih string olarak
          p.NextToken;
          p.CheckToken(',');
          p.NextToken;
          tmp2 := DoStatement(p); // tarih formatý
          if tmp1 <> '' then
            Result := FormatDateTime(tmp2,StrToDateTime(tmp1))
          else
            Result := '';
          p.NextToken;
          p.CheckToken(')');
        end;
      end;
    end;
  end;

var
  s : TStringStream;
  p : TParser;
begin
  s := TStringStream.Create(ASource);
  p := TParser.Create(s);
  try
    Result := '';
    while p.Token <> toEOF do begin
      Result := Result + DoStatement(p);
      p.NextToken;
    end;
  finally
    p.Free;
    s.Free;
  end;
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
    Result := tmp.RecordCount > 0;
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
    'þ': Result := 'Þ';
    'i': Result := 'Ý';
    'ý': Result := 'I';
    'ð': Result := 'Ð';
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
        'Ð' :ch2 := 'Ð';
        'Ý' :ch2 := 'I';
        'Ö' :ch2 := 'O';
        'Þ' :ch2 := 'S';
        'Ü' :ch2 := 'U';
        ' ' :ch2 := '_';
        'ç' :ch2 := 'c';
        'ð' :ch2 := 'g';
        'ý' :ch2 := 'i';
        'ö' :ch2 := 'o';
        'þ' :ch2 := 's';
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
    if (qry.RecordCount > 0) then
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

       Deðerler
         Length(AValue) = 13
         Length(AValue) - StartIndex = 9
         alýnmasý gereken karakter sayýsý = 10
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
//      'þ': Result := Result + '\''fe';
//      'ý': Result := Result + '\''fd';
//      'ð': Result := Result + '\''f0';
//      'ü': Result := Result + '\''fc';
//      'Ö': Result := Result + '\''d6';
//      'Ç': Result := Result + '\''c7';
//      'Þ': Result := Result + '\''de';
//      'Ý': Result := Result + '\''dd';
//      'Ð': Result := Result + '\''d0';
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

    // Baþlýk Bilgisi
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
    // Baþlýk Bilgisi
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

    // Baþlýk Bilgisi

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
    //Result := Result + Format( '\par \pard\plain\f0%s\cf0 %s'#13#10, [ GetRTFFontInfo( grid.Font ), 'Footerim tekerleðim' ] );
    Result := Result + '}}';
  finally
    AFont.Free;
  end;
end;


{$IFNDEF NO_UTABLO}
// completely changed by Erhan 26.10.2007
function TarihBul():TDateTime;
var
  tempQuery : TADOQuery;
begin
  tempQuery := TADOQuery.Create(nil);
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

function _query_exec(cnn : TADOConnection;sql: string;paramNames : array of string;params:array of variant) : TADOQuery;
var
  i     : Integer;
begin
  if ((Length(paramNames) > 0)) then
    begin
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
Writeln(f, FormatDateTime('HH:NN:SS.ZZZ', now)+#9+ s);
CloseFile(f);
end;

function GetMACAdress: string;
var
NCB: PNCB;
Adapter: PAdapterStatus;

URetCode: PChar;
RetCode: char;
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


//function GetFileVersiyon(): string;
//var
//  S: string;
//  n, Len: DWORD;
//  Buf: PChar;
//  Value: PChar;
//begin
//  S := Application.ExeName;
//  n := GetFileVersionInfoSize(PChar(S), n);
//  Buf := AllocMem(n);
//  GetFileVersionInfo(PChar(S), 0, n, Buf);
//  VerQueryValue(Buf, 'StringFileInfo\041F04E6\FileVersion', Pointer(Value), Len);
//  FreeMem(Buf, n);
//  Result := Value;
//end;


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
{    Gun := Ekleme;
    i := Gun Div 5;
    j := DayOfWeek(Tarih+Gun);
    if (j=0)or(j=6)then inc(i);
    Gun := Gun + i*2;
    j := DayOfWeek(Tarih+Gun);
    if (j=0)or(j=6)then inc(Gun, 2);
    TariheGunEkle := Gun;}
end;

procedure PacsCalistir(Ini: TIni;dosyaNo,gelisNo: string;DdeConv: TDdeClientConv);
var
  reg : TRegistry;
  pacsExecutable : string;
  DdeCli :TDdeClientConv;
  DdeClientItem: TDdeClientItem;
  ss :array[0..20] of char;
begin
  if (dosyaNo = '') then Exit;
  // Opsiyon olarak eklenmeli!!!!!
  if Ini.ReadBool('Pacs','YeniPacsModulu',False) then begin
    reg := TRegistry.Create;
    try
      reg.RootKey := HKEY_CURRENT_USER;
      if reg.OpenKey('Software\GENOTIP\Pacs',True) then begin
        reg.WriteString('DosyaNo',dosyaNo);
        reg.WriteString('GelisNo',gelisNo);
        reg.CloseKey;
      end;
      // Opsiyon olarak eklenmeli!!!!!
      pacsExecutable := Ini.ReadString('Pacs','ProgramYolu','');
      if (pacsExecutable <> '') and (FileExists(pacsExecutable)) then begin
        WinExec(PChar(pacsExecutable),SW_SHOW);
      end;
    finally      
      reg.Free;
    end;
    Application.Minimize;
  end else begin
    //DdeClientItem
    DdeClientItem := TDdeClientItem.Create(nil);
    try
      //DdeClientItem
      DdeClientItem.Name := 'DdeClientItem';
      DdeClientItem.DdeConv := DdeConv;
      DdeConv.SetLink('GPACS', dosyaNo);
      DdeClientItem.DdeConv := DdeConv;
      DdeClientItem.DdeItem := 'DdeTestItem';  
      DdeConv.PokeData(DdeClientItem.DdeItem, StrPCopy(ss, dosyaNo ));
    finally
      DdeClientItem.Free;
    end;
    Application.Minimize;
    DdeCli.CloseLink;
  end;
end;

{
function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TADOConnection; Degis: Boolean): string;
var cst, Ser_Name, DB_Name, DB_Pass, s2: string;
  i: smallint;
  e: eoleexception;
  tut: Boolean;
  procedure bilgial;
  begin
    if not MesajStrAl('', 'Server Adýný Giriniz :', 'E', nil, Ser_Name, 'Veri Tabaný Adýný', 'E', nil, DB_Name) then halt;
    if (Ser_Name = '') or (DB_Name = '') then begin
      showmessage('Adýný boþ girdiniz. Kapatýlýyor..');
      halt;
    end;
    if not MesajStrAl('', 'Veri Tabaný Þifresini Giriniz :', 'E', nil, DB_Pass, '', 'E', nil, DB_Pass) then halt;
    if cnn.Connected then
       cnn.Connected := False;
    cnn.ConnectionString := 'Provider=SQLOLEDB.1;Password=' + DB_Pass + ';Persist Security Info=False;Packet Size=8192;User ID=sa;Initial Catalog=' +
      DB_Name + ';Data Source=' + Ser_Name;
//       s2:=DB_Pass;
//       for i:=1 to length(DB_Pass) do
//           s2[i]:=chr(ord(DB_Pass[i])+10);
    GenRegIni.RegWriteString('', 'ConnectionString', cnn.ConnectionString, 'C');
  end;
begin
  cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');

  if cst <> '' then begin
    Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, length(cst) - pos(';Data Source=', cst));
    DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';Data Source=', cst) - pos('Initial Catalog=', cst) - 16);
  end;

  if (Degis) or (cst = '') then
    bilgial
  else
    cnn.ConnectionString := cst;
  if Degis then halt;

//   if DB_Pass<>'' then
//      for i:=1 to length(DB_Pass) do
//             DB_Pass[i]:=chr(ord(DB_Pass[i])-10);
  while not cnn.Connected do begin
    try
          ///showmessage(cst);
      cnn.Open;
    except
      on e: eoleexception do begin
        bilgial;
      end;
    end;
  end;
  VTSifreKontrolu := Ser_Name + ' / ' + DB_Name;
end;
}
{$IFNDEF NO_UTABLO }
function VTSifreKontrolu(GenRegIni: TRegIni; cnn: TADOConnection; Degis: Boolean): string;
var cst, DB_Pass, Ser_Name, DB_Name, s2: string;
   i: smallint;
   e: eoleexception;
   tut: Boolean;
   procedure bilgial;
   begin

      if OpenSQLServerForm = nil then
         Application.CreateForm(TOpenSQLServerForm, OpenSQLServerForm);
      if cst <> '' then begin
         Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, length(cst) - pos(';Data Source=', cst) + 13);
         DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';Data Source=', cst) - pos('Initial Catalog=', cst) - 16);
//         Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, pos(';Initial Catalog', cst) - pos(';Data Source=', cst) - 13);
//         DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';uid', cst) - pos('Initial Catalog=', cst) - 16);

      end;
      OpenSQLServerForm.cboServers.Text := Ser_Name;
      OpenSQLServerForm.cboDatabases.Text := DB_Name;
      OpenSQLServerForm.ledPassword.Text := DB_Pass;
      OpenSQLServerForm.ledUserName.Text := 'sa';
      OpenSQLServerForm.ShowModal;
      if OpenSQLServerForm.ModalResult = mrOK then
         if cnn.Connected then cnn.Connected := False;

      cnn.ConnectionString :=
        OpenSQLServerForm.ADOConnection1.ConnectionString;
      GenRegIni.RegWriteString('', 'ConnectionString', OpenSQLServerForm.ADOConnection1.ConnectionString, 'C');
      cst := OpenSQLServerForm.ADOConnection1.ConnectionString;
   end;
begin

   cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
   if cst = '' then
   begin
      bilgial;
      cst := GenRegIni.RegReadString('', 'ConnectionString', '', 'C');
   end;

   Ser_Name := copy(cst, pos(';Data Source=', cst) + 13, length(cst) - pos(';Data Source=', cst) + 13);
   DB_Name := copy(cst, pos('Initial Catalog=', cst) + 16, pos(';Data Source=', cst) - pos('Initial Catalog=', cst) - 16);


   if (Degis) then
      bilgial;
   if (OpenSQLServerForm <> nil) and (OpenSQLServerForm.ModalResult = 2) then
      Halt;
   cnn.ConnectionString := cst + ';Application Name=' + Application.Title;
    try
      cnn.ConnectOptions := coConnectUnspecified;
      cnn.Connected := True;
   except
      bilgial;
   end;     
   VTSifreKontrolu := Ser_Name + ' / ' + DB_Name;
end;
{$ENDIF}

function Duyarlilik_Cur(R: Currency): Currency;
var s, s2: string[20];
  i: smallint;
  x: real;
begin
   //Katký yüzdenin . dan sonraki 2 rakamý alýnýr
{   s := FloatToStr(R);
   i:=pos('.',s);
   if i>0 then begin         //34.4576 -->  4576  al --> 45.76 yap
      s2:=copy(s,i+1,length(s)-i);
      s:=copy(s,1,i-1);    //34 al
      if length(s2)>2 then
         insert('.',s2,3);
      x:=strtofloat(s2);                         8.245  8.25
      i:=round(x);
      i:=format('#####0.00',[x]);
      s:=s+'.'+IntToStr(i);
   end;
   Duyarlilik_Cur := StrToFloat(s);}
  s := FormatFloat('#####0.00', R);
  Duyarlilik_Cur := StrToFloat(s);


end;

function Duyarlilik_Float(R: Real): Real;
var s, s2: string[20];
  i: smallint;
begin
   //Katký yüzdenin . dan sonraki 2 rakamý alýnýr
  s := FloatToStr(R);
  i := pos('.', s);
  if i > 0 then begin //34.4576 -->  4576  al --> 45.76 yap
    s2 := copy(s, i + 1, length(s) - i);
    s := copy(s, 1, i - 1); //34 al
    if length(s2) > 12 then
      insert('.', s2, 13);
    s := s + '.' + IntToStr(round(strtofloat(s2)));
  end;
  Duyarlilik_Float := StrToFloat(s);
end;

function Virgulle(S: Currency): string;
var nok, t: string;
begin
  nok := FloatToStr(s);
  if pos('.', nok) > 0 then
    Delete(nok, 1, pos('.', nok) - 1)
  else
    nok := '';


  t := Format('%m', [s]);
  if pos('TL', t) > 0 then
    Delete(t, pos('TL', t) - 1, 3);
  Virgulle := t + nok;
end;

{Þifreleme ile ilgili yordamlar}

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
    t1 := StrToDateTime(FormatDateTime('DD/MM/YYYY', StrToDateTime(tarih1)));
    t2 := StrToDateTime(FormatDateTime('DD/MM/YYYY', StrToDateTime(tarih2)));
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
  ShortDateFormat := 'dd/MM/YYYY';
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
    Messagebox(0, 'Dialog Box oluþturulamadý..', DialogAd, mb_OK);
  FreeProcInstance(AnMuProc);
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
  Fn: array[0..50] of Char;
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
  CSt:=StringReplace(CSt,'ð','Ð',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'þ','Þ',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'ö','Ö',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'ý','I',[rfReplaceAll]);
  CSt:=StringReplace(CSt,'i','Ý',[rfReplaceAll]);
{  if St <> '' then
    for i := 0 to Length(CSt) do
      case CSt[i] of
        'ç': CSt[i] := 'Ç';
        'ü': CSt[i] := 'Ü';
        'ð': CSt[i] := 'Ð';
        'þ': CSt[i] := 'Þ';
        'ö': CSt[i] := 'Ö';
        'ý': CSt[i] := 'I';
        'i': CSt[i] := 'Ý';
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

procedure AgacYapisi(TreeView1: TTreeView; Table1: TADOQuery; KeyAlan1, Alan1: string; Yenile: Char);
var
  j, Sev: integer;
  seviye: array[0..10] of TTreeNode;

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

  for Sev := 0 to 10 do seviye[Sev] := nil;
  Table1.First;
  TreeView1.Items.Clear;
  while not Table1.eof do begin
    Sev := GecenSay(Table1.FieldByName(KeyAlan1).AsString);
    Seviye[Sev + 1] := TreeView1.Items.AddChild(Seviye[Sev], Table1.FieldByName(Alan1).AsString); { Add a child };
    Table1.next;
  end; {while}
end;

function AgactaBul(TreeView1: TTreeView; Alan1: string): TTreeNode;
var t, son: TTreeNode;
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
  AgactaBul := t;
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

function YasHesapla(Dtarih, Bugun: TDateTime; var YYil, YAy, YGun: Word): string;
var t3: TDateTime;
begin
  if FormatDateTime('DD/MM/YYYY', Bugun) = FormatDateTime('DD/MM/YYYY', DTarih) then begin
    YGun := 0; YAy := 0; YYil := 0;
  end else
    if Bugun > DTarih then begin
      T3 := Bugun - DTarih + 1;
      DecodeDate(t3, YYil, YAy, YGun);
      Dec(YYil, 1900);
      Dec(YAy);
    end;
  if (YYil = 0) and (YAy = 0) then
    YasHesapla := IntToStr(YGun) + 'Gün'
  else if YYil = 0 then
    YasHesapla := IntToStr(YAy) + 'Ay' //+IntToStr(YGun)+'g'
  else if YYil > 0 then
    YasHesapla := IntToStr(YYil);
//   else
//      YasHesapla := IntToStr(YYil)+'y '+IntToStr(YAy)+'a '+IntToStr(YGun)+'g';
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
      (giren[i] = 'Þ') or (giren[i] = 'S') or
      (giren[i] = 'Ç') or (giren[i] = 'C') or
      (giren[i] = 'Ý') or (giren[i] = 'I') or
      (giren[i] = 'Ö') or (giren[i] = 'O') or
      (giren[i] = 'Ð') or (giren[i] = 'G') then
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
          'Ý': ydg := 'I';
          'I': ydg := 'Ý';
          'Þ': ydg := 'S';
          'S': ydg := 'Þ';
          'Ö': ydg := 'O';
          'O': ydg := 'Ö';
          'Ü': ydg := 'U';
          'U': ydg := 'Ü';
          'Ð': ydg := 'G';
          'G': ydg := 'Ð';
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
             StrCat(s,' : Hdriver Hatasý');
             MessageBox(0,s,'GENOTIP',mb_OK);
       End;
    PAdr:=GetProcAddress(hDriver,'ExtDeviceMode');
    If PAdr<>NIL Then begin
       DMInp:=Nil;
       DMOutp:=Nil;
       Cb := TExtDevMode(Padr)(0,hDriver,DMInp,szD,szPP,DMOutp,PChar(0),0);
       hT1 := LocalAlloc (LHND,cb);
       If ht1=0 Then Messagebox(0,'Local Alloc Hatasý','GetprinterDC',mb_OK);
       DMInp := LocalLock (hT1);
       If DMInp=nil Then Messagebox(0,'Local Lock Hatasý','GetprinterDC',mb_OK);
       hT2 := LocalAlloc (LHND,cb);
       If ht2=0 Then Messagebox(0,'Local Alloc Hatasý','GetprinterDC',mb_OK);
       DMOutp := LocalLock (hT2);
       If DMOutp=nil Then Messagebox(0,'Local Lock Hatasý','GetprinterDC',mb_OK);
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
          MessageBox(0,'Ext Device Mode Hatasý','GENOTIP',mb_OK);
       IF TExtDevMode(Padr)(0,hDriver,DMOutp,szD,szPP,DMInp,PChar(0),DM_COPY Or DM_MODIFY)<0 Then
          MessageBox(0,'Ext Device Mode Hatasý-2','GENOTIP',mb_OK);
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
end.


