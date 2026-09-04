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

describe('Prim Alanlar - aramayla ekleme', () => {
  it('+ dugmesi ARAMAYI acar', async () => {
    ciz();
    fireEvent.click(screen.getByRole('button', { name: /Kişi Ekle/ }));
    expect(await screen.findByPlaceholderText(/Kişi ara/)).toBeInTheDocument();
  });

  it('SATIRA TIKLAYIP Enter: kullanicinin dogal akisi', async () => {
    // Kullanici once listeden kisiyi TIKLAR, sonra Enter'lar. Enter dinleyicisi
    //   pencerenin tamaminda oldugu icin odak satira gecse de calismali.
    const degisenler = ciz();
    fireEvent.click(screen.getByRole('button', { name: /Kişi Ekle/ }));
    await screen.findByPlaceholderText(/Kişi ara/);
    const satir = await screen.findByText('aaa ooo');
    fireEvent.click(satir);
    fireEvent.keyDown(satir, { key: 'Enter' });
    await waitFor(() => expect(degisenler.length).toBeGreaterThan(0));
    expect(String(degisenler[degisenler.length - 1].guncel[0].tarafId)).toBe('4888');
  });

  it('KOD LISTESINDE OLMAYAN kisi eklenirse hucre BOS kalmaz uyarisi (378)', () => {
    // Regresyon notu: kod listesi `aktif = 1` ile suzuluyor. Gorunum kisilerin
    //   bir bolumune aktif=0 dondugunde, aramadan secilen kisi listede
    //   bulunmadigi icin gridde ADSIZ ciziliyor ve kullanici "eklenmedi"
    //   diye okuyor. Cozum db/378: gorunum herkesi aktif=1 dondurur.
    //   Burada metanin bunu tasidigi sabitlenir.
    const alan = (meta.alanlar as { ad: string; kodlar?: Record<string, string> }[])
      .find(a => a.ad === 'tarafId');
    expect(Object.keys(alan?.kodlar ?? {}).length).toBeGreaterThan(0);
  });

  it('SEC dugmesi de ekler', async () => {
    const degisenler = ciz();
    fireEvent.click(screen.getByRole('button', { name: /Kişi Ekle/ }));
    await screen.findByPlaceholderText(/Kişi ara/);
    await screen.findByText('aaa ooo');
    fireEvent.click(screen.getByRole('button', { name: 'Seç' }));
    await waitFor(() => expect(degisenler.length).toBeGreaterThan(0));
    expect(String(degisenler[degisenler.length - 1].guncel[0].tarafId)).toBe('4888');
  });

  it('AYNI KISI ikinci kez: uyari, satir eklenmez', async () => {
    const degisenler = ciz();
    fireEvent.click(screen.getByRole('button', { name: /Kişi Ekle/ }));
    const kutu = await screen.findByPlaceholderText(/Kişi ara/);
    await screen.findByText('aaa ooo');
    fireEvent.keyDown(kutu, { key: 'Enter' });
    await waitFor(() => expect(degisenler.length).toBe(1));
    // LISTE KORUNUR (kullanici): eklemeden sonra bosalmamali - ayni listeden
    //   pes pese secim yapilabilsin ve ekran "hicbir sey olmadi" gibi
    //   gorunmesin.
    expect(document.querySelector('.lookup-liste')?.textContent).toContain('aaa ooo');
    fireEvent.keyDown(kutu, { key: 'Enter' });
    expect(await screen.findByText(/zaten ekli/)).toBeInTheDocument();
    expect(degisenler).toHaveLength(1);
  });

  it('ENTER secili satiri EKLER ve pencere ACIK KALIR', async () => {
    const degisenler = ciz();
    fireEvent.click(screen.getByRole('button', { name: /Kişi Ekle/ }));
    const kutu = await screen.findByPlaceholderText(/Kişi ara/);
    await waitFor(() => expect(liste).toHaveBeenCalled());
    await screen.findByText('aaa ooo');

    fireEvent.keyDown(kutu, { key: 'Enter' });

    await waitFor(() => expect(degisenler.length).toBeGreaterThan(0));
    const son = degisenler[degisenler.length - 1];
    expect(son.guncel).toHaveLength(1);
    expect(String(son.guncel[0].tarafId)).toBe('4888');
    // Pencere kapanmaz - sonraki ad aranabilsin.
    expect(screen.getByPlaceholderText(/Kişi ara/)).toBeInTheDocument();
  });
});
