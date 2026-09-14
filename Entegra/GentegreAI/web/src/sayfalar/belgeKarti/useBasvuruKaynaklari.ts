import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { ListeIstegi } from '../../api/sozlesme';

/**
 * BASVURU KARTININ COMBO LISTELERI (296/297/358).
 *
 * Kartta bes ayri `useEffect` bu listeleri cekiyordu; hepsi ayni desendeydi
 * (basvuru mu · zaten dolu mu · listele · hata olursa bos birak) ve kartin
 * ortasinda 110 satir yer tutuyordu. Tek yere alindi: kart yalniz sonucu
 * okuyor.
 *
 * ORTAK KURAL: liste okunamazsa combo BOS kalir, kayit ENGELLENMEZ. Bir combo
 * hatasi yuzunden hasta kaydi durmamali - alan elle secilebilir ya da bos
 * gecilebilir.
 */

export interface Secenek { id: number; ad: string }
export interface KurumSecenegi extends Secenek { tur: number }
/** Gorevli kendi bolumunu tasir: kisi secilince Bolum alani ondan doldurulur. */
export interface GorevliSecenegi extends Secenek { bolumId: number | null }

export interface BasvuruKaynaklari {
  /** Anlasmali kurumlar (odeyen kurum combosu) - `tur` 1 = Özel. */
  kurumlar: KurumSecenegi[];
  /** Randevu verilebilen bolumler (poliklinik/klinik). */
  bolumler: Secenek[];
  /** Aktif depolar - basvuru dip bolumundeki depo combosu. */
  depolar: Secenek[];
  /** Sorulan hekim/gonderen adaylari - rol ve bolume gore suzulur. */
  gorevliler: GorevliSecenegi[];
  /** Protokol numarasini KULLANICI mi yazar (numara sablonu, 358). */
  protokolElle: boolean;
}

/** Tek satir okumak icin kisa istek - "bu kayit var mi / degeri ne". */
const tekSatir = (alan: string, deger: number): ListeIstegi => ({
  sayfa: 1, boyut: 1,
  filtre: { op: 'and', kosullar: [{ alan, op: 'esit', deger }] },
});

export function useBasvuruKaynaklari(
  basvuruMu: boolean,
  bolumId: number | null,
  hekimRolu: number | undefined,
): BasvuruKaynaklari {
  const [kurumlar, setKurumlar] = useState<KurumSecenegi[]>([]);
  const [bolumler, setBolumler] = useState<Secenek[]>([]);
  const [depolar, setDepolar] = useState<Secenek[]>([]);
  const [gorevliler, setGorevliler] = useState<GorevliSecenegi[]>([]);
  const [protokolElle, setProtokolElle] = useState(false);

  // Protokol numarasini kim verir (358): basvuru turunun numara sablonu.
  useEffect(() => {
    if (!basvuruMu) return;
    void (async () => {
      try {
        const y = await api.liste('numara-basvuru', tekSatir('durum', 1));
        setProtokolElle(Number(y.satirlar[0]?.elleGirilir ?? 0) === 1);
      } catch { /* sablon okunamazsa otomatik varsayilir - numara yine verilir */ }
    })();
  }, [basvuruMu]);

  /**
   * ODEYEN KURUM / BOLUM / DEPO TEK ISTEKTE (kullanici: "banko görevlisi
   * olarak girdim… ödeyen kurum listesi gelmedi combo").
   *
   * Uc liste KART KAYNAKLARINDAN cekiliyordu (`/api/liste/kurum`,
   * `departman`, `depo`) ve her biri KENDI kaynak yetkisini istiyordu. Banko
   * rolunde o yetkiler yok; istek 403 donuyor, catch bloklari hatayi yutup
   * combo'yu bos birakiyordu - gorevli basvuruyu acamiyor, sebebini de
   * goremiyordu. Artik tek uc (`/api/belge/basvuru-kaynaklari`) ve yetkisi
   * BELGE GOR: basvuru acabilen kisi odeyen kurumu secebilmeli.
   */
  useEffect(() => {
    if (!basvuruMu || kurumlar.length > 0) return;
    void (async () => {
      try {
        const y = await api.basvuruKaynaklari();
        setKurumlar(y.kurumlar.map(k => ({ id: k.id, ad: k.ad, tur: k.tur })));
        // Alt birim onekini ("— Dahiliye") combo'da gostermeyiz: agac
        //   gorunumu Bölüm/Görev ekranina ait.
        setBolumler(y.bolumler.map(b => ({ id: b.id, ad: b.ad.replace(/^—\s*/, '') })));
        setDepolar(y.depolar);
      } catch { /* kaynaklar okunamazsa combolar bos kalir, kayit engellenmez */ }
    })();
  }, [basvuruMu, kurumlar.length]);

  /**
   * BASVURUDA SORULAN HEKIM (361): liste PRIM ROL ISARETINDEN gelir ve hangi
   * ROLUN adaylari oldugunu KURUM TIPI belirler (sunucu: fn_basvuru_hekim_rolu)
   *   · Laboratuvar / Görüntüleme merkezi -> DIS DOKTORLARDAN "Gönderen"
   *   · Muayenehane / Dal merkezi / Tıp merkezi / Hastane -> personelden "Yapan"
   * Kural sunucuda oldugu icin kart kurum tipini bilmez; kurum tipi degisince
   * burada kod degismez.
   *
   * Bolum SECILIYSE o bolumle sinirlanir, BOS ise hepsi gelir (297, kullanici:
   * "bolum secilmeden dr listesine tum doktorlar gelir"). Her satir kendi
   * bolumunu tasir - kisi secilince bolum ondan doldurulur.
   */
  useEffect(() => {
    if (!basvuruMu) { setGorevliler([]); return }
    let iptal = false;
    void (async () => {
      try {
        // KAYNAK KURUM PROFILINE GORE, PRIM ROLU ARANMADAN (578, kullanici:
        //   "prim alsa da almasa da… profil laboratuvar ve/veya görüntüleme
        //   merkezi ise dış doktorlar, değilse randevu verilebilir personel").
        //   Karar SUNUCUDA (`v_basvuru_hekim`); ekran yalnizca bolume gore
        //   suzer. Eskiden liste `prim-rol-aday`dan geliyordu ve prim rolu
        //   isaretlenmemis hekim basvuruda hic gorunmuyordu.
        const kosullar = [
          { alan: 'durum', op: 'esit' as const, deger: 1 },
          ...(bolumId ? [{ alan: 'bolumId', op: 'esit' as const, deger: bolumId }] : []),
        ];
        const y = await api.liste('basvuru-hekim', {
          sayfa: 1, boyut: 500, sirala: [{ alan: 'ad', yon: 'asc' }],
          filtre: { op: 'and' as const, kosullar },
        });
        if (!iptal) setGorevliler(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.ad ?? ''),
          bolumId: r.bolumId ? Number(r.bolumId) : null })));
      } catch { if (!iptal) setGorevliler([]) }
    })();
    return () => { iptal = true };
  }, [basvuruMu, bolumId, hekimRolu]);

  return { kurumlar, bolumler, depolar, gorevliler, protokolElle };
}
