import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { guvenli } from '../../bilesenler/mesaj';
import type { Kosul } from '../../api/sozlesme';
import type { SuzgecRolu } from '../../bilesenler/RolSuzgeci';
import { useOturum } from '../../kimlik/OturumBaglami';
import { gostergeKosulu, type GostergeKodu } from './personelGosterge';

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
  // GÖSTERGE ŞERİDİ (963): seçili kutu (bugün izinde, raporlu...) - listeye AND'lenir.
  const [gosterge, setGosterge] = useState<GostergeKodu | null>(null);
  const [roller, setRoller] = useState<SuzgecRolu[]>([]);
  const [rolBolumleri, setRolBolumleri] = useState<string[]>([]);
  // SISTEMDE KAYITLI PERSONELDE GEÇEN bölümler (kullanıcı): bölüm ağacı yalnız
  //   personeli olan dallarla sınırlanır.
  const [bolumIzinli, setBolumIzinli] = useState<number[] | undefined>(undefined);
  const { yetki } = useOturum();
  // Rol listesi `rol` yetkisi ister; yetkisi olmayanda combo hic cizilmez -
  //   403 alip bos combo gostermektense sormuyoruz.
  const rolSuzgeciVar = !!rolSuzgeci && yetki('rol');

  // BÖLÜM + ROL COMBOLARI KAYITLI PERSONELDEN (kullanıcı: "sistemde kayıtlı
  //   personel listesinden getir"): personel listesinden GEÇEN bölüm ve roller
  //   toplanır - kullanılmayan tanımlar combolarda çıkmaz. Sayfalamayı aşmak
  //   için tek büyük sayfa çekilir (personel sayısı mütevazı).
  useEffect(() => {
    if (!bolumSuzgeci && !rolSuzgeciVar) { setRoller([]); setRolBolumleri([]); setBolumIzinli(undefined); return }
    void guvenli(async () => {
      const y = await api.liste(kaynak, { sayfa: 1, boyut: 1000 });
      const bolumSet = new Set<number>();
      const rolMap = new Map<number, string>();
      for (const r of y.satirlar) {
        const bid = Number(r.departmanId ?? 0);
        if (bid > 0) bolumSet.add(bid);
        const rid = Number(r.rolId ?? 0);
        if (rid > 0 && !rolMap.has(rid)) rolMap.set(rid, String(r.rolAdi ?? '').trim() || `Rol ${rid}`);
      }
      setBolumIzinli(bolumSuzgeci ? [...bolumSet] : undefined);
      if (rolSuzgeciVar) {
        setRoller([...rolMap.entries()]
          .map(([id, ad]) => ({ id, kod: '', ad, bolum: 'Diğer', ust: null, sira: 0 }))
          .sort((a, b) => a.ad.localeCompare(b.ad, 'tr')));
        setRolBolumleri([]);
      } else { setRoller([]); setRolBolumleri([]) }
    });
  }, [bolumSuzgeci, rolSuzgeciVar, kaynak]);
  // Liste degisince secimler sifirlanir: yeni kaynakta o alanlar yok.
  useEffect(() => { setBolum(null); setRol(''); setGosterge(null) }, [kaynak]);

  /** Bolum/rol secimleri de sabit filtreye AND'lenir (cip ve arama ile birlikte). */
  const filtre = useCallback((temel: Kosul | undefined): Kosul | undefined => {
    if (!bolumSuzgeci && !rolSuzgeci) return temel;   // bkz. useBasvuruSuzgeci.filtre
    const kosullar: Kosul[] = [];
    if (temel) kosullar.push(temel);
    // Bolum: secilen dal + TUM ALT BIRIMLERI. -1 = "Bölümsüz" (963, ağaç).
    if (bolum?.id === -1)
      kosullar.push({ alan: 'departmanId', op: 'bos', deger: null });
    else if (bolum && bolum.agac.length > 0)
      kosullar.push({ alan: 'departmanId', op: 'icinde', deger: bolum.agac });
    if (gosterge) kosullar.push(gostergeKosulu(gosterge));
    if (rol !== '')
      kosullar.push({ alan: 'rolId', op: 'esit', deger: rol });
    return kosullar.length === 0 ? undefined
         : kosullar.length === 1 ? kosullar[0]
         : { op: 'and', kosullar };
  }, [bolumSuzgeci, rolSuzgeci, bolum, rol, gosterge]);

  return { bolum, setBolum, rol, setRol, gosterge, setGosterge, roller, rolBolumleri, rolSuzgeciVar, bolumIzinli, filtre };
}

export type PersonelSuzgeci = ReturnType<typeof usePersonelSuzgeci>;
