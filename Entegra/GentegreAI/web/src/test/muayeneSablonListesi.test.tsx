// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, fireEvent, render, screen, waitFor, within } from '@testing-library/react';

/**
 * MUAYENE ŞABLONLARI — BÖLÜM ve DOKTORA göre (mockup Ekranlar/Muayene/
 * muayene_sablon_listesi · muayene_sablon_karti):
 *   * ağaç Bölüm › Doktor; "Bölüm ortak" doktorlardan önce, bölümsüz en sonda;
 *   * düğüm seçimi gridi süzer; "Benim" çipi oturumdaki doktorun şablonları;
 *   * üst çubuk standart liste gibi (başlık satırı + 🔍 arama kutulu çip şeridi);
 *   * kart: bölüm zorunlu; kaydet yalnız değişen alanları ve alan farkını yollar.
 */
const api = {
  liste: vi.fn(), kartOku: vi.fn(), kartAlanlari: vi.fn(), kartEkle: vi.fn(), kartGuncelle: vi.fn(),
  sablonKopyala: vi.fn(), sablonVarsayilan: vi.fn(), sablonKullanim: vi.fn(), sablonGecmis: vi.fn(),
};
vi.mock('../api/istemci', () => ({ api }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, onay: () => Promise.resolve(true), guvenli: (f: () => Promise<void>) => f(),
}));
// Yönetici bayrağı testten değiştirilir (929: doktor yalnız kendi şablonunu düzenler).
const oturum = { yonetici: true };
vi.mock('../kimlik/OturumBaglami', () => ({ useOturum: () => ({
  kullanici: { id: 7 }, aksiyonVar: (k: string) => k === 'muayene.sablon_yonet' && oturum.yonetici }) }));

// Arama penceresi: test tek tıkla bir satır seçer (sunucu araması burada ölçülmez).
vi.mock('../bilesenler/KaynakArama', () => ({
  KaynakArama: ({ kaynak, onSec, onKapat }: { kaynak: string; onSec(r: unknown): void; onKapat(): void }) => (
    <div>
      <button type="button" onClick={() => onSec(kaynak === 'icd'
        ? { kod: 'J06.9', ad: 'AKUT ÜSYE' } : { barkod: '8690000000001', ad: 'PAROL 500 MG' })}>arama-sec</button>
      <button type="button" onClick={onKapat}>arama-kapat</button>
    </div>
  ),
}));

const { MuayeneSablonListesi } = await import('../bilesenler/sablon/MuayeneSablonListesi');
const { MuayeneSablonKarti, secenekOku } = await import('../bilesenler/sablon/MuayeneSablonKarti');

const SATIRLAR = [
  { id: 1, kod: 'DAH-GEN', ad: 'Dahiliye genel', tur: 1, durum: 1, bolumId: 5, bolumAdi: 'İç Hastalıkları', hekimId: 0, doktorAdi: '', varsayilan: 1, alanSayisi: 12, kullanim30: 40 },
  { id: 2, kod: 'AK-GA', ad: 'Göğüs ağrısı', tur: 1, durum: 1, bolumId: 5, bolumAdi: 'İç Hastalıkları', hekimId: 7, doktorAdi: 'Dr. Ali Koç', varsayilan: 0, alanSayisi: 7, kullanim30: 3 },
  { id: 3, kod: 'GOZ-1', ad: 'Göz rutin', tur: 1, durum: 1, bolumId: 9, bolumAdi: 'Göz', hekimId: 0, doktorAdi: '', varsayilan: 0, alanSayisi: 5, kullanim30: 0 },
  { id: 4, kod: 'GEN-1', ad: 'Genel sistem sorgusu', tur: 3, durum: 1, bolumId: 0, bolumAdi: '', hekimId: 0, doktorAdi: '', varsayilan: 0, alanSayisi: 9, kullanim30: 1 },
];

beforeEach(() => {
  oturum.yonetici = true;
  Object.values(api).forEach(f => f.mockReset());
  api.liste.mockResolvedValue({ satirlar: SATIRLAR, toplamKayit: SATIRLAR.length });
  api.kartOku.mockResolvedValue({ kart: { id: 1 }, detaylar: { alanlar: [] }, yetki: {}, izlemeNo: '' });
});

