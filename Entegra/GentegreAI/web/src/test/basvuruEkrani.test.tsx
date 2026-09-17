// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, waitFor, act, fireEvent } from '@testing-library/react';
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
/**
 * BASVURU COMBOLARI TEK UCTAN (kullanici: banko rolunde odeyen kurum listesi
 * gelmiyordu): kurum/bolum/depo artik kart kaynagindan degil
 * `/api/belge/basvuru-kaynaklari`dan gelir - combo doldurmak kart yetkisi
 * degil, `belge` gor yetkisidir. Fixture AYNI veriyi kullanir.
 */
const basvuruKaynaklari = vi.fn();
const belgeOku = vi.fn();
const belgeEkle = vi.fn();
/** Odeyen kurumun sozlesme fiyat listesi (495) - kurum basina ayri liste. */
const varsayilanListe = vi.fn(
  (_tur: number, _tarafId: number, kurumId?: number | null) =>
    Promise.resolve({ listeId: kurumId === 4987 ? 9 : null, ad: '', yon: 2, kdvDahil: 0 }));

vi.mock('../api/istemci', () => ({
  api: {
    liste: (kaynak: string, istek: unknown) => liste(kaynak, istek),
    basvuruKaynaklari: () => basvuruKaynaklari(),
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
    belgeVarsayilanListe: (tur: number, tarafId: number, kurumId?: number | null) =>
      varsayilanListe(tur, tarafId, kurumId),
    kodListe: () => Promise.resolve({ degerler: [] }),
    aramaIsaretle: () => Promise.resolve({}),
    belgeAcikSatirlar: () => Promise.resolve({ satirlar: [] }),
    belgeEkle: (govde: unknown) => belgeEkle(govde),
    // Iskonto onay talepleri (662) - ucret sekmesi rozeti icin okunur.
    iskontoTalepleri: () => Promise.resolve([]),
  },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: SUBE_GORUNTULEME, aksiyonlar: [], kaynaklar: [], yukleniyor: false,
    yetki: () => true, aksiyonVar: () => true, aksiyonDegeri: () => 100,
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
  basvuruKaynaklari.mockImplementation(() => Promise.resolve({
    kurumlar: (kayitlar.kurum ?? []).map(k => ({
      id: Number(k.id), ad: String(k.unvan ?? ''), tur: Number(k.tur ?? 0) })),
    bolumler: (kayitlar.departman ?? []).map(b => ({
      id: Number(b.id), ad: String(b.ad ?? '') })),
    depolar: (kayitlar.depo ?? []).map(d => ({
      id: Number(d.id), ad: String(d.ad ?? '') })),
    // Fiyat listesi combosu da bu uctan (banko rolunde `fiyat_listesi` gor
    //   yetkisi yok): fixture'daki AYNI kayitlar.
    fiyatListeleri: (kayitlar['fiyat-listesi'] ?? []).map(l => ({
      id: Number(l.id), ad: String(l.ad ?? ''),
      yon: Number(l.yonKodu ?? l.yon ?? 2),
      tarifeTipi: Number(l.tarifeTipi ?? 0) })),
  }));
  belgeOku.mockResolvedValue({
    belge: (yanitlar as Record<string, Record<string, unknown>>)['114349'],
    satirlar: [], dipToplam: [], izlemeNo: '',
  });
});

const ciz = (p: { id?: number; tarafId?: number; tarafUnvan?: string } = {}) =>
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
    expect(await sekme('Belgeye Dönüşüm')).toBeInTheDocument();
    // YENI basvuruda dugme "protokol ver" der - kayitli belgede "kaydet".
    expect(screen.getByText(/Başvuruyu Aç \(Protokol Ver\)/)).toBeInTheDocument();
  });

  it('HASTA ON-DOLGU: taraf hazir gelir, arama penceresi ACILMAZ', async () => {
    // Hasta kartindaki "＋ Yeni Başvuru" bu yoldan acilir: hasta zaten belli,
    //   kullaniciya bir kez daha "hastayi ara" dedirtmek gereksiz adimdi.
    ciz({ tarafId: 5023, tarafUnvan: 'TEST ÖZEL HASTA' });
    expect(await screen.findByText(/Başvuruyu Aç \(Protokol Ver\)/)).toBeInTheDocument();
    expect(screen.queryByPlaceholderText(/Hastayı isim\/tel ile ara/)).toBeNull();
  });

  it('ON-DOLGU YOKSA arama penceresi acilir (eski davranis korunur)', async () => {
    ciz();
    expect(await screen.findByPlaceholderText(/Hastayı isim\/tel ile ara/))
      .toBeInTheDocument();
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

    // PROTOKOL NO SEKMEDE YOK: aynı salt okunur numarayı iki yerde göstermek
    //   sekmede boş yer harcıyordu; numara kartın BAŞLIK şeridinde durur.
    //
    //   781'e kadar hasta arama satırında da boş bir "Protokol No" kutusu
    //   vardı ("(kaydedince atanacak)"); kullanıcı isteğiyle o satırın tamamı
    //   kaldırıldı - yeni başvuruda protokol henüz YOKTUR, boş bir kutu
    //   göstermek numaranın girilebileceğini ima ediyordu.
    const grup = screen.getByText('Başvuru Bilgileri').closest('.kagrup')!;
    expect(grup.textContent).not.toContain('Protokol No');
    // HASTA ARAMA SATIRI KALDIRILDI (781): kimlik no, hasta no, ad soyad,
    //   protokol, "Ara" ve "Yeni Hasta Kaydı" artık çizilmiyor.
    expect(document.querySelector('.hasta-arama')).toBeNull();
    expect(screen.queryByText('Yeni Hasta Kaydı')).toBeNull();
    expect(screen.queryByText('Kimlik No')).toBeNull();
  });

  it('BOLUM ve ODEYEN KURUM combolari sunucudan doldurulur', async () => {
    ciz();
    (await sekme('Başvuru')).click();
    // Odeyen kurum ZORUNLU alan - listesi bos kalirsa kayit yapilamaz.
    await waitFor(() => expect(screen.getByText('Özel (Ücretli)')).toBeInTheDocument());
    expect(basvuruKaynaklari).toHaveBeenCalled();
  });

  /**
   * 578: hekim listesi artik PRIM ROLUNDEN bagimsiz. Kaynak `basvuru-hekim`
   * gorunumudur ve kurum profiline gore DIS hekimleri ya da randevu
   * verilebilir personeli dondurur - karar SUNUCUDA. Ekranin sordugu tek
   * kosul "aktif" (ve bolum secilmisse bolum).
   */
  it('hekim adaylari basvuru-hekim kaynagindan, prim rolu sorulmadan gelir', async () => {
    ciz();
    await waitFor(() => expect(liste).toHaveBeenCalledWith('basvuru-hekim', expect.anything()));
    const istek = liste.mock.calls.find(c => c[0] === 'basvuru-hekim')![1] as
      { filtre: { kosullar: { alan: string }[] } };
    expect(istek.filtre.kosullar).toContainEqual({ alan: 'durum', op: 'esit', deger: 1 });
    expect(istek.filtre.kosullar.some(k => k.alan === 'rol')).toBe(false);
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
    // Baslikta KAYIT ID'si ve BELGE NO birlikte durur (kullanici): belge no
    //   is numarasidir ve seriye/yila gore tekrar edebilir; kayit izi
    //   surerken aranan sey id'dir.
    await waitFor(() =>
      expect(screen.getByText('Başvuru #114349 — 2026-000000035')).toBeInTheDocument());
    // Hasta karta yansidi: arac cubugundaki "Hasta Kartını Aç" acildi
    //   (hasta secilmeden pasiftir).
    expect(screen.getByTitle('Seçili hastanın kartını aç')).toBeEnabled();
  });

  it('hasta seridi ODEYEN KURUM ile cizilir (Sigorta degil)', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(screen.getByText('Ödeyen Kurum')).toBeInTheDocument());
    expect(screen.queryByText('Sigorta')).toBeNull();
  });

  it('ACIK TAHSILAT seridi cizilir - ucret/tahsilat farki hasta bandinda', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(screen.getByText('Açık Tahsilat')).toBeInTheDocument());
  });

  /**
   * 495 (kullanici: "ödeyen kurum seçilince fiyat listesi otomatik gelsin"):
   * kurum secilince SOZLESMESINDEKI liste sunucudan cozulur ve "Fiyat Listesi"
   * kutusuna yazilir - ucret eklerken fiyatin nereden geldigi ekranda gorunur.
   */
  it('odeyen kurum secilince sozlesme fiyat listesi gelir', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(screen.getByText('Ödeyen Kurum')).toBeInTheDocument());

    // Kurum kutusu Basvuru sekmesinde; secenekler kaynak fixture'undan gelir.
    const kutular = () => screen.getAllByRole('combobox') as HTMLSelectElement[];
    await act(async () => { (await sekme('Başvuru')).click() });
    await waitFor(() => expect(kutular().some(x =>
      [...x.options].some(o => o.text.includes('Sigorta')))).toBe(true));
    const kurumKutusu = kutular().find(x =>
      [...x.options].some(o => o.text.includes('Sigorta')))!;
    await act(async () => {
      fireEvent.change(kurumKutusu, { target: { value: '4987' } });
    });

    await waitFor(() => expect(varsayilanListe)
      .toHaveBeenCalledWith(19, expect.any(Number), 4987));

    // Ucretlendirme sekmesindeki kutu da o listeyi gosterir.
    await act(async () => { (await sekme('Ücretlendirme')).click() });
    await waitFor(() => {
      const listeKutusu = screen.getAllByRole('combobox')
        .find(x => [...x.querySelectorAll('option')]
          .some(o => o.textContent === 'TTB2018'))!;
      expect((listeKutusu as HTMLSelectElement).value).toBe('9');
    });
  });

  // 495: "belge kesilmedi" rozeti yerine DONUSMEYEN TUTAR yazar.
  it('ACIK BELGE hucresi cizilir, kapanma rozeti yoktur', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(screen.getByText('Açık Belge')).toBeInTheDocument());
    expect(screen.queryByText('Faturalanmadı')).toBeNull();
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
      .toEqual(['Başvuru', 'Ücretlendirme', 'Tahsilat', 'Belge Kesimi']);
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
    basvuruKaynaklari.mockResolvedValue({ kurumlar: [], bolumler: [], depolar: [],
                                          fiyatListeleri: [] });
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
  /** Cubuktaki dugme; Banka menude oldugu icin once "⋯" acilir. */
  const tahsilatDugmesi = async (ad: string) => {
    (await sekme('Tahsilat')).click();
    if (ad === 'Banka') {
      const ucNokta = await waitFor(() => {
        const d = [...document.querySelectorAll('.katoolbar button')]
          .find(b => b.textContent?.trim() === '⋯');
        if (!d) throw new Error('"⋯" dugmesi yok');
        return d as HTMLButtonElement;
      });
      await act(async () => { ucNokta.click() });
    }
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
    for (const ad of ['Nakit', 'POS'])
      expect(await tahsilatDugmesi(ad)).not.toBeDisabled();
  });

  it('kaydedilmemis belgede ipucu "belge önce kaydedilir" der', async () => {
    ciz();
    expect((await tahsilatDugmesi('POS')).title).toContain('belge önce kaydedilir');
  });

  it('KAYITLI belgede o ek uyari cikmaz', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    expect((await tahsilatDugmesi('POS')).title).not.toContain('önce kaydedilir');
  });

  it('EKSIK kartta banka basilinca hesap secimi ACILMAZ, Başvuru sekmesine donulur', async () => {
    ciz();
    (await tahsilatDugmesi('Banka')).click();
    await waitFor(() =>
      expect(document.querySelector('.kat.on')?.textContent).toMatch(/^Başvuru/));
    expect(belgeEkle).not.toHaveBeenCalled();
  });
});

