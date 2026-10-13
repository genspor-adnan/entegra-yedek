import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { describe, it, expect } from 'vitest';
import { chromium, type Browser, type Page } from 'playwright';
import { LISTELER } from '../src/sayfalar/listeTanimlari';

/**
 * DUMAN TESTİ - BÜTÜN MENÜ (dokuman/17, kullanıcı 13.10.2026: "duman testini kur").
 *
 * Menü tanımlarındaki (LISTELER) her ekranı gerçek tarayıcıda açar; listede
 * kayıt varsa ilk satırın KARTINI da açar. Her adımda toplanır:
 *   · sayfa / konsol hatası (JS istisnası, React hatası)
 *   · sunucudan 500'lü yanıt (adres + izleme numarası hata_log'da)
 *   · ekrandaki hata kutusu (.hata-kutusu)
 * Sonuç `duman/sonuc/duman-<tarih>.md` raporu; hata varsa test kırmızı.
 *
 * Çalıştırma (API 5180 + web 5173 ayakta olmalı):
 *   $env:DUMAN_SIFRE = '...'; npm run duman
 *   $env:DUMAN_GRUP = 'Kalite'          # yalnız bir menü grubu
 *   $env:DUMAN_PARALEL = '4'            # aynı anda açılan sekme (varsayılan 3)
 *   $env:DUMAN_KART = '0'               # kartları açma (yalnız listeler)
 * Parola koda / depoya YAZILMAZ; ortam değişkeninden okunur.
 *
 * Yalnız OKUR: kart açılır, kaydedilmez; aksiyon düğmesine basılmaz.
 */
const URL = process.env.DUMAN_URL ?? 'http://localhost:5173';
const KULLANICI = process.env.DUMAN_KULLANICI ?? 'admin';
const SIFRE = process.env.DUMAN_SIFRE ?? '';
const GRUP = process.env.DUMAN_GRUP ?? '';
const PARALEL = Math.max(1, Number(process.env.DUMAN_PARALEL ?? 3));
const KART = process.env.DUMAN_KART !== '0';

type Sonuc = { rota: string; baslik: string; grup: string; durum: 'tamam' | 'hata' | 'yok'; satir: number; kart: string; hatalar: string[]; uyarilar: string[] };

/**
 * EKRANDAKİ KUTU: `.hata-kutusu` bazı ekranlarda İŞ UYARISI için de kullanılıyor
 * ("biyolojik test 23 gündür yapılmadı", "şubede e-Belge bilgisi eksik"). Kutu
 * metni ancak gerçek hata işareti taşıyorsa hata sayılır; öteki raporda uyarı.
 */
const GERCEK_HATA = /bilinmeyen|beklenmeyen|izleme|ula[sş][iı]lamad[iı]|sunucu|exception|undefined/i;

/** Sayfa kendi kendine yönlenirken okuma "context destroyed" verir - bir kez daha dene. */
async function metinler(p: Page, secici: string): Promise<string[]> {
  for (let i = 0; i < 3; i++) {
    try { return await p.locator(secici).allInnerTexts() }
    catch { await p.waitForTimeout(1000) }
  }
  return [];
}

/** Menüde açılabilen ekranlar: rotası olan, menü adı olan; aynı rota bir kez. */
function ekranlar() {
  const gorulen = new Set<string>();
  return LISTELER
    .filter(l => l.menuAd && (!GRUP || l.menuGrup === GRUP))
    .map(l => ({ l, rota: l.rota ?? l.kaynak }))
    .filter(({ rota }) => !gorulen.has(rota) && (gorulen.add(rota), true));
}

async function girisYap(tarayici: Browser) {
  const baglam = await tarayici.newContext({ viewport: { width: 1600, height: 1000 } });
  const p = await baglam.newPage();
  await p.goto(URL + '/');
  await p.waitForSelector('input[type="password"]', { timeout: 90_000 });
  await p.locator('input').first().fill(KULLANICI);
  await p.fill('input[type="password"]', SIFRE);
  await p.locator('button', { hasText: /Giri[sş]/ }).click();
  await p.waitForTimeout(4000);
  // Çok şubeli kullanıcıda şube seçimi: ilk şubeyle devam.
  if (await p.locator('button', { hasText: 'Devam' }).count()) {
    await p.locator('button', { hasText: 'Devam' }).click();
    await p.waitForTimeout(3000);
  }
  await p.close();
  return baglam;
}