describe('şablon listesi', () => {
  it('ağaç Bölüm › Doktor: bölümsüz en sonda, bölüm açılınca "Bölüm ortak" önce; düğüm gridi süzer', async () => {
    render(<MuayeneSablonListesi />);
    await waitFor(() => expect(screen.getAllByText(/Dahiliye genel/).length).toBeGreaterThan(0));
    const agac = screen.getByRole('tree');
    const bolumler = [...agac.querySelectorAll('.ms-d1')].map(b => b.textContent ?? '');
    expect(bolumler[0]).toContain('Tümü');
    expect(bolumler[bolumler.length - 1]).toContain('Genel (bölümsüz)');

    await act(async () => { within(agac).getByText('İç Hastalıkları').click() });
    const doktorlar = [...agac.querySelectorAll('.ms-d2')].map(b => b.textContent ?? '');
    expect(doktorlar[0]).toContain('Bölüm ortak');
    expect(doktorlar[1]).toContain('Dr. Ali Koç');
    // Grid yalnız İç Hastalıkları.
    const grid = document.querySelector('.ms-grid')!;
    expect(grid.textContent).toContain('Göğüs ağrısı');
    expect(grid.textContent).not.toContain('Göz rutin');
  });

  it('"Benim" çipi oturumdaki doktorun şablonlarını gösterir', async () => {
    render(<MuayeneSablonListesi />);
    await waitFor(() => expect(screen.getByText(/Benim \(1\)/)).toBeTruthy());
    await act(async () => { screen.getByText(/Benim \(1\)/).click() });
    const grid = document.querySelector('.ms-grid')!;
    expect(grid.textContent).toContain('Göğüs ağrısı');
    expect(grid.textContent).not.toContain('Dahiliye genel');
  });

  it('üst çubuk standart liste gibi: başlık satırında araç çubuğu, çip şeridinde arama süzer', async () => {
    render(<MuayeneSablonListesi />);
    await waitFor(() => expect(screen.getAllByText(/Dahiliye genel/).length).toBeGreaterThan(0));
    const bas = document.querySelector('.sayfabas .basrow')!;
    expect(bas.querySelector('h1')!.textContent).toBe('Muayene Şablonları');
    expect(bas.querySelector('.arac-cubugu')!.textContent).toContain('Yeni şablon');
    const kutu = document.querySelector('.cipler .ara-kutu input[type=search]') as HTMLInputElement;
    await act(async () => { fireEvent.change(kutu, { target: { value: 'göz' } }) });
    const grid = document.querySelector('.ms-grid')!;
    expect(grid.textContent).toContain('Göz rutin');
    expect(grid.textContent).not.toContain('Dahiliye genel');
  });
});

