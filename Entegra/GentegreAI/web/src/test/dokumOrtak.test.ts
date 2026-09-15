import { describe, it, expect } from 'vitest';
import type { DokumKolonMeta, OzetYaniti } from '../api/sozlesme';
import {
  bosTanim, delta, deltaMetni, kiyasAnahtari, kodUret, kuralAraligi, listeyiGrupla,
  olcuBicimle, parametreAlanlari, pivotla, tanimCumlesi, yonOnerisi, boyutDegerMetni,
} from '../sayfalar/dokum/ortak';

/**
 * DÖKÜM TASARIMCISININ SAF HESAPLARI (686).
 *
 * Önizleme ve baskı aynı fonksiyonları kullanır; pivot/Δ/ara toplam burada
 * doğru değilse iki ekranda birden yanlış - o yüzden testi React'siz.
 */

const kolonlar: DokumKolonMeta[] = [
  { ad: 'belgeTarihi', baslik: 'Tarih', tip: 'tarih', filtrelenebilir: true, siralanabilir: true, gruplanabilir: true, olculebilir: false },
  { ad: 'odeyenKurumAdi', baslik: 'Ödeyen Kurum', tip: 'metin', filtrelenebilir: true, siralanabilir: true, gruplanabilir: true, olculebilir: false },
  { ad: 'doktor', baslik: 'Doktor', tip: 'metin', filtrelenebilir: true, siralanabilir: true, gruplanabilir: true, olculebilir: false },
  { ad: 'genelToplam', baslik: 'Genel Toplam', tip: 'para', filtrelenebilir: true, siralanabilir: true, gruplanabilir: false, olculebilir: true },
  { ad: 'tahsilat', baslik: 'Tahsilat', tip: 'para', filtrelenebilir: true, siralanabilir: true, gruplanabilir: false, olculebilir: true },
];

describe('tanım cümlesi ve parametreler', () => {
  it('koşulları, parametreyi ve gruplamayı tek cümlede okur', () => {
    const t = bosTanim('belge');
    t.filtre = { op: 'and', kosullar: [
      { alan: 'belgeTarihi', op: 'arasinda', deger: ['2026-09-01', '2026-09-15'] },
      { alan: 'odeyenKurumAdi', op: 'icinde', deger: ['SGK', 'Anadolu'] },
      { alan: 'genelToplam', op: 'buyukEsit', deger: 500 },
    ] };
    t.parametreler = { belgeTarihi: { ad: 'Tarih aralığı', kural: 'gecenAy' } };
    t.grup = ['odeyenKurumAdi', 'doktor']; t.toplam = ['genelToplam'];
    const c = tanimCumlesi(t, kolonlar, 'Başvurular');
    expect(c).toContain('Tarih arasında 〔sorulur〕');
    expect(c).toContain('Ödeyen Kurum ∈ {SGK, Anadolu}');
    expect(c).toContain('Genel Toplam ≥ 500');
    expect(c).toContain('Ödeyen Kurum › Doktor gruplu');
    expect(c).toContain('Σ Genel Toplam');
    expect(parametreAlanlari(t)).toEqual([{ alan: 'belgeTarihi', ad: 'Tarih aralığı', kural: 'gecenAy', op: 'arasinda' }]);
  });

  it('özet cümlesi boyut ve ölçüyü yazar', () => {
    const t = bosTanim('belge'); t.cikti = 'ozet';
    t.boyut = { satir: ['odeyenKurumAdi'], sutun: 'belgeTarihi:ay' };
    t.olcu = [{ fn: 'adet' }, { fn: 'toplam', alan: 'genelToplam' }, { fn: 'oran', alan: 'tahsilat', bolen: 'genelToplam' }];
    t.kiyas = 'oncekiYil';
    const c = tanimCumlesi(t, kolonlar, 'Başvurular');
    expect(c).toContain('Ödeyen Kurum › Tarih · Ay kırılımında Adet, Σ Genel Toplam, Tahsilat / Genel Toplam');
    expect(c).toContain('Önceki yıl aynı dönem');
  });
});

