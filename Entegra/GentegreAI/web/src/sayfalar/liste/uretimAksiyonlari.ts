import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';
import { UA_ISLEM_OLAYI, UE_ISLEM_OLAYI, UF_ISLEM_OLAYI, type UretimIslemOlayi } from '../uretim/uretimListeSeviye';

/**
 * ÜRETİM AKSİYONLARI (429) — ürün ağacı ve üretim emri.
 *
 * <b>Yapılamayacak adım gizlenmez.</b> "Onayla" düğmesi üretimdeki emirde de
 * görünür; sunucu "yalnız Taslak emir onaylanabilir" der. Gizlenen düğme
 * kullanıcıya neden yapamadığını söylemez - İTS ve doküman ekranlarında da
 * aynı gerekçe.
 *
 * <b>Sayısal girdiler metin olarak sorulur ve BURADA doğrulanır</b> (adet > 0):
 * sunucu da doğruluyor, ama bir tur gidip gelmeden söylemek daha hızlı.
 */
export interface UretimBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Kartı ekran sekmesinde açar (belge / emir bağları); yoksa git. */
  gitKart?(yol: string): void;
}

/** "12,5" -> 12.5. Türkçe klavyede ondalık ayırıcı virgüldür. */
function sayi(metin: string | null): number {
  if (metin === null) return NaN;
  return Number(metin.trim().replace(',', '.'));
}

