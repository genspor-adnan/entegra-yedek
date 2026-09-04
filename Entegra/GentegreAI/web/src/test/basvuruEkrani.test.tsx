// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { BelgeKarti } from '../sayfalar/BelgeKarti';
import kaynaklar from './veri/basvuruKaynaklari.json';
import yanitlar from './veri/basvuruYaniti.json';

/**
 * BASVURU EKRANI - kartin BUTUNU cizilerek denenir.
 *
 * Kart bu oturumda uc kez bolundu (pencereler, okuma cevrimi, basvuru
 * kaynaklari, fiyatlandirma). Parcalar tek tek testli ama "hepsi birlikte
 * dogru ekrani veriyor mu" sorusu ancak kart gercekten cizilerek cevaplanir -
 * bir hook'un yanlis sirada cagrilmasi ya da bir propun kaybolmasi birim
 * testlerinden gecer, EKRANDA patlar.
 *
 * Sunucu taklit ediliyor ama VERILER GERCEK: fixture'lar calisan API'den
 * alindi (sube 1 "Merkez" = goruntuleme merkezi profili, hekimRolu 1
 * "Gönderen", 12 acik modul). Kisi adlari maskelendi.
 */

const SUBE_GORUNTULEME = {
  id: 5019, kod: 'zztest', ad: 'Test Kullanici', rolId: 1, rolAdi: 'Yonetici',
  dil: 0, yetkiSurumu: 1, subeId: 1, subeYazma: true,
  subeler: [{ id: 1, ad: 'Merkez', varsayilan: true, yazma: true }],
  // URUN MODU 2 = GenoTIP: siparis (19) ekrani BASVURU olarak cizilir.
  urunModu: 2,
  moduller: ['randevu', 'kayit_kabul', 'radyoloji', 'prim', 'stok', 'kasa'],
  // HEKIM ROLU 1 = "Gönderen" (lab/goruntuleme kurumu, 364).
  hekimRolu: 1,
};

const liste = vi.fn();
const belgeOku = vi.fn();
const belgeEkle = vi.fn();

vi.mock('../api/istemci', () => ({
  api: {
    liste: (kaynak: string, istek: unknown) => liste(kaynak, istek),
    belgeOku: (id: number) => belgeOku(id),
    // GERCEK sunucu bicimleri: ayarlar duz dizi, turler dizi olarak doner.
    ayarlar: () => Promise.resolve([
      { anahtar: 'genel.yerel_para', deger: 'TL' },
      { anahtar: 'belge.geri_gun_siniri', deger: '7' },
      { anahtar: 'basvuru.pos_aksiyon', deger: '0' },
    ]),
    kasaIslemTurleri: () => Promise.resolve([
      { kod: 19, ad: 'Satış Siparişi', grup: 'belge', yon: 0, cariZorunlu: 1 },
      { kod: 16, ad: 'Satış Fişi', grup: 'belge', yon: 1, cariZorunlu: 1 },
    ]),
    belgeDonusumler: () => Promise.resolve({ satirlar: [] }),
    dovizKur: () => Promise.resolve({ kur: 1 }),
    fiyatKampanya: () => Promise.resolve({ kampanyaId: null, ad: '', kod: '', paylasimModu: 1 }),
    fiyatKalem: () => Promise.resolve({}),
    belgeVarsayilanListe: () => Promise.resolve({ listeId: null }),
    kodListe: () => Promise.resolve({ degerler: [] }),
    aramaIsaretle: () => Promise.resolve({}),
    belgeAcikSatirlar: () => Promise.resolve({ satirlar: [] }),
    belgeEkle: (govde: unknown) => belgeEkle(govde),
  },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: SUBE_GORUNTULEME, aksiyonlar: [], kaynaklar: [], yukleniyor: false,
    yetki: () => true, aksiyonVar: () => true,
  }),
}));

const kayitlar = kaynaklar as Record<string, Record<string, unknown>[]>;

