import { useEffect, useMemo, useRef, useState } from 'react';
import { c } from '../../dil/ceviri';
import { usePaletKomutlari } from './paletKomutlari';
import type { MenuSatiri } from './menuAgaci';

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

export interface PaletEkrani { yol: string; ad: string; grup: string }

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
}

type Oge =
  | { tur: 'ekran'; anahtar: string; ad: string; grup: string; yol: string }
  | { tur: 'komut'; anahtar: string; ad: string; grup: string; kod: string;
      aktif: boolean; kisayol?: string; pasifSebep?: string };

export function KomutPaleti({ satirlar, favoriler, sonMenuler, acik, onKapat, onAc, git }: Props) {
  const [arama, setArama] = useState('');
  const [secili, setSecili] = useState(0);
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

  const ekranlar = useMemo(() => paletEkranlari(satirlar), [satirlar]);

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
        .filter((e): e is PaletEkrani => e !== undefined)
        .slice(0, 8)
        .map<Oge>(e => ({ tur: 'ekran', anahtar: 'e' + e.yol, ad: e.ad, grup: e.grup, yol: e.yol }));
      return [
        ...kisaYol,
        ...komutlar.map<Oge>(k => ({
          tur: 'komut', anahtar: 'k' + k.kod, ad: k.ad, grup: k.grup || c('Bu ekranda'),
          kod: k.kod, aktif: k.aktif, kisayol: k.kisayol, pasifSebep: k.pasifSebep,
        })),
      ];
    }

    const ekranEslesen = ekranlar
      .map(e => ({ e, puan: paletPuan(e.ad, e.grup, q) }))
      .filter((x): x is { e: PaletEkrani; puan: number } => x.puan !== null)
      .sort((a, b) => a.puan - b.puan || a.e.ad.localeCompare(b.e.ad, 'tr'))
      .slice(0, 20)
      .map<Oge>(x => ({ tur: 'ekran', anahtar: 'e' + x.e.yol, ad: x.e.ad, grup: x.e.grup, yol: x.e.yol }));

    const komutEslesen = komutlar
      .map(k => ({ k, puan: paletPuan(k.ad, k.grup, q) }))
      .filter((x): x is { k: typeof komutlar[number]; puan: number } => x.puan !== null)
      .sort((a, b) => a.puan - b.puan)
      .map<Oge>(x => ({
        tur: 'komut', anahtar: 'k' + x.k.kod, ad: x.k.ad, grup: x.k.grup || c('Bu ekranda'),
        kod: x.k.kod, aktif: x.k.aktif, kisayol: x.k.kisayol, pasifSebep: x.k.pasifSebep,
      }));

    // EKRAN ÖNCE: kutunun işi "şu ekrana git"; komut aynı ada sahipse altında kalsın.
    return [...ekranEslesen, ...komutEslesen];
  }, [arama, ekranlar, ekranKomutlari, favoriler, sonMenuler]);

  if (!acik) return null;

  const sec = (o: Oge) => {
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
        <input
          ref={kutu}
          autoFocus
          className="arama"
          placeholder={c('Ekran ya da komut ara… (Ctrl+K)')}
          value={arama}
          onChange={e => { setArama(e.target.value); setSecili(0) }}
        />
        <div className="palet-liste">
          {gorunen.map((o, i) => (
            <button
              key={o.anahtar}
              className={i === secili ? 'secili' : ''}
              disabled={o.tur === 'komut' && !o.aktif}
              onMouseEnter={() => setSecili(i)}
              onClick={() => sec(o)}
            >
              {/* Ekran mı komut mu: ok işareti "gider", şimşek "çalıştırır". */}
              <span className="palet-tur">{o.tur === 'ekran' ? '↗' : '⚡'}</span>
              <span>{c(o.ad)}</span>
              <span className="grup">{o.grup}</span>
              {o.tur === 'komut' && o.kisayol && <span className="kisayol">{o.kisayol}</span>}
              {o.tur === 'komut' && !o.aktif && o.pasifSebep &&
                <span className="pasif-sebep">{o.pasifSebep}</span>}
            </button>
          ))}
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
