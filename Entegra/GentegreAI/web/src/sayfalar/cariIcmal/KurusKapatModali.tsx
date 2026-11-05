import { useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CariIcmal, CariIcmalSatiri } from '../../api/uclar/cariIcmal';
import { para, paraYaz } from '../../bilesenler/bicim';
import { GenLookup } from '../../bilesenler/GenLookup';
import { Modal } from '../../bilesenler/Modal';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { bugunYerel } from '../yaslandirma/yaslandirmaOrtak';

/**
 * KURUŞ FARKI KAPATMA (1269, kullanıcı 05.11.2026: "10 kuruştan küçük bakiyeli kayıtlar kalabalık oluyor" → "1 ve 2").
 * Eşik altındaki her cariye bir kasa işlemi yazılır: borçluya 60 (cari alacak + gider kalemi), alacaklıya 62
 * (cari borç + gelir kalemi). Onay ekranı listeyi ve toplamı gösterir; kalemler Genel Ayarlar'dan ön dolu gelir,
 * burada değiştirilebilir. Yazılan işlemler normal kasa işlemidir (ekstre, log, iptal).
 */
const LOOKUP_KALEM = [{ ad: 'kod', baslik: 'Kod' }, { ad: 'ad', baslik: 'Ad', genis: true }];

export function KurusKapatModali({ v, kucukler, kapsam, temsilci, onKapat, onTamam }: {
  v: CariIcmal; kucukler: CariIcmalSatiri[]; kapsam: string; temsilci: number;
  onKapat(): void; onTamam(): void;
}) {
  const [esik, setEsik] = useState(v.kucuk.esik);
  const [tarih, setTarih] = useState(bugunYerel());
  const [gider, setGider] = useState<{ id: number; ad: string } | null>(v.kucuk.giderId > 0 ? { id: v.kucuk.giderId, ad: v.kucuk.giderAdi } : null);
  const [gelir, setGelir] = useState<{ id: number; ad: string } | null>(v.kucuk.gelirId > 0 ? { id: v.kucuk.gelirId, ad: v.kucuk.gelirAdi } : null);
  const [aciklama, setAciklama] = useState('Kuruş farkı kapatma');
  const [yaziliyor, setYaziliyor] = useState(false);
  const [hata, setHata] = useState('');

  // Önizleme ekrandaki satırlardan (sunucu aynı kümeyi aynı eşikle yeniden hesaplar).
  const hedef = kucukler.filter(c => Math.abs(c.bakiye) < esik);
  const borclu = hedef.filter(c => c.bakiye > 0), alacakli = hedef.filter(c => c.bakiye < 0);
  const giderGerek = borclu.length > 0 && !gider, gelirGerek = alacakli.length > 0 && !gelir;

  const kapat = async () => {
    if (hedef.length === 0) { mesaj('Eşik altında kapatılacak cari yok.'); return }
    if (giderGerek || gelirGerek) { setHata('Borçlu için gider, alacaklı için gelir kalemi seçin.'); return }
    if (!await onay(`${hedef.length} cariye kuruş farkı işlemi yazılacak (toplam ${paraYaz(hedef.reduce((s, c) => s + c.bakiye, 0))}). `
                  + 'İşlemler kasa listesinde görünür, gerekirse tek tek iptal edilir. Onaylıyor musunuz?')) return;
    setYaziliyor(true); setHata('');
    try {
      const s = await api.kurusKapat({ esik, tarih, giderId: gider?.id, gelirId: gelir?.id, aciklama, kapsam, temsilci: temsilci || undefined });
      mesaj(`${s.yazilan} cari kapatıldı (toplam ${paraYaz(s.toplam)})${s.hata ? ` · ${s.hata} cari yazılamadı: ${s.hatalar.join(' | ')}` : ''}`);
      onTamam();
    } catch (h) { setHata(hataMetni(h)) }
    finally { setYaziliyor(false) }
  };

  return (
    <Modal baslik="Kuruş Farklarını Kapat" onKapat={onKapat} enUst dar
           alt={<>
             <button type="button" className="d" onClick={onKapat}>Vazgeç</button>
             <button type="button" className="d bir" disabled={yaziliyor || hedef.length === 0} onClick={kapat}>
               {yaziliyor ? 'Yazılıyor…' : `${hedef.length} cariyi kapat`}</button>
           </>}>
      <div className="kk-alan">
        <label>Eşik (TL, altı)</label>
        <input type="number" step="0.01" min="0.01" max="10" value={esik}
               onChange={e => setEsik(Math.max(0.01, Math.min(10, Number(e.target.value) || 0)))} />
        <label>İşlem tarihi</label>
        <input type="date" value={tarih} max={bugunYerel()} onChange={e => e.target.value && setTarih(e.target.value)} />
        <label>Gider kalemi (borçlu)</label>
        <GenLookup kaynak="masraf" alanlar={LOOKUP_KALEM} deger={gider?.ad} zorunlu={borclu.length > 0}
                   hata={giderGerek && hata ? 'Zorunlu' : undefined}
                   onSec={x => setGider(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)} />
        <label>Gelir kalemi (alacaklı)</label>
        <GenLookup kaynak="hizmet" alanlar={LOOKUP_KALEM} deger={gelir?.ad} zorunlu={alacakli.length > 0}
                   hata={gelirGerek && hata ? 'Zorunlu' : undefined}
                   onSec={x => setGelir(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)} />
        <label>Açıklama</label>
        <input type="text" maxLength={200} value={aciklama} onChange={e => setAciklama(e.target.value)} />
      </div>
      <div className="kk-ozet">
        <b>{hedef.length}</b> cari · {borclu.length} borçlu ({paraYaz(borclu.reduce((s, c) => s + c.bakiye, 0))}) gider kalemine,
        {' '}{alacakli.length} alacaklı ({paraYaz(-alacakli.reduce((s, c) => s + c.bakiye, 0))}) gelir kalemine yazılır.
        Kalemleri kalıcı yapmak için Genel Ayarlar › İcmal Eşikleri (cari.kurus_gider_id / cari.kurus_gelir_id).
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="kk-liste">
        <table>
          <thead><tr><th>Kod</th><th>Ünvan</th><th className="sag">Bakiye</th><th>İşlem</th></tr></thead>
          <tbody>
            {hedef.map(c => (
              <tr key={c.id}><td>{c.kod}</td><td>{c.ad}</td>
                <td className="sag">{para.format(c.bakiye)}</td>
                <td>{c.bakiye > 0 ? 'Gider (60)' : 'Gelir (62)'}</td></tr>
            ))}
            {hedef.length === 0 && <tr><td colSpan={4}>Eşik altında cari yok.</td></tr>}
          </tbody>
        </table>
      </div>
    </Modal>
  );
}
