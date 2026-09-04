// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, waitFor, act } from '@testing-library/react';
import { useBelgeFiyatlandirma } from '../sayfalar/belgeKarti/useBelgeFiyatlandirma';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * FIYAT KARARLARI (274/291).
 *
 * Bu hook belgenin HANGI FIYATLA kesilecegini belirliyor; hatasi dogrudan
 * PARA hatasi. En sinsi senaryo: odeyen kurum degisince kampanyanin yeniden
 * cozulmemesi - belge "SGK anlasmasi" fiyatiyla ozel hastaya kesilir ve kimse
 * fark etmez. Sunucu taklit ediliyor, denenen sey kartin verdigi KARAR.
 */

const listele = vi.fn();
const kampanyaOku = vi.fn();
const kalemFiyati = vi.fn();
const varsayilanListe = vi.fn();
const mesajlar: string[] = [];

vi.mock('../api/istemci', () => ({
  api: {
    liste: (...a: unknown[]) => listele(...a),
    fiyatKampanya: (...a: unknown[]) => kampanyaOku(...a),
    fiyatKalem: (...a: unknown[]) => kalemFiyati(...a),
    belgeVarsayilanListe: (...a: unknown[]) => varsayilanListe(...a),
  },
}));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: (m: string) => { mesajlar.push(m) },
  metinSor: () => Promise.resolve(null),
  // `guvenli` gercek hayatta hatayi yakalayip gosterir - testte saydam.
  guvenli: (f: () => Promise<void>) => f(),
}));

const satir = (y: Partial<SatirDurumu> = {}): SatirDurumu =>
  ({ ...bosSatir(1), hizmetId: 900, adet: '1', birimFiyat: '100', ...y });

function kur(y: Parameters<typeof useBelgeFiyatlandirma>[0] extends infer T
  ? Partial<T> : never = {}) {
  const setSatirlar = vi.fn();
  const sonuc = renderHook(() => useBelgeFiyatlandirma({
    belgeId: undefined, tur: 19, alisMi: false, cariId: 7, odeyenKurumId: null,
    satirlar: [], setSatirlar, ...y,
  }));
  return { ...sonuc, setSatirlar };
}

beforeEach(() => {
  vi.clearAllMocks();
  mesajlar.length = 0;
  listele.mockResolvedValue({ satirlar: [] });
  varsayilanListe.mockResolvedValue({ listeId: null });
  kampanyaOku.mockResolvedValue({ kampanyaId: null, ad: '', kod: '', paylasimModu: 1 });
});

describe('kampanya cozumu', () => {
  it('kampanya adi KOD · AD olarak gosterilir', async () => {
    kampanyaOku.mockResolvedValue(
      { kampanyaId: 3, kod: 'SGK26', ad: 'SGK Anlaşması', paylasimModu: 2 });
    const { result } = kur({ odeyenKurumId: 5 });
    await waitFor(() => expect(result.current.kampanyaAdi).toBe('SGK26 · SGK Anlaşması'));
    expect(result.current.kampanyaId).toBe(3);
    expect(result.current.paylasimModu).toBe(2);
  });

  it('kodu olmayan kampanyada yalniz ad yazilir (bos ayrac kalmaz)', async () => {
    kampanyaOku.mockResolvedValue({ kampanyaId: 3, kod: '', ad: 'Genel', paylasimModu: 1 });
    const { result } = kur({ odeyenKurumId: 5 });
    await waitFor(() => expect(result.current.kampanyaAdi).toBe('Genel'));
  });

  it('kampanya YOKSA ad bos kalir', async () => {
    kampanyaOku.mockResolvedValue({ kampanyaId: null, kod: 'X', ad: 'Y', paylasimModu: 1 });
    const { result } = kur({ odeyenKurumId: 5 });
    await waitFor(() => expect(kampanyaOku).toHaveBeenCalled());
    expect(result.current.kampanyaAdi).toBe('');
  });

  it('kampanyanin KENDI listesi varsa belgenin listesi ONA cekilir', async () => {
    kampanyaOku.mockResolvedValue(
      { kampanyaId: 3, kod: '', ad: 'K', paylasimModu: 1, fiyatListesiId: 42 });
    const { result } = kur({ odeyenKurumId: 5 });
    await waitFor(() => expect(result.current.fiyatListesiId).toBe(42));
  });

  it('KAYITLI belgede kampanya DEGISMEZ, yalniz pay modu tazelenir', async () => {
    kampanyaOku.mockResolvedValue(
      { kampanyaId: 9, kod: 'A', ad: 'B', paylasimModu: 2, fiyatListesiId: 42 });
    const { result } = kur({ belgeId: 500, odeyenKurumId: 5 });
    await waitFor(() => expect(result.current.paylasimModu).toBe(2));
    expect(result.current.kampanyaId).toBeNull();
    expect(result.current.kampanyaAdi).toBe('');
    expect(result.current.fiyatListesiId).toBeNull();
  });

  it('cari ve kurum YOKSA kampanya sorulmaz - varsayilana donulur', async () => {
    const { result } = kur({ cariId: null, odeyenKurumId: null });
    await waitFor(() => expect(result.current.paylasimModu).toBe(1));
    expect(kampanyaOku).not.toHaveBeenCalled();
  });

  it('sunucu hatasinda kampanya TEMIZLENIR (bayat kampanya belgeye yazilmasin)', async () => {
    kampanyaOku.mockRejectedValue(new Error('500'));
    const { result } = kur({ odeyenKurumId: 5 });
    await waitFor(() => expect(kampanyaOku).toHaveBeenCalled());
    expect(result.current.kampanyaId).toBeNull();
    expect(result.current.kampanyaAdi).toBe('');
  });
});

