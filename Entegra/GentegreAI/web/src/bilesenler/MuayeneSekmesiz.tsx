import { basHarfler } from './basHarfler';
import { useEffect, useState, type ReactNode } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { c } from '../dil/ceviri';
import { mesaj } from './mesaj';
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
  /** Alerji listesi OKUNAMADI (ağ / yetki / sunucu): "yok" değil "bilinmiyor" - band yeşil rozet basmaz (K24). */
  alerjiHata: boolean;
  sonuclar: Awaited<ReturnType<typeof api.muayeneSonSonuclar>>;
  band: Awaited<ReturnType<typeof api.muayeneBand>>;
}

/** Hata = null (K24): boş dizi "kayıt yok" demektir, okunamayan liste onunla karışmamalı. */
async function listele(kaynak: string, hastaId: number): Promise<Satir[] | null> {
  try {
    const y = await api.liste(kaynak, { sayfa: 1, boyut: 20, filtre: { alan: 'hastaId', op: 'esit', deger: hastaId } });
    return (y.satirlar ?? []) as Satir[];
  } catch { return null }
}

/** Band ve sağ sütunun ORTAK verisi (tek yükleme). */
export function useMuayeneHastaBilgisi(muayeneId: number, tazele: number, hastaIdYedek = 0): MuayeneHastaBilgisi | null {
  const [b, setB] = useState<MuayeneHastaBilgisi | null>(null);
  useEffect(() => {
    if (!(muayeneId > 0) && !(hastaIdYedek > 0)) { setB(null); return }
    let iptal = false;
    void (async () => {
      let ust: Satir | null = null;
      // MUAYENESİZ KART (listeden yeni sevk / konsültasyon, kullanıcı 15.10.2026): band hastanın
      //   EN SON muayenesinden - ad, yaş, kurum, alerji, uyarılar oradan gelir.
      let mid = muayeneId;
      try {
        const y = mid > 0
          ? await api.liste('muayene', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: mid } })
          : await api.liste('muayene', { sayfa: 1, boyut: 1, filtre: { alan: 'hastaId', op: 'esit', deger: hastaIdYedek },
                                         sirala: [{ alan: 'muayeneTarihi', yon: 'desc' }, { alan: 'id', yon: 'desc' }] });
        ust = (y.satirlar?.[0] ?? null) as Satir | null;
        if (!(mid > 0)) mid = Number(ust?.id ?? 0);
      } catch { /* band zorunlu değil */ }
      // HİÇ MUAYENESİ YOKSA band hasta kaydından: ad, dosya no, cinsiyet, yaş (+ alerji / kronik aşağıda).
      if (!ust && hastaIdYedek > 0) {
        try {
          const y = await api.liste('hasta', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: hastaIdYedek } });
          const h = y.satirlar?.[0] as Satir | undefined;
          if (h) ust = { tarafId: h.id, hastaAdi: h.unvan, dosyaNo: h.kod, yasMetni: h.yas != null ? `${h.yas}y` : '',
                         cinsiyetKisa: Number(h.cinsiyet) === 1 ? 'E' : Number(h.cinsiyet) === 2 ? 'K' : '' } as Satir;
        } catch { /* band zorunlu değil */ }
      }
      if (!ust) { if (!iptal) setB(null); return }
      const muayeneId2 = mid;
      const hastaId = Number(ust?.tarafId ?? 0);
      const [a, k, i, s, bd] = await Promise.all([
        hastaId > 0 ? listele('hasta-alerji', hastaId) : [],
        hastaId > 0 ? listele('hasta-kronik', hastaId) : [],
        hastaId > 0 ? listele('hasta-ilac', hastaId) : [],
        muayeneId2 > 0 ? api.muayeneSonSonuclar(muayeneId2).catch(() => []) : Promise.resolve([]),
        muayeneId2 > 0 ? api.muayeneBand(muayeneId2).catch(() => ({})) : Promise.resolve({}),
      ]);
      if (iptal) return;
      setB({
        ust,
        alerji: (a ?? []).filter(x => Number(x.aktif ?? 1) === 1),
        alerjiHata: a === null,
        kronik: (k ?? []).filter(x => Number(x.durum ?? 1) !== 0),
        ilac: (i ?? []).filter(x => Number(x.aktif ?? 1) === 1),
        sonuclar: s, band: bd,
      });
    })();
    return () => { iptal = true };
  }, [muayeneId, tazele, hastaIdYedek]);
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

/** Banttaki rozet metni: ilk 14 harf, uzunsa "…" (tamamı title'da). */
const kisa = (t: string) => (t.length > 15 ? `${t.slice(0, 14).trimEnd()}…` : t);

