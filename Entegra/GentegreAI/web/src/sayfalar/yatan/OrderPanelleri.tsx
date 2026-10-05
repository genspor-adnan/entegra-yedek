import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import type { OrderGecmisSatiri, OrderGostergeYaniti, OrderOzet, OrderPlan } from '../../api/uclar/yatan';
import { tarihSaat } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';

/**
 * ORDER LİSTESİ + KARTI PARÇALARI (968, mockup
 * Ekranlar/Yatan/order_listesi_v2.html · order_karti_v2.html).
 *
 *   useOrderSuzgeci        gösterge kutusu + servis / oda + tür → Liste filtre zinciri
 *   OrderGostergesi        gridin üstü; kutu = süzgeç (tekrar tıkla = kaldır)
 *   OrderSolPanel          servis > oda ağacı + tür - GenGrid sol paneli (katlanır)
 *   OrderOnizlemePaneli    seçili order - GenGrid yan paneli (katlanır)
 *   OrderHastaSeridi / OrderOzetKutusu / OrderPlanSekmesi / OrderGuvenlikSekmesi / OrderGecmisSekmesi  kart parçaları
 */
export type OrderGostergeKodu = 'imzasiz' | 'bugunDoz' | 'geciken' | 'biten' | 'yuksekRisk';

export const ORDER_TURLERI: Record<number, [string, string]> = {
  1: ['İlaç', '#2f6db3'], 2: ['Serum / sıvı', '#16a085'], 3: ['Tetkik', '#8e44ad'], 4: ['Görüntüleme', '#6c5ce7'],
  5: ['Konsültasyon', '#2c3e50'], 6: ['Diyet', '#7f8c8d'], 7: ['Hemşirelik', '#d35400'], 8: ['Kan ürünü', '#b3261e'],
};

export function useOrderSuzgeci(aktif: boolean) {
  const [gosterge, setGosterge] = useState<OrderGostergeKodu | null>(null);
  const [servis, setServis] = useState<string | null>(null);
  const [oda, setOda] = useState<string | null>(null);
  const [tur, setTur] = useState<number | null>(null);
  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    if (gosterge) l.push({ alan: 'durum', op: 'esit', deger: 1 });
    if (gosterge === 'imzasiz') l.push({ alan: 'imzasiz', op: 'esit', deger: 1 });
    if (gosterge === 'bugunDoz') l.push({ alan: 'bugunDoz', op: 'buyuk', deger: 0 });
    if (gosterge === 'geciken') l.push({ alan: 'gecikenDoz', op: 'buyuk', deger: 0 });
    if (gosterge === 'biten') l.push({ alan: 'bugunBitiyor', op: 'esit', deger: 1 });
    if (gosterge === 'yuksekRisk') l.push({ alan: 'yuksekRisk', op: 'esit', deger: 1 });
    if (servis !== null) l.push({ alan: 'servis', op: 'esit', deger: servis });
    if (oda !== null) l.push({ alan: 'oda', op: 'esit', deger: oda });
    if (tur !== null) l.push({ alan: 'tur', op: 'esit', deger: tur });
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { gosterge, setGosterge, servis, setServis, oda, setOda, tur, setTur, filtre };
}
export type OrderSuzgeci = ReturnType<typeof useOrderSuzgeci>;

export function useOrderGostergesi(aktif: boolean, yenile: number) {
  const [v, setV] = useState<OrderGostergeYaniti | null>(null);
  useEffect(() => { if (aktif) api.orderGosterge().then(setV).catch(() => setV(null)) }, [aktif, yenile]);
  return v;
}

