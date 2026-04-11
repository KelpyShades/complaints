# Student Complaints Management System — UI Design Instructions

## 1. Design Philosophy & Direction

### Core Concept: "Adaptive Authority & Support"

The design follows a **2×2 theme matrix** — two portals (Admin/Student) × two modes (Light/Dark). Each combination maintains its portal's core personality while respecting user preference for light or dark viewing.

| Portal | Light Mode | Dark Mode |
|--------|------------|-----------|
| **Admin** | Clean command center — high contrast, crisp edges, professional clarity | Midnight mission control — focused, immersive, data-forward |
| **Student** | Warm companion — approachable, reassuring, breathable | Calm night mode — gentle, easy on eyes, still supportive |

### Visual Identity Pillars

1. **Consistent Structure**: Layouts, spacing, and component architecture remain identical across all themes
2. **Portal Personality**: Admin always feels "authoritative" — Student always feels "supportive"
3. **Mode Adaptation**: Light = airy, high contrast; Dark = focused, reduced eye strain
4. **Tactile Feedback**: Every interactive element responds with weight and intention

---

## 2. Color Systems

### 2.1 Admin Portal Colors

#### Admin Light Mode — "Day Command"

```css
/* Backgrounds */
--admin-light-bg-primary: #FFFFFF              /* Pure white base */
--admin-light-bg-secondary: #F8FAFC            /* Subtle cool gray surfaces */
--admin-light-bg-tertiary: #F1F5F9             /* Cards, inputs */
--admin-light-bg-elevated: #FFFFFF             /* Popovers, modals */

/* Borders */
--admin-light-border: #E2E8F0                  /* Subtle separation */
--admin-light-border-strong: #CBD5E1           /* Focus, hover */
--admin-light-border-divider: #F1F5F9          /* Section dividers */

/* Text */
--admin-light-text-primary: #0F172A            /* Headlines, critical data */
--admin-light-text-secondary: #475569          /* Body, labels */
--admin-light-text-muted: #94A3B8              /* Timestamps, hints */
--admin-light-text-placeholder: #CBD5E1        /* Input placeholders */

/* Accent — Indigo */
--admin-light-accent-primary: #4F46E5          /* Primary actions */
--admin-light-accent-secondary: #6366F1        /* Highlights, selections */
--admin-light-accent-hover: #4338CA            /* Hover states */
--admin-light-accent-subtle: #EEF2FF           /* Subtle backgrounds */

/* Status Colors */
--admin-light-status-pending: #D97706          /* Amber - text */
--admin-light-status-pending-bg: #FEF3C7       /* Amber - background */
--admin-light-status-progress: #2563EB         /* Blue - text */
--admin-light-status-progress-bg: #DBEAFE      /* Blue - background */
--admin-light-status-resolved: #059669         /* Green - text */
--admin-light-status-resolved-bg: #D1FAE5      /* Green - background */
--admin-light-status-rejected: #DC2626         /* Red - text */
--admin-light-status-rejected-bg: #FEE2E2      /* Red - background */

/* Semantic */
--admin-light-success: #059669
--admin-light-warning: #D97706
--admin-light-error: #DC2626
--admin-light-info: #2563EB

/* Chart Colors */
--admin-light-chart-1: #4F46E5
--admin-light-chart-2: #059669
--admin-light-chart-3: #D97706
--admin-light-chart-4: #DC2626
```

#### Admin Dark Mode — "Night Control"

```css
/* Backgrounds */
--admin-dark-bg-primary: #0B0D10               /* Deep void */
--admin-dark-bg-secondary: #111418             /* Surfaces */
--admin-dark-bg-tertiary: #1A1E24              /* Cards, inputs */
--admin-dark-bg-elevated: #21262D              /* Popovers, modals */

/* Borders */
--admin-dark-border: #2A3039                   /* Subtle separation */
--admin-dark-border-strong: #3D4654            /* Focus, hover */
--admin-dark-border-divider: #1E2229           /* Section dividers */

/* Text */
--admin-dark-text-primary: #F8FAFC             /* Headlines */
--admin-dark-text-secondary: #94A3B8           /* Body, labels */
--admin-dark-text-muted: #64748B               /* Timestamps */
--admin-dark-text-placeholder: #475569         /* Placeholders */

/* Accent — Indigo (brighter for dark) */
--admin-dark-accent-primary: #818CF8           /* Primary actions */
--admin-dark-accent-secondary: #A5B4FC         /* Highlights */
--admin-dark-accent-hover: #6366F1             /* Hover */
--admin-dark-accent-subtle: #312E81            /* Subtle backgrounds */

/* Status Colors (brighter for visibility) */
--admin-dark-status-pending: #FBBF24           /* Amber */
--admin-dark-status-pending-bg: #451A03        /* Amber bg */
--admin-dark-status-progress: #60A5FA          /* Blue */
--admin-dark-status-progress-bg: #172554       /* Blue bg */
--admin-dark-status-resolved: #34D399          /* Green */
--admin-dark-status-resolved-bg: #064E3B       /* Green bg */
--admin-dark-status-rejected: #F87171          /* Red */
--admin-dark-status-rejected-bg: #450A0A       /* Red bg */

/* Semantic */
--admin-dark-success: #34D399
--admin-dark-warning: #FBBF24
--admin-dark-error: #F87171
--admin-dark-info: #60A5FA

/* Chart Colors */
--admin-dark-chart-1: #818CF8
--admin-dark-chart-2: #34D399
--admin-dark-chart-3: #FBBF24
--admin-dark-chart-4: #F87171
```

---

### 2.2 Student Portal Colors

#### Student Light Mode — "Day Companion"

