import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';
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
  /** Ekran-ozel ek girdi (or. tani arama kutusuna yazilan metin). */
  ek?: string,
): Promise<boolean> {
  if (kod !== 'muayene.al' && kod !== 'muayene.tamamla'
      && kod !== 'muayene.sablon' && kod !== 'muayene.ozet'
      && kod !== 'muayene.normal' && kod !== 'muayene.taniOnceki'
      && kod !== 'muayene.taniSik' && kod !== 'muayene.taniAra'
      && kod !== 'muayene.taniSil'
      && kod !== 'muayene.istem' && kod !== 'muayene.istemLab'
      && kod !== 'muayene.istemGoruntuleme') return false;

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

  // TUMU NORMAL: sablonla acilmis ama HENUZ YAZILMAMIS satirlar "normal"
  //   isaretlenir. Yazilmis bulguya dokunulmaz (kural sunucuda) - aksi halde
  //   tek tikla patolojik bulgu silinebilirdi.
  if (kod === 'muayene.normal') {
    await guvenli(async () => {
      const y = await api.muayeneTumuNormal(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  // TANI ARA + EKLE (mockup tani araç çubugu: jenerik arama + ＋):
  //   kod ya da ad parcasiyla ICD katalogunda arar; tek sonuc dogrudan
  //   eklenir, coksa secim sorulur. Katalog ve ekleme SUNUCUDA - ekran
  //   ICD listesi tasimaz.
  if (kod === 'muayene.taniAra') {
    await guvenli(async () => {
      // Arama metni dugmeden gelmiyorsa SORULUR: arac cubugunda ayri bir
      //   kutu tutmak yerine tek mavi dugme (kullanici) - ICD kodu ya da
      //   adin bir parcasi yazilir, katalog aramasi sunucuda yapilir.
      const anahtar = ((ek ?? '') || await metinSor(
        'ICD-10 kodu ya da tanı adının bir parçası:', '', 'Tanı ara') || '').trim();
      if (anahtar.length < 2) {
        if (anahtar.length > 0) mesaj('En az iki harf/rakam yazın.');
        return;
      }
      // Kod VE ad birlikte aranir: hekim "I21" da yazabilir "enfarkt" de.
      const y = await api.liste('icd', {
        sayfa: 1, boyut: 25,
        filtre: { op: 'and', kosullar: [
          { alan: 'aktif', op: 'esit', deger: 1 },
          { op: 'or', kosullar: [
            { alan: 'kod', op: 'baslar', deger: anahtar },
            { alan: 'ad', op: 'icerir', deger: anahtar },
          ] },
        ] },
      });
      if (y.satirlar.length === 0) { mesaj(`"${anahtar}" için ICD bulunamadı.`); return }
      const secim = y.satirlar.length === 1
        ? String(y.satirlar[0].kod)
        : await secimSor('Hangi tanı eklensin?', y.satirlar.map(r => ({
            kod: String(r.kod), ad: `${String(r.kod)} · ${String(r.ad ?? '')}` })));
      if (!secim) return;
      const s = await api.muayeneTaniEkle(id, secim);
      mesaj(s.mesaj);
      b.tazele();
    });
    return true;
  }

  // TANI SIL: hangi satirin kaldirilacagi SUNUCUDAN gelen listeden secilir.
  if (kod === 'muayene.taniSil') {
    await guvenli(async () => {
      const y = await api.muayeneTanilari(id);
      if (y.tanilar.length === 0) { mesaj('Kaldırılacak tanı yok.'); return }
      const secim = await secimSor('Hangi tanı kaldırılsın?', y.tanilar.map(t => ({
        kod: String(t.id),
        ad: `${t.kod} · ${t.ad}${t.tur === 1 ? ' · ANA' : ''}` })));
      if (!secim) return;
      const s = await api.muayeneTaniSil(id, Number(secim));
      mesaj(s.mesaj);
      b.tazele();
    });
    return true;
  }

  // TANI ONERILERI (mockup tani araç çubugu): kronik hastanin tanisi her
  //   muayenede yeniden yazilirken kod degisebiliyordu - ayni hastalik iki ICD
  //   ile yazilinca rapor ve e-Nabiz ikiye bolunur. Liste sunucudan gelir;
  //   secilen kod yine SUNUCUDA satira donusur (ana tani varsa EK tani).
  if (kod === 'muayene.taniOnceki' || kod === 'muayene.taniSik') {
    await guvenli(async () => {
      const y = await api.muayeneTaniOnerileri(id);
      const liste = kod === 'muayene.taniOnceki'
        ? y.onceki.map(t => ({ kod: t.kod,
            ad: `${t.kod} · ${t.ad}${t.kronik ? ' · kronik' : ''} · ${t.son}` }))
        : y.sik.map(t => ({ kod: t.kod, ad: `${t.kod} · ${t.ad} · ${t.adet} kez` }));
      if (liste.length === 0) {
        mesaj(kod === 'muayene.taniOnceki'
          ? 'Bu hastanın önceki tanısı yok.'
          : 'Son 90 günde yazdığınız tanı yok.');
        return;
      }
      const secim = await secimSor(kod === 'muayene.taniOnceki'
        ? 'Önceki tanılar' : 'Sık kullandıklarım', liste);
      if (!secim) return;
      const s = await api.muayeneTaniEkle(id, secim);
      mesaj(s.mesaj);
      b.tazele();
    });
    return true;
  }

  // ISTEM AC: asil kayit MODUL tablosunda acilir (radyoloji calisma listesi);
  //   muayene_istem yalnizca bag ve durum satiridir. Sonuc geldiginde durum
  //   TETIKLE yansir (418) - modul kodlarina "muayene_istem'i de guncelle"
  //   satiri eklemek, birini unutunca sessizce bozulan bir bag birakirdi.
  if (kod === 'muayene.istem' || kod === 'muayene.istemLab'
      || kod === 'muayene.istemGoruntuleme') {
    await guvenli(async () => {
      // ISTEM TURU: listede TEK dugme oldugu icin sorulur; muayene kartinin
      //   istem sekmesinde mockup'taki gibi AYRI dugmeler var, orada tur
      //   zaten belli. Laboratuvar istemi lab_istem'de acilir ve tup plani +
      //   barkod uretir; goruntuleme radyoloji calisma listesine duser.
      const tur = kod === 'muayene.istemLab' ? '1'
                : kod === 'muayene.istemGoruntuleme' ? '2'
                : await secimSor('İstem türü?', [
                    { kod: '1', ad: '🧪 Laboratuvar' },
                    { kod: '2', ad: '📷 Görüntüleme' },
                  ]);
      if (!tur) return;

      if (tur === '1') {
        const paneller = await api.liste('lab-panel', { sayfa: 1, boyut: 50 });
        const tetkikler = await api.liste('lab-tetkik', { sayfa: 1, boyut: 100 });
        const secenekler = [
          ...paneller.satirlar.map(r => ({
            kod: `P${r.id}`, ad: `📦 ${String(r.ad ?? '')}` })),
          ...tetkikler.satirlar.map(r => ({
            kod: `T${r.id}`, ad: `${String(r.kod ?? '')} · ${String(r.ad ?? '')}` })),
        ];
        if (secenekler.length === 0) { mesaj('Tetkik kataloğu boş.'); return }

        const secim = await secimSor('Hangi tetkik / panel istensin?', secenekler);
        if (!secim) return;

        const y = await api.muayeneIstemAc(id, {
          tur: 1, aciliyet: 1,
          tetkikIdler: secim.startsWith('T') ? [Number(secim.slice(1))] : [],
          panelIdler: secim.startsWith('P') ? [Number(secim.slice(1))] : [],
        });
        mesaj(y.mesaj);
        b.tazele();
        return;
      }

      // YALNIZ RADYOLOJI TETKIKLERI (459/460): modalitesi olmayan hizmetle
      //   acilan istem sunucuda reddediliyor - listeye koymak, kullaniciya
      //   secilemeyecek satir teklif etmek demekti.
      const hizmetler = await api.liste('hizmet', {
        sayfa: 1, boyut: 100,
        filtre: { alan: 'modalite', op: 'buyuk', deger: 0 },
      });
      if (hizmetler.satirlar.length === 0) {
        mesaj('Modalitesi tanımlı radyoloji tetkiki yok '
            + '(Stok & Hizmet > Hizmet kartından modalite seçin).');
        return;
      }

      const secim = await secimSor('Hangi tetkik istensin?',
        hizmetler.satirlar.slice(0, 40).map(r => ({
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
