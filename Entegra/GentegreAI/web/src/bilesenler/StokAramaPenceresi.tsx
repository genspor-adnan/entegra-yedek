import { useCallback, useEffect, useRef, useState } from 'react';
import { Modal } from './Modal';
import { api } from '../api/istemci';
import { ApiHatasi, type ListeSatiri } from '../api/sozlesme';

/** Tutar bicimi - liste hucrelerinde iki hane. */
const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/**
 * Stok / hizmet arama penceresi - satir eklemenin ilk adimi.
 *
 * Secim yapilinca KAPANMAZ: cagiran uzerine kalem (adet/fiyat) penceresini acar,
 * o kapaninca kullanici buradan siradaki stogu secer. Boylece on kalemlik bir
 * irsaliye tek arama penceresiyle girilir.
 */
export function StokAramaPenceresi({ etkin, onSec, onKapat, yalnizStok }: {
  /** Ustunde kalem penceresi acikken false olur; true'ya donunce arama
      kutusuna odak GERI GELIR (ardisik girişte fare gerekmesin). */
  etkin: boolean;
  onSec(satir: ListeSatiri): void;
  onKapat(): void;
  /** Yalniz STOK aranir (paket icerigi gibi hizmet kabul etmeyen yerler). */
  yalnizStok?: boolean;
}) {
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);
  /** Liste / Son Aranan / Sik Aranan - GenGrid ile ayni (kullanici_arama). */
  const [aramaGorunumu, setAramaGorunumu] = useState<'tum' | 'son' | 'sik'>('tum');
  const zamanlayici = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  // STOK ve HIZMET birlikte aranir: belge satiri ikisinden birine baglanabilir,
  //   kullanicinin once "hangi listede acayim" diye dusunmesi gereksiz. Iki
  //   kaynak paralel cekilir ve tip alaniyla isaretlenir.
  const ara = useCallback(async (metin: string, gorunumSecimi: 'tum' | 'son' | 'sik' = 'tum') => {
    setYukleniyor(true);
    setHata(null);
    try {
      const filtre = metin.trim()
        ? { op: 'or' as const, kosullar: ['kod', 'ad'].map(alan => ({
            alan, op: 'icerir' as const, deger: metin.trim() })) }
        : undefined;

      // gorunum: Son/Sik Aranan sunucuda kullanici_arama ile suzulur+siralanir.
      const gorunum = gorunumSecimi === 'tum' ? undefined : gorunumSecimi;
      const [stoklar, hizmetler] = await Promise.all([
        api.liste('stok',   { sayfa: 1, boyut: 25, filtre, gorunum }),
        yalnizStok ? Promise.resolve({ satirlar: [] as ListeSatiri[] })
                   : api.liste('hizmet', { sayfa: 1, boyut: 25, filtre, gorunum }),
      ]);

      const birlesik: ListeSatiri[] = [
        ...stoklar.satirlar.map((r): ListeSatiri => ({ ...r, tip: 'stok' })),
        ...hizmetler.satirlar.map((r): ListeSatiri => ({ ...r, tip: 'hizmet' })),
      ].sort((a, b) => String(a.ad ?? '').localeCompare(String(b.ad ?? ''), 'tr'));

      setSatirlar(birlesik);
      setSecili(0);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      setSatirlar([]);
    } finally { setYukleniyor(false) }
  }, [yalnizStok]);

  useEffect(() => { void ara(arama, aramaGorunumu) }, [ara, aramaGorunumu]);  // eslint-disable-line react-hooks/exhaustive-deps

  // Pencere one gelince (acilista ve kalem penceresi kapaninca) imlec aramada.
  useEffect(() => { if (etkin) kutu.current?.focus() }, [etkin]);

  const yaz = (metin: string) => {
    setArama(metin);
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => void ara(metin, aramaGorunumu), 250);
  };

  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(i => Math.min(i + 1, satirlar.length - 1)) }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(i => Math.max(i - 1, 0)) }
    else if (e.key === 'Enter' && satirlar[secili]) { e.preventDefault(); onSec(satirlar[secili]) }
  };

  return (
    <Modal
      baslik={yalnizStok ? "Stok Ara" : "Stok / Hizmet Ara"}
      onKapat={onKapat}
      alt={<button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>}
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="kagrup">
          {/* Arama kutusu ve Liste/Son/Sik dugmeleri LISTE EKRANLARIYLA ayni
              (GenGrid deseni) - kullanici ayni araci iki farkli bicimde
              ogrenmek zorunda kalmasin. */}
          <div className="cipler" style={{ margin: 10 }}>
            <div className="ara" style={{
              maxWidth: 260, margin: 0, height: 23, borderRadius: 12,
              background: 'var(--yuz)', color: 'var(--yazi)', border: '1px solid var(--cizgi)',
            }}>
              <span>🔍</span>
              <input
                ref={kutu}
                autoFocus
                style={{ border: 0, background: 'transparent', outline: 'none', width: '100%', color: 'inherit' }}
                placeholder="Stok ya da hizmet ara…"
                value={arama}
                onChange={e => yaz(e.target.value)}
                onKeyDown={tus}
              />
            </div>

            <div className="durumseg">
              <button className={`ikon-liste ${aramaGorunumu === 'tum' ? 'on' : ''}`}
                      title="Tüm Liste" onClick={() => setAramaGorunumu('tum')}>☰</button>
              <button className={`ikon-liste ${aramaGorunumu === 'son' ? 'on' : ''}`}
                      title="Son Aranan" onClick={() => setAramaGorunumu('son')}>🕓</button>
              <button className={`ikon-liste ${aramaGorunumu === 'sik' ? 'on' : ''}`}
                      title="Sık Aranan" onClick={() => setAramaGorunumu('sik')}>⭐</button>
            </div>
          </div>
          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th style={{ width: 70 }} className="hiza-orta">Tip</th>
                <th style={{ width: 130 }}>Kod</th>
                <th>Ad</th>
                <th className="hiza-sag" style={{ width: 90 }}>Kalan</th>
                <th className="hiza-sag" style={{ width: 100 }}>Fiyat</th>
                <th style={{ width: 60 }} className="hiza-orta">Döviz</th>
                <th style={{ width: 110 }} className="hiza-orta">İzleme</th>
                <th className="hiza-sag" style={{ width: 70 }}>KDV</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map((r, i) => (
                <tr key={`${r.tip}-${r.id}`} className={i === secili ? 'secili' : ''}
                    onMouseEnter={() => setSecili(i)}
                    onClick={() => onSec(r)}>
                  <td className="hiza-orta">
                    <span className={`rozet ${r.tip === 'hizmet' ? 'bilgi' : ''}`}>
                      {r.tip === 'hizmet' ? 'Hizmet' : 'Stok'}
                    </span>
                  </td>
                  <td><code>{String(r.kod ?? '')}</code></td>
                  <td>{String(r.ad ?? '')}</td>
                  {/* Kalan ve izleme yalniz STOKTA anlamli - hizmette stok bakiyesi yok. */}
                  <td className="hiza-sag">
                    {r.tip === 'hizmet' ? <span className="sonuk">—</span>
                      : Number(r.kalan ?? 0).toLocaleString('tr-TR')}
                  </td>
                  <td className="hiza-sag">
                    {r.fiyat ? para.format(Number(r.fiyat)) : <span className="sonuk">—</span>}
                  </td>
                  <td className="hiza-orta sonuk">{String(r.fiyatDovizi ?? '') || '—'}</td>
                  <td className="hiza-orta">
                    {r.tip === 'hizmet' ? <span className="sonuk">—</span>
                      : String(r.izlemeAdi ?? 'Yok') === 'Yok'
                        ? <span className="sonuk">Yok</span>
                        : <span className="rozet bilgi">{String(r.izlemeAdi)}</span>}
                  </td>
                  <td className="hiza-sag">%{String(r.kdv ?? 0)}</td>
                </tr>
              ))}
              {!yukleniyor && satirlar.length === 0 && (
                <tr><td colSpan={8} className="bos">Kayıt yok</td></tr>
              )}
            </tbody>
          </table>
          {yukleniyor && <div className="yukleniyor">Aranıyor…</div>}
        </div>
      </>
    </Modal>
  );
}