```css
/* Backgrounds — Warm undertones */
--student-light-bg-primary: #FAF9F7            /* Warm off-white */
--student-light-bg-secondary: #FFFFFF          /* Pure white surfaces */
--student-light-bg-tertiary: #F5F3EF           /* Warm gray cards */
--student-light-bg-elevated: #FFFFFF           /* Popovers */

/* Borders */
--student-light-border: #E8E4DE                /* Warm separation */
--student-light-border-strong: #D4CFC6         /* Focus states */
--student-light-border-divider: #F0EDE8        /* Dividers */

/* Text */
--student-light-text-primary: #1C1917          /* Warm black */
--student-light-text-secondary: #57534E        /* Warm gray */
--student-light-text-muted: #A8A29E            /* Muted */
--student-light-text-placeholder: #D6D3D1      /* Placeholders */

/* Accent — Emerald */
--student-light-accent-primary: #059669        /* Primary */
--student-light-accent-secondary: #10B981      /* Highlights */
--student-light-accent-hover: #047857          /* Hover */
--student-light-accent-subtle: #ECFDF5         /* Subtle bg */

/* Status Colors */
--student-light-status-pending: #B45309        /* Amber */
--student-light-status-pending-bg: #FEF3C7     /* Amber bg */
--student-light-status-progress: #1D4ED8       /* Blue */
--student-light-status-progress-bg: #DBEAFE    /* Blue bg */
--student-light-status-resolved: #047857       /* Green */
--student-light-status-resolved-bg: #D1FAE5    /* Green bg */
--student-light-status-rejected: #B91C1C       /* Red */
--student-light-status-rejected-bg: #FEE2E2    /* Red bg */

/* Semantic */
--student-light-success: #047857
--student-light-warning: #B45309
--student-light-error: #B91C1C
--student-light-info: #1D4ED8

/* Warm Highlights */
--student-light-warm-bg: #FEF9C3
--student-light-cool-bg: #ECFDF5
```

#### Student Dark Mode — "Night Companion"

```css
/* Backgrounds — Warm darks */
--student-dark-bg-primary: #0C0A09             /* Warm black */
--student-dark-bg-secondary: #1C1917           /* Surfaces */
--student-dark-bg-tertiary: #292524            /* Cards */
--student-dark-bg-elevated: #44403C            /* Popovers */

/* Borders */
--student-dark-border: #44403C                 /* Separation */
--student-dark-border-strong: #57534E          /* Focus */
--student-dark-border-divider: #292524         /* Dividers */

/* Text */
--student-dark-text-primary: #FAFAF9           /* Headlines */
--student-dark-text-secondary: #A8A29E         /* Body */
--student-dark-text-muted: #78716C             /* Timestamps */
--student-dark-text-placeholder: #57534E       /* Placeholders */

/* Accent — Emerald (brighter) */
--student-dark-accent-primary: #34D399         /* Primary */
--student-dark-accent-secondary: #6EE7B7       /* Highlights */
--student-dark-accent-hover: #10B981           /* Hover */
--student-dark-accent-subtle: #064E3B          /* Subtle bg */

/* Status Colors */
--student-dark-status-pending: #FCD34D         /* Amber */
--student-dark-status-pending-bg: #451A03      /* Amber bg */
--student-dark-status-progress: #60A5FA        /* Blue */
--student-dark-status-progress-bg: #172554     /* Blue bg */
--student-dark-status-resolved: #34D399        /* Green */
--student-dark-status-resolved-bg: #064E3B     /* Green bg */
--student-dark-status-rejected: #FCA5A5        /* Red */
--student-dark-status-rejected-bg: #450A0A     /* Red bg */

/* Semantic */
--student-dark-success: #34D399
--student-dark-warning: #FCD34D
--student-dark-error: #FCA5A5
--student-dark-info: #60A5FA
```

---

## 3. Typography System

### Font Families (Universal)

```css
/* Display & Headlines */
--font-display: 'Space Grotesk', system-ui, sans-serif

/* Body & UI */
--font-body: 'DM Sans', system-ui, sans-serif

/* Data, IDs, Code */
--font-mono: 'JetBrains Mono', 'SF Mono', monospace
```

### Type Scale

| Token | Size | Weight | Line Height | Letter Spacing | Usage |
|-------|------|--------|-------------|----------------|-------|
| --text-hero | 48px / 40px mobile | 700 | 1.1 | -0.02em | Dashboard stats |
| --text-h1 | 32px / 28px mobile | 700 | 1.2 | -0.01em | Screen titles |
| --text-h2 | 24px / 22px mobile | 600 | 1.3 | 0 | Section headers |
| --text-h3 | 18px | 600 | 1.4 | 0 | Card titles |
| --text-h4 | 16px | 600 | 1.4 | 0 | Subsection |
| --text-body | 16px | 400 | 1.6 | 0 | Paragraphs |
| --text-body-sm | 14px | 400 | 1.5 | 0 | Secondary text |
| --text-small | 14px | 500 | 1.4 | 0 | Labels |
| --text-xs | 12px | 500 | 1.4 | 0.01em | Badges, timestamps |
| --text-mono | 14px | 500 | 1.3 | 0.02em | IDs, codes |

### Typography Rules

```
1. IDs & Reference Numbers:
   - Font: monospace
   - Uppercase
   - Letter-spacing: 0.05em
   - Example: #COM-2024-001

2. Status Badges:
   - Uppercase
   - Font-size: 11px
   - Letter-spacing: 0.08em
   - Font-weight: 600

3. Dashboard Numbers:
   - Font-variant-numeric: tabular-nums
   - Prevents number width shifting

4. Line Clamp:
   - Descriptions: max 2 lines
   - Overflow: ellipsis

5. Screen Titles:
   - Always sentence case
   - Never all caps
```

---

## 4. Component Specifications

### 4.1 Status Badge

```
Shape: Pill (border-radius: 9999px)
Padding: 6px 12px (mobile), 8px 16px (desktop)
Font: 11px uppercase, weight 600, letter-spacing 0.08em

┌─────────────────────────────────────────────────────────────┐
│ STATUS BADGE VARIANTS (All Themes)                          │
├─────────────┬───────────────────────────────────────────────┤
│ Status      │ Light Mode Style                              │
├─────────────┼───────────────────────────────────────────────┤
│ Pending     │ bg: Amber-100, text: Amber-800, border: none  │
│ In Progress │ bg: Blue-100, text: Blue-800, border: none    │
│ Resolved    │ bg: Green-100, text: Green-800, border: none  │
│ Rejected    │ bg: Red-100, text: Red-800, border: none      │
├─────────────┼───────────────────────────────────────────────┤
│ Status      │ Dark Mode Style                               │
├─────────────┼───────────────────────────────────────────────┤
│ Pending     │ bg: Amber-950, text: Amber-300, border: 1px   │
│             │ border-color: Amber-800                       │
│ In Progress │ bg: Blue-950, text: Blue-300, border: 1px     │
│             │ border-color: Blue-800                        │
│ Resolved    │ bg: Green-950, text: Green-300, border: 1px   │
│             │ border-color: Green-800                       │
│ Rejected    │ bg: Red-950, text: Red-300, border: 1px       │
│             │ border-color: Red-800                         │
└─────────────┴───────────────────────────────────────────────┘
```

