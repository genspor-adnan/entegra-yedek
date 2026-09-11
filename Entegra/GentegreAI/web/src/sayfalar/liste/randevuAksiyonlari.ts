import { api } from '../../api/istemci';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';
import { kampanyaKalemFiyati } from '../belgeKalem';
import { yerelZamanDamgasi } from './zaman';

/**
 * RANDEVU DURUM AKISI (243) ve BASVURUYA DONUSUM (265 · 317).
 *
 * `Liste.tsx` govdesinden ayrildi. Cihazli (radyoloji) randevuda "Geldi" ve
 * "Başvuru" duz durum degisikligi degil KABUL ekranidir (317): hasta cogunlukla
 * kuruma GELMEDEN randevu alir, geldigi an basvuru + ucret + ISTEM dogar.
 *
 * Donus: aksiyon burada ele alindiysa true.
 */
export interface RandevuBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Kabul ekrani (317): istem modali randevuya bagli acilir. */
  setIstemModali(m: { hastaId: number; hastaAdi: string; disIstem: boolean;
                      randevuId?: number; hizmetId?: number }): void;
  /** Acilan/var olan basvuru MODAL gosterilir - belge kartinin rotasi yok. */
  setAcikBelgeId(id: number): void;
  /** Belge olusturmada sube: oturumun calisma subesi. */
  oturumSubeId?: number;
}

