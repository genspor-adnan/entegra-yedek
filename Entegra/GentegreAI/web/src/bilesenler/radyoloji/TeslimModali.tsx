import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';
import { c } from '../../dil/ceviri';
import { paraYaz } from '../bicim';

/**
 * SONUC TESLIMI (304). Film / CD / basili rapor kime verildi.
 *
 * Sema (283) vardi ama girisi yoktu. Hasta disinda biri aliyorsa YAKINLIK ve
 * kimlik dogrulamasi kayda gecer: sonuc kisisel saglik verisidir, "kime
 * verdik" sorusunun cevabi belgede durmali.
 */

/**
 * TESLIM KALEMLERI (318): bir teslimde hastaya AYNI ANDA rapor + film + CD
 * verilir - tek "tür" secimi bunu anlatamiyordu. Eski `tur` kolonu geriye
 * donuk uyumluluk icin ilk isaretli kalemden turetilir.
 */
/**
 * DÜZELTME KİPİ (kullanıcı 18.11.2026: "teslim kuyruğunda çift tıklayınca teslim etme bilgisi olan modal açılmalı ki
 * yanlış yazmışsam düzeltebileyim"): istemin daha önce teslimi varsa modal SON TESLİMLE dolu açılır ve kayıt onu
 * düzeltir (PUT; teslim zamanı değişmez). Ayrı bir teslim (ör. CD sonradan verildi) "＋ Yeni teslim" ile girilir.
 */
type Teslim = Record<string, unknown>;
const KALEM_ALANI: Record<string, string> = { rapor: 'raporVerildi', film: 'filmVerildi', cd: 'cdVerildi', dijital: 'dijitalVerildi' };

const KALEMLER = [
  { anahtar: 'rapor',   ad: 'Rapor (basılı)', tur: 2 },
  { anahtar: 'film',    ad: 'Film',           tur: 4 },
  { anahtar: 'cd',      ad: 'CD / DVD',       tur: 3 },
  { anahtar: 'dijital', ad: 'Dijital bağlantı / e-posta', tur: 5 },
] as const;

