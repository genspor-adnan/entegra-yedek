import { useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type Kosul, type ListeSatiri } from '../../api/sozlesme';
import type { ProtokolOzet, SablonKullanim, SablonOzet, SablonSurumleri } from '../../api/uclar/radyolojiTanim';
import type { EkSekmeBaglami } from '../../bilesenler/GenForm';
import { metinSor, onay, guvenli } from '../../bilesenler/mesaj';
import { sayi, tarihSaat } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';

/**
 * RADYOLOJİ ŞABLON / PROTOKOL EKRAN PARÇALARI (965, mockup
 * Ekranlar/Radyoloji/radyoloji_sablon_*_v2.html · radyoloji_protokol_*.html).
 *
 *   BolgePaneli          liste solu: bölge (rad.bolge) + sayı, seçim listeyi süzer
 *   SablonOnizlemePaneli liste sağı: rapor iskeleti, makrolar, 30 gün kullanım
 *   ProtokolOnizlemePaneli liste sağı: seriler, hazırlık, kontrol, sarf, cihaz
 *   SablonOnizlemeSekmesi / SablonSurumSekmesi / SablonKullanimSekmesi  kart ek sekmeleri
 *   SmsOnizleme          protokol kartı "Hasta hazırlığı" sekmesinin altı
 */

/** Kapsam seçimi (şablon listesi, 1216 / mockup radyoloji_sablon_listesi_v3.html): sahip id'si ya da grup. */
type Kapsam = 'benim' | 'genel' | 'kisisel' | 'eslenmedi' | number;

/**
 * Liste solu seçim - `useBolgeSuzgeci` ile Liste'nin filtre zincirine girer. Bölge her iki ekranda; şablon listesinde
 * ayrıca KAPSAM (benim / genel / kişisel - hekim bazında / sahibi eşlenmedi) ve ESKİ HBYS KLASÖRÜ. Seçimler AND'lenir.
 */
export function useBolgeSuzgeci(aktif: boolean) {
  const { kullanici } = useOturum();
  const [bolge, setBolge] = useState<number | null>(null);
  const [kapsam, setKapsam] = useState<Kapsam | null>(null);
  const [klasor, setKlasor] = useState<string | null>(null);
  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const k: Kosul[] = temel ? [temel] : [];
    if (bolge !== null) k.push(bolge === 0 ? { alan: 'bolge', op: 'bos', deger: null } : { alan: 'bolge', op: 'esit', deger: bolge });
    if (kapsam === 'benim') k.push({ alan: 'sahipId', op: 'esit', deger: Number(kullanici?.id ?? 0) });
    else if (kapsam === 'genel') k.push({ alan: 'kapsamKod', op: 'esit', deger: 1 });
    else if (kapsam === 'kisisel') k.push({ alan: 'kapsamKod', op: 'esit', deger: 2 });
    else if (kapsam === 'eslenmedi') k.push({ alan: 'kapsamKod', op: 'esit', deger: 3 });
    else if (typeof kapsam === 'number') k.push({ alan: 'sahipId', op: 'esit', deger: kapsam });
    if (klasor !== null) k.push({ alan: 'eskiKlasor', op: 'esit', deger: klasor });
    return k.length === 0 ? undefined : k.length === 1 ? k[0] : { op: 'and', kosullar: k };
  };
  return { bolge, setBolge, kapsam, setKapsam, klasor, setKlasor, benimId: Number(kullanici?.id ?? 0), filtre };
}

