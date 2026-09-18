import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * TELERADYOLOJI WORKLIST AKSIYONLARI (799).
 *
 * 797'de `telerad.ata` / `telerad.teslim` yetkileri rollere dagitilmisti ama
 * onlari kullanan bir aksiyon yoktu; ekranin arac cubugu da yoktu. Isin akisi
 * (ata - oku - teslim) yalniz kartta "Durum" kutusunu elle degistirerek
 * ilerletilebiliyordu.
 *
 * <b>Damgalari EKRAN YAZMAZ:</b> okuma baslangici, onay ve teslim zamani
 * `tg_telerad_istek` icinde dogar (799). Buradan yalnizca DURUM ve ATAMA
 * gonderilir - ayni sayi iki yerden hesaplanmasin.
 *
 * Donus: aksiyon burada ele alindiysa true.
 */
export interface TeleradBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Oturumun taraf kimligi - "Bana Ata" bunu yazar. */
  kullaniciId: number;
}

/** Karti oku, tek alan guncelle: surum damgasi optimistik kilidi tasir. */
async function istekGuncelle(id: number, kart: Record<string, unknown>) {
  const mevcut = await api.kartOku('telerad-istek', id);
  await api.kartGuncelle('telerad-istek', id, { surum: mevcut.kart.surum, kart });
}

