import { Fragment, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { HareketStokSatiri, StokHareketIcmali as Veri } from '../../api/uclar/stokIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { isiRengi, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useStokKarti, useSuzgec } from './stokIcmalOrtak';

/**
 * STOK HAREKET İCMALİ `/stok-hareket-icmali` (1174) - mockup Ekranlar/Stok/stok_hareket_icmali.html.
 * "Dönemde hangi stoktan ne girdi, ne çıktı, nereye gitti?" Devir / kalan Stok Değer İcmali'nin
 * tarih itibarıyla bakiyesiyle aynı hesaptan; hareketler türüne göre (iade, sayım fişi ayrı).
 */
type Sekme = 'stok' | 'tur' | 'depo' | 'eks';
const ayBasi = () => bugunYerel().slice(0, 8) + '01';

export function StokHareketIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const kartAc = useStokKarti();
  const bas = arama.get('bas') ?? ayBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const depo = Number(arama.get('depo') ?? 0);
  const kategori = Number(arama.get('kategori') ?? 0);
  const stokId = Number(arama.get('stok') ?? 0);
  const tutarMi = arama.get('birim') === 'tutar';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [sekme, setSekme] = useState<Sekme>(stokId ? 'eks' : 'stok');
  const [ara, setAra] = useState('');
  const [acik, setAcik] = useState<Set<number>>(new Set());

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit });
    if (depo) q.set('depo', String(depo));
    if (kategori) q.set('kategori', String(kategori));
    if (stokId) q.set('stokId', String(stokId));
    if (tutarMi) q.set('tutar', '1');
    api.stokHareketIcmali(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, depo, kategori, stokId, tutarMi]);

  const satirlar = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return (veri?.stoklar ?? []).filter(s => !q || s.kod.toLocaleLowerCase('tr').includes(q) || s.ad.toLocaleLowerCase('tr').includes(q)
      || s.kategori.toLocaleLowerCase('tr').includes(q));
  }, [veri, ara]);
  const o = veri?.ozet;
  const giris = veri?.kolonlar.filter(k => k.yon === 'giris') ?? [];
  const cikis = veri?.kolonlar.filter(k => k.yon === 'cikis') ?? [];
  // TRANSFER SÜTUNU yalnız tek depoda: tüm depolarda toplamı sıfırdır.
  const transferVar = depo > 0 && (veri?.stoklar.some(s => s.transferGiren || s.transferCikan) ?? false);
  const f = (n: number) => (tutarMi ? tl(n) : sayi(n));
  const cevir = (id: number) => setAcik(a => { const n = new Set(a); n.has(id) ? n.delete(id) : n.add(id); return n });
  const ekstreAc = (id: number) => { degistir({ stok: String(id) }); setSekme('eks') };
  const kolonSayisi = 4 + giris.length + cikis.length + (transferVar ? 2 : 0) + 2;
  const donemAdi = (t: string) => veri?.donemTuru === 'ay'
    ? new Date(t).toLocaleDateString('tr-TR', { month: 'short', year: 'numeric' })
    : `${new Date(t).toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' })} haftası`;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Stok Hareket İcmali</h1><span className="yol">Stok &amp; Hizmet › İcmaller › Stok Hareket İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Stok Hareket İcmali" dosyaAdi={`Stok Hareket İcmali ${bas} ${bit}`} devre={!veri}>
          {veri && <HareketA4 v={veri} satirlar={satirlar} antet={antet} duzenleyen={kullanici?.ad ?? ''} f={f} />}
        </CiktiMenusu>
        <span className="sp" />
        <button onClick={() => git('/stok-deger-icmali')}>📦 Stok Değer İcmali</button>
        <button onClick={() => git('/stok-olu-stok-icmali')}>💤 Ölü Stok / Devir Hızı</button>
        <button onClick={() => git('/stok-kritik-stok-icmali')}>🚨 Kritik Stok</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} max={bugunYerel()} onChange={e => e.target.value && degistir({ bit: e.target.value })} /></div>
        <div className="sel">🏬 Depo:
          <select value={depo} onChange={e => degistir({ depo: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.depoListesi ?? []).map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kategori:
          <select value={kategori} onChange={e => degistir({ kategori: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.kategoriler ?? []).map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select></div>
        <div className="si-seg">
          <button type="button" className={!tutarMi ? 'on' : ''} onClick={() => degistir({ birim: '' })}>Miktar</button>
          <button type="button" className={tutarMi ? 'on' : ''} onClick={() => degistir({ birim: 'tutar' })}>Tutar (ort. maliyet)</button>
        </div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.eksiyeDusen > 0 && <span className="bo-rz sari">Dönemde eksiye düşen: {o.eksiyeDusen} kalem</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas={`Devir (${tarihT(veri.bas)})`} deg={f(o.devir)} alt={`${sayi(o.bakiyeliKalem)} bakiyeli kalem (dönem sonu)`} />
          <Kutu bas="Giriş" deg={'+' + f(o.giris)} alt={giris.slice(0, 3).map(k => k.ad).join(' · ') || '—'} sinif="iyi" />
          <Kutu bas="Çıkış" deg={'−' + f(o.cikis)} alt={cikis.slice(0, 3).map(k => k.ad).join(' · ') || '—'} sinif="teh" />
          <Kutu bas={`Kalan (${tarihT(veri.bit)})`} deg={f(o.kalan)}
            alt={tutarMi ? `değerleme farkı ${tl(o.degerlemeFarki ?? 0)}` : 'Stok Değer İcmali ile aynı hesap'} sinif="mor" />
          <Kutu bas="Hareket Gören" deg={sayi(o.kalem)} alt={`kalem · ${o.gun} gün`} />
          <Kutu bas="Belge" deg={sayi(o.belge)} alt="fatura · irsaliye · fiş" />
          <Kutu bas="Transfer" deg={f(o.transfer)} alt="depolar arası · toplama girmez" />
          <Kutu bas="Sayım Farkı" deg={(o.sayimNet >= 0 ? '+' : '') + f(o.sayimNet)} alt={`fazla ${f(o.sayimFazla)} · eksik ${f(o.sayimEksik)}`} sinif={o.sayimNet ? 'uy' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['stok', 'Stok Bazında', satirlar.length], ['tur', `Hareket Türü × ${veri.donemTuru === 'ay' ? 'Ay' : 'Hafta'}`, null],
              ['depo', 'Depo Akışı', null], ['eks', 'Stok Ekstresi', null]]} />

            {sekme === 'stok' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Stok kodu, adı ya da kategori…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">satıra tıkla: depo kırılımı · çift tık: stok ekstresi · ada tıkla: stok kartı · çıkışa göre sıralı</span>
              </div>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead>
                    <tr><th rowSpan={2}>Kod</th><th rowSpan={2}>Stok Adı</th><th rowSpan={2}>Birim</th><th rowSpan={2} className="sag">Devir</th>
                      {giris.length > 0 && <th colSpan={giris.length} className="orta" style={{ background: '#e9f5ec' }}>Giriş</th>}
                      {cikis.length > 0 && <th colSpan={cikis.length} className="orta" style={{ background: '#fbecea' }}>Çıkış</th>}
                      {transferVar && <th colSpan={2} className="orta">Transfer</th>}
                      <th rowSpan={2} className="sag">Kalan</th><th rowSpan={2} className="sag">Hareket</th></tr>
                    <tr>{giris.map(k => <th key={'g' + k.anahtar} className="sag">{k.ad}</th>)}
                      {cikis.map(k => <th key={'c' + k.anahtar} className="sag">{k.ad}</th>)}
                      {transferVar && <><th className="sag">Giren</th><th className="sag">Çıkan</th></>}</tr>
                  </thead>
                  <tbody>
                    {satirlar.length === 0 && <tr><td colSpan={kolonSayisi} className="bos">Bu dönemde hareket gören stok yok.</td></tr>}
                    {satirlar.slice(0, 1000).map(s => (
                      <HareketSatiri key={s.id} s={s} giris={giris.map(k => k.anahtar)} cikis={cikis.map(k => k.anahtar)} transferVar={transferVar}
                        acik={acik.has(s.id)} cevir={cevir} kartAc={kartAc} ekstreAc={ekstreAc} f={f} kolonSayisi={kolonSayisi} />
                    ))}
                    <tr className="top"><td colSpan={3}>Toplam ({sayi(satirlar.length)} kalem{tutarMi ? '' : ' · karışık birim'})</td>
                      <td className="sag">{f(satirlar.reduce((t, s) => t + s.devir, 0))}</td>
                      {giris.map(k => <td key={k.anahtar} className="sag">{f(satirlar.reduce((t, s) => t + (s.giris[k.anahtar] ?? 0), 0))}</td>)}
                      {cikis.map(k => <td key={k.anahtar} className="sag">{f(satirlar.reduce((t, s) => t + (s.cikis[k.anahtar] ?? 0), 0))}</td>)}
                      {transferVar && <><td className="sag">{f(satirlar.reduce((t, s) => t + s.transferGiren, 0))}</td>
                        <td className="sag">{f(satirlar.reduce((t, s) => t + s.transferCikan, 0))}</td></>}
                      <td className="sag">{f(satirlar.reduce((t, s) => t + s.kalan, 0))}</td>
                      <td className="sag">{sayi(satirlar.reduce((t, s) => t + s.hareket, 0))}</td></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Kalan = devir + giriş − çıkış (± transfer). Depolar arası transfer tüm depolarda sıfır toplamlıdır; tek depo seçilince ayrı sütun olur.
                {tutarMi && <> Tutarda girişler belgenin kendi fiyatıyla (alış, giriş fişi, sayım fazlası), çıkış / iade / transfer ve devir / kalan
                  ortalama maliyetle; aradaki değerleme farkı <b>{tl(o.degerlemeFarki ?? 0)}</b> (maliyet ortalamasının girişlerden sapması).</>}
                Sayım fişleri "Sayım fazlası / eksiği" sütunundadır. Üstteki Devir / Kalan kutuları bakiyesi olan bütün stokları kapsar.
              </div>
            </>}

            {sekme === 'tur' && (
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Hareket türü</th>{veri.donemler.map(d => <th key={d} className="sag">{donemAdi(d)}</th>)}
                    <th className="sag">Toplam</th><th className="sag">Belge</th></tr></thead>
                  <tbody>
                    {(['giris', 'cikis'] as const).map(yon => {
                      const l = veri.turDonem.filter(t => t.yon === yon);
                      const mx = Math.max(1, ...veri.turDonem.flatMap(t => t.hucreler));
                      return (
                        <Fragment key={yon}>
                          <tr className="si-grup"><td colSpan={veri.donemler.length + 3}>{yon === 'giris' ? 'Giriş' : 'Çıkış'}</td></tr>
                          {l.length === 0 && <tr><td colSpan={veri.donemler.length + 3} className="bos">Yok.</td></tr>}
                          {l.map(t => (
                            <tr key={t.anahtar}><td>&nbsp;&nbsp;{t.ad}</td>
                              {t.hucreler.map((h, i) => <td key={i} className="si-isi" style={{ background: isiRengi(h, mx) }}>{h ? f(h) : '—'}</td>)}
                              <td className="sag"><b>{f(t.toplam)}</b></td><td className="sag">{t.belge}</td></tr>
                          ))}
                        </Fragment>
                      );
                    })}
                    <tr className="si-grup"><td colSpan={veri.donemler.length + 3}>Depolar arası (toplama girmez)</td></tr>
                    <tr><td>&nbsp;&nbsp;Transfer</td>{veri.transferDonem.map((h, i) => <td key={i} className="sag ki-soluk">{h ? f(h) : '—'}</td>)}
                      <td className="sag ki-soluk">{f(o.transfer)}</td><td /></tr>
                    <tr className="top"><td>Net (giriş − çıkış)</td>
                      {veri.donemler.map((_, i) => {
                        const n = veri.turDonem.reduce((t, x) => t + (x.yon === 'giris' ? 1 : -1) * (x.hucreler[i] ?? 0), 0);
                        return <td key={i} className="sag">{(n >= 0 ? '+' : '') + f(n)}</td>;
                      })}
                      <td className="sag">{(o.giris - o.cikis >= 0 ? '+' : '') + f(o.giris - o.cikis)}</td><td className="sag">{o.belge}</td></tr>
                  </tbody>
                </table>
                <div className="ki-soluk si-not">Satırlar stoku etkileyen belge türlerinden gelir (iade ve sayım fişi ayrı satır). Dönem 62 günü aşarsa sütunlar ay olur.</div>
              </div>
            )}

            {sekme === 'depo' && (
              <div className="si-iki">
                <Kutucuk baslik="Depo bazında" not={tutarMi ? 'tutar' : 'miktar'}>
                  <table className="hi-tablo"><thead><tr><th>Depo</th><th className="sag">Devir</th><th className="sag">Giriş</th><th className="sag">Çıkış</th>
                    <th className="sag">Transfer +/−</th><th className="sag">Kalan</th></tr></thead>
                    <tbody>
                      {veri.depoAkis.map(d => (
                        <tr key={d.depoId}><td>{d.depo}</td><td className="sag">{f(d.devir)}</td><td className="sag si-yesil">{f(d.giris)}</td>
                          <td className="sag kir">{f(d.cikis)}</td><td className={'sag' + (d.transfer < 0 ? ' kir' : d.transfer > 0 ? ' si-yesil' : '')}>{(d.transfer > 0 ? '+' : '') + f(d.transfer)}</td>
                          <td className="sag"><b>{f(d.kalan)}</b></td></tr>))}
                      <tr className="top"><td>Toplam</td><td className="sag">{f(veri.depoAkis.reduce((t, d) => t + d.devir, 0))}</td>
                        <td className="sag">{f(veri.depoAkis.reduce((t, d) => t + d.giris, 0))}</td><td className="sag">{f(veri.depoAkis.reduce((t, d) => t + d.cikis, 0))}</td>
                        <td className="sag">{f(veri.depoAkis.reduce((t, d) => t + d.transfer, 0))}</td><td className="sag">{f(veri.depoAkis.reduce((t, d) => t + d.kalan, 0))}</td></tr>
                    </tbody></table>
                </Kutucuk>
                <Kutucuk baslik="Transferler" not="çıkış deposu → giriş deposu">
                  <table className="hi-tablo"><thead><tr><th>Çıkış</th><th>Giriş</th><th className="sag">{tutarMi ? 'Tutar' : 'Miktar'}</th><th className="sag">Fiş</th></tr></thead>
                    <tbody>
                      {veri.transferMatrisi.length === 0 && <tr><td colSpan={4} className="bos">Bu dönemde transfer yok.</td></tr>}
                      {veri.transferMatrisi.map((t, i) => <tr key={i}><td>{t.cikis || '—'}</td><td>{t.giris || '—'}</td><td className="sag">{f(t.miktar)}</td><td className="sag">{t.fis}</td></tr>)}
                    </tbody></table>
                  <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>
                    <span className="lnk" onClick={() => git('/stok-transfer')}>Stok Transfer listesi</span> · fişte teslim eden / teslim alan zorunlu.</div>
                </Kutucuk>
              </div>
            )}

            {sekme === 'eks' && (!veri.ekstre ? (
              <div className="bos" style={{ padding: 20 }}>Stok Bazında sekmesinde bir satıra çift tıklayın; o stokun dönem ekstresi burada açılır.</div>
            ) : (<>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <b>{veri.ekstre.stok?.kod} · {veri.ekstre.stok?.ad}</b>
                <span className="ki-soluk">{depo ? veri.secim.depoListesi.find(d => d.id === depo)?.ad : 'tüm depolar'} · yürüyen bakiye · satıra çift tık: belge kartı</span>
                <span className="sp" />
                <button onClick={() => veri.ekstre?.stok && kartAc(veri.ekstre.stok.id)}>📦 Stok kartı</button>
                <button onClick={() => { degistir({ stok: '' }); setSekme('stok') }}>✖ Ekstreyi kapat</button>
              </div>
              <table className="hi-tablo">
                <thead><tr><th>Tarih</th><th>Belge</th><th>No</th><th>Cari / Açıklama</th><th>Depo</th><th>Lot · SKT</th>
                  <th className="sag">Giriş</th><th className="sag">Çıkış</th><th className="sag">Bakiye</th></tr></thead>
                <tbody>
                  <tr className="si-grup"><td colSpan={8}>Devir {tarihT(veri.bas)}</td><td className="sag">{sayi(veri.ekstre.devir)}</td></tr>
                  {veri.ekstre.hareketler.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde hareket yok.</td></tr>}
                  {veri.ekstre.hareketler.map((h, i) => (
                    <tr key={i} className="ac" onDoubleClick={() => git(`/belge/${h.belgeId}`)}>
                      <td>{tarihT(h.tarih)}</td><td>{h.belge}</td><td>{h.belgeNo}</td><td>{h.cari || h.aciklama}</td><td>{h.depo}</td><td>{h.lot}</td>
                      <td className="sag si-yesil">{h.giren ? sayi(h.giren) : ''}</td><td className="sag kir">{h.cikan ? sayi(h.cikan) : ''}</td>
                      <td className={'sag' + (h.bakiye < 0 ? ' kir' : '')}>{sayi(h.bakiye)}</td></tr>
                  ))}
                  <tr className="top"><td colSpan={6}>Dönem toplamı</td><td className="sag">{sayi(veri.ekstre.giren)}</td><td className="sag">{sayi(veri.ekstre.cikan)}</td>
                    <td className="sag">{sayi(veri.ekstre.kalan)}</td></tr>
                </tbody>
              </table>
              <div className="ki-soluk si-not">Ekstre her zaman miktardır. Son satırın bakiyesi stok kartındaki {depo ? 'depo ' : ''}bakiyeye eşit olmalı.
                {!depo && ' Tüm depolarda transfer iki satırdır (çıkan depo eksi, giren depo artı).'}{veri.ekstre.sinirli && ' İlk 3000 hareket gösteriliyor.'}</div>
            </>))}
          </div>
        </div>
      </>)}
    </div>
  );
}

