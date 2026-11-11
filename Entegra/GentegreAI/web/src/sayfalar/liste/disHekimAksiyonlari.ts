import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * DIŞ DOKTOR SAHA AKSİYONLARI (1289, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html): talep kapat / ret / göreve
 * çevir, ziyaret gördüm, ziyaretten dış doktor kartı. Kurallar uçta; ekran soruyu sorar, reddi gösterir.
 */
export interface DisHekimBaglam {
  tazele(): void;
  git?(yol: string): void;
}

const OZEL_KODLAR = new Set([
  'dis-hekim-ziyaret.goruldu', 'dis-hekim-ziyaret.hekim-karti', 'dis-hekim-ziyaret.musteri-karti',
  'dis-hekim-vade.musteri-karti',
  'dis-hekim-talep.kapat', 'dis-hekim-talep.ret', 'dis-hekim-talep.goreve-cevir',
  'dis-hekim-vade.planla', 'dis-hekim-vade.ziyaret-yaz', 'dis-hekim-vade.hekim-karti', 'dis-hekim-vade.plan',
]);

export async function disHekimAksiyonu(
  kod: string, satir: ListeSatiri | null | undefined, b: DisHekimBaglam,
): Promise<boolean> {
  // YALNIZ KENDİ KODLARI: Crud'un yeni / duzenle / sil kodları jenerik akışta kalır (kullanıcı 10.11.2026:
  //   "+ Ziyaret'e basınca ziyaret seçin diyor" - önek eşleşmesi yeni kaydı da yutuyordu).
  if (!OZEL_KODLAR.has(kod)) return false;
  if (kod === 'dis-hekim-vade.plan') { b.git?.('/dis-hekim-plan'); return true }
  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir satır seçin.'); return true }

  // ========================================================== VADE ==
  if (kod.startsWith('dis-hekim-vade.')) {
    const hekimId = Number(satir?.hekimId ?? id);
    const hekimAd = String(satir?.hekimAd ?? '');
    if (kod === 'dis-hekim-vade.hekim-karti') { b.git?.(`/dis-hekim/${hekimId}`); return true }
    // ERP (1297): ziyaret edilen müşteri.
    if (kod === 'dis-hekim-vade.musteri-karti') { b.git?.(`/cari/${hekimId}`); return true }
    if (kod === 'dis-hekim-vade.ziyaret-yaz') { b.git?.(`/dis-hekim-ziyaret/yeni?hekimId=${hekimId}`); return true }
    if (kod === 'dis-hekim-vade.planla') {
      const varsayilan = new Date(); varsayilan.setDate(varsayilan.getDate() + 1);
      const t = await metinSor(`${hekimAd} için planlı ziyaret tarihi (gg.aa.yyyy ss:dd):`,
                               varsayilan.toLocaleDateString('tr-TR') + ' 10:00', 'Tarih');
      if (t === null) return true;
      const m = t.trim().match(/^(\d{1,2})\.(\d{1,2})\.(\d{4})(?:\s+(\d{1,2}):(\d{2}))?$/);
      if (!m) { mesaj('Tarih biçimi: gg.aa.yyyy ss:dd'); return true }
      const iso = `${m[3]}-${m[2].padStart(2, '0')}-${m[1].padStart(2, '0')}T${(m[4] ?? '10').padStart(2, '0')}:${m[5] ?? '00'}:00`;
      await guvenli(async () => {
        const y = await api.disHekimPlanla({ hekimId, tarih: iso, temsilciId: Number(satir?.temsilciId ?? 0) || undefined });
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }
    return false;
  }

  // ======================================================== ZİYARET ==
  if (kod === 'dis-hekim-ziyaret.goruldu') {
    await guvenli(async () => {
      const y = await api.disHekimZiyaretGoruldu(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }
  if (kod === 'dis-hekim-ziyaret.hekim-karti' || kod === 'dis-hekim-ziyaret.musteri-karti') {
    const hekimId = Number(satir?.hekimId ?? 0);
    if (!hekimId) { mesaj('Ziyaretin tarafı yok.'); return true }
    b.git?.(kod === 'dis-hekim-ziyaret.musteri-karti' ? `/cari/${hekimId}` : `/dis-hekim/${hekimId}`);
    return true;
  }

  // ========================================================== TALEP ==
  const talep = String(satir?.talep ?? '').slice(0, 80);
  if (kod === 'dis-hekim-talep.kapat' || kod === 'dis-hekim-talep.ret') {
    const ret = kod === 'dis-hekim-talep.ret';
    const sonuc = await metinSor(ret ? `"${talep}" reddediliyor. Gerekçe:` : `"${talep}" karşılandı. Sonuç / yanıt:`,
                                 '', ret ? 'Gerekçe' : 'Sonuç');
    if (sonuc === null) return true;
    if (ret && !sonuc.trim()) { mesaj('Ret gerekçesi zorunlu.'); return true }
    await guvenli(async () => {
      const y = await api.disHekimTalepKapat(id, { durum: ret ? 4 : 3, sonuc: sonuc.trim() });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }
  if (kod === 'dis-hekim-talep.goreve-cevir') {
    const sorumlu = String(satir?.sorumluAd ?? '');
    if (!await onay(`"${talep}" için görev açılacak${sorumlu ? ` (sorumlu: ${sorumlu})` : ' (sorumlu: siz)'}.\n\n`
                  + 'Talep göreve bağlanır; görev kapanınca talebi burada kapatın. Devam edilsin mi?')) return true;
    await guvenli(async () => {
      const y = await api.disHekimTalepGoreveCevir(id);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }
  return false;
}
