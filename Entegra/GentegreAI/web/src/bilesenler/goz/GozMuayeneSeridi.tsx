import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { GozMuayeneSeridiYaniti } from '../../api/uclar/goz';
import { tarihSaat } from '../bicim';

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

const CINSIYET: Record<number, string> = { 1: 'E', 2: 'K' };
const MUAYENE_TURU: Record<number, string> = {
  1: 'Tam muayene', 2: 'Kontrol', 3: 'Postop', 4: 'Tarama', 5: 'Acil',
};

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
  const d = veri.durum;
  const adim = (ad: string, sayi: number) => (
    <span key={ad} className={sayi > 0 ? 'tamam' : ''}>
      {sayi > 0 ? '✔' : '○'} {ad}
    </span>
  );

  return (
    <>
      <div className="goz-kimlik">
        <div className="ad">{k.hasta}</div>
        <div className="kv"><span>Yaş / cinsiyet</span>
          <b>{k.yas ?? '—'}{k.cinsiyet ? ` / ${CINSIYET[k.cinsiyet] ?? ''}` : ''}</b></div>
        <div className="kv"><span>Protokol</span>
          <b>{k.protokol || k.hastaNo || '—'}</b></div>
        <div className="kv"><span>Tarih</span>
          <b>{tarihSaat(k.tarih)}</b></div>
        <div className="kv"><span>Hekim / bölüm</span>
          <b>{[k.hekim, k.bolum].filter(Boolean).join(' · ') || '—'}</b></div>
        {k.oda && <div className="kv"><span>Oda</span><b>{k.oda}</b></div>}
        <div className="sag">
          <span className="rozet mavi">{MUAYENE_TURU[k.muayeneTuru] ?? 'Muayene'}</span>
          {/* DİLATASYON ROZETİ: dilate hasta fundusa hazırdır ama iki saat
              boyunca araç kullanamaz — hekim ve sekreter bunu bilmeli. */}
          {k.dilate
            ? <span className="rozet mor">💧 dilate{k.dilatasyonIlac ? ` · ${k.dilatasyonIlac}` : ''}</span>
            : <span className="rozet pas">dilate değil</span>}
          {k.tamamlandi && <span className="rozet ok">tamamlandı</span>}
        </div>
      </div>

      {/* BAĞLAM KUTULARI (mockup `.hdr k4`): dördü de OKUNUR, yazılmaz -
          şikâyet ve öykü genel muayene kaydının alanları; burada hekimin
          hatırlaması için duruyor. */}
      <div className="goz-baglam">
        <div className="alan">
          <span>Şikâyet</span>
          <b>{k.sikayet || <i className="bos-deger">girilmemiş</i>}</b>
        </div>
        <div className="alan">
          <span>Sistemik / ilaç</span>
          <b>{[k.ozgecmis, k.sistem].filter(Boolean).join(' · ')
              || <i className="bos-deger">—</i>}</b>
        </div>
        <div className="alan">
          <span>Ön tetkik (tekniker · cihaz)</span>
          <b>
            {veri.onTetkik.length === 0
              ? <i className="bos-deger">cihazdan ölçüm gelmedi</i>
              : veri.onTetkik.map(t => (
                  <span key={t.ad} className="rozet ok">
                    {t.ad} ✔ {t.zaman ? new Date(t.zaman).toTimeString().slice(0, 5) : ''}
                  </span>
                ))}
          </b>
        </div>
        <div className="alan">
          <span>Aile / risk</span>
          <b>{k.soygecmis || <i className="bos-deger">—</i>}</b>
        </div>
      </div>

      {/* TAMAMLANMA ÇUBUĞU (mockup `.statusbar`): muayeneyi kapatmadan önce
          "neyi ölçmedim" sorusunun cevabı. */}
      <div className="goz-durum">
        {adim('VA', d.va)}
        {adim('Ref', d.ref_)}
        {adim('GİB', d.gib)}
        {adim('Ön seg', d.onSegment)}
        {adim('Fundus', d.fundus)}
        {adim('Tanı', d.tani)}
        <span className="sonuk">
          Ölçümler göz bazlı kaydedilir (OD/OS ayrı satır); kaynak cihaz,
          tekniker ya da hekimdir.
        </span>
      </div>
    </>
  );
}
