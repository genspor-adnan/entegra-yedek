import { describe, expect, it } from 'vitest';
import { KIMDEN_SECENEKLERI, akisCoz, akisKartYolu, akisTarafSuzgeci, akisYolu, niyetCoz, niyetSecenekleri } from '../sayfalar/kabuk/paletNiyet';

/**
 * REZERVE KELİMELER (kullanıcı 06.11.2026, mockup Ekranlar/AI/ai_rezerve_kelimeler.html): palette yalnız 1. aşama
 * (iş seçenekleri); "Yeni …" akışı Kabuk'a yol olarak gider; tutar ön dolumu ERP'de carinin açık borcu.
 */
describe('rezerve kelimeler', () => {
  it('kelime ve eş anlamlıları tanır, ek ve dolgu sözcükleri yutar', () => {
    expect(niyetCoz('tahsilat')?.niyet.kelime).toBe('tahsilat');
    expect(niyetCoz('Tahsilatı')?.niyet.kelime).toBe('tahsilat');
    expect(niyetCoz('tahsil et')?.niyet.kelime).toBe('tahsilat');
    expect(niyetCoz('fatura kes')?.niyet.kelime).toBe('fatura');
    expect(niyetCoz('yeni sipariş aç')?.niyet.kelime).toBe('siparis');
    expect(niyetCoz('ödeme yap')?.niyet.kelime).toBe('odeme');
  });

  it('araç ve tutar cümleden alınır', () => {
    const n = niyetCoz('nakit 5.000,50 tahsilat');
    expect(n?.arac).toBe('nakit');
    expect(n?.tutar).toBe(5000.5);
    expect(niyetCoz('havale ile tahsilat')?.arac).toBe('havale');
  });

  it('tanınmayan sözcük varsa niyet değildir (ad / ekran araması sürer)', () => {
    expect(niyetCoz('ahmet tahsilat')).toBeNull();
    expect(niyetCoz('tahsilat türü listesi')).toBeNull();
    expect(niyetCoz('')).toBeNull();
    expect(niyetCoz('kasa')).toBeNull();
  });

  it('ERP "Yeni tahsilat" doğrudan cari arar; HBYS kimden sorar (kimden boş)', () => {
    const n = niyetCoz('tahsilat')!.niyet;
    expect(niyetSecenekleri(n, 1)[0].akis).toEqual({ islem: 'tahsilat', kimden: 'cari' });
    expect(niyetSecenekleri(n, 2)[0].akis).toEqual({ islem: 'tahsilat' });
    expect(KIMDEN_SECENEKLERI.map(k => k.kod)).toEqual(['hasta', 'kurum', 'cari']);
  });

  it('akış yolu gidiş-dönüş', () => {
    const a = { islem: 'tahsilat' as const, kimden: 'cari' as const, arac: 'havale' as const, tutar: 250 };
    expect(akisCoz(akisYolu(a))).toEqual(a);
    expect(akisCoz('/kasa-islem')).toBeNull();
  });

  it('arama süzgeci: tahsilat / satış müşteri, ödeme / alış tedarikçi', () => {
    expect(akisTarafSuzgeci({ islem: 'tahsilat', kimden: 'cari' })?.alan).toBe('musteri');
    expect(akisTarafSuzgeci({ islem: 'odeme', kimden: 'cari' })?.alan).toBe('tedarikci');
    expect(akisTarafSuzgeci({ islem: 'siparis', kimden: 'cari', yon: 'alis' })?.alan).toBe('tedarikci');
    expect(akisTarafSuzgeci({ islem: 'tahsilat', kimden: 'hasta' })).toBeUndefined();
  });

  it('kart yolu: tür araçtan, tutar açık borçtan; ödemede alacak; cümledeki tutar önce', () => {
    const satir = { id: 143, bakiye: 184250, kod: '120.01.143', musteri: 1, tedarikci: 0 };
    expect(akisKartYolu({ islem: 'tahsilat', kimden: 'cari', arac: 'nakit' }, { id: 143, unvan: 'ALOE', satir }))
      .toBe('/kasa-islem/yeni?tur=21&tarafId=143&tarafUnvan=ALOE&tutar=184250.00');
    expect(akisKartYolu({ islem: 'odeme', kimden: 'cari', arac: 'havale' }, { id: 5, unvan: 'X', satir: { id: 5, bakiye: -1200 } }))
      .toBe('/kasa-islem/yeni?tur=32&tarafId=5&tarafUnvan=X&tutar=1200.00');
    expect(akisKartYolu({ islem: 'tahsilat', kimden: 'cari', arac: 'nakit', tutar: 500 }, { id: 143, unvan: 'ALOE', satir }))
      .toContain('&tutar=500.00');
    // Alacaklı cariden tahsilat: açık borç yok -> tutar boş.
    expect(akisKartYolu({ islem: 'tahsilat', kimden: 'cari', arac: 'nakit' }, { id: 7, unvan: 'Y', satir: { id: 7, bakiye: -30 } }))
      .not.toContain('tutar=');
    // Belge: cariKomutu ile aynı yol.
    expect(akisKartYolu({ islem: 'fatura', kimden: 'cari', yon: 'satis' }, { id: 143, unvan: 'ALOE', satir }))
      .toBe('/belge/yeni?tur=15&tarafId=143&tarafUnvan=ALOE');
  });
});
