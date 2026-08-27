import { api } from '../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../bilesenler/mesaj';
import { type EBelgeMesaji, type ListeSatiri } from '../api/sozlesme';
import { belgeGoruntusuAc, dosyaIndir, ebelgeDosyaAdi, ebelgeTurAdi } from './ebelgeIslem';
import { xmlAyristir, xsltUygula, hamXmlGorunumu } from './xsltGoruntu';

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
  const belge = xmlAyristir(ubl);
  if (!belge) return hamXmlGorunumu(ubl);

  // Gomulu XSLT: base64 govde bir stylesheet olmali (fatura ekleri arasinda
  //   PDF/gorsel de gelebilir - hepsini denemek yerine icerige bakariz).
  const gomulu = Array.from(belge.getElementsByTagName('*'))
    .filter(d => d.localName === 'EmbeddedDocumentBinaryObject');
  for (const d of gomulu) {
    let cozulmus: string;
    try {
      cozulmus = new TextDecoder('utf-8').decode(
        Uint8Array.from(atob((d.textContent ?? '').trim()), c => c.charCodeAt(0)));
    } catch {
      continue;                       // bozuk base64 - sonraki adaya gec
    }
    if (!cozulmus.includes('xsl:stylesheet') && !cozulmus.includes('xsl:transform')) continue;

    const goruntu = xsltUygula(belge, cozulmus);
    if (goruntu) return goruntu;
  }
  return hamXmlGorunumu(ubl);
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
  // Kaydet dosya adi: "<tür> <belge no> <gönderici ilk 2 kelime>" (giden ile ayni kural).
  const dosyaAdi = satir
    ? ebelgeDosyaAdi(ebelgeTurAdi(satir), no, String(satir.gondericiUnvan ?? ''))
    : no;

  /** Goruntuyu yeni sekmede acar; `yazdir` ise yazdirma penceresini tetikler
      (PDF, tarayicinin "PDF olarak kaydet" secenegiyle alinir). */
  const goster = async (yazdir: boolean) => {
    const y = await api.gelenBelgeUbl(id);
    // Baslik = dosya adi: yazdirma diyalogundaki PDF adi buradan gelir.
    await belgeGoruntusuAc(goruntuUret(y.ubl), dosyaAdi, yazdir);
    yenile();                                     // "Okundu" isaretlendi
  };

  switch (kod) {
    // e-FATURA KOMBOSU: gelen belgede id BELGE degil e_belge kaydidir; bu
    //   yuzden giden taraftaki ebelgeCiktisi'ne DUSMEZ, buraya gelir.
    case 'ebelge.onizle':
      if (!id) return true;
      await guvenli(() => goster(false));
      return true;

    case 'ebelge.pdf':
      if (!id) return true;
      await guvenli(() => goster(true));
      return true;

    case 'ebelge.html':
      if (!id) return true;
      await guvenli(async () => {
        const y = await api.gelenBelgeUbl(id);
        dosyaIndir(goruntuUret(y.ubl), `${dosyaAdi}.html`, 'text/html;charset=utf-8');
      });
      return true;

    case 'ebelge.xml':
      if (!id) return true;
      await guvenli(async () => {
        const y = await api.gelenBelgeUbl(id);
        dosyaIndir(y.ubl, `${dosyaAdi}.xml`, 'application/xml;charset=utf-8');
      });
      return true;

    case 'ebelge.mesajlar':
      if (!id) return true;
      await guvenli(async () => {
        const y = await api.gelenBelgeMesajlar(id);
        mesajGoster?.({ belgeNo: no, satirlar: y.mesajlar });
      });
      return true;

    case 'gelen.yenile':
      await guvenli(async () => {
        const y = await api.gelenKutuYenile();
        mesaj(y.mesaj);
        yenile();
      });
      return true;

    case 'gelen.goruntule': {
      if (!id) return true;
      await guvenli(() => goster(false));
      return true;
    }

    case 'gelen.xml': {
      if (!id) return true;
      await guvenli(async () => {
        const y = await api.gelenBelgeUbl(id);
        dosyaIndir(y.ubl, `${no}.xml`, 'application/xml;charset=utf-8');
      });
      return true;
    }

    // ALIS FATURASINA AKTAR: kutu satirindan gercek belge uretilir; cari borcu
    //   ve stok girisi ancak bundan sonra dogar.
    case 'gelen.aktar': {
      if (!id) return true;
      await guvenli(async () => {
        const y = await api.gelenBelgeAktar(id);
        mesaj(y.mesaj);
        yenile();
      });
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

      await guvenli(async () => {
        const y = await api.gelenBelgeYanit(id, kabul, aciklama);
        mesaj(y.mesaj);
        yenile();
      });
      return true;
    }
  }
  return false;
}
