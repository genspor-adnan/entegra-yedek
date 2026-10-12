import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { EczaneIcmali } from '../../api/uclar/eczaneIcmal';
import { para } from '../../bilesenler/bicim';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { adet, itsSinifRozeti, kacakRozeti, miadRozeti, yuzde } from './eczaneIcmalOrtak';

/** Eczane / ilaç icmalinin sekme tabloları. Rakamlar ve toplamlar sunucudan gelir. */

const p = (n: number) => para.format(n);
const tire = (n: number) => (Math.abs(n) > 0.005 ? p(n) : '—');

function Cubuk({ oran }: { oran: number }) {
  return <span className="lb-bar"><span style={{ width: `${Math.max(0, Math.min(100, oran))}%` }} /></span>;
}

/** SERVİSLER - tık tek, Ctrl / Shift çoklu; ▸ en çok tüketilen 3 ilaç; seçilenler A4'ü süzer. */
export function ServisTablosu({ v, secili, setSecili }: { v: EczaneIcmali; secili: number[]; setSecili(x: number[]): void }) {
  const son = useRef<number | null>(null);
  const [acik, setAcik] = useState<number[]>([]);
  const tikla = (id: number, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, id, v.servisler.map(s => s.id), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = id;
  };
  const ac = (id: number, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(id) ? a.filter(x => x !== id) : [...a, id]) };
  const hepsi = v.servisler.length > 0 && v.servisler.every(s => secili.includes(s.id));
  const t = v.toplam;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : v.servisler.map(s => s.id))} /></th>
          <th>Servis</th><th className="sag">Hasta</th><th className="sag">Kalem</th><th className="sag">Çıkış (adet)</th><th className="sag">Maliyet</th>
          <th className="sag">Faturalanan</th><th className="sag">Faturalanmayan</th><th>Kaçak Oranı</th><th className="sag">Hasta Başı</th>
          <th className="sag">İade</th><th>Maliyet Payı</th></tr></thead>
        <tbody>
          {v.servisler.length === 0 && <tr><td colSpan={12} className="bos">Bu dönemde ilaç tüketimi yok.</td></tr>}
          {v.servisler.map(s => {
            const sec = secili.includes(s.id); const k = kacakRozeti(s.ozet.kacakOrani);
            return (
              <Fragment key={s.id}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(s.id, e)} title="Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık">
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(s.id, e)} /></td>
                  <td><a className="ki-lnk" onClick={e => ac(s.id, e)}>{acik.includes(s.id) ? '▾' : '▸'}</a> <b>{s.ad}</b></td>
                  <td className="sag">{s.ozet.hasta}</td><td className="sag">{s.ozet.kalem}</td><td className="sag">{adet(s.ozet.miktar)}</td>
                  <td className="sag">{p(s.ozet.maliyet)}</td><td className="sag">{tire(s.ozet.faturalanan)}</td>
                  <td className={'sag' + (s.ozet.faturalanmayan > 0 ? ' kir' : '')}>{tire(s.ozet.faturalanmayan)}</td>
                  <td><span className={'bo-rz ' + k.renk}>{k.ad}</span></td>
                  <td className="sag">{tire(s.ozet.hastaBasi)}</td><td className="sag">{tire(s.iade)}</td>
                  <td>{s.pay != null && <Cubuk oran={s.pay} />} {yuzde(s.pay)}</td>
                </tr>
                {acik.includes(s.id) && (
                  <tr className="lb-alt"><td /><td colSpan={11}>En çok tüketilen: {s.enCok.map(x => `${x.ad} ${adet(x.miktar)} adet (${p(x.maliyet)})`).join('  ·  ') || '—'}</td></tr>
                )}
              </Fragment>
            );
          })}
          {v.servisler.length > 0 && (
            <tr className="top"><td /><td>Toplam · {v.servisler.length} servis</td><td className="sag">{t.hasta}</td><td className="sag">{t.kalem}</td>
              <td className="sag">{adet(t.miktar)}</td><td className="sag">{p(t.maliyet)}</td><td className="sag">{p(t.faturalanan)}</td>
              <td className="sag">{p(t.faturalanmayan)}</td><td>{yuzde(t.kacakOrani)}</td><td className="sag">{p(t.hastaBasi)}</td>
              <td className="sag">{tire(v.ozet.iade)}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Tüketim: yatan hastada uygulanmış ilaç / serum dozu (eMAR), ameliyathanede ameliyat sarfındaki ilaç, ayaktan ve
        acilde başvuruya yazılmış ilaç. Maliyet = adet × stok maliyeti (giriş belgelerinden ağırlıklı ortalama). Hasta başı = maliyet / hasta.
        {v.ozet.eslesmeyen > 0 && ` ${v.ozet.eslesmeyen} uygulamanın order'ı ilaç kartına / stoğa bağlı değil - maliyeti ve fatura eşleşmesi hesaplanamadı.`}</div>
    </>
  );
}

