import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { GozHastaOzeti } from '../api/uclar/goz';
import { hataMetni } from '../api/sozlesme';
import { tarihYaz } from './bicim';

/**
 * GÖZ HASTA ÖZETİ — seçili hastanın ayrıntısı (mockup
 * `Ekranlar/Goz/goz_hasta_karti.html`).
 *
 * <b>OD ve OS YAN YANA, alt alta değil.</b> Göz hekimi iki gözü
 * karşılaştırarak okur: "sağ 0,3 sol 1,0" tek başına bir bulgudur ve tek
 * sütuna dizilmiş satırlarda bu karşılaştırma kaybolur.
 *
 * Değerler ölçümün kendisinden okunur (`/api/goz/hasta/{id}/ozet`);
 * materyalize `goz_hasta_ozet` tablosu doldurulmuyor - onu güncel tutan
 * tetikleyicilerden biri unutulduğunda özet SESSİZCE eskirdi.
 */

const HASTALIK: Record<number, string> = {
  1: 'Glokom', 2: 'Diyabetik retinopati', 3: 'AMD',
  4: 'Üveit', 5: 'Keratokonus', 6: 'Ambliyopi',
};
const PROGRESYON: Record<number, string> = { 1: 'Stabil', 2: 'Şüpheli', 3: 'Progresyon' };
const MUAYENE_TUR: Record<number, string> = {
  1: 'Tam', 2: 'Kontrol', 3: 'Postop', 4: 'Acil',
  5: 'Tarama', 6: 'Preop', 7: 'Refraktif', 8: 'Kontakt lens',
};
const ISLEM_TUR: Record<number, string> = {
  1: 'Enjeksiyon', 2: 'Lazer', 3: 'Ameliyat', 4: 'Küçük cerrahi', 5: 'Perioküler enj.',
};
const ISLEM_DURUM: Record<number, string> = {
  1: 'Planlı', 2: 'Hazır', 3: 'Uygulandı', 4: 'Ertelendi',
};
const ENJ_ILAC: Record<number, string> = {
  1: 'Aflibersept', 2: 'Ranibizumab', 3: 'Bevasizumab',
  4: 'Farisimab', 5: 'Deksametazon', 6: 'Triamsinolon',
};
const DR_EVRE: Record<number, string> = {
  0: 'R0', 1: 'R1 hafif', 2: 'R2 orta', 3: 'R3 ağır', 4: 'R4 PDR',
};
const RECETE_TUR: Record<number, string> = {
  1: 'Uzak', 2: 'Yakın', 3: 'Bifokal', 4: 'Progresif', 5: 'Ara', 6: 'Güneş',
};

const SEKMELER = ['OD / OS', 'Takip', 'Ziyaretler', 'İşlemler', 'Reçeteler'] as const;
type Sekme = typeof SEKMELER[number];

/** "-2.25 / -0.75 x 170" — optikte konuşulan biçim. */
function refYaz(sph?: number | null, cyl?: number | null, aks?: number | null) {
  if (sph == null && cyl == null) return '—';
  const s = (v: number) => (v > 0 ? '+' : '') + v.toFixed(2);
  return (sph != null ? s(sph) : '') +
         (cyl != null ? ` / ${s(cyl)}${aks != null ? ` x ${aks}` : ''}` : '');
}

