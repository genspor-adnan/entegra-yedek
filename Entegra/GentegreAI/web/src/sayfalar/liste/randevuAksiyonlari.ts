import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { hataMetni } from '../../api/sozlesme';
import type { ListeSatiri } from '../../api/sozlesme';
import type { ErtelenecekRandevu } from '../../bilesenler/RandevuErtelePenceresi';
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
                      randevuId?: number; hizmetId?: number;
                      gonderen?: { id: number; ad: string } }): void;
  /** Acilan/var olan basvuru MODAL gosterilir - belge kartinin rotasi yok. */
  setAcikBelgeId(id: number): void;
  /** Belge olusturmada sube: oturumun calisma subesi. */
  oturumSubeId?: number;
  /** ERTELE (1119): erteleme penceresini acar. */
  setErtele?(r: ErtelenecekRandevu): void;
  /**
   * ADAY HASTAYI TAMAMLA (17.10.2026): hasta kartını açar; kaydedilince { id }, aynı kimlikte mevcut
   * hastaya geçilirse { id, mevcut: true }, kapatılırsa null.
   */
  hastaTamamla?(hastaId: number): Promise<{ id: number; mevcut?: boolean } | null>;
}

export async function randevuAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: RandevuBaglam,
): Promise<boolean> {
  if (kod !== 'randevu.geldi' && kod !== 'randevu.gelmedi'
      && kod !== 'randevu.iptal' && kod !== 'randevu.basvuru' && kod !== 'randevu.ertele'
      && kod !== 'randevu.geri-al') return false;

  // GERİ AL (kullanıcı 17.10.2026: "yanlışlıkla geldi/gelmedi/iptal işaretlersem nasıl geri alırım"):
  //   durum Planlandı'ya döner; saat yeniden denetlenir (tetik), hatırlatma kart güncellemesinde kurulur.
  if (kod === 'randevu.geri-al') {
    if (!satir) return true;
    const d = Number(satir.durum);
    if (d === 1) { mesaj('Randevu zaten planlandı durumunda.'); return true }
    if (d === 5) { mesaj('Ertelenen randevu geri alınmaz - ertelemeyle açılan yeni randevuyu iptal edin.'); return true }
    if (satir.belgeId) { mesaj('Randevu başvuruya dönüşmüş - önce başvuruyu iptal edin.'); return true }
    if (!await onay(`Randevu "${String(satir.durumAdi ?? '')}" durumundan Planlandı'ya geri alınsın mı?`)) return true;
    await guvenli(async () => {
      const mevcut = await api.kartOku('randevu', Number(satir.id));
      await api.kartGuncelle('randevu', Number(satir.id), { surum: mevcut.kart.surum, kart: { durum: 1 } });
      b.tazele();
    });
    return true;
  }

  // ERTELE (1119): yalniz planlanmis randevu; pencere yeni saati ve nedeni sorar.
  if (kod === 'randevu.ertele') {
    if (!satir) return true;
    if (Number(satir.durum) !== 1) { mesaj('Yalnız planlanmış randevu ertelenir.'); return true }
    b.setErtele?.({
      id: Number(satir.id), hasta: String(satir.hasta ?? ''),
      hekimId: Number(satir.hekimId) || null, hekimAdi: String(satir.hekim ?? '') || undefined,
      cihazId: Number(satir.cihazId) || null, cihazAdi: String(satir.cihaz ?? '') || undefined,
      bolum: Number(satir.bolum) || null, sureDk: Number(satir.sureDk) || 15,
      tarih: String(satir.tarih ?? '').slice(0, 10), saat: String(satir.saat ?? ''),
    });
    return true;
  }

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
      // GÖNDEREN HEKİM (1120): randevuda seçilen dış hekim istemin isteyeni olur.
      gonderen: Number(s.gonderenId) ? { id: Number(s.gonderenId), ad: String(s.gonderen ?? '') } : undefined,
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
  // CİHAZLI randevu da BAŞVURUYA döner (kullanıcı 17.10.2026: "başvuruya dönüştür deyince radyoloji
  //   istem ekranı değil başvuru sekmesi açılmalı, buradaki bilgiler oraya geçmeli"): istem / accession
  //   başvuru kartının kendi istem penceresinden yapılır. Kabul ekranı yalnız "Geldi"de (317) kalır.
  await guvenli(async () => {
    let hastaId = Number(satir.hastaId) || 0;
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
      b.git(`/basvuru/${Number(satir.belgeId)}`);
      return;
    }
    // HASTANIN KURUMU (266) basvurunun ODEYENI olur ve FIYATI belirler (274):
    //   hasta basvurusu her zaman kurum + kampanya uzerinden. Kart okunamazsa
    //   donusum yine yapilir - kurumsuz, hasta kendi oder.
    // HASTANIN KURUMU (266) basvurunun ODEYENI olur ve FIYATI belirler (274) - kurum "ozluk"
    //   detayindadir (taraf_hasta). Kart okunamazsa donusum kurumsuz yapilir (hasta kendi oder).
    const hastaOku = async (hid: number) => {
      try {
        const hk = await api.kartOku('hasta', hid);
        return { kart: hk.kart as { surum?: string; durum?: unknown }, kurumId: Number(hk.detaylar?.ozluk?.[0]?.kurumId) || null };
      } catch { return { kart: null, kurumId: null } }
    };
    let hasta = await hastaOku(hastaId);

    // ADAY HASTA AKTİFE (kullanıcı 17.10.2026: "hasta kartı da adaydan aktife geçmeli · hasta kartındaki
    //   zorunlu alanları tamamlamak gerekiyor - kimlik no, cins, doğum · aynı kimlik no ile kart varsa
    //   açılmamalı"): HASTA KARTI açılır, kendi kurallarıyla (zorunlu alanlar + kimlik no + mükerrer
    //   kimlik) kaydedilir. Aynı kimlikte aktif hasta varsa kart kaydetmez, "mevcut karta geç" der -
    //   seçilirse randevu O HASTAYA bağlanır ve başvuru onunla açılır. Kart kapatılırsa başvuru açılmaz.
    if (hasta.kart && Number(hasta.kart.durum) === 2) {
      if (!b.hastaTamamla) { mesaj('Hasta aday kayıtlı - önce hasta kartını tamamlayıp aktif yapın.'); return }
      const r = await b.hastaTamamla(hastaId);
      if (!r) return;
      if (r.mevcut && r.id !== hastaId) {
        // Aynı kimlikte gerçek kart var: adayın BÜTÜN randevuları ona geçer, aday kart silinir.
        const t = await api.randevuAdayTasi(hastaId, r.id);
        try { await api.kartSil('hasta', hastaId) }
        catch (h) { mesaj(`${t.tasinan} randevu gerçek karta taşındı; aday kart silinemedi: ${hataMetni(h)}`) }
        hastaId = r.id;
      } else {
        const hk = await api.kartOku('hasta', hastaId);
        if (Number(hk.kart.durum) === 2)
          await api.kartGuncelle('hasta', hastaId, { surum: hk.kart.surum, kart: { durum: 1 } });
      }
      hasta = await hastaOku(hastaId);
    }
    const odeyenKurumId = hasta.kurumId;

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
        // GÖNDEREN ve BÖLÜM randevudan (17.10.2026): gönderen (dış) doktor, yoksa randevunun doktoru.
        personelId: Number(satir.gonderenId) || Number(satir.hekimId) || null,
        bolumId: Number(satir.bolum) || null,
        aciklama: `Randevu #${satir.id}`
                  + (satir.bolumAdi ? ` · ${String(satir.bolumAdi)}` : ''),
      },
      // tur = 2 (hizmet): sunucu tur ile urun bagini karsilastiriyor
      //   (1 stok / 2 hizmet / 3 masraf).
      satirlar: [{ sira: 1, tur: 2, hizmetId, adet: 1, birimFiyat, kdv,
                   iskonto, kampanyaSatirId }],
    });
    const belgeId = Number((y as { belge?: { id?: number } }).belge?.id) || 0;
    // ADAY -> AKTİF yukarıda, başvurudan ÖNCE yapıldı (eksik bilgi sorularak).
    // Randevu artik basvuruya bagli ve "Geldi" - hasta muayeneye alindi.
    //   Kart guncellemesi SURUM ister (iyimser kilit): once oku.
    const mevcut = await api.kartOku('randevu', Number(satir.id));
    await api.kartGuncelle('randevu', Number(satir.id),
                           { surum: mevcut.kart.surum, kart: { belgeId, durum: 2 } });
    b.tazele();
    // BAŞVURU KARTI KENDİ SEKMESİNDE (kullanıcı 17.10.2026; kart sekmesi deseni): Başvuru Listesi'nin
    //   kart rotası - ücret, istem ve tahsilat oradan sürer.
    if (belgeId) b.git(`/basvuru/${belgeId}`);
  });
  return true;
}
