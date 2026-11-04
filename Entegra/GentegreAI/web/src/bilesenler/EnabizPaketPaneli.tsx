import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat, sayiya, metne } from './bicim';
import { c } from '../dil/ceviri';

/**
 * e-NABIZ PAKET KARTI (454) — kuyruk satırının altında açılan detay.
 *
 * Kuyrukta "Eksik Alan" ya da "Hatalı" yazan satırın cevabı burada: hangi USS
 * alanı boş, hangi kaynak kolondan gelmesi gerekiyordu, kaçıncı denemede ne
 * hatası alındı.
 *
 * <b>Panel SALT OKUNURDUR.</b> Paket elle düzeltilmez: eksik KAYNAKTA
 * düzeltilir ve paket yeniden üretilir (araç çubuğundaki "Yeniden Üret").
 * Paketi elle düzeltmek, USS'ye giden veri ile hastanın dosyasındaki veriyi
 * birbirinden ayırırdı.
 */

type Satir = Record<string, unknown>;


const DURUM: Record<number, string> = {
  0: 'Eksik Alan', 1: 'Bekliyor', 2: 'Gönderiliyor', 3: 'Gönderildi',
  4: 'Hatalı', 5: 'İptal', 6: 'USS’de silindi',
};
const HATA_SINIFI: Record<number, string> = {
  1: 'veri hatası — kullanıcı düzeltir', 2: 'servis hatası — otomatik tekrar',
  3: 'yetki hatası',
};
const ISLEM: Record<number, string> = { 1: 'Ekle', 2: 'Güncelle', 3: 'Sil' };

const durumSinifi = (d: number) =>
  d === 3 ? 'rozet olumlu' : d === 4 ? 'rozet hata'
  : d === 0 ? 'rozet uyari' : 'rozet gri';

export function EnabizPaketPaneli({ paketId }: { paketId: number }) {
  const [paket, setPaket] = useState<Satir | null>(null);
  const [alanlar, setAlanlar] = useState<Satir[]>([]);
  const [denemeler, setDenemeler] = useState<Satir[]>([]);
  const [hata, setHata] = useState('');

  useEffect(() => {
    let iptal = false;
    setHata('');
    void (async () => {
      try {
        const y = await api.enabizPaketOku(paketId);
        if (iptal) return;
        setPaket(y.paket); setAlanlar(y.alanlar); setDenemeler(y.denemeler);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
    })();
    return () => { iptal = true };
  }, [paketId]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!paket) return <div className="kagrup"><div className="bos">{c('Paket okunuyor…')}</div></div>;

  const durum = sayiya(paket.durum);
  const eksikSayisi = alanlar.filter(a => sayiya(a.gecerli) === 0).length;

  return (
    <div className="enabiz-detay">
      <div className="kagrup">
        <h6>
          {metne(paket.paketNo) || 'Paket'} — {metne(paket.turAdi)}
          <span className="sonuk"> · USS {metne(paket.ussPaket)}
            {metne(paket.ussSurum) ? ` (sürüm ${metne(paket.ussSurum)})` : ''}
            {' · '}{ISLEM[sayiya(paket.islem)] ?? '—'}</span>
          <span className={durumSinifi(durum)} style={{ marginLeft: 6 }}>
            {DURUM[durum] ?? '—'}
          </span>
        </h6>

        <table className="detay-tablo">
          <thead><tr>
            <th style={{ width: 34 }} />
            <th>{c('USS Alanı')}</th><th>Değer</th><th>Kaynak</th><th>SKRS Listesi</th>
          </tr></thead>
          <tbody>
            {alanlar.map((a, i) => {
              const gecerli = sayiya(a.gecerli) === 1;
              return (
                <tr key={i} className={gecerli ? undefined : 'eksik'}>
                  <td className="orta">{gecerli ? '✔' : '⚠'}</td>
                  <td><b>{metne(a.ussAlan)}</b>
                    {!gecerli && metne(a.sorun) && (
                      <div className="sonuk">{metne(a.sorun)}</div>
                    )}
                  </td>
                  <td>{metne(a.deger) || <span className="sonuk">(boş)</span>}</td>
                  <td className="sonuk">{metne(a.kaynakAlan) || '—'}</td>
                  <td className="sonuk">{metne(a.skrsListe) || '—'}</td>
                </tr>
              );
            })}
            {alanlar.length === 0 && (
              <tr><td colSpan={5} className="bos">{c('Paket alanı yok.')}</td></tr>
            )}
          </tbody>
        </table>

        {eksikSayisi > 0 && (
          <div className="not">
            {eksikSayisi} alan eksik. Düzeltme KAYNAKTA yapılır (hasta kartı,
            başvuru, muayene); sonra araç çubuğundan <b>{c('Yeniden Üret')}</b>.
          </div>
        )}
      </div>

      <div className="kagrup">
        <h6>Gönderim denemeleri
          <span className="sonuk"> · {sayiya(paket.deneme)} deneme</span>
        </h6>

        <table className="detay-tablo">
          <thead><tr>
            <th>Zaman</th><th className="orta">Sonuç</th><th>{c('USS Yanıtı')}</th>
            <th className="sag">Süre</th>
          </tr></thead>
          <tbody>
            {denemeler.map((d, i) => (
              <tr key={i}>
                <td>{tarihSaat(d.zaman)}</td>
                <td className="orta">
                  <span className={sayiya(d.sonuc) === 1 ? 'rozet olumlu' : 'rozet hata'}>
                    {sayiya(d.sonuc) === 1 ? 'Başarılı' : `Hata ${sayiya(d.httpKod) || ''}`}
                  </span>
                </td>
                <td>{metne(d.ussKod) && <b>{metne(d.ussKod)} </b>}{metne(d.ussMesaj) || '—'}</td>
                <td className="sag">{sayiya(d.sureMs)} ms</td>
              </tr>
            ))}
            {denemeler.length === 0 && (
              <tr><td colSpan={4} className="bos">{c('Henüz gönderim denemesi yok.')}</td></tr>
            )}
          </tbody>
        </table>

        {/* Hata sınıfı ayrımı gerçek: servis hatası kendiliğinden tekrarlanır,
            veri hatası tekrarlanmaz - aynı veriyi beş kez göndermek aynı
            cevabı beş kez almaktır. */}
        {durum === 4 && (
          <div className="not">
            <b>{metne(paket.hataKodu) || 'Hata'}</b> — {metne(paket.hataMesaj) || '—'}
            {sayiya(paket.hataSinifi) > 0 && (
              <> · {HATA_SINIFI[sayiya(paket.hataSinifi)]}</>
            )}
          </div>
        )}
        <div className="not sonuk">
          Olay {tarihSaat(paket.olayTarihi)} · üretim {tarihSaat(paket.uretimTarihi)}
          {paket.sonTarih ? <> · süre sınırı {tarihSaat(paket.sonTarih)}</> : null}
          {metne(paket.ussPaketId) ? <> · USS paket id {metne(paket.ussPaketId)}</> : null}
        </div>
      </div>
    </div>
  );
}
