import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type DokumanSatiri } from '../../api/sozlesme';
import type { DuyuruAyrinti, DuyuruSatiri } from '../../api/uclar/duyuru';
import { Modal } from '../Modal';
import { guvenli } from '../mesaj';
import { tarihSaat } from '../bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { talepleriYenile } from '../taleplerim/useTaleplerimOzeti';
import { useTaleplerim } from '../taleplerim/taleplerimBaglami';
import { DuyuruKarti } from './DuyuruKarti';
import { ONEM, OnemEtiketi } from './duyuruOnem';

export { ONEM, OnemEtiketi };

/**
 * DUYURULAR (957, mockup Ekranlar/Duyuru/duyuru.html) - ortak parçalar:
 * önem etiketi, zil listesi, okuma penceresi, kritik tam ekran ve kabukta
 * tek duran katman (olayla açılan pencereler).
 */
const OKU = 'gentegre:duyuru-oku';
const KART = 'gentegre:duyuru-kart';
/** Duyuruyu okuma penceresinde aç (zil, anlık bildirim, yönetim listesi). */
export const duyuruOkuAc = (id: number) => window.dispatchEvent(new CustomEvent<number>(OKU, { detail: id }));
/** Yayınla penceresi - id verilirse düzenle. */
export const duyuruKartAc = (id?: number) => window.dispatchEvent(new CustomEvent<number | undefined>(KART, { detail: id }));
export const DUYURU_DEGISTI = 'gentegre:duyuru-degisti';

/** Zil › Duyurular sekmesi. */
export function DuyuruListesi({ satirlar, sonra }: { satirlar: DuyuruSatiri[]; sonra?(): void }) {
  if (satirlar.length === 0) return <ul className="tl-son"><li className="tl-bos">{c('Yayında duyuru yok.')}</li></ul>;
  const okudum = (d: DuyuruSatiri) => guvenli(async () => { await api.duyuruOkudum(d.id); talepleriYenile() });
  return (
    <ul className="dy-liste">
      {satirlar.map(d => (
        <li key={d.id} className={`${d.yeni ? 'dy-yeni' : ''}${d.onem === 3 ? ' dy-kritik' : ''}${d.sabit ? ' dy-sabit' : ''}`}
            onClick={() => { sonra?.(); duyuruOkuAc(d.id) }}>
          <span className="dy-ic">{d.sabit ? '📌' : ONEM[d.onem].ic}</span>
          <span>
            <b>{d.baslik}</b> <OnemEtiketi onem={d.onem} />{d.guncelleme && d.yeni && <span className="dy-guncel">{c('güncellendi')}</span>}
            <small>{d.adina} · {tarihSaat(d.yayinBas)} · {d.hedefOzet}{d.ekSayisi > 0 ? ` · 📎 ${d.ekSayisi}` : ''}</small>
            {d.ozet && <span className="dy-oz">{d.ozet}</span>}
          </span>
          {d.okumaOnayi && (!d.okudu || d.eskiSurumOkundu)
            ? <button type="button" className="d tl-ok" onClick={e => { e.stopPropagation(); void okudum(d) }}>✔ {c('Okudum')}</button>
            : <span className="dy-durum">{d.okudu && !d.eskiSurumOkundu ? `✓ ${c('okundu')}` : d.yeni ? '' : `✓ ${c('görüldü')}`}</span>}
        </li>
      ))}
    </ul>
  );
}

