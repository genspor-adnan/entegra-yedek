import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { GunSonu } from '../../api/uclar/kasaGunSonu';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { farkRozeti, tutarCoz } from './kasaGunSonuOrtak';

/**
 * Kasa gün sonu sekme tabloları. Rakamlar sunucudan; giriş alanları (sayım,
 * POS gün sonu, banka ekstresi, fark açıklaması) kapalı günde görünmez.
 */

const p = (n: number) => para.format(n);
const tire = (n: number | null | undefined) => (n == null || Math.abs(n) < 0.005 ? '—' : p(n));
const saat = (iso: string) => new Date(iso).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });

/** Satır içi tutar girişi: Enter / Kaydet ile gönderir. */
function TutarGir({ ilk, kaydet, yer = 'tutar' }: { ilk?: number | null; kaydet(n: number | null): Promise<unknown>; yer?: string }) {
  const [m, setM] = useState(ilk == null ? '' : String(ilk).replace('.', ','));
  const [gidiyor, setGidiyor] = useState(false);
  const gonder = async () => { setGidiyor(true); try { await kaydet(tutarCoz(m)) } finally { setGidiyor(false) } };
  return (
    <span className="gs-gir" onClick={e => e.stopPropagation()}>
      <input value={m} placeholder={yer} onChange={e => setM(e.target.value)} onKeyDown={e => { if (e.key === 'Enter') void gonder() }} />
      <button type="button" disabled={gidiyor} onClick={() => void gonder()}>Kaydet</button>
    </span>
  );
}

