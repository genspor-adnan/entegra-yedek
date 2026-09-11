import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { guvenli } from '../../bilesenler/mesaj';
import type { Kosul } from '../../api/sozlesme';
import type { SecenekSayili } from './useBasvuruSuzgeci';

/**
 * HAKEDIS SATIRLARI SERIT SUZGECLERI (kullanici: "tarihin sagina Prim Rolu
 * combo ve onun da sagina Kisi filtre"). Kisi listesi SECILI ROLE gore daralir -
 * "Raporlayan" secildiginde raporlamayan kisiyi listelemek, secilince bos grid
 * vermekten baska ise yaramaz.
 */
export function usePrimSuzgeci(aktif: boolean | undefined, kaynak: string) {
  const [rol, setRol] = useState<number | ''>('');
  const [kisi, setKisi] = useState<number | ''>('');
  const [roller, setRoller] = useState<SecenekSayili[]>([]);
  const [kisiler, setKisiler] = useState<SecenekSayili[]>([]);
  /** Griddeki tarih araligi (GenGrid bildirir) - secenekler buna gore uretilir. */
  const [aralik, setAralik] = useState<{ bas: string; bit: string }>({ bas: '', bit: '' });

  const araligiBildir = useCallback((bas: string, bit: string) => {
    setAralik(o => (o.bas === bas && o.bit === bit ? o : { bas, bit }));
  }, []);

  // Secenekler ARALIKTAKI SATIRLARDAN gelir (kullanici: "tum kisiler ve tum
  //   roller listesine o tarihler arasinda olanlar gelsin") - rol/aday
  //   tanimlarindan degil. Boylece combo'da secilince bos grid veren secenek
  //   olmaz. Kisi listesi ayrica secili role gore daralir.
  useEffect(() => {
    if (!aktif) return;
    void guvenli(async () => {
      const y = await api.hakedisSuzgecSecenekleri(
        aralik.bas || undefined, aralik.bit || undefined,
        rol === '' ? undefined : rol);
      setRoller(y.roller ?? []);
      setKisiler(y.kisiler ?? []);
    });
  }, [aktif, aralik.bas, aralik.bit, rol]);
  // Aralik/rol degisince secim listede kalmayabilir: filtre sessizce bos grid
  //   verirdi - secimi birakmak yerine temizliyoruz.
  useEffect(() => {
    if (kisi !== '' && kisiler.length > 0 && !kisiler.some(k => k.id === kisi))
      setKisi('');
  }, [kisiler, kisi]);
  useEffect(() => {
    if (rol !== '' && roller.length > 0 && !roller.some(r => r.id === rol))
      setRol('');
  }, [roller, rol]);
  useEffect(() => { setRol(''); setKisi('') }, [kaynak]);

  /** Prim rolu / kisi secimi de sabit filtreye AND'lenir. */
  const filtre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;          // bkz. useBasvuruSuzgeci.filtre
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    if (rol !== '') kosullar.push({ alan: 'rol', op: 'esit', deger: rol });
    if (kisi !== '') kosullar.push({ alan: 'tarafId', op: 'esit', deger: kisi });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [aktif, rol, kisi]);

  return { rol, setRol, kisi, setKisi, roller, kisiler, araligiBildir, filtre };
}

export type PrimSuzgeci = ReturnType<typeof usePrimSuzgeci>;
