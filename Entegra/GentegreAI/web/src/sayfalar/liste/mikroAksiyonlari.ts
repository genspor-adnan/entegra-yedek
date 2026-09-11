import { api } from '../../api/istemci';
import { type AksiyonBaglami, sayiOku } from './aksiyonOrtak';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * MİKROBİYOLOJİ AKSİYONLARI (436) — kültür süreci.
 *
 * <b>Her adım ayrı düğme</b>: ekim → okuma → izolat → antibiyogram → onay.
 * Tek "kaydet" düğmesi, kültürün hangi aşamada olduğunu gizlerdi.
 *
 * <b>Kademeli bildirim sunucuda hesaplanır.</b> Buradaki mesaj yalnız kaç
 * antibiyotiğin raporda görüneceğini söyler; kararı ekran vermez, yoksa
 * rapor ile ekran ayrışır.
 */
export type MikroBaglam = AksiyonBaglami;

/** "12,5" -> 12.5. Türkçe klavyede ondalık ayırıcı virgüldür. */
/** "≥32" / ">= 32" / "<=0,25" -> { isaret, deger } */
function micCoz(ham: string): { mic?: number; micIsaret: string } {
  const t = ham.trim().replace('≥', '>=').replace('≤', '<=');
  const m = /^(>=|<=)?\s*(.+)$/.exec(t);
  return { mic: sayiOku(m?.[2]), micIsaret: m?.[1] ?? '' };
}

