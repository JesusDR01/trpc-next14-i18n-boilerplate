import { chain } from '~/middlewares/chain'
import { withI18nMiddleware } from '~/middlewares/middleware2'
import { customMiddleware } from '~/middlewares/customMiddleware'

export default chain([withI18nMiddleware, customMiddleware])

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)']
}