import { useEffect, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import { kdvIcmalUclari, type KdvIcmali as Veri, type KdvOranTablosu, type KdvUyariSatiri } from '../../api/uclar/kdvIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { EkranA4, eksi, kisa, sayi, tarihT, TICARI_ICMAL_STILI, tl, useGezinti } from '../ticariIcmal/ticariIcmalOrtak';

/**
 * KDV İCMALİ `/kdv-icmali` - mockup Ekranlar/İcmal/kdv_icmali.html (kararlar 25.10.2026).
 * "Bu ay ne kadar KDV ödeyeceğiz, beyandan önce düzeltmemiz gereken belge var mı, müşavire
 * ne göndereceğiz?" BEYANNAME DEĞİLDİR. Rakamlar SUNUCUDAN (KdvIcmalUclari): KDV belgenin
 * saklı toplamından (fn_belge_diptoplam), oran kırılımı satırlara dağıtılmış; ekran toplamaz.
 * Mükellef = VKN (aynı VKN'li şubeler tek icmal), şube şeritte süzgeç.
 */
type Sekme = 'orn' | 'tev' | 'ist' | 'iad' | 'ba' | 'uyr' | 'muh' | 'onz';

const ETUR_ADI: Record<string, string> = { efatura: 'e-Fatura', earsiv: 'e-Arşiv', kagit: 'Kağıt' };
const YON_ADI: Record<string, string> = { satis: 'satış', 'satis-iade': 'satış iadesi', alis: 'alış', 'alis-iade': 'alış iadesi' };
const UYARI_ADI: Record<KdvUyariSatiri['tur'], string> = {
  gib: 'GİB', kdvsiz: "KDV'siz", oran: 'oran', tarih: 'tarih', iade: 'iade', babs: 'Ba/Bs', subesiz: 'şube',
  aktarim: 'aktarım', taslak: 'taslak',
};
const VKN = (v: string) => (v.length === 10 ? `${v.slice(0, 3)} ${v.slice(3, 6)} ${v.slice(6)}` : v);
const oranAdi = (o: number, istisna: boolean) => (o === 0 ? (istisna ? '%0 (istisna)' : '%0') : `%${o}`);
const tevOran = (o: number) => (o > 0 && o % 10 === 0 ? `${o / 10}/10` : o > 0 ? `%${sayi(o)}` : '—');
/** Kullanıcının yazdığı tutar (1.234,56 ya da 1234.56). */
const tutarOku = (s: string) => {
  const t = s.trim().replace(/\s/g, '');
  const n = Number(t.includes(',') ? t.replace(/\./g, '').replace(',', '.') : t);
  return Number.isFinite(n) ? n : NaN;
};

export function KdvIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const donem = arama.get('donem') ?? '';
  const vkn = arama.get('vkn') ?? '';
  const sube = Number(arama.get('sube') ?? 0);
  const ebelge = arama.get('ebelge') ?? 'hepsi';
  const tur = arama.get('tur') ?? 'tumu';
  const taslak = arama.get('taslak') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('orn');
  const [secili, setSecili] = useState(0);
  const [yenile, setYenile] = useState(0);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams();
    if (donem) q.set('donem', donem);
    if (vkn) q.set('vkn', vkn);
    if (sube) q.set('sube', String(sube));
    if (ebelge !== 'hepsi') q.set('ebelge', ebelge);
    if (tur !== 'tumu') q.set('tur', tur);
    if (taslak) q.set('taslak', '1');
    kdvIcmalUclari.kdvIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [donem, vkn, sube, ebelge, tur, taslak, yenile]);

  const o = veri?.ozet;
  const belgeAc = (id: number | null | undefined) => { if (id) { setSecili(id); gz.belgeKarti(id) } };
  const sec = (id: number | null | undefined) => id && setSecili(id);
  const mukellefYazi = veri ? `${veri.mukellef.unvan}${veri.mukellef.vkn ? ` · ${VKN(veri.mukellef.vkn)}` : ' · (VKN girilmemiş)'}` : '';
  const subeAdi = sube ? veri?.mukellef.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tüm şubeler';
  const a4 = veri && <KdvA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} />;
  const dokum = veri && <MusavirDokumu v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />;
  const segBtn = (k: string, ad: string) => (
    <button type="button" className={ebelge === k ? 'on' : ''} onClick={() => degistir({ ebelge: k === 'hepsi' ? '' : k })}>{ad}</button>
  );

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI + KDV_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>KDV İcmali{veri ? ` — ${veri.donemAd}` : ''}</h1><span className="yol">Muhasebe › İcmaller › KDV İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="KDV İcmali" dosyaAdi={`KDV İcmali ${veri?.donem ?? ''}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={!secili} onClick={() => gz.belgeKarti(secili)} title={secili ? '' : 'Önce bir belge satırına tıklayın'}>📄 Seçili belgeyi aç</button>
        <CiktiMenusu etiket="Müşavir dökümü" dosyaAdi={`KDV müşavir dökümü ${veri?.donem ?? ''}`} devre={!veri}>{dokum}</CiktiMenusu>
        <span className="sp" />
        <button onClick={() => gz.git('/efatura-icmal')}>📨 Fatura / e-Belge İcmali</button>
        <button onClick={() => gz.git('/muhasebe-fis')}>📕 Muhasebe Fişi Listesi</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <select value={veri?.donem ?? donem} onChange={e => degistir({ donem: e.target.value })}>
            {(veri?.secim.donemler ?? []).map(d => <option key={d.donem} value={d.donem}>{d.ad}{d.kapali ? ' (kapalı)' : ''}</option>)}
            {veri && !veri.secim.donemler.some(d => d.donem === veri.donem) && <option value={veri.donem}>{veri.donemAd}</option>}
          </select>
          {veri && <span className={'bo-rz ' + (veri.donemKapali ? 'pas' : 'ok')}>{veri.donemKapali ? 'kapalı ay' : 'açık ay'}</span>}
        </div>
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
        <div className="sel">📑 Belge türü:
          <select value={tur} onChange={e => degistir({ tur: e.target.value === 'tumu' ? '' : e.target.value })}>
            <option value="tumu">Tümü</option><option value="fatura">Fatura</option><option value="fis">Fiş</option>
          </select></div>
        <div className="si-seg">{segBtn('hepsi', 'Hepsi')}{segBtn('efatura', 'e-Fatura')}{segBtn('earsiv', 'e-Arşiv')}{segBtn('kagit', 'Kağıt')}</div>
        <label className="ti-chk"><input type="checkbox" checked={taslak} onChange={e => degistir({ taslak: e.target.checked ? '1' : '' })} /> Taslaklar dahil (ön izleme)</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        <span className="bo-rz sari">Beyanname değildir · ön kontrol</span>
        {veri?.suzgecli && <span className="bo-rz mavi" title="Şube / belge türü / e-Belge süzgeci açık: ödenecek tahmini mükellefin bütün belgeleri değildir">süzgeçli</span>}
        {veri?.kapsamli && <span className="bo-rz sari" title="Cari kayıt kapsamınız sınırlı: yalnız erişebildiğiniz carilerin belgeleri sayıldı">kapsam sınırlı</span>}
        {o && o.uyari > 0 && <span className="bo-rz kir" style={{ cursor: 'pointer' }} onClick={() => setSekme('uyr')}>Uyarı: {o.uyari}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Hesaplanan KDV" deg={kisa(o.hesaplanan, '')} alt={`satış · matrah ${tl(o.hesaplananMatrah)}`} />
          <Kutu bas="İndirilecek KDV" deg={kisa(o.indirilecek, '')} alt={`alış + gider · matrah ${tl(o.indirilecekMatrah)}`} />
          <Kutu bas="Tevkifat" deg={kisa(o.tevkifat, '')} alt={`alıcı olarak KDV-2 · ${o.tevkifatBelge} belge`} sinif={o.tevkifat ? 'uy' : ''} />
          <Kutu bas="Ödenecek KDV (tahmini)" deg={kisa(o.odenecek, '')} sinif="mor"
            alt={o.sonrakiDevreden > 0 ? `sonraki döneme devreden ${tl(o.sonrakiDevreden)}`
              : o.devreden > 0 ? `devreden ${tl(o.devreden)} düşüldü` : 'devreden yok'} />
          <Kutu bas="İstisna Matrahı" deg={kisa(o.istisnaMatrah, '')} alt={o.istisnaKodlar.length ? o.istisnaKodlar.join(' · ') : 'istisna yok'} />
          <Kutu bas="İade KDV" deg={o.iadeKdv ? `−${kisa(o.iadeKdv, '')}` : '—'} alt={`satış iadesi ${o.satisIadeBelge} belge`} sinif={o.iadeKdv ? 'teh' : ''} />
          <Kutu bas="Belge" deg={sayi(o.belge)} alt={`satış ${o.satisBelge} · alış ${o.alisBelge}`} />
          <Kutu bas="Uyarı" deg={sayi(o.uyari)} sinif={o.uyari ? 'teh' : 'iyi'}
            alt={o.uyari ? `GİB'e gitmemiş ${o.uyariSayilari.gib ?? 0} · KDV'siz ${o.uyariSayilari.kdvsiz ?? 0}` : 'beyana hazır görünüyor'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['orn', 'Oran Bazında', null], ['tev', 'Tevkifat', veri.tevkifat.satirlar.length || null],
              ['ist', 'İstisnalar', null], ['iad', 'İadeler', veri.iade.satirlar.length || null],
              ['ba', 'Ba / Bs Ön Kontrol', null], ['uyr', 'Uyarılar', o.uyari || null], ['muh', 'Muhasebe Bağı', null],
              ['onz', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'orn' && <>
              <div className="si-iki">
                <Kutucuk baslik="Satış — hesaplanan KDV"><OranTablosu t={veri.oran.satis} satis /></Kutucuk>
                <Kutucuk baslik="Alış ve gider — indirilecek KDV"><OranTablosu t={veri.oran.alis} satis={false} /></Kutucuk>
              </div>
              {veri.taslakBlok && (
                <div className="si-iki kv-taslak">
                  <Kutucuk baslik={`Taslaklar (ön izleme) — satış ${veri.taslakBlok.satisBelge} belge`} not="ödenecek KDV'ye eklenmedi">
                    <OranTablosu t={veri.taslakBlok.satis} satis /></Kutucuk>
                  <Kutucuk baslik={`Taslaklar (ön izleme) — alış ${veri.taslakBlok.alisBelge} belge`} not="ödenecek KDV'ye eklenmedi">
                    <OranTablosu t={veri.taslakBlok.alis} satis={false} /></Kutucuk>
                </div>
              )}
              <Kutucuk baslik="Hesap özeti">
                <HesapOzeti v={veri} yenile={() => setYenile(n => n + 1)} />
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Tahmindir; beyanname müşavirin programında hazırlanır. KDV belgenin saklı
                  toplamından (fn_belge_diptoplam / BelgeHesap — Delphi formülü), oran kırılımı satırlara dağıtılmış; ekran yeniden yuvarlamaz.
                  Dönem belge (fatura) tarihine göre; dövizli belgeler belge kuruyla TL.</div>
              </Kutucuk>
            </>}

            {sekme === 'tev' && (
              <Kutucuk baslik="Tevkifatlı belgeler" not="çift tık: belge kartı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Belge</th><th>Tarih</th><th>Taraf</th><th>Yön</th><th>Tevkifat kodu</th><th className="orta">Oran</th>
                      <th className="sag">Matrah</th><th className="sag">KDV</th><th className="sag">Tevkif edilen</th><th className="sag">Ödenen KDV</th></tr></thead>
                    <tbody>
                      {veri.tevkifat.satirlar.length === 0 && <tr><td colSpan={10} className="bos">Bu dönemde tevkifatlı belge yok.</td></tr>}
                      {veri.tevkifat.satirlar.map(x => (
                        <tr key={`${x.belgeId}-${x.kod}`} className={'ac' + (secili === x.belgeId ? ' ti-sec' : '')}
                          onClick={() => sec(x.belgeId)} onDoubleClick={() => belgeAc(x.belgeId)}>
                          <td><span className="lnk" onClick={() => belgeAc(x.belgeId)}>{x.no}</span></td><td>{tarihT(x.tarih)}</td>
                          <td>{x.taraf}</td><td>{x.yon === 'alis' ? 'alış' : 'satış'}</td><td title={x.kodAdi}>{x.kodAdi}</td>
                          <td className="orta">{tevOran(x.oran)}</td><td className="sag">{tl(x.matrah)}</td><td className="sag">{tl(x.kdv)}</td>
                          <td className="sag">{tl(x.tevkif)}</td><td className="sag">{tl(x.odenen)}</td></tr>
                      ))}
                      {veri.tevkifat.satirlar.length > 0 && (
                        <tr className="top"><td>Toplam</td><td /><td>{veri.tevkifat.toplam.belge} belge</td><td /><td /><td />
                          <td className="sag">{tl(veri.tevkifat.toplam.matrah)}</td><td className="sag">{tl(veri.tevkifat.toplam.kdv)}</td>
                          <td className="sag">{tl(veri.tevkifat.toplam.tevkif)}</td><td className="sag">{tl(veri.tevkifat.toplam.odenen)}</td></tr>
                      )}
                    </tbody></table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Tevkifat kodu ve oranı belge satırından (yoksa e-Fatura başlığından). Alışta tevkif edilen
                  KDV-2 ile beyan edilir ve aynı dönemde indirilir; satışta alıcının tevkif ettiği kısım hesaplanan KDV'den düşülür. e-Fatura XML'inde
                  WithholdingTax TaxableAmount = KDV tutarıdır (net değil).</div>
              </Kutucuk>
            )}

            {sekme === 'ist' && (
              <Kutucuk baslik="İstisna ve muafiyetler" not="satış · KDV'si sıfır satırlar">
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Açıklama</th><th className="sag">Belge</th><th className="sag">Matrah</th><th>Not</th></tr></thead>
                  <tbody>
                    {veri.istisna.satirlar.length === 0 && <tr><td colSpan={5} className="bos">Bu dönemde istisnalı satış yok.</td></tr>}
                    {veri.istisna.satirlar.map(x => (
                      <tr key={x.kod}><td>{x.kod}</td><td>{x.ad}</td><td className="sag">{x.belge}</td><td className="sag">{tl(x.matrah)}</td>
                        <td>{x.doviz.map(d => <span key={d.para} className="bo-rz mavi" style={{ marginRight: 4 }}>{d.para} {tl(d.tutar)}</span>)}</td></tr>
                    ))}
                    {veri.istisna.kodsuzSatir > 0 && (
                      <tr><td className="kir">—</td><td className="kir">Kodsuz %0 satır</td><td className="sag">{veri.istisna.kodsuzSatir} satır</td>
                        <td className="sag kir">{tl(veri.istisna.kodsuzMatrah)}</td><td><span className="bo-rz kir">Uyarılar'da</span></td></tr>
                    )}
                    <tr className="top"><td>Toplam</td><td /><td className="sag">{veri.istisna.toplam.belge}</td>
                      <td className="sag">{tl(veri.istisna.toplam.matrah)}</td><td /></tr>
                  </tbody></table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Kod e-Fatura ile aynı öncelikle: ihraç kayıtlı / istisna faturasında başlık kodu, sonra
                  satırın muafiyet kodu, ihracat senaryosunda 301 (GİB kod listesi). %0 KDV'li satırda kod yoksa Uyarılar'a düşer. Döviz rozeti dövizli
                  belgelerin belge kuruyla döviz karşılığıdır.</div>
              </Kutucuk>
            )}

            {sekme === 'iad' && (
              <Kutucuk baslik="İade faturaları" not="çift tık: belge kartı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Belge</th><th>Tarih</th><th>Taraf</th><th>Yön</th><th>İade edilen belge</th><th className="sag">Matrah</th>
                      <th className="sag">KDV</th><th>Not</th></tr></thead>
                    <tbody>
                      {veri.iade.satirlar.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde iade faturası yok.</td></tr>}
                      {veri.iade.satirlar.map(x => (
                        <tr key={x.belgeId} className={'ac' + (secili === x.belgeId ? ' ti-sec' : '')}
                          onClick={() => sec(x.belgeId)} onDoubleClick={() => belgeAc(x.belgeId)}>
                          <td>{x.no}</td><td>{tarihT(x.tarih)}</td><td>{x.taraf}</td><td>{x.yon === 'satis' ? 'satış iadesi' : 'alış iadesi'}</td>
                          <td>{x.iadeEdilenId ? <span className="lnk" onClick={e => { e.stopPropagation(); belgeAc(x.iadeEdilenId) }}>{x.iadeEdilenNo}</span>
                            : <span className="ki-soluk">(bağsız)</span>}</td>
                          <td className="sag">{tl(x.matrah)}</td><td className="sag">{tl(x.kdv)}</td>
                          <td>{x.bagsiz && <span className="bo-rz sari">orijinal belge bağı yok</span>}</td></tr>
                      ))}
                      {veri.iade.satirlar.length > 0 && (
                        <tr className="top"><td colSpan={5}>Toplam ({veri.iade.toplam.belge} belge)</td>
                          <td /><td className="sag">satış {eksi(veri.iade.toplam.satisKdv)} · alış {eksi(veri.iade.toplam.alisKdv)}</td><td /></tr>
                      )}
                    </tbody></table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Satış iadesinin KDV'si hesaplanandan düşülür; alış iadesinin KDV'si indirimden düşülür
                  (ödenecekte artı). İade e-Faturası orijinal faturaya BillingReference ile bağlanır; bağsız iade hem beyan hem cari mutabakatta sorun
                  çıkarır, Uyarılar'a da yazılır.</div>
              </Kutucuk>
            )}

            {sekme === 'ba' && (
              <Kutucuk baslik={`Ba / Bs ön kontrol — ${tl(veri.babs.sinir)} TL ve üstü`} not={`Bs ${veri.babs.bs} taraf · Ba ${veri.babs.ba} taraf`}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Form</th><th>Taraf</th><th>VKN / TCKN</th><th className="sag">Belge</th><th className="sag">Tutar (KDV hariç)</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.babs.satirlar.length === 0 && <tr><td colSpan={6} className="bos">Sınırı aşan taraf yok.</td></tr>}
                      {veri.babs.satirlar.map(x => (
                        <tr key={`${x.form}-${x.tarafId}-${x.vkn}`} className="ac" onDoubleClick={() => x.tarafId > 0 && gz.cariKarti(x.tarafId, x.form === 'Ba')}>
                          <td>{x.form}</td><td>{x.taraf}</td>
                          <td>{x.vkn ? VKN(x.vkn) : <span className="kir">(boş)</span>}</td>
                          <td className="sag">{x.belge}</td><td className="sag">{tl(x.tutar)}</td>
                          <td><span className={'bo-rz ' + (x.durum === 'tamam' ? 'ok' : 'kir')}>
                            {x.durum === 'tamam' ? 'tamam' : x.durum === 'eksik' ? 'VKN/TCKN eksik' : 'VKN/TCKN hatalı'}</span></td></tr>
                      ))}
                    </tbody></table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Yalnız faturalar; belge adedi ve KDV hariç tutar taraf bazında. Bs = satış + alış iadesi
                  (düzenlediğimiz), Ba = alış + satış iadesi. Sınır Genel Ayarlar › Muhasebe'den (mevzuat değişirse). Bu ekran form üretmez; eksik vergi
                  numarasını ve mutabakat farkını önceden yakalar. Çift tık: cari kartı.</div>
              </Kutucuk>
            )}

            {sekme === 'uyr' && (
              <Kutucuk baslik="⚠ Beyandan önce düzeltilmesi gerekenler" not="çift tık: belge kartı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Tür</th><th>Belge</th><th>Tarih</th><th>Taraf</th><th>Açıklama</th><th className="sag">Tutar</th><th>Öneri</th></tr></thead>
                    <tbody>
                      {veri.uyarilar.length === 0 && <tr><td colSpan={7} className="bos">Uyarı yok — dönem beyana hazır görünüyor.</td></tr>}
                      {veri.uyarilar.map((u, i) => (
                        <tr key={i} className={'ac' + (u.belgeId && secili === u.belgeId ? ' ti-sec' : '')}
                          onClick={() => sec(u.belgeId)} onDoubleClick={() => belgeAc(u.belgeId)}>
                          <td><span className={'bo-rz ' + u.seviye}>{UYARI_ADI[u.tur] ?? u.tur}</span></td>
                          <td>{u.no || '—'}</td><td>{tarihT(u.tarih)}</td><td>{u.taraf || '—'}</td>
                          <td className="kv-acik">{u.aciklama}</td><td className="sag">{u.tutar == null ? '' : tl(u.tutar)}</td>
                          <td>{u.belgeId ? <span className="lnk" onClick={e => { e.stopPropagation(); belgeAc(u.belgeId) }}>{u.oneri}</span>
                            : u.tarafId && u.tur === 'babs' ? <span className="lnk" onClick={() => gz.cariKarti(u.tarafId)}>{u.oneri}</span>
                              : <span className="ki-soluk">{u.oneri}</span>}</td></tr>
                      ))}
                      {veri.uyariToplam > veri.uyarilar.length && <tr><td colSpan={7} className="bos">… {veri.uyariToplam - veri.uyarilar.length} uyarı daha</td></tr>}
                    </tbody></table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>GİB'e gitmemiş / reddedilmiş e-Belge, KDV'siz ve kodsuz satır, kartındaki orandan farklı
                  satır, fatura tarihi önceki ay olup bu ay kaydedilen alış (kapanmış aya düşüyorsa "bu aya indirilecek"), bağsız iade, Ba/Bs için eksik vergi
                  numarası. Mavi satırlar bilgidir.</div>
              </Kutucuk>
            )}

            {sekme === 'muh' && (
              <Kutucuk baslik="Muhasebe hesaplarıyla karşılaştırma" not="dönem hareketi · kapanış fişi hariç">
                {!veri.muhasebe.kullaniliyor ? (
                  <div className="si-not ki-soluk" style={{ padding: '6px 10px' }}>Bu mükellefin şubelerinde KDV hesaplarına (190 / 191 / 391) yazılmış muhasebe fişi yok —
                    muhasebe kullanılmıyor. Devreden KDV Hesap özetinde elle girilir.</div>
                ) : <>
                  <table className="hi-tablo">
                    <thead><tr><th>Hesap</th><th>Ad</th><th className="sag">İcmal</th><th className="sag">Muhasebe (belge fişleri)</th>
                      <th className="sag">Fark</th><th className="sag">Diğer fişler</th><th>Durum</th></tr></thead>
                    <tbody>{veri.muhasebe.satirlar.map(x => (
                      <tr key={x.hesap}><td>{x.hesap}</td><td>{x.ad}</td><td className="sag">{tl(x.icmal)}</td><td className="sag">{tl(x.muhasebe)}</td>
                        <td className={'sag' + (x.durum === 'fark' ? ' kir' : '')}>{tl(x.fark)}</td><td className="sag ki-soluk">{tl(x.diger)}</td>
                        <td><span className={'bo-rz ' + (x.durum === 'tutuyor' ? 'ok' : 'kir')}>{x.durum === 'tutuyor' ? 'tutuyor'
                          : veri.muhasebe.fislenmemisSayi > 0 ? `fişlenmemiş ${veri.muhasebe.fislenmemisSayi} belge` : 'fark var'}</span></td></tr>
                    ))}</tbody></table>
                  {veri.muhasebe.fislenmemis.length > 0 && (
                    <table className="hi-tablo" style={{ marginTop: 8 }}>
                      <thead><tr><th>Fişi olmayan belge</th><th>Tarih</th><th>Taraf</th><th>Yön</th><th className="sag">KDV</th></tr></thead>
                      <tbody>
                        {veri.muhasebe.fislenmemis.map(x => (
                          <tr key={x.belgeId} className="ac" onClick={() => sec(x.belgeId)} onDoubleClick={() => belgeAc(x.belgeId)}>
                            <td>{x.no}</td><td>{tarihT(x.tarih)}</td><td>{x.taraf}</td><td>{YON_ADI[x.yon] ?? x.yon}</td><td className="sag">{tl(x.kdv)}</td></tr>
                        ))}
                        {veri.muhasebe.fislenmemisSayi > veri.muhasebe.fislenmemis.length &&
                          <tr><td colSpan={5} className="bos">… {veri.muhasebe.fislenmemisSayi - veri.muhasebe.fislenmemis.length} belge daha</td></tr>}
                      </tbody></table>
                  )}
                </>}
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>391 = hesaplanan − satış iadesi, 191 = indirilecek − alış iadesi, 360 = sorumlu sıfatıyla KDV-2.
                  Muhasebe sütunu belgeden üretilmiş fişlerin dönem hareketi; "Diğer fişler" elle / KDV mahsup fişleridir ve karşılaştırmaya girmez. Fark
                  varsa fişi olmayan ya da elle düzeltilmiş belge listelenir.</div>
              </Kutucuk>
            )}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.belge} belge</span><span>Dönem: {veri.donemAd} ({veri.donemKapali ? 'kapalı' : 'açık'})</span>
          <span>Mükellef: {mukellefYazi}</span>
          {!taslak && veri.taslakSayisi > 0 && <span>{veri.taslakSayisi} taslak icmale girmedi</span>}
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

function OranTablosu({ t, satis }: { t: KdvOranTablosu; satis: boolean }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Oran</th><th className="sag">Belge</th><th className="sag">Matrah</th><th className="sag">KDV</th>
        <th className="sag">{satis ? 'Pay' : 'Tevkif edilen'}</th></tr></thead>
      <tbody>
        {t.satirlar.length === 0 && <tr><td colSpan={5} className="bos">Bu dönemde belge yok.</td></tr>}
        {t.satirlar.map(s => (
          <tr key={s.oran}><td>{oranAdi(s.oran, s.istisna)}{s.satirsiz > 0 && <span className="ki-soluk" title="satırsız belge: oran belge toplamından"> *</span>}</td>
            <td className="sag">{s.belge}</td><td className="sag">{tl(s.matrah)}</td><td className="sag">{tl(s.kdv)}</td>
            <td className="sag">{satis ? (s.pay == null ? '—' : `%${sayi(s.pay)}`) : tl(s.tevkif)}</td></tr>
        ))}
        <tr className="top"><td>Toplam</td><td className="sag">{t.toplam.belge}</td><td className="sag">{tl(t.toplam.matrah)}</td>
          <td className="sag">{tl(t.toplam.kdv)}</td><td className="sag">{satis ? '%100' : tl(t.toplam.tevkif)}</td></tr>
      </tbody>
    </table>
  );
}

/** Hesap özeti + devreden (muhasebeden ya da elle; elle girilen loglanır). */
function HesapOzeti({ v, yenile }: { v: Veri; yenile(): void }) {
  const h = v.hesap;
  const d = v.devreden;
  const [duzenle, setDuzenle] = useState(false);
  const [tutar, setTutar] = useState('');
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState('');
  const [kaydediliyor, setKaydediliyor] = useState(false);
  const ac = () => {
    setTutar(d.elle ? d.elle.tutar.toLocaleString('tr-TR', { minimumFractionDigits: 2 }) : '');
    setAciklama(d.elle?.aciklama ?? ''); setHata(''); setDuzenle(true);
  };
  const kaydet = () => {
    const n = tutarOku(tutar || '0');
    if (!Number.isFinite(n) || n < 0) { setHata('Geçerli bir tutar girin (0 ya da büyük).'); return }
    setKaydediliyor(true); setHata('');
    kdvIcmalUclari.kdvDevredenYaz({ vkn: v.mukellef.vkn, donem: v.donem, tutar: n, aciklama, surum: d.elle?.surum })
      .then(() => { setDuzenle(false); yenile() })
      .catch(e => setHata(hataMetni(e)))
      .finally(() => setKaydediliyor(false));
  };
  const satir = (ad: string, n: number, isaret: '+' | '−' | '', sinif = '') => (
    <tr><td>{ad}</td><td className={'sag ' + sinif}>{isaret === '−' ? (Math.abs(n) < 0.005 ? '0' : `−${tl(n)}`) : isaret === '+' ? `+${tl(n)}` : tl(n)}</td></tr>
  );
  const devredenAdi = d.kaynak === 'muhasebe' ? '190 bakiyesi (muhasebe)' : d.kaynak === 'elle' ? 'elle girilen' : 'girilmemiş';
  return (
    <table className="hi-tablo">
      <thead><tr><th>Kalem</th><th className="sag">Tutar</th></tr></thead>
      <tbody>
        {satir('Hesaplanan KDV (satış)', h.hesaplanan, '')}
        {h.satisTevkif > 0 && satir('− Satışta alıcının tevkif ettiği KDV', h.satisTevkif, '−')}
        {satir("− Satış iadelerinin KDV'si", h.satisIade, '−', h.satisIade ? 'kir' : '')}
        {satir('− İndirilecek KDV (alış + gider)', h.indirilecek, '−')}
        {satir("+ Alış iadelerinin KDV'si (indirimden düşülür)", h.alisIade, '+')}
        {satir('+ Sorumlu sıfatıyla KDV-2 (tevkifat)', h.kdv2, '+')}
        {satir('− KDV-2 indirimi', h.kdv2Indirim, '−')}
        <tr><td>− Önceki dönemden devreden <span className="ki-soluk">({devredenAdi})</span>
          {d.elle && d.kaynak === 'elle' && d.elle.aciklama && <span className="ki-soluk"> · {d.elle.aciklama}</span>}
          {d.duzenlenebilir && v.yetkiler.devredenDuzenle && !duzenle &&
            <span className="lnk" style={{ marginLeft: 8 }} onClick={ac}>✎ {d.elle ? 'değiştir' : 'gir'}</span>}
          {d.kaynak === 'muhasebe' && d.elle && <span className="bo-rz pas" style={{ marginLeft: 6 }}
            title="Muhasebe kullanıldığı için elle girilen değer kullanılmıyor">elle: {tl(d.elle.tutar)}</span>}
        </td><td className="sag">{d.tutar ? `−${tl(d.tutar)}` : '0'}</td></tr>
        {duzenle && (
          <tr className="si-det"><td colSpan={2}>
            <div className="kv-devr">
              <label>Devreden KDV ({v.donemAd} başı):
                <input value={tutar} onChange={e => setTutar(e.target.value)} placeholder="0,00" autoFocus /></label>
              <label>Açıklama: <input value={aciklama} maxLength={300} onChange={e => setAciklama(e.target.value)}
                placeholder="ör. Eylül beyannamesinden" style={{ minWidth: 260 }} /></label>
              <button type="button" disabled={kaydediliyor} onClick={kaydet}>💾 Kaydet</button>
              <button type="button" disabled={kaydediliyor} onClick={() => setDuzenle(false)}>Vazgeç</button>
              {hata && <span className="kir">{hata}</span>}
            </div>
            <div className="ki-soluk">Dönem başına bir değer; değişiklik işlem günlüğüne yazılır. Muhasebe kullanılıyorsa 190 bakiyesi esas alınır.</div>
          </td></tr>
        )}
        <tr className="top"><td><b>Ödenecek KDV (tahmini)</b></td><td className="sag">{tl(h.odenecek)}</td></tr>
        {h.sonrakiDevreden > 0 && <tr><td>Sonraki döneme devreden KDV</td><td className="sag">{tl(h.sonrakiDevreden)}</td></tr>}
        {v.taslakBlok && (
          <tr className="kv-taslak-satir"><td>Taslaklar dahil olsaydı etkisi (ön izleme · {v.taslakBlok.belge} belge · ödenecek KDV'ye eklenmedi)</td>
            <td className="sag">{v.taslakBlok.etki >= 0 ? '+' : '−'}{tl(Math.abs(v.taslakBlok.etki))}</td></tr>
        )}
        {h.kapanmisIndirilecek > 0 && (
          <tr><td className="ki-soluk">Bilgi: kapanmış döneme ait, bu aya indirilecek alış KDV'si (Uyarılar › tarih · tahmine katılmadı)</td>
            <td className="sag ki-soluk">{tl(h.kapanmisIndirilecek)}</td></tr>
        )}
      </tbody>
    </table>
  );
}

function KdvA4({ v, antet, duzenleyen, sube }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; sube: string }) {
  const h = v.hesap;
  // Satış ve alış oran satırlarını aynı oran satırında yan yana gösterir (yalnız yerleşim; tutarlar sunucudan).
  const oranlar = [...new Set([...v.oran.satis.satirlar.map(s => s.oran), ...v.oran.alis.satirlar.map(s => s.oran)])].sort((a, b) => b - a);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>KDV İCMALİ — {v.donemAd.toLocaleUpperCase('tr')}</h3>
      <div className="a4-hasta">
        <span>Mükellef: <b>{v.mukellef.unvan}</b></span><span>VKN: {v.mukellef.vkn ? VKN(v.mukellef.vkn) : '—'}</span>
        <span>Dönem: {tarihT(v.bas)} – {tarihT(v.bit)} ({v.donemKapali ? 'kapalı' : 'açık'})</span>
        <span>{v.ozet.belge} belge · ön kontrol · {sube}{v.suzgecli ? ' · süzgeçli' : ''}</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Oran</th><th>Satış matrah</th><th>Hesaplanan</th><th>Alış matrah</th><th>İndirilecek</th></tr></thead>
        <tbody>{oranlar.map(r => {
          const s = v.oran.satis.satirlar.find(x => x.oran === r);
          const a = v.oran.alis.satirlar.find(x => x.oran === r);
          return <tr key={r}><td>{oranAdi(r, !!s?.istisna)}</td><td>{s ? tl(s.matrah) : '—'}</td><td>{s ? tl(s.kdv) : '—'}</td>
            <td>{a ? tl(a.matrah) : '—'}</td><td>{a ? tl(a.kdv) : '—'}</td></tr>;
        })}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Hesaplanan KDV</span><span>{tl(h.hesaplanan)}</span></div>
        {h.satisTevkif > 0 && <div><span>Satışta tevkif edilen</span><span>{eksi(h.satisTevkif)}</span></div>}
        <div><span>Satış iadeleri</span><span>{eksi(h.satisIade)}</span></div>
        <div><span>İndirilecek KDV</span><span>{eksi(h.indirilecek)}</span></div>
        <div><span>Alış iadeleri</span><span>+{tl(h.alisIade)}</span></div>
        <div><span>Devreden KDV</span><span>{eksi(h.devreden)}</span></div>
        <div className="b"><span>ÖDENECEK (tahmini)</span><span>{tl(h.odenecek)} ₺</span></div>
        {h.sonrakiDevreden > 0 && <div className="not"><span>sonraki döneme devreden {tl(h.sonrakiDevreden)}</span><span /></div>}
        {v.taslakBlok && <div className="not"><span>taslaklar ({v.taslakBlok.belge} belge) dahil değildir</span><span /></div>}
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali Müşavir<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · KDV İcmali · beyanname değildir · dövizli belgeler belge kuruyla TL
        {h.kdv2 > 0 ? ` · tevkifat KDV-2 ayrıca: ${tl(h.kdv2)}` : ''} · {v.uyarilar.filter(u => u.seviye !== 'mavi').length} uyarı</p>
    </div>
  );
}

/** Müşavir dökümü: belge belge (Gönder › Excel ile müşavire). */
function MusavirDokumu({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>KDV MÜŞAVİR DÖKÜMÜ — {v.donemAd.toLocaleUpperCase('tr')}</h3>
      <div className="a4-hasta">
        <span>Mükellef: <b>{v.mukellef.unvan}</b></span><span>VKN: {v.mukellef.vkn ? VKN(v.mukellef.vkn) : '—'}</span>
        <span>Dönem: {tarihT(v.bas)} – {tarihT(v.bit)}</span><span>{v.belgeToplam} belge</span>
      </div>
      <table className="a4-t ti-a4t kv-dokum">
        <thead><tr><th>Belge</th><th>Tarih</th><th>Yön</th><th>Taraf</th><th>VKN / TCKN</th><th>e-Belge</th><th>Oran</th>
          <th>Matrah</th><th>KDV</th><th>Tevkif</th></tr></thead>
        <tbody>{v.belgeler.map(b => (
          <tr key={b.id}><td>{b.no}</td><td>{tarihT(b.tarih)}</td><td>{YON_ADI[b.yon] ?? b.yon}</td><td>{b.taraf}</td><td>{b.vkn}</td>
            <td>{ETUR_ADI[b.eTur] ?? b.eTur}</td><td>{b.oranlar}</td>
            <td>{b.yon.endsWith('iade') ? `−${tl(b.matrah)}` : tl(b.matrah)}</td>
            <td>{b.yon.endsWith('iade') ? `−${tl(b.kdv)}` : tl(b.kdv)}</td><td>{b.tevkif ? tl(b.tevkif) : ''}</td></tr>
        ))}</tbody>
      </table>
      {v.belgeToplam > v.belgeler.length && <p className="a4-not">… {v.belgeToplam - v.belgeler.length} belge daha (döküm 5.000 belgeyle sınırlı)</p>}
      <p className="a4-not">Gentegre AI · KDV müşavir dökümü · tutarlar belge dip toplamından (fn_belge_diptoplam) · iadeler eksi</p>
    </div>
  );
}

const KDV_STILI = `
.kv-taslak .si-kutu { border-color:#f0d3a0; }
.kv-taslak .si-kutu h4 { background:linear-gradient(#fffaf0,#fdf3e1); color:#8a5a00; }
.hi-tablo tr.kv-taslak-satir td { background:#fff8ec; color:#8a5a00; font-style:italic; }
.hi-tablo td.kv-acik { white-space:normal; min-width:240px; }
.kv-devr { display:flex; gap:10px; align-items:center; flex-wrap:wrap; margin-bottom:4px; }
.kv-devr input { border:1px solid #cdd6e0; border-radius:3px; font-size:12px; padding:2px 6px; margin-left:4px; }
.kv-devr button { border:1px solid #cdd6e0; border-radius:4px; padding:3px 10px; font-size:12px; background:#fff; cursor:pointer; }
.a4-t.kv-dokum td, .a4-t.kv-dokum th { font-size:8px; }
.a4-t.kv-dokum td:nth-child(-n+7), .a4-t.kv-dokum th:nth-child(-n+7) { text-align:left; }
`;

export default KdvIcmali;
