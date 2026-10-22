import { Fragment, useEffect, useMemo, useRef, useState } from 'react';
import { c } from '../../dil/ceviri';
import { usePaletKomutlari } from './paletKomutlari';
import { api } from '../../api/istemci';
import type { MenuSatiri } from './menuAgaci';
import { useSesliGiris, PALET_SESLI_OLAYI } from '../../bilesenler/sesliGiris';
import { MikrofonIkon } from '../../bilesenler/MikrofonIkon';
import { telefonBicimle } from '../../bilesenler/bicim';
import { mesaj } from '../../bilesenler/mesaj';

/**
 * KOMUT PALETİ (790) — üst şeritteki "Ara ya da komut yaz…" kutusunun karşılığı.
 *
 * Kullanıcı: *"en üstteki ara ya da komut yaz editini şu anki menü ve ekran
 * adlarına göre yapılandır.. oradan kısa yoldan ulaşabileyim"*.
 *
 * <b>Kaynak menünün KENDİSİ:</b> liste sol menüyü çizen `menuSatirlariKur`
 * çıktısından gelir - ekran adları, grup adları, yetki ve kapalı modül
 * süzgeci neyse palet de odur. Ayrı bir "komut listesi" tutmak, menü
 * değiştikçe sessizce eskiyen ikinci bir katalog demekti: olmayan ekrana
 * götüren ya da yeni ekranı hiç bilmeyen bir arama kutusu.
 *
 * <b>Her sayfada aynı yerde:</b> palet eskiden `GenGrid` içindeydi ve yalnız
 * liste ekranlarında açılıyordu; kartta, panoda, özel sayfada üstteki kutuya
 * basmak hiçbir şey yapmıyordu. Artık kabukta duruyor, açık ekranın
 * düğmelerini de `paletKomutlari` deposundan okuyor.
 *
 * <b>Boş aramada kısa yol:</b> önce favoriler, sonra en son kullanılanlar -
 * "kısa yoldan ulaşabileyim" isteğinin karşılığı iki tuş (Ctrl+K, Enter).
 */

/** Türkçe duyarsız arama metni: "İstem" yazan "istem"i bulsun. */
const TR_HARF = 'çğıöşüâîû';
const ASCII_HARF = 'cgiosuaiu';
export function paletSadelestir(metin: string) {
  let sonuc = '';
  for (const h of metin.toLocaleLowerCase('tr')) {
    const i = TR_HARF.indexOf(h);
    sonuc += i >= 0 ? ASCII_HARF[i] : h;
  }
  return sonuc;
}

export interface PaletEkrani { yol: string; ad: string; grup: string;
  /** İŞLEM (ekran değil, bir iş başlatır: "＋ Yeni Hasta Kartı"): "İşlemler" bölümünde durur. */
  islem?: boolean;
  /** Satırın sol ikonu (verilmezse ekran ↗, işlem ＋). */
  ikon?: string;
  /** İşlemin listesi: boş palette yalnız son açılan / favori listelerin işlemleri görünür. */
  listeYol?: string;
  /** Boş palette hep görünür (Yeni / Kayıtlı Hasta ve Başvuru Kartı). */
  sabit?: boolean }

/** Menü satırlarını düz "ekran" listesine indirger (grup adı yol olarak kalır). */
export function paletEkranlari(satirlar: MenuSatiri[]): PaletEkrani[] {
  const liste: PaletEkrani[] = [];
  for (const sat of satirlar) {
    if (sat.tur === 'duz') { liste.push({ yol: sat.m.yol, ad: sat.m.ad, grup: '' }); continue }
    for (const m of sat.alt)
      liste.push({
        yol: m.yol, ad: m.ad,
        grup: [sat.ad, m.altGrup].filter(Boolean).join(' › '),
      });
  }
  // Aynı ekran iki grupta görünebilir (favori kopyası gibi): ilk kayıt kalır.
  return liste.filter((e, i) => liste.findIndex(x => x.yol === e.yol) === i);
}

