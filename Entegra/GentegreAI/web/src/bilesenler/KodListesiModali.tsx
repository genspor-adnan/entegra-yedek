import { useCallback, useEffect, useState } from 'react';
import { Modal } from './Modal';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * JENERIK KOD LISTESI DUZENLEME (219).
 *
 * Ayar combolarinin ETIKETINE tiklaninca acilir: combonun beslendigi
 * kod listesinin (kod_liste/kod_deger) degerleri burada eklenir/silinir/
 * degistirilir. Ekran BILMEZ - liste kodu props'la gelir; ayarlardaki her
 * combo ayni modali kullanir.
 *
 * Kayit ANINDA sunucuya gider (ayar ekranlarinin "aninda kaydet" deseni);
 * kapaninca `onKapat` cagrilir - cagiran combo seceneklerini tazeler.
 */
export function KodListesiModali({ kod, baslik, onKapat }: {
  kod: string;
  baslik: string;
  onKapat(): void;
}) {
  const [satirlar, setSatirlar] =
    useState<{ deger: number; ad: string; sira: number; aktif: number }[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [yeniAd, setYeniAd] = useState('');
  /** Duzenlenen satir (deger) ve taslak adi. */
  const [duzenlenen, setDuzenlenen] = useState<number | null>(null);
  const [taslakAd, setTaslakAd] = useState('');

  const yukle = useCallback(async () => {
    try { setSatirlar((await api.kodListe(kod)).degerler); setHata(null) }
    catch (h) { setHata(hataMetni(h)) }
  }, [kod]);

  useEffect(() => { void yukle() }, [yukle]);

  const guvenli = (islem: () => Promise<unknown>) =>
    void (async () => {
      try { await islem(); await yukle(); setHata(null) }
      catch (h) { setHata(hataMetni(h)) }
    })();

  const ekle = () => {
    const ad = yeniAd.trim();
    if (!ad) return;
    setYeniAd('');
    guvenli(() => api.kodListeEkle(kod, ad));
  };

  return (
    <Modal baslik={`Liste Düzenle — ${baslik}`} dar onKapat={onKapat}
      alt={<button className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>}
    >
      <div className="kagrup">
        {hata && <div className="hata-kutusu" style={{ marginBottom: 8 }}>{hata}</div>}

        <div style={{ display: 'flex', gap: 6, marginBottom: 10 }}>
          <input placeholder="Yeni değer…" value={yeniAd} style={{ flex: 1 }}
                 onChange={e => setYeniAd(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') ekle() }} />
          <button className="d bir" onClick={ekle} disabled={!yeniAd.trim()}>＋ Ekle</button>
        </div>

        <table className="detay-tablo" style={{ width: '100%' }}>
          <thead>
            <tr><th>Ad</th><th style={{ width: 60 }}>Sıra</th>
                <th style={{ width: 60 }}>Aktif</th><th style={{ width: 84 }} /></tr>
          </thead>
          <tbody>
            {satirlar.map(s => (
              <tr key={s.deger}>
                <td>
                  {duzenlenen === s.deger ? (
                    <input value={taslakAd} autoFocus style={{ width: '100%' }}
                           onChange={e => setTaslakAd(e.target.value)}
                           onKeyDown={e => {
                             if (e.key === 'Enter' && taslakAd.trim()) {
                               setDuzenlenen(null);
                               guvenli(() => api.kodListeGuncelle(kod, s.deger,
                                 { ad: taslakAd.trim(), sira: s.sira, aktif: s.aktif }));
                             }
                             if (e.key === 'Escape') setDuzenlenen(null);
                           }} />
                  ) : s.ad}
                </td>
                <td className="hiza-orta">{s.sira}</td>
                <td className="hiza-orta">
                  <input type="checkbox" checked={s.aktif === 1}
                         onChange={e => guvenli(() => api.kodListeGuncelle(kod, s.deger,
                           { ad: s.ad, sira: s.sira, aktif: e.target.checked ? 1 : 0 }))} />
                </td>
                <td className="hiza-orta">
                  <button type="button" className="d ikon-dugme" title="Değiştir"
                          onClick={() => { setDuzenlenen(s.deger); setTaslakAd(s.ad) }}>✎</button>
                  <button type="button" className="d teh ikon-dugme" title="Sil"
                          onClick={() => guvenli(() => api.kodListeSil(kod, s.deger))}>🗑</button>
                </td>
              </tr>
            ))}
            {satirlar.length === 0 && (
              <tr><td colSpan={4} className="bos">Değer yok</td></tr>
            )}
          </tbody>
        </table>

        <div className="not" style={{ marginTop: 8 }}>
          Değişiklikler anında kaydedilir. Silinen değer eski kayıtlarda
          kullanılmışsa listelerde adı boş görünür.
        </div>
      </div>
    </Modal>
  );
}
