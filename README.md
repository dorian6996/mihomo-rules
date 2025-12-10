# Mihomo Rules — Automatic MSR Generation

This repository automatically converts **ZKeen .dat files** into **binary MSR format** for use with Mihomo.

---

## Source Data

* **GeoIP dat:** [https://github.com/jameszeroX/zkeen-ip/releases/latest/download/zkeenip.dat](https://github.com/jameszeroX/zkeen-ip/releases/latest/download/zkeenip.dat)
* **GeoSite dat:** [https://github.com/jameszeroX/zkeen-domains/releases/latest/download/zkeen.dat](https://github.com/jameszeroX/zkeen-domains/releases/latest/download/zkeen.dat)

---

This repository uses GitHub Actions to download the `.dat` files every **3 days** and convert them to MSR using the [`geodat2srs`](https://github.com/runetfreedom/geodat2srs) tool. Each rule or category from the `.dat` files is generated as a separate `.msr` file and automatically committed back to the repository.

