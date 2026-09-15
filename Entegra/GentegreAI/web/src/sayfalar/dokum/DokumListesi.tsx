import type { DokumKaydi, DokumKaynakMeta } from '../../api/sozlesme';
import { tarihSaat } from '../../bilesenler/bicim';
import { GORUNURLUK_ETIKET, degerMetni, yapraklar } from './ortak';

/**
 * DÖKÜMLERİM (mockup "Dökümlerim" sekmesi): benim + rolümle paylaşılan + kurum
 * geneli. `?` işaretli koşul parametredir - çalıştırırken sorulur.
 */
export function DokumListesi({ liste, kaynaklar, seciliId, yukleniyor, onSec, onCalistir, onKopyala, onSil }: {
  liste: DokumKaydi[]; kaynaklar: DokumKaynakMeta[]; seciliId: number; yukleniyor: boolean;
  onSec(d: DokumKaydi): void; onCalistir(d: DokumKaydi): void;
  onKopyala(d: DokumKaydi): void; onSil(d: DokumKaydi): void;
}) {
  const kaynakAdi = (ad: string) => kaynaklar.find(k => k.ad === ad)?.baslik ?? ad;
  return (
    <div className="kagrup">
      <h6>Kayıtlı Dökümler
        <span className="sonuk">benim · rolümle paylaşılan · kurum geneli · çift tık tasarıma açar</span>
      </h6>
      <table className="detay-tablo secilebilir dk-liste">
        <thead><tr>
          <th>Döküm</th><th>Kaynak</th><th>Koşullar</th><th>Çıktı</th>
          <th>Paylaşım</th><th>Son çalıştırma</th><th>Sahibi</th><th style={{ width: 150 }}></th>
        </tr></thead>
        <tbody>
          {liste.map(d => {
            const p = d.tanim.parametreler ?? {};
            const ozet = d.tanim.cikti === 'ozet'
              ? `İstatistik · ${(d.tanim.boyut?.satir ?? []).length + (d.tanim.boyut?.sutun ? 1 : 0)} boyut`
              : `Liste${d.tanim.grup?.length ? ' · gruplu' : ''}`;
            return (
              <tr key={d.id} className={d.id === seciliId ? 'secili' : ''}
                  onDoubleClick={() => onSec(d)}>
                <td><b>{d.ad}</b>{d.aciklama && <div className="sonuk">{d.aciklama}</div>}</td>
                <td>{kaynakAdi(d.kaynak)}</td>
                <td className="dk-cipler">
                  {yapraklar(d.tanim).filter(k => k.alan).slice(0, 4).map((k, i) => (
                    <span key={i} className="rozet gri">
                      {k.alan}{p[k.alan!] ? <i> ?</i> : ` ${degerMetni(k, false).slice(0, 18)}`}
                    </span>
                  ))}
                  {yapraklar(d.tanim).length > 4 && <span className="sonuk">+{yapraklar(d.tanim).length - 4}</span>}
                </td>
                <td>{ozet}</td>
                <td><span className={`rozet ${d.gorunurluk === 0 ? 'gri' : 'mavi'}`}>{GORUNURLUK_ETIKET[d.gorunurluk]}</span></td>
                <td className="sonuk">{d.sonCalisma ? tarihSaat(d.sonCalisma) : '—'}{d.calismaSayisi > 0 && ` · ${d.calismaSayisi}×`}</td>
                <td>{d.sahip}</td>
                <td className="dk-satir-arac">
                  <button className="d bir mini" disabled={d.calistirilabilir === false}
                          title={d.calistirilabilir === false ? 'Kaynağı görme yetkiniz yok' : 'Çalıştır'}
                          onClick={() => onCalistir(d)}>▶</button>
                  <button className="d mini" title="Tasarla" onClick={() => onSec(d)}>✎</button>
                  <button className="d mini" title="Kopyala" onClick={() => onKopyala(d)}>⧉</button>
                  {d.duzenlenebilir && <button className="d mini" title="Sil" onClick={() => onSil(d)}>🗑</button>}
                </td>
              </tr>
            );
          })}
          {liste.length === 0 && (
            <tr><td colSpan={8} className="bos">{yukleniyor ? 'Yükleniyor…' : 'Henüz kayıtlı döküm yok — "Yeni Döküm" ile başlayın.'}</td></tr>
          )}
        </tbody>
      </table>
      <div className="pano-not">
        <b>?</b> işaretli koşul <b>parametredir</b>: değeri kaydedilmez, döküm her çalıştırıldığında
        sorulur. Bir kez tasarla, her ay farklı tarih aralığıyla çalıştır.
      </div>
    </div>
  );
}
