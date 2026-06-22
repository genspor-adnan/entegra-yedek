{********************************************************}
{*                 GenoTIP HBYS                          *}
{*               Kuruluş Sınıfları                       *}
{*                     v1.0                              *}
{*                                                       *}
{*                                                       *}
{* (c) Telif Hakkı 2009 Feta Bilgisayar                  *}
{********************************************************}

unit FetaKurulusSiniflari;

interface
uses
  SysUtils,Classes,Windows,Messages,Contnrs, RichEdit, ComCtrls,
  Controls, Grids, DBGrids, DBCtrls, ExtCtrls, ActiveX, DB, UFDCompatHelpers, FireDAC.Comp.Client, Graphics,
  StdCtrls, JvRichEdit, Forms, DateUtils, Dialogs, Variants, Generics.Collections;
type

  TFrameClass = class of TFrame;

  Pdizi = array[0..255] of Byte;

  DosyaSistemi = class
  public
    type
      Dizin = class
      public
        class procedure ŞuAnkiDizindekiDosyalar(AUzanti : string;AListe: TStrings);
        class procedure DizindekiDosyalar(AramaFiltresi : string;AListe: TStrings);
      end;
    class procedure TumMetniYaz(ADosyaAdi: string;AIcerik: string);
    class function TumMetniOku(ADosyaAdi: string): string;
    class function SurumBilgisi(ADosyaAdi: string;ABuildNoYok: Boolean = False;AAyirac: String='.';ASifirYok: Boolean = False) : string;
    class function SurumBilgisiEx(ADosyaAdi: string;
      ASifirDegerleri: array of integer;
      ABuildNoYok: Boolean = False;
      AAyirac: String='.') : string;
    class procedure TumunuSil(AYol,AMaske :string);
    class procedure Sil(ADosya: string);
    class function SistemDizini : string;
    class function TempDizini   : string;
    class function DosyaKullaniliyorMu(ADosyaAdi : string): Integer;
    class function UzantisizDosyaAdi(ADosyaAdi: string): string;
  end;

  AgSistemi = class
  public
    class function MACAdresiniGetir: string;
  end;

  GtpLog = class
  public
    class procedure Log(AMsg: string;AParams: array of const);overload;
    class procedure Log(AMsg: string);overload;

  end;

  Dize = class
  public
    class function SinirlandirilmisMetin(var AKaynak : string): string;overload;
    class function SinirlandirilmisMetin(var AKaynak : string;AAyirac: string): string;overload;
    class function SinirlandirilmisMetinEx(var AKaynak : string;AAyirac: string): string;
    class function BuyukKarakterTurkce(AKarakter: Char): Char;
    class function BuyukHarfTurkce(AKaynak: string): string;
    class function TurkceDizedenIngilizceDizeye(AKaynak: string): string;
    class function StringListOlarak(AKaynak: string;AAyirac: string = ';'): TStringList;
    class function IlkHarfleriBuyuk(AKaynak: string;ABosluklaAyir : Boolean = False): string;
    class function IlkHarfiKucuk(AKaynak: string): string;
    class function BunlardanBiriVarMi(AKaynak: string;AListe: array of string): Boolean;
    class function BunlardanBiriniIceriyorMu(AKaynak: string;AListe: array of string): Boolean;
    class function AltDize(AKaynak: string;ABaslangic: Integer;ANeKadar: Integer = 0) : string;
    class function Sec(AIndex: Integer;ADegerler: array of string): string;
    class function Varsayilan(AKaynak: string;AEgerBosIse: string): string;
    class function Hangisi(AAranacak: string;ADegerler: array of string): Integer;
    class function EllipsisOlarakKirp(AKaynak: string;ASinirUzunluk: Integer): string;
    class function TerstenAra(AAranan,AKaynak: string): Integer;
    class function TerstenSil(ADize: string;ASayi : Integer): string;
    class function SqlBicimle(ASql: string; paramNames: array of string; params: array of variant): string;
    class function Birlestir(AAyirici: string;AParamList : array of Variant) : string;
    class function SatirSonuEncode(AStr : string): string;
    class function SatirSonuDecode(AStr: string): string;
  end;

  Dizi = class
  public
    class function Birlestir(ADizeArray: array of string;AAyirici: string): string;
  end;

  SayiYonetimi = class
  public
    class function SifirliYaz(ADeger : Integer;ARakamSayisi: Byte): string;
    class function MaxInt(A,B : Integer): Integer;
    class function MinInt(A,B : Integer): Integer;
    class function BunlardanBiriVarMı(ADeğer: Integer;
      ADeğerler: array of Integer): Boolean;
  end;

  KullaniciArayuzu = class
  public
    type
      ZenginMetin = class
      public
        class procedure YerineKoy(ARichEdit : TRichEdit;AParametre: string;ADeger: string);
        class function ParametreBul(ARichEdit: TRichEdit;
          AMetin: string;AStartPos: Integer;var APos: integer): Integer;overload;
        class function ParametreBul(ARichEdit: TRichEdit;
          AMetin: string;var APos: integer): Integer;overload;
        class function ParametreBul_Jv(ARichEdit: TJvCustomRichEdit;
          AMetin: string;var APos: integer): Integer;
        class function StringGriddenRTFKoda(Baslik: string;grid : TStringGrid): string;
        class function DbGriddenRTFKoda(ABaslik,ABlokAdi: string;AGrid : TDBGrid;
          ExtraAlanlar: array of string): string;
        class function DbTablodanRTFKoda(ATitle,ABlockName: string;
          ATable: TDataset;Fields: array of string;
          ColumnWidths: array of integer): string;
        class procedure BosluklariKirp(AEditor: TRichEdit);
        class function BlokSil(AEditor: TCustomRichEdit;ABlokAdi: string): Boolean;
        class function ResimOlarak(ARichEdit: TRichEdit;AGenislik,
          AYukseklik: Integer): TObjectList;
      end;
      Menuler = class
      public
        class function KisayoluSil(ABaslik: string): string;
      end;
    class function DizedenBilesene(ADize: string): TComponent;overload;
    class function DizedenBilesene(AOrnek: TComponent;ADize: string): TComponent;overload;
    class function BilesendenDizeye(ABilesen: TComponent): string;
    class function DenetimdenMetne(ADenetim: TComponent): string;

    class procedure DenetimleriAcKapat(AAnaDenetim: TWinControl;AAcikKapali: Boolean);
    class function BilesenBul(AAranan: string;AKokBilesen: TComponent): TComponent;
    class function GercekGenislik(ADenetim: TWinControl): Integer;
    class function GercekUzunluk(ADenetim: TWinControl): Integer;
    class function CmToPixelToCm(Canvas: TCanvas; Cm: Real; YatayDusey,
      CmPixel: Integer): Real;
    class procedure DenetimCiziminiKilitle(ADenetim: TWinControl;AKilitle: Boolean);
  end;

  Kültür = class
  public
    class function IkiHarfliDilAdi : string;
  end;

  OleNesnesi = class
  public
    class procedure OledenResime(AOleObject: IOleObject;AResim: TImage);
    class function OleGorunenAdi(const ASinifAdi: string): string;
  end;

  TSaatDeğeriniDeğiştir = (sddDeğişiklikYok,sddGünBaşıOlarak,sddGünSonuOlarak);

  TTarihSaatBiçimi = (tsbNormal,tsbSQL);

  TarihSaat = class
  public
    class function SqlTarihe(ATarih: TDateTime): string;
    class function SqlTarihZamana(ATarih: TDateTime): string;
    class function YasHesapla(Dtarih, Bugun: TDateTime; var YYil, YAy, YGun: Word) : string;
    class function TarihFarki(tarih1, tarih2: string): Integer;
    class function TarihDogruMu(ATarihStr: string): Boolean;
    class function TarihStringOlarak(ATarih: TDateTime): string;
    class function TarihSaatStringOlarak(ATarih: TDateTime;ATarihSaatBiçimi: TTarihSaatBiçimi = tsbNormal;
      ASaatDeğeriDeğişsin: TSaatDeğeriniDeğiştir = sddDeğişiklikYok): string;
    class function KüçükTarihSaatStringOlarak(ATarih: TDateTime;ATarihSaatBiçimi: TTarihSaatBiçimi = tsbNormal;
      ASaatDeğeriDeğişsin: TSaatDeğeriniDeğiştir = sddDeğişiklikYok): string;
    class function TarihFarkGunOlarak(ASimdi,ASonra: TDateTime;AOnceSonraEkle: Boolean = True): string;
  end;

  Veritabani = class
  private
  public
    class function KayitSayisi(ABaglanti : TFDConnection;ATabloAdi,AWhere :string; paramAdlari: array of string;ParamListesi: array of Variant): Integer;
    class function SorguBaslat(cnn : TFDConnection;sql: string; paramNames : array of string;params:array of variant; UseDataSource: TDataSource = nil) : TADOQuery;
    class function KomutBaslat(cnn : TFDConnection;sql: string; paramNames : array of string;params:array of variant; UseDataSource: TDataSource = nil) : TADOCommand;
    class function VeriVarMi(cnn: TFDConnection;ASQL: string; AParams: array of string;AParamValues: array of Variant): Boolean;overload;
    class function VeriVarMi(cnn: TFDConnection;ASQL: string; AParams: array of string;AParamValues: array of Variant; var AFirstColumn: Variant): Boolean;overload;
    class function TabloKayitSayisi(cnn: TFDConnection; ATableName: string): Integer;
    /// <summary>
    /// Kolon içindeki değerlerin en büyüğünü döndürür.
    /// </summary>
    /// <param name="cnn">Bağlantı nesnesi</param>
    /// <param name="TableName">Tablo adı</param>
    /// <param name="ColumnName">Kolon adı</param>
    /// <param name="WhereClause">Sorgunun WHERE kısmı</param>
    /// <returns>Sorgu içindeki kolonun en büyük değeri döner. Eğer sorgudan hiç kayıt dönmezse sonuç 0 döner. </returns>
    class function AlaninMaximumunuBul(cnn: TFDConnection; TableName, ColumnName, WhereClause: string): Integer;
    class function SqlTarihAralığı(ABaşlangıç, ABitiş: TDateTime; AKolonlar: array of string;ABetweenKullan: Boolean = True): string;
    class procedure TabloSatırlarınıKopyala(ABağlantı: TFDConnection; ATabloAdı, ADeğişecekAlan, AŞimdikiDeğeri, AİstenenDeğer : string);
    class function BasitKomutÇalıştır(cnn: TFDConnection;ASQL: string; AParamAdları: array of string;AParamDeğerleri: array of Variant; ASonuçDönecek : Boolean = False;AUseDataSource : TDataSource = nil): Variant;
    class function BağlantıDizesiDeğerDeğiştir(AKaynakDize: string; AAnahtar: string;ADeğer: string): string;
    class function BoşDataSet(ABağlantı: TFDConnection;ATabloAdi : string) : TADOQuery;
    class function IntegerListGetir(cnn: TFDConnection;ASql: string; AParamAdları: array of string;AParamDeğerleri: array of variant): TList<Integer>;
  end;

  SenaryoYönetimi = class
  public
    class function PascalKodunaDonustur(AKodlanmisDize: string): string;
    class function MetinDizeIsle(AKaynak: string;ADegiskenler: TStringList): string;
  end;

  Feta = class
  public
    type
      Hasta = class
      public
        class function TcKimlikDogrula(TCNo: Int64): Boolean;
      end;
    class function BaglantiDizesi : string;
    class function CrcHesapla(PSif: Pointer; Size: Integer): Word;
    class procedure Sifrele(Yon: Integer; PSif: Pointer; Size: Integer);
  end;



  TBasitTabloSatir = class;

  TBasitTabloSatirAlan = class(TObject)
  private
    FDeger: string;
    FAlan: string;
    FTablo: TBasitTabloSatir;
    FBlobDeger : TMemoryStream;
    FField: TField;
  public
    constructor Create(ATablo: TBasitTabloSatir;AAlanAdi: string);
    destructor Destroy;override;
    procedure Yapistir(AHedefDataSet: TDataSet);
    property Alan : string read FAlan write FAlan;
    property Deger : string read FDeger write FDeger;
    property Tablo : TBasitTabloSatir read FTablo;
    property BlobDeger : TMemoryStream read FBlobDeger;
    property Field : TField read FField;
  end;

  TBasitTabloSatir = class(TObject)
  private
    FAlanlar : TObjectList;
    FKaynakDataSet: TDataSet;
    function GetAlanDeger(AAlanAdi: string): string;
  public
    constructor Create(AKaynakDataSet: TDataSet);
    destructor Destroy;override;
    procedure Hazirla(AAlanListesi: array of string);
    procedure Yapistir(AHedefDataSet: TDataSet);
    class function Kopyala(ADataSet: TDataSet;AAlanListesi: array of string): TBasitTabloSatir;
    property Alan[AAlanAdi: string]: string read GetAlanDeger;
    property KaynakDataSet : TDataSet read FKaynakDataSet;
  end;

  TBasitTablo = class(TObject)
  private
    FSatirlar : TObjectList;
    FDataSet  : TDataSet;
    constructor Create(ADataSet: TDataSet);
    procedure Hazirla(AAlanListesi: array of string;ATumSatirlar: Boolean = False);
  public
    destructor Destroy;override;
    procedure TumunuYapistir(AHedefDataSet: TDataSet);
    procedure IlkSatiriYapistir(AHedefDataSet: TDataSet);

    class function TekSatirKopyala(ADataSet: TDataSet;AAlanListesi: array of string): TBasitTablo;
    class function TumTabloyuKopyala(ADataSet: TDataSet;AAlanListesi: array of string): TBasitTablo;
  end;

  { Doğrudan çağrılabilir işlev ve yordamlar }

  function IIf(condition: Boolean;IfTrue: string;IfFalse: string): string;overload;
  function IIf(condition: Boolean;IfTrue: Integer;IfFalse: Integer): Integer;overload;
  procedure LogEvent(AMsg: string;params: array of const);

