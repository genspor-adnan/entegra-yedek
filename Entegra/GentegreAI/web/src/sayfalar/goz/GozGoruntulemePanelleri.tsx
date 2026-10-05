import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import type { GozGoruntulemeGostergeYaniti, GozGoruntulemeOnizleme } from '../../api/uclar/goz';
import type { EkSekmeBaglami } from '../../bilesenler/GenForm';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';

/**
 * GÖZ GÖRÜNTÜLEME v2 (974, mockup Ekranlar/Goz/goz_goruntuleme_listesi_v2.html ·
 * goz_goruntuleme_karti_v2.html).
 *
 *   Akış lab / radyolojiyle aynı: hekim istem sepetinden ister → başvuruya bekleyen →
 *   banko ücretlendirir + başvuru kaydı → teknisyen çeker → hekim değerlendirir.
 *   Liste: useGoruntulemeSuzgeci · GoruntulemeGostergesi · GoruntulemeSolPanel · GoruntulemeOnizlemePaneli
 *   Kart : GoruntulemeHastaBandi · GoruntuOlcumSekmesi · GoruntulemeKarsilastirmaSekmesi
 */

export const GOZ_TETKIK: Record<number, string> = {
  1: 'OCT maküla', 2: 'OCT RNFL / GCC', 3: 'OCT ön segment', 4: 'OCT-A', 5: 'FAF', 6: 'FA / ICGA', 7: 'Fundus foto',
  8: 'Görme alanı', 9: 'Topografi', 10: 'Pakimetri', 11: 'Biyometri', 12: 'Endotel', 13: 'UBM', 14: 'B-scan USG', 15: 'ERG / VEP',
};
const TARAF: Record<number, string> = { 1: 'OD', 2: 'OS', 3: 'OU' };
const SONUC: Record<number, string> = { 1: 'Normal', 2: 'Sınırda', 3: 'Anormal', 4: 'Değerlendirilemez' };
const OLCUM: Record<string, string> = {
  cmt: 'CMT (µm)', rnfl_ort: 'RNFL ort. (µm)', rnfl_sup: 'RNFL superior', rnfl_inf: 'RNFL inferior', gcc: 'GCC ort.',
  cd: 'C/D (OCT)', md: 'MD (dB)', psd: 'PSD (dB)', vfi: 'VFI (%)', al: 'AL (mm)', k1: 'K1', k2: 'K2', acd: 'ACD', cct: 'CCT (µm)',
};
const olcumAdi = (k: string) => OLCUM[k] ?? k;
const sayi = (v: unknown) => (v === null || v === undefined || v === '' ? '—'
  : Number(v).toLocaleString('tr-TR', { maximumFractionDigits: 2 }));

/** Durum metni: ödeme / sıra / değerlendirme. */
export function goruntulemeDurumu(durum: number, serbest: number): { ad: string; sinif: string } {
  if (durum === 0) return { ad: 'İptal', sinif: 'gri' };
  if (durum === 3) return { ad: 'Değerlendirildi', sinif: 'ok' };
  if (durum === 2) return { ad: 'Çekildi · değerlendirme bekliyor', sinif: 'uyari' };
  return serbest === 0 ? { ad: 'Ödeme bekliyor', sinif: 'kirmizi' } : { ad: 'İstendi · çekim sırasında', sinif: 'uyari' };
}

// ------------------------------------------------------------------ LİSTE --
export type GoruntulemeGostergeKodu = 'bugun' | 'sirada' | 'odemeBekliyor' | 'degerlendirmeBekleyen' | 'kaliteDusuk' | 'esikDisi' | 'yzDikkat';

