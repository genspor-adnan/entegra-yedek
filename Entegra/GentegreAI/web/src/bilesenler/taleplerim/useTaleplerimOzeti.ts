import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import type { IzinBakiyesi, OnayBekleyenSatiri, TaleplerimYaniti, TalepSatiri } from '../../api/uclar/izin';
import type { ArizaGelen } from '../../api/uclar/ariza';
import type { IskontoTalebi } from '../../api/sozlesme';
import type { DuyuruSatiri } from '../../api/uclar/duyuru';
import { useOturum } from '../../kimlik/OturumBaglami';
import { para } from '../bicim';
import { masaustuBildir } from '../bildirimTercihi';

/**
 * TALEPLERİM ÖZETİ - üst şerit 📨 paneli, avatar menüsü ve Taleplerim
 * sayfası aynı veriyi okur (mockup Ekranlar/Taleplerim/taleplerim.html).
 *
 * YENİ HAREKET (yeşil nokta): kişinin KENDİ talebinde başkasının yaptığı
 * bir değişiklik - onaylandı, reddedildi, hazırlandı. "Son bakış" tarayıcıda
 * kullanıcıya özel saklanır; panel ya da sayfa açılınca güncellenir.
 * Kendi açtığı talep (ekleme ≈ son hareket) yeni sayılmaz.
 */
export const TALEPLER_YENILE = 'gentegre:talepler-yenile';

/** Talep açan/çeken her ekran bunu çağırır: rozet ve panel hemen tazelenir. */
export const talepleriYenile = () => window.dispatchEvent(new Event(TALEPLER_YENILE));

const sonBakisAnahtari = (id: number) => `gentegre.taleplerim.sonBakis.${id}`;

function sonBakisOku(id: number): number {
  try { return Number(localStorage.getItem(sonBakisAnahtari(id))) || 0 } catch { return 0 }
}

/** Başkasının hareketi: son hareket eklemeden en az 5 sn sonra. */
export const baskaHareketi = (s: TalepSatiri) =>
  new Date(s.sonHareket).getTime() - new Date(s.eklemeTarihi).getTime() > 5000;

/**
 * ANLIK BİLDİRİM (gelen_talepler mockup): yeni iş açık ekranın üstüne düşer.
 *  • ariza   - ekibime yeni arıza (acil: kırmızı, kendiliğinden kapanmaz, ses)
 *  • onay    - onayıma yeni talep
 *  • sonuc   - kendi talebimde gelişme (çözüldüyse Evet / Düzelmedi ile)
 * İlk okuma TABAN: sayfa açılınca elde zaten olanlar bildirim olarak düşmez.
 */
export interface TalepBildirimi {
  anahtar: string;
  tur: 'ariza' | 'onay' | 'sonuc' | 'iskonto' | 'duyuru';
  acil: boolean;
  zaman: number;
  ariza?: ArizaGelen;
  onay?: OnayBekleyenSatiri;
  satir?: TalepSatiri;
  iskonto?: IskontoTalebi;
  duyuru?: DuyuruSatiri;
}

/** 20 sn: "anında"ya yakın, sunucuyu yormayacak kadar seyrek. */
const YOKLAMA_MS = 20000;

