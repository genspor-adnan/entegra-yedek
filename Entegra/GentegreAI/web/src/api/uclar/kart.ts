import {
  type AksiyonListesi, type KartMetaYaniti, type KartYaniti, type KartYazmaIstegi, type DetaySayfasi,
  type KisiKaydi, type KisiIstegi, type YerlerYaniti,
  type YetkiSatiri, type YetkiSatiriIstegi, type DokumanSatiri,
  } from '../sozlesme';
import { istek, gonder, dosyaYukle, dosyaIndir, TABAN } from '../cekirdek';
import type {
  KullaniciSubeSatiri, KartRolBilgisi, RolKullanicisi,
  } from '../tipler';

/** Kart, ilgili kisiler, rol yetkileri, dokuman, referans, aksiyon. */
export const kartUclari = {
  // --------------------------------------------------------------- kart ----
  kartAlanlari: (kaynak: string) => istek<KartMetaYaniti>(`/api/kart/${kaynak}/alanlar`),
  kartOku: (kaynak: string, id: number) => istek<KartYaniti>(`/api/kart/${kaynak}/${id}`),
  /** SAYFALI DETAY (525): buyuk detayin sonraki sayfasi. */
  kartDetaySayfasi: (kaynak: string, id: number, ad: string, sayfa: number, boyut: number,
                     ara?: string, kategori?: number, cip?: string) => {
    // SUZGEC SUNUCUDA (526): arama/kategori/cip listenin TAMAMINA uygulanir,
    //   sayfalama da suzulmus sonuc uzerinden isler.
    const p = new URLSearchParams({ sayfa: String(sayfa), boyut: String(boyut) });
    if (ara?.trim()) p.set('ara', ara.trim());
    if (kategori) p.set('kategori', String(kategori));
    if (cip) p.set('cip', cip);
    return istek<DetaySayfasi>(`/api/kart/${kaynak}/${id}/detay/${ad}?${p}`);
  },
  kartEkle: (kaynak: string, govde: KartYazmaIstegi) =>
    gonder<KartYaniti>(`/api/kart/${kaynak}`, govde),
  kartGuncelle: (kaynak: string, id: number, govde: KartYazmaIstegi) =>
    gonder<KartYaniti>(`/api/kart/${kaynak}/${id}`, govde, 'PUT'),
  kartSil: (kaynak: string, id: number) =>
    istek<void>(`/api/kart/${kaynak}/${id}`, { method: 'DELETE' }),
  kartlar: () => istek<{ kartlar: { ad: string; ekle: boolean; degistir: boolean; sil: boolean }[] }>('/api/kart'),

  // ------------------------------------------------ cari > ilgili kisiler ----
  kisiler: (tarafId: number) => istek<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler`),
  kisiEkle: (tarafId: number, govde: KisiIstegi) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler`, govde),
  kisiGuncelle: (tarafId: number, kisiId: number, govde: KisiIstegi) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}`, govde, 'PUT'),
  kisiSil: (tarafId: number, kisiId: number) =>
    istek<void>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}`, { method: 'DELETE' }),
  kisiBagla: (tarafId: number, kisiId: number) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}/bagla`, {}),
  kisiKopar: (tarafId: number, kisiId: number) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}/kopar`, {}),

  // ------------------------------------------------------- rol > yetkiler ----
  rolYetkileri: (rolId: number) => istek<YetkiSatiri[]>(`/api/kart/rol/${rolId}/yetkiler`),
  /** Personel/kisi kartindan rol goster-degistir. */
  kartRol: (kartId: number) =>
    istek<KartRolBilgisi>(`/api/kart/kullanici/${kartId}/rol`),
  kartRolDegistir: (kartId: number, rolId: number) =>
    istek<KartRolBilgisi>(`/api/kart/kullanici/${kartId}/rol/${rolId}`, { method: 'PUT' }),
  kartSubeleri: (kartId: number) =>
    istek<KullaniciSubeSatiri[]>(`/api/kart/kullanici/${kartId}/subeler`),
  kartSubeKaydet: (kartId: number, satirlar: Omit<KullaniciSubeSatiri, 'subeAdi'>[]) =>
    istek<KullaniciSubeSatiri[]>(`/api/kart/kullanici/${kartId}/subeler`,
      { method: 'PUT', body: JSON.stringify({ satirlar }) }),
  rolKullanicilari: (rolId: number) =>
    istek<RolKullanicisi[]>(`/api/kart/rol/${rolId}/kullanicilar`),
  rolKullaniciAdaylari: (rolId: number, arama: string) =>
    istek<RolKullanicisi[]>(
      `/api/kart/rol/${rolId}/kullanicilar/adaylar?arama=${encodeURIComponent(arama)}`),
  rolKullaniciEkle: (rolId: number, kullaniciId: number) =>
    gonder<RolKullanicisi[]>(`/api/kart/rol/${rolId}/kullanicilar/${kullaniciId}`, {}),
  rolKullaniciCikar: (rolId: number, kullaniciId: number) =>
    istek<{ mesaj: string; kullanicilar: RolKullanicisi[] }>(
      `/api/kart/rol/${rolId}/kullanicilar/${kullaniciId}`, { method: 'DELETE' }),
  rolYetkiKaydet: (rolId: number, satirlar: YetkiSatiriIstegi[]) =>
    gonder<YetkiSatiri[]>(`/api/kart/rol/${rolId}/yetkiler`, { satirlar }, 'PUT'),

  // ------------------------------------------------------------- dokuman ----
  dokumanlar: (kartAdi: string, kaynakId: number) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}`),
  // yon: 0 uygulanmaz · 1 gelen · 2 giden (e-Belge XSLT sablonlari, 160).
  dokumanYukle: (kartAdi: string, kaynakId: number, dosya: File, varsayilan: boolean, yon = 0) => {
    const form = new FormData();
    form.append('dosya', dosya);
    form.append('varsayilan', varsayilan ? 'true' : 'false');
    if (yon) form.append('yon', String(yon));
    return dosyaYukle<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}`, form);
  },
  dokumanVarsayilanYap: (kartAdi: string, kaynakId: number, dokumanId: number) =>
    gonder<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}/varsayilan`, {}),
  // kaynakId/yon/varsayilan yalniz e-Belge XSLT sablonlarinda gonderilir (160):
  //   orada belge turu ve yon dosyanin kimligidir, sonradan duzeltilebilmeli.
  dokumanDuzenle: (kartAdi: string, kaynakId: number, dokumanId: number, ad: string,
                   belgeTuru: string, ek?: { kaynakId?: number; yon?: number; varsayilan?: boolean }) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}`,
      { method: 'PUT', body: JSON.stringify({ ad, belgeTuru, ...ek }) }),
  dokumanSil: (kartAdi: string, kaynakId: number, dokumanId: number) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}`, { method: 'DELETE' }),
  dokumanIcerikUrl: (dokumanId: number) => dosyaIndir(`/api/dokuman-icerik/${dokumanId}`),
  dokumanPaylas: async (kartAdi: string, kaynakId: number, dokumanId: number) => {
    const { kod } = await gonder<{ kod: string }>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}/paylas`, {});
    return `${TABAN}/api/dokuman-paylasim/${kod}`;
  },

  // ----------------------------------------------------------- referans ----
  yerler: () => istek<YerlerYaniti>('/api/referans/yerler'),

  // ------------------------------------------------------------ aksiyon ----
  aksiyonlar: (ekran: string, kayitId?: number) =>
    istek<AksiyonListesi>(`/api/aksiyon/${ekran}` + (kayitId ? `?kayitId=${kayitId}` : '')),

};
