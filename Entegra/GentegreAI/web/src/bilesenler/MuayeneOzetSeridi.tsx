import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * MUAYENE LİSTESİ ÖZET ŞERİDİ (461) — mockup
 * `Ekranlar/Muayene/muayene_listesi.html` üstündeki altı kutu: polikliniğin o
 * günkü hâli.
 *
 * <b>Tek uçtan gelir</b> (`/api/muayene/ozet`): altı ayrı istek ekranın
 * yarısını dolu yarısını boş gösterirdi (radyoloji/lab panosu deseni).
 *
 * <b>Sayılar tıklanmaz</b> - liste zaten aşağıda ve kendi çipleriyle
 * süzülüyor; şerit "bugün ne durumdayız" sorusunu cevaplar, ikinci bir
 * süzgeç katmanı değildir.
 */

type Ozet = {
  gun: string;
  sayac: { muayene: number; acik: number; tamamlanan: number; ortDk: number;
           bekleyen: number; enUzunBeklemeDk: number; tanisiz: number };
  sonuc: { lab: number; radyoloji: number; bekleyenTetkik: number };
  enabiz: { toplam: number; gonderilen: number };
  randevu: { randevu: number; gelmedi: number };
};

const dk = (v: number) => (v > 0 ? `${Math.round(v)} dk` : '—');

export function MuayeneOzetSeridi() {
  const [o, setO] = useState<Ozet | null>(null);

  const yukle = useCallback(async () => {
    try { setO(await api.muayeneOzet() as unknown as Ozet) }
    catch { /* serit zorunlu degil */ }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  const s = o?.sayac;
  const kutular: { b: string; d: string; e?: string; vurgu?: 'teh' | 'uy' }[] = [
    { b: 'Bugün', d: String(s?.muayene ?? 0),
      e: `${s?.acik ?? 0} açık · ${s?.tamamlanan ?? 0} tamamlandı` },
    { b: 'Randevu', d: String(o?.randevu.randevu ?? 0),
      e: (o?.randevu.gelmedi ?? 0) > 0 ? `${o?.randevu.gelmedi} gelmedi` : undefined },
    { b: 'Ort. muayene', d: dk(s?.ortDk ?? 0), e: 'tamamlananlarda' },
    { b: 'Bekleyen', d: String(s?.bekleyen ?? 0),
      e: (s?.enUzunBeklemeDk ?? 0) > 0 ? `en uzun ${dk(s!.enUzunBeklemeDk)}` : undefined,
      vurgu: (s?.bekleyen ?? 0) > 0 ? 'uy' : undefined },
    { b: 'Sonuç geldi', d: String((o?.sonuc.lab ?? 0) + (o?.sonuc.radyoloji ?? 0)),
      e: `lab ${o?.sonuc.lab ?? 0} · rad ${o?.sonuc.radyoloji ?? 0}`
         + ((o?.sonuc.bekleyenTetkik ?? 0) > 0
            ? ` · ${o?.sonuc.bekleyenTetkik} bekliyor` : '') },
    // TANISIZ TAMAMLANMIS: başvuru tahakkuka düşmez, e-Nabız paketi eksik
    //   alanda kalır - günün sonunda görülmesi gereken sayı budur.
    { b: 'Tanı girilmemiş', d: String(s?.tanisiz ?? 0), e: 'tamamlanan muayenede',
      vurgu: (s?.tanisiz ?? 0) > 0 ? 'teh' : undefined },
    { b: 'e-Nabız', d: `${o?.enabiz.gonderilen ?? 0}/${o?.enabiz.toplam ?? 0}`,
      e: 'gönderildi' },
  ];

  return (
    <div className="muayene-ozet">
      {kutular.map(k => (
        <div key={k.b} className={`mo-kutu${k.vurgu ? ' ' + k.vurgu : ''}`}>
          <div className="mo-bas">{k.b}</div>
          <div className="mo-deger">{k.d}</div>
          {k.e && <div className="mo-ek">{k.e}</div>}
        </div>
      ))}
    </div>
  );
}
