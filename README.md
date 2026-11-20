# SwiftSonic

A DocC guide to Swiftsonic 2026, November 20–22 in Nashville. It covers the at-conference experience: daily schedules, speaker pages, check-in, meals, on-site help, and places to visit between sessions.

The package contains one empty Swift file so SwiftPM and Xcode can build the documentation without adding API symbols. The site uses Apple’s DocC renderer and topic navigation.

## Build

Use a full Xcode installation selected with `xcode-select`, or a Swift toolchain that includes DocC:

```sh
./build-site.sh
python3 -m http.server 8080 --directory Build
```

Open <http://localhost:8080/documentation/swiftsonic/>. The generated `Build` directory is ready for static hosting and includes an entry-page redirect.

For hosting under a path, build with that path:

```sh
./build-site.sh /SwiftSonic
```

Mount the contents of `Build` at `/SwiftSonic`. For a local preview of that configuration, serve a parent directory containing `SwiftSonic` with the contents of `Build` inside it.

You can also open `Package.swift` in Xcode and choose **Product > Build Documentation**.

## Deploy to Cloudflare Workers

The GitHub Actions workflow builds and validates the site on pull requests. Pushes to `main` also deploy the `Build` directory with Workers Static Assets. You can run the workflow manually from the Actions tab on `main`.

Before the first deployment:

1. In your Cloudflare account, enable a `workers.dev` subdomain if you do not already have one.
2. Create an API token using the **Edit Cloudflare Workers** template, scoped to that account.
3. In the GitHub repository, open **Settings > Secrets and variables > Actions** and add these repository secrets:

   | Secret | Value |
   | --- | --- |
   | `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token |
   | `CLOUDFLARE_ACCOUNT_ID` | Your Cloudflare account ID |

4. Push this repository to GitHub with `main` as its default branch. If the initial push happened before you added the secrets, rerun the workflow.

The first deployment creates a Worker named `swiftsonic`; later deployments update it. Its URL is `https://swiftsonic.<your-subdomain>.workers.dev`. Change `name` in `wrangler.jsonc` if you want a different Worker name. An existing Worker with that name in the selected account will be updated.

The deployment uses the site at the domain root. Add a custom domain from the Worker's **Settings > Domains & Routes** after deploying.

For a local check of the Cloudflare configuration, use Node.js 22 or later:

```sh
npm ci
./build-site.sh
npm run check:deploy
npm run dev
```

`npm run dev` serves the site through the local Workers runtime. To deploy from your computer, authenticate with `npx wrangler login` and run `npm run deploy`.

[Cloudflare Workers CI documentation](https://developers.cloudflare.com/workers/ci-cd/external-cicd/github-actions/) · [Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/)

## Styling

`theme-settings.json` sets DocC’s light and dark colors. `header.html` adds the conference wordmark and day navigation. `Styling/theme.css` supplies the poster typography, paper texture, and schedule styling; `build-site.sh` includes these assets in the static site and adjusts links for the hosting path.

The fonts are self-hosted copies of Anton, Barlow Condensed, and Space Mono used by the conference website. Their licenses are in `Styling/fonts`.

Safari uses Apple’s native Smart App Banner for DocB (App Store ID `6736964512`). Its app argument is `com.mcrich.Apple-Documentation://register/swiftsonic.app`.

## Content

Edit the Markdown files in `Sources/SwiftSonic/SwiftSonic.docc`. Conference information was checked on November 19, 2026. Editorial references and schedule research are kept in `Research.md`, outside the published site. Speaker photos come from the conference website and remain the property of their owners.

This is an independent conference guide. Check [the official website](https://swiftsonicconf.com/) for changes.
