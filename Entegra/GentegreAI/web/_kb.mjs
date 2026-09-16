import { chromium } from 'playwright';
const out = 'C:/Users/HP/AppData/Local/Temp/claude/C--Users-HP-Entegra-Entegra/7734ac55-0f03-4348-86c3-bea5f148370d/scratchpad/';
const giris = await (await fetch('http://localhost:5180/api/kimlik/giris', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ kod: 'admin', parola: '060110*Tuna' }) })).json();
const b = await chromium.launch({ channel: 'msedge' });
const p = await b.newPage({ viewport: { width: 1440, height: 900 } });
const hatalar = []; p.on('pageerror', e => hatalar.push('PAGEERROR ' + e.message));
p.on('response', async r => { if (r.status() >= 400 && r.url().includes('/api/')) { let g=''; try { g=(await r.text()).slice(0,200) } catch {} hatalar.push(`HTTP ${r.status()} ${r.url()} ${g}`); } });
await p.goto('http://localhost:5173/');
await p.evaluate(g => { localStorage.setItem('gentegre.access', g.accessToken); localStorage.setItem('gentegre.refresh', g.refreshToken ?? ''); localStorage.setItem('gentegre.sube', '1'); }, giris);
const w = ms => p.waitForTimeout(ms);
await p.goto('http://localhost:5173/dis-lab-isemri'); await w(2500);
await p.locator('button.cip', { hasText: 'Kanban' }).first().click(); await w(2000);
console.log('kart sayisi', await p.locator('.ds-kb-kart').count());
await p.screenshot({ path: out + 'kb1.png' });
const olcu = p.locator('.ds-kb-kol.olcu .ds-kb-kart').first();
if (await olcu.count()) { await olcu.click(); await w(600); }
await p.screenshot({ path: out + 'kb2.png' });
const btn = p.locator('.ds-kb-asamalar button', { hasText: 'Gönderildi' }).first();
if (await btn.count()) { await btn.click(); await w(1500); console.log('gonderildi tiklandi'); }
console.log('labda sayisi', await p.locator('.ds-kb-kol.labda .ds-kb-kart').count(), 'gecmis', await p.locator('.ds-kb-liste li').count());
const src = p.locator('.ds-kb-kol.labda .ds-kb-kart').first(); const dst = p.locator('.ds-kb-kol.geldi');
if (await src.count()) { await src.dragTo(dst); await w(1500); console.log('drag sonrasi geldi', await p.locator('.ds-kb-kol.geldi .ds-kb-kart').count()); }
await p.screenshot({ path: out + 'kb3.png' });
await p.locator('.cip', { hasText: 'Laba göre' }).first().click(); await w(500); await p.screenshot({ path: out + 'kb4.png' });
await p.locator('.cip', { hasText: 'Kurye günü' }).first().click(); await w(500); await p.screenshot({ path: out + 'kb5.png' });
console.log('HATALAR', hatalar.length ? hatalar.join('\n') : 'yok');
await b.close();
