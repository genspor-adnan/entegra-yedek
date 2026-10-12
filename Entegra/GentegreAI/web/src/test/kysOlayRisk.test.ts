import { describe, expect, it } from 'vitest';
import { dofAcmaYolu, kysOlayRiskAksiyonu } from '../sayfalar/liste/kysOlayRiskAksiyonlari';
import { KYS_OLAY_RISK_LISTELERI } from '../sayfalar/listeTanimlari.KysOlayRisk';

describe('kurumsal kalite olay / risk', () => {
  it('olaydan DÖF açma adresi kaynak türü 2 taşır', () => {
    const y = dofAcmaYolu(2, { id: 7, no: 'OLY-2026-0007', turAdi: 'Hasta güvenliği', zararAdi: 'Hafif', departmanId: 3 });
    const p = new URLSearchParams(y.split('?')[1]);
    expect(y.startsWith('/kys-dof/yeni?')).toBe(true);
    expect(p.get('kaynakTur')).toBe('2');
    expect(p.get('kaynakId')).toBe('7');
    expect(p.get('kaynakNo')).toBe('OLY-2026-0007');
    expect(p.get('birimId')).toBe('3');
    expect(p.get('tanim')).toBe('Hasta güvenliği · Hafif');
  });
  it('riskten DÖF: tür 4, tanım risk metni, birim yoksa parametre yok', () => {
    const p = new URLSearchParams(dofAcmaYolu(4, { id: 2, no: 'RSK-2026-002', tanim: 'Yüksek riskli ilaç' }).split('?')[1]);
    expect(p.get('kaynakTur')).toBe('4');
    expect(p.get('tanim')).toBe('Yüksek riskli ilaç');
    expect(p.has('birimId')).toBe(false);
  });
  it('yalnız kendi kodlarını işler', async () => {
    const gidilen: string[] = [];
    const b = { git: (y: string) => { gidilen.push(y) } };
    expect(await kysOlayRiskAksiyonu('kys.dof-kart', { id: 1 }, b)).toBe(false);
    expect(await kysOlayRiskAksiyonu('kys.risk-dof', { id: 5, no: 'RSK-2026-005' }, b)).toBe(true);
    expect(gidilen[0]).toContain('kaynakTur=4');
  });
  it('menü: Kalite grubu, kys modülü', () => {
    for (const l of KYS_OLAY_RISK_LISTELERI) {
      expect(l.menuGrup).toBe('Kalite');
      expect(l.modul).toBe('kys');
      expect(l.urunModu).toBeUndefined();
    }
  });
});
