import { GRUP_IKON, GRUP_IKON_CEV, type MenuOgesi, type MenuSatiri } from './menuAgaci';
import type { MenuDuzenSatiri } from '../../api/sozlesme';
import { duzenHaritasi } from './menuDuzenHarita';

/**
 * MENÜ DÜZENİ FARKI (979, mockup `Ekranlar/Ayarlar/menu_duzenleme_v2.html`).
 *
 * Menünün kendisi KODDADIR (`listeTanimlari*.ts` + `menuBolgeleri.ts`); kurum
 * yalnız <b>farkı</b> saklar (sunucuda `menu_duzen`). Burası o farkı kurulmuş
 * ağacın üstüne uygular.
 *
 * <b>Neden fark, tam ağaç değil:</b> tam ağaç saklansaydı yeni bir ekran
 * eklendiğinde hiçbir şubede görünmezdi - düzen "donar"dı. Farkla, satırı
 * olmayan düğüm varsayılan yerinde çıkar.
 *
 * <b>Gizlemek erişim kapatmaz:</b> burada `gizli` işaretli ekran menüden
 * düşer ama adresi bilen yetkili kullanıcı yine açar. Erişim `yetki`nin işi.
 */
export type { MenuDuzenSatiri } from '../../api/sozlesme';

/** Ekranın sistem kodu: liste kaynağı varsa o, yoksa rota (özel sayfalar). */
export const ogeKodu = (m: MenuOgesi) => m.kaynak ?? m.yol;

/** Grubun sistem kodu: ÇEVRİLMEMİŞ ad - dil değişince eşleşme bozulmasın. */
export const grupKodu = (sat: Extract<MenuSatiri, { tur: 'grup' }>) =>
  sat.alt.find(m => m.grupHam)?.grupHam ?? sat.ad;

export { duzenHaritasi } from './menuDuzenHarita';

/**
 * Farkı menü satırlarına uygular: gizleme, görünen ad, ikon, sıra ve
 * <b>grup değiştirme</b> (bir ekranı başka grubun altına taşımak).
 *
 * Alt başlık ve dış bağlantı düğümleri bu adımda EKLENMEZ: onlar koda
 * karşılığı olmayan yeni düğümlerdir ve menüyü çizen bileşen (YanMenu) onları
 * ayrı okur - burada ağacın şekli korunur, yalnız var olan düğümler düzenlenir.
 */
export function menuDuzeniUygula(
  satirlar: MenuSatiri[],
  duzen: MenuDuzenSatiri[] | null | undefined,
): MenuSatiri[] {
  if (!duzen || duzen.length === 0) return satirlar;
  const h = duzenHaritasi(duzen);
  if (h.size === 0) return satirlar;

  // 1) ÖĞELER: gizle · yeniden adlandır · ikon · sıra · grup değiştir.
  const ogeDuzenle = (m: MenuOgesi): MenuOgesi | null => {
    const d = h.get(ogeKodu(m));
    if (!d) return m;
    if (d.gizli === 1) return null;
    return {
      ...m,
      ad: d.gorunenAd && d.gorunenAd.length > 0 ? d.gorunenAd : m.ad,
      ic: d.ikon && d.ikon.length > 0 ? d.ikon : m.ic,
      sira: d.sira ?? m.sira,
    };
  };

  // 2) TAŞINANLAR: ekranın üst kodu değiştiyse hedef grubun altına geçer.
  //    Önce bütün öğeleri topla, sonra hedefe göre dağıt - tek geçişte
  //    taşımak, henüz görülmemiş gruba taşımayı kaçırırdı.
  const tasinan = new Map<string, MenuOgesi[]>();
  const sonuc: MenuSatiri[] = [];

  for (const sat of satirlar) {
    if (sat.tur === 'duz') {
      const m = ogeDuzenle(sat.m);
      if (!m) continue;
      const d = h.get(ogeKodu(sat.m));
      if (d?.ustKod) {
        const liste = tasinan.get(d.ustKod) ?? [];
        liste.push(m);
        tasinan.set(d.ustKod, liste);
        continue;
      }
      sonuc.push({ tur: 'duz', m });
      continue;
    }

    const kod = grupKodu(sat);
    const dg = h.get(kod);
    if (dg?.gizli === 1) continue;

    const alt: MenuOgesi[] = [];
    for (const m of sat.alt) {
      const yeni = ogeDuzenle(m);
      if (!yeni) continue;
      const d = h.get(ogeKodu(m));
      // Başka gruba taşınmış ekran burada çizilmez, hedefinde çizilir.
      if (d?.ustKod && d.ustKod !== kod) {
        const liste = tasinan.get(d.ustKod) ?? [];
        liste.push(yeni);
        tasinan.set(d.ustKod, liste);
        continue;
      }
      alt.push(yeni);
    }
    // GRUP İKONU AD İLE BULUNUYOR (YanMenu: GRUP_IKON[s.ad]): grubu yeniden
    //   adlandırınca ikon eşleşmesi düşüyor ve menüde varsayılan klasör (📁)
    //   çiziliyordu. Kurumun verdiği ikon varsa o, yoksa KODDAKİ ADIN ikonu
    //   taşınır - ad değişikliği ikonu düşürmez.
    const yeniAd = dg?.gorunenAd && dg.gorunenAd.length > 0 ? dg.gorunenAd : sat.ad;
    sonuc.push({
      tur: 'grup',
      ad: yeniAd,
      ikon: dg?.ikon && dg.ikon.length > 0 ? dg.ikon
            : (yeniAd !== sat.ad ? (GRUP_IKON[sat.ad] ?? GRUP_IKON_CEV[sat.ad]) : undefined),
      alt,
    });
  }

  // 3) Taşınanları hedef gruplara ekle (hedef yoksa öğe düşer - kurum grubu
  //    gizlemişse taşıdığı ekranı da gizlemiş olur).
  if (tasinan.size > 0) {
    for (const sat of sonuc) {
      if (sat.tur !== 'grup') continue;
      const gelen = tasinan.get(grupKodu(sat));
      if (gelen) sat.alt = [...sat.alt, ...gelen];
    }
  }

  // 4) GRUP SIRASI: fark sıra verdiyse ona göre; vermediyse kodun sırası
  //    korunur (sıra verilmemiş grup, verilmişlerin arkasında kendi yerinde).
  const grupSira = (sat: MenuSatiri, i: number) =>
    sat.tur === 'grup' ? (h.get(grupKodu(sat))?.sira ?? 1000 + i) : 1000 + i;
  const sirali = sonuc
    .map((sat, i) => ({ sat, i }))
    .sort((a, b) => grupSira(a.sat, a.i) - grupSira(b.sat, b.i) || a.i - b.i)
    .map(x => x.sat);

  // 5) Grup içi sıra (öğe sırası fark ile değişmiş olabilir).
  for (const sat of sirali) {
    if (sat.tur !== 'grup') continue;
    sat.alt = sat.alt
      .map((m, i) => ({ m, i }))
      .sort((a, b) => (a.m.sira ?? 900 + a.i) - (b.m.sira ?? 900 + b.i) || a.i - b.i)
      .map(x => x.m);
  }

  // BOŞ GRUP ÇİZİLMEZ: bütün ekranları gizlenmiş ya da taşınmış bir grup
  //   başlığı, tıklanınca hiçbir şey açmayan bir satır olurdu.
  return sirali.filter(sat => sat.tur !== 'grup' || sat.alt.length > 0);
}
