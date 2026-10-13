import { Fragment, useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { AktarimDurumu as Veri, AktarimPaketi } from '../../api/uclar/aktarim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { stil as icmalStili } from '../hasta/icmal/icmalStil';

/**
 * AKTARIM DURUMU `/aktarim-durumu` — mockup Ekranlar/aktarim_durumu.html (sekme 1),
 * kullanıcı onayı 13.10.2026. Delphi ERP → web tek yön aktarımı.
 *
 * Yalnız GÖSTERİR: aktarımı müşteri sunucusundaki ajan yürütür, sıra ve kurallar
 * sunucuda (fn_aktar_paket). Hata kuyruğunda yalnız "Çözüldü say" var - veri
 * atlanmaz (kullanıcı kararı: "Atla" yok); düzeltme Delphi'de ya da sunucu sürümünde.
 */
const ADIM_ADLARI: Record<string, [string, string]> = {
  fn_aktar_depo: ['DEPOLAR', 'Depo'],
  fn_aktar_doviz: ['DOVIZ', 'Döviz kuru'],
  fn_aktar_masraf_merkezi: ['SRMMERKEZI', 'Masraf merkezi'],
  fn_aktar_cari: ['REHBER + iletişim + bilgi', 'Cari, adres'],
  fn_aktar_proje: ['PROJELER', 'Proje'],
  fn_aktar_kalem: ['MASRAFGELIR + FIYATLAR', 'Hizmet / masraf'],
  fn_aktar_stok: ['STOKLAR + barkod / fiyat / seri-lot', 'Stok'],
  fn_aktar_hesap: ['KASALAR · BANKA · POS · KK · KREDİ', 'Hesap'],
  fn_aktar_is_merkezi: ['LOKASYON', 'İş merkezi'],
  fn_aktar_recete: ['URETIMRECETE + satır / operasyon', 'Ürün ağacı'],
  fn_aktar_stok_durum: ['STOKDURUM', 'Stok bakiyesi'],
  fn_aktar_belge: ['FATBASLIK + FATURA + STOKIZLEME', 'Belge, satır, izlem'],
  fn_aktar_kasa: ['KASA', 'Cari hareket, kasa işlemi'],
};
const HAREKET_SIRA = 11;

const saat = (s: string | null | undefined) =>
  s ? new Date(s).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit', second: '2-digit' }) : '—';
const once = (s: string | null | undefined) => {
  if (!s) return '—';
  const sn = Math.max(0, Math.round((Date.now() - new Date(s).getTime()) / 1000));
  return sn < 60 ? `${sn} sn önce` : sn < 3600 ? `${Math.round(sn / 60)} dk önce` : sn < 86400 ? `${Math.round(sn / 3600)} sa önce` : saat(s);
};
const sayi = (n: number) => n.toLocaleString('tr-TR');
const icerik = (p: AktarimPaketi) => {
  const o = Object.entries(p.ozet ?? {}).map(([t, v]) => `${t} ${v.U + v.D}`);
  return o.length ? o.join(' · ') : '(versiyon bildirimi)';
};

export function AktarimDurumu() {
  const { yetki } = useOturum();
  const [veri, setVeri] = useState<Veri | null>(null);
  const [hata, setHata] = useState('');
  const [ham, setHam] = useState<{ id: number; metin: string } | null>(null);
  const [son, setSon] = useState<Date | null>(null);

  const yukle = useCallback(() => {
    api.aktarimDurumu().then(v => { setVeri(v); setHata(''); setSon(new Date()) }).catch(h => setHata(hataMetni(h)));
  }, []);
  useEffect(() => { yukle(); const t = setInterval(yukle, 10000); return () => clearInterval(t) }, [yukle]);

  const cozuldu = (id: number) => api.aktarimHataCozuldu(id).then(yukle).catch(h => setHata(hataMetni(h)));
  const hamGoster = (id: number) => api.aktarimHataHam(id)
    .then(j => setHam({ id, metin: JSON.stringify(j, null, 2) })).catch(h => setHata(hataMetni(h)));

  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );

  const ajan = veri?.ajanlar.find(a => a.aktif === 1);
  const nabizSn = ajan?.sonNabiz ? (Date.now() - new Date(ajan.sonNabiz).getTime()) / 1000 : Infinity;
  const ajanSinif = nabizSn < 120 ? 'iyi' : nabizSn < 600 ? 'uy' : 'teh';
  const hataSira = Math.min(...(veri?.hatalar.map(h => h.sira) ?? []), Infinity);

  return (
    <div className="hi">
      <style>{icmalStili + AKTARIM_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Aktarım Durumu</h1>
          <span className="yol">Yönetim › Platform › Aktarım Durumu</span>
        </div>
      </div>

      <div className="hi-arac">
        <button onClick={yukle}>⟳ Yenile</button>
        <span className="ki-soluk">Bu ekran yalnız gösterir: aktarımı ajan yürütür, sıra ve kurallar sunucuda.</span>
        <span className="sp" />
        <span className="ki-soluk">Yenileme 10 sn · son {son?.toLocaleTimeString('tr-TR') ?? '—'}</span>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && (<>
        {veri.veriKaynagi !== 'delphi' && (
          <div className="bilgi-kutusu">Kurumun veri kaynağı <b>web</b>: Delphi aktarımı kapalı, veriler bu sistemde girilir.
            Aktarım GenProfil › Kurum profili › Veri kaynağı'ndan açılır.</div>
        )}

        <div className="hi-ozet">
          {kutu('Ajan', ajan ? (ajanSinif === 'iyi' ? 'Çalışıyor' : ajanSinif === 'uy' ? 'Gecikiyor' : 'Sustu') : 'Tanımsız',
                ajan ? `${ajan.ad} · sürüm ${ajan.surum ?? '?'} · nabız ${once(ajan.sonNabiz)}` : 'GenProfil\'de ajan anahtarı üretin',
                ajan ? ajanSinif : 'teh')}
          {kutu('Son paket', once(veri.sonPaket), saat(veri.sonPaket))}
          {kutu('Bugün', `${sayi(veri.bugun.paket)} paket`,
                `${sayi(veri.bugun.satir)} satır · ${sayi(veri.bugun.silme)} silme · ort. ${sayi(veri.bugun.ortMs)} ms`)}
          {kutu('Açık hata', String(veri.hatalar.length),
                veri.hatalar.length ? `${veri.hatalar[0].sira}. adım · ${veri.hatalar[0].deneme}. deneme · sonraki adımlar bekliyor` : 'yok',
                veri.hatalar.length ? 'teh' : 'iyi')}
          {kutu('Hareket başlangıcı', veri.hareketBaslangic ? new Date(veri.hareketBaslangic).toLocaleDateString('tr-TR') : '—',
                'belge / kasa / stok izleme bu tarihten', 'mor')}
        </div>

        {veri.hatalar.length > 0 && (
          <div className="ak-grp">
            <h4>Hata kuyruğu <span className="ak-tag">adım başına tek açık kayıt</span></h4>
            <table className="hi-tablo">
              <thead><tr><th>Adım</th><th>Tablolar</th><th>Mesaj</th><th className="r">Deneme</th><th>İlk</th><th>Son</th><th /></tr></thead>
              <tbody>
                {veri.hatalar.map(h => (
                  <tr key={h.id} className="ak-hata">
                    <td>{h.sira} · {ADIM_ADLARI[h.adim]?.[1] ?? h.adim}</td>
                    <td>{h.tablolar.join(', ')}</td>
                    <td className="ak-mesaj">{h.mesaj}</td>
                    <td className="r">{h.deneme}</td>
                    <td>{saat(h.ilk)}</td><td>{saat(h.son)}</td>
                    <td className="ak-dug">
                      <button onClick={() => hamGoster(h.id)}>Ham paketi göster</button>
                      {yetki('aktarim.durum', 'degistir') && <button onClick={() => cozuldu(h.id)}>Çözüldü say</button>}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            <p className="ak-not">
              Hatalı adım ve <b>sonrakiler</b> bu hata çözülene kadar bekler (hatalı cari varken gelen belge carisiz kalırdı);
              önceki adımlar akmaya devam eder. Ajan 30 sn → 10 dk aralıkla kendisi yeniden dener. Düzeltme <b>Delphi'de</b>
              (veri) ya da sunucu sürümüyle (kural) yapılır. "Çözüldü say" yalnız kaydı kapatır, veriyi atlamaz - adım hâlâ
              hatalıysa sonraki denemede kayıt yeniden açılır.
            </p>
            {ham && (
              <div className="ak-ham">
                <div className="ak-ham-bas">Hata #{ham.id} - adımın pakette gelen kısmı <button onClick={() => setHam(null)}>Kapat</button></div>
                <pre>{ham.metin}</pre>
              </div>
            )}
          </div>
        )}

        <div className="ak-iki">
          <div className="ak-grp">
            <h4>Tablolar <span className="ak-tag">sunucu sırası</span></h4>
            <table className="hi-tablo">
              <thead><tr><th>Adım</th><th>Delphi tablosu</th><th>Web</th><th className="r">Versiyon</th><th>Son paket</th><th className="r">Bugün</th><th>Durum</th></tr></thead>
              <tbody>
                <tr className="ak-bolum"><td colSpan={7}>Tanımlar (hepsi)</td></tr>
                {veri.adimlar.map(a => {
                  const [delphi, web] = ADIM_ADLARI[a.fonksiyon] ?? [a.tablolar.join(', '), a.fonksiyon];
                  const durum = a.hata ? ['teh', 'Hata'] : a.sira > hataSira ? ['uy', 'Bekliyor']
                    : a.versiyon == null || a.eksikTablo > 0 ? ['gri', 'Yüklenmedi'] : ['iyi', 'Güncel'];
                  return (<Fragment key={a.sira}>
                    {a.sira === HAREKET_SIRA && (
                      <tr className="ak-bolum"><td colSpan={7}>Hareketler ({veri.hareketBaslangic ? new Date(veri.hareketBaslangic).toLocaleDateString('tr-TR') : '—'}'dan)</td></tr>
                    )}
                    <tr className={a.hata ? 'ak-hata' : a.sira > hataSira ? 'ak-bekle' : ''}>
                      <td>{a.sira}</td><td>{delphi}</td><td>{web}</td>
                      <td className="r">{a.versiyon == null ? '—' : sayi(a.versiyon)}</td>
                      <td>{once(a.sonPaket)}</td>
                      <td className="r">{sayi(a.bugunSatir)}</td>
                      <td><span className={'ak-isik ' + durum[0]} />{durum[1]}</td>
                    </tr>
                  </Fragment>);
                })}
              </tbody>
            </table>
            <p className="ak-not">Versiyon = Delphi Change Tracking numarası. "Bugün" = ajandan gelen satır (aynı içerik web'e yeniden yazılmaz).</p>
          </div>

          <div>
          <div className="ak-grp">
            <h4>Mutabakat <span className="ak-tag">gece · Delphi ↔ web kimlik karşılaştırması</span></h4>
            {veri.mutabakat.length === 0
              ? <p className="ak-not">Henüz mutabakat çalışmadı (ajan gece kendiliğinden yapar; elle: <code>GentegreAktarimAjani --mutabakat</code>).</p>
              : (<>
                <table className="hi-tablo">
                  <thead><tr><th>Tablo</th><th className="r">Delphi</th><th className="r">Web</th><th className="r">Giderilen</th><th className="r">Kural gereği</th><th>Sonuç</th></tr></thead>
                  <tbody>
                    {veri.mutabakat.map(m => {
                      const kalan = m.eksik + m.fazla - m.giderilen - m.atlanan;
                      return (
                        <tr key={m.tablo} className={kalan > 0 ? 'ak-hata' : ''}
                            title={Array.isArray(m.ornek) && m.ornek.length
                              ? m.ornek.slice(0, 10).map(o => `${o.unvan ?? o.id}: Delphi ${o.delphi}, web ${o.web}`).join('\n') : undefined}>
                          <td>{m.tablo === 'CARI_BAKIYE' ? 'Cari bakiye (TL)' : m.tablo}</td>
                          <td className="r">{sayi(m.delphi)}</td><td className="r">{sayi(m.web)}</td>
                          <td className="r">{m.giderilen ? sayi(m.giderilen) : '—'}</td>
                          <td className="r" title="Kural gereği aktarılmayan (ör. makine olmayan lokasyon, mamulü çözülmeyen reçete)">
                            {m.atlanan ? sayi(m.atlanan) : '—'}</td>
                          <td>{kalan > 0
                            ? <><span className="ak-isik teh" />{sayi(kalan)} fark kaldı</>
                            : <><span className="ak-isik iyi" />Eşit{m.giderilen ? ' (giderildi)' : ''}</>}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
                <p className="ak-not">Son: {saat(veri.mutabakat.reduce((a, m) => (m.zaman > a ? m.zaman : a), ''))}.
                  Eksik (web'de yok) yeniden yollanır; fazla (Delphi'de silinmiş) Delphi'de yeniden doğrulanıp web'de pasif yapılır / silinir.</p>
              </>)}
          </div>
          <div className="ak-grp">
            <h4>Son paketler</h4>
            <table className="hi-tablo">
              <thead><tr><th>Saat</th><th>İçerik</th><th className="r">Süre</th><th>Sonuç</th></tr></thead>
              <tbody>
                {veri.sonPaketler.length === 0 && <tr><td colSpan={4} className="ki-soluk">Henüz paket gelmedi.</td></tr>}
                {veri.sonPaketler.map((p, i) => (
                  <tr key={i} className={p.durum !== 1 ? 'ak-hata' : !p.ozet ? 'ak-pas' : ''}>
                    <td>{saat(p.alinma)}</td>
                    <td className="ak-icerik">{icerik(p)}</td>
                    <td className="r">{sayi(p.sureMs ?? 0)} ms</td>
                    <td>{p.durum !== 1
                      ? <><span className="ak-isik teh" />{p.hata ?? 'Hata'}</>
                      : <><span className="ak-isik iyi" />Tamam{p.yazilan ? ` · ${sayi(p.yazilan)} yazıldı` : ''}</>}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          </div>
        </div>
      </>)}
    </div>
  );
}

const AKTARIM_STILI = `
.hi-ozet { grid-template-columns:repeat(5,1fr); }
.ak-grp { border:1px solid var(--cizgi-ince,#e3e9f0); border-radius:4px; background:var(--yuz,#fff); margin:10px 0; overflow-x:auto; }
.ak-grp > h4 { margin:0; padding:6px 10px; font-size:12px; color:var(--baslik,#14315a); background:#f0f5fa;
  border-bottom:1px solid var(--cizgi-ince,#e3e9f0); display:flex; align-items:center; gap:8px; }
.ak-tag { margin-left:auto; font-size:10px; font-weight:bold; background:#eaf1f8; color:#3d6294; border:1px solid #cfe0f0; border-radius:3px; padding:1px 6px; }
.ak-iki { display:grid; grid-template-columns:minmax(0,1.2fr) minmax(0,1fr); gap:12px; }
@media (max-width:1100px) { .ak-iki { grid-template-columns:1fr; } }
.ak-not { font-size:11px; color:var(--soluk,#6b7a8b); margin:6px 10px 8px; line-height:1.5; }
.hi-tablo td.r, .hi-tablo th.r { text-align:right; }
.hi-tablo tr.ak-hata td { background:#f7cfcf; color:#7d1f1f; }
.hi-tablo tr.ak-bekle td { background:#fbe6ae; color:#7a5407; }
.hi-tablo tr.ak-pas td { color:#8a96a3; }
.hi-tablo tr.ak-bolum td { background:#f0f4f9; color:var(--baslik,#14315a); font-weight:bold; font-size:11px; }
.ak-grp .hi-tablo td { white-space:nowrap; }
.ak-grp .hi-tablo td.ak-mesaj, .ak-grp .hi-tablo td.ak-icerik { white-space:normal; }
.hi-tablo td.r { white-space:nowrap; }
.ak-icerik { font-size:11px; }
.ak-dug { white-space:nowrap; } .ak-dug button { margin-left:4px; }
.ak-isik { display:inline-block; width:9px; height:9px; border-radius:50%; margin-right:5px; vertical-align:-1px; background:#b8c2cc; }
.ak-isik.iyi { background:#3fa35c; } .ak-isik.uy { background:#e0a23a; } .ak-isik.teh { background:#d24b47; }
.ak-ham { margin:0 10px 10px; border:1px solid var(--cizgi-ince,#e3e9f0); border-radius:4px; }
.ak-ham-bas { display:flex; justify-content:space-between; align-items:center; padding:4px 8px; background:#f3f6fa; font-size:11px; }
.ak-ham pre { margin:0; padding:8px; max-height:320px; overflow:auto; font-size:11px; background:#1f2d3a; color:#c6f5d0; }
`;

export default AktarimDurumu;
