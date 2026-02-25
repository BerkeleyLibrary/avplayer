# 1.1.6 (2026-02-25)
* DP-2314 remove twitter/x logo and links.

# 1.1.5 (2026-02-05)

* AP-536 Change some OkComputer healthchecks to HEAD requests
  Alma and Wowza healthchecks now use HEAD requests, mainly because
  we are only concerned with service status for these checks, and
  because Alma, specifically, responds much faster for HEAD requests
  than for GET requests.
* Adds the Berkeley_Library_Util gem to enable a new, extended version
  of OkComputer's HTTPCheck that is called HeadCheck.
* OkComputer uses open-uri under the hood, which does not support HEAD
  requests, so we used our own Requester wrapper for RestClient to
  extend support.

# 1.1.4 (2026-01-15)

* ADA-669 stylesheets: Refactor header imprint styles
  Before this change, the containing `a` element was using a `display`
  of `contents`, which caused the elements to be inaccessible via the
  keyboard.  Changing the `a` to be a simple flex item caused various
  other layout issues that were corrected:
  * `vertical-align` was set to `middle` for both the image and text,
    allowing them to look mostly the same as before.
  * Added `text-align: center` to ensure the elements are centred on
    mobile-sized viewports in column layout mode.
  * On mobile, the image remains a `block` element so that it causes a
    hard break in the flex grid (otherwise, on larger mobile/tablet
    screen sizes, it is undersized and the "Audio/Video" appears next to
    the logo element).  On desktop, they are no longer required to be
    `block` elements.
  * Additionally, the fixed width size of the logo is now set as the
    `max-width`, and a `width` of `100%` is used.  This allows the logo
    to shrink on very small viewports, such as an iPhone 11 in 2x zoom
    mode.  The iPhone 11 @ 2x has an effective viewport of 305px, which
    is smaller than the 315px width and caused the logo to be cut off
    with the current rules.
* ADA-670 Rework HTML markup for records
  * Use `<ARTICLE/>` for the overall record container; each track remains
    its own `<SECTION/>` which makes more semantic sense.
  * Use `<ASIDE/>` instead of `<UL/>` for track information.  This is the
    intent for this tag (ancillary information about the section it appears
    inside or next to), and fixes the accessibility issue of improperly
    using a list for markup of something that is not a list.
* ADA-674 Use the `aria-pressed` attribute on fullscreen
  * This adds the `aria-pressed` attribute for the fullscreen button.  The
  value toggles in the enterFullScreen/exitFullScreen methods.
  * Notably, the value is always `false` in Safari / iOS WebKit.  This is
  because the WebKit's native fullscreen view disable access to the DOM
  and all elements.  There is no way to interact or manipulate them from
  the fullscreen view.  This should be fine, because that means any time
  the user can interact with them, the pressed value should be false.
* ADA-667 Always set ARIA attributes on time scrubber
  * This is a backport of https://github.com/mediaelement/mediaelement/pull/2986,
    which is described in https://github.com/mediaelement/mediaelement/issues/2908.
  * Co-authored-by: Raphael Krusenbaum <rkrusenb-git@noreply.materna.group>
* ADA-667 Add volume status element to volume slider
  * This fixes https://github.com/mediaelement/mediaelement/issues/2950 and
    https://github.com/mediaelement/mediaelement/issues/2976, and is a full
    backport of https://github.com/mediaelement/mediaelement/pull/2988.
  * Co-authored-by: Raphael Krusenbaum <rkrusenb-git@noreply.materna.group>

# 1.1.3 (2026-01-13)

* DP-2239 updating footer image to ucb svg
* Instead of changing the colour of links on hover to the highlight
  colour (which results in very poor contrast), use the box shadow
  effect that we already use in Framework and Lost-and-Found.
* For the login button on the header, change the cursor to a pointer
  so it appears as a link, instead of leaving it as an arrow since it
  actually is a button.  This helps POLA / UX.

Closes: ADA-668

# 1.1.2 (2026-01-12)

* update library logo

# 1.1.1 (2025-12-17)

* fix mutiplatform builds
* ensures test artifacts are copied out

# 1.1.0 (2025-12-09)

* AP-533: pass in image build arguments (#22)
* AP-526: upgrade Ruby, Rails, and other dependencies
  * includes changes to support omniauth-cas 3.x
* AP-521: convert healthchecks to okcomputer
* AP-487: declare correct mime type for HLS streams

# 1.0.8 (2025-11-04)

* Bumps av-core to 0.4.3 which leverages the TIND API for metadata sourcing. The old method—using the public /search endpoint—no longer works due to TIND's server-side restrictions.
* Deployments must set LIT_TIND_API_KEY either as a Docker secret (/run/secrets/LIT_TIND_API_KEY) or directly in the environment to authenticate to the TIND API.

# 1.0.7 (2025-10-21)

* Updated build/release workflows: Switches to registry-based build caching (#12)

# 1.0.6 (2025-05-23)

* Vendor our own local copy of MediaElement.js.
* Fix for full-screen video playback in Safari.
* Revert "AP-314: ensure latest dash.js loads"

# 1.0.4 (2025-02-14)

- AP-314: ensure dashjs loads when latest ≥ 5.0.0
- switch to new shared github actions workflow

# 1.0.3 (2024-10-14)

- Bumps av-core gem to add transcript links to record pages.

# 1.0.2 (2024-07-08)

- upgrade mediaelement.js
- change player initialization to handle issues where captions were not displayed properly

# 1.0.1 (2023-02-21)

- Improved startup logging

# 1.0.0 (2023-01-05)

- First GitHub release
