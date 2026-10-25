import { Fragment, useEffect, useMemo, useState, type ReactNode } from 'react';
import { ApiHatasi, hataMetni } from '../../api/sozlesme';
import type { BelgeYaniti } from '../../api/sozlesme';
import {
  eslesmeIcmalUclari, type BaglaYaniti, type EIrsaliyeDurumu, type EslesmeIcmali as Veri, type EslesmeYon,
  type FaturasizIrsaliye, type IrsaliyesizFatura,
} from '../../api/uclar/eslesmeIcmal';
import { BelgeDonusumModali } from '../../bilesenler/BelgeDonusumModali';
import { bugunIso } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { BelgeKarti } from '../BelgeKarti';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { kisaTl, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';

/**
 * İRSALİYE-FATURA EŞLEŞME İCMALİ `/irsaliye-fatura-eslesme` - mockup
 * Ekranlar/İcmal/irsaliye_fatura_eslesme_icmali.html (kararlar 25.10.2026).
 * "Hangi irsaliyenin faturası kesilmedi / gelmedi, nerede miktar ya da fiyat tutmuyor, hangi
 * fatura irsaliyesiz kesilip stoğu iki kez düşürdü?" Eşleşme ve rakamlar sunucuda
 * (EslesmeIcmalUclari); ekran toplamaz.
 *
 * FATURALA: mevcut dönüşüm akışı (BelgeDonusumModali → POST /api/belge/{id}/donustur) - burada
 * ayrı fatura üretici yok. Mevcut akış her irsaliyeden AYRI fatura keser; birden çok irsaliye
 * seçilince sırayla açılır.
 * BAĞLA: irsaliyesiz faturayı açık irsaliyeye bağlar, faturanın stok etkisini kaldırır (loglu).
 * Kapanmış dönemde sunucu onay ister (engel.kod = KAPANMIS_DONEM).
 */
type Sekme = 'fsiz' | 'kismi' | 'isiz' | 'cari' | 'onz';

const E_IRSALIYE: Record<EIrsaliyeDurumu, [string, string]> = {
  kabul: ['ok', 'kabul edildi'], red: ['kir', 'reddedildi'], sure: ['sari', 'yanıt süresi doldu'],
  bekliyor: ['sari', 'yanıt bekliyor'], gonderildi: ['mavi', 'gönderildi'], hazir: ['sari', 'hazır · gönderilmedi'],
  kagit: ['', 'kağıt'],
};
const ERozet = ({ d }: { d: EIrsaliyeDurumu }) => <span className={'bo-rz ' + E_IRSALIYE[d][0]}>{E_IRSALIYE[d][1]}</span>;
const YON_AD: Record<EslesmeYon, string> = { satis: 'Satış (giden)', alis: 'Alış (gelen)', ikisi: 'İkisi' };
const yilBasi = () => bugunIso().slice(0, 4) + '-01-01';

const EK_STIL = `
.ife .bo-rz.mor { background:#f1ecfa; color:#6a3fb5; border-color:#ddd0f2; }
.ife .hi-tablo .orta { text-align:center; }
.ife .ife-durum { display:flex; gap:14px; padding:5px 12px; margin-top:8px; background:#f3f6fa; border:1px solid #e3e9f0;
  border-radius:3px; font-size:11px; color:#6b7a8b; flex-wrap:wrap; }
.ife .ife-durum .sp { margin-left:auto; }
.ife .ife-oneri { white-space:normal; font-size:11px; color:#3a4c5e; }
.ife .bilgi-kutusu.ife-tamam { margin:6px 0; padding:6px 10px; background:#e2f3e8; border:1px solid #bfe3cb; border-radius:4px; }
`;

export function IrsaliyeFaturaEslesme() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const yon = (arama.get('yon') ?? 'satis') as EslesmeYon;
  const bas = arama.get('bas') ?? yilBasi();
  const bit = arama.get('bit') ?? bugunIso();
  const cari = Number(arama.get('cari') ?? 0);
  const sube = Number(arama.get('sube') ?? 0);
  const esik = Number(arama.get('esik') ?? 7);
  const tam = arama.get('tam') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState<{ metin: string; belgeler?: { id: number; no: string }[] } | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [tazele, setTazele] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('fsiz');
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [acikDetay, setAcikDetay] = useState<Set<number>>(new Set());
  const [seciliFatura, setSeciliFatura] = useState<number | null>(null);
  const [acikBelge, setAcikBelge] = useState<number | null>(null);
  const [kuyruk, setKuyruk] = useState<{ id: number; tur: number; yon: 'satis' | 'alis' }[]>([]);
  const [uretilen, setUretilen] = useState<{ id: number; no: string }[]>([]);
  const [isliyor, setIsliyor] = useState(false);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ yon, bas, bit, esik: String(esik) });
    if (cari) q.set('cari', String(cari));
    if (sube) q.set('sube', String(sube));
    if (tam) q.set('tam', '1');
    eslesmeIcmalUclari.eslesmeIcmali(q).then(v => {
      setVeri(v); setSecili(new Set()); setSeciliFatura(null);
    }).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [yon, bas, bit, cari, sube, esik, tam, tazele]);

  const o = veri?.ozet;
  const faturasiz = veri?.faturasiz ?? [];
  const seciliIrs = faturasiz.filter(x => secili.has(x.id));
  const seciliCariler = [...new Set(seciliIrs.map(x => x.tarafId))];
  const seciliTutar = seciliIrs.reduce((t, x) => t + x.tutar, 0);
  const toplamKalem = faturasiz.reduce((t, x) => t + x.kalem, 0);
  const cevir = (id: number) => setSecili(s => { const n = new Set(s); n.has(id) ? n.delete(id) : n.add(id); return n });
  const detayCevir = (id: number) => setAcikDetay(s => { const n = new Set(s); n.has(id) ? n.delete(id) : n.add(id); return n });
  const fatura = useMemo(() => veri?.irsaliyesiz.find(x => x.id === seciliFatura) ?? null, [veri, seciliFatura]);

  // ------------------------------------------------------------ Faturala --
  const faturala = async () => {
    setHata(''); setBilgi(null);
    if (seciliIrs.length === 0) return;
    if (seciliCariler.length !== 1) { setHata('Faturala tek cari içindir: aynı carinin irsaliyelerini seçin.'); return }
    const red = seciliIrs.filter(x => x.eIrsaliye === 'red');
    if (red.length > 0) { setHata(`Reddedilen e-İrsaliye faturalanmaz: ${red.map(x => x.no).join(', ')}.`); return }
    if (seciliIrs.length > 1 && !await onay(
      `${seciliIrs.length} irsaliye seçildi (${seciliIrs[0].cari}).\n\n`
      + 'Mevcut dönüşüm akışı (Satış / Alış İrsaliyeleri › "Faturaya Dönüştür") her irsaliyeden AYRI fatura keser; '
      + 'dönüşüm penceresi irsaliye başına sırayla açılacak. Devam edilsin mi?')) return;
    kuyrugaAl(seciliIrs.map(x => ({ id: x.id, tur: x.tur, yon: x.yon })));
  };
  const kuyrugaAl = (l: { id: number; tur: number; yon: 'satis' | 'alis' }[]) => { setBilgi(null); setUretilen([]); setKuyruk(l) };
  const kuyrukIlerle = () => {
    setKuyruk(k => {
      const kalan = k.slice(1);
      if (kalan.length === 0) setTazele(t => t + 1);
      return kalan;
    });
  };
  useEffect(() => {
    if (kuyruk.length === 0 && uretilen.length > 0)
      setBilgi({ metin: `${uretilen.length} fatura oluşturuldu (mevcut dönüşüm akışı, kesin belge) — kontrol için açın:`, belgeler: uretilen });
  }, [kuyruk.length, uretilen]);

  // ------------------------------------------------------------ Bağla --
  const bagla = async (f: IrsaliyesizFatura) => {
    setHata(''); setBilgi(null);
    const ciftler = f.eslesme.filter(x => x.irsaliyeSatirId != null);
    if (ciftler.length === 0) {
      setHata(f.lotlu
        ? 'Bu faturanın stoklu kalemleri lot / seri izlemli; bu ekrandan bağlanamaz. Faturayı iptal edip irsaliyeden "Faturaya Dönüştür" ile yeniden kesin.'
        : 'Bu faturanın kalemleri için kalanı yeten açık irsaliye satırı yok.');
      return;
    }
    const atlanan = f.eslesme.length - ciftler.length;
    const metin = `${f.no} (${f.cari}) faturasının ${ciftler.length} stoklu kalemi irsaliyeye bağlanacak:\n\n`
      + ciftler.map(x => `• ${x.kod} × ${sayi(x.miktar)} → ${x.irsaliyeNo} (faturalanmamış ${sayi(x.irsaliyeKalan ?? 0)})`).join('\n')
      + `\n\nFaturanın bu satırlarla yaptığı stok ${f.yon === 'satis' ? 'çıkışı' : 'girişi'} geri alınır (irsaliye malı zaten `
      + `${f.yon === 'satis' ? 'düşürdü' : 'girdi'}). Cari ve fatura tutarı değişmez. İşlem loglanır.`
      + (atlanan > 0 ? `\n\n${atlanan} kalem bağlanmaz (lot izlemli ya da uygun açık irsaliye satırı yok).` : '')
      + (f.kapanmisDonem ? '\n\n⚠ KAPANMIŞ DÖNEM: fatura ya da irsaliye kapanmış döneme ait. Onaylarsanız işlem dönem bilgisiyle loglanır.' : '');
    if (!await onay(metin, f.kapanmisDonem)) return;
    const satirlar = ciftler.map(x => ({ faturaSatirId: x.faturaSatirId, irsaliyeSatirId: x.irsaliyeSatirId! }));
    setIsliyor(true);
    try {
      let y: BaglaYaniti;
      try {
        y = await eslesmeIcmalUclari.bagla(f.id, satirlar, f.kapanmisDonem);
      } catch (h) {
        const engel = h instanceof ApiHatasi ? (h.hata.engel as unknown as { kod?: string } | undefined) : undefined;
        if (engel?.kod !== 'KAPANMIS_DONEM') throw h;
        if (!await onay(`⚠ KAPANMIŞ DÖNEM\n\n${(h as ApiHatasi).hata.mesaj}\n\nYine de bağlansın mı?`, true)) return;
        y = await eslesmeIcmalUclari.bagla(f.id, satirlar, true);
      }
      setBilgi({
        metin: `${y.faturaNo}: ${y.baglanan} satır ${y.irsaliyeler.map(i => i.no).join(', ')} irsaliyesine bağlandı, faturanın stok etkisi kaldırıldı.`
          + (y.kapanmisDonem ? ` Kapanmış dönem (${y.donemler.join(', ')}) loglandı.` : '')
          + (y.uyarilar.length ? ' ' + y.uyarilar.join(' ') : ''),
        belgeler: [{ id: y.faturaId, no: y.faturaNo }],
      });
      setTazele(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  const cariAdi = cari ? veri?.secim.cariler.find(x => x.id === cari)?.ad ?? '' : 'Tümü';
  const subeAdi = sube ? veri?.secim.subeler.find(x => x.id === sube)?.ad ?? '' : 'Tüm şubeler';
  const irsTanim = yon === 'alis' ? 'alış' : yon === 'satis' ? 'satış' : 'satış / alış';
  const a4 = veri && <EslesmeA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />;

  return (
    <div className="hi ife">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + EK_STIL}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>İrsaliye-Fatura Eşleşme İcmali</h1>
          <span className="yol">Satış › İcmaller › İrsaliye-Fatura Eşleşme İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Eşleşme İcmali" dosyaAdi={`İrsaliye-Fatura Eşleşme İcmali ${bas} ${bit}`} devre={!veri}>
          {a4}
        </CiktiMenusu>
        <div className="sepv" />
        {veri?.yetkiler.faturala && (
          <button disabled={isliyor || seciliIrs.length === 0} onClick={() => void faturala()}
            title="Seçili irsaliyeler (tek cari) mevcut dönüşüm akışıyla faturaya dönüştürülür">
            🧾 Seçili irsaliyeleri faturala…{seciliIrs.length ? ` (${seciliIrs.length})` : ''}</button>
        )}
        {veri?.yetkiler.bagla && (
          <button disabled={isliyor || !fatura} onClick={() => fatura && void bagla(fatura)}
            title="İrsaliyesiz Faturalar sekmesinde seçili faturayı aynı carinin açık irsaliyesine bağlar">
            🔗 Seçili faturayı irsaliyeye bağla…</button>
        )}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && (
        <div className="bilgi-kutusu ife-tamam">{bilgi.metin}{' '}
          {bilgi.belgeler?.map(x => <span key={x.id} className="lnk" style={{ marginRight: 8 }} onClick={() => setAcikBelge(x.id)}>{x.no}</span>)}
        </div>
      )}

      <div className="hi-serit">
        <div className="si-seg">
          {(['satis', 'alis', 'ikisi'] as const).map(k =>
            <button key={k} type="button" className={yon === k ? 'on' : ''} onClick={() => degistir({ yon: k === 'satis' ? '' : k })}>{YON_AD[k]}</button>)}
        </div>
        <div className="sel">📅 İrsaliye tarihi:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} /> –
          <input type="date" value={bit} min={bas} onChange={e => e.target.value && degistir({ bit: e.target.value })} /></div>
        <div className="sel">💼 Cari:
          <select value={cari} onChange={e => degistir({ cari: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.cariler ?? []).map(c => <option key={c.id} value={c.id}>{c.ad}</option>)}
          </select></div>
        {(veri?.secim.subeler.length ?? 0) > 1 && (
          <div className="sel">🏢 Şube:
            <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri!.secim.subeler.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select></div>
        )}
        <div className="sel">⏱ Bekleme eşiği:
          <select value={esik} onChange={e => degistir({ esik: e.target.value === '7' ? '' : e.target.value })}>
            {[3, 5, 7, 10, 15, 30].map(g => <option key={g} value={g}>{g} gün</option>)}
          </select></div>
        <label className="chk"><input type="checkbox" checked={tam} onChange={e => degistir({ tam: e.target.checked ? '1' : '' })} /> Tam eşleşenleri de göster</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {veri && <span className={'bo-rz ' + (veri.aySonuKalanGun <= 7 ? 'kir' : '')}
          title={`Açık dönem başı: ${tarihT(veri.acikDonemBasi)} (Genel Ayarlar › muhasebe.donem_kapanis_tarihi; yoksa önceki aylar kapalı sayılır)`}>
          Ay sonu kapanışı: {veri.aySonuKalanGun === 0 ? 'bugün' : `${veri.aySonuKalanGun} gün kaldı`}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Faturalanmamış İrsaliye" deg={sayi(o.faturasiz)} alt={`${kisaTl(o.faturasizTutar)} · en eski ${o.enEskiGun} gün`} sinif={o.faturasiz ? 'teh' : ''} />
          <Kutu bas="Kısmi Faturalanan" deg={sayi(o.kismi)} alt={`irsaliye · kalan ${kisaTl(o.kismiKalan)}`} sinif={o.kismi ? 'uy' : ''} />
          <Kutu bas="İrsaliyesiz Fatura" deg={sayi(o.irsaliyesiz)} alt={`stoklu kalemi var · ${o.supheli} mükerrer şüphesi`} />
          <Kutu bas="Miktar Farkı" deg={sayi(o.miktarFarki)} alt={`satır · fatura ≠ irsaliye · ${o.fazla} fazla`} sinif={o.fazla ? 'teh' : ''} />
          <Kutu bas="Fiyat Farkı" deg={sayi(o.fiyatFarki)} alt={`irsaliye fiyatından sapma · ${kisaTl(o.fiyatFarkTutar)}`} sinif={o.fiyatFarki ? 'uy' : ''} />
          <Kutu bas="Tam Eşleşen" deg={sayi(o.tam)} alt={`irsaliye · %${o.tamOran.toLocaleString('tr-TR')}`} sinif="iyi" />
          <Kutu bas="Ort. Faturalama Süresi" deg={o.ortSure != null ? `${o.ortSure.toLocaleString('tr-TR')} gün` : '—'} alt="irsaliye → fatura" />
          <Kutu bas="Yasal Süre Aşımı" deg={sayi(o.sureAsimi)} alt={`${veri.esik} günden uzun faturasız (VUK 231/5) · konsinye muaf`} sinif={o.sureAsimi ? 'teh' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['fsiz', 'Faturalanmamış İrsaliyeler', faturasiz.length], ['kismi', 'Kısmi / Fark', veri.farklar.length],
              ['isiz', 'İrsaliyesiz Faturalar', veri.irsaliyesiz.length], ['cari', 'Cari Bazında', null], ['onz', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'fsiz' && (
              <Kutucuk baslik={`Faturası kesilmemiş ${irsTanim} irsaliyeleri`}
                not={'kutucukla seç → "faturala" (aynı cari) · satıra tıkla: kalemler · çift tık: irsaliye kartı · süre aşımı önde, sonra tarih'}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th style={{ width: 24 }}><input type="checkbox" checked={faturasiz.length > 0 && faturasiz.every(x => secili.has(x.id))}
                      onChange={e => setSecili(e.target.checked ? new Set(faturasiz.map(x => x.id)) : new Set())} /></th>
                      <th>İrsaliye No</th><th>Tarih</th>{yon === 'ikisi' && <th>Yön</th>}<th>{yon === 'alis' ? 'Tedarikçi' : yon === 'satis' ? 'Müşteri' : 'Cari'}</th>
                      <th>Depo</th><th className="sag">Kalem</th><th className="sag">Tutar</th><th className="orta">Bekleyen</th><th>e-İrsaliye</th><th>Not</th></tr></thead>
                    <tbody>
                      {faturasiz.length === 0 && <tr><td colSpan={11} className="bos">Bu süzgeçte faturası kesilmemiş irsaliye yok.</td></tr>}
                      {faturasiz.slice(0, 1000).map(x => (
                        <Fragment key={x.id}>
                          <tr className="ac" onClick={() => detayCevir(x.id)} onDoubleClick={() => setAcikBelge(x.id)}>
                            <td onClick={ev => ev.stopPropagation()}><input type="checkbox" checked={secili.has(x.id)} onChange={() => cevir(x.id)} /></td>
                            <td><span className="ok">{acikDetay.has(x.id) ? '▾' : '▸'}</span>
                              <span className="lnk" onClick={ev => { ev.stopPropagation(); setAcikBelge(x.id) }}>{x.no}</span></td>
                            <td>{tarihT(x.tarih)}</td>{yon === 'ikisi' && <td>{x.yon === 'satis' ? 'Satış' : 'Alış'}</td>}
                            <td>{x.cari}</td><td>{x.depo}</td>
                            <td className="sag">{x.kalem}</td><td className="sag"><b>{tl(x.tutar)}</b></td>
                            <td className="orta"><BekleyenRozet x={x} esik={veri.esik} /></td>
                            <td><ERozet d={x.eIrsaliye} /></td>
                            <td><NotHucresi x={x} esik={veri.esik} /></td>
                          </tr>
                          {acikDetay.has(x.id) && (
                            <tr className="det"><td colSpan={11} style={{ whiteSpace: 'normal', paddingLeft: 26 }}>
                              {x.kalemler.map(k => `${k.kod || k.ad} × ${sayi(k.miktar)} · ${tl(k.birimFiyat)}`).join('  ·  ')}</td></tr>
                          )}
                        </Fragment>
                      ))}
                      <tr className="top"><td colSpan={yon === 'ikisi' ? 6 : 5}>Toplam ({faturasiz.length} irsaliye){seciliIrs.length > 0 &&
                        ` · seçili ${seciliIrs.length} · ${seciliCariler.length === 1 ? seciliIrs[0].cari : `${seciliCariler.length} cari`} · ${tl(seciliTutar)}`}</td>
                        <td className="sag">{toplamKalem}</td><td className="sag">{tl(o.faturasizTutar)}</td><td colSpan={3} /></tr>
                    </tbody>
                  </table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>
                  Faturala: seçili irsaliyeler (tek cari) Satış / Alış İrsaliyeleri listesindeki "Faturaya Dönüştür" ile aynı akışla
                  faturaya dönüştürülür; mevcut akış her irsaliyeden ayrı ve kesin fatura keser, pencere irsaliye başına sırayla açılır
                  (kısmi miktar orada seçilebilir). VUK: irsaliyeden sonra {veri.esik} gün içinde fatura düzenlenmelidir; eşik değiştirilebilir.
                  Konsinye irsaliye ay sonu toplu faturalandığı için süre aşımına girmez. Reddedilen e-İrsaliye faturalanmaz.
                </div>
              </Kutucuk>
            )}

            {sekme === 'kismi' && (
              <Kutucuk baslik="Kısmi faturalanan ve farklı eşleşen irsaliyeler" not="satır bazında irsaliye ↔ fatura · irsaliyeye / faturaya tıkla: belgeyi aç">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>İrsaliye</th><th>Fatura</th><th>Cari</th><th>Kalem</th><th className="sag">İrs. Miktar</th><th className="sag">Fat. Miktar</th>
                      <th className="sag">Kalan</th><th className="sag">İrs. Fiyat</th><th className="sag">Fat. Fiyat</th><th className="sag">Fark ₺</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.farklar.length === 0 && <tr><td colSpan={11} className="bos">Kısmi, fazla ya da fiyatı farklı eşleşen satır yok.</td></tr>}
                      {veri.farklar.slice(0, 2000).map((x, i, l) => (
                        <Fragment key={x.satirId}>
                          {yon === 'ikisi' && (i === 0 || l[i - 1].yon !== x.yon) &&
                            <tr className="si-grup"><td colSpan={11}>{x.yon === 'satis' ? 'Satış (giden)' : 'Alış (gelen)'}</td></tr>}
                          <tr>
                            <td><span className="lnk" onClick={() => setAcikBelge(x.irsaliyeId)}>{x.irsaliyeNo}</span></td>
                            <td>{x.faturaId ? <span className="lnk" onClick={() => setAcikBelge(x.faturaId!)}>{x.faturaNo}</span> : <span className="ki-soluk">—</span>}</td>
                            <td>{x.cari}</td><td title={x.ad}>{x.kod || x.ad}</td>
                            <td className="sag">{sayi(x.irsMiktar)}</td>
                            <td className={'sag' + (x.durum === 'fazla' ? ' kir' : '')}>{sayi(x.fatMiktar)}</td>
                            <td className={'sag' + (x.durum === 'kismi' || x.durum === 'fazla' ? ' kir' : ' ki-soluk')}>{sayi(x.kalan)}</td>
                            <td className="sag">{tl(x.irsFiyat)}</td>
                            <td className={'sag' + (x.durum === 'fiyat' ? ' kir' : '')}>{x.fatFiyat != null ? tl(x.fatFiyat) : '—'}</td>
                            <td className={'sag' + (x.fark ? ' kir' : ' ki-soluk')}>{x.fark ? (x.fark > 0 ? '+' : '') + tl(x.fark) : '—'}</td>
                            <td><FarkRozet d={x.durum} kalan={x.kalan} sapma={x.sapma} yon={x.yon} />
                              {x.konsinye && <span className="bo-rz mor" style={{ marginLeft: 4 }}>konsinye</span>}
                              {x.kalan > 0 && veri.yetkiler.faturala && x.eIrsaliye !== 'red' && (
                                <span className="lnk" style={{ marginLeft: 6 }} onClick={() => kuyrugaAl([{ id: x.irsaliyeId, tur: x.tur, yon: x.yon }])}>kalanı faturala</span>)}
                            </td>
                          </tr>
                        </Fragment>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>
                  Eşleşme belge satırının kaynak bağından (irsaliye satırı → fatura satırı; taslak ve iptal faturalar sayılmaz).
                  Fiyat farkı: fatura birim tutarı irsaliyeden hem %2 hem 1 ₺'den fazla saparsa (tutarlar KDV hariç, satırın kayıtlı tutarından).
                  Fazla faturalanan miktar stoktan ikinci kez düşmez (irsaliyeden türeyen fatura stok düşmez), ama cari borcu fazla yazılmıştır.
                </div>
              </Kutucuk>
            )}

            {sekme === 'isiz' && (
              <Kutucuk baslik="İrsaliyesiz faturalar (stoklu kalemli)" not="stok faturadan düştü · aynı carinin açık irsaliyesi varsa mükerrer stok şüphesi · satır seç → bağla">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th style={{ width: 24 }} /><th>Fatura</th><th>Tarih</th>{yon === 'ikisi' && <th>Yön</th>}<th>Cari</th>
                      <th className="sag">Stoklu kalem</th><th className="sag">Tutar</th><th>Aynı carinin açık irsaliyesi</th><th>Öneri</th></tr></thead>
                    <tbody>
                      {veri.irsaliyesiz.length === 0 && <tr><td colSpan={9} className="bos">Bu süzgeçte stoğu düşürmüş irsaliyesiz fatura yok.</td></tr>}
                      {veri.irsaliyesiz.slice(0, 1000).map(x => (
                        <tr key={x.id} className={'ac' + (seciliFatura === x.id ? ' sec' : '')} onClick={() => setSeciliFatura(x.id)}>
                          <td><input type="radio" name="ife-fatura" checked={seciliFatura === x.id} onChange={() => setSeciliFatura(x.id)} /></td>
                          <td><span className="lnk" onClick={ev => { ev.stopPropagation(); setAcikBelge(x.id) }}>{x.no}</span></td>
                          <td>{tarihT(x.tarih)}</td>{yon === 'ikisi' && <td>{x.yon === 'satis' ? 'Satış' : 'Alış'}</td>}
                          <td>{x.cari}</td><td className="sag">{x.stokluKalem}</td><td className="sag">{tl(x.tutar)}</td>
                          <td className="ife-oneri">
                            {x.acikIrsaliyeler.length === 0 ? <span className="ki-soluk">—</span>
                              : x.acikIrsaliyeler.slice(0, 4).map(a => (
                                <span key={a.id} style={{ marginRight: 8 }}>
                                  <span className="lnk" onClick={ev => { ev.stopPropagation(); setAcikBelge(a.id) }}>{a.no}</span>
                                  {` · ${kisaTl(a.tutar)} · aynı ${a.ortakKalem} kalem`}</span>))}
                            {x.acikIrsaliyeler.length > 4 && <span className="ki-soluk">… {x.acikIrsaliyeler.length - 4} irsaliye daha</span>}
                          </td>
                          <td>
                            {x.oneri === 'bagla' && <span className="bo-rz kir">mükerrer stok çıkışı şüphesi — bağla ({x.eslesenKalem}/{x.stokluKalem})</span>}
                            {x.oneri === 'incele' && <span className="bo-rz sari">açık irsaliye var, kalem / miktar tutmuyor — inceleyin</span>}
                            {x.oneri === 'normal' && <span className="bo-rz ok">normal (irsaliyesiz {x.yon === 'satis' ? 'satış' : 'alış'})</span>}
                            {x.lotlu && <span className="bo-rz" style={{ marginLeft: 4 }} title="Lot / seri izlemli kalem bu ekrandan bağlanmaz">lot izlemli</span>}
                            {x.kapanmisDonem && x.oneri !== 'normal' && <span className="bo-rz kir" style={{ marginLeft: 4 }}>kapanmış dönem</span>}
                            {x.oneri === 'bagla' && veri.yetkiler.bagla && (
                              <span className="lnk" style={{ marginLeft: 6 }} onClick={ev => { ev.stopPropagation(); if (!isliyor) void bagla(x) }}>bağla…</span>)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>
                  Fatura irsaliyesiz kesilip aynı mal için ayrıca irsaliye de kesildiyse stok iki kez düşer. "Bağla" faturanın stoklu satırlarını
                  aynı carinin açık irsaliye satırlarına (aynı stok, kalanı yeten en eski satır) dönüşümle aynı bağla bağlar ve faturanın stok etkisini
                  kaldırır (irsaliye düştüğü için); cari ve fatura tutarı değişmez, kayıt loglanır. Kapanmış dönemdeki belgede onay istenir ve dönem
                  loga işlenir. Lot / seri izlemli kalem bu ekrandan bağlanmaz.{!veri.yetkiler.bagla && ' Bağlamak için belge değiştirme yetkisi gerekir.'}
                </div>
              </Kutucuk>
            )}

            {sekme === 'cari' && (
              <Kutucuk baslik="Cari bazında eşleşme" not="açık irsaliye tutarı · faturalama süresi · açık tutara göre">
                <table className="hi-tablo">
                  <thead><tr><th>Cari</th><th>Yön</th><th className="sag">İrsaliye</th><th className="sag">Tam eşleşen</th><th className="sag">Açık</th>
                    <th className="sag">Açık Tutar</th><th className="sag">Ort. Süre</th><th className="sag">En Eski</th></tr></thead>
                  <tbody>
                    {veri.cariler.length === 0 && <tr><td colSpan={8} className="bos">Bu süzgeçte irsaliye yok.</td></tr>}
                    {veri.cariler.map(x => (
                      <tr key={`${x.tarafId}:${x.yon}`} className="ac" onClick={() => degistir({ cari: String(x.tarafId) })} title="Bu cariye süz">
                        <td>{x.cari}</td><td>{x.yon === 'satis' ? 'Satış' : 'Alış'}</td><td className="sag">{x.irsaliye}</td><td className="sag">{x.tam}</td>
                        <td className={'sag' + (x.acik ? ' kir' : '')}>{x.acik}</td><td className="sag">{tl(x.acikTutar)}</td>
                        <td className="sag">{x.ortSure != null ? `${x.ortSure.toLocaleString('tr-TR')} gün` : '—'}</td>
                        <td className={'sag' + (x.sureAsimi ? ' kir' : '')}>{x.enEski != null ? `${x.enEski} gün` : '—'}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </Kutucuk>
            )}

            {sekme === 'onz' && <div style={{ background: '#dfe5ec', padding: 16, display: 'flex', justifyContent: 'center' }}>{a4}</div>}

            <div className="ife-durum">
              <span>{sayi(o.incelenen)} irsaliye incelendi</span>
              <span>{o.faturasiz + o.kismi} açık · {o.farkSatir} farklı satır · {o.irsaliyesiz} irsaliyesiz</span>
              <span>Eşik: {veri.esik} gün</span>
              {o.konsinyeAcik > 0 && <span>{o.konsinyeAcik} açık konsinye (süre aşımından muaf)</span>}
              {o.redAcik > 0 && <span className="kir">{o.redAcik} reddedilen e-İrsaliye</span>}
              <span className="sp">{cariAdi} · {subeAdi} · hesap sunucuda · ekran toplamaz</span>
            </div>
          </div>
        </div>
      </>)}

      {kuyruk.length > 0 && (
        <BelgeDonusumModali
          key={kuyruk[0].id}
          belgeId={kuyruk[0].id}
          belgeTur={kuyruk[0].tur}
          varsayilanHedef={kuyruk[0].yon === 'satis' ? 15 : 11}
          hedefKilitli
          onKapat={kuyrukIlerle}
          onTamam={(yeni: BelgeYaniti) => {
            const id = Number(yeni.belge.id ?? 0);
            if (id) setUretilen(u => [...u, { id, no: String(yeni.belge.belgeNo || '#' + id) }]);
          }}
        />
      )}
      {acikBelge !== null && <BelgeKarti id={acikBelge} onKapat={() => { setAcikBelge(null); setTazele(t => t + 1) }} />}
    </div>
  );
}

function BekleyenRozet({ x, esik }: { x: FaturasizIrsaliye; esik: number }) {
  if (x.konsinye) return <span className="bo-rz" title="Konsinye: 7 gün uyarısından muaf">{x.bekleyen} gün</span>;
  if (x.sureAsimi) return <span className="bo-rz kir">{x.bekleyen} gün ⚠</span>;
  return <span className={'bo-rz ' + (x.bekleyen > esik / 2 ? 'sari' : '')}>{x.bekleyen} gün</span>;
}

function NotHucresi({ x, esik }: { x: FaturasizIrsaliye; esik: number }) {
  const parcalar: ReactNode[] = [];
  if (x.konsinye) parcalar.push(<Fragment key="k"><span className="bo-rz mor">konsinye</span> ay sonu faturalanır · {esik} gün uyarısından muaf </Fragment>);
  if (x.iade) parcalar.push(<span key="i" className="bo-rz" style={{ marginRight: 4 }}>iade</span>);
  if (x.eIrsaliye === 'red') parcalar.push(<span key="r" className="bo-rz kir" style={{ marginRight: 4 }}>reddedildi — faturalanmaz</span>);
  if (x.taslakFatura) parcalar.push(<span key="t" className="bo-rz sari">taslak fatura var</span>);
  return parcalar.length ? <>{parcalar}</> : <span className="ki-soluk">—</span>;
}

function FarkRozet({ d, kalan, sapma, yon }: { d: 'kismi' | 'fazla' | 'fiyat' | 'tam'; kalan: number; sapma: number; yon: 'satis' | 'alis' }) {
  if (d === 'fazla') return <span className="bo-rz kir">fazla faturalandı ({sayi(-kalan)})</span>;
  if (d === 'kismi') return <span className="bo-rz sari">kısmi · {sayi(kalan)} faturalanmadı</span>;
  if (d === 'fiyat') return <span className={'bo-rz ' + (yon === 'alis' && sapma > 0 ? 'kir' : 'sari')}>
    {yon === 'alis' && sapma > 0 ? 'tedarikçi pahalı faturaladı' : 'fiyat farkı'} ({sapma > 0 ? '+' : '−'}%{Math.abs(sapma).toLocaleString('tr-TR')})</span>;
  return <span className="bo-rz ok">tam eşleşti</span>;
}

function EslesmeA4({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>İRSALİYE - FATURA EŞLEŞME İCMALİ</h3>
      <div className="a4-hasta">
        <span>İrsaliye tarihi: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Yön: {YON_AD[v.yon]}</span>
        <span>Bekleme eşiği: {v.esik} gün</span><span>Açık: {o.faturasiz} irsaliye · {tl(o.faturasizTutar)} ₺</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>İrsaliye</th><th>Tarih</th><th>Cari</th><th>Tutar</th><th>Bekleyen</th></tr></thead>
        <tbody>{v.faturasiz.map(x => (
          <tr key={x.id}><td style={{ textAlign: 'left' }}>{x.no}{x.konsinye ? ' (konsinye)' : ''}</td><td>{tarihT(x.tarih)}</td>
            <td style={{ textAlign: 'left' }}>{x.cari}</td><td>{tl(x.tutar)}</td><td>{x.bekleyen} gün{x.sureAsimi ? ' ⚠' : ''}</td></tr>))}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Faturalanmamış</td><td>{tl(o.faturasizTutar)}</td></tr>
        <tr><td>Kısmi kalan</td><td>{tl(o.kismiKalan)}</td></tr>
        <tr><td>Fiyat farkı</td><td>{tl(o.fiyatFarkTutar)}</td></tr>
        <tr className="kalan ki-kalan"><td>FATURALANACAK</td><td>{tl(o.acikTutar)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Gentegre AI · eşleşme belge satırlarının kaynak bağından · tutarlar KDV hariç · yasal süre aşımı {o.sureAsimi} irsaliye (konsinye muaf).</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Muhasebe<br />Kaşe · İmza</div></div>
    </div>
  );
}

export default IrsaliyeFaturaEslesme;
