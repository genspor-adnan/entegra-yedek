import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor } from '../../bilesenler/mesaj';
import { hamSayi } from '../../bilesenler/bicim';
import type { SatirDurumu } from '../belgeSatir';
import { kampanyaFiyatiUygula } from '../belgeKalem';
import { karsilamaUygula, katilimUygula } from './provizyonPaylari';

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
 * kullanicinin eylemlerini (`listeDegisti`, `provizyonUygula`) cagirir.
 */

export interface Secenek { id: number; ad: string }

export interface FiyatlandirmaGirdisi {
  /** Kayitli belge kimligi - 0/undefined ise YENI belge (kampanya yazilir). */
  belgeId?: number;
  tur: number;
  alisMi: boolean;
  cariId: number | null;
  odeyenKurumId: number | null;
  satirlar: SatirDurumu[];
  setSatirlar(s: SatirDurumu[] | ((o: SatirDurumu[]) => SatirDurumu[])): void;
}

export function useBelgeFiyatlandirma(g: FiyatlandirmaGirdisi) {
  const { belgeId, tur, alisMi, cariId, odeyenKurumId, satirlar, setSatirlar } = g;

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
  const [paylasimModu, setPaylasimModu] = useState(1);

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
        setFiyatListeleri(y.satirlar.map(r => ({ id: Number(r.id), ad: String(r.ad ?? '') })));
      } catch { if (!iptal) setFiyatListeleri([]) }
    })();
    return () => { iptal = true };
  }, [alisMi]);

  // Acilista / cari degisince belgenin listesi cariden cozulur. KAYITLI
  //   belgede DOKUNULMAZ: belge hangi listeyle kesildiyse onu tasir.
  useEffect(() => {
    if (belgeId || !cariId) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.belgeVarsayilanListe(tur, cariId, odeyenKurumId);
        if (!iptal) setFiyatListesiId(y.listeId ?? null);
      } catch { /* liste kurulmamis olabilir - fiyatlar kart fiyatindan gelir */ }
    })();
    return () => { iptal = true };
  }, [belgeId, tur, cariId, odeyenKurumId]);

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
      setPaylasimModu(y.paylasimModu ?? 1);
      if (!kampanyaYaz) return null;

      setKampanyaId(y.kampanyaId);
      setKampanyaAdi(y.kampanyaId ? `${y.kod ? y.kod + ' · ' : ''}${y.ad}` : '');
      // Kampanyanin kendi fiyat listesi varsa belgenin listesi ONA cekilir:
      //   baslik neyle fiyatlandigini dogru gostersin (kullanici degistirebilir).
      if (y.fiyatListesiId) { setFiyatListesiId(y.fiyatListesiId); return y.fiyatListesiId }
      return null;
    } catch {
      if (kampanyaYaz) { setKampanyaId(null); setKampanyaAdi('') } else setPaylasimModu(1);
      return null;
    }
  }

  /**
   * KAMPANYA COZUMU (274). Odeyen kurum varsa kampanya ONUN sozlesmesinden
   * gelir - odemeyi yapan taraf fiyati belirler; yoksa carinin kendi
   * kampanyasi, o da yoksa genel kampanya.
   *
   * KAYITLI belgede kampanya DEGISMEZ; o durumda yalniz pay modu okunur.
   */
  useEffect(() => {
    const kampanyaYaz = !belgeId;
    if (kampanyaYaz && !cariId && !odeyenKurumId) {
      setKampanyaId(null); setKampanyaAdi(''); setPaylasimModu(1); return;
    }
    if (!kampanyaYaz && !odeyenKurumId) { setPaylasimModu(1); return }
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
          { tarafId: cariId, kurumId, listeId });
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
   * PROVIZYON UYGULA (289): kurumun karsilama oranini butun satirlara isler.
   * Tutarlar EKRANDA hesaplanir, Kaydet kalicilastirir - liste degisiminde
   * oldugu gibi. Oran 0 verilirse tamami hastaya yazilir (kendi oder).
   */
  async function provizyonUygula() {
    // KATILIM PAYI MODU (291, SGK): oran sorulmaz. Her satir KENDI katilim
    //   payiyla bolunur (fiyat listesinden kalemle birlikte gelir); kullanici
    //   tek tip bir tutar dayatmak isterse kutuya yazar.
    if (paylasimModu === 2) {
      const cevapKatki = await metinSor(
        'Katılım payı (TL) — boş bırakılırsa her satırın kendi katılım payı uygulanır',
        '', 'Katılım payı');
      if (cevapKatki === null) return;
      const elle = cevapKatki.trim() === '' ? null : Math.max(0, hamSayi(cevapKatki));

      // Yeni satirlar ONCE hesaplanir: toplami setSatirlar geri cagriminda
      //   biriktirmek mesaji "0.00" gosteriyordu (state guncellemesi ertelenir).
      const { satirlar: yeniler, toplamHasta } = katilimUygula(satirlar, elle);
      setSatirlar(yeniler);
      mesaj(`Katılım payı uygulandı: hastadan ${toplamHasta.toFixed(2)} TL, `
          + 'kalanı kuruma. Kaydet ile kalıcı olur.');
      return;
    }

    // Varsayilan olarak KURUMUN sozlesmedeki orani gelir - hekim/kayit
    //   gorevlisi provizyon farkliysa degistirir.
    const cevap = await metinSor(
      'Kurumun karşılama oranı (%) — 0 girilirse tamamı hastaya yazılır',
      String(satirlar.find(r => hamSayi(r.karsilama ?? '0') > 0)?.karsilama ?? ''),
      'Karşılama %');
    if (cevap === null || cevap.trim() === '') return;
    const oran = Math.min(100, Math.max(0, hamSayi(cevap)));

    setSatirlar(eski => karsilamaUygula(eski, oran).satirlar);
    mesaj(`Karşılama oranı %${oran} uygulandı. Kaydet ile kalıcı olur.`);
  }

  return {
    fiyatListeleri, fiyatListesiId, setFiyatListesiId,
    kampanyaId, setKampanyaId, kampanyaAdi, setKampanyaAdi, paylasimModu,
    kampanyaCoz, satirlariYenidenFiyatla, listeDegisti, provizyonUygula,
  };
}
