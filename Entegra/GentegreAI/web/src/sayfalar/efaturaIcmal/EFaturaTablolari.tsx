import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { EFaturaBelgeSatiri, EFaturaIcmali, EFaturaTurOzeti } from '../../api/uclar/efaturaIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { durumRengi, sorunRengi, ulasanRozeti, yuzde } from './efaturaIcmalOrtak';

/** Fatura / e-Belge icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const tl = (n: number) => para.format(n);
const tire = (n: number) => (n ? String(n) : '—');
const tireTl = (n: number) => (n ? tl(n) : '—');

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}

function TurHucreleri({ o }: { o: EFaturaTurOzeti }) {
  const u = ulasanRozeti(o.ulasan);
  return (<>
    <td className="sag">{o.belge}</td><td className="sag">{tl(o.matrah)}</td><td className="sag">{tl(o.kdv)}</td>
    <td className="sag"><b>{tl(o.toplam)}</b></td><td className="sag">{tire(o.iade)}</td><td className="sag">{tireTl(o.iadeTutar)}</td>
    <td className="sag">{tire(o.iptal)}</td>
    <td>{o.ulasan != null && <Cubuk oran={o.ulasan} />} <span className={'bo-rz ' + u.renk}>{u.ad}</span></td>
    <td className={'sag' + (o.sorunlu ? ' kir' : '')}>{tire(o.sorunlu)}</td>
    <td className={'sag' + (o.yediGun ? ' kir' : '')}>{tire(o.yediGun)}</td>
  </>);
}

/** BELGE TÜRLERİ - satıra tıkla: seri kırılımı · onay kutusu: tık tek, Ctrl / Shift çoklu; seçim A4'ü süzer. */
export function TurTablosu({ v, secili, setSecili }: { v: EFaturaIcmali; secili: string[]; setSecili(x: string[]): void }) {
  const son = useRef<string | null>(null);
  const [acik, setAcik] = useState<string[]>([]);
  const turler = v.turler.map(t => t.tur);
  const tikla = (tur: string, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, tur, turler, son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = tur;
  };
  const hepsi = turler.length > 0 && turler.every(t => secili.includes(t));
  const t = v.turler.reduce((a, x) => ({
    belge: a.belge + x.ozet.belge, matrah: a.matrah + x.ozet.matrah, kdv: a.kdv + x.ozet.kdv, toplam: a.toplam + x.ozet.toplam,
    iade: a.iade + x.ozet.iade, iadeTutar: a.iadeTutar + x.ozet.iadeTutar, iptal: a.iptal + x.ozet.iptal,
    sorunlu: a.sorunlu + x.ozet.sorunlu, yediGun: a.yediGun + x.ozet.yediGun,
  }), { belge: 0, matrah: 0, kdv: 0, toplam: 0, iade: 0, iadeTutar: 0, iptal: 0, sorunlu: 0, yediGun: 0 });
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : turler)} /></th>
        <th>Tür</th><th className="sag">Belge</th><th className="sag">Matrah</th><th className="sag">KDV</th><th className="sag">Toplam</th>
        <th className="sag">İade</th><th className="sag">İade Tutarı</th><th className="sag">İptal</th><th>GİB'e Ulaşan</th>
        <th className="sag">Sorunlu</th><th className="sag">7 Gün Aşan</th></tr></thead>
      <tbody>
        {v.turler.length === 0 && <tr><td colSpan={12} className="bos">Dönemde e-Belge yok.</td></tr>}
        {v.turler.map(x => {
          const sec = secili.includes(x.tur);
          return (
            <Fragment key={x.tur}>
              <tr className={'ac' + (sec ? ' sec' : '')} onClick={() => setAcik(a => a.includes(x.tur) ? a.filter(y => y !== x.tur) : [...a, x.tur])}
                  title="Tıkla: seri kırılımı">
                <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(x.tur, e)} /></td>
                <td><span className="ki-lnk">{acik.includes(x.tur) ? '▾' : '▸'}</span> <b>{x.tur}</b></td>
                <TurHucreleri o={x.ozet} />
              </tr>
              {acik.includes(x.tur) && x.seriler.map(s => (
                <tr key={s.seri} className="lb-alt"><td /><td>Seri <b>{s.seri}</b></td><TurHucreleri o={s.ozet} /></tr>
              ))}
            </Fragment>
          );
        })}
        {v.turler.length > 0 && (
          <tr className="top"><td /><td>Toplam · {v.turler.length} tür</td><td className="sag">{t.belge}</td><td className="sag">{tl(t.matrah)}</td>
            <td className="sag">{tl(t.kdv)}</td><td className="sag">{tl(t.toplam)}</td><td className="sag">{tire(t.iade)}</td>
            <td className="sag">{tireTl(t.iadeTutar)}</td><td className="sag">{tire(t.iptal)}</td><td>{yuzde(v.ozet.ulasan)}</td>
            <td className="sag">{t.sorunlu}</td><td className="sag">{t.yediGun}</td></tr>
        )}
      </tbody>
    </table>
  );
}

