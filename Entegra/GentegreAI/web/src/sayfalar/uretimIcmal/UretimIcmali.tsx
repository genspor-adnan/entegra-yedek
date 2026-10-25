import { useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import {
  uretimIcmalUclari, type MalzemeIhtiyacSatiri, type UretimDurumSuzme, type UretimIcmali as Veri,
} from '../../api/uclar/uretimIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { isiRengi, kisaTl, Kutu, Kutucuk, sayi, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useStokKarti, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { EkranA4, TICARI_ICMAL_STILI, yuzde } from '../ticariIcmal/ticariIcmalOrtak';

/**
 * ÜRETİM İCMALİ `/uretim-icmali` (1176) - mockup Ekranlar/İcmal/uretim_icmali.html.
 * "Planı tutturuyor muyuz, fire ve sarf sapması nerede, birim maliyet plandan ne kadar saptı,
 * hangi iş merkezi dolu, hangi hammadde eksik?" Rakamlar sunucuda (UretimIcmalUclari); ekran
 * yalnız gösterir ve süzer. Özet kutuları yalnız ana emirler (alt emirler girintili ayrı satır).
 */
type Sekme = 'emir' | 'sarf' | 'fire' | 'maliyet' | 'yuk' | 'malzeme' | 'a4';

const DURUMLAR: [UretimDurumSuzme, string][] = [
  ['planli', 'Planlı'], ['uretimde', 'Üretimde'], ['kismi', 'Kısmi'], ['tamam', 'Tamamlandı'], ['hepsi', 'Hepsi'],
];
const TURLER: [number, string][] = [[0, 'Tüm türler'], [1, 'Siparişe'], [2, 'Stoğa'], [3, 'Fason']];
const gunAy = (t: string | null | undefined) => (t ? new Date(t).toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' }) : '—');
const isoGun = (t: string | null | undefined) => (t ? t.slice(0, 10) : '');
const durumSinif = (d: number) => (d >= 6 ? 'ok' : d === 5 ? 'sari' : d === 4 ? 'mavi' : 'pas');
const turSinif = (t: number) => (t === 1 ? 'mavi' : t === 3 ? 'mor' : t === 4 ? 'pas' : '');
const tutar = (n: number | null | undefined) => (n == null ? '—' : tl(n));

export function UretimIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const { kullanici } = useOturum();
  const antet = useAntet();
  const stokKarti = useStokKarti();
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState<{ metin: string; talepId?: number } | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [tazele, setTazele] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('emir');
  const [ara, setAra] = useState('');
  const [seciliEmir, setSeciliEmir] = useState<number | null>(null);
  const [hucre, setHucre] = useState<{ merkez: number; hafta: number } | null>(null);
  const [isliyor, setIsliyor] = useState(false);

  const bas = arama.get('bas') ?? '';
  const bit = arama.get('bit') ?? '';
  const durum = (arama.get('durum') ?? 'hepsi') as UretimDurumSuzme;
  const tur = Number(arama.get('tur') ?? 0);
  const sube = Number(arama.get('sube') ?? 0);
  const depo = Number(arama.get('depo') ?? 0);
  const isMerkezi = Number(arama.get('im') ?? 0);
  const mamul = Number(arama.get('mamul') ?? 0);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams();
    if (bas) q.set('bas', bas);
    if (bit) q.set('bit', bit);
    if (durum !== 'hepsi') q.set('durum', durum);
    if (tur) q.set('tur', String(tur));
    if (sube) q.set('sube', String(sube));
    if (depo) q.set('depo', String(depo));
    if (isMerkezi) q.set('isMerkezi', String(isMerkezi));
    if (mamul) q.set('mamul', String(mamul));
    uretimIcmalUclari.uretimIcmali(q).then(v => { setVeri(v); setHucre(null) })
      .catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, durum, tur, sube, depo, isMerkezi, mamul, tazele]);

  const kartAc = (yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) };
  const emirAc = (id: number) => { if (veri?.yetkiler.emir) kartAc(`/uretim-emri/${id}`) };

  const q = ara.trim().toLocaleLowerCase('tr');
  const uyar = (...l: string[]) => !q || l.some(x => x.toLocaleLowerCase('tr').includes(q));
  const emirler = useMemo(() => (veri?.emirler ?? []).filter(x => uyar(x.no, x.mamul, x.mamulKod, x.kaynak)), [veri, ara]); // eslint-disable-line react-hooks/exhaustive-deps
  const sarf = useMemo(() => (veri?.sarf ?? []).filter(x => uyar(x.kod, x.ad, x.emirNo)), [veri, ara]); // eslint-disable-line react-hooks/exhaustive-deps
  const malzeme = useMemo(() => (veri?.malzeme ?? []).filter(x => uyar(x.kod, x.ad, ...x.emirler.map(e => e.no))), [veri, ara]); // eslint-disable-line react-hooks/exhaustive-deps
  const o = veri?.ozet;
  const talepAcilabilir = (x: MalzemeIhtiyacSatiri) => !!veri?.yetkiler.talep && x.eksik > 0 && !x.talep && x.depoId > 0;
  const eksikler = (veri?.malzeme ?? []).filter(talepAcilabilir);

  /** Depo başına bir TASLAK talep (Kritik Stok İcmali ile aynı biçim). */
  const talepAc = async (satirlar: MalzemeIhtiyacSatiri[]) => {
    if (satirlar.length === 0) return;
    setIsliyor(true); setHata(''); setBilgi(null);
    try {
      const depolar = [...new Set(satirlar.map(x => x.depoId))];
      const sonuc: string[] = [];
      let sonId: number | undefined;
      for (const d of depolar) {
        const l = satirlar.filter(x => x.depoId === d);
        const r = await uretimIcmalUclari.uretimIcmalTalepAc(d, l.map(x => ({
          stokId: x.stokId, miktar: x.eksik, emirId: x.emirler.find(e => e.eksik > 0)?.id ?? x.emirler[0]?.id ?? null,
        })));
        sonId = r.id;
        sonuc.push(`${r.talepNo || '#' + r.id} (${l[0].depo || 'depo'} · ${r.kalem} kalem${r.atlanan ? `, ${r.atlanan} atlandı` : ''})`);
      }
      setBilgi({ metin: `Taslak satınalma talebi açıldı: ${sonuc.join(' · ')}. Onaya göndermek için talebi açın.`, talepId: depolar.length === 1 ? sonId : undefined });
      setTazele(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };

  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad : 'Tüm şubeler';
  const depoAdi = depo ? veri?.secim.depolar.find(s => s.id === depo)?.ad : '';
  const donem = veri ? `${tarihT(veri.bas)} – ${tarihT(veri.bit)}` : '';
  const a4 = veri && <UretimA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} subeAdi={[subeAdi, depoAdi].filter(Boolean).join(' · ')} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI + URETIM_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Üretim İcmali{donem && ` — ${donem}`}</h1><span className="yol">Üretim › İcmaller › Üretim İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Üretim İcmali" dosyaAdi={`Üretim İcmali ${isoGun(veri?.bas)} ${isoGun(veri?.bit)}`} devre={!veri}>{a4}</CiktiMenusu>
        <div className="sepv" />
        {veri?.yetkiler.emir && (
          <button disabled={!seciliEmir} onClick={() => seciliEmir && emirAc(seciliEmir)} title="Emirler sekmesinde satır seçin">🏭 Seçili emri aç</button>
        )}
        {veri?.yetkiler.talep && (
          <button disabled={isliyor || eksikler.length === 0} onClick={() => talepAc(eksikler)}
            title="Eksik hammaddeler için depo başına taslak satınalma talebi (açık talebi olan kalem atlanır)">
            📝 Eksik hammadde için talep aç{eksikler.length ? ` (${eksikler.length})` : ''}</button>
        )}
        <span className="sp" />
        <button onClick={() => git('/urun-agaci')}>🌳 Ürün Ağacı Listesi</button>
        <button onClick={() => git('/is-merkezi')}>⚙ İş Merkezi Listesi</button>
        <button onClick={() => git('/stok-kritik-stok-icmali')}>⚠ Kritik Stok İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="ui-bilgi">{bilgi.metin}
        {bilgi.talepId && <> <span className="lnk" onClick={() => git(`/satinalma-talep/${bilgi.talepId}`)}>Talebi aç</span></>}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Plan başlangıcı:
          <input type="date" value={bas || isoGun(veri?.bas)} onChange={e => degistir({ bas: e.target.value })} />
          –<input type="date" value={bit || isoGun(veri?.bit)} onChange={e => degistir({ bit: e.target.value })} /></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🏬 Depo:
          <select value={depo} onChange={e => degistir({ depo: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.depolar ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">⚙ İş merkezi:
          <select value={isMerkezi} onChange={e => degistir({ im: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.isMerkezleri ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">📦 Mamul:
          <select value={mamul} onChange={e => degistir({ mamul: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.mamuller ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="si-seg">
          {DURUMLAR.map(([k, a]) => <button key={k} type="button" className={durum === k ? 'on' : ''}
            onClick={() => degistir({ durum: k === 'hepsi' ? '' : k })}>{a}</button>)}
        </div>
        <div className="si-seg">
          {TURLER.map(([k, a]) => <button key={k} type="button" className={tur === k ? 'on' : ''}
            onClick={() => degistir({ tur: String(k) })}>{a}</button>)}
        </div>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.terminGecen > 0 && <span className="bo-rz kir">Termini geçen emir: <b>{o.terminGecen}</b></span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Emir" deg={sayi(o.emir)} alt={`siparişe ${o.siparise} · stoğa ${o.stoga} · fason ${o.fason}${o.altEmir ? ` · +${o.altEmir} alt emir` : ''}`} />
          <Kutu bas="Açık Emir" deg={sayi(o.acik)} alt={`üretimde ${o.uretimde} · kısmi ${o.kismi} · planlı ${o.planli}`} />
          <Kutu bas="Plan / Gerçekleşen" deg={o.gerceklesme == null ? '—' : yuzde(o.gerceklesme)} alt={`${sayi(o.plan)} planlı · ${sayi(o.uretilen)} üretildi`}
            sinif={o.gerceklesme == null ? '' : o.gerceklesme >= 95 ? 'iyi' : o.gerceklesme < 80 ? 'uy' : ''} />
          <Kutu bas="Fire" deg={o.fireOran == null ? '—' : yuzde(o.fireOran)} alt={`${sayi(o.fire)} adet · ${kisaTl(o.fireTutar)}`} sinif={o.fire ? 'uy' : ''} />
          <Kutu bas="Maliyet Sapması" deg={o.maliyetSapma == null ? '—' : yuzde(o.maliyetSapma, true)}
            alt={o.kapanan ? `gerçek birim plana göre · ${o.kapanan} kapanan emir` : 'kapanan emir yok'}
            sinif={o.maliyetSapma == null ? '' : Math.abs(o.maliyetSapma) > veri.esikler.maliyet ? 'teh' : o.maliyetSapma <= 0 ? 'iyi' : ''} />
          <Kutu bas="Doluluk" deg={o.doluluk == null ? '—' : `%${sayi(o.doluluk)}`} alt={`${veri.yuk.haftalar.length} haftalık plan saati / kapasite`}
            sinif={o.doluluk != null && o.doluluk > 100 ? 'teh' : o.doluluk != null && o.doluluk > 85 ? 'uy' : ''} />
          <Kutu bas="Termini Geçen" deg={sayi(o.terminGecen)} alt={o.enEskiGecikme != null ? `emir · en eski ${o.enEskiGecikme} gün` : 'emir'} sinif={o.terminGecen ? 'teh' : ''} />
          <Kutu bas="Eksik Hammadde" deg={sayi(o.eksikKalem)} alt={o.eksikKalem ? `kalem · ${kisaTl(o.eksikTutar)} · açık emirler için` : 'açık emirler için'} sinif={o.eksikKalem ? 'mor' : ''} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['emir', 'Emirler', veri.emirler.length], ['sarf', 'Sarf', null], ['fire', 'Fire', null], ['maliyet', 'Maliyet', null],
              ['yuk', 'İş Merkezi Yükü', null], ['malzeme', 'Malzeme İhtiyacı', o.eksikKalem || null], ['a4', '🖨 Önizleme (A4)', null]]} />

            {(sekme === 'emir' || sekme === 'sarf' || sekme === 'malzeme') && (
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Emir no, mamul ya da bileşen…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 280 }} />
                <span className="ki-soluk">{sekme === 'emir' ? 'satıra tıkla: seç · çift tıkla: emri aç · alt emirler ana emrin altında'
                  : sekme === 'sarf' ? `eşik ±%${sayi(veri.esikler.sarf)} (Genel Ayarlar › uretim.sapma_sarf_yuzde) · aşanlar üstte`
                  : 'eksik olanlar üstte, ilk gereken tarihe göre'}</span>
              </div>
            )}

            {sekme === 'emir' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Emir</th><th>Tür</th><th>Mamul</th><th className="sag">Plan</th><th className="sag">Üretilen</th>
                    <th className="sag">Fire</th><th className="sag">Kalan</th><th className="orta">Plan başl.</th><th className="orta">Termin</th>
                    <th className="orta">Gecikme</th><th>Durum</th><th>Kaynak</th></tr></thead>
                  <tbody>
                    {emirler.length === 0 && <tr><td colSpan={12} className="bos">
                      Bu süzgeçte üretim emri yok.{veri.emirler.length === 0 ? ' Dönemi genişletin ya da "Hepsi" durumunu seçin.' : ''}</td></tr>}
                    {emirler.map(x => (
                      <tr key={x.id} className={'ac' + (seciliEmir === x.id ? ' ti-sec' : '') + (x.derinlik ? ' ui-alt' : '')}
                        onClick={() => setSeciliEmir(x.id)} onDoubleClick={() => emirAc(x.id)}>
                        <td style={{ paddingLeft: 8 + x.derinlik * 18 }}>{x.derinlik > 0 && <span className="ki-soluk">└ </span>}
                          <span className={veri.yetkiler.emir ? 'lnk' : ''} onClick={() => emirAc(x.id)}>{x.no || `#${x.id}`}</span></td>
                        <td><span className={'bo-rz ' + turSinif(x.tur)}>{x.turAd}</span></td>
                        <td><span className="lnk" onClick={e => { e.stopPropagation(); stokKarti(x.stokId) }}>{x.mamul}</span></td>
                        <td className="sag">{sayi(x.plan)}</td><td className="sag">{sayi(x.uretilen)}</td>
                        <td className={'sag' + (x.fire ? ' kir' : '')}>{x.fire ? sayi(x.fire) : <span className="ki-soluk">0</span>}</td>
                        <td className="sag">{sayi(x.kalan)}</td>
                        <td className="orta">{gunAy(x.planBas)}</td><td className="orta">{gunAy(x.termin)}</td>
                        <td className="orta">{x.gecikme != null ? <span className="bo-rz kir">{x.gecikme} gün</span>
                          : x.kalanGun != null ? <span className="ki-soluk">{x.kalanGun} gün var</span> : <span className="ki-soluk">—</span>}</td>
                        <td><span className={'bo-rz ' + durumSinif(x.durum)}>{x.durumAd}</span>
                          {x.fasonda && <span className="bo-rz mor" style={{ marginLeft: 4 }}>fasonda</span>}</td>
                        <td>{x.ustEmirId ? <span className="lnk" onClick={e => { e.stopPropagation(); emirAc(x.ustEmirId!) }}>{x.kaynak}</span>
                          : x.kaynakBelgeId ? <span className="lnk" onClick={e => { e.stopPropagation(); kartAc(`/belge/${x.kaynakBelgeId}`) }}>{x.kaynak || `#${x.kaynakBelgeId}`}</span>
                          : <span className="ki-soluk">{x.kaynak || '—'}</span>}</td>
                      </tr>
                    ))}
                    {veri.sinirli && <tr><td colSpan={12} className="bos">İlk 3000 emir gösteriliyor — süzgeci daraltın.</td></tr>}
                    <tr className="top"><td colSpan={3}>Toplam ({o.emir} ana emir)</td><td className="sag">{sayi(o.plan)}</td><td className="sag">{sayi(o.uretilen)}</td>
                      <td className="sag">{sayi(o.fire)}</td><td className="sag">{sayi(veri.emirler.filter(x => x.ana && x.eslesti).reduce((t, x) => t + x.kalan, 0))}</td><td colSpan={5} /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Durum sırası (429): 1 taslak · 2 onaylı · 3 planlandı · 4 üretimde · 5 kısmi · 6 tamamlandı · 7 kapatıldı (iptal edilen emir icmale girmez).
                Kalan = plan − üretilen − fire. Kaynak: siparişe üretimde satış siparişi, alt emirde ana emir. Toplam satırı ve özet kutuları yalnız ana emirleri sayar;
                alt emirler (yarı mamul) ana emrin altında girintili gösterilir ama iki kez sayılmaz. Gecikme: açık emirde bugün − termin, tamamlanmış emirde bitiş − termin.
              </div>
            </>}

            {sekme === 'sarf' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Bileşen</th><th>Emir</th><th className="sag">Birim ihtiyaç</th><th className="sag">Ağaç fire %</th><th className="sag">Gerekli</th>
                    <th className="sag">Sarf edilen</th><th className="sag">Beklenen</th><th className="sag">Fark</th><th className="sag">Fark %</th><th className="sag">Fark tutarı</th><th>Satır durumu</th></tr></thead>
                  <tbody>
                    {sarf.length === 0 && <tr><td colSpan={11} className="bos">Bu süzgeçteki emirlerde bileşen satırı yok.</td></tr>}
                    {sarf.slice(0, 2000).map(x => (
                      <tr key={x.satirId}>
                        <td><span className="lnk" onClick={() => stokKarti(x.stokId)}>{x.ad}</span> <span className="ki-soluk">{x.kod}</span></td>
                        <td><span className={veri.yetkiler.emir ? 'lnk' : ''} onClick={() => emirAc(x.emirId)}>{x.emirNo}</span></td>
                        <td className="sag">{sayi(x.birimIhtiyac)}</td><td className="sag">%{sayi(x.fireYuzde)}</td>
                        <td className="sag">{sayi(x.gerekli)} {x.birim}</td><td className="sag">{sayi(x.sarfEdilen)} {x.birim}</td>
                        <td className="sag">{x.beklenen != null ? sayi(x.beklenen) : <span className="ki-soluk">—</span>}</td>
                        <td className={'sag' + (x.esikAsti ? ' kir' : '')}>{x.suruyor ? <span className="ki-soluk">sürüyor</span>
                          : x.fark != null ? `${x.fark > 0 ? '+' : ''}${sayi(x.fark)}` : <span className="ki-soluk">—</span>}</td>
                        <td className={'sag' + (x.esikAsti ? ' kir' : '')}>{x.farkYuzde != null ? yuzde(x.farkYuzde, true) : <span className="ki-soluk">—</span>}</td>
                        <td className={'sag' + (x.esikAsti ? ' kir' : '')}>{x.farkTutar != null ? `${x.farkTutar > 0 ? '+' : ''}${tl(x.farkTutar)}` : <span className="ki-soluk">—</span>}</td>
                        <td><span className={'bo-rz ' + (x.durum === 3 ? 'ok' : x.durum === 2 ? 'sari' : x.durum === 1 ? 'mavi' : 'pas')}>{x.durumAd}</span></td>
                      </tr>
                    ))}
                    {sarf.length > 2000 && <tr><td colSpan={11} className="bos">… {sarf.length - 2000} satır daha — süzgeci daraltın.</td></tr>}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Gerekli = birim ihtiyaç × plan × (1 + fire %) — emir açılırken ağaçtan donar, ağaç sonradan değişse emir bozulmaz.
                Beklenen = gerekli × üretilen / plan; Fark = sarf − beklenen (kısmi emirde orantılı karşılaştırılır). Tek seferde sarf edilmiş ve hâlâ üretimdeki
                emirde tüm malzeme başta çıktığı için oran anlamsızdır: "sürüyor". Fark tutarı = fark × satırın birim maliyeti.
                Kırmızı: |fark %| &gt; %{sayi(veri.esikler.sarf)}.
              </div>
            </>}

            {sekme === 'fire' && <>
              <Kutucuk baslik="Fire (malzemenin içinde)" not={`hedefin ${sayi(veri.esikler.fireKat)} katını aşan kırmızı · Genel Ayarlar › uretim.fire_hedef_kat`}>
                <table className="hi-tablo">
                  <thead><tr><th>Mamul</th><th className="sag">Üretilen</th><th className="sag">Fire</th><th className="sag">Fire %</th><th className="sag">Ağaç hedefi</th>
                    <th className="sag">Fire tutarı</th><th>En sık neden</th><th>Fire deposu</th></tr></thead>
                  <tbody>
                    {veri.fire.length === 0 && <tr><td colSpan={8} className="bos">Bu süzgeçte üretimi ya da firesi olan emir yok.</td></tr>}
                    {veri.fire.map(x => (
                      <tr key={x.stokId}>
                        <td><span className="lnk" onClick={() => stokKarti(x.stokId)}>{x.ad}</span>{x.emir > 1 && <span className="ki-soluk"> · {x.emir} emir</span>}</td>
                        <td className="sag">{sayi(x.uretilen)}</td><td className="sag">{sayi(x.fire)}</td>
                        <td className={'sag' + (x.esikAsti ? ' kir' : '')}><b>{x.oran != null ? yuzde(x.oran) : '—'}</b></td>
                        <td className="sag">{x.hedef != null ? yuzde(x.hedef) : <span className="ki-soluk">—</span>}</td>
                        <td className="sag">{x.tutar ? tl(x.tutar) : <span className="ki-soluk">0</span>}{x.tahmini && <span className="ki-soluk" title="kapanış yok - plan birim maliyetle"> ~</span>}</td>
                        <td>{x.neden || <span className="ki-soluk">—</span>}</td><td>{x.depo || <span className="ki-soluk">—</span>}</td>
                      </tr>
                    ))}
                    <tr className="top"><td>Toplam</td><td className="sag">{sayi(veri.fireToplam.uretilen)}</td><td className="sag">{sayi(veri.fireToplam.fire)}</td>
                      <td className="sag">{veri.fireToplam.oran != null ? yuzde(veri.fireToplam.oran) : '—'}</td><td /><td className="sag">{tl(veri.fireToplam.tutar)}</td><td colSpan={2} /></tr>
                  </tbody>
                </table>
              </Kutucuk>
              <div className="ki-soluk si-not">
                Fire = emrin fire adedi (mamul firesi, fire deposuna çıkış); Fire % = fire / (üretilen + fire). Fire tutarı = fire adedi × kapanıştaki birim maliyet;
                kapanışı olmayan emirde plan birim maliyetle (~). Bileşen firesi sarfın içindedir, ayrıca eklenmez — fire maliyeti malzemenin içindedir.
                Ağaç hedefi = emir satırlarının ağaçtan donmuş fire %'si (gerekliyle ağırlıklı). Neden = fire belgesindeki açıklama.
              </div>
            </>}

            {sekme === 'maliyet' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Emir</th><th>Mamul</th><th className="sag">Üretilen</th><th className="sag">Malzeme</th><th className="sag">İşçilik</th>
                    <th className="sag">GÜG</th><th className="sag">Fason</th><th className="sag">Toplam</th><th className="sag">Birim</th><th className="sag">Plan birim</th>
                    <th className="sag">Sapma</th><th className="orta">Kapanış</th></tr></thead>
                  <tbody>
                    {veri.maliyet.length === 0 && <tr><td colSpan={12} className="bos">Bu süzgeçte maliyeti oluşmuş emir yok.</td></tr>}
                    {veri.maliyet.map(x => (
                      <tr key={x.emirId} className={x.derinlik ? 'ui-alt' : ''}>
                        <td style={{ paddingLeft: 8 + x.derinlik * 18 }}>{x.derinlik > 0 && <span className="ki-soluk">└ </span>}
                          <span className={veri.yetkiler.emir ? 'lnk' : ''} onClick={() => emirAc(x.emirId)}>{x.no || `#${x.emirId}`}</span></td>
                        <td>{x.mamul}</td><td className="sag">{sayi(x.uretilen)}</td>
                        {x.durum === 'fasonda' ? <td colSpan={5} className="orta"><span className="bo-rz mor">fasonda</span>
                          <span className="ki-soluk"> · maliyet fason giriş belgesi gelince kesinleşir</span></td> : <>
                          <td className="sag">{tutar(x.malzeme)}</td><td className="sag">{tutar(x.iscilik)}</td>
                          <td className="sag">{x.gugYok ? <span className="bo-rz pas" title="GÜG ayrı dağıtılmıyor - iş merkezi saat ücretine dahil">0 · ücrete dahil</span> : tutar(x.gug)}</td>
                          <td className="sag">{tutar(x.fason)}{x.fasonEklendi && <span className="bo-rz mavi" style={{ marginLeft: 4 }} title="kapanış fason yazmamıştı - fason giriş belgesinden">belge</span>}</td>
                          <td className="sag"><b>{tutar(x.toplam)}</b></td></>}
                        <td className="sag">{x.birim != null ? tl(x.birim) : x.durum === 'acik' ? <span className="ki-soluk">canlı</span> : <span className="ki-soluk">—</span>}</td>
                        <td className="sag">{x.planBirim ? tl(x.planBirim) : <span className="ki-soluk">—</span>}</td>
                        <td className={'sag' + (x.esikAsti ? ' kir' : x.sapma != null && x.sapma < 0 ? ' si-yesil' : '')}>{x.sapma != null ? yuzde(x.sapma, true) : <span className="ki-soluk">—</span>}</td>
                        <td className="orta">{x.kapanis ? gunAy(x.kapanis) : <span className="bo-rz sari">açık</span>}</td>
                      </tr>
                    ))}
                    <tr className="top"><td colSpan={3}>Ana emirler ({veri.maliyetToplam.kapanan} kapanan · {veri.maliyetToplam.acik} açık{veri.maliyetToplam.fasonda ? ` · ${veri.maliyetToplam.fasonda} fasonda hariç` : ''})</td>
                      <td className="sag">{tl(veri.maliyetToplam.malzeme)}</td><td className="sag">{tl(veri.maliyetToplam.iscilik)}</td><td className="sag">{tl(veri.maliyetToplam.gug)}</td>
                      <td className="sag">{tl(veri.maliyetToplam.fason)}</td><td className="sag">{tl(veri.maliyetToplam.toplam)}</td><td colSpan={4} /></tr>
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Kapanan emirde rakamlar uretim_maliyet kapanış kaydından (tarihli, donmuş); açık emirde canlı toplam (emrin gerçek alanları — birim "canlı").
                İşçilik = zaman kaydı saati × ücret (elle tutar girilmez). GÜG ayrı dağıtılmaz, iş merkezi saat ücretine dahildir; kapanış GÜG yazmadıysa 0 ve rozetli.
                Fasondaki emir canlı maliyet göstermez; maliyet fason giriş irsaliyesi / faturası gelince kesinleşir. Sapma = (birim − plan birim) / plan birim;
                kırmızı: ±%{sayi(veri.esikler.maliyet)} (Genel Ayarlar › uretim.sapma_maliyet_yuzde). Toplam satırı alt emirleri saymaz (maliyetleri ana emrin malzemesinde).
              </div>
            </>}

            {sekme === 'yuk' && <YukSekmesi v={veri} hucre={hucre} setHucre={setHucre} emirAc={emirAc} />}

            {sekme === 'malzeme' && <>
              <div style={{ overflowX: 'auto' }}>
                <table className="hi-tablo">
                  <thead><tr><th>Kod</th><th>Bileşen</th><th>Depo</th><th className="sag">Kalan ihtiyaç</th><th className="sag">Rezerve</th>
                    <th className="sag">Eldeki</th><th className="sag">Yoldaki</th><th className="sag">Eksik</th><th className="orta">İlk gereken</th><th>Emirler</th><th /></tr></thead>
                  <tbody>
                    {malzeme.length === 0 && <tr><td colSpan={11} className="bos">Açık emirlerde karşılanmamış malzeme ihtiyacı yok.</td></tr>}
                    {malzeme.map(x => (
                      <tr key={`${x.stokId}:${x.depoId}`}>
                        <td>{x.kod}</td><td><span className="lnk" onClick={() => stokKarti(x.stokId)}>{x.ad}</span></td>
                        <td>{x.depo || <span className="bo-rz sari">sarf deposu yok</span>}</td>
                        <td className="sag">{sayi(x.ihtiyac)} {x.birim}</td>
                        <td className="sag">{x.rezerve ? sayi(x.rezerve) : <span className="ki-soluk">0</span>}</td>
                        <td className="sag" title={`kalan − SKT'si geçmiş (${sayi(x.sktGecmis)}) − başka rezerv (${sayi(x.baskaRezerv)})`}>{sayi(x.eldeki)}
                          {x.sktGecmis > 0 && <span className="bo-rz sari" style={{ marginLeft: 4 }}>SKT −{sayi(x.sktGecmis)}</span>}</td>
                        <td className="sag">{x.yoldaki ? sayi(x.yoldaki) : <span className="ki-soluk">0</span>}</td>
                        <td className={'sag' + (x.eksik > 0 ? ' kir' : '')}><b>{x.eksik > 0 ? sayi(x.eksik) : '0'}</b></td>
                        <td className="orta">{x.eksik > 0 ? tarihT(x.ilkGereken) : <span className="ki-soluk">—</span>}</td>
                        <td style={{ whiteSpace: 'normal' }}>{x.emirler.map((e, i) => <span key={e.id}>{i > 0 && ', '}
                          <span className={veri.yetkiler.emir ? 'lnk' : ''} onClick={() => emirAc(e.id)} title={e.eksik ? `eksik ${sayi(e.eksik)}` : 'karşılanıyor'}>{e.no || `#${e.id}`}</span></span>)}</td>
                        <td>{x.eksik <= 0 ? <span className="bo-rz ok">yeterli</span>
                          : x.talep ? <span className="bo-rz sari">Talep {x.talep}</span>
                          : talepAcilabilir(x) ? <button disabled={isliyor} onClick={() => talepAc([x])}>Talep aç</button>
                          : <span className="bo-rz kir">eksik</span>}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              <div className="ki-soluk si-not">
                Kalan ihtiyaç = gerekli − sarf edilen (açık emir satırları; alt emirle üretilen yarı mamul hariç). Eldeki = sarf deposundaki kalan − SKT'si geçmiş lot
                − başka kayıtların rezervi; emrin kendi rezervi düşülmez ve önce kendi satırını karşılar, kalan serbest stok ilk gereken tarihe (plan başlangıcı) göre
                sırayla dağıtılır. Eksik = karşılanamayan − yoldaki (açık alış siparişi). "Talep aç" Kritik Stok İcmali'ndeki gibi depo başına TASLAK satınalma talebi
                açar (kaynak: üretim emri); açık talebi olan kalem atlanır — satinalma.talep ekleme yetkisi gerekir. Dönem ve durum seçimi bu sekmeyi etkilemez.
              </div>
            </>}

            {sekme === 'a4' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>
        <div className="ui-durum ki-soluk">
          <span>{o.emir} emir</span><span>{o.acik} açık</span><span>{o.isMerkezi} iş merkezi</span>
          {o.fasonda > 0 && <span>{o.fasonda} fasonda</span>}<span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

function YukSekmesi({ v, hucre, setHucre, emirAc }: {
  v: Veri; hucre: { merkez: number; hafta: number } | null; setHucre(h: { merkez: number; hafta: number } | null): void; emirAc(id: number): void;
}) {
  const y = v.yuk;
  const secOps = hucre ? y.operasyonlar.filter(x => (hucre.merkez === 0
    ? !y.merkezler.some(m => m.id > 0 && m.id === x.isMerkeziId) : x.isMerkeziId === hucre.merkez) && x.haftalar[hucre.hafta] > 0) : [];
  const haftaAdi = (i: number) => i < y.haftalar.length ? `${gunAy(y.haftalar[i].bas)} – ${gunAy(y.haftalar[i].bit)}` : 'Sonrası';
  return (<>
    <Kutucuk baslik="İş merkezi yükü — haftalık plan saati / kapasite" not="hücreye tıkla: o haftanın operasyonları">
      <table className="hi-tablo">
        <thead><tr><th>İş merkezi</th><th className="sag">Kapasite / hafta</th>
          {y.haftalar.map((h, i) => <th key={h.bas} className="sag">{haftaAdi(i)}</th>)}<th className="sag">Sonrası</th><th className="sag">Duruş (bu ay)</th></tr></thead>
        <tbody>
          {y.merkezler.length === 0 && <tr><td colSpan={y.haftalar.length + 4} className="bos">Tanımlı iş merkezi yok — Üretim › Ayarlar › İş Merkezleri.</td></tr>}
          {y.merkezler.map(m => (
            <tr key={m.id}>
              <td>{m.kod ? <b>{m.kod}</b> : null} {m.ad}{m.fason && <span className="bo-rz mor" style={{ marginLeft: 4 }}>fason</span>}
                {m.ucretYok && <span className="bo-rz sari" style={{ marginLeft: 4 }} title="saat ücreti tanımsız - işçilik 0 yazılır">ücret yok</span>}</td>
              <td className="sag">{m.kapasite ? `${sayi(m.kapasite)} saat` : <span className="ki-soluk">—</span>}</td>
              {m.hucreler.map((h, i) => {
                const son = i >= y.haftalar.length;
                const secili = hucre?.merkez === m.id && hucre.hafta === i;
                return (
                  <td key={i} className={'sag ac' + (h.oran != null && h.oran > 100 ? ' kir' : '') + (secili ? ' ui-hucre-sec' : '')}
                    style={{ background: secili ? undefined : !son && h.oran != null ? isiRengi(Math.min(h.oran, 100), 100) : undefined, cursor: h.operasyon ? 'pointer' : undefined }}
                    title={`${sayi(h.saat)} saat · ${h.operasyon} operasyon`}
                    onClick={() => h.operasyon && setHucre(secili ? null : { merkez: m.id, hafta: i })}>
                    {h.saat <= 0 ? <span className="ki-soluk">—</span> : son || h.oran == null ? `${sayi(h.saat)} sa` : <>%{sayi(h.oran)}{h.oran > 100 && ' ⚠'}</>}
                  </td>
                );
              })}
              <td className="sag">{m.durus ? `${sayi(m.durus)} saat` : <span className="ki-soluk">0</span>}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </Kutucuk>
    {hucre && (
      <Kutucuk baslik={`${y.merkezler.find(m => m.id === hucre.merkez)?.ad ?? ''} · ${haftaAdi(hucre.hafta)}`} not={`${secOps.length} operasyon`}>
        <table className="hi-tablo"><thead><tr><th>Emir</th><th>Operasyon</th><th className="orta">Başlangıç</th><th className="orta">Bitiş</th>
          <th className="sag">Bu hafta</th><th className="sag">Kalan plan saati</th></tr></thead>
          <tbody>{secOps.map(x => (
            <tr key={x.id}><td><span className="lnk" onClick={() => emirAc(x.emirId)}>{x.emirNo || `#${x.emirId}`}</span></td><td>{x.ad}</td>
              <td className="orta">{gunAy(x.bas)}</td><td className="orta">{gunAy(x.bit)}</td>
              <td className="sag">{sayi(x.haftalar[hucre.hafta])} sa</td><td className="sag">{sayi(x.saat)} sa</td></tr>))}</tbody></table>
      </Kutucuk>
    )}
    <div className="ki-soluk si-not">
      Plan saati = açık emirlerin bitmemiş operasyonlarında kalan plan saati (plan − gerçek), başlangıç – bitiş arasındaki iş günlerine eşit yayılır;
      geçmişte kalan (gecikmiş) yük bu haftaya düşer. Kapasite = iş merkezi kartındaki günlük kapasite × {y.kapasiteGun} iş günü. Duruş = bu ayki duruş zaman kayıtları.
      %100 üstü kırmızı. Dönem ve durum seçimi bu sekmeyi etkilemez (ileriye bakar).
    </div>
  </>);
}

function UretimA4({ v, antet, duzenleyen, subeAdi }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; subeAdi: string }) {
  const o = v.ozet;
  const d = v.a4.dip;
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>ÜRETİM İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>Şube: {subeAdi || 'Tüm şubeler'}</span>
        <span>{o.emir} emir · {v.a4.mamuller.length} mamul</span><span>Plan / gerçek: {o.gerceklesme != null ? yuzde(o.gerceklesme) : '—'}</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Mamul</th><th>Plan</th><th>Üretilen</th><th>Fire %</th><th>Birim maliyet</th><th>Sapma</th></tr></thead>
        <tbody>
          {v.a4.mamuller.length === 0 && <tr><td colSpan={6} style={{ textAlign: 'center' }}>Bu dönemde üretim emri yok.</td></tr>}
          {v.a4.mamuller.map(x => <tr key={x.stokId}><td>{x.ad}</td><td>{sayi(x.plan)}</td><td>{sayi(x.uretilen)}</td>
            <td>{x.fireOran != null ? yuzde(x.fireOran) : '—'}</td><td>{x.birim != null ? tl(x.birim) : '—'}</td>
            <td>{x.sapma != null ? yuzde(x.sapma, true) : '—'}</td></tr>)}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Malzeme</td><td>{tl(d.malzeme)}</td></tr>
        <tr><td>İşçilik</td><td>{tl(d.iscilik)}</td></tr>
        {d.gug !== 0 && <tr><td>GÜG</td><td>{tl(d.gug)}</td></tr>}
        <tr><td>Fason</td><td>{tl(d.fason)}</td></tr>
        <tr><td>Fire (malzemenin içinde)</td><td>{tl(d.fire)}</td></tr>
        <tr className="kalan ki-kalan"><td>ÜRETİM MALİYETİ</td><td>{tl(d.toplam)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Kapanan emirler kapanış kaydından, açık emirler canlı toplam · fasondaki ({d.fasonda}) emir dahil değil · alt emirler ana emrin malzemesinde.</p>
      <div className="a4-imza"><div>Üretim Planlama<br />Ad Soyad · İmza</div><div>Fabrika Müdürü<br />Kaşe · İmza</div></div>
    </div>
  );
}

const URETIM_ICMAL_STILI = `
.bo-rz.mor { background:#f1ecfa; color:#6a3fb5; border-color:#ddd0f2; }
.hi-tablo tr.ui-alt td { background:#fbfcfe; }
.hi-tablo td.ui-hucre-sec { background:#2f6db3 !important; color:#fff; }
.ui-bilgi { margin:6px 0; padding:6px 10px; background:#e2f3e8; border:1px solid #bfe3cb; border-radius:4px; }
.ui-durum { display:flex; gap:14px; padding:5px 2px; font-size:11px; border-top:1px solid #e3e9f0; margin-top:8px; }
`;

export default UretimIcmali;
