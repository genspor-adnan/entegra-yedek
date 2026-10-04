import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { guvenli, metinSor } from '../mesaj';
import { c } from '../../dil/ceviri';
import { TUR_IKON, talepleriYenile, type TalepBildirimi } from './useTaleplerimOzeti';
import { useTaleplerim } from './TaleplerimPaneli';
import { iskontoKararAc } from './GelenIsler';
import { duyuruOkuAc } from '../duyuru/DuyuruOrtak';
import { para } from '../bicim';

/**
 * ANLIK BİLDİRİMLER (mockup Ekranlar/Taleplerim/gelen_talepler.html ③):
 * yeni iş, açık ekranın sol altına düşer - kişi bulunduğu ekrandan çıkmadan
 * Devral / Onayla / Evet-kapat der. Sağ alt Yapay Zekâ düğmesinin yeri.
 * Acil kapanmaz; diğerleri 12 sn sonra kendiliğinden kapanır (📨'de durur).
 */
const SURE_MS = 12000;

export function TalepBildirimleri() {
  const oz = useTaleplerim();
  const [sol, setSol] = useState(16);

  // İÇERİK ALANINA GÖRE: sol menünün üstüne düşmesin.
  useEffect(() => {
    const olc = () => setSol((document.querySelector('main.ana')?.getBoundingClientRect().left ?? 0) + 16);
    olc();
    window.addEventListener('resize', olc);
    const z = window.setInterval(olc, 2000);   // menü daralt/genişlet
    return () => { window.removeEventListener('resize', olc); window.clearInterval(z) };
  }, []);

  if (!oz || oz.bildirimler.length === 0) return null;
  return (
    <div className="tl-bildirimler" style={{ left: sol }}>
      {oz.bildirimler.map(b => <Bildirim key={b.anahtar} b={b} kapat={() => oz.bildirimKapat(b.anahtar)} />)}
    </div>
  );
}

function Bildirim({ b, kapat }: { b: TalepBildirimi; kapat(): void }) {
  const git = useNavigate();
  useEffect(() => {
    if (b.acil) return;
    const z = window.setTimeout(kapat, SURE_MS);
    return () => window.clearTimeout(z);
    // kapat her çizimde yeni; sayaç yalnız bildirim doğunca kurulur.
  }, [b.acil]); // eslint-disable-line react-hooks/exhaustive-deps

  const yap = (is: () => Promise<unknown>) => guvenli(async () => { await is(); kapat(); talepleriYenile() });

  if (b.ariza) {
    const a = b.ariza;
    return (
      <div className={`tl-toast${b.acil ? ' tl-toast-acil' : ''}`}>
        <div className="tl-tb">{b.acil ? '🚨' : '🔧'} {b.acil ? c('Acil arıza') : c('Yeni arıza')} — {a.ekipAdi}<span>{c('şimdi')}</span></div>
        <div><b>{a.talepNo}</b> · {a.aciklama}{a.konum ? ` · ${a.konum}` : ''}<br />{a.talepEdenAdi}{a.telefon ? ` · ☎ ${a.telefon}` : ''}</div>
        <div className="tl-tey">
          <button type="button" className="d bir" onClick={() => void yap(() => api.arizaDevral(a.id))}>✋ {c('Devral')}</button>
          <button type="button" className="d" onClick={() => { kapat(); git(`/taleplerim?sekme=gelen&sec=ariza-${a.id}`) }}>{c('Gör')}</button>
          <button type="button" className="d tl-sag-btn" onClick={kapat}>{c('Sonra')}</button>
        </div>
      </div>
    );
  }

  if (b.duyuru) {
    const d = b.duyuru;
    return (
      <div className={`tl-toast${b.acil ? ' tl-toast-acil' : ''}`}>
        <div className="tl-tb">{d.onem === 3 ? '🚨' : '📣'} {d.guncelleme ? c('Duyuru güncellendi') : c('Yeni duyuru')}<span>{d.adina}</span></div>
        <div><b>{d.baslik}</b>{d.ozet ? <><br />{d.ozet.slice(0, 120)}</> : null}</div>
        <div className="tl-tey">
          <button type="button" className="d bir" onClick={() => { kapat(); duyuruOkuAc(d.id) }}>{c('Aç')}</button>
          <button type="button" className="d tl-sag-btn" onClick={kapat}>{c('Sonra')}</button>
        </div>
      </div>
    );
  }

  if (b.iskonto) {
    const t = b.iskonto;
    return (
      <div className="tl-toast">
        <div className="tl-tb">％ {c('İskonto onayı bekliyor')}<span>{c('şimdi')}</span></div>
        <div><b>%{t.oran}</b> · {para.format(t.tutar)} · {t.hasta || t.belgeNo}<br />{c('isteyen')}: {t.isteyen}</div>
        <div className="tl-tey">
          <button type="button" className="d bir" onClick={() => { kapat(); iskontoKararAc(t) }}>{c('İncele ve karar ver')}</button>
          <button type="button" className="d tl-sag-btn" onClick={kapat}>{c('Sonra')}</button>
        </div>
      </div>
    );
  }

  if (b.onay) {
    const o = b.onay;
    return (
      <div className="tl-toast">
        <div className="tl-tb">⏳ {c('Onayınızı bekliyor')} — {o.akisAd}<span>{c('şimdi')}</span></div>
        <div><b>{o.konu}</b>{o.kayitNo ? ` · ${o.kayitNo}` : ''}<br />{o.talepEden} · {o.adimAd}</div>
        <div className="tl-tey">
          <button type="button" className="d tl-ok" onClick={() => void yap(() => api.onayKarar(o.kaynakTur, o.kaynakId, { karar: 'onayla' }))}>✔ {c('Onayla')}</button>
          <button type="button" className="d tl-tehlike" onClick={async () => {
            const g = await metinSor(c('Red gerekçesi'), '', c('Gerekçe'));
            if (g) await yap(() => api.onayKarar(o.kaynakTur, o.kaynakId, { karar: 'reddet', gerekce: g }));
          }}>✕ {c('Reddet')}</button>
          <button type="button" className="d tl-sag-btn" onClick={() => { kapat(); git('/taleplerim?sekme=gelen') }}>{c('Gör')}</button>
        </div>
      </div>
    );
  }

  const s = b.satir!;
  const cozuldu = s.tur === 'ariza' && s.durum === 4;
  return (
    <div className={`tl-toast${s.grup === 'red' ? ' tl-toast-kirmizi' : ' tl-toast-yesil'}`}>
      <div className="tl-tb">{TUR_IKON[s.tur]} {cozuldu ? c('Arızanız çözüldü — onaylıyor musunuz?') : `${s.baslik}: ${s.durumAdi}`}<span>{c('şimdi')}</span></div>
      <div><b>{s.no || `#${s.id}`}</b> · {s.detay}{s.redNeden ? <><br />“{s.redNeden}”</> : ''}</div>
      <div className="tl-tey">
        {cozuldu && <>
          <button type="button" className="d tl-ok" onClick={() => void yap(() => api.arizaOnayla(s.id))}>✔ {c('Evet, kapat')}</button>
          <button type="button" className="d tl-tehlike" onClick={async () => {
            const n = await metinSor(c('Ne düzelmedi?'), '', c('Açıklama'));
            if (n) await yap(() => api.arizaYenidenAc(s.id, n));
          }}>↩ {c('Düzelmedi')}</button>
        </>}
        <button type="button" className="d tl-sag-btn" onClick={() => { kapat(); git(`/taleplerim?sec=${s.tur}-${s.id}`) }}>{c('Gör')}</button>
      </div>
    </div>
  );
}
