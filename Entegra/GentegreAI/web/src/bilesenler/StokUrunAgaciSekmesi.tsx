import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { type StokUrunAgaci, hataMetni } from '../api/sozlesme';
import { say4, para, gunMetni } from './bicim';
import { c } from '../dil/ceviri';

/**
 * Stok kartı "Ürün Ağacı / BOM" sekmesi — Ekranlar/Stok/stok_karti_v2.html (kullanıcı 02.11.2026:
 * "Reçete sekme başlığını Ürün Ağacı/BOM"). YALNIZ ERP modunda görünür (HBYS'de üretim yok).
 *
 * SALT OKUNUR: bu stoğu mamul olarak üreten ağaçlar (her sürüm) ve seçili ağacın bileşenleri.
 * Düzenleme Ürün Ağacı kartında - bileşen / operasyon / maliyet hesabı orada tek yerde durur;
 * stok kartında ikinci bir düzenleme yolu açılmaz.
 */
export function StokUrunAgaciSekmesi({ stokId }: { stokId: number }) {
  const git = useNavigate();
  const [agaclar, setAgaclar] = useState<StokUrunAgaci[] | null>(null);
  const [seciliId, setSeciliId] = useState<number | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let iptal = false;
    api.stokUrunAgaclari(stokId)
      .then(a => { if (!iptal) { setAgaclar(a); setSeciliId(a[0]?.id ?? null); setHata(null) } })
      .catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [stokId]);

  const secili = agaclar?.find(a => a.id === seciliId) ?? null;

  return (
    <>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="kagrup">
        <h6>{c('Ürün Ağacı (BOM)')}
          <span className="soluk" style={{ fontWeight: 'normal', marginLeft: 8 }}>
            {c('üretimde bu mamulün çıktı miktarı için bileşenler')}</span></h6>

        <div className="hareket-serit">
          <button type="button" className="d" onClick={() => git(`/urun-agaci/yeni?stokId=${stokId}`)}>＋ {c('Yeni ürün ağacı')}</button>
          {secili && <button type="button" className="d" onClick={() => git(`/urun-agaci/${secili.id}`)}>✎ {c('Ağacı aç')}</button>}
          {(agaclar?.length ?? 0) > 1 && (
            <label className="satir-ici">
              {c('Sürüm')}:
              <select value={seciliId ?? ''} onChange={e => setSeciliId(Number(e.target.value))}>
                {agaclar!.map(a => (
                  <option key={a.id} value={a.id}>
                    {`${a.kod} · v${a.surum}${a.varsayilan ? ' ★' : ''}${a.aktif ? '' : ` (${c('pasif')})`}`}
                  </option>))}
              </select>
            </label>
          )}
          {secili && (
            <span className="hareket-ozet">
              {secili.ad} · {secili.tur} · v{secili.surum}
              {secili.varsayilan && <> · <b>{c('varsayılan')}</b></>}
              {!secili.aktif && <> · <span className="rozet uyari">{c('pasif')}</span></>}
            </span>
          )}
        </div>

        {agaclar === null ? <div className="yukleniyor">{c('Yükleniyor…')}</div>
          : agaclar.length === 0 ? (
            <div className="bos" style={{ padding: 24, textAlign: 'center', color: 'var(--soluk)' }}>
              {c('Bu stok için ürün ağacı tanımlı değil.')}</div>
          ) : (
          <table className="detay-tablo">
            <thead>
              <tr>
                <th style={{ width: 50 }}>{c('Sıra')}</th>
                <th>{c('Bileşen (Stok)')}</th>
                <th style={{ width: 110 }}>{c('Tip')}</th>
                <th className="hiza-sag" style={{ width: 100 }}>{c('Miktar')}</th>
                <th style={{ width: 90 }}>{c('Birim')}</th>
                <th className="hiza-sag" style={{ width: 70 }}>{c('Fire %')}</th>
                <th style={{ width: 160 }}>{c('Alt Ağaç')}</th>
              </tr>
            </thead>
            <tbody>
              {secili!.bilesenler.map((b, i) => (
                <tr key={i} title={b.stokId ? c('Çift tıkla: bileşen stok kartını aç') : undefined}
                    onDoubleClick={() => { if (b.stokId) git(`/stok/${b.stokId}`) }}>
                  <td>{b.sira || i + 1}</td>
                  <td><b>{b.stokKod}</b>{b.stokAd ? <span className="soluk"> · {b.stokAd}</span> : null}</td>
                  <td>{b.tip}</td>
                  <td className="hiza-sag">{say4.format(b.miktar)}</td>
                  <td>{b.birim}</td>
                  <td className="hiza-sag">{b.fireYuzde ? say4.format(b.fireYuzde) : ''}</td>
                  <td>{b.altAgac}</td>
                </tr>
              ))}
              {secili!.bilesenler.length === 0 && (
                <tr><td colSpan={7} className="bos">{c('Bu ağaçta bileşen yok.')}</td></tr>
              )}
            </tbody>
            <tfoot>
              <tr className="genel">
                <td colSpan={5}>
                  {secili!.bilesenler.length} {c('bileşen')} · {c('çıktı')} {say4.format(secili!.ciktiMiktar)}
                  {secili!.maliyetTarih && <span className="soluk"> · {c('son hesap')} {gunMetni(secili!.maliyetTarih)}</span>}
                </td>
                <td colSpan={2} className="hiza-sag">{c('Maliyet')}: <b>{para.format(secili!.maliyetToplam)}</b></td>
              </tr>
            </tfoot>
          </table>
        )}
        <div className="not" style={{ margin: '8px 0 0' }}>
          {c('Salt okunur özet. Bileşen, operasyon ve maliyet Ürün Ağacı kartında düzenlenir; maliyet orada hesaplanır.')}
        </div>
      </div>
    </>
  );
}
