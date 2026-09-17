import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';
import type { IzinBakiyesi } from '../../api/uclar/izin';

/**
 * İZİN AKSİYONLARI (743).
 *
 * KURAL SUNUCUDA: gün sayısı, bakiye, âmir bağı ve zincir uçta. Ekran
 * yalnız düğmeyi uca bağlar ve sunucunun reddini kullanıcıya gösterir.
 *
 * ONAY DÜĞMESİ BURADA YOK: karar onay kutusundan (738) ya da kaydın kendi
 * zincirinden verilir. İzin ekranına ikinci bir onay yolu koymak, aynı
 * kararı iki ayrı yerde farklı kurallarla vermek olurdu.
 */
export interface IzinBaglam {
  tazele(): void;
  git?(yol: string): void;
}

/** Bakiyeyi tek satırda okunur yazar. */
function bakiyeMetni(b: IzinBakiyesi): string {
  if (b.hakGun === null)
    return `${b.personelAd}: işe giriş tarihi girilmemiş - hak hesaplanamıyor.`;
  return `${b.personelAd} · ${b.yil}\n`
    + `Hak ${b.hakGun} + devir ${b.devirGun} + ek ${b.ekGun}\n`
    + `Kullanılan ${b.kullanilanGun} · planlanan ${b.planlananGun}`
    + ` · onayda ${b.onaydaGun}\n`
    + `KALAN: ${b.kalan} gün`
    + (b.not ? `\n${b.not}` : '');
}

