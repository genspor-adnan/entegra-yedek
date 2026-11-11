// MIRTH KANAL ÜRETECİ (Rhino, Mirth 4.5.2 konteynerinde çalışır) - kanal XML'ini Mirth'in KENDİ model sınıflarıyla kurar,
// böylece elle yazılmış XML'deki eksik alan deploy'da patlamaz. Çıktı: /tmp/kanallar/*.xml (mirth-kanallar.ps1 çağırır).
//
// Kanallar (tasarım Ekranlar/Radyoloji/teletip_mirth.html):
//   K1 TELETIP_HL7       - Gentegre MLLP 6661 -> Teletıp (adres configuration map: teletip_hl7_host / teletip_hl7_port).
//                          Kaynak yanıtı "d1": Teletıp'ın ACK'i Gentegre'ye AYNEN döner (bizim ACK politikası çalışır).
//                          Hedef kuyruğu KAPALI: tekrar Gentegre kuyruğunda (telerad_istek); Mirth taşır, arşivler, izler.
//   TELETIP_SIMULATOR    - yalnız dev/test: MLLP 6671, Bakanlık kılavuzu 3.43 § 3.4'teki birkaç ret kuralını uygular
//                          (0002 sürüm, 0003 OBR-24, 0008 OBR-4, 0278 PV1-19) ve AA / AE döner.
importPackage(Packages.com.mirth.connect.model);
var Ser = Packages.com.mirth.connect.model.converters.ObjectXMLSerializer.getInstance();
Ser.init('4.5.2');
var HL7Ozellik = Packages.com.mirth.connect.plugins.datatypes.hl7v2.HL7v2DataTypeProperties;
var MLLP = Packages.com.mirth.connect.plugins.mllpmode.MLLPModeProperties;
var Kolon = Packages.com.mirth.connect.donkey.model.channel.MetaDataColumn;
var KolonTipi = Packages.com.mirth.connect.donkey.model.channel.MetaDataColumnType;

// Dönüştürücüler RAW: betikler ham ER7'yi okur; HL7V2 XML'e çevirmek Bakanlık'ın ORC-21 biçimindeki (148\S\S\…)
// kaçış dizilerinde "invalid XML character 0x1" ile düşüyordu. Mesaj Mirth'ten DEĞİŞMEDEN geçer.
// Yalnız hedefin YANIT dönüştürücüsü HL7V2: Teletıp ACK'i (AA/AE/AR) doğrulansın, AE Mirth'te hata sayılsın.
var RawOzellik = Packages.com.mirth.connect.plugins.datatypes.raw.RawDataTypeProperties;
function donusturucu(adimlar, hl7) {
  var t = new Transformer();
  var tur = hl7 ? 'HL7V2' : 'RAW';
  t.setInboundDataType(tur); t.setOutboundDataType(tur);
  t.setInboundProperties(hl7 ? new HL7Ozellik() : new RawOzellik());
  t.setOutboundProperties(hl7 ? new HL7Ozellik() : new RawOzellik());
  var liste = new java.util.ArrayList();
  for (var i = 0; i < adimlar.length; i++) {
    var a = new Packages.com.mirth.connect.plugins.javascriptstep.JavaScriptStep();
    a.setSequenceNumber(String(i)); a.setName(adimlar[i].ad); a.setScript(adimlar[i].betik); a.setEnabled(true);
    liste.add(a);
  }
  t.setElements(liste);
  return t;
}

function kanal(id, ad, aciklama) {
  var c = new Channel();
  c.setId(id); c.setName(ad); c.setDescription(aciklama); c.setRevision(0);
  c.setPreprocessingScript('// Ön işlem yok\nreturn message;');
  c.setPostprocessingScript('return;');
  c.setDeployScript('return;');
  c.setUndeployScript('return;');
  return c;
}

function mllpDinleyici(port, yanitDegiskeni) {
  var p = new Packages.com.mirth.connect.connectors.tcp.TcpReceiverProperties();
  p.setTransmissionModeProperties(new MLLP());
  p.getListenerConnectorProperties().setPort(String(port));
  p.getSourceConnectorProperties().setResponseVariable(yanitDegiskeni);
  p.setCharsetEncoding('UTF-8');
  return p;
}

