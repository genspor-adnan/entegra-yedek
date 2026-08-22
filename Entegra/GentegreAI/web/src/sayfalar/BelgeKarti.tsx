import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { ApiHatasi, type BelgeYaniti, type KasaIslemTuru, type ListeSatiri } from '../api/sozlesme';
import { GenLookup, LOOKUP_CARI, LOOKUP_STOK } from '../bilesenler/GenLookup';
import { Modal } from '../bilesenler/GenForm';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { useOturum } from '../kimlik/OturumBaglami';

interface SatirDurumu {
  anahtar: number;
  stokId: number | null;
  stokAdi: string;
  adet: string;
  birimFiyat: string;
  iskonto: string;
  kdv: string;
}

const bosSatir = (anahtar: number): SatirDurumu => ({
  anahtar, stokId: null, stokAdi: '', adet: '1', birimFiyat: '', iskonto: '0', kdv: '20',
});

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

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

const KAPANMA_ETIKET: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Faturalanmadı', sinif: 'uyari' },
  1: { ad: 'Kısmi faturalandı', sinif: '' },
  2: { ad: 'Faturalandı', sinif: 'olumlu' },
};

/** Kartin acabilecegi belge turleri - grup='belge' katalogundan suzulur. */
const GIRILEBILIR_TURLER = [19, 15, 14, 9, 11, 10, 16, 12] as const;

