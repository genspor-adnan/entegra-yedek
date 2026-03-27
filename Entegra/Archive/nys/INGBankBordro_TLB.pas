unit INGBankBordro_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 17244 $
// File generated on 03/10/2011 17:04:51 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\GenSoft\Delphi\Entegra\Entegra\nys\INGBankBordro.dll (1)
// LIBID: {F16FAD79-47DA-4803-8E7E-6BD4F2EE51E5}
// LCID: 0
// Helpfile: 
// HelpString: INGBankBordro ActiveX DLL
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// Errors:
//   Hint: Member 'BankaBilgileriGüncelle' of '_Banka' changed to 'BankaBilgileriGüncelle1'
//   Error creating palette bitmap of (TNYSBordro) : Server C:\GenSoft\Delphi\Entegra\Entegra\nys\INGBankBordro.dll contains no icons
//   Error creating palette bitmap of (THata) : Server C:\GenSoft\Delphi\Entegra\Entegra\nys\INGBankBordro.dll contains no icons
//   Error creating palette bitmap of (TBanka) : Server C:\GenSoft\Delphi\Entegra\Entegra\nys\INGBankBordro.dll contains no icons
//   Error creating palette bitmap of (TTalimat) : Server C:\GenSoft\Delphi\Entegra\Entegra\nys\INGBankBordro.dll contains no icons
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  INGBankBordroMajorVersion = 11;
  INGBankBordroMinorVersion = 0;

  LIBID_INGBankBordro: TGUID = '{F16FAD79-47DA-4803-8E7E-6BD4F2EE51E5}';

  IID__NYSBordro: TGUID = '{CDE174D6-2153-4092-B61C-FC9F975F11A6}';
  CLASS_NYSBordro: TGUID = '{08D0D111-B212-4D1E-934B-637C200F3D70}';
  IID__Hata: TGUID = '{8E1FDD07-954A-4719-A670-FD00970ED719}';
  CLASS_Hata: TGUID = '{540F16F0-4B03-4F30-8930-526B72DE1B7D}';
  IID__Banka: TGUID = '{2E86B6BE-F34A-4F4B-8F4C-D9E47F132914}';
  CLASS_Banka: TGUID = '{39BA0191-C007-4642-8B12-5F0EB3DF1FB8}';
  IID__Talimat: TGUID = '{B7B7EB4F-2C7C-42A9-833A-BE7BDD1E3E75}';
  CLASS_Talimat: TGUID = '{8DD9CE27-4DE2-4AB2-AA68-B9EA1DD3290E}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  _NYSBordro = interface;
  _NYSBordroDisp = dispinterface;
  _Hata = interface;
  _HataDisp = dispinterface;
  _Banka = interface;
  _BankaDisp = dispinterface;
  _Talimat = interface;
  _TalimatDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  NYSBordro = _NYSBordro;
  Hata = _Hata;
  Banka = _Banka;
  Talimat = _Talimat;


// *********************************************************************//
// Interface: _NYSBordro
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {CDE174D6-2153-4092-B61C-FC9F975F11A6}
// *********************************************************************//
  _NYSBordro = interface(IDispatch)
    ['{CDE174D6-2153-4092-B61C-FC9F975F11A6}']
    function Get_EvrakNo: WideString; safecall;
    procedure Set_EvrakNo(var Param1: WideString); safecall;
    function Get_BordroPassword: WideString; safecall;
    function Get_BordroAd: WideString; safecall;
    function Get_Durum: WideString; safecall;
    function Get_ExportDosyaYolu: WideString; safecall;
    function Get_ImzaYetkilisiAd4: WideString; safecall;
    procedure Set_ImzaYetkilisiAd4(var Param1: WideString); safecall;
    function Get_ImzaYetkilisiUnvan4: WideString; safecall;
    procedure Set_ImzaYetkilisiUnvan4(var Param1: WideString); safecall;
    function Get_ImzaYetkilisiAd3: WideString; safecall;
    procedure Set_ImzaYetkilisiAd3(var Param1: WideString); safecall;
    function Get_ImzaYetkilisiUnvan3: WideString; safecall;
    procedure Set_ImzaYetkilisiUnvan3(var Param1: WideString); safecall;
    function Get_ImzaYetkilisiAd2: WideString; safecall;
    procedure Set_ImzaYetkilisiAd2(var Param1: WideString); safecall;
    function Get_ImzaYetkilisiUnvan2: WideString; safecall;
    procedure Set_ImzaYetkilisiUnvan2(var Param1: WideString); safecall;
    function Get_ImzaYetkilisiAd1: WideString; safecall;
    procedure Set_ImzaYetkilisiAd1(var Param1: WideString); safecall;
    function Get_ImzaYetkilisiUnvan1: WideString; safecall;
    procedure Set_ImzaYetkilisiUnvan1(var Param1: WideString); safecall;
    function Get_OdemeTarihi: WideString; safecall;
    procedure Set_OdemeTarihi(var Param1: WideString); safecall;
    function Get_FirmaAd: WideString; safecall;
    procedure Set_FirmaAd(var Param1: WideString); safecall;
    function Get_MailBaslik: WideString; safecall;
    procedure Set_MailBaslik(var Param1: WideString); safecall;
    function Get_TalimatAdet: Smallint; safecall;
    function Get_KonsolideTalimatAdet: Smallint; safecall;
    function Get_HataliTalimatAdet: WideString; safecall;
    function Get_IBANsizTalimatAdet: WideString; safecall;
    function Get_HataAdet: WideString; safecall;
    function Get_ToplamTutar: WideString; safecall;
    function Get_IBANsizToplamTutar: WideString; safecall;
    procedure Temizle; safecall;
    procedure Talimat_Olustur(const pTalimat: _Talimat); safecall;
    function Get_Hatalar(var endLine: WideString): WideString; safecall;
    function Kaydet: WordBool; safecall;
    function KapakYazdir: WordBool; safecall;
    function ListeYazdir: WideString; safecall;
    function ePostaIleGonder: WordBool; safecall;
    function ExportDosya(var Path: WideString): WideString; safecall;
    property EvrakNo: WideString read Get_EvrakNo write Set_EvrakNo;
    property BordroPassword: WideString read Get_BordroPassword;
    property BordroAd: WideString read Get_BordroAd;
    property Durum: WideString read Get_Durum;
    property ExportDosyaYolu: WideString read Get_ExportDosyaYolu;
    property ImzaYetkilisiAd4: WideString read Get_ImzaYetkilisiAd4 write Set_ImzaYetkilisiAd4;
    property ImzaYetkilisiUnvan4: WideString read Get_ImzaYetkilisiUnvan4 write Set_ImzaYetkilisiUnvan4;
    property ImzaYetkilisiAd3: WideString read Get_ImzaYetkilisiAd3 write Set_ImzaYetkilisiAd3;
    property ImzaYetkilisiUnvan3: WideString read Get_ImzaYetkilisiUnvan3 write Set_ImzaYetkilisiUnvan3;
    property ImzaYetkilisiAd2: WideString read Get_ImzaYetkilisiAd2 write Set_ImzaYetkilisiAd2;
    property ImzaYetkilisiUnvan2: WideString read Get_ImzaYetkilisiUnvan2 write Set_ImzaYetkilisiUnvan2;
    property ImzaYetkilisiAd1: WideString read Get_ImzaYetkilisiAd1 write Set_ImzaYetkilisiAd1;
    property ImzaYetkilisiUnvan1: WideString read Get_ImzaYetkilisiUnvan1 write Set_ImzaYetkilisiUnvan1;
    property OdemeTarihi: WideString read Get_OdemeTarihi write Set_OdemeTarihi;
    property FirmaAd: WideString read Get_FirmaAd write Set_FirmaAd;
    property MailBaslik: WideString read Get_MailBaslik write Set_MailBaslik;
    property TalimatAdet: Smallint read Get_TalimatAdet;
    property KonsolideTalimatAdet: Smallint read Get_KonsolideTalimatAdet;
    property HataliTalimatAdet: WideString read Get_HataliTalimatAdet;
    property IBANsizTalimatAdet: WideString read Get_IBANsizTalimatAdet;
    property HataAdet: WideString read Get_HataAdet;
    property ToplamTutar: WideString read Get_ToplamTutar;
    property IBANsizToplamTutar: WideString read Get_IBANsizToplamTutar;
  end;

// *********************************************************************//
// DispIntf:  _NYSBordroDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {CDE174D6-2153-4092-B61C-FC9F975F11A6}
// *********************************************************************//
  _NYSBordroDisp = dispinterface
    ['{CDE174D6-2153-4092-B61C-FC9F975F11A6}']
    property EvrakNo: WideString dispid 1745027094;
    property BordroPassword: WideString readonly dispid 1745027093;
    property BordroAd: WideString readonly dispid 1745027092;
    property Durum: WideString readonly dispid 1745027091;
    property ExportDosyaYolu: WideString readonly dispid 1745027090;
    property ImzaYetkilisiAd4: WideString dispid 1745027089;
    property ImzaYetkilisiUnvan4: WideString dispid 1745027088;
    property ImzaYetkilisiAd3: WideString dispid 1745027087;
    property ImzaYetkilisiUnvan3: WideString dispid 1745027086;
    property ImzaYetkilisiAd2: WideString dispid 1745027085;
    property ImzaYetkilisiUnvan2: WideString dispid 1745027084;
    property ImzaYetkilisiAd1: WideString dispid 1745027083;
    property ImzaYetkilisiUnvan1: WideString dispid 1745027082;
    property OdemeTarihi: WideString dispid 1745027081;
    property FirmaAd: WideString dispid 1745027080;
    property MailBaslik: WideString dispid 1745027079;
    property TalimatAdet: Smallint readonly dispid 1745027078;
    property KonsolideTalimatAdet: Smallint readonly dispid 1745027077;
    property HataliTalimatAdet: WideString readonly dispid 1745027076;
    property IBANsizTalimatAdet: WideString readonly dispid 1745027075;
    property HataAdet: WideString readonly dispid 1745027074;
    property ToplamTutar: WideString readonly dispid 1745027073;
    property IBANsizToplamTutar: WideString readonly dispid 1745027072;
    procedure Temizle; dispid 1610809367;
    procedure Talimat_Olustur(const pTalimat: _Talimat); dispid 1610809370;
    function Get_Hatalar(var endLine: WideString): WideString; dispid 1610809372;
    function Kaydet: WordBool; dispid 1610809373;
    function KapakYazdir: WordBool; dispid 1610809374;
    function ListeYazdir: WideString; dispid 1610809375;
    function ePostaIleGonder: WordBool; dispid 1610809376;
    function ExportDosya(var Path: WideString): WideString; dispid 1610809392;
  end;

// *********************************************************************//
// Interface: _Hata
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8E1FDD07-954A-4719-A670-FD00970ED719}
// *********************************************************************//
  _Hata = interface(IDispatch)
    ['{8E1FDD07-954A-4719-A670-FD00970ED719}']
    procedure Temizle; safecall;
    function Get_Aciklama: WideString; safecall;
    function Get_No: WideString; safecall;
    function Get_Kaynak: WideString; safecall;
    function Get_Tipi: WideString; safecall;
    procedure Set_Values(const p_Tipi: WideString; const p_No: WideString; 
                         const p_Kaynak: WideString; const p_Aciklama: WideString); safecall;
    function To_String: WideString; safecall;
    property Aciklama: WideString read Get_Aciklama;
    property No: WideString read Get_No;
    property Kaynak: WideString read Get_Kaynak;
    property Tipi: WideString read Get_Tipi;
  end;

// *********************************************************************//
// DispIntf:  _HataDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8E1FDD07-954A-4719-A670-FD00970ED719}
// *********************************************************************//
  _HataDisp = dispinterface
    ['{8E1FDD07-954A-4719-A670-FD00970ED719}']
    procedure Temizle; dispid 1610809348;
    property Aciklama: WideString readonly dispid 1745027075;
    property No: WideString readonly dispid 1745027074;
    property Kaynak: WideString readonly dispid 1745027073;
    property Tipi: WideString readonly dispid 1745027072;
    procedure Set_Values(const p_Tipi: WideString; const p_No: WideString; 
                         const p_Kaynak: WideString; const p_Aciklama: WideString); dispid 1610809351;
    function To_String: WideString; dispid 1610809352;
  end;

