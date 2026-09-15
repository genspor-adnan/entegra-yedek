import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';

/**
 * GÖZ ÜNİTE AKIŞI AKSİYONLARI — mockup
 * `Ekranlar/Goz/goz_unite_panosu.html` araç çubuğu.
 *
 * <b>Pano yazmaz, taşır:</b> düğmeler hastayı bir sonraki istasyona alır,
 * dilatasyon başlatır, oda atar, ziyareti kapatır. Klinik kayıt (ölçüm, tanı,
 * işlem) kendi kartında girilir — panoya form koymak, ayakta doldurulan yarım
 * kayıtlar üretirdi.
 *
 * <b>Kurallar sunucuda:</b> kapanmış satıra işlem yapılamaz, aynı istasyona
 * taşınamaz, dilatasyon ikinci kez başlatılamaz. Ekran yalnız soruyu sorar ve
 * sunucunun cümlesini gösterir — iki yerde iki kural, ikisinin sessizce
 * ayrışması demek.
 */

/** 1 kabul · 2 ön tetkik · 3 muayene · 4 görüntüleme · 5 karar · 6 tamamlandı. */
const ISTASYONLAR = [
  { kod: '2', ad: 'Ön tetkik' },
  { kod: '3', ad: 'Hekim muayenesi' },
  { kod: '4', ad: 'Görüntüleme' },
  { kod: '5', ad: 'Karar / işlem' },
  { kod: '1', ad: 'Kabul / bekleme' },
  { kod: '6', ad: 'Tamamlandı (ziyaret kapanır)' },
];

const DAMLALAR = ['Tropikamid', 'Siklopentolat', 'Fenilefrin', 'Tropikamid + Fenilefrin'];

export interface GozAkisBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Göz şeması (705): çizim penceresi - ekran açar, kural sunucuda. */
  semaAc?(gozMuayeneId: number): void;
  /** Dikte (705): sesle metin bulgu penceresi. */
  dikteAc?(gozMuayeneId: number): void;
}

