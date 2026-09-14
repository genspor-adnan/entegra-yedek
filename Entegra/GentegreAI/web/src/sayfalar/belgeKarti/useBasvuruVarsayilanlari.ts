import { useEffect } from 'react';
import { api } from '../../api/istemci';
import type { KurumSecenegi } from './useBasvuruKaynaklari';

/**
 * BAŞVURUNUN KENDİLİĞİNDEN DOLAN ALANLARI.
 *
 * İkisi de YALNIZ BOŞ alanı doldurur ve yalnız YENİ kartta çalışır: kayıtlı
 * belgede kullanıcının seçimi ezilmez, dolu alana dokunulmaz. "Boşsa doldur"
 * ile "her açılışta yaz" arasındaki fark, kullanıcının elle yaptığı seçimin
 * kartı her açtığında geri alınıp alınmamasıdır.
 */
export function useBasvuruVarsayilanlari({
  basvuruMu, belgeId, hastaId, kurumlar, odeyenKurumId, personelId,
  onKurum, onGelisSekli,
}: {
  basvuruMu: boolean;
  belgeId?: number;
  /** Seçili hasta (belgenin tarafı). */
  hastaId?: number | null;
  kurumlar: KurumSecenegi[];
  odeyenKurumId: number | null;
  personelId: number | null;
  onKurum(kurumId: number): void;
  /**
   * Geliş şeklini DOLDURUR - çağıran, alan zaten doluysa DOKUNMAMALI
   * (`setBasvuruBilgi(o => o.gelisSekli ? o : …)`): belge sunucudan gelirken
   * alan bir an boş görünür; koşulsuz yazmak kartı kullanıcı hiç dokunmadan
   * "değişmiş" gösterir ve Kapat'ta gereksiz "kaydetmediniz" sorusu çıkarır.
   */
  onGelisSekli(): void;
}) {
  /**
   * VARSAYILAN ÖDEYEN KURUM (kullanıcı: "default kurum seçili varsa o gelir"):
   * hasta seçilince onun KAYITLI kurumu (taraf_hasta.kurum_id) başvuruya geçer.
   * Hastanın kurumu yoksa listedeki "Özel" (tür 1) satırı seçilir - "hasta
   * kendi öder" de bir kurumdur ve alan ZORUNLUDUR.
   */
  useEffect(() => {
    if (!basvuruMu || belgeId || !hastaId || odeyenKurumId != null
        || kurumlar.length === 0) return;
    let iptal = false;
    void (async () => {
      let secilen: number | null = null;
      try {
        const y = await api.liste('hasta', {
          sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: hastaId },
        });
        const k = Number(y.satirlar[0]?.kurumId ?? 0);
        if (k && kurumlar.some(x => x.id === k)) secilen = k;
      } catch { /* okunamazsa asagidaki varsayilana duser */ }
      if (secilen === null) secilen = kurumlar.find(x => x.tur === 1)?.id ?? null;
      if (!iptal && secilen != null) onKurum(secilen);
    })();
    return () => { iptal = true };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [basvuruMu, belgeId, hastaId, kurumlar.length]);

  /**
   * GÖNDEREN HİÇ SEÇİLMEMİŞSE geliş şekli boş kalmasın: başvuru "kendi
   * isteğiyle" açılmış demektir (kullanıcı). Kullanıcı değiştirirse
   * dokunulmaz - yalnız BOŞ alan doldurulur.
   */
  useEffect(() => {
    if (!basvuruMu || personelId) return;
    onGelisSekli();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [basvuruMu, personelId]);
}
