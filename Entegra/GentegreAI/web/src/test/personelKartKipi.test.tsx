// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { useState } from 'react';
import type { KartAlanMeta } from '../api/sozlesme';

/**
 * PERSONEL KARTI STOK GİBİ KİPLİ (kullanıcı 17.11.2026: "personel kartını da stok kartı deseni gibi yap.. view/edit
 * modu da olsun"): kayıtlı personel görüntülemede açılır - şerit görünür ama düz metin + inert; yalnız ✎ düzenlemeye
 * geçirir. Hastadan farkı: görüntülemede şerit GİZLENMEZ (personelin ayrı bir kimlik bandı yok).
 */
vi.mock('../api/istemci', () => ({ api: { dokumanlar: async () => [], dokumanIcerikUrl: async () => null } }));
const { KartKimlikSeridi, KIPLI_GOVDE_KARTLAR } = await import('../bilesenler/kart/KartKimlikSeridi');

const alanlar = [
  { ad: 'ad', baslik: 'Ad', tip: 'metin', zorunlu: true },
  { ad: 'soyad', baslik: 'Soyad', tip: 'metin', zorunlu: true },
] as unknown as KartAlanMeta[];

function Sarmal({ yeniMi, salt = false }: { yeniMi: boolean; salt?: boolean }) {
  const [acik, setAcik] = useState(yeniMi);
  return (
    <KartKimlikSeridi
      kaynak="personel" deger={{ id: 7, ad: 'Ali', soyad: 'Kaya', durum: '1' } as never}
      meta={null} salt={salt} detaylar={{}} setDetaylar={() => {}} kimlikAlanlari={alanlar}
      renderAlanListesi={(a: KartAlanMeta[]) => a.map(x => (
        <label key={x.ad} className={`alan alan-${x.ad}`}><span className="etiket">{x.baslik}</span><input defaultValue="" /></label>))}
      personelGibiKart dogumYasMetni="" yeniMi={yeniMi}
      unvanOneki={{ onek: '', setOnek: () => {}, secenekler: ['Dr.'] } as never}
      aktifSekme="genel" seritAcikDis={acik} onSeritAcik={setAcik} />
  );
}
const kipli = () => screen.getByTestId('kimlik-kipli');
const inert = () => kipli().querySelector('.kaid-hasta-sar')!.hasAttribute('inert');

describe('personel kartı görüntüleme / düzenleme kipi', () => {
  it('personel kipli kartlar arasında', () => {
    expect(KIPLI_GOVDE_KARTLAR.has('personel')).toBe(true);
  });

  it('kayıtlı personel görüntülemede: şerit görünür, düz metin + inert; ✎ açar, tekrar ✎ kapatır', () => {
    render(<Sarmal yeniMi={false} />);
    expect(kipli().classList.contains('kaid-goster')).toBe(true);
    expect(inert()).toBe(true);
    fireEvent.click(screen.getByTestId('kimlik-kalem'));
    expect(kipli().classList.contains('kaid-goster')).toBe(false);
    expect(inert()).toBe(false);
    fireEvent.click(screen.getByTestId('kimlik-kalem'));
    expect(inert()).toBe(true);
  });

  it('yeni personel düzenlemede açılır', () => {
    render(<Sarmal yeniMi />);
    expect(inert()).toBe(false);
  });

  it('yetkisiz kullanıcıda ✎ pasif, şerit görüntülemede kalır', () => {
    render(<Sarmal yeniMi={false} salt />);
    expect((screen.getByTestId('kimlik-kalem') as HTMLButtonElement).disabled).toBe(true);
    expect(inert()).toBe(true);
  });
});