export async function mikroAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: MikroBaglam,
): Promise<boolean> {
  if (kod !== 'lab.ekim' && !kod.startsWith('lab.kultur-')) return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir kayıt seçin.'); return true }

  // EKİM istem satırı listesinden başlar; diğerleri kültür listesinden.
  if (kod === 'lab.ekim') {
    await guvenli(async () => {
      const gram = await metinSor(
        'Direkt bakı / Gram sonucu (boş geçilebilir):', '', 'Ekim');
      if (gram === null) return;
      const y = await api.labEkim(id, { gramSonuc: gram });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  switch (kod) {
    case 'lab.kultur-okuma': {
      const saatMetni = await metinSor('Kaçıncı saat okuması? (24 / 48 / 72)', '24',
                                       'Okuma Kaydı');
      if (saatMetni === null) return true;
      const bulgu = await metinSor('Bulgu (besiyeri başına koloni görünümü):', '',
                                   'Okuma Kaydı');
      if (bulgu === null) return true;
      const uremeSecim = await secimSor('Üreme var mı?', [
        { kod: 'yok', ad: 'Üreme yok' },
        { kod: 'var', ad: 'Üreme var — identifikasyona geç' },
      ]);
      if (!uremeSecim) return true;

      await guvenli(async () => {
        const y = await api.labKulturOkuma(id, {
          saat: sayiOku(saatMetni), uremeVar: uremeSecim === 'var', bulgu,
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.kultur-izolat': {
      const organizmalar = await api.liste('lab-organizma', { sayfa: 1, boyut: 100 });
      if (organizmalar.satirlar.length === 0) {
        mesaj('Organizma kataloğu boş.');
        return true;
      }
      const secim = await secimSor('Üreyen organizma (üreme yoksa "Üreme yok"):',
        organizmalar.satirlar.map(r => ({
          kod: String(r.id), ad: String(r.ad ?? ''),
        })));
      if (!secim) return true;

      const koloni = await metinSor('Koloni sayısı (CFU/mL, boş geçilebilir):', '',
                                    'İzolat');
      if (koloni === null) return true;

      // DİRENÇ MEKANİZMASI: "bakılmadı" ile "negatif" ayrı - yapılmamış
      //   testi negatif rapor etmek yanlış güven verir.
      const esbl = await secimSor('ESBL:', [
        { kod: '0', ad: 'Bakılmadı' },
        { kod: '1', ad: 'Negatif' },
        { kod: '2', ad: 'Pozitif' },
      ]);
      if (!esbl) return true;

      await guvenli(async () => {
        const y = await api.labKulturIzolat(id, {
          organizmaId: Number(secim),
          koloniSayisi: sayiOku(koloni),
          esbl: Number(esbl),
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.kultur-antibiyogram': {
      const detay = await api.labKulturOku(id);
      const izolatlar = (detay.izolatlar ?? []) as Record<string, unknown>[];
      if (izolatlar.length === 0) {
        mesaj('Önce izolat (üreyen organizma) girin.');
        return true;
      }
      const izolatSecim = izolatlar.length === 1
        ? String(izolatlar[0].id)
        : await secimSor('Hangi izolat?', izolatlar.map(u => ({
            kod: String(u.id), ad: `#${u.izolatNo} · ${String(u.organizma ?? '')}`,
          })));
      if (!izolatSecim) return true;

      const antibiyotikler = await api.liste('lab-antibiyotik', { sayfa: 1, boyut: 100 });
      const abSecim = await secimSor('Antibiyotik:', antibiyotikler.satirlar.map(r => ({
        kod: String(r.id), ad: `${String(r.kod ?? '')} · ${String(r.ad ?? '')}`,
      })));
      if (!abSecim) return true;

      const micMetni = await metinSor('MIC (örn. ≥32 · ≤0,25) — disk için boş bırakın:',
                                      '', 'Antibiyogram');
      if (micMetni === null) return true;
      const zon = micMetni.trim() === ''
        ? await metinSor('Zon çapı (mm):', '', 'Antibiyogram')
        : '';
      if (zon === null) return true;

      const yorum = await secimSor('Duyarlılık:', [
        { kod: 'S', ad: 'S — Duyarlı' },
        { kod: 'I', ad: 'I — Artırılmış maruziyette duyarlı' },
        { kod: 'R', ad: 'R — Dirençli' },
      ]);
      if (!yorum) return true;

      const surum = await metinSor('Yorum standardı sürümü (örn. EUCAST 2026 v16):',
                                   'EUCAST 2026 v16', 'Antibiyogram');
      if (surum === null) return true;

      const { mic, micIsaret } = micCoz(micMetni);
      await guvenli(async () => {
        const y = await api.labAntibiyogram(Number(izolatSecim), {
          standart: 'EUCAST', standartSurum: surum,
          satirlar: [{
            antibiyotikId: Number(abSecim), mic, micIsaret,
            zonMm: sayiOku(zon), yorum, kaynak: micMetni.trim() === '' ? 2 : 1,
          }],
        });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.kultur-rapor': {
      // Kultur listesinde secili satir KULTUR; rapor ISTEM numarasiyla
      //   acilir cunku ayni istemdeki diger tetkikler de ayni kagida girer.
      const istemId = Number(satir?.istemId ?? 0);
      if (!istemId) { mesaj('İstem bulunamadı.'); return true }
      b.git(`/lab/rapor/${istemId}`);
      return true;
    }

    case 'lab.kultur-on-rapor': {
      // ÖN RAPOR KÜLTÜR BİTMEDEN GİDER: sepsiste tedavi ilk saatte başlar.
      const metin = await metinSor(
        'Hekime gidecek ön rapor cümlesi:',
        'Gram negatif basil üremesi, identifikasyon sürüyor', 'Ön Rapor');
      if (metin === null || metin.trim() === '') return true;
      const kritik = await onay(
        'Bu bulgu KRİTİK mi (kan kültürü pozitifliği vb.)?\n\n'
        + 'Kritik işaretlenirse panik değer akışı başlar.');
      await guvenli(async () => {
        const y = await api.labKulturOnRapor(id, metin.trim(), kritik);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.kultur-onayla': {
      const yorum = await metinSor('Uzman yorumu (akılcı antibiyotik önerisi):', '',
                                   'Rapor Onayı');
      if (yorum === null) return true;
      if (!await onay('Kültür raporu onaylanacak.\n\n'
                    + 'Onaylı sonuç değiştirilemez; düzeltme ayrı bir işlemdir.')) return true;
      await guvenli(async () => {
        const y = await api.labKulturOnayla(id, yorum);
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'lab.kultur-iptal': {
      const neden = await metinSor('İptal nedeni (zorunlu):', '', 'Kültür İptali');
      if (neden === null || neden.trim() === '') {
        mesaj('İptal nedeni zorunlu.');
        return true;
      }
      if (!await onay('Kültür iptal edilecek; tetkik tekrar numune bekliyor '
                    + 'durumuna döner.')) return true;
      await guvenli(async () => {
        mesaj((await api.labKulturIptal(id, neden.trim())).mesaj);
        b.tazele();
      });
      return true;
    }
  }

  return false;
}
