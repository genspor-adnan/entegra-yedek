import { api } from '../api/istemci';
import { mesaj, metinSor, onay } from '../bilesenler/mesaj';
import { hataMetni, type EBelgeMesaji, type ListeSatiri } from '../api/sozlesme';
import { dosyaIndir } from './ebelgeIslem';

/**
 * GELEN e-BELGE aksiyonlari (187): kutuyu yenile · goruntule · kabul · red ·
 * XML kaydet.
 *
 * Giden taraftan AYRI dosya: gelen belgede hazirlama/gonderme yok, buna karsilik
 * kabul/red var. Ikisini tek switch'te toplamak `Liste.tsx`i yine sisirirdi.
 */

/**
 * GONDERICININ GORUNTUSU: TR UBL faturalari goruntuleme XSLT'sini belgenin
 * KENDI icinde tasir (cac:AdditionalDocumentReference / EmbeddedDocumentBinaryObject,
 * base64). Once onu deneriz - alici, gonderenin tasarladigi faturayi gorur.
 * Yoksa ham XML'i okunur bicimde gosteririz; bos ekran birakmayiz.
 */
function goruntuUret(ubl: string): string {
  const ayristirici = new DOMParser();
  const belge = ayristirici.parseFromString(ubl, 'application/xml');
  if (belge.querySelector('parsererror')) return `<pre>${kacir(ubl)}</pre>`;

  // Gomulu XSLT: base64 govdenin ilk baytlari "<?xml" ya da "<xsl" olmali.
  const gomulu = Array.from(belge.getElementsByTagName('*'))
    .filter(d => d.localName === 'EmbeddedDocumentBinaryObject');
  for (const d of gomulu) {
    try {
      const cozulmus = new TextDecoder('utf-8').decode(
        Uint8Array.from(atob((d.textContent ?? '').trim()), c => c.charCodeAt(0)));
      if (!cozulmus.includes('xsl:stylesheet') && !cozulmus.includes('xsl:transform')) continue;

      const xslt = ayristirici.parseFromString(cozulmus, 'application/xml');
      if (xslt.querySelector('parsererror')) continue;

      const islemci = new XSLTProcessor();
      islemci.importStylesheet(xslt);
      const sonuc = islemci.transformToDocument(belge);
      if (sonuc?.documentElement) return new XMLSerializer().serializeToString(sonuc);
    } catch {
      /* bozuk base64 / desteklenmeyen XSLT - sonraki adaya gec */
    }
  }
  return `<pre style="font:12px/1.5 monospace;white-space:pre-wrap">${kacir(ubl)}</pre>`;
}

