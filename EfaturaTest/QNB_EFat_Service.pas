// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://erpefaturatest.cs.com.tr:8043/efatura/ws/connectorService?wsdl
//  >Import : https://erpefaturatest.cs.com.tr:8043/efatura/ws/connectorService?wsdl=1
//  >Import : https://erpefaturatest.cs.com.tr:8043/efatura/ws/connectorService?wsdl=1>0
//  >Import : https://erpefaturatest.cs.com.tr:8043/efatura/ws/connectorService?xsd=1
// Encoding : UTF-8
// Version  : 1.0
// (26/03/2021 17:45:04 - - $Rev: 52705 $)
// ************************************************************************ //

unit QNB_EFat_Service;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:base64Binary    - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:decimal         - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:byte            - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:short           - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:long            - "http://www.w3.org/2001/XMLSchema"[Gbl]

  gidenBelgeDurumSorgulaResponse2 = class;      { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriAlExt3 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriAlExt  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaResponse = class;       { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  irsaliyeMailGonderResponse2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  irsaliyeMailGonderResponse = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  yereleAktarilacakBelgeleriAlExt2 = class;     { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  yereleAktarilacakBelgeleriAlExt = class;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriIndirPortal2 = class;           { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriIndirPortal = class;            { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaExtResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaExtResponse = class;    { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenIrsaliyeleriArsiveKaldirResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenIrsaliyeleriArsiveKaldirResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderExt2      = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonderExt       = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgelerAlindiResponse2 = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgelerAlindiResponse = class;               { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  serviceReturnType2   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  serviceReturnType    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeDurumSorgulaExtResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumSorgulaExtResponse = class;    { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  csXmlToUblResponse2  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  csXmlToUblResponse   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeEkleriAlResponse2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeEkleriAlResponse = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenStandartRapolariAlResponse2 = class;     { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenStandartRapolariAlResponse = class;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  csXmlOnizlemeResponse2 = class;               { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  csXmlOnizlemeResponse = class;                { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  urunSablonlariniAlResponse2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  urunSablonlariniAlResponse = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  kayitliKullaniciListeleExtendedTimeResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kayitliKullaniciListeleExtendedTimeResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeEkleriAlResponse2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeEkleriAlResponse = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriIndirEttnResponse2 = class;     { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriIndirEttnResponse = class;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonder2         = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonder          = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderResponse2 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonderResponse  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belge                = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgev2              = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgev3              = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgev4              = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgev5              = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgev6              = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  entry                = class;                 { "http://service.connector.uut.cs.com.tr/"[Cplx] }
  yereleAktarilacakBelgeleriAl2 = class;        { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  yereleAktarilacakBelgeleriAl = class;         { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeParametreleri = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  efaturaKullaniciBilgisi2 = class;             { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  efaturaKullaniciBilgisi = class;              { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderExtResponse2 = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonderExtResponse = class;               { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaExt2 = class;           { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaExt = class;            { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  csXmlToUbl2          = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  csXmlToUbl           = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeEkleriAl2  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeEkleriAl   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriAl2    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriAl     = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderResp      = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenTasinanBelgeleriIndir2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenTasinanBelgeleriIndir = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenIrsaliyeleriArsiveKaldir2 = class;       { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenIrsaliyeleriArsiveKaldir = class;        { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgelerAlindi2      = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgelerAlindi       = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriIndirPortalParametreleri = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  mukellefEFaturaKayit = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeTutarBilgileri = class;             { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeTutarBilgileri = class;             { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriListelePortalData = class;      { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriListelePortalDatav2 = class;    { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  cokluGidenBelgeDurumSorgula2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  cokluGidenBelgeDurumSorgula = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaTarihcesiSorgula2 = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaTarihcesiSorgula = class;               { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumParametreleri = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  irsaliyeMailGonder2  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  irsaliyeMailGonder   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaKepIleIadeEdildiIptal2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaKepIleIadeEdildiIptal = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  Exception            = class;                 { "http://service.connector.uut.cs.com.tr/"[Flt][GblElm] }
  gelenStandartRapolariAl2 = class;             { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenStandartRapolariAl = class;              { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriListele2 = class;               { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriListele = class;                { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  eIrsaliyeKullanicisi2 = class;                { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eIrsaliyeKullanicisi = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  csXmlOnizleme2       = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  csXmlOnizleme        = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  urunSablonlariniAl2  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  urunSablonlariniAl   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  eFaturaKayitliKullaniciListele2 = class;      { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eFaturaKayitliKullaniciListele = class;       { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgula2 = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgula = class;               { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaKepIleIadeEdildi2 = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaKepIleIadeEdildi = class;               { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeTutarBilgileriSorgula2 = class;     { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeTutarBilgileriSorgula = class;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeEkleriAl2  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeEkleriAl   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriIndirEttn2 = class;             { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriIndirEttn = class;              { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeParametreleri = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eFaturaKullanici     = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eIrsaliyeKullanici   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaKepIleIadeEdildiIptalResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaKepIleIadeEdildiIptalResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeleriTekrarGonderYerelBelgeNoResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeleriTekrarGonderYerelBelgeNoResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  eIrsaliyeKullanicisiResponse2 = class;        { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eIrsaliyeKullanicisiResponse = class;         { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaKepIleIadeEdildiResponse2 = class;      { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaKepIleIadeEdildiResponse = class;       { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeDurumSorgulaExt2 = class;           { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumSorgulaExt = class;            { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenTasinanBelgeleriIndirResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenTasinanBelgeleriIndirResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  Exception2           = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriListeleData = class;            { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaTarihcesiData  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  irsaliyeTarihcesiData = class;                { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eFaturaKayitliKullaniciHistory = class;       { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eFaturaKullaniciExtended = class;             { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurum      = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumv2    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumv3    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumv4    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumv5    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumv6    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kontorAzaltResp      = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kayitliKullaniciListeleExtendedTime2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kayitliKullaniciListeleExtendedTime = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeDurum      = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumv2    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumv3    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumv4    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumv5    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriIndirPortalResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriIndirPortalResponse = class;    { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriListele2 = class;               { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriListele = class;                { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriListeleParametreleri = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriIndirExtResponse2 = class;      { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriIndirExtResponse = class;       { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriIndirExt2 = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriIndirExt = class;               { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriListelePortal2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriListelePortal = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriListelePortalParametreleri = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenFaturalariArsiveKaldirResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenFaturalariArsiveKaldirResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenFaturalariArsiveKaldir2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenFaturalariArsiveKaldir = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  irsaliyeTarihcesiSorgula2 = class;            { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  irsaliyeTarihcesiSorgula = class;             { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaNoUretResponse2 = class;                { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaNoUretResponse = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaEttn2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaEttn = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaNoUret2        = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaNoUret         = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgelerAlindiEntegrasyonSiparisNoGuncelle2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgelerAlindiEntegrasyonSiparisNoGuncelle = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgelerAlindiEntegrasyonSiparisNoGuncelleResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgelerAlindiEntegrasyonSiparisNoGuncelleResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  temelKontrollerIleBelgeGonder2 = class;       { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  temelKontrollerIleBelgeGonder = class;        { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  temelKontrollerIleBelgeGonderResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  temelKontrollerIleBelgeGonderResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaEttnResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaEttnResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriListeleExt2 = class;            { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriListeleExt = class;             { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaBelgeNo2 = class;       { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaBelgeNo = class;        { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaBelgeNoResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaBelgeNoResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriIndirResponse2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriIndirResponse = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  ublOnizlemeResponse2 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  ublOnizlemeResponse  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriIndir2 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriIndir  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenTamamlananRapolariAlResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenTamamlananRapolariAlResponse = class;    { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeleriTekrarGonderYerelBelgeNo2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeleriTekrarGonderYerelBelgeNo = class;    { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenTamamlananRapolariAl2 = class;           { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenTamamlananRapolariAl = class;            { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeleriTekrarGonderBelgeOid2 = class;       { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeleriTekrarGonderBelgeOid = class;        { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeleriTekrarGonderBelgeOidResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeleriTekrarGonderBelgeOidResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  ublOnizleme2         = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  ublOnizleme          = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeXmlleriniAl2 = class;               { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeXmlleriniAl = class;                { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderExtWithValidateResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonderExtWithValidateResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderExtWithValidate2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonderExtWithValidate = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  eIrsaliyeKayitliKullaniciListele2 = class;    { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eIrsaliyeKayitliKullaniciListele = class;     { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  wsKullaniciBilgileri = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  wsKullanicisiKaydet2 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  wsKullanicisiKaydet  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  wsKullanicisiKaydetResponse2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  wsKullanicisiKaydetResponse = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  kayitliKullaniciListeleExtendedVknTcknResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kayitliKullaniciListeleExtendedVknTcknResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  kayitliKullaniciListeleExtendedVknTckn2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kayitliKullaniciListeleExtendedVknTckn = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  yolcuBeraberFaturaIptalEt2 = class;           { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  yolcuBeraberFaturaIptalEt = class;            { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  yolcuBeraberFaturaIptalEtResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  yolcuBeraberFaturaIptalEtResponse = class;    { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeleriTekrarGonder2 = class;               { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeleriTekrarGonder = class;                { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeleriTekrarGonderResponse2 = class;       { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeleriTekrarGonderResponse = class;        { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriAlExt22 = class;                { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriAlExt2 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  entry2               = class;                 { "http://service.connector.uut.cs.com.tr/"[Cplx] }
  faturaMailGonderResponse2 = class;            { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaMailGonderResponse = class;             { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  kalanKontorBilgisi   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kontorBilgisiGetir2  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kontorBilgisiGetir   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  kontorBilgisiGetirResponse2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kontorBilgisiGetirResponse = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeDurumSorgulaResponse2 = class;      { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumSorgulaResponse = class;       { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaMailGonder2    = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaMailGonder     = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeDurumSorgula2 = class;              { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeDurumSorgula = class;               { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriIndir2 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriIndir  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeleriIndirResponse2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriIndirResponse = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaYerelBelgeNoResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaYerelBelgeNoResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeTutarBilgileriSorgula2 = class;     { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeTutarBilgileriSorgula = class;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenBelgeDurumSorgulaYerelBelgeNo2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeDurumSorgulaYerelBelgeNo = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeXmlleriniAlExt2 = class;            { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeXmlleriniAlExt = class;             { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeXmlleriniAlExtResponse2 = class;    { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeXmlleriniAlExtResponse = class;     { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenFaturalariArsiveKaldir2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenFaturalariArsiveKaldir = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenFaturalariArsiveKaldirResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenFaturalariArsiveKaldirResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenTasinanBelgeleriIndirResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenTasinanBelgeleriIndirResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gidenTasinanBelgeleriIndir2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenTasinanBelgeleriIndir = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  kayitliKullaniciListeleExtendedResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kayitliKullaniciListeleExtendedResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenIrsaliyeleriArsiveKaldir2 = class;       { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenIrsaliyeleriArsiveKaldir = class;        { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenIrsaliyeleriArsiveKaldirResponse2 = class;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenIrsaliyeleriArsiveKaldirResponse = class;   { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  erpBilgileriBelirleResponse2 = class;         { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  erpBilgileriBelirleResponse = class;          { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  erpBilgileriBelirle2 = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  erpBilgileriBelirle  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  erpBilgileri         = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  efaturaKullanicisiResponse2 = class;          { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  efaturaKullanicisiResponse = class;           { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  kayitliKullaniciListeleExtended2 = class;     { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  kayitliKullaniciListeleExtended = class;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  efaturaKullanicisi2  = class;                 { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  efaturaKullanicisi   = class;                 { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderWithValidate2 = class;             { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonderWithValidate = class;              { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  belgeGonderWithValidateResponse2 = class;     { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  belgeGonderWithValidateResponse = class;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }

  {$SCOPEDENUMS ON}
  { "http://service.connector.uut.cs.com.tr/"[GblSmpl] }
  kontorBirimi = (ADET, TL, MB);

  { "http://service.connector.uut.cs.com.tr/"[GblSmpl] }
  kontorTipi = (
      FATURA, 
      DEFTER, 
      KEP, 
      KEPSMS, 
      ARSIV, 
      ARSIVSMS, 
      IRSALIYE, 
      SMM, 
      MMK, 
      PORTAL, 
      OKC, 
      BAYI
  );

  {$SCOPEDENUMS OFF}



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaResponse2 = class(TRemotable)
  private
    Freturn: gidenBelgeDurum;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: gidenBelgeDurum  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;

  gelenBelgeleriListeleResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eFaturaKayitliKullaniciListeleResponse2 = array of eFaturaKullanici;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eFaturaKayitliKullaniciListeleResponse = eFaturaKayitliKullaniciListeleResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  gelenBelgeleriAlExtResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeTutarBilgileriSorgulaResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeTutarBilgileriSorgulaResponse = gelenBelgeTutarBilgileriSorgulaResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gelenBelgeleriAlExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriAlExt3 = class(TRemotable)
  private
    Fparametreler: gelenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gelenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;

  Array_Of_eFaturaKayitliKullaniciHistory = array of eFaturaKayitliKullaniciHistory;   { "http://service.connector.uut.cs.com.tr/"[GblUbnd] }
  gelenBelgeleriListeleResponse = gelenBelgeleriListeleResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gelenBelgeleriAlExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriAlExt = class(gelenBelgeleriAlExt3)
  private
  published
  end;

  gelenBelgeleriAlExtResponse = gelenBelgeleriAlExtResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaResponse = class(gidenBelgeDurumSorgulaResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : irsaliyeMailGonderResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  irsaliyeMailGonderResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : irsaliyeMailGonderResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  irsaliyeMailGonderResponse = class(irsaliyeMailGonderResponse2)
  private
  published
  end;

  cokluGidenBelgeDurumSorgulaResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  cokluGidenBelgeDurumSorgulaResponse = cokluGidenBelgeDurumSorgulaResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : yereleAktarilacakBelgeleriAlExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yereleAktarilacakBelgeleriAlExt2 = class(TRemotable)
  private
    Fparametreler: gelenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gelenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : yereleAktarilacakBelgeleriAlExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yereleAktarilacakBelgeleriAlExt = class(yereleAktarilacakBelgeleriAlExt2)
  private
  published
  end;

  yereleAktarilacakBelgeleriAlExtResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  yereleAktarilacakBelgeleriAlExtResponse = yereleAktarilacakBelgeleriAlExtResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  faturaTarihcesiSorgulaResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  faturaTarihcesiSorgulaResponse = faturaTarihcesiSorgulaResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  efaturaKullaniciListesiResponse2 = array of mukellefEFaturaKayit;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  efaturaKullaniciListesiResponse = efaturaKullaniciListesiResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirPortal, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirPortal2 = class(TRemotable)
  private
    Fparametreler: gidenBelgeleriIndirPortalParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgidenBelgeleriIndirPortalParametreleri: gidenBelgeleriIndirPortalParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gidenBelgeleriIndirPortalParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirPortal, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirPortal = class(gidenBelgeleriIndirPortal2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaExtResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaExtResponse2 = class(TRemotable)
  private
    Freturn: serviceReturnType2;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AserviceReturnType2: serviceReturnType2);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: serviceReturnType2  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaExtResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaExtResponse = class(gidenBelgeDurumSorgulaExtResponse2)
  private
  published
  end;

  gelenBelgeleriAlResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriAlResponse = gelenBelgeleriAlResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gidenIrsaliyeleriArsiveKaldirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenIrsaliyeleriArsiveKaldirResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenIrsaliyeleriArsiveKaldirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenIrsaliyeleriArsiveKaldirResponse = class(gidenIrsaliyeleriArsiveKaldirResponse2)
  private
  published
  end;

  efaturaKullaniciBilgisiResponse2 = array of eFaturaKullanici;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  efaturaKullaniciBilgisiResponse = efaturaKullaniciBilgisiResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : belgeGonderExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExt2 = class(TRemotable)
  private
    Fparametreler: gidenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgidenBelgeParametreleri: gidenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gidenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonderExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExt = class(belgeGonderExt2)
  private
  published
  end;

  yereleAktarilacakBelgeleriAlResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  yereleAktarilacakBelgeleriAlResponse = yereleAktarilacakBelgeleriAlResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : belgelerAlindiResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindiResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgelerAlindiResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindiResponse = class(belgelerAlindiResponse2)
  private
  published
  end;

  ekBilgiler = array of entry;                  { "http://service.connector.uut.cs.com.tr/"[Cplx] }


  // ************************************************************************ //
  // XML       : serviceReturnType, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  serviceReturnType2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : serviceReturnType, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  serviceReturnType = class(serviceReturnType2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgulaExtResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgulaExtResponse2 = class(TRemotable)
  private
    Freturn: serviceReturnType2;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AserviceReturnType2: serviceReturnType2);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: serviceReturnType2  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgulaExtResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgulaExtResponse = class(gelenBelgeDurumSorgulaExtResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : csXmlToUblResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlToUblResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : csXmlToUblResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlToUblResponse = class(csXmlToUblResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeEkleriAlResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeEkleriAlResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeEkleriAlResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeEkleriAlResponse = class(gelenBelgeEkleriAlResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenStandartRapolariAlResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenStandartRapolariAlResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenStandartRapolariAlResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenStandartRapolariAlResponse = class(gelenStandartRapolariAlResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : csXmlOnizlemeResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlOnizlemeResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : csXmlOnizlemeResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlOnizlemeResponse = class(csXmlOnizlemeResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : urunSablonlariniAlResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  urunSablonlariniAlResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : urunSablonlariniAlResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  urunSablonlariniAlResponse = class(urunSablonlariniAlResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedTimeResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedTimeResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedTimeResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedTimeResponse = class(kayitliKullaniciListeleExtendedTimeResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeEkleriAlResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeEkleriAlResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeEkleriAlResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeEkleriAlResponse = class(gidenBelgeEkleriAlResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirEttnResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirEttnResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirEttnResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirEttnResponse = class(gidenBelgeleriIndirEttnResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeGonder, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonder2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    Fveri: TByteDynArray;
    Fveri_Specified: boolean;
    FbelgeHash: string;
    FbelgeHash_Specified: boolean;
    FmimeType: string;
    FmimeType_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  veri_Specified(Index: Integer): boolean;
    procedure SetbelgeHash(Index: Integer; const Astring: string);
    function  belgeHash_Specified(Index: Integer): boolean;
    procedure SetmimeType(Index: Integer; const Astring: string);
    function  mimeType_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string         Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeTuru:       string         Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeNo:         string         Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property veri:            TByteDynArray  Index (IS_OPTN) read Fveri write Setveri stored veri_Specified;
    property belgeHash:       string         Index (IS_OPTN) read FbelgeHash write SetbelgeHash stored belgeHash_Specified;
    property mimeType:        string         Index (IS_OPTN) read FmimeType write SetmimeType stored mimeType_Specified;
    property belgeVersiyon:   string         Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonder, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonder = class(belgeGonder2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeGonderResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderResponse2 = class(TRemotable)
  private
    FbelgeOid: string;
    FbelgeOid_Specified: boolean;
    procedure SetbelgeOid(Index: Integer; const Astring: string);
    function  belgeOid_Specified(Index: Integer): boolean;
  published
    property belgeOid: string  Index (IS_OPTN) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonderResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderResponse = class(belgeGonderResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belge, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belge = class(serviceReturnType2)
  private
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    FbelgeSiraNo: string;
    FbelgeSiraNo_Specified: boolean;
    FbelgeTarihi: string;
    FbelgeTarihi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeVerisi: string;
    FbelgeVerisi_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    FgonderenEtiket: string;
    FgonderenEtiket_Specified: boolean;
    FgonderenVknTckn: string;
    FgonderenVknTckn_Specified: boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure SetbelgeSiraNo(Index: Integer; const Astring: string);
    function  belgeSiraNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTarihi(Index: Integer; const Astring: string);
    function  belgeTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeVerisi(Index: Integer; const Astring: string);
    function  belgeVerisi_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetgonderenEtiket(Index: Integer; const Astring: string);
    function  gonderenEtiket_Specified(Index: Integer): boolean;
    procedure SetgonderenVknTckn(Index: Integer; const Astring: string);
    function  gonderenVknTckn_Specified(Index: Integer): boolean;
  published
    property belgeNo:         string  Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property belgeSiraNo:     string  Index (IS_OPTN) read FbelgeSiraNo write SetbelgeSiraNo stored belgeSiraNo_Specified;
    property belgeTarihi:     string  Index (IS_OPTN) read FbelgeTarihi write SetbelgeTarihi stored belgeTarihi_Specified;
    property belgeTuru:       string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeVerisi:     string  Index (IS_OPTN) read FbelgeVerisi write SetbelgeVerisi stored belgeVerisi_Specified;
    property ettn:            string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property gonderenEtiket:  string  Index (IS_OPTN) read FgonderenEtiket write SetgonderenEtiket stored gonderenEtiket_Specified;
    property gonderenVknTckn: string  Index (IS_OPTN) read FgonderenVknTckn write SetgonderenVknTckn stored gonderenVknTckn_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgev2, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgev2 = class(belge)
  private
    FalanEtiket: string;
    FalanEtiket_Specified: boolean;
    FaliciUnvan: string;
    FaliciUnvan_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    FbelgeXmlZipped: TByteDynArray;
    FbelgeXmlZipped_Specified: boolean;
    FekBilgiler: ekBilgiler;
    FsaticiUnvan: string;
    FsaticiUnvan_Specified: boolean;
    FsubeKodu: string;
    FsubeKodu_Specified: boolean;
    FzarfId: string;
    FzarfId_Specified: boolean;
    FzarfVerisi: TByteDynArray;
    FzarfVerisi_Specified: boolean;
    FzarfXml: string;
    FzarfXml_Specified: boolean;
    procedure SetalanEtiket(Index: Integer; const Astring: string);
    function  alanEtiket_Specified(Index: Integer): boolean;
    procedure SetaliciUnvan(Index: Integer; const Astring: string);
    function  aliciUnvan_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
    procedure SetbelgeXmlZipped(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  belgeXmlZipped_Specified(Index: Integer): boolean;
    procedure SetsaticiUnvan(Index: Integer; const Astring: string);
    function  saticiUnvan_Specified(Index: Integer): boolean;
    procedure SetsubeKodu(Index: Integer; const Astring: string);
    function  subeKodu_Specified(Index: Integer): boolean;
    procedure SetzarfId(Index: Integer; const Astring: string);
    function  zarfId_Specified(Index: Integer): boolean;
    procedure SetzarfVerisi(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  zarfVerisi_Specified(Index: Integer): boolean;
    procedure SetzarfXml(Index: Integer; const Astring: string);
    function  zarfXml_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property alanEtiket:     string         Index (IS_OPTN) read FalanEtiket write SetalanEtiket stored alanEtiket_Specified;
    property aliciUnvan:     string         Index (IS_OPTN) read FaliciUnvan write SetaliciUnvan stored aliciUnvan_Specified;
    property belgeVersiyon:  string         Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
    property belgeXmlZipped: TByteDynArray  Index (IS_OPTN) read FbelgeXmlZipped write SetbelgeXmlZipped stored belgeXmlZipped_Specified;
    property ekBilgiler:     ekBilgiler     read FekBilgiler write FekBilgiler;
    property saticiUnvan:    string         Index (IS_OPTN) read FsaticiUnvan write SetsaticiUnvan stored saticiUnvan_Specified;
    property subeKodu:       string         Index (IS_OPTN) read FsubeKodu write SetsubeKodu stored subeKodu_Specified;
    property zarfId:         string         Index (IS_OPTN) read FzarfId write SetzarfId stored zarfId_Specified;
    property zarfVerisi:     TByteDynArray  Index (IS_OPTN) read FzarfVerisi write SetzarfVerisi stored zarfVerisi_Specified;
    property zarfXml:        string         Index (IS_OPTN) read FzarfXml write SetzarfXml stored zarfXml_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgev3, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgev3 = class(belgev2)
  private
    FodenecekTutar: string;
    FodenecekTutar_Specified: boolean;
    FodenecekTutarDovizCinsi: string;
    FodenecekTutarDovizCinsi_Specified: boolean;
    procedure SetodenecekTutar(Index: Integer; const Astring: string);
    function  odenecekTutar_Specified(Index: Integer): boolean;
    procedure SetodenecekTutarDovizCinsi(Index: Integer; const Astring: string);
    function  odenecekTutarDovizCinsi_Specified(Index: Integer): boolean;
  published
    property odenecekTutar:           string  Index (IS_OPTN) read FodenecekTutar write SetodenecekTutar stored odenecekTutar_Specified;
    property odenecekTutarDovizCinsi: string  Index (IS_OPTN) read FodenecekTutarDovizCinsi write SetodenecekTutarDovizCinsi stored odenecekTutarDovizCinsi_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgev4, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgev4 = class(belgev3)
  private
    Farsivlenmis: string;
    Farsivlenmis_Specified: boolean;
    FbelgeHash: string;
    FbelgeHash_Specified: boolean;
    procedure Setarsivlenmis(Index: Integer; const Astring: string);
    function  arsivlenmis_Specified(Index: Integer): boolean;
    procedure SetbelgeHash(Index: Integer; const Astring: string);
    function  belgeHash_Specified(Index: Integer): boolean;
  published
    property arsivlenmis: string  Index (IS_OPTN) read Farsivlenmis write Setarsivlenmis stored arsivlenmis_Specified;
    property belgeHash:   string  Index (IS_OPTN) read FbelgeHash write SetbelgeHash stored belgeHash_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgev5, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgev5 = class(belgev4)
  private
    FfaturaGelisTarihi: string;
    FfaturaGelisTarihi_Specified: boolean;
    procedure SetfaturaGelisTarihi(Index: Integer; const Astring: string);
    function  faturaGelisTarihi_Specified(Index: Integer): boolean;
  published
    property faturaGelisTarihi: string  Index (IS_OPTN) read FfaturaGelisTarihi write SetfaturaGelisTarihi stored faturaGelisTarihi_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgev6, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgev6 = class(belgev5)
  private
    FprofileId: string;
    FprofileId_Specified: boolean;
    procedure SetprofileId(Index: Integer; const Astring: string);
    function  profileId_Specified(Index: Integer): boolean;
  published
    property profileId: string  Index (IS_OPTN) read FprofileId write SetprofileId stored profileId_Specified;
  end;



  // ************************************************************************ //
  // XML       : entry, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  entry = class(TRemotable)
  private
    Fkey: string;
    Fkey_Specified: boolean;
    Fvalue: string;
    Fvalue_Specified: boolean;
    procedure Setkey(Index: Integer; const Astring: string);
    function  key_Specified(Index: Integer): boolean;
    procedure Setvalue(Index: Integer; const Astring: string);
    function  value_Specified(Index: Integer): boolean;
  published
    property key:   string  Index (IS_OPTN) read Fkey write Setkey stored key_Specified;
    property value: string  Index (IS_OPTN) read Fvalue write Setvalue stored value_Specified;
  end;



  // ************************************************************************ //
  // XML       : yereleAktarilacakBelgeleriAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yereleAktarilacakBelgeleriAl2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FentegrasyonHedefi: string;
    FentegrasyonHedefi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetentegrasyonHedefi(Index: Integer; const Astring: string);
    function  entegrasyonHedefi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:   string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property entegrasyonHedefi: string  Index (IS_OPTN) read FentegrasyonHedefi write SetentegrasyonHedefi stored entegrasyonHedefi_Specified;
    property belgeTuru:         string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : yereleAktarilacakBelgeleriAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yereleAktarilacakBelgeleriAl = class(yereleAktarilacakBelgeleriAl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeParametreleri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeParametreleri = class(TRemotable)
  private
    FalanEtiket: string;
    FalanEtiket_Specified: boolean;
    FbelgeHash: string;
    FbelgeHash_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    FdonusTipiVersiyon: string;
    FdonusTipiVersiyon_Specified: boolean;
    FerpKodu: string;
    FerpKodu_Specified: boolean;
    FgonderenEtiket: string;
    FgonderenEtiket_Specified: boolean;
    FmimeType: string;
    FmimeType_Specified: boolean;
    FsubeKodu: string;
    FsubeKodu_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fveri: TByteDynArray;
    Fveri_Specified: boolean;
    FxsltAdi: string;
    FxsltAdi_Specified: boolean;
    FxsltVeri: TByteDynArray;
    FxsltVeri_Specified: boolean;
    procedure SetalanEtiket(Index: Integer; const Astring: string);
    function  alanEtiket_Specified(Index: Integer): boolean;
    procedure SetbelgeHash(Index: Integer; const Astring: string);
    function  belgeHash_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
    procedure SetdonusTipiVersiyon(Index: Integer; const Astring: string);
    function  donusTipiVersiyon_Specified(Index: Integer): boolean;
    procedure SeterpKodu(Index: Integer; const Astring: string);
    function  erpKodu_Specified(Index: Integer): boolean;
    procedure SetgonderenEtiket(Index: Integer; const Astring: string);
    function  gonderenEtiket_Specified(Index: Integer): boolean;
    procedure SetmimeType(Index: Integer; const Astring: string);
    function  mimeType_Specified(Index: Integer): boolean;
    procedure SetsubeKodu(Index: Integer; const Astring: string);
    function  subeKodu_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  veri_Specified(Index: Integer): boolean;
    procedure SetxsltAdi(Index: Integer; const Astring: string);
    function  xsltAdi_Specified(Index: Integer): boolean;
    procedure SetxsltVeri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  xsltVeri_Specified(Index: Integer): boolean;
  published
    property alanEtiket:        string         Index (IS_OPTN) read FalanEtiket write SetalanEtiket stored alanEtiket_Specified;
    property belgeHash:         string         Index (IS_OPTN) read FbelgeHash write SetbelgeHash stored belgeHash_Specified;
    property belgeNo:           string         Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property belgeTuru:         string         Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeVersiyon:     string         Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
    property donusTipiVersiyon: string         Index (IS_OPTN) read FdonusTipiVersiyon write SetdonusTipiVersiyon stored donusTipiVersiyon_Specified;
    property erpKodu:           string         Index (IS_OPTN) read FerpKodu write SeterpKodu stored erpKodu_Specified;
    property gonderenEtiket:    string         Index (IS_OPTN) read FgonderenEtiket write SetgonderenEtiket stored gonderenEtiket_Specified;
    property mimeType:          string         Index (IS_OPTN) read FmimeType write SetmimeType stored mimeType_Specified;
    property subeKodu:          string         Index (IS_OPTN) read FsubeKodu write SetsubeKodu stored subeKodu_Specified;
    property vergiTcKimlikNo:   string         Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property veri:              TByteDynArray  Index (IS_OPTN) read Fveri write Setveri stored veri_Specified;
    property xsltAdi:           string         Index (IS_OPTN) read FxsltAdi write SetxsltAdi stored xsltAdi_Specified;
    property xsltVeri:          TByteDynArray  Index (IS_OPTN) read FxsltVeri write SetxsltVeri stored xsltVeri_Specified;
  end;



  // ************************************************************************ //
  // XML       : efaturaKullaniciBilgisi, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  efaturaKullaniciBilgisi2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : efaturaKullaniciBilgisi, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  efaturaKullaniciBilgisi = class(efaturaKullaniciBilgisi2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeGonderExtResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExtResponse2 = class(TRemotable)
  private
    FbelgeOid: string;
    FbelgeOid_Specified: boolean;
    procedure SetbelgeOid(Index: Integer; const Astring: string);
    function  belgeOid_Specified(Index: Integer): boolean;
  published
    property belgeOid: string  Index (IS_OPTN) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonderExtResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExtResponse = class(belgeGonderExtResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaExt2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fparametreler: gidenBelgeDurumParametreleri;
    Fparametreler_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setparametreler(Index: Integer; const AgidenBelgeDurumParametreleri: gidenBelgeDurumParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property vergiTcKimlikNo: string                        Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property parametreler:    gidenBelgeDurumParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaExt = class(gidenBelgeDurumSorgulaExt2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : csXmlToUbl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlToUbl2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    Fveri: TByteDynArray;
    Fveri_Specified: boolean;
    FxsltAdi: string;
    FxsltAdi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
    procedure Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  veri_Specified(Index: Integer): boolean;
    procedure SetxsltAdi(Index: Integer; const Astring: string);
    function  xsltAdi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string         Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeVersiyon:   string         Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
    property veri:            TByteDynArray  Index (IS_OPTN) read Fveri write Setveri stored veri_Specified;
    property xsltAdi:         string         Index (IS_OPTN) read FxsltAdi write SetxsltAdi stored xsltAdi_Specified;
    property belgeTuru:       string         Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : csXmlToUbl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlToUbl = class(csXmlToUbl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeEkleriAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeEkleriAl2 = class(TRemotable)
  private
    Fuuid: string;
    Fuuid_Specified: boolean;
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure Setuuid(Index: Integer; const Astring: string);
    function  uuid_Specified(Index: Integer): boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property uuid:      string  Index (IS_OPTN) read Fuuid write Setuuid stored uuid_Specified;
    property vknTckn:   string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
    property belgeTuru: string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeEkleriAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeEkleriAl = class(gelenBelgeEkleriAl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriAl2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FsonAlinanBelgeSiraNumarasi: string;
    FsonAlinanBelgeSiraNumarasi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetsonAlinanBelgeSiraNumarasi(Index: Integer; const Astring: string);
    function  sonAlinanBelgeSiraNumarasi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:            string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property sonAlinanBelgeSiraNumarasi: string  Index (IS_OPTN) read FsonAlinanBelgeSiraNumarasi write SetsonAlinanBelgeSiraNumarasi stored sonAlinanBelgeSiraNumarasi_Specified;
    property belgeTuru:                  string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriAl = class(gelenBelgeleriAl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeGonderResp, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderResp = class(serviceReturnType2)
  private
    FbelgeOid: string;
    FbelgeOid_Specified: boolean;
    FerrorMessage: string;
    FerrorMessage_Specified: boolean;
    FresponseStatus: string;
    FresponseStatus_Specified: boolean;
    procedure SetbelgeOid(Index: Integer; const Astring: string);
    function  belgeOid_Specified(Index: Integer): boolean;
    procedure SeterrorMessage(Index: Integer; const Astring: string);
    function  errorMessage_Specified(Index: Integer): boolean;
    procedure SetresponseStatus(Index: Integer; const Astring: string);
    function  responseStatus_Specified(Index: Integer): boolean;
  published
    property belgeOid:       string  Index (IS_OPTN) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
    property errorMessage:   string  Index (IS_OPTN) read FerrorMessage write SeterrorMessage stored errorMessage_Specified;
    property responseStatus: string  Index (IS_OPTN) read FresponseStatus write SetresponseStatus stored responseStatus_Specified;
  end;

  efaturaKullaniciListesi2 = array of string;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }


  // ************************************************************************ //
  // XML       : gelenTasinanBelgeleriIndir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTasinanBelgeleriIndir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettnler: efaturaKullaniciListesi2;
    Fettnler_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettnler_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettnler:         efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettnler write Setettnler stored ettnler_Specified;
    property belgeFormati:    string                    Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenTasinanBelgeleriIndir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTasinanBelgeleriIndir = class(gelenTasinanBelgeleriIndir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenIrsaliyeleriArsiveKaldir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenIrsaliyeleriArsiveKaldir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FdespatchEttnListesi: efaturaKullaniciListesi2;
    FdespatchEttnListesi_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetdespatchEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  despatchEttnListesi_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:     string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property despatchEttnListesi: efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FdespatchEttnListesi write SetdespatchEttnListesi stored despatchEttnListesi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenIrsaliyeleriArsiveKaldir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenIrsaliyeleriArsiveKaldir = class(gidenIrsaliyeleriArsiveKaldir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgelerAlindi, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindi2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettn: efaturaKullaniciListesi2;
    Fettn_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettn:            efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettn write Setettn stored ettn_Specified;
    property belgeTuru:       string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgelerAlindi, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindi = class(belgelerAlindi2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirPortalParametreleri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirPortalParametreleri = class(TRemotable)
  private
    FbaslangicGonderimTarihi: string;
    FbaslangicGonderimTarihi_Specified: boolean;
    FbelgeEttnListesi: efaturaKullaniciListesi2;
    FbelgeEttnListesi_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbitisGonderimTarihi: string;
    FbitisGonderimTarihi_Specified: boolean;
    FfaturaBaslangicTarihi: string;
    FfaturaBaslangicTarihi_Specified: boolean;
    FfaturaBitisTarihi: string;
    FfaturaBitisTarihi_Specified: boolean;
    Fkaynak: string;
    Fkaynak_Specified: boolean;
    FpageCount: string;
    FpageCount_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
    function  baslangicGonderimTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  belgeEttnListesi_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbitisGonderimTarihi(Index: Integer; const Astring: string);
    function  bitisGonderimTarihi_Specified(Index: Integer): boolean;
    procedure SetfaturaBaslangicTarihi(Index: Integer; const Astring: string);
    function  faturaBaslangicTarihi_Specified(Index: Integer): boolean;
    procedure SetfaturaBitisTarihi(Index: Integer; const Astring: string);
    function  faturaBitisTarihi_Specified(Index: Integer): boolean;
    procedure Setkaynak(Index: Integer; const Astring: string);
    function  kaynak_Specified(Index: Integer): boolean;
    procedure SetpageCount(Index: Integer; const Astring: string);
    function  pageCount_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property baslangicGonderimTarihi: string                    Index (IS_OPTN) read FbaslangicGonderimTarihi write SetbaslangicGonderimTarihi stored baslangicGonderimTarihi_Specified;
    property belgeEttnListesi:        efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FbelgeEttnListesi write SetbelgeEttnListesi stored belgeEttnListesi_Specified;
    property belgeFormati:            string                    Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
    property belgeTuru:               string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property bitisGonderimTarihi:     string                    Index (IS_OPTN) read FbitisGonderimTarihi write SetbitisGonderimTarihi stored bitisGonderimTarihi_Specified;
    property faturaBaslangicTarihi:   string                    Index (IS_OPTN) read FfaturaBaslangicTarihi write SetfaturaBaslangicTarihi stored faturaBaslangicTarihi_Specified;
    property faturaBitisTarihi:       string                    Index (IS_OPTN) read FfaturaBitisTarihi write SetfaturaBitisTarihi stored faturaBitisTarihi_Specified;
    property kaynak:                  string                    Index (IS_OPTN) read Fkaynak write Setkaynak stored kaynak_Specified;
    property pageCount:               string                    Index (IS_OPTN) read FpageCount write SetpageCount stored pageCount_Specified;
    property vergiTcKimlikNo:         string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;

  efaturaKullaniciListesi = efaturaKullaniciListesi2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : mukellefEFaturaKayit, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  mukellefEFaturaKayit = class(TRemotable)
  private
    FefaturaKullaniciListesi: efaturaKullaniciBilgisiResponse2;
    FefaturaKullaniciListesi_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure SetefaturaKullaniciListesi(Index: Integer; const AefaturaKullaniciBilgisiResponse2: efaturaKullaniciBilgisiResponse2);
    function  efaturaKullaniciListesi_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property efaturaKullaniciListesi: efaturaKullaniciBilgisiResponse2  Index (IS_OPTN or IS_UNBD) read FefaturaKullaniciListesi write SetefaturaKullaniciListesi stored efaturaKullaniciListesi_Specified;
    property vergiTcKimlikNo:         string                            Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeTutarBilgileri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeTutarBilgileri = class(serviceReturnType2)
  private
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    FbelgeTarihi: string;
    FbelgeTarihi_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    Fkdv18Oran: string;
    Fkdv18Oran_Specified: boolean;
    Fkdv18Tutar: string;
    Fkdv18Tutar_Specified: boolean;
    Fkdv1Oran: string;
    Fkdv1Oran_Specified: boolean;
    Fkdv1Tutar: string;
    Fkdv1Tutar_Specified: boolean;
    Fkdv8Oran: string;
    Fkdv8Oran_Specified: boolean;
    Fkdv8Tutar: string;
    Fkdv8Tutar_Specified: boolean;
    FkdvTevkifatOran: string;
    FkdvTevkifatOran_Specified: boolean;
    FkdvTevkifatTutari: string;
    FkdvTevkifatTutari_Specified: boolean;
    FkdvToplamTutari: string;
    FkdvToplamTutari_Specified: boolean;
    FkdvToplamTutariDovizCinsi: string;
    FkdvToplamTutariDovizCinsi_Specified: boolean;
    FmalHizmetToplamTutari: string;
    FmalHizmetToplamTutari_Specified: boolean;
    FmalHizmetToplamTutariDovizCinsi: string;
    FmalHizmetToplamTutariDovizCinsi_Specified: boolean;
    FodenecekTutar: string;
    FodenecekTutar_Specified: boolean;
    FodenecekTutarDovizCinsi: string;
    FodenecekTutarDovizCinsi_Specified: boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTarihi(Index: Integer; const Astring: string);
    function  belgeTarihi_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure Setkdv18Oran(Index: Integer; const Astring: string);
    function  kdv18Oran_Specified(Index: Integer): boolean;
    procedure Setkdv18Tutar(Index: Integer; const Astring: string);
    function  kdv18Tutar_Specified(Index: Integer): boolean;
    procedure Setkdv1Oran(Index: Integer; const Astring: string);
    function  kdv1Oran_Specified(Index: Integer): boolean;
    procedure Setkdv1Tutar(Index: Integer; const Astring: string);
    function  kdv1Tutar_Specified(Index: Integer): boolean;
    procedure Setkdv8Oran(Index: Integer; const Astring: string);
    function  kdv8Oran_Specified(Index: Integer): boolean;
    procedure Setkdv8Tutar(Index: Integer; const Astring: string);
    function  kdv8Tutar_Specified(Index: Integer): boolean;
    procedure SetkdvTevkifatOran(Index: Integer; const Astring: string);
    function  kdvTevkifatOran_Specified(Index: Integer): boolean;
    procedure SetkdvTevkifatTutari(Index: Integer; const Astring: string);
    function  kdvTevkifatTutari_Specified(Index: Integer): boolean;
    procedure SetkdvToplamTutari(Index: Integer; const Astring: string);
    function  kdvToplamTutari_Specified(Index: Integer): boolean;
    procedure SetkdvToplamTutariDovizCinsi(Index: Integer; const Astring: string);
    function  kdvToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
    procedure SetmalHizmetToplamTutari(Index: Integer; const Astring: string);
    function  malHizmetToplamTutari_Specified(Index: Integer): boolean;
    procedure SetmalHizmetToplamTutariDovizCinsi(Index: Integer; const Astring: string);
    function  malHizmetToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
    procedure SetodenecekTutar(Index: Integer; const Astring: string);
    function  odenecekTutar_Specified(Index: Integer): boolean;
    procedure SetodenecekTutarDovizCinsi(Index: Integer; const Astring: string);
    function  odenecekTutarDovizCinsi_Specified(Index: Integer): boolean;
  published
    property belgeNo:                         string  Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property belgeTarihi:                     string  Index (IS_OPTN) read FbelgeTarihi write SetbelgeTarihi stored belgeTarihi_Specified;
    property ettn:                            string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property kdv18Oran:                       string  Index (IS_OPTN) read Fkdv18Oran write Setkdv18Oran stored kdv18Oran_Specified;
    property kdv18Tutar:                      string  Index (IS_OPTN) read Fkdv18Tutar write Setkdv18Tutar stored kdv18Tutar_Specified;
    property kdv1Oran:                        string  Index (IS_OPTN) read Fkdv1Oran write Setkdv1Oran stored kdv1Oran_Specified;
    property kdv1Tutar:                       string  Index (IS_OPTN) read Fkdv1Tutar write Setkdv1Tutar stored kdv1Tutar_Specified;
    property kdv8Oran:                        string  Index (IS_OPTN) read Fkdv8Oran write Setkdv8Oran stored kdv8Oran_Specified;
    property kdv8Tutar:                       string  Index (IS_OPTN) read Fkdv8Tutar write Setkdv8Tutar stored kdv8Tutar_Specified;
    property kdvTevkifatOran:                 string  Index (IS_OPTN) read FkdvTevkifatOran write SetkdvTevkifatOran stored kdvTevkifatOran_Specified;
    property kdvTevkifatTutari:               string  Index (IS_OPTN) read FkdvTevkifatTutari write SetkdvTevkifatTutari stored kdvTevkifatTutari_Specified;
    property kdvToplamTutari:                 string  Index (IS_OPTN) read FkdvToplamTutari write SetkdvToplamTutari stored kdvToplamTutari_Specified;
    property kdvToplamTutariDovizCinsi:       string  Index (IS_OPTN) read FkdvToplamTutariDovizCinsi write SetkdvToplamTutariDovizCinsi stored kdvToplamTutariDovizCinsi_Specified;
    property malHizmetToplamTutari:           string  Index (IS_OPTN) read FmalHizmetToplamTutari write SetmalHizmetToplamTutari stored malHizmetToplamTutari_Specified;
    property malHizmetToplamTutariDovizCinsi: string  Index (IS_OPTN) read FmalHizmetToplamTutariDovizCinsi write SetmalHizmetToplamTutariDovizCinsi stored malHizmetToplamTutariDovizCinsi_Specified;
    property odenecekTutar:                   string  Index (IS_OPTN) read FodenecekTutar write SetodenecekTutar stored odenecekTutar_Specified;
    property odenecekTutarDovizCinsi:         string  Index (IS_OPTN) read FodenecekTutarDovizCinsi write SetodenecekTutarDovizCinsi stored odenecekTutarDovizCinsi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeTutarBilgileri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeTutarBilgileri = class(serviceReturnType2)
  private
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    FbelgeTarihi: string;
    FbelgeTarihi_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    FgondericiVkn: string;
    FgondericiVkn_Specified: boolean;
    Fkdv18Oran: string;
    Fkdv18Oran_Specified: boolean;
    Fkdv18Tutar: string;
    Fkdv18Tutar_Specified: boolean;
    Fkdv1Oran: string;
    Fkdv1Oran_Specified: boolean;
    Fkdv1Tutar: string;
    Fkdv1Tutar_Specified: boolean;
    Fkdv8Oran: string;
    Fkdv8Oran_Specified: boolean;
    Fkdv8Tutar: string;
    Fkdv8Tutar_Specified: boolean;
    FkdvTevkifatOran: string;
    FkdvTevkifatOran_Specified: boolean;
    FkdvTevkifatTutari: string;
    FkdvTevkifatTutari_Specified: boolean;
    FkdvToplamTutari: string;
    FkdvToplamTutari_Specified: boolean;
    FkdvToplamTutariDovizCinsi: string;
    FkdvToplamTutariDovizCinsi_Specified: boolean;
    FmalHizmetToplamTutari: string;
    FmalHizmetToplamTutari_Specified: boolean;
    FmalHizmetToplamTutariDovizCinsi: string;
    FmalHizmetToplamTutariDovizCinsi_Specified: boolean;
    FodenecekTutar: string;
    FodenecekTutar_Specified: boolean;
    FodenecekTutarDovizCinsi: string;
    FodenecekTutarDovizCinsi_Specified: boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTarihi(Index: Integer; const Astring: string);
    function  belgeTarihi_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetgondericiVkn(Index: Integer; const Astring: string);
    function  gondericiVkn_Specified(Index: Integer): boolean;
    procedure Setkdv18Oran(Index: Integer; const Astring: string);
    function  kdv18Oran_Specified(Index: Integer): boolean;
    procedure Setkdv18Tutar(Index: Integer; const Astring: string);
    function  kdv18Tutar_Specified(Index: Integer): boolean;
    procedure Setkdv1Oran(Index: Integer; const Astring: string);
    function  kdv1Oran_Specified(Index: Integer): boolean;
    procedure Setkdv1Tutar(Index: Integer; const Astring: string);
    function  kdv1Tutar_Specified(Index: Integer): boolean;
    procedure Setkdv8Oran(Index: Integer; const Astring: string);
    function  kdv8Oran_Specified(Index: Integer): boolean;
    procedure Setkdv8Tutar(Index: Integer; const Astring: string);
    function  kdv8Tutar_Specified(Index: Integer): boolean;
    procedure SetkdvTevkifatOran(Index: Integer; const Astring: string);
    function  kdvTevkifatOran_Specified(Index: Integer): boolean;
    procedure SetkdvTevkifatTutari(Index: Integer; const Astring: string);
    function  kdvTevkifatTutari_Specified(Index: Integer): boolean;
    procedure SetkdvToplamTutari(Index: Integer; const Astring: string);
    function  kdvToplamTutari_Specified(Index: Integer): boolean;
    procedure SetkdvToplamTutariDovizCinsi(Index: Integer; const Astring: string);
    function  kdvToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
    procedure SetmalHizmetToplamTutari(Index: Integer; const Astring: string);
    function  malHizmetToplamTutari_Specified(Index: Integer): boolean;
    procedure SetmalHizmetToplamTutariDovizCinsi(Index: Integer; const Astring: string);
    function  malHizmetToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
    procedure SetodenecekTutar(Index: Integer; const Astring: string);
    function  odenecekTutar_Specified(Index: Integer): boolean;
    procedure SetodenecekTutarDovizCinsi(Index: Integer; const Astring: string);
    function  odenecekTutarDovizCinsi_Specified(Index: Integer): boolean;
  published
    property belgeNo:                         string  Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property belgeTarihi:                     string  Index (IS_OPTN) read FbelgeTarihi write SetbelgeTarihi stored belgeTarihi_Specified;
    property ettn:                            string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property gondericiVkn:                    string  Index (IS_OPTN) read FgondericiVkn write SetgondericiVkn stored gondericiVkn_Specified;
    property kdv18Oran:                       string  Index (IS_OPTN) read Fkdv18Oran write Setkdv18Oran stored kdv18Oran_Specified;
    property kdv18Tutar:                      string  Index (IS_OPTN) read Fkdv18Tutar write Setkdv18Tutar stored kdv18Tutar_Specified;
    property kdv1Oran:                        string  Index (IS_OPTN) read Fkdv1Oran write Setkdv1Oran stored kdv1Oran_Specified;
    property kdv1Tutar:                       string  Index (IS_OPTN) read Fkdv1Tutar write Setkdv1Tutar stored kdv1Tutar_Specified;
    property kdv8Oran:                        string  Index (IS_OPTN) read Fkdv8Oran write Setkdv8Oran stored kdv8Oran_Specified;
    property kdv8Tutar:                       string  Index (IS_OPTN) read Fkdv8Tutar write Setkdv8Tutar stored kdv8Tutar_Specified;
    property kdvTevkifatOran:                 string  Index (IS_OPTN) read FkdvTevkifatOran write SetkdvTevkifatOran stored kdvTevkifatOran_Specified;
    property kdvTevkifatTutari:               string  Index (IS_OPTN) read FkdvTevkifatTutari write SetkdvTevkifatTutari stored kdvTevkifatTutari_Specified;
    property kdvToplamTutari:                 string  Index (IS_OPTN) read FkdvToplamTutari write SetkdvToplamTutari stored kdvToplamTutari_Specified;
    property kdvToplamTutariDovizCinsi:       string  Index (IS_OPTN) read FkdvToplamTutariDovizCinsi write SetkdvToplamTutariDovizCinsi stored kdvToplamTutariDovizCinsi_Specified;
    property malHizmetToplamTutari:           string  Index (IS_OPTN) read FmalHizmetToplamTutari write SetmalHizmetToplamTutari stored malHizmetToplamTutari_Specified;
    property malHizmetToplamTutariDovizCinsi: string  Index (IS_OPTN) read FmalHizmetToplamTutariDovizCinsi write SetmalHizmetToplamTutariDovizCinsi stored malHizmetToplamTutariDovizCinsi_Specified;
    property odenecekTutar:                   string  Index (IS_OPTN) read FodenecekTutar write SetodenecekTutar stored odenecekTutar_Specified;
    property odenecekTutarDovizCinsi:         string  Index (IS_OPTN) read FodenecekTutarDovizCinsi write SetodenecekTutarDovizCinsi stored odenecekTutarDovizCinsi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListelePortalData, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListelePortalData = class(serviceReturnType2)
  private
    FalanEtiket: string;
    FalanEtiket_Specified: boolean;
    FalanSubeKodu: string;
    FalanSubeKodu_Specified: boolean;
    FalanVergiTcKimlikNo: string;
    FalanVergiTcKimlikNo_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    FbelgeTarihi: string;
    FbelgeTarihi_Specified: boolean;
    FbelgeTipi: string;
    FbelgeTipi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FerpKodu: string;
    FerpKodu_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    FgonderenEtiket: string;
    FgonderenEtiket_Specified: boolean;
    FgonderenSubeKodu: string;
    FgonderenSubeKodu_Specified: boolean;
    FgonderimZamani: string;
    FgonderimZamani_Specified: boolean;
    FislemYapanVkn: string;
    FislemYapanVkn_Specified: boolean;
    Fkaynak: string;
    Fkaynak_Specified: boolean;
    FkullaniciKodu: string;
    FkullaniciKodu_Specified: boolean;
    procedure SetalanEtiket(Index: Integer; const Astring: string);
    function  alanEtiket_Specified(Index: Integer): boolean;
    procedure SetalanSubeKodu(Index: Integer; const Astring: string);
    function  alanSubeKodu_Specified(Index: Integer): boolean;
    procedure SetalanVergiTcKimlikNo(Index: Integer; const Astring: string);
    function  alanVergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTarihi(Index: Integer; const Astring: string);
    function  belgeTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeTipi(Index: Integer; const Astring: string);
    function  belgeTipi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SeterpKodu(Index: Integer; const Astring: string);
    function  erpKodu_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetgonderenEtiket(Index: Integer; const Astring: string);
    function  gonderenEtiket_Specified(Index: Integer): boolean;
    procedure SetgonderenSubeKodu(Index: Integer; const Astring: string);
    function  gonderenSubeKodu_Specified(Index: Integer): boolean;
    procedure SetgonderimZamani(Index: Integer; const Astring: string);
    function  gonderimZamani_Specified(Index: Integer): boolean;
    procedure SetislemYapanVkn(Index: Integer; const Astring: string);
    function  islemYapanVkn_Specified(Index: Integer): boolean;
    procedure Setkaynak(Index: Integer; const Astring: string);
    function  kaynak_Specified(Index: Integer): boolean;
    procedure SetkullaniciKodu(Index: Integer; const Astring: string);
    function  kullaniciKodu_Specified(Index: Integer): boolean;
  published
    property alanEtiket:          string  Index (IS_OPTN) read FalanEtiket write SetalanEtiket stored alanEtiket_Specified;
    property alanSubeKodu:        string  Index (IS_OPTN) read FalanSubeKodu write SetalanSubeKodu stored alanSubeKodu_Specified;
    property alanVergiTcKimlikNo: string  Index (IS_OPTN) read FalanVergiTcKimlikNo write SetalanVergiTcKimlikNo stored alanVergiTcKimlikNo_Specified;
    property belgeNo:             string  Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property belgeTarihi:         string  Index (IS_OPTN) read FbelgeTarihi write SetbelgeTarihi stored belgeTarihi_Specified;
    property belgeTipi:           string  Index (IS_OPTN) read FbelgeTipi write SetbelgeTipi stored belgeTipi_Specified;
    property belgeTuru:           string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property erpKodu:             string  Index (IS_OPTN) read FerpKodu write SeterpKodu stored erpKodu_Specified;
    property ettn:                string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property gonderenEtiket:      string  Index (IS_OPTN) read FgonderenEtiket write SetgonderenEtiket stored gonderenEtiket_Specified;
    property gonderenSubeKodu:    string  Index (IS_OPTN) read FgonderenSubeKodu write SetgonderenSubeKodu stored gonderenSubeKodu_Specified;
    property gonderimZamani:      string  Index (IS_OPTN) read FgonderimZamani write SetgonderimZamani stored gonderimZamani_Specified;
    property islemYapanVkn:       string  Index (IS_OPTN) read FislemYapanVkn write SetislemYapanVkn stored islemYapanVkn_Specified;
    property kaynak:              string  Index (IS_OPTN) read Fkaynak write Setkaynak stored kaynak_Specified;
    property kullaniciKodu:       string  Index (IS_OPTN) read FkullaniciKodu write SetkullaniciKodu stored kullaniciKodu_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListelePortalDatav2, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListelePortalDatav2 = class(gidenBelgeleriListelePortalData)
  private
    FyanitEttn: string;
    FyanitEttn_Specified: boolean;
    procedure SetyanitEttn(Index: Integer; const Astring: string);
    function  yanitEttn_Specified(Index: Integer): boolean;
  published
    property yanitEttn: string  Index (IS_OPTN) read FyanitEttn write SetyanitEttn stored yanitEttn_Specified;
  end;



  // ************************************************************************ //
  // XML       : cokluGidenBelgeDurumSorgula, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  cokluGidenBelgeDurumSorgula2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fparametreler: gidenBelgeDurumParametreleri;
    Fparametreler_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setparametreler(Index: Integer; const AgidenBelgeDurumParametreleri: gidenBelgeDurumParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property vergiTcKimlikNo: string                        Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property parametreler:    gidenBelgeDurumParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : cokluGidenBelgeDurumSorgula, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  cokluGidenBelgeDurumSorgula = class(cokluGidenBelgeDurumSorgula2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaTarihcesiSorgula, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaTarihcesiSorgula2 = class(TRemotable)
  private
    Fettn: string;
    Fettn_Specified: boolean;
    FfaturaYonu: string;
    FfaturaYonu_Specified: boolean;
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetfaturaYonu(Index: Integer; const Astring: string);
    function  faturaYonu_Specified(Index: Integer): boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
  published
    property ettn:       string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property faturaYonu: string  Index (IS_OPTN) read FfaturaYonu write SetfaturaYonu stored faturaYonu_Specified;
    property vknTckn:    string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaTarihcesiSorgula, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaTarihcesiSorgula = class(faturaTarihcesiSorgula2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumParametreleri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumParametreleri = class(TRemotable)
  private
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    FbelgeNoList: efaturaKullaniciListesi2;
    FbelgeNoList_Specified: boolean;
    FbelgeNoTipi: string;
    FbelgeNoTipi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FdonusTipiVersiyon: string;
    FdonusTipiVersiyon_Specified: boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure SetbelgeNoList(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  belgeNoList_Specified(Index: Integer): boolean;
    procedure SetbelgeNoTipi(Index: Integer; const Astring: string);
    function  belgeNoTipi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetdonusTipiVersiyon(Index: Integer; const Astring: string);
    function  donusTipiVersiyon_Specified(Index: Integer): boolean;
  published
    property belgeNo:           string                    Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property belgeNoList:       efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FbelgeNoList write SetbelgeNoList stored belgeNoList_Specified;
    property belgeNoTipi:       string                    Index (IS_OPTN) read FbelgeNoTipi write SetbelgeNoTipi stored belgeNoTipi_Specified;
    property belgeTuru:         string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property donusTipiVersiyon: string                    Index (IS_OPTN) read FdonusTipiVersiyon write SetdonusTipiVersiyon stored donusTipiVersiyon_Specified;
  end;



  // ************************************************************************ //
  // XML       : irsaliyeMailGonder, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  irsaliyeMailGonder2 = class(TRemotable)
  private
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    FinOut: string;
    FinOut_Specified: boolean;
    FUUID: string;
    FUUID_Specified: boolean;
    FirsaliyeNo: string;
    FirsaliyeNo_Specified: boolean;
    Falicilar: string;
    Falicilar_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
    procedure SetinOut(Index: Integer; const Astring: string);
    function  inOut_Specified(Index: Integer): boolean;
    procedure SetUUID(Index: Integer; const Astring: string);
    function  UUID_Specified(Index: Integer): boolean;
    procedure SetirsaliyeNo(Index: Integer; const Astring: string);
    function  irsaliyeNo_Specified(Index: Integer): boolean;
    procedure Setalicilar(Index: Integer; const Astring: string);
    function  alicilar_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
  published
    property vknTckn:      string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
    property inOut:        string  Index (IS_OPTN) read FinOut write SetinOut stored inOut_Specified;
    property UUID:         string  Index (IS_OPTN) read FUUID write SetUUID stored UUID_Specified;
    property irsaliyeNo:   string  Index (IS_OPTN) read FirsaliyeNo write SetirsaliyeNo stored irsaliyeNo_Specified;
    property alicilar:     string  Index (IS_OPTN) read Falicilar write Setalicilar stored alicilar_Specified;
    property belgeFormati: string  Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
  end;



  // ************************************************************************ //
  // XML       : irsaliyeMailGonder, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  irsaliyeMailGonder = class(irsaliyeMailGonder2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildiIptal, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildiIptal2 = class(TRemotable)
  private
    Fuuid: string;
    Fuuid_Specified: boolean;
    FgelenGiden: string;
    FgelenGiden_Specified: boolean;
    procedure Setuuid(Index: Integer; const Astring: string);
    function  uuid_Specified(Index: Integer): boolean;
    procedure SetgelenGiden(Index: Integer; const Astring: string);
    function  gelenGiden_Specified(Index: Integer): boolean;
  published
    property uuid:       string  Index (IS_OPTN) read Fuuid write Setuuid stored uuid_Specified;
    property gelenGiden: string  Index (IS_OPTN) read FgelenGiden write SetgelenGiden stored gelenGiden_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildiIptal, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildiIptal = class(faturaKepIleIadeEdildiIptal2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Exception, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // Info      : Fault
  // Base Types: Exception
  // ************************************************************************ //
  Exception = class(ERemotableException)
  private
    Fmessage_: string;
    Fmessage__Specified: boolean;
    procedure Setmessage_(Index: Integer; const Astring: string);
    function  message__Specified(Index: Integer): boolean;
  published
    property message_: string  Index (IS_OPTN) read Fmessage_ write Setmessage_ stored message__Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenStandartRapolariAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenStandartRapolariAl2 = class(TRemotable)
  private
    FgonderenVknTckn: string;
    FgonderenVknTckn_Specified: boolean;
    FaliciVknTckn: string;
    FaliciVknTckn_Specified: boolean;
    FbaslangicTarihi: string;
    FbaslangicTarihi_Specified: boolean;
    FbitisTarihi: string;
    FbitisTarihi_Specified: boolean;
    FgonderimBaslangicTarihi: string;
    FgonderimBaslangicTarihi_Specified: boolean;
    FgonderimBitisTarihi: string;
    FgonderimBitisTarihi_Specified: boolean;
    procedure SetgonderenVknTckn(Index: Integer; const Astring: string);
    function  gonderenVknTckn_Specified(Index: Integer): boolean;
    procedure SetaliciVknTckn(Index: Integer; const Astring: string);
    function  aliciVknTckn_Specified(Index: Integer): boolean;
    procedure SetbaslangicTarihi(Index: Integer; const Astring: string);
    function  baslangicTarihi_Specified(Index: Integer): boolean;
    procedure SetbitisTarihi(Index: Integer; const Astring: string);
    function  bitisTarihi_Specified(Index: Integer): boolean;
    procedure SetgonderimBaslangicTarihi(Index: Integer; const Astring: string);
    function  gonderimBaslangicTarihi_Specified(Index: Integer): boolean;
    procedure SetgonderimBitisTarihi(Index: Integer; const Astring: string);
    function  gonderimBitisTarihi_Specified(Index: Integer): boolean;
  published
    property gonderenVknTckn:         string  Index (IS_OPTN) read FgonderenVknTckn write SetgonderenVknTckn stored gonderenVknTckn_Specified;
    property aliciVknTckn:            string  Index (IS_OPTN) read FaliciVknTckn write SetaliciVknTckn stored aliciVknTckn_Specified;
    property baslangicTarihi:         string  Index (IS_OPTN) read FbaslangicTarihi write SetbaslangicTarihi stored baslangicTarihi_Specified;
    property bitisTarihi:             string  Index (IS_OPTN) read FbitisTarihi write SetbitisTarihi stored bitisTarihi_Specified;
    property gonderimBaslangicTarihi: string  Index (IS_OPTN) read FgonderimBaslangicTarihi write SetgonderimBaslangicTarihi stored gonderimBaslangicTarihi_Specified;
    property gonderimBitisTarihi:     string  Index (IS_OPTN) read FgonderimBitisTarihi write SetgonderimBitisTarihi stored gonderimBitisTarihi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenStandartRapolariAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenStandartRapolariAl = class(gelenStandartRapolariAl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriListele, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriListele2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FsonAlinanBelgeSiraNumarasi: string;
    FsonAlinanBelgeSiraNumarasi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetsonAlinanBelgeSiraNumarasi(Index: Integer; const Astring: string);
    function  sonAlinanBelgeSiraNumarasi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:            string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property sonAlinanBelgeSiraNumarasi: string  Index (IS_OPTN) read FsonAlinanBelgeSiraNumarasi write SetsonAlinanBelgeSiraNumarasi stored sonAlinanBelgeSiraNumarasi_Specified;
    property belgeTuru:                  string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriListele, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriListele = class(gelenBelgeleriListele2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : eIrsaliyeKullanicisi, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eIrsaliyeKullanicisi2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : eIrsaliyeKullanicisi, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eIrsaliyeKullanicisi = class(eIrsaliyeKullanicisi2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : csXmlOnizleme, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlOnizleme2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    Fveri: TByteDynArray;
    Fveri_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    FxsltAdi: string;
    FxsltAdi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
    procedure Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  veri_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
    procedure SetxsltAdi(Index: Integer; const Astring: string);
    function  xsltAdi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string         Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeVersiyon:   string         Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
    property veri:            TByteDynArray  Index (IS_OPTN) read Fveri write Setveri stored veri_Specified;
    property belgeFormati:    string         Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
    property xsltAdi:         string         Index (IS_OPTN) read FxsltAdi write SetxsltAdi stored xsltAdi_Specified;
    property belgeTuru:       string         Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : csXmlOnizleme, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  csXmlOnizleme = class(csXmlOnizleme2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : urunSablonlariniAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  urunSablonlariniAl2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Furun: string;
    Furun_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Seturun(Index: Integer; const Astring: string);
    function  urun_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property urun:            string  Index (IS_OPTN) read Furun write Seturun stored urun_Specified;
  end;



  // ************************************************************************ //
  // XML       : urunSablonlariniAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  urunSablonlariniAl = class(urunSablonlariniAl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : eFaturaKayitliKullaniciListele, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eFaturaKayitliKullaniciListele2 = class(TRemotable)
  private
    FkayitZamani: string;
    FkayitZamani_Specified: boolean;
    procedure SetkayitZamani(Index: Integer; const Astring: string);
    function  kayitZamani_Specified(Index: Integer): boolean;
  published
    property kayitZamani: string  Index (IS_OPTN) read FkayitZamani write SetkayitZamani stored kayitZamani_Specified;
  end;



  // ************************************************************************ //
  // XML       : eFaturaKayitliKullaniciListele, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eFaturaKayitliKullaniciListele = class(eFaturaKayitliKullaniciListele2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgula, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgula2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeOid: string;
    FbelgeOid_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeOid(Index: Integer; const Astring: string);
    function  belgeOid_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeOid:        string  Index (IS_OPTN) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgula, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgula = class(gidenBelgeDurumSorgula2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildi, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildi2 = class(TRemotable)
  private
    Fuuid: string;
    Fuuid_Specified: boolean;
    FgelenGiden: string;
    FgelenGiden_Specified: boolean;
    procedure Setuuid(Index: Integer; const Astring: string);
    function  uuid_Specified(Index: Integer): boolean;
    procedure SetgelenGiden(Index: Integer; const Astring: string);
    function  gelenGiden_Specified(Index: Integer): boolean;
  published
    property uuid:       string  Index (IS_OPTN) read Fuuid write Setuuid stored uuid_Specified;
    property gelenGiden: string  Index (IS_OPTN) read FgelenGiden write SetgelenGiden stored gelenGiden_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildi, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildi = class(faturaKepIleIadeEdildi2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeTutarBilgileriSorgula, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeTutarBilgileriSorgula2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbaslangicGelisTarihi: string;
    FbaslangicGelisTarihi_Specified: boolean;
    FbitisGelisTarihi: string;
    FbitisGelisTarihi_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbaslangicGelisTarihi(Index: Integer; const Astring: string);
    function  baslangicGelisTarihi_Specified(Index: Integer): boolean;
    procedure SetbitisGelisTarihi(Index: Integer; const Astring: string);
    function  bitisGelisTarihi_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:      string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeTuru:            string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property baslangicGelisTarihi: string  Index (IS_OPTN) read FbaslangicGelisTarihi write SetbaslangicGelisTarihi stored baslangicGelisTarihi_Specified;
    property bitisGelisTarihi:     string  Index (IS_OPTN) read FbitisGelisTarihi write SetbitisGelisTarihi stored bitisGelisTarihi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeTutarBilgileriSorgula, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeTutarBilgileriSorgula = class(gelenBelgeTutarBilgileriSorgula2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeEkleriAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeEkleriAl2 = class(TRemotable)
  private
    Fuuid: string;
    Fuuid_Specified: boolean;
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure Setuuid(Index: Integer; const Astring: string);
    function  uuid_Specified(Index: Integer): boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property uuid:      string  Index (IS_OPTN) read Fuuid write Setuuid stored uuid_Specified;
    property vknTckn:   string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
    property belgeTuru: string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeEkleriAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeEkleriAl = class(gidenBelgeEkleriAl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirEttn, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirEttn2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeEttnListesi: efaturaKullaniciListesi2;
    FbelgeEttnListesi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  belgeEttnListesi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:  string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeEttnListesi: efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FbelgeEttnListesi write SetbelgeEttnListesi stored belgeEttnListesi_Specified;
    property belgeTuru:        string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeFormati:     string                    Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirEttn, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirEttn = class(gidenBelgeleriIndirEttn2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeParametreleri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeParametreleri = class(TRemotable)
  private
    FalanEtiket: efaturaKullaniciListesi2;
    FalanEtiket_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    FbelgelerAlindiMi: Boolean;
    FbelgelerAlindiMi_Specified: boolean;
    FdonusTipiVersiyon: string;
    FdonusTipiVersiyon_Specified: boolean;
    FentegrasyonHedefi: string;
    FentegrasyonHedefi_Specified: boolean;
    FerpKodu: string;
    FerpKodu_Specified: boolean;
    Fettn: efaturaKullaniciListesi2;
    Fettn_Specified: boolean;
    FfaturaTarihiBaslangic: string;
    FfaturaTarihiBaslangic_Specified: boolean;
    FfaturaTarihiBitis: string;
    FfaturaTarihiBitis_Specified: boolean;
    FgelisTarihiBaslangic: string;
    FgelisTarihiBaslangic_Specified: boolean;
    FgelisTarihiBitis: string;
    FgelisTarihiBitis_Specified: boolean;
    FgonderenEtiket: efaturaKullaniciListesi2;
    FgonderenEtiket_Specified: boolean;
    FonayDurum: string;
    FonayDurum_Specified: boolean;
    FsonAlinanBelgeSiraNumarasi: string;
    FsonAlinanBelgeSiraNumarasi_Specified: boolean;
    FsubeKodu: string;
    FsubeKodu_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure SetalanEtiket(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  alanEtiket_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
    procedure SetbelgelerAlindiMi(Index: Integer; const ABoolean: Boolean);
    function  belgelerAlindiMi_Specified(Index: Integer): boolean;
    procedure SetdonusTipiVersiyon(Index: Integer; const Astring: string);
    function  donusTipiVersiyon_Specified(Index: Integer): boolean;
    procedure SetentegrasyonHedefi(Index: Integer; const Astring: string);
    function  entegrasyonHedefi_Specified(Index: Integer): boolean;
    procedure SeterpKodu(Index: Integer; const Astring: string);
    function  erpKodu_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetfaturaTarihiBaslangic(Index: Integer; const Astring: string);
    function  faturaTarihiBaslangic_Specified(Index: Integer): boolean;
    procedure SetfaturaTarihiBitis(Index: Integer; const Astring: string);
    function  faturaTarihiBitis_Specified(Index: Integer): boolean;
    procedure SetgelisTarihiBaslangic(Index: Integer; const Astring: string);
    function  gelisTarihiBaslangic_Specified(Index: Integer): boolean;
    procedure SetgelisTarihiBitis(Index: Integer; const Astring: string);
    function  gelisTarihiBitis_Specified(Index: Integer): boolean;
    procedure SetgonderenEtiket(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  gonderenEtiket_Specified(Index: Integer): boolean;
    procedure SetonayDurum(Index: Integer; const Astring: string);
    function  onayDurum_Specified(Index: Integer): boolean;
    procedure SetsonAlinanBelgeSiraNumarasi(Index: Integer; const Astring: string);
    function  sonAlinanBelgeSiraNumarasi_Specified(Index: Integer): boolean;
    procedure SetsubeKodu(Index: Integer; const Astring: string);
    function  subeKodu_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property alanEtiket:                 efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FalanEtiket write SetalanEtiket stored alanEtiket_Specified;
    property belgeFormati:               string                    Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
    property belgeTuru:                  string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeVersiyon:              string                    Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
    property belgelerAlindiMi:           Boolean                   Index (IS_OPTN) read FbelgelerAlindiMi write SetbelgelerAlindiMi stored belgelerAlindiMi_Specified;
    property donusTipiVersiyon:          string                    Index (IS_OPTN) read FdonusTipiVersiyon write SetdonusTipiVersiyon stored donusTipiVersiyon_Specified;
    property entegrasyonHedefi:          string                    Index (IS_OPTN) read FentegrasyonHedefi write SetentegrasyonHedefi stored entegrasyonHedefi_Specified;
    property erpKodu:                    string                    Index (IS_OPTN) read FerpKodu write SeterpKodu stored erpKodu_Specified;
    property ettn:                       efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettn write Setettn stored ettn_Specified;
    property faturaTarihiBaslangic:      string                    Index (IS_OPTN) read FfaturaTarihiBaslangic write SetfaturaTarihiBaslangic stored faturaTarihiBaslangic_Specified;
    property faturaTarihiBitis:          string                    Index (IS_OPTN) read FfaturaTarihiBitis write SetfaturaTarihiBitis stored faturaTarihiBitis_Specified;
    property gelisTarihiBaslangic:       string                    Index (IS_OPTN) read FgelisTarihiBaslangic write SetgelisTarihiBaslangic stored gelisTarihiBaslangic_Specified;
    property gelisTarihiBitis:           string                    Index (IS_OPTN) read FgelisTarihiBitis write SetgelisTarihiBitis stored gelisTarihiBitis_Specified;
    property gonderenEtiket:             efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FgonderenEtiket write SetgonderenEtiket stored gonderenEtiket_Specified;
    property onayDurum:                  string                    Index (IS_OPTN) read FonayDurum write SetonayDurum stored onayDurum_Specified;
    property sonAlinanBelgeSiraNumarasi: string                    Index (IS_OPTN) read FsonAlinanBelgeSiraNumarasi write SetsonAlinanBelgeSiraNumarasi stored sonAlinanBelgeSiraNumarasi_Specified;
    property subeKodu:                   string                    Index (IS_OPTN) read FsubeKodu write SetsubeKodu stored subeKodu_Specified;
    property vergiTcKimlikNo:            string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : eFaturaKullanici, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eFaturaKullanici = class(serviceReturnType2)
  private
    Fetiket: string;
    Fetiket_Specified: boolean;
    FkamuKurulusu: Boolean;
    FkayitZamani: string;
    FkayitZamani_Specified: boolean;
    Funvan: string;
    Funvan_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure Setetiket(Index: Integer; const Astring: string);
    function  etiket_Specified(Index: Integer): boolean;
    procedure SetkayitZamani(Index: Integer; const Astring: string);
    function  kayitZamani_Specified(Index: Integer): boolean;
    procedure Setunvan(Index: Integer; const Astring: string);
    function  unvan_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property etiket:          string   Index (IS_OPTN) read Fetiket write Setetiket stored etiket_Specified;
    property kamuKurulusu:    Boolean  read FkamuKurulusu write FkamuKurulusu;
    property kayitZamani:     string   Index (IS_OPTN) read FkayitZamani write SetkayitZamani stored kayitZamani_Specified;
    property unvan:           string   Index (IS_OPTN) read Funvan write Setunvan stored unvan_Specified;
    property vergiTcKimlikNo: string   Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : eIrsaliyeKullanici, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eIrsaliyeKullanici = class(serviceReturnType2)
  private
    Fetiket: string;
    Fetiket_Specified: boolean;
    FkamuKurulusu: Boolean;
    FkayitZamani: string;
    FkayitZamani_Specified: boolean;
    Funvan: string;
    Funvan_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure Setetiket(Index: Integer; const Astring: string);
    function  etiket_Specified(Index: Integer): boolean;
    procedure SetkayitZamani(Index: Integer; const Astring: string);
    function  kayitZamani_Specified(Index: Integer): boolean;
    procedure Setunvan(Index: Integer; const Astring: string);
    function  unvan_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property etiket:          string   Index (IS_OPTN) read Fetiket write Setetiket stored etiket_Specified;
    property kamuKurulusu:    Boolean  read FkamuKurulusu write FkamuKurulusu;
    property kayitZamani:     string   Index (IS_OPTN) read FkayitZamani write SetkayitZamani stored kayitZamani_Specified;
    property unvan:           string   Index (IS_OPTN) read Funvan write Setunvan stored unvan_Specified;
    property vergiTcKimlikNo: string   Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildiIptalResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildiIptalResponse2 = class(TRemotable)
  private
    Freturn: Boolean;
  published
    property return: Boolean  read Freturn write Freturn;
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildiIptalResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildiIptalResponse = class(faturaKepIleIadeEdildiIptalResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderYerelBelgeNoResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderYerelBelgeNoResponse2 = class(TRemotable)
  private
    Freturn: Boolean;
  published
    property return: Boolean  read Freturn write Freturn;
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderYerelBelgeNoResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderYerelBelgeNoResponse = class(belgeleriTekrarGonderYerelBelgeNoResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : eIrsaliyeKullanicisiResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eIrsaliyeKullanicisiResponse2 = class(TRemotable)
  private
    Freturn: Boolean;
  published
    property return: Boolean  read Freturn write Freturn;
  end;



  // ************************************************************************ //
  // XML       : eIrsaliyeKullanicisiResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eIrsaliyeKullanicisiResponse = class(eIrsaliyeKullanicisiResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildiResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildiResponse2 = class(TRemotable)
  private
    Freturn: Boolean;
  published
    property return: Boolean  read Freturn write Freturn;
  end;



  // ************************************************************************ //
  // XML       : faturaKepIleIadeEdildiResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaKepIleIadeEdildiResponse = class(faturaKepIleIadeEdildiResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgulaExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgulaExt2 = class(TRemotable)
  private
    Fparametreler: gelenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gelenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgulaExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgulaExt = class(gelenBelgeDurumSorgulaExt2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenTasinanBelgeleriIndirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTasinanBelgeleriIndirResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenTasinanBelgeleriIndirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTasinanBelgeleriIndirResponse = class(gelenTasinanBelgeleriIndirResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Exception, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  Exception2 = class(TRemotable)
  private
    Fmessage_: string;
    Fmessage__Specified: boolean;
    procedure Setmessage_(Index: Integer; const Astring: string);
    function  message__Specified(Index: Integer): boolean;
  published
    property message_: string  Index (IS_OPTN) read Fmessage_ write Setmessage_ stored message__Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListeleData, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListeleData = class(serviceReturnType2)
  private
    FalimDurumu: string;
    FalimDurumu_Specified: boolean;
    FalimZamani: string;
    FalimZamani_Specified: boolean;
    FbelgeOid: string;
    FbelgeOid_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    FhataMesaji: string;
    FhataMesaji_Specified: boolean;
    FislemYapanVkn: string;
    FislemYapanVkn_Specified: boolean;
    Fkaynak: string;
    Fkaynak_Specified: boolean;
    FkullaniciKodu: string;
    FkullaniciKodu_Specified: boolean;
    FyerelBelgeNo: string;
    FyerelBelgeNo_Specified: boolean;
    procedure SetalimDurumu(Index: Integer; const Astring: string);
    function  alimDurumu_Specified(Index: Integer): boolean;
    procedure SetalimZamani(Index: Integer; const Astring: string);
    function  alimZamani_Specified(Index: Integer): boolean;
    procedure SetbelgeOid(Index: Integer; const Astring: string);
    function  belgeOid_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SethataMesaji(Index: Integer; const Astring: string);
    function  hataMesaji_Specified(Index: Integer): boolean;
    procedure SetislemYapanVkn(Index: Integer; const Astring: string);
    function  islemYapanVkn_Specified(Index: Integer): boolean;
    procedure Setkaynak(Index: Integer; const Astring: string);
    function  kaynak_Specified(Index: Integer): boolean;
    procedure SetkullaniciKodu(Index: Integer; const Astring: string);
    function  kullaniciKodu_Specified(Index: Integer): boolean;
    procedure SetyerelBelgeNo(Index: Integer; const Astring: string);
    function  yerelBelgeNo_Specified(Index: Integer): boolean;
  published
    property alimDurumu:    string  Index (IS_OPTN) read FalimDurumu write SetalimDurumu stored alimDurumu_Specified;
    property alimZamani:    string  Index (IS_OPTN) read FalimZamani write SetalimZamani stored alimZamani_Specified;
    property belgeOid:      string  Index (IS_OPTN) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
    property ettn:          string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property hataMesaji:    string  Index (IS_OPTN) read FhataMesaji write SethataMesaji stored hataMesaji_Specified;
    property islemYapanVkn: string  Index (IS_OPTN) read FislemYapanVkn write SetislemYapanVkn stored islemYapanVkn_Specified;
    property kaynak:        string  Index (IS_OPTN) read Fkaynak write Setkaynak stored kaynak_Specified;
    property kullaniciKodu: string  Index (IS_OPTN) read FkullaniciKodu write SetkullaniciKodu stored kullaniciKodu_Specified;
    property yerelBelgeNo:  string  Index (IS_OPTN) read FyerelBelgeNo write SetyerelBelgeNo stored yerelBelgeNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaTarihcesiData, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaTarihcesiData = class(serviceReturnType2)
  private
    FbagliKayitId: string;
    FbagliKayitId_Specified: boolean;
    FfaturaEttn: string;
    FfaturaEttn_Specified: boolean;
    Fislem: SmallInt;
    FislemAciklama: string;
    FislemAciklama_Specified: boolean;
    FislemKanali: ShortInt;
    FislemKanaliAciklama: string;
    FislemKanaliAciklama_Specified: boolean;
    FislemSonucu: string;
    FislemSonucu_Specified: boolean;
    FislemZamani: string;
    FislemZamani_Specified: boolean;
    Fkullanici: string;
    Fkullanici_Specified: boolean;
    FkullaniciIp: string;
    FkullaniciIp_Specified: boolean;
    FzarfEttn: string;
    FzarfEttn_Specified: boolean;
    procedure SetbagliKayitId(Index: Integer; const Astring: string);
    function  bagliKayitId_Specified(Index: Integer): boolean;
    procedure SetfaturaEttn(Index: Integer; const Astring: string);
    function  faturaEttn_Specified(Index: Integer): boolean;
    procedure SetislemAciklama(Index: Integer; const Astring: string);
    function  islemAciklama_Specified(Index: Integer): boolean;
    procedure SetislemKanaliAciklama(Index: Integer; const Astring: string);
    function  islemKanaliAciklama_Specified(Index: Integer): boolean;
    procedure SetislemSonucu(Index: Integer; const Astring: string);
    function  islemSonucu_Specified(Index: Integer): boolean;
    procedure SetislemZamani(Index: Integer; const Astring: string);
    function  islemZamani_Specified(Index: Integer): boolean;
    procedure Setkullanici(Index: Integer; const Astring: string);
    function  kullanici_Specified(Index: Integer): boolean;
    procedure SetkullaniciIp(Index: Integer; const Astring: string);
    function  kullaniciIp_Specified(Index: Integer): boolean;
    procedure SetzarfEttn(Index: Integer; const Astring: string);
    function  zarfEttn_Specified(Index: Integer): boolean;
  published
    property bagliKayitId:        string    Index (IS_OPTN) read FbagliKayitId write SetbagliKayitId stored bagliKayitId_Specified;
    property faturaEttn:          string    Index (IS_OPTN) read FfaturaEttn write SetfaturaEttn stored faturaEttn_Specified;
    property islem:               SmallInt  read Fislem write Fislem;
    property islemAciklama:       string    Index (IS_OPTN) read FislemAciklama write SetislemAciklama stored islemAciklama_Specified;
    property islemKanali:         ShortInt  read FislemKanali write FislemKanali;
    property islemKanaliAciklama: string    Index (IS_OPTN) read FislemKanaliAciklama write SetislemKanaliAciklama stored islemKanaliAciklama_Specified;
    property islemSonucu:         string    Index (IS_OPTN) read FislemSonucu write SetislemSonucu stored islemSonucu_Specified;
    property islemZamani:         string    Index (IS_OPTN) read FislemZamani write SetislemZamani stored islemZamani_Specified;
    property kullanici:           string    Index (IS_OPTN) read Fkullanici write Setkullanici stored kullanici_Specified;
    property kullaniciIp:         string    Index (IS_OPTN) read FkullaniciIp write SetkullaniciIp stored kullaniciIp_Specified;
    property zarfEttn:            string    Index (IS_OPTN) read FzarfEttn write SetzarfEttn stored zarfEttn_Specified;
  end;



  // ************************************************************************ //
  // XML       : irsaliyeTarihcesiData, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  irsaliyeTarihcesiData = class(serviceReturnType2)
  private
    FbagliKayitId: string;
    FbagliKayitId_Specified: boolean;
    FirsaliyeEttn: string;
    FirsaliyeEttn_Specified: boolean;
    Fislem: SmallInt;
    FislemAciklama: string;
    FislemAciklama_Specified: boolean;
    FislemKanali: ShortInt;
    FislemKanaliAciklama: string;
    FislemKanaliAciklama_Specified: boolean;
    FislemSonucu: string;
    FislemSonucu_Specified: boolean;
    FislemZamani: string;
    FislemZamani_Specified: boolean;
    Fkullanici: string;
    Fkullanici_Specified: boolean;
    FkullaniciIp: string;
    FkullaniciIp_Specified: boolean;
    FzarfEttn: string;
    FzarfEttn_Specified: boolean;
    procedure SetbagliKayitId(Index: Integer; const Astring: string);
    function  bagliKayitId_Specified(Index: Integer): boolean;
    procedure SetirsaliyeEttn(Index: Integer; const Astring: string);
    function  irsaliyeEttn_Specified(Index: Integer): boolean;
    procedure SetislemAciklama(Index: Integer; const Astring: string);
    function  islemAciklama_Specified(Index: Integer): boolean;
    procedure SetislemKanaliAciklama(Index: Integer; const Astring: string);
    function  islemKanaliAciklama_Specified(Index: Integer): boolean;
    procedure SetislemSonucu(Index: Integer; const Astring: string);
    function  islemSonucu_Specified(Index: Integer): boolean;
    procedure SetislemZamani(Index: Integer; const Astring: string);
    function  islemZamani_Specified(Index: Integer): boolean;
    procedure Setkullanici(Index: Integer; const Astring: string);
    function  kullanici_Specified(Index: Integer): boolean;
    procedure SetkullaniciIp(Index: Integer; const Astring: string);
    function  kullaniciIp_Specified(Index: Integer): boolean;
    procedure SetzarfEttn(Index: Integer; const Astring: string);
    function  zarfEttn_Specified(Index: Integer): boolean;
  published
    property bagliKayitId:        string    Index (IS_OPTN) read FbagliKayitId write SetbagliKayitId stored bagliKayitId_Specified;
    property irsaliyeEttn:        string    Index (IS_OPTN) read FirsaliyeEttn write SetirsaliyeEttn stored irsaliyeEttn_Specified;
    property islem:               SmallInt  read Fislem write Fislem;
    property islemAciklama:       string    Index (IS_OPTN) read FislemAciklama write SetislemAciklama stored islemAciklama_Specified;
    property islemKanali:         ShortInt  read FislemKanali write FislemKanali;
    property islemKanaliAciklama: string    Index (IS_OPTN) read FislemKanaliAciklama write SetislemKanaliAciklama stored islemKanaliAciklama_Specified;
    property islemSonucu:         string    Index (IS_OPTN) read FislemSonucu write SetislemSonucu stored islemSonucu_Specified;
    property islemZamani:         string    Index (IS_OPTN) read FislemZamani write SetislemZamani stored islemZamani_Specified;
    property kullanici:           string    Index (IS_OPTN) read Fkullanici write Setkullanici stored kullanici_Specified;
    property kullaniciIp:         string    Index (IS_OPTN) read FkullaniciIp write SetkullaniciIp stored kullaniciIp_Specified;
    property zarfEttn:            string    Index (IS_OPTN) read FzarfEttn write SetzarfEttn stored zarfEttn_Specified;
  end;



  // ************************************************************************ //
  // XML       : eFaturaKayitliKullaniciHistory, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eFaturaKayitliKullaniciHistory = class(TRemotable)
  private
    Fetiket: string;
    Fetiket_Specified: boolean;
    FetiketOlusturulmaZamani: string;
    FetiketOlusturulmaZamani_Specified: boolean;
    FsilinmeZamani: string;
    FsilinmeZamani_Specified: boolean;
    procedure Setetiket(Index: Integer; const Astring: string);
    function  etiket_Specified(Index: Integer): boolean;
    procedure SetetiketOlusturulmaZamani(Index: Integer; const Astring: string);
    function  etiketOlusturulmaZamani_Specified(Index: Integer): boolean;
    procedure SetsilinmeZamani(Index: Integer; const Astring: string);
    function  silinmeZamani_Specified(Index: Integer): boolean;
  published
    property etiket:                  string  Index (IS_OPTN) read Fetiket write Setetiket stored etiket_Specified;
    property etiketOlusturulmaZamani: string  Index (IS_OPTN) read FetiketOlusturulmaZamani write SetetiketOlusturulmaZamani stored etiketOlusturulmaZamani_Specified;
    property silinmeZamani:           string  Index (IS_OPTN) read FsilinmeZamani write SetsilinmeZamani stored silinmeZamani_Specified;
  end;



  // ************************************************************************ //
  // XML       : eFaturaKullaniciExtended, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eFaturaKullaniciExtended = class(serviceReturnType2)
  private
    Fetiket: string;
    Fetiket_Specified: boolean;
    FetiketOlusturulmaZamani: string;
    FetiketOlusturulmaZamani_Specified: boolean;
    FhesapTipi: Integer;
    FhesapTipi_Specified: boolean;
    FkamuKurulusu: Boolean;
    FkayitZamani: string;
    FkayitZamani_Specified: boolean;
    Ftip: Integer;
    Ftip_Specified: boolean;
    Funvan: string;
    Funvan_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FeFaturaKayitliKullaniciHistoryList: Array_Of_eFaturaKayitliKullaniciHistory;
    FeFaturaKayitliKullaniciHistoryList_Specified: boolean;
    procedure Setetiket(Index: Integer; const Astring: string);
    function  etiket_Specified(Index: Integer): boolean;
    procedure SetetiketOlusturulmaZamani(Index: Integer; const Astring: string);
    function  etiketOlusturulmaZamani_Specified(Index: Integer): boolean;
    procedure SethesapTipi(Index: Integer; const AInteger: Integer);
    function  hesapTipi_Specified(Index: Integer): boolean;
    procedure SetkayitZamani(Index: Integer; const Astring: string);
    function  kayitZamani_Specified(Index: Integer): boolean;
    procedure Settip(Index: Integer; const AInteger: Integer);
    function  tip_Specified(Index: Integer): boolean;
    procedure Setunvan(Index: Integer; const Astring: string);
    function  unvan_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SeteFaturaKayitliKullaniciHistoryList(Index: Integer; const AArray_Of_eFaturaKayitliKullaniciHistory: Array_Of_eFaturaKayitliKullaniciHistory);
    function  eFaturaKayitliKullaniciHistoryList_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property etiket:                             string                                   Index (IS_OPTN) read Fetiket write Setetiket stored etiket_Specified;
    property etiketOlusturulmaZamani:            string                                   Index (IS_OPTN) read FetiketOlusturulmaZamani write SetetiketOlusturulmaZamani stored etiketOlusturulmaZamani_Specified;
    property hesapTipi:                          Integer                                  Index (IS_OPTN) read FhesapTipi write SethesapTipi stored hesapTipi_Specified;
    property kamuKurulusu:                       Boolean                                  read FkamuKurulusu write FkamuKurulusu;
    property kayitZamani:                        string                                   Index (IS_OPTN) read FkayitZamani write SetkayitZamani stored kayitZamani_Specified;
    property tip:                                Integer                                  Index (IS_OPTN) read Ftip write Settip stored tip_Specified;
    property unvan:                              string                                   Index (IS_OPTN) read Funvan write Setunvan stored unvan_Specified;
    property vergiTcKimlikNo:                    string                                   Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property eFaturaKayitliKullaniciHistoryList: Array_Of_eFaturaKayitliKullaniciHistory  Index (IS_OPTN or IS_UNBD) read FeFaturaKayitliKullaniciHistoryList write SeteFaturaKayitliKullaniciHistoryList stored eFaturaKayitliKullaniciHistoryList_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurum, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurum = class(serviceReturnType2)
  private
    Faciklama: string;
    Faciklama_Specified: boolean;
    FalimTarihi: string;
    FalimTarihi_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    Fdurum: Integer;
    Fettn: string;
    Fettn_Specified: boolean;
    FgonderimCevabiDetayi: string;
    FgonderimCevabiDetayi_Specified: boolean;
    FgonderimCevabiKodu: Integer;
    FgonderimDurumu: Integer;
    FgonderimTarihi: string;
    FgonderimTarihi_Specified: boolean;
    FolusturulmaTarihi: string;
    FolusturulmaTarihi_Specified: boolean;
    FyanitDetayi: string;
    FyanitDetayi_Specified: boolean;
    FyanitDurumu: Integer;
    FyanitTarihi: string;
    FyanitTarihi_Specified: boolean;
    procedure Setaciklama(Index: Integer; const Astring: string);
    function  aciklama_Specified(Index: Integer): boolean;
    procedure SetalimTarihi(Index: Integer; const Astring: string);
    function  alimTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetgonderimCevabiDetayi(Index: Integer; const Astring: string);
    function  gonderimCevabiDetayi_Specified(Index: Integer): boolean;
    procedure SetgonderimTarihi(Index: Integer; const Astring: string);
    function  gonderimTarihi_Specified(Index: Integer): boolean;
    procedure SetolusturulmaTarihi(Index: Integer; const Astring: string);
    function  olusturulmaTarihi_Specified(Index: Integer): boolean;
    procedure SetyanitDetayi(Index: Integer; const Astring: string);
    function  yanitDetayi_Specified(Index: Integer): boolean;
    procedure SetyanitTarihi(Index: Integer; const Astring: string);
    function  yanitTarihi_Specified(Index: Integer): boolean;
  published
    property aciklama:             string   Index (IS_OPTN) read Faciklama write Setaciklama stored aciklama_Specified;
    property alimTarihi:           string   Index (IS_OPTN) read FalimTarihi write SetalimTarihi stored alimTarihi_Specified;
    property belgeNo:              string   Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property durum:                Integer  read Fdurum write Fdurum;
    property ettn:                 string   Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property gonderimCevabiDetayi: string   Index (IS_OPTN) read FgonderimCevabiDetayi write SetgonderimCevabiDetayi stored gonderimCevabiDetayi_Specified;
    property gonderimCevabiKodu:   Integer  read FgonderimCevabiKodu write FgonderimCevabiKodu;
    property gonderimDurumu:       Integer  read FgonderimDurumu write FgonderimDurumu;
    property gonderimTarihi:       string   Index (IS_OPTN) read FgonderimTarihi write SetgonderimTarihi stored gonderimTarihi_Specified;
    property olusturulmaTarihi:    string   Index (IS_OPTN) read FolusturulmaTarihi write SetolusturulmaTarihi stored olusturulmaTarihi_Specified;
    property yanitDetayi:          string   Index (IS_OPTN) read FyanitDetayi write SetyanitDetayi stored yanitDetayi_Specified;
    property yanitDurumu:          Integer  read FyanitDurumu write FyanitDurumu;
    property yanitTarihi:          string   Index (IS_OPTN) read FyanitTarihi write SetyanitTarihi stored yanitTarihi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumv2, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumv2 = class(gidenBelgeDurum)
  private
    FulastiMi: Boolean;
    FyenidenGonderilebilirMi: Boolean;
  published
    property ulastiMi:                Boolean  read FulastiMi write FulastiMi;
    property yenidenGonderilebilirMi: Boolean  read FyenidenGonderilebilirMi write FyenidenGonderilebilirMi;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumv3, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumv3 = class(gidenBelgeDurumv2)
  private
    FyerelBelgeOid: string;
    FyerelBelgeOid_Specified: boolean;
    procedure SetyerelBelgeOid(Index: Integer; const Astring: string);
    function  yerelBelgeOid_Specified(Index: Integer): boolean;
  published
    property yerelBelgeOid: string  Index (IS_OPTN) read FyerelBelgeOid write SetyerelBelgeOid stored yerelBelgeOid_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumv4, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumv4 = class(gidenBelgeDurumv3)
  private
    FgtbFiiliIhracatTarihi: string;
    FgtbFiiliIhracatTarihi_Specified: boolean;
    FgtbGcbTescilNo: string;
    FgtbGcbTescilNo_Specified: boolean;
    FgtbRefNo: string;
    FgtbRefNo_Specified: boolean;
    procedure SetgtbFiiliIhracatTarihi(Index: Integer; const Astring: string);
    function  gtbFiiliIhracatTarihi_Specified(Index: Integer): boolean;
    procedure SetgtbGcbTescilNo(Index: Integer; const Astring: string);
    function  gtbGcbTescilNo_Specified(Index: Integer): boolean;
    procedure SetgtbRefNo(Index: Integer; const Astring: string);
    function  gtbRefNo_Specified(Index: Integer): boolean;
  published
    property gtbFiiliIhracatTarihi: string  Index (IS_OPTN) read FgtbFiiliIhracatTarihi write SetgtbFiiliIhracatTarihi stored gtbFiiliIhracatTarihi_Specified;
    property gtbGcbTescilNo:        string  Index (IS_OPTN) read FgtbGcbTescilNo write SetgtbGcbTescilNo stored gtbGcbTescilNo_Specified;
    property gtbRefNo:              string  Index (IS_OPTN) read FgtbRefNo write SetgtbRefNo stored gtbRefNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumv5, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumv5 = class(gidenBelgeDurumv4)
  private
    FyanitEttn: string;
    FyanitEttn_Specified: boolean;
    FyanitVerilenBelgeEttn: string;
    FyanitVerilenBelgeEttn_Specified: boolean;
    procedure SetyanitEttn(Index: Integer; const Astring: string);
    function  yanitEttn_Specified(Index: Integer): boolean;
    procedure SetyanitVerilenBelgeEttn(Index: Integer; const Astring: string);
    function  yanitVerilenBelgeEttn_Specified(Index: Integer): boolean;
  published
    property yanitEttn:             string  Index (IS_OPTN) read FyanitEttn write SetyanitEttn stored yanitEttn_Specified;
    property yanitVerilenBelgeEttn: string  Index (IS_OPTN) read FyanitVerilenBelgeEttn write SetyanitVerilenBelgeEttn stored yanitVerilenBelgeEttn_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumv6, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumv6 = class(gidenBelgeDurumv5)
  private
    FkepDurum: string;
    FkepDurum_Specified: boolean;
    procedure SetkepDurum(Index: Integer; const Astring: string);
    function  kepDurum_Specified(Index: Integer): boolean;
  published
    property kepDurum: string  Index (IS_OPTN) read FkepDurum write SetkepDurum stored kepDurum_Specified;
  end;



  // ************************************************************************ //
  // XML       : kontorAzaltResp, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kontorAzaltResp = class(serviceReturnType2)
  private
    FkanalTipi: Integer;
    FkontorAzaldi: Boolean;
    FkontorTipi: string;
    FkontorTipi_Specified: boolean;
    Fmiktar: TXSDecimal;
    Fmiktar_Specified: boolean;
    FodemeTipi: Integer;
    FpaketTipi: Integer;
    Fvkn: string;
    Fvkn_Specified: boolean;
    procedure SetkontorTipi(Index: Integer; const Astring: string);
    function  kontorTipi_Specified(Index: Integer): boolean;
    procedure Setmiktar(Index: Integer; const ATXSDecimal: TXSDecimal);
    function  miktar_Specified(Index: Integer): boolean;
    procedure Setvkn(Index: Integer; const Astring: string);
    function  vkn_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property kanalTipi:    Integer     read FkanalTipi write FkanalTipi;
    property kontorAzaldi: Boolean     read FkontorAzaldi write FkontorAzaldi;
    property kontorTipi:   string      Index (IS_OPTN) read FkontorTipi write SetkontorTipi stored kontorTipi_Specified;
    property miktar:       TXSDecimal  Index (IS_OPTN) read Fmiktar write Setmiktar stored miktar_Specified;
    property odemeTipi:    Integer     read FodemeTipi write FodemeTipi;
    property paketTipi:    Integer     read FpaketTipi write FpaketTipi;
    property vkn:          string      Index (IS_OPTN) read Fvkn write Setvkn stored vkn_Specified;
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedTime, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedTime2 = class(TRemotable)
  private
    FkayitZamani: string;
    FkayitZamani_Specified: boolean;
    Furun: string;
    Furun_Specified: boolean;
    FgecmisEklensin: Integer;
    FgecmisEklensin_Specified: boolean;
    procedure SetkayitZamani(Index: Integer; const Astring: string);
    function  kayitZamani_Specified(Index: Integer): boolean;
    procedure Seturun(Index: Integer; const Astring: string);
    function  urun_Specified(Index: Integer): boolean;
    procedure SetgecmisEklensin(Index: Integer; const AInteger: Integer);
    function  gecmisEklensin_Specified(Index: Integer): boolean;
  published
    property kayitZamani:    string   Index (IS_OPTN) read FkayitZamani write SetkayitZamani stored kayitZamani_Specified;
    property urun:           string   Index (IS_OPTN) read Furun write Seturun stored urun_Specified;
    property gecmisEklensin: Integer  Index (IS_OPTN) read FgecmisEklensin write SetgecmisEklensin stored gecmisEklensin_Specified;
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedTime, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedTime = class(kayitliKullaniciListeleExtendedTime2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurum, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurum = class(serviceReturnType2)
  private
    FalimTarihi: string;
    FalimTarihi_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    FyanitDetayi: string;
    FyanitDetayi_Specified: boolean;
    FyanitDurumu: Integer;
    FyanitGonderimCevabiDetayi: string;
    FyanitGonderimCevabiDetayi_Specified: boolean;
    FyanitGonderimCevabiKodu: Integer;
    FyanitGonderimDurumu: Integer;
    FyanitGonderimTarihi: string;
    FyanitGonderimTarihi_Specified: boolean;
    procedure SetalimTarihi(Index: Integer; const Astring: string);
    function  alimTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetyanitDetayi(Index: Integer; const Astring: string);
    function  yanitDetayi_Specified(Index: Integer): boolean;
    procedure SetyanitGonderimCevabiDetayi(Index: Integer; const Astring: string);
    function  yanitGonderimCevabiDetayi_Specified(Index: Integer): boolean;
    procedure SetyanitGonderimTarihi(Index: Integer; const Astring: string);
    function  yanitGonderimTarihi_Specified(Index: Integer): boolean;
  published
    property alimTarihi:                string   Index (IS_OPTN) read FalimTarihi write SetalimTarihi stored alimTarihi_Specified;
    property belgeNo:                   string   Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property ettn:                      string   Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property yanitDetayi:               string   Index (IS_OPTN) read FyanitDetayi write SetyanitDetayi stored yanitDetayi_Specified;
    property yanitDurumu:               Integer  read FyanitDurumu write FyanitDurumu;
    property yanitGonderimCevabiDetayi: string   Index (IS_OPTN) read FyanitGonderimCevabiDetayi write SetyanitGonderimCevabiDetayi stored yanitGonderimCevabiDetayi_Specified;
    property yanitGonderimCevabiKodu:   Integer  read FyanitGonderimCevabiKodu write FyanitGonderimCevabiKodu;
    property yanitGonderimDurumu:       Integer  read FyanitGonderimDurumu write FyanitGonderimDurumu;
    property yanitGonderimTarihi:       string   Index (IS_OPTN) read FyanitGonderimTarihi write SetyanitGonderimTarihi stored yanitGonderimTarihi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumv2, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumv2 = class(gelenBelgeDurum)
  private
    FsiraNo: Int64;
    FyereleAktarimDurumu: Integer;
  published
    property siraNo:              Int64    read FsiraNo write FsiraNo;
    property yereleAktarimDurumu: Integer  read FyereleAktarimDurumu write FyereleAktarimDurumu;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumv3, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumv3 = class(gelenBelgeDurumv2)
  private
    FkepDurum: string;
    FkepDurum_Specified: boolean;
    procedure SetkepDurum(Index: Integer; const Astring: string);
    function  kepDurum_Specified(Index: Integer): boolean;
  published
    property kepDurum: string  Index (IS_OPTN) read FkepDurum write SetkepDurum stored kepDurum_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumv4, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumv4 = class(gelenBelgeDurumv3)
  private
    FgibIptalDurum: string;
    FgibIptalDurum_Specified: boolean;
    procedure SetgibIptalDurum(Index: Integer; const Astring: string);
    function  gibIptalDurum_Specified(Index: Integer): boolean;
  published
    property gibIptalDurum: string  Index (IS_OPTN) read FgibIptalDurum write SetgibIptalDurum stored gibIptalDurum_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumv5, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumv5 = class(gelenBelgeDurumv4)
  private
    FyanitEttn: string;
    FyanitEttn_Specified: boolean;
    procedure SetyanitEttn(Index: Integer; const Astring: string);
    function  yanitEttn_Specified(Index: Integer): boolean;
  published
    property yanitEttn: string  Index (IS_OPTN) read FyanitEttn write SetyanitEttn stored yanitEttn_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirPortalResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirPortalResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirPortalResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirPortalResponse = class(gidenBelgeleriIndirPortalResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListele, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListele2 = class(TRemotable)
  private
    Fparametreler: gidenBelgeleriListeleParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgidenBelgeleriListeleParametreleri: gidenBelgeleriListeleParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gidenBelgeleriListeleParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListele, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListele = class(gidenBelgeleriListele2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListeleParametreleri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListeleParametreleri = class(TRemotable)
  private
    FbaslangicGonderimTarihi: string;
    FbaslangicGonderimTarihi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbitisGonderimTarihi: string;
    FbitisGonderimTarihi_Specified: boolean;
    Fvkn: string;
    Fvkn_Specified: boolean;
    procedure SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
    function  baslangicGonderimTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbitisGonderimTarihi(Index: Integer; const Astring: string);
    function  bitisGonderimTarihi_Specified(Index: Integer): boolean;
    procedure Setvkn(Index: Integer; const Astring: string);
    function  vkn_Specified(Index: Integer): boolean;
  published
    property baslangicGonderimTarihi: string  Index (IS_OPTN) read FbaslangicGonderimTarihi write SetbaslangicGonderimTarihi stored baslangicGonderimTarihi_Specified;
    property belgeTuru:               string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property bitisGonderimTarihi:     string  Index (IS_OPTN) read FbitisGonderimTarihi write SetbitisGonderimTarihi stored bitisGonderimTarihi_Specified;
    property vkn:                     string  Index (IS_OPTN) read Fvkn write Setvkn stored vkn_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriIndirExtResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndirExtResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriIndirExtResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndirExtResponse = class(gelenBelgeleriIndirExtResponse2)
  private
  published
  end;

  irsaliyeTarihcesiSorgulaResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  irsaliyeTarihcesiSorgulaResponse = irsaliyeTarihcesiSorgulaResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gelenBelgeleriIndirExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndirExt2 = class(TRemotable)
  private
    Fparametreler: gelenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gelenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriIndirExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndirExt = class(gelenBelgeleriIndirExt2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListelePortal, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListelePortal2 = class(TRemotable)
  private
    Fparametreler: gidenBelgeleriListelePortalParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgidenBelgeleriListelePortalParametreleri: gidenBelgeleriListelePortalParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gidenBelgeleriListelePortalParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListelePortal, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListelePortal = class(gidenBelgeleriListelePortal2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriListelePortalParametreleri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriListelePortalParametreleri = class(TRemotable)
  private
    FbaslangicGonderimTarihi: string;
    FbaslangicGonderimTarihi_Specified: boolean;
    FbelgeEttnListesi: efaturaKullaniciListesi2;
    FbelgeEttnListesi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    FbitisGonderimTarihi: string;
    FbitisGonderimTarihi_Specified: boolean;
    FfaturaBaslangicTarihi: string;
    FfaturaBaslangicTarihi_Specified: boolean;
    FfaturaBitisTarihi: string;
    FfaturaBitisTarihi_Specified: boolean;
    Fkaynak: string;
    Fkaynak_Specified: boolean;
    FpageCount: string;
    FpageCount_Specified: boolean;
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
    function  baslangicGonderimTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  belgeEttnListesi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
    procedure SetbitisGonderimTarihi(Index: Integer; const Astring: string);
    function  bitisGonderimTarihi_Specified(Index: Integer): boolean;
    procedure SetfaturaBaslangicTarihi(Index: Integer; const Astring: string);
    function  faturaBaslangicTarihi_Specified(Index: Integer): boolean;
    procedure SetfaturaBitisTarihi(Index: Integer; const Astring: string);
    function  faturaBitisTarihi_Specified(Index: Integer): boolean;
    procedure Setkaynak(Index: Integer; const Astring: string);
    function  kaynak_Specified(Index: Integer): boolean;
    procedure SetpageCount(Index: Integer; const Astring: string);
    function  pageCount_Specified(Index: Integer): boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property baslangicGonderimTarihi: string                    Index (IS_OPTN) read FbaslangicGonderimTarihi write SetbaslangicGonderimTarihi stored baslangicGonderimTarihi_Specified;
    property belgeEttnListesi:        efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FbelgeEttnListesi write SetbelgeEttnListesi stored belgeEttnListesi_Specified;
    property belgeTuru:               string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeVersiyon:           string                    Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
    property bitisGonderimTarihi:     string                    Index (IS_OPTN) read FbitisGonderimTarihi write SetbitisGonderimTarihi stored bitisGonderimTarihi_Specified;
    property faturaBaslangicTarihi:   string                    Index (IS_OPTN) read FfaturaBaslangicTarihi write SetfaturaBaslangicTarihi stored faturaBaslangicTarihi_Specified;
    property faturaBitisTarihi:       string                    Index (IS_OPTN) read FfaturaBitisTarihi write SetfaturaBitisTarihi stored faturaBitisTarihi_Specified;
    property kaynak:                  string                    Index (IS_OPTN) read Fkaynak write Setkaynak stored kaynak_Specified;
    property pageCount:               string                    Index (IS_OPTN) read FpageCount write SetpageCount stored pageCount_Specified;
    property vergiTcKimlikNo:         string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenFaturalariArsiveKaldirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenFaturalariArsiveKaldirResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenFaturalariArsiveKaldirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenFaturalariArsiveKaldirResponse = class(gelenFaturalariArsiveKaldirResponse2)
  private
  published
  end;

  gidenBelgeleriListeleResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriListeleResponse = gidenBelgeleriListeleResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gelenFaturalariArsiveKaldir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenFaturalariArsiveKaldir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FinvoiceEttnListesi: efaturaKullaniciListesi2;
    FinvoiceEttnListesi_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetinvoiceEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  invoiceEttnListesi_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:    string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property invoiceEttnListesi: efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FinvoiceEttnListesi write SetinvoiceEttnListesi stored invoiceEttnListesi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenFaturalariArsiveKaldir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenFaturalariArsiveKaldir = class(gelenFaturalariArsiveKaldir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : irsaliyeTarihcesiSorgula, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  irsaliyeTarihcesiSorgula2 = class(TRemotable)
  private
    Fettn: string;
    Fettn_Specified: boolean;
    FirasliyeYonu: string;
    FirasliyeYonu_Specified: boolean;
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetirasliyeYonu(Index: Integer; const Astring: string);
    function  irasliyeYonu_Specified(Index: Integer): boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
  published
    property ettn:         string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property irasliyeYonu: string  Index (IS_OPTN) read FirasliyeYonu write SetirasliyeYonu stored irasliyeYonu_Specified;
    property vknTckn:      string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
  end;



  // ************************************************************************ //
  // XML       : irsaliyeTarihcesiSorgula, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  irsaliyeTarihcesiSorgula = class(irsaliyeTarihcesiSorgula2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaNoUretResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaNoUretResponse2 = class(TRemotable)
  private
    Freturn: string;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const Astring: string);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: string  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaNoUretResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaNoUretResponse = class(faturaNoUretResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaEttn, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaEttn2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettn:            string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaEttn, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaEttn = class(gidenBelgeDurumSorgulaEttn2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaNoUret, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaNoUret2 = class(TRemotable)
  private
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    FfaturaKodu: string;
    FfaturaKodu_Specified: boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
    procedure SetfaturaKodu(Index: Integer; const Astring: string);
    function  faturaKodu_Specified(Index: Integer): boolean;
  published
    property vknTckn:    string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
    property faturaKodu: string  Index (IS_OPTN) read FfaturaKodu write SetfaturaKodu stored faturaKodu_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaNoUret, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaNoUret = class(faturaNoUret2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgelerAlindiEntegrasyonSiparisNoGuncelle, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindiEntegrasyonSiparisNoGuncelle2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettn: efaturaKullaniciListesi2;
    Fettn_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FentegrasyonHedefi: string;
    FentegrasyonHedefi_Specified: boolean;
    FguncellenmisSiparisNumarasi: string;
    FguncellenmisSiparisNumarasi_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetentegrasyonHedefi(Index: Integer; const Astring: string);
    function  entegrasyonHedefi_Specified(Index: Integer): boolean;
    procedure SetguncellenmisSiparisNumarasi(Index: Integer; const Astring: string);
    function  guncellenmisSiparisNumarasi_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:             string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettn:                        efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettn write Setettn stored ettn_Specified;
    property belgeTuru:                   string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property entegrasyonHedefi:           string                    Index (IS_OPTN) read FentegrasyonHedefi write SetentegrasyonHedefi stored entegrasyonHedefi_Specified;
    property guncellenmisSiparisNumarasi: string                    Index (IS_OPTN) read FguncellenmisSiparisNumarasi write SetguncellenmisSiparisNumarasi stored guncellenmisSiparisNumarasi_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgelerAlindiEntegrasyonSiparisNoGuncelle, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindiEntegrasyonSiparisNoGuncelle = class(belgelerAlindiEntegrasyonSiparisNoGuncelle2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgelerAlindiEntegrasyonSiparisNoGuncelleResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindiEntegrasyonSiparisNoGuncelleResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgelerAlindiEntegrasyonSiparisNoGuncelleResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgelerAlindiEntegrasyonSiparisNoGuncelleResponse = class(belgelerAlindiEntegrasyonSiparisNoGuncelleResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : temelKontrollerIleBelgeGonder, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  temelKontrollerIleBelgeGonder2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    Fveri: TByteDynArray;
    Fveri_Specified: boolean;
    FbelgeHash: string;
    FbelgeHash_Specified: boolean;
    FmimeType: string;
    FmimeType_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  veri_Specified(Index: Integer): boolean;
    procedure SetbelgeHash(Index: Integer; const Astring: string);
    function  belgeHash_Specified(Index: Integer): boolean;
    procedure SetmimeType(Index: Integer; const Astring: string);
    function  mimeType_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string         Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeNo:         string         Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property veri:            TByteDynArray  Index (IS_OPTN) read Fveri write Setveri stored veri_Specified;
    property belgeHash:       string         Index (IS_OPTN) read FbelgeHash write SetbelgeHash stored belgeHash_Specified;
    property mimeType:        string         Index (IS_OPTN) read FmimeType write SetmimeType stored mimeType_Specified;
    property belgeVersiyon:   string         Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
  end;



  // ************************************************************************ //
  // XML       : temelKontrollerIleBelgeGonder, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  temelKontrollerIleBelgeGonder = class(temelKontrollerIleBelgeGonder2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : temelKontrollerIleBelgeGonderResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  temelKontrollerIleBelgeGonderResponse2 = class(TRemotable)
  private
    FbelgeOid: string;
    FbelgeOid_Specified: boolean;
    procedure SetbelgeOid(Index: Integer; const Astring: string);
    function  belgeOid_Specified(Index: Integer): boolean;
  published
    property belgeOid: string  Index (IS_OPTN) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
  end;



  // ************************************************************************ //
  // XML       : temelKontrollerIleBelgeGonderResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  temelKontrollerIleBelgeGonderResponse = class(temelKontrollerIleBelgeGonderResponse2)
  private
  published
  end;

  gelenBelgeleriListeleExtResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriListeleExtResponse = gelenBelgeleriListeleExtResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaEttnResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaEttnResponse2 = class(TRemotable)
  private
    Freturn: gidenBelgeDurum;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: gidenBelgeDurum  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaEttnResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaEttnResponse = class(gidenBelgeDurumSorgulaEttnResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriListeleExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriListeleExt2 = class(TRemotable)
  private
    Fparametreler: gelenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gelenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriListeleExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriListeleExt = class(gelenBelgeleriListeleExt2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaBelgeNo, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaBelgeNo2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    Furun: string;
    Furun_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure Seturun(Index: Integer; const Astring: string);
    function  urun_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeNo:         string  Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property urun:            string  Index (IS_OPTN) read Furun write Seturun stored urun_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaBelgeNo, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaBelgeNo = class(gidenBelgeDurumSorgulaBelgeNo2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaBelgeNoResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaBelgeNoResponse2 = class(TRemotable)
  private
    Freturn: gidenBelgeDurum;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: gidenBelgeDurum  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaBelgeNoResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaBelgeNoResponse = class(gidenBelgeDurumSorgulaBelgeNoResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriIndirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndirResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriIndirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndirResponse = class(gelenBelgeleriIndirResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ublOnizlemeResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  ublOnizlemeResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : ublOnizlemeResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  ublOnizlemeResponse = class(ublOnizlemeResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriIndir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettnler: efaturaKullaniciListesi2;
    Fettnler_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettnler_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettnler:         efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettnler write Setettnler stored ettnler_Specified;
    property belgeTuru:       string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeFormati:    string                    Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriIndir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriIndir = class(gelenBelgeleriIndir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenTamamlananRapolariAlResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTamamlananRapolariAlResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenTamamlananRapolariAlResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTamamlananRapolariAlResponse = class(gelenTamamlananRapolariAlResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderYerelBelgeNo, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderYerelBelgeNo2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FyerelBelgeNo: efaturaKullaniciListesi2;
    FyerelBelgeNo_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FalanEtiket: string;
    FalanEtiket_Specified: boolean;
    FgonderenEtiket: string;
    FgonderenEtiket_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetyerelBelgeNo(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  yerelBelgeNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetalanEtiket(Index: Integer; const Astring: string);
    function  alanEtiket_Specified(Index: Integer): boolean;
    procedure SetgonderenEtiket(Index: Integer; const Astring: string);
    function  gonderenEtiket_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property yerelBelgeNo:    efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FyerelBelgeNo write SetyerelBelgeNo stored yerelBelgeNo_Specified;
    property belgeTuru:       string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property alanEtiket:      string                    Index (IS_OPTN) read FalanEtiket write SetalanEtiket stored alanEtiket_Specified;
    property gonderenEtiket:  string                    Index (IS_OPTN) read FgonderenEtiket write SetgonderenEtiket stored gonderenEtiket_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderYerelBelgeNo, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderYerelBelgeNo = class(belgeleriTekrarGonderYerelBelgeNo2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenTamamlananRapolariAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTamamlananRapolariAl2 = class(TRemotable)
  private
    FgonderenVknTckn: string;
    FgonderenVknTckn_Specified: boolean;
    FaliciVknTckn: string;
    FaliciVknTckn_Specified: boolean;
    FgelisBasTarihi: string;
    FgelisBasTarihi_Specified: boolean;
    FgelisBitTarihi: string;
    FgelisBitTarihi_Specified: boolean;
    procedure SetgonderenVknTckn(Index: Integer; const Astring: string);
    function  gonderenVknTckn_Specified(Index: Integer): boolean;
    procedure SetaliciVknTckn(Index: Integer; const Astring: string);
    function  aliciVknTckn_Specified(Index: Integer): boolean;
    procedure SetgelisBasTarihi(Index: Integer; const Astring: string);
    function  gelisBasTarihi_Specified(Index: Integer): boolean;
    procedure SetgelisBitTarihi(Index: Integer; const Astring: string);
    function  gelisBitTarihi_Specified(Index: Integer): boolean;
  published
    property gonderenVknTckn: string  Index (IS_OPTN) read FgonderenVknTckn write SetgonderenVknTckn stored gonderenVknTckn_Specified;
    property aliciVknTckn:    string  Index (IS_OPTN) read FaliciVknTckn write SetaliciVknTckn stored aliciVknTckn_Specified;
    property gelisBasTarihi:  string  Index (IS_OPTN) read FgelisBasTarihi write SetgelisBasTarihi stored gelisBasTarihi_Specified;
    property gelisBitTarihi:  string  Index (IS_OPTN) read FgelisBitTarihi write SetgelisBitTarihi stored gelisBitTarihi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenTamamlananRapolariAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenTamamlananRapolariAl = class(gelenTamamlananRapolariAl2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderBelgeOid, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderBelgeOid2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeOid: efaturaKullaniciListesi2;
    FbelgeOid_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FalanEtiket: string;
    FalanEtiket_Specified: boolean;
    FgonderenEtiket: string;
    FgonderenEtiket_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeOid(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  belgeOid_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetalanEtiket(Index: Integer; const Astring: string);
    function  alanEtiket_Specified(Index: Integer): boolean;
    procedure SetgonderenEtiket(Index: Integer; const Astring: string);
    function  gonderenEtiket_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeOid:        efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
    property belgeTuru:       string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property alanEtiket:      string                    Index (IS_OPTN) read FalanEtiket write SetalanEtiket stored alanEtiket_Specified;
    property gonderenEtiket:  string                    Index (IS_OPTN) read FgonderenEtiket write SetgonderenEtiket stored gonderenEtiket_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderBelgeOid, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderBelgeOid = class(belgeleriTekrarGonderBelgeOid2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderBelgeOidResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderBelgeOidResponse2 = class(TRemotable)
  private
    Freturn: Boolean;
  published
    property return: Boolean  read Freturn write Freturn;
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderBelgeOidResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderBelgeOidResponse = class(belgeleriTekrarGonderBelgeOidResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ublOnizleme, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  ublOnizleme2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fveri: TByteDynArray;
    Fveri_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  veri_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string         Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property veri:            TByteDynArray  Index (IS_OPTN) read Fveri write Setveri stored veri_Specified;
    property belgeFormati:    string         Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
    property belgeTuru:       string         Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : ublOnizleme, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  ublOnizleme = class(ublOnizleme2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeXmlleriniAl, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeXmlleriniAl2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettnler: efaturaKullaniciListesi2;
    Fettnler_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettnler_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettnler:         efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettnler write Setettnler stored ettnler_Specified;
    property belgeTuru:       string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeXmlleriniAl, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeXmlleriniAl = class(gelenBelgeXmlleriniAl2)
  private
  published
  end;

  gelenBelgeXmlleriniAlResponse2 = array of string;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeXmlleriniAlResponse = gelenBelgeXmlleriniAlResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : belgeGonderExtWithValidateResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExtWithValidateResponse2 = class(TRemotable)
  private
    Freturn: belgeGonderResp;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AbelgeGonderResp: belgeGonderResp);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: belgeGonderResp  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonderExtWithValidateResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExtWithValidateResponse = class(belgeGonderExtWithValidateResponse2)
  private
  published
  end;

  gidenBelgeleriListelePortalResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeleriListelePortalResponse = gidenBelgeleriListelePortalResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : belgeGonderExtWithValidate, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExtWithValidate2 = class(TRemotable)
  private
    Fparametreler: gidenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgidenBelgeParametreleri: gidenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gidenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonderExtWithValidate, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderExtWithValidate = class(belgeGonderExtWithValidate2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : eIrsaliyeKayitliKullaniciListele, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eIrsaliyeKayitliKullaniciListele2 = class(TRemotable)
  private
    FkayitZamani: string;
    FkayitZamani_Specified: boolean;
    procedure SetkayitZamani(Index: Integer; const Astring: string);
    function  kayitZamani_Specified(Index: Integer): boolean;
  published
    property kayitZamani: string  Index (IS_OPTN) read FkayitZamani write SetkayitZamani stored kayitZamani_Specified;
  end;



  // ************************************************************************ //
  // XML       : eIrsaliyeKayitliKullaniciListele, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  eIrsaliyeKayitliKullaniciListele = class(eIrsaliyeKayitliKullaniciListele2)
  private
  published
  end;

  eIrsaliyeKayitliKullaniciListeleResponse2 = array of eIrsaliyeKullanici;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  eIrsaliyeKayitliKullaniciListeleResponse = eIrsaliyeKayitliKullaniciListeleResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : wsKullaniciBilgileri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  wsKullaniciBilgileri = class(TRemotable)
  private
    FkullaniciKodu: string;
    FkullaniciKodu_Specified: boolean;
    Fsifre: string;
    Fsifre_Specified: boolean;
    procedure SetkullaniciKodu(Index: Integer; const Astring: string);
    function  kullaniciKodu_Specified(Index: Integer): boolean;
    procedure Setsifre(Index: Integer; const Astring: string);
    function  sifre_Specified(Index: Integer): boolean;
  published
    property kullaniciKodu: string  Index (IS_OPTN) read FkullaniciKodu write SetkullaniciKodu stored kullaniciKodu_Specified;
    property sifre:         string  Index (IS_OPTN) read Fsifre write Setsifre stored sifre_Specified;
  end;



  // ************************************************************************ //
  // XML       : wsKullanicisiKaydet, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  wsKullanicisiKaydet2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FurunList: efaturaKullaniciListesi2;
    FurunList_Specified: boolean;
    FerpKodu: string;
    FerpKodu_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SeturunList(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  urunList_Specified(Index: Integer): boolean;
    procedure SeterpKodu(Index: Integer; const Astring: string);
    function  erpKodu_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property urunList:        efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FurunList write SeturunList stored urunList_Specified;
    property erpKodu:         string                    Index (IS_OPTN) read FerpKodu write SeterpKodu stored erpKodu_Specified;
  end;



  // ************************************************************************ //
  // XML       : wsKullanicisiKaydet, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  wsKullanicisiKaydet = class(wsKullanicisiKaydet2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : wsKullanicisiKaydetResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  wsKullanicisiKaydetResponse2 = class(TRemotable)
  private
    Freturn: wsKullaniciBilgileri;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AwsKullaniciBilgileri: wsKullaniciBilgileri);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: wsKullaniciBilgileri  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : wsKullanicisiKaydetResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  wsKullanicisiKaydetResponse = class(wsKullanicisiKaydetResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedVknTcknResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedVknTcknResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedVknTcknResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedVknTcknResponse = class(kayitliKullaniciListeleExtendedVknTcknResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedVknTckn, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedVknTckn2 = class(TRemotable)
  private
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    Furun: string;
    Furun_Specified: boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
    procedure Seturun(Index: Integer; const Astring: string);
    function  urun_Specified(Index: Integer): boolean;
  published
    property vknTckn: string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
    property urun:    string  Index (IS_OPTN) read Furun write Seturun stored urun_Specified;
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedVknTckn, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedVknTckn = class(kayitliKullaniciListeleExtendedVknTckn2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : yolcuBeraberFaturaIptalEt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yolcuBeraberFaturaIptalEt2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    FseriSiraNo: string;
    FseriSiraNo_Specified: boolean;
    FpusulaTarihi: string;
    FpusulaTarihi_Specified: boolean;
    FbelgeOid: string;
    FbelgeOid_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetseriSiraNo(Index: Integer; const Astring: string);
    function  seriSiraNo_Specified(Index: Integer): boolean;
    procedure SetpusulaTarihi(Index: Integer; const Astring: string);
    function  pusulaTarihi_Specified(Index: Integer): boolean;
    procedure SetbelgeOid(Index: Integer; const Astring: string);
    function  belgeOid_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettn:            string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property seriSiraNo:      string  Index (IS_OPTN) read FseriSiraNo write SetseriSiraNo stored seriSiraNo_Specified;
    property pusulaTarihi:    string  Index (IS_OPTN) read FpusulaTarihi write SetpusulaTarihi stored pusulaTarihi_Specified;
    property belgeOid:        string  Index (IS_OPTN) read FbelgeOid write SetbelgeOid stored belgeOid_Specified;
  end;



  // ************************************************************************ //
  // XML       : yolcuBeraberFaturaIptalEt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yolcuBeraberFaturaIptalEt = class(yolcuBeraberFaturaIptalEt2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : yolcuBeraberFaturaIptalEtResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yolcuBeraberFaturaIptalEtResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : yolcuBeraberFaturaIptalEtResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  yolcuBeraberFaturaIptalEtResponse = class(yolcuBeraberFaturaIptalEtResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonder, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonder2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettn: efaturaKullaniciListesi2;
    Fettn_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FalanEtiket: string;
    FalanEtiket_Specified: boolean;
    FgonderenEtiket: string;
    FgonderenEtiket_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetalanEtiket(Index: Integer; const Astring: string);
    function  alanEtiket_Specified(Index: Integer): boolean;
    procedure SetgonderenEtiket(Index: Integer; const Astring: string);
    function  gonderenEtiket_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettn:            efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettn write Setettn stored ettn_Specified;
    property belgeTuru:       string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property alanEtiket:      string                    Index (IS_OPTN) read FalanEtiket write SetalanEtiket stored alanEtiket_Specified;
    property gonderenEtiket:  string                    Index (IS_OPTN) read FgonderenEtiket write SetgonderenEtiket stored gonderenEtiket_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonder, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonder = class(belgeleriTekrarGonder2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderResponse2 = class(TRemotable)
  private
    Freturn: Boolean;
  published
    property return: Boolean  read Freturn write Freturn;
  end;



  // ************************************************************************ //
  // XML       : belgeleriTekrarGonderResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeleriTekrarGonderResponse = class(belgeleriTekrarGonderResponse2)
  private
  published
  end;

  gelenBelgeleriAlExt2Response2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gelenBelgeleriAlExt2Response = gelenBelgeleriAlExt2Response2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }
  parametreler = array of entry2;               { "http://service.connector.uut.cs.com.tr/"[Cplx] }


  // ************************************************************************ //
  // XML       : gelenBelgeleriAlExt2, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriAlExt22 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    Fparametreler: parametreler;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property vergiTcKimlikNo: string        Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeTuru:       string        Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property parametreler:    parametreler  read Fparametreler write Fparametreler;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeleriAlExt2, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeleriAlExt2 = class(gelenBelgeleriAlExt22)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : entry, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  entry2 = class(TRemotable)
  private
    Fkey: string;
    Fkey_Specified: boolean;
    Fvalue: string;
    Fvalue_Specified: boolean;
    procedure Setkey(Index: Integer; const Astring: string);
    function  key_Specified(Index: Integer): boolean;
    procedure Setvalue(Index: Integer; const Astring: string);
    function  value_Specified(Index: Integer): boolean;
  published
    property key:   string  Index (IS_OPTN) read Fkey write Setkey stored key_Specified;
    property value: string  Index (IS_OPTN) read Fvalue write Setvalue stored value_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaMailGonderResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaMailGonderResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaMailGonderResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaMailGonderResponse = class(faturaMailGonderResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : kalanKontorBilgisi, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kalanKontorBilgisi = class(TRemotable)
  private
    Fkalan: TXSDecimal;
    Fkalan_Specified: boolean;
    FkontorBirimi: kontorBirimi;
    FkontorBirimi_Specified: boolean;
    FkontorTipi: kontorTipi;
    FkontorTipi_Specified: boolean;
    FlimitAsimMiktari: TXSDecimal;
    FlimitAsimMiktari_Specified: boolean;
    FtoplamAlinan: TXSDecimal;
    FtoplamAlinan_Specified: boolean;
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    procedure Setkalan(Index: Integer; const ATXSDecimal: TXSDecimal);
    function  kalan_Specified(Index: Integer): boolean;
    procedure SetkontorBirimi(Index: Integer; const AkontorBirimi: kontorBirimi);
    function  kontorBirimi_Specified(Index: Integer): boolean;
    procedure SetkontorTipi(Index: Integer; const AkontorTipi: kontorTipi);
    function  kontorTipi_Specified(Index: Integer): boolean;
    procedure SetlimitAsimMiktari(Index: Integer; const ATXSDecimal: TXSDecimal);
    function  limitAsimMiktari_Specified(Index: Integer): boolean;
    procedure SettoplamAlinan(Index: Integer; const ATXSDecimal: TXSDecimal);
    function  toplamAlinan_Specified(Index: Integer): boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property kalan:            TXSDecimal    Index (IS_OPTN) read Fkalan write Setkalan stored kalan_Specified;
    property kontorBirimi:     kontorBirimi  Index (IS_OPTN) read FkontorBirimi write SetkontorBirimi stored kontorBirimi_Specified;
    property kontorTipi:       kontorTipi    Index (IS_OPTN) read FkontorTipi write SetkontorTipi stored kontorTipi_Specified;
    property limitAsimMiktari: TXSDecimal    Index (IS_OPTN) read FlimitAsimMiktari write SetlimitAsimMiktari stored limitAsimMiktari_Specified;
    property toplamAlinan:     TXSDecimal    Index (IS_OPTN) read FtoplamAlinan write SettoplamAlinan stored toplamAlinan_Specified;
    property vknTckn:          string        Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
  end;



  // ************************************************************************ //
  // XML       : kontorBilgisiGetir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kontorBilgisiGetir2 = class(TRemotable)
  private
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    FkontorTipi: string;
    FkontorTipi_Specified: boolean;
    FkontorBirimi: string;
    FkontorBirimi_Specified: boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
    procedure SetkontorTipi(Index: Integer; const Astring: string);
    function  kontorTipi_Specified(Index: Integer): boolean;
    procedure SetkontorBirimi(Index: Integer; const Astring: string);
    function  kontorBirimi_Specified(Index: Integer): boolean;
  published
    property vknTckn:      string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
    property kontorTipi:   string  Index (IS_OPTN) read FkontorTipi write SetkontorTipi stored kontorTipi_Specified;
    property kontorBirimi: string  Index (IS_OPTN) read FkontorBirimi write SetkontorBirimi stored kontorBirimi_Specified;
  end;



  // ************************************************************************ //
  // XML       : kontorBilgisiGetir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kontorBilgisiGetir = class(kontorBilgisiGetir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : kontorBilgisiGetirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kontorBilgisiGetirResponse2 = class(TRemotable)
  private
    Freturn: kalanKontorBilgisi;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AkalanKontorBilgisi: kalanKontorBilgisi);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: kalanKontorBilgisi  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : kontorBilgisiGetirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kontorBilgisiGetirResponse = class(kontorBilgisiGetirResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgulaResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgulaResponse2 = class(TRemotable)
  private
    Freturn: serviceReturnType2;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AserviceReturnType2: serviceReturnType2);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: serviceReturnType2  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgulaResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgulaResponse = class(gelenBelgeDurumSorgulaResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : faturaMailGonder, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaMailGonder2 = class(TRemotable)
  private
    FvknTckn: string;
    FvknTckn_Specified: boolean;
    FinOut: string;
    FinOut_Specified: boolean;
    FUUID: string;
    FUUID_Specified: boolean;
    FfaturaNo: string;
    FfaturaNo_Specified: boolean;
    Falicilar: string;
    Falicilar_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    procedure SetvknTckn(Index: Integer; const Astring: string);
    function  vknTckn_Specified(Index: Integer): boolean;
    procedure SetinOut(Index: Integer; const Astring: string);
    function  inOut_Specified(Index: Integer): boolean;
    procedure SetUUID(Index: Integer; const Astring: string);
    function  UUID_Specified(Index: Integer): boolean;
    procedure SetfaturaNo(Index: Integer; const Astring: string);
    function  faturaNo_Specified(Index: Integer): boolean;
    procedure Setalicilar(Index: Integer; const Astring: string);
    function  alicilar_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
  published
    property vknTckn:      string  Index (IS_OPTN) read FvknTckn write SetvknTckn stored vknTckn_Specified;
    property inOut:        string  Index (IS_OPTN) read FinOut write SetinOut stored inOut_Specified;
    property UUID:         string  Index (IS_OPTN) read FUUID write SetUUID stored UUID_Specified;
    property faturaNo:     string  Index (IS_OPTN) read FfaturaNo write SetfaturaNo stored faturaNo_Specified;
    property alicilar:     string  Index (IS_OPTN) read Falicilar write Setalicilar stored alicilar_Specified;
    property belgeFormati: string  Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
  end;



  // ************************************************************************ //
  // XML       : faturaMailGonder, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  faturaMailGonder = class(faturaMailGonder2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgula, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgula2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettn: string;
    Fettn_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettn(Index: Integer; const Astring: string);
    function  ettn_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettn:            string  Index (IS_OPTN) read Fettn write Setettn stored ettn_Specified;
    property belgeTuru:       string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeDurumSorgula, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeDurumSorgula = class(gelenBelgeDurumSorgula2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeOidListesi: efaturaKullaniciListesi2;
    FbelgeOidListesi_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeOidListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  belgeOidListesi_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeOidListesi: efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FbelgeOidListesi write SetbelgeOidListesi stored belgeOidListesi_Specified;
    property belgeTuru:       string                    Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeFormati:    string                    Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndir = class(gidenBelgeleriIndir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeleriIndirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeleriIndirResponse = class(gidenBelgeleriIndirResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaYerelBelgeNoResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaYerelBelgeNoResponse2 = class(TRemotable)
  private
    Freturn: gidenBelgeDurum;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: gidenBelgeDurum  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaYerelBelgeNoResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaYerelBelgeNoResponse = class(gidenBelgeDurumSorgulaYerelBelgeNoResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeTutarBilgileriSorgula, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeTutarBilgileriSorgula2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbaslangicGonderimTarihi: string;
    FbaslangicGonderimTarihi_Specified: boolean;
    FbitisGonderimTarihi: string;
    FbitisGonderimTarihi_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
    function  baslangicGonderimTarihi_Specified(Index: Integer): boolean;
    procedure SetbitisGonderimTarihi(Index: Integer; const Astring: string);
    function  bitisGonderimTarihi_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:         string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeTuru:               string  Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property baslangicGonderimTarihi: string  Index (IS_OPTN) read FbaslangicGonderimTarihi write SetbaslangicGonderimTarihi stored baslangicGonderimTarihi_Specified;
    property bitisGonderimTarihi:     string  Index (IS_OPTN) read FbitisGonderimTarihi write SetbitisGonderimTarihi stored bitisGonderimTarihi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeTutarBilgileriSorgula, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeTutarBilgileriSorgula = class(gidenBelgeTutarBilgileriSorgula2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaYerelBelgeNo, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaYerelBelgeNo2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FyerelBelgeNo: string;
    FyerelBelgeNo_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetyerelBelgeNo(Index: Integer; const Astring: string);
    function  yerelBelgeNo_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property yerelBelgeNo:    string  Index (IS_OPTN) read FyerelBelgeNo write SetyerelBelgeNo stored yerelBelgeNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenBelgeDurumSorgulaYerelBelgeNo, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenBelgeDurumSorgulaYerelBelgeNo = class(gidenBelgeDurumSorgulaYerelBelgeNo2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeXmlleriniAlExt, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeXmlleriniAlExt2 = class(TRemotable)
  private
    Fparametreler: gelenBelgeParametreleri;
    Fparametreler_Specified: boolean;
    procedure Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
    function  parametreler_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property parametreler: gelenBelgeParametreleri  Index (IS_OPTN) read Fparametreler write Setparametreler stored parametreler_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeXmlleriniAlExt, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeXmlleriniAlExt = class(gelenBelgeXmlleriniAlExt2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeXmlleriniAlExtResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeXmlleriniAlExtResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenBelgeXmlleriniAlExtResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenBelgeXmlleriniAlExtResponse = class(gelenBelgeXmlleriniAlExtResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenFaturalariArsiveKaldir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenFaturalariArsiveKaldir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FinvoiceEttnListesi: efaturaKullaniciListesi2;
    FinvoiceEttnListesi_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetinvoiceEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  invoiceEttnListesi_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:    string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property invoiceEttnListesi: efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FinvoiceEttnListesi write SetinvoiceEttnListesi stored invoiceEttnListesi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenFaturalariArsiveKaldir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenFaturalariArsiveKaldir = class(gidenFaturalariArsiveKaldir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenFaturalariArsiveKaldirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenFaturalariArsiveKaldirResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenFaturalariArsiveKaldirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenFaturalariArsiveKaldirResponse = class(gidenFaturalariArsiveKaldirResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gidenTasinanBelgeleriIndirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenTasinanBelgeleriIndirResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenTasinanBelgeleriIndirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenTasinanBelgeleriIndirResponse = class(gidenTasinanBelgeleriIndirResponse2)
  private
  published
  end;

  gidenBelgeTutarBilgileriSorgulaResponse2 = array of serviceReturnType2;   { "http://service.connector.uut.cs.com.tr/"[GblCplx] }
  gidenBelgeTutarBilgileriSorgulaResponse = gidenBelgeTutarBilgileriSorgulaResponse2;      { "http://service.connector.uut.cs.com.tr/"[GblElm] }


  // ************************************************************************ //
  // XML       : gidenTasinanBelgeleriIndir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenTasinanBelgeleriIndir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    Fettnler: efaturaKullaniciListesi2;
    Fettnler_Specified: boolean;
    FbelgeFormati: string;
    FbelgeFormati_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  ettnler_Specified(Index: Integer): boolean;
    procedure SetbelgeFormati(Index: Integer; const Astring: string);
    function  belgeFormati_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property ettnler:         efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read Fettnler write Setettnler stored ettnler_Specified;
    property belgeFormati:    string                    Index (IS_OPTN) read FbelgeFormati write SetbelgeFormati stored belgeFormati_Specified;
  end;



  // ************************************************************************ //
  // XML       : gidenTasinanBelgeleriIndir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gidenTasinanBelgeleriIndir = class(gidenTasinanBelgeleriIndir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedResponse2 = class(TRemotable)
  private
    Freturn: TByteDynArray;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  return_Specified(Index: Integer): boolean;
  published
    property return: TByteDynArray  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtendedResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtendedResponse = class(kayitliKullaniciListeleExtendedResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenIrsaliyeleriArsiveKaldir, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenIrsaliyeleriArsiveKaldir2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FdespatchEttnListesi: efaturaKullaniciListesi2;
    FdespatchEttnListesi_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetdespatchEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
    function  despatchEttnListesi_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo:     string                    Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property despatchEttnListesi: efaturaKullaniciListesi2  Index (IS_OPTN or IS_UNBD) read FdespatchEttnListesi write SetdespatchEttnListesi stored despatchEttnListesi_Specified;
  end;



  // ************************************************************************ //
  // XML       : gelenIrsaliyeleriArsiveKaldir, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenIrsaliyeleriArsiveKaldir = class(gelenIrsaliyeleriArsiveKaldir2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenIrsaliyeleriArsiveKaldirResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenIrsaliyeleriArsiveKaldirResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : gelenIrsaliyeleriArsiveKaldirResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  gelenIrsaliyeleriArsiveKaldirResponse = class(gelenIrsaliyeleriArsiveKaldirResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : erpBilgileriBelirleResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  erpBilgileriBelirleResponse2 = class(TRemotable)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : erpBilgileriBelirleResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  erpBilgileriBelirleResponse = class(erpBilgileriBelirleResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : erpBilgileriBelirle, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  erpBilgileriBelirle2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FerpBilgileri: erpBilgileri;
    FerpBilgileri_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SeterpBilgileri(Index: Integer; const AerpBilgileri: erpBilgileri);
    function  erpBilgileri_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property vergiTcKimlikNo: string        Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property erpBilgileri:    erpBilgileri  Index (IS_OPTN) read FerpBilgileri write SeterpBilgileri stored erpBilgileri_Specified;
  end;



  // ************************************************************************ //
  // XML       : erpBilgileriBelirle, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  erpBilgileriBelirle = class(erpBilgileriBelirle2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : erpBilgileri, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  erpBilgileri = class(TRemotable)
  private
    Faciklama: string;
    Faciklama_Specified: boolean;
    Fkod: string;
    Fkod_Specified: boolean;
    procedure Setaciklama(Index: Integer; const Astring: string);
    function  aciklama_Specified(Index: Integer): boolean;
    procedure Setkod(Index: Integer; const Astring: string);
    function  kod_Specified(Index: Integer): boolean;
  published
    property aciklama: string  Index (IS_OPTN) read Faciklama write Setaciklama stored aciklama_Specified;
    property kod:      string  Index (IS_OPTN) read Fkod write Setkod stored kod_Specified;
  end;



  // ************************************************************************ //
  // XML       : efaturaKullanicisiResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  efaturaKullanicisiResponse2 = class(TRemotable)
  private
    Freturn: Boolean;
  published
    property return: Boolean  read Freturn write Freturn;
  end;



  // ************************************************************************ //
  // XML       : efaturaKullanicisiResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  efaturaKullanicisiResponse = class(efaturaKullanicisiResponse2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtended, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtended2 = class(TRemotable)
  private
    Furun: string;
    Furun_Specified: boolean;
    FgecmisEklensin: Integer;
    FgecmisEklensin_Specified: boolean;
    procedure Seturun(Index: Integer; const Astring: string);
    function  urun_Specified(Index: Integer): boolean;
    procedure SetgecmisEklensin(Index: Integer; const AInteger: Integer);
    function  gecmisEklensin_Specified(Index: Integer): boolean;
  published
    property urun:           string   Index (IS_OPTN) read Furun write Seturun stored urun_Specified;
    property gecmisEklensin: Integer  Index (IS_OPTN) read FgecmisEklensin write SetgecmisEklensin stored gecmisEklensin_Specified;
  end;



  // ************************************************************************ //
  // XML       : kayitliKullaniciListeleExtended, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  kayitliKullaniciListeleExtended = class(kayitliKullaniciListeleExtended2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : efaturaKullanicisi, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  efaturaKullanicisi2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string  Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
  end;



  // ************************************************************************ //
  // XML       : efaturaKullanicisi, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  efaturaKullanicisi = class(efaturaKullanicisi2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeGonderWithValidate, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderWithValidate2 = class(TRemotable)
  private
    FvergiTcKimlikNo: string;
    FvergiTcKimlikNo_Specified: boolean;
    FbelgeTuru: string;
    FbelgeTuru_Specified: boolean;
    FbelgeNo: string;
    FbelgeNo_Specified: boolean;
    Fveri: TByteDynArray;
    Fveri_Specified: boolean;
    FbelgeHash: string;
    FbelgeHash_Specified: boolean;
    FmimeType: string;
    FmimeType_Specified: boolean;
    FbelgeVersiyon: string;
    FbelgeVersiyon_Specified: boolean;
    procedure SetvergiTcKimlikNo(Index: Integer; const Astring: string);
    function  vergiTcKimlikNo_Specified(Index: Integer): boolean;
    procedure SetbelgeTuru(Index: Integer; const Astring: string);
    function  belgeTuru_Specified(Index: Integer): boolean;
    procedure SetbelgeNo(Index: Integer; const Astring: string);
    function  belgeNo_Specified(Index: Integer): boolean;
    procedure Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
    function  veri_Specified(Index: Integer): boolean;
    procedure SetbelgeHash(Index: Integer; const Astring: string);
    function  belgeHash_Specified(Index: Integer): boolean;
    procedure SetmimeType(Index: Integer; const Astring: string);
    function  mimeType_Specified(Index: Integer): boolean;
    procedure SetbelgeVersiyon(Index: Integer; const Astring: string);
    function  belgeVersiyon_Specified(Index: Integer): boolean;
  published
    property vergiTcKimlikNo: string         Index (IS_OPTN) read FvergiTcKimlikNo write SetvergiTcKimlikNo stored vergiTcKimlikNo_Specified;
    property belgeTuru:       string         Index (IS_OPTN) read FbelgeTuru write SetbelgeTuru stored belgeTuru_Specified;
    property belgeNo:         string         Index (IS_OPTN) read FbelgeNo write SetbelgeNo stored belgeNo_Specified;
    property veri:            TByteDynArray  Index (IS_OPTN) read Fveri write Setveri stored veri_Specified;
    property belgeHash:       string         Index (IS_OPTN) read FbelgeHash write SetbelgeHash stored belgeHash_Specified;
    property mimeType:        string         Index (IS_OPTN) read FmimeType write SetmimeType stored mimeType_Specified;
    property belgeVersiyon:   string         Index (IS_OPTN) read FbelgeVersiyon write SetbelgeVersiyon stored belgeVersiyon_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonderWithValidate, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderWithValidate = class(belgeGonderWithValidate2)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : belgeGonderWithValidateResponse, global, <complexType>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderWithValidateResponse2 = class(TRemotable)
  private
    Freturn: belgeGonderResp;
    Freturn_Specified: boolean;
    procedure Setreturn(Index: Integer; const AbelgeGonderResp: belgeGonderResp);
    function  return_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property return: belgeGonderResp  Index (IS_OPTN) read Freturn write Setreturn stored return_Specified;
  end;



  // ************************************************************************ //
  // XML       : belgeGonderWithValidateResponse, global, <element>
  // Namespace : http://service.connector.uut.cs.com.tr/
  // ************************************************************************ //
  belgeGonderWithValidateResponse = class(belgeGonderWithValidateResponse2)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://service.connector.uut.cs.com.tr/
  // style     : ????
  // use       : ????
  // ************************************************************************ //
  ConnectorService = interface(IInvokable)
  ['{4B19B25B-3A18-EFB0-6FEA-DAD427A69DC7}']
    function  belgeGonderExt(const parameters: belgeGonderExt): belgeGonderExtResponse; stdcall;
    function  faturaTarihcesiSorgula(const parameters: faturaTarihcesiSorgula): faturaTarihcesiSorgulaResponse; stdcall;
    function  irsaliyeTarihcesiSorgula(const parameters: irsaliyeTarihcesiSorgula): irsaliyeTarihcesiSorgulaResponse; stdcall;
    function  gelenBelgeEkleriAl(const parameters: gelenBelgeEkleriAl): gelenBelgeEkleriAlResponse; stdcall;
    function  gidenBelgeEkleriAl(const parameters: gidenBelgeEkleriAl): gidenBelgeEkleriAlResponse; stdcall;
    function  kayitliKullaniciListeleExtended(const parameters: kayitliKullaniciListeleExtended): kayitliKullaniciListeleExtendedResponse; stdcall;
    function  gelenBelgeleriIndirExt(const parameters: gelenBelgeleriIndirExt): gelenBelgeleriIndirExtResponse; stdcall;
    function  gelenBelgeleriIndir(const parameters: gelenBelgeleriIndir): gelenBelgeleriIndirResponse; stdcall;
    function  gidenBelgeleriIndirPortal(const parameters: gidenBelgeleriIndirPortal): gidenBelgeleriIndirPortalResponse; stdcall;
    function  gidenBelgeleriIndir(const parameters: gidenBelgeleriIndir): gidenBelgeleriIndirResponse; stdcall;
    function  efaturaKullaniciBilgisi(const parameters: efaturaKullaniciBilgisi): efaturaKullaniciBilgisiResponse; stdcall;
    function  efaturaKullaniciListesi(const parameters: efaturaKullaniciListesi): efaturaKullaniciListesiResponse; stdcall;
    function  belgelerAlindi(const parameters: belgelerAlindi): belgelerAlindiResponse; stdcall;
    function  belgeleriTekrarGonder(const parameters: belgeleriTekrarGonder): belgeleriTekrarGonderResponse; stdcall;
    function  belgeleriTekrarGonderBelgeOid(const parameters: belgeleriTekrarGonderBelgeOid): belgeleriTekrarGonderBelgeOidResponse; stdcall;
    function  kayitliKullaniciListeleExtendedVknTckn(const parameters: kayitliKullaniciListeleExtendedVknTckn): kayitliKullaniciListeleExtendedVknTcknResponse; stdcall;
    function  kayitliKullaniciListeleExtendedTime(const parameters: kayitliKullaniciListeleExtendedTime): kayitliKullaniciListeleExtendedTimeResponse; stdcall;
    function  gidenBelgeleriListele(const parameters: gidenBelgeleriListele): gidenBelgeleriListeleResponse; stdcall;
    function  faturaNoUret(const parameters: faturaNoUret): faturaNoUretResponse; stdcall;
    function  gidenBelgeleriListelePortal(const parameters: gidenBelgeleriListelePortal): gidenBelgeleriListelePortalResponse; stdcall;
    function  cokluGidenBelgeDurumSorgula(const parameters: cokluGidenBelgeDurumSorgula): cokluGidenBelgeDurumSorgulaResponse; stdcall;
    function  gidenBelgeDurumSorgulaExt(const parameters: gidenBelgeDurumSorgulaExt): gidenBelgeDurumSorgulaExtResponse; stdcall;
    function  gidenBelgeDurumSorgula(const parameters: gidenBelgeDurumSorgula): gidenBelgeDurumSorgulaResponse; stdcall;
    function  gidenBelgeDurumSorgulaEttn(const parameters: gidenBelgeDurumSorgulaEttn): gidenBelgeDurumSorgulaEttnResponse; stdcall;
    function  gidenBelgeDurumSorgulaBelgeNo(const parameters: gidenBelgeDurumSorgulaBelgeNo): gidenBelgeDurumSorgulaBelgeNoResponse; stdcall;
    function  gidenBelgeDurumSorgulaYerelBelgeNo(const parameters: gidenBelgeDurumSorgulaYerelBelgeNo): gidenBelgeDurumSorgulaYerelBelgeNoResponse; stdcall;
    function  gelenBelgeDurumSorgulaExt(const parameters: gelenBelgeDurumSorgulaExt): gelenBelgeDurumSorgulaExtResponse; stdcall;
    function  gelenBelgeDurumSorgula(const parameters: gelenBelgeDurumSorgula): gelenBelgeDurumSorgulaResponse; stdcall;
    function  gelenBelgeleriListeleExt(const parameters: gelenBelgeleriListeleExt): gelenBelgeleriListeleExtResponse; stdcall;
    function  gelenBelgeleriListele(const parameters: gelenBelgeleriListele): gelenBelgeleriListeleResponse; stdcall;
    function  yereleAktarilacakBelgeleriAl(const parameters: yereleAktarilacakBelgeleriAl): yereleAktarilacakBelgeleriAlResponse; stdcall;
    function  yereleAktarilacakBelgeleriAlExt(const parameters: yereleAktarilacakBelgeleriAlExt): yereleAktarilacakBelgeleriAlExtResponse; stdcall;
    function  gelenBelgeleriAlExt(const parameters: gelenBelgeleriAlExt): gelenBelgeleriAlExtResponse; stdcall;
    function  gelenBelgeleriAlExt2(const parameters: gelenBelgeleriAlExt2): gelenBelgeleriAlExt2Response; stdcall;
    function  gelenBelgeleriAl(const parameters: gelenBelgeleriAl): gelenBelgeleriAlResponse; stdcall;
    function  belgeGonder(const parameters: belgeGonder): belgeGonderResponse; stdcall;
    function  belgeGonderWithValidate(const parameters: belgeGonderWithValidate): belgeGonderWithValidateResponse; stdcall;
    function  belgeGonderExtWithValidate(const parameters: belgeGonderExtWithValidate): belgeGonderExtWithValidateResponse; stdcall;
    function  efaturaKullanicisi(const parameters: efaturaKullanicisi): efaturaKullanicisiResponse; stdcall;
    function  eFaturaKayitliKullaniciListele(const parameters: eFaturaKayitliKullaniciListele): eFaturaKayitliKullaniciListeleResponse; stdcall;
    function  eIrsaliyeKullanicisi(const parameters: eIrsaliyeKullanicisi): eIrsaliyeKullanicisiResponse; stdcall;
    function  eIrsaliyeKayitliKullaniciListele(const parameters: eIrsaliyeKayitliKullaniciListele): eIrsaliyeKayitliKullaniciListeleResponse; stdcall;
    function  gelenBelgeXmlleriniAl(const parameters: gelenBelgeXmlleriniAl): gelenBelgeXmlleriniAlResponse; stdcall;
    function  gelenBelgeXmlleriniAlExt(const parameters: gelenBelgeXmlleriniAlExt): gelenBelgeXmlleriniAlExtResponse; stdcall;
    function  belgeleriTekrarGonderYerelBelgeNo(const parameters: belgeleriTekrarGonderYerelBelgeNo): belgeleriTekrarGonderYerelBelgeNoResponse; stdcall;
    function  gidenBelgeleriIndirEttn(const parameters: gidenBelgeleriIndirEttn): gidenBelgeleriIndirEttnResponse; stdcall;
    function  gelenFaturalariArsiveKaldir(const parameters: gelenFaturalariArsiveKaldir): gelenFaturalariArsiveKaldirResponse; stdcall;
    function  gidenFaturalariArsiveKaldir(const parameters: gidenFaturalariArsiveKaldir): gidenFaturalariArsiveKaldirResponse; stdcall;
    function  kontorBilgisiGetir(const parameters: kontorBilgisiGetir): kontorBilgisiGetirResponse; stdcall;
    function  temelKontrollerIleBelgeGonder(const parameters: temelKontrollerIleBelgeGonder): temelKontrollerIleBelgeGonderResponse; stdcall;
    function  csXmlOnizleme(const parameters: csXmlOnizleme): csXmlOnizlemeResponse; stdcall;
    function  csXmlToUbl(const parameters: csXmlToUbl): csXmlToUblResponse; stdcall;
    function  ublOnizleme(const parameters: ublOnizleme): ublOnizlemeResponse; stdcall;
    function  erpBilgileriBelirle(const parameters: erpBilgileriBelirle): erpBilgileriBelirleResponse; stdcall;
    function  gelenTasinanBelgeleriIndir(const parameters: gelenTasinanBelgeleriIndir): gelenTasinanBelgeleriIndirResponse; stdcall;
    function  gidenTasinanBelgeleriIndir(const parameters: gidenTasinanBelgeleriIndir): gidenTasinanBelgeleriIndirResponse; stdcall;
    function  gelenIrsaliyeleriArsiveKaldir(const parameters: gelenIrsaliyeleriArsiveKaldir): gelenIrsaliyeleriArsiveKaldirResponse; stdcall;
    function  gidenIrsaliyeleriArsiveKaldir(const parameters: gidenIrsaliyeleriArsiveKaldir): gidenIrsaliyeleriArsiveKaldirResponse; stdcall;
    function  gidenBelgeTutarBilgileriSorgula(const parameters: gidenBelgeTutarBilgileriSorgula): gidenBelgeTutarBilgileriSorgulaResponse; stdcall;
    function  gelenBelgeTutarBilgileriSorgula(const parameters: gelenBelgeTutarBilgileriSorgula): gelenBelgeTutarBilgileriSorgulaResponse; stdcall;
    function  faturaMailGonder(const parameters: faturaMailGonder): faturaMailGonderResponse; stdcall;
    function  irsaliyeMailGonder(const parameters: irsaliyeMailGonder): irsaliyeMailGonderResponse; stdcall;
    function  yolcuBeraberFaturaIptalEt(const parameters: yolcuBeraberFaturaIptalEt): yolcuBeraberFaturaIptalEtResponse; stdcall;
    function  belgelerAlindiEntegrasyonSiparisNoGuncelle(const parameters: belgelerAlindiEntegrasyonSiparisNoGuncelle): belgelerAlindiEntegrasyonSiparisNoGuncelleResponse; stdcall;
    function  gelenStandartRapolariAl(const parameters: gelenStandartRapolariAl): gelenStandartRapolariAlResponse; stdcall;
    function  gelenTamamlananRapolariAl(const parameters: gelenTamamlananRapolariAl): gelenTamamlananRapolariAlResponse; stdcall;
    function  wsKullanicisiKaydet(const parameters: wsKullanicisiKaydet): wsKullanicisiKaydetResponse; stdcall;
    function  urunSablonlariniAl(const parameters: urunSablonlariniAl): urunSablonlariniAlResponse; stdcall;
    function  faturaKepIleIadeEdildi(const parameters: faturaKepIleIadeEdildi): faturaKepIleIadeEdildiResponse; stdcall;
    function  faturaKepIleIadeEdildiIptal(const parameters: faturaKepIleIadeEdildiIptal): faturaKepIleIadeEdildiIptalResponse; stdcall;
  end;

function GetEFaturaQNBPort(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): ConnectorService;


implementation
  uses SysUtils;

function GetEFaturaQNBPort(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): ConnectorService;
const
  defWSDL = 'https://erpefaturatest.cs.com.tr:8043/efatura/ws/connectorService?wsdl';
  defURL  = 'https://erpefaturatest.cs.com.tr:8043/efatura/ws/connectorService';
  defSvc  = 'QNB_EFat_Service';
  defPrt  = 'ConnectorService';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as ConnectorService);//  EFaturaOIBPort
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;



destructor gidenBelgeDurumSorgulaResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure gidenBelgeDurumSorgulaResponse2.Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
begin
  Freturn := AgidenBelgeDurum;
  Freturn_Specified := True;
end;

function gidenBelgeDurumSorgulaResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor gelenBelgeleriAlExt3.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gelenBelgeleriAlExt3.Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
begin
  Fparametreler := AgelenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function gelenBelgeleriAlExt3.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

destructor yereleAktarilacakBelgeleriAlExt2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure yereleAktarilacakBelgeleriAlExt2.Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
begin
  Fparametreler := AgelenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function yereleAktarilacakBelgeleriAlExt2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

destructor gidenBelgeleriIndirPortal2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gidenBelgeleriIndirPortal2.Setparametreler(Index: Integer; const AgidenBelgeleriIndirPortalParametreleri: gidenBelgeleriIndirPortalParametreleri);
begin
  Fparametreler := AgidenBelgeleriIndirPortalParametreleri;
  Fparametreler_Specified := True;
end;

function gidenBelgeleriIndirPortal2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

destructor gidenBelgeDurumSorgulaExtResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure gidenBelgeDurumSorgulaExtResponse2.Setreturn(Index: Integer; const AserviceReturnType2: serviceReturnType2);
begin
  Freturn := AserviceReturnType2;
  Freturn_Specified := True;
end;

function gidenBelgeDurumSorgulaExtResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor belgeGonderExt2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure belgeGonderExt2.Setparametreler(Index: Integer; const AgidenBelgeParametreleri: gidenBelgeParametreleri);
begin
  Fparametreler := AgidenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function belgeGonderExt2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

destructor gelenBelgeDurumSorgulaExtResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure gelenBelgeDurumSorgulaExtResponse2.Setreturn(Index: Integer; const AserviceReturnType2: serviceReturnType2);
begin
  Freturn := AserviceReturnType2;
  Freturn_Specified := True;
end;

function gelenBelgeDurumSorgulaExtResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure csXmlToUblResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function csXmlToUblResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gelenBelgeEkleriAlResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gelenBelgeEkleriAlResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gelenStandartRapolariAlResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gelenStandartRapolariAlResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure csXmlOnizlemeResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function csXmlOnizlemeResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure urunSablonlariniAlResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function urunSablonlariniAlResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure kayitliKullaniciListeleExtendedTimeResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function kayitliKullaniciListeleExtendedTimeResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gidenBelgeEkleriAlResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gidenBelgeEkleriAlResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gidenBelgeleriIndirEttnResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gidenBelgeleriIndirEttnResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure belgeGonder2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function belgeGonder2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgeGonder2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belgeGonder2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belgeGonder2.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function belgeGonder2.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure belgeGonder2.Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fveri := ATByteDynArray;
  Fveri_Specified := True;
end;

function belgeGonder2.veri_Specified(Index: Integer): boolean;
begin
  Result := Fveri_Specified;
end;

procedure belgeGonder2.SetbelgeHash(Index: Integer; const Astring: string);
begin
  FbelgeHash := Astring;
  FbelgeHash_Specified := True;
end;

function belgeGonder2.belgeHash_Specified(Index: Integer): boolean;
begin
  Result := FbelgeHash_Specified;
end;

procedure belgeGonder2.SetmimeType(Index: Integer; const Astring: string);
begin
  FmimeType := Astring;
  FmimeType_Specified := True;
end;

function belgeGonder2.mimeType_Specified(Index: Integer): boolean;
begin
  Result := FmimeType_Specified;
end;

procedure belgeGonder2.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function belgeGonder2.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure belgeGonderResponse2.SetbelgeOid(Index: Integer; const Astring: string);
begin
  FbelgeOid := Astring;
  FbelgeOid_Specified := True;
end;

function belgeGonderResponse2.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

procedure belge.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function belge.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure belge.SetbelgeSiraNo(Index: Integer; const Astring: string);
begin
  FbelgeSiraNo := Astring;
  FbelgeSiraNo_Specified := True;
end;

function belge.belgeSiraNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeSiraNo_Specified;
end;

procedure belge.SetbelgeTarihi(Index: Integer; const Astring: string);
begin
  FbelgeTarihi := Astring;
  FbelgeTarihi_Specified := True;
end;

function belge.belgeTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTarihi_Specified;
end;

procedure belge.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belge.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belge.SetbelgeVerisi(Index: Integer; const Astring: string);
begin
  FbelgeVerisi := Astring;
  FbelgeVerisi_Specified := True;
end;

function belge.belgeVerisi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVerisi_Specified;
end;

procedure belge.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function belge.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure belge.SetgonderenEtiket(Index: Integer; const Astring: string);
begin
  FgonderenEtiket := Astring;
  FgonderenEtiket_Specified := True;
end;

function belge.gonderenEtiket_Specified(Index: Integer): boolean;
begin
  Result := FgonderenEtiket_Specified;
end;

procedure belge.SetgonderenVknTckn(Index: Integer; const Astring: string);
begin
  FgonderenVknTckn := Astring;
  FgonderenVknTckn_Specified := True;
end;

function belge.gonderenVknTckn_Specified(Index: Integer): boolean;
begin
  Result := FgonderenVknTckn_Specified;
end;

destructor belgev2.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FekBilgiler)-1 do
    SysUtils.FreeAndNil(FekBilgiler[I]);
  System.SetLength(FekBilgiler, 0);
  inherited Destroy;
end;

procedure belgev2.SetalanEtiket(Index: Integer; const Astring: string);
begin
  FalanEtiket := Astring;
  FalanEtiket_Specified := True;
end;

function belgev2.alanEtiket_Specified(Index: Integer): boolean;
begin
  Result := FalanEtiket_Specified;
end;

procedure belgev2.SetaliciUnvan(Index: Integer; const Astring: string);
begin
  FaliciUnvan := Astring;
  FaliciUnvan_Specified := True;
end;

function belgev2.aliciUnvan_Specified(Index: Integer): boolean;
begin
  Result := FaliciUnvan_Specified;
end;

procedure belgev2.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function belgev2.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure belgev2.SetbelgeXmlZipped(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  FbelgeXmlZipped := ATByteDynArray;
  FbelgeXmlZipped_Specified := True;
end;

function belgev2.belgeXmlZipped_Specified(Index: Integer): boolean;
begin
  Result := FbelgeXmlZipped_Specified;
end;

procedure belgev2.SetsaticiUnvan(Index: Integer; const Astring: string);
begin
  FsaticiUnvan := Astring;
  FsaticiUnvan_Specified := True;
end;

function belgev2.saticiUnvan_Specified(Index: Integer): boolean;
begin
  Result := FsaticiUnvan_Specified;
end;

procedure belgev2.SetsubeKodu(Index: Integer; const Astring: string);
begin
  FsubeKodu := Astring;
  FsubeKodu_Specified := True;
end;

function belgev2.subeKodu_Specified(Index: Integer): boolean;
begin
  Result := FsubeKodu_Specified;
end;

procedure belgev2.SetzarfId(Index: Integer; const Astring: string);
begin
  FzarfId := Astring;
  FzarfId_Specified := True;
end;

function belgev2.zarfId_Specified(Index: Integer): boolean;
begin
  Result := FzarfId_Specified;
end;

procedure belgev2.SetzarfVerisi(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  FzarfVerisi := ATByteDynArray;
  FzarfVerisi_Specified := True;
end;

function belgev2.zarfVerisi_Specified(Index: Integer): boolean;
begin
  Result := FzarfVerisi_Specified;
end;

procedure belgev2.SetzarfXml(Index: Integer; const Astring: string);
begin
  FzarfXml := Astring;
  FzarfXml_Specified := True;
end;

function belgev2.zarfXml_Specified(Index: Integer): boolean;
begin
  Result := FzarfXml_Specified;
end;

procedure belgev3.SetodenecekTutar(Index: Integer; const Astring: string);
begin
  FodenecekTutar := Astring;
  FodenecekTutar_Specified := True;
end;

function belgev3.odenecekTutar_Specified(Index: Integer): boolean;
begin
  Result := FodenecekTutar_Specified;
end;

procedure belgev3.SetodenecekTutarDovizCinsi(Index: Integer; const Astring: string);
begin
  FodenecekTutarDovizCinsi := Astring;
  FodenecekTutarDovizCinsi_Specified := True;
end;

function belgev3.odenecekTutarDovizCinsi_Specified(Index: Integer): boolean;
begin
  Result := FodenecekTutarDovizCinsi_Specified;
end;

procedure belgev4.Setarsivlenmis(Index: Integer; const Astring: string);
begin
  Farsivlenmis := Astring;
  Farsivlenmis_Specified := True;
end;

function belgev4.arsivlenmis_Specified(Index: Integer): boolean;
begin
  Result := Farsivlenmis_Specified;
end;

procedure belgev4.SetbelgeHash(Index: Integer; const Astring: string);
begin
  FbelgeHash := Astring;
  FbelgeHash_Specified := True;
end;

function belgev4.belgeHash_Specified(Index: Integer): boolean;
begin
  Result := FbelgeHash_Specified;
end;

procedure belgev5.SetfaturaGelisTarihi(Index: Integer; const Astring: string);
begin
  FfaturaGelisTarihi := Astring;
  FfaturaGelisTarihi_Specified := True;
end;

function belgev5.faturaGelisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FfaturaGelisTarihi_Specified;
end;

procedure belgev6.SetprofileId(Index: Integer; const Astring: string);
begin
  FprofileId := Astring;
  FprofileId_Specified := True;
end;

function belgev6.profileId_Specified(Index: Integer): boolean;
begin
  Result := FprofileId_Specified;
end;

procedure entry.Setkey(Index: Integer; const Astring: string);
begin
  Fkey := Astring;
  Fkey_Specified := True;
end;

function entry.key_Specified(Index: Integer): boolean;
begin
  Result := Fkey_Specified;
end;

procedure entry.Setvalue(Index: Integer; const Astring: string);
begin
  Fvalue := Astring;
  Fvalue_Specified := True;
end;

function entry.value_Specified(Index: Integer): boolean;
begin
  Result := Fvalue_Specified;
end;

procedure yereleAktarilacakBelgeleriAl2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function yereleAktarilacakBelgeleriAl2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure yereleAktarilacakBelgeleriAl2.SetentegrasyonHedefi(Index: Integer; const Astring: string);
begin
  FentegrasyonHedefi := Astring;
  FentegrasyonHedefi_Specified := True;
end;

function yereleAktarilacakBelgeleriAl2.entegrasyonHedefi_Specified(Index: Integer): boolean;
begin
  Result := FentegrasyonHedefi_Specified;
end;

procedure yereleAktarilacakBelgeleriAl2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function yereleAktarilacakBelgeleriAl2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeParametreleri.SetalanEtiket(Index: Integer; const Astring: string);
begin
  FalanEtiket := Astring;
  FalanEtiket_Specified := True;
end;

function gidenBelgeParametreleri.alanEtiket_Specified(Index: Integer): boolean;
begin
  Result := FalanEtiket_Specified;
end;

procedure gidenBelgeParametreleri.SetbelgeHash(Index: Integer; const Astring: string);
begin
  FbelgeHash := Astring;
  FbelgeHash_Specified := True;
end;

function gidenBelgeParametreleri.belgeHash_Specified(Index: Integer): boolean;
begin
  Result := FbelgeHash_Specified;
end;

procedure gidenBelgeParametreleri.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gidenBelgeParametreleri.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gidenBelgeParametreleri.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeParametreleri.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeParametreleri.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function gidenBelgeParametreleri.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure gidenBelgeParametreleri.SetdonusTipiVersiyon(Index: Integer; const Astring: string);
begin
  FdonusTipiVersiyon := Astring;
  FdonusTipiVersiyon_Specified := True;
end;

function gidenBelgeParametreleri.donusTipiVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FdonusTipiVersiyon_Specified;
end;

procedure gidenBelgeParametreleri.SeterpKodu(Index: Integer; const Astring: string);
begin
  FerpKodu := Astring;
  FerpKodu_Specified := True;
end;

function gidenBelgeParametreleri.erpKodu_Specified(Index: Integer): boolean;
begin
  Result := FerpKodu_Specified;
end;

procedure gidenBelgeParametreleri.SetgonderenEtiket(Index: Integer; const Astring: string);
begin
  FgonderenEtiket := Astring;
  FgonderenEtiket_Specified := True;
end;

function gidenBelgeParametreleri.gonderenEtiket_Specified(Index: Integer): boolean;
begin
  Result := FgonderenEtiket_Specified;
end;

procedure gidenBelgeParametreleri.SetmimeType(Index: Integer; const Astring: string);
begin
  FmimeType := Astring;
  FmimeType_Specified := True;
end;

function gidenBelgeParametreleri.mimeType_Specified(Index: Integer): boolean;
begin
  Result := FmimeType_Specified;
end;

procedure gidenBelgeParametreleri.SetsubeKodu(Index: Integer; const Astring: string);
begin
  FsubeKodu := Astring;
  FsubeKodu_Specified := True;
end;

function gidenBelgeParametreleri.subeKodu_Specified(Index: Integer): boolean;
begin
  Result := FsubeKodu_Specified;
end;

procedure gidenBelgeParametreleri.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeParametreleri.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeParametreleri.Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fveri := ATByteDynArray;
  Fveri_Specified := True;
end;

function gidenBelgeParametreleri.veri_Specified(Index: Integer): boolean;
begin
  Result := Fveri_Specified;
end;

procedure gidenBelgeParametreleri.SetxsltAdi(Index: Integer; const Astring: string);
begin
  FxsltAdi := Astring;
  FxsltAdi_Specified := True;
end;

function gidenBelgeParametreleri.xsltAdi_Specified(Index: Integer): boolean;
begin
  Result := FxsltAdi_Specified;
end;

procedure gidenBelgeParametreleri.SetxsltVeri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  FxsltVeri := ATByteDynArray;
  FxsltVeri_Specified := True;
end;

function gidenBelgeParametreleri.xsltVeri_Specified(Index: Integer): boolean;
begin
  Result := FxsltVeri_Specified;
end;

procedure efaturaKullaniciBilgisi2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function efaturaKullaniciBilgisi2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgeGonderExtResponse2.SetbelgeOid(Index: Integer; const Astring: string);
begin
  FbelgeOid := Astring;
  FbelgeOid_Specified := True;
end;

function belgeGonderExtResponse2.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

destructor gidenBelgeDurumSorgulaExt2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gidenBelgeDurumSorgulaExt2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeDurumSorgulaExt2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeDurumSorgulaExt2.Setparametreler(Index: Integer; const AgidenBelgeDurumParametreleri: gidenBelgeDurumParametreleri);
begin
  Fparametreler := AgidenBelgeDurumParametreleri;
  Fparametreler_Specified := True;
end;

function gidenBelgeDurumSorgulaExt2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure csXmlToUbl2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function csXmlToUbl2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure csXmlToUbl2.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function csXmlToUbl2.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure csXmlToUbl2.Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fveri := ATByteDynArray;
  Fveri_Specified := True;
end;

function csXmlToUbl2.veri_Specified(Index: Integer): boolean;
begin
  Result := Fveri_Specified;
end;

procedure csXmlToUbl2.SetxsltAdi(Index: Integer; const Astring: string);
begin
  FxsltAdi := Astring;
  FxsltAdi_Specified := True;
end;

function csXmlToUbl2.xsltAdi_Specified(Index: Integer): boolean;
begin
  Result := FxsltAdi_Specified;
end;

procedure csXmlToUbl2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function csXmlToUbl2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gelenBelgeEkleriAl2.Setuuid(Index: Integer; const Astring: string);
begin
  Fuuid := Astring;
  Fuuid_Specified := True;
end;

function gelenBelgeEkleriAl2.uuid_Specified(Index: Integer): boolean;
begin
  Result := Fuuid_Specified;
end;

procedure gelenBelgeEkleriAl2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function gelenBelgeEkleriAl2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure gelenBelgeEkleriAl2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeEkleriAl2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gelenBelgeleriAl2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeleriAl2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenBelgeleriAl2.SetsonAlinanBelgeSiraNumarasi(Index: Integer; const Astring: string);
begin
  FsonAlinanBelgeSiraNumarasi := Astring;
  FsonAlinanBelgeSiraNumarasi_Specified := True;
end;

function gelenBelgeleriAl2.sonAlinanBelgeSiraNumarasi_Specified(Index: Integer): boolean;
begin
  Result := FsonAlinanBelgeSiraNumarasi_Specified;
end;

procedure gelenBelgeleriAl2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeleriAl2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belgeGonderResp.SetbelgeOid(Index: Integer; const Astring: string);
begin
  FbelgeOid := Astring;
  FbelgeOid_Specified := True;
end;

function belgeGonderResp.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

procedure belgeGonderResp.SeterrorMessage(Index: Integer; const Astring: string);
begin
  FerrorMessage := Astring;
  FerrorMessage_Specified := True;
end;

function belgeGonderResp.errorMessage_Specified(Index: Integer): boolean;
begin
  Result := FerrorMessage_Specified;
end;

procedure belgeGonderResp.SetresponseStatus(Index: Integer; const Astring: string);
begin
  FresponseStatus := Astring;
  FresponseStatus_Specified := True;
end;

function belgeGonderResp.responseStatus_Specified(Index: Integer): boolean;
begin
  Result := FresponseStatus_Specified;
end;

procedure gelenTasinanBelgeleriIndir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenTasinanBelgeleriIndir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenTasinanBelgeleriIndir2.Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettnler := AefaturaKullaniciListesi2;
  Fettnler_Specified := True;
end;

function gelenTasinanBelgeleriIndir2.ettnler_Specified(Index: Integer): boolean;
begin
  Result := Fettnler_Specified;
end;

procedure gelenTasinanBelgeleriIndir2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function gelenTasinanBelgeleriIndir2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure gidenIrsaliyeleriArsiveKaldir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenIrsaliyeleriArsiveKaldir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenIrsaliyeleriArsiveKaldir2.SetdespatchEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FdespatchEttnListesi := AefaturaKullaniciListesi2;
  FdespatchEttnListesi_Specified := True;
end;

function gidenIrsaliyeleriArsiveKaldir2.despatchEttnListesi_Specified(Index: Integer): boolean;
begin
  Result := FdespatchEttnListesi_Specified;
end;

procedure belgelerAlindi2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function belgelerAlindi2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgelerAlindi2.Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettn := AefaturaKullaniciListesi2;
  Fettn_Specified := True;
end;

function belgelerAlindi2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure belgelerAlindi2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belgelerAlindi2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbaslangicGonderimTarihi := Astring;
  FbaslangicGonderimTarihi_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.baslangicGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbaslangicGonderimTarihi_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetbelgeEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FbelgeEttnListesi := AefaturaKullaniciListesi2;
  FbelgeEttnListesi_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.belgeEttnListesi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeEttnListesi_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetbitisGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbitisGonderimTarihi := Astring;
  FbitisGonderimTarihi_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.bitisGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbitisGonderimTarihi_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetfaturaBaslangicTarihi(Index: Integer; const Astring: string);
begin
  FfaturaBaslangicTarihi := Astring;
  FfaturaBaslangicTarihi_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.faturaBaslangicTarihi_Specified(Index: Integer): boolean;
begin
  Result := FfaturaBaslangicTarihi_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetfaturaBitisTarihi(Index: Integer; const Astring: string);
begin
  FfaturaBitisTarihi := Astring;
  FfaturaBitisTarihi_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.faturaBitisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FfaturaBitisTarihi_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.Setkaynak(Index: Integer; const Astring: string);
begin
  Fkaynak := Astring;
  Fkaynak_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.kaynak_Specified(Index: Integer): boolean;
begin
  Result := Fkaynak_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetpageCount(Index: Integer; const Astring: string);
begin
  FpageCount := Astring;
  FpageCount_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.pageCount_Specified(Index: Integer): boolean;
begin
  Result := FpageCount_Specified;
end;

procedure gidenBelgeleriIndirPortalParametreleri.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeleriIndirPortalParametreleri.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

destructor mukellefEFaturaKayit.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FefaturaKullaniciListesi)-1 do
    SysUtils.FreeAndNil(FefaturaKullaniciListesi[I]);
  System.SetLength(FefaturaKullaniciListesi, 0);
  inherited Destroy;
end;

procedure mukellefEFaturaKayit.SetefaturaKullaniciListesi(Index: Integer; const AefaturaKullaniciBilgisiResponse2: efaturaKullaniciBilgisiResponse2);
begin
  FefaturaKullaniciListesi := AefaturaKullaniciBilgisiResponse2;
  FefaturaKullaniciListesi_Specified := True;
end;

function mukellefEFaturaKayit.efaturaKullaniciListesi_Specified(Index: Integer): boolean;
begin
  Result := FefaturaKullaniciListesi_Specified;
end;

procedure mukellefEFaturaKayit.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function mukellefEFaturaKayit.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gidenBelgeTutarBilgileri.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetbelgeTarihi(Index: Integer; const Astring: string);
begin
  FbelgeTarihi := Astring;
  FbelgeTarihi_Specified := True;
end;

function gidenBelgeTutarBilgileri.belgeTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTarihi_Specified;
end;

procedure gidenBelgeTutarBilgileri.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gidenBelgeTutarBilgileri.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gidenBelgeTutarBilgileri.Setkdv18Oran(Index: Integer; const Astring: string);
begin
  Fkdv18Oran := Astring;
  Fkdv18Oran_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdv18Oran_Specified(Index: Integer): boolean;
begin
  Result := Fkdv18Oran_Specified;
end;

procedure gidenBelgeTutarBilgileri.Setkdv18Tutar(Index: Integer; const Astring: string);
begin
  Fkdv18Tutar := Astring;
  Fkdv18Tutar_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdv18Tutar_Specified(Index: Integer): boolean;
begin
  Result := Fkdv18Tutar_Specified;
end;

procedure gidenBelgeTutarBilgileri.Setkdv1Oran(Index: Integer; const Astring: string);
begin
  Fkdv1Oran := Astring;
  Fkdv1Oran_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdv1Oran_Specified(Index: Integer): boolean;
begin
  Result := Fkdv1Oran_Specified;
end;

procedure gidenBelgeTutarBilgileri.Setkdv1Tutar(Index: Integer; const Astring: string);
begin
  Fkdv1Tutar := Astring;
  Fkdv1Tutar_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdv1Tutar_Specified(Index: Integer): boolean;
begin
  Result := Fkdv1Tutar_Specified;
end;

procedure gidenBelgeTutarBilgileri.Setkdv8Oran(Index: Integer; const Astring: string);
begin
  Fkdv8Oran := Astring;
  Fkdv8Oran_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdv8Oran_Specified(Index: Integer): boolean;
begin
  Result := Fkdv8Oran_Specified;
end;

procedure gidenBelgeTutarBilgileri.Setkdv8Tutar(Index: Integer; const Astring: string);
begin
  Fkdv8Tutar := Astring;
  Fkdv8Tutar_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdv8Tutar_Specified(Index: Integer): boolean;
begin
  Result := Fkdv8Tutar_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetkdvTevkifatOran(Index: Integer; const Astring: string);
begin
  FkdvTevkifatOran := Astring;
  FkdvTevkifatOran_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdvTevkifatOran_Specified(Index: Integer): boolean;
begin
  Result := FkdvTevkifatOran_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetkdvTevkifatTutari(Index: Integer; const Astring: string);
begin
  FkdvTevkifatTutari := Astring;
  FkdvTevkifatTutari_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdvTevkifatTutari_Specified(Index: Integer): boolean;
begin
  Result := FkdvTevkifatTutari_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetkdvToplamTutari(Index: Integer; const Astring: string);
begin
  FkdvToplamTutari := Astring;
  FkdvToplamTutari_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdvToplamTutari_Specified(Index: Integer): boolean;
begin
  Result := FkdvToplamTutari_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetkdvToplamTutariDovizCinsi(Index: Integer; const Astring: string);
begin
  FkdvToplamTutariDovizCinsi := Astring;
  FkdvToplamTutariDovizCinsi_Specified := True;
end;

function gidenBelgeTutarBilgileri.kdvToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
begin
  Result := FkdvToplamTutariDovizCinsi_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetmalHizmetToplamTutari(Index: Integer; const Astring: string);
begin
  FmalHizmetToplamTutari := Astring;
  FmalHizmetToplamTutari_Specified := True;
end;

function gidenBelgeTutarBilgileri.malHizmetToplamTutari_Specified(Index: Integer): boolean;
begin
  Result := FmalHizmetToplamTutari_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetmalHizmetToplamTutariDovizCinsi(Index: Integer; const Astring: string);
begin
  FmalHizmetToplamTutariDovizCinsi := Astring;
  FmalHizmetToplamTutariDovizCinsi_Specified := True;
end;

function gidenBelgeTutarBilgileri.malHizmetToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
begin
  Result := FmalHizmetToplamTutariDovizCinsi_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetodenecekTutar(Index: Integer; const Astring: string);
begin
  FodenecekTutar := Astring;
  FodenecekTutar_Specified := True;
end;

function gidenBelgeTutarBilgileri.odenecekTutar_Specified(Index: Integer): boolean;
begin
  Result := FodenecekTutar_Specified;
end;

procedure gidenBelgeTutarBilgileri.SetodenecekTutarDovizCinsi(Index: Integer; const Astring: string);
begin
  FodenecekTutarDovizCinsi := Astring;
  FodenecekTutarDovizCinsi_Specified := True;
end;

function gidenBelgeTutarBilgileri.odenecekTutarDovizCinsi_Specified(Index: Integer): boolean;
begin
  Result := FodenecekTutarDovizCinsi_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gelenBelgeTutarBilgileri.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetbelgeTarihi(Index: Integer; const Astring: string);
begin
  FbelgeTarihi := Astring;
  FbelgeTarihi_Specified := True;
end;

function gelenBelgeTutarBilgileri.belgeTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTarihi_Specified;
end;

procedure gelenBelgeTutarBilgileri.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gelenBelgeTutarBilgileri.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetgondericiVkn(Index: Integer; const Astring: string);
begin
  FgondericiVkn := Astring;
  FgondericiVkn_Specified := True;
end;

function gelenBelgeTutarBilgileri.gondericiVkn_Specified(Index: Integer): boolean;
begin
  Result := FgondericiVkn_Specified;
end;

procedure gelenBelgeTutarBilgileri.Setkdv18Oran(Index: Integer; const Astring: string);
begin
  Fkdv18Oran := Astring;
  Fkdv18Oran_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdv18Oran_Specified(Index: Integer): boolean;
begin
  Result := Fkdv18Oran_Specified;
end;

procedure gelenBelgeTutarBilgileri.Setkdv18Tutar(Index: Integer; const Astring: string);
begin
  Fkdv18Tutar := Astring;
  Fkdv18Tutar_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdv18Tutar_Specified(Index: Integer): boolean;
begin
  Result := Fkdv18Tutar_Specified;
end;

procedure gelenBelgeTutarBilgileri.Setkdv1Oran(Index: Integer; const Astring: string);
begin
  Fkdv1Oran := Astring;
  Fkdv1Oran_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdv1Oran_Specified(Index: Integer): boolean;
begin
  Result := Fkdv1Oran_Specified;
end;

procedure gelenBelgeTutarBilgileri.Setkdv1Tutar(Index: Integer; const Astring: string);
begin
  Fkdv1Tutar := Astring;
  Fkdv1Tutar_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdv1Tutar_Specified(Index: Integer): boolean;
begin
  Result := Fkdv1Tutar_Specified;
end;

procedure gelenBelgeTutarBilgileri.Setkdv8Oran(Index: Integer; const Astring: string);
begin
  Fkdv8Oran := Astring;
  Fkdv8Oran_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdv8Oran_Specified(Index: Integer): boolean;
begin
  Result := Fkdv8Oran_Specified;
end;

procedure gelenBelgeTutarBilgileri.Setkdv8Tutar(Index: Integer; const Astring: string);
begin
  Fkdv8Tutar := Astring;
  Fkdv8Tutar_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdv8Tutar_Specified(Index: Integer): boolean;
begin
  Result := Fkdv8Tutar_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetkdvTevkifatOran(Index: Integer; const Astring: string);
begin
  FkdvTevkifatOran := Astring;
  FkdvTevkifatOran_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdvTevkifatOran_Specified(Index: Integer): boolean;
begin
  Result := FkdvTevkifatOran_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetkdvTevkifatTutari(Index: Integer; const Astring: string);
begin
  FkdvTevkifatTutari := Astring;
  FkdvTevkifatTutari_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdvTevkifatTutari_Specified(Index: Integer): boolean;
begin
  Result := FkdvTevkifatTutari_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetkdvToplamTutari(Index: Integer; const Astring: string);
begin
  FkdvToplamTutari := Astring;
  FkdvToplamTutari_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdvToplamTutari_Specified(Index: Integer): boolean;
begin
  Result := FkdvToplamTutari_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetkdvToplamTutariDovizCinsi(Index: Integer; const Astring: string);
begin
  FkdvToplamTutariDovizCinsi := Astring;
  FkdvToplamTutariDovizCinsi_Specified := True;
end;

function gelenBelgeTutarBilgileri.kdvToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
begin
  Result := FkdvToplamTutariDovizCinsi_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetmalHizmetToplamTutari(Index: Integer; const Astring: string);
begin
  FmalHizmetToplamTutari := Astring;
  FmalHizmetToplamTutari_Specified := True;
end;

function gelenBelgeTutarBilgileri.malHizmetToplamTutari_Specified(Index: Integer): boolean;
begin
  Result := FmalHizmetToplamTutari_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetmalHizmetToplamTutariDovizCinsi(Index: Integer; const Astring: string);
begin
  FmalHizmetToplamTutariDovizCinsi := Astring;
  FmalHizmetToplamTutariDovizCinsi_Specified := True;
end;

function gelenBelgeTutarBilgileri.malHizmetToplamTutariDovizCinsi_Specified(Index: Integer): boolean;
begin
  Result := FmalHizmetToplamTutariDovizCinsi_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetodenecekTutar(Index: Integer; const Astring: string);
begin
  FodenecekTutar := Astring;
  FodenecekTutar_Specified := True;
end;

function gelenBelgeTutarBilgileri.odenecekTutar_Specified(Index: Integer): boolean;
begin
  Result := FodenecekTutar_Specified;
end;

procedure gelenBelgeTutarBilgileri.SetodenecekTutarDovizCinsi(Index: Integer; const Astring: string);
begin
  FodenecekTutarDovizCinsi := Astring;
  FodenecekTutarDovizCinsi_Specified := True;
end;

function gelenBelgeTutarBilgileri.odenecekTutarDovizCinsi_Specified(Index: Integer): boolean;
begin
  Result := FodenecekTutarDovizCinsi_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetalanEtiket(Index: Integer; const Astring: string);
begin
  FalanEtiket := Astring;
  FalanEtiket_Specified := True;
end;

function gidenBelgeleriListelePortalData.alanEtiket_Specified(Index: Integer): boolean;
begin
  Result := FalanEtiket_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetalanSubeKodu(Index: Integer; const Astring: string);
begin
  FalanSubeKodu := Astring;
  FalanSubeKodu_Specified := True;
end;

function gidenBelgeleriListelePortalData.alanSubeKodu_Specified(Index: Integer): boolean;
begin
  Result := FalanSubeKodu_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetalanVergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FalanVergiTcKimlikNo := Astring;
  FalanVergiTcKimlikNo_Specified := True;
end;

function gidenBelgeleriListelePortalData.alanVergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FalanVergiTcKimlikNo_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gidenBelgeleriListelePortalData.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetbelgeTarihi(Index: Integer; const Astring: string);
begin
  FbelgeTarihi := Astring;
  FbelgeTarihi_Specified := True;
end;

function gidenBelgeleriListelePortalData.belgeTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTarihi_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetbelgeTipi(Index: Integer; const Astring: string);
begin
  FbelgeTipi := Astring;
  FbelgeTipi_Specified := True;
end;

function gidenBelgeleriListelePortalData.belgeTipi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTipi_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeleriListelePortalData.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriListelePortalData.SeterpKodu(Index: Integer; const Astring: string);
begin
  FerpKodu := Astring;
  FerpKodu_Specified := True;
end;

function gidenBelgeleriListelePortalData.erpKodu_Specified(Index: Integer): boolean;
begin
  Result := FerpKodu_Specified;
end;

procedure gidenBelgeleriListelePortalData.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gidenBelgeleriListelePortalData.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetgonderenEtiket(Index: Integer; const Astring: string);
begin
  FgonderenEtiket := Astring;
  FgonderenEtiket_Specified := True;
end;

function gidenBelgeleriListelePortalData.gonderenEtiket_Specified(Index: Integer): boolean;
begin
  Result := FgonderenEtiket_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetgonderenSubeKodu(Index: Integer; const Astring: string);
begin
  FgonderenSubeKodu := Astring;
  FgonderenSubeKodu_Specified := True;
end;

function gidenBelgeleriListelePortalData.gonderenSubeKodu_Specified(Index: Integer): boolean;
begin
  Result := FgonderenSubeKodu_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetgonderimZamani(Index: Integer; const Astring: string);
begin
  FgonderimZamani := Astring;
  FgonderimZamani_Specified := True;
end;

function gidenBelgeleriListelePortalData.gonderimZamani_Specified(Index: Integer): boolean;
begin
  Result := FgonderimZamani_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetislemYapanVkn(Index: Integer; const Astring: string);
begin
  FislemYapanVkn := Astring;
  FislemYapanVkn_Specified := True;
end;

function gidenBelgeleriListelePortalData.islemYapanVkn_Specified(Index: Integer): boolean;
begin
  Result := FislemYapanVkn_Specified;
end;

procedure gidenBelgeleriListelePortalData.Setkaynak(Index: Integer; const Astring: string);
begin
  Fkaynak := Astring;
  Fkaynak_Specified := True;
end;

function gidenBelgeleriListelePortalData.kaynak_Specified(Index: Integer): boolean;
begin
  Result := Fkaynak_Specified;
end;

procedure gidenBelgeleriListelePortalData.SetkullaniciKodu(Index: Integer; const Astring: string);
begin
  FkullaniciKodu := Astring;
  FkullaniciKodu_Specified := True;
end;

function gidenBelgeleriListelePortalData.kullaniciKodu_Specified(Index: Integer): boolean;
begin
  Result := FkullaniciKodu_Specified;
end;

procedure gidenBelgeleriListelePortalDatav2.SetyanitEttn(Index: Integer; const Astring: string);
begin
  FyanitEttn := Astring;
  FyanitEttn_Specified := True;
end;

function gidenBelgeleriListelePortalDatav2.yanitEttn_Specified(Index: Integer): boolean;
begin
  Result := FyanitEttn_Specified;
end;

destructor cokluGidenBelgeDurumSorgula2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure cokluGidenBelgeDurumSorgula2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function cokluGidenBelgeDurumSorgula2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure cokluGidenBelgeDurumSorgula2.Setparametreler(Index: Integer; const AgidenBelgeDurumParametreleri: gidenBelgeDurumParametreleri);
begin
  Fparametreler := AgidenBelgeDurumParametreleri;
  Fparametreler_Specified := True;
end;

function cokluGidenBelgeDurumSorgula2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure faturaTarihcesiSorgula2.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function faturaTarihcesiSorgula2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure faturaTarihcesiSorgula2.SetfaturaYonu(Index: Integer; const Astring: string);
begin
  FfaturaYonu := Astring;
  FfaturaYonu_Specified := True;
end;

function faturaTarihcesiSorgula2.faturaYonu_Specified(Index: Integer): boolean;
begin
  Result := FfaturaYonu_Specified;
end;

procedure faturaTarihcesiSorgula2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function faturaTarihcesiSorgula2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure gidenBelgeDurumParametreleri.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gidenBelgeDurumParametreleri.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gidenBelgeDurumParametreleri.SetbelgeNoList(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FbelgeNoList := AefaturaKullaniciListesi2;
  FbelgeNoList_Specified := True;
end;

function gidenBelgeDurumParametreleri.belgeNoList_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNoList_Specified;
end;

procedure gidenBelgeDurumParametreleri.SetbelgeNoTipi(Index: Integer; const Astring: string);
begin
  FbelgeNoTipi := Astring;
  FbelgeNoTipi_Specified := True;
end;

function gidenBelgeDurumParametreleri.belgeNoTipi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNoTipi_Specified;
end;

procedure gidenBelgeDurumParametreleri.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeDurumParametreleri.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeDurumParametreleri.SetdonusTipiVersiyon(Index: Integer; const Astring: string);
begin
  FdonusTipiVersiyon := Astring;
  FdonusTipiVersiyon_Specified := True;
end;

function gidenBelgeDurumParametreleri.donusTipiVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FdonusTipiVersiyon_Specified;
end;

procedure irsaliyeMailGonder2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function irsaliyeMailGonder2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure irsaliyeMailGonder2.SetinOut(Index: Integer; const Astring: string);
begin
  FinOut := Astring;
  FinOut_Specified := True;
end;

function irsaliyeMailGonder2.inOut_Specified(Index: Integer): boolean;
begin
  Result := FinOut_Specified;
end;

procedure irsaliyeMailGonder2.SetUUID(Index: Integer; const Astring: string);
begin
  FUUID := Astring;
  FUUID_Specified := True;
end;

function irsaliyeMailGonder2.UUID_Specified(Index: Integer): boolean;
begin
  Result := FUUID_Specified;
end;

procedure irsaliyeMailGonder2.SetirsaliyeNo(Index: Integer; const Astring: string);
begin
  FirsaliyeNo := Astring;
  FirsaliyeNo_Specified := True;
end;

function irsaliyeMailGonder2.irsaliyeNo_Specified(Index: Integer): boolean;
begin
  Result := FirsaliyeNo_Specified;
end;

procedure irsaliyeMailGonder2.Setalicilar(Index: Integer; const Astring: string);
begin
  Falicilar := Astring;
  Falicilar_Specified := True;
end;

function irsaliyeMailGonder2.alicilar_Specified(Index: Integer): boolean;
begin
  Result := Falicilar_Specified;
end;

procedure irsaliyeMailGonder2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function irsaliyeMailGonder2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure faturaKepIleIadeEdildiIptal2.Setuuid(Index: Integer; const Astring: string);
begin
  Fuuid := Astring;
  Fuuid_Specified := True;
end;

function faturaKepIleIadeEdildiIptal2.uuid_Specified(Index: Integer): boolean;
begin
  Result := Fuuid_Specified;
end;

procedure faturaKepIleIadeEdildiIptal2.SetgelenGiden(Index: Integer; const Astring: string);
begin
  FgelenGiden := Astring;
  FgelenGiden_Specified := True;
end;

function faturaKepIleIadeEdildiIptal2.gelenGiden_Specified(Index: Integer): boolean;
begin
  Result := FgelenGiden_Specified;
end;

procedure Exception.Setmessage_(Index: Integer; const Astring: string);
begin
  Fmessage_ := Astring;
  Fmessage__Specified := True;
end;

function Exception.message__Specified(Index: Integer): boolean;
begin
  Result := Fmessage__Specified;
end;

procedure gelenStandartRapolariAl2.SetgonderenVknTckn(Index: Integer; const Astring: string);
begin
  FgonderenVknTckn := Astring;
  FgonderenVknTckn_Specified := True;
end;

function gelenStandartRapolariAl2.gonderenVknTckn_Specified(Index: Integer): boolean;
begin
  Result := FgonderenVknTckn_Specified;
end;

procedure gelenStandartRapolariAl2.SetaliciVknTckn(Index: Integer; const Astring: string);
begin
  FaliciVknTckn := Astring;
  FaliciVknTckn_Specified := True;
end;

function gelenStandartRapolariAl2.aliciVknTckn_Specified(Index: Integer): boolean;
begin
  Result := FaliciVknTckn_Specified;
end;

procedure gelenStandartRapolariAl2.SetbaslangicTarihi(Index: Integer; const Astring: string);
begin
  FbaslangicTarihi := Astring;
  FbaslangicTarihi_Specified := True;
end;

function gelenStandartRapolariAl2.baslangicTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbaslangicTarihi_Specified;
end;

procedure gelenStandartRapolariAl2.SetbitisTarihi(Index: Integer; const Astring: string);
begin
  FbitisTarihi := Astring;
  FbitisTarihi_Specified := True;
end;

function gelenStandartRapolariAl2.bitisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbitisTarihi_Specified;
end;

procedure gelenStandartRapolariAl2.SetgonderimBaslangicTarihi(Index: Integer; const Astring: string);
begin
  FgonderimBaslangicTarihi := Astring;
  FgonderimBaslangicTarihi_Specified := True;
end;

function gelenStandartRapolariAl2.gonderimBaslangicTarihi_Specified(Index: Integer): boolean;
begin
  Result := FgonderimBaslangicTarihi_Specified;
end;

procedure gelenStandartRapolariAl2.SetgonderimBitisTarihi(Index: Integer; const Astring: string);
begin
  FgonderimBitisTarihi := Astring;
  FgonderimBitisTarihi_Specified := True;
end;

function gelenStandartRapolariAl2.gonderimBitisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FgonderimBitisTarihi_Specified;
end;

procedure gelenBelgeleriListele2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeleriListele2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenBelgeleriListele2.SetsonAlinanBelgeSiraNumarasi(Index: Integer; const Astring: string);
begin
  FsonAlinanBelgeSiraNumarasi := Astring;
  FsonAlinanBelgeSiraNumarasi_Specified := True;
end;

function gelenBelgeleriListele2.sonAlinanBelgeSiraNumarasi_Specified(Index: Integer): boolean;
begin
  Result := FsonAlinanBelgeSiraNumarasi_Specified;
end;

procedure gelenBelgeleriListele2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeleriListele2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure eIrsaliyeKullanicisi2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function eIrsaliyeKullanicisi2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure csXmlOnizleme2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function csXmlOnizleme2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure csXmlOnizleme2.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function csXmlOnizleme2.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure csXmlOnizleme2.Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fveri := ATByteDynArray;
  Fveri_Specified := True;
end;

function csXmlOnizleme2.veri_Specified(Index: Integer): boolean;
begin
  Result := Fveri_Specified;
end;

procedure csXmlOnizleme2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function csXmlOnizleme2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure csXmlOnizleme2.SetxsltAdi(Index: Integer; const Astring: string);
begin
  FxsltAdi := Astring;
  FxsltAdi_Specified := True;
end;

function csXmlOnizleme2.xsltAdi_Specified(Index: Integer): boolean;
begin
  Result := FxsltAdi_Specified;
end;

procedure csXmlOnizleme2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function csXmlOnizleme2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure urunSablonlariniAl2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function urunSablonlariniAl2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure urunSablonlariniAl2.Seturun(Index: Integer; const Astring: string);
begin
  Furun := Astring;
  Furun_Specified := True;
end;

function urunSablonlariniAl2.urun_Specified(Index: Integer): boolean;
begin
  Result := Furun_Specified;
end;

procedure eFaturaKayitliKullaniciListele2.SetkayitZamani(Index: Integer; const Astring: string);
begin
  FkayitZamani := Astring;
  FkayitZamani_Specified := True;
end;

function eFaturaKayitliKullaniciListele2.kayitZamani_Specified(Index: Integer): boolean;
begin
  Result := FkayitZamani_Specified;
end;

procedure gidenBelgeDurumSorgula2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeDurumSorgula2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeDurumSorgula2.SetbelgeOid(Index: Integer; const Astring: string);
begin
  FbelgeOid := Astring;
  FbelgeOid_Specified := True;
end;

function gidenBelgeDurumSorgula2.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

procedure faturaKepIleIadeEdildi2.Setuuid(Index: Integer; const Astring: string);
begin
  Fuuid := Astring;
  Fuuid_Specified := True;
end;

function faturaKepIleIadeEdildi2.uuid_Specified(Index: Integer): boolean;
begin
  Result := Fuuid_Specified;
end;

procedure faturaKepIleIadeEdildi2.SetgelenGiden(Index: Integer; const Astring: string);
begin
  FgelenGiden := Astring;
  FgelenGiden_Specified := True;
end;

function faturaKepIleIadeEdildi2.gelenGiden_Specified(Index: Integer): boolean;
begin
  Result := FgelenGiden_Specified;
end;

procedure gelenBelgeTutarBilgileriSorgula2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeTutarBilgileriSorgula2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenBelgeTutarBilgileriSorgula2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeTutarBilgileriSorgula2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gelenBelgeTutarBilgileriSorgula2.SetbaslangicGelisTarihi(Index: Integer; const Astring: string);
begin
  FbaslangicGelisTarihi := Astring;
  FbaslangicGelisTarihi_Specified := True;
end;

function gelenBelgeTutarBilgileriSorgula2.baslangicGelisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbaslangicGelisTarihi_Specified;
end;

procedure gelenBelgeTutarBilgileriSorgula2.SetbitisGelisTarihi(Index: Integer; const Astring: string);
begin
  FbitisGelisTarihi := Astring;
  FbitisGelisTarihi_Specified := True;
end;

function gelenBelgeTutarBilgileriSorgula2.bitisGelisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbitisGelisTarihi_Specified;
end;

procedure gidenBelgeEkleriAl2.Setuuid(Index: Integer; const Astring: string);
begin
  Fuuid := Astring;
  Fuuid_Specified := True;
end;

function gidenBelgeEkleriAl2.uuid_Specified(Index: Integer): boolean;
begin
  Result := Fuuid_Specified;
end;

procedure gidenBelgeEkleriAl2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function gidenBelgeEkleriAl2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure gidenBelgeEkleriAl2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeEkleriAl2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriIndirEttn2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeleriIndirEttn2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeleriIndirEttn2.SetbelgeEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FbelgeEttnListesi := AefaturaKullaniciListesi2;
  FbelgeEttnListesi_Specified := True;
end;

function gidenBelgeleriIndirEttn2.belgeEttnListesi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeEttnListesi_Specified;
end;

procedure gidenBelgeleriIndirEttn2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeleriIndirEttn2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriIndirEttn2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function gidenBelgeleriIndirEttn2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure gelenBelgeParametreleri.SetalanEtiket(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FalanEtiket := AefaturaKullaniciListesi2;
  FalanEtiket_Specified := True;
end;

function gelenBelgeParametreleri.alanEtiket_Specified(Index: Integer): boolean;
begin
  Result := FalanEtiket_Specified;
end;

procedure gelenBelgeParametreleri.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function gelenBelgeParametreleri.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure gelenBelgeParametreleri.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeParametreleri.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gelenBelgeParametreleri.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function gelenBelgeParametreleri.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure gelenBelgeParametreleri.SetbelgelerAlindiMi(Index: Integer; const ABoolean: Boolean);
begin
  FbelgelerAlindiMi := ABoolean;
  FbelgelerAlindiMi_Specified := True;
end;

function gelenBelgeParametreleri.belgelerAlindiMi_Specified(Index: Integer): boolean;
begin
  Result := FbelgelerAlindiMi_Specified;
end;

procedure gelenBelgeParametreleri.SetdonusTipiVersiyon(Index: Integer; const Astring: string);
begin
  FdonusTipiVersiyon := Astring;
  FdonusTipiVersiyon_Specified := True;
end;

function gelenBelgeParametreleri.donusTipiVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FdonusTipiVersiyon_Specified;
end;

procedure gelenBelgeParametreleri.SetentegrasyonHedefi(Index: Integer; const Astring: string);
begin
  FentegrasyonHedefi := Astring;
  FentegrasyonHedefi_Specified := True;
end;

function gelenBelgeParametreleri.entegrasyonHedefi_Specified(Index: Integer): boolean;
begin
  Result := FentegrasyonHedefi_Specified;
end;

procedure gelenBelgeParametreleri.SeterpKodu(Index: Integer; const Astring: string);
begin
  FerpKodu := Astring;
  FerpKodu_Specified := True;
end;

function gelenBelgeParametreleri.erpKodu_Specified(Index: Integer): boolean;
begin
  Result := FerpKodu_Specified;
end;

procedure gelenBelgeParametreleri.Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettn := AefaturaKullaniciListesi2;
  Fettn_Specified := True;
end;

function gelenBelgeParametreleri.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gelenBelgeParametreleri.SetfaturaTarihiBaslangic(Index: Integer; const Astring: string);
begin
  FfaturaTarihiBaslangic := Astring;
  FfaturaTarihiBaslangic_Specified := True;
end;

function gelenBelgeParametreleri.faturaTarihiBaslangic_Specified(Index: Integer): boolean;
begin
  Result := FfaturaTarihiBaslangic_Specified;
end;

procedure gelenBelgeParametreleri.SetfaturaTarihiBitis(Index: Integer; const Astring: string);
begin
  FfaturaTarihiBitis := Astring;
  FfaturaTarihiBitis_Specified := True;
end;

function gelenBelgeParametreleri.faturaTarihiBitis_Specified(Index: Integer): boolean;
begin
  Result := FfaturaTarihiBitis_Specified;
end;

procedure gelenBelgeParametreleri.SetgelisTarihiBaslangic(Index: Integer; const Astring: string);
begin
  FgelisTarihiBaslangic := Astring;
  FgelisTarihiBaslangic_Specified := True;
end;

function gelenBelgeParametreleri.gelisTarihiBaslangic_Specified(Index: Integer): boolean;
begin
  Result := FgelisTarihiBaslangic_Specified;
end;

procedure gelenBelgeParametreleri.SetgelisTarihiBitis(Index: Integer; const Astring: string);
begin
  FgelisTarihiBitis := Astring;
  FgelisTarihiBitis_Specified := True;
end;

function gelenBelgeParametreleri.gelisTarihiBitis_Specified(Index: Integer): boolean;
begin
  Result := FgelisTarihiBitis_Specified;
end;

procedure gelenBelgeParametreleri.SetgonderenEtiket(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FgonderenEtiket := AefaturaKullaniciListesi2;
  FgonderenEtiket_Specified := True;
end;

function gelenBelgeParametreleri.gonderenEtiket_Specified(Index: Integer): boolean;
begin
  Result := FgonderenEtiket_Specified;
end;

procedure gelenBelgeParametreleri.SetonayDurum(Index: Integer; const Astring: string);
begin
  FonayDurum := Astring;
  FonayDurum_Specified := True;
end;

function gelenBelgeParametreleri.onayDurum_Specified(Index: Integer): boolean;
begin
  Result := FonayDurum_Specified;
end;

procedure gelenBelgeParametreleri.SetsonAlinanBelgeSiraNumarasi(Index: Integer; const Astring: string);
begin
  FsonAlinanBelgeSiraNumarasi := Astring;
  FsonAlinanBelgeSiraNumarasi_Specified := True;
end;

function gelenBelgeParametreleri.sonAlinanBelgeSiraNumarasi_Specified(Index: Integer): boolean;
begin
  Result := FsonAlinanBelgeSiraNumarasi_Specified;
end;

procedure gelenBelgeParametreleri.SetsubeKodu(Index: Integer; const Astring: string);
begin
  FsubeKodu := Astring;
  FsubeKodu_Specified := True;
end;

function gelenBelgeParametreleri.subeKodu_Specified(Index: Integer): boolean;
begin
  Result := FsubeKodu_Specified;
end;

procedure gelenBelgeParametreleri.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeParametreleri.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure eFaturaKullanici.Setetiket(Index: Integer; const Astring: string);
begin
  Fetiket := Astring;
  Fetiket_Specified := True;
end;

function eFaturaKullanici.etiket_Specified(Index: Integer): boolean;
begin
  Result := Fetiket_Specified;
end;

procedure eFaturaKullanici.SetkayitZamani(Index: Integer; const Astring: string);
begin
  FkayitZamani := Astring;
  FkayitZamani_Specified := True;
end;

function eFaturaKullanici.kayitZamani_Specified(Index: Integer): boolean;
begin
  Result := FkayitZamani_Specified;
end;

procedure eFaturaKullanici.Setunvan(Index: Integer; const Astring: string);
begin
  Funvan := Astring;
  Funvan_Specified := True;
end;

function eFaturaKullanici.unvan_Specified(Index: Integer): boolean;
begin
  Result := Funvan_Specified;
end;

procedure eFaturaKullanici.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function eFaturaKullanici.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure eIrsaliyeKullanici.Setetiket(Index: Integer; const Astring: string);
begin
  Fetiket := Astring;
  Fetiket_Specified := True;
end;

function eIrsaliyeKullanici.etiket_Specified(Index: Integer): boolean;
begin
  Result := Fetiket_Specified;
end;

procedure eIrsaliyeKullanici.SetkayitZamani(Index: Integer; const Astring: string);
begin
  FkayitZamani := Astring;
  FkayitZamani_Specified := True;
end;

function eIrsaliyeKullanici.kayitZamani_Specified(Index: Integer): boolean;
begin
  Result := FkayitZamani_Specified;
end;

procedure eIrsaliyeKullanici.Setunvan(Index: Integer; const Astring: string);
begin
  Funvan := Astring;
  Funvan_Specified := True;
end;

function eIrsaliyeKullanici.unvan_Specified(Index: Integer): boolean;
begin
  Result := Funvan_Specified;
end;

procedure eIrsaliyeKullanici.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function eIrsaliyeKullanici.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

destructor gelenBelgeDurumSorgulaExt2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gelenBelgeDurumSorgulaExt2.Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
begin
  Fparametreler := AgelenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function gelenBelgeDurumSorgulaExt2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure gelenTasinanBelgeleriIndirResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gelenTasinanBelgeleriIndirResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure Exception2.Setmessage_(Index: Integer; const Astring: string);
begin
  Fmessage_ := Astring;
  Fmessage__Specified := True;
end;

function Exception2.message__Specified(Index: Integer): boolean;
begin
  Result := Fmessage__Specified;
end;

procedure gidenBelgeleriListeleData.SetalimDurumu(Index: Integer; const Astring: string);
begin
  FalimDurumu := Astring;
  FalimDurumu_Specified := True;
end;

function gidenBelgeleriListeleData.alimDurumu_Specified(Index: Integer): boolean;
begin
  Result := FalimDurumu_Specified;
end;

procedure gidenBelgeleriListeleData.SetalimZamani(Index: Integer; const Astring: string);
begin
  FalimZamani := Astring;
  FalimZamani_Specified := True;
end;

function gidenBelgeleriListeleData.alimZamani_Specified(Index: Integer): boolean;
begin
  Result := FalimZamani_Specified;
end;

procedure gidenBelgeleriListeleData.SetbelgeOid(Index: Integer; const Astring: string);
begin
  FbelgeOid := Astring;
  FbelgeOid_Specified := True;
end;

function gidenBelgeleriListeleData.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

procedure gidenBelgeleriListeleData.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gidenBelgeleriListeleData.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gidenBelgeleriListeleData.SethataMesaji(Index: Integer; const Astring: string);
begin
  FhataMesaji := Astring;
  FhataMesaji_Specified := True;
end;

function gidenBelgeleriListeleData.hataMesaji_Specified(Index: Integer): boolean;
begin
  Result := FhataMesaji_Specified;
end;

procedure gidenBelgeleriListeleData.SetislemYapanVkn(Index: Integer; const Astring: string);
begin
  FislemYapanVkn := Astring;
  FislemYapanVkn_Specified := True;
end;

function gidenBelgeleriListeleData.islemYapanVkn_Specified(Index: Integer): boolean;
begin
  Result := FislemYapanVkn_Specified;
end;

procedure gidenBelgeleriListeleData.Setkaynak(Index: Integer; const Astring: string);
begin
  Fkaynak := Astring;
  Fkaynak_Specified := True;
end;

function gidenBelgeleriListeleData.kaynak_Specified(Index: Integer): boolean;
begin
  Result := Fkaynak_Specified;
end;

procedure gidenBelgeleriListeleData.SetkullaniciKodu(Index: Integer; const Astring: string);
begin
  FkullaniciKodu := Astring;
  FkullaniciKodu_Specified := True;
end;

function gidenBelgeleriListeleData.kullaniciKodu_Specified(Index: Integer): boolean;
begin
  Result := FkullaniciKodu_Specified;
end;

procedure gidenBelgeleriListeleData.SetyerelBelgeNo(Index: Integer; const Astring: string);
begin
  FyerelBelgeNo := Astring;
  FyerelBelgeNo_Specified := True;
end;

function gidenBelgeleriListeleData.yerelBelgeNo_Specified(Index: Integer): boolean;
begin
  Result := FyerelBelgeNo_Specified;
end;

procedure faturaTarihcesiData.SetbagliKayitId(Index: Integer; const Astring: string);
begin
  FbagliKayitId := Astring;
  FbagliKayitId_Specified := True;
end;

function faturaTarihcesiData.bagliKayitId_Specified(Index: Integer): boolean;
begin
  Result := FbagliKayitId_Specified;
end;

procedure faturaTarihcesiData.SetfaturaEttn(Index: Integer; const Astring: string);
begin
  FfaturaEttn := Astring;
  FfaturaEttn_Specified := True;
end;

function faturaTarihcesiData.faturaEttn_Specified(Index: Integer): boolean;
begin
  Result := FfaturaEttn_Specified;
end;

procedure faturaTarihcesiData.SetislemAciklama(Index: Integer; const Astring: string);
begin
  FislemAciklama := Astring;
  FislemAciklama_Specified := True;
end;

function faturaTarihcesiData.islemAciklama_Specified(Index: Integer): boolean;
begin
  Result := FislemAciklama_Specified;
end;

procedure faturaTarihcesiData.SetislemKanaliAciklama(Index: Integer; const Astring: string);
begin
  FislemKanaliAciklama := Astring;
  FislemKanaliAciklama_Specified := True;
end;

function faturaTarihcesiData.islemKanaliAciklama_Specified(Index: Integer): boolean;
begin
  Result := FislemKanaliAciklama_Specified;
end;

procedure faturaTarihcesiData.SetislemSonucu(Index: Integer; const Astring: string);
begin
  FislemSonucu := Astring;
  FislemSonucu_Specified := True;
end;

function faturaTarihcesiData.islemSonucu_Specified(Index: Integer): boolean;
begin
  Result := FislemSonucu_Specified;
end;

procedure faturaTarihcesiData.SetislemZamani(Index: Integer; const Astring: string);
begin
  FislemZamani := Astring;
  FislemZamani_Specified := True;
end;

function faturaTarihcesiData.islemZamani_Specified(Index: Integer): boolean;
begin
  Result := FislemZamani_Specified;
end;

procedure faturaTarihcesiData.Setkullanici(Index: Integer; const Astring: string);
begin
  Fkullanici := Astring;
  Fkullanici_Specified := True;
end;

function faturaTarihcesiData.kullanici_Specified(Index: Integer): boolean;
begin
  Result := Fkullanici_Specified;
end;

procedure faturaTarihcesiData.SetkullaniciIp(Index: Integer; const Astring: string);
begin
  FkullaniciIp := Astring;
  FkullaniciIp_Specified := True;
end;

function faturaTarihcesiData.kullaniciIp_Specified(Index: Integer): boolean;
begin
  Result := FkullaniciIp_Specified;
end;

procedure faturaTarihcesiData.SetzarfEttn(Index: Integer; const Astring: string);
begin
  FzarfEttn := Astring;
  FzarfEttn_Specified := True;
end;

function faturaTarihcesiData.zarfEttn_Specified(Index: Integer): boolean;
begin
  Result := FzarfEttn_Specified;
end;

procedure irsaliyeTarihcesiData.SetbagliKayitId(Index: Integer; const Astring: string);
begin
  FbagliKayitId := Astring;
  FbagliKayitId_Specified := True;
end;

function irsaliyeTarihcesiData.bagliKayitId_Specified(Index: Integer): boolean;
begin
  Result := FbagliKayitId_Specified;
end;

procedure irsaliyeTarihcesiData.SetirsaliyeEttn(Index: Integer; const Astring: string);
begin
  FirsaliyeEttn := Astring;
  FirsaliyeEttn_Specified := True;
end;

function irsaliyeTarihcesiData.irsaliyeEttn_Specified(Index: Integer): boolean;
begin
  Result := FirsaliyeEttn_Specified;
end;

procedure irsaliyeTarihcesiData.SetislemAciklama(Index: Integer; const Astring: string);
begin
  FislemAciklama := Astring;
  FislemAciklama_Specified := True;
end;

function irsaliyeTarihcesiData.islemAciklama_Specified(Index: Integer): boolean;
begin
  Result := FislemAciklama_Specified;
end;

procedure irsaliyeTarihcesiData.SetislemKanaliAciklama(Index: Integer; const Astring: string);
begin
  FislemKanaliAciklama := Astring;
  FislemKanaliAciklama_Specified := True;
end;

function irsaliyeTarihcesiData.islemKanaliAciklama_Specified(Index: Integer): boolean;
begin
  Result := FislemKanaliAciklama_Specified;
end;

procedure irsaliyeTarihcesiData.SetislemSonucu(Index: Integer; const Astring: string);
begin
  FislemSonucu := Astring;
  FislemSonucu_Specified := True;
end;

function irsaliyeTarihcesiData.islemSonucu_Specified(Index: Integer): boolean;
begin
  Result := FislemSonucu_Specified;
end;

procedure irsaliyeTarihcesiData.SetislemZamani(Index: Integer; const Astring: string);
begin
  FislemZamani := Astring;
  FislemZamani_Specified := True;
end;

function irsaliyeTarihcesiData.islemZamani_Specified(Index: Integer): boolean;
begin
  Result := FislemZamani_Specified;
end;

procedure irsaliyeTarihcesiData.Setkullanici(Index: Integer; const Astring: string);
begin
  Fkullanici := Astring;
  Fkullanici_Specified := True;
end;

function irsaliyeTarihcesiData.kullanici_Specified(Index: Integer): boolean;
begin
  Result := Fkullanici_Specified;
end;

procedure irsaliyeTarihcesiData.SetkullaniciIp(Index: Integer; const Astring: string);
begin
  FkullaniciIp := Astring;
  FkullaniciIp_Specified := True;
end;

function irsaliyeTarihcesiData.kullaniciIp_Specified(Index: Integer): boolean;
begin
  Result := FkullaniciIp_Specified;
end;

procedure irsaliyeTarihcesiData.SetzarfEttn(Index: Integer; const Astring: string);
begin
  FzarfEttn := Astring;
  FzarfEttn_Specified := True;
end;

function irsaliyeTarihcesiData.zarfEttn_Specified(Index: Integer): boolean;
begin
  Result := FzarfEttn_Specified;
end;

procedure eFaturaKayitliKullaniciHistory.Setetiket(Index: Integer; const Astring: string);
begin
  Fetiket := Astring;
  Fetiket_Specified := True;
end;

function eFaturaKayitliKullaniciHistory.etiket_Specified(Index: Integer): boolean;
begin
  Result := Fetiket_Specified;
end;

procedure eFaturaKayitliKullaniciHistory.SetetiketOlusturulmaZamani(Index: Integer; const Astring: string);
begin
  FetiketOlusturulmaZamani := Astring;
  FetiketOlusturulmaZamani_Specified := True;
end;

function eFaturaKayitliKullaniciHistory.etiketOlusturulmaZamani_Specified(Index: Integer): boolean;
begin
  Result := FetiketOlusturulmaZamani_Specified;
end;

procedure eFaturaKayitliKullaniciHistory.SetsilinmeZamani(Index: Integer; const Astring: string);
begin
  FsilinmeZamani := Astring;
  FsilinmeZamani_Specified := True;
end;

function eFaturaKayitliKullaniciHistory.silinmeZamani_Specified(Index: Integer): boolean;
begin
  Result := FsilinmeZamani_Specified;
end;

destructor eFaturaKullaniciExtended.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FeFaturaKayitliKullaniciHistoryList)-1 do
    SysUtils.FreeAndNil(FeFaturaKayitliKullaniciHistoryList[I]);
  System.SetLength(FeFaturaKayitliKullaniciHistoryList, 0);
  inherited Destroy;
end;

procedure eFaturaKullaniciExtended.Setetiket(Index: Integer; const Astring: string);
begin
  Fetiket := Astring;
  Fetiket_Specified := True;
end;

function eFaturaKullaniciExtended.etiket_Specified(Index: Integer): boolean;
begin
  Result := Fetiket_Specified;
end;

procedure eFaturaKullaniciExtended.SetetiketOlusturulmaZamani(Index: Integer; const Astring: string);
begin
  FetiketOlusturulmaZamani := Astring;
  FetiketOlusturulmaZamani_Specified := True;
end;

function eFaturaKullaniciExtended.etiketOlusturulmaZamani_Specified(Index: Integer): boolean;
begin
  Result := FetiketOlusturulmaZamani_Specified;
end;

procedure eFaturaKullaniciExtended.SethesapTipi(Index: Integer; const AInteger: Integer);
begin
  FhesapTipi := AInteger;
  FhesapTipi_Specified := True;
end;

function eFaturaKullaniciExtended.hesapTipi_Specified(Index: Integer): boolean;
begin
  Result := FhesapTipi_Specified;
end;

procedure eFaturaKullaniciExtended.SetkayitZamani(Index: Integer; const Astring: string);
begin
  FkayitZamani := Astring;
  FkayitZamani_Specified := True;
end;

function eFaturaKullaniciExtended.kayitZamani_Specified(Index: Integer): boolean;
begin
  Result := FkayitZamani_Specified;
end;

procedure eFaturaKullaniciExtended.Settip(Index: Integer; const AInteger: Integer);
begin
  Ftip := AInteger;
  Ftip_Specified := True;
end;

function eFaturaKullaniciExtended.tip_Specified(Index: Integer): boolean;
begin
  Result := Ftip_Specified;
end;

procedure eFaturaKullaniciExtended.Setunvan(Index: Integer; const Astring: string);
begin
  Funvan := Astring;
  Funvan_Specified := True;
end;

function eFaturaKullaniciExtended.unvan_Specified(Index: Integer): boolean;
begin
  Result := Funvan_Specified;
end;

procedure eFaturaKullaniciExtended.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function eFaturaKullaniciExtended.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure eFaturaKullaniciExtended.SeteFaturaKayitliKullaniciHistoryList(Index: Integer; const AArray_Of_eFaturaKayitliKullaniciHistory: Array_Of_eFaturaKayitliKullaniciHistory);
begin
  FeFaturaKayitliKullaniciHistoryList := AArray_Of_eFaturaKayitliKullaniciHistory;
  FeFaturaKayitliKullaniciHistoryList_Specified := True;
end;

function eFaturaKullaniciExtended.eFaturaKayitliKullaniciHistoryList_Specified(Index: Integer): boolean;
begin
  Result := FeFaturaKayitliKullaniciHistoryList_Specified;
end;

procedure gidenBelgeDurum.Setaciklama(Index: Integer; const Astring: string);
begin
  Faciklama := Astring;
  Faciklama_Specified := True;
end;

function gidenBelgeDurum.aciklama_Specified(Index: Integer): boolean;
begin
  Result := Faciklama_Specified;
end;

procedure gidenBelgeDurum.SetalimTarihi(Index: Integer; const Astring: string);
begin
  FalimTarihi := Astring;
  FalimTarihi_Specified := True;
end;

function gidenBelgeDurum.alimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FalimTarihi_Specified;
end;

procedure gidenBelgeDurum.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gidenBelgeDurum.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gidenBelgeDurum.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gidenBelgeDurum.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gidenBelgeDurum.SetgonderimCevabiDetayi(Index: Integer; const Astring: string);
begin
  FgonderimCevabiDetayi := Astring;
  FgonderimCevabiDetayi_Specified := True;
end;

function gidenBelgeDurum.gonderimCevabiDetayi_Specified(Index: Integer): boolean;
begin
  Result := FgonderimCevabiDetayi_Specified;
end;

procedure gidenBelgeDurum.SetgonderimTarihi(Index: Integer; const Astring: string);
begin
  FgonderimTarihi := Astring;
  FgonderimTarihi_Specified := True;
end;

function gidenBelgeDurum.gonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FgonderimTarihi_Specified;
end;

procedure gidenBelgeDurum.SetolusturulmaTarihi(Index: Integer; const Astring: string);
begin
  FolusturulmaTarihi := Astring;
  FolusturulmaTarihi_Specified := True;
end;

function gidenBelgeDurum.olusturulmaTarihi_Specified(Index: Integer): boolean;
begin
  Result := FolusturulmaTarihi_Specified;
end;

procedure gidenBelgeDurum.SetyanitDetayi(Index: Integer; const Astring: string);
begin
  FyanitDetayi := Astring;
  FyanitDetayi_Specified := True;
end;

function gidenBelgeDurum.yanitDetayi_Specified(Index: Integer): boolean;
begin
  Result := FyanitDetayi_Specified;
end;

procedure gidenBelgeDurum.SetyanitTarihi(Index: Integer; const Astring: string);
begin
  FyanitTarihi := Astring;
  FyanitTarihi_Specified := True;
end;

function gidenBelgeDurum.yanitTarihi_Specified(Index: Integer): boolean;
begin
  Result := FyanitTarihi_Specified;
end;

procedure gidenBelgeDurumv3.SetyerelBelgeOid(Index: Integer; const Astring: string);
begin
  FyerelBelgeOid := Astring;
  FyerelBelgeOid_Specified := True;
end;

function gidenBelgeDurumv3.yerelBelgeOid_Specified(Index: Integer): boolean;
begin
  Result := FyerelBelgeOid_Specified;
end;

procedure gidenBelgeDurumv4.SetgtbFiiliIhracatTarihi(Index: Integer; const Astring: string);
begin
  FgtbFiiliIhracatTarihi := Astring;
  FgtbFiiliIhracatTarihi_Specified := True;
end;

function gidenBelgeDurumv4.gtbFiiliIhracatTarihi_Specified(Index: Integer): boolean;
begin
  Result := FgtbFiiliIhracatTarihi_Specified;
end;

procedure gidenBelgeDurumv4.SetgtbGcbTescilNo(Index: Integer; const Astring: string);
begin
  FgtbGcbTescilNo := Astring;
  FgtbGcbTescilNo_Specified := True;
end;

function gidenBelgeDurumv4.gtbGcbTescilNo_Specified(Index: Integer): boolean;
begin
  Result := FgtbGcbTescilNo_Specified;
end;

procedure gidenBelgeDurumv4.SetgtbRefNo(Index: Integer; const Astring: string);
begin
  FgtbRefNo := Astring;
  FgtbRefNo_Specified := True;
end;

function gidenBelgeDurumv4.gtbRefNo_Specified(Index: Integer): boolean;
begin
  Result := FgtbRefNo_Specified;
end;

procedure gidenBelgeDurumv5.SetyanitEttn(Index: Integer; const Astring: string);
begin
  FyanitEttn := Astring;
  FyanitEttn_Specified := True;
end;

function gidenBelgeDurumv5.yanitEttn_Specified(Index: Integer): boolean;
begin
  Result := FyanitEttn_Specified;
end;

procedure gidenBelgeDurumv5.SetyanitVerilenBelgeEttn(Index: Integer; const Astring: string);
begin
  FyanitVerilenBelgeEttn := Astring;
  FyanitVerilenBelgeEttn_Specified := True;
end;

function gidenBelgeDurumv5.yanitVerilenBelgeEttn_Specified(Index: Integer): boolean;
begin
  Result := FyanitVerilenBelgeEttn_Specified;
end;

procedure gidenBelgeDurumv6.SetkepDurum(Index: Integer; const Astring: string);
begin
  FkepDurum := Astring;
  FkepDurum_Specified := True;
end;

function gidenBelgeDurumv6.kepDurum_Specified(Index: Integer): boolean;
begin
  Result := FkepDurum_Specified;
end;

destructor kontorAzaltResp.Destroy;
begin
  SysUtils.FreeAndNil(Fmiktar);
  inherited Destroy;
end;

procedure kontorAzaltResp.SetkontorTipi(Index: Integer; const Astring: string);
begin
  FkontorTipi := Astring;
  FkontorTipi_Specified := True;
end;

function kontorAzaltResp.kontorTipi_Specified(Index: Integer): boolean;
begin
  Result := FkontorTipi_Specified;
end;

procedure kontorAzaltResp.Setmiktar(Index: Integer; const ATXSDecimal: TXSDecimal);
begin
  Fmiktar := ATXSDecimal;
  Fmiktar_Specified := True;
end;

function kontorAzaltResp.miktar_Specified(Index: Integer): boolean;
begin
  Result := Fmiktar_Specified;
end;

procedure kontorAzaltResp.Setvkn(Index: Integer; const Astring: string);
begin
  Fvkn := Astring;
  Fvkn_Specified := True;
end;

function kontorAzaltResp.vkn_Specified(Index: Integer): boolean;
begin
  Result := Fvkn_Specified;
end;

procedure kayitliKullaniciListeleExtendedTime2.SetkayitZamani(Index: Integer; const Astring: string);
begin
  FkayitZamani := Astring;
  FkayitZamani_Specified := True;
end;

function kayitliKullaniciListeleExtendedTime2.kayitZamani_Specified(Index: Integer): boolean;
begin
  Result := FkayitZamani_Specified;
end;

procedure kayitliKullaniciListeleExtendedTime2.Seturun(Index: Integer; const Astring: string);
begin
  Furun := Astring;
  Furun_Specified := True;
end;

function kayitliKullaniciListeleExtendedTime2.urun_Specified(Index: Integer): boolean;
begin
  Result := Furun_Specified;
end;

procedure kayitliKullaniciListeleExtendedTime2.SetgecmisEklensin(Index: Integer; const AInteger: Integer);
begin
  FgecmisEklensin := AInteger;
  FgecmisEklensin_Specified := True;
end;

function kayitliKullaniciListeleExtendedTime2.gecmisEklensin_Specified(Index: Integer): boolean;
begin
  Result := FgecmisEklensin_Specified;
end;

procedure gelenBelgeDurum.SetalimTarihi(Index: Integer; const Astring: string);
begin
  FalimTarihi := Astring;
  FalimTarihi_Specified := True;
end;

function gelenBelgeDurum.alimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FalimTarihi_Specified;
end;

procedure gelenBelgeDurum.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gelenBelgeDurum.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gelenBelgeDurum.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gelenBelgeDurum.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gelenBelgeDurum.SetyanitDetayi(Index: Integer; const Astring: string);
begin
  FyanitDetayi := Astring;
  FyanitDetayi_Specified := True;
end;

function gelenBelgeDurum.yanitDetayi_Specified(Index: Integer): boolean;
begin
  Result := FyanitDetayi_Specified;
end;

procedure gelenBelgeDurum.SetyanitGonderimCevabiDetayi(Index: Integer; const Astring: string);
begin
  FyanitGonderimCevabiDetayi := Astring;
  FyanitGonderimCevabiDetayi_Specified := True;
end;

function gelenBelgeDurum.yanitGonderimCevabiDetayi_Specified(Index: Integer): boolean;
begin
  Result := FyanitGonderimCevabiDetayi_Specified;
end;

procedure gelenBelgeDurum.SetyanitGonderimTarihi(Index: Integer; const Astring: string);
begin
  FyanitGonderimTarihi := Astring;
  FyanitGonderimTarihi_Specified := True;
end;

function gelenBelgeDurum.yanitGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FyanitGonderimTarihi_Specified;
end;

procedure gelenBelgeDurumv3.SetkepDurum(Index: Integer; const Astring: string);
begin
  FkepDurum := Astring;
  FkepDurum_Specified := True;
end;

function gelenBelgeDurumv3.kepDurum_Specified(Index: Integer): boolean;
begin
  Result := FkepDurum_Specified;
end;

procedure gelenBelgeDurumv4.SetgibIptalDurum(Index: Integer; const Astring: string);
begin
  FgibIptalDurum := Astring;
  FgibIptalDurum_Specified := True;
end;

function gelenBelgeDurumv4.gibIptalDurum_Specified(Index: Integer): boolean;
begin
  Result := FgibIptalDurum_Specified;
end;

procedure gelenBelgeDurumv5.SetyanitEttn(Index: Integer; const Astring: string);
begin
  FyanitEttn := Astring;
  FyanitEttn_Specified := True;
end;

function gelenBelgeDurumv5.yanitEttn_Specified(Index: Integer): boolean;
begin
  Result := FyanitEttn_Specified;
end;

procedure gidenBelgeleriIndirPortalResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gidenBelgeleriIndirPortalResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor gidenBelgeleriListele2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gidenBelgeleriListele2.Setparametreler(Index: Integer; const AgidenBelgeleriListeleParametreleri: gidenBelgeleriListeleParametreleri);
begin
  Fparametreler := AgidenBelgeleriListeleParametreleri;
  Fparametreler_Specified := True;
end;

function gidenBelgeleriListele2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure gidenBelgeleriListeleParametreleri.SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbaslangicGonderimTarihi := Astring;
  FbaslangicGonderimTarihi_Specified := True;
end;

function gidenBelgeleriListeleParametreleri.baslangicGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbaslangicGonderimTarihi_Specified;
end;

procedure gidenBelgeleriListeleParametreleri.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeleriListeleParametreleri.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriListeleParametreleri.SetbitisGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbitisGonderimTarihi := Astring;
  FbitisGonderimTarihi_Specified := True;
end;

function gidenBelgeleriListeleParametreleri.bitisGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbitisGonderimTarihi_Specified;
end;

procedure gidenBelgeleriListeleParametreleri.Setvkn(Index: Integer; const Astring: string);
begin
  Fvkn := Astring;
  Fvkn_Specified := True;
end;

function gidenBelgeleriListeleParametreleri.vkn_Specified(Index: Integer): boolean;
begin
  Result := Fvkn_Specified;
end;

procedure gelenBelgeleriIndirExtResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gelenBelgeleriIndirExtResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor gelenBelgeleriIndirExt2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gelenBelgeleriIndirExt2.Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
begin
  Fparametreler := AgelenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function gelenBelgeleriIndirExt2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

destructor gidenBelgeleriListelePortal2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gidenBelgeleriListelePortal2.Setparametreler(Index: Integer; const AgidenBelgeleriListelePortalParametreleri: gidenBelgeleriListelePortalParametreleri);
begin
  Fparametreler := AgidenBelgeleriListelePortalParametreleri;
  Fparametreler_Specified := True;
end;

function gidenBelgeleriListelePortal2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbaslangicGonderimTarihi := Astring;
  FbaslangicGonderimTarihi_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.baslangicGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbaslangicGonderimTarihi_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetbelgeEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FbelgeEttnListesi := AefaturaKullaniciListesi2;
  FbelgeEttnListesi_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.belgeEttnListesi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeEttnListesi_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetbitisGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbitisGonderimTarihi := Astring;
  FbitisGonderimTarihi_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.bitisGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbitisGonderimTarihi_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetfaturaBaslangicTarihi(Index: Integer; const Astring: string);
begin
  FfaturaBaslangicTarihi := Astring;
  FfaturaBaslangicTarihi_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.faturaBaslangicTarihi_Specified(Index: Integer): boolean;
begin
  Result := FfaturaBaslangicTarihi_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetfaturaBitisTarihi(Index: Integer; const Astring: string);
begin
  FfaturaBitisTarihi := Astring;
  FfaturaBitisTarihi_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.faturaBitisTarihi_Specified(Index: Integer): boolean;
begin
  Result := FfaturaBitisTarihi_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.Setkaynak(Index: Integer; const Astring: string);
begin
  Fkaynak := Astring;
  Fkaynak_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.kaynak_Specified(Index: Integer): boolean;
begin
  Result := Fkaynak_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetpageCount(Index: Integer; const Astring: string);
begin
  FpageCount := Astring;
  FpageCount_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.pageCount_Specified(Index: Integer): boolean;
begin
  Result := FpageCount_Specified;
end;

procedure gidenBelgeleriListelePortalParametreleri.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeleriListelePortalParametreleri.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenFaturalariArsiveKaldir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenFaturalariArsiveKaldir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenFaturalariArsiveKaldir2.SetinvoiceEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FinvoiceEttnListesi := AefaturaKullaniciListesi2;
  FinvoiceEttnListesi_Specified := True;
end;

function gelenFaturalariArsiveKaldir2.invoiceEttnListesi_Specified(Index: Integer): boolean;
begin
  Result := FinvoiceEttnListesi_Specified;
end;

procedure irsaliyeTarihcesiSorgula2.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function irsaliyeTarihcesiSorgula2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure irsaliyeTarihcesiSorgula2.SetirasliyeYonu(Index: Integer; const Astring: string);
begin
  FirasliyeYonu := Astring;
  FirasliyeYonu_Specified := True;
end;

function irsaliyeTarihcesiSorgula2.irasliyeYonu_Specified(Index: Integer): boolean;
begin
  Result := FirasliyeYonu_Specified;
end;

procedure irsaliyeTarihcesiSorgula2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function irsaliyeTarihcesiSorgula2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure faturaNoUretResponse2.Setreturn(Index: Integer; const Astring: string);
begin
  Freturn := Astring;
  Freturn_Specified := True;
end;

function faturaNoUretResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gidenBelgeDurumSorgulaEttn2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeDurumSorgulaEttn2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeDurumSorgulaEttn2.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gidenBelgeDurumSorgulaEttn2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure faturaNoUret2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function faturaNoUret2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure faturaNoUret2.SetfaturaKodu(Index: Integer; const Astring: string);
begin
  FfaturaKodu := Astring;
  FfaturaKodu_Specified := True;
end;

function faturaNoUret2.faturaKodu_Specified(Index: Integer): boolean;
begin
  Result := FfaturaKodu_Specified;
end;

procedure belgelerAlindiEntegrasyonSiparisNoGuncelle2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function belgelerAlindiEntegrasyonSiparisNoGuncelle2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgelerAlindiEntegrasyonSiparisNoGuncelle2.Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettn := AefaturaKullaniciListesi2;
  Fettn_Specified := True;
end;

function belgelerAlindiEntegrasyonSiparisNoGuncelle2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure belgelerAlindiEntegrasyonSiparisNoGuncelle2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belgelerAlindiEntegrasyonSiparisNoGuncelle2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belgelerAlindiEntegrasyonSiparisNoGuncelle2.SetentegrasyonHedefi(Index: Integer; const Astring: string);
begin
  FentegrasyonHedefi := Astring;
  FentegrasyonHedefi_Specified := True;
end;

function belgelerAlindiEntegrasyonSiparisNoGuncelle2.entegrasyonHedefi_Specified(Index: Integer): boolean;
begin
  Result := FentegrasyonHedefi_Specified;
end;

procedure belgelerAlindiEntegrasyonSiparisNoGuncelle2.SetguncellenmisSiparisNumarasi(Index: Integer; const Astring: string);
begin
  FguncellenmisSiparisNumarasi := Astring;
  FguncellenmisSiparisNumarasi_Specified := True;
end;

function belgelerAlindiEntegrasyonSiparisNoGuncelle2.guncellenmisSiparisNumarasi_Specified(Index: Integer): boolean;
begin
  Result := FguncellenmisSiparisNumarasi_Specified;
end;

procedure temelKontrollerIleBelgeGonder2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function temelKontrollerIleBelgeGonder2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure temelKontrollerIleBelgeGonder2.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function temelKontrollerIleBelgeGonder2.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure temelKontrollerIleBelgeGonder2.Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fveri := ATByteDynArray;
  Fveri_Specified := True;
end;

function temelKontrollerIleBelgeGonder2.veri_Specified(Index: Integer): boolean;
begin
  Result := Fveri_Specified;
end;

procedure temelKontrollerIleBelgeGonder2.SetbelgeHash(Index: Integer; const Astring: string);
begin
  FbelgeHash := Astring;
  FbelgeHash_Specified := True;
end;

function temelKontrollerIleBelgeGonder2.belgeHash_Specified(Index: Integer): boolean;
begin
  Result := FbelgeHash_Specified;
end;

procedure temelKontrollerIleBelgeGonder2.SetmimeType(Index: Integer; const Astring: string);
begin
  FmimeType := Astring;
  FmimeType_Specified := True;
end;

function temelKontrollerIleBelgeGonder2.mimeType_Specified(Index: Integer): boolean;
begin
  Result := FmimeType_Specified;
end;

procedure temelKontrollerIleBelgeGonder2.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function temelKontrollerIleBelgeGonder2.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

procedure temelKontrollerIleBelgeGonderResponse2.SetbelgeOid(Index: Integer; const Astring: string);
begin
  FbelgeOid := Astring;
  FbelgeOid_Specified := True;
end;

function temelKontrollerIleBelgeGonderResponse2.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

destructor gidenBelgeDurumSorgulaEttnResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure gidenBelgeDurumSorgulaEttnResponse2.Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
begin
  Freturn := AgidenBelgeDurum;
  Freturn_Specified := True;
end;

function gidenBelgeDurumSorgulaEttnResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor gelenBelgeleriListeleExt2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gelenBelgeleriListeleExt2.Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
begin
  Fparametreler := AgelenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function gelenBelgeleriListeleExt2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure gidenBelgeDurumSorgulaBelgeNo2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeDurumSorgulaBelgeNo2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeDurumSorgulaBelgeNo2.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function gidenBelgeDurumSorgulaBelgeNo2.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure gidenBelgeDurumSorgulaBelgeNo2.Seturun(Index: Integer; const Astring: string);
begin
  Furun := Astring;
  Furun_Specified := True;
end;

function gidenBelgeDurumSorgulaBelgeNo2.urun_Specified(Index: Integer): boolean;
begin
  Result := Furun_Specified;
end;

destructor gidenBelgeDurumSorgulaBelgeNoResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure gidenBelgeDurumSorgulaBelgeNoResponse2.Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
begin
  Freturn := AgidenBelgeDurum;
  Freturn_Specified := True;
end;

function gidenBelgeDurumSorgulaBelgeNoResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gelenBelgeleriIndirResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gelenBelgeleriIndirResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure ublOnizlemeResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function ublOnizlemeResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gelenBelgeleriIndir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeleriIndir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenBelgeleriIndir2.Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettnler := AefaturaKullaniciListesi2;
  Fettnler_Specified := True;
end;

function gelenBelgeleriIndir2.ettnler_Specified(Index: Integer): boolean;
begin
  Result := Fettnler_Specified;
end;

procedure gelenBelgeleriIndir2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeleriIndir2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gelenBelgeleriIndir2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function gelenBelgeleriIndir2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure gelenTamamlananRapolariAlResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gelenTamamlananRapolariAlResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure belgeleriTekrarGonderYerelBelgeNo2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function belgeleriTekrarGonderYerelBelgeNo2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgeleriTekrarGonderYerelBelgeNo2.SetyerelBelgeNo(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FyerelBelgeNo := AefaturaKullaniciListesi2;
  FyerelBelgeNo_Specified := True;
end;

function belgeleriTekrarGonderYerelBelgeNo2.yerelBelgeNo_Specified(Index: Integer): boolean;
begin
  Result := FyerelBelgeNo_Specified;
end;

procedure belgeleriTekrarGonderYerelBelgeNo2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belgeleriTekrarGonderYerelBelgeNo2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belgeleriTekrarGonderYerelBelgeNo2.SetalanEtiket(Index: Integer; const Astring: string);
begin
  FalanEtiket := Astring;
  FalanEtiket_Specified := True;
end;

function belgeleriTekrarGonderYerelBelgeNo2.alanEtiket_Specified(Index: Integer): boolean;
begin
  Result := FalanEtiket_Specified;
end;

procedure belgeleriTekrarGonderYerelBelgeNo2.SetgonderenEtiket(Index: Integer; const Astring: string);
begin
  FgonderenEtiket := Astring;
  FgonderenEtiket_Specified := True;
end;

function belgeleriTekrarGonderYerelBelgeNo2.gonderenEtiket_Specified(Index: Integer): boolean;
begin
  Result := FgonderenEtiket_Specified;
end;

procedure gelenTamamlananRapolariAl2.SetgonderenVknTckn(Index: Integer; const Astring: string);
begin
  FgonderenVknTckn := Astring;
  FgonderenVknTckn_Specified := True;
end;

function gelenTamamlananRapolariAl2.gonderenVknTckn_Specified(Index: Integer): boolean;
begin
  Result := FgonderenVknTckn_Specified;
end;

procedure gelenTamamlananRapolariAl2.SetaliciVknTckn(Index: Integer; const Astring: string);
begin
  FaliciVknTckn := Astring;
  FaliciVknTckn_Specified := True;
end;

function gelenTamamlananRapolariAl2.aliciVknTckn_Specified(Index: Integer): boolean;
begin
  Result := FaliciVknTckn_Specified;
end;

procedure gelenTamamlananRapolariAl2.SetgelisBasTarihi(Index: Integer; const Astring: string);
begin
  FgelisBasTarihi := Astring;
  FgelisBasTarihi_Specified := True;
end;

function gelenTamamlananRapolariAl2.gelisBasTarihi_Specified(Index: Integer): boolean;
begin
  Result := FgelisBasTarihi_Specified;
end;

procedure gelenTamamlananRapolariAl2.SetgelisBitTarihi(Index: Integer; const Astring: string);
begin
  FgelisBitTarihi := Astring;
  FgelisBitTarihi_Specified := True;
end;

function gelenTamamlananRapolariAl2.gelisBitTarihi_Specified(Index: Integer): boolean;
begin
  Result := FgelisBitTarihi_Specified;
end;

procedure belgeleriTekrarGonderBelgeOid2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function belgeleriTekrarGonderBelgeOid2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgeleriTekrarGonderBelgeOid2.SetbelgeOid(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FbelgeOid := AefaturaKullaniciListesi2;
  FbelgeOid_Specified := True;
end;

function belgeleriTekrarGonderBelgeOid2.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

procedure belgeleriTekrarGonderBelgeOid2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belgeleriTekrarGonderBelgeOid2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belgeleriTekrarGonderBelgeOid2.SetalanEtiket(Index: Integer; const Astring: string);
begin
  FalanEtiket := Astring;
  FalanEtiket_Specified := True;
end;

function belgeleriTekrarGonderBelgeOid2.alanEtiket_Specified(Index: Integer): boolean;
begin
  Result := FalanEtiket_Specified;
end;

procedure belgeleriTekrarGonderBelgeOid2.SetgonderenEtiket(Index: Integer; const Astring: string);
begin
  FgonderenEtiket := Astring;
  FgonderenEtiket_Specified := True;
end;

function belgeleriTekrarGonderBelgeOid2.gonderenEtiket_Specified(Index: Integer): boolean;
begin
  Result := FgonderenEtiket_Specified;
end;

procedure ublOnizleme2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function ublOnizleme2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure ublOnizleme2.Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fveri := ATByteDynArray;
  Fveri_Specified := True;
end;

function ublOnizleme2.veri_Specified(Index: Integer): boolean;
begin
  Result := Fveri_Specified;
end;

procedure ublOnizleme2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function ublOnizleme2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure ublOnizleme2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function ublOnizleme2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gelenBelgeXmlleriniAl2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeXmlleriniAl2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenBelgeXmlleriniAl2.Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettnler := AefaturaKullaniciListesi2;
  Fettnler_Specified := True;
end;

function gelenBelgeXmlleriniAl2.ettnler_Specified(Index: Integer): boolean;
begin
  Result := Fettnler_Specified;
end;

procedure gelenBelgeXmlleriniAl2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeXmlleriniAl2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

destructor belgeGonderExtWithValidateResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure belgeGonderExtWithValidateResponse2.Setreturn(Index: Integer; const AbelgeGonderResp: belgeGonderResp);
begin
  Freturn := AbelgeGonderResp;
  Freturn_Specified := True;
end;

function belgeGonderExtWithValidateResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor belgeGonderExtWithValidate2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure belgeGonderExtWithValidate2.Setparametreler(Index: Integer; const AgidenBelgeParametreleri: gidenBelgeParametreleri);
begin
  Fparametreler := AgidenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function belgeGonderExtWithValidate2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure eIrsaliyeKayitliKullaniciListele2.SetkayitZamani(Index: Integer; const Astring: string);
begin
  FkayitZamani := Astring;
  FkayitZamani_Specified := True;
end;

function eIrsaliyeKayitliKullaniciListele2.kayitZamani_Specified(Index: Integer): boolean;
begin
  Result := FkayitZamani_Specified;
end;

procedure wsKullaniciBilgileri.SetkullaniciKodu(Index: Integer; const Astring: string);
begin
  FkullaniciKodu := Astring;
  FkullaniciKodu_Specified := True;
end;

function wsKullaniciBilgileri.kullaniciKodu_Specified(Index: Integer): boolean;
begin
  Result := FkullaniciKodu_Specified;
end;

procedure wsKullaniciBilgileri.Setsifre(Index: Integer; const Astring: string);
begin
  Fsifre := Astring;
  Fsifre_Specified := True;
end;

function wsKullaniciBilgileri.sifre_Specified(Index: Integer): boolean;
begin
  Result := Fsifre_Specified;
end;

procedure wsKullanicisiKaydet2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function wsKullanicisiKaydet2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure wsKullanicisiKaydet2.SeturunList(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FurunList := AefaturaKullaniciListesi2;
  FurunList_Specified := True;
end;

function wsKullanicisiKaydet2.urunList_Specified(Index: Integer): boolean;
begin
  Result := FurunList_Specified;
end;

procedure wsKullanicisiKaydet2.SeterpKodu(Index: Integer; const Astring: string);
begin
  FerpKodu := Astring;
  FerpKodu_Specified := True;
end;

function wsKullanicisiKaydet2.erpKodu_Specified(Index: Integer): boolean;
begin
  Result := FerpKodu_Specified;
end;

destructor wsKullanicisiKaydetResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure wsKullanicisiKaydetResponse2.Setreturn(Index: Integer; const AwsKullaniciBilgileri: wsKullaniciBilgileri);
begin
  Freturn := AwsKullaniciBilgileri;
  Freturn_Specified := True;
end;

function wsKullanicisiKaydetResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure kayitliKullaniciListeleExtendedVknTcknResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function kayitliKullaniciListeleExtendedVknTcknResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure kayitliKullaniciListeleExtendedVknTckn2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function kayitliKullaniciListeleExtendedVknTckn2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure kayitliKullaniciListeleExtendedVknTckn2.Seturun(Index: Integer; const Astring: string);
begin
  Furun := Astring;
  Furun_Specified := True;
end;

function kayitliKullaniciListeleExtendedVknTckn2.urun_Specified(Index: Integer): boolean;
begin
  Result := Furun_Specified;
end;

procedure yolcuBeraberFaturaIptalEt2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function yolcuBeraberFaturaIptalEt2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure yolcuBeraberFaturaIptalEt2.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function yolcuBeraberFaturaIptalEt2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure yolcuBeraberFaturaIptalEt2.SetseriSiraNo(Index: Integer; const Astring: string);
begin
  FseriSiraNo := Astring;
  FseriSiraNo_Specified := True;
end;

function yolcuBeraberFaturaIptalEt2.seriSiraNo_Specified(Index: Integer): boolean;
begin
  Result := FseriSiraNo_Specified;
end;

procedure yolcuBeraberFaturaIptalEt2.SetpusulaTarihi(Index: Integer; const Astring: string);
begin
  FpusulaTarihi := Astring;
  FpusulaTarihi_Specified := True;
end;

function yolcuBeraberFaturaIptalEt2.pusulaTarihi_Specified(Index: Integer): boolean;
begin
  Result := FpusulaTarihi_Specified;
end;

procedure yolcuBeraberFaturaIptalEt2.SetbelgeOid(Index: Integer; const Astring: string);
begin
  FbelgeOid := Astring;
  FbelgeOid_Specified := True;
end;

function yolcuBeraberFaturaIptalEt2.belgeOid_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOid_Specified;
end;

procedure belgeleriTekrarGonder2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function belgeleriTekrarGonder2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgeleriTekrarGonder2.Setettn(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettn := AefaturaKullaniciListesi2;
  Fettn_Specified := True;
end;

function belgeleriTekrarGonder2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure belgeleriTekrarGonder2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belgeleriTekrarGonder2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belgeleriTekrarGonder2.SetalanEtiket(Index: Integer; const Astring: string);
begin
  FalanEtiket := Astring;
  FalanEtiket_Specified := True;
end;

function belgeleriTekrarGonder2.alanEtiket_Specified(Index: Integer): boolean;
begin
  Result := FalanEtiket_Specified;
end;

procedure belgeleriTekrarGonder2.SetgonderenEtiket(Index: Integer; const Astring: string);
begin
  FgonderenEtiket := Astring;
  FgonderenEtiket_Specified := True;
end;

function belgeleriTekrarGonder2.gonderenEtiket_Specified(Index: Integer): boolean;
begin
  Result := FgonderenEtiket_Specified;
end;

destructor gelenBelgeleriAlExt22.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(Fparametreler)-1 do
    SysUtils.FreeAndNil(Fparametreler[I]);
  System.SetLength(Fparametreler, 0);
  inherited Destroy;
end;

procedure gelenBelgeleriAlExt22.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeleriAlExt22.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenBelgeleriAlExt22.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeleriAlExt22.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure entry2.Setkey(Index: Integer; const Astring: string);
begin
  Fkey := Astring;
  Fkey_Specified := True;
end;

function entry2.key_Specified(Index: Integer): boolean;
begin
  Result := Fkey_Specified;
end;

procedure entry2.Setvalue(Index: Integer; const Astring: string);
begin
  Fvalue := Astring;
  Fvalue_Specified := True;
end;

function entry2.value_Specified(Index: Integer): boolean;
begin
  Result := Fvalue_Specified;
end;

destructor kalanKontorBilgisi.Destroy;
begin
  SysUtils.FreeAndNil(Fkalan);
  SysUtils.FreeAndNil(FlimitAsimMiktari);
  SysUtils.FreeAndNil(FtoplamAlinan);
  inherited Destroy;
end;

procedure kalanKontorBilgisi.Setkalan(Index: Integer; const ATXSDecimal: TXSDecimal);
begin
  Fkalan := ATXSDecimal;
  Fkalan_Specified := True;
end;

function kalanKontorBilgisi.kalan_Specified(Index: Integer): boolean;
begin
  Result := Fkalan_Specified;
end;

procedure kalanKontorBilgisi.SetkontorBirimi(Index: Integer; const AkontorBirimi: kontorBirimi);
begin
  FkontorBirimi := AkontorBirimi;
  FkontorBirimi_Specified := True;
end;

function kalanKontorBilgisi.kontorBirimi_Specified(Index: Integer): boolean;
begin
  Result := FkontorBirimi_Specified;
end;

procedure kalanKontorBilgisi.SetkontorTipi(Index: Integer; const AkontorTipi: kontorTipi);
begin
  FkontorTipi := AkontorTipi;
  FkontorTipi_Specified := True;
end;

function kalanKontorBilgisi.kontorTipi_Specified(Index: Integer): boolean;
begin
  Result := FkontorTipi_Specified;
end;

procedure kalanKontorBilgisi.SetlimitAsimMiktari(Index: Integer; const ATXSDecimal: TXSDecimal);
begin
  FlimitAsimMiktari := ATXSDecimal;
  FlimitAsimMiktari_Specified := True;
end;

function kalanKontorBilgisi.limitAsimMiktari_Specified(Index: Integer): boolean;
begin
  Result := FlimitAsimMiktari_Specified;
end;

procedure kalanKontorBilgisi.SettoplamAlinan(Index: Integer; const ATXSDecimal: TXSDecimal);
begin
  FtoplamAlinan := ATXSDecimal;
  FtoplamAlinan_Specified := True;
end;

function kalanKontorBilgisi.toplamAlinan_Specified(Index: Integer): boolean;
begin
  Result := FtoplamAlinan_Specified;
end;

procedure kalanKontorBilgisi.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function kalanKontorBilgisi.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure kontorBilgisiGetir2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function kontorBilgisiGetir2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure kontorBilgisiGetir2.SetkontorTipi(Index: Integer; const Astring: string);
begin
  FkontorTipi := Astring;
  FkontorTipi_Specified := True;
end;

function kontorBilgisiGetir2.kontorTipi_Specified(Index: Integer): boolean;
begin
  Result := FkontorTipi_Specified;
end;

procedure kontorBilgisiGetir2.SetkontorBirimi(Index: Integer; const Astring: string);
begin
  FkontorBirimi := Astring;
  FkontorBirimi_Specified := True;
end;

function kontorBilgisiGetir2.kontorBirimi_Specified(Index: Integer): boolean;
begin
  Result := FkontorBirimi_Specified;
end;

destructor kontorBilgisiGetirResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure kontorBilgisiGetirResponse2.Setreturn(Index: Integer; const AkalanKontorBilgisi: kalanKontorBilgisi);
begin
  Freturn := AkalanKontorBilgisi;
  Freturn_Specified := True;
end;

function kontorBilgisiGetirResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor gelenBelgeDurumSorgulaResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure gelenBelgeDurumSorgulaResponse2.Setreturn(Index: Integer; const AserviceReturnType2: serviceReturnType2);
begin
  Freturn := AserviceReturnType2;
  Freturn_Specified := True;
end;

function gelenBelgeDurumSorgulaResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure faturaMailGonder2.SetvknTckn(Index: Integer; const Astring: string);
begin
  FvknTckn := Astring;
  FvknTckn_Specified := True;
end;

function faturaMailGonder2.vknTckn_Specified(Index: Integer): boolean;
begin
  Result := FvknTckn_Specified;
end;

procedure faturaMailGonder2.SetinOut(Index: Integer; const Astring: string);
begin
  FinOut := Astring;
  FinOut_Specified := True;
end;

function faturaMailGonder2.inOut_Specified(Index: Integer): boolean;
begin
  Result := FinOut_Specified;
end;

procedure faturaMailGonder2.SetUUID(Index: Integer; const Astring: string);
begin
  FUUID := Astring;
  FUUID_Specified := True;
end;

function faturaMailGonder2.UUID_Specified(Index: Integer): boolean;
begin
  Result := FUUID_Specified;
end;

procedure faturaMailGonder2.SetfaturaNo(Index: Integer; const Astring: string);
begin
  FfaturaNo := Astring;
  FfaturaNo_Specified := True;
end;

function faturaMailGonder2.faturaNo_Specified(Index: Integer): boolean;
begin
  Result := FfaturaNo_Specified;
end;

procedure faturaMailGonder2.Setalicilar(Index: Integer; const Astring: string);
begin
  Falicilar := Astring;
  Falicilar_Specified := True;
end;

function faturaMailGonder2.alicilar_Specified(Index: Integer): boolean;
begin
  Result := Falicilar_Specified;
end;

procedure faturaMailGonder2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function faturaMailGonder2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure gelenBelgeDurumSorgula2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenBelgeDurumSorgula2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenBelgeDurumSorgula2.Setettn(Index: Integer; const Astring: string);
begin
  Fettn := Astring;
  Fettn_Specified := True;
end;

function gelenBelgeDurumSorgula2.ettn_Specified(Index: Integer): boolean;
begin
  Result := Fettn_Specified;
end;

procedure gelenBelgeDurumSorgula2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gelenBelgeDurumSorgula2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriIndir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeleriIndir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeleriIndir2.SetbelgeOidListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FbelgeOidListesi := AefaturaKullaniciListesi2;
  FbelgeOidListesi_Specified := True;
end;

function gidenBelgeleriIndir2.belgeOidListesi_Specified(Index: Integer): boolean;
begin
  Result := FbelgeOidListesi_Specified;
end;

procedure gidenBelgeleriIndir2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeleriIndir2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeleriIndir2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function gidenBelgeleriIndir2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure gidenBelgeleriIndirResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gidenBelgeleriIndirResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

destructor gidenBelgeDurumSorgulaYerelBelgeNoResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure gidenBelgeDurumSorgulaYerelBelgeNoResponse2.Setreturn(Index: Integer; const AgidenBelgeDurum: gidenBelgeDurum);
begin
  Freturn := AgidenBelgeDurum;
  Freturn_Specified := True;
end;

function gidenBelgeDurumSorgulaYerelBelgeNoResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gidenBelgeTutarBilgileriSorgula2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeTutarBilgileriSorgula2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeTutarBilgileriSorgula2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function gidenBelgeTutarBilgileriSorgula2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure gidenBelgeTutarBilgileriSorgula2.SetbaslangicGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbaslangicGonderimTarihi := Astring;
  FbaslangicGonderimTarihi_Specified := True;
end;

function gidenBelgeTutarBilgileriSorgula2.baslangicGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbaslangicGonderimTarihi_Specified;
end;

procedure gidenBelgeTutarBilgileriSorgula2.SetbitisGonderimTarihi(Index: Integer; const Astring: string);
begin
  FbitisGonderimTarihi := Astring;
  FbitisGonderimTarihi_Specified := True;
end;

function gidenBelgeTutarBilgileriSorgula2.bitisGonderimTarihi_Specified(Index: Integer): boolean;
begin
  Result := FbitisGonderimTarihi_Specified;
end;

procedure gidenBelgeDurumSorgulaYerelBelgeNo2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenBelgeDurumSorgulaYerelBelgeNo2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenBelgeDurumSorgulaYerelBelgeNo2.SetyerelBelgeNo(Index: Integer; const Astring: string);
begin
  FyerelBelgeNo := Astring;
  FyerelBelgeNo_Specified := True;
end;

function gidenBelgeDurumSorgulaYerelBelgeNo2.yerelBelgeNo_Specified(Index: Integer): boolean;
begin
  Result := FyerelBelgeNo_Specified;
end;

destructor gelenBelgeXmlleriniAlExt2.Destroy;
begin
  SysUtils.FreeAndNil(Fparametreler);
  inherited Destroy;
end;

procedure gelenBelgeXmlleriniAlExt2.Setparametreler(Index: Integer; const AgelenBelgeParametreleri: gelenBelgeParametreleri);
begin
  Fparametreler := AgelenBelgeParametreleri;
  Fparametreler_Specified := True;
end;

function gelenBelgeXmlleriniAlExt2.parametreler_Specified(Index: Integer): boolean;
begin
  Result := Fparametreler_Specified;
end;

procedure gelenBelgeXmlleriniAlExtResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gelenBelgeXmlleriniAlExtResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gidenFaturalariArsiveKaldir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenFaturalariArsiveKaldir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenFaturalariArsiveKaldir2.SetinvoiceEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FinvoiceEttnListesi := AefaturaKullaniciListesi2;
  FinvoiceEttnListesi_Specified := True;
end;

function gidenFaturalariArsiveKaldir2.invoiceEttnListesi_Specified(Index: Integer): boolean;
begin
  Result := FinvoiceEttnListesi_Specified;
end;

procedure gidenTasinanBelgeleriIndirResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function gidenTasinanBelgeleriIndirResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gidenTasinanBelgeleriIndir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gidenTasinanBelgeleriIndir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gidenTasinanBelgeleriIndir2.Setettnler(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  Fettnler := AefaturaKullaniciListesi2;
  Fettnler_Specified := True;
end;

function gidenTasinanBelgeleriIndir2.ettnler_Specified(Index: Integer): boolean;
begin
  Result := Fettnler_Specified;
end;

procedure gidenTasinanBelgeleriIndir2.SetbelgeFormati(Index: Integer; const Astring: string);
begin
  FbelgeFormati := Astring;
  FbelgeFormati_Specified := True;
end;

function gidenTasinanBelgeleriIndir2.belgeFormati_Specified(Index: Integer): boolean;
begin
  Result := FbelgeFormati_Specified;
end;

procedure kayitliKullaniciListeleExtendedResponse2.Setreturn(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Freturn := ATByteDynArray;
  Freturn_Specified := True;
end;

function kayitliKullaniciListeleExtendedResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

procedure gelenIrsaliyeleriArsiveKaldir2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function gelenIrsaliyeleriArsiveKaldir2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure gelenIrsaliyeleriArsiveKaldir2.SetdespatchEttnListesi(Index: Integer; const AefaturaKullaniciListesi2: efaturaKullaniciListesi2);
begin
  FdespatchEttnListesi := AefaturaKullaniciListesi2;
  FdespatchEttnListesi_Specified := True;
end;

function gelenIrsaliyeleriArsiveKaldir2.despatchEttnListesi_Specified(Index: Integer): boolean;
begin
  Result := FdespatchEttnListesi_Specified;
end;

destructor erpBilgileriBelirle2.Destroy;
begin
  SysUtils.FreeAndNil(FerpBilgileri);
  inherited Destroy;
end;

procedure erpBilgileriBelirle2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function erpBilgileriBelirle2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure erpBilgileriBelirle2.SeterpBilgileri(Index: Integer; const AerpBilgileri: erpBilgileri);
begin
  FerpBilgileri := AerpBilgileri;
  FerpBilgileri_Specified := True;
end;

function erpBilgileriBelirle2.erpBilgileri_Specified(Index: Integer): boolean;
begin
  Result := FerpBilgileri_Specified;
end;

procedure erpBilgileri.Setaciklama(Index: Integer; const Astring: string);
begin
  Faciklama := Astring;
  Faciklama_Specified := True;
end;

function erpBilgileri.aciklama_Specified(Index: Integer): boolean;
begin
  Result := Faciklama_Specified;
end;

procedure erpBilgileri.Setkod(Index: Integer; const Astring: string);
begin
  Fkod := Astring;
  Fkod_Specified := True;
end;

function erpBilgileri.kod_Specified(Index: Integer): boolean;
begin
  Result := Fkod_Specified;
end;

procedure kayitliKullaniciListeleExtended2.Seturun(Index: Integer; const Astring: string);
begin
  Furun := Astring;
  Furun_Specified := True;
end;

function kayitliKullaniciListeleExtended2.urun_Specified(Index: Integer): boolean;
begin
  Result := Furun_Specified;
end;

procedure kayitliKullaniciListeleExtended2.SetgecmisEklensin(Index: Integer; const AInteger: Integer);
begin
  FgecmisEklensin := AInteger;
  FgecmisEklensin_Specified := True;
end;

function kayitliKullaniciListeleExtended2.gecmisEklensin_Specified(Index: Integer): boolean;
begin
  Result := FgecmisEklensin_Specified;
end;

procedure efaturaKullanicisi2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function efaturaKullanicisi2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgeGonderWithValidate2.SetvergiTcKimlikNo(Index: Integer; const Astring: string);
begin
  FvergiTcKimlikNo := Astring;
  FvergiTcKimlikNo_Specified := True;
end;

function belgeGonderWithValidate2.vergiTcKimlikNo_Specified(Index: Integer): boolean;
begin
  Result := FvergiTcKimlikNo_Specified;
end;

procedure belgeGonderWithValidate2.SetbelgeTuru(Index: Integer; const Astring: string);
begin
  FbelgeTuru := Astring;
  FbelgeTuru_Specified := True;
end;

function belgeGonderWithValidate2.belgeTuru_Specified(Index: Integer): boolean;
begin
  Result := FbelgeTuru_Specified;
end;

procedure belgeGonderWithValidate2.SetbelgeNo(Index: Integer; const Astring: string);
begin
  FbelgeNo := Astring;
  FbelgeNo_Specified := True;
end;

function belgeGonderWithValidate2.belgeNo_Specified(Index: Integer): boolean;
begin
  Result := FbelgeNo_Specified;
end;

procedure belgeGonderWithValidate2.Setveri(Index: Integer; const ATByteDynArray: TByteDynArray);
begin
  Fveri := ATByteDynArray;
  Fveri_Specified := True;
end;

function belgeGonderWithValidate2.veri_Specified(Index: Integer): boolean;
begin
  Result := Fveri_Specified;
end;

procedure belgeGonderWithValidate2.SetbelgeHash(Index: Integer; const Astring: string);
begin
  FbelgeHash := Astring;
  FbelgeHash_Specified := True;
end;

function belgeGonderWithValidate2.belgeHash_Specified(Index: Integer): boolean;
begin
  Result := FbelgeHash_Specified;
end;

procedure belgeGonderWithValidate2.SetmimeType(Index: Integer; const Astring: string);
begin
  FmimeType := Astring;
  FmimeType_Specified := True;
end;

function belgeGonderWithValidate2.mimeType_Specified(Index: Integer): boolean;
begin
  Result := FmimeType_Specified;
end;

procedure belgeGonderWithValidate2.SetbelgeVersiyon(Index: Integer; const Astring: string);
begin
  FbelgeVersiyon := Astring;
  FbelgeVersiyon_Specified := True;
end;

function belgeGonderWithValidate2.belgeVersiyon_Specified(Index: Integer): boolean;
begin
  Result := FbelgeVersiyon_Specified;
end;

destructor belgeGonderWithValidateResponse2.Destroy;
begin
  SysUtils.FreeAndNil(Freturn);
  inherited Destroy;
end;

procedure belgeGonderWithValidateResponse2.Setreturn(Index: Integer; const AbelgeGonderResp: belgeGonderResp);
begin
  Freturn := AbelgeGonderResp;
  Freturn_Specified := True;
end;

function belgeGonderWithValidateResponse2.return_Specified(Index: Integer): boolean;
begin
  Result := Freturn_Specified;
end;

initialization
  { ConnectorService }
  InvRegistry.RegisterInterface(TypeInfo(ConnectorService), 'http://service.connector.uut.cs.com.tr/', 'UTF-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(ConnectorService), '');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaResponse2', 'gidenBelgeDurumSorgulaResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriListeleResponse2), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListeleResponse2', 'gelenBelgeleriListeleResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(eFaturaKayitliKullaniciListeleResponse2), 'http://service.connector.uut.cs.com.tr/', 'eFaturaKayitliKullaniciListeleResponse2', 'eFaturaKayitliKullaniciListeleResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(eFaturaKayitliKullaniciListeleResponse), 'http://service.connector.uut.cs.com.tr/', 'eFaturaKayitliKullaniciListeleResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriAlExtResponse2), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExtResponse2', 'gelenBelgeleriAlExtResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeTutarBilgileriSorgulaResponse2), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeTutarBilgileriSorgulaResponse2', 'gelenBelgeTutarBilgileriSorgulaResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeTutarBilgileriSorgulaResponse), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeTutarBilgileriSorgulaResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriAlExt3, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExt3', 'gelenBelgeleriAlExt');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Array_Of_eFaturaKayitliKullaniciHistory), 'http://service.connector.uut.cs.com.tr/', 'Array_Of_eFaturaKayitliKullaniciHistory');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriListeleResponse), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListeleResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriAlExt, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExt');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriAlExtResponse), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExtResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaResponse');
  RemClassRegistry.RegisterXSClass(irsaliyeMailGonderResponse2, 'http://service.connector.uut.cs.com.tr/', 'irsaliyeMailGonderResponse2', 'irsaliyeMailGonderResponse');
  RemClassRegistry.RegisterXSClass(irsaliyeMailGonderResponse, 'http://service.connector.uut.cs.com.tr/', 'irsaliyeMailGonderResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(cokluGidenBelgeDurumSorgulaResponse2), 'http://service.connector.uut.cs.com.tr/', 'cokluGidenBelgeDurumSorgulaResponse2', 'cokluGidenBelgeDurumSorgulaResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(cokluGidenBelgeDurumSorgulaResponse), 'http://service.connector.uut.cs.com.tr/', 'cokluGidenBelgeDurumSorgulaResponse');
  RemClassRegistry.RegisterXSClass(yereleAktarilacakBelgeleriAlExt2, 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAlExt2', 'yereleAktarilacakBelgeleriAlExt');
  RemClassRegistry.RegisterXSClass(yereleAktarilacakBelgeleriAlExt, 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAlExt');
  RemClassRegistry.RegisterXSInfo(TypeInfo(yereleAktarilacakBelgeleriAlExtResponse2), 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAlExtResponse2', 'yereleAktarilacakBelgeleriAlExtResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(yereleAktarilacakBelgeleriAlExtResponse), 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAlExtResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(faturaTarihcesiSorgulaResponse2), 'http://service.connector.uut.cs.com.tr/', 'faturaTarihcesiSorgulaResponse2', 'faturaTarihcesiSorgulaResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(faturaTarihcesiSorgulaResponse), 'http://service.connector.uut.cs.com.tr/', 'faturaTarihcesiSorgulaResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(efaturaKullaniciListesiResponse2), 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciListesiResponse2', 'efaturaKullaniciListesiResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(efaturaKullaniciListesiResponse), 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciListesiResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirPortal2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirPortal2', 'gidenBelgeleriIndirPortal');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirPortal, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirPortal');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaExtResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaExtResponse2', 'gidenBelgeDurumSorgulaExtResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaExtResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaExtResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriAlResponse2), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlResponse2', 'gelenBelgeleriAlResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriAlResponse), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlResponse');
  RemClassRegistry.RegisterXSClass(gidenIrsaliyeleriArsiveKaldirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenIrsaliyeleriArsiveKaldirResponse2', 'gidenIrsaliyeleriArsiveKaldirResponse');
  RemClassRegistry.RegisterXSClass(gidenIrsaliyeleriArsiveKaldirResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenIrsaliyeleriArsiveKaldirResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(efaturaKullaniciBilgisiResponse2), 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciBilgisiResponse2', 'efaturaKullaniciBilgisiResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(efaturaKullaniciBilgisiResponse), 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciBilgisiResponse');
  RemClassRegistry.RegisterXSClass(belgeGonderExt2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExt2', 'belgeGonderExt');
  RemClassRegistry.RegisterXSClass(belgeGonderExt, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExt');
  RemClassRegistry.RegisterXSInfo(TypeInfo(yereleAktarilacakBelgeleriAlResponse2), 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAlResponse2', 'yereleAktarilacakBelgeleriAlResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(yereleAktarilacakBelgeleriAlResponse), 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAlResponse');
  RemClassRegistry.RegisterXSClass(belgelerAlindiResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindiResponse2', 'belgelerAlindiResponse');
  RemClassRegistry.RegisterXSClass(belgelerAlindiResponse, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindiResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ekBilgiler), 'http://service.connector.uut.cs.com.tr/', 'ekBilgiler');
  RemClassRegistry.RegisterXSClass(serviceReturnType2, 'http://service.connector.uut.cs.com.tr/', 'serviceReturnType2', 'serviceReturnType');
  RemClassRegistry.RegisterXSClass(serviceReturnType, 'http://service.connector.uut.cs.com.tr/', 'serviceReturnType');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgulaExtResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgulaExtResponse2', 'gelenBelgeDurumSorgulaExtResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgulaExtResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgulaExtResponse');
  RemClassRegistry.RegisterXSClass(csXmlToUblResponse2, 'http://service.connector.uut.cs.com.tr/', 'csXmlToUblResponse2', 'csXmlToUblResponse');
  RemClassRegistry.RegisterXSClass(csXmlToUblResponse, 'http://service.connector.uut.cs.com.tr/', 'csXmlToUblResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeEkleriAlResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeEkleriAlResponse2', 'gelenBelgeEkleriAlResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeEkleriAlResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeEkleriAlResponse');
  RemClassRegistry.RegisterXSClass(gelenStandartRapolariAlResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenStandartRapolariAlResponse2', 'gelenStandartRapolariAlResponse');
  RemClassRegistry.RegisterXSClass(gelenStandartRapolariAlResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenStandartRapolariAlResponse');
  RemClassRegistry.RegisterXSClass(csXmlOnizlemeResponse2, 'http://service.connector.uut.cs.com.tr/', 'csXmlOnizlemeResponse2', 'csXmlOnizlemeResponse');
  RemClassRegistry.RegisterXSClass(csXmlOnizlemeResponse, 'http://service.connector.uut.cs.com.tr/', 'csXmlOnizlemeResponse');
  RemClassRegistry.RegisterXSClass(urunSablonlariniAlResponse2, 'http://service.connector.uut.cs.com.tr/', 'urunSablonlariniAlResponse2', 'urunSablonlariniAlResponse');
  RemClassRegistry.RegisterXSClass(urunSablonlariniAlResponse, 'http://service.connector.uut.cs.com.tr/', 'urunSablonlariniAlResponse');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedTimeResponse2, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedTimeResponse2', 'kayitliKullaniciListeleExtendedTimeResponse');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedTimeResponse, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedTimeResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeEkleriAlResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeEkleriAlResponse2', 'gidenBelgeEkleriAlResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeEkleriAlResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeEkleriAlResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirEttnResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirEttnResponse2', 'gidenBelgeleriIndirEttnResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirEttnResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirEttnResponse');
  RemClassRegistry.RegisterXSClass(belgeGonder2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonder2', 'belgeGonder');
  RemClassRegistry.RegisterXSClass(belgeGonder, 'http://service.connector.uut.cs.com.tr/', 'belgeGonder');
  RemClassRegistry.RegisterXSClass(belgeGonderResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderResponse2', 'belgeGonderResponse');
  RemClassRegistry.RegisterXSClass(belgeGonderResponse, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderResponse');
  RemClassRegistry.RegisterXSClass(belge, 'http://service.connector.uut.cs.com.tr/', 'belge');
  RemClassRegistry.RegisterXSClass(belgev2, 'http://service.connector.uut.cs.com.tr/', 'belgev2');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(belgev2), 'ekBilgiler', '[ArrayItemName="entry"]');
  RemClassRegistry.RegisterXSClass(belgev3, 'http://service.connector.uut.cs.com.tr/', 'belgev3');
  RemClassRegistry.RegisterXSClass(belgev4, 'http://service.connector.uut.cs.com.tr/', 'belgev4');
  RemClassRegistry.RegisterXSClass(belgev5, 'http://service.connector.uut.cs.com.tr/', 'belgev5');
  RemClassRegistry.RegisterXSClass(belgev6, 'http://service.connector.uut.cs.com.tr/', 'belgev6');
  RemClassRegistry.RegisterXSClass(entry, 'http://service.connector.uut.cs.com.tr/', 'entry');
  RemClassRegistry.RegisterXSClass(yereleAktarilacakBelgeleriAl2, 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAl2', 'yereleAktarilacakBelgeleriAl');
  RemClassRegistry.RegisterXSClass(yereleAktarilacakBelgeleriAl, 'http://service.connector.uut.cs.com.tr/', 'yereleAktarilacakBelgeleriAl');
  RemClassRegistry.RegisterXSClass(gidenBelgeParametreleri, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeParametreleri');
  RemClassRegistry.RegisterXSClass(efaturaKullaniciBilgisi2, 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciBilgisi2', 'efaturaKullaniciBilgisi');
  RemClassRegistry.RegisterXSClass(efaturaKullaniciBilgisi, 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciBilgisi');
  RemClassRegistry.RegisterXSClass(belgeGonderExtResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExtResponse2', 'belgeGonderExtResponse');
  RemClassRegistry.RegisterXSClass(belgeGonderExtResponse, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExtResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaExt2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaExt2', 'gidenBelgeDurumSorgulaExt');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaExt, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaExt');
  RemClassRegistry.RegisterXSClass(csXmlToUbl2, 'http://service.connector.uut.cs.com.tr/', 'csXmlToUbl2', 'csXmlToUbl');
  RemClassRegistry.RegisterXSClass(csXmlToUbl, 'http://service.connector.uut.cs.com.tr/', 'csXmlToUbl');
  RemClassRegistry.RegisterXSClass(gelenBelgeEkleriAl2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeEkleriAl2', 'gelenBelgeEkleriAl');
  RemClassRegistry.RegisterXSClass(gelenBelgeEkleriAl, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeEkleriAl');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriAl2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAl2', 'gelenBelgeleriAl');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriAl, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAl');
  RemClassRegistry.RegisterXSClass(belgeGonderResp, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderResp');
  RemClassRegistry.RegisterXSInfo(TypeInfo(efaturaKullaniciListesi2), 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciListesi2', 'efaturaKullaniciListesi');
  RemClassRegistry.RegisterXSClass(gelenTasinanBelgeleriIndir2, 'http://service.connector.uut.cs.com.tr/', 'gelenTasinanBelgeleriIndir2', 'gelenTasinanBelgeleriIndir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenTasinanBelgeleriIndir2), 'ettnler', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gelenTasinanBelgeleriIndir, 'http://service.connector.uut.cs.com.tr/', 'gelenTasinanBelgeleriIndir');
  RemClassRegistry.RegisterXSClass(gidenIrsaliyeleriArsiveKaldir2, 'http://service.connector.uut.cs.com.tr/', 'gidenIrsaliyeleriArsiveKaldir2', 'gidenIrsaliyeleriArsiveKaldir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenIrsaliyeleriArsiveKaldir2), 'despatchEttnListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gidenIrsaliyeleriArsiveKaldir, 'http://service.connector.uut.cs.com.tr/', 'gidenIrsaliyeleriArsiveKaldir');
  RemClassRegistry.RegisterXSClass(belgelerAlindi2, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindi2', 'belgelerAlindi');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(belgelerAlindi2), 'ettn', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(belgelerAlindi, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindi');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirPortalParametreleri, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirPortalParametreleri');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenBelgeleriIndirPortalParametreleri), 'belgeEttnListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSInfo(TypeInfo(efaturaKullaniciListesi), 'http://service.connector.uut.cs.com.tr/', 'efaturaKullaniciListesi');
  RemClassRegistry.RegisterXSClass(mukellefEFaturaKayit, 'http://service.connector.uut.cs.com.tr/', 'mukellefEFaturaKayit');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(mukellefEFaturaKayit), 'efaturaKullaniciListesi', '[ArrayItemName="return"]');
  RemClassRegistry.RegisterXSClass(gidenBelgeTutarBilgileri, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeTutarBilgileri');
  RemClassRegistry.RegisterXSClass(gelenBelgeTutarBilgileri, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeTutarBilgileri');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListelePortalData, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListelePortalData');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListelePortalDatav2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListelePortalDatav2');
  RemClassRegistry.RegisterXSClass(cokluGidenBelgeDurumSorgula2, 'http://service.connector.uut.cs.com.tr/', 'cokluGidenBelgeDurumSorgula2', 'cokluGidenBelgeDurumSorgula');
  RemClassRegistry.RegisterXSClass(cokluGidenBelgeDurumSorgula, 'http://service.connector.uut.cs.com.tr/', 'cokluGidenBelgeDurumSorgula');
  RemClassRegistry.RegisterXSClass(faturaTarihcesiSorgula2, 'http://service.connector.uut.cs.com.tr/', 'faturaTarihcesiSorgula2', 'faturaTarihcesiSorgula');
  RemClassRegistry.RegisterXSClass(faturaTarihcesiSorgula, 'http://service.connector.uut.cs.com.tr/', 'faturaTarihcesiSorgula');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumParametreleri, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumParametreleri');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenBelgeDurumParametreleri), 'belgeNoList', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(irsaliyeMailGonder2, 'http://service.connector.uut.cs.com.tr/', 'irsaliyeMailGonder2', 'irsaliyeMailGonder');
  RemClassRegistry.RegisterXSClass(irsaliyeMailGonder, 'http://service.connector.uut.cs.com.tr/', 'irsaliyeMailGonder');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildiIptal2, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildiIptal2', 'faturaKepIleIadeEdildiIptal');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildiIptal, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildiIptal');
  RemClassRegistry.RegisterXSClass(Exception, 'http://service.connector.uut.cs.com.tr/', 'Exception');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Exception), 'message_', '[ExtName="message"]');
  RemClassRegistry.RegisterXSClass(gelenStandartRapolariAl2, 'http://service.connector.uut.cs.com.tr/', 'gelenStandartRapolariAl2', 'gelenStandartRapolariAl');
  RemClassRegistry.RegisterXSClass(gelenStandartRapolariAl, 'http://service.connector.uut.cs.com.tr/', 'gelenStandartRapolariAl');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriListele2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListele2', 'gelenBelgeleriListele');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriListele, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListele');
  RemClassRegistry.RegisterXSClass(eIrsaliyeKullanicisi2, 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKullanicisi2', 'eIrsaliyeKullanicisi');
  RemClassRegistry.RegisterXSClass(eIrsaliyeKullanicisi, 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKullanicisi');
  RemClassRegistry.RegisterXSClass(csXmlOnizleme2, 'http://service.connector.uut.cs.com.tr/', 'csXmlOnizleme2', 'csXmlOnizleme');
  RemClassRegistry.RegisterXSClass(csXmlOnizleme, 'http://service.connector.uut.cs.com.tr/', 'csXmlOnizleme');
  RemClassRegistry.RegisterXSClass(urunSablonlariniAl2, 'http://service.connector.uut.cs.com.tr/', 'urunSablonlariniAl2', 'urunSablonlariniAl');
  RemClassRegistry.RegisterXSClass(urunSablonlariniAl, 'http://service.connector.uut.cs.com.tr/', 'urunSablonlariniAl');
  RemClassRegistry.RegisterXSClass(eFaturaKayitliKullaniciListele2, 'http://service.connector.uut.cs.com.tr/', 'eFaturaKayitliKullaniciListele2', 'eFaturaKayitliKullaniciListele');
  RemClassRegistry.RegisterXSClass(eFaturaKayitliKullaniciListele, 'http://service.connector.uut.cs.com.tr/', 'eFaturaKayitliKullaniciListele');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgula2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgula2', 'gidenBelgeDurumSorgula');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgula, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgula');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildi2, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildi2', 'faturaKepIleIadeEdildi');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildi, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildi');
  RemClassRegistry.RegisterXSClass(gelenBelgeTutarBilgileriSorgula2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeTutarBilgileriSorgula2', 'gelenBelgeTutarBilgileriSorgula');
  RemClassRegistry.RegisterXSClass(gelenBelgeTutarBilgileriSorgula, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeTutarBilgileriSorgula');
  RemClassRegistry.RegisterXSClass(gidenBelgeEkleriAl2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeEkleriAl2', 'gidenBelgeEkleriAl');
  RemClassRegistry.RegisterXSClass(gidenBelgeEkleriAl, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeEkleriAl');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirEttn2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirEttn2', 'gidenBelgeleriIndirEttn');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenBelgeleriIndirEttn2), 'belgeEttnListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirEttn, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirEttn');
  RemClassRegistry.RegisterXSClass(gelenBelgeParametreleri, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeParametreleri');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenBelgeParametreleri), 'alanEtiket', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenBelgeParametreleri), 'ettn', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenBelgeParametreleri), 'gonderenEtiket', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(eFaturaKullanici, 'http://service.connector.uut.cs.com.tr/', 'eFaturaKullanici');
  RemClassRegistry.RegisterXSClass(eIrsaliyeKullanici, 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKullanici');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildiIptalResponse2, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildiIptalResponse2', 'faturaKepIleIadeEdildiIptalResponse');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildiIptalResponse, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildiIptalResponse');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderYerelBelgeNoResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderYerelBelgeNoResponse2', 'belgeleriTekrarGonderYerelBelgeNoResponse');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderYerelBelgeNoResponse, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderYerelBelgeNoResponse');
  RemClassRegistry.RegisterXSClass(eIrsaliyeKullanicisiResponse2, 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKullanicisiResponse2', 'eIrsaliyeKullanicisiResponse');
  RemClassRegistry.RegisterXSClass(eIrsaliyeKullanicisiResponse, 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKullanicisiResponse');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildiResponse2, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildiResponse2', 'faturaKepIleIadeEdildiResponse');
  RemClassRegistry.RegisterXSClass(faturaKepIleIadeEdildiResponse, 'http://service.connector.uut.cs.com.tr/', 'faturaKepIleIadeEdildiResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgulaExt2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgulaExt2', 'gelenBelgeDurumSorgulaExt');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgulaExt, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgulaExt');
  RemClassRegistry.RegisterXSClass(gelenTasinanBelgeleriIndirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenTasinanBelgeleriIndirResponse2', 'gelenTasinanBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSClass(gelenTasinanBelgeleriIndirResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenTasinanBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSClass(Exception2, 'http://service.connector.uut.cs.com.tr/', 'Exception2', 'Exception');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Exception2), 'message_', '[ExtName="message"]');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListeleData, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListeleData');
  RemClassRegistry.RegisterXSClass(faturaTarihcesiData, 'http://service.connector.uut.cs.com.tr/', 'faturaTarihcesiData');
  RemClassRegistry.RegisterXSClass(irsaliyeTarihcesiData, 'http://service.connector.uut.cs.com.tr/', 'irsaliyeTarihcesiData');
  RemClassRegistry.RegisterXSClass(eFaturaKayitliKullaniciHistory, 'http://service.connector.uut.cs.com.tr/', 'eFaturaKayitliKullaniciHistory');
  RemClassRegistry.RegisterXSClass(eFaturaKullaniciExtended, 'http://service.connector.uut.cs.com.tr/', 'eFaturaKullaniciExtended');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurum, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurum');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumv2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumv2');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumv3, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumv3');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumv4, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumv4');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumv5, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumv5');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumv6, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumv6');
  RemClassRegistry.RegisterXSClass(kontorAzaltResp, 'http://service.connector.uut.cs.com.tr/', 'kontorAzaltResp');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedTime2, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedTime2', 'kayitliKullaniciListeleExtendedTime');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedTime, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedTime');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurum, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurum');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumv2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumv2');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumv3, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumv3');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumv4, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumv4');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumv5, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumv5');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirPortalResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirPortalResponse2', 'gidenBelgeleriIndirPortalResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirPortalResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirPortalResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListele2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListele2', 'gidenBelgeleriListele');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListele, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListele');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListeleParametreleri, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListeleParametreleri');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndirExtResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndirExtResponse2', 'gelenBelgeleriIndirExtResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndirExtResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndirExtResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(irsaliyeTarihcesiSorgulaResponse2), 'http://service.connector.uut.cs.com.tr/', 'irsaliyeTarihcesiSorgulaResponse2', 'irsaliyeTarihcesiSorgulaResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(irsaliyeTarihcesiSorgulaResponse), 'http://service.connector.uut.cs.com.tr/', 'irsaliyeTarihcesiSorgulaResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndirExt2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndirExt2', 'gelenBelgeleriIndirExt');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndirExt, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndirExt');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListelePortal2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListelePortal2', 'gidenBelgeleriListelePortal');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListelePortal, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListelePortal');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriListelePortalParametreleri, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListelePortalParametreleri');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenBelgeleriListelePortalParametreleri), 'belgeEttnListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gelenFaturalariArsiveKaldirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenFaturalariArsiveKaldirResponse2', 'gelenFaturalariArsiveKaldirResponse');
  RemClassRegistry.RegisterXSClass(gelenFaturalariArsiveKaldirResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenFaturalariArsiveKaldirResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gidenBelgeleriListeleResponse2), 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListeleResponse2', 'gidenBelgeleriListeleResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gidenBelgeleriListeleResponse), 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListeleResponse');
  RemClassRegistry.RegisterXSClass(gelenFaturalariArsiveKaldir2, 'http://service.connector.uut.cs.com.tr/', 'gelenFaturalariArsiveKaldir2', 'gelenFaturalariArsiveKaldir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenFaturalariArsiveKaldir2), 'invoiceEttnListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gelenFaturalariArsiveKaldir, 'http://service.connector.uut.cs.com.tr/', 'gelenFaturalariArsiveKaldir');
  RemClassRegistry.RegisterXSClass(irsaliyeTarihcesiSorgula2, 'http://service.connector.uut.cs.com.tr/', 'irsaliyeTarihcesiSorgula2', 'irsaliyeTarihcesiSorgula');
  RemClassRegistry.RegisterXSClass(irsaliyeTarihcesiSorgula, 'http://service.connector.uut.cs.com.tr/', 'irsaliyeTarihcesiSorgula');
  RemClassRegistry.RegisterXSClass(faturaNoUretResponse2, 'http://service.connector.uut.cs.com.tr/', 'faturaNoUretResponse2', 'faturaNoUretResponse');
  RemClassRegistry.RegisterXSClass(faturaNoUretResponse, 'http://service.connector.uut.cs.com.tr/', 'faturaNoUretResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaEttn2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaEttn2', 'gidenBelgeDurumSorgulaEttn');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaEttn, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaEttn');
  RemClassRegistry.RegisterXSClass(faturaNoUret2, 'http://service.connector.uut.cs.com.tr/', 'faturaNoUret2', 'faturaNoUret');
  RemClassRegistry.RegisterXSClass(faturaNoUret, 'http://service.connector.uut.cs.com.tr/', 'faturaNoUret');
  RemClassRegistry.RegisterXSClass(belgelerAlindiEntegrasyonSiparisNoGuncelle2, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindiEntegrasyonSiparisNoGuncelle2', 'belgelerAlindiEntegrasyonSiparisNoGuncelle');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(belgelerAlindiEntegrasyonSiparisNoGuncelle2), 'ettn', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(belgelerAlindiEntegrasyonSiparisNoGuncelle, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindiEntegrasyonSiparisNoGuncelle');
  RemClassRegistry.RegisterXSClass(belgelerAlindiEntegrasyonSiparisNoGuncelleResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindiEntegrasyonSiparisNoGuncelleResponse2', 'belgelerAlindiEntegrasyonSiparisNoGuncelleResponse');
  RemClassRegistry.RegisterXSClass(belgelerAlindiEntegrasyonSiparisNoGuncelleResponse, 'http://service.connector.uut.cs.com.tr/', 'belgelerAlindiEntegrasyonSiparisNoGuncelleResponse');
  RemClassRegistry.RegisterXSClass(temelKontrollerIleBelgeGonder2, 'http://service.connector.uut.cs.com.tr/', 'temelKontrollerIleBelgeGonder2', 'temelKontrollerIleBelgeGonder');
  RemClassRegistry.RegisterXSClass(temelKontrollerIleBelgeGonder, 'http://service.connector.uut.cs.com.tr/', 'temelKontrollerIleBelgeGonder');
  RemClassRegistry.RegisterXSClass(temelKontrollerIleBelgeGonderResponse2, 'http://service.connector.uut.cs.com.tr/', 'temelKontrollerIleBelgeGonderResponse2', 'temelKontrollerIleBelgeGonderResponse');
  RemClassRegistry.RegisterXSClass(temelKontrollerIleBelgeGonderResponse, 'http://service.connector.uut.cs.com.tr/', 'temelKontrollerIleBelgeGonderResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriListeleExtResponse2), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListeleExtResponse2', 'gelenBelgeleriListeleExtResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriListeleExtResponse), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListeleExtResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaEttnResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaEttnResponse2', 'gidenBelgeDurumSorgulaEttnResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaEttnResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaEttnResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriListeleExt2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListeleExt2', 'gelenBelgeleriListeleExt');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriListeleExt, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriListeleExt');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaBelgeNo2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaBelgeNo2', 'gidenBelgeDurumSorgulaBelgeNo');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaBelgeNo, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaBelgeNo');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaBelgeNoResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaBelgeNoResponse2', 'gidenBelgeDurumSorgulaBelgeNoResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaBelgeNoResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaBelgeNoResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndirResponse2', 'gelenBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndirResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSClass(ublOnizlemeResponse2, 'http://service.connector.uut.cs.com.tr/', 'ublOnizlemeResponse2', 'ublOnizlemeResponse');
  RemClassRegistry.RegisterXSClass(ublOnizlemeResponse, 'http://service.connector.uut.cs.com.tr/', 'ublOnizlemeResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndir2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndir2', 'gelenBelgeleriIndir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenBelgeleriIndir2), 'ettnler', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriIndir, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriIndir');
  RemClassRegistry.RegisterXSClass(gelenTamamlananRapolariAlResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenTamamlananRapolariAlResponse2', 'gelenTamamlananRapolariAlResponse');
  RemClassRegistry.RegisterXSClass(gelenTamamlananRapolariAlResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenTamamlananRapolariAlResponse');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderYerelBelgeNo2, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderYerelBelgeNo2', 'belgeleriTekrarGonderYerelBelgeNo');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(belgeleriTekrarGonderYerelBelgeNo2), 'yerelBelgeNo', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderYerelBelgeNo, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderYerelBelgeNo');
  RemClassRegistry.RegisterXSClass(gelenTamamlananRapolariAl2, 'http://service.connector.uut.cs.com.tr/', 'gelenTamamlananRapolariAl2', 'gelenTamamlananRapolariAl');
  RemClassRegistry.RegisterXSClass(gelenTamamlananRapolariAl, 'http://service.connector.uut.cs.com.tr/', 'gelenTamamlananRapolariAl');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderBelgeOid2, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderBelgeOid2', 'belgeleriTekrarGonderBelgeOid');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(belgeleriTekrarGonderBelgeOid2), 'belgeOid', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderBelgeOid, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderBelgeOid');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderBelgeOidResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderBelgeOidResponse2', 'belgeleriTekrarGonderBelgeOidResponse');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderBelgeOidResponse, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderBelgeOidResponse');
  RemClassRegistry.RegisterXSClass(ublOnizleme2, 'http://service.connector.uut.cs.com.tr/', 'ublOnizleme2', 'ublOnizleme');
  RemClassRegistry.RegisterXSClass(ublOnizleme, 'http://service.connector.uut.cs.com.tr/', 'ublOnizleme');
  RemClassRegistry.RegisterXSClass(gelenBelgeXmlleriniAl2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAl2', 'gelenBelgeXmlleriniAl');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenBelgeXmlleriniAl2), 'ettnler', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gelenBelgeXmlleriniAl, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAl');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeXmlleriniAlResponse2), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAlResponse2', 'gelenBelgeXmlleriniAlResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeXmlleriniAlResponse), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAlResponse');
  RemClassRegistry.RegisterXSClass(belgeGonderExtWithValidateResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExtWithValidateResponse2', 'belgeGonderExtWithValidateResponse');
  RemClassRegistry.RegisterXSClass(belgeGonderExtWithValidateResponse, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExtWithValidateResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gidenBelgeleriListelePortalResponse2), 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListelePortalResponse2', 'gidenBelgeleriListelePortalResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gidenBelgeleriListelePortalResponse), 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriListelePortalResponse');
  RemClassRegistry.RegisterXSClass(belgeGonderExtWithValidate2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExtWithValidate2', 'belgeGonderExtWithValidate');
  RemClassRegistry.RegisterXSClass(belgeGonderExtWithValidate, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderExtWithValidate');
  RemClassRegistry.RegisterXSClass(eIrsaliyeKayitliKullaniciListele2, 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKayitliKullaniciListele2', 'eIrsaliyeKayitliKullaniciListele');
  RemClassRegistry.RegisterXSClass(eIrsaliyeKayitliKullaniciListele, 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKayitliKullaniciListele');
  RemClassRegistry.RegisterXSInfo(TypeInfo(eIrsaliyeKayitliKullaniciListeleResponse2), 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKayitliKullaniciListeleResponse2', 'eIrsaliyeKayitliKullaniciListeleResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(eIrsaliyeKayitliKullaniciListeleResponse), 'http://service.connector.uut.cs.com.tr/', 'eIrsaliyeKayitliKullaniciListeleResponse');
  RemClassRegistry.RegisterXSClass(wsKullaniciBilgileri, 'http://service.connector.uut.cs.com.tr/', 'wsKullaniciBilgileri');
  RemClassRegistry.RegisterXSClass(wsKullanicisiKaydet2, 'http://service.connector.uut.cs.com.tr/', 'wsKullanicisiKaydet2', 'wsKullanicisiKaydet');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(wsKullanicisiKaydet2), 'urunList', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(wsKullanicisiKaydet, 'http://service.connector.uut.cs.com.tr/', 'wsKullanicisiKaydet');
  RemClassRegistry.RegisterXSClass(wsKullanicisiKaydetResponse2, 'http://service.connector.uut.cs.com.tr/', 'wsKullanicisiKaydetResponse2', 'wsKullanicisiKaydetResponse');
  RemClassRegistry.RegisterXSClass(wsKullanicisiKaydetResponse, 'http://service.connector.uut.cs.com.tr/', 'wsKullanicisiKaydetResponse');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedVknTcknResponse2, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedVknTcknResponse2', 'kayitliKullaniciListeleExtendedVknTcknResponse');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedVknTcknResponse, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedVknTcknResponse');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedVknTckn2, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedVknTckn2', 'kayitliKullaniciListeleExtendedVknTckn');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedVknTckn, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedVknTckn');
  RemClassRegistry.RegisterXSClass(yolcuBeraberFaturaIptalEt2, 'http://service.connector.uut.cs.com.tr/', 'yolcuBeraberFaturaIptalEt2', 'yolcuBeraberFaturaIptalEt');
  RemClassRegistry.RegisterXSClass(yolcuBeraberFaturaIptalEt, 'http://service.connector.uut.cs.com.tr/', 'yolcuBeraberFaturaIptalEt');
  RemClassRegistry.RegisterXSClass(yolcuBeraberFaturaIptalEtResponse2, 'http://service.connector.uut.cs.com.tr/', 'yolcuBeraberFaturaIptalEtResponse2', 'yolcuBeraberFaturaIptalEtResponse');
  RemClassRegistry.RegisterXSClass(yolcuBeraberFaturaIptalEtResponse, 'http://service.connector.uut.cs.com.tr/', 'yolcuBeraberFaturaIptalEtResponse');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonder2, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonder2', 'belgeleriTekrarGonder');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(belgeleriTekrarGonder2), 'ettn', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonder, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonder');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderResponse2', 'belgeleriTekrarGonderResponse');
  RemClassRegistry.RegisterXSClass(belgeleriTekrarGonderResponse, 'http://service.connector.uut.cs.com.tr/', 'belgeleriTekrarGonderResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriAlExt2Response2), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExt2Response2', 'gelenBelgeleriAlExt2Response');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gelenBelgeleriAlExt2Response), 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExt2Response');
  RemClassRegistry.RegisterXSInfo(TypeInfo(parametreler), 'http://service.connector.uut.cs.com.tr/', 'parametreler');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriAlExt22, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExt22', 'gelenBelgeleriAlExt2');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenBelgeleriAlExt22), 'parametreler', '[ArrayItemName="entry"]');
  RemClassRegistry.RegisterXSClass(gelenBelgeleriAlExt2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeleriAlExt2');
  RemClassRegistry.RegisterXSClass(entry2, 'http://service.connector.uut.cs.com.tr/', 'entry2', 'entry');
  RemClassRegistry.RegisterXSClass(faturaMailGonderResponse2, 'http://service.connector.uut.cs.com.tr/', 'faturaMailGonderResponse2', 'faturaMailGonderResponse');
  RemClassRegistry.RegisterXSClass(faturaMailGonderResponse, 'http://service.connector.uut.cs.com.tr/', 'faturaMailGonderResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(kontorBirimi), 'http://service.connector.uut.cs.com.tr/', 'kontorBirimi');
  RemClassRegistry.RegisterXSInfo(TypeInfo(kontorTipi), 'http://service.connector.uut.cs.com.tr/', 'kontorTipi');
  RemClassRegistry.RegisterXSClass(kalanKontorBilgisi, 'http://service.connector.uut.cs.com.tr/', 'kalanKontorBilgisi');
  RemClassRegistry.RegisterXSClass(kontorBilgisiGetir2, 'http://service.connector.uut.cs.com.tr/', 'kontorBilgisiGetir2', 'kontorBilgisiGetir');
  RemClassRegistry.RegisterXSClass(kontorBilgisiGetir, 'http://service.connector.uut.cs.com.tr/', 'kontorBilgisiGetir');
  RemClassRegistry.RegisterXSClass(kontorBilgisiGetirResponse2, 'http://service.connector.uut.cs.com.tr/', 'kontorBilgisiGetirResponse2', 'kontorBilgisiGetirResponse');
  RemClassRegistry.RegisterXSClass(kontorBilgisiGetirResponse, 'http://service.connector.uut.cs.com.tr/', 'kontorBilgisiGetirResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgulaResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgulaResponse2', 'gelenBelgeDurumSorgulaResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgulaResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgulaResponse');
  RemClassRegistry.RegisterXSClass(faturaMailGonder2, 'http://service.connector.uut.cs.com.tr/', 'faturaMailGonder2', 'faturaMailGonder');
  RemClassRegistry.RegisterXSClass(faturaMailGonder, 'http://service.connector.uut.cs.com.tr/', 'faturaMailGonder');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgula2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgula2', 'gelenBelgeDurumSorgula');
  RemClassRegistry.RegisterXSClass(gelenBelgeDurumSorgula, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeDurumSorgula');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndir2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndir2', 'gidenBelgeleriIndir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenBelgeleriIndir2), 'belgeOidListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndir, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndir');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirResponse2', 'gidenBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeleriIndirResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaYerelBelgeNoResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaYerelBelgeNoResponse2', 'gidenBelgeDurumSorgulaYerelBelgeNoResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaYerelBelgeNoResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaYerelBelgeNoResponse');
  RemClassRegistry.RegisterXSClass(gidenBelgeTutarBilgileriSorgula2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeTutarBilgileriSorgula2', 'gidenBelgeTutarBilgileriSorgula');
  RemClassRegistry.RegisterXSClass(gidenBelgeTutarBilgileriSorgula, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeTutarBilgileriSorgula');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaYerelBelgeNo2, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaYerelBelgeNo2', 'gidenBelgeDurumSorgulaYerelBelgeNo');
  RemClassRegistry.RegisterXSClass(gidenBelgeDurumSorgulaYerelBelgeNo, 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeDurumSorgulaYerelBelgeNo');
  RemClassRegistry.RegisterXSClass(gelenBelgeXmlleriniAlExt2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAlExt2', 'gelenBelgeXmlleriniAlExt');
  RemClassRegistry.RegisterXSClass(gelenBelgeXmlleriniAlExt, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAlExt');
  RemClassRegistry.RegisterXSClass(gelenBelgeXmlleriniAlExtResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAlExtResponse2', 'gelenBelgeXmlleriniAlExtResponse');
  RemClassRegistry.RegisterXSClass(gelenBelgeXmlleriniAlExtResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenBelgeXmlleriniAlExtResponse');
  RemClassRegistry.RegisterXSClass(gidenFaturalariArsiveKaldir2, 'http://service.connector.uut.cs.com.tr/', 'gidenFaturalariArsiveKaldir2', 'gidenFaturalariArsiveKaldir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenFaturalariArsiveKaldir2), 'invoiceEttnListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gidenFaturalariArsiveKaldir, 'http://service.connector.uut.cs.com.tr/', 'gidenFaturalariArsiveKaldir');
  RemClassRegistry.RegisterXSClass(gidenFaturalariArsiveKaldirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenFaturalariArsiveKaldirResponse2', 'gidenFaturalariArsiveKaldirResponse');
  RemClassRegistry.RegisterXSClass(gidenFaturalariArsiveKaldirResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenFaturalariArsiveKaldirResponse');
  RemClassRegistry.RegisterXSClass(gidenTasinanBelgeleriIndirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gidenTasinanBelgeleriIndirResponse2', 'gidenTasinanBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSClass(gidenTasinanBelgeleriIndirResponse, 'http://service.connector.uut.cs.com.tr/', 'gidenTasinanBelgeleriIndirResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gidenBelgeTutarBilgileriSorgulaResponse2), 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeTutarBilgileriSorgulaResponse2', 'gidenBelgeTutarBilgileriSorgulaResponse');
  RemClassRegistry.RegisterXSInfo(TypeInfo(gidenBelgeTutarBilgileriSorgulaResponse), 'http://service.connector.uut.cs.com.tr/', 'gidenBelgeTutarBilgileriSorgulaResponse');
  RemClassRegistry.RegisterXSClass(gidenTasinanBelgeleriIndir2, 'http://service.connector.uut.cs.com.tr/', 'gidenTasinanBelgeleriIndir2', 'gidenTasinanBelgeleriIndir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gidenTasinanBelgeleriIndir2), 'ettnler', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gidenTasinanBelgeleriIndir, 'http://service.connector.uut.cs.com.tr/', 'gidenTasinanBelgeleriIndir');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedResponse2, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedResponse2', 'kayitliKullaniciListeleExtendedResponse');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtendedResponse, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtendedResponse');
  RemClassRegistry.RegisterXSClass(gelenIrsaliyeleriArsiveKaldir2, 'http://service.connector.uut.cs.com.tr/', 'gelenIrsaliyeleriArsiveKaldir2', 'gelenIrsaliyeleriArsiveKaldir');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(gelenIrsaliyeleriArsiveKaldir2), 'despatchEttnListesi', '[ArrayItemName="vergiTcKimlikNoListesi"]');
  RemClassRegistry.RegisterXSClass(gelenIrsaliyeleriArsiveKaldir, 'http://service.connector.uut.cs.com.tr/', 'gelenIrsaliyeleriArsiveKaldir');
  RemClassRegistry.RegisterXSClass(gelenIrsaliyeleriArsiveKaldirResponse2, 'http://service.connector.uut.cs.com.tr/', 'gelenIrsaliyeleriArsiveKaldirResponse2', 'gelenIrsaliyeleriArsiveKaldirResponse');
  RemClassRegistry.RegisterXSClass(gelenIrsaliyeleriArsiveKaldirResponse, 'http://service.connector.uut.cs.com.tr/', 'gelenIrsaliyeleriArsiveKaldirResponse');
  RemClassRegistry.RegisterXSClass(erpBilgileriBelirleResponse2, 'http://service.connector.uut.cs.com.tr/', 'erpBilgileriBelirleResponse2', 'erpBilgileriBelirleResponse');
  RemClassRegistry.RegisterXSClass(erpBilgileriBelirleResponse, 'http://service.connector.uut.cs.com.tr/', 'erpBilgileriBelirleResponse');
  RemClassRegistry.RegisterXSClass(erpBilgileriBelirle2, 'http://service.connector.uut.cs.com.tr/', 'erpBilgileriBelirle2', 'erpBilgileriBelirle');
  RemClassRegistry.RegisterXSClass(erpBilgileriBelirle, 'http://service.connector.uut.cs.com.tr/', 'erpBilgileriBelirle');
  RemClassRegistry.RegisterXSClass(erpBilgileri, 'http://service.connector.uut.cs.com.tr/', 'erpBilgileri');
  RemClassRegistry.RegisterXSClass(efaturaKullanicisiResponse2, 'http://service.connector.uut.cs.com.tr/', 'efaturaKullanicisiResponse2', 'efaturaKullanicisiResponse');
  RemClassRegistry.RegisterXSClass(efaturaKullanicisiResponse, 'http://service.connector.uut.cs.com.tr/', 'efaturaKullanicisiResponse');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtended2, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtended2', 'kayitliKullaniciListeleExtended');
  RemClassRegistry.RegisterXSClass(kayitliKullaniciListeleExtended, 'http://service.connector.uut.cs.com.tr/', 'kayitliKullaniciListeleExtended');
  RemClassRegistry.RegisterXSClass(efaturaKullanicisi2, 'http://service.connector.uut.cs.com.tr/', 'efaturaKullanicisi2', 'efaturaKullanicisi');
  RemClassRegistry.RegisterXSClass(efaturaKullanicisi, 'http://service.connector.uut.cs.com.tr/', 'efaturaKullanicisi');
  RemClassRegistry.RegisterXSClass(belgeGonderWithValidate2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderWithValidate2', 'belgeGonderWithValidate');
  RemClassRegistry.RegisterXSClass(belgeGonderWithValidate, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderWithValidate');
  RemClassRegistry.RegisterXSClass(belgeGonderWithValidateResponse2, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderWithValidateResponse2', 'belgeGonderWithValidateResponse');
  RemClassRegistry.RegisterXSClass(belgeGonderWithValidateResponse, 'http://service.connector.uut.cs.com.tr/', 'belgeGonderWithValidateResponse');

end.