import { api } from '../../api/istemci';
import { type AksiyonBaglami, sayiOku } from './aksiyonOrtak';
import { guvenli, mesaj, metinSor, secimSor } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * KALİTE KONTROL AKSİYONLARI (442) — İKK ölçümü ve düzeltici faaliyet.
 *
 * <b>Z skoru ve Westgard kararı ekranda hesaplanmaz</b>: ölçüm sunucuya
 * gider, değerlendirme oradan döner. İki yerde hesaplanırsa grafik ile
 * karar ayrışır ve hangisinin doğru olduğu belirsiz kalır.
 *
 * <b>Ret düzeltici faaliyet ister</b> (ISO 15189): ne yapıldığı yazılmayan
 * ret denetimde savunulamaz. Etkilenen hasta sonuçlarının kaçının gözden
 * geçirildiği de burada sorulur - "kontrol tutmadı" demek, o aralıktaki
 * hasta sonuçlarının şüpheli olduğunu söylemektir.
 */
export type KkBaglam = AksiyonBaglami;

export async function kkAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: KkBaglam,
): Promise<boolean> {
  if (!kod.startsWith('lab.kk-')) return false;

  // Yeni ölçüm satır seçimi gerektirmez.
  if (kod === 'lab.kk-olcum') {
    await guvenli(async () => {
      const lotlar = await api.liste('lab-kk-lot', { sayfa: 1, boyut: 50 });
      const aktif = lotlar.satirlar.filter(r => Number(r.durum) === 0);
      if (aktif.length === 0) {
        mesaj('Aktif kontrol lotu yok - önce Kontrol Lotları ekranından tanımlayın.');
        return;
      }
      const lot = await secimSor('Kontrol lotu:', aktif.map(r => ({
        kod: String(r.id),
        ad: `${String(r.materyalAd ?? '')} · lot ${String(r.lot ?? '')}`,
      })));
      if (!lot) return;

      const tetkikler = await api.liste('lab-tetkik', { sayfa: 1, boyut: 200 });
      const tetkik = await secimSor('Tetkik:', tetkikler.satirlar.map(r => ({
        kod: String(r.id), ad: `${String(r.kod ?? '')} · ${String(r.ad ?? '')}`,
      })));
      if (!tetkik) return;

      const seviye = await secimSor('Kontrol seviyesi:', [
        { kod: '1', ad: 'Seviye 1' },
        { kod: '2', ad: 'Seviye 2' },
        { kod: '3', ad: 'Seviye 3' },
      ]);
      if (!seviye) return;

      const deger = await metinSor('Ölçülen değer:', '', 'KK Ölçümü');
      if (deger === null) return;
      const d = sayiOku(deger);
      if (d === undefined) { mesaj('Değer sayı olmalı.'); return }

      const y = await api.kkOlcum({
        lotId: Number(lot), tetkikId: Number(tetkik), seviye: Number(seviye),
        deger: d, kaynak: 2,
      });
      // RET mesajı sonucun yazılmadığı anlamına gelmez: ölçüm kaydedilir,
      //   değişen şey o testin oto-onayının kapanmasıdır.
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir ölçüm seçin.'); return true }

  switch (kod) {
    case 'lab.kk-aksiyon': {
      const aksiyon = await metinSor(
        'Düzeltici faaliyet (ne yapıldı?):',
        'Kalibrasyon yenilendi, kontrol tekrarlandı', 'Düzeltici Faaliyet');
      if (aksiyon === null || aksiyon.trim() === '') {
        mesaj('Düzeltici faaliyet zorunlu (ISO 15189).');
        return true;
      }
      const olay = await secimSor('Cihaz olayı olarak da kaydedilsin mi?', [
        { kod: '1', ad: 'Kalibrasyon' },
        { kod: '3', ad: 'Reaktif lot değişimi' },
        { kod: '2', ad: 'Bakım' },
        { kod: '4', ad: 'Arıza' },
        { kod: '0', ad: 'Kaydetme' },
      ]);
      if (!olay) return true;

      // ETKİLENEN HASTA SONUÇLARI: kontrol tutmayan aralıkta verilen
      //   sonuçlar şüphelidir; kaçının bakıldığı kayda geçer.
      const gozden = await metinSor(
        'Gözden geçirilen hasta sonucu sayısı:', '0', 'Düzeltici Faaliyet');
      if (gozden === null) return true;
      const duzeltilen = await metinSor(
        'Bunlardan düzeltilen (yeniden çalışılan) sayısı:', '0',
        'Düzeltici Faaliyet');
      if (duzeltilen === null) return true;

      await guvenli(async () => {
        const y = await api.kkAksiyon(id, {
          aksiyon: aksiyon.trim(),
          gozdenGecirilen: sayiOku(gozden) ?? 0,
          duzeltilen: sayiOku(duzeltilen) ?? 0,
          olay: Number(olay) || undefined,
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.kk-grafik': {
      const tetkikId = Number(satir?.tetkikId ?? 0);
      if (!tetkikId) { mesaj('Tetkik bulunamadı.'); return true }
      const lotId = Number(satir?.lotId ?? 0);
      const seviye = Number(satir?.seviye ?? 0);
      const s = new URLSearchParams({ tetkik: String(tetkikId) });
      if (lotId) s.set('lot', String(lotId));
      if (seviye) s.set('seviye', String(seviye));
      b.git(`/lab/kk/grafik?${s}`);
      return true;
    }
  }

  return false;
}