/** İLAÇLAR - maliyete göre ilk 15, toplam satırı dönemin tamamı (sunucudan). */
export function IlacTablosu({ v }: { v: EczaneIcmali }) {
  const [hepsi, setHepsi] = useState(false);
  const liste = hepsi ? v.ilaclar : v.ilaclar.slice(0, 15);
  const t = v.ilacToplam;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>İlaç</th><th>Etken Madde</th><th className="sag">Servis</th><th className="sag">Adet</th><th className="sag">Birim Maliyet</th>
          <th className="sag">Maliyet</th><th className="sag">Faturalanan</th><th className="sag">Faturalanmayan</th><th>Tüketim</th></tr></thead>
        <tbody>
          {v.ilaclar.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde ilaç tüketimi yok.</td></tr>}
          {liste.map(i => (
            <tr key={`${i.stokId}-${i.ad}`}>
              <td><b>{i.ad}</b>{i.eslesmez && <span className="bo-rz pas lb-k">stoğa bağlı değil</span>}</td>
              <td>{i.etken || '—'}</td><td className="sag">{i.servis}</td><td className="sag">{adet(i.miktar)}</td>
              <td className="sag">{tire(i.birimMaliyet)}</td><td className="sag">{tire(i.maliyet)}</td><td className="sag">{tire(i.faturalanan)}</td>
              <td className={'sag' + (i.faturalanmayan > 0 ? ' kir' : '')}>{i.faturalanmayan > 0 ? `${p(i.faturalanmayan)} (${adet(i.faturalanmayanAdet)})` : '—'}</td>
              <td><Cubuk oran={t.maliyet > 0 ? (100 * i.maliyet) / t.maliyet : 0} /></td>
            </tr>
          ))}
          {v.ilaclar.length > 0 && (
            <tr className="top"><td colSpan={3}>Toplam · {v.ilaclar.length} ilaç (dönemin tamamı)</td><td className="sag">{adet(t.miktar)}</td><td />
              <td className="sag">{p(t.maliyet)}</td><td className="sag">{p(t.faturalanan)}</td><td className="sag">{p(t.faturalanmayan)}</td><td /></tr>
          )}
        </tbody>
      </table>
      {v.ilaclar.length > 15 && (
        <div className="ki-not"><a className="ki-lnk" onClick={() => setHepsi(h => !h)}>{hepsi ? 'İlk 15\'i göster' : `Tümünü göster (${v.ilaclar.length})`}</a></div>
      )}
    </>
  );
}

