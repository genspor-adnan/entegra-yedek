import {
  kdvCarpan,
  payKalan as hesapPayKalan,
  payKalanDahil as hesapPayKalanDahil,
  tahsilDahil as hesapTahsilDahil,
} from '../sayfalar/belgeDonusumHesap';
import { Fragment, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { type AcikSatir, type BelgeYaniti, hataMetni } from '../api/sozlesme';
import { Modal } from './GenForm';
import { DONUSUM_PAY_SECENEKLERI }
  from '../sayfalar/belgeKarti/dagilimKovalari';
import { para, say4, sayiOku as sayi, hamSayi, yerelAnMetni } from './bicim';
import { c } from '../dil/ceviri';
import { gorunenBelgeNo } from '../sayfalar/belgeKartiKurallari';
import { IzlemPenceresi } from './belge/IzlemPenceresi';
import type { IzlemSatiri } from '../sayfalar/belgeSatir';



/**
 * Numarasi KARSI TARAFTA uretilen belgeler: alis faturasinin numarasi
 * tedarikcinin fatura numarasidir, sayacimiz uretemez - kullanici girer.
 * Sunucudaki DisNumaraliTur ile ayni liste.
 */
// Alış belgeleri: numara tedarikçinin (BelgeTuru.DisNumaraliTurler, 02.11.2026).
const DIS_NUMARALI = new Set([10, 11, 12, 109]);

/**
 * Kaynak turden hangi hedeflere donusulebilir (belge turu kod uzayi, 073
 * katalogu).
 *
 * Siparis ve irsaliye YALNIZ faturaya/irsaliyeye degil; FIS ve TAHAKKUK da
 * hedef olabilir (kullanici):
 *   - Fis (12/16): fatura kesilmeden stok/cari hareketi yazilan ic belge
 *     (perakende satis, numune cikisi gibi) - e-Belge'ye gitmez.
 *   - Tahakkuk (17 satis / 13 alis): mal hareketi olmayan alacak/borc kaydi; siparis ya da
 *     irsaliye tutari faturalanmadan cari hesaba islenmek istendiginde.
 * Yon KAYNAKTAN gelir: alis zincirinde alis hedefleri, satista satis.
 */
export const HEDEFLER: Record<number, { kod: number; ad: string }[]> = {
  // Satis teklifi (216): teklif YALNIZ siparise donusur (kullanici) -
  //   taahhut zinciri teklif -> siparis -> irsaliye/fatura sirasiyla yurur.
  18: [{ kod: 19, ad: 'Satış Siparişi' }],
  // Alis siparisi
  9:  [{ kod: 10, ad: 'Alış İrsaliyesi' }, { kod: 11, ad: 'Alış Faturası' },
       { kod: 12, ad: 'Alış Fişi' }, { kod: 13, ad: 'Alış Tahakkuku' }],
  // Satis siparisi
  // BASVURU (246, kullanici): fatura / fis / tahakkuk.
  30: [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
       { kod: 17, ad: 'Satış Tahakkuku' }],
  19: [{ kod: 14, ad: 'Satış İrsaliyesi' }, { kod: 15, ad: 'Satış Faturası' },
       { kod: 16, ad: 'Satış Fişi' }, { kod: 17, ad: 'Satış Tahakkuku' }],
  // Irsaliyeler (konsinye dahil): mal zaten cikti/girdi, sirada belgelenmesi var
  10:  [{ kod: 11, ad: 'Alış Faturası' }, { kod: 12, ad: 'Alış Fişi' },
        { kod: 13, ad: 'Alış Tahakkuku' }],
  14:  [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
        { kod: 17, ad: 'Satış Tahakkuku' }],
  109: [{ kod: 11, ad: 'Alış Faturası' }, { kod: 12, ad: 'Alış Fişi' },
        { kod: 13, ad: 'Alış Tahakkuku' }],
  119: [{ kod: 15, ad: 'Satış Faturası' }, { kod: 16, ad: 'Satış Fişi' },
        { kod: 17, ad: 'Satış Tahakkuku' }],
};

interface Props {
  belgeId: number;
  belgeTur: number;
  /**
   * Arac cubugundaki dugmenin sectigi hedef ("İrsaliyeye Dönüştür" -> 14).
   * Listede yoksa ya da 0 ise ilk hedefe duser; kullanici combodan degistirir.
   */
  varsayilanHedef?: number;
  /** Hedef listede secildi: combo degistirilemez (kullanici). */
  hedefKilitli?: boolean;
  /**
   * KURUM TAHAKKUKU (289/331): kisayoldan acilinca hangi PAYIN kapatilacagi
   * onceden secili gelir - 0 tum satir · 1 hasta payi · 2 kurum payi.
   */
  varsayilanPay?: number;
  onKapat(): void;
  /** Donusum bittiginde cagrilir - cagiran yalnizca grid'i tazeler. */
  onTamam(yeni: BelgeYaniti): void;
}

/**
 * Sipariş → irsaliye → fatura dönüşümü.
 *
 * KISMI donusum esastir: kullanici her satirdan ne kadarini aktaracagini secer,
 * kalan kaynak belgede durur. Miktar kontrolu SUNUCUDA yapilir (kaynak satirlar
 * kilitlenerek) - buradaki sinir yalnizca kullaniciyi erken uyarmak icindir.
 */
export function BelgeDonusumModali({ belgeId, belgeTur, varsayilanHedef, hedefKilitli,
                                    varsayilanPay, onKapat, onTamam }: Props) {
  const [satirlar, setSatirlar] = useState<AcikSatir[]>([]);
  const [miktarlar, setMiktarlar] = useState<Record<number, string>>({});
  const miktarlarRef = useRef(miktarlar);
  miktarlarRef.current = miktarlar;
  const [secili, setSecili] = useState<Record<number, boolean>>({});
  const [hedefTur, setHedefTur] = useState<number>(() => {
    const liste = HEDEFLER[belgeTur] ?? [];
    return liste.some(h => h.kod === varsayilanHedef)
      ? varsayilanHedef! : (liste[0]?.kod ?? 0);
  });
  // TARİH + SAAT (kullanıcı 03.11.2026: "belge dönüştür ekranında belge tarihi yanında saat de olsun"): belge kartının
  //   başlığıyla aynı - yerel an metni (datetime-local), sunucu kartta olduğu gibi okur.
  const [tarih, setTarih] = useState(() => yerelAnMetni(new Date()));
  const [belgeNo, setBelgeNo] = useState('');
  /* Taslak kutusu kaldirildi (kullanici) - donusum hep KESIN belge uretir. */
  const taslak = false;
  const [yukleniyor, setYukleniyor] = useState(true);
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [sonuc, setSonuc] = useState<BelgeYaniti | null>(null);
  /** Uretilen belgenin turu - basari kutusunda yazar (combo sonradan degisebilir). */
  const [sonucAd, setSonucAd] = useState('');

  useEffect(() => {
    void (async () => {
      try {
        const s = await api.belgeAcikSatirlar(belgeId);
        setSatirlar(s);
        setSecili(Object.fromEntries(s.map(x => [x.satirId, true])));
        setMiktarlar(Object.fromEntries(s.map(x => [x.satirId, String(x.kalanMiktar)])));
      } catch (h) {
        setHata(hataMetni(h));
      } finally { setYukleniyor(false) }
    })();
  }, [belgeId]);

  const hedefler = HEDEFLER[belgeTur] ?? [];

  /**
   * LOT / SERİ SOR (kullanıcı 02.11.2026: "satış siparişini irsaliyeye ya da faturaya dönüştürürsek lot/serino
   * sormalı"): sipariş stok düşürmez; irsaliye / fatura / fiş düşürür - izlemli satırda hangi lottan çıkılacağı
   * seçilir. Öneri FIFO (en yakın SKT), kullanıcı değiştirir; toplam satırın miktarına eşit olmalı.
   */
  const lotSorulur = belgeTur === 19 && [14, 15, 16].includes(hedefTur);
  // TEK LOT EKRANI (kullanıcı 02.11.2026: "normal sat.irs de jenerik lot seçme ekranı burada da olsa daha iyi..
  //   her yerde tek ekran"): kalem penceresinin IzlemPenceresi'si (çıkış kipi) - depodaki lotlar, SKT, tamamla,
  //   toplam kilidi aynı.
  const [lotlar, setLotlar] = useState<Record<number, IzlemSatiri[]>>({});
  const [lotAcik, setLotAcik] = useState<number | null>(null);
  const izlemliMi = (s: AcikSatir) => lotSorulur && Number(s.izleme ?? 0) > 0 && !!s.stokId;
  const lotKolonu = satirlar.some(izlemliMi);
  /** Satırın bu belgeye giden miktarı - tutar kipinde sunucu kaynak miktarını yazar. */
  const etkinMiktar = (s: AcikSatir) => tutarModRef.current ? Number(s.miktar) : sayi(miktarlarRef.current[s.satirId] ?? '0');
  const lotToplam = (id: number) => (lotlar[id] ?? []).reduce((t, l) => t + hamSayi(l.miktar), 0);
  const lotSecilenler = (id: number) => (lotlar[id] ?? []).filter(l => hamSayi(l.miktar) > 0 && l.seriLotId);
  const disNumarali = DIS_NUMARALI.has(hedefTur);
  /**
   * ODEME PAYLASIMI (289): satirda kurum ve hasta payi ayri duruyorsa
   * donusum HANGI PAYI kapatacagini sorar. Kurum payi kuruma faturalanir,
   * hasta payi hastaya - ayni satir iki ayri belgeye boluner.
   */
  const [pay, setPay] = useState(varsayilanPay ?? 0);
  const paylasimVar = satirlar.some(
    s => Number(s.kurumTutar ?? 0) > 0 && Number(s.hastaTutar ?? 0) > 0);

  /**
   * TUTAR BAZLI DONUSUM (352): "1000 TL'lik kalemin tahsil edilen 300'u
   * satis fisi, kalan 700'u tahakkuk". Satis siparisi/basvurudan fis, fatura
   * ve tahakkuka giderken acilir; kaynak satir tutarla kismi kapanir (289
   * pay sayaclari). Onerilen tutar: fis/faturada tahsil edilen matrah (payin
   * kalanini asmaz), tahakkukta payin kalani.
   */
  const tutarModOlur = belgeTur === 19 && [15, 16, 17].includes(hedefTur);
  // BASVURUDA VARSAYILAN TUTAR MODU (kullanici: "butona basinca modal olarak
  //   ACIK BELGE TUTARI ne ise o gelecek"): kabul memuru adet degil TUTAR
  //   dusunur - "900 TL'lik muayenenin ne kadarina belge kesiyorum".
  const [tutarMod, setTutarMod] = useState(tutarModOlur);
  const tutarModRef = useRef(tutarMod);
  tutarModRef.current = tutarMod;
  const [tutarlar, setTutarlar] = useState<Record<number, string>>({});
  const [kalaniTahakkuk, setKalaniTahakkuk] = useState(true);
  /**
   * TUTAR MODUNDA EKRAN KDV DAHIL calisir (kullanici: "10.000 TL kdv dahil
   * islem; sadece faturaya/fise gecince kdv haric"). Pay tutarlari ve API
   * MATRAH ister; giris/gosterim burada carpan ile cevrilir - tahsilat da
   * KDV dahil dagitildigi icin (323) oneri gercek odenen tutari verir.
   */
  // Hesap ORTAK dosyada (belgeDonusumHesap): otomatik POS fisi ayni kurali
  //   kullaniyor - iki yerde ayri formul kalmasin.
  const payKalan = (s: AcikSatir) => hesapPayKalan(s, pay);
  const payKalanDahil = (s: AcikSatir) => hesapPayKalanDahil(s, pay);
  const tahsilDahil = (s: AcikSatir) => hesapTahsilDahil(s, pay);
  /**
   * MODALDE ONERI = SATIRIN ACIK KALANI (KDV dahil, kullanici): kart
   * seridindeki "Açık Belge" ile ayni rakam gelsin. belgeDonusumHesap.onerilenTutar
   * (352: fis/faturada TAHSIL EDILEN kadar) otomatik POS fisinde
   * kullanilmaya devam ediyor - orada tahsilat zaten olcudur.
   */
  const onerilenTutar = (s: AcikSatir, _hedef: number) => payKalanDahil(s);
  const tutarModuDegistir = (acik: boolean) => {
    setTutarMod(acik);
    if (acik) setTutarlar(Object.fromEntries(
      satirlar.map(s => [s.satirId, onerilenTutar(s, hedefTur).toFixed(2).replace('.', ',')])));   // ekran biçimi: sayiOku noktayı binlik sayar (1050.06 -> 105006)
  };
  useEffect(() => {
    if (!tutarModOlur && tutarMod) setTutarMod(false);
    if (tutarModOlur && tutarMod) tutarModuDegistir(true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tutarModOlur, satirlar, pay, hedefTur]);

  /**
   * BELGEYE DONUSECEK ACIK TUTAR (KDV dahil): satirlarin kalanlari toplami.
   * Sifirsa modal is yapamaz - "hepsi kesilmis" durumunu dugmeyi pasif
   * birakip SOYLEYEREK gosterir (kullanici).
   */
  const acikToplam = useMemo(
    () => satirlar.reduce((t, s) => t + payKalanDahil(s), 0),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [satirlar, pay]);
  const donusecekYok = !yukleniyor && satirlar.length > 0 && acikToplam < 0.01;

  /**
   * ONIZLEME FIYATI: pay secilince satirin birim fiyati DEGISIR - hedef belge
   * o payin KALANIYLA uretilir (BelgeDeposu.SatirJson). Kaynak fiyatini
   * gostermek "30 TL'lik hasta tahakkuku" icin 150 TL yaziyordu.
   */
  const payliFiyat = (s: AcikSatir) => {
    if (pay === 0) return Number(s.birimFiyat ?? 0);
    // Kalan ORTAK hesaptan: ince kova haritasi burada da gecerli - elle
    // yazilan "1 ise hasta, degilse kurum" ayrimi hasta ek katkisini (4)
    // kurum kovasina dusuruyordu.
    const kalan = hesapPayKalan(s, pay);
    const miktar = Number(s.miktar ?? 0);
    return miktar > 0 ? kalan / miktar : kalan;
  };

  const toplam = useMemo(() =>
    satirlar.reduce((t, s) => secili[s.satirId]
      ? t + (tutarMod ? sayi(tutarlar[s.satirId] ?? '0')
                      : sayi(miktarlar[s.satirId] ?? '0') * payliFiyat(s)) : t, 0),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [satirlar, secili, miktarlar, tutarlar, tutarMod, pay]);

  const seciliSayi = satirlar.filter(s => secili[s.satirId]
    && sayi((tutarMod ? tutarlar : miktarlar)[s.satirId] ?? '0') > 0).length;

  async function donustur() {
    setHata(null);
    // TUTAR MODU (352): satirdan miktar degil TUTAR gonderilir; miktar
    //   sunucuda kaynagin miktari olur. Tutar payin kalanini asamaz.
    const gonderilecek: { satirId: number; miktar: number; tutar?: number }[] = tutarMod
      ? satirlar
          .filter(s => secili[s.satirId] && sayi(tutarlar[s.satirId] ?? '0') > 0)
          // Ekranda KDV DAHIL girilir, sunucu MATRAH ister (pay tutarlari matrah).
          .map(s => ({ satirId: s.satirId, miktar: Number(s.miktar),
                       tutar: Math.round(sayi(tutarlar[s.satirId]) / kdvCarpan(s) * 10000) / 10000,
                       // GIRILEN BRUT de gider: hedef satirin KDV dahil fiyati
                       //   bundan yazilir, "500 girdim 499,99 kesildi" olmaz.
                       tutarKdvli: sayi(tutarlar[s.satirId]) }))
      : satirlar
          .filter(s => secili[s.satirId] && sayi(miktarlar[s.satirId] ?? '0') > 0)
          .map(s => ({ satirId: s.satirId, miktar: sayi(miktarlar[s.satirId]) }));

    if (gonderilecek.length === 0) { setHata('En az bir satır seçilmeli.'); return }
    // LOT KONTROLÜ: izlemli her satırda lot seçilmiş ve toplamı miktara eşit olmalı.
    for (const g of gonderilecek) {
      const s = satirlar.find(x => x.satirId === g.satirId)!;
      if (!izlemliMi(s)) continue;
      const ad = s.stokAdi ?? s.kalemAdi ?? '';
      if (lotSecilenler(g.satirId).length === 0) {
        setHata(`${ad}: lot / seri seçilmeli.`); setLotAcik(g.satirId); return;
      }
      if (Math.abs(lotToplam(g.satirId) - g.miktar) > 0.0001) {
        setHata(`${ad}: seçilen lot miktarı (${say4.format(lotToplam(g.satirId))}) satır miktarına (${say4.format(g.miktar)}) eşit olmalı.`);
        setLotAcik(g.satirId); return;
      }
      const asan = lotSecilenler(g.satirId).find(l => l.kalan !== undefined && hamSayi(l.miktar) > l.kalan + 0.0001);
      if (asan) { setHata(`${ad}: ${asan.lotNo || asan.seriNo} lotunda yalnız ${say4.format(asan.kalan ?? 0)} var.`); setLotAcik(g.satirId); return }
    }
    const lotluGonderilecek = gonderilecek.map(g => {
      const s = satirlar.find(x => x.satirId === g.satirId)!;
      return izlemliMi(s)
        ? { ...g, lotlar: lotSecilenler(g.satirId).map(l => ({ seriLotId: l.seriLotId!, miktar: hamSayi(l.miktar) })) }
        : g;
    });
    if (!hedefTur) { setHata('Hedef belge türü seçilmeli.'); return }

    if (tutarMod) {
      const asanT = gonderilecek.find(g => {
        const s = satirlar.find(x => x.satirId === g.satirId)!;
        return (g.tutar ?? 0) > payKalan(s) + 0.01;   // matrah duzleminde
      });
      if (asanT) { setHata('Bir satırda girilen tutar payın kalanını aşıyor.'); return }
    } else {
      // PAY donusumunde sinir miktar degil TUTAR - kontrol sunucuda (289).
      const asan = pay > 0 ? undefined : gonderilecek.find(g => {
        const s = satirlar.find(x => x.satirId === g.satirId)!;
        return g.miktar > Number(s.kalanMiktar);
      });
      if (asan) { setHata('Bir satırda girilen miktar kalanı aşıyor.'); return }
    }
    if (disNumarali && !taslak && belgeNo.trim() === '') {
      setHata('Tedarikçi belge numarası girilmeli.'); return;
    }

    setCalisiyor(true);
    try {
      const yeni = await api.belgeDonustur(belgeId, hedefTur, lotluGonderilecek, tarih, taslak,
                                           disNumarali ? belgeNo.trim() : undefined,
                                           tutarMod ? (pay || 1) : paylasimVar ? pay : 0,
                                           tutarMod && kalaniTahakkuk && hedefTur !== 17);
      setSonuc(yeni);
      setSonucAd(hedefler.find(h => h.kod === hedefTur)?.ad ?? 'Belge');
      setBelgeNo('');
      // Kalan satirlari tazele: ayni siparisten ikinci bir belge kesilebilir.
      setSatirlar(await api.belgeAcikSatirlar(belgeId));
      setLotlar({}); setLotAcik(null);
      onTamam(yeni);
    } catch (h) {
      setHata(hataMetni(h));
    } finally { setCalisiyor(false) }
  }

  return (
    <Modal
      baslik="Belge Dönüştür"
      onKapat={onKapat}
      alt={
        <>
          <button className="d bir"
                  disabled={calisiyor || satirlar.length === 0 || donusecekYok}
                  title={donusecekYok ? 'Belgeye dönüşecek tutar kalmadı' : undefined}
                  onClick={() => void donustur()}>
            {calisiyor ? 'Dönüştürülüyor…' : sonuc ? '⇢ Kalanı Dönüştür' : '⇢ Dönüştür'}
          </button>
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}

      {/* Hata varken ONCEKI basari kutusu gizlenir: iki kutu yan yana durunca
          "hem oldu hem olmadi" gibi okunuyordu (yesil kutu bir onceki
          donusumun sonucu). */}
      {sonuc && !hata && (
        <div className="bilgi-kutusu">
          {/* Hedef adi DONUSUM ANINDA sabitlenir: combo sonradan degistirilince
              "Satış Fişi oluşturuldu" yazip aslinda tahakkuk uretmis gibi
              gorunuyordu. */}
          <b>{sonucAd || 'Belge'} oluşturuldu.</b>{' '}
          No: <b>{gorunenBelgeNo(sonuc.belge.belgeNo) || (sonuc.belge.belgeNo ? c('e-Belge gönderiminde verilir') : '—')}</b> ·
          Genel toplam: <b>{para.format(Number(sonuc.belge.genelToplam))}</b>
          {sonuc.uyarilar && sonuc.uyarilar.length > 0 && (
            <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
          )}
        </div>
      )}

      {/* BELGEYE DONUSECEK TUTAR KALMADI (kullanici): satirlarin tamami
          faturaya/fise/tahakkuka cevrilmisse modal bos bir tabloyla
          acilmasin - sebebi yazsin. */}
      {donusecekYok && !sonuc && (
        <div className="uyari">
          Belgeye dönüşecek tutar kalmadı — bu başvurunun ücretleri zaten
          belgeye çevrilmiş.
        </div>
      )}

      {hedefler.length === 0 ? (
        <div className="bilgi-kutusu">Bu belge türü için tanımlı bir dönüşüm hedefi yok.</div>
      ) : (
        <>
          <div className="kagrup">
            <h6>Hedef</h6>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">{c('Hedef Belge')}</span>
                {/* Hedef listeden secildiyse KILITLI - karar orada verildi. */}
                <select value={hedefTur} disabled={hedefKilitli}
                        title={hedefKilitli ? 'Hedef listede seçildi' : undefined}
                        onChange={e => setHedefTur(Number(e.target.value))}>
                  {hedefler.map(h => <option key={h.kod} value={h.kod}>{h.ad}</option>)}
                </select>
              </label>
              {/* ODEME PAYLASIMI (289): satirlar kurum/hasta payina bolunmusse
                  hangi payin donusturulecegi sorulur. Kurum payi KURUMA
                  faturalanir - hedef belgenin carisi hasta degildir. */}
              {paylasimVar && (
                <label className="alan">
                  <span className="etiket">{c('Dönüştürülecek Pay')}</span>
                  {/* INCE KOVALAR (470): sunucu bu kodlarla calisir - kaba
                      "kurum payi" (2) SGK kovasi demek ve anlasmali kurum
                      basvurusunda "SGK payı zaten kapatılmış" hatasi
                      veriyordu. */}
                  <select value={pay} onChange={e => setPay(Number(e.target.value))}>
                    <option value={0}>{c('Tümü (paylaşımsız)')}</option>
                    {DONUSUM_PAY_SECENEKLERI.map(k =>
                      <option key={k.kod} value={k.kod}>{k.ad}</option>)}
                  </select>
                </label>
              )}
              {/* TUTAR BAZLI DONUSUM (352): "1000 TL'lik kalemin tahsil edilen
                  300'u satis fisi, kalan 700'u tahakkuk". Yalniz satis
                  tarafinda (fis/fatura/tahakkuk); miktar yerine tutar girilir. */}
              {tutarModOlur && (
                <label className="alan">
                  <span className="etiket">{c('Dönüşüm Ölçüsü')}</span>
                  <select value={tutarMod ? 1 : 0} onChange={e => tutarModuDegistir(e.target.value === '1')}>
                    <option value={0}>{c('Miktar (adet)')}</option>
                    <option value={1}>{c('Tutar (tahsil edilen kadar)')}</option>
                  </select>
                </label>
              )}
              {tutarMod && hedefTur !== 17 && (
                <label className="alan onay-kutusu">
                  <input type="checkbox" checked={kalaniTahakkuk}
                         onChange={e => setKalaniTahakkuk(e.target.checked)} />
                  <span>{c('Kalanı satış tahakkukuna çevir')}</span>
                </label>
              )}
              {/* Alis faturasinda numara TEDARIKCININ - sayac uretmez, sorulur. */}
              {disNumarali && (
                <label className="alan">
                  <span className="etiket zorunlu-isaret">{hedefTur === 10 || hedefTur === 109 ? c('Tedarikçi İrsaliye No')
                    : hedefTur === 12 ? c('Tedarikçi Fiş No') : c('Tedarikçi Fatura No')}</span>
                  <input value={belgeNo} maxLength={20}
                         onChange={e => setBelgeNo(e.target.value)} />
                </label>
              )}
              <label className="alan">
                <span className="etiket">{c('Belge Tarihi')}</span>
                <input type="datetime-local" value={tarih} onChange={e => setTarih(e.target.value || yerelAnMetni(new Date()))} />
              </label>
              {/* TASLAK kutusu KALKTI (kullanici): donusumden cikan belge de
                  kesindir - kart tarafinda da ayni kural. */}
            </div>
          </div>

          <div className="kagrup">
            <h6>{c('Dönüştürülecek Satırlar')}</h6>
            {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th style={{ width: 34 }} />
                    <th>{c('Stok / Açıklama')}</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Miktar</th>
                    <th className="hiza-sag" style={{ width: 90 }}>{c('Dönüşen')}</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Kalan</th>
                    <th className="hiza-sag" style={{ width: 120 }}>{tutarMod ? 'Bu Belgeye (₺ KDV dahil)' : 'Bu Belgeye'}</th>
                    <th className="hiza-sag" style={{ width: 110 }}>{tutarMod ? 'Tahsil / Kalan (KDV dahil)' : 'Birim Fiyat'}</th>
                    {lotKolonu && <th style={{ width: 190 }}>{c('Lot / Seri')}</th>}
                  </tr>
                </thead>
                <tbody>
                  {satirlar.map(s => (<Fragment key={s.satirId}>
                    {/* Satira tiklamak da isaretler: burada secim = "bu satiri
                    //   donustur" isareti, coklu secim ASILDIR - o yuzden duz tik
                    //   digerlerini kaldirmaz (liste gridlerinin aksine). */}
                    <tr
                        className={secili[s.satirId] ? 'secili' : ''}
                        onClick={() => setSecili(x => ({ ...x, [s.satirId]: !x[s.satirId] }))}>
                      <td className="hiza-orta">
                        <input
                          type="checkbox"
                          checked={!!secili[s.satirId]}
                          onClick={e => e.stopPropagation()}
                          onChange={e => setSecili(x => ({ ...x, [s.satirId]: e.target.checked }))}
                        />
                      </td>
                      <td>
                        {/* Stok disi satirda (hizmet/masraf) ad kalem_adi'ndan
                            gelir (293) - once bos gorunuyordu. */}
                        {(s.stokKodu ?? s.kalemKodu)
                          ? <><code>{s.stokKodu ?? s.kalemKodu}</code>{' '}
                              {s.stokAdi ?? s.kalemAdi}{' '}
                              {s.aciklama ? <span className="sonuk">· {s.aciklama}</span> : null}</>
                          : s.aciklama}
                      </td>
                      <td className="hiza-sag">{say4.format(Number(s.miktar))}</td>
                      <td className="hiza-sag">{say4.format(Number(s.kapatilanMiktar))}</td>
                      <td className="hiza-sag"><b>{say4.format(Number(s.kalanMiktar))}</b></td>
                      <td>
                        {tutarMod ? (
                          <input
                            className="hiza-sag"
                            value={tutarlar[s.satirId] ?? ''}
                            disabled={!secili[s.satirId]}
                            onClick={e => e.stopPropagation()}
                            onChange={e => setTutarlar(x => ({ ...x, [s.satirId]: e.target.value }))}
                          />
                        ) : (
                          <input
                            className="hiza-sag"
                            value={miktarlar[s.satirId] ?? ''}
                            disabled={!secili[s.satirId]}
                            onClick={e => e.stopPropagation()}
                            onChange={e => setMiktarlar(x => ({ ...x, [s.satirId]: e.target.value }))}
                          />
                        )}
                      </td>
                      <td className="hiza-sag">
                        {tutarMod
                          ? <>{para.format(tahsilDahil(s))} <span className="sonuk">/ {para.format(payKalanDahil(s))}</span></>
                          : para.format(payliFiyat(s))}
                      </td>
                      {lotKolonu && (
                        <td onClick={e => e.stopPropagation()}>
                          {izlemliMi(s) && (
                            <button type="button" className={`d mini${secili[s.satirId] && Math.abs(lotToplam(s.satirId) - etkinMiktar(s)) > 0.0001 ? ' teh' : ''}`}
                                    disabled={!secili[s.satirId]} onClick={() => setLotAcik(s.satirId)}
                                    title={c('Hangi lot / seriden çıkılacağını seçin')}>
                              🏷 {lotSecilenler(s.satirId).map(l => `${l.lotNo || l.seriNo}×${l.miktar}`).join(', ') || c('Lot seç')}
                            </button>)}
                        </td>
                      )}
                    </tr>
                  </Fragment>))}
                  {satirlar.length === 0 && (
                    <tr><td colSpan={7} className="bos">{c('Dönüştürülecek açık satır yok.')}</td></tr>
                  )}
                </tbody>
                <tfoot>
                  <tr className="genel">
                    <td colSpan={5}>{seciliSayi} satır seçili</td>
                    <td className="hiza-sag" colSpan={2}>
                      {para.format(toplam)} (KDV hariç, önizleme)
                    </td>
                  </tr>
                </tfoot>
              </table>
            )}
          </div>

          {lotAcik !== null && (() => {
            const ls = satirlar.find(x => x.satirId === lotAcik);
            return ls ? (
              <IzlemPenceresi
                stokAdi={ls.stokAdi ?? ls.kalemAdi ?? ''}
                stokId={ls.stokId ?? null}
                depoId={ls.cikisDepoId ?? null}
                cikis
                izleme={Number(ls.izleme ?? 0)}
                miktar={etkinMiktar(ls)}
                satirlar={lotlar[ls.satirId] ?? []}
                onKapat={() => setLotAcik(null)}
                onKaydet={secim => { setLotlar(x => ({ ...x, [ls.satirId]: secim })); setLotAcik(null) }}
              />
            ) : null;
          })()}

          <div className="not">
            Kalan miktar kaynağında durur; aynı siparişten birden fazla irsaliye/fatura
            kesilebilir. Miktar kontrolü sunucuda, kaynak satırlar kilitlenerek yapılır.
          </div>
        </>
      )}
    </Modal>
  );
}
