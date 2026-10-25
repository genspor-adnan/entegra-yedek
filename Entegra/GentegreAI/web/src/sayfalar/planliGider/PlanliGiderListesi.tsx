import { useCallback, useContext, useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import {
  planliGiderUclari as u,
  type PlanliGiderKarti, type PlanliGiderListeSuzgeci, type PlanliGiderListesi as Veri, type PlanliGiderSatiri,
  type PlanliGiderTakvimi,
} from '../../api/uclar/planliGider';
import { para } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { useAntet } from '../stokIcmal/stokIcmalOrtak';
import { ayKisa, ayUzun, cubukBoyu, durumRozeti, gunT, odenecekDonem } from './planliGiderOrtak';
import { PLANLI_GIDER_STILI } from './planliGiderStil';

/**
 * PLANLI GİDERLER `/planli-gider` (1177) - mockup Ekranlar/ERP/planli_gider.html.
 *
 * Kira, vergi, abonelik, aidat gibi faturası önceden gelmeyen TEKRARLAYAN giderlerin tanım listesi;
 * Nakit Akış İcmali'nin "Planlı" çıkışları buradan gelir. Özet şeridi, tutarlar, dönem durumu ve
 * 12 aylık takvim SUNUCUDA hesaplanır (PlanliGiderUclari) - ekran toplamaz, süzmez.
 *
 * Kart kendi ekran sekmesinde açılır (kart sekmesi deseni): "Yeni" / çift tık / "Aç" -> /planli-gider/{id}.
 * Dönemler sekmesi seçili kaydın KARTINDADIR (mockup kararı), liste yalnız Liste ve Takvim'i taşır.
 */
export const PLANLI_GIDER_KAYNAGI = 'planli-gider';

type Cip = 'aktif' | 'buay' | 'gecikmis' | 'degisken' | 'hesaplanan' | 'dovizli' | 'bitiyor' | 'pasif' | 'tumu';
const CIPLER: [Cip, string][] = [
  ['aktif', 'Aktif'], ['buay', 'Bu ay'], ['gecikmis', 'Gecikmiş'], ['degisken', 'Değişken tutarlı'],
  ['hesaplanan', 'Hesaplanan (KDV / SGK)'], ['dovizli', 'Dövizli'], ['bitiyor', 'Bitiyor (90 gün)'], ['pasif', 'Pasif'], ['tumu', 'Tümü'],
];
const cipSuzgeci = (c: Cip): Pick<PlanliGiderListeSuzgeci, 'durum' | 'cip'> =>
  c === 'pasif' ? { durum: 'pasif' } : c === 'tumu' ? { durum: 'tumu' } : c === 'aktif' ? { durum: 'aktif' } : { durum: 'aktif', cip: c };

const tl = (n: number) => para.format(n);
const tam = (n: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: 0 });
const yuzde = (n: number | null | undefined) => (n == null ? '—' : `%${n.toLocaleString('tr-TR', { maximumFractionDigits: 1 })}`);
const isaretliYuzde = (n: number | null | undefined) => (n == null ? '—' : `${n > 0 ? '+' : n < 0 ? '−' : ''}%${Math.abs(n).toLocaleString('tr-TR', { maximumFractionDigits: 1 })}`);
const dovizli = (s: { tutar: number; doviz: string }) => (s.doviz && s.doviz !== 'TL' && s.doviz !== 'TRY' ? `${s.doviz} ${tl(s.tutar)}` : tl(s.tutar));

/** Kart / kasa işlemi kartını kendi ekran sekmesinde açar (kart sekmesi deseni). */
export function usePlanliKartAc() {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  return useCallback((yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) }, [ekranSekmesi, git]);
}

/**
 * "Ödeme Oluştur" (listeden ve karttan): hedef dönem verilmezse kartın ilk ödenecek dönemi
 * (gecikmiş varsa o). Sunucu TASLAK tediye açar; kasa işlemi kartı yeni sekmede açılır.
 */
