import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * GENETİK AKSİYONLARI (439) — vaka süreci ve varyant kararları.
 *
 * <b>Onam ayrı düğme</b>: raporun ön koşuludur (KVKK md. 6) ve tesadüfi
 * bulgu tercihi raporlamayı doğrudan değiştirir. Vaka açılışına gömseydik,
 * hasta tercihi sorulmadan varsayılan bir değer yazılırdı.
 *
 * <b>Sınıfı ekran hesaplamaz.</b> ACMG kanıt kodları sunucuya gider, sınıf
 * orada türetilir (fn_lab_acmg_sinif). İki yerde hesaplansaydı rapor ile
 * ekran ayrışır ve hangisinin doğru olduğu belirsiz kalırdı.
 */
export interface GenetikBaglam {
  tazele(): void;
  git(yol: string): void;
}

function sayi(metin: string | null | undefined): number | undefined {
  if (!metin || metin.trim() === '') return undefined;
  const d = Number(metin.trim().replace(',', '.'));
  return Number.isFinite(d) ? d : undefined;
}

export async function genetikAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: GenetikBaglam,
): Promise<boolean> {
  if (!kod.startsWith('lab.genetik') && !kod.startsWith('lab.varyant-')) return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }

  // Vaka açma istem satırı listesinden başlar.
  if (kod === 'lab.genetik-vaka') {
    await guvenli(async () => {
      const paneller = await api.liste('lab-genetik-panel', { sayfa: 1, boyut: 50 });
      const secim = await secimSor('Hangi panel çalışılacak?',
        paneller.satirlar.map(r => ({ kod: String(r.id), ad: String(r.ad ?? '') })));
      if (!secim) return;
      const endikasyon = await metinSor('Endikasyon / klinik bilgi:', '', 'Genetik Vaka');
      if (endikasyon === null) return;
      const y = await api.genetikVakaAc(id, { panelId: Number(secim), endikasyon });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  switch (kod) {
    case 'lab.genetik-onam': {
      const surum = await metinSor('Onam formu sürümü:', 'Genetik test onamı v2',
                                   'Onam Kaydı');
      if (surum === null || surum.trim() === '') return true;
      // TESADÜFİ BULGU: hastanın kendi tercihi. "İstemiyorum" seçildiğinde
      //   ikincil bulgular anında raporlamadan çıkar.
      const tercih = await secimSor('Tesadüfi (ikincil) bulgu bildirimi:', [
        { kod: '2', ad: 'İstemiyorum — ikincil bulgular raporlanmasın' },
        { kod: '1', ad: 'İstiyorum — ACMG SF listesi de raporlansın' },
      ]);
      if (!tercih) return true;
      const saklama = await metinSor('Ham veri saklama süresi (yıl):', '10',
                                     'Onam Kaydı');
      if (saklama === null) return true;

      await guvenli(async () => {
        const y = await api.genetikOnam(id, {
          surum: surum.trim(), tesadufiBulgu: Number(tercih),
          veriSaklamaYil: sayi(saklama),
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.genetik-izolasyon': {
      const konsan = await metinSor('DNA konsantrasyonu (ng/µL):', '', 'DNA İzolasyon');
      if (konsan === null) return true;
      const saflik = await metinSor('A260/280 saflık oranı:', '1,85', 'DNA İzolasyon');
      if (saflik === null) return true;
      const k = sayi(konsan); const s = sayi(saflik);
      if (k === undefined || s === undefined) {
        mesaj('Konsantrasyon ve saflık sayı olmalı.');
        return true;
      }
      await guvenli(async () => {
        mesaj((await api.genetikIzolasyon(id, k, s)).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.genetik-run': {
      const runlar = await api.liste('lab-genetik-run', { sayfa: 1, boyut: 20 });
      const secenekler = [
        { kod: 'yeni', ad: '➕ Yeni run aç' },
        ...runlar.satirlar
          .filter(r => Number(r.durum) !== 4 && Number(r.durum) !== 0)
          .map(r => ({ kod: String(r.id),
                       ad: `${String(r.kod ?? '')} · ${String(r.cihazAdi ?? '')}` })),
      ];
      const secim = await secimSor('Run seçin:', secenekler);
      if (!secim) return true;

      if (secim !== 'yeni') {
        await guvenli(async () => {
          mesaj((await api.genetikRunaAl(id, { runId: Number(secim) })).mesaj);
          b.tazele();
        });
        return true;
      }

      const cihaz = await metinSor('Cihaz:', 'Illumina NextSeq 550', 'Yeni Run');
      if (cihaz === null) return true;
      const kit = await metinSor('Kit / panel:', '', 'Yeni Run');
      if (kit === null) return true;
      const lot = await metinSor('Kit lot:', '', 'Yeni Run');
      if (lot === null) return true;
      await guvenli(async () => {
        const y = await api.genetikRunaAl(id, { cihazAdi: cihaz, kit, kitLot: lot });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.genetik-kalite': {
      const kapsama = await metinSor('Hedef kapsama (%≥20×):', '', 'Kalite');
      if (kapsama === null) return true;
      const derinlik = await metinSor('Ortalama derinlik (×):', '', 'Kalite');
      if (derinlik === null) return true;
      const kontaminasyon = await metinSor('Kontaminasyon (%):', '0', 'Kalite');
      if (kontaminasyon === null) return true;
      const cinsiyet = await secimSor('Cinsiyet doğrulama:', [
        { kod: '1', ad: 'Uyumlu' },
        { kod: '2', ad: 'UYUMSUZ — numune karışıklığı şüphesi' },
        { kod: '0', ad: 'Yapılmadı' },
      ]);
      if (!cinsiyet) return true;

      await guvenli(async () => {
        const y = await api.genetikKalite(id, {
          kapsamaYuzde: sayi(kapsama), ortDerinlik: sayi(derinlik),
          kontaminasyon: sayi(kontaminasyon), cinsiyetDogrulama: Number(cinsiyet),
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.genetik-varyant': {
      const gen = await metinSor('Gen sembolü (örn. MYBPC3):', '', 'Varyant');
      if (gen === null || gen.trim() === '') return true;
      const hgvsC = await metinSor('HGVS c. (örn. c.1504C>T):', '', 'Varyant');
      if (hgvsC === null || hgvsC.trim() === '') return true;
      const hgvsP = await metinSor('HGVS p. (örn. p.(Arg502Trp)):', '', 'Varyant');
      if (hgvsP === null) return true;
      const zigosite = await secimSor('Zigosite:', [
        { kod: '1', ad: 'Heterozigot' },
        { kod: '2', ad: 'Homozigot' },
        { kod: '3', ad: 'Hemizigot' },
        { kod: '4', ad: 'Mozaik' },
      ]);
      if (!zigosite) return true;
      // ACMG KANIT KODLARI: sınıf bunlardan türetilir. Güç ekleri de
      //   yazılabilir (PP1_Strong, PM2_Supporting).
      const acmg = await metinSor(
        'ACMG kanıt kodları (virgülle):\nörn. PS4, PP1_Strong, PM2, PP3',
        '', 'Varyant');
      if (acmg === null) return true;

      await guvenli(async () => {
        const y = await api.genetikVaryant(id, {
          genSembol: gen.trim().toUpperCase(), hgvsC: hgvsC.trim(),
          hgvsP: hgvsP.trim(), zigosite: Number(zigosite),
          acmgKriterler: acmg.split(',').map(x => x.trim()).filter(Boolean),
        });
        mesaj(y.bankaUyarisi ? `${y.mesaj}\n\n⚠ ${y.bankaUyarisi}` : y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.genetik-onayla': {
      const yorum = await metinSor('Uzman yorumu:', '', 'Rapor Onayı');
      if (yorum === null) return true;
      const oneriler = await metinSor(
        'Öneriler (danışmanlık, kaskad tarama, izlem):', '', 'Rapor Onayı');
      if (oneriler === null) return true;
      if (!await onay('Genetik rapor onaylanacak.\n\n'
                    + 'Onam kaydı ve patojenik varyantların doğrulaması '
                    + 'tamamlanmış olmalı; sunucu ikisini de denetler.')) return true;
      await guvenli(async () => {
        mesaj((await api.genetikOnayla(id, yorum, oneriler)).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.genetik-iptal': {
      const neden = await metinSor('İptal nedeni (zorunlu):', '', 'Vaka İptali');
      if (neden === null || neden.trim() === '') {
        mesaj('İptal nedeni zorunlu.');
        return true;
      }
      await guvenli(async () => {
        mesaj((await api.genetikIptal(id, neden.trim())).mesaj);
        b.tazele();
      });
      return true;
    }

    // ---------------------------------------------------------- varyant ---
    case 'lab.varyant-sinif': {
      const sinif = await secimSor('Uzman sınıflaması:', [
        { kod: '5', ad: '5 · Patojenik' },
        { kod: '4', ad: '4 · Olası patojenik' },
        { kod: '3', ad: '3 · Klinik önemi belirsiz (VUS)' },
        { kod: '2', ad: '2 · Olası benign' },
        { kod: '1', ad: '1 · Benign' },
      ]);
      if (!sinif) return true;
      const neden = await metinSor(
        'Gerekçe (ACMG hesabı neden geçersiz?):', '', 'Sınıf Değişikliği');
      if (neden === null || neden.trim() === '') {
        mesaj('Gerekçe zorunlu - kural motorunun sonucu sessizce değiştirilemez.');
        return true;
      }
      await guvenli(async () => {
        mesaj((await api.varyantSinif(id, Number(sinif), neden.trim())).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.varyant-dogrulama': {
      const durum = await secimSor('Sanger doğrulama:', [
        { kod: '1', ad: 'Doğrulama istendi' },
        { kod: '2', ad: 'Doğrulandı' },
        { kod: '3', ad: 'DOĞRULANAMADI — rapordan çıkar' },
      ]);
      if (!durum) return true;
      if (durum === '3' && !await onay(
        'Varyant doğrulanamadı olarak işaretlenecek ve RAPORDAN ÇIKARILACAK.\n\n'
        + 'Dizileme artefaktı olabilir; raporda bırakmak hastaya olmayan bir '
        + 'tanı koymak olur.')) return true;
      await guvenli(async () => {
        mesaj((await api.varyantDogrulama(id, Number(durum))).mesaj);
        b.tazele();
      });
      return true;
    }
  }

  return false;
}
