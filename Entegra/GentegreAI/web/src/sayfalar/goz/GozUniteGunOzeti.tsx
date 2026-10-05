import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { tarihSaat } from '../../bilesenler/bicim';
import type { GozUniteOzeti } from '../../api/uclar/goz';
import { c } from '../../dil/ceviri';
import { GOZ_ISTASYON } from '../../bilesenler/goz/gozPanoSabitleri';

/**
 * GÖZ ÜNİTESİ GÜN ÖZETİ ÇIKTISI (976, mockup araç çubuğundaki "🖨 Gün Özeti").
 *
 * <b>Panonun kâğıt hâli değil, GÜNÜN kâğıt hâli.</b> Pano o anki sırayı
 * gösteriyor; burada gün sonunda imzalanıp dosyalanan şey var: kaç ziyaret,
 * ortalama bekleme, darboğaz hangi kaynakta, hangi hekim ne kadar geciktirdi.
 * Ekranı yazdırmaya zorlamak kâğıda sürükle-bırak sütunlarını basmak olurdu.
 *
 * <b>Veri panonun kendi ucundan</b> (<c>/api/goz/unite-ozet</c>): ikinci bir
 * "gün özeti" sorgusu yazmak, aynı günün iki farklı ortalamasıyla iki belge
 * üretmenin en kısa yoluydu. Geçmiş gün için <c>?gun=YYYY-MM-DD</c>.
 *
 * Yazdırma tarayıcınındır ("PDF olarak kaydet" de orada) - ayrı bir PDF
 * üreticisi YOK (şema / lab / radyoloji çıktılarıyla aynı karar).
 */
