import { useCallback, useEffect, useMemo, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type KartDetayMeta, type KartMetaYaniti } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { GenDetayTablo, bosDetay, detayFarki, type DetayDurumu } from '../GenDetayTablo';
import { guvenli, mesaj } from '../mesaj';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { KaynakArama } from '../KaynakArama';

/**
 * MUAYENE ŞABLONU KARTI — mockup `Ekranlar/Muayene/muayene_sablon_karti.html`.
 *
 * Sekmeler: Genel (tanım + BÖLÜM / DOKTOR kapsamı) · Alanlar (sistem gruplu
 * alan gridi) · HEKİM TERCİHLERİ (931: Sık Tanılar · Reçete Şablonları · İstem
 * Panelleri · Metin Makroları · Kurallar - şablonun bölüm/doktor kapsamıyla)
 * · Önizleme (muayenede nasıl görünür) · Kullanım (muayene.sablon_id sayımı)
 * · Geçmiş (islem_log).
 *
 * Kapsam iki kolondan: doktor boş = BÖLÜM ORTAK, dolu = DOKTORA ÖZEL. Bölüm
 * varsayılanı (⭐) ve "Kopyala (bana)" düğmelerin işi (sunucu ucu); kartta elle
 * yazılmaz.
 */

const TURLER = [{ kod: 1, ad: 'Fizik muayene' }, { kod: 2, ad: 'Anamnez' }, { kod: 3, ad: 'Sistem sorgusu' }];
/**
 * HEKİM TERCİHLERİ (kullanıcı: "sık tanılar, reçete şablonları, istem
 * panelleri, metin makroları, kurallar da branş/doktora özel.. kartın içine
 * al"): şablonun detayları; sekme adı -> katalog detay adı.
 */
const TERCIHLER = [
  { sekme: 'Sık Tanılar', ad: 'tanilar' },
  { sekme: 'Reçete Şablonları', ad: 'receteler' },
  { sekme: 'İstem Panelleri', ad: 'paneller' },
  { sekme: 'Metin Makroları', ad: 'makrolar' },
  { sekme: 'Kurallar', ad: 'kurallar' },
] as const;
type TercihAd = typeof TERCIHLER[number]['ad'];
// SIRA (kullanıcı): Önizleme Alanlar'ın hemen sağında (alanı yazıp sonucu
//   görmek yan yana), onun sağında Metin Makroları; sonra diğer tercihler.
const SEKMELER = ['Genel', 'Alanlar', 'Önizleme', 'Metin Makroları', 'Sık Tanılar', 'Reçete Şablonları',
                  'İstem Panelleri', 'Kurallar', 'Kullanım', 'Geçmiş'] as const;
/** Sekmenin altındaki açıklama (neyi, muayenede nerede etkiler). */
const TERCIH_NOTU: Record<TercihAd, string> = {
  tanilar: 'Muayenede ICD arama penceresindeki "📋 Şablon Tanıları" listesinde çıkar.',
  receteler: 'Aynı "Reçete Şablonu" adındaki ilaçlar tek reçetedir; muayenede reçete gridindeki "📋 Şablondan" ile tek tıkla yazılır.',
  paneller: 'Muayenede istem ekranı bu panellerle açılır (Laboratuvar › ⭐ Şablon Panelleri).',
  makrolar: 'Muayene alanında kısayol yazıp boşluk (ya da Tab) basınca metne açılır; alan boşsa her alanda geçerli.',
  kurallar: 'Aktif kural muayene TAMAMLA sırasında denetlenir; yasal zorunluluklara (ana tanı, şikayet, çıkış şekli) eklenir.',
};
const bosTercihler = (): Record<TercihAd, DetayDurumu> =>
  Object.fromEntries(TERCIHLER.map(t => [t.ad, bosDetay()])) as Record<TercihAd, DetayDurumu>;
const tercihDegisti = (x: DetayDurumu) =>
  x.silinen.length > 0 || JSON.stringify(x.guncel) !== JSON.stringify(x.ilk);
const GIZLI_ALAN = new Set(['secenekler', 'oneriler']);
/** Seçenekli tip (katalog SablonAlanTipKodlari: 3 = Seçenekli). */
const SECENEKLI = 3;

/** jsonb seçenek dizisini okur: '["yok","+1"]' ya da dizi → string[]. */
export function secenekOku(v: unknown): string[] {
  if (Array.isArray(v)) return v.map(x => String(x));
  const s = String(v ?? '').trim();
  if (!s) return [];
  try { const d = JSON.parse(s); return Array.isArray(d) ? d.map(x => String(x)) : [] }
  catch { return [] }
}

