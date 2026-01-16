# Pensions Governance Knowledge Sources

> Curated sources for 45Black pensions governance knowledge base
> Created: 2026-01-15 via Claude Code investigation

## Quick Start

```bash
# 1. Start Docker Desktop
open -a "Docker Desktop"

# 2. Wait ~30 seconds, then start Archon
cd ~/Projects/infrastructure/archon
docker compose up --build -d

# 3. Open Archon UI
open http://localhost:3737
```

## Priority Crawl List

### 🔴 HIGH PRIORITY - Crawl First

| Source | URL | Why |
|--------|-----|-----|
| **FinRegOnt** | https://finregont.com/ | FIBO + LKIF ontology template for pensions |
| **Stanford CodeX** | https://law.stanford.edu/codex-the-stanford-center-for-legal-informatics/ | Computational law frameworks |
| **Computational Law** | https://computationallaw.org/ | AI Agents x Law - trustee duty encoding |
| **TPR DDaT Strategy** | https://www.thepensionsregulator.gov.uk/en/document-library/corporate-information/ddat-strategy | UK regulatory AI context |

### 🟡 MEDIUM PRIORITY

| Source | URL | Why |
|--------|-----|-----|
| **Liquid Legal Institute** | https://liquid-legal-institute.com/workinggroups/legal-ontologies-and-knowledge-graphs/ | Legal ontology methodology |
| **Lynx Project** | https://www.lynx-project.eu/ | EU compliance KG model |
| **Stanford NLP** | https://nlp.stanford.edu/software/ | Document processing tools |
| **TPR Trustee Toolkit** | https://trusteetoolkit.thepensionsregulator.gov.uk/ | Official trustee guidance |

### 🟢 LOW PRIORITY - Manual Review

| Source | URL | Notes |
|--------|-----|-------|
| **CFA Pensions AI Report** | [PDF Link](https://rpc.cfainstitute.org/sites/default/files/docs/research-reports/pensions-in-the-age-of-artificial-intelligence_online.pdf) | Download and upload to Archon |
| **SPB AI Analysis** | https://www.squirepattonboggs.com/en/insights/publications/2025/05/the-quiet-revolution-of-ai-in-pensions | Single page crawl |

## Crawl Settings Recommendations

| Source Type | Depth | Strategy |
|-------------|-------|----------|
| Documentation sites | 2-3 | Recursive |
| Single articles | 1 | Single page |
| GitHub repos | - | Clone locally, don't crawl |
| PDFs | 0 | Upload directly to Archon |

## Related Memory MCP Entities

These sources have been added to the Memory MCP with relations to your projects:

- `Stanford CodeX` → informs_research_for → `Apex Governance`
- `FinRegOnt` → provides_ontology_template_for → `lgps-knowledge-graph`
- `TPR Digital Strategy` → regulatory_context_for → `Apex Governance`
- `Stanford NLP Group` → potential_tool_for → `pensions-api-worker`
- `Lynx Project` → provides_EU_model_for → `Apex Governance`

## Key Insights

### FinRegOnt Architecture (Recommended Pattern)
```
┌─────────────────┐     ┌─────────────────┐
│      FIBO       │     │      LKIF       │
│ (Business Data) │     │ (Legal Rules)   │
│                 │     │                 │
│ Financial       │     │ Financial Laws  │
│ Entities        │     │ & Regulations   │
└────────┬────────┘     └────────┬────────┘
         │                       │
         └───────────┬───────────┘
                     │
              ┌──────▼──────┐
              │   FinRegOnt │
              │  (Aligned)  │
              └─────────────┘
```

**Apply to Pensions:**
- FIBO equivalent → LGPS business entities (schemes, members, benefits)
- LKIF equivalent → Pensions legislation (PA04, PA08, PSA93, etc.)
- Aligned ontology → Your Apex Governance knowledge graph

## Files

- `pensions-governance-sources.json` - Full structured crawl list
- `README.md` - This file
