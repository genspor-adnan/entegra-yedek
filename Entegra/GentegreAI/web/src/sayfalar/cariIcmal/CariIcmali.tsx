import { EkstreIkon } from '../../bilesenler/EkstreIkon';
import { useCallback, useContext, useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CariIcmal as Veri, CariIcmalSatiri } from '../../api/uclar/cariIcmal';
import { para, paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { EkranSekmesiBaglami } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';
import { CariIcmalA4, MutabakatMektuplari } from './CariIcmalA4';
import { CariTablosu, DikkatSekmesi, KirilimSekmesi, YaslandirmaSekmesi } from './CariIcmalTablolari';

/**
 * CARİ İCMALİ `/cari-icmali` — mockup Ekranlar/İcmal/cari_icmali.html (kullanıcı 23.10.2026:
 * "müşteri ve/veya tedarikçi için icmal" → "tek ekran olsun" → "koda dök").
 *
 * Müşteri ve tedarikçi bakiyeleri tek ekranda: şeritte Müşteri / Tedarikçi / İkisi, dönem,
 * temsilci. Rakamlar SUNUCUDAN (CariIcmalUclari): devir / dönem / bakiye Kasa › Cari Ekstre
 * ile aynı kümeden, yaşlandırma FIFO. Satır tıkla / Ctrl / Shift seçimi A4 icmali ve
 * mutabakat mektuplarını süzer; çift tık cari ekstresini, ad cari kartını açar.
 */
type Sekme = 'cari' | 'yas' | 'kir' | 'dik';

const yilBasi = () => `${new Date().getFullYear()}-01-01`;
const kisa = (n: number) => (Math.abs(n) >= 1e6 ? `${(n / 1e6).toLocaleString('tr-TR', { maximumFractionDigits: 1 })} M` : paraYaz(n));

export function CariIcmali() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const bas = arama.get('bas') ?? yilBasi();
  const bit = arama.get('bit') ?? bugunYerel();
  const kapsam = arama.get('kapsam') ?? 'hepsi';
  const temsilci = Number(arama.get('temsilci') ?? 0);
  const pasif = arama.get('pasif') === '1';
  const [sifirGizle, setSifirGizle] = useState(true);
  const [veri, setVeri] = useState<Veri | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('cari');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [secili, setSecili] = useState<number[]>([]);

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0' && v !== 'hepsi') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
    setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata(''); setYukleniyor(true);
    const q = new URLSearchParams({ bas, bit, kapsam });
    if (temsilci) q.set('temsilci', String(temsilci));
    if (pasif) q.set('pasif', '1');
    api.cariIcmal(q).then(setVeri).catch(h => setHata(hataMetni(h))).finally(() => setYukleniyor(false));
  }, [bas, bit, kapsam, temsilci, pasif]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  // "Bakiyesi sıfır olanları gizle" yalnız GÖRÜNÜM süzgeci: dönemde hareketi olan cari kalır.
  const satirlar = useMemo(() => (veri?.carilar ?? []).filter(c => !sifirGizle
    || Math.abs(c.bakiye) > 0.005 || Math.abs(c.donemBorc) > 0.005 || Math.abs(c.donemAlacak) > 0.005), [veri, sifirGizle]);
  const seciliSatirlar = secili.length > 0 ? satirlar.filter(c => secili.includes(c.id)) : satirlar;
  // Mektup: seçili cariler; seçim yoksa bakiyesi olanlar.
  const mektupSatirlari = secili.length > 0 ? seciliSatirlar : satirlar.filter(c => Math.abs(c.bakiye) > 0.005);

  const o = veri?.ozet;
  // HBYS: yalnız tedarikçiler (sunucu kapsamı sabitler) - kapsam düğmeleri ve müşteri kutuları çizilmez.
  const yalnizTed = !!veri?.sadeceTedarikci;
  const baslik = yalnizTed ? 'Tedarikçi İcmali' : 'Cari İcmali';
  const ekstreAc = (c: CariIcmalSatiri) => git(`/ekstre?tur=cari&id=${c.id}`);
  // KART KENDİ SEKMESİNDE (kullanıcı 24.10.2026: "cari bazında müşteriye tıklayınca kartı modal açıyor,
  //   sekme olarak açsın"): `?geri=` kartı eski modal desenine düşürüyordu - kaldırıldı. Yalnız
  //   tedarikçi olan cari (HBYS'de hepsi) Tedarikçi kartında açılır.
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const kartAc = (id: number) => {
    const s = veri?.carilar.find(x => x.id === id);
    const yol = `${yalnizTed || (s && s.tedarikci && !s.musteri) ? '/tedarikci' : '/cari'}/${id}`;
    if (ekranSekmesi) ekranSekmesi.kartaGit(yol); else git(yol);
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const oran = (a: number, b: number) => (b > 0.005 ? `%${Math.round((100 * a) / b)}` : '—');
  const sekmeler: [Sekme, string, string | null][] = [
    ['cari', 'Cari Bazında', String(satirlar.length)], ['yas', 'Yaşlandırma', null], ['kir', 'Kırılımlar', null],
    ['dik', 'Dikkat', veri ? String(veri.dikkat.limit.length + veri.dikkat.tahsilatsiz.length + veri.dikkat.alacakli.length + veri.dikkat.odemeler.length) : null],
  ];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + CARI_ICMAL_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>{baslik}</h1><span className="yol">Finans › {baslik}</span></div>
      </div>

      <div className="hi-arac">
        <CiktiMenusu etiket={baslik} dosyaAdi={`${baslik} ${bas} ${bit}`} devre={!veri}>
          {veri && <CariIcmalA4 v={veri} satirlar={seciliSatirlar} antet={antet} duzenleyen={kullanici?.ad ?? ''} secimVar={secili.length > 0} />}
        </CiktiMenusu>
        <CiktiMenusu etiket="Mutabakat Mektubu" dosyaAdi={`Mutabakat ${bit}`} devre={!veri || mektupSatirlari.length === 0}>
          {veri && <MutabakatMektuplari v={veri} satirlar={mektupSatirlari} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
        </CiktiMenusu>
        <span className="ki-soluk">
          {secili.length > 0 ? `Çıktılar yalnız seçili ${secili.length} cariyi basar`
            : `Mektup: bakiyesi olan ${mektupSatirlari.length} cari (satır seçerek daraltın)`}</span>
        <span className="sp" />
        <button onClick={() => git(yalnizTed ? '/tedarikci' : '/cari')}>{yalnizTed ? '🚚 Tedarikçi Listesi' : '👥 Müşteri Listesi'}</button>
        <button onClick={() => git('/ekstre?tur=cari')}><EkstreIkon /> Ekstre</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="hi-serit">
        {!yalnizTed && <div className="ci-seg">
          {([['musteri', '👥 Müşteri'], ['tedarikci', '🚚 Tedarikçi'], ['hepsi', '⇄ İkisi']] as const).map(([k, ad]) => (
            <button key={k} type="button" className={kapsam === k ? 'on' : ''} onClick={() => degistir({ kapsam: k })}>{ad}</button>
          ))}
        </div>}
        <div className="sel">📅 Dönem:
          <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value })} /> –
          <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
        </div>
        <div className="sel">👤 Temsilci:
          <select value={temsilci} onChange={e => degistir({ temsilci: e.target.value })}>
            <option value={0}>Tümü</option>
            {(veri?.temsilciler ?? []).map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
          </select>
        </div>
        <label className="sel"><input type="checkbox" checked={sifirGizle} onChange={e => setSifirGizle(e.target.checked)} /> Bakiyesi ve hareketi olmayanları gizle</label>
        <label className="sel"><input type="checkbox" checked={pasif} onChange={e => degistir({ pasif: e.target.checked ? '1' : '' })} /> Pasifler dahil</label>
        <span className="sp" />
        {yukleniyor && <span className="ki-soluk">hesaplanıyor…</span>}
        {o && (o.vadesiGecenAlacak - o.vadesiGecenBorc) > 0.005 && <span className="bo-rz kir">Vadesi geçen net: {paraYaz(o.vadesiGecenAlacak - o.vadesiGecenBorc)}</span>}
      </div>

      {veri && o && (<>
        <div className="hi-ozet">
          {kutu('Alacağımız', kisa(o.alacak), `${o.alacakCari} borçlu cari`, 'iyi')}
          {kutu('Borcumuz', kisa(o.borc), `${o.borcCari} alacaklı cari`, 'teh')}
          {kutu('Net Pozisyon', `${o.net >= 0 ? '+' : '−'}${kisa(Math.abs(o.net))}`, 'alacak − borç', 'mor')}
          {kutu('Vadesi Geçen Alacak', kisa(o.vadesiGecenAlacak), `${o.vadesiGecenAlacakCari} cari · ort. ${o.vadesiGecenAlacakGun} gün`, o.vadesiGecenAlacak > 0.005 ? 'uy' : '')}
          {kutu('Vadesi Geçen Borç', kisa(o.vadesiGecenBorc), `${o.vadesiGecenBorcCari} cari · ort. ${o.vadesiGecenBorcGun} gün`, o.vadesiGecenBorc > 0.005 ? 'teh' : '')}
          {!yalnizTed && kutu('Dönem Satış / Tahsilat', `${kisa(o.satis)} / ${kisa(o.tahsilat)}`, `tahsil oranı ${oran(o.tahsilat, o.satis)} · KDV dahil`)}
          {kutu('Dönem Alış / Ödeme', `${kisa(o.alis)} / ${kisa(o.odeme)}`, `ödeme oranı ${oran(o.odeme, o.alis)}`)}
          {kutu('Çek / Senet', `${kisa(o.cekAlinan)} / ${kisa(o.cekVerilen)}`, `${o.cekAlinanAdet} alınan · ${o.cekVerilenAdet} verilen`)}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {sekmeler.map(([k, ad, n]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{n != null && <span className="b">{n}</span>}
                </div>
              ))}
            </div>
            {sekme === 'cari' && <>
              <CariTablosu satirlar={satirlar} secili={secili} setSecili={setSecili} kartAc={kartAc} ekstreAc={ekstreAc} />
              <div className="ki-soluk ci-not">
                Hem müşteri hem tedarikçi olan cari tek satırdır: borç bakiyesi varsa Müşteriler, alacak bakiyesi varsa Tedarikçiler grubunda.
                Tutarlar hareketin kendi kuruyla TL karşılığı; satırın ▸ işareti kendi para birimini ve yaşlandırmayı açar.
                Personel cari hesapları kapsam dışı. Toplam bakiye: {para.format(satirlar.reduce((s, c) => s + c.bakiye, 0))}
              </div>
            </>}
            {sekme === 'yas' && <YaslandirmaSekmesi v={veri} />}
            {sekme === 'kir' && <KirilimSekmesi v={veri} />}
            {sekme === 'dik' && <DikkatSekmesi v={veri} kartAc={kartAc} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

/** Cari icmaline özgü: kapsam düğmeleri, grup / ara toplam satırları, iki sütunlu kutular, A4. */
const CARI_ICMAL_STILI = `
.hi-serit select, .hi-serit input[type=date] { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.ci-seg { display:flex; border:1px solid #cdd6e0; border-radius:13px; overflow:hidden; background:#fff; }
.ci-seg button { border:0; border-right:1px solid #e3e9f0; background:none; padding:4px 12px; font-size:12px; color:#4d5d6e; cursor:pointer; }
.ci-seg button:last-child { border-right:0; }
.ci-seg button.on { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; font-weight:bold; }
.hi-tablo tr.ci-grup td { background:#f1f5fa; font-weight:bold; color:#2c4a6b; }
.hi-tablo tr.ci-ara td { background:#f7f9fc; font-weight:bold; border-top:1px solid #cdd6e0; }
.hi-tablo tr.ci-pasif td { color:#9aa7b4; }
.hi-tablo .ci-yesil, .ci-yesil { color:#2e7d46; }
.ci-tablo td .ok { cursor:pointer; margin-right:4px; }
.ci-not { margin:8px 2px; font-size:11px; line-height:1.6; }
.ci-iki { display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:12px; }
.ci-kutu { border:1px solid #e3e9f0; border-radius:4px; overflow:hidden; background:#fff; margin-bottom:12px; }
.ci-iki .ci-kutu { margin-bottom:0; }
.ci-kutu h4 { margin:0; padding:7px 10px; font-size:12px; background:linear-gradient(#f6f9fc,#eef3f9); border-bottom:1px solid #e3e9f0; color:#2c4a6b; display:flex; gap:8px; }
.ci-kutu h4 span { margin-left:auto; font-weight:normal; font-size:11px; color:#6b7a8b; }
.ci-cubuk { display:flex; height:14px; margin:8px 10px; border-radius:3px; overflow:hidden; background:#e7edf4; }
.ci-cubuk i { display:block; height:100%; }
.ci-nokta { display:inline-block; width:10px; height:10px; border-radius:2px; margin-right:6px; vertical-align:-1px; }
.a4-t.ci-a4t tr.ci-a4grup td { font-weight:bold; background:#eef2f7; }
.a4-t.ci-a4t tr.ci-a4top td { font-weight:bold; border-top:1px solid #333; }
.a4-t.ci-a4t tr.ci-a4top td:nth-child(n+2) { text-align:right; }
.a4-t.ci-a4t td:nth-child(n+3), .a4-t.ci-a4t th:nth-child(n+3) { text-align:right; }
.ci-mektup p { margin:8px 0; line-height:1.5; }
.ci-mektup + .ci-mektup { break-before:page; page-break-before:always; margin-top:14px; }
@media (max-width: 1000px) { .ci-iki { grid-template-columns:1fr; } }
`;

export default CariIcmali;
