import { useCallback, useEffect, useRef, useState, useSyncExternalStore } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import type { AiEkranIpucu, AiEkranKonusu, AiEkranOzeti, AiRehberYaniti } from '../api/uclar/yapayZeka';
import { ApiHatasi, hataMetni } from '../api/sozlesme';
import { hataIziDinle, hataIziTemizle, sonHataIzi } from '../api/hataIzi';
import { useAiBaglam } from './aiBaglam';
import { Kalinla } from './kalinMetin';
import { aktifDil, c } from '../dil/ceviri';

/** Sürüklenen düğmenin konumu (bu tarayıcı) - 20.11.2026. */
const KONUM_ANAHTARI = 'gentegre.aiRehber.konum';
const VARSAYILAN_KONUM = { sag: 18, alt: 18 };

/**
 * YAPAY ZEKÂYA SOR — BAĞLAMSAL YARDIM PANELİ (447 · 871), sağ altta, her ekranda.
 *
 * <b>Rehberdir, operatör değildir.</b> Panel hiçbir kayıt açmaz, değiştirmez,
 * silmez; kullanıcıya bulunduğu ekranda işini nasıl yapacağını söyler.
 * Cevabı sunucu üretir (`POST /api/ai/rehber`) - istemcide iş kuralı yok.
 *
 * <b>Ekran bağlamı yalnız KİMLİKTİR:</b> rota, kaynak kodu, açık kaydın
 * numarası, sekme adı, son hata kodu, dil. DOM, satır verisi, hasta bilgisi
 * gönderilmez. Sunucu ipucunu katalog ve yetkiyle doğrular; panel "şu ekran
 * hakkında soruyorsunuz" satırını sunucunun döndürdüğü özetle çizer.
 *
 * <b>Rota değişince bağlam sıfırlanır:</b> cevap, öneriler, hata izi ve açık
 * kayıt bağlamı temizlenir - önceki hastanın bağlamı yeni ekrana taşınmaz.
 *
 * <b>Yönlendirme yalnız sunucu rotasıyla:</b> düğmeler sunucunun verdiği
 * `rota` ile çizilir; model metninde geçen bir adres asla çalıştırılmaz.
 */

interface Adim { no: number; metin: string; ekran?: string; rota?: string; aksiyon?: string }
interface Oneri {
  kod: string; seviye: number; baslik: string; aciklama: string;
  alan: string; ekran: string; rota?: string;
}
type Yanit = AiRehberYaniti;

/** Sunucu ekranı tanımadığında / henüz yüklenmemişken gösterilen genel sorular. */
const GENEL_SORULAR = [
  'Bu ekranda ne yapabilirim?',
  'Yeni hasta kaydı nasıl açılır?',
  'Hastanın laboratuvar sonucuna nereden bakarım?',
  'Rolüm ne yapabilir?',
];

const KAYNAK_ETIKETI: Record<number, string> = {
  0: 'eşleşme yok', 1: 'rehber kataloğu', 2: 'ekran eşleşmesi', 3: 'bu ekranın yardımı',
  5: 'yapay zeka', 6: 'rol tanımı', 7: 'kapsam dışı', 8: 'yardım belgesi', 9: 'akılcı istem kuralı',
};

/**
 * Kart rotasından kayıt: "/cari/4868" -> ("cari", 4868). Liste rotasında
 * (örneğin "/cari") kayıt YOKTUR - öneri de istenmez.
 */
function rotadanKayit(rota: string): { kaynak: string; id: number } | null {
  const p = rota.split('/').filter(Boolean);
  if (p.length < 2) return null;
  const id = Number(p[1]);
  return Number.isInteger(id) && id > 0 ? { kaynak: p[0], id } : null;
}

function dilKodu(): string { return ['tr', 'en', 'de'][aktifDil()] ?? 'tr' }

