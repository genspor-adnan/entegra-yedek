import { Fragment, useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ApiHatasi, hataMetni } from '../../api/sozlesme';
import {
  KALEM_AMORTISMAN, KALEM_ATANMAMIS, masrafIcmalUclari, type MasrafDetay, type MasrafDetaySatiri, type MasrafDikkat,
  type MasrafIcmali as Veri, type MasrafPlanSatiri,
} from '../../api/uclar/masrafIcmal';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { listeSor, onay } from '../../bilesenler/mesaj';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Cubuk, Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { ayAdi, DegisimRozeti, EkranA4, hazirDonem, kisa, tarihT, TICARI_ICMAL_STILI, tl, yilBasi, yuzde } from '../ticariIcmal/ticariIcmalOrtak';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';

/**
 * MASRAF İCMALİ `/masraf-icmali` - mockup Ekranlar/İcmal/masraf_icmali.html (kararlar 25.10.2026).
 * "Paramız nereye gidiyor, geçen yıla ve plana göre nerede artıyor, hangi merkez ne harcıyor?"
 * Rakamlar SUNUCUDAN (MasrafIcmalUclari): kesin alış belgesinin stoksuz satırları + kasa / banka masraf
 * bacağı (v_masraf_ekstre) + onaylı masraf beyanı + demirbaş amortismanı; plan Planlı Giderler'in dönem
 * planından. "Masraf kalemi ata…" seçili satırlara toplu kalem atar (belge Değiştir, loglu; kapanmış
 * dönemde pasif). Ekran toplamaz, yalnız gösterir.
 */
type Sekme = 'klm' | 'mrk' | 'trd' | 'pln' | 'ted' | 'det' | 'dkt' | 'onz';
/** Belge Detayı süzgeci: ust (üst kalem, -1 atanmamış, -2 amortisman) · alt (kalem) · dmerkez (-1 atanmamış) · tedarikci. */
type DetaySuzgec = { ust?: number; alt?: number; dmerkez?: number; tedarikci?: number };

const DIGER_KOLON = -9;
const anahtar = (s: { kaynak: string; satirId: number }) => `${s.kaynak}:${s.satirId}`;
const PLAN_SINIF: Record<MasrafPlanSatiri['durum'], string> = { planinda: 'ok', odenmedi: 'sari', tahmin: 'sari', artis: 'kir', alti: 'mavi' };
const DIKKAT_SINIF: Record<MasrafDikkat['tur'], string> = { atanmamis: 'sari', artis: 'kir', mukerrer: 'kir', kdv: 'sari', plansiz: 'mavi' };

/** Fark hücresi: gider ARTIŞI kötü (kırmızı). */
const farkMetni = (n: number | null | undefined) => (n == null || Math.abs(n) < 0.005 ? '0' : `${n > 0 ? '+' : '−'}${tl(Math.abs(n))}`);

