import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { IsgIcmali } from '../../api/uclar/isgIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { dk, gecikmeRenk, karsilamaRozeti, sozlesmeRozeti, tahsilRozeti } from './isgIcmalOrtak';

/** İSG / OSGB icmalinin sekme tabloları. Rakamlar ve toplamlar sunucudan gelir. */

const tire = (n: number) => (n ? String(n) : '—');
const p = (n: number) => para.format(n);

/** FİRMALAR - tık tek, Ctrl / Shift çoklu; ▸ bölüm / maruziyet; seçilenler diğer sekmeleri ve A4'ü süzer. */
export function FirmaTablosu({ v, secili, setSecili }: { v: IsgIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.firmalar.map(f => f.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.firmalar.length > 0 && v.firmalar.every(f => secili.includes(f.id));
  const o = v.ozet;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.firmalar.map(f => f.id))} /></th>
          <th>Firma</th><th>NACE</th><th>Tehlike</th><th className="sag">Çalışan</th><th>İşyeri Hekimi</th><th className="sag">Plan dk</th>
          <th className="sag">Gerçekleşen dk</th><th>Karşılama</th><th className="sag">Muayene</th><th className="sag">Geciken</th><th className="sag">Kaza</th></tr></thead>
        <tbody>
          {v.firmalar.length === 0 && <tr><td colSpan={12} className="bos">Aktif firma yok.</td></tr>}
          {v.firmalar.map(f => {
            const sec = secili.includes(f.id); const k = karsilamaRozeti(f.karsilama);
            return (
              <Fragment key={f.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(f.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(f.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(f.id, e)}>{acik.includes(f.id) ? '▾' : '▸'}</a> <b>{f.ad}</b></td>
                  <td>{f.nace} <span className="ki-soluk">{f.naceAd}</span></td>
                  <td><span className={'bo-rz ' + (f.tehlike === 3 ? 'kir' : f.tehlike === 2 ? 'sari' : 'ok')}>{f.tehlikeAdi}</span></td>
                  <td className="sag">{f.calisan}</td><td>{f.hekim || '—'}</td>
                  <td className="sag">{dk(f.planDk)}</td><td className="sag">{dk(f.gercekDk)}</td>
                  <td><span className={'bo-rz ' + k.renk}>{k.ad}</span></td>
                  <td className="sag">{tire(f.muayene)}</td><td className={'sag' + (f.geciken ? ' kir' : '')}>{tire(f.geciken)}</td>
                  <td className={'sag' + (f.kaza ? ' kir' : '')}>{tire(f.kaza)}</td>
                </tr>
                {acik.includes(f.id) && (f.bolumler.length === 0
                  ? <tr className="lb-alt"><td /><td colSpan={11}>Bölüm tanımı yok.</td></tr>
                  : f.bolumler.map(b => (
                    <tr key={b.ad} className="lb-alt"><td /><td colSpan={3}>{b.ad}{b.maruziyet && ` · ${b.maruziyet}`}</td>
                      <td className="sag">{b.calisan}</td><td colSpan={4}>periyot {b.periyotAy % 12 === 0 ? `${b.periyotAy / 12} yıl` : `${b.periyotAy} ay`}</td>
                      <td /><td className="sag">{tire(b.geciken)}</td><td /></tr>
                  )))}
              </Fragment>
            );
          })}
          {v.firmalar.length > 0 && (
            <tr className="top"><td /><td colSpan={3}>Toplam · {o.firma} firma</td><td className="sag">{o.calisan}</td><td />
              <td className="sag">{dk(o.planDk)}</td><td className="sag">{dk(o.gercekDk)}</td><td>{karsilamaRozeti(o.karsilama).ad}</td>
              <td className="sag">{o.muayene}</td><td className="sag">{o.geciken}</td><td className="sag">{o.kaza}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Plan = sözleşme dakikası (firma kartı), yoksa çalışan × (az tehlikeli 5 · tehlikeli 10 · çok tehlikeli 15 dk / ay),
        dönemin ay oranıyla. Gerçekleşen = ziyaret + tamamlanmış Ek-2 muayene süresi. Geciken periyodik bugün itibarıyladır.</div>
    </>
  );
}

/** MUAYENELER - tür ve kanaat; geciken periyodik muayeneler. */
export function MuayeneTablosu({ v }: { v: IsgIcmali }) {
  const t = v.muayeneToplam;
  return (
    <>
      <div className="lb-bas">Muayene Türü ve Kanaat <span className="ki-soluk">Ek-2 formu · süre İSG-KATİP'e sayılan muayene dakikası</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Firma</th><th className="sag">İşe giriş</th><th className="sag">Periyodik</th><th className="sag">İşe dönüş</th>
          <th className="sag">Erken kontrol</th><th className="sag">İş değişikliği</th><th className="sag">Toplam</th><th className="sag">Çalışır</th>
          <th className="sag">Şu koşulla</th><th className="sag">Çalışamaz</th><th className="sag">Bekliyor</th><th className="sag">Süre dk</th></tr></thead>
        <tbody>
          {v.muayeneler.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde Ek-2 muayenesi yok.</td></tr>}
          {v.muayeneler.map(m => (
            <tr key={m.id}><td>{m.ad}</td><td className="sag">{tire(m.iseGiris)}</td><td className="sag">{tire(m.periyodik)}</td>
              <td className="sag">{tire(m.iseDonus)}</td><td className="sag">{tire(m.erkenKontrol)}</td><td className="sag">{tire(m.isDegisikligi)}</td>
              <td className="sag"><b>{m.toplam}</b></td><td className="sag">{tire(m.calisir)}</td><td className="sag">{tire(m.kosullu)}</td>
              <td className={'sag' + (m.calisamaz ? ' kir' : '')}>{tire(m.calisamaz)}</td><td className="sag">{tire(m.bekliyor)}</td>
              <td className="sag">{dk(m.sureDk)}</td></tr>
          ))}
          {v.muayeneler.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{t.iseGiris}</td><td className="sag">{t.periyodik}</td><td className="sag">{t.iseDonus}</td>
              <td className="sag">{t.erkenKontrol}</td><td className="sag">{t.isDegisikligi}</td><td className="sag">{t.toplam}</td><td className="sag">{t.calisir}</td>
              <td className="sag">{t.kosullu}</td><td className="sag">{t.calisamaz}</td><td className="sag">{t.bekliyor}</td><td className="sag">{dk(t.sureDk)}</td></tr>
          )}
        </tbody>
      </table>

      <div className="lb-bas">Geciken Periyodik Muayeneler <span className="ki-soluk">olması gereken = hekimin verdiği sonraki tarih, yoksa son muayene + periyot
        (hekim kısaltması › bölüm › tehlike sınıfı) · {tarihKisa(v.bugun)} itibarıyla</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Çalışan</th><th>Firma</th><th>Bölüm</th><th>Tehlike</th><th>Son Muayene</th><th>Olması Gereken</th><th className="sag">Gecikme</th></tr></thead>
        <tbody>
          {v.geciken.length === 0 && <tr><td colSpan={7} className="bos">Geciken periyodik muayene yok.</td></tr>}
          {v.geciken.map(g => (
            <tr key={g.id}><td>{g.ad}</td><td>{g.firma}</td><td>{g.bolum || '—'}</td><td>{g.tehlike}</td>
              <td>{g.sonMuayene ? tarihKisa(g.sonMuayene) : 'hiç yok'}</td><td>{tarihKisa(g.vade)}</td>
              <td className={'sag ' + gecikmeRenk(g.gecikmeGun)}>{g.gecikmeGun} gün</td></tr>
          ))}
          {v.geciken.length > 0 && (
            <tr className="top"><td colSpan={6}>Toplam · {v.ozet.geciken} çalışanın periyodik muayenesi gecikti</td>
              <td className="sag">{v.ozet.geciken90} × 90+ gün</td></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

/** ZİYARETLER - onaylı defter; firma bazında süre. */
export function ZiyaretTablosu({ v }: { v: IsgIcmali }) {
  const o = v.ozet;
  return (
    <div className="lb-kalite">
      <div>
        <div className="lb-bas">Ziyaretler <span className="ki-soluk">onaylı defter imzası: işyeri hekimi + işveren</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Tarih</th><th>Firma</th><th>Tür</th><th>Hekim</th><th className="sag">Süre</th><th>Defter</th></tr></thead>
          <tbody>
            {v.ziyaretler.length === 0 && <tr><td colSpan={6} className="bos">Bu dönemde ziyaret yok.</td></tr>}
            {v.ziyaretler.map(z => (
              <tr key={z.id}><td>{tarihKisa(z.tarih)}</td><td>{z.firma}</td><td>{z.tur}</td><td>{z.hekim || '—'}</td>
                <td className="sag">{z.sureDk} dk</td>
                <td>{z.imzali ? <span className="bo-rz ok">İmzalı</span> : <span className="bo-rz kir">Defter imzası eksik</span>}
                  {z.defterSayfa && <span className="ki-soluk"> s. {z.defterSayfa}</span>}</td></tr>
            ))}
            {v.ziyaretler.length > 0 && (
              <tr className="top"><td colSpan={4}>Toplam · {o.ziyaret} ziyaret</td><td className="sag">{dk(o.ziyaretDk)} dk</td>
                <td>{o.imzaEksik ? `${o.imzaEksik} imza eksik` : 'tümü imzalı'}</td></tr>
            )}
          </tbody>
        </table>
      </div>
      <div>
        <div className="lb-bas">Firma Bazında Süre <span className="ki-soluk">plan = sözleşme dakikası ya da çalışan × tehlike katsayısı</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Firma</th><th className="sag">Ziyaret</th><th className="sag">Ziyaret dk</th><th className="sag">Muayene dk</th>
            <th className="sag">Toplam</th><th className="sag">Plan</th><th className="sag">Eksik</th></tr></thead>
          <tbody>
            {v.sureler.length === 0 && <tr><td colSpan={7} className="bos">Süre kaydı yok.</td></tr>}
            {v.sureler.map(s => (
              <tr key={s.id}><td>{s.ad}</td><td className="sag">{tire(s.ziyaret)}</td><td className="sag">{dk(s.ziyaretDk)}</td>
                <td className="sag">{dk(s.muayeneDk)}</td><td className="sag"><b>{dk(s.toplamDk)}</b></td><td className="sag">{dk(s.planDk)}</td>
                <td className={'sag' + (s.eksikDk ? ' kir' : '')}>{s.eksikDk ? dk(s.eksikDk) : '—'}</td></tr>
            ))}
            {v.sureler.length > 0 && (
              <tr className="top"><td>Toplam</td><td className="sag">{o.ziyaret}</td><td className="sag">{dk(o.ziyaretDk)}</td><td className="sag">{dk(o.muayeneDk)}</td>
                <td className="sag">{dk(o.gercekDk)}</td><td className="sag">{dk(o.planDk)}</td><td className="sag">{dk(o.sureEksikDk)}</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

/** OLAYLAR - iş kazası / meslek hastalığı şüphesi / ramak kala; SGK bildirim süresi. */
export function OlayTablosu({ v }: { v: IsgIcmali }) {
  const o = v.ozet;
  return (
    <>
      <div className="lb-bas">İş Kazası / Meslek Hastalığı / Ramak Kala <span className="ki-soluk">SGK bildirimi olaydan sonra 3 iş günü içinde · ramak kala bildirim gerektirmez</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Tür</th><th>Firma</th><th>Bölüm</th><th>Çalışan</th><th>Yaralanma / Bulgu</th><th className="sag">Gün Kaybı</th>
          <th>SGK Bildirimi</th><th>Durum</th></tr></thead>
        <tbody>
          {v.olaylar.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde olay kaydı yok.</td></tr>}
          {v.olaylar.map(x => (
            <tr key={x.id}><td>{tarihKisa(x.tarih)}</td>
              <td><span className={'bo-rz ' + (x.tur === 1 ? 'kir' : x.tur === 2 ? 'mor' : 'sari')}>{x.turAdi}</span></td>
              <td>{x.firma}</td><td>{x.bolum || '—'}</td><td>{x.calisan || '—'}</td><td>{x.yaralanma || '—'}</td>
              <td className="sag">{tire(x.gunKaybi)}</td>
              <td>{!x.bildirimGerekir ? <span className="ki-soluk">gerekmez</span>
                : x.sgkBildirim ? <span className={x.sgkGec ? 'kir' : ''}>{tarihKisa(x.sgkBildirim)} · {x.sgkGec ? 'gecikti' : 'süresinde'}</span>
                : <span className={'bo-rz ' + (x.sgkGec ? 'kir' : 'sari')}>{x.sgkGec ? 'bildirilmedi · süre geçti' : `son gün ${tarihKisa(x.sgkSon)}`}</span>}</td>
              <td><span className={'bo-rz ' + (x.acik ? 'sari' : 'ok')}>{x.acik ? 'Açık' : 'Kapandı'}</span></td></tr>
          ))}
          {v.olaylar.length > 0 && (
            <tr className="top"><td colSpan={6}>Toplam · {o.kaza} iş kazası · {o.meslekHastaligi} meslek hastalığı şüphesi · {o.ramakKala} ramak kala</td>
              <td className="sag">{o.gunKaybi}</td><td colSpan={2}>{o.sgkGec ? `${o.sgkGec} geç bildirim` : 'geç bildirim yok'}</td></tr>
          )}
        </tbody>
      </table>
    </>
  );
}

/** HİZMET BEDELİ & SÖZLEŞME - aylık bedel kartta; fatura / tahsil / bakiye firmanın carisinden. */
export function HizmetTablosu({ v }: { v: IsgIcmali }) {
  const t = v.hizmetToplam;
  return (
    <>
      <div className="lb-bas">Hizmet Bedeli ve Sözleşme <span className="ki-soluk">aylık bedel firma kartından · faturalanan / tahsil firmanın carisinden ·
        bakiye = devreden + faturalanan − tahsil</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Firma</th><th className="sag">Aylık Bedel</th><th className="sag">Devreden</th><th className="sag">Faturalanan</th>
          <th className="sag">Tahsil Edilen</th><th className="sag">Bakiye</th><th>Tahsil</th><th>Sözleşme Bitişi</th><th>Kalan</th></tr></thead>
        <tbody>
          {v.hizmet.length === 0 && <tr><td colSpan={9} className="bos">Firma yok.</td></tr>}
          {v.hizmet.map(h => {
            const s = sozlesmeRozeti(h.kalanGun); const tr = tahsilRozeti(h.tahsilDurumu);
            return (
              <tr key={h.id}><td>{h.ad}</td><td className="sag">{h.aylikUcret ? p(h.aylikUcret) : '—'}</td>
                <td className="sag">{h.devreden ? p(h.devreden) : '—'}</td><td className="sag">{p(h.faturalanan)}</td><td className="sag">{p(h.tahsil)}</td>
                <td className={'sag' + (h.bakiye > 0 ? ' kir' : '')}><b>{p(h.bakiye)}</b></td>
                <td><span className={'bo-rz ' + tr.renk}>{tr.ad}</span></td>
                <td>{h.sozlesmeBit ? tarihKisa(h.sozlesmeBit) : '—'}</td><td><span className={'bo-rz ' + s.renk}>{s.ad}</span></td></tr>
            );
          })}
          {v.hizmet.length > 0 && (
            <tr className="top"><td>Toplam · {v.hizmet.length} firma</td><td className="sag">{p(t.aylikUcret)}</td><td className="sag">{p(t.devreden)}</td>
              <td className="sag">{p(t.faturalanan)}</td><td className="sag">{p(t.tahsil)}</td><td className="sag">{p(t.bakiye)}</td>
              <td colSpan={3}>{v.ozet.sozlesme60 ? `${v.ozet.sozlesme60} sözleşme 60 gün içinde bitiyor` : ''}</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Firma ile fatura arasında doğrudan bağ yok; faturalanan, firmanın carisine dönemde kesilen belgelerdir.
        Aylık bedel girilmemiş firmada "—" görünür (firma kartı › Atama &amp; Sözleşme).</div>
    </>
  );
}
