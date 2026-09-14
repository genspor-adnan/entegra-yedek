import type { IskontoTalebi } from '../../api/sozlesme';
import { para, tarihSaat } from '../../bilesenler/bicim';
import { ACIL_DAKIKA, DURUM_ROZET, dakikaFarki, indirim, sure, verilenIndirim } from './ortak';

/**
 * TALEP TABLOSU - hem BEKLEYEN kuyruk hem SONUÇLANANLAR için.
 *
 * İki liste aynı sütunları okur; ayrı iki tablo yazmak, bir kolonu birinde
 * düzeltip ötekinde unutmak demekti. Fark iki başlıkta ve son sütunda:
 * kuyrukta "Durum", geçmişte "Karar" (kim, hangi notla).
 */
export function KuyrukTablosu({ liste, gecmisMi, seciliId, yukleniyor,
                                kararVerilir, onSec }: {
  liste: IskontoTalebi[];
  /** Sonuçlananlar tablosu mu - başlıklar ve son sütun buna göre. */
  gecmisMi: boolean;
  seciliId?: number | null;
  yukleniyor: boolean;
  /** Bu talebe karar verilebilir mi (bekleyen + tavan yeter). */
  kararVerilir(t: IskontoTalebi): boolean;
  onSec(t: IskontoTalebi): void;
}) {
  return (
    <table className="detay-tablo isk-kuyruk">
      <thead>
        <tr>
          <th style={{ width: 96 }}>{gecmisMi ? 'Süre' : 'Bekleme'}</th>
          <th style={{ width: 118 }}>Saat</th>
          <th style={{ width: 160 }}>Hasta</th>
          <th style={{ width: 104 }}>Protokol</th>
          <th>Talep edilen indirim</th>
          <th style={{ width: 150 }}>Gerekçe</th>
          <th className="hiza-sag" style={{ width: 100 }}>Tutar</th>
          <th className="hiza-sag" style={{ width: 96 }}>İndirim</th>
          <th style={{ width: 140 }}>İsteyen</th>
          <th style={{ width: 150 }}>{gecmisMi ? 'Karar' : 'Durum'}</th>
          <th style={{ width: 86 }} />
        </tr>
      </thead>
      <tbody>
        {liste.map(t => {
          const bekleme = dakikaFarki(t.istekTs, t.durum === 0 ? null : t.onayTs);
          // ACIL: hasta veznede bekliyor - satir kirmizi, en ustte.
          const acil = t.durum === 0 && bekleme >= ACIL_DAKIKA;
          const rz = DURUM_ROZET[t.durum] ?? DURUM_ROZET[0];
          return (
            <tr key={t.id}
                className={acil ? 'acil' : (seciliId === t.id ? 'secili' : undefined)}
                onDoubleClick={() => onSec(t)}>
              <td>
                {acil ? <span className="rozet hata">{sure(bekleme)} ⏳</span>
                      : <span className="sonuk">{sure(bekleme)}</span>}
              </td>
              <td className="sonuk">{tarihSaat(t.istekTs)}</td>
              <td>{t.hasta || '—'}</td>
              <td className="sonuk">{t.belgeNo}</td>
              <td>
                {t.satirSayisi} kalem · <b>%{t.oran}</b>
                {t.durum === 1 && t.onaylananOran < t.oran && (
                  <span className="rozet uyari" style={{ marginLeft: 6 }}>
                    %{t.onaylananOran} verildi
                  </span>
                )}
                {t.kalemler.length > 0 && (
                  <div className="sonuk">{t.kalemler.map(k => k.ad).join(', ')}</div>
                )}
              </td>
              <td className="sonuk">{t.gerekce}</td>
              <td className="hiza-sag">{para.format(t.tutar)}</td>
              <td className="hiza-sag">
                <b>{para.format(t.durum === 1 ? verilenIndirim(t) : indirim(t))}</b>
              </td>
              <td>{t.isteyen}</td>
              <td>
                {gecmisMi ? (
                  <>
                    <span className={`rozet ${rz.sinif}`}>
                      {t.durum === 1 && t.onaylananOran < t.oran ? 'Kısmi onay' : rz.ad}
                    </span>
                    <div className="sonuk">{t.onaylayan || '—'}</div>
                    {t.kararNotu && <div className="sonuk">“{t.kararNotu}”</div>}
                  </>
                ) : (
                  <span className={`rozet ${acil ? 'hata' : rz.sinif}`}>
                    {acil ? 'Hasta bekliyor' : rz.ad}
                  </span>
                )}
              </td>
              <td>
                <button type="button" className={kararVerilir(t) ? 'd bir' : 'd'}
                        onClick={() => onSec(t)}>
                  {kararVerilir(t) ? 'Karar' : 'İncele'}
                </button>
              </td>
            </tr>
          );
        })}
        {liste.length === 0 && !yukleniyor && (
          <tr><td colSpan={11} className="bos">
            {gecmisMi ? 'Bu aralıkta sonuçlanmış talep yok.'
                      : 'Bekleyen iskonto talebi yok.'}
          </td></tr>
        )}
      </tbody>
    </table>
  );
}
