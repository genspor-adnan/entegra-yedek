import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';

/**
 * ÇAĞRI MERKEZİ (839) liste aksiyonları: çağrı kartı / elle kayıt / kişi kartı /
 * geri arama tamam; kampanya panosu / üret / çalıştır / durdur; kişi ara / sonuç.
 * Düz CRUD'lar (yeni / düzenle / sil) Liste'nin genel akışında kalır.
 */
export async function cagriAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                    b: { tazele(): void; git(yol: string): void; geri: string }): Promise<boolean> {
  if (!kod.startsWith('cagri.')) return false;
  const geri = `?geri=${encodeURIComponent(b.geri)}`;
  const id = Number(satir?.id ?? 0);

  if (kod === 'cagri.yeni-kayit') {
    const tel = await metinSor('Arayan / aranan numara', '', 'Telefon');
    if (tel === null) return true;
    const yon = await secimSor('Çağrı yönü', [{ kod: '1', ad: '📥 Gelen (elle kayıt)' }, { kod: '2', ad: '📤 Giden (aradım)' }], '1');
    if (!yon) return true;
    await guvenli(async () => {
      const y = await api.cagriBaslat({ kanal: 1, yon: Number(yon), arayanNo: tel.trim() });
      b.git(`/cagri-pano?cagri=${y.id}`);
    });
    return true;
  }
  if (!id) { mesaj('Önce bir satır seçin.'); return true }

  if (kod === 'cagri.kart') { b.git(`/cagri/${Number(satir?.cagriId ?? 0) || id}${geri}`); return true }
  if (kod === 'cagri.duzenle') { b.git(`/cagri-kart/${id}${geri}`); return true }
  if (kod === 'cagri.kisi-ac') {
    const t = Number(satir?.tarafId ?? 0);
    if (!t) { mesaj('Bu çağrı bir kişiye bağlı değil.'); return true }
    b.git(`${Number(satir?.hasta ?? 0) ? '/hasta' : '/cari'}/${t}${geri}`); return true;
  }
  if (kod === 'cagri.geri-arama-tamam') {
    if (!await onay('Geri arama yapıldı olarak işaretlensin mi? Bağlı hatırlatma görevi kapanır.')) return true;
    await guvenli(async () => { await api.cagriGeriAramaTamam(id); b.tazele() });
    return true;
  }
  if (kod === 'cagri.kampanya-kart') { b.git(`/cagri-giden?kampanya=${id}`); return true }
  if (kod === 'cagri.kampanya-uret') {
    await guvenli(async () => {
      const y = await api.cagriKampanyaUret(id);
      mesaj(y.not_ || `Listeye ${y.eklenen} kişi eklendi (${y.atlanan} atlandı: telefon yok / zaten listede).`);
      b.tazele();
    });
    return true;
  }
  if (kod === 'cagri.kampanya-calistir') {
    if (!await onay('Kampanya çalıştırılsın mı? Bekleyen kişilere 1. adım mesajı bildirim kuyruğuna alınır; şablonsuz kampanyada kişiler geri arama listesine düşer.')) return true;
    await guvenli(async () => {
      const y = await api.cagriKampanyaCalistir(id);
      mesaj(y.dogrudanArama ? 'Kampanya çalışıyor; kişiler geri arama listesinde.' : `${y.gonderilen} mesaj kuyruğa alındı${y.hata ? `, ${y.hata} hata` : ''}.`);
      b.tazele();
    });
    return true;
  }
  if (kod === 'cagri.kampanya-durdur') {
    if (!await onay('Kampanya durdurulsun mu?')) return true;
    await guvenli(async () => { await api.cagriKampanyaDurdur(id); b.tazele() });
    return true;
  }
  if (kod === 'cagri.kisi-ara') {
    await guvenli(async () => {
      const y = await api.cagriBaslat({ kanal: 1, yon: 2, arayanNo: String(satir?.telefon ?? ''), tarafId: Number(satir?.tarafId ?? 0) || null, kampanyaKisiId: id });
      b.git(`/cagri-pano?cagri=${y.id}`);
    });
    return true;
  }
  if (kod === 'cagri.kisi-sonuc') {
    const d = await secimSor('Kişi sonucu', [{ kod: '5', ad: '✅ Onayladı' }, { kod: '4', ad: '✔ Tamamlandı' }, { kod: '3', ad: '📵 Ulaşılamadı' }, { kod: '6', ad: '❌ İptal etti' }, { kod: '7', ad: '🚫 Vazgeçildi' }]);
    if (!d) return true;
    const notu = await metinSor('Sonuç notu', '', 'Not');
    if (notu === null) return true;
    await guvenli(async () => { await api.cagriKisiSonuc(id, { durum: Number(d), sonuc: notu }); b.tazele() });
    return true;
  }
  return false;
}
