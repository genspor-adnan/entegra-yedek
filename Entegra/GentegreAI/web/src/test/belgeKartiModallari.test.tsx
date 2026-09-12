// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render } from '@testing-library/react';
import {
  BelgeKartiModallari, type BelgeKartiModalProps,
} from '../bilesenler/belge/BelgeKartiModallari';
import { bosSatir } from '../sayfalar/belgeSatir';
import { belgeTuruBilgisi } from '../sayfalar/belgeTuru';

/**
 * KARTIN PENCERE YONLENDIRMESI.
 *
 * Pencereler karttan ayri bir bilesene tasindi; tasima sirasinda bir kosulun
 * kaymasi (or. iade turleri, stok yonu, hasta/cari kaynagi) ekranda ancak o
 * senaryo denenince fark edilir - YANLIS belge turu ya da yanlis kisi listesi
 * gosterilir. Bu testler "hangi bayrak hangi pencereyi, HANGI parametreyle
 * acar" sorusunu sabitler.
 *
 * Cocuk pencereler taklit ediliyor: burada denenen sey pencerelerin ICI degil,
 * karttan onlara giden karardir.
 */

/** Taklit pencerelerin aldigi son proplar - testler buradan okur. */
const cizilen: Record<string, Record<string, unknown>> = {};

function taklit(ad: string, gorunurAlan?: string) {
  return (props: Record<string, unknown>) => {
    // TarafArama gibi HEP mount edilen pencereler `acik` ile gizlenir; ustelik
    //   kartta UC TarafArama var (cari / satis temsilcisi / teslim personeli).
    //   Kapali olani KAYDETMIYORUZ: yoksa en sondaki oteki ikisini eziyor ve
    //   test hep sonuncusunun proplarini okuyor.
    if (gorunurAlan && !props[gorunurAlan]) return null;
    cizilen[ad] = props;
    return <div data-testid={ad} />;
  };
}

vi.mock('../bilesenler/TarafArama', () => ({ TarafArama: taklit('taraf', 'acik') }));
vi.mock('../bilesenler/StokAramaPenceresi', () => ({ StokAramaPenceresi: taklit('stok') }));
vi.mock('../bilesenler/BelgeDonusumModali', () => ({ BelgeDonusumModali: taklit('donusum') }));
vi.mock('../bilesenler/radyoloji/IstemModali', () => ({ IstemModali: taklit('istem') }));
vi.mock('../bilesenler/belge/KalemPenceresi', () => ({ KalemPenceresi: taklit('kalem') }));
vi.mock('../bilesenler/belge/TerminModali', () => ({ TerminModali: taklit('termin') }));
vi.mock('../bilesenler/prim/KalemRolModali', () => ({ KalemRolModali: taklit('rol') }));
vi.mock('../bilesenler/belge/IadeSatirPenceresi', () => ({ IadeSatirPenceresi: taklit('iade') }));
vi.mock('../bilesenler/belge/HesapSecModali', () => ({ HesapSecModali: taklit('hesap') }));
vi.mock('../bilesenler/belge/BelgeTahsilatModallari',
        () => ({ BelgeTahsilatModallari: taklit('tahsilat') }));
// Kartin KENDISI (turetilmis belge ustte acilir) - gercegini yuklemek tum
//   sayfayi ve api'yi getirirdi; burada yalniz "acildi mi" onemli.
vi.mock('../sayfalar/BelgeKarti', () => ({ BelgeKarti: taklit('altKart') }));

const yok = () => {};
const temel = (y: Partial<BelgeKartiModalProps> = {}): BelgeKartiModalProps => ({
  kayitliId: 0, tur: 15, bilgi: belgeTuruBilgisi(15),
  basvuruMu: false, alisMi: false, irsaliyeMi: false, siparisMi: false,
  stokFisiMi: false, depoBelgesi: false,
  yerelPara: 'TRY', tarih: '2026-09-04T10:00', odeyenKurumId: null,
  depo: null, sonuc: null, setSonuc: yok,
  cari: null, setCari: yok, cariArama: false, setCariArama: yok,
  hastaAramaMetni: '', setHastaAramaMetni: yok,
  hastaAramaYeni: false, setHastaAramaYeni: yok,
  hastaKartId: null, setHastaKartId: yok,
  saticiArama: false, setSaticiArama: yok, setSatici: yok,
  personelArama: null, setPersonelArama: yok,
  setTeslimEden: yok, setTeslimAlan: yok,
  satirlar: [], setSatirlar: yok, stokArama: false, setStokArama: yok,
  aramaEklenen: { sayi: 0, son: '' }, setAramaEklenen: yok,
  stokSecildi: yok, kalem: null, setKalem: yok, kalemKaydet: yok,
  iadeArama: false, setIadeArama: yok,
  tahsilat: {} as BelgeKartiModalProps['tahsilat'],
  tahsilatTutariSor: async () => 0,
  hesapSecim: null, setHesapSecim: yok,
  donusum: null, setDonusum: yok, donusumPay: 0, setDonusumPay: yok,
  acilanDonusum: null, setAcilanDonusum: yok,
  donusumleriYukle: async () => {},
  terminAcik: false, setTerminAcik: yok,
  rolModali: null, setRolModali: yok,
  istemModali: false, setIstemModali: yok,
  onKaydedildi: yok, git: yok,
  ...y,
});

