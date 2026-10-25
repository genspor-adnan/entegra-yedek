import { Fragment, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import {
  musteriRiskIcmalUclari, type MusteriRiskIcmali as Veri, type RiskDurumu, type RiskMusteri, type Teminat, type TeminatYazma,
} from '../../api/uclar/musteriRiskIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { onay } from '../../bilesenler/mesaj';
import { Modal } from '../../bilesenler/Modal';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { EkranA4, TICARI_ICMAL_STILI } from '../ticariIcmal/ticariIcmalOrtak';
import { FINANS_ICMAL_STILI, useCariKarti } from './finansIcmalOrtak';

/**
 * MÜŞTERİ RİSK / LİMİT İCMALİ `/musteri-risk-icmali` - mockup Ekranlar/İcmal/musteri_risk_icmali.html (kararlar 25.10.2026).
 * "Kime ne kadar açığız, kim limitini aştı, kime mal göndermeye devam etmeliyiz?" Risk = açık bakiye + portföy çek +
 * faturasız irsaliye + açık sipariş; her bileşen kendi icmalinin kuralıyla, SUNUCUDA (MusteriRiskIcmalUclari).
 * Ekran toplamaz, yalnız gösterir. Limit / bloke / teminat değişikliği `cari.risk_limit` yetkisiyle, neden zorunlu, loglu.
 * Blokeyi icmal KOYMAZ, önerir. Hatırlatma gönderimi yok (carilere ileti şablonu / mekanizması henüz yok).
 */
type Sekme = 'risk' | 'limit' | 'vade' | 'cek' | 'odeme' | 'yogun' | 'bloke' | 'a4';
type Pencere = { tur: 'limit' | 'bloke' | 'teminat'; m: RiskMusteri } | null;

const DURUM_ROZET: Record<RiskDurumu, [string, string]> = {
  tanimsiz: ['pas', 'tanımsız'], kurYok: ['sari', 'kur yok'], asim: ['kir', 'aşım'], yaklasiyor: ['sari', 'yaklaşıyor'], uygun: ['ok', 'uygun'],
};
const SKOR_ROZET: Record<string, string> = { A: 'ok', B: 'mavi', C: 'sari', D: 'kir' };
const ONERI_ROZET: Record<string, string> = { blokele: 'kir', kalsin: 'kir', uyar: 'sari', kaldir: 'ok' };
const EGILIM: Record<string, [string, string]> = { iyilesiyor: ['↗', 'si-yesil'], kotulesiyor: ['↘', 'kir'], sabit: ['→', ''], '': ['—', 'ki-soluk'] };
const TEMINAT_TURLERI: [number, string][] = [[1, 'Teminat mektubu'], [2, 'İpotek'], [3, 'Çek / senet'], [4, 'Nakit'], [9, 'Diğer']];
const DOVIZLER = ['TL', 'USD', 'EUR', 'GBP', 'CHF', 'JPY'];

const yz = (n: number | null | undefined) => (n == null ? '—' : `%${n.toLocaleString('tr-TR', { maximumFractionDigits: 1 })}`);
const gun = (n: number | null | undefined) => (n == null ? '—' : `${Math.round(n)} gün`);
const kisa = (n: number) => (Math.abs(n) < 0.005 ? '—' : tl(n));
const limitMetni = (limit: number | undefined, doviz: string) =>
  limit == null ? 'tanımsız' : `${tl(limit)}${doviz && doviz !== 'TL' ? ' ' + doviz : ''}`;

export function MusteriRiskIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici, yetki } = useOturum();
  const antet = useAntet();
  const cariKarti = useCariKarti();
  const sube = Number(arama.get('sube') ?? 0);
  const temsilci = Number(arama.get('temsilci') ?? 0);
  const grup = arama.get('grup') ?? '';
  const siparisHaric = arama.get('siparis') === '0';
  const cekHaric = arama.get('cek') === '0';
  const tanimsizGizle = arama.get('tanimsiz') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [surum, setSurum] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('risk');
  const [ara, setAra] = useState('');
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [seciliId, setSeciliId] = useState(0);
  const [pencere, setPencere] = useState<Pencere>(null);

  useEffect(() => {
    let iptal = false;
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams();
    if (sube) q.set('sube', String(sube));
    if (temsilci) q.set('temsilci', String(temsilci));
    if (grup) q.set('grup', grup);
    if (siparisHaric) q.set('siparis', '0');
    if (cekHaric) q.set('cek', '0');
    if (tanimsizGizle) q.set('tanimsiz', '1');
    musteriRiskIcmalUclari.musteriRiskIcmali(q)
      .then(v => { if (!iptal) setVeri(v) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) })
      .finally(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [sube, temsilci, grup, siparisHaric, cekHaric, tanimsizGizle, surum]);

  const musteriler = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return (veri?.musteriler ?? []).filter(m => !q || m.ad.toLocaleLowerCase('tr').includes(q) || m.kod.toLocaleLowerCase('tr').includes(q));
  }, [veri, ara]);
  const secili = veri?.musteriler.find(m => m.id === seciliId) ?? null;
  const o = veri?.ozet;
  const yetkili = !!veri?.yetkiler.limit;
  const cevir = (id: number) => setAcik(a => { const n = new Set(a); if (n.has(id)) n.delete(id); else n.add(id); return n });
  const ekstreAc = (id: number) => { if (id) git(`/ekstre?tur=cari&id=${id}`) };
  const tazele = (metin: string) => { setBilgi(metin); setPencere(null); setSurum(s => s + 1) };
  const ad = (id: number, metin: string) => <span className="lnk" onClick={e => { e.stopPropagation(); cariKarti(id) }}>{metin}</span>;
  const sec = (id: number) => setSeciliId(id);
  const a4 = veri && <RiskA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + FINANS_ICMAL_STILI + TICARI_ICMAL_STILI + MR_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Müşteri Risk / Limit İcmali</h1><span className="yol">Finans › İcmaller › Müşteri Risk / Limit İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Risk İcmali" dosyaAdi={`Müşteri Risk İcmali ${veri?.tarih?.slice(0, 10) ?? ''}`} devre={!veri}>{a4}</CiktiMenusu>
        <span className="sepv" />
        <button disabled={!secili} onClick={() => secili && cariKarti(secili.id)} title={secili?.ad ?? 'Bir müşteri seçin'}>👤 Cari kartı</button>
        <button disabled={!secili} onClick={() => secili && ekstreAc(secili.id)}>📄 Ekstre</button>
        {yetkili && <>
          <button disabled={!secili} onClick={() => secili && setPencere({ tur: 'limit', m: secili })}>✎ Limit güncelle…</button>
          <button disabled={!secili} onClick={() => secili && setPencere({ tur: 'bloke', m: secili })}>
            ⛔ {secili?.sevkBlokesi ? 'Sevk blokesini kaldır…' : 'Sevk blokesi koy…'}</button>
        </>}
        <button disabled={!secili} onClick={() => secili && setPencere({ tur: 'teminat', m: secili })}>🛡 Teminatlar…</button>
        <span className="sp" />
        {yetki('finans.alacak_yaslandirma') && <button onClick={() => git('/alacak-yaslandirma')}>⏳ Alacak Yaşlandırma</button>}
        {yetki('finans.cari_icmali') && <button onClick={() => git('/cari-icmali')}>📊 Cari İcmali</button>}
        {yetki('finans.cek_senet_icmali') && <button onClick={() => git('/cek-senet-icmali')}>📃 Çek / Senet İcmali</button>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu" onClick={() => setBilgi('')}>{bilgi}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Tarih: <b>{veri ? tarihT(veri.tarih) : '…'}</b></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">👤 Temsilci:
          <select value={temsilci} onChange={e => degistir({ temsilci: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.temsilciler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🏷 Risk grubu:
          <select value={grup} onChange={e => degistir({ grup: e.target.value })}>
            <option value="">Tümü</option>
            {(veri?.secim.riskGruplari ?? []).map(g => <option key={g} value={g}>{g}</option>)}
          </select></div>
        <div className="sel">💱 Para birimi: <b>TL karşılığı (bugünkü kur)</b></div>
        <label className="fi-chk"><input type="checkbox" checked={!siparisHaric} onChange={e => degistir({ siparis: e.target.checked ? '' : '0' })} /> Açık siparişler riske dahil</label>
        <label className="fi-chk"><input type="checkbox" checked={!cekHaric} onChange={e => degistir({ cek: e.target.checked ? '' : '0' })} /> Portföydeki müşteri çekleri dahil</label>
        <label className="fi-chk"><input type="checkbox" checked={tanimsizGizle} onChange={e => degistir({ tanimsiz: e.target.checked ? '1' : '' })} /> Limiti tanımsızları gizle</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.limitTanimsiz > 0 && <span className="bo-rz pas">Limiti tanımsız aktif müşteri: {o.limitTanimsiz}</span>}
        {veri && <span className={'bo-rz ' + (veri.davranis === 'engelle' ? 'kir' : 'mavi')}
          title="Genel Ayarlar › satis.limit_davranis - satış siparişi / irsaliyesi / faturası kaydında">
          satış belgesinde: {veri.davranis === 'engelle' ? 'engelle' : 'uyar'}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Toplam Risk" deg={`${tl(o.toplamRisk)} ₺`} alt={`${o.musteri} aktif müşteri`} />
          <Kutu bas="Açık Bakiye" deg={`${tl(o.acikBakiye)} ₺`} alt="cari borç (alacağımız)" />
          <Kutu bas="Vadesi Geçen" deg={`${tl(o.vadesiGecen)} ₺`} alt={`${yz(o.vadesiGecenYuzde)} · ${o.vadesiGecenMusteri} müşteri`} sinif={o.vadesiGecen > 0 ? 'teh' : ''} />
          <Kutu bas="Portföydeki Çek" deg={veri.cekDahil ? `${tl(o.cek)} ₺` : 'dahil değil'} alt={`${o.cekAdet} evrak · vadesi gelmemiş`} />
          <Kutu bas="Faturasız İrs. + Açık Sipariş" deg={`${tl(o.irsaliye + o.siparis)} ₺`}
            alt={`${tl(o.irsaliye)} + ${veri.siparisDahil ? tl(o.siparis) : 'sipariş hariç'}`} />
          <Kutu bas="Limit Aşan" deg={`${o.limitAsan} müşteri`} alt={`aşım ${tl(o.asimTutar)} ₺`} sinif={o.limitAsan ? 'teh' : 'iyi'} />
          <Kutu bas="Limitin %80'i Üstü" deg={`${o.yaklasan} müşteri`} alt="yaklaşan" sinif={o.yaklasan ? 'uy' : ''} />
          <Kutu bas="İlk 10 Müşteri Payı" deg={yz(o.ilk10Pay)} alt="yoğunlaşma" sinif="mor" />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['risk', 'Risk Listesi', null], ['limit', 'Limit Aşımı', veri.limitAsimi.filter(x => x.durum === 'asim').length || null],
              ['vade', 'Vade / Yaşlandırma', null], ['cek', 'Çek Riski', o.cekRiskli || null], ['odeme', 'Ödeme Davranışı', null],
              ['yogun', 'Yoğunlaşma', null], ['bloke', 'Bloke Önerisi', o.oneri || null], ['a4', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'risk' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Müşteri adı ya da kodu…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 260 }} />
                <span className="ki-soluk">satıra tıkla: seç + bileşenler · çift tık: ekstre · ada tıkla: cari kartı</span>
              </div>
              <Kutucuk baslik="Müşteri bazında toplam risk" not="toplam risk = açık bakiye + portföy çek + faturasız irsaliye + açık sipariş">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Müşteri</th><th>Temsilci</th><th className="sag">Açık bakiye</th><th className="sag">Vadesi geçen</th>
                      <th className="sag">Portföy çek</th><th className="sag">Faturasız irs.</th><th className="sag">Açık sipariş</th>
                      <th className="sag">Toplam risk</th><th className="sag">Limit</th><th style={{ minWidth: 120 }}>Kullanım</th><th className="orta">Skor</th></tr></thead>
                    <tbody>
                      {musteriler.length === 0 && <tr><td colSpan={11} className="bos">Riskli müşteri yok.</td></tr>}
                      {musteriler.slice(0, 1000).map(m => {
                        const ac = acik.has(m.id);
                        return (
                          <Fragment key={m.id}>
                            <tr className={'ac' + (seciliId === m.id ? ' fi-sec' : '') + (m.durum === 'asim' ? ' mr-asim' : '')}
                              onClick={() => { sec(m.id); cevir(m.id) }} onDoubleClick={() => ekstreAc(m.id)}>
                              <td><span className="ok">{ac ? '▾' : '▸'}</span>{ad(m.id, m.ad)}
                                {m.sevkBlokesi && <span className="bo-rz kir mr-rz" title={m.blokeNeden}>blokeli</span>}
                                {m.limitDoviz !== 'TL' && m.limit != null && <span className="bo-rz mavi mr-rz">{m.limitDoviz}</span>}
                                {m.riskGrubu && <span className="bo-rz pas mr-rz">{m.riskGrubu}</span>}</td>
                              <td>{m.temsilci || <span className="ki-soluk">—</span>}</td>
                              <td className={'sag' + (m.bakiye < 0 ? ' kir' : '')}>{kisa(m.bakiye)}</td>
                              <td className={'sag' + (m.vadesiGecen > 0 ? ' kir' : ' ki-soluk')}>{kisa(m.vadesiGecen)}</td>
                              <td className="sag">{veri.cekDahil ? kisa(m.cek) : <span className="ki-soluk">hariç</span>}</td>
                              <td className="sag">{kisa(m.irsaliye)}</td>
                              <td className="sag">{veri.siparisDahil ? kisa(m.siparis) : <span className="ki-soluk">hariç</span>}</td>
                              <td className="sag"><b>{tl(m.toplam)}</b></td>
                              <td className="sag">{m.limit == null ? <span className="bo-rz pas">tanımsız</span> : limitMetni(m.limit, m.limitDoviz)}</td>
                              <td>{m.kullanim != null
                                ? <div className="mr-kul"><Cubuk yuzde={m.kullanim} renk={m.kullanim > 100 ? '#c0413d' : m.kullanim >= 80 ? '#c99a2e' : undefined} />
                                    <span className={m.kullanim > 100 ? 'kir' : ''}>{yz(m.kullanim)}</span></div>
                                : <span className={'bo-rz ' + DURUM_ROZET[m.durum][0]}>{DURUM_ROZET[m.durum][1]}</span>}</td>
                              <td className="orta">{m.skor ? <span className={'bo-rz ' + SKOR_ROZET[m.skor]} title={`puan ${m.skorPuan}`}>{m.skor}</span> : '—'}</td>
                            </tr>
                            {ac && (
                              <tr className="si-det"><td colSpan={11}>
                                Açık bakiye {tl(m.bakiye)} · portföy çek {tl(m.cek)} ({m.cekAdet} evrak{m.cek7Gun > 0 ? `, 7 gün içinde ${tl(m.cek7Gun)}` : ''})
                                · faturasız irsaliye {tl(m.irsaliye)} ({m.irsaliyeAdet} belge) · açık sipariş {tl(m.siparis)} ({m.siparisAdet} sipariş)
                                {m.limitTl != null && m.limitDoviz !== 'TL' && <> · limit ≈ {tl(m.limitTl)} ₺</>}
                                {m.teminatOzet && <> · teminat: {m.teminatOzet}</>}
                                {m.sevkBlokesi && <> · <b className="kir">sevk blokesi</b>{m.blokeNeden && `: ${m.blokeNeden}`}{m.blokeKim && ` (${m.blokeKim}${m.blokeAn ? ', ' + tarihT(m.blokeAn) : ''})`}</>}
                                {m.kurYok && <> · <span className="kir">bazı dövizli kalemlerin bugünkü kuru yok - işlem kuruyla</span></>}
                              </td></tr>
                            )}
                          </Fragment>
                        );
                      })}
                      <tr className="top"><td colSpan={2}>Toplam ({musteriler.length} müşteri)</td>
                        <td className="sag">{tl(musteriler.reduce((t, m) => t + m.bakiye, 0))}</td>
                        <td className="sag">{tl(musteriler.reduce((t, m) => t + m.vadesiGecen, 0))}</td>
                        <td className="sag">{veri.cekDahil ? tl(musteriler.reduce((t, m) => t + m.cek, 0)) : '—'}</td>
                        <td className="sag">{tl(musteriler.reduce((t, m) => t + m.irsaliye, 0))}</td>
                        <td className="sag">{veri.siparisDahil ? tl(musteriler.reduce((t, m) => t + m.siparis, 0)) : '—'}</td>
                        <td className="sag">{tl(musteriler.reduce((t, m) => t + m.toplam, 0))}</td><td colSpan={3} /></tr>
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Açık bakiye cari hareketlerinden (Cari İcmali ile aynı küme); portföy çek = müşteriden alınıp vadesi gelmemiş,
                  ciro edilmemiş çek / senet (Çek / Senet İcmali ile aynı); faturasız irsaliye = İrsaliye-Fatura Eşleşme kuralı; açık sipariş = Açık
                  Satır Listesi kuralı (kalanı kapatılan satır hariç). İrsaliye ve sipariş KDV hariç. Dövizli kalem bugünkü kurla. Limit tanımsız müşteri
                  "limitsiz" değildir. Skor son 12 ayın ödeme davranışından, yalnız bilgi.</div>
              </Kutucuk>
            </>}

            {sekme === 'limit' && (
              <Kutucuk baslik="Limit aşımı ve yaklaşanlar" not={`${o.limitAsan} aşan · ${o.yaklasan} yaklaşan`}>
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri</th><th className="sag">Toplam risk</th><th className="sag">Limit</th><th className="sag">Aşım</th>
                    <th className="sag">Kullanım</th><th>Teminat</th><th>Son limit değişikliği</th><th>Durum</th></tr></thead>
                  <tbody>
                    {veri.limitAsimi.length === 0 && <tr><td colSpan={8} className="bos">Limiti aşan ya da %80'ine yaklaşan müşteri yok.</td></tr>}
                    {veri.limitAsimi.map(x => (
                      <tr key={x.id} className={'ac' + (seciliId === x.id ? ' fi-sec' : '')} onClick={() => sec(x.id)} onDoubleClick={() => ekstreAc(x.id)}>
                        <td>{ad(x.id, x.ad)}</td><td className="sag">{tl(x.toplam)}</td><td className="sag">{limitMetni(x.limit, x.limitDoviz)}</td>
                        <td className={'sag' + (x.asim > 0 ? ' kir' : ' ki-soluk')}>{kisa(x.asim)}</td>
                        <td className={'sag' + ((x.kullanim ?? 0) > 100 ? ' kir' : '')}>{yz(x.kullanim)}</td>
                        <td>{x.teminatOzet || <span className="ki-soluk">—</span>}</td>
                        <td>{x.sonLimitAn ? `${tarihT(x.sonLimitAn)} · ${x.sonLimitKim ?? ''}` : <span className="ki-soluk">—</span>}</td>
                        <td><span className={'bo-rz ' + (x.durum === 'yaklasiyor' || x.teminatIcinde ? 'sari' : 'kir')}>{x.durumMetni}</span></td>
                      </tr>))}
                  </tbody>
                </table>
                <div className="fi-ipucu">Limit cari kartında (salt okunur) ve burada "Limit güncelle…" ile değişir: yetkili kullanıcı, neden zorunlu, loglu.
                  Dövizli limit kendi dövizinde, bugünkü kurla karşılaştırılır. Teminat aşımı karşılıyorsa sarı.</div>
              </Kutucuk>
            )}

            {sekme === 'vade' && (
              <Kutucuk baslik="Vade / yaşlandırma özeti (Cari İcmali ile aynı dilimler)" not="yalnız vadesi geçeni olan müşteriler">
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri</th><th className="sag">Vadesi gelmemiş</th><th className="sag">1–30</th><th className="sag">31–60</th>
                    <th className="sag">61–90</th><th className="sag">90+</th><th className="sag">Ort. gecikme</th><th>En eski</th></tr></thead>
                  <tbody>
                    {veri.yaslandirma.length === 0 && <tr><td colSpan={8} className="bos">Vadesi geçen alacak yok.</td></tr>}
                    {veri.yaslandirma.map(x => (
                      <tr key={x.id} className={'ac' + (seciliId === x.id ? ' fi-sec' : '')} onClick={() => sec(x.id)} onDoubleClick={() => ekstreAc(x.id)}>
                        <td>{ad(x.id, x.ad)}</td><td className="sag">{kisa(x.yas.gelmemis)}</td><td className="sag">{kisa(x.yas.d30)}</td>
                        <td className="sag">{kisa(x.yas.d60)}</td><td className="sag">{kisa(x.yas.d90)}</td>
                        <td className={'sag' + (x.yas.d90p > 0 ? ' kir' : '')}>{kisa(x.yas.d90p)}</td>
                        <td className="sag">{gun(x.ortGecikme)}</td><td>{tarihT(x.yas.enEskiTarih)}</td></tr>))}
                    <tr className="top"><td>Toplam</td><td className="sag">{tl(veri.yasToplam.gelmemis)}</td><td className="sag">{tl(veri.yasToplam.d30)}</td>
                      <td className="sag">{tl(veri.yasToplam.d60)}</td><td className="sag">{tl(veri.yasToplam.d90)}</td><td className="sag">{tl(veri.yasToplam.d90p)}</td>
                      <td className="sag">{gun(veri.yasToplam.ortGecikme)}</td><td /></tr>
                  </tbody>
                </table>
                <div className="fi-ipucu">Ayrıntı ve tahsilat planı için Alacak Yaşlandırma / Cari İcmali; bu sekme yalnız riske giren özet (FIFO: karşı yöndeki
                  hareket önce vadesi en eski kalemi kapatır).</div>
              </Kutucuk>
            )}

            {sekme === 'cek' && (
              <Kutucuk baslik="Müşteri çeklerinin riski" not={veri.cekDahil ? `${veri.cekRiski.length} grup` : 'çek bileşeni kapalı'}>
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri (ciranta)</th><th>Keşideci</th><th className="sag">Evrak</th><th className="sag">Tutar</th><th>Vade</th><th>Banka</th><th>Uyarı</th></tr></thead>
                  <tbody>
                    {veri.cekRiski.length === 0 && <tr><td colSpan={7} className="bos">Riske giren müşteri çeki yok.</td></tr>}
                    {veri.cekRiski.map((x, i) => (
                      <tr key={i} className={'ac' + (seciliId === x.tarafId ? ' fi-sec' : '')} onClick={() => sec(x.tarafId)}>
                        <td>{ad(x.tarafId, x.cari)}</td><td>{x.kesideci}{x.ucuncuKisi && <span className="ki-soluk"> (3. şahıs)</span>}</td>
                        <td className="sag">{x.adet}</td><td className="sag">{tl(x.tutar)}</td>
                        <td>{x.ilkVade === x.sonVade ? tarihT(x.ilkVade) : `${tarihT(x.ilkVade)} – ${tarihT(x.sonVade)}`}</td>
                        <td>{x.banka || <span className="ki-soluk">—</span>}</td>
                        <td>{x.uyarilar.length ? x.uyarilar.map((u, j) => <span key={j} className="bo-rz sari mr-rz">{u}</span>) : <span className="ki-soluk">—</span>}</td>
                      </tr>))}
                  </tbody>
                </table>
                <div className="fi-ipucu">Portföyde / tahsilde / teminatta, vadesi gelmemiş müşteri evrakı. Karşılıksız / protestolu geçmiş çek ve senet
                  hareketlerinden (keşideci adına göre); üçüncü şahıs çeki (keşideci müşteri değil) ayrıca işaretlenir.</div>
              </Kutucuk>
            )}

            {sekme === 'odeme' && (
              <Kutucuk baslik="Ödeme davranışı (son 12 ay)" not="skora göre - en riskli üstte">
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri</th><th className="sag">Fatura</th><th className="sag">Ort. vade</th><th className="sag">Ort. ödeme süresi</th>
                    <th className="sag">Ort. gecikme</th><th className="orta">Eğilim</th><th className="sag">Zamanında %</th><th className="sag">Karşılıksız</th><th className="orta">Skor</th></tr></thead>
                  <tbody>
                    {veri.odemeDavranisi.length === 0 && <tr><td colSpan={9} className="bos">Son 12 ayda satış faturası yok.</td></tr>}
                    {veri.odemeDavranisi.map(x => (
                      <tr key={x.id} className={'ac' + (seciliId === x.id ? ' fi-sec' : '')} onClick={() => sec(x.id)} onDoubleClick={() => ekstreAc(x.id)}>
                        <td>{ad(x.id, x.ad)}</td><td className="sag">{x.odeme.fatura}</td><td className="sag">{gun(x.odeme.ortVade)}</td>
                        <td className="sag">{gun(x.odeme.ortOdeme)}</td>
                        <td className={'sag' + ((x.odeme.ortGecikme ?? 0) > 30 ? ' kir' : '')}>{gun(x.odeme.ortGecikme)}</td>
                        <td className={'orta ' + EGILIM[x.odeme.egilim][1]}>{EGILIM[x.odeme.egilim][0]}</td>
                        <td className={'sag' + ((x.odeme.zamaninda ?? 100) < 60 ? ' kir' : '')}>{yz(x.odeme.zamaninda)}</td>
                        <td className={'sag' + (x.karsiliksiz12 ? ' kir' : ' ki-soluk')}>{x.karsiliksiz12}{x.karsiliksiz > x.karsiliksiz12 && <span className="ki-soluk"> / {x.karsiliksiz}</span>}</td>
                        <td className="orta">{x.skor ? <span className={'bo-rz ' + SKOR_ROZET[x.skor]} title={`puan ${x.skorPuan}`}>{x.skor}</span> : '—'}</td></tr>))}
                  </tbody>
                </table>
                <div className="fi-ipucu">Ödeme süresi FIFO ile: fatura → onu kapatan tahsilat (Cari İcmali'nin kapama kuralı); açık ve vadesi geçmiş fatura
                  gecikmeye bugüne kadar girer. Eğilim: son 90 günün gecikmesi önceki dokuz aya göre. Skor sabit ağırlıklı: zamanında % 40, gecikme 30,
                  karşılıksız (12 ay) 20, limit kullanımı 10 - A 85+, B 70+, C 50+, D altı. Yalnız bilgi; blokeyi skor değil limit / vade önerir.</div>
              </Kutucuk>
            )}

            {sekme === 'yogun' && (
              <div className="si-iki">
                <Kutucuk baslik="Yoğunlaşma - riskin ilk 10 müşteride toplanması" not={`ilk 10: ${yz(o.ilk10Pay)}`}>
                  <table className="hi-tablo">
                    <thead><tr><th className="sag">Sıra</th><th>Müşteri</th><th className="sag">Toplam risk</th><th className="sag">Pay</th><th className="sag">Kümülatif</th><th style={{ width: 120 }} /></tr></thead>
                    <tbody>
                      {veri.yogunlasma.length === 0 && <tr><td colSpan={6} className="bos">Risk yok.</td></tr>}
                      {veri.yogunlasma.map(x => (
                        <tr key={x.id} className={'ac' + (seciliId === x.id ? ' fi-sec' : '')} onClick={() => sec(x.id)}>
                          <td className="sag">{x.sira}</td><td>{ad(x.id, x.ad)}</td><td className="sag">{tl(x.toplam)}</td>
                          <td className="sag">{x.yuksek ? <span className="bo-rz sari">{yz(x.pay)}</span> : yz(x.pay)}</td>
                          <td className="sag">{yz(x.kumulatif)}</td><td><Cubuk yuzde={x.kumulatif} /></td></tr>))}
                    </tbody>
                  </table>
                  <div className="fi-ipucu">Tek müşteride %15 üstü risk sarı rozetle.</div>
                </Kutucuk>
                <Kutucuk baslik="Risk grubu toplamları" not="aynı patron, farklı cari - cari kartındaki risk grubu">
                  <table className="hi-tablo">
                    <thead><tr><th>Grup</th><th className="sag">Müşteri</th><th className="sag">Toplam risk</th><th className="sag">Limit (TL)</th><th className="sag">Aşan</th></tr></thead>
                    <tbody>
                      {veri.gruplar.length === 0 && <tr><td colSpan={5} className="bos">Risk grubu tanımlı müşteri yok.</td></tr>}
                      {veri.gruplar.map(g => (
                        <tr key={g.ad} className="ac" onClick={() => degistir({ grup: g.ad })}>
                          <td>{g.ad}</td><td className="sag">{g.musteri}</td><td className="sag">{tl(g.toplam)}</td>
                          <td className="sag">{g.limitTl != null ? tl(g.limitTl) : '—'}</td><td className={'sag' + (g.asan ? ' kir' : '')}>{g.asan}</td></tr>))}
                    </tbody>
                  </table>
                  <div className="fi-ipucu">Satıra tıkla: listeyi o gruba süz (şeritteki "Risk grubu").</div>
                </Kutucuk>
              </div>
            )}

            {sekme === 'bloke' && (
              <Kutucuk baslik="Sevk blokesi önerisi" not={`${veri.blokeOnerisi.length} müşteri`}>
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri</th><th>Neden</th><th className="sag">Toplam risk</th><th className="sag">Aşım</th><th>Mevcut</th><th>Öneri</th>{yetkili && <th />}</tr></thead>
                  <tbody>
                    {veri.blokeOnerisi.length === 0 && <tr><td colSpan={yetkili ? 7 : 6} className="bos">Öneri yok.</td></tr>}
                    {veri.blokeOnerisi.map(x => {
                      const m = veri.musteriler.find(y => y.id === x.id);
                      return (
                        <tr key={x.id} className={'ac' + (seciliId === x.id ? ' fi-sec' : '')} onClick={() => sec(x.id)}>
                          <td>{ad(x.id, x.ad)}</td><td style={{ whiteSpace: 'normal' }}>{x.nedenler.join(' · ')}</td>
                          <td className="sag">{tl(x.toplam)}</td><td className={'sag' + (x.asim > 0 ? ' kir' : ' ki-soluk')}>{kisa(x.asim)}</td>
                          <td>{x.sevkBlokesi ? <span className="bo-rz kir" title={x.blokeNeden}>blokeli</span> : <span className="bo-rz ok">açık</span>}</td>
                          <td><span className={'bo-rz ' + (ONERI_ROZET[x.oneri] ?? 'pas')}>{x.oneriAd}</span></td>
                          {yetkili && <td>{m && (x.oneri === 'blokele' || x.oneri === 'kaldir') &&
                            <button onClick={e => { e.stopPropagation(); setPencere({ tur: 'bloke', m }) }}>{x.sevkBlokesi ? 'Kaldır…' : 'Blokele…'}</button>}</td>}
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
                <div className="fi-ipucu">Blokeyi icmal KOYMAZ, önerir: "Sevk blokesi koy / kaldır" yetkili kullanıcı, neden zorunlu, loglu. Blokeli ya da limitini
                  aşan müşteriye satış belgesi (sipariş / irsaliye / fatura) kesilince Genel Ayarlar › satis.limit_davranis'a göre uyarı ya da engel
                  (şu an: {veri.davranis === 'engelle' ? 'engelle' : 'uyar'}).</div>
              </Kutucuk>
            )}

            {sekme === 'a4' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="ki-soluk si-not">{o.musteri} aktif müşteri · {o.limitTanimli} limit tanımlı · {o.blokeli} blokeli · Risk tarihi: {tarihT(veri.tarih)}
          · Hesap sunucuda, ekran toplamaz.</div>
      </>)}

      {pencere?.tur === 'limit' && <LimitPenceresi m={pencere.m} onKapat={() => setPencere(null)} onTamam={tazele} />}
      {pencere?.tur === 'bloke' && <BlokePenceresi m={pencere.m} onKapat={() => setPencere(null)} onTamam={tazele} />}
      {pencere?.tur === 'teminat' && <TeminatPenceresi m={pencere.m} yetkili={yetkili} onKapat={() => setPencere(null)}
        onDegisti={() => setSurum(s => s + 1)} />}
    </div>
  );
}

// ============================================================ pencereler ===

function LimitPenceresi({ m, onKapat, onTamam }: { m: RiskMusteri; onKapat(): void; onTamam(metin: string): void }) {
  const [limit, setLimit] = useState(m.limit != null ? String(m.limit) : '');
  const [doviz, setDoviz] = useState(m.limitDoviz || 'TL');
  const [riskGrubu, setRiskGrubu] = useState(m.riskGrubu);
  const [neden, setNeden] = useState('');
  const [hata, setHata] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const kaydet = async () => {
    const metin = limit.trim().replace(/\./g, '').replace(',', '.');
    const deger = metin === '' ? null : Number(metin);
    if (deger != null && (!Number.isFinite(deger) || deger < 0)) { setHata('Limit sayı olmalı (boş = tanımsız).'); return }
    if (neden.trim().length < 3) { setHata('Neden yazılmalı (en az 3 karakter).'); return }
    setIsliyor(true); setHata('');
    try {
      const y = await musteriRiskIcmalUclari.musteriRiskLimit({ tarafId: m.id, limit: deger, doviz, riskGrubu: riskGrubu.trim(), neden: neden.trim(), surum: m.surum });
      onTamam(y.degisti ? `${m.ad}: risk limiti güncellendi.` : `${m.ad}: değişiklik yok.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };
  return (
    <Modal baslik={`✎ Limit güncelle · ${m.ad}`} dar buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="b" disabled={isliyor} onClick={() => void kaydet()}>Kaydet</button>
        <button type="button" className="d" onClick={onKapat}>✖ Vazgeç</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="not">Toplam risk {tl(m.toplam)} ₺ · şu anki limit {limitMetni(m.limit, m.limitDoviz)}{m.kullanim != null ? ` · kullanım ${yz(m.kullanim)}` : ''}</div>
      <div className="alan"><label>Risk limiti (boş = tanımsız)</label>
        <input value={limit} onChange={e => setLimit(e.target.value)} inputMode="decimal" placeholder="tanımsız" /></div>
      <div className="alan"><label>Limit dövizi</label>
        <select value={doviz} onChange={e => setDoviz(e.target.value)}>{DOVIZLER.map(d => <option key={d} value={d}>{d}</option>)}</select></div>
      <div className="alan"><label>Risk grubu</label>
        <input value={riskGrubu} maxLength={60} onChange={e => setRiskGrubu(e.target.value)} placeholder="aynı patron, farklı cari" /></div>
      <div className="alan"><label>Neden (zorunlu)</label>
        <textarea value={neden} maxLength={300} rows={3} onChange={e => setNeden(e.target.value)} /></div>
      <div className="not">Değişiklik alan bazında loglanır (eski → yeni, neden ile). Dövizli limit kendi dövizinde, bugünkü kurla karşılaştırılır.</div>
    </Modal>
  );
}

function BlokePenceresi({ m, onKapat, onTamam }: { m: RiskMusteri; onKapat(): void; onTamam(metin: string): void }) {
  const koy = !m.sevkBlokesi;
  const [neden, setNeden] = useState('');
  const [hata, setHata] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const kaydet = async () => {
    if (neden.trim().length < 3) { setHata('Neden yazılmalı (en az 3 karakter).'); return }
    setIsliyor(true); setHata('');
    try {
      await musteriRiskIcmalUclari.musteriRiskBloke(m.id, koy, neden.trim());
      onTamam(`${m.ad}: sevk blokesi ${koy ? 'konuldu' : 'kaldırıldı'}.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };
  return (
    <Modal baslik={`⛔ ${koy ? 'Sevk blokesi koy' : 'Sevk blokesini kaldır'} · ${m.ad}`} dar buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="b" disabled={isliyor} onClick={() => void kaydet()}>{koy ? 'Blokele' : 'Blokeyi kaldır'}</button>
        <button type="button" className="d" onClick={onKapat}>✖ Vazgeç</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!koy && <div className="not">Mevcut bloke: {m.blokeNeden || '—'}{m.blokeKim && ` · ${m.blokeKim}`}{m.blokeAn && ` · ${tarihT(m.blokeAn)}`}</div>}
      {m.oneri && <div className="not">Öneri: <b>{m.oneri.ad}</b> - {m.oneri.nedenler.join(' · ')}</div>}
      <div className="alan"><label>Neden (zorunlu)</label>
        <textarea value={neden} maxLength={300} rows={3} onChange={e => setNeden(e.target.value)} /></div>
      <div className="not">{koy
        ? 'Blokeli müşteriye satış siparişi / irsaliyesi / faturası kesilince Genel Ayarlar › satis.limit_davranis\'a göre uyarı ya da engel. Loglanır.'
        : 'Kaldırma da nedeniyle loglanır.'}</div>
    </Modal>
  );
}

const bosTeminat = (tarafId: number): TeminatYazma => ({ tarafId, tur: 1, tutar: 0, doviz: 'TL', baslangic: null, bitis: null, aciklama: '' });

function TeminatPenceresi({ m, yetkili, onKapat, onDegisti }: { m: RiskMusteri; yetkili: boolean; onKapat(): void; onDegisti(): void }) {
  const [liste, setListe] = useState<Teminat[] | null>(null);
  const [hata, setHata] = useState('');
  const [duzen, setDuzen] = useState<{ id: number; g: TeminatYazma } | null>(null);
  const [tutarMetni, setTutarMetni] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const [yenile, setYenile] = useState(0);

  useEffect(() => {
    let iptal = false;
    musteriRiskIcmalUclari.musteriTeminatlari(m.id)
      .then(v => { if (!iptal) setListe(v.teminatlar) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [m.id, yenile]);

  const ac = (t: Teminat | null) => {
    setHata('');
    if (!t) { setDuzen({ id: 0, g: bosTeminat(m.id) }); setTutarMetni(''); return }
    setDuzen({ id: t.id, g: { tarafId: m.id, tur: t.tur, tutar: t.tutar, doviz: t.doviz, baslangic: t.baslangic?.slice(0, 10) ?? null,
      bitis: t.bitis?.slice(0, 10) ?? null, aciklama: t.aciklama, surum: t.surum } });
    setTutarMetni(String(t.tutar).replace('.', ','));
  };
  const alan = (d: Partial<TeminatYazma>) => setDuzen(x => (x ? { ...x, g: { ...x.g, ...d } } : x));
  const kaydet = async () => {
    if (!duzen) return;
    const tutar = Number(tutarMetni.trim().replace(/\./g, '').replace(',', '.'));
    if (!Number.isFinite(tutar) || tutar <= 0) { setHata('Tutar sıfırdan büyük olmalı.'); return }
    setIsliyor(true); setHata('');
    try {
      const g = { ...duzen.g, tutar };
      if (duzen.id) await musteriRiskIcmalUclari.musteriTeminatGuncelle(duzen.id, g);
      else await musteriRiskIcmalUclari.musteriTeminatEkle(g);
      setDuzen(null); setYenile(n => n + 1); onDegisti();
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };
  const sil = async (t: Teminat) => {
    if (!(await onay(`${t.turAdi} ${tl(t.tutar)} ${t.doviz} teminatı silinecek. Silme loglanır.`))) return;
    setIsliyor(true); setHata('');
    try {
      await musteriRiskIcmalUclari.musteriTeminatSil(t.id);
      setYenile(n => n + 1); onDegisti();
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  return (
    <Modal baslik={`🛡 Teminatlar · ${m.ad}`} buyutmeYok onKapat={onKapat}
      alt={<>
        {yetkili && !duzen && <button type="button" className="b" onClick={() => ac(null)}>＋ Teminat ekle</button>}
        <button type="button" className="d" onClick={onKapat}>✖ Kapat</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="ds-dg"><table>
        <thead><tr><th>Tür</th><th className="sag">Tutar</th><th>Başlangıç</th><th>Bitiş</th><th>Açıklama</th><th>Ekleyen</th>{yetkili && <th />}</tr></thead>
        <tbody>
          {!liste && <tr><td colSpan={7} className="not">Yükleniyor…</td></tr>}
          {liste?.length === 0 && <tr><td colSpan={7} className="not">Teminat yok.</td></tr>}
          {liste?.map(t => (
            <tr key={t.id} className={t.aktif ? undefined : 'sonuk'}>
              <td>{t.turAdi}{!t.aktif && <span className="rozet gri" style={{ marginLeft: 4 }}>geçersiz</span>}</td>
              <td className="sag">{tl(t.tutar)} {t.doviz}</td><td>{tarihT(t.baslangic)}</td><td>{t.bitis ? tarihT(t.bitis) : 'süresiz'}</td>
              <td>{t.aciklama}</td><td>{t.ekleyen}</td>
              {yetkili && <td style={{ whiteSpace: 'nowrap' }}>
                <button type="button" disabled={isliyor} onClick={() => ac(t)}>✎</button>{' '}
                <button type="button" disabled={isliyor} onClick={() => void sil(t)}>🗑</button></td>}
            </tr>))}
        </tbody>
      </table></div>
      {duzen && (
        <div className="kagrup" style={{ marginTop: 10 }}>
          <h6>{duzen.id ? 'Teminatı düzenle' : 'Yeni teminat'}</h6>
          <div className="ds-sr">
            <div className="alan"><label>Tür</label>
              <select value={duzen.g.tur} onChange={e => alan({ tur: Number(e.target.value) })}>
                {TEMINAT_TURLERI.map(([k, a]) => <option key={k} value={k}>{a}</option>)}</select></div>
            <div className="alan"><label>Tutar</label><input value={tutarMetni} inputMode="decimal" onChange={e => setTutarMetni(e.target.value)} /></div>
            <div className="alan"><label>Döviz</label>
              <select value={duzen.g.doviz} onChange={e => alan({ doviz: e.target.value })}>{DOVIZLER.map(d => <option key={d} value={d}>{d}</option>)}</select></div>
          </div>
          <div className="ds-sr">
            <div className="alan"><label>Başlangıç</label><input type="date" value={duzen.g.baslangic ?? ''} onChange={e => alan({ baslangic: e.target.value || null })} /></div>
            <div className="alan"><label>Bitiş (boş = süresiz)</label><input type="date" value={duzen.g.bitis ?? ''} onChange={e => alan({ bitis: e.target.value || null })} /></div>
          </div>
          <div className="alan"><label>Açıklama</label><input value={duzen.g.aciklama} maxLength={300} onChange={e => alan({ aciklama: e.target.value })} /></div>
          <div style={{ display: 'flex', gap: 6, marginTop: 6 }}>
            <button type="button" className="b" disabled={isliyor} onClick={() => void kaydet()}>Kaydet</button>
            <button type="button" className="d" onClick={() => setDuzen(null)}>Vazgeç</button>
          </div>
        </div>
      )}
      <div className="not">Bugün geçerli teminatlar (başlangıcı gelmiş, bitişi geçmemiş) limit aşımının teminatla karşılanıp karşılanmadığını belirler.
        Ekleme / değişiklik / silme loglanır.</div>
    </Modal>
  );
}

// ==================================================================== A4 ===

function RiskA4({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const o = v.ozet;
  const sube = v.sube ? v.secim.subeler.find(s => s.id === v.sube)?.ad : 'Tümü';
  const ilk = v.musteriler.slice(0, 30);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>MÜŞTERİ RİSK / LİMİT İCMALİ</h3>
      <div className="a4-hasta">
        <span>Tarih: <b>{tarihT(v.tarih)}</b></span><span>TL karşılığı (bugünkü kur)</span><span>Şube: {sube}</span>
        <span>Risk = açık bakiye{v.cekDahil ? ' + portföy çek' : ''} + faturasız irsaliye{v.siparisDahil ? ' + açık sipariş' : ''}</span>
        <span>{o.musteri} aktif müşteri</span>{v.grup && <span>Risk grubu: {v.grup}</span>}
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Müşteri</th><th>Toplam risk</th><th>Limit</th><th>Kullanım</th><th>Vadesi geçen</th></tr></thead>
        <tbody>
          {ilk.map(m => <tr key={m.id}><td>{m.ad}{m.sevkBlokesi ? ' (blokeli)' : ''}</td><td>{tl(m.toplam)}</td><td>{limitMetni(m.limit, m.limitDoviz)}</td>
            <td>{yz(m.kullanim)}</td><td>{tl(m.vadesiGecen)}</td></tr>)}
          {v.musteriler.length > ilk.length && <tr><td colSpan={5}>… {v.musteriler.length - ilk.length} müşteri daha</td></tr>}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Açık bakiye</td><td>{tl(o.acikBakiye)}</td></tr>
        {v.cekDahil && <tr><td>Portföy çek</td><td>{tl(o.cek)}</td></tr>}
        <tr><td>Faturasız irsaliye{v.siparisDahil ? ' + açık sipariş' : ''}</td><td>{tl(o.irsaliye + o.siparis)}</td></tr>
        <tr className="kalan ki-kalan"><td>TOPLAM RİSK</td><td>{tl(o.toplamRisk)} ₺</td></tr>
      </tbody></table>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Genel Müdür<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Müşteri Risk / Limit İcmali · {o.limitAsan} müşteri limit üstünde · {o.limitTanimsiz} müşterinin limiti tanımsız</p>
    </div>
  );
}

const MR_STILI = `
.hi .sepv { width:1px; height:20px; background:#cdd6e0; margin:0 4px; display:inline-block; }
.hi .mr-rz { margin-left:4px; }
.hi-tablo tr.mr-asim td:first-child { box-shadow: inset 3px 0 0 #c0413d; }
.mr-kul { display:flex; align-items:center; gap:6px; }
.mr-kul .si-cubuk { flex:1; }
.hi .bilgi-kutusu { margin:6px 12px; padding:6px 10px; border:1px solid #bfe3cb; background:#e2f3e8; color:#2e7d46; border-radius:4px; cursor:pointer; }
`;

export default MusteriRiskIcmali;