export function BolgePaneli({ kaynak, s, yenile }: { kaynak: string; s: ReturnType<typeof useBolgeSuzgeci>; yenile: number }) {
  const [bolgeler, setBolgeler] = useState<{ deger: number; ad: string }[]>([]);
  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const sablon = kaynak === 'radyoloji-sablon';
  useEffect(() => {
    api.kodListe('rad.bolge').then(y => setBolgeler(y.degerler.map(d => ({ deger: Number(d.deger), ad: d.ad })))).catch(() => setBolgeler([]));
  }, []);
  // SAYILAR liste verisinden: tanım listeleri küçük (yüzler), tek istek yeter.
  useEffect(() => {
    api.liste(kaynak, { sayfa: 1, boyut: 2000 }).then(y => setSatirlar(y.satirlar)).catch(() => setSatirlar([]));
  }, [kaynak, yenile]);
  const say = (f: (r: ListeSatiri) => boolean) => satirlar.filter(f).length;
  const bolgeSayisi = (b: number) => say(r => Number(r.bolge ?? 0) === b);
  // Kişisel şablonu olan hekimler (ad - sahip) ve eski HBYS klasörleri, sayılarıyla.
  const hekimler = useMemo(() => {
    const m = new Map<number, { ad: string; n: number }>();
    for (const r of satirlar) {
      const id = Number(r.sahipId ?? 0);
      if (!id) continue;
      const ad = String(r.kapsam ?? '').replace(/^Kişisel · /, '');
      m.set(id, { ad, n: (m.get(id)?.n ?? 0) + 1 });
    }
    return [...m.entries()].sort((a, b) => a[1].ad.localeCompare(b[1].ad, 'tr'));
  }, [satirlar]);
  const klasorler = useMemo(() => {
    const m = new Map<string, number>();
    for (const r of satirlar) { const k = String(r.eskiKlasor ?? ''); if (k) m.set(k, (m.get(k) ?? 0) + 1) }
    return [...m.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], 'tr'));
  }, [satirlar]);

  const dal = (anahtar: string, on: boolean, ad: string, n: number, f: () => void, sinif = '') => (
    <button key={anahtar} type="button" className={`rt-dal${on ? ' on' : ''}${sinif ? ` ${sinif}` : ''}`}
            onClick={f}><span>{ad}</span><i>{n}</i></button>
  );
  return (
    <div className="rt-agac">
      <h6>{c('Bölge')}</h6>
      {dal('b-tum', s.bolge === null, c('Tümü'), satirlar.length, () => s.setBolge(null))}
      {bolgeler.map(b => dal(`b-${b.deger}`, s.bolge === b.deger, c(b.ad), bolgeSayisi(b.deger), () => s.setBolge(b.deger)))}
      {bolgeSayisi(0) > 0 && dal('b-0', s.bolge === 0, c('Bölge girilmemiş'), bolgeSayisi(0), () => s.setBolge(0), 'rt-bos')}
      {sablon && <>
        <h6 className="rt-agac-ara">{c('Kapsam')}</h6>
        {dal('k-tum', s.kapsam === null, c('Tümü'), satirlar.length, () => s.setKapsam(null))}
        {dal('k-benim', s.kapsam === 'benim', '★ ' + c('Benim şablonlarım'), say(r => s.benimId > 0 && Number(r.sahipId ?? 0) === s.benimId), () => s.setKapsam('benim'))}
        {dal('k-genel', s.kapsam === 'genel', c('Genel (kurum)'), say(r => Number(r.kapsamKod) === 1), () => s.setKapsam('genel'))}
        {dal('k-kis', s.kapsam === 'kisisel', c('Kişisel — tümü'), say(r => Number(r.kapsamKod) === 2), () => s.setKapsam('kisisel'))}
        {hekimler.map(([id, h]) => dal(`k-${id}`, s.kapsam === id, h.ad, h.n, () => s.setKapsam(id), 'alt'))}
        {say(r => Number(r.kapsamKod) === 3) > 0 &&
          dal('k-esl', s.kapsam === 'eslenmedi', '⚠ ' + c('Sahibi eşlenmedi'), say(r => Number(r.kapsamKod) === 3), () => s.setKapsam('eslenmedi'), 'alt rt-bos')}
        {klasorler.length > 0 && <>
          <h6 className="rt-agac-ara">{c('Eski HBYS klasörü')}</h6>
          {dal('e-tum', s.klasor === null, c('Tümü'), satirlar.length, () => s.setKlasor(null))}
          {klasorler.map(([k, n]) => dal(`e-${k}`, s.klasor === k, k, n, () => s.setKlasor(k)))}
        </>}
      </>}
    </div>
  );
}

function Satir({ s, d }: { s: string; d: React.ReactNode }) {
  return <div className="rt-satir"><span>{s}</span><b>{d}</b></div>;
}