/** Acil iş sesi - dosya yok, WebAudio ile iki kısa bip. */
export function acilSes() {
  try {
    const Ctx = window.AudioContext ?? (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
    const ses = new Ctx();
    [0, 0.25].forEach(t => {
      const o = ses.createOscillator(); const g = ses.createGain();
      o.frequency.value = 880; g.gain.value = 0.15;
      o.connect(g); g.connect(ses.destination);
      o.start(ses.currentTime + t); o.stop(ses.currentTime + t + 0.15);
    });
    setTimeout(() => void ses.close(), 800);
  } catch { /* ses yoksa bildirim yine görünür */ }
}

export function useTaleplerimOzeti(kullaniciId: number | undefined) {
  const [veri, setVeri] = useState<TaleplerimYaniti | null>(null);
  const [gelen, setGelen] = useState<ArizaGelen[]>([]);
  // İSKONTO ONAYI (zil, 662): tavanı olan kişide "Bana gelenler"e de düşer.
  //   Liste sunucuda tavana göre süzülü gelir.
  const { aksiyonDegeri } = useOturum();
  const iskontoTavan = aksiyonDegeri('basvuru.iskonto');
  const [iskontolar, setIskontolar] = useState<IskontoTalebi[]>([]);
  // DUYURULAR (957): zil > Duyurular sekmesi.
  const [duyurular, setDuyurular] = useState<DuyuruSatiri[]>([]);
  const [ekip, setEkip] = useState(false);
  const [bildirimler, setBildirimler] = useState<TalepBildirimi[]>([]);
  /** Panel son açıldıktan sonra yeni iş geldi: rozet nabız atar. */
  const [nabiz, setNabiz] = useState(false);
  const taban = useRef<{ ariza: Set<number>; onay: Set<string>; satir: Map<string, string>; iskonto: Set<number>; duyuru: Map<number, number> } | null>(null);
  const [bakiye, setBakiye] = useState<IzinBakiyesi | null>(null);
  const [sonBakis, setSonBakis] = useState(() => kullaniciId ? sonBakisOku(kullaniciId) : 0);

  const yukle = useCallback(async () => {
    if (!kullaniciId) return;
    try {
      const [y, g, isk, dy] = await Promise.all([
        api.taleplerim(),
        api.arizaGelen().catch(() => ({ ekip: false, satirlar: [] as ArizaGelen[] })),
        iskontoTavan > 0 ? api.iskontoBekleyenler().catch(() => [] as IskontoTalebi[]) : Promise.resolve([] as IskontoTalebi[]),
        api.duyuruBenim().then(x => x.satirlar).catch(() => [] as DuyuruSatiri[]),
      ]);
      // İskonto zinciri onay omurgasında da (1256) görünür - aynı iş iki kez çizilmesin.
      if (isk.length) y.onaylar = (y.onaylar ?? []).filter(o => o.kaynakTur !== 1256);
      setVeri(y); setGelen(g.satirlar); setEkip(g.ekip); setIskontolar(isk); setDuyurular(dy);

      // FARK → anlık bildirim (ilk okumada yalnız taban kurulur).
      const once = taban.current;
      const yeni: TalepBildirimi[] = [];
      const simdi = Date.now();
      if (once) {
        for (const a of g.satirlar)
          if (!once.ariza.has(a.id) && !a.benim)
            yeni.push({ anahtar: `a${a.id}`, tur: 'ariza', acil: a.oncelik === 4, zaman: simdi, ariza: a });
        // YENİ / GÜNCELLENEN DUYURU: yalnız Önemli ve Kritik ekrana düşer; Bilgi zilde bekler.
        for (const d of dy)
          if (d.onem >= 2 && d.yeni && once.duyuru.get(d.id) !== d.surum)
            yeni.push({ anahtar: `d${d.id}-${d.surum}`, tur: 'duyuru', acil: d.onem === 3, zaman: simdi, duyuru: d });
        for (const t of isk)
          if (!once.iskonto.has(t.id))
            yeni.push({ anahtar: `i${t.id}`, tur: 'iskonto', acil: false, zaman: simdi, iskonto: t });
        for (const o of y.onaylar ?? [])
          if (!once.onay.has(`${o.kaynakTur}-${o.kaynakId}`))
            yeni.push({ anahtar: `o${o.kaynakTur}-${o.kaynakId}`, tur: 'onay', acil: false, zaman: simdi, onay: o });
        for (const st of y.satirlar) {
          const k = `${st.tur}-${st.id}`;
          const eski = once.satir.get(k);
          if (eski !== undefined && eski !== st.sonHareket && st.grup !== 'taslak' && st.sonDegistiren !== kullaniciId)
            yeni.push({ anahtar: `s${k}-${st.sonHareket}`, tur: 'sonuc', acil: false, zaman: simdi, satir: st });
        }
      }
      taban.current = {
        ariza: new Set(g.satirlar.map(a => a.id)),
        onay: new Set((y.onaylar ?? []).map(o => `${o.kaynakTur}-${o.kaynakId}`)),
        satir: new Map(y.satirlar.map(st => [`${st.tur}-${st.id}`, st.sonHareket])),
        iskonto: new Set(isk.map(t => t.id)),
        duyuru: new Map(dy.map(d => [d.id, d.surum])),
      };
      if (yeni.length) {
        setBildirimler(l => [...yeni, ...l.filter(b => !yeni.some(n => n.anahtar === b.anahtar))].slice(0, 5));
        if (yeni.some(b => b.tur !== 'sonuc' && b.tur !== 'duyuru')) setNabiz(true);
        if (yeni.some(b => b.acil)) acilSes();
        for (const b of yeni) {
          if (b.ariza) masaustuBildir('talep.gelen', `${b.acil ? '🚨 Acil arıza' : 'Yeni arıza'} — ${b.ariza.ekipAdi}`,
            `${b.ariza.talepNo} · ${b.ariza.aciklama} · ${b.ariza.konum}`);
          else if (b.onay) masaustuBildir('talep.gelen', 'Onayınızı bekliyor', `${b.onay.konu} · ${b.onay.talepEden}`);
          else if (b.duyuru) masaustuBildir('duyuru', `📣 ${b.duyuru.baslik}`, `${b.duyuru.adina} · ${b.duyuru.ozet}`);
          else if (b.iskonto) masaustuBildir('iskonto', 'İskonto onayı bekliyor', `${b.iskonto.hasta} · %${b.iskonto.oran} · ${para.format(b.iskonto.tutar)}`);
          else if (b.satir) masaustuBildir('talep.sonuc', `${b.satir.baslik}: ${b.satir.durumAdi}`, b.satir.detay);
        }
      }
      // Bakiye yalnız personelde: personel kartı yoksa izin hakkı da yok.
      if (y.personel) setBakiye(await api.izinBakiye(y.tarafId).catch(() => null));
    } catch { /* rozet bir uyarı işareti - okunamazsa sessiz kalır */ }
  }, [kullaniciId, iskontoTavan]);

  useEffect(() => {
    if (!kullaniciId) return;
    setSonBakis(sonBakisOku(kullaniciId));
    void yukle();
    const z = window.setInterval(() => void yukle(), YOKLAMA_MS);
    const dinle = () => void yukle();
    window.addEventListener(TALEPLER_YENILE, dinle);
    return () => { window.clearInterval(z); window.removeEventListener(TALEPLER_YENILE, dinle) };
  }, [kullaniciId, yukle]);

  const yeniler = useMemo(() => (veri?.satirlar ?? []).filter(s =>
    new Date(s.sonHareket).getTime() > sonBakis && baskaHareketi(s) && s.sonDegistiren !== kullaniciId
    && s.grup !== 'taslak' && s.grup !== 'onayda'), [veri, sonBakis]);

  /**
   * Görüldü: panel KAPANIRKEN / sayfadan çıkarken çağrılır. Açıkken
   * çağrılsaydı yeni satırların vurgusu kullanıcı okumadan sönerdi.
   */
  const gorulduIsaretle = useCallback(() => {
    if (!kullaniciId) return;
    const simdi = Date.now();
    try { localStorage.setItem(sonBakisAnahtari(kullaniciId), String(simdi)) } catch { /* yoksa her açılışta yeni görünür */ }
    setSonBakis(simdi);
  }, [kullaniciId]);

  const acik = (veri?.satirlar ?? []).filter(s => s.grup === 'taslak' || s.grup === 'onayda' || s.grup === 'acik');

  const bildirimKapat = useCallback((anahtar: string) =>
    setBildirimler(l => l.filter(b => b.anahtar !== anahtar)), []);
  const nabziSondur = useCallback(() => setNabiz(false), []);

  /** İşlem bekleyen: atanmamış + bende arıza + onayımı bekleyen. */
  const islemBekleyen = gelen.length + (veri?.onaylar?.length ?? 0) + iskontolar.length;
  /** Zilin mavi rozeti: okunmamış (ya da güncellenmiş) duyuru. */
  const duyuruYeni = duyurular.filter(d => d.yeni).length;
  /** Girişte tam ekran: okunmamış KRİTİK duyuru (okuma onayı verilene kadar). */
  const kritikBekleyen = duyurular.filter(d => d.onem === 3 && (!d.okudu || d.eskiSurumOkundu));

  return { veri, bakiye, yeniler, acik, yukle, gorulduIsaretle, gelen, ekip, islemBekleyen, iskontolar, iskontoTavan,
           duyurular, duyuruYeni, kritikBekleyen,
           bildirimler, bildirimKapat, nabiz, nabziSondur };
}

export type TaleplerimOzeti = ReturnType<typeof useTaleplerimOzeti>;

export const TUR_IKON: Record<TalepSatiri['tur'], string> = {
  izin: '✈️', avans: '💸', masraf: '🧾', belge: '📄', ariza: '🧰', malzeme: '📥',
};

export const TUR_AD: Record<TalepSatiri['tur'], string> = {
  izin: 'İzin', avans: 'Avans', masraf: 'Masraf', belge: 'Belge', ariza: 'Arıza', malzeme: 'Malzeme',
};

/** Durum çipinin rengi - grup bazlı. */
export const GRUP_SINIF: Record<TalepSatiri['grup'], string> = {
  taslak: 'tl-c-gri', onayda: 'tl-c-bek', acik: 'tl-c-mavi', tamam: 'tl-c-ok', red: 'tl-c-red', iptal: 'tl-c-gri',
};

/** Gün sayısı Türkçe ondalıkla: 13 · 0,5 */
export const gunYaz = (g: number) => String(Math.round(g * 10) / 10).replace('.', ',');
