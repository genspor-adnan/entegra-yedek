import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni, type Kosul, type ListeSatiri } from '../../api/sozlesme';
import type { PersonelGostergeYaniti, PersonelOnizleme as Onizleme } from '../../api/uclar/izin';
import { Avatar } from '../../bilesenler/grid/satirHucre';
import { guvenli } from '../../bilesenler/mesaj';
import { sayi, tarihSaat } from '../../bilesenler/bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { PERSONEL_TALEP_TURLERI, type PersonelTalepDurumu } from '../../bilesenler/taleplerim/personelTalebi';
import type { PersonelSuzgeci } from './usePersonelSuzgeci';
import type { GostergeKodu } from './personelGosterge';
import { c } from '../../dil/ceviri';

/**
 * PERSONEL LİSTESİ PANELLERİ (963, mockup Ekranlar/IK/personel_listesi.html).
 *
 *   PersonelGostergesi  gridin üstünde; her kutu bir süzgeç (tekrar tıkla = kaldır)
 *   PersonelBolumAgaci  solda; bölüm + alt birimler, personel sayılı, "Bölümsüz"
 *   PersonelOnizleme    sağda; seçili personel - bugün, bakiye, son talepler, eksikler
 *   PersonelKartlari / PersonelOrganizasyon  ek görünümler (fotoğraflı ızgara, yönetici ağacı)
 *
 * Sayılar sunucudaki v_personel_durum görünümünden: kutu ile süzülen satırlar
 * aynı tanımı okur.
 */
