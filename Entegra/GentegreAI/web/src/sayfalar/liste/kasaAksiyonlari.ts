import { api } from '../../api/istemci';
import { mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * KASA / BANKA LISTE AKSIYONLARI (147-152).
 *
 * `Liste.tsx` icindeki `aksiyon()` 950 satira ulasmisti; ÜTS ile ayni desende
 * konu bazli ayrildi. Ekran state'ine dokunan isler BAGLAM nesnesiyle geliyor.
 *
 * Donus: aksiyon burada ele alindiysa true.
 */
export interface KasaBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Yeni kasa islemi MODAL olarak acilir (liste arkada kalsin). */
  setKasaTuru(tur: number): void;
  /** Cek/senet: once KIYMET karti acilir, kasa islemi ona baglanir. */
  setCekTuru(tur: number): void;
  /** Mevcut kaydi modalde acar - kart kendi turuyle gelir. */
  setAcikKasaId(id: number): void;
}

/** Cek/senet ile tahsilat-odeme turleri: once kiymet karti acilir. */
const CEK_SENET = [23, 24, 33, 34];

export async function kasaAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: KasaBaglam,
): Promise<boolean> {
  // Alt menuden gelen arac secimi: "kasa.yeni.22" -> tur 22 ile modal.
  if (kod.startsWith('kasa.yeni.')) {
    const t = Number(kod.slice(10));
    // CEK / SENET (23/24/33/34): once KIYMET KARTI acilir (kullanici) - banka,
    //   sube, kesideci, seri no, vade... kasa kartinda sorulamayacak kadar cok
    //   alan var. Kart kaydedilince kasa islemi o kiymete BAGLANARAK olusur.
    if (CEK_SENET.includes(t)) b.setCekTuru(t); else b.setKasaTuru(t);
    return true;
  }

  switch (kod) {
    // Tahsilat/odeme dugmeleri ARAC (nakit/banka/pos/cek/senet) menusu acar;
    //   secilen aracin kodu "kasa.yeni.<tur>" olarak geri gelir ve kart MODAL
    //   olarak acilir (liste arkada kalsin, kullanici listeden kopmasin).
    case 'kasa.tahsilat.yeni': b.setKasaTuru(21); return true;
    case 'kasa.odeme.yeni':    b.setKasaTuru(31); return true;
    case 'kasa.virman.yeni':   b.setKasaTuru(41); return true;
    case 'kasa.doviz.yeni':    b.setKasaTuru(45); return true;
    case 'kasa.plan.yeni':     b.setKasaTuru(61); return true;

    case 'kasa.gerceklestir':
      // Gerceklestirme hesap/tutar secimi ister - plan kartindaki panele goturur.
      if (satir) b.git(`/kasa-islem/${satir.id}`);
      return true;

    case 'kasa.ac':
      // MODAL acilir (kullanici): kart kaydin KENDI turuyle gelir (tahsilat /
      //   odeme / cek / virman...) ve liste arkada kalir - tam sayfaya gidince
      //   kullanici listedeki yerini kaybediyordu.
      if (satir) b.setAcikKasaId(Number(satir.id));
      return true;

    case 'kasa.fis-gor':
      if (satir) b.git(`/kasa-islem/${satir.id}`);
      return true;

    case 'kasa.kesinlestir':
      if (!satir) return true;
      if (!await onay('İşlem kesinleştirilecek: makbuz numarası verilir ve muhasebe fişi yazılır. Onaylıyor musunuz?'))
        return true;
      await api.kasaKesinlestir(Number(satir.id));
      b.tazele();
      return true;

    case 'kasa.iptal': {
      if (!satir) return true;
      // GERCEKLESMIS islem SILINMEZ, iptal edilir (076/354): sebep zorunlu -
      //   ters kayit onun aciklamasiyla yazilir.
      const sebep = await metinSor('İptal sebebi:', '');
      if (!sebep) return true;
      await api.kasaIptal(Number(satir.id), sebep);
      b.tazele();
      return true;
    }

    case 'kasa.sil':
      if (!satir) return true;
      if (!await onay('Taslak/plan kaydı silinecek. Onaylıyor musunuz?')) return true;
      await api.kasaSil(Number(satir.id));
      b.tazele();
      return true;

    case 'genel.yazdir':
      mesaj('Yazdirma henuz baglanmadi.');
      return true;

    default:
      return false;
  }
}
