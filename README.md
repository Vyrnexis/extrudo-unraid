# Extrudo for Unraid

Unofficial container packaging of [Extrudo](https://github.com/zoltanf/extrudo), the free and open-source parametric CAD application for 3D printing.

The image serves Extrudo's static web build. Modeling, project storage and WebAssembly execution happen in the user's browser; the container has no database, appdata directory, device access or privileged mode.

The current image packages Extrudo **v0.9.0**.

## Install on Unraid

Until Extrudo is accepted into Community Applications, install its template directly:

1. Open **Terminal** in the Unraid web interface and download the template:

   ```sh
   curl -fsSL \
     https://raw.githubusercontent.com/Vyrnexis/extrudo-unraid/main/templates/extrudo.xml \
     -o /boot/config/plugins/dockerMan/templates-user/my-extrudo.xml
   ```

2. Open **Docker → Add Container**.
3. Select **Extrudo** from the **User templates** section of the Template dropdown.
4. Keep host port `8780`, or choose another unused port, and click **Apply**.
5. When the container starts, click its icon and select **WebUI**.

The template configures `ghcr.io/vyrnexis/extrudo-unraid:latest`, bridge networking, the icon, WebUI link and port mapping. No path mappings are needed.

For an existing installation, use **Docker → Check for Updates**, then apply the Extrudo update.

## Project storage

Extrudo stores designs in IndexedDB and OPFS in each browser, not on the Unraid server. Consequently:

- each browser and device has separate projects;
- changing the scheme, hostname or port changes the browser storage origin;
- clearing site data can remove projects;
- an Unraid appdata backup does not include projects.

Export `.extrudo` backups regularly. This image does not add shared or server-side storage.

## HTTPS

Direct LAN HTTP access supports creating and editing designs, but still uses browser storage fallbacks; use a stable HTTPS hostname through a reverse proxy for service workers, installable PWA support, OPFS and browser file APIs.

The container reproduces Extrudo's upstream COOP, COEP, Content Security Policy and caching headers.

## Build and test locally

```sh
docker build -t extrudo-unraid .
docker run -d --name extrudo-test -p 8780:8080 extrudo-unraid
tests/smoke.sh extrudo-test
docker rm -f extrudo-test
```

The build pins the upstream release and resolved commit in `Dockerfile`. To package a new release, update both values, build, run the smoke test and tag this repository with the matching version. GitHub Actions publishes `linux/amd64` images to GHCR.

## Publish for Unraid users

1. Push `main` and let the Container workflow publish the first image.
2. In the GitHub package settings, change `extrudo-unraid` visibility to public.
3. Install the image on an Unraid server and verify create, save, reload, export and import.
4. Create a support thread or keep GitHub Issues as the support destination.
5. Submit `templates/extrudo.xml` through the [Community Applications portal](https://ca.unraid.net/submit).

## License and trademarks

Extrudo is distributed under GPL-3.0-or-later. Its source and third-party notices are available in the [upstream repository](https://github.com/zoltanf/extrudo). The packaging files in this repository are MIT licensed.

Extrudo's name and logo belong to the upstream project. This image packages an unmodified official release and is not endorsed by the Extrudo maintainer.
