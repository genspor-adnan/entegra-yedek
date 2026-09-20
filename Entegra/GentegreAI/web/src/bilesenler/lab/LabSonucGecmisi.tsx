import { useCallback, useEffect, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import type { LabSonucGecmisVerisi } from '../../api/uclar/lab';
import { hataMetni } from '../../api/sozlesme';
import { bayrakSinifi } from '../labKodlari';
import { tarihSaat } from '../bicim';
import { c as cev } from '../../dil/ceviri';

/**
 * ONAYLARKEN GEÇMİŞ VE TEKRARLAR (886 — KTS denetim maddesi L9).
 *
 * Uzman bir sonucu onaylarken iki şeyi bilmek ister: bu hastanın aynı
 * tetkiki daha önce kaçtı, ve bu numunede tekrar çalışma yapıldı mı.
 * İkisi de vardı ama başka ekrandaydı; pencere onları sonucun yanına
 * getirir.
 *
 * <b>Geçmiş yalnız ONAYLI sonuçlardır.</b> Uzmanın kararını dayandıracağı
 * değer, kurumun sahiplendiği değerdir - onaysız bir ölçümü "önceki sonuç"
 * diye göstermek, henüz doğrulanmamış bir sayıyı karara sokardı.
 *
 * <b>Tekrar geçmiş değildir</b>: aynı numunenin ikinci okuması ayrı
 * listede durur ve onaysızı da görünür - tekrarın amacı zaten "hangisi
 * doğru" sorusunu uzmanın önüne koymaktır.
 *
 * <b>Delta sunucudan gelir</b> (sonuç yazılırken hesaplandı); ekran
 * yeniden hesaplamaz - iki yerde hesaplamak sessizce ayrışırdı.
 */
const DURUM: Record<number, string> = {
  1: 'Girildi', 2: 'Teknik onay', 3: 'Onaylı', 4: 'İptal', 5: 'Düzeltildi',
};

export function LabSonucGecmisi({ satirId, baslik, onKapat }: {
  satirId: number; baslik?: string; onKapat(): void;
}) {
  const [veri, setVeri] = useState<LabSonucGecmisVerisi | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.labSonucGecmis(satirId)); setHata(null) }
    catch (h) { setHata(hataMetni(h)) }
  }, [satirId]);
  useEffect(() => { void yukle() }, [yukle]);

  const d = veri?.delta;
  return (
    <Modal baslik={`📈 ${cev('Önceki sonuçlar ve tekrarlar')}${baslik ? ' · ' + baslik : ''}`}
           onKapat={onKapat}
           alt={<button type="button" className="d" onClick={onKapat}>{cev('Kapat')}</button>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!veri ? <div className="sonuk">{cev('Yükleniyor…')}</div> : (
        <>
          {/* DELTA: sonucun kendi satırındaki karşılaştırma. Kural kapalıysa
              (tetkikte delta yüzdesi 0) bunu da söylemek gerekir - "uyarı
              yok" ile "kural tanımlı değil" farklı şeyler. */}
          {d && (
            <div className={d.uyari ? 'uyari-kutusu' : 'ds-ic'}>
              <b>{cev('Bu sonuç')}:</b> {d.deger} {d.birim}
              {d.bayrak && d.bayrak !== 'N' && (
                <span className={bayrakSinifi(d.bayrak)} style={{ marginLeft: 4 }}>{d.bayrak}</span>
              )}
              {d.panik && <span className="rozet hata" style={{ marginLeft: 4 }}>PANİK</span>}
              {' · '}
              {d.oncekiDeger == null
                ? <span className="sonuk">{cev('karşılaştırılacak önceki değer yok')}</span>
                : <>
                    {cev('önceki')}: <b>{d.oncekiDeger}</b>
                    {d.yuzde != null && <> · {cev('değişim')}: <b>%{d.yuzde}</b></>}
                    {d.uyari
                      ? <span className="rozet hata" style={{ marginLeft: 4 }}>
                          {cev('delta uyarısı')}
                        </span>
                      : null}
                  </>}
              {d.kuralYuzde > 0
                ? <span className="sonuk"> ({cev('kural')}: %{d.kuralYuzde}
                    {d.kuralGun > 0 ? ` · ${d.kuralGun} ${cev('gün')}` : ''})</span>
                : <span className="sonuk"> ({cev('bu tetkikte delta kuralı tanımlı değil')})</span>}
            </div>
          )}

          <div className="ds-gb" style={{ marginTop: 8 }}>
            {cev('Önceki onaylı sonuçlar')}
            <span className="ds-sp sonuk">{cev('aynı hasta · aynı tetkik · başka istemler')}</span>
          </div>
          <div className="ds-dg"><table>
            <thead><tr>
              <th className="orta">{cev('Tarih')}</th><th className="orta">{cev('İstem')}</th>
              <th className="sag">{cev('Değer')}</th><th>{cev('Birim')}</th>
              <th className="orta">{cev('Bayrak')}</th><th>{cev('Cihaz')}</th>
            </tr></thead>
            <tbody>
              {veri.gecmis.map(g => (
                <tr key={g.sonucId} className={g.panik ? 'panik' : undefined}>
                  <td className="orta">{tarihSaat(g.tarih)}</td>
                  <td className="orta sonuk">{g.istemNo}</td>
                  <td className="sag"><b>{g.deger}</b></td>
                  <td>{g.birim}</td>
                  <td className="orta">
                    {g.bayrak && g.bayrak !== 'N'
                      ? <span className={bayrakSinifi(g.bayrak)}>{g.bayrak}</span> : ''}
                  </td>
                  <td className="sonuk">{g.cihaz}</td>
                </tr>
              ))}
              {veri.gecmis.length === 0 && (
                <tr><td colSpan={6} className="sonuk">
                  {cev('Bu hastanın bu tetkikte önceki onaylı sonucu yok.')}
                </td></tr>
              )}
            </tbody>
          </table></div>

          <div className="ds-gb" style={{ marginTop: 8 }}>
            {cev('Bu istemdeki tekrarlar')}
            <span className="ds-sp sonuk">{cev('aynı numunenin öteki çalışmaları')}</span>
          </div>
          <div className="ds-dg"><table>
            <thead><tr>
              <th className="orta">{cev('Tekrar')}</th><th className="orta">{cev('Zaman')}</th>
              <th className="sag">{cev('Değer')}</th><th className="orta">{cev('Bayrak')}</th>
              <th className="orta">{cev('Durum')}</th><th>{cev('Cihaz')}</th>
            </tr></thead>
            <tbody>
              {veri.tekrarlar.map(t => (
                <tr key={t.sonucId}>
                  <td className="orta">{t.tekrarNo === 0 ? cev('ilk') : `${t.tekrarNo}.`}</td>
                  <td className="orta">{tarihSaat(t.tarih)}</td>
                  <td className="sag"><b>{t.deger}</b> {t.birim}</td>
                  <td className="orta">
                    {t.bayrak && t.bayrak !== 'N'
                      ? <span className={bayrakSinifi(t.bayrak)}>{t.bayrak}</span> : ''}
                  </td>
                  <td className="orta sonuk">{DURUM[t.onayDurum] ?? t.onayDurum}</td>
                  <td className="sonuk">{t.cihaz}</td>
                </tr>
              ))}
              {veri.tekrarlar.length === 0 && (
                <tr><td colSpan={6} className="sonuk">{cev('Tekrar çalışma yok.')}</td></tr>
              )}
            </tbody>
          </table></div>
        </>
      )}
    </Modal>
  );
}
