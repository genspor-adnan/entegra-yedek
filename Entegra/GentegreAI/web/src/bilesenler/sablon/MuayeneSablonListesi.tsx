import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj } from '../mesaj';
import { MuayeneSablonKarti } from './MuayeneSablonKarti';
import { c } from '../../dil/ceviri';

/**
 * MUAYENE ŞABLONLARI LİSTESİ — mockup `Ekranlar/Muayene/muayene_sablon_listesi.html`.
 *
 * BÖLÜM ve DOKTORA göre (kullanıcı): solda Bölüm › Doktor ağacı, ortada aynı
 * sırayla gruplu grid, sağda seçili şablonun özeti ve alanları. Doktoru boş
 * şablon bölümün ORTAK şablonu, dolu olan DOKTORA ÖZEL. ⭐ = bölümde muayene
 * açılınca önerilen şablon. Kullanım sayısı muayene.sablon_id'den (sunucu).
 */

type Cip = 'tumu' | 'benim' | 'ortak' | 'ozel';
type Dugum = { bolum: string | null; doktor: string | null };   // null = tümü

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);
const BOLUMSUZ = 'Genel (bölümsüz)';
const ORTAK = 'Bölüm ortak';
const bolumAdi = (r: ListeSatiri) => metin(r.bolumAdi) || BOLUMSUZ;
const doktorAdi = (r: ListeSatiri) => metin(r.doktorAdi) || ORTAK;
/** Bölümler ada göre, bölümsüz EN SONDA; doktorlar ada göre, "Bölüm ortak" EN ÖNDE. */
const bolumSirasi = (a: string, b: string) =>
  a === BOLUMSUZ ? 1 : b === BOLUMSUZ ? -1 : a.localeCompare(b, 'tr');
const doktorSirasi = (a: string, b: string) =>
  a === ORTAK ? -1 : b === ORTAK ? 1 : a.localeCompare(b, 'tr');
const TUR_AD: Record<number, string> = { 1: 'Fizik muayene', 2: 'Anamnez', 3: 'Sistem sorgusu' };
const sonKullanim = (v: unknown) => {
  const s = metin(v);
  if (!s) return '—';
  const g = Math.floor((Date.now() - new Date(s).getTime()) / 86400000);
  return g <= 0 ? c('bugün') : g === 1 ? c('dün') : g < 30 ? `${g} ${c('gün önce')}` : new Date(s).toLocaleDateString('tr-TR');
};