beforeEach(() => {
  vi.clearAllMocks();
  belgeEkle.mockResolvedValue({
    belge: { ...(yanitlar as Record<string, Record<string, unknown>>)['114349'], id: 999 },
    satirlar: [], dipToplam: [], izlemeNo: '',
  });
  // Kaynak adina gore GERCEK sunucu satirlari; tanimsiz kaynak bos doner.
  liste.mockImplementation((kaynak: string) =>
    Promise.resolve({ satirlar: kayitlar[kaynak] ?? [] }));
  belgeOku.mockResolvedValue({
    belge: (yanitlar as Record<string, Record<string, unknown>>)['114349'],
    satirlar: [], dipToplam: [], izlemeNo: '',
  });
});

const ciz = (p: { id?: number } = {}) =>
  render(<MemoryRouter><BelgeKarti tur={19} {...p} onKapat={() => {}} /></MemoryRouter>);

/**
 * SEKME dugmesini bulur. "Başvuru" metni ekranda IKI KEZ gecer (pencere
 * basligi + sekme), duz metin aramasi bu yuzden belirsiz - sekme seridi
 * `.kat` sinifiyla ayrilir.
 */
const sekme = async (ad: string) => {
  const hepsi = await screen.findAllByText(ad);
  const d = hepsi.find(x => x.classList.contains('kat'));
  if (!d) throw new Error(`"${ad}" sekmesi bulunamadi`);
  return d;
};

describe('yeni basvuru karti', () => {
  it('BASVURU olarak acilir: sekmeler ve hasta arama hazir', async () => {
    ciz();
    // Basvuru sekmesi yalniz GenoTIP modunda cizilir - ERP'de ayni belge
    //   normal satis siparisidir.
    expect(await sekme('Başvuru')).toBeInTheDocument();
    expect(await sekme('Ücretlendirme')).toBeInTheDocument();
    expect(await sekme('Tahsilat')).toBeInTheDocument();
    expect(await sekme('Faturalama')).toBeInTheDocument();
    // YENI basvuruda dugme "protokol ver" der - kayitli belgede "kaydet".
    expect(screen.getByText(/Başvuruyu Aç \(Protokol Ver\)/)).toBeInTheDocument();
  });

  it('GORUNTULEME kurumunda (hekimRolu 1) hekim alani "Gönderen" olur', async () => {
    ciz();
    (await sekme('Başvuru')).click();
    await waitFor(() => expect(screen.getByText('Gönderen')).toBeInTheDocument());
  });

  it('GORUNTULEME kurumunda Basvuru Turu ve Poliklinik Odasi SORULMAZ', async () => {
    ciz();
    (await sekme('Başvuru')).click();
    await waitFor(() => expect(screen.getByText('Gönderen')).toBeInTheDocument());
    // Tur her zaman "Laboratuvar / Görüntüleme" damgalanir, oda kavrami yok.
    expect(screen.queryByText('Başvuru Türü')).toBeNull();
    expect(screen.queryByText('Poliklinik Odası')).toBeNull();
    // "Başvurulan Bölüm" degil sadece "Bölüm": hasta poliklinige basvurmuyor,
    //   tetkik yaptiriyor.
    expect(screen.getByText('Bölüm')).toBeInTheDocument();
    expect(screen.queryByText('Başvurulan Bölüm')).toBeNull();

    // PROTOKOL NO sekmede YOK ama kartin BASLIK seridinde var - ayni salt
    //   okunur numarayi iki yerde gostermek sekmede bos yer harciyordu.
    const grup = screen.getByText('Başvuru Bilgileri').closest('.kagrup')!;
    expect(grup.textContent).not.toContain('Protokol No');
    expect(screen.getByText('Protokol No')).toBeInTheDocument();
  });

  it('BOLUM ve ODEYEN KURUM combolari sunucudan doldurulur', async () => {
    ciz();
    (await sekme('Başvuru')).click();
    // Odeyen kurum ZORUNLU alan - listesi bos kalirsa kayit yapilamaz.
    await waitFor(() => expect(screen.getByText('Özel (Ücretli)')).toBeInTheDocument());
    expect(liste).toHaveBeenCalledWith('kurum', expect.anything());
    expect(liste).toHaveBeenCalledWith('departman', expect.anything());
  });

  it('gonderen adaylari GONDEREN rolu (1) ile sorulur - kurum tipi kurali', async () => {
    ciz();
    await waitFor(() => expect(liste).toHaveBeenCalledWith('prim-rol-aday', expect.anything()));
    const istek = liste.mock.calls.find(c => c[0] === 'prim-rol-aday')![1] as
      { filtre: { kosullar: unknown[] } };
    expect(istek.filtre.kosullar).toContainEqual({ alan: 'rol', op: 'esit', deger: 1 });
  });

  it('protokol numara sablonu sorulur (358) - numarayi kim verir', async () => {
    ciz();
    await waitFor(() =>
      expect(liste).toHaveBeenCalledWith('numara-basvuru', expect.anything()));
  });
});

