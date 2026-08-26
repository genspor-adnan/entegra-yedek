import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { ListeSatiri } from '../api/sozlesme';
import { GenForm } from '../bilesenler/GenForm';

const SEKMELER = [
  { anahtar: 'subeler', baslik: 'Şube Tanımları' },
  { anahtar: 'depolar', baslik: 'Depolar' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/** Kart seridinde kalan alanlar: ünvan, kısa ad, durum. Kimligin geri kalani
    kartin "Kimlik" sekmesinde - serit karti TANIMLAR, doldurmaz. */
const SERIT_ALANLARI = ['unvan', 'ad', 'aktif'];

/**
 * FIRMA BILGILERI (Yonetim › Firma Bilgileri) — mockup: Ekranlar/firma_bilgileri.html
 *
 * EKRAN = SUBE LISTESI, kart MODAL olarak acilir (kullanici): firma bilgisi
 * sayfaya gomulu dururken hangi kaydin duzenlendigi belirsizdi ve tek subeli
 * kurulumda bile sekme degistirmek gerekiyordu. Simdi liste tek gorunum,
 * "+ Yeni Şube" ve satirdaki "Düzenle" ayni karti acar.
 *
 * FIRMA = VARSAYILAN SUBE. Ayri bir "firma" tablosu ACILMADI: e-Belgede gonderici
 * taraf zaten sube bazlidir (fatura hangi subeden kesildiyse onun unvani ve adresi
 * gider), dolayisiyla firma bilgisi subenin kendisidir.
 *
 * e-BELGE ROZETI: gonderim icin zorunlu alanlar (unvan/VKN/vergi dairesi/adres/il)
 * eksikse listede gorunur - eksik bilgi ancak fatura gonderilirken fark ediliyordu.
 */
export function FirmaBilgileri() {
  const [aktif, setAktif] = useState<Sekme>('subeler');
  const [subeler, setSubeler] = useState<ListeSatiri[]>([]);
  const [depolar, setDepolar] = useState<ListeSatiri[]>([]);
  /** Karti acan kayit: sayi = duzenle, 'yeni' = ekle, null = kart kapali. */
  const [kart, setKart] = useState<number | 'yeni' | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      const [s, d] = await Promise.all([
        api.liste('sube', { boyut: 200, sirala: [{ alan: 'varsayilan', yon: 'desc' }] }),
        api.liste('depo', { boyut: 200 }),
      ]);
      setSubeler(s.satirlar);
      setDepolar(d.satirlar);
      setHata(null);
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setYukleniyor(false);
    }
  }, []);

  useEffect(() => { void yukle(); }, [yukle]);

  const eksikSube = subeler.filter(s => String(s.ebelgeHazir ?? '') !== 'Tamam').length;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Firma Bilgileri</h1>
          <span className="yol">Yönetim › Firma Bilgileri</span>
        </div>
      </div>

      <div className="katab">
        {SEKMELER.map(s => (
          <div key={s.anahtar}
               className={`kat${s.anahtar === aktif ? ' on' : ''}`}
               onClick={() => setAktif(s.anahtar)}>
            {s.baslik}
          </div>
        ))}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}

      {!yukleniyor && aktif === 'subeler' && (
        <div className="kagrup">
          <div className="numaralama-bas bitisik">
            <h6>Şube Tanımları</h6>
            <button className="d bir" onClick={() => setKart('yeni')}>+ Yeni Şube</button>
          </div>

          {/* e-Belge icin bilgisi eksik sube varsa ustte uyari: gonderim o
              subeden yapilamaz ve sebebi ancak fatura kesilirken anlasilirdi. */}
          {eksikSube > 0 && (
            <div className="hata-kutusu">
              {eksikSube} şubede e-Belge için zorunlu bilgiler eksik (ünvan, VKN,
              vergi dairesi, adres, il). O şubeden fatura gönderilemez.
            </div>
          )}

          <table className="grid">
            <thead>
              <tr>
                <th>Kod</th><th>Şube Adı</th><th>Ünvan</th>
                <th>İlçe / İl</th><th>Telefon</th>
                <th>Gönderici Kimliği</th>
                <th style={{ textAlign: 'center' }}>Vars.</th>
                <th style={{ textAlign: 'center' }}>e-Belge</th>
                <th style={{ textAlign: 'center' }}>Durum</th>
                <th style={{ width: 90 }}></th>
              </tr>
            </thead>
            <tbody>
              {subeler.map(s => (
                <tr key={String(s.id)} onDoubleClick={() => setKart(Number(s.id))}>
                  <td>{String(s.kod ?? '')}</td>
                  <td>{String(s.ad ?? '')}</td>
                  <td>{String(s.unvan ?? '')}</td>
                  <td>{[s.ilce, s.il].filter(Boolean).join(' / ')}</td>
                  <td>{String(s.telefon ?? '')}</td>
                  <td>{String(s.ebelgeKimlikAdi ?? 'Kendi')}</td>
                  <td style={{ textAlign: 'center' }}>{Number(s.varsayilan) === 1 ? '✓' : ''}</td>
                  <td style={{ textAlign: 'center' }}>
                    <span className={`rozet ${String(s.ebelgeHazir) === 'Tamam' ? 'ok' : 'uyari'}`}>
                      {String(s.ebelgeHazir ?? '')}
                    </span>
                  </td>
                  <td style={{ textAlign: 'center' }}>
                    <span className={`rozet ${Number(s.aktif) === 1 ? 'ok' : 'gri'}`}>
                      {Number(s.aktif) === 1 ? 'Aktif' : 'Pasif'}
                    </span>
                  </td>
                  <td style={{ textAlign: 'center' }}>
                    <button className="d" onClick={() => setKart(Number(s.id))}>Düzenle</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="not">
            Satıra çift tıklayınca da kart açılır. <b>Gönderici Kimliği</b>
            “Merkez” ise şubenin faturası merkezin ünvanı ve VKN’siyle gider;
            “Merkez kimliği + şube adresi”nde ünvan/VKN merkezin, adres şubenindir.
          </div>
        </div>
      )}

      {!yukleniyor && aktif === 'depolar' && (
        <div className="kagrup">
          <h6>Depolar</h6>
          <table className="grid">
            <thead>
              <tr><th>Depo Adı</th><th>Tipi</th><th style={{ textAlign: 'center' }}>Durum</th></tr>
            </thead>
            <tbody>
              {depolar.map(d => (
                <tr key={String(d.id)}>
                  <td>{String(d.ad ?? '')}</td>
                  <td>{String(d.tipAdi ?? '')}</td>
                  <td style={{ textAlign: 'center' }}>
                    <span className={`rozet ${String(d.durumAdi) === 'Aktif' ? 'ok' : 'gri'}`}>
                      {String(d.durumAdi ?? '')}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {/* Depo BAKIMI Stok menusunde; burasi mockup'taki gibi yalniz gorunum. */}
          <div className="not">Depo tanımları Stok &amp; Hizmet › Depolar ekranından yönetilir.</div>
        </div>
      )}

      {/* Baslik verilince GenForm kendini modal icinde cizer. Ayni kart hem
          "+ Yeni Şube" hem "Düzenle" icin - iki ayri akis tutulmaz. */}
      {kart !== null && (
        <GenForm kaynak="sube" id={kart}
                 baslik={kart === 'yeni' ? 'Yeni Şube' : 'Firma / Şube'}
                 seritAlanlari={SERIT_ALANLARI}
                 onKapat={() => setKart(null)}
                 onKaydedildi={() => { setKart(null); void yukle(); }} />
      )}
    </>
  );
}
