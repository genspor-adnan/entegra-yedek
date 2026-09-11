import { api } from '../../api/istemci';
import { type AksiyonBaglami, sayiOku } from './aksiyonOrtak';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * DIŞ LABORATUVAR AKSİYONLARI (445).
 *
 * <b>Numune binadan çıkar</b>: kurye, taşıma koşulu ve teslim kaydı bu
 * andan sonra elimizdeki tek iz. Numune kaybolduğunda ya da sonuç
 * geciktiğinde cevabı verecek olan bu zincirdir - bu yüzden gönderim
 * sırasında kurye ve soğuk zincir sorulur, "sonra gireriz" bırakılmaz.
 *
 * <b>Dış lab sonucu oto-onaya girmez</b>: başka bir laboratuvarın yöntemini
 * ve kalite kontrolünü biz doğrulamadık; sunucu bunu zorluyor, buradaki
 * mesaj yalnız sebebini söylüyor.
 */
export type DisLabBaglam = AksiyonBaglami;

export async function disLabAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: DisLabBaglam,
): Promise<boolean> {
  if (!kod.startsWith('lab.dis-')) return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }

  // Numune kabul listesinden sevk: seçili numunenin bekleyen tetkikleri.
  if (kod === 'lab.dis-gonder') {
    await guvenli(async () => {
      const labs = await api.liste('lab-dis-lab', { sayfa: 1, boyut: 50 });
      const aktif = labs.satirlar.filter(r => Number(r.durum) === 0);
      if (aktif.length === 0) {
        mesaj('Tanımlı dış laboratuvar yok - önce Laboratuvar › Dış Laboratuvarlar '
            + 'ekranından ekleyin.');
        return;
      }
      const disLab = await secimSor('Hangi dış laboratuvara gönderilecek?',
        aktif.map(r => ({ kod: String(r.id), ad: String(r.ad ?? '') })));
      if (!disLab) return;

      // Numunenin bekleyen tetkikleri: istem detayından okunur.
      // İSTEMLER listesinde satırın kendisi istemdir (mockup araç çubuğunda
      //   "📦 Dış Lab'a Gönder" orada da var); numune kabul listesinde ise
      //   satır tüptür ve istem id'si ayrı kolonda gelir.
      const istemId = Number(satir?.istemId ?? satir?.id ?? 0);
      if (!istemId) { mesaj('İstem bulunamadı.'); return }
      const d = await api.labIstemOku(istemId) as Record<string, unknown>;
      const satirlar = (d.satirlar ?? []) as Record<string, unknown>[];
      const uygun = satirlar.filter(s => Number(s.numuneDurum ?? 0) === 3
                                      && [1, 2, 6].includes(Number(s.durum ?? 0)));
      if (uygun.length === 0) {
        mesaj('Bu numunede gönderilebilecek bekleyen tetkik yok.');
        return;
      }

      const secim = await secimSor('Hangi tetkik gönderilecek?', [
        { kod: 'hepsi', ad: `Tümü (${uygun.length} tetkik)` },
        ...uygun.map(s => ({ kod: String(s.satirId),
                             ad: `${String(s.kod ?? '')} · ${String(s.ad ?? '')}` })),
      ]);
      if (!secim) return;

      // SOĞUK ZİNCİR: -20 °C isteyen bir testin numunesi oda sıcaklığında
      //   gittiyse sonuç geçersizdir ve bunu SONRADAN bilmek gerekir.
      const tasima = await secimSor('Taşıma koşulu:', [
        { kod: '2', ad: 'Soğuk (2-8 °C)' },
        { kod: '1', ad: 'Oda sıcaklığı' },
        { kod: '3', ad: 'Dondurulmuş (-20 °C)' },
        { kod: '4', ad: 'Kuru buz (-70 °C)' },
      ]);
      if (!tasima) return;
      const kurye = await metinSor('Kurye (firma / kişi):', '', 'Dış Lab Gönderimi');
      if (kurye === null) return;

      const y = await api.disLabGonder({
        disLabId: Number(disLab),
        istemSatirIdler: secim === 'hepsi'
          ? uygun.map(s => Number(s.satirId))
          : [Number(secim)],
        tasimaKosulu: Number(tasima),
        kuryeAd: kurye,
      });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  switch (kod) {
    case 'lab.dis-yolda':
      await guvenli(async () => {
        mesaj((await api.disLabYolda(id)).mesaj);
        b.tazele();
      });
      return true;

    case 'lab.dis-teslim': {
      const alan = await metinSor('Teslim alan (dış lab görevlisi):', '', 'Teslim');
      if (alan === null) return true;
      // DIŞ KABUL NO: sonuç geldiğinde ve itirazda iki laboratuvarın ortak
      //   tek referansı budur.
      const kabulNo = await metinSor('Dış laboratuvarın kabul numarası:', '',
                                     'Teslim');
      if (kabulNo === null) return true;
      await guvenli(async () => {
        mesaj((await api.disLabTeslim(id, alan, kabulNo)).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.dis-sonuc': {
      const d = await api.disLabOku(id);
      const bekleyen = (d.satirlar ?? []).filter(s => Number(s.durum) === 1);
      if (bekleyen.length === 0) {
        mesaj('Bu gönderimde sonucu bekleyen tetkik yok.');
        return true;
      }
      const secim = bekleyen.length === 1
        ? String(bekleyen[0].istemSatirId)
        : await secimSor('Hangi tetkiğin sonucu?', bekleyen.map(s => ({
            kod: String(s.istemSatirId),
            ad: `${String(s.kod ?? '')} · ${String(s.hasta ?? '')}`,
          })));
      if (!secim) return true;

      const deger = await metinSor('Sonuç değeri:', '', 'Dış Lab Sonucu');
      if (deger === null || deger.trim() === '') return true;
      const birim = await metinSor('Birim (boş = katalogdaki):', '', 'Dış Lab Sonucu');
      if (birim === null) return true;

      await guvenli(async () => {
        const y = await api.disLabSonuc(id, {
          istemSatirId: Number(secim), deger: deger.trim(),
          birim: birim.trim() || undefined,
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.dis-ret': {
      const d = await api.disLabOku(id);
      const bekleyen = (d.satirlar ?? []).filter(s => Number(s.durum) === 1);
      if (bekleyen.length === 0) { mesaj('Bekleyen tetkik yok.'); return true }
      const secim = await secimSor('Hangi tetkik?', bekleyen.map(s => ({
        kod: String(s.istemSatirId),
        ad: `${String(s.kod ?? '')} · ${String(s.hasta ?? '')}`,
      })));
      if (!secim) return true;
      const durum = await secimSor('Ne oldu?', [
        { kod: '3', ad: 'Dış laboratuvar reddetti' },
        { kod: '4', ad: 'Numune kayboldu' },
      ]);
      if (!durum) return true;
      const neden = await metinSor('Gerekçe (zorunlu):', '', 'Dış Lab Reddi');
      if (neden === null || neden.trim() === '') {
        mesaj('Gerekçe zorunlu.');
        return true;
      }
      if (!await onay('Tetkik "tekrar numune bekliyor" durumuna dönecek.\n\n'
                    + 'Hastadan yeniden numune alınması gerekir.')) return true;
      await guvenli(async () => {
        mesaj((await api.disLabRet(id, Number(secim), Number(durum),
                                   neden.trim())).mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.dis-fatura': {
      const belgeNo = await metinSor('Alış faturası belge id:', '', 'Fatura Eşleştir');
      if (belgeNo === null || belgeNo.trim() === '') return true;
      const tutar = await metinSor('Tutar (boş geçilebilir):', '', 'Fatura Eşleştir');
      if (tutar === null) return true;
      await guvenli(async () => {
        mesaj((await api.disLabFatura(id, Number(belgeNo), sayiOku(tutar))).mesaj);
        b.tazele();
      });
      return true;
    }
  }

  return false;
}
