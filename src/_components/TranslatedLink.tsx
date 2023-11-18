"use-client";

import Link from "next/link";

const pathTranslations = {
  en: {
    "/about": "/about",
  },
  es: {
    "/about": "/nosotros",
  },
};

type AvailableLinks = keyof (typeof pathTranslations)["en"];

const TranslatedLink = ({
  href,
  children,
  locale,
}: {
  href: AvailableLinks;
  children: JSX.Element;
  locale?: string;
}) => {
  const localePath = locale as keyof typeof pathTranslations;
  // Get translated route for non-default locales
  const translatedPath = pathTranslations[localePath]?.[href];
  // Set `as` prop to change displayed URL in browser
  const as = translatedPath ? `/${locale}${translatedPath}` : undefined;

  return (
    <Link href={href} as={as}>
      {children}
    </Link>
  );
};

export default TranslatedLink;
