import { api } from '../api/istemci';
import { hataMetni, type EBelgeMesaji, type ListeSatiri } from '../api/sozlesme';

/**
 * e-BELGE MENUSUNUN "cikti" adimlari: Ön İzle · PDF · HTML · XML · Mesaj Geçmişi.
 *
 * `Liste.tsx`ten AYRILDI (180 refaktor): aksiyon switch'i 100 satiri gecmisti ve
 * bu bes adim listeden bagimsiz - hepsi tek bir belge id'si alip ciktisini
 * uretiyor. Hazırla/Gönder/Seri/Sıfırla listede KALDI: onlar listeyi tazeliyor
 * ve onay diyalogu istiyor, yani ekranin durumuna bagli.
 */

/** Metni dosya olarak indirir. Blob URL kisa omurlu - birakilmazsa sekme
    kapanana kadar bellekte kalir. */
export function dosyaIndir(icerik: string, ad: string, tip: string) {
  const url = URL.createObjectURL(new Blob([icerik], { type: tip }));
  const bag = document.createElement('a');
  bag.href = url;
  bag.download = ad;
  document.body.appendChild(bag);
  bag.click();
  bag.remove();
  setTimeout(() => URL.revokeObjectURL(url), 10_000);
}

/**
 * Onizleme HTML'ini yeni sekmede acar. `yazdir` ise yazdirma penceresini de
 * tetikler - "PDF Kaydet" ayri bir PDF motoru yerine tarayicinin
 * "PDF olarak kaydet" secenegini kullanir.
 */
async function onizle(belgeId: number, yazdir: boolean) {
  const y = await api.belgeEBelgeOnizle(belgeId);
  const pencere = window.open('', '_blank');
  if (!pencere) {
    alert('Tarayıcı yeni sekmeyi engelledi; açılır pencere iznini verin.');
    return;
  }
  pencere.document.write(y.html);
  pencere.document.close();
  if (yazdir) pencere.setTimeout(() => pencere.print(), 400);
}

/**
 * Menunun cikti adimlarini calistirir. Bilinen bir kod degilse `false` doner -
 * cagiran kendi switch'ine devam eder.
 *
 * @param mesajGoster mesaj gecmisi penceresini acan geri cagrim
 */
export async function ebelgeCiktisi(
  kod: string,
  satir: ListeSatiri,
  mesajGoster: (veri: { belgeNo: string; satirlar: EBelgeMesaji[] }) => void,
): Promise<boolean> {
  const id = Number(satir.id);
  const belgeNo = String(satir.belgeNo ?? satir.id);
  try {
    switch (kod) {
      case 'ebelge.onizle':
        await onizle(id, false);
        return true;
      case 'ebelge.pdf':
        await onizle(id, true);
        return true;
      case 'ebelge.html': {
        const y = await api.belgeEBelgeOnizle(id);
        dosyaIndir(y.html, `${belgeNo}.html`, 'text/html;charset=utf-8');
        return true;
      }
      // XML KAYDET: entegratore giden GOVDE. izibiz JSON tabanli oldugu icin
      //   uzanti bicime gore secilir - UBL ureten entegratorde .xml olur.
      case 'ebelge.xml': {
        const y = await api.belgeEBelgeGovde(id);
        const xmlMi = y.bicim === 2;
        dosyaIndir(y.govde, `${y.dosyaAdi}.${xmlMi ? 'xml' : 'json'}`,
                   xmlMi ? 'application/xml' : 'application/json');
        return true;
      }
      case 'ebelge.mesajlar': {
        const y = await api.belgeEBelgeMesajlar(id);
        mesajGoster({ belgeNo, satirlar: y.mesajlar });
        return true;
      }
      default:
        return false;
    }
  } catch (h) {
    alert(hataMetni(h));
    return true;                 // ele alindi: cagiran yeniden denemesin
  }
}
