import { useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { c } from '../dil/ceviri';
import { guvenli, mesaj } from './mesaj';
import { Modal } from './Modal';

type Tip = { id: number; ad: string; vakaTuru: number; calismaYeri: number; disLabId: number | null; tatGun: number };
type Lab = { id: number; ad: string };
type Kap = { materyalTipiId: number | ''; lokalizasyon: string };

const VAKA_TURU: Record<number, string> = { 1: 'Histopatoloji', 2: 'Sitoloji', 3: 'Frozen', 4: 'Konsültasyon' };

/**
 * PATOLOJİ İSTEMİ (1105, mockup Ekranlar/Patoloji/patoloji_istem.html) - muayeneden.
 *
 * Kullanıcı: "hekim istem yapınca başvuruya düşecek.. başvuru kaydı yapılınca patoloji
 * istemi çalışılabilecek". İstem lab / radyolojiyle AYNI kapıdan geçer: başvuruya
 * bekleyen düşer, banko ücretlendirip başvuruyu kaydedince patolojide çalışılır.
 *
 * Klinik bilgi ZORUNLU (dış lab hastayı görmez; elindeki tek bilgi bu form). Ön tanı
 * muayenenin tanısından gelir. Her satır bir kap; ücret ve "nerede" materyal tipinden.
 */
export function PatolojiIstemModal({ muayeneId, onKapat, onKaydedildi }: {
  muayeneId: number;
  onKapat(): void;
  onKaydedildi(): void;
}) {
  const [tipler, setTipler] = useState<Tip[]>([]);
  const [lablar, setLablar] = useState<Lab[]>([]);
  const [klinik, setKlinik] = useState('');
  const [tur, setTur] = useState<number | ''>('');
  const [nerede, setNerede] = useState<number | ''>('');
  const [disLab, setDisLab] = useState<number | ''>('');
  const [acil, setAcil] = useState(false);
  const [kaplar, setKaplar] = useState<Kap[]>([{ materyalTipiId: '', lokalizasyon: '' }]);
  const [kaydediyor, setKaydediyor] = useState(false);

  useEffect(() => {
    void guvenli(async () => {
      // SEÇENEKLER MUAYENE YETKİSİYLE (15.10.2026): tanım listeleri (patoloji.tanim.materyal,
      //   lab.dislab) hekimde yetkisiz -> "yetkiniz yok" + boş combo idi.
      const y = await api.patolojiIstemSecenekleri(muayeneId);
      setTipler(y.tipler);
      setLablar(y.lablar);
    });
  }, []);

  // İlk kabın tipinden öneri: vaka türü ve nerede (değiştirilebilir).
  const ilkTip = useMemo(() => tipler.find(t => t.id === kaplar[0]?.materyalTipiId), [tipler, kaplar]);
  const etkinTur = tur || ilkTip?.vakaTuru || 1;
  const etkinNerede = nerede || ilkTip?.calismaYeri || 1;
  const frozenDisLab = etkinTur === 3 && etkinNerede === 1;

  const kontroller = [
    { tamam: klinik.trim().length > 0, metin: c('Klinik bilgi dolu') },
    { tamam: kaplar.length > 0 && kaplar.every(k => k.materyalTipiId !== ''), metin: c('Her kapta materyal tipi') },
    { tamam: etkinNerede === 2 || lablar.length > 0, metin: c('Patoloji yapan dış laboratuvar tanımlı') },
    { tamam: !frozenDisLab, metin: c('Frozen dış laba gönderilemez (kurum içi)') },
  ];

  const kaydet = async () => {
    if (kontroller.some(k => !k.tamam)) { mesaj(c('Kontrol listesindeki eksikleri tamamlayın.')); return }
    setKaydediyor(true);
    await guvenli(async () => {
      const y = await api.muayeneIstemAc(muayeneId, {
        tur: 7, aciliyet: acil ? 2 : 1, patTur: etkinTur, klinikBilgi: klinik.trim(), nerede: etkinNerede,
        disLabId: etkinNerede === 1 && disLab ? Number(disLab) : undefined,
        materyaller: kaplar.map(k => ({ materyalTipiId: Number(k.materyalTipiId), lokalizasyon: k.lokalizasyon.trim() })),
      });
      mesaj(`${y.mesaj} ${c('Bankoda ücretlendirilip başvuru kaydedilince patolojide çalışılır.')}`);
      onKaydedildi();
    });
    setKaydediyor(false);
  };

  return (
    <Modal baslik={`🔬 ${c('Patoloji İstemi')}`} onKapat={onKapat}
           alt={<>
             <button type="button" className="d bir" disabled={kaydediyor} onClick={() => void kaydet()}>💾 {c('İstemi Kaydet')}</button>
             <button type="button" className="d kapat-dugmesi" onClick={onKapat}>{c('Kapat')}</button>
           </>}>
      <div className="kagrup">
        <h6>{c('Klinik bilgi')} <span className="not">· {c('labın patoloğu tanıyı buna göre koyar · ön tanı muayeneden')}</span></h6>
        <div className="ic">
          <textarea rows={3} style={{ width: '100%' }} value={klinik} autoFocus
                    placeholder={c('Örn. Çekumda kitle, kolonoskopik biyopsi adenokarsinom. Neoadjuvan tedavi almadı.')}
                    onChange={e => setKlinik(e.target.value)} />
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap', marginTop: 8, alignItems: 'center' }}>
            <label>{c('Vaka türü')} <select value={tur} onChange={e => setTur(e.target.value ? Number(e.target.value) : '')}>
              <option value="">{c('Materyalden')} ({c(VAKA_TURU[etkinTur])})</option>
              {Object.entries(VAKA_TURU).map(([k, v]) => <option key={k} value={k}>{c(v)}</option>)}
            </select></label>
            <label>{c('Nerede')} <select value={nerede} onChange={e => setNerede(e.target.value ? Number(e.target.value) : '')}>
              <option value="">{c('Materyalden')} ({etkinNerede === 2 ? c('Kurum içi') : c('Dış lab')})</option>
              <option value="1">🚚 {c('Dış laboratuvar')}</option>
              <option value="2">🏠 {c('Kurum içi')}</option>
            </select></label>
            {etkinNerede === 1 && (
              <label>{c('Laboratuvar')} <select value={disLab} onChange={e => setDisLab(e.target.value ? Number(e.target.value) : '')}>
                <option value="">{c('Varsayılan')}</option>
                {lablar.map(l => <option key={l.id} value={l.id}>{l.ad}</option>)}
              </select></label>
            )}
            <label><input type="checkbox" checked={acil} onChange={e => setAcil(e.target.checked)} /> {c('Acil')}</label>
          </div>
        </div>
      </div>

      <div className="kagrup">
        <h6>{c('Materyaller')} <span className="not">· {c('her satır bir kap · etiket kaba yapıştırılır')}</span>
          <span style={{ marginLeft: 'auto' }} />
          <button type="button" className="d" onClick={() => setKaplar(k => [...k, { materyalTipiId: '', lokalizasyon: '' }])}>＋ {c('Materyal Ekle')}</button>
        </h6>
        <table className="detay-tablo">
          <thead><tr><th style={{ width: 50 }}>{c('Kap')}</th><th>{c('Materyal tipi')}</th><th>{c('Lokalizasyon / not')}</th><th style={{ width: 90 }}>TAT</th><th style={{ width: 40 }} /></tr></thead>
          <tbody>
            {kaplar.map((k, i) => {
              const tip = tipler.find(t => t.id === k.materyalTipiId);
              return (
                <tr key={i}>
                  <td className="hiza-orta"><b>{String.fromCharCode(65 + (i % 26))}</b></td>
                  <td><select style={{ width: '100%' }} value={k.materyalTipiId}
                              onChange={e => setKaplar(ks => ks.map((x, j) => j === i ? { ...x, materyalTipiId: e.target.value ? Number(e.target.value) : '' } : x))}>
                    <option value="">{c('— seçin —')}</option>
                    {tipler.map(t => <option key={t.id} value={t.id}>{t.ad}</option>)}
                  </select></td>
                  <td><input style={{ width: '100%' }} value={k.lokalizasyon}
                             onChange={e => setKaplar(ks => ks.map((x, j) => j === i ? { ...x, lokalizasyon: e.target.value } : x))} /></td>
                  <td className="hiza-orta">{tip ? (tip.tatGun > 0 ? `${tip.tatGun} ${c('iş günü')}` : '—') : ''}</td>
                  <td className="hiza-orta">{kaplar.length > 1 &&
                    <button type="button" className="d sil" title={c('Kabı kaldır')} onClick={() => setKaplar(ks => ks.filter((_, j) => j !== i))}>✕</button>}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <div className="kagrup">
        <h6>{c('Kontrol')} <span className="not">· {c('kayıt öncesi')}</span></h6>
        <div className="ic">
          {kontroller.map((k, i) => <div key={i}>{k.tamam ? '✔' : '⚠'} {k.metin}</div>)}
          <div className="not" style={{ marginTop: 6 }}>{c('Kaydedince başvuruya bekleyen istem olarak düşer; bankoda ücretlendirilip başvuru kaydedilince patolojide çalışılır.')}</div>
        </div>
      </div>
    </Modal>
  );
}