export async function izinAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: IzinBaglam,
): Promise<boolean> {
  // ------------------------------------------------ millî tatil üret --
  if (kod === 'resmi-tatil.yil-uret') {
    const ham = await metinSor(
      'Hangi yılın millî tatilleri üretilsin?\n\n'
      + 'Dinî bayramlar DÂHİL DEĞİLDİR: hicrî takvime bağlıdırlar ve '
      + 'Diyanet takvimine göre elle girilir.',
      String(new Date().getFullYear()), 'Yıl');
    if (!ham) return true;
    await guvenli(async () => {
      const y = await api.resmiTatilUret(Number(ham));
      mesaj([`${y.yil}: ${y.eklenen} millî tatil yazıldı`
             + (y.eklenen === 0 ? ' (zaten tanımlıydı).' : '.'),
             ...(y.uyarilar.length ? ['', ...y.uyarilar] : [])].join('\n'));
      b.tazele();
    });
    return true;
  }

  // MASRAF VE BELGE TALEBİ DE BU DOSYADA: hepsi aynı omurgayı (onay zinciri
  //   + âmir) kullanıyor, ayrı dosya açmak aynı deseni dört yerde tutmak
  //   olurdu.
  if (!kod.startsWith('personel-izin.') && !kod.startsWith('izin-bakiye.')
      && !kod.startsWith('personel-avans.') && !kod.startsWith('personel-masraf.')
      && !kod.startsWith('personel-belge-talep.')) return false;

  const id = Number(satir?.id ?? 0);
  const tarafId = Number(satir?.tarafId ?? 0);

  // =========================================================== MASRAF ==
  if (kod.startsWith('personel-masraf.')) {
    if (!id) { mesaj('Önce bir masraf beyanı seçin.'); return true }

    if (kod === 'personel-masraf.gonder') {
      await guvenli(async () => {
        const y = await api.masrafGonder(id);
        mesaj([`${y.toplamTutar} TL'lik beyan onaya gönderildi.`,
               `Zincir: ${y.basamaklar.map(a => a.ad).join(' → ')}`,
               '', 'Ödeme bu modülde YAPILMAZ - zincir onayla biter, '
                 + 'ödemeyi muhasebe kendi akışında yapar.'].join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'personel-masraf.zincir') {
      await guvenli(async () => {
        // 1312 = personel_masraf (islem_log.tablo_id).
        const y = await api.onayZinciri(1312, id);
        if (!y.onay) { mesaj('Bu beyan onaya gönderilmemiş.'); return }
        const DURUM: Record<number, string> = {
          0: 'bekliyor', 1: 'ONAYLANDI', 2: 'REDDEDİLDİ',
          3: 'bilgi istendi', 4: 'sözlü onay', 5: 'atlandı',
        };
        mesaj([`${y.onay.akisAd} · ${y.onay.olcuAdi}: ${y.onay.olcu}`, '',
               ...y.adimlar.map(a => `${a.sira}. ${a.ad} — ${DURUM[a.durum] ?? a.durum}`
                 + (a.gerekce ? `\n     ${a.gerekce}` : ''))].join('\n'));
      });
      return true;
    }

    if (kod === 'personel-masraf.iptal') {
      const gerekce = await metinSor('Masraf beyanı iptal edilecek. Gerekçe:',
                                     '', 'Gerekçe');
      if (!gerekce) return true;
      await guvenli(async () => {
        await api.masrafIptal(id, gerekce);
        mesaj('Beyan iptal edildi, varsa onay zinciri kapandı. Kayıt silinmedi - '
            + '"bu harcama talep edilmiş miydi" sorusu sonradan da sorulur.');
        b.tazele();
      });
      return true;
    }
    return false;
  }

  // ==================================================== BELGE TALEBİ ==
  if (kod.startsWith('personel-belge-talep.')) {
    if (!id) { mesaj('Önce bir belge talebi seçin.'); return true }

    if (kod === 'personel-belge-talep.hazirla') {
      const not = await metinSor('Belge hazırlandı. Not (isteğe bağlı):', '', 'Not');
      if (not === null) return true;
      await guvenli(async () => {
        await api.belgeTalepHazirla(id, not.trim() || undefined);
        mesaj('Belge hazırlandı olarak işaretlendi. Teslim edilince '
            + '"Teslim Edildi" ile kapatın - personelin beklediği şey belgenin '
            + 'kendisi.');
        b.tazele();
      });
      return true;
    }

    if (kod === 'personel-belge-talep.teslim') {
      const not = await metinSor('Belge teslim edildi. Not (isteğe bağlı):', '', 'Not');
      if (not === null) return true;
      await guvenli(async () => {
        await api.belgeTalepTeslim(id, not.trim() || undefined);
        mesaj('Belge teslim edildi; talep kapandı.');
        b.tazele();
      });
      return true;
    }

    if (kod === 'personel-belge-talep.zincir') {
      await guvenli(async () => {
        // 1314 = personel_belge_talep (islem_log.tablo_id).
        const y = await api.onayZinciri(1314, id);
        if (!y.onay) {
          // OTOMATİK ONAYDA ZİNCİR KURULMAZ: boş bir zinciri "yok" diye
          //   göstermek yerine sebebini söylüyoruz.
          mesaj('Bu talepte onay zinciri yok.\n\n'
              + 'Belge talepleri "ik.belge_talep_otomatik" ayarı açıkken '
              + 'otomatik onaylanır ve doğrudan hazırlık kuyruğuna düşer.');
          return;
        }
        const DURUM: Record<number, string> = {
          0: 'bekliyor', 1: 'ONAYLANDI', 2: 'REDDEDİLDİ',
          3: 'bilgi istendi', 4: 'sözlü onay', 5: 'atlandı',
        };
        mesaj([y.onay.akisAd, '',
               ...y.adimlar.map(a => `${a.sira}. ${a.ad} — ${DURUM[a.durum] ?? a.durum}`
                 + (a.gerekce ? `\n     ${a.gerekce}` : ''))].join('\n'));
      });
      return true;
    }

    if (kod === 'personel-belge-talep.reddet') {
      const gerekce = await metinSor(
        'Belge talebi reddedilecek. Gerekçe (personele söylenecek):', '', 'Gerekçe');
      if (!gerekce) return true;
      await guvenli(async () => {
        await api.belgeTalepReddet(id, gerekce);
        mesaj('Talep reddedildi.');
        b.tazele();
      });
      return true;
    }
    return false;
  }

  // ============================================================ AVANS ==
  if (kod.startsWith('personel-avans.')) {
    if (!id) { mesaj('Önce bir avans seçin.'); return true }

    if (kod === 'personel-avans.gonder') {
      await guvenli(async () => {
        const y = await api.avansGonder(id);
        const satirlar = [
          `${y.tutar} TL avans onaya gönderildi.`,
          `Zincir: ${y.basamaklar.map(a => a.ad).join(' → ')}`,
        ];
        // AÇIK AVANS ENGEL DEĞİL, BASAMAK: üstüne avans ayrı bir karardır.
        if (y.bayraklar.includes('acik_avans'))
          satirlar.push('', 'Personelin açık avansı var - zincire "İK (açık avans)" '
                            + 'basamağı eklendi.');
        mesaj(satirlar.join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'personel-avans.ode') {
      // ÖDEME KASADAN GEÇER: hangi hesaptan çıktığı sorulmadan para
      //   çıkarılmaz - kasa bakiyesi avansı görmeli.
      const hesap = await metinSor(
        'Ödemenin çıkacağı kasa/banka hesabının numarası:', '', 'Hesap');
      if (!hesap) return true;
      const nakit = await onay('Nakit ödeme mi? (Hayır = havale/EFT)');
      await guvenli(async () => {
        const y = await api.avansOde(id, {
          hesapId: Number(hesap), tur: nakit ? 31 : 32,
        });
        mesaj([`${y.tutar} TL ödendi (kasa işlemi #${y.kasaIslemId}).`,
               `${y.taksit} taksitlik kesinti planı açıldı.`,
               '', 'Mahsup bordroya YAZILMAZ - kesintiler bu ekrandan işaretlenir.']
              .join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'personel-avans.kesinti') {
      await guvenli(async () => {
        const y = await api.avansKesinti(id, {});
        mesaj([`${y.donem} dönemi kesintisi işlendi: ${y.tutar} TL (${y.sira}. taksit).`,
               y.kalanTaksit === 0
                 ? 'Son taksitti - avans KAPANDI.'
                 : `Kalan ${y.kalanTaksit} taksit.`].join('\n'));
        b.tazele();
      });
      return true;
    }

    if (kod === 'personel-avans.zincir') {
      await guvenli(async () => {
        // 1257 = personel_avans (islem_log.tablo_id). 907 DEĞİL: o numara
        //   Hasta Bilgisi'nin, 753'te yanlışlıkla alınmıştı (755).
        const y = await api.onayZinciri(1257, id);
        if (!y.onay) { mesaj('Bu avans onaya gönderilmemiş.'); return }
        const DURUM: Record<number, string> = {
          0: 'bekliyor', 1: 'ONAYLANDI', 2: 'REDDEDİLDİ',
          3: 'bilgi istendi', 4: 'sözlü onay', 5: 'atlandı',
        };
        mesaj([`${y.onay.akisAd} · ${y.onay.olcuAdi}: ${y.onay.olcu}`, '',
               ...y.adimlar.map(a => `${a.sira}. ${a.ad} — ${DURUM[a.durum] ?? a.durum}`
                 + (a.gerekce ? `\n     ${a.gerekce}` : ''))].join('\n'));
      });
      return true;
    }

    if (kod === 'personel-avans.iptal') {
      const gerekce = await metinSor('Avans iptal edilecek. Gerekçe:', '', 'Gerekçe');
      if (!gerekce) return true;
      await guvenli(async () => {
        await api.avansIptal(id, gerekce);
        mesaj('Avans iptal edildi, varsa onay zinciri kapandı.');
        b.tazele();
      });
      return true;
    }
    return false;
  }


  // ------------------------------------------------------ onaya gönder --
  if (kod === 'personel-izin.gonder') {
    if (!id) { mesaj('Önce bir izin seçin.'); return true }
    await guvenli(async () => {
      const y = await api.izinGonder(id);
      const satirlar = [
        `${y.gun} günlük izin onaya gönderildi.`,
        `Zincir: ${y.basamaklar.map(a => a.ad).join(' → ')}`,
      ];
      // BAKİYE AŞIMI ENGEL DEĞİL, BASAMAK: kullanıcı bunu karar anında
      //   bilmeli - "onaya gitti" deyip geçmek, fazladan bir imzanın neden
      //   istendiğini gizlerdi.
      if (y.bayraklar.includes('bakiye_asildi'))
        satirlar.push('', 'Bakiye aşıldı - zincire "İK (bakiye aşımı)" basamağı eklendi.');
      // AÇIK RANDEVU: izin onaylanınca takvim kapanır ama randevular
      //   taşınmaz - onaylayan bunu karar anında bilmeli.
      if (y.randevu > 0)
        satirlar.push('', `Bu tarihlerde ${y.randevu} randevu var - onaylanırsa `
                          + 'takvim kapanır ama randevular taşınmaz.');
      satirlar.push('', bakiyeMetni(y.bakiye));
      mesaj(satirlar.join('\n'));
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------------------ bakiye --
  if (kod === 'personel-izin.bakiye' || kod === 'izin-bakiye.izin-ac') {
    const kisi = tarafId || Number(satir?.tarafId ?? 0);
    if (!kisi) { mesaj('Önce bir personel seçin.'); return true }

    if (kod === 'personel-izin.bakiye') {
      await guvenli(async () => mesaj(bakiyeMetni(await api.izinBakiye(kisi))));
      return true;
    }

    // BAKİYE EKRANINDAN TALEP AÇMA: İK izin döneminde bakiyeye bakarken
    //   talebi de oradan açar - kişiyi ikinci ekranda yeniden aratmak
    //   aynı işi iki kez yaptırırdı.
    const bas = await metinSor('İzin başlangıç tarihi (YYYY-AA-GG):', '', 'Başlangıç');
    if (!bas) return true;
    const bit = await metinSor('İzin bitiş tarihi (YYYY-AA-GG):', bas, 'Bitiş');
    if (!bit) return true;

    await guvenli(async () => {
      const y = await api.izinAc({ tarafId: kisi, tur: 1, baslangic: bas, bitis: bit });
      mesaj([`${y.gun} günlük izin talebi açıldı (taslak).`,
             ...(y.uyarilar.length ? ['', ...y.uyarilar] : []),
             '', bakiyeMetni(y.bakiye),
             '', 'Onaya göndermek için İzin Talepleri ekranını kullanın.'].join('\n'));
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------------ onay zinciri --
  if (kod === 'personel-izin.zincir') {
    if (!id) { mesaj('Önce bir izin seçin.'); return true }
    await guvenli(async () => {
      // 904 = personel_izin (islem_log.tablo_id) - onay omurgasının kaynak türü.
      const y = await api.onayZinciri(904, id);
      if (!y.onay) { mesaj('Bu izin henüz onaya gönderilmemiş.'); return }
      const DURUM: Record<number, string> = {
        0: 'bekliyor', 1: 'ONAYLANDI', 2: 'REDDEDİLDİ',
        3: 'bilgi istendi', 4: 'sözlü onay', 5: 'atlandı',
      };
      mesaj([`${y.onay.akisAd} · ${y.onay.olcuAdi}: ${y.onay.olcu}`, '',
             ...y.adimlar.map(a =>
               `${a.sira}. ${a.ad} — ${DURUM[a.durum] ?? a.durum}`
               + (a.kararZamani ? ` · ${new Date(a.kararZamani).toLocaleString('tr-TR')}` : '')
               + (a.gerekce ? `\n     ${a.gerekce}` : ''))].join('\n'));
    });
    return true;
  }

  // ------------------------------------------------------------- iptal --
  if (kod === 'personel-izin.iptal') {
    if (!id) { mesaj('Önce bir izin seçin.'); return true }
    const gerekce = await metinSor(
      'İzin iptal edilecek. Gerekçe (personel vazgeçti, kurum geri çağırdı…):',
      '', 'Gerekçe');
    if (!gerekce) return true;
    if (!await onay('İzin İPTAL edilecek ve varsa onay zinciri kapanacak. Emin misiniz?',
                    true)) return true;
    await guvenli(async () => {
      await api.izinIptal(id, gerekce);
      mesaj('İzin iptal edildi. Kayıt silinmedi - "bu izin alınmış mıydı" '
            + 'sorusu sonradan da sorulur.');
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------- hakediş tanımlama --
  if (kod === 'izin-bakiye.hak-tanimla') {
    if (!tarafId) { mesaj('Önce bir personel seçin.'); return true }
    b.git?.(`/personel-izin-hak/yeni?tarafId=${tarafId}`);
    return true;
  }

  return false;
}
