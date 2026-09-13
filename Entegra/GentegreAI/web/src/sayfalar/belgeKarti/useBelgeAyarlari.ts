import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { type KasaIslemTuru } from '../../api/sozlesme';
import { GERIYE_GUN_VARSAYILAN, YEREL_PARA_VARSAYILAN } from '../belgeSabitleri';

/**
 * SUNUCUDAN GELEN KART AYARLARI — tür adları, tarih penceresi, yerel para,
 * POS aksiyonu.
 *
 * Dördü de açılışta bir kez okunur ve bir daha değişmez; kartın 45 state'i
 * arasında dağınık duruyorlardı. Bir arada olmalarının sebebi ortak: hepsi
 * SUNUCUNUN söylediği, kullanıcının kart üzerinde değiştirmediği değerler.
 *
 * Ayar okunamazsa varsayılanla devam edilir - sunucu zaten aynı kuralı
 * uyguluyor, buradaki sınır sadece erken uyarı.
 */
export function useBelgeAyarlari() {
  /** Belge türü adları katalogtan gelir; istemcide ikinci bir liste tutulmaz. */
  const [turler, setTurler] = useState<KasaIslemTuru[]>([]);

  /** Geriye dönük kaç gün belge girilebilir (`belge.geri_gun_siniri`). */
  const [geriGun, setGeriGun] = useState(GERIYE_GUN_VARSAYILAN);

  /** Kurumun para birimi (`genel.yerel_para`). */
  const [yerelPara, setYerelPara] = useState(YEREL_PARA_VARSAYILAN);

  /**
   * POS aksiyonu (355): 0 yok · 1 otomatik fiş · 2 sor.
   *
   * Tek DEĞİŞEBİLEN ayar: para akışları kancası, kullanıcı "bir daha sorma"
   * dediğinde değeri oturum içinde düşürür - o yüzden setter da dışa verilir.
   */
  const [posAksiyon, setPosAksiyon] = useState(0);

  useEffect(() => {
    void api.ayarlar()
      .then(a => {
        const s = a.find(x => x.anahtar === 'belge.geri_gun_siniri')?.deger;
        if (s !== undefined && s !== '' && Number.isFinite(Number(s))) setGeriGun(Number(s));
        const p = a.find(x => x.anahtar === 'genel.yerel_para')?.deger;
        if (p) setYerelPara(p);
        const pa = a.find(x => x.anahtar === 'basvuru.pos_aksiyon')?.deger;
        if (pa !== undefined && pa !== '') setPosAksiyon(Number(pa) || 0);
      })
      .catch(() => { /* varsayılan kalır */ });
  }, []);

  useEffect(() => {
    void (async () => {
      try { setTurler(await api.kasaIslemTurleri()) } catch { /* ad yoksa kod gösterilir */ }
    })();
  }, []);

  /** Tür adı; katalogta yoksa kodun kendisi gösterilir. */
  const turAdi = (kod: number) => turler.find(t => t.kod === kod)?.ad ?? `Belge (${kod})`;

  return { turler, turAdi, geriGun, yerelPara, posAksiyon, setPosAksiyon };
}
