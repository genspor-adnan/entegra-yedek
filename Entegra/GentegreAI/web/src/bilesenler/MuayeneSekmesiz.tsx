import { basHarfler } from './basHarfler';
import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { c } from '../dil/ceviri';
import { tarihSaat } from './bicim';
import { OlcumGrafigi } from './OlcumGrafigi';
import { OncekiKopyaPenceresi } from './MuayeneSekmeleri';

/**
 * SEKMESİZ MUAYENE DÜZENİNİN ÜÇ PARÇASI (mockup Ekranlar/Muayene/muayene_karti_v7.html,
 * Ayarlar/hasta_bandi.html). Sekmeli düzen bunları KULLANMAZ - orada mevcut şerit ve
 * Özet sekmesi aynen kalır (kullanıcı: "sekmeli eski düzenimi bozma").
 *
 *  - MuayeneHastaBandi: başlık = hasta bandı (kimlik · kan · alerji/kronik · uyarılar · şu an).
 *  - MuayeneSolMenu: tamamlama kontrolü maddeleri HEM menü HEM kontrol (✓ / ⚠ / –),
 *    altında işlemler; tıklayınca ilgili bölüme kaydırır.
 *  - MuayeneYanPanel: kullandığı ilaçlar, son sonuçlar (📈), önceki muayeneler (↺ seçmeli kopyala).
 */
type Satir = Record<string, unknown>;
const m = (v: unknown) => String(v ?? '').trim();
const onekli = (on: string, v: string) => !v ? '' : /^[A-ZÇĞİÖŞÜ]+-/.test(v) ? v : `${on} ${v}`;

export interface MuayeneHastaBilgisi {
  ust: Satir | null; alerji: Satir[]; kronik: Satir[]; ilac: Satir[];
  sonuclar: Awaited<ReturnType<typeof api.muayeneSonSonuclar>>;
  band: Awaited<ReturnType<typeof api.muayeneBand>>;
}

async function listele(kaynak: string, hastaId: number): Promise<Satir[]> {
  try {
    const y = await api.liste(kaynak, { sayfa: 1, boyut: 20, filtre: { alan: 'hastaId', op: 'esit', deger: hastaId } });
    return (y.satirlar ?? []) as Satir[];
  } catch { return [] }
}

/** Band ve sağ sütunun ORTAK verisi (tek yükleme). */
export function useMuayeneHastaBilgisi(muayeneId: number, tazele: number): MuayeneHastaBilgisi | null {
  const [b, setB] = useState<MuayeneHastaBilgisi | null>(null);
  useEffect(() => {
    if (!(muayeneId > 0)) return;
    let iptal = false;
    void (async () => {
      let ust: Satir | null = null;
      try {
        const y = await api.liste('muayene', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: muayeneId } });
        ust = (y.satirlar?.[0] ?? null) as Satir | null;
      } catch { /* band zorunlu değil */ }
      const hastaId = Number(ust?.tarafId ?? 0);
      const [a, k, i, s, bd] = await Promise.all([
        hastaId > 0 ? listele('hasta-alerji', hastaId) : [],
        hastaId > 0 ? listele('hasta-kronik', hastaId) : [],
        hastaId > 0 ? listele('hasta-ilac', hastaId) : [],
        api.muayeneSonSonuclar(muayeneId).catch(() => []),
        api.muayeneBand(muayeneId).catch(() => ({})),
      ]);
      if (iptal) return;
      setB({
        ust,
        alerji: a.filter(x => Number(x.aktif ?? 1) === 1),
        kronik: k.filter(x => Number(x.durum ?? 1) !== 0),
        ilac: i.filter(x => Number(x.aktif ?? 1) === 1),
        sonuclar: s, band: bd,
      });
    })();
    return () => { iptal = true };
  }, [muayeneId, tazele]);
  return b;
}

/* ================================================================ BAND ==== */