export function OrderGostergesi({ veri, s }: { veri: OrderGostergeYaniti | null; s: OrderSuzgeci }) {
  const g = veri?.gosterge;
  const kutular: { kod: OrderGostergeKodu | null; deger?: number; ad: string; sinif?: string }[] = [
    { kod: null, deger: g?.aktif, ad: 'Aktif order' },
    { kod: 'imzasiz', deger: g?.imzasiz, ad: 'Hekim onayı bekleyen (sözel)', sinif: g?.imzasiz ? 'uyari' : undefined },
    { kod: 'bugunDoz', deger: g?.bugunDoz, ad: 'Bugün verilecek doz' },
    { kod: 'geciken', deger: g?.geciken, ad: 'Geciken doz (> 30 dk)', sinif: g?.geciken ? 'kirmizi' : undefined },
    { kod: 'biten', deger: g?.biten, ad: 'Bugün biten', sinif: g?.biten ? 'uyari' : undefined },
    { kod: 'yuksekRisk', deger: g?.yuksekRisk, ad: 'Yüksek riskli ilaç', sinif: g?.yuksekRisk ? 'kirmizi' : undefined },
  ];
  return (
    <div className="pl-kpi rc-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" className={`pl-k${s.gosterge === k.kod ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                onClick={() => s.setGosterge(k.kod === null || s.gosterge === k.kod ? null : k.kod)}>
          <b>{k.deger ?? '…'}</b><span>{c(k.ad)}</span>
        </button>
      ))}
    </div>
  );
}

export function OrderTurRozeti({ tur }: { tur: number }) {
  const [ad, renk] = ORDER_TURLERI[tur] ?? ['?', '#7f8c8d'];
  return <span className="od-tur" style={{ background: renk }}>{c(ad)}</span>;
}

export function OrderSolPanel({ veri, s }: { veri: OrderGostergeYaniti | null; s: OrderSuzgeci }) {
  const odalar = veri?.odalar ?? [];
  const toplam = odalar.reduce((a, b) => a + b.sayi, 0);
  const servisler = [...new Set(odalar.map(o => o.servis))];
  const sec = (servis: string | null, oda: string | null) => { s.setServis(servis); s.setOda(oda) };
  return (
    <div className="rt-agac">
      <h6>{c('Servis / oda')}</h6>
      <button type="button" className={`rt-dal${s.servis === null && s.oda === null ? ' on' : ''}`} onClick={() => sec(null, null)}>
        <span>{c('Tümü')}</span><i>{toplam}</i></button>
      {servisler.map(sv => (
        <div key={sv}>
          <button type="button" className={`rt-dal${s.servis === sv && s.oda === null ? ' on' : ''}`} onClick={() => sec(sv, null)}>
            <span>{sv || c('(servis yok)')}</span><i>{odalar.filter(o => o.servis === sv).reduce((a, b) => a + b.sayi, 0)}</i></button>
          {odalar.filter(o => o.servis === sv && o.oda).map(o => (
            <button key={o.oda} type="button" className={`rt-dal od-alt${s.servis === sv && s.oda === o.oda ? ' on' : ''}`}
                    onClick={() => sec(sv, o.oda)}><span>{o.oda}</span><i>{o.sayi}</i></button>
          ))}
        </div>
      ))}
      <h6 style={{ marginTop: 12 }}>{c('Tür')}</h6>
      {(veri?.turler ?? []).map(t => (
        <button key={t.tur} type="button" className={`rt-dal${s.tur === t.tur ? ' on' : ''}`} onClick={() => s.setTur(s.tur === t.tur ? null : t.tur)}>
          <span><OrderTurRozeti tur={t.tur} /></span><i>{t.sayi}</i></button>
      ))}
    </div>
  );
}

function Satir({ s, d }: { s: string; d: React.ReactNode }) {
  return <div className="rt-satir"><span>{s}</span><b>{d}</b></div>;
}

const DOZ_DURUM: Record<number, [string, string]> = {
  0: ['planlı', 'pln'], 1: ['bekliyor', 'bek'], 2: ['verildi', 'ok'], 3: ['atlandı', 'atl'], 4: ['reddetti', 'atl'], 5: ['gecikti', 'gec'],
};

function useOzet(id: number, yenile: number) {
  const [o, setO] = useState<OrderOzet | null>(null);
  useEffect(() => { setO(null); if (id > 0) api.orderOzet(id).then(setO).catch(() => setO(null)) }, [id, yenile]);
  return o;
}

const cinsiyet = (n: number) => (n === 1 ? 'E' : n === 2 ? 'K' : '');

function BugunDozlar({ o }: { o: OrderOzet }) {
  if (o.bugun.length === 0) return <div className="sonuk rt-kucuk">{c('Bugün doz yok.')}</div>;
  return (
    <div className="gh-dozlar od-dozlar">{o.bugun.map((d, i) => (
      <span key={i} className={`gh-doz ${DOZ_DURUM[d.durum]?.[1] ?? 'bek'}`}>
        {d.saat} {d.durum === 2 ? `✓ ${d.uygulayan}${d.uygulanan ? ` ${d.uygulanan}` : ''}` : c(DOZ_DURUM[d.durum]?.[0] ?? '')}
      </span>
    ))}</div>
  );
}

const GUV_ROZET: Record<string, string> = { ok: 'olumlu', uyari: 'uyari', hata: 'hata', gri: 'gri' };

export function OrderOnizlemePaneli({ satir, yenile }: { satir: ListeSatiri | null; yenile: number }) {
  const id = satir ? Number(satir.id) : 0;
  const o = useOzet(id, yenile);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir order seçin.')}</div>;
  if (!o) return <div className="rt-oniz sonuk">{c('yükleniyor')}…</div>;
  const r = o.order;
  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Hasta')}</h5>
        <div className="rt-ad">{r.hasta}{r.yatak ? ` · ${r.yatak}` : ''}</div>
        <Satir s={c('Yaş / cinsiyet')} d={[r.yas, cinsiyet(r.cinsiyet)].filter(Boolean).join(' ') || '—'} />
        <Satir s={c('Servis / oda')} d={[r.servis, r.oda].filter(Boolean).join(' · ') || '—'} />
        <Satir s={c('Alerji')} d={r.alerjiler ? <span className="od-kirmizi">{r.alerjiler}</span> : <span className="od-yesil">{c('bilinen yok')}</span>} />
        {r.tani && <Satir s={c('Tanı')} d={r.tani} />}
      </div>
      <div className="rt-bl"><h5>{c('Seçili order')}</h5>
        <div className="rt-ad"><OrderTurRozeti tur={r.tur} /> {r.ad}</div>
        <Satir s={c('Sıklık')} d={r.siklik || '—'} />
        <Satir s={c('Süre')} d={`${c('gün')} ${r.gunNo}${r.gunToplam ? ` / ${r.gunToplam}` : ''}`} />
        <Satir s={c('Hekim / veriliş')} d={`${r.hekim || '—'} · ${r.sozelOrder === 1 ? (r.imzali ? c('sözel, onaylı') : c('sözel, onay bekliyor')) : c('yazılı')}`} />
      </div>
      <div className="rt-bl"><h5>{c('Doz takvimi · bugün')}</h5>
        <BugunDozlar o={o} />
        <Satir s={c('Toplam (bu order)')} d={`${r.verilenDoz} / ${r.toplamDoz} ${c('doz verildi')}`} />
      </div>
      <div className="rt-bl"><h5>{c('Güvenlik')}</h5>
        {o.guvenlik.filter(g => g.durum !== 'gri' || g.kontrol === 'Alerji').map(g => (
          <Satir key={g.kontrol} s={c(g.kontrol)} d={<span className={`rozet ${GUV_ROZET[g.durum]}`} title={g.ayrinti}>{c(g.sonuc)}</span>} />
        ))}
      </div>
    </div>
  );
}

// ------------------------------------------------------------ kart parçaları --
/** Kimlik şeridinin üstünde: hasta, yatış yeri / günü, alerji, tanı. */
export function OrderHastaSeridi({ id, yenile }: { id: number; yenile: number }) {
  const o = useOzet(id, yenile);
  if (!o) return null;
  const r = o.order;
  return (
    <div className="od-hasta">
      <span><b>{r.hasta}</b>{[r.yas, cinsiyet(r.cinsiyet)].filter(Boolean).length > 0 && ` · ${[r.yas, cinsiyet(r.cinsiyet)].filter(Boolean).join(' ')}`}</span>
      <span>{c('Yatış')}: {[r.servis, r.yatak].filter(Boolean).join(' · ') || '—'} · {c('gün')} {r.yatisGunu}</span>
      <span>{c('Alerji')}: {r.alerjiler ? <b className="od-kirmizi">{r.alerjiler}</b> : <b className="od-yesil">{c('bilinen yok')}</b>}</span>
      {r.tani && <span>{c('Tanı')}: {r.tani}</span>}
      {r.alerjiEslesen && <span className="od-kirmizi">⚠ {c('Order kayıtlı alerjiyle eşleşiyor')}: {r.alerjiEslesen}</span>}
    </div>
  );
}

/** Order sekmesinin sağında: doz sayıları, sonraki doz, güvenlik özeti. */
export function OrderOzetKutusu({ id, yenile }: { id: number; yenile: number }) {
  const o = useOzet(id, yenile);
  if (!o) return <div className="od-ozet sonuk">{c('yükleniyor')}…</div>;
  const r = o.order;
  return (
    <div className="od-ozet">
      <h6 className="rt-baslik">{c('Özet')}</h6>
      <Satir s={c('Toplam doz')} d={r.toplamDoz} />
      <Satir s={c('Verilen / kalan')} d={`${r.verilenDoz} / ${Math.max(0, r.toplamDoz - r.verilenDoz)}`} />
      <Satir s={c('Geciken')} d={r.gecikenDoz > 0 ? <span className="od-kirmizi">{r.gecikenDoz}</span> : 0} />
      <Satir s={c('Sonraki doz')} d={r.sonraki ?? '—'} />
      <Satir s={c('Gün')} d={`${r.gunNo}${r.gunToplam ? ` / ${r.gunToplam}` : ''}`} />
      <h6 className="rt-baslik" style={{ marginTop: 10 }}>{c('Bugün')}</h6>
      <BugunDozlar o={o} />
      {r.yuksekRisk === 1 && <div className="tl-uyari rt-kucuk" style={{ marginTop: 8 }}>⚠ {c('Yüksek riskli ilaç')} ({r.riskAnahtar}) - {c('uygulamada çift kontrol')}</div>}
      <div className="sonuk rt-kucuk" style={{ marginTop: 8 }}>
        {c('Kaydedilince doz planı üretilir; doz kuyruğu bu plandan beslenir. Doz değişikliği order\'ı durdurup yeni order açar (iz kalsın diye).')}
      </div>
    </div>
  );
}

export function OrderPlanSekmesi({ id, yenile }: { id: number; yenile: number }) {
  const [p, setP] = useState<OrderPlan | null>(null);
  useEffect(() => { api.orderPlan(id).then(setP).catch(() => setP(null)) }, [id, yenile]);
  if (!p) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;
  if (p.izgara.length === 0) return <div className="sonuk" style={{ padding: 16 }}>{c('Bu order için saatli doz planı yok (uygulama saati girilmemiş ya da ilaç / sıvı değil).')}</div>;
  const gun = (s: string) => new Date(`${s}T00:00:00`).toLocaleDateString('tr-TR', { weekday: 'short', day: '2-digit', month: '2-digit' });
  return (
    <div className="rt-sekme">
      <div className="rt-baslik">{c('Doz planı')} <span className="sonuk">({c('yeşil verildi · kırmızı gecikti · beyaz bekliyor · kesikli planlı')})</span></div>
      <div className="od-plan-kap">
        <table className="od-plan">
          <thead><tr><th />{p.gunler.map(g => <th key={g} className={g === p.bugun ? 'bugun' : undefined}>{gun(g)}</th>)}</tr></thead>
          <tbody>{p.izgara.map(s => (
            <tr key={s.saat}><th>{s.saat}</th>{s.hucreler.map((h, i) => (
              <td key={i} className={`od-p-${h.durum < 0 ? 'yok' : DOZ_DURUM[h.durum]?.[1] ?? 'bek'}`}>
                {h.durum < 0 ? '' : h.durum === 2 ? `✓ ${h.uygulanan ?? ''}` : c(DOZ_DURUM[h.durum]?.[0] ?? '')}
              </td>
            ))}</tr>
          ))}</tbody>
        </table>
      </div>
    </div>
  );
}

export function OrderGuvenlikSekmesi({ id, yenile }: { id: number; yenile: number }) {
  const o = useOzet(id, yenile);
  if (!o) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;
  return (
    <div className="rt-sekme od-guv">
      <div>
        <div className="rt-baslik">{c('Güvenlik kontrolleri')} <span className="sonuk">({c('sunucuda, kayıtlı bilgilerden')})</span></div>
        <table className="rt-tablo">
          <thead><tr><th>{c('Kontrol')}</th><th>{c('Sonuç')}</th><th>{c('Ayrıntı')}</th></tr></thead>
          <tbody>{o.guvenlik.map(g => (
            <tr key={g.kontrol}><td><b>{c(g.kontrol)}</b></td>
              <td><span className={`rozet ${GUV_ROZET[g.durum]}`}>{c(g.sonuc)}</span></td><td>{g.ayrinti}</td></tr>
          ))}</tbody>
        </table>
      </div>
      <div className="tl-uyari rt-kucuk">
        {c('Uyarı çıkarsa order kaydı durmaz; hekim kararıyla devam edilir. Alerji eşleşmesi etken maddenin adıyla yapılır - ilaç sınıfı (penisilin → amoksisilin) eşlemesi yoktur.')}
      </div>
    </div>
  );
}

export function OrderGecmisSekmesi({ id, yenile }: { id: number; yenile: number }) {
  const [l, setL] = useState<OrderGecmisSatiri[] | null>(null);
  useEffect(() => { api.orderGecmis(id).then(y => setL(y.satirlar)).catch(() => setL([])) }, [id, yenile]);
  if (!l) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;
  const ozet = (b: string) => {
    if (!b.startsWith('{')) return b;
    try { return Object.entries(JSON.parse(b) as Record<string, unknown>).map(([k, v]) => `${k}: ${String(v)}`).join(' · ') } catch { return b }
  };
  return (
    <div className="rt-sekme">
      <div className="rt-baslik">{c('Order geçmişi')}</div>
      {l.length === 0 ? <div className="sonuk">{c('Kayıt yok.')}</div> : (
        <table className="rt-tablo">
          <thead><tr><th>{c('Zaman')}</th><th>{c('İşlem')}</th><th>{c('Kim')}</th><th>{c('Ayrıntı')}</th></tr></thead>
          <tbody>{l.map((s, i) => (
            <tr key={i}><td>{tarihSaat(s.tarih)}</td><td>{c(s.islem)}</td><td>{s.kullanici}</td><td className="rt-kucuk">{ozet(s.bilgi)}</td></tr>
          ))}</tbody>
        </table>
      )}
    </div>
  );
}
