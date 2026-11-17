import { useEffect, useRef, useState } from 'react';
import { c } from '../../dil/ceviri';

/** KVKK Onay menüsünün eylemleri (BelgeKarti verir). */
export interface KvkkOnayEylemleri {
  smsGonder(): void;
  kodGir(): void;
  islakImza(): void;
  hastaReddetti(): void;
}

/**
 * "📱 KVKK Onay ▾" (kullanıcı 17.11.2026: "kvkk sms buton caption rename 'KVKK Onay' altına 4 tane menü ekle"):
 * SMS Gönder · Onay Kodu Gir · Islak İmzalı Onay Alındı · Hasta Reddetti. Dışarı tık / Esc kapatır (AktarMenusu deseni).
 */
export function KvkkOnayMenusu({ eylemler, pasif, hastaVar, baslik, smsGitti }: {
  eylemler: KvkkOnayEylemleri; pasif: boolean; hastaVar: boolean;
  /** Menünün üstündeki durum satırı (1353): "Geçerli onay var (…'e kadar)" / "Onay gerekli" / "SMS gönderildi · kod bekleniyor". */
  baslik?: string;
  /** SMS gönderildi mi: Onay Kodu Gir yalnız o zaman açık, SMS Gönder "Yeniden Gönder" olur. */
  smsGitti?: boolean;
}) {
  const [acik, setAcik] = useState(false);
  const kok = useRef<HTMLSpanElement>(null);
  useEffect(() => {
    if (!acik) return;
    const kapat = (e: MouseEvent) => { if (!kok.current?.contains(e.target as Node)) setAcik(false) };
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    window.addEventListener('mousedown', kapat);
    window.addEventListener('keydown', esc);
    return () => { window.removeEventListener('mousedown', kapat); window.removeEventListener('keydown', esc) };
  }, [acik]);
  const sec = (f: () => void) => { setAcik(false); f() };
  return (
    <span className="dugme-menu" ref={kok}>
      <button type="button" className="d" disabled={pasif || !hastaVar} data-testid="kvkk-onay-menu"
              title={c('KVKK / ETK onayı: SMS kodu, ıslak imza ya da hastanın reddi')}
              aria-haspopup="menu" aria-expanded={acik} onClick={() => setAcik(a => !a)}>
        📱 {c('KVKK Onay')} ▾
      </button>
      {acik && (
        <div className="dugme-menu-liste" role="menu">
          {baslik && <div className="dugme-menu-baslik" data-testid="kvkk-menu-baslik">{baslik}</div>}
          <button type="button" className="mi" role="menuitem" onClick={() => sec(eylemler.smsGonder)}>📤 {smsGitti ? c("SMS'i Yeniden Gönder") : c('SMS Gönder')}</button>
          <button type="button" className="mi" role="menuitem" disabled={!smsGitti}
                  title={smsGitti ? undefined : c('Önce SMS gönderin')} onClick={() => sec(eylemler.kodGir)}>🔢 {c('Onay Kodu Gir')}</button>
          <button type="button" className="mi" role="menuitem" onClick={() => sec(eylemler.islakImza)}>✍️ {c('Islak İmzalı Onay Alındı')}</button>
          <button type="button" className="mi" role="menuitem" onClick={() => sec(eylemler.hastaReddetti)}>🚫 {c('Hasta Reddetti')}</button>
        </div>
      )}
    </span>
  );
}
