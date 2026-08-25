import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type ListeSatiri } from '../api/sozlesme';
import { GenForm } from './GenForm';

interface TarafSatiri {
  kaynak: string;
  id: number;
  tip: string;
  kod: string;
  unvan: string;
  bagliKurum: string;
  gorevRol: string;
}

const tipEtiketi = (kaynak: string, s: ListeSatiri): string => {
  if (kaynak === 'kisi') return 'Kişi';
  if (kaynak === 'personel') return 'Personel';
  if (kaynak === 'hasta') return 'Hasta';
  const musteri = Number(s.musteri) === 1;
  const tedarikci = Number(s.tedarikci) === 1;
  if (musteri && tedarikci) return 'Müşteri/Tedarikçi';
  if (musteri) return 'Müşteri';
  if (tedarikci) return 'Tedarikçi';
  // Henuz musteri olmayan ADAY (122): tip sutununda "cari" yazmasi
  //   kullaniciya hicbir sey soylemiyordu.
  if (Number(s.aday) === 1) return 'Aday';
  return kaynak;
};

const satiraCevir = (kaynak: string, s: ListeSatiri): TarafSatiri => ({
  kaynak,
  id: Number(s.id),
  tip: tipEtiketi(kaynak, s),
  kod: String(s.kod ?? ''),
  unvan: String(s.unvan ?? ''),
  bagliKurum: String(s.bagliCari ?? ''),
  gorevRol: String(s.gorev ?? ''),
});

interface Props {
  acik: boolean;
  /** Aranacak taraf-tabanli kaynaklar (varsayilan: cari + kisi). */
  kaynaklar?: string[];
  yerTutucu?: string;
  onKapat(): void;
  onSec(secilen: { kaynak: string; id: number; unvan: string }): void;
}

/**
 * Genel taraf arama/secim modali - taraf-tabanli her kaynakta (cari, kisi, ileride
 * personel/hasta) kullanilabilir tek bilesen (kullanici: "bu arama ekrani genel olacak,
 * her yerde kullanilacak, jenerik yap"). GenLookup'tan farki: GenLookup TEK kaynakta arar
 * ve alan icine gomulu kucuk bir tetikleyicidir; TarafArama BIRDEN FAZLA kaynagi BIRLIKTE
 * arar (Tip/Bağlı Kurum/Görev-Rol gibi taraf-ortak kolonlarla) ve disaridan (ör. toolbar
 * butonu) acik/kapali kontrol edilir (`acik` prop) - kendi tetikleyicisi yok.
 */
