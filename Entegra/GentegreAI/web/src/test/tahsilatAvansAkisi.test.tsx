// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render, screen } from '@testing-library/react';

/**
 * TAHSİLAT SEKMESİNİN AVANS EYLEMLERİ (783/784).
 *
 * GERÇEK VAKA (başvuru P-000140): memur ücret satırını girmiş ama henüz
 * kaydetmemişken "Avans Kullan" dedi. Mahsup bittiğinde kart satırları
 * SUNUCUDAN tazeliyor - gridde duran kaydedilmemiş ücret o anda silindi
 * (kullanıcı: *"ücret girdim, avans kullan dediğim zaman girdiğim ücreti
 * sildi"*). Denetim kaydı da bunu doğruluyordu: belgede tek "ekle" logu vardı,
 * ücret hiç kaydedilmemişti.
 *
 * Kural: avans eylemleri (kullan / al / iade) önce KAYIT KAPISINDAN geçer -
 * tahsilat araçlarıyla (Nakit/POS) aynı desen. Kapı geçilmezse eylem yapılmaz.
 */
const paraSor = vi.fn();
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: vi.fn(),
  get paraSor() { return paraSor },
  onay: vi.fn(async () => true),
  metinSor: vi.fn(),
}));

const { TahsilatSekmesi } = await import('../bilesenler/belge/TahsilatSekmesi');

const avansDurumu = (toplam: number, mahsupEt = vi.fn()) => ({
  toplam, adet: 1, calisiyor: false, hata: '',
  satirlar: [{ kasaIslemId: 5, islemTarihi: '2026-09-16', kalan: toplam }],
  tazele: vi.fn(), mahsupEt,
}) as unknown as Parameters<typeof TahsilatSekmesi>[0]['avans'];

const ciz = (y: Partial<Parameters<typeof TahsilatSekmesi>[0]> = {}) => render(
  <TahsilatSekmesi
    sonuc={{ belge: { tarafId: 42, genelToplam: 500 } } as never}
    tahsilatlar={[]} kayitliId={7509} alisMi={false}
    tahsilatAc={async () => {}} secili={[]} setSecili={() => {}}
    tahsilatAcKart={() => {}} tahsilatSil={async () => {}}
    basvuruMu avans={avansDurumu(1000)} {...y} />,
);

/** "⋯" menüsünü açıp içindeki bir öğeye basar. */
async function menuden(ad: string) {
  const ucNokta = [...document.querySelectorAll('button')]
    .find(b => b.textContent?.trim() === '⋯')!;
  await act(async () => { ucNokta.click() });
  const oge = [...document.querySelectorAll('.dugme-menu-liste button')]
    .find(b => (b.textContent ?? '').includes(ad)) as HTMLButtonElement;
  await act(async () => { oge.click() });
}

describe('avans eylemleri kayıt kapısından geçer (784)', () => {
  beforeEach(() => {
    paraSor.mockReset();
    paraSor.mockResolvedValue({ tutar: 100, doviz: 'TL', kur: 1, yerelTutar: 100 });
  });

  it('AVANS KULLAN önce kaydeder, sonra mahsup eder', async () => {
    const mahsupEt = vi.fn(async () => ({ dagitilan: 100, islemSayisi: 1 }));
    const sira: string[] = [];
    const kayitSart = vi.fn(async () => { sira.push('kayit'); return true });
    mahsupEt.mockImplementation(async () => { sira.push('mahsup');
      return { dagitilan: 100, islemSayisi: 1 } });

    ciz({ avans: avansDurumu(1000, mahsupEt), kayitSart });
    await menuden('Avans Kullan');

    expect(kayitSart).toHaveBeenCalled();
    expect(mahsupEt).toHaveBeenCalledWith(7509, 100);
    expect(sira).toEqual(['kayit', 'mahsup']);   // önce kayıt, sonra mahsup
  });

  it('kayıt GEÇMEZSE mahsup hiç denenmez - ücret ekranda kalır', async () => {
    const mahsupEt = vi.fn();
    const kayitSart = vi.fn(async () => false);

    ciz({ avans: avansDurumu(1000, mahsupEt), kayitSart });
    await menuden('Avans Kullan');

    expect(mahsupEt).not.toHaveBeenCalled();
    // Tutar da sorulmaz: kaydedilemeyen belgede mahsup zaten yapılamaz.
    expect(paraSor).not.toHaveBeenCalled();
  });

  it('TUTAR sorulur ve iptal edilirse mahsup yapılmaz (783)', async () => {
    const mahsupEt = vi.fn();
    paraSor.mockResolvedValue(null);

    ciz({ avans: avansDurumu(1000, mahsupEt), kayitSart: async () => true });
    await menuden('Avans Kullan');

    expect(paraSor).toHaveBeenCalled();
    expect(mahsupEt).not.toHaveBeenCalled();
  });

  it('AVANS AL da kayıt kapısından geçer', async () => {
    const avansAl = vi.fn();
    const kayitSart = vi.fn(async () => true);
    ciz({ avansAl, kayitSart });

    const dugme = [...document.querySelectorAll('button')]
      .find(b => (b.textContent ?? '').includes('Avans Al'))!;
    await act(async () => { dugme.click() });
    const nakit = [...document.querySelectorAll('.dugme-menu-liste button')]
      .find(b => (b.textContent ?? '').includes('Nakit')) as HTMLButtonElement;
    await act(async () => { nakit.click() });

    expect(kayitSart).toHaveBeenCalled();
    expect(avansAl).toHaveBeenCalledWith(21);
  });

  it('AVANS İADE de kayıt kapısından geçer', async () => {
    const avansIadeAc = vi.fn();
    const kayitSart = vi.fn(async () => true);
    ciz({ avansIadeAc, kayitSart });

    const dugme = [...document.querySelectorAll('button')]
      .find(b => (b.textContent ?? '').includes('Avans İade'))!;
    await act(async () => { dugme.click() });
    const ilk = document.querySelector('.dugme-menu-liste button') as HTMLButtonElement;
    await act(async () => { ilk.click() });

    expect(kayitSart).toHaveBeenCalled();
    expect(avansIadeAc).toHaveBeenCalledWith(5, 1000);
  });

  it('avans YOKSA "Avans İade" çizilmez, "Avans Al" durur', () => {
    // `avansAl` verilmezse dugme hic cizilmez (cagiran onu baglamamis
    //   demektir); burada baglanmis bir kart taklit ediliyor.
    ciz({ avans: avansDurumu(0), avansAl: vi.fn(), avansIadeAc: vi.fn() });
    expect(screen.queryByText(/Avans İade/)).toBeNull();
    expect(screen.getByText(/Avans Al/)).toBeTruthy();
  });
});