/** "174 cm · 86 kg" ve ayrı satırda "VKİ 28,4" (kullanıcı 14.10.2026) - olmayan parça yazılmaz. */
function antropometri(bd: MuayeneHastaBilgisi['band'] | undefined): { boyKilo: string; vki: string } {
  const say = (v: unknown) => { const n = Number(v ?? 0); return n > 0 ? n : 0 };
  const sayi = (n: number, h: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: h });
  const boy = say(bd?.boyCm), kilo = say(bd?.kiloKg), bki = say(bd?.bki);
  return {
    boyKilo: [boy ? `${sayi(boy, 0)} cm` : '', kilo ? `${sayi(kilo, 1)} kg` : ''].filter(Boolean).join(' · '),
    vki: bki ? `VKİ ${sayi(bki, 1)}` : '',
  };
}

export function MuayeneHastaBandi({ bilgi }: { bilgi: MuayeneHastaBilgisi | null }) {
  const [alerjiAcik, setAlerjiAcik] = useState(false);
  const u = bilgi?.ust ?? null;
  const ad = m(u?.hastaAdi);
  const bas = basHarfler(ad);
  const panik = (bilgi?.sonuclar ?? []).filter(s => Number(s.panik ?? 0) === 1);
  const cins = m(u?.cinsiyetKisa);
  return (
    <div className="hbnd">
      <div className="hbnd-foto">{bas || '?'}</div>
      <div className="hbnd-kim">
        <div className="hbnd-ad">{ad || '—'}
          {Number(bilgi?.band.ayniAd ?? 0) > 0 && (
            <span className="hbnd-ayni" title={c('Bu kurumda aynı ad soyadlı başka hasta var')}>
              {c('AYNI AD')} ×{bilgi?.band.ayniAd}</span>
          )}
        </div>
        <div className="hbnd-alt"><b>{cins}{m(u?.yasMetni) ? ` ${m(u?.yasMetni)}` : ''}</b>
          {/* Yaşın sağında BU BAŞVURUNUN kurumu ve varsa sözleşmesi (kullanıcı 14.10.2026). */}
          {m(bilgi?.band.kurum) && <> · <b>{m(bilgi?.band.kurum)}</b></>}
          {m(bilgi?.band.sozlesme) && <span className="not"> · {m(bilgi?.band.sozlesme)}</span>}</div>
        {/* D / P: numara kendi önekini taşıyorsa ("H-000079", "P-000154") tekrar eklenmez. */}
        <div className="hbnd-alt">{[onekli('D', m(u?.dosyaNo)), onekli('P', m(u?.protokolNo))].filter(Boolean).join(' · ')}</div>
      </div>
      <div className="hbnd-blok">
        <span className={`hbnd-kg${m(bilgi?.band.kanGrubu) ? '' : ' yok'}`}>{m(bilgi?.band.kanGrubu) || c('kan grubu ?')}</span>
        {/* BOY · KİLO · VKİ (mockup v7): hastanın son girilen değerleri. */}
        {antropometri(bilgi?.band).boyKilo && <div className="hbnd-alt" title={c('Son boy / kilo')}>{antropometri(bilgi?.band).boyKilo}</div>}
        {antropometri(bilgi?.band).vki && <div className="hbnd-alt" title={c('Vücut kitle indeksi')}>{antropometri(bilgi?.band).vki}</div>}
        {m(u?.sonVital) && <div className="hbnd-alt" title={c('Son vital')}>{m(u?.sonVital)}</div>}
      </div>
      <div className="hbnd-blok">
        <div className="hbnd-b">{c('Alerji / Kronik')}</div>
        <div className="hbnd-rozetler">
          {bilgi && bilgi.alerji.length === 0 && <span className="rozet olumlu">{c('Alerji: yok')}</span>}
          {(bilgi?.alerji.length ?? 0) > 0 && (
            <span className="rozet hata hbnd-tik" onClick={() => setAlerjiAcik(a => !a)}>
              ⚠ {m(bilgi!.alerji[0].etken) || m(bilgi!.alerji[0].etkenMadde)}
              {bilgi!.alerji.length > 1 ? ` +${bilgi!.alerji.length - 1}` : ''}
            </span>
          )}
          {(bilgi?.kronik ?? []).slice(0, 3).map((k, i) => (
            <span key={i} className="rozet uyari" title={m(k.taniAd) || m(k.icdKod)}>{m(k.taniAd) || m(k.icdKod)}</span>
          ))}
          {(bilgi?.kronik.length ?? 0) > 3 && <span className="rozet gri">+{bilgi!.kronik.length - 3}</span>}
        </div>
      </div>
      <div className="hbnd-blok hbnd-genis">
        <div className="hbnd-b">{c('Uyarılar')}</div>
        <div className="hbnd-rozetler">
          {panik.map((s, i) => <span key={i} className="rozet hata">{c('Panik sonuç')}: {m(s.ad)}</span>)}
          {m(u?.uyari) && <span className="rozet uyari">{m(u?.uyari)}</span>}
          {panik.length === 0 && !m(u?.uyari) && <span className="not">—</span>}
        </div>
      </div>
      <div className="hbnd-blok hbnd-simdi">
        <div className="hbnd-b">{c('Şu an')}</div>
        <div><b>{m(u?.bolumAdi) || '—'}</b></div>
        <div className="hbnd-alt">{m(u?.hekimAdi)}{u?.baslangic ? ` · ${tarihSaat(u.baslangic).slice(11)}` : ''}</div>
      </div>
      {alerjiAcik && bilgi && (
        <div className="hbnd-ayr" onClick={() => setAlerjiAcik(false)}>
          <h5>⚠ {c('Alerjiler')} ({bilgi.alerji.length})</h5>
          {bilgi.alerji.map((a, i) => (
            <div key={i} className="hbnd-ayr-s"><b>{m(a.etken) || m(a.etkenMadde)}</b>
              {m(a.turAdi) && ` · ${m(a.turAdi)}`}{m(a.reaksiyon) && ` · ${m(a.reaksiyon)}`}</div>
          ))}
        </div>
      )}
    </div>
  );
}