export function useGoruntulemeSuzgeci(aktif: boolean) {
  const [gosterge, setGosterge] = useState<GoruntulemeGostergeKodu | null>(null);
  const [tetkik, setTetkik] = useState<number | null>(null);
  const [cihaz, setCihaz] = useState<number | null>(null);
  const [degerlendiren, setDegerlendiren] = useState<number | null>(null);
  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    const esit = (alan: string, deger: number) => l.push({ alan, op: 'esit', deger });
    if (gosterge === 'bugun') esit('bugun', 1);
    if (gosterge === 'sirada') { esit('durum', 1); esit('serbest', 1) }
    if (gosterge === 'odemeBekliyor') { esit('durum', 1); esit('serbest', 0) }
    if (gosterge === 'degerlendirmeBekleyen') esit('durum', 2);
    if (gosterge === 'kaliteDusuk') esit('kaliteDusuk', 1);
    if (gosterge === 'esikDisi') esit('esikDisi', 1);
    if (gosterge === 'yzDikkat') esit('yzDikkat', 1);
    if (tetkik !== null) esit('tetkik', tetkik);
    if (cihaz !== null) esit('cihazId', cihaz);
    if (degerlendiren !== null) esit('degerlendirenId', degerlendiren);
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { gosterge, setGosterge, tetkik, setTetkik, cihaz, setCihaz, degerlendiren, setDegerlendiren, filtre };
}
export type GoruntulemeSuzgeci = ReturnType<typeof useGoruntulemeSuzgeci>;

export function useGoruntulemeGostergesi(aktif: boolean, yenile: number) {
  const [v, setV] = useState<GozGoruntulemeGostergeYaniti | null>(null);
  useEffect(() => { if (aktif) api.gozGoruntulemeGosterge().then(setV).catch(() => setV(null)) }, [aktif, yenile]);
  return v;
}