export function TarafArama({ acik, kaynaklar = ['cari', 'kisi'], yerTutucu, onKapat, onSec }: Props) {
  /** Kutuda yazan metin (aninda) - `arama` bunun gecikmeli (debounce) hali. */
  const [metin, setMetin] = useState('');
  const [arama, setArama] = useState('');
  /** Tum Liste / Son Aranan / Sik Aranan - liste ekranlariyla ayni (kullanici_arama). */
  const [gorunum, setGorunum] = useState<'tum' | 'son' | 'sik'>('tum');
  const [satirlar, setSatirlar] = useState<TarafSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);
  // Yeni/Duzenle - cari-liste'deki gibi. Sadece TEK kaynakla aranirken (ör. kaynaklar=['kisi'])
  // anlamli, kullanici hangi TIP olusturacagini secemeyecegi icin karisik aramada gizli.
  const [kartAcik, setKartAcik] = useState<{ kaynak: string; id: number | 'yeni' } | null>(null);
  const zamanlayici = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  const ara = useCallback(async (metin: string, gorunumSecimi: 'tum' | 'son' | 'sik' = 'tum') => {
    setYukleniyor(true);
    setHata(null);
    try {
      const filtre = metin.trim()
        ? { op: 'or' as const, kosullar: [
            { alan: 'kod', op: 'icerir' as const, deger: metin.trim() },
            { alan: 'unvan', op: 'icerir' as const, deger: metin.trim() },
          ] }
        : undefined;
      // gorunum: Son/Sik Aranan sunucuda kullanici_arama ile suzulur+siralanir.
      const gorunumParam = gorunumSecimi === 'tum' ? undefined : gorunumSecimi;
      const yanitlar = await Promise.all(
        kaynaklar.map(k => api.liste(k, { sayfa: 1, boyut: 20, filtre, gorunum: gorunumParam })));
      setSatirlar(yanitlar.flatMap((y, i) => y.satirlar.map(s => satiraCevir(kaynaklar[i], s))));
      setSecili(0);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      setSatirlar([]);
    } finally {
      setYukleniyor(false);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kaynaklar.join(',')]);

  useEffect(() => {
    if (!acik) return;
    void ara(arama, gorunum);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acik, arama, gorunum, ara]);

  useEffect(() => {
    if (acik) { setTimeout(() => kutu.current?.focus(), 0); return }
    setMetin('');
    setArama('');
    setGorunum('tum');
    setSatirlar([]);
  }, [acik]);

  const yaz = (yeni: string) => {
    setMetin(yeni);
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => setArama(yeni), 300);
  };

  const sec = (satir: TarafSatiri) => {
    // Secim "Son / Sik Aranan" sayacina islensin - listede oldugu gibi.
    void api.aramaIsaretle(satir.kaynak, satir.id);
    onSec({ kaynak: satir.kaynak, id: satir.id, unvan: satir.unvan });
    onKapat();
  };

  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(s => Math.min(s + 1, satirlar.length - 1)) }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(s => Math.max(s - 1, 0)) }
    else if (e.key === 'Enter' && satirlar[secili]) { e.preventDefault(); sec(satirlar[secili]) }
    else if (e.key === 'Escape') { onKapat() }
  };

  if (!acik) return null;

  // Kart acikken (Yeni/Duzenle) arama penceresi GIZLI ama state korunuyor - kart kapaninca
  // (Kaydet/Kapat) ayni aramaya donulur + liste yenilenir (yeni/degisen kayit gorunsun).
  if (kartAcik) {
    return (
      <GenForm
        kaynak={kartAcik.kaynak}
        id={kartAcik.id}
        cariyeBaglaGizli
        onKapat={() => { setKartAcik(null); void ara(arama) }}
        onKaydedildi={() => { setKartAcik(null); void ara(arama) }}
      />
    );
  }

  return (
    <>
      {/* z-index inline: kart modali (.kaperde) 320'de - GenLookup'in .perde/.lookup-pencere
          varsayilan z-index'i (20/21) bunun ICINDE acilinca modalin ARKASINDA kalirdi. */}
      <div className="perde" onClick={onKapat} style={{ zIndex: 400 }} />
      <div className="lookup-pencere taraf-arama" onKeyDown={tus} style={{ width: 'min(880px, 92vw)', zIndex: 401 }}>
        {/* Ust arac cubugu (cari-liste ile ayni desen): Yeni/Duzenle sadece tek-kaynakli
            aramada (kaynaklar.length===1) - kullanici hangi TIP olusturulacagini secemez. */}
        <div className="lookup-cubuk">
          {kaynaklar.length === 1 && (
            <>
              <button type="button" className="d" onClick={() => setKartAcik({ kaynak: kaynaklar[0], id: 'yeni' })}>
                ＋ Yeni
              </button>
              <button type="button" className="d" disabled={!satirlar[secili]}
                onClick={() => satirlar[secili] && setKartAcik({ kaynak: satirlar[secili].kaynak, id: satirlar[secili].id })}>
                ✎ Düzenle
              </button>
            </>
          )}
          <button type="button" className="d bir" disabled={!satirlar[secili]}
            onClick={() => satirlar[secili] && sec(satirlar[secili])}>
            Seç
          </button>
          <button type="button" className="d kapat-dugmesi" onClick={onKapat}>Kapat</button>
        </div>

        {/* Arama kutusu ve Liste/Son/Sik dugmeleri LISTE EKRANLARIYLA ayni
            (GenGrid deseni) - ayni arac her yerde ayni gorunsun. */}
        <div className="cipler" style={{ margin: 0 }}>
          <div className="ara" style={{
            maxWidth: 260, margin: 0, height: 23, borderRadius: 12,
            background: 'var(--yuz)', color: 'var(--yazi)', border: '1px solid var(--cizgi)',
          }}>
            <span>🔍</span>
            <input
              ref={kutu}
              style={{ border: 0, background: 'transparent', outline: 'none', width: '100%', color: 'inherit' }}
              placeholder={yerTutucu ?? 'Ara…'}
              value={metin}
              onChange={e => yaz(e.target.value)}
            />
          </div>

          <div className="durumseg">
            <button type="button" className={`ikon-liste ${gorunum === 'tum' ? 'on' : ''}`}
                    title="Tüm Liste" onClick={() => setGorunum('tum')}>☰</button>
            <button type="button" className={`ikon-liste ${gorunum === 'son' ? 'on' : ''}`}
                    title="Son Aranan" onClick={() => setGorunum('son')}>🕓</button>
            <button type="button" className={`ikon-liste ${gorunum === 'sik' ? 'on' : ''}`}
                    title="Sık Aranan" onClick={() => setGorunum('sik')}>⭐</button>
          </div>
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="lookup-liste">
          <table>
            <thead>
              <tr>
                <th className="check"></th>
                <th className="dar">Tip</th>
                <th className="dar">Kod</th>
                <th className="genis">Unvan</th>
                <th className="bagli-kurum">Bağlı Kurum</th>
                <th className="dar">Görev/Rol</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map((satir, i) => (
                <tr
                  key={`${satir.kaynak}-${satir.id}`}
                  className={i === secili ? 'secili' : ''}
                  onDoubleClick={() => sec(satir)}
                  onClick={() => setSecili(i)}
                >
                  <td className="check"><input type="checkbox" checked={i === secili} readOnly /></td>
                  <td>{satir.tip}</td>
                  <td>{satir.kod}</td>
                  <td>{satir.unvan}</td>
                  <td>{satir.bagliKurum}</td>
                  <td>{satir.gorevRol}</td>
                </tr>
              ))}
              {!yukleniyor && satirlar.length === 0 && (
                <tr><td colSpan={6} className="bos">Kayit yok</td></tr>
              )}
            </tbody>
          </table>
          {yukleniyor && <div className="yukleniyor">Araniyor…</div>}
        </div>

        <div className="lookup-alt">
          <span>↑↓ gez · çift tık/Enter seç · Esc kapat</span>
        </div>
      </div>
    </>
  );
}

