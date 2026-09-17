import type { DokumBaski, DokumKolonMeta, DokumTanimi, ListeYaniti, OzetYaniti } from '../../api/sozlesme';
import { tarihSaat } from '../../bilesenler/bicim';
import { KURAL_ETIKET, bosBaski, parametreAlanlari, tanimCumlesi, yonOnerisi } from './ortak';
import { CubukGrafik, ListeSonucu, OzetGostergeler, OzetSonucu, ozetMi } from './SonucTablosu';
import { AntetLogo } from '../../bilesenler/AntetLogo';

/**
 * BASKI ÖNİZLEME (mockup Ekranlar/Ayarlar/dokum_baski_onizleme.html).
 *
 * Yol LabRaporCikti ile aynı: HTML + window.print() + @media print. Ayrı bir
 * PDF üreticisi yok - "PDF" tarayıcının "PDF olarak kaydet"i. Sol panel baskı
 * ayarları (dökümle saklanır: tanim.baski), sağda A4 kâğıt. Kâğıt Önizleme
 * sekmesinin ALDIĞI veriyle çizilir; ikinci sorgu yok.
 */
export function BaskiOnizleme({ tanim, setTanim, kolonlar, kaynakAdi, ad, yanit, parametreler,
                                antet, kullaniciAdi, surum, onTumunuCek, tumCekiliyor }: {
  tanim: DokumTanimi; setTanim(t: DokumTanimi): void; kolonlar: DokumKolonMeta[]; kaynakAdi: string;
  ad: string; yanit: ListeYaniti | OzetYaniti | null; parametreler: Record<string, unknown>;
  antet: Record<string, unknown> | null; kullaniciAdi: string; surum: number;
  /** Liste çıktısında kâğıt için tüm sayfaları (tavana kadar) çeker. */
  onTumunuCek(): void; tumCekiliyor: boolean;
}) {
  const b: DokumBaski = { ...bosBaski(), ...(tanim.baski ?? {}) };
  const yaz = (y: Partial<DokumBaski>) => setTanim({ ...tanim, baski: { ...b, ...y } });
  const oneri = yonOnerisi(tanim, ozetMi(yanit) ? new Set(yanit.satirlar.map(r => String(r[yanit.boyutlar[yanit.boyutlar.length - 1]] ?? ''))).size : 0);
  const secili = tanim.kolonlar?.length ? tanim.kolonlar : kolonlar.map(k => k.ad);
  const gizli = b.gizliKolonlar ?? [];
  const alanlar = parametreAlanlari(tanim);
  const eksik = yanit && !ozetMi(yanit) && yanit.satirlar.length < Math.min(yanit.toplamKayit, b.satirTavani);
  const simdi = new Date();

  const parametreMetni = (a: { alan: string; kural: string; op: string }) => {
    const v = parametreler[a.alan];
    if (Array.isArray(v) && v.length) return a.op === 'arasinda' ? `${gunTr(v[0])} – ${gunTr(v[1])}` : v.join(', ');
    if (v) return String(v);
    return a.kural ? KURAL_ETIKET[a.kural] : '—';
  };

  return (
    <div className="dk-baski">
      {/* ------------------------------------------------ sol: ayarlar */}
      <div className="dk-baski-ayar">
        <div className="kagrup">
          <h6>Sayfa</h6>
          <div className="dk-sat"><span>Kâğıt</span><span>A4</span></div>
          <div className="dk-sat"><span>Yön</span>
            <span>
              <label className="dk-onay"><input type="radio" checked={b.yon === 'dikey'} onChange={() => yaz({ yon: 'dikey' })} />Dikey</label>
              <label className="dk-onay"><input type="radio" checked={b.yon === 'yatay'} onChange={() => yaz({ yon: 'yatay' })} />Yatay</label>
            </span>
          </div>
          {oneri !== b.yon && (
            <div className="pano-not">Öneri: {secili.length > 8 ? '8+ kolon' : '6+ çapraz sütun'} → <b>{oneri}</b>.
              <button className="d mini" onClick={() => yaz({ yon: oneri })}>Uygula</button></div>
          )}
        </div>
        <div className="kagrup">
          <h6>Başlık &amp; Altbilgi</h6>
          {([
            ['kurumBasligi', 'Kurum başlığı (ad · adres)'],
            ['parametreKutusu', 'Döküm adı + parametre kutusu'],
            ['sayfaNo', 'Üretim zamanı · kullanıcı · sayfa'],
            ['damga', '"GİZLİ" damgası'],
            ['imza', 'İmza alanı (Hazırlayan · Kontrol · Onaylayan)'],
          ] as const).map(([k, ad]) => (
            <label key={k} className="dk-sat dk-onay"><input type="checkbox" checked={b[k]} onChange={e => yaz({ [k]: e.target.checked })} />{ad}</label>
          ))}
          <label className="dk-sat"><span>Dipnot</span><input value={b.dipnot} onChange={e => yaz({ dipnot: e.target.value })} /></label>
        </div>
        <div className="kagrup">
          <h6>İçerik</h6>
          {([
            ['ozetGostergeler', 'Özet göstergeler'],
            ['araToplam', 'Grup ara toplamları'],
            ['capraz', 'Grafik (özet)'],
          ] as const).map(([k, ad]) => (
            <label key={k} className="dk-sat dk-onay"><input type="checkbox" checked={b[k]} onChange={e => yaz({ [k]: e.target.checked })} />{ad}</label>
          ))}
          <label className="dk-sat"><span>Satır tavanı</span>
            <input type="number" min={100} max={5000} step={100} value={b.satirTavani}
                   onChange={e => yaz({ satirTavani: Math.max(100, Math.min(5000, Number(e.target.value) || 2000)) })} />
          </label>
          {tanim.cikti === 'liste' && (
            <div className="dk-havuz">
              <span className="sonuk">Kolon gizle/göster:</span>
              {secili.map(k => (
                <button key={k} className={`dk-cip${gizli.includes(k) ? '' : ' on'}`}
                        onClick={() => yaz({ gizliKolonlar: gizli.includes(k) ? gizli.filter(x => x !== k) : [...gizli, k] })}>
                  {kolonlar.find(x => x.ad === k)?.baslik ?? k}
                </button>
              ))}
            </div>
          )}
        </div>
        <div className="kagrup">
          <h6>Basım</h6>
          <div className="dk-sat" style={{ gap: 6, justifyContent: 'flex-start' }}>
            <button className="d bir" onClick={() => window.print()} disabled={!yanit}>🖨 Yazdır</button>
            <button className="d" onClick={() => window.print()} disabled={!yanit}
                    title="Yazdırma penceresinde “PDF olarak kaydet” seçin.">📄 PDF</button>
          </div>
          {eksik && (
            <div className="pano-not">
              Kâğıtta yalnız ilk {yanit!.satirlar.length} satır var (toplam {yanit!.toplamKayit.toLocaleString('tr-TR')}).
              <button className="d mini" onClick={onTumunuCek} disabled={tumCekiliyor}>
                {tumCekiliyor ? 'Çekiliyor…' : `Tümünü çek (en çok ${b.satirTavani})`}
              </button>
            </div>
          )}
          <div className="pano-not">Baskı ayarı <b>dökümle kaydedilir</b> (Kaydet düğmesi). Yazdırma tarayıcınındır; ayrı PDF sunucusu yok.</div>
        </div>
      </div>

      {/* ------------------------------------------------ sağ: kâğıt */}
      <div className="dk-kagit-alani">
        <div className={`dk-kagit${b.yon === 'yatay' ? ' yatay' : ''}`}>
          {b.damga && <div className="dk-damga">GİZLİ</div>}
          {b.kurumBasligi && (
            <div className="dk-kurum">
              <AntetLogo dokumanId={antet?.logoDokumanId as number | undefined}
                         sinif="dk-logo" />
              <div>
                <div className="ad">{String(antet?.unvan ?? '—')}</div>
                <div className="alt">
                  {[antet?.adres, [antet?.ilce, antet?.il].filter(Boolean).join(' / '), antet?.telefon].filter(x => x && String(x).trim()).join(' · ')}
                  {antet?.mersisNo ? <><br />Mersis {String(antet.mersisNo)}</> : null}
                </div>
              </div>
              <div className="no"><b>DÖKÜM</b>Üretim: {tarihSaat(simdi.toISOString())}<br />Hazırlayan: {kullaniciAdi}{surum > 0 && <><br />Sürüm: v{surum}</>}</div>
            </div>
          )}
          <h1>{ad || 'Adsız döküm'}</h1>
          <h2>{tanimCumlesi(tanim, kolonlar, kaynakAdi)}</h2>
          {b.parametreKutusu && alanlar.length > 0 && (
            <div className="dk-paramkutu">
              {alanlar.map(a => <div key={a.alan}><span>{a.ad}</span><b>{parametreMetni(a)}</b></div>)}
            </div>
          )}
          {!yanit && <div className="bos">Önce Önizleme sekmesinde çalıştırın — kâğıt aynı veriyle çizilir.</div>}
          {yanit && b.ozetGostergeler && <OzetGostergeler yanit={yanit} tanim={tanim} kolonlar={kolonlar} baski />}
          {yanit && (ozetMi(yanit)
            ? <OzetSonucu yanit={yanit} tanim={tanim} kolonlar={kolonlar} baski />
            : <ListeSonucu yanit={yanit} tanim={tanim} kolonlar={kolonlar} baski gizli={gizli} />)}
          {yanit && ozetMi(yanit) && b.capraz && (tanim.boyut?.satir.length ?? 0) > 0 && (
            <div className="dk-bolum-bas">Satır boyutuna göre
              <CubukGrafik yanit={yanit} tanim={tanim} kolonlar={kolonlar} enCok={10} />
            </div>
          )}
          {b.imza && (
            <div className="dk-imzalar">
              <div><b>Hazırlayan</b>{kullaniciAdi} · {gunTr(simdi.toISOString().slice(0, 10))}</div>
              <div><b>Kontrol</b></div>
              <div><b>Onaylayan</b></div>
            </div>
          )}
          {b.dipnot && <div className="dk-dipnot">{b.dipnot}</div>}
          {b.sayfaNo && (
            <div className="dk-altbilgi">
              <span>Gentegre AI · {String(antet?.unvan ?? '')}</span>
              <span>Üretim {tarihSaat(simdi.toISOString())} · {kullaniciAdi}</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

const gunTr = (v: unknown) => {
  const m = /^(\d{4})-(\d{2})-(\d{2})/.exec(String(v ?? ''));
  return m ? `${m[3]}.${m[2]}.${m[1]}` : String(v ?? '');
};
