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
    expect(kysPanoHedefi('kys-dof', k => k === 'kys.dof.liste')).toBe('/kys-dof');   // 1129: liste ekran kodu
  });
});

describe('kalite panosu iyelik eki', async () => {
  const { iyelik } = await import('../sayfalar/kys/pano/KysPano');
  it("mockup '3'ü vadesi geçti' - son basamağa göre ünlü uyumu", () => {
    expect([1, 2, 3, 6, 9, 10, 40, 60, 100, 1000].map(iyelik))
      .toEqual(["1'i", "2'si", "3'ü", "6'sı", "9'u", "10'u", "40'ı", "60'ı", "100'ü", "1000'i"]);
  });
});
