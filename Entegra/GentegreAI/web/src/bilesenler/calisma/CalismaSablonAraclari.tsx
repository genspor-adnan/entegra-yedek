import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';
import { Modal } from '../Modal';
import { guvenli, mesaj, onay } from '../mesaj';

/**
 * CALISMA SABLONLARI LISTESI ARACLARI (mockup Ekranlar/Randevu/
 * calisma_sablonu_karti.html - liste arac cubugu). Eski "Randevu Ayarlari"
 * ekraninin yerini alir:
 *   * 🏥 Bolum: bir bolumu randevuya ac (isaretli doktorlara "Standart hafta"
 *     sablonu varsayilan duzenle) ya da kapat (bolumun sablonlari pasif).
 *   * ⚙ Varsayilanlar: yeni sablonun varsayilan gun / blok / slot duzeni ve
 *     randevu kurallari (mesai disi, izinli doktor: engelle / yalniz uyar).
 * Kural ve yazma sunucuda; burasi yalniz secimi toplar.
 */
const GUNLER = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const SLOTLAR = [10, 15, 20, 30, 45, 60];

export function CalismaSablonAraclari({ onDegisti }: { onDegisti(): void }) {
  const [bolumAcik, setBolumAcik] = useState(false);
  const [varsayilanAcik, setVarsayilanAcik] = useState(false);
  return (
    <>
      <button type="button" className="d" title={c('Bir bölümü randevuya toplu aç / kapat')}
              onClick={() => setBolumAcik(true)}>🏥 {c('Bölüm')}</button>
      <button type="button" className="d" title={c('Yeni şablonun varsayılan düzeni ve randevu kuralları')}
              onClick={() => setVarsayilanAcik(true)}>⚙ {c('Varsayılanlar')}</button>
      {bolumAcik && <BolumPenceresi onKapat={() => setBolumAcik(false)} onDegisti={onDegisti} />}
      {varsayilanAcik && <VarsayilanPenceresi onKapat={() => setVarsayilanAcik(false)} />}
    </>
  );
}

