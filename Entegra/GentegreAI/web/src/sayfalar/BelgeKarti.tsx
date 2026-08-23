import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { ApiHatasi, type BelgeYaniti, type KasaIslemTuru, type ListeSatiri } from '../api/sozlesme';
import { GenLookup, LOOKUP_CARI } from '../bilesenler/GenLookup';
import { Modal } from '../bilesenler/GenForm';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { TarafArama } from '../bilesenler/TarafArama';
import { DokumanGalerisi } from '../bilesenler/DokumanGalerisi';
import { useOturum } from '../kimlik/OturumBaglami';

interface SatirDurumu {
  anahtar: number;
  /** 1 stok · 2 hizmet · 3 masraf (belge_satir.tur). */
  satirTur: number;
  stokId: number | null;
  hizmetId: number | null;
  stokKodu: string;
  stokAdi: string;
  adet: string;
  /** YEREL para biriminde birim fiyat - belgeye kaydedilen ve gridde gorunen deger. */
  birimFiyat: string;
  /** Kartindan gelen fiyatin para birimi (ör. USD). Yerel ise donusum yok. */
  fiyatDovizi: string;
  /** Kart fiyati kendi doviziyle - kullanici bunu girer, yerel karsiligi hesaplanir. */
  dovizFiyat: string;
  /** fiyatDovizi -> yerel kur (gunluk kurdan gelir, elle degistirilebilir). */
  kur: string;
  /** 1. iskonto yuzdesi. */
  iskonto: string;
  /** 2. iskonto yuzdesi - birinciden SONRA, carpimsal uygulanir (BelgeHesap). */
  iskonto2: string;
  kdv: string;
  /** Satir aciklamasi (belge_satir.aciklama) - gridde stok adinin saginda. */
  aciklama: string;
  /** Seri / lot takibi (belge_satir.izleme_kodu) - irsaliyede gorunur. */
  izlemeKodu: string;
}

/**
 * Yerel para birimi. SIMDILIK sabit - opsiyona (kurulus ayari) baglanacak;
 * mali_hareket/muhasebe tarafinda da ayni kavram "yerel tutar" olarak geciyor.
 */
const YEREL_PARA = 'TL';

const bosSatir = (anahtar: number): SatirDurumu => ({
  anahtar, satirTur: 1, stokId: null, hizmetId: null, stokKodu: '', stokAdi: '',
  adet: '1', birimFiyat: '', fiyatDovizi: YEREL_PARA, dovizFiyat: '', kur: '1',
  iskonto: '0', iskonto2: '0', kdv: '20', aciklama: '', izlemeKodu: '',
});

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/**
 * Satir tutari ONIZLEMESI - sunucudaki BelgeHesap.SatirTutari ile ayni sira:
 * once (adet x fiyat) yuvarlanir, sonra iki iskonto CARPIMSAL uygulanir.
 * Kesin tutar yine sunucudan gelir; bu yalniz ekranda anlik gosterim.
 */
/** Gridde iskonto gosterimi: tek iskonto "%10", iki kademeli "%10 + %5". */
function iskonatoMetni(r: { iskonto: string; iskonto2: string }): string {
  const i1 = Number(r.iskonto.replace(',', '.')) || 0;
  const i2 = Number(r.iskonto2.replace(',', '.')) || 0;
  if (!i1 && !i2) return '';
  return i2 ? `%${i1} + %${i2}` : `%${i1}`;
}

function satirTutari(adet: number, fiyat: number, iskonto: string, iskonto2: string): number {
  const i1 = Number(iskonto.replace(',', '.')) || 0;
  const i2 = Number(iskonto2.replace(',', '.')) || 0;
  return Math.round(adet * fiyat * 100) / 100 * ((100 - i1) / 100) * ((100 - i2) / 100);
}

const LOOKUP_DEPO = [{ ad: 'ad', baslik: 'Depo', genis: true }];

/** Teslim sekli (088 kod listesi belge.teslim_sekli) - e-Irsaliye'de GIB bekler. */
const TESLIM_SEKLI: { deger: number; ad: string }[] = [
  { deger: 0, ad: 'Belirtilmemiş' },
  { deger: 1, ad: 'Alıcı adresine teslim' },
  { deger: 2, ad: 'Alıcı kendi aracıyla' },
  { deger: 3, ad: 'Kargo / nakliye firması' },
  { deger: 4, ad: 'Depoda teslim' },
  { deger: 5, ad: 'Yurt dışı sevk' },
];

/** Yururlukteki ve gecmis KDV oranlari - eski belgeler %8/%18 tasiyor. */
const KDV_ORANLARI = [0, 1, 8, 10, 18, 20] as const;

const KAPANMA_ETIKET: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Faturalanmadı', sinif: 'uyari' },
  1: { ad: 'Kısmi faturalandı', sinif: '' },
  2: { ad: 'Faturalandı', sinif: 'olumlu' },
};

/** Kart sekmeleri (mockup satis_irsaliye_karti.html .tabs).
    `irsaliye:true` olanlar yalniz irsaliye turlerinde gorunur. */
const SEKMELER: { anahtar: string; baslik: string; irsaliye?: boolean }[] = [
  { anahtar: 'kalem',    baslik: 'Kalemler' },
  { anahtar: 'tasiyici', baslik: 'Taşıyıcı / Sevkiyat', irsaliye: true },
  { anahtar: 'ebelge',   baslik: 'e-Belge' },
  { anahtar: 'fatura',   baslik: 'Faturalama' },
  { anahtar: 'imza',     baslik: 'İmza / Teslim', irsaliye: true },
  { anahtar: 'yorum',    baslik: 'Yorum / Medya' },
];

/** Kartin acabilecegi belge turleri - grup='belge' katalogundan suzulur. */
const GIRILEBILIR_TURLER = [19, 15, 14, 9, 11, 10, 16, 12] as const;

/** Hangi turden sonra hangi listeye donulur. */
const LISTE_YOLU = (tur: number) => (tur === 9 || tur === 19 ? '/siparis' : '/belge');

/**
 * TarafArama ile doldurulan baslik alani (cari, satis temsilcisi...).
 *
 * GenLookup DEGIL: secim her yerde AYNI arama ekranindan yapilsin diye alan
 * kendisi salt okunur, tiklayinca (ya da "…" dugmesiyle) modali cagirir.
 */
function TarafAlani({ etiket, deger, kilitli, ipucu, zorunlu, hata, onAc }: {
  etiket: string;
  deger?: string;
  kilitli: boolean;
  ipucu: string;
  zorunlu?: boolean;
  hata?: string;
  onAc(): void;
}) {
  return (
    <label className="alan">
      <span className={`etiket${zorunlu ? ' zorunlu-isaret' : ''}`}>{etiket}</span>
      <span className="lookup-kutu">
        <input readOnly value={deger ?? ''} placeholder="Seçiniz…" disabled={kilitli}
               onMouseDown={e => { if (!kilitli) { e.preventDefault(); onAc() } }} />
        {!kilitli && (
          <button type="button" className="mini" title={ipucu} onClick={onAc}>…</button>
        )}
      </span>
      {hata && <span className="alan-hata">{hata}</span>}
    </label>
  );
}

/**
 * Belge kesme ekrani (satis faturasi, siparis, irsaliye…).
 *
 * TUR URL'DEN GELIR (?tur=19). Ekran eskiden 15'e (satis faturasi) SABITTI;
 * Siparisler listesinden "Yeni" denince yine fatura ekrani aciliyordu.
 *
 * Ekran MODAL acilir (diger kartlarla ayni desen): liste arkada kalir.
 *
 * TUTAR HESABI SUNUCUDA. Ekranda gosterilen satir tutari yalnizca ONIZLEMEDIR;
 * kaydedilen degerler her zaman sunucudan donen belgeden okunur. Delphi ile kurusu
 * kurusuna ayni olmasi gereken formul (ic yuvarlama + carpimsal iskonto + banker's)
 * tek yerde, sunucuda durur — istemciye kopyalanirsa iki formul birbirinden kayar.
 */
interface Props {
  /** Verilirse MEVCUT belge acilir (salt gorunum). Duzenleme F7'de gelecek. */
  id?: number;
  /** Acilis turu; verilmezse URL'deki ?tur= ya da satis faturasi (15). */
  tur?: number;
  /** Liste icinden acildiginda: modal kapanisi cagirani ilgilendirir. */
  onKapat?(): void;
  /** Kayit sonrasi cagirani (grid) tazelemek icin. */
  onKaydedildi?(): void;
}

