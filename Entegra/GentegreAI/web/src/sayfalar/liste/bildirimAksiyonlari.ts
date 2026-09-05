import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * BILDIRIM KUYRUGU LISTE AKSIYONLARI (399).
 *
 * Kuyruk ekrani "gitti mi" sorusunun tek yeri; oradan yapilabilecek iki is
 * var: gitmeyeni YENIDEN DENE, gitmesin dedigini IPTAL ET. Ikisi de sunucuda
 * durum kontrolluduur (uc yalniz uygun durumdaki satiri degistirir), burasi
 * kullaniciya SONUCU soyler - sessiz "tamam" yanlis izlenim birakirdi.
 *
 * Toplu secim destekli: hatali gece bildirimlerinin tamami tek seferde
 * yeniden denenebilsin (tek tek acmak is degil, angarya).
 */
export interface BildirimBaglam {
  tazele(): void;
}

export async function bildirimAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  secililer: ListeSatiri[] | undefined,
  b: BildirimBaglam,
): Promise<boolean> {
  if (kod !== 'bildirim.tekrar' && kod !== 'bildirim.iptal') return false;

  const idler = (secililer && secililer.length > 0 ? secililer : satir ? [satir] : [])
    .map(x => Number(x.id)).filter(Boolean);
  if (idler.length === 0) { mesaj('Önce satır seçin.'); return true }

  const tekrarMi = kod === 'bildirim.tekrar';

  // IPTAL onay ister (geri alinmaz sayilmaz ama kullanici bilerek yapsin),
  //   TEKRAR DENE tek satirda sormaz - zaten gitmemis bir bildirimi yeniden
  //   denemek zararsiz; TOPLU secimde ikisi de sorar (yanlis secim pahali).
  const soru = tekrarMi
    ? `${idler.length} bildirim yeniden kuyruğa alınacak. Onaylıyor musunuz?`
    : `${idler.length} bildirim iptal edilecek (gönderilmeyecek). Onaylıyor musunuz?`;
  if ((!tekrarMi || idler.length > 1) && !await onay(soru, !tekrarMi)) return true;

  await guvenli(async () => {
    let olan = 0;
    const olmayan: number[] = [];
    for (const id of idler) {
      const oldu = tekrarMi
        ? (await api.bildirimTekrar(id)).tekrar
        : (await api.bildirimIptal(id)).iptal;
      if (oldu) olan++; else olmayan.push(id);
    }

    // ELE ALINMAYANIN SEBEBI SOYLENIR: uc yalniz uygun durumdaki satiri
    //   degistirir (tekrar: hata/iptal/vazgecildi · iptal: kuyrukta/hata/
    //   vazgecildi). "0 satir etkilendi" sessiz kalirsa kullanici dugmeyi
    //   bozuk sanir.
    mesaj(`${olan} bildirim ${tekrarMi ? 'yeniden kuyruğa alındı' : 'iptal edildi'}.`
        + (olmayan.length
           ? `\n\n${olmayan.length} satır uygun durumda değil `
             + (tekrarMi
                ? '(yalnız hatalı / iptal / vazgeçilmiş satır yeniden denenir).'
                : '(gönderilmiş bildirim iptal edilemez).')
           : ''));
    b.tazele();
  });
  return true;
}