describe('kayitli basvuru karti', () => {
  it('sunucudan okunan basvuru basliga yansir (belge no · hasta · kurum)', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalledWith(114349));
    // Belge numarasi YIL ONEKLI uretildi (366): "2026-000000035" - pencere
    //   basliginda gorunur.
    await waitFor(() =>
      expect(screen.getByText('Başvuru — 2026-000000035')).toBeInTheDocument());
    // Hasta karta yansidi: arac cubugundaki "Hasta Kartını Aç" acildi
    //   (hasta secilmeden pasiftir).
    expect(screen.getByTitle('Seçili hastanın kartını aç')).toBeEnabled();
  });

  it('hasta seridi ODEYEN KURUM ile cizilir (Sigorta degil)', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(screen.getByText('Ödeyen Kurum')).toBeInTheDocument());
    expect(screen.queryByText('Sigorta')).toBeNull();
  });

  it('ACIK BORC seridi cizilir - ucret/tahsilat farki hasta bandinda', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(screen.getByText('Açık Borç')).toBeInTheDocument());
  });
});

describe('tamamlanma seridi (370)', () => {
  // Kart MODAL olarak `document.body`ye portallanir (Modal.tsx) - sorgular
  //   render kabindan degil BELGEDEN yapilmali.
  const asamalar = () => [...document.querySelectorAll('.basvuru-asama .asama')];

  it('yeni basvuruda butun asamalar GRI - %0', async () => {
    ciz();
    await waitFor(() => expect(document.querySelector('.basvuru-asama')).toBeTruthy());
    expect(asamalar().map(a => a.textContent))
      .toEqual(['Başvuru', 'Ücretlendirme', 'Tahsilat', 'Faturalama']);
    expect(document.querySelectorAll('.basvuru-asama .asama.ok')).toHaveLength(0);
    expect(document.querySelector('.asama-yuzde b')?.textContent).toBe('%0');
  });

  it('KAYITLI basvuruda "Başvuru" asamasi kendi rengiyle dolar', async () => {
    ciz({ id: 114349 });
    await waitFor(() =>
      expect(document.querySelector('.basvuru-asama .asama.ok')).toBeTruthy());
    const ilk = asamalar()[0];
    expect(ilk.className).toContain('kirmizi');
    expect(ilk.className).toContain('ok');
  });

  it('ODEYEN KURUM ozel (tur 1) oldugu icin PROVIZYON asamasi cizilmez', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(document.querySelector('.basvuru-asama')).toBeTruthy());
    expect(asamalar().map(a => a.textContent)).not.toContain('Provizyon');
  });
});

describe('acilista aktif sekme', () => {
  // Aktif sekme `.kat.on` sinifiyla isaretlenir (BelgeBaslik). Sekme metni
  //   satir sayaci rozetini de tasiyabilir ("Ücretlendirme0") - basi yeter.
  const aktif = () => document.querySelector('.kat.on')?.textContent ?? '';

  it('YENI basvuruda "Başvuru" sekmesi acik gelir - once hasta/kurum girilir', async () => {
    ciz();
    await waitFor(() => expect(aktif()).toMatch(/^Başvuru/));
  });

  it('KAYITLI basvuruda "Ücretlendirme" acik gelir - memur islem eklemeye doner', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(aktif()).toMatch(/^Ücretlendirme/));
  });
});