const ciz = (y: Partial<BelgeKartiModalProps> = {}) =>
  render(<BelgeKartiModallari {...temel(y)} />);
const HASTA = { id: 7, unvan: 'Ali Veli' };
type Secim = (s: { id: number; unvan: string }) => void;

beforeEach(() => { for (const k of Object.keys(cizilen)) delete cizilen[k] });

describe('cari / hasta arama', () => {
  it('BASVURUDA yalnizca hasta aranir, normal belgede cari', () => {
    ciz({ cariArama: true, basvuruMu: true });
    expect(cizilen.taraf.kaynaklar).toEqual(['hasta']);
    ciz({ cariArama: true, basvuruMu: false });
    expect(cizilen.taraf.kaynaklar).toEqual(['cari']);
  });

  it('secim yapilinca hasta arama durumu TEMIZLENIR (kart bayat metinle acilmasin)', () => {
    const setCari = vi.fn(), setMetin = vi.fn(), setYeni = vi.fn(), setKart = vi.fn();
    ciz({ cariArama: true, setCari, setHastaAramaMetni: setMetin,
          setHastaAramaYeni: setYeni, setHastaKartId: setKart });
    (cizilen.taraf.onSec as Secim)(HASTA);
    expect(setCari).toHaveBeenCalledWith(HASTA);
    expect(setMetin).toHaveBeenCalledWith('');
    expect(setYeni).toHaveBeenCalledWith(false);
    expect(setKart).toHaveBeenCalledWith(null);
  });
});

describe('personel secimi', () => {
  it('"eden" secimi TESLIM EDEN alanini doldurur, teslim alani degil', () => {
    const eden = vi.fn(), alan = vi.fn();
    ciz({ personelArama: 'eden', setTeslimEden: eden, setTeslimAlan: alan });
    (cizilen.taraf.onSec as Secim)({ id: 3, unvan: 'Zeynep' });
    expect(eden).toHaveBeenCalledWith({ id: 3, ad: 'Zeynep' });
    expect(alan).not.toHaveBeenCalled();
  });

  it('"alan" secimi teslim alani doldurur', () => {
    const eden = vi.fn(), alan = vi.fn();
    ciz({ personelArama: 'alan', setTeslimEden: eden, setTeslimAlan: alan });
    (cizilen.taraf.onSec as Secim)({ id: 3, unvan: 'Zeynep' });
    expect(alan).toHaveBeenCalledWith({ id: 3, ad: 'Zeynep' });
    expect(eden).not.toHaveBeenCalled();
  });
});

describe('istem modali (304)', () => {
  it('HASTA SECILMEDEN acilmaz', () => {
    const { queryByTestId } = ciz({ istemModali: true, cari: null });
    expect(queryByTestId('istem')).toBeNull();
  });

  it('hasta varsa hasta ve belge kimligiyle acilir', () => {
    const { getByTestId } = ciz({ istemModali: true, cari: HASTA, kayitliId: 42 });
    expect(getByTestId('istem')).toBeTruthy();
    expect(cizilen.istem.hastaId).toBe(7);
    expect(cizilen.istem.belgeId).toBe(42);
  });
});

describe('iade satir penceresi (132/133)', () => {
  const turler = (y: Partial<BelgeKartiModalProps>) => {
    ciz({ iadeArama: true, cari: HASTA, ...y });
    return cizilen.iade.turler;
  };

  it('iade FATURASI faturalardan, iade IRSALIYESI irsaliyelerden secer', () => {
    expect(turler({ irsaliyeMi: false, alisMi: false })).toEqual([15, 16]);
    expect(turler({ irsaliyeMi: false, alisMi: true })).toEqual([11, 12]);
    expect(turler({ irsaliyeMi: true, alisMi: false })).toEqual([14, 119]);
    expect(turler({ irsaliyeMi: true, alisMi: true })).toEqual([10, 109]);
  });

  it('cari yoksa acilmaz (kimin faturalari listelenecegi belli degil)', () => {
    const { queryByTestId } = ciz({ iadeArama: true, cari: null });
    expect(queryByTestId('iade')).toBeNull();
  });
});