export function SablonOnizlemePaneli({ satir }: { satir: ListeSatiri | null }) {
  const id = satir ? Number(satir.id) : 0;
  const [o, setO] = useState<SablonOzet | null>(null);
  useEffect(() => { setO(null); if (id > 0) api.radSablonOzet(id).then(setO).catch(() => setO(null)) }, [id]);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir şablon seçin.')}</div>;
  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Seçili şablon')}</h5>
        <div className="rt-ad">{satir?.varsayilan ? '⭐ ' : ''}{String(satir?.ad ?? '')}</div>
        <Satir s={c('Kod / sürüm')} d={`${satir?.kod ?? ''} · ${satir?.surumAdi ?? ''}`} />
        <Satir s={c('Modalite')} d={String(satir?.modaliteAdi ?? '')} />
        <Satir s={c('Bağlı hizmet')} d={[satir?.tetkik, satir?.ekHizmet].filter(Boolean).join(' ') || '—'} />
        <Satir s={c('Sahibi')} d={String(satir?.sahibi ?? '')} />
      </div>
      {!o ? <div className="sonuk rt-bl">{c('yükleniyor')}…</div> : (<>
        <div className="rt-bl"><h5>{c('Rapor iskeleti')}</h5>
          {o.bolumler.length === 0 && <div className="sonuk">{c('Bölüm tanımlanmamış.')}</div>}
          {o.bolumler.map((b, i) => (
            <div key={i} className="rt-satir"><span>{b.sira || i + 1}</span><b>{b.baslik}</b>
              <em>{b.zorunlu ? <span className="rozet hata">{c('zorunlu')}</span> : b.varsayilanMetin.includes('{istem') ? <span className="rozet mavi">{c('istemden')}</span> : null}</em></div>
          ))}
        </div>
        {o.makrolar.length > 0 && (
          <div className="rt-bl"><h5>{c('Makrolar')}</h5>
            {o.makrolar.map(m => <div key={m.kisayol} className="rt-satir"><span><kbd className="rt-kbd">{m.kisayol}</kbd></span><b>{m.ad}</b></div>)}
          </div>
        )}
        <div className="rt-bl"><h5>{c('Kullanım · 30 gün')}</h5>
          <Satir s={c('Rapor')} d={o.kullanim?.rapor ?? 0} />
          {o.kullanim?.enCok && <Satir s={c('En çok kullanan')} d={o.kullanim.enCok} />}
        </div>
      </>)}
    </div>
  );
}

export function ProtokolOnizlemePaneli({ satir }: { satir: ListeSatiri | null }) {
  const id = satir ? Number(satir.id) : 0;
  const [o, setO] = useState<ProtokolOzet | null>(null);
  useEffect(() => { setO(null); if (id > 0) api.radProtokolOzet(id).then(setO).catch(() => setO(null)) }, [id]);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir protokol seçin.')}</div>;
  if (!o) return <div className="rt-oniz sonuk">{c('yükleniyor')}…</div>;
  const p = o.protokol;
  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Seçili protokol')}</h5>
        <div className="rt-ad">{p.tetkik}</div>
        <Satir s={c('Seri')} d={p.seriKodu || '—'} />
        <Satir s={c('Süre')} d={`${p.sureDk} dk${p.hazirlikOnceDk ? ` · ${p.hazirlikOnceDk} dk önce gelsin` : ''}`} />
        {p.kontrast > 0 && <Satir s={c('Kontrast')} d={[p.kontrastAjan, p.kontrastDoz].filter(Boolean).join(' · ') || c('var')} />}
        {o.cihazlar.length > 0 && <Satir s={c('Cihaz')} d={o.cihazlar.map(x => x.kod).join(', ')} />}
      </div>
      {o.seriler.length > 0 && (
        <div className="rt-bl"><h5>{c('Seriler')}</h5>
          {o.seriler.map((s, i) => <div key={i} className="rt-satir"><span>{i + 1}</span><b>{s.ad}{s.faz ? ` (${s.faz})` : ''}</b></div>)}
        </div>
      )}
      <div className="rt-bl"><h5>{c('Hasta hazırlığı')}</h5>
        <div className="rt-metin">{p.hazirlikMetni || <span className="sonuk">{c('Hazırlık metni yok.')}</span>}</div>
      </div>
      {o.kontroller.length > 0 && (
        <div className="rt-bl"><h5>{c('Çekim öncesi kontrol')}</h5>
          {o.kontroller.map((k, i) => <div key={i} className="rt-satir"><span>☐</span><b>{k.ad}</b><em>{k.engel ? <span className="rozet hata">{c('engel')}</span> : <span className="rozet uyari">{c('uyarı')}</span>}</em></div>)}
        </div>
      )}
      {o.malzeme.length > 0 && (
        <div className="rt-bl"><h5>{c('Sarf (otomatik düşüm)')}</h5>
          {o.malzeme.map((m, i) => <div key={i} className="rt-satir"><span>{m.ad}</span><b>{m.miktar != null ? sayi.format(m.miktar) : ''}</b></div>)}
        </div>
      )}
      {p.ozelUyari && <div className="rt-bl"><div className="tl-uyari">⚠ {p.ozelUyari}</div></div>}
    </div>
  );
}

