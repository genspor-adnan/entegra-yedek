import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { type IskontoTalebi } from '../api/sozlesme';
import { para, tarihSaat } from './bicim';
import { useOturum } from '../kimlik/OturumBaglami';
import { IskontoOnayModali } from './IskontoOnayModali';
import { masaustuBildir } from './bildirimTercihi';

/**
 * ZİL — onay bekleyen işler (662).
 *
 * Şimdilik tek tür var: İSKONTO ONAYI. Zil düğmesi vardı ama hiçbir şey
 * yapmıyordu; onay akışını e-posta bildirimine bağlamak yerine buraya
 * koyduk - onaylayacak kişi zaten uygulamanın içinde ve karar hastayı
 * VEZNEDE BEKLETİYOR, posta kutusuna düşen bir bağlantı geç kalırdı.
 *
 * Liste SUNUCUDAN SÜZÜLÜ gelir: tavanı yetmeyen kullanıcıya boş döner.
 * "Göremediğin şeyi onaylayamazsın" - göründüğü halde basılamayan bir
 * düğme, kullanıcıyı sunucudan ret yemeye gönderirdi.
 */
export function ZilPaneli({ c }: { c(m: string): string }) {
  const { aksiyonDegeri } = useOturum();
  const tavan = aksiyonDegeri('basvuru.iskonto');
  const [acik, setAcik] = useState(false);
  const [liste, setListe] = useState<IskontoTalebi[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  /** Acik onay penceresi (663) - karar burada verilir, belge acilmadan. */
  const [secili, setSecili] = useState<IskontoTalebi | null>(null);

  /* Daha once bildirilen talepler: ayni talep her 60 sn'de bir yeniden
     bildirilmesin. Sayfa yenilenince sifirlanir - acilista elde ZATEN bekleyen
     talep icin masaustu bildirimi cikarmiyoruz (asagida ilkGecis), cunku onlar
     "yeni bir sey oldu" demek degil. */
  const bildirilen = useRef<Set<number>>(new Set());
  const ilkGecis = useRef(true);

  const yukle = useCallback(async () => {
    if (tavan <= 0) { setListe([]); return }
    setYukleniyor(true);
    try {
      const yeni = await api.iskontoBekleyenler();
      setListe(yeni);

      // MASAUSTU BILDIRIMI (669): kullanici Ayarlar > Bildirimler'de actiysa,
      //   tarayici izni verdiyse ve sessiz saatte degilse - ucunu de
      //   masaustuBildir kontrol eder. Zil listesi her durumda dolar.
      const ilk = ilkGecis.current;
      ilkGecis.current = false;
      for (const t of yeni) {
        if (bildirilen.current.has(t.id)) continue;
        bildirilen.current.add(t.id);
        if (ilk) continue;
        masaustuBildir('iskonto', 'İskonto onayı bekliyor',
          `${t.hasta} · %${t.oran} · ${para.format(t.tutar)}`);
      }
    }
    catch { setListe([]) }
    finally { setYukleniyor(false) }
  }, [tavan]);

  /* Sayac panel KAPALIYKEN de guncel olmali - rozet zaten uyari isareti.
     60 sn: karar hastayi bekletir ama saniyede bir sormak da gereksiz. */
  useEffect(() => {
    void yukle();
    const z = window.setInterval(() => void yukle(), 60000);
    return () => window.clearInterval(z);
  }, [yukle]);

  /* Disari tiklaninca kapan - acik panel ekranda unutulmasin. */
  useEffect(() => {
    if (!acik) return;
    const kapat = () => setAcik(false);
    window.addEventListener('click', kapat);
    return () => window.removeEventListener('click', kapat);
  }, [acik]);

  return (
    <span className="zil-sar" onMouseDown={e => e.stopPropagation()}>
      <button className="ib" title={c('Bildirimler')}
              onClick={e => { e.stopPropagation(); setAcik(a => !a); void yukle() }}>
        🔔
        {liste.length > 0 && <span className="zil-rozet">{liste.length}</span>}
      </button>
      {acik && (
        <div className="zil-panel" onClick={e => e.stopPropagation()}>
          <div className="zil-baslik">
            {c('Onay Bekleyenler')}
            {yukleniyor && <span className="sonuk"> · {c('yükleniyor')}…</span>}
          </div>
          {tavan <= 0 && (
            <div className="zil-bos">
              {c('Onay yetkiniz yok.')}
            </div>
          )}
          {tavan > 0 && liste.length === 0 && !yukleniyor && (
            <div className="zil-bos">{c('Bekleyen onay yok.')}</div>
          )}
          {liste.map(t => (
            <div key={t.id} className="zil-satir">
              <div className="zil-ust">
                <b>%{t.oran}</b>
                <span className="sonuk">{t.hasta || t.belgeNo}</span>
                <span className="sp" />
                <span className="sonuk">{tarihSaat(t.istekTs)}</span>
              </div>
              <div className="zil-orta">
                {t.satirSayisi} {c('satır')} · {para.format(t.tutar)} ·{' '}
                {c('isteyen')}: {t.isteyen}
              </div>
              <div className="zil-gerekce">“{t.gerekce}”</div>
              <div className="zil-dugmeler">
                {/* Karar PENCEREDE verilir: zil satiri karar icin yetmez -
                    hangi hizmetler, hangi hasta, hangi doktor gorunmeli. */}
                <button type="button" className="d bir"
                        onClick={() => { setSecili(t); setAcik(false) }}>
                  {c('İncele ve Karar Ver')}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}
      {secili && (
        <IskontoOnayModali talep={secili} tavan={tavan}
                           onKapat={() => setSecili(null)}
                           onSonuc={() => void yukle()} />
      )}
    </span>
  );
}
