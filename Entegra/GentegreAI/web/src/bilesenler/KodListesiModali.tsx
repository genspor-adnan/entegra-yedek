import { useCallback, useEffect, useState } from 'react';
import { Modal } from './Modal';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/** Taslak satiri: deger=null -> henuz sunucuda olmayan YENI kayit. */
interface TaslakSatir { deger: number | null; ad: string; sira: number; aktif: number }

/**
 * JENERIK KOD LISTESI DUZENLEME (219).
 *
 * Ayar combolarinin ETIKETINE tiklaninca acilir: combonun beslendigi
 * kod listesinin (kod_liste/kod_deger) degerleri duzenlenir. Ekran BILMEZ -
 * liste kodu props'la gelir; ayarlardaki her combo ayni modali kullanir.
 *
 * TASLAK MODELI (kullanici): degisiklikler ANINDA GITMEZ - ekle/sil/degistir
 * yerelde birikir, sol ustteki KAYDET son hali sunucuya yazar (sil + guncelle
 * + ekle sirasiyla) ve modal kapanir. Kaydetmeden kapatilirsa hicbir sey
 * degismez.
 */
export function KodListesiModali({ kod, baslik, ustDeger, onKapat }: {
  kod: string;
  baslik: string;
  /**
   * BAGLI LISTE (544): verilirse liste yalniz bu ust degerin satirlarini
   * gosterir ve yeni satir da ona baglanir - stok kartinda "Model" listesi
   * secili MARKANIN modelleridir. Bagsiz listelerde verilmez.
   */
  ustDeger?: number;
  onKapat(): void;
}) {
  const [ilk, setIlk] = useState<TaslakSatir[]>([]);
  const [satirlar, setSatirlar] = useState<TaslakSatir[]>([]);
  const [silinenler, setSilinenler] = useState<number[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [yeniAd, setYeniAd] = useState('');
  /** Duzenlenen satirin indeksi ve taslak adi. */
  const [duzenlenen, setDuzenlenen] = useState<number | null>(null);
  const [taslakAd, setTaslakAd] = useState('');

  const yukle = useCallback(async () => {
    try {
      const d = (await api.kodListe(kod, ustDeger)).degerler
        .map(x => ({ deger: x.deger as number | null, ad: x.ad, sira: x.sira, aktif: x.aktif }));
      setIlk(d.map(x => ({ ...x })));
      setSatirlar(d.map(x => ({ ...x })));
      setSilinenler([]);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [kod, ustDeger]);

  useEffect(() => { void yukle() }, [yukle]);

  const degisti = satirlar.some(s => {
    if (s.deger === null) return true;
    const o = ilk.find(x => x.deger === s.deger);
    return !o || o.ad !== s.ad || o.aktif !== s.aktif || o.sira !== s.sira;
  }) || silinenler.length > 0;

  const ekle = () => {
    const ad = yeniAd.trim();
    if (!ad) return;
    setYeniAd('');
    setSatirlar(t => [...t, {
      deger: null, ad,
      sira: Math.max(0, ...t.map(x => x.sira)) + 10, aktif: 1,
    }]);
  };

  const sil = (i: number) => {
    const s = satirlar[i];
    if (s.deger !== null) setSilinenler(t => [...t, s.deger!]);
    setSatirlar(t => t.filter((_, x) => x !== i));
  };

  const kaydet = async () => {
    setKaydediyor(true);
    setHata(null);
    try {
      // Sira: once SIL (ad cakismalari acilsin), sonra GUNCELLE, sonra EKLE.
      for (const d of silinenler) await api.kodListeSil(kod, d);
      for (const s of satirlar) {
        if (s.deger === null) continue;
        const o = ilk.find(x => x.deger === s.deger);
        if (!o || o.ad !== s.ad || o.aktif !== s.aktif || o.sira !== s.sira)
          await api.kodListeGuncelle(kod, s.deger, { ad: s.ad, sira: s.sira, aktif: s.aktif });
      }
      for (const s of satirlar)
        if (s.deger === null) await api.kodListeEkle(kod, s.ad, s.sira, ustDeger);
      onKapat();                    // cagiran combo seceneklerini tazeler
    } catch (h) {
      // Kismi yazim olabilir - taze durumla devam edilsin.
      setHata(hataMetni(h));
      await yukle();
    } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Liste Düzenle — ${baslik}`} dar onKapat={onKapat}
      alt={<>
        {/* SOL USTTE KAYDET (kullanici): degisiklikler basilana kadar yerelde. */}
        <button className="d bir" disabled={!degisti || kaydediyor}
                onClick={() => void kaydet()}>
          {kaydediyor ? 'Kaydediliyor…' : '💾 Kaydet'}
        </button>
        <button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                onClick={onKapat} disabled={kaydediyor}>✕ Kapat</button>
      </>}
    >
      <div className="kagrup">
        {hata && <div className="hata-kutusu" style={{ marginBottom: 8 }}>{hata}</div>}

        <div style={{ display: 'flex', gap: 6, marginBottom: 10 }}>
          <input placeholder="Yeni değer…" value={yeniAd} style={{ flex: 1 }}
                 onChange={e => setYeniAd(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') ekle() }} />
          <button className="d" onClick={ekle} disabled={!yeniAd.trim()}>＋ Ekle</button>
        </div>

        <table className="detay-tablo" style={{ width: '100%' }}>
          <thead>
            <tr><th>Ad</th><th style={{ width: 60 }}>Sıra</th>
                <th style={{ width: 60 }}>Aktif</th><th style={{ width: 84 }} /></tr>
          </thead>
          <tbody>
            {satirlar.map((s, i) => (
              <tr key={s.deger ?? `yeni-${i}`}
                  style={s.deger === null ? { fontStyle: 'italic' } : undefined}>
                <td>
                  {duzenlenen === i ? (
                    <input value={taslakAd} autoFocus style={{ width: '100%' }}
                           onChange={e => setTaslakAd(e.target.value)}
                           onKeyDown={e => {
                             if (e.key === 'Enter' && taslakAd.trim()) {
                               setSatirlar(t => t.map((x, xi) =>
                                 xi === i ? { ...x, ad: taslakAd.trim() } : x));
                               setDuzenlenen(null);
                             }
                             if (e.key === 'Escape') setDuzenlenen(null);
                           }} />
                  ) : <>{s.ad}{s.deger === null && <span className="sonuk"> (yeni)</span>}</>}
                </td>
                <td className="hiza-orta">{s.sira}</td>
                <td className="hiza-orta">
                  <input type="checkbox" checked={s.aktif === 1}
                         onChange={e => setSatirlar(t => t.map((x, xi) =>
                           xi === i ? { ...x, aktif: e.target.checked ? 1 : 0 } : x))} />
                </td>
                <td className="hiza-orta">
                  <button type="button" className="d ikon-dugme" title="Değiştir"
                          onClick={() => { setDuzenlenen(i); setTaslakAd(s.ad) }}>✎</button>
                  <button type="button" className="d teh ikon-dugme" title="Sil"
                          onClick={() => sil(i)}>🗑</button>
                </td>
              </tr>
            ))}
            {satirlar.length === 0 && (
              <tr><td colSpan={4} className="bos">Değer yok</td></tr>
            )}
          </tbody>
        </table>

        <div className="not" style={{ marginTop: 8 }}>
          Değişiklikler <b>Kaydet</b>'e basılınca yazılır; kaydetmeden kapatılırsa
          hiçbir şey değişmez. Silinen değer eski kayıtlarda kullanılmışsa
          listelerde adı boş görünür.
        </div>
      </div>
    </Modal>
  );
}