describe('tahsilat arac cubugu duzeni', () => {
  // Kartta birden cok `.katoolbar` var (ust arac cubugu + tahsilat) - dogru
  //   olani ICERIGINDEN bulunur.
  const araclar = async () => {
    (await sekme('Tahsilat')).click();
    return waitFor(() => {
      const c = [...document.querySelectorAll('.katoolbar')]
        .find(x => x.textContent?.includes('Nakit'));
      if (!c) throw new Error('tahsilat arac cubugu yok');
      return c;
    });
  };
  const dugmeler = (c: Element) =>
    [...c.querySelectorAll(':scope > button, :scope > .dugme-menu > button')]
      .map(b => (b.textContent ?? '').trim());

  it('NAKIT · POS · ⋯ sirasi (banka/cek/senet menuye tasindi)', async () => {
    ciz();
    const c = await araclar();
    const ilkUc = dugmeler(c).slice(0, 3);
    expect(ilkUc[0]).toContain('Nakit');
    expect(ilkUc[1]).toContain('POS');
    expect(ilkUc[2]).toBe('⋯');
    // Banka / Çek / Senet artik cubukta DEGIL.
    expect(c.textContent).not.toContain('Banka');
    expect(c.textContent).not.toContain('Senet');
  });

  it('"⋯" basilinca Banka / Çek / Senet menusu acilir', async () => {
    ciz();
    const c = await araclar();
    expect(document.querySelector('.dugme-menu-liste')).toBeNull();
    const ucNokta = [...c.querySelectorAll('button')]
      .find(b => b.textContent?.trim() === '⋯')!;
    await act(async () => { ucNokta.click() });
    const menu = document.querySelector('.dugme-menu-liste')!;
    expect([...menu.querySelectorAll('button')].map(b => (b.textContent ?? '').trim()))
      .toEqual(['🏦 Banka', '🧾 Çek', '📜 Senet']);
  });

  it('KENDI ODEYENDE (Özel) Kuruma Tahakkuk dugmesi CIZILMEZ', async () => {
    // Fixture belgenin odeyeni "Özel (Ücretli)" (tur 1) - kurum payi hep 0.
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    const c = await araclar();
    expect(c.textContent).not.toContain('Kuruma Tahakkuk');
  });
});

