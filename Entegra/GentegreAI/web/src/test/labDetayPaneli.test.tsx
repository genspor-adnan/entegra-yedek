// @vitest-environment jsdom
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
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

  /** Mockup lab_istem_numune_kabul.html: tüp planı + kabul kolonları. */
  const istemKaydi = () => ({
    istemNo: 'LAB-2026/31877', durum: 2, oncelik: 3, hasta: 'Ayşe Yılmaz',
    yas: '39y', cinsiyet: 'K', kimlik: '1234567****', protokol: '2026/20417',
    hekim: 'Dr. A. Koç', hazirlik: '8 saat açlık',
    klinik: 'Boğaz ağrısı', tani: 'J03.9',
    kaynakAd: 'Muayene istemi', alerjiler: 'Penisilin', kronik: 'Hipotiroidi',
    agirAlerji: true, kanGrubu: 'A Rh+', dosyaNo: 'H-004182',
    numuneler: [{ id: 5, barkod: '2603187701', tupTipi: 1, numuneTipi: 1, durum: 3,
                  alim: '2026-09-03T09:12:00', kabul: '2026-09-03T09:20:00',
                  alan: 'Hemşire N. Koç', alimYeri: 'Kan alma', kalite: 1,
                  hemoliz: 4, lipemi: 1, ikter: 0,
                  saklamaYeri: 'Dolap A / Raf 2', saklamaSicaklik: 4 }],
    tatlar: [{ bolum: 1, hedefDk: 120, yuzde: 62, kalanDk: 12, biten: 0, toplam: 1 }],
    oncekiler: [{ ad: 'CRP', deger: '18', birim: 'mg/L', bayrak: 'H',
                  zaman: '2026-08-12T10:00:00' }],
    satirlar: [{
      satirId: 9, kod: 'CRP', ad: 'C-Reaktif Protein', durum: 3, bolum: 1,
      barkod: '2603187701', deger: '24,0', birim: 'mg/L',
      referansAlt: null, referansUst: 5, referansMetin: '', bayrak: 'H',
      numuneTipi: 1, tupTipi: 1, alim: '2026-09-03T09:12:00',
      kabul: '2026-09-03T09:20:00', hedefTat: 120, cihaz: 'Cobas c503',
    }],
  });

  it('numune listesinde İSTEMİN tetkikleri okunur (barkod değil istemId)', async () => {
    // Bir istemde birden çok tüp olur; panel tüpü değil istemi gösterir.
    labIstemOku.mockResolvedValue(istemKaydi());

    render(<MemoryRouter>
      <LabDetayPaneli kaynak="lab-numune"
                      satir={{ id: 5, istemId: 77, barkod: '2603187701' }} />
    </MemoryRouter>);

    await waitFor(() => expect(labIstemOku).toHaveBeenCalledWith(77));
    expect(await screen.findByText('C-Reaktif Protein')).toBeTruthy();
    // Tüp rengi mockup'taki gibi metinle birlikte: "Sarı jel" - hem tetkik
    //   satırında hem etiket kutucuğunda (aynı renk, iki yer).
    expect(screen.getAllByText('Sarı jel').length).toBe(2);
    // NUMUNE KABUL KOLONLARI (mockup): numune tipi, hedef TAT ve cihaz.
    //   Sonuç kolonları bu ekranda YOK - aynı tablo iki soruya cevap veremez.
    expect(screen.getByText('Serum')).toBeTruthy();
    expect(screen.getByText('2 s')).toBeTruthy();
    expect(screen.getByText('Cobas c503')).toBeTruthy();
    expect(screen.queryByText('≤ 5')).toBeNull();
    expect(screen.getByText('ACİL')).toBeTruthy();
    // Sağ panel mockup'taki hasta şeridi: ad, yaş/cinsiyet ve MASKELİ kimlik
    //   ayrı ayrı - kimlik rozeti ada karışmasın.
    expect(screen.getByText('Ayşe Yılmaz')).toBeTruthy();
    expect(screen.getByText('39y K')).toBeTruthy();
    expect(screen.getByText('1234567****')).toBeTruthy();
    expect(screen.getByText('8 saat açlık')).toBeTruthy();
    expect(screen.getByText(/Hemşire N. Koç/)).toBeTruthy();
    // Uyarı bandı, kaynak, serum indeksi ve TAT çubuğu (mockup
    //   lab_hasta_istem_karti.html): hepsi sunucudan gelen değerle çizilir.
    expect(screen.getByText(/Penisilin/)).toBeTruthy();
    expect(screen.getByText('Muayene istemi')).toBeTruthy();
    expect(screen.getByText('H 4')).toBeTruthy();
    expect(screen.getByText('12 dk kaldı')).toBeTruthy();
    // "Son laboratuvar" kutusu: onceki ONAYLI deger, delta kontrolunun dayanagi.
    const oncekiKutu = screen.getByText('Son laboratuvar').closest('.kagrup');
    expect(oncekiKutu?.textContent).toContain('18');
    expect(oncekiKutu?.textContent).toContain('mg/L');
  });

  it('sonuç listesinde sonuç kolonları çizilir (referans, bayrak)', async () => {
    labIstemOku.mockResolvedValue(istemKaydi());

    render(<MemoryRouter>
      <LabDetayPaneli kaynak="lab-sonuc" satir={{ id: 9, istemId: 77 }} />
    </MemoryRouter>);

    await waitFor(() => expect(labIstemOku).toHaveBeenCalledWith(77));
    // Tek taraflı referans "≤ 5" olarak yazılır, "0 – 5" değil.
    expect(await screen.findByText('≤ 5')).toBeTruthy();
    expect(screen.getByText('24,0')).toBeTruthy();
    // Kabul kolonları sonuç ekranında yer tutmaz.
    expect(screen.queryByText('Cobas c503')).toBeNull();
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

    render(<MemoryRouter><LabDetayPaneli kaynak="lab-kultur" satir={{ id: 4 }} /></MemoryRouter>);

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

    render(<MemoryRouter><LabDetayPaneli kaynak="lab-genetik-vaka" satir={{ id: 8 }} /></MemoryRouter>);

    expect(await screen.findByText('BRCA1')).toBeTruthy();
    expect(screen.getByText('alınmadı')).toBeTruthy();
    expect(screen.getByText('Patojenik')).toBeTruthy();
    expect(screen.getByText('Heterozigot')).toBeTruthy();
  });

  it('satır seçilmemişse boş kutu yerine yönlendirme yazar', () => {
    render(<MemoryRouter><LabDetayPaneli kaynak="lab-kultur" satir={null} /></MemoryRouter>);
    expect(screen.getByText(/listeden bir satır seçin/i)).toBeTruthy();
    expect(labKulturOku).not.toHaveBeenCalled();
  });
});
