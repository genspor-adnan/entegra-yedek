import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import {
  ApiHatasi,
  type KartAlanMeta, type KartDetayMeta, type KartMetaYaniti, type KartYetkisi,
} from '../api/sozlesme';
import { GenDetayTablo, type DetayDurumu, bosDetay, detayFarki } from './GenDetayTablo';
import { IlgiliKisiler } from './IlgiliKisiler';
import { TekAdres } from './TekAdres';
import { TekOzluk } from './TekOzluk';
import { PersonelKimlikOzet } from './PersonelKimlikOzet';
import { RolYetkiMatrisi } from './RolYetkiMatrisi';
import { DokumanGalerisi } from './DokumanGalerisi';
import { TarafArama } from './TarafArama';
import { epostaGecerliMi } from './alanBicim';
import { TelefonGirdi } from './TelefonGirdi';

interface Props {
  kaynak: string;
  id: number | 'yeni';
  baslik?: string;
  onKapat?(): void;
  onKaydedildi?(id: number): void;
  /** Mockup'ta olup backend'i henuz olmayan sekmeler (or. "UTS Bilgileri") - "yakinda" gosterilir. */
  yerTutucuSekmeler?: string[];
  /** "Genel" sekmesinde alt-bolum kutularinin YANINA mockup'taki gibi bos "Resim" kutusu ekler. */
  resimYerTutucu?: boolean;
  /** TarafArama'nin kendi Yeni/Duzenle'siyle acilan ic-ice Kisi Karti'nda "Cariye Bağla"
      butonu GIZLENIR - yoksa TarafArama'nin icinden bir baska TarafArama acilir, tekrarli/
      kafa karistirici olur (kullanici). */
  cariyeBaglaGizli?: boolean;
}

