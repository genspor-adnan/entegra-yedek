// BAKANLIK HL7 DOĞRULAYICISIYLA YEREL DENEME (12.11.2026; kullanıcı: "test ortamını oluştur.. deneyelim").
//
// Bakanlık'ın https://teleradyoloji.saglik.gov.tr/hl7validasyon.html sayfası mesajı TAMAMEN tarayıcıda (sayfanın kendi
// JavaScript'i) denetler. Bu araç sayfayı bir kez yükler, ardından BÜTÜN ağ isteklerini keser (veri dışarı çıkamaz),
// verilen HL7 dosyalarını ilgili sekmeye yapıştırıp "Kontrol Et"e basar ve kırmızı alanları yazar.
// Dikkat: doğrulayıcı sayfa eski kılavuza göre yazılmış olabilir (ör. MSH-5/6 "TELETIP" ister, kılavuz 3.68 tablosu
// "TELERADYOLOJI" der) - kırmızı her alan hata değildir, kılavuzla karşılaştırın.
//
// Kullanım (web/ klasöründen; Edge kurulu olmalı):
//   node araclar/teleradyoloji-hl7-dogrula.mjs mesaj1.hl7 mesaj2.hl7 ...
// Mesajı DB'den almak için (segment ayırıcı \r olabilir, araç çevirir):
//   docker exec gentegre-pg18 psql -U postgres -d KOSUYOLU -tAc "select mesaj from teletip_gonderim where id = 5" > nw.hl7
import { chromium } from 'playwright';
import fs from 'node:fs';

const dosyalar = process.argv.slice(2);
if (dosyalar.length === 0) { console.error('Kullanım: node araclar/teleradyoloji-hl7-dogrula.mjs <dosya.hl7> ...'); process.exit(2); }

const SEKME = { NW: [1, 'btn_tistek'], XO: [2, 'btn_tguncelleme'], CA: [3, 'btn_tiptal'], ORU: [4, 'btn_raporaktarimi'] };
function tur(metin) {
  const satir = metin.split('\n');
  if ((satir[0] || '').split('|')[8]?.startsWith('ORU')) return 'ORU';
  const orc = satir.find(s => s.startsWith('ORC|'));
  return orc?.split('|')[1] ?? '?';
}

const tarayici = await chromium.launch({ channel: 'msedge' });
const sayfa = await tarayici.newPage({ viewport: { width: 1400, height: 1000 } });
await sayfa.goto('https://teleradyoloji.saglik.gov.tr/hl7validasyon.html', { waitUntil: 'load' });
const kesilen = [];
await sayfa.route('**/*', r => { kesilen.push(`${r.request().method()} ${r.request().url()}`); return r.abort(); });
sayfa.on('dialog', d => d.dismiss());

let toplamKirmizi = 0;
for (const yol of dosyalar) {
  const metin = fs.readFileSync(yol, 'utf8').replace(/^﻿/, '').replace(/\r\n?/g, '\n').trim();
  const t = tur(metin);
  const s = SEKME[t];
  if (!s) { console.log(`== ${yol}: mesaj türü anlaşılamadı (${t})`); continue; }
  const [id, dugme] = s;
  await sayfa.click('#' + dugme);
  await sayfa.fill('#_textareainfo' + id, metin);
  await sayfa.locator(`#_textareainfo${id}`).locator('xpath=ancestor::*[.//button[@id="btn_control"]][1]').locator('#btn_control').first().click();
  await sayfa.waitForTimeout(400);
  const r = await sayfa.evaluate(no => {
    let kok = document.getElementById('_textareainfo' + no);
    while (kok && kok.querySelectorAll('input[readonly]').length < 20) kok = kok.parentElement;
    const o = { kirmizi: [], yesil: 0, bos: 0 };
    for (const i of kok.querySelectorAll('input[readonly]')) {
      const bg = getComputedStyle(i).backgroundColor;
      const etiket = (i.parentElement?.innerText || '').trim().replace(/\s+/g, ' ').slice(0, 50);
      if (bg.includes('255, 0, 0')) o.kirmizi.push(`${etiket} => ${i.value}`);
      else if (bg.includes('0, 128, 0')) o.yesil++; else o.bos++;
    }
    return o;
  }, id);
  toplamKirmizi += r.kirmizi.length;
  console.log(`== ${yol} (${t}): yeşil ${r.yesil}, kırmızı ${r.kirmizi.length}, denetlenmeyen ${r.bos}`);
  for (const k of r.kirmizi) console.log('   ✖ ' + k);
}
console.log(`Kesilen ağ isteği: ${kesilen.length} (sayfa yüklendikten sonra dışarı hiçbir şey gitmez)`);
await tarayici.close();
process.exit(toplamKirmizi > 0 ? 1 : 0);
