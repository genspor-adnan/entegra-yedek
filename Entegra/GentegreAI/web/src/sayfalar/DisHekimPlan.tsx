import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { HaftalikPlan, PlanZiyareti, SiradakiHedef } from '../api/uclar/disHekim';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { GenLookup } from '../bilesenler/GenLookup';
import { Modal } from '../bilesenler/Modal';
import { c as cev } from '../dil/ceviri';
import { useOturum } from '../kimlik/OturumBaglami';

/**
 * ZİYARET PLANI = TEMSİLCİ PANELİ + HAFTALIK PLAN + "SIRASI GELENLER" ÇEKMECESİ
 * (1290; mockup Ekranlar/Radyoloji/temsilci_paneli_plan.html ve _v2.html; kullanıcı 11.11.2026 "mockup uygula").
 *
 * Üstte ÖZET KUTULARI (bugün planlı / yapıldı, geciken, açık talep, öneri, bu ay gönderim-satış, hedeflerim) - tıklayınca
 * alttaki tablo o kümeye süzülür. Ortada HAFTA ŞERİDİ (5 gün; öneri kesik ✓/✖, planlı sürüklenir). Altta SEÇİLİ GÜNÜN
 * İŞİ tablosu (gün başlığına tıkla; "Bu hafta" çipi tümü). Sağda çekmece: planı olmayan, sırası gelen hedefler ilçe /
 * ölçüt çipleriyle; satır güne SÜRÜKLENİR, işaretlenip "Seçilenleri plana ekle", ilçe başlığından "güne dağıt",
 * "Haftaya dağıt" = Planı Üret seçilenlerle (1299). Görünüm segmenti İkisi / Liste / Takvim (localStorage dhp.mod).
 * İKİ KİP (1297): HBYS dış doktor / gönderim, ERP müşteri / satış - metinler kullanici.urunModu.
 * "Planı Üret" sunucuda (fn_dis_hekim_plan_uret) sıklıktan ÖNERİ çıkarır; ROTA (§4) kullanıcı kararıyla yapılmadı.
 */
const GUNLER = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum'];
type Mod = 'ikisi' | 'liste' | 'takvim';
type Cip = 'tum' | 'geciken' | 'dusen' | 'talepli' | 'oneri';
type Olcut = 'geciken' | 'buhafta' | 'dusen' | 'talepli' | 'yeni';

const haftaBasi = (d: Date) => {
  const x = new Date(d); x.setHours(0, 0, 0, 0);
  x.setDate(x.getDate() - ((x.getDay() + 6) % 7));
  return x;
};
const isoGun = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const saat = (iso: string) => new Date(iso).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
const tarihYaz = (iso: string | null | undefined) => iso ? new Date(iso).toLocaleDateString('tr-TR') : '—';
const modOku = (): Mod => { try { const m = localStorage.getItem('dhp.mod'); return m === 'liste' || m === 'takvim' ? m : 'ikisi' } catch { return 'ikisi' } };
const bugunIdx = () => { const g = (new Date().getDay() + 6) % 7; return g > 4 ? 0 : g };