// *********************************************************************//
// Interface: _Banka
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {2E86B6BE-F34A-4F4B-8F4C-D9E47F132914}
// *********************************************************************//
  _Banka = interface(IDispatch)
    ['{2E86B6BE-F34A-4F4B-8F4C-D9E47F132914}']
    function BankaBilgileriGüncelle1: WordBool; safecall;
  end;

// *********************************************************************//
// DispIntf:  _BankaDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {2E86B6BE-F34A-4F4B-8F4C-D9E47F132914}
// *********************************************************************//
  _BankaDisp = dispinterface
    ['{2E86B6BE-F34A-4F4B-8F4C-D9E47F132914}']
    function BankaBilgileriGüncelle1: WordBool; dispid 1610809344;
  end;

// *********************************************************************//
// Interface: _Talimat
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B7B7EB4F-2C7C-42A9-833A-BE7BDD1E3E75}
// *********************************************************************//
  _Talimat = interface(IDispatch)
    ['{B7B7EB4F-2C7C-42A9-833A-BE7BDD1E3E75}']
    procedure Temizle; safecall;
    function Get_TCMBOdemeKodu: WideString; safecall;
    procedure Set_TCMBOdemeKodu(var Param1: WideString); safecall;
    function Get_Tutar: Currency; safecall;
    procedure Set_Tutar(var Param1: Currency); safecall;
    function Get_MasrafBilgisi: Smallint; safecall;
    procedure Set_MasrafBilgisi(var Param1: Smallint); safecall;
    function Get_FirmayaOzel1: WideString; safecall;
    procedure Set_FirmayaOzel1(var Param1: WideString); safecall;
    function Get_FirmayaOzel2: WideString; safecall;
    procedure Set_FirmayaOzel2(var Param1: WideString); safecall;
    function Get_FirmayaOzel3: WideString; safecall;
    procedure Set_FirmayaOzel3(var Param1: WideString); safecall;
    function Get_FirmayaOzel4: WideString; safecall;
    procedure Set_FirmayaOzel4(var Param1: WideString); safecall;
    function Get_FirmayaOzel5: WideString; safecall;
    procedure Set_FirmayaOzel5(var Param1: WideString); safecall;
    function Get_Durum: WideString; safecall;
    procedure Borclu_Temizle; safecall;
    function Get_BorcluMuhasebeReferansNo: WideString; safecall;
    procedure Set_BorcluMuhasebeReferansNo(var Param1: WideString); safecall;
    function Get_BorcluKullaniciAciklama: WideString; safecall;
    procedure Set_BorcluKullaniciAciklama(var Param1: WideString); safecall;
    function Get_BorcluOtomatikAciklama: WideString; safecall;
    procedure Set_BorcluOtomatikAciklama(var Param1: WideString); safecall;
    function Get_BorcluHesapNo: WideString; safecall;
    procedure Set_BorcluHesapNo(var Param1: WideString); safecall;
    function Get_BorcluSubeKod: WideString; safecall;
    procedure Set_BorcluSubeKod(var Param1: WideString); safecall;
    function Get_BorcluSubeAd: WideString; safecall;
    procedure Set_BorcluSubeAd(var Param1: WideString); safecall;
    function Get_BorcluBankaKod: WideString; safecall;
    procedure Set_BorcluBankaKod(var Param1: WideString); safecall;
    function Get_BorcluBankaAd: WideString; safecall;
    procedure Set_BorcluBankaAd(var Param1: WideString); safecall;
    function Get_BorcluFirmaKod: WideString; safecall;
    procedure Set_BorcluFirmaKod(var Param1: WideString); safecall;
    function Get_BorcluFirmaUnvan: WideString; safecall;
    procedure Set_BorcluFirmaUnvan(var Param1: WideString); safecall;
    function Get_BorcluVergiNo: WideString; safecall;
    procedure Set_BorcluVergiNo(var Param1: WideString); safecall;
    procedure Alacakli_Temizle; safecall;
    function Get_AlacakliBankaKod: WideString; safecall;
    procedure Set_AlacakliBankaKod(var Param1: WideString); safecall;
    function Get_AlacakliBankaAd: WideString; safecall;
    procedure Set_AlacakliBankaAd(var Param1: WideString); safecall;
    function Get_AlacakliBabaAdi: WideString; safecall;
    procedure Set_AlacakliBabaAdi(var Param1: WideString); safecall;
    function Get_AlacakliVergiNo: WideString; safecall;
    procedure Set_AlacakliVergiNo(var Param1: WideString); safecall;
    function Get_AlacakliVergiD: WideString; safecall;
    procedure Set_AlacakliVergiD(var Param1: WideString); safecall;
    function Get_AlacakliAdres: WideString; safecall;
    procedure Set_AlacakliAdres(var Param1: WideString); safecall;
    function Get_AlacakliTelefonNo: WideString; safecall;
    procedure Set_AlacakliTelefonNo(var Param1: WideString); safecall;
    function Get_AlacakliFaksNo: WideString; safecall;
    procedure Set_AlacakliFaksNo(var Param1: WideString); safecall;
    function Get_AlacakliePosta1: WideString; safecall;
    procedure Set_AlacakliePosta1(var Param1: WideString); safecall;
    function Get_AlacakliePosta2: WideString; safecall;
    procedure Set_AlacakliePosta2(var Param1: WideString); safecall;
    function Get_AlacakliMuhasebeReferansNo: WideString; safecall;
    procedure Set_AlacakliMuhasebeReferansNo(var Param1: WideString); safecall;
    function Get_AlacakliOtomatikAciklama: WideString; safecall;
    procedure Set_AlacakliOtomatikAciklama(var Param1: WideString); safecall;
    function Get_AlacakliKullaniciAciklama: WideString; safecall;
    procedure Set_AlacakliKullaniciAciklama(var Param1: WideString); safecall;
    function Get_AlacakliHesapNo: WideString; safecall;
    procedure Set_AlacakliHesapNo(var Param1: WideString); safecall;
    function Get_AlacakliSubeKod: WideString; safecall;
    procedure Set_AlacakliSubeKod(var Param1: WideString); safecall;
    function Get_AlacakliSubead: WideString; safecall;
    procedure Set_AlacakliSubead(var Param1: WideString); safecall;
    function Get_AlacakliFirmaUnvan: WideString; safecall;
    procedure Set_AlacakliFirmaUnvan(var Param1: WideString); safecall;
    function Get_AlacakliFirmaKod: WideString; safecall;
    procedure Set_AlacakliFirmaKod(var Param1: WideString); safecall;
    function Get_HataAdet: Smallint; safecall;
    procedure Kaydet; safecall;
    function Get_Hatalar: WideString; safecall;
    function konsolide_equals(var comp: _Talimat): WordBool; safecall;
    procedure copyFrom(var comp: _Talimat); safecall;
    property TCMBOdemeKodu: WideString read Get_TCMBOdemeKodu write Set_TCMBOdemeKodu;
    property Tutar: Currency read Get_Tutar write Set_Tutar;
    property MasrafBilgisi: Smallint read Get_MasrafBilgisi write Set_MasrafBilgisi;
    property FirmayaOzel1: WideString read Get_FirmayaOzel1 write Set_FirmayaOzel1;
    property FirmayaOzel2: WideString read Get_FirmayaOzel2 write Set_FirmayaOzel2;
    property FirmayaOzel3: WideString read Get_FirmayaOzel3 write Set_FirmayaOzel3;
    property FirmayaOzel4: WideString read Get_FirmayaOzel4 write Set_FirmayaOzel4;
    property FirmayaOzel5: WideString read Get_FirmayaOzel5 write Set_FirmayaOzel5;
    property Durum: WideString read Get_Durum;
    property BorcluMuhasebeReferansNo: WideString read Get_BorcluMuhasebeReferansNo write Set_BorcluMuhasebeReferansNo;
    property BorcluKullaniciAciklama: WideString read Get_BorcluKullaniciAciklama write Set_BorcluKullaniciAciklama;
    property BorcluOtomatikAciklama: WideString read Get_BorcluOtomatikAciklama write Set_BorcluOtomatikAciklama;
    property BorcluHesapNo: WideString read Get_BorcluHesapNo write Set_BorcluHesapNo;
    property BorcluSubeKod: WideString read Get_BorcluSubeKod write Set_BorcluSubeKod;
    property BorcluSubeAd: WideString read Get_BorcluSubeAd write Set_BorcluSubeAd;
    property BorcluBankaKod: WideString read Get_BorcluBankaKod write Set_BorcluBankaKod;
    property BorcluBankaAd: WideString read Get_BorcluBankaAd write Set_BorcluBankaAd;
    property BorcluFirmaKod: WideString read Get_BorcluFirmaKod write Set_BorcluFirmaKod;
    property BorcluFirmaUnvan: WideString read Get_BorcluFirmaUnvan write Set_BorcluFirmaUnvan;
    property BorcluVergiNo: WideString read Get_BorcluVergiNo write Set_BorcluVergiNo;
    property AlacakliBankaKod: WideString read Get_AlacakliBankaKod write Set_AlacakliBankaKod;
    property AlacakliBankaAd: WideString read Get_AlacakliBankaAd write Set_AlacakliBankaAd;
    property AlacakliBabaAdi: WideString read Get_AlacakliBabaAdi write Set_AlacakliBabaAdi;
    property AlacakliVergiNo: WideString read Get_AlacakliVergiNo write Set_AlacakliVergiNo;
    property AlacakliVergiD: WideString read Get_AlacakliVergiD write Set_AlacakliVergiD;
    property AlacakliAdres: WideString read Get_AlacakliAdres write Set_AlacakliAdres;
    property AlacakliTelefonNo: WideString read Get_AlacakliTelefonNo write Set_AlacakliTelefonNo;
    property AlacakliFaksNo: WideString read Get_AlacakliFaksNo write Set_AlacakliFaksNo;
    property AlacakliePosta1: WideString read Get_AlacakliePosta1 write Set_AlacakliePosta1;
    property AlacakliePosta2: WideString read Get_AlacakliePosta2 write Set_AlacakliePosta2;
    property AlacakliMuhasebeReferansNo: WideString read Get_AlacakliMuhasebeReferansNo write Set_AlacakliMuhasebeReferansNo;
    property AlacakliOtomatikAciklama: WideString read Get_AlacakliOtomatikAciklama write Set_AlacakliOtomatikAciklama;
    property AlacakliKullaniciAciklama: WideString read Get_AlacakliKullaniciAciklama write Set_AlacakliKullaniciAciklama;
    property AlacakliHesapNo: WideString read Get_AlacakliHesapNo write Set_AlacakliHesapNo;
    property AlacakliSubeKod: WideString read Get_AlacakliSubeKod write Set_AlacakliSubeKod;
    property AlacakliSubead: WideString read Get_AlacakliSubead write Set_AlacakliSubead;
    property AlacakliFirmaUnvan: WideString read Get_AlacakliFirmaUnvan write Set_AlacakliFirmaUnvan;
    property AlacakliFirmaKod: WideString read Get_AlacakliFirmaKod write Set_AlacakliFirmaKod;
    property HataAdet: Smallint read Get_HataAdet;
  end;

