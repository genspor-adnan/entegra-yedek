import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { YatakSecenegi, YatisOzeti } from '../../api/uclar/yatan';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';
import { mesaj } from '../mesaj';
import { YatakSecimi } from './YatakSecimi';

/**
 * NAKİL / YATAK DEĞİŞİMİ — mockup `Ekranlar/Yatan/nakil_yatak_degisim.html`.
 *
 * <b>Nakil yeni bir yatış değildir:</b> aynı yatışın yatağı değişir
 * (`yatis_yatak` satırı kapanır, yenisi açılır). Yeni yatış açılsaydı order'lar,
 * izlem ve gün sayısı sıfırlanır; hasta altıncı gününde "birinci gün"
 * görünürdü. Bu yüzden ekranda "nakille birlikte taşınanlar" kutusu var:
 * taşınan şey aslında hiçbir şey — kayıt aynı kayıt.
 *
 * <b>Ücret sınıfı değişimi UYARIDIR, engel değil.</b> Yoğun bakıma çıkan
 * hastanın yatak ücreti elbette değişir; sessiz kalmak farkı faturada gören
 * hastaya bırakmak olurdu.
 *
 * <b>Eski yatak "boş" değil "temizlik bekliyor" olur</b> — nakil de taburcu
 * gibi arkasında yapılmamış bir yatak bırakır.
 */

interface KodDeger { deger: number; ad: string }

export function NakilModali({ yatisId, onKapat, onTamam }: {
  yatisId: number;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [ozet, setOzet] = useState<YatisOzeti | null>(null);
  const [yatak, setYatak] = useState<YatakSecenegi | null>(null);
  const [neden, setNeden] = useState(2);
  const [nedenler, setNedenler] = useState<KodDeger[]>([]);
  const [aciklama, setAciklama] = useState('');
  const [hekimId, setHekimId] = useState<number | null>(null);
  const [hekimAdi, setHekimAdi] = useState('');
  const [hekimArama, setHekimArama] = useState(false);
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  useEffect(() => {
    void (async () => {
      try { setOzet(await api.yatisOzeti(yatisId)) } catch { setHata('Yatış okunamadı.') }
      try {
        const n = await api.kodListe('yatan.nakil_neden');
        setNedenler(n.degerler.filter(d => d.aktif === 1 && d.deger !== 1));
      } catch { /* kod listesi zorunlu değil */ }
    })();
  }, [yatisId]);

  const kaydet = async () => {
    if (!yatak) { setHata('Hedef yatak seçilmeli.'); return }
    setHata('');
    setKaydediyor(true);
    try {
      const y = await api.yatisNakil(yatisId, {
        yatakId: yatak.id, neden, aciklama,
        departmanId: yatak.departmanId, hekimId,
      });
      mesaj(y.uyari ? `Nakil yapıldı — ${y.uyari}` : `Nakil yapıldı: ${y.oda}/${y.yatak}`);
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  const o = ozet?.ozet;
  // KLİNİK DEĞİŞİYORSA NAKİL AYNI ZAMANDA HEKİM DEVRİDİR: "hastayı kim takip
  //   ediyor" sorusunun cevapsız kaldığı saatler, yatan hastadaki en sık aksama.
  const klinikDegisiyor = !!(yatak?.klinik && o?.klinik && yatak.klinik !== o.klinik);

  return (
    <>
      <TarafArama
        acik={hekimArama}
        kaynaklar={['basvuru-hekim']}
        yerTutucu="Devralan hekimi ara…"
        onKapat={() => setHekimArama(false)}
        onSec={s => { setHekimId(s.id); setHekimAdi(s.unvan); setHekimArama(false) }}
      />

      <Modal baslik="🔀 Nakil / Yatak Değişimi" onKapat={onKapat}
             ustBilgi={o ? `${o.hasta} · ${o.yatak || '—'} · ${o.gun}. gün` : undefined}
             alt={
               <>
                 <button className="d onay" disabled={kaydediyor || !yatak}
                         onClick={() => void kaydet()}>✔ Nakli Uygula</button>
                 <button className="d" onClick={onKapat}>✖ Kapat</button>
               </>
             }>
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="kagrup">
          <h6>Nakil <span>mevcut → hedef</span></h6>
          <div className="ic">
            <div className="sat"><span>Mevcut yatak</span>
              <b>{o?.yatak || '—'}<span className="sonuk"> · {o?.klinik || '—'}</span></b></div>
            <div className="sat"><span>Hedef yatak</span>
              <b>{yatak ? `${yatak.oda} / ${yatak.yatak}` : '— seçilmedi'}
                 {yatak?.ucretHizmet && <span className="sonuk"> · {yatak.ucretHizmet}</span>}</b></div>
            {klinikDegisiyor && (
              <div className="sat"><span>Klinik</span>
                <b>{o?.klinik} → {yatak?.klinik}
                   <span className="rozet sari"> hekim devri gerekir</span></b></div>
            )}
          </div>
        </div>

        <div className="alan-izgara" style={{ marginTop: 8 }}>
          <label className="alan">
            <span className="etiket">Nakil sebebi</span>
            <select value={neden} onChange={e => setNeden(Number(e.target.value))}>
              {nedenler.map(n => <option key={n.deger} value={n.deger}>{n.ad}</option>)}
            </select>
          </label>
          <label className="alan">
            <span className={`etiket${klinikDegisiyor ? ' zorunlu-isaret' : ''}`}>
              Sorumlu hekim
            </span>
            <span className="deger-serit">
              <input readOnly style={{ flex: 1, minWidth: 0 }} value={hekimAdi} placeholder={o?.hekim || 'Değişmiyor'}
                     onClick={() => setHekimArama(true)} />
              <button className="d" onClick={() => setHekimArama(true)}>🔍</button>
            </span>
          </label>
          <label className="alan" style={{ gridColumn: '1 / -1' }}>
            <span className="etiket">Açıklama</span>
            <input value={aciklama} placeholder="örn. dirençli üreme, damlacık izolasyonu"
                   onChange={e => setAciklama(e.target.value)} />
          </label>
        </div>

        <h4 style={{ margin: '10px 0 4px' }}>Hedef yatak seçimi</h4>
        {o && (
          // HASTA ID ÖZETTEN gelir: uygunluk hastanın cinsiyetine bağlı ve
          //   hastanın MEVCUT yatağı listede seçilemez olmalı.
          <YatakSecimi hastaId={o.hastaId} seciliId={yatak?.id ?? null}
                       haricYatakId={o.yatakId} onSec={y => setYatak(y)} />
        )}

        <div className="not" style={{ marginTop: 8 }}>
          Nakil <b>yeni bir yatış değildir</b>: aynı yatışın yatağı değişir. Açık
          order'lar, izlem, sıvı takibi ve gün sayısı kesintisiz sürer. Eski yatak
          <b> temizlik bekliyor</b> durumuna düşer, yeni yatak dolu olur; yatak
          ücreti hareket saatinden itibaren yeni tarifeyle işler.
        </div>
      </Modal>
    </>
  );
}
