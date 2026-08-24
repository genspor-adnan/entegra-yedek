import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { ApiHatasi, type PanelYaniti } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const sayi = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 0 });

/** Gunun saatine gore selam - mockup'taki "İyi çalışmalar, <ad>" seridi. */
function selam(): string {
  const s = new Date().getHours();
  if (s < 6)  return 'İyi geceler';
  if (s < 12) return 'Günaydın';
  if (s < 18) return 'İyi çalışmalar';
  return 'İyi akşamlar';
}

/** Kutuya tiklayinca gidilecek liste; yolu olmayan kutu tiklanmaz. */
const HIZLI_ERISIM = [
  { ad: '＋ Satış Faturası', yol: '/belge' },
  { ad: '＋ Satış İrsaliyesi', yol: '/satis-irsaliye' },
  { ad: '＋ Alış Faturası', yol: '/alis-fatura' },
  { ad: '＋ Tahsilat', yol: '/kasa-islem' },
  { ad: '＋ Stok Transfer', yol: '/stok-transfer' },
  { ad: 'Cari Listesi', yol: '/musteri' },
];

/**
 * ANA SAYFA PANELI (Ekranlar/giris_sayfasi.html).
 *
 * YALNIZ GERCEK VERI: mockup'ta gorev/takvim/duyuru kutulari da var ama o
 * moduller semada yok - uydurma sayi, panele bakip karar veren kullaniciyi
 * yaniltir. Modul geldiginde buraya eklenecek.
 *
 * Tek istek (/api/panel) butun kutulari ve listeleri getirir; sube suzgeci
 * sunucuda, oturumun aktif subesine gore uygulanir.
 */
export function Panel() {
  const git = useNavigate();
  const { kullanici } = useOturum();
  const [veri, setVeri] = useState<PanelYaniti | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    void api.panel()
      .then(setVeri)
      .catch(h => setHata(h instanceof ApiHatasi ? h.message : String(h)))
      .finally(() => setYukleniyor(false));
  }, []);

  const kutuDeger = (deger: number, birim: string) =>
    birim === '₺' ? `${para.format(deger)} ₺` : `${sayi.format(deger)} ${birim}`;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{selam()}, {kullanici?.ad ?? ''}</h1>
          <span className="yol">
            {new Date().toLocaleDateString('tr-TR',
              { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
          </span>
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <>
            <div className="panel-kutular">
              {(veri?.kutular ?? []).map(k => (
                <button key={k.anahtar} type="button" className="kpi panel-kpi"
                        onClick={() => k.yol && git(k.yol)}
                        title={k.yol ? 'Listeyi aç' : undefined}>
                  <div className="k">{k.baslik}</div>
                  <div className={`v ${k.vurgu}`}>{kutuDeger(Number(k.deger), k.birim)}</div>
                  <div className="s">{k.alt}</div>
                </button>
              ))}
            </div>

            <div className="panel-sutunlar">
              <div className="kagrup">
                <h6>Son Belgeler</h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.sonBelgeler ?? []).map(s => (
                      <tr key={`b${s.id}`} onDoubleClick={() => git(s.yol)}
                          title="Çift tıkla: listeyi aç">
                        <td>{s.ana}</td>
                        <td className="sonuk">{s.yan}</td>
                        <td className="hiza-sag">{s.deger}</td>
                      </tr>
                    ))}
                    {(veri?.sonBelgeler ?? []).length === 0 && (
                      <tr><td className="bos">Henüz belge yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>

              <div className="kagrup">
                <h6>Kritik Stok <span className="sonuk">(kullanılabilir / minimum)</span></h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.kritikStok ?? []).map(s => (
                      <tr key={`s${s.id}`} onDoubleClick={() => git(s.yol)}>
                        <td><code>{s.ana}</code></td>
                        <td className="sonuk">{s.yan}</td>
                        <td className="hiza-sag"><b className="hata-metin">{s.deger}</b></td>
                      </tr>
                    ))}
                    {(veri?.kritikStok ?? []).length === 0 && (
                      <tr><td className="bos">Minimum seviyenin altında stok yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>

              <div className="kagrup">
                <h6>En Büyük Cari Bakiyeler</h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.buyukBakiyeler ?? []).map(s => (
                      <tr key={`c${s.id}`} onDoubleClick={() => git(s.yol)}>
                        <td>{s.ana}</td>
                        <td className="hiza-orta">
                          <span className={`rozet ${s.yan === 'Alacak' ? 'ok' : 'uyari'}`}>{s.yan}</span>
                        </td>
                        <td className="hiza-sag">{s.deger}</td>
                      </tr>
                    ))}
                    {(veri?.buyukBakiyeler ?? []).length === 0 && (
                      <tr><td className="bos">Bakiyeli cari yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="kagrup">
              <h6>Hızlı Erişim</h6>
              <div className="gridtb" style={{ padding: 10, flexWrap: 'wrap' }}>
                {HIZLI_ERISIM.map(h => (
                  <button key={h.yol} type="button" className="d" onClick={() => git(h.yol)}>
                    {h.ad}
                  </button>
                ))}
              </div>
            </div>
          </>
        )}
      </div>
    </>
  );
}