function kaynak(ozellik, adimlar, tasima) {
  var k = new Connector();
  k.setMetaDataId(0); k.setName('sourceConnector'); k.setMode(Connector.Mode.SOURCE);
  k.setTransportName(tasima || 'TCP Listener'); k.setProperties(ozellik); k.setEnabled(true);
  k.setTransformer(donusturucu(adimlar)); k.setFilter(new Filter());
  return k;
}

function hedef(no, ad, tasima, ozellik) {
  var h = new Connector();
  h.setMetaDataId(no); h.setName(ad); h.setMode(Connector.Mode.DESTINATION);
  h.setTransportName(tasima); h.setProperties(ozellik); h.setEnabled(true); h.setWaitForPrevious(true);
  h.setTransformer(donusturucu([])); h.setResponseTransformer(donusturucu([], true)); h.setFilter(new Filter());
  return h;
}

// Ham ER7'den alan okuyan ortak yardımcı (E4X yerine: bileşenli alanlarda toString tuzağı yok).
var ALAN = '' +
  "function hl7Segmentler(ham) { return String(ham).replace(/\\n/g, '\\r').split('\\r').filter(function (s) { return s.length > 0; }); }\n" +
  "function hl7Alan(ham, seg, no) {\n" +
  "  var s = hl7Segmentler(ham).filter(function (x) { return x.substr(0, 3) == seg; })[0];\n" +
  "  if (!s) return null;\n" +
  "  var f = s.split('|');\n" +
  "  return seg == 'MSH' ? (f[no - 1] || '') : (f[no] || '');\n" +
  "}\n";

// ------------------------------------------------------------------ K1 TELETIP_HL7
var k1 = kanal('6d1f0c2a-7e43-4c55-9a0e-1b7c5e2f6601', 'TELETIP_HL7',
  'K1 - Gentegre -> Teletip HL7 2.3.1 (ORM/ORU). Icerik Gentegre\'de uretilir; Mirth tasir, arsivler. ' +
  'Hedef adresi configuration map: teletip_hl7_host / teletip_hl7_port. Kaynak yaniti d1 = Teletip ACK aynen doner. ' +
  'Hedef kuyrugu kapali: tekrar Gentegre kuyrugunda (telerad_istek).');
k1.setSourceConnector(kaynak(mllpDinleyici(6661, 'd1'), [{
  ad: 'Arama alanlari',
  betik: ALAN +
    "var ham = connectorMessage.getRawData();\n" +
    "channelMap.put('mesajTuru', hl7Alan(ham, 'MSH', 9) || '');\n" +
    "channelMap.put('kontrolNo', hl7Alan(ham, 'MSH', 10) || '');\n" +
    "var acc = hl7Alan(ham, 'OBR', 18) || String(hl7Alan(ham, 'ORC', 2) || '').split('^')[0];\n" +
    "channelMap.put('accession', acc || '');\n" +
    "channelMap.put('emir', String(hl7Alan(ham, 'ORC', 1) || ''));\n"
}]));
var k1Ozellik = new Packages.com.mirth.connect.connectors.tcp.TcpDispatcherProperties();
k1Ozellik.setTransmissionModeProperties(new MLLP());
k1Ozellik.setRemoteAddress('${teletip_hl7_host}');
k1Ozellik.setRemotePort('${teletip_hl7_port}');
k1Ozellik.setTemplate('${message.encodedData}');
k1Ozellik.setResponseTimeout('30000');
k1Ozellik.setSendTimeout('10000');
k1Ozellik.setCharsetEncoding('UTF-8');
k1Ozellik.getDestinationConnectorProperties().setValidateResponse(true);   // AE / AR Mirth'te HATA sayılır (pano)
k1Ozellik.getDestinationConnectorProperties().setQueueEnabled(false);
k1.getDestinationConnectors().add(hedef(1, 'Teletip', 'TCP Sender', k1Ozellik));
k1.setNextMetaDataId(2);
var kolonlar = new java.util.ArrayList();
kolonlar.add(new Kolon('ACCESSION', KolonTipi.STRING, 'accession'));
kolonlar.add(new Kolon('MESAJ', KolonTipi.STRING, 'mesajTuru'));
kolonlar.add(new Kolon('EMIR', KolonTipi.STRING, 'emir'));
kolonlar.add(new Kolon('KONTROL_NO', KolonTipi.STRING, 'kontrolNo'));
k1.getProperties().setMetaDataColumns(kolonlar);
k1.getProperties().setMessageStorageMode(Packages.com.mirth.connect.model.MessageStorageMode.PRODUCTION);

