# Slides

- `slides.md`:
  - https://www.osgeo.jp/events/foss4g-2021/foss4g-2021-japan-online/foss4g-japan-2021-online-core-day#sponsor5

To build slides, use https://sli.dev/.

## Setup

Install slidev locally (https://sli.dev/guide/install.html#install-manually), via `package.json`.

```bash
$ cd /path/to/pgGeocoder/slides
$ npm i
```

## Launch

```bash
$ npx slidev [slides file name]
```

## Build

```bash
$ npx slidev build [slides file name] --out {event dir} --base /pgGeocoder/slides/{event dir}/
```

Example for FOSS4G 2021 Japan Online.
```bash
$ npx slidev build --out foss4g2021jp --base /pgGeocoder/slides/foss4g2021jp/
```

## Export

```bash
$ npx slidev export [slides file name]
```
