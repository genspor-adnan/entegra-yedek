import { Fragment, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { hataMetni } from '../../api/sozlesme';
import { bankaHareketUclari } from '../../api/uclar/bankaHareket';
import {
  bankaMutabakatUclari, type BankaMutabakatIcmali as Veri, type EslesmeAdaylari, type GunlukBakiye, type IslenmemisHareket,
  type MutabakatDurumu, type MutabakatHesabi,
} from '../../api/uclar/bankaMutabakat';
import { tutarOku } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { Kutu, Kutucuk, Sekmeler, STOK_ICMAL_STILI, tarihT, tl, useAntet, useSuzgec } from '../stokIcmal/stokIcmalOrtak';
import { EkranA4, TICARI_ICMAL_STILI } from '../ticariIcmal/ticariIcmalOrtak';
import { FINANS_ICMAL_STILI, HESAP_IKON, isaretli } from './finansIcmalOrtak';

/**
 * BANKA MUTABAKAT İCMALİ `/banka-mutabakat` - mockup Ekranlar/İcmal/banka_mutabakat_icmali.html (kararlar 25.10.2026).
 * "Bankadaki para ile sistemdeki para tutuyor mu; tutmuyorsa farkın her kuruşu neden?" Rakamlar sunucudan
 * (BankaMutabakatUclari); ekran toplamaz. Varsayılan gün dünün gün sonu, "Ay sonu" hızlı seçimi; tarih esası
 * işlem tarihi; POS valör bekleyen ayrı satır, fark sayılmaz. İşle / Bankadan Çek Banka Hareketleri'nin uçlarıyla.
 */
type Sekme = 'hesap' | 'tablo' | 'isl' | 'yol' | 'gun' | 'gec' | 'onz';

const DURUM: Record<MutabakatDurumu, [string, string]> = {
  bakiye_yok: ['bakiye girilmedi', 'sari'], tutuyor: ['tutuyor', 'ok'], aciklandi: ['açıklandı', 'mavi'],
  fark: ['açıklanmayan fark', 'kir'], onayli: ['onaylı', 'ok'], bozuldu: ['bozuldu - yeniden onay', 'kir'],
};
const KAYNAK_AD: Record<string, string> = { api: 'API', dosya: 'dosya', elle: 'elle', ekstre: 'ekstre', yok: '—' };
const ONERI_AD: Record<string, string> = {
  tahsilat: 'Tahsilat', tediye: 'Ödeme', virman: 'Virman', pos: 'POS aktarımı', masraf: 'Masraf', yoksay: 'Yoksay',
};
/** 'yyyy-AA-gg…' → gg.AA.yyyy (saat dilimi kaydırmasız). */
const gunT = (s: string | null | undefined) => (s ? `${s.slice(8, 10)}.${s.slice(5, 7)}.${s.slice(0, 4)}` : '—');
const zamanT = (s: string | null | undefined) => (s
  ? new Date(s).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }) : '—');
const gunEkle = (s: string, n: number) => {
  const d = new Date(Number(s.slice(0, 4)), Number(s.slice(5, 7)) - 1, Number(s.slice(8, 10)) + n);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
};
const para = (h: { doviz: string; yerelMi?: boolean }, n: number | null | undefined) =>
  n == null ? '—' : `${h.doviz && h.doviz !== 'TL' && h.doviz !== 'TRY' ? h.doviz + ' ' : ''}${tl(n)}`;
const Rozet = ({ d }: { d: MutabakatDurumu }) => <span className={'bo-rz ' + DURUM[d][1]}>{DURUM[d][0]}</span>;