/** FATURALANMAYAN - uygulanan / düşülen ilaç ↔ başvurudaki aynı stok satırı. Hasta adı yok, protokol no var. */
export function FaturasizTablosu({ v, basvuruAc }: { v: EczaneIcmali; basvuruAc(id: number): void }) {
  const [hepsi, setHepsi] = useState(false);
  const liste = hepsi ? v.faturasiz : v.faturasiz.slice(0, 30);
  return (
    <>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Protokol No</th><th>Servis</th><th>İlaç</th><th className="sag">Uygulanan</th><th className="sag">Faturada</th>
          <th className="sag">Eksik Adet</th><th className="sag">Tutar (satış)</th><th>Durum</th></tr></thead>
        <tbody>
          {v.faturasiz.length === 0 && <tr><td colSpan={9} className="bos">Bu dönemde faturaya girmeyen ilaç yok.</td></tr>}
          {liste.map((f, n) => (
            <tr key={n}>
              <td>{f.tarih ? tarihKisa(f.tarih) : '—'}</td>
              <td>{f.belgeId > 0 ? <a className="ki-lnk" onClick={() => basvuruAc(f.belgeId)}>{f.protokol || f.belgeId}</a> : f.protokol || '—'}</td>
              <td>{f.servis}</td><td>{f.ilac}</td><td className="sag">{adet(f.uygulanan)}</td><td className="sag">{adet(f.faturada)}</td>
              <td className="sag kir">{adet(f.adet)}</td>
              <td className="sag">{f.fiyatYok ? <span className="bo-rz pas" title="Fiyat listesinde fiyatı yok">fiyat yok</span> : p(f.tutar)}</td>
              <td><span className={'bo-rz ' + (f.neden === 'faturada eksik' ? 'sari' : 'kir')}>{f.neden}</span></td>
            </tr>
          ))}
          {v.faturasiz.length > 0 && (
            <tr className="top"><td colSpan={6}>Toplam · {v.faturasiz.length} kayıt (dönemin tamamı)</td><td className="sag">{adet(v.ozet.faturalanmayanAdet)}</td>
              <td className="sag">{p(v.ozet.faturalanmayan)}</td><td /></tr>
          )}
        </tbody>
      </table>
      {v.faturasiz.length > 30 && (
        <div className="ki-not"><a className="ki-lnk" onClick={() => setHepsi(h => !h)}>{hepsi ? 'En büyük 30\'u göster' : `Tümünü göster (${v.faturasiz.length})`}</a></div>
      )}
      <div className="ki-not">Başvuru × ilaç bazında uygulanan adet, başvurudaki aynı stok satırından fazlaysa fark listelenir. Ameliyatta "faturaya
        eklenmez" (pakete dahil) işaretli sarf beklenmez. Tutar faturadaki birim fiyattan, satır yoksa fiyat listesinden. Nedeni sistem bilmez -
        her satır kontrol içindir (paket kapsamı Medula'da kesinleşir).</div>
    </>
  );
}

/** MİAD / İADE - 90 gün içindeki lotlar + servisten iade ve imha. */
export function MiadIadeTablosu({ v }: { v: EczaneIcmali }) {
  const o = v.ozet;
  return (
    <div className="lb-kalite">
      <div>
        <div className="lb-bas">Miadı Dolan / Yaklaşan Lotlar <span className="ki-soluk">bugün {tarihKisa(o.bugun)} · 90 gün içinde</span></div>
        <table className="hi-tablo">
          <thead><tr><th>İlaç</th><th>Lot</th><th>Depo</th><th>SKT</th><th className="sag">Kalan Gün</th><th className="sag">Miktar</th>
            <th className="sag">Tutar</th><th>Durum</th></tr></thead>
          <tbody>
            {v.miad.length === 0 && <tr><td colSpan={8} className="bos">90 gün içinde miadı dolan ilaç lotu yok (lot takibi yapılan stoklar).</td></tr>}
            {v.miad.map((m, n) => {
              const r = miadRozeti(m);
              return (
                <tr key={n}><td>{m.ad}</td><td>{m.lot || '—'}</td><td>{m.depo || '—'}</td><td>{tarihKisa(m.skt)}</td>
                  <td className={'sag' + (m.kalanGun < 0 ? ' kir' : '')}>{m.kalanGun}</td><td className="sag">{adet(m.miktar)}</td>
                  <td className="sag">{tire(m.tutar)}</td><td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>
              );
            })}
            {v.miad.length > 0 && (
              <tr className="top"><td colSpan={6}>Toplam · {v.miad.length} lot · dolmuş {o.miadDolmus} · ≤30 {o.miad30} · ≤90 {o.miad90}</td>
                <td className="sag">{p(o.miadTutar)}</td><td /></tr>
            )}
          </tbody>
        </table>
      </div>
      <div>
        <div className="lb-bas">Servisten İade <span className="ki-soluk">eczacı kararı</span></div>
        <table className="hi-tablo">
          <thead><tr><th>Tarih</th><th>Servis</th><th>İlaç</th><th className="sag">Adet</th><th className="sag">Tutar</th><th>Karar</th></tr></thead>
          <tbody>
            {v.iadeler.length === 0 && <tr><td colSpan={6} className="bos">Bu dönemde servisten iade yok.</td></tr>}
            {v.iadeler.map((i, n) => (
              <tr key={n}><td>{tarihKisa(i.tarih)}</td><td>{i.servis}</td><td>{i.ilac}{i.gerekce && <div className="ki-soluk">{i.gerekce}</div>}</td>
                <td className="sag">{adet(i.miktar)}</td><td className="sag">{tire(i.tutar)}</td>
                <td><span className={'bo-rz ' + (i.kararKod === 1 ? 'ok' : i.kararKod === 0 ? 'pas' : 'sari')}>{i.karar}</span></td></tr>
            ))}
            {v.iadeler.length > 0 && (
              <tr className="top"><td colSpan={3}>Toplam · {o.iadeKayit} iade</td><td className="sag">{adet(o.iadeAdet)}</td><td className="sag">{p(o.iade)}</td>
                <td>imha {p(o.imha)}</td></tr>
            )}
          </tbody>
        </table>
        <div className="ki-not">İmha: dönemde {o.imhaTutanak} tutanak, {p(o.imha)} (eczane imha satırları).</div>
      </div>
    </div>
  );
}

/** İTS - tür / durum özeti + hatalı bildirimler. */
export function ItsTablosu({ v, itsAc }: { v: EczaneIcmali; itsAc(): void }) {
  const o = v.ozet;
  return (
    <>
      <div className="lb-bas">İTS Bildirim Özeti <span className="ki-soluk">tür ve durum · iptal ve test bildirimi sayılmaz</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Tür</th><th className="sag">Bildirim</th><th className="sag">Başarılı</th><th className="sag">Hatalı</th><th className="sag">Bekleyen</th><th>Başarı</th></tr></thead>
        <tbody>
          {v.itsOzet.length === 0 && <tr><td colSpan={6} className="bos">Bu dönemde İTS bildirimi yok.</td></tr>}
          {v.itsOzet.map(x => (
            <tr key={x.tur}><td>{x.tur}</td><td className="sag">{x.bildirim}</td><td className="sag">{x.basarili}</td>
              <td className={'sag' + (x.hatali ? ' kir' : '')}>{x.hatali || '—'}</td><td className="sag">{x.bekleyen || '—'}</td><td>{yuzde(x.basari)}</td></tr>
          ))}
          {v.itsOzet.length > 0 && (
            <tr className="top"><td>Toplam</td><td className="sag">{o.itsBildirim}</td><td className="sag">{o.itsBasarili}</td><td className="sag">{o.itsHatali}</td>
              <td className="sag">{o.itsBekleyen}</td><td>{yuzde(o.itsBasari)}</td></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Hatalı Bildirimler <span className="ki-soluk">sınıf: veri = kullanıcı düzeltir · servis = otomatik tekrar · yetki = GLN / sözleşme</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Tarih</th><th>Tür</th><th>Protokol / Belge</th><th>İlaç</th><th>Seri No</th><th>Hata Kodu</th><th>Mesaj</th><th>Sınıf</th>
          <th className="sag">Deneme</th></tr></thead>
        <tbody>
          {v.itsHatali.length === 0 && <tr><td colSpan={9} className="bos">Hatalı bildirim yok.</td></tr>}
          {v.itsHatali.map(h => {
            const r = itsSinifRozeti(h.sinif);
            return (
              <tr key={h.id}><td>{tarihKisa(h.tarih)}</td><td>{h.tur}</td><td>{h.protokol || '—'}</td>
                <td>{h.ilac || '—'}{h.kalem > 1 && <span className="ki-soluk"> +{h.kalem - 1} kalem</span>}</td><td>{h.seri || '—'}</td>
                <td>{h.hataKodu || '—'}</td><td>{h.mesaj}</td><td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td><td className="sag">{h.deneme}</td></tr>
            );
          })}
        </tbody>
      </table>
      {v.itsHatali.length > 0 && <div className="ki-not"><a className="ki-lnk" onClick={itsAc}>İTS Bildirimleri ekranında düzelt / yeniden gönder →</a></div>}
    </>
  );
}