export async function odemeOlustur(id: number, kartAc: (yol: string) => void, vade?: string) {
  let hedef = vade;
  if (!hedef) {
    const k = await u.planliGiderKart(id);
    const d = odenecekDonem(k.donemler);
    if (!d) { mesaj('Ödenecek dönem yok (bütün dönemler eşleşmiş ya da atlanmış).'); return false }
    hedef = d.vade;
  }
  const y = await u.planliGiderOdeme(id, hedef);
  if (y.mesaj) mesaj(y.mesaj);
  if (y.kasaIslemId) kartAc(`/kasa-islem/${y.kasaIslemId}`);
  return true;
}

export function PlanliGiderListesi() {
  const git = useNavigate();
  const kartAc = usePlanliKartAc();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const [gorunum, setGorunum] = useState<'liste' | 'takvim'>('liste');
  const [cip, setCip] = useState<Cip>('aktif');
  const [kategori, setKategori] = useState(0);
  const [hesap, setHesap] = useState(0);
  const [araKutu, setAraKutu] = useState('');
  const [ara, setAra] = useState('');
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [seciliId, setSeciliId] = useState(0);
  const [tazele, setTazele] = useState(0);
  const [mesgul, setMesgul] = useState(false);

  // ARAMA DEBOUNCE'LU (350 ms, liste kuralı) - arama sunucuda.
  useEffect(() => { const t = setTimeout(() => setAra(araKutu), 350); return () => clearTimeout(t) }, [araKutu]);

  useEffect(() => {
    let iptal = false;
    setYukleniyor(true); setHata('');
    u.planliGiderListe({ ...cipSuzgeci(cip), kategori, hesap, ara })
      .then(v => { if (!iptal) { setVeri(v); setSeciliId(s => (v.satirlar.some(r => r.id === s) ? s : v.satirlar[0]?.id ?? 0)) } })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) })
      .then(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [cip, kategori, hesap, ara, tazele]);

  // Başka sekmede (kart) kaydedilince liste tazelenir.
  useEffect(() => {
    const dinle = (e: Event) => { if ((e as CustomEvent<string>).detail === PLANLI_GIDER_KAYNAGI) setTazele(n => n + 1) };
    window.addEventListener(LISTE_TAZELE_OLAYI, dinle);
    return () => window.removeEventListener(LISTE_TAZELE_OLAYI, dinle);
  }, []);

  const secili = veri?.satirlar.find(s => s.id === seciliId) ?? null;
  const yetki = veri?.yetkiler;
  const o = veri?.ozet;

  const islem = async (f: () => Promise<unknown>) => {
    setMesgul(true);
    try { await f() } catch (h) { mesaj(hataMetni(h)) } finally { setMesgul(false) }
  };
  const kopyala = () => secili && islem(async () => {
    if (!await onay(`"${secili.ad}" kopyalansın mı? (yenileme: yeni dönem, yeni tutar)`)) return;
    const y = await u.planliGiderKopyala(secili.id);
    setTazele(n => n + 1);
    kartAc(`/planli-gider/${y.id}`);
  });
  const eslestir = () => islem(async () => {
    const y = await u.planliGiderEslestir();
    mesaj(y.eslesen ? `${y.eslesen} dönem otomatik eşleşti (tek aday).` : 'Otomatik eşleşecek tek adaylı dönem bulunamadı - öneriler kartın Dönemler sekmesinde.');
    setTazele(n => n + 1);
  });

  return (
    <div className="sahne">
      <style>{PLANLI_GIDER_STILI + hastaIcmalStili}</style>
      <div className="pg">
        <div className="pg-gor">
          <span className={gorunum === 'liste' ? 'on' : ''} onClick={() => setGorunum('liste')}>📋 Liste</span>
          <span className={gorunum === 'takvim' ? 'on' : ''} onClick={() => setGorunum('takvim')}>📆 Takvim (12 ay)</span>
        </div>

        {gorunum === 'liste' ? (<>
          <div className="pg-arac">
            {yetki?.ekle && <button type="button" className="d bir" onClick={() => kartAc('/planli-gider/yeni')}>＋ Yeni Planlı Gider</button>}
            <button type="button" className="d" disabled={!secili} onClick={() => secili && kartAc(`/planli-gider/${secili.id}`)}>📝 Aç</button>
            {yetki?.ekle && <button type="button" className="d" disabled={!secili || mesgul} onClick={() => void kopyala()}>⧉ Kopyala</button>}
            <span className="pg-sepv" />
            {yetki?.odeme && <button type="button" className="d" disabled={!secili || mesgul || secili.durum !== 1}
              onClick={() => secili && void islem(() => odemeOlustur(secili.id, kartAc))}>💳 Ödeme Oluştur</button>}
            {yetki?.degistir && <button type="button" className="d" disabled={mesgul} title="Tek adaylı dönemleri otomatik eşleştirir"
              onClick={() => void eslestir()}>🔗 Eşleştir</button>}
            <span className="pg-sepv" />
            <button type="button" className="d" onClick={() => git('/nakit-akis-icmali')}>📊 Nakit Akış İcmali</button>
            <CiktiMenusu etiket="Planlı Giderler" dosyaAdi={`Planlı Giderler ${new Date().toISOString().slice(0, 10)}`} devre={!veri}>
              {veri && <ListeA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
            </CiktiMenusu>
            <span className="pg-sp" />
            <label className="pg-alan"><span>Ödeme hesabı</span>
              <select value={hesap} onChange={e => setHesap(Number(e.target.value))}>
                <option value={0}>Tümü</option>
                {(veri?.secim.hesaplar ?? []).map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
              </select></label>
            <label className="pg-alan"><span>Kategori</span>
              <select value={kategori} onChange={e => setKategori(Number(e.target.value))}>
                <option value={0}>Tümü</option>
                {(veri?.secim.kategoriler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
              </select></label>
            <label className="pg-alan"><span>Ara</span>
              <input type="search" style={{ minWidth: 180 }} value={araKutu} placeholder="kira, elektrik, SGK, tedarikçi…"
                     onChange={e => setAraKutu(e.target.value)} /></label>
          </div>

          {hata && <div className="hata-kutusu">{hata}</div>}

          {o && (
            <div className="pg-ozet">
              <div><div className="pg-ob">Aylık planlı gider</div><div className="pg-od">{tam(o.aylik)} ₺</div>
                <div className="pg-ox">{veri!.toplam.aktif} aktif tanım · yıllık / 3 aylık aya bölünmüş</div></div>
              <div><div className="pg-ob">Önümüzdeki 30 gün</div><div className="pg-od">{tam(o.sonraki30)} ₺</div>
                <div className="pg-ox">{o.sonraki30Donem} dönem{o.enBuyuk ? ` · en büyüğü ${o.enBuyuk.ad} ${tam(o.enBuyuk.tutar)}` : ''}</div></div>
              <div><div className="pg-ob">Gecikmiş</div><div className={'pg-od' + (o.gecikmis ? ' pg-borc' : '')}>{tam(o.gecikmis)} ₺</div>
                <div className="pg-ox">{o.gecikmisDonem} dönem · ödeme eşleşmedi</div></div>
              <div><div className="pg-ob">Tahmini (değişken)</div><div className="pg-od">{yuzde(o.tahminiPay)}</div>
                <div className="pg-ox">tutarı tahminle gelen kısım</div></div>
              <div><div className="pg-ob">Bu ay gerçekleşen</div>
                <div className="pg-od">{o.buAyPlan ? yuzde(Math.round((o.buAyOdenen / o.buAyPlan) * 100)) : '—'}</div>
                <div className="pg-ox">{tam(o.buAyOdenen)} / {tam(o.buAyPlan)} · {o.buAyOdenenTanim} / {o.buAyTanim} ödendi</div></div>
              <div><div className="pg-ob">Plan − gerçek (6 ay)</div><div className="pg-od">{isaretliYuzde(o.planGercekFark6Ay)}</div>
                <div className="pg-ox">{o.planGercekFark6Ay == null ? 'eşleşmiş dönem yok' : o.planGercekFark6Ay > 0 ? 'gerçek plandan yüksek' : o.planGercekFark6Ay < 0 ? 'gerçek plandan düşük' : 'fark yok'}</div></div>
            </div>
          )}

          <div className="pg-govde">
            <div className="pg-liste">
              <div className="pg-cipler">
                {CIPLER.map(([k, ad]) => (
                  <span key={k} className={'pg-cip' + (cip === k ? ' on' : '')} onClick={() => setCip(k)}>
                    {ad}{k === 'gecikmis' && o?.gecikmisDonem ? ` (${o.gecikmisDonem})` : ''}
                  </span>
                ))}
                <span className="pg-sp" />
                {yukleniyor && <span className="pg-soluk">yükleniyor…</span>}
              </div>
              <table className="pg-dg">
                <thead><tr><th>Gider</th><th>Kategori</th><th>Periyot · gün</th><th className="pg-sag">Tutar</th><th>Tutar türü</th>
                  <th>Ödeme</th><th>Sonraki</th><th>Bu dönem</th></tr></thead>
                <tbody>
                  {(veri?.satirlar ?? []).map(s => (
                    <Satir key={s.id} s={s} secili={s.id === seciliId} onSec={() => setSeciliId(s.id)}
                           onAc={() => kartAc(`/planli-gider/${s.id}`)} />
                  ))}
                  {veri && veri.satirlar.length === 0 && (
                    <tr><td colSpan={8} className="pg-bos">
                      {cip === 'aktif' && !ara && !kategori && !hesap
                        ? 'Planlı gider tanımı yok. Kira, vergi, abonelik gibi tekrarlayan giderleri tanımlayın - Nakit Akış İcmali "Planlı" çıkışlarını buradan alır.'
                        : 'Süzgece uyan tanım yok.'}
                    </td></tr>
                  )}
                </tbody>
                {veri && (
                  <tfoot><tr><td colSpan={3}>{veri.toplam.aktif} aktif · {veri.toplam.pasif} pasif</td>
                    <td className="pg-sag">{tl(veri.toplam.aylik)} / ay</td>
                    <td colSpan={4}>TL karşılığı · yıllık / 3 aylık tanımlar aya bölünmüş · dövizli bugünkü kurla</td></tr></tfoot>
                )}
              </table>
              <div className="pg-altsatir">Satıra çift tık = kart<span className="pg-sp" />Hesap sunucuda · ekran toplamaz</div>
            </div>
            <OnizlemePaneli satir={secili} tazele={tazele} />
          </div>
        </>) : <TakvimGorunumu />}

        <div className="pg-altsatir">Planlı gider kayıt değildir: kasa / banka hareketi ya da fatura oluşturmaz, yalnız beklentiyi tutar · Nakit Akış İcmali'nin "Planlı" satırlarının kaynağı</div>
      </div>
    </div>
  );
}

function Satir({ s, secili, onSec, onAc }: { s: PlanliGiderSatiri; secili: boolean; onSec(): void; onAc(): void }) {
  const pasif = s.durum !== 1;
  const bd = s.buDonem;
  const rz = pasif ? durumRozeti('pasif') : bd ? durumRozeti(bd.durum, bd.gun) : null;
  const odendiMi = bd && (bd.durum === 'odendi' || bd.durum === 'erken' || bd.durum === 'gec');
  return (
    <tr className={(secili ? 'sec' : '') + (pasif ? ' pasif' : '')} onClick={onSec} onDoubleClick={onAc}>
      <td><b>{s.ad}</b><small>{[s.taraf, s.masraf && `masraf ${s.masraf}`].filter(Boolean).join(' · ')}</small></td>
      <td>{s.kategori}</td>
      <td>{s.periyotMetni}{s.kalanDonem != null && <> · <b>{s.kalanDonem} kaldı</b></>}</td>
      <td className="pg-sag">{dovizli(s)}
        <small>{s.doviz && s.doviz !== 'TL' && s.doviz !== 'TRY' ? `≈ ${tam(s.tutarTl)} ₺ bugünkü kur`
          : s.kdvOran ? `${tam(s.kdvHaric)} + KDV %${s.kdvOran}` : s.tahmini ? s.tutarTurAdi : ''}</small></td>
      <td><span className={'pg-rz' + (s.tahmini ? (s.tutarTur === 4 ? ' mavi' : ' sari') : '')}>{s.tutarTurAdi}</span>
        {s.artisRozet && <> <span className="pg-rz mavi">{s.artisRozet}</span></>}</td>
      <td>{[s.hesap, s.yontem].filter(Boolean).join(' · ') || <span className="pg-soluk">—</span>}</td>
      <td>{s.sonraki ? gunT(s.sonraki) : '—'}</td>
      <td>{rz ? <span className={'pg-rz ' + rz.renk}>{odendiMi && bd?.tarih ? `${rz.ad} ${gunT(bd.tarih).slice(0, 5)}` : rz.ad}</span>
               : <span className="pg-soluk">—</span>}
        {bd?.not && <small>{bd.not}</small>}</td>
    </tr>
  );
}

/** Sağ panel: seçili tanımın önizlemesi (son 6 dönem + sonraki ödemeler kartın sunucu yanıtından). */
function OnizlemePaneli({ satir, tazele }: { satir: PlanliGiderSatiri | null; tazele: number }) {
  const [kart, setKart] = useState<PlanliGiderKarti | null>(null);
  const istenen = useRef(0);
  const id = satir?.id ?? 0;
  useEffect(() => {
    setKart(null);
    if (!id) return;
    istenen.current = id;
    // Ok tuşu / tıklama ile hızlı gezinmede her satıra istek atılmasın.
    const t = setTimeout(() => {
      u.planliGiderKart(id).then(k => { if (istenen.current === id) setKart(k) }).catch(() => { if (istenen.current === id) setKart(null) });
    }, 250);
    return () => clearTimeout(t);
  }, [id, tazele]);
  if (!satir) return <div className="pg-yan"><div className="pg-soluk">Önizleme için listeden bir tanım seçin.</div></div>;
  const k = kart?.kart;
  const gecmis = (kart?.donemler ?? []).filter(d => d.eslesen || d.durum === 'atlandi' || d.durum === 'gecikti').slice(-6);
  return (
    <div className="pg-yan">
      <h5>{satir.ad} — önizleme</h5>
      <div className="pg-kutu">
        <div className="pg-sat"><span>Cari</span><b>{satir.taraf || '—'}</b></div>
        <div className="pg-sat"><span>Masraf kalemi</span><b>{satir.masraf || '—'}</b></div>
        <div className="pg-sat"><span>Tutar</span><b>{kart ? `${tl(kart.ozet.kdvHaric)}${kart.ozet.kdv ? ` + KDV ${tl(kart.ozet.kdv)}` : ''}${kart.ozet.stopaj ? ` − stopaj ${tl(kart.ozet.stopaj)}` : ''} = ${tl(kart.ozet.donemTutari)}` : dovizli(satir)}</b></div>
        <div className="pg-sat"><span>Takvim</span><b>{satir.periyotMetni}</b></div>
        {k && <div className="pg-sat"><span>Geçerlilik</span><b>{gunT(k.baslangic)} – {k.bitis ? gunT(k.bitis) : 'süresiz'}</b></div>}
        {satir.artisRozet && <div className="pg-sat"><span>Artış</span><b>{satir.artisRozet}</b></div>}
        <div className="pg-sat"><span>Ödeme</span><b>{[satir.hesap, satir.yontem, k?.hatirlatmaGun ? `${k.hatirlatmaGun} gün önce hatırlat` : ''].filter(Boolean).join(' · ') || '—'}</b></div>
      </div>
      <h5>Son {gecmis.length || 6} dönem</h5>
      <div className="pg-kutu">
        {!kart && <span className="pg-soluk">yükleniyor…</span>}
        {kart && gecmis.length === 0 && <span className="pg-soluk">Gerçekleşmiş dönem yok.</span>}
        {gecmis.map(d => {
          const r = durumRozeti(d.durum, d.gun);
          return <div key={d.vade} className="pg-sat"><span>{ayUzun(d.vade)}</span>
            <b><span className={'pg-rz ' + r.renk}>{r.ad}{d.odemeTarihi ? ` ${gunT(d.odemeTarihi).slice(0, 5)}` : ''}</span> {tam(d.gercek ?? d.plan)}</b></div>;
        })}
      </div>
      {kart && kart.onizleme.tutarlar.length > 0 && (<>
        <h5>Nakit akışa etkisi</h5>
        <div className="pg-kutu">
          <div className="pg-onizle" style={{ marginTop: 0 }}>
            {kart.onizleme.tutarlar.slice(0, 12).map(t => (
              <span key={t.vade} className={t.artis ? 'k' : ''}>{ayKisa(t.vade)} {tam(t.tutar)}</span>))}
          </div>
          <span className="pg-soluk">Nakit Akış İcmali'nde "Planlı: {satir.ad}" satırı{kart.ozet.sonraki ? `, sonraki çıkış ${gunT(kart.ozet.sonraki.tarih)}` : ''}.</span>
        </div>
      </>)}
    </div>
  );
}

/** TAKVİM (12 ay): sunucunun aylık toplamları - çubuk (sabit / tahmini / hesaplanan) + kırılım tablosu. */
function TakvimGorunumu() {
  const git = useNavigate();
  const [kirilim, setKirilim] = useState<'toplam' | 'kategori' | 'hesap'>('toplam');
  const [veri, setVeri] = useState<PlanliGiderTakvimi | null>(null);
  const [hata, setHata] = useState('');
  const gorunum = kirilim === 'hesap' ? 'hesap' : 'kategori';
  useEffect(() => {
    let iptal = false;
    setHata('');
    u.planliGiderTakvim(12, gorunum).then(v => { if (!iptal) setVeri(v) }).catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [gorunum]);
  const enBuyuk = Math.max(0, ...(veri?.aylar ?? []).map(a => a.toplam));
  return (<>
    <div className="pg-arac">
      <div className="pg-alan"><span>Görünüm</span>
        <div className="pg-radyo">
          {([['toplam', 'Aylık toplam'], ['kategori', 'Kategori'], ['hesap', 'Ödeme hesabı']] as const).map(([k, ad]) => (
            <span key={k} className={kirilim === k ? 'on' : ''} onClick={() => setKirilim(k)}>{ad}</span>))}
        </div></div>
      <span className="pg-sp" />
      <button type="button" className="d" onClick={() => git('/nakit-akis-icmali')}>📊 Nakit Akış İcmali'nde aç</button>
    </div>
    {hata && <div className="hata-kutusu">{hata}</div>}
    <div className="pg-ic">
      <div className="pg-grp"><h4>Önümüzdeki 12 ay <span className="pg-rz">mavi sabit · sarı tahmini · gri hesaplanan</span></h4><div className="pg-gi">
        <div className="pg-aylar">
          {(veri?.aylar ?? []).map(a => (
            <div key={a.ay} title={`${ayUzun(a.ay)}: ${tl(a.toplam)}`}>
              <i className="t" style={{ height: cubukBoyu(a.tahmini, enBuyuk, 96) }} />
              <i className="h" style={{ height: cubukBoyu(a.hesaplanan, enBuyuk, 96) }} />
              <i className="s" style={{ height: cubukBoyu(a.sabit, enBuyuk, 96) }} />
              {ayKisa(a.ay)}
            </div>))}
        </div>
      </div></div>
      <table className="pg-dg">
        <thead><tr><th>Ay</th>
          {kirilim === 'toplam'
            ? <><th className="pg-sag">Sabit</th><th className="pg-sag">Tahmini</th><th className="pg-sag">Hesaplanan</th></>
            : (veri?.kolonlar ?? []).map(k => <th key={k.anahtar} className="pg-sag">{k.ad}</th>)}
          <th className="pg-sag">Toplam</th><th className="pg-sag">Tahmini payı</th></tr></thead>
        <tbody>
          {(veri?.aylar ?? []).map(a => (
            <tr key={a.ay}><td>{ayUzun(a.ay)}</td>
              {kirilim === 'toplam'
                ? <><td className="pg-sag">{tam(a.sabit)}</td><td className="pg-sag">{tam(a.tahmini)}</td><td className="pg-sag">{tam(a.hesaplanan)}</td></>
                : (veri?.kolonlar ?? []).map(k => <td key={k.anahtar} className="pg-sag">{a.kirilim[k.anahtar] ? tam(a.kirilim[k.anahtar]) : '—'}</td>)}
              <td className="pg-sag"><b>{tam(a.toplam)}</b></td>
              <td className="pg-sag">{a.toplam ? yuzde(Math.round(((a.tahmini + a.hesaplanan) / a.toplam) * 100)) : '—'}</td></tr>))}
          {veri && veri.aylar.length === 0 && <tr><td colSpan={9} className="pg-bos">Önümüzdeki 12 ayda planlı gider yok.</td></tr>}
        </tbody>
      </table>
      <div className="pg-ipucu">Vergi / SGK'nın KDV kısmı KDV İcmali'nin son dönem ödenecek'i — gelecek aylarda aynı tutarla tekrar edilir (tahmini).</div>
    </div>
  </>);
}

/** A4 liste çıktısı (ortak Çıktı menüsü): ekrandaki satırlar. */
function ListeA4({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>PLANLI GİDERLER</h3>
      <div className="a4-hasta">
        <span>Aylık planlı gider: <b>{tl(v.ozet.aylik)} ₺</b></span>
        <span>Önümüzdeki 30 gün: {tl(v.ozet.sonraki30)} ₺ · {v.ozet.sonraki30Donem} dönem</span>
        <span>Gecikmiş: {tl(v.ozet.gecikmis)} ₺ · {v.ozet.gecikmisDonem} dönem</span>
        <span>{v.toplam.aktif} aktif · {v.toplam.pasif} pasif</span>
      </div>
      <table className="a4-t">
        <thead><tr><th>Gider</th><th>Cari / Masraf</th><th>Kategori</th><th>Periyot</th><th>Tutar</th><th>Tür</th><th>Sonraki</th><th>Bu dönem</th></tr></thead>
        <tbody>
          {v.satirlar.map(s => (
            <tr key={s.id}><td>{s.ad}</td><td>{[s.taraf, s.masraf].filter(Boolean).join(' · ')}</td><td>{s.kategori}</td><td>{s.periyotMetni}</td>
              <td style={{ textAlign: 'right' }}>{dovizli(s)}</td><td>{s.tutarTurAdi}</td><td>{s.sonraki ? gunT(s.sonraki) : '—'}</td>
              <td>{s.durum !== 1 ? 'Pasif' : s.buDonem ? durumRozeti(s.buDonem.durum, s.buDonem.gun).ad : '—'}</td></tr>))}
        </tbody>
      </table>
    </div>
  );
}

export default PlanliGiderListesi;
