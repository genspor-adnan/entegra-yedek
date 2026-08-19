import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { ApiHatasi, type BelgeYaniti, type ListeSatiri } from '../api/sozlesme';
import { GenLookup, LOOKUP_CARI, LOOKUP_STOK } from '../bilesenler/GenLookup';
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

/**
 * Satis faturasi ekrani — Faz 1 dikey diliminin son parcasi.
 *
 * TUTAR HESABI SUNUCUDA. Ekranda gosterilen satir tutari yalnizca ONIZLEMEDIR;
 * kaydedilen degerler her zaman sunucudan donen belgeden okunur. Delphi ile kurusu
 * kurusuna ayni olmasi gereken formul (ic yuvarlama + carpimsal iskonto + banker's)
 * tek yerde, sunucuda durur — istemciye kopyalanirsa iki formul birbirinden kayar.
 */
export function BelgeKarti() {
  const git = useNavigate();
  const { yetki, kullanici } = useOturum();

  const [cari, setCari] = useState<{ id: number; unvan: string } | null>(null);
  const [tarih, setTarih] = useState(new Date().toISOString().slice(0, 10));
  const [seri, setSeri] = useState('WEB');
  const [vadeGun, setVadeGun] = useState('30');
  const [depoId, setDepoId] = useState('1');
  const [taslak, setTaslak] = useState(false);
  const [satirlar, setSatirlar] = useState<SatirDurumu[]>([bosSatir(1)]);

  const [kaydediyor, setKaydediyor] = useState(false);
  const [sonuc, setSonuc] = useState<BelgeYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});

  const ekleyebilir = yetki('belge', 'ekle');

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
          tur: 15,                       // satis faturasi
          tarafId: cari.id,
          belgeTarihi: `${tarih}T${new Date().toTimeString().slice(0, 8)}`,
          belgeSeri: seri,
          belgeDovizi: 'TL',
          dovizKuru: 1,
          vadeGun: Number(vadeGun) || 0,
          cikisDepoId: Number(depoId) || null,
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

  if (!ekleyebilir)
    return <div className="sahne"><div className="hata-kutusu">Belge ekleme yetkiniz yok.</div></div>;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Satis Faturasi</h1>
          <span className="yol">Satis › Yeni Fatura · {kullanici?.subeler.find(s => s.id === kullanici?.subeId)?.ad}</span>
          {kullanici?.subeYazma === false && <span className="rozet uyari">salt okuma subesi</span>}
          <div className="sag">
            <label className="satir-ici">
            <input type="checkbox" checked={taslak} onChange={e => setTaslak(e.target.checked)} />
            Taslak (numara tuketmez)
          </label>
            <button className="d" onClick={() => git('/belge')}>Listeye Don</button>
            {sonuc
              ? <button className="d bir" onClick={yeniBelge}>Yeni Belge</button>
              : <button className="d bir" disabled={kaydediyor} onClick={() => void kes()}>
                  {kaydediyor ? 'Kesiliyor…' : 'Faturayi Kes'}
                </button>}
          </div>
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        {sonuc && (
        <div className="bilgi-kutusu">
          <b>Belge kaydedildi.</b>{' '}
          No: <b>{String(sonuc.belge.belgeNo || '(taslak — numara verilmedi)')}</b> ·
          Genel toplam: <b>{para.format(Number(sonuc.belge.genelToplam))}</b> ·
          <a href="#" onClick={e => { e.preventDefault(); git('/belge') }}> listede gor</a>
          {sonuc.uyarilar && sonuc.uyarilar.length > 0 && (
            <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
          )}
        </div>
      )}

        <div className="kutu" style={{ padding: 14 }}>
        <div className="kagrup">
          <h6>Belge</h6>
          <div className="alan-izgara">
            <GenLookup
              kaynak="cari"
              etiket="Cari"
              zorunlu
              alanlar={LOOKUP_CARI}
              deger={cari?.unvan}
              hata={alanHatalari.tarafId}
              saltOkunur={!!sonuc}
              onSec={s => setCari(s ? { id: Number(s.id), unvan: String(s.unvan ?? '') } : null)}
            />
            <label className="alan">
              <span className="etiket">Belge Tarihi</span>
              <input type="date" value={tarih} disabled={!!sonuc} onChange={e => setTarih(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">Seri</span>
              <input value={seri} maxLength={5} disabled={!!sonuc} onChange={e => setSeri(e.target.value.toUpperCase())} />
            </label>
            <label className="alan">
              <span className="etiket">Vade (gun)</span>
              <input value={vadeGun} disabled={!!sonuc} onChange={e => setVadeGun(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">Cikis Deposu</span>
              <input value={depoId} disabled={!!sonuc} onChange={e => setDepoId(e.target.value)} />
            </label>
          </div>
        </div>

        <div className="kagrup">
          <h6>
            Satirlar
            {!sonuc && <button type="button" className="d" onClick={satirEkle}>+ Satir</button>}
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
                {!sonuc && <th />}
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
                        saltOkunur={!!sonuc}
                        onSec={satir => stokSec(s.anahtar, satir)}
                      />
                    </td>
                    <td><input className="hiza-sag" value={s.adet} disabled={!!sonuc}
                               onChange={e => satirDegis(s.anahtar, 'adet', e.target.value)} /></td>
                    <td><input className="hiza-sag" value={s.birimFiyat} disabled={!!sonuc}
                               onChange={e => satirDegis(s.anahtar, 'birimFiyat', e.target.value)} /></td>
                    <td><input className="hiza-sag" value={s.iskonto} disabled={!!sonuc}
                               onChange={e => satirDegis(s.anahtar, 'iskonto', e.target.value)} /></td>
                    <td><input className="hiza-sag" value={s.kdv} disabled={!!sonuc}
                               onChange={e => satirDegis(s.anahtar, 'kdv', e.target.value)} /></td>
                    <td className="hiza-sag onizleme">{para.format(tutar)}</td>
                    {!sonuc && (
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
          {!sonuc && <div className="not">Kesin tutar sunucuda hesaplanir; buradaki degerler onizlemedir.</div>}
        </div>
      </div>
      </div>
    </>
  );
}
