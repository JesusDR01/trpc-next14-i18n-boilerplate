import {
  createTRPCProxyClient,
  loggerLink,
  unstable_httpBatchStreamLink,
} from "@trpc/client";
import { cookies } from "next/headers";

import { type AppRouter } from "~/server/api/root";
import { getUrl, transformer } from "./shared";

export const api = createTRPCProxyClient<AppRouter>({
  transformer,
  links: [
    loggerLink({
      enabled: (op) =>
        process.env.NODE_ENV === "development" ||
        (op.direction === "down" && op.result instanceof Error),
    }),
    unstable_httpBatchStreamLink({
      // fetch: fetchPonyfill().fetch,

      url: getUrl(),
      headers() {
        return {
          cookie: cookies().toString(),
          "x-trpc-source": "rsc",
        };
      },
    }),
  ],
});


// createTRPCProxyClient<AppRouter>({
//   transformer,
//   links: [
//     devtoolsLink({
//       enabled: process.env.NODE_ENV === 'development',
//     }),
//     splitLink({
//       condition(op) {
//         // check for context property `skipBatch`
//         return op.context.skipBatch === true
//       },
//       // when condition is true, use normal request
//       true: httpLink({
//         // vercel issue with fetch undici
//         fetch: fetchPonyfill().fetch,
//         url: `${getBaseUrl()}/api/trpc`,
//       }),
//       // when condition is false, use batching
//       false: httpBatchLink({
//         fetch: fetchPonyfill().fetch,
//         url: `${getBaseUrl()}/api/trpc`,
//       }),
//     }),
//     loggerLink({
//       enabled: (opts) => opts.direction === 'down' && opts.result instanceof Error,
//     }),
//   ],
// })