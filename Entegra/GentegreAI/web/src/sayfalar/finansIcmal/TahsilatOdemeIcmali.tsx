import { Fragment, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import { finansIcmalUclari, type TahsilatAraci, type TahsilatCari, type TahsilatOdemeIcmali as Veri } from '../../api/uclar/finansIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, isiRengi, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { ARAC_IKON, FINANS_ICMAL_STILI, HESAP_IKON, isaretli, useCariKarti } from './finansIcmalOrtak';

/**
 * TAHSİLAT / ÖDEME İCMALİ `/tahsilat-odeme-icmali` - mockup Ekranlar/İcmal/tahsilat_odeme_icmali.html.
 * "Bu dönem kimden ne tahsil ettik, kime ne ödedik, hangi araçla, hangi hesaba; tahsilat satışa
 * yetişiyor mu?" Rakamlar sunucuda (FinansIcmalUclari); ekran toplamaz.
 * Kararlar (25.10.2026): çekle tahsilat çekin alındığı gün; POS brüt, komisyon Gün / Hesap'ta.
 */
type Sekme = 'tur' | 'cari' | 'gun' | 'kisi' | 'dik';
const ayBasi = () => bugunYerel().slice(0, 8) + '01';
const iso = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const TUR_AD: Record<string, string> = { musteri: 'Müşteri', tedarikci: 'Tedarikçi', carisiz: '—' };
const KIRMIZI = '#c0413d';

/** Hızlı dönem seçimi (yalnız tarih üretir). */
function hizliDonem(k: string): [string, string] {
  const b = new Date();
  if (k === 'gecen') { const s = new Date(b.getFullYear(), b.getMonth(), 0); return [iso(new Date(s.getFullYear(), s.getMonth(), 1)), iso(s)] }
  if (k === '30') { const s = new Date(b); s.setDate(s.getDate() - 29); return [iso(s), iso(b)] }
  if (k === 'yil') return [`${b.getFullYear()}-01-01`, iso(b)];
  return [ayBasi(), iso(b)];
}

export function TahsilatOdemeIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici, yetki } = useOturum();
  const antet = useAntet();
  const cariKarti = useCariKarti();
  const bas = arama.get('bas') ?? ayBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const yon = (arama.get('yon') ?? 'ikisi') as Veri['yon'];
  const sube = Number(arama.get('sube') ?? 0);
  const kisi = Number(arama.get('kisi') ?? 0);
  const para = arama.get('para') ?? '';
  const virman = arama.get('virman') === '1';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>('tur');
  const [ara, setAra] = useState('');
  const [acik, setAcik] = useState<Set<string>>(new Set());
  const [secili, setSecili] = useState<TahsilatCari | null>(null);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit, yon });
    if (sube) q.set('sube', String(sube));
    if (kisi) q.set('kisi', String(kisi));
    if (para) q.set('para', para);
    if (virman) q.set('virman', '1');
    finansIcmalUclari.tahsilatOdemeIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, yon, sube, kisi, para, virman]);

  const cariler = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return (veri?.cariler ?? []).filter(c => !q || c.ad.toLocaleLowerCase('tr').includes(q) || c.kod.toLocaleLowerCase('tr').includes(q));
  }, [veri, ara]);
  const o = veri?.ozet;
  const f = (n: number) => tl(n) + (para ? ` ${para}` : '');
  const kisa = (n: number) => tl(n);
  const cevir = (k: string) => setAcik(a => { const n = new Set(a); if (n.has(k)) n.delete(k); else n.add(k); return n });
  const ekstreAc = (id: number) => { if (id) git(`/ekstre?tur=cari&id=${id}&bas=${bas}&bit=${bit}`) };
  const tahGor = yon !== 'odeme';
  const odeGor = yon !== 'tahsilat';
  const dikkatSayi = veri ? veri.dikkat.dagitilmamisAdet + veri.dikkat.iadeIptal.length + veri.dikkat.odemesiz.length + veri.dikkat.gecmisOdeme.length : null;
  const hizli = hizliDonem('ay');
  const buAy = bas === hizli[0] && bit === hizli[1];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + FINANS_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Tahsilat / Ödeme İcmali</h1><span className="yol">Finans › İcmaller › Tahsilat / Ödeme İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Tahsilat / Ödeme İcmali" dosyaAdi={`Tahsilat Ödeme İcmali ${bas} ${bit}`} devre={!veri}>
          {veri && <TahsilatA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
        </CiktiMenusu>
        <button disabled={!secili?.id} onClick={() => secili && ekstreAc(secili.id)}
          title={secili?.id ? secili.ad : 'Cari Bazında sekmesinde bir satır seçin'}>📄 Seçili carinin ekstresi</button>
        <span className="sp" />
        <button onClick={() => git('/cek-senet-icmali')}>🧾 Çek / Senet İcmali</button>
        {yetki('finans.nakit_akis_icmali') && <button onClick={() => git('/nakit-akis-icmali')}>📈 Nakit Akış (Vade)</button>}
        {kullanici?.urunModu === 2 && yetki('finans.alacak_yaslandirma')
          ? <button onClick={() => git('/alacak-yaslandirma')}>⏳ Alacak Yaşlandırma</button>
          : yetki('finans.cari_icmali') && <button onClick={() => git('/cari-icmali')}>⏳ Cari İcmali (yaşlandırma)</button>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="si-seg">
          {([['tahsilat', 'Tahsilat'], ['odeme', 'Ödeme'], ['ikisi', 'İkisi']] as const).map(([k, ad]) =>
            <button key={k} type="button" className={yon === k ? 'on' : ''} onClick={() => degistir({ yon: k === 'ikisi' ? '' : k })}>{ad}</button>)}
        </div>
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (e.target.value) { const [b, s] = hizliDonem(e.target.value); degistir({ bas: b, bit: s }) } }}>
            <option value="">{buAy ? 'Bu ay' : 'Hızlı…'}</option>
            <option value="ay">Bu ay</option><option value="gecen">Geçen ay</option><option value="30">Son 30 gün</option><option value="yil">Bu yıl</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">👤 Tahsil eden / Temsilci:
          <select value={kisi} onChange={e => degistir({ kisi: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.kisiler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">💱 Para birimi:
          <select value={para} onChange={e => degistir({ para: e.target.value })}>
            <option value="">TL karşılığı</option>
            {(veri?.secim.paralar ?? []).map(p => <option key={p} value={p}>{p} (kendi tutarı)</option>)}
          </select></div>
        <label className="fi-chk"><input type="checkbox" checked={virman} onChange={e => degistir({ virman: e.target.checked ? '1' : '' })} /> Virmanları göster</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.dagitilmamisAdet > 0 && <span className="bo-rz sari">Faturaya dağıtılmamış tahsilat: {o.dagitilmamisAdet}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Tahsilat" deg={f(o.tahsilat)} alt={`${o.tahsilatIslem} işlem · ${o.tahsilatCari} cari`} sinif="iyi" />
          <Kutu bas="Ödeme" deg={f(o.odeme)} alt={`${o.odemeIslem} işlem · ${o.odemeCari} cari`} sinif="teh" />
          <Kutu bas="Net Nakit Girişi" deg={isaretli(o.net)} alt="tahsilat − ödeme" sinif="mor" />
          <Kutu bas="Tahsilat / Satış" deg={o.tahsilatSatis != null ? `%${o.tahsilatSatis.toLocaleString('tr-TR')}` : '—'} alt={`dönem satışı ${kisa(o.satis)}`} />
          <Kutu bas="Ort. Tahsil Süresi" deg={o.ortTahsilGun != null ? `${o.ortTahsilGun} gün` : '—'}
            alt={`fatura → tahsilat${o.oncekiOrtTahsilGun != null ? ` · önceki dönem ${o.oncekiOrtTahsilGun}` : ''}`} />
          <Kutu bas="Ort. Ödeme Süresi" deg={o.ortOdemeGun != null ? `${o.ortOdemeGun} gün` : '—'} alt="fatura → ödeme" />
          <Kutu bas="Dağıtılmamış" deg={f(o.dagitilmamis)} alt={`${o.dagitilmamisAdet} tahsilat faturaya bağlanmadı`} sinif={o.dagitilmamisAdet ? 'uy' : ''} />
          <Kutu bas="Çek / Senet ile" deg={`%${o.cekSenetOran.toLocaleString('tr-TR')}`} alt={`tahsilatın · ${kisa(o.cekSenet)}`} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['tur', 'Ödeme Aracı', null], ['cari', 'Cari Bazında', cariler.length], ['gun', 'Gün / Hesap', null],
              ['kisi', 'Tahsil Eden', null], ['dik', 'Dikkat', dikkatSayi]]} />

            {sekme === 'tur' && <>
              <div className="si-iki">
                {tahGor && <AracTablosu baslik="Tahsilat — ödeme aracına göre" satirlar={veri.araclar.tahsilat} yon="tahsilat"
                  cariler={veri.cariler} acik={acik} cevir={cevir} f={f}
                  alt={veri.araclar.avansMahsup && veri.araclar.avansMahsup.islem > 0 ? (
                    <tr><td className="ki-soluk">↪ Avans mahsubu (bilgi)</td><td className="sag ki-soluk">{veri.araclar.avansMahsup.islem}</td>
                      <td className="sag ki-soluk">{tl(veri.araclar.avansMahsup.tutar)}</td><td colSpan={2} className="ki-soluk">toplama girmez</td></tr>) : null} />}
                {odeGor && <AracTablosu baslik="Ödeme — ödeme aracına göre" satirlar={veri.araclar.odeme} yon="odeme" renk={KIRMIZI}
                  cariler={veri.cariler} acik={acik} cevir={cevir} f={f} />}
              </div>
              {virman && veri.araclar.virmanlar && (
                <Kutucuk baslik="↔ Virmanlar (hesaplar arası aktarım · toplama girmez)">
                  <table className="hi-tablo"><thead><tr><th>Tür</th><th className="sag">İşlem</th><th className="sag">Tutar</th></tr></thead>
                    <tbody>
                      {veri.araclar.virmanlar.length === 0 && <tr><td colSpan={3} className="bos">Bu dönemde virman yok.</td></tr>}
                      {veri.araclar.virmanlar.map(v => <tr key={v.tur}><td>{v.ad}</td><td className="sag">{v.islem}</td><td className="sag">{f(v.tutar)}</td></tr>)}
                    </tbody></table>
                </Kutucuk>)}
              <div className="ki-soluk si-not">
                POS tahsilatı brüttür (cari brütle kapanır); banka komisyonu ve hesaba geçen tutar "Gün / Hesap" sekmesinde.
                Çekle / senetle tahsilat çekin alındığı gün sayılır; paraya dönüşmesi Nakit Akış ve Çek / Senet icmallerinde.
                İade eksi tutarla aracının içindedir; iptal edilen işlem toplama girmez.
                {o.aktarimTahsilat > 0 && <> Aktarımla gelen {o.aktarimTahsilat} tahsilatın fatura dağıtımı yok - ortalama gün FIFO'dan.</>}
              </div>
            </>}

            {sekme === 'cari' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Cari adı ya da kodu…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 260 }} />
                <span className="ki-soluk">satıra tıkla: işlemler ve dağıtıldığı faturalar · çift tık: cari ekstresi · ada tıkla: cari kartı</span>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Cari</th><th>Tür</th><th className="sag">Tahsilat</th><th className="sag">Ödeme</th><th className="sag">Dönem Faturası</th>
                    <th className="sag">Tahsil Oranı</th><th className="sag">Ort. Gün</th><th className="sag">Dağıtılmamış</th><th className="sag">Kalan Bakiye</th></tr></thead>
                  <tbody>
                    {cariler.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde tahsilat / ödeme yok.</td></tr>}
                    {cariler.slice(0, 1000).map(c => {
                      const k = 'c' + c.id;
                      const ac = acik.has(k);
                      return (
                        <Fragment key={k}>
                          <tr className={'ac' + (secili?.id === c.id ? ' fi-sec' : '')} onClick={() => { setSecili(c); cevir(k) }} onDoubleClick={() => ekstreAc(c.id)}>
                            <td><span className="ok">{ac ? '▾' : '▸'}</span>
                              {c.id ? <span className="lnk" onClick={e => { e.stopPropagation(); cariKarti(c.id, c.tur === 'tedarikci') }}>{c.ad}</span> : <span className="ki-soluk">{c.ad}</span>}</td>
                            <td>{TUR_AD[c.tur]}</td>
                            <td className={'sag' + (c.tahsilat ? ' si-yesil' : ' ki-soluk')}>{c.tahsilat ? kisa(c.tahsilat) : '—'}</td>
                            <td className={'sag' + (c.odeme ? ' kir' : ' ki-soluk')}>{c.odeme ? kisa(c.odeme) : '—'}</td>
                            <td className="sag">{c.donemFatura ? kisa(c.donemFatura) : '—'}</td>
                            <td className={'sag' + (c.tahsilOrani != null && c.tahsilOrani < 60 ? ' kir' : '')}>{c.tahsilOrani != null ? `%${c.tahsilOrani.toLocaleString('tr-TR')}` : '—'}</td>
                            <td className={'sag' + (c.ortGun != null && c.ortGun > 60 ? ' kir' : '')}>{c.ortGun ?? '—'}</td>
                            <td className={'sag' + (c.dagitilmamis ? ' kir' : ' ki-soluk')}>{kisa(c.dagitilmamis)}</td>
                            <td className={'sag' + (c.bakiye != null && c.bakiye < 0 ? ' kir' : '')}>{c.bakiye != null ? isaretli(c.bakiye) : '—'}</td>
                          </tr>
                          {ac && (
                            <tr className="si-det"><td colSpan={9}>
                              {c.islemler.map((x, i) => (
                                <span key={i}>{i > 0 && ' · '}{tarihT(x.tarih).slice(0, 5)} {x.yon === 'odeme' ? 'ödeme ' : ''}{x.arac}
                                  {x.cek && ` (${x.cek})`} {kisa(x.tutar)}{x.hesap && ` · ${x.hesap}`}
                                  {x.faturalar ? ` → ${x.faturalar}${x.dagitimli ? '' : ' (FIFO)'}` : x.yon === 'tahsilat' ? ' → dağıtılmamış' : ''}</span>
                              ))}
                              {c.islem > c.islemler.length && <span className="ki-soluk"> … {c.islem - c.islemler.length} işlem daha (ekstrede)</span>}
                            </td></tr>
                          )}
                        </Fragment>
                      );
                    })}
                    <tr className="top"><td colSpan={2}>Toplam ({cariler.length} cari)</td>
                      <td className="sag">{kisa(cariler.reduce((t, c) => t + c.tahsilat, 0))}</td>
                      <td className="sag">{kisa(cariler.reduce((t, c) => t + c.odeme, 0))}</td>
                      <td className="sag">{kisa(cariler.reduce((t, c) => t + c.donemFatura, 0))}</td><td /><td />
                      <td className="sag">{kisa(cariler.reduce((t, c) => t + c.dagitilmamis, 0))}</td><td /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Tahsil oranı = dönem tahsilatı / dönem faturası (tedarikçide ödeme / alış). Ortalama gün = tahsilatın dağıtıldığı faturaların tarihinden
                tahsilat tarihine, tutar ağırlıklı; dağıtılmamış tahsilatta Cari İcmali'nin FIFO kuralı (en eski vadeli kalem önce kapanır).
                Dağıtılmamış tahsilat cariyi düşürür ama faturayı açık gösterir. Kalan bakiye Cari İcmali ile aynı hesap (bitiş günü, + borçlu).
              </div>
            </>}

            {sekme === 'gun' && <GunHesap v={veri} f={f} virman={virman} git={git} />}

            {sekme === 'kisi' && <>
              <table className="hi-tablo">
                <thead><tr><th>Kişi</th><th className="sag">İşlem</th><th className="sag">Tahsilat</th><th className="sag">Nakit</th><th className="sag">POS</th>
                  <th className="sag">Havale / EFT</th><th className="sag">Çek / Senet</th><th className="sag">Gün sonu farkı</th></tr></thead>
                <tbody>
                  {veri.kisiler.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde tahsilat yok.</td></tr>}
                  {veri.kisiler.map(k => (
                    <tr key={k.id} className="ac" onClick={() => k.id && degistir({ kisi: String(k.id) })}>
                      <td>{k.ad}</td><td className="sag">{k.islem}</td><td className="sag"><b>{kisa(k.tahsilat)}</b></td>
                      <td className="sag">{kisa(k.nakit)}</td><td className="sag">{kisa(k.pos)}</td><td className="sag">{kisa(k.havale)}</td>
                      <td className="sag">{k.cekSenet ? kisa(k.cekSenet) : '—'}</td>
                      <td className={'sag' + (k.gunSonuFarki ? ' kir' : ' ki-soluk')}>{k.gunSonuFarki != null ? isaretli(k.gunSonuFarki) : '—'}</td></tr>
                  ))}
                </tbody>
              </table>
              <div className="ki-soluk si-not">Kasa ve POS tahsilatı işlemi alan kullanıcıya (banko oturumu varsa oturumun kasiyerine), banka tahsilatı carinin
                temsilcisine yazılır. Gün sonu farkı Kasa / Gün Sonu Mutabakatı'ndaki banko oturum kapanış farklarından. Satıra tıkla: yalnız o kişinin işlemleri.</div>
            </>}

            {sekme === 'dik' && <DikkatSekmesi v={veri} f={f} cariKarti={cariKarti} git={git} />}
          </div>
        </div>

        <div className="ki-soluk si-not">{o.islem} işlem · {o.cari} cari · Dönem: {o.gun} gün · Hesap sunucuda, ekran toplamaz.</div>
      </>)}
    </div>
  );
}