/** Modal sarmalayici — mockup'taki .kaperde / .kawin duzeni. */
function Modal({ baslik, ustBilgi, ustSerit, sekmeBar, alt, onKapat, children }: {
  baslik: string;
  ustBilgi?: React.ReactNode;
  ustSerit?: React.ReactNode;
  sekmeBar?: React.ReactNode;
  alt: React.ReactNode;
  onKapat?(): void;
  children: React.ReactNode;
}) {
  useEffect(() => {
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') onKapat?.() };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  }, [onKapat]);

  return (
    <div className="kaperde" onMouseDown={e => { if (e.target === e.currentTarget) onKapat?.() }}>
      <div className="kawin genis" onMouseDown={e => e.stopPropagation()}>
        <div className="kabas">
          <span>{baslik}</span>
          {ustBilgi}
          <span className="kapt">Esc ile kapanir</span>
        </div>
        {/* Mockup: Kaydet/Sil/Yazdir/Kapat baslikla idstrip ARASINDA arac cubugu (alt degil). */}
        <div className="katoolbar">{alt}</div>
        {ustSerit}
        {sekmeBar}
        <div className="kagov">{children}</div>
      </div>
    </div>
  );
}

/** Kart ici sekme: alan grubu, detay tablosu, ya da henuz baglanmamis yer tutucu. */
type SekmeTanimi =
  | { tur: 'grup'; anahtar: string; baslik: string; alanlar: KartAlanMeta[] }
  | { tur: 'detay'; anahtar: string; baslik: string; detay: KartDetayMeta }
  | { tur: 'yerTutucu'; anahtar: string; baslik: string }
  // Generic Detay mekanizmasina uymayan kaynaga-ozel sekmeler (ör. Rol > Yetki Matrisi).
  | { tur: 'ozel'; anahtar: string; baslik: string };

const detaySekmeAnahtari = (detayAd: string) => `d:${detayAd}`;
const grupSekmeAnahtari = (grupAd: string) => `g:${grupAd}`;

/** Sekme DEGIL, ust seritte sabit gorunen grup (mockup idstrip). */
const KIMLIK_GRUP = 'Kimlik';

type Deger = string | number | boolean | null;

// "epostaWeb"/"aliasEposta" DAHIL DEGIL - role gore URL/GIB-URN-alias de tutabiliyor
// (taraf.eposta_web/alias_eposta yorumlari), sadece duz "eposta" alani her zaman e-posta.
const EPOSTA_ALANLARI = new Set(['eposta']);
const TELEFON_ALANLARI = new Set(['telefon', 'cepTel']);

/**
 * Kart sozlesmesini (§3) tuketen genel form.
 *
 *  - Alan listesi, etiketler, zorunluluk ve uzunluk sinirlari SUNUCUDAN gelir
 *    (/alanlar). Yetkisiz alan hic donmedigi icin arayuzde gizleme mantigi yok.
 *  - Kaydetmede `surum` geri gonderilir; baskasi degistirmisse sunucu 409 doner ve
 *    kullaniciya "guncel hali al" secenegi sunulur (§1.3).
 *  - Alan hatalari (`alanlar[]`) ilgili girdinin altina yazilir.
 *  - Detaylar FARK olarak gonderilir (eklenen / degisen / silinen), tam liste degil.
 */
export function GenForm({ kaynak, id, baslik, onKapat, onKaydedildi, yerTutucuSekmeler, resimYerTutucu, cariyeBaglaGizli }: Props) {
  const yeniMi = id === 'yeni';

  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  const [deger, setDeger] = useState<Record<string, Deger>>({});
  const [ilkDeger, setIlkDeger] = useState<Record<string, Deger>>({});
  const [surum, setSurum] = useState<string | undefined>();
  const [yetki, setYetki] = useState<KartYetkisi>({ duzenle: false, sil: false, gizliAlanlar: [] });
  const [detaylar, setDetaylar] = useState<Record<string, DetayDurumu>>({});

  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});
  const [cakisma, setCakisma] = useState<{ alanlar: string[]; guncel: Record<string, unknown> } | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);
  const [cariyeBaglaAcik, setCariyeBaglaAcik] = useState(false);
  // TarafArama'dan bir KISI secilirse "public.v_cari_lookup" (KodTablosu) onu bilmiyor -
  // secim sonrasi ad gorunsun diye adini ayrica burada tutuyoruz (server'a etkisi yok).
  const [bagliTarafAdi, setBagliTarafAdi] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    setHata(null);
    try {
      const m = await api.kartAlanlari(kaynak);
      setMeta(m);
      setYetki(m.yetki);

      const bosDetaylar: Record<string, DetayDurumu> = {};
      m.detaylar.forEach(d => { bosDetaylar[d.ad] = bosDetay() });

      if (yeniMi) {
        const baslangic: Record<string, Deger> = {};
        // Yeni kayitta Durum her zaman "Aktif" gelsin (kullanici: "yeni kart kaydında
        // varsa durum hep aktif gelsin") - DurumKodlari'nde 1 = Aktif (KartKatalogu.cs).
        m.alanlar.forEach(a => {
          baslangic[a.ad] = a.ad === 'durum' ? '1' : a.tip === 'mantik' ? false : '';
        });
        setDeger(baslangic);
        setIlkDeger(baslangic);
        setSurum(undefined);
        setDetaylar(bosDetaylar);
      } else {
        const k = await api.kartOku(kaynak, id as number);
        const gelen: Record<string, Deger> = {};
        m.alanlar.forEach(a => {
          const d = k.kart[a.ad];
          gelen[a.ad] = a.tip === 'mantik' ? Number(d) === 1 : (d === null || d === undefined ? '' : String(d));
        });
        setDeger(gelen);
        setIlkDeger(gelen);
        setSurum(k.kart.surum as string | undefined);
        setYetki(k.yetki);
        m.detaylar.forEach(d => {
          bosDetaylar[d.ad] = bosDetay(k.detaylar?.[d.ad] ?? []);
        });
        setDetaylar(bosDetaylar);
      }
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, id, yeniMi]);

  useEffect(() => { void yukle() }, [yukle]);

  const gruplar = useMemo(() => {
    const harita = new Map<string, KartAlanMeta[]>();
    meta?.alanlar.forEach(a => {
      if (a.ad === 'id') return;
      const g = a.grup ?? 'Genel';
      harita.set(g, [...(harita.get(g) ?? []), a]);
    });
    return [...harita.entries()];
  }, [meta]);

  /**
   * "Kimlik" grubu sekme DEGIL — mockup'taki idstrip gibi ust seritte, her sekmede
   * sabit gorunur (kod/unvan/durum gibi karti tanimlayan alanlar).
   */
  const kimlikAlanlari = useMemo(
    () => gruplar.find(([ad]) => ad === KIMLIK_GRUP)?.[1] ?? [],
    [gruplar],
  );

  /** Mockup'taki gibi sekmeli kart: Kimlik disindaki her alan grubu + her detay tablosu ayri sekme. */
  const sekmeler = useMemo<SekmeTanimi[]>(() => {
    const s: SekmeTanimi[] = gruplar
      .filter(([ad]) => ad !== KIMLIK_GRUP)
      .map(([ad, alanlar]) => ({ tur: 'grup', anahtar: grupSekmeAnahtari(ad), baslik: ad, alanlar }));
    meta?.detaylar.forEach(d => {
      // Cari/Kisi/Personel'e ozel: Adresler mockup'ta ayri sekme DEGIL, ilgili grup
      //   sekmesinin icine gomulu bir tek-satir form - kendi sekmesi acilmasin (bkz.
      //   asagida grup render'i - Personel'de İletişim sekmesine gomulu, ik_karti.html).
      if ((kaynak === 'cari' || kaynak === 'kisi' || kaynak === 'personel') && d.ad === 'adresler') return;
      // Personel'de Eğitim/Sertifika artık Genel sekmesinde Kimlik Bilgileri'nin altında
      //   gömülü grid; ayrı sekme açılmasın.
      if (kaynak === 'personel' && d.ad === 'egitimler') return;
      s.push({ tur: 'detay', anahtar: detaySekmeAnahtari(d.ad), baslik: d.baslik, detay: d });
    });
    (yerTutucuSekmeler ?? []).forEach(baslik => {
      s.push({ tur: 'yerTutucu', anahtar: `y:${baslik}`, baslik });
    });
    // Rol'e ozel: Yetki Matrisi generic Detay degil (satir ekle/sil yok, sabit yetki
    //   listesi x Gor/Ekle/Degistir/Sil checkbox'lari) - ayri "ozel" sekme. Yeni kayitta
    //   henuz rolId yok, kart once kaydedilmeli (Kisi'nin İlgili Kişiler'iyle ayni kural).
    if (kaynak === 'rol' && !yeniMi) {
      s.push({ tur: 'ozel', anahtar: 'ozel:yetkiler', baslik: 'Yetki Matrisi' });
    }
    // Personel'e ozel: Resim/Doküman galerisi (057_dokuman.sql, generic DokumanGalerisi -
    // Kişi/Cari/Stok'ta da aynı bileşen kullanılabilir). Yeni kayıtta henüz id yok.
    if (kaynak === 'personel' && !yeniMi) {
      s.push({ tur: 'ozel', anahtar: 'ozel:dokuman', baslik: 'Resim / Doküman' });
    }
    return s;
  }, [gruplar, meta, yerTutucuSekmeler, kaynak, yeniMi]);

  const [aktifSekme, setAktifSekme] = useState<string | null>(null);
  // Genel kural: karta HER GIRISTE (id/kaynak degisince) ilk sekme acik olmali - "Sonraki"
  // ile ayni kaynaktaki baska kayida gecince onceki sekmede kalinmasin. RENDER SIRASINDA
  // (useEffect DEGIL) sifirlaniyor - useEffect [sekmeler] deps'ine bagli olsaydi, meta henuz
  // guncellenmeden (sekmeler referansi degismeden) once tetiklenip kacirabiliyordu.
  const [sonKayitAnahtari, setSonKayitAnahtari] = useState(`${kaynak}:${id}`);
  const kayitAnahtari = `${kaynak}:${id}`;
  if (kayitAnahtari !== sonKayitAnahtari) {
    setSonKayitAnahtari(kayitAnahtari);
    setAktifSekme(null);
  }
  useEffect(() => {
    if (sekmeler.length && !sekmeler.some(s => s.anahtar === aktifSekme)) {
      setAktifSekme(sekmeler[0].anahtar);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sekmeler, aktifSekme]);

  /** Hangi alan hangi sekmede — hata gelince o sekmeye atlamak icin. Kimlik her zaman gorunur, atlamaya gerek yok. */
  const sekmeBul = useCallback((alanAdi: string): string | null => {
    if (alanAdi.includes('.')) {
      const detayAd = alanAdi.split('.')[0];
      if (kaynak === 'cari' && detayAd === 'adresler') return grupSekmeAnahtari('Fatura Bilgileri');
      if (kaynak === 'kisi' && detayAd === 'adresler') return grupSekmeAnahtari('Genel');
      if (kaynak === 'personel' && detayAd === 'adresler') return grupSekmeAnahtari('İletişim');
      if (kaynak === 'personel' && detayAd === 'egitimler') return grupSekmeAnahtari('Genel');
      return detaySekmeAnahtari(detayAd);
    }
    const alan = meta?.alanlar.find(a => a.ad === alanAdi);
    const grup = alan?.grup ?? 'Genel';
    return grup === KIMLIK_GRUP ? null : grupSekmeAnahtari(grup);
  }, [meta]);

  /**
   * Yalniz DEGISEN alanlar gonderilir (§3.2: alan gondermemek "degistirme" demektir).
   *
   * YENI kayitta bos birakilan alan HIC GONDERILMEZ - null gondermek NOT NULL +
   * varsayilanli kolonlarda (durum, bayraklar) kaydi patlatiyordu. Bos gonderilmeyince
   * veritabani varsayilani devreye girer.
   * DUZENLEMEDE ise bos deger anlamlidir: kullanici alani temizlemis olabilir -> null.
   */
  const degisenAlanlar = useCallback(() => {
    const govde: Record<string, unknown> = {};
    meta?.alanlar.forEach(a => {
      if (!a.yazilabilir || a.ad === 'id') return;
      const yeni = deger[a.ad];

      if (yeniMi) {
        if (a.tip === 'mantik') { if (yeni) govde[a.ad] = true; return }
        if (yeni === '' || yeni === null || yeni === undefined) return;
        govde[a.ad] = yeni;
        return;
      }

      if (yeni === ilkDeger[a.ad]) return;
      govde[a.ad] = a.tip === 'mantik' ? Boolean(yeni) : (yeni === '' ? null : yeni);
    });
    return govde;
  }, [meta, deger, ilkDeger, yeniMi]);

  async function kaydet() {
    // Client-side eposta kontrolu - sunucuya hic gitmeden dur, ilgili sekmeye atla.
    const gecersizEposta = meta?.alanlar.find(a => {
      const v = deger[a.ad];
      return EPOSTA_ALANLARI.has(a.ad) && typeof v === 'string' && v !== '' && !epostaGecerliMi(v);
    });
    if (gecersizEposta) {
      setAlanHatalari(h => ({ ...h, [gecersizEposta.ad]: 'Gecerli bir e-posta adresi girin.' }));
      const hedefSekme = sekmeBul(gecersizEposta.ad);
      if (hedefSekme) setAktifSekme(hedefSekme);
      return;
    }

    setKaydediyor(true);
    setHata(null);
    setAlanHatalari({});
    setCakisma(null);
    setBilgi(null);
    try {
      const govde = {
        surum,
        kart: degisenAlanlar(),
        detaylar: Object.fromEntries(
          Object.entries(detaylar)
            .map(([ad, durum]) => [ad, detayFarki(durum)])
            .filter(([, fark]) => {
              const f = fark as ReturnType<typeof detayFarki>;
              return (f.eklenen?.length ?? 0) + (f.degisen?.length ?? 0) + (f.silinen?.length ?? 0) > 0;
            })),
      };

      // Personel'de "unvan" hic gosterilmiyor/duzenlenmiyor (kullanici: ad/soyad kullanilsin)
      // - DB'de NOT NULL oldugu icin Kaydet'te ad+soyad'dan burada birlestirilip eklenir.
      if (kaynak === 'personel') {
        const ad = String(deger.ad ?? '').trim();
        const soyad = String(deger.soyad ?? '').trim();
        const unvan = [ad, soyad].filter(Boolean).join(' ');
        if (unvan) govde.kart.unvan = unvan;
      }

      const yanit = yeniMi
        ? await api.kartEkle(kaynak, govde)
        : await api.kartGuncelle(kaynak, id as number, govde);

      onKaydedildi?.(Number(yanit.kart.id));
      onKapat?.();
      return;
    } catch (h) {
      if (h instanceof ApiHatasi) {
        if (h.dogrulamaMi && h.hata.alanlar) {
          setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
          setHata(h.message);
          const hedefSekme = h.hata.alanlar[0] ? sekmeBul(h.hata.alanlar[0].alan) : null;
          if (hedefSekme) setAktifSekme(hedefSekme);
        } else if (h.cakismaMi) {
          setCakisma({
            alanlar: h.hata.cakisanAlanlar ?? [],
            guncel: h.hata.guncelDeger ?? {},
          });
        } else {
          setHata(`${h.hata.kod}: ${h.message}${h.hata.engel ? ` (${h.hata.engel.tablo}: ${h.hata.engel.adet})` : ''}`);
        }
      } else {
        setHata(String(h));
      }
    } finally {
      setKaydediyor(false);
    }
  }

  async function sil() {
    setHata(null);
    try {
      await api.kartSil(kaynak, id as number);
      onKapat?.();
    } catch (h) {
      if (h instanceof ApiHatasi) {
        setHata(h.hata.engel
          ? `${h.message} (${h.hata.engel.tablo}: ${h.hata.engel.adet} kayit)`
          : `${h.hata.kod}: ${h.message}`);
      }
    }
  }

  if (yukleniyor)
    return (
      <Modal baslik={baslik ?? kaynak} alt={<button className="d" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="yukleniyor-satir">Yukleniyor…</div>
      </Modal>
    );

  if (!meta)
    return (
      <Modal baslik={baslik ?? kaynak} alt={<button className="d" onClick={onKapat}>Kapat</button>} onKapat={onKapat}>
        <div className="hata-kutusu">{hata}</div>
      </Modal>
    );

  const salt = !yeniMi && !yetki.duzenle;
  const aktif = sekmeler.find(s => s.anahtar === aktifSekme) ?? sekmeler[0];

  /** Sekme icinde mockup'taki gibi alt-bolumler (or. Genel -> Tanım/Sınıflandırma). */
  const altGruplaVar = (alanlar: KartAlanMeta[]) => {
    const harita = new Map<string, KartAlanMeta[]>();
    alanlar.forEach(a => {
      const g = a.altGrup ?? '';
      harita.set(g, [...(harita.get(g) ?? []), a]);
    });
    return [...harita.entries()];
  };

  const renderGirdi = (a: KartAlanMeta) => (
    a.tip === 'mantik' ? (
      <input
        key={a.ad}
        type="checkbox"
        checked={Boolean(deger[a.ad])}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.checked }))}
      />
    ) : kaynak === 'kisi' && a.ad === 'bagId' ? (
      // "Cariye Bağla" butonu + TarafArama modaliyla degistiriliyor - burada duz salt-okunur
      // gorunum (kullanici: "bagli cari readonly edit olsun"). Yazilabilir hala TRUE (kaydet
      // payload'una girsin), sadece render FARKLI - select degil, disabled text input.
      <div key={a.ad} className="tel-girdi">
        <input
          readOnly
          disabled
          value={bagliTarafAdi ?? (a.kodlar && a.kodlar[String(deger[a.ad] ?? '')]) ?? ''}
          placeholder="Bağlanmadı"
        />
        {!salt && deger[a.ad] && (
          <button type="button" className="mini" title="Boşalt"
            onClick={() => { setDeger(d => ({ ...d, [a.ad]: '' })); setBagliTarafAdi(null) }}>
            ×
          </button>
        )}
      </div>
    ) : a.kodlar ? (
      <select
        key={a.ad}
        value={String(deger[a.ad] ?? '')}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.value }))}
      >
        <option value="">—</option>
        {Object.entries(a.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
      </select>
    ) : TELEFON_ALANLARI.has(a.ad) ? (
      <TelefonGirdi
        key={a.ad}
        value={String(deger[a.ad] ?? '')}
        disabled={salt || !a.yazilabilir}
        onChange={v => setDeger(d => ({ ...d, [a.ad]: v }))}
      />
    ) : (
      <input
        key={a.ad}
        type={EPOSTA_ALANLARI.has(a.ad) ? 'email' : 'text'}
        value={String(deger[a.ad] ?? '')}
        maxLength={a.enFazlaUzunluk ?? undefined}
        disabled={salt || !a.yazilabilir}
        onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.value }))}
        onBlur={e => {
          if (EPOSTA_ALANLARI.has(a.ad)) {
            const gecerli = epostaGecerliMi(e.target.value);
            setAlanHatalari(h => {
              if (gecerli) { const { [a.ad]: _cikar, ...kalan } = h; return kalan }
              return { ...h, [a.ad]: 'Gecerli bir e-posta adresi girin.' };
            });
          }
        }}
      />
    )
  );

  const renderAlan = (a: KartAlanMeta) => (
    <label key={a.ad} className={`alan tip-${a.tip}`}>
      <span className="etiket">
        {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
      </span>
      {renderGirdi(a)}
      {alanHatalari[a.ad] && <span className="alan-hata">{alanHatalari[a.ad]}</span>}
    </label>
  );

  /**
   * Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
   * `eslesAlan` ile baska bir alani gosteren alan, o alani kendi satirina EKLER; hedef alan
   * ayri satir olarak TEKRAR RENDER EDILMEZ.
   */
  const renderAlanListesi = (alanlar: KartAlanMeta[]) => {
    const eslesenler = new Set(alanlar.map(a => a.eslesAlan).filter(Boolean));
    return alanlar
      .filter(a => !eslesenler.has(a.ad))
      .map(a => {
        const hedef = a.eslesAlan ? alanlar.find(x => x.ad === a.eslesAlan) : undefined;
        if (!hedef) return renderAlan(a);
        return (
          <label key={a.ad} className={`alan tip-${a.tip}`}>
            <span className="etiket">
              {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
            </span>
            <div className="ikili">{renderGirdi(a)}{renderGirdi(hedef)}</div>
            {(alanHatalari[a.ad] || alanHatalari[hedef.ad]) && (
              <span className="alan-hata">{alanHatalari[a.ad] || alanHatalari[hedef.ad]}</span>
            )}
          </label>
        );
      });
  };

  return (
    <Modal
      baslik={`${baslik ?? kaynak} ${yeniMi ? '— Yeni' : `#${id}`}`}
      ustBilgi={
        <>
          {surum && <span className="rozet gri">surum {surum}</span>}
          {salt && <span className="rozet uyari">salt okunur</span>}
        </>
      }
      ustSerit={kimlikAlanlari.length > 0 && (
        <div className="kaid">
          {/* Kisi'ye ozel: Kisi Kodu dar, Unvan genis (kullanici: "kod edit yariya dussun,
              onu unvana ekle") - idstrip'in 4 sabit alani (Kod/Unvan/Departman/Gorev). */}
          <div className={`alan-izgara${kaynak === 'kisi' ? ' kaid-kisi' : ''}`}>
            {renderAlanListesi(kimlikAlanlari)}
          </div>
        </div>
      )}
      sekmeBar={sekmeler.length > 1 && (
        <div className="katab">
          {sekmeler.map(s => (
            <div
              key={s.anahtar}
              className={`kat${s.anahtar === aktif?.anahtar ? ' on' : ''}`}
              onClick={() => setAktifSekme(s.anahtar)}
            >
              {s.baslik}
              {s.tur === 'detay' && <span className="b">{(detaylar[s.detay.ad] ?? bosDetay()).guncel.length}</span>}
            </div>
          ))}
        </div>
      )}
      onKapat={onKapat}
      alt={
        <>
          {!salt && (
            <button className="d bir" disabled={kaydediyor} onClick={() => void kaydet()}>
              {kaydediyor ? 'Kaydediliyor…' : 'Kaydet'}
            </button>
          )}
          {!yeniMi && yetki.sil && (
            <button className="d teh" onClick={() => void sil()}>Sil</button>
          )}
          {/* Kisi'ye ozel: "Bagli Cari" alani artik salt-okunur gorunum (asagida renderGirdi),
              tek degistirme yolu bu buton + TarafArama modali. Kisi zaten bagliysa (bagId
              dolu) buton GORUNMEZ (kullanici) - once "x" ile bag bosaltilmali. */}
          {kaynak === 'kisi' && !salt && !cariyeBaglaGizli && !deger.bagId && (
            <button className="d" onClick={() => setCariyeBaglaAcik(true)}>🔗 Cariye Bağla</button>
          )}
          <button className="d" onClick={onKapat}>Kapat</button>
          {/* Cari'ye ozel: Musteri/Tedarikci rolleri hizlı erisim icin arac cubuguna,
              Kaydet/Sil ile ayni satira, saga yanasik olarak da tasindi (Roller sekmesindeki
              alanlarla AYNI deger - ikisi de senkron, tekrar degil). */}
          {kaynak === 'cari' && meta.alanlar.some(a => a.ad === 'musteri') && (
            <span style={{ marginLeft: 'auto', display: 'flex', gap: 12, alignItems: 'center' }}>
              <label className="satir-ici">
                <input
                  type="checkbox"
                  checked={Boolean(deger.musteri)}
                  disabled={salt}
                  onChange={e => setDeger(d => ({ ...d, musteri: e.target.checked }))}
                />
                Müşteri
              </label>
              <label className="satir-ici">
                <input
                  type="checkbox"
                  checked={Boolean(deger.tedarikci)}
                  disabled={salt}
                  onChange={e => setDeger(d => ({ ...d, tedarikci: e.target.checked }))}
                />
                Tedarikçi
              </label>
            </span>
          )}
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {cakisma && (
        <div className="cakisma-kutusu">
          <b>Bu kaydi baska bir kullanici degistirdi.</b>
          {cakisma.alanlar.length > 0 && <div>Cakisan alanlar: {cakisma.alanlar.join(', ')}</div>}
          <div className="cakisma-arac">
            <button className="d" onClick={() => { setCakisma(null); void yukle() }}>Guncel hali al (degisikliklerim gider)</button>
            <button className="d" onClick={() => {
              // Sunucudaki guncel surumu alip kendi degisikliklerimi UZERINE yaz
              setSurum(String(cakisma.guncel.surum ?? ''));
              setCakisma(null);
            }}>Benim degisikliklerimi uygula</button>
          </div>
        </div>
      )}

      {aktif?.tur === 'grup' && (() => {
        const gruplanmis = altGruplaVar(aktif.alanlar);
        const adli = gruplanmis.filter(([b]) => b);
        // musteri/tedarikci toolbar'da (kaydet/sil yaninda) checkbox olarak zaten var,
        // ad/soyad kart'ta hic gosterilmiyor - burada tekrarlanmasin (cari'ya ozel). "kisi"
        // check'i de KALDIRILDI (kullanici) - artik ayri "Kişi Kartı" + "İlgili Kişiler"
        // akisi var, cari uzerinde dogrudan kisi bayragi degistirmek gereksiz/kafa karistirici.
        const gizli = kaynak === 'cari' ? new Set(['ad', 'soyad', 'musteri', 'tedarikci', 'kisi'])
          : kaynak === 'kisi' ? new Set(['kisi'])
          // Personel: "unvan" ad+soyad'dan Kaydet'te turetiliyor, ayrica gosterilmez/
          //   duzenlenmez (kullanici: "ad soyad kullan"); "personel" bayragi Kisi'nin
          //   "kisi" bayragiyla ayni sebeple gizli. "vkno"/"gorev" de gizli - normal
          //   adsiz akistan CIKARILIP PersonelKimlikOzet.tsx'e props olarak geciyor
          //   (ik_karti.html: TCKN "Kimlik Bilgileri" kutusunda, Görev "Özet" kutusunda).
          : kaynak === 'personel' ? new Set(['personel', 'unvan', 'vkno', 'gorev'])
          : new Set<string>();
        const adsiz = (gruplanmis.find(([b]) => !b)?.[1] ?? []).filter(a => !gizli.has(a.ad));
        // Cari'ya ozel: Iletisim + Notlar ayni (sol) sutunda ust-alt, Tanımlama sagda.
        const iletisim = adli.find(([b]) => b === 'İletişim');
        const notlar = adli.find(([b]) => b === 'Notlar');
        const digerAdli = adli.filter(([b]) => b !== 'İletişim' && b !== 'Notlar');
        const adliBlok = (
          <>
            {/* Mockup: Tanım/Sınıflandırma · Vergi & Ana Birim ... AYNI SATIRDA yan yana (.row > .col > .grp).
                Personel'de bu sarmalayici, AltGrup'lu (adli) alan olmasa BILE acik kalmali -
                PersonelKimlikOzet/TekAdres gibi ozel bilesenler AltGrup'a bagli DEGIL, asagida
                bu blogun icinde render ediliyor (bug: "genel sekmesinde sadece 2 alan var" -
                adli.length===0 oldugu icin butun kasira hic acilmiyordu). */}
            {(adli.length > 0 || kaynak === 'personel') && (
              <div className="kasira">
                {iletisim && (
                  <div className="kasutun">
                    <div className="kagrup">
                      <h6>{iletisim[0]}</h6>
                      <div className="alan-izgara tek-sutun">{renderAlanListesi(iletisim[1])}</div>
                    </div>
                    {notlar && kaynak !== 'cari' && (
                      <div className="kagrup">
                        <h6>{notlar[0]}</h6>
                        <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
                      </div>
                    )}
                  </div>
                )}
                {digerAdli.map(([altBaslik, alanlar]) => {
                  // Cari'ye ozel: Tanımlama kutusunda dort cift AYNI SATIRDA yan yana,
                  // sirayla (kullanici): Kategori/İlk Temas, Sektör/Alt Sektör, Sınıf/Bölge,
                  // Temsilci/Özel Kod.
                  const ciftler = kaynak === 'cari' && altBaslik === 'Tanımlama'
                    ? [['kategori', 'ilkTemas'], ['sektor', 'altSektor'], ['sinif', 'bolge'], ['temsilci', 'ozelKod']]
                    : [];
                  const ciftliAlanlar = ciftler.map(cift =>
                    cift.map(ad => alanlar.find(a => a.ad === ad)).filter(a => a !== undefined));
                  const digerAlanlar = alanlar.filter(a => !ciftliAlanlar.flat().includes(a));
                  return (
                    <div className="kagrup" key={altBaslik}>
                      <h6>{altBaslik}</h6>
                      <div className="alan-izgara tek-sutun">
                        {ciftliAlanlar.map((cift, i) => cift.length > 0 && (
                          <div className="adres-satir" key={i}>{renderAlanListesi(cift)}</div>
                        ))}
                        {renderAlanListesi(digerAlanlar)}
                      </div>
                    </div>
                  );
                })}
                {/* Kisi'ye ozel: kisi_karti.html'deki "Adres" kutusu - GRID DEGIL, TEK adres
                    (kullanici: "grid olmasin tek adres"). Iletisim kutusuyla AYNI satirda
                    (kasira icinde) - genislik esitlensin diye (kullanici: "iletisim kutusu
                    kadar olsun"). Ayni taraf_adres tablosu, sadece tek satir gosterilir. */}
                {kaynak === 'kisi' && aktif.baslik === 'Genel' && (() => {
                  const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
                  if (!adresDetay) return null;
                  return (
                    <TekAdres
                      meta={adresDetay}
                      durum={detaylar[adresDetay.ad] ?? bosDetay()}
                      saltOkunur={salt || adresDetay.saltOkunur}
                      onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                    />
                  );
                })()}
                {/* Personel'e ozel: ik_karti.html mockup'ta "Ev Adresi" İletişim sekmesinde
                    (Genel'de degil) - AYNI TekAdres, farkli sekmede gomulu. */}
                {kaynak === 'personel' && aktif.baslik === 'İletişim' && (() => {
                  const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
                  if (!adresDetay) return null;
                  return (
                    <TekAdres
                      meta={adresDetay}
                      durum={detaylar[adresDetay.ad] ?? bosDetay()}
                      saltOkunur={salt || adresDetay.saltOkunur}
                      onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                      baslik="Ev Adresi"
                    />
                  );
                })()}
                {/* Personel'e ozel: ik_karti.html mockup'ta Genel sekmesinde "Kimlik
                    Bilgileri" (TCKN + Ozluk'ten dogum/cinsiyet/vb) + "Özet" (Pozisyon +
                    İşe Giriş) kutulari - iki farkli veri kaynagini (taraf + personel_ozluk)
                    BIRLESTIRDIGI icin ozel bilesen (PersonelKimlikOzet.tsx). */}
                {kaynak === 'personel' && aktif.baslik === 'Genel' && (() => {
                  const ozlukDetay = meta.detaylar.find(d => d.ad === 'ozluk');
                  const egitimDetay = meta.detaylar.find(d => d.ad === 'egitimler');
                  const vknoAlan = meta.alanlar.find(a => a.ad === 'vkno');
                  const gorevAlan = meta.alanlar.find(a => a.ad === 'gorev');
                  if (!ozlukDetay || !vknoAlan || !gorevAlan) return null;
                  return (
                    <PersonelKimlikOzet
                      vknoAlan={vknoAlan}
                      vkno={String(deger.vkno ?? '')}
                      onVknoDegis={v => setDeger(d => ({ ...d, vkno: v }))}
                      gorevAlan={gorevAlan}
                      gorev={String(deger.gorev ?? '')}
                      onGorevDegis={v => setDeger(d => ({ ...d, gorev: v }))}
                      ozlukMeta={ozlukDetay}
                      ozlukDurum={detaylar[ozlukDetay.ad] ?? bosDetay()}
                      saltOkunur={salt}
                      onOzlukDegis={yeni => setDetaylar(t => ({ ...t, [ozlukDetay.ad]: yeni }))}
                      kaynakId={yeniMi ? undefined : (id as number)}
                      egitimler={egitimDetay && (
                        <GenDetayTablo
                          meta={egitimDetay}
                          durum={detaylar[egitimDetay.ad] ?? bosDetay()}
                          saltOkunur={salt || egitimDetay.saltOkunur}
                          hatalar={alanHatalari}
                          onDegis={yeni => setDetaylar(t => ({ ...t, [egitimDetay.ad]: yeni }))}
                        />
                      )}
                    />
                  );
                })()}
                {!iletisim && notlar && kaynak !== 'cari' && (
                  <div className="kagrup" key="Notlar">
                    <h6>{notlar[0]}</h6>
                    <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
                  </div>
                )}
                {resimYerTutucu && aktif.baslik === 'Genel' && (
                  <div className="kagrup kagrup-resim">
                    <h6>Resim</h6>
                    <div className="resim-kutusu">🖼️</div>
                  </div>
                )}
              </div>
            )}
          </>
        );
        // SubeId/EklemeTarihi (salt-okunur meta alanlar) EN ALTTA (kullanici: kisi kartinda
        //   sonra cari kartinda da "şube id ve ekleme tarihi en alta gelsin") - Kisi'de Bagli
        //   Cari/Rol/Durum'dan AYRI (o idstrip'in hemen altinda kaliyor); Cari'de zaten baska
        //   adsiz alan kalmadi (kisi/ad/soyad/musteri/tedarikci gizli), direkt en alta duser.
        const enAltAd = new Set(['subeId', 'eklemeTarihi']);
        const adsizUst = adsiz.filter(a => !enAltAd.has(a.ad));
        const adsizAlt = adsiz.filter(a => enAltAd.has(a.ad));
        {/* Kisi'ye ozel: Rol/Durum saga yanasik, aradaki bosluk Bagli Cari editi buyuyerek
            doldurur (kullanici: "rol ve durum saga yanasik, aradaki bosluk bagli cari editi
            doldursun"). Alan sirasi katalogda Bagli Cari, Rol, Durum. */}
        const adsizBlok = adsizUst.length > 0 && (
          <div className={`alan-izgara${kaynak === 'kisi' ? ' kisi-ust-satir' : ''}`}>
            {renderAlanListesi(adsizUst)}
          </div>
        );
        const adsizAltBlok = adsizAlt.length > 0 && <div className="alan-izgara">{renderAlanListesi(adsizAlt)}</div>;
        return (
          <>
            {/* Kisi'ye ozel: Bagli Cari/Rol/Durum (adsiz) idstrip'in HEMEN ALTINDA, 2. sirada
                (kullanici: "onun altinda 2.sirada Bagli Cari/Rol/Durum olsun") - Iletisim/Adres
                kutularindan ONCE. Diger kaynaklar (Cari) eski sirada: kutular sonra adsiz. */}
            {kaynak === 'kisi' ? (
              <>
                {adsizBlok}
                {adliBlok}
              </>
            ) : (
              <>
                {adliBlok}
                {adsizBlok}
              </>
            )}
            {/* Cari'ye ozel: mockup'ta Genel'in altinda "İlgili Kişiler" tablosu (ayri
                uclar - /api/kart/cari/{id}/kisiler, kartin diger alanlari gibi Kaydet'i
                beklemez). Yeni kayitta henuz id yok, kart once kaydedilmeli. */}
            {kaynak === 'cari' && aktif.baslik === 'Genel' && !yeniMi && (
              <IlgiliKisiler tarafId={id as number} saltOkunur={salt} />
            )}
            {/* Kullanici: "notlar ilgili kişiler altına gelsin" - Cari'de Notlar kutusu
                artik İletişim'in yaninda degil, İlgili Kişiler tablosunun altinda. */}
            {kaynak === 'cari' && aktif.baslik === 'Genel' && notlar && (
              <div className="kasira">
                <div className="kagrup" key="Notlar">
                  <h6>{notlar[0]}</h6>
                  <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
                </div>
              </div>
            )}
            {/* Cari'ye ozel: Adresler mockup'ta ayri sekme degil, Fatura Bilgileri'nin icine
                gomulu GRID (birden fazla adres - fatura/sevkiyat/vb). */}
            {kaynak === 'cari' && aktif.baslik === 'Fatura Bilgileri' && (() => {
              const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
              if (!adresDetay) return null;
              return (
                <GenDetayTablo
                  meta={adresDetay}
                  durum={detaylar[adresDetay.ad] ?? bosDetay()}
                  saltOkunur={salt || adresDetay.saltOkunur}
                  hatalar={alanHatalari}
                  onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                />
              );
            })()}
            {/* SubeId/EklemeTarihi GERCEKTEN EN ALTTA - Kisi/Ilgili Kisiler/Adresler
                kutularindan da SONRA (kullanici iki kez duzeltti: onceki yer "ortada"
                kaliyordu, İlgili Kişiler grid'inden ONCE geliyordu). */}
            {adsizAltBlok}
          </>
        );
      })()}

      {/* Personel'e ozel: "Özlük" kendi sekmesi ama TEK SATIR form (TekOzluk.tsx) -
          personel_ozluk 1:1, generic coklu-satir grid'e uymuyor (ik_karti.html). */}
      {aktif?.tur === 'detay' && kaynak === 'personel' && aktif.detay.ad === 'ozluk' && (
        <TekOzluk
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
        />
      )}

      {aktif?.tur === 'detay' && !(kaynak === 'personel' && aktif.detay.ad === 'ozluk') && (
        <GenDetayTablo
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          saltOkunur={salt || aktif.detay.saltOkunur}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
        />
      )}

      {aktif?.tur === 'ozel' && kaynak === 'rol' && (
        <RolYetkiMatrisi rolId={id as number} saltOkunur={salt} />
      )}

      {aktif?.tur === 'ozel' && kaynak === 'personel' && (
        <DokumanGalerisi kartAdi="personel" kaynakId={id as number} saltOkunur={salt} />
      )}

      {aktif?.tur === 'yerTutucu' && (
        <div style={{ padding: 40, textAlign: 'center', color: 'var(--soluk)' }}>
          {aktif.baslik} sekmesi yakında.
        </div>
      )}

      {kaynak === 'kisi' && (
        <TarafArama
          acik={cariyeBaglaAcik}
          kaynaklar={['cari']}
          yerTutucu="Cari (müşteri/tedarikçi) ara…"
          onKapat={() => setCariyeBaglaAcik(false)}
          onSec={secilen => {
            setDeger(d => ({ ...d, bagId: String(secilen.id) }));
            setBagliTarafAdi(secilen.unvan);
          }}
        />
      )}
    </Modal>
  );
}
