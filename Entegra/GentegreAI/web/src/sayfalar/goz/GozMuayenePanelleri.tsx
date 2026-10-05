import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import type { GozGecmisSatiri, GozMuayeneGostergeYaniti, GozMuayeneIsleri, GozMuayeneOnizleme, GozGoruntuSatiri } from '../../api/uclar/goz';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';
import { DokumanGalerisi } from '../../bilesenler/DokumanGalerisi';
import { c } from '../../dil/ceviri';
import { GozIsaretSeridi, useGozIsaretleri } from '../../bilesenler/goz/GozIsaretSeridi';

/**
 * GÖZ MUAYENE LİSTESİ + KARTI PARÇALARI (970, mockup
 * Ekranlar/Goz/goz_muayene_listesi_v2.html · goz_muayene_karti_v2.html).
 *
 *   useGozMuayeneSuzgeci     gösterge kutusu + tür + hekim → Liste filtre zinciri
 *   GozMuayeneGostergesi     gridin üstü; kutu = süzgeç (tekrar tıkla = kaldır)
 *   GozMuayeneSolPanel       muayene türü + hekim - GenGrid sol paneli (katlanır)
 *   GozMuayeneOnizleme       seçili muayene - GenGrid yan paneli (katlanır)
 *   GozGibEgilimi / GozTaniPlanPaneli / GozKarsilastirmaSekmesi / GozGoruntulerSekmesi  kart parçaları
 */
export type GozGostergeKodu = 'bugun' | 'dilatasyon' | 'gibYuksek' | 'gormeDusus' | 'kontrolGecikmis' | 'taslak';

export const GOZ_MUAYENE_TURLERI: Record<number, string> = {
  1: 'Tam muayene', 2: 'Kontrol', 3: 'Postop kontrol', 4: 'Acil', 5: 'Tarama (DR)',
  6: 'Preop', 7: 'Refraktif değerlendirme', 8: 'Kontakt lens',
};

export function useGozMuayeneSuzgeci(aktif: boolean) {
  const [gosterge, setGosterge] = useState<GozGostergeKodu | null>(null);
  const [tur, setTur] = useState<number | null>(null);
  const [hekim, setHekim] = useState<number | null>(null);
  // İŞARET ŞERİDİ (mockup ②) görüntüleme listesiyle ORTAK: dilate · glokom ·
  //   retina, üçü bağımsız. Eskiden dönem / durum çiplerinin arasındaydılar,
  //   o şerit TEK SEÇİM olduğu için "Bugün + dilate" kurulamıyordu.
  const isaret = useGozIsaretleri();
  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    if (gosterge === 'bugun') l.push({ alan: 'bugun', op: 'esit', deger: 1 });
    if (gosterge === 'dilatasyon') l.push({ alan: 'dilatasyonBekliyor', op: 'esit', deger: 1 });
    if (gosterge === 'gibYuksek') l.push({ alan: 'gibYuksek', op: 'buyuk', deger: 0 }, { alan: 'son30', op: 'esit', deger: 1 });
    if (gosterge === 'gormeDusus') l.push({ alan: 'gormeDusus', op: 'buyuk', deger: 0 }, { alan: 'son30', op: 'esit', deger: 1 });
    if (gosterge === 'kontrolGecikmis') l.push({ alan: 'kontrolGecikmis', op: 'esit', deger: 1 });
    if (gosterge === 'taslak') l.push({ alan: 'tamamlandi', op: 'esit', deger: 0 });
    isaret.isaretKosullari((alan, deger) => l.push({ alan, op: 'esit', deger }));
    if (tur !== null) l.push({ alan: 'tur', op: 'esit', deger: tur });
    if (hekim !== null) l.push({ alan: 'hekimId', op: 'esit', deger: hekim });
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { gosterge, setGosterge, tur, setTur, hekim, setHekim, isaret, filtre };
}
export type GozMuayeneSuzgeci = ReturnType<typeof useGozMuayeneSuzgeci>;

export function useGozMuayeneGostergesi(aktif: boolean, yenile: number) {
  const [v, setV] = useState<GozMuayeneGostergeYaniti | null>(null);
  useEffect(() => { if (aktif) api.gozMuayeneGosterge().then(setV).catch(() => setV(null)) }, [aktif, yenile]);
  return v;
}

