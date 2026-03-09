---
name: daisyui
description: Use DaisyUI 5 components, colors, and config with Tailwind CSS 4
---

# DaisyUI 5

DaisyUI 5 is a CSS component library for Tailwind CSS 4. It adds semantic class names for common UI components.

- [DaisyUI 5 docs](https://daisyui.com)
- [DaisyUI 5 release notes](https://daisyui.com/docs/v5/)

## Config

```css
@plugin "daisyui" {
  themes:
    light --default,
    dark --prefersdark;
  root: ":root";
  include:;
  exclude:;
  prefix:;
  logs: true;
}
```

- `themes`: list of enabled themes; `--default` sets the default, `--prefersdark` sets the dark mode default
- `exclude`: comma-separated list of things to exclude (e.g. `rootscrollgutter`, `checkbox`)
- `prefix`: add a prefix to all daisyUI classes (e.g. `daisy-` → `daisy-btn`)
- All built-in themes: `light, dark, cupcake, bumblebee, emerald, corporate, synthwave, retro, cyberpunk, valentine, halloween, garden, forest, aqua, lofi, pastel, fantasy, wireframe, black, luxury, dracula, cmyk, autumn, business, acid, lemonade, night, coffee, winter, dim, nord, sunset, caramellatte, abyss, silk`

## Usage Rules

1. Style elements by combining a component class, optional part classes, and optional modifier classes
2. Customize with Tailwind CSS utility classes (e.g. `btn px-10`)
3. Use `!` suffix to force override when specificity conflicts arise (e.g. `btn bg-red-500!`) — last resort only
4. If a component doesn't exist, build it with Tailwind CSS utilities
5. Flex/grid layouts must be responsive using Tailwind responsive prefixes
6. Only use existing daisyUI class names or Tailwind CSS utility classes — no custom CSS unless unavoidable
7. Avoid writing custom CSS; prefer daisyUI classes or Tailwind utilities

## Color System

### Semantic Color Names

| Color               | Purpose                 |
| ------------------- | ----------------------- |
| `primary`           | Main brand color        |
| `primary-content`   | Foreground on primary   |
| `secondary`         | Secondary brand color   |
| `secondary-content` | Foreground on secondary |
| `accent`            | Accent brand color      |
| `accent-content`    | Foreground on accent    |
| `neutral`           | Neutral dark color      |
| `neutral-content`   | Foreground on neutral   |
| `base-100`          | Page background         |
| `base-200`          | Slightly darker surface |
| `base-300`          | Even darker surface     |
| `base-content`      | Foreground on base      |
| `info`              | Informational           |
| `info-content`      | Foreground on info      |
| `success`           | Success/safe            |
| `success-content`   | Foreground on success   |
| `warning`           | Warning/caution         |
| `warning-content`   | Foreground on warning   |
| `error`             | Error/danger            |
| `error-content`     | Foreground on error     |

### Color Rules

- Use daisyUI color names (e.g. `bg-primary`) so colors adapt automatically per theme
- No need for `dark:` variants with daisyUI colors
- Avoid Tailwind color names (e.g. `text-gray-800`) for text/background — they won't adapt to dark themes
- `*-content` colors must contrast well with their paired color
- Use `base-*` colors for most of the page; use `primary` for important/call-to-action elements
- Use `base-200` for navbar and footer backgrounds

## Component Categories

Component reference is split by category. Read the relevant file when working with those components:

- **[Actions](./actions.md)** — `button`, `dropdown`, `fab`, `modal`, `swap`
- **[Data Display](./data-display.md)** — `accordion`, `avatar`, `badge`, `card`, `carousel`, `chat`, `collapse`, `countdown`, `diff`, `hover-3d`, `hover-gallery`, `indicator`, `kbd`, `list`, `stat`, `table`, `timeline`
- **[Navigation](./navigation.md)** — `breadcrumbs`, `dock`, `drawer`, `footer`, `link`, `menu`, `navbar`, `pagination`, `steps`, `tab`
- **[Feedback](./feedback.md)** — `alert`, `loading`, `progress`, `radial-progress`, `skeleton`, `toast`
- **[Data Input](./data-input.md)** — `checkbox`, `file-input`, `filter`, `input`, `label`, `radio`, `range`, `rating`, `select`, `textarea`, `toggle`, `validator`
- **[Layout](./layout.md)** — `calendar`, `divider`, `fieldset`, `hero`, `join`, `mask`, `text-rotate`
- **[Mockup](./mockup.md)** — `mockup-browser`, `mockup-code`, `mockup-phone`, `mockup-window`
