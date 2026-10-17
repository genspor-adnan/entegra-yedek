import { useCallback, useEffect, useRef, useState } from 'react';

/**
 * SESLİ GİRİŞ (kullanıcı 17.10.2026: "komut ekranına mic ikonu koy, basınca Win+H basılmış gibi").
 *
 * Sayfa Windows'un Win+H kısayolunu tetikleyemez (tarayıcı güvenliği); aynı işi tarayıcının ses
 * tanıması (Web Speech, Chrome / Edge) görür. TEK SÖZ dinler: konuşma bitince kendiliğinden durur,
 * ara sonuçlar da yazılır (kullanıcı yazıldığını görsün). Muayene diktesinden (MuayeneDikte) ayrı ve
 * küçük - o çok alanlı, sürekli ve noktalama komutlu.
 */
interface TanimaOlayi {
  resultIndex: number;
  results: ArrayLike<ArrayLike<{ transcript: string }> & { isFinal: boolean }>;
}
interface Taniyici {
  lang: string; continuous: boolean; interimResults: boolean;
  start(): void; stop(): void; abort(): void;
  onresult: ((o: TanimaOlayi) => void) | null;
  onerror: ((o: { error: string }) => void) | null;
  onend: (() => void) | null;
}

const sinif = () => {
  const p = window as unknown as { SpeechRecognition?: new () => Taniyici; webkitSpeechRecognition?: new () => Taniyici };
  return p.SpeechRecognition ?? p.webkitSpeechRecognition;
};

/** Tarayıcı ses tanımayı destekliyor mu (Firefox desteklemez). */
export const sesliGirisVar = () => typeof window !== 'undefined' && !!sinif();

const HATA: Record<string, string> = {
  'not-allowed': 'Mikrofon izni verilmedi - tarayıcının adres çubuğundaki mikrofon simgesinden izin verin.',
  'service-not-allowed': 'Mikrofon izni verilmedi - tarayıcının adres çubuğundaki mikrofon simgesinden izin verin.',
  'audio-capture': 'Mikrofon bulunamadı - tarayıcı ayarlarında doğru mikrofonun seçili olduğuna bakın.',
  network: 'Ses tanıma hizmetine ulaşılamadı - internet bağlantısını kontrol edin.',
  'no-speech': 'Ses duyulmadı - mikrofona yakın konuşup yeniden deneyin.',
  'language-not-supported': 'Tarayıcı Türkçe ses tanımayı desteklemiyor.',
};

/** `onMetin` her ara ve son sonuçta söylenenin tamamıyla çağrılır. */
export function useSesliGiris(onMetin: (metin: string) => void) {
  const [dinliyor, setDinliyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const t = useRef<Taniyici | null>(null);
  const geri = useRef(onMetin);
  geri.current = onMetin;

  const durdur = useCallback(() => { t.current?.stop() }, []);
  const baslat = useCallback(() => {
    const S = sinif();
    if (!S) { setHata('Bu tarayıcı ses tanımayı desteklemiyor (Chrome ya da Edge kullanın).'); return }
    t.current?.abort();
    const r = new S();
    r.lang = 'tr-TR'; r.continuous = false; r.interimResults = true;
    r.onresult = o => {
      let metin = '';
      for (let i = 0; i < o.results.length; i++) metin += o.results[i][0].transcript;
      geri.current(metin.trim());
    };
    r.onerror = o => { if (o.error !== 'aborted') setHata(HATA[o.error] ?? `Ses tanıma hatası: ${o.error}`) };
    r.onend = () => { setDinliyor(false); if (t.current === r) t.current = null };
    t.current = r; setHata(null); setDinliyor(true);
    try { r.start() } catch { setDinliyor(false) }
  }, []);
  // Bileşen kapanırken dinleme sürmesin (mikrofon açık kalmasın).
  useEffect(() => () => { t.current?.abort() }, []);
  return { dinliyor, hata, baslat, durdur, destek: sesliGirisVar() };
}