describe('stok arama (141)', () => {
  it('belgenin YONUNE gore suzulur, depo/stok fisinde suzulmez', () => {
    ciz({ stokArama: true, alisMi: false });
    expect(cizilen.stok.yon).toBe('satis');
    ciz({ stokArama: true, alisMi: true });
    expect(cizilen.stok.yon).toBe('alis');
    ciz({ stokArama: true, depoBelgesi: true });
    expect(cizilen.stok.yon).toBeUndefined();
    ciz({ stokArama: true, stokFisiMi: true });
    expect(cizilen.stok.yon).toBeUndefined();
  });

  it('kalem penceresi ustune acilinca arama PASIF olur (cift Enter olmasin)', () => {
    ciz({ stokArama: true });
    expect(cizilen.stok.etkin).toBe(true);
    ciz({ stokArama: true, kalem: bosSatir(1) });
    expect(cizilen.stok.etkin).toBe(false);
  });
});

describe('kalem penceresi', () => {
  // 586: "Ek Katkı" kutusu (ve onu acan `paylasimli` bayragi) kalkti. Pencere
  //   artik TARIFE TIPINI soruyor - TTB/SUT'ta Katkı Fiyatı kutusu acilir ve
  //   iskonto katki uzerinden isler.
  it('tarife tipi pencereye AYNEN gecer (Katkı Fiyatı kutusunun kosulu)', () => {
    ciz({ kalem: bosSatir(1), basvuruMu: true, tarifeTipi: 3 });
    expect(cizilen.kalem.tarifeTipi).toBe(3);
    ciz({ kalem: bosSatir(1), basvuruMu: true, tarifeTipi: 1 });
    expect(cizilen.kalem.tarifeTipi).toBe(1);
  });

  it('eski PAYLASIMLI bayragi ARTIK GONDERILMEZ', () => {
    ciz({ kalem: bosSatir(1), basvuruMu: true, odeyenKurumId: 5 });
    expect(cizilen.kalem.paylasimli).toBeUndefined();
  });

  it('kaydedince arama penceresi acikken sayac artar', () => {
    const setEklenen = vi.fn();
    ciz({ kalem: bosSatir(1), stokArama: true, setAramaEklenen: setEklenen });
    (cizilen.kalem.onKaydet as (r: unknown) => void)({ ...bosSatir(1), stokAdi: 'Tetkik' });
    expect(setEklenen).toHaveBeenCalled();
  });

  it('arama penceresi KAPALIYSA sayac artmaz', () => {
    const setEklenen = vi.fn();
    ciz({ kalem: bosSatir(1), stokArama: false, setAramaEklenen: setEklenen });
    (cizilen.kalem.onKaydet as (r: unknown) => void)({ ...bosSatir(1), stokAdi: 'Tetkik' });
    expect(setEklenen).not.toHaveBeenCalled();
  });
});

describe('hizli tahsilat hesap secimi', () => {
  it('banka ve POS ayni pencereyi FARKLI baslikla acar', () => {
    ciz({ hesapSecim: 'B' });
    expect(cizilen.hesap.baslik).toBe('Banka Hesabı Seç');
    ciz({ hesapSecim: 'P' });
    expect(cizilen.hesap.baslik).toBe('POS Hesabı Seç');
  });

  it('yalniz YEREL para birimli hesaplar listelenir', () => {
    ciz({ hesapSecim: 'B', yerelPara: 'TRY' });
    expect(cizilen.hesap.doviz).toBe('TRY');
  });
});

describe('kaydedilmis belge gerektiren pencereler', () => {
  it('termin ve donusum KAYDEDILMEMIS belgede acilmaz', () => {
    const a = ciz({ terminAcik: true, donusum: 15, kayitliId: 0 });
    expect(a.queryByTestId('termin')).toBeNull();
    expect(a.queryByTestId('donusum')).toBeNull();
    const b = ciz({ terminAcik: true, donusum: 15, kayitliId: 99 });
    expect(b.getByTestId('termin')).toBeTruthy();
    expect(b.getByTestId('donusum')).toBeTruthy();
  });

  it('donusum hedefi 0 (tur secilmemis) ile de acilir - null degilse yeter', () => {
    const { getByTestId } = ciz({ donusum: 0, kayitliId: 99 });
    expect(getByTestId('donusum')).toBeTruthy();
    expect(cizilen.donusum.varsayilanHedef).toBe(0);
  });
});

describe('turetilmis belge ve prim rolleri', () => {
  it('turetilmis belge kartin USTUNDE acilir', () => {
    const { getByTestId } = ciz({ acilanDonusum: 555 });
    expect(getByTestId('altKart')).toBeTruthy();
    expect(cizilen.altKart.id).toBe(555);
  });

  it('rol modali kalemin adiyla acilir', () => {
    ciz({ rolModali: { satirId: 88, ad: 'MR Çekim' } });
    expect(cizilen.rol.belgeSatirId).toBe(88);
    expect(cizilen.rol.kalemAdi).toBe('MR Çekim');
  });
});

describe('hicbir sey acik degilken', () => {
  it('gorunur modal yoktur', () => {
    const { queryByTestId } = ciz();
    for (const ad of ['taraf', 'stok', 'kalem', 'iade', 'istem', 'hesap',
                      'donusum', 'termin', 'rol', 'altKart'])
      expect(queryByTestId(ad)).toBeNull();
  });
});