/**
 * GENEL KURAL (kullanici): cari/kisi/personel secimi UYGULAMANIN HER YERINDE
 * ayni ekrandan yapilir. Bu bilesen alan + TarafArama modalini birlikte verir:
 * salt-okunur kutu, sagindaki "…" dugmesi ve modal. GenLookup'un kucuk kendi
 * penceresi yerine bunu kullanin.
 */
export function TarafSecici({
  etiket, deger, kilitli, zorunlu, hata, kaynaklar = ['cari'], yerTutucu, ipucu,
  otomatikAc = false, onSec, onTemizle,
}: {
  etiket: string;
  deger?: string;
  kilitli?: boolean;
  zorunlu?: boolean;
  hata?: string;
  kaynaklar?: string[];
  yerTutucu?: string;
  ipucu?: string;
  /** Acilista modali kendiliginden ac (ör. yeni belgede "kime?" sorusu). */
  otomatikAc?: boolean;
  onSec(secilen: { kaynak: string; id: number; unvan: string }): void;
  /** Verilirse "×" dugmesi cikar ve secimi bosaltir. */
  onTemizle?(): void;
}) {
  const [acik, setAcik] = useState(otomatikAc);

  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <span className="lookup-kutu">
        <input readOnly value={deger ?? ''} placeholder="Seçiniz…" disabled={kilitli}
               onMouseDown={e => { if (!kilitli) { e.preventDefault(); setAcik(true) } }} />
        {!kilitli && onTemizle && deger && (
          <button type="button" className="mini" title="Boşalt"
                  onClick={onTemizle}>×</button>
        )}
        {!kilitli && (
          <button type="button" className="mini" title={ipucu ?? `${etiket} ara`}
                  onClick={() => setAcik(true)}>…</button>
        )}
      </span>
      {hata && <span className="alan-hata">{hata}</span>}

      <TarafArama
        acik={acik}
        kaynaklar={kaynaklar}
        yerTutucu={yerTutucu}
        onKapat={() => setAcik(false)}
        onSec={sec => { onSec(sec); setAcik(false) }}
      />
    </label>
  );
}
