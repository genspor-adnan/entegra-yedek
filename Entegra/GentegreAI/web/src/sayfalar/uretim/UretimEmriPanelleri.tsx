import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { OnKontrol } from '../../api/uclar/uretimFisi';
import { fisDurumAdi } from '../../api/uclar/uretimFisi';
import { useSekmedeAc } from '../../bilesenler/KartAdi';
import { ImzaPenceresi } from '../../bilesenler/ImzaPenceresi';
import { mesaj } from '../../bilesenler/mesaj';
import { para, sayi, tarihSaat } from '../../bilesenler/bicim';
import { useUretimSeviyesi } from '../../bilesenler/useUretimSeviyesi';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { UEP_STILI } from './uretimStil';

/**
 * ÜRETİM EMRİ KARTI EK SEKMELERİ (1253, mockup uretim_emri_v2.html): "Ön Kontroller" (serbest bırakma ön koşulları,
 * ISO 13485 §7.5.1) ve "Üretim Girişleri" (emre bağlı üretim fişleri - her kısmi giriş ayrı parti). Generic emir kartına
 * kartEklentileri üzerinden eklenir; sunucu sonuçları çizer, ekran karar vermez.
 */
export function EmirOnKontrolSekmesi({ emirId, durum, tazele, onDegisti }: { emirId: number; durum: number; tazele: number; onDegisti?(): void }) {
  const [veri, setVeri] = useState<{ kontroller: OnKontrol[]; serbestOlur: boolean } | null>(null);
  const [hata, setHata] = useState('');
  const [imza, setImza] = useState(false);
  const { aksiyonVar } = useOturum();
  const sv = useUretimSeviyesi();
  useEffect(() => { void api.uretimEmriOnKontrol(emirId).then(setVeri).catch(h => setHata(hataMetni(h))) }, [emirId, tazele]);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;
  return (
    <div style={{ padding: 10 }}>
      <style>{UEP_STILI}</style>
      <p className="uep-not">{c('Serbest bırakma (atölyeye çıkış) ön koşulları. Kırmızı varsa "Serbest Bırak" sunucuda reddedilir; "takip edilmiyor" satırları bu sürümde izlenmeyen kayıtlardır - uydurma "uygun" yazılmaz.')}
        {sv.denetimli ? ` ${c('Denetimli seviyede emir serbest bırakılmadan başlatılamaz.')}` : ` ${c('Standart seviyede serbest bırakma isteğe bağlı adımdır.')}`}</p>
      <table className="uep-dg">
        <thead><tr><th style={{ width: 28 }} /><th>{c('Kontrol')}</th><th>{c('Kural / durum')}</th><th>{c('Sonuç')}</th></tr></thead>
        <tbody>{veri.kontroller.map(k => (
          <tr key={k.kod} className={k.sonuc === 0 ? 'uygunsuz' : ''}>
            <td className="or">{k.sonuc === 1 ? '✔' : k.sonuc === 0 ? '✖' : '·'}</td>
            <td>{k.ad}</td><td className="sl">{k.kural}</td>
            <td><span className={`rz ${k.sonuc === 1 ? 'ok' : k.sonuc === 0 ? 'hata' : 'gri'}`}>{k.sonuc === 1 ? c('Uygun') : k.sonuc === 0 ? c('Uygunsuz') : c('Takip edilmiyor')}</span></td>
          </tr>))}</tbody>
      </table>
      <div className={`uep-imza ${veri.serbestOlur ? '' : 'hata'}`}>
        {durum >= 3 ? `✍ ${c('Emir serbest bırakıldı')}` : veri.serbestOlur ? `✔ ${c('Ön kontroller geçti - "Serbest Bırak" ile atölyeye bırakılabilir (Onaylı emirde).')}` : `⛔ ${c('Ön kontroller geçmedi.')}`}
        {durum === 2 && aksiyonVar('uretim.onayla') && (veri.serbestOlur || !sv.denetimli) && (
          <button type="button" className="d onay" style={{ marginLeft: 10 }} onClick={() => setImza(true)}>🏁 {c('Serbest Bırak…')}</button>)}
      </div>
      {imza && (
        /* SERBEST BIRAKMA (e-imza, anlam "atölyeye serbest bırakıldı"): standartta parola istenmez. */
        <ImzaPenceresi baslik={c('Atölyeye serbest bırak')} parolaIster={sv.denetimli} gerekceZorunlu={sv.denetimli}
          onaylaMetni={() => `🏁 ${c(sv.denetimli ? 'İmzala ve serbest bırak' : 'Serbest bırak')}`}
          aciklama={c('Durum Onaylı → Serbest bırakıldı; sonra "Üretime Başlat". İmza kaydı: ad, zaman, anlam, gerekçe.')}
          onKapat={() => setImza(false)}
          onImzala={async (gerekce, parola) => { const y = await api.uretimEmriSerbestBirak(emirId, gerekce, parola); mesaj(y.mesaj); setImza(false); onDegisti?.() }} />)}
    </div>
  );
}


