import { Fragment, useMemo, useRef, useState, type MouseEvent, type ReactNode } from 'react';
import type { BorcIslemi, Borclu } from '../../api/uclar/hastaBorc';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { ISLEM_ADI, KANAL_ADI, durumRozeti, islemSonucu } from './borcOrtak';

/** Hasta borç takibinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);

/**
 * KOLON SIRALAMA (kullanıcı 19.11.2026: "hasta borç takibi listesinde grid kolonlara sıralama özelliği ekle"):
 * başlığa tık artan, ikinci tık azalan, üçüncü tık varsayılan sıraya döner. Metin Türkçe kurala göre, sayı / tarih
 * sayısal; boş değer her yönde sonda.
 */
type Anahtar<T> = (x: T) => string | number | null | undefined;
function useSiralama<T>(liste: T[], anahtarlar: Record<string, Anahtar<T>>) {
  const [sira, setSira] = useState<{ alan: string; yon: 1 | -1 } | null>(null);
  const sirali = useMemo(() => {
    if (!sira || !anahtarlar[sira.alan]) return liste;
    const k = anahtarlar[sira.alan];
    return [...liste].sort((a, b) => {
      const x = k(a), y = k(b);
      const xb = x == null || x === '', yb = y == null || y === '';
      if (xb || yb) return xb === yb ? 0 : xb ? 1 : -1;
      const f = typeof x === 'number' && typeof y === 'number' ? x - y : String(x).localeCompare(String(y), 'tr', { numeric: true });
      return f * sira.yon;
    });
    // anahtarlar her çizimde yeni nesne - sıralamayı yalnız liste / seçim değiştirir.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [liste, sira]);
  const baslik = (alan: string, metin: ReactNode, sinif?: string) => (
    <th className={['sirala', sinif ?? ''].filter(Boolean).join(' ')} title="Sırala"
        onClick={() => setSira(s => (s?.alan !== alan ? { alan, yon: 1 } : s.yon === 1 ? { alan, yon: -1 } : null))}>
      {metin}<span className="sirala-ok">{sira?.alan === alan ? (sira.yon === 1 ? ' ▲' : ' ▼') : ''}</span>
    </th>
  );
  return { sirali, baslik };
}
const zaman = (g?: string | null) => (g ? new Date(g).getTime() : null);

/**
 * BORÇLULAR - tık tek hasta, Ctrl / Shift çoklu seçer (listeSecimi); seçim
 * hatırlatma / işaret / mektup içindir. ▸ işareti açık protokolleri açar.
 */
export function BorcluTablosu({ liste, secili, setSecili, hastaAc }: {
  liste: Borclu[]; secili: number[]; setSecili(s: number[]): void; hastaAc(id: number): void;
}) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const { sirali, baslik } = useSiralama(liste, {
    ad: b => b.ad, dosya: b => b.dosyaNo, tel: b => b.telefon, basvuru: b => zaman(b.sonBasvuru),
    protokol: b => b.acikProtokol, borc: b => b.borc, gun: b => b.gun, tahsilat: b => zaman(b.sonTahsilat),
    hatirlatma: b => zaman(b.sonHatirlatma), soz: b => (b.soz ? zaman(b.soz.sonrakiVade ?? b.soz.vade) : null),
    durum: b => durumRozeti(b.durum).ad,
  });
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    // Shift aralığı EKRANDAKİ (sıralı) düzene göre.
    setSecili(secimUygula(secili, id, sirali.map(b => b.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = liste.length > 0 && liste.every(b => secili.includes(b.id));
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : liste.map(b => b.id))} /></th>
        {baslik('ad', 'Hasta')}{baslik('dosya', 'Dosya No')}{baslik('tel', 'Telefon')}{baslik('basvuru', 'Son Başvuru')}
        {baslik('protokol', 'Protokol', 'sag')}{baslik('borc', 'Açık Borç', 'sag')}{baslik('gun', 'Gün', 'sag')}
        {baslik('tahsilat', 'Son Tahsilat')}{baslik('hatirlatma', 'Son Hatırlatma')}{baslik('soz', 'Söz / Plan')}
        {baslik('durum', 'Durum')}</tr></thead>
      <tbody>
        {liste.length === 0 && <tr><td colSpan={12} className="bos">Bu süzgeçte borçlu hasta yok.</td></tr>}
        {sirali.map(b => {
          const r = durumRozeti(b.durum);
          const sec = secili.includes(b.id);
          const ac = acik.includes(b.id);
          return (
            <Fragment key={b.id}>
              <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(b.id, e)}
                  title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(b.id, e)} /></td>
                <td><span className="ok" title="Açık protokoller" onClick={e => { e.stopPropagation(); setAcik(a => (ac ? a.filter(x => x !== b.id) : [...a, b.id])) }}>
                  {ac ? '▾' : '▸'}</span>
                  <a className="ki-lnk" title="Hasta icmalini aç" onClick={e => { e.stopPropagation(); hastaAc(b.id) }}>{b.ad}</a></td>
                <td>{b.dosyaNo || '—'}</td>
                <td>{b.telefon || <span className="ki-soluk">yok</span>}{b.epostaVar && <span className="ki-soluk" title="E-posta var"> ✉</span>}</td>
                <td>{tarihKisa(b.sonBasvuru)}</td><td className="sag">{b.acikProtokol}</td>
                <td className="sag"><b>{p(b.borc)}</b></td>
                <td className={'sag' + (b.gun > 30 ? ' kir' : '')}>{b.gun}</td>
                <td>{b.sonTahsilat ? tarihKisa(b.sonTahsilat) : '—'}</td>
                <td>{b.sonHatirlatma ? `${tarihKisa(b.sonHatirlatma)} · ${KANAL_ADI[b.sonHatirlatmaKanal ?? 0] ?? ''}` : '—'}</td>
                <td>{b.soz ? `${b.soz.tur === 3 ? `Plan ${b.soz.odenenTaksit ?? 0}/${b.soz.taksitSayisi} taksit` : 'Söz'} · `
                  + `${b.soz.durum === 'tutuldu' ? 'tutuldu ✓' : `kalan ${p(b.soz.kalan ?? b.soz.tutar ?? 0)}`} · ${tarihKisa(b.soz.vade)}` : '—'}</td>
                <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
              </tr>
              {ac && (
                <tr className="det"><td colSpan={12}>
                  {b.protokoller.map(x => `${x.protokolNo} · ${tarihKisa(x.tarih)} · ${x.bolum || '—'} · hasta payı ${p(x.hastaPayi)} · tahsil ${p(x.tahsil)} · kalan ${p(x.kalan)} (${x.gun} gün)`).join('   |   ')}
                </td></tr>
              )}
            </Fragment>
          );
        })}
      </tbody>
    </table>
  );
}

