import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { GozMuayeneSeridiYaniti } from '../../api/uclar/goz';
import { tarihSaat } from '../bicim';
import { c } from '../../dil/ceviri';
import { cinsiyetAdi } from '../kisiKodlari';

/**
 * GÖZ MUAYENE KARTI ÜST ŞERİDİ — mockup
 * `Ekranlar/Goz/goz_detayli_muayene.html` (başlık + `.hdr k4` bağlam kutuları
 * + alt `.statusbar`).
 *
 * <b>Hekim ölçüme başlamadan dört şeyi okur:</b> kim (yaş/cinsiyet/protokol),
 * niçin geldi (şikâyet), neyi var (sistemik + kullandığı ilaç), teknikerin ne
 * ölçtüğü (otoref/tonometri saatleri, dilate mi). Bunlar sekmeye gömülseydi
 * hekim her muayenede iki kez gezinirdi; mockup da bu yüzden şeridi
 * sekmelerin ÜSTÜNE koyuyor.
 *
 * <b>Ön tetkik satırı cihazdan gelenin kanıtıdır</b> (kaynak = cihaz): "Otoref
 * ✔ 10:02" gören hekim aynı ölçümü ikinci kez yapmaz. Elle girilen değerle
 * karışmasın diye kaynak ayrımı sunucuda korunuyor.
 *
 * <b>Alt satır tamamlanma durumu</b> (mockup `.statusbar`): hangi ölçüm kümesi
 * dolu. Sayılar sunucudan gelir — istemci açılmamış sekmenin verisini
 * göremediği için eksik sayardı.
 */

// goz.muayene_turu kod listesiyle aynı (970: 4 / 5 ters yazılmıştı).
const MUAYENE_TURU: Record<number, string> = {
  1: 'Tam muayene', 2: 'Kontrol', 3: 'Postop', 4: 'Acil', 5: 'Tarama (DR)',
  6: 'Preop', 7: 'Refraktif', 8: 'Kontakt lens',
};
const sayiYaz = (v: number | null | undefined) => (v === null || v === undefined ? '—' : Number(v).toLocaleString('tr-TR'));

export function GozMuayeneSeridi({ gozMuayeneId, yenile }: {
  gozMuayeneId: number;
  yenile?: number;
}) {
  const [veri, setVeri] = useState<GozMuayeneSeridiYaniti | null>(null);

  const yukle = useCallback(async () => {
    // Şerit zorunlu değil: hatası kartı açılmaz yapmamalı.
    try { setVeri(await api.gozMuayeneSeridi(gozMuayeneId)) } catch { /* sessiz */ }
  }, [gozMuayeneId]);

  useEffect(() => { void yukle() }, [yukle, yenile]);
  if (!veri) return null;

  const k = veri.kimlik;
  // v4 (mockup goz_muayene_karti_v4): TEK sarı şerit - kim, takip, alerji, damlalar, sistemik,
  //   önceki muayene ve rozetler. Bağlam kutuları Özet'e, tamamlanma çubuğu sol gezinti /
  //   alt şeride taşındı.
  const e = veri.ek;
  return (
    <div className="gz4-ust">
      <div>
        <div className="ad">{k.hasta}</div>
        <div className="sonuk">
          {[`${k.yas ?? '—'}${k.cinsiyet ? ` ${cinsiyetAdi(k.cinsiyet, true)}` : ''}`,
            k.protokol ? `Prot. ${k.protokol}` : '', tarihSaat(k.tarih), k.hekim].filter(Boolean).join(' · ')}
        </div>
      </div>
      <div className="bil">
        {e?.takip && <span>{c('Takip')}: <b>{e.takip}</b></span>}
        <span>{c('Alerji')}: {e?.alerji ? <b className="gz-kirmizi">{e.alerji}</b> : <b className="gz-yesil">{c('bilinen yok')}</b>}</span>
        <span>{c('Damlalar')}: <b>{e?.tedavi || '—'}</b></span>
        {(k.ozgecmis || k.sistem) && <span>{c('Sistemik')}: <b>{[k.ozgecmis, k.sistem].filter(Boolean).join(' · ').slice(0, 60)}</b></span>}
        <span>{c('Önceki')}: <b>{e?.oncekiTarih
          ? `${tarihSaat(e.oncekiTarih).slice(0, 10)} · GİB ${sayiYaz(e.oncekiGibOd)} / ${sayiYaz(e.oncekiGibOs)}` : c('ilk muayene')}</b></span>
      </div>
      <div className="roz">
        <span className="rozet mavi">{MUAYENE_TURU[k.muayeneTuru] ?? 'Muayene'}</span>
        {k.dilate
          ? <span className="rozet mor">💧 {c('dilate')}{k.dilatasyonIlac ? ` · ${k.dilatasyonIlac}` : ''}</span>
          : <span className="rozet pas">{c('dilate değil')}</span>}
        {veri.onTetkik.map(t => <span key={t.ad} className="rozet ok">{t.ad} ✓</span>)}
        <span className={`rozet ${k.tamamlandi ? 'ok' : 'uyari'}`}>{k.tamamlandi ? c('tamamlandı') : c('taslak')}</span>
      </div>
    </div>
  );
}
