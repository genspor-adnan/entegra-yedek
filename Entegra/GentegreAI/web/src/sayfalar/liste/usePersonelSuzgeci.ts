import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { guvenli } from '../../bilesenler/mesaj';
import type { Kosul } from '../../api/sozlesme';
import type { SuzgecRolu } from '../../bilesenler/RolSuzgeci';
import { useOturum } from '../../kimlik/OturumBaglami';

/**
 * PERSONEL SERIT SUZGECLERI (kullanici: "aktif/pasif/durum saginda Bolum agac
 * combo ve Rol combo"). Randevununkinden AYRI durum: o ekranda secim takvimi de
 * suruyor, buradaki yalniz gridi suzer.
 */
export function usePersonelSuzgeci(
  bolumSuzgeci: boolean | undefined,
  rolSuzgeci: boolean | undefined,
  kaynak: string,
) {
  const [bolum, setBolum] = useState<{ id: number; agac: number[] } | null>(null);
  const [rol, setRol] = useState<number | ''>('');
  const [roller, setRoller] = useState<SuzgecRolu[]>([]);
  const [rolBolumleri, setRolBolumleri] = useState<string[]>([]);
  const { yetki } = useOturum();
  // Rol listesi `rol` yetkisi ister; yetkisi olmayanda combo hic cizilmez -
  //   403 alip bos combo gostermektense sormuyoruz.
  const rolSuzgeciVar = !!rolSuzgeci && yetki('rol');

  // ROL LISTESI KADRO BILGISIYLE (846): combo agac cizebilsin diye roller
  //   `profil-rolleri` ucundan alinir - dogrudan `rol` listesinde bolum/ust
  //   kolonu yok (hiyerarsi sablon haritasinda, SablonKadro). Ayni yetkiyi
  //   ("rol" gor) istedigi icin ek bir kapi acmiyor.
  useEffect(() => {
    if (!rolSuzgeciVar) { setRoller([]); setRolBolumleri([]); return }
    void guvenli(async () => {
      const y = await api.profilRolleri();
      setRoller((y.roller ?? [])
        .filter(r => r.aktif)
        .map(r => ({ id: r.id, kod: r.kod, ad: r.ad,
                     bolum: r.bolum || 'Diğer', ust: r.ust ?? null,
                     sira: r.sira ?? 0 })));
      setRolBolumleri(y.bolumler ?? []);
    });
  }, [rolSuzgeciVar]);
  // Liste degisince secimler sifirlanir: yeni kaynakta o alanlar yok.
  useEffect(() => { setBolum(null); setRol('') }, [kaynak]);

  /** Bolum/rol secimleri de sabit filtreye AND'lenir (cip ve arama ile birlikte). */
  const filtre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (!bolumSuzgeci && !rolSuzgeci) return temel;   // bkz. useBasvuruSuzgeci.filtre
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    // Bolum: secilen dal + TUM ALT BIRIMLERI.
    if (bolum && bolum.agac.length > 0)
      kosullar.push({ alan: 'departmanId', op: 'icinde', deger: bolum.agac });
    if (rol !== '')
      kosullar.push({ alan: 'rolId', op: 'esit', deger: rol });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [bolumSuzgeci, rolSuzgeci, bolum, rol]);

  return { bolum, setBolum, rol, setRol, roller, rolBolumleri, rolSuzgeciVar, filtre };
}

export type PersonelSuzgeci = ReturnType<typeof usePersonelSuzgeci>;
