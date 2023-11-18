import React from "react";
import { getDictionary } from "get-dictionary";
import type { Locale } from "i18n.config";

export default async function about({
  params: { lang },
}: {
  params: { lang: Locale };
}) {
  const dictionary = await getDictionary(lang);
  return (
    <div>
      <p>{dictionary.page.about.title}</p>
      <p>{dictionary.page.about.description}</p>
    </div>
  );
}
