import { useEffect, useState, type ReactNode } from 'react';
import { api } from '../../api/istemci';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import type { GozCihazGostergeYaniti, GozCihazOnizleme } from '../../api/uclar/goz';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';
import { GozIsaretSeridi, useGozIsaretleri } from '../../bilesenler/goz/GozIsaretSeridi';
import { GOZ_CIHAZ_TUR, GOZ_CIHAZ_PROTOKOL, GOZ_CIHAZ_DURUM, GOZ_TETKIK } from '../../bilesenler/goz/gozKodlari';

/**
 * GÖZ CİHAZLARI v2 (978, mockup `Ekranlar/Goz/goz_goruntuleme_cihazlar_v2.html`
 * ve `goz_cihaz_karti_v2.html`).
 *
 *   useGozCihazSuzgeci     gösterge + tür / protokol / durum → Liste filtre zinciri
 *   GozCihazGostergesi     gridin üstü; kutu = süzgeç (tekrar tıkla = kaldır)
 *   GozCihazSolPanel       tür · protokol · durum ağacı + işaret şeridi
 *   CihazOnizleme       seçili cihaz - bağlantı, son 24 saat, eşleme, kalibrasyon
 *
 * <b>Kalibrasyon bölümü salt okumadır</b> (kullanıcı kararı 05.10.2026): kayıt
 * demirbaş kartında tutulur, burada yalnız gösterilir ve oraya bağlantı verilir.
 */
export type GozCihazGostergeKodu =
  'bugun' | 'bekleyen' | 'eslenmeyen' | 'hatali' | 'kalibrasyon' | 'pasif';

/** Mockup ② şeridi: bağımsız işaretler (tek seçimli çiplerle karışmaz). */
export const GOZ_CIHAZ_ISARETLERI = {
  mwl: 'MWL destekli', eslenmeyenVar: 'Eşlenmeyen var', kalibrasyonGecikmis: 'Kalibrasyon gecikmiş',
};

export function useGozCihazSuzgeci(aktif: boolean) {
  const [gosterge, setGosterge] = useState<GozCihazGostergeKodu | null>(null);
  const [tur, setTur] = useState<number | null>(null);
  const [protokol, setProtokol] = useState<number | null>(null);
  const [durum, setDurum] = useState<number | null>(null);
  const isaret = useGozIsaretleri(GOZ_CIHAZ_ISARETLERI);

  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    const esit = (alan: string, deger: number) => l.push({ alan, op: 'esit', deger });
    const buyuk = (alan: string, deger: number) => l.push({ alan, op: 'buyuk', deger });
    if (gosterge === 'bugun') buyuk('bugunCekim', 0);
    if (gosterge === 'bekleyen') buyuk('bekleyen', 0);
    if (gosterge === 'eslenmeyen') buyuk('eslenmeyen', 0);
    if (gosterge === 'hatali') buyuk('hatali', 0);
    if (gosterge === 'kalibrasyon') esit('kalibrasyonGecikmis', 1);
    if (gosterge === 'pasif') esit('aktif', 0);
    isaret.isaretKosullari(esit);
    if (tur !== null) esit('tur', tur);
    if (protokol !== null) esit('protokol', protokol);
    // DURUM AĞACI kolondan değil bileşenlerden süzülür: "bağlantı yok" =
    //   dinleyici 2, "pasif" = aktif 0 - gridde tek rozet, süzgeçte iki alan.
    if (durum === 3) esit('aktif', 0);
    if (durum === 2) { esit('dinleyiciDurum', 2); esit('aktif', 1) }
    if (durum === 0) { esit('dinleyiciDurum', 1); esit('aktif', 1) }
    if (durum === 1) { esit('aktif', 1); l.push({ alan: 'dinleyiciDurum', op: 'esit', deger: 0 }) }
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { gosterge, setGosterge, tur, setTur, protokol, setProtokol, durum, setDurum, isaret, filtre };
}
export type GozCihazSuzgeci = ReturnType<typeof useGozCihazSuzgeci>;

export function useGozCihazGostergesi(aktif: boolean, yenile: number) {
  const [v, setV] = useState<GozCihazGostergeYaniti | null>(null);
  useEffect(() => { if (aktif) api.gozCihazGosterge().then(setV).catch(() => setV(null)) }, [aktif, yenile]);
  return v;
}

