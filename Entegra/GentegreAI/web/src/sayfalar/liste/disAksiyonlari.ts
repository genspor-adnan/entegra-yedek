import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { guvenli, listeSor, mesaj, metinSor, onay } from '../../bilesenler/mesaj';

/**
 * DİŞ LİSTE AKSİYONLARI (706) — plan sun/onayla, seans bitir, lab aşaması,
 * ödeme planı üret, hasta kartına geç. Kurallar sunucuda; ekran soruyu sorar
 * ve sunucunun cümlesini gösterir.
 */

const LAB_ASAMALARI = [
  { kod: '2', ad: 'Gönderildi (kurye / portal)' },
  { kod: '3', ad: 'Tasarım onayı' },
  { kod: '4', ad: 'Üretim' },
  { kod: '5', ad: 'Geldi (teslim alındı)' },
  { kod: '6', ad: 'Prova' },
  { kod: '8', ad: 'Teslim edildi / simantasyon' },
  { kod: '9', ad: 'İptal' },
];

export interface DisAksiyonBaglam {
  tazele(): void;
  git(yol: string): void;
}

export async function disAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                  b: DisAksiyonBaglam): Promise<boolean> {
  if (!kod.startsWith('dis.')) return false;
  const id = Number(satir?.id ?? 0);

  if (kod === 'dis.hasta-karti') {
    // Hasta listesinde satır hastadır; plan/seans listesinde hastaId kolonu.
    const hastaId = Number(satir?.hastaId ?? satir?.id ?? 0);
    if (!hastaId) { mesaj('Önce bir satır seçin.'); return true }
    b.git(`/dis-hasta/${hastaId}`);
    return true;
  }

  if (kod === 'dis.plan-ac') {
    const hastaId = Number(satir?.id ?? 0);
    if (!hastaId) { mesaj('Önce bir hasta seçin.'); return true }
    b.git('/dis-plan/yeni');
    return true;
  }

  if (kod === 'dis.plan-sun') {
    if (!id) { mesaj('Önce bir plan seçin.'); return true }
    await guvenli(async () => { await api.disPlanSun(id); mesaj('Plan hastaya sunuldu; proforma numarası üretildi.'); b.tazele(); });
    return true;
  }

  if (kod === 'dis.plan-onayla') {
    if (!id) { mesaj('Önce bir plan seçin.'); return true }
    if (!await onay('Plan hasta onayıyla kapatılsın mı? Onaylı satırların fiyatı bundan sonra değişmez.')) return true;
    await guvenli(async () => { await api.disPlanOnayla(id); mesaj('Plan onaylandı.'); b.tazele(); });
    return true;
  }

  if (kod === 'dis.odeme-plani-uret') {
    if (!id) { mesaj('Önce bir plan seçin.'); return true }
    const pesinat = await metinSor('Peşinat tutarı', '0');
    if (pesinat === null) return true;
    const taksit = await metinSor('Taksit sayısı', '3');
    if (taksit === null) return true;
    await guvenli(async () => {
      const y = await api.disOdemePlaniUret(id, {
        pesinat: Number(String(pesinat).replace(',', '.')) || 0,
        taksitSayisi: Number(taksit) || 1,
      });
      mesaj(`Ödeme planı üretildi: ${y.taksit} taksit × ${y.taksitTutar.toLocaleString('tr-TR')}`
            + (y.pesinat > 0 ? ` · peşinat ${y.pesinat.toLocaleString('tr-TR')}` : ''));
      b.tazele();
    });
    return true;
  }

  if (kod === 'dis.seans-bitir') {
    if (!id) { mesaj('Önce bir seans seçin.'); return true }
    if (!await onay('Seans bitirilsin mi? "Bu seansta tamamlandı" işaretli işlemler ücretlenir ve odontograma işlenir.')) return true;
    await guvenli(async () => {
      const y = await api.disSeansBitir(id);
      mesaj(`Seans bitti · ${y.yapilan} işlem tamamlandı, ${y.ilerleyen} seans ilerledi`
            + (y.ucret > 0 ? ` · ücret ${y.ucret.toLocaleString('tr-TR')}` : '')
            + (y.uyari ? ` — ${y.uyari}` : ''));
      b.tazele();
    });
    return true;
  }

  if (kod === 'dis.lab-asama') {
    if (!id) { mesaj('Önce bir iş emri seçin.'); return true }
    const secim = await listeSor('Hangi aşamaya?', LAB_ASAMALARI);
    if (!secim) return true;
    await guvenli(async () => {
      await api.disLabAsama(id, { asama: Number(secim) });
      mesaj(`Aşama: ${LAB_ASAMALARI.find(a => a.kod === secim)?.ad ?? secim}`);
      b.tazele();
    });
    return true;
  }

  if (kod === 'dis.lab-geri') {
    if (!id) { mesaj('Önce bir iş emri seçin.'); return true }
    const not = await metinSor('Geri gönderme nedeni', '');
    if (not === null) return true;
    await guvenli(async () => { await api.disLabAsama(id, { asama: 7, not }); mesaj('İş laba geri gönderildi.'); b.tazele(); });
    return true;
  }

  return false;
}
