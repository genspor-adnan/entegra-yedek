// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { useState } from 'react';
import type { KartAlanMeta } from '../api/sozlesme';

/**
 * HASTA KARTI STOK GİBİ KİPLİ (kullanıcı 16.11.2026: "hasta kartını da stok gibi yap"): kayıtlı hasta görüntülemede
 * (şerit inert, düz metin) açılır; ızgaraya tıklamak kipi değiştirmez, yalnız ✎. Kip GenForm'da tutulur (seritAcikDis).
 */
vi.mock('../api/istemci', () => ({ api: { dokumanlar: async () => [], dokumanIcerikUrl: async () => null } }));
const { KartKimlikSeridi, KIPLI_GOVDE_KARTLAR } = await import('../bilesenler/kart/KartKimlikSeridi');

const alanlar = [
  { ad: 'vkno', baslik: 'Kimlik No', tip: 'metin', zorunlu: true },
  { ad: 'ad', baslik: 'Ad', tip: 'metin', zorunlu: true },
  { ad: 'soyad', baslik: 'Soyad', tip: 'metin', zorunlu: true },
] as unknown as KartAlanMeta[];

function Sarmal({ yeniMi }: { yeniMi: boolean }) {
  const [acik, setAcik] = useState(yeniMi);
  return (
    <KartKimlikSeridi
      kaynak="hasta" deger={{ id: 5, ad: 'Ayşe', soyad: 'Kaya', vkno: '10000000146', durum: '1', kod: 'H-1' } as never}
      meta={null} salt={false} detaylar={{}} setDetaylar={() => {}} kimlikAlanlari={alanlar}
      renderAlanListesi={(a: KartAlanMeta[]) => a.map(x => (
        <label key={x.ad} className={`alan alan-${x.ad}`}><span className="etiket">{x.baslik}</span><input defaultValue="" /></label>))}
      personelGibiKart dogumYasMetni="14.03.1979 ♀ K 47 y" yeniMi={yeniMi}
      unvanOneki={{ onek: '', setOnek: () => {}, secenekler: [] } as never}
      aktifSekme="genel" seritAcikDis={acik} onSeritAcik={setAcik} />
  );
}
const kipli = () => screen.getByTestId('kimlik-kipli');

describe('hasta kartı görüntüleme / düzenleme kipi', () => {
  it('hasta kipli kartlar arasında', () => {
    expect(KIPLI_GOVDE_KARTLAR.has('hasta')).toBe(true);
  });

  it('kayıtlı hasta görüntüleme BANDI: ad soyad, etiketsiz kimlik no, durum rozeti; tıklama kipi değiştirmez, ✎ değiştirir', () => {
    render(<Sarmal yeniMi={false} />);
    expect(kipli().classList.contains('kisi-bant')).toBe(true);
    expect(kipli().textContent).toContain('Ayşe Kaya');
    expect(kipli().textContent).toContain('10000000146');
    expect(kipli().textContent).not.toContain('Kimlik No');
    expect(screen.getByTestId('hasta-durum').textContent).toBe('Aktif');
    expect(kipli().querySelector('input')).toBeNull();
    fireEvent.mouseDown(kipli().querySelector('.kim')!);
    fireEvent.click(kipli().querySelector('.kim')!);
    expect(kipli().classList.contains('kisi-bant')).toBe(true);
    fireEvent.click(screen.getByTestId('kimlik-kalem'));
    expect(kipli().classList.contains('kisi-bant')).toBe(false);
    expect(kipli().querySelector('input')).not.toBeNull();
    fireEvent.click(screen.getByTestId('kimlik-kalem'));
    expect(kipli().classList.contains('kisi-bant')).toBe(true);
  });

  it('yeni hasta düzenlemede (alan ızgarası) açılır', () => {
    render(<Sarmal yeniMi />);
    expect(kipli().classList.contains('kisi-bant')).toBe(false);
    expect(kipli().querySelector('input')).not.toBeNull();
  });
});
