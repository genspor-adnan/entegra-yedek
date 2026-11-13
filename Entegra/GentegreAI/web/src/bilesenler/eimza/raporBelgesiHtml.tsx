import { createRoot } from 'react-dom/client';
import { RadyolojiRaporBelgesi, type RaporCiktiVerisi } from '../../sayfalar/RadyolojiRaporCikti';
import { htmlBelgesi, stilGomuluKopya } from '../cikti/ciktiDonustur';

/**
 * İMZALANACAK RAPOR BELGESİ (1337): çıktı sayfasıyla AYNI bileşen (RadyolojiRaporBelgesi) ekran dışında çizilir,
 * hesaplanmış stiller gömülür (Word/HTML dışa aktarımla aynı yol - ciktiDonustur) ve tek dosyalık HTML üretilir.
 * Resimler data: URI olur; böylece imzalı XML'in içindeki belge kendi başına açılır.
 *
 * Neden HTML (PDF değil): üründe PDF üreten bir motor yok (yazdırma tarayıcının "PDF olarak kaydet"iyle);
 * Teletıp ORU da aynı HTML'i taşır (1334). XAdES enveloping her mimeType'ı sarar; sunucu mimeType'ı kaydeder,
 * ileride sunucu tarafı PDF gelirse imza yolu değişmez.
 */
export async function raporBelgesiHtml(veri: RaporCiktiVerisi, baslik: string): Promise<string> {
  const kap = document.createElement('div');
  // Görünür ama ekran dışı: display:none'da getComputedStyle boş döner, resim ölçüleri sıfırlanır.
  kap.style.cssText = 'position:fixed;left:-20000px;top:0;width:900px;background:#fff;z-index:-1';
  document.body.appendChild(kap);
  const kok = createRoot(kap);
  try {
    kok.render(<RadyolojiRaporBelgesi veri={veri} />);
    // React 19 render'ı eşzamansız yerleştirir; iki kare bekle (resimler data: URI'ye çevrilmeden önce boyutları otursun).
    await new Promise<void>(r => requestAnimationFrame(() => requestAnimationFrame(() => r())));
    const a4 = kap.querySelector<HTMLElement>('.cikti-sayfa') ?? (kap.firstElementChild as HTMLElement | null) ?? kap;
    const kopya = await stilGomuluKopya(a4);
    return htmlBelgesi(baslik, kopya);
  } finally {
    kok.unmount();
    kap.remove();
  }
}
