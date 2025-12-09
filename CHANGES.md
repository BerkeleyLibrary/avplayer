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
