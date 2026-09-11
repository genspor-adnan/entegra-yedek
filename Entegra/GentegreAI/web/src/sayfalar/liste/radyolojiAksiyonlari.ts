import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';
import { yerelZamanDamgasi } from './zaman';

/**
 * RADYOLOJI WORKLIST AKSIYONLARI (283 · 304 · 316 · 318 · 320).
 *
 * `Liste.tsx` govdesinden ayrildi. Modal acan isler BAGLAM'daki setter'lara
 * duser; durum degistiren isler dogrudan kart ucunu kullanir.
 *
 * Donus: aksiyon burada ele alindiysa true.
 */
export interface RadyolojiBaglam {
  tazele(): void;
  git(yol: string): void;
  /** YENI ISTEM (304): once hasta aranir, sonra tetkik modali gelir. */
  setIstemHastaArama(acik: boolean): void;
  setSarfModali(m: { istemId: number; accessionNo: string; tetkikAdi: string }): void;
  setRandevuModali(m: { istemId: number; accessionNo: string; tetkikAdi: string;
                        modalite: number; sureDk: number }): void;
  setTeslimModali(m: { istemId: number; accessionNo: string; cdIstendi?: boolean }): void;
  setKritikModali(m: { istemId: number; accessionNo: string; hasta: string;
                       tetkik: string; bulgu: string; bildirilenAd: string }): void;
  setKonsultasyonModali(m: { istemId: number; konsultasyonId: number; accessionNo: string;
                             hasta: string; tetkik: string; soru: string; gorus: string }): void;
}

