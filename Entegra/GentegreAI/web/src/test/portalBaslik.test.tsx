import { describe, expect, it } from 'vitest';
import { renderToStaticMarkup } from 'react-dom/server';
import { PortalBaslikSaglayici, usePortalBaslik, usePortaldaMi }
  from '../sayfalar/portal/portalBaslik';
import type { MenuKaynagi } from '../sayfalar/portal/portalMenu';

/**
 * PORTALDA BAŞLIK = MENÜ ADI (796 V2).
 *
 * Kullanıcı menüde "Randevularım"a tıklayıp sayfada "Randevular" görüyordu.
 * Ad tek yerde (portalMenu) durur; başlık oradan okunur. Portal dışında
 * hiçbir şey değişmez - kanca `undefined` döner.
 */

const MENU: MenuKaynagi[] = [
  { yol: '/randevu', ad: 'Randevular', ic: '📅', kaynak: 'randevu' },
  { yol: '/lab-sonuc', ad: 'Sonuç Onay Kuyruğu', ic: '📊', kaynak: 'lab-sonuc' },
];

function Deneme({ yol }: { yol: string }) {
  const ad = usePortalBaslik(yol);
  return <span>{`${usePortaldaMi() ? 'portal' : 'kurum'}:${ad ?? '—'}`}</span>;
}

const ciz = (yol: string, portalTuru: 1 | 2 | 3 = 3) => renderToStaticMarkup(
  <PortalBaslikSaglayici ogeler={MENU} portalTuru={portalTuru}>
    <Deneme yol={yol} />
  </PortalBaslikSaglayici>);

describe('portal başlığı', () => {
  it('hasta portalında ekranın adı menüdeki addır', () => {
    expect(ciz('/randevu')).toContain('portal:Randevularım');
    expect(ciz('/lab-sonuc')).toContain('portal:Lab sonuçlarım');
  });

  it('dış hekimde aynı ekran kendi adıyla', () => {
    expect(ciz('/lab-sonuc', 1)).toContain('portal:Lab sonuçları');
  });

  it('menüde olmayan yol için başlık zorlanmaz', () => {
    // Eşleşme yoksa ekran KENDİ başlığını kullanmalı - uydurma ad değil.
    expect(ciz('/bilinmeyen')).toContain('portal:—');
  });

  it('portal dışında sağlayıcı yok: kanca undefined döner', () => {
    expect(renderToStaticMarkup(<Deneme yol="/randevu" />)).toContain('kurum:—');
  });
});
