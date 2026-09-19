import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ApiHatasi } from '../api/sozlesme';
import { akilciEngelKodu, akilciUyariAkisi } from '../sayfalar/liste/akilciIstem';

/**
 * AKILCI TEST İSTEMİ — hekim karar akışı (873).
 *
 * Kural sunucuda; bu yardımcı yalnız 422 AKILCI_UYARI gövdesini diyaloğa çevirir.
 * Testler: gerekçe seçimi → devam kararı; "Hayır" → tetkik çıkar + vazgeçme
 * sunucuya yazılır; ENGEL aşılmaz; başka hata akışa girmez; diyalog kapatılınca
 * istem gönderilmez.
 */
const secimSor = vi.fn();
const mesaj = vi.fn();
const labAkilciKarar = vi.fn();
vi.mock('../bilesenler/mesaj', () => ({ secimSor: (...a: unknown[]) => secimSor(...a), mesaj: (m: string) => mesaj(m) }));
vi.mock('../api/istemci', () => ({ api: { labAkilciKarar: (g: unknown) => labAkilciKarar(g) } }));

beforeEach(() => { secimSor.mockReset(); mesaj.mockReset(); labAkilciKarar.mockReset().mockResolvedValue({ tamam: true }) });

const uyariHatasi = () => new ApiHatasi(422, {
  kod: 'IS_KURALI', mesaj: 'Bu testin 19.09.2026 tarihinde yapılmış bir sonucu bulunmaktadır…', izlemeNo: 'x',
  engel: {
    kod: 'AKILCI_UYARI',
    uyarilar: [
      { tetkikId: 1, ad: 'CRP', kural: 'sure', mesaj: 'CRP 7 gün içinde istenmiş. Tekrar istemek istediğinizden emin misiniz?',
        sureGun: 7, sonTarih: '2026-09-19T10:00:00', kalanGun: 7,
        sonuclar: [{ tarih: '2026-09-19T10:00:00', deger: '12', birim: 'mg/L', bayrak: 'H', durum: 'onaylı' }] },
      { tetkikId: 14, ad: 'TSH', kural: 'brans', mesaj: 'TSH göz branşına açık değil.', sureGun: 0 },
    ],
    gerekceler: [{ kod: 1, ad: 'KLİNİK UYUMSUZLUK' }, { kod: 2, ad: 'TEDAVİNİN TAKİBİ' }],
    klinikGerekceler: [{ kod: 3, ad: 'SAĞLIK TESİSİNDE İLGİLİ UZMANLIK BRANŞI MEVCUT DEĞİL' }],
  },
});

describe('akilciUyariAkisi', () => {
  it('engel kodunu tanır, başka hatayı akışa sokmaz', () => {
    expect(akilciEngelKodu(uyariHatasi())).toBe('AKILCI_UYARI');
    expect(akilciEngelKodu(new ApiHatasi(422, { kod: 'IS_KURALI', mesaj: 'x', izlemeNo: '', engel: { kod: 'KARANTINA' } }))).toBeNull();
    expect(akilciEngelKodu(new Error('ağ'))).toBeNull();
  });

  it('süre uyarısında gerekçe, branş uyarısında KLİNİK gerekçe listesi sorulur; kararlar toplanır', async () => {
    secimSor.mockResolvedValueOnce('2').mockResolvedValueOnce('3');
    const k = await akilciUyariAkisi(uyariHatasi(), 45158, 7905);
    expect(k).toEqual({ akilci: [{ tetkikId: 1, kural: 'sure', gerekceKod: 2 }, { tetkikId: 14, kural: 'brans', gerekceKod: 3 }], cikar: [] });
    // İlk soru: son sonuç metni + süre gerekçeleri + "Hayır"; ikinci: klinik gerekçeler.
    const [soru1, secenek1] = secimSor.mock.calls[0] as [string, { kod: string; ad: string }[]];
    expect(soru1).toContain('12 mg/L');
    expect(secenek1.map(s => s.kod)).toEqual(['1', '2', 'HAYIR']);
    const [, secenek2] = secimSor.mock.calls[1] as [string, { kod: string; ad: string }[]];
    expect(secenek2.map(s => s.kod)).toEqual(['3', 'HAYIR']);
    expect(labAkilciKarar).not.toHaveBeenCalled();
  });

  it('"Hayır" tetkiği çıkarır ve vazgeçmeyi sunucuya yazar (§4.6)', async () => {
    secimSor.mockResolvedValueOnce('HAYIR').mockResolvedValueOnce('3');
    const k = await akilciUyariAkisi(uyariHatasi(), 45158);
    expect(k).toEqual({ akilci: [{ tetkikId: 14, kural: 'brans', gerekceKod: 3 }], cikar: [1] });
    expect(labAkilciKarar).toHaveBeenCalledWith(expect.objectContaining({
      hastaId: 45158, kararlar: [expect.objectContaining({ tetkikId: 1, kural: 'sure', aciklama: 'hekim vazgeçti' })],
    }));
  });

  it('diyalog kapatılırsa null döner (istem gönderilmez)', async () => {
    secimSor.mockResolvedValueOnce('');
    expect(await akilciUyariAkisi(uyariHatasi(), 45158)).toBeNull();
  });

  it('AKILCI_ENGEL aşılmaz: mesaj gösterilir, null döner', async () => {
    const engel = new ApiHatasi(422, { kod: 'IS_KURALI', mesaj: 'engel', izlemeNo: '',
      engel: { kod: 'AKILCI_ENGEL', tetkikler: [{ tetkikId: 9, ad: 'HLA', kural: 'basamak', mesaj: 'yalnız 3. basamak' }] } });
    expect(await akilciUyariAkisi(engel, 45158)).toBeNull();
    expect(mesaj).toHaveBeenCalledWith(expect.stringContaining('HLA: yalnız 3. basamak'));
    expect(secimSor).not.toHaveBeenCalled();
  });
});
