import { useMemo } from 'react';

interface Ulke { kod: string; bayrak: string; dial: string; ad: string }

/** Kisa liste - Turkiye varsayilan, gerisi en sik gorulen kaynak/musteri ulkeleri. */
const ULKELER: Ulke[] = [
  { kod: 'TR', bayrak: '🇹🇷', dial: '90', ad: 'Türkiye' },
  { kod: 'DE', bayrak: '🇩🇪', dial: '49', ad: 'Almanya' },
  { kod: 'US', bayrak: '🇺🇸', dial: '1', ad: 'ABD' },
  { kod: 'GB', bayrak: '🇬🇧', dial: '44', ad: 'İngiltere' },
  { kod: 'FR', bayrak: '🇫🇷', dial: '33', ad: 'Fransa' },
  { kod: 'NL', bayrak: '🇳🇱', dial: '31', ad: 'Hollanda' },
  { kod: 'AZ', bayrak: '🇦🇿', dial: '994', ad: 'Azerbaycan' },
  { kod: 'RU', bayrak: '🇷🇺', dial: '7', ad: 'Rusya' },
  { kod: 'AE', bayrak: '🇦🇪', dial: '971', ad: 'BAE' },
  { kod: 'SA', bayrak: '🇸🇦', dial: '966', ad: 'Suudi Arabistan' },
];
const VARSAYILAN = ULKELER[0];
const DIAL_UZUNLUGA_GORE = [...ULKELER].sort((a, b) => b.dial.length - a.dial.length);

function coz(deger: string): { ulke: Ulke; yerel: string } {
  const v = deger.trim();
  if (v.startsWith('+')) {
    const rakam = v.slice(1).replace(/\D/g, '');
    const eslesen = DIAL_UZUNLUGA_GORE.find(u => rakam.startsWith(u.dial));
    if (eslesen) return { ulke: eslesen, yerel: rakam.slice(eslesen.dial.length) };
  }
  // "+" ile baslamayan eski veri (ör. "0532 418 77 20") - Turkiye varsayilir, oldugu gibi kalir.
  return { ulke: VARSAYILAN, yerel: v };
}

/** Turkiye icin "5324187720" -> "532 418 77 20". Diger ulkelerde gruplama yapilmaz (format cok cesitli). */
function yerelFormatla(ulke: Ulke, yerel: string): string {
  if (ulke.kod !== 'TR') return yerel.replace(/[^\d ]/g, '');
  const rakam = yerel.replace(/\D/g, '');
  const on = rakam.length === 10 ? rakam : rakam.startsWith('0') ? rakam.slice(1) : rakam;
  if (on.length !== 10) return yerel;
  return `${on.slice(0, 3)} ${on.slice(3, 6)} ${on.slice(6, 8)} ${on.slice(8, 10)}`;
}

const birlestir = (ulke: Ulke, yerel: string): string => {
  const temiz = yerel.trim();
  return temiz ? `+${ulke.dial} ${temiz}` : '';
};

/**
 * Ulke bayragi + kod secimi (varsayilan Turkiye) + yerel numara kutusu. Deger her zaman
 * "+90 532 418 77 20" seklinde tek string olarak disari verilir/alinir - ayri kolon YOK.
 * Yerel kisim SADECE BLUR'DA gruplaniyor (yazarken imlec atlamasin diye).
 */
export function TelefonGirdi({ value, onChange, onBlurSonrasi, disabled }: {
  value: string;
  onChange(v: string): void;
  onBlurSonrasi?(v: string): void;
  disabled?: boolean;
}) {
  const { ulke, yerel } = useMemo(() => coz(value), [value]);
  // Kutuda da GRUPLU gorunur (genel kural: telefon her yerde ayni bicimde).
  //   Yazarken imlec atlamasin diye gruplama BLUR'da yapiliyordu; acilista da
  //   gruplu gostermek icin gorunum degeri burada bicimlenir - kullanici
  //   yazmaya baslayinca kendi yazdigi kalir (deger degismedigi surece).
  const gorunen = useMemo(() => yerelFormatla(ulke, yerel), [ulke, yerel]);

  return (
    <div className="tel-girdi">
      <select
        value={ulke.kod}
        disabled={disabled}
        onChange={e => {
          const yeniUlke = ULKELER.find(u => u.kod === e.target.value) ?? VARSAYILAN;
          onChange(birlestir(yeniUlke, yerel));
        }}
      >
        {ULKELER.map(u => <option key={u.kod} value={u.kod}>{u.bayrak} +{u.dial}</option>)}
      </select>
      <input
        type="tel"
        value={gorunen}
        disabled={disabled}
        onChange={e => {
          // TR icin sadece rakam (+bosluk, gruplamayi bozma) - harf/sembol yazilamasin.
          const girilen = ulke.kod === 'TR' ? e.target.value.replace(/[^\d ]/g, '') : e.target.value;
          onChange(birlestir(ulke, girilen));
        }}
        onBlur={e => {
          const bicimli = birlestir(ulke, yerelFormatla(ulke, e.target.value));
          onChange(bicimli);
          onBlurSonrasi?.(bicimli);
        }}
      />
    </div>
  );
}
