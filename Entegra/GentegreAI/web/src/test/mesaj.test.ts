import { describe, it, expect, afterEach } from 'vitest';
import { mesajDinleyiciAta, secimSor, onay, metinSor, type MesajIstegi } from '../bilesenler/mesaj';

/**
 * UC SECENEKLI SORU (kullanici: "kaydetmeden çıkışta soru da 3 seçenek
 * Kaydet/İptal/Geri Dön").
 *
 * Kritik kural: pencere Escape/perde ile kapatilirsa GUVENLI secenek donmeli -
 * "geri don". Aksi halde kullanicinin kacamak kapatmasi degisiklikleri atardi
 * ya da istemeden kaydederdi.
 */
function katmanKur() {
  const gelen: MesajIstegi[] = [];
  mesajDinleyiciAta(i => { gelen.push(i) });
  return gelen;
}

afterEach(() => mesajDinleyiciAta(null));

describe('secimSor - istek sekli', () => {
  it('secenekleri ve varsayilan kodu katmana tasir', async () => {
    const gelen = katmanKur();
    const soz = secimSor('Kaydedilsin mi?', [
      { kod: 'kaydet', ad: '💾 Kaydet', sinif: 'bir' },
      { kod: 'iptal', ad: '✖ İptal', sinif: 'teh' },
      { kod: 'geri', ad: '↩ Geri Dön' },
    ], 'geri');

    const istek = gelen[0];
    expect(istek.metin).toBe('Kaydedilsin mi?');
    expect(istek.onayMi).toBe(true);
    expect(istek.secenekler?.map(x => x.kod)).toEqual(['kaydet', 'iptal', 'geri']);
    expect(istek.varsayilanKod).toBe('geri');

    istek.cozumSecim?.('kaydet');
    expect(await soz).toBe('kaydet');
  });

  it('her secenek kendi kodunu doner', async () => {
    for (const kod of ['kaydet', 'iptal', 'geri']) {
      const gelen = katmanKur();
      const soz = secimSor('?', [
        { kod: 'kaydet', ad: 'K' }, { kod: 'iptal', ad: 'I' }, { kod: 'geri', ad: 'G' },
      ], 'geri');
      gelen[0].cozumSecim?.(kod);
      expect(await soz).toBe(kod);
    }
  });

  it('varsayilan verilmezse SON secenek guvenli sayilir', () => {
    const gelen = katmanKur();
    void secimSor('?', [{ kod: 'kaydet', ad: 'K' }, { kod: 'geri', ad: 'G' }]);
    expect(gelen[0].varsayilanKod).toBe('geri');
  });

  it('katman yoksa (teorik) guvenli secenek doner - tarayici kutusu ACILMAZ', async () => {
    mesajDinleyiciAta(null);
    expect(await secimSor('?', [
      { kod: 'kaydet', ad: 'K' }, { kod: 'geri', ad: 'G' },
    ], 'geri')).toBe('geri');
  });
});

describe('mesaj altyapisi - eski cagrilar bozulmadi', () => {
  it('onay: Tamam true, Vazgeç false', async () => {
    const gelen = katmanKur();
    const evet = onay('Silinsin mi?', true);
    expect(gelen[0].tehlike).toBe(true);
    expect(gelen[0].secenekler).toBeUndefined();   // iki dugmeli klasik onay
    gelen[0].cozum(true);
    expect(await evet).toBe(true);

    const gelen2 = katmanKur();
    const hayir = onay('Silinsin mi?');
    gelen2[0].cozum(false);
    expect(await hayir).toBe(false);
  });

  it('metinSor: iptalde null, yazinca deger', async () => {
    const gelen = katmanKur();
    const soz = metinSor('İptal sebebi:', '');
    expect(gelen[0].girdiMi).toBe(true);
    gelen[0].cozumMetin?.('yanlış kayıt');
    expect(await soz).toBe('yanlış kayıt');

    const gelen2 = katmanKur();
    const soz2 = metinSor('İptal sebebi:');
    gelen2[0].cozumMetin?.(null);
    expect(await soz2).toBeNull();
  });
});