// ------------------------------------------------------------------ TELETIP_SIMULATOR (dev)
var sim = kanal('6d1f0c2a-7e43-4c55-9a0e-1b7c5e2f6699', 'TELETIP_SIMULATOR',
  'YALNIZ DEV/TEST - Teletip HL7 alicisi benzetimi (MLLP 6671). Kilavuz 3.43 s.3.4 ret kurallarindan 0002 / 0003 / 0008 / 0278 ' +
  've PID-4 TCKN bicimini denetler; AA ya da AE doner. Uretimde dagitilmaz.');
sim.setSourceConnector(kaynak(mllpDinleyici(6671, 'teletip_ack'), [{
  ad: 'Bakanlik kurallari + ACK',
  betik: ALAN +
    "var ham = String(connectorMessage.getRawData());\n" +
    "var hatalar = [];\n" +
    "if (hl7Alan(ham, 'MSH', 12) != '2.3.1') hatalar.push('0002: HL7 surumu 2.3.1 olmali');\n" +
    "var pid4 = String(hl7Alan(ham, 'PID', 4) || '').split('^');\n" +
    "if (pid4[3] != 'PASS' && !/^[1-9][0-9]{10}$/.test(pid4[0])) hatalar.push('PID-4 gecerli TCKN degil (benzetim)');\n" +
    "if (String(hl7Alan(ham, 'PV1', 19) || '').split('^')[0] == '') hatalar.push('0278: PV1-19 Visit No alani bos gecilemez');\n" +
    "var obr = hl7Alan(ham, 'OBR', 4);\n" +
    "if (obr !== null) {\n" +
    "  var o4 = String(obr).split('^');\n" +
    "  if (o4.length < 2 || o4[0] == '' || o4[1] == '') hatalar.push('0008: OBR-4-1 ve OBR-4-2 alanlari eksik ya da hatali');\n" +
    "  var o24 = String(hl7Alan(ham, 'OBR', 24) || '');\n" +
    "  if (o24.length < 2 || o24.length > 16) hatalar.push('0003: OBR-24 alani en az iki karakter Modalite olmali');\n" +
    "}\n" +
    "var kod = hatalar.length == 0 ? 'AA' : 'AE';\n" +
    "var ack = ACKGenerator.generateAckResponse(ham, kod, hatalar.join(' | '));\n" +
    "responseMap.put('teletip_ack', ResponseFactory.getSentResponse(ack));\n" +
    "channelMap.put('sonuc', kod);\n"
}]));
var simHedef = new Packages.com.mirth.connect.connectors.js.JavaScriptDispatcherProperties();
simHedef.setScript('// Benzetim: mesaj yalniz arsivlenir.\nreturn;');
sim.getDestinationConnectors().add(hedef(1, 'Arsiv', 'JavaScript Writer', simHedef));
sim.setNextMetaDataId(2);
var simKolon = new java.util.ArrayList();
simKolon.add(new Kolon('SONUC', KolonTipi.STRING, 'sonuc'));
sim.getProperties().setMetaDataColumns(simKolon);