describe('ucretlendirme KDV DAHIL gosterir (kullanici)', () => {
  // HBYS'de fiyatlar hep KDV dahil veriliyor; saklanan deger MATRAHTIR,
  //   ekranda brute cevrilir. Fis/fatura dogal olarak matrahla kesilir.
  const satirliBelge = (kdv: number, birimFiyat: number) => {
    belgeOku.mockResolvedValue({
      belge: (yanitlar as Record<string, Record<string, unknown>>)['114349'],
      satirlar: [{ id: 1, sira: 1, tur: 2, hizmetId: 900, adet: 1,
                   birimFiyat, kdv, iskonto: 0, iskonto2: 0, aciklama: '' }],
      dipToplam: [], izlemeNo: '',
    });
  };

  it('kolon basligi SADE: "Birim Fiyat (TL)" - deger KDV dahil ama yazmaz', async () => {
    // Kayit kabulde fiyat zaten hep KDV dahil konusuluyor; her satirda
    //   hatirlatmak yer kapliyordu (kullanici).
    satirliBelge(20, 100);
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    (await sekme('Ücretlendirme')).click();
    await waitFor(() =>
      expect([...document.querySelectorAll('th')]
        .some(t => (t.textContent ?? '').startsWith('Birim Fiyat'))).toBe(true));
    expect([...document.querySelectorAll('th')]
      .some(t => t.textContent?.includes('KDV Dahil'))).toBe(false);
  });

  it('MATRAH 100 / %20 satiri gridde 120,00 gorunur', async () => {
    satirliBelge(20, 100);
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    (await sekme('Ücretlendirme')).click();
    await waitFor(() => {
      const hucreler = [...document.querySelectorAll('tbody td')]
        .map(t => (t.textContent ?? '').trim());
      expect(hucreler).toContain('120,00');
      // Matrah degeri gride YAZILMAZ - kullanici brut gorur.
      expect(hucreler).not.toContain('100,00');
    });
  });
});