export async function randevuAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: RandevuBaglam,
): Promise<boolean> {
  if (kod !== 'randevu.geldi' && kod !== 'randevu.gelmedi'
      && kod !== 'randevu.iptal' && kod !== 'randevu.basvuru') return false;

  /**
   * RADYOLOJI RANDEVUSUNDA "GELDI" = KABUL (317).
   *
   * Hasta cogunlukla kuruma GELMEDEN randevu alir: o an ne basvuru ne odeme ne
   * istem vardir - yalniz plan. Geldigi an kabul edilmeli: basvuru acilir,
   * ucret/tahsilat alinir, ISTEM dogar; cihazin calisma listesine (MWL)
   * dusecek kayit da budur. Bu yuzden cihazli randevuda "Geldi" durumu tek
   * basina yazmak yerine kabul ekranini acar.
   */
  const radyolojiKabulu = (s: ListeSatiri) => {
    b.setIstemModali({
      hastaId: Number(s.hastaId), hastaAdi: String(s.hasta ?? ''),
      // Isteyen hekim disaridan olabilir - kabul ekraninin tam hali acilir.
      disIstem: true,
      randevuId: Number(s.id),
      hizmetId: Number(s.hizmetId) || undefined,
    });
  };

  if (kod === 'randevu.geldi' && satir && Number(satir.cihazId) > 0
      && !satir.belgeId) {
    if (!Number(satir.hastaId)) { mesaj('Randevuda hasta yok.'); return true }
    radyolojiKabulu(satir);
    return true;
  }

  if (kod === 'randevu.geldi' || kod === 'randevu.gelmedi' || kod === 'randevu.iptal') {
    if (!satir) return true;
    const yeniDurum = kod === 'randevu.geldi' ? 2 : kod === 'randevu.gelmedi' ? 3 : 4;
    await guvenli(async () => {
      const mevcut = await api.kartOku('randevu', Number(satir.id));
      await api.kartGuncelle('randevu', Number(satir.id),
                             { surum: mevcut.kart.surum, kart: { durum: yeniDurum } });
      b.tazele();
    });
    return true;
  }

  // kod === 'randevu.basvuru'
  if (!satir) return true;
  // CIHAZLI (radyoloji) randevu: duz basvuru yerine kabul ekrani (317) -
  //   basvuru orada da acilir, ustune ISTEM ve accession uretilir.
  if (Number(satir.cihazId) > 0 && !satir.belgeId) {
    if (!Number(satir.hastaId)) { mesaj('Randevuda hasta yok.'); return true }
    radyolojiKabulu(satir);
    return true;
  }
  await guvenli(async () => {
    const hastaId = Number(satir.hastaId) || 0;
    const hizmetId = Number(satir.hizmetId) || 0;
    if (!hastaId) { mesaj('Randevuda hasta yok.'); return }
    // Basvuru en az bir kalemle acilir (sunucu bos belgeyi reddediyor):
    //   randevunun hizmeti yoksa once o secilmeli.
    if (!Number(satir.hizmetId)) {
      mesaj('Randevuda hizmet seçili değil — başvuru kalemi oluşturulamıyor. '
          + 'Randevu kartından "Hizmet / İşlem" seçip tekrar deneyin.');
      b.git(`/randevu/${Number(satir.id)}`);
      return;
    }
    if (satir.belgeId) {
      // Zaten donusmus: yeni belge acmak yerine mevcut basvuruyu ac - ayni
      //   randevudan iki basvuru cikmasin.
      b.setAcikBelgeId(Number(satir.belgeId));
      return;
    }
    // HASTANIN KURUMU (266) basvurunun ODEYENI olur ve FIYATI belirler (274):
    //   hasta basvurusu her zaman kurum + kampanya uzerinden. Kart okunamazsa
    //   donusum yine yapilir - kurumsuz, hasta kendi oder.
    let hastaKart: { surum?: string; durum?: unknown } | null = null;
    let odeyenKurumId: number | null = null;
    try {
      const hk = await api.kartOku('hasta', hastaId);
      hastaKart = hk.kart;
      // Kurum kartin KENDI alani degil "ozluk" detayindadir (taraf_hasta,
      //   266): kart kokunden okunursa hep bos gelir - basvuru odeyensiz ve
      //   kampanyasiz aciliyordu.
      odeyenKurumId = Number(hk.detaylar?.ozluk?.[0]?.kurumId) || null;
    } catch { /* hasta okunamazsa kurumsuz devam */ }

    // FIYAT: liste BAZ, kampanya INDIRIM (274). Baz liste belge kartinin
    //   kuralindan gelir (205: carinin listesi > varsayilan satis);
    //   kampanyanin kendi listesi varsa uc onu kullanir. Fiyat cikmazsa
    //   hizmet kartindaki fiyata dusulur.
    // Odeyen kurumun kendi listesi hastaninkini ezer (278).
    const varsayilanListe = await api.belgeVarsayilanListe(19, hastaId, odeyenKurumId);
    let fiyatListesiId = varsayilanListe.listeId ?? null;
    // KAMPANYANIN KENDI LISTESI bazi belirler (kurum sozlesmesi "TTB2018
    //   uzerinden %40" der): varsayilan satis listesi acikca gonderilirse uc
    //   onu baz alir ve kampanyanin listesi devre disi kalirdi. Belge karti da
    //   acilista ayni sirayi izliyor (BelgeKarti kampanya cozumu).
    try {
      const kmp = await api.fiyatKampanya({ tarafId: hastaId, kurumId: odeyenKurumId });
      if (kmp.fiyatListesiId) fiyatListesiId = kmp.fiyatListesiId;
    } catch { /* kampanya cozulemezse varsayilan liste kalir */ }
    const h = await api.liste('hizmet', {
      sayfa: 1, boyut: 1,
      filtre: { alan: 'id', op: 'esit', deger: hizmetId },
    });
    const kdv = Number(h.satirlar[0]?.kdv) || 0;
    let birimFiyat = Number(h.satirlar[0]?.fiyat) || 0;
    let iskonto = 0;
    let kampanyaId: number | null = null;
    let kampanyaSatirId: number | null = null;
    try {
      const f = await api.fiyatKalem({ hizmetId },
        { tarafId: hastaId, kurumId: odeyenKurumId, listeId: fiyatListesiId });
      kampanyaId = f.kampanyaId;
      if (f.listeId) fiyatListesiId = f.listeId;
      // Yuzde/tutar karari BELGE KARTIYLA AYNI yerden (belgeKalem.ts): iki
      //   yerde yazilirsa donusumdeki fatura kartta gorunenden farkli fiyatlanir.
      const y = kampanyaKalemFiyati(f);
      if (y) {
        birimFiyat = y.birimFiyat;
        iskonto = y.iskonto ?? 0;
        kampanyaSatirId = y.kampanyaSatirId ?? null;
      }
    } catch { /* fiyat cozulemezse hizmet kartindaki fiyat kalir */ }

    const y = await api.belgeEkle({
      belge: {
        // Basvuru = SATIS SIPARISI (279): ayri tur yok.
        tur: 19,
        tarafId: hastaId,
        odeyenKurumId,
        kampanyaId,
        // Basvuru BUGUNUN tarihiyle acilir: hasta simdi geldi. Randevu ileri
        //   tarihliyse sunucu "belge tarihi ileri tarihli olamaz" diyordu;
        //   randevunun kendi tarihi aciklamada duruyor.
        // YEREL an (kullanici): toISOString UTC verdigi icin belge saati TR'de
        //   3 saat geriye kayiyordu; basvuru saatinin dogru olmasi kayit kabul
        //   icin sart.
        belgeTarihi: yerelZamanDamgasi(),
        subeId: b.oturumSubeId,
        fiyatListesiId,
        aciklama: `Randevu #${satir.id}`
                  + (satir.bolumAdi ? ` · ${String(satir.bolumAdi)}` : ''),
      },
      // tur = 2 (hizmet): sunucu tur ile urun bagini karsilastiriyor
      //   (1 stok / 2 hizmet / 3 masraf).
      satirlar: [{ sira: 1, tur: 2, hizmetId, adet: 1, birimFiyat, kdv,
                   iskonto, kampanyaSatirId }],
    });
    const belgeId = Number((y as { belge?: { id?: number } }).belge?.id) || 0;
    // ADAY hasta (266) basvuruya donusunce AKTIF olur: randevu sirasinda hizli
    //   acilmis kayit, hasta gelince gercek hastaya doner.
    try {
      if (hastaKart && Number(hastaKart.durum) === 2) {
        await api.kartGuncelle('hasta', hastaId,
                               { surum: hastaKart.surum, kart: { durum: 1 } });
      }
    } catch { /* durum guncellenemezse donusum yine de tamamlanir */ }
    // Randevu artik basvuruya bagli ve "Geldi" - hasta muayeneye alindi.
    //   Kart guncellemesi SURUM ister (iyimser kilit): once oku.
    const mevcut = await api.kartOku('randevu', Number(satir.id));
    await api.kartGuncelle('randevu', Number(satir.id),
                           { surum: mevcut.kart.surum, kart: { belgeId, durum: 2 } });
    b.tazele();
    // Basvuru kartI MODAL acilir (belge kartinin rotasi yok, her listede bu
    //   bilesenle aciliyor).
    if (belgeId) b.setAcikBelgeId(belgeId);
  });
  return true;
}
