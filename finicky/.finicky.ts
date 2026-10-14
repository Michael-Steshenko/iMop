// ~/.finicky.ts — routes each local rimt-ui workspace to its own Chrome profile
// so cookies (auth tokens) stay separate per workspace.
import type { FinickyConfig } from '/Applications/Finicky.app/Contents/Resources/finicky.d.ts';

const chrome = (profile: string) => ({ name: 'Google Chrome', profile });

export default {
  // everything that doesn't match a handler opens in the main profile
  defaultBrowser: chrome('Michael'),
  // no menu bar icon; open Finicky.app directly to get its window
  options: { hideIcon: true },
  handlers: [
    { match: (url) => url.host === 'localhost:9441', browser: chrome('Michael') },
    { match: (url) => url.host === 'localhost:9442', browser: chrome('Michael 2') },
    { match: (url) => url.host === 'localhost:9443', browser: chrome('Michael 3') },
    { match: (url) => url.host === 'localhost:9444', browser: chrome('Michael 4') },
  ],
} satisfies FinickyConfig;