/** Sayfa içinde SPA gezinmesi (tam yükleme yok - hızlı). */
async function git(p: Page, yol: string) {
  // Önceki ekran sayfayı yeniden yüklüyorsa (yönlendirme) bağlam yok olur:
  //   yüklenmesini bekleyip yeniden dene - bu uygulama hatası değil.
  for (let i = 0; ; i++) {
    try {
      await p.evaluate(y => { history.pushState({}, '', y); dispatchEvent(new PopStateEvent('popstate')) }, yol);
      return;
    } catch (h) {
      if (i >= 2) throw h;
      await p.waitForLoadState('load').catch(() => {});
      await p.waitForTimeout(1500);
    }
  }
}

async function ekranDene(p: Page, e: ReturnType<typeof ekranlar>[number]): Promise<Sonuc> {
  const hatalar: string[] = [];
  const dinle = {
    hata: (h: Error) => hatalar.push('JS: ' + h.message.slice(0, 200)),
    konsol: (m: import('playwright').ConsoleMessage) => {
      if (m.type() !== 'error') return;
      const t = m.text();
      // 4xx yanıtların tarayıcı satırı (yetki / bulunamadı) duman hatası değil; 500 ayrıca yakalanır.
      if (/Failed to load resource: the server responded with a status of 4\d\d/.test(t)) return;
      if (/status of 5\d\d/.test(t)) return;
      hatalar.push('KONSOL: ' + t.slice(0, 200));
    },
    yanit: async (r: import('playwright').Response) => {
      if (r.status() < 500) return;
      let izleme = '';
      try { izleme = (await r.json())?.hata?.izlemeNo ?? '' } catch { /* gövde yok */ }
      hatalar.push(`SUNUCU ${r.status()} ${r.request().method()} ${r.url().replace(/^https?:\/\/[^/]+/, '')}${izleme ? ` (izleme ${izleme})` : ''}`);
    },
  };
  p.on('pageerror', dinle.hata);
  p.on('console', dinle.konsol);
  p.on('response', dinle.yanit);
  const uyarilar: string[] = [];
  const kutu = (onEk: string, metin: string) =>
    (GERCEK_HATA.test(metin) ? hatalar : uyarilar).push(`${onEk}: ${metin.slice(0, 200)}`);
  const sonuc: Sonuc = { rota: e.rota, baslik: e.l.menuAd ?? e.l.baslik, grup: e.l.menuGrup ?? '', durum: 'tamam', satir: 0, kart: '', hatalar, uyarilar };
  try {
    await git(p, '/' + e.rota);
    await p.waitForTimeout(1800);
    // Rota bu kurulumda yoksa (ürün modu / modül kapalı) uygulama ana sayfaya döner.
    if (!p.url().includes('/' + e.rota)) { sonuc.durum = 'yok'; return sonuc }
    for (const t of await metinler(p, '.hata-kutusu')) kutu('EKRAN', t);
    sonuc.satir = await p.locator('table tbody tr').count().catch(() => 0);

    if (KART && !e.l.ozelSayfa && e.l.kartYolu && sonuc.satir > 0) {
      const ilk = p.locator('table tbody tr').first();
      if ((await ilk.locator('td').count()) > 1) {
        await ilk.dblclick({ timeout: 3000 }).catch(() => {});
        await p.waitForTimeout(1800);
        sonuc.kart = p.url().replace(/^https?:\/\/[^/]+/, '');
        for (const t of await metinler(p, '.hata-kutusu')) kutu('KART', t);
        await p.keyboard.press('Escape').catch(() => {});
      }
    }
  } catch (h) {
    hatalar.push('DUMAN: ' + (h as Error).message.slice(0, 200));
  } finally {
    p.off('pageerror', dinle.hata);
    p.off('console', dinle.konsol);
    p.off('response', dinle.yanit);
  }
  if (hatalar.length && sonuc.durum !== 'yok') sonuc.durum = 'hata';
  return sonuc;
}

