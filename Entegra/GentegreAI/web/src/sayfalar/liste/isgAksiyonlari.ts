import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj, onay, secimSor } from '../../bilesenler/mesaj';

/**
 * İSG (741) liste aksiyonları: firma panosu, çalışan kartı, Ek-2 muayene aç
 * (SMS / iç ekran), form gönder, olay bildir; muayene formu / kanaati işle /
 * iptal; olay SGK bildirildi / kapat.
 */
export async function isgAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                  b: { tazele(): void; git(yol: string): void; geri: string }): Promise<boolean> {
  if (!kod.startsWith('isg.')) return false;
  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir satır seçin.'); return true }
  const geri = `?geri=${encodeURIComponent(b.geri)}`;

  if (kod === 'isg.firma-kart') { b.git(`/isg-pano?firma=${id}`); return true }
  if (kod === 'isg.calisan-kart') { b.git(`/isg-calisan/${id}${geri}`); return true }
  if (kod === 'isg.muayene-ac' || kod === 'isg.form-gonder') {
    const kanal = kod === 'isg.form-gonder' ? '3'
      : await secimSor('Çalışan bölümü nasıl doldurulacak?', [{ kod: '3', ad: '📱 SMS ile telefonuna gönder' }, { kod: '2', ad: '🖥 Tablette / kioskta' }, { kod: '1', ad: '🩺 İç ekranda birlikte' }]);
    if (!kanal) return true;
    const tur = await secimSor('Muayene türü', [{ kod: '2', ad: 'Periyodik' }, { kod: '1', ad: 'İşe giriş' }, { kod: '3', ad: 'İşe dönüş' }, { kod: '4', ad: 'Erken kontrol' }]); if (!tur) return true;
    await guvenli(async () => {
      const y = await api.isgMuayeneAc(id, { tur: Number(tur), kanal: Number(kanal) });
      if (y.mevcut) mesaj('Açık muayene zaten var; ona gidiliyor.');
      else if (Number(kanal) === 3) mesaj('Ek-2 muayenesi açıldı, çalışan bölümü SMS kuyruğuna alındı.');
      if (Number(kanal) === 2 && y.baglanti) window.open(y.baglanti, '_blank', 'noopener');
      b.tazele();
      if (Number(kanal) !== 3 && y.formIstekId) b.git(`/form-doldur/${y.formIstekId}${geri}`);
    });
    return true;
  }
  if (kod === 'isg.olay-bildir') { b.git(`/isg-olay/yeni${geri}&firmaId=${satir?.firmaId ?? ''}&calisanId=${id}`); return true }
  if (kod === 'isg.muayene-form') {
    const f = Number(satir?.formIstekId ?? 0);
    if (!f) { b.git(`/isg-muayene/${id}${geri}`); return true }
    b.git(`/form-doldur/${f}${geri}`); return true;
  }
  if (kod === 'isg.muayene-isle') {
    await guvenli(async () => { const y = await api.isgMuayeneIsle(id); mesaj(`Kanaat işlendi: ${y.kanaatMetin || '—'}`); b.tazele() });
    return true;
  }
  if (kod === 'isg.muayene-iptal') {
    if (!await onay('Muayene iptal edilsin mi? Ek-2 bağlantısı kapanır.', true)) return true;
    await guvenli(async () => { await api.isgMuayeneIptal(id); b.tazele() });
    return true;
  }
  if (kod === 'isg.olay-sgk') {
    if (!await onay('SGK bildirimi bugün yapıldı olarak işaretlensin mi?')) return true;
    await guvenli(async () => { await api.isgOlaySgk(id); b.tazele() });
    return true;
  }
  if (kod === 'isg.olay-kapat') {
    if (!await onay('Olay kapatılsın mı?')) return true;
    await guvenli(async () => { await api.isgOlayKapat(id); b.tazele() });
    return true;
  }
  return false;
}
