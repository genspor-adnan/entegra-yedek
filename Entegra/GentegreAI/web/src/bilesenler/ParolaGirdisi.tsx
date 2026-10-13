import { useState, type InputHTMLAttributes } from 'react';
import { c } from '../dil/ceviri';

/**
 * PAROLA ALANI + GÖSTER/GİZLE (göz) düğmesi.
 *
 * Kullanıcı (13.10.2026): "logine şifreyi görme göz ikonu ekle". Giriş, ilk
 * girişte zorunlu parola değişikliği, "Şifremi Unuttum" ve GenProfil
 * bağlantısı aynı bileşeni kullanır - dört ekranda dört ayrı göz olmasın.
 *
 * Varsayılan GİZLİ. Düğme `type="button"`: Enter formu göndermeye devam eder,
 * gözü açıp kapatmaz. Tab sırasında durur (klavyeyle de açılabilsin).
 */
export function ParolaGirdisi(props: Omit<InputHTMLAttributes<HTMLInputElement>, 'type'>) {
  const [acik, setAcik] = useState(false);
  const etiket = acik ? c('Parolayı gizle') : c('Parolayı göster');
  return (
    <span className="parola-girdi">
      <input {...props} type={acik ? 'text' : 'password'} />
      <button type="button" className="parola-goz" onClick={() => setAcik(a => !a)}
              aria-label={etiket} title={etiket} aria-pressed={acik}>
        <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor"
             strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
          <path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12z" />
          <circle cx="12" cy="12" r="3" />
          {acik && <path d="M3 3l18 18" />}
        </svg>
      </button>
    </span>
  );
}
