import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * TEKNİK SERVİS AKSİYONLARI (773).
 *
 * KURAL SUNUCUDA: SLA, toplam, durum geçişleri ve iki kapı - imzasız ziyaret
 * kapanmaz, açık emanetle iş emri teslim edilmez - uçtadır. Ekran yalnız
 * düğmeyi uca bağlar ve reddi kullanıcıya olduğu gibi gösterir.
 *
 * Kararı ekranda tekrar etmiyoruz: burada da kontrol edilseydi iki kural
 * bir gün ayrışır ve ekran "olur" derken sunucu "olmaz" derdi.
 */
export interface ServisBaglam {
  tazele(): void;
  git?(yol: string): void;
}

export async function servisAksiyonu(
  kod: string, satir: ListeSatiri | null | undefined, b: ServisBaglam,
): Promise<boolean> {
  if (!kod.startsWith('servis-') && !kod.startsWith('taraf-cihaz.')) return false;

  const id = Number(satir?.id ?? 0);

  // ======================================================== ÇAĞRI ==
  if (kod.startsWith('servis-cagri.')) {
    if (!id) { mesaj('Önce bir çağrı seçin.'); return true }

    if (kod === 'servis-cagri.is-emri') {
      if (!await onay('Bu çağrı için iş emri açılacak. Çağrı "atandı" olarak '
                    + 'işaretlenecek ve ilk yanıt zamanı damgalanacak.')) return true;
      await guvenli(async () => {
        const y = await api.servisIsEmriAc(id);
        mesaj([`İş emri açıldı: ${y.isEmriNo || `#${y.id}`}`, '',
               'İş emri listesinden ziyaret başlatabilir, emanet cihaz '
                 + 'verebilirsiniz.'].join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'servis-cagri.cihaz-parki') {
      const tarafId = Number(satir?.tarafId ?? 0);
      if (!tarafId) { mesaj('Çağrının müşterisi okunamadı.'); return true }
      await guvenli(async () => {
        const y = await api.servisCihazParki(tarafId);
        if (y.satirlar.length === 0) {
          mesaj('Bu müşterinin cihaz parkında kayıt yok.\n\n'
              + 'Servisini verdiğimiz cihaz parka girilirse garanti ve '
              + 'sözleşme durumu her çağrıda kendiliğinden gelir.');
          return;
        }
        const GARANTI: Record<number, string> = {
          0: 'garanti bilinmiyor', 1: 'garanti sürüyor', 2: 'garanti bitti',
        };
        mesaj(y.satirlar.map(c =>
          `${c.ad} ${c.markaModel}`.trim()
          + (c.seriNo ? ` · S/N ${c.seriNo}` : '')
          + `\n   ${GARANTI[c.garantiDurum] ?? ''}`
          + (c.sozlesmeId ? ' · sözleşmeli' : ' · sözleşmesiz')
          + ` · ${c.cagriSayisi} çağrı`).join('\n\n'));
      });
      return true;
    }
    return false;
  }

  // ====================================================== İŞ EMRİ ==
  if (kod.startsWith('servis-is-emri.')) {
    if (!id) { mesaj('Önce bir iş emri seçin.'); return true }

    if (kod === 'servis-is-emri.ziyaret') {
      const arac = await metinSor('Ziyaret başlatılıyor. Araç (isteğe bağlı):',
                                  '', 'Plaka');
      if (arac === null) return true;
      await guvenli(async () => {
        const y = await api.servisZiyaretAc(id, { arac: arac.trim() || undefined });
        mesaj([`${y.sira}. ziyaret başladı, varış damgalandı.`, '',
               'Ziyaretler listesinden "Ziyareti Kapat" ile yapılan işi, '
                 + 'süreyi ve müşteri imzasını girin.'].join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'servis-is-emri.emanet') {
      const cihaz = await metinSor(
        'Müşteriye verilecek emanet / yerine konacak yedek cihaz:', '', 'Cihaz');
      if (!cihaz) return true;
      await guvenli(async () => {
        const y = await api.servisEmanetVer(id, { cihazMetni: cihaz });
        mesaj([`Emanet kaydı açıldı: ${y.emanetNo || `#${y.id}`}`, '',
               'Emanet cihaz stoktan DÜŞMEZ, ayrı izlenir. İade alınmadan '
                 + 'iş emri kapanmaz - kapanan iş emriyle unutulan emanet, '
                 + 'envanterde "depoda" yazan ama sahada duran cihaz demektir.'
              ].join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'servis-is-emri.teslim') {
      const not = await metinSor('Teslim ediliyor. Not (isteğe bağlı):', '', 'Not');
      if (not === null) return true;
      await guvenli(async () => {
        const y = await api.servisTeslim(id, not.trim() || undefined);
        mesaj([`Teslim edildi. ${y.ziyaret} ziyaret · toplam ${y.toplamTutar} ₺`,
               '', y.mesaj].join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'servis-is-emri.ziyaretler') {
      b.git?.(`/servis-ziyaret?isEmriId=${id}`);
      return true;
    }
    return false;
  }

  // ====================================================== ZİYARET ==
  if (kod === 'servis-ziyaret.kapat') {
    if (!id) { mesaj('Önce bir ziyaret seçin.'); return true }
    if (Number(satir?.sonuc ?? 0) !== 0) {
      mesaj('Bu ziyaret zaten kapatılmış.');
      return true;
    }

    const yapilan = await metinSor('Yapılan iş:', '', 'Ne yapıldı');
    if (!yapilan) return true;
    const cozuldu = await onay('Arıza çözüldü mü?\n\n'
      + 'Hayır derseniz çağrı AÇIK kalır - ikinci gidiş gerekiyor demektir '
      + 've "ilk gidişte çözüm" oranı buradan düşer.');
    // İMZA: alınamadıysa gerekçe zorunlu. Uç da kontrol ediyor; burada
    //   soruyoruz ki kullanıcı reddi görmeden önce cevabı versin.
    const imza = await onay('Müşteri imzası alındı mı?');
    let imzaNotu: string | null = '';
    if (!imza) {
      imzaNotu = await metinSor('İmza neden alınamadı? (zorunlu)', '', 'Gerekçe');
      if (!imzaNotu) return true;
    }
    const km = await metinSor('Yol (km) — isteğe bağlı:', '', 'km');
    if (km === null) return true;

    await guvenli(async () => {
      const y = await api.servisZiyaretKapat(id, {
        yapilan, sonuc: cozuldu ? 1 : 2,
        yolKm: km.trim() ? Number(km.replace(',', '.')) : undefined,
        imzaAlindi: imza, imzaNotu: imzaNotu || undefined,
      });
      mesaj([y.mesaj, `İş emri toplamı: ${y.toplamTutar} ₺`].join('\n'));
      b.tazele();
    });
    return true;
  }

  // ======================================================= EMANET ==
  if (kod === 'servis-emanet.iade') {
    if (!id) { mesaj('Önce bir emanet kaydı seçin.'); return true }
    if (!await onay('Emanet cihaz iade alındı olarak işaretlenecek.')) return true;
    await guvenli(async () => {
      await api.servisEmanetIade(id);
      mesaj('İade alındı. İş emri artık teslim edilebilir.');
      b.tazele();
    });
    return true;
  }

  return false;
}
