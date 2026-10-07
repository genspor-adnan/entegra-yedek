/** `vekil.mjs` düz JS: Node tarafında hem Vite hem kendi sunucumuz çağırıyor. */
import type { IncomingMessage, ServerResponse } from 'node:http';

export function vekilAraKatmani(
  istek: IncomingMessage,
  yanit: ServerResponse,
  sonraki: () => void,
): void;
