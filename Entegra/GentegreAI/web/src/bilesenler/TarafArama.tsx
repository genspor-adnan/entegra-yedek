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
  const musteri = Number(s.musteri) === 1;
  const tedarikci = Number(s.tedarikci) === 1;
  if (musteri && tedarikci) return 'Müşteri/Tedarikçi';
  if (musteri) return 'Müşteri';
  if (tedarikci) return 'Tedarikçi';
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
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<TarafSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);
  // Yeni/Duzenle - cari-liste'deki gibi. Sadece TEK kaynakla aranirken (ör. kaynaklar=['kisi'])
  // anlamli, kullanici hangi TIP olusturacagini secemeyecegi icin karisik aramada gizli.
  const [kartAcik, setKartAcik] = useState<{ kaynak: string; id: number | 'yeni' } | null>(null);
  const zamanlayici = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  const ara = useCallback(async (metin: string) => {
    setYukleniyor(true);
    setHata(null);
    try {
      const filtre = metin.trim()
        ? { op: 'or' as const, kosullar: [
            { alan: 'kod', op: 'icerir' as const, deger: metin.trim() },
            { alan: 'unvan', op: 'icerir' as const, deger: metin.trim() },
          ] }
        : undefined;
      const yanitlar = await Promise.all(
        kaynaklar.map(k => api.liste(k, { sayfa: 1, boyut: 20, filtre })));
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
    void ara(arama);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acik, arama, ara]);

  useEffect(() => {
    if (acik) { setTimeout(() => kutu.current?.focus(), 0); return }
    setArama('');
    setSatirlar([]);
  }, [acik]);

  const yaz = (metin: string) => {
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => setArama(metin), 300);
  };

  const sec = (satir: TarafSatiri) => {
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
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
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
          <button type="button" className="d" onClick={onKapat}>Kapat</button>
        </div>

        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input
            ref={kutu}
            className="arama"
            style={{ flex: 1 }}
            placeholder={yerTutucu ?? 'Ara…'}
            defaultValue=""
            onChange={e => yaz(e.target.value)}
          />
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="lookup-liste">
          <table>
            <thead>
              <tr>
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
                  onMouseEnter={() => setSecili(i)}
                  onDoubleClick={() => sec(satir)}
                  onClick={() => setSecili(i)}
                >
                  <td>{satir.tip}</td>
                  <td>{satir.kod}</td>
                  <td>{satir.unvan}</td>
                  <td>{satir.bagliKurum}</td>
                  <td>{satir.gorevRol}</td>
                </tr>
              ))}
              {!yukleniyor && satirlar.length === 0 && (
                <tr><td colSpan={5} className="bos">Kayit yok</td></tr>
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
