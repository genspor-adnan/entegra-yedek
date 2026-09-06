import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * LABORATUVAR AKSİYONLARI (433/434) — numune kabul/ret, sonuç onayı,
 * düzeltme, panik bildirimi, cihaz mesajını sonuca aktarma.
 *
 * <b>Ret nedeni sorulmadan gönderilmez.</b> Sunucu da zorunlu tutuyor, ama
 * hemoliz mi pıhtı mı olduğu sorulmadan reddedilen tüp, hasta ikinci kez
 * kan verdiğinde aynı hatayla geri gelir.
 *
 * <b>Onaylı sonuç güncellenmez.</b> "Düzelt" eski satırı iptal edip yenisini
 * açar; neden zorunludur çünkü rapor "düzeltilmiş" damgası taşıyacak.
 */
export interface LabBaglam {
  tazele(): void;
  git(yol: string): void;
}

/** Ret nedenleri = numune KALİTE kod uzayı (db/433, 434'te belgelendi). */
const RET_NEDENLERI: Record<string, string> = {
  '2': 'Hemolizli', '3': 'Lipemik', '4': 'İkterik', '5': 'Yetersiz miktar',
  '6': 'Pıhtılı', '7': 'Yanlış tüp', '8': 'Etiketsiz', '9': 'Diğer',
};

export async function labAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: LabBaglam,
): Promise<boolean> {
  if (!kod.startsWith('lab.')) return false;
  // Crud() lab-tetkik.yeni / .duzenle / .sil uretir - onlar Liste'nin kendi
  //   kart akisi.
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }

  switch (kod) {
    // ------------------------------------------------------------ istem ---
    case 'lab.numune-plani':
      await guvenli(async () => {
        const y = await api.labNumunePlani(id);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;

    // ETIKET: istemin TUM tupleri tek sayfada - kan alma bankosu tupleri
    //   birlikte hazirlar, tek tek basmak siraya girer.
    case 'lab.etiket':
      b.git(`/lab/etiket?istem=${id}`);
      return true;

    // RAPOR: hastaya verilen belge ayri sayfada acilir (yazdirma
    //   tarayicinin kendi diyalogu; ayri bir PDF ureticisi yok).
    case 'lab.rapor':
      b.git(`/lab/rapor/${id}`);
      return true;

    // ----------------------------------------------------------- numune ---
    case 'lab.numune-alindi':
      await guvenli(async () => {
        mesaj((await api.labNumuneDurum(id, 2)).mesaj);
        b.tazele();
      });
      return true;

    case 'lab.numune-kabul': {
      // Kalite sorulur ama ZORUNLU degil: uygun tup icin ek soru, kabul
      //   akisini yavaslatirdi. Bos gecilirse "Uygun" kalir.
      const k = await metinSor(
        'Numune kalitesi (boş = Uygun):\n'
        + '1 Uygun · 2 Hemolizli · 3 Lipemik · 4 İkterik · 5 Yetersiz · '
        + '6 Pıhtılı · 7 Yanlış tüp · 8 Etiketsiz',
        '', 'Numune Kabul');
      if (k === null) return true;
      const kalite = Number(k.trim()) || undefined;
      await guvenli(async () => {
        const y = await api.labNumuneDurum(id, 3, { kalite });
        mesaj(`${y.mesaj} Süre (TAT) şimdi başladı.`);
        b.tazele();
      });
      return true;
    }

    case 'lab.numune-ret': {
      const n = await metinSor(
        'Ret nedeni:\n'
        + Object.entries(RET_NEDENLERI).map(([k, v]) => `${k} ${v}`).join(' · '),
        '2', 'Numune Reddi');
      if (n === null) return true;
      const retNeden = Number(n.trim());
      if (!RET_NEDENLERI[String(retNeden)]) {
        mesaj('Geçerli bir ret nedeni seçin.');
        return true;
      }
      const aciklama = await metinSor('Açıklama (isteğe bağlı):', '', 'Numune Reddi');
      if (aciklama === null) return true;
      if (!await onay(`Numune REDDEDİLECEK (${RET_NEDENLERI[String(retNeden)]}).\n\n`
                    + 'Tetkikler "tekrar numune bekliyor" durumuna geçer.')) return true;
      await guvenli(async () => {
        mesaj((await api.labNumuneDurum(id, 0, { retNeden, aciklama })).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.barkod-yazdir': {
      // ETIKET AYRI SAYFADA: tup uzerine yapisan fiziksel belge, ekran
      //   cercevesiyle birlikte basilmamali (@media print).
      b.git(`/lab/etiket?numune=${id}`);
      return true;
    }

    // ------------------------------------------------------------ sonuç ---
    case 'lab.teknik-onay':
      await guvenli(async () => {
        mesaj((await api.labSonucOnayla(id, 1)).mesaj);
        b.tazele();
      });
      return true;

    case 'lab.onayla': {
      const panik = Number(satir?.panik ?? 0) === 1;
      if (panik && !await onay(
        'Bu sonuç PANİK DEĞER.\n\n'
        + 'Onaylamadan önce hekime bildirim yapıldığından emin olun.\n'
        + 'Onaylansın mı?')) return true;
      await guvenli(async () => {
        mesaj((await api.labSonucOnayla(id, 2)).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.duzelt': {
      const deger = await metinSor('Doğru sonuç değeri:', String(satir?.deger ?? ''),
                                   'Sonuç Düzeltme');
      if (deger === null || deger.trim() === '') return true;
      const neden = await metinSor('Düzeltme nedeni (zorunlu):', '', 'Sonuç Düzeltme');
      if (neden === null || neden.trim() === '') {
        mesaj('Düzeltme nedeni zorunlu.');
        return true;
      }
      await guvenli(async () => {
        const y = await api.labSonucDuzelt(id, deger.trim(), neden.trim());
        mesaj(`${y.mesaj} Yeni değerlendirme: ${y.bayrak}`);
        b.tazele();
      });
      return true;
    }

    case 'lab.panik-bildir': {
      const kime = await metinSor('Bildirim yapılan kişi (ad soyad):', '',
                                  'Panik Değer Bildirimi');
      if (kime === null || kime.trim() === '') return true;
      const aciklama = await metinSor('Açıklama (okundu-tekrar edildi vb.):', '',
                                      'Panik Değer Bildirimi');
      if (aciklama === null) return true;
      await guvenli(async () => {
        const y = await api.labPanikBildir(id, kime.trim(), 1, aciklama);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    // ------------------------------------------------------------ cihaz ---
    case 'lab.mesaj-sonuca-aktar':
      await guvenli(async () => {
        const y = await api.labCihazMesajIsle(id);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
  }

  return false;
}