describe('tarih kuralları (sunucu ParametreCozucu ile aynı)', () => {
  const bugun = new Date(2026, 8, 15); // 15.09.2026 Salı
  it.each([
    ['bugun', ['2026-09-15', '2026-09-15']],
    ['dun', ['2026-09-14', '2026-09-14']],
    ['buHafta', ['2026-09-14', '2026-09-20']],
    ['gecenHafta', ['2026-09-07', '2026-09-13']],
    ['buAy', ['2026-09-01', '2026-09-30']],
    ['gecenAy', ['2026-08-01', '2026-08-31']],
    ['buCeyrek', ['2026-07-01', '2026-09-30']],
    ['buYil', ['2026-01-01', '2026-12-31']],
    ['son7', ['2026-09-09', '2026-09-15']],
    ['son30', ['2026-08-17', '2026-09-15']],
  ])('%s', (kural, beklenen) => {
    expect(kuralAraligi(kural, bugun)).toEqual(beklenen);
  });
  it('bilinmeyen kural null', () => expect(kuralAraligi('yok', bugun)).toBeNull());
});

const ozet: OzetYaniti = {
  boyutlar: ['odeyenKurumAdi', 'belgeTarihi_ay'],
  olculer: [
    { ad: 'adet', baslik: 'Adet', fn: 'adet', bicim: '#,##0' },
    { ad: 'genelToplam_toplam', baslik: 'Σ Genel Toplam', fn: 'toplam', bicim: '#,##0.00' },
    { ad: 'genelToplam_ortalama', baslik: 'Ort.', fn: 'ortalama', bicim: '#,##0.00' },
  ],
  satirlar: [
    { odeyenKurumAdi: 'SGK', belgeTarihi_ay: '2026-08', adet: 10, genelToplam_toplam: 1000, genelToplam_ortalama: 100 },
    { odeyenKurumAdi: 'SGK', belgeTarihi_ay: '2026-09', adet: 5, genelToplam_toplam: 600, genelToplam_ortalama: 120 },
    { odeyenKurumAdi: 'Anadolu', belgeTarihi_ay: '2026-09', adet: 2, genelToplam_toplam: 400, genelToplam_ortalama: 200 },
  ],
  kiyas: [
    { odeyenKurumAdi: 'SGK', belgeTarihi_ay: '2025-08', adet: 8, genelToplam_toplam: 800, genelToplam_ortalama: 100 },
    { odeyenKurumAdi: 'SGK', belgeTarihi_ay: '2025-09', adet: 6, genelToplam_toplam: 500, genelToplam_ortalama: 90 },
  ],
  kiyasAraligi: '01.08.2025 – 30.09.2025', sureMs: 1, izlemeNo: '',
};

