import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { DokumanSatiri } from '../../api/sozlesme';
import { basHarfler } from '../basHarfler';

/**
 * STOK AVATARI (mockup Ekranlar/Stok/stok_karti_baslik_kip.html, kullanıcı 09.11.2026 "avatar da ekle"): kimlik
 * şeridinin solunda, kişi kartı bandıyla aynı 44px daire. Varsayılan resim (Resim / Doküman ★, yoksa ilk resim)
 * varsa o; yoksa stok adının baş harfleri (kurumsal kural: 1. + 2. kelime). Kipten (görüntüleme / düzenleme)
 * etkilenmez. Resim varsa tıklanınca yeni sekmede büyük açılır.
 *
 * Resim KartResimKutusu ile aynı yoldan okunur (dokumanlar → varsayilan → içerik URL); yeni kartta id yok,
 * yalnız baş harfler.
 */
export function StokAvatar({ kaynakId, ad, pasif = false }: {
  kaynakId?: number;
  ad: string;
  /** Pasif stok: gri ton (mockup 3. senaryo). */
  pasif?: boolean;
}) {
  const [url, setUrl] = useState<string | null>(null);

  useEffect(() => {
    if (!kaynakId) { setUrl(null); return }
    let iptal = false;
    let blobUrl: string | null = null;
    api.dokumanlar('stok', kaynakId)
      .then((satirlar: DokumanSatiri[]) => {
        const resimler = satirlar.filter(s => s.contentType.startsWith('image/'));
        const resim = resimler.find(s => s.varsayilan) ?? resimler[0];
        return resim ? api.dokumanIcerikUrl(resim.id) : null;
      })
      .then(u => { if (!u || iptal) return; blobUrl = u; setUrl(u) })
      .catch(() => setUrl(null));
    return () => { iptal = true; if (blobUrl) URL.revokeObjectURL(blobUrl) };
  }, [kaynakId]);

  const harf = ad.trim() ? basHarfler(ad, true) : '?';
  return (
    <span className={`kart-avatar stok-avatar${pasif ? ' pasif' : ''}${url ? ' resimli' : ''}`}
          title={url ? 'Varsayılan resim - büyütmek için tıklayın' : ad.trim() ? ad : undefined}
          data-testid="stok-avatar"
          onClick={url ? () => window.open(url, '_blank', 'noopener') : undefined}>
      {url ? <img src={url} alt={ad} /> : harf}
    </span>
  );
}
