import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { type ListeSatiri, hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';

/**
 * KASA / BANKA / POS HESABI SECIMI (kullanici: "banka ise modal arama ile
 * seçilmeli yine pos da modal arama ile seçilmeli").
 *
 * Belge kartinin Tahsilat sekmesinde hizli tahsilat icin kullanilir: hesap
 * secilince kasa karti ACILMADAN satir eklenir. Combo yerine ARAMA penceresi
 * cunku banka hesaplari onlarca satir (38 banka, 13 POS) - hangi hesabin
 * hangi sube/IBAN oldugu ancak listede secilebiliyor.
 */
export function HesapSecModali({ tur, baslik, doviz, onSec, onKapat }: {
  /** hesap.tur: 'K' kasa · 'B' banka · 'P' POS. */
  tur: 'K' | 'B' | 'P';
  baslik: string;
  /**
   * YALNIZ BU PARA BIRIMINDEKI hesaplar (kullanici): hizli tahsilat yerel
   * parada calisir - USD/EUR kasa ve POS listeye girerse secilen hesabin
   * dovizi islemle uyusmaz ve sunucu reddeder.
   */
  doviz?: string;
  onSec(h: { id: number; ad: string }): void;
  onKapat(): void;
}) {
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);
  const kutu = useRef<HTMLInputElement>(null);
  const zamanlayici = useRef<number | undefined>(undefined);

  const ara = useCallback(async (metin: string) => {
    setYukleniyor(true);
    try {
      const y = await api.liste('hesap', {
        sayfa: 1, boyut: 50,
        sirala: [{ alan: 'kod', yon: 'asc' }],
        filtre: { op: 'and', kosullar: [
          { alan: 'tur', op: 'esit', deger: tur },
          // PASIF hesap secilemez - kapatilmis kasa/banka listede durmasin.
          { alan: 'durum', op: 'esit', deger: 1 },
          ...(doviz ? [{ alan: 'dovizCinsi', op: 'esit' as const, deger: doviz }] : []),
          // Serbest metin: kod ya da ad icinde arar (liste ucunda "ara" alani
          //   yok, kosul olarak gonderilir).
          ...(metin ? [{ op: 'or' as const, kosullar: [
            { alan: 'kod', op: 'icerir' as const, deger: metin },
            { alan: 'ad',  op: 'icerir' as const, deger: metin },
          ] }] : []),
        ] },
      });
      setSatirlar(y.satirlar);
      setSecili(0);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)); setSatirlar([]) }
    finally { setYukleniyor(false) }
  }, [tur, doviz]);

  useEffect(() => { void ara('') }, [ara]);
  useEffect(() => { kutu.current?.focus() }, []);

  const yaz = (metin: string) => {
    setArama(metin);
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => void ara(metin), 250);
  };

  const sec = (r: ListeSatiri) =>
    onSec({ id: Number(r.id), ad: String(r.ad ?? '') });

  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(i => Math.min(i + 1, satirlar.length - 1)) }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(i => Math.max(i - 1, 0)) }
    else if (e.key === 'Enter' && satirlar[secili]) { e.preventDefault(); sec(satirlar[secili]) }
  };

  return (
    <Modal baslik={baslik} dar onKapat={onKapat}
           alt={<button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>}>
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="kagrup">
          <div className="cipler" style={{ margin: 10 }}>
            <input ref={kutu} value={arama} onChange={e => yaz(e.target.value)}
                   onKeyDown={tus} placeholder="Kod / ad ara…"
                   style={{ width: '100%' }} />
          </div>

          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th style={{ width: 150 }}>Kod</th>
                <th>Hesap</th>
                <th className="hiza-orta" style={{ width: 70 }}>Döviz</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map((r, i) => (
                <tr key={String(r.id)} className={i === secili ? 'secili' : ''}
                    onClick={() => sec(r)}>
                  <td><code>{String(r.kod ?? '')}</code></td>
                  <td>{String(r.ad ?? '')}</td>
                  <td className="hiza-orta">{String(r.dovizCinsi ?? 'TL')}</td>
                </tr>
              ))}
              {satirlar.length === 0 && (
                <tr><td colSpan={3} className="bos">
                  {yukleniyor ? 'Yükleniyor…' : 'Kayıt yok.'}
                </td></tr>
              )}
            </tbody>
          </table>
          <div className="not">
            Enter seçer, ↑ ↓ satır gezer. Seçilen hesapla tahsilat satırı
            <b> kart açılmadan</b> eklenir; tutar gridde değiştirilebilir.
          </div>
        </div>
      </>
    </Modal>
  );
}
