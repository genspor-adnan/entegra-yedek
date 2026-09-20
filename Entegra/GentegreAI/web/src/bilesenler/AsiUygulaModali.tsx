import { useCallback, useEffect, useState } from 'react';
import { Modal } from './Modal';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { guvenli, mesaj } from './mesaj';
import { tarihSaat } from './bicim';
import { c as cev } from '../dil/ceviri';

/**
 * AŞI UYGULAMA (898 — KTS denetim maddesi H10, USS 207).
 *
 * <b>Doz numarasını kullanıcı yazmaz.</b> Sunucu hastanın geçmişine bakıp
 * sıradaki dozu söyler; elle yazılan doz numarası, USS'de yanlış şema
 * demektir (3 dozluk aşının 2. dozu 1. doz diye gidince Bakanlık tarafındaki
 * takvim kayar).
 *
 * <b>Şeması biten aşı listede çıkmaz:</b> "kalan doz yok" bilgisini kaydı
 * reddederek değil, seçeneği hiç göstermeyerek veririz.
 *
 * <b>SKRS kodu olmayan aşı uyarısıyla kaydedilir:</b> kayıt kurumun kendi
 * verisidir, gönderim ayrı iştir - kaydı engellemek, yapılmış aşıyı
 * kayıtsız bırakırdı.
 */
type Siradaki = { asiId: number; kod: string; ad: string; dozSayisi: number; sonrakiDoz: number };
type Uygulama = {
  id: number; asi: string; asiKod: string; dozNo: number; dozSayisi: number;
  kalanDoz: number; lot: string; uygulamaZamani: string; uygulayan: string;
  durum: number; iptalNeden: string; skrsKod: string;
};

export function AsiUygulaModali({ hastaId, hastaAdi, belgeId, onKapat }: {
  hastaId: number; hastaAdi?: string; belgeId?: number | null; onKapat(): void;
}) {
  const [siradaki, setSiradaki] = useState<Siradaki[]>([]);
  const [gecmis, setGecmis] = useState<Uygulama[]>([]);
  const [asiId, setAsiId] = useState(0);
  const [lot, setLot] = useState('');
  const [barkod, setBarkod] = useState('');
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try {
      const y = await api.asiHastaGecmisi(hastaId);
      setSiradaki(y.siradaki ?? []);
      setGecmis(y.uygulamalar ?? []);
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);
  useEffect(() => { void yukle() }, [yukle]);

  const secili = siradaki.find(s => s.asiId === asiId);

  const uygula = async () => {
    if (!asiId) { mesaj('Aşı seçin.'); return }
    await guvenli(async () => {
      const y = await api.asiUygula({
        tarafId: hastaId, asiId, belgeId: belgeId ?? null,
        lot: lot.trim(), barkod: barkod.trim() });
      mesaj(y.mesaj);
      setAsiId(0); setLot(''); setBarkod('');
      await yukle();
    });
  };

  return (
    <Modal baslik={`💉 ${cev('Aşı Uygula')}${hastaAdi ? ' · ' + hastaAdi : ''}`}
           onKapat={onKapat}
           alt={<>
             <button type="button" className="b" onClick={() => void uygula()}
                     disabled={!asiId}>{cev('Uygula')}</button>
             <button type="button" className="d" onClick={onKapat}>{cev('Kapat')}</button>
           </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="alan">
        <label>{cev('Aşı')}</label>
        <select value={asiId} onChange={e => setAsiId(Number(e.target.value))}>
          <option value={0}>{cev('— seçin —')}</option>
          {siradaki.map(s => (
            <option key={s.asiId} value={s.asiId}>
              {s.kod} · {s.ad}
              {s.dozSayisi > 0 ? ` (${s.sonrakiDoz}. doz / ${s.dozSayisi})` : ''}
            </option>
          ))}
        </select>
      </div>
      {siradaki.length === 0 && (
        <div className="ds-ic sonuk">
          {cev('Uygulanabilecek aşı yok - katalog boş ya da şemalar tamamlanmış.')}
        </div>
      )}
      {secili && (
        // DOZ SUNUCUDAN: ekran yalnız gösterir, kullanıcı değiştirmez.
        <div className="not">
          {cev('Kaydedilecek doz')}: <b>{secili.sonrakiDoz}</b>
          {secili.dozSayisi > 0 ? ` / ${secili.dozSayisi}` : ` (${cev('şemasız')})`}
        </div>
      )}

      <div className="ds-sr" style={{ marginTop: 6 }}>
        <div className="alan">
          <label>{cev('Lot')}</label>
          <input value={lot} onChange={e => setLot(e.target.value)} />
        </div>
        <div className="alan">
          <label>{cev('Barkod / karekod')}</label>
          <input value={barkod} onChange={e => setBarkod(e.target.value)}
                 placeholder={cev('okutun')} />
        </div>
      </div>

      <div className="ds-gb" style={{ marginTop: 10 }}>
        {cev('Aşı geçmişi')}
        <span className="ds-sp sonuk">{gecmis.length} {cev('kayıt')}</span>
      </div>
      <div className="ds-dg"><table>
        <thead><tr>
          <th>{cev('Aşı')}</th><th className="sag">{cev('Doz')}</th>
          <th className="orta">{cev('Tarih')}</th><th>{cev('Uygulayan')}</th>
          <th className="orta">{cev('Durum')}</th>
        </tr></thead>
        <tbody>
          {gecmis.map(u => (
            <tr key={u.id} className={u.durum === 0 ? 'sonuk' : undefined}>
              <td>
                {u.asiKod} · {u.asi}
                {/* SKRS KODU YOKSA GÖNDERİLEMEZ: kullanıcı bunu kayıt
                    listesinde de görmeli, yoksa "gönderildi" sanır. */}
                {!u.skrsKod && (
                  <span className="rozet uyari" style={{ marginLeft: 4 }}>
                    {cev('SKRS kodu yok')}
                  </span>
                )}
              </td>
              <td className="sag">{u.dozNo}{u.dozSayisi > 0 ? `/${u.dozSayisi}` : ''}</td>
              <td className="orta">{tarihSaat(u.uygulamaZamani)}</td>
              <td>{u.uygulayan}</td>
              <td className="orta">
                {u.durum === 1
                  ? <span className="rozet olumlu">{cev('Uygulandı')}</span>
                  : <span className="rozet gri" title={u.iptalNeden}>{cev('İptal')}</span>}
              </td>
            </tr>
          ))}
          {gecmis.length === 0 && (
            <tr><td colSpan={5} className="not">{cev('Kayıtlı aşı yok.')}</td></tr>
          )}
        </tbody>
      </table></div>
    </Modal>
  );
}