/* ============================================================ SOL MENÜ ==== */

export interface KontrolMaddesi { alan: string; ad: string; tamam: boolean; mesaj: string; zorunlu: boolean }

export function MuayeneSolMenu({ kontrol, git, muayeneyeAl, istemRozeti, islemler, gorunum, onGorunum, eylemler }: {
  kontrol: KontrolMaddesi[] | null;
  /** ÖZET / DETAY (kullanıcı 14.10.2026): özet = orta kısımda yalnız özet; detay = özetsiz tüm
      bölümler. Varsayılan: muayene tamamlandıysa özet, değilse detay. */
  gorunum?: 'ozet' | 'detay';
  onGorunum?(g: 'ozet' | 'detay'): void;
  git(baslik: string): void;
  muayeneyeAl(): void;
  /** İstem maddesinin yanında "3/5". */
  istemRozeti?: string;
  islemler: { ad: string; ikon: string; bilgi?: string; ac(): void }[];
  /** Madde EKSİKSE doğrudan açılan ekleme ekranları (kullanıcı 15.10.2026: "ana tanı tıklayınca
      veri varsa onun üzerine konumlansın yoksa seçme ekranı direkt açılsın; tetkik istem ve
      reçete de aynı desen"). */
  eylemler?: { taniEkle(): void; istemAc(): void; ilacEkle(): void };
}) {
  // Kontrol maddesi → bölüm (Özet sekmesindeki eşlemenin aynısı).
  const hedef: Record<string, (tamam: boolean) => void> = {
    baslangic: muayeneyeAl, sikayet: () => git('Muayene'), fizik: () => git('Fizik muayene'),
    tanilar: tamam => tamam || !eylemler ? git('Tanı') : eylemler.taniEkle(),
    istem: tamam => tamam || !eylemler ? git('İstem') : eylemler.istemAc(),
    recete: tamam => tamam || !eylemler ? git('e-Reçete') : eylemler.ilacEkle(),
    karar: () => git('Muayene'),
    cikisSekli: () => git('Muayene'),
  };
  const eksik = (kontrol ?? []).filter(k => k.zorunlu && !k.tamam).length;
  return (
    <>
      <div className="kanav-g bas smn-gorunum">
        <div className={`kanav-o smn-g${gorunum === 'ozet' ? ' on' : ''}`} onClick={() => onGorunum ? onGorunum('ozet') : git('Özet')}>
          <span className="kanav-d">≡</span><span>{c('Özet')}</span></div>
        {onGorunum && <div className={`kanav-o smn-g${gorunum === 'detay' ? ' on' : ''}`} onClick={() => onGorunum('detay')}>
          <span className="kanav-d">☰</span><span>{c('Detay')}</span></div>}
      </div>
      <div className="kanav-g">
        <h6>{c('Tamamlama')}<i className={eksik === 0 ? 'tamam' : ''}>{kontrol === null ? '…' : eksik === 0 ? c('hazır') : `${eksik} ${c('eksik')}`}</i></h6>
        {(kontrol ?? []).map(k => (
          <div key={k.alan} className={`kanav-o smn-k${k.tamam ? ' ok' : k.zorunlu ? ' eksik' : ''}`}
               title={k.tamam ? undefined : k.mesaj} onClick={() => hedef[k.alan]?.(k.tamam)}>
            {/* Mockup v7 dizini: dolu yuvarlak - tamam yeşil ✓, zorunlu eksik kırmızı !, isteğe bağlı eksik boş halka. */}
            <span className={`smn-d ${k.tamam ? 'smn-d-ok' : k.zorunlu ? 'smn-d-kir' : 'smn-d-bos'}`}>{k.tamam ? '✓' : k.zorunlu ? '!' : ''}</span>
            <span>{c(k.ad)}</span>
            {k.alan === 'istem' && istemRozeti && <small>{istemRozeti}</small>}
          </div>
        ))}
      </div>
      <div className="kanav-g kanav-ek">
        <h6>{c('İşlemler')}</h6>
        {islemler.map(i => (
          <div key={i.ad} className="kanav-o" onClick={i.ac}>
            <span className="kanav-d">{i.ikon}</span><span>{c(i.ad)}</span>{i.bilgi && <small>{i.bilgi}</small>}
          </div>
        ))}
      </div>
    </>
  );
}

