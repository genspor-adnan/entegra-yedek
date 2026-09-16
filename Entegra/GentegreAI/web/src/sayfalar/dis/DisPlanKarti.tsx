import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { DisIslemSecenegi, DisPlanKartVerisi as Veri, DisPlanSatiri } from '../../api/uclar/dis';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { TarafSecici } from '../../bilesenler/TarafArama';
import { para, tarihSaat, tarihYaz } from '../../bilesenler/bicim';

/**
 * TEDAVİ PLANI KARTI (710) — mockup `Ekranlar/Dis Klinigi/dis_tedavi_plani_karti.html`.
 *
 * Plan = iş birimi: satırlar diş + yüzey + hizmet + hekim + seans + fiyat +
 * lab bağı; fazlar klinik öncelik. Yaşam döngüsü taslak → sunuldu (proforma)
 * → onaylı (hasta imzası; fiyat kilitlenir) → sürüyor (seanslarla) →
 * tamamlandı. Ücret plan satırında değil seans/yapıldı anında doğar;
 * bakiye = yapılan − tahsil. Alternatif B ayrı plan kaydı (ana_plan_id).
 *
 * Modal: arkada Tedavi Planları listesi; Esc / Kapat geldiği yere döner
 * (prensip: ekran nereden açıldıysa oraya). Buradan açılan ekranlar da
 * geri buraya döner (state.geri / ?geri=).
 */
const DURUM: Record<number, [string, string]> = { 1: ['Taslak', 'gri'], 2: ['Sunuldu', 'mavi'], 3: ['Onaylı', 'ok'], 4: ['Sürüyor', 'mavi'], 5: ['Tamamlandı', 'ok'], 6: ['İptal', 'hata'], 7: ['Süresi doldu', 'uyari'] };
const SATIR: Record<number, [string, string]> = { 1: ['Planlı', 'gri'], 2: ['Sürüyor', 'mavi'], 3: ['Yapıldı', 'ok'], 4: ['İptal', 'hata'], 5: ['Ertelendi', 'uyari'] };
const KURAL: Record<number, string> = { 1: 'Tamamlanınca', 2: 'Seans başına oran', 3: 'Adet' };
const LAB_ASAMA: Record<number, [string, string]> = { 1: ['Ölçü bekliyor', 'gri'], 2: ['Gönderildi', 'mavi'], 3: ['Tasarım onayı', 'mor'], 4: ['Üretim', 'mavi'], 5: ['Geldi', 'uyari'], 6: ['Prova', 'uyari'], 7: ['Geri gönderildi', 'hata'], 8: ['Teslim edildi', 'ok'], 9: ['İptal', 'gri'] };
const LAB_TUR: Record<number, string> = { 1: 'Kron', 2: 'Köprü', 3: 'İmplant üstü', 4: 'Total protez', 5: 'Parsiyel protez', 6: 'Ortodonti apareyi', 7: 'Gece plağı', 8: 'Diğer' };
const SEANS_DURUM: Record<number, [string, string]> = { 1: ['Açık', 'mavi'], 2: ['Bitti', 'ok'], 3: ['İptal', 'hata'] };
const LOG_TIP: Record<number, string> = { 0: 'sildi', 1: 'ekledi', 2: 'değiştirdi' };
const LOG_TABLO: Record<number, string> = { 1130: 'plan', 1131: 'plan satırı', 1138: 'ödeme planı' };
type Sekme = 'satir' | 'seans' | 'proforma' | 'odeme' | 'lab' | 'varyant' | 'gunluk';
type Suzgec = 'tumu' | 'bekleyen' | 'yapilan' | 'lab';

const d10 = (t: string | null | undefined) => (t ? String(t).slice(0, 10) : '');

