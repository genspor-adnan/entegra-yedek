import type { KeyboardEvent } from 'react';
import { api } from '../api/istemci';

/**
 * Alanda geçerli makrolar; aynı kısayolun geneli, alana özeli varken gizlenir.
 * SIRA (kullanıcı: "ipucu çiplerini kullanım sayısına göre sırala"): çok
 * kullanılan önce; eşitlikte alana özel, sonra kısayol. Sayı sayfa açılırken
 * okunur - tıklanınca çip YER DEĞİŞTİRMEZ (imleç altından kaymasın), yeni sıra
 * kart tazelenince gelir.
 */
export function alanMakrolari(alan: string, makrolar: readonly Makro[]): Makro[] {
  const ozel = makrolar.filter(x => x.alan === alan);
  const genel = makrolar.filter(x => x.alan === '' && !ozel.some(o => o.kisayol === x.kisayol));
  return [...ozel, ...genel].sort((a, b) =>
    (b.kullanim ?? 0) - (a.kullanim ?? 0)
    || Number(a.alan === '') - Number(b.alan === '')
    || a.kisayol.localeCompare(b.kisayol, 'tr'));
}

/**
 * METİN MAKROSU (411 + 931, kullanıcı: "makroları alanlara bağla"): muayene
 * alanında kısayol yazılıp BOŞLUK (ya da Tab) basılınca kısayol metne açılır.
 *
 * Makrolar sunucudan gelir (`/api/muayene-sablon/muayene/{id}/tercihler`):
 * bölüm/doktor şablonlarınınkiler + kurum makroları, çakışmada şablonunki.
 * Makronun `alan`ı boşsa her alanda, doluysa yalnız o alanda geçerlidir;
 * aynı kısayolun alana özel olanı genel olanından önce gelir.
 */
export interface Makro { kisayol: string; alan: string; metin: string; kaynak?: 's' | 'k'; id?: number;
                         kullanim?: number }

/**
 * KULLANIM SAYACI (932, kullanıcı: "makro çipine tıklayınca makro kullanım
 * sayısı artsın"): makro alana yazılınca (çip ya da kısayol) sunucu sayacı
 * artırır. Sessiz: sayaç yazılamazsa hekimin yazdığı metin etkilenmez.
 */
export function makroKullanildi(m: Makro): void {
  if (!m.kaynak || !m.id) return;
  void api.makroKullanim(m.kaynak, m.id).catch(() => { /* sayaç kaybı yazımı durdurmaz */ });
}

/**
 * İmleçten önceki sözcük bir kısayolsa genişletilmiş metni ve yeni imleci
 * döndürür, değilse null. Seçim varken (imleç tek nokta değilse) açılmaz.
 */
export function makroGenislet(metin: string, imlec: number, alan: string, makrolar: readonly Makro[],
                              ek = ' '): { deger: string; imlec: number; makro: Makro } | null {
  const once = metin.slice(0, imlec);
  const m = /(\S+)$/.exec(once);
  if (!m) return null;
  const kisayol = m[1];
  const makro = makrolar.find(x => x.kisayol === kisayol && x.alan === alan)
    ?? makrolar.find(x => x.kisayol === kisayol && x.alan === '');
  if (!makro) return null;
  const bas = once.slice(0, once.length - kisayol.length) + makro.metin + ek;
  return { deger: bas + metin.slice(imlec), imlec: bas.length, makro };
}

/**
 * ÇİPTEN EKLEME (kullanıcı: "ipucu çipine tıklayınca makro alana yazılsın"):
 * makro metni imlecin olduğu yere girer; önünde/arkasında yazı varsa arada tek
 * boşluk bırakılır. Yeni imleç eklenen metnin sonudur.
 */
export function makroEkle(metin: string, imlec: number, makroMetni: string): { deger: string; imlec: number } {
  const i = Math.max(0, Math.min(imlec, metin.length));
  const once = metin.slice(0, i);
  const sonra = metin.slice(i);
  const bas = once + (once && !/\s$/.test(once) ? ' ' : '') + makroMetni;
  const ara = sonra && !/^\s/.test(sonra) ? ' ' : '';
  return { deger: bas + ara + sonra, imlec: bas.length + ara.length };
}

/**
 * Kartın klavye olayını yakalar: hedef `data-alan` taşıyan metin kutusuysa ve
 * tuş boşluk / Tab ise makroyu açar. Yazım kartın kendi alan yazıcısıyla
 * (`yaz`) yapılır - React durumu tek kaynak kalır, imleç çizimden sonra konur.
 */
export function makroTusu(e: KeyboardEvent, makrolar: readonly Makro[] | undefined,
                          yaz: ((alan: string, v: string) => void) | undefined): void {
  if (!makrolar?.length || !yaz || (e.key !== ' ' && e.key !== 'Tab') || e.ctrlKey || e.altKey || e.metaKey) return;
  const el = e.target as HTMLTextAreaElement | HTMLInputElement;
  const alan = el.dataset?.alan;
  if (!alan || el.readOnly || el.disabled || typeof el.selectionStart !== 'number'
      || el.selectionStart !== el.selectionEnd) return;
  const s = makroGenislet(el.value, el.selectionStart, alan, makrolar, e.key === ' ' ? ' ' : '');
  if (!s) return;
  e.preventDefault();
  yaz(alan, s.deger);
  makroKullanildi(s.makro);
  requestAnimationFrame(() => { try { el.setSelectionRange(s.imlec, s.imlec) } catch { /* kutu gitti */ } });
}
