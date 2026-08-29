import { useEffect, useRef, useState, type ReactNode } from 'react';
import type { DetayDurumu, Satir } from './GenDetayTablo';
import type { KartAlanMeta, KartDetayMeta } from '../api/sozlesme';
import { useYerler, VARSAYILAN_ULKE } from './yerlerHook';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { TekOzluk } from './TekOzluk';
import { KartKullaniciRolu } from './KartKullaniciRolu';
import { KartKullaniciSubeleri } from './KartKullaniciSubeleri';

interface Props {
  kartAdi?: string;
  vknoAlan: KartAlanMeta;
  vkno: string;
  onVknoDegis(v: string): void;
  gorevAlan: KartAlanMeta;
  gorev: string;
  onGorevDegis(v: string): void;
  ozlukMeta: KartDetayMeta;
  ozlukDurum: DetayDurumu;
  saltOkunur: boolean;
  onOzlukDegis(yeni: DetayDurumu): void;
  egitimler?: ReactNode;
  fotoSolEk?: ReactNode;
  fotoSolEkOnce?: boolean;
  ozetGizli?: boolean;
  /** "Çalıştığı Şube" alani (taraf.sube_id) - is bilgilerinde cizilir. */
  subeAlan?: KartAlanMeta;
  sube?: string;
  onSubeDegis?(v: string): void;
  vknoGizli?: boolean;
  kimlikSutunGenisligi?: string;
  /** Yeni kayıtta henüz yok; kart kaydedilmeden dosya yüklenemez. */
  kaynakId?: number;
}

/** "01.09.2019" -> "6 yıl 11 ay" */

/** "14.06.1992" -> "33 yaş" */
function yasHesapla(tarihStr: string): string | null {
  const dogum = new Date(tarihStr);
  if (!tarihStr || Number.isNaN(dogum.getTime())) return null;
  const simdi = new Date();
  let yas = simdi.getFullYear() - dogum.getFullYear();
  const ayFarki = simdi.getMonth() - dogum.getMonth();
  if (ayFarki < 0 || (ayFarki === 0 && simdi.getDate() < dogum.getDate())) yas -= 1;
  return yas >= 0 ? `${yas} yaş` : null;
}

/**
 * Personel/Hasta kartı Genel sekmesi kimlik özeti. TCKN/Görev taraf alanlarından,
 * diğer kimlik alanları 1:1 detay kaydından gelir.
 */