function AracTablosu({ baslik, satirlar, yon, renk, cariler, acik, cevir, f, alt }: {
  baslik: string; satirlar: TahsilatAraci[]; yon: 'tahsilat' | 'odeme'; renk?: string; cariler: TahsilatCari[];
  acik: Set<string>; cevir(k: string): void; f(n: number): string; alt?: ReactNode;
}) {
  const toplam = satirlar.reduce((t, s) => t + s.tutar, 0);
  const islem = satirlar.reduce((t, s) => t + s.islem, 0);
  return (
    <Kutucuk baslik={baslik} not="satıra tıkla: işlemler">
      <table className="hi-tablo">
        <thead><tr><th>Araç</th><th className="sag">İşlem</th><th className="sag">Tutar</th><th className="sag">Pay</th><th style={{ width: 130 }} /></tr></thead>
        <tbody>
          {satirlar.length === 0 && <tr><td colSpan={5} className="bos">Bu dönemde {yon === 'tahsilat' ? 'tahsilat' : 'ödeme'} yok.</td></tr>}
          {satirlar.map(s => {
            const k = yon + s.anahtar;
            const ac = acik.has(k);
            const islemler = ac ? cariler.flatMap(c => c.islemler.filter(x => x.yon === yon && x.aracAnahtar === s.anahtar).map(x => ({ ...x, cari: c.ad }))).slice(0, 40) : [];
            return (
              <Fragment key={k}>
                <tr className="ac" onClick={() => cevir(k)}>
                  <td><span className="ok">{ac ? '▾' : '▸'}</span>{ARAC_IKON[s.anahtar] ?? ''} {s.ad}</td><td className="sag">{s.islem}</td>
                  <td className="sag">{f(s.tutar)}{s.iade < 0 && <span className="ki-soluk" title="iade dahil"> (iade {f(s.iade)})</span>}</td>
                  <td className="sag">%{s.pay.toLocaleString('tr-TR')}</td><td><Cubuk yuzde={s.pay} renk={renk} /></td></tr>
                {ac && (
                  <tr className="si-det"><td colSpan={5}>
                    {islemler.length === 0 ? 'İşlem ayrıntısı Cari Bazında sekmesinde.' : islemler.map((x, i) => (
                      <span key={i}>{i > 0 && ' · '}{tarihT(x.tarih).slice(0, 5)} {x.cari} {f(x.tutar)}{x.cek && ` (${x.cek})`}</span>))}
                  </td></tr>
                )}
              </Fragment>
            );
          })}
          {alt}
          <tr className="top"><td>Toplam</td><td className="sag">{islem}</td><td className="sag">{f(toplam)}</td><td className="sag">%100</td><td /></tr>
        </tbody>
      </table>
    </Kutucuk>
  );
}

