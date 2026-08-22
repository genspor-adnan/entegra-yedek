import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../api/istemci';
import {
  ApiHatasi, KASA_DURUM,
  type KasaIslemTuru, type KasaIslemYaniti, type ListeSatiri,
} from '../api/sozlesme';
import { GenLookup, LOOKUP_CARI } from '../bilesenler/GenLookup';
import { BacakListesi } from '../bilesenler/kasa/BacakSatiri';
import { FisOnizleme } from '../bilesenler/kasa/FisOnizleme';
import { useOturum } from '../kimlik/OturumBaglami';

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const LOOKUP_HESAP = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'ad', baslik: 'Hesap Adı', genis: true },
  { ad: 'dovizCinsi', baslik: 'Döviz' },
];
const LOOKUP_KALEM = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'ad', baslik: 'Ad', genis: true },
];
const LOOKUP_PROJE = [
  { ad: 'kod', baslik: 'Kod' },
  { ad: 'ad', baslik: 'Proje', genis: true },
];

/** Sayi girisi: "1.234,56" ve "1234.56" ikisini de kabul eder. */
const sayi = (metin: string) => Number(metin.replace(/\./g, '').replace(',', '.')) || 0;

/**
 * Kasa (tahsilat / ödeme) islem karti — F2.
 *
 * BACAKLARI KULLANICI GIRMEZ. Ekran basligi doldurur (tur, hesap, cari, tutar,
 * masraf); bacaklari ve muhasebe fisini SUNUCU turun sablonundan uretir
 * (fn_kasa_islem_bacak_uret / fn_kasa_islem_fisle). Ekranda gorunen tutarlar
 * kaydettikten sonra sunucunun dondugu degerlerdir - iki taraf ayrisamaz.
 */
