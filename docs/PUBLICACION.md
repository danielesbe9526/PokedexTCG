# Publicación en la App Store

Guía para publicar **Binderly** reduciendo el riesgo de rechazo (guía 5.2.1 de Apple) y de reclamos de
propiedad intelectual. No es asesoría legal: antes de cobrar o promocionar la app, consúltalo con un
abogado de propiedad intelectual.

## Qué se cambió en la app

| Antes | Ahora | Por qué |
|---|---|---|
| Nombre "Pokédex" / PokedexPTC | **Binderly** (nombre visible, producto y bundle id `daniel.beltran.binderly`) | "Pokédex" es marca registrada |
| Ícono de Bellsprout | Ícono original (cartas con destello) | Era un personaje con copyright |
| Pokébola, íconos de tipos y etiquetas oficiales | Eliminados; energías dibujadas con SF Symbols | Arte de terceros |
| Pokédex con artwork oficial (PokeAPI) | Eliminada | Artwork oficial = mayor riesgo |
| — | Colección local con valor estimado (SwiftData) | Funcionalidad propia; evita rechazo por "app de contenido ajeno" |
| — | Pantalla "Acerca de" con aviso legal y fuentes | Deja claro que no es oficial |
| — | `PrivacyInfo.xcprivacy` y `ITSAppUsesNonExemptEncryption = NO` | Requisitos de envío |

**Riesgo que sigue:** las imágenes de las cartas (servidas por TCGdex) tienen copyright. Apps similares
(colecciones y precios) están publicadas, pero un reclamo del titular podría hacer que Apple retire la app.
Si llega un aviso, la salida es quitar las imágenes y dejar solo datos y precios.

## Antes de enviar

- [ ] Comprobar que el nombre "Binderly" esté libre: App Store Connect (al crear la app), USPTO/EUIPO y
      la oficina de marcas de tu país. Si no, cámbialo en `INFOPLIST_KEY_CFBundleDisplayName`.
- [ ] Aceptar el Program License Agreement pendiente en developer.apple.com.
- [ ] Crear el App ID `daniel.beltran.binderly` (Xcode lo hace solo con firma automática).
- [ ] Publicar una política de privacidad (puede ser una página simple: "no recopilamos datos").
- [ ] Capturas **sin** la palabra Pokémon en textos superpuestos; mostrar la colección y el buscador.
- [ ] Privacidad en App Store Connect: "Data Not Collected".
- [ ] Categoría: Utilidades (o Estilo de vida). **No** usar la categoría Juegos.
- [ ] Clasificación por edad: 4+.

## Reglas para la ficha

- No usar "Pokémon", "Pokédex", "Pikachu", etc. en el **nombre**, **subtítulo**, **ícono** ni
  **palabras clave**. Apple rechaza las palabras clave con marcas de terceros.
- En la descripción se puede mencionar el juego **solo para describir compatibilidad** y siempre con el
  aviso legal al final.
- No decir "oficial", ni usar logos, tipografías o colores de marca del juego.

## Texto sugerido

**Nombre:** Binderly
**Subtítulo:** Colección de cartas y precios

**Descripción (es):**

> Binderly te ayuda a organizar tu colección de cartas coleccionables y saber cuánto vale.
>
> • Explora todas las expansiones, de la más reciente a la más antigua.
> • Busca cualquier carta por nombre.
> • Añade cartas a tu colección indicando variante (normal, holo, reverse holo) y cantidad.
> • Consulta el valor estimado de tu colección con precios de mercado de TCGplayer y Cardmarket.
> • Actualiza los precios cuando quieras.
> • Tu colección se guarda solo en tu dispositivo: sin cuentas y sin recopilar datos.
>
> Compatible con cartas del juego de cartas coleccionables Pokémon.
>
> Binderly es una app no oficial hecha por fans. No está afiliada, respaldada, patrocinada ni aprobada por
> Nintendo, Creatures Inc., GAME FREAK inc. ni The Pokémon Company. Pokémon y los nombres relacionados son
> marcas registradas de sus respectivos dueños. Datos de cartas: TCGdex. Los precios son estimaciones.

**Palabras clave:** colección,cartas,tcg,coleccionables,binder,precios,valor,tracker,cartas coleccionables

**Notas para el revisor (App Review):**

> Binderly is a collection tracker for trading card collectors. Card data is retrieved from the public
> TCGdex API (tcgdex.dev). The app is clearly labeled as unofficial in the About screen and the
> description. It does not use any trademark in its name, icon or keywords, and collects no user data.
