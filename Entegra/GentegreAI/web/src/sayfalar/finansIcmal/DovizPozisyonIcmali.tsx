import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import {
  dovizPozisyonUclari, type DovizPozisyonu as Veri, type DovizTutar, type KurFarkiDurumu, type KurFarkiSatiri,
} from '../../api/uclar/dovizPozisyon';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { onay } from '../../bilesenler/mesaj';
import { Modal } from '../../bilesenler/Modal';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { EkranA4, TICARI_ICMAL_STILI } from '../ticariIcmal/ticariIcmalOrtak';
import { FINANS_ICMAL_STILI, useCariKarti, useKartAc } from './finansIcmalOrtak';

/**
 * DÖVİZ POZİSYONU / KUR FARKI İCMALİ `/doviz-pozisyon` - mockup Ekranlar/İcmal/doviz_pozisyon_icmali.html (1186, kararlar
 * 25.10.2026). "Dövizde ne kadar açığız, kur artarsa ne kaybederiz, bu ay kur farkından ne kazandık, kime kur farkı faturası
 * kesmeliyiz?" Pozisyon, FIFO kur farkı, değerleme ve duyarlılık SUNUCUDA (DovizPozisyonUclari); ekran yalnız gösterir.
 * Kur farkı faturası OTOMATİK KESİLMEZ: öneri listelenir, `finans.kur_farki` yetkilisi "kesildi / gerek yok" işaretler (loglu).
 */
type Sekme = 'poz' | 'cari' | 'krf' | 'fat' | 'vade' | 'dur' | 'kur' | 'a4';

const DURUM_ROZET: Record<KurFarkiDurumu, [string, string]> = {
  oneri: ['sari', 'kesilmedi'], aleyhte: ['pas', 'aleyhte · alacak dekontu'], kesildi: ['ok', 'kesildi'], gerekYok: ['pas', 'gerek yok'],
};
const KUR_TURLERI: [string, string][] = [['alis', 'TCMB döviz alış'], ['efektif', 'TCMB efektif alış'], ['satis', 'TCMB döviz satış']];

const isaretli = (n: number | null | undefined) => (n == null ? '—' : (n > 0 ? '+' : n < 0 ? '−' : '') + tl(Math.abs(n)));
const dv = (n: number | null | undefined) => (n == null || Math.abs(n) < 0.005 ? '—' : isaretli(n));
const kurT = (n: number | null | undefined) => (n == null ? '—' : n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 4 }));
const renk = (n: number | null | undefined) => (n == null || Math.abs(n) < 0.005 ? 'ki-soluk' : n > 0 ? 'si-yesil' : 'kir');

