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

  // BASVURU (249): odeyen kurum combosu - yalniz anlasmali kurumlar
  //   (taraf.kurum = 1), tum cariler degil.
  useEffect(() => {
    if (!basvuruMu || kurumlar.length > 0) return;
    void (async () => {
      try {
        const y = await api.liste('kurum', {
          sayfa: 1, boyut: 500, sirala: [{ alan: 'unvan', yon: 'asc' }],
          filtre: { op: 'and', kosullar: [{ alan: 'durum', op: 'esit', deger: 1 }] },
        });
        setKurumlar(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.unvan ?? ''), tur: Number(r.tur ?? 0) })));
      } catch { /* kurum listesi okunamazsa combo bos kalir, kayit engellenmez */ }
    })();
  }, [basvuruMu, kurumlar.length]);

  // BASVURU (296): randevu verilebilen BOLUMLER - basvurunun yapildigi
  //   poliklinik/klinik. Randevu ekraniyla ayni kume.
  useEffect(() => {
    if (!basvuruMu || bolumler.length > 0) return;
    void (async () => {
      try {
        const y = await api.liste('departman', {
          sayfa: 1, boyut: 300, sirala: [{ alan: 'ad', yon: 'asc' }],
          filtre: { op: 'and', kosullar: [
            { alan: 'durum', op: 'esit', deger: 1 },
            { alan: 'randevuVerilebilir', op: 'esit', deger: 1 },
          ] },
        });
        // Departman kaynagi alt birimleri "— Dahiliye" gibi GIRINTILI dondurur
        //   (257, Bölüm/Görev ekranindaki agac gorunumu icin). Combo'da agac
        //   yok - onek kirpilir, yoksa her bolum tire ile basliyormus gibi durur.
        setBolumler(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.ad ?? '').replace(/^—\s*/, '') })));
      } catch { /* bolum listesi okunamazsa combo bos kalir, kayit engellenmez */ }
    })();
  }, [basvuruMu, bolumler.length]);

  // Basvuruda depo combosu (296) icin aktif depolar.
  useEffect(() => {
    if (!basvuruMu || depolar.length > 0) return;
    void (async () => {
      try {
        const y = await api.liste('depo', {
          sayfa: 1, boyut: 200, sirala: [{ alan: 'ad', yon: 'asc' }],
          filtre: { alan: 'durum', op: 'esit', deger: 1 },
        });
        setDepolar(y.satirlar.map(r => ({ id: Number(r.id), ad: String(r.ad ?? '') })));
      } catch { /* depo listesi okunamazsa combo bos kalir */ }
    })();
  }, [basvuruMu, depolar.length]);

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
