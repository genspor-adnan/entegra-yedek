import { useState } from 'react';
import { api } from '../api/istemci';
import { type ListeSatiri } from '../api/sozlesme';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';

const SEKMELER = [
  { anahtar: 'genel',       baslik: 'Genel' },
  { anahtar: 'entegrasyon', baslik: 'Entegrasyon' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * KAYIT KABUL AYARLARI (336) — Yönetim › Ayarlar › Kayıt Kabul.
 *
 * "Entegrasyon" sekmesi dış servis hesaplarını tek yerde toplar (kullanıcı):
 * SKRS/Sağlık.NET, e-Nabız, MEDULA, ÜTS, e-Belge, SMS. Her satır bir
 * (entegrasyon · şube · ortam) üçlüsüdür; şubesi boş kayıt kurum genelidir.
 *
 * Şifreler listede GÖSTERİLMEZ - yalnız "dolu mu" işareti; gerçek değer
 * kartı açan yetkili kullanıcıya gider.
 */
export function KayitKabulAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const [kart, setKart] = useState<number | 'yeni' | null>(null);
  const [yenile, setYenile] = useState(0);
  const [hata, setHata] = useState<string | null>(null);

  async function aksiyon(kod: string, satir: ListeSatiri | null) {
    setHata(null);
    switch (kod) {
      case 'entegrasyon.yeni':    setKart('yeni'); return;
      case 'entegrasyon.duzenle': if (satir) setKart(Number(satir.id)); return;
      case 'entegrasyon.sil':
        if (!satir) return;
        if (!await onay(`"${String(satir.kodAdi ?? satir.kod ?? '')}" hesabı silinecek. `
                        + 'Onaylıyor musunuz?')) return;
        await guvenli(async () => {
          await api.kartSil('entegrasyon-hesap', Number(satir.id));
          setYenile(t => t + 1);
        });
        return;
      // BAGLANTI SINAMA: kimlik dogru mu, adres ayakta mi - kayit degismez.
      case 'entegrasyon.sina':
        if (!satir) return;
        await guvenli(async () => {
          const y = await api.entegrasyonSina(Number(satir.id));
          mesaj(y.mesaj);
          setYenile(t => t + 1);
        });
        return;
      // SKRS listelerini servisten cekip YEREL kod listelerini tazeler.
      case 'entegrasyon.skrs-senkron':
        if (!satir) return;
        if (String(satir.kod ?? '') !== 'SKRS') {
          mesaj('Bu işlem yalnız SKRS hesabında çalışır.');
          return;
        }
        if (!await onay('SKRS kod listeleri servisten çekilip yerel listeler '
                        + 'güncellenecek. Devam edilsin mi?')) return;
        await guvenli(async () => {
          const y = await api.skrsListeSenkron(Number(satir.id));
          mesaj(y.mesaj);
          setYenile(t => t + 1);
        });
        return;
    }
  }

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kayıt Kabul Ayarları</h1>
          <span className="yol">Yönetim › Ayarlar › Kayıt Kabul</span>
        </div>
      </div>

      <div className="katab">
        {SEKMELER.map(s => (
          <div key={s.anahtar}
               className={`kat${s.anahtar === aktif ? ' on' : ''}`}
               onClick={() => setAktif(s.anahtar)}>
            {s.baslik}
          </div>
        ))}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {aktif === 'genel' && (
        <div className="kagrup">
          <h6>Genel</h6>
          <div className="not">
            Kayıt kabul davranış ayarları (protokol numarası, varsayılan
            başvuru türü…) buraya gelecek. Dış servis hesapları
            <b> Entegrasyon</b> sekmesinde.
          </div>
        </div>
      )}

      {aktif === 'entegrasyon' && (
        <GenGrid
          key="entegrasyon"
          kaynak="entegrasyon-hesap"
          gomulu
          seritGizli
          aracCubuguSol
          aksiyonEkrani="entegrasyon-liste"
          yenile={yenile}
          onSatirAc={satir => setKart(Number(satir.id))}
          onAksiyon={(kod, satir) => { void aksiyon(kod, satir) }}
        />
      )}

      {kart !== null && (
        <GenForm
          kaynak="entegrasyon-hesap"
          id={kart}
          baslik="Entegrasyon Hesabı"
          onKapat={() => setKart(null)}
          onKaydedildi={() => { setKart(null); setYenile(t => t + 1) }}
        />
      )}
    </>
  );
}
