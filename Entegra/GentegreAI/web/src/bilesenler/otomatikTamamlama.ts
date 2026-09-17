import { useEffect } from 'react';

/**
 * TARAYICI OTOMATİK TAMAMLAMASINI KAPATIR (780).
 *
 * Kullanıcı: *"kimlik ekranı ve diğer ekranlarda dahil editlerin içine
 * tıklayınca otomatik tamamlama gelmesin."*
 *
 * ============ NEDEN MERKEZÎ ==========================================
 * Uygulamada 500'ün üzerinde `<input>` var. Her birine `autoComplete="off"`
 * yazmak bugünküleri kapatır ama YARIN EKLENENİ kapatmaz - kural kodun
 * her yerine dağılmış olur ve bir sonraki ekranda yine unutulur. Tek yerde
 * duran bir gözlemci, sonradan çizilen alanları da kapsar.
 *
 * ============ PAROLADA "off" YETMEZ ==================================
 * Chrome ve Edge, `type="password"` alanlarında `autocomplete="off"`u
 * YOK SAYAR (kayıtlı parolayı yine önerirler). Tarayıcıların dinlediği
 * tek değer `new-password`tür: "bu alan yeni parola" demek, kayıtlı
 * parolanın açılır listesini bastırır.
 *
 * ============ KENDİ ÖNERİLERİMİZ KALIR ===============================
 * `datalist` ile verdiğimiz öneriler (ör. masraf beyanında fiş belge
 * numaraları) BU KURALDAN ETKİLENMEZ: onlar tarayıcı geçmişi değil, bizim
 * listemiz. Kapatılan şey tarayıcının kendi geçmiş/adres/parola önerisi.
 *
 * ============ GARANTİ DEĞİL, İSTEKTİR ================================
 * `autocomplete` tarayıcıya verilen bir istektir; parola yöneticileri
 * (tarayıcının kendi kasası dâhil) kendi kurallarıyla yine kaydetmeyi
 * önerebilir. Uygulamanın yapabileceği son nokta burasıdır.
 */
const KAPALI = 'off';

function kapat(e: Element) {
  const alan = e as HTMLInputElement | HTMLTextAreaElement;
  // TİPİ OLMAYAN input metin sayılır (HTML varsayılanı).
  const tip = (alan as HTMLInputElement).type?.toLowerCase() ?? 'text';
  // Düğme/onay kutusu gibi alanlarda otomatik tamamlama zaten yok; onlara
  //   öznitelik yazmak DOM'u gereksiz kalabalıklaştırır.
  if (['checkbox', 'radio', 'button', 'submit', 'reset', 'file', 'range',
       'color', 'hidden', 'image'].includes(tip)) return;

  const istenen = tip === 'password' ? 'new-password' : KAPALI;
  if (alan.getAttribute('autocomplete') !== istenen)
    alan.setAttribute('autocomplete', istenen);
}

/**
 * Uygulama kökünde BİR KEZ çağrılır. Var olan alanları kapatır ve sonradan
 * eklenenleri gözlemciyle yakalar.
 */
export function useOtomatikTamamlamaKapali() {
  useEffect(() => {
    const tara = (kok: ParentNode) =>
      kok.querySelectorAll('input, textarea').forEach(kapat);

    tara(document);

    // GÖZLEMCİ: React her ekranda yeni alanlar çiziyor; ilk taramayla
    //   yetinmek, ikinci ekranda kuralı kaybetmek olurdu.
    const gozlemci = new MutationObserver(kayitlar => {
      for (const k of kayitlar) {
        for (const d of k.addedNodes) {
          if (!(d instanceof Element)) continue;
          if (d.matches('input, textarea')) kapat(d);
          else tara(d);
        }
      }
    });
    gozlemci.observe(document.body, { childList: true, subtree: true });
    return () => gozlemci.disconnect();
  }, []);
}
