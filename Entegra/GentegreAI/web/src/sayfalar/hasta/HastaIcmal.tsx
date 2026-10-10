import { Fragment, useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { HastaIcmali, IcmalTahsilat } from '../../api/uclar/hastaIcmal';
import { AntetLogo } from '../../bilesenler/AntetLogo';
import { useOturum } from '../../kimlik/OturumBaglami';

/**
 * HASTA İCMALİ `/hasta-icmal/:hastaId` — mockup Ekranlar/Kayıt Kabul/
 * hasta_icmal.html (kullanıcı 10.10.2026: "hasta icmal ekranını kodla").
 *
 * Bütün rakamlar SUNUCUDAN (HastaIcmalUclari): ekran yalnız çizer ve hareket
 * özetinin yürüyen bakiyesini sıralar. Kurum payı bilgi amaçlı; hastaya
 * söylenen rakam kalan borçtur. Avans kalan borçtan kendiliğinden düşmez.
 */
const para = (n: number) =>
  n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const tarih = (t: string | null | undefined) => (t ? new Date(t).toLocaleDateString('tr-TR') : '—');
const isoGun = (d: Date) => d.toISOString().slice(0, 10);

type Sekme = 'basvuru' | 'hizmet' | 'tahsilat' | 'provizyon' | 'hareket';

/** Ödeme rozeti: kasa hesabının türünden (K nakit, P POS, B banka). */
function odemeRozeti(t: IcmalTahsilat): { ad: string; renk: string } {
  if (t.iptal) return { ad: 'iptal', renk: 'pas' };
  if (t.iade) return { ad: 'iade', renk: 'kir' };
  if (t.hesapTuru === 'K') return { ad: 'nakit', renk: 'sari' };
  if (t.hesapTuru === 'P') return { ad: 'POS', renk: 'mavi' };
  if (t.hesapTuru === 'B') return { ad: 'havale', renk: 'mavi' };
  return { ad: t.tur.toLocaleLowerCase('tr-TR'), renk: '' };
}

export function HastaIcmal() {
  const { hastaId } = useParams();
  const [arama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const bugun = new Date();
  const [bas, setBas] = useState(isoGun(new Date(bugun.getFullYear(), bugun.getMonth() - 12, bugun.getDate())));
  const [bit, setBit] = useState(isoGun(bugun));
  const [veri, setVeri] = useState<HastaIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('basvuru');
  const [acik, setAcik] = useState<Record<number, boolean>>({});
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const geri = arama.get('geri');

  useEffect(() => {
    if (!hastaId) return;
    setHata('');
    api.hastaIcmal(Number(hastaId), bas, bit).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [hastaId, bas, bit]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  /** HAREKET ÖZETİ: başvuru hasta payı borç, tahsilat alacak, iade borç. */
  const hareketler = useMemo(() => {
    if (!veri) return [];
    const satir = [
      ...veri.basvurular.filter(b => !b.iptal).map(b => ({
        t: b.tarih ?? '', belge: b.no, aciklama: `Başvuru · ${b.bolum || '—'} · hasta payı`,
        borc: b.hastaPayi, alacak: 0 })),
      ...veri.tahsilatlar.filter(t => !t.iptal).map(t => ({
        t: t.tarih ?? '', belge: t.makbuzNo, aciklama: `${t.tur}${t.basvuruNo ? ` · ${t.basvuruNo}` : ''}`,
        borc: t.iade ? t.tutar : 0, alacak: t.iade ? 0 : t.tutar })),
    ].sort((a, b) => a.t.localeCompare(b.t));
    let bakiye = 0;
    return satir.map(s => { bakiye += s.borc - s.alacak; return { ...s, bakiye } });
  }, [veri]);

  const o = veri?.ozet;
  const yas = veri?.hasta.dogumTarihi
    ? Math.floor((Date.now() - new Date(veri.hasta.dogumTarihi).getTime()) / 31557600000) : null;
  const cins = veri?.hasta.cinsiyet === 1 ? 'E' : veri?.hasta.cinsiyet === 2 ? 'K' : '';
  const kurumlar = [...new Set((veri?.basvurular ?? []).map(b => b.kurum))].join(' + ');
  const gecerli = (veri?.basvurular ?? []).filter(b => !b.iptal);

  const kutu = (bas2: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{bas2}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );

  return (
    <div className="hi">
      <style>{stil}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Hasta İcmali{veri ? ` — ${veri.hasta.ad}` : ''}</h1>
          <span className="yol">Kayıt Kabul › Hasta › Hesap İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <button className="hi-ana" disabled={!veri} onClick={() => window.print()}>🖨️ Yazdır (A4 İcmal)</button>
        <span className="sp" />
        {geri && <button onClick={() => git(geri)}>↩ Geri Dön</button>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">👤 <b>{veri.hasta.ad}</b>{veri.hasta.tc && ` · TC ${veri.hasta.tc}`}{yas != null && ` · ${yas} yaş`}{cins && ` · ${cins}`}</div>
          {veri.hasta.dosyaNo && <div className="sel">📁 Dosya No: <b>{veri.hasta.dosyaNo}</b></div>}
          {kurumlar && <div className="sel">🏥 Kurum: <b>{kurumlar}</b></div>}
          <div className="sel">📅 Dönem:
            <input type="date" value={bas} onChange={e => e.target.value && setBas(e.target.value)} />–
            <input type="date" value={bit} onChange={e => e.target.value && setBit(e.target.value)} />
          </div>
          <span className="sp" />
          {o.kalan > 0.005 && <span className="bo-rz kir">Açık borç var</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Toplam Hizmet', `${para(o.toplam)} ₺`, `${o.basvuru} başvuru · ${o.kalem} kalem`)}
          {kutu('Kurum Payı', `${para(o.kurumPayi)} ₺`, 'SGK + özel sigorta', 'mor')}
          {kutu('Hasta Payı', `${para(o.hastaPayi)} ₺`, 'katılım + fark + ücretli')}
          {kutu('İskonto', `${para(o.iskonto)} ₺`, 'satır iskontoları', 'uy')}
          {kutu('Tahsil Edilen', `${para(o.tahsil)} ₺`, 'iptal hariç', 'iyi')}
          {kutu('İade', `${para(o.iade)} ₺`, 'iade makbuzları')}
          {kutu('Kalan Borç', `${para(o.kalan)} ₺`, 'hastadan alınacak', o.kalan > 0.005 ? 'teh' : 'iyi')}
          {kutu('Avans / Alacak', `${para(o.avans)} ₺`, 'mahsup edilmedi')}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {([['basvuru', 'Başvurular', veri.basvurular.length], ['hizmet', 'Hizmetler', veri.hizmetler.length],
                 ['tahsilat', 'Tahsilatlar', veri.tahsilatlar.length], ['provizyon', 'Kurum Provizyonları', veri.provizyonlar.length],
                 ['hareket', 'Hareket Özeti', null]] as [Sekme, string, number | null][]).map(([k, ad, n]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{n != null && <span className="b">{n}</span>}
                </div>
              ))}
            </div>

            {sekme === 'basvuru' && (
              <table className="hi-tablo">
                <thead><tr><th>Tarih</th><th>Başvuru No</th><th>Bölüm / Hekim</th><th>Kurum</th>
                  <th className="sag">Toplam</th><th className="sag">İskonto</th><th className="sag">Kurum Payı</th>
                  <th className="sag">Hasta Payı</th><th className="sag">Tahsil</th><th className="sag">Kalan</th><th>Durum</th></tr></thead>
                <tbody>
                  {veri.basvurular.map(b => (
                    <Fragment key={b.id}>
                      <tr className={'ac' + (b.iptal ? ' iptal' : '') + (acik[b.id] ? ' sec' : '')}
                          onClick={() => setAcik(a => ({ ...a, [b.id]: !a[b.id] }))}>
                        <td><span className="ok">{acik[b.id] ? '▾' : '▸'}</span>{tarih(b.tarih)}</td>
                        <td>{b.no}</td><td>{b.bolum || '—'}{b.hekim && ` · ${b.hekim}`}</td><td>{b.kurum}</td>
                        <td className="sag">{para(b.toplam)}</td><td className="sag">{b.iskonto ? para(b.iskonto) : '—'}</td>
                        <td className="sag">{para(b.kurumPayi)}</td><td className="sag">{para(b.hastaPayi)}</td>
                        <td className="sag">{para(b.tahsil)}</td>
                        <td className={'sag' + (b.kalan > 0.005 && !b.iptal ? ' kir' : '')}>{para(b.kalan)}</td>
                        <td>{b.iptal ? <span className="bo-rz pas">İptal</span>
                          : b.kalan > 0.005 ? <span className="bo-rz sari">{b.tahsil > 0 ? 'Kısmi' : 'Açık'}</span>
                          : <span className="bo-rz ok">Kapandı</span>}</td>
                      </tr>
                      {acik[b.id] && (
                        <tr className="det"><td colSpan={11}>
                          {veri.hizmetler.filter(h => h.basvuruId === b.id)
                            .map(h => `${h.kod} ${h.ad} ${h.adet}×${para(h.birimFiyat)} = ${para(h.tutar)}`).join(' · ') || 'Hizmet satırı yok.'}
                        </td></tr>
                      )}
                    </Fragment>
                  ))}
                  <tr className="top"><td colSpan={4}>Toplam (iptal hariç · {gecerli.length} başvuru)</td>
                    <td className="sag">{para(o.toplam)}</td><td className="sag">{para(o.iskonto)}</td>
                    <td className="sag">{para(o.kurumPayi)}</td><td className="sag">{para(o.hastaPayi)}</td>
                    <td className="sag">{para(gecerli.reduce((t, b) => t + b.tahsil, 0))}</td>
                    <td className="sag">{para(o.kalan)}</td><td /></tr>
                </tbody>
              </table>
            )}

            {sekme === 'hizmet' && (
              <table className="hi-tablo">
                <thead><tr><th>Tarih</th><th>Başvuru</th><th>Kod</th><th>Hizmet</th><th className="sag">Adet</th>
                  <th className="sag">Birim Fiyat</th><th className="sag">Tutar</th><th className="sag">Kurum</th><th className="sag">Hasta</th></tr></thead>
                <tbody>
                  {veri.hizmetler.map((h, i) => (
                    <tr key={i}><td>{tarih(h.tarih)}</td><td>{h.basvuruNo}</td><td>{h.kod}</td><td>{h.ad}</td>
                      <td className="sag">{h.adet}</td><td className="sag">{para(h.birimFiyat)}</td><td className="sag">{para(h.tutar)}</td>
                      <td className="sag">{para(h.kurumPayi)}</td><td className="sag">{para(h.hastaPayi)}</td></tr>
                  ))}
                </tbody>
              </table>
            )}

            {sekme === 'tahsilat' && (
              <table className="hi-tablo">
                <thead><tr><th>Makbuz No</th><th>Tarih</th><th>Banko</th><th>Ödeme</th><th>İşlem</th><th>Başvuru</th>
                  <th className="sag">Tutar</th></tr></thead>
                <tbody>
                  {veri.tahsilatlar.length === 0 && <tr><td colSpan={7} className="bos">Bu dönemde tahsilat yok.</td></tr>}
                  {veri.tahsilatlar.map(t => {
                    const r = odemeRozeti(t);
                    return (
                      <tr key={t.id} className={t.iptal ? 'iptal' : ''}>
                        <td>{t.makbuzNo}</td><td>{tarih(t.tarih)}</td><td>{t.banko || '—'}</td>
                        <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td><td>{t.tur}</td><td>{t.basvuruNo || '—'}</td>
                        <td className={'sag' + (t.iade ? ' kir' : '')}>{t.iade ? '−' : ''}{para(t.tutar)}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}

            {sekme === 'provizyon' && (
              <table className="hi-tablo">
                <thead><tr><th>Başvuru</th><th>Provizyon / Takip No</th><th className="sag">SGK</th>
                  <th className="sag">Özel Sigorta</th><th className="sag">Satır</th><th>Durum</th></tr></thead>
                <tbody>
                  {veri.provizyonlar.length === 0 && <tr><td colSpan={6} className="bos">Kurum payı olan başvuru yok.</td></tr>}
                  {veri.provizyonlar.map((p, i) => (
                    <tr key={i}><td>{p.basvuruNo}</td><td>{p.provizyonNo || '—'}</td>
                      <td className="sag">{para(p.sgk)}</td><td className="sag">{para(p.ozelSigorta)}</td>
                      <td className="sag">{p.satir}</td>
                      <td>{p.provizyonNo ? <span className="bo-rz ok">Provizyonlu</span> : <span className="bo-rz sari">Provizyon yok</span>}</td></tr>
                  ))}
                </tbody>
              </table>
            )}

            {sekme === 'hareket' && (
              <table className="hi-tablo">
                <thead><tr><th>Tarih</th><th>Belge</th><th>Açıklama</th><th className="sag">Borç</th>
                  <th className="sag">Alacak</th><th className="sag">Bakiye</th></tr></thead>
                <tbody>
                  {hareketler.map((h, i) => (
                    <tr key={i}><td>{tarih(h.t)}</td><td>{h.belge}</td><td>{h.aciklama}</td>
                      <td className="sag">{h.borc ? para(h.borc) : '—'}</td><td className="sag">{h.alacak ? para(h.alacak) : '—'}</td>
                      <td className={'sag' + (h.bakiye > 0.005 ? ' kir' : '')}>{para(h.bakiye)}</td></tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>

          {/* A4 ÖNİZLEME: yazdırınca yalnız bu basılır. */}
          <div className="hi-sag">
            <div className="hi-a4">
              <div className="a4-bas">
                <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined} />
                <div><div className="kurum">{String(antet?.unvan ?? '')}</div>
                  <div className="kurum-alt">{[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon].filter(x => x && String(x).trim()).join(' · ')}</div></div>
                <div className="a4-tarih">Düzenleme: {new Date().toLocaleString('tr-TR')}<br />Düzenleyen: {kullanici?.ad ?? ''}</div>
              </div>
              <h3>HASTA HESAP İCMALİ</h3>
              <div className="a4-hasta">
                <span>Hasta: <b>{veri.hasta.ad}</b></span><span>Dosya No: {veri.hasta.dosyaNo || '—'}</span>
                <span>T.C. Kimlik: {veri.hasta.tc || '—'}</span><span>Dönem: {tarih(veri.donem.bas)} - {tarih(veri.donem.bit)}</span>
              </div>
              <table className="a4-t">
                <thead><tr><th>Tarih</th><th>Başvuru</th><th>Toplam</th><th>Kurum</th><th>Hasta</th><th>Tahsil</th><th>Kalan</th></tr></thead>
                <tbody>
                  {gecerli.map(b => (
                    <tr key={b.id}><td>{tarih(b.tarih)}</td><td>{b.no}</td><td>{para(b.toplam)}</td>
                      <td>{para(b.kurumPayi)}</td><td>{para(b.hastaPayi)}</td><td>{para(b.tahsil)}</td><td>{para(b.kalan)}</td></tr>
                  ))}
                </tbody>
              </table>
              <table className="a4-toplam"><tbody>
                <tr><td>Toplam hizmet</td><td>{para(o.toplam)} ₺</td></tr>
                <tr><td>Kurum payı</td><td>{para(o.kurumPayi)} ₺</td></tr>
                <tr><td>Hasta payı</td><td>{para(o.hastaPayi)} ₺</td></tr>
                <tr><td>Tahsil edilen</td><td>{para(o.tahsil - o.iade)} ₺</td></tr>
                {o.avans > 0 && <tr><td>Avans (mahsup edilmedi)</td><td>{para(o.avans)} ₺</td></tr>}
                <tr className="kalan"><td>ÖDENECEK KALAN</td><td>{para(o.kalan)} ₺</td></tr>
              </tbody></table>
              <p className="a4-not">Kurum payı bilgi amaçlıdır; hastadan talep edilmez. Bu belge fatura yerine geçmez.</p>
              <div className="a4-imza"><div>Hasta / Yakını<br />Ad Soyad · İmza</div><div>Vezne Yetkilisi<br />Kaşe · İmza</div></div>
            </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

const stil = `
.hi-arac { display:flex; gap:6px; align-items:center; padding:6px 12px; }
.hi-arac button { border:1px solid var(--cizgi,#cdd6e0); border-radius:4px; padding:5px 11px; font-size:12px; background:var(--yuz,#fff); cursor:pointer; }
.hi-arac button.hi-ana { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; border-color:#2f6db3; }
.hi-arac .sp, .hi-serit .sp { flex:1; }
.hi-serit { display:flex; gap:8px; align-items:center; flex-wrap:wrap; padding:6px 12px; background:#f7fafc;
  border-top:1px solid var(--cizgi-ince,#e3e9f0); border-bottom:1px solid var(--cizgi-ince,#e3e9f0); }
.hi-serit .sel { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; background:var(--yuz,#fff); min-height:26px;
  display:flex; align-items:center; gap:6px; padding:0 8px; font-size:12px; }
.hi-serit input[type=date] { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.hi-ozet { display:grid; grid-template-columns:repeat(8,1fr); gap:1px; background:var(--cizgi-ince,#e3e9f0); border-bottom:1px solid var(--cizgi,#cdd6e0); }
@media (max-width:1100px) { .hi-ozet { grid-template-columns:repeat(4,1fr); } }
.hi-kutu { background:var(--yuz,#fff); padding:6px 10px; }
.hi-kutu .bas { font-size:10.5px; color:var(--soluk,#6b7a8b); text-transform:uppercase; letter-spacing:.3px; }
.hi-kutu .deg { font-size:16px; font-weight:bold; color:var(--baslik,#14315a); }
.hi-kutu .alt { font-size:10.5px; color:var(--soluk,#6b7a8b); }
.hi-kutu.mor .deg { color:#6a3fb5; } .hi-kutu.iyi .deg { color:#2e7d46; } .hi-kutu.uy .deg { color:#b7791f; } .hi-kutu.teh .deg { color:#b3261e; }
.hi-govde { display:grid; grid-template-columns:minmax(0,1fr) 440px; gap:10px; padding:10px 12px; }
@media (max-width:1200px) { .hi-govde { grid-template-columns:1fr; } }
.hi-sol .katab { margin-bottom:0; }
.hi-tablo { width:100%; border-collapse:collapse; font-size:12px; background:var(--yuz,#fff); }
.hi-tablo th, .hi-tablo td { border-bottom:1px solid var(--cizgi-ince,#e3e9f0); padding:5px 8px; text-align:left; }
.hi-tablo th { background:#f3f6fa; font-weight:600; }
.hi-tablo .sag { text-align:right; font-family:Consolas,monospace; } .hi-tablo th.sag { font-family:inherit; }
.hi-tablo .kir { color:#b3261e; font-weight:bold; }
.hi-tablo tr.ac { cursor:pointer; } .hi-tablo tr.sec td { background:#eef4fc; }
.hi-tablo tr.iptal td { color:#9aa7b4; text-decoration:line-through; }
.hi-tablo tr.det td { background:#f9fbfd; font-size:11px; color:#3a4c5e; padding-left:26px; }
.hi-tablo tr.top td { font-weight:bold; background:#eef4fb; }
.hi-tablo .ok { display:inline-block; width:12px; color:#2f6db3; }
.hi-tablo td:first-child, .hi-tablo td:nth-child(2) { white-space:nowrap; }
.hi-tablo .bos { color:var(--soluk,#6b7a8b); text-align:center; padding:14px; }
.bo-rz { display:inline-block; border-radius:9px; padding:0 7px; font-size:10.5px; border:1px solid transparent; }
.bo-rz.ok { background:#e2f3e8; color:#2e7d46; } .bo-rz.sari { background:#fdf6e3; color:#8a6218; }
.bo-rz.kir { background:#fbe9e7; color:#b3261e; } .bo-rz.mavi { background:#eef4fc; color:#2f6db3; }
.bo-rz.pas { background:#eceff2; color:#6b7a8b; }
.hi-a4 { background:#fff; color:#111; border:1px solid #d9dee5; padding:14px; font-size:10.5px; box-shadow:0 2px 8px rgba(0,0,0,.06); }
.a4-bas { display:flex; gap:10px; align-items:flex-start; border-bottom:2px solid #1c4374; padding-bottom:6px; }
.a4-bas .logo { width:40px; height:40px; object-fit:contain; }
.a4-bas .kurum { font-weight:bold; font-size:12px; } .a4-bas .kurum-alt { color:#555; }
.a4-tarih { margin-left:auto; text-align:right; color:#555; }
.hi-a4 h3 { text-align:center; margin:8px 0; font-size:13px; letter-spacing:.5px; }
.a4-hasta { display:grid; grid-template-columns:1fr 1fr; gap:2px 10px; border:1px solid #bbb; padding:5px 7px; margin-bottom:6px; }
.a4-t, .a4-toplam { width:100%; border-collapse:collapse; }
.a4-t { table-layout:fixed; font-size:9.5px; } .a4-t td, .a4-t th { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.a4-t th:nth-child(1) { width:15%; } .a4-t th:nth-child(2) { width:20%; }
.a4-t td:nth-child(n+3) { text-overflow:clip; }
.a4-t th, .a4-t td { border:1px solid #ccc; padding:2px 4px; text-align:right; } .a4-t th:nth-child(-n+2), .a4-t td:nth-child(-n+2) { text-align:left; }
.a4-toplam { width:60%; margin:6px 0 0 auto; } .a4-toplam td { padding:2px 4px; } .a4-toplam td:last-child { text-align:right; }
.a4-toplam tr.kalan td { font-weight:bold; color:#b3261e; border-top:1px solid #333; }
.a4-not { color:#555; margin:8px 0; }
.a4-imza { display:grid; grid-template-columns:1fr 1fr; gap:20px; margin-top:34px; text-align:center; }
.a4-imza div { border-top:1px solid #333; padding-top:3px; }
@media print {
  body * { visibility:hidden !important; }
  .hi-a4, .hi-a4 * { visibility:visible !important; }
  .hi-a4 { position:fixed; left:0; top:0; width:100%; border:none; box-shadow:none; font-size:11px; }
}
`;

export default HastaIcmal;