// *********************************************************************//
// DispIntf:  _TalimatDisp
// Flags:     (4560) Hidden Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B7B7EB4F-2C7C-42A9-833A-BE7BDD1E3E75}
// *********************************************************************//
  _TalimatDisp = dispinterface
    ['{B7B7EB4F-2C7C-42A9-833A-BE7BDD1E3E75}']
    procedure Temizle; dispid 1610809383;
    property TCMBOdemeKodu: WideString dispid 1745027110;
    property Tutar: Currency dispid 1745027109;
    property MasrafBilgisi: Smallint dispid 1745027108;
    property FirmayaOzel1: WideString dispid 1745027107;
    property FirmayaOzel2: WideString dispid 1745027106;
    property FirmayaOzel3: WideString dispid 1745027105;
    property FirmayaOzel4: WideString dispid 1745027104;
    property FirmayaOzel5: WideString dispid 1745027103;
    property Durum: WideString readonly dispid 1745027102;
    procedure Borclu_Temizle; dispid 1610809386;
    property BorcluMuhasebeReferansNo: WideString dispid 1745027101;
    property BorcluKullaniciAciklama: WideString dispid 1745027100;
    property BorcluOtomatikAciklama: WideString dispid 1745027099;
    property BorcluHesapNo: WideString dispid 1745027098;
    property BorcluSubeKod: WideString dispid 1745027097;
    property BorcluSubeAd: WideString dispid 1745027096;
    property BorcluBankaKod: WideString dispid 1745027095;
    property BorcluBankaAd: WideString dispid 1745027094;
    property BorcluFirmaKod: WideString dispid 1745027093;
    property BorcluFirmaUnvan: WideString dispid 1745027092;
    property BorcluVergiNo: WideString dispid 1745027091;
    procedure Alacakli_Temizle; dispid 1610809387;
    property AlacakliBankaKod: WideString dispid 1745027090;
    property AlacakliBankaAd: WideString dispid 1745027089;
    property AlacakliBabaAdi: WideString dispid 1745027088;
    property AlacakliVergiNo: WideString dispid 1745027087;
    property AlacakliVergiD: WideString dispid 1745027086;
    property AlacakliAdres: WideString dispid 1745027085;
    property AlacakliTelefonNo: WideString dispid 1745027084;
    property AlacakliFaksNo: WideString dispid 1745027083;
    property AlacakliePosta1: WideString dispid 1745027082;
    property AlacakliePosta2: WideString dispid 1745027081;
    property AlacakliMuhasebeReferansNo: WideString dispid 1745027080;
    property AlacakliOtomatikAciklama: WideString dispid 1745027079;
    property AlacakliKullaniciAciklama: WideString dispid 1745027078;
    property AlacakliHesapNo: WideString dispid 1745027077;
    property AlacakliSubeKod: WideString dispid 1745027076;
    property AlacakliSubead: WideString dispid 1745027075;
    property AlacakliFirmaUnvan: WideString dispid 1745027074;
    property AlacakliFirmaKod: WideString dispid 1745027073;
    property HataAdet: Smallint readonly dispid 1745027072;
    procedure Kaydet; dispid 1610809389;
    function Get_Hatalar: WideString; dispid 1610809391;
    function konsolide_equals(var comp: _Talimat): WordBool; dispid 1610809392;
    procedure copyFrom(var comp: _Talimat); dispid 1610809393;
  end;

// *********************************************************************//
// The Class CoNYSBordro provides a Create and CreateRemote method to          
// create instances of the default interface _NYSBordro exposed by              
// the CoClass NYSBordro. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoNYSBordro = class
    class function Create: _NYSBordro;
    class function CreateRemote(const MachineName: string): _NYSBordro;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TNYSBordro