function GunHesap({ v, f, virman, git }: { v: Veri; f(n: number): string; virman: boolean; git(y: string): void }) {
  const { donemler, hesaplar } = v.gunHesap;
  const mx = Math.max(1, ...hesaplar.flatMap(h => h.hucreler.map(Math.abs)));
  const kolon = donemler.length + 4;
  const hucreAc = (id: number, i: number) => git(`/ekstre?tur=hesap&id=${id}&bas=${donemler[i].bas.slice(0, 10)}&bit=${donemler[i].bit.slice(0, 10)}`);
  return (<>
    <Kutucuk baslik="Kasa / banka hesabı × dönem" not="giriş − çıkış · hücreye tıkla: o dönemin hesap ekstresi">
      <div style={{ overflowX: 'auto' }}>
        <table className="hi-tablo">
          <thead><tr><th>Hesap</th>{donemler.map(d => <th key={d.bas} className="sag" title={`${tarihT(d.bas)} – ${tarihT(d.bit)}`}>{d.ad}</th>)}
            <th className="sag">Giriş</th><th className="sag">Çıkış</th><th className="sag">Net</th></tr></thead>
          <tbody>
            {hesaplar.length === 0 && <tr><td colSpan={kolon} className="bos">Bu dönemde kasa / banka / POS hareketi yok.</td></tr>}
            {hesaplar.map(h => (
              <Fragment key={h.id}>
                {h.normalVar && (
                  <tr>
                    <td>{HESAP_IKON[h.tur] ?? ''} {h.ad}{h.doviz !== 'TL' && ` (${h.doviz})`}{h.pos && h.pos.oran > 0 && <span className="ki-soluk"> — komisyon %{h.pos.oran.toLocaleString('tr-TR')}</span>}</td>
                    {h.hucreler.map((x, i) => <td key={i} className="si-isi ac" style={{ background: isiRengi(Math.abs(x), mx) }} onClick={() => hucreAc(h.id, i)}>
                      {x ? isaretli(x) : '—'}</td>)}
                    <td className="sag">{f(h.giris)}</td><td className="sag">{f(h.cikis)}</td>
                    <td className={'sag' + (h.net < 0 ? ' kir' : '')}><b>{isaretli(h.net)}</b></td>
                  </tr>)}
                {h.pos && (
                  <tr className="fi-alt"><td colSpan={kolon}>
                    ↳ brüt {f(h.pos.brut)} · hesaba geçen {f(h.pos.hesabaGecen)}
                    · komisyon {h.pos.komisyon ? f(h.pos.komisyon) : h.pos.tahminiKomisyon ? `${f(h.pos.tahminiKomisyon)} (tahmini, kart oranıyla)` : '—'}
                    {h.pos.bekleyen > 0 && ` · bankaya aktarılmamış ${f(h.pos.bekleyen)}`}{h.pos.valor > 0 && ` · valör ${h.pos.valor} gün`}
                  </td></tr>)}
                {virman && (h.transferGiris > 0 || h.transferCikis > 0) && (
                  <tr className="fi-alt">
                    <td>↔ virman</td>{h.transferHucreler.map((x, i) => <td key={i} className="sag ki-soluk">{x ? isaretli(x) : '—'}</td>)}
                    <td className="sag ki-soluk">{f(h.transferGiris)}</td><td className="sag ki-soluk">{f(h.transferCikis)}</td>
                    <td className="sag ki-soluk">{isaretli(h.transferGiris - h.transferCikis)}</td>
                  </tr>)}
              </Fragment>
            ))}
            <tr className="top"><td>Toplam</td>
              {donemler.map((_, i) => <td key={i} className="sag">{isaretli(hesaplar.reduce((t, h) => t + (h.hucreler[i] ?? 0), 0))}</td>)}
              <td className="sag">{f(hesaplar.reduce((t, h) => t + h.giris, 0))}</td><td className="sag">{f(hesaplar.reduce((t, h) => t + h.cikis, 0))}</td>
              <td className="sag">{isaretli(hesaplar.reduce((t, h) => t + h.net, 0))}</td></tr>
          </tbody>
        </table>
      </div>
      <div className="fi-ipucu">Çek / senet tahsilatı hesaba portföyden tahsil edildiği gün girer (Çek / Senet İcmali); burada yalnız nakit, banka ve POS
        hareketi var. Hesaplar arası aktarım (virman) toplama girmez; "Virmanları göster" işaretliyse hesabın altında ayrı satır.
        POS satırında çıkış = çekimde kesilen komisyon; hesaba geçen = POS'tan bankaya aktarılan net tutar.</div>
    </Kutucuk>
  </>);
}

