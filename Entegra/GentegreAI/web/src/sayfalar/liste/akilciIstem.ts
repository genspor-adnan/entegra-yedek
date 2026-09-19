import { api } from '../../api/istemci';
import { ApiHatasi } from '../../api/sozlesme';
import { mesaj, secimSor } from '../../bilesenler/mesaj';

/**
 * AKILCI TEST İSTEMİ — hekim karar akışı (873, Bakanlık EK-2 §3-4).
 *
 * Kural SUNUCUDA: istem ucu gerekçesiz uyarıda 422 `AKILCI_UYARI` döner,
 * gövdede uyarılar (mesaj, son 2 sonuç) ve SKRS gerekçe seçenekleri gelir.
 * Bu yardımcı yalnız diyaloğu çizer: her uyarı için "Bu testin … tarihinde
 * sonucu var, tekrar istemek istediğinizden emin misiniz?" sorusu; hekim
 * gerekçe seçer (devam) ya da "Hayır" der (tetkik listeden çıkar, vazgeçme
 * kaydı sunucuya düşer). Sonra çağıran istemi kararla yeniden gönderir.
 *
 * `AKILCI_ENGEL` (kapalı test / basamak) aşılmaz: mesaj gösterilir.
 */
export interface AkilciKarar { tetkikId: number; kural: string; gerekceKod: number; aciklama?: string }

interface Uyari {
  tetkikId: number; ad: string; kural: string; mesaj: string; sureGun: number;
  sonTarih?: string | null; kalanGun?: number | null; hekimBrans?: string; sureNotu?: string;
  sonuclar?: { tarih: string; deger: string; birim: string; bayrak: string; durum: string }[] | null;
}
interface Secenek { kod: number; ad: string }
interface UyariGovdesi {
  kod: string; uyarilar?: Uyari[]; gerekceler?: Secenek[]; klinikGerekceler?: Secenek[];
  tetkikler?: { tetkikId: number; ad: string; kural: string; mesaj: string }[];
}

export function akilciEngelKodu(h: unknown): string | null {
  if (!(h instanceof ApiHatasi)) return null;
  const kod = (h.hata.engel as { kod?: string } | undefined)?.kod;
  return kod === 'AKILCI_UYARI' || kod === 'AKILCI_ENGEL' ? kod : null;
}

function tarih(t?: string | null): string {
  if (!t) return '';
  const d = new Date(t);
  return Number.isNaN(d.getTime()) ? t : d.toLocaleDateString('tr-TR');
}

/**
 * Uyarı hatasını hekime sorar. Dönen: devam kararları + listeden çıkarılacak
 * tetkikler; kullanıcı diyaloğu kapatırsa null (istem gönderilmez).
 * Vazgeçmeler `hastaId` verildiyse sunucuya kaydedilir (§4.6).
 */
export async function akilciUyariAkisi(h: unknown, hastaId?: number, hekimId?: number)
  : Promise<{ akilci: AkilciKarar[]; cikar: number[] } | null> {
  if (!(h instanceof ApiHatasi)) return null;
  const govde = h.hata.engel as UyariGovdesi | undefined;
  if (!govde) return null;

  if (govde.kod === 'AKILCI_ENGEL') {
    const satirlar = (govde.tetkikler ?? []).map(t => `• ${t.ad}: ${t.mesaj}`).join('\n');
    mesaj(`Akılcı test istemi engeli:\n${satirlar || h.message}`);
    return null;
  }
  if (govde.kod !== 'AKILCI_UYARI') return null;

  const akilci: AkilciKarar[] = [];
  const cikar: number[] = [];
  const vazgec: AkilciKarar[] = [];
  for (const u of govde.uyarilar ?? []) {
    const secenekler = (u.kural === 'brans' ? govde.klinikGerekceler : govde.gerekceler) ?? [];
    const gecmis = (u.sonuclar ?? []).map(s =>
      `${tarih(s.tarih)}: ${s.deger} ${s.birim ?? ''} ${s.bayrak && s.bayrak !== 'N' ? `(${s.bayrak})` : ''} · ${s.durum}`).join('\n');
    const soru = `${u.mesaj}${gecmis ? `\n\nSon sonuçlar:\n${gecmis}` : ''}\n\n`
      + (u.kural === 'brans' ? 'Klinik gerekçe seçerek devam edin ya da vazgeçin:'
                             : 'Tekrar istemek için gerekçe seçin ya da "Hayır" ile vazgeçin:');
    const secim = await secimSor(soru, [
      ...secenekler.map(s => ({ kod: String(s.kod), ad: s.ad })),
      { kod: 'HAYIR', ad: '✖ Hayır - bu tetkiği isteme' },
    ]);
    if (!secim) return null;                       // diyalog kapatıldı: istem gönderilmez
    if (secim === 'HAYIR') {
      cikar.push(u.tetkikId);
      vazgec.push({ tetkikId: u.tetkikId, kural: u.kural, gerekceKod: 0, aciklama: 'hekim vazgeçti' });
      continue;
    }
    akilci.push({ tetkikId: u.tetkikId, kural: u.kural, gerekceKod: Number(secim) });
  }
  if (vazgec.length > 0 && hastaId) {
    try { await api.labAkilciKarar({ hastaId, hekimId, kararlar: vazgec }) } catch { /* iz düşmezse istem yine devam eder */ }
  }
  return { akilci, cikar };
}