export function DovizPozisyonIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici, yetki } = useOturum();
  const antet = useAntet();
  const cariKarti = useCariKarti();
  const kartAc = useKartAc();
  const tarih = arama.get('tarih') ?? '';
  const donem = arama.get('donem') ?? '';
  const kur = arama.get('kur') ?? '';
  const sube = Number(arama.get('sube') ?? 0);
  const siparisDahil = arama.get('siparis') === '1';
  const cekHaric = arama.get('cek') === '0';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [bilgi, setBilgi] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [surum, setSurum] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('poz');
  const [secDoviz, setSecDoviz] = useState('');
  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<KurFarkiSatiri | null>(null);
  const [isaret, setIsaret] = useState<{ s: KurFarkiSatiri; durum: 1 | 2 } | null>(null);

  useEffect(() => {
    let iptal = false;
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams();
    if (tarih) q.set('tarih', tarih);
    if (donem) q.set('donem', donem);
    if (kur) q.set('kur', kur);
    if (sube) q.set('sube', String(sube));
    if (siparisDahil) q.set('siparis', '1');
    if (cekHaric) q.set('cek', '0');
    dovizPozisyonUclari.dovizPozisyonu(q)
      .then(v => { if (!iptal) setVeri(v) })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) })
      .finally(() => { if (!iptal) setYukleniyor(false) });
    return () => { iptal = true };
  }, [tarih, donem, kur, sube, siparisDahil, cekHaric, surum]);

  const dovizler = useMemo(() => (veri?.dovizler ?? []).filter(d => !secDoviz || d === secDoviz), [veri, secDoviz]);
  const cariler = useMemo(() => {
    const q = ara.trim().toLocaleLowerCase('tr');
    return (veri?.cariler ?? []).filter(c => (!secDoviz || c.doviz === secDoviz)
      && (!q || c.ad.toLocaleLowerCase('tr').includes(q) || c.kod.toLocaleLowerCase('tr').includes(q)));
  }, [veri, secDoviz, ara]);
  const faturalar = useMemo(() => (veri?.faturalar ?? []).filter(f => !secDoviz || f.doviz === secDoviz), [veri, secDoviz]);
  const o = veri?.ozet;
  const yetkili = !!veri?.yetkiler.kurFarki;
  const tazele = (metin: string) => { setBilgi(metin); setIsaret(null); setSecili(null); setSurum(s => s + 1) };
  const ad = (id: number, metin: string, tedarikci = false) =>
    <span className="lnk" onClick={e => { e.stopPropagation(); cariKarti(id, tedarikci) }}>{metin}</span>;
  const ekstreAc = (id: number) => { if (id) git(`/ekstre?tur=cari&id=${id}`) };
  const kurAdi = (d: string) => veri?.kurlar.find(k => k.doviz === d);
  const geriAl = async (f: KurFarkiSatiri) => {
    if (!f.takipId || !await onay(`${f.cari} · ${f.belgeNo}: kur farkı işareti ("${DURUM_ROZET[f.durum][1]}") geri alınsın mı?`)) return;
    try { await dovizPozisyonUclari.kurFarkiGeriAl(f.takipId); tazele('İşaret geri alındı.') } catch (h) { setHata(hataMetni(h)) }
  };
  const a4 = veri && <DovizA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + FINANS_ICMAL_STILI + TICARI_ICMAL_STILI + DP_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Döviz Pozisyonu / Kur Farkı İcmali</h1><span className="yol">Finans › İcmaller › Döviz Pozisyonu / Kur Farkı İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Döviz İcmali" dosyaAdi={`Döviz Pozisyonu ${veri?.tarih?.slice(0, 10) ?? ''}`} devre={!veri}>{a4}</CiktiMenusu>
        <span className="sepv" />
        <button disabled={!secili || secili.durum !== 'oneri'}
          onClick={() => secili && git(`/belge/yeni?tur=15&tarafId=${secili.tarafId}&tarafUnvan=${encodeURIComponent(secili.cari)}`)}
          title="Seçili satırın carisine yeni satış faturası (kur farkı satırını siz eklersiniz)">🧾 Kur farkı faturası aç</button>
        <button disabled={!secili} onClick={() => secili && ekstreAc(secili.tarafId)}>📒 Cari ekstresi</button>
        <span className="sp" />
        {yetki('finans.cari_icmali') && <button onClick={() => git('/cari-icmali')}>📊 Cari İcmali</button>}
        {yetki('finans.nakit_akis_icmali') && <button onClick={() => git('/nakit-akis-icmali')}>🌊 Nakit Akış İcmali</button>}
        {yetki('finans.banka_mutabakat') && <button onClick={() => git('/banka-mutabakat')}>🏦 Banka Mutabakat</button>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu" onClick={() => setBilgi('')}>{bilgi}</div>}

      <div className="hi-serit">
        <div className="sel">📅 Tarih:
          <input type="date" value={tarih || (veri?.tarih?.slice(0, 10) ?? '')} onChange={e => degistir({ tarih: e.target.value })} /></div>
        <div className="sel">🗓 Kur farkı dönemi:
          <input type="month" value={donem || (veri?.donem ?? '')} onChange={e => degistir({ donem: e.target.value })} /></div>
        <div className="sel">💱 Değerleme kuru:
          <select value={kur || veri?.kurTuru || 'alis'} onChange={e => degistir({ kur: e.target.value })}>
            {KUR_TURLERI.map(([k, a]) => <option key={k} value={k}>{a}</option>)}
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="si-seg">
          <button className={!secDoviz ? 'on' : ''} onClick={() => setSecDoviz('')}>Tüm dövizler</button>
          {(veri?.dovizler ?? []).map(d => <button key={d} className={secDoviz === d ? 'on' : ''} onClick={() => setSecDoviz(d)}>{d}</button>)}
        </div>
        <label className="fi-chk"><input type="checkbox" checked={siparisDahil} onChange={e => degistir({ siparis: e.target.checked ? '1' : '' })} /> Açık siparişleri pozisyona dahil et</label>
        <label className="fi-chk"><input type="checkbox" checked={!cekHaric} onChange={e => degistir({ cek: e.target.checked ? '' : '0' })} /> Portföy çekleri dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {veri && <span className="bo-rz mavi" title="Değerleme kuru (Genel Ayarlar › finans.degerleme_kuru)">Kurlar: {tarihT(veri.tarih)} · {veri.kurAdi}</span>}
        {o && o.kurEski > 0 && <span className="bo-rz sari" title="Bu dövizlerin o güne ait kuru yok; son kur kullanıldı">Eski kur: {o.kurEski}</span>}
        {o && o.kurYok > 0 && <span className="bo-rz kir" title="Kuru hiç yok - TL karşılığı kayıtlı tutardan">Kuru olmayan döviz: {o.kurYok}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Net Döviz Pozisyonu" deg={`${isaretli(o.netTl)} ₺`}
            alt={veri.dovizler.filter(d => Math.abs(o.net[d] ?? 0) >= 0.005).map(d => `${isaretli(o.net[d])} ${d}`).join(' · ') || 'pozisyon yok'}
            sinif={o.netTl < 0 ? 'teh' : 'mor'} />
          <Kutu bas="Döviz Varlıkları" deg={`${tl(o.varlikTl)} ₺`} alt={`kasa + banka + alacak${veri.cekDahil ? ' + çek' : ''}`} />
          <Kutu bas="Döviz Yükümlülükleri" deg={`${tl(-o.yukumlulukTl)} ₺`} alt="tedarikçi borcu + kredi" />
          <Kutu bas="Kur %10 Artarsa" deg={`${isaretli(o.artis10)} ₺`} alt={o.artis10 < 0 ? 'net açık pozisyon zararı' : 'net fazla pozisyon kârı'}
            sinif={o.artis10 < 0 ? 'teh' : 'iyi'} />
          <Kutu bas="Gerçekleşen Kur Farkı" deg={`${isaretli(o.gerceklesen)} ₺`} alt={`${veri.donem} · kapanan işlemler`} sinif={o.gerceklesen < 0 ? 'teh' : 'iyi'} />
          <Kutu bas="Değerleme Farkı" deg={`${isaretli(o.degerleme)} ₺`} alt="açık bakiyeler · bugünkü kur (bilgi)" sinif="uy" />
          <Kutu bas="Kesilecek Kur Farkı Faturası" deg={`${o.faturaAdet} cari`} alt={`alacak lehine ${tl(o.faturaTutar)} ₺`} />
          <Kutu bas="Ort. Vade (döviz borç)" deg={o.ortVadeGun != null ? `${o.ortVadeGun} gün` : '—'}
            alt={o.enYakinBorc ? `en yakın ${tarihT(o.enYakinBorc.tarih)} · ${tl(o.enYakinBorc.tutar)} ${o.enYakinBorc.doviz}` : 'açık döviz borç yok'} />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['poz', 'Pozisyon', null], ['cari', 'Cari Bazında', null], ['krf', 'Kur Farkı', null],
              ['fat', 'Kur Farkı Faturası', faturalar.filter(f => f.durum === 'oneri').length || null], ['vade', 'Döviz Vade Takvimi', null],
              ['dur', 'Kur Duyarlılığı', null], ['kur', 'Kur Geçmişi', null], ['a4', '🖨 Önizleme (A4)', null]]} />

            {sekme === 'poz' && (
              <Kutucuk baslik="Döviz bazında pozisyon" not="varlık − yükümlülük · TL karşılığı değerleme kuruyla">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Kalem</th>{dovizler.map(d => <th key={d} className="sag">{d}</th>)}<th className="sag">TL karşılığı</th></tr></thead>
                    <tbody>
                      {veri.pozisyon.satirlar.filter(s => s.varlik).map(s => <PozSatir key={s.anahtar} s={s} dovizler={dovizler} />)}
                      <tr className="si-grup"><td><b>Varlık toplamı</b></td>{dovizler.map(d => <td key={d} className="sag"><b>{dv(veri.pozisyon.varlik[d])}</b></td>)}
                        <td className="sag"><b>{tl(veri.pozisyon.varlikTl)}</b></td></tr>
                      {veri.pozisyon.satirlar.filter(s => !s.varlik).map(s => <PozSatir key={s.anahtar} s={s} dovizler={dovizler} />)}
                      <tr className="top"><td>NET POZİSYON</td>
                        {dovizler.map(d => <td key={d} className={'sag ' + renk(veri.pozisyon.net[d])}>{dv(veri.pozisyon.net[d])}</td>)}
                        <td className={'sag ' + renk(veri.pozisyon.netTl)}>{isaretli(veri.pozisyon.netTl)}</td></tr>
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Kasa / banka hesap ekstresiyle aynı küme, hareketin kendi dövizinde. Dövizli cari = hareketi kendi dövizinde tutulan
                  cari (Cari Ekstre'nin döviz sütunu); TL carinin dövizli faturası TL alacaktır, pozisyona girmez. Portföy çek = alınan, vadesi gelmemiş
                  döviz çek / senet. Açık sipariş (gelecek alacak / borç) şeritten açılır. TL karşılığı {veri.kurAdi} ile; kuru olmayan döviz kayıtlı TL ile.</div>
              </Kutucuk>
            )}

            {sekme === 'cari' && <>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <input placeholder="🔍 Cari adı ya da kodu…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 260 }} />
                <span className="ki-soluk">çift tık: ekstre · ada tıkla: cari kartı</span>
              </div>
              <Kutucuk baslik="Cari bazında dövizli bakiye" not="işlem kuru ile bugünkü kur arasındaki değerleme farkı">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Cari</th><th>Döviz</th><th className="sag">Bakiye (döviz)</th><th className="sag">Ort. işlem kuru</th>
                      <th className="sag">Bugünkü kur</th><th className="sag">Kayıtlı TL</th><th className="sag">Bugünkü TL</th><th className="sag">Değerleme farkı</th></tr></thead>
                    <tbody>
                      {cariler.length === 0 && <tr><td colSpan={8} className="bos">Dövizli bakiyesi olan cari yok.</td></tr>}
                      {cariler.slice(0, 1000).map(c => (
                        <tr key={`${c.tarafId}-${c.doviz}`} className="ac" onDoubleClick={() => ekstreAc(c.tarafId)}>
                          <td>{ad(c.tarafId, c.ad, c.tedarikci && !c.musteri)}
                            <span className="ki-soluk dp-rz">{c.bakiye > 0 ? 'alacak' : 'borç'}</span></td>
                          <td>{c.doviz}</td>
                          <td className={'sag' + (c.bakiye < 0 ? ' kir' : '')}>{isaretli(c.bakiye)}</td>
                          <td className="sag">{kurT(c.ortKur)}</td><td className="sag">{kurT(c.bugunKur)}</td>
                          <td className="sag">{isaretli(c.kayitliTl)}</td><td className="sag">{c.bugunTl == null ? '—' : isaretli(c.bugunTl)}</td>
                          <td className={'sag ' + renk(c.fark)}>{dv(c.fark)}</td>
                        </tr>))}
                      {cariler.length > 0 && <tr className="top"><td colSpan={7}>Toplam ({cariler.length} satır)</td>
                        <td className={'sag ' + renk(cariler.reduce((t, c) => t + (c.fark ?? 0), 0))}>{dv(cariler.reduce((t, c) => t + (c.fark ?? 0), 0))}</td></tr>}
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Ortalama işlem kuru: açık bakiyeyi oluşturan kalemlerin (FIFO kapama sonrası kalanların, Cari İcmali kuralı)
                  ağırlıklı kuru. Değerleme farkı yalnız bilgidir, kayda geçmez.</div>
              </Kutucuk>
            </>}

            {sekme === 'krf' && (
              <Kutucuk baslik={`Kur farkı — ${veri.donem}`} not="gerçekleşen: kapanan işlemler · değerleme: açık bakiyeler (bilgi)">
                <table className="hi-tablo">
                  <thead><tr><th>Kaynak</th><th className="sag">Kur farkı geliri</th><th className="sag">Kur farkı gideri</th>
                    <th className="sag">Net</th><th className="sag">Adet</th><th>Not</th></tr></thead>
                  <tbody>
                    {veri.kurFarki.satirlar.map(s => (
                      <tr key={s.kaynak}><td>{s.kaynak}</td><td className="sag">{dv(s.gelir)}</td><td className="sag">{dv(s.gider)}</td>
                        <td className={'sag ' + renk(s.net)}>{dv(s.net)}</td><td className="sag">{s.adet}</td><td className="ki-soluk">{s.not}</td></tr>))}
                    <tr className="top"><td>Gerçekleşen net</td><td colSpan={2} />
                      <td className={'sag ' + renk(veri.kurFarki.gerceklesen)}>{isaretli(veri.kurFarki.gerceklesen)}</td><td colSpan={2} /></tr>
                  </tbody>
                </table>
                <div className="fi-ipucu">Gerçekleşen kur farkı: dövizli fatura ile onu kapatan tahsilat / ödeme arasındaki kur değişimi × kapanan döviz tutar
                  (Cari İcmali FIFO kapama kuralı: aynı cari ve döviz içinde vade sırasıyla). Kalemin kuru = kayıtlı TL / döviz tutar.
                  Dönem: {tarihT(veri.donemBas)} – {tarihT(veri.donemBit)}.</div>
              </Kutucuk>
            )}

            {sekme === 'fat' && (
              <Kutucuk baslik="Kesilmesi gereken kur farkı faturaları" not="satış faturasını kapatan tahsilatta kur farkı · otomatik kesilmez">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Cari</th><th>Kapanan fatura</th><th>Kapama</th><th className="sag">Döviz</th><th className="sag">Fatura kuru</th>
                      <th className="sag">Kapama kuru</th><th className="sag">Kur farkı</th><th>Durum</th>{yetkili && <th />}</tr></thead>
                    <tbody>
                      {faturalar.length === 0 && <tr><td colSpan={yetkili ? 9 : 8} className="bos">Bu dönemde kur farkı doğan tahsilat yok.</td></tr>}
                      {faturalar.map(f => (
                        <tr key={`${f.belgeId}-${f.kapamaAnahtar}`} className={'ac' + (secili === f ? ' fi-sec' : '')} onClick={() => setSecili(f)}
                          onDoubleClick={() => kartAc(`/belge/${f.belgeId}`)}>
                          <td>{ad(f.tarafId, f.cari)}</td>
                          <td>{f.belgeNo} <span className="ki-soluk">{tarihT(f.belgeTarihi)}</span></td>
                          <td>{f.kapamaTur || f.kapamaNo} <span className="ki-soluk">{tarihT(f.kapamaTarihi)}</span></td>
                          <td className="sag">{tl(f.tutarDoviz)} {f.doviz}</td>
                          <td className="sag">{kurT(f.faturaKuru)}</td><td className="sag">{kurT(f.kapamaKuru)}</td>
                          <td className={'sag ' + renk(f.kurFarki)}>{isaretli(f.kurFarki)}</td>
                          <td><span className={'bo-rz ' + DURUM_ROZET[f.durum][0]}
                            title={f.takipAn ? `${f.takipKim} · ${tarihT(f.takipAn)}${f.takipAciklama ? ' · ' + f.takipAciklama : ''}` : undefined}>
                            {DURUM_ROZET[f.durum][1]}{f.kesilenBelgeNo ? ` · ${f.kesilenBelgeNo}` : ''}</span>
                            {f.ihracat && <span className="bo-rz mavi dp-rz">ihracat — KDV yok</span>}</td>
                          {yetkili && <td className="dp-dug" onClick={e => e.stopPropagation()}>
                            {f.durum === 'oneri' && <>
                              <button onClick={() => setIsaret({ s: f, durum: 1 })}>✓ Kesildi…</button>
                              <button onClick={() => setIsaret({ s: f, durum: 2 })}>Gerek yok…</button></>}
                            {f.takipId != null && <button onClick={() => void geriAl(f)}>↶ Geri al</button>}
                          </td>}
                        </tr>))}
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Lehte fark (tahsil kuru fatura kurundan yüksek) için KDV'li kur farkı faturası kesilir (ihracatta KDV yok);
                  aleyhte fark yalnız bilgi (alacak dekontu önerisi). "Kur farkı faturası aç" seçili carinin yeni satış faturasını açar; fatura kesilince
                  satırı "Kesildi" ile o faturaya bağlayın — ikinci kez önerilmez. İşaret loglanır, geri alınabilir.</div>
              </Kutucuk>
            )}

            {sekme === 'vade' && (
              <Kutucuk baslik="Döviz vade takvimi" not="açık dövizli alacak (+) / borcun (−) vade dilimleri">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Dilim</th>
                      {dovizler.map(d => <th key={'a' + d} className="sag">Alacak {d}</th>)}
                      {dovizler.map(d => <th key={'b' + d} className="sag">Borç {d}</th>)}
                      <th className="sag">Net TL karşılığı</th></tr></thead>
                    <tbody>
                      {veri.vade.map(v => (
                        <tr key={v.dilim}><td>{v.ad}</td>
                          {dovizler.map(d => <td key={'a' + d} className="sag">{dv(v.alacak[d])}</td>)}
                          {dovizler.map(d => <td key={'b' + d} className="sag">{dv(v.borc[d])}</td>)}
                          <td className={'sag ' + renk(v.netTl)}>{dv(v.netTl)}</td></tr>))}
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Nakit Akış İcmali'nin döviz kırılımı: FIFO kapama sonrası açık kalan cari kalemleri vadesine göre (vade = hareketin
                  plan tarihi, yoksa işlem + carinin vade günü). Kasa ve banka bakiyesi bu tabloya girmez (vadesiz).</div>
              </Kutucuk>
            )}

            {sekme === 'dur' && (
              <Kutucuk baslik="Kur duyarlılığı" not="net pozisyon × kur değişimi · bugünkü pozisyonla">
                <table className="hi-tablo">
                  <thead><tr><th>Senaryo</th>{dovizler.map(d => <th key={d} className="sag">{d} etkisi</th>)}<th className="sag">Toplam TL etkisi</th></tr></thead>
                  <tbody>
                    {veri.duyarlilik.map(s => (
                      <tr key={s.yuzde}><td>{s.senaryo}</td>{dovizler.map(d => <td key={d} className={'sag ' + renk(s.etkiler[d])}>{dv(s.etkiler[d])}</td>)}
                        <td className={'sag ' + renk(s.toplam)}><b>{isaretli(s.toplam)}</b></td></tr>))}
                  </tbody>
                </table>
                <div className="fi-ipucu">Tek etkenli basit senaryo: tüm dövizler aynı oranda değişir, net pozisyonun TL karşılığı × oran. Türev / vadeli
                  işlem yok sayılır. {dovizler.length > 0 && `En büyük açık: ${enBuyukAcik(veri.ozet.netDovizTl, dovizler)}.`}</div>
              </Kutucuk>
            )}

            {sekme === 'kur' && (
              <Kutucuk baslik={`Kur geçmişi (${veri.kurAdi})`} not="pozisyon ve kur farkı hesabında kullanılan kurlar">
                <table className="hi-tablo">
                  <thead><tr><th>Tarih</th>{dovizler.map(d => <th key={d} className="sag">{d}</th>)}<th>Not</th></tr></thead>
                  <tbody>
                    {veri.kurGecmisi.length === 0 && <tr><td colSpan={dovizler.length + 2} className="bos">Kur kaydı yok.</td></tr>}
                    {veri.kurGecmisi.map(k => (
                      <tr key={k.tarih}><td>{tarihT(k.tarih)}</td>{dovizler.map(d => <td key={d} className="sag">{kurT(k.kurlar[d])}</td>)}
                        <td className="ki-soluk">{k.aySonu ? 'ay sonu değerleme' : ''}</td></tr>))}
                  </tbody>
                </table>
                <div className="fi-ipucu">Kurlar Döviz Kurları tanımından; o güne ait kur yoksa önceki son kur kullanılır.
                  {veri.kurlar.filter(k => k.eski || k.yok).map(k => ` ${k.doviz}: ${k.yok ? 'kur yok' : `son kur ${tarihT(k.kurTarihi)}`}.`).join('')}</div>
              </Kutucuk>
            )}

            {sekme === 'a4' && <EkranA4>{a4}</EkranA4>}
          </div>
        </div>

        <div className="fi-ipucu dp-durum">
          {veri.dovizler.length} döviz · {o.dovizliCari} dövizli cari · kur {tarihT(veri.tarih)}: {veri.dovizler.map(d => `${d} ${kurT(kurAdi(d)?.kur)}`).join(' · ')}
          {' '}· hesap sunucuda, ekran toplamaz
        </div>
      </>)}

      {isaret && <IsaretPenceresi s={isaret.s} durum={isaret.durum} onKapat={() => setIsaret(null)} onTamam={tazele} />}
    </div>
  );
}

