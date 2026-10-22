import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * İK › BELGE TAKİBİ LİSTE AKSİYONU (1137, mockup personel_belge_takibi.html (2)
 * "📤 Seçililere hatırlat"). Satır id = personel id. Gönderilmeyenin SEBEBİ
 * söylenir (iletişim yok, 24 saatte hatırlatıldı, eksiği yok) - sessiz "tamam"
 * kullanıcıya herkese gittiği izlenimini verirdi.
 */
export async function belgeTakipAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  secililer: ListeSatiri[] | undefined,
): Promise<boolean> {
  if (kod !== 'personel-belge.hatirlat') return false;

  const idler = (secililer && secililer.length > 0 ? secililer : satir ? [satir] : [])
    .map(x => Number(x.id)).filter(Boolean);
  if (idler.length === 0) { mesaj('Önce personel seçin.'); return true }
  if (!await onay(`${idler.length} personele eksik / süresi dolan belgeleri için hatırlatma gönderilecek `
                + '(e-postası varsa e-posta, yoksa SMS). Onaylıyor musunuz?')) return true;

  await guvenli(async () => {
    const y = await api.belgeTakipHatirlat(idler);
    mesaj(`${y.kuyruga} personele hatırlatma gönderim kuyruğuna alındı.`
        + (y.atlanan.length
           ? `\n\nGönderilmeyen ${y.atlanan.length}:\n` + y.atlanan.map(a => `• ${a.ad}: ${a.neden}`).join('\n')
           : ''));
  });
  return true;
}
