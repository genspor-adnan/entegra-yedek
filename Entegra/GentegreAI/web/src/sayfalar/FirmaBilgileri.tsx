import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { ListeSatiri } from '../api/sozlesme';
import { GenForm } from '../bilesenler/GenForm';

const SEKMELER = [
  { anahtar: 'firma',   baslik: 'Firma Kimliği' },
  { anahtar: 'subeler', baslik: 'Şube Tanımları' },
  { anahtar: 'depolar', baslik: 'Depolar' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/** Ust seritte kalan alanlar (kullanici): ünvan, kısa ad, durum. Kimligin geri
    kalani "Kimlik" sekmesinde - serit karti TANIMLAR, doldurmaz. */
const SERIT_ALANLARI = ['unvan', 'ad', 'aktif'];

/**
 * FIRMA BILGILERI (Yonetim › Firma Bilgileri) — mockup: Ekranlar/firma_bilgileri.html
 *
 * Neden ozel sayfa, duz liste degil: mockup'ta ekran TEK bir firmayi anlatir,
 * subeler onun ALTINDA bir tablodur. Duz liste acsaydik tek subeli kurulumda
 * (cogunluk) kullanici once bir satir listesi gorup icine girmek zorunda kalirdi.
 *
 * FIRMA = VARSAYILAN SUBE. Ayri bir "firma" tablosu ACILMADI: e-Belgede gonderici
 * taraf zaten sube bazlidir (fatura hangi subeden kesildiyse onun unvani ve adresi
 * gider), dolayisiyla firma bilgisi subenin kendisidir. Cok subeli kurulumda ust
 * form sadece secili subeyi gosterir.
 *
 * e-BELGE SERIDI: gonderim icin zorunlu alanlar (unvan/VKN/vergi dairesi/adres/il)
 * eksikse ustte uyari cikar - eksik bilgi ancak fatura gonderilirken fark ediliyordu.
 */
export function FirmaBilgileri() {
  const [aktif, setAktif] = useState<Sekme>('firma');
  const [subeler, setSubeler] = useState<ListeSatiri[]>([]);
  const [depolar, setDepolar] = useState<ListeSatiri[]>([]);
  const [seciliId, setSeciliId] = useState<number | null>(null);
  const [yeniAcik, setYeniAcik] = useState(false);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  /** GenForm'u kayit sonrasi yeniden kurmak icin (form ic durumunu tazeler). */
  const [tazele, setTazele] = useState(0);

  const yukle = useCallback(async () => {
    setYukleniyor(true);
    try {
      const [s, d] = await Promise.all([
        api.liste('sube', { boyut: 200, sirala: [{ alan: 'varsayilan', yon: 'desc' }] }),
        api.liste('depo', { boyut: 200 }),
      ]);
      setSubeler(s.satirlar);
      setDepolar(d.satirlar);
      // Ilk acilista varsayilan sube secili gelir - "firma bilgisi" odur.
      setSeciliId(onceki => onceki ?? (Number(s.satirlar[0]?.id) || null));
      setHata(null);
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setYukleniyor(false);
    }
  }, []);

  useEffect(() => { void yukle(); }, [yukle]);

  const secili = subeler.find(s => Number(s.id) === seciliId);
  const eksik = secili ? String(secili.ebelgeHazir ?? '') !== 'Tamam' : false;

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

      {!yukleniyor && aktif === 'firma' && (
        seciliId == null
          ? <div className="not">Şube kaydı yok. “Şube Tanımları” sekmesinden ekleyin.</div>
          : (
            <>
              {eksik && (
                <div className="hata-kutusu">
                  Bu şubede e-Belge için zorunlu bilgiler eksik (resmî unvan, VKN,
                  vergi dairesi, adres, il). Fatura gönderimi bunlar girilene kadar
                  yapılamaz.
                </div>
              )}
              {subeler.length > 1 && (
                <div className="alan" style={{ maxWidth: 320, marginBottom: 8 }}>
                  <label className="etiket" htmlFor="sube-sec">Şube</label>
                  <select id="sube-sec" value={seciliId}
                          onChange={e => setSeciliId(Number(e.target.value))}>
                    {subeler.map(s => (
                      <option key={String(s.id)} value={Number(s.id)}>
                        {String(s.ad ?? '')}{Number(s.varsayilan) === 1 ? ' (varsayılan)' : ''}
                      </option>
                    ))}
                  </select>
                </div>
              )}
              <GenForm key={`${seciliId}-${tazele}`}
                       kaynak="sube" id={seciliId} gomulu
                       seritAlanlari={SERIT_ALANLARI}
                       onKaydedildi={() => { setTazele(t => t + 1); void yukle(); }} />
            </>
          )
      )}

      {!yukleniyor && aktif === 'subeler' && (
        <div className="kagrup">
          <div className="numaralama-bas bitisik">
            <h6>Şube Tanımları</h6>
            <button className="d bir" onClick={() => setYeniAcik(true)}>+ Yeni Şube</button>
          </div>
          <table className="grid">
            <thead>
              <tr>
                <th>Kod</th><th>Şube Adı</th><th>Resmî Unvan</th>
                <th>İlçe / İl</th><th>Telefon</th>
                <th style={{ textAlign: 'center' }}>Vars.</th><th style={{ textAlign: 'center' }}>e-Belge</th>
                <th style={{ textAlign: 'center' }}>Durum</th>
              </tr>
            </thead>
            <tbody>
              {subeler.map(s => (
                <tr key={String(s.id)}
                    onDoubleClick={() => { setSeciliId(Number(s.id)); setAktif('firma'); }}>
                  <td>{String(s.kod ?? '')}</td>
                  <td>{String(s.ad ?? '')}</td>
                  <td>{String(s.unvan ?? '')}</td>
                  <td>{[s.ilce, s.il].filter(Boolean).join(' / ')}</td>
                  <td>{String(s.telefon ?? '')}</td>
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
                </tr>
              ))}
            </tbody>
          </table>
          <div className="not">
            Satıra çift tıklayınca şube bilgileri açılır. <b>Gönderici Kimliği</b>
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

      {/* Baslik verilince GenForm kendini modal icinde cizer (NumaralamaSekmesi deseni). */}
      {yeniAcik && (
        <GenForm kaynak="sube" id="yeni" baslik="Yeni Şube"
                 onKapat={() => setYeniAcik(false)}
                 onKaydedildi={id => { setYeniAcik(false); setSeciliId(id); setAktif('firma'); void yukle(); }} />
      )}
    </>
  );
}