export function PersonelKimlikOzet({
  kartAdi = 'personel', vknoAlan, vkno, onVknoDegis,
  ozlukMeta, ozlukDurum, saltOkunur, onOzlukDegis, egitimler, fotoSolEk, ozetGizli,
  subeAlan, sube, onSubeDegis,
  vknoGizli, kimlikSutunGenisligi, kaynakId, fotoSolEkOnce = false,
}: Props) {
  const yerler = useYerler(true);
  const [resimUrl, setResimUrl] = useState<string | null>(null);
  const [resimYukleniyor, setResimYukleniyor] = useState(false);
  const [resimHata, setResimHata] = useState<string | null>(null);
  const resimGirdiRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (!kaynakId) { setResimUrl(null); return }
    let iptal = false;
    api.dokumanlar(kartAdi, kaynakId)
      .then(satirlar => {
        const varsayilan = satirlar.find(s => s.varsayilan && s.contentType.startsWith('image/'));
        if (!varsayilan) return;
        return api.dokumanIcerikUrl(varsayilan.id).then(url => { if (!iptal) setResimUrl(url) });
      })
      .catch(() => { /* fotoğraf yoksa placeholder kalır */ });
    return () => { iptal = true };
  }, [kaynakId, kartAdi]);

  const resimSecildi = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const dosya = e.target.files?.[0];
    e.target.value = '';
    if (!dosya || !kaynakId) return;
    setResimYukleniyor(true);
    setResimHata(null);
    try {
      const satirlar = await api.dokumanYukle(kartAdi, kaynakId, dosya, true);
      const varsayilan = satirlar.find(s => s.varsayilan && s.contentType.startsWith('image/'));
      if (varsayilan) setResimUrl(await api.dokumanIcerikUrl(varsayilan.id));
    } catch (h) {
      setResimHata(hataMetni(h));
    } finally {
      setResimYukleniyor(false);
    }
  };

  const satir: Satir = { uyruk: VARSAYILAN_ULKE, ...(ozlukDurum.guncel[0] ?? {}) };

  const ozlukDegis = (degisiklik: Record<string, unknown>) => {
    const yeniSatir = { ...satir, ...degisiklik };
    const guncel = ozlukDurum.guncel.length ? [yeniSatir, ...ozlukDurum.guncel.slice(1)] : [yeniSatir];
    onOzlukDegis({ ...ozlukDurum, guncel });
  };

  const alan = (ad: string) => ozlukMeta.alanlar.find(a => a.ad === ad);
  const cinsiyetAlan = alan('cinsiyet');
  const medeniHalAlan = alan('medeniHal');
  const kanGrubuAlan = alan('kanGrubu');
  const meslekAlan = alan('meslek');

  const yas = yasHesapla(String(satir.dogumTarihi ?? ''));

  return (
    // "etiket-sag": kart govdesindeki alan etiketleri saga yaslanir (kullanici);
    //   kimlik seridi (.kaid) bu sarmalayicinin DISINDA, orada etiketler solda.
    <div className="kasira etiket-sag">
      {fotoSolEkOnce && fotoSolEk}
      <div className="kasutun"
           style={{ flex: kimlikSutunGenisligi ? `0 0 ${kimlikSutunGenisligi}` : 1,
                    minWidth: 0 }}>
        <div className="kagrup">
          <h6>Kimlik Bilgileri</h6>
          <div className="alan-izgara tek-sutun">
            <div className="adres-satir">
              {!vknoGizli && (
                <label className="alan tip-metin">
                  <span className="etiket">{vknoAlan.baslik}{vknoAlan.zorunlu && ' *'}</span>
                  <input value={vkno} maxLength={vknoAlan.enFazlaUzunluk ?? undefined} disabled={saltOkunur}
                    onChange={e => onVknoDegis(e.target.value)} />
                </label>
              )}
              {/* ROL burada (kullanici: gorev ile yer degistirdi) - gorev
                  kimlik seridinde. Kullanici hesabi yoksa alan cizilmez. */}
              {!ozetGizli && kaynakId && (
                <KartKullaniciRolu sade kartId={kaynakId} saltOkunur={saltOkunur} />
              )}
            </div>
            <div className="adres-satir">
              <label className="alan tip-tarih">
                <span className="etiket">Doğum Tarihi *</span>
                <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                  <input type="date" value={String(satir.dogumTarihi ?? '').slice(0, 10)} disabled={saltOkunur}
                    onChange={e => ozlukDegis({ dogumTarihi: e.target.value })} />
                  {yas && <span style={{ fontSize: 10, color: 'var(--soluk)', whiteSpace: 'nowrap' }}>{yas}</span>}
                </div>
              </label>
              <label className="alan tip-metin">
                <span className="etiket">Doğum Yeri</span>
                <input value={String(satir.dogumYeri ?? '')} disabled={saltOkunur}
                  onChange={e => ozlukDegis({ dogumYeri: e.target.value })} />
              </label>
            </div>
            <div className="adres-satir">
              <label className="alan tip-kod">
                <span className="etiket">Cinsiyet</span>
                <select value={String(satir.cinsiyet ?? '')} disabled={saltOkunur}
                  onChange={e => ozlukDegis({ cinsiyet: e.target.value })}>
                  <option value="">-</option>
                  {cinsiyetAlan?.kodlar && Object.entries(cinsiyetAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                </select>
              </label>
              {meslekAlan && (
                <label className="alan tip-kod">
                  <span className="etiket">Meslek</span>
                  <select value={String(satir.meslek ?? '')} disabled={saltOkunur}
                    onChange={e => ozlukDegis({ meslek: e.target.value })}>
                    <option value="">-</option>
                    {meslekAlan.kodlar && Object.entries(meslekAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                  </select>
                </label>
              )}
              {medeniHalAlan && (
                <label className="alan tip-kod">
                  <span className="etiket">Medeni Hal</span>
                  <select value={String(satir.medeniHal ?? '')} disabled={saltOkunur}
                    onChange={e => ozlukDegis({ medeniHal: e.target.value })}>
                    <option value="">-</option>
                    {medeniHalAlan.kodlar && Object.entries(medeniHalAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                  </select>
                </label>
              )}
            </div>
            <div className="adres-satir">
              <label className="alan tip-kod">
                <span className="etiket">Uyruk</span>
                <select value={String(satir.uyruk ?? '')} disabled={saltOkunur}
                  onChange={e => ozlukDegis({ uyruk: e.target.value })}>
                  {(yerler?.ulkeler ?? []).map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
                </select>
              </label>
              <label className="alan tip-kod">
                <span className="etiket">Kan Grubu</span>
                <select value={String(satir.kanGrubu ?? '')} disabled={saltOkunur}
                  onChange={e => ozlukDegis({ kanGrubu: e.target.value })}>
                  <option value="">-</option>
                  {kanGrubuAlan?.kodlar && Object.entries(kanGrubuAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                </select>
              </label>
            </div>
          </div>
        </div>
        {egitimler}
      </div>
      {/* Özlük ("İş Bilgileri") kimlik kutusunun SAGINDA, alanlar alt alta
          (kullanici) - eskiden ayri sekmedeydi. Hasta kartinda ozluk yok. */}
      {!ozetGizli && (
        <div className="kasutun" style={{ flex: 1, minWidth: 0 }}>
          <TekOzluk meta={ozlukMeta} durum={ozlukDurum} saltOkunur={saltOkunur}
                    onDegis={onOzlukDegis}
                    subeEk={subeAlan && onSubeDegis ? (
                      <label className="alan tip-kod">
                        <span className="etiket">{subeAlan.baslik}</span>
                        <select value={sube ?? ''} disabled={saltOkunur}
                                onChange={e => onSubeDegis(e.target.value)}>
                          <option value="">-</option>
                          {subeAlan.kodlar && Object.entries(subeAlan.kodlar)
                            .map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                        </select>
                      </label>
                    ) : undefined} />
        </div>
      )}
      {!fotoSolEkOnce && fotoSolEk}
      {/* Foto sutunu is bilgilerinin HEMEN saginda (kullanici) - araya bosluk
          birakan saga yaslama kaldirildi, uc sutun bitisik akiyor. */}
      <div className="kasutun" style={{ flex: '0 0 210px' }}>
        <div className="kagrup kagrup-resim">
          <h6>Fotoğraf</h6>
          {!saltOkunur && kaynakId && (
            <input ref={resimGirdiRef} type="file" style={{ display: 'none' }}
              accept="image/jpeg,image/png,image/webp,image/gif" onChange={e => void resimSecildi(e)} />
          )}
          <div
            className="resim-kutusu"
            title={!kaynakId ? 'Kart kaydedilmeden resim eklenemez' : saltOkunur ? undefined : 'Resim eklemek için tıklayın'}
            style={{ cursor: !saltOkunur && kaynakId ? 'pointer' : 'default', overflow: 'hidden' }}
            onClick={() => { if (!saltOkunur && kaynakId) resimGirdiRef.current?.click() }}
          >
            {resimYukleniyor
              ? '...'
              : resimUrl
                ? <img src={resimUrl} alt="Fotoğraf" style={{ width: '100%', height: '100%', objectFit: 'contain' }} />
                : 'Resim'}
          </div>
          {resimHata && <div className="alan-hata" style={{ margin: '4px 10px 0' }}>{resimHata}</div>}
        </div>
        {/* Yetkili subeler FOTOGRAFIN ALTINDA (kullanici). */}
        {!ozetGizli && kaynakId && (
          <KartKullaniciSubeleri kartId={kaynakId} saltOkunur={saltOkunur}
                                 zorunluSubeId={Number(sube) || undefined} />
        )}

        {/* Kullanici rolu (kullanici): karta bagli kullanici hesabinin rolu -
            gorulur ve degistirilebilir. Yeni kayitta id yok, gosterilmez. */}

      </div>
    </div>
  );
}
