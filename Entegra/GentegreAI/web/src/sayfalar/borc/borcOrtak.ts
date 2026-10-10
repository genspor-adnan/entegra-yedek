import type { BorcIslemi, Borclu } from '../../api/uclar/hastaBorc';

/** Hasta borç takibinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Borçlu durumu (sunucunun durum kodu). */
export function durumRozeti(d: Borclu['durum']): Rozet {
  switch (d) {
    case 'tahsilata': return { ad: 'Tahsilata çağrılacak', renk: 'kir' };
    case 'soz_tutulmadi': return { ad: 'Söz tutulmadı', renk: 'kir' };
    case 'soz': return { ad: 'Söz verdi', renk: 'mavi' };
    case 'planli': return { ad: 'Ödeme planlı', renk: 'mor' };
    case 'hatirlatildi': return { ad: 'Hatırlatıldı', renk: 'sari' };
    default: return { ad: 'Hatırlatma bekliyor', renk: 'pas' };
  }
}

export const KANAL_ADI: Record<number, string> = { 1: 'SMS', 2: 'E-posta', 3: 'Push', 4: 'WhatsApp' };
export const ISLEM_ADI: Record<number, string> = { 1: 'Hatırlatma', 2: 'Ödeme sözü', 3: 'Ödeme planı', 4: 'Tahsilata çağır', 5: 'Not' };

/** Geçmiş satırı sonucu: hatırlatmada bildirimin durumu, diğerlerinde geçerli / iptal. */
export function islemSonucu(i: Pick<BorcIslemi, 'tur' | 'durum' | 'bildirimDurum'>): Rozet {
  if (i.durum === 9) return { ad: 'Kaldırıldı', renk: 'pas' };
  if (i.tur !== 1) return { ad: 'Geçerli', renk: 'ok' };
  switch (i.bildirimDurum) {
    case 3: return { ad: 'Gönderildi', renk: 'ok' };
    case 1: case 2: return { ad: 'Kuyrukta', renk: 'sari' };
    case 4: case 6: return { ad: 'Gönderilemedi', renk: 'kir' };
    case 5: return { ad: 'İptal', renk: 'pas' };
    default: return { ad: '—', renk: 'pas' };
  }
}

/** Seçilen hastalar içinde kanala uygun olanlar (telefon / e-posta var). */
export function kanalaUygun(borclular: Borclu[], secili: number[], kanal: 1 | 2): Borclu[] {
  return borclular.filter(b => secili.includes(b.id) && (kanal === 1 ? b.telefonVar : b.epostaVar));
}

export type Cip = 'hepsi' | Borclu['durum'];
export const CIPLER: [Cip, string][] = [
  ['hepsi', 'Tümü'], ['yeni', 'Hatırlatma bekliyor'], ['hatirlatildi', 'Hatırlatıldı'], ['soz', 'Söz verdi'],
  ['planli', 'Planlı'], ['soz_tutulmadi', 'Söz tutulmadı'], ['tahsilata', 'Tahsilata çağrılacak'],
];