export function BankaMutabakatIcmali() {
  const { arama, degistir } = useSuzgec();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const antet = useAntet();
  const gunP = arama.get('gun') ?? '';
  const hesapP = Number(arama.get('hesap') ?? 0);
  const sube = Number(arama.get('sube') ?? 0);
  const kart = arama.get('kart') !== '0';
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [tazele, setTazele] = useState(0);
  const [sekme, setSekme] = useState<Sekme>('hesap');
  const [secHesap, setSecHesap] = useState(0);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [aktifHareket, setAktifHareket] = useState(0);
  const [eslesAcik, setEslesAcik] = useState(false);
  const [bakiyeAcik, setBakiyeAcik] = useState(false);
  const [mesgul, setMesgul] = useState(false);
  const [bilgi, setBilgi] = useState('');

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams();
    if (gunP) q.set('gun', gunP);
    if (hesapP) q.set('hesap', String(hesapP));
    if (sube) q.set('sube', String(sube));
    if (!kart) q.set('kart', '0');
    bankaMutabakatUclari.bankaMutabakatIcmali(q)
      .then(v => { setVeri(v); setSecili(new Set()) })
      .catch(h => setHata(hataMetni(h)))
      .finally(() => setYukleniyor(false));
  }, [gunP, hesapP, sube, kart, tazele]);

  const yenile = () => setTazele(t => t + 1);
  const o = veri?.ozet;
  const yt = veri?.yetkiler;
  const gun = veri?.gun ?? gunP;
  const hesap = useMemo(() => veri?.hesaplar.find(h => h.id === secHesap) ?? veri?.hesaplar[0] ?? null, [veri, secHesap]);
  const elleHesaplar = (veri?.hesaplar ?? []).filter(h => !h.api);
  const onaylanabilir = (veri?.hesaplar ?? []).filter(h => h.onaylanabilir);
  const gunAdi = !veri ? '' : gun === veri.dun ? ' (dün, gün sonu)' : gun === veri.aySonu ? ' (ay sonu)' : gun === veri.bugun ? ' (bugün - gün bitmedi)' : ' (gün sonu)';

  /** Yazan eylem: meşgulken düğmeler kapalı, sonunda icmal yenilenir. */
  const calistir = (is: () => Promise<string>) => {
    setMesgul(true); setBilgi('');
    is().then(m => { setBilgi(m); yenile() })
      .catch(e => mesaj(hataMetni(e)))
      .finally(() => setMesgul(false));
  };

  const bankadanCek = () => calistir(async () => {
    const r = await bankaHareketUclari.bankaCek();
    const yeni = r.sonuclar.reduce((t, s) => t + (s.yeni ?? 0), 0);
    const hatalar = r.sonuclar.filter(s => s.hata).map(s => s.hata);
    return `Bankadan çekildi: ${yeni} yeni hareket${hatalar.length ? ` · ${hatalar.length} hesap hata verdi (${hatalar.join('; ')})` : ''}.`;
  });

  const topluIsle = () => calistir(async () => {
    const r = await bankaHareketUclari.bankaTopluIsle([...secili]);
    return `${r.islenen} hareket işlendi${r.hatalar.length ? ` · işlenemeyen: ${r.hatalar.join('; ')}` : ''}.`;
  });

  const tekIsle = (x: IslenmemisHareket) => calistir(async () => {
    await bankaHareketUclari.bankaIsle(x.id, {});
    return `${x.aciklama || 'Hareket'} öneriyle işlendi.`;
  });

  const onayla = async (liste: MutabakatHesabi[]) => {
    if (!veri || liste.length === 0) return;
    const metin = liste.length === 1
      ? `${liste[0].ad} hesabının ${gunT(gun)} gün sonu mutabakatı onaylanacak; o günün bakiyeleri ve açıklama listeleri dondurulur.`
      : `${liste.length} hesabın ${gunT(gun)} gün sonu mutabakatı onaylanacak; o günün bakiyeleri ve açıklama listeleri dondurulur.`;
    if (!await onay(metin)) return;
    calistir(async () => {
      const r = await bankaMutabakatUclari.bankaMutabakatOnay(gun, liste.map(h => h.id));
      return `${r.onaylanan.length} hesap onaylandı${r.hatalar.length ? ` · onaylanmayan: ${r.hatalar.map(h => `${h.ad} (${h.neden})`).join('; ')}` : ''}.`;
    });
  };

  const hesapSec = (id: number, s?: Sekme) => { setSecHesap(id); if (s) setSekme(s) };
  const ekstre = (h: MutabakatHesabi | null) => h && git(`/ekstre?tur=hesap&id=${h.id}&bas=${gunEkle(gun, -30)}&bit=${gun}`);
  const hareketler = (h: MutabakatHesabi | null) => git(`/banka-hareket${h && h.tur === 'B' ? `?hesapId=${h.id}` : ''}`);
  const islSec = (x: IslenmemisHareket) => setSecili(s => { const n = new Set(s); if (n.has(x.id)) n.delete(x.id); else n.add(x.id); return n });
  const a4 = veri && hesap ? <Tutanak v={veri} h={hesap} antet={antet} duzenleyen={kullanici?.ad ?? ''} /> : null;

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + STOK_ICMAL_STILI + FINANS_ICMAL_STILI + TICARI_ICMAL_STILI + BM_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>Banka Mutabakat İcmali{veri ? ` — ${gunT(gun)} gün sonu` : ''}</h1>
          <span className="yol">Finans › İcmaller › Banka Mutabakat İcmali</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket="Mutabakat Tutanağı" dosyaAdi={`Banka Mutabakat Tutanağı ${hesap?.ad ?? ''} ${gun}`} devre={!a4}>{a4}</CiktiMenusu>
        <button disabled={!yt?.cek || mesgul} onClick={bankadanCek} title="Banka API'si bağlı bütün hesaplar">🔄 Bankadan Çek (tümü)</button>
        <button disabled={!yt?.isle || mesgul || secili.size === 0} onClick={topluIsle}
          title={secili.size ? '' : 'İşlenmemiş sekmesinde öneri hazır hareketleri işaretleyin'}>✓ Seçilenleri İşle{secili.size ? ` (${secili.size})` : ''}</button>
        <button disabled={!yt?.esles || mesgul || !aktifHareket} onClick={() => { setEslesAcik(true); setSekme('isl') }}
          title={aktifHareket ? 'Banka hareketini var olan kasa işlemine bağla' : 'İşlenmemiş sekmesinde bir harekete tıklayın'}>🔗 Eşleştir…</button>
        <button disabled={!yt?.bakiyeGir || mesgul || elleHesaplar.length === 0} onClick={() => setBakiyeAcik(a => !a)}
          title={elleHesaplar.length ? '' : "API'siz hesap yok"}>✍ Banka bakiyesi gir (API'siz hesap)</button>
        <button className="bm-birincil" disabled={!yt?.onay || mesgul || onaylanabilir.length === 0} onClick={() => void onayla(onaylanabilir)}
          title={!yt?.onay ? 'banka.mutabakat_onay yetkisi gerekir' : onaylanabilir.length ? '' : 'Açıklanmayan farkı 0 olan, onaylanmamış hesap yok'}>
          🔒 Mutabakatı Onayla{onaylanabilir.length ? ` (${onaylanabilir.length})` : ''}</button>
        <span className="sp" />
        {yt?.hareketGor && <button onClick={() => hareketler(hesap)}>🔄 Banka Hareketleri</button>}
        <button disabled={!hesap} onClick={() => ekstre(hesap)}>📄 Hesap Ekstresi</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bm-bilgi">{bilgi} <span className="lnk" onClick={() => setBilgi('')}>kapat</span></div>}

      <div className="hi-serit">
        <div className="sel">📅 Mutabakat günü:
          <input type="date" value={gun} max={veri?.bugun} onChange={e => e.target.value && degistir({ gun: e.target.value })} />
          <select value="" onChange={e => { if (veri && e.target.value) degistir({ gun: e.target.value === 'dun' ? '' : veri.aySonu }) }}>
            <option value="">{gunAdi.trim() || 'Hızlı…'}</option>
            <option value="dun">Dün (gün sonu)</option>
            {veri && <option value="ay">Ay sonu ({gunT(veri.aySonu)})</option>}
          </select></div>
        <div className="sel">🏦 Hesap:
          <select value={hesapP} onChange={e => degistir({ hesap: e.target.value })}>
            <option value={0}>Tüm hesaplar ({veri?.secim.hesaplar.length ?? 0})</option>
            {(veri?.secim.hesaplar ?? []).map(h => <option key={h.id} value={h.id}>{HESAP_IKON[h.tur] ?? ''} {h.ad}</option>)}
          </select></div>
        <div className="sel">🏢 Şube:
          <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.secim.subeler ?? []).map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
          </select></div>
        <div className="sel" title="Karar 25.10.2026: bankanın ekstresi gibi işlem tarihi; valörü sonraki hareket ayrı satırda">📆 Tarih esası: <b>İşlem tarihi</b></div>
        <label className="fi-chk"><input type="checkbox" checked={kart} onChange={e => degistir({ kart: e.target.checked ? '' : '0' })} /> Kredi kartı / POS hesapları dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && o.api > 0 && <span className="bo-rz mavi">Son çekim: {zamanT(o.sonCekim)} · {o.api} hesap API</span>}
        {o && o.elle > 0 && <span className="bo-rz">{o.elle} hesap API'siz · bakiye elle</span>}
        {o && o.bozuldu > 0 && <span className="bo-rz kir">{o.bozuldu} onay bozuldu</span>}
        {o && o.kurYok.length > 0 && <span className="bo-rz sari" title="TL karşılığı toplamına girmedi">Kur yok: {o.kurYok.join(', ')}</span>}
      </div>

      {bakiyeAcik && veri && <BakiyeFormu v={veri} hesaplar={elleHesaplar} varsayilan={hesap && !hesap.api ? hesap.id : elleHesaplar[0]?.id ?? 0}
        kapat={() => setBakiyeAcik(false)} kaydedildi={m => { setBakiyeAcik(false); setBilgi(m); yenile() }} />}

      {veri && o && (<>
        <div className="hi-ozet">
          <Kutu bas="Banka Bakiyesi" deg={`${tl(o.bankaBakiye)} ₺`} alt={`${o.hesap - o.bakiyesiz} hesap · TL karşılığı${o.bakiyesiz ? ` · ${o.bakiyesiz} bakiyesiz` : ''}`} />
          <Kutu bas="Sistem Bakiyesi" deg={`${tl(o.sistemBakiye)} ₺`} alt="kesin kasa işlemlerinden" />
          <Kutu bas="Fark" deg={`${isaretli(o.fark)} ₺`} alt={o.farkHesap ? `${o.farkHesap} hesapta · ${o.fark > 0 ? 'banka fazla' : 'sistem fazla'}` : 'fark yok'}
            sinif={Math.abs(o.fark) >= 0.005 ? 'uy' : 'iyi'} />
          <Kutu bas="İşlenmemiş Banka Hareketi" deg={String(o.islenmemisAdet)} alt={`${isaretli(o.islenmemisTutar)} ₺ net · ${o.oneriHazir} öneri hazır`}
            sinif={o.islenmemisAdet ? 'uy' : ''} />
          <Kutu bas="Sistemde Var, Bankada Yok" deg={String(o.yoldaAdet)} alt={`${isaretli(o.yoldaTutar)} ₺ · yolda / talimat${o.yoldaGeciken ? ` · ${o.yoldaGeciken} gecikmiş` : ''}`}
            sinif={o.yoldaGeciken ? 'teh' : ''} />
          <Kutu bas="Açıklanan Fark" deg={`${isaretli(o.aciklanan)} ₺`}
            alt={`${o.aciklananYuzde != null ? `%${o.aciklananYuzde} · ` : ''}açıklanmayan ${isaretli(o.aciklanmayan)}`}
            sinif={Math.abs(o.aciklanmayan) >= 0.005 ? 'teh' : 'iyi'} />
          <Kutu bas="Son Onaylı Mutabakat" deg={o.sonOnay ? gunT(o.sonOnay.gun) : '—'}
            alt={o.sonOnay ? `${o.sonOnay.onaylayan} · ${o.sonOnay.onayli} / ${o.sonOnay.toplamHesap} hesap` : 'henüz onay yok'} />
          <Kutu bas="Valör Bekleyen" deg={`${tl(o.valorBekleyen)} ₺`} alt="valörü günden sonra · fark sayılmaz" sinif="mor" />
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <Sekmeler<Sekme> secili={sekme} sec={setSekme} liste={[
              ['hesap', 'Hesaplar', null], ['tablo', 'Mutabakat Tablosu', null],
              ['isl', 'İşlenmemiş (banka var, sistem yok)', o.islenmemisAdet], ['yol', 'Sistemde var, bankada yok', o.yoldaAdet],
              ['gun', 'Günlük Bakiye', null], ['gec', 'Mutabakat Geçmişi', null], ['onz', '🖨 Mutabakat Tutanağı (A4)', null]]} />

            {sekme === 'hesap' && (
              <Kutucuk baslik="Banka hesapları — banka bakiyesi / sistem bakiyesi" not="satıra tıkla: o hesabın mutabakat tablosu">
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Hesap</th><th>Kaynak</th><th className="sag">Banka bakiyesi</th><th>Bakiye zamanı</th><th className="sag">Sistem bakiyesi</th>
                      <th className="sag">Fark</th><th className="sag">İşlenmemiş</th><th className="sag">Yolda</th><th className="sag">Açıklanmayan</th><th>Durum</th><th /></tr></thead>
                    <tbody>
                      {veri.hesaplar.length === 0 && <tr><td colSpan={11} className="bos">Görebildiğiniz banka / kredi kartı / POS hesabı yok.</td></tr>}
                      {veri.hesaplar.map(h => (
                        <tr key={h.id} className={'ac' + (hesap?.id === h.id ? ' fi-sec' : '')} onClick={() => hesapSec(h.id, 'tablo')}>
                          <td>{HESAP_IKON[h.tur] ?? ''} {h.ad}{h.doviz !== 'TL' && <span className="ki-soluk"> ({h.doviz})</span>}</td>
                          <td><span className={'bo-rz ' + (h.kaynak === 'api' ? 'mavi' : h.kaynak === 'yok' ? 'sari' : '')}>{KAYNAK_AD[h.kaynak]}</span></td>
                          <td className="sag">{h.bankaBakiye != null ? para(h, h.bankaBakiye) : <span className="ki-soluk">girilmedi</span>}</td>
                          <td className="ki-soluk">{h.bakiyeZamani ? zamanT(h.bakiyeZamani) : '—'}{h.bakiyeGiren ? ` · ${h.bakiyeGiren}` : ''}{h.kaynak === 'ekstre' ? ' · ekstre' : ''}
                            {h.cekimEksik && <span className="bo-rz sari" style={{ marginLeft: 4 }} title="Son çekim gün bitmeden yapıldı">çekim eksik</span>}</td>
                          <td className="sag">{para(h, h.sistemBakiye)}</td>
                          <td className={'sag' + (h.fark ? ' kir' : ' ki-soluk')}>{h.fark != null ? isaretli(h.fark) : '—'}</td>
                          <td className="sag">{h.islenmemisAdet ? `${h.islenmemisAdet} · ${isaretli(h.islenmemisTutar)}` : '—'}</td>
                          <td className={'sag' + (h.yoldaGeciken ? ' kir' : '')}>{h.yoldaAdet ? `${h.yoldaAdet} · ${isaretli(h.yoldaTutar)}` : h.akisVar ? '—' : <span className="ki-soluk" title="Banka hareketi akışı yok - yolda listesi çıkarılamaz">akış yok</span>}</td>
                          <td className={'sag' + (h.aciklanmayan ? ' kir' : '')}>{h.aciklanmayan != null ? tl(h.aciklanmayan) : '—'}</td>
                          <td><Rozet d={h.durum} />{h.valorBekleyen ? <span className="ki-soluk"> · valör bekleyen {tl(h.valorBekleyen)}</span> : null}
                            {h.onay?.durum === 'onayli' && <span className="ki-soluk"> · {h.onay.onaylayan}</span>}
                            {h.onay?.bozulmaNeden && <div className="kir bm-kucuk">{h.onay.bozulmaNeden}</div>}</td>
                          <td onClick={e => e.stopPropagation()}>
                            {yt?.onay && h.onaylanabilir && <span className="lnk" onClick={() => void onayla([h])}>🔒 onayla</span>}
                            {!h.onaylanabilir && h.onayEngel && h.durum !== 'onayli' && <span className="ki-soluk" title={h.onayEngel}>ⓘ</span>}
                            {yt?.bakiyeGir && !h.api && <span className="lnk" style={{ marginLeft: 6 }} onClick={() => { hesapSec(h.id); setBakiyeAcik(true) }}>✍</span>}
                          </td>
                        </tr>
                      ))}
                      <tr className="top"><td colSpan={2}>Toplam (TL karşılığı)</td><td className="sag">{tl(o.bankaBakiye)}</td><td />
                        <td className="sag">{tl(o.sistemBakiye)}</td><td className="sag">{isaretli(o.fark)}</td>
                        <td className="sag">{o.islenmemisAdet} · {isaretli(o.islenmemisTutar)}</td><td className="sag">{o.yoldaAdet} · {isaretli(o.yoldaTutar)}</td>
                        <td className="sag">{tl(o.aciklanmayan)}</td><td colSpan={2} /></tr>
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Banka bakiyesi API'li hesapta günün sonuna kadarki son banka hareketinin bakiyesi (son çekim gün bitmeden yapıldıysa "çekim eksik", onay verilmez);
                  API'siz hesapta o gün için elle girilen gün sonu bakiyesi (kredi kartında ekstre bakiyesi; kim / ne zaman loglu). Sistem bakiyesi kesin kasa işlemlerinden,
                  mutabakat gününün sonu itibarıyla (hesap ekstresiyle aynı). Tarih esası işlem tarihi; valörü sonraki POS / banka hareketi "valör bekleyen" — fark sayılmaz.
                  {veri.ayar.dortGoz && ' Dört göz açık: onaylayan, o günün hazırlayanından farklı olmalı.'}</div>
              </Kutucuk>
            )}

            {sekme === 'tablo' && <TabloSekmesi v={veri} h={hesap} sec={id => hesapSec(id)} />}

            {sekme === 'isl' && (<>
              <Kutucuk baslik="İşlenmemiş banka hareketleri (Banka Hareketleri ekranıyla aynı kayıtlar)"
                not={`${o.islenmemisAdet} · ${isaretli(o.islenmemisTutar)} ₺ · satıra tıkla: Eşleştir için seç`}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th style={{ width: 24 }} /><th>Tarih</th><th>Hesap</th><th>Açıklama</th><th>Karşı taraf</th><th className="sag">Tutar</th>
                      <th>Öneri</th><th className="sag">Güven</th><th /></tr></thead>
                    <tbody>
                      {veri.islenmemis.length === 0 && <tr><td colSpan={9} className="bos">İşlenmemiş banka hareketi yok.</td></tr>}
                      {veri.islenmemis.map(x => (
                        <tr key={x.id} className={'ac' + (aktifHareket === x.id ? ' fi-sec' : '')} onClick={() => setAktifHareket(x.id)}>
                          <td onClick={e => e.stopPropagation()}>
                            {x.durum === 1 && yt?.isle && <input type="checkbox" checked={secili.has(x.id)} onChange={() => islSec(x)} />}</td>
                          <td>{tarihT(x.tarih)}</td><td>{x.hesapAd}</td>
                          <td style={{ whiteSpace: 'normal', minWidth: 220 }}>{x.aciklama}
                            {x.valorBekleyen && <span className="bo-rz mor" style={{ marginLeft: 4 }}>valör {gunT(x.valor)}</span>}</td>
                          <td>{x.karsiAd || <span className="ki-soluk">—</span>}{x.karsiIban && <span className="ki-soluk"> · {x.karsiIban}</span>}</td>
                          <td className={'sag' + (x.tutar < 0 ? ' kir' : ' si-yesil')}>{isaretli(x.tutar)}</td>
                          <td style={{ whiteSpace: 'normal' }}>
                            {x.durum === 3 ? <span className="bo-rz pas">yoksayıldı</span>
                              : x.durum === 2 ? <span className="bo-rz mavi" title="Bağlı kasa işlemi mutabakat gününden sonra tarihli">sonra işlendi</span>
                              : x.durum === 4 ? <span className="bo-rz sari">seçim bekliyor</span>
                              : x.oneriTur ? <>{ONERI_AD[x.oneriTur] ?? x.oneriTur}{x.oneriHedef && ` → ${x.oneriHedef}`}</>
                              : <span className="ki-soluk">öneri yok</span>}
                            {x.neden && <div className="ki-soluk bm-kucuk">{x.neden}</div>}</td>
                          <td className="sag">{x.durum === 1 && x.guven ? `%${x.guven}` : '—'}</td>
                          <td onClick={e => e.stopPropagation()} style={{ whiteSpace: 'nowrap' }}>
                            {x.durum === 1 && yt?.isle && <button type="button" disabled={mesgul} onClick={() => tekIsle(x)}>✓ İşle</button>}
                            {(x.durum === 0 || x.durum === 4) && yt?.hareketGor && <span className="lnk" onClick={() => git(`/banka-hareket?hesapId=${x.hesapId}`)}>seç…</span>}
                            {x.durum !== 2 && x.durum !== 3 && yt?.esles && <span className="lnk" style={{ marginLeft: 6 }}
                              onClick={() => { setAktifHareket(x.id); setEslesAcik(true) }}>🔗</span>}
                          </td>
                        </tr>
                      ))}
                      {o.islenmemisAdet > veri.islenmemis.length && <tr><td colSpan={9} className="ki-soluk">… {o.islenmemisAdet - veri.islenmemis.length} hareket daha (Banka Hareketleri'nde)</td></tr>}
                      <tr className="top"><td colSpan={5}>Toplam ({o.islenmemisAdet})</td><td className="sag">{isaretli(o.islenmemisTutar)}</td><td colSpan={3} /></tr>
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">İşleme Banka Hareketleri ekranının aynı uçlarıyla (öneri → kasa işlemi); burada toplu işle ve mutabakat etkisi görünür.
                  "🔗" var olan kasa işlemine bağlar — yeni kasa işlemi açılmaz; tutar farkı {tl(veri.ayar.tolerans)} ₺ toleransı dışındaysa bağlanmaz
                  (fark banka masrafıysa ayrı masraf işlemi girin). Yoksayılan hareket bankada var, sistemde yok: farkı açıklar ama işlenene kadar listede kalır.</div>
              </Kutucuk>
              {eslesAcik && aktifHareket > 0 && <EslesPaneli hareketId={aktifHareket} kapat={() => setEslesAcik(false)}
                bagla={(k, no) => calistir(async () => {
                  const r = await bankaMutabakatUclari.bankaMutabakatEsles(aktifHareket, k);
                  setEslesAcik(false); setAktifHareket(0);
                  return `Banka hareketi ${r.islemNo || no || `#${k}`} kasa işlemine bağlandı${r.fark ? ` (fark ${isaretli(r.fark)})` : ''}.`;
                })} />}
            </>)}

            {sekme === 'yol' && (
              <Kutucuk baslik="Sistemde var, bankaya düşmemiş (yolda)" not={`${o.yoldaAdet} · ${isaretli(o.yoldaTutar)} ₺`}>
                <div style={{ overflowX: 'auto' }}>
                  <table className="hi-tablo">
                    <thead><tr><th>Kayıt</th><th>Tarih</th><th>Hesap</th><th>Tür</th><th>Karşı taraf</th><th className="sag">Tutar</th><th className="sag">İş günü</th><th>Durum</th></tr></thead>
                    <tbody>
                      {veri.yolda.length === 0 && <tr><td colSpan={8} className="bos">Bankaya düşmemiş kasa işlemi yok.</td></tr>}
                      {veri.yolda.map((y, i) => (
                        <tr key={`${y.hesapId}-${y.kasaIslemId ?? i}`} className={y.gecikti ? 'fi-eksi' : ''}>
                          <td>{y.islemNo || (y.kasaIslemId ? `#${y.kasaIslemId}` : '—')}</td><td>{tarihT(y.tarih)}</td><td>{y.hesapAd}</td>
                          <td>{y.turAdi}</td><td>{y.karsi || <span className="ki-soluk">{y.aciklama || '—'}</span>}</td>
                          <td className={'sag' + (y.tutar < 0 ? ' kir' : '')}>{isaretli(y.tutar)}</td><td className="sag">{y.gun}</td>
                          <td className={y.gecikti ? 'kir' : 'ki-soluk'}>{y.durumMetni}</td>
                        </tr>
                      ))}
                      {o.yoldaAdet > veri.yolda.length && <tr><td colSpan={8} className="ki-soluk">… {o.yoldaAdet - veri.yolda.length} kayıt daha</td></tr>}
                      <tr className="top"><td colSpan={5}>Toplam ({o.yoldaAdet})</td><td className="sag">{isaretli(o.yoldaTutar)}</td><td colSpan={2} /></tr>
                    </tbody>
                  </table>
                </div>
                <div className="fi-ipucu">Kesin kasa işlemi var, eşleşen banka hareketi yok (yalnız banka hareketi akışı olan hesaplarda, akış başladıktan sonrası).
                  Eşik: {veri.ayar.yoldaEsik} iş günü (çekte vade + 1 gün) — aşan kırmızı: kayıt yanlış hesaba girmiş ya da işlem yapılmamış olabilir.
                  Banka hareketi geldiyse İşlenmemiş sekmesinde "🔗" ile bu kayda bağlayın.</div>
              </Kutucuk>
            )}

            {sekme === 'gun' && <GunlukSekmesi v={veri} h={hesap} sec={id => hesapSec(id)} />}

            {sekme === 'gec' && <GecmisSekmesi v={veri} gunSec={g => { degistir({ gun: g === veri.dun ? '' : g }); setSekme('hesap') }} />}

            {sekme === 'onz' && (<>
              <div className="hi-serit" style={{ border: 0, padding: '6px 0' }}>
                <span>Tutanak hesabı:</span>
                <select value={hesap?.id ?? 0} onChange={e => hesapSec(Number(e.target.value))}>
                  {veri.hesaplar.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
                </select>
              </div>
              {a4 ? <EkranA4>{a4}</EkranA4> : <div className="bos">Hesap yok.</div>}
            </>)}
          </div>
        </div>

        <div className="hi-serit ki-soluk" style={{ borderBottom: 0 }}>
          <span>{o.hesap} banka / kart / POS hesabı</span><span>{o.islenmemisAdet} işlenmemiş</span><span>{o.yoldaAdet} yolda</span>
          <span>{o.onayli} onaylı{o.bozuldu ? ` · ${o.bozuldu} bozuldu` : ''}</span><span>Hesap sunucuda · ekran toplamaz</span>
        </div>
      </>)}
    </div>
  );
}

// ===================================================================== sekmeler ===

function HesapSecici({ v, h, sec }: { v: Veri; h: MutabakatHesabi | null; sec(id: number): void }) {
  return (
    <select value={h?.id ?? 0} onChange={e => sec(Number(e.target.value))}>
      {v.hesaplar.map(x => <option key={x.id} value={x.id}>{HESAP_IKON[x.tur] ?? ''} {x.ad}</option>)}
    </select>
  );
}

function TabloSekmesi({ v, h, sec }: { v: Veri; h: MutabakatHesabi | null; sec(id: number): void }) {
  if (!h) return <div className="bos">Hesap yok.</div>;
  const t = h.tablo;
  const satir = (ad: string, n: number | null | undefined, adet: number | null, not: string, sinif = '') => (
    <tr className={sinif}><td>{ad}</td><td className="sag">{n == null ? '—' : sinif ? para(h, n) : isaretli(n)}</td>
      <td className="sag">{adet ?? ''}</td><td className="ki-soluk" style={{ whiteSpace: 'normal' }}>{not}</td></tr>
  );
  return (
    <Kutucuk baslik={`Mutabakat tablosu — ${h.ad}, ${gunT(v.gun)} gün sonu`} not={DURUM[h.durum][0]}>
      <div className="hi-serit" style={{ border: 0, padding: '6px 8px' }}><span>Hesap:</span><HesapSecici v={v} h={h} sec={sec} /></div>
      <table className="hi-tablo">
        <thead><tr><th>Kalem</th><th className="sag">Tutar</th><th className="sag">Adet</th><th>Açıklama</th></tr></thead>
        <tbody>
          <tr className="si-grup"><td>Banka bakiyesi</td><td className="sag">{t.banka != null ? para(h, t.banka) : '—'}</td><td />
            <td className="ki-soluk">{t.banka == null ? 'bakiye girilmedi' : `${KAYNAK_AD[h.kaynak]}${h.bakiyeZamani ? ` · ${zamanT(h.bakiyeZamani)}` : ''}${h.bakiyeGiren ? ` · ${h.bakiyeGiren}` : ''}${h.bakiyeNot ? ` · ${h.bakiyeNot}` : ''}`}</td></tr>
          {satir('− Sistemde var, bankaya düşmemiş çıkış', t.yoldaCikis, t.yoldaCikisAdet, t.yoldaCikisNot)}
          {satir('+ Sistemde var, bankaya düşmemiş giriş', t.yoldaGiris, t.yoldaGirisAdet, t.yoldaGirisNot)}
          <tr className="top"><td>= Düzeltilmiş banka bakiyesi</td><td className="sag">{t.duzeltilmisBanka != null ? para(h, t.duzeltilmisBanka) : '—'}</td><td /><td /></tr>
          <tr className="si-grup"><td>Sistem bakiyesi</td><td className="sag">{para(h, t.sistem)}</td><td /><td className="ki-soluk">kesin kasa işlemleri</td></tr>
          {satir('+ Bankada var, sistemde işlenmemiş giriş', t.islenmemisGiris, t.islenmemisGirisAdet, t.islenmemisGirisNot)}
          {satir('− Bankada var, sistemde işlenmemiş çıkış', t.islenmemisCikis, t.islenmemisCikisAdet, t.islenmemisCikisNot)}
          <tr className="top"><td>= Düzeltilmiş sistem bakiyesi</td><td className="sag">{para(h, t.duzeltilmisSistem)}</td><td /><td className="ki-soluk">işlenmemişler işlenince sistem bakiyesi budur</td></tr>
          <tr className={t.aciklanmayan ? 'fi-eksi' : ''}><td><b>Açıklanmayan fark</b></td><td className={'sag' + (t.aciklanmayan ? ' kir' : ' si-yesil')}><b>{t.aciklanmayan != null ? tl(t.aciklanmayan) : '—'}</b></td>
            <td /><td>{t.aciklanmayan == null ? 'banka bakiyesi yok' : t.aciklanmayan ? 'farkın açıklaması yok — kayıtları kontrol edin' : 'mutabık'}</td></tr>
          {h.valorBekleyen ? <tr className="fi-alt"><td>Valör bekleyen (bilgi)</td><td className="sag">{para(h, h.valorBekleyen)}</td><td /><td>fark sayılmaz</td></tr> : null}
        </tbody>
      </table>
      <div className="fi-ipucu">Klasik banka mutabakatı: banka bakiyesi ↔ defter bakiyesi; fark yalnız iki listeyle açıklanır (bankada olup sistemde olmayan, sistemde olup bankada olmayan).
        Açıklanmayan fark ≠ 0 ise "Mutabakatı Onayla" pasif.{h.onayEngel && h.durum !== 'onayli' && <> <b>Onay:</b> {h.onayEngel}</>}
        {h.onay?.bozulmaNeden && <> <b className="kir">Bozuldu:</b> {h.onay.bozulmaNeden}</>}</div>
    </Kutucuk>
  );
}

function GunlukSekmesi({ v, h, sec }: { v: Veri; h: MutabakatHesabi | null; sec(id: number): void }) {
  const [n, setN] = useState(10);
  const [g, setG] = useState<GunlukBakiye | null>(null);
  const [hata, setHata] = useState('');
  const id = h?.id ?? 0;
  useEffect(() => {
    if (!id) return;
    setHata('');
    bankaMutabakatUclari.bankaMutabakatGunluk(id, v.gun, n).then(setG).catch(e => setHata(hataMetni(e)));
  }, [id, v.gun, n]);
  if (!h) return <div className="bos">Hesap yok.</div>;
  return (
    <Kutucuk baslik={`Günlük bakiye — ${h.ad} (son ${n} gün)`}>
      <div className="hi-serit" style={{ border: 0, padding: '6px 8px' }}><span>Hesap:</span><HesapSecici v={v} h={h} sec={sec} />
        <select value={n} onChange={e => setN(Number(e.target.value))}>{[10, 20, 31].map(x => <option key={x} value={x}>son {x} gün</option>)}</select></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <table className="hi-tablo">
        <thead><tr><th>Gün</th><th className="sag">Banka (gün sonu)</th><th className="sag">Sistem (gün sonu)</th><th className="sag">Fark</th><th>Mutabakat</th></tr></thead>
        <tbody>
          {!g && !hata && <tr><td colSpan={5} className="bos">yükleniyor…</td></tr>}
          {g?.satirlar.map(s => (
            <tr key={s.gun} className={s.gun === v.gun ? 'fi-sec' : ''}>
              <td>{gunT(s.gun)}</td>
              <td className="sag">{s.banka != null ? para(h, s.banka) : <span className="ki-soluk">—</span>}{s.banka != null && <span className="ki-soluk"> · {KAYNAK_AD[s.kaynak]}</span>}</td>
              <td className="sag">{para(h, s.sistem)}</td>
              <td className={'sag' + (s.fark ? ' kir' : ' ki-soluk')}>{s.fark != null ? isaretli(s.fark) : '—'}</td>
              <td>{s.onay ? (s.onay.durum === 'onayli'
                ? <span className="si-yesil">onaylı · {s.onay.onaylayan}</span>
                : <span className="kir" title={s.onay.bozulmaNeden}>bozuldu — yeniden onay</span>)
                : s.banka == null ? <span className="ki-soluk">bakiye yok</span>
                : s.fark ? <span className="ki-soluk">onay bekliyor</span> : <span className="ki-soluk">tutuyor, onaysız</span>}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="fi-ipucu">Banka gün sonu bakiyesi API'nin hareket bakiyesinden (banka_hareket.bakiye, günün son hareketi); hareketsiz gün önceki günün bakiyesiyle.
        API'siz hesapta yalnız bakiyesi girilmiş günler dolu. Onay her gün için ayrıdır.</div>
    </Kutucuk>
  );
}

function GecmisSekmesi({ v, gunSec }: { v: Veri; gunSec(g: string): void }) {
  const [acik, setAcik] = useState<Set<string>>(new Set());
  const cevir = (k: string) => setAcik(a => { const n = new Set(a); if (n.has(k)) n.delete(k); else n.add(k); return n });
  return (
    <Kutucuk baslik="Mutabakat geçmişi" not="satıra tıkla: hesaplar · çift tık: o günü aç">
      <table className="hi-tablo">
        <thead><tr><th>Gün</th><th>Hesap</th><th className="sag">Banka</th><th className="sag">Sistem</th><th className="sag">Açıklanmayan</th><th>Onaylayan</th><th>Not</th></tr></thead>
        <tbody>
          {v.gecmis.length === 0 && <tr><td colSpan={7} className="bos">Henüz onaylanmış mutabakat yok.</td></tr>}
          {v.gecmis.map(g => (
            <Fragment key={g.gun}>
              <tr className="ac" onClick={() => cevir(g.gun)} onDoubleClick={() => gunSec(g.gun.slice(0, 10))}>
                <td><span className="ok">{acik.has(g.gun) ? '▾' : '▸'}</span>{gunT(g.gun)}</td>
                <td>{g.onayli} / {g.toplamHesap} hesap{g.aySonu && ' (ay sonu)'}</td>
                <td className="sag">{tl(g.banka)}</td><td className="sag">{tl(g.sistem)}</td>
                <td className={'sag' + (g.aciklanmayan ? ' kir' : '')}>{tl(g.aciklanmayan)}</td>
                <td>{g.onaylayan} · {zamanT(g.onayAn)}</td>
                <td>{g.bozuldu > 0 && <span className="bo-rz kir">{g.bozuldu} bozuldu</span>}</td>
              </tr>
              {acik.has(g.gun) && g.satirlar.map(s => (
                <tr key={g.gun + s.hesapId} className="fi-alt">
                  <td /><td>{s.hesapAd}</td><td className="sag">{tl(s.banka)}</td><td className="sag">{tl(s.sistem)}</td>
                  <td className="sag">{tl(s.aciklanmayan)}</td><td>{s.onaylayan} · {zamanT(s.onayAn)}</td>
                  <td>{s.durum === 'bozuldu' ? <span className="kir" style={{ whiteSpace: 'normal' }}>bozuldu{s.bozulmaNeden ? `: ${s.bozulmaNeden}` : ''}</span> : <span className="si-yesil">onaylı</span>}</td>
                </tr>
              ))}
            </Fragment>
          ))}
        </tbody>
      </table>
      <div className="fi-ipucu">Onay o günün bakiyelerini ve açıklama listelerini dondurur; sonradan o güne geriye dönük kasa işlemi girilirse (ya da elle bakiye değişirse)
        onay "bozuldu" rozetiyle düşer ve yeniden onay ister. Kayıt engellenmez. Tutarlar TL karşılığı (dondurulan bakiye × o günün kuru).</div>
    </Kutucuk>
  );
}

// ======================================================================= paneller ===

function EslesPaneli({ hareketId, kapat, bagla }: { hareketId: number; kapat(): void; bagla(kasaIslemId: number, no: string): void }) {
  const [a, setA] = useState<EslesmeAdaylari | null>(null);
  const [hata, setHata] = useState('');
  useEffect(() => {
    setA(null); setHata('');
    bankaMutabakatUclari.bankaMutabakatEslesAday(hareketId).then(setA).catch(e => setHata(hataMetni(e)));
  }, [hareketId]);
  const x = a?.hareket;
  return (
    <Kutucuk baslik="🔗 Eşleştir — banka hareketi ↔ var olan kasa işlemi" not={a ? `tolerans ${tl(a.tolerans)} ₺` : ''}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {x && <div className="bm-bilgi" style={{ margin: 8 }}>{tarihT(x.tarih)} · {x.hesapAd} · {x.aciklama}{x.karsiAd && ` · ${x.karsiAd}`} · <b>{isaretli(x.tutar)}</b></div>}
      <table className="hi-tablo">
        <thead><tr><th>Kayıt</th><th>Tarih</th><th>Tür</th><th>Karşı taraf</th><th className="sag">Tutar</th><th className="sag">Fark</th><th /></tr></thead>
        <tbody>
          {!a && !hata && <tr><td colSpan={7} className="bos">aranıyor…</td></tr>}
          {a && a.adaylar.length === 0 && <tr><td colSpan={7} className="bos">Bu hesapta ±45 gün içinde tutarı tutan, banka hareketiyle eşleşmemiş kesin kasa işlemi yok.</td></tr>}
          {a?.adaylar.map(k => (
            <tr key={k.kasaIslemId}>
              <td>{k.islemNo || `#${k.kasaIslemId}`}</td><td>{tarihT(k.tarih)}</td><td>{k.turAdi}</td>
              <td>{k.karsi || <span className="ki-soluk">{k.aciklama || '—'}</span>}</td>
              <td className="sag">{isaretli(k.tutar)}</td><td className={'sag' + (k.fark ? ' kir' : ' ki-soluk')}>{k.fark ? isaretli(k.fark) : '0'}</td>
              <td><button type="button" onClick={() => bagla(k.kasaIslemId, k.islemNo)}>🔗 Bağla</button></td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="fi-ipucu">Yeni kasa işlemi açılmaz (çifte kayıt olmaz); hareket seçilen işleme bağlanır ve "işlendi" olur. Kasa işlemi iptal edilirse hareket yeniden bekleyene döner.
        <span className="lnk" style={{ marginLeft: 8 }} onClick={kapat}>kapat</span></div>
    </Kutucuk>
  );
}

function BakiyeFormu({ v, hesaplar, varsayilan, kapat, kaydedildi }: {
  v: Veri; hesaplar: MutabakatHesabi[]; varsayilan: number; kapat(): void; kaydedildi(m: string): void;
}) {
  const [hesapId, setHesapId] = useState(varsayilan);
  const [gun, setGun] = useState(v.gun);
  const h = hesaplar.find(x => x.id === hesapId);
  const ayniGun = gun === v.gun;
  const [tutar, setTutar] = useState('');
  const [kaynak, setKaynak] = useState(1);
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState('');
  const [mesgul, setMesgul] = useState(false);
  useEffect(() => {
    // Seçili günün mevcut kaydı (icmal günündeyse) forma gelir; değişiklik sürümüyle gönderilir.
    const e = ayniGun ? h?.elle : undefined;
    setTutar(e ? e.bakiye.toLocaleString('tr-TR', { minimumFractionDigits: 2 }) : '');
    setKaynak(e ? e.kaynak : h?.tur === 'V' ? 2 : 1);
    setAciklama(e?.aciklama ?? '');
  }, [h, ayniGun]);
  const kaydet = () => {
    if (!h) { setHata('Hesap seçin.'); return }
    if (!tutar.trim()) { setHata('Gün sonu bakiyesini girin.'); return }
    const n = tutarOku(tutar);
    if (!Number.isFinite(n)) { setHata('Geçerli bir tutar girin.'); return }
    setMesgul(true); setHata('');
    bankaMutabakatUclari.bankaMutabakatBakiye({ hesapId: h.id, gun, bakiye: n, kaynak, aciklama, surum: ayniGun ? h.elle?.surum : undefined })
      .then(() => kaydedildi(`${h.ad} · ${gunT(gun)} gün sonu bakiyesi kaydedildi.`))
      .catch(e => setHata(hataMetni(e)))
      .finally(() => setMesgul(false));
  };
  return (
    <Kutucuk baslik="✍ Banka bakiyesi gir — API'siz hesap, gün sonu" not="tutar + tarih + not · işlem günlüğüne yazılır">
      <div className="bm-form">
        <label>Hesap: <select value={hesapId} onChange={e => setHesapId(Number(e.target.value))}>
          {hesaplar.map(x => <option key={x.id} value={x.id}>{HESAP_IKON[x.tur] ?? ''} {x.ad}</option>)}</select></label>
        <label>Gün: <input type="date" value={gun} max={v.bugun} onChange={e => e.target.value && setGun(e.target.value)} /></label>
        <label>Gün sonu bakiyesi{h && h.doviz !== 'TL' ? ` (${h.doviz})` : ''}: <input value={tutar} onChange={e => setTutar(e.target.value)} placeholder="0,00" autoFocus /></label>
        <label>Kaynak: <select value={kaynak} onChange={e => setKaynak(Number(e.target.value))}>
          <option value={1}>Elle (banka ekranı / dekont)</option><option value={2}>Ekstre</option></select></label>
        <label>Not: <input value={aciklama} maxLength={300} onChange={e => setAciklama(e.target.value)} placeholder="ör. internet şubesi 18:10" style={{ minWidth: 220 }} /></label>
        <button type="button" disabled={mesgul} onClick={kaydet}>💾 Kaydet</button>
        <button type="button" disabled={mesgul} onClick={kapat}>Vazgeç</button>
        {hata && <span className="kir">{hata}</span>}
      </div>
      <div className="fi-ipucu">Hesap ve gün başına bir değer; değiştirince eski değer işlem günlüğünde kalır. Kredi kartında ekstre bakiyesini (borç eksi) girin.
        {ayniGun && h?.elle && <> Bu günün kaydı: {tl(h.elle.bakiye)} · {h.elle.giren} · {zamanT(h.elle.zaman)}.</>}
        {' '}O gün onaylıysa ve bakiye değişirse onay "bozuldu" olur.</div>
    </Kutucuk>
  );
}

// ========================================================================= A4 ===

function Tutanak({ v, h, antet, duzenleyen }: { v: Veri; h: MutabakatHesabi; antet: Record<string, unknown> | null; duzenleyen: string }) {
  const t = h.tablo;
  const p = (n: number | null | undefined) => para(h, n);
  return (
    <div className="hi-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>BANKA MUTABAKAT TUTANAĞI</h3>
      <div className="a4-hasta">
        <span>Mutabakat günü: <b>{gunT(v.gun)} (gün sonu)</b></span>
        <span>Hesap: {h.ad}{h.iban && ` · ${h.iban}`}</span>
        <span>Banka bakiyesi kaynağı: {KAYNAK_AD[h.kaynak]}{h.bakiyeZamani ? ` (${zamanT(h.bakiyeZamani)})` : ''}</span>
        <span>Hazırlayan: {h.hazirlayan ?? duzenleyen}</span>
        {h.onay && <span>Onay: {h.onay.durum === 'onayli' ? `${h.onay.onaylayan} · ${zamanT(h.onay.onayAn)}` : 'bozuldu - yeniden onay bekliyor'}</span>}
      </div>
      <table className="a4-t si-a4t">
        <thead><tr><th>Kalem</th><th>Tutar</th></tr></thead>
        <tbody>
          <tr><td>Banka bakiyesi</td><td>{p(t.banka)}</td></tr>
          {t.yoldaCikisAdet > 0 && <tr><td>− Sistemde var, bankaya düşmemiş çıkış ({t.yoldaCikisAdet})</td><td>{isaretli(t.yoldaCikis)}</td></tr>}
          {t.yoldaGirisAdet > 0 && <tr><td>+ Sistemde var, bankaya düşmemiş giriş ({t.yoldaGirisAdet})</td><td>{isaretli(t.yoldaGiris)}</td></tr>}
          <tr><td><b>Düzeltilmiş banka bakiyesi</b></td><td><b>{p(t.duzeltilmisBanka)}</b></td></tr>
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Sistem bakiyesi</td><td>{p(t.sistem)}</td></tr>
        {t.islenmemisGirisAdet + t.islenmemisCikisAdet > 0 &&
          <tr><td>+ Bankada var, işlenmemiş ({t.islenmemisGirisAdet + t.islenmemisCikisAdet}, net)</td><td>{isaretli(t.islenmemisGiris + t.islenmemisCikis)}</td></tr>}
        <tr><td>Düzeltilmiş sistem bakiyesi</td><td>{p(t.duzeltilmisSistem)}</td></tr>
        <tr className="kalan ki-kalan"><td>AÇIKLANMAYAN FARK</td><td>{t.aciklanmayan != null ? `${tl(t.aciklanmayan)} ${h.doviz === 'TL' ? '₺' : h.doviz}` : '—'}</td></tr>
      </tbody></table>
      {h.valorBekleyen ? <p className="a4-not">Valör bekleyen (bilgi, fark sayılmaz): {p(h.valorBekleyen)}</p> : null}
      <div className="a4-imza"><div>Hazırlayan<br />Ad Soyad · İmza</div><div>Mali İşler Müdürü<br />Kaşe · İmza</div></div>
      <p className="a4-not">Gentegre AI · Banka Mutabakat Tutanağı · tarih esası işlem tarihi · açıklama listeleri ekte (İşlenmemiş / Sistemde var, bankada yok)</p>
    </div>
  );
}

const BM_STILI = `
.hi-arac button.bm-birincil:not(:disabled) { border-color:#2f6db3; background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; font-weight:bold; }
.bm-bilgi { margin:6px 0; padding:6px 10px; background:#eef4fc; border:1px solid #cfe0f5; border-radius:4px; font-size:12px; color:#2c4a6b; }
.bm-kucuk { font-size:10.5px; white-space:normal; }
.bm-form { display:flex; gap:10px; flex-wrap:wrap; align-items:center; padding:8px 10px; font-size:12px; }
.bm-form input, .bm-form select { border:1px solid #cdd6e0; border-radius:3px; font-size:12px; padding:2px 4px; }
.bo-rz.mor { background:#f1ecfa; color:#6a3fb5; border-color:#ddd0f2; }
`;

export default BankaMutabakatIcmali;
