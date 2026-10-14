import { api } from '../../api/istemci';
import type { AksiyonBaglami } from './aksiyonOrtak';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * PATOLOJİ AKSİYONLARI (1104) - vaka ve dış lab gönderimi adımları.
 *
 * Durum kartta yazılmaz, buradan yürür: hazırlandı → pakete ekle → kurye →
 * lab teslim → lab kabul (lab vaka no, TAT başlar) → rapor (kartta) → gördüm.
 * "Pakete Ekle" çoklu seçimle çalışır: aynı laba gidecek vakalar tek pakette.
 */
export async function patolojiAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  secililer: ListeSatiri[] | undefined,
  b: AksiyonBaglami,
): Promise<boolean> {
  if (!kod.startsWith('patoloji.')) return false;

  if (kod === 'patoloji.pakete-ekle') {
    const idler = (secililer?.length ? secililer : satir ? [satir] : []).map(r => Number(r.id)).filter(Boolean);
    if (!idler.length) { mesaj('Önce vaka seçin.'); return true }
    await guvenli(async () => { mesaj((await api.patolojiPaketeEkle(idler)).mesaj); b.tazele() });
    return true;
  }

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }
  const calistir = (f: () => Promise<{ mesaj: string }>) =>
    guvenli(async () => { mesaj((await f()).mesaj); b.tazele() });

  switch (kod) {
    case 'patoloji.hazirlandi': await calistir(() => api.patolojiHazirlandi(id)); return true;
    case 'patoloji.paketten-cikar': await calistir(() => api.patolojiPakettenCikar(id)); return true;
    case 'patoloji.gordum': await calistir(() => api.patolojiGordum(id)); return true;
    case 'patoloji.lab-kabul': {
      const no = await metinSor('Labın verdiği vaka numarası (örn. P26-18833):', String(satir?.labNo ?? ''), 'Lab vaka no');
      if (no?.trim()) await calistir(() => api.patolojiLabKabul(id, no.trim()));
      return true;
    }
    case 'patoloji.ret': {
      await guvenli(async () => {
        const r = await api.liste('patoloji-ret-nedeni', { sayfa: 1, boyut: 50 });
        const neden = await listeSor('Ret nedeni:', r.satirlar.filter(x => Number(x.aktif) === 1)
          .map(x => ({ kod: String(x.id), ad: String(x.ad) })), '', 'Neden');
        if (neden === null) return;
        const aciklama = await metinSor('Açıklama (isteyen hekime gider):', '', 'Açıklama') ?? '';
        mesaj((await api.patolojiRet(id, Number(neden) || null, aciklama)).mesaj); b.tazele();
      });
      return true;
    }
    case 'patoloji.ek-onayla':
    case 'patoloji.ek-reddet': {
      const onayla = kod === 'patoloji.ek-onayla';
      if (!await onay(onayla ? 'Bu vakada onay bekleyen ek incelemeler (İHK / özel boya) onaylansın mı? Ek ücret oluşur.'
                             : 'Onay bekleyen ek incelemeler reddedilsin mi? Lab bilgilendirilmeli.', !onayla)) return true;
      await calistir(() => api.patolojiEkKarar(id, onayla ? 'onayla' : 'reddet'));
      return true;
    }
    case 'patoloji.laba-ilet': await calistir(() => api.patolojiIlet(id)); return true;
    case 'patoloji.kurye': {
      const k = await metinSor('Kurye (firma / ad):', String(satir?.kurye ?? ''), 'Kurye');
      if (k !== null) await calistir(() => api.patolojiKurye(id, k));
      return true;
    }
    case 'patoloji.lab-teslim': {
      const t = await metinSor('Labda teslim alan:', '', 'Teslim alan');
      if (t !== null) await calistir(() => api.patolojiLabTeslim(id, t));
      return true;
    }
  }
  return false;
}
