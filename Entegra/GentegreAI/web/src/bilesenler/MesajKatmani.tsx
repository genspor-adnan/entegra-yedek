import { useEffect, useState } from 'react';
import { Modal } from './Modal';
import { mesajDinleyiciAta, type MesajIstegi } from './mesaj';
import { urunAdi } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';

/**
 * "Gentegre AI Mesajı" penceresi - uygulamanin TEK mesaj/onay ekrani.
 *
 * App'in koküne bir kez konur; `mesaj()` ve `onay()` cagrilari buraya duser.
 * Tarayicinin alert/confirm kutulari sayfayi kilitliyor ve "localhost diyor ki"
 * basligiyla cikiyordu.
 *
 * Kuyruk YOK: ust uste gelen mesajda son istek gosterilir - kullanici arka
 * arkaya diyalog kapatmak zorunda kalmasin.
 */
export function MesajKatmani() {
  const { kullanici } = useOturum();
  const [istek, setIstek] = useState<MesajIstegi | null>(null);
  const [girdi, setGirdi] = useState('');

  useEffect(() => {
    mesajDinleyiciAta(setIstek);
    return () => mesajDinleyiciAta(null);
  }, []);

  if (!istek) return null;

  const kapat = (sonuc: boolean) => {
    // Metin istegi ise degeri (iptalde null) ayri geri cagirimla veririz.
    if (istek.girdiMi) istek.cozumMetin?.(sonuc ? girdi : null);
    else istek.cozum(sonuc);
    setIstek(null);
    setGirdi('');
  };

  return (
    <Modal
      baslik={`${urunAdi(kullanici?.urunModu)} Mesajı`}
      dar
      onKapat={() => kapat(false)}
      alt={
        <>
          {istek.onayMi && (
            <button type="button" className="d kapat-dugmesi"
                    onClick={() => kapat(false)}>Vazgeç</button>
          )}
          <button type="button"
                  className={`d ${istek.tehlike ? 'teh' : 'bir'}`}
                  autoFocus
                  onClick={() => kapat(true)}>
            {istek.onayMi ? 'Tamam' : 'Kapat'}
          </button>
        </>
      }
    >
      {/* Satir sonlari korunur: sunucudan gelen cok satirli aciklamalar
          (or. "Gönderilemedi (HTTP 400): ...") okunakli kalsin. */}
      <div className="kagrup">
        <div style={{ padding: '10px 12px', whiteSpace: 'pre-wrap', lineHeight: 1.5 }}>
          {istek.metin}
        </div>
        {istek.girdiMi && (
          <div className="alan-izgara tek-sutun ayar-formu" style={{ padding: '0 12px 12px' }}>
            <label className="alan">
              {istek.girdiEtiket && <span className="etiket">{istek.girdiEtiket}</span>}
              <span className="ikili">
                <input className="genis-deger" autoFocus
                       value={girdi || istek.girdiVarsayilan || ''}
                       onChange={e => setGirdi(e.target.value)}
                       onKeyDown={e => { if (e.key === 'Enter') kapat(true) }} />
              </span>
            </label>
          </div>
        )}
      </div>
    </Modal>
  );
}
