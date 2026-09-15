import type {
  AlanTipi, DokumKolonMeta, DokumTanimi, Kosul, KosulOp, OzetOlcu, OzetYaniti,
} from '../../api/sozlesme';
import { bugunIso } from '../../bilesenler/bicim';

/**
 * DÖKÜM TASARIMCISININ SAF HESAPLARI (686) — React'siz, test edilebilir.
 *
 * Burada SQL yok, sunucu çağrısı yok: tanım nesnesi üzerinde küçük düzenleme
 * yardımcıları, okunabilir tanım cümlesi, özet yanıtını çapraz tabloya
 * dağıtma (pivot), kıyas Δ'sı ve liste satırlarını gruplu/ara toplamlı
 * biçime çevirme. Önizleme ve baskı AYNI fonksiyonları kullanır - ekranda
 * görünen rakam kâğıttakinden sapamaz.
 */

export const FN_ETIKET: Record<string, string> = {
  adet: 'Adet', tekil: 'Tekil sayı', toplam: 'Toplam', ortalama: 'Ortalama',
  min: 'En az', max: 'En çok', medyan: 'Medyan', p90: 'P90', oran: 'Oran',
};

export const KESME_ETIKET: Record<string, string> = {
  '': 'Gün (ham)', gun: 'Gün', hafta: 'Hafta', ay: 'Ay', ceyrek: 'Çeyrek', yil: 'Yıl',
  haftaGunu: 'Haftanın günü', saat: 'Saat',
};

export const KURAL_ETIKET: Record<string, string> = {
  '': 'Sabit değer', bugun: 'Bugün', dun: 'Dün', buHafta: 'Bu hafta', gecenHafta: 'Geçen hafta',
  buAy: 'Bu ay', gecenAy: 'Geçen ay', buCeyrek: 'Bu çeyrek', buYil: 'Bu yıl',
  son7: 'Son 7 gün', son30: 'Son 30 gün',
};

export const KIYAS_ETIKET: Record<string, string> = {
  yok: 'Kıyas yok', oncekiDonem: 'Önceki dönem', oncekiYil: 'Önceki yıl aynı dönem',
};

export const GORUNURLUK_ETIKET: Record<number, string> = {
  0: 'Bana özel', 1: 'Rollerle paylaşılan', 2: 'Kurum geneli',
};

/** Operatör listesi ALANIN TİPİNE göre (mockup: tarih arasında, liste şunlardan biri…). */
export function operatorler(tip: AlanTipi): { op: KosulOp; ad: string }[] {
  switch (tip) {
    case 'tarih': case 'zaman':
      return [{ op: 'arasinda', ad: 'arasında' }, { op: 'esit', ad: 'eşit' },
              { op: 'buyukEsit', ad: 'sonrası (dahil)' }, { op: 'kucukEsit', ad: 'öncesi (dahil)' },
              { op: 'bos', ad: 'boş' }, { op: 'bosDegil', ad: 'dolu' }];
    case 'sayi': case 'ondalik': case 'para':
      return [{ op: 'esit', ad: 'eşit' }, { op: 'esitDegil', ad: 'değil' },
              { op: 'buyukEsit', ad: 'büyük eşit' }, { op: 'kucukEsit', ad: 'küçük eşit' },
              { op: 'buyuk', ad: 'büyük' }, { op: 'kucuk', ad: 'küçük' },
              { op: 'arasinda', ad: 'arasında' }, { op: 'bos', ad: 'boş' }];
    case 'kod': case 'mantik':
      return [{ op: 'esit', ad: 'eşit' }, { op: 'esitDegil', ad: 'değil' },
              { op: 'icinde', ad: 'şunlardan biri' }, { op: 'bos', ad: 'boş' }];
    default:
      return [{ op: 'icerir', ad: 'içerir' }, { op: 'esit', ad: 'eşit' }, { op: 'esitDegil', ad: 'değil' },
              { op: 'baslar', ad: 'başlar' }, { op: 'icinde', ad: 'şunlardan biri' },
              { op: 'bos', ad: 'boş' }, { op: 'bosDegil', ad: 'dolu' }];
  }
}

