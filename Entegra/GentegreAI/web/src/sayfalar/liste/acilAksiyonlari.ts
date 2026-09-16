import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';

/**
 * ACİL SERVİS LİSTE AKSİYONLARI (716 uçları).
 *
 * DÜŞÜRME KONTROLÜNÜ SUNUCU YAPAR, ekran yalnız GEREKÇEYİ ÖNDEN SORAR. Satırda
 * güncel triyaj düzeyi zaten var; kullanıcıya iki kez ("önce reddedildiniz,
 * şimdi gerekçe yazın") gitmek yerine düşürme seçildiği anda soruyoruz. Yetki
 * kontrolü yine sunucuda - istemcinin sorduğu gerekçe bir kolaylık, kural değil.
 *
 * ÇIKIŞ KARARI MODAL İSTER: çıkış şekli + ICD tanısı + hedef bölüm + not dört
 * ayrı alan ve ikisi koşullu. Art arda dört soru penceresi, acil masasında
 * yanlış tuşa basmanın en kolay yolu olurdu.
 *
 * YATAK ve ÇAĞRI tek seçimlik - açılır liste yeter, modal fazla gelirdi.
 */
export interface AcilBaglam {
  tazele(): void;
  cikisAc(v: { basvuruId: number; protokolNo?: string; hastaAdi?: string }): void;
}

const TRIYAJ: { kod: string; ad: string }[] = [
  { kod: '1', ad: '1 · Kırmızı (resüsitasyon)' },
  { kod: '2', ad: '2 · Turuncu (acil)' },
  { kod: '3', ad: '3 · Sarı (acele)' },
  { kod: '4', ad: '4 · Yeşil (az acil)' },
  { kod: '5', ad: '5 · Mavi (acil değil)' },
];

const CAGRI_TURU: { kod: string; ad: string }[] = [
  { kod: '1', ad: 'Konsültasyon' },
  { kod: '2', ad: 'Mavi Kod' },
  { kod: '3', ad: 'Beyaz Kod' },
  { kod: '4', ad: 'Pembe Kod' },
  { kod: '5', ad: 'Kateter Lab' },
  { kod: '6', ad: 'Ameliyathane' },
  { kod: '7', ad: 'Yoğun Bakım' },
];

