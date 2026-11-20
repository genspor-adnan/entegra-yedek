import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CekSenetIslemi, CekSenetIslemleri } from '../../api/uclar/cekSenetIslem';
import { c } from '../../dil/ceviri';
import { yerelGun } from '../bicim';
import { onay } from '../mesaj';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';

/**
 * ÇEK / SENET "⚙ İşlem ▾" (kullanıcı 20.11.2026: "işlem buton ve altında menüyü de ekle", "çek/senet hareketleri
 * aynı delphi erp deki çek/senet hareketleri gibi olmalı"; mockup Ekranlar/cek_senet_baslik.html).
 *
 * Delphi UCekListeFrame sağ tık menüsü: hangi maddelerin görüneceğine SUNUCU karar verir (kıymetin yönü + durumu,
 * CekSenetIslemleri). Madde seçilince Delphi'nin sorduğu bilgiler sorulur: tarih (son hareketten önce olamaz),
 * gerekiyorsa cari ya da kasa / banka hesabı, makbuz / bordro no, açıklama. Menünün sonunda "Son Hareketi Geri Al"
 * (Delphi "Hareketi Sil"). İşlem kartı kaydetmez; kaydedilmemiş değişiklik varken menü kapalı.
 */
const RENK: Record<string, string> = {
  'portfoye-al': 'cs-m-portfoy', cirola: 'cs-m-ciro', 'teminat-cari': 'cs-m-teminat', 'teminat-banka': 'cs-m-teminat',
  takas: 'cs-m-takas', icra: 'cs-m-kir', karsiliksiz: 'cs-m-kir', tahsil: 'cs-m-tahsil', iade: 'cs-m-gri',
  odendi: 'cs-m-tahsil', 'iade-al': 'cs-m-portfoy', 'saticiya-ver': 'cs-m-ciro', iptal: 'cs-m-gri',
};

type Hesap = { id: number; ad: string; tur: string; dovizCinsi: string };

export function CekSenetIslemMenusu({ id, kirli, onBitti }: {
  id: number;
  /** Kaydedilmemiş değişiklik - önce Kaydet. */
  kirli: boolean;
  /** İşlem yazıldı: kart yeniden okunur (durum, hareketler). */
  onBitti(): void;
}) {
  const [acik, setAcik] = useState(false);
  const [veri, setVeri] = useState<CekSenetIslemleri | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<CekSenetIslemi | null>(null);

  useEffect(() => {
    if (!acik) return;
    let iptal = false;
    setHata(null);
    api.cekSenetIslemleri(id).then(v => { if (!iptal) setVeri(v) }).catch(e => { if (!iptal) setHata(hataMetni(e)) });
    const kapat = () => setAcik(false);
    window.addEventListener('click', kapat);
    return () => { iptal = true; window.removeEventListener('click', kapat) };
  }, [acik, id]);

  const geriAl = async () => {
    setAcik(false);
    if (!(await onay(c('Çekin / senedin son hareketi geri alınacak. Hareket kasa işlemi yazdıysa o işlem iptal edilir (ters kayıt). Devam edilsin mi?')))) return;
    try { await api.cekSenetGeriAl(id); onBitti() } catch (e) { setHata(hataMetni(e)) }
  };

  return (
    <>
      <span className="dugme-menu">
        <button type="button" className="d" data-testid="cek-senet-islem" disabled={kirli}
                title={kirli ? c('Önce değişiklikleri kaydedin.') : c('Çek / senet işlemleri (ciro, tahsil, takas, iade…)')}
                onClick={e => { e.stopPropagation(); setAcik(v => !v) }}>⚙ {c('İşlem')} ▾</button>
        {acik && (
          <div className="dugme-menu-liste cs-islem-menu" onClick={e => e.stopPropagation()}>
            {!veri && !hata && <div className="soluk" style={{ padding: '6px 10px' }}>{c('Yükleniyor…')}</div>}
            {hata && <div className="hata" style={{ padding: '6px 10px' }}>{hata}</div>}
            {veri && veri.islemler.length === 0 && !veri.geriAlinir && (
              <div className="soluk" style={{ padding: '6px 10px' }}>{c('Bu durumda yapılabilecek işlem yok.')}</div>
            )}
            {veri?.islemler.map((i, sira) => (
              <div key={i.kod}>
                {i.ayrac && sira > 0 && <div className="ayrac" />}
                <button type="button" className={`mi cs-m ${RENK[i.kod] ?? ''}`} data-testid={`cek-islem-${i.kod}`}
                        onClick={() => { setAcik(false); setSecili(i) }}>{i.ikon} {c(i.ad)}</button>
              </div>
            ))}
            {veri?.geriAlinir && (
              <>
                <div className="ayrac" />
                <button type="button" className="mi cs-m cs-m-gri" data-testid="cek-islem-geri-al"
                        onClick={() => void geriAl()}>↶ {c('Son Hareketi Geri Al')}</button>
              </>
            )}
          </div>
        )}
      </span>
      {hata && !acik && <span className="hata" style={{ alignSelf: 'center' }}>{hata}</span>}
      {secili && veri && (
        <CekSenetIslemPenceresi id={id} islem={secili} varsayilanHesap={veri.hesapId}
                                onKapat={() => setSecili(null)} onBitti={() => { setSecili(null); onBitti() }} />
      )}
    </>
  );
}

