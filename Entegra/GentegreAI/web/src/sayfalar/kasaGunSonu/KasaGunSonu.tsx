import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { GunSonu } from '../../api/uclar/kasaGunSonu';
import { para, paraYaz } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { GunSonuA4 } from './GunSonuA4';
import { gunKaydir } from './kasaGunSonuOrtak';
import { BankaTablosu, FarkTablosu, HareketTablosu, KasaTablosu, PosTablosu } from './GunSonuTablolari';

/**
 * KASA / GÜN SONU MUTABAKATI `/kasa-gun-sonu` — mockup Ekranlar/İcmal/
 * kasa_gun_sonu_mutabakati.html (kullanıcı 11.10.2026: "kasa mutabakatını kodla").
 *
 * Şubenin bir gününde bütün kasalar, POS ve banka: beklenen / sayılan / fark,
 * POS gün sonu ve banka ekstresi karşılaştırması, fark açıklaması ve GÜNÜ
 * KAPAT (kapalı güne kasa işlemi yazılamaz - veritabanı kilidi). Vezne
 * İcmali bir alt düzeydir (banko oturumları). Rakamlar SUNUCUDAN.
 */
type Sekme = 'kasa' | 'pos' | 'banka' | 'hareket' | 'fark';

export function KasaGunSonu() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { kullanici, yetki } = useOturum();
  const dun = gunKaydir(new Date().toISOString().slice(0, 10), -1);
  const tarih = arama.get('tarih') ?? dun;
  const [veri, setVeri] = useState<GunSonu | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('kasa');
  const [secili, setSecili] = useState<number[]>([]);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  const [tazele, setTazele] = useState(0);

  const degistir = useCallback((t: string) => {
    const yeni = new URLSearchParams(arama); yeni.set('tarih', t);
    setArama(yeni, { replace: true }); setSecili([]);
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.kasaGunSonu(tarih).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [tarih, tazele]);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const yenile = () => setTazele(t => t + 1);
  const kapali = !!veri?.kapanis?.kapali;
  const acik = !!veri && !kapali && yetki('kasa.gun_sonu', 'degistir');
  const o = veri?.ozet;
  const p = (n: number) => para.format(n);

  const sayimKaydet = (hesapId: number, n: number | null) => guvenli(async () => {
    if (n == null) return;
    await api.kasaGunSayim({ tarih, hesapId, sayilan: n }); yenile();
  });
  const posKaydet = (hesapId: number, n: number | null) => guvenli(async () => {
    await api.kasaGunPos({ tarih, hesapId, adet: 0, tutar: n }); yenile();
  });
  const bankaKaydet = (hesapId: number, yatis: number | null, havale: number | null) => guvenli(async () => {
    await api.kasaGunBanka({ tarih, hesapId, yatis, havale }); yenile();
  });
  const farkKaydet = (kalem: string, fark: number, neden: number, aciklama: string) => guvenli(async () => {
    await api.kasaGunFark({ tarih, kalem, fark, neden, aciklama }); yenile();
  });
  const gunuKapat = () => void guvenli(async () => {
    if (!veri) return;
    if (veri.engeller.length) { setSekme('fark'); mesaj(`Gün kapatılamaz:\n• ${veri.engeller.join('\n• ')}`); return }
    if (!(await onay(`${tarihKisa(veri.tarih)} günü kapatılsın mı? Kapalı güne kasa işlemi yazılamaz, `
          + `değiştirilemez; günü yalnız yetkili kişi gerekçeyle açabilir.`, true))) return;
    await api.kasaGunKapat(tarih); mesaj('Gün kapatıldı.'); yenile();
  });
  const gunuAc = () => void guvenli(async () => {
    const g = await metinSor('Günü açma gerekçesi (kayıtta kalır):', '', 'Gerekçe');
    if (!g) return;
    await api.kasaGunAc(tarih, g); mesaj('Gün açıldı.'); yenile();
  });

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const sekmeler: [Sekme, string, number | null][] = veri ? [
    ['kasa', 'Kasalar', veri.kasalar.length], ['pos', 'POS Mutabakatı', veri.poslar.length], ['banka', 'Banka Hareketleri', veri.bankalar.length],
    ['hareket', 'Hareketler', veri.hareketler.length], ['fark', 'Farklar / Açıklamalar', veri.farklar.filter(f => f.engel && !f.aciklama).length]] : [];
  const seciliAdlar = veri ? veri.kasalar.filter(k => secili.includes(k.id)).map(k => k.ad) : [];
  const gunAdi = new Date(`${tarih}T00:00:00`).toLocaleDateString('tr-TR', { weekday: 'long' });

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + GS_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kasa / Gün Sonu Mutabakatı</h1>
          <span className="yol">Finans › Kasa / Gün Sonu</span>
        </div>
      </div>

      <div className="hi-arac">
        {!kapali && (
          <button className={'hi-yesil' + (veri?.engeller.length ? ' gs-pasif' : '')} disabled={!veri || !yetki('kasa.gun_sonu', 'degistir')}
                  title={veri?.engeller.length ? `${veri.engeller.length} engel var` : 'Günü kilitle'} onClick={gunuKapat}>
            🔒 Günü Kapat{veri?.engeller.length ? ` (${veri.engeller.length} engel)` : ''}</button>
        )}
        {kapali && yetki('kasa.gun_sonu', 'sil') && <button onClick={gunuAc}>🔓 Günü Aç</button>}
        <CiktiMenusu etiket="Gün Sonu Raporu" dosyaAdi={`Gün Sonu Kasa Raporu ${tarih}`} devre={!veri}>
          {veri && <GunSonuA4 v={veri} antet={antet} duzenleyen={kullanici?.ad ?? ''} secili={secili} />}
        </CiktiMenusu>
        <span className="sp" />
        <button onClick={() => git(`/vezne-icmali?bas=${tarih}&bit=${tarih}`)}>🏦 Vezne İcmali</button>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">📅 Tarih:
            <button className="ki-ok" title="Önceki gün" onClick={() => degistir(gunKaydir(tarih, -1))}>‹</button>
            <input type="date" value={tarih} onChange={e => e.target.value && degistir(e.target.value)} />
            <span className="ki-soluk">{gunAdi}</span>
            <button className="ki-ok" title="Sonraki gün" onClick={() => degistir(gunKaydir(tarih, 1))}>›</button>
          </div>
          <span className="sp" />
          {kapali
            ? <span className="bo-rz ok">Gün kapalı · {veri.kapanis!.kapatan} {new Date(veri.kapanis!.kapanisZamani).toLocaleString('tr-TR')}</span>
            : <span className={'bo-rz ' + (veri.engeller.length ? 'kir' : 'sari')}>Gün açık{veri.engeller.length ? ` · kapatılamaz (${veri.engeller.length} engel)` : ' · kapatılabilir'}</span>}
          {veri.kapanis && !veri.kapanis.kapali && veri.kapanis.acilisZamani && (
            <span className="bo-rz pas" title={veri.kapanis.gerekce}>yeniden açıldı · {veri.kapanis.acan}</span>
          )}
          {o.acikOturum > 0 && <span className="bo-rz sari">{o.acikOturum} kapanmamış banko oturumu</span>}
          {Math.abs(o.posFark) > 0.005 && <span className="bo-rz kir">POS farkı {p(o.posFark)}</span>}
          {veri.onceki
            ? <span className="ki-soluk">{tarihKisa(veri.onceki.tarih)} {veri.onceki.kapali ? `kapatıldı · ${veri.onceki.kapatan}` : 'yeniden açık'}</span>
            : <span className="ki-soluk">önceki gün kapatılmadı</span>}
        </div>

        <div className="hi-ozet">
          {kutu('Devir (Açılış)', paraYaz(o.devir), `${o.kasaAdet} kasa · önceki gün sonu`)}
          {kutu('Nakit Giriş', paraYaz(o.girisNakit), `${o.makbuz} nakit tahsilat`, 'iyi')}
          {kutu('Nakit Çıkış', paraYaz(o.cikisNakit), 'iade ve ödemeler', 'uy')}
          {kutu('Kasa Bakiyesi', paraYaz(o.beklenen), o.sayilanAdet
            ? `beklenen · sayılan ${p(o.sayilan)} / ${p(o.sayilanBeklenen)} (${o.sayilanAdet} kasa) · fark ${p(o.kasaFark)}` : 'beklenen · sayım yok',
            Math.abs(o.kasaFark) > 0.005 ? 'teh' : '')}
          {kutu('POS / Kredi Kartı', paraYaz(o.pos), `${o.posAdet} çekim · gün sonu ${p(o.posBatch)} / ${p(o.posBatchSistem)} · fark ${p(o.posFark)}`
            + (o.posBekleyen.length ? ` · ${o.posBekleyen.join(', ')} bekliyor` : ''), Math.abs(o.posFark) > 0.005 ? 'teh' : 'mor')}
          {kutu('Havale / EFT', paraYaz(o.havale), `${o.havaleAdet} işlem · ekstre ${p(o.havaleEkstre)} (${o.bankaFark >= 0 ? '+' : ''}${p(o.bankaFark)})`)}
          {kutu('Bankaya Yatırılan', paraYaz(o.bankayaYatirilan), 'kasadan bankaya')}
          {kutu('Ertesi Gün Devri', paraYaz(o.ertesiGunDevri), o.ertesiKesin ? 'sayılan kasalar' : 'sayılmayan kasa beklenenle · kesin değil')}
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
            {sekme === 'kasa' && <KasaTablosu v={veri} secili={secili} setSecili={setSecili} acik={acik} sayimKaydet={sayimKaydet} />}
            {sekme === 'pos' && <PosTablosu v={veri} acik={acik} posKaydet={posKaydet} />}
            {sekme === 'banka' && <BankaTablosu v={veri} acik={acik} bankaKaydet={bankaKaydet} />}
            {sekme === 'hareket' && <HareketTablosu v={veri} seciliAdlar={seciliAdlar} />}
            {sekme === 'fark' && <FarkTablosu v={veri} acik={acik} farkKaydet={farkKaydet} />}
          </div>
        </div>
      </>)}
    </div>
  );
}