implementation
uses
  JclStrings, SynRegExpr, Registry, StrUtils, FetaClassExtensions, NB30;

var
  PixPerInch: TPoint;

procedure LogEvent(AMsg: string;params: array of const);
begin
  OutputDebugString(PChar(Format(AMsg,params)));
end;


{$REGION 'RTF Destek Rutinleri'}
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
            Dize.SinirlandirilmisMetin(S)]);
        end
      else
        begin
          Dize.SinirlandirilmisMetin(S);
          Result := Result + Format( '%s%s\cell ', [ '',
            DataSet.FieldByName(Dize.SinirlandirilmisMetin(S)).AsString]);
        end;
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
            Dize.SinirlandirilmisMetin(S)]);
        end
      else
        begin
          Dize.SinirlandirilmisMetin(S);
          Result := Result + Format( '%s%s\cell ', [ '',
            ATable.FieldByName(S).AsString]);
        end;
    end;
end;

{$ENDREGION}

function IIf(condition: Boolean;IfTrue: Integer;IfFalse: Integer): Integer;overload;
begin
  if condition then
    Result := IfTrue
  else
    Result := IfFalse;
end;
                                                                                      
function IIf(condition: Boolean;IfTrue: string;IfFalse: string): string;overload;
begin
  if (condition) then
    Result := IfTrue
  else
    Result := IfFalse;
end;


{ DosyaSistemi }

class function DosyaSistemi.DosyaKullaniliyorMu(ADosyaAdi: string): Integer;
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
  DosError := FindFirst(ADosyaAdi, faArchive, DirInfo);
  if DosError = 0 then begin
    StrPCopy(Fn, ADosyaAdi);
    l := Windows._lopen(FN, OF_READ or OF_SHARE_EXCLUSIVE);
    if l = -1 then
      Result := 2
    else begin
      Result := 1;
      _LClose(l);
    end;
  end
  else
    Result := 0;

end;

class procedure DosyaSistemi.Sil(ADosya: string);
begin
  DeleteFile(PWideChar(ADosya));
end;

class function DosyaSistemi.SistemDizini: string;
var
  Bf: array[0..255] of Char;
begin
  GetSystemDirectory(Bf, 250);
  Result := StrPas(Bf);
end;

class function DosyaSistemi.SurumBilgisi(ADosyaAdi: string;ABuildNoYok: Boolean;AAyirac: String;ASifirYok: Boolean): string;
{ Helper function to get the actual file version information }
var
  Info: Pointer;
  InfoSize: DWORD;
  FileInfo: PVSFixedFileInfo;
  FileInfoSize: DWORD;
  Tmp: DWORD;
begin
  // Get the size of the FileVersionInformatioin
  InfoSize := GetFileVersionInfoSize(PChar(ADosyaAdi), Tmp);
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
    GetFileVersionInfo(PChar(ADosyaAdi), 0, InfoSize, Info);
    // Query the information for the version
    VerQueryValue(Info, '\', Pointer(FileInfo), FileInfoSize);
    // Now fill in the version information
    Result := SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionMS shr 16,IIf(ASifirYok,0,2)) + AAyirac;
    Result := Result + SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionMS and $FFFF,IIf(ASifirYok,0,2)) + AAyirac;
    Result := Result + SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionLS shr 16,IIf(ASifirYok,0,2)) + IIf(ABuildNoYok,'',AAyirac);
    if not ABuildNoYok then
      Result := Result + SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionLS and $FFFF,IIf(ASifirYok,0,4));
  finally
    FreeMem(Info, FileInfoSize);
  end;

end;

class function DosyaSistemi.SurumBilgisiEx(ADosyaAdi: string;
      ASifirDegerleri: array of integer;
      ABuildNoYok: Boolean = False;
      AAyirac: String='.'): string;
{ Helper function to get the actual file version information }
var
  Info: Pointer;
  InfoSize: DWORD;
  FileInfo: PVSFixedFileInfo;
  FileInfoSize: DWORD;
  Tmp: DWORD;
