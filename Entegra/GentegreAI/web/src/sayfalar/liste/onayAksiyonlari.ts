import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { tutarOku } from '../../bilesenler/bicim';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * ONAY GELEN KUTUSU AKSİYONLARI (738/739).
 *
 * KARAR KUTUDAN VERİLİR. Kullanıcıyı kaydın kendi ekranına yollamak, tek
 * kutunun anlamını ortadan kaldırırdı - onay kuyruğu zaten "sırayla bak,
 * karar ver" işidir; her satır için başka bir ekrana gidip dönmek o işi
 * gezinmeye çevirir.
 *
 * KURAL SUNUCUDA: hangi basamağın açık olduğunu, kimin imzalayabileceğini ve
 * zincirin nereye gittiğini uç bilir. Ekran yalnız kararı iletir ve sunucunun
 * reddini kullanıcıya gösterir.
 */
export interface OnayBaglam {
  tazele(): void;
  git?(yol: string): void;
}

/** kaynak_tur (= islem_log.tablo_id) -> kaydın kendi ekranı. */
const KAYIT_YOLU: Record<number, string> = {
  1241: '/satinalma-talep',
};

const ROL_ADI: Record<number, string> = {
  1: 'Birim sorumlusu', 2: 'Satınalma', 3: 'Başhekim / Müdür',
  4: 'Mali işler', 5: 'Üst yönetim',
};