export function TeslimModali({ istemId, accessionNo, cdIstendi, lab, onKapat, onTamam }: {
  istemId: number;
  /** LAB SATIRI (1396, tek teslim listesi): başvurunun lab bölümü teslim edilir - kalem / düzeltme yok. */
  lab?: { belgeId: number; bolum: number };
  accessionNo?: string;
  /** Kabulde "CD istendi" isaretliyse CD kutusu onden isaretli gelir (311). */
  cdIstendi?: boolean;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [secili, setSecili] = useState<Record<string, boolean>>(
    { rapor: true, film: false, cd: !!cdIstendi, dijital: false });
  const [alanAd, setAlanAd] = useState('');
  const [yakinlik, setYakinlik] = useState('');
  const [kimlik, setKimlik] = useState(true);
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);
  /** Düzeltilen teslim (null = yeni teslim). */
  const [duzeltilen, setDuzeltilen] = useState<Teslim | null>(null);
  const [onceki, setOnceki] = useState<Teslim | null>(null);
  /** Hastanın tahsil edilmemiş borcu (kullanıcı 18.11.2026: teslimde kırmızı uyarı; teslimi engellemez). */
  const [borc, setBorc] = useState<{ acikBorc: number; basvuru: number } | null>(null);

  const doldur = (t: Teslim | null) => {
    setDuzeltilen(t);
    if (t) {
      setSecili(Object.fromEntries(KALEMLER.map(k => [k.anahtar, Number(t[KALEM_ALANI[k.anahtar]]) === 1])));
      setAlanAd(String(t.alanAd ?? ''));
      setYakinlik(String(t.alanYakinlik ?? ''));
      setKimlik(Number(t.kimlikDogrulandi) === 1);
      setAciklama(String(t.aciklama ?? ''));
    } else {
      setSecili({ rapor: true, film: false, cd: !!cdIstendi, dijital: false });
      setAlanAd(''); setYakinlik(''); setKimlik(true); setAciklama('');
    }
  };

  useEffect(() => {
    let iptal = false;
    if (lab) return;
    void api.radyolojiTeslimler(istemId)
      .then(l => { if (!iptal && l.length > 0) { setOnceki(l[0]); doldur(l[0]) } })
      .catch(() => { /* okunamazsa yeni teslim */ });
    void api.radyolojiTeslimDurum(istemId)
      .then(d => { if (!iptal) setBorc(d) })
      .catch(() => { /* uyarı okunamazsa teslim yine yapılır */ });
    return () => { iptal = true };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [istemId]);

  const kaydet = async () => {
    setHata('');
    if (!alanAd.trim()) { setHata('Teslim alan kişi yazılmalı.'); return }
    const isaretli = KALEMLER.filter(k => secili[k.anahtar]);
    if (!lab && isaretli.length === 0) { setHata('En az bir teslim kalemi seçilmeli.'); return }
    setKaydediyor(true);
    try {
      if (lab) {
        await api.labSonucTeslim({ belgeId: lab.belgeId, bolum: lab.bolum, alanAd, alanYakinlik: yakinlik, aciklama });
        mesaj('Teslim kaydedildi.');
        onTamam?.(); onKapat();
        return;
      }
      const govde = {
        // Eski tek-deger kolonu: ilk isaretli kalem (geriye donuk uyum).
        tur: isaretli[0].tur,
        raporVerildi:   secili.rapor ? 1 : 0,
        filmVerildi:    secili.film ? 1 : 0,
        cdVerildi:      secili.cd ? 1 : 0,
        dijitalVerildi: secili.dijital ? 1 : 0,
        alanAd, alanYakinlik: yakinlik,
        kimlikDogrulandi: kimlik ? 1 : 0, aciklama,
      };
      if (duzeltilen) await api.radyolojiTeslimDuzelt(istemId, Number(duzeltilen.id), govde);
      else await api.radyolojiTeslim(istemId, govde);
      mesaj(duzeltilen ? 'Teslim bilgisi düzeltildi.' : 'Teslim kaydedildi.');
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`${duzeltilen ? 'Teslim Düzeltme' : 'Sonuç Teslimi'}${accessionNo ? ` — ${accessionNo}` : ''}`} dar
           onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={kaydediyor}
                       onClick={() => void kaydet()}>{duzeltilen ? '✔ Düzeltmeyi Kaydet' : '✔ Teslim Et'}</button>
               {onceki && (duzeltilen
                 ? <button className="d" onClick={() => doldur(null)}>＋ Yeni teslim</button>
                 : <button className="d" onClick={() => doldur(onceki)}>✎ Son teslimi düzelt</button>)}
               <button className="d" onClick={onKapat}>✖ {c('Kapat')}</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {borc && Number(borc.acikBorc) > 0 && (
        <div className="hata-kutusu" role="alert">
          ⚠ {c('Hastanın tahsil edilmemiş borcu var')}: <b>{paraYaz(Number(borc.acikBorc))}</b>
          {borc.basvuru > 1 ? ` (${borc.basvuru} ${c('başvuruda')})` : ''}. {c('Teslimden önce tahsilatı kontrol edin.')}
        </div>
      )}
      {duzeltilen && (
        <div className="bilgi-kutusu">
          {String(duzeltilen.teslimZamani ?? '').replace('T', ' ').slice(0, 16)} tarihli teslim
          {duzeltilen.teslimEden ? ` (${String(duzeltilen.teslimEden)})` : ''} düzeltiliyor - teslim zamanı değişmez.
        </div>
      )}
      <div className="alan-izgara tek-sutun">
        {!lab && <label className="alan">
          <span className="etiket zorunlu-isaret">{c('Teslim edilen')}</span>
          <span className="deger-serit" style={{ flexWrap: 'wrap', gap: 12 }}>
            {KALEMLER.map(k => (
              <label key={k.anahtar} className="satir-ici">
                <input type="checkbox" checked={!!secili[k.anahtar]}
                       onChange={e => setSecili(s => ({ ...s, [k.anahtar]: e.target.checked }))} />
                {k.ad}
              </label>
            ))}
          </span>
        </label>}
        <label className="alan">
          <span className="etiket zorunlu-isaret">Teslim Alan</span>
          <input value={alanAd} placeholder="Ad Soyad"
                 onChange={e => setAlanAd(e.target.value)} />
        </label>
        {/* Yakinlik yalniz hasta DISINDA biri alirken anlamli - bos gecilebilir. */}
        <label className="alan">
          <span className="etiket">Yakınlık</span>
          <input value={yakinlik} placeholder="örn. Hastanın kendisi / Eşi / Oğlu"
                 onChange={e => setYakinlik(e.target.value)} />
        </label>
        {!lab && <label className="alan">
          <span className="etiket">Kimlik</span>
          <span className="deger-serit">
            <input type="checkbox" checked={kimlik}
                   onChange={e => setKimlik(e.target.checked)} />
            <span>{c('Kimlik doğrulandı')}</span>
          </span>
        </label>}
        <label className="alan">
          <span className="etiket">Açıklama</span>
          <input value={aciklama} onChange={e => setAciklama(e.target.value)} />
        </label>
      </div>
      <div className="not">
        Sonuç kişisel sağlık verisidir: hasta dışında biri alıyorsa yakınlığı ve
        kimlik doğrulamasını mutlaka işaretleyin.
      </div>
    </Modal>
  );
}