/** SORUNLU BELGELER - seçilenler üstteki e-Fatura menüsüyle işlenir (tek ya da çoklu). */
export function SorunluTablosu({ v, secili, setSecili, belgeAc }: {
  v: EFaturaIcmali; secili: number[]; setSecili(x: number[]): void; belgeAc(id: number): void;
}) {
  const son = useRef<number | null>(null);
  const idler = v.sorunlu.map(s => s.id);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, idler, son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const hepsi = idler.length > 0 && idler.every(i => secili.includes(i));
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : idler)} /></th>
          <th>Belge No</th><th>Tarih</th><th>Tür</th><th>Alıcı</th><th>Protokol No</th><th className="sag">Tutar</th><th>Sorun</th>
          <th>Açıklama / GİB Mesajı</th><th>Gönderim</th></tr></thead>
        <tbody>
          {v.sorunlu.length === 0 && <tr><td colSpan={10} className="bos">Sorunlu belge yok.</td></tr>}
          {v.sorunlu.map(s => (
            <tr key={s.id} className={'ac' + (secili.includes(s.id) ? ' sec' : '')} onClick={e => tikla(s.id, e)}
                onDoubleClick={() => belgeAc(s.id)} title="Tıkla: seç · çift tık: faturayı aç">
              <td><input type="checkbox" checked={secili.includes(s.id)} readOnly onClick={e => tikla(s.id, e)} /></td>
              <td><b>{s.belgeNo === '0' ? '—' : s.belgeNo}</b></td><td>{tarihKisa(s.tarih)}</td><td>{s.tur}</td><td>{s.alici}</td>
              <td>{s.protokol || '—'}</td><td className="sag">{tl(s.tutar)}</td>
              <td>{s.sorun && <span className={'bo-rz ' + sorunRengi(s.sorun)}>{s.sorun}</span>}
                {s.gun > 0 && <span className="bo-rz kir" style={{ marginLeft: 4 }}>{s.gun} gün · 7 gün kuralı</span>}</td>
              <td className="ki-soluk">{s.aciklama}</td><td>{s.gonderim ? tarihKisa(s.gonderim) : '—'}</td>
            </tr>
          ))}
          {v.sorunlu.length > 0 && (
            <tr className="top"><td /><td colSpan={5}>{v.sorunlu.length} sorunlu belge</td>
              <td className="sag">{tl(v.sorunlu.reduce((a, s) => a + s.tutar, 0))}</td><td colSpan={3} /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Bir belge hem sorunlu (ör. GİB'e gitmedi) hem 7 günü aşmış olabilir; satırda iki rozet görünür.
        Seçili belgeler üstteki e-Fatura menüsüyle hazırlanır / gönderilir (Ctrl / Shift ile çoklu; uygun olmayan belge atlanır).
        Alıcı yanıtı ve iptal talebi giden belgede izlenmiyor.</div>
    </>
  );
}

export function KdvTablosu({ v }: { v: EFaturaIcmali }) {
  const t = v.kdvOzet.reduce((a, k) => ({ satir: a.satir + k.satir, eFatura: a.eFatura + k.eFatura, eArsiv: a.eArsiv + k.eArsiv,
    matrah: a.matrah + k.matrah, kdv: a.kdv + k.kdv }), { satir: 0, eFatura: 0, eArsiv: 0, matrah: 0, kdv: 0 });
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>KDV Oranı</th><th className="sag">Satır</th><th className="sag">Belge</th><th className="sag">e-Fatura Matrah</th>
          <th className="sag">e-Arşiv Matrah</th><th className="sag">Matrah</th><th className="sag">KDV</th><th className="sag">Pay</th></tr></thead>
        <tbody>
          {v.kdvOzet.length === 0 && <tr><td colSpan={8} className="bos">Geçerli satış faturası yok.</td></tr>}
          {v.kdvOzet.map(k => (
            <tr key={k.oran}><td><b>{k.oran ? `%${k.oran}` : 'İstisna (%0)'}</b></td><td className="sag">{k.satir}</td><td className="sag">{k.belge}</td>
              <td className="sag">{tl(k.eFatura)}</td><td className="sag">{tl(k.eArsiv)}</td><td className="sag">{tl(k.matrah)}</td>
              <td className="sag">{tl(k.kdv)}</td><td className="sag">{yuzde(k.pay)}</td></tr>
          ))}
          {v.kdvOzet.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{t.satir}</td><td className="sag">{v.ozet.eFatura + v.ozet.eArsiv}</td>
              <td className="sag">{tl(t.eFatura)}</td><td className="sag">{tl(t.eArsiv)}</td><td className="sag">{tl(t.matrah)}</td>
              <td className="sag">{tl(t.kdv)}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Geçerli satış faturaları (e-Fatura + e-Arşiv) · iade ve iptal hariç · e-İrsaliye vergi belgesi değil.
        Bir belge birden çok oranda sayılabilir (çok oranlı fatura); toplam satırındaki belge sayısı tekildir.</div>
    </>
  );
}

export function AliciSeriTablosu({ v }: { v: EFaturaIcmali }) {
  return (
    <>
      {/* MOCKUP (Ekranlar/İcmal/fatura_ebelge_icmali.html "Alıcı / Seri"): pay çubuklu,
          toplam satırlı; kurum tablosunda Durum geniş. */}
      <div className="lb-bas">Alıcı Grubu <span className="ki-soluk">kurum faturası (e-Fatura) · hasta faturası (e-Arşiv) · firma · cari kartındaki rol</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Alıcı</th><th className="sag">Belge</th><th className="sag">Matrah</th><th className="sag">KDV</th><th className="sag">Toplam</th>
          <th className="sag">İade</th><th className="sag">İptal</th><th className="sag">Sorunlu</th><th className="sag">Pay</th></tr></thead>
        <tbody>
          {v.alicilar.length === 0 && <tr><td colSpan={9} className="bos">Kayıt yok.</td></tr>}
          {v.alicilar.map(a => (
            <tr key={a.grup}><td><b>{a.grup}</b></td><td className="sag">{a.belge}</td><td className="sag">{tl(a.matrah)}</td>
              <td className="sag">{tl(a.kdv)}</td><td className="sag">{tl(a.toplam)}</td><td className="sag">{tire(a.iade)}</td>
              <td className="sag">{tire(a.iptal)}</td><td className={'sag' + (a.sorunlu ? ' kir' : '')}>{tire(a.sorunlu)}</td>
              <td className="sag"><span className="lb-bar"><span style={{ width: `${Math.min(100, a.pay)}%` }} /></span> {yuzde(a.pay)}</td></tr>
          ))}
          {v.alicilar.length > 1 && (
            <tr className="top"><td>Toplam</td><td className="sag">{v.alicilar.reduce((t, a) => t + a.belge, 0)}</td>
              <td className="sag">{tl(v.alicilar.reduce((t, a) => t + a.matrah, 0))}</td>
              <td className="sag">{tl(v.alicilar.reduce((t, a) => t + a.kdv, 0))}</td>
              <td className="sag">{tl(v.alicilar.reduce((t, a) => t + a.toplam, 0))}</td>
              <td className="sag">{tire(v.alicilar.reduce((t, a) => t + a.iade, 0))}</td>
              <td className="sag">{tire(v.alicilar.reduce((t, a) => t + a.iptal, 0))}</td>
              <td className="sag">{tire(v.alicilar.reduce((t, a) => t + a.sorunlu, 0))}</td><td /></tr>
          )}
        </tbody>
      </table>

      <div className="lb-bas">Kurum Faturaları <span className="ki-soluk">geçerli kurum faturaları · rozetler sorunlu olanları sayar</span></div>
      <table className="hi-tablo">
        <thead><tr><th style={{ width: '34%' }}>Kurum</th><th className="sag" style={{ width: 80 }}>Fatura</th>
          <th className="sag" style={{ width: 140 }}>Toplam</th><th style={{ paddingLeft: 16 }}>Durum</th></tr></thead>
        <tbody>
          {v.kurumlar.length === 0 && <tr><td colSpan={4} className="bos">Kurum faturası yok.</td></tr>}
          {v.kurumlar.map(k => (
            <tr key={k.ad}><td>{k.ad}</td><td className="sag">{k.fatura}</td><td className="sag">{tl(k.toplam)}</td>
              <td style={{ paddingLeft: 16 }}>{k.durumlar.length === 0 ? <span className="bo-rz ok">tümü gönderildi</span>
                : k.durumlar.map(d => <span key={d.ad} className={'bo-rz ' + sorunRengi(d.ad)} style={{ marginRight: 4 }}>{d.ad} {d.adet}</span>)}</td></tr>
          ))}
          {v.kurumlar.length > 1 && (
            <tr className="top"><td>{v.kurumlar.length} kurum</td><td className="sag">{v.kurumlar.reduce((t, k) => t + k.fatura, 0)}</td>
              <td className="sag">{tl(v.kurumlar.reduce((t, k) => t + k.toplam, 0))}</td><td /></tr>
          )}
        </tbody>
      </table>

      <div className="lb-bas">Seriler <span className="ki-soluk">numara sürekliliği: ilk – son no arasında atlama olmamalı · kayıt = geçerli + iade + iptal</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Seri</th><th>Tür</th><th>Kullanım</th><th>İlk No</th><th>Son No</th><th className="sag">Kayıt</th><th className="sag">Geçerli Satış</th>
          <th className="sag">İade</th><th className="sag">İptal</th><th className="sag">Toplam</th><th>Süreklilik</th></tr></thead>
        <tbody>
          {v.seriler.length === 0 && <tr><td colSpan={11} className="bos">Kayıt yok.</td></tr>}
          {v.seriler.map(s => (
            <tr key={s.seri}><td><b>{s.seri}</b></td><td>{s.tur}</td><td className="ki-soluk">{s.kullanim}</td><td>{s.ilk}</td><td>{s.son}</td>
              <td className="sag">{s.kayit}</td><td className="sag">{s.gecerli}</td><td className="sag">{tire(s.iade)}</td>
              <td className="sag">{tire(s.iptal)}</td><td className="sag">{tl(s.toplam)}</td>
              <td>{s.atlama ? <span className="bo-rz kir">{s.atlama} numara atlandı</span> : <span className="bo-rz ok">atlama yok</span>}</td></tr>
          ))}
        </tbody>
      </table>
      <div className="ki-not">Atlama, dönem içinde seride kullanılmayan numara sayısıdır; "Hazırı Geri Al" ile boşa düşen numara da atlama yaratır.</div>
    </>
  );
}

function BelgeListesi({ satirlar, bos, iptal }: { satirlar: EFaturaBelgeSatiri[]; bos: string; iptal?: boolean }) {
  return (
    <table className="hi-tablo">
      <thead><tr><th>Belge No</th><th>Tarih</th><th>Tür</th><th>Alıcı</th><th>Protokol No</th><th className="sag">Matrah</th>
        <th className="sag">KDV</th><th className="sag">Toplam</th><th>{iptal ? 'e-Belge' : 'Durum'}</th></tr></thead>
      <tbody>
        {satirlar.length === 0 && <tr><td colSpan={9} className="bos">{bos}</td></tr>}
        {satirlar.map(s => (
          <tr key={s.id}><td><b>{s.belgeNo}</b></td><td>{tarihKisa(s.tarih)}</td><td>{s.tur}</td><td>{s.alici}</td><td>{s.protokol || '—'}</td>
            <td className="sag">{tl(s.matrah)}</td><td className="sag">{tl(s.kdv)}</td><td className="sag">{tl(s.toplam)}</td>
            <td><span className={'bo-rz ' + durumRengi(s.durum)}>{s.durum}</span></td></tr>
        ))}
        {satirlar.length > 0 && (
          <tr className="top"><td colSpan={5}>{satirlar.length} belge</td><td className="sag">{tl(satirlar.reduce((a, s) => a + s.matrah, 0))}</td>
            <td className="sag">{tl(satirlar.reduce((a, s) => a + s.kdv, 0))}</td><td className="sag">{tl(satirlar.reduce((a, s) => a + s.toplam, 0))}</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

export function IadeIptalTablosu({ v }: { v: EFaturaIcmali }) {
  return (
    <>
      <div className="lb-bas">İade Faturaları <span className="ki-soluk">satış toplamına girmez, ayrı izlenir</span></div>
      <BelgeListesi satirlar={v.iadeler} bos="Dönemde iade faturası yok." />
      <div className="lb-bas">İptaller <span className="ki-soluk">programda iptal edilen e-Belge kayıtları</span></div>
      <BelgeListesi satirlar={v.iptaller} bos="Dönemde iptal yok." iptal />
      <div className="ki-not">Gönderilmiş e-Fatura / e-Arşiv programdan iptal edilmez; düzeltme iade faturasıyla yapılır.</div>
    </>
  );
}
