import { api } from '../../api/istemci';
import { type AksiyonBaglami } from './aksiyonOrtak';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
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
export type LabBaglam = AksiyonBaglami & {
  /** SONUC GIRIS penceresini acar (433) - istemin butun tetkikleri icin. */
  sonucGir?(istemId: number): void;
};

/** Ret nedenleri = numune KALİTE kod uzayı (db/433, 434'te belgelendi). */
const RET_NEDENLERI: Record<string, string> = {
  '2': 'Hemolizli', '3': 'Lipemik', '4': 'İkterik', '5': 'Yetersiz miktar',
  '6': 'Pıhtılı', '7': 'Yanlış tüp', '8': 'Etiketsiz', '9': 'Diğer',
};

/**
 * KABULDE KALITE listesi = 1 Uygun + ret kod uzayi (9 Diger haric;
 * "diger" bir kabul gerekcesi degil). Kabul edilen ama kusurlu tup
 * (hafif lipemik) isaretlenir - sonuc yorumlanirken rapora duser.
 */
const KALITELER: { kod: string; ad: string }[] = [
  { kod: '1', ad: '1 - Uygun' },
  ...Object.entries(RET_NEDENLERI)
    .filter(([k]) => k !== '9')
    .map(([kod, ad]) => ({ kod, ad: `${kod} - ${ad}` })),
];

/** Ret penceresinin combo secenekleri - varsayilan 2 Hemolizli. */
const RET_SECENEKLERI = Object.entries(RET_NEDENLERI)
  .map(([kod, ad]) => ({ kod, ad: `${kod} - ${ad}` }));

export async function labAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: LabBaglam,
): Promise<boolean> {
  if (!kod.startsWith('lab.')) return false;
  // Crud() lab-tetkik.yeni / .duzenle / .sil uretir - onlar Liste'nin kendi
  //   kart akisi.
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  // BARKOD OKUT kayit SECIMI ISTEMEZ: bankonun giris yolu tupun kendisidir.
  //   Okutulan barkod hangi isteme aitse o istem acilir; kabul edilmemisse
  //   ayni yerden kabul edilir - iki ekran arasinda gezinmeye gerek kalmaz.
  if (kod === 'lab.barkod-okut') {
    const b2 = await metinSor('Tüp barkodunu okutun ya da yazın:', '', 'Barkod Okut');
    if (b2 === null || b2.trim() === '') return true;
    await guvenli(async () => {
      const n = await api.labNumuneBarkod(b2.trim()) as Record<string, unknown>;
      const durum = Number(n.durum ?? 0);
      const bilgi = `${String(n.istemNo ?? '')} · ${String(n.hasta ?? '')}`
                  + ` · ${Number(n.tetkik ?? 0)} tetkik`;
      if (durum === 3) { mesaj(`${bilgi}\n\nBu tüp zaten kabul edilmiş.`); return }
      if (durum === 0) { mesaj(`${bilgi}\n\nBu tüp REDDEDİLMİŞ - yeni numune gerekiyor.`); return }
      if (!await onay(`${bilgi}\n\nTüp kabul edilsin mi? (TAT şimdi başlar)`)) return;
      mesaj((await api.labNumuneDurum(Number(n.id ?? 0), 3)).mesaj);
      b.tazele();
    });
    return true;
  }

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }

  // SONUC GIRISI: pencere acilir, yazma ve kural motoru orada.
  if (kod === 'lab.sonuc-gir') { b.sonucGir?.(id); return true }

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

    // ISTEM DUZEYINDE KABUL/RET: hastanin TUM tupleri. Hangi tupe
    //   dokunulacagina sunucu karar verir (calisilmis numune atlanir).
    case 'lab.istem-kabul': {
      // Kod listesi METINDE degil COMBODA (kullanici: "kabul/ret
      //   butonlarinda mesajda girisler combo olsun, 1 default gelsin").
      //   Kabul edilen tupun olagan hali "Uygun" - Enter'la gecilir.
      const k = await listeSor('Numune kalitesi:', KALITELER, '1', 'Kalite');
      if (k === null) return true;
      const kalite = Number(k) || undefined;
      await guvenli(async () => {
        const y = await api.labIstemNumuneDurum(id, 3, { kalite });
        mesaj(`${y.mesaj} Süre (TAT) şimdi başladı.`);
        b.tazele();
      });
      return true;
    }

    case 'lab.istem-ret': {
      const n = await listeSor('Ret nedeni:', RET_SECENEKLERI, '2', 'Ret Nedeni');
      if (n === null) return true;
      const retNeden = Number(n);
      if (!RET_NEDENLERI[String(retNeden)]) {
        mesaj('Geçerli bir ret nedeni seçin.');
        return true;
      }
      const aciklama = await metinSor('Açıklama (isteğe bağlı):', '', 'Numune Reddi');
      if (aciklama === null) return true;
      if (!await onay(`İstemin TÜM tüpleri REDDEDİLECEK `
                    + `(${RET_NEDENLERI[String(retNeden)]}).\n\n`
                    + 'Tetkikler "tekrar numune bekliyor" durumuna geçer.')) return true;
      await guvenli(async () => {
        mesaj((await api.labIstemNumuneDurum(id, 0, { retNeden, aciklama })).mesaj);
        b.tazele();
      });
      return true;
    }

    // SAKLAMA YERI: tupler calisilmayi beklerken nerede duruyor. Sicaklik
    //   istege bagli - dolap adi zaten yeri soyler, sicaklik kaydi ise
    //   soguk zincir gereken numunede kanittir.
    case 'lab.saklama': {
      const yer = await metinSor('Saklama yeri (dolap / raf):', '', 'Saklama Yeri');
      if (yer === null || yer.trim() === '') return true;
      const s = await metinSor('Sıcaklık °C (boş geçilebilir):', '', 'Saklama Yeri');
      if (s === null) return true;
      const sicaklik = s.trim() === '' ? undefined
                     : Number(s.trim().replace(',', '.'));
      if (sicaklik !== undefined && Number.isNaN(sicaklik)) {
        mesaj('Sıcaklık sayı olmalı.');
        return true;
      }
      await guvenli(async () => {
        mesaj((await api.labIstemSaklama(id, yer.trim(), sicaklik)).mesaj);
        b.tazele();
      });
      return true;
    }

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
      // Kod listesi METINDE degil COMBODA (kullanici: "kabul/ret
      //   butonlarinda mesajda girisler combo olsun, 1 default gelsin").
      //   Kabul edilen tupun olagan hali "Uygun" - Enter'la gecilir.
      const k = await listeSor('Numune kalitesi:', KALITELER, '1', 'Kalite');
      if (k === null) return true;
      const kalite = Number(k) || undefined;
      await guvenli(async () => {
        const y = await api.labNumuneDurum(id, 3, { kalite });
        mesaj(`${y.mesaj} Süre (TAT) şimdi başladı.`);
        b.tazele();
      });
      return true;
    }

    case 'lab.numune-ret': {
      const n = await listeSor('Ret nedeni:', RET_SECENEKLERI, '2', 'Ret Nedeni');
      if (n === null) return true;
      const retNeden = Number(n);
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