export function MasrafIcmali() {
  const { arama, degistir } = useSuzgec();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  const kartAc = (yol: string) => { if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol) };

  const bas = arama.get('bas') ?? yilBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const karsi = arama.get('karsi') === 'od' ? 'od' : 'gy';
  const sube = Number(arama.get('sube') ?? 0);
  const merkez = Number(arama.get('merkez') ?? 0);
  const kalem = Number(arama.get('kalem') ?? 0);
  const kdvDahil = arama.get('kdv') === '1';
  const planKiyas = arama.get('plansiz') !== '1';
  const taslak = arama.get('taslak') === '1';
  const amortisman = arama.get('amortismansiz') !== '1';

  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [tazele, setTazele] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('klm');
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const [dSuz, setDSuz] = useState<DetaySuzgec>({});
  const [detay, setDetay] = useState<MasrafDetay | null>(null);
  const [detayYuk, setDetayYuk] = useState(false);
  const [secili, setSecili] = useState<Set<string>>(new Set());
  const [secSatir, setSecSatir] = useState<MasrafDetaySatiri | null>(null);
  const [secMasraf, setSecMasraf] = useState(0);
  const [tumTedarikci, setTumTedarikci] = useState(false);
  const [isliyor, setIsliyor] = useState(false);

  const anaSorgu = useMemo(() => {
    const q = new URLSearchParams({ bas, bit, karsi });
    if (sube) q.set('sube', String(sube));
    if (merkez) q.set('merkez', String(merkez));
    if (kalem) q.set('kalem', String(kalem));
    if (kdvDahil) q.set('kdv', '1');
    if (!planKiyas) q.set('plan', '0');
    if (taslak) q.set('taslak', '1');
    if (!amortisman) q.set('amortisman', '0');
    return q.toString();
  }, [bas, bit, karsi, sube, merkez, kalem, kdvDahil, planKiyas, taslak, amortisman]);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    masrafIcmalUclari.masrafIcmali(new URLSearchParams(anaSorgu))
      .then(v => setVeri(v))
      .catch(h => setHata(hataMetni(h)))
      .finally(() => setYukleniyor(false));
  }, [anaSorgu, tazele]);

  // Belge Detayı yalnız sekme açıkken yüklenir (süzgeç değişince yeniden).
  useEffect(() => {
    if (sekme !== 'det') return;
    const q = new URLSearchParams(anaSorgu);
    if (dSuz.ust) q.set('ust', String(dSuz.ust));
    if (dSuz.alt) q.set('alt', String(dSuz.alt));
    if (dSuz.dmerkez) q.set('dmerkez', String(dSuz.dmerkez));
    if (dSuz.tedarikci) q.set('tedarikci', String(dSuz.tedarikci));
    setDetayYuk(true);
    masrafIcmalUclari.detay(q)
      .then(v => { setDetay(v); setSecili(new Set()); setSecSatir(null) })
      .catch(h => setHata(hataMetni(h)))
      .finally(() => setDetayYuk(false));
  }, [sekme, anaSorgu, dSuz, tazele]);

  const detayaGit = (s: DetaySuzgec) => { setDSuz(s); setSekme('det') };
  const cevir = (id: number) => setAcik(a => { const n = new Set(a); if (n.has(id)) n.delete(id); else n.add(id); return n });
  const secCevir = (k: string) => setSecili(s => { const n = new Set(s); if (n.has(k)) n.delete(k); else n.add(k); return n });

  const belgeAc = (s: MasrafDetaySatiri) => {
    if (s.kaynak === 'belge') kartAc(`/belge/${s.belgeId}`);
    else if (s.kaynak === 'kasa' && s.belgeId > 0) kartAc(`/kasa-islem/${s.belgeId}`);
    else if (s.kaynak === 'beyan') kartAc(`/personel-masraf/${s.belgeId}`);
  };

  const o = veri?.ozet;
  const karsiAdi = karsi === 'gy' ? 'Geçen yıl' : 'Önceki dönem';
  const atanabilirSatirlar = (detay?.satirlar ?? []).filter(s => !s.atamaEngeli);
  const seciliSatirlar = (detay?.satirlar ?? []).filter(s => secili.has(anahtar(s)));
  const kapanmisMetin = veri ? `Kapanmış muhasebe dönemi: ${tarihT(veri.acikDonemBasi)} öncesi (yalnız görüntülenir)` : '';

  // ------------------------------------------------------------ Masraf kalemi ata --
  const ata = async () => {
    setHata(''); setBilgi('');
    if (!veri) return;
    if (sekme !== 'det' || seciliSatirlar.length === 0) {
      detayaGit({ ust: KALEM_ATANMAMIS });
      setBilgi('Kalem atanmamış satırlar listelendi. Atanacak satırları işaretleyip yeniden "✎ Masraf kalemi ata…" deyin (başka kalemdeki satırı da yeniden atayabilirsiniz).');
      return;
    }
    if (veri.secim.atanabilir.length === 0) { setHata('Atanabilir (başlık olmayan, aktif) masraf kalemi yok; önce masraf kartı açın.'); return }
    const secim = await listeSor(`${seciliSatirlar.length} satıra atanacak masraf kalemi:`,
      veri.secim.atanabilir.map(m => ({ kod: String(m.id), ad: `${m.kod ? m.kod + ' ' : ''}${m.ad}${m.ust ? ` · ${m.ust}` : ''}` })),
      '', 'Masraf kalemi');
    if (!secim) return;
    const masrafId = Number(secim);
    const m = veri.secim.atanabilir.find(x => x.id === masrafId);
    const toplam = seciliSatirlar.reduce((t, s) => t + s.tutar, 0);
    if (!await onay(`${seciliSatirlar.length} gider satırı (${tl(toplam)} ₺) "${m ? `${m.kod} ${m.ad}`.trim() : secim}" kalemine atanacak.\n\n`
      + 'Tutar, cari ve stok değişmez; belge satırı masraf satırı olur, kasa işleminin masraf bacağı bu kaleme yazılır. İşlem loglanır.'
      + (seciliSatirlar.some(s => s.fis) ? '\n\nBazı belgelerin muhasebe fişi var: gider hesabı fişte kendiliğinden değişmez.' : ''))) return;
    setIsliyor(true);
    try {
      const y = await masrafIcmalUclari.ata(masrafId, seciliSatirlar.map(s => ({ kaynak: s.kaynak as 'belge' | 'kasa', id: s.satirId })));
      setBilgi(`${y.atanan} satır (${y.belgeler} belge / işlem) "${y.masraf.ad}" kalemine atandı.` + (y.uyarilar.length ? ' ' + y.uyarilar.join(' ') : ''));
      setTazele(t => t + 1);
    } catch (h) {
      const engel = h instanceof ApiHatasi ? (h.hata.engel as unknown as { kod?: string } | undefined) : undefined;
      setHata(engel?.kod === 'KAPANMIS_DONEM' ? `⚠ ${hataMetni(h)}` : hataMetni(h));
    } finally { setIsliyor(false) }
  };

  const subeAdi = sube ? veri?.secim.subeler.find(s => s.id === sube)?.ad ?? '' : 'Tüm şubeler';
  const merkezAdi = merkez === -1 ? '(merkez atanmamış)' : merkez ? veri?.secim.merkezler.find(s => s.id === merkez)?.ad ?? '' : 'Tümü';
  const kipYazi = `${kdvDahil ? 'KDV dahil' : 'KDV hariç'} · karşılaştırma: ${karsiAdi.toLocaleLowerCase('tr')}${amortisman ? ' · amortisman dahil' : ''}${taslak ? ' · taslaklar dahil' : ''}`;
  const a4 = veri && <MasrafA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} sube={subeAdi} merkez={merkezAdi} kip={kipYazi} karsiAdi={karsiAdi} />;
  const ataPasif = !veri?.yetkiler.ata || isliyor;
  const ataBaslik = !veri?.yetkiler.ata ? 'Belge değiştirme yetkisi gerekir'
    : sekme === 'det' && seciliSatirlar.length > 0 ? `${seciliSatirlar.length} satıra kalem ata` : 'Kalem atanmamış satırları listeler; seçip atayın';

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + TICARI_ICMAL_STILI + MASRAF_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Masraf İcmali</h1><span className="yol">Finans › İcmaller › Masraf İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Masraf İcmali" dosyaAdi={`Masraf İcmali ${bas} ${bit}`} devre={!veri}>{a4}</CiktiMenusu>
        <button disabled={!secSatir || secSatir.kaynak === 'amortisman'} onClick={() => secSatir && belgeAc(secSatir)}
          title={secSatir ? '' : 'Önce Belge Detayı sekmesinde bir satıra tıklayın'}>📄 Seçili belgeyi aç</button>
        <button disabled={secMasraf <= 0} onClick={() => kartAc(`/masraf/${secMasraf}`)}
          title={secMasraf > 0 ? 'Masraf kalemi kartı' : 'Önce Kalem sekmesinde bir kalem satırına tıklayın'}>🏷 Masraf kartı</button>
        <button disabled={ataPasif} onClick={() => void ata()} title={ataBaslik}>✎ Masraf kalemi ata…</button>
        <span className="sp" />
        <button onClick={() => git('/planli-gider')}>🗓️ Planlı Giderler</button>
        <button onClick={() => git('/nakit-akis-icmali')}>📊 Nakit Akış İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="hi-serit" style={{ background: '#eef7ee' }}><span>{bilgi}</span></div>}

      <div className="hi-serit">
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} max={bit} onChange={e => e.target.value && degistir({ bas: e.target.value })} />
          –<input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
          <select value="" onChange={e => { if (!e.target.value) return; const [b1, b2] = hazirDonem(e.target.value); degistir({ bas: b1, bit: b2 }) }}>
            <option value="">hazır…</option><option value="buyil">Bu yıl</option><option value="buay">Bu ay</option>
            <option value="gecenay">Geçen ay</option><option value="son3">Son 3 ay</option><option value="gecenyil">Geçen yıl</option>
          </select></div>
        <div className="sel">⇄ Karşılaştır:
          <select value={karsi} onChange={e => degistir({ karsi: e.target.value === 'od' ? 'od' : '' })}>
            <option value="gy">Geçen yıl aynı dönem</option><option value="od">Önceki dönem</option>
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🎯 Masraf merkezi:
          <select value={merkez} onChange={e => degistir({ merkez: e.target.value })}>
            <option value={0}>Tümü</option><option value={-1}>(merkez atanmamış)</option>
            {(veri?.secim.merkezler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel">🗂 Kalem:
          <select value={kalem} onChange={e => degistir({ kalem: e.target.value })}>
            <option value={0}>Tümü (ağaç)</option><option value={KALEM_ATANMAMIS}>Diğer (kalem atanmamış)</option>
            <option value={KALEM_AMORTISMAN}>Amortisman</option>
            {(veri?.secim.kalemler ?? []).map(k => <option key={k.id} value={k.id}>{k.derinlik ? '   ' : ''}{k.ad}</option>)}
          </select></div>
        <div className="si-seg" title="Varsayılan KDV hariç (gider budur; indirilecek KDV gider değil). KDV dahil nakit bakışı içindir.">
          <button type="button" className={!kdvDahil ? 'on' : ''} onClick={() => degistir({ kdv: '' })}>KDV hariç</button>
          <button type="button" className={kdvDahil ? 'on' : ''} onClick={() => degistir({ kdv: '1' })}>KDV dahil</button>
        </div>
        <label className="ti-chk"><input type="checkbox" checked={planKiyas} onChange={e => degistir({ plansiz: e.target.checked ? '' : '1' })} /> Planlı giderle kıyasla</label>
        <label className="ti-chk"><input type="checkbox" checked={amortisman} onChange={e => degistir({ amortismansiz: e.target.checked ? '' : '1' })} /> Amortisman dahil</label>
        <label className="ti-chk"><input type="checkbox" checked={taslak} onChange={e => degistir({ taslak: e.target.checked ? '1' : '' })} /> Taslaklar dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.atanmamis.satir > 0 && (
          <span className="bo-rz sari ac" onClick={() => detayaGit({ ust: KALEM_ATANMAMIS })} title="Belge Detayı'nda listele">
            Masraf kalemi atanmamış gider: {o.atanmamis.satir} satır · {tl(o.atanmamis.tutar)} ₺</span>
        )}
      </div>

      {veri && o && (<>
        {veri.uyarilar.length > 0 && <div className="hi-serit ki-soluk" style={{ background: '#fffaf0' }}>{veri.uyarilar.join(' ')}</div>}
        <div className="hi-ozet">
          <Kutu bas="Toplam Gider" deg={kisa(o.toplam, '')} alt={`${kdvDahil ? 'KDV dahil' : 'KDV hariç'} · ${o.ay} ay`} />
          <Kutu bas={karsi === 'gy' ? 'Geçen Yıl Aynı Dönem' : 'Önceki Dönem'} deg={yuzde(o.degisim ?? null, true)} alt={`${tl(o.karsi)} ₺`}
            sinif={o.degisim == null ? '' : o.degisim > 0 ? 'teh' : 'iyi'} />
          <Kutu bas="Aylık Ortalama" deg={kisa(o.aylikOrt, '')} alt={`son 3 ay ${tl(o.son3Ort)}`} />
          <Kutu bas="Planlı Gider (aynı dönem)" deg={veri.planKiyas ? kisa(o.plan, '') : '—'}
            alt={veri.planKiyas ? `${o.planTanim} tanım · kalemi tanımlı gider` : 'kıyas kapalı'} />
          <Kutu bas="Plan − Gerçek" deg={veri.planKiyas && o.planTanim > 0 ? `${farkMetni(o.planFark)} ₺` : '—'}
            alt={veri.planKiyas && o.planTanim > 0 ? `${yuzde(o.planFarkYuzde ?? null, true)}${o.planFarkKalemler.length ? ' · ' + o.planFarkKalemler.join(', ').toLocaleLowerCase('tr') : ''}` : 'planlı gider yok'}
            sinif={veri.planKiyas && o.planFark > 0.005 ? 'uy' : ''} />
          <Kutu bas="En Büyük Kalem" deg={o.enBuyuk?.ad ?? '—'} alt={o.enBuyuk ? `%${o.enBuyuk.pay.toLocaleString('tr-TR')} · ${tl(o.enBuyuk.tutar)} ₺` : ''} />
          <Kutu bas="Gider / Ciro" deg={o.giderCiro == null ? '—' : `%${o.giderCiro.toLocaleString('tr-TR')}`}
            alt={`ciro ${kisa(o.ciro, '')} (net satış, KDV hariç)`} sinif="mor" />
          <Kutu bas="Atanmamış" deg={`${o.atanmamis.satir} satır`} alt={o.atanmamis.satir ? `${tl(o.atanmamis.tutar)} ₺ · "Diğer"e düştü` : 'bütün satırların kalemi var'}
            sinif={o.atanmamis.satir ? 'uy' : 'iyi'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['klm', 'Kalem (ağaç)', null], ['mrk', 'Masraf Merkezi', null], ['trd', 'Aylık Trend', null],
              ['pln', 'Plan − Gerçek', veri.planKiyas ? veri.plan.satirlar.length : null], ['ted', 'Tedarikçi', null],
              ['det', 'Belge Detayı', detay && sekme === 'det' ? detay.sayi : null], ['dkt', 'Dikkat', veri.dikkat.length],
              ['onz', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'klm' && <>
              <Kutucuk baslik="Masraf kalemleri — üst kalem › alt kalem" not="satıra tıkla: alt kalemler · çift tık: belge detayı · ▾ açık, ▸ kapalı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Kalem</th><th>Kod</th><th>Muhasebe</th><th className="sag">Bu dönem</th><th className="sag">{karsiAdi}</th>
                      <th className="orta">Fark</th><th className="sag">Pay</th><th className="sag">Aylık ort.</th><th style={{ width: 100 }} /></tr></thead>
                    <tbody>
                      {veri.kalemler.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde gider yok.</td></tr>}
                      {veri.kalemler.map(u => {
                        const acilir = u.altlar.length > 1 || (u.altlar.length === 1 && !u.altlar[0].dogrudan);
                        return (
                          <Fragment key={u.id}>
                            <tr className={'ac' + (acilir ? ' si-grup' : '') + (secMasraf === u.id ? ' ti-sec' : '')}
                              onClick={() => { if (acilir) cevir(u.id); setSecMasraf(u.id > 0 ? u.id : 0); setDSuz({ ust: u.id }) }}
                              onDoubleClick={() => detayaGit({ ust: u.id })}>
                              <td className="ti-ad"><span className="ok">{acilir ? (acik.has(u.id) ? '▾' : '▸') : ''}</span>
                                <span className={u.atanmamis ? 'ki-soluk' : ''}>{u.ad}</span>
                                {u.nakitDisi && <span className="bo-rz mavi" style={{ marginLeft: 4 }}>nakit çıkışı yok</span>}
                                {u.artis != null && <span className="bo-rz kir" style={{ marginLeft: 4 }}
                                  title={`Son 3 tam ay ortalaması önceki 6 ayın %${u.artis.toLocaleString('tr-TR')} üstünde`}>⚠ artış</span>}</td>
                              <td>{u.kod || '—'}</td><td className="ki-soluk">{u.muhKodu}</td>
                              <td className="sag"><b>{tl(u.tutar)}</b></td><td className="sag">{tl(u.karsi)}</td>
                              <td className="orta"><DegisimRozeti d={u.degisim ?? null} ters /></td>
                              <td className="sag">%{u.pay.toLocaleString('tr-TR')}</td><td className="sag">{tl(u.aylikOrt)}</td>
                              <td><Cubuk yuzde={Math.abs(u.pay)} /></td>
                            </tr>
                            {acilir && acik.has(u.id) && u.altlar.map(x => (
                              <tr key={`${u.id}-${x.id}`} className={'ac si-alt' + (secMasraf === x.id ? ' ti-sec' : '')}
                                onClick={() => { setSecMasraf(x.id > 0 ? x.id : 0); setDSuz({ ust: u.id, alt: x.id }) }}
                                onDoubleClick={() => detayaGit({ ust: u.id, alt: x.id })}>
                                <td className="ti-ad" style={{ paddingLeft: 26 }}>{x.ad}{x.dogrudan && <span className="ki-soluk"> (doğrudan)</span>}</td>
                                <td>{x.kod || '—'}</td><td className="ki-soluk">{x.muhKodu}</td>
                                <td className="sag">{tl(x.tutar)}</td><td className="sag">{tl(x.karsi)}</td>
                                <td className="orta"><DegisimRozeti d={x.degisim ?? null} ters /></td>
                                <td className="sag">%{x.pay.toLocaleString('tr-TR')}</td><td className="sag">{tl(x.aylikOrt)}</td><td />
                              </tr>
                            ))}
                          </Fragment>
                        );
                      })}
                      <tr className="top"><td colSpan={3}>Toplam</td><td className="sag">{tl(veri.kalemToplam.tutar)}</td>
                        <td className="sag">{tl(veri.kalemToplam.karsi)}</td><td className="orta">{yuzde(veri.kalemToplam.degisim ?? null, true)}</td>
                        <td className="sag">%100</td><td className="sag">{tl(veri.kalemToplam.aylikOrt)}</td><td /></tr>
                    </tbody>
                  </table>
                </div>
              </Kutucuk>
              <div className="ki-soluk si-not">
                Kaynak: kesin alış faturası / fişi / gider pusulası satırlarının masraf kalemi (hizmet / masraf satırı; stoklu mal alımı gider değildir — stoğa girer)
                + kasa / banka işleminin masraf bacağı (v_masraf_ekstre) + onaylı personel masraf beyanı{veri.amortismanDahil ? ' + demirbaş amortismanı (gün oranıyla, nakit çıkışı yok)' : ''}.
                Aynı gider iki yoldan gelmez: faturası olan ödemenin kendisi gider sayılmaz (fatura sayılır). Maaş gibi bordrosuz giderler ödeme tarihine göre
                girer (<span className="bo-rz pas">ödeme esaslı</span>). Gruplama kalem ağacına göre (masraf kartının üst kalemi); muhasebe kodu bilgi içindir.
                ⚠ artış: son 3 tam ay ortalaması önceki 6 ayın %{veri.esik.artisYuzde.toLocaleString('tr-TR')} üstü.
              </div>
            </>}

            {sekme === 'mrk' && <>
              <Kutucuk baslik="Masraf merkezi × üst kalem" not="hücreye tıkla: belge detayı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Masraf merkezi</th>{veri.merkezMatris.kolonlar.map(k => <th key={k.id} className="sag">{k.ad}</th>)}
                      <th className="sag">Toplam</th><th className="sag">Pay</th></tr></thead>
                    <tbody>
                      {veri.merkezMatris.satirlar.length === 0 && <tr><td colSpan={veri.merkezMatris.kolonlar.length + 3} className="bos">Bu dönemde gider yok.</td></tr>}
                      {veri.merkezMatris.satirlar.map(m => (
                        <tr key={m.id}>
                          <td className={'ac' + (m.id === -1 ? ' ki-soluk' : '')} onClick={() => detayaGit({ dmerkez: m.id })}>{m.ad}</td>
                          {m.hucreler.map((h, i) => {
                            const kolon = veri.merkezMatris.kolonlar[i];
                            return (
                              <td key={kolon?.id ?? i} className={'sag' + (h ? ' ac' : ' ki-soluk')}
                                onClick={() => h && detayaGit(kolon && kolon.id !== DIGER_KOLON ? { dmerkez: m.id, ust: kolon.id } : { dmerkez: m.id })}>
                                {h ? tl(h) : '—'}</td>
                            );
                          })}
                          <td className="sag"><b>{tl(m.toplam)}</b></td><td className="sag">%{m.pay.toLocaleString('tr-TR')}</td>
                        </tr>
                      ))}
                      <tr className="top"><td>Toplam</td>{veri.merkezMatris.toplam.hucreler.map((h, i) => <td key={i} className="sag">{tl(h)}</td>)}
                        <td className="sag">{tl(veri.merkezMatris.toplam.toplam)}</td><td className="sag">%100</td></tr>
                    </tbody>
                  </table>
                </div>
              </Kutucuk>
              <div className="ki-soluk si-not">Masraf merkezi belge satırından; yoksa belgenin başlığından; o da yoksa "(merkez atanmamış)" — tahmin edilip
                dağıtılmaz. Kasa masraf bacağı işlemin merkezini taşır; masraf beyanı ve amortisman merkezsizdir. "Diğer": ilk altı üst kalemin dışındakiler.</div>
            </>}

            {sekme === 'trd' && (
              <Kutucuk baslik={`Aylık gider — bu yıl ve geçen yıl${veri.planKiyas ? ' · plan' : ''}`} not="çubuk: bu yılın gideri">
                <table className="hi-tablo">
                  <thead><tr><th>Ay</th><th className="sag">Bu yıl</th><th className="sag">Geçen yıl</th><th className="orta">Fark</th>
                    {veri.planKiyas && <><th className="sag">Plan</th><th className="sag">Planlı kalemlerin gerçeği</th><th className="sag">Gerçek − plan</th></>}
                    <th style={{ width: 200 }} /></tr></thead>
                  <tbody>
                    {veri.trend.map(a => (
                      <tr key={a.ay}><td>{a.kismiGun ? <b>{ayAdi(a.ay)} ({a.kismiGun}'i)</b> : ayAdi(a.ay)}</td>
                        <td className="sag">{tl(a.tutar)}</td><td className="sag">{tl(a.gecenYil)}</td>
                        <td className="orta"><DegisimRozeti d={a.degisim ?? null} ters /></td>
                        {veri.planKiyas && <>
                          <td className="sag">{a.plan == null ? '—' : tl(a.plan)}</td>
                          <td className="sag">{a.planGercek == null ? '—' : tl(a.planGercek)}</td>
                          <td className={'sag' + (a.planFark != null && a.planFark > 0.005 ? ' kir' : '')}>{a.planFark == null ? '—' : farkMetni(a.planFark)}</td>
                        </>}
                        <td><Cubuk yuzde={a.cubuk} /></td></tr>
                    ))}
                  </tbody>
                </table>
                <div className="ki-soluk si-not" style={{ padding: '0 10px' }}>Ay içindeki gider belge / işlem / harcama tarihine göre. İçinde bulunulan ay yarım;
                  plan da bitiş gününe kadar olan dönemlerden. Geçen yıl: {tarihT(veri.gecenYil.bas)} – {tarihT(veri.gecenYil.bit)}. Plan yalnız planlı gider tanımı olan
                  kalemleri kapsar; onların gerçeğiyle kıyaslanır.</div>
              </Kutucuk>
            )}

            {sekme === 'pln' && (veri.planKiyas ? <>
              <Kutucuk baslik="Planlı gider − gerçekleşen (Planlı Giderler ile eşleşen dönemler)" not="satıra tıkla: belge detayı · tanıma tıkla: planlı gider kartı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Planlı gider</th><th>Kalem</th><th className="sag">Plan</th><th className="sag">Gerçek</th><th className="sag">Fark</th>
                      <th className="sag">Fark %</th><th className="orta">Dönem</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.plan.satirlar.length === 0 && <tr><td colSpan={8} className="bos">Bu dönemde masraf kalemi tanımlı planlı gider yok.</td></tr>}
                      {veri.plan.satirlar.map(p => (
                        <tr key={p.masrafId} className="ac" onClick={() => detayaGit({ alt: p.masrafId })}>
                          <td>{p.tanimlar.map((t, i) => (
                            <Fragment key={t.id}>{i > 0 && ' · '}
                              <span className="lnk" onClick={e => { e.stopPropagation(); kartAc(`/planli-gider/${t.id}`) }}>{t.ad}</span></Fragment>))}</td>
                          <td>{p.kod ? `${p.kod} ` : ''}{p.kalem}</td>
                          <td className="sag">{tl(p.plan)}</td><td className="sag">{tl(p.gercek)}</td>
                          <td className={'sag' + (p.fark > 0.005 ? ' kir' : '')}>{farkMetni(p.fark)}</td>
                          <td className="sag">{yuzde(p.farkYuzde ?? null, true)}</td>
                          <td className="orta">{p.eslesen} / {p.donem}</td>
                          <td><span className={'bo-rz ' + PLAN_SINIF[p.durum]}>{p.durumAdi}</span></td></tr>
                      ))}
                      <tr className="top"><td colSpan={2}>Toplam ({veri.plan.toplam.tanim} tanım)</td><td className="sag">{tl(veri.plan.toplam.plan)}</td>
                        <td className="sag">{tl(veri.plan.toplam.gercek)}</td><td className="sag">{farkMetni(veri.plan.toplam.fark)}</td>
                        <td className="sag">{yuzde(veri.plan.toplam.farkYuzde ?? null, true)}</td><td colSpan={2} /></tr>
                    </tbody>
                  </table>
                </div>
              </Kutucuk>
              <div className="ki-soluk si-not">Plan = Planlı Giderler'in dönem planı (dondurulmuş ya da kuralla hesaplanan, {kdvDahil ? 'KDV dahil' : 'KDV hariç'}), plan tarihi
                dönemde olanlar; atlanan dönem sayılmaz. Gerçek = aynı masraf kalemindeki gider. Dönem: eşleşen / planlanan. Tanımı olmayan kalemler bu tabloda
                yok, Kalem sekmesinde var.</div>
            </> : <div className="ki-soluk si-not">Şeritteki "Planlı giderle kıyasla" kapalı.</div>)}

            {sekme === 'ted' && <>
              <Kutucuk baslik={`Tedarikçiye göre gider${tumTedarikci ? '' : ' (ilk 10)'}`} not="satıra tıkla: belge detayı">
                <table className="hi-tablo">
                  <thead><tr><th>Tedarikçi</th><th>Ana kalem</th><th className="sag">Gider</th><th className="sag">Belge</th><th className="sag">{karsiAdi}</th>
                    <th className="orta">Fark</th><th className="sag">Pay</th></tr></thead>
                  <tbody>
                    {veri.tedarikciler.length === 0 && <tr><td colSpan={7} className="bos">Bu dönemde carili gider yok.</td></tr>}
                    {(tumTedarikci ? veri.tedarikciler : veri.tedarikciler.slice(0, 10)).map(t => (
                      <tr key={t.id} className="ac" onClick={() => detayaGit({ tedarikci: t.id })}>
                        <td>{t.ad}</td><td>{t.anaKalem}</td><td className="sag"><b>{tl(t.tutar)}</b></td><td className="sag">{t.belge}</td>
                        <td className="sag">{t.karsi == null ? <span className="ki-soluk">yeni</span> : tl(t.karsi)}</td>
                        <td className="orta"><DegisimRozeti d={t.degisim ?? null} yeni={t.karsi == null} ters /></td>
                        <td className="sag">%{t.pay.toLocaleString('tr-TR')}</td></tr>
                    ))}
                    {!tumTedarikci && veri.tedarikciler.length > 10 && (
                      <tr><td colSpan={7} className="bos"><span className="lnk" onClick={() => setTumTedarikci(true)}>… {veri.tedarikciler.length - 10} tedarikçi daha</span></td></tr>)}
                  </tbody>
                </table>
              </Kutucuk>
              <div className="ki-soluk si-not">Personel, SGK, vergi gibi carisiz giderler (kasa masraf bacağı, masraf beyanı, amortisman) bu tabloda yok — Kalem sekmesinde.</div>
            </>}

            {sekme === 'det' && <>
              <Kutucuk baslik={`Belge detayı — ${detay?.baslik ?? '…'}`}
                not={`satıra tıkla: seç · çift tık: belge${veri.yetkiler.ata ? ' · kutu: kalem atamak için seç' : ''}`}>
                <div className="hi-serit" style={{ border: 0 }}>
                  {Object.keys(dSuz).length > 0 && <span className="lnk" onClick={() => setDSuz({})}>✖ süzgeci kaldır (bütün giderler)</span>}
                  <span className="lnk" onClick={() => setDSuz({ ust: KALEM_ATANMAMIS })}>yalnız kalem atanmamış</span>
                  {veri.yetkiler.ata && detay && atanabilirSatirlar.length > 0 && (
                    <span className="lnk" onClick={() => setSecili(s => s.size >= atanabilirSatirlar.length ? new Set<string>() : new Set<string>(atanabilirSatirlar.map(anahtar)))}>
                      {secili.size >= atanabilirSatirlar.length ? 'seçimi kaldır' : `atanabilir ${atanabilirSatirlar.length} satırı seç`}</span>)}
                  {secili.size > 0 && <span className="bo-rz mavi">{secili.size} satır seçili</span>}
                  <span className="sp" />
                  {detayYuk && <span className="ki-soluk">yükleniyor…</span>}
                  <span className="ki-soluk">{kapanmisMetin}</span>
                </div>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr>{veri.yetkiler.ata && <th />}<th>Tarih</th><th>Belge</th><th>Kaynak</th><th>Tedarikçi</th><th>Açıklama</th><th>Kalem</th>
                      <th>Merkez</th><th className="sag">KDV hariç</th><th className="sag">KDV</th></tr></thead>
                    <tbody>
                      {detay && detay.satirlar.length === 0 && <tr><td colSpan={10} className="bos">Bu süzgeçte gider satırı yok.</td></tr>}
                      {(detay?.satirlar ?? []).map(s => {
                        const k = anahtar(s);
                        return (
                          <tr key={k} className={'ac' + (secSatir && anahtar(secSatir) === k ? ' ti-sec' : '')}
                            onClick={() => setSecSatir(s)} onDoubleClick={() => belgeAc(s)}>
                            {veri.yetkiler.ata && <td onClick={e => e.stopPropagation()}>
                              <input type="checkbox" disabled={!!s.atamaEngeli} checked={secili.has(k)} onChange={() => secCevir(k)}
                                title={s.atamaEngeli || 'Kalem atamak için seç'} /></td>}
                            <td>{tarihT(s.tarih)}</td>
                            <td>{s.kaynak === 'amortisman' ? s.no : <span className="lnk" onClick={e => { e.stopPropagation(); belgeAc(s) }}>{s.no}</span>}
                              {s.taslak && <span className="bo-rz sari" style={{ marginLeft: 4 }}>taslak</span>}</td>
                            <td>{s.kaynakAdi}{s.kaynak === 'kasa' && <span className="bo-rz pas" style={{ marginLeft: 4 }}>ödeme esaslı</span>}
                              {s.atamaEngeli.startsWith('Kapanmış') && <span className="bo-rz pas" style={{ marginLeft: 4 }} title={s.atamaEngeli}>kapanmış dönem</span>}</td>
                            <td className={s.taraf ? '' : 'ki-soluk'}>{s.taraf || '—'}</td>
                            <td className="ma-ack">{s.aciklama}</td>
                            <td className={s.kalemId === KALEM_ATANMAMIS ? 'kir' : ''}>{s.kalemId === KALEM_ATANMAMIS ? '(atanmamış)' : `${s.kalemKod ? s.kalemKod + ' ' : ''}${s.kalem}`}</td>
                            <td className={s.merkezId ? '' : 'ki-soluk'}>{s.merkez}</td>
                            <td className={'sag' + (s.iade ? ' kir' : '')}>{tl(s.haric)}</td><td className="sag">{tl(s.kdv)}</td>
                          </tr>
                        );
                      })}
                      {detay && detay.sayi > detay.satirlar.length && <tr><td colSpan={10} className="bos">… {detay.sayi - detay.satirlar.length} satır daha (süzgeçle daraltın)</td></tr>}
                      {detay && <tr className="top"><td colSpan={veri.yetkiler.ata ? 8 : 7}>Toplam ({detay.sayi} satır)</td>
                        <td className="sag">{tl(detay.toplam.haric)}</td><td className="sag">{tl(detay.toplam.kdv)}</td></tr>}
                    </tbody>
                  </table>
                </div>
              </Kutucuk>
              <div className="ki-soluk si-not">Kalem ya da merkez sekmesinde bir satıra tıklayınca buraya süzülür; belgeye çift tık. Kalem ataması belge satırına
                (masraf satırı olur) ve kasa işleminin masraf bacağına yazılır; masraf beyanı kendi kartında, amortisman demirbaşta düzeltilir. Hizmet kartına
                bağlı satır, Delphi'den gelen kayıt, kapanmış muhasebe dönemi ve kapalı kasa günü atanamaz (kutusu pasif, gerekçesi üzerinde).
                {!veri.yetkiler.ata && ' Kalem atamak için belge değiştirme yetkisi gerekir.'}</div>
            </>}

            {sekme === 'dkt' && <>
              <Kutucuk baslik="Dikkat" not="satıra tıkla: ilgili satırlar">
                <table className="hi-tablo">
                  <thead><tr><th>Tür</th><th>Belge / kayıt</th><th>Tarih</th><th>Açıklama</th><th>Öneri</th></tr></thead>
                  <tbody>
                    {veri.dikkat.length === 0 && <tr><td colSpan={5} className="bos">Dikkat gerektiren bir şey yok.</td></tr>}
                    {veri.dikkat.map((d, i) => (
                      <tr key={i} className="ac" onClick={() => {
                        if (d.tur === 'atanmamis') detayaGit({ ust: KALEM_ATANMAMIS });
                        else if (d.tur === 'artis') detayaGit({ ust: d.kalemId });
                        else if (d.tur === 'kdv' || d.tur === 'plansiz') detayaGit({ alt: d.kalemId });
                      }}>
                        <td><span className={'bo-rz ' + DIKKAT_SINIF[d.tur]}>{d.turAdi}</span></td>
                        <td>{d.belgeler.length > 0
                          ? d.belgeler.map((b, j) => <Fragment key={b.id}>{j > 0 && ' / '}
                            <span className="lnk" onClick={e => { e.stopPropagation(); kartAc(`/belge/${b.id}`) }}>{b.no}</span></Fragment>)
                          : d.kayit}</td>
                        <td>{d.tarih ? (d.tarih.length === 10 ? tarihT(d.tarih) : d.tarih) : '—'}</td>
                        <td className="ma-ack">{d.aciklama}</td>
                        <td>{d.tur === 'atanmamis' && veri.yetkiler.ata
                          ? <span className="lnk" onClick={e => { e.stopPropagation(); detayaGit({ ust: KALEM_ATANMAMIS }) }}>{d.oneri}</span>
                          : d.tur === 'plansiz'
                            ? <span className="lnk" onClick={e => { e.stopPropagation(); git('/planli-gider') }}>{d.oneri}</span>
                            : d.oneri}</td></tr>
                    ))}
                  </tbody>
                </table>
              </Kutucuk>
              <div className="ki-soluk si-not">Eşikler (Genel Ayarlar › İcmal Eşikleri): olağan dışı artış = son 3 tam ay ortalaması önceki 6 ayın
                %{veri.esik.artisYuzde.toLocaleString('tr-TR')} üstü; mükerrer = aynı cari + aynı belge tutarı ± {veri.esik.mukerrerGun} gün. KDV oranı farklı: aynı kalem
                ve carinin son belgesindeki oran öncekilerin en sık oranından farklı. Planda yok: en az 3 ayda tekrarlayan, planlı gider tanımı olmayan kalem.</div>
            </>}

            {sekme === 'onz' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.satir.toLocaleString('tr-TR')} gider satırı</span><span>{o.kalem} masraf kalemi</span><span>{o.merkez} masraf merkezi</span>
          {o.amortisman.dahil && o.amortisman.tutar !== 0 && <span>amortisman {tl(o.amortisman.tutar)} ₺ (nakit çıkışı yok)</span>}
          <span>Karşılaştırma: {karsiAdi.toLocaleLowerCase('tr')} ({tarihT(veri.karsi.bas)} – {tarihT(veri.karsi.bit)})</span>
          <span className="sp" /><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

function MasrafA4({ v, antet, duzenleyen, sube, merkez, kip, karsiAdi }: {
  v: Veri; antet: Record<string, unknown> | null; duzenleyen: string; sube: string; merkez: string; kip: string; karsiAdi: string;
}) {
  const o = v.ozet;
  const ilk = v.kalemler.slice(0, 14);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>MASRAF İCMALİ</h3>
      <div className="a4-hasta">
        <span>Dönem: <b>{tarihT(v.bas)} – {tarihT(v.bit)}</b></span><span>{kip}</span>
        <span>Şube: {sube}</span><span>Masraf merkezi: {merkez}</span>
      </div>
      <table className="a4-t ti-a4t">
        <thead><tr><th>Kalem</th><th>Bu dönem</th><th>{karsiAdi}</th><th>Fark</th><th>Pay</th></tr></thead>
        <tbody>
          {ilk.map(k => <tr key={k.id}><td>{k.ad}{k.nakitDisi ? ' (nakit çıkışı yok)' : ''}</td><td>{tl(k.tutar)}</td><td>{tl(k.karsi)}</td>
            <td>{yuzde(k.degisim ?? null, true)}</td><td>%{k.pay.toLocaleString('tr-TR')}</td></tr>)}
          {v.kalemler.length > ilk.length && <tr><td colSpan={5}>… {v.kalemler.length - ilk.length} kalem daha</td></tr>}
        </tbody>
      </table>
      <div className="ti-dip">
        <div className="b"><span>Toplam gider</span><span>{tl(o.toplam)}</span></div>
        {v.planKiyas && o.planTanim > 0 && <>
          <div><span>Planlı gider (tanımlı kalemler)</span><span>{tl(o.plan)}</span></div>
          <div><span>Plan − gerçek</span><span>{farkMetni(o.planFark)}</span></div>
        </>}
        <div className="b"><span>GİDER / CİRO</span><span>{o.giderCiro == null ? '—' : `%${o.giderCiro.toLocaleString('tr-TR')}`}</span></div>
      </div>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Genel Müdür<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Masraf İcmali · {kip}
        {o.atanmamis.satir > 0 && ` · kalem atanmamış ${tl(o.atanmamis.tutar)} ₺ "Diğer" satırında`}
        {o.amortisman.dahil && o.amortisman.tutar !== 0 && ` · amortisman ${tl(o.amortisman.tutar)} ₺ nakit çıkışı değildir`}</p>
    </div>
  );
}

const MASRAF_STILI = `
.hi-tablo tr.si-alt td { background:#f9fbfd; font-size:11.5px; color:#3a4c5e; }
.hi-tablo td.ma-ack { white-space:normal; max-width:320px; }
.hi-serit .bo-rz.ac { cursor:pointer; }
`;

export default MasrafIcmali;
