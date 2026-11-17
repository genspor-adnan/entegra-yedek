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
const inert = () => kipli().querySelector('.kaid-hasta-sar')!.hasAttribute('inert');

describe('hasta kartı görüntüleme / düzenleme kipi', () => {
  it('hasta kipli kartlar arasında', () => {
    expect(KIPLI_GOVDE_KARTLAR.has('hasta')).toBe(true);
  });

  it('kayıtlı hasta görüntülemede; tıklama kipi değiştirmez, ✎ değiştirir', () => {
    render(<Sarmal yeniMi={false} />);
    expect(kipli().classList.contains('kaid-goster')).toBe(true);
    expect(inert()).toBe(true);
    fireEvent.mouseDown(kipli().querySelector('.kaid-hasta-sar')!);
    fireEvent.click(kipli().querySelector('.kaid-hasta-sar')!);
    expect(kipli().classList.contains('kaid-goster')).toBe(true);
    fireEvent.click(screen.getByTestId('kimlik-kalem'));
    expect(kipli().classList.contains('kaid-goster')).toBe(false);
    expect(inert()).toBe(false);
  });

  it('yeni hasta düzenlemede açılır', () => {
    render(<Sarmal yeniMi />);
    expect(kipli().classList.contains('kaid-goster')).toBe(false);
    expect(inert()).toBe(false);
  });
});
