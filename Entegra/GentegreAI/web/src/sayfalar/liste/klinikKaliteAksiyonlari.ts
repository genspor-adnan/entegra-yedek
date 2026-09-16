import { api } from '../../api/istemci';
import { guvenli, listeSor, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * KLİNİK KALİTE LİSTE AKSİYONLARI (db/713 motoru).
 *
 * Üç iş: dönemi hesapla · tek göstergeyi önizle · dönemi kesinleştir.
 *
 * DÖNEM SORULUR, VARSAYILMAZ. Kalite birimi çoğu zaman GEÇEN dönemi kapatmak
 * için hesaplatıyor (rehberin analiz periyodu 6 aylık); "içinde bulunduğumuz
 * dönem" varsayılsaydı yanlış döneme yazıp fark ettiğinde satırlar çoktan
 * oluşmuş olurdu. Seçenekler son iki yılın yarıyılları + yıllık.
 *
 * ÖNİZLEME YAZMAZ: "bu gösterge niye böyle çıktı" sorusu taslak satır
 * kirletmeden yanıtlanabilsin diye ayrı uç.
 *
 * KESİNLEŞTİRME TEHLİKELİ ONAY ile sorulur: tek yönlüdür, geri alınamaz -
 * Bakanlığa giden sayının sonradan değişmesi geri bildirim raporlarıyla kurum
 * kaydı arasında açıklanamayan fark üretir.
 */
export interface KlinikKaliteBaglam {
  tazele(): void;
}

/** "2026-1-6" -> {yil, donemNo, periyot}. Kod bilerek düz metin: listeSor kod döndürür. */
function donemCoz(kod: string) {
  const [yil, donemNo, periyot] = kod.split('-').map(Number);
  return { yil, donemNo, periyot };
}

/**
 * Seçilebilir dönemler: bu yıl ve geçen yılın yarıyılları + yıllık.
 * Gelecek dönem TEKLİF EDİLMEZ - henüz dolmamış bir dönemi hesaplamak
 * yarım veriyle "hedef dışı" üretir ve kullanıcıyı yanıltır.
 */
function donemSecenekleri() {
  const bugun = new Date();
  const buYil = bugun.getFullYear();
  const buYarim = bugun.getMonth() < 6 ? 1 : 2;
  const s: { kod: string; ad: string }[] = [];
  for (const yil of [buYil, buYil - 1]) {
    for (const no of [2, 1]) {
      if (yil === buYil && no > buYarim) continue;
      s.push({ kod: `${yil}-${no}-6`, ad: `${yil} / ${no}. yarıyıl` });
    }
    if (yil < buYil) s.push({ kod: `${yil}-1-12`, ad: `${yil} / yıllık` });
  }
  return s;
}

export async function klinikKaliteAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: KlinikKaliteBaglam,
): Promise<boolean> {
  if (!kod.startsWith('klinik-kalite.')) return false;

  const secenekler = donemSecenekleri();

  // ------------------------------------------------------------ hesapla ----
  if (kod === 'klinik-kalite.hesapla') {
    const secim = await listeSor('Hangi dönem hesaplansın?', secenekler,
                                 secenekler[0]?.kod ?? '', 'Dönem');
    if (!secim) return true;
    const d = donemCoz(secim);

    await guvenli(async () => {
      const y = await api.klinikKaliteHesapla(d.yil, d.donemNo, d.periyot);
      // Üç sayı da söylenir: "yazılan" işin yapıldığını, "atlanan" kesinleşmiş
      //   dönemin korunduğunu, "kodsuz" elle girilmesi gerekenleri anlatır.
      //   Yalnız "tamam" deseydik, boş kalan satırların sebebi görünmezdi.
      mesaj(`Dönem hesaplandı: ${y.yazilan} gösterge yazıldı`
          + (y.atlanan ? `, ${y.atlanan} kesinleşmiş satır korundu` : '')
          + (y.kodsuz ? `, ${y.kodsuz} gösterge kod listesi eksik (elle girilmeli)` : '')
          + `. (${y.sureMs} ms)`);
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------------------ önizle ----
  if (kod === 'klinik-kalite.onizle') {
    const gostergeId = Number(satir?.gostergeId ?? satir?.id ?? 0);
    if (!gostergeId) { mesaj('Önce bir gösterge seçin.'); return true }

    const secim = await listeSor('Hangi dönem önizlensin?', secenekler,
                                 secenekler[0]?.kod ?? '', 'Dönem');
    if (!secim) return true;
    const d = donemCoz(secim);

    await guvenli(async () => {
      const y = await api.klinikKaliteOnizle(gostergeId, d.yil, d.donemNo, d.periyot);
      const ad = String(satir?.kod ?? '') + ' ' + String(satir?.ad ?? '');
      if (y.durum === 'kod_yok') { mesaj(`${ad}\n\n${y.aciklama}`); return }
      if (y.durum === 'vaka_yok') { mesaj(`${ad}\n\nDönemde payda vakası yok.`); return }
      const oran = y.payda ? (y.pay / y.payda * 100).toFixed(2) : '0';
      mesaj(`${ad}\n\nPay: ${y.pay}\nPayda: ${y.payda}\nSonuç: %${oran}`
          + '\n\n(Önizleme - kayıt yazılmadı.)');
    });
    return true;
  }

  // ------------------------------------------------------- kesinleştir ----
  if (kod === 'klinik-kalite.kesinlestir') {
    const secim = await listeSor('Hangi dönem kesinleştirilsin?', secenekler,
                                 secenekler[0]?.kod ?? '', 'Dönem');
    if (!secim) return true;
    const d = donemCoz(secim);
    const ad = secenekler.find(x => x.kod === secim)?.ad ?? secim;

    if (!await onay(`"${ad}" dönemi kesinleştirilsin mi?\n\n`
                  + 'Kesinleşen satırlar bir daha HESAPLANMAZ ve bu işlem '
                  + 'geri alınamaz.', true)) return true;

    await guvenli(async () => {
      const y = await api.klinikKaliteKesinlestir(d.yil, d.donemNo, d.periyot);
      mesaj(y.kesinlesen
        ? `${y.kesinlesen} gösterge kesinleştirildi.`
        : 'Kesinleştirilecek taslak satır bulunamadı.');
      b.tazele();
    });
    return true;
  }

  return false;
}