describe('basvuru dip toplami sadelesti (kullanici)', () => {
  // Sunucunun dip toplam satirlari (fn_belge_diptoplam): 1 Toplam · 3 İskonto ·
  //   4 Ara Toplam · 5 kdv%x · 15 kdv Toplam · 20 Genel Toplam.
  const satirliBelge = (kdv: number, birimFiyat: number, iskonto = 0) => {
    const brut = Math.round(birimFiyat * (1 + kdv / 100) * 10000) / 10000;
    const ind = Math.round(brut * iskonto) / 100;
    const genel = brut - ind;
    const d = (tur: number, aciklama: string, deger: number) =>
      ({ tur, aciklama, deger, dovizTutari: 0, kur: '', belgeDovizi: 'TL' });
    belgeOku.mockResolvedValue({
      belge: (yanitlar as Record<string, Record<string, unknown>>)['114349'],
      satirlar: [{ id: 1, sira: 1, tur: 2, hizmetId: 900, adet: 1, birimFiyat,
                   birimFiyatKdvli: brut, kdv, iskonto, iskonto2: 0, aciklama: '' }],
      dipToplam: [
        d(1, 'Toplam', brut),
        ...(iskonto ? [d(3, 'İskonto', ind)] : []),
        d(4, 'Ara Toplam', genel / (1 + kdv / 100)),
        d(15, 'kdv Toplam', genel - genel / (1 + kdv / 100)),
        d(20, 'Genel Toplam', genel),
      ],
      izlemeNo: '',
    });
  };
  const ucret = async () => { (await sekme('Ücretlendirme')).click() };
  /** Ekranda birden cok `.dip-tablo` olabilir - DOLU olani alinir. */
  const dip = () => waitFor(() => {
    const t = [...document.querySelectorAll('.dip-tablo')]
      .map(x => x.textContent ?? '').find(x => x.includes('Genel Toplam'));
    if (!t) throw new Error('dip toplam tablosu yok');
    return t;
  });

  it('KDV satiri YOK - fiyat zaten KDV dahil konusuluyor', async () => {
    satirliBelge(20, 100);
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    await ucret();
    const t = await dip();
    expect(t).toContain('Genel Toplam');
    expect(t).not.toContain('KDV');
    expect(t).not.toContain('Ara Toplam');
  });

  it('ISKONTO yoksa tek satir: yalniz Genel Toplam', async () => {
    satirliBelge(20, 100);
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    await ucret();
    expect(await dip()).not.toContain('İskonto');
  });

  it('ISKONTO varsa Toplam · İskonto (ORANIYLA) · Genel Toplam', async () => {
    satirliBelge(20, 100, 10);          // brut 120, %10 iskonto -> 108
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    await ucret();
    const t = await dip();
    expect(t).toContain('İskonto');
    expect(t).toContain('120,00');    // iskontosuz brut
    expect(t).toContain('12,00');     // iskonto tutari
    expect(t).toContain('%10');       // ETKIN oran
    expect(t).toContain('108,00');    // genel toplam
  });

  it('GRIDIN kendi TOPLAM satiri basvuruda cizilmez', async () => {
    satirliBelge(20, 100);
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    await ucret();
    await dip();
    expect([...document.querySelectorAll('tfoot')]
      .some(f => f.textContent?.includes('TOPLAM'))).toBe(false);
  });
});