export function bosTanim(kaynak = ''): DokumTanimi {
  return {
    kaynak, cikti: 'liste', filtre: { op: 'and', kosullar: [] }, kolonlar: [], sirala: [],
    toplam: [], grup: [], boyut: { satir: [], sutun: null }, olcu: [{ fn: 'adet' }],
    kiyas: 'yok', esik: 0, parametreler: {}, baski: bosBaski(),
  };
}

export function bosBaski() {
  return {
    yon: 'dikey' as const, kurumBasligi: true, parametreKutusu: true, sayfaNo: true,
    damga: false, imza: false, dipnot: '', ozetGostergeler: true, araToplam: true,
    capraz: true, satirTavani: 2000, gizliKolonlar: [],
  };
}

/** Kök VE dalının yaprakları - tasarımcı tek seviye çizer (VEYA grubu ileride). */
export function yapraklar(tanim: DokumTanimi): Kosul[] {
  return tanim.filtre?.kosullar ?? [];
}

export function yapraklariYaz(tanim: DokumTanimi, k: Kosul[]): DokumTanimi {
  return { ...tanim, filtre: { op: 'and', kosullar: k } };
}

/** Operatörün kaç değer istediği: 0 boş/dolu · 2 arasında · -1 liste · 1 tek. */
export function degerSayisi(op: string): number {
  if (op === 'bos' || op === 'bosDegil') return 0;
  if (op === 'arasinda') return 2;
  if (op === 'icinde') return -1;
  return 1;
}

/** "a, b ,c" → ["a","b","c"]; boşlar düşer. */
export const listeyeCevir = (metin: string): string[] =>
  metin.split(/[,;\n]/).map(s => s.trim()).filter(Boolean);

/** Çalıştırırken sorulacak alanlar: parametre işaretli yapraklar, tanım sırasıyla. */
export function parametreAlanlari(tanim: DokumTanimi): { alan: string; ad: string; kural: string; op: string }[] {
  const p = tanim.parametreler ?? {};
  return yapraklar(tanim)
    .filter(k => k.alan && p[k.alan])
    .map(k => ({ alan: k.alan!, ad: p[k.alan!].ad || k.alan!, kural: p[k.alan!].kural, op: k.op }));
}

/** Sunucudaki ParametreCozucu.KuralAraligi'nin ekran kopyası - varsayılan değer gösterimi. */
export function kuralAraligi(kural: string, bugun = new Date()): [string, string] | null {
  const g = new Date(bugun.getFullYear(), bugun.getMonth(), bugun.getDate());
  const gun = (d: Date) => bugunIso(d);
  const ekle = (d: Date, n: number) => new Date(d.getFullYear(), d.getMonth(), d.getDate() + n);
  const pzt = (d: Date) => ekle(d, -((d.getDay() + 6) % 7));
  const ayBas = (y: number, m: number) => new Date(y, m, 1);
  switch (kural) {
    case 'bugun': return [gun(g), gun(g)];
    case 'dun': return [gun(ekle(g, -1)), gun(ekle(g, -1))];
    case 'buHafta': return [gun(pzt(g)), gun(ekle(pzt(g), 6))];
    case 'gecenHafta': { const p = ekle(pzt(g), -7); return [gun(p), gun(ekle(p, 6))]; }
    case 'buAy': return [gun(ayBas(g.getFullYear(), g.getMonth())), gun(ekle(ayBas(g.getFullYear(), g.getMonth() + 1), -1))];
    case 'gecenAy': return [gun(ayBas(g.getFullYear(), g.getMonth() - 1)), gun(ekle(ayBas(g.getFullYear(), g.getMonth()), -1))];
    case 'buCeyrek': { const ay = Math.floor(g.getMonth() / 3) * 3; return [gun(ayBas(g.getFullYear(), ay)), gun(ekle(ayBas(g.getFullYear(), ay + 3), -1))]; }
    case 'buYil': return [gun(ayBas(g.getFullYear(), 0)), gun(new Date(g.getFullYear(), 11, 31))];
    case 'son7': return [gun(ekle(g, -6)), gun(g)];
    case 'son30': return [gun(ekle(g, -29)), gun(g)];
    default: return null;
  }
}

