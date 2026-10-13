import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import type { AktarimProfili } from '../api/uclar/aktarim';
import { mesaj, onay } from './mesaj';

/**
 * KURUM PROFİLİ › VERİ KAYNAĞI (Delphi aktarımı adım 6d, mockup
 * Ekranlar/aktarim_durumu.html sekme 3). GenProfil de bu ekranı paylaşır.
 *
 * Diğer sekmelerden farklı olarak "Kaydet & Uygula"yı BEKLEMEZ: veri kaynağını
 * değiştirmek aktarılan bütün kaynakları salt okunur yapar / açar, ajan anahtarı
 * da üretildiği anda bir kez gösterilir - ikisi de onaylı, tek başına işlem.
 * Web'e dönünce sunucu ajan anahtarlarını pasifleştirir (aktarım fiilen durur).
 */
export function VeriKaynagiPaneli() {
  const [v, setV] = useState<AktarimProfili | null>(null);
  const [hata, setHata] = useState('');
  const [tarih, setTarih] = useState('');
  const [yeniAd, setYeniAd] = useState('');
  const [anahtar, setAnahtar] = useState<string | null>(null);

  const yukle = useCallback(() => {
    api.aktarimProfili().then(p => { setV(p); setTarih(p.hareketBaslangic ?? ''); setHata('') })
      .catch(h => setHata(hataMetni(h)));
  }, []);
  useEffect(() => { yukle() }, [yukle]);

  const kipDegistir = async (k: 'web' | 'delphi') => {
    if (!v || v.veriKaynagi === k) return;
    const soru = k === 'delphi'
      ? 'Veri kaynağı DELPHI ERP olsun mu?\n\nCari, stok, hizmet, belge, kasa ve diğer aktarılan kayıtlar web\'de SALT OKUNUR olur; '
        + 'yeni kayıt Delphi\'de açılır. Web\'e özgü ekler (not, ek belge, görev) açık kalır.'
      : 'Veri kaynağı WEB olsun mu?\n\nAktarılan kayıtlar web\'de yeniden düzenlenebilir olur ve bütün ajan anahtarları PASİF yapılır '
        + '(Delphi\'den aktarım durur; yeniden açmak için yeni anahtar gerekir).';
    if (!await onay(soru)) return;
    try { await api.aktarimProfiliYaz({ veriKaynagi: k }); yukle() } catch (h) { setHata(hataMetni(h)) }
  };

  const tarihKaydet = async () => {
    if (!tarih || tarih === v?.hareketBaslangic) return;
    if (!await onay(`Hareket başlangıcı ${new Date(tarih).toLocaleDateString('tr-TR')} olsun mu?\n\n`
      + 'Belge, kasa ve stok izleme tabloları ajanın bir sonraki turunda bu tarihten YENİDEN yüklenir. '
      + 'Tarih ileri alınırsa önceki hareketler web\'de silinmez.')) return;
    try { await api.aktarimProfiliYaz({ hareketBaslangic: tarih }); yukle() } catch (h) { setHata(hataMetni(h)) }
  };

  const anahtarUret = async () => {
    try { const y = await api.aktarimAjanEkle(yeniAd.trim()); setAnahtar(y.anahtar); setYeniAd(''); yukle() }
    catch (h) { setHata(hataMetni(h)) }
  };

  const pasif = async (id: number, ad: string) => {
    if (!await onay(`"${ad}" ajanı pasif yapılsın mı? Bu anahtarla gelen paketler reddedilir.`)) return;
    try { await api.aktarimAjanPasif(id); yukle() } catch (h) { setHata(hataMetni(h)) }
  };

  const kopyala = async () => {
    if (!anahtar) return;
    try { await navigator.clipboard.writeText(anahtar); mesaj('Anahtar panoya kopyalandı.') }
    catch { mesaj('Kopyalanamadı - anahtarı seçip elle kopyalayın.') }
  };

  if (!v) return <div className="ic">{hata ? <div className="uyari">{hata}</div> : 'Yükleniyor…'}</div>;

  return (
    <div className="vk-kok">
      {hata && <div className="uyari">{hata}</div>}

      <div className="grp">
        <div className="hdr">Veri kaynağı <span className="rz mavi">kurum geneli - bütün şubeler</span></div>
        <div className="ic">
          <label className="vk-sec">
            <input type="radio" checked={v.veriKaynagi === 'web'} onChange={() => void kipDegistir('web')} />
            <b>Web</b> <span className="sonuk">(veriler bu sistemde girilir)</span>
          </label>
          <label className="vk-sec">
            <input type="radio" checked={v.veriKaynagi === 'delphi'} onChange={() => void kipDegistir('delphi')} />
            <b>Delphi ERP</b> <span className="sonuk">(aktarım ajanıyla, tek yön - aktarılan kayıtlar salt okunur)</span>
          </label>
          <div className="vk-satir">
            <span className="vk-et">Hareket başlangıcı</span>
            <input type="date" className="vk-inp" value={tarih} onChange={e => setTarih(e.target.value)} />
            <div className={`btn${!tarih || tarih === v.hareketBaslangic ? ' pas' : ''}`} onClick={() => void tarihKaydet()}>Uygula</div>
            <span className="sonuk">Belge, kasa ve stok izleme bu tarihten aktarılır; tanımların hepsi gelir.</span>
          </div>
          <div className="vk-satir">
            <span className="vk-et">Şube eşlemesi</span>
            <span>{v.subeEsleme.length
              ? v.subeEsleme.map(e => `Delphi şube ${e.delphiSube} → ${e.subeAd}`).join(' · ')
              : <span className="sonuk">eşleme yok</span>}
              {' '}<span className="sonuk">· eşlenmeyen → {v.varsayilanSube ?? '—'}</span></span>
          </div>
        </div>
      </div>

      <div className="grp">
        <div className="hdr">Ajan anahtarları</div>
        <div className="dg"><table>
          <thead><tr><th>Ad</th><th>Oluşturma</th><th>Son nabız</th><th>Sürüm</th><th>Durum</th><th /></tr></thead>
          <tbody>
            {v.ajanlar.length === 0 && <tr><td colSpan={6} className="sonuk">Henüz ajan yok.</td></tr>}
            {v.ajanlar.map(a => (
              <tr key={a.id} className={a.aktif ? '' : 'sonuk'}>
                <td>{a.ad}</td>
                <td>{new Date(a.olusturma).toLocaleDateString('tr-TR')}</td>
                <td>{a.sonNabiz ? new Date(a.sonNabiz).toLocaleString('tr-TR') : '—'}</td>
                <td>{a.surum ?? '—'}</td>
                <td>{a.aktif ? <span className="rz ok">Aktif</span> : <span className="rz pas">Pasif</span>}</td>
                <td>{a.aktif === 1 && <div className="btn" style={{ display: 'inline-flex' }} onClick={() => void pasif(a.id, a.ad)}>Pasif yap</div>}</td>
              </tr>
            ))}
          </tbody>
        </table></div>
        <div className="ic vk-satir">
          <input className="vk-inp" placeholder="Ajan adı (ör. Merkez sunucusu)" value={yeniAd} onChange={e => setYeniAd(e.target.value)} />
          <div className={`btn primary${v.veriKaynagi !== 'delphi' ? ' pas' : ''}`}
               title={v.veriKaynagi !== 'delphi' ? 'Önce veri kaynağını Delphi ERP yapın' : undefined}
               onClick={() => v.veriKaynagi === 'delphi' && void anahtarUret()}>＋ Yeni anahtar üret</div>
        </div>
        {anahtar && (
          <div className="ic">
            <div className="sonuk">Anahtar <b>yalnız şimdi</b> görünür, sistemde saklanmaz (yalnız özeti). Ajanın <code>ajan.json</code>'una
              yazın, sonra <code>GentegreAktarimAjani --sifrele</code>.</div>
            <div className="vk-anahtar">
              <code>{anahtar}</code>
              <div className="btn" onClick={() => void kopyala()}>Kopyala</div>
              <div className="btn" onClick={() => setAnahtar(null)}>Gizle</div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