// Help String      : 
// Default Interface: _NYSBordro
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TNYSBordroProperties= class;
{$ENDIF}
  TNYSBordro = class(TOleServer)
  private
    FIntf: _NYSBordro;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TNYSBordroProperties;
    function GetServerProperties: TNYSBordroProperties;
{$ENDIF}
    function GetDefaultInterface: _NYSBordro;
  protected
    procedure InitServerData; override;
    function Get_EvrakNo: WideString;
    procedure Set_EvrakNo(var Param1: WideString);
    function Get_BordroPassword: WideString;
    function Get_BordroAd: WideString;
    function Get_Durum: WideString;
    function Get_ExportDosyaYolu: WideString;
    function Get_ImzaYetkilisiAd4: WideString;
    procedure Set_ImzaYetkilisiAd4(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan4: WideString;
    procedure Set_ImzaYetkilisiUnvan4(var Param1: WideString);
    function Get_ImzaYetkilisiAd3: WideString;
    procedure Set_ImzaYetkilisiAd3(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan3: WideString;
    procedure Set_ImzaYetkilisiUnvan3(var Param1: WideString);
    function Get_ImzaYetkilisiAd2: WideString;
    procedure Set_ImzaYetkilisiAd2(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan2: WideString;
    procedure Set_ImzaYetkilisiUnvan2(var Param1: WideString);
    function Get_ImzaYetkilisiAd1: WideString;
    procedure Set_ImzaYetkilisiAd1(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan1: WideString;
    procedure Set_ImzaYetkilisiUnvan1(var Param1: WideString);
    function Get_OdemeTarihi: WideString;
    procedure Set_OdemeTarihi(var Param1: WideString);
    function Get_FirmaAd: WideString;
    procedure Set_FirmaAd(var Param1: WideString);
    function Get_MailBaslik: WideString;
    procedure Set_MailBaslik(var Param1: WideString);
    function Get_TalimatAdet: Smallint;
    function Get_KonsolideTalimatAdet: Smallint;
    function Get_HataliTalimatAdet: WideString;
    function Get_IBANsizTalimatAdet: WideString;
    function Get_HataAdet: WideString;
    function Get_ToplamTutar: WideString;
    function Get_IBANsizToplamTutar: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: _NYSBordro);
    procedure Disconnect; override;
    procedure Temizle;
    procedure Talimat_Olustur(const pTalimat: _Talimat);
    function Get_Hatalar(var endLine: WideString): WideString;
    function Kaydet: WordBool;
    function KapakYazdir: WordBool;
    function ListeYazdir: WideString;
    function ePostaIleGonder: WordBool;
    function ExportDosya(var Path: WideString): WideString;
    property DefaultInterface: _NYSBordro read GetDefaultInterface;
    property BordroPassword: WideString read Get_BordroPassword;
    property BordroAd: WideString read Get_BordroAd;
    property Durum: WideString read Get_Durum;
    property ExportDosyaYolu: WideString read Get_ExportDosyaYolu;
    property TalimatAdet: Smallint read Get_TalimatAdet;
    property KonsolideTalimatAdet: Smallint read Get_KonsolideTalimatAdet;
    property HataliTalimatAdet: WideString read Get_HataliTalimatAdet;
    property IBANsizTalimatAdet: WideString read Get_IBANsizTalimatAdet;
    property HataAdet: WideString read Get_HataAdet;
    property ToplamTutar: WideString read Get_ToplamTutar;
    property IBANsizToplamTutar: WideString read Get_IBANsizToplamTutar;
    property EvrakNo: WideString read Get_EvrakNo write Set_EvrakNo;
    property ImzaYetkilisiAd4: WideString read Get_ImzaYetkilisiAd4 write Set_ImzaYetkilisiAd4;
    property ImzaYetkilisiUnvan4: WideString read Get_ImzaYetkilisiUnvan4 write Set_ImzaYetkilisiUnvan4;
    property ImzaYetkilisiAd3: WideString read Get_ImzaYetkilisiAd3 write Set_ImzaYetkilisiAd3;
    property ImzaYetkilisiUnvan3: WideString read Get_ImzaYetkilisiUnvan3 write Set_ImzaYetkilisiUnvan3;
    property ImzaYetkilisiAd2: WideString read Get_ImzaYetkilisiAd2 write Set_ImzaYetkilisiAd2;
    property ImzaYetkilisiUnvan2: WideString read Get_ImzaYetkilisiUnvan2 write Set_ImzaYetkilisiUnvan2;
    property ImzaYetkilisiAd1: WideString read Get_ImzaYetkilisiAd1 write Set_ImzaYetkilisiAd1;
    property ImzaYetkilisiUnvan1: WideString read Get_ImzaYetkilisiUnvan1 write Set_ImzaYetkilisiUnvan1;
    property OdemeTarihi: WideString read Get_OdemeTarihi write Set_OdemeTarihi;
    property FirmaAd: WideString read Get_FirmaAd write Set_FirmaAd;
    property MailBaslik: WideString read Get_MailBaslik write Set_MailBaslik;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TNYSBordroProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TNYSBordro
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TNYSBordroProperties = class(TPersistent)
  private
    FServer:    TNYSBordro;
    function    GetDefaultInterface: _NYSBordro;
    constructor Create(AServer: TNYSBordro);
  protected
    function Get_EvrakNo: WideString;
    procedure Set_EvrakNo(var Param1: WideString);
    function Get_BordroPassword: WideString;
    function Get_BordroAd: WideString;
    function Get_Durum: WideString;
    function Get_ExportDosyaYolu: WideString;
    function Get_ImzaYetkilisiAd4: WideString;
    procedure Set_ImzaYetkilisiAd4(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan4: WideString;
    procedure Set_ImzaYetkilisiUnvan4(var Param1: WideString);
    function Get_ImzaYetkilisiAd3: WideString;
    procedure Set_ImzaYetkilisiAd3(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan3: WideString;
    procedure Set_ImzaYetkilisiUnvan3(var Param1: WideString);
    function Get_ImzaYetkilisiAd2: WideString;
    procedure Set_ImzaYetkilisiAd2(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan2: WideString;
    procedure Set_ImzaYetkilisiUnvan2(var Param1: WideString);
    function Get_ImzaYetkilisiAd1: WideString;
    procedure Set_ImzaYetkilisiAd1(var Param1: WideString);
    function Get_ImzaYetkilisiUnvan1: WideString;
    procedure Set_ImzaYetkilisiUnvan1(var Param1: WideString);
    function Get_OdemeTarihi: WideString;
    procedure Set_OdemeTarihi(var Param1: WideString);
    function Get_FirmaAd: WideString;
    procedure Set_FirmaAd(var Param1: WideString);
    function Get_MailBaslik: WideString;
    procedure Set_MailBaslik(var Param1: WideString);
    function Get_TalimatAdet: Smallint;
    function Get_KonsolideTalimatAdet: Smallint;
    function Get_HataliTalimatAdet: WideString;
    function Get_IBANsizTalimatAdet: WideString;
    function Get_HataAdet: WideString;
    function Get_ToplamTutar: WideString;
    function Get_IBANsizToplamTutar: WideString;
  public
    property DefaultInterface: _NYSBordro read GetDefaultInterface;
  published
    property EvrakNo: WideString read Get_EvrakNo write Set_EvrakNo;
    property ImzaYetkilisiAd4: WideString read Get_ImzaYetkilisiAd4 write Set_ImzaYetkilisiAd4;
    property ImzaYetkilisiUnvan4: WideString read Get_ImzaYetkilisiUnvan4 write Set_ImzaYetkilisiUnvan4;
    property ImzaYetkilisiAd3: WideString read Get_ImzaYetkilisiAd3 write Set_ImzaYetkilisiAd3;
    property ImzaYetkilisiUnvan3: WideString read Get_ImzaYetkilisiUnvan3 write Set_ImzaYetkilisiUnvan3;
    property ImzaYetkilisiAd2: WideString read Get_ImzaYetkilisiAd2 write Set_ImzaYetkilisiAd2;
    property ImzaYetkilisiUnvan2: WideString read Get_ImzaYetkilisiUnvan2 write Set_ImzaYetkilisiUnvan2;
    property ImzaYetkilisiAd1: WideString read Get_ImzaYetkilisiAd1 write Set_ImzaYetkilisiAd1;
    property ImzaYetkilisiUnvan1: WideString read Get_ImzaYetkilisiUnvan1 write Set_ImzaYetkilisiUnvan1;
    property OdemeTarihi: WideString read Get_OdemeTarihi write Set_OdemeTarihi;
    property FirmaAd: WideString read Get_FirmaAd write Set_FirmaAd;
    property MailBaslik: WideString read Get_MailBaslik write Set_MailBaslik;
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoHata provides a Create and CreateRemote method to          
// create instances of the default interface _Hata exposed by              
// the CoClass Hata. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoHata = class
    class function Create: _Hata;
    class function CreateRemote(const MachineName: string): _Hata;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : THata
// Help String      : 
// Default Interface: _Hata
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  THataProperties= class;
{$ENDIF}
  THata = class(TOleServer)
  private
    FIntf: _Hata;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: THataProperties;
    function GetServerProperties: THataProperties;
{$ENDIF}
    function GetDefaultInterface: _Hata;
  protected
    procedure InitServerData; override;
    function Get_Aciklama: WideString;
    function Get_No: WideString;
    function Get_Kaynak: WideString;
    function Get_Tipi: WideString;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: _Hata);
    procedure Disconnect; override;
    procedure Temizle;
    procedure Set_Values(const p_Tipi: WideString; const p_No: WideString; 
                         const p_Kaynak: WideString; const p_Aciklama: WideString);
    function To_String: WideString;
    property DefaultInterface: _Hata read GetDefaultInterface;
    property Aciklama: WideString read Get_Aciklama;
    property No: WideString read Get_No;
    property Kaynak: WideString read Get_Kaynak;
    property Tipi: WideString read Get_Tipi;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: THataProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : THata
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 THataProperties = class(TPersistent)
  private
    FServer:    THata;
    function    GetDefaultInterface: _Hata;
    constructor Create(AServer: THata);
  protected
    function Get_Aciklama: WideString;
    function Get_No: WideString;
    function Get_Kaynak: WideString;
    function Get_Tipi: WideString;
  public
    property DefaultInterface: _Hata read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoBanka provides a Create and CreateRemote method to          
// create instances of the default interface _Banka exposed by              
// the CoClass Banka. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoBanka = class
    class function Create: _Banka;
    class function CreateRemote(const MachineName: string): _Banka;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TBanka
// Help String      : 
// Default Interface: _Banka
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TBankaProperties= class;
{$ENDIF}
  TBanka = class(TOleServer)
  private
    FIntf: _Banka;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TBankaProperties;
    function GetServerProperties: TBankaProperties;
{$ENDIF}
    function GetDefaultInterface: _Banka;
  protected
    procedure InitServerData; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: _Banka);
    procedure Disconnect; override;
    function BankaBilgileriGüncelle1: WordBool;
    property DefaultInterface: _Banka read GetDefaultInterface;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TBankaProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TBanka
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TBankaProperties = class(TPersistent)
  private
    FServer:    TBanka;
    function    GetDefaultInterface: _Banka;
    constructor Create(AServer: TBanka);
  protected
  public
    property DefaultInterface: _Banka read GetDefaultInterface;
  published
  end;
{$ENDIF}


// *********************************************************************//
// The Class CoTalimat provides a Create and CreateRemote method to          
// create instances of the default interface _Talimat exposed by              
// the CoClass Talimat. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoTalimat = class
    class function Create: _Talimat;
    class function CreateRemote(const MachineName: string): _Talimat;
  end;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TTalimat
// Help String      : 
// Default Interface: _Talimat
// Def. Intf. DISP? : No
// Event   Interface: 
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TTalimatProperties= class;
{$ENDIF}
  TTalimat = class(TOleServer)
  private
    FIntf: _Talimat;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps: TTalimatProperties;
    function GetServerProperties: TTalimatProperties;
{$ENDIF}
    function GetDefaultInterface: _Talimat;
  protected
    procedure InitServerData; override;
    function Get_TCMBOdemeKodu: WideString;
    procedure Set_TCMBOdemeKodu(var Param1: WideString);
    function Get_Tutar: Currency;
    procedure Set_Tutar(var Param1: Currency);
    function Get_MasrafBilgisi: Smallint;
    procedure Set_MasrafBilgisi(var Param1: Smallint);
    function Get_FirmayaOzel1: WideString;
    procedure Set_FirmayaOzel1(var Param1: WideString);
    function Get_FirmayaOzel2: WideString;
    procedure Set_FirmayaOzel2(var Param1: WideString);
    function Get_FirmayaOzel3: WideString;
    procedure Set_FirmayaOzel3(var Param1: WideString);
    function Get_FirmayaOzel4: WideString;
    procedure Set_FirmayaOzel4(var Param1: WideString);
    function Get_FirmayaOzel5: WideString;
    procedure Set_FirmayaOzel5(var Param1: WideString);
    function Get_Durum: WideString;
    function Get_BorcluMuhasebeReferansNo: WideString;
    procedure Set_BorcluMuhasebeReferansNo(var Param1: WideString);
    function Get_BorcluKullaniciAciklama: WideString;
    procedure Set_BorcluKullaniciAciklama(var Param1: WideString);
    function Get_BorcluOtomatikAciklama: WideString;
    procedure Set_BorcluOtomatikAciklama(var Param1: WideString);
    function Get_BorcluHesapNo: WideString;
    procedure Set_BorcluHesapNo(var Param1: WideString);
    function Get_BorcluSubeKod: WideString;
    procedure Set_BorcluSubeKod(var Param1: WideString);
    function Get_BorcluSubeAd: WideString;
    procedure Set_BorcluSubeAd(var Param1: WideString);
    function Get_BorcluBankaKod: WideString;
    procedure Set_BorcluBankaKod(var Param1: WideString);
    function Get_BorcluBankaAd: WideString;
    procedure Set_BorcluBankaAd(var Param1: WideString);
    function Get_BorcluFirmaKod: WideString;
    procedure Set_BorcluFirmaKod(var Param1: WideString);
    function Get_BorcluFirmaUnvan: WideString;
    procedure Set_BorcluFirmaUnvan(var Param1: WideString);
    function Get_BorcluVergiNo: WideString;
    procedure Set_BorcluVergiNo(var Param1: WideString);
    function Get_AlacakliBankaKod: WideString;
    procedure Set_AlacakliBankaKod(var Param1: WideString);
    function Get_AlacakliBankaAd: WideString;
    procedure Set_AlacakliBankaAd(var Param1: WideString);
    function Get_AlacakliBabaAdi: WideString;
    procedure Set_AlacakliBabaAdi(var Param1: WideString);
    function Get_AlacakliVergiNo: WideString;
    procedure Set_AlacakliVergiNo(var Param1: WideString);
    function Get_AlacakliVergiD: WideString;
    procedure Set_AlacakliVergiD(var Param1: WideString);
    function Get_AlacakliAdres: WideString;
    procedure Set_AlacakliAdres(var Param1: WideString);
    function Get_AlacakliTelefonNo: WideString;
    procedure Set_AlacakliTelefonNo(var Param1: WideString);
    function Get_AlacakliFaksNo: WideString;
    procedure Set_AlacakliFaksNo(var Param1: WideString);
    function Get_AlacakliePosta1: WideString;
    procedure Set_AlacakliePosta1(var Param1: WideString);
    function Get_AlacakliePosta2: WideString;
    procedure Set_AlacakliePosta2(var Param1: WideString);
    function Get_AlacakliMuhasebeReferansNo: WideString;
    procedure Set_AlacakliMuhasebeReferansNo(var Param1: WideString);
    function Get_AlacakliOtomatikAciklama: WideString;
    procedure Set_AlacakliOtomatikAciklama(var Param1: WideString);
    function Get_AlacakliKullaniciAciklama: WideString;
    procedure Set_AlacakliKullaniciAciklama(var Param1: WideString);
    function Get_AlacakliHesapNo: WideString;
    procedure Set_AlacakliHesapNo(var Param1: WideString);
    function Get_AlacakliSubeKod: WideString;
    procedure Set_AlacakliSubeKod(var Param1: WideString);
    function Get_AlacakliSubead: WideString;
    procedure Set_AlacakliSubead(var Param1: WideString);
    function Get_AlacakliFirmaUnvan: WideString;
    procedure Set_AlacakliFirmaUnvan(var Param1: WideString);
    function Get_AlacakliFirmaKod: WideString;
    procedure Set_AlacakliFirmaKod(var Param1: WideString);
    function Get_HataAdet: Smallint;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: _Talimat);
    procedure Disconnect; override;
    procedure Temizle;
    procedure Borclu_Temizle;
    procedure Alacakli_Temizle;
    procedure Kaydet;
    function Get_Hatalar: WideString;
    function konsolide_equals(var comp: _Talimat): WordBool;
    procedure copyFrom(var comp: _Talimat);
    property DefaultInterface: _Talimat read GetDefaultInterface;
    property Durum: WideString read Get_Durum;
    property HataAdet: Smallint read Get_HataAdet;
    property TCMBOdemeKodu: WideString read Get_TCMBOdemeKodu write Set_TCMBOdemeKodu;
    property Tutar: Currency read Get_Tutar write Set_Tutar;
    property MasrafBilgisi: Smallint read Get_MasrafBilgisi write Set_MasrafBilgisi;
    property FirmayaOzel1: WideString read Get_FirmayaOzel1 write Set_FirmayaOzel1;
    property FirmayaOzel2: WideString read Get_FirmayaOzel2 write Set_FirmayaOzel2;
    property FirmayaOzel3: WideString read Get_FirmayaOzel3 write Set_FirmayaOzel3;
    property FirmayaOzel4: WideString read Get_FirmayaOzel4 write Set_FirmayaOzel4;
    property FirmayaOzel5: WideString read Get_FirmayaOzel5 write Set_FirmayaOzel5;
    property BorcluMuhasebeReferansNo: WideString read Get_BorcluMuhasebeReferansNo write Set_BorcluMuhasebeReferansNo;
    property BorcluKullaniciAciklama: WideString read Get_BorcluKullaniciAciklama write Set_BorcluKullaniciAciklama;
    property BorcluOtomatikAciklama: WideString read Get_BorcluOtomatikAciklama write Set_BorcluOtomatikAciklama;
    property BorcluHesapNo: WideString read Get_BorcluHesapNo write Set_BorcluHesapNo;
    property BorcluSubeKod: WideString read Get_BorcluSubeKod write Set_BorcluSubeKod;
    property BorcluSubeAd: WideString read Get_BorcluSubeAd write Set_BorcluSubeAd;
    property BorcluBankaKod: WideString read Get_BorcluBankaKod write Set_BorcluBankaKod;
    property BorcluBankaAd: WideString read Get_BorcluBankaAd write Set_BorcluBankaAd;
    property BorcluFirmaKod: WideString read Get_BorcluFirmaKod write Set_BorcluFirmaKod;
    property BorcluFirmaUnvan: WideString read Get_BorcluFirmaUnvan write Set_BorcluFirmaUnvan;
    property BorcluVergiNo: WideString read Get_BorcluVergiNo write Set_BorcluVergiNo;
    property AlacakliBankaKod: WideString read Get_AlacakliBankaKod write Set_AlacakliBankaKod;
    property AlacakliBankaAd: WideString read Get_AlacakliBankaAd write Set_AlacakliBankaAd;
    property AlacakliBabaAdi: WideString read Get_AlacakliBabaAdi write Set_AlacakliBabaAdi;
    property AlacakliVergiNo: WideString read Get_AlacakliVergiNo write Set_AlacakliVergiNo;
    property AlacakliVergiD: WideString read Get_AlacakliVergiD write Set_AlacakliVergiD;
    property AlacakliAdres: WideString read Get_AlacakliAdres write Set_AlacakliAdres;
    property AlacakliTelefonNo: WideString read Get_AlacakliTelefonNo write Set_AlacakliTelefonNo;
    property AlacakliFaksNo: WideString read Get_AlacakliFaksNo write Set_AlacakliFaksNo;
    property AlacakliePosta1: WideString read Get_AlacakliePosta1 write Set_AlacakliePosta1;
    property AlacakliePosta2: WideString read Get_AlacakliePosta2 write Set_AlacakliePosta2;
    property AlacakliMuhasebeReferansNo: WideString read Get_AlacakliMuhasebeReferansNo write Set_AlacakliMuhasebeReferansNo;
    property AlacakliOtomatikAciklama: WideString read Get_AlacakliOtomatikAciklama write Set_AlacakliOtomatikAciklama;
    property AlacakliKullaniciAciklama: WideString read Get_AlacakliKullaniciAciklama write Set_AlacakliKullaniciAciklama;
    property AlacakliHesapNo: WideString read Get_AlacakliHesapNo write Set_AlacakliHesapNo;
    property AlacakliSubeKod: WideString read Get_AlacakliSubeKod write Set_AlacakliSubeKod;
    property AlacakliSubead: WideString read Get_AlacakliSubead write Set_AlacakliSubead;
    property AlacakliFirmaUnvan: WideString read Get_AlacakliFirmaUnvan write Set_AlacakliFirmaUnvan;
    property AlacakliFirmaKod: WideString read Get_AlacakliFirmaKod write Set_AlacakliFirmaKod;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TTalimatProperties read GetServerProperties;
{$ENDIF}
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TTalimat
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TTalimatProperties = class(TPersistent)
  private
    FServer:    TTalimat;
    function    GetDefaultInterface: _Talimat;
    constructor Create(AServer: TTalimat);
  protected
    function Get_TCMBOdemeKodu: WideString;
    procedure Set_TCMBOdemeKodu(var Param1: WideString);
    function Get_Tutar: Currency;
    procedure Set_Tutar(var Param1: Currency);
    function Get_MasrafBilgisi: Smallint;
    procedure Set_MasrafBilgisi(var Param1: Smallint);
    function Get_FirmayaOzel1: WideString;
    procedure Set_FirmayaOzel1(var Param1: WideString);
    function Get_FirmayaOzel2: WideString;
    procedure Set_FirmayaOzel2(var Param1: WideString);
    function Get_FirmayaOzel3: WideString;
    procedure Set_FirmayaOzel3(var Param1: WideString);
    function Get_FirmayaOzel4: WideString;
    procedure Set_FirmayaOzel4(var Param1: WideString);
    function Get_FirmayaOzel5: WideString;
    procedure Set_FirmayaOzel5(var Param1: WideString);
    function Get_Durum: WideString;
    function Get_BorcluMuhasebeReferansNo: WideString;
    procedure Set_BorcluMuhasebeReferansNo(var Param1: WideString);
    function Get_BorcluKullaniciAciklama: WideString;
    procedure Set_BorcluKullaniciAciklama(var Param1: WideString);
    function Get_BorcluOtomatikAciklama: WideString;
    procedure Set_BorcluOtomatikAciklama(var Param1: WideString);
    function Get_BorcluHesapNo: WideString;
    procedure Set_BorcluHesapNo(var Param1: WideString);
    function Get_BorcluSubeKod: WideString;
    procedure Set_BorcluSubeKod(var Param1: WideString);
    function Get_BorcluSubeAd: WideString;
    procedure Set_BorcluSubeAd(var Param1: WideString);
    function Get_BorcluBankaKod: WideString;
    procedure Set_BorcluBankaKod(var Param1: WideString);
    function Get_BorcluBankaAd: WideString;
    procedure Set_BorcluBankaAd(var Param1: WideString);
    function Get_BorcluFirmaKod: WideString;
    procedure Set_BorcluFirmaKod(var Param1: WideString);
    function Get_BorcluFirmaUnvan: WideString;
    procedure Set_BorcluFirmaUnvan(var Param1: WideString);
    function Get_BorcluVergiNo: WideString;
    procedure Set_BorcluVergiNo(var Param1: WideString);
    function Get_AlacakliBankaKod: WideString;
    procedure Set_AlacakliBankaKod(var Param1: WideString);
    function Get_AlacakliBankaAd: WideString;
    procedure Set_AlacakliBankaAd(var Param1: WideString);
    function Get_AlacakliBabaAdi: WideString;
    procedure Set_AlacakliBabaAdi(var Param1: WideString);
    function Get_AlacakliVergiNo: WideString;
    procedure Set_AlacakliVergiNo(var Param1: WideString);
    function Get_AlacakliVergiD: WideString;
    procedure Set_AlacakliVergiD(var Param1: WideString);
    function Get_AlacakliAdres: WideString;
    procedure Set_AlacakliAdres(var Param1: WideString);
    function Get_AlacakliTelefonNo: WideString;
    procedure Set_AlacakliTelefonNo(var Param1: WideString);
    function Get_AlacakliFaksNo: WideString;
    procedure Set_AlacakliFaksNo(var Param1: WideString);
    function Get_AlacakliePosta1: WideString;
    procedure Set_AlacakliePosta1(var Param1: WideString);
    function Get_AlacakliePosta2: WideString;
    procedure Set_AlacakliePosta2(var Param1: WideString);
    function Get_AlacakliMuhasebeReferansNo: WideString;
    procedure Set_AlacakliMuhasebeReferansNo(var Param1: WideString);
    function Get_AlacakliOtomatikAciklama: WideString;
    procedure Set_AlacakliOtomatikAciklama(var Param1: WideString);
    function Get_AlacakliKullaniciAciklama: WideString;
    procedure Set_AlacakliKullaniciAciklama(var Param1: WideString);
    function Get_AlacakliHesapNo: WideString;
    procedure Set_AlacakliHesapNo(var Param1: WideString);
    function Get_AlacakliSubeKod: WideString;
    procedure Set_AlacakliSubeKod(var Param1: WideString);
    function Get_AlacakliSubead: WideString;
    procedure Set_AlacakliSubead(var Param1: WideString);
    function Get_AlacakliFirmaUnvan: WideString;
    procedure Set_AlacakliFirmaUnvan(var Param1: WideString);
    function Get_AlacakliFirmaKod: WideString;
    procedure Set_AlacakliFirmaKod(var Param1: WideString);
    function Get_HataAdet: Smallint;
  public
    property DefaultInterface: _Talimat read GetDefaultInterface;
  published
    property TCMBOdemeKodu: WideString read Get_TCMBOdemeKodu write Set_TCMBOdemeKodu;
    property Tutar: Currency read Get_Tutar write Set_Tutar;
    property MasrafBilgisi: Smallint read Get_MasrafBilgisi write Set_MasrafBilgisi;
    property FirmayaOzel1: WideString read Get_FirmayaOzel1 write Set_FirmayaOzel1;
    property FirmayaOzel2: WideString read Get_FirmayaOzel2 write Set_FirmayaOzel2;
    property FirmayaOzel3: WideString read Get_FirmayaOzel3 write Set_FirmayaOzel3;
    property FirmayaOzel4: WideString read Get_FirmayaOzel4 write Set_FirmayaOzel4;
    property FirmayaOzel5: WideString read Get_FirmayaOzel5 write Set_FirmayaOzel5;
    property BorcluMuhasebeReferansNo: WideString read Get_BorcluMuhasebeReferansNo write Set_BorcluMuhasebeReferansNo;
    property BorcluKullaniciAciklama: WideString read Get_BorcluKullaniciAciklama write Set_BorcluKullaniciAciklama;
    property BorcluOtomatikAciklama: WideString read Get_BorcluOtomatikAciklama write Set_BorcluOtomatikAciklama;
    property BorcluHesapNo: WideString read Get_BorcluHesapNo write Set_BorcluHesapNo;
    property BorcluSubeKod: WideString read Get_BorcluSubeKod write Set_BorcluSubeKod;
    property BorcluSubeAd: WideString read Get_BorcluSubeAd write Set_BorcluSubeAd;
    property BorcluBankaKod: WideString read Get_BorcluBankaKod write Set_BorcluBankaKod;
    property BorcluBankaAd: WideString read Get_BorcluBankaAd write Set_BorcluBankaAd;
    property BorcluFirmaKod: WideString read Get_BorcluFirmaKod write Set_BorcluFirmaKod;
    property BorcluFirmaUnvan: WideString read Get_BorcluFirmaUnvan write Set_BorcluFirmaUnvan;
    property BorcluVergiNo: WideString read Get_BorcluVergiNo write Set_BorcluVergiNo;
    property AlacakliBankaKod: WideString read Get_AlacakliBankaKod write Set_AlacakliBankaKod;
    property AlacakliBankaAd: WideString read Get_AlacakliBankaAd write Set_AlacakliBankaAd;
    property AlacakliBabaAdi: WideString read Get_AlacakliBabaAdi write Set_AlacakliBabaAdi;
    property AlacakliVergiNo: WideString read Get_AlacakliVergiNo write Set_AlacakliVergiNo;
    property AlacakliVergiD: WideString read Get_AlacakliVergiD write Set_AlacakliVergiD;
    property AlacakliAdres: WideString read Get_AlacakliAdres write Set_AlacakliAdres;
    property AlacakliTelefonNo: WideString read Get_AlacakliTelefonNo write Set_AlacakliTelefonNo;
    property AlacakliFaksNo: WideString read Get_AlacakliFaksNo write Set_AlacakliFaksNo;
    property AlacakliePosta1: WideString read Get_AlacakliePosta1 write Set_AlacakliePosta1;
    property AlacakliePosta2: WideString read Get_AlacakliePosta2 write Set_AlacakliePosta2;
    property AlacakliMuhasebeReferansNo: WideString read Get_AlacakliMuhasebeReferansNo write Set_AlacakliMuhasebeReferansNo;
    property AlacakliOtomatikAciklama: WideString read Get_AlacakliOtomatikAciklama write Set_AlacakliOtomatikAciklama;
    property AlacakliKullaniciAciklama: WideString read Get_AlacakliKullaniciAciklama write Set_AlacakliKullaniciAciklama;
    property AlacakliHesapNo: WideString read Get_AlacakliHesapNo write Set_AlacakliHesapNo;
    property AlacakliSubeKod: WideString read Get_AlacakliSubeKod write Set_AlacakliSubeKod;
    property AlacakliSubead: WideString read Get_AlacakliSubead write Set_AlacakliSubead;
    property AlacakliFirmaUnvan: WideString read Get_AlacakliFirmaUnvan write Set_AlacakliFirmaUnvan;
    property AlacakliFirmaKod: WideString read Get_AlacakliFirmaKod write Set_AlacakliFirmaKod;
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoNYSBordro.Create: _NYSBordro;
begin
  Result := CreateComObject(CLASS_NYSBordro) as _NYSBordro;
end;

class function CoNYSBordro.CreateRemote(const MachineName: string): _NYSBordro;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_NYSBordro) as _NYSBordro;
end;

procedure TNYSBordro.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{08D0D111-B212-4D1E-934B-637C200F3D70}';
    IntfIID:   '{CDE174D6-2153-4092-B61C-FC9F975F11A6}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TNYSBordro.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as _NYSBordro;
  end;
end;

procedure TNYSBordro.ConnectTo(svrIntf: _NYSBordro);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TNYSBordro.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TNYSBordro.GetDefaultInterface: _NYSBordro;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TNYSBordro.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TNYSBordroProperties.Create(Self);
{$ENDIF}
end;

destructor TNYSBordro.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TNYSBordro.GetServerProperties: TNYSBordroProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TNYSBordro.Get_EvrakNo: WideString;
begin
    Result := DefaultInterface.EvrakNo;
end;

procedure TNYSBordro.Set_EvrakNo(var Param1: WideString);
  { Warning: The property EvrakNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.EvrakNo := Param1;
end;

function TNYSBordro.Get_BordroPassword: WideString;
begin
    Result := DefaultInterface.BordroPassword;
end;

function TNYSBordro.Get_BordroAd: WideString;
begin
    Result := DefaultInterface.BordroAd;
end;

function TNYSBordro.Get_Durum: WideString;
begin
    Result := DefaultInterface.Durum;
end;

function TNYSBordro.Get_ExportDosyaYolu: WideString;
begin
    Result := DefaultInterface.ExportDosyaYolu;
end;

function TNYSBordro.Get_ImzaYetkilisiAd4: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd4;
end;

procedure TNYSBordro.Set_ImzaYetkilisiAd4(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd4 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd4 := Param1;
end;

function TNYSBordro.Get_ImzaYetkilisiUnvan4: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan4;
end;

procedure TNYSBordro.Set_ImzaYetkilisiUnvan4(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan4 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan4 := Param1;
end;

function TNYSBordro.Get_ImzaYetkilisiAd3: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd3;
end;

procedure TNYSBordro.Set_ImzaYetkilisiAd3(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd3 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd3 := Param1;
end;

function TNYSBordro.Get_ImzaYetkilisiUnvan3: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan3;
end;

procedure TNYSBordro.Set_ImzaYetkilisiUnvan3(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan3 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan3 := Param1;
end;

function TNYSBordro.Get_ImzaYetkilisiAd2: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd2;
end;

procedure TNYSBordro.Set_ImzaYetkilisiAd2(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd2 := Param1;
end;

function TNYSBordro.Get_ImzaYetkilisiUnvan2: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan2;
end;

procedure TNYSBordro.Set_ImzaYetkilisiUnvan2(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan2 := Param1;
end;

function TNYSBordro.Get_ImzaYetkilisiAd1: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd1;
end;

procedure TNYSBordro.Set_ImzaYetkilisiAd1(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd1 := Param1;
end;

function TNYSBordro.Get_ImzaYetkilisiUnvan1: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan1;
end;

procedure TNYSBordro.Set_ImzaYetkilisiUnvan1(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan1 := Param1;
end;

function TNYSBordro.Get_OdemeTarihi: WideString;
begin
    Result := DefaultInterface.OdemeTarihi;
end;

procedure TNYSBordro.Set_OdemeTarihi(var Param1: WideString);
  { Warning: The property OdemeTarihi has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.OdemeTarihi := Param1;
end;

function TNYSBordro.Get_FirmaAd: WideString;
begin
    Result := DefaultInterface.FirmaAd;
end;

procedure TNYSBordro.Set_FirmaAd(var Param1: WideString);
  { Warning: The property FirmaAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmaAd := Param1;
end;

function TNYSBordro.Get_MailBaslik: WideString;
begin
    Result := DefaultInterface.MailBaslik;
end;

procedure TNYSBordro.Set_MailBaslik(var Param1: WideString);
  { Warning: The property MailBaslik has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.MailBaslik := Param1;
end;

function TNYSBordro.Get_TalimatAdet: Smallint;
begin
    Result := DefaultInterface.TalimatAdet;
end;

function TNYSBordro.Get_KonsolideTalimatAdet: Smallint;
begin
    Result := DefaultInterface.KonsolideTalimatAdet;
end;

function TNYSBordro.Get_HataliTalimatAdet: WideString;
begin
    Result := DefaultInterface.HataliTalimatAdet;
end;

function TNYSBordro.Get_IBANsizTalimatAdet: WideString;
begin
    Result := DefaultInterface.IBANsizTalimatAdet;
end;

function TNYSBordro.Get_HataAdet: WideString;
begin
    Result := DefaultInterface.HataAdet;
end;

function TNYSBordro.Get_ToplamTutar: WideString;
begin
    Result := DefaultInterface.ToplamTutar;
end;

function TNYSBordro.Get_IBANsizToplamTutar: WideString;
begin
    Result := DefaultInterface.IBANsizToplamTutar;
end;

procedure TNYSBordro.Temizle;
begin
  DefaultInterface.Temizle;
end;

procedure TNYSBordro.Talimat_Olustur(const pTalimat: _Talimat);
begin
  DefaultInterface.Talimat_Olustur(pTalimat);
end;

function TNYSBordro.Get_Hatalar(var endLine: WideString): WideString;
begin
  Result := DefaultInterface.Get_Hatalar(endLine);
end;

function TNYSBordro.Kaydet: WordBool;
begin
  Result := DefaultInterface.Kaydet;
end;

function TNYSBordro.KapakYazdir: WordBool;
begin
  Result := DefaultInterface.KapakYazdir;
end;

function TNYSBordro.ListeYazdir: WideString;
begin
  Result := DefaultInterface.ListeYazdir;
end;

function TNYSBordro.ePostaIleGonder: WordBool;
begin
  Result := DefaultInterface.ePostaIleGonder;
end;

function TNYSBordro.ExportDosya(var Path: WideString): WideString;
begin
  Result := DefaultInterface.ExportDosya(Path);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TNYSBordroProperties.Create(AServer: TNYSBordro);
begin
  inherited Create;
  FServer := AServer;
end;

function TNYSBordroProperties.GetDefaultInterface: _NYSBordro;
begin
  Result := FServer.DefaultInterface;
end;

function TNYSBordroProperties.Get_EvrakNo: WideString;
begin
    Result := DefaultInterface.EvrakNo;
end;

procedure TNYSBordroProperties.Set_EvrakNo(var Param1: WideString);
  { Warning: The property EvrakNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.EvrakNo := Param1;
end;

function TNYSBordroProperties.Get_BordroPassword: WideString;
begin
    Result := DefaultInterface.BordroPassword;
end;

function TNYSBordroProperties.Get_BordroAd: WideString;
begin
    Result := DefaultInterface.BordroAd;
end;

function TNYSBordroProperties.Get_Durum: WideString;
begin
    Result := DefaultInterface.Durum;
end;

function TNYSBordroProperties.Get_ExportDosyaYolu: WideString;
begin
    Result := DefaultInterface.ExportDosyaYolu;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiAd4: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd4;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiAd4(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd4 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd4 := Param1;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiUnvan4: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan4;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiUnvan4(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan4 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan4 := Param1;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiAd3: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd3;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiAd3(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd3 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd3 := Param1;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiUnvan3: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan3;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiUnvan3(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan3 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan3 := Param1;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiAd2: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd2;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiAd2(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd2 := Param1;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiUnvan2: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan2;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiUnvan2(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan2 := Param1;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiAd1: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiAd1;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiAd1(var Param1: WideString);
  { Warning: The property ImzaYetkilisiAd1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiAd1 := Param1;
end;

function TNYSBordroProperties.Get_ImzaYetkilisiUnvan1: WideString;
begin
    Result := DefaultInterface.ImzaYetkilisiUnvan1;
end;

procedure TNYSBordroProperties.Set_ImzaYetkilisiUnvan1(var Param1: WideString);
  { Warning: The property ImzaYetkilisiUnvan1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.ImzaYetkilisiUnvan1 := Param1;
end;

function TNYSBordroProperties.Get_OdemeTarihi: WideString;
begin
    Result := DefaultInterface.OdemeTarihi;
end;

procedure TNYSBordroProperties.Set_OdemeTarihi(var Param1: WideString);
  { Warning: The property OdemeTarihi has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.OdemeTarihi := Param1;
end;

function TNYSBordroProperties.Get_FirmaAd: WideString;
begin
    Result := DefaultInterface.FirmaAd;
end;

procedure TNYSBordroProperties.Set_FirmaAd(var Param1: WideString);
  { Warning: The property FirmaAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmaAd := Param1;
end;

function TNYSBordroProperties.Get_MailBaslik: WideString;
begin
    Result := DefaultInterface.MailBaslik;
end;

procedure TNYSBordroProperties.Set_MailBaslik(var Param1: WideString);
  { Warning: The property MailBaslik has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.MailBaslik := Param1;
end;

function TNYSBordroProperties.Get_TalimatAdet: Smallint;
begin
    Result := DefaultInterface.TalimatAdet;
end;

function TNYSBordroProperties.Get_KonsolideTalimatAdet: Smallint;
begin
    Result := DefaultInterface.KonsolideTalimatAdet;
end;

function TNYSBordroProperties.Get_HataliTalimatAdet: WideString;
begin
    Result := DefaultInterface.HataliTalimatAdet;
end;

function TNYSBordroProperties.Get_IBANsizTalimatAdet: WideString;
begin
    Result := DefaultInterface.IBANsizTalimatAdet;
end;

function TNYSBordroProperties.Get_HataAdet: WideString;
begin
    Result := DefaultInterface.HataAdet;
end;

function TNYSBordroProperties.Get_ToplamTutar: WideString;
begin
    Result := DefaultInterface.ToplamTutar;
end;

function TNYSBordroProperties.Get_IBANsizToplamTutar: WideString;
begin
    Result := DefaultInterface.IBANsizToplamTutar;
end;

{$ENDIF}

class function CoHata.Create: _Hata;
begin
  Result := CreateComObject(CLASS_Hata) as _Hata;
end;

class function CoHata.CreateRemote(const MachineName: string): _Hata;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Hata) as _Hata;
end;

procedure THata.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{540F16F0-4B03-4F30-8930-526B72DE1B7D}';
    IntfIID:   '{8E1FDD07-954A-4719-A670-FD00970ED719}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure THata.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as _Hata;
  end;
end;

procedure THata.ConnectTo(svrIntf: _Hata);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure THata.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function THata.GetDefaultInterface: _Hata;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor THata.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := THataProperties.Create(Self);
{$ENDIF}
end;

destructor THata.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function THata.GetServerProperties: THataProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function THata.Get_Aciklama: WideString;
begin
    Result := DefaultInterface.Aciklama;
end;

function THata.Get_No: WideString;
begin
    Result := DefaultInterface.No;
end;

function THata.Get_Kaynak: WideString;
begin
    Result := DefaultInterface.Kaynak;
end;

function THata.Get_Tipi: WideString;
begin
    Result := DefaultInterface.Tipi;
end;

procedure THata.Temizle;
begin
  DefaultInterface.Temizle;
end;

procedure THata.Set_Values(const p_Tipi: WideString; const p_No: WideString; 
                           const p_Kaynak: WideString; const p_Aciklama: WideString);
begin
  DefaultInterface.Set_Values(p_Tipi, p_No, p_Kaynak, p_Aciklama);
end;

function THata.To_String: WideString;
begin
  Result := DefaultInterface.To_String;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor THataProperties.Create(AServer: THata);
begin
  inherited Create;
  FServer := AServer;
end;

function THataProperties.GetDefaultInterface: _Hata;
begin
  Result := FServer.DefaultInterface;
end;

function THataProperties.Get_Aciklama: WideString;
begin
    Result := DefaultInterface.Aciklama;
end;

function THataProperties.Get_No: WideString;
begin
    Result := DefaultInterface.No;
end;

function THataProperties.Get_Kaynak: WideString;
begin
    Result := DefaultInterface.Kaynak;
end;

function THataProperties.Get_Tipi: WideString;
begin
    Result := DefaultInterface.Tipi;
end;

{$ENDIF}

class function CoBanka.Create: _Banka;
begin
  Result := CreateComObject(CLASS_Banka) as _Banka;
end;

class function CoBanka.CreateRemote(const MachineName: string): _Banka;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Banka) as _Banka;
end;

procedure TBanka.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{39BA0191-C007-4642-8B12-5F0EB3DF1FB8}';
    IntfIID:   '{2E86B6BE-F34A-4F4B-8F4C-D9E47F132914}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TBanka.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as _Banka;
  end;
end;

procedure TBanka.ConnectTo(svrIntf: _Banka);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TBanka.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TBanka.GetDefaultInterface: _Banka;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TBanka.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TBankaProperties.Create(Self);
{$ENDIF}
end;

destructor TBanka.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TBanka.GetServerProperties: TBankaProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TBanka.BankaBilgileriGüncelle1: WordBool;
begin
  Result := DefaultInterface.BankaBilgileriGüncelle1;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TBankaProperties.Create(AServer: TBanka);
begin
  inherited Create;
  FServer := AServer;
end;

function TBankaProperties.GetDefaultInterface: _Banka;
begin
  Result := FServer.DefaultInterface;
end;

{$ENDIF}

class function CoTalimat.Create: _Talimat;
begin
  Result := CreateComObject(CLASS_Talimat) as _Talimat;
end;

class function CoTalimat.CreateRemote(const MachineName: string): _Talimat;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Talimat) as _Talimat;
end;

procedure TTalimat.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{8DD9CE27-4DE2-4AB2-AA68-B9EA1DD3290E}';
    IntfIID:   '{B7B7EB4F-2C7C-42A9-833A-BE7BDD1E3E75}';
    EventIID:  '';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TTalimat.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    Fintf:= punk as _Talimat;
  end;
end;

procedure TTalimat.ConnectTo(svrIntf: _Talimat);
begin
  Disconnect;
  FIntf := svrIntf;
end;

procedure TTalimat.DisConnect;
begin
  if Fintf <> nil then
  begin
    FIntf := nil;
  end;
end;

function TTalimat.GetDefaultInterface: _Talimat;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call "Connect" or "ConnectTo" before this operation');
  Result := FIntf;
end;

constructor TTalimat.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TTalimatProperties.Create(Self);
{$ENDIF}
end;

destructor TTalimat.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TTalimat.GetServerProperties: TTalimatProperties;
begin
  Result := FProps;
end;
{$ENDIF}

function TTalimat.Get_TCMBOdemeKodu: WideString;
begin
    Result := DefaultInterface.TCMBOdemeKodu;
end;

procedure TTalimat.Set_TCMBOdemeKodu(var Param1: WideString);
  { Warning: The property TCMBOdemeKodu has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.TCMBOdemeKodu := Param1;
end;

function TTalimat.Get_Tutar: Currency;
begin
    Result := DefaultInterface.Tutar;
end;

procedure TTalimat.Set_Tutar(var Param1: Currency);
begin
  DefaultInterface.Set_Tutar(Param1);
end;

function TTalimat.Get_MasrafBilgisi: Smallint;
begin
    Result := DefaultInterface.MasrafBilgisi;
end;

procedure TTalimat.Set_MasrafBilgisi(var Param1: Smallint);
begin
  DefaultInterface.Set_MasrafBilgisi(Param1);
end;

function TTalimat.Get_FirmayaOzel1: WideString;
begin
    Result := DefaultInterface.FirmayaOzel1;
end;

procedure TTalimat.Set_FirmayaOzel1(var Param1: WideString);
  { Warning: The property FirmayaOzel1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel1 := Param1;
end;

function TTalimat.Get_FirmayaOzel2: WideString;
begin
    Result := DefaultInterface.FirmayaOzel2;
end;

procedure TTalimat.Set_FirmayaOzel2(var Param1: WideString);
  { Warning: The property FirmayaOzel2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel2 := Param1;
end;

function TTalimat.Get_FirmayaOzel3: WideString;
begin
    Result := DefaultInterface.FirmayaOzel3;
end;

procedure TTalimat.Set_FirmayaOzel3(var Param1: WideString);
  { Warning: The property FirmayaOzel3 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel3 := Param1;
end;

function TTalimat.Get_FirmayaOzel4: WideString;
begin
    Result := DefaultInterface.FirmayaOzel4;
end;

procedure TTalimat.Set_FirmayaOzel4(var Param1: WideString);
  { Warning: The property FirmayaOzel4 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel4 := Param1;
end;

function TTalimat.Get_FirmayaOzel5: WideString;
begin
    Result := DefaultInterface.FirmayaOzel5;
end;

procedure TTalimat.Set_FirmayaOzel5(var Param1: WideString);
  { Warning: The property FirmayaOzel5 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel5 := Param1;
end;

function TTalimat.Get_Durum: WideString;
begin
    Result := DefaultInterface.Durum;
end;

function TTalimat.Get_BorcluMuhasebeReferansNo: WideString;
begin
    Result := DefaultInterface.BorcluMuhasebeReferansNo;
end;

procedure TTalimat.Set_BorcluMuhasebeReferansNo(var Param1: WideString);
  { Warning: The property BorcluMuhasebeReferansNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluMuhasebeReferansNo := Param1;
end;

function TTalimat.Get_BorcluKullaniciAciklama: WideString;
begin
    Result := DefaultInterface.BorcluKullaniciAciklama;
end;

procedure TTalimat.Set_BorcluKullaniciAciklama(var Param1: WideString);
  { Warning: The property BorcluKullaniciAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluKullaniciAciklama := Param1;
end;

function TTalimat.Get_BorcluOtomatikAciklama: WideString;
begin
    Result := DefaultInterface.BorcluOtomatikAciklama;
end;

procedure TTalimat.Set_BorcluOtomatikAciklama(var Param1: WideString);
  { Warning: The property BorcluOtomatikAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluOtomatikAciklama := Param1;
end;

function TTalimat.Get_BorcluHesapNo: WideString;
begin
    Result := DefaultInterface.BorcluHesapNo;
end;

procedure TTalimat.Set_BorcluHesapNo(var Param1: WideString);
  { Warning: The property BorcluHesapNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluHesapNo := Param1;
end;

function TTalimat.Get_BorcluSubeKod: WideString;
begin
    Result := DefaultInterface.BorcluSubeKod;
end;

procedure TTalimat.Set_BorcluSubeKod(var Param1: WideString);
  { Warning: The property BorcluSubeKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluSubeKod := Param1;
end;

function TTalimat.Get_BorcluSubeAd: WideString;
begin
    Result := DefaultInterface.BorcluSubeAd;
end;

procedure TTalimat.Set_BorcluSubeAd(var Param1: WideString);
  { Warning: The property BorcluSubeAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluSubeAd := Param1;
end;

function TTalimat.Get_BorcluBankaKod: WideString;
begin
    Result := DefaultInterface.BorcluBankaKod;
end;

procedure TTalimat.Set_BorcluBankaKod(var Param1: WideString);
  { Warning: The property BorcluBankaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluBankaKod := Param1;
end;

function TTalimat.Get_BorcluBankaAd: WideString;
begin
    Result := DefaultInterface.BorcluBankaAd;
end;

procedure TTalimat.Set_BorcluBankaAd(var Param1: WideString);
  { Warning: The property BorcluBankaAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluBankaAd := Param1;
end;

function TTalimat.Get_BorcluFirmaKod: WideString;
begin
    Result := DefaultInterface.BorcluFirmaKod;
end;

procedure TTalimat.Set_BorcluFirmaKod(var Param1: WideString);
  { Warning: The property BorcluFirmaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluFirmaKod := Param1;
end;

function TTalimat.Get_BorcluFirmaUnvan: WideString;
begin
    Result := DefaultInterface.BorcluFirmaUnvan;
end;

procedure TTalimat.Set_BorcluFirmaUnvan(var Param1: WideString);
  { Warning: The property BorcluFirmaUnvan has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluFirmaUnvan := Param1;
end;

function TTalimat.Get_BorcluVergiNo: WideString;
begin
    Result := DefaultInterface.BorcluVergiNo;
end;

procedure TTalimat.Set_BorcluVergiNo(var Param1: WideString);
  { Warning: The property BorcluVergiNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluVergiNo := Param1;
end;

function TTalimat.Get_AlacakliBankaKod: WideString;
begin
    Result := DefaultInterface.AlacakliBankaKod;
end;

procedure TTalimat.Set_AlacakliBankaKod(var Param1: WideString);
  { Warning: The property AlacakliBankaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliBankaKod := Param1;
end;

function TTalimat.Get_AlacakliBankaAd: WideString;
begin
    Result := DefaultInterface.AlacakliBankaAd;
end;

procedure TTalimat.Set_AlacakliBankaAd(var Param1: WideString);
  { Warning: The property AlacakliBankaAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliBankaAd := Param1;
end;

function TTalimat.Get_AlacakliBabaAdi: WideString;
begin
    Result := DefaultInterface.AlacakliBabaAdi;
end;

procedure TTalimat.Set_AlacakliBabaAdi(var Param1: WideString);
  { Warning: The property AlacakliBabaAdi has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliBabaAdi := Param1;
end;

function TTalimat.Get_AlacakliVergiNo: WideString;
begin
    Result := DefaultInterface.AlacakliVergiNo;
end;

procedure TTalimat.Set_AlacakliVergiNo(var Param1: WideString);
  { Warning: The property AlacakliVergiNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliVergiNo := Param1;
end;

function TTalimat.Get_AlacakliVergiD: WideString;
begin
    Result := DefaultInterface.AlacakliVergiD;
end;

procedure TTalimat.Set_AlacakliVergiD(var Param1: WideString);
  { Warning: The property AlacakliVergiD has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliVergiD := Param1;
end;

function TTalimat.Get_AlacakliAdres: WideString;
begin
    Result := DefaultInterface.AlacakliAdres;
end;

procedure TTalimat.Set_AlacakliAdres(var Param1: WideString);
  { Warning: The property AlacakliAdres has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliAdres := Param1;
end;

function TTalimat.Get_AlacakliTelefonNo: WideString;
begin
    Result := DefaultInterface.AlacakliTelefonNo;
end;

procedure TTalimat.Set_AlacakliTelefonNo(var Param1: WideString);
  { Warning: The property AlacakliTelefonNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliTelefonNo := Param1;
end;

function TTalimat.Get_AlacakliFaksNo: WideString;
begin
    Result := DefaultInterface.AlacakliFaksNo;
end;

procedure TTalimat.Set_AlacakliFaksNo(var Param1: WideString);
  { Warning: The property AlacakliFaksNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliFaksNo := Param1;
end;

function TTalimat.Get_AlacakliePosta1: WideString;
begin
    Result := DefaultInterface.AlacakliePosta1;
end;

procedure TTalimat.Set_AlacakliePosta1(var Param1: WideString);
  { Warning: The property AlacakliePosta1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliePosta1 := Param1;
end;

function TTalimat.Get_AlacakliePosta2: WideString;
begin
    Result := DefaultInterface.AlacakliePosta2;
end;

procedure TTalimat.Set_AlacakliePosta2(var Param1: WideString);
  { Warning: The property AlacakliePosta2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliePosta2 := Param1;
end;

function TTalimat.Get_AlacakliMuhasebeReferansNo: WideString;
begin
    Result := DefaultInterface.AlacakliMuhasebeReferansNo;
end;

procedure TTalimat.Set_AlacakliMuhasebeReferansNo(var Param1: WideString);
  { Warning: The property AlacakliMuhasebeReferansNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliMuhasebeReferansNo := Param1;
end;

function TTalimat.Get_AlacakliOtomatikAciklama: WideString;
begin
    Result := DefaultInterface.AlacakliOtomatikAciklama;
end;

procedure TTalimat.Set_AlacakliOtomatikAciklama(var Param1: WideString);
  { Warning: The property AlacakliOtomatikAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliOtomatikAciklama := Param1;
end;

function TTalimat.Get_AlacakliKullaniciAciklama: WideString;
begin
    Result := DefaultInterface.AlacakliKullaniciAciklama;
end;

procedure TTalimat.Set_AlacakliKullaniciAciklama(var Param1: WideString);
  { Warning: The property AlacakliKullaniciAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliKullaniciAciklama := Param1;
end;

function TTalimat.Get_AlacakliHesapNo: WideString;
begin
    Result := DefaultInterface.AlacakliHesapNo;
end;

procedure TTalimat.Set_AlacakliHesapNo(var Param1: WideString);
  { Warning: The property AlacakliHesapNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliHesapNo := Param1;
end;

function TTalimat.Get_AlacakliSubeKod: WideString;
begin
    Result := DefaultInterface.AlacakliSubeKod;
end;

procedure TTalimat.Set_AlacakliSubeKod(var Param1: WideString);
  { Warning: The property AlacakliSubeKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliSubeKod := Param1;
end;

function TTalimat.Get_AlacakliSubead: WideString;
begin
    Result := DefaultInterface.AlacakliSubead;
end;

procedure TTalimat.Set_AlacakliSubead(var Param1: WideString);
  { Warning: The property AlacakliSubead has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliSubead := Param1;
end;

function TTalimat.Get_AlacakliFirmaUnvan: WideString;
begin
    Result := DefaultInterface.AlacakliFirmaUnvan;
end;

procedure TTalimat.Set_AlacakliFirmaUnvan(var Param1: WideString);
  { Warning: The property AlacakliFirmaUnvan has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliFirmaUnvan := Param1;
end;

function TTalimat.Get_AlacakliFirmaKod: WideString;
begin
    Result := DefaultInterface.AlacakliFirmaKod;
end;

procedure TTalimat.Set_AlacakliFirmaKod(var Param1: WideString);
  { Warning: The property AlacakliFirmaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliFirmaKod := Param1;
end;

function TTalimat.Get_HataAdet: Smallint;
begin
    Result := DefaultInterface.HataAdet;
end;

procedure TTalimat.Temizle;
begin
  DefaultInterface.Temizle;
end;

procedure TTalimat.Borclu_Temizle;
begin
  DefaultInterface.Borclu_Temizle;
end;

procedure TTalimat.Alacakli_Temizle;
begin
  DefaultInterface.Alacakli_Temizle;
end;

procedure TTalimat.Kaydet;
begin
  DefaultInterface.Kaydet;
end;

function TTalimat.Get_Hatalar: WideString;
begin
  Result := DefaultInterface.Get_Hatalar;
end;

function TTalimat.konsolide_equals(var comp: _Talimat): WordBool;
begin
  Result := DefaultInterface.konsolide_equals(comp);
end;

procedure TTalimat.copyFrom(var comp: _Talimat);
begin
  DefaultInterface.copyFrom(comp);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TTalimatProperties.Create(AServer: TTalimat);
begin
  inherited Create;
  FServer := AServer;
end;

function TTalimatProperties.GetDefaultInterface: _Talimat;
begin
  Result := FServer.DefaultInterface;
end;

function TTalimatProperties.Get_TCMBOdemeKodu: WideString;
begin
    Result := DefaultInterface.TCMBOdemeKodu;
end;

procedure TTalimatProperties.Set_TCMBOdemeKodu(var Param1: WideString);
  { Warning: The property TCMBOdemeKodu has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.TCMBOdemeKodu := Param1;
end;

function TTalimatProperties.Get_Tutar: Currency;
begin
    Result := DefaultInterface.Tutar;
end;

procedure TTalimatProperties.Set_Tutar(var Param1: Currency);
begin
  DefaultInterface.Set_Tutar(Param1);
end;

function TTalimatProperties.Get_MasrafBilgisi: Smallint;
begin
    Result := DefaultInterface.MasrafBilgisi;
end;

procedure TTalimatProperties.Set_MasrafBilgisi(var Param1: Smallint);
begin
  DefaultInterface.Set_MasrafBilgisi(Param1);
end;

function TTalimatProperties.Get_FirmayaOzel1: WideString;
begin
    Result := DefaultInterface.FirmayaOzel1;
end;

procedure TTalimatProperties.Set_FirmayaOzel1(var Param1: WideString);
  { Warning: The property FirmayaOzel1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel1 := Param1;
end;

function TTalimatProperties.Get_FirmayaOzel2: WideString;
begin
    Result := DefaultInterface.FirmayaOzel2;
end;

procedure TTalimatProperties.Set_FirmayaOzel2(var Param1: WideString);
  { Warning: The property FirmayaOzel2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel2 := Param1;
end;

function TTalimatProperties.Get_FirmayaOzel3: WideString;
begin
    Result := DefaultInterface.FirmayaOzel3;
end;

procedure TTalimatProperties.Set_FirmayaOzel3(var Param1: WideString);
  { Warning: The property FirmayaOzel3 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel3 := Param1;
end;

function TTalimatProperties.Get_FirmayaOzel4: WideString;
begin
    Result := DefaultInterface.FirmayaOzel4;
end;

procedure TTalimatProperties.Set_FirmayaOzel4(var Param1: WideString);
  { Warning: The property FirmayaOzel4 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel4 := Param1;
end;

function TTalimatProperties.Get_FirmayaOzel5: WideString;
begin
    Result := DefaultInterface.FirmayaOzel5;
end;

procedure TTalimatProperties.Set_FirmayaOzel5(var Param1: WideString);
  { Warning: The property FirmayaOzel5 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.FirmayaOzel5 := Param1;
end;

function TTalimatProperties.Get_Durum: WideString;
begin
    Result := DefaultInterface.Durum;
end;

function TTalimatProperties.Get_BorcluMuhasebeReferansNo: WideString;
begin
    Result := DefaultInterface.BorcluMuhasebeReferansNo;
end;

procedure TTalimatProperties.Set_BorcluMuhasebeReferansNo(var Param1: WideString);
  { Warning: The property BorcluMuhasebeReferansNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluMuhasebeReferansNo := Param1;
end;

function TTalimatProperties.Get_BorcluKullaniciAciklama: WideString;
begin
    Result := DefaultInterface.BorcluKullaniciAciklama;
end;

procedure TTalimatProperties.Set_BorcluKullaniciAciklama(var Param1: WideString);
  { Warning: The property BorcluKullaniciAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluKullaniciAciklama := Param1;
end;

function TTalimatProperties.Get_BorcluOtomatikAciklama: WideString;
begin
    Result := DefaultInterface.BorcluOtomatikAciklama;
end;

procedure TTalimatProperties.Set_BorcluOtomatikAciklama(var Param1: WideString);
  { Warning: The property BorcluOtomatikAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluOtomatikAciklama := Param1;
end;

function TTalimatProperties.Get_BorcluHesapNo: WideString;
begin
    Result := DefaultInterface.BorcluHesapNo;
end;

procedure TTalimatProperties.Set_BorcluHesapNo(var Param1: WideString);
  { Warning: The property BorcluHesapNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluHesapNo := Param1;
end;

function TTalimatProperties.Get_BorcluSubeKod: WideString;
begin
    Result := DefaultInterface.BorcluSubeKod;
end;

procedure TTalimatProperties.Set_BorcluSubeKod(var Param1: WideString);
  { Warning: The property BorcluSubeKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluSubeKod := Param1;
end;

function TTalimatProperties.Get_BorcluSubeAd: WideString;
begin
    Result := DefaultInterface.BorcluSubeAd;
end;

procedure TTalimatProperties.Set_BorcluSubeAd(var Param1: WideString);
  { Warning: The property BorcluSubeAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluSubeAd := Param1;
end;

function TTalimatProperties.Get_BorcluBankaKod: WideString;
begin
    Result := DefaultInterface.BorcluBankaKod;
end;

procedure TTalimatProperties.Set_BorcluBankaKod(var Param1: WideString);
  { Warning: The property BorcluBankaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluBankaKod := Param1;
end;

function TTalimatProperties.Get_BorcluBankaAd: WideString;
begin
    Result := DefaultInterface.BorcluBankaAd;
end;

procedure TTalimatProperties.Set_BorcluBankaAd(var Param1: WideString);
  { Warning: The property BorcluBankaAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluBankaAd := Param1;
end;

function TTalimatProperties.Get_BorcluFirmaKod: WideString;
begin
    Result := DefaultInterface.BorcluFirmaKod;
end;

procedure TTalimatProperties.Set_BorcluFirmaKod(var Param1: WideString);
  { Warning: The property BorcluFirmaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluFirmaKod := Param1;
end;

function TTalimatProperties.Get_BorcluFirmaUnvan: WideString;
begin
    Result := DefaultInterface.BorcluFirmaUnvan;
end;

procedure TTalimatProperties.Set_BorcluFirmaUnvan(var Param1: WideString);
  { Warning: The property BorcluFirmaUnvan has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluFirmaUnvan := Param1;
end;

function TTalimatProperties.Get_BorcluVergiNo: WideString;
begin
    Result := DefaultInterface.BorcluVergiNo;
end;

procedure TTalimatProperties.Set_BorcluVergiNo(var Param1: WideString);
  { Warning: The property BorcluVergiNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.BorcluVergiNo := Param1;
end;

function TTalimatProperties.Get_AlacakliBankaKod: WideString;
begin
    Result := DefaultInterface.AlacakliBankaKod;
end;

procedure TTalimatProperties.Set_AlacakliBankaKod(var Param1: WideString);
  { Warning: The property AlacakliBankaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliBankaKod := Param1;
end;

function TTalimatProperties.Get_AlacakliBankaAd: WideString;
begin
    Result := DefaultInterface.AlacakliBankaAd;
end;

procedure TTalimatProperties.Set_AlacakliBankaAd(var Param1: WideString);
  { Warning: The property AlacakliBankaAd has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliBankaAd := Param1;
end;

function TTalimatProperties.Get_AlacakliBabaAdi: WideString;
begin
    Result := DefaultInterface.AlacakliBabaAdi;
end;

procedure TTalimatProperties.Set_AlacakliBabaAdi(var Param1: WideString);
  { Warning: The property AlacakliBabaAdi has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliBabaAdi := Param1;
end;

function TTalimatProperties.Get_AlacakliVergiNo: WideString;
begin
    Result := DefaultInterface.AlacakliVergiNo;
end;

procedure TTalimatProperties.Set_AlacakliVergiNo(var Param1: WideString);
  { Warning: The property AlacakliVergiNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliVergiNo := Param1;
end;

function TTalimatProperties.Get_AlacakliVergiD: WideString;
begin
    Result := DefaultInterface.AlacakliVergiD;
end;

procedure TTalimatProperties.Set_AlacakliVergiD(var Param1: WideString);
  { Warning: The property AlacakliVergiD has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliVergiD := Param1;
end;

function TTalimatProperties.Get_AlacakliAdres: WideString;
begin
    Result := DefaultInterface.AlacakliAdres;
end;

procedure TTalimatProperties.Set_AlacakliAdres(var Param1: WideString);
  { Warning: The property AlacakliAdres has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliAdres := Param1;
end;

function TTalimatProperties.Get_AlacakliTelefonNo: WideString;
begin
    Result := DefaultInterface.AlacakliTelefonNo;
end;

procedure TTalimatProperties.Set_AlacakliTelefonNo(var Param1: WideString);
  { Warning: The property AlacakliTelefonNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliTelefonNo := Param1;
end;

function TTalimatProperties.Get_AlacakliFaksNo: WideString;
begin
    Result := DefaultInterface.AlacakliFaksNo;
end;

procedure TTalimatProperties.Set_AlacakliFaksNo(var Param1: WideString);
  { Warning: The property AlacakliFaksNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliFaksNo := Param1;
end;

function TTalimatProperties.Get_AlacakliePosta1: WideString;
begin
    Result := DefaultInterface.AlacakliePosta1;
end;

procedure TTalimatProperties.Set_AlacakliePosta1(var Param1: WideString);
  { Warning: The property AlacakliePosta1 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliePosta1 := Param1;
end;

function TTalimatProperties.Get_AlacakliePosta2: WideString;
begin
    Result := DefaultInterface.AlacakliePosta2;
end;

procedure TTalimatProperties.Set_AlacakliePosta2(var Param1: WideString);
  { Warning: The property AlacakliePosta2 has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliePosta2 := Param1;
end;

function TTalimatProperties.Get_AlacakliMuhasebeReferansNo: WideString;
begin
    Result := DefaultInterface.AlacakliMuhasebeReferansNo;
end;

procedure TTalimatProperties.Set_AlacakliMuhasebeReferansNo(var Param1: WideString);
  { Warning: The property AlacakliMuhasebeReferansNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliMuhasebeReferansNo := Param1;
end;

function TTalimatProperties.Get_AlacakliOtomatikAciklama: WideString;
begin
    Result := DefaultInterface.AlacakliOtomatikAciklama;
end;

procedure TTalimatProperties.Set_AlacakliOtomatikAciklama(var Param1: WideString);
  { Warning: The property AlacakliOtomatikAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliOtomatikAciklama := Param1;
end;

function TTalimatProperties.Get_AlacakliKullaniciAciklama: WideString;
begin
    Result := DefaultInterface.AlacakliKullaniciAciklama;
end;

procedure TTalimatProperties.Set_AlacakliKullaniciAciklama(var Param1: WideString);
  { Warning: The property AlacakliKullaniciAciklama has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliKullaniciAciklama := Param1;
end;

function TTalimatProperties.Get_AlacakliHesapNo: WideString;
begin
    Result := DefaultInterface.AlacakliHesapNo;
end;

procedure TTalimatProperties.Set_AlacakliHesapNo(var Param1: WideString);
  { Warning: The property AlacakliHesapNo has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliHesapNo := Param1;
end;

function TTalimatProperties.Get_AlacakliSubeKod: WideString;
begin
    Result := DefaultInterface.AlacakliSubeKod;
end;

procedure TTalimatProperties.Set_AlacakliSubeKod(var Param1: WideString);
  { Warning: The property AlacakliSubeKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliSubeKod := Param1;
end;

function TTalimatProperties.Get_AlacakliSubead: WideString;
begin
    Result := DefaultInterface.AlacakliSubead;
end;

procedure TTalimatProperties.Set_AlacakliSubead(var Param1: WideString);
  { Warning: The property AlacakliSubead has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliSubead := Param1;
end;

function TTalimatProperties.Get_AlacakliFirmaUnvan: WideString;
begin
    Result := DefaultInterface.AlacakliFirmaUnvan;
end;

procedure TTalimatProperties.Set_AlacakliFirmaUnvan(var Param1: WideString);
  { Warning: The property AlacakliFirmaUnvan has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliFirmaUnvan := Param1;
end;

function TTalimatProperties.Get_AlacakliFirmaKod: WideString;
begin
    Result := DefaultInterface.AlacakliFirmaKod;
end;

procedure TTalimatProperties.Set_AlacakliFirmaKod(var Param1: WideString);
  { Warning: The property AlacakliFirmaKod has a setter and a getter whose
    types do not match. Delphi was unable to generate a property of
    this sort and so is using a Variant as a passthrough. }
var
  InterfaceVariant: OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  InterfaceVariant.AlacakliFirmaKod := Param1;
end;

function TTalimatProperties.Get_HataAdet: Smallint;
begin
    Result := DefaultInterface.HataAdet;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TNYSBordro, THata, TBanka, TTalimat]);
end;

end.