// ------------------------------------------------------------- 🏥 BOLUM ----
function BolumPenceresi({ onKapat, onDegisti }: { onKapat(): void; onDegisti(): void }) {
  const [bolumler, setBolumler] = useState<{ id: number; ad: string }[]>([]);
  const [bolum, setBolum] = useState<number | ''>('');
  const [doktorlar, setDoktorlar] = useState<{ id: number; ad: string; sablonVar: boolean }[] | null>(null);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [hata, setHata] = useState('');

  useEffect(() => {
    api.liste('departman', { sayfa: 1, boyut: 500, sirala: [{ alan: 'ad', yon: 'asc' }] })
      .then(y => setBolumler(y.satirlar.map(r => ({ id: Number(r.id), ad: String(r.ad ?? '') }))))
      .catch(h => setHata(hataMetni(h)));
  }, []);

  useEffect(() => {
    if (bolum === '') { setDoktorlar(null); return }
    let iptal = false;
    api.randevuBolumDoktorlari(bolum)
      .then(y => {
        if (iptal) return;
        setDoktorlar(y.doktorlar);
        // Varsayilan: sablonu OLMAYAN doktorlar isaretli (acilacaklar).
        setSecili(new Set(y.doktorlar.filter(d => !d.sablonVar).map(d => d.id)));
      })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [bolum]);

  const ac = () => guvenli(async () => {
    if (bolum === '') return;
    const y = await api.randevuBolumIsaretle(bolum, true, [...secili]);
    mesaj(doktorlar?.length
      ? `${y.eklenen} ${c('doktora "Standart hafta" şablonu açıldı.')}`
      : c('Bölümde doktor yok - randevusuz kabul olarak işaretlendi.'));
    onDegisti(); onKapat();
  });

  const kapat = () => guvenli(async () => {
    if (bolum === '') return;
    if (!await onay(c('Bölümdeki bütün aktif çalışma şablonları pasife alınacak; bu bölüme yeni randevu verilemez. Devam edilsin mi?'), true)) return;
    await api.randevuBolumIsaretle(bolum, false);
    mesaj(c('Bölüm randevuya kapatıldı.'));
    onDegisti(); onKapat();
  });

  const acilacak = (doktorlar ?? []).filter(d => !d.sablonVar);

  return (
    <Modal baslik={`🏥 ${c('Bölümü randevuya aç / kapat')}`} dar enUst buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d teh" disabled={bolum === ''} onClick={() => void kapat()}>
               ⏸ {c('Bölümü randevuya kapat')}</button>
             <button type="button" className="d bir"
                     disabled={bolum === '' || (acilacak.length > 0 && secili.size === 0)}
                     onClick={() => void ac()}>✔ {c('Randevuya aç')}</button>
             <button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
           </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="cs-pencere">
        <label className="cs-alan">{c('Bölüm')}
          <select value={bolum} onChange={e => setBolum(e.target.value ? Number(e.target.value) : '')}>
            <option value="">{c('Seçin…')}</option>
            {bolumler.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}
          </select>
        </label>
        {doktorlar !== null && (
          <div className="cs-alan">
            <span>{c('Bu bölümdeki doktorlar')}</span>
            {doktorlar.length === 0 && <span className="not">{c('Doktor yok - bölüm randevusuz kabul olarak açılır.')}</span>}
            {doktorlar.map(d => (
              <label key={d.id} className="cs-onay">
                <input type="checkbox" disabled={d.sablonVar}
                       checked={d.sablonVar ? false : secili.has(d.id)}
                       onChange={e => setSecili(s => {
                         const y = new Set(s);
                         if (e.target.checked) y.add(d.id); else y.delete(d.id);
                         return y;
                       })} />
                {d.ad}
                <span className="not">— {d.sablonVar ? c('zaten aktif şablonu var') : c('şablonu yok, açılacak')}</span>
              </label>
            ))}
          </div>
        )}
        <div className="not">{c('Seçili her doktora "Standart hafta" şablonu varsayılan düzenle (⚙ Varsayılanlar) açılır; sonra kartından düzenlenir.')}</div>
      </div>
    </Modal>
  );
}

// ------------------------------------------------------ ⚙ VARSAYILANLAR ----
interface Varsayilan {
  gunler: number[];
  bas: string; ogleBas: string; ogleBit: string; bit: string;
  slot: number;
  mesaiDisi: string; izinli: string;
}

const ANAHTAR = {
  gunler: 'randevu.calisma_gunleri', bas: 'randevu.baslangic_saat', bit: 'randevu.bitis_saat',
  ogleBas: 'randevu.ogle_baslangic', ogleBit: 'randevu.ogle_bitis', slot: 'randevu.slot_dk',
  mesaiDisi: 'randevu.mesai_disi', izinli: 'randevu.izinli_hekim',
} as const;

function VarsayilanPenceresi({ onKapat }: { onKapat(): void }) {
  const [v, setV] = useState<Varsayilan | null>(null);
  const [ilk, setIlk] = useState<Record<string, string>>({});
  const [hata, setHata] = useState('');

  useEffect(() => {
    api.ayarlar().then(liste => {
      const al = (a: string, vs: string) => liste.find(x => x.anahtar === a)?.deger || vs;
      const ham: Record<string, string> = {};
      Object.values(ANAHTAR).forEach(a => { ham[a] = liste.find(x => x.anahtar === a)?.deger ?? '' });
      setIlk(ham);
      setV({
        gunler: al(ANAHTAR.gunler, '1,2,3,4,5').split(',').map(Number).filter(x => x >= 1 && x <= 7),
        bas: al(ANAHTAR.bas, '09:00'), bit: al(ANAHTAR.bit, '18:00'),
        ogleBas: al(ANAHTAR.ogleBas, ''), ogleBit: al(ANAHTAR.ogleBit, ''),
        slot: Number(al(ANAHTAR.slot, '15')) || 15,
        mesaiDisi: al(ANAHTAR.mesaiDisi, '0'), izinli: al(ANAHTAR.izinli, '0'),
      });
    }).catch(h => setHata(hataMetni(h)));
  }, []);

  const kaydet = () => guvenli(async () => {
    if (!v) return;
    const saat = /^\d{2}:\d{2}$/;
    if (!saat.test(v.bas) || !saat.test(v.bit) || (v.ogleBas && !saat.test(v.ogleBas)) || (v.ogleBit && !saat.test(v.ogleBit)))
      throw new Error(c('Saatler SS:DD biçiminde olmalı (ör. 09:00).'));
    if (!!v.ogleBas !== !!v.ogleBit) throw new Error(c('Öğle arası için iki saat de girilmeli ya da ikisi de boş kalmalı.'));
    if (v.gunler.length === 0) throw new Error(c('En az bir gün seçin.'));
    const yeni: Record<string, string> = {
      [ANAHTAR.gunler]: [...v.gunler].sort().join(','), [ANAHTAR.bas]: v.bas, [ANAHTAR.bit]: v.bit,
      [ANAHTAR.ogleBas]: v.ogleBas, [ANAHTAR.ogleBit]: v.ogleBit, [ANAHTAR.slot]: String(v.slot),
      [ANAHTAR.mesaiDisi]: v.mesaiDisi, [ANAHTAR.izinli]: v.izinli,
    };
    // Yalniz degisenler yazilir (her ayar ayri kayit, ayri log satiri).
    for (const [a, d] of Object.entries(yeni)) if (d !== ilk[a]) await api.ayarYaz(a, d);
    mesaj(c('Varsayılanlar kaydedildi.'));
    onKapat();
  });

  const kural = (anahtar: 'mesaiDisi' | 'izinli') => v && (
    <div className="cipler">
      {[['0', 'Engelle'], ['1', 'Yalnız uyar']].map(([k, ad]) => (
        <button key={k} type="button" className={`cip${v[anahtar] === k ? ' on' : ''}`}
                onClick={() => setV({ ...v, [anahtar]: k })}>{c(ad)}</button>
      ))}
    </div>
  );

  return (
    <Modal baslik={`⚙ ${c('Varsayılanlar ve kurallar')}`} dar enUst buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d bir" disabled={!v} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>
             <button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
           </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!v ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
        <div className="cs-pencere">
          <h6>{c('Yeni şablonun varsayılanı')}</h6>
          <div className="cs-alan"><span>{c('Günler')}</span>
            <div className="cs-gunler">
              {GUNLER.map((g, i) => (
                <button key={g} type="button" className={`cs-gun${v.gunler.includes(i + 1) ? ' on' : ''}`}
                        onClick={() => setV({ ...v, gunler: v.gunler.includes(i + 1)
                          ? v.gunler.filter(x => x !== i + 1) : [...v.gunler, i + 1] })}>{c(g)}</button>
              ))}
            </div>
          </div>
          <div className="cs-alan"><span>{c('Bloklar (öğle arası boş bırakılırsa tek blok)')}</span>
            <div className="cs-blok">
              <input value={v.bas} onChange={e => setV({ ...v, bas: e.target.value })} placeholder="09:00" />
              <span>–</span>
              <input value={v.ogleBas} onChange={e => setV({ ...v, ogleBas: e.target.value })} placeholder={c('öğle')} />
              <span className="cs-ara" />
              <input value={v.ogleBit} onChange={e => setV({ ...v, ogleBit: e.target.value })} placeholder={c('öğle')} />
              <span>–</span>
              <input value={v.bit} onChange={e => setV({ ...v, bit: e.target.value })} placeholder="18:00" />
            </div>
          </div>
          <div className="cs-alan"><span>{c('Slot')}</span>
            <div className="cipler">
              {SLOTLAR.map(s => (
                <button key={s} type="button" className={`cip${v.slot === s ? ' on' : ''}`}
                        onClick={() => setV({ ...v, slot: s })}>{s} dk</button>
              ))}
            </div>
          </div>
          <h6>{c('Randevu kuralları')}</h6>
          <div className="cs-alan"><span>{c('Mesai dışına randevu')}</span>{kural('mesaiDisi')}</div>
          <div className="cs-alan"><span>{c('İzinli doktora randevu')}</span>{kural('izinli')}</div>
        </div>
      )}
    </Modal>
  );
}
