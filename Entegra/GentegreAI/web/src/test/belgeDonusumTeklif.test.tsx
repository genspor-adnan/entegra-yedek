// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';

// UNIVERSE teklif 10286'nın açık satırları (v_belge_acik_satir, 09.11.2026): tutar hasta_ek_katki kovasında,
//   provizyon / SGK / ÖSS 0, tutar_kalan dolu. Kullanıcı: "Satış Teklifi listesinde sağ tık Belgeye Dönüştür ->
//   'Belgeye dönüşecek tutar kalmadı' uyarısı, dönüştürülemiyor".
const satirlar = [
  { satirId: 11830, sira: 1, satirTur: 1, stokId: 5, stokKodu: 'A', stokAdi: 'Cihaz', aciklama: '', miktar: 5, kapatilanMiktar: 0,
    kalanMiktar: 5, birim: 51, birimFiyat: 8339.96, iskonto: 0, kdv: 10, belgeTur: 18, belgeNo: '000000001', tarafUnvan: 'X',
    belgeDovizi: 'TL', kapanmaDurum: 0, rota: 1, sgk: 0, oss: 0, hastaProvizyon: 0, hastaEkKatki: 41699.8,
    sgkKalan: 0, ossKalan: 0, hastaProvizyonKalan: 0, hastaEkKatkiKalan: 41699.8, kurumTutar: 0, hastaTutar: 41699.8,
    kurumKalan: 0, hastaKalan: 41699.8, tutar: 41699.8, hastaTahsilMatrah: 0, kurumTahsilMatrah: 0, tutarKalan: 41699.8, izleme: 0 },
  { satirId: 11829, sira: 2, satirTur: 2, hizmetId: 9, kalemAdi: 'Kurulum', aciklama: '', miktar: 1, kapatilanMiktar: 0,
    kalanMiktar: 1, birim: 0, birimFiyat: 150, iskonto: 0, kdv: 10, belgeTur: 18, belgeNo: '000000001', tarafUnvan: 'X',
    belgeDovizi: 'TL', kapanmaDurum: 0, rota: 1, sgk: 0, oss: 0, hastaProvizyon: 0, hastaEkKatki: 150,
    sgkKalan: 0, ossKalan: 0, hastaProvizyonKalan: 0, hastaEkKatkiKalan: 150, kurumTutar: 0, hastaTutar: 150,
    kurumKalan: 0, hastaKalan: 150, tutar: 150, hastaTahsilMatrah: 0, kurumTahsilMatrah: 0, tutarKalan: 150, izleme: 0 },
];

vi.mock('../api/istemci', () => ({
  api: {
    belgeAcikSatirlar: vi.fn(async () => satirlar),
    belgeDonustur: vi.fn(),
    stokLotlari: vi.fn(async () => []),
  },
}));

import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';

describe('Belge Dönüştür - teklif (18) -> sipariş (19)', () => {
  it('FİYATSIZ (0 TL) satırlar miktarla dönüşür: "kalmadı" uyarısı çıkmaz', async () => {
    const { api } = await import('../api/istemci');
    (api.belgeAcikSatirlar as ReturnType<typeof vi.fn>).mockResolvedValueOnce(
      satirlar.map(s => ({ ...s, birimFiyat: 0, tutar: 0, tutarKalan: 0, hastaEkKatki: 0, hastaEkKatkiKalan: 0,
                           hastaTutar: 0, hastaKalan: 0 })));
    render(<BelgeDonusumModali belgeId={10287} belgeTur={18} onKapat={() => {}} onTamam={() => {}} />);
    await waitFor(() => expect(screen.queryByText(/Cihaz/)).toBeTruthy());
    expect(screen.queryByText(/kalmadı/i)).toBeNull();
    expect((screen.getByRole('button', { name: /Dönüştür/ }) as HTMLButtonElement).disabled).toBe(false);
  });

  it('açık tutar satırların kalanıdır; "tutar kalmadı" uyarısı çıkmaz, Dönüştür etkin', async () => {
    render(<BelgeDonusumModali belgeId={10286} belgeTur={18} onKapat={() => {}} onTamam={() => {}} />);
    await waitFor(() => expect(screen.queryByText(/Cihaz/)).toBeTruthy());
    expect(screen.queryByText(/dönüşecek tutar kalmadı/i)).toBeNull();
    const dugme = screen.getByRole('button', { name: /Dönüştür/ });
    expect((dugme as HTMLButtonElement).disabled).toBe(false);
  });
});
