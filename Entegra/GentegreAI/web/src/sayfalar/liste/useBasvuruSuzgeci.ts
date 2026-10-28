import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { guvenli } from '../../bilesenler/mesaj';
import type { Kosul } from '../../api/sozlesme';

/** Serit combolarinin secenekleri: ad + o aralikta kac kayit var. */
export interface SecenekSayili { id: number; ad: string; adet: number }

/**
 * BASVURU SERIT SUZGECLERI (kullanici): hazir tarih araligi, Tamamlanma,
 * Tahsilat, Donusum, Odeyen kurum, Bolum agaci ve Doktor. Hepsi SUNUCUDA suzer
 * ve sabit filtreye AND'lenir.
 *
 * TARIH bu kancada DEGIL (28.10.2026): grid'in standart tarih kutulari
 * (tanim `tarihAlani` + `tarihVarsayilan: 'bugun'`) suzer; kanca yalniz
 * araligi `araligiBildir` ile ogrenir - secenek combolari o araliktan dolar.
 *
 * Durum `Liste` bileseninde degil BURADA yasar; ekran degisince sifirlanir.
 */
export function useBasvuruSuzgeci(aktif: boolean | undefined, kaynak: string) {
  // Grid'in tarih kutularindaki aralik (bos = sinirsiz). Acilista bugun-bugun gelir.
  const [aralik, setAralik] = useState<{ bas: string; bit: string } | null>(null);
  const araligiBildir = useCallback((bas: string, bit: string) => {
    setAralik(o => (o?.bas === bas && o?.bit === bit) ? o : (bas || bit ? { bas, bit } : null));
  }, []);
  const [odeyen, setOdeyen] = useState<number | ''>('');
  const [bolum, setBolum] = useState<{ id: number; agac: number[] } | null>(null);
  const [doktor, setDoktor] = useState<number | ''>('');
  // CIPLERIN YERINE UC COMBO (kullanici): Tamamlanma, Tahsilat, Donusum.
  //   Donusum'un secenekleri eski ciplerin ta kendisi (kapanma_durum).
  const [tamamlanma, setTamamlanma] = useState<'' | 'tamam' | 'devam'>('');
  const [tahsilat, setTahsilat] = useState<'' | '0' | '1' | '2'>('');
  const [donusum, setDonusum] = useState<'' | '0' | '1' | '2'>('');
  const [kurumlar, setKurumlar] = useState<SecenekSayili[]>([]);
  const [bolumler, setBolumler] = useState<SecenekSayili[]>([]);
  const [doktorlar, setDoktorlar] = useState<SecenekSayili[]>([]);

  // Secenekler ARALIKTAKI BASVURULARDAN gelir (kullanici: "bu filtrelere o
  //   tarih araligindaki yer alan item'lar gelsin") - tanim tablolarindan
  //   degil. Tarih secimi degisince listeler yenilenir.
  useEffect(() => {
    if (!aktif) return;
    void guvenli(async () => {
      const y = await api.basvuruSuzgecSecenekleri(aralik?.bas || undefined, aralik?.bit || undefined);
      setKurumlar(y.odeyenler ?? []);
      setBolumler(y.bolumler ?? []);
      setDoktorlar(y.doktorlar ?? []);
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [aktif, aralik?.bas, aralik?.bit]);
  // Aralik degisince listede kalmayan secim temizlenir: filtre sessizce bos
  //   liste verirdi.
  useEffect(() => {
    if (odeyen !== '' && kurumlar.length > 0 && !kurumlar.some(k => k.id === odeyen))
      setOdeyen('');
  }, [kurumlar, odeyen]);
  useEffect(() => {
    if (doktor !== '' && doktorlar.length > 0 && !doktorlar.some(d => d.id === doktor))
      setDoktor('');
  }, [doktorlar, doktor]);

  const sifirla = useCallback(() => {
    setOdeyen(''); setBolum(null); setDoktor('');
    setTamamlanma(''); setTahsilat(''); setDonusum('');
  }, []);
  // Liste degisince secimler sifirlanir: yeni kaynakta o alanlar yok.
  useEffect(() => { sifirla() }, [kaynak, sifirla]);

  const filtre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    // SUZGEC KAPALI EKRANDA HIC KOSUL EKLENMEZ: durumlar bilesen agacinda
    //   yasadigi icin baska bir listeye gecildiginde de doluydu ve tarih
    //   varsayilani 'bugun' oldugu icin KOSUL HEP VARDI - hasta listesi
    //   "Bilinmeyen alan: belgeTarihi" ile 400 donuyordu.
    if (!aktif) return temel;
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    if (odeyen !== '') kosullar.push({ alan: 'odeyenKurumId', op: 'esit', deger: odeyen });
    // Bolum: secilen dal + TUM ALT BIRIMLERI (agac combosu).
    if (bolum && bolum.agac.length > 0)
      kosullar.push({ alan: 'bolumId', op: 'icinde', deger: bolum.agac });
    if (doktor !== '') kosullar.push({ alan: 'doktorId', op: 'esit', deger: doktor });
    // Tamamlanma: %100 tamamlandi ya da altindaki her sey "devam ediyor".
    if (tamamlanma === 'tamam')
      kosullar.push({ alan: 'tamamlanma', op: 'esit', deger: 100 });
    if (tamamlanma === 'devam')
      kosullar.push({ alan: 'tamamlanma', op: 'kucuk', deger: 100 });
    if (tahsilat !== '')
      kosullar.push({ alan: 'tahsilatDurum', op: 'esit', deger: Number(tahsilat) });
    if (donusum !== '')
      kosullar.push({ alan: 'kapanmaDurum', op: 'esit', deger: Number(donusum) });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [aktif, odeyen, bolum, doktor, tamamlanma, tahsilat, donusum]);

  /** Varsayilandan (hepsi) sapan bir secim var mi - "×" dugmesi icin. Tarih grid'in kutularinda. */
  const secimVar = odeyen !== '' || bolum !== null || doktor !== ''
    || tamamlanma !== '' || tahsilat !== '' || donusum !== '';

  return { aralik, araligiBildir, odeyen, setOdeyen, bolum, setBolum, doktor, setDoktor,
           tamamlanma, setTamamlanma, tahsilat, setTahsilat, donusum, setDonusum,
           kurumlar, bolumler, doktorlar, filtre, sifirla, secimVar };
}

export type BasvuruSuzgeci = ReturnType<typeof useBasvuruSuzgeci>;
