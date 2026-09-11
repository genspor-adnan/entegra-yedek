import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * KURUM ICMALI (289): kurumun donem sonu payi TEK faturaya doner.
 *
 * `Liste.tsx` govdesinden ayrildi (belge/kasa/ÜTS ile ayni desen).
 * Donus: aksiyon burada ele alindiysa true.
 */
export interface IcmalBaglam {
  tazele(): void;
  /** Faturalanan icmalin belgesi MODAL acilir - listenin rotasi degismez. */
  setAcikBelgeId(id: number): void;
}

export async function icmalAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: IcmalBaglam,
): Promise<boolean> {
  if (kod === 'icmal.yeni') {
    await guvenli(async () => {
      // Soru METINDE, kutu BOS: ikinci parametre varsayilan DEGERDIR - soruyu
      //   oraya yazmak kutuyu hazir doldurup aramayi bozuyordu.
      const kurumAd = await metinSor(
        'İcmal hangi kuruma kesilecek? (ör. SGK)', '', 'Kurum kodu ya da adı');
      if (!kurumAd) return;
      // Kurum kaynaginda ad kolonu 'unvan' ('kurumAdi' icmal kaynaginin
      //   kolonu) - yanlis alan sunucuda "Bilinmeyen alan" hatasi veriyordu.
      // KOD YA DA AD: soru ikisini de kabul ediyor ("SGK" ya da "Sosyal
      //   Güvenlik Kurumu") - yalniz unvana bakinca kodla arayan kullanici
      //   "Kurum bulunamadı" aliyordu.
      const k = await api.liste('kurum', {
        sayfa: 1, boyut: 5,
        filtre: { op: 'or', kosullar: [
          { alan: 'unvan', op: 'icerir', deger: kurumAd },
          { alan: 'kod',   op: 'icerir', deger: kurumAd },
        ] },
      });
      if (k.satirlar.length === 0) { mesaj('Kurum bulunamadı.'); return }
      const kurumId = Number(k.satirlar[0].id);
      const kurumUnvan = String(k.satirlar[0].unvan ?? kurumAd);

      // Donem = icinde bulunulan AY. toISOString UTC'ye cevirdigi icin yerel
      //   gece yarisi bir onceki gune kayiyordu (1 Agustos -> "07-31"): ayin
      //   ilk gunu onceki aya dusup satirlari kacirirdi.
      const bugun = new Date();
      const gun = (t: Date) => `${t.getFullYear()}-`
        + `${String(t.getMonth() + 1).padStart(2, '0')}-`
        + `${String(t.getDate()).padStart(2, '0')}`;
      const bas = gun(new Date(bugun.getFullYear(), bugun.getMonth(), 1));
      const bit = gun(new Date(bugun.getFullYear(), bugun.getMonth() + 1, 0));

      // ONIZLEME: kullanici neyi faturaladigini gormeden icmal acmasin.
      const on = await api.icmalOnizleme(kurumId, bas, bit);
      if (on.satirlar.length === 0) {
        mesaj(`${kurumUnvan} için bu dönemde açık kurum payı yok.`);
        return;
      }
      if (!(await onay(
            `${kurumUnvan} · ${bas} – ${bit}: `
            + `${on.satirlar.length} satır, toplam ${on.toplam.toFixed(2)}. `
            + 'İcmal oluşturulsun mu?'))) return;

      const y = await api.icmalOlustur({ kurumId, donemBas: bas, donemBit: bit });
      b.tazele();
      mesaj(`İcmal oluşturuldu: ${y.satir} satır. "Faturala" ile tek fatura kesilir.`);
    });
    return true;
  }

  if (kod === 'icmal.faturala') {
    if (!satir) return true;
    if (Number(satir.durum) !== 1) { mesaj('Yalnız hazırlanan icmal faturalanabilir.'); return true }
    if (!(await onay(`${satir.kurumAdi} icmali faturalansın mı? `
          + `Toplam ${Number(satir.toplam ?? 0).toFixed(2)} tutarında TEK fatura kesilir `
          + 've satırların kurum payı kapanır.'))) return true;
    await guvenli(async () => {
      const y = await api.icmalFaturala(Number(satir.id));
      b.tazele();
      mesaj(`Fatura kesildi (${y.satir} kalem).`);
      b.setAcikBelgeId(y.belgeId);
    });
    return true;
  }

  if (kod === 'icmal.belge') {
    if (!satir?.belgeId) { mesaj('Bu icmal henüz faturalanmamış.'); return true }
    b.setAcikBelgeId(Number(satir.belgeId));
    return true;
  }

  return false;
}