begin
  // Get the size of the FileVersionInformatioin
  InfoSize := GetFileVersionInfoSize(PChar(ADosyaAdi), Tmp);
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
    GetFileVersionInfo(PChar(ADosyaAdi), 0, InfoSize, Info);
    // Query the information for the version
    VerQueryValue(Info, '\', Pointer(FileInfo), FileInfoSize);
    // Now fill in the version information
    Result := SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionMS shr 16,ASifirDegerleri[0]) + AAyirac;
    Result := Result + SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionMS and $FFFF,ASifirDegerleri[1]) + AAyirac;
    Result := Result + SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionLS shr 16,ASifirDegerleri[2]) + IIf(ABuildNoYok,'',AAyirac);
    if not ABuildNoYok then
      Result := Result + SayiYonetimi.SifirliYaz(FileInfo.dwFileVersionLS and $FFFF,ASifirDegerleri[3]);
  finally
    FreeMem(Info, FileInfoSize);
  end;
end;

class function DosyaSistemi.TempDizini: string;
var
  Bf: array[0..255] of Char;
begin
  GetTempPath(255,Bf);
  Result := StrPas(Bf);
end;

class function DosyaSistemi.TumMetniOku(ADosyaAdi: string): string;
begin
  Result := FileToString(ADosyaAdi);
end;

class procedure DosyaSistemi.TumMetniYaz(ADosyaAdi, AIcerik: string);
begin
  StringToFile(ADosyaAdi,AIcerik);
end;

class procedure DosyaSistemi.TumunuSil(AYol, AMaske: string);
var
  SR: TSearchRec;
begin
  if (FindFirst(IncludeTrailingBackslash(AYol) + AMaske,faArchive,SR) = 0) then begin
    repeat
      if ((SR.Attr and faArchive) = faArchive) then
        begin
          SysUtils.DeleteFile(IncludeTrailingBackslash(AYol) +
            SR.Name);
        end;
    until SysUtils.FindNext(SR) <> 0;
    SysUtils.FindClose(SR);
  end;
end;

class function DosyaSistemi.UzantisizDosyaAdi(ADosyaAdi: string): string;
begin
  Result := ExtractFileName(ADosyaAdi);
  Result := Copy(Result, 1, Length(Result) - Length(ExtractFileExt(Result)));
end;

{ Dize }

class function Dize.AltDize(AKaynak: string; ABaslangic,
  ANeKadar: Integer): string;
begin
  if (ANeKadar > 0) then
    Result := Copy(AKaynak,ABaslangic,ANeKadar)
  else
    Result := Copy(AKaynak,ABaslangic,(Length(AKaynak) - ABaslangic) + 1);
end;

class function Dize.Birlestir(AAyirici: string;
  AParamList: array of Variant): string;
var
  i     : Integer;
begin
  Result := '';
  for I := 0 to Length(AParamList) - 1 do begin
    if I > 0 then Result := Result + AAyirici;
    Result := Result + AParamList[i];
  end;
end;

class function Dize.BunlardanBiriniIceriyorMu(AKaynak: string;
  AListe: array of string): Boolean;
var
  oge: string;
begin
  Result := False;
  for oge in AListe do begin
    if (Pos(oge, AKaynak) > 0) then begin
      Result := True;
      Exit;
    end;
  end;
end;

class function Dize.BunlardanBiriVarMi(AKaynak: string;
  AListe: array of string): Boolean;
var
  i : integer;
begin
  Result := False;
  for i := Low(AListe) to High(AListe) do
    if (AKaynak = AListe[i]) then begin
      Result := True;
      Exit;
    end;
end;

class function Dize.BuyukHarfTurkce(AKaynak: string): string;
var
  i : Integer;
begin
  Result := '';
  for i := 1 to Length(AKaynak) do
    Result := Result + BuyukKarakterTurkce(AKaynak[i]);
end;

class function Dize.BuyukKarakterTurkce(AKarakter: Char): Char;
begin
  case AKarakter of
    'ç': Result := 'Ç';
    'ö': Result := 'Ö';
    'ş': Result := 'Ş';
    'i': Result := 'İ';
    'ı': Result := 'I';
    'ğ': Result := 'Ğ';
    'ü': Result := 'Ü';
  else
    Result := Upcase(AKarakter);
  end;
end;

class function Dize.EllipsisOlarakKirp(AKaynak: string;
  ASinirUzunluk: Integer): string;
begin
  if (Length(AKaynak) > ASinirUzunluk) then
    Result := Copy(AKaynak,1,ASinirUzunluk - 3) + '...'
  else
    Result := AKaynak;
end;

class function Dize.Hangisi(AAranacak: string;
  ADegerler: array of string): Integer;
var
  i : integer;
begin
  Result := -1;
  for i := Low(ADegerler) to High(ADegerler) do
    if (AAranacak = ADegerler[i]) then
      begin
        Result := i;
        Exit;
      end;
end;

class function Dize.IlkHarfiKucuk(AKaynak: string): string;
begin
  if (Length(AKaynak) > 0) then
    AKaynak[1] := LowerCase(AKaynak)[1];
  Result := AKaynak;
end;

class function Dize.IlkHarfleriBuyuk(AKaynak: string;
  ABosluklaAyir: Boolean): string;

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
  //i : Integer;
  fp : Integer;
  //lp : Integer;
begin
  AKaynak := LowerCase(AKaynak);
  r := TRegExpr.Create;
  try
    if (Pos('_',AKaynak) = 0) then begin
      r.Expression := '((no)|(No)|(nO)|(NO))$';
      if (r.Exec(AKaynak)) then begin
        if (Length(AKaynak) > 2) then begin
          s := IlkHarfBuyuk(Copy(AKaynak,0,r.MatchPos[0] - 1)) + IIf(ABosluklaAyir,' ','') + 'No';
          Result := s;
        end else Result := IIf(ABosluklaAyir,' ','') + 'No';
      end else Result := IlkHarfBuyuk(AKaynak) + IIf(ABosluklaAyir,' ','');
    end else begin
      r.Expression := '_';
      r.InputString := AKaynak;
      s := '';
      fp := 1;
      while (r.ExecPos(fp)) do begin
        s := s + IlkHarfleriBuyuk(Copy(AKaynak,fp,r.MatchPos[0] - fp)) + IIf(ABosluklaAyir,' ','');
        fp := r.MatchPos[0] + 1;
      end;
      if (fp < Length(AKaynak)) then
        s := s + IlkHarfleriBuyuk(Copy(AKaynak,fp,100)) + IIf(ABosluklaAyir,' ','');
      Result := s;
    end;
  finally
    r.Free;
  end;

end;


