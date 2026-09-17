import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { IsgFirmaKarti, IsgFirmaSatiri, IsgPano as Pano } from '../../api/uclar/isg';
import { useOturum } from '../../kimlik/OturumBaglami';

/**
 * FİRMA PANOSU `/isg-pano` (İSG 741) — mockup Ekranlar/ISG/isg_firma_panosu.html.
 * Üstte KPI'lar, solda firma listesi (tehlike, çalışan, plan/gerçekleşen dakika,
 * vade, kaza), seçili firma için sekmeler: Firma kartı (bölümler & maruziyet),
 * Sağlık gözetimi özeti (işverene giden yalnız sayılar), Süre (İSG-KATİP).
 */
const TEH: Record<number, string> = { 1: 'isg-teh-az', 2: 'isg-teh-t', 3: 'isg-teh-ct' };
export function IsgPano() {
  const git = useNavigate();
  const [sorgu, setSorgu] = useSearchParams();
  const { yetki } = useOturum();
  const [p, setP] = useState<Pano | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [seciliId, setSeciliId] = useState<number>(Number(sorgu.get('firma') ?? 0));
  const [k, setK] = useState<IsgFirmaKarti | null>(null);
  const [sekme, setSekme] = useState<'kart' | 'ozet' | 'sure'>('kart');
  const [teh, setTeh] = useState(0);

  const yukle = useCallback(async () => {
    try { const y = await api.isgPano(); setP(y); setHata(null); if (!seciliId && y.firmalar[0]) setSeciliId(y.firmalar[0].id) } catch (h) { setHata(hataMetni(h)) }
  }, [seciliId]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => {
    if (!seciliId) { setK(null); return }
    api.isgFirmaKart(seciliId).then(setK).catch(h => setHata(hataMetni(h)));
    setSorgu(s => { s.set('firma', String(seciliId)); return s }, { replace: true });
  }, [seciliId, setSorgu]);

  if (hata) return <div className="fm-sayfa"><div className="hata-kutusu">{hata}</div></div>;
  if (!p) return <div className="fm-sayfa sonuk">Yükleniyor…</div>;
  const o = p.ozet;
  const firmalar = p.firmalar.filter(f => !teh || f.tehlike === teh);
  const oran = (f: IsgFirmaSatiri) => f.plan_dk ? Math.min(100, Math.round((f.muayene_dk_ay + f.ziyaret_dk_ay) / f.plan_dk * 100)) : 0;
  const f = k?.firma;
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>🏭 Firma Panosu</h1><span className="yol">İşyeri Hekimliği › Firma Panosu · {new Date().toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' })}</span>
        <div className="sag">
          {yetki('isg.firma', 'ekle') && <button className="d bir" onClick={() => git('/isg-firma/yeni?geri=%2Fisg-pano')}>＋ Firma</button>}
          <button className="d" onClick={() => git('/isg-takvim')}>📅 Periyodik takvim</button>
          <button className="d" onClick={() => git('/dokumler?grup=%C4%B0%C5%9Fyeri%20Hekimli%C4%9Fi')}>📊 Dökümler</button>
        </div></div></div>
      <div className="fm-kpis">
        <div className="fm-kpi"><div className="b">Firma / çalışan</div><div className="d">{o.firma} <small>/ {o.calisan}</small></div></div>
        <div className="fm-kpi"><div className="b">Sözleşme dk (ay)</div><div className="d">{o.planDk.toLocaleString('tr-TR')}</div></div>
        <div className="fm-kpi"><div className="b">Gerçekleşen</div><div className={`d${o.planDk && o.gercekDk / o.planDk < 0.8 ? ' sari' : ''}`}>{o.gercekDk.toLocaleString('tr-TR')} <small>{o.planDk ? `%${Math.round(o.gercekDk / o.planDk * 100)}` : ''}</small></div></div>
        <div className="fm-kpi"><div className="b">Vadesi gelen (30 g)</div><div className={`d${o.vadeGelen ? ' sari' : ''}`}>{o.vadeGelen}</div></div>
        <div className="fm-kpi"><div className="b">Vadesi geçen</div><div className={`d${o.vadeGecen ? ' kir' : ''}`}>{o.vadeGecen}</div></div>
        <div className="fm-kpi"><div className="b">Bu ay iş kazası</div><div className="d">{o.kazaAy}</div></div>
        <div className="fm-kpi"><div className="b">SGK bildirimi geciken</div><div className={`d${o.sgkGeciken ? ' kir' : ''}`}>{o.sgkGeciken}</div></div>
        <div className="fm-kpi"><div className="b">Açık muayene</div><div className="d">{o.acikMuayene}</div></div>
      </div>
      <div className="fm-doldur-arac">
        <span className="sonuk">Tehlike:</span>
        {[[0, 'Tümü'], [1, 'Az'], [2, 'Tehlikeli'], [3, 'Çok tehlikeli']].map(([v, ad]) => <button key={v} className={`d${teh === v ? ' bir' : ''}`} onClick={() => setTeh(v as number)}>{ad}</button>)}
      </div>
      <section className="fm-bolum">
        <table className="fm-tablo isg-firma-tablo">
          <thead><tr><th>Firma</th><th>NACE</th><th>Tehlike</th><th className="fm-sag">Çalışan</th><th>Hekim</th><th className="fm-sag">Plan dk</th><th className="fm-sag">Gerç. dk</th><th>Süre</th><th className="fm-sag">Vade</th><th className="fm-sag">Kaza (yıl)</th></tr></thead>
          <tbody>
            {firmalar.map(x => (
              <tr key={x.id} className={x.id === seciliId ? 'sec' : ''} onClick={() => setSeciliId(x.id)} onDoubleClick={() => git(`/isg-firma/${x.id}?geri=%2Fisg-pano`)}>
                <td><b>{x.firma_adi}</b></td><td>{x.nace}</td><td><span className={`isg-teh ${TEH[x.tehlike]}`}>{x.tehlike_adi}</span></td>
                <td className="fm-sag">{x.aktif_calisan}</td><td>{x.hekim_adi}</td><td className="fm-sag">{x.plan_dk.toLocaleString('tr-TR')}</td>
                <td className="fm-sag">{(x.muayene_dk_ay + x.ziyaret_dk_ay).toLocaleString('tr-TR')}</td>
                <td><div className={`isg-bar${oran(x) >= 80 ? '' : oran(x) >= 50 ? ' s' : ' k'}`}><i style={{ width: `${oran(x)}%` }} /></div></td>
                <td className={`fm-sag${x.vade_yaklasan ? ' isg-kir' : ''}`}>{x.vade_yaklasan}</td><td className="fm-sag">{x.kaza_yil}</td>
              </tr>
            ))}
            {!firmalar.length && <tr><td colSpan={10} className="sonuk">Firma yok — "＋ Firma" ile anlaşmalı kurumu işveren olarak tanımlayın.</td></tr>}
          </tbody>
        </table>
        <div className="sonuk" style={{ fontSize: 11, marginTop: 4 }}>Süre = muayene + ziyaret + eğitim + kurul dakikaları / sözleşme dakikası · çift tık: firma kartı</div>
      </section>
      {f && k && (
        <section className="fm-bolum">
          <div className="ka-sekmeler" style={{ padding: '0 0 8px' }}>
            <div className={`ka-sekme${sekme === 'kart' ? ' on' : ''}`} onClick={() => setSekme('kart')}>Firma Kartı — {f.firma_adi}</div>
            <div className={`ka-sekme${sekme === 'ozet' ? ' on' : ''}`} onClick={() => setSekme('ozet')}>Sağlık Gözetimi Özeti</div>
            <div className={`ka-sekme${sekme === 'sure' ? ' on' : ''}`} onClick={() => setSekme('sure')}>Süre (İSG-KATİP)</div>
            <span className="sp" />
            <button className="d mini" onClick={() => git(`/isg-firma/${f.id}?geri=%2Fisg-pano%3Ffirma%3D${f.id}`)}>✎ Düzenle</button>
            <button className="d mini" onClick={() => git(`/isg-calisan?firmaId=${f.id}`)}>👷 Çalışanlar</button>
            <button className="d mini" onClick={() => git(`/isg-ziyaret/yeni?geri=%2Fisg-pano%3Ffirma%3D${f.id}&firmaId=${f.id}`)}>＋ Ziyaret</button>
          </div>
          {sekme === 'kart' && (
            <>
              <div className="isg-frm">
                <Al lb="SGK sicil" v={f.sgk_sicil} /><Al lb="NACE" v={`${f.nace} ${f.nace_ad}`} /><Al lb="Tehlike sınıfı" v={<span className={`isg-teh ${TEH[f.tehlike]}`}>{f.tehlike_adi}</span>} />
                <Al lb="Çalışan" v={`${f.aktif_calisan} aktif · beyan ${f.calisan_sayisi}`} /><Al lb="İşyeri hekimi" v={f.hekim_adi} /><Al lb="İSG uzmanı" v={f.isg_uzman_adi} /><Al lb="DSP" v={f.dsp_adi} />
                <Al lb="Aylık dakika" v={`${f.plan_dk.toLocaleString('tr-TR')} dk${f.aylik_dk ? ' (sözleşme)' : ' (çalışan × katsayı)'}`} /><Al lb="Sözleşme" v={`${f.sozlesme_bas ? new Date(f.sozlesme_bas).toLocaleDateString('tr-TR') : '—'} – ${f.sozlesme_bit ? new Date(f.sozlesme_bit).toLocaleDateString('tr-TR') : '—'}`} />
                <Al lb="Ziyaret sıklığı" v={f.ziyaret_sikligi} /><Al lb="Gece çalışanı" v={String(f.gece_calisan)} /><Al lb="İSG kurulu" v={f.isg_kurulu ? 'Var' : 'Yok'} /><Al lb="Yetkili" v={`${f.yetkili} ${f.yetkili_tel}`} /><Al lb="Adres" v={f.adres} />
              </div>
              <table className="fm-tablo">
                <thead><tr><th>Bölüm</th><th className="fm-sag">Çalışan</th><th>Maruziyet</th><th>Tetkik paketi</th><th>Periyot</th><th className="fm-sag">Vadesi geçen</th></tr></thead>
                <tbody>
                  {k.bolumler.map(b => <tr key={b.id}><td>{b.ad}</td><td className="fm-sag">{b.aktif || b.calisanSayisi}</td><td>{(b.maruziyet ?? []).map(m => <span key={m} className="isg-mrz">{MARUZIYET[m] ?? m}</span>)}</td><td>{b.tetkikPaketi}</td><td>{b.periyotAy ? `${b.periyotAy} ay` : `sınıf (${f.tehlike === 1 ? 60 : f.tehlike === 2 ? 36 : 12} ay)`}</td><td className={`fm-sag${b.vadeGecen ? ' isg-kir' : ''}`}>{b.vadeGecen}</td></tr>)}
                  {!k.bolumler.length && <tr><td colSpan={6} className="sonuk">Bölüm yok — firma kartında "Bölümler ve maruziyetler" detayından ekleyin.</td></tr>}
                </tbody>
              </table>
            </>
          )}
          {sekme === 'ozet' && (
            <>
              <div className="fm-kpis">
                <div className="fm-kpi"><div className="b">Muayene (yıl)</div><div className="d">{k.ozet.muayene}</div></div>
                <div className="fm-kpi"><div className="b">Çalışır</div><div className="d ok">{k.ozet.calisir}</div></div>
                <div className="fm-kpi"><div className="b">Koşullu çalışır</div><div className={`d${k.ozet.kosullu ? ' sari' : ''}`}>{k.ozet.kosullu}</div></div>
                <div className="fm-kpi"><div className="b">Çalışamaz</div><div className={`d${k.ozet.calisamaz ? ' kir' : ''}`}>{k.ozet.calisamaz}</div></div>
                <div className="fm-kpi"><div className="b">Vadesi geçen</div><div className={`d${k.ozet.vadeGecen ? ' kir' : ''}`}>{k.ozet.vadeGecen}</div></div>
                <div className="fm-kpi"><div className="b">Kaza / meslek hast. (yıl)</div><div className="d">{k.ozet.kaza} / {k.ozet.meslekHastaligi}</div></div>
                <div className="fm-kpi"><div className="b">Termin geçen öneri</div><div className={`d${k.ozet.terminGecen ? ' sari' : ''}`}>{k.ozet.terminGecen}</div></div>
              </div>
              <div className="sonuk" style={{ fontSize: 11 }}>İşverene giden özet yalnız sayılar ve kanaat dağılımıdır; tanı, tetkik değeri, kişisel öykü GİTMEZ (6331 md.15). Firma Yetkilisi rolü bu sekmeyi ve periyodik takvimi görür.</div>
              <table className="fm-tablo" style={{ marginTop: 8 }}>
                <thead><tr><th>Son ziyaretler</th><th>Tür</th><th className="fm-sag">Süre</th><th>Öneri</th><th>Termin</th><th>Defter</th><th className="fm-sag">İmza</th></tr></thead>
                <tbody>{k.ziyaretler.map(z => <tr key={z.id}><td>{new Date(z.tarih).toLocaleDateString('tr-TR')}</td><td>{z.tur_adi}</td><td className="fm-sag">{z.sure_dk} dk</td><td className="fm-not">{z.oneri.slice(0, 120)}</td><td className={z.termin_gecti ? 'isg-kir' : ''}>{z.termin ? new Date(z.termin).toLocaleDateString('tr-TR') : ''}</td><td>{z.defter_sayfa}</td><td className="fm-sag">{z.imza_sayisi}/3</td></tr>)}</tbody>
              </table>
            </>
          )}
          {sekme === 'sure' && (
            <>
              <table className="fm-tablo">
                <thead><tr><th>Ay</th><th className="fm-sag">Plan dk</th><th className="fm-sag">Muayene</th><th className="fm-sag">Muayene dk</th><th className="fm-sag">Ziyaret dk</th><th className="fm-sag">Eğitim dk</th><th className="fm-sag">Kurul dk</th><th className="fm-sag">Toplam</th><th>Oran</th></tr></thead>
                <tbody>{k.aylar.map(a => { const t = a.muayeneDk + a.ziyaretDk + a.egitimDk + a.kurulDk; const r = f.plan_dk ? Math.min(100, Math.round(t / f.plan_dk * 100)) : 0; return (
                  <tr key={a.ay}><td>{a.ay}</td><td className="fm-sag">{f.plan_dk.toLocaleString('tr-TR')}</td><td className="fm-sag">{a.muayene}</td><td className="fm-sag">{a.muayeneDk}</td><td className="fm-sag">{a.ziyaretDk}</td><td className="fm-sag">{a.egitimDk}</td><td className="fm-sag">{a.kurulDk}</td><td className="fm-sag"><b>{t}</b></td><td><div className={`isg-bar${r >= 80 ? '' : r >= 50 ? ' s' : ' k'}`}><i style={{ width: `${r}%` }} /></div> %{r}</td></tr>); })}</tbody>
              </table>
              <div className="sonuk" style={{ fontSize: 11 }}>Muayene dakikası = Ek-2 başına 15 dk (muayene kartında değiştirilebilir); ziyaret/eğitim/kurul ziyaret tutanağından. İSG-KATİP'e elle girilen dakika ile aylık karşılaştırma (resmî API yok). Fatura: sözleşme dakikası × birim fiyat.</div>
            </>
          )}
        </section>
      )}
    </div>
  );
}

export const MARUZIYET: Record<number, string> = {
  1: 'Gürültü', 2: 'Toz', 3: 'Kimyasal', 4: 'Ekranlı araç', 5: 'Yüksekte', 6: 'Gece', 7: 'Biyolojik', 8: 'Ergonomik', 9: 'Sıcak/soğuk', 10: 'Titreşim', 11: 'Radyasyon', 12: 'Gıda (portör)', 13: 'Metal dumanı', 14: 'Ağır metal',
};
function Al({ lb, v }: { lb: string; v: React.ReactNode }) {
  return <div className="isg-al"><div className="fm-etiket">{lb}</div><div className="isg-v">{v || '—'}</div></div>;
}
