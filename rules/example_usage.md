# Пример использования сгенерированных файлов в Mihomo

## Для GeoIP правил (IP/CIDR):

```yaml
rule-providers:
  # Использование MRS файла (рекомендуется)
  geoip_cn:
    type: http
    behavior: ipcidr
    url: "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/rules/geoip/cn.mrs"
    interval: 86400
    
  # Или использование YAML файла  
  geoip_ru:
    type: http
    behavior: ipcidr
    url: "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/rules/geoip/ru.yaml"
    interval: 86400
```

## Для GeoSite правил (домены):

```yaml
rule-providers:
  # Использование MRS файла (рекомендуется)
  geosite_cn:
    type: http
    behavior: domain
    url: "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/rules/geosite/cn.mrs"
    interval: 86400
    
  # Или использование YAML файла
  geosite_youtube:
    type: http
    behavior: domain
    url: "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/rules/geosite/youtube.yaml"
    interval: 86400
```

## Правила в конфиге:

```yaml
rules:
  # GeoIP правила
  - RULE-SET,geoip_cn,DIRECT
  - RULE-SET,geoip_ru,DIRECT
  
  # GeoSite правила
  - RULE-SET,geosite_cn,DIRECT
  - RULE-SET,geosite_youtube,PROXY
  
  # Финальное правило
  - MATCH,PROXY
```

## Доступные файлы:

### GeoIP:
- **akamai** (251 правил) - файлы: akamai.txt, akamai.yaml, akamai.mrs
- **amazon** (4564 правил) - файлы: amazon.txt, amazon.yaml, amazon.mrs
- **cdn77** (171 правил) - файлы: cdn77.txt, cdn77.yaml, cdn77.mrs
- **cloudflare** (844 правил) - файлы: cloudflare.txt, cloudflare.yaml, cloudflare.mrs
- **cn** (1 правил) - файлы: cn.txt, cn.yaml, cn.mrs
- **colocrossing** (308 правил) - файлы: colocrossing.txt, colocrossing.yaml, colocrossing.mrs
- **contabo** (334 правил) - файлы: contabo.txt, contabo.yaml, contabo.mrs
- **digitalocean** (174 правил) - файлы: digitalocean.txt, digitalocean.yaml, digitalocean.mrs
- **discord** (5 правил) - файлы: discord.txt, discord.yaml, discord.mrs
- **fastly** (36 правил) - файлы: fastly.txt, fastly.yaml, fastly.mrs
- **gcore** (345 правил) - файлы: gcore.txt, gcore.yaml, gcore.mrs
- **google** (96 правил) - файлы: google.txt, google.yaml, google.mrs
- **hetzner** (90 правил) - файлы: hetzner.txt, hetzner.yaml, hetzner.mrs
- **linode** (247 правил) - файлы: linode.txt, linode.yaml, linode.mrs
- **mega** (14 правил) - файлы: mega.txt, mega.yaml, mega.mrs
- **meta** (46 правил) - файлы: meta.txt, meta.yaml, meta.mrs
- **oracle** (710 правил) - файлы: oracle.txt, oracle.yaml, oracle.mrs
- **ovh** (545 правил) - файлы: ovh.txt, ovh.yaml, ovh.mrs
- **ru** (12805 правил) - файлы: ru.txt, ru.yaml, ru.mrs
- **scaleway** (12 правил) - файлы: scaleway.txt, scaleway.yaml, scaleway.mrs
- **telegram** (7 правил) - файлы: telegram.txt, telegram.yaml, telegram.mrs
- **vultr** (123 правил) - файлы: vultr.txt, vultr.yaml, vultr.mrs
- **youtube** (8 правил) - файлы: youtube.txt, youtube.yaml, youtube.mrs

### GeoSite:
- **bypass** (1 правил) - файлы: bypass.txt, bypass.yaml, bypass.mrs
- **cn** (1 правил) - файлы: cn.txt, cn.yaml, cn.mrs
- **domains** (540 правил) - файлы: domains.txt, domains.yaml, domains.mrs
- **other** (827 правил) - файлы: other.txt, other.yaml, other.mrs
- **politic** (163 правил) - файлы: politic.txt, politic.yaml, politic.mrs
- **youtube** (12 правил) - файлы: youtube.txt, youtube.yaml, youtube.mrs

## Формат YAML файлов:

YAML файлы имеют формат `payload:` как у metacubex:
```yaml
payload:
  - "1.1.1.1/32"
  - "8.8.8.8/32"
  - "domain.com"
  - "*.example.com"
```

## Автоматическое обновление

Файлы обновляются автоматически каждые 6 часов.
Последнее обновление: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
