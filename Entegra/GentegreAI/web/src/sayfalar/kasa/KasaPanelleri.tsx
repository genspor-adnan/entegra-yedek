import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { hataMetni } from '../../api/sozlesme';
import type { KasaGostergesi as Gosterge, KasaKartOzeti } from '../../api/uclar/kasaListe';
import { para, sayi, tarihSaat } from '../../bilesenler/bicim';
import { Egri } from '../../bilesenler/grid/satirHucre';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { KasaIslemKarti } from '../KasaIslemKarti';
import { BelgeKarti } from '../BelgeKarti';

/**
 * KASA LİSTESİ / KARTI V3 (1161, mockup Ekranlar/kasa_listesi_ver3.html + kasa_karti_ver3.html).
 *
 *  · KasaGostergesi  - üst şerit: toplam nakit, sayım bekleyen, sayım farkı, limit aşan, açık
 *    oturum, bugün tahsilat / ödeme. Kutu listenin akıllı çipini açar.
 *  · KasaOnizleme    - sağ panel: seçili kasanın durumu, son hareketler, sayım, hızlı işlemler.
 *  · KasaOzetSeridi  - kartta kimlik şeridinin altı: bakiye, günün akışı, son sayım, limit,
 *    son yatırma, ay neti, yetkili.
 *  · KasaSayimSekmesi - kartın "Sayım / Gün Sonu" sekmesi: sayım geçmişi + fark eğilimi.
 * Rakamlar sunucudan (KasaListeUclari); panel hesap yapmaz. Hareket sekmesi yok - Ekstre.
 */

/** listeTanimlari.Ticari Kasa Listesi çip sırası: Aktif 0, Pasif 1, Tümü 2, Sayım bekleyen 3, Sayım farkı 4, Limit aşan 5, Açık oturum 6, Dövizli 7, Banko 8. */
const CIP = { aktif: 0, tumu: 2, sayim: 3, fark: 4, limit: 5, oturum: 6 } as const;
const kisa = (n: number) => (Math.abs(n) >= 1e6 ? `${sayi.format(Math.round(n / 1e5) / 10)} M` : para.format(n));
const gun = (t: string | null | undefined) => (t ? tarihSaat(t).slice(0, 10) : '—');

