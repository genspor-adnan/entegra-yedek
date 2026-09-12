import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import type { SatirDurumu } from '../belgeSatir';
import { kampanyaFiyatiUygula } from '../belgeKalem';

/**
 * BELGENIN FIYAT KARARLARI (205/207/274/289/291) TEK YERDE.
 *
 * Fiyat listesi, kampanya, pay modu ve provizyon uygulamasi kartin icine
 * dagilmisti; oysa hepsi TEK SORUYU cevapliyor: "bu satir kaca yazilacak".
 * Dagildikca kural kacmaya basladi - or. odeyen kurum degisince kampanyayi
 * cozup satirlari yeniden fiyatlamayi unutmak, belgeyi "SGK anlasmasi"
 * fiyatiyla ozel hastaya kesmek demekti.
 *
 * Kart yalniz sonucu (liste kimligi, kampanya adi, pay modu) gosterir ve
 * kullanicinin eylemlerini (`listeDegisti`) cagirir. ODEME DAGILIMI
 * artik SUNUCUDA (470/478): kart `POST /api/belge/{id}/dagit` cagirir.
 */

export interface Secenek {
  id: number; ad: string;
  /**
   * TARIFE TIPI (586): 1 Özel · 2 TTB/HUV · 3 SUT. Ücret penceresi buna göre
   * davranır - TTB/SUT'ta satırın hastaya bakan yüzü KATKI PAYIDIR, iskonto
   * da onun üzerinden işler (kullanıcı).
   */
  tarifeTipi?: number;
}

export interface FiyatlandirmaGirdisi {
  /** Kayitli belge kimligi - 0/undefined ise YENI belge (kampanya yazilir). */
  belgeId?: number;
  tur: number;
  alisMi: boolean;
  cariId: number | null;
  odeyenKurumId: number | null;
  /** Basvuruda secili police (588) - kurumun tarifesi ondan cozulur. */
  sozlesmeId?: number | null;
  /**
   * Basvurudaki "SGK kullanilsin" isareti (597). Rotayi belirledigi icin
   * SATIR YENIDEN FIYATLANIRKEN de gecmeli (601): gecmezse sunucu rotayi
   * varsayilanla cozer, donen cevapta `sgkGerekli` false gelir ve
   * `kampanyaFiyatiUygula` satirdaki SUT bedelini SILER.
   */
  sgkKullan?: number | null;
  satirlar: SatirDurumu[];
  setSatirlar(s: SatirDurumu[] | ((o: SatirDurumu[]) => SatirDurumu[])): void;
}