export function KasaTablosu({ v, secili, setSecili, acik, sayimKaydet }: {
  v: GunSonu; secili: number[]; setSecili(s: number[]): void; acik: boolean;
  sayimKaydet(hesapId: number, n: number | null): Promise<unknown>;
}) {
  const son = useRef<number | null>(null);
  const [acilan, setAcilan] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.kasalar.map(k => k.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcilan(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.kasalar.length > 0 && v.kasalar.every(k => secili.includes(k.id));
  const t = v.kasalar.reduce((a, k) => ({ devir: a.devir + k.devir, giris: a.giris + k.giris, cikis: a.cikis + k.cikis, transfer: a.transfer + k.transfer,
    beklenen: a.beklenen + k.beklenen }), { devir: 0, giris: 0, cikis: 0, transfer: 0, beklenen: 0 });
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.kasalar.map(k => k.id))} /></th>
          <th>Kasa</th><th className="sag">Açılış</th><th className="sag">Giriş</th><th className="sag">Çıkış</th><th className="sag">Transfer</th>
          <th className="sag">Beklenen</th><th className="sag">Sayılan</th><th>Fark</th><th>Sorumlu</th><th>Oturum / Sayım</th></tr></thead>
        <tbody>
          {v.kasalar.length === 0 && <tr><td colSpan={11} className="bos">Bu gün kasa hareketi yok.</td></tr>}
          {v.kasalar.map(k => {
            const sec = secili.includes(k.id); const f = farkRozeti(k.fark, p);
            return (
              <Fragment key={k.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(k.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(k.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(k.id, e)}>{acilan.includes(k.id) ? '▾' : '▸'}</a> <b>{k.ad}</b>
                    <span className="ki-soluk"> {k.kod}</span>{k.banko && <span className="bo-rz mavi lb-k">banko</span>}</td>
                  <td className="sag">{p(k.devir)}</td><td className="sag">{tire(k.giris)}</td><td className="sag">{tire(k.cikis)}</td>
                  <td className="sag">{tire(k.transfer)}</td><td className="sag"><b>{p(k.beklenen)}</b></td>
                  <td className="sag">{!k.banko && acik ? <TutarGir ilk={k.sayilan} yer="sayılan" kaydet={n => sayimKaydet(k.id, n)} />
                    : k.sayilan != null ? p(k.sayilan) : '—'}</td>
                  <td><span className={'bo-rz ' + f.renk}>{f.ad}</span></td><td>{k.sorumlu || '—'}</td>
                  <td><span className={'bo-rz ' + (k.acik ? 'sari' : k.sayilan != null ? 'ok' : k.sayimGerekli ? 'kir' : 'pas')}>{k.durum}</span></td>
                </tr>
                {acilan.includes(k.id) && (
                  <tr className="lb-alt"><td /><td colSpan={10}>{k.kirilim.length ? k.kirilim.map(x => `${x.ad} ${x.adet} · ${p(x.tutar)}`).join('  |  ') : 'Bu gün hareket yok'}</td></tr>
                )}
              </Fragment>
            );
          })}
          {v.kasalar.length > 0 && (
            <tr className="top"><td /><td>Toplam · {v.kasalar.length} kasa</td><td className="sag">{p(t.devir)}</td><td className="sag">{p(t.giris)}</td>
              <td className="sag">{p(t.cikis)}</td><td className="sag">{p(t.transfer)}</td><td className="sag">{p(t.beklenen)}</td>
              <td className="sag">{p(v.ozet.sayilan)}</td><td>{farkRozeti(v.ozet.sayilanAdet ? v.ozet.kasaFark : null, p).ad}</td><td colSpan={2} /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Beklenen = açılış + giriş − çıkış + transfer (virman ve bankaya yatırılan). Sayılan: bankolarda oturum kapanışında
        kasada bırakılan (sayım − teslim), öteki kasalarda burada girilen sayım. Fark = sayılan − beklenen; sayılmayan kasa farka girmez.</div>
    </>
  );
}

export function PosTablosu({ v, acik, posKaydet }: { v: GunSonu; acik: boolean; posKaydet(hesapId: number, n: number | null): Promise<unknown> }) {
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>POS Hesabı</th><th>Terminal / Banko</th><th className="sag">Sistem Adet</th><th className="sag">Sistem Tutar</th>
          <th className="sag">Gün Sonu (Batch)</th><th>Kaynak</th><th>Fark</th><th>Durum</th></tr></thead>
        <tbody>
          {v.poslar.length === 0 && <tr><td colSpan={8} className="bos">Bu gün POS tahsilatı yok.</td></tr>}
          {v.poslar.map(x => {
            const f = farkRozeti(x.fark, p);
            return (
              <tr key={x.id}><td><b>{x.ad}</b></td><td>{x.terminal ? `T ${x.terminal}` : '—'}{x.banko && <span className="ki-soluk"> · {x.banko}</span>}</td>
                <td className="sag">{x.adet}</td><td className="sag">{p(x.sistem)}</td>
                <td className="sag">{acik ? <TutarGir ilk={x.kaynak === 'elle' ? x.batch : null} yer={x.batch != null ? p(x.batch) : 'batch tutarı'}
                                                   kaydet={n => posKaydet(x.id, n)} /> : x.batch != null ? p(x.batch) : '—'}</td>
                <td>{x.kaynak === 'elle' ? 'elle girildi' : x.kaynak === 'oturum' ? 'banko kapanışı' : '—'}</td>
                <td>{x.batch != null ? <span className={'bo-rz ' + f.renk}>{f.ad}</span> : '—'}</td>
                <td><span className={'bo-rz ' + (x.durum === 'Eşleşti' ? 'ok' : x.durum === 'Fark var' ? 'kir' : 'sari')}>{x.durum}</span></td></tr>
            );
          })}
          {v.poslar.length > 0 && (
            <tr className="top"><td colSpan={2}>Toplam · {v.poslar.length} POS</td><td className="sag">{v.ozet.posAdet}</td><td className="sag">{p(v.ozet.pos)}</td>
              <td className="sag">{p(v.ozet.posBatch)}</td><td /><td>{tire(v.ozet.posFark)}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Sistem = günün POS tahsilatları (tür 25). Gün sonu (batch) toplamı banko oturumu kapanışında girilen cihaz toplamından gelir;
        oturumsuz POS için burada elle girilir (girilen değer geçerlidir, boş bırakıp kaydetmek elle girişi siler). İşlem düzeyinde batch içe aktarma ve
        eşleşmeyen işlem listesi bu sürümde yok.</div>
    </>
  );
}

export function BankaTablosu({ v, acik, bankaKaydet }: {
  v: GunSonu; acik: boolean; bankaKaydet(hesapId: number, yatis: number | null, havale: number | null): Promise<unknown>;
}) {
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Banka Hesabı</th><th className="sag">Yatış · Beklenen</th><th className="sag">Yatış · Ekstre</th>
          <th className="sag">Havale Adet</th><th className="sag">Havale · Sistem</th><th className="sag">Havale · Ekstre</th><th>Fark</th><th>Durum</th></tr></thead>
        <tbody>
          {v.bankalar.length === 0 && <tr><td colSpan={8} className="bos">Bu gün banka hareketi yok.</td></tr>}
          {v.bankalar.map(x => (
            <tr key={x.id}><td><b>{x.ad}</b>{x.iban && <div className="ki-soluk">{x.iban}</div>}</td>
              <td className="sag">{tire(x.yatisBeklenen)}</td>
              <td className="sag">{acik ? <TutarGir ilk={x.yatisGerceklesen} yer="ekstre" kaydet={n => bankaKaydet(x.id, n, x.havaleEkstre ?? null)} />
                                        : tire(x.yatisGerceklesen)}</td>
              <td className="sag">{x.havaleAdet}</td><td className="sag">{tire(x.havaleSistem)}</td>
              <td className="sag">{acik ? <TutarGir ilk={x.havaleEkstre} yer="ekstre" kaydet={n => bankaKaydet(x.id, x.yatisGerceklesen ?? null, n)} />
                                        : tire(x.havaleEkstre)}</td>
              <td>{x.fark != null ? <span className={'bo-rz ' + farkRozeti(x.fark, p).renk}>{farkRozeti(x.fark, p).ad}</span> : '—'}</td>
              <td><span className={'bo-rz ' + (x.durum === 'Eşleşti' ? 'ok' : x.durum === 'Ekstre girilmedi' ? 'pas' : 'sari')}>{x.durum}</span></td></tr>
          ))}
        </tbody>
      </table>
      <div className="ki-not">Beklenen yatış = kasadan bankaya (tür 41); havale sistem = banka tahsilatı (tür 22). Ekstre rakamı elle girilir (içe aktarma
        bu sürümde yok). POS tahsilatı bankaya valörle geçer, burada değil. Banka farkı günü kapatmaya engel değildir.</div>
    </>
  );
}

export function HareketTablosu({ v, seciliAdlar }: { v: GunSonu; seciliAdlar: string[] }) {
  const liste = seciliAdlar.length ? v.hareketler.filter(h => seciliAdlar.includes(h.hesap)) : v.hareketler;
  return (
    <table className="hi-tablo">
      <thead><tr><th>Saat</th><th>Kasa / Hesap</th><th>Tür</th><th>Yön</th><th>Protokol No / Açıklama</th><th className="sag">Tutar</th><th>Kullanıcı</th></tr></thead>
      <tbody>
        {liste.length === 0 && <tr><td colSpan={7} className="bos">Hareket yok.</td></tr>}
        {liste.map((h, i) => (
          <tr key={i}><td>{saat(h.zaman)}</td><td>{h.hesap}</td><td>{h.turAdi} ({h.tur})</td>
            <td>{h.tutar >= 0 ? 'Giriş' : 'Çıkış'}</td><td>{[h.belgeNo, h.aciklama].filter(Boolean).join(' · ') || '—'}</td>
            <td className={'sag' + (h.tutar < 0 ? ' kir' : '')}>{p(h.tutar)}</td><td>{h.kullanici || '—'}</td></tr>
        ))}
        {liste.length > 0 && <tr className="top"><td colSpan={5}>{liste.length} hareket (iptal edilenler hariç)</td>
          <td className="sag">{p(liste.reduce((t, h) => t + h.tutar, 0))}</td><td /></tr>}
      </tbody>
    </table>
  );
}

export function FarkTablosu({ v, acik, farkKaydet }: {
  v: GunSonu; acik: boolean; farkKaydet(kalem: string, fark: number, neden: number, aciklama: string): Promise<unknown>;
}) {
  const [taslak, setTaslak] = useState<Record<string, { neden: number; aciklama: string }>>({});
  const bekleyen = v.farklar.filter(f => f.engel && !f.aciklama).length;
  return (
    <>
      {v.engeller.length > 0 && (
        <div className="gs-engel"><b>Gün kapatılamaz — {v.engeller.length} engel:</b>
          <ul>{v.engeller.map((e, i) => <li key={i}>{e}</li>)}</ul></div>
      )}
      <table className="hi-tablo">
        <thead><tr><th>Kalem</th><th className="sag">Fark</th><th>Sorumlu</th><th>Neden</th><th>Açıklama</th><th>Durum</th></tr></thead>
        <tbody>
          {v.farklar.length === 0 && <tr><td colSpan={6} className="bos">Fark yok.</td></tr>}
          {v.farklar.map(f => {
            const t = taslak[f.kalem] ?? { neden: f.aciklama?.neden ?? 0, aciklama: f.aciklama?.aciklama ?? '' };
            const set = (d: Partial<typeof t>) => setTaslak(s => ({ ...s, [f.kalem]: { ...t, ...d } }));
            return (
              <tr key={f.kalem}><td>{f.tur} · {f.ad}</td><td className={'sag ' + (f.fark < 0 ? 'kir' : '')}>{p(f.fark)}</td><td>{f.sorumlu || '—'}</td>
                <td>{acik ? <select value={t.neden} onChange={e => set({ neden: Number(e.target.value) })}>
                  <option value={0}>— seçiniz</option>{v.nedenler.map(n => <option key={n.kod} value={n.kod}>{n.ad}</option>)}</select>
                  : f.aciklama?.nedenAd ?? '—'}</td>
                <td>{acik ? <span className="gs-gir"><input value={t.aciklama} onChange={e => set({ aciklama: e.target.value })} placeholder="açıklama" />
                  <button type="button" disabled={!t.neden} onClick={() => void farkKaydet(f.kalem, f.fark, t.neden, t.aciklama)}>Kaydet</button></span>
                  : f.aciklama?.aciklama || '—'}</td>
                <td><span className={'bo-rz ' + (f.aciklama ? 'ok' : f.engel ? 'kir' : 'pas')}>{f.aciklama ? 'Açıklandı' : f.engel ? 'Açıklama bekliyor' : 'Bilgi (engel değil)'}</span></td></tr>
            );
          })}
          {v.farklar.length > 0 && (
            <tr className="top"><td>{v.farklar.length} fark</td><td className="sag">{p(v.farklar.reduce((t, f) => t + f.fark, 0))}</td>
              <td colSpan={4}>{bekleyen ? `${bekleyen} açıklama bekliyor` : 'hepsi açıklandı'}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Kasa ve POS farkının nedeni ve açıklaması girilmeden gün kapanmaz; banka farkı yalnız bilgidir. Kapalı güne kasa işlemi
        yazılamaz; günü yalnız yetkili kişi gerekçeyle açar.</div>
    </>
  );
}
