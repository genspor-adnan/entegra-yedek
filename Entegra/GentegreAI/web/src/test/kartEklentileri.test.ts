import { describe, expect, it } from 'vitest';
import { LISTELER } from '../sayfalar/Liste';
import type { ListeTanimi } from '../sayfalar/listeTanimlari';
import { yeniKartVarsayilanlari } from '../sayfalar/liste/kartVarsayilanlari';
import { KART_EKLENTILERI, type KartEklentiBaglami } from '../sayfalar/liste/kartEklentileri';

/**
 * KART EKLENTİLERİ ve YENİ KART ÖN DOLGUSU (refaktör 22.10.2026) - ListeKarti'nin zincirlerinden
 * ayrılan saf parçalar. Davranış zincirdekiyle aynı kalmalı.
 */
const tanim = (kaynak: string, ek: Partial<ListeTanimi> = {}) =>
  ({ kaynak, baslik: kaynak, yol: kaynak, ...ek }) as ListeTanimi;
const q = (s: string) => new URLSearchParams(s);

describe('yeniKartVarsayilanlari', () => {
  it('parametre yoksa liste tanımının kendi varsayılanları', () => {
    const t = tanim('entegrasyon-hesap', { yeniKayitVarsayilanlari: { bazSubeId: 0, testMi: true } });
    expect(yeniKartVarsayilanlari(t, 'yeni', q(''))).toEqual({ bazSubeId: 0, testMi: true });
    expect(yeniKartVarsayilanlari(tanim('cari'), 'yeni', q(''))).toBeUndefined();
  });

  it('Ctrl+K: hasta / personel yeni kartı TC ya da telefon dolu; kayıtlı kartta uygulanmaz', () => {
    expect(yeniKartVarsayilanlari(tanim('hasta'), 'yeni', q('vkno=12345678901'))).toEqual({ vkno: '12345678901' });
    expect(yeniKartVarsayilanlari(tanim('personel'), 'yeni', q('cepTel=%2B90%20555%20444%2033%2022')))
      .toEqual({ cepTel: '+90 555 444 33 22' });
    expect(yeniKartVarsayilanlari(tanim('hasta'), 5, q('vkno=12345678901'))).toBeUndefined();
    expect(yeniKartVarsayilanlari(tanim('cari'), 'yeni', q('vkno=12345678901'))).toBeUndefined();
  });

  it('konsültasyon / sevk önce sorulan hastayla açılır', () => {
    expect(yeniKartVarsayilanlari(tanim('sevk'), 'yeni', q('tarafId=42'))).toEqual({ tarafId: 42 });
  });

  it('metin makrosu muayenedeki alanla açılır', () => {
    expect(yeniKartVarsayilanlari(tanim('metin-makro'), 'yeni', q('alan=sikayet'))).toEqual({ alan: 'sikayet', durum: 1 });
  });

  it('randevu takvimden: saat, süre, hekim, bölüm, cihaz, hasta - yalnız gelenler', () => {
    expect(yeniKartVarsayilanlari(tanim('randevu'), 'yeni',
      q('baslangic=2026-10-23T09:00&sure=20&hekim=7&bolum=3&cihaz=2&hastaId=9')))
      .toEqual({ baslangic: '2026-10-23T09:00', sureDk: 20, hekimId: 7, bolum: 3, cihazId: 2, hastaId: 9 });
    expect(yeniKartVarsayilanlari(tanim('randevu'), 'yeni', q('hekim=7'))).toEqual({ hekimId: 7 });
  });

  it('göz kısayolları, diş lab, İSG, DÖF, tedarikçi, çalışma planı, hasta kayıtları, ödeme planı', () => {
    expect(yeniKartVarsayilanlari(tanim('goz-goruntuleme'), 'yeni', q('hastaId=1&muayeneId=2'))).toEqual({ hastaId: 1, muayeneId: 2 });
    expect(yeniKartVarsayilanlari(tanim('dis-lab-isemri'), 'yeni', q('hastaId=1&disNolar=11,12')))
      .toEqual({ hastaId: 1, disNolar: '11,12' });
    expect(yeniKartVarsayilanlari(tanim('isg-olay'), 'yeni', q('firmaId=4'))).toEqual({ firmaId: 4 });
    expect(yeniKartVarsayilanlari(tanim('kys-dof'), 'yeni', q('kaynakTur=2&kaynakNo=B-7&birimId=5')))
      .toEqual({ kaynakTur: 2, kaynakNo: 'B-7', departmanId: 5 });
    expect(yeniKartVarsayilanlari(tanim('kys-tedarikci'), 'yeni', q('tarafId=8&neAliniyor=eldiven')))
      .toEqual({ tarafId: 8, neAliniyor: 'eldiven' });
    expect(yeniKartVarsayilanlari(tanim('calisma-istisna'), 'yeni', q('hekimId=3'))).toEqual({ hekimId: 3 });
    expect(yeniKartVarsayilanlari(tanim('hasta-alerji'), 'yeni', q('hastaId=6'))).toEqual({ hastaId: 6 });
    expect(yeniKartVarsayilanlari(tanim('dis-odeme-plani'), 'yeni', q('planId=2&toplam=150'))).toEqual({ planId: 2, toplam: 150 });
  });

  it('ekran varsayılanı korunur, parametre üstüne yazar', () => {
    const t = tanim('randevu', { yeniKayitVarsayilanlari: { durum: 1, hekimId: 1 } });
    expect(yeniKartVarsayilanlari(t, 'yeni', q('hekim=7'))).toEqual({ durum: 1, hekimId: 7 });
  });
});

