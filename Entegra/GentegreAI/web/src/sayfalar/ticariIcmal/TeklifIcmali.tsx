import { useEffect, useMemo, useState } from 'react';
import { hataMetni } from '../../api/sozlesme';
import {
  teklifIcmalUclari, type TeklifIcmali as Veri, type TeklifDurumu, type TeklifSatiri,
} from '../../api/uclar/teklifIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { Modal } from '../../bilesenler/Modal';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { EkranA4, hazirDonem, kisa, sayi, tarihT, TICARI_ICMAL_STILI, tl, useGezinti, yilBasi, yuzde } from './ticariIcmalOrtak';

/**
 * TEKLİF / FIRSAT DÖNÜŞÜM İCMALİ `/teklif-icmali` - mockup Ekranlar/İcmal/teklif_donusum_icmali.html (kararlar
 * 25.10.2026). "Verdiğimiz tekliflerin ne kadarı satışa dönüyor, nerede kaybediyoruz, hangi teklif takip
 * bekliyor?" Rakamlar SUNUCUDAN (TeklifIcmalUclari): tutar teklif dip toplamı (KDV hariç, TL), dönüşüm teklif
 * satırından türeyen sipariş / irsaliye / fatura. Süresi dolan teklif gece kendiliğinden "kaybedildi · süre
 * doldu" olur. Ekran toplamaz, yalnız gösterir.
 */
type Sekme = 'hun' | 'tek' | 'tem' | 'mus' | 'kat' | 'kay' | 'tak' | 'onz';

const DURUM_SINIF: Record<TeklifDurumu, string> = {
  dondu: 'ok', kismen: 'ok', kaybedildi: 'kir', iptal: 'pas', kabul: 'mavi', suresi_doldu: 'sari', hazirlaniyor: 'pas', bekliyor: 'mavi',
};

/** Dönüşüm çubuğu: yüksek yeşil, düşük kırmızı (eşik sunucunun "düşük dönüşüm" yüzdesi). */
const DonusumCubugu = ({ y, dusuk }: { y: number; dusuk: number }) => (
  <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}>
    <Cubuk yuzde={y} renk={y >= 40 ? '#2e7d46' : y < dusuk ? '#c0413d' : undefined} />{yuzde(y)}
  </span>
);

