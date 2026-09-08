import { useState } from 'react';
import { useOturum } from '../kimlik/OturumBaglami';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { api } from '../api/istemci';
import { type ListeSatiri, hataMetni } from '../api/sozlesme';
import { onay } from '../bilesenler/mesaj';

/**
 * DEPARTMAN / GÖREV ekranı (255, kullanıcı: "Departman listesi ekranını 2'ye
 * böl; solda departman için sadece ekle/düzenle/sil ikonları olsun, diğer
 * butonları ve arama editini kaldır; sağ taraf aynı şekilde görev gridi").
 *
 * İki taraf da aynı desende: başlıkta ＋ ✎ 🗑, altında sade grid. Sol tarafta
 * seçilen departman sağ gridi süzer; bağımsız görevler (departman_id = 0) her
 * departmanda görünür - "Müdür" gibi görevler tek tek her departmana
 * kopyalanmasın diye.
 */
type Taraf = 'departman' | 'gorev';

export function DepartmanGorev() {
  const { kullanici } = useOturum();
  /**
   * RANDEVU KOLONU YALNIZ HBYS'DE (kullanici: "bolum listesinde erp modunda
   * randevu gorunmesin"). "Randevu Bölümü" isareti randevu kartinin bolum
   * listesini suzer; ERP kurulumunda randevu diye bir ekran yok, kolon her
   * satirda anlamsiz bir carpi gosteriyordu.
   */
  const hbys = (kullanici?.urunModu ?? 1) === 2;
  const [departman, setDepartman] = useState<ListeSatiri | null>(null);
  const [gorev, setGorev] = useState<ListeSatiri | null>(null);
  const [kart, setKart] = useState<{ taraf: Taraf; id: number | 'yeni' } | null>(null);
  const [yenile, setYenile] = useState(0);
  const [hata, setHata] = useState('');

  const departmanId = departman ? Number(departman.id) : null;

  const sil = async (taraf: Taraf, satir: ListeSatiri | null) => {
    if (!satir) return;
    const ad = String(satir.ad ?? '');
    if (!await onay(`"${ad}" silinsin mi?`)) return;
    try {
      await api.kartSil(taraf === 'departman' ? 'departman' : 'personel-gorev',
                        Number(satir.id));
      if (taraf === 'departman') setDepartman(null); else setGorev(null);
      setYenile(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) }
  };

  /**
   * İki gridin de araç şeridi: yalnız ＋ ✎ 🗑 (kullanici: "Departmanlar ve
   * Görevler label'larını kaldır") - hangi grid olduğu kolonlardan belli.
   */
  const baslik = (taraf: Taraf, secili: ListeSatiri | null) => (
    <div className="numaralama-bas bitisik">
      <button type="button" className="d" title="Ekle"
              onClick={() => setKart({ taraf, id: 'yeni' })}>＋</button>
      <button type="button" className="d" title="Düzenle" disabled={!secili}
              onClick={() => secili && setKart({ taraf, id: Number(secili.id) })}>✎</button>
      <button type="button" className="d" title="Sil" disabled={!secili}
              onClick={() => void sil(taraf, secili)}>🗑</button>
    </div>
  );

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Bölüm / Görev</h1>
          <span className="yol">Yönetim › Bölüm / Görev</span>
        </div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      <div style={{ display: 'flex', gap: 16, alignItems: 'flex-start' }}>
        <div className="kagrup" style={{ flex: '1 1 0', minWidth: 0 }}>
          {baslik('departman', departman)}
          <GenGrid
            kaynak="departman"
            baslik="Bölümler"
            // gomulu: gridin kendi baslik/yol satiri cizilmez - baslik zaten
            //   ustteki ikon seridinde (＋ ✎ 🗑).
            gomulu
            seritGizli
            boyut={200}
            yenile={yenile}
            gizliKolonlar={hbys ? ['sira'] : ['sira', 'randevuVerilebilir']}
            onSecimDegisti={s => { setDepartman(s); setGorev(null) }}
            onSatirAc={s => setKart({ taraf: 'departman', id: Number(s.id) })}
          />
        </div>

        <div className="kagrup" style={{ flex: '1 1 0', minWidth: 0 }}>
          {baslik('gorev', gorev)}
          <GenGrid
            kaynak="personel-gorev"
            baslik="Görevler"
            gomulu
            seritGizli
            boyut={200}
            yenile={yenile}
            // Departman seçiliyse o departmanın görevleri + bağımsızlar (0):
            //   bağımsız görev her departmanda geçerlidir.
            sabitFiltre={departmanId === null ? undefined : {
              op: 'or',
              kosullar: [
                { alan: 'departmanId', op: 'esit', deger: departmanId },
                { alan: 'departmanId', op: 'esit', deger: 0 },
              ],
            }}
            gizliKolonlar={['sira', 'departmanId']}
            onSecimDegisti={setGorev}
            onSatirAc={s => setKart({ taraf: 'gorev', id: Number(s.id) })}
          />
        </div>
      </div>

      {kart && (
        <GenForm
          kaynak={kart.taraf === 'departman' ? 'departman' : 'personel-gorev'}
          id={kart.id}
          baslik={kart.taraf === 'departman' ? 'Bölüm' : 'Görev'}
          // Yeni gorevde departman BOS gelir (kullanici): gorev cogu zaman
          //   bagimsizdir; departman gerekiyorsa kartta secilir.
          onKapat={() => setKart(null)}
          onKaydedildi={() => { setKart(null); setYenile(t => t + 1) }}
        />
      )}
    </>
  );
}
