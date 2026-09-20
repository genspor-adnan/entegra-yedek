import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { DisIconSkoru } from '../../api/uclar/dis';
import { hataMetni } from '../../api/sozlesme';
import { gunNokta } from '../bicim';
import { guvenli, mesaj, onay } from '../mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c as cev } from '../../dil/ceviri';

/**
 * ORTODONTİ ICON SKOR FORMU (875 — KTS denetim maddesi D9:
 * "Ortodonti Icon Scor Formu Ekranı ve Raporları var mı?").
 *
 * <b>Beş bileşen, tek ekran.</b> Hekim puanları verir; toplam, tedavi
 * ihtiyacı ve karmaşıklık derecesi SUNUCUDAN gelir - ağırlıklar burada
 * yeniden yazılmaz (`fn_dis_icon_toplam`). Kaydetmeden önce de canlı
 * önizleme aynı uçtan okunur: ekranda görünen skor ile kaydedilen skorun
 * ayrışması, denetimde raporun kendisini tartışmalı yapardı.
 *
 * <b>Tedavi sonrası ölçüm önceki ölçüme bağlanır</b> ve iyileşme derecesi
 * (önce − 4 × sonra) o bağdan çıkar. Bağ seçilmezse sunucu hastanın son
 * "tedavi öncesi" ölçümünü bağlar.
 *
 * <b>Rapor yazdırılabilir:</b> tarayıcı baskısında yalnız skor kâğıdı
 * kalır (`ds-icon-rapor`), form ve liste basılmaz.
 */
type Taslak = {
  id: number | null; tarih: string; olcumTuru: number;
  estetik: number; ustArk: number; capraz: number; dikey: number; bukkal: number;
  oncesiId: number | null; not: string;
};

const BOS = (): Taslak => ({
  id: null, tarih: new Date().toISOString().slice(0, 10), olcumTuru: 1,
  estetik: 1, ustArk: 0, capraz: 0, dikey: 0, bukkal: 0, oncesiId: null, not: '',
});

/** Bileşen tanımı: etiket, aralık, ağırlık (ağırlık yalnız GÖSTERİM için). */
const BILESENLER: { alan: keyof Taslak; ad: string; ipucu: string; enAz: number; enCok: number; agirlik: number }[] = [
  { alan: 'estetik', ad: 'Estetik bileşen (IOTN-AC)', ipucu: '1 = en iyi · 10 = en kötü (fotoğraf skalası)', enAz: 1, enCok: 10, agirlik: 7 },
  { alan: 'ustArk', ad: 'Üst ark dizilimi / aralık', ipucu: '0 = düzgün · 4 = ileri çapraşıklık ya da aralık', enAz: 0, enCok: 4, agirlik: 5 },
  { alan: 'capraz', ad: 'Çapraz kapanış', ipucu: '0 = yok · 1 = var', enAz: 0, enCok: 1, agirlik: 5 },
  { alan: 'dikey', ad: 'Dikey ilişki (açık / derin kapanış)', ipucu: '0 = normal örtülü · 4 = ileri açık ya da derin kapanış', enAz: 0, enCok: 4, agirlik: 4 },
  { alan: 'bukkal', ad: 'Bukkal segment ön-arka ilişki', ipucu: '0 = Sınıf I · 4 = tam Sınıf II / III', enAz: 0, enCok: 4, agirlik: 3 },
];

const KARMASIKLIK_ROZET: Record<number, string> = { 1: 'ok', 2: 'mavi', 3: 'uyari', 4: 'uyari', 5: 'hata' };
const IYILESME_ROZET: Record<number, string> = { 1: 'ok', 2: 'ok', 3: 'mavi', 4: 'uyari', 5: 'hata' };

