import { useState } from 'react';
import { onay } from '../mesaj';
import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { GenGrid } from '../GenGrid';
import { GenForm } from '../GenForm';

/**
 * e-BELGE SERI KURALLARI — Delphi "Seri Bilgileri" gridinin karsiligi
 * (UOpsiyonFatura > TabSeri). Belgenin IC numarasi degil, GIB'e giden SERI kodu.
 *
 * Ayarlar ekranindan Firma Bilgileri'ne TASINDI (kullanici): seri mukellefe
 * baglidir - entegrator hesabi, mukellefiyet ve seriler ayni ekranda durmali.
 * Bilesen olarak ayrildi ki tasinirken mantik kopyalanmasin.
 */
export function SeriKurallari() {
  /** Acik seri kurali karti ("yeni" = ekleme). */
  const [kart, setKart] = useState<number | 'yeni' | null>(null);
  const [yenile, setYenile] = useState(0);
  /** Gridde secili kural - Duzenle/Sil bunu kullanir. */
  const [secili, setSecili] = useState<ListeSatiri | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const sil = async () => {
    if (!secili) return;
    const ad = `${secili.seri ?? ''}`.trim();
    if (!await onay(`"${ad}" seri kuralı silinecek. Onaylıyor musunuz?`, true)) return;
    setHata(null);
    try {
      await api.kartSil('ebelge-seri', Number(secili.id));
      setSecili(null);
      setYenile(t => t + 1);
    } catch (h) { setHata(hataMetni(h)) }
  };

  return (
    <>
      <div className="kagrup">
        {/* Ikonlar basligin HEMEN saginda (kullanici) - saga yaslanmis halde
            baslikla arasindaki bosluk ikisini ayri iki ogeye cevirmisti. */}
        <div className="numaralama-bas bitisik">
          <h6>Seri Kuralları</h6>
          {/* Duzenle ve Sil satir secimi ister; secim yokken pasif, sebebi title'da. */}
          <span className="baslik-eylem">
            <button className="d bir ikon-dugme" title="Yeni seri kuralı"
                    onClick={() => setKart('yeni')}>＋</button>
            <button className="d ikon-dugme" disabled={!secili}
                    title={secili ? 'Seçili kuralı düzenle' : 'Önce satır seçin'}
                    onClick={() => secili && setKart(Number(secili.id))}>✎</button>
            <button className="d teh ikon-dugme" disabled={!secili}
                    title={secili ? 'Seçili kuralı sil' : 'Önce satır seçin'}
                    onClick={() => { void sil() }}>🗑</button>
          </span>
        </div>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <GenGrid
          key={`ebelge-seri-${yenile}`}
          kaynak="ebelge-seri"
          gomulu
          seritGizli
          boyut={25}
          onSatirAc={satir => setKart(Number(satir.id))}
          onSecimDegisti={setSecili}
        />
        <div className="not">
          Belge gönderilirken bu kurallardan <b>uyanı</b> seçilir: önce
          kullanıcıya özel, sonra senaryoya özel, sonra genel kural; eşitlikte
          <b> Sıra</b> küçük olan kazanır. Senaryo ve Kullanıcı boş bırakılırsa
          kural her senaryoda / her kullanıcıda geçerlidir.
        </div>
      </div>

      {kart !== null && (
        <GenForm
          kaynak="ebelge-seri"
          id={kart}
          baslik="e-Belge Seri Kuralı"
          onKapat={() => setKart(null)}
          onKaydedildi={() => { setKart(null); setYenile(t => t + 1) }}
        />
      )}
    </>
  );
}