export function KasaGostergesi({ yenile, cipIndeks, onCip }: { yenile: number; cipIndeks?: number; onCip(i: number): void }) {
  const [g, setG] = useState<Gosterge | null>(null);
  useEffect(() => { api.kasaGosterge().then(y => setG(y.gosterge)).catch(() => setG(null)) }, [yenile]);
  const kutular: { cip: number | null; deger: string; ad: string; ek?: string; sinif?: string }[] = [
    { cip: CIP.aktif, deger: g ? kisa(g.nakit) : '…', ad: 'Toplam nakit (TL karşılığı)', ek: g ? `${g.aktif} ${c('aktif kasa')} · ${g.sube} ${c('şube')}` : undefined },
    { cip: CIP.sayim, deger: g ? sayi.format(g.sayimBekleyen) : '…', ad: 'Bugün sayımı yapılmamış', ek: c('sayım zorunlu kasalar'), sinif: g?.sayimBekleyen ? 'kirmizi' : undefined },
    { cip: CIP.fark, deger: g ? sayi.format(g.farkli) : '…', ad: 'Sayım farkı olan', ek: g?.farkli ? `${c('toplam fark')} ${para.format(g.farkToplam)}` : undefined, sinif: g?.farkli ? 'kirmizi' : undefined },
    { cip: CIP.limit, deger: g ? sayi.format(g.limitAsan) : '…', ad: 'Güvenlik limitini aşan', sinif: g?.limitAsan ? 'uyari' : undefined },
    { cip: CIP.oturum, deger: g ? sayi.format(g.acikOturum) : '…', ad: 'Açık banko oturumu', sinif: g?.acikOturum ? 'uyari' : undefined },
    { cip: null, deger: g ? `${kisa(g.bugunGiris)} / ${kisa(g.bugunCikis)}` : '…', ad: 'Bugün tahsilat / ödeme',
      ek: g ? `${c('net')} ${g.bugunGiris - g.bugunCikis >= 0 ? '+' : ''}${kisa(g.bugunGiris - g.bugunCikis)} · ${g.bugunAdet} ${c('işlem')}` : undefined },
  ];
  return (
    <div className="pl-kpi ml-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" disabled={k.cip === null}
                className={`pl-k${k.cip !== null && cipIndeks === k.cip ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                title={k.cip !== null ? c('Listeyi bu kümeye süz (tekrar tıkla: tümü)') : undefined}
                onClick={() => k.cip !== null && onCip(cipIndeks === k.cip ? CIP.tumu : k.cip)}>
          <b>{k.deger}</b><span>{c(k.ad)}{k.ek ? ` · ${k.ek}` : ''}</span>
        </button>))}
    </div>
  );
}

const bekleyen = new Map<string, Promise<KasaKartOzeti>>();
function ozetGetir(id: number, tazele: number) {
  const anahtar = `${id}:${tazele}`;
  let p = bekleyen.get(anahtar);
  // finally() yeni bir söz döndürür: p reddedilince o da reddedilir ve kimse dinlemediği için
  //   "yakalanmamış hata" olurdu (duman 25.10.2026) - temizlik zinciri hatayı yutar, asıl
  //   hata çağırana p üzerinden gider.
  if (!p) { p = api.kasaKartOzet(id); bekleyen.set(anahtar, p); p.finally(() => setTimeout(() => bekleyen.delete(anahtar), 2000)).catch(() => {}) }
  return p;
}
export function useKasaKartOzeti(id: number, tazele: number) {
  const [veri, setVeri] = useState<KasaKartOzeti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  useEffect(() => {
    // Seçili kasa yokken (önizleme boş) istek atılmaz - /api/kasa/0/ozet 404 döner.
    if (!(id > 0)) { setVeri(null); setHata(null); return }
    let iptal = false; setHata(null);
    ozetGetir(id, tazele).then(v => { if (!iptal) setVeri(v) }, h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [id, tazele]);
  return { veri, hata };
}

type Acik = { tur: 'tahsilat' | 'odeme' | 'yatir' } | { tur: 'kayit'; kasa?: number; belge?: number };

export function KasaOnizleme({ satir, yenile, tazele, git, gitKart }: {
  satir: ListeSatiri | null; yenile: number; tazele(): void; git(yol: string): void; gitKart(yol: string): void;
}) {
  const { yetki } = useOturum();
  const id = satir ? Number(satir.id) : 0;
  const { veri } = useKasaKartOzeti(id || 0, yenile);
  const [acik, setAcik] = useState<Acik | null>(null);
  const [sekme, setSekme] = useState<'durum' | 'hareket' | 'sayim'>('durum');
  if (!(id > 0) || !satir) return <div className="pl-oniz bos sonuk">{c('Önizleme için bir kasa seçin.')}</div>;
  const o = veri?.ozet;
  const ad = String(satir.ad ?? '');
  const kapat = () => { setAcik(null); tazele() };
  const egri = String(satir.son7 ?? '').split(',').filter(Boolean).map(Number);
  const limitYuzde = o?.limitYuzde ?? null;
  return (
    <div className="pl-oniz">
      <div className="pl-kimlik"><div className="ks-avatar">{String(satir.dovizCinsi ?? 'TL') === 'TL' ? '₺' : String(satir.dovizCinsi)}</div>
        <div><b>{ad}</b>
          <small>{[satir.kod, satir.atamaAdi, satir.dovizCinsi].filter(Boolean).join(' · ')}</small>
          <small>{Number(satir.durum ?? 1) !== 1 ? c('Pasif') : o?.acikOturum ? `${c('Oturum açık')} · ${o.oturumKisiler}` : o?.bugunSayildi ? c('Bugün sayıldı') : c('Aktif')}</small></div></div>
      <div className="ml-hizli">
        {yetki('kasa_islem', 'ekle') && <button type="button" className="d" onClick={() => setAcik({ tur: 'tahsilat' })}>💰 {c('Tahsilat')}</button>}
        {yetki('kasa_islem', 'ekle') && <button type="button" className="d" onClick={() => setAcik({ tur: 'odeme' })}>💸 {c('Ödeme')}</button>}
        {yetki('kasa_islem', 'ekle') && <button type="button" className="d" onClick={() => setAcik({ tur: 'yatir' })}>🏦 {c('Yatır')}</button>}
        {yetki('kasa.gun_sonu', 'gor') && <button type="button" className="d" onClick={() => git('/kasa-gun-sonu')}>🧮 {c('Sayım')}</button>}
        {yetki('finans.ekstre', 'gor') && <button type="button" className="d" onClick={() => git(`/ekstre?tur=kasa&id=${id}`)}>📄 {c('Ekstre')}</button>}
        <button type="button" className="d bir" onClick={() => gitKart(`/kasa-hesap/${id}`)}>{c('Kartı Aç')} ↗</button>
      </div>
      <div className="katab ks-sekme">
        {([['durum', 'Durum'], ['hareket', 'Son Hareketler'], ['sayim', 'Sayım']] as const).map(([k, a]) => (
          <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>{c(a)}</div>))}
      </div>
      {sekme === 'durum' && o && (<>
        <div className="pl-bl">
          <div className="ml-mali">
            <div><span>{c('Bakiye')}</span><b className={o.bakiye < -0.005 ? 'ml-borc' : undefined}>{para.format(o.bakiye)} {o.doviz}</b></div>
            <div><span>{c('Bugün giriş')}</span><b>{para.format(o.bugunGiris)}</b></div>
            <div><span>{c('Bugün çıkış')}</span><b>{para.format(o.bugunCikis)}</b></div>
            <div><span>{c('Güvenlik limiti')}</span><b>{o.guvenlikLimiti > 0 ? `${para.format(o.guvenlikLimiti)} · %${limitYuzde}` : '—'}</b></div>
          </div>
        </div>
        {egri.length > 1 && egri.some(x => x) && (
          <div className="pl-bl"><h5>{c('Son 7 gün net')}</h5><Egri degerler={egri} genislik={300} yukseklik={40} /></div>)}
        <div className="pl-bl">
          <div className="pl-satir"><span>{c('Son sayım')}</span>{o.sonSayim ? `${gun(o.sonSayim)} · ${c('fark')} ${para.format(o.sonFark ?? 0)}` : '—'}</div>
          <div className="pl-satir"><span>{c('Son bankaya yatırma')}</span>{o.sonYatirma ? gun(o.sonYatirma) : '—'}</div>
          <div className="pl-satir"><span>{c('Bu ay net')}</span>{(o.ayNet >= 0 ? '+ ' : '') + para.format(o.ayNet)}</div>
          <div className="pl-satir"><span>{c('Muhasebe hesabı')}</span>{o.muhHesap || '—'}</div>
          <div className="pl-satir"><span>{c('Yetkili')}</span>{o.yetkili} {c('kullanıcı / rol')}</div>
        </div>
        <div className="sonuk pl-kucuk">{o.sayimZorunlu ? c('Gün sonu sayımı zorunlu; fark açıklanmadan ertesi gün tahsilat alınamaz (opsiyon).') : c('Bu kasada gün sonu sayımı zorunlu değil (kart › Limitler & Kurallar).')}</div>
      </>)}
      {sekme === 'hareket' && veri && (
        <div className="pl-bl"><h5>{c('Son hareketler')}<button type="button" className="pl-bag" onClick={() => git(`/ekstre?tur=kasa&id=${id}`)}>{c('Tam ekstre')} ›</button></h5>
          {veri.hareketler.length === 0 ? <div className="sonuk">{c('Hareket yok.')}</div> : (
            <table className="ml-hareket"><tbody>
              {veri.hareketler.map(h => (
                <tr key={h.id} title={c('Çift tıkla: kaydı aç')} onDoubleClick={() => (h.kasaIslemId || h.belgeId) && setAcik({ tur: 'kayit', kasa: h.kasaIslemId || undefined, belge: h.kasaIslemId ? undefined : h.belgeId })}>
                  <td>{tarihSaat(h.tarih)}</td><td>{h.turAdi}{h.cari ? ` · ${h.cari}` : ''}</td>
                  <td className={`hiza-sag ${h.giris ? 'ml-alacak' : 'ml-borc'}`}>{h.giris ? para.format(h.giris) : `−${para.format(h.cikis)}`}</td>
                </tr>))}
            </tbody></table>)}
        </div>)}
      {sekme === 'sayim' && veri && (
        <div className="pl-bl"><h5>{c('Sayım geçmişi')}</h5>
          {veri.sayimlar.length === 0 ? <div className="sonuk">{c('Sayım yok.')}</div> : (
            <table className="ml-hareket"><tbody>
              {veri.sayimlar.slice(0, 6).map(s => (
                <tr key={s.id}><td>{gun(s.tarih)}</td><td>{s.sayan}</td><td className="hiza-sag">{para.format(s.sayilan)}</td>
                  <td className={`hiza-sag ${Math.abs(s.fark) > 0.005 ? 'ml-borc' : ''}`}>{para.format(s.fark)}</td></tr>))}
            </tbody></table>)}
          <div className="sonuk pl-kucuk">{c('Fark açıklaması zorunlu; açıklanan fark "Sayım Farkı" hareketi olarak kasaya işlenir.')}</div>
        </div>)}
      {acik?.tur === 'tahsilat' && <KasaIslemKarti acilis={{ tur: 21 }} onKapat={kapat} onKaydedildi={tazele} />}
      {acik?.tur === 'odeme' && <KasaIslemKarti acilis={{ tur: 31 }} onKapat={kapat} onKaydedildi={tazele} />}
      {acik?.tur === 'yatir' && <KasaIslemKarti acilis={{ tur: 41 }} onKapat={kapat} onKaydedildi={tazele} />}
      {acik?.tur === 'kayit' && acik.kasa && <KasaIslemKarti kayitIdProp={acik.kasa} onKapat={kapat} />}
      {acik?.tur === 'kayit' && acik.belge && <BelgeKarti id={acik.belge} onKapat={kapat} />}
    </div>
  );
}

/** Kartta kimlik şeridinin altı (mockup özet şeridi). */
export function KasaOzetSeridi({ id, tazele, git }: { id: number; tazele: number; git(yol: string): void }) {
  const { veri, hata } = useKasaKartOzeti(id, tazele);
  if (hata) return <div className="hata-kutusu" style={{ margin: '6px 12px' }}>{hata}</div>;
  if (!veri) return null;
  const o = veri.ozet;
  const limitSinif = o.limitYuzde === null ? '' : o.limitYuzde > 125 ? 'kir' : o.limitYuzde > 100 ? 'uy' : '';
  const kutu = (b: string, deg: string, alt: string, sinif = '', tik?: () => void) => (
    <button type="button" className={'ks-kutu ' + sinif} onClick={tik} disabled={!tik}><span>{b}</span><b>{deg}</b><small>{alt}</small></button>);
  return (
    <div className="ks-ozet">
      <style>{STIL}</style>
      {kutu(c('Bakiye'), `${para.format(o.bakiye)} ${o.doviz}`, `${c('sistem')} · ${o.yerelBakiye !== o.bakiye ? `₺ ${para.format(o.yerelBakiye)}` : c('bugün')}`, o.bakiye < -0.005 ? 'kir' : '',
           () => git(`/ekstre?tur=kasa&id=${id}`))}
      {kutu(c('Bugün giriş / çıkış'), `${para.format(o.bugunGiris)} / ${para.format(o.bugunCikis)}`, `${o.bugunAdet} ${c('işlem')}`)}
      {kutu(c('Son sayım'), o.sonSayim ? gun(o.sonSayim) : '—', o.sonSayim ? `${c('fark')} ${para.format(o.sonFark ?? 0)}${Math.abs(o.sonFark ?? 0) > 0.005 && o.sonFarkAciklama ? ' · ' + c('açıklandı') + ' ✓' : ''}` : c('sayım yok'),
           Math.abs(o.sonFark ?? 0) > 0.005 ? 'uy' : '')}
      {kutu(c('Güvenlik limiti'), o.guvenlikLimiti > 0 ? `%${o.limitYuzde}` : c('yok'), o.guvenlikLimiti > 0 ? `₺ ${para.format(o.guvenlikLimiti)}${(o.limitYuzde ?? 0) > 100 ? ` · ${c('fazlası')} ${para.format(o.bakiye - o.guvenlikLimiti)}` : ''}` : c('kart › Limitler & Kurallar'), limitSinif)}
      {kutu(c('Son bankaya yatırma'), o.sonYatirma ? gun(o.sonYatirma) : '—', o.bagliHesap || c('bağlı banka hesabı yok'))}
      {kutu(c('Bu ay net'), `${o.ayNet >= 0 ? '+ ' : ''}${para.format(o.ayNet)}`, o.doviz, o.ayNet < 0 ? 'uy' : 'ok')}
      {kutu(c('Yetkili kullanıcı'), String(o.yetkili), o.acikOturum ? `${c('oturum açık')} · ${o.oturumKisiler}` : c('kart › Yetkiler'))}
    </div>
  );
}

/** Kartın Sayım / Gün Sonu sekmesi. */
export function KasaSayimSekmesi({ id, tazele, git }: { id: number; tazele: number; git(yol: string): void }) {
  const { yetki } = useOturum();
  const { veri, hata } = useKasaKartOzeti(id, tazele);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="sonuk" style={{ padding: 12 }}>{c('yükleniyor')}…</div>;
  const e = veri.egilim; const n = e.tam + e.toleransIci + e.toleransUstu || 1;
  return (
    <div className="ks-sayim">
      <style>{STIL}</style>
      <div className="ks-serit">
        <span className="sonuk">{veri.sayimlar.length} {c('sayım')} · {c('son 30 gün')}: {e.tam + e.toleransIci + e.toleransUstu} {c('sayım')} · {e.toleransUstu} {c('tolerans üstü')}</span>
        <span className="sp" />
        {yetki('kasa.gun_sonu', 'gor') && <button type="button" className="d" onClick={() => git('/kasa-gun-sonu')}>🧮 {c('Yeni sayım (Gün Sonu)')}</button>}
      </div>
      <table className="detay-tablo">
        <thead><tr><th>{c('Tarih')}</th><th>{c('Sayan')}</th><th className="hiza-sag">{c('Sistem')}</th><th className="hiza-sag">{c('Sayılan')}</th><th className="hiza-sag">{c('Fark')}</th><th>{c('Açıklama')}</th><th>{c('Durum')}</th></tr></thead>
        <tbody>
          {veri.sayimlar.length === 0 && <tr><td colSpan={7} className="bos">{c('Bu kasada sayım yapılmamış.')}</td></tr>}
          {veri.sayimlar.map(s => {
            const farkli = Math.abs(s.fark) > 0.005;
            return (
              <tr key={s.id}>
                <td>{tarihSaat(s.zaman)}</td><td>{s.sayan || '—'}</td><td className="hiza-sag">{para.format(s.sistem)}</td><td className="hiza-sag">{para.format(s.sayilan)}</td>
                <td className={'hiza-sag' + (farkli ? ' ks-kir' : '')}>{para.format(s.fark)}</td><td>{s.farkAciklama || s.aciklama}</td>
                <td>{!farkli ? <span className="rozet ok">{c('Tam')}</span> : s.farkAciklama ? <span className="rozet ok">{c('Açıklandı')}</span> : <span className="rozet uyari">{c('Açıklanmadı')}</span>}</td>
              </tr>);
          })}
        </tbody>
      </table>
      <div className="ks-egilim">
        <h5>{c('Fark eğilimi (30 gün)')}</h5>
        <div className="ks-cubuk"><i style={{ width: `${(e.tam / n) * 100}%`, background: '#2e7d46' }} /><i style={{ width: `${(e.toleransIci / n) * 100}%`, background: '#e0a33a' }} /><i style={{ width: `${(e.toleransUstu / n) * 100}%`, background: '#c0413d' }} /></div>
        <div className="ks-yl"><span>{c('Tam')}<b>{e.tam}</b></span><span>{c('Tolerans içi')}<b>{e.toleransIci}</b></span><span>{c('Tolerans üstü')}<b className={e.toleransUstu ? 'ks-kir' : ''}>{e.toleransUstu}</b></span></div>
        <div className="sonuk pl-kucuk">{c('Fark toplamı')} {para.format(e.toplam)}{e.enBuyuk ? ` · ${c('en büyük')} ${para.format(e.enBuyuk.fark)} (${gun(e.enBuyuk.tarih)})` : ''}. {c('Açıklanan fark "Sayım Farkı" hareketi olarak kasaya işlenir; tolerans kart › Limitler & Kurallar.')}</div>
      </div>
    </div>
  );
}

const STIL = `
.ks-avatar { width:44px; height:44px; border-radius:8px; background:linear-gradient(#3f8f5e,#2b6b43); color:#fff; display:flex; align-items:center; justify-content:center; font-size:20px; font-weight:bold; flex:none; }
.ks-sekme { margin:6px 0; }
.ks-ozet { display:grid; grid-template-columns:repeat(7, 1fr); gap:1px; background:var(--cizgi2,#e3e9f0); border-bottom:1px solid var(--cizgi,#cdd6e0); }
.ks-kutu { background:var(--yuz,#fff); border:0; padding:6px 10px; text-align:left; display:flex; flex-direction:column; gap:1px; cursor:pointer; font:inherit; }
.ks-kutu:disabled { cursor:default; }
.ks-kutu span { font-size:10.5px; color:var(--soluk,#6b7a8b); }
.ks-kutu b { font-size:15px; color:var(--baslik,#14315a); }
.ks-kutu small { font-size:10.5px; color:var(--soluk,#6b7a8b); }
.ks-kutu.kir b { color:#b3261e; } .ks-kutu.uy b { color:#b7791f; } .ks-kutu.ok b { color:#2e7d46; }
.ks-sayim { padding:10px 12px; display:flex; flex-direction:column; gap:10px; }
.ks-serit { display:flex; gap:8px; align-items:center; }
.ks-serit .sp { flex:1; }
.ks-kir { color:#b3261e; font-weight:bold; }
.ks-egilim h5 { margin:0 0 6px; font-size:11px; color:var(--soluk,#6b7a8b); text-transform:uppercase; }
.ks-cubuk { display:flex; height:14px; border-radius:3px; overflow:hidden; background:#e7edf4; }
.ks-cubuk i { display:block; height:100%; }
.ks-yl { display:flex; gap:18px; font-size:11px; color:var(--soluk,#6b7a8b); margin:6px 0; }
.ks-yl b { display:block; font-size:13px; color:var(--baslik,#14315a); }
.detay-tablo .bos { text-align:center; color:var(--soluk,#6b7a8b); padding:14px; }
@media (max-width: 1100px) { .ks-ozet { grid-template-columns:repeat(4, 1fr); } }
`;