class function Dize.SatirSonuDecode(AStr: string): string;
begin
  Result := StringReplace(StringReplace(AStr,#18,#13,[rfReplaceAll]),#19,#10,[rfReplaceAll]);
end;

class function Dize.SatirSonuEncode(AStr: string): string;
begin
  Result := StringReplace(StringReplace(AStr,#13,#18,[rfReplaceAll]),#10,#19,[rfReplaceAll]);
end;

class function Dize.Sec(AIndex: Integer; ADegerler: array of string): string;
begin
  if ((AIndex >= Low(ADegerler)) and (AIndex <= High(ADegerler))) then
    Result := ADegerler[AIndex]
  else
    Result := '';
end;

class function Dize.SinirlandirilmisMetin(var AKaynak: string;
  AAyirac: string): string;
begin
  if (Pos(AAyirac,AKaynak) > 0) then
    begin
      Result := Copy(AKaynak,1,Pos(AAyirac,AKaynak) - 1);
      Delete(AKaynak,1,Pos(AAyirac,AKaynak));
    end
  else
    begin
      Result := AKaynak;
      AKaynak := '';
    end;
end;

class function Dize.SinirlandirilmisMetinEx(var AKaynak: string;AAyirac: string): string;
begin
  Result := SinirlandirilmisMetin(AKaynak,AAyirac);
end;

class function Dize.SqlBicimle(ASql: string; paramNames: array of string;
  params: array of variant): string;
var
  i : Integer;
begin
  if (Length(params) > 0) then begin
    for i := Low(paramNames) to High(paramNames) do
      begin
        if ((VarType(params[i]) in [vtString,vtWideString,vtPChar,vtPWideChar,
          vtChar]) or (VarType(params[i]) = varString)) then
          ASql := StringReplace(ASql,paramNames[i],#39 + StringReplace(params[i],#39,#39#39,[rfReplaceAll]) + #39,[rfReplaceAll])
        else
          if Pos('*datetime*',paramNames[i]) > 0 then
            ASql := StringReplace(ASql,StringReplace(paramNames[i],'*datetime*','',[rfReplaceAll]),#39 + FormatDateTime('yyyymmdd hh:nn:ss.zzz',params[i]) + #39,[rfReplaceAll])
          else
            ASql := StringReplace(ASql,paramNames[i],params[i],[rfReplaceAll]);
      end;
  end;
  Result := ASql;
end;

class function Dize.SinirlandirilmisMetin(var AKaynak: string): string;
begin
  Result := SinirlandirilmisMetin(AKaynak,';');
end;

class function Dize.StringListOlarak(AKaynak: string;AAyirac: string): TStringList;
begin
  Result := TStringList.Create;
  while Length(AKaynak) > 0 do begin
    Result.Add(SinirlandirilmisMetin(AKaynak,AAyirac));
  end;
end;

class function Dize.TerstenAra(AAranan, AKaynak: string): Integer;
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
  k := length(AAranan) - 1;
  for i := length(AKaynak) - k downto 1 do
  begin
    for j := 0 to k do
    begin
      if AKaynak[i + j] <> AAranan[j + 1] then break;
      if j = k then
      begin
        result := i;
        exit;
      end;
    end;
  end;
end;

class function Dize.TerstenSil(ADize: string; ASayi: Integer): string;
begin
  Result := ADize;
  Delete(Result,Length(Result) - Pred(ASayi),ASayi);
end;

class function Dize.TurkceDizedenIngilizceDizeye(AKaynak: string): string;
var
  xi : Integer;
  ch, ch2 : Char;
begin
  AKaynak := Trim(AKaynak);
  FillChar(Result, Sizeof(Result), 0);
  for xi := 1 to length(AKaynak) do
    begin
      ch := AKaynak[xi];
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

class function Dize.Varsayilan(AKaynak, AEgerBosIse: string): string;
begin
  Result := IIf(Length(AKaynak) = 0,AEgerBosIse,AKaynak);
end;

{ KullaniciArayuzu.ZenginMetin }

class function KullaniciArayuzu.ZenginMetin.BlokSil(AEditor: TCustomRichEdit;
  ABlokAdi: string): Boolean;
var
  APos : Integer;
  ALastPos : Integer;
begin
  Result := False;
  APos := AEditor.FindText('>>' + ABlokAdi, 0, maxint, []);
  if (APos >= 0) then
    begin
      ALastPos := AEditor.FindText('<<' + ABlokAdi,APos + 2,MaxInt,[]);
      if (ALastPos >= 0) then
        begin
          AEditor.SelStart := APos;
          AEditor.SelLength := (ALastPos - APos) + Length(ABlokAdi) + 2;
          AEditor.SelText := '';
          Result := True;
          Exit;
        end;
    end;
end;

class procedure KullaniciArayuzu.ZenginMetin.BosluklariKirp(AEditor: TRichEdit);
var
  i : integer;
  a : Boolean;
begin
  a := True;
  for i := AEditor.Lines.Count - 1 downto 0 do
    if (Trim(AEditor.Lines[i]) = '') and A then
      AEditor.Lines.Delete(i)
    else
      if ((Trim(AEditor.Lines[i]) <> '') and A) then
        Break;
end;

class function KullaniciArayuzu.ZenginMetin.DbGriddenRTFKoda(ABaslik,
  ABlokAdi: string; AGrid: TDBGrid; ExtraAlanlar: array of string): string;
function GetVisibleColumnCount: integer;
  var
    i : Integer;
  begin
    Result := 0;
    for i := 0 to AGrid.Columns.Count - 1 do
      if (AGrid.Columns[i].Visible) then
        Result := Result + 1;
  end;
var
  ColHeader : String;
  i         : integer;
  x         : integer;
  temp      : integer;
  AFont     : TFont;
begin
            // *** Standard Headers ***
  Result := Result + '{\rtf1\ansi\ansicpg1254\deff0\deflang1055\deff0\deftab720'#13#10 ;

           // *** Font Table ***
  AFont := TFont.Create;
  try
    AFont.Assign(AGrid.Font);
    AFont.Name := 'Times New Roman';
    AFont.Size := 12;
    Afont.Style := [fsBold];

    Result := Result + '{\fonttbl' ;
    Result := Result + GetRTFFont( 0, AGrid.Font ) ;
    Result := Result + GetRTFFont( 1, AGrid.Font ) ;
    Result := Result + GetRTFFont( 2, AGrid.Font ) ;
    Result := Result + GetRTFFont( 3, AFont );
    Result := Result + GetRTFFont( 4, AFont ) + '}'#13#10;

             // *** Color Table ***

    Result := Result + '{\colortbl' ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clBlack ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clWhite ) ;
    Result := Result + GetRTFColor( clSilver );
    Result := Result + GetRTFColor( clNavy ) + '}'#13#10 ;

    if (Length(ABlokAdi) > 0) then
      Result := Result + '{\*\v >>'+ABlokAdi+'}';
    if (Length(ABaslik) > 0) then
      Result := Result + Format( '\par \par \pard\plain\f3%s\cf6 %s'#13#10, [ GetRTFFontInfo( AFont ),
         '             -------  '+ABaslik+'  -------\par' ] );
    Result := Result + Format( '\margl%d\margr%d\margt%d\margb%d', [ 461, 562, 101,101 ] ) ;
    // Başlık Bilgisi

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
    ColHeader :=  GetDBGridCells( AGrid, True, ExtraAlanlar );
    Result := Result + '\trowd\trgaph108\trrh260\trleft0';
    temp := 0;
    for i := 0 to AGrid.Columns.Count - 1 do
      begin
        if (AGrid.Columns[i].Visible) then begin
          Result := Result + '\clvertalc';
          Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
          Result := Result + ' \clcbpat5' ;
          Temp := Temp + AGrid.Columns[i].Width + 8;
          Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
            + 108.0));
        end;
      end;
    for i := 0 to Length(ExtraAlanlar) - 1 do
      begin
        Result := Result + '\clvertalc';
        Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
        Result := Result + ' \clcbpat5' ;
        Temp := Temp + 101;
        Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
          + 108.0));
      end;

    Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl' ;
    AGrid.Font.Style := [fsBold];
    Result := Result + Format( ' {\f1%s\cf1\cgrid0 ', [ GetRTFFontInfo( AGrid.Font ) ] ) ;
    AGrid.Font.Style := [];
    Result := Result + ColHeader;
    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    AGrid.DataSource.DataSet.First;

    while not AGrid.DataSource.DataSet.Eof do
      begin
        Result := Result + '\trowd\trgaph108\trrh260\trleft0' ;
        Temp := 0;
        For X := 0 To AGrid.Columns.Count - 1 Do
        Begin
          if (AGrid.Columns[X].Visible) then begin
            Result := Result + '\clvertalc' ;
            Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
            Result := Result + ' \clcbpat4' ;
            Temp := Temp + AGrid.Columns[X].Width + 8;
            Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
              + 108.0));
          end;
        End;
        for i := 0 to Length(ExtraAlanlar) - 1 do
          begin
            Result := Result + '\clvertalc';
            Result := Result + '\clbrdrt\brdrs\brdrw10\clbrdrl\brdrs\brdrw10\clbrdrb\brdrs\brdrw10\clbrdrr\brdrs\brdrw10' ;
            Result := Result + ' \clcbpat4' ;
            Temp := Temp + 101;
            Result := Result + '\cltxlrtb\cellx' + IntToStr(Round((Temp / Screen.pixelsperinch * 1440.0)
              + 108.0));
          end;
        Result := Result + '\pard\ri-123\nowidctlpar\widctlpar\intbl\adjustright' ;
        Result := Result + Format( ' {\f2%s\cf2\cgrid0 ', [ GetRTFFontInfo( AGrid.Font ) ] );
        Result := Result + GetDBGridCells(AGrid, False, ExtraAlanlar);
        Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
        AGrid.DataSource.DataSet.Next;
      end;
//    Result := Result + '}\pard \nowidctlpar\widctlpar\intbl\adjustright {\row}'#13#10;
    Result := Result + '\pard\nowidctlpar\widctlpar\adjustright {'#13#10;
    if (Length(ABlokAdi) > 0) then
      Result := Result + '{\*\v <<'+ABlokAdi+'}';
    Result := Result + '}}';
  finally
    AFont.Free;
  end;

end;

class function KullaniciArayuzu.ZenginMetin.DbTablodanRTFKoda(ATitle,
  ABlockName: string; ATable: TDataset; Fields: array of string;
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
    blockFont.Color := clBlack;
    blockFont.Size := 0;

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
    if (Length(ABlockName) > 0) then
      Result := Result + '{\*\v >>'+ABlockName+'}';
    // Başlık Bilgisi
    if (Length(ATitle) > 0) then
      Result := Result + Format( '\pard\plain\f3%s\cf6 %s'#13#10, [ GetRTFFontInfo( AFont ),
         '             -------  ' + ATitle + '  -------\par' ] );
    Result := Result + Format( '\margl%d\margr%d\margt%d\margb%d', [ 461, 562, 101,101 ] ) ;

    
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
    if (Length(ABlockName) > 0) then
      Result := Result + '{\*\v <<'+ABlockName+'}';
    Result := Result + '}}';
  finally
    AFont.Free;
    blockFont.Free;
    gridFont.Free;
  end;
end;

class function KullaniciArayuzu.ZenginMetin.ParametreBul(ARichEdit: TRichEdit;
  AMetin: string; AStartPos: Integer; var APos: integer): Integer;
begin
  APos := ARichEdit.FindText(AMetin,AStartPos,MaxInt,[]);
  Result := APos;
end;

class function KullaniciArayuzu.ZenginMetin.ParametreBul(ARichEdit: TRichEdit;
  AMetin: string; var APos: integer): Integer;
begin
  Result := ParametreBul(ARichEdit,AMetin,0,APos);
end;

class function KullaniciArayuzu.ZenginMetin.ParametreBul_Jv(
  ARichEdit: TJvCustomRichEdit; AMetin: string; var APos: integer): Integer;
begin
  APos := ARichEdit.FindText(AMetin,0,MaxInt,[]);
  Result := APos;
end;

