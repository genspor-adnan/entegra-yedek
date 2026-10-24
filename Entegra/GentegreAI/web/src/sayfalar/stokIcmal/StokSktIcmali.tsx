import { Fragment, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { SktIcmali as Veri, SktLotSatiri } from '../../api/uclar/stokIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import {
  ayYil, Cubuk, IZLEME_ADI, kisaTl, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl,
  useAntet, useStokKarti, useSuzgec,
} from './stokIcmalOrtak';

/**
 * SKT / LOT İCMALİ `/stok-skt-icmali` (1173) - mockup Ekranlar/Stok/stok_skt_icmali.html.
 * "Hangi lotların miadı geçti / geçmek üzere, değeri ne, ne yapmalı?" Lot defteri + SKT;
 * öneriler sunucuda (imha / iade, FEFO, satış hızı yetmez).
 */
type Sekme = 'takvim' | 'lot' | 'stok' | 'dik';
const UFUKLAR = [30, 90, 180, 365];
const AY = (t: string) => new Date(t).toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' });

const ONERI: Record<string, [string, string]> = {
  imha: ['İmha / İade', 'kir'], fefo: ['Önce bunu çıkar (FEFO)', 'sari'], hiz: ['Satış hızı yetmez', 'sari'],
  takip: ['Takipte', ''], eksi: ['Eksi lot', 'kir'], sktsiz: ['SKT yok', 'sari'],
};