function kacir(m: string) {
  return m.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

/**
 * Gelen belge aksiyonlari. Isledi ise true doner; false ise cagiran kendi
 * switch'ine devam eder.
 */
export async function gelenBelgeAksiyonu(
  kod: string, satir: ListeSatiri | null, yenile: () => void,
  mesajGoster?: (m: { belgeNo: string; satirlar: EBelgeMesaji[] }) => void): Promise<boolean> {

  const id = satir ? Number(satir.id) : 0;
  const no = String(satir?.belgeNo ?? id);

  /** Goruntuyu yeni sekmede acar; `yazdir` ise yazdirma penceresini tetikler
      (PDF, tarayicinin "PDF olarak kaydet" secenegiyle alinir). */
  const goster = async (yazdir: boolean) => {
    const y = await api.gelenBelgeUbl(id);
    const pencere = window.open('', '_blank');
    if (!pencere) { mesaj('Tarayıcı yeni sekmeyi engelledi; açılır pencere iznini verin.'); return }
    pencere.document.write(goruntuUret(y.ubl));
    pencere.document.close();
    if (yazdir) pencere.setTimeout(() => pencere.print(), 400);
    yenile();                                     // "Okundu" isaretlendi
  };

  switch (kod) {
    // e-FATURA KOMBOSU: gelen belgede id BELGE degil e_belge kaydidir; bu
    //   yuzden giden taraftaki ebelgeCiktisi'ne DUSMEZ, buraya gelir.
    case 'ebelge.onizle':
      if (!id) return true;
      try { await goster(false) } catch (h) { mesaj(hataMetni(h)) }
      return true;

    case 'ebelge.pdf':
      if (!id) return true;
      try { await goster(true) } catch (h) { mesaj(hataMetni(h)) }
      return true;

    case 'ebelge.html':
      if (!id) return true;
      try {
        const y = await api.gelenBelgeUbl(id);
        dosyaIndir(goruntuUret(y.ubl), `${no}.html`, 'text/html;charset=utf-8');
      } catch (h) { mesaj(hataMetni(h)) }
      return true;

    case 'ebelge.xml':
      if (!id) return true;
      try {
        const y = await api.gelenBelgeUbl(id);
        dosyaIndir(y.ubl, `${no}.xml`, 'application/xml;charset=utf-8');
      } catch (h) { mesaj(hataMetni(h)) }
      return true;

    case 'ebelge.mesajlar':
      if (!id) return true;
      try {
        const y = await api.gelenBelgeMesajlar(id);
        mesajGoster?.({ belgeNo: no, satirlar: y.mesajlar });
      } catch (h) { mesaj(hataMetni(h)) }
      return true;

    case 'gelen.yenile':
      try {
        const y = await api.gelenKutuYenile();
        mesaj(y.mesaj);
        yenile();
      } catch (h) { mesaj(hataMetni(h)) }
      return true;

    case 'gelen.goruntule': {
      if (!id) return true;
      try {
        const y = await api.gelenBelgeUbl(id);
        const pencere = window.open('', '_blank');
        if (!pencere) { mesaj('Tarayıcı yeni sekmeyi engelledi; açılır pencere iznini verin.'); return true }
        pencere.document.write(goruntuUret(y.ubl));
        pencere.document.close();
        yenile();                                   // "Okundu" isaretlendi
      } catch (h) { mesaj(hataMetni(h)) }
      return true;
    }

    case 'gelen.xml': {
      if (!id) return true;
      try {
        const y = await api.gelenBelgeUbl(id);
        dosyaIndir(y.ubl, `${no}.xml`, 'application/xml;charset=utf-8');
      } catch (h) { mesaj(hataMetni(h)) }
      return true;
    }

    // ALIS FATURASINA AKTAR: kutu satirindan gercek belge uretilir; cari borcu
    //   ve stok girisi ancak bundan sonra dogar.
    case 'gelen.aktar': {
      if (!id) return true;
      try {
        const y = await api.gelenBelgeAktar(id);
        mesaj(y.mesaj);
        yenile();
      } catch (h) { mesaj(hataMetni(h)) }
      return true;
    }

    // KABUL / RED: GIB'e uygulama yaniti gider, GERI ALINAMAZ - ikisi de onay ister.
    //   Redde gerekce ZORUNLU (sunucu da dogrular); kabulde acikla istege bagli.
    case 'gelen.kabul':
    case 'gelen.red': {
      if (!id) return true;
      const kabul = kod === 'gelen.kabul';
      if (!await onay(
        `"${no}" numaralı belge ${kabul ? 'KABUL' : 'RED'} edilecek.\n\n` +
        'Yanıt GİB’e gönderilir ve geri alınamaz. Onaylıyor musunuz?', !kabul)) return true;

      const aciklama = await metinSor(
        kabul ? 'Kabul notu (isteğe bağlı):' : 'Red gerekçesi (zorunlu):', '');
      if (aciklama === null) return true;
      if (!kabul && !aciklama.trim()) { mesaj('Red gerekçesi zorunlu.'); return true }

      try {
        const y = await api.gelenBelgeYanit(id, kabul, aciklama);
        mesaj(y.mesaj);
        yenile();
      } catch (h) { mesaj(hataMetni(h)) }
      return true;
    }
  }
  return false;
}
