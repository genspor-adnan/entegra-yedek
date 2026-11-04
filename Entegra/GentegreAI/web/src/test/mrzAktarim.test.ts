import { describe, expect, it } from 'vitest';
import type { MrzSonucu } from '../api/uclar/kimlik';
import { aktarimPaketi, asciiKat, karsilastir, mrzBekleyenAl, mrzBekleyenKoy } from '../bilesenler/kimlik/mrzAktarim';
import { mrzSatirlari } from '../bilesenler/kimlik/mrzOcr';

/** KİMLİĞİ OKUT (1255): MRZ → kart karşılaştırması ve aktarım paketi (mockup kimlik_mrz_okut.html ②). */
const sonuc: MrzSonucu = {
  gecerli: true, hatalar: [], satirlar: [], bicim: 'TD1', belgeKodu: 'I', belgeTuru: 1, duzenleyenUlke: 'TUR',
  belgeNo: 'A12B34567', belgeNoTamam: true, dogumTarihi: '1990-01-01', dogumTamam: true, cinsiyet: '1',
  sonKullanma: '2030-12-31', sonKullanmaTamam: true, suresiDolmus: false, engellendi: false,
  uyruk: 'TUR', uyrukAdi: 'Türkiye', uyrukKod: '9980', kimlikNo: '10000000146', soyad: 'YILMAZ', ad: 'AHMET', bilesikTamam: true,
};

describe('MRZ karşılaştırma', () => {
  it('kayıt yoksa her alan dolacak ve alınır', () => {
    const s = karsilastir(sonuc, null);
    expect(s.every(r => r.durum === 'dolacak' && r.al)).toBe(true);
    const p = aktarimPaketi(sonuc, s, null);
    expect(p.kart).toEqual({ vkno: '10000000146', soyad: 'YILMAZ', ad: 'AHMET' });
    expect(p.ozluk).toMatchObject({ dogumTarihi: '1990-01-01', cinsiyet: '1', uyruk: '9980', belgeTuru: '1', belgeSeriNo: 'A12B34567', belgeSonKullanma: '2030-12-31' });
    expect(p.ozluk.pasaportNo).toBeUndefined();          // kimlik kartında pasaport no satırı yok
  });

  it('gerçek harfli ad ASCII ile aynıdır, alınmaz; farklı doğum MRZ alınır', () => {
    const s = karsilastir(sonuc, { kart: { vkno: '10000000146', ad: 'Ahmet', soyad: 'Yılmaz' },
                                   ozluk: { dogumTarihi: '1990-10-01T00:00:00', cinsiyet: 1, uyruk: 9980 } });
    const r = Object.fromEntries(s.map(x => [x.anahtar, x]));
    expect(r.ad.durum).toBe('ayni'); expect(r.ad.al).toBe(false);
    expect(r.soyad.durum).toBe('ayni');
    expect(r.vkno.durum).toBe('ayni');
    expect(r.dogumTarihi.durum).toBe('fark'); expect(r.dogumTarihi.al).toBe(true);
    expect(r.uyruk.durum).toBe('ayni');
    expect(r.belgeSeriNo.durum).toBe('dolacak');
    const p = aktarimPaketi(sonuc, s, 42);
    expect(p.kart).toEqual({});
    expect(p.ozluk).toEqual({ dogumTarihi: '1990-01-01', belgeTuru: '1', belgeSeriNo: 'A12B34567', belgeSonKullanma: '2030-12-31' });
    expect(p.hastaId).toBe(42);
  });

  it('kontrol hanesi tutmayan alan bozuk, alınmaz', () => {
    const s = karsilastir({ ...sonuc, gecerli: false, dogumTamam: false, hatalar: ['Doğum tarihi kontrol hanesi tutmuyor.'] }, null);
    const d = s.find(x => x.anahtar === 'dogumTarihi')!;
    expect(d.bozuk).toBe(true); expect(d.al).toBe(false);
  });

  it('pasaportta pasaport no satırı var, kimlik no satırı yok', () => {
    const s = karsilastir({ ...sonuc, bicim: 'TD3', belgeKodu: 'P', belgeTuru: 2, kimlikNo: '', belgeNo: 'C01X00T47', uyruk: 'DEU', uyrukKod: '9893' }, null);
    expect(s.some(x => x.anahtar === 'vkno')).toBe(false);
    expect(s.find(x => x.anahtar === 'pasaportNo')!.mrz).toBe('C01X00T47');
  });

  it('asciiKat Türkçe harfleri indirger', () => {
    expect(asciiKat('Şule Çağrı Öztürk')).toBe('SULE CAGRI OZTURK');
    expect(asciiKat('ılgın')).toBe('ILGIN');
  });

  it('bekleyen paket tek kullanımlık ve karta özel', () => {
    const p = aktarimPaketi(sonuc, karsilastir(sonuc, null), null);
    mrzBekleyenKoy(p, 'yeni');
    expect(mrzBekleyenAl(5)).toBeNull();          // başka kart almaz, paket durur
    expect(mrzBekleyenAl('yeni')).toBe(p);
    expect(mrzBekleyenAl('yeni')).toBeNull();     // tüketildi
  });
});

describe('OCR satır süzgeci', () => {
  it('boşluk, küçük harf ve benzer işaretleri toparlar, kısa satırı atar', () => {
    expect(mrzSatirlari('i<tur a12b345675 «««««\nkısa\n9001011M3012316TUR100000001462'))
      .toEqual(['I<TURA12B345675<<<<<', '9001011M3012316TUR100000001462']);
  });
});
