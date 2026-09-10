import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { type PanelYaniti, hataMetni } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { para } from '../bilesenler/bicim';

const sayi = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 0 });

/** Gunun saatine gore selam - mockup'taki "İyi çalışmalar, <ad>" seridi. */
function selam(): string {
  const s = new Date().getHours();
  if (s < 6)  return 'İyi geceler';
  if (s < 12) return 'Günaydın';
  if (s < 18) return 'İyi çalışmalar';
  return 'İyi akşamlar';
}

/** Kutuya tiklayinca gidilecek liste; yolu olmayan kutu tiklanmaz. */
/**
 * Blok ikonlari (512): mockup'taki basliklarla AYNI - ikon bilgi tasimaz ama
 * alti blogun icinde arananini goz hizli buluyor.
 */
const BLOK_IKON: Record<string, string> = {
  poliklinik: '🩺', kurum: '🏢', birim: '🧪', enabiz: '📤',
  hekim: '👨‍⚕️', dikkat: '⚠️', bolum: '🔬', modalite: '🖥',
};

const HIZLI_ERISIM = [
  { ad: '＋ Satış Faturası', yol: '/belge' },
  { ad: '＋ Satış İrsaliyesi', yol: '/satis-irsaliye' },
  { ad: '＋ Alış Faturası', yol: '/alis-fatura' },
  { ad: '＋ Tahsilat', yol: '/kasa-islem' },
  { ad: '＋ Stok Transfer', yol: '/stok-transfer' },
  { ad: '＋ Görev', yol: '/gorev' },
  { ad: 'Cari Listesi', yol: '/musteri' },
];

/**
 * ANA SAYFA PANELI (Ekranlar/giris_sayfasi.html).
 *
 * YALNIZ GERCEK VERI. Gorev/takvim modulu db/108 ile acildi ve panele baglandi;
 * mockup'taki DUYURULAR hala yok (tablosu yok) - uydurma icerik, panele bakip
 * karar veren kullaniciyi yaniltir.
 *
 * Tek istek (/api/panel) butun kutulari ve listeleri getirir; sube suzgeci
 * sunucuda, oturumun aktif subesine gore uygulanir.
 */
