import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { tarihSaat } from './bicim';

/**
 * MUAYENE › VİTAL BULGULAR PANELİ (461) — mockup
 * `Ekranlar/Muayene/muayene_karti.html` sağ sütunundaki "Vital bulgular"
 * ızgarası.
 *
 * <b>Neden ızgara, neden anamnezin yanında:</b> mockup vitali ayrı bir sekmeye
 * koymuyor; hekim şikâyeti yazarken tansiyonu ve ateşi aynı ekranda görüyor.
 * Kartın "Vital Bulgular" sekmesi (ölçüm geçmişi, düzenleme) duruyor - burası
 * SON ÖLÇÜMÜN okunur özeti.
 *
 * <b>Sınır işareti sunucudan gelen değerle hesaplanmaz mı?</b> Hayır - burada
 * eşik yok, yalnız değerin kendisi çizilir. "Yüksek/panik" kararı laboratuvar
 * ve klinik kural işidir; ekranda uydurulan bir sınır, hekimi yanlış yönlendirir.
 */

type Satir = Record<string, unknown>;

const sayi = (v: unknown) => (v === null || v === undefined || v === '' ? null : Number(v));

const KAYNAK: Record<number, string> = {
  1: 'hemşire girişi', 2: 'hekim', 3: 'cihazdan', 4: 'hasta beyanı',
};

/** Değer + birim; değer yoksa "—" (boş kutu ölçülmedi mi belli olmalı). */
function Kutu({ etiket, deger, birim, ek }:
  { etiket: string; deger: unknown; birim?: string; ek?: React.ReactNode }) {
  const d = sayi(deger);
  return (
    <div className="vt-kutu">
      <div className="vt-etiket">{etiket}</div>
      <div className="vt-deger">
        {d === null ? <span className="sonuk">—</span>
          : <>{d.toLocaleString('tr-TR', { maximumFractionDigits: 1 })}
              {birim ? <span className="vt-birim"> {birim}</span> : null}</>}
        {ek}
      </div>
    </div>
  );
}

export function MuayeneVitalPaneli({ muayeneId }: { muayeneId: number }) {
  const [son, setSon] = useState<Satir | null>(null);
  const [adet, setAdet] = useState(0);
  const [yuklendi, setYuklendi] = useState(false);

  useEffect(() => {
    if (!(muayeneId > 0)) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kartOku('muayene', muayeneId);
        if (iptal) return;
        // Detay sunucuda "zaman desc" sirali: ilk satir SON olcum.
        const liste = (y.detaylar?.vitaller ?? []) as Satir[];
        setSon(liste[0] ?? null);
        setAdet(liste.length);
      } catch { /* panel zorunlu degil */ }
      finally { if (!iptal) setYuklendi(true) }
    })();
    return () => { iptal = true };
  }, [muayeneId]);

  if (!(muayeneId > 0)) return null;

  const sis = sayi(son?.sistolik);
  const diy = sayi(son?.diyastolik);
  const kaynak = KAYNAK[Number(son?.kaynak ?? 0)] ?? '';

  return (
    <div className="kagrup vital-panel">
      <h6>
        Vital bulgular
        <span className="sonuk">
          {son
            ? ` · ${tarihSaat(son.zaman)}${kaynak ? ' · ' + kaynak : ''}`
              + (adet > 1 ? ` · ${adet} ölçüm` : '')
            : yuklendi ? ' · ölçüm yok' : ' · …'}
        </span>
      </h6>

      <div className="vital-izgara">
        <div className="vt-kutu">
          <div className="vt-etiket">Tansiyon</div>
          <div className="vt-deger">
            {sis === null && diy === null
              ? <span className="sonuk">—</span>
              : <>{sis ?? '—'} / {diy ?? '—'}<span className="vt-birim"> mmHg</span></>}
          </div>
        </div>
        <Kutu etiket="Nabız" deger={son?.nabiz} birim="/dk" />
        <Kutu etiket="SpO₂" deger={son?.spo2} birim="%" />
        <Kutu etiket="Ateş" deger={son?.ates} birim="°C" />
        <Kutu etiket="Solunum" deger={son?.solunum} birim="/dk" />
        <Kutu etiket="Ağrı (VAS)" deger={son?.agriVas} birim="/10" />
        <div className="vt-kutu">
          <div className="vt-etiket">Boy / Kilo</div>
          <div className="vt-deger">
            {sayi(son?.boyCm) === null && sayi(son?.kiloKg) === null
              ? <span className="sonuk">—</span>
              : <>{sayi(son?.boyCm) ?? '—'} / {sayi(son?.kiloKg) ?? '—'}
                  <span className="vt-birim"> cm/kg</span></>}
          </div>
        </div>
        <Kutu etiket="BKİ" deger={son?.bki} />
        <Kutu etiket="Bel çevresi" deger={son?.belCevresiCm} birim="cm" />
        <Kutu etiket="Parmak glukoz" deger={son?.glukozParmak} birim="mg/dL" />
      </div>

      {yuklendi && !son && (
        <div className="not">
          Ölçüm girilmemiş — <b>Vital Bulgular</b> sekmesinden eklenir.
        </div>
      )}
    </div>
  );
}
