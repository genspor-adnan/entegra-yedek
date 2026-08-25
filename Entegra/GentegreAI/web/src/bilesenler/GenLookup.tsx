import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type Kosul, type ListeSatiri } from '../api/sozlesme';

interface Props {
  /** Liste kaynagi: 'cari', 'stok' ... */
  kaynak: string;
  /** Kutuda gosterilecek metin (secili kaydin adi). */
  deger?: string;
  etiket?: string;
  /** Aramada taranacak ve listede gosterilecek alanlar. */
  alanlar: { ad: string; baslik: string; genis?: boolean }[];
  sabitFiltre?: Kosul;
  saltOkunur?: boolean;
  zorunlu?: boolean;
  hata?: string;
  onSec(satir: ListeSatiri | null): void;
}

/**
 * Arama/secim kutusu (F0-06 Gen* katmani). Delphi'deki "listeden bilgi getir"
 * diyaloglarinin karsiligi.
 *
 * Arama SUNUCUDA yapilir (liste sozlesmesi, 'icerir' + pg_trgm). Istemci hicbir
 * listeyi bellege alip suzmez - 5.000 stoklu kurulumda bu ekrani kilitlerdi.
 */
export function GenLookup({
  kaynak, deger, etiket, alanlar, sabitFiltre,
  saltOkunur, zorunlu, hata, onSec,
}: Props) {
  const [acik, setAcik] = useState(false);
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [listeHatasi, setListeHatasi] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);

  const zamanlayici = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  const ara = useCallback(async (metin: string) => {
    setYukleniyor(true);
    setListeHatasi(null);
    try {
      const parcalar: Kosul[] = [];
      if (sabitFiltre) parcalar.push(sabitFiltre);
      if (metin.trim()) {
        parcalar.push({
          op: 'or',
          kosullar: alanlar.map(a => ({ alan: a.ad, op: 'icerir', deger: metin.trim() })),
        });
      }
      const filtre = parcalar.length === 0 ? undefined
        : parcalar.length === 1 ? parcalar[0]
        : { op: 'and' as const, kosullar: parcalar };

      const yanit = await api.liste(kaynak, { sayfa: 1, boyut: 25, filtre });
      setSatirlar(yanit.satirlar);
      setSecili(0);
    } catch (h) {
      setListeHatasi(h instanceof ApiHatasi ? h.message : String(h));
      setSatirlar([]);
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, alanlar, sabitFiltre]);

  useEffect(() => {
    if (!acik) return;
    void ara(arama);
  }, [acik, arama, ara]);

  useEffect(() => {
    if (acik) { setTimeout(() => kutu.current?.focus(), 0); return }
    // Kapaninca arama sifirlanir: bir sonraki acilis eski metinle acilmasin.
    setArama('');
    setSatirlar([]);
  }, [acik]);

  const yaz = (metin: string) => {
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => setArama(metin), 300);
  };

  const sec = (satir: ListeSatiri) => {
    onSec(satir);
    setAcik(false);
    setArama('');
  };

  /** Klavyeyle calisma: ok tuslari + Enter (fatura kesme hizinin kabul olcutu var). */
  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(s => Math.min(s + 1, satirlar.length - 1)) }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(s => Math.max(s - 1, 0)) }
    else if (e.key === 'Enter' && satirlar[secili]) { e.preventDefault(); sec(satirlar[secili]) }
    else if (e.key === 'Escape') { setAcik(false) }
  };

  return (
    <div className="lookup">
      {etiket && <span className="etiket">{etiket}{zorunlu && <b className="zorunlu"> *</b>}</span>}

      <div className="lookup-kutu">
        {/* readOnly input'ta tiklama guvenilir degil (imlec/secim davranisi tarayiciya
            gore degisiyor); acmayi onMouseDown ustlenir, klavye icin Enter/F4 kalir. */}
        <input
          readOnly
          value={deger ?? ''}
          placeholder="Seciniz…"
          disabled={saltOkunur}
          onMouseDown={e => { if (!saltOkunur) { e.preventDefault(); setAcik(true) } }}
          onKeyDown={e => { if (!saltOkunur && (e.key === 'Enter' || e.key === 'F4')) { e.preventDefault(); setAcik(true) } }}
        />
        {!saltOkunur && deger && (
          <button type="button" className="mini" title="Temizle" onClick={() => onSec(null)}>×</button>
        )}
        {!saltOkunur && (
          <button type="button" className="mini" title="Ara (F4)" onClick={() => setAcik(true)}>…</button>
        )}
      </div>

      {hata && <span className="alan-hata">{hata}</span>}

      {acik && (
        <>
          <div className="perde" onClick={() => setAcik(false)} />
          {/* Pencere duzeni CARI/STOK ARAMASIYLA AYNI (kullanici): sol ustte
              Seç, sag ustte Kapat, arama kutusu oval, satir basinda isaret
              kutusu. Ayni is (listeden secim) her ekranda ayni gorunsun -
              hesap/depo/proje aramasi ayri bir bicimdeydi. */}
          <div className="lookup-pencere" onKeyDown={tus}>
            <div className="lookup-cubuk">
              <button type="button" className="d bir" disabled={!satirlar[secili]}
                      onClick={() => satirlar[secili] && sec(satirlar[secili])}>
                Seç
              </button>
              <span style={{ flex: 1 }} />
              <button type="button" className="d kapat-dugmesi"
                      onClick={() => setAcik(false)}>Kapat</button>
            </div>

            <div className="cipler" style={{ margin: 0 }}>
              <div className="ara" style={{
                maxWidth: 260, margin: 0, height: 23, borderRadius: 12,
                background: 'var(--yuz)', color: 'var(--yazi)', border: '1px solid var(--cizgi)',
              }}>
                <span>🔍</span>
                <input
                  ref={kutu}
                  style={{ border: 0, background: 'transparent', outline: 'none',
                           width: '100%', color: 'inherit' }}
                  placeholder="Ara…"
                  defaultValue=""
                  onChange={e => yaz(e.target.value)}
                />
              </div>
            </div>

            {listeHatasi && <div className="hata-kutusu">{listeHatasi}</div>}

            <div className="lookup-liste">
              <table>
                <thead>
                  <tr>
                    <th className="check" />
                    {alanlar.map(a => <th key={a.ad} className={a.genis ? 'genis' : ''}>{a.baslik}</th>)}
                  </tr>
                </thead>
                <tbody>
                  {satirlar.map((satir, i) => (
                    <tr
                      key={String(satir.id ?? i)}
                      className={i === secili ? 'secili' : ''}
                      onMouseEnter={() => setSecili(i)}
                      onClick={() => sec(satir)}
                    >
                      {/* Isaret kutusu SECILI SATIRI gosterir; tikla = sec
                          (cari aramasindaki davranisin aynisi). */}
                      <td className="hiza-orta" onClick={e => e.stopPropagation()}>
                        <input type="checkbox" checked={i === secili} readOnly
                               onChange={() => sec(satir)} />
                      </td>
                      {alanlar.map(a => <td key={a.ad}>{String(satir[a.ad] ?? '')}</td>)}
                    </tr>
                  ))}
                  {!yukleniyor && satirlar.length === 0 && (
                    <tr><td colSpan={alanlar.length + 1} className="bos">Kayıt yok</td></tr>
                  )}
                </tbody>
              </table>
              {yukleniyor && <div className="yukleniyor">Aranıyor…</div>}
            </div>

            <div className="lookup-alt">
              <span>↑↓ gez · Enter seç · Esc kapat</span>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

/** Sik kullanilan iki lookup icin hazir alan kumeleri. */
export const LOOKUP_CARI = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'unvan', baslik: 'Unvan', genis: true },
  { ad: 'vkno', baslik: 'VKN/TCKN' },
];

export const LOOKUP_STOK = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'ad', baslik: 'Stok Adi', genis: true },
  { ad: 'kdv', baslik: 'KDV' },
];