function enBuyukAcik(net: DovizTutar, dovizler: string[]) {
  const d = [...dovizler].sort((a, b) => Math.abs(net[b] ?? 0) - Math.abs(net[a] ?? 0))[0];
  return d ? `${d} (${isaretli(net[d] ?? 0)} ₺)` : '—';
}

function PozSatir({ s, dovizler }: { s: Veri['pozisyon']['satirlar'][number]; dovizler: string[] }) {
  return (
    <tr><td>{s.kalem}</td>{dovizler.map(d => <td key={d} className={'sag' + ((s.tutar[d] ?? 0) < 0 ? ' kir' : '')}>{dv(s.tutar[d])}</td>)}
      <td className={'sag' + (s.tl < 0 ? ' kir' : '')}>{dv(s.tl)}</td></tr>
  );
}

function IsaretPenceresi({ s, durum, onKapat, onTamam }: {
  s: KurFarkiSatiri; durum: 1 | 2; onKapat(): void; onTamam(metin: string): void;
}) {
  const [no, setNo] = useState('');
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState('');
  const [isliyor, setIsliyor] = useState(false);
  const kaydet = async () => {
    if (durum === 1 && !no.trim()) { setHata('Kesilen kur farkı faturasının numarası girilmeli.'); return }
    if (durum === 2 && aciklama.trim().length < 3) { setHata('Neden yazılmalı (en az 3 karakter).'); return }
    setIsliyor(true); setHata('');
    try {
      await dovizPozisyonUclari.kurFarkiIsaretle({
        tarafId: s.tarafId, belgeId: s.belgeId, kapamaAnahtar: s.kapamaAnahtar, doviz: s.doviz, tutarDoviz: s.tutarDoviz,
        faturaKuru: s.faturaKuru, kapamaKuru: s.kapamaKuru, kurFarki: s.kurFarki, durum,
        kesilenBelgeNo: durum === 1 ? no.trim() : undefined, aciklama: aciklama.trim(),
      });
      onTamam(`${s.cari} · ${s.belgeNo}: kur farkı ${durum === 1 ? 'kesildi olarak işaretlendi' : '"gerek yok" işaretlendi'}.`);
    } catch (h) { setHata(hataMetni(h)) } finally { setIsliyor(false) }
  };
  return (
    <Modal baslik={`${durum === 1 ? '✓ Kur farkı faturası kesildi' : 'Kur farkı faturasına gerek yok'} · ${s.cari}`} dar buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="b" disabled={isliyor} onClick={() => void kaydet()}>Kaydet</button>
        <button type="button" className="d" onClick={onKapat}>✖ Vazgeç</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="not">{s.belgeNo} ({tarihT(s.belgeTarihi)}) · {tl(s.tutarDoviz)} {s.doviz} · fatura kuru {kurT(s.faturaKuru)} → kapama kuru
        {' '}{kurT(s.kapamaKuru)} · kur farkı <b>{isaretli(s.kurFarki)} ₺</b></div>
      {durum === 1 && <div className="alan"><label>Kesilen kur farkı faturasının numarası</label>
        <input value={no} maxLength={40} onChange={e => setNo(e.target.value)} placeholder="ör. FAT2026000000123" /></div>}
      <div className="alan"><label>{durum === 1 ? 'Açıklama (isteğe bağlı)' : 'Neden (zorunlu)'}</label>
        <textarea value={aciklama} maxLength={300} rows={3} onChange={e => setAciklama(e.target.value)} /></div>
      <div className="not">Fatura bu carinin kesin satış faturaları arasında aranır. İşaret loglanır ve geri alınabilir.</div>
    </Modal>
  );
}