export async function onayAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: OnayBaglam,
): Promise<boolean> {
  // ======================================================= akış tanımı ==
  if (kod === 'onay-akis.dene' || kod === 'onay-akis.yuruyenler') {
    const akisId = Number(satir?.id ?? 0);
    if (!akisId) { mesaj('Önce bir akış seçin.'); return true }

    if (kod === 'onay-akis.yuruyenler') {
      // Kutu ZATEN tüm türleri gösteriyor; akıştan oraya süzgeçle gidilir.
      b.git?.('/onay-kutusu');
      return true;
    }

    // DENEME KAYIT ÜRETMEZ: eşiği değiştiren kişi sonucunu gerçek bir talep
    //   açmadan görmeli - yoksa akışın doğru kurulup kurulmadığı ancak ilk
    //   gerçek talepte, yanlış kişiye düşünce anlaşılır.
    const ham = await metinSor(
      `"${satir?.ad ?? 'Akış'}" denenecek.\n\n`
      + `${satir?.olcuAdi || 'Karar ölçüsü'} değeri kaç olsun?`,
      '0', satir?.olcuAdi ? String(satir.olcuAdi) : 'Ölçü');
    if (ham === null) return true;

    const bayrakHam = await metinSor(
      'Bayrak koşulları (virgülle) - yoksa boş bırakın:\n'
      + 'Satınalmada kullanılanlar: butce · butce_asildi',
      '', 'Bayraklar');
    if (bayrakHam === null) return true;

    await guvenli(async () => {
      const y = await api.onayAkisDene(akisId, tutarOku(ham),
        bayrakHam.split(',').map(x => x.trim()).filter(Boolean));

      const basliklar = [
        `${y.akisAd} · ${y.olcuAdi || 'ölçü'}: ${ham}`
        + (y.bayraklar.length ? ` · bayrak: ${y.bayraklar.join(', ')}` : ''),
        `Tanımlı ${y.tanimliBasamak} basamaktan ${y.adimlar.length} tanesi çıkıyor:`,
        '',
      ];
      const satirlar = y.adimlar.map(a =>
        `${a.sira}. ${a.ad} — ${a.sahipTuru === 2 ? 'kullanıcı'
                                : a.sahipTuru === 3 ? 'âmir'
                                : ROL_ADI[a.rol] ?? `rol ${a.rol}`}`
        + (a.sureGun > 0 ? ` · ${a.sureGun} gün` : '')
        + (a.eImza === 1 ? ' · e-imza' : ''));

      mesaj([...basliklar, ...(satirlar.length ? satirlar : ['(basamak yok)']),
             ...(y.uyarilar.length ? ['', ...y.uyarilar] : [])].join('\n'));
    });
    return true;
  }

  if (!kod.startsWith('onay-kutusu.')) return false;

  const kaynakTur = Number(satir?.kaynakTur ?? 0);
  const kaynakId = Number(satir?.kaynakId ?? 0);
  if (!kaynakTur || !kaynakId) { mesaj('Önce bir kayıt seçin.'); return true }

  const kayitNo = String(satir?.kayitNo ?? kaynakId);

  // ------------------------------------------------------------- karar --
  const KARARLAR: Record<string, 'onayla' | 'reddet' | 'bilgi-iste' | 'sozlu-onay'> = {
    'onay-kutusu.onayla': 'onayla',
    'onay-kutusu.reddet': 'reddet',
    'onay-kutusu.bilgi': 'bilgi-iste',
    'onay-kutusu.sozlu': 'sozlu-onay',
  };

  if (KARARLAR[kod]) {
    const karar = KARARLAR[kod];
    let gerekce = '';

    // GEREKÇE RET VE BİLGİ İSTEĞİNDE ZORUNLU (sunucu da ister): "hayır"
    //   demek tek başına bir karar değil, talebi açan kişiye bir şey
    //   söylemiyor.
    if (karar === 'reddet' || karar === 'bilgi-iste') {
      const g = await metinSor(
        karar === 'reddet' ? `${kayitNo} reddedilecek. Gerekçe:`
                           : `${kayitNo} için ne bilgi isteniyor?`,
        '', 'Gerekçe');
      if (!g) return true;
      gerekce = g;
    }

    // SÖZLÜ ONAY KALICI KAYIT DEĞİLDİR: yazılı tamamlanma süresi izlenir,
    //   kullanıcı bunu karar anında bilmeli.
    if (karar === 'sozlu-onay' && !await onay(
      `${kayitNo} SÖZLÜ olarak onaylanacak. Yazılı tamamlanmazsa askıda kalır. `
      + 'Sürdürülsün mü?')) return true;

    if (karar === 'reddet' && !await onay(
      `${kayitNo} REDDEDİLECEK ve zincir kapanacak. Emin misiniz?`, true))
      return true;

    await guvenli(async () => {
      const y = await api.onayKarar(kaynakTur, kaynakId, { karar, gerekce });
      // ZİNCİR DURUMU SÖYLENİR: "onayladım, bitti mi" sorusunun yanıtı
      //   karar anında verilmeli - listeye bakıp çıkarmak zorunda kalmasın.
      const bitti = y.zincirDurum !== 0;
      const satirlar = [
        `${y.adim}: ${karar === 'onayla' ? 'onaylandı'
                     : karar === 'reddet' ? 'reddedildi'
                     : karar === 'sozlu-onay' ? 'sözlü onay verildi'
                     : 'bilgi istendi'}.`,
      ];
      if (karar === 'bilgi-iste')
        satirlar.push('Zincir DURDU ama kapanmadı - yanıt gelince aynı basamak sürer.');
      else if (bitti)
        satirlar.push(y.zincirDurum === 1
          ? 'Zincir tamamlandı, kayıt onaylandı.'
          : 'Zincir kapandı, kayıt reddedildi.');
      else
        satirlar.push(`Sıradaki basamak: ${y.sonrakiBasamak}.`);
      if (y.yaziliSon)
        satirlar.push(`Yazılı tamamlama süresi: ${new Date(y.yaziliSon).toLocaleString('tr-TR')}`);
      mesaj(satirlar.join('\n'));
      b.tazele();
    });
    return true;
  }

  // -------------------------------------------------------- kayda git --
  if (kod === 'onay-kutusu.kayda-git') {
    const yol = KAYIT_YOLU[kaynakTur];
    if (!yol) {
      mesaj(`Bu kayıt türünün ekranı tanımlı değil (tür ${kaynakTur}).`);
      return true;
    }
    b.git?.(`${yol}/${kaynakId}`);
    return true;
  }

  // ------------------------------------------------------- zinciri gör --
  if (kod === 'onay-kutusu.zincir') {
    await guvenli(async () => {
      const y = await api.onayZinciri(kaynakTur, kaynakId);
      if (!y.onay) { mesaj('Bu kayıtta onay zinciri yok.'); return }
      const DURUM: Record<number, string> = {
        0: 'bekliyor', 1: 'ONAYLANDI', 2: 'REDDEDİLDİ',
        3: 'bilgi istendi', 4: 'sözlü onay', 5: 'atlandı',
      };
      const satirlar = y.adimlar.map(a =>
        `${a.sira}. ${a.ad} — ${DURUM[a.durum] ?? a.durum}`
        + (a.kararZamani ? ` · ${new Date(a.kararZamani).toLocaleString('tr-TR')}` : '')
        + (a.gerekce ? `\n     ${a.gerekce}` : ''));
      mesaj([`${y.onay.akisAd} · ${y.onay.olcuAdi}: ${y.onay.olcu}`, '',
             ...satirlar].join('\n'));
    });
    return true;
  }

  return false;
}