describe('KART_EKLENTILERI', () => {
  const b = (kartId: KartEklentiBaglami['kartId']): KartEklentiBaglami => ({
    tanim: tanim('x'), kartId, git: () => {}, tazele: 0, tazeleKayit: 0, kartiTazele: () => {},
    listeyiTazele: () => {}, kartiKaydet: async () => true, aksiyon: () => {}, yetki: () => true,
    rozet: null, rozetYaz: () => {},
  });

  it('her eklenti kartı olan bir liste kaynağına ait (yazım hatası sessizce eklentiyi kapatır)', () => {
    const kartli = new Set(LISTELER.filter(l => l.kartYolu).map(l => l.kaynak));
    for (const k of Object.keys(KART_EKLENTILERI)) expect(kartli, k).toContain(k);
  });

  it('kart yokken (null) hiçbir eklenti ek sekme üretmez; kayda bağlı araçlar da yok', () => {
    for (const [k, e] of Object.entries(KART_EKLENTILERI)) expect(e.ekSekmeler?.(b(null)), k).toBeUndefined();
    // DÖF / denetim / toplantı araçları kayıttan bağımsız (zincirde de koşulsuzdu) - yeni kartta da var.
    for (const k of ['personel-belge-turu', 'acilYatak', 'yatis-order', 'randevu', 'goz-goruntuleme', 'goz-gozluk-recete'])
      expect(KART_EKLENTILERI[k].ekAraclar?.(b('yeni')), k).toBeUndefined();
  });

  it('kayıtlı karta bağlı ek sekmeler yeni kartta açılmaz; "yeni kartta da" olanlar açılır', () => {
    expect(KART_EKLENTILERI['personel-belge-turu'].ekSekmeler!(b('yeni'))).toBeUndefined();
    expect(KART_EKLENTILERI['yatis-order'].ekSekmeler!(b('yeni'))).toBeUndefined();
    expect(KART_EKLENTILERI['radyoloji-sablon'].ekSekmeler!(b('yeni'))?.map(s => s.baslik)).toEqual(['Önizleme', 'Sürümler', 'Kullanım']);
    expect(KART_EKLENTILERI['personel-belge-turu'].ekSekmeler!(b(5))?.map(s => s.baslik))
      .toEqual(['Personel durumu', 'Hatırlatma', 'Hareketler']);
  });

  it('belge türü rozeti sekmeye gider; sıfırsa rozet yok', () => {
    const e = KART_EKLENTILERI['personel-belge-turu'].ekSekmeler!;
    expect(e({ ...b(5), rozet: 3 })?.[0].rozet).toEqual({ metin: '3', hata: true });
    expect(e({ ...b(5), rozet: 0 })?.[0].rozet).toBeUndefined();
  });
});
