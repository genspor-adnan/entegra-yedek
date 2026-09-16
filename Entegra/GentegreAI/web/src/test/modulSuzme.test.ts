import { describe, it, expect } from 'vitest';
import { LISTELER, MENU_GRUP_MODUL, modulAcikMi } from '../sayfalar/listeTanimlari';

/**
 * KURUM PROFİLİ MODÜL SÜZMESİ (359).
 *
 * Kurulumda kapatılan modülün ekranları menüde ÇİZİLMEZ ve rotası açılmaz.
 * Bağ tek bir alandan kurulur: listenin `modul` kodu (yoksa menü grubunun
 * varsayılanı). O kod yanlış yazılınca süzme sessizce çalışmaz - ekran
 * kapalı modülde de görünmeye devam eder ve kimse fark etmez.
 *
 * Nitekim e-Nabız listeleri `modul: 'muayene'` taşıyordu: kullanıcı kurum
 * profilinden "e-Nabız"ı kapatıp kaydediyor, menüde duruyordu.
 */
describe('modül süzmesi', () => {
  it('e-Nabız kapalıysa e-Nabız ekranları gizlenir', () => {
    const enabiz = LISTELER.filter(l => l.menuGrup === 'e-Nabız');
    expect(enabiz.length).toBeGreaterThan(0);

    // Kurulumda e-Nabız DIŞINDA her şey açık.
    const acik = Object.values(MENU_GRUP_MODUL).filter(m => m !== 'enabiz');
    for (const l of enabiz) {
      expect(modulAcikMi(l, acik), `${l.baslik} gizlenmeliydi`).toBe(false);
    }
  });

  it('e-Nabız açıkken ekranlar görünür', () => {
    const enabiz = LISTELER.filter(l => l.menuGrup === 'e-Nabız');
    for (const l of enabiz) {
      expect(modulAcikMi(l, ['enabiz']), `${l.baslik} görünmeliydi`).toBe(true);
    }
  });

  it('her menü grubu bir modüle bağlıdır ya da bilerek bağsızdır', () => {
    // Bağsız kalması GEREKENLER: ayar/kullanıcı ekranları kapatılamaz -
    //   yoksa kapatılan modül geri açılamazdı.
    // Menu yeniden duzeni (plan 11): Cari+CRM tek grup, IK & Prim, ve
    //   Kurumlar & Sigorta - ucu de kapatilamaz cekirdek ekranlar.
    // Medula (707): modül kapısı yok - SGK'lı hasta kabul eden her HBYS
    //   kurumunda görünür, hesap tanımsızsa kuyruk ekranı bunu söyler.
    const bagsiz = new Set(['Yönetim', 'Ana Sayfa', 'Cari & CRM', 'İK & Prim',
                            'Kurumlar & Sigorta', 'Demirbaş', 'Medula']);
    const gruplar = new Set(LISTELER.map(l => l.menuGrup).filter(Boolean) as string[]);

    for (const g of gruplar) {
      if (bagsiz.has(g)) continue;
      const ornek = LISTELER.find(l => l.menuGrup === g)!;
      const kod = ornek.modul ?? MENU_GRUP_MODUL[g];
      expect(kod, `"${g}" grubu hiçbir modüle bağlı değil`).toBeTruthy();
    }
  });

  it('modül bilgisi yoksa hiçbir şey süzülmez', () => {
    // Eski kurulumda profil satırı olmayabilir; ekranın kaybolmasındansa
    //   görünmesi yeğlenir.
    const l = LISTELER.find(x => x.menuGrup === 'e-Nabız')!;
    expect(modulAcikMi(l, [])).toBe(true);
    expect(modulAcikMi(l, undefined)).toBe(true);
  });
});