function HareketSatiri({ s, giris, cikis, transferVar, acik, cevir, kartAc, ekstreAc, f, kolonSayisi }: {
  s: HareketStokSatiri; giris: string[]; cikis: string[]; transferVar: boolean; acik: boolean;
  cevir(id: number): void; kartAc(id: number): void; ekstreAc(id: number): void; f(n: number): string; kolonSayisi: number;
}) {
  const kirilim = s.depolar.length > 1;
  const h = (n: number | undefined, sinif: string) => <td className={'sag ' + (n ? sinif : 'ki-soluk')}>{n ? f(n) : '—'}</td>;
  return (
    <Fragment>
      <tr className="ac" onClick={() => kirilim && cevir(s.id)} onDoubleClick={() => ekstreAc(s.id)}>
        <td>{kirilim && <span className="ok">{acik ? '▾' : '▸'}</span>}{s.kod}</td>
        <td><span className="lnk" onClick={e => { e.stopPropagation(); kartAc(s.id) }}>{s.ad}</span></td>
        <td>{s.birim}</td><td className="sag">{f(s.devir)}</td>
        {giris.map(k => <Fragment key={'g' + k}>{h(s.giris[k], 'si-yesil')}</Fragment>)}
        {cikis.map(k => <Fragment key={'c' + k}>{h(s.cikis[k], 'kir')}</Fragment>)}
        {transferVar && <>{h(s.transferGiren, 'si-yesil')}{h(s.transferCikan, 'kir')}</>}
        <td className={'sag' + (s.kalan < 0 ? ' kir' : '')}><b>{f(s.kalan)}</b>{s.eksiyeDustu && <span className="bo-rz kir" style={{ marginLeft: 4 }}>eksiye düştü</span>}</td>
        <td className="sag">{s.hareket}</td>
      </tr>
      {acik && kirilim && (
        <tr className="si-det"><td colSpan={kolonSayisi}>
          {s.depolar.map(d => `${d.depo}: devir ${f(d.devir)} · +${f(d.giris)} · −${f(d.cikis)}${d.transfer ? ` · transfer ${d.transfer > 0 ? '+' : ''}${f(d.transfer)}` : ''} → ${f(d.kalan)}`).join('   ·   ')}
        </td></tr>
      )}
    </Fragment>
  );
}