### 4.2 Complaint Card

```
Container:
- Border-radius: 16px
- Background: var(--bg-secondary)
- Border: 1px solid var(--border)
- Padding: 20px
- Shadow (Light): 0 1px 3px rgba(0,0,0,0.05)
- Shadow (Dark): 0 1px 3px rgba(0,0,0,0.2)

Hover State (Desktop):
- Transform: translateY(-2px)
- Border-color: var(--border-strong)
- Shadow (Light): 0 8px 24px rgba(0,0,0,0.08)
- Shadow (Dark): 0 8px 24px rgba(0,0,0,0.4)
- Transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1)

Active/Pressed State:
- Transform: scale(0.99)
- Transition: 100ms

Content Layout:
┌─────────────────────────────────────────────────────────┐
│ [STATUS BADGE]                              [CATEGORY]  │
│                                                         │
│ Complaint Title (h3, 1 line max, ellipsis)              │
│ #COM-2024-001 (mono, muted)                             │
│                                                         │
│ Description preview that truncates after two lines...   │
│                                                         │
│ ┌────┐ Student Name                    2 hours ago      │
│ │ 👤 │                                  (muted)          │
│ └────┘                                                  │
└─────────────────────────────────────────────────────────┘

Category Tag:
- Background: var(--bg-tertiary)
- Padding: 4px 10px
- Border-radius: 6px
- Font: 12px, weight 500
- Color: var(--text-secondary)

Avatar:
- Size: 28px
- Border-radius: 50%
- Background: var(--accent-subtle)
- Text: var(--accent-primary), 12px, weight 600
```

### 4.3 Stat Card (Admin Dashboard)

```
Container:
- Border-radius: 20px
- Background: var(--bg-secondary)
- Border: 1px solid var(--border)
- Padding: 24px
- Position: relative

Accent Bar (Left Edge):
- Width: 4px
- Height: 50%
- Position: absolute, left: 0, top: 25%
- Border-radius: 0 4px 4px 0
- Color: matches stat type

Content Structure:
┌─────────────────────────────────────────────────────────┐
│ │                                                       │
│ │  ┌────┐                                               │
│ │  │ 📊 │  Label (small, muted)                         │
│ │  └────┘                                               │
│ │                                                       │
│ │  1,247 (hero, tabular-nums)                           │
│ │                                                       │
│ │  ↑ 12% from last week (small)                         │
│ │  (Green for positive, Red for negative)               │
│ │                                                       │
└─────────────────────────────────────────────────────────┘

Icon Container:
- Size: 44px
- Border-radius: 12px
- Background: accent color at 10% opacity
- Icon size: 22px
- Icon color: accent color

Trend Indicator:
- Arrow icon (↑ ↓ →)
- Color: semantic color (success/warning/error)
- Number follows arrow

Stat Color Mapping:
- Total: Indigo
- Pending: Amber
- In Progress: Blue
- Resolved: Emerald
- Rejected: Red
```

### 4.4 Comment Bubble

```
Container:
- Max-width: 75%
- Margin-bottom: 16px

Self Message (You):
- Alignment: flex-end (right)
- Bubble:
  - Background: var(--accent-primary)
  - Color: white
  - Border-radius: 16px 16px 4px 16px
  - Padding: 12px 16px
- Meta: below bubble, right-aligned

Other Message:
- Alignment: flex-start (left)
- Bubble:
  - Background: var(--bg-tertiary)
  - Color: var(--text-primary)
  - Border-radius: 16px 16px 16px 4px
  - Padding: 12px 16px
- Meta: below bubble, left-aligned

Meta Structure:
┌─────────────────────────────────────────┐
│ [Avatar] Author Name                    │
│  28px    14px, weight 500               │
│          (accent color if admin)        │
│                                         │
│  [Message bubble]                       │
│                                         │
│  2:30 PM • Read (xs, muted)             │
└─────────────────────────────────────────┘

Avatar:
- Size: 28px
- Border-radius: 50%
- Admin avatars: subtle ring (2px accent)

Timestamp:
- Font: 12px
- Color: var(--text-muted)
- Format: "2:30 PM" or "Today at 2:30 PM"
```

### 4.5 Stepper / Status Timeline

```
Container:
- Display: flex (horizontal desktop, vertical mobile)
- Gap: 0 (connected)

Step Structure:
┌─────────────────────────────────────────────────────────┐
│  ┌────┐         ┌────┐         ┌────┐                   │
│  │ ✓  │─────────│ 2  │─────────│ ○  │                   │
│  └────┘         └────┘         └────┘                   │
│  Submitted      In Progress    Resolved                 │
│  (completed)    (active)       (pending)                │
└─────────────────────────────────────────────────────────┘

Step Node:
- Size: 36px
- Border-radius: 50%
- Border: 2px solid
- Font: 14px, weight 600
- Centered content

States:
┌─────────────┬───────────────────────────────────────────────┐
│ State       │ Style                                         │
├─────────────┼───────────────────────────────────────────────┤
│ Completed   │ bg: accent, border: accent, icon: white ✓     │
│ Active      │ bg: accent, border: accent, text: white       │
│             │ (step number or current label initial)        │
│ Pending     │ bg: transparent, border: var(--border)        │
│             │ text: var(--text-muted)                       │
└─────────────┴───────────────────────────────────────────────┘

Connector Line:
- Height: 2px (horizontal) / Width: 2px (vertical)
- Flex: 1 (fills space)
- Completed: accent color
- Pending: var(--border)

Step Label:
- Margin-top: 12px
- Font: 13px, weight 500
- Completed: var(--text-secondary)
- Active: var(--accent-primary), weight 600
- Pending: var(--text-muted)

Mobile Adaptation:
- Vertical layout
- Labels to the right of nodes
- Connector becomes vertical line
```

### 4.6 Form Inputs