describe('tahsilat tutari MODALDE sorulur (kullanici)', () => {
  // Once acik borc varsa SORULMADAN tahsil ediliyordu; kismi tahsilat ancak
  //   satir eklendikten sonra gridden duzeltilebiliyordu. Artik her araca
  //   basildiginda tutar kutusu acik borcla ONYUKLU gelir.
  it('NAKIT basilinca tutar sorulur ve varsayilan ACIK BORCTUR', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    (await sekme('Tahsilat')).click();
    const nakit = await waitFor(() => {
      const d = [...document.querySelectorAll('.katoolbar button')]
        .find(b => b.textContent?.includes('Nakit'));
      if (!d) throw new Error('Nakit dugmesi yok');
      return d as HTMLButtonElement;
    });
    await act(async () => { nakit.click() });
    // metinSor kutusu MesajKatmani'nda cizilmiyor (saglayici yok) ama
    //   cagrildigi kesin: kart kaydedilmis oldugu icin kayitSart gecti ve
    //   akis tutar sorusuna geldi - tahsilat satiri EKLENMEDI.
    expect(document.querySelector('[data-testid="hesap"]')).toBeNull();
  });

  it('GRIDDE tutar hucresi artik TIKLANARAK duzenlenmiyor', async () => {
    ciz({ id: 114349 });
    await waitFor(() => expect(belgeOku).toHaveBeenCalled());
    (await sekme('Tahsilat')).click();
    await waitFor(() => expect(document.querySelector('.katoolbar')).toBeTruthy());
    expect(document.querySelector('.tiklanir-tutar')).toBeNull();
  });
});