export function DisIconFormu({ hastaId, hastaAdi }: { hastaId: number; hastaAdi: string }) {
  const { yetki } = useOturum();
  const yazar = yetki('dis.icon');
  const [skorlar, setSkorlar] = useState<DisIconSkoru[]>([]);
  const [taslak, setTaslak] = useState<Taslak>(BOS());
  const [onizleme, setOnizleme] = useState<{ toplam: number; tedaviGerekir: boolean; karmasiklikAdi: string } | null>(null);
  const [formAcik, setFormAcik] = useState(false);
  const [rapor, setRapor] = useState<DisIconSkoru | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { const y = await api.disIconListe(hastaId); setSkorlar(y.skorlar); setHata(null) }
    catch (h) { setHata(hataMetni(h)) }
  }, [hastaId]);
  useEffect(() => { void yukle() }, [yukle]);

  // ÖNİZLEME SUNUCUDAN: ağırlıkları burada çarpmak, şemadaki hesapla
  //   ayrışma riski demekti. İstek küçük ve yalnız form açıkken atılır.
  useEffect(() => {
    if (!formAcik) { setOnizleme(null); return }
    let iptal = false;
    api.disIconHesapla({ estetik: taslak.estetik, ustArk: taslak.ustArk, capraz: taslak.capraz,
                         dikey: taslak.dikey, bukkal: taslak.bukkal })
      .then(y => { if (!iptal) setOnizleme(y) })
      .catch(() => { if (!iptal) setOnizleme(null) });
    return () => { iptal = true };
  }, [formAcik, taslak.estetik, taslak.ustArk, taslak.capraz, taslak.dikey, taslak.bukkal]);

  const duzenle = (s: DisIconSkoru) => {
    setTaslak({ id: s.id, tarih: s.tarih.slice(0, 10), olcumTuru: s.olcumTuru, estetik: s.estetik,
                ustArk: s.ustArk, capraz: s.capraz, dikey: s.dikey, bukkal: s.bukkal,
                oncesiId: s.oncesiId, not: s.not_ });
    setFormAcik(true);
  };

  const kaydet = async () => {
    await guvenli(async () => {
      const y = await api.disIconKaydet({
        id: taslak.id, hastaId, tarih: taslak.tarih, olcumTuru: taslak.olcumTuru,
        estetik: taslak.estetik, ustArk: taslak.ustArk, capraz: taslak.capraz,
        dikey: taslak.dikey, bukkal: taslak.bukkal, oncesiId: taslak.oncesiId, not: taslak.not,
      });
      mesaj(`ICON skoru kaydedildi: ${y.skor.toplam}`
            + (y.skor.tedaviGerekir ? ' · tedavi ihtiyacı var' : ' · tedavi ihtiyacı eşiğinin altında'));
      setFormAcik(false); setTaslak(BOS()); await yukle();
    });
  };

  const sil = async (s: DisIconSkoru) => {
    if (!await onay(`${gunNokta(s.tarih)} tarihli ICON kaydı (${s.toplam}) silinsin mi?`)) return;
    await guvenli(async () => { await api.disIconSil(s.id); await yukle() });
  };

  const oncekiler = skorlar.filter(s => s.olcumTuru === 1);

  return (
    <div className="ds-grp" style={{ margin: 10 }}>
      <div className="ds-gb">
        📐 Ortodonti ICON skoru
        <span className="ds-sp sonuk">
          {cev('Index of Complexity, Outcome and Need · tedavi ihtiyacı eşiği 43')}
        </span>
        {yazar && (
          <span className="ds-sp">
            <button className="d bir" onClick={() => { setTaslak(BOS()); setFormAcik(true) }}>
              + {cev('Yeni ölçüm')}
            </button>
          </span>
        )}
      </div>

      {hata && <div className="hata-kutusu" style={{ margin: 8 }}>{hata}</div>}

      {formAcik && (
        <div className="ds-ic ds-icon-form">
          <div className="ds-hdr" style={{ gridTemplateColumns: '150px 200px 1fr' }}>
            <div><label>Tarih</label>
              <input type="date" value={taslak.tarih}
                     onChange={e => setTaslak(t => ({ ...t, tarih: e.target.value }))} /></div>
            <div><label>{cev('Ölçüm')}</label>
              <select value={taslak.olcumTuru}
                      onChange={e => setTaslak(t => ({ ...t, olcumTuru: Number(e.target.value),
                                                       oncesiId: Number(e.target.value) === 1 ? null : t.oncesiId }))}>
                <option value={1}>{cev('Tedavi öncesi')}</option>
                <option value={2}>{cev('Tedavi sonrası')}</option>
              </select></div>
            {taslak.olcumTuru === 2 && (
              <div><label>{cev('Bağlı tedavi öncesi ölçüm')}</label>
                <select value={taslak.oncesiId ?? ''}
                        onChange={e => setTaslak(t => ({ ...t, oncesiId: e.target.value ? Number(e.target.value) : null }))}>
                  <option value="">{cev('(en son tedavi öncesi ölçüm)')}</option>
                  {oncekiler.map(o => <option key={o.id} value={o.id}>{gunNokta(o.tarih)} · {o.toplam}</option>)}
                </select></div>
            )}
          </div>

          <table className="ds-icon-tablo">
            <thead><tr><th>{cev('Bileşen')}</th><th className="orta">Puan</th><th className="orta">{cev('Ağırlık')}</th><th /></tr></thead>
            <tbody>
              {BILESENLER.map(b => {
                const deger = Number(taslak[b.alan]);
                return (
                  <tr key={b.alan}>
                    <td><b>{b.ad}</b><div className="sonuk">{b.ipucu}</div></td>
                    <td className="orta">
                      <div className="ds-icon-puanlar">
                        {Array.from({ length: b.enCok - b.enAz + 1 }, (_, i) => b.enAz + i).map(p => (
                          <button key={p} type="button"
                                  className={`d mini${deger === p ? ' bir' : ''}`}
                                  onClick={() => setTaslak(t => ({ ...t, [b.alan]: p }))}>{p}</button>
                        ))}
                      </div>
                    </td>
                    <td className="orta sonuk">× {b.agirlik}</td>
                    <td className="sag sonuk">{deger * b.agirlik}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>

          <div className="ds-hdr" style={{ gridTemplateColumns: '1fr' }}>
            <div><label>Not</label>
              <input value={taslak.not} maxLength={400}
                     onChange={e => setTaslak(t => ({ ...t, not: e.target.value }))} /></div>
          </div>

          <div className="ds-icon-ozet">
            {onizleme ? (
              <>
                <span>{cev('Toplam')}: <b>{onizleme.toplam}</b></span>
                <span className={`rozet ${onizleme.tedaviGerekir ? 'uyari' : 'ok'}`}>
                  {onizleme.tedaviGerekir ? cev('Tedavi ihtiyacı var (>43)') : cev('Eşiğin altında')}
                </span>
                {onizleme.karmasiklikAdi && <span className="rozet mavi">{onizleme.karmasiklikAdi}</span>}
              </>
            ) : <span className="sonuk">{cev('Toplam hesaplanıyor…')}</span>}
            <span className="ds-sp" />
            <button className="d bir" disabled={!yazar} onClick={() => void kaydet()}>{cev('Kaydet')}</button>
            <button className="d" onClick={() => { setFormAcik(false); setTaslak(BOS()) }}>{cev('Vazgeç')}</button>
          </div>
        </div>
      )}

      <div className="ds-dg"><table>
        <thead><tr>
          <th className="orta">Tarih</th><th>{cev('Ölçüm')}</th>
          <th className="orta">E</th><th className="orta">Ü</th><th className="orta">Ç</th>
          <th className="orta">D</th><th className="orta">B</th>
          <th className="orta">{cev('Toplam')}</th><th className="orta">{cev('Tedavi ihtiyacı')}</th>
          <th className="orta">{cev('Karmaşıklık')}</th><th className="orta">{cev('İyileşme')}</th>
          <th>Hekim</th><th />
        </tr></thead>
        <tbody>
          {skorlar.map(s => (
            <tr key={s.id}>
              <td className="orta">{gunNokta(s.tarih)}</td>
              <td>{s.olcumTuruAdi}</td>
              <td className="orta">{s.estetik}</td><td className="orta">{s.ustArk}</td>
              <td className="orta">{s.capraz}</td><td className="orta">{s.dikey}</td>
              <td className="orta">{s.bukkal}</td>
              <td className="orta"><b>{s.toplam}</b></td>
              <td className="orta"><span className={`rozet ${s.tedaviGerekir ? 'uyari' : 'ok'}`}>{s.tedaviGerekir ? 'var' : 'yok'}</span></td>
              <td className="orta">{s.karmasiklikAdi
                ? <span className={`rozet ${KARMASIKLIK_ROZET[s.karmasiklik ?? 0] ?? 'gri'}`}>{s.karmasiklikAdi}</span>
                : <span className="sonuk">—</span>}</td>
              <td className="orta">{s.iyilesmeAdi
                ? <span className={`rozet ${IYILESME_ROZET[s.iyilesme ?? 0] ?? 'gri'}`} title={`önce ${s.oncesiToplam} → sonra ${s.toplam}`}>{s.iyilesmeAdi}</span>
                : <span className="sonuk">—</span>}</td>
              <td>{s.hekim || '—'}</td>
              <td className="orta ds-satir-arac">
                <button className="d" title={cev('Rapor')} onClick={() => setRapor(s)}>🖨</button>
                {yazar && <button className="d" title={cev('Düzenle')} onClick={() => duzenle(s)}>✎</button>}
                {yazar && <button className="d" title={cev('Sil')} onClick={() => void sil(s)}>✕</button>}
              </td>
            </tr>
          ))}
          {skorlar.length === 0 && <tr><td colSpan={13} className="sonuk">{cev('ICON ölçümü yok.')}</td></tr>}
        </tbody>
      </table></div>

      {/* RAPOR: yazdırılabilir skor kâğıdı. Baskıda yalnız bu blok kalır. */}
      {rapor && (
        <div className="ds-icon-rapor">
          <div className="cikti-arac">
            <button className="d bir" onClick={() => window.print()}>🖨 {cev('Yazdır')}</button>
            <button className="d" onClick={() => setRapor(null)}>{cev('✖ Kapat')}</button>
          </div>
          <h3>{cev('Ortodonti ICON Skor Raporu')}</h3>
          <div className="ds-icon-rapor-ust">
            <span><b>{hastaAdi}</b></span>
            <span>{gunNokta(rapor.tarih)} · {rapor.olcumTuruAdi}</span>
            <span>{rapor.hekim || '—'}</span>
          </div>
          <table className="ds-icon-tablo">
            <thead><tr><th>{cev('Bileşen')}</th><th className="orta">Puan</th><th className="orta">{cev('Ağırlık')}</th><th className="sag">{cev('Katkı')}</th></tr></thead>
            <tbody>
              {BILESENLER.map(b => {
                const d = Number(rapor[b.alan as keyof DisIconSkoru] ?? 0);
                return (
                  <tr key={b.alan}><td>{b.ad}</td><td className="orta">{d}</td>
                    <td className="orta">× {b.agirlik}</td><td className="sag">{d * b.agirlik}</td></tr>
                );
              })}
              <tr className="grup"><td colSpan={3}>{cev('TOPLAM')}</td><td className="sag"><b>{rapor.toplam}</b></td></tr>
            </tbody>
          </table>
          <ul className="ds-icon-sonuc">
            <li>{cev('Tedavi ihtiyacı')}: <b>{rapor.tedaviGerekir ? cev('var (>43)') : cev('yok')}</b></li>
            <li>{cev('Karmaşıklık')}: <b>{rapor.karmasiklikAdi || '—'}</b></li>
            {rapor.oncesiToplam != null && (
              <li>{cev('İyileşme')}: <b>{rapor.iyilesmeAdi || '—'}</b>
                {' '}<span className="sonuk">({cev('önce')} {rapor.oncesiToplam} → {cev('sonra')} {rapor.toplam};
                  {' '}{cev('önce − 4 × sonra')} = {rapor.oncesiToplam - 4 * rapor.toplam})</span></li>
            )}
            {rapor.not_ && <li>Not: {rapor.not_}</li>}
          </ul>
        </div>
      )}
    </div>
  );
}