export function TeklifIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gz = useGezinti();
  const bas = arama.get('bas') ?? yilBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const sube = Number(arama.get('sube') ?? 0);
  const temsilci = Number(arama.get('temsilci') ?? 0);
  const adetKipi = arama.get('kip') === 'adet';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('hun');
  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<TeklifSatiri | null>(null);
  const [kayipPenceresi, setKayipPenceresi] = useState<TeklifSatiri | null>(null);
  const [surum, setSurum] = useState(0);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit });
    if (sube) q.set('sube', String(sube));
    if (temsilci) q.set('temsilci', String(temsilci));
    teklifIcmalUclari.teklifIcmali(q).then(v => { setVeri(v); setSecili(null) }).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, sube, temsilci, surum]);

  const q = ara.trim().toLocaleLowerCase('tr');
  const teklifler = useMemo(() => (veri?.teklifler ?? []).filter(t => !q || t.no.toLocaleLowerCase('tr').includes(q)
    || t.cari.toLocaleLowerCase('tr').includes(q) || t.temsilci.toLocaleLowerCase('tr').includes(q)), [veri, q]);
  const o = veri?.ozet;
  const dusuk = veri?.esik.dusukYuzde ?? 25;
  const yetkili = !!veri?.yetkiler.kayip;
  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tümü';
  const temsilciAdi = temsilci ? veri?.secim.temsilciler.find(t => t.id === temsilci)?.ad ?? '' : 'Tümü';
  const kayipYapilabilir = (t: TeklifSatiri | null) => !!t && ['bekliyor', 'hazirlaniyor', 'kabul', 'suresi_doldu'].includes(t.durum);
  const cariKarti = (t: { tarafId: number; musteri: boolean; tedarikci: boolean }) => gz.cariKarti(t.tarafId, t.tedarikci && !t.musteri);

  const a4 = veri && <TeklifA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} temsilci={temsilciAdi} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Teklif / Fırsat Dönüşüm İcmali</h1><span className="yol">Satış › İcmaller › Teklif / Fırsat Dönüşüm İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Dönüşüm İcmali" dosyaAdi={`Teklif Dönüşüm İcmali ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={!secili} onClick={() => secili && gz.belgeKarti(secili.id)} title={secili ? '' : 'Önce bir teklif satırına tıklayın'}>📝 Teklif kartı</button>
        <button disabled={!secili || !yetkili || !kayipYapilabilir(secili)} onClick={() => secili && setKayipPenceresi(secili)}
          title={!yetkili ? 'Yetkiniz yok (satis.teklif_kayip)' : !secili ? 'Önce bir teklif seçin' : kayipYapilabilir(secili) ? '' : 'Bu teklif açık değil'}>✖ Kaybedildi işaretle</button>
        <button onClick={() => gz.git('/firsat')}>🧲 Fırsat listesi</button>
        <span className="sp" />
        <button onClick={() => gz.git('/satis-icmali')}>🛍️ Satış İcmali</button>
        <button onClick={() => gz.git('/temsilci-performans')}>👔 Temsilci Performans</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu" onClick={() => setBilgi('')}>{bilgi}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (!e.target.value) return; const [b1, b2] = hazirDonem(e.target.value); degistir({ bas: b1, bit: b2 }) }}>
            <option value="">hazır…</option><option value="buay">Bu ay</option><option value="gecenay">Geçen ay</option>
            <option value="son3">Son 3 ay</option><option value="buyil">Bu yıl</option><option value="gecenyil">Geçen yıl</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">👤 Temsilci:
          <select value={temsilci} onChange={e => degistir({ temsilci: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.temsilciler ?? []).map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
          </select></div>
        <div className="si-seg" title="Dönüşüm oranı tutara ya da teklif adedine göre">
          <button type="button" className={!adetKipi ? 'on' : ''} onClick={() => degistir({ kip: '' })}>Tutar</button>
          <button type="button" className={adetKipi ? 'on' : ''} onClick={() => degistir({ kip: 'adet' })}>Adet</button>
        </div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.dolacakAdet > 0 && <span className="bo-rz sari">{veri!.takipGun} gün içinde süresi dolacak: {o.dolacakAdet}</span>}
        {veri && !veri.otomatikKayip && <span className="bo-rz mavi" title="Genel Ayarlar › teklif.otomatik_kayip = 0">Süresi dolan teklif kendiliğinden kaybedilmiyor</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Verilen Teklif" deg={sayi(o.teklif)} alt={`${kisa(o.tutar, '')}${o.iptal ? ` · ${o.iptal} iptal hariç` : ''}`} sinif="mor" />
          <Kutu bas="Siparişe Dönen" deg={yuzde(adetKipi ? o.donusumAdet : o.donusumTutar)}
            alt={`${adetKipi ? 'adetçe' : 'tutarca'} · ${o.donenAdet} teklif · ${kisa(o.donenTutar, '')}`} sinif="iyi" />
          <Kutu bas="Kaybedilen" deg={yuzde(adetKipi ? (o.teklif ? Math.round(1000 * o.kaybedilenAdet / o.teklif) / 10 : 0) : o.kayipOran)}
            alt={`${o.kaybedilenAdet} teklif · ${kisa(o.kaybedilenTutar, '')}`} sinif={o.kaybedilenAdet ? 'teh' : ''} />
          <Kutu bas="Bekleyen" deg={sayi(o.bekleyenAdet)} alt={kisa(o.bekleyenTutar, '')} />
          <Kutu bas="Ort. Dönüş Süresi" deg={o.ortDonusGun == null ? '—' : `${sayi(o.ortDonusGun)} gün`} alt="tekliften siparişe" />
          <Kutu bas="Ort. Teklif İskontosu" deg={yuzde(o.ortIskonto)} alt={`kazanılanda ${yuzde(o.kazanilanIskonto)}`} sinif={o.ortIskonto > 10 ? 'uy' : ''} />
          <Kutu bas="Açık Fırsat Hunisi" deg={kisa(o.firsat.acikTutar, '')} alt={`${o.firsat.acik} fırsat · ağırlıklı ${kisa(o.firsat.agirlikli, '')}`} />
          <Kutu bas="Süresi Dolup Kaybedilen" deg={sayi(o.sureDolanAdet)} alt={o.sureDolanAdet ? `${kisa(o.sureDolanTutar, '')} · kendiliğinden kayba düştü` : 'yok'}
            sinif={o.sureDolanAdet ? 'teh' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['hun', 'Huni', null], ['tek', 'Teklifler', veri.teklifSayi], ['tem', 'Temsilci', null], ['mus', 'Müşteri', null],
              ['kat', 'Ürün / Kategori', null], ['kay', 'Kayıp Nedeni', veri.kayipToplam.adet || null],
              ['tak', 'Takip Bekleyen', veri.takip.length || null], ['onz', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'hun' && <>
              <Kutucuk baslik="Fırsat → teklif → sipariş hunisi" not="aşama geçişi fırsat ve teklif durumlarından">
                <table className="hi-tablo"><thead><tr><th>Aşama</th><th className="sag">Adet</th><th className="sag">Tutar</th>
                  <th>Önceki aşamadan geçiş</th><th className="sag">Ort. bekleme</th></tr></thead>
                  <tbody>{veri.huni.map(h => (
                    <tr key={h.asama}><td>{h.asama}</td><td className="sag">{sayi(h.adet)}</td><td className="sag">{tl(h.tutar)}</td>
                      <td>{h.gecis == null ? '—' : <DonusumCubugu y={h.gecis} dusuk={dusuk} />}</td>
                      <td className="sag">{h.ortGun == null ? '—' : `${sayi(h.ortGun)} gün`}</td></tr>))}</tbody>
                </table>
              </Kutucuk>
              <div className="ki-soluk si-not">Fırsatsız doğrudan verilen teklif huniye "Teklif verildi" aşamasından girer; fırsat sayısı tekliften azsa geçiş
                %100'ü aşabilir. Siparişe dönüş: teklif satırından türeyen sipariş / irsaliye / fatura satırı (belge dönüşüm izi); bekleme teklif tarihinden ilk
                siparişe, faturada siparişten faturaya. Tutarlar KDV hariç, dövizli teklif teklif tarihindeki kurla.</div>
            </>}

            {sekme === 'tek' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Teklif no, müşteri ya da temsilci…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">satıra tıkla: seç (kart / kaybedildi) · çift tık: teklif kartı · müşteriye tıkla: cari kartı</span>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Teklif</th><th>Tarih</th><th>Müşteri</th><th>Temsilci</th><th className="sag">Tutar</th><th className="sag">İskonto</th>
                    <th>Geçerlilik</th><th>Durum</th><th className="sag">Dönen</th></tr></thead>
                  <tbody>
                    {teklifler.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde teklif yok.</td></tr>}
                    {teklifler.slice(0, 500).map(t => (
                      <tr key={t.id} className={'ac' + (secili?.id === t.id ? ' ti-sec' : '')} onClick={() => setSecili(t)} onDoubleClick={() => gz.belgeKarti(t.id)}>
                        <td><span className="lnk" onClick={e => { e.stopPropagation(); gz.belgeKarti(t.id) }}>{t.no}</span>
                          {t.revize && <span className="bo-rz mor" style={{ marginLeft: 4 }}>rev. {t.revize}</span>}</td>
                        <td>{tarihT(t.tarih)}</td>
                        <td><span className="lnk" onClick={e => { e.stopPropagation(); cariKarti(t) }}>{t.cari}</span></td>
                        <td className={t.temsilci === '(temsilcisiz)' ? 'ki-soluk' : ''}>{t.temsilci}</td>
                        <td className="sag">{tl(t.tutar)}</td><td className="sag">{yuzde(t.iskonto)}</td>
                        <td>{t.gecerlilik ? tarihT(t.gecerlilik) : <span className="ki-soluk">süresiz</span>}</td>
                        <td><span className={'bo-rz ' + DURUM_SINIF[t.durum]} title={t.rakip ? `rakip: ${t.rakip}${t.rakipFiyat != null ? ` · ${tl(t.rakipFiyat)}` : ''}` : ''}>{t.durumAdi}</span></td>
                        <td className="sag">{t.donenTutar ? tl(t.donenTutar) : '—'}</td></tr>
                    ))}
                    {teklifler.length > 500 && <tr><td colSpan={9} className="bos">… {teklifler.length - 500} teklif daha (aramayla daraltın)</td></tr>}
                    <tr className="top"><td colSpan={4}>Toplam ({o.teklif} teklif{o.iptal ? `, ${o.iptal} iptal hariç` : ''})</td>
                      <td className="sag">{tl(o.tutar)}</td><td className="sag">{yuzde(o.ortIskonto)}</td><td colSpan={2} /><td className="sag">{tl(o.donenTutar)}</td></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Kısmen dönen teklif: satırlarının bir kısmı siparişe girdi - dönen tutar sütunda, oran tutar üzerinden. "Süresi doldu":
                geçerlilik bitti, gece işi henüz kayba çevirmedi. Kaybedildi yapılan teklifin nedeni durumda, rakip ipucunda görünür.</div>
            </>}

            {sekme === 'tem' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Temsilci</th><th className="sag">Teklif</th><th className="sag">Tutar</th><th className="sag">Dönen</th><th>Dönüşüm</th>
                    <th className="sag">Kayıp</th><th className="sag">Ort. iskonto</th><th className="sag">Ort. süre</th><th className="sag">Bekleyen</th></tr></thead>
                  <tbody>
                    {veri.temsilciler.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde teklif yok.</td></tr>}
                    {veri.temsilciler.map(t => (
                      <tr key={t.id} className="ac" onDoubleClick={() => degistir({ temsilci: String(t.id) })}>
                        <td className={t.id === -1 ? 'ki-soluk' : ''}>{t.ad}</td><td className="sag">{t.teklif}</td><td className="sag">{tl(t.tutar)}</td>
                        <td className="sag">{tl(t.donen)}</td>
                        <td><DonusumCubugu y={adetKipi ? t.donusumAdet : t.donusum} dusuk={dusuk} /></td>
                        <td className="sag">{tl(t.kayip)}</td>
                        <td className={'sag' + (t.ortIskonto > 10 && t.donusum < dusuk ? ' kir' : '')}>{yuzde(t.ortIskonto)}</td>
                        <td className="sag">{t.ortGun == null ? '—' : `${sayi(t.ortGun)} gün`}</td><td className="sag">{tl(t.bekleyen)}</td></tr>))}
                    <tr className="top"><td>Toplam</td><td className="sag">{veri.temsilciToplam.teklif}</td><td className="sag">{tl(veri.temsilciToplam.tutar)}</td>
                      <td className="sag">{tl(veri.temsilciToplam.donen)}</td><td>{yuzde(veri.temsilciToplam.donusum)}</td>
                      <td className="sag">{tl(veri.temsilciToplam.kayip)}</td><td className="sag">{yuzde(veri.temsilciToplam.ortIskonto)}</td>
                      <td className="sag">{veri.temsilciToplam.ortGun == null ? '—' : `${sayi(veri.temsilciToplam.ortGun)} gün`}</td>
                      <td className="sag">{tl(veri.temsilciToplam.bekleyen)}</td></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Temsilci teklifteki satıcıdır. Yüksek iskonto (%10 üstü) ile düşük dönüşüm (%{sayi(dusuk)} altı) aynı satırda kırmızı:
                iskonto dönüşüm getirmiyor. Çift tık: temsilciyle süz.</div>
            </>}

            {sekme === 'mus' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Müşteri</th><th className="sag">Teklif</th><th className="sag">Tutar</th><th className="sag">Dönen</th><th>Dönüşüm</th>
                    <th className="sag">Kayıp</th><th>Son teklif</th><th>Son sipariş</th></tr></thead>
                  <tbody>
                    {veri.musteriler.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde teklif yok.</td></tr>}
                    {veri.musteriler.slice(0, 500).map(m => (
                      <tr key={m.id} className="ac" onDoubleClick={() => gz.ekstre(m.id)}>
                        <td><span className="lnk" onClick={() => gz.cariKarti(m.id, m.tedarikci && !m.musteri)}>{m.ad}</span>
                          {m.dusuk && <span className="bo-rz kir" style={{ marginLeft: 4 }} title="çok teklif, az sipariş - fiyat karşılaştırması için teklif topluyor olabilir">düşük dönüşüm</span>}</td>
                        <td className="sag">{m.teklif}</td><td className="sag">{tl(m.tutar)}</td><td className="sag">{tl(m.donen)}</td>
                        <td><DonusumCubugu y={m.donusum} dusuk={dusuk} /></td><td className="sag">{tl(m.kayip)}</td>
                        <td>{tarihT(m.sonTeklif)}</td><td>{m.sonSiparis ? tarihT(m.sonSiparis) : '—'}</td></tr>))}
                    {veri.musteriler.length > 500 && <tr><td colSpan={8} className="bos">… {veri.musteriler.length - 500} müşteri daha</td></tr>}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Dönemde {veri.esik.dusukTeklif} ve üstü teklif alıp tutarca %{sayi(dusuk)} altında siparişe dönen müşteri kırmızı rozetle üstte.
                Son sipariş müşterinin bütün satış siparişlerinden. Çift tık: cari ekstresi.</div>
            </>}

            {sekme === 'kat' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Kategori</th><th className="sag">Teklif satırı</th><th className="sag">Teklif tutarı</th><th className="sag">Dönen</th>
                    <th>Dönüşüm</th><th className="sag">Ort. iskonto</th></tr></thead>
                  <tbody>
                    {veri.kategoriler.length === 0 && <tr><td colSpan={6} className="bos">Teklif satırı yok.</td></tr>}
                    {veri.kategoriler.map(k => (
                      <tr key={k.ad}><td>{k.ad}</td><td className="sag">{sayi(k.satir)}</td><td className="sag">{tl(k.tutar)}</td><td className="sag">{tl(k.donen)}</td>
                        <td><DonusumCubugu y={k.donusum} dusuk={dusuk} /></td><td className="sag">{yuzde(k.ortIskonto)}</td></tr>))}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">Teklif dip toplamı satır tutarı payıyla kategorilere bölüştürülür; dönen satırın türeyen miktar oranıyla. Hizmet satırları
                "(hizmet)" altında. İskonto: satırın adet × birim fiyatı ile tutarı arasındaki fark.</div>
            </>}

            {sekme === 'kay' && <>
              <Kutucuk baslik="Kayıp nedenleri" not="teklif kaybedildi işaretlenirken neden zorunlu">
                <table className="hi-tablo"><thead><tr><th>Neden</th><th className="sag">Teklif</th><th className="sag">Tutar</th><th>Pay</th>
                  <th>Rakip (girildiyse)</th><th className="sag">Ort. fiyat farkı</th></tr></thead>
                  <tbody>
                    {veri.kayiplar.length === 0 && <tr><td colSpan={6} className="bos">Bu dönemde kaybedilen teklif yok.</td></tr>}
                    {veri.kayiplar.map(k => (
                      <tr key={k.neden}><td>{k.ad}</td><td className="sag">{k.adet}</td><td className="sag">{tl(k.tutar)}</td>
                        <td><span style={{ display: 'inline-flex', alignItems: 'center', gap: 6 }}><Cubuk yuzde={k.pay} />{yuzde(k.pay)}</span></td>
                        <td>{k.rakipler || '—'}</td><td className="sag">{k.ortFiyatFark == null ? '—' : yuzde(k.ortFiyatFark)}</td></tr>))}
                    {veri.kayipToplam.adet > 0 && <tr className="top"><td>Toplam</td><td className="sag">{veri.kayipToplam.adet}</td>
                      <td className="sag">{tl(veri.kayipToplam.tutar)}</td><td colSpan={3} /></tr>}
                  </tbody></table>
              </Kutucuk>
              <div className="ki-soluk si-not">"Süre doldu": geçerliliği biten, hiç satırı dönmemiş teklif gece kendiliğinden kayba düşer. Ortalama fiyat farkı:
                teklif tutarının girilen rakip fiyatından yüzde farkı. Neden listesi Ayarlar › Kod Listeleri › teklif.kayip_nedeni.</div>
            </>}

            {sekme === 'tak' && <>
              <Kutucuk baslik="Takip bekleyen teklifler" not={`geçerliliği ${veri.takipGun} gün içinde bitiyor ya da ${veri.takipGun} gündür hareket yok · satıra tıkla: seç`}>
                <table className="hi-tablo"><thead><tr><th>Teklif</th><th>Müşteri</th><th>Temsilci</th><th className="sag">Tutar</th><th>Geçerlilik</th>
                  <th className="sag">Son hareket</th><th>Durum</th></tr></thead>
                  <tbody>
                    {veri.takip.length === 0 && <tr><td colSpan={7} className="bos">Takip bekleyen teklif yok.</td></tr>}
                    {veri.takip.map(t => (
                      <tr key={t.id} className={'ac' + (secili?.id === t.id ? ' ti-sec' : '')} onDoubleClick={() => gz.belgeKarti(t.id)}
                        onClick={() => setSecili(veri.teklifler.find(x => x.id === t.id) ?? {
                          id: t.id, no: t.no, tarih: t.tarih, tarafId: t.tarafId, cari: t.cari, musteri: t.musteri, tedarikci: t.tedarikci,
                          temsilci: t.temsilci, tutar: t.tutar, iskonto: 0, gecerlilik: t.gecerlilik, revize: '', konu: '', durum: 'bekliyor',
                          durumAdi: 'bekliyor', donenTutar: 0, donenOran: 0, rakip: '', sistem: false })}>
                        <td><span className="lnk" onClick={e => { e.stopPropagation(); gz.belgeKarti(t.id) }}>{t.no}</span></td>
                        <td>{t.cari}</td><td className={t.temsilci === '(temsilcisiz)' ? 'ki-soluk' : ''}>{t.temsilci}</td>
                        <td className="sag">{tl(t.tutar)}</td><td>{t.gecerlilik ? tarihT(t.gecerlilik) : <span className="ki-soluk">süresiz</span>}</td>
                        <td className="sag">{t.hareketsizGun} gün</td>
                        <td><span className={'bo-rz ' + (t.durum === 'bugun' || t.durum === 'yarin' ? 'kir' : 'sari')}>{t.durumAdi}</span></td></tr>))}
                  </tbody></table>
              </Kutucuk>
              <div className="ki-soluk si-not">Geçerliliği biten teklif o gece kendiliğinden "kaybedildi · süre doldu" olur ve bu listeden çıkar - süresi dolmadan
                sipariş alınmalı ya da geçerlilik uzatılmalı (teklif kartında Geçerlilik Süresi). Kısmen dönen teklif kayba düşmez.</div>
            </>}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.teklif} teklif</span><span>{o.firsat.adet} fırsat</span><span>Dönem: {tarihT(veri.bas)} – {tarihT(veri.bit)}</span>
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}

      {kayipPenceresi && veri && (
        <KayipPenceresi t={kayipPenceresi} nedenler={veri.secim.kayipNedenleri} onKapat={() => setKayipPenceresi(null)}
          onTamam={m => { setBilgi(m); setKayipPenceresi(null); setSurum(s => s + 1) }} />
      )}
    </div>
  );
}

