/**
 * BI-RADS YAPISAL RAPORLAMA - KURAL MOTORU (1194, kullanıcı 27.10.2026, mockup Ekranlar/Radyoloji/radyoloji_birads_v2.html).
 *
 * Lezyon sözlük seçimlerinden lezyon kategorisi ÖNERİLİR; genel öneri lezyonların en yükseğidir. Son kategori
 * radyoloğundur (öneriden farklıysa gerekçe zorunlu - sunucu da denetler). Kurallar SADELEŞTİRİLMİŞTİR ve
 * bilerek tek yerdedir: kurum hekimleriyle gözden geçirilip değiştirilecek yer burası.
 * Metin üretimi (`metinUret`) BULGULAR ve SONUÇ bölümlerinin içeriğini verir; rapor metni yine bölümlerde durur.
 */

export type BiradsModalite = 'mg' | 'us' | 'mr';
export type Kategori = '0' | '1' | '2' | '3' | '4A' | '4B' | '4C' | '5' | '6';

export interface Lezyon {
  taraf: string; saat: string; uzaklik: string; boyut: string;
  sekil: string; oryantasyon: string; kenar: string; eko: string; arka: string; kalsifikasyon: string;
  buyume: boolean;
}

export interface BiradsDurumu {
  kompozisyon: string;
  lezyonlar: Lezyon[];
  /** Radyoloğun seçtiği son kategori; null = öneri. */
  sonElle: Kategori | null;
  gerekce: string;
}

/** Kategoriler artan şüphe sırasıyla ('0' eksik değerlendirme, ayrı). */
export const SIRA: Kategori[] = ['1', '2', '3', '4A', '4B', '4C', '5', '6'];
export const KATEGORILER: Kategori[] = ['0', ...SIRA];

export const KOMPOZISYON: Record<BiradsModalite, string[]> = {
  mg: ['a - Neredeyse tamamen yağlı', 'b - Dağınık fibroglandüler', 'c - Heterojen yoğun', 'd - Son derece yoğun'],
  us: ['Homojen - yağ', 'Homojen - fibroglandüler', 'Heterojen'],
  mr: ['a - Neredeyse tamamen yağlı', 'b - Dağınık fibroglandüler', 'c - Heterojen fibroglandüler', 'd - Yoğun fibroglandüler'],
};

export type SozlukAlani = 'sekil' | 'oryantasyon' | 'kenar' | 'eko' | 'arka' | 'kalsifikasyon';
export const SOZLUK: Record<SozlukAlani, string[]> = {
  sekil: ['Oval', 'Yuvarlak', 'Düzensiz'],
  oryantasyon: ['Paralel', 'Paralel değil'],
  kenar: ['Düzgün sınırlı', 'Belirsiz', 'Açılı', 'Mikrolobüle', 'Spiküle'],
  eko: ['Anekoik', 'Hiperekoik', 'Kompleks kistik-solid', 'Hipoekoik', 'İzoekoik', 'Heterojen'],
  arka: ['Yok', 'Güçlenme', 'Gölgelenme', 'Kombine'],
  kalsifikasyon: ['Yok', 'Tipik benign', 'Kaba heterojen', 'Amorf', 'İnce pleomorfik', 'İnce lineer / dallanan'],
};
export const SOZLUK_ETIKET: Record<SozlukAlani, string> = {
  sekil: 'Şekil', oryantasyon: 'Oryantasyon', kenar: 'Kenar', eko: 'Eko paterni', arka: 'Arka akustik',
  kalsifikasyon: 'Kalsifikasyon',
};

/** Modaliteye göre sorulan alanlar: eko / arka akustik / oryantasyon yalnız US'de anlamlı. */
export const modaliteAlanlari = (m: BiradsModalite): SozlukAlani[] =>
  m === 'us' ? ['sekil', 'oryantasyon', 'kenar', 'eko', 'arka', 'kalsifikasyon']
             : m === 'mg' ? ['sekil', 'kenar', 'kalsifikasyon'] : ['sekil', 'kenar'];

/** Şablon modalitesinden (rad.modalite: 2 MR, 3 US, 5 MG) form modalitesi. */
export const modaliteKodundan = (kod: unknown): BiradsModalite =>
  Number(kod) === 5 ? 'mg' : Number(kod) === 2 ? 'mr' : 'us';