export function StokSktIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const kartAc = useStokKarti();
  const tarih = arama.get('tarih') ?? bugunYerel();
  const ufuk = Number(arama.get('ufuk') ?? 180);
  const depo = Number(arama.get('depo') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('takvim');
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [ara, setAra] = useState('');

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ tarih, ufuk: String(ufuk) });
    if (depo) q.set('depo', String(depo));
    if (kategori) q.set('kategori', String(kategori));
    api.stokSktIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [tarih, ufuk, depo, kategori]);

  const stoklar = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return (veri?.stoklar ?? []).filter(s => !q || s.kod.toLocaleLowerCase('tr').includes(q) || s.ad.toLocaleLowerCase('tr').includes(q));
  }, [veri, ara]);
  const o = veri?.ozet;
  const enBuyukAy = Math.max(1, veri?.takvim.gecmis.tutar ?? 0, ...(veri?.takvim.aylar ?? []).map(a => a.tutar));
  const dikkatSayi = veri ? veri.dikkat.eksi.length + veri.dikkat.lotsuz.length + veri.dikkat.sktsiz.length + veri.dikkat.hiz.length : null;
  const riskli = o ? o.gecmis.tutar + o.gun30.tutar + o.gun90.tutar + o.gun180.tutar : 0;
  const kutu = (k: { tutar: number; lot: number; miktar: number }) => `${k.lot} lot · ${sayi(k.miktar)} adet`;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>SKT / Lot İcmali</h1><span className="yol">Stok &amp; Hizmet › SKT / Lot İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="SKT / Lot İcmali" dosyaAdi={`SKT Lot İcmali ${tarih}`} devre={!veri}>
          {veri && <SktA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} riskli={riskli} />}
        </CiktiMenusu>
        <span className="sp" />
        <button onClick={() => git('/cikis-fis')}>🗑 Çıkış Fişi (İmha)</button>
        <button onClick={() => git('/stok-deger-icmali')}>📦 Stok Değer İcmali</button>
        <button onClick={() => git('/stok-sayim-fark-icmali')}>⚖ Sayım Fark İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Referans:
          <input type="date" value={tarih} onChange={e => e.target.value && degistir({ tarih: e.target.value })} /></div>
        <div className="si-seg">
          {UFUKLAR.map(u => <button key={u} type="button" className={ufuk === u ? 'on' : ''}
                                    onClick={() => degistir({ ufuk: u === 180 ? '' : String(u) })}>{u === 365 ? '1 yıl' : `${u} gün`}</button>)}
        </div>
        <div className="sel">🏬 Depo:
          <select value={depo} onChange={e => degistir({ depo: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.depoListesi ?? []).map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kategori:
          <select value={kategori} onChange={e => degistir({ kategori: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.kategoriler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select></div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.gecmis.lot > 0 && <span className="bo-rz kir">SKT geçmiş: {o.gecmis.lot} lot · {sayi(o.gecmis.miktar)} adet</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="SKT Geçmiş" deg={kisaTl(o.gecmis.tutar)} alt={kutu(o.gecmis)} sinif={o.gecmis.lot ? 'teh' : 'iyi'} />
          <Kutu bas="≤ 30 Gün" deg={kisaTl(o.gun30.tutar)} alt={kutu(o.gun30)} sinif={o.gun30.lot ? 'teh' : ''} />
          <Kutu bas="31 – 90 Gün" deg={kisaTl(o.gun90.tutar)} alt={kutu(o.gun90)} sinif={o.gun90.lot ? 'uy' : ''} />
          <Kutu bas="91 – 180 Gün" deg={kisaTl(o.gun180.tutar)} alt={kutu(o.gun180)} sinif={o.gun180.lot ? 'uy' : ''} />
          <Kutu bas="180+ Gün" deg={kisaTl(o.ufukOtesi.tutar)} alt={`${o.ufukOtesi.lot} lot`} sinif="iyi" />
          <Kutu bas="Lotlu Değer" deg={kisaTl(o.lotluDeger)} alt={`${sayi(o.lotluKalem)} kalem · ${sayi(o.lotSayisi)} lot`} />
          <Kutu bas="Eksi Lot" deg={sayi(o.eksiLot)} alt={`lotu girilmeden çıkış · ${sayi(o.eksiMiktar)} adet`} sinif={o.eksiLot ? 'teh' : ''} />
          <Kutu bas="Lotsuz Bakiye" deg={sayi(o.lotsuzKalem)} alt="kalem · lot toplamı tutmuyor" sinif={o.lotsuzKalem ? 'uy' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['takvim', 'SKT Takvimi', null], ['lot', 'Lot Bazında', veri.lotlar.length], ['stok', 'Stok Bazında', veri.stoklar.length], ['dik', 'Dikkat', dikkatSayi]]} />

            {sekme === 'takvim' && <>
              <table className="hi-tablo">
                <thead><tr><th>Ay</th><th className="sag">Lot</th><th className="sag">Miktar</th><th className="sag">Tutar</th><th style={{ width: 300 }}>Dağılım</th><th>En büyük</th></tr></thead>
                <tbody>
                  <tr><td className="kir"><b>Geçmiş</b></td><td className="sag">{veri.takvim.gecmis.lot}</td><td className="sag">{sayi(veri.takvim.gecmis.miktar)}</td>
                    <td className="sag kir">{tl(veri.takvim.gecmis.tutar)}</td><td><Cubuk yuzde={(100 * veri.takvim.gecmis.tutar) / enBuyukAy} renk="#c0413d" /></td>
                    <td>{veri.takvim.gecmis.enBuyuk || '—'}</td></tr>
                  {veri.takvim.aylar.length === 0 && <tr><td colSpan={6} className="bos">Ufuk içinde SKT'si dolan lot yok.</td></tr>}
                  {veri.takvim.aylar.map((a, i) => (
                    <tr key={a.ay}><td>{AY(a.ay)}</td><td className="sag">{a.lot}</td><td className="sag">{sayi(a.miktar)}</td>
                      <td className={'sag' + (i === 0 ? ' kir' : '')}>{tl(a.tutar)}</td>
                      <td><Cubuk yuzde={(100 * a.tutar) / enBuyukAy} renk={i === 0 ? '#d9783a' : i < 3 ? '#e0a33a' : undefined} /></td><td>{a.enBuyuk}</td></tr>))}
                  <tr><td className="ki-soluk">Ufuk sonrası</td><td className="sag">{veri.takvim.otesi.lot}</td><td className="sag">—</td>
                    <td className="sag">{tl(veri.takvim.otesi.tutar)}</td><td className="ki-soluk">ufkun dışında</td><td /></tr>
                </tbody>
              </table>
              <div className="ki-soluk si-not">Tutar = lot kalanı × stokun ortalama maliyeti (lot bazında maliyet tutulmuyor). SKT'si boş lotlar takvime girmez, Dikkat'te listelenir.</div>
            </>}

            {sekme === 'lot' && <>
              <table className="hi-tablo">
                <thead><tr><th>Stok</th><th>Lot No</th><th>Üretim</th><th>SKT</th><th className="sag">Kalan Gün</th><th>Depo</th>
                  <th className="sag">Kalan</th><th className="sag">Tutar</th><th className="sag">90 gün çıkış</th><th>Öneri</th></tr></thead>
                <tbody>
                  {veri.lotlar.length === 0 && <tr><td colSpan={10} className="bos">Ufuk içinde lot yok.</td></tr>}
                  {veri.lotlar.map(l => <LotSatiri key={`${l.seriLotId}-${l.depoId}`} l={l} kartAc={kartAc} />)}
                </tbody>
              </table>
              <div className="ki-soluk si-not"><b>FEFO:</b> aynı stok-depoda daha geç SKT'li lottan son 90 günde çıkış yapılmış ama bu lot duruyor.
                <b> Satış hızı yetmez:</b> son 90 günün çıkış hızıyla lot SKT'ye kadar bitmiyor. SKT geçmiş lot Çıkış Fişi (tip İmha) ya da tedarikçiye iade ile düşülür.</div>
            </>}

            {sekme === 'stok' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Stok kodu ya da adı…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 260 }} />
                <span className="ki-soluk">satıra tıkla: lotlar</span>
              </div>
              <table className="hi-tablo">
                <thead><tr><th>Stok</th><th>İzleme</th><th className="sag">Lot</th><th className="sag">Toplam</th><th>En yakın SKT</th>
                  <th className="sag">≤ 90 gün</th><th className="sag">Geçmiş</th><th className="sag">Lotsuz bakiye</th></tr></thead>
                <tbody>
                  {stoklar.slice(0, 1000).map(s => (
                    <Fragment key={s.stokId}>
                      <tr className="ac" onClick={() => setAcik(a => { const n = new Set(a); n.has(s.stokId) ? n.delete(s.stokId) : n.add(s.stokId); return n })}>
                        <td><span className="ok">{acik.has(s.stokId) ? '▾' : '▸'}</span><span className="lnk" onClick={e => { e.stopPropagation(); kartAc(s.stokId) }}>{s.kod}</span> · {s.ad}</td>
                        <td><span className="bo-rz mavi">{IZLEME_ADI[s.izleme] ?? '—'}</span></td>
                        <td className="sag">{s.lot}</td><td className="sag">{sayi(s.toplam)}</td>
                        <td className={s.enYakin && new Date(s.enYakin) < new Date(tarih) ? 'kir' : ''}>{ayYil(s.enYakin)}</td>
                        <td className={'sag' + (s.yakin90 ? ' kir' : '')}>{s.yakin90 ? sayi(s.yakin90) : '—'}</td>
                        <td className={'sag' + (s.gecmis ? ' kir' : '')}>{s.gecmis ? sayi(s.gecmis) : '—'}</td>
                        <td className={'sag' + (s.lotsuz ? ' kir' : '')}>{s.lotsuz ? sayi(s.lotsuz) : '—'}</td></tr>
                      {acik.has(s.stokId) && <tr className="si-det"><td colSpan={8}>
                        {s.lotlar.map(l => `${l.lot || 'lotsuz'} (${ayYil(l.skt)}) ${sayi(l.kalan)} · ${l.depo}`).join('  ·  ')}</td></tr>}
                    </Fragment>
                  ))}
                </tbody>
              </table>
            </>}

            {sekme === 'dik' && (
              <div className="si-iki">
                <Kutucuk baslik="⛔ Eksi lot" not="lotu girilmeden çıkış · sayımda düzelir">
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th>Lot</th><th>SKT</th><th className="sag">Kalan</th></tr></thead>
                    <tbody>{veri.dikkat.eksi.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr>
                      : veri.dikkat.eksi.map((x, i) => <tr key={i}><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.kod}</span> · {x.ad}</td>
                        <td>{x.lot}</td><td>{ayYil(x.skt)}</td><td className="sag kir">{sayi(x.kalan)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="🏷 Lotsuz bakiye" not="stok bakiyesi − lot toplamı ≠ 0">
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th>Depo</th><th className="sag">Stok</th><th className="sag">Lot toplamı</th><th className="sag">Lotsuz</th></tr></thead>
                    <tbody>{veri.dikkat.lotsuz.length === 0 ? <tr><td colSpan={5} className="bos">Yok.</td></tr>
                      : veri.dikkat.lotsuz.map((x, i) => <tr key={i}><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.kod}</span> · {x.ad}</td><td>{x.depo}</td>
                        <td className="sag">{sayi(x.stok)}</td><td className="sag">{sayi(x.lotToplam)}</td><td className="sag kir">{sayi(x.lotsuz)}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="❔ SKT'si boş lotlar" not="izleme türü SKT istiyor">
                  <table className="hi-tablo"><thead><tr><th>Stok</th><th>Lot</th><th className="sag">Kalan</th><th>Depo</th></tr></thead>
                    <tbody>{veri.dikkat.sktsiz.length === 0 ? <tr><td colSpan={4} className="bos">Yok.</td></tr>
                      : veri.dikkat.sktsiz.map((x, i) => <tr key={i}><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.kod}</span> · {x.ad}</td>
                        <td>{x.lot}</td><td className="sag">{sayi(x.kalan)}</td><td>{x.depo}</td></tr>)}</tbody></table>
                </Kutucuk>
                <Kutucuk baslik="📉 Satış hızı yetmeyecek lotlar" not="SKT'ye kadar bitmez · kampanya / iade">
                  <table className="hi-tablo"><thead><tr><th>Stok · Lot</th><th>SKT</th><th className="sag">Kalan</th><th className="sag">90 gün çıkış</th><th className="sag">Tahmini artan</th></tr></thead>
                    <tbody>{veri.dikkat.hiz.length === 0 ? <tr><td colSpan={5} className="bos">Yok.</td></tr>
                      : veri.dikkat.hiz.map((x, i) => <tr key={i}><td><span className="lnk" onClick={() => kartAc(x.stokId)}>{x.kod}</span> · {x.lot}</td>
                        <td>{ayYil(x.skt)}</td><td className="sag">{sayi(x.kalan)}</td><td className="sag">{sayi(x.cikan90)}</td><td className="sag kir">~{sayi(x.tahminiArtan)}</td></tr>)}</tbody></table>
                </Kutucuk>
              </div>
            )}
          </div>
        </div>
      </>)}
    </div>
  );
}

function LotSatiri({ l, kartAc }: { l: SktLotSatiri; kartAc(id: number): void }) {
  const [ad, sinif] = ONERI[l.oneri] ?? ['', ''];
  const g = l.kalanGun;
  return (
    <tr>
      <td><span className="lnk" onClick={() => kartAc(l.stokId)}>{l.kod}</span> · {l.ad}</td>
      <td>{l.lot || '—'}</td><td>{ayYil(l.uretim)}</td><td className={g != null && g < 0 ? 'kir' : ''}>{ayYil(l.skt)}</td>
      <td className="sag">{g == null ? '—' : <span className={'bo-rz ' + (g < 0 ? 'kir' : g <= 30 ? 'kir' : g <= 90 ? 'sari' : '')}>{g}</span>}</td>
      <td>{l.depo}</td><td className="sag">{sayi(l.kalan)}</td><td className="sag">{tl(l.tutar)}</td><td className="sag">{sayi(l.cikan90)}</td>
      <td>{ad && <span className={'bo-rz ' + sinif}>{ad}{l.oneri === 'hiz' ? ` · ~${sayi(l.tahminiArtan)} artar` : ''}</span>}</td>
    </tr>
  );
}

function SktA4({ v, antet, duzenleyen, riskli }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; riskli: number }) {
  const o = v.ozet;
  const gruplar: [string, SktLotSatiri[]][] = [
    ['SKT GEÇMİŞ', v.lotlar.filter(l => (l.kalanGun ?? 0) < 0)],
    ['30 GÜN İÇİNDE', v.lotlar.filter(l => l.kalanGun != null && l.kalanGun >= 0 && l.kalanGun <= 30)],
    ['31 – 90 GÜN', v.lotlar.filter(l => l.kalanGun != null && l.kalanGun > 30 && l.kalanGun <= 90)],
    [`91 – ${v.ufuk} GÜN`, v.lotlar.filter(l => l.kalanGun != null && l.kalanGun > 90)],
  ];
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>SON KULLANMA TARİHİ (SKT) / LOT İCMALİ</h3>
      <div className="a4-hasta">
        <span>Referans: <b>{tarihT(v.tarih)}</b> · ufuk {v.ufuk} gün</span><span>Lotlu kalem: {sayi(o.lotluKalem)} · lot {sayi(o.lotSayisi)}</span>
        <span>Değer: ortalama maliyet</span><span>Eksi lot: {o.eksiLot} · lotsuz bakiye: {o.lotsuzKalem}</span>
      </div>
      <table className="a4-t">
        <thead><tr><th>Stok</th><th>Lot</th><th>SKT</th><th>Gün</th><th>Depo</th><th>Kalan</th><th>Tutar</th></tr></thead>
        <tbody>{gruplar.map(([ad, l]) => l.length === 0 ? null : [
          <tr key={ad}><td colSpan={7}><b>{ad} ({l.length})</b></td></tr>,
          ...l.map(x => <tr key={`${x.seriLotId}-${x.depoId}`}><td>{x.kod} · {x.ad}</td><td>{x.lot}</td><td>{ayYil(x.skt)}</td>
            <td>{x.kalanGun}</td><td>{x.depo}</td><td>{sayi(x.kalan)}</td><td>{tl(x.tutar)}</td></tr>),
        ])}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>SKT geçmiş</td><td>{tl(o.gecmis.tutar)}</td></tr>
        <tr><td>30 gün içinde</td><td>{tl(o.gun30.tutar)}</td></tr>
        <tr><td>31 – 180 gün</td><td>{tl(o.gun90.tutar + o.gun180.tutar)}</td></tr>
        <tr className="kalan ki-kalan"><td>RİSKLİ DEĞER</td><td>{tl(riskli)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Lot kalanı lot defterinden; tutar stokun ortalama maliyetiyle. SKT geçmiş lot imha (Çıkış Fişi) ya da tedarikçiye iade ile düşülür.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Depo Sorumlusu<br />Ad Soyad · İmza</div></div>
    </div>
  );
}

export default StokSktIcmali;
