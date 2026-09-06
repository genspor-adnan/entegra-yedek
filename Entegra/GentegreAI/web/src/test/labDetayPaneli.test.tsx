// @vitest-environment jsdom
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { LabDetayPaneli, labDetayVarMi } from '../bilesenler/LabDetayPaneli';

/**
 * LAB GRİD ALTI DETAY PANELİ (446).
 *
 * Panel sunucudan gelen kaydı çiziyor; alan adları uçlarla birebir olmalı.
 * Bir alan adı kayarsa ekran hata vermez, sessizce BOŞ görünür - mockup'a
 * benzeyen ama içi boş bir ekran, olmayan ekrandan daha kötüdür. Bu yüzden
 * uçların gerçek alan adlarıyla çiziliyor.
 */
const labIstemOku = vi.fn();
const labKulturOku = vi.fn();
const genetikVakaOku = vi.fn();
const disLabOku = vi.fn();

vi.mock('../api/istemci', () => ({
  api: {
    labIstemOku: (id: number) => labIstemOku(id),
    labKulturOku: (id: number) => labKulturOku(id),
    genetikVakaOku: (id: number) => genetikVakaOku(id),
    disLabOku: (id: number) => disLabOku(id),
  },
}));

beforeEach(() => {
  labIstemOku.mockReset(); labKulturOku.mockReset();
  genetikVakaOku.mockReset(); disLabOku.mockReset();
});

describe('LabDetayPaneli', () => {
  it('yalnız lab listelerinde çizilir', () => {
    expect(labDetayVarMi('lab-numune')).toBe(true);
    expect(labDetayVarMi('lab-kultur')).toBe(true);
    expect(labDetayVarMi('cari')).toBe(false);
  });

  it('numune listesinde İSTEMİN tetkikleri okunur (barkod değil istemId)', async () => {
    // Bir istemde birden çok tüp olur; panel tüpü değil istemi gösterir.
    labIstemOku.mockResolvedValue({
      istemNo: 'LAB-2026/31877', durum: 2, oncelik: 3, hasta: 'Ayşe Yılmaz',
      klinik: 'Boğaz ağrısı', tani: 'J03.9',
      numuneler: [{ id: 5, barkod: '2603187701', tupTipi: 1, numuneTipi: 1, durum: 3 }],
      satirlar: [{
        satirId: 9, kod: 'CRP', ad: 'C-Reaktif Protein', durum: 3, bolum: 1,
        barkod: '2603187701', deger: '24,0', birim: 'mg/L',
        referansAlt: null, referansUst: 5, referansMetin: '', bayrak: 'H',
      }],
    });

    render(<LabDetayPaneli kaynak="lab-numune"
                           satir={{ id: 5, istemId: 77, barkod: '2603187701' }} />);

    await waitFor(() => expect(labIstemOku).toHaveBeenCalledWith(77));
    expect(await screen.findByText('C-Reaktif Protein')).toBeTruthy();
    // Tüp rengi mockup'taki gibi metinle birlikte: "Sarı jel" - hem tetkik
    //   satırında hem tüp listesinde (aynı renk, iki yer).
    expect(screen.getAllByText('Sarı jel').length).toBe(2);
    // Tek taraflı referans "≤ 5" olarak yazılır, "0 – 5" değil.
    expect(screen.getByText('≤ 5')).toBeTruthy();
    expect(screen.getByText('ACİL')).toBeTruthy();
  });

  it('kültür panelinde antibiyogram ve direnç işareti görünür', async () => {
    // Kademeli bildirimde GİZLENEN ajan da listelenir: uzman neyin
    //   raporlanmadığını görebilmeli.
    labKulturOku.mockResolvedValue({
      kultur: { tetkikAd: 'İdrar kültürü', ozet: 'E. coli' },
      besiyeriler: [{ id: 1, kod: 'CLED', ad: 'CLED' }],
      okumalar: [{ id: 1, saat: 24, zaman: '2026-09-03T09:40:00', uremeVar: true,
                   bulgu: 'Üreme var', sonrakiAdim: 'MALDI-TOF' }],
      izolatlar: [{ id: 3, izolatNo: 1, organizma: 'Escherichia coli',
                    organizmaKod: 'ECOLI', koloniSayisi: 100000, koloniBirim: 'CFU/mL',
                    idYontem: 1, esbl: 0, mrsa: 1 }],
      antibiyogram: [
        { id: 11, kod: 'AMP', ad: 'Ampisilin', mic: 32, micIsaret: '≥',
          yorum: 'R', kaynak: 1, bildir: true },
        { id: 12, kod: 'GEN', ad: 'Gentamisin', mic: 1, micIsaret: '',
          yorum: 'S', kaynak: 1, bildir: false },
      ],
    });

    render(<LabDetayPaneli kaynak="lab-kultur" satir={{ id: 4 }} />);

    await waitFor(() => expect(labKulturOku).toHaveBeenCalledWith(4));
    expect(await screen.findByText('Ampisilin')).toBeTruthy();
    expect(screen.getByText('Escherichia coli')).toBeTruthy();
    expect(screen.getByText('MRSA')).toBeTruthy();
    expect(screen.getAllByText('MALDI-TOF').length).toBeGreaterThan(0);
    // Raporlanmayan ajan "Kademeli" olarak işaretli.
    expect(screen.getByText('Kademeli')).toBeTruthy();
  });

  it('genetik panelinde ONAM eksikse kırmızı yazar', async () => {
    // KVKK md. 6: onamsız rapor yok. Eksik onam ekranda saklanmamalı.
    genetikVakaOku.mockResolvedValue({
      vaka: { vakaNo: 'GEN-2026/14', panel: 'Herediter kanser paneli',
              onamTarihi: null, tesadufiBulgu: 1 },
      varyantlar: [{ id: 2, genSembol: 'BRCA1', transkript: 'NM_007294.4',
                     hgvsC: 'c.5266dupC', hgvsP: 'p.Gln1756fs', zigosite: 1,
                     vaf: 49.5, sinif: 5, raporla: true, acmg: ['PVS1', 'PM2'] }],
    });

    render(<LabDetayPaneli kaynak="lab-genetik-vaka" satir={{ id: 8 }} />);

    expect(await screen.findByText('BRCA1')).toBeTruthy();
    expect(screen.getByText('alınmadı')).toBeTruthy();
    expect(screen.getByText('Patojenik')).toBeTruthy();
    expect(screen.getByText('Heterozigot')).toBeTruthy();
  });

  it('satır seçilmemişse boş kutu yerine yönlendirme yazar', () => {
    render(<LabDetayPaneli kaynak="lab-kultur" satir={null} />);
    expect(screen.getByText(/listeden bir satır seçin/i)).toBeTruthy();
    expect(labKulturOku).not.toHaveBeenCalled();
  });
});
