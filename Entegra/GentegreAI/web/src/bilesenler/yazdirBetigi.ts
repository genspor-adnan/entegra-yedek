/**
 * YAZDIRMA PENCERESİNİN TEK BETİĞİ (kod inceleme 30.10.2026 K61 - CSP): `document.write` ile açılan yazdırma
 * pencereleri ana sayfanın içerik güvenlik politikasını devralır; satır içi betik yalnız HASH'i politikada
 * olan metinse çalışır. Bütün yazdırma pencereleri bu metni kullanır - değişirse hash derlemede yeniden
 * hesaplanır (csp.ts), ayrıca bir şey gerekmez. Metin tek satır ve sabit kalmalı.
 */
export const YAZDIR_BETIGI = 'addEventListener("load",function(){setTimeout(function(){print()},400)})';

/** `<script>` etiketiyle - HTML'e gömülecek hâli. */
export const YAZDIR_ETIKETI = `<script>${YAZDIR_BETIGI}</script>`;
