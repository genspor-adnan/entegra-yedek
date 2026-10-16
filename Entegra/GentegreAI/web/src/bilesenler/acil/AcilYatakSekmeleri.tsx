import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { AcilYatakAyrinti } from '../../api/uclar/acil';
import { c } from '../../dil/ceviri';
import { tarihSaat } from '../bicim';
import { guvenli, listeSor, mesaj, metinSor } from '../mesaj';
import { ACIL_CIKIS_SEKLI, ACIL_TRIYAJ_RENK } from './acilKodlari';

/**
 * ACİL YATAK KARTI SEKMELERİ (1118, mockup Ekranlar/Acil/acil_yatak_karti.html): Durum · Kullanım
 * Geçmişi · Temizlik & Bakım. Donanım katalog grubu (kart alanları). Durum ELLE YAZILMAZ: Dolu / Boş
 * hastadan gelir; Temizlikte / Kullanım dışı / Kullanıma aç düğmeyle (uç loglar, olay günlüğü tetikle).
 */
const DURUM: { kod: number; ad: string; sinif: string; ikon: string }[] = [
  { kod: 0, ad: 'Boş', sinif: 'bos', ikon: '🟢' },
  { kod: 1, ad: 'Dolu', sinif: 'dolu', ikon: '🔵' },
  { kod: 2, ad: 'Temizlikte', sinif: 'tem', ikon: '🟡' },
  { kod: 3, ad: 'Kullanım dışı', sinif: 'kap', ikon: '🔴' },
];
const saat = (z: string | null | undefined) => (z ? tarihSaat(z).slice(11, 16) : '—');
const gunSaat = (z: string | null | undefined) => {
  if (!z) return '—';
  const t = tarihSaat(z);
  return new Date(z).toDateString() === new Date().toDateString() ? t.slice(11, 16) : `${t.slice(0, 5)} ${t.slice(11, 16)}`;
};
const sure = (dk: number | null | undefined) =>
  dk == null ? '—' : dk >= 1440 ? `${Math.floor(dk / 1440)} gün ${Math.floor((dk % 1440) / 60)} sa`
  : dk >= 60 ? `${Math.floor(dk / 60)} sa ${dk % 60} dk` : `${dk} dk`;

function useAyrinti(yatakId: number, tazele: number) {
  const [a, setA] = useState<AcilYatakAyrinti | null>(null);
  useEffect(() => {
    let iptal = false;
    void api.acilYatakAyrinti(yatakId).then(y => { if (!iptal) setA(y) }).catch(() => { if (!iptal) setA(null) });
    return () => { iptal = true };
  }, [yatakId, tazele]);
  return a;
}

/** Alan renk / ad (acil_yatak.alan: 1 resüsitasyon · 2 müşahede · 3 yeşil · 4 izolasyon · 5 travma). */
export const ACIL_ALAN: Record<number, { ad: string; renk: string }> = {
  1: { ad: 'Resüsitasyon', renk: '#c62828' }, 2: { ad: 'Müşahede', renk: '#f9a825' },
  3: { ad: 'Yeşil alan', renk: '#2e7d32' }, 4: { ad: 'İzolasyon', renk: '#6a1b9a' }, 5: { ad: 'Travma', renk: '#d84315' },
};
const durumAdi = (d: number) => DURUM.find(x => x.kod === d)?.ad ?? '';

/** Hastayı başka (boş, aktif) yatağa taşır - acil başvurunun yatak ucu; eski yatak temizliğe düşer. */
async function hastayiTasi(basvuruId: number, yatakId: number): Promise<boolean> {
  const y = await api.liste('acilYatak', { sayfa: 1, boyut: 200, filtre: { op: 'and', kosullar: [
    { alan: 'durum', op: 'esit', deger: 0 }, { alan: 'aktif', op: 'esit', deger: 1 }] } });
  const bos = y.satirlar.filter(s => Number(s.id) !== yatakId);
  if (bos.length === 0) { mesaj(c('Boş yatak yok.')); return false }
  const sec = await listeSor(c('Hasta hangi yatağa taşınsın?'),
    bos.map(s => ({ kod: String(s.id), ad: `${String(s.kod ?? '')} · ${String(s.ad ?? '')} · ${String(s.alanAdi ?? '')}` })),
    String(bos[0].id), c('Yatak'));
  if (!sec) return false;
  await api.acilYatak(basvuruId, Number(sec));
  return true;
}