export function KasaIslemKarti() {
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const { yetki, kullanici } = useOturum();

  const kayitId = id && id !== 'yeni' ? Number(id) : null;

  const [turler, setTurler] = useState<KasaIslemTuru[]>([]);
  const [tur, setTur] = useState<number>(Number(sorgu.get('tur')) || 21);
  const [tarih, setTarih] = useState(new Date().toISOString().slice(0, 10));
  const [cari, setCari] = useState<{ id: number; unvan: string } | null>(null);
  const [hesap, setHesap] = useState<{ id: number; ad: string; doviz: string } | null>(null);
  const [tutar, setTutar] = useState('');
  const [kur, setKur] = useState('1');
  const [masrafTutar, setMasrafTutar] = useState('');
  const [kalem, setKalem] = useState<{ id: number; ad: string } | null>(null);
  const [proje, setProje] = useState<{ id: number; ad: string } | null>(null);
  const [aciklama, setAciklama] = useState('');

  const [sonuc, setSonuc] = useState<KasaIslemYaniti | null>(null);
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});

  const secili = useMemo(() => turler.find(t => t.kod === tur), [turler, tur]);
  const durum = sonuc ? Number(sonuc.islem.durum ?? 0) : null;
  const kilitli = durum !== null && durum >= 2;      // gerceklesmis / iptal: salt gorunum
  const dovizli = (hesap?.doviz ?? 'TL') !== 'TL';
  const ekleyebilir = yetki('kasa_islem', 'ekle');

  // Turler bir kez yuklenir (katalog degismez, 5 dk cache sunucuda).
  useEffect(() => {
    void (async () => {
      try { setTurler(await api.kasaIslemTurleri()) }
      catch (h) { setHata(h instanceof ApiHatasi ? h.message : String(h)) }
    })();
  }, []);

  const yaniti = useCallback((y: KasaIslemYaniti) => {
    setSonuc(y);
    const i = y.islem;
    setTur(Number(i.tur));
    if (i.islemTarihi) setTarih(String(i.islemTarihi).slice(0, 10));
    setTutar(String(i.tutar ?? ''));
    setKur(String(i.dovizKuru ?? 1));
    setMasrafTutar(Number(i.masrafTutar) ? String(i.masrafTutar) : '');
    setAciklama(String(i.aciklama ?? ''));
    if (i.tarafId) setCari({ id: Number(i.tarafId), unvan: String(i.tarafUnvan ?? '') });
    if (i.hesapId) setHesap({
      id: Number(i.hesapId), ad: String(i.hesapAdi ?? ''), doviz: String(i.dovizCinsi ?? 'TL'),
    });
    if (i.projeId) setProje({ id: Number(i.projeId), ad: String(i.projeAdi ?? '') });
  }, []);

  // Mevcut kaydi ac
  useEffect(() => {
    if (kayitId === null) return;
    void (async () => {
      try { yaniti(await api.kasaOku(kayitId)) }
      catch (h) { setHata(h instanceof ApiHatasi ? h.message : String(h)) }
    })();
  }, [kayitId, yaniti]);

  // Hesap ya da tarih degisince kuru tazele (yalniz dovizli hesapta, kilitli degilse).
  useEffect(() => {
    if (kilitli) return;
    const cins = hesap?.doviz ?? 'TL';
    if (cins === 'TL') { setKur('1'); return }
    const yon = secili?.grup === 'tahsilat' ? 1 : 2;      // giris satis, cikis alis kuru
    void (async () => {
      try {
        const k = await api.dovizKur(cins, tarih, yon);
        if (k.kur) setKur(String(k.kur));
      } catch { /* kur yoksa kullanici elle girer */ }
    })();
  }, [hesap?.doviz, tarih, secili?.grup, kilitli]);

  const yerelOnizleme = sayi(tutar) * (Number(kur.replace(',', '.')) || 1);

  function govde(taslak: boolean) {
    return {
      islem: {
        tur,
        islemTarihi: tarih,
        tarafId: cari?.id ?? null,
        hesapId: hesap?.id ?? null,
        tutar: sayi(tutar),
        dovizCinsi: hesap?.doviz ?? 'TL',
        dovizKuru: Number(kur.replace(',', '.')) || 1,
        masrafTutar: sayi(masrafTutar),
        masrafId: kalem?.id ?? null,
        projeId: proje?.id ?? null,
        aciklama,
      },
      secenekler: { taslak, kurKontrolu: true },
    };
  }

  async function kaydet(taslak: boolean) {
    setHata(null);
    setAlanHatalari({});

    if (!hesap) { setAlanHatalari({ hesapId: 'Hesap seçilmeli.' }); return }
    if (sayi(tutar) <= 0) { setAlanHatalari({ tutar: 'Sıfırdan büyük olmalı.' }); return }
    if (secili?.cariZorunlu === 1 && !cari) { setAlanHatalari({ tarafId: 'Cari zorunlu.' }); return }

    setCalisiyor(true);
    try {
      const y = kayitId === null
        ? await api.kasaEkle(govde(taslak))
        : await api.kasaGuncelle(kayitId, { ...govde(taslak), surum: String(sonuc?.islem.surum ?? '') });
      yaniti(y);
      if (kayitId === null) git(`/kasa-islem/${y.islem.id}`, { replace: true });
    } catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  async function kesinlestir() {
    if (!kayitId) return;
    setHata(null);
    setCalisiyor(true);
    try { yaniti(await api.kasaKesinlestir(kayitId)) }
    catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  async function iptalEt() {
    if (!kayitId) return;
    const sebep = window.prompt('İptal sebebi:');
    if (!sebep) return;
    setHata(null);
    setCalisiyor(true);
    try {
      await api.kasaIptal(kayitId, sebep);
      yaniti(await api.kasaOku(kayitId));
    } catch (h) { hataYaz(h) } finally { setCalisiyor(false) }
  }

  function hataYaz(h: unknown) {
    if (h instanceof ApiHatasi) {
      if (h.hata.alanlar)
        setAlanHatalari(Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])));
      setHata(h.message);
    } else setHata(String(h));
  }

  if (!ekleyebilir && kayitId === null)
    return <div className="sahne"><div className="hata-kutusu">Kasa işlemi ekleme yetkiniz yok.</div></div>;

  const gruplar = ['tahsilat', 'odeme'] as const;
  const grupAdi: Record<string, string> = { tahsilat: 'Tahsilat', odeme: 'Ödeme' };

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{secili?.ad ?? 'Kasa İşlemi'}</h1>
          <span className="yol">
            Kasa › {secili?.grup === 'odeme' ? 'Ödeme' : 'Tahsilat'}
            {sonuc?.islem.islemNo ? ` · ${sonuc.islem.islemNo}` : ''}
          </span>
          {durum !== null && (
            <span className={`rozet ${durum === 2 ? 'olumlu' : durum === 3 ? 'uyari' : ''}`}>
              {KASA_DURUM[durum] ?? durum}
            </span>
          )}
          {kullanici?.subeYazma === false && <span className="rozet uyari">salt okuma şubesi</span>}

          <div className="sag">
            <button className="d" onClick={() => git('/kasa-islem')}>Listeye Dön</button>
            {!kilitli && (
              <>
                <button className="d" disabled={calisiyor} onClick={() => void kaydet(true)}>
                  Taslak Kaydet
                </button>
                <button className="d bir" disabled={calisiyor} onClick={() => void kaydet(false)}>
                  {calisiyor ? 'Kaydediliyor…' : 'Kaydet ve Kesinleştir'}
                </button>
              </>
            )}
            {kayitId !== null && durum === 0 && (
              <button className="d bir" disabled={calisiyor} onClick={() => void kesinlestir()}>
                Kesinleştir
              </button>
            )}
            {durum === 2 && (
              <button className="d teh" disabled={calisiyor} onClick={() => void iptalEt()}>
                İptal Et
              </button>
            )}
          </div>
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {sonuc?.uyarilar?.length ? (
          <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
        ) : null}

        <div className="kutu" style={{ padding: 14 }}>
          {/* Islem turu: grup sekmeleri + o gruptaki turler. Kaydedildikten sonra
              tur DEGISTIRILEMEZ - bacak sablonu ve fis buna bagli. */}
          <div className="kagrup">
            <h6>İşlem Türü</h6>
            <div className="cip-serit">
              {gruplar.flatMap(g => turler.filter(t => t.grup === g)).map(t => (
                <button
                  key={t.kod}
                  type="button"
                  className={`cip ${t.kod === tur ? 'secili' : ''}`}
                  disabled={sonuc !== null}
                  onClick={() => setTur(t.kod)}
                >
                  {grupAdi[t.grup] === 'Ödeme' ? '－' : '＋'} {t.ad}
                </button>
              ))}
            </div>
          </div>

          <div className="kagrup">
            <h6>Bilgiler</h6>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">İşlem Tarihi</span>
                <input type="date" value={tarih} disabled={kilitli}
                       onChange={e => setTarih(e.target.value)} />
              </label>

              <GenLookup
                kaynak="hesap"
                etiket={secili?.grup === 'odeme' ? 'Ödenen Hesap' : 'Tahsil Edilen Hesap'}
                zorunlu
                alanlar={LOOKUP_HESAP}
                sabitFiltre={secili?.anaHesapTuru
                  ? { alan: 'tur', op: 'esit', deger: secili.anaHesapTuru }
                  : undefined}
                deger={hesap?.ad}
                hata={alanHatalari.hesapId}
                saltOkunur={kilitli}
                onSec={(s: ListeSatiri | null) => setHesap(s ? {
                  id: Number(s.id), ad: String(s.ad ?? ''), doviz: String(s.dovizCinsi ?? 'TL'),
                } : null)}
              />

              {secili?.cariZorunlu !== -1 && (
                <GenLookup
                  kaynak="cari"
                  etiket="Cari"
                  zorunlu={secili?.cariZorunlu === 1}
                  alanlar={LOOKUP_CARI}
                  deger={cari?.unvan}
                  hata={alanHatalari.tarafId}
                  saltOkunur={kilitli}
                  onSec={s => setCari(s ? { id: Number(s.id), unvan: String(s.unvan ?? '') } : null)}
                />
              )}

              <label className="alan">
                <span className="etiket">Tutar {dovizli && `(${hesap?.doviz})`}</span>
                <input className="hiza-sag" value={tutar} disabled={kilitli}
                       onChange={e => setTutar(e.target.value)} />
                {alanHatalari.tutar && <span className="alan-hata">{alanHatalari.tutar}</span>}
              </label>

              {dovizli && (
                <>
                  <label className="alan">
                    <span className="etiket">Kur</span>
                    <input className="hiza-sag" value={kur} disabled={kilitli}
                           onChange={e => setKur(e.target.value)} />
                  </label>
                  <label className="alan">
                    <span className="etiket">TL Karşılığı (önizleme)</span>
                    <input className="hiza-sag onizleme" value={para.format(yerelOnizleme)} readOnly />
                  </label>
                </>
              )}

              {secili?.kalemTuru !== 0 && (
                <>
                  <label className="alan">
                    <span className="etiket">Masraf Tutarı</span>
                    <input className="hiza-sag" value={masrafTutar} disabled={kilitli}
                           placeholder="0,00"
                           onChange={e => setMasrafTutar(e.target.value)} />
                  </label>
                  <GenLookup
                    kaynak="masraf"
                    etiket="Gider Kalemi"
                    alanlar={LOOKUP_KALEM}
                    deger={kalem?.ad}
                    saltOkunur={kilitli}
                    onSec={s => setKalem(s ? { id: Number(s.id), ad: String(s.ad ?? '') } : null)}
                  />
                </>
              )}

              <GenLookup
                kaynak="proje"
                etiket="Proje"
                alanlar={LOOKUP_PROJE}
                sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
                deger={proje?.ad}
                saltOkunur={kilitli}
                onSec={s => setProje(s ? { id: Number(s.id), ad: String(s.ad ?? '') } : null)}
              />

              <label className="alan genis">
                <span className="etiket">Açıklama</span>
                <input value={aciklama} maxLength={200} disabled={kilitli}
                       onChange={e => setAciklama(e.target.value)} />
              </label>
            </div>
          </div>

          {/* Bacaklar: sunucunun urettigi muhasebe kaydinin ham hali. */}
          <div className="kagrup">
            <h6>Hareket Bacakları</h6>
            <BacakListesi bacaklar={sonuc?.bacaklar ?? []} dovizCinsi={hesap?.doviz ?? 'TL'} />
          </div>

          {sonuc?.fis && <FisOnizleme fis={sonuc.fis} />}

          {!kilitli && (
            <div className="not">
              Bacaklar ve muhasebe fişi sunucuda işlem türünün şablonundan üretilir;
              buradaki TL karşılığı yalnızca önizlemedir.
            </div>
          )}
        </div>
      </div>
    </>
  );
}