export async function teleradAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: TeleradBaglam,
): Promise<boolean> {
  if (!kod.startsWith('telerad.')) return false;
  // CRUD (yeni/duzenle/sil) generic kart yolunu kullanir: burada ele alinmaz.
  if (kod === 'telerad.yeni' || kod === 'telerad.duzenle' || kod === 'telerad.sil') return false;

  const id = satir ? Number(satir.id) : 0;
  const no = satir ? String(satir.istekNo ?? satir.id ?? '') : '';

  // DONEM FATURASI (803): kurum listesinden secili kurumla fatura ekranini
  //   acar. Faturayi ekran DEGIL sunucu uretir; buradan yalniz gecis var.
  if (kod === 'telerad.faturala') {
    if (!satir) return true;
    b.git(`/telerad-fatura?kurumId=${Number(satir.id)}`);
    return true;
  }

  // YAZISMA (806): istegin sohbetini acar ve Mesajlar ekranina gecer.
  //   Sohbeti ve uyelerini SUNUCU belirler - istemci kimi ekleyecegini
  //   bilmez (portal kullanicisi kurum ici personel listesini gormemeli).
  if (kod === 'telerad.mesaj') {
    if (!satir) return true;
    await guvenli(async () => {
      const sonuc = await api.teleradSohbet(Number(satir.id));
      b.git(`/mesajlar?sohbet=${sonuc.sohbetId}`);
    });
    return true;
  }

  // OTOMATIK DAGIT (801): siradaki atanmamis isler nobet cizelgesi ve atama
  //   kurallarina gore paylastirilir. KAYIT SECIMI ISTEMEZ - isi tek tek
  //   sectirmek "gece listeye bakan kimse yok" sorununu cozmezdi.
  //   KURALI SUNUCU YORUMLAR (`fn_telerad_radyolog_oner`): istemci kural
  //   bilmez, yalniz sonucu yazar.
  if (kod === 'telerad.dagit') {
    if (!(await onay(
          'Sıradaki atanmamış istekler nöbet çizelgesi ve atama kurallarına göre '
          + 'dağıtılsın mı? Kuralı uymayan iş sırada kalır.'))) return true;
    await guvenli(async () => {
      const sonuc = await api.teleradDagit();
      b.tazele();
      mesaj(sonuc.atanan > 0
        ? `${sonuc.atanan} istek atandı${sonuc.kalan > 0 ? `, ${sonuc.kalan} istek sırada kaldı` : ''}.`
        : sonuc.sirada === 0
          ? 'Dağıtılacak istek yok.'
          : 'Hiçbir istek atanmadı: kural uymadı ya da nöbetçi yok.');
    });
    return true;
  }

  // BANA ATA: atama durumu da yukseltir (tetik: atanan var + durum 2 -> 3).
  //   Radyolog olmayan kullaniciyi sunucu reddeder (alan `v_rad_hekim_lookup`
  //   ile sinirli) - istemci ikinci bir kural yazmaz.
  if (kod === 'telerad.ata') {
    if (!satir) return true;
    await guvenli(async () => {
      await istekGuncelle(id, { atananRadyologId: b.kullaniciId });
      b.tazele();
      mesaj(`${no} size atandı.`);
    });
    return true;
  }

  // BIRAK: atama kalkinca tetik durumu "sirada"ya geri alir. Onay ister -
  //   isi birakmak baskasinin kuyruguna tasimaktir.
  if (kod === 'telerad.birak') {
    if (!satir) return true;
    if (!(await onay(`${no} isteğinin ataması bırakılsın mı? İstek sıraya geri döner.`))) return true;
    await guvenli(async () => {
      await istekGuncelle(id, { atananRadyologId: null });
      b.tazele();
      mesaj(`${no} sıraya geri döndü.`);
    });
    return true;
  }

  // OKUMAYA BASLA: durum 4. Okuma damgasini tetik yazar (799) - "sirada
  //   bekleme" ile "okuma" suresini ayiran tek isaret odur.
  if (kod === 'telerad.oku') {
    if (!satir) return true;
    await guvenli(async () => {
      await istekGuncelle(id, { durum: 4 });
      b.tazele();
      mesaj(`${no} okumaya alındı.`);
    });
    return true;
  }

  // TESLIM: durum 7. Onay ister - teslim karsi kuruma "is bitti" demektir;
  //   raporu onaysiz istegi teslim etmek bos rapor gondermek olurdu, bunu
  //   sunucu tarafinda durum akisi engelliyor.
  if (kod === 'telerad.teslim') {
    if (!satir) return true;
    if (!(await onay(`${no} isteği gönderen kuruma teslim edilsin mi?`))) return true;
    await guvenli(async () => {
      // YOLU SUNUCU SECER (814): HL7 ORU kanalinda mesaj kuyruga girip
      //   gonderilir ve ACK beklenir; "Portal" kanalinda yalniz damga yazilir.
      //   Ekran kanal bilmez - ayni kural iki yerde yasamasin.
      const y = await api.teleradTeslim(id);
      b.tazele();
      if (y.yol === 'portal') { mesaj(`${no} teslim edildi.`); return }
      if (y.basarili) { mesaj(`${no} karşı sisteme gönderildi (ACK ${y.ackKodu}).`); return }
      // BASARISIZ GONDERIM SESSIZ GECILMEZ: is kuyrukta kaldi, kullanici
      //   nedenini simdi gormeli - kuyruk ekrani da ayrica listeliyor.
      mesaj(`${no} gönderilemedi: ${y.hata || 'karşı uç yanıt vermedi'}. `
            + 'İş teslim kuyruğunda, otomatik tekrar denenecek.');
    });
    return true;
  }

  // IPTAL: durum 0. Goruntu ve varsa rapor yerinde kalir - iptal isin
  //   "yapilmayacak" olmasidir, gecmisin silinmesi degil.
  if (kod === 'telerad.iptal') {
    if (!satir) return true;
    if (!(await onay(
          `${no} isteği iptal edilsin mi? Gelen görüntü ve yazılmış rapor kaydı yerinde kalır.`)))
      return true;
    await guvenli(async () => {
      await istekGuncelle(id, { durum: 0 });
      b.tazele();
      mesaj(`${no} iptal edildi.`);
    });
    return true;
  }

  // ---------------------------------------------------- TESLIM KUYRUGU ----
  // Kuyruk ekraninin satiri bir TESLIM kaydidir, istek degil: id de teslim
  //   id'sidir. Ayni aksiyon dosyasinda durmasi bilincli - ikisi de "raporun
  //   karsi tarafa gitmesi" isinin parcasi.
  if (kod === 'telerad.teslim_dene') {
    if (!satir) return true;
    await guvenli(async () => {
      const y = await api.teleradTeslimDene(id);
      b.tazele();
      mesaj(y.basarili
        ? `Teslim başarılı (ACK ${y.ackKodu}).`
        : `Gönderilemedi: ${y.hata || 'karşı uç yanıt vermedi'}.`);
    });
    return true;
  }

  if (kod === 'telerad.teslim_iptal') {
    if (!satir) return true;
    if (!(await onay('Bu teslim kuyruktan çıkarılsın mı? '
                   + 'Rapor karşı sisteme GÖNDERİLMEYECEK.'))) return true;
    await guvenli(async () => {
      await api.teleradTeslimIptal(id);
      b.tazele();
      mesaj('Teslim kuyruktan çıkarıldı.');
    });
    return true;
  }

  // ISTEGE GIT: kuyruktaki satirin isini acar - duzeltme orada yapilir.
  if (kod === 'telerad.teslim_istek') {
    if (!satir) return true;
    const istekId = Number(satir.istekId ?? 0);
    if (istekId > 0) b.git(`/telerad-istek/${istekId}`);
    return true;
  }

  // ------------------------------------------------------ GELEN RAPORLAR ----
  // Satır bir GELEN MESAJDIR; id de gelen kaydının id'sidir.
  if (kod === 'telerad.gelen_bagla') {
    if (!satir) return true;
    const acc = String(satir.accessionNo ?? '');
    // İSTEK NUMARASI SORULUR: accession tutmadığı için eşleşmemiş olan
    //   raporu hangi işe yazacağımıza İNSAN karar verir - eşleştirme kuralını
    //   gevşetmek yanlış hastaya rapor yazma riskidir.
    const no = await metinSor(
      `Gelen rapor (erişim no ${acc || '—'}) hangi isteğe bağlansın?`,
      '', 'İstek No (TR-…)');
    if (!no || !no.trim()) return true;

    await guvenli(async () => {
      const y = await api.liste('telerad-istek', {
        sayfa: 1, boyut: 2,
        filtre: { alan: 'istekNo', op: 'esit', deger: no.trim() },
      });
      if (y.satirlar.length === 0) { mesaj(`${no} numaralı istek bulunamadı.`); return }

      const istekId = Number(y.satirlar[0].id ?? 0);
      const s = await api.teleradGelenBagla(id, istekId);
      b.tazele();
      mesaj(s.mesaj || 'Rapor kaydedildi.');
    });
    return true;
  }

  if (kod === 'telerad.gelen_istek') {
    if (!satir) return true;
    const istekId = Number(satir.istekId ?? 0);
    if (istekId > 0) b.git(`/telerad-istek/${istekId}`);
    else mesaj('Bu rapor henüz bir isteğe bağlanmadı.');
    return true;
  }

  return false;
}