export function GozMuayeneGostergesi({ veri, s }: { veri: GozMuayeneGostergeYaniti | null; s: GozMuayeneSuzgeci }) {
  const g = veri?.gosterge;
  const kutular: { kod: GozGostergeKodu; deger?: number; ad: string; sinif?: string }[] = [
    { kod: 'bugun', deger: g?.bugun, ad: 'Bugün muayene' },
    { kod: 'dilatasyon', deger: g?.dilatasyon, ad: 'Dilatasyon bekliyor (damla verildi)', sinif: g?.dilatasyon ? 'uyari' : undefined },
    { kod: 'gibYuksek', deger: g?.gibYuksek, ad: 'GİB yüksek (> hedef / > 21) · 30 gün', sinif: g?.gibYuksek ? 'kirmizi' : undefined },
    { kod: 'gormeDusus', deger: g?.gormeDusus, ad: 'Görme düşüşü (≥ 2 sıra) · 30 gün', sinif: g?.gormeDusus ? 'kirmizi' : undefined },
    { kod: 'kontrolGecikmis', deger: g?.kontrolGecikmis, ad: 'Kontrolü gecikmiş', sinif: g?.kontrolGecikmis ? 'uyari' : undefined },
    { kod: 'taslak', deger: g?.taslak, ad: 'Tamamlanmamış (taslak)' },
  ];
  return (
    <div className="pl-kpi rc-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" className={`pl-k${s.gosterge === k.kod ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                onClick={() => s.setGosterge(s.gosterge === k.kod ? null : k.kod)}>
          <b>{k.deger ?? '…'}</b><span>{c(k.ad)}</span>
        </button>
      ))}
    </div>
  );
}

export function GozMuayeneSolPanel({ veri, s }: { veri: GozMuayeneGostergeYaniti | null; s: GozMuayeneSuzgeci }) {
  const turler = veri?.turler ?? [];
  const toplam = turler.reduce((a, b) => a + b.sayi, 0);
  return (
    <div className="rt-agac">
      <GozIsaretSeridi s={s.isaret} />
      <h6>{c('Muayene türü')}</h6>
      <button type="button" className={`rt-dal${s.tur === null ? ' on' : ''}`} onClick={() => s.setTur(null)}><span>{c('Tümü')}</span><i>{toplam}</i></button>
      {turler.map(t => (
        <button key={t.tur} type="button" className={`rt-dal${s.tur === t.tur ? ' on' : ''}`} onClick={() => s.setTur(s.tur === t.tur ? null : t.tur)}>
          <span>{c(GOZ_MUAYENE_TURLERI[t.tur] ?? `Tür ${t.tur}`)}</span><i>{t.sayi}</i></button>
      ))}
      <h6 style={{ marginTop: 12 }}>{c('Hekim')}</h6>
      {(veri?.hekimler ?? []).map(h => (
        <button key={h.id ?? 0} type="button" className={`rt-dal${s.hekim === h.id ? ' on' : ''}`}
                onClick={() => s.setHekim(s.hekim === h.id ? null : h.id)}><span>{h.ad}</span><i>{h.sayi}</i></button>
      ))}
    </div>
  );
}

function Satir({ s, d }: { s: string; d: React.ReactNode }) {
  return <div className="rt-satir"><span>{s}</span><b>{d}</b></div>;
}

const ond = (v: number | null | undefined, k = 2) => (v === null || v === undefined ? '—' : Number(v).toLocaleString('tr-TR', { maximumFractionDigits: k }));
const cins = (n: number) => (n === 1 ? 'E' : n === 2 ? 'K' : '');

/** GİB çubukları (en eski solda): sağ mavi, sol mor, hedef üstü kırmızı. */
function GibCubuklari({ satirlar, yukseklik = 80 }: { satirlar: GozGecmisSatiri[]; yukseklik?: number }) {
  const sira = [...satirlar].reverse();
  const enCok = Math.max(25, ...sira.flatMap(r => [Number(r.gibOd ?? 0), Number(r.gibOs ?? 0)]));
  const cubuk = (v: number | null, hedef: number | null, sinif: string) => (
    <i className={v !== null && v > (hedef ?? 21) ? 'y' : sinif} title={v === null ? '—' : `${ond(v, 1)} mmHg`}
       style={{ height: `${v === null ? 0 : (Number(v) / enCok) * 100}%` }} />
  );
  return (
    <>
      <div className="gz-trend" style={{ height: yukseklik }}>
        {sira.map(r => (
          <div key={r.id} className="c">{cubuk(r.gibOd, r.hedefOd, 's')}{cubuk(r.gibOs, r.hedefOs, 'l')}</div>
        ))}
      </div>
      <div className="gz-trend-et">{sira.map(r => <span key={r.id}>{r.bu ? c('bugün') : tarihYaz(r.tarih).slice(3)}</span>)}</div>
    </>
  );
}

export function GozMuayeneOnizleme({ satir, yenile, onAc, onTamamla, onGozluk, onIstem }: {
  satir: ListeSatiri | null; yenile: number;
  /**
   * HIZLI İŞLEM (mockup ④): panelden de çağrılabilen araç çubuğu aksiyonları.
   * Hepsi araç çubuğunun AYNI yolunu kullanır - ikinci bir kod yolu, tamamlama
   * kontrollerinin (zorunlu alan, ödeme) birinde eksik kalması demekti.
   */
  onAc?: (id: number) => void;
  onTamamla?: () => void;
  onGozluk?: () => void;
  onIstem?: () => void;
}) {
  const id = satir ? Number(satir.id) : 0;
  const [o, setO] = useState<GozMuayeneOnizleme | null>(null);
  useEffect(() => { setO(null); if (id > 0) api.gozMuayeneOnizleme(id).then(setO).catch(() => setO(null)) }, [id, yenile]);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir muayene seçin.')}</div>;
  if (!o) return <div className="rt-oniz sonuk">{c('yükleniyor')}…</div>;
  const m = o.muayene;
  const kirmizi = (bit: number, bayrak: number, v: string) => (bayrak & bit ? <span className="gz-kirmizi">{v}</span> : v);
  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Hasta')}</h5>
        <div className="rt-ad">{m.hasta}{m.yas !== null ? ` · ${m.yas} ${cins(m.cinsiyet)}` : ''}</div>
        {m.takip && <Satir s={c('Takip')} d={m.takip} />}
        <Satir s={c('Alerji')} d={m.alerji ? <span className="gz-kirmizi">{m.alerji}</span> : c('bilinen yok')} />
        {m.tedavi && <Satir s={c('Damlalar')} d={m.tedavi} />}
        {(m.hedefOd !== null || m.hedefOs !== null) && <Satir s={c('Hedef GİB')} d={`${c('sağ')} ${ond(m.hedefOd, 0)} · ${c('sol')} ${ond(m.hedefOs, 0)}`} />}
      </div>
      <div className="rt-bl"><h5>{c('Bu muayene')}</h5>
        <div className="gz-od2">
          <span /><span className="b">{c('Sağ')}</span><span className="b">{c('Sol')}</span>
          <span className="b">{c('Görme (düz.)')}</span><span>{kirmizi(1, m.gormeDusus, ond(m.bcvaOd))}</span><span>{kirmizi(2, m.gormeDusus, ond(m.bcvaOs))}</span>
          <span className="b">GİB</span><span>{kirmizi(1, m.gibYuksek, ond(m.gibOd, 1))}</span><span>{kirmizi(2, m.gibYuksek, ond(m.gibOs, 1))}</span>
          <span className="b">CCT</span><span>{m.cctOd ? `${m.cctOd} µm` : '—'}</span><span>{m.cctOs ? `${m.cctOs} µm` : '—'}</span>
          <span className="b">C/D</span><span>{ond(m.cdOd)}</span><span>{ond(m.cdOs)}</span>
        </div>
      </div>
      {o.gecmis.length > 1 && (
        <div className="rt-bl"><h5>{c('GİB eğilimi')} <span className="sonuk">({c('son')} {o.gecmis.length})</span></h5>
          <GibCubuklari satirlar={o.gecmis} yukseklik={44} />
        </div>
      )}
      <div className="rt-bl"><h5>{c('Tanı & plan')}</h5>
        <div className="rt-kucuk">{m.tani || <span className="sonuk">{c('tanı yok')}</span>}</div>
        {m.plan && <Satir s={c('Plan')} d={m.plan} />}
        <Satir s={c('Kontrol')} d={m.kontrolTarihi ? tarihYaz(m.kontrolTarihi) : '—'} />
        <Satir s={c('Durum')} d={<span className={`rozet ${m.tamamlandi ? 'olumlu' : 'uyari'}`}>{m.tamamlandi ? c('Tamamlandı') : c('Taslak')}</span>} />
      </div>
      {(onAc || onTamamla || onGozluk || onIstem) && (
        <div className="rt-bl"><h5>{c('Hızlı işlem')}</h5>
          {onAc && <button type="button" className="d" onClick={() => onAc(id)}>📇 {c('Aç')}</button>}
          {/* TAMAMLA yalnız taslakta: tamamlanmış muayene yeniden kapatılmaz. */}
          {onTamamla && !m.tamamlandi && (
            <button type="button" className="d" onClick={onTamamla}>✔ {c('Tamamla')}</button>)}
          {onGozluk && <button type="button" className="d" onClick={onGozluk}>👓 {c('Gözlük reçetesi')}</button>}
          {onIstem && <button type="button" className="d" onClick={onIstem}>🖼 {c('Görüntüleme iste')}</button>}
        </div>
      )}
    </div>
  );
}

// ------------------------------------------------------------ kart parçaları --
/** Tonometri sekmesinin sağında: hastanın GİB eğilimi ve hedef üstü uyarısı. */
export function GozGibEgilimi({ id, yenile }: { id: number; yenile: number }) {
  const [l, setL] = useState<GozGecmisSatiri[] | null>(null);
  useEffect(() => { api.gozMuayeneKarsilastirma(id).then(y => setL(y.satirlar)).catch(() => setL([])) }, [id, yenile]);
  if (!l) return null;
  const ust = (g: 'Od' | 'Os') => {
    let n = 0;
    for (const r of l) { const v = r[`gib${g}`]; if (v !== null && v > (r[`hedef${g}`] ?? 21)) n++; else break; }
    return n;
  };
  const uOd = ust('Od'), uOs = ust('Os');
  return (
    <div className="gz-yan">
      <div className="rt-baslik">{c('GİB eğilimi')} <span className="sonuk">({c('mavi sağ · mor sol · kırmızı hedef üstü')})</span></div>
      {l.length === 0 ? <div className="sonuk rt-kucuk">{c('Ölçüm yok.')}</div> : <GibCubuklari satirlar={l} />}
      {(uOd > 0 || uOs > 0) && (
        <div className="tl-uyari rt-kucuk" style={{ marginTop: 8 }}>
          ⚠ {[uOd > 0 && `${c('Sağ')} ${uOd}`, uOs > 0 && `${c('Sol')} ${uOs}`].filter(Boolean).join(' · ')} {c('ziyarettir hedef üstünde. Tedavi değişikliği / lazer değerlendirin.')}
        </div>
      )}
    </div>
  );
}

const TARAF: Record<number, string> = { 1: 'Sağ', 2: 'Sol', 3: 'İki taraf' };
const IS_IKON: Record<string, string> = { gozluk: '👓', goruntuleme: '🖼', islem: '💉', randevu: '📅' };

/** Tanı & Plan sekmesinin sağında: muayene tanıları + bu muayeneden doğan işler + tamamlama kuralı. */
export function GozTaniPlanPaneli({ id, yenile }: { id: number; yenile: number }) {
  const [v, setV] = useState<GozMuayeneIsleri | null>(null);
  useEffect(() => { api.gozMuayeneIsleri(id).then(setV).catch(() => setV(null)) }, [id, yenile]);
  if (!v) return null;
  return (
    <div className="gz-yan">
      <div className="rt-baslik">{c('Tanılar')} <span className="sonuk">({c('genel muayenenin tanı listesi')})</span></div>
      {v.tanilar.length === 0 ? <div className="sonuk rt-kucuk">{c('Tanı girilmemiş.')}</div> : (
        <table className="rt-tablo">
          <tbody>{v.tanilar.map((t, i) => (
            <tr key={i}><td><b>{t.kod}</b></td><td>{t.ad}</td><td className="rt-kucuk">{c(TARAF[t.taraf] ?? '')}</td></tr>
          ))}</tbody>
        </table>
      )}
      <div className="rt-baslik" style={{ marginTop: 12 }}>{c('Bu muayeneden doğan işler')}</div>
      {v.isler.length === 0 ? <div className="sonuk rt-kucuk">{c('Henüz yok - reçete, görüntüleme ve işlem araç çubuğundan açılır.')}</div>
        : v.isler.map((s, i) => (
          <div key={i} className="rt-satir"><span>{IS_IKON[s.tur] ?? '•'} {c(s.ad)}</span><b>{[s.ayrinti, s.zaman ? tarihSaat(s.zaman) : ''].filter(Boolean).join(' · ')}</b></div>
        ))}
      <div className="tl-uyari rt-kucuk" style={{ marginTop: 10 }}>
        {c('Tamamla: tanı, iki gözün görmesi ve GİB\'i girilmeden muayene ancak gerekçeyle (çocuk, iş birliği yok, tek göz…) tamamlanır.')}
      </div>
    </div>
  );
}

const TUR_KISA: Record<number, string> = { 1: 'Tam', 2: 'Kontrol', 3: 'Postop', 4: 'Acil', 5: 'Tarama', 6: 'Preop', 7: 'Refraktif', 8: 'Kontakt lens' };

export function GozKarsilastirmaSekmesi({ id, yenile }: { id: number; yenile: number }) {
  const [l, setL] = useState<GozGecmisSatiri[] | null>(null);
  useEffect(() => { api.gozMuayeneKarsilastirma(id).then(y => setL(y.satirlar)).catch(() => setL([])) }, [id, yenile]);
  if (!l) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;
  const ik = (a: number | null, b: number | null, k = 2, yuksek?: [number | null, number | null]) => (
    <>{yuksek && a !== null && a > (yuksek[0] ?? 21) ? <span className="gz-kirmizi">{ond(a, k)}</span> : ond(a, k)}
      {' / '}{yuksek && b !== null && b > (yuksek[1] ?? 21) ? <span className="gz-kirmizi">{ond(b, k)}</span> : ond(b, k)}</>
  );
  return (
    <div className="rt-sekme">
      <div className="rt-baslik">{c('Önceki muayenelerle karşılaştırma')} <span className="sonuk">({c('sağ / sol')})</span></div>
      {l.length <= 1 && <div className="sonuk rt-kucuk" style={{ marginBottom: 6 }}>{c('Hastanın önceki göz muayenesi yok.')}</div>}
      <table className="rt-tablo">
        <thead><tr><th>{c('Tarih')}</th><th>{c('Tür')}</th><th>{c('Görme (düz.)')}</th><th>GİB</th><th>C/D</th><th>RNFL</th><th>MD</th><th>{c('Plan')}</th></tr></thead>
        <tbody>{l.map(r => (
          <tr key={r.id} className={r.bu ? 'gz-bu' : undefined}>
            <td>{r.bu ? <b>{c('bu muayene')}</b> : tarihYaz(r.tarih)}</td><td>{c(TUR_KISA[r.tur] ?? '')}</td>
            <td>{ik(r.bcvaOd, r.bcvaOs)}</td><td>{ik(r.gibOd, r.gibOs, 1, [r.hedefOd, r.hedefOs])}</td>
            <td>{ik(r.cdOd, r.cdOs)}</td><td>{ik(r.rnflOd, r.rnflOs, 0)}</td><td>{ond(r.md, 1)}</td>
            <td className="rt-kucuk">{r.plan}</td>
          </tr>
        ))}</tbody>
      </table>
    </div>
  );
}

export function GozGoruntulerSekmesi({ id, muayeneId, yenile }: { id: number; muayeneId: number; yenile: number }) {
  const [l, setL] = useState<GozGoruntuSatiri[] | null>(null);
  useEffect(() => { api.gozMuayeneGoruntuler(id).then(y => setL(y.satirlar)).catch(() => setL([])) }, [id, yenile]);
  return (
    <div className="rt-sekme">
      <div className="rt-baslik">{c('Görüntüleme ve çizimler')} <span className="sonuk">({c('hastanın göz görüntülemeleri; bu muayenenin olanlar koyu')})</span></div>
      {!l ? <div className="sonuk">{c('yükleniyor')}…</div> : l.length === 0 ? <div className="sonuk rt-kucuk">{c('Kayıt yok.')}</div> : (
        <table className="rt-tablo">
          <thead><tr><th>{c('Tarih')}</th><th>{c('Tür')}</th><th>{c('Göz')}</th><th>{c('Kaynak')}</th><th>{c('Durum')}</th></tr></thead>
          <tbody>{l.map((s, i) => (
            <tr key={i} className={s.buMuayene ? 'gz-bu' : undefined}>
              <td>{s.zaman ? tarihSaat(s.zaman) : '—'}</td><td>{c(s.tur)}</td><td>{s.goz}</td><td>{s.kaynak}</td><td>{c(s.durum)}</td>
            </tr>
          ))}</tbody>
        </table>
      )}
      {muayeneId > 0 && (
        <>
          <div className="rt-baslik" style={{ marginTop: 14 }}>{c('Belgeler')} <span className="sonuk">({c('muayeneye yüklenen dosyalar')})</span></div>
          <DokumanGalerisi kartAdi="muayene" kaynakId={muayeneId} saltOkunur={false} />
        </>
      )}
    </div>
  );
}
