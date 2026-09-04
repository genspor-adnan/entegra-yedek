// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { GenDetayTablo, bosDetay, type DetayDurumu } from '../bilesenler/GenDetayTablo';
import type { KartDetayMeta } from '../api/sozlesme';
import gercekMeta from './veri/primTaraflarMeta.json';

/**
 * PRIM ALANLAR: "+ Kişi Ekle" -> jenerik arama -> Enter -> SATIR EKLENIR.
 *
 * Kullanici "arama açılıyor ama ekleme yapamıyorum" dedi; akisin tamami
 * bilesenler arasinda dagildigi icin (GenDetayTablo -> TarafArama -> onSec ->
 * onDegis) hicbir birim testi bunu tutmuyordu.
 */
const liste = vi.fn();

vi.mock('../api/istemci', () => ({
  api: {
    liste: (kaynak: string, istek: unknown) => liste(kaynak, istek),
    aramaIsaretle: () => Promise.resolve({}),
    kodListe: () => Promise.resolve({ degerler: [] }),
  },
}));

// GERCEK SUNUCU META'SI (kirpilmis kod listesiyle): uydurma meta ile testin
//   gecip ekranin calismamasi tam da bu ekranda yasandi.
const meta = gercekMeta as unknown as KartDetayMeta;

beforeEach(() => {
  vi.clearAllMocks();
  liste.mockImplementation((kaynak: string) => Promise.resolve({
    // Arama SIRASI kaynaklar dizisiyle ayni: once 'personel', sonra
    //   'dis-hekim' - listedeki ilk satir bu yuzden personeldir.
    satirlar: kaynak === 'dis-hekim'
      ? [{ id: 5030, kod: 'DH-AKIN', unvan: 'Dr. Akın YILDIRIM' }]
      : [{ id: 4888, kod: 'P-4888', unvan: 'aaa ooo' }],
  }));
});

function Kap({ durum, onDegis }: { durum: DetayDurumu; onDegis(y: DetayDurumu): void }) {
  return <GenDetayTablo meta={meta} durum={durum} saltOkunur={false}
                        hatalar={{}} onDegis={onDegis} />;
}

const ciz = () => {
  const durum = bosDetay();
  const degisenler: DetayDurumu[] = [];
  const { rerender } = render(
    <Kap durum={durum} onDegis={y => { degisenler.push(y); rerender(<Kap durum={y} onDegis={() => {}} />) }} />);
  return degisenler;
};

describe('Prim Alanlar - isaretleyip toplu ekleme', () => {
  const araya = async () => {
    fireEvent.click(screen.getByRole('button', { name: /Kişi Ekle/ }));
    await screen.findByPlaceholderText(/Kişi ara/);
    await waitFor(() => expect(
      document.querySelector('.lookup-liste')?.textContent).toContain('aaa ooo'));
  };
  const listedeSatir = (ad: string) => {
    const tr = [...document.querySelectorAll('.lookup-liste tbody tr')]
      .find(x => (x.textContent ?? '').includes(ad));
    if (!tr) throw new Error(`listede "${ad}" yok`);
    return tr;
  };

  it('+ dugmesi ARAMAYI acar', async () => {
    ciz();
    fireEvent.click(screen.getByRole('button', { name: /Kişi Ekle/ }));
    expect(await screen.findByPlaceholderText(/Kişi ara/)).toBeInTheDocument();
  });

  it('TIK ISARETLER, satir HENUZ EKLENMEZ', async () => {
    const degisenler = ciz();
    await araya();
    fireEvent.click(listedeSatir('aaa ooo'));
    // Isaret koymak kayit degildir: "Seç"e basilana kadar grid degismez,
    //   kullanici vazgecebilir.
    expect(degisenler).toHaveLength(0);
    expect(await screen.findByText(/1 işaretli/)).toBeInTheDocument();
  });

  it('SEC: isaretlilerin HEPSI tek seferde eklenir ve pencere KAPANIR', async () => {
    const degisenler = ciz();
    await araya();
    fireEvent.click(listedeSatir('aaa ooo'));
    fireEvent.click(listedeSatir('Dr. Akın YILDIRIM'));
    fireEvent.click(screen.getByRole('button', { name: /^Seç \(2\)$/ }));

    await waitFor(() => expect(degisenler.length).toBeGreaterThan(0));
    const son = degisenler[degisenler.length - 1];
    // TEK guncelleme, IKI satir: her secilen icin ayri onDegis cagrilsaydi
    //   hepsi ayni durumdan turetilir ve yalniz sonuncusu kalirdi.
    expect(son.guncel.map(r => String(r.tarafId))).toEqual(['4888', '5030']);
    expect(screen.queryByPlaceholderText(/Kişi ara/)).toBeNull();
  });

  it('ISARET GERI ALINIR (ikinci tik)', async () => {
    ciz();
    await araya();
    fireEvent.click(listedeSatir('aaa ooo'));
    expect(await screen.findByText(/1 işaretli/)).toBeInTheDocument();
    fireEvent.click(listedeSatir('aaa ooo'));
    expect(screen.queryByText(/işaretli/)).toBeNull();
  });

  it('ZATEN EKLI kisi ISARETLENEMEZ - sebebi yazar', async () => {
    const durum = { ...bosDetay(), ilk: [{ id: 1, tarafId: '4888' }],
                    guncel: [{ id: 1, tarafId: '4888' }] };
    render(<GenDetayTablo meta={meta} durum={durum} saltOkunur={false}
                          hatalar={{}} onDegis={() => {}} />);
    await araya();
    fireEvent.click(listedeSatir('aaa ooo'));
    expect(await screen.findByText(/zaten ekli/)).toBeInTheDocument();
    expect(screen.queryByText(/işaretli/)).toBeNull();
  });
});