export const YONETIM: Record<Kategori, string> = {
  '0': 'Ek görüntüleme / önceki tetkiklerle karşılaştırma önerilir',
  '1': 'Rutin tarama önerilir', '2': 'Rutin tarama önerilir',
  '3': '6 ay sonra kısa aralıklı kontrol önerilir',
  '4A': 'Doku tanısı (biyopsi) önerilir', '4B': 'Doku tanısı (biyopsi) önerilir',
  '4C': 'Doku tanısı (biyopsi) önerilir', '5': 'Doku tanısı (biyopsi) önerilir',
  '6': 'Uygun tedavi planı (cerrahi / onkoloji) önerilir',
};

export const yeniLezyon = (m: BiradsModalite): Lezyon => ({
  taraf: 'Sağ', saat: '12:00', uzaklik: '', boyut: '', sekil: 'Oval', oryantasyon: 'Paralel',
  kenar: 'Düzgün sınırlı', eko: m === 'us' ? 'Hipoekoik' : '', arka: m === 'us' ? 'Yok' : '',
  kalsifikasyon: 'Yok', buyume: false,
});

const kucuk = (s: string) => s.toLocaleLowerCase('tr');
const yuksek = (a: Kategori, b: Kategori): Kategori => (SIRA.indexOf(b) > SIRA.indexOf(a) ? b : a);

/** Tek lezyonun önerilen kategorisi + hangi kuralların uygulandığı (ekrandaki "neden" çipleri). */
export function lezyonKategorisi(l: Lezyon, m: BiradsModalite): { kategori: Kategori; nedenler: string[] } {
  const n: string[] = [];
  let k: Kategori = '3';
  if (m === 'us' && l.eko === 'Anekoik' && l.kenar === 'Düzgün sınırlı' && l.sekil !== 'Düzensiz') {
    k = '2'; n.push('basit kist görünümü → 2');
  } else if (l.sekil !== 'Düzensiz' && l.kenar === 'Düzgün sınırlı' && (m !== 'us' || l.oryantasyon === 'Paralel')) {
    n.push('oval / yuvarlak, düzgün sınırlı → 3');
  }
  const yuk = (x: Kategori, neden: string) => { k = yuksek(k, x); n.push(neden) };
  if (l.kenar === 'Mikrolobüle') yuk('4A', 'mikrolobüle kenar → 4A');
  if (l.kenar === 'Belirsiz' || l.kenar === 'Açılı') yuk('4B', `${kucuk(l.kenar)} kenar → 4B`);
  if (m === 'us' && l.sekil === 'Düzensiz' && l.oryantasyon === 'Paralel değil') yuk('4C', 'düzensiz + paralel değil → 4C');
  else if (m !== 'us' && l.sekil === 'Düzensiz') yuk('4B', 'düzensiz şekil → 4B');
  if (l.kenar === 'Spiküle') {
    const s: Kategori = l.sekil === 'Düzensiz' ? '5' : '4C';
    yuk(s, `spiküle kenar → ${s}`);
  }
  const kals: Partial<Record<string, Kategori>> = {
    'Tipik benign': '2', 'Kaba heterojen': '4A', 'Amorf': '4B', 'İnce pleomorfik': '4C', 'İnce lineer / dallanan': '5',
  };
  const kk = kals[l.kalsifikasyon];
  if (kk) yuk(kk, `${kucuk(l.kalsifikasyon)} kalsifikasyon → ${kk}`);
  if (l.buyume && SIRA.indexOf(k) < SIRA.indexOf('4A')) { k = '4A'; n.push('önceki tetkike göre büyüme → en az 4A') }
  return { kategori: k, nedenler: n };
}

/** Genel öneri: lezyonların en yükseği; lezyon yoksa 1 (negatif). */
export function genelOneri(d: BiradsDurumu, m: BiradsModalite): { kategori: Kategori; nedenler: string[] } {
  if (d.lezyonlar.length === 0) return { kategori: '1', nedenler: ['lezyon yok → 1 (negatif)'] };
  let g: Kategori = '1';
  const n: string[] = [];
  d.lezyonlar.forEach((l, i) => {
    const r = lezyonKategorisi(l, m);
    g = yuksek(g, r.kategori);
    n.push(...r.nedenler.map(x => `L${i + 1}: ${x}`));
  });
  return { kategori: g, nedenler: n };
}

