import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import type { EmarDoz, EmarOrder, EmarYaniti } from '../../api/uclar/yatan';
import { guvenli, mesaj } from '../mesaj';
import { DozUygulamaModali } from './DozUygulamaModali';

/**
 * eMAR ÇİZELGESİ — mockup `Ekranlar/Yatan/order_ilac_uygulama.html`.
 *
 * <b>Satır order, sütun saat.</b> İlaç takibi "verildi mi" sorusudur ve bu soru
 * ancak SAATLE birlikte sorulur: düz liste "günde üç kez verilecek" der,
 * "16:00 atlandı"yı söylemez. Altındaki grid doz kuyruğunu (servis geneli)
 * gösterir; çizelge ise TEK HASTANIN günüdür — ikisi aynı veriyi iki ayrı
 * soruya cevap verecek biçimde gösteriyor.
 *
 * <b>Hücreler sunucudan gelen PLANLANAN dozlardır</b> (698 tetikleyicisi
 * üretir). İstemci saat üretmiyor: "plan" ile "kayıt" iki ayrı yerde
 * hesaplansaydı, ekranda görünen doz veritabanında olmayabilirdi.
 */

const DURUM_SINIF: Record<number, string> = {
  1: 'bekle', 2: 'ok', 3: 'atla', 4: 'atla', 5: 'gec',
};
const DURUM_IM: Record<number, string> = {
  1: '○', 2: '✓', 3: '⤫', 4: '⤫', 5: '⏰',
};

const ss = (t: string) => new Date(t).toTimeString().slice(0, 5);

interface YatisSecenegi { id: number; hasta: string; yatak: string }

