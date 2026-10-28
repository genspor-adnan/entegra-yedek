import { useEffect, useState } from 'react';
import { istek } from '../../api/cekirdek';
import { hataMetni } from '../../api/sozlesme';
import type { Deger } from '../../bilesenler/kartAlanCizim';
import { para, sayi } from '../../bilesenler/bicim';
import { kartSekmeRozetiYayinla } from '../../bilesenler/kartSekmeleri';
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
  kayitTarihi: string | null; ilaclar: string[];
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
// Bant rozetleri KISA (kullanıcı 24.10.2026): uzun SKRS / ilaç adı kesilir, tamamı title'da.
const kisalt = (s: string, n = 22) => (s.length > n ? s.slice(0, n - 1).trimEnd() + '…' : s);
// "AKLAV BID 1000 MG FILM KAPLI TABLET, 14 ADET" -> "AKLAV BID": ilk rakam / virgülden önce.
const ilacKisa = (s: string) => kisalt(s.split(/[\d,(]/)[0].trim() || s, 18);

const STIL = `
.mk-ozet.hkb-tek { grid-template-columns: 1.9fr 1.3fr 1.2fr 1fr 1fr 1fr 1.1fr }
.mk-ozet > .hkb-kim { display: flex; flex-direction: row; align-items: center; gap: 12px; min-width: 0 }
.hkb-kim-m { display: flex; flex-direction: column; min-width: 0 }
.hkb-kim-m small b { font-size: inherit; color: var(--yazi, #1f2d3a); font-weight: normal }
.hkb-foto { position: relative; flex: none }
.hkb-foto small { position: absolute; bottom: -6px; right: -10px; background: var(--zemin, #fff); border: 1px solid var(--cizgi2);
  border-radius: 8px; font-size: 9.5px; color: var(--soluk); padding: 0 4px; white-space: nowrap }
.mk-ozet .hkb-ad { font-size: 15px; font-weight: bold; color: var(--lacivert, #14315a); overflow: hidden; text-overflow: ellipsis }
.hkb-alt { color: var(--soluk); font-size: 11.5px; margin-top: 3px }
.hkb-alt b { color: var(--yazi, #1f2d3a); font-weight: normal }
.hkb-alt .hkb-goz { cursor: pointer; margin-left: 3px; opacity: .7 }
.hkb-govde { flex: 1; min-width: 0 }
.hkb-ust { display: flex; align-items: center; gap: 10px }
.hkb-rz { margin-left: auto; display: flex; gap: 4px; flex-wrap: wrap; justify-content: flex-end }
.hkb-rz .rozet.buyuk { font-weight: bold; font-size: 11.5px }
.mk-ozet b > span { font-size: inherit; overflow: visible }
.mk-ozet b > span:not(.ml-borc) { color: inherit }
`;

export function HastaKartBandi({ id, deger, git }: {
  id: number; deger: Record<string, Deger>; git(yol: string): void;
}) {
  const [o, setO] = useState<HastaKartOzeti | null>(null);
  const [hata, setHata] = useState('');
  // Kart her kaydedildiğinde (deger değişir) özet yeniden okunur - alerji / kurum değişmiş olabilir.
  const surum = String(deger.surum ?? '');
  useEffect(() => {
    let iptal = false;
    istek<HastaKartOzeti>(`/api/hasta/${id}/kart-ozeti`)
      .then(x => { if (!iptal) { setO(x); setHata('') } })
      .catch(e => { if (!iptal) setHata(hataMetni(e)) });
    return () => { iptal = true };
  }, [id, surum]);
  // BAŞVURULAR SEKMESİ ROZETİ (kullanıcı 28.10.2026): sayı özetten - GenForm sekme adının yanına yazar.
  useEffect(() => {
    if (o) kartSekmeRozetiYayinla({ kaynak: 'hasta', id, anahtar: 'ozel:basvurular', metin: sayi.format(o.basvuruSayisi) });
  }, [o, id]);

  const ad = [deger.ad, deger.soyad].map(x => String(x ?? '').trim()).filter(Boolean).join(' ') || String(deger.unvan ?? '');
  const y = yas(o?.dogumTarihi ?? null);
  const aktif = Number(deger.durum ?? 1) === 1;
  // Avatar köşesi (mockup "E · 63"): cinsiyet harfi + yaş.
  const cins = o?.cinsiyet === 1 ? 'E' : o?.cinsiyet === 2 ? 'K' : '';
  const kose = [cins, y ?? ''].filter(x => x !== '').join(' · ');
  return (
    <>
      <style>{STIL}</style>
      {hata && <div className="hata-kutusu" style={{ margin: '0 12px 6px' }}>{hata}</div>}
      {/* TEK BANT (kullanıcı 28.10.2026: "2 bant 1 bant a düşsün"): üstteki kimlik bandı kalktı - avatar, ad soyad,
          dosya / kan grubu özet şeridinin İLK hücresinde; "Toplam başvuru" hücresi kaldırıldı. Pasif / vefat
          avatarın soluk hali ve alt satırda; alerjiler "Alerji · Kronik · İlaç" hücresinin ipucunda. */}
      <div className="mk-ozet hkb-tek">
        {/* 1 HASTA (kullanıcı: "avatar daha büyük ve adın solunda yalnız olsun"): büyük avatar tek başına solda. */}
        <div className="hkb-kim">
          <Avatar ad={ad} buyuk soluk={!aktif} />
          <span className="hkb-kim-m">
            <b className="hkb-ad" title={ad}>{ad || '—'}</b>
            {/* Etiketsiz (kullanıcı 28.10.2026: "dosya ve kan label'lara gerek yok"): E · 69 · H-000081 · A Rh+. */}
            <small>{[kose, String(deger.kod ?? ''), o?.kanGrubu ?? '',
                     !aktif ? c('Pasif') : '', o?.vefat === 1 ? `✝ ${c('Vefat')}` : ''].filter(Boolean).join(' · ')}</small>
          </span>
        </div>
        {/* SIRA (kullanıcı 28.10.2026): hasta · kurum · son başvuru · bakiye · alerji · bekleyen sonuç · sonraki randevu. */}
        <div><span>{c('Kurum / Ödeyen')}</span><b>{o ? (o.kurum || c('Özel (Ücretli)')) : '…'}</b>
          <small>{c('kartta bağlı kurum')}</small></div>
        <div><span>{c('Son başvuru')}</span><b>{o ? tarih(o.sonBasvuru) : '…'}</b>
          <small>{o?.sonBasvuru ? [o.sonBolum, o.sonDoktor].filter(Boolean).join(' · ') : c('başvuru yok')}</small></div>
        <button type="button" title={c('Hasta ekstresini aç')} onClick={() => git(`/ekstre?tur=cari&id=${id}`)}>
          <span>{c('Hasta bakiyesi')}</span>
          <b className={o && o.bakiye > 0.005 ? 'ml-borc' : o && o.bakiye < -0.005 ? 'ml-alacak' : undefined}>
            {o ? para.format(Math.abs(o.bakiye)) : '…'}</b>
          <small>{o && o.bakiye < -0.005 ? c('avans / alacak') : c('açık borç · ekstre')}</small></button>
        <div title={o ? [o.alerjiler.length ? `${c('Alerji')}: ${o.alerjiler.join(', ')}` : '',
                         o.kronikler.length ? `${c('Kronik')}: ${o.kronikler.join(', ')}` : '',
                         o.ilaclar.length ? `${c('İlaç')}: ${o.ilaclar.map(ilacKisa).join(', ')}` : ''].filter(Boolean).join(' · ') : undefined}>
          <span>{c('Alerji · Kronik · İlaç')}</span>
          <b>{o ? <><span className={o.alerjiSayisi > 0 ? 'ml-borc' : undefined}>{o.alerjiSayisi}</span> · {o.kronikSayisi} · {o.ilacSayisi}</> : '…'}</b>
          <small>{c('aktif kayıtlar')}</small></div>
        <div><span>{c('Bekleyen sonuç')}</span><b>{o ? o.bekleyenSonuc : '…'}</b>
          <small>{c('lab istemi · son 90 gün')}</small></div>
        <div><span>{c('Sonraki randevu')}</span><b>{o ? tarih(o.sonrakiRandevu, true) : '…'}</b>
          <small>{o?.sonrakiRandevu ? [o.randevuBolum, o.randevuHekim].filter(Boolean).join(' · ') : c('planlı randevu yok')}</small></div>
      </div>
    </>
  );
}