export function GoruntulemeGostergesi({ veri, s }: { veri: GozGoruntulemeGostergeYaniti | null; s: GoruntulemeSuzgeci }) {
  const g = veri?.gosterge;
  const kutular: { kod: GoruntulemeGostergeKodu; deger?: number; ad: string; sinif?: string }[] = [
    { kod: 'bugun', deger: g?.bugun, ad: 'Bugün istenen' },
    { kod: 'odemeBekliyor', deger: g?.odemeBekliyor, ad: 'Ödeme bekleyen (bankoda)', sinif: g?.odemeBekliyor ? 'uyari' : undefined },
    { kod: 'sirada', deger: g?.sirada, ad: 'Çekim bekleyen (sırada)' },
    { kod: 'degerlendirmeBekleyen', deger: g?.degerlendirmeBekleyen, ad: 'Değerlendirme bekleyen', sinif: g?.degerlendirmeBekleyen ? 'uyari' : undefined },
    { kod: 'kaliteDusuk', deger: g?.kaliteDusuk, ad: 'Kalitesi düşük (sinyal < 6/10)', sinif: g?.kaliteDusuk ? 'uyari' : undefined },
    { kod: 'esikDisi', deger: g?.esikDisi, ad: 'Eşik dışı ölçüm', sinif: g?.esikDisi ? 'kirmizi' : undefined },
    { kod: 'yzDikkat', deger: g?.yzDikkat, ad: 'YZ ön okuma: dikkat' },
  ];
  return (
    <div className="pl-kpi">
      {kutular.map(k => (
        <button key={k.kod} type="button" className={`pl-k${s.gosterge === k.kod ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                onClick={() => s.setGosterge(s.gosterge === k.kod ? null : k.kod)}>
          <b>{k.deger ?? '…'}</b><span>{c(k.ad)}</span>
        </button>
      ))}
    </div>
  );
}

export function GoruntulemeSolPanel({ veri, s }: { veri: GozGoruntulemeGostergeYaniti | null; s: GoruntulemeSuzgeci }) {
  const toplam = (veri?.tetkikler ?? []).reduce((a, b) => a + b.sayi, 0);
  return (
    <div className="rt-agac">
      <h6>{c('Tetkik')}</h6>
      <button type="button" className={`rt-dal${s.tetkik === null ? ' on' : ''}`} onClick={() => s.setTetkik(null)}><span>{c('Tümü')}</span><i>{toplam}</i></button>
      {(veri?.tetkikler ?? []).map(t => (
        <button key={t.tetkik} type="button" className={`rt-dal${s.tetkik === t.tetkik ? ' on' : ''}`}
                onClick={() => s.setTetkik(s.tetkik === t.tetkik ? null : t.tetkik)}>
          <span>{c(GOZ_TETKIK[t.tetkik] ?? String(t.tetkik))}</span><i>{t.sayi}</i></button>
      ))}
      {(veri?.cihazlar ?? []).length > 0 && <h6 style={{ marginTop: 12 }}>{c('Cihaz')}</h6>}
      {(veri?.cihazlar ?? []).map(d => (
        <button key={d.id} type="button" className={`rt-dal${s.cihaz === d.id ? ' on' : ''}`} onClick={() => s.setCihaz(s.cihaz === d.id ? null : d.id)}>
          <span>{d.ad}</span><i>{d.sayi}</i></button>
      ))}
      {(veri?.degerlendirenler ?? []).length > 0 && <h6 style={{ marginTop: 12 }}>{c('Değerlendiren')}</h6>}
      {(veri?.degerlendirenler ?? []).map(d => (
        <button key={d.id} type="button" className={`rt-dal${s.degerlendiren === d.id ? ' on' : ''}`}
                onClick={() => s.setDegerlendiren(s.degerlendiren === d.id ? null : d.id)}>
          <span>{d.ad}</span><i>{d.sayi}</i></button>
      ))}
    </div>
  );
}

/** Görüntü yer tutucu: piksel cihaz / PACS'tan (henüz bağlı değil); varsa Study UID ve belge sayısı. */
function GoruntuKutusu({ k }: { k: Record<string, unknown> }) {
  const goz = Number(k.goz ?? 3);
  const kutu = (ad: string) => (
    <div className="gg-resim"><span>{ad}</span></div>
  );
  return (
    <div>
      <div className="gg-resimler">{goz !== 2 && kutu(c('OD · Sağ'))}{goz !== 1 && kutu(c('OS · Sol'))}</div>
      <div className="rt-kucuk sonuk">
        {String(k.studyUid ?? '') ? `Study UID ${String(k.studyUid)}` : c('Görüntü cihazdan / PACS\'tan gelir (DICOM)')}
        {Number(k.dokumanSay ?? 0) > 0 ? ` · ${String(k.dokumanSay)} ${c('belge')}` : ''}
      </div>
    </div>
  );
}

function OlcumTablosu({ olcumler, onceki = true }: { olcumler: GozGoruntulemeOnizleme['olcumler']; onceki?: boolean }) {
  const adlar = [...new Set(olcumler.map(o => o.olcum))];
  if (adlar.length === 0) return <div className="sonuk">{c('Ölçüm yok (cihazdan gelir ya da "Ölçüm girişi" sekmesinden girilir).')}</div>;
  const bul = (ad: string, goz: number) => olcumler.find(o => o.olcum === ad && o.goz === goz);
  const hucre = (o?: GozGoruntulemeOnizleme['olcumler'][number]) => (
    <td className={o && o.bayrak >= 2 ? 'gg-y1' : o && o.bayrak === 1 ? 'gg-y5' : ''}>{sayi(o?.deger)}</td>
  );
  return (
    <table className="gl-mini gg-olcum">
      <tbody>
        <tr><th>{c('Ölçüm')}</th><th>OD</th><th>OS</th>{onceki && <th>{c('Önceki')} OD / OS</th>}</tr>
        {adlar.map(ad => {
          const od = bul(ad, 1), os = bul(ad, 2);
          return (
            <tr key={ad}><th>{olcumAdi(ad)}</th>{hucre(od)}{hucre(os)}
              {onceki && <td className="sonuk">{sayi(od?.onceki)} / {sayi(os?.onceki)}</td>}</tr>
          );
        })}
      </tbody>
    </table>
  );
}

function YzOnOkuma({ metin, onAktar }: { metin: string; onAktar?: (m: string) => void }) {
  if (!metin) return null;
  return (
    <div className="gg-yz">
      🤖 <b>{c('YZ ön okuma')}:</b> {metin}
      <div className="rt-kucuk">
        {onAktar && <button type="button" className="d" onClick={() => onAktar(metin)}>✓ {c('Değerlendirmeye aktar')}</button>}
        <span className="sonuk"> {c('öneridir, hekim karar verir')}</span>
      </div>
    </div>
  );
}

const yzMetni = (ham: unknown): string => {
  if (!ham) return '';
  try {
    const j = JSON.parse(String(ham)) as Record<string, unknown>;
    return String(j.ozet ?? j.metin ?? j.bulgu ?? '');
  } catch { return '' }
};

function Egilim({ e }: { e: GozGoruntulemeOnizleme['egilim'] }) {
  const deg = e.flatMap(x => [x.od, x.os]).filter((v): v is number => v !== null && v !== undefined).map(Number);
  if (e.length < 2 || deg.length === 0) return <div className="sonuk">{c('Eğilim için en az iki çekim gerekir.')}</div>;
  const enb = Math.max(...deg), enk = Math.min(...deg);
  const h = (v: number | null) => (v === null || v === undefined ? 0 : 8 + ((Number(v) - enk) / Math.max(1, enb - enk)) * 36);
  return (
    <div>
      <div className="gg-trend">
        {e.map(x => (
          <div key={x.id} className={x.bu ? 'bu' : ''} title={`${tarihYaz(x.zaman)} · OD ${sayi(x.od)} · OS ${sayi(x.os)}`}>
            <i className="od" style={{ height: h(x.od) }} /><i className="os" style={{ height: h(x.os) }} />
          </div>
        ))}
      </div>
      <div className="rt-kucuk sonuk">{tarihYaz(e[0].zaman)} → {tarihYaz(e[e.length - 1].zaman)} · <span className="gg-mavi">■ OD</span> <span className="gg-mor">■ OS</span></div>
    </div>
  );
}

export function GoruntulemeOnizlemePaneli({ satir, yenile, onAc }: { satir: ListeSatiri | null; yenile: number; onAc?: (id: number) => void }) {
  const id = satir ? Number(satir.id) : 0;
  const [r, setR] = useState<GozGoruntulemeOnizleme | null>(null);
  useEffect(() => { setR(null); if (id > 0) api.gozGoruntulemeOnizleme(id).then(setR).catch(() => setR(null)) }, [id, yenile]);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir görüntüleme seçin.')}</div>;
  if (!r) return <div className="rt-oniz sonuk">{c('yükleniyor')}…</div>;
  const k = r.kayit;
  const d = goruntulemeDurumu(Number(k.durum), Number(k.serbest));
  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Görüntü')}</h5>
        <GoruntuKutusu k={k} />
        <div className="rt-kucuk">{[String(k.cihaz ?? ''), k.cekimZamani ? tarihSaat(k.cekimZamani) : '', k.kalite != null ? `${c('sinyal')} ${String(k.kalite)}/10` : '']
          .filter(Boolean).join(' · ') || <span className={`rozet ${d.sinif}`}>{c(d.ad)}</span>}</div>
      </div>
      <div className="rt-bl"><h5>{c('Ölçümler')}</h5><OlcumTablosu olcumler={r.olcumler} onceki={false} /></div>
      {r.egilim.length > 1 && <div className="rt-bl"><h5>{c('Eğilim')}</h5><Egilim e={r.egilim} /></div>}
      {yzMetni(k.yzOnOkuma) && <div className="rt-bl"><YzOnOkuma metin={yzMetni(k.yzOnOkuma)} /></div>}
      {Number(k.durum) === 3 && (
        <div className="rt-bl"><h5>{c('Değerlendirme')}</h5>
          <div><b>{c(SONUC[Number(k.sonuc)] ?? '—')}</b> · {String(k.degerlendiren ?? '')}</div>
          {String(k.degerlendirme ?? '') && <div className="rt-kucuk">{String(k.degerlendirme)}</div>}
        </div>
      )}
      {onAc && <div className="rt-bl"><button type="button" className="d" onClick={() => onAc(id)}>📇 {c('Aç')}</button></div>}
    </div>
  );
}

// ------------------------------------------------------------------- KART --
export function useGoruntulemeOnizleme(id: number | null, yenile: number) {
  const [r, setR] = useState<GozGoruntulemeOnizleme | null>(null);
  useEffect(() => { setR(null); if (id && id > 0) api.gozGoruntulemeOnizleme(id).then(setR).catch(() => setR(null)) }, [id, yenile]);
  return r;
}

/** Kimlik şeridinin üstünde: hasta, isteyen hekim, klinik soru, son aynı tetkik, durum. */
export function GoruntulemeHastaBandi({ r }: { r: GozGoruntulemeOnizleme | null }) {
  if (!r) return null;
  const k = r.kayit;
  const d = goruntulemeDurumu(Number(k.durum), Number(k.serbest));
  const onceki = r.egilim.filter(x => !x.bu).at(-1);
  return (
    <div className="gz4-ust">
      <div>
        <div className="ad">{String(k.hasta ?? '—')}</div>
        <div className="sonuk">{[k.yas != null ? `${String(k.yas)} ${Number(k.cinsiyet) === 1 ? 'E' : Number(k.cinsiyet) === 2 ? 'K' : ''}` : '',
          k.istemZamani ? `${c('istem')} ${tarihSaat(k.istemZamani)}` : '', String(k.istekHekim ?? '')].filter(Boolean).join(' · ')}</div>
      </div>
      <div className="bil">
        <span>{c('Son aynı tetkik')}: <b>{onceki ? tarihYaz(onceki.zaman) : c('yok')}</b></span>
        {Number(k.dilate) === 1 && <span>{c('Dilate')}: <b>{c('evet')}</b></span>}
        {String(k.klinikSoru ?? '') && <span>{c('Klinik soru')}: <b>{String(k.klinikSoru)}</b></span>}
        {String(k.basvuruNo ?? '') && <span>{c('Başvuru')}: <b>{String(k.basvuruNo)}</b></span>}
      </div>
      <div className="roz"><span className={`rozet ${d.sinif === 'kirmizi' ? 'hata' : d.sinif}`}>{c(d.ad)}</span></div>
    </div>
  );
}

/** "Görüntü & ölçümler" sekmesi: OD / OS görüntü, ölçüm tablosu (önceki ile), YZ ön okuma. */
export function GoruntuOlcumSekmesi({ r, b }: { r: GozGoruntulemeOnizleme | null; b: EkSekmeBaglami }) {
  if (!r) return <div className="sonuk">{c('yükleniyor')}…</div>;
  const k = r.kayit;
  const kilit = Number(k.durum) === 3 || b.saltOkunur;
  return (
    <div className="gg-iki">
      <div><GoruntuKutusu k={k} /></div>
      <div>
        <OlcumTablosu olcumler={r.olcumler} />
        <div className="rt-kucuk sonuk">{c('Renk: kırmızı %1 altı · sarı %5 altı (normatif)')}</div>
        <YzOnOkuma metin={yzMetni(k.yzOnOkuma)}
          onAktar={kilit ? undefined : m => { b.alanYaz('degerlendirme', m); b.sekmeyeGit('Değerlendirme') }} />
      </div>
    </div>
  );
}

/** "Karşılaştırma" sekmesi: ana ölçüm eğilimi + önceki tetkikler tablosu. */
export function GoruntulemeKarsilastirmaSekmesi({ r }: { r: GozGoruntulemeOnizleme | null }) {
  if (!r) return <div className="sonuk">{c('yükleniyor')}…</div>;
  const ana = String(r.kayit.anaOlcum ?? '');
  return (
    <div>
      <Egilim e={r.egilim} />
      <table className="gl-mini" style={{ marginTop: 10 }}>
        <tbody>
          <tr><th>{c('Tarih')}</th><th>{olcumAdi(ana)} OD</th><th>{olcumAdi(ana)} OS</th></tr>
          {[...r.egilim].reverse().map(x => (
            <tr key={x.id} style={x.bu ? { fontWeight: 700 } : undefined}>
              <td>{x.bu ? c('bu çekim') : tarihYaz(x.zaman)}</td><td>{sayi(x.od)}</td><td>{sayi(x.os)}</td></tr>
          ))}
        </tbody>
      </table>
      {!ana && <div className="sonuk">{c('Bu tetkik için ana ölçüm tanımlı değil.')}</div>}
    </div>
  );
}

export { TARAF as GOZ_TARAF };