export function GozHastaPaneli({ hastaId }: { hastaId: number }) {
  const [sekme, setSekme] = useState<Sekme>('OD / OS');
  const [veri, setVeri] = useState<GozHastaOzeti | null>(null);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    setVeri(null); setHata('');
    try { setVeri(await api.gozHastaOzeti(hastaId)) } catch (e) { setHata(hataMetni(e)) }
  }, [hastaId]);

  useEffect(() => { void yukle() }, [yukle]);

  const od = veri?.olcumler.find(o => o.goz === 1);
  const os = veri?.olcumler.find(o => o.goz === 2);

  /** RNFL: son ile ondan önceki ölçümün farkı — "inceliyor mu" sorusu. */
  const rnflFark = (o?: typeof od) =>
    o?.rnflSon != null && o?.rnflOnceki != null
      ? Number(o.rnflSon) - Number(o.rnflOnceki) : null;

  return (
    <div className="altpanel">
      <div className="altpanel-sekmeler">
        {SEKMELER.map(s => (
          <button type="button" key={s}
                  className={`altpanel-sekme${s === sekme ? ' on' : ''}`}
                  onClick={() => setSekme(s)}>
            {s}
            {s === 'Takip' && veri && veri.takipler.length > 0 && (
              <span className="rozet mavi">{veri.takipler.length}</span>
            )}
            {s === 'İşlemler' && veri && veri.islemler.length > 0 && (
              <span className="rozet mavi">{veri.islemler.length}</span>
            )}
          </button>
        ))}
      </div>

      <div className="altpanel-govde">
        {hata && <div className="kauyari">{hata}</div>}
        {!veri && !hata && <div className="yukleniyor">Yükleniyor…</div>}

        {/* ---------------------------------------------------- OD / OS --- */}
        {/* MOCKUP DÜZENİ (`goz_hasta_karti.html` .odos): üç kolon —
            Parametre | OD · Sağ | OS · Sol. Satır satır tablo (ölçüm, değer,
            not) göz hekiminin YAPTIĞI İŞİ bozuyordu: iki göz karşılaştırılarak
            okunur, "sağ 0,3 sol 1,0" tek başına bir bulgudur. Not sütunu da
            kalktı - açıklama değerin yanında küçük metin olarak duruyor. */}
        {veri && sekme === 'OD / OS' && (
          <div className="odos">
            <div className="h">Parametre</div>
            <div className="h od">OD · Sağ</div>
            <div className="h os">OS · Sol</div>

            <div className="l">Son BCVA</div>
            {[od, os].map((o, i) => (
              <div className="v" key={i}>
                <b>{o?.bcva != null ? Number(o.bcva).toFixed(2) : '—'}</b>
                {o?.bcvaSnellen && <span className="sonuk">({o.bcvaSnellen})</span>}
                {o?.bcvaZaman && <span className="sonuk">· {tarihYaz(o.bcvaZaman)}</span>}
              </div>
            ))}

            <div className="l">Son refraksiyon</div>
            {[od, os].map((o, i) => (
              <div className="v" key={i}>{refYaz(o?.sph, o?.cyl, o?.aks)}</div>
            ))}

            <div className="l">GİB / hedef</div>
            {[od, os].map((o, i) => (
              <div className="v" key={i}>
                {/* Bayrak ölçümde hesaplanır (>21 yüksek, >30 panik): panik
                    değeri gözle aramak, yoğun bir günde kaçırmaktır. */}
                {o?.gib == null ? <b>—</b>
                  : o.gibBayrak > 0
                    ? <span className={`rozet ${o.gibBayrak === 2 ? 'hata' : 'sari'}`}>
                        {Number(o.gib).toFixed(1)}
                      </span>
                    : <b>{Number(o.gib).toFixed(1)}</b>}
                <span className="sonuk">mmHg</span>
                {o?.hedefGib != null && (
                  <span className="sonuk">· hedef {Number(o.hedefGib).toFixed(1)}</span>
                )}
                {o?.gibZaman && <span className="sonuk">· {tarihYaz(o.gibZaman)}</span>}
              </div>
            ))}

            <div className="l">Pakimetri (CCT)</div>
            {[od, os].map((o, i) => (
              <div className="v" key={i}>
                {o?.cct != null ? <>{o.cct} <span className="sonuk">µm</span></> : '—'}
              </div>
            ))}

            <div className="l">C/D oranı (dikey)</div>
            {[od, os].map((o, i) => (
              <div className="v" key={i}>
                {o?.cdDikey == null ? '—'
                  : Number(o.cdDikey) >= 0.6
                    ? <span className="rozet sari">{Number(o.cdDikey).toFixed(2)}</span>
                    : Number(o.cdDikey).toFixed(2)}
              </div>
            ))}

            <div className="l">RNFL ort. (OCT)</div>
            {[od, os].map((o, i) => {
              const f = rnflFark(o);
              return (
                <div className="v" key={i}>
                  {o?.rnflSon == null ? '—'
                    : <><b>{Number(o.rnflSon).toFixed(1)}</b><span className="sonuk">µm</span></>}
                  {/* Tek değer "inceliyor mu"yu göstermez: önceki ölçümle fark
                      olmadan progresyon ancak iki kart açılarak anlaşılır. */}
                  {f != null && (
                    <span className={`rozet ${f <= -5 ? 'hata' : f < 0 ? 'sari' : 'ok'}`}>
                      {f > 0 ? '+' : ''}{f.toFixed(1)} µm
                    </span>
                  )}
                  {o?.rnflOncekiZaman && (
                    <span className="sonuk">· önceki {tarihYaz(o.rnflOncekiZaman)}</span>
                  )}
                </div>
              );
            })}

            <div className="l">DR / AMD evresi</div>
            {[od, os].map((o, i) => (
              <div className="v" key={i}>
                {o?.drEvre != null && <span className="rozet">{DR_EVRE[o.drEvre]}</span>}
                {o?.amdEvre ? <span className="rozet sari">AMD {o.amdEvre}</span> : null}
                {o?.drEvre == null && !o?.amdEvre ? '—' : null}
              </div>
            ))}
          </div>
        )}

        {/* ------------------------------------------------------ takip --- */}
        {veri && sekme === 'Takip' && (
          <table className="grid">
            <thead><tr><th>Hastalık</th><th className="orta">Göz</th><th>Evre</th>
              <th className="sag">Hedef GİB</th><th>Sonraki Kontrol</th>
              <th className="orta">Progresyon</th></tr></thead>
            <tbody>
              {veri.takipler.length === 0 && (
                <tr><td colSpan={6} className="bos">Açık takip planı yok.</td></tr>
              )}
              {veri.takipler.map(t => (
                <tr key={t.id}>
                  <td>{HASTALIK[t.hastalik] ?? '—'}</td>
                  <td className="orta">{t.goz === 1 ? 'OD' : t.goz === 2 ? 'OS' : 'OU'}</td>
                  <td>{t.evre || '—'}</td>
                  <td className="sag">{t.hedefGib != null ? Number(t.hedefGib).toFixed(1) : '—'}</td>
                  <td>
                    {t.sonrakiKontrol ? tarihYaz(t.sonrakiKontrol) : '—'}
                    {/* Gecikme gün sayısı satırda: "kim gelmedi" sorusu
                        tarihlere bakılarak değil rozete bakılarak cevaplanır. */}
                    {t.gecikmeGun != null && t.gecikmeGun > 0 && (
                      <span className="rozet hata"> {t.gecikmeGun} gün gecikti</span>
                    )}
                  </td>
                  <td className="orta">
                    <span className={`rozet ${t.progresyon === 3 ? 'hata'
                                             : t.progresyon === 2 ? 'sari' : 'ok'}`}>
                      {PROGRESYON[t.progresyon] ?? '—'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {/* -------------------------------------------------- ziyaretler --- */}
        {veri && sekme === 'Ziyaretler' && (
          <table className="grid">
            <thead><tr><th>Tarih</th><th>Tür</th><th>Hekim</th><th className="orta">Dilate</th></tr></thead>
            <tbody>
              {veri.ziyaretler.length === 0 && (
                <tr><td colSpan={4} className="bos">Göz muayenesi yok.</td></tr>
              )}
              {veri.ziyaretler.map(z => (
                <tr key={z.id}>
                  <td>{tarihYaz(z.tarih)}</td>
                  <td>{MUAYENE_TUR[z.tur] ?? '—'}</td>
                  <td className="sonuk">{z.hekim || '—'}</td>
                  <td className="orta">{z.dilate ? '✓' : ''}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {/* ---------------------------------------------------- işlemler --- */}
        {veri && sekme === 'İşlemler' && (
          <table className="grid">
            <thead><tr><th>Tarih</th><th>İşlem</th><th className="orta">Göz</th>
              <th>Detay</th><th className="orta">Durum</th></tr></thead>
            <tbody>
              {veri.islemler.length === 0 && (
                <tr><td colSpan={5} className="bos">İşlem kaydı yok.</td></tr>
              )}
              {veri.islemler.map(i => (
                <tr key={i.id}>
                  <td>{i.zaman ? tarihYaz(i.zaman) : '—'}</td>
                  <td>{ISLEM_TUR[i.tur] ?? '—'}</td>
                  <td className="orta">{i.goz === 1 ? 'OD' : i.goz === 2 ? 'OS' : 'OU'}</td>
                  {/* "Kaçıncı doz" hekimin kararını doğrudan değiştirir:
                      yükleme mi, idame mi, bırakılacak mı. */}
                  <td className="sonuk">
                    {i.tur === 1
                      ? `${ENJ_ILAC[i.ilac] ?? ''}${i.dozNo ? ` · ${i.dozNo}. doz` : ''}`
                      : i.tur === 3 ? `ameliyat türü ${i.ameliyatTur || '—'}`
                      : i.tur === 2 ? `lazer türü ${i.lazerTur || '—'}` : ''}
                  </td>
                  <td className="orta">
                    <span className={`rozet ${i.durum === 3 ? 'ok' : i.durum === 1 ? 'mavi' : ''}`}>
                      {ISLEM_DURUM[i.durum] ?? '—'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {/* --------------------------------------------------- reçeteler --- */}
        {veri && sekme === 'Reçeteler' && (
          <table className="grid">
            <thead><tr><th>Tarih</th><th>Reçete No</th><th>Tür</th>
              <th>OD</th><th>OS</th></tr></thead>
            <tbody>
              {veri.receteler.length === 0 && (
                <tr><td colSpan={5} className="bos">Gözlük reçetesi yok.</td></tr>
              )}
              {veri.receteler.map(r => (
                <tr key={r.id}>
                  <td>{tarihYaz(r.tarih)}</td>
                  <td>{r.receteNo || '—'}</td>
                  <td>{RECETE_TUR[r.tur] ?? '—'}</td>
                  <td>{refYaz(r.odSph, r.odCyl, r.odAks)}
                    {r.odAdd != null && <span className="sonuk"> add {Number(r.odAdd).toFixed(2)}</span>}</td>
                  <td>{refYaz(r.osSph, r.osCyl, r.osAks)}
                    {r.osAdd != null && <span className="sonuk"> add {Number(r.osAdd).toFixed(2)}</span>}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