// ------------------------------------------------------- kart ek sekmeleri --
const YER_TUTUCU = /(\{[a-z_.:]+\})/gi;

/** Önizleme: bölümler A4 kâğıtta; yer tutucular sarı. */
export function SablonOnizlemeSekmesi({ baglam }: { baglam: EkSekmeBaglami }) {
  const d = baglam.deger;
  const bolumler = baglam.detaySatirlari('bolumler')
    .slice().sort((a, b) => Number(a.sira ?? 0) - Number(b.sira ?? 0));
  return (
    <div className="rt-a4-zemin">
      <div className="rt-a4">
        <div className="rt-a4-ust"><b>{c('Radyoloji')}</b><span>{c('Rapor no')}: R-…</span></div>
        <h3>{String(d.raporBasligi || d.ad || '').toLocaleUpperCase('tr-TR')}</h3>
        {bolumler.length === 0 && <div className="sonuk">{c('Bölüm yok - "Bölümler" sekmesinden ekleyin.')}</div>}
        {bolumler.filter(b => Number(b.yazdir ?? 1) !== 0).map((b, i) => (
          <div key={i}>
            <div className="rt-a4-bb">{String(b.baslik ?? '')}{Number(b.zorunlu) ? ' *' : ''}</div>
            <div className="rt-a4-metin">{String(b.varsayilanMetin ?? '').split(YER_TUTUCU).map((p, j) =>
              YER_TUTUCU.test(p) ? <span key={j} className="rt-yer">{p}</span> : <span key={j}>{p}</span>)}</div>
          </div>
        ))}
        <div className="rt-a4-imza">{c('Uzm. Dr. …')}<br />{c('Radyoloji')}{Number(d.eimzaZorunlu) ? ` · ${c('e-imzalı')}` : ''}</div>
      </div>
      <div className="tl-bilgi" style={{ marginTop: 10 }}>{c('Sarı = istem / hasta verisinden dolacak yer tutucu; "Yazdır" kapalı bölüm çıktıda görünmez.')}</div>
    </div>
  );
}

export function SablonSurumSekmesi({ id, tazele }: { id: number; tazele(): void }) {
  const [v, setV] = useState<SablonSurumleri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const yukle = () => api.radSablonSurumleri(id).then(setV).catch(e => setHata(hataMetni(e)));
  useEffect(() => { void yukle() }, [id]); // eslint-disable-line react-hooks/exhaustive-deps
  const yeni = () => void guvenli(async () => {
    const n = await metinSor(c('Bu sürümde ne değişti? (ör. "ASPECTS alanı eklendi")'), '', c('Sürüm notu'));
    if (n === null) return;
    await api.radSablonYeniSurum(id, n); await yukle(); tazele();
  });
  const geri = (s: number) => void guvenli(async () => {
    if (!await onay(`v${s} ${c('içeriği bugünkü şablonun yerine yazılsın mı? (bölümler, alanlar, makrolar)')}`)) return;
    await api.radSablonGeriYukle(id, s); await yukle(); tazele();
  });
  return (
    <div className="rt-sekme">
      <div className="rt-arac"><span className="sonuk">{c('Yazılmış rapor kendi sürümüyle kalır. "Yeni sürüm" bugünkü içeriği dondurur, sayaç artar.')}</span>
        <span className="ck-bosluk" /><button type="button" className="d bir" onClick={yeni}>🆕 {c('Yeni sürüm')}</button></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <table className="rt-tablo">
        <thead><tr><th>{c('Sürüm')}</th><th>{c('Tarih')}</th><th>{c('Değiştiren')}</th><th>{c('Not')}</th><th className="sag">{c('Rapor')}</th><th /></tr></thead>
        <tbody>{(v?.satirlar ?? []).map(s => (
          <tr key={s.surum} className={s.guncel ? 'rt-sec' : undefined}>
            <td><b>v{s.surum}</b> {s.guncel ? <span className="rozet olumlu">{c('güncel')}</span> : null}</td>
            <td>{s.tarih ? tarihSaat(s.tarih) : '—'}</td><td>{s.kim}</td><td>{s.notu}</td><td className="sag">{s.rapor}</td>
            <td>{!s.guncel && <button type="button" className="d mini" onClick={() => geri(s.surum)}>{c('Geri yükle')}</button>}</td>
          </tr>
        ))}</tbody>
      </table>
    </div>
  );
}

