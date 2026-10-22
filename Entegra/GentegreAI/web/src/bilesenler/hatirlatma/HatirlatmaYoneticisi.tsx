import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import type { Hatirlatma } from '../../api/uclar/hatirlatma';
import { guvenli } from '../mesaj';
import { HatirlatmaKarti } from './HatirlatmaKarti';
import { HATIRLATMA_AC_OLAYI, hatirlatmaDegisti, hatirlatmaPenceresiAc, kayitIkonu, kisaZaman, kalanMetni,
         useHatirlatmaZil, zilYukle, type HatirlatmaAcIstegi } from './hatirlatmaDeposu';
import { HATIRLATMA_STIL } from './hatirlatmaStil';

/**
 * KABUKTA BİR KEZ (mockup kisisel_hatirlatici.html (1)(5)):
 *  · zil verisini dakikada bir tazeler (hatirlatmaDeposu),
 *  · `hatirlatmaPenceresiAc` olayıyla hatırlatma kartını açar,
 *  · Alt+H = yeni hatırlatma,
 *  · uyarı anı gelen hatırlatmaları sağ altta AÇILIR UYARI olarak gösterir (Tamam · Ertele · Kaydı aç).
 *    Kapatılan uyarı bu tarayıcıda o zaman için bir daha çıkmaz (id@zaman anahtarı - erteleme yeni
 *    zaman demek, yeniden çıkar). Kalıcı durum sunucuda; bu yalnız görüntü kolaylığı.
 */
const KAPALI_ANAHTAR = 'hatirlatma.kapatilanUyarilar';
const kapaliOku = (): string[] => { try { return JSON.parse(localStorage.getItem(KAPALI_ANAHTAR) ?? '[]') } catch { return [] } };
const kapaliYaz = (l: string[]) => { try { localStorage.setItem(KAPALI_ANAHTAR, JSON.stringify(l.slice(-200))) } catch { /* özel pencere */ } };
const anahtar = (h: Hatirlatma) => `${h.id}@${h.zaman}`;

export function HatirlatmaYoneticisi() {
  const git = useNavigate();
  const zil = useHatirlatmaZil();
  const [pencere, setPencere] = useState<HatirlatmaAcIstegi | null>(null);
  const [kapali, setKapali] = useState<string[]>(kapaliOku);
  const [simdi, setSimdi] = useState(Date.now());

  useEffect(() => {
    void zilYukle();
    const t = setInterval(() => { void zilYukle(); setSimdi(Date.now()) }, 60_000);
    // Uyarı anını dakika sınırında kaçırmamak için saati de 20 sn'de bir ilerlet.
    const s = setInterval(() => setSimdi(Date.now()), 20_000);
    return () => { clearInterval(t); clearInterval(s) };
  }, []);

  useEffect(() => {
    const ac = (e: Event) => setPencere((e as CustomEvent<HatirlatmaAcIstegi>).detail ?? {});
    const tus = (e: KeyboardEvent) => {
      if (e.altKey && !e.ctrlKey && (e.key === 'h' || e.key === 'H')) { e.preventDefault(); hatirlatmaPenceresiAc() }
    };
    window.addEventListener(HATIRLATMA_AC_OLAYI, ac);
    window.addEventListener('keydown', tus);
    return () => { window.removeEventListener(HATIRLATMA_AC_OLAYI, ac); window.removeEventListener('keydown', tus) };
  }, []);

  const kapat = (h: Hatirlatma) => { const y = [...kapali, anahtar(h)]; setKapali(y); kapaliYaz(y) };
  const eylem = (f: () => Promise<unknown>) => void guvenli(async () => { await f(); hatirlatmaDegisti() });

  const uyarilar = zil.filter(h => h.kanalUygulama && new Date(h.uyariZamani).getTime() <= simdi && !kapali.includes(anahtar(h)))
    .slice(0, 3);

  return <>
    <style>{HATIRLATMA_STIL}</style>
    {pencere && <HatirlatmaKarti key={JSON.stringify(pencere)} istek={pencere} onKapat={() => setPencere(null)} />}
    {uyarilar.length > 0 && (
      <div className="hk-tostlar" role="status">
        {uyarilar.map(h => {
          const k = kalanMetni(h.zaman, simdi);
          const gecti = new Date(h.zaman).getTime() < simdi;
          return (
            <div key={anahtar(h)} className={`hk-tost${gecti ? ' kir' : ''}`}>
              <div className="hk-tu">⏰ {gecti ? 'Gecikmiş' : 'Hatırlatma'} · {kisaZaman(new Date(h.zaman))}
                {!gecti && <span className="hk-rz sari">{k.metin}</span>}
                <button type="button" className="x" title="Kapat" onClick={() => kapat(h)}>✕</button></div>
              <b className="bs" onClick={() => setPencere({ id: h.id })}>{h.baslik}</b>
              {h.notu && <div className="hk-soluk">{h.notu.length > 90 ? h.notu.slice(0, 90) + '…' : h.notu}</div>}
              {h.kaynakAd && <div className="hk-bag">{kayitIkonu(h.kaynak)} {h.kaynakAd}</div>}
              <div className="eyl">
                <button type="button" className="d yesil mini" onClick={() => eylem(() => api.hatirlatmaTamamla(h.id))}>✓ Tamam</button>
                <button type="button" className="d mini" onClick={() => eylem(() => api.hatirlatmaErtele(h.id, { dakika: 10 }))}>⏱ 10 dk</button>
                <button type="button" className="d mini" onClick={() => eylem(() => api.hatirlatmaErtele(h.id, { dakika: 60 }))}>⏱ 1 saat</button>
                <button type="button" className="d mini" onClick={() => {
                  const y = new Date(); y.setDate(y.getDate() + 1); y.setHours(9, 0, 0, 0);
                  const p = (n: number) => String(n).padStart(2, '0');
                  eylem(() => api.hatirlatmaErtele(h.id, { zaman: `${y.getFullYear()}-${p(y.getMonth() + 1)}-${p(y.getDate())}T09:00` }));
                }}>⏱ Yarın</button>
                {h.kaynak && h.kaynakId && <button type="button" className="d mini"
                  onClick={() => { kapat(h); git(`/${h.kaynak}/${h.kaynakId}`) }}>↗ Kaydı aç</button>}
              </div>
            </div>
          );
        })}
      </div>
    )}
  </>;
}
