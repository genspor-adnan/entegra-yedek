import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { ArizaTakip } from '../../api/uclar/ariza';
import type { DokumanSatiri } from '../../api/sozlesme';
import { tarihSaat } from '../bicim';
import { guvenli, metinSor, onay } from '../mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { talepleriYenile } from './useTaleplerimOzeti';

/**
 * ARIZA TAKİP PANELİ (954) - Taleplerim'in sağ paneli. Aynı panel iki kişiye:
 *  • BİLDİREN (rol 1) / takipçi (2): not, fotoğraf, vazgeç; çözülünce
 *    "Evet, kapat" / "Düzelmedi, yeniden aç".
 *  • EKİP (rol 3, yetki ariza): devral, çözüldü (not zorunlu), kapat.
 * Durum geçişleri sunucuda; panel yalnız uca bağlar.
 */
const HAREKET: Record<number, string> = {
  1: 'Bildirildi', 2: 'Ekibe iletildi', 3: 'Atandı', 4: 'İşleme alındı', 5: 'Çözüldü', 6: 'Kapandı',
  7: 'Yeniden açıldı', 8: 'İptal edildi', 9: 'Not', 10: 'Ben de bildiriyorum', 11: 'Kendiliğinden kapandı',
};

export function ArizaTakipPaneli({ id, onKapat }: { id: number; onKapat(): void }) {
  const { yetki } = useOturum();
  const [t, setT] = useState<ArizaTakip | null>(null);
  const [dosyalar, setDosyalar] = useState<DokumanSatiri[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const dosyaRef = useRef<HTMLInputElement>(null);

  const yukle = useCallback(async () => {
    try {
      setT(await api.arizaTakip(id)); setHata(null);
      setDosyalar(await api.dokumanlar('ariza', id).catch(() => []));
    } catch (e) { setHata(hataMetni(e)) }
  }, [id]);
  useEffect(() => { setT(null); void yukle() }, [yukle]);

  const yap = (is: () => Promise<unknown>) => guvenli(async () => { await is(); talepleriYenile(); await yukle() });

  if (hata) return <div className="tl-detay"><div className="tl-grp"><div className="tl-ic sonuk">{hata}</div></div></div>;
  if (!t) return <div className="tl-detay"><div className="tl-grp"><div className="tl-ic sonuk">{c('yükleniyor')}…</div></div></div>;

  const d = t.talep;
  const bildiren = t.rol === 1;
  const ekip = yetki('ariza', 'degistir');
  const acik = d.durum === 1 || d.durum === 2 || d.durum === 3;

  return (
    <div className="tl-detay">
      <div className="tl-grp">
        <h6>🧰 {d.talepNo} · {d.kategoriAdi}
          <span className={`tl-chip ${d.durum === 4 ? 'tl-c-ok' : d.durum === 5 ? 'tl-c-gri' : d.durum === 0 ? 'tl-c-gri' : 'tl-c-mavi'}`} style={{ marginLeft: 'auto' }}>{d.durumAdi}</span>
          <button type="button" className="cl-bag sonuk" title={c('Kapat')} onClick={onKapat}>✕</button></h6>
        <div className="tl-ic">
          <div className="tl-sat"><span>{c('Ne oluyor')}</span><span>{d.aciklama}</span></div>
          <div className="tl-sat"><span>{c('Ekip')}</span><span>{d.ekipAdi} · {c('öncelik')} {d.oncelik === 4 ? <b className="tl-gec">🚨 {d.oncelikAdi}</b> : d.oncelikAdi}</span></div>
          <div className="tl-sat"><span>{c('Konum')}</span><span>{d.konum || '—'}</span></div>
          {d.demirbasId && <div className="tl-sat"><span>{c('Cihaz')}</span><span>{d.demirbasKod} · {d.demirbasAdi}</span></div>}
          <div className="tl-sat"><span>{c('Bildiren')}</span><span>{d.talepEdenAdi}{d.telefon ? ` · ☎ ${d.telefon}` : ''}</span></div>
          <div className="tl-sat"><span>{c('Sorumlu')}</span><span>{d.sorumluAdi ? <b>{d.sorumluAdi}</b> : <span className="sonuk">{c('henüz atanmadı')}</span>}</span></div>
          {t.takipciler.length > 0 && <div className="tl-sat"><span>{c('Takipçi')}</span><span>{t.takipciler.join(', ')}</span></div>}

          {/* ÇÖZÜLDÜ → BİLDİRENİN ONAYI */}
          {bildiren && d.durum === 4 && (
            <div className="tl-cozuldu">✔ {c('Ekip çözüldü dedi')}{d.cozumNotu ? <>: “{d.cozumNotu}”</> : ''}
              <div className="tl-eylem">
                <button type="button" className="d bir" onClick={() => void yap(() => api.arizaOnayla(d.id))}>✔ {c('Evet, kapat')}</button>
                <button type="button" className="d tl-tehlike" onClick={async () => {
                  const n = await metinSor(c('Ne düzelmedi?'), '', c('Açıklama'));
                  if (n) await yap(() => api.arizaYenidenAc(d.id, n));
                }}>↩ {c('Düzelmedi, yeniden aç')}</button>
              </div>
              <span className="sonuk tl-kucuk">{c('3 gün yanıt verilmezse kendiliğinden kapanır.')}</span>
            </div>
          )}

          <div className="tl-eylem">
            {/* EKİP İŞLEMLERİ */}
            {ekip && acik && d.durum !== 3 && (
              <button type="button" className="d bir" onClick={() => void yap(() => api.arizaDevral(d.id))}>✋ {c('Devral')}</button>
            )}
            {ekip && acik && (
              <button type="button" className="d tl-ok" onClick={async () => {
                const n = await metinSor(c('Ne yapıldı? (bildirene gider)'), '', c('Çözüm notu'));
                if (n) await yap(() => api.arizaCoz(d.id, n));
              }}>✔ {c('Çözüldü')}</button>
            )}
            {ekip && !bildiren && d.durum === 4 && (
              <button type="button" className="d" onClick={() => void yap(() => api.arizaKapat(d.id))}>■ {c('Kapat')}</button>
            )}
            {d.durum !== 0 && d.durum !== 5 && (
              <button type="button" className="d" onClick={async () => {
                const n = await metinSor(c('Not'), '', c('Not'));
                if (n) await yap(() => api.arizaNot(d.id, n));
              }} title={c('Not ekle')}>💬 {c('Not')}</button>
            )}
            {d.durum !== 0 && d.durum !== 5 && (
              <button type="button" className="d" title={c('Fotoğraf ekle')} onClick={() => dosyaRef.current?.click()}>📷</button>
            )}
            {bildiren && acik && (
              <button type="button" className="d tl-tehlike" onClick={async () => {
                if (!await onay(c('Arıza bildirimi iptal edilsin mi?'), true)) return;
                await yap(() => api.arizaVazgec(d.id));
              }}>✖ {c('Vazgeç')}</button>
            )}
            <input ref={dosyaRef} type="file" accept="image/*,video/*" multiple capture="environment" hidden
                   onChange={e => {
                     const l = Array.from(e.target.files ?? []); e.target.value = '';
                     void yap(async () => { for (const f of l) await api.dokumanYukle('ariza', d.id, f, false) });
                   }} />
          </div>
          {dosyalar.length > 0 && (
            <div className="tl-ekler">{dosyalar.map(f => (
              <button key={f.id} type="button" className="tl-ek" onClick={async () => { const w = window.open('', '_blank'); const u = await api.dokumanIcerikUrl(f.id); if (w) w.location.href = u }}>📎 {f.ad}</button>
            ))}</div>
          )}
        </div>
      </div>

      <div className="tl-grp">
        <h6>{c('Akış')}<span className="tl-grp-ek">{c('en yeni altta')}</span></h6>
        <div className="tl-ic">
          <div className="tl-zc">
            {t.hareketler.map(h => (
              <div key={h.id} className={`tl-zo ${h.tur === 9 || h.tur === 10 ? 'not' : h.tur === 8 || h.tur === 7 ? 'red' : 'ok'}`}>
                <b>{c(HAREKET[h.tur] ?? '')}{h.tur === 2 || h.tur === 3 ? `: ${h.metin}` : ''}</b>
                {h.metin && h.tur !== 2 && h.tur !== 3 && <div className="tl-gerekce">“{h.metin}”</div>}
                <small>{h.yazan} · {tarihSaat(h.tarih)}</small>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
