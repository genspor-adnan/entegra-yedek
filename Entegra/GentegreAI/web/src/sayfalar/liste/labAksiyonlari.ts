import { api } from '../../api/istemci';
import { type AksiyonBaglami } from './aksiyonOrtak';
import { guvenli, listeSor, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * LABORATUVAR AKSİYONLARI (433/434) — numune kabul/ret, sonuç onayı,
 * düzeltme, panik bildirimi, cihaz mesajını sonuca aktarma.
 *
 * <b>Ret nedeni sorulmadan gönderilmez.</b> Sunucu da zorunlu tutuyor, ama
 * hemoliz mi pıhtı mı olduğu sorulmadan reddedilen tüp, hasta ikinci kez
 * kan verdiğinde aynı hatayla geri gelir.
 *
 * <b>Onaylı sonuç güncellenmez.</b> "Düzelt" eski satırı iptal edip yenisini
 * açar; neden zorunludur çünkü rapor "düzeltilmiş" damgası taşıyacak.
 */
export type LabBaglam = AksiyonBaglami & {
  /** SONUC GIRIS penceresini acar (433) - istemin butun tetkikleri icin. */
  sonucGir?(istemId: number): void;
};

/**
 * RET KRİTERLERİ SUNUCUDAN (879, KTS maddesi L6).
 *
 * Eskiden sekiz kod burada sabitti; laboratuvar kendi kabul/ret ölçütlerini
 * (kalite el kitabındakileri) giremiyordu. Artık `lab_ret_nedeni` tanımı
 * okunuyor: ret penceresinin seçenekleri de, kabuldeki "kalite" listesi de
 * aynı satırlardan çıkıyor - iki listeyi ayrı tutmak, kurum yeni kriter
 * eklediğinde birinde görünüp ötekinde görünmemesi demekti.
 *
 * TEK SEFER OKUNUR: liste kurulum verisidir, her düğmede yeniden istemek
 * bankoyu yavaşlatırdı. Sunucu hatası halinde 433'ün kod uzayına düşülür -
 * numune kabul, tanım okunamadı diye durmamalı.
 */
interface RetKriteri {
  kod: number; ad: string; kabuldeSecilebilir: boolean; hastaBilgilendir: boolean;
}

const YEDEK_KRITERLER: RetKriteri[] = [
  { kod: 1, ad: 'Uygun', kabuldeSecilebilir: true, hastaBilgilendir: false },
  { kod: 2, ad: 'Hemolizli', kabuldeSecilebilir: true, hastaBilgilendir: true },
  { kod: 3, ad: 'Lipemik', kabuldeSecilebilir: true, hastaBilgilendir: true },
  { kod: 4, ad: 'İkterik', kabuldeSecilebilir: true, hastaBilgilendir: false },
  { kod: 5, ad: 'Yetersiz miktar', kabuldeSecilebilir: true, hastaBilgilendir: true },
  { kod: 6, ad: 'Pıhtılı', kabuldeSecilebilir: true, hastaBilgilendir: true },
  { kod: 7, ad: 'Yanlış tüp', kabuldeSecilebilir: true, hastaBilgilendir: true },
  { kod: 8, ad: 'Etiketsiz', kabuldeSecilebilir: false, hastaBilgilendir: false },
  { kod: 9, ad: 'Diğer', kabuldeSecilebilir: false, hastaBilgilendir: false },
];

let kriterler: RetKriteri[] | null = null;

async function kriterleriAl(): Promise<RetKriteri[]> {
  if (kriterler) return kriterler;
  try {
    const y = await api.labRetNedenleri();
    kriterler = y.nedenler.length > 0 ? y.nedenler : YEDEK_KRITERLER;
  } catch {
    kriterler = YEDEK_KRITERLER;
  }
  return kriterler;
}

const secenek = (k: RetKriteri) => ({ kod: String(k.kod), ad: `${k.kod} - ${k.ad}` });

/** Ret penceresi: kod 1 ("Uygun") bir ret nedeni değildir, listede olmaz. */
const retSecenekleri = (l: RetKriteri[]) => l.filter(k => k.kod !== 1).map(secenek);

/**
 * KABULDE KALITE listesi: "Uygun" + kabulde de seçilebilen kriterler.
 * Kabul edilen ama kusurlu tüp (hafif lipemik) işaretlenir - sonuç
 * yorumlanırken rapora düşer.
 */
const kaliteSecenekleri = (l: RetKriteri[]) =>
  l.filter(k => k.kod === 1 || k.kabuldeSecilebilir).map(secenek);

const kriterAdi = (l: RetKriteri[], kod: number) => l.find(k => k.kod === kod)?.ad ?? '';

export async function labAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: LabBaglam,
  secililer?: ListeSatiri[] | null,
): Promise<boolean> {
  if (!kod.startsWith('lab.')) return false;
  // Crud() lab-tetkik.yeni / .duzenle / .sil uretir - onlar Liste'nin kendi
  //   kart akisi.
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  // BARKOD OKUT kayit SECIMI ISTEMEZ: bankonun giris yolu tupun kendisidir.
  //   Okutulan barkod hangi isteme aitse o istem acilir; kabul edilmemisse
  //   ayni yerden kabul edilir - iki ekran arasinda gezinmeye gerek kalmaz.
  if (kod === 'lab.barkod-okut') {
    const b2 = await metinSor('Tüp barkodunu okutun ya da yazın:', '', 'Barkod Okut');
    if (b2 === null || b2.trim() === '') return true;
    await guvenli(async () => {
      const n = await api.labNumuneBarkod(b2.trim()) as Record<string, unknown>;
      const durum = Number(n.durum ?? 0);
      const bilgi = `${String(n.istemNo ?? '')} · ${String(n.hasta ?? '')}`
                  + ` · ${Number(n.tetkik ?? 0)} tetkik`;
      if (durum === 3) { mesaj(`${bilgi}\n\nBu tüp zaten kabul edilmiş.`); return }
      if (durum === 0) { mesaj(`${bilgi}\n\nBu tüp REDDEDİLMİŞ - yeni numune gerekiyor.`); return }
      if (!await onay(`${bilgi}\n\nTüp kabul edilsin mi? (TAT şimdi başlar)`)) return;
      mesaj((await api.labNumuneDurum(Number(n.id ?? 0), 3)).mesaj);
      b.tazele();
    });
    return true;
  }

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }
  // TOPLU ONAY (kullanıcı): birden çok tetkik seçiliyse hepsi onaylanır.
  //   Seçim yoksa/tekse aktif satır. Yalnız onay/panik aksiyonları kullanır.
  const secIdler = (secililer && secililer.length > 0
    ? secililer.map(s => Number(s.id)).filter(n => n > 0)
    : [id]);

  // SONUC GIRISI: pencere acilir, yazma ve kural motoru orada.
  if (kod === 'lab.sonuc-gir') { b.sonucGir?.(id); return true }

  // REFLEKTİF İSTEM (873 §7): lab uzmanı sonuç sonrası ek tetkik ister. Kayıt
  //   "Laboratuvar Uzmanı Reflektif İstemi" olarak sunucuda düşer, tüp planı
  //   ardından üretilir; hekim müdahalesi yok.
  if (kod === 'lab.reflektif') {
    if (!id) { mesaj('Önce bir istem seçin.'); return true }
    await guvenli(async () => {
      const tetkikler = await api.liste('lab-tetkik', { sayfa: 1, boyut: 200 });
      const secim = await secimSor('Reflektif olarak eklenecek tetkik?',
        tetkikler.satirlar.map(r => ({ kod: String(r.id), ad: `${String(r.kod ?? '')} · ${String(r.ad ?? '')}` })));
      if (!secim) return;
      const aciklama = await metinSor('Reflektif istem gerekçesi (klinik bulgu / önceki sonuç)', '', 'Gerekçe');
      if (aciklama === null) return;
      const y = await api.labReflektifEkle(id, { tetkikIdler: [Number(secim)], aciklama });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  switch (kod) {
    // ------------------------------------------------------------ istem ---
    case 'lab.numune-plani':
      await guvenli(async () => {
        const y = await api.labNumunePlani(id);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;

    // ETIKET: istemin TUM tupleri tek sayfada - kan alma bankosu tupleri
    //   birlikte hazirlar, tek tek basmak siraya girer.
    case 'lab.etiket':
      b.git(`/lab/etiket?istem=${id}`);
      return true;

    // RAPOR: hastaya verilen belge ayri sayfada acilir (yazdirma
    //   tarayicinin kendi diyalogu; ayri bir PDF ureticisi yok).
    case 'lab.rapor':
      b.git(`/lab/rapor/${id}`);
      return true;

    // ISTEM DUZEYINDE KABUL/RET: hastanin TUM tupleri. Hangi tupe
    //   dokunulacagina sunucu karar verir (calisilmis numune atlanir).
    case 'lab.istem-kabul': {
      // Kod listesi METINDE degil COMBODA (kullanici: "kabul/ret
      //   butonlarinda mesajda girisler combo olsun, 1 default gelsin").
      //   Kabul edilen tupun olagan hali "Uygun" - Enter'la gecilir.
      const kl = await kriterleriAl();
      const k = await listeSor('Numune kalitesi:', kaliteSecenekleri(kl), '1', 'Kalite');
      if (k === null) return true;
      const kalite = Number(k) || undefined;
      await guvenli(async () => {
        const y = await api.labIstemNumuneDurum(id, 3, { kalite });
        mesaj(`${y.mesaj} Süre (TAT) şimdi başladı.`);
        b.tazele();
      });
      return true;
    }

    case 'lab.istem-ret': {
      const kl2 = await kriterleriAl();
      const n = await listeSor('Ret nedeni:', retSecenekleri(kl2), '2', 'Ret Nedeni');
      if (n === null) return true;
      const retNeden = Number(n);
      if (!kriterAdi(kl2, retNeden)) {
        mesaj('Geçerli bir ret nedeni seçin.');
        return true;
      }
      const aciklama = await metinSor('Açıklama (isteğe bağlı):', '', 'Numune Reddi');
      if (aciklama === null) return true;
      if (!await onay(`İstemin TÜM tüpleri REDDEDİLECEK `
                    + `(${kriterAdi(kl2, retNeden)}).\n\n`
                    + 'Tetkikler "tekrar numune bekliyor" durumuna geçer.')) return true;
      await guvenli(async () => {
        mesaj((await api.labIstemNumuneDurum(id, 0, { retNeden, aciklama })).mesaj);
        b.tazele();
      });
      return true;
    }

    // SAKLAMA YERI: tupler calisilmayi beklerken nerede duruyor. Sicaklik
    //   istege bagli - dolap adi zaten yeri soyler, sicaklik kaydi ise
    //   soguk zincir gereken numunede kanittir.
    case 'lab.saklama': {
      const yer = await metinSor('Saklama yeri (dolap / raf):', '', 'Saklama Yeri');
      if (yer === null || yer.trim() === '') return true;
      const s = await metinSor('Sıcaklık °C (boş geçilebilir):', '', 'Saklama Yeri');
      if (s === null) return true;
      const sicaklik = s.trim() === '' ? undefined
                     : Number(s.trim().replace(',', '.'));
      if (sicaklik !== undefined && Number.isNaN(sicaklik)) {
        mesaj('Sıcaklık sayı olmalı.');
        return true;
      }
      await guvenli(async () => {
        mesaj((await api.labIstemSaklama(id, yer.trim(), sicaklik)).mesaj);
        b.tazele();
      });
      return true;
    }

    // ----------------------------------------------------------- numune ---
    case 'lab.numune-alindi':
      await guvenli(async () => {
        mesaj((await api.labNumuneDurum(id, 2)).mesaj);
        b.tazele();
      });
      return true;

    case 'lab.numune-kabul': {
      // Kalite sorulur ama ZORUNLU degil: uygun tup icin ek soru, kabul
      //   akisini yavaslatirdi. Bos gecilirse "Uygun" kalir.
      // Kod listesi METINDE degil COMBODA (kullanici: "kabul/ret
      //   butonlarinda mesajda girisler combo olsun, 1 default gelsin").
      //   Kabul edilen tupun olagan hali "Uygun" - Enter'la gecilir.
      const kl = await kriterleriAl();
      const k = await listeSor('Numune kalitesi:', kaliteSecenekleri(kl), '1', 'Kalite');
      if (k === null) return true;
      const kalite = Number(k) || undefined;
      await guvenli(async () => {
        const y = await api.labNumuneDurum(id, 3, { kalite });
        mesaj(`${y.mesaj} Süre (TAT) şimdi başladı.`);
        b.tazele();
      });
      return true;
    }

    case 'lab.numune-ret': {
      const kl2 = await kriterleriAl();
      const n = await listeSor('Ret nedeni:', retSecenekleri(kl2), '2', 'Ret Nedeni');
      if (n === null) return true;
      const retNeden = Number(n);
      if (!kriterAdi(kl2, retNeden)) {
        mesaj('Geçerli bir ret nedeni seçin.');
        return true;
      }
      const aciklama = await metinSor('Açıklama (isteğe bağlı):', '', 'Numune Reddi');
      if (aciklama === null) return true;
      if (!await onay(`Numune REDDEDİLECEK (${kriterAdi(kl2, retNeden)}).\n\n`
                    + 'Tetkikler "tekrar numune bekliyor" durumuna geçer.')) return true;
      await guvenli(async () => {
        mesaj((await api.labNumuneDurum(id, 0, { retNeden, aciklama })).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.barkod-yazdir': {
      // ETIKET AYRI SAYFADA: tup uzerine yapisan fiziksel belge, ekran
      //   cercevesiyle birlikte basilmamali (@media print).
      b.git(`/lab/etiket?numune=${id}`);
      return true;
    }

    // ------------------------------------------------------------ sonuç ---
    case 'lab.teknik-onay':
      await guvenli(async () => {
        for (const sid of secIdler) await api.labSonucOnayla(sid, 1);
        mesaj(secIdler.length > 1 ? `${secIdler.length} sonuç teknik onaylandı.`
                                  : 'Sonuç teknik onaylandı.');
        b.tazele();
      });
      return true;

    case 'lab.onayla': {
      // Seçimde panik değer varsa tek sefer uyar (herhangi biri panikse).
      const panikVar = (secililer && secililer.length > 0
        ? secililer.some(s => Number(s.panik ?? 0) === 1)
        : Number(satir?.panik ?? 0) === 1);
      if (panikVar && !await onay(
        (secIdler.length > 1 ? 'Seçili sonuçlardan biri PANİK DEĞER.\n\n'
                             : 'Bu sonuç PANİK DEĞER.\n\n')
        + 'Onaylamadan önce hekime bildirim yapıldığından emin olun.\n'
        + 'Onaylansın mı?')) return true;
      await guvenli(async () => {
        for (const sid of secIdler) await api.labSonucOnayla(sid, 2);
        mesaj(secIdler.length > 1 ? `${secIdler.length} sonuç uzman onayıyla yayınlandı.`
                                  : 'Sonuç uzman onayıyla yayınlandı.');
        b.tazele();
      });
      return true;
    }

    case 'lab.duzelt': {
      const deger = await metinSor('Doğru sonuç değeri:', String(satir?.deger ?? ''),
                                   'Sonuç Düzeltme');
      if (deger === null || deger.trim() === '') return true;
      const neden = await metinSor('Düzeltme nedeni (zorunlu):', '', 'Sonuç Düzeltme');
      if (neden === null || neden.trim() === '') {
        mesaj('Düzeltme nedeni zorunlu.');
        return true;
      }
      await guvenli(async () => {
        const y = await api.labSonucDuzelt(id, deger.trim(), neden.trim());
        mesaj(`${y.mesaj} Yeni değerlendirme: ${y.bayrak}`);
        b.tazele();
      });
      return true;
    }

    // TEST TEKRARI (891, KTS L8): gerekçe ZORUNLU ve kod listesinden -
    //   "neden tekrar ettik" sayılabilir bir kalite göstergesidir, serbest
    //   metin sayılamaz. Tür ayrımı laboratuvar için iş ayrımıdır: aynı
    //   tüpten tekrar çalışma ile yeni numune alınması başka işlerdir.
    case 'lab.tekrar-iste': {
      const satirId = Number(satir?.satirId ?? satir?.istemSatirId ?? 0);
      if (!satirId) { mesaj('İstem satırı bulunamadı.'); return true }

      const tur = await secimSor('Tekrar türü:', [
        { kod: '1', ad: 'Aynı numuneden tekrar çalış' },
        { kod: '2', ad: 'Yeni numune alınsın' },
      ]);
      if (!tur) return true;

      // GEREKÇE KOD LİSTESİNDEN (891): kurum listeyi Ayarlar'dan
      //   genişletebilsin diye sabit dizi değil, sunucudan okunur.
      const liste = await api.kodListe('lab.tekrar_gerekce');
      const gerekce = await listeSor('Tekrar gerekçesi:',
        (liste.degerler ?? []).filter(d => d.aktif === 1)
          .map(d => ({ kod: String(d.deger), ad: d.ad })), '', 'Test Tekrarı');
      if (!gerekce) return true;

      const not = await metinSor('Açıklama (isteğe bağlı):', '', 'Test Tekrarı');
      if (not === null) return true;

      await guvenli(async () => {
        const y = await api.labTekrarIste(satirId, {
          tur: Number(tur), gerekceKod: Number(gerekce), gerekce: not.trim(),
          sonucId: id || undefined,
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.tekrar-iptal': {
      const neden = await metinSor('İptal nedeni (zorunlu):', '', 'Tekrar Talebi');
      if (neden === null || neden.trim() === '') {
        mesaj('İptal nedeni zorunlu.');
        return true;
      }
      await guvenli(async () => {
        const y = await api.labTekrarIptal(id, neden.trim());
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    // OKUMA-GERİ TEYİDİ (894, KTS L2): panik kaydı "aradım" ile değil,
    //   karşı tarafın değeri TEKRAR ETMESİYLE kapanır. Teyidi alan kişi
    //   yazılır - denetimde sorulan budur.
    case 'lab.panik-teyit': {
      const bildirimId = Number(satir?.bildirimId ?? 0);
      if (!bildirimId) {
        mesaj('Bu panik değer için bildirim kaydı yok - önce bildirim yapın.');
        return true;
      }
      const kim = await metinSor('Değeri tekrar eden kişi (ad soyad):', '',
                                 'Okuma-Geri Teyidi');
      if (kim === null || kim.trim() === '') return true;
      await guvenli(async () => {
        const y = await api.labPanikTeyit(bildirimId, kim.trim());
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.panik-bildir': {
      const kime = await metinSor('Bildirim yapılan kişi (ad soyad):', '',
                                  'Panik Değer Bildirimi');
      if (kime === null || kime.trim() === '') return true;
      const aciklama = await metinSor('Açıklama (okundu-tekrar edildi vb.):', '',
                                      'Panik Değer Bildirimi');
      if (aciklama === null) return true;
      await guvenli(async () => {
        const y = await api.labPanikBildir(id, kime.trim(), 1, aciklama);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    // ------------------------------------------------------------ cihaz ---
    case 'lab.mesaj-sonuca-aktar':
      await guvenli(async () => {
        const y = await api.labCihazMesajIsle(id);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
  }

  return false;
}
