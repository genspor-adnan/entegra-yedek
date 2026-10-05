import { api } from '../../api/istemci';
import { ApiHatasi, type ListeSatiri } from '../../api/sozlesme';
import { gozTamamlaSonrasi } from '../goz/GozSurecSekmeleri';
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

  // SÜREÇ v2: başvuruyu panoya (Kabul) al - panoya ilk satırı açan tek yol.
  if (kod === 'goz.panoya-al') {
    await guvenli(async () => {
      const y = await api.gozAkisBasvurular();
      if (y.satirlar.length === 0) { mesaj('Panoya alınacak başvuru yok (son 24 saat).'); return }
      const sec = await listeSor('Hangi başvuru göz ünitesine alınsın?', y.satirlar.map(s => ({
        kod: String(s.id),
        ad: `${s.hasta} · ${s.bolum || 'bölüm yok'}${s.hekim ? ` · ${s.hekim}` : ''} · `
            + new Date(s.zaman).toTimeString().slice(0, 5),
      })));
      if (!sec) return;
      await api.gozAkisEkle(Number(sec));
      mesaj('Hasta panoya (Kabul) alındı.');
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
        : `${y.hasta} → ${y.istasyon}${y.uyari ? ` — ${y.uyari}` : ''}`
          + (y.muayeneYeni ? ` · göz muayenesi #${y.gozMuayeneId} açıldı` : ''));
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
    // SÜREÇ v2: kayıt yoksa AÇILIR (genel muayene + göz uzantısı) - "açılmamış" denip
    //   bırakılmaz; aynı başvuruda ikinci kayıt açılmaz.
    const muayeneId = Number(satir?.gozMuayeneId ?? 0);
    if (muayeneId) { b.git(`/goz-muayene/${muayeneId}`); return true }
    if (!id) { mesaj('Önce bir hasta kartı seçin.'); return true }
    await guvenli(async () => {
      const y = await api.gozAkisMuayene(id);
      b.tazele();
      b.git(`/goz-muayene/${y.gozMuayeneId}`);
    });
    return true;
  }

  // ---- MUAYENE KARTI ARAÇ ÇUBUĞU (mockup goz_detayli_muayene.html).
  if (kod === 'goz.muayene-tamamla') {
    if (!id) { mesaj('Önce bir muayene seçin.'); return true }
    // EKSİKTE GEREKÇE (970): tanı / iki göz görme / GİB yoksa sunucu GOZ_EKSIK der;
    //   hekim gerekçe yazarsa (çocuk, iş birliği yok, tek göz…) tamamlanır.
    await guvenli(async () => {
      let y;
      try {
        y = await api.gozMuayeneTamamla(id);
      } catch (e) {
        const engel = e instanceof ApiHatasi ? (e.hata.engel as { kod?: string } | undefined) : undefined;
        if (engel?.kod !== 'GOZ_EKSIK') throw e;
        const gerekce = await metinSor(`${(e as ApiHatasi).message}\n\nGerekçe:`, '', 'Gerekçe', true);
        if (!gerekce?.trim()) return;
        y = await api.gozMuayeneTamamla(id, gerekce.trim());
      }
      if (y.uyari) mesaj(y.uyari);
      b.tazele();
      // SÜREÇ v2: doğan işler + sonraki istasyon + kontrol randevusu.
      await gozTamamlaSonrasi(id, b.git);
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
  if (kod === 'goz.gozluk-recete' || kod === 'goz.islem-planla') {
    const hastaId = Number(satir?.hastaId ?? 0);
    if (!id || !hastaId) { mesaj('Önce bir muayene seçin.'); return true }
    const yol = kod === 'goz.gozluk-recete' ? '/goz-gozluk-recete' : '/goz-islem';
    // MUAYENE ID (goz_muayene.id DEGIL): uc tablonun da muayene_id'si
    //   public.muayene'ye bakar. Yoksa bag kurulmaz, kart yine acilir.
    const muayeneId = Number(satir?.muayeneId ?? 0);
    // HASTA ADI + GERİ (kullanıcı): reçete kartında hasta dolu gelir; Kaydet / Kapat göz
    //   muayene kartına döner.
    const p = new URLSearchParams({ hastaId: String(hastaId) });
    if (muayeneId) p.set('muayeneId', String(muayeneId));
    if (satir?.hastaAdi) p.set('hastaAd', String(satir.hastaAdi));
    p.set('geri', `/goz-muayene/${id}`);
    b.git(`${yol}/yeni?${p.toString()}`);
    return true;
  }

  // ---- GÖZLÜK REÇETELERİ (972): imza → optiğe ver → teslim; kopya yeni reçete açar.
  if (kod === 'goz.gozluk-imzala' || kod === 'goz.gozluk-optik' || kod === 'goz.gozluk-teslim') {
    if (!id) { mesaj('Önce bir reçete seçin.'); return true }
    if (kod === 'goz.gozluk-imzala' && !await onay('Reçete imzalansın mı? İmzadan sonra değerler değiştirilemez.')) return true;
    await guvenli(async () => {
      if (kod === 'goz.gozluk-imzala') { const y = await api.gozlukImzala(id); mesaj(`Reçete imzalandı (${y.receteNo}).`) }
      else { await api.gozlukDurum(id, kod === 'goz.gozluk-optik' ? 3 : 4); mesaj(kod === 'goz.gozluk-optik' ? 'Reçete optiğe verildi.' : 'Teslim edildi.') }
      b.tazele();
    });
    return true;
  }
  if (kod === 'goz.gozluk-kopyala') {
    if (!id) { mesaj('Önce bir reçete seçin.'); return true }
    const p = new URLSearchParams({ hastaId: String(satir?.hastaId ?? ''), kopya: String(id) });
    if (satir?.muayeneId) p.set('muayeneId', String(satir.muayeneId));
    if (satir?.hasta) p.set('hastaAd', String(satir.hasta));
    b.git(`/goz-gozluk-recete/yeni?${p.toString()}`);
    return true;
  }

  // ---- GÖZ GÖRÜNTÜLEME (974): ödenmiş istem çekilir → hekim değerlendirir; yeniden çekim ücretsiz yeni kayıt.
  if (kod === 'goz.gor-cekildi' || kod === 'goz.gor-degerlendir' || kod === 'goz.gor-yeniden' || kod === 'goz.gor-muayene') {
    if (!id) { mesaj('Önce bir görüntüleme seçin.'); return true }
    if (kod === 'goz.gor-degerlendir') { b.git(`/goz-goruntuleme/${id}`); return true }
    if (kod === 'goz.gor-yeniden' && !await onay('Yeniden çekim istensin mi? Bu çekim iptal edilir, yeni kayıt ücretsiz sıraya düşer.')) return true;
    await guvenli(async () => {
      if (kod === 'goz.gor-muayene') {
        const y = await api.gozGoruntulemeOnizleme(id);
        const gm = Number(y.kayit.gozMuayeneId ?? 0);
        if (!gm) { mesaj('Bu görüntülemenin göz muayenesi yok.'); return }
        b.git(`/goz-muayene/${gm}`);
        return;
      }
      if (kod === 'goz.gor-cekildi') { await api.gozGoruntulemeCekildi(id); mesaj('Çekildi; değerlendirme bekliyor.') }
      else { await api.gozGoruntulemeYeniden(id); mesaj('Yeniden çekim istendi.') }
      b.tazele();
    });
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