export function GozCihazGostergesi({ veri, s }: { veri: GozCihazGostergeYaniti | null; s: GozCihazSuzgeci }) {
  const g = veri?.gosterge;
  const kutular: { kod: GozCihazGostergeKodu; ad: string; deger?: number; sinif?: string }[] = [
    { kod: 'bugun', ad: 'Bugün çekim yapan', deger: g?.bugunCekim },
    { kod: 'bekleyen', ad: 'Sonuç bekleyen istem', deger: g?.bekleyen, sinif: 'uyari' },
    { kod: 'eslenmeyen', ad: 'Eşlenmeyen mesaj', deger: g?.eslenmeyen, sinif: 'kirmizi' },
    { kod: 'hatali', ad: 'Hatalı mesaj', deger: g?.hatali, sinif: 'kirmizi' },
    { kod: 'kalibrasyon', ad: 'Kalibrasyon günü geçmiş', deger: g?.kalibrasyonGecikmis, sinif: 'uyari' },
    { kod: 'pasif', ad: 'Pasif cihaz', deger: (g?.tanimli ?? 0) - (g?.aktif ?? 0) },
  ];
  return (
    <div className="pl-kpi" style={{ gridTemplateColumns: 'repeat(6, minmax(0, 1fr))' }}>
      {kutular.map(k => (
        <button key={k.kod} type="button"
                className={`pl-k${s.gosterge === k.kod ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                onClick={() => s.setGosterge(s.gosterge === k.kod ? null : k.kod)}>
          <b>{k.deger ?? '…'}</b><span>{c(k.ad)}</span>
        </button>
      ))}
    </div>
  );
}

export function GozCihazSolPanel({ veri, s }: { veri: GozCihazGostergeYaniti | null; s: GozCihazSuzgeci }) {
  const toplam = (veri?.turler ?? []).reduce((a, b) => a + b.sayi, 0);
  return (
    <div className="rt-agac">
      <GozIsaretSeridi s={s.isaret} />
      <h6>{c('Cihaz türü')}</h6>
      <button type="button" className={`rt-dal${s.tur === null ? ' on' : ''}`}
              onClick={() => s.setTur(null)}><span>{c('Tümü')}</span><i>{toplam}</i></button>
      {(veri?.turler ?? []).map(t => (
        <button key={t.tur} type="button" className={`rt-dal${s.tur === t.tur ? ' on' : ''}`}
                onClick={() => s.setTur(s.tur === t.tur ? null : t.tur)}>
          <span>{c(GOZ_CIHAZ_TUR[t.tur] ?? `Tür ${t.tur}`)}</span><i>{t.sayi}</i></button>
      ))}
      <h6 style={{ marginTop: 12 }}>{c('Bağlantı')}</h6>
      {(veri?.protokoller ?? []).map(p => (
        <button key={p.protokol} type="button" className={`rt-dal${s.protokol === p.protokol ? ' on' : ''}`}
                onClick={() => s.setProtokol(s.protokol === p.protokol ? null : p.protokol)}>
          <span>{c(GOZ_CIHAZ_PROTOKOL[p.protokol] ?? `Protokol ${p.protokol}`)}</span><i>{p.sayi}</i></button>
      ))}
      <h6 style={{ marginTop: 12 }}>{c('Durum')}</h6>
      {(veri?.durumlar ?? []).map(d => (
        <button key={d.durum} type="button" className={`rt-dal${s.durum === d.durum ? ' on' : ''}`}
                onClick={() => s.setDurum(s.durum === d.durum ? null : d.durum)}>
          <span>{c(GOZ_CIHAZ_DURUM[d.durum] ?? String(d.durum))}</span><i>{d.sayi}</i></button>
      ))}
    </div>
  );
}

const sayi = (v: unknown) => (v === null || v === undefined ? '—' : String(v));

/**
 * jsonb SUNUCUDAN METİN OLARAK GELİR (Npgsql jsonb → string): `Object.entries`
 * doğrudan uygulanırsa metin KARAKTER KARAKTER dolaşılır ve eşleme tablosu
 * "0 → {", "1 → \"" diye çizilir. Hem metin hem nesne hâli karşılanıyor,
 * bozuk JSON'da boş nesne dönüyor - panel çökmesin.
 */
function jsonObje(ham: unknown): Record<string, unknown> {
  if (!ham) return {};
  if (typeof ham === 'object') return ham as Record<string, unknown>;
  try {
    const c = JSON.parse(String(ham));
    return c && typeof c === 'object' ? (c as Record<string, unknown>) : {};
  } catch { return {} }
}

/** Ölçüm eşlemesi: cihaz alanı → ölçüm kodu (jsonb anahtar/değer). */
function EslemeTablosu({ esleme }: { esleme: Record<string, unknown> }) {
  const satirlar = Object.entries(esleme ?? {});
  if (satirlar.length === 0) {
    return (
      <div className="sonuk">{c('Ölçüm eşlemesi tanımlı değil - gelen değerler ham kalır, '
        + 'trend ve eşik kontrolü çalışmaz.')}</div>
    );
  }
  return (
    <table className="gl-mini">
      <tbody>
        <tr><th>{c('Cihaz alanı')}</th><th>{c('Ölçüm')}</th></tr>
        {satirlar.map(([alan, kod]) => (
          <tr key={alan}><td>{alan}</td><td><b>{String(kod)}</b></td></tr>
        ))}
      </tbody>
    </table>
  );
}

const MESAJ_DURUM: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Bekliyor', sinif: 'uyari' },
  1: { ad: 'İşlendi', sinif: 'olumlu' },
  2: { ad: 'Sahipsiz', sinif: 'uyari' },
  3: { ad: 'Hata', sinif: 'hata' },
};

export function useGozCihazOnizleme(id: number | null, yenile: number) {
  const [r, setR] = useState<GozCihazOnizleme | null>(null);
  useEffect(() => {
    setR(null);
    if (id && id > 0) api.gozCihazOnizleme(id).then(setR).catch(() => setR(null));
  }, [id, yenile]);
  return r;
}

export function GozCihazOnizlemePaneli({ satir, yenile, onSina, onMesajlar, onDemirbas }: {
  satir: ListeSatiri | null; yenile: number;
  /** Hızlı işlem düğmeleri araç çubuğunun AYNI yolunu çağırır. */
  onSina?: () => void;
  onMesajlar?: () => void;
  onDemirbas?: () => void;
}) {
  const id = satir ? Number(satir.id) : 0;
  const r = useGozCihazOnizleme(id > 0 ? id : null, yenile);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir cihaz seçin.')}</div>;
  if (!r) return <div className="rt-oniz sonuk">{c('yükleniyor')}…</div>;
  const k = r.cihaz;
  const ayarlar = jsonObje(k.ayarlar);
  const adres = [String(ayarlar.ip ?? ''), ayarlar.port ? `:${String(ayarlar.port)}` : '']
    .filter(Boolean).join('') || String(k.baglanti ?? '');
  const demirbasli = Number(k.demirbasId ?? 0) > 0;

  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Cihaz')}</h5>
        <div className="rt-ad">{String(k.ad ?? '')}{k.model ? ` · ${String(k.model)}` : ''}</div>
        <div className="rt-kucuk sonuk">{c(GOZ_CIHAZ_TUR[Number(k.tur)] ?? '')}
          {k.seriNo ? ` · ${c('seri')} ${String(k.seriNo)}` : ''}</div>
        {String(k.oda ?? '') && <Satir s={c('Yer')} d={String(k.oda)} />}
        {String(k.sorumlu ?? '') && <Satir s={c('Sorumlu')} d={String(k.sorumlu)} />}
        <Satir s={c('Durum')} d={Number(k.aktif) === 0
          ? <span className="rozet gri">{c('Pasif')}</span>
          : Number(k.dinleyiciDurum) === 2
            ? <span className="rozet hata">{c('Bağlantı yok')}</span>
            : <span className="rozet olumlu">{c('Çalışıyor')}</span>} />
      </div>

      <div className="rt-bl"><h5>{c('Bağlantı')}</h5>
        <Satir s={c('Biçim')} d={c(GOZ_CIHAZ_PROTOKOL[Number(k.protokol)] ?? '—')} />
        <Satir s={c('Adres')} d={adres || '—'} />
        <Satir s={c('MWL')} d={Number(k.mwl) === 1 ? c('var') : c('yok')} />
        <Satir s={c('Son mesaj')} d={k.sonMesaj ? tarihSaat(k.sonMesaj) : '—'} />
        {/* SINAMA SONUCU saklanıyor: ekran her açılışta "bilinmiyor" derse
            kullanıcı aynı sınamayı tekrar tekrar çalıştırır. */}
        <Satir s={c('Son sınama')} d={k.sonSinama
          ? <>{tarihSaat(k.sonSinama)}<div className="rt-kucuk sonuk">{String(k.sonSinamaSonuc ?? '')}</div></>
          : c('hiç sınanmadı')} />
        {onSina && <div style={{ marginTop: 4 }}>
          <button type="button" className="d" onClick={onSina}>🔌 {c('Bağlantıyı sına')}</button></div>}
      </div>

      <div className="rt-bl"><h5>{c('Son 24 saat')}</h5>
        <Satir s={c('Gelen mesaj')} d={sayi(k.mesaj24s)} />
        <Satir s={c('İşlenen')} d={sayi(k.islenen24s)} />
        <Satir s={c('Eşlenmeyen')} d={Number(k.eslenmeyen ?? 0) > 0
          ? <b className="gz-kirmizi">{sayi(k.eslenmeyen)}</b> : '—'} />
        <Satir s={c('Hatalı')} d={Number(k.hatali ?? 0) > 0
          ? <b className="gz-kirmizi">{sayi(k.hatali)}</b> : '—'} />
        {/* ÇEKİM → EKRAN gecikmesi: cihaz "çalışıyor" görünüp geç veri
            gönderiyorsa hekim ölçümü muayene bitmeden göremiyor. */}
        <Satir s={c('Ortalama gecikme')} d={k.gecikmeSn != null
          ? `${Number(k.gecikmeSn)} ${c('sn')}` : '—'} />
        <Satir s={c('Bugün çekim')} d={sayi(k.bugunCekim)} />
      </div>

      <div className="rt-bl"><h5>{c('Ölçüm eşlemesi')}</h5>
        <EslemeTablosu esleme={jsonObje(k.olcumEsleme)} />
      </div>

      {r.tetkikler.length > 0 && (
        <div className="rt-bl"><h5>{c('Bu ay tetkikler')}</h5>
          {r.tetkikler.map(t => (
            <Satir key={t.tetkik} s={c(GOZ_TETKIK[t.tetkik] ?? String(t.tetkik))} d={String(t.sayi)} />
          ))}
        </div>
      )}

      {r.mesajlar.length > 0 && (
        <div className="rt-bl"><h5>{c('Son mesajlar')}</h5>
          {r.mesajlar.slice(0, 5).map(m => {
            const d = MESAJ_DURUM[Number(m.durum)] ?? { ad: '—', sinif: 'gri' };
            return (
              <div key={m.id} className="rt-kucuk" style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                <span>{tarihSaat(m.zaman)}</span>
                <span className={`rozet ${d.sinif}`}>{c(d.ad)}</span>
                <span className="sonuk">{m.hastaEslesme || m.hata || '—'}</span>
              </div>
            );
          })}
          {onMesajlar && <div style={{ marginTop: 4 }}>
            <button type="button" className="d" onClick={onMesajlar}>📨 {c('Mesaj kuyruğu')}</button></div>}
        </div>
      )}

      {/* KALİBRASYON: salt okuma, demirbaştan (kullanıcı kararı). */}
      <div className="rt-bl"><h5>{c('Kalibrasyon')} <span className="sonuk">({c('demirbaştan')})</span></h5>
        {!demirbasli ? (
          <div className="sonuk">{c('Cihaz demirbaşa bağlı değil - kalibrasyon ve bakım takip edilmiyor. '
            + 'Takip için cihaz kartından demirbaş kaydını bağlayın.')}</div>
        ) : (
          <>
            <Satir s={c('Demirbaş')} d={String(k.demirbasKod ?? '—')} />
            <Satir s={c('Periyot')} d={k.kalibrasyonPeriyotAy ? `${Number(k.kalibrasyonPeriyotAy)} ${c('ay')}` : '—'} />
            <Satir s={c('Son kalibrasyon')} d={k.sonKalibrasyon ? tarihYaz(String(k.sonKalibrasyon)) : '—'} />
            <Satir s={c('Geçerlilik')} d={k.kalibrasyonGecerlilik
              ? <>{tarihYaz(String(k.kalibrasyonGecerlilik))}{' '}
                {Number(k.kalibrasyonGecikmis) === 1
                  ? <span className="rozet hata">{c('geçti')}</span>
                  : <span className="rozet olumlu">{c('güncel')}</span>}</>
              : '—'} />
            <Satir s={c('Sonraki bakım')} d={k.sonrakiBakim ? tarihYaz(String(k.sonrakiBakim)) : '—'} />
            {r.kalibrasyonlar.length > 0 && (
              <div className="rt-kucuk" style={{ marginTop: 4 }}>
                {c('Son kayıt')}: {tarihYaz(r.kalibrasyonlar[0].tarih)}
                {r.kalibrasyonlar[0].referansCihaz ? ` · ${r.kalibrasyonlar[0].referansCihaz}` : ''}
              </div>
            )}
            {onDemirbas && <div style={{ marginTop: 4 }}>
              <button type="button" className="d" onClick={onDemirbas}>↗ {c('Demirbaş kartı')}</button></div>}
          </>
        )}
      </div>
    </div>
  );
}

function Satir({ s, d }: { s: string; d: ReactNode }) {
  return <div className="rt-satir"><span>{s}</span><b>{d}</b></div>;
}
