import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { c } from '../../dil/ceviri';
import { RadyolojiRaporBelgesi, type RaporCiktiVerisi } from '../RadyolojiRaporCikti';

/**
 * RADYOLOJİ RAPOR LİSTESİ ÇEVRESİ (1215, mockup Ekranlar/Radyoloji/radyoloji_rapor_listesi.html):
 *
 *  · üst şerit - sayaçlar (kutu listeyi o çiple açar; `.kul-ozet` deseni),
 *  · yan panel - seçili raporun A4 belgesi küçültülmüş (açmadan okunur; tablo + gömülü resim dahil),
 *  · araç çubuğu - icmallerdeki ÇIKTI MENÜSÜ (Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸):
 *    işaretli raporlar, işaret yoksa seçili rapor. Belge rapor ekranının yazdırdığı belgenin aynısı.
 */

/** Çip sırası `listeTanimlari.Radyoloji.ts` (radyoloji-rapor) ile aynı. */
const CIP = { onRapor: 1, onayli: 2, ekRapor: 4, eskiHbys: 6 } as const;
/** Tek çıktıda en çok bu kadar rapor (her biri ayrı istek + A4 sayfası). */
const COKLU_AZAMI = 50;

const raporIdsi = (s: ListeSatiri | null | undefined) => Number(s?.raporId ?? 0) || 0;

export function RaporListeSeridi({ yenile, onCip }: { yenile: number; onCip(i: number): void }) {
  const [o, setO] = useState<Awaited<ReturnType<typeof api.radyolojiRaporOzet>> | null>(null);
  // Şerit zorunlu değil: hatası liste akışını kesmemeli.
  useEffect(() => { api.radyolojiRaporOzet().then(setO).catch(() => setO(null)) }, [yenile]);
  if (!o) return null;
  const kutular: { anahtar: string; etiket: string; deger: number; alt: string; vurgu?: 'uyari'; cip?: number }[] = [
    { anahtar: 'bugun', etiket: 'Bugün onaylanan', deger: o.bugunOnay, alt: 'rapor' },
    { anahtar: 'on', etiket: 'Ön raporda bekleyen', deger: o.onRapor, alt: 'uzman onayı bekliyor',
      vurgu: o.onRapor > 0 ? 'uyari' : undefined, cip: CIP.onRapor },
    { anahtar: 'ek', etiket: 'Ek / düzeltme raporu', deger: o.ekRapor, alt: 'son 7 gün', cip: CIP.ekRapor },
    { anahtar: 'teslim', etiket: 'Onaylı, teslim edilmemiş', deger: o.teslimBekleyen, alt: 'rapor', cip: CIP.onayli },
    { anahtar: 'eski', etiket: "Eski HBYS'den aktarılan", deger: o.eskiHbys, alt: 'rapor', cip: CIP.eskiHbys },
  ];
  return (
    <div className="kul-ozet" style={{ gridTemplateColumns: `repeat(${kutular.length}, 1fr)` }}>
      {kutular.map(k => k.cip === undefined ? (
        <div className="k bilgi" key={k.anahtar}>
          <span className="bas">{c(k.etiket)}</span>
          <span className="deg">{k.deger.toLocaleString('tr')}</span>
          <span className="alt">{c(k.alt)}</span>
        </div>
      ) : (
        <button type="button" className="k" key={k.anahtar} title={c('Listeyi bu süzgeçle aç')} onClick={() => onCip(k.cip!)}>
          <span className="bas">{c(k.etiket)}</span>
          <span className={`deg${k.vurgu ? ` ${k.vurgu}` : ''}`}>{k.deger.toLocaleString('tr')}</span>
          <span className="alt">{c(k.alt)}</span>
        </button>
      ))}
    </div>
  );
}

