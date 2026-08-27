import { api } from '../api/istemci';
import { mesaj, onay } from '../bilesenler/mesaj';
import { hataMetni, type EBelgeMesaji, type ListeSatiri } from '../api/sozlesme';

/**
 * e-BELGE MENUSUNUN "cikti" adimlari: Ön İzle · PDF · HTML · XML · Mesaj Geçmişi.
 *
 * `Liste.tsx`ten AYRILDI (180 refaktor): aksiyon switch'i 100 satiri gecmisti ve
 * bu bes adim listeden bagimsiz - hepsi tek bir belge id'si alip ciktisini
 * uretiyor. Hazırla/Gönder/Seri/Sıfırla listede KALDI: onlar listeyi tazeliyor
 * ve onay diyalogu istiyor, yani ekranin durumuna bagli.
 */

/** Satir sonu - sablon dizgede kacis karisikligi olmasin diye sabit. */
const NL = '\n';

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
 * GIB GORUNTUSU: UBL'e goruntuleme XSLT'si uygulanir (182) - GIB'e giden
 * belgenin gordugu goruntunun AYNISI. Sablon yoksa ya da donusum basarisiz
 * olursa uygulamanin kendi sade HTML onizlemesine duseriz; kullanici bos ekran
 * gormesin.
 */
async function goruntuUret(belgeId: number): Promise<string> {
  try {
    const y = await api.belgeEBelgeUbl(belgeId);
    if (y.xslt && y.ubl) {
      const ayristirici = new DOMParser();
      const ubl = ayristirici.parseFromString(y.ubl, 'application/xml');
      const xslt = ayristirici.parseFromString(y.xslt, 'application/xml');
      // Ayristirma hatasi "parsererror" dugumu birakir - sessizce yanlis
      //   goruntu cizmek yerine sade onizlemeye duselim.
      if (!ubl.querySelector('parsererror') && !xslt.querySelector('parsererror')) {
        const islemci = new XSLTProcessor();
        islemci.importStylesheet(xslt);
        const sonuc = islemci.transformToDocument(ubl);
        if (sonuc?.documentElement) {
          return new XMLSerializer().serializeToString(sonuc);
        }
      }
    }
  } catch {
    /* XSLT yoksa/bozuksa sade onizlemeye dusulur */
  }
  const h = await api.belgeEBelgeOnizle(belgeId);
  return h.html;
}

/**
 * Goruntuyu yeni sekmede acar. `yazdir` ise yazdirma penceresini de tetikler -
 * "PDF Kaydet" ayri bir PDF motoru yerine tarayicinin "PDF olarak kaydet"
 * secenegini kullanir.
 */
async function onizle(belgeId: number, yazdir: boolean) {
  const html = await goruntuUret(belgeId);
  const pencere = window.open('', '_blank');
  if (!pencere) {
    mesaj('Tarayıcı yeni sekmeyi engelledi; açılır pencere iznini verin.');
    return;
  }
  pencere.document.write(html);
  pencere.document.close();
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
  yenile?: () => void,
): Promise<boolean> {
  const id = Number(satir.id);
  const belgeNo = String(satir.belgeNo ?? satir.id);
  const dosyaAdi = ebelgeDosyaAdi(ebelgeTurAdi(satir), belgeNo,
                                  String(satir.tarafUnvan ?? ''));
  const hazirlanmamis = Number(satir.efaturaDurum ?? 0) === 0;

  /**
   * ONIZLEMEDEN ONCE HAZIRLA (kullanici; Delphi MenuOnizle de boyle yapar):
   * hazirlanmamis belgenin numarasi ve turu HENUZ YOK - onizleme "belge no -"
   * gosterirdi. Kullanici onay verirse once hazirlanir, sonra onizlenir.
   * Hazirlama numara ve seri TUKETIR, o yuzden sessizce yapilmaz.
   */
  const hazirlaGerekirse = async (): Promise<boolean> => {
    if (!hazirlanmamis) return true;
    if (!await onay(`"${belgeNo}" için e-Belge henüz hazırlanmamış.

`
                  + 'Ön izleme için önce hazırlansın mı? '
                  + 'Belgeye seri ve e-Belge numarası verilir.')) return false;
    const h = await api.belgeEBelgeHazirla(id);
    mesaj((h.uyarilar ?? []).join(' • ') || 'e-Belge hazırlandı.');
    yenile?.();
    return true;
  };

  try {
    switch (kod) {
      case 'ebelge.onizle':
        if (!await hazirlaGerekirse()) return true;
        await onizle(id, false);
        return true;
      case 'ebelge.pdf':
        if (!await hazirlaGerekirse()) return true;
        await onizle(id, true);
        return true;
      case 'ebelge.html': {
        // Ekranda gorulen GORUNTUNUN aynisi insin (XSLT varsa o).
        dosyaIndir(await goruntuUret(id), `${dosyaAdi}.html`, 'text/html;charset=utf-8');
        return true;
      }
      // XML KAYDET: artik GERCEK UBL (182). Entegratore giden ham istek
      //   (izibiz'de JSON) ayri bir uctan alinabiliyor; kullanici "XML" derken
      //   GIB belgesini kastediyor.
      case 'ebelge.xml': {
        const y = await api.belgeEBelgeUbl(id);
        dosyaIndir(y.ubl, `${dosyaAdi}.xml`, 'application/xml;charset=utf-8');
        return true;
      }
      // DURUM SORGULA (183): entegratordeki GIB durumunu ceker ve kayda isler.
      case 'ebelge.durum': {
        const d = await api.belgeEBelgeDurum(id);
        const ek = d.degisti ? 'Durum güncellendi.' : 'Durum değişmemiş.';
        mesaj(d.kod
          ? `${d.belgeNo}: ${d.aciklama || d.kod}` + NL + NL + ek
          : `${d.belgeNo}: ${d.aciklama}`);
        if (d.degisti) yenile?.();
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
    mesaj(hataMetni(h));
    return true;                 // ele alindi: cagiran yeniden denemesin
  }
}