/** Gösterge + ağaç verisi: seçili bölüm / rol değişince tazelenir. */
export function usePersonelGostergesi(aktif: boolean, s: PersonelSuzgeci, yenile: number) {
  const [veri, setVeri] = useState<PersonelGostergeYaniti | null>(null);
  const bolumAnahtar = s.bolum ? `${s.bolum.id}:${s.bolum.agac.join(',')}` : '';
  useEffect(() => {
    if (!aktif) return;
    const p = new URLSearchParams();
    if (s.bolum?.id === -1) p.set('bolumsuz', '1');
    else if (s.bolum) p.set('bolumler', s.bolum.agac.join(','));
    if (s.rol !== '') p.set('rol', String(s.rol));
    api.personelGosterge(p).then(setVeri).catch(() => setVeri(null));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [aktif, bolumAnahtar, s.rol, yenile]);
  return veri;
}

export function PersonelGostergesi({ veri, s }: { veri: PersonelGostergeYaniti | null; s: PersonelSuzgeci }) {
  const g = veri?.gosterge;
  const kutular: { kod: GostergeKodu | null; deger: number | undefined; ad: string; ek?: string; sinif?: string }[] = [
    { kod: null, deger: g?.aktif, ad: 'Aktif personel' },
    { kod: 'izinde', deger: g?.izinde, ad: 'Bugün izinde' },
    { kod: 'raporlu', deger: g?.raporlu, ad: 'Raporlu' },
    { kod: 'talep', deger: g?.onaydaTalep, ad: 'Onay bekleyen talep', ek: g?.talepliKisi ? `${g.talepliKisi} ${c('kişi')}` : undefined,
      sinif: g?.onaydaTalep ? 'uyari' : undefined },
    { kod: 'deneme', deger: g?.deneme, ad: 'Deneme süresinde' },
    { kod: 'dogum', deger: g?.dogumBuAy, ad: 'Bu ay doğum günü 🎂' },
    { kod: 'eksik', deger: g?.eksik, ad: 'Eksik özlük bilgisi', sinif: g?.eksik ? 'kirmizi' : undefined },
  ];
  return (
    <div className="pl-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" className={`pl-k${s.gosterge === k.kod ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                title={k.kod ? c('Listeyi bu kümeye süz (tekrar tıkla: kaldır)') : c('Süzgeci kaldır')}
                onClick={() => s.setGosterge(k.kod === null || s.gosterge === k.kod ? null : k.kod)}>
          <b>{k.deger ?? '…'}</b><span>{c(k.ad)}{k.ek ? ` · ${k.ek}` : ''}</span>
        </button>
      ))}
    </div>
  );
}

interface Dal { id: number; ad: string; sayi: number; toplam: number; cocuk: Dal[]; agac: number[] }

/** Düz bölüm listesinden ağaç; personeli olmayan dallar düşer. */
function agacKur(liste: PersonelGostergeYaniti['bolumler']): Dal[] {
  const dugum = new Map<number, Dal>(liste.map(b => [b.id, { id: b.id, ad: b.ad, sayi: b.sayi, toplam: 0, cocuk: [], agac: [] }]));
  const kok: Dal[] = [];
  for (const b of liste) {
    const d = dugum.get(b.id)!;
    const u = b.ust ? dugum.get(b.ust) : undefined;
    if (u && u !== d) u.cocuk.push(d); else kok.push(d);
  }
  const topla = (d: Dal, yol: Set<number>): Dal | null => {
    if (yol.has(d.id)) return null;            // döngülü veri koruması
    yol.add(d.id);
    d.cocuk = d.cocuk.map(x => topla(x, yol)).filter((x): x is Dal => !!x);
    d.toplam = d.sayi + d.cocuk.reduce((t, x) => t + x.toplam, 0);
    d.agac = [d.id, ...d.cocuk.flatMap(x => x.agac)];
    return d.toplam > 0 ? d : null;
  };
  return kok.map(d => topla(d, new Set())).filter((x): x is Dal => !!x);
}

export function PersonelBolumAgaci({ veri, s }: { veri: PersonelGostergeYaniti | null; s: PersonelSuzgeci }) {
  const agac = useMemo(() => agacKur(veri?.bolumler ?? []), [veri]);
  const toplam = agac.reduce((t, d) => t + d.toplam, 0) + (veri?.bolumsuz ?? 0);
  // AÇ / KAPA (kullanıcı: "alt bölüm olanlar kapanır/açılır olsun.. yoksa liste
  //   aşağı doğru çok uzuyor"): varsayılan kapalı; seçili dalın üstleri açık.
  const [acik, setAcik] = useState<Set<number>>(new Set());
  const seciliYol = useMemo(() => {
    const yol = new Set<number>();
    const ara = (l: Dal[], ust: number[]): boolean => l.some(d =>
      d.id === s.bolum?.id ? (ust.forEach(x => yol.add(x)), true) : ara(d.cocuk, [...ust, d.id]));
    ara(agac, []);
    return yol;
  }, [agac, s.bolum?.id]);
  const degistir = (id: number) => setAcik(o => { const y = new Set(o); if (y.has(id)) y.delete(id); else y.add(id); return y });
  const dal = (d: Dal, derinlik: number) => {
    const acikMi = acik.has(d.id) || seciliYol.has(d.id);
    return (
      <div key={d.id}>
        <div className={`pl-dal${s.bolum?.id === d.id ? ' on' : ''}`} style={{ paddingLeft: 4 + derinlik * 14 }}>
          {d.cocuk.length > 0
            ? <button type="button" className="pl-ok" title={acikMi ? c('Kapat') : c('Aç')} onClick={() => degistir(d.id)}>
                <svg width="14" height="14" viewBox="0 0 14 14" aria-hidden="true"
                     style={{ transform: acikMi ? 'rotate(90deg)' : undefined, transition: 'transform .12s' }}>
                  <path d="M5 2.5 L9.5 7 L5 11.5" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </button>
            : <span className="pl-ok" />}
          <button type="button" className="pl-dal-ad" onClick={() => s.setBolum({ id: d.id, agac: d.agac })}
                  onDoubleClick={() => d.cocuk.length > 0 && degistir(d.id)}>
            <span>{d.ad}</span><i>{d.toplam}</i>
          </button>
        </div>
        {acikMi && d.cocuk.map(x => dal(x, derinlik + 1))}
      </div>
    );
  };
  return (
    <div className="pl-agac pl-sol-isaret">
      <h6>{c('Bölüm')}</h6>
      <div className={`pl-dal${s.bolum === null ? ' on' : ''}`} style={{ paddingLeft: 4 }}>
        <span className="pl-ok" />
        <button type="button" className="pl-dal-ad" onClick={() => s.setBolum(null)}><span>{c('Tümü')}</span><i>{toplam}</i></button>
      </div>
      {agac.map(d => dal(d, 0))}
      {(veri?.bolumsuz ?? 0) > 0 && (
        <div className={`pl-dal pl-bolumsuz${s.bolum?.id === -1 ? ' on' : ''}`} style={{ paddingLeft: 4 }}>
          <span className="pl-ok" />
          <button type="button" className="pl-dal-ad" title={c('Bölümü atanmamış personel')}
                  onClick={() => s.setBolum({ id: -1, agac: [] })}><span>{c('Bölümsüz')}</span><i>{veri?.bolumsuz}</i></button>
        </div>
      )}
    </div>
  );
}

const TALEP_RENGI: Record<string, string> = { taslak: 'gri', onayda: 'uyari', acik: 'mavi', tamam: 'olumlu', red: 'hata', iptal: 'gri' };

export function PersonelOnizleme({ satir, yenile }: { satir: ListeSatiri | null; yenile: number }) {
  const git = useNavigate();
  const { yetki } = useOturum();
  const id = satir ? Number(satir.id) : 0;
  const [o, setO] = useState<Onizleme | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [menu, setMenu] = useState(false);
  useEffect(() => {
    setO(null); setHata(null);
    if (!(id > 0)) return;
    api.personelOnizleme(id).then(setO).catch(e => setHata(hataMetni(e)));
  }, [id, yenile]);

  if (!(id > 0)) return <div className="pl-oniz bos sonuk">{c('Önizleme için bir personel seçin.')}</div>;
  if (hata) return <div className="pl-oniz"><div className="hata-kutusu">{hata}</div></div>;
  if (!o) return <div className="pl-oniz bos sonuk">{c('yükleniyor')}…</div>;
  const k = o.kisi;
  const durum: PersonelTalepDurumu = { personel: { id, ad: k.ad }, geri: '/personel', arka: 'personel' };
  const eksikler = [
    ...(k.eksik ? [`${c('Özlük')}: ${k.eksik}`] : []),
    ...o.egitim.map(e => `${e.ad}: ${e.gecerlilik && new Date(e.gecerlilik) < new Date() ? c('süresi doldu') : c('süresi doluyor')} (${tarihSaat(e.gecerlilik).slice(0, 10)})`),
  ];
  const mesaj = () => guvenli(async () => {
    const y = await api.mesajSohbetAc({ tip: 1, uyeler: [id] });
    git(`/mesajlar?sohbet=${y.id}`);
  });
  return (
    <div className="pl-oniz">
      <div className="pl-kimlik"><Avatar ad={k.ad} buyuk soluk={k.bugunKod === 0} />
        <div><b>{k.ad}{k.dogumBugun ? ' 🎂' : ''}</b><small>{[k.gorev, k.bolum].filter(Boolean).join(' · ')}</small>
          <small>{c('Sicil')} {k.sicil}{k.iseGiris ? ` · ${c('işe giriş')} ${tarihSaat(k.iseGiris).slice(0, 10)}` : ''}</small></div></div>

      <div className="pl-bl"><h5>{c('Bugün')}</h5>
        <div className="pl-satir"><span>{c('Durum')}</span><b className={`pl-durum k${k.bugunKod}`}>{c(k.bugun)}</b></div>
        {k.kidem && <div className="pl-satir"><span>{c('Kıdem')}</span>{k.kidem}</div>}
        {k.rol && <div className="pl-satir"><span>{c('Rol')}</span>{k.rol}</div>}
        {k.yonetici && <div className="pl-satir"><span>{c('Yönetici')}</span>{k.yonetici}</div>}
        {k.telefon && <div className="pl-satir"><span>{c('Telefon')}</span>{k.telefon}</div>}
        {k.eposta && <div className="pl-satir"><span>{c('E-posta')}</span><span className="pl-kes" title={k.eposta}>{k.eposta}</span></div>}
      </div>

      <div className="pl-bl"><h5>{c('İzin bakiyesi')} · {new Date().getFullYear()}
        {yetki('ik.izin') && <button type="button" className="pl-bag" onClick={() => git('/izin-bakiye')}>{c('İzinler')} ›</button>}</h5>
        {k.hakToplam === null ? <div className="sonuk">{c('İşe giriş tarihi yok - hak hesaplanamıyor.')}</div> : (
          <div className="pl-bakiye">
            <div><b>{sayi.format(k.hakToplam)}</b>{c('Hak + devir')}</div>
            <div><b>{sayi.format(k.kullanilan)}</b>{c('Kullanılan')}</div>
            <div className="yesil"><b>{sayi.format(k.kalanIzin ?? 0)}</b>{c('Kalan')}</div>
          </div>
        )}
        {k.onayda > 0 && <div className="sonuk pl-kucuk">{sayi.format(k.onayda)} {c('gün onayda')}</div>}
      </div>

      <div className="pl-bl"><h5>{c('Son talepler')}
        <button type="button" className="pl-bag" onClick={() => git(`/personel/${id}`)}>{c('Tümü')} ›</button></h5>
        {o.talepler.length === 0 ? <div className="sonuk">{c('Talep yok.')}</div> : o.talepler.map(t => (
          <div key={`${t.tur}-${t.id}`} className="pl-talep">
            <div>{c(t.baslik)}<small>{[t.no, t.detay].filter(Boolean).join(' · ')}</small></div>
            <span className={`rozet ${TALEP_RENGI[t.grup] ?? 'gri'}`}>{c(t.durumAdi)}</span>
          </div>
        ))}
      </div>

      {eksikler.length > 0 && (
        <div className="pl-bl"><h5>{c('Eksikler')}</h5>
          <div className="tl-uyari pl-kucuk">⚠ {eksikler.join(' · ')}</div></div>
      )}

      <div className="pl-bl"><h5>{c('Hızlı işlem')}</h5>
        <div className="pl-hizli">
          <button type="button" className="d mini" onClick={() => git(`/personel/${id}`)}>📇 {c('Kartı aç')}</button>
          <span className="dugme-menu">
            <button type="button" className="d mini" onClick={e => { e.stopPropagation(); setMenu(m => !m) }}>📨 {c('Yeni talep')} ▾</button>
            {menu && (
              <div className="dugme-menu-liste" onMouseLeave={() => setMenu(false)}>
                {PERSONEL_TALEP_TURLERI.filter(t => yetki(t.yetki, 'ekle')).map(t => (
                  <button key={t.kod} type="button" className="mi" onClick={() => { setMenu(false); git(`${t.yol}/yeni`, { state: durum }) }}>{c(t.ad)}</button>
                ))}
              </div>
            )}
          </span>
          {yetki('mesaj') && <button type="button" className="d mini" onClick={() => void mesaj()}>💬 {c('Mesaj')}</button>}
          {yetki('randevu.plan') && <button type="button" className="d mini" onClick={() => git('/calisma-plani')}>📅 {c('Çalışma planı')}</button>}
        </div>
      </div>
    </div>
  );
}

/** Kart / Organizasyon görünümlerinin verisi: liste süzgeciyle, aktif personel. */
function usePersonelSatirlari(filtre: Kosul | undefined, yenile: number) {
  const [satirlar, setSatirlar] = useState<ListeSatiri[] | null>(null);
  const anahtar = JSON.stringify(filtre ?? null);
  useEffect(() => {
    const aktif: Kosul = { alan: 'durum', op: 'esit', deger: 1 };
    api.liste('personel', { sayfa: 1, boyut: 1000, filtre: filtre ? { op: 'and', kosullar: [aktif, filtre] } : aktif })
      .then(y => setSatirlar(y.satirlar)).catch(() => setSatirlar([]));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [anahtar, yenile]);
  return satirlar;
}

function KisiKarti({ r, onAc }: { r: ListeSatiri; onAc(): void }) {
  const ad = String(r.unvan ?? '');
  const bugun = String(r.bugun ?? '');
  return (
    <button type="button" className="pl-kart" onDoubleClick={onAc} title={c('Çift tık: kartı aç')}>
      <Avatar ad={ad} buyuk />
      <b>{ad}</b>
      <small>{String(r.gorev ?? '')}</small>
      <small className="sonuk">{String(r.departmanAdi ?? '')}</small>
      {bugun && <span className={`rozet ${bugun === 'Çalışıyor' ? 'olumlu' : bugun.startsWith('İzinde') ? 'mavi' : bugun.startsWith('Raporlu') ? 'hata' : 'uyari'}`}>{c(bugun)}</span>}
    </button>
  );
}

export function PersonelKartlari({ filtre, yenile }: { filtre: Kosul | undefined; yenile: number }) {
  const git = useNavigate();
  const satirlar = usePersonelSatirlari(filtre, yenile);
  if (!satirlar) return <div className="kutu sonuk" style={{ padding: 24 }}>{c('yükleniyor')}…</div>;
  return (
    <div className="kutu pl-kartlar">
      {satirlar.length === 0 && <div className="sonuk">{c('Kayıt yok')}</div>}
      {satirlar.map(r => <KisiKarti key={String(r.id)} r={r} onAc={() => git(`/personel/${r.id}`)} />)}
    </div>
  );
}

interface OrgDugum { r: ListeSatiri; alt: OrgDugum[] }

export function PersonelOrganizasyon({ filtre, yenile }: { filtre: Kosul | undefined; yenile: number }) {
  const git = useNavigate();
  const satirlar = usePersonelSatirlari(filtre, yenile);
  const kokler = useMemo(() => {
    if (!satirlar) return [];
    const harita = new Map<number, OrgDugum>(satirlar.map(r => [Number(r.id), { r, alt: [] }]));
    const kok: OrgDugum[] = [];
    for (const d of harita.values()) {
      const y = Number(d.r.yoneticiId ?? 0);
      const u = y && y !== Number(d.r.id) ? harita.get(y) : undefined;
      if (u) u.alt.push(d); else kok.push(d);
    }
    // Ast sayısı çok olan yönetici üstte; yöneticisiz tek kişiler sonda toplanır.
    const sirala = (l: OrgDugum[]) => l.sort((a, b) => b.alt.length - a.alt.length
      || String(a.r.unvan).localeCompare(String(b.r.unvan), 'tr'));
    const gez = (l: OrgDugum[]) => { sirala(l); l.forEach(x => gez(x.alt)) };
    gez(kok);
    return kok;
  }, [satirlar]);
  if (!satirlar) return <div className="kutu sonuk" style={{ padding: 24 }}>{c('yükleniyor')}…</div>;
  const yoneticili = kokler.filter(k => k.alt.length > 0);
  const tekler = kokler.filter(k => k.alt.length === 0);
  const ciz = (d: OrgDugum, derinlik: number, yol: Set<number>): React.ReactNode => {
    if (yol.has(Number(d.r.id))) return null;
    const y2 = new Set(yol).add(Number(d.r.id));
    return (
      <div key={String(d.r.id)} className={`pl-org-dal${derinlik ? "" : " kok"}`} style={{ marginLeft: derinlik ? 28 : 0 }}>
        <div className="pl-org-kisi" onDoubleClick={() => git(`/personel/${d.r.id}`)} title={c('Çift tık: kartı aç')}>
          <Avatar ad={String(d.r.unvan ?? '')} />
          <span><b>{String(d.r.unvan ?? '')}</b><small>{[d.r.gorev, d.r.departmanAdi].filter(Boolean).join(' · ')}</small></span>
          {d.alt.length > 0 && <span className="pl-org-say">{d.alt.length} {c('kişi')}</span>}
        </div>
        {d.alt.map(x => ciz(x, derinlik + 1, y2))}
      </div>
    );
  };
  return (
    <div className="kutu pl-org">
      {yoneticili.length === 0 && <div className="tl-bilgi">{c('Personel kartlarında yönetici girilmemiş - ağaç kurulamıyor. Özlük sekmesinden "Yönetici" alanını doldurun.')}</div>}
      {yoneticili.map(d => ciz(d, 0, new Set()))}
      {tekler.length > 0 && (
        <>
          <h6 className="pl-org-baslik">{c('Yöneticisi girilmemiş')} · {tekler.length}</h6>
          <div className="pl-kartlar ic">{tekler.map(d => <KisiKarti key={String(d.r.id)} r={d.r} onAc={() => git(`/personel/${d.r.id}`)} />)}</div>
        </>
      )}
    </div>
  );
}