export function MuayeneSablonListesi() {
  const { kullanici, aksiyonVar } = useOturum();
  const yonetici = aksiyonVar('muayene.sablon_yonet');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [cip, setCip] = useState<Cip>('tumu');
  const [tur, setTur] = useState<number | null>(null);
  const [ara, setAra] = useState('');
  const [dugum, setDugum] = useState<Dugum>({ bolum: null, doktor: null });
  const [acik, setAcik] = useState<Set<string>>(new Set());
  const [secili, setSecili] = useState<number | null>(null);
  const [alanlar, setAlanlar] = useState<Record<string, unknown>[]>([]);
  const [kart, setKart] = useState<number | 'yeni' | null>(null);

  const yukle = useCallback(async () => {
    try {
      const y = await api.liste('muayene-sablon', { sayfa: 1, boyut: 1000 });
      setSatirlar(y.satirlar); setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, []);
  useEffect(() => { void yukle() }, [yukle]);

  // Seçili şablonun alanları (sağ panel).
  useEffect(() => {
    if (secili === null) { setAlanlar([]); return }
    let iptal = false;
    void api.kartOku('muayene-sablon', secili)
      .then(k => { if (!iptal) setAlanlar((k.detaylar?.alanlar ?? []) as Record<string, unknown>[]) })
      .catch(() => { if (!iptal) setAlanlar([]) });
    return () => { iptal = true };
  }, [secili]);

  const benimId = Number(kullanici?.id ?? 0);
  const cipUyar = (r: ListeSatiri) => {
    const aktif = sayi(r.durum) === 1;
    switch (cip) {
      case 'benim': return aktif && sayi(r.hekimId) === benimId;
      case 'ortak': return aktif && sayi(r.hekimId) === 0;
      case 'ozel': return aktif && sayi(r.hekimId) !== 0;
      default: return true;
    }
  };
  const arananMi = (r: ListeSatiri) => {
    const a = ara.trim().toLocaleLowerCase('tr');
    return !a || `${metin(r.ad)} ${metin(r.kod)} ${metin(r.doktorAdi)} ${metin(r.bolumAdi)}`
      .toLocaleLowerCase('tr').includes(a);
  };
  // Ağaç sayıları cip + tür + arama süzgecinden sonra; düğüm süzgeci gride uygulanır.
  const suzulmus = satirlar.filter(r => cipUyar(r) && (tur === null || sayi(r.tur) === tur) && arananMi(r));
  const gorunen = suzulmus.filter(r =>
    (dugum.bolum === null || bolumAdi(r) === dugum.bolum)
    && (dugum.doktor === null || doktorAdi(r) === dugum.doktor));

  /** Bölüm › Doktor ağacı: bölümler ada göre, "Bölüm ortak" önce. */
  const agac = useMemo(() => {
    const m = new Map<string, Map<string, number>>();
    suzulmus.forEach(r => {
      const b = bolumAdi(r), d = doktorAdi(r);
      if (!m.has(b)) m.set(b, new Map());
      m.get(b)!.set(d, (m.get(b)!.get(d) ?? 0) + 1);
    });
    return [...m.entries()].sort(([a], [b]) => bolumSirasi(a, b))
      .map(([b, dm]) => ({ bolum: b, toplam: [...dm.values()].reduce((x, y) => x + y, 0),
                           doktorlar: [...dm.entries()].sort(([a], [z]) => doktorSirasi(a, z)) }));
  }, [suzulmus]);

  /** Grid grupları: bölüm → doktor (ortak önce) → sıra/ad. */
  const gruplar = useMemo(() => {
    const m = new Map<string, Map<string, ListeSatiri[]>>();
    gorunen.forEach(r => {
      const b = bolumAdi(r), d = doktorAdi(r);
      if (!m.has(b)) m.set(b, new Map());
      m.get(b)!.set(d, [...(m.get(b)!.get(d) ?? []), r]);
    });
    return [...m.entries()].sort(([a], [b]) => bolumSirasi(a, b))
      .map(([b, dm]) => ({ bolum: b, doktorlar: [...dm.entries()]
        .sort(([a], [z]) => doktorSirasi(a, z))
        .map(([d, s]) => ({ doktor: d, satirlar: [...s].sort((x, y) => sayi(y.varsayilan) - sayi(x.varsayilan)
          || sayi(x.sira) - sayi(y.sira) || metin(x.ad).localeCompare(metin(y.ad), 'tr')) })) }));
  }, [gorunen]);

  const seciliSatir = satirlar.find(r => sayi(r.id) === secili) ?? null;
  const say = (f: (r: ListeSatiri) => boolean) => satirlar.filter(f).length;
  const cipler: { k: Cip; ad: string; n: number }[] = [
    { k: 'tumu', ad: 'Tümü', n: satirlar.length },
    { k: 'benim', ad: 'Benim', n: say(r => sayi(r.durum) === 1 && sayi(r.hekimId) === benimId) },
    { k: 'ortak', ad: 'Bölüm ortak', n: say(r => sayi(r.durum) === 1 && sayi(r.hekimId) === 0) },
    { k: 'ozel', ad: 'Doktora özel', n: say(r => sayi(r.durum) === 1 && sayi(r.hekimId) !== 0) },
  ];

  const kopyala = () => guvenli(async () => {
    if (secili === null) return;
    const y = await api.sablonKopyala(secili);
    mesaj(y.mesaj);
    await yukle();
    setSecili(y.id);
  });
  const varsayilanYap = () => guvenli(async () => {
    if (secili === null) return;
    const y = await api.sablonVarsayilan(secili);
    mesaj(y.mesaj);
    await yukle();
  });

  const acikMi = (b: string) => acik.has(b) || dugum.bolum === b;
  const bolumSec = (b: string | null) => {
    setDugum({ bolum: b, doktor: null });
    if (b) setAcik(s => { const n = new Set(s); if (n.has(b) && dugum.bolum === b) n.delete(b); else n.add(b); return n });
  };
  // Yeni şablonun varsayılan bölümü: ağaçta seçili bölümün id'si.
  const yeniBolumId = dugum.bolum
    ? sayi(satirlar.find(r => bolumAdi(r) === dugum.bolum)?.bolumId) || null : null;
  const seciliOrtak = seciliSatir !== null && sayi(seciliSatir.hekimId) === 0 && sayi(seciliSatir.bolumId) > 0;

  return (
    <div className="ms-liste">
      {/* ÜST ÇUBUK STANDART LİSTE GİBİ (kullanıcı: "sadece üstteki arama ve
          butonları standart listeye benzet"): GenGrid'in `sayfabas` başlık
          satırı - başlık, yol, sağda araç çubuğu - ve altında 🔍 arama kutulu
          çip şeridi. Ağaç + gruplu grid + önizleme aynen kalır. */}
      <div className="sayfabas">
        <div className="basrow">
          <h1>{c('Muayene Şablonları')}</h1>
          <span className="yol">{c('Muayene › Muayene Ayarları › Muayene Şablonları')}</span>
          <div className="sag">
            <div className="arac-cubugu">
              <button type="button" className="d bir" onClick={() => setKart('yeni')}><span>＋ {c('Yeni şablon')}</span></button>
              <button type="button" className="d" disabled={secili === null} onClick={() => secili !== null && setKart(secili)}
                      title={secili !== null && !yonetici && sayi(seciliSatir?.hekimId) !== benimId
                        ? c('Başkasının şablonu: görüntülenir; "Kopyala (bana)" ile uyarlayın') : ''}>
                <span>{secili !== null && !yonetici && sayi(seciliSatir?.hekimId) !== benimId ? `👁 ${c('Görüntüle')}` : `✎ ${c('Düzenle')}`}</span></button>
              <button type="button" className="d" disabled={secili === null} onClick={() => void kopyala()}
                      title={c('Seçili şablonu kendi şablonunuz olarak çoğaltır')}><span>⧉ {c('Kopyala (bana)')}</span></button>
              {/* Bölüm varsayılanı şablon YÖNETİCİSİNİN işi (929). */}
              {yonetici && (
                <button type="button" className="d" disabled={!seciliOrtak || sayi(seciliSatir?.varsayilan) === 1 || sayi(seciliSatir?.durum) !== 1}
                        title={c('Yalnız bölüm ortak ve aktif şablon')} onClick={() => void varsayilanYap()}>
                  <span>⭐ {c('Bölüm varsayılanı yap')}</span></button>
              )}
            </div>
          </div>
        </div>
      </div>
      <div className="cipler">
        <div className="ara-kutu dar">
          <span>🔍</span>
          <input type="search" value={ara} placeholder={c('Bu listede ara…')} aria-label={c('Şablon ara')}
                 onChange={e => setAra(e.target.value)} />
        </div>
        {cipler.map(x => (
          <button key={x.k} type="button" className={`cip${cip === x.k ? ' on' : ''}`} onClick={() => setCip(x.k)}>
            {c(x.ad)} ({x.n})
          </button>
        ))}
        <span className="ms-ayrac" />
        {[1, 2, 3].map(t => (
          <button key={t} type="button" className={`cip${tur === t ? ' on' : ''}`}
                  onClick={() => setTur(tur === t ? null : t)}>{c(TUR_AD[t])}</button>
        ))}
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="ms-uc">
        {/* SOL: BÖLÜM › DOKTOR */}
        <div className="ms-agac" role="tree" aria-label={c('Bölüm › Doktor')}>
          <div className="ms-agac-bas">{c('Bölüm › Doktor')}</div>
          <button type="button" className={`ms-d1${dugum.bolum === null ? ' on' : ''}`} onClick={() => bolumSec(null)}>
            🏥 {c('Tümü')}<span className="ms-say">{suzulmus.length}</span></button>
          {agac.map(b => (
            <div key={b.bolum}>
              <button type="button" className={`ms-d1${dugum.bolum === b.bolum && dugum.doktor === null ? ' on' : ''}`}
                      onClick={() => bolumSec(b.bolum)} aria-expanded={acikMi(b.bolum)}>
                <span className="ms-ok">{acikMi(b.bolum) ? '▾' : '▸'}</span>{b.bolum}<span className="ms-say">{b.toplam}</span>
              </button>
              {acikMi(b.bolum) && b.doktorlar.map(([d, n]) => (
                <button key={d} type="button"
                        className={`ms-d2${dugum.bolum === b.bolum && dugum.doktor === d ? ' on' : ''}`}
                        onClick={() => setDugum({ bolum: b.bolum, doktor: d })}>
                  {d === ORTAK ? '👥' : '👨‍⚕️'} {d}<span className="ms-say">{n}</span>
                </button>
              ))}
            </div>
          ))}
        </div>

        {/* ORTA: gruplu grid */}
        <div className="ms-grid">
          <table className="detay-tablo">
            <thead><tr>
              <th>{c('Şablon')}</th><th className="hiza-orta">{c('Kod')}</th><th className="hiza-orta">{c('Tür')}</th>
              <th className="hiza-orta">{c('Kapsam')}</th><th className="hiza-orta">{c('Alan')}</th>
              <th className="hiza-orta">{c('Kullanım (30 gün)')}</th><th className="hiza-orta">{c('Son kullanım')}</th>
              <th className="hiza-orta">{c('Durum')}</th>
            </tr></thead>
            <tbody>
              {gruplar.length === 0 && <tr><td colSpan={8} className="bos">{c('Şablon yok.')}</td></tr>}
              {gruplar.map(g => [
                <tr key={`b-${g.bolum}`} className="ms-g1"><td colSpan={8}>
                  {g.bolum} · {g.doktorlar.reduce((t, x) => t + x.satirlar.length, 0)} {c('şablon')}</td></tr>,
                ...g.doktorlar.flatMap(dk => [
                  <tr key={`d-${g.bolum}-${dk.doktor}`} className="ms-g2"><td colSpan={8}>
                    {dk.doktor === ORTAK ? '👥' : '👨‍⚕️'} {dk.doktor} · {dk.satirlar.length}</td></tr>,
                  ...dk.satirlar.map(r => {
                    const id = sayi(r.id);
                    const aktif = sayi(r.durum) === 1;
                    return (
                      <tr key={id} className={`tiklanir${secili === id ? ' secili' : ''}${aktif ? '' : ' ms-pasif'}`}
                          onClick={() => setSecili(id)} onDoubleClick={() => setKart(id)} title={c('Çift tık: kartı aç')}>
                        <td className="ms-ad">{sayi(r.varsayilan) === 1 && <span className="ms-yildiz" title={c('Bölüm varsayılanı')}>⭐ </span>}
                          {secili === id ? <b>{metin(r.ad)}</b> : metin(r.ad)}</td>
                        <td className="hiza-orta">{metin(r.kod)}</td>
                        <td className="hiza-orta"><span className={`rozet ${sayi(r.tur) === 1 ? 'mavi' : 'gri'}`}>{TUR_AD[sayi(r.tur)] ?? ''}</span></td>
                        <td className="hiza-orta">{sayi(r.hekimId) === 0 ? c('Bölüm ortak') : c('Doktora özel')}</td>
                        <td className="hiza-orta">{sayi(r.alanSayisi)}</td>
                        <td className="hiza-orta">
                          <span className="ms-kullanim"><i style={{ width: Math.min(60, sayi(r.kullanim30) / 3) }} />{sayi(r.kullanim30)}</span>
                        </td>
                        <td className="hiza-orta">{sonKullanim(r.sonKullanim)}</td>
                        <td className="hiza-orta"><span className={`rozet ${aktif ? 'olumlu' : 'gri'}`}>{aktif ? c('Aktif') : c('Pasif')}</span></td>
                      </tr>
                    );
                  }),
                ]),
              ])}
            </tbody>
          </table>
        </div>

        {/* SAĞ: seçili şablon */}
        <div className="ms-onz">
          {!seciliSatir ? <p className="not">{c('Soldan / gridden şablon seçin.')}</p> : (
            <>
              <div className="rk-blk">
                <h6>{c('Seçili şablon')}</h6>
                <div className="ms-onz-ad">{sayi(seciliSatir.varsayilan) === 1 && '⭐ '}{metin(seciliSatir.ad)}</div>
                <div className="rk-kv">
                  <span>{c('Bölüm')}</span><span>{bolumAdi(seciliSatir)}</span>
                  <span>{c('Kapsam')}</span><span>{sayi(seciliSatir.hekimId) === 0 ? c('Bölüm ortak') : `${c('Doktora özel')} · ${metin(seciliSatir.doktorAdi)}`}</span>
                  <span>{c('Tür')}</span><span>{TUR_AD[sayi(seciliSatir.tur)] ?? ''}</span>
                  <span>{c('Kullanım')}</span><span>{sayi(seciliSatir.kullanim30)} {c('muayene / 30 gün')}</span>
                  {sayi(seciliSatir.kaynakSablonId) > 0 && (<><span>{c('Kopyası')}</span><span>#{sayi(seciliSatir.kaynakSablonId)}</span></>)}
                </div>
              </div>
              <div className="rk-blk">
                <h6>{c('Alanlar')} ({alanlar.length})</h6>
                {[...alanlar].sort((a, b) => sayi(a.sira) - sayi(b.sira)).slice(0, 12).map((a, i) => (
                  <div key={i} className="ms-alan">{metin(a.ad)}<span className="sonuk">{metin(a.grup)}</span></div>
                ))}
                {alanlar.length > 12 && <div className="sonuk">… {alanlar.length - 12} {c('alan daha')}</div>}
              </div>
              <p className="not">{c('Doktora özel şablon yalnız sahibinin muayenesinde önerilir; "Kopyala (bana)" ortak şablonu doktorun kendi şablonu olarak çoğaltır.')}</p>
            </>
          )}
        </div>
      </div>
      <div className="ms-durum">
        <span>{satirlar.length} {c('şablon')} · {new Set(satirlar.map(bolumAdi)).size} {c('bölüm')} · {new Set(satirlar.filter(r => sayi(r.hekimId)).map(r => sayi(r.hekimId))).size} {c('doktor')}</span>
        <span className="sonuk">{c('Çift tık = şablon kartı · Gruplama: Bölüm › Doktor')}</span>
      </div>

      {kart !== null && (
        <MuayeneSablonKarti id={kart} varsayilanBolum={yeniBolumId}
          onKapat={() => { setKart(null); void yukle() }}
          onDegisti={() => void yukle()} />
      )}
    </div>
  );
}