const kolonAdi = (kolonlar: DokumKolonMeta[], ad: string) =>
  kolonlar.find(k => k.ad === ad)?.baslik ?? ad;

const OP_METIN: Record<string, string> = {
  esit: '=', esitDegil: '≠', icerir: 'içerir', baslar: 'ile başlar', biter: 'ile biter',
  buyuk: '>', buyukEsit: '≥', kucuk: '<', kucukEsit: '≤', arasinda: 'arasında',
  bos: 'boş', bosDegil: 'dolu', icinde: '∈',
};

export function degerMetni(k: Kosul, parametreMi: boolean): string {
  if (parametreMi) return '〔sorulur〕';
  const d = k.deger;
  if (d === undefined || d === null || d === '') return '';
  if (Array.isArray(d)) return k.op === 'arasinda' ? `${d[0] ?? ''} – ${d[1] ?? ''}` : `{${d.join(', ')}}`;
  return String(d);
}

/** Mockup "Tanım Özeti": tanım tek cümle - kullanıcı ne tasarladığını okusun. */
export function tanimCumlesi(tanim: DokumTanimi, kolonlar: DokumKolonMeta[], kaynakAdi: string): string {
  const p = tanim.parametreler ?? {};
  const kosullar = yapraklar(tanim)
    .filter(k => k.alan)
    .map(k => `${kolonAdi(kolonlar, k.alan!)} ${OP_METIN[k.op] ?? k.op} ${degerMetni(k, !!p[k.alan!])}`.trim());
  const parcalar: string[] = [`${kaynakAdi} kaynağından`];
  if (kosullar.length) parcalar.push(kosullar.join(', ') + ' olan kayıtlar');
  else parcalar.push('tüm kayıtlar');
  if (tanim.cikti === 'ozet') {
    const b = [...(tanim.boyut?.satir ?? []), ...(tanim.boyut?.sutun ? [tanim.boyut.sutun] : [])]
      .map(x => boyutEtiketi(x, kolonlar));
    const o = (tanim.olcu ?? []).map(x => olcuEtiketi(x, kolonlar));
    parcalar.push(`${b.join(' › ')} kırılımında ${o.join(', ')}`);
    if (tanim.kiyas !== 'yok') parcalar.push(`(${KIYAS_ETIKET[tanim.kiyas]} ile kıyaslı)`);
  } else {
    if (tanim.grup?.length) parcalar.push(`${tanim.grup.map(g => kolonAdi(kolonlar, g)).join(' › ')} gruplu`);
    if (tanim.sirala?.length)
      parcalar.push(tanim.sirala.map(s => `${kolonAdi(kolonlar, s.alan)} ${s.yon === 'desc' ? '↓' : '↑'}`).join(', '));
    if (tanim.toplam?.length) parcalar.push(`Σ ${tanim.toplam.map(t => kolonAdi(kolonlar, t)).join(' / ')}`);
  }
  return parcalar.join('; ') + '.';
}

export function boyutEtiketi(boyut: string, kolonlar: DokumKolonMeta[]): string {
  const i = boyut.indexOf(':');
  const alan = i < 0 ? boyut : boyut.slice(0, i);
  const kesme = i < 0 ? '' : boyut.slice(i + 1);
  return kesme ? `${kolonAdi(kolonlar, alan)} · ${KESME_ETIKET[kesme] ?? kesme}` : kolonAdi(kolonlar, alan);
}