class function KullaniciArayuzu.ZenginMetin.ResimOlarak(ARichEdit: TRichEdit;
  AGenislik, AYukseklik: Integer): TObjectList;

var
  range         : TFormatRange;

  function YeniBmp(AListe : TObjectList) : TBitmap;
  begin
    Result := TBitmap.Create;
    Result.Canvas.Brush.Color := clWhite;
    Result.Width := AGenislik;
    Result.Height := AYukseklik;
    AListe.Add(Result); 
    // Rendering to the same DC we are measuring.
    Range.hdc        := Result.Canvas.handle;
    Range.hdcTarget  := Result.Canvas.Handle;
  end;

var
  ABmp          : TBitmap;
  SonKarakter   : Integer;
  KarakterSayisi: Integer;
  rectSakla     : TRect;
begin
  FillChar(Range, SizeOf(TFormatRange), 0);

  // Set up the page.
  Range.rc.left    := 0;
  Range.rc.top     := 0;
  Range.rc.right   := AGenislik * 1440 div Screen.PixelsPerInch;
  Range.rc.Bottom  := AYukseklik * 1440 div Screen.PixelsPerInch;
  rectSakla := Range.rc;
  // Default the range of text to print as the entire document.
  Range.chrg.cpMax := -1;
  Range.chrg.cpMin := 0;

  // Free cached information
  SendMessage(ARichEdit.handle, EM_FORMATRANGE, 0,0);

  Result := TObjectList.Create;
  ABmp := YeniBmp(Result);

  KarakterSayisi := ARichEdit.GetTextLen;

  SonKarakter := 0;
  try
    repeat
      Range.rc := rectSakla;
      Range.chrg.cpMin := SonKarakter;
      // format the text
      SonKarakter := SendMessage(ARichedit.Handle, EM_FORMATRANGE, 1, Longint(@Range));
      if (SonKarakter < KarakterSayisi) and (SonKarakter <> -1) then YeniBmp(Result);
    until (SonKarakter >= KarakterSayisi) or (SonKarakter = -1);
  finally
    // Free cached information
    SendMessage(ARichEdit.handle, EM_FORMATRANGE, 0,0);
  end;
end;

class function KullaniciArayuzu.ZenginMetin.StringGriddenRTFKoda(Baslik: string;
  grid: TStringGrid): string;
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
       '             -------  '+Baslik+'  -------\par' ] );
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

class procedure KullaniciArayuzu.ZenginMetin.YerineKoy(ARichEdit: TRichEdit;
  AParametre, ADeger: string);
var
  APos : integer;
  AName: string;
begin
  AName := '$' + AParametre + '$';
  while (ParametreBul(ARichEdit,AName,APos) > -1) do
    begin
      ARichEdit.SelStart := APos;
      ARichEdit.SelLength := Length(AName);
      ARichEdit.SelText := ADeger;
    end;

end;

{ KullaniciArayuzu }

class function KullaniciArayuzu.BilesenBul(AAranan: string;
  AKokBilesen: TComponent): TComponent;
var
  i : integer;
begin
  Result := nil;
  if (not Assigned(AKokBilesen)) then Exit;
  if (AKokBilesen.ComponentCount > 0) then
    begin
      for i := 0 to AKokBilesen.ComponentCount - 1 do
        begin
          if (AKokBilesen.Components[i].ComponentCount > 0) then
            begin
              Result := BilesenBul(AAranan,AKokBilesen.Components[i]);
              if (Assigned(Result)) then Exit;
            end
          else
            if (AKokBilesen.Components[i].Name = AAranan) then
              begin
                Result := AKokBilesen.Components[i];
                Exit
              end;
        end;
    end;
  if (AKokBilesen.Name = AAranan) then
    begin
      Result := AKokBilesen;
      Exit;
    end;
end;

class function KullaniciArayuzu.BilesendenDizeye(ABilesen: TComponent): string;
var
  BinStream:TMemoryStream;
  StrStream: TStringStream;
begin
  BinStream := TMemoryStream.Create;
  try
    StrStream := TStringStream.Create('');
    try
      BinStream.WriteComponent(ABilesen);
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


class function KullaniciArayuzu.CmToPixelToCm(Canvas: TCanvas; Cm: Real;
  YatayDusey, CmPixel: Integer): Real;
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

class procedure KullaniciArayuzu.DenetimCiziminiKilitle(ADenetim: TWinControl;
  AKilitle: Boolean);