function KayipPenceresi({ t, nedenler, onKapat, onTamam }: {
  t: TeklifSatiri; nedenler: { id: number; ad: string }[]; onKapat(): void; onTamam(metin: string): void;
}) {
  const [neden, setNeden] = useState(0);
  const [rakip, setRakip] = useState('');
  const [fiyat, setFiyat] = useState('');
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const kaydet = async () => {
    if (!neden) { setHata('Kayıp nedeni seçilmeli.'); return }
    const metin = fiyat.trim().replace(/\./g, '').replace(',', '.');
    const deger = metin === '' ? null : Number(metin);
    if (deger != null && (!Number.isFinite(deger) || deger < 0)) { setHata('Rakip fiyatı sayı olmalı.'); return }
    setIsliyor(true); setHata('');
    try {
      await teklifIcmalUclari.teklifKayip({ belgeId: t.id, neden, rakip: rakip.trim(), rakipFiyat: deger, aciklama: aciklama.trim() });
      onTamam(`${t.no}: kaybedildi işaretlendi.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };
  return (
    <Modal baslik={`✖ Kaybedildi işaretle · ${t.no}`} dar buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="b" disabled={isliyor} onClick={() => void kaydet()}>Kaybedildi</button>
        <button type="button" className="d" onClick={onKapat}>✖ Vazgeç</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="not">{t.cari} · {tl(t.tutar)} ₺ · {t.temsilci}</div>
      <div className="alan"><label>Kayıp nedeni (zorunlu)</label>
        <select value={neden} onChange={e => setNeden(Number(e.target.value))}>
          <option value={0}>— seçin —</option>
          {nedenler.map(n => <option key={n.id} value={n.id}>{n.ad}</option>)}
        </select></div>
      <div className="alan"><label>Rakip (isteğe bağlı)</label>
        <input value={rakip} maxLength={120} onChange={e => setRakip(e.target.value)} /></div>
      <div className="alan"><label>Rakip fiyatı, KDV hariç (isteğe bağlı)</label>
        <input value={fiyat} inputMode="decimal" onChange={e => setFiyat(e.target.value)} /></div>
      <div className="alan"><label>Açıklama</label>
        <textarea value={aciklama} maxLength={300} rows={2} onChange={e => setAciklama(e.target.value)} /></div>
      <div className="not">Teklif durumu "Red" olur ve dönüşüm hesabında kayıp sayılır; değişiklik loglanır. Satırları siparişe dönmüş teklif kaybedilemez.</div>
    </Modal>
  );
}

/** A4: temsilci bazında dönüşüm + toplamlar. */
function TeklifA4({ v, antet, duzenleyen, sube, temsilci }: {
  v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; sube: string; temsilci: string;
}) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>TEKLİF / FIRSAT DÖNÜŞÜM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Şube: {sube} · Temsilci: {temsilci}</span>
        <span>Tutar: KDV hariç, TL karşılığı</span><span>{o.teklif} teklif · {o.firsat.adet} fırsat</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Temsilci</th><th>Teklif</th><th>Tutar</th><th>Dönen</th><th>Dönüşüm</th></tr></thead>
        <tbody>{v.temsilciler.map(t => <tr key={t.id}><td>{t.ad}</td><td>{t.teklif}</td><td>{tl(t.tutar)}</td><td>{tl(t.donen)}</td>
          <td>{yuzde(t.donusum)}</td></tr>)}</tbody>
      </table>
      <div className="ti-dip">
        <div><span>Verilen</span><span>{tl(o.tutar)}</span></div>
        <div><span>Kaybedilen</span><span>{tl(o.kaybedilenTutar)}</span></div>
        <div><span>Bekleyen</span><span>{tl(o.bekleyenTutar)}</span></div>
        <div className="b"><span>SİPARİŞE DÖNEN</span><span>{tl(o.donenTutar)} ₺ · {yuzde(o.donusumTutar)}</span></div>
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Genel Müdür<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Teklif / Fırsat Dönüşüm İcmali · {o.dolacakAdet} teklifin süresi {v.takipGun} gün içinde doluyor
        {o.sureDolanAdet > 0 && ` · ${o.sureDolanAdet} teklif süre dolduğu için kaybedildi`}</p>
    </div>
  );
}

export default TeklifIcmali;