/** Hata türüne göre kullanıcı diliyle durum metni (§1.2 kodları + ağ). */
function hataDurumu(h: unknown): { metin: string; tur: 'yetki' | 'yok' | 'kota' | 'ag' | 'diger' } {
  if (h instanceof ApiHatasi) {
    if (h.durum === 401) return { metin: 'Oturumunuz kapanmış görünüyor; yeniden giriş yapın.', tur: 'yetki' };
    if (h.durum === 403) return { metin: 'Bu işlem için yetkiniz yok (asistan yetkiniz olmayan işi anlatmaz).', tur: 'yetki' };
    if (h.durum === 404) return { metin: 'Kayıt ya da ekran bulunamadı (ya da kapsamınız dışında).', tur: 'yok' };
    if (h.durum === 429) return { metin: 'Çok sık soruldu; biraz sonra yeniden deneyin.', tur: 'kota' };
    if (h.durum >= 500) return { metin: 'Asistan şu an cevap veremiyor (sunucu). Biraz sonra yeniden deneyin.', tur: 'ag' };
    return { metin: hataMetni(h), tur: 'diger' };
  }
  return { metin: 'Sunucuya ulaşılamadı; bağlantınızı kontrol edip yeniden deneyin.', tur: 'ag' };
}

/** Üst şeritteki "?" düğmesinin gönderdiği olay (Kabuk). */
export const YARDIM_AC_OLAYI = 'gentegre:yardim-ac';

