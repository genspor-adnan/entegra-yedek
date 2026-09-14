import { describe, it, expect } from 'vitest';
import { yanittanBaslik, yanittanBasvuruBilgi } from '../sayfalar/belgeKarti/belgeOkuma';
import yanitlar from './veri/basvuruYaniti.json';

/**
 * GERCEK SUNUCU YANITI uzerinde CEVRIM DENKLIGI.
 *
 * `belgeOkuma.ts` bir TASIMA refaktoruydu: cevrim kartin acilis effect'inden
 * cikarildi, davranisi degismemeliydi. Uydurma nesnelerle denemek yetmez -
 * gercek yanitin kendine ozgu bicimleri var: `null` gelen provizyon alanlari,
 * `belgeTarihi` saniyeli gelir, `tipi` basvuruda 30'dur, `girisDepoId` yoktur.
 *
 * Bu dosya kartin ESKI satir ici kodunu birebir tekrar yazar ve iki cikti
 * gercek yanitlar uzerinde KARSILASTIRILIR. Eski kod degismeyecegi icin bu
 * test yeni cevrimde sessiz bir kayma olursa yakalar.
 *
 * Fixture (`veri/basvuruYaniti.json`) calisan API'den alindi (belge 114349 /
 * 114346 / 114341 - basvuru turu 19, tipi 30); ad-soyad, vergi no ve adres
 * alanlari maskelendi, kalan butun alanlar sunucudan geldigi gibi.
 */
type Belge = Record<string, unknown>;
const ORNEKLER = Object.entries(yanitlar as Record<string, Belge>);
const YEREL = 'TRY';

/** Kartin ESKI (satir ici) baslik cevrimi - degistirilmeden korunuyor. */
function eskiBaslik(b: Belge, yerelPara: string) {
  const cikisD = b.cikisDepoId
    ? { id: Number(b.cikisDepoId), ad: String(b.cikisDepoAdi ?? '') } : null;
  const girisD = b.girisDepoId
    ? { id: Number(b.girisDepoId), ad: String(b.girisDepoAdi ?? '') } : null;
  return {
    tur: Number(b.tur),
    cari: { id: Number(b.tarafId), unvan: String(b.tarafUnvan ?? '') },
    tarih: String(b.belgeTarihi ?? '').slice(0, 16) || 'ŞİMDİ',
    seri: String(b.belgeSeri ?? ''),
    vadeGun: String(b.vadeGun ?? 0),
    aciklama: String(b.aciklama ?? ''),
    odeyenKurumId: b.odeyenKurumId != null ? Number(b.odeyenKurumId) : null,
    fiyatListesiId: Number(b.fiyatListesiId) || null,
    bolumId: b.bolumId != null ? Number(b.bolumId) : null,
    personelId: b.personelId != null ? Number(b.personelId) : null,
    kampanyaId: b.kampanyaId != null ? Number(b.kampanyaId) : null,
    kampanyaAdi: String(b.kampanyaAdi ?? ''),
    teklifDurum: String(b.teklifDurum ?? '1'),
    revizeNo: String(b.revizeNo ?? ''),
    teklifKonusu: String(b.teklifKonusu ?? ''),
    teklifTeslim: String(b.teklifTeslim ?? ''),
    depo: Number(b.tur) === 20 ? cikisD : girisD ?? cikisD,
    girisDepo: Number(b.tur) === 20 ? girisD : null,
    satici: b.saticiId ? { id: Number(b.saticiId), ad: String(b.saticiAdi ?? '') } : null,
    teslimEden: b.teslimEdenId
      ? { id: Number(b.teslimEdenId), ad: String(b.teslimEdenAdi ?? '') } : null,
    teslimAlan: b.teslimAlanId
      ? { id: Number(b.teslimAlanId), ad: String(b.teslimAlanAdi ?? '') } : null,
    teslimSekli: Number(b.teslimSekli ?? 0),
    senaryo: Number(b.senaryo ?? 0),
    sevkTarihi: b.irsaliyeTarihi ? String(b.irsaliyeTarihi).slice(0, 16) : '',
    soforTckn: String(b.soforTckn ?? ''),
    aracPlaka: String(b.aracPlaka ?? ''),
    soforAd: String(b.soforAd ?? ''),
    fisTipi: Number(b.tipi ?? 0),
    faturaTipi: Number(b.tipi) || 1,
    raporDovizi: String(b.raporDovizi ?? b.belgeDovizi ?? '') || yerelPara,
    ekstreDovizi: String(b.ekstreDovizi ?? b.raporDovizi ?? '') || yerelPara,
    belgeKuru: String(b.dovizKuru ?? 1),
  };
}