```
Text Field:
- Height: 52px (mobile), 48px (desktop)
- Border-radius: 12px
- Border: 1px solid var(--border)
- Background: var(--bg-secondary)
- Padding: 0 16px
- Font: 16px, weight 400
- Color: var(--text-primary)
- Placeholder color: var(--text-placeholder)

Focus State:
- Border: 2px solid var(--accent-primary)
- Outline: 3px solid var(--accent-subtle)
- Outline-offset: 0

Error State:
- Border: 2px solid var(--error)
- Background: var(--error-bg) at 5%

Label:
- Display: block
- Margin-bottom: 8px
- Font: 14px, weight 500
- Color: var(--text-secondary)

Required Indicator:
- Color: var(--error)
- Content: " *"

Helper Text:
- Margin-top: 6px
- Font: 13px
- Color: var(--text-muted)

Textarea:
- Min-height: 120px
- Padding: 16px
- Resize: vertical
- Line-height: 1.6

Character Counter:
- Position: absolute, bottom-right
- Font: 12px
- Color: var(--text-muted)
- Warning at 90%: var(--warning)
- Error at 100%: var(--error)

Dropdown/Select:
- Same base styling as text field
- Chevron icon: 20px, right 16px
- Dropdown panel:
  - Background: var(--bg-elevated)
  - Border: 1px solid var(--border)
  - Border-radius: 12px
  - Shadow: 0 10px 40px rgba(0,0,0,0.15)
  - Max-height: 280px
  - Overflow: auto

Dropdown Item:
- Height: 44px
- Padding: 0 16px
- Font: 15px
- Hover: var(--bg-tertiary)
- Selected: var(--accent-subtle), text accent
```

### 4.7 Buttons

```
Primary Button:
- Height: 52px (mobile), 44px (desktop)
- Border-radius: 12px
- Background: var(--accent-primary)
- Color: white
- Font: 16px, weight 600
- Padding: 0 24px
- Full-width on mobile
- Disabled: opacity 0.5, cursor not-allowed

Primary Hover:
- Background: var(--accent-hover)
- Transform: translateY(-1px)
- Shadow: 0 4px 12px var(--accent-primary) at 30%

Primary Active:
- Transform: scale(0.98)
- Transition: 100ms

Secondary Button:
- Background: transparent
- Border: 1px solid var(--border-strong)
- Color: var(--text-primary)

Secondary Hover:
- Background: var(--bg-tertiary)
- Border-color: var(--text-secondary)

Tertiary Button (Text-only):
- Background: transparent
- Color: var(--accent-primary)
- Padding: 8px 12px
- Height: auto

Tertiary Hover:
- Background: var(--accent-subtle)

Danger Button:
- Background: var(--error)
- Color: white

Danger Hover:
- Background: darker shade of error
- Shadow: 0 4px 12px var(--error) at 30%

Icon Button:
- Size: 40px
- Border-radius: 10px
- Background: var(--bg-tertiary)
- Icon size: 20px

Icon Button Hover:
- Background: var(--bg-secondary)
- Border: 1px solid var(--border)

Floating Action Button (Student Mobile):
- Size: 56px
- Border-radius: 50%
- Background: var(--accent-primary)
- Icon: Plus, white, 24px
- Shadow: 0 4px 16px rgba(0,0,0,0.25)
- Position: fixed, bottom: 24px, right: 24px

FAB Hover:
- Transform: scale(1.05)
- Shadow: 0 6px 20px rgba(0,0,0,0.3)

FAB Extended (with label):
- Width: auto
- Padding: 0 20px
- Gap: 8px
- Border-radius: 28px
- Label: "New Complaint"
```

### 4.8 Theme Toggle Switch

```
Container:
- Width: 52px
- Height: 28px
- Border-radius: 14px
- Background: var(--bg-tertiary)
- Border: 1px solid var(--border)
- Cursor: pointer
- Position: relative

Thumb:
- Size: 24px
- Border-radius: 50%
- Background: var(--bg-secondary)
- Shadow: 0 2px 4px rgba(0,0,0,0.1)
- Position: absolute
- Left: 2px (light mode)
- Right: 2px (dark mode)
- Transition: 200ms ease

Active State (Dark Mode):
- Background: var(--accent-primary)
- Thumb: translateX(24px)

Icons (optional):
- Sun icon on left
- Moon icon on right
- Opacity: 0.5 inactive, 1 active
```

---

## 5. Navigation Specifications

### 5.1 Desktop Sidebar (>900px)

```
Container:
- Width: 280px
- Height: 100vh
- Position: fixed, left
- Background: var(--bg-secondary)
- Border-right: 1px solid var(--border)
- Padding: 24px 16px
- Display: flex, flex-direction: column

Header Section:
- Margin-bottom: 32px
- Padding: 0 12px

Logo Area:
- Display: flex, align-items: center
- Gap: 12px

Logo Icon:
- Size: 40px
- Border-radius: 10px
- Background: var(--accent-primary)
- Icon: white, 22px

App Name:
- Font: 18px, weight 700
- Color: var(--text-primary)

Theme Toggle:
- Position: absolute, top: 24px, right: 16px
- Size: 36px icon button

Navigation Items:
- Flex: 1 (scrollable)
- Overflow-y: auto

Nav Item:
- Height: 48px
- Border-radius: 12px
- Padding: 0 16px
- Display: flex, align-items: center
- Gap: 14px
- Font: 15px, weight 500
- Color: var(--text-secondary)
- Cursor: pointer
- Transition: 150ms

Nav Item Icon:
- Size: 20px
- Color: inherit

Nav Item Hover:
- Background: var(--bg-tertiary)
- Color: var(--text-primary)

Nav Item Active:
- Background: var(--accent-subtle)
- Color: var(--accent-primary)
- Icon: var(--accent-primary)

Nav Item Badge:
- Position: absolute, right: 16px
- Min-width: 20px
- Height: 20px
- Border-radius: 10px
- Background: var(--accent-primary)
- Color: white
- Font: 11px, weight 600
- Text-align: center
- Line-height: 20px

User Section (Bottom):
- Margin-top: auto
- Padding-top: 16px
- Border-top: 1px solid var(--border-divider)

User Card:
- Height: 64px
- Border-radius: 12px
- Padding: 0 12px
- Display: flex, align-items: center
- Gap: 12px
- Background: var(--bg-tertiary)

User Avatar:
- Size: 40px
- Border-radius: 50%
- Background: var(--accent-subtle)
- Icon/initials: var(--accent-primary)

User Info:
- Flex: 1

User Name:
- Font: 14px, weight 600
- Color: var(--text-primary)
- Line-height: 1.3

User Role:
- Font: 12px, weight 400
- Color: var(--text-muted)

Logout Button:
- Size: 36px
- Border-radius: 8px
- Background: transparent
- Icon: 18px, var(--text-muted)

Logout Hover:
- Background: var(--error-bg) at 10%
- Icon: var(--error)
```

