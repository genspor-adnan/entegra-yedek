import type { DetayDurumu, Satir } from './GenDetayTablo';
import type { KartDetayMeta } from '../api/sozlesme';

interface Props {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  onDegis(yeni: DetayDurumu): void;
}

/** "01.09.2019" -> "6 yıl 11 ay" (ik_karti.html mockup "Kıdem" - hesaplanan, saklanmaz). */
function kidemHesapla(tarihStr: string): string | null {
  if (!tarihStr) return null;
  const giris = new Date(tarihStr);
  if (Number.isNaN(giris.getTime())) return null;
  const simdi = new Date();
  let ay = (simdi.getFullYear() - giris.getFullYear()) * 12 + (simdi.getMonth() - giris.getMonth());
  if (simdi.getDate() < giris.getDate()) ay -= 1;
  if (ay < 0) return null;
  const yil = Math.floor(ay / 12);
  const kalanAy = ay % 12;
  return yil > 0 ? `${yil} yıl ${kalanAy} ay` : `${kalanAy} ay`;
}

/**
 * Personel kartı "Özlük Bilgileri" sekmesi (ik_karti.html mockup) — personel_ozluk 1:1
 * (taraf_id UNIQUE) - GRID DEGIL, TEK satır (TekAdres.tsx ile aynı desen). Doğum/Cinsiyet/
 * Medeni Hal/Uyruk/Kan Grubu/Öğrenim mockup'ta GENEL sekmesinde ("Kimlik Bilgileri" kutusu,
 * bkz. PersonelKimlikOzet.tsx) - burada TEKRARLANMAZ, sadece iş/SGK bilgileri var.
 */
export function TekOzluk({ meta, durum, saltOkunur, onDegis }: Props) {
  const satir: Satir = durum.guncel[0] ?? {};

  const degis = (degisiklik: Record<string, unknown>) => {
    const yeniSatir = { ...satir, ...degisiklik };
    const guncel = durum.guncel.length ? [yeniSatir, ...durum.guncel.slice(1)] : [yeniSatir];
    onDegis({ ...durum, guncel });
  };

  const alan = (ad: string) => meta.alanlar.find(a => a.ad === ad);
  const calismaSekliAlan = alan('calismaSekli');
  const sozlesmeTuruAlan = alan('sozlesmeTuru');
  const vardiyaTuruAlan = alan('vardiyaTuru');
  const denemeSuresiAlan = alan('denemeSuresi');
  const yoneticiAlan = alan('yoneticiId');

  const kidem = kidemHesapla(String(satir.iseGirisTarihi ?? ''));

  return (
    <div className="kasira">
      <div className="kagrup">
        <h6>İş Bilgileri</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan tip-kod">
            <span className="etiket">Yönetici</span>
            <select value={String(satir.yoneticiId ?? '')} disabled={saltOkunur}
              onChange={e => degis({ yoneticiId: e.target.value })}>
              <option value="">—</option>
              {yoneticiAlan?.kodlar && Object.entries(yoneticiAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
            </select>
          </label>
          <div className="adres-satir">
            <label className="alan tip-kod">
              <span className="etiket">Çalışma Şekli</span>
              <select value={String(satir.calismaSekli ?? '')} disabled={saltOkunur}
                onChange={e => degis({ calismaSekli: e.target.value })}>
                <option value="">—</option>
                {calismaSekliAlan?.kodlar && Object.entries(calismaSekliAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
              </select>
            </label>
            <label className="alan tip-kod">
              <span className="etiket">Vardiya Türü</span>
              <select value={String(satir.vardiyaTuru ?? '')} disabled={saltOkunur}
                onChange={e => degis({ vardiyaTuru: e.target.value })}>
                <option value="">—</option>
                {vardiyaTuruAlan?.kodlar && Object.entries(vardiyaTuruAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
              </select>
            </label>
          </div>
          <div className="adres-satir">
            <label className="alan tip-kod">
              <span className="etiket">Sözleşme Türü</span>
              <select value={String(satir.sozlesmeTuru ?? '')} disabled={saltOkunur}
                onChange={e => degis({ sozlesmeTuru: e.target.value })}>
                <option value="">—</option>
                {sozlesmeTuruAlan?.kodlar && Object.entries(sozlesmeTuruAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
              </select>
            </label>
            <label className="alan tip-kod">
              <span className="etiket">Deneme Süresi</span>
              <select value={String(satir.denemeSuresi ?? '')} disabled={saltOkunur}
                onChange={e => degis({ denemeSuresi: e.target.value })}>
                <option value="">—</option>
                {denemeSuresiAlan?.kodlar && Object.entries(denemeSuresiAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
              </select>
            </label>
          </div>
        </div>
      </div>
      <div className="kagrup">
        <h6>SGK / Giriş-Çıkış</h6>
        <div className="alan-izgara tek-sutun">
          <div className="adres-satir">
            <label className="alan tip-tarih">
              <span className="etiket">İşe Giriş</span>
              <input type="date" value={String(satir.iseGirisTarihi ?? '')} disabled={saltOkunur}
                onChange={e => degis({ iseGirisTarihi: e.target.value })} />
            </label>
            <label className="alan tip-tarih">
              <span className="etiket">İşten Çıkış</span>
              <input type="date" value={String(satir.istenCikisTarihi ?? '')} disabled={saltOkunur}
                onChange={e => degis({ istenCikisTarihi: e.target.value })} />
            </label>
          </div>
          <div className="adres-satir">
            <label className="alan tip-metin">
              <span className="etiket">SGK Sicil No</span>
              <input value={String(satir.sgkSicilNo ?? '')} disabled={saltOkunur}
                onChange={e => degis({ sgkSicilNo: e.target.value })} />
            </label>
            <label className="alan tip-tarih">
              <span className="etiket">SGK Başlama</span>
              <input type="date" value={String(satir.sgkBaslamaTarihi ?? '')} disabled={saltOkunur}
                onChange={e => degis({ sgkBaslamaTarihi: e.target.value })} />
            </label>
          </div>
          <label className="alan tip-metin">
            <span className="etiket">Meslek Kodu</span>
            <input value={String(satir.meslekKodu ?? '')} disabled={saltOkunur}
              onChange={e => degis({ meslekKodu: e.target.value })} />
          </label>
          {kidem && (
            <label className="alan tip-metin">
              <span className="etiket">Kıdem</span>
              <input value={kidem} disabled readOnly />
            </label>
          )}
        </div>
      </div>
    </div>
  );
}