/** Kartin ESKI basvuru/provizyon cevrimi - degistirilmeden korunuyor. */
function eskiBasvuru(b: Belge) {
  return {
    // SYS TAKIP NO (608): sunucudan gelen yeni alan - basvurunun e-Nabiz
    //   kimligi. Referans cevrim de tasimali, yoksa test "eski kodla ayni
    //   degil" der ve eklenen her mesru alan burayi kirar.
    // 658'de EKLENEN alan: dis kurum basvurusunda hasta cariden ayri
    //   tutuluyor. Referans cevrim de tasiyor - yoksa test "kayma" diye
    //   bildirir; oysa bu bilincli bir davranis degisikligi.
    hastaId: b.hastaId != null ? Number(b.hastaId) : null,
    sysTakipNo: String(b.sysTakipNo ?? ''),
    basvuruTuru: b.basvuruTuru != null ? Number(b.basvuruTuru) : null,
    gelisSekli: b.gelisSekli != null ? Number(b.gelisSekli) : null,
    gelisNedeni: b.gelisNedeni != null ? Number(b.gelisNedeni) : null,
    oda: b.oda != null ? Number(b.oda) : null,
    siraNo: String(b.siraNo ?? ''),
    refakatci: String(b.refakatci ?? ''),
    ambulansHastaNo: String(b.ambulansHastaNo ?? ''),
    ambulansBileklikNo: String(b.ambulansBileklikNo ?? ''),
    // SOZLESME / ALT KURUM / SGK KATKISI: referans kopya BILEREK guncellendi
    //   (kullanici: "sözleşme kaydolmuyor"). Alanlar yaziliyordu ama yanitta
    //   donmuyor, dolayisiyla cevrimde de yoktu; kart her acilista secimi
    //   kaybediyordu. Fixture bu alanlari tasimadigi icin degerler bos gelir -
    //   okuma kurali ayrica asagida test edilir.
    sozlesmeId: b.sozlesmeId != null ? Number(b.sozlesmeId) : null,
    altKurum: b.altKurum != null ? Number(b.altKurum) : null,
    sgkKullan: b.sgkKullan != null ? Number(b.sgkKullan) : 1,
    // EMEKLI (590): referans kopya BILEREK guncellendi - SGK katilim payi
    //   muafiyeti basvurunun bilgisidir ve karta geri okunmali.
    emekli: b.emekli != null ? Number(b.emekli) : 0,
    // 370'te EKLENEN alan: "Kendi İsteği" isareti. Referans kopya BILEREK
    //   guncellendi - bu dosyanin isi "cevrim degismedi mi" degil, "cevrim
    //   YANLISLIKLA degismedi mi". Yeni bir alan eklendiginde buraya da
    //   yazilir; test o zaman yeni alanin kuralini da korumaya baslar.
    kendiIstegi: b.kendiIstegi != null ? Number(b.kendiIstegi) : 0,
    sgkDurum: b.sgkDurum != null ? Number(b.sgkDurum) : 0,
    sgkProvizyonNo: String(b.sgkProvizyonNo ?? ''),
    sgkProvizyonTipi: b.sgkProvizyonTipi != null ? Number(b.sgkProvizyonTipi) : null,
    sgkProvizyonTarihi: b.sgkProvizyonTarihi
      ? String(b.sgkProvizyonTarihi).slice(0, 16) : null,
    sgkGecerlilik: b.sgkGecerlilik ? String(b.sgkGecerlilik).slice(0, 16) : null,
    sgkKarsilama: b.sgkKarsilama != null ? String(b.sgkKarsilama) : '',
    sgkTutar: b.sgkTutar != null ? String(b.sgkTutar) : '',
    sgkRedNedeni: String(b.sgkRedNedeni ?? ''),
    sgkSigortaTuru: String(b.sgkSigortaTuru ?? ''),
    sgkBasvuruNo: String(b.sgkBasvuruNo ?? ''),
    sgkTakipNo: String(b.sgkTakipNo ?? ''),
    sgkTakipTarihi: b.sgkTakipTarihi ? String(b.sgkTakipTarihi).slice(0, 16) : null,
    sgkTakipTuru: b.sgkTakipTuru != null ? Number(b.sgkTakipTuru) : null,
    sgkTesisKodu: String(b.sgkTesisKodu ?? ''),
    sgkMustehaklik: b.sgkMustehaklik != null ? Number(b.sgkMustehaklik) : 0,
    sgkMustehaklikZaman: b.sgkMustehaklikZaman ? String(b.sgkMustehaklikZaman) : null,
    sgkSevkli: b.sgkSevkli != null ? Number(b.sgkSevkli) : 0,
    sgkSevkKurum: String(b.sgkSevkKurum ?? ''),
    ossKurumId: b.ossKurumId != null ? Number(b.ossKurumId) : null,
    ossKurumAdi: String(b.ossKurumAdi ?? ''),
    ossDurum: b.ossDurum != null ? Number(b.ossDurum) : 0,
    ossProvizyonNo: String(b.ossProvizyonNo ?? ''),
    ossProvizyonTarihi: b.ossProvizyonTarihi
      ? String(b.ossProvizyonTarihi).slice(0, 16) : null,
    ossGecerlilik: b.ossGecerlilik ? String(b.ossGecerlilik).slice(0, 16) : null,
    ossKarsilama: b.ossKarsilama != null ? String(b.ossKarsilama) : '',
    ossTutar: b.ossTutar != null ? String(b.ossTutar) : '',
    ossRedNedeni: String(b.ossRedNedeni ?? ''),
    ossPoliceNo: String(b.ossPoliceNo ?? ''),
    ossHasarNo: String(b.ossHasarNo ?? ''),
    ossBrans: String(b.ossBrans ?? ''),
    provizyonAciklama: String(b.provizyonAciklama ?? ''),
  };
}

