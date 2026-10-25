import { Fragment, useEffect, useMemo, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import {
  babsIcmalUclari, type BabsBelge, type BabsForm, type BabsIcmali as Veri, type BabsKiyas, type BabsSatiri, type BabsUyari,
} from '../../api/uclar/babsIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { Modal } from '../../bilesenler/Modal';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { EkranA4, kisa, sayi, tarihT, TICARI_ICMAL_STILI, tl, useGezinti } from '../ticariIcmal/ticariIcmalOrtak';

/**
 * Ba / Bs İCMALİ `/babs-icmali` - mockup Ekranlar/İcmal/ba_bs_icmali.html (1186, 25.10.2026).
 * "Bu ay Ba / Bs'ye kimler giriyor, tutarlar doğru mu, cari bizimle aynı tutarı mı bildirecek?"
 * Kural KDV İcmali ile ORTAK (sunucu: KdvIcmalUclari.BabsBelgesi / BabsFormu); aynı VKN'li cariler tek satır.
 * Rakamlar SUNUCUDAN (BabsIcmalUclari); ekran toplamaz. e-Beyanname XML'i değil, Excel dökümü verir.
 */
type Sekme = 'ba' | 'bs' | 'esk' | 'uyr' | 'mut' | 'kdv' | 'onz';

const VKN = (v: string) => (v.length === 10 ? `${v.slice(0, 3)} ${v.slice(3, 6)} ${v.slice(6)}` : v);
const YON_ADI: Record<string, string> = { satis: 'satış', 'satis-iade': 'satış iadesi', alis: 'alış', 'alis-iade': 'alış iadesi' };
const UYARI_ADI: Record<BabsUyari['tur'], string> = {
  vkn: 'VKN', cokcari: 'aynı VKN', yurtdisi: 'yurt dışı', taslak: 'taslak', degisti: 'değişti',
};
/** Kullanıcının yazdığı tutar (1.234,56 ya da 1234.56). */
const tutarOku = (s: string) => {
  const t = s.trim().replace(/\s/g, '');
  if (!t) return NaN;
  const n = Number(t.includes(',') ? t.replace(/\./g, '').replace(',', '.') : t);
  return Number.isFinite(n) ? n : NaN;
};
const satirKimligi = (s: BabsSatiri) => `${s.form}|${s.anahtar}`;

function MutabakatRozeti({ s }: { s: BabsSatiri }) {
  const m = s.mutabakat;
  if (s.vknDurum !== 'tamam') return <span className="bo-rz kir">VKN {s.vknDurum === 'eksik' ? 'eksik' : 'hatalı'}</span>;
  if (!m?.gonderimAn) return <span className="bo-rz">gönderilmedi</span>;
  if (m.degisti) return <span className="bo-rz sari" title="Gönderimden sonra tutar / belge sayısı değişti">tutar değişti</span>;
  if (m.yanit === 1) return <span className="bo-rz ok">mutabık</span>;
  if (m.yanit === 2) return <span className="bo-rz kir">fark: {tl(Math.abs(m.fark ?? 0))}</span>;
  return <span className="bo-rz sari">bekliyor</span>;
}

export function BabsIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const donem = arama.get('donem') ?? '';
  const vkn = arama.get('vkn') ?? '';
  const sube = Number(arama.get('sube') ?? 0);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('ba');
  const [yenile, setYenile] = useState(0);
  const [acik, setAcik] = useState<Record<string, BabsBelge[] | 'yukleniyor'>>({});
  const [secim, setSecim] = useState<Set<string>>(new Set());
  const [gonderAcik, setGonderAcik] = useState(false);
  const [yanitSatiri, setYanitSatiri] = useState<BabsSatiri | null>(null);
  const [indiriliyor, setIndiriliyor] = useState(false);

  const sorgu = useMemo(() => {
    const q = new URLSearchParams();
    if (donem) q.set('donem', donem);
    if (vkn) q.set('vkn', vkn);
    if (sube) q.set('sube', String(sube));
    return q;
  }, [donem, vkn, sube]);

  useEffect(() => {
    setHata(''); setYukleniyor(true); setAcik({});
    babsIcmalUclari.babsIcmali(sorgu).then(v => {
      setVeri(v);
      // Seçim yalnız hâlâ var olan satırlarda kalır.
      const varolan = new Set([...v.ba, ...v.bs].map(satirKimligi));
      setSecim(s => new Set([...s].filter(k => varolan.has(k))));
    }).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [sorgu, yenile]);

  const o = veri?.ozet;
  const yazabilir = !!veri?.yetkiler.mutabakat;
  const tumSatirlar = useMemo(() => (veri ? [...veri.ba, ...veri.bs] : []), [veri]);
  const seciliSatirlar = tumSatirlar.filter(s => secim.has(satirKimligi(s)));

  const belgeAcKapa = (s: BabsSatiri) => {
    const k = satirKimligi(s);
    if (acik[k]) { setAcik(a => { const y = { ...a }; delete y[k]; return y }); return }
    setAcik(a => ({ ...a, [k]: 'yukleniyor' }));
    babsIcmalUclari.babsBelgeler(sorgu, s.form, s.anahtar)
      .then(y => setAcik(a => ({ ...a, [k]: y.belgeler })))
      .catch(h => { setHata(hataMetni(h)); setAcik(a => { const y = { ...a }; delete y[k]; return y }) });
  };
  const secDegis = (s: BabsSatiri, acikMi: boolean) => setSecim(m => {
    const y = new Set(m); const k = satirKimligi(s);
    if (acikMi) y.add(k); else y.delete(k);
    return y;
  });
  const disaAktar = async () => {
    setIndiriliyor(true); setHata('');
    try {
      const url = await babsIcmalUclari.babsDisaAktar(sorgu);
      const a = document.createElement('a');
      a.href = url; a.download = `BaBs_${veri?.donem ?? ''}.xlsx`; a.click();
      setTimeout(() => URL.revokeObjectURL(url), 10_000);
    } catch (h) { setHata(hataMetni(h)) } finally { setIndiriliyor(false) }
  };

  const a4 = (form: BabsForm) => veri && <BabsA4 v={veri} form={form} antet={antet} duzenleyen={kullanici?.ad ?? ''} />;

  const formTablosu = (satirlar: BabsSatiri[], form: BabsForm) => {
    const toplam = form === 'Ba' ? o!.ba : o!.bs;
    const secilebilir = satirlar.filter(s => s.vknDurum === 'tamam');
    const hepsi = secilebilir.length > 0 && secilebilir.every(s => secim.has(satirKimligi(s)));
    return (
      <Kutucuk baslik={form === 'Ba' ? 'Form Ba — mal ve hizmet alımları' : 'Form Bs — mal ve hizmet satışları'}
        not={`cari bazında (aynı VKN tek satır) · ${tl(veri!.sinir)} TL ve üstü · ▸ belgeler`}>
        <div style={{ overflowX: 'auto' }}>
          <table className="hi-tablo">
            <thead><tr>
              {yazabilir && <th className="orta"><input type="checkbox" checked={hepsi} title="Tümünü seç"
                onChange={e => secilebilir.forEach(s => secDegis(s, e.target.checked))} /></th>}
              <th>Sıra</th><th>Unvan</th><th>VKN / TCKN</th><th>Ülke</th><th className="sag">Belge sayısı</th>
              <th className="sag">Tutar (KDV hariç)</th><th className="sag">İade (dahil)</th><th>Mutabakat</th></tr></thead>
            <tbody>
              {satirlar.length === 0 && <tr><td colSpan={yazabilir ? 9 : 8} className="bos">Bu dönemde sınırı aşan cari yok.</td></tr>}
              {satirlar.map(s => {
                const k = satirKimligi(s);
                const b = acik[k];
                return (
                  <Fragment key={k}>
                    <tr className="ac" onDoubleClick={() => gz.cariKarti(s.tarafId, form === 'Ba')}>
                      {yazabilir && <td className="orta"><input type="checkbox" disabled={s.vknDurum !== 'tamam'} checked={secim.has(k)}
                        onChange={e => secDegis(s, e.target.checked)} /></td>}
                      <td><span className="lnk" onClick={() => belgeAcKapa(s)}>{b ? '▾' : '▸'}</span> {s.sira}</td>
                      <td><span className="lnk" onClick={() => gz.cariKarti(s.tarafId, form === 'Ba')}>{s.unvan}</span>
                        {s.tarafSayisi > 1 && <span className="bo-rz mavi" style={{ marginLeft: 4 }} title="Aynı VKN birden çok caride">{s.tarafSayisi} cari</span>}</td>
                      <td>{s.vkn ? VKN(s.vkn) : <span className="kir">(boş)</span>}</td><td>TR</td>
                      <td className="sag">{sayi(s.belge)}</td><td className="sag">{tl(s.tutar)}</td>
                      <td className="sag ki-soluk">{s.iade ? tl(s.iade) : ''}</td>
                      <td><MutabakatRozeti s={s} /></td>
                    </tr>
                    {b === 'yukleniyor' && <tr><td colSpan={yazabilir ? 9 : 8} className="bos">yükleniyor…</td></tr>}
                    {Array.isArray(b) && b.map(x => (
                      <tr key={`${k}-${x.id}`} className="ac bb-det" onDoubleClick={() => gz.belgeKarti(x.id)}>
                        {yazabilir && <td />}
                        <td /><td><span className="lnk" onClick={() => gz.belgeKarti(x.id)}>{x.no}</span> · {tarihT(x.tarih)}</td>
                        <td colSpan={2}>{x.taraf}</td><td className="sag">{YON_ADI[x.yon] ?? x.yon}</td><td className="sag">{tl(x.matrah)}</td>
                        <td /><td />
                      </tr>
                    ))}
                  </Fragment>
                );
              })}
              {satirlar.length > 0 && (
                <tr className="top">{yazabilir && <td />}<td colSpan={4}>Toplam ({toplam.cari} cari)</td>
                  <td className="sag">{sayi(toplam.belge)}</td><td className="sag">{tl(toplam.tutar)}</td><td /><td /></tr>
              )}
            </tbody></table>
        </div>
        <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Yalnız kesin faturalar (gider pusulası / serbest meslek makbuzu henüz
          ayrı belge türü değil). {form === 'Bs' ? 'Bs = satış + düzenlediğimiz alış iadesi' : 'Ba = alış + aldığımız satış iadesi'}; tutar KDV hariç,
          dövizli belge belge kuruyla TL. Aynı VKN'li cariler tek satırda; nihai tüketici (11111111111) ve yurt dışı girmez. Çift tık: cari kartı.</div>
      </Kutucuk>
    );
  };

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI + BABS_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Ba / Bs İcmali{veri ? ` — ${veri.donemAd}` : ''}</h1><span className="yol">Muhasebe › İcmaller › Ba / Bs İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Form Ba" dosyaAdi={`Form Ba ${veri?.donem ?? ''}`} devre={!veri}>{a4('Ba')}</CiktiMenusu>
        <CiktiMenusu etiket="Form Bs" dosyaAdi={`Form Bs ${veri?.donem ?? ''}`} devre={!veri}>{a4('Bs')}</CiktiMenusu>
        <button disabled={!veri || indiriliyor} onClick={() => void disaAktar()}
          title="Form Ba + Form Bs dökümü (.xlsx) — e-Beyanname'ye yükleme dosyası değildir">📤 Excel dökümü</button>
        {yazabilir && <button disabled={seciliSatirlar.length === 0} onClick={() => setGonderAcik(true)}
          title={seciliSatirlar.length ? '' : 'Önce Form Ba / Bs sekmesinde satır seçin'}>✉ Mutabakat gönder{seciliSatirlar.length ? ` (${seciliSatirlar.length})` : ''}</button>}
        <span className="sp" />
        <button onClick={() => gz.git('/kdv-icmali' + (donem ? `?donem=${donem}` : ''))}>🧮 KDV İcmali</button>
        <button onClick={() => gz.git('/cari-icmali')}>📒 Cari İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="hi-serit"><span className="bo-rz ok">{bilgi}</span><span className="sp" />
        <button className="bb-kapat" onClick={() => setBilgi('')}>✖</button></div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <select value={veri?.donem ?? donem} onChange={e => degistir({ donem: e.target.value })}>
            {(veri?.secim.donemler ?? []).map(d => <option key={d.donem} value={d.donem}>{d.ad}</option>)}
            {veri && !veri.secim.donemler.some(d => d.donem === veri.donem) && <option value={veri.donem}>{veri.donemAd}</option>}
          </select></div>
        <div className="sel">🏢 Mükellef:
          <select value={veri?.vkn ?? vkn} onChange={e => degistir({ vkn: e.target.value, sube: '' })}>
            {(veri?.secim.mukellefler ?? []).map(m => <option key={m.anahtar} value={m.anahtar}>
              {m.unvan} · {m.vkn ? VKN(m.vkn) : '(VKN yok)'}</option>)}
          </select></div>
        {veri && veri.mukellef.subeler.length > 1 && (
          <div className="sel">Şube:
            <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.mukellef.subeler.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select></div>
        )}
        {veri && <span className="bo-rz mavi" title="Genel Ayarlar › İcmal Eşikleri (muhasebe.babs_sinir)">Eşik: {tl(veri.sinir)} TL (KDV hariç)</span>}
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {veri && <span className={'bo-rz ' + (veri.gecikti ? 'kir' : 'sari')}>Bildirim son günü: {tarihT(veri.sonGun)}</span>}
        {o && o.vknEksik > 0 && <span className="bo-rz kir" style={{ cursor: 'pointer' }} onClick={() => setSekme('uyr')}>VKN eksik: {o.vknEksik}</span>}
        {veri?.kapsamli && <span className="bo-rz sari" title="Cari kayıt kapsamınız sınırlı: yalnız erişebildiğiniz carilerin belgeleri sayıldı">kapsam sınırlı</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Form Ba (alış)" deg={`${o.ba.cari} satıcı`} alt={`${tl(o.ba.tutar)} ₺ · ${sayi(o.ba.belge)} belge`} sinif="mor" />
          <Kutu bas="Form Bs (satış)" deg={`${o.bs.cari} alıcı`} alt={`${tl(o.bs.tutar)} ₺ · ${sayi(o.bs.belge)} belge`} sinif="mor" />
          <Kutu bas="Eşik altı" deg={`${o.esikAlti.cari} cari`} alt={`${kisa(o.esikAlti.tutar, '₺')} · ${o.esikAlti.yakin} eşiğe yakın`} />
          <Kutu bas="VKN / TCKN eksik" deg={sayi(o.vknEksik)} alt={o.vknEksik ? 'bildirime girmez — düzeltin' : 'tamam'} sinif={o.vknEksik ? 'teh' : 'iyi'} />
          <Kutu bas="Mutabakat bekleyen" deg={sayi(o.bekleyen)} alt={`${o.gonderilmedi} cariye gönderilmedi`} sinif={o.bekleyen ? 'uy' : ''} />
          <Kutu bas="Mutabık" deg={sayi(o.mutabik)} alt="yanıt geldi, tutar aynı" sinif="iyi" />
          <Kutu bas="Fark bildiren" deg={sayi(o.fark)} alt="cari farklı tutar bildirdi" sinif={o.fark ? 'teh' : ''} />
          <Kutu bas="Yurt dışı (hariç)" deg={sayi(o.yurtDisi)} alt={o.yurtDisi ? `${tl(o.yurtDisiTutar)} ₺ · Ba / Bs dışı` : 'yok'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['ba', 'Form Ba', veri.ba.length || null], ['bs', 'Form Bs', veri.bs.length || null], ['esk', 'Eşik Altı', null],
              ['uyr', 'Uyarılar', veri.uyarilar.length || null], ['mut', 'Mutabakat', o.bekleyen || null],
              ['kdv', 'KDV İcmali ile Kıyas', null], ['onz', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'ba' && formTablosu(veri.ba, 'Ba')}
            {sekme === 'bs' && formTablosu(veri.bs, 'Bs')}

            {sekme === 'esk' && (
              <Kutucuk baslik="Eşik altında kalan cariler" not="bildirime girmez · eşiğe yakın olanlar üstte">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Unvan</th><th>Form</th><th>VKN / TCKN</th><th className="sag">Belge</th><th className="sag">Tutar</th>
                      <th className="sag">Eşiğe kalan</th><th>Not</th></tr></thead>
                    <tbody>
                      {veri.esikAlti.length === 0 && <tr><td colSpan={7} className="bos">Eşik altında cari yok.</td></tr>}
                      {veri.esikAlti.map(s => (
                        <tr key={satirKimligi(s)} className="ac" onDoubleClick={() => gz.cariKarti(s.tarafId, s.form === 'Ba')}>
                          <td>{s.unvan}</td><td>{s.form}</td><td>{s.vkn ? VKN(s.vkn) : <span className="ki-soluk">(boş)</span>}</td>
                          <td className="sag">{s.belge}</td><td className="sag">{tl(s.tutar)}</td><td className="sag">{tl(s.kalan ?? 0)}</td>
                          <td>{s.yakin && <span className="bo-rz sari">eşiğe çok yakın</span>}</td></tr>
                      ))}
                      {veri.esikAltiToplam > veri.esikAlti.length &&
                        <tr><td colSpan={7} className="bos">… {veri.esikAltiToplam - veri.esikAlti.length} cari daha</td></tr>}
                    </tbody></table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Eşiğe %10 yakın olanlar sarı: dönem sonuna doğru kesilecek bir fatura cariyi
                  bildirime sokar — önceden mutabakat istemek isteyebilirsiniz.</div>
              </Kutucuk>
            )}

            {sekme === 'uyr' && (
              <Kutucuk baslik="Bildirimi bozacak kayıtlar" not="kırmızı satırlar düzeltilmeden bildirime girmez">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Tür</th><th>Cari</th><th>Form</th><th className="sag">Tutar</th><th>Sorun</th><th>Düzeltme</th></tr></thead>
                    <tbody>
                      {veri.uyarilar.length === 0 && <tr><td colSpan={6} className="bos">Uyarı yok — bildirime hazır görünüyor.</td></tr>}
                      {veri.uyarilar.map((u, i) => (
                        <tr key={i} className="ac" onDoubleClick={() => u.tarafId > 0 && gz.cariKarti(u.tarafId, u.form === 'Ba')}>
                          <td><span className={'bo-rz ' + u.seviye}>{UYARI_ADI[u.tur] ?? u.tur}</span></td>
                          <td>{u.unvan || '—'}</td><td>{u.form || '—'}</td><td className="sag">{tl(u.tutar)}</td>
                          <td className="bb-acik">{u.aciklama}</td>
                          <td>{u.tarafId > 0 && u.oneri ? <span className="lnk" onClick={() => gz.cariKarti(u.tarafId, u.form === 'Ba')}>{u.oneri}</span>
                            : <span className="ki-soluk">{u.oneri}</span>}</td></tr>
                      ))}
                    </tbody></table>
                </div>
                {veri.yurtDisi.length > 0 && (
                  <table className="hi-tablo" style={{ marginTop: 8 }}>
                    <thead><tr><th>Yurt dışı cari (Ba / Bs dışı)</th><th>Form</th><th className="sag">Belge</th><th className="sag">Tutar</th></tr></thead>
                    <tbody>{veri.yurtDisi.map(s => (
                      <tr key={satirKimligi(s)}><td>{s.unvan}</td><td>{s.form}</td><td className="sag">{s.belge}</td><td className="sag">{tl(s.tutar)}</td></tr>
                    ))}</tbody></table>
                )}
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Aynı VKN'li cariler bildirimde tek satıra toplanır (GİB VKN bazında ister).
                  Yurt dışı (VKN 2222222222 ya da ihracat faturası) gümrük beyannamesiyle izlenir.</div>
              </Kutucuk>
            )}

            {sekme === 'mut' && (
              <Kutucuk baslik="Cari mutabakat (Ba / Bs teyidi)" not="gönderim Form Ba / Bs sekmesinden · yanıt elle işlenir">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Cari</th><th>Form</th><th className="sag">Bizim tutar</th><th className="sag">Belge</th><th>Gönderim</th>
                      <th>Yanıt</th><th className="sag">Carinin tutarı</th><th className="sag">Fark</th><th /></tr></thead>
                    <tbody>
                      {tumSatirlar.filter(s => s.mutabakat?.gonderimAn).length === 0 &&
                        <tr><td colSpan={9} className="bos">Bu dönem için mutabakat gönderilmedi.</td></tr>}
                      {tumSatirlar.filter(s => s.mutabakat?.gonderimAn).map(s => {
                        const m = s.mutabakat!;
                        return (
                          <tr key={satirKimligi(s)}>
                            <td>{s.unvan}</td><td>{s.form}</td><td className="sag">{tl(s.tutar)}</td><td className="sag">{s.belge}</td>
                            <td>{tarihT(m.gonderimAn)}{m.eposta ? ` · ${m.eposta}` : ' · çıktı'}</td>
                            <td><MutabakatRozeti s={s} />{m.yanitAn ? <span className="ki-soluk"> {tarihT(m.yanitAn)}</span> : null}</td>
                            <td className="sag">{m.carininTutari != null ? tl(m.carininTutari) : '—'}</td>
                            <td className={'sag' + (m.fark ? ' kir' : '')}>{m.fark != null ? tl(m.fark) : '—'}</td>
                            <td>{yazabilir && <button className="bb-kucuk" onClick={() => setYanitSatiri(s)}>Yanıt işle</button>}</td>
                          </tr>
                        );
                      })}
                    </tbody></table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>"Mutabakat gönder" seçili carilere bizim tutar ve belge sayısını yazar, e-posta
                  adresi varsa mektubu kuyruğa koyar (adresi olmayana Form Ba / Bs çıktısı verilir). Yanıt bu ekrandan elle işlenir; mektupta tek
                  kullanımlık yanıt bağlantısı yoktur. Gönderimden sonra tutar değişirse satır "tutar değişti" olur — yeniden gönderin.</div>
              </Kutucuk>
            )}

            {sekme === 'kdv' && (
              <Kutucuk baslik="KDV İcmali ile kıyas" not="aynı dönemin KDV İcmali matrahı · fark açıklanmalı">
                <table className="hi-tablo">
                  <thead><tr><th>Kalem</th><th className="sag">Satış (KDV İcmali hesaplanan)</th><th className="sag">Alış (KDV İcmali indirilecek)</th></tr></thead>
                  <tbody>
                    {([
                      ['Ba / Bs eşik üstü', 'ustu'], ['Eşik altı', 'alti'], ['Nihai tüketici (Ba / Bs dışı)', 'nihai'],
                      ['Yurt dışı (Ba / Bs dışı)', 'yurtDisi'], ['Fiş (fatura değil — Ba / Bs dışı)', 'fis'],
                    ] as [string, keyof BabsKiyas][]).map(([ad, k]) => (
                      <tr key={k}><td>{ad}</td><td className="sag">{tl(veri.kiyas.satis[k])}</td><td className="sag">{tl(veri.kiyas.alis[k])}</td></tr>
                    ))}
                    <tr className="top"><td>Toplam</td><td className="sag">{tl(veri.kiyas.satis.toplam)}</td><td className="sag">{tl(veri.kiyas.alis.toplam)}</td></tr>
                    <tr><td>KDV İcmali matrahı</td><td className="sag">{tl(veri.kiyas.satis.kdv)}</td><td className="sag">{tl(veri.kiyas.alis.kdv)}</td></tr>
                    <tr><td>Fark</td>
                      {[veri.kiyas.satis.fark, veri.kiyas.alis.fark].map((f, i) => (
                        <td key={i} className="sag">{Math.abs(f) < 0.005 ? <span className="bo-rz ok">tutarlı</span> : <span className="kir">{tl(f)}</span>}</td>))}</tr>
                    <tr><td className="ki-soluk">İadeler (iade hariç matraha girmez)</td>
                      <td className="sag ki-soluk">alış iadesi → Bs {tl(veri.kiyas.iadeBs)}</td>
                      <td className="sag ki-soluk">satış iadesi → Ba {tl(veri.kiyas.iadeBa)}</td></tr>
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Ba / Bs toplamı + eşik altı + kapsam dışı (nihai tüketici, yurt dışı, fiş) = KDV
                  İcmali'ndeki matrah olmalı. Fark çıkarsa bir belge iki icmalde farklı sınıflanmıştır — belgeyi KDV İcmali'nden açın.</div>
              </Kutucuk>
            )}

            {sekme === 'onz' && <EkranA4>{a4('Bs')}{a4('Ba')}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.ba.cari} Ba · {o.bs.cari} Bs</span><span>Dönem: {veri.donemAd}</span>
          <span>Mükellef: {veri.mukellef.unvan}{veri.mukellef.vkn ? ` · ${VKN(veri.mukellef.vkn)}` : ' · (VKN girilmemiş)'}</span>
          {o.taslak > 0 && <span>{o.taslak} taslak fatura girmedi</span>}
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}

      {gonderAcik && veri && (
        <GonderModali v={veri} satirlar={seciliSatirlar} onKapat={() => setGonderAcik(false)}
          onTamam={m => { setGonderAcik(false); setBilgi(m); setSecim(new Set()); setYenile(n => n + 1) }} />
      )}
      {yanitSatiri && (
        <YanitModali s={yanitSatiri} onKapat={() => setYanitSatiri(null)}
          onTamam={m => { setYanitSatiri(null); setBilgi(m); setYenile(n => n + 1) }} />
      )}
    </div>
  );
}

function GonderModali({ v, satirlar, onKapat, onTamam }: {
  v: Veri; satirlar: BabsSatiri[]; onKapat(): void; onTamam(mesaj: string): void;
}) {
  const [epostalar, setEpostalar] = useState<Record<string, string>>(() =>
    Object.fromEntries(satirlar.map(s => [satirKimligi(s), s.mutabakat?.eposta || s.eposta])));
  const [epostaGonder, setEpostaGonder] = useState(true);
  const [hata, setHata] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const yeniden = satirlar.filter(s => s.mutabakat?.gonderimAn).length;
  const gonder = async () => {
    setIsliyor(true); setHata('');
    try {
      const y = await babsIcmalUclari.babsMutabakatGonder({
        donem: v.donem, vkn: v.vkn, sube: v.sube || undefined, epostaGonder,
        satirlar: satirlar.map(s => ({ form: s.form, anahtar: s.anahtar, eposta: (epostalar[satirKimligi(s)] ?? '').trim() })),
      });
      onTamam(`${y.yazilan} cari için mutabakat yazıldı${epostaGonder ? `, ${y.eposta} e-posta kuyruğa alındı` : ''}.`
        + (y.atlanan.length ? ` Atlanan: ${y.atlanan.join(' · ')}` : ''));
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };
  return (
    <Modal baslik={`✉ Ba / Bs mutabakatı gönder · ${v.donemAd}`} buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="b" disabled={isliyor} onClick={() => void gonder()}>Gönder</button>
        <button type="button" className="d" onClick={onKapat}>✖ Vazgeç</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="not">{satirlar.length} cari{yeniden ? ` (${yeniden} tanesine daha önce gönderildi — yanıtları sıfırlanır)` : ''}.
        Tutar ve belge sayısı sunucuda yeniden hesaplanır.</div>
      <label className="ti-chk"><input type="checkbox" checked={epostaGonder} onChange={e => setEpostaGonder(e.target.checked)} /> E-posta ile mektup gönder</label>
      <div style={{ maxHeight: 320, overflowY: 'auto', marginTop: 6 }}>
        <table className="hi-tablo">
          <thead><tr><th>Cari</th><th>Form</th><th className="sag">Tutar</th><th>E-posta</th></tr></thead>
          <tbody>{satirlar.map(s => {
            const k = satirKimligi(s);
            return (
              <tr key={k}><td>{s.unvan}</td><td>{s.form}</td><td className="sag">{tl(s.tutar)}</td>
                <td><input className="bb-eposta" value={epostalar[k] ?? ''} maxLength={300} disabled={!epostaGonder}
                  placeholder="adres yok — çıktı verilir" onChange={e => setEpostalar(m => ({ ...m, [k]: e.target.value }))} /></td></tr>
            );
          })}</tbody></table>
      </div>
    </Modal>
  );
}

function YanitModali({ s, onKapat, onTamam }: { s: BabsSatiri; onKapat(): void; onTamam(mesaj: string): void }) {
  const m = s.mutabakat!;
  const [yanit, setYanit] = useState<0 | 1 | 2>(m.yanit === 0 ? 1 : m.yanit);
  const [tutar, setTutar] = useState(m.carininTutari != null ? String(m.carininTutari).replace('.', ',') : '');
  const [belge, setBelge] = useState(m.carininBelge != null ? String(m.carininBelge) : '');
  const [not, setNot] = useState(m.yanitNot);
  const [hata, setHata] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const kaydet = async () => {
    const t = tutarOku(tutar);
    if (yanit === 2 && Number.isNaN(t)) { setHata('Fark bildiren carinin tutarını girin.'); return }
    setIsliyor(true); setHata('');
    try {
      await babsIcmalUclari.babsMutabakatYanit(m.id, {
        yanit, carininTutari: yanit === 1 ? s.tutar : Number.isNaN(t) ? undefined : t,
        carininBelge: belge.trim() ? Number(belge) : yanit === 1 ? s.belge : undefined, not: not.trim(),
      });
      onTamam(`${s.unvan}: yanıt işlendi.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };
  return (
    <Modal baslik={`Yanıt işle · ${s.unvan} · Form ${s.form}`} dar buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="b" disabled={isliyor} onClick={() => void kaydet()}>Kaydet</button>
        {m.yanit !== 0 && <button type="button" className="d" disabled={isliyor}
          onClick={() => { setIsliyor(true); babsIcmalUclari.babsMutabakatYanit(m.id, { yanit: 0 }).then(() => onTamam(`${s.unvan}: yanıt geri alındı.`))
            .catch(h => setHata(hataMetni(h))).finally(() => setIsliyor(false)) }}>Yanıtı geri al</button>}
        <button type="button" className="d" onClick={onKapat}>✖ Vazgeç</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="not">Bizim tutar {tl(s.tutar)} ₺ · {s.belge} belge · gönderim {tarihT(m.gonderimAn)}</div>
      <div className="alan"><label>Yanıt</label>
        <select value={yanit} onChange={e => setYanit(Number(e.target.value) as 1 | 2)}>
          <option value={1}>Mutabık</option><option value={2}>Fark var</option>
        </select></div>
      {yanit === 2 && <>
        <div className="alan"><label>Carinin tutarı (KDV hariç)</label>
          <input value={tutar} inputMode="decimal" onChange={e => setTutar(e.target.value)} /></div>
        <div className="alan"><label>Carinin belge sayısı</label>
          <input value={belge} inputMode="numeric" onChange={e => setBelge(e.target.value.replace(/\D/g, ''))} /></div>
      </>}
      <div className="alan"><label>Not</label>
        <textarea value={not} maxLength={500} rows={3} onChange={e => setNot(e.target.value)} /></div>
    </Modal>
  );
}

/** Form Ba / Bs ön izleme (GİB formunun yerine geçmez; müşavir / kontrol dökümü). */
function BabsA4({ v, form, antet, duzenleyen }: { v: Veri; form: BabsForm; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const satirlar = form === 'Ba' ? v.ba : v.bs;
  const t = form === 'Ba' ? v.ozet.ba : v.ozet.bs;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>FORM {form.toUpperCase()} — {form === 'Ba' ? 'MAL VE HİZMET ALIMLARI' : 'MAL VE HİZMET SATIŞLARI'} (ÖN İZLEME)</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{v.donemAd}</b></span><span>Mükellef: {v.mukellef.unvan}{v.mukellef.vkn ? ` · VKN ${VKN(v.mukellef.vkn)}` : ''}</span>
        <span>Eşik: {tl(v.sinir)} TL (KDV hariç)</span><span>{t.cari} cari · {sayi(t.belge)} belge</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Sıra</th><th>Unvan</th><th>VKN / TCKN</th><th>Ülke</th><th>Belge</th><th>Tutar</th></tr></thead>
        <tbody>{satirlar.map(s => (
          <tr key={satirKimligi(s)}><td>{s.sira}</td><td>{s.unvan}</td><td>{s.vkn || '(boş)'}</td><td>TR</td><td>{s.belge}</td><td>{tl(s.tutar)}</td></tr>
        ))}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Belge sayısı</span><span>{sayi(t.belge)}</span></div>
        <div className="b"><span>FORM {form.toUpperCase()} TOPLAMI</span><span>{tl(t.tutar)} ₺</span></div>
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali Müşavir<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Ba / Bs İcmali · yalnız kesin faturalar · {v.ozet.vknEksik} cari VKN eksik olduğu için dışarıda ·
        son gün {tarihT(v.sonGun)}</p>
    </div>
  );
}

const BABS_STILI = `
.hi-tablo tr.bb-det td { background:#f9fbfd; font-size:11px; color:#3a4c5e; }
.hi-tablo td.bb-acik { white-space:normal; min-width:240px; }
.bb-eposta { border:1px solid #cdd6e0; border-radius:3px; font-size:12px; padding:2px 6px; width:100%; min-width:200px; }
.bb-kucuk { border:1px solid #cdd6e0; border-radius:4px; padding:2px 8px; font-size:11.5px; background:#fff; cursor:pointer; }
.bb-kapat { border:0; background:none; cursor:pointer; color:#6b7a8b; }
`;

export default BabsIcmali;
