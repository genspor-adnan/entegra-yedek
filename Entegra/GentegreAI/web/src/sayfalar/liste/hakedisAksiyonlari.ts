import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * PRIM / HAKEDIS AKSIYONLARI (324 · 330).
 *
 * Hakedis satiri TAHSILATTAN dogar, elle eklenmez: buradaki aksiyonlar satirin
 * kaynagina gitmek, rollerini gormek ve donemi kapatmak/onaylamak icindir.
 *
 * Donus: aksiyon burada ele alindiysa true.
 */
export interface HakedisBaglam {
  tazele(): void;
  git(yol: string): void;
  setDonemModali(m: { tarafId?: number; kisi?: string }): void;
  setRolModali(m: { satirId: number; ad: string }): void;
  /** Satirin belgesi MODAL acilir - hakedis satirinin ayri rotasi yok. */
  setAcikBelgeId(id: number): void;
}

export async function hakedisAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  secililer: ListeSatiri[] | undefined,
  b: HakedisBaglam,
): Promise<boolean> {
  if (kod === 'hakedis.donem-kapat') {
    b.setDonemModali(satir
      ? { tarafId: Number(satir.tarafId) || undefined,
          kisi: String(satir.kisi ?? '') }
      : {});
    return true;
  }

  // ONAY (330): satiri kilitler. Toplu secim varsa hepsi islenir.
  if (kod === 'hakedis.onayla' || kod === 'hakedis.onay-kaldir') {
    const geriAl = kod === 'hakedis.onay-kaldir';
    const idler = (secililer && secililer.length > 0 ? secililer
                   : satir ? [satir] : []).map(x => Number(x.id));
    if (idler.length === 0) return true;
    if (!await onay(geriAl
      ? `${idler.length} prim satırının onayı kaldırılacak. Onaylıyor musunuz?`
      : `${idler.length} prim satırı ONAYLANACAK. Onaylanan satır kilitlenir: `
        + 'rol ya da belge türü sonradan değişse bile prim yeniden hesaplanmaz.'))
      return true;
    await guvenli(async () => {
      const y = await api.primOnayla({ satirlar: idler, geriAl });
      mesaj(geriAl
        ? `${y.satirSayisi} satırın onayı kaldırıldı.`
        : `${y.satirSayisi} satır onaylandı (kilitlendi).`);
      b.tazele();
    });
    return true;
  }

  if (kod === 'hakedis.roller') {
    if (!satir) return true;
    const sid = Number(satir.belgeSatirId ?? 0);
    if (!sid) { mesaj('Satırın kalem bağı yok.'); return true }
    b.setRolModali({ satirId: sid, ad: String(satir.kalem ?? '') });
    return true;
  }

  // Belgenin AYRI ROTASI YOK: kart modal olarak listenin ustunde acilir
  //   (donusum zincirindeki "kaynak/hedef belgeyi ac" ile ayni desen).
  if (kod === 'hakedis.kalem') {
    if (!satir) return true;
    const bid = Number(satir.belgeId ?? 0);
    if (!bid) { mesaj('Satırın belge bağı yok.'); return true }
    b.setAcikBelgeId(bid);
    return true;
  }

  // Baslikta "Satirlari Gor": ayni donemin satirlarina hakedis filtresiyle gecilir.
  if (kod === 'hakedis.satirlar') {
    if (!satir) return true;
    b.git(`/hakedis-satir?hakedisId=${Number(satir.id)}`);
    return true;
  }

  return false;
}