export async function acilAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: AcilBaglam,
): Promise<boolean> {
  if (!kod.startsWith('acil.') && !kod.startsWith('acil-yatak.')) return false;
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  const id = Number(satir?.id ?? 0);

  // ------------------------------------------------------------ triyaj ----
  if (kod === 'acil.triyaj-ver') {
    if (!id) { mesaj('Önce bir başvuru seçin.'); return true }
    const mevcut = Number(satir?.triyaj ?? 0);
    const secim = await listeSor('Triyaj düzeyi:', TRIYAJ,
                                 mevcut > 0 ? String(mevcut) : '3', 'Düzey');
    if (!secim) return true;
    const duzey = Number(secim);
    if (duzey === mevcut) { mesaj('Düzey değişmedi.'); return true }

    // SAYI BÜYÜDÜKÇE ACİLİYET AZALIR (1 = kırmızı): büyüyen düzey DÜŞÜRMEDİR.
    let gerekce: string | undefined;
    if (mevcut > 0 && duzey > mevcut) {
      const g = await metinSor(
        `Triyaj ${mevcut} → ${duzey} düşürülüyor. Gerekçe zorunlu:`, '', 'Gerekçe');
      if (!g || !g.trim()) return true;
      gerekce = g.trim();
    }

    await guvenli(async () => {
      const y = await api.acilTriyaj(id, duzey, gerekce);
      mesaj(y.dusurme
        ? `Triyaj ${y.onceki} → ${y.triyaj} düşürüldü; gerekçe geçmişe yazıldı.`
        : `Triyaj ${y.triyaj} olarak kaydedildi.`);
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------------- hekim gördü ----
  if (kod === 'acil.hekim-gordu') {
    if (!id) { mesaj('Önce bir başvuru seçin.'); return true }
    await guvenli(async () => {
      const y = await api.acilHekimGordu(id);
      if (y.zatenVardi) {
        // SESSİZCE ÜZERİNE YAZMIYORUZ: ilk görme damgası kapı-hekim süresinin
        //   ölçüsü; yenilenseydi hedef tutturulmuş gibi görünürdü.
        mesaj('Hekimin gördüğü an zaten kayıtlı - değiştirilmedi.');
        return;
      }
      const s = y.sure;
      mesaj(`Hekim görme kaydedildi. Kapı-hekim: ${s?.kapiHekimDk ?? '—'} dk`
          + (s?.hedefDk != null ? ` (hedef ${s.hedefDk} dk`
              + `, ${s.hedefeUyuldu === 1 ? 'uyuldu' : 'aşıldı'})` : ''));
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------------------- yatak ----
  if (kod === 'acil.yatak-ver') {
    if (!id) { mesaj('Önce bir başvuru seçin.'); return true }
    await guvenli(async () => {
      const y = await api.liste('acilYatak', {
        sayfa: 1, boyut: 100,
        filtre: { op: 'and', kosullar: [
          { alan: 'aktif', op: 'esit', deger: 1 },
          // YALNIZ BOŞ YATAK: dolu ya da temizlikteki yatağı seçeneğe koymak,
          //   sunucunun reddedeceği bir tıklamayı davet etmek olurdu.
          { alan: 'durum', op: 'esit', deger: 0 },
        ] },
      });
      const secenekler = [
        ...y.satirlar.map(r => ({
          kod: String(r.id), ad: `${r.kod ?? ''} · ${r.alanAdi ?? r.ad ?? ''}`,
        })),
        { kod: '0', ad: '— yatağı boşalt —' },
      ];
      if (secenekler.length === 1) { mesaj('Boş yatak yok.'); return }

      const secim = await listeSor('Yatak:', secenekler, secenekler[0].kod, 'Yatak');
      if (!secim) return;
      const yatakId = Number(secim) || null;
      await api.acilYatak(id, yatakId);
      mesaj(yatakId ? 'Yatak verildi.' : 'Yatak boşaltıldı (temizliğe düştü).');
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------------ çıkış kararı ----
  if (kod === 'acil.cikis-karar') {
    if (!id) { mesaj('Önce bir başvuru seçin.'); return true }
    b.cikisAc({
      basvuruId: id,
      protokolNo: satir?.protokolNo ? String(satir.protokolNo) : undefined,
      hastaAdi: satir?.hastaAd ? String(satir.hastaAd) : undefined,
    });
    return true;
  }

  // -------------------------------------------------------- çağrı açma ----
  if (kod === 'acil.cagri-ac') {
    if (!id) { mesaj('Önce bir başvuru seçin.'); return true }
    const tur = await listeSor('Çağrı türü:', CAGRI_TURU, '1', 'Tür');
    if (!tur) return true;
    await guvenli(async () => {
      await api.acilCagriAc(id, { tur: Number(tur) });
      mesaj('Çağrı açıldı. Yanıt saati girilene kadar bekleme süresi işler.');
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------- çağrı durumu (liste) ----
  if (kod === 'acil.cagri-yanit' || kod === 'acil.cagri-kapat'
      || kod === 'acil.cagri-tekrar') {
    if (!id) { mesaj('Önce bir çağrı seçin.'); return true }
    const durum = kod === 'acil.cagri-yanit' ? 1 : kod === 'acil.cagri-kapat' ? 2 : 3;

    if (durum === 3 && !await onay(
      'Çağrı "yanıt yok" olarak işaretlensin ve tekrar çağrılsın mı?\n\n'
      + 'Tekrar sayacı artar; bekleme süresi KAPANMAZ.')) return true;

    await guvenli(async () => {
      const y = await api.acilCagriYanit(id, durum);
      const c = y.cagri;
      mesaj(durum === 3
        ? `Tekrar çağrıldı (${c.tekrarSayi}. kez).`
        : `Çağrı ${durum === 1 ? 'yanıtlandı' : 'kapatıldı'}`
          + (c.yanitDk != null ? ` — yanıt süresi ${c.yanitDk} dk.` : '.'));
      b.tazele();
    });
    return true;
  }

  // -------------------------------------------------- yatak temizlendi ----
  if (kod === 'acil.yatak-temizlendi') {
    if (!id) { mesaj('Önce bir yatak seçin.'); return true }
    await guvenli(async () => {
      await api.acilYatakTemizlendi(id);
      mesaj('Yatak boşa alındı.');
      b.tazele();
    });
    return true;
  }

  return false;
}
