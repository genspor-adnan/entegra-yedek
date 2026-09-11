import { BolumSuzgeci } from '../../bilesenler/BolumSuzgeci';
import { TARIH_ON_AYARLAR, type TarihOnAyar } from './tarihAralik';
import type { BasvuruSuzgeci } from './useBasvuruSuzgeci';

/**
 * BASVURU SERIDI (kullanici): serit "Sık" dugmesinin hemen saginda TARIH
 * ARALIGI ile baslar - listeyi once tarihe gore daraltmak en sik yapilan is;
 * combolarin arasinda kaldiginda aranıyordu. Sonra Tamamlanma / Tahsilat /
 * Dönüşüm, ardindan Odeyen, Bolum, Doktor.
 *
 * Secimlerin kendisi `useBasvuruSuzgeci` kancasinda; burasi yalniz cizim.
 */
export function BasvuruSeridi({ s }: { s: BasvuruSuzgeci }) {
  return (
    <>
      <select className="kat-suzgec" value={s.tarih} title="Tarih aralığı"
              onChange={e => s.setTarih(e.target.value as TarihOnAyar | '')}>
        <option value="">Tüm Tarihler</option>
        {TARIH_ON_AYARLAR.map(t => (
          <option key={t.deger} value={t.deger}>{t.ad}</option>
        ))}
      </select>
      <span className="durumseg-ayrac" />
      <select className="kat-suzgec" value={s.tamamlanma} title="Tamamlanmaya göre süz"
              onChange={e => s.setTamamlanma(e.target.value as '' | 'tamam' | 'devam')}>
        <option value="">Tamamlanma: Tümü</option>
        <option value="tamam">Tamamlandı (%100)</option>
        <option value="devam">Devam Ediyor</option>
      </select>
      <select className="kat-suzgec" value={s.tahsilat} title="Tahsilat durumuna göre süz"
              onChange={e => s.setTahsilat(e.target.value as '' | '0' | '1' | '2')}>
        <option value="">Tahsilat: Tümü</option>
        <option value="2">Tahsil Edildi</option>
        <option value="1">Kısmi Tahsilat</option>
        <option value="0">Tahsilat Yok</option>
      </select>
      {/* Eski cipler: belgenin fis/faturaya DONUSUM durumu. */}
      <select className="kat-suzgec" value={s.donusum} title="Dönüşüm durumuna göre süz"
              onChange={e => s.setDonusum(e.target.value as '' | '0' | '1' | '2')}>
        <option value="">Dönüşüm: Tümü</option>
        <option value="0">Açık</option>
        <option value="1">Kısmi</option>
        <option value="2">Kapanan</option>
      </select>
      <select className="kat-suzgec" value={s.odeyen} title="Ödeyen kuruma göre süz"
              onChange={e => s.setOdeyen(e.target.value ? Number(e.target.value) : '')}>
        <option value="">Tüm Kurumlar</option>
        {s.kurumlar.map(k => (
          <option key={k.id} value={k.id}>{k.ad} ({k.adet})</option>
        ))}
      </select>
      <BolumSuzgeci
        deger={s.bolum?.id ?? null}
        izinliIdler={s.bolumler.map(x => x.id)}
        onDegis={(id, agac) => s.setBolum(id === null ? null : { id, agac })}
      />
      <select className="kat-suzgec" value={s.doktor} title="Doktora göre süz"
              onChange={e => s.setDoktor(e.target.value ? Number(e.target.value) : '')}>
        <option value="">Tüm Doktorlar</option>
        {s.doktorlar.map(d => (
          <option key={d.id} value={d.id}>{d.ad} ({d.adet})</option>
        ))}
      </select>
      {s.secimVar && (
        <button type="button" className="kapat" title="Başvuru filtrelerini kaldır (tarih bugüne döner)"
                onClick={s.sifirla}>×</button>
      )}
    </>
  );
}
