import { useEffect, useState } from 'react';
import { istek } from '../../api/cekirdek';
import { hataMetni } from '../../api/sozlesme';
import type { Deger } from '../../bilesenler/kartAlanCizim';
import { para, sayi } from '../../bilesenler/bicim';
import { Avatar } from '../../bilesenler/grid/satirHucre';
import { c } from '../../dil/ceviri';

/**
 * HASTA KARTI İSİM BANDI + SAYI KUTULARI (kullanıcı 24.10.2026, mockup Kayıt Kabul/hasta_karti_v5.html):
 * kart araç çubuğunun altında, sekmelerin üstünde - eski etiketli kimlik şeridinin yerinde (Kimlik No /
 * Ad / Soyad / Durum alanları Genel sekmesinin "Kimlik" kutusuna geçti). Ad, dosya no ve kimlik no kartın
 * kendi değerinden (kaydedilince hemen değişir); doğum / kurum / sayılar `GET /api/hasta/{id}/kart-ozeti`.
 */
export interface HastaKartOzeti {
  dogumTarihi: string | null; cinsiyet: number; kanGrubu: string; vefat: number; kurum: string;
  sonBasvuru: string | null; sonBolum: string; sonDoktor: string; basvuruSayisi: number;
  sonrakiRandevu: string | null; randevuBolum: string; randevuHekim: string;
  bakiye: number; alerjiSayisi: number; alerjiSiddet: number; alerjiler: string[];
  kronikSayisi: number; kronikler: string[]; ilacSayisi: number; bekleyenSonuc: number;
}

const tarih = (s: string | null, saat = false) => {
  if (!s) return '—';
  const d = new Date(s);
  if (Number.isNaN(d.getTime())) return '—';
  const g = d.toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' });
  return saat ? `${g} ${d.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}` : g;
};
const yas = (s: string | null) => {
  if (!s) return null;
  const d = new Date(s), b = new Date();
  let y = b.getFullYear() - d.getFullYear();
  if (b.getMonth() < d.getMonth() || (b.getMonth() === d.getMonth() && b.getDate() < d.getDate())) y--;
  return y >= 0 && y < 130 ? y : null;
};
const maskele = (tc: string) => (tc.length >= 8 ? `${tc.slice(0, 3)}${'*'.repeat(tc.length - 6)}${tc.slice(-3)}` : tc);

const STIL = `
.hkb { display: flex; gap: 14px; align-items: center; padding: 10px 14px; border-top: 1px solid var(--cizgi2) }
.hkb .gh-av.buyuk { width: 52px; height: 52px; font-size: 19px; flex: none }
.hkb-ad { font-size: 17px; font-weight: bold; color: var(--lacivert, #14315a) }
.hkb-alt { color: var(--soluk); font-size: 11.5px; margin-top: 3px }
.hkb-alt b { color: var(--yazi, #1f2d3a); font-weight: normal }
.hkb-alt .hkb-goz { cursor: pointer; margin-left: 3px; opacity: .7 }
.hkb-rz { margin-top: 6px; display: flex; gap: 4px; flex-wrap: wrap }
.hkb-rz .rozet.buyuk { font-weight: bold; font-size: 11.5px }
.mk-ozet b > span { font-size: inherit; overflow: visible }
.mk-ozet b > span:not(.ml-borc) { color: inherit }
`;