export function olcuEtiketi(o: { fn: string; alan?: string | null; bolen?: string | null; baslik?: string | null },
                            kolonlar: DokumKolonMeta[]): string {
  if (o.baslik) return o.baslik;
  if (o.fn === 'adet') return 'Adet';
  if (o.fn === 'oran') return `${kolonAdi(kolonlar, o.alan ?? '')} / ${kolonAdi(kolonlar, o.bolen ?? '')}`;
  const on: Record<string, string> = { toplam: 'Σ', ortalama: 'Ort.', tekil: 'Tekil', min: 'En az', max: 'En çok', medyan: 'Medyan', p90: 'P90' };
  return `${on[o.fn] ?? o.fn} ${kolonAdi(kolonlar, o.alan ?? '')}`;
}

/** Sunucunun özet kolon adı: "alan_fn" ya da "adet"; boyutlarda "alan_kesme". */
export const olcuKolonAdi = (o: { fn: string; alan?: string | null }) => o.alan ? `${o.alan}_${o.fn}` : o.fn;
export const boyutKolonAdi = (b: string) => b.replace(':', '_');

/** Ölçü değerini biçime göre yazar. Oran yüzde, adet tam sayı, diğerleri 2 hane. */
export function olcuBicimle(v: unknown, bicim: string): string {
  if (v === null || v === undefined || v === '') return '—';
  const s = Number(v);
  if (!Number.isFinite(s)) return String(v);
  if (bicim === '%') return `%${(s * 100).toLocaleString('tr-TR', { maximumFractionDigits: 1 })}`;
  if (bicim === '#,##0') return s.toLocaleString('tr-TR', { maximumFractionDigits: 0 });
  return s.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

/** Boyut değerinin ekran metni: ay "2026-09" → "Eyl 2026", haftanın günü 1 → "Pzt". */
const AYLAR = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
const GUNLER = ['', 'Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
export function boyutDegerMetni(v: unknown, boyut: string, kolonlar: DokumKolonMeta[]): string {
  if (v === null || v === undefined || v === '') return '(boş)';
  const i = boyut.indexOf(':');
  const alan = i < 0 ? boyut : boyut.slice(0, i);
  const kesme = i < 0 ? '' : boyut.slice(i + 1);
  const s = String(v);
  if (kesme === 'ay' && /^\d{4}-\d{2}$/.test(s)) return `${AYLAR[Number(s.slice(5, 7)) - 1]} ${s.slice(0, 4)}`;
  if (kesme === 'haftaGunu') return GUNLER[Number(s)] ?? s;
  if (kesme === 'saat') return `${s.padStart(2, '0')}:00`;
  if (kesme === 'gun' || kesme === 'hafta' || kesme === '') {
    const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(s);
    if (m) return `${m[3]}.${m[2]}.${m[1]}`;
  }
  const kol = kolonlar.find(k => k.ad === alan);
  if (kol?.kodlar && s in kol.kodlar) return kol.kodlar[s];
  if (kol?.tip === 'mantik') return s === '1' || s === 'true' ? 'Evet' : 'Hayır';
  return s;
}

// ------------------------------------------------------------------- pivot ----
export interface PivotSatir {
  anahtar: string;
  etiketler: string[];               // satır boyutlarının metinleri
  hucre: Record<string, Record<string, unknown>>;   // sütun değeri → ölçüler
  toplam: Record<string, number>;    // ölçü → satır toplamı (adet/toplam), ortalamalar için ağırlıklı değil
  adet: number;
}
export interface Pivot {
  sutunlar: string[];                // sütun boyutu değerleri (sıralı); sütun yoksa ['']
  satirlar: PivotSatir[];
  dip: Record<string, number>;       // ölçü → genel toplam (yalnız toplanabilir fn)
  sutunToplam: Record<string, Record<string, number>>;  // sütun → ölçü → toplam
}

const TOPLANABILIR = new Set(['adet', 'toplam', 'tekil']);

/**
 * Özet satırlarını satır boyutları × sütun boyutu ızgarasına dağıtır. Toplam
 * satır/sütunları yalnız TOPLANABİLİR ölçüler için (adet, Σ); ortalama ve
 * oranın satır toplamı anlamsızdır, "—" yazılır. Tekil sayının satır toplamı
 * da kesin değildir (aynı hasta iki ayda) - yine de yaklaşık olarak toplanır,
 * başlıkta "≈" ile işaretlenir.
 */
export function pivotla(ozet: OzetYaniti, satirBoyutSayisi: number): Pivot {
  const boyutlar = ozet.boyutlar;
  const sutunAd = boyutlar.length > satirBoyutSayisi ? boyutlar[satirBoyutSayisi] : null;
  const satirAdlari = boyutlar.slice(0, satirBoyutSayisi);
  const satirlar = new Map<string, PivotSatir>();
  const sutunlar = new Set<string>();
  const dip: Record<string, number> = {};
  const sutunToplam: Record<string, Record<string, number>> = {};

  for (const r of ozet.satirlar) {
    const etiketler = satirAdlari.map(a => (r[a] === null || r[a] === undefined) ? '' : String(r[a]));
    const anahtar = etiketler.join('|');
    const sutun = sutunAd ? String(r[sutunAd] ?? '') : '';
    sutunlar.add(sutun);
    let s = satirlar.get(anahtar);
    if (!s) { s = { anahtar, etiketler, hucre: {}, toplam: {}, adet: 0 }; satirlar.set(anahtar, s); }
    s.hucre[sutun] = r;
    s.adet += Number(r.adet ?? 0);
    sutunToplam[sutun] ??= {};
    for (const o of ozet.olculer) {
      if (!TOPLANABILIR.has(o.fn)) continue;
      const v = Number(r[o.ad] ?? 0);
      if (!Number.isFinite(v)) continue;
      s.toplam[o.ad] = (s.toplam[o.ad] ?? 0) + v;
      dip[o.ad] = (dip[o.ad] ?? 0) + v;
      sutunToplam[sutun][o.ad] = (sutunToplam[sutun][o.ad] ?? 0) + v;
    }
  }
  return {
    sutunlar: [...sutunlar].sort(),
    satirlar: [...satirlar.values()],
    dip, sutunToplam,
  };
}

export const toplanabilirMi = (o: OzetOlcu) => TOPLANABILIR.has(o.fn);

/** Kıyas satırlarını aynı boyut anahtarıyla eşler: anahtar → satır. */
export function kiyasEsle(ozet: OzetYaniti): Map<string, Record<string, unknown>> {
  const m = new Map<string, Record<string, unknown>>();
  for (const r of ozet.kiyas ?? [])
    m.set(ozet.boyutlar.map(b => String(r[b] ?? '')).join('|'), r);
  return m;
}

/** Δ: fark ve yüzde; taban 0 ise yüzde yok. */
export function delta(simdi: unknown, once: unknown): { fark: number; yuzde: number | null } | null {
  const a = Number(simdi), b = Number(once);
  if (!Number.isFinite(a) || !Number.isFinite(b)) return null;
  return { fark: a - b, yuzde: b === 0 ? null : (a - b) / Math.abs(b) };
}

export const deltaMetni = (d: { fark: number; yuzde: number | null } | null): string =>
  !d ? '' : d.yuzde === null ? (d.fark > 0 ? '+' : '') + d.fark.toLocaleString('tr-TR', { maximumFractionDigits: 0 })
    : `${d.yuzde > 0 ? '+' : ''}${(d.yuzde * 100).toLocaleString('tr-TR', { maximumFractionDigits: 1 })}%`;

/**
 * KIYAS ANAHTARI: kıyas döneminde ay boyutu bir yıl geridedir ("2026-09" ↔
 * "2025-09"); "ay" kesmeli boyut aynı satıra düşsün diye yıl parçası atılır.
 * Gün/hafta kesmeleri için de tarih kısmı (yıl) düşürülür; diğer boyutlar aynen.
 */
export function kiyasAnahtari(r: Record<string, unknown>, boyutlar: string[]): string {
  return boyutlar.map(b => {
    const v = String(r[b] ?? '');
    if (b.endsWith('_ay')) return v.slice(5);
    if (b.endsWith('_yil')) return '';
    if (b.endsWith('_ceyrek')) return v.slice(5);
    if (b.endsWith('_gun') || b.endsWith('_hafta')) return v.slice(5, 10);
    return v;
  }).join('|');
}

// ------------------------------------------------------------ liste grubu ----
export interface GrupluSatir {
  tur: 'grup' | 'satir' | 'ara';
  seviye: number;
  etiket?: string;
  adet?: number;
  satir?: Record<string, unknown>;
  toplam?: Record<string, number>;
}

/**
 * Liste satırlarını 1-2 kolona göre öbekler; her öbeğin sonuna ara toplam.
 * Sayfadaki satırlar üzerinden - sunucu sabit grup kolonu dışında ara toplam
 * vermez; bu yüzden baskıda TÜM satırlar çekilir (satır tavanına kadar).
 */
export function listeyiGrupla(satirlar: Record<string, unknown>[], grup: string[],
                              toplam: string[], kolonlar: DokumKolonMeta[]): GrupluSatir[] {
  if (grup.length === 0) return satirlar.map(s => ({ tur: 'satir', seviye: 0, satir: s }));
  const g1 = grup[0], g2 = grup[1];
  const sonuc: GrupluSatir[] = [];
  const sirali = [...satirlar].sort((a, b) =>
    String(a[g1] ?? '').localeCompare(String(b[g1] ?? ''), 'tr')
    || (g2 ? String(a[g2] ?? '').localeCompare(String(b[g2] ?? ''), 'tr') : 0));
  const topla = (liste: Record<string, unknown>[]) => {
    const t: Record<string, number> = {};
    for (const k of toplam) t[k] = liste.reduce((x, s) => x + (Number(s[k]) || 0), 0);
    return t;
  };
  const etiket = (ad: string, v: unknown) => boyutDegerMetni(v, ad, kolonlar);
  let i = 0;
  while (i < sirali.length) {
    const d1 = sirali[i][g1];
    const o1: Record<string, unknown>[] = [];
    while (i < sirali.length && sirali[i][g1] === d1) o1.push(sirali[i++]);
    sonuc.push({ tur: 'grup', seviye: 1, etiket: etiket(g1, d1), adet: o1.length, toplam: topla(o1) });
    if (g2) {
      let j = 0;
      while (j < o1.length) {
        const d2 = o1[j][g2];
        const o2: Record<string, unknown>[] = [];
        while (j < o1.length && o1[j][g2] === d2) o2.push(o1[j++]);
        sonuc.push({ tur: 'grup', seviye: 2, etiket: etiket(g2, d2), adet: o2.length, toplam: topla(o2) });
        for (const s of o2) sonuc.push({ tur: 'satir', seviye: 2, satir: s });
        sonuc.push({ tur: 'ara', seviye: 2, etiket: etiket(g2, d2), adet: o2.length, toplam: topla(o2) });
      }
    } else {
      for (const s of o1) sonuc.push({ tur: 'satir', seviye: 1, satir: s });
    }
    sonuc.push({ tur: 'ara', seviye: 1, etiket: etiket(g1, d1), adet: o1.length, toplam: topla(o1) });
  }
  return sonuc;
}

/** Baskı yönü önerisi (mockup): 8+ kolon ya da 6+ çapraz sütun → yatay. */
export function yonOnerisi(tanim: DokumTanimi, sutunSayisi = 0): 'dikey' | 'yatay' {
  if (tanim.cikti === 'ozet') return sutunSayisi >= 6 ? 'yatay' : 'dikey';
  return (tanim.kolonlar?.length ?? 0) > 8 ? 'yatay' : 'dikey';
}

/** "Kurum bazlı hekim cirosu" → "kurum-bazli-hekim-cirosu" (sunucu da aynı kuralı uygular). */
export function kodUret(ad: string): string {
  return ad.trim().toLocaleLowerCase('tr-TR')
    .replace(/ı/g, 'i').replace(/ğ/g, 'g').replace(/ü/g, 'u').replace(/ş/g, 's')
    .replace(/ö/g, 'o').replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 50) || 'dokum';
}
