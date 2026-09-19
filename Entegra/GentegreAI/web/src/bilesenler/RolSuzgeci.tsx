import { useMemo } from 'react';

/**
 * ROL SÜZGECİ — KADRO AĞACI GÖRÜNÜMÜ (846, kullanıcı: "personel listesinde
 * filtreleme için roller combosu da ağaç şeklinde olsun").
 *
 * Düz alfabetik listede 70+ rol arasından "Başhekim Yardımcısı"nı bulmak
 * zordu; roller kadro ağacında duruyor (Kurum Profili > Roller ekranındaki
 * ağacın aynısı): bölüm başlığı `optgroup`, rolün üstüne bağlılığı girinti.
 *
 * Hiyerarşi GÖRÜNÜMDÜR, yetki değil - bu yüzden süzme yine TEK role bakar:
 * "Başhekim" seçen kullanıcı başhekim yardımcılarını istemiyordur. Bölüm
 * süzgecinde alt dallar dâhil edilir çünkü orada soru "hangi birimde".
 */
export type SuzgecRolu = {
  id: number; kod: string; ad: string;
  /** Kadro bölümü (ör. "Yönetim") - `optgroup` başlığı. */
  bolum: string;
  /** Üst rolün KODU; ağaçta girintiyi bu belirler. */
  ust?: string | null;
  sira: number;
};

/** Bölüm içinde ağaç sırası: kökler sıra/ad, altları hemen ardından girintili. */
function bolumAgaci(roller: SuzgecRolu[]) {
  const kodlar = new Set(roller.map(r => r.kod));
  const cocuk = new Map<string, SuzgecRolu[]>();
  const kokler: SuzgecRolu[] = [];
  roller.forEach(r => {
    // Üstü BAŞKA bölümdeyse (ya da hiç kurulu değilse) bu bölümde KÖK sayılır -
    //   yoksa dal asılı kalır ve rol comboda hiç görünmez.
    const ust = r.ust && kodlar.has(r.ust) ? r.ust : null;
    if (ust) cocuk.set(ust, [...(cocuk.get(ust) ?? []), r]);
    else kokler.push(r);
  });
  const sirala = (l: SuzgecRolu[]) =>
    l.sort((a, b) => (a.sira - b.sira) || a.ad.localeCompare(b.ad, 'tr'));
  sirala(kokler); cocuk.forEach(sirala);

  const sonuc: { id: number; etiket: string }[] = [];
  const gez = (r: SuzgecRolu, derinlik: number) => {
    sonuc.push({
      id: r.id,
      etiket: `${'  '.repeat(derinlik)}${derinlik > 0 ? '└ ' : ''}${r.ad}`,
    });
    (cocuk.get(r.kod) ?? []).forEach(c => gez(c, derinlik + 1));
  };
  kokler.forEach(r => gez(r, 0));
  return sonuc;
}

export function RolSuzgeci({ roller, bolumler, deger, onDegis }: {
  roller: SuzgecRolu[];
  /** Bölüm sırası (sunucudan) - listede olmayan bölümler sona alfabetik. */
  bolumler: string[];
  deger: number | '';
  onDegis(id: number | ''): void;
}) {
  const gruplar = useMemo(() => {
    const harita = new Map<string, SuzgecRolu[]>();
    roller.forEach(r => {
      const b = r.bolum || 'Diğer';
      harita.set(b, [...(harita.get(b) ?? []), r]);
    });
    const sirali = [...harita.keys()].sort((a, b) => {
      const ia = bolumler.indexOf(a), ib = bolumler.indexOf(b);
      if (ia !== ib) return (ia < 0 ? 999 : ia) - (ib < 0 ? 999 : ib);
      return a.localeCompare(b, 'tr');
    });
    return sirali.map(b => ({ bolum: b, secenekler: bolumAgaci(harita.get(b) ?? []) }));
  }, [roller, bolumler]);

  return (
    <select className="kat-suzgec" value={deger}
            title="Kullanıcı rolüne göre süz (kadro ağacı)"
            onChange={e => onDegis(e.target.value ? Number(e.target.value) : '')}>
      <option value="">Tüm Roller</option>
      {gruplar.map(g => (
        <optgroup key={g.bolum} label={g.bolum}>
          {g.secenekler.map(s => <option key={s.id} value={s.id}>{s.etiket}</option>)}
        </optgroup>
      ))}
    </select>
  );
}