function DikkatSekmesi({ v, f, cariKarti, git }: {
  v: Veri; f(n: number): string; cariKarti(id: number, tedarikci?: boolean): void; git(y: string): void;
}) {
  const d = v.dikkat;
  return (
    <div className="si-iki">
      <Kutucuk baslik="⚠ Faturaya dağıtılmamış tahsilatlar" not={`${d.dagitilmamisAdet} · ${f(d.dagitilmamisTutar)}`}>
        <table className="hi-tablo"><thead><tr><th>Tarih</th><th>Cari</th><th>Araç</th><th className="sag">Tutar</th><th>Açık faturası</th></tr></thead>
          <tbody>
            {d.dagitilmamis.length === 0 && <tr><td colSpan={5} className="bos">Dağıtılmamış tahsilat yok.</td></tr>}
            {d.dagitilmamis.map((x, i) => (
              <tr key={i} className="ac" onDoubleClick={() => git(`/ekstre?tur=cari&id=${x.id}`)}>
                <td>{tarihT(x.tarih)}</td><td><span className="lnk" onClick={() => cariKarti(x.id)}>{x.cari}</span>{x.avans && <span className="bo-rz mavi" style={{ marginLeft: 4 }}>avans</span>}</td>
                <td>{x.arac}</td><td className="sag">{f(x.tutar)}</td>
                <td>{x.acikFatura ? `${x.acikFatura} fatura · ${tl(x.acikTutar)}` : <span className="ki-soluk">açık fatura yok</span>}</td></tr>))}
            {d.dagitilmamisAdet > d.dagitilmamis.length && <tr><td colSpan={5} className="ki-soluk">… {d.dagitilmamisAdet - d.dagitilmamis.length} tahsilat daha</td></tr>}
          </tbody></table>
      </Kutucuk>
      <Kutucuk baslik="↩ İade edilen / iptal tahsilat ve ödeme">
        <table className="hi-tablo"><thead><tr><th>Tarih</th><th>Cari</th><th>Araç</th><th className="sag">Tutar</th><th>Neden</th></tr></thead>
          <tbody>
            {d.iadeIptal.length === 0 && <tr><td colSpan={5} className="bos">İade / iptal yok.</td></tr>}
            {d.iadeIptal.map((x, i) => <tr key={i}><td>{tarihT(x.tarih)}</td><td>{x.cari}</td><td>{x.yon === 'odeme' ? 'Ödeme · ' : ''}{x.arac}</td>
              <td className="sag kir">{f(x.tutar)}</td><td style={{ whiteSpace: 'normal' }}>{x.neden}</td></tr>)}
          </tbody></table>
      </Kutucuk>
      <Kutucuk baslik="💤 Bu dönem hiç ödeme yapmayan, bakiyesi olan müşteri">
        <table className="hi-tablo"><thead><tr><th>Cari</th><th className="sag">Bakiye</th><th>Son tahsilat</th></tr></thead>
          <tbody>
            {d.odemesiz.length === 0 && <tr><td colSpan={3} className="bos">Yok.</td></tr>}
            {d.odemesiz.map(x => <tr key={x.id} className="ac" onDoubleClick={() => git(`/ekstre?tur=cari&id=${x.id}`)}>
              <td><span className="lnk" onClick={() => cariKarti(x.id)}>{x.ad}</span></td><td className="sag">{tl(x.bakiye)}</td>
              <td className={x.gun == null || x.gun > 90 ? 'kir' : ''}>{x.sonTahsilat ? `${tarihT(x.sonTahsilat)} · ${x.gun} gün` : 'hiç tahsilat yok'}</td></tr>)}
          </tbody></table>
      </Kutucuk>
      <Kutucuk baslik="⏰ Vadesi geçmiş ödememiz">
        <table className="hi-tablo"><thead><tr><th>Tedarikçi</th><th>Fatura</th><th>Vade</th><th className="sag">Tutar</th></tr></thead>
          <tbody>
            {d.gecmisOdeme.length === 0 && <tr><td colSpan={4} className="bos">Vadesi geçmiş ödeme yok.</td></tr>}
            {d.gecmisOdeme.map((x, i) => <tr key={i} className="ac" onDoubleClick={() => x.belgeId && git(`/belge/${x.belgeId}`)}>
              <td><span className="lnk" onClick={() => cariKarti(x.id, true)}>{x.ad}</span></td><td>{x.belgeNo || '—'}</td>
              <td className="kir">{tarihT(x.vade)} · {x.gun} gün</td>
              <td className="sag">{tl(x.tutar)}{x.doviz !== 'TL' && <span className="ki-soluk"> ({tl(x.dovizTutar)} {x.doviz})</span>}</td></tr>)}
          </tbody></table>
      </Kutucuk>
    </div>
  );
}

