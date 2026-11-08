import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { telefonBicimle } from './bicim';
import type { KisiKaydi } from '../api/sozlesme';
import { TarafArama } from './TarafArama';
import { KartAdi } from './KartAdi';
import { onay as onaySor } from './mesaj';
import { c } from '../dil/ceviri';

/**
 * Cari kartı Genel sekmesi > İlgili Kişiler (mockup: cari_karti.html). Sade salt-okunur
 * liste + üst satırda iki düğme (kullanıcı 08.11.2026: "Düzenle ve sil butonları kaldır..
 * Kişi ekle butonu sağına Kaldır butonu ekle.. bu kişinin müşteri ile bağını kaldırsın").
 *
 * UNVAN sütunu görünen ad (sunucu `fn_taraf_ad(unvan, ad, soyad)`: "Av. Ali Kaya" - kişi kartı
 * 1277'den beri ünvan önek + ad / soyad) ve TIKLANINCA KART SEKMEDE açılır (KartAdi; kart
 * sekmesi deseni - gömülü GenForm düzenlemesi kaldırıldı). Sağında ROL (kullanıcı: "unvan sağına
 * rol kolonu"), sonra BÖLÜM/GÖREV tek sütun ("Satınalma / Depo Sorumlusu"). E-posta yok, Durum dar.
 *
 * Satıra tıklamak SEÇER (Kaldır / Ayrıldı o seçime uygulanır). İkisi de kişi kaydını SİLMEZ:
 *  · KALDIR (/kaldir) yanlış eklenen kişi içindir - bağ VE bu kişi-cari geçmişi silinir, satır bir daha gelmez.
 *  · AYRILDI (/kopar, Durum combosuyla aynı) - bağ kopar, dönem kapanır, satır "Ayrıldı" olarak tarihçede kalır.
 */
