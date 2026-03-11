# Brand Style Guide — mrjonesbot.com

## Design System

The complete brand CSS is in `app/assets/stylesheets/application.css`.

**Aesthetic**: Bento Grid layout with purple accent colors, optimized for light + dark modes.

## Fonts

- **Sans**: `Sora` (300, 400, 600) — headings, body copy
- **Mono**: `JetBrains Mono` (300, 400, 500) — code, labels

## Color Tokens

### Light Mode
- `--bg-base`: #f5f4f0 (page background)
- `--bg-card`: #ffffff (card surface)
- `--accent`: #8060ff (primary purple)
- `--text-primary`: #1a1625
- `--text-secondary`: #5a5070

### Dark Mode
- `--bg-base`: #0e0e12
- `--bg-card`: #1a1a24
- `--accent`: #8060ff (same)
- `--text-primary`: #e8e6f4
- `--text-secondary`: #8880a8

## Components

### Cards
```html
<div class="card col-span-2">
  <p class="card__label">Label</p>
  <h2 class="card__title">Title</h2>
  <p class="card__body">Body text</p>
</div>
```

**Variants**: `.card--accent`, `.card--subtle`, `.card--inverse`, `.card--ghost`

### Buttons
```html
<a href="/path" class="btn btn--primary">Primary</a>
<a href="/path" class="btn btn--secondary">Secondary</a>
<a href="/path" class="btn btn--ghost">Ghost</a>
<a href="/path" class="btn btn--mono">Mono</a>
```

**Sizes**: `.btn--sm`, `.btn--lg`

### Tags
```html
<span class="tag tag--rails">Rails</span>
<span class="tag tag--postgres">PostgreSQL</span>
<span class="tag tag--hotwire">Hotwire</span>
<span class="tag tag--accent">Accent</span>
```

**Tech stack colors**: rails, postgres, hotwire, redis, sidekiq, stripe

### Status Indicator
```html
<div class="status status--available">
  <span class="status__dot"></span>
  Open to work
</div>
```

## Layout

### Bento Grid
```html
<div class="bento-grid">
  <div class="card col-span-2">...</div>
  <div class="card col-span-1">...</div>
  <div class="card col-span-1">...</div>
</div>
```

**Responsive**: 4 cols → 2 cols (tablet) → 1 col (mobile)

## Typography Classes

- `.text-display` — 40px, semibold, tight leading
- `.text-heading` — 24px, semibold
- `.text-subheading` — 20px, semibold
- `.text-body` — 15px, regular
- `.text-caption` — 11px, semibold, uppercase, wide tracking
- `.text-mono` — monospace, 13px
- `.text-accent` — purple accent color

## Utility Classes

**Spacing**: `.p-4`, `.p-6`, `.mt-4`, `.mb-6`, etc.
**Borders**: `.border`, `.border-medium`, `.border-accent`, `.rounded-lg`
**Flex**: `.flex`, `.flex-col`, `.items-center`, `.justify-between`, `.gap-4`
**Backgrounds**: `.bg-base`, `.bg-card`, `.bg-accent`

## Dark Mode

Automatically respects `prefers-color-scheme: dark`.

To force dark mode: `<html data-theme="dark">` or `<body class="dark">`

## Design Principles

1. **Bento Grid First**: Use `.bento-grid` for primary layouts
2. **Card Components**: Prefer card-based UI with clear hierarchy
3. **Purple Accent**: Use `--accent` / `.text-accent` / `.btn--primary` for CTAs
4. **Consistent Spacing**: Use CSS variables (`--space-4`, `--space-6`, etc.)
5. **Light + Dark**: Always test both modes
