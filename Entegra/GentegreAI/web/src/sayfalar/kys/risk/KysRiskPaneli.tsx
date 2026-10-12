import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni, type KartMetaYaniti, type ListeSatiri } from '../../../api/sozlesme';
import { guvenli } from '../../../bilesenler/mesaj';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { c } from '../../../dil/ceviri';
import { dofAcmaYolu } from '../../liste/kysOlayRiskAksiyonlari';

/**
 * KURUMSAL KALİTE — RİSK SAĞ KARTI (1062, mockup Ekranlar/Kalite2/risk_listesi.html):
 * "risk listesi + yanda kart". Seçili risk yerinde düzenlenir; skor = O × Ş
 * (sunucuda generated), rengi seviye eşiklerinden (ayar, fn_kys_risk_seviye).
 * Kayıt generic kart ucuyla (`kys-risk`); yeni risk listenin "Yeni" düğmesiyle.
 */
const ALANLAR = ['departmanId', 'olasilik', 'siddet', 'gozdenGecirme', 'sahipId', 'durum', 'tanim', 'kontrolOnlem'] as const;
type Alan = typeof ALANLAR[number];
type Deger = Record<Alan, string>;
const KODLU: readonly Alan[] = ['departmanId', 'olasilik', 'siddet', 'sahipId', 'durum'];

const okut = (k: Record<string, unknown>): Deger => {
  const d = Object.fromEntries(ALANLAR.map(a => [a, k[a] == null ? '' : String(k[a])])) as Deger;
  d.gozdenGecirme = d.gozdenGecirme.slice(0, 10);
  return d;
};

