import { api } from '../../api/istemci';
import { ApiHatasi, type ListeSatiri } from '../../api/sozlesme';
import { gozTamamlaSonrasi } from '../goz/GozSurecSekmeleri';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { GOZ_ISTASYON } from '../../bilesenler/goz/gozPanoSabitleri';

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

/**
 * "İstasyona al" listesi: sözlük ortak (gozPanoSabitleri), SIRA burada -
 * hasta en çok ön tetkik ve muayene arasında taşınıyor, kuyruğun başına
 * onlar yazılıyor. 6 (tamamlandı) ziyareti kapatır, en sonda durur.
 */
const ISTASYONLAR = [2, 3, 4, 5, 1, 6].map(k => ({
  kod: String(k),
  ad: k === 6 ? 'Tamamlandı (ziyaret kapanır)'
    : k === 1 ? 'Kabul / bekleme'
      : k === 3 ? 'Hekim muayenesi'
        : GOZ_ISTASYON[k],
}));

const DAMLALAR = ['Tropikamid', 'Siklopentolat', 'Fenilefrin', 'Tropikamid + Fenilefrin'];

export interface GozAkisBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Göz şeması (705): çizim penceresi - ekran açar, kural sunucuda. */
  semaAc?(gozMuayeneId: number): void;
  /** Dikte (705): sesle metin bulgu penceresi. */
  dikteAc?(gozMuayeneId: number): void;
  /**
   * 976: istem sepetini Göz sekmesinde açar. Pano istemi AÇAR ama YAZMAZ -
   * kayıt muayeneye gidiyor, ücretlendirme başvuruda; panoya form koymak
   * ayakta doldurulan yarım kayıtlar üretirdi.
   */
  istemAc?(gozMuayeneId: number): void;
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

  // ---- ODA / CİHAZ ATAMA: 976'dan beri TANIMLI kaynaktan seçiliyor.
  //   Serbest metin "OCT-1 / OCT1" ikiliğini üretiyor, doluluk tablosu ikiye
  //   bölünüyor ve darboğaz görünmez oluyordu. Tanım yapılmamış kurulumda
  //   (liste boş) eski davranış sürüyor: elle metin.
  if (kod === 'goz.oda-ata') {
    if (!id) { mesaj('Önce bir hasta kartı seçin.'); return true }
    await guvenli(async () => {
      const istasyon = Number(satir?.istasyon ?? 0);
      const y = await api.liste('goz-kaynak', { sayfa: 1, boyut: 200,
        filtre: { alan: 'aktif', op: 'esit', deger: 1 } });
      // İSTASYONA UYAN KAYNAK ÖNDE: ön tetkik masasını muayene listesinde
      //   göstermek yanlış atamayı kolaylaştırıyor. "Tümü" (0) her yerde.
      const uygun = y.satirlar.filter(k => {
        const i = Number(k.istasyon ?? 0);
        return i === 0 || !istasyon || i === istasyon;
      });
      if (uygun.length === 0) {
        const oda = await metinSor('Oda / cihaz (tanım yok - elle)', String(satir?.oda ?? ''));
        if (!oda?.trim()) return;
        await api.gozOdaAta(id, oda.trim());
        mesaj(`Oda atandı: ${oda.trim()}`);
        b.tazele();
        return;
      }
      const sec = await listeSor('Hangi oda / cihaz?', uygun.map(k => ({
        kod: String(k.id),
        ad: `${String(k.ad ?? '')} · ${String(k.turAdi ?? '')}`
            + (Number(k.sayi ?? 0) > 0 ? ` · sırada ${String(k.sayi)}` : ' · boş')
            + (String(k.sahip ?? '') ? ` · ${String(k.sahip)}` : ''),
      })));
      if (!sec) return;
      const secili = uygun.find(k => String(k.id) === sec);
      const r = await api.gozOdaAta(id, '', null, Number(sec));
      mesaj(`Oda atandı: ${r.oda || String(secili?.ad ?? '')}`);
      b.tazele();
    });
    return true;
  }

  // ---- GÖRÜNTÜLEME İSTEMİ (976): mockup araç çubuğundaki "📷 Görüntüleme
  //   İstemi". Muayene kaydı YOKSA açılmaz - istem muayeneye yazılıyor,
  //   başvurusuz / muayenesiz istem 974'te bilerek kapatıldı.
  if (kod === 'goz.goruntuleme-istem') {
    const muayeneId = Number(satir?.gozMuayeneId ?? 0);
    if (!muayeneId) {
      mesaj('Önce hastayı Ön tetkik / Hekim muayenesine alın: istem muayene kaydına yazılır.');
      return true;
    }
    if (!b.istemAc) { mesaj('İstem sepeti bu ekranda açılamıyor.'); return true }
    b.istemAc(muayeneId);
    return true;
  }

  // ---- BEKLEME EKRANI: salon televizyonunda açık kalacak, YENİ SEKMEDE
  //   açılıyor - panoyu kullanan kişi kendi ekranını kaybetmemeli.
  if (kod === 'goz.bekleme-ekrani') {
    window.open('/goz-bekleme-ekrani', '_blank', 'noopener');
    return true;
  }

  if (kod === 'goz.gun-ozeti') {
    b.git('/goz-unite-gun-ozeti');
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

  // ---- CİHAZLAR (978): bağlantı sınaması · mesaj kuyruğu · demirbaş kartı.
  if (kod === 'goz.cihaz-sina') {
    if (!id) { mesaj('Önce bir cihaz seçin.'); return true }
    await guvenli(async () => {
      const y = await api.gozCihazSina(id);
      // SONUÇ METNİ sunucudan geliyor ve sınırını kendisi yazıyor
      //   ("DICOM doğrulaması yapılmadı") - istemci onu yorumlamıyor.
      mesaj(`${y.basarili ? '✔' : '✕'} ${y.sonuc}`);
      b.tazele();
    });
    return true;
  }
  if (kod === 'goz.cihaz-mesajlar') {
    if (!id) { mesaj('Önce bir cihaz seçin.'); return true }
    // Mesaj listesi kendi ekranı: cihaz süzgeciyle açılır.
    b.git(`/goz-cihaz-mesaj?cihazId=${id}`);
    return true;
  }
  if (kod === 'goz.cihaz-demirbas') {
    const demirbasId = Number(satir?.demirbasId ?? 0);
    if (!demirbasId) {
      mesaj('Cihaz demirbaşa bağlı değil - kalibrasyon ve bakım takip edilmiyor. '
            + 'Cihaz kartından demirbaş kaydını bağlayın.');
      return true;
    }
    b.git(`/demirbas/${demirbasId}`);
    return true;
  }

  // ---- GÖZLÜK REÇETESİ BİLDİRİMİ (973): hastaya reçetenin HAZIR olduğu
  //   bildirilir; değerleri gitmez (SMS'te dioptri yanlış okunur, bkz. db 977).
  if (kod === 'goz.gozluk-bildir') {
    if (!id) { mesaj('Önce bir reçete seçin.'); return true }
    await guvenli(async () => {
      const y = await api.gozlukBildir(id);
      mesaj(`${y.kanal === 'sms' ? 'SMS' : 'E-posta'} kuyruğa alındı: ${y.alici}`);
      b.tazele();
    });
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
