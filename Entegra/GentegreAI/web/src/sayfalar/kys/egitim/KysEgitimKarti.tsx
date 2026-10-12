import { useCallback, useEffect, useState } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../../api/istemci';
import { hataMetni } from '../../../api/sozlesme';
import type { KysEgitimKatilimci } from '../../../api/uclar/kysEgitim';
import { useOturum } from '../../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../../bilesenler/mesaj';
import { useEscIleKapat } from '../../../bilesenler/Modal';
import { c } from '../../../dil/ceviri';

/**
 * KURUMSAL KALİTE — EĞİTİM KAYDI KARTI (1056) — mockup `Ekranlar/Kalite2/egitim.html`
 * ("＋ Eğitim Kaydı"). Sade: eğitim adı, tür, tarih, eğitmen, geçerlilik ve
 * katılımcılar. Katılımcı başına bir personel_egitim satırı yazılır; personel
 * kartının Eğitim / Sertifika sekmesinde de görünür. Ön/son test, etkinlik
 * ölçümü yok (sade kapsam). Modal: arkada Eğitim listesi.
 */
type Kisi = Pick<KysEgitimKatilimci, 'tarafId' | 'ad' | 'birim'>;

export function KysEgitimKarti() {
  const { id: param } = useParams();
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const geri = (konum.state as { geri?: string } | null)?.geri ?? sorgu.get('geri') ?? '/kys-egitim';
  const kapat = useCallback(() => git(geri), [git, geri]);
  useEscIleKapat(kapat);

  const yeni = param === 'yeni';
  const id = yeni ? 0 : Number(param ?? 0);
  const [ad, setAd] = useState('');
  const [tur, setTur] = useState(3);
  const [tarih, setTarih] = useState(() => new Date().toISOString().slice(0, 10));
  const [egitmen, setEgitmen] = useState('');
  const [gecerlilik, setGecerlilik] = useState('');
  const [kisiler, setKisiler] = useState<Kisi[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [yuklendi, setYuklendi] = useState(yeni);
  const [ara, setAra] = useState('');
  const [sonuc, setSonuc] = useState<{ id: number; ad: string; birim: string }[]>([]);

  useEffect(() => {
    if (!id) return;
    void (async () => {
      try {
        const k = await api.kysEgitim(id);
        setAd(k.ad); setTur(k.tur); setTarih(k.tarih); setEgitmen(k.egitmen); setGecerlilik(k.gecerlilik);
        setKisiler(k.katilimcilar.map(x => ({ tarafId: x.tarafId, ad: x.ad, birim: x.birim })));
        setYuklendi(true);
      } catch (h) { setHata(hataMetni(h)) }
    })();
  }, [id]);

  const yazar = yetki('kys.egitim', yeni ? 'ekle' : 'degistir');
  const silebilir = !yeni && yetki('kys.egitim', 'sil');
  const personelAra = useCallback(async (q: string) => {
    setAra(q);
    try { setSonuc((await api.kysEgitimPersonel(q)).satirlar) } catch { /* sessiz: liste boş kalır */ }
  }, []);
  useEffect(() => { if (yazar) void personelAra('') }, [yazar, personelAra]);

  const ekle = (p: { id: number; ad: string; birim: string }) =>
    setKisiler(k => k.some(x => x.tarafId === p.id) ? k : [...k, { tarafId: p.id, ad: p.ad, birim: p.birim }]);
  const cikar = (tarafId: number) => setKisiler(k => k.filter(x => x.tarafId !== tarafId));

  const kaydet = async () => {
    if (!ad.trim()) { mesaj('Eğitim adı zorunlu.'); return }
    if (!tarih.trim()) { mesaj('Tarih zorunlu.'); return }
    if (kisiler.length === 0) { mesaj('En az bir katılımcı seçin.'); return }
    await guvenli(async () => {
      await api.kysEgitimKaydet(id, { ad, tur, egitmen, tarih, gecerlilik, katilimcilar: kisiler.map(k => k.tarafId) });
      kapat();
    });
  };
  const sil = async () => {
    if (!await onay(`"${ad}" eğitimi ve ${kisiler.length} katılımcı kaydı silinsin mi? (personel kartlarından da silinir)`, true)) return;
    await guvenli(async () => { await api.kysEgitimSil(id); kapat() });
  };

  const secili = new Set(kisiler.map(k => k.tarafId));
  return (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin" style={{ width: 'min(920px, 96vw)' }} onClick={e => e.stopPropagation()}>
        <div className="kabas">
          <span>🎓 {yeni ? c('Yeni Eğitim Kaydı') : ad || c('Eğitim Kaydı')}</span>
          <span className="ds-kabas-yol">Kalite › Eğitim · ISO 9001 7.2</span>
          <span className="kapt">{c('Esc ile kapanır')}</span>
          <button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button>
        </div>
        <div className="kagov ds-kagov">
          {hata ? <div className="hata-kutusu">{hata}</div> : !yuklendi ? <span className="sonuk">{c('Yükleniyor…')}</span> : (<>
            <div className="ds-arac ds-kart-arac">
              {yazar && <button className="d onay" onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>}
              {silebilir && <button className="d teh" onClick={() => void sil()}>🗑 {c('Sil')}</button>}
              <button className="d ds-sp" onClick={kapat}>{c('✖ Kapat')}</button>
            </div>
            <div className="ds-hdr" style={{ padding: '6px 10px' }}>
              <div style={{ gridColumn: 'span 2' }}><label>{c('Eğitim adı')} *</label>
                <input value={ad} disabled={!yazar} maxLength={200} onChange={e => setAd(e.target.value)} placeholder="ISO 9001 Farkındalık" style={{ width: '100%' }} /></div>
              <div><label>{c('Tür')}</label>
                <select value={tur} disabled={!yazar} onChange={e => setTur(Number(e.target.value))}>
                  <option value={3}>{c('Eğitim')}</option><option value={2}>{c('Sertifika')}</option>
                </select></div>
              <div><label>{c('Tarih')} *</label>
                <input value={tarih} disabled={!yazar} maxLength={10} onChange={e => setTarih(e.target.value)} placeholder="2026-09-25" /></div>
              <div style={{ gridColumn: 'span 2' }}><label>{c('Eğitmen / kurum')}</label>
                <input value={egitmen} disabled={!yazar} maxLength={150} onChange={e => setEgitmen(e.target.value)} style={{ width: '100%' }} /></div>
              <div><label>{c('Geçerlilik')}</label>
                <input value={gecerlilik} disabled={!yazar} maxLength={60} onChange={e => setGecerlilik(e.target.value)} placeholder="2 yıl" /></div>
            </div>
            <div className="ds-odo-alan" style={{ gridTemplateColumns: yazar ? '1fr 1fr' : '1fr' }}>
              <div className="ds-grp">
                <div className="ds-gb">{c('Katılımcılar')} ({kisiler.length})</div>
                <div className="ds-dg" style={{ maxHeight: 320, overflowY: 'auto' }}><table>
                  <thead><tr><th>{c('Personel')}</th><th>{c('Birim')}</th><th /></tr></thead>
                  <tbody>
                    {kisiler.map(k => <tr key={k.tarafId}><td>{k.ad}</td><td className="sonuk">{k.birim || '—'}</td>
                      <td className="ds-satir-arac">{yazar && <button className="d" onClick={() => cikar(k.tarafId)} title={c('Çıkar')}>✖</button>}</td></tr>)}
                    {kisiler.length === 0 && <tr><td colSpan={3} className="sonuk">{c('Katılımcı yok - sağdan personel ekleyin.')}</td></tr>}
                  </tbody>
                </table></div>
              </div>
              {yazar && <div className="ds-grp">
                <div className="ds-gb">{c('Personel ekle')}</div>
                <div className="ds-arac"><input autoFocus={yeni} value={ara} onChange={e => void personelAra(e.target.value)} placeholder={c('Ad, soyad ya da birim ara…')} style={{ width: '100%' }} /></div>
                <div className="ds-dg" style={{ maxHeight: 290, overflowY: 'auto' }}><table>
                  <tbody>
                    {sonuc.map(p => <tr key={p.id} className={secili.has(p.id) ? 'soluk' : ''}><td>{p.ad}</td><td className="sonuk">{p.birim || '—'}</td>
                      <td className="ds-satir-arac">{!secili.has(p.id) && <button className="d onay" onClick={() => ekle(p)}>＋</button>}</td></tr>)}
                    {sonuc.length === 0 && <tr><td colSpan={3} className="sonuk">{c('Sonuç yok.')}</td></tr>}
                  </tbody>
                </table></div>
              </div>}
            </div>
            <div className="ds-ic sonuk">{c('Zorunlu eğitim, adı "Zorunlu Eğitimler" sekmesindeki tanımla aynı yazılınca sayılır.')}</div>
          </>)}
        </div>
      </div>
    </div>
  );
}