function HareketA4({ v, satirlar, antet, duzenleyen, f }: {
  v: Veri; satirlar: HareketStokSatiri[]; antet: Record<string, unknown> | null; duzenleyen: string; f(n: number): string;
}) {
  const o = v.ozet;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>STOK HAREKET İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Birim: {v.birim === 'tutar' ? 'Tutar (ortalama maliyet)' : 'Miktar'}</span>
        <span>Depo: {v.depo ? v.secim.depoListesi.find(d => d.id === v.depo)?.ad : 'Tümü'}</span><span>Hareket gören: {sayi(o.kalem)} kalem · {sayi(o.belge)} belge</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Stok</th><th>Devir</th><th>Giriş</th><th>Çıkış</th><th>Kalan</th></tr></thead>
        <tbody>{satirlar.map(s => <tr key={s.id}><td>{s.kod} · {s.ad}</td><td>{f(s.devir)}</td><td>{f(s.girisToplam)}</td>
          <td>{f(s.cikisToplam)}</td><td>{f(s.kalan)}</td></tr>)}</tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Devir</td><td>{f(o.devir)}</td></tr>
        <tr><td>Giriş</td><td>{f(o.giris)}</td></tr>
        <tr><td>Çıkış</td><td>{f(o.cikis)}</td></tr>
        <tr className="kalan ki-kalan"><td>KALAN</td><td>{f(o.kalan)}</td></tr>
      </tbody></table>
      <p className="a4-not">Devir ve kalan bakiyesi olan bütün stokları kapsar; depolar arası transfer toplamda sıfırdır, tabloya girmez.</p>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Depo Sorumlusu<br />Kaşe · İmza</div></div>
    </div>
  );
}

export default StokHareketIcmali;
