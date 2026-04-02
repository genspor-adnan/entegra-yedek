unit USabitler;

{

  21-01-2008
  Proje içinde kullanacaðýmýz sabitle bu modulde tanýmlanmýþtýr
  Hakan Arslantaþ

}

interface

uses SysUtils, sysConst;

const

  (* -BEGIN- MODUL KOD Listesi*)
  Modul1 = 'Ajanda';
  Modul2 = 'Ameliyat';
  Modul3 = 'Anket';
  Modul4 = 'Diyaliz';
  Modul5 = 'DoðanBebek';
  Modul6 = 'Evrak Defteri';
  Modul7 = 'Evrak Takip';
  Modul8 = 'Fatura Takip';
  Modul9 = 'GARS';
  Modul10 = 'Gen95';
  Modul11 = 'GenLAB';
  Modul12 = 'GenMedula';
  Modul13 = 'GenScan';
  Modul14 = 'Genspor';
  Modul15 = 'Gentegre';
  Modul16 = 'Giykimbil';
  Modul17 = 'Hýzlý Giriþ';
  Modul18 = 'KamuLab';
  Modul19 = 'Kayýtkabul';
  Modul20 = 'Kullanan';
  Modul21 = 'Lab';
  Modul22 = 'LIS - Cihaz baðlantýsý';
  Modul23 = 'LISNET';
  Modul24 = 'Medula Entegrasyon';
  Modul25 = 'Muayene';
  Modul26 = 'Persona';
  Modul27 = 'Radyoloji';
  Modul28 = 'Randevu';
  Modul29 = 'Servis';
  Modul30 = 'Stok';
  Modul31 = 'Sýramatik';
  Modul32 = 'Tüp Bebek';
  Modul33 = 'Yönlendirme';
  Modul34 = 'Ýþyeri Hekimliði';
  Modul35 = 'Magic SAS';
  Modul36 = 'Muhasebe Entegrasyonu';
  Modul37 = 'Satýnalma';
  (* -END- MODUL KOD Listesi*)

  DBInfo = 'DBInfo';
  NoSplash = '\NoSplash';
  Feta_Test = 'Feta_Test';
  NoLisControl = 'NoLisControl';

var
  LisControl : Boolean;

  procedure SetRegionalSettings;

implementation

procedure SetRegionalSettings;
begin
  FormatSettings.CurrencyString := 'TL';
  FormatSettings.CurrencyFormat := 3;
  FormatSettings.NegCurrFormat := 8;
  FormatSettings.ThousandSeparator := ',';
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.CurrencyDecimals := 2;
  FormatSettings.DateSeparator := '/';
  FormatSettings.ShortDateFormat := 'dd/MM/yyyy';
  FormatSettings.LongDateFormat := 'dd MMMM yyyy dddd';
  FormatSettings.TimeSeparator := ':';
  FormatSettings.TimeAMString := '';
  FormatSettings.TimePMString := '';
  FormatSettings.ShortTimeFormat := 'hh:mm';
  FormatSettings.LongTimeFormat := 'hh:mm:ss';
  FormatSettings.ListSeparator := ';';
end;

begin
  LisControl := True;
end.

