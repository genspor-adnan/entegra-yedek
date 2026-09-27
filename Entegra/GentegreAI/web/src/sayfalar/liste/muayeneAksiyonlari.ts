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
  /**
   * Acik karti kapatir (listeden cagrildiysa verilmez).
   *
   * TAMAMLANAN MUAYENENIN KARTI ACIK KALMAMALI: kayit kilitlendi, alanlar
   * artik salt okunur ve hekimin o ekranda yapacagi bir sey yok. Acik
   * birakmak, kapali bir kaydin uzerinde calisiliyormus izlenimi verir -
   * hekim yazmaya devam eder ve degisiklik kaydedilemez.
   */
  kartKapat?(): void;
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
      && kod !== 'muayene.taniSil' && kod !== 'muayene.raporImza'
      && kod !== 'muayene.raporSil') return false;

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

  // RAPOR SİL (mockup "🗑"): yalnız TASLAK rapor silinir - imzalı/onaylı
  //   rapor yasal kayıttır, silinmez (uç de reddeder).
  if (kod === 'muayene.raporSil') {
    await guvenli(async () => {
      const y = await api.muayeneRaporlari(id);
      const taslak = y.raporlar.filter(r => Number(r.durum ?? 0) === 1);
      if (taslak.length === 0) { mesaj('Silinecek taslak rapor yok (imzalı rapor silinemez).'); return }
      const secim = taslak.length === 1
        ? String(taslak[0].id)
        : await secimSor('Hangi taslak rapor silinsin?', taslak.map(r => ({
            kod: String(r.id),
            ad: `#${String(r.id)} · ${String(r.baslangic ?? '').slice(0, 10)}`
              + ` · ${String(r.gun ?? 0)} gün · ${String(r.icdKod ?? '')}`,
          })));
      if (!secim) return;
      if (!await onay('Taslak rapor silinecek. Onaylıyor musunuz?', true)) return;
      const s = await api.muayeneRaporSil(Number(secim));
      mesaj(s.mesaj);
      b.tazele();
    });
    return true;
  }

  // RAPOR IMZA (mockup rapor arac cubugu "✍ e-Imzala"): hangi raporun
  //   imzalanacagi SUNUCUDAN gelen listeden secilir; eksik rapor uc
  //   tarafindan reddedilir (tur/baslangic/gun/tani).
  if (kod === 'muayene.raporImza') {
    await guvenli(async () => {
      const y = await api.muayeneRaporlari(id);
      const taslak = y.raporlar.filter(r => Number(r.durum ?? 0) === 1);
      if (taslak.length === 0) { mesaj('İmzalanacak taslak rapor yok.'); return }
      const secim = taslak.length === 1
        ? String(taslak[0].id)
        : await secimSor('Hangi rapor imzalansın?', taslak.map(r => ({
            kod: String(r.id),
            ad: `#${String(r.id)} · ${String(r.baslangic ?? '').slice(0, 10)}`
              + ` · ${String(r.gun ?? 0)} gün · ${String(r.icdKod ?? '')}`,
          })));
      if (!secim) return;
      if (!await onay('Rapor imzalanacak. İmzalanan rapor değiştirilemez. '
                    + 'Onaylıyor musunuz?')) return;
      const s = await api.muayeneRaporImzala(Number(secim));
      mesaj(s.mesaj);
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

  // (Eski tek-düğme "İstem Aç" secimSor akışı kaldırıldı - istem artık İstem &
  //   Sonuçlar sekmesindeki grid başlığında "＋ İstem" birleşik modalıyla.)

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
    // Kapatma YALNIZ BASARIDA: sunucu eksik alan yuzunden reddederse
    //   (ana tani / sikayet / karar) kart acik kalmali - hekim eksigi
    //   ayni ekranda tamamlasin diye. `guvenli` hatada buraya hic gelmez.
    b.kartKapat?.();
  });
  return true;
}
