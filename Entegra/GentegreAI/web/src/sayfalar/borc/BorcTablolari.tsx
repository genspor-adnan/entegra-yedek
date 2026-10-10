import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { BorcIslemi, Borclu } from '../../api/uclar/hastaBorc';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { ISLEM_ADI, KANAL_ADI, durumRozeti, islemSonucu } from './borcOrtak';

/** Hasta borç takibinin sekme tabloları. Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);

/**
 * BORÇLULAR - tık tek hasta, Ctrl / Shift çoklu seçer (listeSecimi); seçim
 * hatırlatma / işaret / mektup içindir. ▸ işareti açık protokolleri açar.
 */
export function BorcluTablosu({ liste, secili, setSecili, hastaAc }: {
  liste: Borclu[]; secili: number[]; setSecili(s: number[]): void; hastaAc(id: number): void;
}) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, liste.map(b => b.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = liste.length > 0 && liste.every(b => secili.includes(b.id));
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : liste.map(b => b.id))} /></th>
        <th>Hasta</th><th>Dosya No</th><th>Telefon</th><th>Son Başvuru</th><th className="sag">Protokol</th>
        <th className="sag">Açık Borç</th><th className="sag">Gün</th><th>Son Tahsilat</th><th>Son Hatırlatma</th>
        <th>Söz / Plan</th><th>Durum</th></tr></thead>
      <tbody>
        {liste.length === 0 && <tr><td colSpan={12} className="bos">Bu süzgeçte borçlu hasta yok.</td></tr>}
        {liste.map(b => {
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
                <td>{b.soz ? `${b.soz.tur === 3 ? `Plan ${b.soz.taksitSayisi} taksit` : 'Söz'} · ${p(b.soz.tutar ?? 0)} · ${tarihKisa(b.soz.vade)}` : '—'}</td>
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
  return (
    <table className="hi-tablo">
      <thead><tr><th>Zaman</th><th>Hasta</th><th>İşlem</th><th>Kanal</th><th className="sag">Tutar</th><th>Vade</th>
        <th>Açıklama</th><th>Yapan</th><th>Sonuç</th><th /></tr></thead>
      <tbody>
        {islemler.length === 0 && <tr><td colSpan={10} className="bos">Henüz hatırlatma / söz kaydı yok.</td></tr>}
        {islemler.map(i => {
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
  const sozlu = liste.filter(b => b.soz).sort((a, b) => (a.soz!.durum === 'tutulmadi' ? -1 : 0) - (b.soz!.durum === 'tutulmadi' ? -1 : 0));
  return (
    <table className="hi-tablo">
      <thead><tr><th>Hasta</th><th>Tür</th><th className="sag">Tutar</th><th>Vade / İlk Taksit</th><th className="sag">Taksit</th>
        <th className="sag">Açık Borç</th><th>Durum</th><th /></tr></thead>
      <tbody>
        {sozlu.length === 0 && <tr><td colSpan={8} className="bos">Geçerli ödeme sözü / planı yok.</td></tr>}
        {sozlu.map(b => (
          <tr key={b.id}><td>{b.ad}</td><td>{b.soz!.tur === 3 ? 'Ödeme planı' : 'Ödeme sözü'}</td>
            <td className="sag">{p(b.soz!.tutar ?? 0)}</td><td>{tarihKisa(b.soz!.vade)}</td>
            <td className="sag">{b.soz!.taksitSayisi ?? '—'}</td><td className="sag">{p(b.borc)}</td>
            <td><span className={'bo-rz ' + (b.soz!.durum === 'tutulmadi' ? 'kir' : 'mavi')}>{b.soz!.durum === 'tutulmadi' ? 'Tutulmadı (vade geçti)' : 'Bekliyor'}</span></td>
            <td><a className="ki-lnk" onClick={() => kaldir(b.soz!.id)}>kaldır</a></td></tr>
        ))}
      </tbody>
    </table>
  );
}