export function IlgiliKisiler({ tarafId, saltOkunur }: { tarafId: number; saltOkunur: boolean }) {
  const [satirlar, setSatirlar] = useState<KisiKaydi[] | null>(null);
  const [roller, setRoller] = useState<Record<string, string>>({});
  const [seciliId, setSeciliId] = useState<number | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [kisiEkleAcik, setKisiEkleAcik] = useState(false);

  const yenile = () => {
    api.kisiler(tarafId).then(setSatirlar).catch(h => setHata(h instanceof Error ? h.message : String(h)));
  };

  useEffect(() => {
    yenile();
    api.kartAlanlari('kisi').then(m => {
      const alan = m.alanlar.find(a => a.ad === 'rol');
      if (alan?.kodlar) setRoller(alan.kodlar);
    }).catch(() => { /* rol etiketsiz de calisir - kod gorunur */ });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tarafId]);

  const kisiBagla = async (kisiId: number) => {
    try {
      // Basarili baglamada onceki hata mesaji SILINIR: "zaten bir cariye bagli"
      //   uyarisi, sonraki dogru secimden sonra da ekranda kalip kullaniciyi
      //   islem basarisiz sandiriyordu.
      setHata(null);
      setSatirlar(await api.kisiBagla(tarafId, kisiId));
    } catch (h) {
      setHata(h instanceof Error ? h.message : String(h));
    }
  };

  /**
   * İKİ DÜĞME (kullanıcı 08.11.2026: "kaldır dersem - yanlışlıkla eklenmiş olabilir - tümden bağını koparsın;
   * Ayrıldı dersem durum Ayrıldı olsun"):
   *  · KALDIR  = sunucu /kaldir: bağ + kişi-cari geçmişi silinir, satır gridden düşer ve bir daha gelmez.
   *  · AYRILDI = sunucu /kopar: bağ kopar, dönem kapanır, satır "Ayrıldı" olarak tarihçede kalır (Durum combosu ile aynı).
   * Kişi kaydı ikisinde de silinmez. Sil düğmeleri gibi önce sorulur.
   */
  const kaldir = async () => {
    const k = satirlar?.find(x => x.id === seciliId);
    if (!k) return;
    if (!await onaySor(`"${k.unvan}" bu cariden tümden kaldırılsın mı? Geçmiş bağı da silinir; kişi kaydı durur.`)) return;
    setHata(null);
    const onceki = satirlar;
    setSatirlar(s => s?.filter(x => x.id !== k.id) ?? s);
    setSeciliId(null);
    try {
      setSatirlar(await api.kisiKaldir(tarafId, k.id));
    } catch (h) {
      setSatirlar(onceki ?? null);
      setHata(h instanceof Error ? h.message : String(h));
    }
  };
  const ayrildi = async () => {
    const k = satirlar?.find(x => x.id === seciliId);
    if (!k || !k.bagli) return;
    if (!await onaySor(`"${k.unvan}" bu cariden ayrıldı olarak işaretlensin mi?`)) return;
    setHata(null);
    await durumDegis(k, false);
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

  return (
    <div className="kagrup">
      <h6>
        İlgili Kişiler
        {!saltOkunur && (
          <>
            <button type="button" className="d bir" onClick={() => setKisiEkleAcik(true)}>
              🔗 Kişi Ekle
            </button>
            <button type="button" className="d teh" disabled={seciliId === null} onClick={() => void kaldir()}
                    title={c('Yanlış eklenen kişiyi bu cariden tümden kaldır (kayıt silinmez)')}>
              {c('Kaldır')}
            </button>
            <button type="button" className="d" disabled={!satirlar?.find(x => x.id === seciliId)?.bagli}
                    onClick={() => void ayrildi()} title={c('Kişi bu cariden ayrıldı - bağ kopar, tarihçede kalır')}>
              {c('Ayrıldı')}
            </button>
          </>
        )}
      </h6>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      <table className="detay-tablo">
        <thead>
          <tr>
            {/* GENİŞLİKLER (kullanıcı: "unvan az genişlesin bölüm/görev daralsın", sonra "Not durum solunda, unvan
                ve telefon daralt"): Unvan 26%, Bölüm/Görev 20%, Telefon 120px, Not kalan genişlik. */}
            <th style={{ width: '26%' }}>Unvan</th>
            <th style={{ width: 120 }}>Rol</th>
            <th style={{ width: '20%' }}>Bölüm/Görev</th>
            <th style={{ width: 120 }}>Telefon</th>
            <th>Not</th>
            {/* DURUM DAR (kullanıcı: "%50 daraltılabilir"): iki değerli küçük combo, tam sütun boş kalıyordu. */}
            <th style={{ width: 90 }}>Durum</th>
          </tr>
        </thead>
        <tbody>
          {satirlar === null && <tr><td colSpan={6}>Yükleniyor…</td></tr>}
          {satirlar?.length === 0 && <tr><td colSpan={6}>Kayıt yok.</td></tr>}
          {satirlar?.map(k => (
            <tr key={k.id}
              className={k.id === seciliId ? 'secili' : ''}
              onClick={() => setSeciliId(k.id)}
              style={{ cursor: 'pointer' }}
            >
              <td><KartAdi tur="kisi" id={k.id}>{k.unvan}</KartAdi></td>
              <td>{k.rol != null ? (roller[String(k.rol)] ?? k.rol) : ''}</td>
              <td>{[k.departmanAdi, k.gorevAdi ?? k.gorev].filter(Boolean).join(' / ')}</td>
              <td>{telefonBicimle(k.telefon)}</td>
              <td title={k.notlar ?? undefined} style={{ maxWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{k.notlar ?? ''}</td>
              <td style={{ textAlign: 'center' }} onClick={e => e.stopPropagation()}>
                <select
                  className={`rozet-sec ${k.bagli ? 'ok' : 'hata'}`}
                  value={k.bagli ? 'aktif' : 'ayrildi'}
                  disabled={saltOkunur}
                  onChange={e => void durumDegis(k, e.target.value === 'aktif')}
                >
                  <option value="aktif">Aktif</option>
                  <option value="ayrildi">{c('Ayrıldı')}</option>
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
