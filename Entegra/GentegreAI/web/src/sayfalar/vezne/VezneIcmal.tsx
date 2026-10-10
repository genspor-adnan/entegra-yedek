import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { VezneIcmali } from '../../api/uclar/vezneIcmal';
import { BankoOturumModali } from '../../bilesenler/banko/BankoOturumModali';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { VezneA4 } from './icmal/VezneA4';
import { DevirTablosu, OturumTablosu, PosTablosu, TurTablosu } from './icmal/VezneTablolari';
import { bugun } from './icmal/vezneOrtak';

/**
 * VEZNE / KASA KONSOLİDE İCMALİ `/vezne-icmali` — mockup Ekranlar/İcmal/
 * vezne_icmali.html (kullanıcı 10.10.2026: "vezne icmalini kodla").
 *
 * Şubenin bütün banko oturumlarının günü (ya da aralığı): oturum başına
 * tahsilat / sayım / fark, ödeme türleri, POS terminal mutabakatı, merkez
 * kasaya devir ve A4 "Günlük Vezne İcmali". Rakamlar SUNUCUDAN
 * (VezneIcmalUclari), banko oturum kartıyla aynı görünümlerden. Oturum
 * listesindeki onay kutuları diğer sekmeleri ve A4'ü süzer.
 * Görünüm hasta / kurum icmaliyle ortak.
 */
type Sekme = 'oturum' | 'tur' | 'pos' | 'devir';

const VARDIYALAR: [number, string][] = [[0, 'Tümü'], [1, 'Sabah'], [2, 'Öğleden sonra'], [3, 'Akşam'], [4, 'Gece / nöbet'], [9, 'Tüm gün']];

