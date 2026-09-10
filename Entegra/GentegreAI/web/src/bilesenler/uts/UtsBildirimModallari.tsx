import { useState } from 'react';
import { Modal } from '../Modal';
import { GenLookup } from '../GenLookup';
import { api } from '../../api/istemci';
import type { UtsMesaji } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';

/**
 * ÜTS ELLE BİLDİRİM FORMLARI (225, Faz 2) - belge köprüsünden gelmeyen tekil
 * işlemler için: VERME (ürünü başka ÜTS kurumuna devir) ve KULLANIM (hastada
 * kullanım). Ekran yalnız API çağırır; ADT tekil/lot kuralı, KUN doğrulaması
 * ve gönderim sunucudadır.
 *
 * Ortak kural (sözleşme): SNO doluysa ürün TEKİL takiplidir - adet gönderilmez;
 * yalnız LNO doluysa LOT takiplidir - adet zorunlu. İkisi de boşsa sunucu
 * alan hatasıyla reddeder.
 */

function MesajSatirlari({ mesajlar }: { mesajlar: UtsMesaji[] }) {
  if (!mesajlar.length) return null;
  return (
    <div style={{ marginTop: 6 }}>
      {mesajlar.map((m, i) => (
        <div key={i}>
          <span className={`rozet ${m.tip === 'HATA' ? 'hata'
                                  : m.tip === 'UYARI' ? 'uyari' : 'bilgi'}`}>
            {m.tip ?? 'BİLGİ'}
          </span>{' '}{m.met ?? ''}{m.kod ? ` (${m.kod})` : ''}
        </div>
      ))}
    </div>
  );
}

/** Ürün + seri/lot + adet - iki formun ortak üst bloğu. */
function UrunAlanlari(p: {
  uno: string; setUno(v: string): void;
  seriNo: string; setSeriNo(v: string): void;
  lotNo: string; setLotNo(v: string): void;
  adet: string; setAdet(v: string): void;
  kilitli: boolean;
}) {
  const tekil = p.seriNo.trim().length > 0;
  return (
    <>
      {/* Stok seçimi UNO'yu doldurur; ÜTS kaydı stok kartındaki Ürün No'dan. */}
      <GenLookup
        kaynak="stok"
        etiket="Stok (ürün no'yu doldurur)"
        alanlar={[{ ad: 'kod', baslik: 'Kod' }, { ad: 'ad', baslik: 'Adı', genis: true },
                  { ad: 'urunNo', baslik: 'Ürün No' }]}
        sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
        deger={undefined}
        saltOkunur={p.kilitli}
        onSec={x => { if (x?.urunNo) p.setUno(String(x.urunNo)) }}
      />
      <label className="alan">
        <span className="etiket zorunlu-isaret">Ürün No (UNO)</span>
        <input value={p.uno} maxLength={23} disabled={p.kilitli}
               onChange={e => p.setUno(e.target.value)} />
      </label>
      <label className="alan">
        <span className="etiket">Seri No (SNO — tekil takip)</span>
        <input value={p.seriNo} maxLength={20} disabled={p.kilitli}
               onChange={e => p.setSeriNo(e.target.value)} />
      </label>
      <label className="alan">
        <span className="etiket">Lot No (LNO — lot takip)</span>
        <input value={p.lotNo} maxLength={20} disabled={p.kilitli}
               onChange={e => p.setLotNo(e.target.value)} />
      </label>
      {!tekil && (
        <label className="alan">
          <span className="etiket">Adet (lot takipte zorunlu)</span>
          <input className="hiza-sag" value={p.adet} disabled={p.kilitli}
                 onChange={e => p.setAdet(e.target.value)} />
        </label>
      )}
    </>
  );
}

// ---------------------------------------------------------------- verme ----
export function UtsKullanimModali({ onKapat, onTamam }: {
  onKapat(): void;
  onTamam(mesaj: string): void;
}) {
  const [uno, setUno] = useState('');
  const [seriNo, setSeriNo] = useState('');
  const [lotNo, setLotNo] = useState('');
  const [adet, setAdet] = useState('1');
  const [git, setGit] = useState(new Date().toISOString().slice(0, 10));
  const [hastaTckn, setHastaTckn] = useState('');
  const [hastaAdi, setHastaAdi] = useState('');
  const [hastaSoyadi, setHastaSoyadi] = useState('');
  const [gonderiyor, setGonderiyor] = useState(false);
  const [hata, setHata] = useState('');
  const [mesajlar, setMesajlar] = useState<UtsMesaji[]>([]);

  const gonder = async () => {
    setGonderiyor(true); setHata(''); setMesajlar([]);
    try {
      const y = await api.utsKullanimBildir({
        uno: uno.trim(), seriNo: seriNo.trim() || undefined,
        lotNo: lotNo.trim() || undefined,
        adet: Number(adet.replace(',', '.')) || 0,
        git: git || undefined,
        hastaTckn: hastaTckn.trim() || undefined,
        hastaAdi: hastaAdi.trim() || undefined,
        hastaSoyadi: hastaSoyadi.trim() || undefined,
      });
      setMesajlar(y.mesajlar);
      if (!y.basarili) { setHata(y.mesaj); return }
      onTamam(y.mesaj);
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setGonderiyor(false);
    }
  };

  return (
    <Modal baslik="ÜTS Kullanım Bildirimi" dar onKapat={onKapat}
      alt={<>
        <button className="d bir" disabled={gonderiyor} onClick={() => void gonder()}>
          {gonderiyor ? 'Gönderiliyor…' : '🧑‍⚕️ ÜTS’ye Bildir'}
        </button>
        <button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                onClick={onKapat}>Kapat</button>
      </>}>
      <div className="alan-izgara tek-sutun" style={{ padding: 10 }}>
        <UrunAlanlari uno={uno} setUno={setUno} seriNo={seriNo} setSeriNo={setSeriNo}
                      lotNo={lotNo} setLotNo={setLotNo} adet={adet} setAdet={setAdet}
                      kilitli={gonderiyor} />
        <label className="alan">
          <span className="etiket zorunlu-isaret">Kullanım Tarihi (GIT)</span>
          <input type="date" value={git} disabled={gonderiyor}
                 onChange={e => setGit(e.target.value)} />
        </label>
        {/* Hasta alanları İLK SÜRÜMDE ELLE - HBYS hasta kartı entegrasyonu
            sonraki iş (plan notu). */}
        <label className="alan">
          <span className="etiket">Hasta TCKN</span>
          <input value={hastaTckn} maxLength={11} disabled={gonderiyor}
                 onChange={e => setHastaTckn(e.target.value)} />
        </label>
        <label className="alan">
          <span className="etiket">Hasta Adı</span>
          <input value={hastaAdi} maxLength={60} disabled={gonderiyor}
                 onChange={e => setHastaAdi(e.target.value)} />
        </label>
        <label className="alan">
          <span className="etiket">Hasta Soyadı</span>
          <input value={hastaSoyadi} maxLength={60} disabled={gonderiyor}
                 onChange={e => setHastaSoyadi(e.target.value)} />
        </label>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <MesajSatirlari mesajlar={mesajlar} />
      </div>
    </Modal>
  );
}