describe('gercek basvuru yaniti - cevrim denkligi', () => {
  it.each(ORNEKLER)('belge %s: baslik cevrimi eski kodla AYNI', (_id, b) => {
    const yeni = yanittanBaslik(b, YEREL);
    // Tarih dolu geldigi icin "simdiki an" dali calismaz; iki taraf da ayni
    //   kirpmayi yapmali. (Bos tarih dali ayrica belgeOkuma.test.ts'te.)
    expect({ ...yeni }).toEqual(eskiBaslik(b, YEREL));
  });

  it.each(ORNEKLER)('belge %s: basvuru/provizyon cevrimi eski kodla AYNI', (_id, b) => {
    expect({ ...yanittanBasvuruBilgi(b) }).toEqual(eskiBasvuru(b));
  });
});

describe('gercek yanitin kart icin onemli kurallari', () => {
  const b = (yanitlar as Record<string, Belge>)['114349'];

  it('BASVURU turu 19 / tipi 30 - fis tipi 30 tasinir, fatura tipi de 30', () => {
    expect(b.tur).toBe(19);
    const d = yanittanBaslik(b, YEREL);
    expect(d.tur).toBe(19);
    expect(d.fisTipi).toBe(30);
    expect(d.faturaTipi).toBe(30);
  });

  it('belge tarihi SANIYELI gelir, kutuya dakikaya kirpilarak yazilir', () => {
    expect(String(b.belgeTarihi)).toMatch(/T\d{2}:\d{2}:\d{2}/);
    expect(yanittanBaslik(b, YEREL).tarih).toBe(String(b.belgeTarihi).slice(0, 16));
  });

  it('basvuruda GIRIS deposu yok - cikis deposu tek depo alanina yansir', () => {
    expect(b.girisDepoId).toBeNull();
    const d = yanittanBaslik(b, YEREL);
    expect(d.depo).toEqual({ id: Number(b.cikisDepoId), ad: String(b.cikisDepoAdi) });
    expect(d.girisDepo).toBeNull();
  });

  it('odeyen kurum ve fiyat listesi karta gecer (ucretlendirme bunlara bagli)', () => {
    const d = yanittanBaslik(b, YEREL);
    expect(d.odeyenKurumId).toBe(4990);
    expect(d.fiyatListesiId).toBe(6);
  });

  it('provizyon HIC alinmamis belgede durum alanlari 0 olur, numaralar bos', () => {
    expect(b.sgkDurum).toBeNull();
    const p = yanittanBasvuruBilgi(b);
    expect(p.sgkDurum).toBe(0);
    expect(p.ossDurum).toBe(0);
    expect(p.sgkTakipNo).toBe('');
    expect(p.sgkProvizyonTarihi).toBeNull();
  });

  it('SOZLESME / ALT KURUM / SGK KATKISI geri okunur', () => {
    // Kayitli basvuruda police secimi karta DONMELI: donmezse combo bos gelir,
    //   bir sonraki kayitta bos gider ve sunucu "Kurumun N sözleşmesi var -
    //   hangisinin geçerli olduğunu seçin" ile reddeder.
    const x = yanittanBasvuruBilgi({ ...b, sozlesmeId: 2, altKurum: 201, sgkKullan: 0 });
    expect(x.sozlesmeId).toBe(2);
    expect(x.altKurum).toBe(201);
    expect(x.sgkKullan).toBe(0);
    // Alan hic gelmezse: police bos, SGK katkisi VARSAYILAN 1.
    const y = yanittanBasvuruBilgi(b);
    expect(y.sozlesmeId).toBeNull();
    expect(y.sgkKullan).toBe(1);
  });

  it('doviz TL gelir - yerel paraya DUSMEZ (alan dolu)', () => {
    const d = yanittanBaslik(b, YEREL);
    expect(d.raporDovizi).toBe('TL');
    expect(d.ekstreDovizi).toBe('TL');
  });
});
