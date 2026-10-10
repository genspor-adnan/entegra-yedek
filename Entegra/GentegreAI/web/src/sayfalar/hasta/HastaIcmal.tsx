import { useEffect, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { HastaIcmali } from '../../api/uclar/hastaIcmal';
import { paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { IcmalA4 } from './icmal/IcmalA4';
import {
  BasvuruTablosu, HareketTablosu, HizmetTablosu, ProvizyonTablosu, TahsilatTablosu,
} from './icmal/IcmalTablolari';
import { isoGun } from './icmal/icmalOrtak';
import { stil } from './icmal/icmalStil';

/**
 * HASTA İCMALİ `/hasta-icmal/:hastaId` — mockup Ekranlar/İcmal/
 * hasta_icmal.html (kullanıcı 10.10.2026: "hasta icmal ekranını kodla").
 *
 * Bütün rakamlar SUNUCUDAN (HastaIcmalUclari): ekran yalnız çizer.
 * Kurum payı bilgi amaçlı; hastaya söylenen rakam kalan borçtur. Avans
 * kalan borçtan kendiliğinden düşmez. Tablolar `icmal/IcmalTablolari`,
 * A4 belge `icmal/IcmalA4`, saf hesaplar `icmal/icmalOrtak` (testli).
 */
type Sekme = 'basvuru' | 'hizmet' | 'tahsilat' | 'provizyon' | 'hareket';

export function HastaIcmal() {
  const { hastaId } = useParams();
  const [arama] = useSearchParams();
  const git = useNavigate();
  const { kullanici } = useOturum();
  const bugun = new Date();
  const [bas, setBas] = useState(isoGun(new Date(bugun.getFullYear(), bugun.getMonth() - 12, bugun.getDate())));
  const [bit, setBit] = useState(isoGun(bugun));
  const [veri, setVeri] = useState<HastaIcmali | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('basvuru');
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const geri = arama.get('geri');

  useEffect(() => {
    if (!hastaId) return;
    setHata('');
    api.hastaIcmal(Number(hastaId), bas, bit).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [hastaId, bas, bit]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const o = veri?.ozet;
  const yas = veri?.hasta.dogumTarihi
    ? Math.floor((Date.now() - new Date(veri.hasta.dogumTarihi).getTime()) / 31557600000) : null;
  const cins = veri?.hasta.cinsiyet === 1 ? 'E' : veri?.hasta.cinsiyet === 2 ? 'K' : '';
  const kurumlar = [...new Set((veri?.basvurular ?? []).map(b => b.kurum))].join(' + ');

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['basvuru', 'Başvurular', veri.basvurular.length], ['hizmet', 'Hizmetler', veri.hizmetler.length],
    ['tahsilat', 'Tahsilatlar', veri.tahsilatlar.length], ['provizyon', 'Kurum Provizyonları', veri.provizyonlar.length],
    ['hareket', 'Hareket Özeti', null]] : [];

  return (
    <div className="hi">
      <style>{stil}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Hasta İcmali{veri ? ` — ${veri.hasta.ad}` : ''}</h1>
          <span className="yol">Kayıt Kabul › Hasta › Hesap İcmali</span>
        </div>
      </div>

      <div className="hi-arac">
        {/* ÇIKTI MENÜSÜ: Baskı Önizleme / Yazıcıya Yazdır / Gönder ▸ - A4 menünün içinde, ayrı önizleme sekmesi yok. */}
        <CiktiMenusu etiket="Hasta İcmali" dosyaAdi={`Hasta İcmali ${veri?.hasta.ad ?? ''}`} devre={!veri}>
          {veri && <IcmalA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} />}
        </CiktiMenusu>
        <span className="sp" />
        {geri && <button onClick={() => git(geri)}>↩ Geri Dön</button>}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">👤 <b>{veri.hasta.ad}</b>{veri.hasta.tc && ` · TC ${veri.hasta.tc}`}{yas != null && ` · ${yas} yaş`}{cins && ` · ${cins}`}</div>
          {veri.hasta.dosyaNo && <div className="sel">📁 Dosya No: <b>{veri.hasta.dosyaNo}</b></div>}
          {kurumlar && <div className="sel">🏥 Kurum: <b>{kurumlar}</b></div>}
          <div className="sel">📅 Dönem:
            <input type="date" value={bas} onChange={e => e.target.value && setBas(e.target.value)} />–
            <input type="date" value={bit} onChange={e => e.target.value && setBit(e.target.value)} />
          </div>
          <span className="sp" />
          {o.kalan > 0.005 && <span className="bo-rz kir">Açık borç var</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Toplam Hizmet', paraYaz(o.toplam), `${o.basvuru} başvuru · ${o.kalem} kalem`)}
          {kutu('Kurum Payı', paraYaz(o.kurumPayi), 'SGK + özel sigorta', 'mor')}
          {kutu('Hasta Payı', paraYaz(o.hastaPayi), 'katılım + fark + ücretli')}
          {kutu('İskonto', paraYaz(o.iskonto), 'satır iskontoları', 'uy')}
          {kutu('Tahsil Edilen', paraYaz(o.tahsil), 'iptal hariç', 'iyi')}
          {kutu('İade', paraYaz(o.iade), 'iade makbuzları')}
          {kutu('Kalan Borç', paraYaz(o.kalan), 'hastadan alınacak', o.kalan > 0.005 ? 'teh' : 'iyi')}
          {kutu('Avans / Alacak', paraYaz(o.avans), 'mahsup edilmedi')}
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
            {sekme === 'basvuru' && <BasvuruTablosu v={veri} />}
            {sekme === 'hizmet' && <HizmetTablosu v={veri} />}
            {sekme === 'tahsilat' && <TahsilatTablosu v={veri} />}
            {sekme === 'provizyon' && <ProvizyonTablosu v={veri} />}
            {sekme === 'hareket' && <HareketTablosu v={veri} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

export default HastaIcmal;