export function DisPlanKarti() {
  const { id: param } = useParams();
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const durum = konum.state as { geri?: string; ustGeri?: string } | null;
  const geri = durum?.geri ?? sorgu.get('geri') ?? '/dis-plan';
  const ustGeri = durum?.ustGeri;
  const kapat = useCallback(() => git(geri, ustGeri ? { state: { geri: ustGeri } } : undefined), [git, geri, ustGeri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);

  const yeni = param === 'yeni';
  const id = yeni ? 0 : Number(param ?? 0);
  const [v, setV] = useState<Veri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('satir');
  const [suzgec, setSuzgec] = useState<Suzgec>('tumu');
  const [secili, setSecili] = useState<number | null>(null);
  const [taslak, setTaslak] = useState<Record<string, string>>({});
  const [kirli, setKirli] = useState(false);
  const [islemAra, setIslemAra] = useState<{ acik: boolean; q: string; sonuc: DisIslemSecenegi[]; disNo: string; yz: string; iskonto: string; seans: string; faz: string }>(
    { acik: false, q: '', sonuc: [], disNo: '', yz: '', iskonto: '0', seans: '', faz: '1' });
  const [odemeForm, setOdemeForm] = useState({ pesinat: '', taksit: '1', ilkVade: '', yontem: '1' });
  const [yeniHasta, setYeniHasta] = useState<{ id: number; ad: string } | null>(null);

  const yukle = useCallback(async () => {
    if (!id) return;
    try {
      const k = await api.disPlanKart(id);
      setV(k); setHata(null);
      setTaslak({
        hekimId: k.plan.hekimId ? String(k.plan.hekimId) : '', fiyatListesiId: k.plan.fiyatListesiId ? String(k.plan.fiyatListesiId) : '',
        odeyenKurumId: k.plan.odeyenKurumId ? String(k.plan.odeyenKurumId) : '', odemeSecenegi: k.plan.odemeSecenegi,
        taksitSayisi: String(k.plan.taksitSayisi || ''), gecerlilikBitis: d10(k.plan.gecerlilikBitis), aciklama: k.plan.aciklama,
      });
      setKirli(false);
      setOdemeForm(f => ({ ...f, taksit: String(k.plan.taksitSayisi || 1) }));
    } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { void yukle() }, [yukle]);

  const p = v?.plan;
  const acik = !!p && p.durum <= 4;
  const yazar = yetki('dis.plan') && acik;
  const sec = useMemo(() => v?.satirlar.find(s => s.id === secili) ?? null, [v, secili]);
  const geriBurasi = konum.pathname;
  const geriParam = encodeURIComponent(geriBurasi);

  const satirlar = useMemo(() => {
    const s = v?.satirlar ?? [];
    if (suzgec === 'bekleyen') return s.filter(x => x.durum === 1 || x.durum === 2 || x.durum === 5);
    if (suzgec === 'yapilan') return s.filter(x => x.durum === 3);
    if (suzgec === 'lab') return s.filter(x => x.labGerekir);
    return s;
  }, [v, suzgec]);
  const fazlar = useMemo(() => {
    const m = new Map<number, DisPlanSatiri[]>();
    satirlar.forEach(s => { const l = m.get(s.faz) ?? []; l.push(s); m.set(s.faz, l) });
    return [...m.entries()].sort((a, b) => a[0] - b[0]);
  }, [satirlar]);

  // ---- yazma
  const ayarla = (ad: string, deger: string) => { setTaslak(t => ({ ...t, [ad]: deger })); setKirli(true) };
  const kaydet = async () => {
    if (!p) return;
    await guvenli(async () => {
      await api.disPlanGuncelle(p.id, {
        hekimId: taslak.hekimId ? Number(taslak.hekimId) : null,
        fiyatListesiId: p.durum < 3 && taslak.fiyatListesiId ? Number(taslak.fiyatListesiId) : null,
        odeyenKurumId: taslak.odeyenKurumId ? Number(taslak.odeyenKurumId) : null,
        odeyenKurumTemizle: !taslak.odeyenKurumId && !!p.odeyenKurumId,
        odemeSecenegi: taslak.odemeSecenegi, taksitSayisi: taslak.taksitSayisi ? Number(taslak.taksitSayisi) : null,
        gecerlilikBitis: taslak.gecerlilikBitis || null, aciklama: taslak.aciklama,
      });
      mesaj('Kaydedildi.'); await yukle();
    });
  };
  const sun = async () => { if (!p) return; await guvenli(async () => { await api.disPlanSun(p.id); mesaj('Plan hastaya sunuldu (proforma).'); await yukle() }) };
  const onayla = async () => {
    if (!p) return;
    if (!await onay('Hasta onayı alındı mı? Onaylı satır fiyatı değişmez.')) return;
    await guvenli(async () => { await api.disPlanOnayla(p.id); mesaj('Plan onaylandı.'); await yukle() });
  };
  const iptal = async () => {
    if (!p) return;
    if (!await onay('Plan iptal edilsin mi? Yapılmış işlemler kalır (ücreti doğmuş), bekleyen satırlar iptal olur.')) return;
    await guvenli(async () => { const y = await api.disPlanIptal(p.id); mesaj(`Plan iptal edildi · ${y.iptalSatir} satır iptal.`); await yukle() });
  };
  const alternatif = async () => {
    if (!p) return;
    if (!await onay('Alternatif plan açılsın mı? Satırlar kopyalanır, yeni varyantta düzenlersiniz; hasta birini seçince öteki iptal olur.')) return;
    await guvenli(async () => { const y = await api.disPlanAlternatif(p.id); mesaj(`Alternatif ${y.varyant} açıldı: ${y.planNo}`); git(`/dis-plan/${y.id}`, { state: { geri } }) });
  };
  const anaYap = async (vid: number, ad: string) => {
    if (!await onay(`${ad} ana plan yapılsın mı? Diğer varyantlar "iptal (seçilmedi)" olur.`)) return;
    await guvenli(async () => { await api.disPlanAnaYap(vid); mesaj('Ana plan değişti.'); git(`/dis-plan/${vid}`, { state: { geri } }) });
  };
  const seansAc = async () => {
    if (!p) return;
    await guvenli(async () => {
      const y = await api.disSeansAc({ hastaId: p.hastaId, planId: p.id, hekimId: p.hekimId, planSatirId: sec?.id ?? null });
      if (y.basvuruAcildi) mesaj(`Başvuru ${y.basvuruNo} açıldı (ödeyen: ${y.odeyen}).`);
      git(`/dis-seans/${y.id}`, { state: { geri: geriBurasi, ustGeri: geri } });
    });
  };
  const odemePlaniUret = async () => {
    if (!p) return;
    await guvenli(async () => {
      const y = await api.disOdemePlaniUret(p.id, {
        pesinat: Number(odemeForm.pesinat.replace(',', '.')) || 0, taksitSayisi: Number(odemeForm.taksit) || 1,
        ilkVade: odemeForm.ilkVade || undefined, odemeYontemi: Number(odemeForm.yontem) || 1,
      });
      mesaj(`Ödeme planı üretildi · ${y.taksit} taksit × ${para.format(y.taksitTutar)}${y.pesinat ? ` · peşinat ${para.format(y.pesinat)}` : ''}`);
      await yukle();
    });
  };
  const islemAraYap = async (q: string) => {
    setIslemAra(a => ({ ...a, q }));
    try { const y = await api.disIslemAra(q, p?.fiyatListesiId); setIslemAra(a => ({ ...a, sonuc: y.satirlar })) } catch { /* sessiz */ }
  };
  const satirEkle = async (h: DisIslemSecenegi) => {
    if (!p) return;
    await guvenli(async () => {
      await api.disPlanSatirEkle(p.hastaId, {
        planId: p.id, disNo: Number(islemAra.disNo) || 0, yuzeyler: islemAra.yz, hizmetId: h.id,
        iskonto: Number(islemAra.iskonto.replace(',', '.')) || 0, seansSayisi: Number(islemAra.seans) || undefined,
        faz: Number(islemAra.faz) || 1, hekimId: p.hekimId,
      });
      setIslemAra(a => ({ ...a, acik: false, q: '', sonuc: [] }));
      await yukle();
    });
  };
  const yapildi = async (s: DisPlanSatiri) => {
    if (!await onay(`${s.disNo ? `Diş ${s.disNo} · ` : ''}${s.islem} yapıldı olarak işaretlensin mi? Başvuruya ücret satırı düşer.`)) return;
    await guvenli(async () => { const y = await api.disPlanSatirYapildi(s.id); mesaj((y.ucret > 0 ? `Ücret satırı yazıldı: ${para.format(y.ucret)}. ` : '') + (y.uyari ?? '')); await yukle() });
  };
  const satirIptal = async (s: DisPlanSatiri) => {
    if (!await onay(`${s.islem} satırı iptal edilsin mi?`)) return;
    await guvenli(async () => { await api.disPlanSatirIptal(s.id); await yukle() });
  };
  const labIsemriAc = (s: DisPlanSatiri | null) => {
    if (!p) return;
    git(`/dis-lab-isemri/yeni?hastaId=${p.hastaId}&hastaAd=${encodeURIComponent(p.hasta)}${p.hekimId ? `&hekimId=${p.hekimId}` : ''}`
      + (s ? `&planSatirId=${s.id}&disNolar=${s.disNo || s.disNolar}` : '') + `&geri=${geriParam}`);
  };
  const yeniPlan = async () => {
    if (!yeniHasta) { mesaj('Hasta seçin.'); return }
    await guvenli(async () => { const y = await api.disPlanAc({ hastaId: yeniHasta.id }); mesaj(`Plan açıldı: ${y.planNo}`); git(`/dis-plan/${y.id}`, { state: { geri } }) });
  };

  const Perde = ({ children, baslik }: { children: ReactNode; baslik: ReactNode }) => (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">{baslik}<span className="kapt">Esc ile kapanır</span><button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov ds-kagov">{children}</div>
      </div>
    </div>
  );

  if (yeni) return (
    <Perde baslik={<span>📋 Yeni Tedavi Planı</span>}>
      <div className="ds-hdr" style={{ padding: 12 }}>
        <div><label>Hasta</label><TarafSecici etiket="" deger={yeniHasta?.ad ?? ''} kaynaklar={['hasta']} bosMetin="Hasta seçin…" onSec={h => setYeniHasta({ id: h.id, ad: h.unvan })} onTemizle={() => setYeniHasta(null)} /></div>
        <div><label>&nbsp;</label><button className="d bir" onClick={() => void yeniPlan()}>📋 Taslak Plan Aç</button></div>
      </div>
      <div className="ds-ic sonuk">Boş taslak açılır; satırlar bu karttan ("＋ İşlem") ya da hasta kartındaki odontogramdan eklenir. Fiyat listesi hastanın kurum sözleşmesinden, yoksa varsayılandan gelir.</div>
    </Perde>
  );
  if (hata) return <Perde baslik={<span>📋 Tedavi Planı</span>}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!v || !p) return <Perde baslik={<span>📋 Tedavi Planı</span>}><span className="sonuk">Yükleniyor…</span></Perde>;

  const oz = v.ozet;
  const bakiye = oz.yapilan - oz.tahsil;
  const durumRozet = DURUM[p.durum] ?? ['?', 'gri'];
  const adimlar: [string, boolean, boolean][] = [
    ['Taslak', p.durum >= 1, p.durum === 1],
    [`Sunuldu${p.proformaNo ? ` · ${p.proformaNo}` : ''}`, p.durum >= 2 && p.durum <= 5, p.durum === 2],
    [`Onaylı${p.hastaOnayZamani ? ` · ${tarihYaz(p.hastaOnayZamani)}` : ''}`, p.durum >= 3 && p.durum <= 5, p.durum === 3],
    [`Sürüyor · ${oz.yapilanSayisi} / ${oz.satirSayisi}`, p.durum >= 4 && p.durum <= 5, p.durum === 4],
    ['Tamamlandı', p.durum === 5, p.durum === 5],
  ];
  const gunKaldi = p.gecerlilikBitis ? Math.ceil((new Date(p.gecerlilikBitis).getTime() - Date.now()) / 86400000) : null;
  const odemePlani = v.odemePlani ?? null;
  const labGerekenAcik = v.satirlar.filter(s => s.labGerekir && !s.labIsemriId && s.durum !== 4);
  const labMaliyet = v.labIsleri.reduce((a, l) => a + (l.asama === 9 ? 0 : l.labFiyat), 0);
  const cins = p.cinsiyet === 1 ? 'E' : p.cinsiyet === 2 ? 'K' : '';

  // Varyant karşılaştırma: diş → { [planId]: satırlar }
  const disKarsilastirma = (() => {
    const m = new Map<number, Record<number, { islem: string; net: number }[]>>();
    const ekle = (planId: number, s: { disNo: number; islem: string; net: number }) => {
      const r = m.get(s.disNo) ?? {}; (r[planId] ??= []).push({ islem: s.islem, net: s.net }); m.set(s.disNo, r);
    };
    v.satirlar.filter(s => s.durum !== 4).forEach(s => ekle(p.id, s));
    v.varyantSatirlari.forEach(s => ekle(s.planId, s));
    return [...m.entries()].sort((a, b) => a[0] - b[0]);
  })();

  const proformaMetni = () => {
    const sat = (t: string, n: number) => (t.length > n ? t.slice(0, n - 1) + '…' : t).padEnd(n);
    const sag = (t: string, n: number) => t.padStart(n);
    const satirlarM = v.satirlar.filter(s => s.durum !== 4).map(s =>
      `${sat(s.disNo ? String(s.disNo) : '--', 5)}${sat(s.islem, 34)}${sag(String(s.seansSayisi), 4)}${sag(para.format(s.listeFiyat), 12)}${sag(s.iskonto ? '-' + para.format(s.iskonto) : '-', 10)}${sag(para.format(s.net), 12)}`).join('\n');
    return `TEDAVİ PLANI / PROFORMA\nHasta: ${p.hasta}${p.tckn ? ' · ' + p.tckn : ''}    Hekim: ${p.hekim || '—'}    Tarih: ${tarihYaz(p.eklemeTarihi)}\nPlan: ${p.planNo} (${p.varyant})    Proforma: ${p.proformaNo || '—'}    Geçerlilik: ${p.gecerlilikBitis ? tarihYaz(p.gecerlilikBitis) : '—'}\n${'-'.repeat(77)}\n${sat('Diş', 5)}${sat('İşlem', 34)}${sag('Sns', 4)}${sag('Liste', 12)}${sag('İnd.', 10)}${sag('Net', 12)}\n${satirlarM}\n${'-'.repeat(77)}\n${sag('TOPLAM', 43)}${sag(para.format(p.toplam), 12)}${sag('-' + para.format(p.indirim), 10)}${sag(para.format(p.net), 12)}\nÖdeme: ${p.odemeSecenegi || (p.taksitSayisi > 1 ? `${p.taksitSayisi} taksit` : 'peşin')}\nFiyatlar seans/işlem anında ücretlendirilir; onaylı fiyat değişmez.\nHasta imzası: ____________${p.hastaOnayZamani ? `   (${p.onayYontemi} · ${tarihSaat(p.hastaOnayZamani)})` : ''}`;
  };

  return (
    <Perde baslik={<>
      <span>📋 Tedavi Planı — {p.planNo} · {p.hasta}{p.yas != null ? ` · ${p.yas} ${cins}` : ''}</span>
      <span className="ds-kabas-yol">varyant {p.varyant}{p.anaPlanNo ? ` (ana ${p.anaPlanNo})` : ''} · {oz.yapilanSayisi}/{oz.satirSayisi} işlem · {p.hekim || 'hekim —'} · Diş › Tedavi Planları</span>
      <span className={`rozet ${durumRozet[1]}`}>{durumRozet[0]}</span>
    </>}>
      <div className="ds-arac ds-kart-arac">
        {yazar && <button className="d bir" disabled={!kirli} onClick={() => void kaydet()}>💾 Kaydet</button>}
        {yazar && p.durum === 1 && <button className="d" onClick={() => void sun()}>📤 Hastaya Sun (proforma)</button>}
        {yazar && (p.durum === 1 || p.durum === 2) && <button className="d onay" onClick={() => void onayla()}>✍ Hasta Onayı</button>}
        {yazar && !p.anaPlanId && <button className="d" onClick={() => void alternatif()}>🔁 Alternatif Plan</button>}
        <span className="ds-sep" />
        {yazar && yetki('dis.seans') && <button className="d" title={sec ? `Seçili satırla (${sec.islem}) seans aç` : 'Bu plana seans aç'} onClick={() => void seansAc()}>🪑 Seans Aç{sec ? ` (#${sec.sira})` : ''}</button>}
        {oz.odemePlaniId
          ? <button className="d" onClick={() => git(`/dis-odeme-plani/${oz.odemePlaniId}?geri=${geriParam}`)}>💳 Ödeme Planı</button>
          : yazar && yetki('dis.odeme') && <button className="d" onClick={() => setSekme('odeme')}>💳 Ödeme Planı Üret</button>}
        {yazar && <button className="d" title={sec?.labGerekir ? `Seçili satır için (${sec.disNo}) lab iş emri` : 'Bu hasta adına lab iş emri'} onClick={() => labIsemriAc(sec?.labGerekir ? sec : null)}>🧪 Lab İş Emri{sec?.labGerekir && !sec.labIsemriId ? ` (${sec.disNo})` : ''}</button>}
        <button className="d" onClick={() => { setSekme('proforma'); setTimeout(() => window.print(), 50) }}>🖨 Proforma</button>
        <span className="ds-sep" />
        <button className="d" onClick={() => git(`/dis-hasta/${p.hastaId}`, { state: { geri: geriBurasi, ustGeri: geri } })}>🦷 Hasta Kartı (odontogram)</button>
        {yazar && <button className="d teh" onClick={() => void iptal()}>✖ Planı İptal Et</button>}
        <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        <button className="d ds-sp" onClick={kapat}>✖ Kapat</button>
      </div>

      <div className="ds-adim">
        {adimlar.map(([ad, gecti, simdi]) => <span key={ad} className={simdi ? 'on' : gecti ? 'ok' : ''}>{ad}</span>)}
        {p.durum >= 6 && <span className="on hata">{durumRozet[0]}</span>}
      </div>

      <div className="ds-hdr ds-hdr5" style={{ padding: '4px 10px 8px' }}>
        <div><label>Hasta *</label><div className="ds-inp big">{p.hasta}{p.tckn ? <span className="sonuk">· {p.tckn}</span> : null}{p.alerji && p.alerji.split(', ').map(a => <span key={a} className="rozet hata">{a}</span>)}</div></div>
        <div><label>Hekim *</label>
          <select value={taslak.hekimId ?? ''} disabled={!yazar} onChange={e => ayarla('hekimId', e.target.value)} style={{ width: '100%' }}>
            <option value="">— seçiniz —</option>{v.secenekler.hekimler.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
          </select></div>
        <div><label>Muayene</label><div className="ds-inp">{p.muayeneId ? <a href={`/muayene/${p.muayeneId}`} onClick={e => { e.preventDefault(); git(`/muayene/${p.muayeneId}?geri=${geriParam}`) }}>#{p.muayeneId} · {p.muayeneTarih ? tarihYaz(p.muayeneTarih) : ''}</a> : <span className="sonuk">—</span>}</div></div>
        <div><label>Varyant</label><div className="ds-inp">{p.varyant} — {p.anaPlanId ? `alternatif (ana ${p.anaPlanNo})` : 'ana plan'}{v.varyantlar.length > 0 && <span className="rozet mavi" style={{ cursor: 'pointer' }} onClick={() => setSekme('varyant')}>{v.varyantlar.map(x => x.varyant).join(', ')} var (karşılaştır)</span>}</div></div>
        <div><label>Durum</label><div className="ds-inp"><span className={`rozet ${durumRozet[1]}`}>{durumRozet[0]}{p.durum === 4 ? ` · ${oz.yapilanSayisi}/${oz.satirSayisi}` : ''}</span></div></div>
        <div><label>Fiyat listesi</label>
          <select value={taslak.fiyatListesiId ?? ''} disabled={!yazar || p.durum >= 3} title={p.durum >= 3 ? 'Onaylı planda fiyat listesi değişmez' : ''} onChange={e => ayarla('fiyatListesiId', e.target.value)} style={{ width: '100%' }}>
            <option value="">— varsayılan —</option>{v.secenekler.fiyatListeleri.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
          </select></div>
        <div><label>Ödeyen kurum</label>
          <select value={taslak.odeyenKurumId ?? ''} disabled={!yazar} onChange={e => ayarla('odeyenKurumId', e.target.value)} style={{ width: '100%' }}>
            <option value="">— (hasta öder)</option>{v.secenekler.kurumlar.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}
          </select></div>
        <div><label>Geçerlilik</label><div className="ds-inp" style={{ padding: 0, border: 'none', background: 'transparent' }}>
          <input type="date" value={taslak.gecerlilikBitis ?? ''} disabled={!yazar} onChange={e => ayarla('gecerlilikBitis', e.target.value)} />
          {gunKaldi != null && p.durum <= 2 && <span className={`rozet ${gunKaldi < 0 ? 'hata' : gunKaldi <= 7 ? 'uyari' : 'gri'}`}>{gunKaldi < 0 ? `${-gunKaldi} gün geçti` : `${gunKaldi} gün kaldı`}</span>}</div></div>
        <div><label>Ödeme seçeneği</label><input style={{ width: '100%' }} value={taslak.odemeSecenegi ?? ''} disabled={!yazar} placeholder="Peşinat 4.000 + 3 taksit" onChange={e => ayarla('odemeSecenegi', e.target.value)} /></div>
        <div><label>Önceki plan</label><div className="ds-inp">{p.oncekiPlan || <span className="sonuk">—</span>}</div></div>
      </div>

      <div className="ds-ozet6" style={{ gridTemplateColumns: 'repeat(7, 1fr)' }}>
        <div><span>Toplam</span><b>{para.format(p.toplam)}</b></div>
        <div><span>İndirim</span><b>−{para.format(p.indirim)}</b><i>{p.toplam ? `%${Math.round(p.indirim / p.toplam * 100)}` : ''}</i></div>
        <div><span>Net</span><b>{para.format(p.net)}</b></div>
        <div><span>Yapılan</span><b className="ds-ok">{para.format(oz.yapilan)}</b><i>{oz.yapilanSayisi} işlem</i><div className="ds-bar" style={{ margin: '3px 0 0' }}><i style={{ width: `${p.net ? Math.min(100, oz.yapilan / p.net * 100) : 0}%`, background: 'var(--ok)' }} /></div></div>
        <div><span>Tahsil</span><b>{para.format(oz.tahsil)}</b><i>{odemePlani ? (odemePlani.pesinat > oz.tahsil ? 'peşinat kısmi' : 'plana göre') : 'ödeme planı yok'}</i></div>
        <div><span>Bakiye (yapılan − tahsil)</span><b className={bakiye > 0 ? 'ds-kir' : ''}>{para.format(bakiye)}</b></div>
        <div><span>Lab</span><b>{oz.labSayisi}</b><i>{oz.labdaSayisi} labda · {oz.labBekleyen} açılmadı</i></div>
      </div>

      <div className="ka-sekmeler">
        {([['satir', `Plan Satırları (${v.satirlar.length})`], ['seans', `Seans Programı (${v.seanslar.length})`], ['proforma', 'Proforma & Onay'], ['odeme', 'Ödeme Planı'], ['lab', `Lab İşleri (${v.labIsleri.length})`], ['varyant', `Alternatif (${v.varyantlar.length})`], ['gunluk', `Günlük (${v.gunluk.length})`]] as [Sekme, string][])
          .map(([k, ad]) => <div key={k} className={`ka-sekme${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{ad}</div>)}
      </div>

      {sekme === 'satir' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-arac">
            {([['tumu', `Tümü (${v.satirlar.length})`], ['bekleyen', `Bekleyen (${v.satirlar.filter(s => s.durum === 1 || s.durum === 2 || s.durum === 5).length})`], ['yapilan', `Yapılan (${v.satirlar.filter(s => s.durum === 3).length})`], ['lab', `Lab gerektiren (${v.satirlar.filter(s => s.labGerekir).length})`]] as [Suzgec, string][])
              .map(([k, ad]) => <span key={k} className={`cip${suzgec === k ? ' on' : ''}`} onClick={() => setSuzgec(k)}>{ad}</span>)}
            <span className="ds-sp">
              {yazar && <button className="d bir" onClick={() => { setIslemAra(a => ({ ...a, acik: !a.acik })); if (!islemAra.acik) void islemAraYap('') }}>＋ İşlem (SUT / özel kod)</button>}
              <button className="d" onClick={() => git(`/dis-hasta/${p.hastaId}`, { state: { geri: geriBurasi, ustGeri: geri } })}>🦷 Odontogramda göster</button>
            </span>
          </div>
          {islemAra.acik && (
            <div className="ds-islem-ara">
              <div className="ds-arac"><b>Plan satırı ekle</b>
                <input autoFocus placeholder="İşlem ara (SUT / kod / ad)…" value={islemAra.q} onChange={e => void islemAraYap(e.target.value)} style={{ minWidth: 240 }} />
                <label className="sonuk">Diş <input value={islemAra.disNo} onChange={e => setIslemAra(a => ({ ...a, disNo: e.target.value }))} style={{ width: 46 }} /></label>
                <label className="sonuk">Yüzey <input value={islemAra.yz} onChange={e => setIslemAra(a => ({ ...a, yz: e.target.value }))} style={{ width: 56 }} placeholder="MOD" /></label>
                <label className="sonuk">Faz <input value={islemAra.faz} onChange={e => setIslemAra(a => ({ ...a, faz: e.target.value }))} style={{ width: 36 }} /></label>
                <label className="sonuk">İnd. <input value={islemAra.iskonto} onChange={e => setIslemAra(a => ({ ...a, iskonto: e.target.value }))} style={{ width: 60 }} /></label>
                <label className="sonuk">Seans <input value={islemAra.seans} onChange={e => setIslemAra(a => ({ ...a, seans: e.target.value }))} style={{ width: 36 }} placeholder="std" /></label>
                <button className="d" onClick={() => setIslemAra(a => ({ ...a, acik: false }))}>Kapat</button></div>
              <div className="ds-dg" style={{ maxHeight: 220, overflowY: 'auto' }}><table>
                <thead><tr><th>Kod</th><th>İşlem</th><th className="orta">Seans</th><th className="orta">Lab</th><th className="sag">Fiyat</th><th /></tr></thead>
                <tbody>{islemAra.sonuc.map(x => <tr key={x.id}><td className="sonuk">{x.kod}</td><td>{x.ad}</td><td className="orta">{x.standartSeans}</td><td className="orta">{x.labGerekir ? '🧪' : ''}</td><td className="sag">{para.format(x.fiyat)}</td>
                  <td><button className="d onay" onClick={() => void satirEkle(x)}>Ekle</button></td></tr>)}
                  {islemAra.sonuc.length === 0 && <tr><td colSpan={6} className="sonuk">Sonuç yok.</td></tr>}</tbody>
              </table></div>
            </div>
          )}
          <div className="ds-dg"><table className="ds-plan">
            <thead><tr><th className="orta">#</th><th className="orta">Diş</th><th className="orta">Yüzey</th><th>İşlem (SUT / kod)</th><th>Hekim</th><th className="orta">Seans</th><th className="sag">Liste</th><th className="sag">İnd.</th><th className="sag">Net</th><th>Ücretlendirme</th><th className="orta">Lab</th><th className="orta">Onam</th><th className="orta">Randevu</th><th>Durum</th><th /></tr></thead>
            <tbody>
              {fazlar.map(([faz, liste]) => (<>
                <tr key={`f${faz}`} className="grup"><td colSpan={15}>Faz {faz}{faz === 1 ? ' — Acil / ağrı giderme' : faz === 2 ? ' — Restoratif' : faz === 3 ? ' — Protetik' : ''} · {liste.length} satır</td></tr>
                {liste.map(s => {
                  const lab = v.labIsleri.find(l => l.id === s.labIsemriId);
                  const rnd = v.randevular.find(r => r.planSatirId === s.id);
                  return (
                    <tr key={s.id} className={`${secili === s.id ? 'dis-sec' : ''}${s.durum === 4 ? ' soluk' : ''}`} onClick={() => setSecili(s.id)}>
                      <td className="orta sonuk">{s.sira}</td>
                      <td className="orta"><b>{s.disNo || s.disNolar || '—'}</b></td>
                      <td className="orta">{s.yuzeyler || (s.disNo ? 'tüm' : '—')}</td>
                      <td>{secili === s.id ? '▸ ' : ''}{s.islem}</td>
                      <td>{s.hekim || <span className="sonuk">—</span>}</td>
                      <td className="orta">{s.yapilanSeans}/{s.seansSayisi}</td>
                      <td className="sag">{para.format(s.listeFiyat)}</td>
                      <td className="sag">{s.iskonto ? `−${para.format(s.iskonto)}` : '—'}</td>
                      <td className="sag">{para.format(s.net)}</td>
                      <td>{KURAL[s.ucretKurali] ?? ''}{s.labGerekir && s.ucretKurali === 1 ? ' (teslim)' : ''}</td>
                      <td className="orta">{lab ? <span className={`rozet ${LAB_ASAMA[lab.asama]?.[1] ?? 'gri'}`}>{lab.isemriNo} · {LAB_ASAMA[lab.asama]?.[0]}</span> : s.labGerekir ? <span className="rozet uyari">lab gerekir</span> : '—'}</td>
                      <td className="orta">{s.durum !== 4 && p.hastaOnayZamani ? <span className="rozet ok">✔</span> : '—'}</td>
                      <td className="orta">{rnd ? tarihSaat(rnd.baslangic) : s.randevu ? tarihSaat(s.randevu) : '—'}</td>
                      <td><span className={`rozet ${SATIR[s.durum]?.[1] ?? 'gri'}`}>{SATIR[s.durum]?.[0] ?? s.durum}{s.durum === 3 && s.tamamlanma ? ` · ${tarihYaz(s.tamamlanma)}` : ''}</span></td>
                      <td className="ds-satir-arac">
                        {yazar && s.durum < 3 && <button className="d" onClick={e => { e.stopPropagation(); void yapildi(s) }}>✔ Yapıldı</button>}
                        {yazar && s.labGerekir && !s.labIsemriId && s.durum < 3 && <button className="d" title="Lab iş emri aç" onClick={e => { e.stopPropagation(); labIsemriAc(s) }}>🧪</button>}
                        {yazar && s.durum < 3 && <button className="d" title="İptal" onClick={e => { e.stopPropagation(); void satirIptal(s) }}>✖</button>}
                      </td>
                    </tr>
                  );
                })}
              </>))}
              {satirlar.length === 0 && <tr><td colSpan={15} className="sonuk">Satır yok - "＋ İşlem" ile ekleyin ya da odontogramdan seçin.</td></tr>}
              {v.satirlar.length > 0 && <tr className="grup"><td colSpan={6}>TOPLAM · {v.satirlar.filter(s => s.durum !== 4).length} işlem · {fazlar.length} faz</td><td className="sag">{para.format(p.toplam)}</td><td className="sag">−{para.format(p.indirim)}</td><td className="sag">{para.format(p.net)}</td><td colSpan={6} /></tr>}
            </tbody>
          </table></div>
          <div className="ds-ic sonuk">{p.durum >= 3 ? <b>Onaylı planda satır fiyatı değişmez.</b> : <b>Taslak: fiyat listesi değişince satırlar yeniden fiyatlanmaz; satırı silip ekleyin.</b>} Silinen satır iptal olur, satır yok olmaz. Fazlar klinik önceliktir. Ücret satırda değil seans / "yapıldı" anında doğar (başvuru satırı).</div>
        </div>
      )}

      {sekme === 'seans' && (
        <div className="ds-odo-alan" style={{ gridTemplateColumns: 'minmax(0,1fr) 340px' }}>
          <div className="ds-sol">
            <div className="ds-grp ds-grp-ic">
              <div className="ds-gb">Seanslar <span className="ds-sp sonuk">plan satırı → seans · süre hizmet kartından</span></div>
              <div className="ds-dg"><table>
                <thead><tr><th className="orta">Seans</th><th>Tarih</th><th>Ünit / hekim</th><th className="orta">Süre</th><th>Plan satırları</th><th>Durum</th><th /></tr></thead>
                <tbody>
                  {v.seanslar.map((x, n) => <tr key={x.id}>
                    <td className="orta">{n + 1}</td><td>{tarihSaat(x.baslangic)}</td><td>{[x.unit, x.hekim].filter(Boolean).join(' · ') || '—'}</td>
                    <td className="orta">{x.bitis ? `${x.sureDk} dk` : <span className="sonuk">devam</span>}</td><td>{x.islemler || <span className="sonuk">işlem yok</span>}</td>
                    <td><span className={`rozet ${SEANS_DURUM[x.durum]?.[1] ?? 'gri'}`}>{SEANS_DURUM[x.durum]?.[0] ?? x.durum}</span></td>
                    <td><button className="d" onClick={() => git(`/dis-seans/${x.id}`, { state: { geri: geriBurasi, ustGeri: geri } })}>Aç</button></td></tr>)}
                  {v.randevular.map(r => { const s = v.satirlar.find(z => z.id === r.planSatirId); return <tr key={`r${r.id}`} className="soluk">
                    <td className="orta">—</td><td>{tarihSaat(r.baslangic)}</td><td>{[r.unit, r.hekim].filter(Boolean).join(' · ') || '—'}</td><td className="orta">{r.sureDk} dk</td>
                    <td>#{s?.sira} {s?.islem}</td><td><span className="rozet mavi">Randevulu</span></td>
                    <td><button className="d" onClick={() => git(`/randevu/${r.id}?geri=${geriParam}`)}>Randevu</button></td></tr> })}
                  {v.seanslar.length === 0 && v.randevular.length === 0 && <tr><td colSpan={7} className="sonuk">Seans yok. "🪑 Seans Aç" ile başlayın ya da Günlük Akış'tan randevuyla açın.</td></tr>}
                </tbody>
              </table></div>
              {yazar && yetki('dis.seans') && <div className="ds-arac"><button className="d bir" onClick={() => void seansAc()}>🪑 Seans aç{sec ? ` (#${sec.sira} ${sec.islem})` : ''}</button>
                <button className="d" onClick={() => git(`/randevu/yeni?hastaId=${p.hastaId}&geri=${geriParam}`)}>🗓 Randevu ver</button>
                <span className="ds-sp sonuk">Randevu = ünit + hekim + süre; <code>randevu.plan_satir_id</code>. Lab kısıtı: prova randevusu iş emrinin beklenen tarihinden önce verilmez.</span></div>}
            </div>
          </div>
          <div className="ds-sag">
            <div className="ds-grp"><div className="ds-gb">Kalan iş</div>
              <div className="ds-ic">
                {v.satirlar.filter(s => s.durum === 1 || s.durum === 2 || s.durum === 5).map(s => <div key={s.id}><span className="sonuk">#{s.sira}</span> {s.disNo || ''} {s.islem} · {s.seansSayisi - s.yapilanSeans} seans{s.labGerekir && !s.labIsemriId ? <span className="rozet uyari" style={{ marginLeft: 4 }}>lab iş emri açılmadı</span> : ''}</div>)}
                {v.satirlar.filter(s => s.durum === 1 || s.durum === 2 || s.durum === 5).length === 0 && <span className="sonuk">Bekleyen satır yok.</span>}
                <div style={{ marginTop: 6 }}><b>Toplam kalan:</b> {v.satirlar.filter(s => s.durum < 3 || s.durum === 5).reduce((a, s) => a + Math.max(0, s.seansSayisi - s.yapilanSeans), 0)} seans</div>
              </div>
            </div>
            <div className="ds-grp"><div className="ds-gb">Seans önerisi</div>
              <div className="ds-ic sonuk">Kural: aynı diş ardışık seanslarda, kanal → kron ölçüsü aynı seansa, kompozitler tek seansta, lab işleri beklenen tarihe göre. Otomatik öneri ve "kalan seansları randevuya dönüştür" sonraki sürümde; şimdilik Randevu ekranından.</div>
            </div>
          </div>
        </div>
      )}

      {sekme === 'proforma' && (
        <div className="ds-odo-alan" style={{ gridTemplateColumns: '1fr 1fr' }}>
          <div className="ds-sol">
            <div className="ds-grp ds-grp-ic"><div className="ds-gb">Proforma</div>
              <div className="ds-hdr" style={{ padding: '4px 10px 8px', gridTemplateColumns: '1fr 1fr' }}>
                <div><label>Proforma no</label><div className="ds-inp">{p.proformaNo || <span className="sonuk">sunulunca üretilir</span>}</div></div>
                <div><label>Sunum / onay</label><div className="ds-inp">{p.durum >= 2 ? `sunuldu · ${p.proformaNo}` : '—'}{p.hastaOnayZamani ? ` · onay ${tarihSaat(p.hastaOnayZamani)}` : ''}</div></div>
                <div><label>Geçerlilik</label><input type="date" value={taslak.gecerlilikBitis ?? ''} disabled={!yazar} onChange={e => ayarla('gecerlilikBitis', e.target.value)} /></div>
                <div><label>Toplam / indirim / net</label><div className="ds-inp">{para.format(p.toplam)} · −{para.format(p.indirim)} · <b>{para.format(p.net)}</b></div></div>
                <div><label>Ödeme seçeneği</label><input style={{ width: '100%' }} value={taslak.odemeSecenegi ?? ''} disabled={!yazar} onChange={e => ayarla('odemeSecenegi', e.target.value)} /></div>
                <div><label>Taksit sayısı</label><input type="number" min={1} max={36} style={{ width: '100%' }} value={taslak.taksitSayisi ?? ''} disabled={!yazar} onChange={e => ayarla('taksitSayisi', e.target.value)} /></div>
                <div style={{ gridColumn: '1 / 3' }}><label>Açıklama (proformada görünür)</label><textarea rows={2} style={{ width: '100%' }} value={taslak.aciklama ?? ''} disabled={!yazar} onChange={e => ayarla('aciklama', e.target.value)} /></div>
                <div style={{ gridColumn: '1 / 3' }}><label>Alternatif plan</label><div className="ds-inp">{v.varyantlar.length ? v.varyantlar.map(x => `${x.varyant}: ${para.format(x.net)} (${DURUM[x.durum]?.[0]})`).join(' · ') : <span className="sonuk">yok</span>}</div></div>
              </div>
              {yazar && <div className="ds-arac"><button className="d onay" disabled={!kirli} onClick={() => void kaydet()}>💾 Kaydet</button></div>}
            </div>
            <div className="ds-grp ds-grp-ic"><div className="ds-gb">Hasta onayı</div>
              <div className="ds-hdr" style={{ padding: '4px 10px 8px', gridTemplateColumns: '1fr 1fr' }}>
                <div><label>Onay</label><div className="ds-inp">{p.hastaOnayZamani ? <><span className="rozet ok">Onaylandı</span> {tarihSaat(p.hastaOnayZamani)}</> : <span className="rozet gri">Onay yok</span>}</div></div>
                <div><label>Yöntem</label><div className="ds-inp">{p.onayYontemi || <span className="sonuk">—</span>}</div></div>
                <div><label>Onam</label><div className="ds-inp">{p.hastaOnayZamani ? `${v.satirlar.filter(s => s.durum !== 4).length} satır hasta onaylı` : <span className="sonuk">onayla birlikte işaretlenir</span>}</div></div>
                <div><label>Belge</label><div className="ds-inp"><span className="sonuk">proforma PDF (döküman) — 🖨 ile</span></div></div>
              </div>
              <div className="ds-arac">
                {yazar && p.durum === 1 && <button className="d" onClick={() => void sun()}>📤 Hastaya sun</button>}
                {yazar && (p.durum === 1 || p.durum === 2) && <button className="d onay" onClick={() => void onayla()}>✍ Hasta onayı (ıslak / tablet)</button>}
                <button className="d" onClick={() => window.print()}>🖨 PDF</button>
                {yazar && p.durum >= 3 && <span className="sonuk">Ek işlem eklenirse plan "ek proforma" ister - satır ekleyin, yeniden sunun.</span>}
              </div>
            </div>
          </div>
          <div className="ds-sag">
            <div className="ds-grp"><div className="ds-gb">Proforma önizleme</div>
              <pre className="ds-proforma">{proformaMetni()}</pre>
            </div>
          </div>
        </div>
      )}

      {sekme === 'odeme' && (
        <div className="ds-odo-alan" style={{ gridTemplateColumns: 'minmax(0,1fr) 360px' }}>
          <div className="ds-sol">
            <div className="ds-grp ds-grp-ic"><div className="ds-gb">Ödeme planı <span className="ds-sp sonuk">dis_odeme_plani · taksitler kasa plan kayıtları</span></div>
              {odemePlani ? (<>
                <div className="ds-hdr" style={{ padding: '4px 10px 8px', gridTemplateColumns: 'repeat(3,1fr)' }}>
                  <div><label>Toplam (net)</label><div className="ds-inp">{para.format(odemePlani.toplam)}</div></div>
                  <div><label>Peşinat</label><div className="ds-inp">{para.format(odemePlani.pesinat)}</div></div>
                  <div><label>Taksit</label><div className="ds-inp">{odemePlani.taksitSayisi} × {para.format(odemePlani.taksitTutar)}</div></div>
                  <div><label>İlk vade</label><div className="ds-inp">{odemePlani.ilkVade ? tarihYaz(odemePlani.ilkVade) : '—'}</div></div>
                  <div><label>Yöntem</label><div className="ds-inp">{['', 'Nakit', 'POS taksit', 'Havale', 'Kredi'][odemePlani.odemeYontemi] ?? odemePlani.odemeYontemi}</div></div>
                  <div><label>Durum</label><div className="ds-inp"><span className={`rozet ${odemePlani.durum === 2 ? 'ok' : 'uyari'}`}>{odemePlani.durum === 2 ? 'Tamamlandı' : oz.tahsil > 0 ? 'Açık · kısmi' : 'Açık'}</span></div></div>
                </div>
                <div className="ds-dg"><table>
                  <thead><tr><th className="orta">Taksit</th><th>Vade</th><th className="sag">Tutar</th><th className="sag">Ödenen</th><th>Ödeme</th><th>Durum</th></tr></thead>
                  <tbody>
                    {v.taksitler.map(k => { const kalan = k.tutar - k.odenen; const gecikti = kalan > 0 && new Date(k.vade).getTime() < Date.now(); return <tr key={k.id}>
                      <td className="orta">{k.sira === 0 ? 'Peşinat' : k.sira}</td><td>{tarihYaz(k.vade)}</td><td className="sag">{para.format(k.tutar)}</td><td className="sag">{para.format(k.odenen)}</td>
                      <td>{k.odemeTarihi ? tarihYaz(k.odemeTarihi) : '—'}{k.maliHareketId ? ` · kasa #${k.maliHareketId}` : ''}</td>
                      <td><span className={`rozet ${kalan <= 0 ? 'ok' : gecikti ? 'hata' : k.odenen > 0 ? 'uyari' : 'gri'}`}>{kalan <= 0 ? 'Ödendi' : k.odenen > 0 ? `Kısmi · ${para.format(kalan)} açık` : gecikti ? 'Gecikti' : 'Bekliyor'}</span></td></tr> })}
                    <tr className="grup"><td colSpan={2}>Toplam</td><td className="sag">{para.format(v.taksitler.reduce((a, k) => a + k.tutar, 0))}</td><td className="sag">{para.format(v.taksitler.reduce((a, k) => a + k.odenen, 0))}</td><td colSpan={2} /></tr>
                  </tbody>
                </table></div>
                <div className="ds-arac">
                  <button className="d bir" onClick={() => git(`/dis-odeme-plani/${odemePlani.id}?geri=${geriParam}`)}>💳 Ödeme planı kartı (tahsilat / taksit düzenle)</button>
                  <span className="ds-sp sonuk">Tahsilat kasa modülüyle; taksit "ödenen" oradan işlenir.</span>
                </div>
              </>) : (<>
                <div className="ds-hdr" style={{ padding: '4px 10px 8px', gridTemplateColumns: 'repeat(4,1fr)' }}>
                  <div><label>Net</label><div className="ds-inp">{para.format(p.net)}</div></div>
                  <div><label>Peşinat</label><input style={{ width: '100%' }} value={odemeForm.pesinat} disabled={!yazar} placeholder="0" onChange={e => setOdemeForm(f => ({ ...f, pesinat: e.target.value }))} /></div>
                  <div><label>Taksit sayısı</label><input type="number" min={1} max={36} style={{ width: '100%' }} value={odemeForm.taksit} disabled={!yazar} onChange={e => setOdemeForm(f => ({ ...f, taksit: e.target.value }))} /></div>
                  <div><label>İlk vade</label><input type="date" style={{ width: '100%' }} value={odemeForm.ilkVade} disabled={!yazar} onChange={e => setOdemeForm(f => ({ ...f, ilkVade: e.target.value }))} /></div>
                  <div><label>Yöntem</label><select value={odemeForm.yontem} disabled={!yazar} onChange={e => setOdemeForm(f => ({ ...f, yontem: e.target.value }))} style={{ width: '100%' }}><option value="1">Nakit</option><option value="2">POS taksit</option><option value="3">Havale</option><option value="4">Kredi</option></select></div>
                  <div style={{ gridColumn: '2 / 5' }}><label>Önizleme</label><div className="ds-inp">{(() => { const pes = Number(odemeForm.pesinat.replace(',', '.')) || 0, t = Math.max(1, Number(odemeForm.taksit) || 1); return pes > p.net ? <span className="ds-kir">peşinat neti aşıyor</span> : `${pes ? `peşinat ${para.format(pes)} + ` : ''}${t} × ${para.format((p.net - pes) / t)}` })()}</div></div>
                </div>
                <div className="ds-arac">
                  {yazar && yetki('dis.odeme') ? <button className="d bir" disabled={p.durum < 2} title={p.durum < 2 ? 'Önce plan sunulmalı / onaylanmalı' : ''} onClick={() => void odemePlaniUret()}>💳 Ödeme planı üret</button> : <span className="sonuk">ödeme planı yetkisi yok</span>}
                  <span className="ds-sp sonuk">Peşinat + eşit taksit; son taksit yuvarlama farkını taşır. Var olan plan ezilmez.</span>
                </div>
              </>)}
            </div>
          </div>
          <div className="ds-sag">
            <div className="ds-grp"><div className="ds-gb">Ücret akışı</div>
              <div className="ds-ic">
                <p><b>Yapılan işlem</b> {para.format(oz.yapilan)} ({oz.yapilanSayisi} satır) → başvuru satırları (tür 19).</p>
                <p><b>Tahsil</b> {para.format(oz.tahsil)} → önce yapılan işlemlere dağıtılır; fazlası <b>avans</b> olarak durur (yapılmamış işin parası borç değildir).</p>
                <p><b>Bakiye</b> = yapılan − tahsil = <b className={bakiye > 0 ? 'ds-kir' : ''}>{para.format(bakiye)}</b>.{labGerekenAcik.length || oz.labSayisi ? ' Kron teslimi bakiye sıfırlanmadan yapılmaz (ayar: uyarı/engel).' : ''}</p>
                <p className="sonuk">Plan iptalinde yapılan işlemler faturalanır, kalan avans iade edilir.</p>
              </div>
            </div>
          </div>
        </div>
      )}

      {sekme === 'lab' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-gb">Lab işleri <span className="ds-sp sonuk">dis_lab_isemri · plan_satir_id</span></div>
          <div className="ds-dg"><table>
            <thead><tr><th>İş emri</th><th className="orta">Plan satırı</th><th>Laboratuvar</th><th className="orta">Diş</th><th>İş · malzeme · renk</th><th>Gönderim</th><th>Beklenen</th><th>Aşama</th><th>Prova / teslim randevusu</th><th className="sag">Lab maliyeti</th><th /></tr></thead>
            <tbody>
              {v.labIsleri.map(l => { const s = v.satirlar.find(z => z.id === l.planSatirId); const gec = l.beklenen && l.asama < 5 && new Date(l.beklenen).getTime() < Date.now(); return <tr key={l.id}>
                <td><b>{l.isemriNo}</b></td><td className="orta">#{l.planSira}{s ? ` · ${s.islem}` : ''}</td><td>{l.lab || '—'}</td><td className="orta">{l.disNolar || s?.disNo || '—'}</td>
                <td>{[LAB_TUR[l.isTuru], l.malzeme, l.renk].filter(Boolean).join(' · ')}</td><td>{l.gonderim ? tarihYaz(l.gonderim) : '—'}</td>
                <td>{l.beklenen ? <span className={gec ? 'ds-kir' : ''}>{tarihYaz(l.beklenen)}{gec ? ' · gecikti' : ''}</span> : '—'}</td>
                <td><span className={`rozet ${LAB_ASAMA[l.asama]?.[1] ?? 'gri'}`}>{LAB_ASAMA[l.asama]?.[0] ?? l.asama}{l.asama >= 5 && l.kaliteKontrol === 1 ? ' · KK ✔' : ''}</span></td>
                <td>{l.randevu ? tarihSaat(l.randevu) : l.teslim ? `teslim ${tarihYaz(l.teslim)}` : '—'}</td><td className="sag">{para.format(l.labFiyat)}</td>
                <td><button className="d" onClick={() => git(`/dis-lab-isemri/${l.id}?geri=${geriParam}`)}>Aç</button></td></tr> })}
              {labGerekenAcik.map(s => <tr key={`a${s.id}`} className="soluk">
                <td>—</td><td className="orta">#{s.sira} · {s.islem}</td><td className="sonuk">varsayılan</td><td className="orta">{s.disNo || s.disNolar || '—'}</td><td className="sonuk">—</td><td>—</td><td>—</td>
                <td><span className="rozet gri">İş emri açılmadı</span></td><td>—</td><td className="sag">—</td>
                <td>{yazar && <button className="d onay" onClick={() => labIsemriAc(s)}>🧪 İş emri aç</button>}</td></tr>)}
              {v.labIsleri.length === 0 && labGerekenAcik.length === 0 && <tr><td colSpan={11} className="sonuk">Lab gerektiren satır yok.</td></tr>}
              {v.labIsleri.length > 0 && <tr className="grup"><td colSpan={9}>Lab maliyeti (hakedişten düşer)</td><td className="sag">{para.format(labMaliyet)}</td><td /></tr>}
            </tbody>
          </table></div>
          <div className="ds-ic sonuk">Lab gerektiren satır (hizmet kartı <code>lab_gerekir</code>) iş emri açılmadan "yapıldı" olamaz; teslim aşamasıyla satır ücretlenir (ücretlendirme kuralı: tamamlanınca).</div>
        </div>
      )}

      {sekme === 'varyant' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-gb">Alternatif planlar <span className="ds-sp sonuk">{p.anaPlanId ? `ana plan ${p.anaPlanNo}` : `ana plan ${p.planNo}`} · karşılaştırmalı proforma</span></div>
          {v.varyantlar.length === 0 ? (
            <div className="ds-ic sonuk">Alternatif yok. Araç çubuğundaki "🔁 Alternatif Plan" satırları kopyalayıp yeni varyant açar; hastaya ikisi karşılaştırmalı sunulur, seçilen sürer.</div>
          ) : (<>
            <div className="ds-dg"><table>
              <thead><tr><th className="orta">Diş</th><th>{p.varyant} — {p.anaPlanId ? 'bu (alternatif)' : 'ana plan'}</th><th className="sag">{p.varyant} net</th>
                {v.varyantlar.map(x => <><th key={`h${x.id}`}>{x.varyant} — {x.planNo}</th><th key={`n${x.id}`} className="sag">{x.varyant} net</th></>)}<th className="sag">Fark</th></tr></thead>
              <tbody>
                {disKarsilastirma.map(([disNo, r]) => { const a = (r[p.id] ?? []).reduce((t, s) => t + s.net, 0); const b0 = v.varyantlar[0] ? (r[v.varyantlar[0].id] ?? []).reduce((t, s) => t + s.net, 0) : a; return <tr key={disNo}>
                  <td className="orta">{disNo || 'genel'}</td><td>{(r[p.id] ?? []).map(s => s.islem).join(' + ') || <span className="sonuk">—</span>}</td><td className="sag">{para.format(a)}</td>
                  {v.varyantlar.map(x => <><td key={`i${x.id}`}>{(r[x.id] ?? []).map(s => s.islem).join(' + ') || <span className="sonuk">—</span>}</td><td key={`t${x.id}`} className="sag">{para.format((r[x.id] ?? []).reduce((t, s) => t + s.net, 0))}</td></>)}
                  <td className="sag">{para.format(b0 - a)}</td></tr> })}
                <tr className="grup"><td /><td>{p.varyant} toplam</td><td className="sag">{para.format(p.net)}</td>
                  {v.varyantlar.map(x => <><td key={`a${x.id}`}>{x.varyant} toplam · <span className={`rozet ${DURUM[x.durum]?.[1]}`}>{DURUM[x.durum]?.[0]}</span></td><td key={`b${x.id}`} className="sag">{para.format(x.net)}</td></>)}
                  <td className="sag">{v.varyantlar[0] ? para.format(v.varyantlar[0].net - p.net) : ''}</td></tr>
              </tbody>
            </table></div>
            <div className="ds-arac">
              {v.varyantlar.map(x => <span key={x.id} style={{ display: 'inline-flex', gap: 4 }}>
                <button className="d" onClick={() => git(`/dis-plan/${x.id}`, { state: { geri } })}>📋 {x.varyant} planını aç</button>
                {yazar && !p.anaPlanId && x.durum <= 2 && p.durum <= 2 && <button className="d" onClick={() => void anaYap(x.id, x.planNo)}>🔁 {x.varyant}'yi ana plan yap</button>}
              </span>)}
              <button className="d" onClick={() => window.print()}>🖨 Karşılaştırmalı proforma</button>
              <span className="ds-sp sonuk">Varyant ayrı plan kaydıdır (<code>varyant</code>, <code>ana_plan_id</code>); onaylanan sürer, öteki "iptal (seçilmedi)".</span>
            </div>
          </>)}
        </div>
      )}

      {sekme === 'gunluk' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-gb">Günlük <span className="ds-sp sonuk">ISLEMLOG 1130 plan · 1131 satır · 1138 ödeme planı</span></div>
          <div className="ds-dg"><table>
            <thead><tr><th>Zaman</th><th>Kullanıcı</th><th>İşlem</th><th>Kayıt</th><th>Bilgi</th></tr></thead>
            <tbody>
              {v.gunluk.map((g, i) => <tr key={i}><td>{tarihSaat(g.tarih)}</td><td>{g.kullanici || '—'}</td><td>{LOG_TIP[g.islemTipi] ?? g.islemTipi}</td><td>{LOG_TABLO[g.tabloId] ?? g.tabloId} #{g.kayitId}</td><td style={{ whiteSpace: 'normal', maxWidth: 520 }} className="sonuk">{g.bilgi.replace(/[{}"]/g, '').slice(0, 300)}</td></tr>)}
              {v.gunluk.length === 0 && <tr><td colSpan={5} className="sonuk">Kayıt yok.</td></tr>}
            </tbody>
          </table></div>
          <div className="ds-ic sonuk">Plan sürümleri (ek proforma) henüz ayrı kayıt değil: fiyat değişikliği ve satır ekleme günlükte izlenir.</div>
        </div>
      )}
    </Perde>
  );
}