describe('fiyat listesi combosu', () => {
  it('BELGE YONUNE gore suzulur: satista 2, alista 1', async () => {
    kur({ alisMi: false });
    await waitFor(() => expect(listele).toHaveBeenCalled());
    const istek = listele.mock.calls[0][1] as { filtre: { kosullar: unknown[] } };
    expect(istek.filtre.kosullar).toContainEqual({ alan: 'yonKodu', op: 'esit', deger: 2 });

    listele.mockClear();
    kur({ alisMi: true });
    await waitFor(() => expect(listele).toHaveBeenCalled());
    const alis = listele.mock.calls[0][1] as { filtre: { kosullar: unknown[] } };
    expect(alis.filtre.kosullar).toContainEqual({ alan: 'yonKodu', op: 'esit', deger: 1 });
  });

  it('KAYITLI belgede varsayilan liste SORULMAZ - belge kendi listesini tasir', async () => {
    kur({ belgeId: 500 });
    await waitFor(() => expect(listele).toHaveBeenCalled());
    expect(varsayilanListe).not.toHaveBeenCalled();
  });

  it('yeni belgede varsayilan liste cariden cozulur', async () => {
    varsayilanListe.mockResolvedValue({ listeId: 8 });
    const { result } = kur();
    await waitFor(() => expect(result.current.fiyatListesiId).toBe(8));
  });
});

describe('satirlari yeniden fiyatlama', () => {
  it('liste secilmemisse HICBIR SEY yapilmaz (sunucuya gidilmez)', async () => {
    const { result, setSatirlar } = kur({ satirlar: [satir()] });
    await act(async () => { await result.current.satirlariYenidenFiyatla(null, 5, 'listeden') });
    expect(kalemFiyati).not.toHaveBeenCalled();
    expect(setSatirlar).not.toHaveBeenCalled();
  });

  it('kalemi olmayan satir (aciklama/baslik) fiyat sorulmadan gecilir', async () => {
    const { result } = kur({ satirlar: [satir({ hizmetId: undefined })] });
    await act(async () => { await result.current.satirlariYenidenFiyatla(8, 5, 'listeden') });
    expect(kalemFiyati).not.toHaveBeenCalled();
  });

  it('listede BULUNAMAYAN kalem sayilir ve fiyati DEGISMEDI diye uyarilir', async () => {
    // Fiyat donmezse kampanyaFiyatiUygula ayni satiri geri verir = bulunamadi.
    kalemFiyati.mockResolvedValue({});
    const { result } = kur({ satirlar: [satir()] });
    await act(async () => { await result.current.satirlariYenidenFiyatla(8, 5, 'listeden') });
    expect(mesajlar[0]).toContain('DEĞİŞMEDİ');
  });

  it('KAYITLI belgede "Kaydet ile kalıcı olur" uyarisi eklenir', async () => {
    kalemFiyati.mockResolvedValue({ fiyat: 250 });
    const { result } = kur({ belgeId: 500, satirlar: [satir()] });
    await act(async () => { await result.current.satirlariYenidenFiyatla(8, 5, 'listeden') });
    expect(mesajlar[0]).toContain('Kaydet ile kalıcı olur');
  });

  it('YENI belgede o uyari cikmaz - zaten kaydedilmemis', async () => {
    kalemFiyati.mockResolvedValue({ fiyat: 250 });
    const { result } = kur({ satirlar: [satir()] });
    await act(async () => { await result.current.satirlariYenidenFiyatla(8, 5, 'listeden') });
    expect(mesajlar[0]).not.toContain('Kaydet ile kalıcı olur');
  });

  it('liste degisimi listeyi yazar ve satirlari o listeyle fiyatlar', async () => {
    kalemFiyati.mockResolvedValue({ fiyat: 250 });
    varsayilanListe.mockResolvedValue({ listeId: 3 });
    const { result } = kur({ satirlar: [satir()], odeyenKurumId: 5 });
    // Once ACILIS listesi otursun: varsayilan liste effect'i sonradan
    //   cozulurse kullanicinin secimini ezerdi ve test sasardi.
    await waitFor(() => expect(result.current.fiyatListesiId).toBe(3));
    await act(async () => { await result.current.listeDegisti(8) });
    expect(result.current.fiyatListesiId).toBe(8);
    expect(kalemFiyati).toHaveBeenCalledWith({ hizmetId: 900 },
                                             { tarafId: 7, kurumId: 5, listeId: 8 });
  });
});
