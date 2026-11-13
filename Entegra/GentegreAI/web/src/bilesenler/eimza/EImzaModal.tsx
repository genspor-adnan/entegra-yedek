import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { EImzaAyar, EImzaKart, EImzaSertifika } from '../../api/uclar/eimza';
import { Modal } from '../Modal';
import { genSignerSertifikalar } from './genSigner';

/**
 * e-İMZA PENCERESİ (1337): kart seçimi + PIN. Kartlar istemci kipinde bu bilgisayardaki GenSigner'dan, sunucu
 * kipinde API üzerinden sunucudaki GenSigner'dan okunur. PIN bileşende tutulmaz; "İmzala"da ana ekrana verilir,
 * pencere kapanınca silinir.
 */
export function EImzaModal({ baslik, onKapat, onImzala }: {
  baslik: string;
  onKapat(): void;
  /** İmza akışını ana ekran yürütür (rapor kaydı + belge + GenSigner + API). Hata fırlatırsa pencere açık kalır. */
  onImzala(ayar: EImzaAyar, kart: EImzaKart, pin: string): Promise<void>;
}) {
  const [ayar, setAyar] = useState<EImzaAyar | null>(null);
  const [sertifikalar, setSertifikalar] = useState<EImzaSertifika[]>([]);
  const [secili, setSecili] = useState('');
  const [pin, setPin] = useState('');
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);
  const [imzalaniyor, setImzalaniyor] = useState(false);

  const kartlariOku = useCallback(async (a: EImzaAyar) => {
    setYukleniyor(true); setHata('');
    try {
      const liste = a.kip === 'sunucu'
        ? (await api.eimzaSertifikalar()).sertifikalar
        : await genSignerSertifikalar(a.url, a.apiKey);
      // İmza anahtarı olan ve tarihi geçerli sertifikalar önce; hiç yoksa hepsi görünür, uyarı verilir.
      const sirali = [...liste].sort((x, y) => Number(y.keyUsageSign ?? true) - Number(x.keyUsageSign ?? true));
      setSertifikalar(sirali);
      const ilk = sirali.find(s => s.keyUsageSign !== false && s.dateValid !== false) ?? sirali[0];
      setSecili(ilk ? anahtar(ilk) : '');
    } catch (h) { setHata(hataMetni(h)); setSertifikalar([]); setSecili('') }
    finally { setYukleniyor(false) }
  }, []);

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const a = await api.eimzaAyar();
        if (iptal) return;
        setAyar(a);
        if (!a.aktif) { setHata('e-İmza hesabı tanımlı değil (Ayarlar › Entegrasyon Hesapları › EIMZA).'); setYukleniyor(false); return }
        await kartlariOku(a);
      } catch (h) { if (!iptal) { setHata(hataMetni(h)); setYukleniyor(false) } }
    })();
    return () => { iptal = true };
  }, [kartlariOku]);

  const kart = sertifikalar.find(s => anahtar(s) === secili);
  const hazir = !!ayar?.aktif && !!kart && pin.length > 0 && !imzalaniyor;

  const imzala = async () => {
    if (!ayar || !kart) return;
    setImzalaniyor(true); setHata('');
    try {
      await onImzala(ayar, { libraryAlias: kart.libraryAlias, slotId: kart.slotId, serial: kart.serial, cn: kart.cn }, pin);
    } catch (h) { setHata(hataMetni(h)) }
    finally { setImzalaniyor(false); setPin('') }
  };

  return (
    <Modal baslik={baslik} dar onKapat={onKapat}
           alt={<>
             <button className="d bir" disabled={!hazir} onClick={() => void imzala()}>
               {imzalaniyor ? '⏳ İmzalanıyor…' : '✍ İmzala ve Onayla'}</button>
             {/* Kapat sağ uçta (kullanıcı 13.11.2026), kart başlığındaki düzenle aynı: .ck-bosluk margin-left:auto. */}
             <span className="ck-bosluk" />
             <button className="d" disabled={imzalaniyor} onClick={onKapat}>✖ Kapat</button>
           </>}>
      <div className="alan-izgara tek-sutun">
        {ayar && (
          <div className="sonuk kucuk">
            {ayar.kip === 'sunucu'
              ? 'Kart sunucudaki okuyucuda; PIN yalnız imza için sunucudaki araca iletilir, saklanmaz.'
              : `Kart bu bilgisayarda (GenSigner ${ayar.url}); PIN bu bilgisayardan dışarı çıkmaz.`}
          </div>
        )}
        <label className="alan">
          <span className="etiket zorunlu-isaret">Sertifika (kart)</span>
          <div style={{ display: 'flex', gap: 6 }}>
            <select value={secili} disabled={yukleniyor || sertifikalar.length === 0} style={{ flex: 1 }}
                    onChange={e => setSecili(e.target.value)}>
              {sertifikalar.length === 0 && <option value="">{yukleniyor ? 'Kartlar okunuyor…' : 'Kart bulunamadı - kartı takıp Yenile'}</option>}
              {sertifikalar.map(s => (
                <option key={anahtar(s)} value={anahtar(s)}>
                  {(s.cn || s.subject || s.serial)}{s.dateValid === false ? ' · SÜRESİ DOLMUŞ' : ''}{s.keyUsageSign === false ? ' · imza anahtarı değil' : ''}
                </option>))}
            </select>
            <button type="button" className="d" disabled={!ayar?.aktif || yukleniyor} title="Kartları yeniden oku"
                    onClick={() => ayar && void kartlariOku(ayar)}>⟳</button>
          </div>
        </label>
        {kart && (kart.issuer || kart.serialNumber) && (
          <div className="sonuk kucuk">{kart.issuer ? `Veren: ${kart.issuer}` : ''}{kart.serialNumber ? ` · Seri: ${kart.serialNumber}` : ''}</div>
        )}
        <label className="alan">
          <span className="etiket zorunlu-isaret">Kart PIN</span>
          <input type="password" autoComplete="off" value={pin} maxLength={16} disabled={!kart || imzalaniyor}
                 onChange={e => setPin(e.target.value)}
                 onKeyDown={e => { if (e.key === 'Enter' && hazir) void imzala() }} />
        </label>
        <div className="sonuk kucuk">İmza raporu onaylar ve kilitler; imzalı belge (XAdES) rapor dokümanlarına eklenir.</div>
        {hata && <div className="hata-kutusu">{hata}</div>}
      </div>
    </Modal>
  );
}

const anahtar = (s: EImzaSertifika) => `${s.libraryAlias}|${s.slotId}|${s.serial}`;