function CekSenetIslemPenceresi({ id, islem, varsayilanHesap, onKapat, onBitti }: {
  id: number; islem: CekSenetIslemi; varsayilanHesap: number | null; onKapat(): void; onBitti(): void;
}) {
  const [tarih, setTarih] = useState(yerelGun(new Date()));
  const [cari, setCari] = useState<{ id: number; unvan: string } | null>(null);
  const [cariAra, setCariAra] = useState(islem.hedef === 'cari');
  const [hesaplar, setHesaplar] = useState<Hesap[]>([]);
  const [hesapId, setHesapId] = useState<number>(varsayilanHesap ?? 0);
  const [belgeNo, setBelgeNo] = useState('');
  const [aciklama, setAciklama] = useState('');
  const [mesgul, setMesgul] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  // Takas / bankaya teminat yalnız banka hesabı; tahsil / ödeme kasa ya da banka (Delphi "Kasa Seçimi").
  const yalnizBanka = islem.kod === 'takas' || islem.kod === 'teminat-banka';

  useEffect(() => {
    if (islem.hedef !== 'hesap') return;
    let iptal = false;
    api.liste('hesap', { sayfa: 1, boyut: 500, filtre: { alan: 'tur', op: 'icinde', deger: yalnizBanka ? ['B'] : ['K', 'B'] } })
      .then(y => { if (!iptal) setHesaplar(y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.ad ?? ''),
                                                                   tur: String(s.tur ?? ''), dovizCinsi: String(s.dovizCinsi ?? '') }))) })
      .catch(e => { if (!iptal) setHata(hataMetni(e)) });
    return () => { iptal = true };
  }, [islem.hedef, yalnizBanka]);

  const kaydet = async () => {
    if (islem.hedef === 'cari' && !cari) { setHata(c('Cari seçilmeli.')); return }
    if (islem.hedef === 'hesap' && !hesapId) { setHata(c('Hesap seçilmeli.')); return }
    setMesgul(true); setHata(null);
    try {
      await api.cekSenetIslem(id, {
        kod: islem.kod, tarih,
        tarafId: islem.hedef === 'cari' ? cari?.id : undefined,
        hesapId: islem.hedef === 'hesap' ? hesapId : undefined,
        belgeNo: belgeNo.trim() || undefined, aciklama: aciklama.trim() || undefined,
      });
      onBitti();
    } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };

  const satir = { display: 'grid', gridTemplateColumns: '130px 1fr', gap: 8, alignItems: 'center' } as const;
  return (
    <>
      <Modal baslik={`${islem.ikon} ${c(islem.ad.replace('…', ''))}`} enUst buyutmeYok onKapat={onKapat}
             alt={<>
               <button type="button" className="d bir" disabled={mesgul} data-testid="cek-islem-kaydet"
                       onClick={() => void kaydet()}>✔ {c('Uygula')}</button>
               <button type="button" className="d" style={{ marginLeft: 'auto' }} onClick={onKapat}>✖ {c('Kapat')}</button>
             </>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10, minWidth: 460 }} data-testid="cek-islem-penceresi">
          {islem.kasa && (
            <div className="not" style={{ margin: 0 }}>
              {islem.hedef === 'hesap' ? c('Tutar seçilen hesaba kasa / banka işlemi olarak yazılır.')
                : c('Cari hesaba kasa işlemi (makbuz) olarak yazılır.')}
            </div>
          )}
          <label style={satir}><span>{c('Tarih')} *</span>
            <input type="date" value={tarih} max={yerelGun(new Date())} data-testid="cek-islem-tarih"
                   onChange={e => setTarih(e.target.value)} style={{ height: 30 }} /></label>
          {islem.hedef === 'cari' && (
            <div style={satir}><span>{c('Cari')} *</span>
              <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                <b style={{ flex: 1 }}>{cari?.unvan ?? '—'}</b>
                <button type="button" className="d" onClick={() => setCariAra(true)}>🔍 {c('Cari Seç')}</button>
              </span></div>
          )}
          {islem.hedef === 'hesap' && (
            <label style={satir}><span>{yalnizBanka ? c('Banka Hesabı') : c('Kasa / Banka')} *</span>
              <select value={hesapId} onChange={e => setHesapId(Number(e.target.value))} style={{ height: 30 }}
                      data-testid="cek-islem-hesap">
                <option value={0}>— {c('seçin')} —</option>
                {hesaplar.map(h => (
                  <option key={h.id} value={h.id}>{h.tur === 'K' ? '💰' : '🏦'} {h.ad}{h.dovizCinsi && h.dovizCinsi !== 'TL' ? ` (${h.dovizCinsi})` : ''}</option>
                ))}
              </select></label>
          )}
          {!islem.kasa && (
            <label style={satir}><span>{c('Makbuz / Bordro No')}</span>
              <input value={belgeNo} maxLength={30} data-testid="cek-islem-belgeno" onChange={e => setBelgeNo(e.target.value)} style={{ height: 30 }} /></label>
          )}
          <label style={satir}><span>{c('Açıklama')}</span>
            <input value={aciklama} maxLength={200} onChange={e => setAciklama(e.target.value)} style={{ height: 30 }} /></label>
          {hata && <div className="hata">{hata}</div>}
        </div>
      </Modal>
      <TarafArama acik={cariAra} kaynaklar={['cari']} onKapat={() => setCariAra(false)}
                  onSec={s => { setCari({ id: s.id, unvan: s.unvan }); setCariAra(false) }} />
    </>
  );
}
