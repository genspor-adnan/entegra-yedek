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

function kaynak(ozellik, adimlar) {
  var k = new Connector();
  k.setMetaDataId(0); k.setName('sourceConnector'); k.setMode(Connector.Mode.SOURCE);
  k.setTransportName('TCP Listener'); k.setProperties(ozellik); k.setEnabled(true);
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

new java.io.File('/tmp/kanallar').mkdirs();
function yaz(c, dosya) {
  var w = new java.io.OutputStreamWriter(new java.io.FileOutputStream('/tmp/kanallar/' + dosya), 'UTF-8');
  w.write(Ser.serialize(c)); w.close();
  print('yazildi: ' + dosya);
}
yaz(k1, 'TELETIP_HL7.xml');
yaz(sim, 'TELETIP_SIMULATOR.xml');