export function AiRehberPaneli({ urunModu }: { urunModu?: number }) {
  const git = useNavigate();
  const konum = useLocation();
  const [oneriler, setOneriler] = useState<Oneri[]>([]);
  // Açık kart (modal) bağlamı; yoksa rotadan çözülür.
  const acikKayit = useAiBaglam();
  const hataIzi = useSyncExternalStore(hataIziDinle, sonHataIzi, () => null);
  const [acik, setAcik] = useState(false);
  const [soru, setSoru] = useState('');
  const [yanit, setYanit] = useState<Yanit | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<{ metin: string; tur: string } | null>(null);
  // Sunucunun doğruladığı ekran + önerilen sorular ("şu ekran hakkında soruyorsunuz").
  const [ekran, setEkran] = useState<AiEkranOzeti | null>(null);
  const [onerilenSorular, setOnerilenSorular] = useState<string[]>(GENEL_SORULAR);
  // EKRAN KILAVUZU (kullanıcı 14.11.2026: "başlıklara koy.. tıklandığında bu bilgiler ekranda görünsün"):
  //   sunucunun ekrana bağladığı belge konuları; başlık tıklanınca metni açılır, model çağrısı yok.
  const [konular, setKonular] = useState<AiEkranKonusu[]>([]);
  const [acikKonu, setAcikKonu] = useState<string | null>(null);
  const kutu = useRef<HTMLInputElement>(null);
  const panel = useRef<HTMLDivElement>(null);

  useEffect(() => { if (acik) kutu.current?.focus() }, [acik]);

  // ROTA DEĞİŞİNCE BAĞLAM SIFIRLANIR: cevap, öneriler, hata izi. Önceki
  //   ekranın (hastanın) bağlamı yeni ekrana taşınmaz.
  useEffect(() => {
    setYanit(null); setOneriler([]); setHata(null); setSoru('');
    hataIziTemizle();
  }, [konum.pathname]);

  const kayit = acikKayit ?? rotadanKayit(konum.pathname);
  const ipucu: AiEkranIpucu = {
    rota: konum.pathname,
    kaynak: kayit?.kaynak,
    kayitId: kayit?.id,
    sekme: acikKayit?.sekme,
    hataKodu: hataIzi?.kod,
    dil: dilKodu(),
  };
  const ipucuAnahtari = JSON.stringify(ipucu);

  // EKRAN BAĞLAMI sunucudan: panel açıkken rota / kayıt / sekme / hata
  //   değişince tazelenir. Kontör harcamaz, günlüğe yazmaz.
  useEffect(() => {
    if (!acik) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.aiEkranBaglami(JSON.parse(ipucuAnahtari) as AiEkranIpucu);
        if (iptal) return;
        setEkran(y.ekran);
        setOnerilenSorular(y.onerilenSorular.length > 0 ? y.onerilenSorular : GENEL_SORULAR);
        setKonular(y.konular ?? []); setAcikKonu(null);
      } catch {
        if (!iptal) { setEkran(null); setOnerilenSorular(GENEL_SORULAR); setKonular([]) }
      }
    })();
    return () => { iptal = true };
  }, [acik, ipucuAnahtari]);

  // BU KAYITTA: panel açıkken ve KART rotasındaysak kaydın eksikleri
  //   sorulmadan gösterilir.
  useEffect(() => {
    if (!acik) return;
    if (!kayit) { setOneriler([]); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.aiOneri(kayit.kaynak, kayit.id);
        if (!iptal) setOneriler(y.oneriler as Oneri[]);
      } catch { if (!iptal) setOneriler([]) }   // öneri zorunlu değil
    })();
    return () => { iptal = true };
  }, [acik, kayit?.kaynak, kayit?.id]);   // eslint-disable-line react-hooks/exhaustive-deps

  const oneriGizle = async (kod: string) => {
    setOneriler(o => o.filter(x => x.kod !== kod));
    try { await api.aiOneriGizle(kod, true) } catch { /* tercih kaydedilemedi */ }
  };

  const sor = useCallback(async (metin: string) => {
    const s = metin.trim();
    if (s === '') return;
    setYukleniyor(true); setHata(null); setYanit(null);
    try {
      setYanit(await api.aiRehber({
        kullaniciMesaji: s,
        aktifMod: urunModu,
        aktifSayfa: konum.pathname,
        // Bağlam YALNIZ kimlik: sunucu doğrular, uymayanı atar.
        baglam: JSON.parse(ipucuAnahtari) as AiEkranIpucu,
      }));
    } catch (h) { setHata(hataDurumu(h)) }
    finally { setYukleniyor(false) }
  }, [urunModu, konum.pathname, ipucuAnahtari]);

  // ÜST ŞERİTTEKİ "?" (kullanıcı 10.10.2026: "yardımı nasıl kullanacağım" ->
  //   "evet yap"): paneli açar ve bulunduğu ekranın yardımını sorar. Bağlamsal
  //   soru sunucuda ekranın belgesine gider; belgesi olmayan ekranda genel
  //   rehber cevabı gelir.
  useEffect(() => {
    const ac = () => { setAcik(true); void sor('Bu ekranda ne yapabilirim?') };
    window.addEventListener(YARDIM_AC_OLAYI, ac);
    return () => window.removeEventListener(YARDIM_AC_OLAYI, ac);
  }, [sor]);

  /**
   * SÜRÜKLENEBİLİR DÜĞME (kullanıcı 20.11.2026: "yapay zekaya sor altta sabit ve toplam üzerine geliyor.. yerini
   * değişebilir yap"): düğme fareyle taşınır, konum (sağdan / alttan px) bu tarayıcıda hatırlanır; panel de oradan
   * açılır. 4 px'ten az kayma tıklamadır (paneli açar); çift tık varsayılan köşeye döndürür. Ekran dışına taşmaz.
   */
  const [dKonum, setDKonum] = useState<{ sag: number; alt: number }>(() => {
    try {
      const k = JSON.parse(localStorage.getItem(KONUM_ANAHTARI) ?? 'null') as { sag?: number; alt?: number } | null;
      if (k && Number.isFinite(k.sag) && Number.isFinite(k.alt)) return { sag: k.sag!, alt: k.alt! };
    } catch { /* depolama yok - varsayılan */ }
    return VARSAYILAN_KONUM;
  });
  const surukleme = useRef<{ x: number; y: number; sag: number; alt: number; tasindi: boolean } | null>(null);
  /** Sürükleme bırakıldıktan hemen sonra gelen tıklama paneli açmasın. */
  const yeniSuruklendi = useRef(false);
  const sinirla = (sag: number, alt: number) => ({
    sag: Math.round(Math.min(Math.max(4, sag), Math.max(4, window.innerWidth - 60))),
    alt: Math.round(Math.min(Math.max(4, alt), Math.max(4, window.innerHeight - 40))),
  });
  const konumYaz = (k: { sag: number; alt: number }) => {
    setDKonum(k);
    try { localStorage.setItem(KONUM_ANAHTARI, JSON.stringify(k)) } catch { /* yok say */ }
  };
  const basla = (e: React.PointerEvent<HTMLButtonElement>) => {
    if (e.button !== 0) return;
    surukleme.current = { x: e.clientX, y: e.clientY, sag: dKonum.sag, alt: dKonum.alt, tasindi: false };
    e.currentTarget.setPointerCapture(e.pointerId);
  };
  const tasi = (e: React.PointerEvent<HTMLButtonElement>) => {
    const s = surukleme.current;
    if (!s) return;
    const dx = e.clientX - s.x, dy = e.clientY - s.y;
    if (!s.tasindi && Math.abs(dx) + Math.abs(dy) < 4) return;
    s.tasindi = true;
    setDKonum(sinirla(s.sag - dx, s.alt - dy));
  };
  const birak = (e: React.PointerEvent<HTMLButtonElement>) => {
    const s = surukleme.current;
    surukleme.current = null;
    try { e.currentTarget.releasePointerCapture(e.pointerId) } catch { /* yok say */ }
    if (s?.tasindi) {
      yeniSuruklendi.current = true;
      konumYaz(sinirla(s.sag - (e.clientX - s.x), s.alt - (e.clientY - s.y)));
    }
  };
  // Pencere küçülünce ekran dışında kalmasın.
  useEffect(() => {
    const boyut = () => setDKonum(k => sinirla(k.sag, k.alt));
    window.addEventListener('resize', boyut);
    return () => window.removeEventListener('resize', boyut);
  }, []);

  // KLAVYE: Esc kapatır; odak panelde kalır.
  const tusla = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') { e.stopPropagation(); setAcik(false) }
  };

  if (!acik) {
    return (
      <button className="rehber-dugme" style={{ right: dKonum.sag, bottom: dKonum.alt }}
              onPointerDown={basla} onPointerMove={tasi} onPointerUp={birak}
              onClick={() => { if (yeniSuruklendi.current) { yeniSuruklendi.current = false; return } setAcik(true) }}
              onDoubleClick={() => konumYaz(VARSAYILAN_KONUM)}
              aria-label={c('Yapay Zekâya Sor — bu ekranda nasıl yapılır?')}
              title={c('Yapay Zekâya Sor — bu ekranda nasıl yapılır? (Sürükleyerek taşıyabilirsiniz; çift tık: köşeye)')}>
        💡 <span>{c('Yapay Zekâya Sor')}</span>
      </button>
    );
  }

  const guven = yanit ? Math.round(yanit.guvenSkoru * 100) : 0;
  const ekranBasligi = ekran?.bulundu
    ? ekran.yol + (ekran.sekme ? ` › ${ekran.sekme}` : '') + (ekran.kayitVar ? ' (açık kayıt)' : '')
    : null;

  return (
    <div className="rehber-panel" style={{ right: Math.min(dKonum.sag, Math.max(4, window.innerWidth - 392)),
                                           bottom: Math.min(dKonum.alt, Math.max(4, window.innerHeight - 320)) }} role="dialog" aria-label={c('Yapay Zekâya Sor')}
         aria-modal="false" ref={panel} onKeyDown={tusla}>
      <div className="rehber-bas">
        <b>{c('💡 Yapay Zekâya Sor')}</b>
        <span className="rehber-not">{c('yol gösterir, kayıt değiştirmez')}</span>
        <button className="d" onClick={() => setAcik(false)} title={c('Kapat')} aria-label={c('Kapat')}>✖</button>
      </div>

      {/* ŞU EKRAN HAKKINDA: sunucunun doğruladığı ekran; istemci uydurmaz. */}
      <div className="rehber-baglam" aria-live="polite">
        {ekranBasligi
          ? <>{c('Şu ekran hakkında soruyorsunuz:')} <b>{ekranBasligi}</b>
              {ekran && !ekran.yetkili && <span className="rehber-baglam-uyari"> · {c('bu ekrana yetkiniz yok')}</span>}
              {ekran?.hataKodu && <span className="rehber-baglam-hata"> · {c('son hata')}: {ekran.hataKodu}</span>}
            </>
          : <span className="rehber-not">{c('Bu ekran için yardım bağlamı tanınmadı; genel sorular sorabilirsiniz.')}</span>}
      </div>

      <div className="rehber-govde">
        {oneriler.length > 0 && (
          <div className="rehber-oneriler">
            <div className="rehber-not">{c('Bu kayıtta')}</div>
            {oneriler.map(o => (
              <div key={o.kod} className={`rehber-oneri s${o.seviye}`}>
                <div className="bas">
                  <b>{o.seviye === 3 ? '⛔' : o.seviye === 2 ? '⚠' : 'ℹ'} {o.baslik}</b>
                  <button className="d" title={c('Bunu bir daha gösterme')}
                          onClick={() => void oneriGizle(o.kod)}>✖</button>
                </div>
                <div className="ac">{o.aciklama}</div>
                {o.rota && o.rota !== konum.pathname && (
                  <button className="d rehber-git"
                          onClick={() => { git(o.rota!); setAcik(false) }}>
                    {c('Ekranı aç')}
                  </button>
                )}
              </div>
            ))}
          </div>
        )}

        {!yanit && !yukleniyor && !hata && konular.length > 0 && (
          <div className="rehber-konular">
            <div className="rehber-not">{c('Bu ekranda')}</div>
            {konular.map(k => (
              <div key={k.baslik} className={`rehber-konu${acikKonu === k.baslik ? ' acik' : ''}`}>
                <button type="button" className="rehber-konu-bas" aria-expanded={acikKonu === k.baslik}
                        onClick={() => setAcikKonu(a => (a === k.baslik ? null : k.baslik))}>
                  <span className="rehber-konu-ok">{acikKonu === k.baslik ? '▾' : '▸'}</span> {k.baslik}
                </button>
                {acikKonu === k.baslik && <KonuMetni metin={k.metin} />}
              </div>
            ))}
          </div>
        )}

        {!yanit && !yukleniyor && !hata && (
          <div className="rehber-ornek">
            <div className="rehber-not">{c('Ne yapmak istediğinizi yazın ya da bir soru seçin:')}</div>
            {onerilenSorular.map(o => (
              <button key={o} className="rehber-ornek-dugme"
                      onClick={() => { setSoru(o); void sor(o) }}>{o}</button>
            ))}
          </div>
        )}

        {yukleniyor && <div className="rehber-not" role="status">{c('Bakıyorum…')}</div>}
        {hata && (
          <div className={`hata-kutusu rehber-hata-${hata.tur}`} role="alert">
            {hata.metin}
            {hata.tur === 'ag' && (
              <button className="d rehber-git" onClick={() => void sor(soru)}>{c('Yeniden dene')}</button>
            )}
          </div>
        )}

        {yanit && (
          <>
            <p className="rehber-cevap" aria-live="polite"><Kalinla metin={yanit.cevap} /></p>

            {yanit.adimlar.length > 0 && (
              <ol className="rehber-adimlar">
                {yanit.adimlar.map((a: Adim) => (
                  <li key={a.no}>
                    <Kalinla metin={a.metin} />
                    {/* Düğme YALNIZ sunucu rota verdiyse çizilir; metindeki adres çalıştırılmaz. */}
                    {a.rota && a.rota !== konum.pathname && (
                      <button className="d rehber-git"
                              onClick={() => { git(a.rota!); setAcik(false) }}>
                        {c('Ekranı aç')}
                      </button>
                    )}
                    {a.aksiyon && (
                      <span className="rehber-aksiyon-rozet" title={c('Bu ekrandaki düğme')}>
                        {yanit.onerilenAksiyonlar.find(x => x.kod === a.aksiyon)?.ad ?? a.aksiyon}
                      </span>
                    )}
                  </li>
                ))}
              </ol>
            )}

            {yanit.uyarilar.length > 0 && (
              <div className="rehber-uyari">
                {yanit.uyarilar.map((u, i) => <div key={i}>⚠ {u}</div>)}
              </div>
            )}

            {yanit.onerilenEkranlar.length > 0 && (
              <div className="rehber-ekranlar">
                <div className="rehber-not">{c('İlgili ekranlar')}</div>
                {yanit.onerilenEkranlar.map(e => (
                  <button key={e.rota} className="d"
                          onClick={() => { git(e.rota); setAcik(false) }}
                          title={e.yol}>
                    {e.ad}
                  </button>
                ))}
              </div>
            )}

            {yanit.onerilenAksiyonlar.length > 0 && (
              <div className="rehber-not rehber-aksiyon">
                {c('O ekrandaki düğmeler:')}{' '}
                {yanit.onerilenAksiyonlar.map(a => a.ad).join(' · ')}
              </div>
            )}

            {yanit.eksikBilgiSorusu && (
              <div className="rehber-eksik">❓ {yanit.eksikBilgiSorusu}</div>
            )}

            {/* KAYNAK: cevabın dayandığı yardım belgesi - kullanıcı doğrulayabilsin. */}
            {yanit.kaynaklar?.length > 0 && (
              <div className="rehber-not rehber-kaynak">
                {c('Kaynak')}: {yanit.kaynaklar.map(k => k.baslik).join(' · ')}
              </div>
            )}

            <div className="rehber-alt">
              <span className={`rozet ${guven >= 70 ? 'olumlu' : guven >= 40 ? 'uyari' : 'gri'}`}>
                güven %{guven}
              </span>
              <span className="rehber-not">{KAYNAK_ETIKETI[yanit.kaynakTuru] ?? ''}</span>
              {yanit.modelKullanildi && (
                <span className="rehber-not" title={yanit.model}>yapay zeka · kontör</span>
              )}
            </div>
          </>
        )}
      </div>

      <form className="rehber-sorgu"
            onSubmit={e => { e.preventDefault(); void sor(soru) }}>
        <input ref={kutu} value={soru} onChange={e => setSoru(e.target.value)}
               placeholder={c('Nasıl yapılır diye sorun…')} maxLength={300}
               aria-label={c('Soru')} />
        <button className="d bir" type="submit" disabled={yukleniyor}>{c('Sor')}</button>
      </form>
    </div>
  );
}

/**
 * Kılavuz konu metni: "- " satırları madde, diğerleri paragraf; `**kalın**` Kalinla ile (HTML basılmaz, enjeksiyon yok).
 */
function KonuMetni({ metin }: { metin: string }) {
  const bloklar: { tur: 'p' | 'ul'; satirlar: string[] }[] = [];
  for (const ham of metin.split('\n')) {
    const s = ham.trim();
    if (s === '') continue;
    const madde = s.startsWith('- ');
    const son = bloklar[bloklar.length - 1];
    if (madde) {
      if (son?.tur === 'ul') son.satirlar.push(s.slice(2)); else bloklar.push({ tur: 'ul', satirlar: [s.slice(2)] });
    } else bloklar.push({ tur: 'p', satirlar: [s] });
  }
  return (
    <div className="rehber-konu-metin">
      {bloklar.map((b, i) => b.tur === 'ul'
        ? <ul key={i}>{b.satirlar.map((x, j) => <li key={j}><Kalinla metin={x} /></li>)}</ul>
        : <p key={i}><Kalinla metin={b.satirlar[0]} /></p>)}
    </div>
  );
}
