# Design System Document: High-Precision Analytics

## 1. Overview & Creative North Star: "The Sovereign Lens"
The "Sovereign Lens" is our creative North Star. In the world of government analytics, trust is not built through decorative flair, but through **absolute clarity and quiet authority.** This design system rejects the "SaaS-template" look in favor of a high-end editorial aesthetic that feels like a precision instrument.

We break the "standard" layout by using **intentional asymmetry** and **tonal depth**. Instead of rigid, boxed-in grids, we use expansive white space and "ghost" structures. The goal is to make complex data feel breathable and transparent, transforming raw numbers into an authoritative narrative.

---

## 2. Colors: Tonal Architecture
Our palette uses deep, institutional blues as the foundation, punctuated by high-chroma burnt oranges and forest greens for data storytelling.

### The "No-Line" Rule
**Borders are a failure of hierarchy.** Designers are prohibited from using 1px solid lines to section off content. Boundaries must be defined solely through:
1.  **Background Shifts:** Using `surface-container-low` against `surface`.
2.  **Negative Space:** Utilizing our spacing scale to create invisible partitions.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of fine, semi-translucent paper.
*   **Base Layer:** `surface` (#f7f9fc)
*   **Sectioning:** `surface-container-low` (#f2f4f7)
*   **Interactive/Elevated Elements:** `surface-container-lowest` (#ffffff) for maximum "pop" without shadows.

### The "Glass & Gradient" Rule
To move beyond a flat, "standard" feel, use **Glassmorphism** for floating panels (e.g., filter drawers or hover cards). Use `surface` colors at 80% opacity with a `24px` backdrop-blur. 
*   **Signature Textures:** For primary CTAs or high-level hero data points, apply a subtle linear gradient from `primary` (#001e40) to `primary_container` (#003366) at a 135-degree angle. This adds "visual soul" and depth.

---

## 3. Typography: Editorial Authority
We utilize a dual-typeface system to balance technical precision with human readability.

*   **Display & Headlines (Manrope):** Use Manrope for all `display-` and `headline-` tokens. Its geometric yet warm curves provide an approachable "modern government" feel.
    *   *Tip:* Use `display-lg` (3.5rem) with tight letter-spacing (-0.02em) for "hero" statistics.
*   **Body & Labels (Inter):** Use Inter for `title-`, `body-`, and `label-` tokens. Inter is a workhorse designed for high-density data. 
    *   *Tip:* Use `label-sm` in all-caps with +0.05em letter spacing for metadata to evoke a sense of "archival" precision.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are too "heavy" for a government tool. We use **Tonal Layering** to create lift.

*   **The Layering Principle:** Place a `surface-container-lowest` card on top of a `surface-container-high` background. The delta in lightness creates a natural, soft lift.
*   **Ambient Shadows:** If a floating state is required (e.g., a Modal), use an "Ambient Shadow": 
    *   `box-shadow: 0 12px 32px -4px rgba(25, 28, 30, 0.08);` 
    *   The shadow is tinted with `on_surface` to mimic natural light.
*   **The "Ghost Border":** If accessibility requires a container edge, use the `outline_variant` token (#c3c6d1) at **15% opacity**. This provides a "suggestion" of a border rather than a hard cage.

---

## 5. Components: Precision Primitives

### Buttons & Interaction
*   **Primary:** High-contrast `primary` (#001e40) with `on_primary` (#ffffff). Use `radius-md` (0.375rem).
*   **Secondary:** `secondary_container` (#90c9ff). No border.
*   **Tertiary (Ghost):** No background. Use `primary` text. Transitions should involve a subtle background shift to `surface_container_high`.

### High-Precision Data Cards
*   **Rule:** Forbid divider lines. 
*   **Structure:** Use a `surface-container-low` header area and a `surface-container-lowest` body area. 
*   **Asymmetry:** Align secondary data (labels) to a 12-column sub-grid that is slightly offset to the right, creating an editorial feel.

### Input Fields
*   **State:** Default inputs should use `surface_container_highest` with a bottom-only "Ghost Border" of 1px. 
*   **Focus:** Transition to a full border using `primary` (#001e40) to signal "Active Engagement."

### Additional Analytics Components
*   **The "Trend Micro-Badge":** Use `tertiary_container` (Burnt Orange) for "Warning" trends and `on_secondary_container` (Forest Green) for "Positive" trends. Keep these small and pill-shaped (`radius-full`).
*   **Data Scrubber:** A custom slider using `secondary` (#206393) for the track and a `surface_container_lowest` handle with a high-diffuse ambient shadow.

---

## 6. Do's and Don'ts

### Do:
*   **DO** use `surface-dim` for inactive or backgrounded content to push it visually further back in the Z-axis.
*   **DO** use `Manrope` for large numbers in dashboards—it creates an "Executive Dashboard" feel.
*   **DO** leave at least 32px of "breathing room" between major data modules.

### Don't:
*   **DON'T** use 100% black (#000000). Always use `on_surface` (#191c1e) for text to maintain a premium, ink-on-paper look.
*   **DON'T** use "Standard Blue" for links. Use `secondary` (#206393) and a subtle underline that is 2px below the baseline.
*   **DON'T** use "Full Red" for errors unless critical. Prefer the `tertiary` (Burnt Orange) tones for warnings to keep the interface feeling sophisticated rather than "alarmist."