export function RaporOnizlemePaneli({ satir, yenile, onAc }: {
  satir: ListeSatiri | null; yenile: number; onAc(istemId: number): void;
}) {
  const raporId = raporIdsi(satir);
  const [veri, setVeri] = useState<RaporCiktiVerisi | null>(null);
  const [hata, setHata] = useState(false);
  useEffect(() => {
    setVeri(null); setHata(false);
    if (!raporId) return;
    let iptal = false;
    api.radyolojiRaporCikti(raporId)
      .then(v => { if (!iptal) setVeri(v as RaporCiktiVerisi) })
      .catch(() => { if (!iptal) setHata(true) });
    return () => { iptal = true };
  }, [raporId, yenile]);
  if (!raporId) return <div className="rr-oniz sonuk">{c('Önizleme için bir rapor seçin.')}</div>;
  if (hata) return <div className="rr-oniz sonuk">{c('Rapor okunamadı.')}</div>;
  if (!veri) return <div className="rr-oniz sonuk">{c('yükleniyor')}…</div>;
  return (
    <div className="rr-oniz">
      <div className="rr-oniz-arac">
        <b>{String(satir?.tetkikAdi ?? '')}</b>
        <span className="rozet">{String(satir?.durumAdi ?? '')}</span>
        {Number(satir?.ekRapor ?? 0) > 0 && <span className="rozet">+{String(satir?.ekRapor)} {c('ek rapor')}</span>}
        <span className="sp" />
        <button type="button" className="d" onClick={() => onAc(Number(satir?.id))}>📄 {c('Aç')}</button>
      </div>
      <div className="rr-kagit"><RadyolojiRaporBelgesi veri={veri} /></div>
    </div>
  );
}

/** Araç çubuğundaki ÇIKTI MENÜSÜ: işaretli raporlar, yoksa seçili rapor. */
export function RaporListeCiktisi({ secili, isaretli }: { secili: ListeSatiri | null; isaretli: ListeSatiri[] }) {
  const kume = (isaretli.length > 0 ? isaretli : secili ? [secili] : []).filter(s => raporIdsi(s) > 0);
  const anahtar = kume.slice(0, COKLU_AZAMI).map(raporIdsi).join(',');
  const [belgeler, setBelgeler] = useState<RaporCiktiVerisi[] | null>(null);
  useEffect(() => {
    setBelgeler(null);
    if (!anahtar) return;
    let iptal = false;
    Promise.all(anahtar.split(',').map(id => api.radyolojiRaporCikti(Number(id)) as Promise<RaporCiktiVerisi>))
      .then(v => { if (!iptal) setBelgeler(v) })
      .catch(() => { if (!iptal) setBelgeler(null) });
    return () => { iptal = true };
  }, [anahtar]);
  const tek = belgeler?.length === 1 ? belgeler[0].rapor : null;
  const dosyaAdi = tek
    ? `Radyoloji Raporu ${String(tek.hastaAdi ?? '')} ${String(tek.raporNo ?? '')}`.trim()
    : `Radyoloji Raporları (${belgeler?.length ?? 0})`;
  // rr-cikti: liste başlığı yazdırmada gizli - bu menüyü taşıyan başlık belge için açılır (tema.css).
  return (
    <span className="rr-cikti">
      {kume.length > COKLU_AZAMI && (
        <span className="sonuk" title={c('Tek çıktıda en çok 50 rapor')}>{c('ilk')} {COKLU_AZAMI}</span>
      )}
      <CiktiMenusu etiket={kume.length > 1 ? `${c('Yazdır')} (${Math.min(kume.length, COKLU_AZAMI)})` : c('Yazdır')}
                   dugmeSinifi="d" sagda devre={!belgeler || belgeler.length === 0} dosyaAdi={dosyaAdi}>
        {belgeler && (
          <div className="rr-coklu">
            {belgeler.map(v => <RadyolojiRaporBelgesi key={String(v.rapor.id)} veri={v} />)}
          </div>
        )}
      </CiktiMenusu>
    </span>
  );
}
