import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * ANTET LOGOSU (772) — kâğıda basılan çıktılarda kurum logosu.
 *
 * Logo şube kartının "Logo" görselidir (`dokuman` kaynağı `sube`); hangi
 * dosyanın logo sayıldığına **sunucu** karar verir (`v_sube_antet`), ekran
 * yalnız gelen kimliği çizer. Üst şeritteki logo da aynı kuralı kullanıyor -
 * ekranda görünen logo ile kâğıttaki logonun farklı olması, aynı kurumun iki
 * kimliği demekti.
 *
 * `yedek` logosuz kurulumda çizilecek emoji/harf: lab çıktısı 🧪, radyoloji
 * 🏥 kullanıyordu ve logo tanımlanana kadar kutu boş kalmamalı.
 *
 * İçerik ucu imzalı URL döndürdüğü için `useEffect` ile çözülüyor; hata
 * SESSİZ yutulur ve yedek çizilir - logonun okunamaması raporun basılmasını
 * engellememeli.
 */
export function AntetLogo({ dokumanId, yedek, sinif = 'logo' }: {
  dokumanId?: number | null;
  yedek?: string;
  /** Kabın sınıf adı: çıktılarda `logo`, döküm baskısında `dk-logo`. */
  sinif?: string;
}) {
  const [url, setUrl] = useState<string | null>(null);

  useEffect(() => {
    let gecerli = true;
    setUrl(null);
    if (dokumanId) {
      api.dokumanIcerikUrl(dokumanId)
        .then(u => { if (gecerli) setUrl(u) })
        .catch(() => { /* logo okunamadı: yedek çizilir, çıktı basılır */ });
    }
    return () => { gecerli = false };
  }, [dokumanId]);

  // LOGO DA YEDEK DE YOKSA KUTU ÇİZİLMEZ: boş çerçeve, olmayan bir logonun
  //   yerini tutuyormuş gibi görünürdü.
  if (!url && !yedek) return null;

  return (
    <div className={sinif}>
      {url ? <img src={url} alt="" /> : yedek}
    </div>
  );
}