/**
 * SEÇENEK / ÖNERİ DÜZENLEYİCİSİ (kullanıcı: "seçenekleri de kartta
 * düzenlenebilir yap"; "önerileri şablon ayarlara ekle, istersem
 * değiştiririm"): seçili alanın listesi çip olarak - ekle (Enter), çıkar
 * (✕), sola/sağa taşı. "Seçenekli" tipte SEÇENEKLER (kısıt), diğer tiplerde
 * bulgu kutusunun ÖNERİLERİ (açılır liste, serbest yazı da serbest).
 * JSON dizi olarak satıra yazılır; kayıt kartın Kaydet'iyle.
 */
function SecenekDuzenleyici({ satir, salt, onDegis }: {
  satir: Record<string, unknown> | null;
  salt?: boolean;
  /** alan: hangi kolona yazılacağı ('secenekler' | 'oneriler'). */
  onDegis(json: string | null, alan: 'secenekler' | 'oneriler'): void;
}) {
  const [yeni, setYeni] = useState('');
  if (!satir) return (
    <div className="ms-secenek"><h6>{c('Seçenekler')}</h6>
      <p className="not">{c('Gridden bir alan seçin (satır başındaki kutu).')}</p></div>
  );
  const secenekli = Number(satir.tip ?? 0) === SECENEKLI;
  const alan = secenekli ? 'secenekler' : 'oneriler';
  const liste = secenekOku(satir[alan]);
  const yaz = (l: string[]) => onDegis(l.length ? JSON.stringify(l) : null, alan);
  const ekle = () => {
    const d = yeni.trim();
    if (!d || liste.some(x => x.toLocaleLowerCase('tr') === d.toLocaleLowerCase('tr'))) { setYeni(''); return }
    yaz([...liste, d]); setYeni('');
  };
  const tasi = (i: number, y: -1 | 1) => {
    const j = i + y;
    if (j < 0 || j >= liste.length) return;
    const l = [...liste]; [l[i], l[j]] = [l[j], l[i]]; yaz(l);
  };
  return (
    <fieldset className="ms-secenek ms-fieldset" disabled={salt}>
      <h6>{secenekli ? c('Seçenekler') : c('Öneriler')} — {String(satir.ad ?? '')}</h6>
      {!secenekli && (
        <p className="not">{c('Muayenede bulgu kutusunda açılır liste olarak çıkar; hekim listeden seçer ya da serbest yazar.')}</p>
      )}
      <div className="ms-cipler">
        {liste.length === 0 && <span className="sonuk">{secenekli ? c('Seçenek yok.') : c('Öneri yok.')}</span>}
        {liste.map((x, i) => (
          <span key={`${x}-${i}`} className={`ms-cip${String(satir.normalMetni ?? '') === x ? ' normal' : ''}`}>
            <button type="button" aria-label={`${x} ${c('sola')}`} disabled={i === 0} onClick={() => tasi(i, -1)}>‹</button>
            {x}
            <button type="button" aria-label={`${x} ${c('sağa')}`} disabled={i === liste.length - 1} onClick={() => tasi(i, 1)}>›</button>
            <button type="button" aria-label={`${x} ${c('kaldır')}`} onClick={() => yaz(liste.filter((_, k) => k !== i))}>✕</button>
          </span>
        ))}
      </div>
      <div className="ms-secenek-ekle">
        <input value={yeni} maxLength={secenekli ? 60 : 120}
               placeholder={secenekli ? c('Yeni seçenek… (Enter)') : c('Yeni öneri… (Enter)')}
               aria-label={secenekli ? c('Yeni seçenek') : c('Yeni öneri')}
               onChange={e => setYeni(e.target.value)}
               onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); ekle() } }} />
        <button type="button" className="d" onClick={ekle}>＋ {c('Ekle')}</button>
      </div>
      <p className="not">{c('Normal metnine eşit seçenek yeşil görünür: "Tümü normal" onu seçer.')}</p>
    </fieldset>
  );
}
type Sekme = typeof SEKMELER[number];

const metin = (v: unknown) => String(v ?? '').trim();
const sayi = (v: unknown) => Number(v ?? 0);
const zaman = (v: unknown) => {
  const d = new Date(metin(v));
  return Number.isNaN(d.getTime()) ? metin(v) : d.toLocaleString('tr-TR', {
    day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });
};
/** Lookup adının başındaki SKRS kodunu atar ("157 - İç Hastalıkları"). */
const kodsuz = (s: string) => s.replace(/^\s*\d+\s*-\s*/, '');

interface Deger {
  kod: string; ad: string; tur: number; aciklama: string; sira: number; durum: number;
  bolumId: number | null; hekimId: number | null;
}