### 5.2 Mobile Navigation (<900px)

```
App Bar:
- Height: 64px
- Background: var(--bg-secondary)
- Border-bottom: 1px solid var(--border)
- Padding: 0 16px
- Display: flex, align-items: center
- Position: sticky, top: 0
- Z-index: 100

Left Section:
- Hamburger menu button
- Size: 40px
- Icon: Menu, 22px

Center Section:
- Screen title
- Font: 18px, weight 600
- Color: var(--text-primary)

Right Section:
- Theme toggle icon button (36px)
- Notification bell with badge
- Badge: 18px circle, red bg, white text

Navigation Drawer:
- Width: 85% (max 320px)
- Height: 100vh
- Background: var(--bg-secondary)
- Position: fixed
- Transform: translateX(-100%)
- Transition: 300ms ease
- Z-index: 200

Drawer Open:
- Transform: translateX(0)

Drawer Overlay:
- Position: fixed, inset: 0
- Background: rgba(0,0,0,0.5)
- Z-index: 199
- Opacity: 0 → 1

Drawer Header:
- Height: 80px
- Padding: 24px 20px
- Border-bottom: 1px solid var(--border)
- Display: flex, align-items: center
- Gap: 12px

Drawer Content:
- Same nav items as desktop
- Padding: 16px

Drawer Footer:
- Same user card as desktop
- Position: absolute, bottom: 0
- Width: 100%
- Border-top: 1px solid var(--border)
```

---

## 6. Screen-by-Screen Design Instructions

### 6.1 Login Screen (Unified)

```
Layout:
- Min-height: 100vh
- Display: flex, center
- Background: var(--bg-primary)
- Padding: 20px

Background Pattern (subtle):
- Light: Radial gradient dots at 5% opacity
- Dark: Subtle grid lines at 3% opacity

Card:
- Width: 100%, max-width: 420px
- Padding: 48px (desktop), 32px (mobile)
- Border-radius: 24px
- Background: var(--bg-secondary)
- Border: 1px solid var(--border)
- Shadow (Light): 0 25px 50px -12px rgba(0,0,0,0.1)
- Shadow (Dark): 0 25px 50px -12px rgba(0,0,0,0.5)

Logo Section:
- Text-align: center
- Margin-bottom: 32px

Logo:
- Size: 64px
- Border-radius: 16px
- Background: var(--accent-primary)
- Icon: white, 32px
- Margin-bottom: 24px

Title:
- Font: h1
- Color: var(--text-primary)
- Margin-bottom: 8px

Subtitle:
- Font: body, var(--text-secondary)
- Margin-bottom: 32px

Form:
- Display: flex, flex-direction: column
- Gap: 20px

Input Group:
- Position: relative

Password Toggle:
- Position: absolute
- Right: 16px
- Top: 50%
- Transform: translateY(-50%)
- Size: 20px
- Color: var(--text-muted)
- Cursor: pointer

Submit Button:
- Full width
- Margin-top: 8px

Footer Links:
- Display: flex
- Justify-content: space-between
- Margin-top: 24px
- Font: 14px

Link:
- Color: var(--accent-primary)
- Font-weight: 500

Link Hover:
- Text-decoration: underline
```

### 6.2 Admin Dashboard

```
Layout:
- Padding: 32px (desktop), 20px (mobile)
- Max-width: 1400px
- Margin: 0 auto

Header Section:
- Display: flex
- Justify-content: space-between
- Align-items: flex-start
- Margin-bottom: 32px

Title Group:
- Title: "Dashboard" (h1)
- Subtitle: Current date (small, muted)
- Format: "Monday, January 15, 2024"

Header Actions:
- Refresh button (icon)
- Export button (optional)

Stats Grid:
- Display: grid
- Desktop: 4 columns
- Tablet: 2 columns
- Mobile: 2 columns
- Gap: 20px
- Margin-bottom: 40px

Recent Section:
- Header row:
  - Title: "Recent Complaints" (h2)
  - "View All" link (accent)
- Margin-bottom: 20px

Recent List:
- Display: flex, flex-direction: column
- Gap: 12px

Compact Card:
- Padding: 16px
- No description
- Status + Title + Timestamp only
```

### 6.3 Admin Complaints List

```
Layout:
- Padding: 32px (desktop), 20px (mobile)
- Max-width: 1400px

Page Header:
- Title: "All Complaints" (h1)
- Total count badge (pill)
- Format: "247 total"

Filter Bar:
- Display: flex
- Gap: 12px
- Margin-bottom: 24px
- Flex-wrap: wrap (mobile)

Search Input:
- Flex: 1
- Min-width: 200px
- Prefix icon: Search
- Placeholder: "Search by title, ID, or student..."

Filter Dropdowns:
- Width: 150px
- Status: "All Statuses", "Pending", "In Progress", "Resolved", "Rejected"
- Category: "All Categories", "Facilities", "IT", "Billing", "Academic", "Other"

Active Filters:
- Display: flex
- Gap: 8px
- Margin-bottom: 16px
- Wrap: wrap

Filter Chip:
- Height: 32px
- Border-radius: 16px
- Background: var(--accent-subtle)
- Color: var(--accent-primary)
- Padding: 0 12px
- Font: 13px
- Close icon: 14px, right

Complaints List:
- Display: flex, flex-direction: column
- Gap: 16px

Pagination (if applicable):
- Display: flex
- Justify-content: center
- Gap: 8px
- Margin-top: 32px

Page Button:
- Size: 40px
- Border-radius: 10px
- Background: var(--bg-tertiary)
- Font: 14px

Page Button Active:
- Background: var(--accent-primary)
- Color: white
```

### 6.4 Admin Complaint Detail