/**
 * BAŞLIK EKİ (mockup): "— R-3" ve sağda alan rengi · durum · dolu yatakta süre. Durum yataktaki
 * hastadan okunur (kayıttaki durum eski olabilir).
 */
export function AcilYatakBaslik({ yatakId, deger, tazele }: { yatakId: number; deger: Record<string, unknown>; tazele: number }) {
  const a = useAyrinti(yatakId, tazele);
  const alan = ACIL_ALAN[Number(deger.alan ?? 0)];
  const durum = a?.hasta ? 1 : Number(deger.durum ?? 0);
  const yer = a?.hasta?.yerlesme ?? a?.hasta?.giris;
  const dk = durum === 1 && yer ? Math.max(0, Math.round((Date.now() - new Date(yer).getTime()) / 60000)) : null;
  return (
    <span className="ay-baslik">
      <b>— {String(deger.kod ?? '')}</b>
      <span className="ay-baslik-sag">
        {alan && <><span className="ay-alan" style={{ background: alan.renk }} />{c(alan.ad)}</>}
        {' · '}{c(durumAdi(durum))}{dk !== null ? ` · ${sure(dk)}` : ''}
      </span>
    </span>
  );
}

/**
 * ARAÇ ÇUBUĞU (mockup): Hastayı Başka Yatağa Al · Temizliğe Al · Kullanım Dışı / Kullanıma Aç ·
 * Yatak Etiketi. Kural uçta da var; düğme yalnız uygun durumda etkin.
 */
export function AcilYatakAraclari({ yatakId, deger, tazele, onDegisti }: {
  yatakId: number; deger: Record<string, unknown>; tazele: number; onDegisti(): void;
}) {
  const a = useAyrinti(yatakId, tazele);
  const hasta = a?.hasta ?? null;
  const durum = hasta ? 1 : Number(deger.durum ?? 0);
  const degistir = (yeni: 0 | 2 | 3) => guvenli(async () => {
    let not: string | undefined;
    if (yeni === 3) {
      const n = await metinSor(c('Yatak kullanım dışı yapılsın - triyajda atanamaz. Neden?'), '', c('Arıza / bakım / kapatma'));
      if (n === null) return;
      not = n.trim() || undefined;
    }
    await api.acilYatakDurum(yatakId, yeni, not);
    onDegisti();
  });
  const etiket = () => {
    const alan = ACIL_ALAN[Number(deger.alan ?? 0)];
    const w = window.open('', '_blank', 'width=420,height=300');
    if (!w) return;
    w.document.write(`<html><head><title>${String(deger.kod ?? '')}</title></head><body style="font-family:Trebuchet MS,sans-serif;text-align:center;padding:24px">
      <div style="font-size:64px;font-weight:bold">${String(deger.kod ?? '')}</div>
      <div style="font-size:20px">${String(deger.ad ?? '')}</div>
      <div style="font-size:16px;margin-top:6px;color:${alan?.renk ?? '#333'}">${alan?.ad ?? ''}</div></body></html>`);
    w.document.close(); w.focus(); w.print();
  };
  return (
    <>
      <button type="button" className="d" disabled={!hasta}
              onClick={() => void guvenli(async () => { if (hasta && await hastayiTasi(hasta.basvuruId, yatakId)) onDegisti() })}>
        🔁 {c('Hastayı Başka Yatağa Al')}</button>
      <button type="button" className="d" disabled={!!hasta || durum !== 0} onClick={() => void degistir(2)}>🧹 {c('Temizliğe Al')}</button>
      {durum === 2 || durum === 3
        ? <button type="button" className="d onay" onClick={() => void degistir(0)}>✓ {c(durum === 2 ? 'Temizlik Bitti' : 'Kullanıma Aç')}</button>
        : <button type="button" className="d" disabled={!!hasta} onClick={() => void degistir(3)}>⛔ {c('Kullanım Dışı')}</button>}
      <button type="button" className="d" onClick={etiket}>🖨️ {c('Yatak Etiketi')}</button>
    </>
  );
}