describe('şablon kartı', () => {
  const META = {
    kaynak: 'muayene-sablon',
    alanlar: [
      { ad: 'bolumId', kodlar: { '5': '157 - İç Hastalıkları', '9': '151 - Göz' } },
      { ad: 'hekimId', kodlar: { '7': 'Dr. Ali Koç' } },
    ],
    detaylar: [{ ad: 'alanlar', baslik: 'Alanlar', saltOkunur: false, alanlar: [
      { ad: 'id', baslik: 'Id', tip: 'sayi', yazilabilir: false },
      { ad: 'ad', baslik: 'Alan', tip: 'metin', yazilabilir: true },
    ] }],
  };

  it('bölüm kodsuz listelenir; bölüm seçilmeden kaydedilmez; güncellemede yalnız değişen alan gider', async () => {
    api.kartAlanlari.mockResolvedValue(META);
    api.kartOku.mockResolvedValue({ kart: { id: 1, kod: 'DAH-GEN', ad: 'Dahiliye genel', tur: 1, aciklama: '',
      sira: 10, durum: 1, bolumId: 5, hekimId: 0, varsayilan: 1, surum: 'v1' },
      detaylar: { alanlar: [{ id: 11, ad: 'Genel durum' }] }, yetki: {}, izlemeNo: '' });
    api.kartGuncelle.mockResolvedValue({ kart: { id: 1 } });
    render(<MuayeneSablonKarti id={1} onKapat={() => {}} />);
    await waitFor(() => expect((screen.getByLabelText(/Şablon adı/) as HTMLInputElement).value).toBe('Dahiliye genel'));
    const bolum = screen.getByLabelText(/^Bölüm/) as HTMLSelectElement;
    expect([...bolum.options].map(o => o.textContent)).toContain('İç Hastalıkları');
    expect(document.body.textContent).toContain('⭐');

    fireEvent.change(screen.getByLabelText(/Açıklama/), { target: { value: 'Rutin' } });
    await act(async () => { screen.getByText(/💾 Kaydet/).closest('button')!.click() });
    // Alanlarda değişiklik yok: detay farkı GİTMEZ.
    expect(api.kartGuncelle).toHaveBeenCalledWith('muayene-sablon', 1, {
      surum: 'v1', kart: { aciklama: 'Rutin' }, detaylar: undefined });
  });

  it('hekim tercihleri kartın sekmeleri: sayılar rozette; ICD ve ilaç aramadan eklenir, yalnız o detay farkı gider', async () => {
    const d = (ad: string, alanlar: { ad: string; tip: string }[]) => ({ ad, baslik: ad, saltOkunur: false,
      alanlar: [{ ad: 'id', baslik: 'Id', tip: 'sayi', yazilabilir: false },
                ...alanlar.map(x => ({ ...x, baslik: x.ad, yazilabilir: true }))] });
    api.kartAlanlari.mockResolvedValue({ ...META, detaylar: [...META.detaylar,
      { ...d('tanilar', [{ ad: 'icdKod', tip: 'metin' }, { ad: 'sira', tip: 'sayi' }, { ad: 'aciklama', tip: 'metin' }]),
        alanlar: [...d('tanilar', [{ ad: 'icdKod', tip: 'metin' }, { ad: 'sira', tip: 'sayi' }, { ad: 'aciklama', tip: 'metin' }]).alanlar,
                  { ad: 'taniAd', baslik: 'Tanı', tip: 'metin', yazilabilir: false }] },
      d('receteler', [{ ad: 'grup', tip: 'metin' }, { ad: 'ilacBarkod', tip: 'metin' }, { ad: 'ilacAd', tip: 'metin' },
                      { ad: 'kutu', tip: 'sayi' }]),
      d('paneller', [{ ad: 'panelId', tip: 'sayi' }]),
      d('makrolar', [{ ad: 'kisayol', tip: 'metin' }]),
      d('kurallar', [{ ad: 'kod', tip: 'metin' }]),
    ] });
    api.kartOku.mockResolvedValue({ kart: { id: 1, kod: 'DAH-GEN', ad: 'Dahiliye genel', tur: 1, aciklama: '',
      sira: 10, durum: 1, bolumId: 5, hekimId: 0, surum: 'v1' },
      detaylar: { alanlar: [], tanilar: [{ id: 3, icdKod: 'I10', taniAd: 'HT', sira: 1, aciklama: '' }],
                  paneller: [{ id: 4, panelId: 7 }, { id: 5, panelId: 8 }] }, yetki: {}, izlemeNo: '' });
    api.kartGuncelle.mockResolvedValue({ kart: { id: 1 } });
    render(<MuayeneSablonKarti id={1} onKapat={() => {}} />);
    await waitFor(() => expect((screen.getByLabelText(/Şablon adı/) as HTMLInputElement).value).toBe('Dahiliye genel'));
    // Rozet: kayıtlı satır sayısı.
    expect(screen.getByRole('tab', { name: /Sık Tanılar/ }).textContent).toContain('1');
    expect(screen.getByRole('tab', { name: /İstem Panelleri/ }).textContent).toContain('2');

    await act(async () => { screen.getByRole('tab', { name: /Sık Tanılar/ }).click() });
    await act(async () => { screen.getByText(/ICD-10 ara/).click() });
    await act(async () => { screen.getByText('arama-sec').click() });
    await act(async () => { screen.getByText('arama-sec').click() });   // aynı tanı ikinci kez eklenmez
    await act(async () => { screen.getByText('arama-kapat').click() });

    await act(async () => { screen.getByRole('tab', { name: /Reçete Şablonları/ }).click() });
    fireEvent.change(screen.getByLabelText('Reçete şablonu'), { target: { value: 'ÜSYE' } });
    await act(async () => { screen.getByText(/İlaç ekle/).click() });
    await act(async () => { screen.getByText('arama-sec').click() });
    await act(async () => { screen.getByText('arama-kapat').click() });

    await act(async () => { screen.getByText(/💾 Kaydet/).closest('button')!.click() });
    const govde = api.kartGuncelle.mock.calls[0][2];
    expect(govde.kart).toEqual({});
    expect(Object.keys(govde.detaylar).sort()).toEqual(['receteler', 'tanilar']);
    expect(govde.detaylar.tanilar.eklenen).toEqual([expect.objectContaining({ icdKod: 'J06.9', sira: 2 })]);
    // Salt okunur hesaplanan alan (taniAd) sunucuya gitmez.
    expect(govde.detaylar.tanilar.eklenen[0].taniAd).toBeUndefined();
    expect(govde.detaylar.receteler.eklenen).toEqual([expect.objectContaining({
      grup: 'ÜSYE', ilacBarkod: '8690000000001', ilacAd: 'PAROL 500 MG', kutu: 1 })]);
  });

  it('yeni şablonda bölüm seçilmezse kaydetmez', async () => {
    api.kartAlanlari.mockResolvedValue(META);
    render(<MuayeneSablonKarti id="yeni" onKapat={() => {}} />);
    await waitFor(() => expect(screen.getByLabelText(/Şablon adı/)).toBeTruthy());
    fireEvent.change(screen.getByLabelText(/^Kod/), { target: { value: 'X1' } });
    fireEvent.change(screen.getByLabelText(/Şablon adı/), { target: { value: 'Yeni' } });
    await act(async () => { screen.getByText(/💾 Kaydet/).closest('button')!.click() });
    expect(api.kartEkle).not.toHaveBeenCalled();
    expect(document.body.textContent).toContain('Bölüm seçilmeli');
  });

  it('seçenekler: jsonb metni okunur; seçili alana çip eklenir/çıkarılır, JSON olarak kaydedilir', async () => {
    expect(secenekOku('["yok","+1"]')).toEqual(['yok', '+1']);
    expect(secenekOku(null)).toEqual([]);
    expect(secenekOku('bozuk')).toEqual([]);

    api.kartAlanlari.mockResolvedValue({ ...META, detaylar: [{ ...META.detaylar[0], alanlar: [
      ...META.detaylar[0].alanlar,
      { ad: 'tip', baslik: 'Tip', tip: 'sayi', yazilabilir: true },
      { ad: 'secenekler', baslik: 'Seçenekler', tip: 'json', yazilabilir: true },
      { ad: 'normalMetni', baslik: 'Normal metni', tip: 'metin', yazilabilir: true },
    ] }] });
    api.kartOku.mockResolvedValue({ kart: { id: 1, kod: 'K', ad: 'Kardiyoloji', tur: 1, aciklama: '', sira: 0,
      durum: 1, bolumId: 5, hekimId: 0, surum: 'v' },
      detaylar: { alanlar: [{ id: 21, ad: 'Ödem', tip: 3, secenekler: '["yok","+1"]', normalMetni: 'yok' }] },
      yetki: {}, izlemeNo: '' });
    api.kartGuncelle.mockResolvedValue({ kart: { id: 1 } });
    render(<MuayeneSablonKarti id={1} onKapat={() => {}} />);
    await waitFor(() => expect((screen.getByLabelText(/Şablon adı/) as HTMLInputElement).value).toBe('Kardiyoloji'));
    await act(async () => { screen.getByRole('tab', { name: /Alanlar/ }).click() });
    // Satır başındaki seçim kutusu (başlıktaki "tümü" değil).
    const kutu = document.querySelector('tbody input[type=checkbox]') as HTMLInputElement;
    await act(async () => { fireEvent.click(kutu) });
    await waitFor(() => expect(document.body.textContent).toContain('Seçenekler — Ödem'));
    fireEvent.change(screen.getByLabelText('Yeni seçenek'), { target: { value: '+2' } });
    await act(async () => { fireEvent.keyDown(screen.getByLabelText('Yeni seçenek'), { key: 'Enter' }) });
    await act(async () => { screen.getByLabelText('+1 kaldır').click() });
    await act(async () => { screen.getByText(/💾 Kaydet/).closest('button')!.click() });
    const govde = api.kartGuncelle.mock.calls[0][2];
    expect(govde.detaylar.alanlar.degisen).toEqual([expect.objectContaining({ id: 21, secenekler: '["yok","+2"]' })]);
  });

  it('yetkisiz doktor: bölüm ortak şablon SALT OKUNUR (Kaydet yok, kilit bandı, Kopyala var)', async () => {
    oturum.yonetici = false;
    api.kartAlanlari.mockResolvedValue(META);
    api.kartOku.mockResolvedValue({ kart: { id: 1, kod: 'DAH-GEN', ad: 'Dahiliye genel', tur: 1, aciklama: '',
      sira: 10, durum: 1, bolumId: 5, hekimId: 0, varsayilan: 1, surum: 'v1' },
      detaylar: { alanlar: [] }, yetki: {}, izlemeNo: '' });
    render(<MuayeneSablonKarti id={1} onKapat={() => {}} />);
    await waitFor(() => expect((screen.getByLabelText(/Şablon adı/) as HTMLInputElement).value).toBe('Dahiliye genel'));
    expect(document.body.textContent).toContain('yalnız görüntüleyebilirsiniz');
    expect(screen.queryByText(/💾 Kaydet/)).toBeNull();
    expect(screen.getByRole('button', { name: /Kopyala \(bana\)/ })).toBeTruthy();
    expect((screen.getByLabelText(/Şablon adı/) as HTMLInputElement).closest('fieldset')!.disabled).toBe(true);
    expect(screen.queryByText(/Bölüm varsayılanı yap/)).toBeNull();
  });

  it('yetkisiz doktor: KENDİ şablonunu düzenler; yeni şablonda Doktor = kendisi (kilitli)', async () => {
    oturum.yonetici = false;
    api.kartAlanlari.mockResolvedValue(META);
    api.kartEkle.mockResolvedValue({ kart: { id: 50 } });
    api.kartOku.mockResolvedValue({ kart: { id: 50, kod: 'X1', ad: 'Benim', tur: 1, aciklama: '', sira: 0,
      durum: 1, bolumId: 5, hekimId: 7, surum: 's' }, detaylar: { alanlar: [] }, yetki: {}, izlemeNo: '' });
    render(<MuayeneSablonKarti id="yeni" varsayilanBolum={5} onKapat={() => {}} />);
    await waitFor(() => expect(screen.getByLabelText(/Şablon adı/)).toBeTruthy());
    const doktor = screen.getByLabelText(/^Doktor/) as HTMLSelectElement;
    expect(doktor.value).toBe('7');
    expect(doktor.disabled).toBe(true);
    fireEvent.change(screen.getByLabelText(/^Kod/), { target: { value: 'X1' } });
    fireEvent.change(screen.getByLabelText(/Şablon adı/), { target: { value: 'Benim' } });
    await act(async () => { screen.getByText(/💾 Kaydet/).closest('button')!.click() });
    expect(api.kartEkle).toHaveBeenCalledWith('muayene-sablon', expect.objectContaining({
      kart: expect.objectContaining({ hekimId: 7, bolumId: 5 }) }));
    // Kaydedilen kendi şablonu: salt değil.
    await waitFor(() => expect(document.body.textContent).not.toContain('yalnız görüntüleyebilirsiniz'));
  });
});