describe('ucret eklemenin ilk kapisi', () => {
  const ucretEkle = async () => {
    (await sekme('Ücretlendirme')).click();
    const dugme = await waitFor(() => {
      const d = [...document.querySelectorAll('button')]
        .find(b => b.getAttribute('title') === 'Satır ekle');
      if (!d) throw new Error('"Satır ekle" dugmesi yok');
      return d;
    });
    dugme.click();
  };

  // NOT: dolu ve GECERLI bir yeni basvurunun kaydedilmesi burada
  //   surulemiyor (hasta/bolum/gonderen secimi dort ayri arama penceresi
  //   ister); kaydetme kurallari `basvuruDogrulama.test.ts`te tek tek
  //   deneniyor. Burada denenen sey KAPININ kendisi: gecersiz kartta arama
  //   ACILMIYOR ve eksik alanin sekmesine donuluyor mu.
  it('EKSIK kartta kayit denenmez, arama ACILMAZ ve Başvuru sekmesine donulur', async () => {
    ciz();                                   // hasta secilmemis yeni kart
    await ucretEkle();
    await waitFor(() =>
      expect(document.querySelector('.kat.on')?.textContent).toMatch(/^Başvuru/));
    expect(belgeEkle).not.toHaveBeenCalled();
    // Kalem protokolsuz belgeye yazilmasin: stok arama penceresi acilmamali.
    expect(document.querySelector('[data-testid="stok"]')).toBeNull();
  });

  it('ODEYEN KURUM secilemiyorsa da kapi kapali kalir', async () => {
    // Kurum listesi bos donerse zorunlu alan doldurulamaz.
    liste.mockImplementation((kaynak: string) =>
      Promise.resolve({ satirlar: kaynak === 'kurum' ? [] : (kayitlar[kaynak] ?? []) }));
    ciz();
    await ucretEkle();
    await waitFor(() =>
      expect(document.querySelector('.kat.on')?.textContent).toMatch(/^Başvuru/));
    expect(belgeEkle).not.toHaveBeenCalled();
  });

  it('KAYITLI basvuruda dogrudan arama acilir - tekrar kaydedilmez', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    await ucretEkle();
    expect(belgeEkle).not.toHaveBeenCalled();
  });
});

describe('hizli tahsilat dugmeleri (nakit / banka / pos)', () => {
  const tahsilatDugmesi = async (ad: string) => {
    (await sekme('Tahsilat')).click();
    return waitFor(() => {
      const d = [...document.querySelectorAll('button')]
        .find(b => (b.textContent ?? '').includes(ad));
      if (!d) throw new Error(`"${ad}" dugmesi yok`);
      return d as HTMLButtonElement;
    });
  };

  // Kullanici: "ücretleme yaptım tahsilat sekmede nakit/banka/pos
  //   basamıyorum" - dugmeler kaydedilmemis belgede PASIFTI. Artik kart
  //   kendisi kaydediyor, dugme hic pasif olmuyor.
  it('KAYDEDILMEMIS belgede de BASILABILIR - kart once kaydeder', async () => {
    ciz();
    for (const ad of ['Nakit', 'Banka', 'POS'])
      expect(await tahsilatDugmesi(ad)).not.toBeDisabled();
  });

  it('kaydedilmemis belgede ipucu "belge önce kaydedilir" der', async () => {
    ciz();
    expect((await tahsilatDugmesi('Banka')).title).toContain('belge önce kaydedilir');
  });

  it('KAYITLI belgede o ek uyari cikmaz', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    expect((await tahsilatDugmesi('Banka')).title).not.toContain('önce kaydedilir');
  });

  it('EKSIK kartta banka basilinca hesap secimi ACILMAZ, Başvuru sekmesine donulur', async () => {
    ciz();
    (await tahsilatDugmesi('Banka')).click();
    await waitFor(() =>
      expect(document.querySelector('.kat.on')?.textContent).toMatch(/^Başvuru/));
    expect(belgeEkle).not.toHaveBeenCalled();
  });
});