export function Panel() {
  const git = useNavigate();
  const { kullanici } = useOturum();
  const [veri, setVeri] = useState<PanelYaniti | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    void api.panel()
      .then(setVeri)
      .catch(h => setHata(hataMetni(h)))
      .finally(() => setYukleniyor(false));
  }, []);

  const kutuDeger = (deger: number, birim: string) =>
    birim === '₺' ? `${para.format(deger)} ₺` : `${sayi.format(deger)} ${birim}`;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{selam()}, {kullanici?.ad ?? ''}</h1>
          <span className="yol">
            {new Date().toLocaleDateString('tr-TR',
              { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })}
            {/* Hangi profilin panelini gorduguu basligin yaninda: ayni kurulumda
                sube degistirince panel de degisiyor (508). */}
            {veri?.profil?.baslik && <> · <b>{veri.profil.baslik}</b> paneli</>}
          </span>
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <>
            {/* KURUM PROFILINE OZEL PANEL (508, kullanici: "lab da,
                goruntuleme merkezinde veya tip merkezinde ayri dashboardlar
                olsun"). Kutu/blok tanimi SUNUCUDAN (`fn_panel_profil`) gelir;
                burada yalniz cizim var - yeni profil eklemek ekran kodu
                degistirmez. Profil taninmiyorsa asagidaki genel duzen kalir. */}
            {(veri?.profil?.kutular?.length ?? 0) > 0 && (
              <>
                <div className="panel-kutular profil">
                  {veri!.profil!.kutular.map(k => (
                    <button key={k.kod} type="button" className="kpi panel-kpi"
                            onClick={() => k.rota && git(k.rota)}
                            title={k.rota ? 'Listeyi aç' : undefined}>
                      <div className="k">{k.baslik}</div>
                      <div className={`v ${k.vurgu}`}>
                        {k.bicim === 'para' ? `${para.format(Number(k.deger))} ₺`
                                            : sayi.format(Number(k.deger))}
                      </div>
                      <div className="s">{k.alt}</div>
                    </button>
                  ))}
                </div>
                <div className="panel-sutunlar">
                  {veri!.profil!.bloklar.map(b => (
                    <div className="kagrup" key={b.kod}>
                      <h6>
                        {BLOK_IKON[b.kod] && <span className="blok-ikon">{BLOK_IKON[b.kod]}</span>}
                        {b.baslik}{b.ipucu && <span className="sonuk"> · {b.ipucu}</span>}
                      </h6>
                      <table className="detay-tablo">
                        <thead><tr>{b.kolonlar.map((k, i) => (
                          <th key={k} className={b.bicimler?.[i] === 'metin' ? '' : 'hiza-sag'}>{k}</th>
                        ))}</tr></thead>
                        <tbody>
                          {b.satirlar.map((sat, si) => (
                            <tr key={si}>
                              {sat.map((h, hi) => (
                                <td key={hi} className={b.bicimler?.[hi] === 'metin' ? '' : 'hiza-sag'}>
                                  {b.bicimler?.[hi] === 'para' ? para.format(Number(h))
                                   : b.bicimler?.[hi] === 'sayi' ? sayi.format(Number(h)) : h}
                                </td>
                              ))}
                            </tr>
                          ))}
                          {b.satirlar.length === 0 && (
                            <tr><td className="bos" colSpan={b.kolonlar.length}>Kayıt yok.</td></tr>
                          )}
                        </tbody>
                      </table>
                    </div>
                  ))}
                </div>
              </>
            )}

            {/* PROFIL PANELI VARSA GENEL (ERP) BOLUM CIZILMEZ (kullanici:
                "mockup'la birebir aynı görünüm olsun"): klinik kullanicisinin
                ana sayfasinda ay ozeti/stok kutulari ve ERP listeleri isin
                onune geciyordu. Profil taninmiyorsa asagisi aynen kalir. */}
            {(veri?.profil?.kutular?.length ?? 0) === 0 && (<>
            <div className="panel-kutular">
              {(veri?.kutular ?? []).map(k => (
                <button key={k.anahtar} type="button" className="kpi panel-kpi"
                        onClick={() => k.yol && git(k.yol)}
                        title={k.yol ? 'Listeyi aç' : undefined}>
                  <div className="k">{k.baslik}</div>
                  <div className={`v ${k.vurgu}`}>{kutuDeger(Number(k.deger), k.birim)}</div>
                  <div className="s">{k.alt}</div>
                </button>
              ))}
            </div>

            <div className="panel-sutunlar">
              {/* Gorevler ve takvim EN BASTA: gun buradan planlanir. */}
              <div className="kagrup">
                <h6>Görevlerim / Hatırlatmalar</h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.gorevler ?? []).map(s => (
                      <tr key={`g${s.id}`} onDoubleClick={() => git(s.yol)}
                          title="Çift tıkla: görev listesini aç">
                        <td>{s.ana}</td>
                        <td className="sonuk">{s.yan}</td>
                        <td className="hiza-orta">
                          <span className={`rozet ${s.deger === 'Gecikti' ? 'hata'
                                                  : s.deger === 'Devam' ? 'uyari' : ''}`}>
                            {s.deger}
                          </span>
                        </td>
                      </tr>
                    ))}
                    {(veri?.gorevler ?? []).length === 0 && (
                      <tr><td className="bos">Bekleyen görev yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>

              <div className="kagrup">
                <h6>Yaklaşan Takvim <span className="sonuk">(14 gün)</span></h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.takvim ?? []).map(s => (
                      <tr key={`t${s.id}`} onDoubleClick={() => git(s.yol)}>
                        <td className="sonuk">{s.yan}</td>
                        <td>{s.ana}</td>
                        <td className="hiza-orta"><span className="rozet bilgi">{s.deger}</span></td>
                      </tr>
                    ))}
                    {(veri?.takvim ?? []).length === 0 && (
                      <tr><td className="bos">Önümüzdeki iki haftada kayıt yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>

              <div className="kagrup">
                <h6>Son Belgeler</h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.sonBelgeler ?? []).map(s => (
                      <tr key={`b${s.id}`} onDoubleClick={() => git(s.yol)}
                          title="Çift tıkla: listeyi aç">
                        <td>{s.ana}</td>
                        <td className="sonuk">{s.yan}</td>
                        <td className="hiza-sag">{s.deger}</td>
                      </tr>
                    ))}
                    {(veri?.sonBelgeler ?? []).length === 0 && (
                      <tr><td className="bos">Henüz belge yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>

              <div className="kagrup">
                <h6>Kritik Stok <span className="sonuk">(kullanılabilir / minimum)</span></h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.kritikStok ?? []).map(s => (
                      <tr key={`s${s.id}`} onDoubleClick={() => git(s.yol)}>
                        <td><code>{s.ana}</code></td>
                        <td className="sonuk">{s.yan}</td>
                        <td className="hiza-sag"><b className="hata-metin">{s.deger}</b></td>
                      </tr>
                    ))}
                    {(veri?.kritikStok ?? []).length === 0 && (
                      <tr><td className="bos">Minimum seviyenin altında stok yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>

              <div className="kagrup">
                <h6>En Büyük Cari Bakiyeler</h6>
                <table className="detay-tablo">
                  <tbody>
                    {(veri?.buyukBakiyeler ?? []).map(s => (
                      <tr key={`c${s.id}`} onDoubleClick={() => git(s.yol)}>
                        <td>{s.ana}</td>
                        <td className="hiza-orta">
                          <span className={`rozet ${s.yan === 'Alacak' ? 'ok' : 'uyari'}`}>{s.yan}</span>
                        </td>
                        <td className="hiza-sag">{s.deger}</td>
                      </tr>
                    ))}
                    {(veri?.buyukBakiyeler ?? []).length === 0 && (
                      <tr><td className="bos">Bakiyeli cari yok.</td></tr>
                    )}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="kagrup">
              <h6>Hızlı Erişim</h6>
              <div className="gridtb" style={{ padding: 10, flexWrap: 'wrap' }}>
                {HIZLI_ERISIM.map(h => (
                  <button key={h.yol} type="button" className="d" onClick={() => git(h.yol)}>
                    {h.ad}
                  </button>
                ))}
              </div>
            </div>
            </>)}
          </>
        )}
      </div>
    </>
  );
}
