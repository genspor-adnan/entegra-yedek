// @vitest-environment jsdom
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter, Route, Routes, useNavigate } from 'react-router-dom';
import { AiRehberPaneli } from '../bilesenler/AiRehberPaneli';
import { ApiHatasi } from '../api/sozlesme';
import { hataIziKaydet, sonHataIzi } from '../api/hataIzi';

/**
 * YAPAY ZEKÂYA SOR — BAĞLAMSAL YARDIM PANELİ (447 · 871).
 *
 * Panel <b>rehberdir, operatör değildir</b>: yalnız sunucunun verdiğini çizer.
 * Testler şunu tutar: ekran bağlamı YALNIZ kimlik olarak gider ve sunucunun
 * doğruladığı haliyle gösterilir; rota değişince bağlam sıfırlanır; sunucu
 * bir ekran önermediyse panel düğme uydurmaz; yetkisiz / bulunamadı / ağ
 * hataları ayrı metinle görünür; güven açıkça yazılır.
 */
const aiRehber = vi.fn();
const aiOneri = vi.fn();
const aiOneriGizle = vi.fn();
const aiEkranBaglami = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  aiRehber: (g: unknown) => aiRehber(g),
  aiOneri: (k: string, i: number) => aiOneri(k, i),
  aiOneriGizle: (k: string, g: boolean) => aiOneriGizle(k, g),
  aiEkranBaglami: (i: unknown) => aiEkranBaglami(i),
} }));

const ekranOzeti = (ek: Record<string, unknown> = {}) => ({
  bulundu: true, yetkili: true, kaynak: 'hasta', rota: '/hasta', baslik: 'Hastalar',
  yol: 'Hasta › Hastalar', sekme: null, kayitVar: false, hataKodu: null, ...ek,
});

beforeEach(() => {
  aiRehber.mockClear();
  aiOneri.mockClear().mockResolvedValue({ kaynak: 'cari', kayitId: 0, oneriler: [],
                                          engel: 0, uyari: 0, bilgi: 0 });
  aiOneriGizle.mockClear().mockResolvedValue({ mesaj: '' });
  aiEkranBaglami.mockClear().mockResolvedValue({
    ekran: ekranOzeti(), onerilenSorular: ['Bu ekranda ne yapabilirim?', 'Yeni hasta kaydı nasıl açılır?'],
    aksiyonlar: [{ kod: 'hasta.yeni', ad: '＋ Yeni', ekran: 'hasta-liste' }],
  });
});

const yanit = (ek: Record<string, unknown> = {}) => ({
  cevap: '**Yeni hasta kaydı açma** — 2 adım:',
  adimlar: [
    { no: 1, metin: 'Kayıt Kabul › Hasta Listesi ekranını açın.', ekran: 'hasta',
      rota: '/hasta' },
    { no: 2, metin: 'Yeni düğmesine basın.', aksiyon: 'hasta.yeni' },
  ],
  onerilenEkranlar: [{ kaynak: 'hasta', ad: 'Hastalar', rota: '/hasta',
                       yol: 'Hasta › Hastalar', menuGrup: 'Hasta' }],
  onerilenAksiyonlar: [{ kod: 'hasta.yeni', ad: '＋ Yeni', ekran: 'hasta-liste' }],
  guvenSkoru: 0.9, uyarilar: [], konuKod: 'hasta-kayit', kaynakTuru: 1,
  kontorBakiye: 0, kaynaklar: [], ekran: ekranOzeti(), ...ek,
});

const ac = (rota = '/') => {
  render(<MemoryRouter initialEntries={[rota]}><AiRehberPaneli urunModu={2} /></MemoryRouter>);
  fireEvent.click(screen.getByTitle(/Yapay Zekâya Sor/i));
};

