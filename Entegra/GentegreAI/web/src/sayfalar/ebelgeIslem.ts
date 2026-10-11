import { mesaj } from '../bilesenler/mesaj';
import type { ListeSatiri } from '../api/sozlesme';

/**
 * GELEN KUTUSU CIKTI YARDIMCILARI (gelenBelgeIslem): goruntu penceresi ve
 * dosya adi. GIDEN e-Fatura 11.10.2026'da Delphi'ye gore yeniden yazildi -
 * bilesenler/efatura/efaturaIslem.ts.
 */


// Indirme `bilesenler/indir.ts`e tasindi (bes kopyasi vardi); buradan
//   yeniden disa vuruluyor ki e-Belge cagrilari degismesin.
import { dosyaIndir } from '../bilesenler/indir';
export { dosyaIndir };

/**
 * Goruntuyu yeni sekmede acar. `yazdir` ise yazdirma penceresini de tetikler -
 * "PDF Kaydet" ayri bir PDF motoru yerine tarayicinin "PDF olarak kaydet"
 * secenegini kullanir.
 *
 * BASLIK = DOSYA ADI: tarayicinin yazdirma diyalogu kaydedilecek PDF'in adini
 * sayfanin `document.title`indan alir. XSLT ciktisinin kendi basligi
 * ("e-Fatura") geliyordu; kullanicinin istedigi ad ancak boyle gecer.
 */
export async function belgeGoruntusuAc(html: string, baslik: string, yazdir: boolean) {
  const pencere = window.open('', '_blank');
  if (!pencere) {
    mesaj('Tarayıcı yeni sekmeyi engelledi; açılır pencere iznini verin.');
    return;
  }
  pencere.document.write(html);
  pencere.document.close();
  // Sablonun kendi <title>'i yazildiktan SONRA ezilir.
  try { pencere.document.title = baslik } catch { /* farkli koken - onemsiz */ }
  if (yazdir) pencere.setTimeout(() => pencere.print(), 400);
}

/**
 * KAYDET dosya adi (kullanici kurali): "<tür adı> <belge no> <cari adı ilk 2 kelime>"
 *   ör. "e-Arşiv GNY2026000000009 3EKSEN TEKNOLOJİ.xml"
 *
 * Tur adi listedeki rozetten gelir ("e-Arşiv ✓" gibi) - onay isareti ve fazla
 * bosluk atilir. Dosya sisteminde yasakli karakterler temizlenir; Turkce
 * harfler KORUNUR (Windows ve Linux ikisinde de gecerli).
 */
export function ebelgeDosyaAdi(turAdi: string, belgeNo: string, cariAdi: string): string {
  const temiz = (m: string) => (m ?? '').replace(/[\\/:*?"<>|]/g, ' ')
                                        .replace(/\s+/g, ' ').trim();
  const tur = temiz(turAdi).replace(/[✓✔]/g, '').trim();
  const cari = temiz(cariAdi).split(' ').slice(0, 2).join(' ');
  return [tur, temiz(belgeNo), cari].filter(Boolean).join(' ') || 'belge';
}

/** Liste satirindan tur adi: satis faturasinda `efatura`, irsaliyede `eIrsaliye`,
    gelen kutusunda `belgeTuruAdi` kolonu tasir. */
export function ebelgeTurAdi(satir: ListeSatiri): string {
  const aday = [satir.belgeTuruAdi, satir.efatura, satir.eIrsaliye]
    .map(x => String(x ?? '').trim())
    .find(x => x.length > 0 && x !== 'Kağıt' && x !== 'Bilinmiyor');
  return aday ?? 'e-Belge';
}