begin
  if (ADenetim = nil) or (ADenetim.Handle = 0) then Exit;
  if AKilitle then
    SendMessage(ADenetim.Handle, WM_SETREDRAW, 0, 0)
  else
  begin
    SendMessage(ADenetim.Handle, WM_SETREDRAW, 1, 0);
    RedrawWindow(ADenetim.Handle, nil, 0,
    RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
  end;
end;

class function KullaniciArayuzu.DenetimdenMetne(ADenetim: TComponent): string;
begin
  Result := '';
  if (not Assigned(ADenetim)) then Exit;
  if (ADenetim is TEdit) then
    Result := TEdit(ADenetim).Text
  else
    if (ADenetim is TComboBox) then
      Result := TComboBox(ADenetim).Text
    else
      if (ADenetim is TMemo) then
        Result := TMemo(ADenetim).Text
      else
        if (ADenetim is TGroupBox) then
          Result := TGroupBox(ADenetim).Caption
        else
          if (ADenetim is TRadioButton) then
            Result := TRadioButton(ADenetim).Caption
          else
            if (ADenetim is TCheckBox) then
              Result := TCheckBox(ADenetim).Caption;
end;

class procedure KullaniciArayuzu.DenetimleriAcKapat(AAnaDenetim: TWinControl;
  AAcikKapali: Boolean);
var
  i : integer;
begin
  AAnaDenetim.Enabled := AAcikKapali;
  for i := 0 to AAnaDenetim.ControlCount - 1 do
    AAnaDenetim.Controls[i].Enabled := AAcikKapali;
  AAnaDenetim.Repaint;
end;

class function KullaniciArayuzu.DizedenBilesene(AOrnek: TComponent;
  ADize: string): TComponent;
var
  StrStream:TStringStream;
  BinStream: TMemoryStream;
begin
  StrStream := TStringStream.Create(ADize);
  try
    BinStream := TMemoryStream.Create;
    try
      ObjectTextToBinary(StrStream, BinStream);
      BinStream.Seek(0, soFromBeginning);
      Result := BinStream.ReadComponent(AOrnek);
    finally
      BinStream.Free;
    end;
  finally
    StrStream.Free;
  end;
end;

class function KullaniciArayuzu.DizedenBilesene(ADize: string): TComponent;
begin
  Result := DizedenBilesene(nil,ADize);
end;

class function KullaniciArayuzu.GercekGenislik(ADenetim: TWinControl): Integer;
var
  i : Integer;
  gen: Integer;
begin
  Result := -MaxInt;
  for i := 0 to ADenetim.ControlCount - 1 do begin
    if ADenetim.Controls[i].Visible then begin
      gen := ADenetim.Controls[i].Left + ADenetim.Controls[i].Width;
      if gen > Result  then
        Result := gen;
    end;
  end;
end;

class function KullaniciArayuzu.GercekUzunluk(ADenetim: TWinControl): Integer;
var
  i : Integer;
  gen: Integer;
begin
  Result := 0;
  for i := 0 to ADenetim.ControlCount - 1 do begin
    if ADenetim.Controls[i].Visible then begin
      gen := ADenetim.Controls[i].Top + ADenetim.Controls[i].Height;
      if gen > Result  then
        Result := gen;
    end;
  end;
end;

{ OleNesnesi }

function HimetricToPixels(const P: TPoint): TPoint;
begin
  Result.X := MulDiv(P.X, PixPerInch.X, 2540);
  Result.Y := MulDiv(P.Y, PixPerInch.Y, 2540);
end;

class procedure OleNesnesi.OledenResime(AOleObject: IOleObject; AResim: TImage);
var
  //ViewObject2: IViewObject2;
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
  AResim.Picture.Assign(Bitmap); 
end;

class function OleNesnesi.OleGorunenAdi(const ASinifAdi: string): string;
var
  reg : TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    if (reg.OpenKey(ASinifAdi,False)) then begin
      Result := reg.ReadString('');
      reg.CloseKey;
    end else
      Result := '';
  finally
    reg.Free;
  end;
end;

{ TarihSaat }

class function TarihSaat.KüçükTarihSaatStringOlarak(ATarih: TDateTime;
  ATarihSaatBiçimi: TTarihSaatBiçimi;
  ASaatDeğeriDeğişsin: TSaatDeğeriniDeğiştir): string;
var
  fmt : string;
begin
  case ATarihSaatBiçimi of
    tsbNormal: fmt := 'dd/mm/yyyy';
    tsbSQL: fmt := 'yyyy-mm-dd';
  end;
  case ASaatDeğeriDeğişsin of
    sddDeğişiklikYok: Result := FormatDateTime(fmt + ' hh:nn', ATarih);
    sddGünBaşıOlarak: Result := FormatDateTime(fmt + ' 00:00', ATarih);
    sddGünSonuOlarak: Result := FormatDateTime(fmt + ' 23:59', ATarih);
  end;
end;

class function TarihSaat.SqlTarihe(ATarih: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd 00:00:00',ATarih);
end;

class function TarihSaat.SqlTarihZamana(ATarih: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss',ATarih);
end;

class function TarihSaat.TarihDogruMu(ATarihStr: string): Boolean;
begin
  Result := True;
  //ShortDateFormat := 'dd/MM/YYYY';
  try
    StrToDate(ATarihStr);
  except
    on exception do Result := False;
  end;
end;

class function TarihSaat.TarihFarkGunOlarak(ASimdi, ASonra : TDateTime;
  AOnceSonraEkle: Boolean): string;
var
  fark : Integer;
begin
  fark := DaysBetween(ASimdi,ASonra);
  if AOnceSonraEkle then begin
    if ASonra > ASimdi then
      Result := Format('%d gün sonra',[Abs(fark)])
    else
      Result := Format('%d gün önce',[Abs(fark)])
  end else Result := IntToStr(fark);
end;

class function TarihSaat.TarihFarki(tarih1, tarih2: string): Integer;
var
  t1, t2: TDateTime;
begin
  TarihFarki := 0;
  try
    t1 := StrToDateTime(FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', StrToDateTime(tarih1)));
    t2 := StrToDateTime(FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', StrToDateTime(tarih2)));
  except
    on exception do
      Exit;
  end;
  TarihFarki := StrToInt(FloatToStr(Abs(t2 - t1)));
end;

class function TarihSaat.TarihSaatStringOlarak(ATarih: TDateTime;
  ATarihSaatBiçimi: TTarihSaatBiçimi;
  ASaatDeğeriDeğişsin: TSaatDeğeriniDeğiştir): string;
var
  fmt : string;
begin
  case ATarihSaatBiçimi of
    tsbNormal: fmt := 'dd/mm/yyyy';
    tsbSQL: fmt := 'yyyy-mm-dd';
  end;
  case ASaatDeğeriDeğişsin of
    sddDeğişiklikYok: Result := FormatDateTime(fmt + ' hh:nn:ss', ATarih);
    sddGünBaşıOlarak: Result := FormatDateTime(fmt + ' 00:00:00', ATarih);
    sddGünSonuOlarak: Result := FormatDateTime(fmt + ' 23:59', ATarih);
  end;
end;

class function TarihSaat.TarihStringOlarak(ATarih: TDateTime): string;
begin
  Result := FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', ATarih);
end;

class function TarihSaat.YasHesapla(Dtarih, Bugun: TDateTime;
  var YYil, YAy, YGun: Word): string;
var t3: TDateTime;
begin
  if FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', Bugun) = FormatDateTime('DD'+FormatSettings.DateSeparator+'MM'+FormatSettings.DateSeparator+'YYYY', DTarih) then begin
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
end;

{ Veritabani }

class function Veritabani.AlaninMaximumunuBul(cnn: TFDConnection; TableName,
  ColumnName, WhereClause: string): Integer;
var
  qry : TADOQuery;
begin
  qry := Veritabani.SorguBaslat(cnn,Format(
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

class function Veritabani.BasitKomutÇalıştır(cnn: TFDConnection;
  ASQL: string; AParamAdları: array of string;
  AParamDeğerleri: array of Variant;ASonuçDönecek : Boolean;
  AUseDataSource: TDataSource): Variant;
var
  LSQL: string;
  LQry: TFDQuery;
begin
  if ASonuçDönecek then
    LSQL := ASQL
  else
    LSQL := 'SET NOCOUNT ON; ' + ASQL;

  LQry := SorguBaslat(cnn,LSQL,AParamAdları,AParamDeğerleri,AUseDataSource);

  try
    if ASonuçDönecek then
    begin
      LQry.Open;
      if not LQry.Eof then
        Result := LQry.Fields[0].AsVariant
      else
        Result := Null;
    end
    else
    begin
      LQry.ExecSQL;
      Result := Null;
    end;
  finally
    LQry.Free;
  end;
end;

class function Veritabani.BağlantıDizesiDeğerDeğiştir(AKaynakDize,
  AAnahtar, ADeğer: string): string;
var
  cs : TStringList;
begin
  cs := TStringList.Create;
  try
    cs.LoadFromString(AKaynakDize,';');
    cs.Values[AAnahtar] := ADeğer;
    Result := cs.Join(';');
  finally
    cs.Free;
  end;
end;

class function Veritabani.BoşDataSet(ABağlantı: TFDConnection;ATabloAdi: string): TADOQuery;
begin
  Result := SorguBaslat(ABağlantı,'SELECT TOP 0 * FROM ' + ATabloAdi,[],[]);
end;

class function Veritabani.IntegerListGetir(cnn: TFDConnection; ASql: string;
  AParamAdları: array of string;
  AParamDeğerleri: array of variant): TList<Integer>;
begin
  Result := TList<Integer>.Create;
  with SorguBaslat(cnn, ASql, AParamAdları, AParamDeğerleri) do
    try
      Open;
      while not Eof do begin
        Result.Add(AsInteger[0]);
        Next;
      end;
    finally
      Free;
    end;
end;

class function Veritabani.KayitSayisi(ABaglanti: TFDConnection; ATabloAdi,
  AWhere: string; paramAdlari: array of string;
  ParamListesi: array of Variant): Integer;
begin
  Result := 0;
  with SorguBaslat(ABaglanti,'SELECT count(*) FROM ' + ATabloAdi +
    IIf(AWhere <> '',' WHERE ' + AWhere,''),paramAdlari,ParamListesi) do
  try
    Open;
    Result := Fields[0].AsInteger;
  finally
    Free;
  end;
end;

class function Veritabani.KomutBaslat(cnn: TFDConnection; sql: string;
  paramNames: array of string; params: array of variant;
  UseDataSource: TDataSource): TADOCommand;
begin
  Result := TADOCommand.Create(nil);
  Result.Connection := cnn;
  Result.InitCommand(Sql,paramNames,params,UseDataSource);
end;

class function Veritabani.SorguBaslat(cnn: TFDConnection; sql: string;
  paramNames: array of string; params: array of variant;
  UseDataSource: TDataSource): TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := cnn;
  Result.CommandTimeout := 12000;
  Result.InitSql(Sql,paramNames,params,UseDataSource);
end;

class function Veritabani.SqlTarihAralığı(ABaşlangıç, ABitiş: TDateTime;
  AKolonlar: array of string; ABetweenKullan: Boolean): string;
begin
  if Length(AKolonlar) > 1 then
    Result := Format('%s >= %s AND %s <= %s',[
      AKolonlar[0],
      TarihSaat.TarihSaatStringOlarak(ABaşlangıç,tsbSQL,sddGünBaşıOlarak),
      AKolonlar[1],
      TarihSaat.TarihSaatStringOlarak(ABitiş,tsbSQL,sddGünSonuOlarak)
    ])
  else if ABetweenKullan then
    Result := Format('%0:s BETWEEN %1:s AND %2:s',[
      AKolonlar[0],
      TarihSaat.TarihSaatStringOlarak(ABaşlangıç,tsbSQL,sddGünBaşıOlarak),
      TarihSaat.TarihSaatStringOlarak(ABitiş,tsbSQL,sddGünSonuOlarak)
    ])
  else
    Result := Format('%0:s >= %1:s AND %0:s <= %2:s',[
      AKolonlar[0],
      TarihSaat.TarihSaatStringOlarak(ABaşlangıç,tsbSQL,sddGünBaşıOlarak),
      TarihSaat.TarihSaatStringOlarak(ABitiş,tsbSQL,sddGünSonuOlarak)
    ]);
end;

class function Veritabani.TabloKayitSayisi(cnn: TFDConnection;
  ATableName: string): Integer;
begin
  with SorguBaslat(cnn,'SELECT COUNT(*) FROM ' + ATableName,[],[]) do
  try
    Open;
    Result := Fields[0].AsInteger;
    Close;
  finally
    Free;
  end;
end;

class procedure Veritabani.TabloSatırlarınıKopyala(ABağlantı: TFDConnection;ATabloAdı,
  ADeğişecekAlan, AŞimdikiDeğeri, AİstenenDeğer: string);
var
  fld : string;
  lst : TStringList;
  _out : string;
  değer : string;
  stringAlan: Boolean;
begin
  lst := TStringList.Create;
  with FetaKurulusSiniflari.Veritabani.SorguBaslat(ABağlantı,'SELECT c.name,t.name as tip FROM '+
    'syscolumns c inner join systypes t on t.xtype = c.xtype WHERE '+
    'c.id = OBJECT_ID(&1) ORDER BY c.colorder',['&1'],[ATabloAdı]) do
  try
    Open;
    _out := '';
    Locate('name',ADeğişecekAlan,[]);
    stringAlan := Dize.BunlardanBiriVarMi(Fields[1].AsString,
      ['varchar','nvarchar','char','nchar']);
    { INSERT için alanları topluyoruz }
    Fields[0].CopyAllRowsToStringList(lst);
    fld := lst.Join(',');
    _out := Format('INSERT INTO %s (%s)',[ATabloAdı,fld]);
    { SELECT için ayarlamalar yapıyoruz }
    if stringAlan then
      değer := '''' + AİstenenDeğer + ''''
    else
      değer := AİstenenDeğer;
    değer := değer + ' AS ' + ADeğişecekAlan;
    lst.Change(ADeğişecekAlan,değer);
    if stringAlan then
      değer := '''' + AŞimdikiDeğeri + ''''
    else
      değer := AŞimdikiDeğeri;
    _out := _out + Format('SELECT %s FROM %s WHERE %s = %s',
      [lst.Join(','),ATabloAdı,ADeğişecekAlan,değer]);
    ABağlantı.ExecSQL(_out);
  finally
    Free;
    lst.Free;
  end;

end;

class function Veritabani.VeriVarMi(cnn: TFDConnection; ASQL: string;
  AParams: array of string; AParamValues: array of Variant;
  var AFirstColumn: Variant): Boolean;
var
  tmp : TADOQuery;
begin
  tmp := SorguBaslat(cnn,ASQL,AParams,AParamValues);
  try
    tmp.Open;
    Result := not tmp.IsEmpty;
    if Result then
      AFirstColumn := tmp.Fields[0].AsVariant;
  finally
    tmp.Free;
  end;
end;

class function Veritabani.VeriVarMi(cnn: TFDConnection; ASQL: string;
  AParams: array of string; AParamValues: array of Variant): Boolean;
var
  tmp : TADOQuery;
begin
  tmp := SorguBaslat(cnn,ASQL,AParams,AParamValues);
  try
    tmp.Open;
    Result := not tmp.IsEmpty;
  finally
    tmp.Free;
  end;
end;

{ KullaniciArayuzu.Menuler }

class function KullaniciArayuzu.Menuler.KisayoluSil(ABaslik: string): string;
begin
  Result := StringReplace(ABaslik,'&','',[rfReplaceAll]);
end;

{ SayiYonetimi }

class function SayiYonetimi.BunlardanBiriVarMı(ADeğer: Integer;
  ADeğerler: array of Integer): Boolean;
var
  değer : Integer;
begin
  Result := False;
  for değer in ADeğerler do
    if ADeğer = değer then begin
      Result := True;
      Exit;
    end;
end;

class function SayiYonetimi.MaxInt(A, B: Integer): Integer;
begin
  if (A > B) then
    Result := A
  else
    Result := B;
end;

class function SayiYonetimi.MinInt(A, B: Integer): Integer;
begin
  if (A < B) then
    Result := A
  else
    Result := B;
end;

class function SayiYonetimi.SifirliYaz(ADeger: Integer;
  ARakamSayisi: Byte): string;
var
  i: Integer;
  j: Integer;
begin
  Result := IntToStr(ADeger);
  j := Length(Result);
  for i := 1 to ARakamSayisi - j do
    Result := '0' + Result;
end;

{ SenaryoYönetimi }

class function SenaryoYönetimi.MetinDizeIsle(AKaynak: string;
  ADegiskenler: TStringList): string;

  function DoTableFieldValue(p: TParser): string;
  var
    i : Integer;
  begin
    if (not Assigned(ADegiskenler)) then
      raise EInvalidOperation.Create('İç hata ! : 1000');
    Result := '';
    if (p.Token = '@') then begin
      if p.NextToken = '@' then begin
        // Değişken
        // bundan sonra sembol gelmeli!!!
        p.NextToken;
        p.CheckToken(toSymbol);
        i := ADegiskenler.IndexOf(p.TokenString);
        if (i > -1) and (Assigned(ADegiskenler.Objects[i])) then begin
          p.NextToken;
          p.CheckToken('.');
          p.NextToken;
          p.CheckToken(toSymbol);
          Result := TDataSet(ADegiskenler.Objects[i]).FieldByName(p.TokenString).AsString;
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
      Classes.toString: begin
        Result := p.TokenString;
      end;
      '~': begin // değişken
        if (not Assigned(ADegiskenler)) then
          raise Exception.Create('İç hata 1000'); 
        p.NextToken;
        p.CheckToken(toSymbol);
        Result := ADegiskenler.Values[p.TokenString];
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
          tmp2 := TarihSaat.YasHesapla(floatValue, Date, YasYil, YasAy, YasGun);
          p.NextToken;
          p.CheckToken(',');
          p.NextToken;
          tmp1 := DoStatement(p);
          if tmp1 = '0' then // branş çocuk değilse
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
          if ADegiskenler.IndexOf(p.TokenString) = -1 then
            ADegiskenler.Add(tmp1 + '=' + tmp2)
          else
            ADegiskenler.Values[tmp1] := tmp2;
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
          tmp2 := DoStatement(p); // tarih formatı
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
  s := TStringStream.Create(AKaynak);
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

class function SenaryoYönetimi.PascalKodunaDonustur(
  AKodlanmisDize: string): string;
type
  TTagInfo = record
    BeginEndBlock : string;
    HeaderString  : string;
    Processed     : Boolean;
    HeaderBlock   : Boolean;
    WriteDirective: Boolean;
    LastPosition  : Integer;
  end;

  function KodIcinUygunlastir(Str : string): string;
  var
    tirnakKipi  : Boolean;
    p           : Integer;
  begin
    tirnakKipi := False;
    Result := '';
    for p := 1 to Length(str) do begin
      if tirnakKipi then begin
        case Str[p] of
          #39: begin
            Result := Result + #39#39;
          end;
          #10: begin
            Result := Result + '''#10';
            tirnakKipi := False;
          end;
          #13: begin
            Result := Result + '''#13';
            tirnakKipi := False;
          end;
          #9: begin
            Result := Result + '''#9';
            tirnakKipi := False;
          end;
          else
            Result := Result + Str[p];
        end;
      end else begin
        case Str[p] of
          #39: begin
            Result := Result + #39#39#39;
            tirnakKipi := True;
          end;
          #10: begin
            Result := Result + '#10';
          end;
          #13: begin
            Result := Result + '#13';
          end;
          #9: begin
            Result := Result + '#9';
          end;
          else
            Result := Result + #39 + Str[p];
            tirnakKipi := True;
        end;
      end;
    end;
    if tirnakKipi then
      Result := Result + '''';
  end;

  function _Write(AA: String): String;
  begin
    if Length(AA) = 0 then Exit;
    Result := #13#10'  _Write(' + KodIcinUygunlastir(AA) + ');';
  end;

  function _WriteDirect(AA: String): String;
  begin
    if Length(AA) = 0 then Exit;
    Result := #13#10'  _Write(' + Trim(AA) + ');';
  end;

var
  CurPos          : Integer;
  BeginEndBlock   : String;
  Header          : String;
  ti              : TTagInfo;

  function DoCodeBlock(AStartPos : Integer;AStartTag: string;AEndTag: string) : TTagInfo;
  var
    F     : Integer;
    F2    : Integer;
    S     : string;
  begin
    Result.Processed := False;
    Result.HeaderBlock := False;
    Result.WriteDirective := False;
    Result.BeginEndBlock := '';
    F := PosEx(AStartTag,AKodlanmisDize,AStartPos);
    if F > 0 then begin
      { Kodlama sembollerini kontrol ediyoruz }
      if Copy(AKodlanmisDize,F + Length(AStartTag),1) = '=' then begin
        {Burada belirtilen kod _write kullanarak çıktıya yansıtılmalı gerektiğini bildiriyor}
        Result.WriteDirective := True;
        { Değer çıkarma işlevlerinin düzgün çalışması için = sembolünü geçmesini sağlıyoruz }
        AStartTag := AStartTag + '=';
        //AStartPos := AStartPos + 1;
      end else if Copy(AKodlanmisDize,F + Length(AStartTag),1) = '*' then begin
        {Burada belirtilen kod bir başlık bilgisi olduğunu function,var gibi
          global olarak kullanılan ifade içerdiğini bildiriyor}
        Result.HeaderBlock := True;
        AStartTag := AStartTag + '*';
        { Değer çıkarma işlevlerinin düzgün çalışması için * sembolünü geçmesini sağlıyoruz }
      end;
      { Kapama etiketini buluyoruz }
      F2 := PosEx(AEndTag,AKodlanmisDize,F + Length(AStartTag));
      { Bu etiketten önce bir girdi var ise bunları _write ile yazıyoruz }
      Result.BeginEndBlock := Result.BeginEndBlock + _Write(Copy(AKodlanmisDize,AStartPos,(F) - AStartPos));
      { Etiketler arasındaki kod kısımını yazıyoruz }
      S := TrimRight(Copy(AKodlanmisDize,F + Length(AStartTag), F2 - (F + Length(AStartTag))));

      if Result.WriteDirective then
        S := _WriteDirect(S);
      //else
      //  if Pos(';'#13#10,S) = 0 then S := S + ';'#13#10;
      if Result.HeaderBlock then
        Result.HeaderString := S
      else
        Result.BeginEndBlock := Result.BeginEndBlock + S;
      { Son pozisyon güncellemesini yapıyor F2 değişkeni  --> %> % işaretini gösteriyor. }
      Result.LastPosition := F2 + Length(AEndTag);
      Result.Processed := True;
    end;
  end;

begin
  CurPos := 1;
  BeginEndBlock := '';
  Header := '';
  try
    repeat
      {Kod bloğu var mı bakıyoruz }
      ti := DoCodeBlock(CurPos,'<%','%>');
      { Bu çağırmadan birşey işlenmiş mi? }
      if ti.Processed then begin
        {Bu kod başlık bloğu mu ?}
        if ti.HeaderBlock then begin
          Header := Header + ti.HeaderString;
          BeginEndBlock := BeginEndBlock + ti.BeginEndBlock;
        end
        { Bu kod sadece _write kullanarak direk yazılması gereken bişey mi ? Örn. bir değişken }
        else BeginEndBlock := BeginEndBlock + ti.BeginEndBlock;
        { Hep aynı şeyleri bulmaması için Pozisyonu değiştiriyoruz }
        CurPos := ti.LastPosition;
      end;
    until not ti.Processed;
  finally
    if (BeginEndBlock = '') then begin
      { Hiç pascal kodu içermiyor }
      { O zaman tamamını _write ile çevreliyoruz }
      BeginEndBlock := BeginEndBlock + _Write(AKodlanmisDize);
//      CurPos := Length(AKodlanmisDize);
    end else if CurPos < Length(AKodlanmisDize) then begin
      { Sonda kalanlarıda _write ile çevreliyoruz }
      BeginEndBlock := BeginEndBlock + _Write(Copy(AKodlanmisDize,CurPos,(Length(AKodlanmisDize) - CurPos) + 1 ));
    end;
    {Pascal kod bloğunu inşa ediyoruz }
    Result := Header + 'begin'#13#10 + BeginEndBlock + 'end.'#13#10;
    //ShowMessage(Result);
    //stringToFile('c:\sql_out.txt',Result);
  end;
end;

{ DosyaSistemi.Dizin }

class procedure DosyaSistemi.Dizin.DizindekiDosyalar(AramaFiltresi: string;
  AListe: TStrings);
var
  SearchRec: TSearchRec;
  ListeSonu: Boolean;
begin
  ListeSonu := False;
  AListe.Clear;
  if FindFirst(AramaFiltresi, faAnyFile, SearchRec) = 0 then begin
    while not ListeSonu do
    begin
      AListe.Add(SearchRec.Name);
      ListeSonu := (FindNext(SearchRec) <> 0);
    end;
  end;
end;

class procedure DosyaSistemi.Dizin.ŞuAnkiDizindekiDosyalar(AUzanti: string;
  AListe: TStrings);
var
  SearchRec: TSearchRec;
  ListeSonu: Boolean;
  FileSpecs: string;
begin
  ListeSonu := False;
  GetDir(0, FileSpecs);
  FileSpecs := FileSpecs + '\*.' + AUzanti;
  AListe.Clear;
  if FindFirst(FileSpecs, faAnyFile, SearchRec) = 0 then begin
    while not ListeSonu do
    begin
      AListe.Add(SearchRec.Name);
      ListeSonu := (FindNext(SearchRec) <> 0);
    end;
  end;
end;

{ TBasitTablo }

constructor TBasitTabloSatir.Create(AKaynakDataSet: TDataSet);
begin
  FKaynakDataSet := AKaynakDataSet;
  FAlanlar := TObjectList.Create;
  FAlanlar.OwnsObjects := True;
end;

destructor TBasitTabloSatir.Destroy;
begin
  FAlanlar.Free;
  inherited;
end;

function TBasitTabloSatir.GetAlanDeger(AAlanAdi: string): string;
var
  I: Integer;
  alan : TBasitTabloSatirAlan;
begin
  Result := '';
  for I := 0 to FAlanlar.Count - 1 do begin
    alan := TBasitTabloSatirAlan(FAlanlar[i]);
    if UpperCase(alan.Alan) = UpperCase(AAlanAdi) then begin
      Result := alan.Deger;
      Exit;
    end;
  end;
end;

procedure TBasitTabloSatir.Hazirla(AAlanListesi: array of string);
var
  I: Integer;
begin
  FAlanlar.Clear;
  for I := Low(AAlanListesi) to High(AAlanListesi) do begin
    FAlanlar.Add(TBasitTabloSatirAlan.Create(Self,AAlanListesi[i]));
  end;
end;

class function TBasitTabloSatir.Kopyala(ADataSet: TDataSet;
  AAlanListesi: array of string): TBasitTabloSatir;
begin
  Result := TBasitTabloSatir.Create(ADataSet);
  Result.Hazirla(AAlanListesi);  
end;

procedure TBasitTabloSatir.Yapistir(AHedefDataSet: TDataSet);
var
  I: Integer;
  alan : TBasitTabloSatirAlan;
begin
  if not (AHedefDataSet.State in [dsEdit,dsInsert]) then
    AHedefDataSet.Edit;
  for I := 0 to FAlanlar.Count - 1 do begin
    alan := TBasitTabloSatirAlan(FAlanlar[i]);
    alan.Yapistir(AHedefDataSet);
  end;
end;

{ TBasitTabloAlan }

constructor TBasitTabloSatirAlan.Create(ATablo: TBasitTabloSatir; AAlanAdi: string);
begin
  FAlan := AAlanAdi;
  FField := ATablo.KaynakDataSet.FieldByName(AAlanAdi);
  if FField.IsBlob then begin
    FBlobDeger := TMemoryStream.Create;
    TBlobField(FField).SaveToStream(FBlobDeger);
  end else FDeger := ATablo.KaynakDataSet.FieldByName(AAlanAdi).AsString;
end;

destructor TBasitTabloSatirAlan.Destroy;
begin
  if FField.IsBlob and Assigned(FBlobDeger) then
    FBlobDeger.Free;
  inherited;
end;

procedure TBasitTabloSatirAlan.Yapistir(AHedefDataSet: TDataSet);
begin
  if FField.IsBlob then begin
    FBlobDeger.Position := 0;
    TBlobField(AHedefDataSet.FieldByName(FField.FieldName)).LoadFromStream(FBlobDeger);
  end else AHedefDataSet.FieldByName(FField.FieldName).AsString := FDeger;
end;

{ TBasitTablo }

constructor TBasitTablo.Create(ADataSet: TDataSet);
begin
  FSatirlar := TObjectList.Create;
  FSatirlar.OwnsObjects := True;
  FDataSet := ADataSet;
end;

destructor TBasitTablo.Destroy;
begin

  inherited;
end;

procedure TBasitTablo.Hazirla(AAlanListesi: array of string;
  ATumSatirlar: Boolean);
var
  satir : TBasitTabloSatir;
begin
  FSatirlar.Clear;
  if ATumSatirlar then begin
    FDataSet.First;
    while not FDataSet.Eof do begin
      satir := TBasitTabloSatir.Kopyala(FDataSet,AAlanListesi);
      FSatirlar.Add(satir); 
      FDataSet.Next;
    end;
  end;
end;

procedure TBasitTablo.IlkSatiriYapistir(AHedefDataSet: TDataSet);
begin

end;

class function TBasitTablo.TekSatirKopyala(ADataSet: TDataSet;
  AAlanListesi: array of string): TBasitTablo;
begin
  Result := TBasitTablo.Create(ADataSet);
  Result.Hazirla(AAlanListesi);
end;

class function TBasitTablo.TumTabloyuKopyala(ADataSet: TDataSet;
  AAlanListesi: array of string): TBasitTablo;
begin
  Result := TBasitTablo.Create(ADataSet);
  Result.Hazirla(AAlanListesi,True);
end;

procedure TBasitTablo.TumunuYapistir(AHedefDataSet: TDataSet);
var
  i: Integer;
  satir: TBasitTabloSatir;
begin
  for i := 0 to FSatirlar.Count - 1 do begin
    satir := TBasitTabloSatir(FSatirlar[i]);
    satir.Yapistir(AHedefDataSet);
  end;
end;


{ Feta }

class function Feta.BaglantiDizesi: string;
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

class function Feta.CrcHesapla(PSif: Pointer; Size: Integer): Word;
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

class procedure Feta.Sifrele(Yon: Integer; PSif: Pointer; Size: Integer);
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

{ Feta.Hasta }

class function Feta.Hasta.TcKimlikDogrula(TCNo: Int64): Boolean;
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
      C9 := ATCNO mod 10; {ATCNO := ATCNO div 10;}
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

{ AgSistemi }

class function AgSistemi.MACAdresiniGetir: string;
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
Result := _SystemID;

end;

{ Dizi }

class function Dizi.Birlestir(ADizeArray: array of string;
  AAyirici: string): string;
var
  eleman: string;
begin
  Result := '';
  for eleman in ADizeArray do begin
    Result := Result + eleman + AAyirici;
  end;
  if Length(Result) > 0 then
    Result := Dize.TerstenSil(Result,Length(AAyirici));
end;

{ Kultur }

class function Kültür.IkiHarfliDilAdi: string;
var
 pcLCA: Array[0..20] of Char;
begin
  if( GetLocaleInfo(LOCALE_SYSTEM_DEFAULT,LOCALE_SISO639LANGNAME,pcLCA,19) <= 0 ) then
    pcLCA[0] := #0;
  Result := UpperCase(pcLCA);
end;

{ GtpLog }

class procedure GtpLog.Log(AMsg: string; AParams: array of const);
begin
  OutputDebugString(PChar(Format(AMsg,AParams)));
end;

class procedure GtpLog.Log(AMsg: string);
begin
  Log(AMsg,[]);
end;

end.