```
Desktop Layout (2-column):
┌─────────────────────────────────────┬──────────────────────────┐
│                                     │                          │
│  [← Back]  Complaint #COM-001       │     ACTIONS              │
│                                     │                          │
│  ┌─────────────────────────────┐    │  ┌────────────────────┐  │
│  │                             │    │  │ Status             │  │
│  │  [PENDING]  Facilities      │    │  │                    │  │
│  │                             │    │  │  [Pending ▼]       │  │
│  │  WiFi Not Working in        │    │  │                    │  │
│  │  Library Building           │    │  ──────────────────────  │
│  │                             │    │                          │
│  │  Description...             │    │  Assigned To             │
│  │                             │    │  [Select Admin ▼]        │
│  │  Submitted: Jan 15, 2024    │    │                          │
│  │                             │    │  ──────────────────────  │
│  └─────────────────────────────┘    │                          │
│                                     │  [Mark as Resolved]      │
│  STUDENT INFORMATION                │  [Reject Complaint]      │
│  ┌─────────────────────────────┐    │                          │
│  │ [Avatar]  John Doe          │    │  ──────────────────────  │
│  │           john@student.edu  │    │                          │
│  │           ID: STU-2024-001  │    │  Student Details         │
│  │                             │    │  [View Profile →]        │
│  └─────────────────────────────┘    │                          │
│                                     │                          │
│  ─────────────────────────────────  │                          │
│                                     │                          │
│  DISCUSSION                         │                          │
│                                     │                          │
│  [Comment thread...]                │                          │
│                                     │                          │
│  ┌─────────────────────────────┐    │                          │
│  │ Type a message...      [📎] │    │                          │
│  └─────────────────────────────┘    │                          │
│                      [Send]         │                          │
│                                     │                          │
└─────────────────────────────────────┴──────────────────────────┘

Left Column: 65% | Right Column: 35%
Gap: 32px

Mobile Layout (1-column):
- Actions become sticky header bar
- Status changer opens bottom sheet
- Full-width cards stacked

Action Buttons:
- Primary: Full width, accent color
- Secondary: Full width, outlined
- Gap: 12px between buttons

Comment Input:
- Position: sticky, bottom: 0
- Background: var(--bg-primary)
- Padding: 16px
- Border-top: 1px solid var(--border)
```

### 6.5 Student My Complaints

```
Layout:
- Padding: 32px (desktop), 20px (mobile)
- Max-width: 900px
- Margin: 0 auto

Header:
- Title: "My Complaints" (h1)
- Subtitle: "Track and manage your requests" (muted)

Filter Chips:
- Display: flex
- Gap: 8px
- Margin: 24px 0
- Overflow-x: auto (mobile)
- Padding-bottom: 8px (for scrollbar)

Chip:
- Height: 36px
- Border-radius: 18px
- Padding: 0 16px
- Font: 14px, weight 500
- Background: var(--bg-tertiary)
- Color: var(--text-secondary)
- White-space: nowrap

Chip Active:
- Background: var(--accent-primary)
- Color: white

Complaints List:
- Display: flex, flex-direction: column
- Gap: 16px

FAB (Mobile only):
- Position: fixed
- Bottom: 24px
- Right: 24px
- Size: 56px
- Border-radius: 50%
- Background: var(--accent-primary)
- Shadow: 0 4px 16px rgba(0,0,0,0.25)
- Icon: Plus, white, 24px

Empty State:
- Text-align: center
- Padding: 64px 20px

Empty Icon:
- Size: 80px
- Color: var(--text-muted)
- Margin-bottom: 24px

Empty Title:
- Font: h3
- Margin-bottom: 8px

Empty Description:
- Font: body
- Color: var(--text-secondary)
- Margin-bottom: 24px

Empty CTA:
- Primary button
- Max-width: 240px
- Margin: 0 auto
```

### 6.6 Student New Complaint Form

```
Layout:
- Padding: 32px (desktop), 20px (mobile)
- Max-width: 640px
- Margin: 0 auto

Header:
- Title: "What do you need help with?" (h1)
- Subtitle: "We'll get back to you within 24 hours" (muted)
- Margin-bottom: 32px

Form:
- Display: flex, flex-direction: column
- Gap: 24px

Category Field:
- Label: "Category *"
- Dropdown with options:
  - Facilities (WiFi, furniture, cleaning)
  - IT Support (email, software, hardware)
  - Billing (fees, payments, refunds)
  - Academic (courses, grades, registration)
  - Other
- Each option has description subtitle

Title Field:
- Label: "Title *"
- Placeholder: "Brief summary of your issue"
- Max-length: 100
- Character counter

Description Field:
- Label: "Description *"
- Placeholder: "Please provide details about your issue..."
  - "What happened?"
  - "When did it start?"
  - "Any error messages?"
- Min-height: 160px
- Max-length: 500
- Character counter

Submit Button:
- Full width (mobile)
- Margin-top: 8px
- Loading state with spinner

Success State:
- Replace form with success card
- Checkmark animation (Lottie or CSS)
- Title: "Complaint submitted!"
- Complaint ID displayed (mono, accent)
- Description: "You can track its progress in My Complaints"
- CTA: "Back to My Complaints"
```

### 6.7 Student Complaint Detail

```
Layout:
- Padding: 32px (desktop), 20px (mobile)
- Max-width: 800px
- Margin: 0 auto

Header:
- Back button + Complaint ID (mono)
- Margin-bottom: 24px

Status Card:
- Background: var(--bg-secondary)
- Border: 1px solid var(--border)
- Border-radius: 16px
- Padding: 24px
- Margin-bottom: 24px

Status Stepper:
- Horizontal on desktop
- Vertical on mobile
- Current status highlighted

Withdraw Button:
- Only if status === "Pending"
- Secondary button style
- Confirmation dialog:
  - Title: "Withdraw complaint?"
  - Description: "This action cannot be undone."
  - Buttons: "Cancel", "Withdraw"

Details Card:
- Same structure as admin
- Read-only view
- No action buttons

Discussion Section:
- Same as admin
- Student can reply
```

### 6.8 Activity Feed (Both Roles)

```
Layout:
- Padding: 32px (desktop), 20px (mobile)
- Max-width: 800px
- Margin: 0 auto

Header:
- Title: "Activity Feed" (h1)
- "Mark all as read" link (if unread)
- Margin-bottom: 24px

Filter (optional):
- Tabs: "All", "Status Updates", "Comments"

Timeline:
- Position: relative
- Padding-left: 28px

Timeline Line:
- Position: absolute
- Left: 10px
- Top: 0
- Bottom: 0
- Width: 2px
- Background: var(--border)

Timeline Item:
- Position: relative
- Padding: 16px 0
- Border-left: 3px solid transparent

Timeline Item Unread:
- Border-left-color: var(--accent-primary)
- Background: var(--accent-subtle) at 30%
- Margin-left: -20px
- Padding-left: 17px (20 - 3 border)
- Border-radius: 0 12px 12px 0

Timeline Node:
- Position: absolute
- Left: -24px (relative to item)
- Size: 20px
- Border-radius: 50%
- Background: var(--bg-primary)
- Border: 2px solid var(--border)
- Display: flex, center

Node Icon:
- Size: 10px
- Color: var(--text-muted)

Node Types:
┌───────────────┬────────────────────────────────────────────┐
│ Type          │ Icon & Color                               │
├───────────────┼────────────────────────────────────────────┤
│ Status Change │ Refresh/rotate icon, accent color          │
│ New Comment   │ Message bubble icon, accent color          │
│ Assignment    │ User icon, accent color                    │
│ System        │ Bell icon, muted color                     │
└───────────────┴────────────────────────────────────────────┘

Item Content:
- Title: Action description
- Subtitle: Complaint reference (clickable)
- Timestamp: relative time
- Preview: Comment text (if applicable)

Click Behavior:
- Navigate to complaint detail
- Mark as read
```

