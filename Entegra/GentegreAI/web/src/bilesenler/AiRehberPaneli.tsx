import { useCallback, useEffect, useRef, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

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
interface Ekran { kaynak: string; ad: string; rota: string; yol: string; menuGrup: string }
interface Aksiyon { kod: string; ad: string; ekran: string }
interface Yanit {
  cevap: string; adimlar: Adim[]; onerilenEkranlar: Ekran[];
  onerilenAksiyonlar: Aksiyon[]; guvenSkoru: number; eksikBilgiSorusu?: string;
  uyarilar: string[]; konuKod: string; kaynakTuru: number; kontorBakiye: number;
}

/** Sık sorulanlar: boş panel "ne yazsam" diye baktırır. */
const ORNEKLER = [
  'Yeni hasta kaydı nasıl açılır?',
  'Bir cariye fatura nasıl keserim?',
  'Randevu oluşturmak istiyorum',
  'Hastanın laboratuvar sonucuna nereden bakarım?',
];

/** **kalın** yazımını güvenle çizer (HTML enjekte edilmez). */
function Kalinla({ metin }: { metin: string }) {
  const parcalar = metin.split(/\*\*(.+?)\*\*/g);
  return <>{parcalar.map((p, i) => (i % 2 === 1 ? <b key={i}>{p}</b> : p))}</>;
}

export function AiRehberPaneli({ urunModu }: { urunModu?: number }) {
  const git = useNavigate();
  const konum = useLocation();
  const [acik, setAcik] = useState(false);
  const [soru, setSoru] = useState('');
  const [yanit, setYanit] = useState<Yanit | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState('');
  const kutu = useRef<HTMLInputElement>(null);

  useEffect(() => { if (acik) kutu.current?.focus() }, [acik]);

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
              {yanit.kaynakTuru === 0 && <span className="rehber-not">eşleşme yok</span>}
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
