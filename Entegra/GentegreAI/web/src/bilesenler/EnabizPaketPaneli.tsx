import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from './bicim';

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

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);

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
  if (!paket) return <div className="kagrup"><div className="bos">Paket okunuyor…</div></div>;

  const durum = sayi(paket.durum);
  const eksikSayisi = alanlar.filter(a => sayi(a.gecerli) === 0).length;

  return (
    <div className="enabiz-detay">
      <div className="kagrup">
        <h6>
          {metin(paket.paketNo) || 'Paket'} — {metin(paket.turAdi)}
          <span className="sonuk"> · USS {metin(paket.ussPaket)}
            {metin(paket.ussSurum) ? ` (sürüm ${metin(paket.ussSurum)})` : ''}
            {' · '}{ISLEM[sayi(paket.islem)] ?? '—'}</span>
          <span className={durumSinifi(durum)} style={{ marginLeft: 6 }}>
            {DURUM[durum] ?? '—'}
          </span>
        </h6>

        <table className="detay-tablo">
          <thead><tr>
            <th style={{ width: 34 }} />
            <th>USS Alanı</th><th>Değer</th><th>Kaynak</th><th>SKRS Listesi</th>
          </tr></thead>
          <tbody>
            {alanlar.map((a, i) => {
              const gecerli = sayi(a.gecerli) === 1;
              return (
                <tr key={i} className={gecerli ? undefined : 'eksik'}>
                  <td className="orta">{gecerli ? '✔' : '⚠'}</td>
                  <td><b>{metin(a.ussAlan)}</b>
                    {!gecerli && metin(a.sorun) && (
                      <div className="sonuk">{metin(a.sorun)}</div>
                    )}
                  </td>
                  <td>{metin(a.deger) || <span className="sonuk">(boş)</span>}</td>
                  <td className="sonuk">{metin(a.kaynakAlan) || '—'}</td>
                  <td className="sonuk">{metin(a.skrsListe) || '—'}</td>
                </tr>
              );
            })}
            {alanlar.length === 0 && (
              <tr><td colSpan={5} className="bos">Paket alanı yok.</td></tr>
            )}
          </tbody>
        </table>

        {eksikSayisi > 0 && (
          <div className="not">
            {eksikSayisi} alan eksik. Düzeltme KAYNAKTA yapılır (hasta kartı,
            başvuru, muayene); sonra araç çubuğundan <b>Yeniden Üret</b>.
          </div>
        )}
      </div>

      <div className="kagrup">
        <h6>Gönderim denemeleri
          <span className="sonuk"> · {sayi(paket.deneme)} deneme</span>
        </h6>

        <table className="detay-tablo">
          <thead><tr>
            <th>Zaman</th><th className="orta">Sonuç</th><th>USS Yanıtı</th>
            <th className="sag">Süre</th>
          </tr></thead>
          <tbody>
            {denemeler.map((d, i) => (
              <tr key={i}>
                <td>{tarihSaat(d.zaman)}</td>
                <td className="orta">
                  <span className={sayi(d.sonuc) === 1 ? 'rozet olumlu' : 'rozet hata'}>
                    {sayi(d.sonuc) === 1 ? 'Başarılı' : `Hata ${sayi(d.httpKod) || ''}`}
                  </span>
                </td>
                <td>{metin(d.ussKod) && <b>{metin(d.ussKod)} </b>}{metin(d.ussMesaj) || '—'}</td>
                <td className="sag">{sayi(d.sureMs)} ms</td>
              </tr>
            ))}
            {denemeler.length === 0 && (
              <tr><td colSpan={4} className="bos">Henüz gönderim denemesi yok.</td></tr>
            )}
          </tbody>
        </table>

        {/* Hata sınıfı ayrımı gerçek: servis hatası kendiliğinden tekrarlanır,
            veri hatası tekrarlanmaz - aynı veriyi beş kez göndermek aynı
            cevabı beş kez almaktır. */}
        {durum === 4 && (
          <div className="not">
            <b>{metin(paket.hataKodu) || 'Hata'}</b> — {metin(paket.hataMesaj) || '—'}
            {sayi(paket.hataSinifi) > 0 && (
              <> · {HATA_SINIFI[sayi(paket.hataSinifi)]}</>
            )}
          </div>
        )}
        <div className="not sonuk">
          Olay {tarihSaat(paket.olayTarihi)} · üretim {tarihSaat(paket.uretimTarihi)}
          {paket.sonTarih ? <> · süre sınırı {tarihSaat(paket.sonTarih)}</> : null}
          {metin(paket.ussPaketId) ? <> · USS paket id {metin(paket.ussPaketId)}</> : null}
        </div>
      </div>
    </div>
  );
}
