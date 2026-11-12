import { c } from '../../dil/ceviri';
import type { EkSekmeBaglami } from '../GenForm';
import { ayarYazici, jsonOku, metin, TEST_SKRS, TEST_TESIS } from './kartAyar';

/**
 * ENTEGRASYON HESABI › e-NABIZ › KURUM KİMLİĞİ (1321, kullanıcı: "her yerde geçerli ana ayarlar enabız ayarları olsun..
 * çünkü tüm hbys kullanan yerler enabız kullanmak zorunda ama medula ya da teleradyoloji kullanmak zorunda değil").
 * Kurumun Bakanlık kimliğinin ANA yeri: SKRS kurum kodu (kurum_kodu), MEDULA tesis kodu ve Bakanlık'ta görünen ad
 * (ayarlar). Şube başına satır (şube boş = kurum geneli). TeleRadyoloji (ORC-21, KOS, doz), MEDULA ve Teleradyoloji teslimi
 * buradan okur. CSS öneki `ekk-`.
 */
export function EnabizKimlikSekmesi({ e }: { e: EkSekmeBaglami }) {
  const d = e.deger;
  const ay = jsonOku(d.ayarlar);
  const salt = e.saltOkunur;
  const ayarYaz = ayarYazici(e);
  const skrs = metin(d.kurumKodu), tesis = metin(ay.medulaTesisKodu);
  return (
    <div className="ekk">
      <style>{EKK_STIL}</style>
      <fieldset className="ekk-grp">
        <legend>{c('Kurum kimliği')} <small>{c('her yerde geçerli - şube satırı → kurum geneli')}</small></legend>
        <div className="ekk-izgara">
          <label className="ekk-alan"><span className="ekk-zor">{c('SKRS kurum kodu')}</span>
            <input value={skrs} disabled={salt} placeholder="ör. 148" onChange={ev => e.alanYaz('kurumKodu', ev.target.value.trim())} />
            <small className={skrs === TEST_SKRS ? 'ekk-sari' : ''}>{skrs === TEST_SKRS ? c('TEST değeri') : c('e-Nabız, TeleRadyoloji (ORC-21 / KOS), Teleradyoloji teslimi')}</small></label>
          <label className="ekk-alan"><span>{c('MEDULA tesis kodu')}</span>
            <input value={tesis} disabled={salt} placeholder="11xxxxxx" onChange={ev => ayarYaz('medulaTesisKodu', ev.target.value.trim())} />
            <small className={tesis === TEST_TESIS ? 'ekk-sari' : tesis && !/^\d{8}$/.test(tesis) ? 'ekk-kirmizi' : ''}>
              {tesis === TEST_TESIS ? c('TEST değeri') : tesis && !/^\d{8}$/.test(tesis) ? c('8 haneli sayı olmalı') : c('MEDULA, TeleRadyoloji ORC-21')}</small></label>
          <label className="ekk-alan ekk-genis"><span>{c("Bakanlık'ta görünen ad")}</span>
            <input value={metin(ay.bakanlikAd)} disabled={salt} placeholder={c('boş = şube unvanı')} onChange={ev => ayarYaz('bakanlikAd', ev.target.value)} />
            <small>{c('TeleRadyoloji ORC-21 kurum adı, KOS InstitutionName')}</small></label>
        </div>
      </fieldset>
      <div className="ekk-not">
        <b>{c('Neden burada:')}</b> {c('her HBYS e-Nabız kullanmak zorunda; MEDULA ve TeleRadyoloji isteğe bağlı. Bu yüzden kimlik e-Nabız hesabında tutulur, ötekiler buradan okur. Şubesi ayrı tesis olan kurumda o şubeye ayrı e-Nabız satırı açılır. e-Nabız hesabı olmayan kurulumda kurum profili / eski ayar kullanılır.')}
      </div>
    </div>
  );
}

const EKK_STIL = `
.ekk{padding:10px 12px;display:flex;flex-direction:column;gap:10px;font-size:12px}
.ekk .ekk-grp{border:1px solid #e3e9f0;border-radius:4px;background:#fbfcfd;margin:0;padding:8px 10px 10px}
.ekk .ekk-grp legend{font-weight:bold;color:#2c4a6b;padding:0 4px}
.ekk .ekk-grp legend small{font-weight:normal;color:#2f6db3;margin-left:6px}
.ekk .ekk-izgara{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:9px 12px}
@media (max-width:900px){.ekk .ekk-izgara{grid-template-columns:repeat(2,minmax(0,1fr))}}
.ekk .ekk-alan{display:flex;flex-direction:column;gap:3px}
.ekk .ekk-alan>span{font-size:10.5px;color:#6b7a8b}
.ekk .ekk-zor::after{content:" *";color:#b23b3b}
.ekk .ekk-alan input{height:26px;border:1px solid #cdd6e0;border-radius:2px;padding:0 7px;font-size:12px;background:#fff}
.ekk .ekk-alan small{font-size:10px;color:#6b7a8b}
.ekk .ekk-genis{grid-column:span 2}
.ekk .ekk-sari{color:#9a5b00 !important}
.ekk .ekk-kirmizi{color:#9d3434 !important}
.ekk .ekk-not{font-size:11px;color:#6b7a8b;background:#fff;border:1px solid #e3e9f0;border-radius:3px;padding:6px 9px;line-height:1.5}
`;
