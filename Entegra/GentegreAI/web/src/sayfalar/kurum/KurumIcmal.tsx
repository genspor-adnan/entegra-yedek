import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { KurumIcmalKaydi, KurumIcmali } from '../../api/uclar/kurumIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { IcmallerSekmesi } from './icmal/IcmallerSekmesi';
import { KurumIcmalA4 } from './icmal/KurumIcmalA4';
import {
  BasvuruTablosu, CariTablosu, HizmetGrubuTablosu, KesintiTablosu, KurumTablosu,
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
 *
 * VER2 (mockup kurum_icmal_ver2.html, kullanıcı 10.10.2026: "ver2 yi kodla"):
 * eski "Kurum İcmalleri" listesi "İcmaller" sekmesi oldu (dönemden bağımsız
 * icmal kayıtları); eski adres `/kurum-icmal` buraya `?sekme=icmaller` ile
 * yönlenir. Fatura tablosu oraya taşındı, kalan sekme "Cari & Tahsilat".
 */
type Sekme = 'kurumlar' | 'basvuru' | 'grup' | 'kesinti' | 'icmaller' | 'cari';
const SEKMELER: Sekme[] = ['kurumlar', 'basvuru', 'grup', 'kesinti', 'icmaller', 'cari'];

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
  // Açılış sekmesi adresten (eski Kurum İcmalleri bağlantısı ?sekme=icmaller).
  const [sekme, setSekme] = useState<Sekme>(() => {
    const a = arama.get('sekme') as Sekme | null;
    return a && SEKMELER.includes(a) ? a : secili.length ? 'basvuru' : 'kurumlar';
  });
  const [yazdirBekliyor, setYazdirBekliyor] = useState(false);
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
  // İCMALİ YAZDIR (İcmaller sekmesi): ekran icmalin kurum ve dönemine geçer,
  //   veri gelince A4 basılır - belge o kurum / dönemin icmalidir.
  useEffect(() => {
    if (!yazdirBekliyor || !veri) return;
    setYazdirBekliyor(false);
    const z = setTimeout(() => window.print(), 300);
    return () => clearTimeout(z);
  }, [yazdirBekliyor, veri]);

  /** İcmal kaydının kurumuna ve dönemine geç (İcmaller sekmesinde çift tık). */
  const icmaleGec = (k: KurumIcmalKaydi, hedef: Sekme) => {
    setVeri(null);
    degistir({ kurumlar: String(k.kurumId), bas: k.donemBas.slice(0, 10), bit: k.donemBit.slice(0, 10), sekme: '' });
    setSekme(hedef);
  };

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
  //   kilitlenir, sonradan girilen başvuru yeni icmale düşer. Kurum verilir
  //   (tek kurum seçili değilse İcmaller sekmesinde seçtirilir - kullanıcı:
  //   "İcmal Oluştur butonu çalışmıyor", tek kurum şartıyla pasif kalıyordu).
  //   Tutar 289'un önizlemesinden: oluşturmayla AYNI küme.
  const icmalOlustur = (kurumId: number, kurumAd: string) => guvenli(async () => {
    const on = await api.icmalOnizleme(kurumId, bas, bit);
    if (on.satirlar.length === 0) {
      // NEDEN SÖYLENİR: düğme pasif kalınca "çalışmıyor" sanılıyordu. Kurum
      //   payı olup açık payı olmayan dönemde pay ya başka icmalde, ya kurum
      //   tahakkukuyla kapanmış ya da başvuru kesinleşmemiştir.
      const kp = veri?.kurumlar.find(k => k.id === kurumId)?.kurumPayi ?? 0;
      mesaj(`${kurumAd} için ${bas} – ${bit} döneminde icmale girmemiş açık kurum payı yok.`
        + (kp > 0.005 ? ` Dönemdeki kurum payı (${paraYaz(kp)}) başka bir icmalde, kurum tahakkukuyla kapatılmış`
          + ' ya da başvurular kesinleşmemiş.' : ''));
      return;
    }
    if (!(await onay(`${kurumAd} · ${bas} – ${bit}: ${on.satirlar.length} satır, açık kurum payı `
          + `${paraYaz(on.toplam)}. İcmal oluşturulsun mu? Satırlar bu icmale bağlanır.`))) return;
    const y = await api.icmalOlustur({ kurumId, donemBas: bas, donemBit: bit });
    mesaj(`İcmal oluşturuldu: ${y.satir} satır. "Faturala" ile kuruma tek fatura kesilir.`);
    setTazele(t => t + 1);
  });
  const [kurumSecIstegi, setKurumSecIstegi] = useState(0);
  /** Üst araç çubuğu: tek kurum varsa doğrudan, yoksa İcmaller'de kurum seçtir. */
  const ustIcmalOlustur = () => {
    if (tekKurum) { void icmalOlustur(tekKurum.id, tekKurum.ad); return }
    setSekme('icmaller'); setKurumSecIstegi(n => n + 1);
  };

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
    ['icmaller', 'İcmaller', null], ['cari', 'Cari & Tahsilat', veri.cari ? veri.cari.hareketler.length : null]] : [];

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
        <button title="Dönemin açık kurum payını icmale bağlar" disabled={!veri}
                onClick={ustIcmalOlustur}>🔒 İcmal Oluştur (Kesinleştir)</button>
        <button className="hi-yesil" disabled={!hazirIcmal} title={hazirIcmal ? '' : 'Hazırlanmış icmal yok'}
                onClick={faturala}>🧾 Kuruma Fatura Kes</button>
        <span className="ki-ayrac" />
        {/* ÇIKTI MENÜSÜ: Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸ - A4 menünün içinde, ayrı önizleme sekmesi yok. */}
        <CiktiMenusu etiket="Kurum İcmali" dosyaAdi={`Kurum İcmali ${tekKurum ? tekKurum.ad + ' ' : ''}${bas} - ${bit}`} devre={!veri}>
          {veri && <KurumIcmalA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} kurumAdi={kurumAdi} />}
        </CiktiMenusu>
        <span className="sp" />
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
            {sekme === 'icmaller' && (
              <IcmallerSekmesi seciliKurumlar={secili} tazele={tazele}
                               kurumlar={veri.kurumlar} varsayilanKurum={tekKurum?.id ?? 0}
                               donem={`${bas} – ${bit}`} kurumSecIstegi={kurumSecIstegi}
                               icmalOlustur={icmalOlustur}
                               ac={k => icmaleGec(k, 'basvuru')}
                               yazdir={k => { icmaleGec(k, 'basvuru'); setYazdirBekliyor(true) }}
                               faturaAc={id => git(`/belge/${id}`)} degisti={() => setTazele(t => t + 1)} />
            )}
            {sekme === 'cari' && <CariTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

export default KurumIcmal;