const GS_STILI = `
.lb-k { margin-left:6px; font-size:10px; }
.lb-alt td { background:var(--zemin-2,#f6f8fb); font-size:11.5px; color:var(--soluk,#5b6b7d); }
.gs-gir { display:inline-flex; gap:4px; align-items:center; }
.gs-gir input { width:96px; text-align:right; border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; padding:1px 5px; font-size:12px; }
.gs-gir button { font-size:11px; padding:1px 6px; }
.hi-tablo td select { border:1px solid var(--cizgi,#cdd6e0); border-radius:3px; font-size:12px; }
.gs-engel { border:1px solid #f1b8b2; background:#fdf1ef; color:#8c1d14; border-radius:6px; padding:8px 12px; margin:6px 0 10px; font-size:12.5px; }
.gs-engel ul { margin:4px 0 0 18px; padding:0; }
.gs-pasif { opacity:.75; }
.a4-t.gs-a4t { font-size:8.5px; margin-bottom:6px; }
.a4-t.gs-a4t th:nth-child(1), .a4-t.gs-a4t td:nth-child(1) { text-align:left; width:22%; }
.a4-t.gs-a4t th:nth-child(2), .a4-t.gs-a4t td:nth-child(2) { text-align:right; }
`;

export default KasaGunSonu;
