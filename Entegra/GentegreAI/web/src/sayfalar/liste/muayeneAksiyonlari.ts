import { api } from '../../api/istemci';
import { guvenli, mesaj, onay, secimSor } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * MUAYENE LISTE AKSIYONLARI (409, Faz 1).
 *
 * Iki dugme, iki durum gecisi:
 *
 *   * "Muayeneye Al" baslangic zamanini yazar - USS Muayene Baslangic.
 *     Kartin acilma zamani DEGIL: kart sabah acilip hasta ogleden sonra
 *     girebilir. Ikinci tikta zaman ezilmez (kural sunucuda).
 *   * "Tamamla" kaydi kilitler, basvuruyu tahakkuka dondurur ve e-Nabiz
 *     kuyruguna atar; geri alinamaz, bu yuzden ONAY istenir. Eksik kayit
 *     sunucuda reddedilir (ana tani + sikayet + karar) - hata mesaji
 *     eksiklerin HEPSINI birden sayar.
 */
export interface MuayeneBaglam {
  tazele(): void;
}

export async function muayeneAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: MuayeneBaglam,
): Promise<boolean> {
  if (kod !== 'muayene.al' && kod !== 'muayene.tamamla'
      && kod !== 'muayene.sablon' && kod !== 'muayene.ozet'
      && kod !== 'muayene.istem') return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir muayene seçin.'); return true }
  const hasta = String(satir?.hastaAdi ?? '');

  // SABLON UYGULA: alanlar bulgu satiri olarak acilir ve hepsi "normal"
  //   isaretlenir. Hekimin isi boylece "hepsini yaz" degil "sapani duzelt"
  //   olur - poliklinikte fark buradadir. Var olan bulgular korunur, yani
  //   sablonu ikinci kez uygulamak yazilmis bulguyu silmez.
  if (kod === 'muayene.sablon') {
    await guvenli(async () => {
      const liste = await api.liste('muayene-sablon', { sayfa: 1, boyut: 50,
        filtre: { alan: 'durum', op: 'esit', deger: 1 } });
      if (liste.satirlar.length === 0) { mesaj('Tanımlı şablon yok.'); return }

      const secim = await secimSor('Hangi şablon uygulansın?',
        liste.satirlar.map(r => ({
          kod: String(r.id),
          ad: `${r.ad} · ${r.kapsamAdi} · ${r.alanSayisi} alan`,
        })));
      if (!secim) return;

      const y = await api.muayeneSablonUygula(id, Number(secim));
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  // ISTEM AC: asil kayit MODUL tablosunda acilir (radyoloji calisma listesi);
  //   muayene_istem yalnizca bag ve durum satiridir. Sonuc geldiginde durum
  //   TETIKLE yansir (418) - modul kodlarina "muayene_istem'i de guncelle"
  //   satiri eklemek, birini unutunca sessizce bozulan bir bag birakirdi.
  if (kod === 'muayene.istem') {
    await guvenli(async () => {
      const hizmetler = await api.liste('hizmet', { sayfa: 1, boyut: 50 });
      if (hizmetler.satirlar.length === 0) { mesaj('Tanımlı hizmet yok.'); return }

      const secim = await secimSor('Hangi tetkik istensin?',
        hizmetler.satirlar.slice(0, 20).map(r => ({
          kod: String(r.id), ad: String(r.ad ?? ''),
        })));
      if (!secim) return;

      const y = await api.muayeneIstemAc(id, { tur: 2, hizmetId: Number(secim), aciliyet: 1 });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'muayene.ozet') {
    await guvenli(async () => {
      const y = await api.muayeneOzetDerle(id);
      mesaj(y.bulguOzet
        ? `Muayene bulguları derlendi:\n\n${y.bulguOzet}`
        : 'Derlenecek bulgu yok - önce şablon uygulayın.');
      b.tazele();
    });
    return true;
  }

  if (kod === 'muayene.al') {
    await guvenli(async () => {
      const y = await api.muayeneyeAl(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (!await onay(`${hasta} muayenesi tamamlansın mı?\n\n`
                + 'Kayıt kilitlenir, başvuru tahakkuka döner ve e-Nabız kuyruğuna girer.'))
    return true;

  await guvenli(async () => {
    const y = await api.muayeneTamamla(id);
    mesaj(y.uyari ? `${y.mesaj}\n\n⚠ ${y.uyari}` : y.mesaj);
    b.tazele();
  });
  return true;
}