export function SablonKullanimSekmesi({ id }: { id: number }) {
  const [k, setK] = useState<SablonKullanim | null>(null);
  useEffect(() => { api.radSablonKullanim(id).then(setK).catch(() => setK(null)) }, [id]);
  const gruplu = useMemo(() => {
    const m = new Map<string, { deger: string; adet: number }[]>();
    for (const d of k?.dagilim ?? []) m.set(d.alan, [...(m.get(d.alan) ?? []), { deger: d.deger, adet: d.adet }]);
    return [...m.entries()];
  }, [k]);
  if (!k) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;
  return (
    <div className="rt-sekme rt-iki">
      <div>
        <h6 className="rt-baslik">{c('Kullanım · son 30 gün')}</h6>
        {k.hekimler.length === 0 ? <div className="sonuk">{c('Son 30 günde bu şablonla rapor yazılmamış.')}</div> : (
          <table className="rt-tablo">
            <thead><tr><th>{c('Hekim')}</th><th className="sag">{c('Rapor')}</th><th className="sag">{c('Onaylı')}</th><th className="sag">{c('Ort. yazım (dk)')}</th></tr></thead>
            <tbody>{k.hekimler.map((h, i) => (
              <tr key={i}><td>{h.hekim}</td><td className="sag">{h.rapor}</td><td className="sag">{h.onayli}</td>
                <td className="sag">{h.ortDk != null ? sayi.format(h.ortDk) : '—'}</td></tr>
            ))}</tbody>
          </table>
        )}
      </div>
      <div>
        <h6 className="rt-baslik">{c('Yapılandırılmış alan dağılımı')}</h6>
        {gruplu.length === 0 ? <div className="sonuk">{c('Alan değeri yok.')}</div> : gruplu.map(([alan, l]) => {
          const top = l.reduce((a, b) => a + b.adet, 0);
          return (
            <div key={alan} className="rt-bl"><h5>{alan}</h5>
              {l.map(d => <div key={d.deger} className="rt-satir"><span>{d.deger}</span><b>%{Math.round((d.adet / top) * 100)} ({d.adet})</b></div>)}
            </div>
          );
        })}
      </div>
    </div>
  );
}

/** Yeni (kaydedilmemiş) şablonda Sürümler / Kullanım sekmesi. */
export function KayitSonraDolar() {
  return <div className="tl-bilgi" style={{ margin: 14 }}>{c('Şablon kaydedilince dolar: ilk kayıt v1 olur, raporlar yazıldıkça kullanım burada görünür.')}</div>;
}

/** Protokol kartı "Hasta hazırlığı" sekmesinin altında SMS önizleme. */
export function SmsOnizleme({ deger }: { deger: Record<string, unknown> }) {
  const metin = String(deger.hazirlikMetni ?? '').trim();
  if (!metin) return null;
  const sms = `Sayın Elif Demo, 06.10 10:30 ${c('randevunuz var.')} ${metin}`;
  return (
    <div className="rt-sms">
      <h6 className="rt-baslik">{c('SMS önizleme')}{Number(deger.smsEkle ?? 1) ? '' : ` · ${c('SMS kapalı')}`}</h6>
      <div className="rt-sms-balon">{sms}</div>
      <div className="sonuk rt-kucuk">{sms.length} {c('karakter')} · {Math.ceil(sms.length / 160)} SMS</div>
    </div>
  );
}
