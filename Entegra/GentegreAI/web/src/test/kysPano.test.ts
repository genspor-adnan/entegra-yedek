import { describe, it, expect } from 'vitest';
import { KYS_PANO_LISTELERI } from '../sayfalar/listeTanimlari.KysPano';
import { KYS_PANO_TUR_ROZET, kysPanoHedefi } from '../sayfalar/kys/pano/KysPano';

describe('Kalite panosu (1055)', () => {
  it('menüde Kalite grubunun ilk satırı, kendi kodu', () => {
    const [p] = KYS_PANO_LISTELERI;
    expect(p.menuGrup).toBe('Kalite');
    expect(p.menuSira).toBe(10);
    expect(p.yetkiKodu).toBe('kys.pano');
    expect(p.ozelSayfa).toBe(true);
  });

  it('bana düşenler türlerinin hepsinin rozeti var', () => {
    for (const t of ['DÖF', 'Faaliyet', 'Olay', 'Karar', 'Denetim']) expect(KYS_PANO_TUR_ROZET[t]).toBeTruthy();
  });

  it('kart hedefi: tanımsız rota ya da yetkisiz liste tıklanmaz', () => {
    expect(kysPanoHedefi('yok-boyle-bir-ekran', () => true)).toBeNull();
    expect(kysPanoHedefi('kys-dof', () => false)).toBeNull();
    expect(kysPanoHedefi('kys-dof', k => k === 'kys.dof')).toBe('/kys-dof');
  });
});