export function MuayeneHastaBandi({ bilgi, onSuAn, kanGrubuYok, sonBlok, suAnYerine }: {
  bilgi: MuayeneHastaBilgisi | null; onSuAn?(): void;
  /** Kan grubu gösterilmez (radyoloji raporu, kullanıcı 27.10.2026). */
  kanGrubuYok?: boolean;
  /** Bandın SONUNA ekranın kendi blok(lar)ı (radyoloji raporunda Yazan · Onaylayacak/Onaylayan · Durum). */
  sonBlok?: ReactNode | ReactNode[];
  /** "Şu an" bloğunun YERİNE (radyoloji raporunda İsteyen: hekim · bölüm - istemin muayenesi yok). */
  suAnYerine?: ReactNode;
}) {
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
      {/* Kan grubu gizliyken ve ölçüm yoksa blok hiç çizilmez (boş sütun kalmasın). */}
      {(!kanGrubuYok || antropometri(bilgi?.band).boyKilo || antropometri(bilgi?.band).vki || m(u?.sonVital)) && <div className="hbnd-blok">
        {!kanGrubuYok && <span className={`hbnd-kg${m(bilgi?.band.kanGrubu) ? '' : ' yok'}`}>{m(bilgi?.band.kanGrubu) || c('kan grubu ?')}</span>}
        {/* BOY · KİLO · VKİ (mockup v7): hastanın son girilen değerleri. */}
        {antropometri(bilgi?.band).boyKilo && <div className="hbnd-alt" title={c('Son boy / kilo')}>{antropometri(bilgi?.band).boyKilo}</div>}
        {antropometri(bilgi?.band).vki && <div className="hbnd-alt" title={c('Vücut kitle indeksi')}>{antropometri(bilgi?.band).vki}</div>}
        {m(u?.sonVital) && <div className="hbnd-alt" title={c('Son vital')}>{m(u?.sonVital)}</div>}
      </div>}
      <div className="hbnd-blok">
        <div className="hbnd-b">{c('Alerji / Kronik')}</div>
        <div className="hbnd-rozetler">
          {/* "YOK" ile "BİLİNMİYOR" ayrı (K24): liste okunamadıysa yeşil rozet yerine uyarı. */}
          {bilgi && bilgi.alerjiHata && <span className="rozet uyari" title={c('Alerji listesi okunamadı - kartı yenileyin')}>⚠ {c('Alerji: ?')}</span>}
          {bilgi && !bilgi.alerjiHata && bilgi.alerji.length === 0 && <span className="rozet olumlu">{c('Alerji: yok')}</span>}
          {/* KISA (kullanıcı 15.10.2026: "alerji/kronik bilgiler daha kısa gelsin"): ad kısaltılır,
              tamamı ipucunda; kronikte en çok 2 rozet + kalan sayısı. */}
          {(bilgi?.alerji.length ?? 0) > 0 && (
            <span className="rozet hata hbnd-tik"
                  title={bilgi!.alerji.map(a => m(a.etken) || m(a.etkenMadde)).join(', ')}
                  onClick={() => setAlerjiAcik(a => !a)}>
              ⚠ {kisa(m(bilgi!.alerji[0].etken) || m(bilgi!.alerji[0].etkenMadde))}
              {bilgi!.alerji.length > 1 ? ` +${bilgi!.alerji.length - 1}` : ''}
            </span>
          )}
          {(bilgi?.kronik ?? []).slice(0, 2).map((k, i) => (
            <span key={i} className="rozet uyari" title={[m(k.icdKod), m(k.taniAd)].filter(Boolean).join(' ')}>
              {kisa(m(k.taniAd) || m(k.icdKod))}</span>
          ))}
          {(bilgi?.kronik.length ?? 0) > 2 && (
            <span className="rozet gri" title={bilgi!.kronik.slice(2).map(k => m(k.taniAd) || m(k.icdKod)).join(', ')}>
              +{bilgi!.kronik.length - 2}</span>
          )}
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
      {/* "Şu an" tıklanır (onSuAn verilirse): muayene bilgisi (bölüm / hekim / tür) penceresi -
          sekmeli muayenede eski bağlam şeridinin "Bugün ✎" kutusunun yerini tutar (16.10.2026). */}
      {suAnYerine ? <div className={`hbnd-blok hbnd-simdi${sonBlok ? ' hbnd-arada' : ''}`}>{suAnYerine}</div> : <div className={`hbnd-blok hbnd-simdi${onSuAn ? ' hbnd-tik' : ''}`} onClick={onSuAn}
           role={onSuAn ? 'button' : undefined} title={onSuAn ? c('Muayene bilgisini düzenle') : undefined}>
        <div className="hbnd-b">{c('Şu an')}{onSuAn && ' ✎'}</div>
        <div><b>{m(u?.bolumAdi) || '—'}</b></div>
        <div className="hbnd-alt">{m(u?.hekimAdi)}{u?.baslangic ? ` · ${tarihSaat(u.baslangic).slice(11)}` : ''}</div>
      </div>}
      {(Array.isArray(sonBlok) ? sonBlok : [sonBlok]).filter(Boolean).map((b, i) => <div key={i} className="hbnd-blok">{b}</div>)}
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

export function MuayeneSolMenu({ kontrol, git, muayeneyeAl, istemRozeti, islemler, gorunum, onGorunum, eylemler, sayac }: {
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
  /** MADDE ADETLERİ (kullanıcı 15.10.2026): kontrol maddesi alanı → sağdaki küçük yazı (yalnız varsa). */
  sayac?: Record<string, string>;
}) {
  // Kontrol maddesi → bölüm (Özet sekmesindeki eşlemenin aynısı).
  const hedef: Record<string, (tamam: boolean) => void> = {
    baslangic: muayeneyeAl, sikayet: () => git('Muayene'), fizik: () => git('Fizik muayene'),
    tanilar: tamam => tamam || !eylemler ? git('Tanı') : eylemler.taniEkle(),
    // TETKİK İSTEM: istem olsa da yeni istem ekranı doğrudan (kullanıcı 15.10.2026); kaydedilince ortada.
    istem: () => eylemler ? eylemler.istemAc() : git('İstem'),
    recete: tamam => tamam || !eylemler ? git('e-Reçete') : eylemler.ilacEkle(),
    // Değerlendirme / Sonuç çerçevesine (reçetenin altında) - kullanıcı 15.10.2026.
    karar: () => git('Değerlendirme'),
    cikisSekli: () => git('Değerlendirme'),
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
            {(sayac?.[k.alan] ?? (k.alan === 'istem' ? istemRozeti : undefined))
              && <small>{sayac?.[k.alan] ?? istemRozeti}</small>}
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

/**
 * KULLANDIĞI İLAÇLAR - ✎ / 💾 (kullanıcı 16.10.2026: "tıkladığımda edit moda geçmeli ve sürekli
 * kullandığı ilaçları kısa isimlerle eklemeliyim"). Düzenlemede kısa adla yazılır ("Coraspin 100
 * 1x1"), Enter ekler; sondaki "1x1" / "2x1" periyot olarak ayrılır. × ilacı BIRAKILDI yapar (kartın
 * "Bıraktı"sı: aktif 0, uyum 3, bitiş bugün) - kayıt silinmez, geçmişte kalır.
 */
function IlacKutusu({ bilgi, onDegisti }: { bilgi: MuayeneHastaBilgisi | null; onDegisti?(): void }) {
  const [duzen, setDuzen] = useState(false);
  const [metin, setMetin] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const hastaId = Number(bilgi?.ust?.tarafId ?? 0);
  const ilaclar = bilgi?.ilac ?? [];
  const ekle = async () => {
    const t = metin.trim();
    if (!t || !(hastaId > 0) || mesgul) return;
    const p = /\s+(\d+\s*[x×]\s*\d+)$/i.exec(t);
    setMesgul(true);
    try {
      await api.kartEkle('hasta-ilac', { kart: {
        hastaId, ilacAd: p ? t.slice(0, p.index).trim() : t, periyot: p ? p[1].replace(/\s+/g, '').replace('×', 'x') : '',
        kaynak: 2, uyum: 1, aktif: 1 } });
      setMetin('');
      onDegisti?.();
    } catch (h) { mesaj(hataMetni(h)) }
    finally { setMesgul(false) }
  };
  const birak = async (id: number) => {
    setMesgul(true);
    try {
      const k = await api.kartOku('hasta-ilac', id);
      await api.kartGuncelle('hasta-ilac', id, { surum: k.kart.surum as string | undefined,
        kart: { aktif: 0, uyum: 3, bitis: new Date().toLocaleDateString('sv-SE') } });
      onDegisti?.();
    } catch (h) { mesaj(hataMetni(h)) }
    finally { setMesgul(false) }
  };
  return (
    <div className="myp-k">
      <div className="myp-b myp-tik" onClick={() => setDuzen(d => !d)} title={duzen ? c('Gösterime dön') : c('Düzenle')}>
        {c('Kullandığı ilaçlar')} <span className="not">{duzen ? '💾' : '✎'}</span></div>
      {bilgi && ilaclar.length === 0 && !duzen && <div className="not">{c('Kayıtlı ilaç yok.')}</div>}
      {ilaclar.map((i, n) => (
        <div key={n} className="myp-s">{m(i.ilacAd)}
          <span className="not">{[m(i.doz), m(i.periyot)].filter(Boolean).join(' ')}
            {duzen && <button type="button" className="myp-x" disabled={mesgul} title={c('Bıraktı (listeden çıkar)')}
                              onClick={() => void birak(Number(i.id))}>×</button>}</span></div>
      ))}
      {duzen && (
        <input className="myp-ilac-gir" value={metin} disabled={mesgul} autoFocus
               placeholder={c('Kısa adla ekle, Enter (ör. Coraspin 100 1x1)')}
               onChange={e => setMetin(e.target.value)}
               onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); void ekle() } else if (e.key === 'Escape') setDuzen(false) }} />
      )}
    </div>
  );
}

export function MuayeneYanPanel({ muayeneId, bilgi, gecmis, onKopyalandi, onIlacDegisti, tazele = 0 }: {
  muayeneId: number;
  bilgi: MuayeneHastaBilgisi | null;
  gecmis: Satir[];
  onKopyalandi(): void;
  /** Kullandığı ilaç eklendi / bırakıldı - hasta bilgisi yeniden okunsun. */
  onIlacDegisti?(): void;
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
      <IlacKutusu bilgi={bilgi} onDegisti={onIlacDegisti} />
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