/** Duyurunun tamamı: metin, ekler, okuma onayı. Açılınca "görüldü". */
function DuyuruOkuModali({ id, onKapat }: { id: number; onKapat(): void }) {
  const [d, setD] = useState<DuyuruAyrinti | null>(null);
  const [ekler, setEkler] = useState<DokumanSatiri[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  useEffect(() => {
    api.duyuru(id).then(y => { setD(y.duyuru); if (y.duyuru.durum === 1) void api.duyuruGordu(id).then(talepleriYenile).catch(() => {}) })
      .catch(e => setHata(hataMetni(e)));
    api.dokumanlar('duyuru', id).then(setEkler).catch(() => setEkler([]));
  }, [id]);
  const onayGerek = !!d?.okumaOnayi && !d.okudu && d.durum === 1;
  const okudum = () => guvenli(async () => { await api.duyuruOkudum(id); talepleriYenile(); onKapat() });
  const alt = (
    <>
      {onayGerek && <button type="button" className="d tl-ok" onClick={() => void okudum()}>✔ {c('Okudum')}</button>}
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={onKapat}>{c('Kapat')}</button>
    </>
  );
  return (
    <Modal baslik={d ? `${ONEM[d.onem].ic} ${d.baslik}` : c('Duyuru')} ustBilgi={d ? `${d.adinaGorunen}` : undefined}
           dar buyutmeYok alt={alt} onKapat={onKapat}>
      <div className="dy-oku">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {d && <>
          <div className="dy-ust"><OnemEtiketi onem={d.onem} /> <span className="sonuk">{tarihSaat(d.gorunenBas)} · {d.hedefOzet}
            {d.guncelleme ? ` · ${c('güncellendi')} ${tarihSaat(d.guncelleme)}` : ''}</span></div>
          {/* METİN SUNUCUDA TEMİZLENDİ (DuyuruUclari.HtmlTemizle - beyaz liste). */}
          <div className="dy-metin" dangerouslySetInnerHTML={{ __html: d.metin }} />
          {ekler.length > 0 && (
            <div className="tl-ekler">{ekler.map(f => (
              <button key={f.id} type="button" className="tl-ek"
                      onClick={async () => { const w = window.open('', '_blank'); const u = await api.dokumanIcerikUrl(f.id); if (w) w.location.href = u }}>📎 {f.ad}</button>
            ))}</div>
          )}
          {d.okudu && <div className="sonuk">✓ {c('Okudunuz.')}</div>}
        </>}
      </div>
    </Modal>
  );
}

/**
 * KRİTİK DUYURU - oturum açılışında TAM EKRAN: "Okudum, anladım" denmeden
 * kapanmaz, "Sonra" yok. Birden çoksa sırayla.
 */
function KritikDuyuruEkrani() {
  const oz = useTaleplerim();
  const ilk = oz?.kritikBekleyen[0];
  const [d, setD] = useState<DuyuruAyrinti | null>(null);
  const [ekler, setEkler] = useState<DokumanSatiri[]>([]);
  useEffect(() => {
    setD(null); setEkler([]);
    if (!ilk) return;
    api.duyuru(ilk.id).then(y => setD(y.duyuru)).catch(() => setD(null));
    api.dokumanlar('duyuru', ilk.id).then(setEkler).catch(() => setEkler([]));
  }, [ilk?.id, ilk?.surum]); // eslint-disable-line react-hooks/exhaustive-deps
  if (!ilk || !d || !oz) return null;
  return (
    <div className="dy-tam">
      <div className="dy-tam-kutu">
        <div className="dy-tam-bas">🚨 {d.baslik}<span>{d.adinaGorunen} · {tarihSaat(d.gorunenBas)}</span></div>
        <div className="dy-tam-ic">
          <div className="dy-metin" dangerouslySetInnerHTML={{ __html: d.metin }} />
          {ekler.length > 0 && (
            <div className="tl-ekler">{ekler.map(f => (
              <button key={f.id} type="button" className="tl-ek"
                      onClick={async () => { const w = window.open('', '_blank'); const u = await api.dokumanIcerikUrl(f.id); if (w) w.location.href = u }}>📎 {f.ad}</button>
            ))}</div>
          )}
        </div>
        <div className="dy-tam-alt">
          <span className="sonuk">{oz.kritikBekleyen.length > 1 ? `1 / ${oz.kritikBekleyen.length} ${c('kritik duyuru')}` : c('Kritik duyuru')}</span>
          <button type="button" className="d tl-ok dy-tam-btn" onClick={() => void guvenli(async () => { await api.duyuruOkudum(ilk.id); await oz.yukle() })}>
            ✔ {c('Okudum, anladım')}</button>
        </div>
      </div>
    </div>
  );
}

/** Kabukta tek: okuma penceresi, yayınla penceresi, kritik tam ekran. */
export function DuyuruKatmani() {
  const { yetki } = useOturum();
  const [oku, setOku] = useState<number | null>(null);
  const [kart, setKart] = useState<{ id?: number } | null>(null);
  useEffect(() => {
    const o = (e: Event) => setOku((e as CustomEvent<number>).detail);
    const k = (e: Event) => setKart({ id: (e as CustomEvent<number | undefined>).detail });
    window.addEventListener(OKU, o); window.addEventListener(KART, k);
    return () => { window.removeEventListener(OKU, o); window.removeEventListener(KART, k) };
  }, []);
  return (
    <>
      {oku != null && <DuyuruOkuModali id={oku} onKapat={() => setOku(null)} />}
      {kart && yetki('duyuru', kart.id ? 'degistir' : 'ekle') && (
        <DuyuruKarti id={kart.id} onKapat={() => setKart(null)}
                     onKaydet={() => { setKart(null); talepleriYenile(); window.dispatchEvent(new Event(DUYURU_DEGISTI)) }} />
      )}
      <KritikDuyuruEkrani />
    </>
  );
}
