import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * ENTEGRASYON HESAPLARI LİSTE AKSİYONLARI (336 · 455 · 820). Liste Genel Ayarlar'ın sekmesinden
 * bağımsız ekrana taşındı (22.10.2026); Yeni / Düzenle / Sil genel liste yolundan (kartYolu) gider,
 * burada yalnız hesaba özel işlemler. Dönüş: aksiyon burada ele alındıysa true.
 */
export async function entegrasyonAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                          tazele: () => void): Promise<boolean> {
  switch (kod) {
    // BAGLANTI SINAMA: kimlik dogru mu, adres ayakta mi - kayit degismez.
    case 'entegrasyon.sina':
      if (!satir) return true;
      await guvenli(async () => {
        const y = await api.entegrasyonSina(Number(satir.id));
        mesaj(y.mesaj);
        tazele();
      });
      return true;

    // KANAL SINAMASI (820): SMS/e-posta hesabina GERCEK mesaj gonderir. "Baglantiyi Sina" sunucunun
    //   ayakta olduguna bakiyor; kullanici adi yanlis ya da XML govdesi saglayicinin bekledigi
    //   bicimde degilse yine "basarili" derdi - kanalin calistiginin tek kaniti ULASAN mesajdir.
    case 'entegrasyon.test-bildirim': {
      if (!satir) return true;
      const smsMi = String(satir.kod ?? '') === 'SMS';
      const alici = await metinSor(
        smsMi ? 'Test SMS hangi numaraya gitsin?' : 'Test e-postası hangi adrese gitsin?',
        '', smsMi ? 'Numara (905XXXXXXXXX)' : 'E-posta adresi');
      if (!alici || !alici.trim()) return true;
      // DISARIYA GIDER: SMS ucretli, e-posta gercek bir kutuya duser.
      if (!await onay(smsMi
        ? `${alici} numarasına GERÇEK bir test SMS'i gönderilecek (ücretlidir). Devam?`
        : `${alici} adresine gerçek bir test e-postası gönderilecek. Devam?`)) return true;
      await guvenli(async () => {
        const y = await api.bildirimSina(Number(satir.id), alici.trim());
        mesaj(y.mesaj + (y.saglayiciRef ? ` · sağlayıcı: ${y.saglayiciRef}` : ''));
        tazele();
      });
      return true;
    }

    // SKRS listelerini servisten cekip YEREL kod listelerini tazeler.
    case 'entegrasyon.skrs-senkron':
      if (!satir) return true;
      if (String(satir.kod ?? '') !== 'SKRS') { mesaj('Bu işlem yalnız SKRS hesabında çalışır.'); return true }
      if (!await onay('SKRS kod listeleri servisten çekilip yerel listeler güncellenecek. Devam edilsin mi?')) return true;
      await guvenli(async () => {
        const y = await api.skrsListeSenkron(Number(satir.id));
        mesaj(y.mesaj);
        tazele();
      });
      return true;

    // SKRS klinik kodlarini BOLUM KODUNA yazar (455). Dolu kod korunur: kurum kendi kodlamasini
    //   yapmis olabilir.
    case 'entegrasyon.skrs-klinik':
      if (!satir) return true;
      if (String(satir.kod ?? '') !== 'SKRS') { mesaj('Bu işlem yalnız SKRS hesabında çalışır.'); return true }
      if (!await onay('Kodu BOŞ olan bölümlere SKRS klinik kodu yazılacak (dolu kodlara dokunulmaz). '
                      + 'Devam edilsin mi?')) return true;
      await guvenli(async () => {
        const y = await api.skrsKlinikEsle(Number(satir.id));
        mesaj(y.eslesmeyen.length > 0
          ? `${y.mesaj} Eşleşmeyen: ` + y.eslesmeyen.slice(0, 8).map(b => b.ad).join(', ')
          : y.mesaj);
        tazele();
      });
      return true;

    default:
      return false;
  }
}
