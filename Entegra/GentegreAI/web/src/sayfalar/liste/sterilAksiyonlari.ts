import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';

/**
 * STERİLİZASYON (868) liste aksiyonları: döngü kartı / yeni döngü / paketleri izle;
 * paket izleme / kullanım okutma; birim hazırlama adımları (kirli, yıkama, sayım,
 * paketle, yağlama, arıza); geri çağırma panosu / kapat; hasta kartı.
 * Düz CRUD'lar (yeni / düzenle / sil) Liste'nin genel akışında kalır.
 */
export async function sterilAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                     b: { tazele(): void; git(yol: string): void; geri: string }): Promise<boolean> {
  if (!kod.startsWith('steril.')) return false;
  const geri = `?geri=${encodeURIComponent(b.geri)}`;
  const id = Number(satir?.id ?? 0);

  if (kod === 'steril.dongu-yeni') { b.git('/steril-pano?yeni=1'); return true }
  if (!id) { mesaj('Önce bir satır seçin.'); return true }

  if (kod === 'steril.dongu-kart') { b.git(`/steril-dongu/${Number(satir?.donguId ?? 0) || id}${geri}`); return true }
  if (kod === 'steril.izle-dongu') { b.git(`/steril-paket?donguId=${id}`); return true }
  if (kod === 'steril.izle') {
    const barkod = String(satir?.paketBarkod ?? satir?.barkod ?? '');
    if (!barkod) { mesaj('Satırda barkod yok.'); return true }
    b.git(`/steril-izleme?barkod=${encodeURIComponent(barkod)}`); return true;
  }
  if (kod === 'steril.hasta-ac') {
    const t = Number(satir?.tarafId ?? 0);
    if (!t) { mesaj('Kullanım bir hastaya bağlı değil.'); return true }
    b.git(`/hasta/${t}${geri}`); return true;
  }
  if (kod === 'steril.okut') {
    const barkod = String(satir?.barkod ?? '');
    const unite = await metinSor('Ünite / oda', '', 'Ünite'); if (unite === null) return true;
    await guvenli(async () => {
      try { const y = await api.sterilOkut({ barkod, unite }); mesaj(y.mesaj); }
      catch (h) {
        if (String((h as { hata?: { engel?: { kod?: string } } })?.hata?.engel?.kod) === 'KARANTINA' && await onay('Paket karantinada (biyolojik sonuç bekleniyor). Yine de kullanılsın mı?')) {
          const y = await api.sterilOkut({ barkod, unite, zorla: true }); mesaj(y.mesaj);
        } else throw h;
      }
      b.tazele();
    });
    return true;
  }
  if (kod.startsWith('steril.birim-')) {
    const islem = kod.slice('steril.birim-'.length) as 'kirli' | 'yikama' | 'sayim' | 'paketle' | 'yaglama' | 'ariza';
    let sayilan: number | undefined, toplam: number | undefined, eksik: string | undefined, notu: string | undefined;
    if (islem === 'sayim') {
      const s = await metinSor('Sayılan alet adedi (boş = tam)', '', 'Sayılan'); if (s === null) return true;
      if (s.trim() !== '') { sayilan = Number(s); const e = await metinSor('Eksik / hasarlı alet', '', 'Eksik'); if (e === null) return true; eksik = e; }
    }
    if (islem === 'ariza') { const n = await metinSor('Arıza / bakım açıklaması', '', 'Açıklama'); if (n === null) return true; notu = n; }
    await guvenli(async () => { const y = await api.sterilBirimOlay({ birimId: id, islem, sayilan, toplam, eksik, notu }); mesaj(y.mesaj); b.tazele() });
    return true;
  }
  if (kod === 'steril.geri-cagirma-ac') { b.git(`/steril-izleme?geriCagirma=${id}`); return true }
  if (kod === 'steril.geri-cagirma-kapat') {
    const n = await metinSor('Kapanış notu (DÖF, tekrar test sonucu)', '', 'Not'); if (n === null) return true;
    await guvenli(async () => { await api.sterilGeriCagirmaKapat(id, n); b.tazele() });
    return true;
  }
  return false;
}
