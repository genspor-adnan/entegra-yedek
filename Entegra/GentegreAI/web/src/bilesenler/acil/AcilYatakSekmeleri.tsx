import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { AcilYatakAyrinti } from '../../api/uclar/acil';
import { c } from '../../dil/ceviri';
import { tarihSaat } from '../bicim';
import { guvenli, mesaj, metinSor } from '../mesaj';
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
  dk == null ? '—' : dk >= 60 ? `${Math.floor(dk / 60)} sa ${dk % 60}` : `${dk} dk`;

function useAyrinti(yatakId: number, tazele: number) {
  const [a, setA] = useState<AcilYatakAyrinti | null>(null);
  useEffect(() => {
    let iptal = false;
    void api.acilYatakAyrinti(yatakId).then(y => { if (!iptal) setA(y) }).catch(() => { if (!iptal) setA(null) });
    return () => { iptal = true };
  }, [yatakId, tazele]);
  return a;
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
            <button type="button" className="d" style={{ marginLeft: 'auto' }}
                    onClick={() => git(`/acil-basvuru/${hasta.basvuruId}`)}>🗂️ {c('Hasta Kartı')}</button>
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
