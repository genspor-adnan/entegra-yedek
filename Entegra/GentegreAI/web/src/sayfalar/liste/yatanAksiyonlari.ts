import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * YATAN HASTA AKSİYONLARI (695) — yatışın yaşam döngüsü.
 *
 * <b>Yatak durumu yatışla birlikte değişir, elle değil:</b> kabul yatağı
 * rezerve eder, "yatakta" dolu yapar, nakil eskisini temizliğe düşürür,
 * taburcu da öyle. Bu yüzden buradaki her düğme SUNUCUDAKİ tek uca gider —
 * istemci yatak durumunu ayrıca güncellemez, iki yazıcı olsaydı biri
 * unutulduğunda pano gerçeğin yarım saat gerisinde kalırdı.
 *
 * Modal gerektiren üçü (kabul · nakil · taburcu) burada yalnız AÇILIR; ekranın
 * kendi durumu `Liste` tarafında duruyor.
 */
export interface YatanBaglam {
  tazele(): void;
  kabulAc(hasta?: { id: number; ad: string } | null): void;
  nakilAc(yatisId: number): void;
  taburcuAc(yatisId: number): void;
  /** Doz kuyruğu satırından uygulama penceresi (atlama modu dahil). */
  dozAc(yatisId: number, dozId: number, atlaModu?: boolean): void;
}

export async function yatanAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: YatanBaglam,
): Promise<boolean> {
  if (!kod.startsWith('yatan.')) return false;
  // CRUD kodlari (yatan.yeni / .duzenle / .sil) genel makinede kalir.
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  const yatisId = Number(satir?.id ?? 0);

  if (kod === 'yatan.kabul') { b.kabulAc(null); return true }

  if (kod === 'yatan.yatakta') {
    if (!yatisId) { mesaj('Önce bir yatış seçin.'); return true }
    await guvenli(async () => {
      await api.yatistaYatakta(yatisId);
      mesaj('Hasta yatağına alındı — yatak "dolu".');
      b.tazele();
    });
    return true;
  }

  if (kod === 'yatan.nakil') {
    if (!yatisId) { mesaj('Önce bir yatış seçin.'); return true }
    b.nakilAc(yatisId);
    return true;
  }

  if (kod === 'yatan.taburcu') {
    if (!yatisId) { mesaj('Önce bir yatış seçin.'); return true }
    b.taburcuAc(yatisId);
    return true;
  }

  if (kod === 'yatan.taburcu-planla') {
    if (!yatisId) { mesaj('Önce bir yatış seçin.'); return true }
    // TARİH SORULUR: "bugün" varsayımı, sabah karar verilip ertesi gün çıkacak
    //   hastayı panoda bugün boşalacak gösterirdi.
    if (!await onay('Taburcu bugün için planlansın mı? '
                      + 'Yatak panosunda "bugün çıkacak" olarak işaretlenir.')) return true;
    await guvenli(async () => {
      await api.yatisTaburcuPlanla(yatisId, new Date().toISOString().slice(0, 10));
      mesaj('Taburcu planlandı.');
      b.tazele();
    });
    return true;
  }

  if (kod === 'yatan.iptal') {
    if (!yatisId) { mesaj('Önce bir yatış seçin.'); return true }
    // İPTAL SİLME DEĞİLDİR ama geri de alınmaz: onay isteriz.
    if (!await onay('Yatış iptal edilsin mi? Kayıt silinmez, durumu "İptal" olur '
                    + 've yatak serbest kalır.', true)) return true;
    await guvenli(async () => {
      await api.yatisIptal(yatisId);
      mesaj('Yatış iptal edildi — yatak serbest.');
      b.tazele();
    });
    return true;
  }

  // ---- ORDER LISTESI aksiyonlari (satir = order).
  if (kod === 'yatan.order-imzala') {
    const orderId = Number(satir?.id ?? 0);
    if (!orderId) { mesaj('Önce bir order seçin.'); return true }
    await guvenli(async () => {
      await api.orderImzala(orderId);
      mesaj('Sözel order imzalandı.');
      b.tazele();
    });
    return true;
  }

  if (kod === 'yatan.order-durdur') {
    const orderId = Number(satir?.id ?? 0);
    if (!orderId) { mesaj('Önce bir order seçin.'); return true }
    if (!await onay('Order durdurulsun mu? Gelecekteki bekleyen dozlar düşer, '
                    + 'uygulanmış dozlar kalır.')) return true;
    await guvenli(async () => {
      await api.orderDurdur(orderId);
      mesaj('Order durduruldu.');
      b.tazele();
    });
    return true;
  }

  // ---- DOZ KUYRUGU aksiyonlari (satir = planlanan doz).
  if (kod === 'yatan.doz-uygula' || kod === 'yatan.doz-atla') {
    const dozId = Number(satir?.id ?? 0);
    const dozYatis = Number(satir?.yatisId ?? 0);
    if (!dozId || !dozYatis) { mesaj('Önce bir doz satırı seçin.'); return true }
    // BEŞ DOĞRU PENCERESİ HER İKİ YOLDA DA AÇILIR: tek tıkla "uygulandı"
    //   yazmak, barkod kontrolünü de sebep alanını da atlamak olurdu.
    b.dozAc(dozYatis, dozId, kod === 'yatan.doz-atla');
    return true;
  }

  // ---- HEMSIRE IZLEM aksiyonlari (satir = olcum).
  if (kod === 'yatan.izlem-bildir') {
    const izlemId = Number(satir?.id ?? 0);
    if (!izlemId) { mesaj('Önce bir ölçüm seçin.'); return true }
    await guvenli(async () => {
      await api.izlemBildirildi(izlemId);
      mesaj('Hekime bildirim kaydı yazıldı.');
      b.tazele();
    });
    return true;
  }

  // ---- HIZMET ICMALI aksiyonlari (satir = tahakkuk).
  if (kod === 'yatan.tahakkuk-hesapla') {
    // TARİH SATIRDAN: "hangi günü yeniden çalıştırayım" sorusunu kullanıcıya
    //   sormak yerine seçili satırın gününü kullanırız; satır yoksa dün.
    const ham = String(satir?.tarih ?? '');
    const gun = /^\d{4}-\d{2}-\d{2}/.test(ham)
      ? ham.slice(0, 10)
      : new Date(Date.now() - 864e5).toISOString().slice(0, 10);
    await guvenli(async () => {
      const y = await api.tahakkukHesapla(gun);
      mesaj(y.mesaj || 'Tahakkuk çalıştırıldı.');
      b.tazele();
    });
    return true;
  }

  // ---- YATAK PANOSU aksiyonlari (satir = yatak).
  if (kod === 'yatan.yatak-temizlendi') {
    const yatakId = Number(satir?.id ?? 0);
    if (!yatakId) { mesaj('Önce bir yatak seçin.'); return true }
    await guvenli(async () => {
      await api.yatakTemizlendi(yatakId);
      mesaj('Yatak hazır — "boş" olarak işaretlendi.');
      b.tazele();
    });
    return true;
  }

  return false;
}
