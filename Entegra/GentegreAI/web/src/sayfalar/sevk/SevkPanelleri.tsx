import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';

/**
 * SEVK LİSTESİ PANELLERİ (1110) - mockup Ekranlar/Muayene/sevk_listesi_v2.html (sade):
 * iki sekme (Giden · Gelen) ve tek satırlık ön izleme. Özet kutuları bilerek yok.
 *   Giden: sevki ben yaptım ya da bölümümden çıktı.
 *   Gelen: kurum içi / yatış sevki ve hedef bölüm benim bölümlerimden.
 */
export type SevkSekme = 'giden' | 'gelen';

export function useSevkSuzgeci(aktif: boolean) {
  const [sekme, setSekme] = useState<SevkSekme>('giden');
  const [kapsam, setKapsam] = useState<{ ben: number; bolumler: number[] } | null>(null);
  useEffect(() => {
    if (!aktif) return;
    let iptal = false;
    api.sevkKapsam().then(y => { if (!iptal) setKapsam(y) }).catch(() => { if (!iptal) setKapsam(null) });
    return () => { iptal = true };
  }, [aktif]);

  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    // Kullanıcı / bölüm gelene kadar boş liste (başkasının listesi bir an bile görünmesin).
    if (!kapsam) l.push({ alan: 'id', op: 'esit', deger: -1 });
    // BÖLÜMÜ OLMAYAN kullanıcı (yönetici, kayıt) şubenin bütün sevklerini görür; hekim kendi /
    //   bölümünün sevklerini.
    else if (sekme === 'gelen') {
      l.push({ alan: 'tur', op: 'icinde', deger: [2, 3] });
      if (kapsam.bolumler.length) l.push({ alan: 'hedefBolumId', op: 'icinde', deger: kapsam.bolumler });
    }
    else if (kapsam.bolumler.length)
      l.push({ op: 'or', kosullar: [{ alan: 'hekimId', op: 'esit', deger: kapsam.ben }, { alan: 'bolumId', op: 'icinde', deger: kapsam.bolumler }] });
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { sekme, setSekme, filtre };
}
export type SevkSuzgeci = ReturnType<typeof useSevkSuzgeci>;

export function SevkUstPanel({ s }: { s: SevkSuzgeci }) {
  return (
    <div className="kns-ust">
      <div className="kns-sekmeler">
        {([['giden', '📤 Giden'], ['gelen', '📥 Gelen']] as const).map(([k, ad]) => (
          <button key={k} type="button" className={s.sekme === k ? 'on' : ''} onClick={() => s.setSekme(k)}>{c(ad)}</button>
        ))}
      </div>
    </div>
  );
}

/** Tek satırlık ön izleme: seçili sevkin nereye / ulaşım / Medula no ve notu. */
export function SevkOnizlemePaneli({ satir, onAc }: { satir: ListeSatiri | null; onAc(id: number): void }) {
  if (!satir) return <div className="svk-onizleme bos">{c('Ön izleme için bir sevk seçin.')}</div>;
  const m = (v: unknown) => String(v ?? '').trim();
  return (
    <div className="svk-onizleme">
      <small>
        {c('SEÇİLİ')} · {m(satir.hastaAdi)} · {m(satir.nereye) || '—'} · {m(satir.ulasimAdi)}
        {m(satir.medulaSevkNo) && ` · Medula ${m(satir.medulaSevkNo)}`}
        <button type="button" className="d" style={{ marginLeft: 8 }} onClick={() => onAc(Number(satir.id))}>{c('Kartı aç')}</button>
      </small>
      {m(satir.notu) || '—'}
    </div>
  );
}
