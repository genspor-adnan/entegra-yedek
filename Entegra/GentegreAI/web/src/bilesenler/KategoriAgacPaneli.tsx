import { useCallback, useEffect, useMemo, useState } from 'react';
import { altAgac as altAgacHesapla } from './kategoriAgaci';
import { api } from '../api/istemci';
import { guvenli } from './mesaj';

/**
 * KATEGORİ AĞACI PANELİ (kullanıcı: "hizmet listesi de kategori ağacına bağlı
 * açılır kapanır olsun").
 *
 * Listenin SOLUNDA duran ağaç: dal seçilince liste o dalın ALT AĞACIYLA
 * birlikte süzülür - üst dal seçen kullanıcı altındaki her şeyi görmek ister.
 * Ağaç KAPALI açılır (Kategoriler ekranıyla aynı davranış): büyük ağaçta
 * ekran köklerle başlasın.
 *
 * Seçili dal yeniden tıklanınca süzgeç kalkar - "tümünü göster" için ayrı
 * düğme aramak gerekmesin.
 */
type Kategori = { id: number; kod: string; ad: string; ustId: number | null; tur: number };

export function KategoriAgacPaneli({ tur, secili, onSec, sayacAlani }: {
  /** 1 stok · 2 hizmet (346). */
  tur: number;
  secili: number | null;
  onSec(id: number | null, altAgac: number[]): void;
  /** Satırda gösterilecek sayaç: 'stokSayisi' | 'hizmetSayisi'. */
  sayacAlani?: 'stokSayisi' | 'hizmetSayisi';
}) {
  const [kayitlar, setKayitlar] = useState<(Kategori & { sayi: number })[]>([]);
  const [acik, setAcik] = useState<Set<number>>(new Set());

  useEffect(() => {
    void guvenli(async () => {
      const y = await api.liste('kategori', { sayfa: 1, boyut: 1000 });
      setKayitlar((y.satirlar ?? [])
        .map(s => ({
          id: Number(s.id), kod: String(s.kod ?? ''), ad: String(s.ad ?? ''),
          ustId: s.ustId === null || s.ustId === undefined ? null : Number(s.ustId),
          tur: Number(s.tur ?? 1),
          sayi: Number(s[sayacAlani ?? 'hizmetSayisi'] ?? 0),
        }))
        .filter(k => k.tur === tur));
    });
  }, [tur, sayacAlani]);

  const cocuklar = useMemo(() => {
    const harita = new Map<number, (Kategori & { sayi: number })[]>();
    kayitlar.slice()
      .sort((a, b) => a.kod.localeCompare(b.kod, 'tr') || a.ad.localeCompare(b.ad, 'tr'))
      .forEach(k => {
        const ust = k.ustId ?? 0;
        harita.set(ust, [...(harita.get(ust) ?? []), k]);
      });
    return harita;
  }, [kayitlar]);

  const altAgac = useCallback(
    (id: number) => altAgacHesapla(id, kayitlar), [kayitlar]);

  const dal = (k: Kategori & { sayi: number }, derinlik: number): React.ReactNode => {
    const altlar = cocuklar.get(k.id) ?? [];
    const acikMi = acik.has(k.id);
    return (
      <div key={k.id}>
        <div className={`kat-satir${secili === k.id ? ' on' : ''}`}
             style={{ paddingLeft: 6 + derinlik * 22, height: 20, lineHeight: '18px', whiteSpace: 'nowrap' }}
             title={k.kod}
             onClick={() => (secili === k.id ? onSec(null, []) : onSec(k.id, altAgac(k.id)))}>
          {altlar.length > 0 ? (
            <span className="ok" style={{ flex: '0 0 16px', width: 16, height: 16, overflow: 'hidden', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontSize: 14, lineHeight: 1, color: 'var(--yazi2)', cursor: 'pointer' }} onClick={e => {
              e.stopPropagation();
              setAcik(s => {
                const y = new Set(s);
                if (y.has(k.id)) y.delete(k.id); else y.add(k.id);
                return y;
              });
            }}>{acikMi ? '▾' : '▸'}</span>
          ) : <span className="ok bos" style={{ flex: '0 0 16px', width: 16, height: 16, visibility: 'hidden' }} />}
          <span className="ad" style={{ flex: 1, minWidth: 0, overflow: 'hidden',
                                        textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {k.ad}
          </span>
          {k.sayi > 0 && (
            <span className="sonuk sayi" style={{ flex: 'none', marginLeft: 8 }}>{k.sayi}</span>
          )}
        </div>
        {acikMi && altlar.map(a => dal(a, derinlik + 1))}
      </div>
    );
  };

  const kokler = cocuklar.get(0) ?? [];

  return (
    <div className="kat-panel">
      <div className="kat-panel-bas">
        <b>Kategoriler</b>
        {secili !== null && (
          <span className="minibtn" onClick={() => onSec(null, [])}>✖ Süzgeci kaldır</span>
        )}
      </div>
      <div className="kat-panel-agac">
        {kokler.length === 0 && <div className="not">Kategori yok.</div>}
        {kokler.map(k => dal(k, 0))}
      </div>
    </div>
  );
}