export function DisHekimPlan() {
  const git = useNavigate();
  const { kullanici } = useOturum();
  // İKİ KİP (1297): HBYS dış doktor, ERP müşteri - metinler ona göre.
  const erp = kullanici?.urunModu === 1;
  const S = erp
    ? { hedef: 'Müşteri', hedefK: 'müşteri', hedefler: 'Müşterilerim', gonderim: 'Satış', gonderimK: 'satış', gonderimi: 'Satışı', ist: '30 gün satış', yol: 'Cari & CRM › CRM › Ziyaret Planı', kart: '/cari' }
    : { hedef: 'Dış Doktor', hedefK: 'hekim', hedefler: 'Hekimlerim', gonderim: 'Gönderim', gonderimK: 'gönderim', gonderimi: 'Gönderimi', ist: '30 gün ist.', yol: 'Kurumlar & Sigorta › Dış Doktorlar › Ziyaret Planı', kart: '/dis-hekim' };

  const [hafta, setHafta] = useState(() => haftaBasi(new Date()));
  const [temsilci, setTemsilci] = useState<number | undefined>(undefined);
  const [veri, setVeri] = useState<HaftalikPlan | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [yenile, setYenile] = useState(0);
  const [gunBasi, setGunBasi] = useState(6);
  const [grupla, setGrupla] = useState(true);
  const [hedef, setHedef] = useState<number | null>(null);
  const [surukle, setSurukle] = useState<PlanZiyareti | null>(null);
  const [surukleHedef, setSurukleHedef] = useState<SiradakiHedef | null>(null);
  const [mod, setMod] = useState<Mod>(modOku);
  const [seciliGun, setSeciliGun] = useState<number | 'hafta'>(bugunIdx);
  const [cip, setCip] = useState<Cip>('tum');
  const [ara, setAra] = useState('');
  // ÇEKMECE (mockup v2)
  const [cekmece, setCekmece] = useState(false);
  const [ilce, setIlce] = useState('');
  const [olcutler, setOlcutler] = useState<Set<Olcut>>(() => new Set<Olcut>(['geciken', 'buhafta']));
  const [cekAra, setCekAra] = useState('');
  const [secili, setSecili] = useState<Set<number>>(() => new Set());
  const [ekleGunu, setEkleGunu] = useState<number | null>(null);
  const [ekleSaati, setEkleSaati] = useState('');
  // ELLE EKLE (gün başlığındaki ＋): hedef araması + saat; POST /planla.
  const [ekleGun, setEkleGun] = useState<number | null>(null);
  const [ekleHekim, setEkleHekim] = useState<{ id: number; ad: string } | null>(null);
  const [ekleSaat, setEkleSaat] = useState('10:00');

  useEffect(() => {
    void (async () => {
      try { const y = await api.disHekimPlan(isoGun(hafta), temsilci); setVeri(y); setHata(null); if (!temsilci) setTemsilci(y.temsilciId) }
      catch (h) { setHata(hataMetni(h)) }
    })();
  }, [hafta, temsilci, yenile]);
  useEffect(() => { try { localStorage.setItem('dhp.mod', mod) } catch { /* özel pencere */ } }, [mod]);

  const haftaDegis = (f: number) => { const d = new Date(hafta); d.setDate(d.getDate() + 7 * f); setHafta(d); setSeciliGun(0) };
  const gunTarihi = (i: number) => { const d = new Date(hafta); d.setDate(d.getDate() + i); return d };
  const bugun = isoGun(new Date());
  const buguneGit = () => { setHafta(haftaBasi(new Date())); setSeciliGun(bugunIdx()) };
  const tazele = () => setYenile(t => t + 1);

  const uret = (hekimIdler?: number[]) => guvenli(async () => {
    const y = await api.disHekimPlanUret({ haftaBas: isoGun(hafta), temsilciId: temsilci, gunBasi, grupla, hekimIdler });
    mesaj(y.mesaj); if (hekimIdler) setSecili(new Set()); tazele();
  });
  const onayla = (z: PlanZiyareti) => guvenli(async () => { await api.disHekimZiyaretOnayla(z.id); tazele() });
  const iptal = async (z: PlanZiyareti) => {
    if (!z.oneri && !await onay(`${z.hekim_ad} ziyareti iptal edilecek. Onaylıyor musunuz?`)) return;
    await guvenli(async () => { const y = await api.disHekimZiyaretIptal(z.id); mesaj(y.mesaj); tazele() });
  };
  // SESSİZ (kullanıcı 11.11.2026: sürükle-bıraktan sonra "1 ziyaret planlandı" gelmesin): kart takvimde belirir,
  //   mesaj yalnız bir şey planlanamadıysa.
  const topluPlanla = (hekimIdler: number[], gunIdx: number, baslangicSaat?: string, sessiz = false) => guvenli(async () => {
    if (hekimIdler.length === 0) { mesaj(cev('Önce hedef seçin.')); return }
    const y = await api.disHekimPlanlaToplu({ hekimIdler, gun: isoGun(gunTarihi(gunIdx)), baslangicSaat: baslangicSaat || undefined, temsilciId: temsilci });
    if (!sessiz || y.sayi === 0) mesaj(y.mesaj);
    setSecili(s => { const n = new Set(s); hekimIdler.forEach(h => n.delete(h)); return n }); tazele();
  });
  const birak = (gunIdx: number) => {
    setHedef(null);
    // Çekmeceden güne bırakma (v2): tek hedef, saat gündeki sondan + 90 dk (sunucu).
    if (surukleHedef) { const h = surukleHedef; setSurukleHedef(null); void topluPlanla([h.hekim_id], gunIdx, undefined, true); return }
    if (!surukle || surukle.durum !== 0) return;
    const eski = new Date(surukle.tarih);
    const yeni = gunTarihi(gunIdx); yeni.setHours(eski.getHours(), eski.getMinutes(), 0, 0);
    if (isoGun(yeni) === isoGun(eski)) return;
    const z = surukle; setSurukle(null);
    void guvenli(async () => { await api.disHekimZiyaretTasi(z.id, `${isoGun(yeni)}T${String(yeni.getHours()).padStart(2, '0')}:${String(yeni.getMinutes()).padStart(2, '0')}:00`); tazele() });
  };
  const ekle = () => {
    if (ekleGun === null || !ekleHekim) { mesaj(erp ? 'Müşteri seçin.' : 'Dış doktor seçin.'); return }
    const gun = isoGun(gunTarihi(ekleGun));
    void guvenli(async () => {
      const y = await api.disHekimPlanla({ hekimId: ekleHekim.id, tarih: `${gun}T${ekleSaat || '10:00'}:00`, temsilciId: temsilci });
      mesaj(y.mesaj); setEkleGun(null); setEkleHekim(null); tazele();
    });
  };

  const ziyaretler = veri?.ziyaretler ?? [];
  const oneri = ziyaretler.filter(z => z.oneri === 1).length;
  const yapildi = ziyaretler.filter(z => z.durum === 1).length;
  const temsilciAd = veri?.temsilciler.find(t => t.id === temsilci)?.ad ?? '';
  const simdi = new Date();
  const gecikenMi = (z: PlanZiyareti) => z.durum === 0 && new Date(z.tarih) < simdi && isoGun(new Date(z.tarih)) !== bugun;
  const seciliGunIso = seciliGun === 'hafta' ? '' : isoGun(gunTarihi(seciliGun));

  // GÜNÜN İŞİ: seçili gün (ya da hafta) + çip + arama.
  const gunSatirlari = useMemo(() => {
    const k = ara.trim().toLocaleLowerCase('tr-TR');
    return ziyaretler.filter(z => seciliGun === 'hafta' || isoGun(new Date(z.tarih)) === seciliGunIso)
      .filter(z => cip === 'tum' || (cip === 'geciken' && gecikenMi(z)) || (cip === 'dusen' && z.gonderim_dusen === 1)
                || (cip === 'talepli' && z.acik_talep > 0) || (cip === 'oneri' && z.oneri === 1))
      .filter(z => !k || `${z.hekim_ad} ${z.hekim_kurum} ${z.hekim_ilce}`.toLocaleLowerCase('tr-TR').includes(k));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [ziyaretler, seciliGun, seciliGunIso, cip, ara]);

  // ÇEKMECE: sırası gelenler, ilçe + ölçüt + arama.
  const siradakiler = veri?.siradakiler ?? [];
  const haftaSon = isoGun(gunTarihi(6));
  const olcutUyar = (h: SiradakiHedef) => {
    if (olcutler.size === 0) return true;
    return (olcutler.has('geciken') && h.gecikme_gun > 0)
      || (olcutler.has('buhafta') && !!h.vade_tarihi && h.vade_tarihi.slice(0, 10) <= haftaSon && h.gecikme_gun === 0)
      || (olcutler.has('dusen') && h.gonderim_dusen === 1)
      || (olcutler.has('talepli') && h.acik_talep > 0)
      || (olcutler.has('yeni') && h.yeni_hekim === 1);
  };
  const cekSatirlari = useMemo(() => {
    const k = cekAra.trim().toLocaleLowerCase('tr-TR');
    return siradakiler.filter(olcutUyar).filter(h => !ilce || (h.hekim_ilce || '—') === ilce)
      .filter(h => !k || `${h.hekim_ad} ${h.hekim_kurum} ${h.hekim_ilce}`.toLocaleLowerCase('tr-TR').includes(k));
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [siradakiler, olcutler, ilce, cekAra, haftaSon]);
  const ilceler = useMemo(() => {
    const m = new Map<string, number>();
    siradakiler.filter(olcutUyar).forEach(h => { const i = h.hekim_ilce || '—'; m.set(i, (m.get(i) ?? 0) + 1) });
    return [...m.entries()].sort((a, b) => b[1] - a[1]);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [siradakiler, olcutler, haftaSon]);
  const ilceGruplari = useMemo(() => {
    const m = new Map<string, SiradakiHedef[]>();
    cekSatirlari.forEach(h => { const i = h.hekim_ilce || '—'; m.set(i, [...(m.get(i) ?? []), h]) });
    return [...m.entries()];
  }, [cekSatirlari]);
  const olcutDegis = (o: Olcut) => setOlcutler(s => { const n = new Set(s); if (n.has(o)) n.delete(o); else n.add(o); return n });
  const secDegis = (id: number) => setSecili(s => { const n = new Set(s); if (n.has(id)) n.delete(id); else n.add(id); return n });
  const hedefGunIdx = typeof seciliGun === 'number' ? seciliGun : 0;
  const ekleGunIdx = ekleGunu ?? hedefGunIdx;

  // ÖZET KUTUSU → süzgeç kısayolu.
  const kutuSec = (yeniCip: Cip, gun?: number | 'hafta', cekmeceAc?: Olcut) => {
    setCip(yeniCip); if (gun !== undefined) setSeciliGun(gun);
    if (cekmeceAc) { setCekmece(true); setOlcutler(new Set<Olcut>([cekmeceAc])); setIlce('') }
  };
  const o = veri?.ozet;
  const gunAdi = (i: number) => `${GUNLER[i]} ${gunTarihi(i).toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit' })}`;
  const gunSayisi = (i: number) => ziyaretler.filter(z => isoGun(new Date(z.tarih)) === isoGun(gunTarihi(i))).length;

  return (
    <div className="sayfa">
      <div className="sayfabas">
        <div className="basrow">
          <h1>{cev('Ziyaret Planı')}</h1>
          <span className="yol">{cev(S.yol)}</span>
        </div>
      </div>
      <div className="cz-sayfa">
        <div className="cp-arac">
          <button className="d bir" onClick={() => git('/dis-hekim-ziyaret/yeni')}>＋ {cev('Ziyaret')}</button>
          <button className="d" onClick={() => void uret()} data-testid="plan-uret" title={cev(erp ? 'Sırası gelen, planı olmayan müşterilere öneri ziyaret açar' : 'Sırası gelen, planı olmayan hekimlere öneri ziyaret açar')}>⚙ {cev('Planı Üret')}</button>
          <button className={`d${cekmece ? ' bir' : ''}`} onClick={() => setCekmece(c => !c)} data-testid="plan-cekmece">⏰ {cev('Sırası gelenler')} {siradakiler.length > 0 && <span className="rozet hata">{siradakiler.length}</span>}</button>
          <button className="d" onClick={() => git('/dis-hekim-talep')}>📋 {cev('Açık Talepler')}</button>
          <span className="dhp-seg" title={cev('Görünüm')}>
            {(['ikisi', 'liste', 'takvim'] as Mod[]).map(m => (
              <button key={m} type="button" className={mod === m ? 'on' : ''} onClick={() => setMod(m)} data-testid={`plan-mod-${m}`}>
                {m === 'ikisi' ? '▦ ' + cev('İkisi') : m === 'liste' ? '📋 ' + cev('Liste') : '🗓 ' + cev('Takvim')}
              </button>
            ))}
          </span>
          {veri && veri.temsilciler.length > 1 && (
            <select value={temsilci ?? 0} onChange={e => setTemsilci(Number(e.target.value) || undefined)} data-testid="plan-temsilci">
              {veri.temsilciler.map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
            </select>
          )}
          <span style={{ marginLeft: 'auto', fontWeight: 700 }}>{temsilciAd}{temsilciAd ? ' · ' : ''}{new Date().toLocaleDateString('tr-TR', { weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric' })}</span>
          <button className="d" onClick={tazele}>⟳</button>
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className={`dhp-sayfa${cekmece ? ' cekmece' : ''} mod-${mod}`}>
        <div className="dhp-sol">
          {veri && (
            <div className="dhp-ozet">
              <div className={`dhp-kutu${cip === 'tum' && seciliGunIso === bugun ? ' suz' : ''}`} onClick={() => { buguneGit(); setCip('tum') }}>
                <b>{cev('Bugün planlı ziyaret')}</b><span>{o?.bugun_planli ?? 0}</span><small>{o?.bugun_yapildi ?? 0} {cev('yapıldı')}</small>
              </div>
              <div className={`dhp-kutu kir${cip === 'geciken' ? ' suz' : ''}`} onClick={() => kutuSec('geciken', 'hafta', 'geciken')}>
                <b>{cev('Geciken')}</b><span>{veri.vade?.geciken ?? 0}</span><small>{cev(erp ? 'sıklığı aşılan müşteri' : 'sıklığı aşılan hekim')}</small>
              </div>
              <div className={`dhp-kutu kir${cip === 'talepli' ? ' suz' : ''}`} onClick={() => kutuSec('talepli', 'hafta', 'talepli')}>
                <b>{cev('Açık talep')}</b><span>{veri.vade?.talepli ?? 0}</span><small>{cev('talebi açık')} {S.hedefK}</small>
              </div>
              <div className={`dhp-kutu sari${cip === 'oneri' ? ' suz' : ''}`} onClick={() => kutuSec('oneri', 'hafta')}>
                <b>{cev('Öneri')}</b><span>{oneri}</span><small>{cev('onay bekliyor')}</small>
              </div>
              <div className="dhp-kutu ok" onClick={() => git('/saha-performans')} title={cev('Saha Performansı')}>
                <b>{cev('Bu ay')} {S.gonderimK}</b><span>{o?.ay_gonderim ?? 0}</span><small>{cev('geçen ay')} {o?.onceki_ay_gonderim ?? 0} · {S.gonderimK} {cev('düşen')} {veri.vade?.dusen ?? 0}</small>
              </div>
              <div className="dhp-kutu" onClick={() => { setCekmece(true); setOlcutler(new Set()); setIlce('') }}>
                <b>{cev(S.hedefler)}</b><span>{o?.hedef_sayisi ?? 0}</span><small>{o?.sessiz_sayisi ?? 0} · 60 {cev('gündür')} {S.gonderimK} {cev('yok')} · {cev('yeni')} {o?.yeni_sayisi ?? 0}</small>
              </div>
            </div>
          )}

          {mod !== 'liste' && (<>
          <div className="dhp-haftabas">
            <button className="d" onClick={() => haftaDegis(-1)}>‹ {cev('Önceki hafta')}</button>
            <span style={{ fontWeight: 700, color: 'var(--yazi2)' }}>{gunTarihi(0).toLocaleDateString('tr-TR')} – {gunTarihi(4).toLocaleDateString('tr-TR')}</span>
            <button className="d" onClick={() => haftaDegis(1)}>{cev('Sonraki hafta')} ›</button>
            <button className="d" onClick={buguneGit}>{cev('Bu hafta')}</button>
            <span className="dhp-uret" style={{ marginLeft: 'auto' }}>
              <label>{cev('Gün başı')} <input type="number" min={1} max={20} value={gunBasi} onChange={e => setGunBasi(Number(e.target.value) || 6)} /></label>
              <label><input type="checkbox" checked={grupla} onChange={e => setGrupla(e.target.checked)} /> {cev('Aynı ilçe aynı gün')}</label>
              <span>{ziyaretler.filter(z => z.durum === 0 && z.oneri === 0).length} {cev('planlı')} · {yapildi} {cev('yapıldı')} · {oneri} {cev('öneri')}</span>
            </span>
          </div>
          <div className="dhp-hafta">
            {GUNLER.map((ad, i) => {
              const gun = isoGun(gunTarihi(i));
              const liste = ziyaretler.filter(z => isoGun(new Date(z.tarih)) === gun);
              const ilceler2 = [...new Set(liste.map(z => z.hekim_ilce).filter(Boolean))].join(' / ');
              return (
                <div key={ad} className={`dhp-gun${gun === bugun ? ' bugun' : ''}${hedef === i ? ' hedef' : ''}${seciliGun === i ? ' secili' : ''}${mod === 'takvim' ? ' uzun' : ''}`}
                     onClick={() => setSeciliGun(i)}
                     onDragOver={e => { if (surukle || surukleHedef) { e.preventDefault(); setHedef(i) } }}
                     onDragLeave={() => setHedef(h => h === i ? null : h)}
                     onDrop={e => { e.preventDefault(); birak(i) }}>
                  <h5>{gunAdi(i)}<small>{liste.length} {cev('ziyaret')}{ilceler2 ? ` · ${ilceler2}` : ''}</small>
                    <button type="button" className="bs-kalem" title={cev(erp ? 'Bu güne müşteri ekle' : 'Bu güne dış doktor ekle')} data-testid={`plan-ekle-${i}`}
                            onClick={e => { e.stopPropagation(); setEkleGun(i); setEkleHekim(null) }}>＋</button></h5>
                  <div className="dhp-govde">
                    {liste.map(z => (
                      <div key={z.id}
                           className={`dhp-kart${z.durum === 1 ? ' yapildi' : ''}${z.oneri === 1 ? ' oneri' : ''}${gecikenMi(z) ? ' gecik' : ''}`}
                           draggable={z.durum === 0}
                           onDragStart={() => setSurukle(z)} onDragEnd={() => { setSurukle(null); setHedef(null) }}
                           onDoubleClick={() => git(`/dis-hekim-ziyaret/${z.id}`)}
                           title={z.notu}>
                        <b>{saat(z.tarih)} {z.hekim_ad}</b>{z.hekim_ilce ? ` · ${z.hekim_ilce}` : ''}
                        <div className="s">{z.durum === 1 ? `${z.tur_ad} · ${z.sonuc_ad}` : z.oneri === 1 ? z.notu : z.amac_ad}{z.acik_talep > 0 ? ` · ${z.acik_talep} ${cev('açık talep')}` : ''}</div>
                        {z.durum === 0 && (
                          <div className="d">
                            {z.oneri === 1 && <button className="d" title={cev('Öneriyi plana al')} onClick={e => { e.stopPropagation(); void onayla(z) }}>✓</button>}
                            <button className="d" title={cev('Ziyaret kartı (yapıldı olarak kaydet)')} onClick={e => { e.stopPropagation(); git(`/dis-hekim-ziyaret/${z.id}`) }}>📝</button>
                            <button className="d" title={z.oneri === 1 ? cev('Öneriyi kaldır') : cev('Planı iptal et')} onClick={e => { e.stopPropagation(); void iptal(z) }}>✖</button>
                          </div>
                        )}
                      </div>
                    ))}
                    {liste.length === 0 && <div className="dhp-bos">{cev('sürükle-bırak ile ziyaret taşı')}</div>}
                  </div>
                </div>
              );
            })}
          </div>
          </>)}

          {/* GÜNÜN İŞİ */}
          {mod === 'liste' && (
            <div className="dhp-gunsekme">
              {GUNLER.map((_, i) => <button key={i} type="button" className={`d${seciliGun === i ? ' on' : ''}`} onClick={() => setSeciliGun(i)}>{gunAdi(i)}<small>{gunSayisi(i)}</small></button>)}
              <button type="button" className={`d${seciliGun === 'hafta' ? ' on' : ''}`} style={{ borderStyle: 'dashed' }} onClick={() => setSeciliGun('hafta')}>{cev('Bu hafta')}<small>{ziyaretler.length}</small></button>
            </div>
          )}
          {mod !== 'takvim' && (<>
          <div className={`dhp-gunbas${mod === 'liste' ? ' ustsuz' : ''}`}>
            <h4>{cev('Günün işi')} — {seciliGun === 'hafta' ? cev('bu hafta') : gunTarihi(seciliGun).toLocaleDateString('tr-TR', { weekday: 'long', day: '2-digit', month: '2-digit', year: 'numeric' })}</h4>
            <span className="dhp-gunbas-tag">{cev('takvimde gün başlığına tıkla')}</span>
            <span className="dhp-gunbas-sag">{gunSatirlari.length} {cev('ziyaret')} · {gunSatirlari.filter(z => z.durum === 1).length} {cev('yapıldı')} · {gunSatirlari.filter(gecikenMi).length} {cev('geciken')} · {gunSatirlari.reduce((t, z) => t + z.acik_talep, 0)} {cev('açık talep')}</span>
          </div>
          <div className="dhp-cipler gunun">
            {([['tum', 'Tümü'], ['geciken', 'Geciken'], ['dusen', `${S.gonderimi} düşen`], ['talepli', 'Talebi açık'], ['oneri', 'Öneri']] as [Cip, string][]).map(([k, ad]) => (
              <span key={k} className={`dhp-cip${cip === k ? ' on' : ''}`} onClick={() => setCip(k)}>{cev(ad)}</span>
            ))}
            <span className={`dhp-cip${seciliGun === 'hafta' ? ' on' : ''}`} onClick={() => setSeciliGun(s => s === 'hafta' ? hedefGunIdx : 'hafta')}>{cev('Bu hafta')}</span>
            <input placeholder={cev(erp ? 'müşteri / ilçe…' : 'hekim / kurum / ilçe…')} value={ara} onChange={e => setAra(e.target.value)} />
          </div>
          <div className="dhp-tablo">
            <table>
              <thead><tr>
                <th className="orta">{cev('Saat')}</th>{seciliGun === 'hafta' && <th>{cev('Gün')}</th>}<th>{cev(S.hedef)}</th><th>{cev('Kurum · İlçe')}</th>
                <th className="orta">{cev('Tür')}</th><th className="orta">{cev('Son ziyaret')}</th><th className="orta">{cev('Sıklık')}</th>
                <th className="orta">{cev(S.ist)}</th><th>{cev('Konu / Açık talep')}</th><th className="orta">{cev('Durum')}</th><th></th>
              </tr></thead>
              <tbody>
                {gunSatirlari.map(z => (
                  <tr key={z.id} className={`ac${gecikenMi(z) ? ' gecik' : ''}${z.durum === 1 ? ' yapildi' : ''}`} onDoubleClick={() => git(`/dis-hekim-ziyaret/${z.id}`)} title={cev('Çift tık: ziyaret kartı')}>
                    <td className="orta">{saat(z.tarih)}</td>
                    {seciliGun === 'hafta' && <td>{new Date(z.tarih).toLocaleDateString('tr-TR', { weekday: 'short', day: '2-digit', month: '2-digit' })}</td>}
                    <td>{z.hekim_ad}</td>
                    <td>{[z.hekim_kurum, z.hekim_ilce].filter(Boolean).join(' · ') || '—'}</td>
                    <td className="orta"><span className="rozet">{z.oneri === 1 ? cev('Öneri') : z.tur_ad}</span></td>
                    <td className="orta">{tarihYaz(z.son_ziyaret)}</td>
                    <td className="orta">{z.siklik_hafta > 0 ? `${z.siklik_hafta} ${cev('hafta')}` : '—'}</td>
                    <td className="orta">{z.son30_istem}{z.gonderim_dusen === 1 && <span className="rozet hata" style={{ marginLeft: 4 }}>↓</span>}</td>
                    <td className="sar">{z.durum === 1 ? `${z.sonuc_ad}${z.notu ? ' · ' + z.notu.slice(0, 80) : ''}` : z.oneri === 1 ? z.notu : z.amac_ad}{z.acik_talep > 0 ? ` · ${z.acik_talep} ${cev('açık talep')}` : ''}</td>
                    <td className="orta">{z.durum === 1 ? <span className="rozet olumlu">{cev('Yapıldı')}</span> : gecikenMi(z) ? <span className="rozet hata">{cev('Gecikti')}</span> : <span className="rozet mavi">{cev('Planlı')}</span>}</td>
                    <td><span className="dhp-tablo-d">
                      <button className="d" title={cev('Ziyaret kartı')} onClick={() => git(`/dis-hekim-ziyaret/${z.id}`)}>📝</button>
                      <button className="d" title={cev(erp ? 'Müşteri kartı' : 'Dış doktor kartı')} onClick={() => git(`${S.kart}/${z.hekim_id}`)}>{erp ? '👤' : '🩺'}</button>
                      {z.durum === 0 && z.oneri === 1 && <button className="d" title={cev('Öneriyi plana al')} onClick={() => void onayla(z)}>✓</button>}
                      {z.durum === 0 && <button className="d" title={cev('Planı iptal et')} onClick={() => void iptal(z)}>✖</button>}
                    </span></td>
                  </tr>
                ))}
                {gunSatirlari.length === 0 && <tr><td colSpan={11} className="dhp-bos2">{cev('Bu günde kayıt yok.')}</td></tr>}
              </tbody>
            </table>
          </div>
          </>)}
        </div>

        {/* SIRASI GELENLER ÇEKMECESİ (mockup v2) */}
        {cekmece && (
          <div className="dhp-cek" data-testid="plan-cek">
            <h4>⏰ {cev('Sırası gelenler')} <span className="rozet hata">{cekSatirlari.length}</span><button className="d" onClick={() => setCekmece(false)}>✖</button></h4>
            <div className="dhp-cek-ust">
              <span>{cev('İlçe')}:</span>
              {ilceler.map(([i, n]) => <span key={i} className={`dhp-cip${ilce === i ? ' on' : ''}`} onClick={() => setIlce(x => x === i ? '' : i)}>{i} <small>{n}</small></span>)}
              {ilceler.length === 0 && <span>—</span>}
              <span style={{ width: '100%' }}>{cev('Ölçüt')}:</span>
              {([['geciken', 'Geciken'], ['buhafta', 'Sırası bu hafta'], ['dusen', `${S.gonderimi} düşen`], ['talepli', 'Talebi açık'], ['yeni', 'Yeni']] as [Olcut, string][]).map(([k, ad]) => (
                <span key={k} className={`dhp-cip${olcutler.has(k) ? ' on' : ''}`} onClick={() => olcutDegis(k)}>{cev(ad)}</span>
              ))}
              <input placeholder={cev(erp ? 'müşteri…' : 'hekim / kurum…')} value={cekAra} onChange={e => setCekAra(e.target.value)} />
            </div>
            <div className="dhp-cek-liste">
              {ilceGruplari.map(([i, satirlar]) => (
                <div key={i}>
                  <div className="dhp-ilce"><b>{i}</b> · {satirlar.length} {S.hedefK} · {satirlar.filter(h => h.gecikme_gun > 0).length} {cev('geciken')}
                    <button className="d" title={cev('İlçenin tümünü seçili güne saat sırasıyla ekle')} onClick={() => void topluPlanla(satirlar.map(h => h.hekim_id), ekleGunIdx, ekleSaati)}>⤵ {cev('güne dağıt')}</button>
                  </div>
                  {satirlar.map(h => (
                    <div key={h.hekim_id} className={`dhp-vs${secili.has(h.hekim_id) ? ' sec' : ''}`} draggable
                         onDragStart={() => setSurukleHedef(h)} onDragEnd={() => { setSurukleHedef(null); setHedef(null) }}
                         onDoubleClick={() => git(`${S.kart}/${h.hekim_id}`)} title={cev(erp ? 'Çift tık: müşteri kartı · güne sürükle' : 'Çift tık: dış doktor kartı · güne sürükle')}>
                      <input type="checkbox" checked={secili.has(h.hekim_id)} onChange={() => secDegis(h.hekim_id)} />
                      <div className="dhp-vs-ic"><b>{h.hekim_ad}</b>{h.hekim_kurum ? ` · ${h.hekim_kurum}` : ''}
                        <div className="dhp-vs-not">{cev('son')} {tarihYaz(h.son_ziyaret)} · {h.siklik_hafta > 0 ? `${h.siklik_hafta} ${cev('hf')}` : cev('sıklık yok')}
                          {h.acik_talep > 0 ? ` · ${cev('açık talep')} ${h.acik_talep}` : ''}{h.gonderim_dusen === 1 ? ` · ${S.gonderimK} ↓` : ''}
                          {h.tercih_gun ? ` · ${cev('tercih')} ${GUNLER[h.tercih_gun - 1] ?? h.tercih_gun} ${h.tercih_saat ?? ''}` : ''}</div>
                      </div>
                      <span className={`dhp-vs-gk${h.gecikme_gun > 0 ? '' : ' sari'}`}>{h.gecikme_gun > 0 ? `+${h.gecikme_gun} g` : h.yeni_hekim === 1 && !h.vade_tarihi ? cev('yeni') : cev('bu hafta')}</span>
                    </div>
                  ))}
                </div>
              ))}
              {cekSatirlari.length === 0 && <div className="dhp-bos2">{cev('Bu ölçütte sırası gelen kayıt yok.')}</div>}
            </div>
            <div className="dhp-cek-alt">
              <div className="dhp-cek-satir"><span>{cev('Seçili')} <b>{secili.size}</b> →</span>
                <select value={ekleGunIdx} onChange={e => setEkleGunu(Number(e.target.value))}>{GUNLER.map((_, i) => <option key={i} value={i}>{gunAdi(i)}</option>)}</select>
                <input type="time" value={ekleSaati} onChange={e => setEkleSaati(e.target.value)} title={cev('Boş: gündeki son ziyaretten + 90 dk')} style={{ width: 90 }} />
              </div>
              <div className="dhp-cek-satir">
                <button className="d bir" style={{ flex: 1, justifyContent: 'center' }} disabled={secili.size === 0} onClick={() => void topluPlanla([...secili], ekleGunIdx, ekleSaati)} data-testid="plan-toplu">📅 {cev('Seçilenleri plana ekle')} ({secili.size})</button>
                <button className="d" disabled={secili.size === 0} title={cev('Seçilenleri haftaya sıklık / ilçeye göre dağıt (Planı Üret)')} onClick={() => void uret([...secili])}>⚙ {cev('Haftaya dağıt')}</button>
              </div>
              <div style={{ color: 'var(--soluk)', fontSize: 10.5 }}>{cev('ya da satırı tutup takvimde güne bırak; saat gündeki son ziyaretten +90 dk.')}</div>
            </div>
          </div>
        )}
        </div>
      </div>
      {ekleGun !== null && (
        <Modal baslik={`${cev('Plana Ekle')} — ${GUNLER[ekleGun]} ${gunTarihi(ekleGun).toLocaleDateString('tr-TR')}`} onKapat={() => setEkleGun(null)} enUst dar
          alt={<>
            <button className="d bir" disabled={!ekleHekim} onClick={ekle}>📅 {cev('Planla')}</button>
            <button className="d kapat-dugmesi" onClick={() => setEkleGun(null)}>✖ {cev('Vazgeç')}</button>
          </>}>
          <div className="alan-izgara" data-testid="plan-ekle">
            <GenLookup kaynak="saha-hedef" etiket={cev(S.hedef)} zorunlu
                       alanlar={[{ ad: 'unvan', baslik: S.hedef, genis: true }, { ad: 'kurum', baslik: 'Kurum' }, { ad: 'ilce', baslik: 'İlçe' }]}
                       deger={ekleHekim?.ad}
                       onSec={x => setEkleHekim(x ? { id: Number(x.id), ad: String(x.unvan ?? '') } : null)} />
            <label className="alan">
              <span className="etiket">{cev('Saat')}</span>
              <input type="time" value={ekleSaat} onChange={e => setEkleSaat(e.target.value)} />
            </label>
          </div>
          <div className="not" style={{ marginTop: 8 }}>{cev('Planlı ziyaret temsilciye yazılır; yapılınca karttan "Yapıldı" olarak kaydedilir.')}</div>
        </Modal>
      )}
    </div>
  );
}
