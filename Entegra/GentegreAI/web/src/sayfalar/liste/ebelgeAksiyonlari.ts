import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * e-BELGE LISTE AKSIYONLARI (163/164/184/188) - hazirla · gonder · seri ·
 * sifirla · iptal.
 *
 * `Liste.tsx` icindeki dev `aksiyon()` fonksiyonundan konu bazli ayrildi.
 * Belgenin ONIZLEME/XML/PDF ciktilari ayri dosyada (`ebelgeIslem.ts`) - bu
 * dosya GONDERIM adimlarini tasir.
 *
 * ORTAK KURAL: gonderilen e-Belge GERI ALINAMAZ; onay metinleri bunu acikca
 * yazar ve tehlike bicimiyle sorar. Duzeltme iade faturasiyla yapilir.
 */
export interface EBelgeBaglam {
  tazele(): void;
}

export async function ebelgeAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: EBelgeBaglam,
): Promise<boolean> {
  switch (kod) {
    case 'ebelge.hazirla': {
      if (!satir) return true;
      const belgeNo = String(satir.belgeNo ?? satir.id);
      if (!await onay(`"${belgeNo}" için e-Belge hazırlansın mı? `
                    + 'Belgeye seri ve e-Belge numarası verilir.')) return true;
      await guvenli(async () => {
        const y = await api.belgeEBelgeHazirla(Number(satir.id));
        mesaj((y.uyarilar ?? []).join(' • ') || 'e-Belge hazırlandı.');
        b.tazele();
      });
      return true;
    }

    // e-BELGE GONDER: GERI ALINAMAZ, bu yuzden onay metni acik yazilir -
    //   GIB'e giden belge iptal edilmez, yalniz iade faturasiyla duzeltilir.
    case 'ebelge.gonder': {
      if (!satir) return true;
      const no = String(satir.belgeNo ?? satir.id);
      await guvenli(async () => {
        // e-ARSIVDE ALICI E-POSTASI SORULUR (184, Delphi ile ayni): alias
        //   alani e-Faturada GIB posta kutusu, e-Arsivde e-posta adresidir.
        //   Bos gonderilirse entegrator belgeyi KAGIT olarak isaretliyor.
        let alias: string | undefined;
        const a = await api.belgeEBelgeAlici(Number(satir.id));
        if (a.belgeTuru === 2) {
          const girilen = await metinSor(
            `"${no}" e-Arşiv olarak gönderilecek.\n\n`
            + 'Belge alıcıya e-postayla iletilir. Boş bırakırsanız kâğıt '
            + 'belge olarak işaretlenir.',
            a.alias || a.onerilenMail, 'Alıcı e-postası');
          if (girilen === null) return;              // vazgecildi
          alias = girilen.trim();
        } else if (!await onay(`"${no}" entegratöre GÖNDERİLECEK.\n\n`
                             + 'Gönderilen belge geri alınamaz; düzeltme ancak iade '
                             + 'faturasıyla yapılır. Onaylıyor musunuz?', true)) {
          return;
        }
        const y = await api.belgeEBelgeGonder(Number(satir.id), alias);
        mesaj((y.uyarilar ?? []).join(' • ') || 'Gönderildi.');
        b.tazele();
      });
      return true;
    }

    // e-Belge menusunun oteki adimlari (164): seri degistir ve sifirla.
    case 'ebelge.seri': {
      if (!satir) return true;
      const seri = await metinSor('Yeni seri (boş bırakırsanız sıradaki seriye geçilir):',
                                  '', 'Seri');
      if (seri === null) return true;                // vazgecildi
      await guvenli(async () => {
        const y = await api.belgeEBelgeSeri(Number(satir.id), seri.trim() || undefined);
        mesaj((y.uyarilar ?? []).join(' • ') || 'Seri değişti.');
        b.tazele();
      });
      return true;
    }

    case 'ebelge.sifirla': {
      if (!satir) return true;
      if (!await onay('e-Belge geri alınacak; belge yeniden hazırlanabilir hale gelir. '
                    + 'Numara boşa düşer. Onaylıyor musunuz?')) return true;
      await guvenli(async () => {
        const y = await api.belgeEBelgeSifirla(Number(satir.id));
        mesaj((y.uyarilar ?? []).join(' • ') || 'e-Belge geri alındı.');
        b.tazele();
      });
      return true;
    }

    // e-BELGE IPTALI (188): e-Arsivde dogrudan iptal, e-Faturada GIB'e iptal
    //   TALEBI. Ikisi de geri alinamaz; gerekce ZORUNLU.
    case 'ebelge.iptal': {
      if (!satir) return true;
      const belgeNo = String(satir.belgeNo ?? satir.id);
      if (!await onay(`"${belgeNo}" için e-Belge iptali başlatılacak.\n\n`
                    + 'e-Arşiv doğrudan iptal edilir; e-Faturada GİB’e iptal talebi '
                    + 'gönderilir ve alıcı onayına kalır. Geri alınamaz. Onaylıyor musunuz?',
                      true)) return true;
      const gerekce = await metinSor('İptal gerekçesi (zorunlu):', '');
      if (gerekce === null) return true;
      if (!gerekce.trim()) { mesaj('İptal gerekçesi zorunlu.'); return true }
      await guvenli(async () => {
        const y = await api.belgeEBelgeIptal(Number(satir.id), gerekce);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    default:
      return false;
  }
}