/** Durum sekmesi: dört durum, yataktaki hasta, günlük özet. */
export function AcilYatakDurumSekmesi({ yatakId, durum, tazele, onDegisti, git }: {
  yatakId: number; durum: number; tazele: number; onDegisti(): void; git(yol: string): void;
}) {
  const a = useAyrinti(yatakId, tazele);
  const hasta = a?.hasta ?? null;
  const etkin = hasta ? 1 : durum;
  const degistir = (yeni: 0 | 2 | 3) => guvenli(async () => {
    if (hasta) { mesaj(c('Bu yatakta hasta var; önce hastayı çıkarın ya da taşıyın.')); return }
    let not: string | undefined;
    if (yeni === 3) {
      // Kullanım dışı: neden sorulur (iptal = vazgeç); temizlik bakım geçmişinde görünür.
      const n = await metinSor(c('Yatak kullanım dışı yapılsın - triyajda atanamaz. Neden?'), '', c('Arıza / bakım / kapatma'));
      if (n === null) return;
      not = n.trim() || undefined;
    }
    await api.acilYatakDurum(yatakId, yeni, not);
    onDegisti();
  });
  return (
    <div className="ay-sekme">
      <div className="kagrup">
        <h6>{c('Yatak durumu')} <span className="not">· {c('Dolu / Boş hasta yerleşince / çıkınca kendiliğinden değişir')}</span></h6>
        <div className="ay-durumlar">
          {DURUM.map(d => {
            // Tıklanabilenler: Temizlikte (boşken), Kullanım dışı (hastasızken), Boş (temizlikte / kullanım dışıyken).
            const tik = !hasta && ((d.kod === 2 && etkin === 0) || (d.kod === 3 && etkin !== 3)
                                   || (d.kod === 0 && (etkin === 2 || etkin === 3)));
            return (
              <button key={d.kod} type="button" className={`ay-d ${d.sinif}${etkin === d.kod ? ' on' : ''}`}
                      disabled={!tik && etkin !== d.kod} onClick={() => { if (tik) void degistir(d.kod as 0 | 2 | 3) }}
                      title={tik ? (d.kod === 0 ? c(etkin === 2 ? 'Temizlik bitti' : 'Kullanıma aç') : c('Bu duruma al')) : undefined}>
                {d.ikon} {c(d.ad)}{tik && d.kod === 0 ? ` · ${c(etkin === 2 ? 'temizlik bitti' : 'kullanıma aç')}` : ''}
              </button>
            );
          })}
        </div>
        {hasta && (
          <div className="ay-hasta">
            <span className="ay-avt">{hasta.hastaAd.split(/\s+/).map(p => p[0]).slice(0, 2).join('')}</span>
            <div>
              <b>{hasta.hastaAd}</b>
              {hasta.triyaj > 0 && <span className="rozet uyari" style={{ marginLeft: 6 }}>{c('Triyaj')} {ACIL_TRIYAJ_RENK[hasta.triyaj] ?? hasta.triyaj}</span>}
              <div className="not">{[hasta.protokolNo, hasta.yerlesme ? `${c('yerleşme')} ${saat(hasta.yerlesme)}` : `${c('geliş')} ${gunSaat(hasta.giris)}`,
                                    hasta.hekimAd, hasta.sikayet].filter(Boolean).join(' · ')}</div>
            </div>
            <span style={{ marginLeft: 'auto', display: 'flex', gap: 6 }}>
              <button type="button" className="d" onClick={() => git(`/acil-basvuru/${hasta.basvuruId}`)}>🗂️ {c('Hasta Kartı')}</button>
              <button type="button" className="d"
                      onClick={() => void guvenli(async () => { if (await hastayiTasi(hasta.basvuruId, yatakId)) onDegisti() })}>
                🔁 {c('Taşı')}</button>
            </span>
          </div>
        )}
      </div>
      <div className="ay-ozet">
        <div><span>{c('Bugün kullanım')}</span><b>{a?.ozet.bugunKullanim ?? 0}</b> <small>{c('hasta')}</small></div>
        <div><span>{c('Ort. kalış (7 gün)')}</span><b>{sure(a?.ozet.ortKalisDk)}</b></div>
        <div><span>{c('Ort. temizlik (7 gün)')}</span><b>{sure(a?.ozet.ortTemizlikDk)}</b></div>
        <div><span>{c('Doluluk (7 gün)')}</span><b>{a?.ozet.doluluk7 != null ? `%${a.ozet.doluluk7}` : '—'}</b></div>
      </div>
      <p className="not">{c('Temizlik bitmeden yatak Boş görünmez - triyajda atanamaz. Geçmiş 16.10.2026 itibarıyla tutuluyor.')}</p>
    </div>
  );
}

