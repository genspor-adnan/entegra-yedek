import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';
import { dosyaIndirUrl } from '../../bilesenler/indir';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * DOKUMAN AKSIYONLARI (419) - surum ve onay dongusu.
 *
 * Onay kuyrugunda satir = ADIM, dokuman degil: ayni dokuman iki adimda iki
 * farkli kisiyi bekliyor olabilir ve herkes yalniz kendi adimini gormeli.
 *
 * RET dokumani TASLAGA dondurur; hazirlayan duzeltip yeni surum acar.
 * Reddedilen surumu yeniden onaya gondermek, neyin degistigini gorunmez
 * kilardi - denetimde "hangi haliyle onaylandi" sorusu cevapsiz kalirdi.
 */
export interface DokumanBaglam {
  tazele(): void;
  git(yol: string): void;
}

export async function dokumanAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: DokumanBaglam,
): Promise<boolean> {
  if (!kod.startsWith('dokuman.')) return false;

  // ---------------------------------------------------------------- liste
  if (kod === 'dokuman.depo') {
    await guvenli(async () => {
      const d = await api.dokumanDepo();
      const mb = (b: number) => (b / 1024 / 1024).toFixed(1) + ' MB';
      // DEDUP'IN DEGERI ancak olculunce gorunur: ayni dosya on kartta bir kez
      //   saklaniyor ve kac MB kazandirdigi burada yaziyor.
      mesaj(`Depo kullanımı\n\n`
          + `Fiziksel: ${mb(d.fizikselBayt)} (${d.icerikSayisi} içerik)\n`
          + `Mantıksal: ${mb(d.mantikselBayt)} (${d.dokumanSayisi} doküman)\n`
          + `Dedup tasarrufu: ${mb(d.tasarrufBayt)}`);
    });
    return true;
  }

  const dokumanId = Number(satir?.id ?? 0);

  if (kod === 'dokuman.ac') {
    if (!dokumanId) { mesaj('Önce bir doküman seçin.'); return true }
    // ICERIK UCU KIMLIK ISTER (Authorization). Adresi yeni sekmede acmak
    //   token tasimadigi icin 401 doner - bu yuzden icerik BLOB olarak
    //   cekilir (api.dokumanIcerikUrl) ve oradan indirilir/acilir; token
    //   URL'e de sizmaz. Galeri de ayni yolu kullaniyor.
    await guvenli(async () => {
      const url = await api.dokumanIcerikUrl(dokumanId);
      const ad = String(satir?.ad ?? 'dokuman');
      // Tarayicinin gosterebildigi tipler YENI SEKMEDE acilir (onizleme),
      //   otekiler indirilir: PDF icin indirme zorlamak gereksiz bir adim.
      const tip = String(satir?.contentType ?? '');
      if (tip.startsWith('image/') || tip === 'application/pdf' || tip.startsWith('text/'))
        window.open(url, '_blank');
      else dosyaIndirUrl(url, ad, true);
    });
    return true;
  }

  if (kod === 'dokuman.surum') {
    if (!dokumanId) { mesaj('Önce bir doküman seçin.'); return true }
    b.git(`/dokuman/${dokumanId}`);
    return true;
  }

  if (kod === 'dokuman.tasi') {
    if (!dokumanId) { mesaj('Önce bir doküman seçin.'); return true }
    await guvenli(async () => {
      const k = await api.dokumanKlasorleri();
      if (k.kurumsal.length === 0) { mesaj('Tanımlı kurumsal klasör yok.'); return }
      const secim = await secimSor('Hangi klasöre taşınsın?',
        k.kurumsal.map(x => ({ kod: String(x.id), ad: x.yol })));
      if (!secim) return;
      const y = await api.dokumanTasi(dokumanId, { klasorId: Number(secim) });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'dokuman.etiket') {
    if (!dokumanId) { mesaj('Önce bir doküman seçin.'); return true }
    const metin = await metinSor('Etiketler (virgülle ayırın)',
                                 String(satir?.etiketler ?? ''), 'Etiket');
    if (metin === null) return true;
    await guvenli(async () => {
      const y = await api.dokumanTasi(dokumanId, {
        etiketler: metin.split(',').map(x => x.trim()).filter(Boolean),
      });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'dokuman.gizlilik') {
    if (!dokumanId) { mesaj('Önce bir doküman seçin.'); return true }
    const secim = await secimSor('Gizlilik sınıfı', [
      { kod: '1', ad: 'Herkese Açık' },
      { kod: '2', ad: 'Kurum İçi' },
      { kod: '3', ad: 'Gizli' },
      { kod: '4', ad: 'Özel Nitelikli (KVKK)' },
    ], String(satir?.gizlilik ?? 2));
    if (!secim) return true;
    await guvenli(async () => {
      const y = await api.dokumanTasi(dokumanId, { gizlilik: Number(secim) });
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  if (kod === 'dokuman.onaya-gonder') {
    if (!dokumanId) { mesaj('Önce bir doküman seçin.'); return true }
    if (Number(satir?.surumlu ?? 0) !== 1) {
      mesaj('Bu tür sürümsüz: yüklenen dosya doğrudan yayında olur, onay akışı yok.');
      return true;
    }
    // Onaya gonderilen SURUMDUR, dokuman degil: kartta hangi surumun
    //   gonderildigi gorunmeli.
    b.git(`/dokuman/${dokumanId}`);
    mesaj('Onaya göndermek için karttaki Sürümler sekmesinden taslak sürümü seçin.');
    return true;
  }

  if (kod !== 'dokuman.onay' && kod !== 'dokuman.ret') return false;

  const onayId = Number(satir?.onayId ?? 0);
  if (!onayId) { mesaj('Önce bir onay adımı seçin.'); return true }
  const ad = String(satir?.dokumanAd ?? '');

  if (kod === 'dokuman.onay') {
    if (!await onay(`"${ad}" onaylansın mı?\n\n`
                  + 'Son adımsa sürüm yayınlanır ve önceki sürüm arşive düşer.')) return true;
    await guvenli(async () => {
      const y = await api.dokumanOnayKarar(onayId, 1);
      mesaj(y.mesaj);
      b.tazele();
    });
    return true;
  }

  // RET GEREKÇESİ ZORUNLU: hazırlayan neyi düzelteceğini bilmeli.
  const gerekce = await metinSor(`"${ad}" neden reddediliyor?`, '', 'Gerekçe');
  if (gerekce === null) return true;
  if (!gerekce.trim()) { mesaj('Ret gerekçesi zorunlu.'); return true }

  await guvenli(async () => {
    const y = await api.dokumanOnayKarar(onayId, 2, gerekce.trim());
    mesaj(y.mesaj);
    b.tazele();
  });
  return true;
}