export async function uretimAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: UretimBaglam,
): Promise<boolean> {
  if (!kod.startsWith('uretim.') && !kod.startsWith('urun-agaci.') && !kod.startsWith('uretim-fisi.')) return false;
  // Crud() uretim-emri.yeni / .duzenle / .sil uretir - onlar Liste'nin kendi
  //   kart akisi, burada ele alinmaz. Fişin Sil'i ise fişin kendi ucuna gider (aşağıda).
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle')) return false;
  if (kod.startsWith('uretim-fisi.')) return uretimFisiAksiyonu(kod, satir, b);
  if (kod.endsWith('.sil')) return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }

  switch (kod) {
    // ------------------------------------------------------------ ürün ağacı
    case 'urun-agaci.maliyet': {
      const g = await metinSor(
        'Genel üretim gideri yüzdesi (boş = 0):', '0', 'GÜG %');
      if (g === null) return true;
      const gug = sayi(g) || 0;
      await guvenli(async () => {
        const y = await api.uretimAgacMaliyet(id, gug);
        mesaj(`Malzeme ${y.malzeme.toFixed(2)} + İşçilik ${y.iscilik.toFixed(2)}`
            + (y.gug ? ` + GÜG ${y.gug.toFixed(2)}` : '')
            + ` = Birim maliyet ${y.toplam.toFixed(2)}`);
        b.tazele();
      });
      return true;
    }

    case 'urun-agaci.yeni-surum': {
      // ESKI SURUM SILINMEZ: acik emirler kendi surumunde yasar. Kullaniciya
      //   da boyle soylenir ki "eskisi ne oldu" sorusu kalmasin.
      if (!await onay('Ağacın yeni bir sürümü oluşturulsun mu?\n\n'
                    + 'Yeni sürüm TASLAK gelir ve varsayılan değildir; '
                    + 'eski sürüm silinmez, açık emirler onunla devam eder.')) return true;
      await guvenli(async () => {
        const y = await api.uretimYeniSurum(id);
        mesaj(y.mesaj);
        b.git(`/urun-agaci/${y.id}`);
      });
      return true;
    }

    case 'urun-agaci.nerede': {
      const stokId = Number(satir?.stokId ?? 0);
      if (!stokId) { mesaj('Bu ağacın mamul kartı okunamadı.'); return true }
      await guvenli(async () => {
        const y = await api.uretimNeredeKullaniliyor(stokId);
        mesaj(y.kayitlar.length === 0
          ? 'Bu stok hiçbir ürün ağacında bileşen olarak geçmiyor.'
          : y.kayitlar.map(k => `${k.kod} v${k.surum} · ${k.mamul} · ${k.miktar}`)
              .join('\n'));
      });
      return true;
    }

    case 'urun-agaci.emir-ac': {
      const a = await metinSor('Kaç adet üretilecek?', '1', 'Emir adedi');
      const adet = sayi(a);
      if (Number.isNaN(adet)) return true;
      if (adet <= 0) { mesaj('Adet sıfırdan büyük olmalı.'); return true }
      await guvenli(async () => {
        const y = await api.uretimEmriAc({
          stokId: Number(satir?.stokId ?? 0), agacId: id, adet,
        });
        mesaj(y.mesaj);
        b.git(`/uretim-emri/${y.id}`);
      });
      return true;
    }

    // REÇETE LİSTESİ (1257, mockup urun_agaci_listesi_v2.html). "Üret…" ve "Üretim Fişi Kes" fiş kartını mamul + adet dolu
    //   açar (fiş kartı reçeteyi mamulden bulur, malzemeyi doldurur); emir yok. Pasif / onay pencereleri üst panelde (olay).
    case 'urun-agaci.uret':
      // Basit "Üret…": tek adımlı pencere (mockup ②) üst panelde / kartta açılır.
      window.dispatchEvent(new CustomEvent<UretimIslemOlayi>(UA_ISLEM_OLAYI, { detail: { id, islem: 'uret', satir: satir ?? undefined } }));
      return true;
    case 'urun-agaci.fis-kes': {
      const stokId = Number(satir?.stokId ?? 0);
      if (!stokId) { mesaj('Bu reçetenin mamul kartı okunamadı.'); return true }
      const a = await metinSor('Kaç adet üretildi / üretilecek?', String(satir?.ciktiMiktar ?? 1), 'Üretim adedi');
      const adet = sayi(a);
      if (Number.isNaN(adet)) return true;
      if (adet <= 0) { mesaj('Adet sıfırdan büyük olmalı.'); return true }
      (b.gitKart ?? b.git)(`/uretim-fisi/yeni?stokId=${stokId}&miktar=${adet}`);
      return true;
    }
    case 'urun-agaci.kopyala':
      await guvenli(async () => {
        const y = await api.uretimAgacKopyala(id);
        mesaj(y.mesaj);
        (b.gitKart ?? b.git)(`/urun-agaci/${y.id}`);
      });
      return true;
    case 'urun-agaci.pasif':
    case 'urun-agaci.onaya-gonder':
    case 'urun-agaci.onayla':
      window.dispatchEvent(new CustomEvent<UretimIslemOlayi>(UA_ISLEM_OLAYI,
        { detail: { id, islem: kod.slice('urun-agaci.'.length) as UretimIslemOlayi['islem'], satir: satir ?? undefined } }));
      return true;
    case 'urun-agaci.mamul-ac': {
      const stokId = Number(satir?.stokId ?? 0);
      if (!stokId) { mesaj('Bu reçetenin mamul kartı okunamadı.'); return true }
      (b.gitKart ?? b.git)(`/stok/${stokId}`);
      return true;
    }

    // ---------------------------------------------------------- üretim emri
    case 'uretim.rezerve': {
      const ac = await onay('Emrin malzemesi rezerve edilsin mi?\n\n'
                          + '"Hayır" derseniz mevcut rezerv BIRAKILIR.');
      await guvenli(async () => {
        const y = await api.uretimRezerve(id, ac);
        mesaj(`${y.mesaj} Malzeme hazırlık: %${y.hazirlik}`);
        b.tazele();
      });
      return true;
    }

    case 'uretim.eksik':
      await guvenli(async () => {
        const y = await api.uretimEksikMalzeme(id);
        const eksikler = y.satirlar.filter(s => s.eksik > 0);
        mesaj(eksikler.length === 0
          ? `Malzeme tam: %${y.hazirlik}`
          : `Malzeme hazırlık %${y.hazirlik} · eksikler:\n`
            + eksikler.map(s => `${s.kod} ${s.ad}: gerekli ${s.gerekli}, `
                              + `depoda ${s.mevcut}, eksik ${s.eksik}`).join('\n'));
      });
      return true;

    case 'uretim.onayla':
      await guvenli(async () => {
        mesaj((await api.uretimOnayla(id)).mesaj);
        b.tazele();
      });
      return true;

    // SERBEST BIRAK (1253 / 1254): denetimlide ön kontrol + gerekçe + parola (e-imza) - pencere listenin üst
    //   panelinde (UretimEmirGostergesi), aksiyon olayla açar; standartta onay yeter.
    case 'uretim.serbest-birak': {
      const sv = await api.uretimSeviye().catch(() => ({ seviye: 'basit', emirKullan: false }));
      if (sv.seviye === 'denetimli') {
        window.dispatchEvent(new CustomEvent<UretimIslemOlayi>(UE_ISLEM_OLAYI, { detail: { id, islem: 'serbest' } }));
        return true;
      }
      if (!await onay('Emir atölyeye serbest bırakılsın mı? (Onaylı → Serbest bırakıldı; sonra Başlat)')) return true;
      await guvenli(async () => { mesaj((await api.uretimEmriSerbestBirak(id)).mesaj); b.tazele() });
      return true;
    }

    // ÜRET (1253, uretim_basit.html ②): üretilen adedi sor, emirden üretim fişini kes (sarf + giriş + maliyet).
    case 'uretim.uret': {
      const kalan = Math.max(0, Number(satir?.adet ?? 0) - Number(satir?.uretilenAdet ?? 0));
      const a = await metinSor('Kaç adet üretildi?', kalan ? String(kalan) : '', 'Üretilen adet');
      const adet = sayi(a);
      if (Number.isNaN(adet)) return true;
      if (adet <= 0) { mesaj('Adet sıfırdan büyük olmalı.'); return true }
      await guvenli(async () => {
        const y = await api.uretimEmriUret(id, { adet });
        mesaj([y.mesaj, ...y.uyarilar].join('\n'));
        b.tazele();
      });
      return true;
    }

    case 'uretim.baslat':
      if (!await onay('Emir üretime alınsın mı?\n\n'
                    + 'Sarf modu "tek seferde" ise bütün bileşenler ŞİMDİ '
                    + 'sarf fişiyle depodan çıkar.')) return true;
      await guvenli(async () => {
        mesaj((await api.uretimBaslat(id)).mesaj);
        b.tazele();
      });
      return true;

    case 'uretim.sarf':
      if (!await onay('Kalan malzemenin tamamı sarf edilsin mi?')) return true;
      await guvenli(async () => {
        mesaj((await api.uretimSarf(id)).mesaj);
        b.tazele();
      });
      return true;

    case 'uretim.mamul-giris': {
      const a = await metinSor('Kaç adet mamul girişi yapılacak?', '', 'Giriş adedi');
      const adet = sayi(a);
      if (Number.isNaN(adet)) return true;
      if (adet <= 0) { mesaj('Adet sıfırdan büyük olmalı.'); return true }
      await guvenli(async () => {
        const y = await api.uretimMamulGiris(id, adet);
        mesaj(`${y.mesaj}\nToplam: ${y.uretilen} / ${y.adet}`);
        b.tazele();
      });
      return true;
    }

    case 'uretim.fire': {
      const a = await metinSor('Fire adedi:', '', 'Fire');
      const adet = sayi(a);
      if (Number.isNaN(adet)) return true;
      if (adet <= 0) { mesaj('Adet sıfırdan büyük olmalı.'); return true }
      const neden = await metinSor('Fire nedeni:', '', 'Neden');
      if (neden === null) return true;
      await guvenli(async () => {
        // v1'de fire MAMUL uzerinden: bilesen firesi zaten sarfin icinde.
        mesaj((await api.uretimFire(id, Number(satir?.stokId ?? 0), adet, neden)).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'uretim.agactan-yenile':
      if (!await onay('Emrin malzeme ve operasyonları ağaçtan yeniden '
                    + 'oluşturulsun mu?\n\nMevcut satırlar SİLİNİR; yalnız '
                    + 'Taslak ve Onaylı emirde çalışır.', true)) return true;
      await guvenli(async () => {
        mesaj((await api.uretimAgactanYenile(id)).mesaj);
        b.tazele();
      });
      return true;

    case 'uretim.maliyet-kapat': {
      const g = await metinSor('Genel üretim gideri yüzdesi (boş = 0):', '0', 'GÜG %');
      if (g === null) return true;
      await guvenli(async () => {
        const y = await api.uretimMaliyetKapat(id, sayi(g) || 0);
        mesaj(`${y.mesaj}\nMalzeme ${y.malzeme.toFixed(2)} · `
            + `İşçilik ${y.iscilik.toFixed(2)} · Fark %${y.farkYuzde}`);
        b.tazele();
      });
      return true;
    }

    case 'uretim.kapat':
      if (!await onay('Emir kapatılsın mı?\n\nKalan rezerv bırakılır, '
                    + 'emir bir daha değiştirilemez.', true)) return true;
      await guvenli(async () => {
        mesaj((await api.uretimEmriKapat(id)).mesaj);
        b.tazele();
      });
      return true;

    case 'uretim.iptal': {
      // NEDEN ZORUNLU: iptal edilmiş emir raporlarda kalır; sebebi olmayan
      //   bir iptal ay sonunda kimseye bir şey anlatmaz.
      const neden = await metinSor('İptal nedeni:', '', 'Neden');
      if (neden === null) return true;
      if (!neden.trim()) { mesaj('İptal nedeni zorunlu.'); return true }
      await guvenli(async () => {
        mesaj((await api.uretimEmriIptal(id, neden.trim())).mesaj);
        b.tazele();
      });
      return true;
    }

    default:
      return false;
  }
}

/**
 * ÜRETİM FİŞİ LİSTE AKSİYONLARI (1254, uretim_fisi_listesi.html). Hangisinin hangi seviyede çizildiğini
 * uretimListeSeviye.ts seçer; burada hepsi çalışır. E-imza isteyenler (Serbest Bırak, gerekçeli Ters Kayıt) pencereyi
 * listenin üst panelinde açar (UretimFisiGostergesi) - aksiyon olay atar.
 */
async function uretimFisiAksiyonu(kod: string, satir: ListeSatiri | null | undefined, b: UretimBaglam): Promise<boolean> {
  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir fiş seçin.'); return true }
  const durum = Number(satir?.durum ?? -1);
  const ac = (yol: string) => (b.gitKart ?? b.git)(yol);
  const olay = (islem: UretimIslemOlayi['islem']) =>
    window.dispatchEvent(new CustomEvent<UretimIslemOlayi>(UF_ISLEM_OLAYI, { detail: { id, islem, satir: satir ?? undefined } }));

  switch (kod) {
    // SİL (basit / standart): taslak silinir; gerçekleşmiş fiş SİLİNMEZ - ters kayıt (belgeler geri alınır, iz kalır).
    case 'uretim-fisi.sil':
      if (durum === 1) {
        if (!await onay('Taslak fiş silinsin mi?')) return true;
        await guvenli(async () => { await api.uretimFisSil(id); mesaj('Taslak silindi.'); b.tazele() });
        return true;
      }
      if (durum === 0) { mesaj('Bu fiş zaten ters kayıtla kapatılmış.'); return true }
      if (!await onay('Gerçekleşmiş fiş silinmez; ters kayıt atılır: sarf, fire ve üretim girişi belgeleri geri alınır, '
                    + 'fiş "Ters kayıt" durumuyla kalır. Devam edilsin mi?')) return true;
      await guvenli(async () => { mesaj((await api.uretimFisTersKayit(id, 'Listeden silme')).mesaj); b.tazele() });
      return true;

    // TERS KAYIT (denetimli): gerekçe zorunlu - pencere üst panelde. Taslak için ters kayıt yok, düz silme.
    case 'uretim-fisi.ters-kayit':
      if (durum === 1) {
        if (!await onay('Taslak fiş silinsin mi?')) return true;
        await guvenli(async () => { await api.uretimFisSil(id); mesaj('Taslak silindi.'); b.tazele() });
        return true;
      }
      olay('ters');
      return true;

    case 'uretim-fisi.gerceklestir':
      // Koşul ("yalnız taslak") sunucuda; eksik malzeme 422'si guvenli() ile ekrana düşer.
      await guvenli(async () => {
        const y = await api.uretimFisGerceklestir(id);
        mesaj([y.mesaj, ...y.uyarilar].join('\n'));
        b.tazele();
      });
      return true;

    case 'uretim-fisi.serbest':
      olay('serbest');
      return true;

    case 'uretim-fisi.sarf-ac':
    case 'uretim-fisi.giris-ac': {
      const belgeId = Number(satir?.[kod === 'uretim-fisi.sarf-ac' ? 'sarfBelgeId' : 'girisBelgeId'] ?? 0);
      if (!belgeId) { mesaj(durum === 1 ? 'Fiş henüz gerçekleşmedi - belgesi yok.' : 'Bu fişte o belge yok.'); return true }
      ac(`/belge/${belgeId}`);
      return true;
    }

    case 'uretim-fisi.emir-ac': {
      const emirId = Number(satir?.emirId ?? 0);
      if (!emirId) { mesaj('Fiş bir üretim emrine bağlı değil (elle kesilmiş).'); return true }
      ac(`/uretim-emri/${emirId}`);
      return true;
    }

    default:
      return false;
  }
}
