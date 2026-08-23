import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { ayarOnbellegiTemizle } from '../api/ayarlar';
import { ApiHatasi, type AyarSatiri } from '../api/sozlesme';
import { YardimIkonu } from './YardimIkonu';

/**
 * Ayar ekranlarinin ortak kancasi: /api/ayar'i yukler, tek alan yazar, hata ve
 * "kaydedildi" bilgisini yonetir. Genel Ayarlar ve Stok Ayarlari ayni listeyi
 * kullanir (beyaz liste sunucuda) - her ekran kendi anahtarlarini cizer.
 */
export function useAyarlar() {
  const [ayarlar, setAyarlar] = useState<AyarSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      setAyarlar(await api.ayarlar());
      setHata(null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void yukle() }, [yukle]);

  const yaz = useCallback(async (anahtar: string, yeni: string) => {
    try {
      setAyarlar(await api.ayarYaz(anahtar, yeni));
      ayarOnbellegiTemizle();          // acilacak ekranlar yeni degeri okusun
      setHata(null);
      setBilgi('Ayar kaydedildi.');
      setTimeout(() => setBilgi(null), 2500);
    } catch (h) {
      // ONCE tazele, SONRA hatayi yaz: yukle() basarida setHata(null) yaptigi
      //   icin ters sirada mesaj aninda siliniyordu.
      await yukle();
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  }, [yukle]);

  return { ayarlar, yukleniyor, hata, bilgi, yaz };
}

export type AyarTipi = 'sayi' | 'metin' | 'mantik' | 'secenek';

/**
 * Tek ayar satiri — GENEL KURAL: etiket EDITIN USTUNDE, aciklama alt paragrafta
 * degil editin SAGINDAKI "?" ikonunda (metin public.help'te).
 *
 * Kayit ANINDA: sayi/metin alanlar blur ya da Enter'da, mantik/secenek
 * degistigi anda yazilir. Tek alanlik ayarlara "Kaydet" dugmesi koymak
 * kullaniciyi bekletmekten baska ise yaramiyordu.
 */
export function AyarAlani({ anahtar, etiket, tip = 'sayi', secenekler, ayarlar, onYaz, genis }: {
  anahtar: string;
  etiket: string;
  tip?: AyarTipi;
  /** tip='secenek' icin: [{ deger, ad }]. */
  secenekler?: { deger: string; ad: string }[];
  ayarlar: AyarSatiri[];
  onYaz(anahtar: string, deger: string): void | Promise<void>;
  /** Metin alanini genis ciz (kisa kodlarda dar durur). */
  genis?: boolean;
}) {
  const kayit = ayarlar.find(a => a.anahtar === anahtar);
  const kayitliDeger = kayit?.deger ?? '';
  const [taslak, setTaslak] = useState<string | null>(null);
  const deger = taslak ?? kayitliDeger;

  const yardim = (
    <YardimIkonu anahtar={`ayar.${anahtar}`}
                 baslik={kayit?.yardimBaslik}
                 metin={kayit?.yardim} />
  );

  const bitir = (v: string) => {
    setTaslak(null);
    if (v.trim() !== kayitliDeger) void onYaz(anahtar, v.trim());
  };

  return (
    <label className="alan">
      <span className="etiket">{etiket}</span>
      <span className="ikili">
        {tip === 'mantik' ? (
          <input type="checkbox" checked={deger === '1'}
                 onChange={e => { setTaslak(null); void onYaz(anahtar, e.target.checked ? '1' : '0') }} />
        ) : tip === 'secenek' ? (
          <select value={deger}
                  onChange={e => { setTaslak(null); void onYaz(anahtar, e.target.value) }}>
            {(secenekler ?? []).map(s => <option key={s.deger} value={s.deger}>{s.ad}</option>)}
          </select>
        ) : (
          <input className={tip === 'sayi' ? 'hiza-sag' : genis ? 'genis-deger' : ''}
                 value={deger}
                 inputMode={tip === 'sayi' ? 'numeric' : undefined}
                 onChange={e => setTaslak(e.target.value)}
                 onBlur={e => bitir(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter') (e.target as HTMLInputElement).blur() }} />
        )}
        {yardim}
      </span>
    </label>
  );
}