export function MuayeneSablonKarti({ id, varsayilanBolum, onKapat, onDegisti }: {
  id: number | 'yeni';
  /** Yeni şablonda önceden seçili bölüm (listede seçili düğüm). */
  varsayilanBolum?: number | null;
  onKapat(): void;
  onDegisti?(): void;
}) {
  // YETKİ (929): şablon yöneticisi her şablonu, doktor yalnız KENDİ şablonunu
  //   düzenler. Kural sunucuda; ekran salt okunur açıp "Kopyala (bana)" önerir.
  const { kullanici, aksiyonVar } = useOturum();
  const benimId = Number(kullanici?.id ?? 0);
  const yonetici = aksiyonVar('muayene.sablon_yonet');
  const [kayitId, setKayitId] = useState<number | null>(id === 'yeni' ? null : id);
  const [meta, setMeta] = useState<KartMetaYaniti | null>(null);
  const [d, setD] = useState<Deger>({ kod: '', ad: '', tur: 1, aciklama: '', sira: 10, durum: 1,
                                      bolumId: varsayilanBolum ?? null,
                                      // Yönetici değilse yeni şablon doktorun KENDİ şablonudur.
                                      hekimId: yonetici ? null : (benimId || null) });
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [ek, setEk] = useState<{ varsayilan: boolean; kaynakSablonId: number | null }>(
    { varsayilan: false, kaynakSablonId: null });
  const [surum, setSurum] = useState<string | undefined>();
  const [alanlar, setAlanlar] = useState<DetayDurumu>(bosDetay());
  const [tercih, setTercih] = useState<Record<TercihAd, DetayDurumu>>(bosTercihler);
  const tercihYaz = (ad: TercihAd, x: DetayDurumu) => setTercih(o => ({ ...o, [ad]: x }));
  /** Arama penceresi: ICD (sık tanı) ya da ilaç (reçete şablonu). */
  const [arama, setArama] = useState<'icd' | 'ilac' | null>(null);
  /** Yeni ilaçların yazılacağı reçete şablonu adı. */
  const [receteGrup, setReceteGrup] = useState('');
  const [sekme, setSekme] = useState<Sekme>('Genel');
  const [hata, setHata] = useState<string | null>(null);
  const [alanHatalari, setAlanHatalari] = useState<Record<string, string>>({});
  const [kaydediyor, setKaydediyor] = useState(false);
  /** Alanlar gridinde seçili TEK satır (seçenek düzenleyicisi için). */
  const [seciliAlan, setSeciliAlan] = useState<number | null>(null);
  const alanSecildi = useCallback((k: ReadonlySet<number>) =>
    setSeciliAlan(k.size === 1 ? [...k][0] : null), []);
  const [kullanim, setKullanim] = useState<Awaited<ReturnType<typeof api.sablonKullanim>> | null>(null);
  const [gecmis, setGecmis] = useState<Awaited<ReturnType<typeof api.sablonGecmis>>['satirlar'] | null>(null);

  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));

  const oku = async (kid: number) => {
    const y = await api.kartOku('muayene-sablon', kid);
    const k = y.kart;
    const v: Deger = {
      kod: metin(k.kod), ad: metin(k.ad), tur: sayi(k.tur) || 1, aciklama: metin(k.aciklama),
      sira: sayi(k.sira), durum: sayi(k.durum ?? 1),
      bolumId: k.bolumId == null || sayi(k.bolumId) === 0 ? null : sayi(k.bolumId),
      hekimId: k.hekimId == null || sayi(k.hekimId) === 0 ? null : sayi(k.hekimId),
    };
    setKayitId(kid); setD(v); setIlk(v); setSurum(k.surum);
    setEk({ varsayilan: sayi(k.varsayilan) === 1,
            kaynakSablonId: k.kaynakSablonId ? sayi(k.kaynakSablonId) : null });
    setAlanlar(bosDetay((y.detaylar?.alanlar ?? []) as Parameters<typeof bosDetay>[0]));
    setTercih(Object.fromEntries(TERCIHLER.map(t =>
      [t.ad, bosDetay((y.detaylar?.[t.ad] ?? []) as Parameters<typeof bosDetay>[0])])) as Record<TercihAd, DetayDurumu>);
    setKullanim(null); setGecmis(null);
  };

  useEffect(() => {
    void (async () => {
      try {
        setMeta(await api.kartAlanlari('muayene-sablon'));
        if (id !== 'yeni') await oku(id);
      } catch (h) { setHata(hataMetni(h)) }
    })();
  }, [id]);   // yalniz acilista

  // Kullanım / geçmiş sekmesi açılınca bir kez okunur.
  useEffect(() => {
    if (kayitId === null) return;
    if (sekme === 'Kullanım' && !kullanim)
      void api.sablonKullanim(kayitId).then(setKullanim).catch(e => setHata(hataMetni(e)));
    if (sekme === 'Geçmiş' && !gecmis)
      void api.sablonGecmis(kayitId).then(y => setGecmis(y.satirlar)).catch(e => setHata(hataMetni(e)));
  }, [sekme, kayitId, kullanim, gecmis]);

  const alanMeta: KartDetayMeta | undefined = meta?.detaylar?.find(x => x.ad === 'alanlar');
  // Bölüm / doktor seçenekleri kart metasındaki lookup'lardan (sunucu).
  const secenekler = (ad: string, kodu: boolean) =>
    Object.entries(meta?.alanlar.find(a => a.ad === ad)?.kodlar ?? {})
      .map(([k, v]) => ({ kod: Number(k), ad: kodu ? kodsuz(v) : v }))
      .sort((a, b) => a.ad.localeCompare(b.ad, 'tr'));
  const bolumler = useMemo(() => secenekler('bolumId', true), [meta]);
  const doktorlar = useMemo(() => secenekler('hekimId', false), [meta]);

  const govde = (v: Deger): Record<string, unknown> => ({
    kod: v.kod.trim(), ad: v.ad.trim(), tur: v.tur, aciklama: v.aciklama.trim(), sira: v.sira,
    durum: v.durum, bolumId: v.bolumId, hekimId: v.hekimId,
  });

  const kaydet = (ekAlan?: Partial<Deger>) => guvenli(async () => {
    const v = { ...d, ...ekAlan };
    if (!v.kod.trim() || !v.ad.trim()) { setHata('Kod ve şablon adı zorunlu.'); setSekme('Genel'); return }
    if (!v.bolumId) { setHata('Bölüm seçilmeli.'); setSekme('Genel'); return }
    setHata(null); setAlanHatalari({});
    setKaydediyor(true);
    try {
      const izinli = alanMeta?.alanlar.filter(a => a.yazilabilir !== false).map(a => a.ad);
      // Alan farkı yalnız DEĞİŞİKLİK varsa gider (boş fark gereksiz yazım ve log).
      const f = detayFarki(alanlar, izinli);
      const dolu = (x: ReturnType<typeof detayFarki>) => !!(x.eklenen?.length || x.degisen?.length || x.silinen?.length);
      const tum: Record<string, ReturnType<typeof detayFarki>> = {};
      if (dolu(f)) tum.alanlar = f;
      for (const t of TERCIHLER) {
        const m = meta?.detaylar?.find(x => x.ad === t.ad);
        const tf = detayFarki(tercih[t.ad], m?.alanlar.filter(a => a.yazilabilir !== false).map(a => a.ad));
        if (dolu(tf)) tum[t.ad] = tf;
      }
      const detaylar = Object.keys(tum).length ? tum : undefined;
      let yeniId = kayitId;
      if (kayitId === null) {
        const y = await api.kartEkle('muayene-sablon', { kart: govde(v), detaylar });
        yeniId = sayi(y.kart.id);
      } else {
        const once = ilk ? govde(ilk) : {};
        const fark = Object.fromEntries(Object.entries(govde(v)).filter(([k, x]) => once[k] !== x));
        await api.kartGuncelle('muayene-sablon', kayitId, { surum, kart: fark, detaylar });
      }
      onDegisti?.();
      if (yeniId) await oku(yeniId);
      mesaj('Şablon kaydedildi.');
    } catch (h) {
      const e = h as { alanlar?: { alan: string; mesaj: string }[] };
      if (e.alanlar) setAlanHatalari(Object.fromEntries(e.alanlar.map(x => [x.alan, x.mesaj])));
      throw h;
    } finally { setKaydediyor(false) }
  });

  const kopyala = () => guvenli(async () => {
    if (kayitId === null) return;
    const y = await api.sablonKopyala(kayitId);
    mesaj(y.mesaj);
    onDegisti?.();
    await oku(y.id);
    setSekme('Genel');
  });

  const varsayilanYap = () => guvenli(async () => {
    if (kayitId === null) return;
    const y = await api.sablonVarsayilan(kayitId);
    mesaj(y.mesaj);
    onDegisti?.();
    await oku(kayitId);
  });

  const bolumOrtak = d.hekimId === null;
  /** Düzenleme hakkı: yönetici ya da (kayıtlı şablonda) sahibi. */
  //   Kayıt okunmadan (ilk yok) sahip BİLİNMEZ: kilit bandı yüklenirken yanıp sönmesin.
  const salt = !yonetici && kayitId !== null && ilk !== null && ilk.hekimId !== benimId;
  const bolumAdi = bolumler.find(b => b.kod === d.bolumId)?.ad ?? '';
  const doktorAdi = doktorlar.find(x => x.kod === d.hekimId)?.ad ?? '';
  const degisti = kayitId === null || (ilk !== null && JSON.stringify(govde(d)) !== JSON.stringify(govde(ilk)))
    || alanlar.silinen.length > 0 || JSON.stringify(alanlar.guncel) !== JSON.stringify(alanlar.ilk)
    || TERCIHLER.some(t => tercihDegisti(tercih[t.ad]));

  /** Arama penceresinden seçilen satırı ilgili tercih detayına ekler (aynı tanı ikinci kez eklenmez). */
  const aramadanEkle = (r: Record<string, unknown>) => {
    if (arama === 'icd') {
      const kod = metin(r.kod);
      setTercih(o => o.tanilar.guncel.some(x => metin(x.icdKod) === kod) ? o : ({ ...o, tanilar: { ...o.tanilar,
        guncel: [...o.tanilar.guncel, { sira: o.tanilar.guncel.length + 1, icdKod: kod, taniAd: metin(r.ad), aciklama: '' }] } }));
    } else if (arama === 'ilac') {
      const grup = receteGrup.trim() || c('Genel');
      setTercih(o => ({ ...o, receteler: { ...o.receteler, guncel: [...o.receteler.guncel, {
        grup, sira: o.receteler.guncel.filter(x => metin(x.grup) === grup).length + 1,
        ilacBarkod: metin(r.barkod), ilacAd: metin(r.ad), doz: '', periyot: '', kullanimSekli: 1,
        sureGun: 0, kutu: 1, icdKod: '', aciklama: '' }] } }));
    }
  };
  const alanSayisi = alanlar.guncel.length;
  const normalEksik = alanlar.guncel.filter(a => !metin(a.normalMetni)).length;

  // Önizleme: sistem gruplu alanlar, normal metniyle.
  const gruplu = useMemo(() => {
    const m = new Map<string, Record<string, unknown>[]>();
    [...alanlar.guncel].sort((a, b) => sayi(a.sira) - sayi(b.sira)).forEach(a => {
      const g = metin(a.grup) || 'Genel';
      m.set(g, [...(m.get(g) ?? []), a as Record<string, unknown>]);
    });
    return [...m.entries()];
  }, [alanlar.guncel]);

  return (
    <Modal baslik={`📋 ${c('Muayene Şablonu')} — ${kayitId === null ? c('Yeni') : `#${kayitId}`}`}
      ekSinif="kart-sablon" buyutmeYok onKapat={onKapat}
      ustSerit={(
        <div className="rk-kimlik">
          <b className="rk-ad">{ek.varsayilan && <span className="ms-yildiz">⭐ </span>}{d.ad || c('Yeni şablon')}</b>
          {d.kod && <span className="sonuk">{d.kod}</span>}
          <span className="rozet mavi">{TURLER.find(t => t.kod === d.tur)?.ad}</span>
          {bolumAdi && <span className="rozet gri">{bolumAdi}</span>}
          <span className={`rozet ${bolumOrtak ? 'olumlu' : 'mavi'}`}>
            {bolumOrtak ? c('Bölüm ortak') : `${c('Doktora özel')} · ${doktorAdi}`}
          </span>
          <span className={`rozet ${d.durum === 1 ? 'olumlu' : 'gri'}`}>{d.durum === 1 ? c('Aktif') : c('Pasif')}</span>
          <span className="rk-bosluk" />
          {kullanim && <span className="sonuk">{kullanim.toplam30} {c('muayene / 30 gün')} · {kullanim.doktorSayisi} {c('doktor')}</span>}
        </div>
      )}
      alt={<>
        {!salt && (
          <button type="button" className="d bir" disabled={kaydediyor || !degisti} onClick={() => void kaydet()}>
            💾 {c('Kaydet')}
          </button>
        )}
        {kayitId !== null && (
          <button type="button" className="d" onClick={() => void kopyala()}
                  title={c('Bu şablonu kendi şablonunuz olarak çoğaltır; asıl şablon değişmez')}>
            ⧉ {c('Kopyala (bana)')}
          </button>
        )}
        {yonetici && kayitId !== null && bolumOrtak && d.bolumId && d.durum === 1 && !ek.varsayilan && (
          <button type="button" className="d" onClick={() => void varsayilanYap()}
                  title={c('Bu bölümde muayene açılınca önerilen şablon olur; eskisi kalkar')}>
            ⭐ {c('Bölüm varsayılanı yap')}
          </button>
        )}
        <span style={{ marginLeft: 'auto' }} />
        {/* Kayit OKUNDUKTAN sonra: yuklenirken tik surumsuz (eszamanlilik denetimsiz) yazim gonderirdi. */}
        {kayitId !== null && ilk !== null && !salt && (
          <button type="button" className={`d${d.durum === 1 ? ' teh' : ''}`}
                  onClick={() => void kaydet({ durum: d.durum === 1 ? 0 : 1 })}>
            {d.durum === 1 ? `⏸ ${c('Pasif yap')}` : `▶ ${c('Aktif yap')}`}
          </button>
        )}
        <button type="button" className="d kapat-dugmesi" onClick={onKapat}>✖ {c('Kapat')}</button>
      </>}
      sekmeBar={(
        <div className="katab">
          {SEKMELER.map(s => (
            <div key={s} className={`kat${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}
                 role="tab" aria-selected={sekme === s}>
              {c(s)}
              {s === 'Alanlar' && <span className="b">{alanSayisi}</span>}
              {TERCIHLER.filter(t => t.sekme === s && tercih[t.ad].guncel.length > 0).map(t => (
                <span key={t.ad} className="b">{tercih[t.ad].guncel.length}</span>))}
            </div>
          ))}
        </div>
      )}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {salt && (
        <div className="rk-bant mavi ms-bant ms-salt">
          🔒 {bolumOrtak ? c('Bu şablon bölüm ortaktır') : c('Bu şablon başka bir doktorundur')}
          {c(' — yalnız görüntüleyebilirsiniz. Kendinize uyarlamak için "⧉ Kopyala (bana)"; kopya yalnız sizin muayenenizde çıkar.')}
        </div>
      )}
      {!meta ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <div className="ms-govde">
          {sekme === 'Genel' && (
            <fieldset className="ms-fieldset" disabled={salt}>
              <div className="kagrup">
                <h6>{c('Tanım')}</h6>
                <div className="ms-alanlar">
                  <div className="rk-fld">
                    <label htmlFor="ms-kod">{c('Kod')} <span className="ak-zor">*</span></label>
                    <input id="ms-kod" value={d.kod} maxLength={30} onChange={e => yaz('kod', e.target.value)} />
                  </div>
                  <div className="rk-fld ms-iki">
                    <label htmlFor="ms-ad">{c('Şablon adı')} <span className="ak-zor">*</span></label>
                    <input id="ms-ad" value={d.ad} maxLength={120} onChange={e => yaz('ad', e.target.value)} />
                  </div>
                  <div className="rk-fld ms-tam">
                    <label>{c('Tür')}</label>
                    <div className="ak-seg" role="radiogroup" aria-label={c('Tür')}>
                      {TURLER.map(t => (
                        <button key={t.kod} type="button" role="radio" aria-checked={d.tur === t.kod}
                                className={d.tur === t.kod ? 'on' : ''} onClick={() => yaz('tur', t.kod)}>{t.ad}</button>
                      ))}
                    </div>
                  </div>
                  <div className="rk-fld ms-tam">
                    <label htmlFor="ms-aciklama">{c('Açıklama')}</label>
                    <input id="ms-aciklama" value={d.aciklama} maxLength={300} onChange={e => yaz('aciklama', e.target.value)} />
                  </div>
                </div>
              </div>
              <div className="kagrup">
                <h6>{c('Kapsam — Bölüm ve Doktor')}</h6>
                <div className="ms-alanlar">
                  <div className="rk-fld">
                    <label htmlFor="ms-bolum">{c('Bölüm')} <span className="ak-zor">*</span></label>
                    <select id="ms-bolum" value={d.bolumId ?? ''} onChange={e => yaz('bolumId', e.target.value ? Number(e.target.value) : null)}>
                      <option value="">—</option>
                      {bolumler.map(b => <option key={b.kod} value={b.kod}>{b.ad}</option>)}
                    </select>
                  </div>
                  <div className="rk-fld">
                    <label htmlFor="ms-doktor">{c('Doktor')}</label>
                    <select id="ms-doktor" value={d.hekimId ?? ''} disabled={!yonetici}
                            title={yonetici ? '' : c('Yalnız şablon yöneticisi doktoru değiştirir')} onChange={e => yaz('hekimId', e.target.value ? Number(e.target.value) : null)}>
                      <option value="">{c('— (bölüm ortak)')}</option>
                      {doktorlar.map(x => <option key={x.kod} value={x.kod}>{x.ad}</option>)}
                    </select>
                  </div>
                  <div className="rk-fld">
                    <label>{c('Kapsam')}</label>
                    <div className="ak-salt">
                      {bolumOrtak ? c('Bölüm ortak') : c('Doktora özel')}
                      {ek.varsayilan && <span className="rozet uyari" style={{ marginLeft: 6 }}>⭐ {c('bölüm varsayılanı')}</span>}
                    </div>
                  </div>
                  <div className="rk-fld">
                    <label htmlFor="ms-sira">{c('Sıra')}</label>
                    <input id="ms-sira" type="number" value={d.sira} onChange={e => yaz('sira', Number(e.target.value))} />
                  </div>
                  <label className="ak-kutu">
                    <input type="checkbox" checked={d.durum === 1} onChange={e => yaz('durum', e.target.checked ? 1 : 0)} />
                    {c('Aktif')}
                  </label>
                  {ek.kaynakSablonId && (
                    <div className="rk-fld">
                      <label>{c('Kopyalandığı şablon')}</label>
                      <div className="ak-salt">#{ek.kaynakSablonId}</div>
                    </div>
                  )}
                </div>
                <div className="rk-bant mavi ms-bant">
                  {c('Doktor boş = bölüm ortak: bölümdeki bütün doktorların muayenesinde önerilir. Doktor seçilirse yalnız o doktorun muayenesinde çıkar. Bölümde tek ⭐ varsayılan olur; yenisi seçilince eskisi kalkar.')}
                </div>
              </div>
            </fieldset>
          )}

          {sekme === 'Alanlar' && alanMeta && (
            <div className="ms-alan-sekme">
              <div className="ms-alan-iki">
                {/* Grid kipi: satır başında seçim, düzenleme modalda. SEÇENEKLER
                    ham JSON olarak gösterilmez - sağdaki çip düzenleyicisi yazar. */}
                <GenDetayTablo meta={alanMeta} durum={alanlar} hatalar={alanHatalari}
                               saltOkunur={salt} onDegis={setAlanlar}
                               modalDuzenle ikonlu
                               gizliAlanlar={GIZLI_ALAN} onSecim={alanSecildi} />
                <SecenekDuzenleyici salt={salt} satir={seciliAlan === null ? null : alanlar.guncel[seciliAlan] ?? null}
                  onDegis={(yeni, alan) => setAlanlar(o => ({ ...o, guncel: o.guncel.map((r, i) =>
                    i === seciliAlan ? { ...r, [alan]: yeni } : r) }))} />
              </div>
              <p className="not">
                {c('Normal metni olan alan muayenede "☑ Tümü normal" ile tek tıkla dolar; yazılmış bulgu ezilmez.')}
                {normalEksik > 0 && ` ${normalEksik} ${c('alanda normal metni yok.')}`}
              </p>
            </div>
          )}

          {TERCIHLER.filter(t => t.sekme === sekme).map(t => {
            const m = meta.detaylar?.find(x => x.ad === t.ad);
            if (!m) return <p key={t.ad} className="not">{c('Sunucu bu bölümü henüz tanımıyor (API güncel değil).')}</p>;
            return (
              <div key={t.ad} className="ms-tercih">
                {!salt && t.ad === 'tanilar' && (
                  <div className="ms-tercih-arac">
                    <button type="button" className="d bir" onClick={() => setArama('icd')}>＋ {c('ICD-10 ara')}</button>
                  </div>
                )}
                {!salt && t.ad === 'receteler' && (
                  <div className="ms-tercih-arac">
                    <label htmlFor="ms-recete-grup">{c('Reçete şablonu')}</label>
                    <input id="ms-recete-grup" list="ms-recete-gruplar" value={receteGrup} maxLength={80}
                           placeholder={c('ör. Üst solunum yolu enfeksiyonu')} onChange={e => setReceteGrup(e.target.value)} />
                    <datalist id="ms-recete-gruplar">
                      {[...new Set(tercih.receteler.guncel.map(x => metin(x.grup)).filter(Boolean))].map(g => <option key={g} value={g} />)}
                    </datalist>
                    <button type="button" className="d bir" onClick={() => setArama('ilac')}>＋ {c('İlaç ekle')}</button>
                  </div>
                )}
                <GenDetayTablo meta={m} durum={tercih[t.ad]} hatalar={alanHatalari}
                               saltOkunur={salt} onDegis={x => tercihYaz(t.ad, x)} modalDuzenle ikonlu />
                <p className="not">{c(TERCIH_NOTU[t.ad])}</p>
              </div>
            );
          })}

          {sekme === 'Önizleme' && (
            <div className="ms-onizleme">
              <div className="ms-onz-arac">
                <span className="d">☑ {c('Tümü normal işaretle')}</span>
                <span className="sonuk">{c('muayene kartı › Şablon Muayene sekmesi')}</span>
              </div>
              <table className="detay-tablo">
                <thead><tr><th>{c('Sistem')}</th><th className="hiza-orta">{c('Normal')}</th><th>{c('Bulgu')}</th><th>{c('Taraf')}</th></tr></thead>
                <tbody>
                  {gruplu.length === 0 && <tr><td colSpan={4} className="bos">{c('Alan yok.')}</td></tr>}
                  {gruplu.map(([grup, satirlar]) => [
                    <tr key={`g-${grup}`} className="ms-grup"><td colSpan={4}>{grup}</td></tr>,
                    ...satirlar.map((a, i) => (
                      <tr key={`${grup}-${i}`}>
                        <td>{metin(a.ad)}{sayi(a.zorunlu) === 1 && <span className="ak-zor"> *</span>}</td>
                        <td className="hiza-orta">{metin(a.normalMetni) ? '☑' : '☐'}</td>
                        <td>{metin(a.normalMetni) || <span className="sonuk">—</span>}
                          {secenekOku(a.secenekler).length > 0 && (
                            <span className="sonuk"> · {secenekOku(a.secenekler).join(' / ')}</span>)}</td>
                        <td>{sayi(a.tarafSorulur) === 1 ? c('Sağ / Sol / Bilateral') : ''}</td>
                      </tr>
                    )),
                  ])}
                </tbody>
              </table>
            </div>
          )}

          {sekme === 'Kullanım' && (
            kayitId === null ? <p className="not">{c('Kaydedilince kullanım görünür.')}</p>
            : !kullanim ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
              <div className="ms-kullanim">
                <div className="ms-kpi">
                  <div><span>{c('Son 30 gün')}</span><b>{kullanim.toplam30}</b><small>{c('muayene')}</small></div>
                  <div><span>{c('Kullanan doktor')}</span><b>{kullanim.doktorSayisi}</b></div>
                </div>
                <div className="kagrup">
                  <h6>{c('Doktora göre (30 gün)')}</h6>
                  <div className="ms-cubuklar">
                    {kullanim.doktorlar.length === 0 && <span className="sonuk">{c('Son 30 günde kullanılmadı.')}</span>}
                    {kullanim.doktorlar.map(x => {
                      const en = Math.max(...kullanim.doktorlar.map(y => y.adet), 1);
                      return (
                        <div key={x.ad} className="ms-cubuk">
                          <span>{x.ad}</span><i style={{ width: `${Math.round(x.adet / en * 100)}%` }} /><b>{x.adet}</b>
                        </div>
                      );
                    })}
                  </div>
                </div>
                <div className="kagrup">
                  <h6>{c('Son kullanımlar')}</h6>
                  <table className="detay-tablo">
                    <thead><tr><th>{c('Tarih')}</th><th>{c('Hasta')}</th><th>{c('Doktor')}</th></tr></thead>
                    <tbody>
                      {kullanim.son.length === 0 && <tr><td colSpan={3} className="bos">{c('Kullanım yok.')}</td></tr>}
                      {kullanim.son.map(s => (
                        <tr key={s.muayeneId}><td>{zaman(s.tarih)}</td><td>{s.hasta}</td><td>{s.doktor}</td></tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )
          )}

          {sekme === 'Geçmiş' && (
            kayitId === null ? <p className="not">{c('Kaydedilince değişiklik kaydı görünür.')}</p>
            : !gecmis ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
              <div className="kagrup">
                <h6>{c('Değişiklikler')}</h6>
                {gecmis.length === 0 ? <p className="not ms-ic">{c('Kayıt yok.')}</p> : (
                  <ul className="ms-log">
                    {gecmis.map((g, i) => (
                      <li key={i}>
                        <span className="sonuk">{zaman(g.tarih)}</span>
                        <span><b>{g.kullanici || '—'}</b> — {g.bolum ? c(g.bolum) : g.alan ? c('alan') : c('şablon')}{' '}
                          {g.islemTipi === 1 ? c('eklendi') : g.islemTipi === 3 ? c('silindi') : c('değişti')}</span>
                      </li>
                    ))}
                  </ul>
                )}
                <div className="rk-bant mavi ms-bant">
                  {c('Şablon değişikliği geçmiş muayeneleri değiştirmez: muayene, uygulandığı andaki bulgularını saklar.')}
                </div>
              </div>
            )
          )}
        </div>
      )}
      {arama === 'icd' && (
        <KaynakArama kaynak="icd" baslik={c('Sık tanı ekle — ICD-10')} acikKalir
                     ekKosul={{ alan: 'aktif', op: 'esit', deger: 1 }}
                     onSec={r => aramadanEkle(r)} onKapat={() => setArama(null)} />
      )}
      {arama === 'ilac' && (
        <KaynakArama kaynak="ilac" baslik={`${c('İlaç ekle')} — ${receteGrup.trim() || c('Genel')}`} acikKalir
                     kodAlani="barkod" adAlani="ad" ekKosul={{ alan: 'aktif', op: 'esit', deger: 1 }}
                     onSec={r => aramadanEkle(r)} onKapat={() => setArama(null)} />
      )}
    </Modal>
  );
}
