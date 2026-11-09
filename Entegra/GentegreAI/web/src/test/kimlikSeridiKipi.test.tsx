// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent, act } from '@testing-library/react';
import type { KartAlanMeta } from '../api/sozlesme';

/**
 * KİMLİK ŞERİDİ GÖRÜNTÜLEME / DÜZENLEME KİPİ (mockup Ekranlar/Stok/stok_karti_baslik_kip.html; kullanıcı 09.11.2026
 * "stok kartı başlığı edit/view", "fiyat listeleri kartı başlığını da", "avatar da ekle"):
 *  · yeni kart düzenlemede, kayıtlı kart görüntülemede (ızgara inert) açılır
 *  · tek geçiş yolu ✎ - ızgaraya tıklamak kipi değiştirmez
 *  · sekme değişince görüntülemeye döner; ilk sekme ataması (null → değer) değişim sayılmaz
 *  · salt okunur kartta ✎ pasif
 *  · avatar yalnız stokta; resim yoksa baş harfler
 */
vi.mock('../api/istemci', () => ({ api: {
  dokumanlar: async () => [],
  dokumanIcerikUrl: async () => null,
} }));

const { KartKimlikSeridi } = await import('../bilesenler/kart/KartKimlikSeridi');

const alanlar: KartAlanMeta[] = [
  { ad: 'kod', baslik: 'Stok Kodu', tip: 'metin', zorunlu: true },
  { ad: 'ad', baslik: 'Stok Adı', tip: 'metin', zorunlu: true },
  { ad: 'durum', baslik: 'Durum', tip: 'kod', zorunlu: false },
] as unknown as KartAlanMeta[];

function ciz(p: { kaynak?: string; yeniMi?: boolean; salt?: boolean; aktifSekme?: string | null;
                  deger?: Record<string, unknown> } = {}) {
  const props = () => ({
    kaynak: p.kaynak ?? 'stok',
    deger: (p.deger ?? (p.yeniMi ? { ad: 'Eldiven Nitril M' } : { id: 412, kod: 'STK-00412', ad: 'Parasetamol 500 mg', durum: '1' })) as never,
    meta: null, salt: p.salt ?? false, detaylar: {}, setDetaylar: () => {},
    kimlikAlanlari: alanlar,
    renderAlanListesi: (a: KartAlanMeta[]) => a.map(x => (
      <label key={x.ad} className={`alan alan-${x.ad}`}><span className="etiket">{x.baslik}</span><input defaultValue="" /></label>)),
    personelGibiKart: false, dogumYasMetni: '', yeniMi: p.yeniMi ?? false,
    unvanOneki: { onek: '', setOnek: () => {}, secenekler: [] } as never,
    aktifSekme: p.aktifSekme,
  });
  const r = render(<KartKimlikSeridi {...props()} />);
  return { ...r, yeniden: (sekme: string | null) => r.rerender(<KartKimlikSeridi {...props()} aktifSekme={sekme} />) };
}
const kipli = () => screen.getByTestId('kimlik-kipli');
const goster = () => kipli().classList.contains('kaid-goster');
const inert = () => kipli().querySelector('.alan-izgara')!.hasAttribute('inert');

describe('kimlik şeridi kipi (stok / fiyat listesi)', () => {
  it('yeni stok DÜZENLEME kipinde açılır, avatar baş harf', () => {
    ciz({ yeniMi: true });
    expect(goster()).toBe(false);
    expect(inert()).toBe(false);
    expect(screen.getByTestId('kimlik-kalem').classList.contains('acik')).toBe(true);
    expect(screen.getByTestId('stok-avatar').textContent).toBe('EN');
  });

  it('kayıtlı stok GÖRÜNTÜLEME kipinde; ızgaraya tıklamak kipi değiştirmez, ✎ değiştirir', () => {
    ciz({ aktifSekme: 'genel' });
    expect(goster()).toBe(true);
    expect(inert()).toBe(true);
    fireEvent.mouseDown(kipli().querySelector('.alan-izgara')!);
    fireEvent.click(kipli().querySelector('.alan-izgara')!);
    expect(goster()).toBe(true);
    fireEvent.click(screen.getByTestId('kimlik-kalem'));
    expect(goster()).toBe(false);
    expect(inert()).toBe(false);
  });

  it('sekme değişince görüntülemeye döner; ilk sekme ataması kapatmaz', async () => {
    // Yeni kart: aktifSekme önce null (GenForm ilk sekmeyi effect ile verir) → 'genel' ataması kip KAPATMAMALI.
    const { yeniden } = ciz({ yeniMi: true, aktifSekme: null });
    await act(async () => { yeniden('genel') });
    expect(goster()).toBe(false);
    await act(async () => { yeniden('fiyat') });
    expect(goster()).toBe(true);
  });

  it('salt okunur kartta ✎ pasif, hep görüntüleme', () => {
    ciz({ salt: true });
    expect(goster()).toBe(true);
    expect((screen.getByTestId('kimlik-kalem') as HTMLButtonElement).disabled).toBe(true);
  });

  it('fiyat listesi de kipli; avatar yok', () => {
    ciz({ kaynak: 'fiyat-listesi', deger: { id: 3, ad: 'Perakende' } });
    expect(goster()).toBe(true);
    expect(kipli().querySelector('.alan-izgara')!.classList.contains('kaid-fiyat')).toBe(true);
    expect(screen.queryByTestId('stok-avatar')).toBeNull();
  });

  it('pasif stok avatarı gri', () => {
    ciz({ deger: { id: 77, ad: 'Serum Fizyolojik', durum: '0' } });
    expect(screen.getByTestId('stok-avatar').classList.contains('pasif')).toBe(true);
  });
});