export function VezneIcmal() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const bas = arama.get('bas') ?? bugun();
  const bit = arama.get('bit') ?? bas;
  const vardiya = Number(arama.get('vardiya') ?? 0);
  const seciliAnahtar = arama.get('oturumlar') ?? '';
  const secili = seciliAnahtar.split(',').map(Number).filter(n => n > 0);
  const [veri, setVeri] = useState<VezneIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('oturum');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [acikOturum, setAcikOturum] = useState<number | null>(null);
  const [tazele, setTazele] = useState(0);

  // URL TEK KAYNAK: tarih, vardiya ve seçim adres çubuğunda.
  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.vezneIcmali(bas, bit, vardiya, seciliAnahtar ? seciliAnahtar.split(',').map(Number) : [])
      .then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, vardiya, seciliAnahtar, tazele]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const gunlu = bas !== bit;
  const gunKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`); d.setDate(d.getDate() + n);
    const g = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    degistir({ bas: g, bit: g, oturumlar: '' });
  };

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const posFarkli = veri?.pos.filter(t => Math.abs(t.fark ?? 0) > 0.005 || t.eksik).length ?? 0;
  const sekmeler: [Sekme, string, string | null, string][] = veri ? [
    ['oturum', 'Bankolar / Oturumlar', String(veri.oturumlar.length), ''],
    ['tur', 'Ödeme Türleri', String(veri.turler.length), ''],
    ['pos', 'POS Mutabakatı', posFarkli ? `${posFarkli} uyarı` : String(veri.pos.length), posFarkli ? ' kir' : ''],
    ['devir', 'Merkez Kasa Devri', String(o!.devredilenOturum), '']] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + VEZNE_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Vezne İcmali</h1>
          <span className="yol">Kayıt Kabul › Vezne İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        {/* ÇIKTI MENÜSÜ: Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸ - A4 menünün içinde, ayrı önizleme sekmesi yok. */}
        <CiktiMenusu etiket="Vezne İcmali" dosyaAdi={`Vezne İcmali ${bas}${bit !== bas ? ' - ' + bit : ''}`} devre={!veri}>
          {veri && <VezneA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} gunlu={gunlu} />}
        </CiktiMenusu>
        <span className="sp" />
        <button onClick={() => git('/banko-oturumlar')}>📋 Banko Oturumları</button>
        <button onClick={() => git('/banko-onay')}>✅ Banko Onayları</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">📅 Tarih:
            <button className="ki-ok" title="Önceki gün" onClick={() => gunKaydir(-1)}>‹</button>
            <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value, oturumlar: '' })} />–
            <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value, oturumlar: '' })} />
            <button className="ki-ok" title="Sonraki gün" onClick={() => gunKaydir(1)}>›</button>
          </div>
          <div className="sel">🕘 Vardiya:
            <select value={vardiya} onChange={e => degistir({ vardiya: e.target.value, oturumlar: '' })}>
              {VARDIYALAR.map(([k, ad]) => <option key={k} value={k}>{ad}</option>)}
            </select>
          </div>
          {secili.length > 0 && (
            <div className="sel">☑ {secili.length} oturum seçili
              <a className="ki-lnk" onClick={() => degistir({ oturumlar: '' })}>temizle</a></div>
          )}
          <span className="sp" />
          {o.acik + o.onayBekleyen > 0 && (
            <span className="bo-rz sari">{o.acik} oturum açık · {o.onayBekleyen} onay bekliyor</span>
          )}
          {o.farkliOturum > 0 && <span className="bo-rz kir">{o.farkliOturum} oturumda sayım farkı</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Toplam Tahsilat', paraYaz(o.tahsilat), `${o.makbuz} işlem · net ${paraYaz(o.net)}`)}
          {kutu('Nakit', paraYaz(o.nakit), 'kasada sayılır', 'iyi')}
          {kutu('POS', paraYaz(o.pos), `${veri.pos.length} terminal`, 'mor')}
          {kutu('Havale / Diğer', paraYaz(o.havale + o.diger), 'havale · çek · kupon')}
          {kutu('İade', paraYaz(o.iade), 'iade makbuzları', 'uy')}
          {kutu('Sayım Farkı', paraYaz(o.kasaFarki), `POS farkı ${paraYaz(o.posFarki)}`, Math.abs(o.kasaFarki) > 0.005 ? 'teh' : 'iyi')}
          {kutu('Açık Oturum', String(o.acik), `${o.onayBekleyen} onay bekliyor`)}
          {kutu('Merkeze Devredilen', paraYaz(o.devredilen), `${o.devredilenOturum} oturum · bekleyen ${paraYaz(o.bekleyenDevir)}`, 'iyi')}
        </div>

        <div className="hi-govde">
          <div className="hi-sol">
            <div className="katab">
              {sekmeler.map(([k, ad, n, renk]) => (
                <div key={k} className={'kat' + (sekme === k ? ' on' : '')} onClick={() => setSekme(k)}>
                  {ad}{n != null && <span className={'b' + renk}>{n}</span>}
                </div>
              ))}
            </div>
            {sekme === 'oturum' && (
              <OturumTablosu v={veri} secili={secili} gunlu={gunlu}
                             setSecili={s => degistir({ oturumlar: s.join(',') })}
                             oturumAc={setAcikOturum} />
            )}
            {sekme === 'tur' && <TurTablosu v={veri} />}
            {sekme === 'pos' && <PosTablosu v={veri} />}
            {sekme === 'devir' && <DevirTablosu v={veri} gunlu={gunlu} />}
          </div>
        </div>
      </>)}

      {acikOturum !== null && (
        <BankoOturumModali oturumId={acikOturum} onKapat={() => { setAcikOturum(null); setTazele(t => t + 1) }} />
      )}
    </div>
  );
}

/** Vezne icmaline özgü: A4 tablosu 10 sütun, POS uyarı rozeti. */
const VEZNE_STILI = `
.hi-serit select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; padding:1px 4px; }
.katab .kat .b.kir { background:#fbe9e7; color:#b3261e; }
.a4-t.vz-a4t { font-size:8.5px; }
.a4-t.vz-a4t th:nth-child(1) { width:11%; } .a4-t.vz-a4t th:nth-child(2) { width:15%; } .a4-t.vz-a4t th:nth-child(3) { width:11%; }
.a4-t.vz-a4t th:nth-child(-n+3), .a4-t.vz-a4t td:nth-child(-n+3) { text-align:left; }
`;

export default VezneIcmal;