/* ========================================================== SAĞ SÜTUN ==== */

export function MuayeneYanPanel({ muayeneId, bilgi, gecmis, onKopyalandi, tazele = 0 }: {
  muayeneId: number;
  bilgi: MuayeneHastaBilgisi | null;
  gecmis: Satir[];
  onKopyalandi(): void;
  /** İstem açılınca / kaydedilince bekleyen istemler yeniden okunur. */
  tazele?: number;
}) {
  const [grafik, setGrafik] = useState<string | null>(null);
  const [kopya, setKopya] = useState<number | null>(null);
  // BEKLEYEN İSTEMLER (kullanıcı 14.10.2026: sekmesiz kartta özetten sağ bandın altına).
  const [bekleyen, setBekleyen] = useState<{ ad: string; durum: string; acil: boolean }[] | null>(null);
  useEffect(() => {
    if (!(muayeneId > 0)) return;
    let iptal = false;
    void api.muayeneSonuclari(muayeneId).then(y0 => {
      if (iptal) return;
      const y = y0 as unknown as { istemler?: Satir[]; radyoloji?: Satir[]; goz?: Satir[]; patoloji?: Satir[] };
      const sayi = (x: unknown) => Number(x ?? 0);
      setBekleyen([
        ...(y.istemler ?? []).filter(i => ![5, 9].includes(sayi(i.durum ?? 1))).map(i => ({
          ad: `${c('Lab')} ${m(i.istemNo)}`, durum: `${sayi(i.onayli)}/${sayi(i.tetkik)} ${c('onaylı')}`, acil: sayi(i.oncelik) === 3 })),
        ...(y.radyoloji ?? []).filter(r => !r.onayTarihi).map(r => ({
          ad: m(r.tetkik), durum: r.cekimTarihi ? c('rapor bekliyor') : c('sırada'), acil: false })),
        ...(y.patoloji ?? []).filter(v => sayi(v.durum) < 11 && ![0, 90].includes(sayi(v.durum))).map(v => ({
          ad: `🔬 ${m(v.vakaNo)}`, durum: sayi(v.serbest ?? 1) === 0 ? c('başvuru bekliyor') : c('çalışılıyor'), acil: false })),
      ]);
    }).catch(() => { if (!iptal) setBekleyen([]) });
    return () => { iptal = true };
  }, [muayeneId, tazele]);
  return (
    <div className="myp">
      <div className="myp-k">
        <div className="myp-b">{c('Kullandığı ilaçlar')}</div>
        {bilgi && bilgi.ilac.length === 0 && <div className="not">{c('Kayıtlı ilaç yok.')}</div>}
        {(bilgi?.ilac ?? []).map((i, n) => (
          <div key={n} className="myp-s">{m(i.ilacAd)}<span className="not">{[m(i.doz), m(i.periyot)].filter(Boolean).join(' ')}</span></div>
        ))}
      </div>
      <div className="myp-k">
        <div className="myp-b">{c('Son sonuçlar')} <span className="not">· {c('tıkla: grafik')}</span></div>
        {bilgi && bilgi.sonuclar.length === 0 && <div className="not">{c('Onaylı sonuç yok.')}</div>}
        {(bilgi?.sonuclar ?? []).map((s, n) => {
          const kir = Number(s.panik ?? 0) === 1 || ['H', 'L', 'HH', 'LL'].includes(m(s.bayrak));
          return (
            <div key={n} className="myp-s myp-tik" onClick={() => setGrafik(s.kod)}>
              <span className={kir ? 'myp-kir' : ''}>{s.ad} {s.deger}{s.birim ? ` ${s.birim}` : ''}</span>
              <span className="not">{tarihSaat(s.zaman).slice(0, 10)} 📈</span>
            </div>
          );
        })}
      </div>
      <div className="myp-k">
        <div className="myp-b">{c('Önceki muayeneler')} <span className="not">· ↺ {c('kopyala')}</span></div>
        {gecmis.length === 0 && <div className="not">{c('Önceki muayene yok.')}</div>}
        {gecmis.slice(0, 6).map(g => (
          <div key={String(g.id)} className="myp-s">
            <span>{tarihSaat(g.tarih).slice(0, 10)} · {m(g.bolum) || m(g.hekim)}
              <span className="not"> {m(g.tanilar) || m(g.ozet)}</span></span>
            <button type="button" className="myp-kopya" title={c('Seçerek bu muayeneye kopyala')}
                    onClick={() => setKopya(Number(g.id))}>↺</button>
          </div>
        ))}
      </div>
      <div className="myp-k">
        <div className="myp-b">{c('Bekleyen istemler')}</div>
        {bekleyen && bekleyen.length === 0 && <div className="not">{c('Bekleyen istem yok.')}</div>}
        {(bekleyen ?? []).map((b, n) => (
          <div key={n} className="myp-s">
            <span>{b.acil && <span className="rozet hata">{c('Acil')}</span>} {b.ad}</span>
            <span className="not">{b.durum}</span>
          </div>
        ))}
      </div>
      <div className="myp-k">
        <div className="myp-b">{c('Son 3 Muayene')}</div>
        {gecmis.length === 0 && <div className="not">{c('Önceki muayene yok.')}</div>}
        {gecmis.slice(0, 3).map((g, n) => (
          <div key={n} className="myp-s" style={{ display: 'block' }} title={m(g.anaTani) || m(g.ozet)}>
            <div>{tarihSaat(g.tarih).slice(0, 10)}{m(g.hekim) ? <span className="not"> · {m(g.hekim)}</span> : null}</div>
            <div className="not" style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              {m(g.anaTani) || m(g.ozet) || '—'}</div>
          </div>
        ))}
      </div>
      {grafik && <OlcumGrafigi muayeneId={muayeneId} secim={{ tetkik: grafik }} onKapat={() => setGrafik(null)} />}
      {kopya !== null && <OncekiKopyaPenceresi muayeneId={muayeneId} kaynakId={kopya}
                                               onKapat={() => setKopya(null)} onKopyalandi={onKopyalandi} />}
    </div>
  );
}
