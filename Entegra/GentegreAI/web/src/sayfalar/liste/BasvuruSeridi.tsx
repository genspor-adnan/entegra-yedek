import { BolumSuzgeci } from '../../bilesenler/BolumSuzgeci';
import { TARIH_ON_AYARLAR, type TarihOnAyar } from './tarihAralik';
import type { BasvuruSuzgeci } from './useBasvuruSuzgeci';
import { c } from '../../dil/ceviri';

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
      <select className="kat-suzgec" value={s.tarih} title={c('Tarih aralığı')}
              onChange={e => s.setTarih(e.target.value as TarihOnAyar | '')}>
        <option value="">{c('Tüm Tarihler')}</option>
        {TARIH_ON_AYARLAR.map(t => (
          <option key={t.deger} value={t.deger}>{t.ad}</option>
        ))}
      </select>
      <span className="durumseg-ayrac" />
      <select className="kat-suzgec" value={s.tamamlanma} title={c('Tamamlanmaya göre süz')}
              onChange={e => s.setTamamlanma(e.target.value as '' | 'tamam' | 'devam')}>
        <option value="">{c('Tamamlanma: Tümü')}</option>
        <option value="tamam">{c('Tamamlandı (%100)')}</option>
        <option value="devam">{c('Devam Ediyor')}</option>
      </select>
      <select className="kat-suzgec" value={s.tahsilat} title={c('Tahsilat durumuna göre süz')}
              onChange={e => s.setTahsilat(e.target.value as '' | '0' | '1' | '2')}>
        <option value="">{c('Tahsilat: Tümü')}</option>
        <option value="2">{c('Tahsil Edildi')}</option>
        <option value="1">{c('Kısmi Tahsilat')}</option>
        <option value="0">{c('Tahsilat Yok')}</option>
      </select>
      {/* Eski cipler: belgenin fis/faturaya DONUSUM durumu. */}
      <select className="kat-suzgec" value={s.donusum} title={c('Dönüşüm durumuna göre süz')}
              onChange={e => s.setDonusum(e.target.value as '' | '0' | '1' | '2')}>
        <option value="">{c('Dönüşüm: Tümü')}</option>
        <option value="0">Açık</option>
        <option value="1">Kısmi</option>
        <option value="2">{c('Kapanan')}</option>
      </select>
      <select className="kat-suzgec" value={s.odeyen} title={c('Ödeyen kuruma göre süz')}
              onChange={e => s.setOdeyen(e.target.value ? Number(e.target.value) : '')}>
        <option value="">{c('Tüm Kurumlar')}</option>
        {s.kurumlar.map(k => (
          <option key={k.id} value={k.id}>{k.ad} ({k.adet})</option>
        ))}
      </select>
      <BolumSuzgeci
        deger={s.bolum?.id ?? null}
        izinliIdler={s.bolumler.map(x => x.id)}
        onDegis={(id, agac) => s.setBolum(id === null ? null : { id, agac })}
      />
      <select className="kat-suzgec" value={s.doktor} title={c('Doktora göre süz')}
              onChange={e => s.setDoktor(e.target.value ? Number(e.target.value) : '')}>
        <option value="">{c('Tüm Doktorlar')}</option>
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