export const sonKategori = (d: BiradsDurumu, m: BiradsModalite): Kategori => d.sonElle ?? genelOneri(d, m).kategori;

/** BULGULAR ve SONUÇ metni - formdan üretilir (yapısal girişte bölümlere yazılır, serbestte "Rapora aktar"). */
export function metinUret(d: BiradsDurumu, m: BiradsModalite): { bulgular: string; sonuc: string } {
  const s: string[] = [];
  if (d.kompozisyon) s.push(`${m === 'us' ? 'Doku kompozisyonu' : m === 'mr' ? 'Fibroglandüler doku' : 'Meme kompozisyonu'}: ${kucuk(d.kompozisyon)}.`);
  d.lezyonlar.forEach(l => {
    const { kategori } = lezyonKategorisi(l, m);
    const yer = [`${l.taraf} meme`, l.saat && `saat ${l.saat} hizasında`, l.uzaklik && `meme başına ${l.uzaklik} uzaklıkta`]
      .filter(Boolean).join(' ');
    const ozellik = [
      l.boyut && `${l.boyut} boyutlarında`,
      kucuk(l.sekil),
      m === 'us' && l.oryantasyon && `${kucuk(l.oryantasyon)} oryantasyonlu`,
      `${kucuk(l.kenar)} kenarlı`,
      m === 'us' && l.eko && kucuk(l.eko),
    ].filter(Boolean).join(', ');
    const ek = [
      m === 'us' && l.arka && l.arka !== 'Yok' && `arka akustik ${kucuk(l.arka)}`,
      l.kalsifikasyon && l.kalsifikasyon !== 'Yok' && `${kucuk(l.kalsifikasyon)} kalsifikasyon`,
    ].filter(Boolean).join(', ');
    s.push(`${yer}, ${ozellik}${ek ? `, ${ek}` : ''} lezyon izlenmiştir${l.buyume ? ' (önceki tetkike göre büyüme)' : ''}. [BI-RADS ${kategori}]`);
  });
  if (d.lezyonlar.length === 0) s.push('Her iki memede kitle, şüpheli kalsifikasyon ya da mimari distorsiyon izlenmemiştir.');
  const k = sonKategori(d, m);
  const oneri = genelOneri(d, m).kategori;
  const sonuc = `BI-RADS ${k}. ${YONETIM[k]}.` + (k !== oneri && d.gerekce.trim() ? `\nNot: ${d.gerekce.trim()}` : '');
  return { bulgular: s.join('\n'), sonuc };
}

/** Sunucu gövdesi (RaporIstegi.Birads). */
export function biradsGovdesi(d: BiradsDurumu, m: BiradsModalite) {
  const oneri = genelOneri(d, m).kategori;
  const kategori = sonKategori(d, m);
  return {
    kompozisyon: d.kompozisyon, oneri, kategori,
    gerekce: kategori !== oneri ? d.gerekce : '', yonetim: YONETIM[kategori],
    lezyonlar: d.lezyonlar.map(l => ({ ...l, buyume: l.buyume ? 1 : 0, kategori: lezyonKategorisi(l, m).kategori })),
  };
}

/** Sunucu yanıtından (rapor + lezyonlar) form durumu. */
export function durumOku(rapor: Record<string, unknown> | null, lez: Record<string, unknown>[], m: BiradsModalite): BiradsDurumu {
  const S = (x: unknown) => String(x ?? '');
  const d: BiradsDurumu = {
    kompozisyon: S(rapor?.biradsKompozisyon) || KOMPOZISYON[m][1],
    lezyonlar: lez.map(l => ({
      taraf: S(l.taraf) || 'Sağ', saat: S(l.saat), uzaklik: S(l.uzaklik), boyut: S(l.boyut), sekil: S(l.sekil),
      oryantasyon: S(l.oryantasyon), kenar: S(l.kenar), eko: S(l.eko), arka: S(l.arka),
      kalsifikasyon: S(l.kalsifikasyon) || 'Yok', buyume: Number(l.buyume ?? 0) === 1,
    })),
    sonElle: null, gerekce: S(rapor?.biradsGerekce),
  };
  const kayitli = S(rapor?.biradsKategori) as Kategori;
  if (kayitli && kayitli !== genelOneri(d, m).kategori) d.sonElle = kayitli;
  return d;
}
