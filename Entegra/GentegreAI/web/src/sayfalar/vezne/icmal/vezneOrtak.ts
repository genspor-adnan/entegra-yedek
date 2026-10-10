import type { VezneOturumu, VezneTerminali, VezneTuru } from '../../../api/uclar/vezneIcmal';

/** Vezne icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** "08:00" - tarih aralığı birden çok günse "10.10 08:00". */
export function saat(t: string | null | undefined, gunlu = false): string {
  if (!t) return '';
  const d = new Date(t);
  const s = d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
  return gunlu ? `${d.toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' })} ${s}` : s;
}

/**
 * OTURUM DURUMU: kapanmış oturumda sayım farkı açıklanmamışsa uyarı rozeti
 * (mockup "Fark · açıklama bekliyor") - fark kendisi hata değil, açıklamasız
 * fark denetim konusudur.
 */
export function oturumRozeti(o: Pick<VezneOturumu, 'durum' | 'fark' | 'farkAciklama'>): Rozet {
  const farkli = Math.abs(o.fark ?? 0) > 0.005;
  if (o.durum === 1) return { ad: 'Açılış onayı bekliyor', renk: 'sari' };
  if (o.durum === 2) return { ad: 'Açık', renk: 'mavi' };
  if (o.durum === 3) return { ad: 'Kapanış onayı bekliyor', renk: 'sari' };
  if (farkli && !o.farkAciklama.trim()) return { ad: 'Fark · açıklama yok', renk: 'kir' };
  return { ad: farkli ? 'Teslim edildi · farklı' : 'Teslim edildi', renk: farkli ? 'sari' : 'ok' };
}

/** Ödeme türü "nerede": kasada mı, bankada mı (kasa_durumu 1..4). */
export function neredeRozeti(x: Pick<VezneTuru, 'kasaDurumu' | 'hesapTuru' | 'net'>): Rozet {
  if (x.kasaDurumu === 1) return x.net < 0 ? { ad: 'Kasadan çıktı', renk: 'ok' } : { ad: 'Kasada', renk: 'ok' };
  if (x.kasaDurumu === 3) return { ad: 'Portföyde', renk: 'mor' };
  if (x.kasaDurumu === 4) return { ad: 'Nakit akışı yok', renk: 'pas' };
  return { ad: x.hesapTuru === 'P' ? 'Bankada (bloke)' : 'Bankada', renk: 'mavi' };
}

/** POS terminal durumu: gün sonu girilmediyse fark hesaplanamaz. */
export function terminalRozeti(t: Pick<VezneTerminali, 'eksik' | 'fark'>): Rozet {
  if (t.eksik || t.fark == null) return { ad: 'Cihaz gün sonu girilmedi', renk: 'sari' };
  if (Math.abs(t.fark) > 0.005) {
    return t.fark > 0 ? { ad: 'Kasaya girilmemiş işlem', renk: 'kir' } : { ad: 'Cihazda olmayan kayıt', renk: 'kir' };
  }
  return { ad: 'Eşleşti', renk: 'ok' };
}

/** Devir satırı durumu (yalnız nakit merkez kasaya gider). */
export function devirRozeti(o: Pick<VezneOturumu, 'durum' | 'fark'>): Rozet {
  if (o.durum === 4) return Math.abs(o.fark ?? 0) > 0.005
    ? { ad: 'Devredildi · farklı', renk: 'sari' } : { ad: 'Devredildi', renk: 'ok' };
  if (o.durum === 3) return { ad: 'Onay bekliyor', renk: 'sari' };
  if (o.durum === 2) return { ad: 'Oturum açık', renk: 'mavi' };
  return { ad: 'Açılmadı', renk: 'pas' };
}

/** Bugün (yerel gün). */
export const bugun = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};