export function useBelgeFiyatlandirma(g: FiyatlandirmaGirdisi) {
  const { belgeId, tur, alisMi, cariId, odeyenKurumId, sozlesmeId, sgkKullan,
          satirlar, setSatirlar } = g;

  const [fiyatListeleri, setFiyatListeleri] = useState<Secenek[]>([]);
  /**
   * Belgenin fiyat listesi. "Ham" setter DOGRUDAN yazar (belge okunurken ve
   * kampanya cozulurken); kullanici secimi `listeDegisti` uzerinden gecer -
   * o satirlari da yeniden fiyatlar.
   */
  const [fiyatListesiId, setFiyatListesiId] = useState<number | null>(null);
  const [kampanyaId, setKampanyaId] = useState<number | null>(null);
  const [kampanyaAdi, setKampanyaAdi] = useState('');
  /**
   * PAY MODU (291): 1 karsilama orani (ozel sigorta) · 2 katilim payi (SGK).
   * Kurumun ozelligidir, belgeye YAZILMAZ - her acilista kurumdan cozulur.
   */

  /**
   * Belge YONUNDEKI listeler. Tur/yon degisince yeniden cozulur: alis
   * belgesinde alis listeleri, satista satis.
   */
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        // YON SUZMESI SART: alis belgesinde satis listesi secilememeli -
        //   satis fiyatiyla mal girisi yapmak maliyeti bozar.
        const y = await api.liste('fiyat-listesi', {
          sayfa: 1, boyut: 200,
          filtre: { op: 'and', kosullar: [
            // 'durum' HAM KOD kolonudur (sayi) - metin 'Aktif' gondermek
            //   sunucuda tip hatasiyla 500 veriyordu, kutu hic dolmuyordu.
            { alan: 'durum',   op: 'esit', deger: 1 },
            { alan: 'yonKodu', op: 'esit', deger: alisMi ? 1 : 2 },
          ] },
        });
        if (iptal) return;
        setFiyatListeleri(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.ad ?? ''),
          tarifeTipi: r.tarifeTipi != null ? Number(r.tarifeTipi) : undefined,
        })));
      } catch { if (!iptal) setFiyatListeleri([]) }
    })();
    return () => { iptal = true };
  }, [alisMi]);

  // Acilista / cari degisince belgenin listesi cariden cozulur. KAYITLI
  //   belgede DOKUNULMAZ: belge hangi listeyle kesildiyse onu tasir.
  //
  //
  // KAYITLI BELGEDE ACILISTA COZMEK DENENDI VE GERI ALINDI (602): "kurum SGK
  //   secili ama ozel fiyat geliyor" sikayetinin kaynagi bu degildi - sozlesme
  //   kaydinda SUT listesi bostu (601). Kurum/police degisince liste zaten
  //   tazeleniyor (`kurumListesiCoz`). Acilista yeniden cozmek ise karti
  //   kullanici hic dokunmadan "degismis" gosteriyor ve Kapat'ta gereksiz
  //   "kaydetmediniz" sorusu cikiyordu (basvuruKapat testi).
  useEffect(() => {
    if (belgeId || !cariId) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.belgeVarsayilanListe(tur, cariId, odeyenKurumId, sozlesmeId);
        if (!iptal) setFiyatListesiId(y.listeId ?? null);
      } catch { /* liste kurulmamis olabilir - fiyatlar kart fiyatindan gelir */ }
    })();
    return () => { iptal = true };
  }, [belgeId, tur, cariId, odeyenKurumId, sozlesmeId]);

  /**
   * KAMPANYAYI COZ ve baslik alanlarina isle (274/291). Uc yerden cagrilir
   * (yeni belge acilisi, kayitli belgede pay modu, odeyen kurum degisimi);
   * uceye ayri ayri yazilinca "modu da set etmeyi unutma" hatasi kacinilmazdi.
   *
   * @param kampanyaYaz kampanya kimligini/listesini de yaz. KAYITLI belgede
   *   FALSE gecilir: belge hangi kampanyayla kesildiyse onu tasir, yalniz
   *   PAY MODU tazelenir (mod kampanyanin degil KURUMUN ozelligi, belgeye
   *   yazilmaz - kayitli basvuruda provizyon dugmesi de dogru davranmali).
   * @returns kampanyanin fiyat listesi (varsa) - cagiran satirlari o listeyle
   *   yeniden fiyatlayabilsin.
   */
  async function kampanyaCoz(
    kurumId: number | null, kampanyaYaz: boolean,
  ): Promise<number | null> {
    try {
      const y = await api.fiyatKampanya({
        tarafId: kampanyaYaz ? cariId : null, kurumId,
      });
      if (!kampanyaYaz) return null;

      setKampanyaId(y.kampanyaId);
      setKampanyaAdi(y.kampanyaId ? `${y.kod ? y.kod + ' · ' : ''}${y.ad}` : '');
      // Kampanyanin kendi fiyat listesi varsa belgenin listesi ONA cekilir:
      //   baslik neyle fiyatlandigini dogru gostersin (kullanici degistirebilir).
      if (y.fiyatListesiId) { setFiyatListesiId(y.fiyatListesiId); return y.fiyatListesiId }
      return null;
    } catch {
      if (kampanyaYaz) { setKampanyaId(null); setKampanyaAdi('') }
      return null;
    }
  }

  /**
   * KAMPANYA COZUMU (274). Odeyen kurum varsa kampanya ONUN sozlesmesinden
   * gelir - odemeyi yapan taraf fiyati belirler; yoksa carinin kendi
   * kampanyasi, o da yoksa genel kampanya.
   *
   * KAYITLI belgede kampanya DEGISMEZ - odeme dagilimi sunucuda (478).
   */
  useEffect(() => {
    const kampanyaYaz = !belgeId;
    if (kampanyaYaz && !cariId && !odeyenKurumId) {
      setKampanyaId(null); setKampanyaAdi(''); return;
    }
    if (!kampanyaYaz && !odeyenKurumId) return;
    void kampanyaCoz(odeyenKurumId, kampanyaYaz);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [belgeId, cariId, odeyenKurumId]);

  /**
   * Butun satirlari verilen liste + gecerli kampanya ile yeniden fiyatlar.
   *
   * Liste degisimi ve ODEYEN KURUM degisimi ayni yolu kullanir: kurum degisince
   * gecerli kampanya da degisir - satirlar eski kurumun fiyatinda kalirsa belge
   * "SGK anlasmasi" fiyatiyla Ozel Yasam'a kesilirdi.
   *
   * Fiyatlama EKRANDA yapilir, Kaydet kalicilastirir. Sunucudaki
   * `fn_belge_fiyatlandir` KALDIRILDI: durum=0 butun normal belgelerde "Kesin"
   * oldugundan hepsini reddediyordu, ustelik yalniz birim_fiyat yazip
   * tutar/matrah/genel_toplami bayat birakiyordu (satir matematigi banker's
   * rounding ile BelgeHesap'ta - PG round'u farkli yuvarlar, kurus paritesi
   * DB'de tutturulamaz). Kaydetme hatti zaten tum toplamlari yeniden hesaplar.
   */
  async function satirlariYenidenFiyatla(
    listeId: number | null, kurumId: number | null, kaynakAdi: string,
  ) {
    if (!listeId) return;
    await guvenli(async () => {
      let degisen = 0, bulunamayan = 0;
      const yeniSatirlar = await Promise.all(satirlar.map(async r => {
        if (!r.stokId && !r.hizmetId) return r;
        const f = await api.fiyatKalem(
          r.stokId ? { stokId: r.stokId } : { hizmetId: r.hizmetId! },
          // SOZLESME VE SGK ISARETI BURADA DA GECER (601): satir eklerken
          //   (stokSecimi) geciyordu, toplu yeniden fiyatlamada gecmiyordu -
          //   liste degistirince satirlarin SUT bedeli sessizce siliniyordu.
          { tarafId: cariId, kurumId, listeId,
            sozlesmeId: sozlesmeId ?? null, sgkKullan: sgkKullan ?? null });
        const y = kampanyaFiyatiUygula(r, f);
        if (y === r) bulunamayan++; else degisen++;
        return y;
      }));
      setSatirlar(yeniSatirlar);
      mesaj(`${degisen} satırın fiyatı ${kaynakAdi} güncellendi.`
          + (bulunamayan ? ` ${bulunamayan} kalem listede bulunamadı, fiyatı DEĞİŞMEDİ.` : '')
          + (belgeId && degisen ? ' Kaydet ile kalıcı olur.' : ''));
    });
  }

  /** Kullanici baslikta liste degistirdi: satirlar o listeyle yeniden fiyatlanir. */
  async function listeDegisti(yeni: number | null) {
    setFiyatListesiId(yeni);
    await satirlariYenidenFiyatla(yeni, odeyenKurumId, 'listeden');
  }

  /**
   * ODEYEN KURUMUN LISTESI (495, kullanici: "ödeyen kurum seçilince fiyat
   * listesi otomatik gelsin"): kurumun yururlukteki SOZLESMESINDEKI liste
   * sunucudan cozulur (fn_belge_varsayilan_liste). Kampanyanin kendi listesi
   * varsa O oncelikli - kampanya sozlesmenin ustune yazilan anlasmadir.
   *
   * KAYITLI belgede de calisir: kurum degistirildiyse tarife de degismistir;
   * acilista dokunulmaz (belge hangi listeyle kesildiyse onu tasir).
   */
  async function kurumListesiCoz(kurumId: number | null,
                                 police?: number | null): Promise<number | null> {
    if (!cariId) return null;
    try {
      const y = await api.belgeVarsayilanListe(tur, cariId, kurumId,
                                               police !== undefined ? police : sozlesmeId);
      return y.listeId ?? null;
    } catch { return null }   // liste kurulmamis olabilir - kart fiyati kalir
  }

  /**
   * SECILI LISTENIN TARIFE TIPI (586) - 1 Özel · 2 TTB/HUV · 3 SUT.
   * Ücret penceresi bunu sorar: TTB/SUT'ta "Katkı Fiyatı" kutusu açılır ve
   * iskonto katkı üzerinden işler.
   */
  const tarifeTipi = fiyatListeleri.find(l => l.id === fiyatListesiId)?.tarifeTipi ?? 0;

  return {
    fiyatListeleri, fiyatListesiId, setFiyatListesiId, kurumListesiCoz, tarifeTipi,
    kampanyaId, setKampanyaId, kampanyaAdi, setKampanyaAdi,
    kampanyaCoz, satirlariYenidenFiyatla, listeDegisti,
  };
}
