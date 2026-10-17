import { describe, expect, it } from 'vitest';
import { KYS_DOF_LISTELERI } from '../sayfalar/listeTanimlari.KysDof';

describe('kurumsal kalite DÖF listesi', () => {
  const t = KYS_DOF_LISTELERI[0];
  it('Kalite menüsünde, kys modülünde, generic kartla', () => {
    expect(t.menuGrup).toBe('Kalite');
    expect(t.modul).toBe('kys');
    expect(t.yetkiKodu).toBe('kys.dof.liste');   // 1129: liste yalnız Gör, kart kys.dof
    expect(t.kartYolu).toBe('/kys-dof');
    expect(t.ozelKart).toBeFalsy();
  });
  it('çipler: Açık / Vadesi geçen / Kapalı / Tümü', () => {
    expect(t.cipler?.map(c => c.ad)).toEqual(['Açık', 'Vadesi geçen', 'Kapalı', 'Tümü']);
    expect(t.cipler?.[2].filtre).toEqual({ alan: 'durum', op: 'esit', deger: 5 });
  });
});
