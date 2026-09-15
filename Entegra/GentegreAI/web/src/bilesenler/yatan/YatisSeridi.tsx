import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { YatisOzeti } from '../../api/uclar/yatan';
import { tarihSaat, tarihYaz } from '../bicim';

/**
 * YATIŞ KARTI ÜST ŞERİDİ — mockup `Ekranlar/Yatan/yatis_karti.html`
 * (`.serit-kimlik` + `.vital-serit`).
 *
 * <b>Sekmelerin DIŞINDA durur.</b> Yatan hastada "kim, nerede, kaçıncı gün,
 * nasıl" her kararın önkoşuludur; sekmeye gömülürse hekim her seferinde
 * tıklar. Radyoloji istem kartındaki akış şeridiyle aynı yer: kimlik
 * şeridinin altında, sekmelerin üstünde.
 *
 * Son vitaller ŞERİTTE çünkü kart açıldığı anda sorulan ikinci soru "hasta
 * nasıl"dır. Eşiği aşan değer renklenir: ateş ≥ 38, SpO₂ < 94, erken uyarı
 * ≥ 5 — hekimin sayıya bakıp kendi eşiğini hatırlamasını beklemek, yoğun bir
 * günde kaçırmak demektir.
 */

const IZOLASYON: Record<number, string> = {
  1: 'temaslı izolasyon', 2: 'damlacık izolasyon',
  3: 'solunum izolasyonu', 4: 'koruyucu izolasyon',
};
const DURUM: Record<number, string> = {
  0: 'İptal', 1: 'Yatış kabul', 2: 'Yatakta',
  3: 'Taburcu planlandı', 4: 'Taburcu', 5: 'Kurum dışına sevk',
};

export function YatisSeridi({ yatisId }: { yatisId: number }) {
  const [veri, setVeri] = useState<YatisOzeti | null>(null);

  const yukle = useCallback(async () => {
    // Şerit zorunlu değil: hatası kartı açılmaz yapmamalı.
    try { setVeri(await api.yatisOzeti(yatisId)) } catch { /* sessiz */ }
  }, [yatisId]);

  useEffect(() => { void yukle() }, [yukle]);
  if (!veri) return null;

  const o = veri.ozet;
  const acikIs = o.gecikenDoz + o.imzasizOrder + o.bekleyenTetkik + o.bekleyenKonsultasyon;
  const aldi = Number(veri.sivi?.aldi ?? 0);
  const cikardi = Number(veri.sivi?.cikardi ?? 0);
  // SIVI KAYDI YOKSA DENGE DE YOK: "0 mL" yazmak "girdi çıktı eşit" demektir
  //   ve takip edilmeyen hastayı dengedeymiş gibi gösterir.
  const sivikayitVar = aldi > 0 || cikardi > 0;
  const denge = aldi - cikardi;

  return (
    <>
      <div className="yatis-kimlik">
        <div className="ad">{o.hasta}</div>
        <div className="kv"><span>Yaş / cinsiyet</span>
          <b>{o.yas != null ? o.yas : '—'}
             {o.cinsiyet === 1 ? ' / Erkek' : o.cinsiyet === 2 ? ' / Kadın' : ''}</b></div>
        <div className="kv"><span>Yatak</span>
          <b className="yatak-kod">{o.yatak || '—'}</b></div>
        <div className="kv"><span>Yatış</span>
          <b>{tarihSaat(o.girisTarihi)}</b></div>
        {/* GÜN SAYISI: uzayan yatış hem klinik hem mali bir sinyal
            (provizyon dönemi, enfeksiyon riski, yatak devri). */}
        <div className="kv"><span>Gün</span><b>{o.gun}</b></div>
        <div className="kv"><span>Klinik / hekim</span>
          <b>{[o.klinik, o.hekim].filter(Boolean).join(' · ') || '—'}</b></div>
        <div className="kv"><span>Ödeyen</span>
          <b>{o.odeyen || '—'}
             {o.odeyen && (o.provizyonNo
               ? <span className="sonuk"> · provizyon alındı</span>
               : <span className="rozet sari"> provizyon yok</span>)}</b></div>

        <div className="sag">
          <span className={`rozet ${o.durum === 3 ? 'sari' : o.durum >= 4 ? 'pas' : 'ok'}`}>
            {DURUM[o.durum] ?? ''}
          </span>
          {o.izolasyon > 0 && <span className="rozet hata">🦠 {IZOLASYON[o.izolasyon]}</span>}
          {o.refakatci && <span className="rozet mavi">👥 refakatçi</span>}
          {o.tahminiCikis && (
            <span className="rozet">📅 tahmini çıkış {tarihYaz(o.tahminiCikis)}</span>
          )}
        </div>
      </div>

      {/* SON VİTALLER: kart açılır açılmaz "hasta nasıl". */}
      <div className="vital-serit">
        <Kutu ad="TA" deger={o.sistolik != null ? `${o.sistolik}/${o.diyastolik ?? '—'}` : '—'} />
        <Kutu ad="Nabız" deger={o.nabiz} />
        <Kutu ad="Ateş" deger={o.ates != null ? Number(o.ates).toFixed(1) : null}
              vurgu={o.ates != null && Number(o.ates) >= 38 ? 'uy' : undefined} />
        <Kutu ad="SpO₂" deger={o.spo2}
              vurgu={o.spo2 != null && o.spo2 < 94 ? 'uy' : undefined} />
        <Kutu ad="Solunum" deger={o.solunum} />
        {/* Erken uyarı skoru tek tek normal görünen değerlerin birlikte
            kötüleşmesini gösterir: eşiği aşınca kırmızı. */}
        <Kutu ad="Erken uyarı" deger={o.erkenUyari}
              vurgu={o.erkenUyari != null && o.erkenUyari >= 5 ? 'teh'
                     : o.erkenUyari != null && o.erkenUyari >= 3 ? 'uy' : undefined} />
        <Kutu ad="Sıvı dengesi"
              deger={sivikayitVar ? `${denge > 0 ? '+' : ''}${Math.round(denge)}` : null}
              alt={sivikayitVar ? 'mL · bugün' : 'bugün kayıt yok'} />
        <Kutu ad="Açık iş" deger={acikIs} alt={o.vitalZaman ? tarihSaat(o.vitalZaman) : 'ölçüm yok'}
              vurgu={acikIs > 0 ? 'uy' : undefined} />
      </div>
    </>
  );
}

function Kutu({ ad, deger, alt, vurgu }: {
  ad: string; deger: string | number | null | undefined; alt?: string;
  vurgu?: 'uy' | 'teh';
}) {
  return (
    <div className={`v${vurgu ? ' ' + vurgu : ''}`}>
      <span>{ad}</span>
      <b>{deger ?? '—'}</b>
      {alt && <i>{alt}</i>}
    </div>
  );
}
