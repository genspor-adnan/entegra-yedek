// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, fireEvent, render, waitFor } from '@testing-library/react';

/**
 * ŞABLON TERCİHLERİ MUAYENEDE (931, kullanıcı: "panelleri istem ekranına,
 * makroları alanlara bağla"):
 *   * kısayol + boşluk metne açılır; alana özel makro genelinden önce gelir,
 *     başka alanın makrosu açılmaz, seçim varken açılmaz;
 *   * istem ekranı muayenenin şablon panelleriyle açılır, seçilen panel sepete girer.
 */
const api = { liste: vi.fn(), muayeneSablonTercihleri: vi.fn(), muayeneIstemAc: vi.fn(), muayeneYzTetkikOnerisi: vi.fn(),
              makroKullanim: vi.fn(() => Promise.resolve({})) };
vi.mock('../api/istemci', () => ({ api }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, onay: () => Promise.resolve(true), guvenli: (f: () => Promise<void>) => f(),
}));

const { makroGenislet, makroTusu, alanMakrolari, makroEkle } = await import('../bilesenler/muayeneMakro');
const { MakroIpucu } = await import('../bilesenler/MakroIpucu');
const { IstemSepetiModal } = await import('../bilesenler/IstemSepetiModal');

const MAKROLAR = [
  { kisayol: '.ktr', alan: 'karar', metin: '3 ay sonra kontrol.', kaynak: 's' as const, id: 41 },
  { kisayol: '.ktr', alan: '', metin: 'Kontrol.' },
  { kisayol: '.fmn', alan: 'bulguOzet', metin: 'Genel durum iyi.' },
];

describe('metin makrosu', () => {
  it('imleçten önceki kısayol açılır; alana özel önce, başka alanınki açılmaz', () => {
    expect(makroGenislet('Plan: .ktr', 10, 'karar', MAKROLAR))
      .toEqual({ deger: 'Plan: 3 ay sonra kontrol. ', imlec: 26, makro: MAKROLAR[0] });
    expect(makroGenislet('.ktr', 4, 'hikaye', MAKROLAR)?.deger).toBe('Kontrol. ');
    expect(makroGenislet('.fmn', 4, 'hikaye', MAKROLAR)).toBeNull();
    expect(makroGenislet('a .ktr b', 6, 'karar', MAKROLAR, '')?.deger).toBe('a 3 ay sonra kontrol. b');
    expect(makroGenislet('', 0, 'karar', MAKROLAR)).toBeNull();
  });

  it('boşluk tuşu data-alan kutusunda kısayolu açar, olayı durdurur', () => {
    const yaz = vi.fn();
    const Kutu = () => (
      <div onKeyDownCapture={e => makroTusu(e, MAKROLAR, yaz)}>
        <textarea data-alan="karar" defaultValue=".ktr" />
        <textarea data-alan="karar" defaultValue="xyz" aria-label="duz" />
      </div>
    );
    const { container } = render(<Kutu />);
    const [k1, k2] = [...container.querySelectorAll('textarea')];
    k1.setSelectionRange(4, 4);
    fireEvent.keyDown(k1, { key: ' ' });
    expect(yaz).toHaveBeenCalledWith('karar', '3 ay sonra kontrol. ');
    // Kısayolla açılan makro da sayılır (932).
    expect(api.makroKullanim).toHaveBeenCalledWith('s', 41);
    k2.setSelectionRange(3, 3);
    fireEvent.keyDown(k2, { key: ' ' });
    expect(yaz).toHaveBeenCalledTimes(1);
  });
});

describe('makro ipucu', () => {
  it('alanın altında geçerli kısayollar: alana özel, genelin aynı kısayolu gizlenir; metin başlıkta', () => {
    expect(alanMakrolari('karar', MAKROLAR).map(m => m.metin)).toEqual(['3 ay sonra kontrol.']);
    expect(alanMakrolari('hikaye', MAKROLAR).map(m => m.kisayol)).toEqual(['.ktr']);
    const { container } = render(<MakroIpucu alan="bulguOzet" makrolar={MAKROLAR} />);
    const kodlar = [...container.querySelectorAll('button')];
    expect(kodlar.map(k => k.textContent)).toEqual(['.fmn', '.ktr']);
    expect(kodlar[0].getAttribute('title')).toContain('Genel durum iyi.');
  });

  it('çipler kullanım sayısına göre: çok kullanılan önce, eşitlikte alana özel, sonra kısayol', () => {
    const l = [
      { kisayol: '.a', alan: '', metin: 'A', kullanim: 2 },
      { kisayol: '.b', alan: 'karar', metin: 'B', kullanim: 9 },
      { kisayol: '.c', alan: 'karar', metin: 'C', kullanim: 2 },
      { kisayol: '.d', alan: 'karar', metin: 'D' },
      { kisayol: '.b', alan: '', metin: 'B genel', kullanim: 50 },   // alana özeli var: gizli
    ];
    expect(alanMakrolari('karar', l).map(m => m.kisayol)).toEqual(['.b', '.c', '.a', '.d']);
    expect(alanMakrolari('karar', l)[0].metin).toBe('B');
  });

  it('makroEkle: imleç yerine girer, arada tek boşluk', () => {
    expect(makroEkle('', 0, 'Kontrol.')).toEqual({ deger: 'Kontrol.', imlec: 8 });
    expect(makroEkle('Plan:', 5, 'Kontrol.')).toEqual({ deger: 'Plan: Kontrol.', imlec: 14 });
    expect(makroEkle('a b', 1, 'X')).toEqual({ deger: 'a X b', imlec: 3 });
    expect(makroEkle('a ', 2, 'X')).toEqual({ deger: 'a X', imlec: 3 });
  });

  it('çipe tık: odakta değilse metnin SONUNA, odaktaysa imlece yazar', async () => {
    api.makroKullanim.mockClear();
    const yaz = vi.fn();
    const { container } = render(
      <label>
        <textarea data-alan="karar" defaultValue="Plan: ilaç" />
        <MakroIpucu alan="karar" makrolar={MAKROLAR} yaz={yaz} />
      </label>);
    const kutu = container.querySelector('textarea')!;
    const cip = container.querySelector('.makro-ipucu button') as HTMLButtonElement;
    await act(async () => { cip.click() });
    expect(yaz).toHaveBeenLastCalledWith('Plan: ilaç 3 ay sonra kontrol.');
    kutu.focus(); kutu.setSelectionRange(5, 5);
    await act(async () => { cip.click() });
    expect(yaz).toHaveBeenLastCalledWith('Plan: 3 ay sonra kontrol. ilaç');
    // Her tık kullanım sayacını artırır (932); kaynağı/id'si olmayan makro sayılmaz.
    expect(api.makroKullanim).toHaveBeenCalledTimes(2);
    expect(api.makroKullanim).toHaveBeenLastCalledWith('s', 41);
  });

  it('makro yoksa hiçbir şey çizmez', () => {
    const { container } = render(<MakroIpucu alan="karar" makrolar={[]} />);
    expect(container.innerHTML).toBe('');
  });
});

