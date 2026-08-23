import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { KisiKaydi } from '../api/sozlesme';
import { TarafArama } from './TarafArama';
import { GenForm } from './GenForm';

/**
 * Cari kartı Genel sekmesi > İlgili Kişiler (mockup: cari_karti.html). Sade salt-okunur
 * liste + ust satirda 3 buton (kullanici: "arama/liste-grup-analiz/aksiyon-sec-uygula/
 * bağ-kopar KALDIRILACAK, Kişi Ekle yanina Düzenle ve Sil EKLENECEK" - GenGrid'in tam
 * araç çubuğu bu kucuk gomulu alan icin fazla agir kaldi, sade tabloya donuldu).
 *
 * Satira tiklamak SECER (Duzenle/Sil o secime uygulanir). "Sil" kisiyi VERİTABANINDAN
 * SİLMEZ - sadece bu cariden KOPARIR (bag_id=null, kullanıcı: "sadece satırdan silecek").
 */
export function IlgiliKisiler({ tarafId, saltOkunur }: { tarafId: number; saltOkunur: boolean }) {
  const [satirlar, setSatirlar] = useState<KisiKaydi[] | null>(null);
  const [departmanlar, setDepartmanlar] = useState<Record<string, string>>({});
  const [seciliId, setSeciliId] = useState<number | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [kisiEkleAcik, setKisiEkleAcik] = useState(false);
  const [duzenlenenId, setDuzenlenenId] = useState<number | null>(null);

  const yenile = () => {
    api.kisiler(tarafId).then(setSatirlar).catch(h => setHata(h instanceof Error ? h.message : String(h)));
  };

  useEffect(() => {
    yenile();
    api.kartAlanlari('kisi').then(m => {
      const alan = m.alanlar.find(a => a.ad === 'departman');
      if (alan?.kodlar) setDepartmanlar(alan.kodlar);
    }).catch(() => { /* departman etiketsiz de calisir - kod gorunur */ });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tarafId]);

  const kisiBagla = async (kisiId: number) => {
    try {
      setSatirlar(await api.kisiBagla(tarafId, kisiId));
    } catch (h) {
      setHata(h instanceof Error ? h.message : String(h));
    }
  };

  const kopar = async () => {
    if (seciliId === null) return;
    const onceki = satirlar;
    setSatirlar(s => s?.filter(k => k.id !== seciliId) ?? s);
    setSeciliId(null);
    try {
      await api.kisiKopar(tarafId, seciliId);
    } catch (h) {
      setSatirlar(onceki ?? null);
      setHata(h instanceof Error ? h.message : String(h));
    }
  };

  // Durum burada SEÇİLEBİLİR (kullanıcı: "seçilebilsin burada"). "Ayrıldı" seçilirse
  // kişinin bu cariyle bağı taraf_gecmis'te KAPATILIR (kopar); "Aktif" secilirse yeniden
  // baglanir (bagla) - taraf.durum (genel aktif/pasif) ile ILGISI YOK, o ayri bir alan.
  // Satır grid'den ANINDA ÇIKARILMAZ (kullanıcı: "gridden çıkarmasın") - "Ayrıldı" artik
  // taraf_gecmis'te KALICI oldugu icin sonraki yenilemede de ayni sekilde gorunmeye devam eder.
  const durumDegis = async (k: KisiKaydi, bagli: boolean) => {
    const onceki = satirlar;
    setSatirlar(s => s?.map(x => x.id === k.id ? { ...x, bagli } : x) ?? s);
    try {
      const guncel = bagli ? await api.kisiBagla(tarafId, k.id) : await api.kisiKopar(tarafId, k.id);
      setSatirlar(guncel);
    } catch (h) {
      setSatirlar(onceki ?? null);
      setHata(h instanceof Error ? h.message : String(h));
    }
  };

  if (duzenlenenId !== null) {
    return (
      <GenForm
        kaynak="kisi"
        id={duzenlenenId}
        onKapat={() => { setDuzenlenenId(null); yenile() }}
        onKaydedildi={() => { setDuzenlenenId(null); yenile() }}
      />
    );
  }

  return (
    <div className="kagrup">
      <h6>
        İlgili Kişiler
        {!saltOkunur && (
          <>
            <button type="button" className="d bir" onClick={() => setKisiEkleAcik(true)}>
              🔗 Kişi Ekle
            </button>
            <button type="button" className="d" disabled={seciliId === null}
              onClick={() => seciliId !== null && setDuzenlenenId(seciliId)}>
              ✎ Düzenle
            </button>
            <button type="button" className="d teh" disabled={seciliId === null} onClick={() => void kopar()}>
              Sil
            </button>
          </>
        )}
      </h6>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      <table className="detay-tablo">
        <thead>
          <tr>
            <th>Unvan</th>
            <th>Departman</th>
            <th>Görev</th>
            <th>Telefon</th>
            <th>E-posta</th>
            <th>Durum</th>
          </tr>
        </thead>
        <tbody>
          {satirlar === null && <tr><td colSpan={6}>Yükleniyor…</td></tr>}
          {satirlar?.length === 0 && <tr><td colSpan={6}>Kayıt yok.</td></tr>}
          {satirlar?.map(k => (
            <tr key={k.id}
              className={k.id === seciliId ? 'secili' : ''}
              onClick={() => setSeciliId(k.id)}
              onDoubleClick={() => setDuzenlenenId(k.id)}
              style={{ cursor: 'pointer' }}
            >
              <td>{k.unvan}</td>
              <td>{k.departman != null ? (departmanlar[String(k.departman)] ?? k.departman) : ''}</td>
              <td>{k.gorev ?? ''}</td>
              <td>{k.telefon ?? ''}</td>
              <td>{k.eposta ?? ''}</td>
              <td style={{ textAlign: 'center' }} onClick={e => e.stopPropagation()}>
                <select
                  className={`rozet-sec ${k.bagli ? 'ok' : 'hata'}`}
                  value={k.bagli ? 'aktif' : 'ayrildi'}
                  disabled={saltOkunur}
                  onChange={e => void durumDegis(k, e.target.value === 'aktif')}
                >
                  <option value="aktif">Aktif</option>
                  <option value="ayrildi">Ayrıldı</option>
                </select>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <TarafArama
        acik={kisiEkleAcik}
        kaynaklar={['kisi']}
        yerTutucu="Kişi ara…"
        onKapat={() => setKisiEkleAcik(false)}
        onSec={secilen => void kisiBagla(secilen.id)}
      />
    </div>
  );
}