export function GecmisTablosu({ islemler, kaldir }: { islemler: BorcIslemi[]; kaldir(id: number): void }) {
  const { sirali, baslik } = useSiralama(islemler, {
    zaman: i => zaman(i.zaman), hasta: i => i.hasta, islem: i => ISLEM_ADI[i.tur] ?? String(i.tur),
    kanal: i => (i.kanal ? KANAL_ADI[i.kanal] : null), tutar: i => i.tutar ?? null, vade: i => zaman(i.vade),
    aciklama: i => i.aciklama, yapan: i => i.ekleyen, sonuc: i => islemSonucu(i).ad,
  });
  return (
    <table className="hi-tablo">
      <thead><tr>{baslik('zaman', 'Zaman')}{baslik('hasta', 'Hasta')}{baslik('islem', 'İşlem')}{baslik('kanal', 'Kanal')}
        {baslik('tutar', 'Tutar', 'sag')}{baslik('vade', 'Vade')}{baslik('aciklama', 'Açıklama')}{baslik('yapan', 'Yapan')}
        {baslik('sonuc', 'Sonuç')}<th /></tr></thead>
      <tbody>
        {islemler.length === 0 && <tr><td colSpan={10} className="bos">Henüz hatırlatma / söz kaydı yok.</td></tr>}
        {sirali.map(i => {
          const r = islemSonucu(i);
          return (
            <tr key={i.id} className={i.durum === 9 ? 'iptal' : ''}>
              <td>{new Date(i.zaman).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' })}</td>
              <td>{i.hasta}</td><td>{ISLEM_ADI[i.tur] ?? i.tur}{i.tur === 3 && i.taksitSayisi ? ` · ${i.taksitSayisi} taksit` : ''}</td>
              <td>{i.kanal ? KANAL_ADI[i.kanal] : '—'}</td>
              <td className="sag">{i.tutar != null ? p(i.tutar) : '—'}</td><td>{i.vade ? tarihKisa(i.vade) : '—'}</td>
              <td>{i.aciklama || '—'}</td><td>{i.ekleyen || '—'}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
              <td>{i.tur !== 1 && i.durum === 0 && <a className="ki-lnk" onClick={() => kaldir(i.id)}>kaldır</a>}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}

/** ÖDEME SÖZLERİ / PLANLARI: geçerli söz ve planlar, tutulmayanlar üstte. */
export function SozTablosu({ liste, kaldir }: { liste: Borclu[]; kaldir(id: number): void }) {
  // Sıra: tutulmayan, bekleyen, tutulan (19.11.2026: söz sonrası tahsilatla değerlendirilir).
  const sira = (d?: string) => d === 'tutulmadi' ? 0 : d === 'bekliyor' ? 1 : 2;
  const sozluHam = useMemo(() => liste.filter(b => b.soz).sort((a, b) => sira(a.soz!.durum) - sira(b.soz!.durum)), [liste]);
  const { sirali: sozlu, baslik } = useSiralama(sozluHam, {
    ad: b => b.ad, tur: b => b.soz!.tur, tutar: b => b.soz!.tutar ?? null, odenen: b => b.soz!.odenen ?? 0,
    kalan: b => b.soz!.kalan ?? b.soz!.tutar ?? null, vade: b => zaman(b.soz!.sonrakiVade ?? b.soz!.vade),
    taksit: b => b.soz!.taksitSayisi ?? null, borc: b => b.borc, durum: b => sira(b.soz!.durum),
  });
  return (
    <table className="hi-tablo">
      <thead><tr>{baslik('ad', 'Hasta')}{baslik('tur', 'Tür')}{baslik('tutar', 'Tutar', 'sag')}{baslik('odenen', 'Ödenen', 'sag')}
        {baslik('kalan', 'Kalan', 'sag')}{baslik('vade', 'Vade / Sonraki')}{baslik('taksit', 'Taksit', 'sag')}
        {baslik('borc', 'Açık Borç', 'sag')}{baslik('durum', 'Durum')}<th /></tr></thead>
      <tbody>
        {sozlu.length === 0 && <tr><td colSpan={10} className="bos">Geçerli ödeme sözü / planı yok.</td></tr>}
        {sozlu.map(b => (
          <tr key={b.id}><td>{b.ad}</td><td>{b.soz!.tur === 3 ? 'Ödeme planı' : 'Ödeme sözü'}</td>
            <td className="sag">{p(b.soz!.tutar ?? 0)}</td><td className="sag">{p(b.soz!.odenen ?? 0)}</td>
            <td className="sag">{p(b.soz!.kalan ?? b.soz!.tutar ?? 0)}</td>
            <td>{tarihKisa(b.soz!.sonrakiVade ?? b.soz!.vade)}</td>
            <td className="sag">{b.soz!.tur === 3 ? `${b.soz!.odenenTaksit ?? 0}/${b.soz!.taksitSayisi ?? '—'}` : '—'}</td><td className="sag">{p(b.borc)}</td>
            <td><span className={'bo-rz ' + (b.soz!.durum === 'tutulmadi' ? 'kir' : b.soz!.durum === 'tutuldu' ? 'ok' : 'mavi')}>
              {b.soz!.durum === 'tutulmadi'
                ? (b.soz!.tur === 3 ? `${b.soz!.gecikenTaksit ?? 1} taksit gecikti` : 'Tutulmadı (vade geçti)')
                : b.soz!.durum === 'tutuldu' ? 'Tutuldu ✓' : 'Bekliyor'}</span></td>
            <td><a className="ki-lnk" onClick={() => kaldir(b.soz!.id)}>kaldır</a></td></tr>
        ))}
      </tbody>
    </table>
  );
}