function rapor(sonuclar: Sonuc[], sure: number) {
  const hatali = sonuclar.filter(s => s.durum === 'hata');
  const satirlar = [
    `# Duman testi — ${new Date().toLocaleString('tr-TR')}`,
    '',
    `${sonuclar.length} ekran · ${sonuclar.filter(s => s.durum === 'tamam').length} tamam · **${hatali.length} hatalı** · `
      + `${sonuclar.filter(s => s.durum === 'yok').length} bu kurulumda yok · ${Math.round(sure / 1000)} sn`
      + (GRUP ? ` · grup: ${GRUP}` : ''),
    '',
    '## Hatalı ekranlar',
    '',
    ...(hatali.length ? hatali.flatMap(s => [`### ${s.grup} › ${s.baslik} (\`/${s.rota}\`)${s.kart ? ` · kart \`${s.kart}\`` : ''}`, '',
      ...[...new Set(s.hatalar)].map(h => `- ${h}`), '']) : ['Yok.', '']),
    '## Uyarılar (testi kırmızı yapmaz)',
    '',
    ...(sonuclar.some(s => s.uyarilar.length)
      ? sonuclar.filter(s => s.uyarilar.length).flatMap(s => [`- **${s.grup} › ${s.baslik}**: ${[...new Set(s.uyarilar)].join(' · ')}`])
      : ['Yok.']),
    '',
    '## Bütün ekranlar',
    '',
    '| Grup | Ekran | Rota | Durum | Satır | Kart |',
    '|---|---|---|---|---|---|',
    ...sonuclar.map(s => `| ${s.grup} | ${s.baslik} | /${s.rota} | ${s.durum} | ${s.satir} | ${s.kart} |`),
  ];
  const dizin = join(process.cwd(), 'duman', 'sonuc');
  mkdirSync(dizin, { recursive: true });
  const dosya = join(dizin, `duman-${new Date().toISOString().slice(0, 16).replace(/[:T]/g, '-')}.md`);
  writeFileSync(dosya, satirlar.join('\n'), 'utf8');
  return dosya;
}

describe('duman testi', () => {
  it('menüdeki her ekran ve ilk kaydın kartı hatasız açılır', async () => {
    expect(SIFRE, 'DUMAN_SIFRE ortam değişkeni gerekli (giriş parolası)').not.toBe('');
    const liste = ekranlar();
    expect(liste.length).toBeGreaterThan(0);
    const bas = Date.now();
    const tarayici = await chromium.launch({ channel: 'chrome' });
    try {
      const baglam = await girisYap(tarayici);
      // Ana sayfa bir kez yüklenir, sonra her sekme SPA içinde gezinir.
      const sayfalar = await Promise.all(Array.from({ length: PARALEL }, async () => {
        const p = await baglam.newPage();
        await p.goto(URL + '/');
        await p.waitForTimeout(3000);
        return p;
      }));
      const sonuclar: Sonuc[] = [];
      let sira = 0;
      await Promise.all(sayfalar.map(async p => {
        while (sira < liste.length) {
          const e = liste[sira++];
          sonuclar.push(await ekranDene(p, e));
        }
      }));
      sonuclar.sort((a, b) => (a.grup + a.baslik).localeCompare(b.grup + b.baslik, 'tr'));
      const dosya = rapor(sonuclar, Date.now() - bas);
      const hatali = sonuclar.filter(s => s.durum === 'hata');
      console.log(`Duman: ${sonuclar.length} ekran, ${hatali.length} hatalı. Rapor: ${dosya}`);
      expect(hatali.map(s => `${s.grup} › ${s.baslik}: ${s.hatalar[0]}`)).toEqual([]);
    } finally {
      await tarayici.close();
    }
  });
});
