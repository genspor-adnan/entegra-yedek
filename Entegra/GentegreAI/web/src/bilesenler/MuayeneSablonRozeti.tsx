import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { MuayeneSablonSecenek } from '../api/uclar/liste';
import { guvenli, mesaj } from './mesaj';

/**
 * ÖNERİLEN ŞABLON ROZETİ: "Şablon Uygula" sağında tek tıkla uygulanacak şablon.
 *
 * Seçim SUNUCUDA (933, kullanıcı: "muayene sırasında doktor adına şablon varsa
 * onu kullansın yoksa genel branş şablonu kullanılsın"): muayenenin doktorunun
 * o bölümdeki fizik muayene şablonu; yoksa bölüm varsayılanı (⭐), yoksa bölümün
 * ortak şablonu. Eskiden bölüm ADINDAN şablon adı tahmin ediliyordu - bölüm/doktor
 * bağı (927) varken tahmin hem gereksiz hem yanıltıcıydı. Öneri yoksa rozet çizilmez.
 */
export function MuayeneSablonRozeti({ muayeneId, onUygulandi }:
  { muayeneId: number; onUygulandi(): void }) {
  const [sablon, setSablon] = useState<MuayeneSablonSecenek | null>(null);
  const [mesgul, setMesgul] = useState(false);

  useEffect(() => {
    let iptal = false;
    void api.muayeneSablonlari(muayeneId)
      .then(y => { if (!iptal) setSablon(y.onerilen) })
      .catch(() => { if (!iptal) setSablon(null) });
    return () => { iptal = true };
  }, [muayeneId]);

  if (!sablon) return null;
  const doktorun = sablon.oncelik === 0;

  const uygula = () => guvenli(async () => {
    setMesgul(true);
    try {
      const y = await api.muayeneSablonUygula(muayeneId, sablon.id);
      mesaj(y.mesaj);
      onUygulandi();
    } finally { setMesgul(false) }
  });

  return (
    <button type="button" className={`rozet ${doktorun ? 'olumlu' : 'mavi'} sablon-onerisi`} disabled={mesgul}
      title={`${doktorun ? 'Doktorun kendi şablonu' : 'Bölüm şablonu'}: ${sablon.ad} — tıklayın, uygulansın`}
      onClick={() => void uygula()}>
      {doktorun ? '👤' : '🩺'} {sablon.ad}
    </button>
  );
}
