import { api, type UtsHazirlaYaniti } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import type { UtsBildirimTuru } from '../../bilesenler/uts/UtsGenelBildirimModali';

/**
 * ÜTS LISTE AKSIYONLARI (223-230).
 *
 * `Liste.tsx` icindeki `aksiyon()` 950 satira ve 44 case'e ulasmisti; konu
 * bazli bloklar oradan ayrildi (e-Belge ve gelen belge zaten ayriydi -
 * `ebelgeIslem.ts` / `gelenBelgeIslem.ts`; bu dosya ayni deseni surduruyor).
 *
 * Ekranin state'ine dokunmak gerekiyor: modal acmak, gridi tazelemek. Bunlar
 * BAGLAM nesnesiyle geliyor - dosya boylece ekrandan bagimsiz kaliyor.
 *
 * Donus: aksiyon BURADA ele alindi mi (true) - cagiran `if (await ...) return`
 * ile zincirliyor.
 */
export interface UtsBaglam {
  /** Grid tazeleme sayaci (satir durumlari degisti). */
  tazele(): void;
  /** "Verme hazırla" sonucu - atlananlar gride dokulur. */
  setUtsHazirla(y: UtsHazirlaYaniti): void;
  setUtsKullanim(v: boolean): void;
  setUtsGenel(v: UtsBildirimTuru): void;
  setUtsAlma(v: {
    envanterId: number; urunNo: string; kurumUnvan: string;
    askiAdet: number; seriNo: string;
  }): void;
}

export async function utsAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  secililer: ListeSatiri[] | undefined,
  b: UtsBaglam,
): Promise<boolean> {
  switch (kod) {
    // IKI ASAMALI VERME (kullanici): 1) hazirla - e-Belgeli satis
    //   faturalarindan BEKLEYEN kayitlar gride dolar (ÜTS'ye gitmez),
    //   2) gridde secilenler "📤 Gönder" ile cikar.
    case 'uts.verme':
      await guvenli(async () => {
        const y = await api.utsVermeHazirla();
        // Atlananlar GRIDDE (kullanici): siralanir + CSV kaydedilir.
        if (y.atlanan.length > 0) b.setUtsHazirla(y); else mesaj(y.mesaj);
        b.tazele();
      });
      return true;

    case 'uts.kullanim': b.setUtsKullanim(true); return true;
    case 'uts.uretim':   b.setUtsGenel('uretim');  return true;
    case 'uts.ithalat':  b.setUtsGenel('ithalat'); return true;
    case 'uts.hek':      b.setUtsGenel('hek');     return true;
    case 'uts.imha':     b.setUtsGenel('imha');    return true;

    case 'uts.senkron':
      await guvenli(async () => {
        const y = await api.utsAskidakilerSenkron();
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;

    case 'uts.al':
      if (!satir) return true;
      if (Number(satir.durum) !== 1) { mesaj('Bu kayıt askıda değil.'); return true }
      b.setUtsAlma({
        envanterId: Number(satir.id),
        urunNo: String(satir.urunNo ?? ''),
        kurumUnvan: String(satir.kurumUnvan ?? ''),
        askiAdet: Number(satir.askiAdet ?? 1),
        seriNo: String(satir.seriNo ?? ''),
      });
      return true;

    case 'uts.iptal': {
      if (!satir) return true;
      // ALMA bildirimi ÜTS'de iptal EDILEMEZ: karsi taraf verme bildirimini
      //   iptal etmeli - kullaniciyi bosuna denemeye birakmayalim.
      if (Number(satir.tur) === 1) {
        mesaj("Alma bildirimi ÜTS'de iptal edilemez (karşı taraf verme bildirimini iptal etmelidir).");
        return true;
      }
      if (!await onay(`"${String(satir.utsBildirimId ?? satir.id)}" bildirimi ÜTS'de İPTAL edilecek.\n\nOnaylıyor musunuz?`))
        return true;
      await guvenli(async () => {
        const y = await api.utsIptal(Number(satir.id));
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'uts.yeniden-gonder': {
      // GONDER: coklu secim - isaretli bekleyen/hatali bildirimler sirayla
      //   ÜTS'ye cikar. Bir bildirimin hatasi otekileri DURDURMAZ; sonuc
      //   satir satir raporlanir.
      const hedefler = (secililer && secililer.length > 0 ? secililer
                        : satir ? [satir] : []);
      if (hedefler.length === 0) return true;
      if (!await onay(`${hedefler.length} bildirim ÜTS'ye GÖNDERİLECEK.\n\nGönderilen bildirim resmî işlemdir. Onaylıyor musunuz?`, true))
        return true;
      await guvenli(async () => {
        let tamam = 0; const hatalar: string[] = [];
        for (const h of hedefler) {
          try {
            const y = await api.utsYenidenGonder(Number(h.id));
            if (y.basarili) tamam++;
            else hatalar.push(`#${h.id}: ${y.mesaj}`);
          } catch (hh) {
            hatalar.push(`#${h.id}: ${hataMetni(hh)}`);
          }
        }
        mesaj(hedefler.length === 1 && hatalar.length === 0
          ? 'Bildirim başarıyla gönderildi.'
          : `${tamam}/${hedefler.length} bildirim gönderildi.`
            + (hatalar.length > 0 ? '\n\n' + hatalar.join('\n') : ''));
        b.tazele();
      });
      return true;
    }

    case 'uts.detay':
      if (!satir) return true;
      await guvenli(async () => {
        const y = await api.utsBildirimDetay(Number(satir.id));
        const ozet = y.mesajlar.map(m => `${m.tip ?? ''}: ${m.met ?? ''}`).join('\n');
        mesaj(y.sonuc != null
          ? JSON.stringify(y.sonuc, null, 2).slice(0, 1500)
          : (ozet || 'ÜTS detay dönmedi.'));
      });
      return true;

    default:
      return false;
  }
}