// ------------------------------------------------------------------ K2 TELETIP_KOS (1310)
// Gentegre RAD-68 (ITI-41) MTOM gövdesini HTTP ile gönderir; Mirth gövdeyi BAYT olarak (Base64) alır - multipart
// ayrıştırılmaz, DICOM eki bozulmaz - ve Gentegre'nin Content-Type başlığıyla (boundary + action) aynen
// ${teletip_xds_url}'e iletir. Yanıt (RegistryResponse) metin olarak Gentegre'ye döner (kaynak yanıtı d1).
// Yanıt dönüştürücüsü: Success değilse Mirth'te HATA (pano). Kuyruk kapalı - tekrar Gentegre'de.
function httpDinleyici(port, yol, yanitDegiskeni, yanitTuru) {
  var p = new Packages.com.mirth.connect.connectors.http.HttpReceiverProperties();
  p.getListenerConnectorProperties().setPort(String(port));
  p.getSourceConnectorProperties().setResponseVariable(yanitDegiskeni);
  p.setContextPath(yol);
  p.setXmlBody(false);
  p.setParseMultipart(false);
  p.setBinaryMimeTypes('multipart/.*|application/.*');
  p.setBinaryMimeTypesRegex(true);
  p.setResponseContentType(yanitTuru);
  p.setTimeout('120000');
  return p;
}
// Content-Type: Mirth 4 HTTP dinleyicisi içerik başlıklarını (Content-Type / Length) sourceMap 'headers'
//   (MessageHeaders) içine KOYMUYOR - denendi, yalnız [host] geliyor. Gentegre aynı değeri X-Gentegre-Content-Type
//   başlığıyla da gönderir (boundary + action dahil); hedef bu değerle Content-Type yazar.
var ICERIK_TURU = '' +
  "var tur = '';\n" +
  "var h = sourceMap.get('headers');\n" +
  "if (h != null) { try { var v = h.getHeader('X-Gentegre-Content-Type'); if (v == null) v = h.getHeader('x-gentegre-content-type'); tur = v == null ? '' : String(v); } catch (e) { } }\n" +
  "channelMap.put('icerikTuru', tur);\n";

var k2 = kanal('6d1f0c2a-7e43-4c55-9a0e-1b7c5e2f6602', 'TELETIP_KOS',
  'K2 - Gentegre -> Teletip XDS (RAD-68 / ITI-41, SOAP 1.2 + MTOM). KOS ve zarf Gentegre\'de uretilir; Mirth govdeyi bayt ' +
  'olarak (Base64) alip Content-Type ile aynen ${teletip_xds_url}\'e iletir, RegistryResponse Gentegre\'ye doner.');
k2.setSourceConnector(kaynak(httpDinleyici(8082, '/kos', 'd1', 'application/soap+xml'),
  [{ ad: 'Icerik turu', betik: ICERIK_TURU }], 'HTTP Listener'));
var k2Ozellik = new Packages.com.mirth.connect.connectors.http.HttpDispatcherProperties();
k2Ozellik.setHost('${teletip_xds_url}');
k2Ozellik.setMethod('post');
k2Ozellik.setContent('${message.rawData}');
k2Ozellik.setContentType('${icerikTuru}');
k2Ozellik.setDataTypeBinary(true);
k2Ozellik.setSocketTimeout('120000');
k2Ozellik.setResponseXmlBody(false);
k2Ozellik.setResponseParseMultipart(false);
k2Ozellik.setResponseBinaryMimeTypes('image/.*|video/.*|audio/.*');
k2Ozellik.getDestinationConnectorProperties().setQueueEnabled(false);
var k2Hedef = hedef(1, 'Teletip XDS', 'HTTP Sender', k2Ozellik);
k2Hedef.setResponseTransformer(donusturucu([{ ad: 'RegistryResponse durumu',
  betik: "if (String(msg).indexOf('ResponseStatusType:Success') < 0) { responseStatus = ERROR; }\n" }]));
k2.getDestinationConnectors().add(k2Hedef);
k2.setNextMetaDataId(2);
k2.getProperties().setMessageStorageMode(Packages.com.mirth.connect.model.MessageStorageMode.PRODUCTION);

// ------------------------------------------------------------------ TELETIP_XDS_SIMULATOR (dev, 1310)
// Kilavuz XDS 1.15 Tablo 3 yanitlari: govdede ProvideAndRegister istegi + application/dicom eki + DICM varsa Success /
// MatchStatus (institutionId = sourceId'deki SKRS); hasta kimligi bossa Failure XDSRepositoryError. Uretimde dagitilmaz.
var simXds = kanal('6d1f0c2a-7e43-4c55-9a0e-1b7c5e2f6698', 'TELETIP_XDS_SIMULATOR',
  'YALNIZ DEV/TEST - Teletip XDS (RAD-68) alicisi benzetimi (HTTP 8083 /xds, konteyner ici). Kilavuz XDS 1.15 Tablo 3 ' +
  'Success / Failure yanitlari doner. Uretimde dagitilmaz.');
