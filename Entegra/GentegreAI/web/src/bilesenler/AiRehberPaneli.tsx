import { useCallback, useEffect, useRef, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { useAiBaglam } from './aiBaglam';
import { Kalinla } from './kalinMetin';

/**
 * AI REHBER PANELİ (447) — sağ altta duran yol gösterici.
 *
 * <b>Rehberdir, operatör değildir.</b> Panel hiçbir kayıt açmaz, değiştirmez,
 * silmez; kullanıcıya hangi ekrandan başlayacağını ve adım sırasını söyler.
 * Cevabı sunucu üretir (`POST /api/ai/rehber`) - istemcide iş kuralı yok.
 *
 * <b>Öneriler sunucuda süzülür:</b> yetkisi olmayan ekranın düğmesi hiç
 * gelmez. Panel geldiği listeyi çizer, kendi filtresini kurmaz.
 *
 * <b>Bağlam gönderilir</b> (aktif sayfa): "bu ekranda ne yapabilirim"
 * sorusunun cevabı hangi ekranda durduğunuza bağlıdır.
 */

interface Adim { no: number; metin: string; ekran?: string; rota?: string }
interface Oneri {
  kod: string; seviye: number; baslik: string; aciklama: string;
  alan: string; ekran: string; rota?: string;
}
interface Ekran { kaynak: string; ad: string; rota: string; yol: string; menuGrup: string }
interface Aksiyon { kod: string; ad: string; ekran: string }
interface Yanit {
  cevap: string; adimlar: Adim[]; onerilenEkranlar: Ekran[];
  onerilenAksiyonlar: Aksiyon[]; guvenSkoru: number; eksikBilgiSorusu?: string;
  uyarilar: string[]; konuKod: string; kaynakTuru: number; kontorBakiye: number;
  /** Cevabı dil modeli mi yazdı (450)? Katalog cevabı ücretsizdir. */
  modelKullanildi?: boolean; model?: string;
}

/**
 * Sık sorulanlar: boş panel "ne yazsam" diye baktırır. İlk sıra BAĞLAMSAL -
 * kullanıcı çoğu zaman durduğu ekranı sorar (Faz 2).
 */
const ORNEKLER = [
  'Bu ekranda ne yapabilirim?',
  'Yeni hasta kaydı nasıl açılır?',
  'Bir cariye fatura nasıl keserim?',
  'Hastanın laboratuvar sonucuna nereden bakarım?',
];

/**
 * Kart rotasindan kayit: "/cari/4868" -> ("cari", 4868). Liste rotasinda
 * (ornegin "/cari") kayit YOKTUR - oneri de istenmez.
 */
function rotadanKayit(rota: string): { kaynak: string; id: number } | null {
  const p = rota.split('/').filter(Boolean);
  if (p.length < 2) return null;
  const id = Number(p[1]);
  return Number.isInteger(id) && id > 0 ? { kaynak: p[0], id } : null;
}

export function AiRehberPaneli({ urunModu }: { urunModu?: number }) {
  const git = useNavigate();
  const konum = useLocation();
  const [oneriler, setOneriler] = useState<Oneri[]>([]);
  // Acik kart (modal) baglami; yoksa rotadan cozulur.
  const acikKayit = useAiBaglam();
  const [acik, setAcik] = useState(false);
  const [soru, setSoru] = useState('');
  const [yanit, setYanit] = useState<Yanit | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState('');
  const kutu = useRef<HTMLInputElement>(null);

  useEffect(() => { if (acik) kutu.current?.focus() }, [acik]);

  // BU KAYITTA: panel acikken ve KART rotasindaysak kaydin eksikleri
  //   sorulmadan gosterilir - kullanici "gondere basinca" ogrenmesin.
  useEffect(() => {
    if (!acik) return;
    const kayit = acikKayit ?? rotadanKayit(konum.pathname);
    if (!kayit) { setOneriler([]); return }
    let iptal = false;
    void (async () => {
      try {
        const y = await api.aiOneri(kayit.kaynak, kayit.id);
        if (!iptal) setOneriler(y.oneriler as Oneri[]);
      } catch { if (!iptal) setOneriler([]) }   // oneri zorunlu degil
    })();
    return () => { iptal = true };
  }, [acik, konum.pathname, acikKayit]);

  const oneriGizle = async (kod: string) => {
    setOneriler(o => o.filter(x => x.kod !== kod));
    try { await api.aiOneriGizle(kod, true) } catch { /* tercih kaydedilemedi */ }
  };

  const sor = useCallback(async (metin: string) => {
    const s = metin.trim();
    if (s === '') return;
    setYukleniyor(true); setHata(''); setYanit(null);
    try {
      setYanit(await api.aiRehber({
        kullaniciMesaji: s,
        aktifMod: urunModu,
        // Bağlam: hangi ekranda sorulduğu. Sunucu bunu ipucu olarak kullanır.
        aktifSayfa: konum.pathname,
      }) as unknown as Yanit);
    } catch (h) { setHata(hataMetni(h)) }
    finally { setYukleniyor(false) }
  }, [urunModu, konum.pathname]);

  if (!acik) {
    return (
      <button className="rehber-dugme" onClick={() => setAcik(true)}
              title="AI Rehber — ne nerede, nasıl yapılır?">
        💡 <span>AI Rehber</span>
      </button>
    );
  }

  const guven = yanit ? Math.round(yanit.guvenSkoru * 100) : 0;

  return (
    <div className="rehber-panel" role="dialog" aria-label="AI Rehber">
      <div className="rehber-bas">
        <b>💡 AI Rehber</b>
        <span className="rehber-not">yol gösterir, kayıt değiştirmez</span>
        <button className="d" onClick={() => setAcik(false)} title="Kapat">✖</button>
      </div>

      <div className="rehber-govde">
        {/* Kaydin eksikleri: seviye sirasiyla (engel -> uyari -> bilgi).
            Asistan bunlari DUZELTMEZ; isaret eder. */}
        {oneriler.length > 0 && (
          <div className="rehber-oneriler">
            <div className="rehber-not">Bu kayıtta</div>
            {oneriler.map(o => (
              <div key={o.kod} className={`rehber-oneri s${o.seviye}`}>
                <div className="bas">
                  <b>{o.seviye === 3 ? '⛔' : o.seviye === 2 ? '⚠' : 'ℹ'} {o.baslik}</b>
                  <button className="d" title="Bunu bir daha gösterme"
                          onClick={() => void oneriGizle(o.kod)}>✖</button>
                </div>
                <div className="ac">{o.aciklama}</div>
                {/* Zaten o ekrandaysak dugme gurultu: kullanici bulundugu
                    yere "git" demez. */}
                {o.rota && o.rota !== konum.pathname && (
                  <button className="d rehber-git"
                          onClick={() => { git(o.rota!); setAcik(false) }}>
                    Ekranı aç
                  </button>
                )}
              </div>
            ))}
          </div>
        )}

        {!yanit && !yukleniyor && !hata && (
          <div className="rehber-ornek">
            <div className="rehber-not">Ne yapmak istediğinizi yazın:</div>
            {ORNEKLER.map(o => (
              <button key={o} className="rehber-ornek-dugme"
                      onClick={() => { setSoru(o); void sor(o) }}>{o}</button>
            ))}
          </div>
        )}

        {yukleniyor && <div className="rehber-not">Bakıyorum…</div>}
        {hata && <div className="hata-kutusu">{hata}</div>}

        {yanit && (
          <>
            <p className="rehber-cevap"><Kalinla metin={yanit.cevap} /></p>

            {yanit.adimlar.length > 0 && (
              <ol className="rehber-adimlar">
                {yanit.adimlar.map(a => (
                  <li key={a.no}>
                    <Kalinla metin={a.metin} />
                    {/* Düğme YALNIZ yetkili ekran için gelir (sunucu süzer). */}
                    {a.rota && (
                      <button className="d rehber-git"
                              onClick={() => { git(a.rota!); setAcik(false) }}>
                        Ekranı aç
                      </button>
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
                <div className="rehber-not">İlgili ekranlar</div>
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
                O ekrandaki düğmeler:{' '}
                {yanit.onerilenAksiyonlar.map(a => a.ad).join(' · ')}
              </div>
            )}

            {yanit.eksikBilgiSorusu && (
              <div className="rehber-eksik">❓ {yanit.eksikBilgiSorusu}</div>
            )}

            {/* GÜVEN açıkça yazılır: emin olmadığı yerde kullanıcı da temkinli
                olsun - kesin konuşan yanlış cevap, belirsiz cevaptan kötüdür. */}
            <div className="rehber-alt">
              <span className={`rozet ${guven >= 70 ? 'olumlu' : guven >= 40 ? 'uyari' : 'gri'}`}>
                güven %{guven}
              </span>
              {yanit.kaynakTuru === 1 && <span className="rehber-not">rehber kataloğu</span>}
              {yanit.kaynakTuru === 2 && <span className="rehber-not">ekran eşleşmesi</span>}
              {yanit.kaynakTuru === 3 && <span className="rehber-not">bu ekranın yardımı</span>}
              {yanit.kaynakTuru === 0 && <span className="rehber-not">eşleşme yok</span>}
              {/* Cevabın kaynağı gizlenmez: katalog cevabı kurumun yazdığı
                  adımdır, model cevabı yorumdur - kullanıcı ayırt edebilmeli. */}
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
               placeholder="Nasıl yapılır diye sorun…" maxLength={300} />
        <button className="d bir" type="submit" disabled={yukleniyor}>Sor</button>
      </form>
    </div>
  );
}