function TahsilatA4({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const o = v.ozet;
  const sube = v.sube ? v.secim.subeler.find(s => s.id === v.sube)?.ad : 'Tümü';
  const birim = v.para ? ` ${v.para}` : '';
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>TAHSİLAT / ÖDEME İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span>
        <span>Kapsam: {v.yon === 'tahsilat' ? 'tahsilat' : v.yon === 'odeme' ? 'ödeme' : 'tahsilat ve ödeme'}</span>
        <span>Şube: {sube}</span><span>{o.islem} işlem · {o.cari} cari</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Araç</th><th>Tahsilat</th><th>Ödeme</th><th>Net</th></tr></thead>
        <tbody>{v.a4.map(x => <tr key={x.arac}><td>{x.arac}</td><td>{tl(x.tahsilat)}</td><td>{tl(x.odeme)}</td><td>{isaretli(x.net)}</td></tr>)}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Tahsilat</td><td>{tl(o.tahsilat)}{birim}</td></tr>
        <tr><td>Ödeme</td><td>{tl(o.odeme)}{birim}</td></tr>
        <tr className="kalan ki-kalan"><td>NET NAKİT GİRİŞİ</td><td>{isaretli(o.net)}{birim || ' ₺'}</td></tr>
      </tbody></table>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Tahsilat / Ödeme İcmali · tutarlar kasa işlemlerinden · {v.para ? `yalnız ${v.para} işlemler, kendi tutarıyla` : 'dövizli işlem işlem kuruyla TL'}</p>
    </div>
  );
}

export default TahsilatOdemeIcmali;