describe('AiRehberPaneli - bağlam', () => {
  it('soruyu YALNIZ KİMLİK bağlamıyla gönderir (rota, kaynak, kayıt no, dil)', async () => {
    aiRehber.mockResolvedValue(yanit());
    ac('/hasta/5057');
    await waitFor(() => expect(aiEkranBaglami).toHaveBeenCalled());
    fireEvent.change(screen.getByPlaceholderText(/Nasıl yapılır/i),
                     { target: { value: 'hasta kaydı' } });
    fireEvent.click(screen.getByText('Sor'));
    expect(await screen.findByText(/Kayıt Kabul/)).toBeTruthy();
    expect(aiRehber).toHaveBeenCalledWith(expect.objectContaining({
      kullaniciMesaji: 'hasta kaydı', aktifMod: 2, aktifSayfa: '/hasta/5057',
      baglam: expect.objectContaining({ rota: '/hasta/5057', kaynak: 'hasta', kayitId: 5057, dil: 'tr' }),
    }));
    // Gönderilen bağlamda DOM / satır verisi / ad gibi anahtar yok.
    const gonderilen = aiRehber.mock.calls[0][0].baglam as Record<string, unknown>;
    const izinli = ['dil', 'hataKodu', 'kaynak', 'kayitId', 'rota', 'sekme'];
    expect(Object.keys(gonderilen).every(k => izinli.includes(k))).toBe(true);
  });

  it('"şu ekran hakkında" satırı SUNUCUNUN doğruladığı ekranla çizilir', async () => {
    ac('/hasta');
    expect(await screen.findByText(/Şu ekran hakkında soruyorsunuz/)).toBeTruthy();
    expect(screen.getByText('Hasta › Hastalar')).toBeTruthy();
    // Önerilen sorular sunucudan.
    expect(screen.getByText('Yeni hasta kaydı nasıl açılır?')).toBeTruthy();
  });

  it('yetkisiz ekranda uyarı görünür, kayıt bağlamı gösterilmez', async () => {
    aiEkranBaglami.mockResolvedValue({
      ekran: ekranOzeti({ yetkili: false, kayitVar: false }),
      onerilenSorular: ['Bu ekran için hangi yetki gerekiyor?'], aksiyonlar: [],
    });
    ac('/hasta/5057');
    expect(await screen.findByText(/bu ekrana yetkiniz yok/)).toBeTruthy();
    expect(screen.queryByText(/açık kayıt/)).toBeNull();
  });

  it('son hata kodu bağlama girer ve satırda görünür', async () => {
    aiEkranBaglami.mockResolvedValue({
      ekran: ekranOzeti({ hataKodu: 'KARANTINA' }), onerilenSorular: ['Bu hata ne demek?'], aksiyonlar: [],
    });
    // Hata, ekran açıkken (panel kapalıyken) oluşur; panel açılınca bağlama girer.
    render(<MemoryRouter initialEntries={['/steril-pano']}><AiRehberPaneli urunModu={2} /></MemoryRouter>);
    hataIziKaydet('IS_KURALI', 'KARANTINA');
    expect(sonHataIzi()?.kod).toBe('KARANTINA');
    fireEvent.click(screen.getByTitle(/Yapay Zekâya Sor/i));
    expect(await screen.findByText(/son hata/)).toBeTruthy();
    expect(aiEkranBaglami).toHaveBeenCalledWith(expect.objectContaining({ hataKodu: 'KARANTINA' }));
  });

  it('ROTA DEĞİŞİNCE cevap ve bağlam sıfırlanır (önceki hasta taşınmaz)', async () => {
    aiRehber.mockResolvedValue(yanit());
    function Gecis() {
      const git = useNavigate();
      return <button onClick={() => git('/randevu')}>git</button>;
    }
    render(
      <MemoryRouter initialEntries={['/hasta/5057']}>
        <Routes><Route path="*" element={<><Gecis /><AiRehberPaneli urunModu={2} /></>} /></Routes>
      </MemoryRouter>);
    fireEvent.click(screen.getByTitle(/Yapay Zekâya Sor/i));
    fireEvent.change(screen.getByPlaceholderText(/Nasıl yapılır/i), { target: { value: 'hasta kaydı' } });
    fireEvent.click(screen.getByText('Sor'));
    expect(await screen.findByText(/Kayıt Kabul/)).toBeTruthy();

    hataIziKaydet('YASAK');
    fireEvent.click(screen.getByText('git'));
    await waitFor(() => expect(screen.queryByText(/Kayıt Kabul/)).toBeNull());
    expect(sonHataIzi()).toBeNull();
    // Yeni ekranın bağlamı yeniden sorulur; eski kayıt numarası gitmez.
    await waitFor(() => {
      const son = aiEkranBaglami.mock.calls.at(-1)?.[0] as Record<string, unknown>;
      expect(son.rota).toBe('/randevu');
      expect(son.kayitId).toBeUndefined();
      expect(son.hataKodu).toBeUndefined();
    });
  });
});

