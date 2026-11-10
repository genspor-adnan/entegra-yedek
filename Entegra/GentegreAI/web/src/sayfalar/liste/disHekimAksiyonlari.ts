import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * DIŞ DOKTOR SAHA AKSİYONLARI (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html): talep kapat / ret / göreve
 * çevir, ziyaret gördüm, ziyaretten dış doktor kartı. Kurallar uçta; ekran soruyu sorar, reddi gösterir.
 */
export interface DisHekimBaglam {
  tazele(): void;
  git?(yol: string): void;
}

export async function disHekimAksiyonu(
  kod: string, satir: ListeSatiri | null | undefined, b: DisHekimBaglam,
): Promise<boolean> {
  if (!kod.startsWith('dis-hekim-ziyaret.') && !kod.startsWith('dis-hekim-talep.')) return false;
  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir satır seçin.'); return true }

  // ======================================================== ZİYARET ==
  if (kod === 'dis-hekim-ziyaret.goruldu') {
    await guvenli(async () => {
      const y = await api.disHekimZiyaretGoruldu(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }
  if (kod === 'dis-hekim-ziyaret.hekim-karti') {
    const hekimId = Number(satir?.hekimId ?? 0);
    if (!hekimId) { mesaj('Ziyaretin doktoru yok.'); return true }
    b.git?.(`/dis-hekim/${hekimId}`);
    return true;
  }

  // ========================================================== TALEP ==
  const talep = String(satir?.talep ?? '').slice(0, 80);
  if (kod === 'dis-hekim-talep.kapat' || kod === 'dis-hekim-talep.ret') {
    const ret = kod === 'dis-hekim-talep.ret';
    const sonuc = await metinSor(ret ? `"${talep}" reddediliyor. Gerekçe:` : `"${talep}" karşılandı. Sonuç / yanıt:`,
                                 '', ret ? 'Gerekçe' : 'Sonuç');
    if (sonuc === null) return true;
    if (ret && !sonuc.trim()) { mesaj('Ret gerekçesi zorunlu.'); return true }
    await guvenli(async () => {
      const y = await api.disHekimTalepKapat(id, { durum: ret ? 4 : 3, sonuc: sonuc.trim() });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }
  if (kod === 'dis-hekim-talep.goreve-cevir') {
    const sorumlu = String(satir?.sorumluAd ?? '');
    if (!await onay(`"${talep}" için görev açılacak${sorumlu ? ` (sorumlu: ${sorumlu})` : ' (sorumlu: siz)'}.\n\n`
                  + 'Talep göreve bağlanır; görev kapanınca talebi burada kapatın. Devam edilsin mi?')) return true;
    await guvenli(async () => {
      const y = await api.disHekimTalepGoreveCevir(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }
  return false;
}