export function GozUniteGunOzeti() {
  const git = useNavigate();
  const [param] = useSearchParams();
  const gun = param.get('gun') ?? undefined;
  const [veri, setVeri] = useState<GozUniteOzeti | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    void (async () => {
      try { setVeri(await api.gozUniteOzeti(gun)) } catch (h) { setHata(hataMetni(h)) }
    })();
  }, [gun]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const a = veri.antet;
  const g = veri.gunOzet;
  const k = veri.acik;
  const d = veri.darbogaz;
  const adres = [a?.adres, [a?.ilce, a?.il].filter(Boolean).join(' / ')]
    .filter(x => String(x ?? '').trim() !== '').join(' · ');
  const ist = (n: number) => c(GOZ_ISTASYON[n] ?? '');

  return (
    <div className="gp-cikti">
      {/* Araç çubuğu YAZDIRILMAZ (@media print) - kâğıtta yalnız belge kalır. */}
      <div className="cikti-arac">
        <button className="d bir" onClick={() => window.print()}>🖨 {c('Yazdır')}</button>
        <button className="d" onClick={() => git(-1)}>← {c('Geri')}</button>
      </div>

      <div className="cikti-sayfa">
        <div className="cikti-antet">
          <AntetLogo dokumanId={a?.logoDokumanId ?? undefined} />
          <div>
            <b>{a?.unvan ?? '—'}</b>
            {adres && <div className="sonuk">{adres}</div>}
            {a?.telefon ? <div className="sonuk">Tel: {a.telefon}</div> : null}
          </div>
          <div className="sag">
            <b>{c('Göz Ünitesi — Gün Özeti')}</b>
            <div className="sonuk">{c('Gün')}: {veri.gun}</div>
            <div className="sonuk">{c('Üretim')}: {tarihSaat(new Date().toISOString())}</div>
          </div>
        </div>

        {/* SAYAÇLAR: panonun yedi kutusu, kâğıtta tablo olarak - kutular
            ekranda yan yana okunuyor, kâğıtta satır olarak taranıyor. */}
        <table className="cikti-kimlik">
          <tbody>
            <tr>
              <th>{c('Ziyaret')}</th><td>{g?.ziyaret ?? 0}</td>
              <th>{c('Tamamlanan')}</th><td>{g?.tamamlanan ?? 0}</td>
            </tr>
            <tr>
              <th>{c('Hâlâ ünitede')}</th><td>{g?.unitede ?? 0}</td>
              <th>{c('Ort. ziyaret')}</th><td>{g?.ortZiyaretDk ?? 0} dk</td>
            </tr>
            <tr>
              <th>{c('Ort. bekleme')}</th><td>{k?.ortBeklemeDk ?? 0} dk</td>
              <th>{c('En uzun bekleme')}</th>
              <td>
                {k?.enUzunDk ?? 0} dk
                {veri.enUzun ? ` · ${veri.enUzun.hasta} (${ist(veri.enUzun.istasyon)})` : ''}
              </td>
            </tr>
            <tr>
              <th>{c('Dilatasyonda')}</th>
              <td>{k?.dilatasyonda ?? 0} ({k?.dilatasyonHazir ?? 0} {c('hazır')})</td>
              {/* DARBOĞAZ KÂĞITTA DA ADIYLA: "ünite yoğundu" cümlesi gün
                  sonunda kimseye bir şey yaptırmıyor. */}
              <th>{c('Darboğaz')}</th>
              <td>{d ? `${ist(d.istasyon)} · ${d.sayi} ${c('kişi')} · ${c('en uzun')} ${d.enUzunDk} dk` : '—'}</td>
            </tr>
          </tbody>
        </table>

        <div className="cikti-blok">
          <h4>{c('İstasyon dağılımı')}</h4>
          <table className="gl-mini">
            <tbody>
              <tr><th>{c('İstasyon')}</th><th className="sag">{c('Açık kayıt')}</th>
                  <th className="sag">{c('En uzun bekleme')}</th></tr>
              {veri.istasyonlar.length === 0 && (
                <tr><td colSpan={3} className="sonuk">{c('Ünitede açık kayıt yok.')}</td></tr>
              )}
              {veri.istasyonlar.map(i => (
                <tr key={i.istasyon}>
                  <td>{ist(i.istasyon)}</td>
                  <td className="sag">{i.sayi}</td>
                  <td className="sag">{i.enUzunDk} dk</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="cikti-blok">
          <h4>{c('Oda ve cihaz doluluğu')}</h4>
          <table className="gl-mini">
            <tbody>
              <tr><th>{c('Kaynak')}</th><th>{c('Tür')}</th><th>{c('Şu an')}</th>
                  <th className="sag">{c('Süre')}</th><th className="sag">{c('Sıra')}</th></tr>
              {veri.odalar.length === 0 && (
                <tr><td colSpan={5} className="sonuk">{c('Oda / cihaz tanımlanmamış.')}</td></tr>
              )}
              {veri.odalar.map(o => (
                <tr key={`${o.kaynakId ?? 'x'}-${o.oda}`}>
                  <td>{o.oda}{o.sahip ? ` · ${o.sahip}` : ''}</td>
                  <td>{o.turAdi}</td>
                  <td>{o.bos ? c('boş') : o.hasta}</td>
                  <td className="sag">{o.bos ? '—' : `${o.sureDk} dk`}</td>
                  <td className="sag">{o.sayi || '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="cikti-blok">
          <h4>{c('Hekim ve tekniker yükü')}</h4>
          <table className="gl-mini">
            <tbody>
              <tr><th>{c('Kişi')}</th><th className="sag">{c('Tamam')}</th>
                  <th className="sag">{c('Bekleyen')}</th><th className="sag">{c('Ort. süre')}</th>
                  <th className="sag">{c('Gecikme')}</th></tr>
              {veri.hekimler.length === 0 && (
                <tr><td colSpan={5} className="sonuk">{c('Bugün istasyonlara personel atanmamış.')}</td></tr>
              )}
              {veri.hekimler.map(h => (
                <tr key={h.personelId}>
                  <td>{h.personel}</td>
                  <td className="sag">{h.tamamlanan}</td>
                  <td className="sag">{h.bekleyen}</td>
                  <td className="sag">{h.ortDk ? `${h.ortDk} dk` : '—'}</td>
                  {/* Randevusuz hastada gecikme ÖLÇÜLEMEZ - kâğıtta da "—". */}
                  <td className="sag">{h.gecikmeDk === null ? '—' : `${h.gecikmeDk > 0 ? '+' : ''}${h.gecikmeDk} dk`}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="cikti-bos sonuk">
          {c('Ön tetkik ünitenin girişidir: tıkanırsa hekim odası boş kalır. '
             + 'Gecikme randevu saatine göre ölçülür; randevusuz hastada ölçülemez.')}
        </div>
      </div>
    </div>
  );
}