/**
 * Eşleşme puanı (küçük önce), eşleşmiyorsa `null`.
 *
 * ADIN BAŞI en değerli: "has" yazan Hasta Listesi'ni bekler, "Randevu
 * Hatırlatma"yı değil. Sorgudaki her kelime ayrı ayrı tutmalı ("kasa isl"),
 * yoksa iki kelime yazan kullanıcı sonucu kaybeder.
 */
export function paletPuan(ad: string, grup: string, sorgu: string): number | null {
  const kelimeler = paletSadelestir(sorgu).split(/\s+/).filter(Boolean);
  if (kelimeler.length === 0) return 0;
  const sadeAd = paletSadelestir(ad);
  const sadeHepsi = sadeAd + ' ' + paletSadelestir(grup);
  let puan = 0;
  for (const k of kelimeler) {
    if (sadeAd.startsWith(k)) { puan += 0; continue }
    if (sadeAd.split(/[\s(/-]+/).some(p => p.startsWith(k))) { puan += 1; continue }
    if (sadeAd.includes(k)) { puan += 2; continue }
    if (sadeHepsi.includes(k)) { puan += 3; continue }
    return null;                       // bir kelime hiç tutmadıysa eşleşme yok
  }
  return puan;
}

interface Props {
  satirlar: MenuSatiri[];
  favoriler: string[];
  sonMenuler: string[];
  acik: boolean;
  onKapat(): void;
  onAc(): void;
  git(yol: string): void;
  /** Menüde olmayan ama aranabilen ekranlar (1103: gösterge panelleri, "gösterge" yazınca). */
  ekEkranlar?: PaletEkrani[];
  /** Ekran açılma sayıları (yol -> adet): eşit eşleşmede sık açılan önce. */
  ekranSayac?: Record<string, number>;
}

/** Hızlı bul türü -> kart yolu, ikon ve kartın liste rotası (menüde yoksa kullanıcı açamaz). */
const KAYIT_YOLU: Record<string, { yol: (id: number) => string; liste: string; ikon: string }> = {
  hasta:   { yol: id => `/hasta/${id}`,     liste: '/hasta',     ikon: '🧑' },
  basvuru: { yol: id => `/basvuru/${id}`,   liste: '/basvuru',   ikon: '📝' },
  muayene: { yol: id => `/muayene/${id}`,   liste: '/muayene',   ikon: '🩺' },
  rapor:   { yol: id => `/muayene/${id}`,   liste: '/muayene',   ikon: '📄' },
  recete:  { yol: id => `/recete/${id}`,    liste: '/recete',    ikon: '💊' },
  lab:     { yol: id => `/lab-istem/${id}`, liste: '/lab-istem', ikon: '🧪' },
  randevu: { yol: id => `/randevu/${id}`,   liste: '/randevu',   ikon: '📅' },
};

/**
 * CÜMLE KOMUTU (kullanıcı 19.10.2026: "'Ercan Temel hasta kartı aç' deyince açsın.. en son gelen",
 * "'Ercan Temel başvuru kartı aç' veya randevu kartı aç da diyebilirim", "hep o modülle ilgili son
 * işlemi getirmeli"). Yazılan ya da mikrofonla söylenen "<ad soyad> <modül> [kartı] [aç]" tanınır;
 * sunucu hastanın o modüldeki EN SON kaydını verir (/api/hizli-bul/son). Sonuç "Kayıtlar"ın en üstünde.
 */
const CUMLE_MODUL: Record<string, { modul: string; ad: string }> = {
  hasta: { modul: 'hasta', ad: 'hasta kartı' },
  basvuru: { modul: 'basvuru', ad: 'son başvuru' }, kabul: { modul: 'basvuru', ad: 'son başvuru' },
  randevu: { modul: 'randevu', ad: 'son randevu' },
  muayene: { modul: 'muayene', ad: 'son muayene' },
  recete: { modul: 'recete', ad: 'son reçete' },
  lab: { modul: 'lab', ad: 'son lab istemi' }, laboratuvar: { modul: 'lab', ad: 'son lab istemi' },
  tahlil: { modul: 'lab', ad: 'son lab istemi' },
};
/** "ercan temel başvuru kartı aç" -> { ad: 'ercan temel', modul: 'basvuru' }; kalıp değilse null. */
export function cumleCoz(metin: string): { ad: string; modul: string; modulAd: string } | null {
  const sade = metin.toLocaleLowerCase('tr').replace(/[.!?,]+$/g, '').trim()
    .replace(/ş/g, 's').replace(/ç/g, 'c').replace(/ğ/g, 'g').replace(/ü/g, 'u').replace(/ö/g, 'o').replace(/ı/g, 'i');
  // KISALTMA (kullanıcı 19.10.2026: "erhan savaş ran aç da diyebilirim"): modül sözcüğünün en az ilk
  //   3 harfi yeter - ran, baş, mua, reç, has, tah; "lab" zaten tam.
  const e = /^(.+?)\s+([a-z]{3,})(?:\s+kart\S*)?(?:\s+(?:ac|goster|getir))?$/.exec(sade);
  if (!e) return null;
  const ad = e[1].trim();
  if (ad.replace(/\s/g, '').length < 3) return null;
  const anahtar = Object.keys(CUMLE_MODUL).find(k => k.startsWith(e[2]));
  if (!anahtar) return null;
  const m = CUMLE_MODUL[anahtar];
  // Ad orijinal yazımıyla gider (sunucu fn_ara_metin ile eşleştirir): ilk N kelime.
  const kelime = ad.split(/\s+/).length;
  return { ad: metin.trim().split(/\s+/).slice(0, kelime).join(' '), modul: m.modul, modulAd: m.ad };
}

/**
 * KİMLİK / TELEFON NİYETİ (kullanıcı 22.10.2026: "ctrl k aramada kimlikno/telno verip yeni hasta/yeni
 * başvuru/yeni personel diyebilirim yoksa yeni kart oluşturmalı"). "12345678901 yeni hasta",
 * "0532 444 55 66 yeni personel", "5354441122 başvuru": numara TC (11 hane, 0'la başlamaz) ya da cep
 * telefonu (5xx - 10 hane; 0 / 90 önekli de olur). Niyet sözcüğünün ilk 3 harfi yeter (has, baş / kab,
 * per); "yeni" isteğe bağlı. Niyet yoksa üçü birden önerilir. Kayıtlı ise kart / yeni başvuru, değilse
 * yeni kart TC / telefonu dolu açılır.
 */
export type KimlikNiyeti = 'hasta' | 'basvuru' | 'personel';
export function kimlikNiyetCoz(metin: string): { rakam: string; tur: 'tc' | 'tel'; niyet: KimlikNiyeti | null } | null {
  const n = /[+\d][\d\s().-]{8,}\d/.exec(metin);
  if (!n) return null;
  const rakam = n[0].replace(/\D/g, '');
  const tc = rakam.length === 11 && rakam[0] !== '0';
  const tel = !tc && ((rakam.length === 10 && rakam[0] === '5') || (rakam.length === 11 && rakam.startsWith('05'))
                      || (rakam.length === 12 && rakam.startsWith('905')));
  if (!tc && !tel) return null;
  const kalan = paletSadelestir((metin.slice(0, n.index) + ' ' + metin.slice(n.index + n[0].length)).trim())
    .split(/\s+/).filter(k => k && k !== 'yeni' && !/^kart/.test(k) && k !== 'ac' && k !== 'olustur');
  let niyet: KimlikNiyeti | null = null;
  for (const k of kalan) {
    if (k.length < 3) return null;
    if ('hasta'.startsWith(k)) niyet = 'hasta';
    else if ('basvuru'.startsWith(k) || 'kabul'.startsWith(k)) niyet = 'basvuru';
    else if ('personel'.startsWith(k)) niyet = 'personel';
    else return null;     // tanınmayan sözcük: kimlik komutu değil (eski arama sürer)
  }
  return { rakam, tur: tc ? 'tc' : 'tel', niyet };
}

/** Palet BÖLÜMLERİ (mockup Ekranlar/Ayarlar/ana_ekran_sekmeli_v3.html): boşta Son açılanlar +
 *  İşlemler, aramada Ekranlar + İşlemler. Klavye sırası bölüm sırasıdır. */
type Bolum = 'Son açılanlar' | 'Kayıtlar' | 'Ekranlar' | 'İşlemler';
type Oge = { bolum: Bolum } & (
  | { tur: 'ekran'; anahtar: string; ad: string; grup: string; yol: string; islem?: boolean; ikon?: string;
      /** Kayıtlı hastaya YENİ BAŞVURU: açık başvurusu varsa o açılır (Liste.basvuruAc ile aynı kural). */
      basvuruTaraf?: { id: number; ad: string } }
  | { tur: 'komut'; anahtar: string; ad: string; grup: string; kod: string;
      aktif: boolean; kisayol?: string; pasifSebep?: string });

export function KomutPaleti({ satirlar, favoriler, sonMenuler, acik, onKapat, onAc, git, ekEkranlar, ekranSayac }: Props) {
  const [arama, setArama] = useState('');
  const [secili, setSecili] = useState(0);
  // MİKROFON (kullanıcı 17.10.2026): söylenen arama kutusuna yazılır, liste anında süzülür. Kanca
  //   erken `return`'den (palet kapalı) ÖNCE - kanca sırası her çizimde aynı kalmalı.
  const ses = useSesliGiris(metin => { setArama(metin); setSecili(0) });
  // Palet kapanınca mikrofon açık kalmasın.
  const { durdur: sesDurdur, baslat: sesBaslat } = ses;
  useEffect(() => { if (!acik) sesDurdur() }, [acik, sesDurdur]);
  // Ana sayfadaki 🎤: paleti aç ve hemen dinle.
  useEffect(() => {
    const sesli = () => { onAc(); sesBaslat() };
    window.addEventListener(PALET_SESLI_OLAYI, sesli);
    return () => window.removeEventListener(PALET_SESLI_OLAYI, sesli);
  }, [onAc, sesBaslat]);
  const kutu = useRef<HTMLInputElement>(null);
  const ekranKomutlari = usePaletKomutlari();

  useEffect(() => {
    const tus = (e: KeyboardEvent) => {
      // Ctrl+K bazı tarayıcılarda adres çubuğunu açıyor; F1 ve Ctrl+Shift+P yedek.
      const paletTusu =
        ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') ||
        ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key.toLowerCase() === 'p') ||
        e.key === 'F1';
      if (paletTusu) { e.preventDefault(); if (acik) onKapat(); else onAc() }
      else if (e.key === 'Escape' && acik) onKapat();
    };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  }, [acik, onAc, onKapat]);

  // Her açılışta temiz başla: önceki aramanın sonucu ekranda kalırsa kullanıcı
  //   onu yeni sorgunun cevabı sanıyor.
  useEffect(() => { if (acik) { setArama(''); setSecili(0) } }, [acik]);

  const ekranlar = useMemo(() => [...paletEkranlari(satirlar), ...(ekEkranlar ?? [])], [satirlar, ekEkranlar]);

  /**
   * KAYIT NUMARASIYLA AÇMA (kullanıcı 16.10.2026, hızlı erişim): rakam içeren ≥4 karakterlik arama
   * sunucuda dosya / TC / protokol / muayene / reçete / rapor / lab numarasına bakar; bulunan kayıt
   * "Kayıtlar" bölümünde en üstte - Enter kartı açar. Kartın listesi menüde yoksa (yetki) gösterilmez.
   */
  const [kayitlar, setKayitlar] = useState<Oge[]>([]);
  useEffect(() => {
    const q = arama.trim();
    if (!acik || q.length < 4 || !/\d/.test(q)) { setKayitlar([]); return }
    let iptal = false;
    const zaman = window.setTimeout(() => {
      void api.hizliBul(q).then(y => {
        if (iptal) return;
        const menude = new Set(ekranlar.map(e => e.yol.split('?')[0]));
        setKayitlar(y.sonuclar
          .filter(s => KAYIT_YOLU[s.tur] && menude.has(KAYIT_YOLU[s.tur].liste))
          .map<Oge>(s => ({ bolum: 'Kayıtlar', tur: 'ekran', anahtar: `r${s.tur}${s.id}:${s.altId}`, ad: s.ad || s.bilgi,
                            grup: s.bilgi, yol: KAYIT_YOLU[s.tur].yol(s.id), ikon: KAYIT_YOLU[s.tur].ikon })));
      }).catch(() => { if (!iptal) setKayitlar([]) });
    }, 250);
    return () => { iptal = true; window.clearTimeout(zaman) };
  }, [arama, acik, ekranlar]);

  const [cumleKaydi, setCumleKaydi] = useState<Oge[]>([]);
  useEffect(() => {
    // Numara + niyet ('11111111110 yeni hasta') cümle komutu değil - kimlik niyeti karşılar.
    const cz = acik && !kimlikNiyetCoz(arama) ? cumleCoz(arama) : null;
    if (!cz) { setCumleKaydi([]); return }
    let iptal = false;
    const zaman = window.setTimeout(() => {
      void api.hizliBulSon(cz.ad, cz.modul).then(s => {
        if (iptal) return;
        const menude = new Set(ekranlar.map(e => e.yol.split('?')[0]));
        setCumleKaydi(s && KAYIT_YOLU[s.tur] && menude.has(KAYIT_YOLU[s.tur].liste)
          ? [{ bolum: 'Kayıtlar', tur: 'ekran', anahtar: `c${s.tur}${s.id}`, ad: `${s.ad} — ${c(cz.modulAd)}`,
               grup: s.bilgi, yol: KAYIT_YOLU[s.tur].yol(s.id), ikon: KAYIT_YOLU[s.tur].ikon }]
          // BULUNAMADI da söylenir: kullanıcı (özellikle sesle) cümlenin anlaşıldığını görsün.
          : [{ bolum: 'Kayıtlar', tur: 'komut', anahtar: 'c-yok', ad: `${cz.ad}: ${c(cz.modulAd)} ${c('bulunamadı')}`,
               grup: '', kod: '', aktif: false }]);
      }).catch(h => {
        if (iptal) return;
        // YETKİ YOK (kullanıcı 19.10.2026): sunucu sorguyu hiç çalıştırmadan 403 verir - sessiz kalmak
        //   "cümle anlaşılmadı" sanılıyordu. Hasta adı / kayıt yine dönmez, yalnız neden söylenir.
        const durum = (h as { durum?: number })?.durum;
        setCumleKaydi(durum === 403
          ? [{ bolum: 'Kayıtlar', tur: 'komut', anahtar: 'c-yetki', ad: `${c(cz.modulAd)}: ${c('bu kayıt türüne yetkiniz yok')}`,
               grup: '', kod: '', aktif: false }]
          : []);
      });
    }, 250);
    return () => { iptal = true; window.clearTimeout(zaman) };
  }, [arama, acik, ekranlar]);

  const [kimlikOgeleri, setKimlikOgeleri] = useState<Oge[]>([]);
  useEffect(() => {
    const kz = acik ? kimlikNiyetCoz(arama) : null;
    if (!kz) { setKimlikOgeleri([]); return }
    let iptal = false;
    const zaman = window.setTimeout(() => {
      void api.hizliBulKimlik(kz.rakam).then(y => {
        if (iptal || !y.tur) return;
        const menude = new Set(ekranlar.map(e => e.yol.split('?')[0]));
        const etiket = y.tur === 'tc' ? `TC ${y.deger}` : `Tel ${telefonBicimle(y.deger)}`;
        // Yeni kart ön dolgusu: TC -> vkno, telefon -> cepTel (kartlar +90 biçimini okur).
        const dolgu = y.tur === 'tc' ? `vkno=${y.deger}` : `cepTel=${encodeURIComponent(telefonBicimle(y.deger))}`;
        const niyetler: KimlikNiyeti[] = kz.niyet ? [kz.niyet] : ['hasta', 'basvuru', 'personel'];
        const l: Oge[] = [];
        for (const n of niyetler) {
          if (n === 'personel') {
            if (!menude.has('/personel')) continue;
            if (y.personeller.length) y.personeller.forEach(p => l.push({ bolum: 'Kayıtlar', tur: 'ekran', anahtar: `kp${p.id}`,
              ad: `${p.ad} — ${c('personel kartı')}`, grup: `${p.bilgi} · ${etiket}`, yol: `/personel/${p.id}`, ikon: '👤' }));
            else l.push({ bolum: 'İşlemler', tur: 'ekran', anahtar: 'kp-yeni', ad: `${c('Yeni personel kartı')} — ${etiket}`,
              grup: c('kayıtlı personel yok'), yol: `/personel/yeni?${dolgu}`, islem: true, ikon: '👤' });
            continue;
          }
          if (!menude.has('/hasta')) continue;
          if (n === 'basvuru' && !menude.has('/basvuru')) continue;
          if (y.hastalar.length) y.hastalar.forEach(h => l.push(n === 'hasta'
            ? { bolum: 'Kayıtlar', tur: 'ekran', anahtar: `kh${h.id}`, ad: `${h.ad} — ${c('hasta kartı')}`,
                grup: `${h.bilgi} · ${etiket}`, yol: `/hasta/${h.id}`, ikon: '🧑' }
            : { bolum: 'Kayıtlar', tur: 'ekran', anahtar: `kb${h.id}`, ad: `${h.ad} — ${c('yeni başvuru')}`,
                grup: `${h.bilgi} · ${etiket}`, yol: `/basvuru/yeni?tarafId=${h.id}&tarafUnvan=${encodeURIComponent(h.ad)}`,
                ikon: '📝', basvuruTaraf: { id: h.id, ad: h.ad } }));
          else if (!l.some(o => o.anahtar === 'kh-yeni'))
            // Kayıtlı hasta yok: başvuru da önce hasta kartı ister - yeni hasta kartı numara dolu açılır.
            l.push({ bolum: 'İşlemler', tur: 'ekran', anahtar: 'kh-yeni',
              ad: `${c('Yeni hasta kartı')} — ${etiket}${n === 'basvuru' ? ` (${c('başvuru için')})` : ''}`,
              grup: c('kayıtlı hasta yok'), yol: `/hasta/yeni?${dolgu}`, islem: true, ikon: '🧑' });
        }
        setKimlikOgeleri(l);
      }).catch(() => { if (!iptal) setKimlikOgeleri([]) });
    }, 250);
    return () => { iptal = true; window.clearTimeout(zaman) };
  }, [arama, acik, ekranlar]);

  const gorunen = useMemo<Oge[]>(() => {
    const q = arama.trim();
    const komutlar = ekranKomutlari?.komutlar ?? [];

    if (q === '') {
      // BOŞ ARAMA = kısa yol listesi: favoriler, sonra son kullanılanlar,
      //   sonra bu ekranın düğmeleri. Tüm menüyü dökmek (100+ satır) aramadan
      //   önce hiçbir şey söylemiyor.
      const yolAdi = (yol: string) => ekranlar.find(e => e.yol === yol);
      const sirali = [...favoriler, ...sonMenuler.filter(y => !favoriler.includes(y))];
      const kisaYol = sirali
        .map(yolAdi)
        .filter((e): e is PaletEkrani => e !== undefined && !e.islem)
        .slice(0, 8)
        .map<Oge>(e => ({ bolum: 'Son açılanlar', tur: 'ekran', anahtar: 'e' + e.yol, ad: e.ad, grup: e.grup, yol: e.yol }));
      return [
        ...kisaYol,
        ...ekranlar.filter(e => e.islem && (e.sabit || (e.listeYol && sirali.includes(e.listeYol)))).map<Oge>(e => ({
          bolum: 'İşlemler', tur: 'ekran', anahtar: 'e' + e.yol, ad: e.ad, grup: e.grup, yol: e.yol, islem: true, ikon: e.ikon })),
        ...komutlar.map<Oge>(k => ({
          bolum: 'İşlemler', tur: 'komut', anahtar: 'k' + k.kod, ad: k.ad, grup: k.grup || c('Bu ekranda'),
          kod: k.kod, aktif: k.aktif, kisayol: k.kisayol, pasifSebep: k.pasifSebep,
        })),
      ];
    }

    const ekranEslesen = ekranlar
      .map((e, i) => ({ e, i, puan: paletPuan(e.ad, e.grup, q) }))
      .filter((x): x is { e: PaletEkrani; i: number; puan: number } => x.puan !== null)
      // ESIT PUANDA MENU SIRASI: "telerad" yazip Enter'a basan kullanici
      //   calisma listesini bekler, ayarlar ekranini degil - alfabetik sira
      //   "Telerad Kurumlari"ni one aliyordu. Menu sirasi isin onceligini
      //   zaten tasiyor (menuSira), palet de onu izlesin.
      // KULLANIMA GÖRE (16.10.2026): eşit puanda sık açılan ekran önce, sonra menü sırası.
      .sort((a, b) => a.puan - b.puan || (ekranSayac?.[b.e.yol] ?? 0) - (ekranSayac?.[a.e.yol] ?? 0) || a.i - b.i)
      .slice(0, 20)
      .map<Oge>(x => ({ bolum: x.e.islem ? 'İşlemler' : 'Ekranlar', tur: 'ekran', anahtar: 'e' + x.e.yol,
                         ad: x.e.ad, grup: x.e.grup, yol: x.e.yol, islem: x.e.islem, ikon: x.e.ikon }));

    const komutEslesen = komutlar
      .map(k => ({ k, puan: paletPuan(k.ad, k.grup, q) }))
      .filter((x): x is { k: typeof komutlar[number]; puan: number } => x.puan !== null)
      .sort((a, b) => a.puan - b.puan)
      .map<Oge>(x => ({
        bolum: 'İşlemler', tur: 'komut', anahtar: 'k' + x.k.kod, ad: x.k.ad, grup: x.k.grup || c('Bu ekranda'),
        kod: x.k.kod, aktif: x.k.aktif, kisayol: x.k.kisayol, pasifSebep: x.k.pasifSebep,
      }));

    // EKRAN ÖNCE: kutunun işi "şu ekrana git"; komut aynı ada sahipse altında kalsın.
    //   Bölüm sırası: Ekranlar, sonra İşlemler (eşleşen iş + komut).
    // KİMLİK NİYETİ ÖNCE (Enter onu çalıştırır); aynı hastayı numara araması da bulduysa ikinci kez çizilmez.
    const kimlikYollari = new Set(kimlikOgeleri.map(o => o.tur === 'ekran' ? o.yol : ''));
    return [...kimlikOgeleri, ...cumleKaydi, ...kayitlar.filter(o => !(o.tur === 'ekran' && kimlikYollari.has(o.yol))),
            ...ekranEslesen.filter(o => o.bolum === 'Ekranlar'),
            ...ekranEslesen.filter(o => o.bolum === 'İşlemler'), ...komutEslesen];
  }, [arama, ekranlar, ekranKomutlari, favoriler, sonMenuler, kayitlar, cumleKaydi, kimlikOgeleri, ekranSayac]);

  if (!acik) return null;

  const sec = (o: Oge) => {
    if (o.tur === 'ekran' && o.basvuruTaraf) {
      // AÇIK BAŞVURU VARSA O (Liste.basvuruAc ile aynı): tamamlanmamış en yeni başvuru açılır.
      const t = o.basvuruTaraf;
      onKapat();
      void api.liste('belge', {
        sayfa: 1, boyut: 1,
        sirala: [{ alan: 'belgeTarihi', yon: 'desc' }, { alan: 'id', yon: 'desc' }],
        filtre: { op: 'and', kosullar: [
          { alan: 'tarafId', op: 'esit', deger: t.id }, { alan: 'tur', op: 'esit', deger: 19 },
          { alan: 'tipi', op: 'esit', deger: 30 }, { alan: 'tamamlanma', op: 'kucuk', deger: 100 }] },
      }).then(y => {
        const acikId = Number(y.satirlar[0]?.id ?? 0);
        if (acikId) { mesaj(c('Bu hastanın kapanmamış başvurusu var - o başvuru açıldı.')); git(`/basvuru/${acikId}`) }
        else git(o.yol);
      }, () => git(o.yol));
      return;
    }
    if (o.tur === 'ekran') { git(o.yol); onKapat(); return }
    if (!o.aktif) return;
    ekranKomutlari?.calistir(o.kod);
    onKapat();
  };

  return (
    <>
      <div className="perde" onClick={onKapat} />
      <div className="palet" onKeyDown={e => {
        if (e.key === 'ArrowDown') { e.preventDefault(); setSecili(s => Math.min(s + 1, gorunen.length - 1)) }
        else if (e.key === 'ArrowUp') { e.preventDefault(); setSecili(s => Math.max(s - 1, 0)) }
        else if (e.key === 'Enter' && gorunen[secili]) { e.preventDefault(); sec(gorunen[secili]) }
      }}>
        <div className="palet-arama">
          <div className="palet-kutu">
          <input
            ref={kutu}
            autoFocus
            className="arama"
            placeholder={ses.dinliyor ? c('Dinliyorum… söyleyin') : c('Ekran, komut ya da numara ara (dosya / TC / protokol)… (Ctrl+K)')}
            value={arama}
            onChange={e => { setArama(e.target.value); setSecili(0) }}
          />
          {/* TEMİZLE kutunun İÇİNDE, sağda (kullanıcı 17.10.2026: "edit içinde sağda olsun x"). */}
          {arama && (
            <button type="button" className="palet-temizle" title={c('Aramayı temizle')}
                    onClick={() => { ses.durdur(); setArama(''); setSecili(0); kutu.current?.focus() }}>✕</button>
          )}
          </div>
          {ses.destek && (
            <button type="button" className={`palet-mik${ses.dinliyor ? ' acik' : ''}`}
                    title={ses.dinliyor ? c('Dinlemeyi durdur') : c('Sesle ara (konuşun, söylediğiniz yazılır)')}
                    aria-pressed={ses.dinliyor}
                    onClick={() => { if (ses.dinliyor) ses.durdur(); else { ses.baslat(); kutu.current?.focus() } }}>
              <MikrofonIkon />
            </button>
          )}
        </div>
        {ses.hata && <div className="palet-ses-hata">{c(ses.hata)}</div>}
        <div className="palet-liste">
          {gorunen.map((o, i) => (<Fragment key={o.anahtar}>
            {(i === 0 || gorunen[i - 1].bolum !== o.bolum) && <div className="palet-bolum">{c(o.bolum)}</div>}
            <button
              className={i === secili ? 'secili' : ''}
              disabled={o.tur === 'komut' && !o.aktif}
              onMouseEnter={() => setSecili(i)}
              onClick={() => sec(o)}
            >
              {/* Ekran mı komut mu: ok işareti "gider", şimşek "çalıştırır". */}
              <span className={`palet-tur${o.tur === 'ekran' && o.islem && !o.ikon ? ' palet-yeni' : ''}`}>
                {o.tur === 'ekran' ? (o.ikon ?? (o.islem ? '＋' : '↗')) : '⚡'}</span>
              <span>{c(o.ad)}</span>
              <span className="grup">{o.grup}</span>
              {o.tur === 'komut' && o.kisayol && <span className="kisayol">{o.kisayol}</span>}
              {o.tur === 'komut' && !o.aktif && o.pasifSebep &&
                <span className="pasif-sebep">{o.pasifSebep}</span>}
            </button>
          </Fragment>))}
          {gorunen.length === 0 && (
            <div className="bos">
              {arama.trim() === ''
                ? c('Ekran adı yazın: “hasta”, “kasa”, “randevu”…')
                : c('Eşleşen ekran ya da komut yok')}
            </div>
          )}
        </div>
      </div>
    </>
  );
}