export function HastaKartBandi({ id, deger, git }: {
  id: number; deger: Record<string, Deger>; git(yol: string): void;
}) {
  const [o, setO] = useState<HastaKartOzeti | null>(null);
  const [hata, setHata] = useState('');
  const [tcAcik, setTcAcik] = useState(false);
  // Kart her kaydedildiğinde (deger değişir) özet yeniden okunur - alerji / kurum değişmiş olabilir.
  const surum = String(deger.surum ?? '');
  useEffect(() => {
    let iptal = false;
    istek<HastaKartOzeti>(`/api/hasta/${id}/kart-ozeti`)
      .then(x => { if (!iptal) { setO(x); setHata('') } })
      .catch(e => { if (!iptal) setHata(hataMetni(e)) });
    return () => { iptal = true };
  }, [id, surum]);

  const ad = [deger.ad, deger.soyad].map(x => String(x ?? '').trim()).filter(Boolean).join(' ') || String(deger.unvan ?? '');
  const tc = String(deger.vkno ?? '');
  const y = yas(o?.dogumTarihi ?? null);
  const aktif = Number(deger.durum ?? 1) === 1;
  const cins = o?.cinsiyet === 1 ? 'E' : o?.cinsiyet === 2 ? 'K' : '';
  return (
    <>
      <style>{STIL}</style>
      <div className="hkb">
        <Avatar ad={ad} buyuk soluk={!aktif} />
        <div>
          <div className="hkb-ad">{ad || '—'}</div>
          <div className="hkb-alt">
            {c('Dosya')} <b>{String(deger.kod ?? '') || '—'}</b>
            {tc && <> · TC <b>{tcAcik ? tc : maskele(tc)}</b>
              <span className="hkb-goz" title={c(tcAcik ? 'Gizle' : 'Göster')} onClick={() => setTcAcik(x => !x)}>👁</span></>}
            {o?.dogumTarihi && <> · {c('Doğum')} <b>{tarih(o.dogumTarihi)}</b>{y !== null ? ` (${y} y${cins ? ' · ' + cins : ''})` : ''}</>}
            {o?.kanGrubu && <> · {c('Kan')} <b>{o.kanGrubu}</b></>}
            {o && <> · <b>{sayi.format(o.basvuruSayisi)}</b> {c('başvuru')}</>}
          </div>
          <div className="hkb-rz">
            <span className={`rozet ${aktif ? 'ok' : 'gri'}`}>● {c(aktif ? 'Aktif' : 'Pasif')}</span>
            {o?.kurum && <span className="rozet mavi">{o.kurum}</span>}
            {o && o.alerjiSayisi > 0 && (
              <span className="rozet hata buyuk" title={o.alerjiler.join(', ')}>
                ⚠ {c('ALERJİ')}: {o.alerjiler[0]}{o.alerjiSayisi > 1 ? ` +${o.alerjiSayisi - 1}` : ''}</span>)}
            {o?.kronikler.map(k => <span key={k} className="rozet mor">{k}</span>)}
            {o?.vefat === 1 && <span className="rozet gri">✝ {c('Vefat')}</span>}
          </div>
        </div>
      </div>
      {hata && <div className="hata-kutusu" style={{ margin: '0 12px 6px' }}>{hata}</div>}
      <div className="mk-ozet">
        <div><span>{c('Son başvuru')}</span><b>{o ? tarih(o.sonBasvuru) : '…'}</b>
          <small>{o?.sonBasvuru ? [o.sonBolum, o.sonDoktor].filter(Boolean).join(' · ') : c('başvuru yok')}</small></div>
        <div><span>{c('Sonraki randevu')}</span><b>{o ? tarih(o.sonrakiRandevu, true) : '…'}</b>
          <small>{o?.sonrakiRandevu ? [o.randevuBolum, o.randevuHekim].filter(Boolean).join(' · ') : c('planlı randevu yok')}</small></div>
        <div><span>{c('Kurum / Ödeyen')}</span><b>{o ? (o.kurum || c('Özel (Ücretli)')) : '…'}</b>
          <small>{c('kartta bağlı kurum')}</small></div>
        <button type="button" title={c('Hasta ekstresini aç')} onClick={() => git(`/ekstre?tur=cari&id=${id}`)}>
          <span>{c('Hasta bakiyesi')}</span>
          <b className={o && o.bakiye > 0.005 ? 'ml-borc' : o && o.bakiye < -0.005 ? 'ml-alacak' : undefined}>
            {o ? para.format(Math.abs(o.bakiye)) : '…'}</b>
          <small>{o && o.bakiye < -0.005 ? c('avans / alacak') : c('açık borç · ekstre')}</small></button>
        <div><span>{c('Alerji · Kronik · İlaç')}</span>
          <b>{o ? <><span className={o.alerjiSayisi > 0 ? 'ml-borc' : undefined}>{o.alerjiSayisi}</span> · {o.kronikSayisi} · {o.ilacSayisi}</> : '…'}</b>
          <small>{c('aktif kayıtlar')}</small></div>
        <div><span>{c('Bekleyen sonuç')}</span><b>{o ? o.bekleyenSonuc : '…'}</b>
          <small>{c('lab istemi · son 90 gün')}</small></div>
        <div><span>{c('Toplam başvuru')}</span><b>{o ? sayi.format(o.basvuruSayisi) : '…'}</b>
          <small>{c('ilk kayıttan bu yana')}</small></div>
      </div>
    </>
  );
}