describe('pivot ve kıyas', () => {
  it('satır × sütun ızgarası; toplanabilir ölçüler toplanır, ortalama toplanmaz', () => {
    const p = pivotla(ozet, 1);
    expect(p.sutunlar).toEqual(['2026-08', '2026-09']);
    expect(p.satirlar.map(s => s.anahtar)).toEqual(['SGK', 'Anadolu']);
    const sgk = p.satirlar[0];
    expect(sgk.toplam.adet).toBe(15);
    expect(sgk.toplam.genelToplam_toplam).toBe(1600);
    expect(sgk.toplam.genelToplam_ortalama).toBeUndefined();
    expect(sgk.hucre['2026-09'].adet).toBe(5);
    expect(p.dip.adet).toBe(17);
    expect(p.sutunToplam['2026-09'].adet).toBe(7);
  });

  it('kıyas anahtarı ay boyutunda yılı atar - 2026-09 ↔ 2025-09 aynı satıra düşer', () => {
    expect(kiyasAnahtari(ozet.satirlar[1], ozet.boyutlar)).toBe('SGK|09');
    expect(kiyasAnahtari(ozet.kiyas![1], ozet.boyutlar)).toBe('SGK|09');
  });

  it('Δ: fark ve yüzde; taban sıfırsa yüzde yok', () => {
    expect(delta(15, 14)).toEqual({ fark: 1, yuzde: 1 / 14 });
    expect(deltaMetni(delta(120, 100))).toBe('+20%');
    expect(deltaMetni(delta(80, 100))).toBe('-20%');
    expect(deltaMetni(delta(5, 0))).toBe('+5');
    expect(delta('x', 1)).toBeNull();
  });

  it('ölçü biçimi: oran yüzde, adet tam, para iki hane', () => {
    expect(olcuBicimle(0.7412, '%')).toBe('%74,1');
    expect(olcuBicimle(1209, '#,##0')).toBe('1.209');
    expect(olcuBicimle(1480.5, '#,##0.00')).toBe('1.480,50');
    expect(olcuBicimle(null, '#,##0')).toBe('—');
  });

  it('boyut değeri metni: ay adı, haftanın günü, kod sözlüğü', () => {
    expect(boyutDegerMetni('2026-09', 'belgeTarihi:ay', kolonlar)).toBe('Eyl 2026');
    expect(boyutDegerMetni(1, 'belgeTarihi:haftaGunu', kolonlar)).toBe('Pzt');
    expect(boyutDegerMetni('2026-09-15T00:00:00', 'belgeTarihi:gun', kolonlar)).toBe('15.09.2026');
    const kodlu: DokumKolonMeta[] = [{ ad: 'tur', baslik: 'Tür', tip: 'kod', filtrelenebilir: true, siralanabilir: true,
      gruplanabilir: true, olculebilir: false, kodlar: { '19': 'Sipariş' } }];
    expect(boyutDegerMetni(19, 'tur', kodlu)).toBe('Sipariş');
    expect(boyutDegerMetni(null, 'tur', kodlu)).toBe('(boş)');
  });
});

describe('liste gruplama (ara toplam)', () => {
  const satirlar = [
    { odeyenKurumAdi: 'SGK', doktor: 'Güneş', genelToplam: 100 },
    { odeyenKurumAdi: 'Anadolu', doktor: 'Kavak', genelToplam: 50 },
    { odeyenKurumAdi: 'SGK', doktor: 'Kavak', genelToplam: 30 },
    { odeyenKurumAdi: 'SGK', doktor: 'Güneş', genelToplam: 20 },
  ];
  it('iki seviye grup + ara toplamlar; sıra Türkçe alfabetik', () => {
    const g = listeyiGrupla(satirlar, ['odeyenKurumAdi', 'doktor'], ['genelToplam'], kolonlar);
    const ozetle = g.map(x => `${x.tur}${x.seviye}${x.tur === 'satir' ? '' : ':' + x.etiket + '=' + x.toplam?.genelToplam}`);
    expect(ozetle).toEqual([
      'grup1:Anadolu=50', 'grup2:Kavak=50', 'satir2', 'ara2:Kavak=50', 'ara1:Anadolu=50',
      'grup1:SGK=150', 'grup2:Güneş=120', 'satir2', 'satir2', 'ara2:Güneş=120',
      'grup2:Kavak=30', 'satir2', 'ara2:Kavak=30', 'ara1:SGK=150',
    ]);
  });
  it('grupsuz: düz satırlar', () => {
    expect(listeyiGrupla(satirlar, [], [], kolonlar).every(x => x.tur === 'satir')).toBe(true);
  });
});

describe('küçük yardımcılar', () => {
  it('yön önerisi: 8+ kolon ya da 6+ çapraz sütun yatay', () => {
    const t = bosTanim('belge'); t.kolonlar = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i'];
    expect(yonOnerisi(t)).toBe('yatay');
    t.kolonlar = ['a']; expect(yonOnerisi(t)).toBe('dikey');
    t.cikti = 'ozet'; expect(yonOnerisi(t, 6)).toBe('yatay'); expect(yonOnerisi(t, 3)).toBe('dikey');
  });
  it('kod üretimi Türkçe harfleri düşürür', () => {
    expect(kodUret('Kurum bazlı hekim cirosu')).toBe('kurum-bazli-hekim-cirosu');
    expect(kodUret('  Çok   Şık!! ')).toBe('cok-sik');
    expect(kodUret('')).toBe('dokum');
  });
});