---

## 7. Responsive Breakpoints

```
Mobile: < 640px
- Single column layouts
- Full-width buttons
- Hamburger navigation
- Bottom sheets for actions
- Reduced padding (16-20px)
- Smaller typography scale

Tablet: 640px - 1024px
- 2-column grids
- Collapsible sidebar option
- Increased padding (24px)
- Medium typography scale

Desktop: > 1024px
- Multi-column layouts
- Full persistent sidebar
- Max-width containers
- Generous padding (32px)
- Full typography scale

Large Desktop: > 1440px
- Centered content with max-width
- Increased spacing
- Potential for 3+ column layouts
```

---

## 8. Micro-interactions & Animations

### 8.1 Page Transitions

```
Enter Animation:
- Opacity: 0 → 1
- Transform: translateY(12px) → translateY(0)
- Duration: 300ms
- Easing: cubic-bezier(0.4, 0, 0.2, 1)
- Stagger children: 50ms delay per item

Exit Animation:
- Opacity: 1 → 0
- Duration: 200ms
```

### 8.2 Card Interactions

```
Hover (Desktop):
- Transform: translateY(-2px)
- Border-color: var(--border-strong)
- Shadow elevation increase
- Duration: 200ms
- Easing: ease-out

Press:
- Transform: scale(0.98)
- Duration: 100ms

Focus:
- Outline: 2px solid var(--accent-primary)
- Outline-offset: 2px
```

### 8.3 Button Interactions

```
Hover:
- Background color shift
- Transform: translateY(-1px)
- Shadow increase
- Duration: 150ms

Press:
- Transform: scale(0.97)
- Duration: 100ms

Loading:
- Spinner replaces text
- Disabled state
- Spinner: rotating circle, accent color
```

### 8.4 Form Interactions

```
Input Focus:
- Border: 1px → 2px
- Border-color: var(--accent-primary)
- Outline: 3px solid var(--accent-subtle)
- Duration: 150ms

Label Float (optional):
- Font-size: 16px → 12px
- Color: var(--text-secondary) → var(--accent-primary)
- Transform: translateY(0) → translateY(-24px)
```

### 8.5 Status Change Animation

```
Background Transition:
- Color interpolation
- Duration: 300ms
- Easing: ease-in-out

Badge Pop:
- Scale: 0.8 → 1
- Duration: 200ms
- Easing: cubic-bezier(0.175, 0.885, 0.32, 1.275)
```

### 8.6 Toast Notifications

```
Position:
- Desktop: top-right, 24px from edges
- Mobile: bottom-center, 24px from bottom

Enter:
- Transform: translateX(100%) → translateX(0)
- Opacity: 0 → 1
- Duration: 300ms

Exit:
- Transform: translateX(0) → translateX(100%)
- Opacity: 1 → 0
- Duration: 200ms

Auto-dismiss: 4000ms
Progress bar: 4s countdown

Types:
┌─────────┬─────────────────────────────────────────┐
│ Type    │ Style                                   │
├─────────┼─────────────────────────────────────────┤
│ Success │ Green accent, checkmark icon            │
│ Error   │ Red accent, X icon                      │
│ Warning │ Amber accent, alert icon                │
│ Info    │ Blue accent, info icon                  │
└─────────┴─────────────────────────────────────────┘
```

### 8.7 Loading States

```
Skeleton:
- Background: linear-gradient(
    90deg,
    var(--bg-tertiary) 25%,
    var(--bg-secondary) 50%,
    var(--bg-tertiary) 75%
  )
- Background-size: 200% 100%
- Animation: shimmer 1.5s infinite
- Border-radius: match content

Shimmer Animation:
- 0%: background-position: 200% 0
- 100%: background-position: -200% 0

Spinner:
- Size: 24px (inline), 48px (page)
- Border: 3px solid var(--border)
- Border-top: 3px solid var(--accent-primary)
- Border-radius: 50%
- Animation: rotate 1s linear infinite
```

### 8.8 Theme Transition

```
Global Transition:
- All color properties
- Duration: 300ms
- Easing: ease-in-out

Implementation:
- CSS custom properties transition
- No flash of wrong theme
- Smooth color interpolation
```

---

## 9. Empty States

```
Structure:
- Icon/Illustration: 80-120px
- Title: 18px, weight 600
- Description: 14px, var(--text-secondary)
- CTA Button (optional)
- Text-align: center
- Padding: 64px 20px

No Complaints (Student):
- Icon: Inbox (outline)
- Title: "No complaints yet"
- Description: "Submit your first complaint and we'll help you resolve it"
- CTA: "Submit Complaint" (primary)

No Complaints (Admin):
- Icon: ClipboardCheck
- Title: "All caught up!"
- Description: "No complaints in the system"

No Search Results:
- Icon: Search (outline)
- Title: "No matches found"
- Description: "Try adjusting your search or filters"
- CTA: "Clear Filters" (secondary)

No Activity:
- Icon: Bell (outline)
- Title: "No recent activity"
- Description: "We'll notify you when there are updates"

Error State:
- Icon: AlertCircle
- Title: "Something went wrong"
- Description: "We couldn't load the data"
- CTA: "Try Again" (primary)
```

---

## 10. Iconography

