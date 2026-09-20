import { chromium } from 'playwright';
const t = await chromium.connectOverCDP('http://127.0.0.1:9222');
const s = await t.contexts()[0].newPage();
await s.setViewportSize({ width: 1500, height: 900 });
await s.goto('http://127.0.0.1:5173/', { waitUntil: 'domcontentloaded' });
await s.evaluate(() => { try { localStorage.clear() } catch {} });
await s.reload({ waitUntil: 'domcontentloaded' });
await s.waitForTimeout(1000);
const k = await s.$$('input');
await k[0].fill('admin');
await (await s.$('input[type="password"]')).fill('060110*Tuna');
await s.keyboard.press('Enter');
await s.waitForTimeout(2500);
await s.goto('http://127.0.0.1:5173/hasta', { waitUntil: 'domcontentloaded' });
await s.waitForTimeout(2000);
// ilk satiri sec
const satir = await s.$('table.grid tbody tr');
if (satir) { await satir.click(); await s.waitForTimeout(800); }
console.log(JSON.stringify(await s.evaluate(() => ({
  dugmeler: [...document.querySelectorAll('.sayfabas button, .cipler button')]
    .map(b => b.textContent.trim()).filter(Boolean).slice(0, 25),
}))));
await s.bringToFront();
await s.screenshot({ path: 'C:/Users/HP/AppData/Local/Temp/claude/hasta_liste.png' });
await s.close(); await t.close();