export function BelgeKarti({ id: belgeId, tur: acilisTuru, onKapat, onKaydedildi }: Props = {}) {
  const git = useNavigate();
  const [sorgu] = useSearchParams();
  const { yetki, kullanici } = useOturum();

  const [tur, setTur] = useState<number>(() => {
    const istenen = acilisTuru ?? Number(sorgu.get('tur'));
    return GIRILEBILIR_TURLER.includes(istenen as typeof GIRILEBILIR_TURLER[number]) ? istenen : 15;
  });
  const [turler, setTurler] = useState<KasaIslemTuru[]>([]);

  const [cari, setCari] = useState<{ id: number; unvan: string } | null>(null);
  const [tarih, setTarih] = useState(new Date().toISOString().slice(0, 10));
  const [seri, setSeri] = useState('WEB');
  const [vadeGun, setVadeGun] = useState('30');
  const [depo, setDepo] = useState<{ id: number; ad: string } | null>(null);
  const [satici, setSatici] = useState<{ id: number; ad: string } | null>(null);
  const [teslimSekli, setTeslimSekli] = useState(0);
  const [sevkTarihi, setSevkTarihi] = useState('');
  const [soforTckn, setSoforTckn] = useState('');
  const [tasiyici, setTasiyici] = useState<{ id: number; ad: string } | null>(null);
  const [aracPlaka, setAracPlaka] = useState('');
  const [soforAd, setSoforAd] = useState('');
  const [teslimEden, setTeslimEden] = useState<{ id: number; ad: string } | null>(null);
  const [taslak, setTaslak] = useState(false);
  const [satirlar, setSatirlar] = useState<SatirDurumu[]>([bosSatir(1)]);

  const [kaydediyor, setKaydediyor] = useState(false);
  const [aciliyor, setAciliyor] = useState(!!belgeId);
  const [donusum, setDonusum] = useState(false);
  const [aktifSekme, setAktifSekme] = useState('kalem');
  /** Grid satir secimi (kirmizi Sil dugmesi bunlari siler). */
  const [seciliSatirlar, setSeciliSatirlar] = useState<Set<number>>(new Set());
  /** Acik kalem penceresi (adet / fiyat). Stok zaten secilmis olarak gelir. */
  const [kalem, setKalem] = useState<SatirDurumu | null>(null);
  /** Ardisik giris: stok arama penceresi acik mi. Kalem eklendikten sonra
      KAPANMAZ - kullanici arka arkaya satir girer, isi bitince Kapat der. */
  const [stokArama, setStokArama] = useState(false);
  /** Cari secim modali. YENI belgede acilista kendiliginden acilir: belgenin
      ilk sorusu "kime?" - kullaniciyi bos formda birakip aramaya zorlamak yerine
      dogrudan secim ekrani gelir (kisi kartindaki "Cariye Bağla" deseni). */
  const [cariArama, setCariArama] = useState(!belgeId);
  /** Satis temsilcisi (personel) secim modali - cari ile ayni ekran. */
  const [saticiArama, setSaticiArama] = useState(false);
  const [donusumler, setDonusumler] = useState<Record<string, unknown>[]>([]);
  const [sonuc, setSonuc] = useState<BelgeYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});

  const ekleyebilir = yetki('belge', 'ekle');

  // Tur adlari katalogtan gelir (istemcide ikinci bir liste tutulmaz).
  useEffect(() => {
    void (async () => {
      try { setTurler(await api.kasaIslemTurleri()) } catch { /* ad yoksa kod gosterilir */ }
    })();
  }, []);

  const turAdi = (kod: number) => turler.find(t => t.kod === kod)?.ad ?? `Belge (${kod})`;
  const seciliTurAdi = turAdi(tur);
  /** Mevcut belge SALT GORUNUM: duzenleme ucu (PUT /api/belge/{id}) henuz yok. */
  const mevcutBelge = !!belgeId;
  const kilitli = mevcutBelge || !!sonuc;
  const siparisMi = tur === 9 || tur === 19;
  const irsaliyeMi = tur === 10 || tur === 14 || tur === 109 || tur === 119;
  /** Kaydedilmis belgenin id'si (yeni kayittan ya da acilan belgeden). */
  const kayitliId = belgeId ?? (sonuc ? Number(sonuc.belge.id) : 0);

  /** Bu belge icin tahsilat islemi ac (cari ve tutar onyuklu). */
  const tahsilatAc = () => {
    if (!kayitliId) return;
    kapat();
    git(`/kasa-islem/yeni?tur=21&tarafId=${cari?.id ?? ''}` +
        `&belgeId=${kayitliId}&tutar=${sonuc?.belge.genelToplam ?? ''}`);
  };

  // Mevcut belgeyi ac: baslik + satirlar + dip toplam sunucudan gelir.
  useEffect(() => {
    if (!belgeId) return;
    void (async () => {
      try {
        const y = await api.belgeOku(belgeId);
        setSonuc(y);
        setTur(Number(y.belge.tur));
        setCari({ id: Number(y.belge.tarafId), unvan: String(y.belge.tarafUnvan ?? '') });
        setTarih(String(y.belge.belgeTarihi ?? '').slice(0, 10));
        setSeri(String(y.belge.belgeSeri ?? ''));
        setVadeGun(String(y.belge.vadeGun ?? 0));
        setDepo(y.belge.cikisDepoId
          ? { id: Number(y.belge.cikisDepoId), ad: String(y.belge.cikisDepoAdi ?? '') } : null);
        setSatici(y.belge.saticiId
          ? { id: Number(y.belge.saticiId), ad: String(y.belge.saticiAdi ?? '') } : null);
        setTeslimSekli(Number(y.belge.teslimSekli ?? 0));
        setSevkTarihi(y.belge.irsaliyeTarihi ? String(y.belge.irsaliyeTarihi).slice(0, 16) : '');
        setSoforTckn(String(y.belge.soforTckn ?? ''));
        setAracPlaka(String(y.belge.aracPlaka ?? ''));
        setSoforAd(String(y.belge.soforAd ?? ''));
        setTeslimEden(y.belge.teslimEdenId
          ? { id: Number(y.belge.teslimEdenId), ad: String(y.belge.teslimEdenAdi ?? '') } : null);
        setSatirlar((y.satirlar ?? []).map((r, i) => ({
          anahtar: i + 1,
          satirTur: Number(r.tur ?? 1),
          stokId: r.stokId ? Number(r.stokId) : null,
          hizmetId: r.hizmetId ? Number(r.hizmetId) : null,
          stokKodu: String(r.stokKodu ?? ''),
          stokAdi: String(r.stokAdi ?? r.hizmetAdi ?? r.aciklama ?? ''),
          aciklama: String(r.aciklama ?? ''),
          izlemeKodu: String(r.izlemeKodu ?? ''),
          adet: String(r.miktar ?? r.adet ?? 0),
          birimFiyat: String(r.birimFiyat ?? 0),
          // Kayitli satir belgenin dovizinde saklanir; satir bazinda doviz/kur
          //   tutulmuyor - kalem yeniden acilirsa yerel giris olarak gelir.
          fiyatDovizi: YEREL_PARA,
          dovizFiyat: String(r.birimFiyat ?? 0),
          kur: '1',
          iskonto: String(r.iskonto ?? 0),
          iskonto2: String(r.iskonto2 ?? 0),
          kdv: String(r.kdv ?? 0),
        })));
      } catch (h) {
        setHata(h instanceof ApiHatasi ? h.message : String(h));
      } finally { setAciliyor(false) }
    })();
  }, [belgeId]);

  // YENI belgede cikis deposu ANA DEPO ile dolu gelir (depo.varsayilan = 1).
  //   Depo cogu belgede hep aynidir; kullaniciyi her seferinde secmeye zorlamak
  //   yerine varsayilani koyariz, isteyen degistirir. Kayitli belgede dokunulmaz.
  useEffect(() => {
    if (belgeId) return;
    void (async () => {
      try {
        const y = await api.liste('depo', {
          sayfa: 1, boyut: 1,
          filtre: { op: 'and', kosullar: [
            { alan: 'varsayilan', op: 'esit', deger: 1 },
            { alan: 'durum', op: 'esit', deger: 1 },
          ] },
        });
        const d = y.satirlar[0];
        if (d) setDepo(o => o ?? { id: Number(d.id), ad: String(d.ad ?? '') });
      } catch { /* varsayilan depo yoksa alan bos kalir - engelleyici degil */ }
    })();
  }, [belgeId]);

  // Faturalama sekmesi: bu belgeden turetilmis belgeler (F8 zinciri).
  useEffect(() => {
    if (!kayitliId || aktifSekme !== 'fatura') return;
    void (async () => {
      try { setDonusumler(await api.belgeDonusumler(kayitliId)) } catch { setDonusumler([]) }
    })();
  }, [kayitliId, aktifSekme]);

  /** Yalniz ONIZLEME: gercek tutar sunucudan gelir. */
  const onizleme = useMemo(() => {
    let matrah = 0, kdv = 0;
    satirlar.forEach(s => {
      const adet = Number(s.adet.replace(',', '.')) || 0;
      const fiyat = Number(s.birimFiyat.replace(',', '.')) || 0;
      const oran = Number(s.kdv.replace(',', '.')) || 0;
      const tutar = satirTutari(adet, fiyat, s.iskonto, s.iskonto2);
      matrah += tutar;
      kdv += tutar * oran / 100;
    });
    return { matrah, kdv, genel: matrah + kdv };
  }, [satirlar]);

  /** Kalem penceresinden donen satiri yazar (yeni ise ekler). */
  const kalemKaydet = (satir: SatirDurumu) =>
    setSatirlar(s => s.some(x => x.anahtar === satir.anahtar)
      ? s.map(x => (x.anahtar === satir.anahtar ? satir : x))
      : [...s, satir]);

  /** Secili satirlari siler - grid salt gorunum oldugu icin satir ici silme yok. */
  const seciliSil = () => {
    if (seciliSatirlar.size === 0) return;
    setSatirlar(s => s.filter(x => !seciliSatirlar.has(x.anahtar)));
    setSeciliSatirlar(new Set());
  };

  const secimDegis = (anahtar: number) =>
    setSeciliSatirlar(k => {
      const y = new Set(k);
      if (y.has(anahtar)) y.delete(anahtar); else y.add(anahtar);
      return y;
    });

  async function kes() {
    setHata(null);
    setAlanHatalari({});
    setSonuc(null);

    if (!cari) { setAlanHatalari({ tarafId: 'Cari seçilmeli.' }); return }
    const dolu = satirlar.filter(s => s.stokId || s.hizmetId);
    if (dolu.length === 0) { setHata('En az bir satırda stok ya da hizmet seçilmeli.'); return }

    setKaydediyor(true);
    try {
      const govde = {
        belge: {
          tur,
          tarafId: cari.id,
          belgeTarihi: `${tarih}T${new Date().toTimeString().slice(0, 8)}`,
          belgeSeri: seri,
          belgeDovizi: 'TL',
          dovizKuru: 1,
          vadeGun: Number(vadeGun) || 0,
          subeId: kullanici?.subeId ?? undefined,
          cikisDepoId: depo?.id ?? null,
          saticiId: satici?.id ?? null,
          // Teslim sekli e-Irsaliye'de GIB'in bekledigi alan.
          teslimSekli: irsaliyeMi ? teslimSekli : undefined,
          aracPlaka: irsaliyeMi ? aracPlaka : undefined,
          soforAd: irsaliyeMi ? soforAd : undefined,
          // Tasiyici / Sevkiyat sekmesindeki ek UBL alanlari
          irsaliyeTarihi: irsaliyeMi && sevkTarihi ? sevkTarihi : undefined,
          soforTckn: irsaliyeMi ? soforTckn : undefined,
          tasiyiciId: irsaliyeMi ? tasiyici?.id ?? null : undefined,
          teslimEdenId: irsaliyeMi ? teslimEden?.id ?? null : undefined,
        },
        satirlar: dolu.map((s, i) => ({
          sira: i + 1,
          tur: s.satirTur,
          stokId: s.stokId,
          hizmetId: s.hizmetId,
          adet: Number(s.adet.replace(',', '.')) || 0,
          miktar: Number(s.adet.replace(',', '.')) || 0,
          birimFiyat: Number(s.birimFiyat.replace(',', '.')) || 0,
          iskonto: Number(s.iskonto.replace(',', '.')) || 0,
          iskonto2: Number(s.iskonto2.replace(',', '.')) || 0,
          kdv: Number(s.kdv.replace(',', '.')) || 0,
          aciklama: s.aciklama,
          izlemeKodu: s.izlemeKodu,
          izleme: s.izlemeKodu ? 1 : 0,
        })),
        secenekler: { taslak, stokKontrolu: true },
      };

      setSonuc(await api.belgeEkle(govde));
      onKaydedildi?.();
    } catch (h) {
      if (h instanceof ApiHatasi) {
        if (h.dogrulamaMi && h.hata.alanlar)
          setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
        setHata(`${h.hata.kod}: ${h.message}`);
      } else setHata(String(h));
    } finally {
      setKaydediyor(false);
    }
  }

  function yeniBelge() {
    setSonuc(null);
    setCari(null);
    setSatirlar([bosSatir(1)]);
    setHata(null);
  }

  /** Modal icinde acildiysa cagiran kapatir; dogrudan URL ile acildiysa listeye doner. */
  const kapat = () => (onKapat ? onKapat() : git(LISTE_YOLU(tur)));

  if (!ekleyebilir)
    return (
      <Modal baslik="Belge" onKapat={kapat} alt={<button className="d" onClick={kapat}>Kapat</button>}>
        <div className="hata-kutusu">Belge ekleme yetkiniz yok.</div>
      </Modal>
    );

  return (
    <Modal
      baslik={mevcutBelge
        ? `${seciliTurAdi}${sonuc?.belge.belgeNo ? ` — ${sonuc.belge.belgeNo}` : ''}`
        : seciliTurAdi}
      ustBilgi={kullanici?.subeYazma === false
        ? <span className="rozet uyari">salt okuma şubesi</span>
        : <span className="kapt">{kullanici?.subeler.find(s => s.id === kullanici?.subeId)?.ad}</span>}
      onKapat={kapat}
      // Arac cubugu TURE GORE degisir; duzen mockup'lardan birebir alindi:
      //   Ekranlar/satis_faturasi.html · satis_irsaliye_karti.html · satis_siparis_karti.html
      //   (Kaydet yesil, Sil kirmizi, e-Belge mavi, gruplar ayracla ayrilir.)
      // Ucu henuz olmayan islemler GORUNUR ama PASIF ve title'inda sebebi yazili -
      //   kullanici neyin gelecegini gorur, tikladiginda sessiz kalmaz.
      alt={
        <>
          {mevcutBelge
            ? <button className="d onay" disabled
                      title="Kesin belge düzenlenemez; değişiklik için iptal edip yeniden kesin (F7).">
                💾 Kaydet
              </button>
            : sonuc
              ? <button className="d onay" onClick={yeniBelge}>＋ Yeni Belge</button>
              : <button className="d onay" disabled={kaydediyor} onClick={() => void kes()}>
                  {kaydediyor ? '💾 Kaydediliyor…' : '💾 Kaydet'}
                </button>}
          <button className="d teh" disabled title="Belge iptali henüz bağlanmadı (F7).">
            🗑 Sil
          </button>

          <span className="ayrac" />

          {/* ---------------------------------------------------- SIPARIS ---- */}
          {siparisMi && (
            <>
              <button className="d bir" disabled title="Stok rezervasyonu henüz bağlanmadı.">
                🔒 Rezervasyon Yap
              </button>
              <button className="d" disabled={!kayitliId}
                      title={kayitliId ? 'Seçili satırları irsaliyeye aktar' : 'Önce siparişi kaydedin.'}
                      onClick={() => setDonusum(true)}>
                🚚 İrsaliyeye Dönüştür
              </button>
              <button className="d" disabled={!kayitliId}
                      title={kayitliId ? 'Seçili satırları faturaya aktar' : 'Önce siparişi kaydedin.'}
                      onClick={() => setDonusum(true)}>
                🧾 Faturaya Dönüştür
              </button>
              <button className="d" disabled title="Üretim emri henüz bağlanmadı.">🏭 Üretime Aktar</button>
              <span className="ayrac" />
              <button className="d" disabled={!kayitliId || !cari}
                      title={kayitliId ? 'Bu sipariş için ön ödeme (tahsilat) işlemi aç' : 'Önce siparişi kaydedin.'}
                      onClick={tahsilatAc}>
                💵 Ön Ödeme Al
              </button>
              <button className="d" disabled title="Termin güncelleme henüz bağlanmadı.">📅 Termin Güncelle</button>
              <button className="d" disabled title="Yazdırma henüz bağlanmadı.">🖨️ Yazdır</button>
            </>
          )}

          {/* --------------------------------------------------- IRSALIYE ---- */}
          {irsaliyeMi && (
            <>
              <button className="d bir" disabled={!kayitliId}
                      title={kayitliId ? 'e-İrsaliye gönderimi henüz bağlanmadı.' : 'Önce irsaliyeyi kaydedin.'}>
                ✉ e‑İrsaliye Gönder
              </button>
              <button className="d" disabled={!kayitliId}
                      title={kayitliId ? 'Sevk edilen satırları faturaya aktar' : 'Önce irsaliyeyi kaydedin.'}
                      onClick={() => setDonusum(true)}>
                🧾 Faturaya Dönüştür
              </button>
              <button className="d" disabled title="Sevk fişi yazdırma henüz bağlanmadı.">
                🖨️ Sevk Fişi Yazdır
              </button>
              <span className="ayrac" />
              <button className="d" disabled
                      title="Siparişten aktarım için Siparişler listesinden ilgili siparişi açıp Dönüştür deyin.">
                📋 Siparişten Aktar
              </button>
              <button className="d" disabled title="GİB durum sorgusu henüz bağlanmadı.">
                ⟳ GİB Durum Sorgula
              </button>
              <button className="d" disabled title="İade irsaliyesi henüz bağlanmadı.">
                ↩ İade İrsaliyesi
              </button>
            </>
          )}

          {/* ----------------------------------------------------- FATURA ---- */}
          {!siparisMi && !irsaliyeMi && (
            <>
              <button className="d bir" disabled={!kayitliId}
                      title={kayitliId ? 'e-Belge gönderimi henüz bağlanmadı.' : 'Önce belgeyi kaydedin.'}>
                📤 e‑Fatura Gönder
              </button>
              <button className="d" disabled={!kayitliId || !cari}
                      title={kayitliId ? 'Bu belge için tahsilat işlemi aç' : 'Önce belgeyi kaydedin.'}
                      onClick={tahsilatAc}>
                💵 Tahsilat
              </button>
              <button className="d" disabled title="İade belgesi henüz bağlanmadı.">↩ İade</button>
              <button className="d" disabled title="Yazdırma henüz bağlanmadı.">🖨️ Yazdır</button>
            </>
          )}

          <span className="ayrac" />

          <button className="d" onClick={kapat}>✖ Kapat</button>

          <label className="satir-ici">
            <input type="checkbox" checked={taslak} disabled={kilitli}
                   onChange={e => setTaslak(e.target.checked)} />
            Taslak (numara tüketmez)
          </label>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}

        {aciliyor && <div className="yukleniyor">Belge açılıyor…</div>}

        {sonuc && !mevcutBelge && (
        <div className="bilgi-kutusu">
          <b>Belge kaydedildi.</b>{' '}
          No: <b>{String(sonuc.belge.belgeNo || '(taslak — numara verilmedi)')}</b> ·
          Genel toplam: <b>{para.format(Number(sonuc.belge.genelToplam))}</b> ·
          <a href="#" onClick={e => { e.preventDefault(); kapat() }}> listede gör</a>
          {sonuc.uyarilar && sonuc.uyarilar.length > 0 && (
            <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
          )}
        </div>
      )}

        <div className="belge-hdr-sar">
          {/* Alan duzeni: Ekranlar/satis_irsaliye_karti.html .hdr + kullanici
              sirasi. BASLIKSIZ 3 sutunlu izgara; her alanda etiket EDITIN
              USTUNDE. Satirlar:
                1) Musteri . Belge No . e-Belge
                2) Vade . Belge Tarihi . Kapanma
                3) Satis Temsilcisi . Cikis Deposu . Doviz/Kur */}
          <div className="alan-izgara uc-sutun belge-hdr">
            {/* --- 1. satir --- */}
            {/* Cari alani GenLookup DEGIL: secim ayni TarafArama modalindan yapilir
                ki "yeni belge" akisiyla ayni ekran olsun (iki farkli cari secme
                bicimi kullaniciyi sasirtiyordu). */}
            <TarafAlani
              etiket={siparisMi || irsaliyeMi ? 'Müşteri (Cari)' : 'Cari'}
              zorunlu
              deger={cari?.unvan}
              kilitli={kilitli}
              ipucu="Cari ara"
              onAc={() => setCariArama(true)}
              hata={alanHatalari.tarafId}
            />

            <label className="alan">
              <span className="etiket">{irsaliyeMi ? 'İrsaliye No' : 'Belge No'}</span>
              <input className="one-cikan"
                     value={String(sonuc?.belge.belgeNo ?? '') || (kilitli ? '' : '(kaydedince verilir)')}
                     readOnly />
            </label>

            <label className="alan">
              <span className="etiket">e-Belge</span>
              <span className="deger-serit">
                <span className="rozet bilgi">{irsaliyeMi ? 'e-İrsaliye' : 'e-Fatura'}</span>
                {Number(sonuc?.belge.efaturaDurum ?? 0) > 0
                  ? <span className="rozet olumlu">✓ Gönderildi</span>
                  : <span className="rozet">gönderilmedi</span>}
              </span>
            </label>

            {/* --- 2. satir: Satis Temsilcisi cari'nin ALTINDA --- */}
            {/* Satis temsilcisi PERSONEL'dir (cari degil) ve secim cari ile ayni
                TarafArama ekranindan yapilir - tek arama bicimi. */}
            <TarafAlani
              etiket="Satış Temsilcisi"
              deger={satici?.ad}
              kilitli={kilitli}
              ipucu="Personel ara"
              onAc={() => setSaticiArama(true)}
            />

            <label className="alan">
              <span className="etiket zorunlu-isaret">
                {irsaliyeMi ? 'İrsaliye Tarihi' : 'Belge Tarihi'}
              </span>
              <input type="date" value={tarih} disabled={kilitli}
                     onChange={e => setTarih(e.target.value)} />
            </label>

            <label className="alan">
              <span className="etiket">{irsaliyeMi ? 'Faturalama Durumu' : 'Kapanma'}</span>
              <span className="deger-serit">
                {(() => {
                  const k = KAPANMA_ETIKET[Number(sonuc?.belge.kapanmaDurum ?? 0)];
                  return (
                    <>
                      <span className={`rozet ${k?.sinif ?? ''}`}>{k?.ad ?? '—'}</span>
                      {kayitliId > 0 && <span className="sonuk">{satirlar.length} kalem</span>}
                    </>
                  );
                })()}
              </span>
            </label>

            {/* --- 3. satir: Cikis Deposu temsilcinin ALTINDA --- */}
            <GenLookup
              kaynak="depo"
              etiket={siparisMi ? 'Depo' : 'Çıkış Deposu'}
              // Pasif depo secilemez: kapatilmis depoya belge kesilmesin.
              sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
              alanlar={LOOKUP_DEPO}
              deger={depo?.ad}
              saltOkunur={kilitli}
              onSec={s => setDepo(s ? { id: Number(s.id), ad: String(s.ad ?? '') } : null)}
            />

            {/* Irsaliyede Vade YOK (mal cikis tarihi belge tarihidir). */}
            {!irsaliyeMi && (
              <label className="alan">
                <span className="etiket">Vade (gün)</span>
                <input className="hiza-sag" value={vadeGun} disabled={kilitli}
                       onChange={e => setVadeGun(e.target.value)} />
              </label>
            )}

            <label className="alan">
              <span className="etiket">Döviz / Kur</span>
              <input value={`${String(sonuc?.belge.belgeDovizi ?? 'TL')} · ${
                Number(sonuc?.belge.dovizKuru ?? 1).toLocaleString('tr-TR', { minimumFractionDigits: 6 })}`}
                     readOnly />
            </label>

            {/* Adres BASLIKTAN CIKTI: e-Belge sekmesinde (XML'e giden alanlarla
                birlikte) duruyor. Seri de basliktan kaldirildi - kullanici
                girmiyor, numara serisi zaten e-Belge sekmesinde gorunuyor.

                Vergi Dairesi/VKN kartta gosterilmiyor: cari kartindan gelen ve
                belgeye DONDURULAN bir bilgi, e-Belge XML'ine oradan gidiyor. */}
            <label className="alan">
              <span className="etiket">{siparisMi ? 'Kaynak Belge' : 'Bağlı Sipariş'}</span>
              <span className="deger-serit">
                {sonuc?.belge.kaynakBelgeNo
                  ? <>{String(sonuc.belge.kaynakTurAdi ?? '')} <b>{String(sonuc.belge.kaynakBelgeNo)}</b></>
                  : <span className="sonuk">—</span>}
              </span>
            </label>

            {/* Belge turu SECICISI YOK: tur ekranin kendisinden gelir (Siparisler
                19, Irsaliyeler 14, Faturalar 15) ve pencere basliginda zaten yazili.
                Kartta degistirilebilir olmasi, kaydedilen belgenin hangi listede
                cikacagini belirsizlestiriyordu. */}
          </div>
        </div>

        {/* Sekmeler BASLIK ALANLARININ ALTINDA, grid'in hemen ustunde -
            mockup duzeni (toolbar > hdr > tabs > pane). Tasiyici ve Imza/Teslim
            yalniz irsaliyede anlamli, o yuzden suzuluyor. */}
        <div className="katab">
          {SEKMELER.filter(x => !x.irsaliye || irsaliyeMi).map(x => (
            <div key={x.anahtar}
                 className={`kat${x.anahtar === aktifSekme ? ' on' : ''}`}
                 onClick={() => setAktifSekme(x.anahtar)}>
              {x.baslik}
              {x.anahtar === 'kalem' && <span className="b">{satirlar.length}</span>}
              {x.anahtar === 'fatura' && donusumler.length > 0 && (
                <span className="b">{donusumler.length}</span>
              )}
            </div>
          ))}
        </div>

        {aktifSekme === 'kalem' && (
        <>
        <div className="kagrup">
          <h6>
            Kalemler
            {/* Dugmeler kesin belgede de GORUNUR, yalnizca pasif - kaybolunca
                kullanici "nereye gitti" diye ariyordu; sebebi title'da yazili. */}
            <button type="button" className="d bir" disabled={kilitli}
                    title={kilitli ? 'Kesin belgeye satır eklenemez (İptal edip yeniden kesin).' : 'Yeni kalem ekle'}
                    onClick={() => setStokArama(true)}>
              ＋ Satır
            </button>
            <button type="button" className="d teh"
                    disabled={kilitli || seciliSatirlar.size === 0}
                    title={kilitli ? 'Kesin belgeden satır silinemez.'
                          : seciliSatirlar.size === 0 ? 'Önce satır seçin' : 'Seçili satırları sil'}
                    onClick={seciliSil}>
              🗑 Sil{seciliSatirlar.size > 0 ? ` (${seciliSatirlar.size})` : ''}
            </button>
          </h6>

          {/* Grid SALT GORUNUM (mockup deseni): hucre ici input yok, satir secimi
              onay kutusuyla, ekleme/duzenleme ayri kalem penceresinde. Boylece
              satirlar okunakli kalir ve yanlislikla ustune yazilmaz. */}
          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th style={{ width: 30 }} className="hiza-orta">
                  <input type="checkbox"
                         checked={satirlar.length > 0 && seciliSatirlar.size === satirlar.length}
                         onChange={e => setSeciliSatirlar(
                           e.target.checked ? new Set(satirlar.map(x => x.anahtar)) : new Set())} />
                </th>
                <th style={{ width: 70 }} className="hiza-orta">Tip</th>
                <th style={{ width: 30 }} className="hiza-orta">#</th>
                <th style={{ width: 110 }}>Kod</th>
                <th>Stok / Hizmet</th>
                <th style={{ width: 200 }}>Açıklama</th>
                <th className="hiza-sag" style={{ width: 90 }}>Miktar</th>
                {!irsaliyeMi && <th className="hiza-sag" style={{ width: 80 }}>İskonto %</th>}
                {!irsaliyeMi && <th className="hiza-sag" style={{ width: 70 }}>KDV %</th>}
                <th className="hiza-sag" style={{ width: 100 }}>Br. Fiyat</th>
                <th className="hiza-sag" style={{ width: 120 }}>Tutar</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map((r, sira) => {
                const adet = Number(r.adet.replace(',', '.')) || 0;
                const fiyat = Number(r.birimFiyat.replace(',', '.')) || 0;
                const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);
                const secili = seciliSatirlar.has(r.anahtar);
                return (
                  <tr key={r.anahtar} className={secili ? 'secili' : ''}
                      onDoubleClick={() => !kilitli && setKalem(r)}>
                    <td className="hiza-orta">
                      <input type="checkbox" checked={secili}
                             onChange={() => secimDegis(r.anahtar)} />
                    </td>
                    <td className="hiza-orta">
                      <span className={`rozet ${r.satirTur === 2 ? 'bilgi' : ''}`}>
                        {r.satirTur === 2 ? 'Hizmet' : 'Stok'}
                      </span>
                    </td>
                    <td className="hiza-orta sonuk">{sira + 1}</td>
                    <td><code>{r.stokKodu}</code></td>
                    <td>{r.stokAdi || <span className="sonuk">(stok seçilmedi)</span>}</td>
                    <td className="sonuk">{r.aciklama}</td>
                    <td className="hiza-sag">{adet.toLocaleString('tr-TR')}</td>
                    {/* Iki iskonto varsa ikisi de gorunsun: "%10 + %5". */}
                    {!irsaliyeMi && <td className="hiza-sag">{iskonatoMetni(r)}</td>}
                    {!irsaliyeMi && <td className="hiza-sag">%{r.kdv}</td>}
                    <td className="hiza-sag">{para.format(fiyat)}</td>
                    <td className="hiza-sag"><b>{para.format(tutar)}</b></td>
                  </tr>
                );
              })}
              {satirlar.length === 0 && (
                <tr><td colSpan={irsaliyeMi ? 7 : 9} className="bos">
                  Kalem yok — “＋ Satır” ile ekleyin.
                </td></tr>
              )}
            </tbody>
            <tfoot>
              <tr className="genel">
                <td colSpan={6} className="hiza-sag">TOPLAM</td>
                <td className="hiza-sag">
                  {satirlar.reduce((t, r) => t + (Number(r.adet.replace(',', '.')) || 0), 0)
                           .toLocaleString('tr-TR')}
                </td>
                <td colSpan={irsaliyeMi ? 1 : 3} />
                <td className="hiza-sag">{para.format(onizleme.matrah)}</td>
              </tr>
            </tfoot>
          </table>
          {!kilitli && satirlar.length > 0 && (
            <div className="not">Satırı düzenlemek için çift tıklayın.</div>
          )}
        </div>

        <div className="kagrup dip-toplam">
          <h6>{sonuc ? 'Dip Toplam (sunucu)' : 'Dip Toplam (önizleme)'}</h6>
          {sonuc ? (
            <table className="dip-tablo">
              <tbody>
                {sonuc.dipToplam.map((d, i) => (
                  <tr key={i} className={d.tur === 20 ? 'genel' : ''}>
                    <td>{d.aciklama}</td>
                    <td className="hiza-sag">{para.format(d.deger)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : (
            <table className="dip-tablo">
              <tbody>
                <tr><td>Ara Toplam</td><td className="hiza-sag">{para.format(onizleme.matrah)}</td></tr>
                <tr><td>KDV</td><td className="hiza-sag">{para.format(onizleme.kdv)}</td></tr>
                <tr className="genel"><td>Genel Toplam</td><td className="hiza-sag">{para.format(onizleme.genel)}</td></tr>
              </tbody>
            </table>
          )}
          {!kilitli && <div className="not">Kesin tutar sunucuda hesaplanır; buradaki değerler önizlemedir.</div>}
        </div>
        </>
        )}

        {/* ========================================= TASIYICI / SEVKIYAT ==== */}
        {aktifSekme === 'tasiyici' && (
          <div className="kagrup">
            <h6>Taşıyıcı Bilgileri</h6>
            <div className="alan-izgara uc-sutun">
              <GenLookup
                kaynak="cari"
                etiket="Taşıyıcı Ünvan"
                alanlar={LOOKUP_CARI}
                deger={tasiyici?.ad}
                saltOkunur={kilitli}
                onSec={s => setTasiyici(s ? { id: Number(s.id), ad: String(s.unvan ?? '') } : null)}
              />
              <GenLookup
                kaynak="cari"
                etiket="Teslim Eden"
                alanlar={LOOKUP_CARI}
                deger={teslimEden?.ad}
                saltOkunur={kilitli}
                onSec={s => setTeslimEden(s ? { id: Number(s.id), ad: String(s.unvan ?? '') } : null)}
              />
              <label className="alan">
                <span className="etiket">Teslim Şekli</span>
                <select value={teslimSekli} disabled={kilitli}
                        onChange={e => setTeslimSekli(Number(e.target.value))}>
                  {TESLIM_SEKLI.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
                </select>
              </label>
              <label className="alan genis-2">
                <span className="etiket">Sevk Adresi</span>
                <input value={[sonuc?.belge.tarafAdres, sonuc?.belge.tarafIlce, sonuc?.belge.tarafIl]
                                .filter(Boolean).join(' / ')} readOnly
                       placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
              </label>
              <label className="alan">
                <span className="etiket">Sevk Zamanı</span>
                <input type="datetime-local" value={sevkTarihi} disabled={kilitli}
                       onChange={e => setSevkTarihi(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Araç Plakası</span>
                <input value={aracPlaka} maxLength={20} disabled={kilitli}
                       placeholder="07 ABC 145"
                       onChange={e => setAracPlaka(e.target.value.toUpperCase())} />
              </label>
              <label className="alan">
                <span className="etiket">Şoför Adı</span>
                <input value={soforAd} maxLength={60} disabled={kilitli}
                       onChange={e => setSoforAd(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">Şoför TC</span>
                <input value={soforTckn} maxLength={11} disabled={kilitli}
                       placeholder="11 hane"
                       onChange={e => setSoforTckn(e.target.value.replace(/\D/g, ''))} />
              </label>
            </div>
            <div className="not">
              Bu alanlar e-İrsaliye UBL'ine gider (TransportMeans/PlateID,
              DriverPerson, CarrierParty, ShipmentStage). Kap adedi, brüt ağırlık
              ve sevkiyat aşamaları (yola çıkış / teslim) henüz şemada yok.
            </div>
          </div>
        )}

        {/* ================================================== e-BELGE ==== */}
        {aktifSekme === 'ebelge' && (
          <div className="kagrup">
            <h6>e-Belge Zarf Bilgisi</h6>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">Belge Tipi</span>
                <input value={irsaliyeMi ? 'e-İrsaliye' : 'e-Fatura'} readOnly />
              </label>
              <label className="alan">
                <span className="etiket">Seri</span>
                <input value={String(sonuc?.belge.belgeSeri ?? seri)} readOnly />
              </label>
              <label className="alan">
                <span className="etiket">Alias (URN)</span>
                <input value={String(sonuc?.belge.gondericiAlias ?? '') || '—'} readOnly />
              </label>
              {/* Adres basliktan buraya tasindi: e-Belge XML'ine giden alici
                  bilgisi, kesim sirasinda degil gonderim baglaminda okunuyor. */}
              <label className="alan genis-2">
                <span className="etiket">Adres</span>
                <input value={[sonuc?.belge.tarafAdres, sonuc?.belge.tarafIlce, sonuc?.belge.tarafIl]
                                .filter(Boolean).join(' / ')} readOnly
                       placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
              </label>
              <label className="alan">
                <span className="etiket">Durum</span>
                <span className="deger-serit">
                  {Number(sonuc?.belge.efaturaDurum ?? 0) > 0
                    ? <span className="rozet olumlu">Gönderildi</span>
                    : <span className="rozet">Kâğıt / gönderilmedi</span>}
                </span>
              </label>
            </div>
            <div className="not">
              ETTN, zarf numarası, gönderim zamanı ve GİB yanıtı e-Belge kuyruğundan
              (e_belge tablosu) gelecek — gönderim ucu henüz bağlanmadı.
            </div>
          </div>
        )}

        {/* =============================================== FATURALAMA ==== */}
        {aktifSekme === 'fatura' && (
          <div className="kagrup">
            <h6>
              Faturalama
              {kayitliId > 0 && (
                <button type="button" className="d bir" onClick={() => setDonusum(true)}>
                  🧾 Faturaya Dönüştür
                </button>
              )}
            </h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th style={{ width: 160 }}>Belge No</th>
                  <th style={{ width: 100 }}>Tarih</th>
                  <th>Tür</th>
                  <th className="hiza-sag" style={{ width: 100 }}>Miktar</th>
                  <th className="hiza-sag" style={{ width: 130 }}>Tutar</th>
                  <th style={{ width: 90 }}>Durum</th>
                </tr>
              </thead>
              <tbody>
                {donusumler.map((d, i) => (
                  <tr key={i}>
                    <td><b>{String(d.belgeNo ?? '')}</b></td>
                    <td>{String(d.belgeTarihi ?? '').slice(0, 10).split('-').reverse().join('.')}</td>
                    <td>{String(d.turAdi ?? '')}</td>
                    <td className="hiza-sag">{Number(d.miktar ?? 0).toLocaleString('tr-TR')}</td>
                    <td className="hiza-sag">{para.format(Number(d.tutar ?? 0))}</td>
                    <td>{String(d.durumAdi ?? '')}</td>
                  </tr>
                ))}
                {donusumler.length === 0 && (
                  <tr><td colSpan={6} className="bos">
                    {kayitliId > 0 ? 'Bu belgeden henüz belge türetilmemiş.' : 'Önce belgeyi kaydedin.'}
                  </td></tr>
                )}
              </tbody>
            </table>
          </div>
        )}

        {/* ============================================= IMZA / TESLIM ==== */}
        {aktifSekme === 'imza' && (
          <div className="kagrup">
            <h6>İmza / Teslim Alan</h6>
            <div className="not">
              Teslim alan kişi, TC, görev, teslim zamanı, nüsha sayısı ve teslim notu
              alanları henüz şemada yok — e-İrsaliye teslim onayı akışıyla gelecek.
              İmzalı teslim belgesi şimdilik Yorum / Medya sekmesine eklenebilir.
            </div>
          </div>
        )}

        {/* ============================================= YORUM / MEDYA ==== */}
        {aktifSekme === 'yorum' && (
          <div className="kagrup">
            <h6>Yorum / Medya</h6>
            {kayitliId > 0
              ? <DokumanGalerisi kartAdi="belge" kaynakId={kayitliId} saltOkunur={false} />
              : <div className="not">Belge kaydedilince ek ve yorum eklenebilir.</div>}
          </div>
        )}

        {/* Kalem penceresi: grid salt gorunum oldugu icin ekleme/duzenleme burada.
            Alanlar ture gore degisir (irsaliyede seri/lot, faturada iskonto/KDV). */}
        {/* 0) Cari secimi - yeni belgenin ilk adimi. */}
        <TarafArama
          acik={cariArama}
          kaynaklar={['cari']}
          yerTutucu="Müşteri / tedarikçi ara…"
          onKapat={() => setCariArama(false)}
          onSec={sec => {
            setCari({ id: sec.id, unvan: sec.unvan });
            setCariArama(false);
          }}
        />

        {/* 0b) Satis temsilcisi - ayni ekran, kaynak personel. */}
        <TarafArama
          acik={saticiArama}
          kaynaklar={['personel']}
          yerTutucu="Personel ara…"
          onKapat={() => setSaticiArama(false)}
          onSec={sec => {
            setSatici({ id: sec.id, ad: sec.unvan });
            setSaticiArama(false);
          }}
        />

        {/* 1) Stok/hizmet arama - satir eklemenin BASLANGICI. Secim yapilinca
               kapanmaz; kalem penceresi ustune acilir, o kapaninca buraya donulur
               ve siradaki stok secilir (ardisik hizli giris). */}
        {stokArama && (
          <StokAramaPenceresi
            etkin={kalem === null}
            onKapat={() => setStokArama(false)}
            onSec={sec => {
              const hizmet = sec.tip === 'hizmet';
              // Secim "Son / Sik Aranan" sayacina islensin - listede oldugu gibi.
              void api.aramaIsaretle(hizmet ? 'hizmet' : 'stok', Number(sec.id));
              setKalem({
                ...bosSatir(Math.max(0, ...satirlar.map(x => x.anahtar)) + 1),
                satirTur: hizmet ? 2 : 1,
                stokId: hizmet ? null : Number(sec.id),
                hizmetId: hizmet ? Number(sec.id) : null,
                stokKodu: String(sec.kod ?? ''),
                stokAdi: String(sec.ad ?? ''),
                kdv: sec.kdv !== undefined && sec.kdv !== null ? String(sec.kdv) : '20',
                // Kart fiyati onyuklenir - kullanici zaten listede gorup seciyor;
                //   pencerede degistirebilir. Fiyatin PARA BIRIMI de gelir: yerel
                //   degilse kalem penceresi kur + yerel karsilik satirini acar.
                fiyatDovizi: String(sec.fiyatDovizi ?? YEREL_PARA) || YEREL_PARA,
                dovizFiyat: sec.fiyat ? String(sec.fiyat) : '',
                birimFiyat: sec.fiyat ? String(sec.fiyat) : '',
              });
            }}
          />
        )}

        {/* 2) Adet / birim fiyat - Enter satiri gride ekler ve buraya doner. */}
        {kalem !== null && (
          <KalemPenceresi
            satir={kalem}
            irsaliyeMi={irsaliyeMi}
            belgeTarihi={tarih}
            onKapat={() => setKalem(null)}
            onKaydet={r => { kalemKaydet(r); setKalem(null) }}
          />
        )}

        {/* Donusum modali bu kartin USTUNDE acilir: hedef turu ve satir miktarlari
            orada secilir, kalan bu belgede kalir (F8). */}
        {donusum && kayitliId > 0 && (
          <BelgeDonusumModali
            belgeId={kayitliId}
            belgeTur={tur}
            onKapat={() => setDonusum(false)}
            onTamam={() => onKaydedildi?.()}
          />
        )}
      </>
    </Modal>
  );
}

/**
 * Stok / hizmet arama penceresi - satir eklemenin ilk adimi.
 *
 * Secim yapilinca KAPANMAZ: cagiran uzerine kalem (adet/fiyat) penceresini acar,
 * o kapaninca kullanici buradan siradaki stogu secer. Boylece on kalemlik bir
 * irsaliye tek arama penceresiyle girilir.
 */
function StokAramaPenceresi({ etkin, onSec, onKapat }: {
  /** Ustunde kalem penceresi acikken false olur; true'ya donunce arama
      kutusuna odak GERI GELIR (ardisik girişte fare gerekmesin). */
  etkin: boolean;
  onSec(satir: ListeSatiri): void;
  onKapat(): void;
}) {
  const [arama, setArama] = useState('');
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState(0);
  /** Liste / Son Aranan / Sik Aranan - GenGrid ile ayni (kullanici_arama). */
  const [aramaGorunumu, setAramaGorunumu] = useState<'tum' | 'son' | 'sik'>('tum');
  const zamanlayici = useRef<number | undefined>(undefined);
  const kutu = useRef<HTMLInputElement | null>(null);

  // STOK ve HIZMET birlikte aranir: belge satiri ikisinden birine baglanabilir,
  //   kullanicinin once "hangi listede acayim" diye dusunmesi gereksiz. Iki
  //   kaynak paralel cekilir ve tip alaniyla isaretlenir.
  const ara = useCallback(async (metin: string, gorunumSecimi: 'tum' | 'son' | 'sik' = 'tum') => {
    setYukleniyor(true);
    setHata(null);
    try {
      const filtre = metin.trim()
        ? { op: 'or' as const, kosullar: ['kod', 'ad'].map(alan => ({
            alan, op: 'icerir' as const, deger: metin.trim() })) }
        : undefined;

      // gorunum: Son/Sik Aranan sunucuda kullanici_arama ile suzulur+siralanir.
      const gorunum = gorunumSecimi === 'tum' ? undefined : gorunumSecimi;
      const [stoklar, hizmetler] = await Promise.all([
        api.liste('stok',   { sayfa: 1, boyut: 25, filtre, gorunum }),
        api.liste('hizmet', { sayfa: 1, boyut: 25, filtre, gorunum }),
      ]);

      const birlesik: ListeSatiri[] = [
        ...stoklar.satirlar.map((r): ListeSatiri => ({ ...r, tip: 'stok' })),
        ...hizmetler.satirlar.map((r): ListeSatiri => ({ ...r, tip: 'hizmet' })),
      ].sort((a, b) => String(a.ad ?? '').localeCompare(String(b.ad ?? ''), 'tr'));

      setSatirlar(birlesik);
      setSecili(0);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      setSatirlar([]);
    } finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void ara(arama, aramaGorunumu) }, [ara, aramaGorunumu]);  // eslint-disable-line react-hooks/exhaustive-deps

  // Pencere one gelince (acilista ve kalem penceresi kapaninca) imlec aramada.
  useEffect(() => { if (etkin) kutu.current?.focus() }, [etkin]);

  const yaz = (metin: string) => {
    setArama(metin);
    window.clearTimeout(zamanlayici.current);
    zamanlayici.current = window.setTimeout(() => void ara(metin, aramaGorunumu), 250);
  };

  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(i => Math.min(i + 1, satirlar.length - 1)) }
    else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(i => Math.max(i - 1, 0)) }
    else if (e.key === 'Enter' && satirlar[secili]) { e.preventDefault(); onSec(satirlar[secili]) }
  };

  return (
    <Modal
      baslik="Stok / Hizmet Ara"
      onKapat={onKapat}
      alt={<button className="d" onClick={onKapat}>✖ Kapat</button>}
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="kagrup">
          {/* Arama kutusu ve Liste/Son/Sik dugmeleri LISTE EKRANLARIYLA ayni
              (GenGrid deseni) - kullanici ayni araci iki farkli bicimde
              ogrenmek zorunda kalmasin. */}
          <div className="cipler" style={{ margin: 10 }}>
            <div className="ara" style={{
              maxWidth: 260, margin: 0, height: 23, borderRadius: 12,
              background: 'var(--yuz)', color: 'var(--yazi)', border: '1px solid var(--cizgi)',
            }}>
              <span>🔍</span>
              <input
                ref={kutu}
                autoFocus
                style={{ border: 0, background: 'transparent', outline: 'none', width: '100%', color: 'inherit' }}
                placeholder="Stok ya da hizmet ara…"
                value={arama}
                onChange={e => yaz(e.target.value)}
                onKeyDown={tus}
              />
            </div>

            <div className="durumseg">
              <button className={`ikon-liste ${aramaGorunumu === 'tum' ? 'on' : ''}`}
                      title="Tüm Liste" onClick={() => setAramaGorunumu('tum')}>☰</button>
              <button className={`ikon-liste ${aramaGorunumu === 'son' ? 'on' : ''}`}
                      title="Son Aranan" onClick={() => setAramaGorunumu('son')}>🕓</button>
              <button className={`ikon-liste ${aramaGorunumu === 'sik' ? 'on' : ''}`}
                      title="Sık Aranan" onClick={() => setAramaGorunumu('sik')}>⭐</button>
            </div>
          </div>
          <table className="detay-tablo secilebilir">
            <thead>
              <tr>
                <th style={{ width: 70 }} className="hiza-orta">Tip</th>
                <th style={{ width: 130 }}>Kod</th>
                <th>Ad</th>
                <th className="hiza-sag" style={{ width: 90 }}>Kalan</th>
                <th className="hiza-sag" style={{ width: 100 }}>Fiyat</th>
                <th style={{ width: 60 }} className="hiza-orta">Döviz</th>
                <th style={{ width: 110 }} className="hiza-orta">İzleme</th>
                <th className="hiza-sag" style={{ width: 70 }}>KDV</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map((r, i) => (
                <tr key={`${r.tip}-${r.id}`} className={i === secili ? 'secili' : ''}
                    onMouseEnter={() => setSecili(i)}
                    onClick={() => onSec(r)}>
                  <td className="hiza-orta">
                    <span className={`rozet ${r.tip === 'hizmet' ? 'bilgi' : ''}`}>
                      {r.tip === 'hizmet' ? 'Hizmet' : 'Stok'}
                    </span>
                  </td>
                  <td><code>{String(r.kod ?? '')}</code></td>
                  <td>{String(r.ad ?? '')}</td>
                  {/* Kalan ve izleme yalniz STOKTA anlamli - hizmette stok bakiyesi yok. */}
                  <td className="hiza-sag">
                    {r.tip === 'hizmet' ? <span className="sonuk">—</span>
                      : Number(r.kalan ?? 0).toLocaleString('tr-TR')}
                  </td>
                  <td className="hiza-sag">
                    {r.fiyat ? para.format(Number(r.fiyat)) : <span className="sonuk">—</span>}
                  </td>
                  <td className="hiza-orta sonuk">{String(r.fiyatDovizi ?? '') || '—'}</td>
                  <td className="hiza-orta">
                    {r.tip === 'hizmet' ? <span className="sonuk">—</span>
                      : String(r.izlemeAdi ?? 'Yok') === 'Yok'
                        ? <span className="sonuk">Yok</span>
                        : <span className="rozet bilgi">{String(r.izlemeAdi)}</span>}
                  </td>
                  <td className="hiza-sag">%{String(r.kdv ?? 0)}</td>
                </tr>
              ))}
              {!yukleniyor && satirlar.length === 0 && (
                <tr><td colSpan={8} className="bos">Kayıt yok</td></tr>
              )}
            </tbody>
          </table>
          {yukleniyor && <div className="yukleniyor">Aranıyor…</div>}
        </div>
      </>
    </Modal>
  );
}

/**
 * Adet / birim fiyat penceresi. Kalemler gridi SALT GORUNUM oldugu icin
 * ekleme/duzenleme buradan yapilir - hucre ici duzenlemede satir yanlislikla
 * ustune yaziliyor ve uzun stok adlari okunmuyordu.
 */
/**
 * "+/−" dugmeleri: 1 artirir/azaltir. Alt sinir 1 - eksi (ve sifir) miktar
 * belge satirinda anlamsiz, dugmeyle oraya inilemez.
 */
function adetKaydir(deger: string, yon: number): string {
  const sayi = Number(deger.replace(',', '.')) || 0;
  const yeni = Math.max(1, sayi + yon);
  return Number.isInteger(yeni) ? String(yeni) : yeni.toFixed(2).replace('.', ',');
}

function KalemPenceresi({ satir, irsaliyeMi, belgeTarihi, onKapat, onKaydet }: {
  satir: SatirDurumu;
  irsaliyeMi: boolean;
  /** Kur bu tarihten okunur (belge tarihi) - bugunun kuru degil. */
  belgeTarihi: string;
  onKapat(): void;
  onKaydet(r: SatirDurumu): void;
}) {
  const [r, setR] = useState<SatirDurumu>(satir);
  const [hata, setHata] = useState<string | null>(null);
  /** Kur kutusu kullanici tarafindan degistirildi mi - degistiyse ustune yazma. */
  const kurElle = useRef(false);

  const degis = (alan: keyof SatirDurumu, deger: string) =>
    setR(x => ({ ...x, [alan]: deger }));

  /** Enter = Tamam: adet/fiyat yazip Enter'a basinca satir gride eklenir. */
  const tus = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') { e.preventDefault(); kaydet() }
  };

  const dovizli = r.fiyatDovizi !== YEREL_PARA && r.fiyatDovizi !== '';

  // Dovizli kalemde gunun kuru cekilir; kullanici kutuyu elle degistirdiyse
  //   dokunulmaz (kur pazarlikli olabiliyor - "istenirse degistirilebilsin").
  useEffect(() => {
    if (!dovizli || kurElle.current) return;
    void (async () => {
      try {
        const y = await api.dovizKur(r.fiyatDovizi, belgeTarihi);
        if (y.kur && y.kur > 0 && !kurElle.current) setR(x => ({ ...x, kur: String(y.kur) }));
      } catch { /* kur yoksa kullanici elle girer */ }
    })();
  }, [dovizli, r.fiyatDovizi, belgeTarihi]);

  const adet = Number(r.adet.replace(',', '.')) || 0;
  const kur = dovizli ? (Number(r.kur.replace(',', '.')) || 0) : 1;
  const dovizFiyat = Number(r.dovizFiyat.replace(',', '.')) || 0;
  // Yerel birim fiyat: dovizli kalemde doviz fiyati x kur, degilse dogrudan girilen.
  const fiyat = dovizli
    ? Math.round(dovizFiyat * kur * 100) / 100
    : (Number(r.birimFiyat.replace(',', '.')) || 0);
  const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);

  function kaydet() {
    if (!r.stokId && !r.hizmetId) { setHata('Stok ya da hizmet seçilmeli.'); return }
    if (adet <= 0) { setHata('Miktar sıfırdan büyük olmalı.'); return }
    if (dovizli && kur <= 0) { setHata('Kur sıfırdan büyük olmalı.'); return }
    // Belgeye YEREL fiyat gider; doviz/kur bilgisi satirda saklanir ki kalem
    //   tekrar acildiginda ayni degerlerle gelsin.
    onKaydet({ ...r, birimFiyat: String(fiyat) });
  }

  return (
    <Modal
      baslik={r.stokAdi || 'Kalem'}
      dar
      onKapat={onKapat}
      alt={
        <>
          <button className="d onay" onClick={kaydet}>💾 Tamam (Enter)</button>
          <button className="d" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {/* Cerceve kalir, BASLIK yok: pencere basligi zaten stok/hizmet adi. */}
        <div className="kagrup">
          {/* Alanlar ALT ALTA ve giris sirasinda: Miktar > Birim Fiyat > KDV >
              Iskonto. Stok/hizmet adi PENCERE BASLIGINDA yaziyor - burada
              tekrarlamak yer kaplamaktan baska ise yaramiyordu. */}
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket">Miktar</span>
              <span className="ikili">
                {/* Eksi isareti elle de yazilamaz. Yukari/asagi ok = +1 / -1. */}
                <input autoFocus className="hiza-sag" value={r.adet}
                       onKeyDown={e => {
                         if (e.key === 'ArrowUp') { e.preventDefault(); degis('adet', adetKaydir(r.adet, +1)) }
                         else if (e.key === 'ArrowDown') { e.preventDefault(); degis('adet', adetKaydir(r.adet, -1)) }
                         else tus(e);
                       }}
                       onChange={e => degis('adet', e.target.value.replace(/-/g, ''))} />
                {/* Fare ile hizli artir/azalt - klavyeden yazmak da serbest. */}
                <button type="button" className="mini" title="Azalt"
                        onClick={() => degis('adet', adetKaydir(r.adet, -1))}>−</button>
                <button type="button" className="mini" title="Artır"
                        onClick={() => degis('adet', adetKaydir(r.adet, +1))}>+</button>
              </span>
            </label>

            {/* Birim fiyat KARTIN para biriminde girilir (stok arama ekraninda
                gorulen fiyat/doviz). Yerel para disindaysa yaninda gunun kuru
                (elle degistirilebilir) ve ALTINDA yerel karsilik satiri cikar. */}
            <label className="alan">
              <span className="etiket">Birim Fiyat</span>
              <span className="ikili">
                <input className="hiza-sag"
                       value={dovizli ? r.dovizFiyat : r.birimFiyat} onKeyDown={tus}
                       onChange={e => degis(dovizli ? 'dovizFiyat' : 'birimFiyat', e.target.value)} />
                <input className="birim" value={r.fiyatDovizi || YEREL_PARA} readOnly tabIndex={-1} />
                {dovizli && (
                  <input className="hiza-sag kur" value={r.kur} onKeyDown={tus}
                         title="Günlük kur — değiştirilebilir"
                         onChange={e => { kurElle.current = true; degis('kur', e.target.value) }} />
                )}
              </span>
            </label>

            {dovizli && (
              <label className="alan">
                <span className="etiket">Yerel Para</span>
                <span className="ikili">
                  <input className="hiza-sag onizleme" value={para.format(fiyat)} readOnly />
                  <input className="birim" value={YEREL_PARA} readOnly tabIndex={-1} />
                </span>
              </label>
            )}

            {/* Iskonto ve KDV HER TURDE girilir - irsaliyede de matrah/KDV
                hesaplanir (dip toplam ondan cikar), yalniz gridde gosterilmez. */}
            <label className="alan">
              <span className="etiket">KDV %</span>
              <select value={r.kdv} onKeyDown={tus}
                      onChange={e => degis('kdv', e.target.value)}>
                {/* Stok kartindan gelen oran listede yoksa kaybolmasin. */}
                {(KDV_ORANLARI as readonly number[]).includes(Number(r.kdv))
                  ? null : <option value={r.kdv}>%{r.kdv}</option>}
                {KDV_ORANLARI.map(o => <option key={o} value={o}>%{o}</option>)}
              </select>
            </label>

            {/* Iki kademeli iskonto: ikincisi birincinin ARDINDAN carpimsal
                uygulanir (sunucudaki BelgeHesap.SatirTutari ile ayni sira). */}
            <label className="alan">
              <span className="etiket">İskonto %</span>
              <span className="ikili">
                <input className="hiza-sag" value={r.iskonto} onKeyDown={tus}
                       title="1. iskonto"
                       onChange={e => degis('iskonto', e.target.value)} />
                <input className="hiza-sag" value={r.iskonto2} onKeyDown={tus}
                       title="2. iskonto (birincinin ardindan uygulanir)"
                       onChange={e => degis('iskonto2', e.target.value)} />
              </span>
            </label>

            {irsaliyeMi && (
              <label className="alan">
                <span className="etiket">Seri / Lot</span>
                <input value={r.izlemeKodu} placeholder="LOT / seri" onKeyDown={tus}
                       onChange={e => degis('izlemeKodu', e.target.value)} />
              </label>
            )}

            <label className="alan">
              <span className="etiket">Açıklama</span>
              <input value={r.aciklama} onKeyDown={tus} placeholder="Satır açıklaması"
                     onChange={e => degis('aciklama', e.target.value)} />
            </label>

            <label className="alan">
              <span className="etiket">Tutar (önizleme)</span>
              <input className="hiza-sag onizleme" value={para.format(tutar)} readOnly />
            </label>
          </div>
        </div>
      </>
    </Modal>
  );
}
