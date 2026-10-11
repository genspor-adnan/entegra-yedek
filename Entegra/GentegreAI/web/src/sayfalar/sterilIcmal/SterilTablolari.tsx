import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { SterilIcmali } from '../../api/uclar/sterilIcmal';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { dolulukRozeti, omurRozeti, yuzde } from './sterilIcmalOrtak';

/** Sterilizasyon icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}
const tire = (n: number) => (n ? String(n) : '—');

/** CİHAZLAR - tık tek, Ctrl / Shift çoklu; ▸ program dağılımı; seçilenler A4'ü süzer. */
export function CihazTablosu({ v, secili, setSecili }: { v: SterilIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.cihazlar.map(c => c.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.cihazlar.length > 0 && v.cihazlar.every(c => secili.includes(c.id));
  const t = v.cihazlar.reduce((a, c) => ({ dongu: a.dongu + c.dongu, serbest: a.serbest + c.serbest, karantina: a.karantina + c.karantina,
    basarisiz: a.basarisiz + c.basarisiz, test: a.test + c.test }), { dongu: 0, serbest: 0, karantina: 0, basarisiz: 0, test: 0 });
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.cihazlar.map(c => c.id))} /></th>
          <th>Cihaz</th><th>Tür</th><th className="sag">Döngü</th><th className="sag">Serbest</th><th className="sag">Karantina</th>
          <th className="sag">Başarısız / İptal</th><th className="sag">Test</th><th className="sag">Yüklenen</th><th className="sag">Kapasite</th>
          <th>Doluluk</th><th className="sag">Ort. Süre</th><th>Validasyon</th></tr></thead>
        <tbody>
          {v.cihazlar.length === 0 && <tr><td colSpan={13} className="bos">Tanımlı cihaz yok.</td></tr>}
          {v.cihazlar.map(c => {
            const sec = secili.includes(c.id); const d = dolulukRozeti(c.doluluk);
            return (
              <Fragment key={c.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(c.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(c.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(c.id, e)}>{acik.includes(c.id) ? '▾' : '▸'}</a> <b>{c.ad}</b>
                    <div className="ki-soluk">{c.model}</div></td>
                  <td>{c.tur}</td><td className="sag">{c.dongu}</td><td className="sag">{tire(c.serbest)}</td><td className="sag">{tire(c.karantina)}</td>
                  <td className={'sag' + (c.basarisiz ? ' kir' : '')}>{tire(c.basarisiz)}</td><td className="sag">{tire(c.test)}</td>
                  <td className="sag">{c.sterilizasyon ? c.yuklenen : '—'}</td><td className="sag">{c.kapasite ?? '—'}</td>
                  <td>{c.doluluk != null && <Cubuk oran={c.doluluk} />} <span className={'bo-rz ' + d.renk}>{d.ad}</span></td>
                  <td className="sag">{c.ortSureDk != null ? `${c.ortSureDk} dk` : '—'}</td>
                  <td>{c.validasyon ? <span className={c.validasyonGecikti ? 'kir' : ''}>{tarihKisa(c.validasyon)}</span>
                    : c.sterilizasyon ? <span className="bo-rz kir">yok</span> : '—'}</td>
                </tr>
                {acik.includes(c.id) && (
                  <tr className="lb-alt"><td /><td colSpan={12}>Programlar: {c.programlar.map(p => `${p.ad} ${p.adet}`).join('  ·  ') || '—'}
                    {c.sonBakim && `  |  son bakım ${tarihKisa(c.sonBakim)}`}</td></tr>
                )}
              </Fragment>
            );
          })}
          {v.cihazlar.length > 0 && (
            <tr className="top"><td /><td colSpan={2}>Toplam · {v.cihazlar.length} cihaz</td><td className="sag">{t.dongu}</td><td className="sag">{t.serbest}</td>
              <td className="sag">{t.karantina}</td><td className="sag">{t.basarisiz}</td><td className="sag">{t.test}</td>
              <td className="sag">{v.cihazlar.filter(c => c.sterilizasyon).reduce((x, c) => x + c.yuklenen, 0)}</td><td className="sag">{v.ozet.kapasite || '—'}</td><td>{yuzde(v.ozet.doluluk)}</td><td colSpan={2} /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Döngü = test dışı yük (günlük Bowie-Dick / vakum testi ayrı). Doluluk = döngüye bağlı paket / (yük kapasitesi × döngü);
        yük kapasitesi cihaz kartında girilir{v.ozet.kapasitesiz ? ` - ${v.ozet.kapasitesiz} cihazda girilmemiş, doluluğu hesaplanmadı` : ''}.
        Yıkama döngüsünde yük adedi tutulmuyor. Validasyonu bir yılı geçen otoklav kırmızıdır.</div>
    </>
  );
}

export function SetTablosu({ v }: { v: SterilIcmali }) {
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Kod</th><th>Set</th><th>Paket</th><th className="sag">Birim</th><th className="sag">Dönem Çevrimi</th><th className="sag">Birim Başı</th>
          <th className="sag">Kullanılan</th><th>Ömür Ort. / Eşik</th><th className="sag">Eşiğe Yakın</th><th className="sag">Steril Depoda / Min.</th></tr></thead>
        <tbody>
          {v.setler.length === 0 && <tr><td colSpan={10} className="bos">Set tanımı yok.</td></tr>}
          {v.setler.map(s => {
            const o = omurRozeti(s.omur, s.esik);
            return (
              <tr key={s.id}><td>{s.kod}</td><td><b>{s.ad}</b>{s.implant && <span className="bo-rz mor lb-k">implant</span>}</td><td>{s.paketTur || '—'}</td>
                <td className="sag">{s.birim}</td><td className="sag">{tire(s.uretilen)}</td><td className="sag">{s.uretilen ? s.birimBasi.toLocaleString('tr-TR') : '—'}</td>
                <td className="sag">{tire(s.kullanilan)}</td><td><span className={'bo-rz ' + o.renk}>{o.ad}</span></td>
                <td className={'sag' + (s.esigeYakin ? ' kir' : '')}>{s.esigeYakin ? `${s.esigeYakin} birim` : '—'}</td>
                <td className={'sag' + (s.stokAz ? ' kir' : '')}>{s.depoda} / {s.minStok || '—'}</td></tr>
            );
          })}
          {v.setler.length > 0 && (
            <tr className="top"><td colSpan={3}>Toplam · {v.setler.length} set</td><td className="sag">{v.ozet.birim}</td><td className="sag">{v.ozet.uretilen}</td>
              <td /><td className="sag">{v.ozet.kullanilan}</td><td /><td className="sag">{v.ozet.esigeYakin} birim</td><td className="sag">{v.ozet.depoda}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Dönem çevrimi = dönemde üretilen paket · ömür = birimin bugüne kadarki toplam döngüsü · eşik = üreticinin (birimde) ya da
        setin sınırı; %90 üstü uyarı · steril depoda minimum stokun altına düşen set kırmızıdır.</div>
    </>
  );
}

export function IndikatorTablosu({ v }: { v: SterilIcmali }) {
  const t = v.indikatorOzet.reduce((a, i) => ({ okuma: a.okuma + i.okuma, gecti: a.gecti + i.gecti, kaldi: a.kaldi + i.kaldi, bekliyor: a.bekliyor + i.bekliyor }),
    { okuma: 0, gecti: 0, kaldi: 0, bekliyor: 0 });
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Tür</th><th className="sag">Okuma</th><th className="sag">Geçti</th><th className="sag">Kaldı</th><th className="sag">Bekliyor</th><th className="sag">Başarı</th></tr></thead>
        <tbody>
          {v.indikatorOzet.length === 0 && <tr><td colSpan={6} className="bos">Bu dönemde indikatör okuması yok.</td></tr>}
          {v.indikatorOzet.map(i => (
            <tr key={i.tur}><td>{i.tur}</td><td className="sag">{i.okuma}</td><td className="sag">{i.gecti}</td>
              <td className={'sag' + (i.kaldi ? ' kir' : '')}>{tire(i.kaldi)}</td><td className="sag">{tire(i.bekliyor)}</td><td className="sag">{yuzde(i.basari)}</td></tr>
          ))}
          {v.indikatorOzet.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{t.okuma}</td><td className="sag">{t.gecti}</td><td className="sag">{t.kaldi}</td>
              <td className="sag">{t.bekliyor}</td><td className="sag">{yuzde(t.gecti + t.kaldi ? 100 * t.gecti / (t.gecti + t.kaldi) : null)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Başarısız İndikatörler <span className="ki-soluk">her biri döngüyü durdurur; biyolojik pozitif geri çağırma başlatır</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Cihaz</th><th>Döngü</th><th>Tür</th><th>Lot</th><th>Aksiyon</th></tr></thead>
        <tbody>
          {v.basarisizIndikatorler.length === 0 && <tr><td colSpan={6} className="bos">Başarısız indikatör yok.</td></tr>}
          {v.basarisizIndikatorler.map((i, k) => (
            <tr key={k}><td>{i.tarih ? tarihKisa(i.tarih) : '—'}</td><td>{i.cihaz}</td><td>#{i.dongu}</td><td>{i.tur}</td><td>{i.lot || '—'}</td>
              <td>{i.aksiyon || '—'}</td></tr>
          ))}
        </tbody>
      </table>
    </>
  );
}

export function KarantinaTablosu({ v }: { v: SterilIcmali }) {
  return (
    <>
      <div className="lb-bas">Geri Çağırmalar <span className="ki-soluk">hasta listesi geri çağırma kaydındadır, burada gösterilmez</span></div>
      <table className="hi-tablo">
        <thead><tr><th>No</th><th>Cihaz</th><th>Tetik</th><th className="sag">Döngü</th><th className="sag">Paket</th><th className="sag">Kullanılmış</th>
          <th className="sag">Hasta</th><th>Durum</th><th>Açıklama</th></tr></thead>
        <tbody>
          {v.geriCagirmalar.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde geri çağırma yok.</td></tr>}
          {v.geriCagirmalar.map(g => (
            <tr key={g.id}><td>GC-{g.id}</td><td>{g.cihaz}</td><td>{tarihKisa(g.tarih)} · döngü #{g.tetikDongu}</td><td className="sag">{g.dongu}</td>
              <td className="sag">{g.paket}</td><td className={'sag' + (g.kullanilan ? ' kir' : '')}>{g.kullanilan}</td><td className="sag">{g.hasta}</td>
              <td><span className={'bo-rz ' + (g.acik ? 'kir' : 'ok')}>{g.acik ? 'açık' : `kapandı${g.kapanis ? ' · ' + tarihKisa(g.kapanis) : ''}`}</span></td>
              <td className="ki-soluk">{g.aciklama.replace(/\n/g, ' · ') || '—'}</td></tr>
          ))}
        </tbody>
      </table>
      <div className="lb-kalite">
        <div>
          <div className="lb-bas">Karantinadaki Paketler <span className="ki-soluk">biyolojik sonucu bekliyor</span></div>
          <table className="hi-tablo">
            <thead><tr><th>Döngü</th><th>Cihaz</th><th>Set</th><th className="sag">Paket</th><th>BI Bitişi</th></tr></thead>
            <tbody>
              {v.karantina.length === 0 && <tr><td colSpan={5} className="bos">Karantinada paket yok.</td></tr>}
              {v.karantina.map((k, i) => (
                <tr key={i}><td>#{k.dongu}</td><td>{k.cihaz}</td><td>{k.set}</td><td className="sag">{k.paket}</td>
                  <td>{k.biBitis ? new Date(k.biBitis).toLocaleString('tr-TR') : '—'}</td></tr>
              ))}
            </tbody>
          </table>
        </div>
        <div>
          <div className="lb-bas">Süresi Dolan Paketler <span className="ki-soluk">SKT dönemde</span></div>
          <table className="hi-tablo">
            <thead><tr><th>Barkod</th><th>Set</th><th>Raf</th><th>SKT</th><th>Durum</th></tr></thead>
            <tbody>
              {v.suresiDolan.length === 0 && <tr><td colSpan={5} className="bos">Süresi dolan paket yok.</td></tr>}
              {v.suresiDolan.map(p => (
                <tr key={p.barkod}><td>{p.barkod}</td><td>{p.set}</td><td>{p.raf || '—'}</td><td>{tarihKisa(p.skt)}</td>
                  <td><span className={'bo-rz ' + (p.islenmedi ? 'kir' : p.durum === 'dolacak' ? 'sari' : 'ok')}>{p.durum}</span></td></tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}

export function BolumTablosu({ v }: { v: SterilIcmali }) {
  const [acik, setAcik] = useState<string[]>([]);
  const toplam = v.bolumler.reduce((t, b) => t + b.paket, 0);
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Bölüm / Ünite</th><th className="sag">Kullanılan Paket</th><th className="sag">Set Çeşidi</th><th className="sag">İmplant Seti</th>
          <th className="sag">Hasta</th><th className="sag">Ort. Depoda Bekleme</th><th>Pay</th></tr></thead>
        <tbody>
          {v.bolumler.length === 0 && <tr><td colSpan={7} className="bos">Bu dönemde paket kullanımı yok.</td></tr>}
          {v.bolumler.map(b => (
            <Fragment key={b.bolum}>
              <tr className="ac" onClick={() => setAcik(a => a.includes(b.bolum) ? a.filter(x => x !== b.bolum) : [...a, b.bolum])}>
                <td>{acik.includes(b.bolum) ? '▾' : '▸'} <b>{b.bolum}</b></td><td className="sag">{b.paket}</td><td className="sag">{b.setCesidi}</td>
                <td className="sag">{tire(b.implant)}</td><td className="sag">{b.hasta}</td>
                <td className="sag">{b.ortBeklemeGun != null ? `${b.ortBeklemeGun.toLocaleString('tr-TR')} gün` : '—'}</td>
                <td><Cubuk oran={toplam ? 100 * b.paket / toplam : 0} /> {yuzde(toplam ? 100 * b.paket / toplam : null)}</td></tr>
              {acik.includes(b.bolum) && (
                <tr className="lb-alt"><td colSpan={7}>{b.setler.map(s => `${s.ad} ${s.adet}`).join('  ·  ')}</td></tr>
              )}
            </Fragment>
          ))}
          {v.bolumler.length > 0 && (
            <tr className="top"><td>Toplam · {v.bolumler.length} bölüm</td><td className="sag">{toplam}</td><td colSpan={5} /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Bölüm = paket okutulurken yazılan ünite / bölüm adı (kullanım kaydında serbest metin). Hasta = farklı başvuru / hasta.
        Bekleme = paketleme → kullanım.</div>
    </>
  );
}