export function EmarCizelgesi({ yenile, onDegisti }: {
  yenile?: number;
  onDegisti?(): void;
}) {
  const [yatislar, setYatislar] = useState<YatisSecenegi[]>([]);
  const [yatisId, setYatisId] = useState<number | null>(null);
  const [gun, setGun] = useState(() => new Date().toISOString().slice(0, 10));
  const [veri, setVeri] = useState<EmarYaniti | null>(null);
  const [secili, setSecili] = useState<{ doz: EmarDoz; order: EmarOrder } | null>(null);

  // YATIŞ LİSTESİ gridin kendi kaynağından gelir: ikinci bir uç açmak, aynı
  //   ekranda iki farklı "yatan hasta" listesi üretmenin en kısa yoluydu.
  useEffect(() => {
    void (async () => {
      try {
        const y = await api.liste('yatan', {
          sayfa: 1, boyut: 200,
          filtre: { alan: 'durum', op: 'icinde', deger: [1, 2, 3] },
        });
        const satirlar = y.satirlar.map(s => ({
          id: Number(s.id),
          hasta: String(s.hasta ?? ''),
          yatak: String(s.yatak ?? ''),
        }));
        setYatislar(satirlar);
        setYatisId(o => o ?? (satirlar[0]?.id ?? null));
      } catch { /* liste yoksa çizelge de yok */ }
    })();
  }, []);

  const yukle = useCallback(async () => {
    if (!yatisId) { setVeri(null); return }
    try { setVeri(await api.emar(yatisId, gun)) } catch { setVeri(null) }
  }, [yatisId, gun]);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  // SÜTUNLAR O GÜNÜN GERÇEK SAATLERİNDEN çıkar: sabit 24 sütun, üç dozluk bir
  //   hastada ekranın yarısını boş çizerdi.
  const saatler = useMemo(() => {
    const k = new Set<string>();
    for (const d of veri?.dozlar ?? []) k.add(ss(d.planlanan));
    return [...k].sort();
  }, [veri]);

  if (yatislar.length === 0) return null;

  const o = veri?.ozet;
  const secim = yatislar.find(y => y.id === yatisId);

  const imzala = async (orderId: number) => {
    await guvenli(async () => {
      await api.orderImzala(orderId);
      mesaj('Sözel order imzalandı.');
      await yukle();
      onDegisti?.();
    });
  };

  return (
    <div className="emar">
      <div className="emar-serit">
        <label>Hasta
          <select value={yatisId ?? ''} onChange={e => setYatisId(Number(e.target.value))}>
            {yatislar.map(y => (
              <option key={y.id} value={y.id}>{y.yatak ? `${y.yatak} · ` : ''}{y.hasta}</option>
            ))}
          </select>
        </label>
        <label>Gün
          <input type="date" value={gun} onChange={e => setGun(e.target.value)} />
        </label>
        {o && (
          <div className="emar-ozet">
            <span><b>{o.toplam}</b> doz</span>
            <span className="ok"><b>{o.uygulanan}</b> uygulandı</span>
            <span><b>{o.bekleyen}</b> bekleyen</span>
            {o.geciken > 0 && <span className="teh"><b>{o.geciken}</b> geciken</span>}
            {o.atlanan > 0 && <span className="uy"><b>{o.atlanan}</b> atlanan</span>}
            {/* BARKODSUZ UYGULAMA görünür kalır: engellenmiyor ama sayılıyor. */}
            {o.barkodsuz > 0 && (
              <span className="uy" title="Barkod okutulmadan kaydedilen doz">
                <b>{o.barkodsuz}</b> elle doğrulanmış
              </span>
            )}
            {o.imzasizSozel > 0 && (
              <span className="teh"><b>{o.imzasizSozel}</b> imzasız sözel order</span>
            )}
          </div>
        )}
      </div>

      {veri && veri.orderlar.length === 0 && (
        <div className="sonuk" style={{ padding: 10 }}>
          Bu hastada {gun} için order yok.
        </div>
      )}

      {veri && veri.orderlar.length > 0 && (
        <div className="emar-tablo">
          <table>
            <thead>
              <tr>
                <th style={{ width: 300 }}>Order</th>
                <th style={{ width: 120 }}>Doz / yol</th>
                {saatler.map(s => <th key={s} className="saat">{s}</th>)}
                <th style={{ width: 140 }}>Son uygulayan</th>
              </tr>
            </thead>
            <tbody>
              {veri.orderlar.map(od => (
                <tr key={od.id}>
                  <td>
                    <span className="ilac-ad">{od.ad}</span>
                    <div className="ilac-alt">
                      {od.turAd}
                      {od.siklik && <> · {od.siklik}</>}
                      {od.hekim && <> · {od.hekim}</>}
                      {/* SÖZEL ORDER UYGULANIR ama imzasız kalmaz: rozet
                          hekim imzalayana kadar durur ve taburcuyu engeller. */}
                      {od.sozelOrder && !od.imzali && (
                        <>
                          {' '}
                          <span className="rozet hata">sözel · imza bekliyor</span>
                          <button className="d kucuk" style={{ marginLeft: 4 }}
                                  onClick={() => void imzala(od.id)}>✍ İmzala</button>
                        </>
                      )}
                      {od.durum !== 1 && <> <span className="rozet pas">kapandı</span></>}
                    </div>
                  </td>
                  <td>{od.doz ?? '—'} {od.birim}{od.yolAd && ` · ${od.yolAd}`}</td>
                  {saatler.map(s => {
                    const d = veri.dozlar.find(
                      x => x.orderId === od.id && ss(x.planlanan) === s);
                    if (!d) return <td key={s} className="saat"><span className="doz yok">—</span></td>;
                    return (
                      <td key={s} className="saat">
                        <span className={`doz ${DURUM_SINIF[d.durum] ?? ''}`}
                              title={d.atlamaNedeni || d.gecikmeNedeni
                                     || (d.elleDogrulandi && d.durum === 2
                                         ? 'Elle doğrulandı (barkodsuz)' : '')}
                              onClick={() => { if (d.durum !== 2) setSecili({ doz: d, order: od }) }}>
                          {DURUM_IM[d.durum] ?? ''}
                          <b>{d.durum === 2 && d.uygulanan ? ss(d.uygulanan) : s}</b>
                          {d.durum === 2 && d.elleDogrulandi && <i>elle</i>}
                        </span>
                      </td>
                    );
                  })}
                  <td className="sonuk">{od.sonUygulayan || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <div className="not">
        <b>Satır order, sütun saat.</b> Uygulama satırları order kaydedilirken
        <b> önceden üretilir</b> — plan görünmeden takip olmaz, sonradan üretilen satır
        atlanmış dozu gizler. Hücreye tıklayınca uygulama penceresi açılır.
      </div>

      {secili && secim && (
        <DozUygulamaModali
          doz={secili.doz}
          order={secili.order}
          hasta={`${secim.hasta}${secim.yatak ? ` · ${secim.yatak}` : ''}`}
          onKapat={() => setSecili(null)}
          onTamam={() => { void yukle(); onDegisti?.() }}
        />
      )}
    </div>
  );
}
