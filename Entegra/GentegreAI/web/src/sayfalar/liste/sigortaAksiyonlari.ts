import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * SIGORTA AKSIYONLARI (430) — provizyon takibi ve kurum hesabı testi.
 *
 * <b>Provizyon burada ALINMAZ</b>: başvuru kartından alınır (kalemler orada).
 * Bu ekran takip ve düzeltme içindir - durum tazeleme, doküman gönderimi,
 * iptal.
 *
 * <b>İptal nedeni sabit listeden seçilir</b>: şirket serbest metin kabul
 * etmiyor, kanonik kod `sigorta_kod_esleme` üzerinden çevriliyor. Elle
 * yazdırmak, sunucuda "eşleme yok" ile geri dönerdi.
 */
export interface SigortaBaglam {
  tazele(): void;
  git(yol: string): void;
}

/** db/430 iptal_nedeni kanonik kodları. */
const IPTAL_NEDENLERI: { kod: string; ad: string }[] = [
  { kod: '1', ad: 'Mükerrer provizyon' },
  { kod: '2', ad: 'İstenilen provizyon hatalı' },
  { kod: '3', ad: 'Geri ödeme kurumu iptal istedi' },
  { kod: '4', ad: 'Sigortalı vazgeçti' },
  { kod: '5', ad: 'Numune verilmediği için tetkikler iptal' },
  { kod: '9', ad: 'Diğer' },
];

/** db/430 dokuman_tipi eşlemesindeki sağlayıcı kodları (itemTypeName). */
const DOKUMAN_TIPLERI: { kod: string; ad: string }[] = [
  { kod: 'EpikrizNotu', ad: 'Epikriz notu' },
  { kod: 'Fatura', ad: 'Fatura' },
  { kod: 'TetkikSonucu', ad: 'Tetkik sonucu' },
  { kod: 'Recete', ad: 'Reçete' },
  { kod: 'PolklinikKaydi', ad: 'Poliklinik kaydı' },
  { kod: 'DigerTazmEvr', ad: 'Diğer tazminat evrakı' },
];

export async function sigortaAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: SigortaBaglam,
): Promise<boolean> {
  if (!kod.startsWith('sigorta.')) return false;
  // Crud() sigorta-hesap.yeni/.duzenle/.sil uretir - onlar Liste'nin kendi
  //   kart akisi.
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }

  switch (kod) {
    case 'sigorta.tazele':
      await guvenli(async () => {
        mesaj((await api.sigortaTazele(id)).mesaj);
        b.tazele();
      });
      return true;

    case 'sigorta.basvuru': {
      const belgeId = Number(satir?.belgeId ?? 0);
      if (!belgeId) { mesaj('Provizyonun başvurusu okunamadı.'); return true }
      b.git(`/basvuru/${belgeId}`);
      return true;
    }

    case 'sigorta.dokuman': {
      const tip = await secimSor('Gönderilecek doküman türü:', DOKUMAN_TIPLERI);
      if (!tip) return true;
      const dokuman = await metinSor(
        'Gönderilecek doküman kaydının numarası (Doküman listesindeki Id):',
        '', 'Doküman Id');
      const dokumanId = Number((dokuman ?? '').trim());
      if (!dokumanId) { mesaj('Doküman seçilmedi.'); return true }
      await guvenli(async () => {
        mesaj((await api.sigortaDokumanGonder(id, tip, dokumanId)).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'sigorta.iptal': {
      const neden = await secimSor('İptal nedeni:', IPTAL_NEDENLERI);
      if (!neden) return true;
      const aciklama = await metinSor('Açıklama (isteğe bağlı):', '', 'Açıklama');
      if (aciklama === null) return true;
      // PAY GERİ ALINIR: iptal edilince kurum payı hastaya döner - kullanıcı
      //   bunu onaylamalı, vezne tutarı değişiyor.
      if (!await onay('Provizyon iptal edilsin mi?\n\n'
                    + 'Kurum payı geri alınır, tutarın tamamı hastaya yazılır. '
                    + 'Paketlenmiş provizyon şirket tarafından iptal edilemez.',
                      true)) return true;
      await guvenli(async () => {
        mesaj((await api.sigortaIptal(id, Number(neden), aciklama)).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'sigorta.hesap-test':
      await guvenli(async () => {
        const y = await api.sigortaHesapTest(id);
        mesaj(`${y.saglayici} · ${y.test ? 'TEST' : 'CANLI'} ortam\n${y.mesaj}`
            + (y.notlar?.length ? `\n\n${y.notlar.join('\n')}` : ''));
      });
      return true;

    default:
      return false;
  }
}
