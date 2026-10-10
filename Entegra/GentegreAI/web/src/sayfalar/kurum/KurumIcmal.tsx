import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { KurumIcmali } from '../../api/uclar/kurumIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { KurumIcmalA4 } from './icmal/KurumIcmalA4';
import {
  BasvuruTablosu, FaturaTablolari, HizmetGrubuTablosu, KesintiTablosu, KurumTablosu,
} from './icmal/KurumIcmalTablolari';
import { donemAdimlari, gecenAy, yerelGun } from './icmal/kurumIcmalOrtak';
import { stil } from './icmal/kurumIcmalStil';

/**
 * KURUM İCMALİ `/kurum-icmali` — mockup Ekranlar/İcmal/
 * kurum_icmal.html (kullanıcı 10.10.2026: "kurum icmal ekranını kodla").
 *
 * Ödeyen kurumların dönem başvuruları, kurum payı, kesinti, icmal / fatura
 * durumu ve kurum carisi. Rakamlar SUNUCUDAN (KurumIcmalOzetUclari).
 * "Dönemdeki Kurumlar" sekmesindeki onay kutuları (kullanıcı) diğer
 * sekmeleri süzer; hiçbiri seçili değilse bütün kurumlar. Tek kurum
 * seçiliyken icmal oluşturma / faturalama (289'un uçları) ve cari açılır.
 * Görünüm hasta icmaliyle ortak (icmalStil); A4 önizleme ayrı sekmede.
 */
type Sekme = 'kurumlar' | 'basvuru' | 'grup' | 'kesinti' | 'fatura' | 'onizleme';