/** Kullanım geçmişi: yerleşme -> çıkış / taşınma çiftleri. */
export function AcilYatakGecmisSekmesi({ yatakId, tazele, git }: { yatakId: number; tazele: number; git(yol: string): void }) {
  const a = useAyrinti(yatakId, tazele);
  const cikis = (k: number) => ACIL_CIKIS_SEKLI.find(x => x.kod === k)?.ad ?? '';
  return (
    <div className="ay-sekme">
      {a && a.gecmis.length === 0 && <div className="not">{c('Bu yatakta henüz kayıtlı kullanım yok.')}</div>}
      {a && a.gecmis.length > 0 && (
        <table className="detay-tablo">
          <thead><tr><th>{c('Hasta')}</th><th>{c('Protokol')}</th><th>{c('Triyaj')}</th><th>{c('Giriş')}</th>
            <th>{c('Çıkış')}</th><th className="hiza-sag">{c('Kalış')}</th><th>{c('Çıkış şekli')}</th></tr></thead>
          <tbody>{a.gecmis.map((g, i) => (
            <tr key={i} className="tiklanir" onClick={() => git(`/acil-basvuru/${g.basvuruId}`)}>
              <td><b>{g.hastaAd}</b></td><td>{g.protokolNo}</td>
              <td>{g.triyaj > 0 ? ACIL_TRIYAJ_RENK[g.triyaj] ?? g.triyaj : '—'}</td>
              <td>{gunSaat(g.giris)}</td><td>{g.cikis ? gunSaat(g.cikis) : <span className="not">{c('yatakta')}</span>}</td>
              <td className="hiza-sag">{sure(g.kalisDk)}</td>
              <td>{g.cikis ? (g.tasindi ? c('Başka yatağa taşındı') : cikis(g.cikisSekli) || '—') : '—'}</td>
            </tr>))}</tbody>
        </table>
      )}
    </div>
  );
}

/** Temizlik & bakım: temizliğe alma -> bitti, kullanım dışı -> kullanıma açma. */
export function AcilYatakTemizlikSekmesi({ yatakId, tazele }: { yatakId: number; tazele: number }) {
  const a = useAyrinti(yatakId, tazele);
  return (
    <div className="ay-sekme">
      {a && a.temizlik.length === 0 && <div className="not">{c('Temizlik / bakım kaydı yok.')}</div>}
      {a && a.temizlik.length > 0 && (
        <table className="detay-tablo">
          <thead><tr><th>{c('Başlama')}</th><th>{c('Bitiş')}</th><th>{c('Tür')}</th><th className="hiza-sag">{c('Süre')}</th>
            <th>{c('Yapan')}</th><th>{c('Not')}</th></tr></thead>
          <tbody>{a.temizlik.map((t, i) => (
            <tr key={i}>
              <td>{gunSaat(t.baslama)}</td><td>{t.bitis ? gunSaat(t.bitis) : <span className="not">{c('sürüyor')}</span>}</td>
              <td>{t.tur === 3 ? c('Temizlik') : <span className="rozet uyari">{c('Kullanım dışı')}</span>}</td>
              <td className="hiza-sag">{sure(t.sureDk)}</td><td>{t.yapan || '—'}</td><td>{t.not || <span className="not">—</span>}</td>
            </tr>))}</tbody>
        </table>
      )}
    </div>
  );
}
