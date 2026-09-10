import { useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import type { UtsMesaji } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { GenLookup } from '../GenLookup';

/**
 * ÜTS ÜRETİM / İTHALAT / KAYIP-HEK / İMHA bildirimleri (229) - dördü aynı
 * iskelet: ürün bloğu + türe özgü birkaç alan. "＋ Bildirim ▾" menüsünden
 * açılır. Tür seçenek listeleri sözleşmeden (HEK s74, İmha GRK s83).
 */

const HEK_TURLERI = [
  ['HEK', 'HEK (Hurda/Enkaz/Köhne)'], ['DOGAL_AFET', 'Doğal Afet'],
  ['YANGIN', 'Yangın'], ['CALINMA', 'Çalınma'],
  ['STOK_DUZELTME', 'Stok Düzeltme'], ['DIGER', 'Diğer'],
] as const;

const IMHA_GEREKCELERI = [
  ['KURUM_KARARI', 'Kurum Kararı'],
  ['GONULLU_GERI_CEKME', 'Gönüllü Geri Çekme'],
  ['SON_KULLANMA_TARIHI_GECMIS', 'Son Kullanma Tarihi Geçmiş'],
  ['SAHTE_KACAK', 'Sahte / Kaçak'],
  ['TASIMA_VE_SAKLAMA_KOSULLARI_BOZULMUS', 'Taşıma/Saklama Koşulları Bozulmuş'],
  ['HASTANIN_VUCUDUNDAN_CIKARILMIS', 'Hastanın Vücudundan Çıkarılmış'],
  ['DIGER', 'Diğer'],
] as const;

export type UtsBildirimTuru = 'uretim' | 'ithalat' | 'hek' | 'imha';

const TUR_BASLIK: Record<UtsBildirimTuru, string> = {
  uretim: 'ÜTS Üretim Bildirimi', ithalat: 'ÜTS İthalat Bildirimi',
  hek: 'ÜTS Kayıp / HEK Bildirimi', imha: 'ÜTS İmha / Bertaraf Bildirimi',
};

export function UtsGenelBildirimModali({ tur, onKapat, onTamam }: {
  tur: UtsBildirimTuru;
  onKapat(): void;
  onTamam(mesaj: string): void;
}) {
  const [uno, setUno] = useState('');
  const [seriNo, setSeriNo] = useState('');
  const [lotNo, setLotNo] = useState('');
  const [adet, setAdet] = useState('1');
  const [urt, setUrt] = useState('');
  const [skt, setSkt] = useState('');
  const [ithalUlke, setIthalUlke] = useState('');
  const [menseiUlke, setMenseiUlke] = useState('792');
  const [gumrukBeyanname, setGumrukBeyanname] = useState('');
  const [hekTuru, setHekTuru] = useState('HEK');
  const [gerekce, setGerekce] = useState('KURUM_KARARI');
  const [digerAciklama, setDigerAciklama] = useState('');
  const [belgeNo, setBelgeNo] = useState('');
  const [gonderiyor, setGonderiyor] = useState(false);
  const [hata, setHata] = useState('');
  const [mesajlar, setMesajlar] = useState<UtsMesaji[]>([]);

  const tekil = seriNo.trim().length > 0;

  const gonder = async () => {
    setGonderiyor(true); setHata(''); setMesajlar([]);
    try {
      const ortak = {
        uno: uno.trim(), seriNo: seriNo.trim() || undefined,
        lotNo: lotNo.trim() || undefined,
        adet: Number(adet.replace(',', '.')) || 0,
      };
      const y = tur === 'uretim'
        ? await api.utsUretimBildir({ ...ortak,
            urt: urt || undefined, skt: skt || undefined })
        : tur === 'ithalat'
        ? await api.utsIthalatBildir({ ...ortak,
            urt: urt || undefined, skt: skt || undefined,
            ithalUlke: Number(ithalUlke) || undefined,
            menseiUlke: Number(menseiUlke) || undefined,
            gumrukBeyanname: gumrukBeyanname.trim() || undefined })
        : tur === 'hek'
        ? await api.utsHekBildir({ ...ortak, tur: hekTuru,
            digerAciklama: digerAciklama.trim() || undefined })
        : await api.utsImhaBildir({ ...ortak, gerekce,
            digerAciklama: digerAciklama.trim() || undefined,
            belgeNo: belgeNo.trim() });
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
    <Modal baslik={TUR_BASLIK[tur]} dar onKapat={onKapat}
      alt={<>
        <button className="d bir" disabled={gonderiyor} onClick={() => void gonder()}>
          {gonderiyor ? 'Gönderiliyor…' : 'ÜTS’ye Bildir'}
        </button>
        <button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                onClick={onKapat}>Kapat</button>
      </>}>
      <div className="alan-izgara tek-sutun" style={{ padding: 10 }}>
        {/* Ürün bloğu: stok araması UNO'yu doldurur. */}
        <GenLookup
          kaynak="stok"
          etiket="Stok (ürün no'yu doldurur)"
          alanlar={[{ ad: 'kod', baslik: 'Kod' },
                    { ad: 'ad', baslik: 'Adı', genis: true },
                    { ad: 'urunNo', baslik: 'Ürün No' }]}
          sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
          deger={undefined}
          saltOkunur={gonderiyor}
          onSec={x => { if (x?.urunNo) setUno(String(x.urunNo)) }}
        />
        <label className="alan">
          <span className="etiket zorunlu-isaret">Ürün No (UNO)</span>
          <input value={uno} maxLength={23} disabled={gonderiyor}
                 onChange={e => setUno(e.target.value)} />
        </label>
        <label className="alan">
          <span className="etiket">Seri No (SNO — tekil takip)</span>
          <input value={seriNo} maxLength={20} disabled={gonderiyor}
                 onChange={e => setSeriNo(e.target.value)} />
        </label>
        <label className="alan">
          <span className="etiket">Lot No (LNO — lot takip)</span>
          <input value={lotNo} maxLength={20} disabled={gonderiyor}
                 onChange={e => setLotNo(e.target.value)} />
        </label>
        {!tekil && (
          <label className="alan">
            <span className="etiket">Adet (lot takipte zorunlu)</span>
            <input className="hiza-sag" value={adet} disabled={gonderiyor}
                   onChange={e => setAdet(e.target.value)} />
          </label>
        )}

        {(tur === 'uretim' || tur === 'ithalat') && (
          <>
            <label className="alan">
              <span className="etiket zorunlu-isaret">Üretim Tarihi (ÜRT)</span>
              <input type="date" value={urt} disabled={gonderiyor}
                     onChange={e => setUrt(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">Son Kullanma (SKT)</span>
              <input type="date" value={skt} disabled={gonderiyor}
                     onChange={e => setSkt(e.target.value)} />
            </label>
          </>
        )}

        {tur === 'ithalat' && (
          <>
            <label className="alan">
              <span className="etiket zorunlu-isaret">İthal Edildiği Ülke (IEU)</span>
              <input value={ithalUlke} maxLength={3} disabled={gonderiyor}
                     placeholder="ÜTS ülke kodu (örn. 276 Almanya)"
                     onChange={e => setIthalUlke(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket zorunlu-isaret">Menşei Ülke (MEU)</span>
              <input value={menseiUlke} maxLength={3} disabled={gonderiyor}
                     placeholder="Türkiye 792"
                     onChange={e => setMenseiUlke(e.target.value)} />
            </label>
            <label className="alan">
              <span className="etiket">Gümrük Beyanname No</span>
              <input value={gumrukBeyanname} maxLength={16} disabled={gonderiyor}
                     onChange={e => setGumrukBeyanname(e.target.value)} />
            </label>
          </>
        )}

        {tur === 'hek' && (
          <label className="alan">
            <span className="etiket zorunlu-isaret">Türü</span>
            <select value={hekTuru} disabled={gonderiyor}
                    onChange={e => setHekTuru(e.target.value)}>
              {HEK_TURLERI.map(([k, a]) => <option key={k} value={k}>{a}</option>)}
            </select>
          </label>
        )}

        {tur === 'imha' && (
          <>
            <label className="alan">
              <span className="etiket zorunlu-isaret">Gerekçe</span>
              <select value={gerekce} disabled={gonderiyor}
                      onChange={e => setGerekce(e.target.value)}>
                {IMHA_GEREKCELERI.map(([k, a]) => <option key={k} value={k}>{a}</option>)}
              </select>
            </label>
            <label className="alan">
              <span className="etiket zorunlu-isaret">İmha/Bertaraf Belge No</span>
              <input value={belgeNo} maxLength={50} disabled={gonderiyor}
                     onChange={e => setBelgeNo(e.target.value)} />
            </label>
          </>
        )}

        {((tur === 'hek' && hekTuru === 'DIGER')
          || (tur === 'imha' && gerekce === 'DIGER')) && (
          <label className="alan">
            <span className="etiket zorunlu-isaret">Diğer Açıklaması</span>
            <input value={digerAciklama} maxLength={50} disabled={gonderiyor}
                   onChange={e => setDigerAciklama(e.target.value)} />
          </label>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}
        {mesajlar.length > 0 && (
          <div>
            {mesajlar.map((m, i) => (
              <div key={i}>
                <span className={`rozet ${m.tip === 'HATA' ? 'hata'
                                        : m.tip === 'UYARI' ? 'uyari' : 'bilgi'}`}>
                  {m.tip ?? 'BİLGİ'}
                </span>{' '}{m.met ?? ''}{m.kod ? ` (${m.kod})` : ''}
              </div>
            ))}
          </div>
        )}
      </div>
    </Modal>
  );
}