export function KurumIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const varsayilan = gecenAy();
  const bas = arama.get('bas') ?? varsayilan.bas;
  const bit = arama.get('bit') ?? varsayilan.bit;
  const secili = (arama.get('kurumlar') ?? '').split(',').map(Number).filter(n => n > 0);
  const seciliAnahtar = secili.join(',');
  const geri = arama.get('geri');
  const [veri, setVeri] = useState<KurumIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>(secili.length ? 'basvuru' : 'kurumlar');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [tazele, setTazele] = useState(0);

  // URL TEK KAYNAK: dönem ve seçim adres çubuğunda - geri dönüşte ve
  //   hasta icmalinden dönünce ekran aynı haliyle açılır.
  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v) yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.kurumIcmali(seciliAnahtar ? seciliAnahtar.split(',').map(Number) : [], bas, bit)
      .then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [seciliAnahtar, bas, bit, tazele]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const tekKurum = veri && veri.kurumId > 0 ? veri.kurumlar.find(k => k.id === veri.kurumId) ?? null : null;
  const seciliAdlar = veri?.kurumlar.filter(k => secili.includes(k.id)).map(k => k.ad) ?? [];
  const kurumAdi = tekKurum?.ad ?? (seciliAdlar.length ? seciliAdlar.join(', ') : 'Tüm kurumlar');
  const hazirIcmal = veri?.icmaller.find(i => i.durum === 1) ?? null;
  const buYol = () => `/kurum-icmali?${arama.toString()}`;

  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`);
    const yeniBas = new Date(d.getFullYear(), d.getMonth() + n, 1);
    degistir({ bas: yerelGun(yeniBas), bit: yerelGun(new Date(yeniBas.getFullYear(), yeniBas.getMonth() + 1, 0)) });
  };

  // İCMAL OLUŞTUR (289): dönemin açık kurum payını icmale bağlar - satırlar
  //   kilitlenir, sonradan girilen başvuru yeni icmale düşer.
  const icmalOlustur = () => void guvenli(async () => {
    if (!tekKurum || !o) return;
    if (!(await onay(`${tekKurum.ad} · ${bas} – ${bit}: açık kurum payı ${paraYaz(o.acikKurumPayi)}. `
          + 'İcmal oluşturulsun mu? Satırlar bu icmale bağlanır.'))) return;
    const y = await api.icmalOlustur({ kurumId: tekKurum.id, donemBas: bas, donemBit: bit });
    mesaj(`İcmal oluşturuldu: ${y.satir} satır. "Kuruma Fatura Kes" ile tek fatura kesilir.`);
    setTazele(t => t + 1);
  });

  const faturala = () => void guvenli(async () => {
    if (!hazirIcmal) return;
    if (!(await onay(`${hazirIcmal.kurum} icmali faturalansın mı? ${paraYaz(hazirIcmal.toplam)} tutarında `
          + 'TEK fatura kesilir ve satırların kurum payı kapanır.'))) return;
    const y = await api.icmalFaturala(hazirIcmal.id);
    mesaj(`Fatura kesildi (${y.satir} kalem).`);
    setTazele(t => t + 1);
  });

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['kurumlar', 'Dönemdeki Kurumlar', veri.kurumlar.length], ['basvuru', 'Başvurular', veri.basvurular.length],
    ['grup', 'Hizmet Grupları', veri.hizmetGruplari.length], ['kesinti', 'Kesinti & İtiraz', veri.kesintiler.length],
    ['fatura', 'Fatura & Tahsilat', veri.icmaller.length], ['onizleme', '🖨️ Önizleme (A4)', null]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + stil}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kurum İcmali{tekKurum ? ` — ${tekKurum.ad}` : ''}</h1>
          <span className="yol">Kurumlar &amp; Sigorta › Kurum İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        <button disabled={!tekKurum || !o || o.acikKurumPayi <= 0.005}
                title={!tekKurum ? 'Tek kurum seçin' : 'Dönemin açık kurum payını icmale bağlar'}
                onClick={icmalOlustur}>🔒 İcmal Oluştur (Kesinleştir)</button>
        <button className="hi-yesil" disabled={!hazirIcmal} title={hazirIcmal ? '' : 'Hazırlanmış icmal yok'}
                onClick={faturala}>🧾 Kuruma Fatura Kes</button>
        <span className="ki-ayrac" />
        <button className="hi-ana" disabled={!veri} onClick={() => window.print()}>🖨️ Yazdır (A4 Kurum İcmali)</button>
        <span className="sp" />
        <button onClick={() => git('/kurum-icmal')}>🧾 Kurum İcmalleri</button>
        {geri && <button onClick={() => git(geri)}>↩ Geri Dön</button>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">🏢 Kurum: <b>{kurumAdi}</b>
            {secili.length > 0 && <a className="ki-lnk" onClick={() => { degistir({ kurumlar: '' }); setSekme('kurumlar') }}>temizle</a>}
          </div>
          <div className="sel">📅 Dönem:
            <button className="ki-ok" title="Önceki ay" onClick={() => ayKaydir(-1)}>‹</button>
            <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value })} />–
            <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
            <button className="ki-ok" title="Sonraki ay" onClick={() => ayKaydir(1)}>›</button>
          </div>
          <span className="sp" />
          {tekKurum && (
            <div className="ki-adim">
              {donemAdimlari(veri).map(a => (
                <span key={a.ad} className={a.durum}>{a.durum === 'bitti' ? '✓ ' : ''}{a.ad}</span>
              ))}
            </div>
          )}
        </div>

        <div className="hi-ozet">
          {kutu('Başvuru', String(o.basvuru), `${o.hasta} hasta · ${o.provizyonlu} provizyonlu${o.red ? ` · ${o.red} red` : ''}`)}
          {kutu('Toplam Hizmet', paraYaz(o.toplam), `${o.kalem} kalem`)}
          {kutu('Kurum Payı', paraYaz(o.kurumPayi), 'SGK + özel sigorta', 'mor')}
          {kutu('Hasta Payı', paraYaz(o.hastaPayi), 'bilgi · kurumdan istenmez')}
          {kutu('Kesinti', paraYaz(o.kesinti), o.kesintiBasvuru ? `${o.kesintiBasvuru} başvuru` : 'kesinti yok', 'uy')}
          {kutu('Faturalanan', paraYaz(o.faturalanan),
            tekKurum && o.acikKurumPayi > 0.005 ? `açık pay ${paraYaz(o.acikKurumPayi)}` : 'dönem icmalleri')}
          {kutu('Kurumdan Tahsil', paraYaz(o.tahsil), 'icmal faturalarına', 'iyi')}
          {veri.cari
            ? kutu('Kurum Bakiyesi', paraYaz(veri.cari.bakiye), 'cari · borçlu', veri.cari.bakiye > 0.005 ? 'teh' : 'iyi')
            : kutu('Net Alacak', paraYaz(o.net), 'kurum payı − kesinti', 'teh')}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {sekmeler.map(([k, ad, n]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{n != null && <span className="b">{n}</span>}
                </div>
              ))}
            </div>
            {sekme === 'kurumlar' && (
              <KurumTablosu v={veri} secili={secili}
                            setSecili={s => degistir({ kurumlar: s.join(',') })} />
            )}
            {sekme === 'basvuru' && (
              <BasvuruTablosu v={veri} kurumSutunu={!tekKurum}
                              hastaAc={id => git(`/hasta-icmal/${id}?geri=${encodeURIComponent(buYol())}`)} />
            )}
            {sekme === 'grup' && <HizmetGrubuTablosu v={veri} />}
            {sekme === 'kesinti' && <KesintiTablosu v={veri} />}
            {sekme === 'fatura' && <FaturaTablolari v={veri} faturaAc={id => git(`/belge/${id}`)} />}
            <div className={'hi-onizleme' + (sekme === 'onizleme' ? '' : ' gizli')}>
              <KurumIcmalA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} kurumAdi={kurumAdi} />
            </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

export default KurumIcmal;