describe('AiRehberPaneli - cevap', () => {
  it('ekran düğmesi YALNIZ sunucu rota verdiyse çizilir; aksiyon rozeti adıyla', async () => {
    aiRehber.mockResolvedValue(yanit());
    ac();
    fireEvent.click(await screen.findByText(/Yeni hasta kaydı nasıl/));
    expect(await screen.findByText(/Kayıt Kabul/)).toBeTruthy();
    expect(screen.getAllByText('Ekranı aç')).toHaveLength(1);   // 2. adımda rota yok
    expect(screen.getByTitle('Bu ekrandaki düğme').textContent).toBe('＋ Yeni');
  });

  it('düşük güvende rozet UYARI rengine döner; kaynak satırı görünür', async () => {
    aiRehber.mockResolvedValue(yanit({ guvenSkoru: 0.42, kaynakTuru: 8,
      kaynaklar: [{ id: 'hasta-arama-kayit#adim-adim', baslik: 'Hasta arama ve kayıt › Adım adım', belge: 'hasta-arama-kayit' }] }));
    ac();
    fireEvent.click(await screen.findByText(/Yeni hasta kaydı nasıl/));
    const rozet = await screen.findByText('güven %42');
    expect(rozet.className).toContain('uyari');
    expect(screen.getByText(/Hasta arama ve kayıt › Adım adım/)).toBeTruthy();
    expect(screen.getByText('yardım belgesi')).toBeTruthy();
  });

  it('uyarı ve eksik bilgi sorusu gösterilir', async () => {
    aiRehber.mockResolvedValue(yanit({
      uyarilar: ['"lab" modülü bu kurulumda kapalı görünüyor.'],
      eksikBilgiSorusu: 'Hangi modülde çalışıyorsunuz?',
    }));
    ac();
    fireEvent.click(await screen.findByText(/Yeni hasta kaydı nasıl/));
    expect(await screen.findByText(/modülü bu kurulumda kapalı/)).toBeTruthy();
    expect(screen.getByText(/Hangi modülde çalışıyorsunuz/)).toBeTruthy();
  });

  it('403 yetkisiz, 404 bulunamadı ve ağ hatası AYRI metinle görünür', async () => {
    ac();
    const sor = async (metin: string) => {
      fireEvent.change(screen.getByPlaceholderText(/Nasıl yapılır/i), { target: { value: metin } });
      fireEvent.click(screen.getByText('Sor'));
    };
    aiRehber.mockRejectedValueOnce(new ApiHatasi(403, { kod: 'YASAK', mesaj: 'x', izlemeNo: '' }));
    await sor('a');
    expect(await screen.findByText(/yetkiniz yok/)).toBeTruthy();

    aiRehber.mockRejectedValueOnce(new ApiHatasi(404, { kod: 'BULUNAMADI', mesaj: 'x', izlemeNo: '' }));
    await sor('b');
    expect(await screen.findByText(/bulunamadı/)).toBeTruthy();

    aiRehber.mockRejectedValueOnce(new TypeError('Failed to fetch'));
    await sor('c');
    expect(await screen.findByText(/Sunucuya ulaşılamadı/)).toBeTruthy();
    expect(screen.getByText('Yeniden dene')).toBeTruthy();
  });

  it('Esc paneli kapatır (klavye erişimi)', async () => {
    ac();
    const kutu = await screen.findByPlaceholderText(/Nasıl yapılır/i);
    fireEvent.keyDown(kutu, { key: 'Escape' });
    expect(screen.getByTitle(/Yapay Zekâya Sor/i)).toBeTruthy();   // düğmeye döndü
  });
});

/**
 * FAZ 3 — KONTROLLÜ ÖNERİ (449). Öneriler sunucudan gelir; panel kural
 * bilmez, kayıt okumaz, hiçbir şeyi düzeltmez.
 */
const oneriYaniti = {
  kaynak: 'cari', kayitId: 4868, engel: 1, uyari: 0, bilgi: 1,
  oneriler: [
    { kod: 'cari.vkno-yok', seviye: 3, baslik: 'VKN / TCKN boş',
      aciklama: 'GİB numarasız belgeyi reddeder.', alan: 'vkno', ekran: '/cari',
      rota: '/cari' },
    { kod: 'cari.eposta-yok', seviye: 1, baslik: 'E-posta adresi yok',
      aciklama: 'e-Arşiv faturası iletilemez.', alan: 'eposta', ekran: '/cari',
      rota: '/cari' },
  ],
};

const kartaAc = (rota = '/cari/4868') => {
  render(<MemoryRouter initialEntries={[rota]}><AiRehberPaneli urunModu={1} /></MemoryRouter>);
  fireEvent.click(screen.getByTitle(/Yapay Zekâya Sor/i));
};

describe('AiRehberPaneli - kontrollü öneri', () => {
  it('kart rotasında kaydın eksikleri SORULMADAN gösterilir', async () => {
    aiOneri.mockResolvedValue(oneriYaniti);
    kartaAc();
    expect(await screen.findByText(/VKN \/ TCKN boş/)).toBeTruthy();
    expect(screen.getByText(/E-posta adresi yok/)).toBeTruthy();
    expect(aiOneri).toHaveBeenCalledWith('cari', 4868);
  });

  it('LİSTE rotasında öneri istenmez', () => {
    kartaAc('/cari');
    expect(aiOneri).not.toHaveBeenCalled();
  });

  it('seviye SINIFA yansır (engel/uyarı/bilgi ayrılsın)', async () => {
    aiOneri.mockResolvedValue(oneriYaniti);
    kartaAc();
    const engel = (await screen.findByText(/VKN \/ TCKN boş/)).closest('.rehber-oneri');
    const bilgi = screen.getByText(/E-posta adresi yok/).closest('.rehber-oneri');
    expect(engel?.className).toContain('s3');
    expect(bilgi?.className).toContain('s1');
  });

  it('"bir daha gösterme" öneriyi kaldırır ve sunucuya bildirir', async () => {
    aiOneri.mockResolvedValue(oneriYaniti);
    kartaAc();
    await screen.findByText(/VKN \/ TCKN boş/);
    fireEvent.click(screen.getAllByTitle(/bir daha gösterme/i)[0]);
    expect(screen.queryByText(/VKN \/ TCKN boş/)).toBeNull();
    expect(aiOneriGizle).toHaveBeenCalledWith('cari.vkno-yok', true);
  });
});