export async function gozAkisAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: GozAkisBaglam,
): Promise<boolean> {
  if (!kod.startsWith('goz.')) return false;

  const id = Number(satir?.id ?? 0);

  // ---- SIRADAKİNİ ÇAĞIR: kayıt seçilmemişse en uzun bekleyen çağrılır.
  if (kod === 'goz.cagir') {
    await guvenli(async () => {
      const y = await api.gozCagir(id || null);
      mesaj(`${y.hasta} çağrıldı — ${y.istasyon}${y.oda ? ` · ${y.oda}` : ''}`
            + (y.tekrar ? ' (tekrar çağrı)' : ''));
      b.tazele();
    });
    return true;
  }

  if (kod === 'goz.istasyona-al') {
    if (!id) { mesaj('Önce bir hasta kartı seçin.'); return true }
    const hedef = await listeSor('Hangi istasyona alınsın?', ISTASYONLAR);
    if (!hedef) return true;
    await guvenli(async () => {
      const y = await api.gozIstasyonaAl(id, { istasyon: Number(hedef) });
      // UYARI SUNUCUDAN: dilatasyon hazır değilken muayeneye alma kararı
      //   klinik bir karardır - engellenmiyor ama söyleniyor.
      mesaj(y.tamamlandi
        ? `${y.hasta} · ziyaret tamamlandı.`
        : `${y.hasta} → ${y.istasyon}${y.uyari ? ` — ${y.uyari}` : ''}`);
      b.tazele();
    });
    return true;
  }

  if (kod === 'goz.dilatasyon') {
    if (!id) { mesaj('Önce bir hasta kartı seçin.'); return true }
    const ilac = await listeSor('Hangi damla?', DAMLALAR.map(d => ({ kod: d, ad: d })));
    if (!ilac) return true;
    await guvenli(async () => {
      const y = await api.gozDilatasyon(id, ilac);
      mesaj(`Dilatasyon başladı — ${y.hazirDk} dakika sonra hazır.`);
      b.tazele();
    });
    return true;
  }

  if (kod === 'goz.oda-ata') {
    if (!id) { mesaj('Önce bir hasta kartı seçin.'); return true }
    const oda = await metinSor('Oda / cihaz', String(satir?.oda ?? ''));
    if (!oda?.trim()) return true;
    await guvenli(async () => {
      await api.gozOdaAta(id, oda.trim());
      mesaj(`Oda atandı: ${oda.trim()}`);
      b.tazele();
    });
    return true;
  }

  if (kod === 'goz.muayene-ac') {
    // Muayene kaydı YOKSA açılmaz: pano muayene açmaz, açılmışı gösterir -
    //   boş muayene kaydı üretmek, hekimin hiç görmediği hastayı görülmüş
    //   gibi listelerdi.
    const muayeneId = Number(satir?.gozMuayeneId ?? 0);
    if (!muayeneId) {
      mesaj('Bu ziyarette henüz göz muayenesi açılmamış.');
      return true;
    }
    b.git(`/goz-muayene/${muayeneId}`);
    return true;
  }

  // ---- MUAYENE KARTI ARAÇ ÇUBUĞU (mockup goz_detayli_muayene.html).
  if (kod === 'goz.muayene-tamamla') {
    if (!id) { mesaj('Önce bir muayene seçin.'); return true }
    await guvenli(async () => {
      const y = await api.gozMuayeneTamamla(id);
      mesaj('Muayene tamamlandı.' + (y.uyari ? ` ${y.uyari}` : ''));
      b.tazele();
    });
    return true;
  }

  if (kod === 'goz.onceki-kopyala') {
    if (!id) { mesaj('Önce bir muayene seçin.'); return true }
    if (!await onay('Önceki muayenenin biyomikroskopi ve fundus bulguları '
                    + 'getirilsin mi? Bugün yazılmış bulgular korunur, '
                    + 'ölçümler (görme, basınç, refraksiyon) kopyalanmaz.')) return true;
    await guvenli(async () => {
      const y = await api.gozOncekiKopyala(id);
      mesaj(y.aciklama);
      // Kart açıksa yeni satırlar ancak yeniden okunduğunda görünür.
      b.tazele();
    });
    return true;
  }

  // ---- ÇİZİM VE DİKTE (705): ikisi de bulgu yazmanın başka bir yolu.
  //   Pencereyi ekran açar; yazma kuralı (kapalı muayene, kapalı alan,
  //   metni ezmeme) sunucuda.
  if (kod === 'goz.sema' || kod === 'goz.dikte') {
    if (!id) { mesaj('Önce bir muayene seçin.'); return true }
    if (kod === 'goz.sema') b.semaAc?.(id); else b.dikteAc?.(id);
    return true;
  }

  // YENİ KAYIT AÇAN KISAYOLLAR: kart hastayı ve muayeneyi ÖN DOLGU olarak
  //   taşır (sorgu parametresi). Hekim aynı bilgiyi ikinci kez seçmesin diye.
  if (kod === 'goz.gozluk-recete' || kod === 'goz.goruntuleme-iste'
      || kod === 'goz.islem-planla') {
    const hastaId = Number(satir?.hastaId ?? 0);
    if (!id || !hastaId) { mesaj('Önce bir muayene seçin.'); return true }
    const yol = kod === 'goz.gozluk-recete' ? '/goz-gozluk-recete'
      : kod === 'goz.goruntuleme-iste' ? '/goz-goruntuleme' : '/goz-islem';
    // MUAYENE ID (goz_muayene.id DEGIL): uc tablonun da muayene_id'si
    //   public.muayene'ye bakar. Yoksa bag kurulmaz, kart yine acilir.
    const muayeneId = Number(satir?.muayeneId ?? 0);
    b.git(`${yol}/yeni?hastaId=${hastaId}`
          + (muayeneId ? `&muayeneId=${muayeneId}` : ''));
    return true;
  }

  // ---- CİHAZ MESAJLARI (703): ham kayıt silinmez, YENİDEN İŞLENİR.
  if (kod === 'goz.mesaj-isle') {
    if (!id) { mesaj('Önce bir mesaj seçin.'); return true }
    await guvenli(async () => {
      const y = await api.gozMesajIsle(id);
      mesaj(y.aciklama);
      b.tazele();
    });
    return true;
  }

  if (kod === 'goz.mesaj-kuyruk') {
    await guvenli(async () => {
      const y = await api.gozMesajKuyruk();
      mesaj(y.aciklama);
      b.tazele();
    });
    return true;
  }

  if (kod === 'goz.ziyaret-kapat') {
    if (!id) { mesaj('Önce bir hasta kartı seçin.'); return true }
    if (!await onay('Ziyaret tamamlansın mı? Hasta panodan düşer, '
                    + 'kayıtları yerinde kalır.')) return true;
    await guvenli(async () => {
      const y = await api.gozIstasyonaAl(id, { istasyon: 6 });
      mesaj(`${y.hasta} · ziyaret tamamlandı.`);
      b.tazele();
    });
    return true;
  }

  return false;
}