export async function radyolojiAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: RadyolojiBaglam,
): Promise<boolean> {
  // SARF DUSUMU (320): cekim tamamlaninca protokoldeki malzeme onerilir.
  //   Ayri aksiyon olarak da cagrilabilir - cekim sirasinda atlanmis ya da
  //   sonradan duzeltilmesi gereken dusum icin.
  if (kod === 'radyoloji.sarf') {
    if (!satir) return true;
    b.setSarfModali({
      istemId: Number(satir.istemId ?? satir.id),
      accessionNo: String(satir.accessionNo ?? ''),
      tetkikAdi: String(satir.tetkikAdi ?? satir.tetkik ?? ''),
    });
    return true;
  }

  // RANDEVU VER (316): istem cihaza baglanir - kayit public.randevu'ya gider,
  //   kaynagi cihazdir. Sure tetkikin protokolunden gelir.
  if (kod === 'radyoloji.randevu') {
    if (!satir) return true;
    b.setRandevuModali({
      istemId: Number(satir.id),
      accessionNo: String(satir.accessionNo ?? ''),
      tetkikAdi: String(satir.tetkikAdi ?? ''),
      modalite: Number(satir.modalite ?? 0),
      sureDk: Number(satir.protokolSure ?? 0),
    });
    return true;
  }

  // RADYOLOJI (283): worklist durum akisi. "Cekildi" teknisyenin islemi -
  //   cekim zamani da yazilir, cunku bekleme suresi (kalite gostergesi)
  //   oradan hesaplanir. Iptal onay ister: cekilmis istem iptal edilirse
  //   goruntu ortada kalir.
  if (kod === 'radyoloji.cekildi' || kod === 'radyoloji.iptal') {
    if (!satir) return true;
    const iptalMi = kod === 'radyoloji.iptal';
    if (iptalMi && !(await onay(
          `${String(satir.accessionNo ?? '')} istemi iptal edilsin mi? `
          + 'Çekim yapıldıysa görüntü ve rapor kaydı yerinde kalır.'))) return true;
    await guvenli(async () => {
      const mevcut = await api.kartOku('radyoloji-istem', Number(satir.id));
      await api.kartGuncelle('radyoloji-istem', Number(satir.id), {
        surum: mevcut.kart.surum,
        kart: iptalMi
          ? { durum: 0 }
          // ÇEKIM ZAMANI YEREL saat: toISOString UTC verir, TR'de kayit
          //   3 saat GERIYE dusuyordu - bekleme suresi (istem->cekim)
          //   kalite gostergesi buradan hesaplaniyor, negatif bile cikabilir.
          : { durum: 2, cekimTarihi: yerelZamanDamgasi() },
      });
      b.tazele();
      mesaj(iptalMi ? 'İstem iptal edildi.' : 'İstem "Çekildi" olarak işaretlendi.');
      // SARF DUSUMU (320): cekim tamamlandi - protokolde malzeme tanimliysa
      //   onay penceresi acilir. Iptalde acilmaz; sarf ayari kapaliysa ya da
      //   liste bossa modal kendi kendini "tanimli degil" diye anlatir.
      if (!iptalMi) {
        try {
          const sarf = await api.radyolojiSarf(Number(satir.id));
          if (sarf.aktif && (sarf.satirlar ?? []).length > 0)
            b.setSarfModali({
              istemId: Number(satir.id),
              accessionNo: String(satir.accessionNo ?? ''),
              tetkikAdi: String(satir.tetkikAdi ?? satir.tetkik ?? ''),
            });
        } catch { /* sarf okunamazsa cekim isaretlemesi yine gecerli */ }
      }
    });
    return true;
  }

  // YENI ISTEM (304): generic kart TEK tetkik acardi; istem ekrani coklu
  //   tetkik secer, klinik bilgiyi hepsine gecer ve basvuruya ucret
  //   satirlarini ekler. Listeden acildiginda DIS istem varsayilir - hastanin
  //   kendi hekimi yoksa disaridan gelmistir; ic istem basvuru kartindan acilir.
  if (kod === 'radyoloji.yeni') {
    b.setIstemHastaArama(true);
    return true;
  }

  // KRITIK BULGU TAKIBI (318): bildirim ve kapatma AYRI islemdir - kapatma
  //   "karsi taraf teyit etti" demektir, bildirim yoksa kapatilacak bir sey de
  //   yoktur (sunucu da reddeder).
  if (kod === 'radyoloji.kritik-bildir') {
    if (!satir) return true;
    b.setKritikModali({
      istemId: Number(satir.istemId ?? satir.id),
      accessionNo: String(satir.accessionNo ?? ''),
      hasta: String(satir.hasta ?? ''),
      tetkik: String(satir.tetkik ?? ''),
      bulgu: String(satir.bulgu ?? ''),
      bildirilenAd: String(satir.bildirilen ?? ''),
    });
    return true;
  }

  if (kod === 'radyoloji.kritik-kapat') {
    if (!satir) return true;
    if (!await onay('Kritik bulgu takibi kapatılsın mı? Kapatma, bildirimin '
                    + 'yapıldığı ve karşı tarafın teyit ettiği anlamına gelir.'))
      return true;
    await guvenli(async () => {
      await api.radyolojiKritikKapat(Number(satir.istemId ?? satir.id));
      mesaj('Kritik bulgu takibi kapatıldı.');
      b.tazele();
    });
    return true;
  }

  // KONSULTASYON CEVABI (318): cevabi cogunlukla BASKA biri yazar - istek
  //   rapor ekranindan, cevap bu listeden gelir.
  if (kod === 'radyoloji.konsultasyon-cevap') {
    if (!satir) return true;
    b.setKonsultasyonModali({
      istemId: Number(satir.istemId),
      konsultasyonId: Number(satir.id),
      accessionNo: String(satir.accessionNo ?? ''),
      hasta: String(satir.hasta ?? ''),
      tetkik: String(satir.tetkik ?? ''),
      soru: String(satir.gerekce ?? ''),
      gorus: String(satir.gorus ?? ''),
    });
    return true;
  }

  // Takip listelerinde satirin kimligi ISTEM'dir: istemi ac.
  if (kod === 'radyoloji.istem-ac') {
    if (!satir) return true;
    b.git(`/radyoloji/${Number(satir.istemId ?? satir.id)}`);
    return true;
  }

  if (kod === 'radyoloji.teslim') {
    if (!satir) return true;
    b.setTeslimModali({ istemId: Number(satir.istemId ?? satir.id),
                        accessionNo: String(satir.accessionNo ?? ''),
                        cdIstendi: Number(satir.cdIstendi) === 1 });
    return true;
  }

  // Rapor yazma AYRI EKRAN (283): bolumler sablondan uretilir, onay iki
  //   asamalidir - generic karta sigmaz.
  if (kod === 'radyoloji.rapor') {
    if (!satir) return true;
    b.git(`/radyoloji/rapor/${Number(satir.id)}`);
    return true;
  }

  return false;
}