```
Library: Lucide Icons (or equivalent)
Default Size: 20px
Nav Icons: 20px
Inline Icons: 16px
Large Icons: 24px
XL Icons: 32px

Stroke Width: 2px
Stroke Linecap: round
Stroke Linejoin: round

Key Icons by Screen:
┌─────────────────────┬──────────────────────────────────────┐
│ Screen              │ Icons                                │
├─────────────────────┼──────────────────────────────────────┤
│ Navigation          │ LayoutDashboard, FileText, Bell,     │
│                     │ BarChart3, User, Settings, LogOut    │
├─────────────────────┼──────────────────────────────────────┤
│ Actions             │ Search, Filter, Plus, Send, Paperclip│
│                     │ Download, Refresh, MoreVertical      │
├─────────────────────┼──────────────────────────────────────┤
│ Status              │ Check, X, Clock, Loader, AlertCircle │
├─────────────────────┼──────────────────────────────────────┤
│ Navigation UI       │ Menu, ChevronLeft, ChevronRight,     │
│                     │ ChevronDown, ArrowLeft               │
├─────────────────────┼──────────────────────────────────────┤
│ Theme               │ Sun, Moon                            │
├─────────────────────┼──────────────────────────────────────┤
│ Empty States        │ Inbox, Search, Bell, AlertCircle     │
├─────────────────────┼──────────────────────────────────────┤
│ Categories          │ Building, Monitor, CreditCard,       │
│                     │ GraduationCap, HelpCircle            │
└─────────────────────┴──────────────────────────────────────┘
```

---

## 11. Accessibility Requirements

### 11.1 Color Contrast

```
Minimum Ratios (WCAG AA):
- Normal text: 4.5:1
- Large text (18px+): 3:1
- UI components: 3:1

Never rely on color alone:
- Status: icon + text + color
- Errors: icon + text + border
- Success: icon + text + color
```

### 11.2 Focus States

```
Visible Focus:
- Outline: 2px solid var(--accent-primary)
- Outline-offset: 2px
- Border-radius: inherit

Focus-Visible Only:
- Show on keyboard navigation
- Hide on mouse click

Skip Links:
- "Skip to main content"
- Position: absolute, top-left
- Visible on focus
```

### 11.3 Touch Targets

```
Minimum Size: 44×44px
Spacing: 8px minimum between targets

Exceptions:
- Inline links: 36px height minimum
- Icon buttons: 40×40px
```

### 11.4 Screen Readers

```
Semantic HTML:
- Proper heading hierarchy (h1 → h2 → h3)
- Landmark regions (nav, main, aside)
- Button vs link distinction

ARIA Labels:
- Icon-only buttons: aria-label
- Dynamic content: aria-live
- Current page: aria-current="page"

Status Announcements:
- Toast notifications
- Form errors
- Loading states
```

### 11.5 Motion Preferences

```
Respect prefers-reduced-motion:
- Disable non-essential animations
- Keep functional transitions (theme switch)
- Instant state changes instead of animated
```

---

## 12. Flutter Implementation Notes

### 12.1 Theme Structure

```dart
// Theme provider with 4 combinations
enum AppTheme {
  adminLight,
  adminDark,
  studentLight,
  studentDark,
}

// Theme data factory
class AppThemeData {
  static ThemeData getTheme(AppTheme theme) {
    return switch (theme) {
      AppTheme.adminLight => _adminLightTheme,
      AppTheme.adminDark => _adminDarkTheme,
      AppTheme.studentLight => _studentLightTheme,
      AppTheme.studentDark => _studentDarkTheme,
    };
  }
}

// Color extensions
extension AppColors on ThemeData {
  Color get statusPending => extension<AppColorExtension>()!.statusPending;
  Color get statusResolved => extension<AppColorExtension>()!.statusResolved;
  // ... etc
}
```

### 12.2 Component Library

```dart
// Reusable widgets
class AppCard extends StatelessWidget { }
class StatusBadge extends StatelessWidget { }
class CommentBubble extends StatelessWidget { }
class StatCard extends StatelessWidget { }
class Stepper extends StatelessWidget { }
class EmptyState extends StatelessWidget { }
class AppButton extends StatelessWidget { }
class AppTextField extends StatelessWidget { }
class ThemeToggle extends StatelessWidget { }
```

### 12.3 Responsive Layout

```dart
// Breakpoint detection
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 640) return mobile;
        if (constraints.maxWidth < 1024) return tablet;
        return desktop;
      },
    );
  }
}
```

### 12.4 Animation Implementation

```dart
// Page transitions
class FadePageTransition extends PageTransitionsBuilder {
  @override
  Widget buildTransitions(
    Route route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

// Card hover
class HoverCard extends StatefulWidget {
  // Implementation with MouseRegion
}
```

### 12.5 State Management

```dart
// Theme state
@riverpod
class ThemeController extends _$ThemeController {
  @override
  AppTheme build() {
    // Load from preferences
    return AppTheme.adminLight;
  }
  
  void setTheme(AppTheme theme) {
    state = theme;
    // Save to preferences
  }
  
  void toggleMode() {
    // Toggle between light/dark for current portal
  }
}

// Role-based initial theme
@riverpod
class AuthController extends _$AuthController {
  void onLogin(User user) {
    final theme = user.isAdmin 
      ? AppTheme.adminLight 
      : AppTheme.studentLight;
    ref.read(themeControllerProvider.notifier).setTheme(theme);
  }
}
```

---

## Summary

### Theme Matrix Overview

| Portal | Light Mode | Dark Mode |
|--------|------------|-----------|
| **Admin** | Clean white, indigo accent, crisp edges | Deep slate, bright indigo, immersive |
| **Student** | Warm off-white, emerald accent, friendly | Warm dark, bright emerald, calm |

### Key Design Principles

1. **Four Distinct Experiences**: Each theme combination feels unique while maintaining consistency
2. **Portal Personality Persists**: Admin always authoritative, Student always supportive
3. **Smooth Theme Transitions**: 300ms color interpolation, no flash
4. **Accessibility First**: WCAG AA compliance, reduced motion support
5. **Responsive by Design**: Mobile-first, breakpoint-optimized layouts

### File Organization (Flutter)

```
lib/
├── themes/
│   ├── admin_light_theme.dart
│   ├── admin_dark_theme.dart
│   ├── student_light_theme.dart
│   ├── student_dark_theme.dart
│   └── theme_extensions.dart
├── components/
│   ├── cards/
│   ├── badges/
│   ├── buttons/
│   ├── inputs/
│   └── feedback/
├── screens/
│   ├── auth/
│   ├── admin/
│   ├── student/
│   └── shared/
└── providers/
    └── theme_provider.dart
```