export function EmirFislerSekmesi({ emirId, tazele }: { emirId: number; tazele: number }) {
  const [fisler, setFisler] = useState<Awaited<ReturnType<typeof api.uretimEmriFisleri>>['fisler'] | null>(null);
  const [hata, setHata] = useState('');
  const sv = useUretimSeviyesi();
  const ac = useSekmedeAc();
  useEffect(() => { void api.uretimEmriFisleri(emirId).then(y => setFisler(y.fisler)).catch(h => setHata(hataMetni(h))) }, [emirId, tazele]);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!fisler) return <div className="yukleniyor">{c('Yükleniyor…')}</div>;
  const toplam = fisler.filter(f => f.durum !== 0).reduce((a, f) => a + f.uretilen, 0);
  return (
    <div style={{ padding: 10 }}>
      <style>{UEP_STILI}</style>
      <p className="uep-not">{c('Her kısmi giriş ayrı üretim fişi (parti). Fiş sarfı düşer, mamulü girer, maliyeti hesaplar; emir sayaçları fişten güncellenir.')}
        {sv.denetimli ? ` ${c('Denetimlide giriş karantinaya alınır; parti kalite onayıyla serbest kalır.')}` : ''}</p>
      <table className="uep-dg">
        <thead><tr><th>{c('Üretim fişi')}</th><th>{c('Tarih')}</th><th>{c('Parti')}</th><th className="sg">{c('Üretilen')}</th><th className="sg">{c('Fire')}</th><th className="sg">{c('Birim maliyet')}</th><th className="sg">{c('Toplam')}</th><th>{c('Durum')}</th></tr></thead>
        <tbody>
          {fisler.map(f => (
            <tr key={f.id} className={f.durum === 0 ? 'ters' : ''}>
              <td><button type="button" className="bag" onClick={() => ac(`/uretim-fisi/${f.id}`)}>{f.no} ↗</button></td>
              <td>{tarihSaat(f.tarih)}</td><td>{f.partiNo || <span className="sl">—</span>}</td>
              <td className="sg">{sayi.format(f.uretilen)}</td><td className="sg">{f.fire ? sayi.format(f.fire) : ''}</td>
              <td className="sg">{para.format(f.birimMaliyet)}</td><td className="sg">{para.format(f.toplam)}</td>
              <td><span className={`rz ${f.durum === 3 ? 'ok' : f.durum === 2 ? (sv.denetimli ? 'uy' : 'ok') : f.durum === 0 || f.durum === 4 ? 'hata' : 'gri'}`}>{fisDurumAdi(f.durum, sv.denetimli ? 'denetimli' : '')}</span></td>
            </tr>))}
          {fisler.length === 0 && <tr><td colSpan={8} className="sl bos">{c('Bu emre bağlı üretim fişi yok. "▶ Üret…" ile kısmi giriş yapın.')}</td></tr>}
          {fisler.length > 0 && <tr className="top"><td colSpan={3}>{c('Toplam')}</td><td className="sg">{sayi.format(toplam)}</td><td colSpan={4} /></tr>}
        </tbody>
      </table>
    </div>
  );
}