export function KysRiskPaneli({ satir, yenile }: { satir: ListeSatiri | null; yenile: () => void }) {
  const git = useNavigate();
  const { yetki } = useOturum();
  const id = satir ? Number(satir.id) : 0;
  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [d, setD] = useState<Deger | null>(null);
  const [surum, setSurum] = useState<string | undefined>();
  const [duzenle, setDuzenle] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  // Liste satırının TAZE hali (seviye, durum adı): kayıttan sonra listedeki
  //   seçili satır nesnesi eski kalır - seviye rengi sunucudan yeniden okunur.
  const [ozet, setOzet] = useState<ListeSatiri | null>(satir);
  const ozetOku = (rid: number) => api.liste('kys-risk', { boyut: 1, filtre: { alan: 'id', op: 'esit', deger: rid } })
    .then(y => setOzet(y.satirlar[0] ?? null)).catch(() => { /* eski satır kalır */ });

  useEffect(() => { api.kartAlanlari('kys-risk').then(setMeta).catch(h => setHata(hataMetni(h))) }, []);
  useEffect(() => {
    setIlk(null); setHata(null); setOzet(satir);
    if (!(id > 0)) return;
    let iptal = false;
    api.kartOku('kys-risk', id).then(y => {
      if (iptal) return;
      const v = okut(y.kart);
      setIlk(v); setD(v); setSurum(y.kart.surum); setDuzenle(y.yetki.duzenle);
    }).catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [id]);

  if (!(id > 0)) return <div className="kys-olay-panel sonuk">{c('Bir risk seçin ya da ＋ Yeni Risk ile ekleyin.')}</div>;
  if (hata) return <div className="kys-olay-panel"><div className="hata-kutusu">{hata}</div></div>;
  if (!ilk || !d || !meta) return <div className="kys-olay-panel sonuk">{c('Yükleniyor…')}</div>;

  const kodlar = (alan: string) => meta.alanlar.find(a => a.ad === alan)?.kodlar ?? {};
  const salt = !duzenle;
  const degisen = ALANLAR.filter(a => d[a] !== ilk[a]);
  const yaz = (a: Alan) => (e: { target: { value: string } }) => setD(x => x && ({ ...x, [a]: e.target.value }));
  const secim = (a: Alan, bosOlur = false) => (
    <select value={d[a]} disabled={salt} onChange={yaz(a)}>
      {bosOlur || !d[a] ? <option value="">—</option> : null}
      {Object.entries(kodlar(a)).map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
    </select>
  );
  // SKOR: kayıtlıysa sunucunun seviyesi (eşikler ayarda); O/Ş değiştiyse
  //   yalnız çarpım - seviye kaydedince sunucuda hesaplanır.
  const skor = Number(d.olasilik || 0) * Number(d.siddet || 0);
  const kayitli = d.olasilik === ilk.olasilik && d.siddet === ilk.siddet;
  const [, seviye] = String(ozet?.skorRozet ?? '').split('|');

  const kaydet = async () => {
    if (degisen.length === 0) return;
    await guvenli(async () => {
      const kart: Record<string, unknown> = {};
      for (const a of degisen) kart[a] = KODLU.includes(a) ? (d[a] ? Number(d[a]) : null) : (d[a] || (a === 'gozdenGecirme' ? null : ''));
      const y = await api.kartGuncelle('kys-risk', id, { surum, kart });
      const v = okut(y.kart);
      setIlk(v); setD(v); setSurum(y.kart.surum);
      await ozetOku(id);
      yenile();
    });
  };

  return (
    <div className="kys-olay-panel">
      <div className="kagrup">
        <h6>{String(satir?.no ?? '')}
          {ozet?.durumAdi ? <span className="rozet gri">{String(ozet.durumAdi)}</span> : null}
        </h6>
        <div className="alan-izgara kys-olay-hdr">
          <label className="alan"><span className="etiket">{c('No')}</span><input value={String(satir?.no ?? '')} disabled /></label>
          <label className="alan"><span className="etiket">{c('Birim / süreç')}</span>{secim('departmanId', true)}</label>
          <label className="alan"><span className="etiket">{c('Olasılık (1–5)')}<b className="zorunlu"> *</b></span>{secim('olasilik')}</label>
          <label className="alan"><span className="etiket">{c('Şiddet (1–5)')}<b className="zorunlu"> *</b></span>{secim('siddet')}</label>
          <label className="alan"><span className="etiket">{c('Skor')}</span>
            <span className="kys-olay-bildiren">
              <span className={`risk-skor s${kayitli ? seviye || 0 : 0}`}>{skor || '—'}</span>
              {kayitli ? String(ozet?.seviyeAdi ?? '') : c('kaydedince hesaplanır')}
            </span></label>
          <label className="alan"><span className="etiket">{c('Gözden geçirme')}</span>
            <input type="date" value={d.gozdenGecirme} disabled={salt} onChange={yaz('gozdenGecirme')} /></label>
          <label className="alan"><span className="etiket">{c('Sahibi')}</span>{secim('sahipId', true)}</label>
          <label className="alan"><span className="etiket">{c('Durum')}</span>{secim('durum')}</label>
        </div>
        <div className="kys-olay-metin">
          <label className="alan"><span className="etiket">{c('Risk')}<b className="zorunlu"> *</b></span>
            <textarea value={d.tanim} disabled={salt} maxLength={1000} onChange={yaz('tanim')} /></label>
          <label className="alan"><span className="etiket">{c('Alınan / alınacak önlem')}</span>
            <textarea value={d.kontrolOnlem} disabled={salt} maxLength={1000} onChange={yaz('kontrolOnlem')} /></label>
        </div>
        <div className="kys-olay-arac">
          {!salt && <button type="button" className="d bir" disabled={degisen.length === 0} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>}
          {yetki('kys.dof', 'ekle') && <button type="button" className="d onay"
            onClick={() => git(dofAcmaYolu(4, { ...satir!, tanim: d.tanim }))}>🛠️ {c('DÖF Aç')}</button>}
          <button type="button" className="d kys-olay-sag" onClick={() => git(`/kys-risk/${id}`)}>{c('Kartı aç')}</button>
        </div>
      </div>
    </div>
  );
}
