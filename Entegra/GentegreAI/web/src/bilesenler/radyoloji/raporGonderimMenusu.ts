import { api } from '../../api/istemci';
import type { ListeSatiri } from '../../api/sozlesme';
import { raporBaglantisi } from '../../api/uclar/raporGonderim';
import { guvenli, mesaj, onay } from '../mesaj';

/**
 * RADYOLOJİ RAPOR TESLİM › GÖNDERİM ▾ (1390; kullanıcı 20.11.2026; mockup radyoloji_rapor_hasta_goruntuleme.html §5).
 * Satırın hasta / gönderen dış doktor gönderimi üzerinde: şimdi gönder (yeniden gönder), bekleyeni iptal et, borca
 * rağmen gönder (ayrı yetki - sunucu denetler), bağlantıyı kopyala, başvuruyu aç (tahsilat).
 */
export const GONDERIM_KODU = 'radyoloji.rapor-gonderim';

export const GONDERIM_MENUSU: { kod: string; ad: string; sinif?: string }[] = [
  { kod: 'radyoloji.gonderim.hasta',        ad: '📨 Hastaya Şimdi Gönder' },
  { kod: 'radyoloji.gonderim.hekim',        ad: '📨 Dış Doktora Şimdi Gönder' },
  { kod: 'radyoloji.gonderim.iptal',        ad: '✖ Bekleyen Gönderimi İptal Et' },
  { kod: 'radyoloji.gonderim.ayrac1.ayrac', ad: '' },
  { kod: 'radyoloji.gonderim.borc-hasta',   ad: '⚠ Borca Rağmen Gönder › Hastaya' },
  { kod: 'radyoloji.gonderim.borc-hekim',   ad: '⚠ Borca Rağmen Gönder › Dış Doktora' },
  { kod: 'radyoloji.gonderim.ayrac2.ayrac', ad: '' },
  { kod: 'radyoloji.gonderim.baglanti',     ad: '🔗 Hasta Bağlantısını Kopyala' },
  { kod: 'radyoloji.gonderim.tahsilat',     ad: '💵 Başvuruyu Aç (Tahsilat)' },
];

const DURUM_METNI: Record<number, string> = {
  0: 'Hazır (otomatik gönderim yok).', 1: 'Planlandı.', 2: 'Başvurunun borcu var - bekliyor. Borç kapanınca kendiliğinden gider.',
  3: 'Gönderildi.', 4: 'Gönderilemedi.', 9: 'İptal.',
};

/** Gönderim ▾ alt menü kodu burada ele alındıysa true. */
export async function raporGonderimAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                            b: { tazele(): void; git(yol: string): void }): Promise<boolean> {
  if (!kod.startsWith('radyoloji.gonderim.')) return false;
  if (!satir) return true;
  const hastaId = Number(satir.hastaGonderimId ?? 0), hekimId = Number(satir.hekimGonderimId ?? 0);
  const yok = (kime: string) => mesaj(`${kime} için gönderim kaydı yok. ${kime === 'Dış doktor'
    ? 'Gönderen dış doktor yok ya da kartında "Rapor Bildirimi" seçili değil.' : 'Rapor onaylanınca bağlantı oluşur.'}`);
  const gonder = async (id: number, borcaRagmen: boolean) => {
    await guvenli(async () => {
      const y = await api.raporGonder(id, borcaRagmen);
      mesaj(DURUM_METNI[y.durum] ?? 'İşlendi.');
      b.tazele();
    });
  };

  switch (kod) {
    case 'radyoloji.gonderim.hasta': if (hastaId) await gonder(hastaId, false); else yok('Hasta'); return true;
    case 'radyoloji.gonderim.hekim': if (hekimId) await gonder(hekimId, false); else yok('Dış doktor'); return true;
    case 'radyoloji.gonderim.borc-hasta':
    case 'radyoloji.gonderim.borc-hekim': {
      const hekim = kod.endsWith('hekim');
      const id = hekim ? hekimId : hastaId;
      if (!id) { yok(hekim ? 'Dış doktor' : 'Hasta'); return true }
      if (!(await onay(`Başvurunun borcu olsa da rapor ${hekim ? 'gönderen dış doktora' : 'hastaya'} gönderilecek ve bağlantı raporu açacak. Devam edilsin mi?`, true)))
        return true;
      await gonder(id, true);
      return true;
    }
    case 'radyoloji.gonderim.iptal': {
      const bekleyen = [[hastaId, Number(satir.hastaGonderimDurum)], [hekimId, Number(satir.hekimGonderimDurum)]]
        .filter(([id, d]) => id > 0 && (d === 1 || d === 2)).map(([id]) => id);
      if (bekleyen.length === 0) { mesaj('Bekleyen gönderim yok.'); return true }
      if (!(await onay('Bekleyen gönderim iptal edilecek (bağlantı ve basılmış karekod çalışmaya devam eder). Devam edilsin mi?'))) return true;
      await guvenli(async () => { for (const id of bekleyen) await api.raporGonderimIptal(id); b.tazele() });
      return true;
    }
    case 'radyoloji.gonderim.baglanti':
      await guvenli(async () => {
        // Kod satırda (1396 - lab satırının istemi yok); eski yanıtta yoksa istemden okunur.
        let h: { kod: string; webKok: string } | undefined = satir.hastaKod
          ? { kod: String(satir.hastaKod), webKok: String(satir.hastaWebKok ?? '') } : undefined;
        if (!h && Number(satir.kaynakTur) !== 2)
          h = (await api.raporGonderimleri(Number(satir.istemId ?? satir.id))).satirlar.find(s => s.aliciTur === 1);
        if (!h) { mesaj('Bağlantı yok: rapor / sonuç onaylanınca oluşur.'); return }
        const adres = raporBaglantisi(h.kod, h.webKok);
        await navigator.clipboard.writeText(adres);
        mesaj(`Bağlantı kopyalandı: ${adres}`);
      });
      return true;
    case 'radyoloji.gonderim.tahsilat': {
      const basvuru = Number(satir.basvuruId ?? 0);
      if (basvuru) b.git(`/basvuru/${basvuru}`); else mesaj('Bu istem bir başvuruya bağlı değil.');
      return true;
    }
    default: return true;
  }
}
