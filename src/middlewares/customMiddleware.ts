import type { NextFetchEvent, NextRequest } from 'next/server'

import type { CustomMiddleware } from './chain'
import createMiddleware from 'next-intl/middleware';


// eslint-disable-next-line @typescript-eslint/no-empty-function
export function middleware(_request: NextRequest) {}

export function customMiddleware(middleware: CustomMiddleware) {
  return async (
    request: NextRequest,
    event: NextFetchEvent,
    // response: NextResponse
  ) => {
    

const md = createMiddleware({
  defaultLocale: 'en',
  locales: ['en', 'es'],
 
  // The `pathnames` object holds pairs of internal and
  // external paths. Based on the locale, the external
  // paths are rewritten to the shared, internal ones.
  pathnames: {
    // If all locales use the same pathname, a single
    // external path can be used for all locales.
    '/': '/',
    '/blog': '/blog',
 
    // If locales use different paths, you can
    // specify each external path per locale.
    '/about': {
      en: '/about',
      es: '/nosotros'
    },
 
    // Dynamic params are supported via square brackets
    '/news/[articleSlug]-[articleId]': {
      en: '/news/[articleSlug]-[articleId]',
      es: '/novedades/[articleSlug]-[articleId]'
    },
 
    // Also (optional) catch-all segments are supported
    '/categories/[...slug]': {
      en: '/categories/[...slug]',
      es: '/categorias/[...slug]'
    }
  }
})
    return middleware(request, event, md(request))
  }
}