describe('istem ekranı: şablon panelleri', () => {
  beforeEach(() => {
    Object.values(api).forEach(f => f.mockReset());
    api.liste.mockResolvedValue({ satirlar: [], toplamKayit: 0 });
    api.muayeneIstemAc.mockResolvedValue({ istemId: 1 });
  });

  it('şablonda panel varsa "⭐ Şablon Panelleri" ile açılır; seçilen panel istemde gider', async () => {
    api.muayeneSablonTercihleri.mockResolvedValue({ tanilar: [], receteler: [], makrolar: [],
      paneller: [{ id: 4, kod: 'BIYORUTIN', ad: 'Biyokimya Rutini' }, { id: 7, kod: 'LIPID', ad: 'Lipid Paneli' }] });
    render(<IstemSepetiModal muayeneId={11} onKapat={() => {}} onBitti={() => {}} />);
    await waitFor(() => expect(document.body.textContent).toContain('Şablon Panelleri (2)'));
    await waitFor(() => expect(document.body.textContent).toContain('Lipid Paneli'));
    expect(document.body.textContent).not.toContain('Yükleniyor');
    const satir = [...document.querySelectorAll('tr')].find(t => t.textContent?.includes('Lipid Paneli'))!;
    await act(async () => { satir.click() });
    const dugme = [...document.querySelectorAll('button')].find(b => b.textContent?.includes('İstem Aç'))!;
    await act(async () => { dugme.click() });
    expect(api.muayeneIstemAc).toHaveBeenCalledWith(11, expect.objectContaining({ tur: 1, panelIdler: [7] }));
  });

  it('🤖 YZ Önerisi: bir kez istenir, gerekçe görünür; lab tetkiği lab istemine, görüntüleme radyoloji istemine gider', async () => {
    api.muayeneSablonTercihleri.mockResolvedValue({ tanilar: [], receteler: [], makrolar: [], paneller: [] });
    api.muayeneYzTetkikOnerisi.mockResolvedValue({ not: '', atilan: 0, model: 'm', uyari: 'YZ önerisidir; istem kararı hekimindir.',
      oneriler: [{ tur: 'tetkik', id: 5, kod: 'CRP', ad: 'C Reaktif Protein', gerekce: 'bakteriyel ayrım' },
                 { tur: 'radyoloji', id: 3005, kod: '803', ad: 'Akciğer Grafisi', gerekce: 'pnömoni dışlama' }] });
    render(<IstemSepetiModal muayeneId={11} onKapat={() => {}} onBitti={() => {}} />);
    const kat = await waitFor(() => [...document.querySelectorAll('button')].find(b => b.textContent?.includes('YZ Önerisi'))!);
    await act(async () => { kat.click() });
    await waitFor(() => expect(document.body.textContent).toContain('bakteriyel ayrım'));
    expect(document.body.textContent).toContain('istem kararı hekimindir');
    for (const ad of ['C Reaktif Protein', 'Akciğer Grafisi']) {
      const tr = [...document.querySelectorAll('tr')].find(t => t.textContent?.includes(ad))!;
      await act(async () => { tr.click() });
    }
    const dugme = [...document.querySelectorAll('button')].find(b => b.textContent?.includes('İstem Aç'))!;
    await act(async () => { dugme.click() });
    expect(api.muayeneIstemAc).toHaveBeenCalledWith(11, expect.objectContaining({ tur: 1, tetkikIdler: [5], panelIdler: [] }));
    expect(api.muayeneIstemAc).toHaveBeenCalledWith(11, expect.objectContaining({ tur: 2, hizmetId: 3005 }));
    expect(api.muayeneYzTetkikOnerisi).toHaveBeenCalledTimes(1);
  });

  it('şablonda panel yoksa kategori çıkmaz', async () => {
    api.muayeneSablonTercihleri.mockResolvedValue({ tanilar: [], receteler: [], makrolar: [], paneller: [] });
    render(<IstemSepetiModal muayeneId={11} onKapat={() => {}} onBitti={() => {}} />);
    await waitFor(() => expect(api.muayeneSablonTercihleri).toHaveBeenCalled());
    await waitFor(() => expect(document.body.textContent).toContain('Paneller'));
    expect(document.body.textContent).not.toContain('Şablon Panelleri');
  });
});
