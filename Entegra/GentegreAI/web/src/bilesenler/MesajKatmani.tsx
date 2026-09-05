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

  /**
   * KUTU VARSAYILANLA DOLU BASLAR (kullanici: POS/dönüşüm tutarı soruldugunda
   * "50.000,00" yaziyordu ama Enter'a basinca "Tutar sıfırdan büyük olmalı"
   * diyordu). Kutuda GORUNEN deger `girdi || girdiVarsayilan` idi: kullanici
   * uzerine yazmadikca state BOS kaliyor ve cagirana bos metin donuyordu.
   * Varsayilan artik state'e yazilir - gorunen ile donen ayni degerdir.
   */
  useEffect(() => {
    setGirdi(istek?.girdiMi ? (istek.girdiVarsayilan ?? '') : '');
  }, [istek]);

  if (!istek) return null;

  const kapat = (sonuc: boolean) => {
    // Metin istegi ise degeri (iptalde null) ayri geri cagirimla veririz.
    if (istek.girdiMi) istek.cozumMetin?.(sonuc ? girdi : null);
    else if (istek.secenekler) istek.cozumSecim?.(istek.varsayilanKod ?? '');
    else istek.cozum(sonuc);
    setIstek(null);
    setGirdi('');
  };

  /** Cok secenekli soruda dugmeye basildi (Kaydet / İptal / Geri Dön). */
  const secildi = (kod: string) => {
    istek.cozumSecim?.(kod);
    setIstek(null);
    setGirdi('');
  };

  return (
    <Modal
      baslik={`${urunAdi(kullanici?.urunModu)} Mesajı`}
      dar
      enUst
      onKapat={() => kapat(false)}
      alt={
        istek.secenekler ? (
          // COK SECENEKLI soru (or. "Kaydet / İptal / Geri Dön"): dugmeler
          //   verildigi SIRADA cizilir, ilki one cikan secimdir.
          <>
            {istek.secenekler.map((x, i) => (
              <button key={x.kod} type="button"
                      className={`d ${x.sinif ?? ''}`.trim()}
                      autoFocus={i === 0}
                      onClick={() => secildi(x.kod)}>
                {x.ad}
              </button>
            ))}
          </>
        ) : (
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
        )
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
                       value={girdi}
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