simXds.setSourceConnector(kaynak(httpDinleyici(8083, '/xds', 'xds_yanit', 'application/soap+xml'), [{
  ad: 'RAD-68 benzetimi',
  betik:
    "var ham = new java.lang.String(org.apache.commons.codec.binary.Base64.decodeBase64(String(connectorMessage.getRawData())), 'ISO-8859-1');\n" +
    "var s = String(ham);\n" +
    "var hasta = (s.match(/name=\"sourcePatientId\"><rim:ValueList><rim:Value>([^<^]*)/) || [])[1] || '';\n" +
    "var skrs = ((s.match(/1\\.3\\.6\\.1\\.4\\.1\\.21367\\.2017\\.10\\.26\\.(\\d+)/) || [])[1]) || '-1';\n" +
    "var hata = '';\n" +
    "if (s.indexOf('ProvideAndRegisterDocumentSetRequest') < 0) hata = 'ProvideAndRegisterDocumentSetRequest yok';\n" +
    "else if (s.indexOf('application/dicom') < 0 || s.indexOf('DICM') < 0) hata = 'KOS (application/dicom, DICM) eki yok';\n" +
    "else if (hasta == '') hata = 'Hastaya ait bilgilerden PatientID/OtherPatientIDs bos olamaz.';\n" +
    "var rs = 'urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0';\n" +
    "var y = hata == ''\n" +
    "  ? '<rs:RegistryResponse xmlns:rs=\"' + rs + '\" status=\"urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success\"><rs:RegistryErrorList>' +\n" +
    "    '<rs:RegistryError codeContext=\"{ &quot;result&quot;: true, &quot;institutionId&quot;: ' + skrs + ', &quot;citizenId&quot;: &quot;' + hasta + '&quot;, &quot;accessionNumberList&quot;: &quot;[]&quot;, &quot;error&quot;: &quot;&quot;}\" ' +\n" +
    "    'errorCode=\"MatchStatus\" location=\"Benzetim\" severity=\"urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Warning\"/></rs:RegistryErrorList></rs:RegistryResponse>'\n" +
    "  : '<rs:RegistryResponse xmlns:rs=\"' + rs + '\" status=\"urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Failure\"><rs:RegistryErrorList>' +\n" +
    "    '<rs:RegistryError codeContext=\"' + hata + '\" errorCode=\"XDSRepositoryError\" location=\"Benzetim\" severity=\"urn:oasis:names:tc:ebxml-regrep:ErrorSeverityType:Error\"/></rs:RegistryErrorList></rs:RegistryResponse>';\n" +
    "var zarf = '<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\"><s:Body>' + y + '</s:Body></s:Envelope>';\n" +
    "responseMap.put('xds_yanit', ResponseFactory.getSentResponse(zarf));\n" +
    "channelMap.put('sonuc', hata == '' ? 'Success' : 'Failure');\n"
}], 'HTTP Listener'));
var simXdsHedef = new Packages.com.mirth.connect.connectors.js.JavaScriptDispatcherProperties();
simXdsHedef.setScript('// Benzetim: istek yalniz arsivlenir.\nreturn;');
simXds.getDestinationConnectors().add(hedef(1, 'Arsiv', 'JavaScript Writer', simXdsHedef));
simXds.setNextMetaDataId(2);
var simXdsKolon = new java.util.ArrayList();
simXdsKolon.add(new Kolon('SONUC', KolonTipi.STRING, 'sonuc'));
simXds.getProperties().setMetaDataColumns(simXdsKolon);

new java.io.File('/tmp/kanallar').mkdirs();
function yaz(c, dosya) {
  var w = new java.io.OutputStreamWriter(new java.io.FileOutputStream('/tmp/kanallar/' + dosya), 'UTF-8');
  w.write(Ser.serialize(c)); w.close();
  print('yazildi: ' + dosya);
}
yaz(k1, 'TELETIP_HL7.xml');
yaz(sim, 'TELETIP_SIMULATOR.xml');
yaz(k2, 'TELETIP_KOS.xml');
yaz(simXds, 'TELETIP_XDS_SIMULATOR.xml');
