import { describe, expect, it } from 'vitest';
import { kysTedarikciAksiyonu, tedarikciDofYolu, tedarikciYenidenYolu } from '../sayfalar/liste/kysTedarikciAksiyonlari';
import { KYS_TEDARIKCI_LISTELERI } from '../sayfalar/listeTanimlari.KysTedarikci';

describe('kurumsal kalite tedarikçi değerlendirme', () => {
  it('DÖF adresi kaynak türü 8 ve tedarikçi taraf id taşır', () => {
    const y = tedarikciDofYolu({ id: 12, tarafId: 40, tedarikciAdi: 'Hızlı Lojistik', sonucAdi: 'Şartlı', puan: 3 });
    const p = new URLSearchParams(y.split('?')[1]);
    expect(y.startsWith('/kys-dof/yeni?')).toBe(true);
    expect(p.get('kaynakTur')).toBe('8');
    expect(p.get('kaynakId')).toBe('40');
    expect(p.get('kaynakNo')).toBe('Hızlı Lojistik');
    expect(p.get('tanim')).toContain('Şartlı');
  });
  it('yeniden değerlendirme tedarikçiyi dolu açar', () => {
    const p = new URLSearchParams(tedarikciYenidenYolu({ id: 3, tarafId: 9, neAliniyor: 'Koli' }).split('?')[1]);
    expect(p.get('tarafId')).toBe('9');
    expect(p.get('neAliniyor')).toBe('Koli');
  });
  it('yalnız kendi kodlarını işler', async () => {
    const gidilen: string[] = [];
    const b = { git: (y: string) => { gidilen.push(y) } };
    expect(await kysTedarikciAksiyonu('kys.risk-dof', { id: 1, tarafId: 1 }, b)).toBe(false);
    expect(await kysTedarikciAksiyonu('kys.tedarikci-dof', { id: 1, tarafId: 5 }, b)).toBe(true);
    expect(gidilen[0]).toContain('kaynakTur=8');
  });
  it('menü: Kalite grubu, kys modülü, kendi yetki kodu', () => {
    for (const l of KYS_TEDARIKCI_LISTELERI) {
      expect(l.menuGrup).toBe('Kalite');
      expect(l.modul).toBe('kys');
      expect(l.yetkiKodu).toBe('kys.tedarikci.liste');   // 1129: liste yalnız Gör, kart kys.tedarikci
      expect(l.urunModu).toBeUndefined();
    }
  });
});