function DovizA4({ v, antet, duzenleyen }: { v: Veri; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const o = v.ozet;
  const sube = v.sube ? v.secim.subeler.find(s => s.id === v.sube)?.ad : 'Tümü';
  const kurlar = v.kurlar.map(k => `${k.doviz} ${kurT(k.kur)}`).join(' · ');
  const yuzde10 = v.duyarlilik.find(d => d.yuzde === 10);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>DÖVİZ POZİSYONU VE KUR FARKI İCMALİ</h3>
      <div className="a4-hasta">
        <span>Tarih: <b>{tarihT(v.tarih)}</b> · {v.kurAdi}</span><span>Kur farkı dönemi: {v.donem}</span>
        <span>{kurlar}</span><span>Şube: {sube}</span>
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Döviz</th><th>Varlık</th><th>Yükümlülük</th><th>Net</th><th>TL karşılığı</th></tr></thead>
        <tbody>
          {v.dovizler.map(d => <tr key={d}><td>{d}</td><td>{dv(v.pozisyon.varlik[d])}</td><td>{dv(v.pozisyon.yukumluluk[d])}</td>
            <td>{dv(v.pozisyon.net[d])}</td><td>{dv(o.netDovizTl[d])}</td></tr>)}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Gerçekleşen kur farkı</td><td>{isaretli(o.gerceklesen)}</td></tr>
        <tr><td>Değerleme farkı (bilgi)</td><td>{isaretli(o.degerleme)}</td></tr>
        <tr className="kalan ki-kalan"><td>NET DÖVİZ POZİSYONU</td><td>{isaretli(o.netTl)} ₺</td></tr>
      </tbody></table>
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Genel Müdür<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Döviz Pozisyonu / Kur Farkı İcmali{yuzde10 ? ` · kur %10 artarsa ${isaretli(yuzde10.toplam)} ₺` : ''}
        {o.faturaAdet > 0 ? ` · ${o.faturaAdet} cariye kur farkı faturası kesilmedi` : ''}</p>
    </div>
  );
}

const DP_STILI = `
.hi .sepv { width:1px; height:20px; background:#cdd6e0; margin:0 4px; display:inline-block; }
.hi .dp-rz { margin-left:6px; }
.hi .dp-durum { margin:0 12px 12px; }
.hi .dp-dug { white-space:nowrap; }
.hi .dp-dug button { font-size:11px; padding:2px 6px; margin-right:4px; }
.hi .bilgi-kutusu { margin:6px 12px; padding:6px 10px; border:1px solid #bfe3cb; background:#e2f3e8; color:#2e7d46; border-radius:4px; cursor:pointer; }
`;

export default DovizPozisyonIcmali;
