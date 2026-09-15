import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { YatisOzeti } from '../../api/uclar/yatan';
import { tarihYaz } from '../bicim';

/**
 * AÇIK İŞLER + RİSK DEĞERLENDİRMELERİ — yatış kartının Genel sekmesi
 * (mockup `Ekranlar/Yatan/yatis_karti.html` sağ sütun).
 *
 * <b>Taburcu ekranı bu listeyi yeniden sormaz, aynı listeyi gösterir:</b>
 * çıkışta "bir şey kalmış mıydı" sorusunun cevabı, hasta yatarken de aynı
 * yerde durmalı. İki ayrı yerde iki ayrı "açık iş" tanımı olsaydı, taburcu
 * ekranında görünmeyen bir eksik hastayla birlikte çıkardı.
 *
 * <b>Risk ölçekleri dönemseldir</b> (yatışta + her 24 saatte + durum
 * değişiminde): son değerin YAŞI gösterilir ve süresi geçen sararır. Tek
 * seferlik alan olsaydı, üçüncü günü düşen hastanın puanı hâlâ yatış
 * günündeki puan olurdu.
 */

const OLCEK: Record<number, string> = {
  1: 'Düşme riski (İtaki)', 2: 'Bası yarası (Braden)',
  3: 'Beslenme (NRS-2002)', 4: 'Bilinç (GKS)',
};
const DUZEY: Record<number, string> = { 1: 'düşük', 2: 'orta', 3: 'yüksek' };

/** Değerlendirme kaç saat sonra "eski" sayılır. */
const TAZELIK_SAAT = 24;

export function YatisAcikIsler({ yatisId }: { yatisId: number }) {
  const [veri, setVeri] = useState<YatisOzeti | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.yatisOzeti(yatisId)) } catch { /* sessiz */ }
  }, [yatisId]);

  useEffect(() => { void yukle() }, [yukle]);
  if (!veri) return null;

  const o = veri.ozet;
  const isler: { ad: string; sayi: number; agir?: boolean; not: string }[] = [
    { ad: 'Geciken ilaç dozu', sayi: o.gecikenDoz, agir: true,
      not: 'saati 30 dakikayı geçmiş' },
    { ad: 'İmzasız sözel order', sayi: o.imzasizOrder, agir: true,
      not: 'hekim imzası bekliyor' },
    { ad: 'Bekleyen tetkik / görüntüleme', sayi: o.bekleyenTetkik,
      not: 'sonuç gelmeden taburcu, sonucu sahipsiz bırakır' },
    { ad: 'Yanıtlanmamış konsültasyon', sayi: o.bekleyenKonsultasyon,
      not: 'hekim onayıyla geçilebilir' },
  ];
  const acik = isler.filter(i => i.sayi > 0);

  return (
    <div className="altpanel-iki yatis-acik" style={{ marginTop: 10 }}>
      <div className="kagrup">
        <h6>Açık işler <span>taburcu bunları bekler</span></h6>
        <div className="ic">
          {acik.length === 0 && (
            <div className="sat"><span>Açık iş yok</span>
              <b><span className="rozet ok">taburcuya hazır</span></b></div>
          )}
          {isler.map(i => i.sayi > 0 && (
            <div className="sat" key={i.ad}>
              <span>{i.ad}</span>
              <b>
                <span className={`rozet ${i.agir ? 'hata' : 'sari'}`}>{i.sayi}</span>
                <span className="sonuk"> {i.not}</span>
              </b>
            </div>
          ))}
        </div>
        <div className="not">
          Sayılar yatışın kendi kayıtlarından gelir; taburcu ekranı da aynı
          listeyi okur — <b>iki yerde iki ayrı "açık iş" tanımı</b> olsaydı,
          taburcuda görünmeyen bir eksik hastayla birlikte çıkardı.
        </div>
      </div>

      <div className="kagrup">
        <h6>Risk değerlendirmeleri <span>24 saatte bir yenilenir</span></h6>
        <div className="ic">
          {veri.riskler.length === 0 && (
            <div className="sat"><span>Değerlendirme yok</span>
              <b><span className="rozet sari">yatışta doldurulmalı</span></b></div>
          )}
          {veri.riskler.map(r => {
            const saat = (Date.now() - new Date(r.zaman).getTime()) / 36e5;
            const eski = saat > TAZELIK_SAAT;
            return (
              <div className="sat" key={r.olcek}>
                <span>{OLCEK[r.olcek] ?? '—'}</span>
                <b>
                  {r.puan ?? '—'}
                  {r.duzey != null && (
                    <span className={`rozet ${r.duzey === 3 ? 'hata'
                                              : r.duzey === 2 ? 'sari' : 'ok'}`}>
                      {DUZEY[r.duzey]}
                    </span>
                  )}
                  {/* SÜRESİ GEÇEN DEĞERLENDİRME SARARIR: puan tazeliğiyle
                      birlikte okunur. */}
                  <span className={eski ? 'rozet sari' : 'sonuk'}>
                    {eski ? `${Math.floor(saat / 24)} gün önce` : tarihYaz(r.zaman)}
                  </span>
                </b>
              </div>
            );
          })}
        </div>
        <div className="not">
          Puan tek başına kayıt değildir; <b>alınan önlem de satırda durur</b>
          (Risk Ölçekleri sekmesi). "Yüksek risk" yazıp önlem yazmamak,
          denetimde de klinikte de boş bir kayıttır.
        </div>
      </div>
    </div>
  );
}
