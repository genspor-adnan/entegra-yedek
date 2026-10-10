import type { VezneIcmali } from '../../../api/uclar/vezneIcmal';
import { para } from '../../../bilesenler/bicim';
import { odemeTuruIkonu } from '../../banko/odemeTuru';
import { devirRozeti, neredeRozeti, oturumRozeti, saat, terminalRozeti } from './vezneOrtak';

/** Vezne icmalinin sekme tabloları (VezneIcmal). Rakamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number | null | undefined) => (n != null && Math.abs(n) > 0.005 ? p(n) : '—');
const isaretli = (n: number) => (n > 0.005 ? `+${p(n)}` : p(n));

/**
 * BANKOLAR / OTURUMLAR - soldaki onay kutusu (mockup) diğer sekmeleri ve A4'ü
 * süzer; hiçbiri seçili değilse bütün oturumlar. Çift tık banko oturumunu açar.
 */
export function OturumTablosu({ v, secili, setSecili, gunlu, oturumAc }: {
  v: VezneIcmali; secili: number[]; setSecili(s: number[]): void; gunlu: boolean;
  oturumAc(id: number): void;
}) {
  const hepsi = v.oturumlar.length > 0 && v.oturumlar.every(o => secili.includes(o.id));
  const degistir = (id: number) =>
    setSecili(secili.includes(id) ? secili.filter(x => x !== id) : [...secili, id]);
  // Toplam satırı SUNUCU özetinden - seçim sunucuda uygulanır (v.secili).
  const z = v.ozet;
  return (
    <table className="hi-tablo">
      <thead><tr>
        <th style={{ width: 28 }}>
          <input type="checkbox" checked={hepsi} title="Hepsini seç / bırak"
                 onChange={() => setSecili(hepsi ? [] : v.oturumlar.map(o => o.id))} />
        </th>
        <th>Banko</th><th>Görevli</th><th>Açılış – Kapanış</th>
        <th className="sag">Nakit</th><th className="sag">POS</th><th className="sag">Havale</th>
        <th className="sag">Diğer</th><th className="sag">İade</th><th className="sag">Net</th>
        <th className="sag">Beklenen Nakit</th><th className="sag">Sayım</th><th className="sag">Fark</th><th>Durum</th>
      </tr></thead>
      <tbody>
        {v.oturumlar.length === 0 && <tr><td colSpan={14} className="bos">Bu tarihte banko oturumu yok.</td></tr>}
        {v.oturumlar.map(o => {
          const r = oturumRozeti(o);
          const sec = secili.includes(o.id);
          const fark = o.fark ?? 0;
          return (
            <tr key={o.id} className={'ac' + (sec ? ' sec' : '')} onClick={() => degistir(o.id)}
                onDoubleClick={() => oturumAc(o.id)} title="Çift tık: banko oturumunu aç">
              <td><input type="checkbox" checked={sec} onClick={e => e.stopPropagation()}
                         onChange={() => degistir(o.id)} /></td>
              <td><b>{o.banko || o.bankoKod}</b>{o.vardiya && <div className="ki-soluk">{o.vardiya}</div>}</td>
              <td>{o.gorevli}</td>
              <td>{saat(o.acilis, gunlu)} – {o.kapanis ? saat(o.kapanis, gunlu) : <span className="ki-soluk">açık</span>}</td>
              <td className="sag">{tire(o.nakit)}</td><td className="sag">{tire(o.pos)}</td>
              <td className="sag">{tire(o.havale)}</td><td className="sag">{tire(o.diger)}</td>
              <td className={'sag' + (o.iade > 0.005 ? ' kir' : '')}>{o.iade > 0.005 ? `−${p(o.iade)}` : '—'}</td>
              <td className="sag"><b>{p(o.net)}</b></td>
              <td className="sag">{p(o.beklenenNakit)}</td>
              <td className="sag">{o.sayim != null ? p(o.sayim) : '—'}</td>
              <td className={'sag' + (fark < -0.005 ? ' kir' : '')} title={o.farkAciklama || undefined}>
                {o.fark != null ? isaretli(fark) : '—'}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td>
            </tr>
          );
        })}
        {v.oturumlar.length > 0 && (
          <tr className="top"><td />
            <td colSpan={3}>{z.oturum} oturum · {z.banko} banko{secili.length > 0 && ' (seçili)'}</td>
            <td className="sag">{p(z.nakit)}</td><td className="sag">{p(z.pos)}</td>
            <td className="sag">{p(z.havale)}</td><td className="sag">{p(z.diger)}</td>
            <td className="sag">{z.iade > 0.005 ? `−${p(z.iade)}` : p(0)}</td>
            <td className="sag">{p(z.net)}</td><td className="sag">{p(z.beklenenNakit)}</td>
            <td className="sag">{p(z.sayim)}</td><td className="sag">{isaretli(z.kasaFarki)}</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

export function TurTablosu({ v }: { v: VezneIcmali }) {
  const net = v.turler.reduce((t, x) => t + x.net, 0);
  const adet = v.turler.reduce((t, x) => t + x.adet, 0);
  return (
    <table className="hi-tablo">
      <thead><tr><th>Ödeme Türü</th><th className="sag">Adet</th><th className="sag">Tahsilat</th>
        <th className="sag">İade</th><th className="sag">Net</th><th className="sag">Pay</th><th>Nerede</th></tr></thead>
      <tbody>
        {v.turler.length === 0 && <tr><td colSpan={7} className="bos">Seçili oturumlarda işlem yok.</td></tr>}
        {v.turler.map(x => {
          const r = neredeRozeti(x);
          return (
            <tr key={x.tur}><td>{odemeTuruIkonu(x)} {x.turAdi}</td><td className="sag">{x.adet}</td>
              <td className="sag">{tire(x.tahsilat)}</td>
              <td className={'sag' + (x.iade > 0.005 ? ' kir' : '')}>{x.iade > 0.005 ? `−${p(x.iade)}` : '—'}</td>
              <td className="sag">{p(x.net)}</td>
              <td className="sag">{Math.abs(net) > 0.005 ? `%${(100 * x.net / net).toFixed(1).replace('.', ',')}` : '—'}</td>
              <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
          );
        })}
        {v.turler.length > 0 && (
          <tr className="top"><td>Net</td><td className="sag">{adet}</td><td colSpan={2} />
            <td className="sag">{p(net)}</td><td className="sag">%100</td><td /></tr>
        )}
      </tbody>
    </table>
  );
}

export function PosTablosu({ v }: { v: VezneIcmali }) {
  const o = v.ozet;
  const eksik = v.pos.some(t => t.eksik || t.cihazToplami == null);
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Terminal</th><th>Banka / Hesap</th><th>Banko</th><th className="sag">Adet</th>
          <th className="sag">Cihaz Toplamı</th><th className="sag">Kasa Toplamı</th><th className="sag">Fark</th><th>Durum</th></tr></thead>
        <tbody>
          {v.pos.length === 0 && <tr><td colSpan={8} className="bos">Seçili oturumlarda POS işlemi yok.</td></tr>}
          {v.pos.map(t => {
            const r = terminalRozeti(t);
            return (
              <tr key={t.bankoPosId}><td>{t.terminalNo}</td><td>{t.banka}</td>
                <td>{t.bankolar}{t.oturum > 1 && <span className="ki-soluk"> ({t.oturum} oturum)</span>}</td>
                <td className="sag">{t.adet}</td>
                <td className="sag">{t.cihazToplami != null ? p(t.cihazToplami) : '—'}</td>
                <td className="sag">{p(t.kasaToplami)}</td>
                <td className={'sag' + (Math.abs(t.fark ?? 0) > 0.005 ? ' kir' : '')}>{t.fark != null ? isaretli(t.fark) : '—'}</td>
                <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
            );
          })}
          {v.pos.length > 0 && (
            <tr className="top"><td colSpan={3}>{v.pos.length} terminal</td>
              <td className="sag">{v.pos.reduce((s, t) => s + t.adet, 0)}</td>
              {/* Gün sonu girilmemiş terminal varsa cihaz toplamı / fark eksik -
                  "0,00" mutabık sanılırdı. */}
              <td className="sag">{eksik ? '—' : p(v.pos.reduce((s, t) => s + (t.cihazToplami ?? 0), 0))}</td>
              <td className="sag">{p(v.pos.reduce((s, t) => s + t.kasaToplami, 0))}</td>
              <td className="sag">{eksik ? '—' : isaretli(o.posFarki)}</td><td /></tr>
          )}
        </tbody>
      </table>
      {o.posAtanmamis > 0.005 && (
        <div className="ki-not">⚠ Terminale bağlanmamış POS tahsilatı: <b>{p(o.posAtanmamis)}</b> - kayıtta var,
          hangi cihazdan geçtiği yazılmamış; terminal toplamlarına girmez.</div>
      )}
    </>
  );
}

export function DevirTablosu({ v, gunlu }: { v: VezneIcmali; gunlu: boolean }) {
  const o = v.ozet;
  return (
    <table className="hi-tablo">
      <thead><tr><th>Oturum</th><th>Görevli</th><th className="sag">Sayım</th><th className="sag">Devredilen</th>
        <th className="sag">Kasada Bırakılan</th><th>Teslim Alan</th><th>Zaman</th><th>Tutanak</th><th>Durum</th></tr></thead>
      <tbody>
        {v.oturumlar.length === 0 && <tr><td colSpan={9} className="bos">Bu tarihte banko oturumu yok.</td></tr>}
        {v.oturumlar.filter(x => !v.secili.length || v.secili.includes(x.id)).map(x => {
          const r = devirRozeti(x);
          return (
            <tr key={x.id}><td>{x.banko || x.bankoKod} · {saat(x.acilis, gunlu)}</td><td>{x.gorevli}</td>
              <td className="sag">{x.sayim != null ? p(x.sayim) : '—'}</td>
              <td className="sag">{x.teslimEdilen != null ? p(x.teslimEdilen) : '—'}</td>
              <td className="sag">{x.kasadaBirakilan != null ? p(x.kasadaBirakilan) : '—'}</td>
              <td>{x.teslimAlan || '—'}</td><td>{x.teslimZamani ? saat(x.teslimZamani, gunlu) : '—'}</td>
              <td>{x.tutanakNo || '—'}</td><td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
          );
        })}
        {v.oturumlar.length > 0 && (
          <tr className="top"><td colSpan={3}>Devredilen ({o.devredilenOturum}) · bekleyen {p(o.bekleyenDevir)}</td>
            <td className="sag">{p(o.devredilen)}</td><td colSpan={5} className="ki-soluk">yalnız nakit merkez kasaya devredilir</td></tr>
        )}
      </tbody>
    </table>
  );
}