/** Hangi turden sonra hangi listeye donulur. */
const LISTE_YOLU = (tur: number) => (tur === 9 || tur === 19 ? '/siparis' : '/belge');

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
  const [sevkTarihi, setSevkTarihi] = useState('');
  const [teslimSekli, setTeslimSekli] = useState(0);
  const [taslak, setTaslak] = useState(false);
  const [satirlar, setSatirlar] = useState<SatirDurumu[]>([bosSatir(1)]);

  const [kaydediyor, setKaydediyor] = useState(false);
  const [aciliyor, setAciliyor] = useState(!!belgeId);
  const [donusum, setDonusum] = useState(false);
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
        setSevkTarihi(y.belge.irsaliyeTarihi ? String(y.belge.irsaliyeTarihi).slice(0, 16) : '');
        setTeslimSekli(Number(y.belge.teslimSekli ?? 0));
        setSatirlar((y.satirlar ?? []).map((r, i) => ({
          anahtar: i + 1,
          stokId: r.stokId ? Number(r.stokId) : null,
          stokAdi: String(r.stokAdi ?? r.aciklama ?? ''),
          adet: String(r.miktar ?? r.adet ?? 0),
          birimFiyat: String(r.birimFiyat ?? 0),
          iskonto: String(r.iskonto ?? 0),
          kdv: String(r.kdv ?? 0),
        })));
      } catch (h) {
        setHata(h instanceof ApiHatasi ? h.message : String(h));
      } finally { setAciliyor(false) }
    })();
  }, [belgeId]);

  /** Yalniz ONIZLEME: gercek tutar sunucudan gelir. */
  const onizleme = useMemo(() => {
    let matrah = 0, kdv = 0;
    satirlar.forEach(s => {
      const adet = Number(s.adet.replace(',', '.')) || 0;
      const fiyat = Number(s.birimFiyat.replace(',', '.')) || 0;
      const isk = Number(s.iskonto.replace(',', '.')) || 0;
      const oran = Number(s.kdv.replace(',', '.')) || 0;
      const tutar = Math.round(adet * fiyat * 100) / 100 * (1 - isk / 100);
      matrah += tutar;
      kdv += tutar * oran / 100;
    });
    return { matrah, kdv, genel: matrah + kdv };
  }, [satirlar]);

  const satirDegis = (anahtar: number, alan: keyof SatirDurumu, deger: unknown) =>
    setSatirlar(s => s.map(x => x.anahtar === anahtar ? { ...x, [alan]: deger } : x));

  const stokSec = (anahtar: number, satir: ListeSatiri | null) => {
    setSatirlar(s => s.map(x => x.anahtar !== anahtar ? x : {
      ...x,
      stokId: satir ? Number(satir.id) : null,
      stokAdi: satir ? String(satir.ad ?? '') : '',
      kdv: satir?.kdv !== undefined && satir?.kdv !== null ? String(satir.kdv) : x.kdv,
    }));
  };

  const satirEkle = () =>
    setSatirlar(s => [...s, bosSatir(Math.max(0, ...s.map(x => x.anahtar)) + 1)]);

  const satirSil = (anahtar: number) =>
    setSatirlar(s => (s.length === 1 ? s : s.filter(x => x.anahtar !== anahtar)));

  async function kes() {
    setHata(null);
    setAlanHatalari({});
    setSonuc(null);

    if (!cari) { setAlanHatalari({ tarafId: 'Cari secilmeli.' }); return }
    const dolu = satirlar.filter(s => s.stokId);
    if (dolu.length === 0) { setHata('En az bir satirda stok secilmeli.'); return }

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
          // Irsaliyede sevk zamani ve teslim sekli GIB'in bekledigi alanlar.
          irsaliyeTarihi: irsaliyeMi && sevkTarihi ? sevkTarihi : undefined,
          teslimSekli: irsaliyeMi ? teslimSekli : undefined,
        },
        satirlar: dolu.map((s, i) => ({
          sira: i + 1,
          tur: 1,
          stokId: s.stokId,
          adet: Number(s.adet.replace(',', '.')) || 0,
          miktar: Number(s.adet.replace(',', '.')) || 0,
          birimFiyat: Number(s.birimFiyat.replace(',', '.')) || 0,
          iskonto: Number(s.iskonto.replace(',', '.')) || 0,
          kdv: Number(s.kdv.replace(',', '.')) || 0,
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

          <label className="satir-ici">
            <input type="checkbox" checked={taslak} disabled={kilitli}
                   onChange={e => setTaslak(e.target.checked)} />
            Taslak (numara tüketmez)
          </label>
          <button className="d" onClick={kapat}>✖ Kapat</button>
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
          {/* Alan duzeni mockup'tan (Ekranlar/satis_irsaliye_karti.html .hdr):
              BASLIKSIZ 3 sutunlu izgara - mockup'ta da bu blogun basligi yok,
              belge zaten pencere basliginda yaziyor. */}
          <div className="alan-izgara uc-sutun belge-hdr">
            <label className="alan">
              <span className="etiket">{irsaliyeMi ? 'İrsaliye No' : 'Belge No'}</span>
              <input className="one-cikan"
                     value={String(sonuc?.belge.belgeNo ?? '') || (kilitli ? '' : '(kaydedince verilir)')}
                     readOnly />
            </label>

            <GenLookup
              kaynak="cari"
              etiket={siparisMi || irsaliyeMi ? 'Müşteri (Cari)' : 'Cari'}
              zorunlu
              alanlar={LOOKUP_CARI}
              deger={cari?.unvan}
              hata={alanHatalari.tarafId}
              saltOkunur={kilitli}
              onSec={s => setCari(s ? { id: Number(s.id), unvan: String(s.unvan ?? '') } : null)}
            />

            <label className="alan">
              <span className="etiket">e-Belge</span>
              <span className="deger-serit">
                {irsaliyeMi
                  ? <span className="rozet bilgi">e‑İrsaliye</span>
                  : <span className="rozet bilgi">e‑Fatura</span>}
                {Number(sonuc?.belge.efaturaDurum ?? 0) > 0
                  ? <span className="rozet olumlu">✓ Gönderildi</span>
                  : <span className="rozet">gönderilmedi</span>}
              </span>
            </label>

            <label className="alan">
              <span className="etiket zorunlu-isaret">
                {irsaliyeMi ? 'İrsaliye Tarihi' : 'Belge Tarihi'}
              </span>
              <input type="date" value={tarih} disabled={kilitli}
                     onChange={e => setTarih(e.target.value)} />
            </label>

            {irsaliyeMi ? (
              <label className="alan">
                <span className="etiket">Sevk Tarih / Saati</span>
                <input type="datetime-local" value={sevkTarihi} disabled={kilitli}
                       onChange={e => setSevkTarihi(e.target.value)} />
              </label>
            ) : (
              <label className="alan">
                <span className="etiket">Vade (gün)</span>
                <input className="hiza-sag" value={vadeGun} disabled={kilitli}
                       onChange={e => setVadeGun(e.target.value)} />
              </label>
            )}

            <label className="alan">
              <span className="etiket">{siparisMi ? 'Kaynak Belge' : 'Bağlı Sipariş'}</span>
              <span className="deger-serit">
                {sonuc?.belge.kaynakBelgeNo
                  ? <>{String(sonuc.belge.kaynakTurAdi ?? '')} <b>{String(sonuc.belge.kaynakBelgeNo)}</b></>
                  : <span className="sonuk">—</span>}
              </span>
            </label>

            <GenLookup
              kaynak="depo"
              etiket={siparisMi ? 'Depo' : 'Çıkış Deposu'}
              alanlar={LOOKUP_DEPO}
              deger={depo?.ad}
              saltOkunur={kilitli}
              onSec={s => setDepo(s ? { id: Number(s.id), ad: String(s.ad ?? '') } : null)}
            />

            <GenLookup
              kaynak="cari"
              etiket="Satış Temsilcisi"
              alanlar={LOOKUP_CARI}
              deger={satici?.ad}
              saltOkunur={kilitli}
              onSec={s => setSatici(s ? { id: Number(s.id), ad: String(s.unvan ?? '') } : null)}
            />

            <label className="alan">
              <span className="etiket">{irsaliyeMi ? 'Faturalama Durumu' : 'Kapanma'}</span>
              <span className="deger-serit">
                {(() => {
                  const k = KAPANMA_ETIKET[Number(sonuc?.belge.kapanmaDurum ?? 0)];
                  const acik = satirlar.length;
                  return (
                    <>
                      <span className={`rozet ${k?.sinif ?? ''}`}>{k?.ad ?? '—'}</span>
                      {kayitliId > 0 && <span className="sonuk">{acik} kalem</span>}
                    </>
                  );
                })()}
              </span>
            </label>

            <label className="alan genis-2">
              <span className="etiket">{irsaliyeMi ? 'Sevk Adresi' : 'Adres'}</span>
              <input value={[sonuc?.belge.tarafAdres, sonuc?.belge.tarafIlce, sonuc?.belge.tarafIl]
                              .filter(Boolean).join(' / ')} readOnly
                     placeholder="Cari seçilince kartındaki varsayılan adres gelir" />
            </label>

            {irsaliyeMi ? (
              <label className="alan">
                <span className="etiket">Teslim Şekli</span>
                <select value={teslimSekli} disabled={kilitli}
                        onChange={e => setTeslimSekli(Number(e.target.value))}>
                  {TESLIM_SEKLI.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
                </select>
              </label>
            ) : (
              <label className="alan">
                <span className="etiket">Seri</span>
                <input value={seri} maxLength={5} disabled={kilitli}
                       onChange={e => setSeri(e.target.value.toUpperCase())} />
              </label>
            )}

            <label className="alan">
              <span className="etiket">Vergi Dairesi / VKN</span>
              <input value={[sonuc?.belge.tarafVd, sonuc?.belge.tarafVkno]
                              .filter(Boolean).join(' · ')} readOnly />
            </label>

            <label className="alan">
              <span className="etiket">Döviz / Kur</span>
              <input value={`${String(sonuc?.belge.belgeDovizi ?? 'TL')} · ${
                Number(sonuc?.belge.dovizKuru ?? 1).toLocaleString('tr-TR', { minimumFractionDigits: 6 })}`}
                     readOnly />
            </label>

            <label className="alan">
              <span className="etiket">Belge Türü</span>
              <select value={tur} disabled={kilitli} onChange={e => setTur(Number(e.target.value))}>
                {GIRILEBILIR_TURLER.map(k => (
                  <option key={k} value={k}>{turAdi(k)}</option>
                ))}
              </select>
            </label>
          </div>
        </div>

        <div className="kagrup">
          <h6>
            Satirlar
            {!kilitli && <button type="button" className="d bir" onClick={satirEkle}>+ Satır</button>}
          </h6>

          <table className="detay-tablo">
            <thead>
              <tr>
                <th style={{ width: '34%' }}>Stok</th>
                <th className="hiza-sag">Adet</th>
                <th className="hiza-sag">Birim Fiyat</th>
                <th className="hiza-sag">Iskonto %</th>
                <th className="hiza-sag">KDV %</th>
                <th className="hiza-sag">Tutar (onizleme)</th>
                {!kilitli && <th />}
              </tr>
            </thead>
            <tbody>
              {satirlar.map(s => {
                const adet = Number(s.adet.replace(',', '.')) || 0;
                const fiyat = Number(s.birimFiyat.replace(',', '.')) || 0;
                const isk = Number(s.iskonto.replace(',', '.')) || 0;
                const tutar = Math.round(adet * fiyat * 100) / 100 * (1 - isk / 100);
                return (
                  <tr key={s.anahtar}>
                    <td>
                      <GenLookup
                        kaynak="stok"
                        alanlar={LOOKUP_STOK}
                        deger={s.stokAdi}
                        saltOkunur={kilitli}
                        onSec={satir => stokSec(s.anahtar, satir)}
                      />
                    </td>
                    <td><input className="hiza-sag" value={s.adet} disabled={kilitli}
                               onChange={e => satirDegis(s.anahtar, 'adet', e.target.value)} /></td>
                    <td><input className="hiza-sag" value={s.birimFiyat} disabled={kilitli}
                               onChange={e => satirDegis(s.anahtar, 'birimFiyat', e.target.value)} /></td>
                    <td><input className="hiza-sag" value={s.iskonto} disabled={kilitli}
                               onChange={e => satirDegis(s.anahtar, 'iskonto', e.target.value)} /></td>
                    <td><input className="hiza-sag" value={s.kdv} disabled={kilitli}
                               onChange={e => satirDegis(s.anahtar, 'kdv', e.target.value)} /></td>
                    <td className="hiza-sag onizleme">{para.format(tutar)}</td>
                    {!kilitli && (
                      <td className="hiza-orta">
                        <button type="button" className="d teh" onClick={() => satirSil(s.anahtar)}>×</button>
                      </td>
                    )}
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Dip toplam: kaydedilmeden ONCE onizleme, kaydedildikten sonra SUNUCUNUN
            hesabi (fn_belge_diptoplam) - tevkifat/OTV/stopaj satirlariyla birlikte. */}
        <div className="kagrup dip-toplam">
          <h6>{sonuc ? 'Dip Toplam (sunucu)' : 'Dip Toplam (onizleme)'}</h6>
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
          {!sonuc && <div className="not">Kesin tutar sunucuda hesaplanır; buradaki değerler önizlemedir.</div>}
        </div>

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
