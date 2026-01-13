# Ralph ISO Quality Gates v2.0

ISO-aligned quality gates for the Ralph autonomous development loop.

## Overview

This gate system implements controls from:
- **ISO 9001:2015** - Quality Management System (20 QMS controls)
- **ISO/IEC 42001:2023** - AI Management System (8 AIM controls)
- **ISO/IEC 25010:2023** - Software Quality (8 SWQ controls)

## Gate Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  PRE-FLIGHT GATES (run once before iteration loop)         │
├─────────────────────────────────────────────────────────────┤
│  Gate 1: PRD Quality     → Validates progress.txt structure│
│  Gate 2: Task Plan       → QMS-008 Anti-Rubber-Stamp check │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  PER-TASK GATES (run for each task iteration)              │
├─────────────────────────────────────────────────────────────┤
│  Gate 3: Pre-Commit      → Typecheck, tests, security scan │
│  Gate 4: Acceptance      → Final verification before done  │
│  Adversarial Review      → Domain-based critique (optional)│
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  POST-COMPLETION (run once after all tasks complete)       │
├─────────────────────────────────────────────────────────────┤
│  Compound Review         → Learning capture & archival     │
│  Report Generator        → ISO Compliance Report           │
└─────────────────────────────────────────────────────────────┘
```

## Gate Scripts

| Script | Controls | Purpose |
|--------|----------|---------|
| `gate-1-prd.sh` | QMS-001 to QMS-004, AIM-001 | PRD structure, domain detection |
| `gate-2-plan.sh` | QMS-005 to QMS-008, AIM-003 | Task plan validation, **anti-rubber-stamp** |
| `gate-3-precommit.sh` | QMS-009 to QMS-012, SWQ-002, SWQ-005 | Typecheck, tests, security, scope |
| `gate-4-acceptance.sh` | QMS-013 to QMS-016, SWQ-001 | Final acceptance verification |
| `adversarial-review.sh` | AIM-003 | Domain-based adversarial critique |
| `post-gate-compound.sh` | QMS-017 to QMS-020, MLL-005 | Learning capture, archival |
| `generate-report.sh` | - | ISO Compliance Report generation |

## Critical Control: QMS-008 Anti-Rubber-Stamp

This control prevents "placebo verification" - acceptance criteria that check existence rather than correctness.

### Bad Patterns (Rubber-Stamps)
```
- API endpoint exists
- Component renders
- File was created
- Function is defined
- Database is available
```

### Good Patterns (Executable Verification)
```
- API call returns HTTP 200 with {"status": "ok"}
- npm run typecheck passes with 0 errors
- Function calculateTotal(10, 20) returns 30
- Query SELECT count(*) returns 5
- npm test shows all tests passing
```

## Domain Detection

The gate system auto-detects regulated domains from keywords:

| Domain | Keywords | Adversarial Review |
|--------|----------|-------------------|
| Pensions | pension, LGPS, trustee, scheme, TPR | **Mandatory** |
| Legal | legal, legislation, act, regulation | **Mandatory** |
| Security | auth, credential, permission, encrypt | **Mandatory** |
| Standard | (none detected) | Optional |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RALPH_GATES_ENABLED` | `true` | Master switch for all gates |
| `RALPH_GATE1_SKIP` | `false` | Skip PRD validation |
| `RALPH_GATE2_SKIP` | `false` | Skip task plan validation |
| `RALPH_GATE3_SKIP` | `false` | Skip pre-commit checks |
| `RALPH_GATE4_SKIP` | `false` | Skip acceptance checks |
| `RALPH_FORCE_ADVERSARIAL` | `false` | Force adversarial review |

## Usage Examples

```bash
# Run with all gates (default)
./ralph-archon.sh 10

# Skip Gate 2 during debugging
RALPH_GATE2_SKIP=true ./ralph-archon.sh 10

# Disable all gates temporarily
RALPH_GATES_ENABLED=false ./ralph-archon.sh 10

# Force adversarial review on standard domain
RALPH_FORCE_ADVERSARIAL=true ./ralph-archon.sh 10
```

## Audit Trail

Each gate creates JSON evidence files:

```
scripts/ralph/audit/
├── gate-1-prd.json           # PRD validation evidence
├── gate-2-plan.json          # Task plan validation evidence
├── gate-3/
│   └── task-{id}.json        # Per-task pre-commit evidence
├── gate-4/
│   └── task-{id}.json        # Per-task acceptance evidence
├── compound.json             # Compound review evidence
└── COMPLIANCE-REPORT-{feature}.md  # Full compliance report
```

## Compliance Report

The `generate-report.sh` script creates a markdown report including:
- Executive summary
- Gate summary table
- Controls executed with evidence
- QMS-008 anti-rubber-stamp analysis
- Task execution summary
- Audit trail file listing
- ISO certification statement

## Integration with ralph-archon.sh

The gates are automatically integrated into `ralph-archon.sh` v2.0:

1. **Pre-flight**: Gates 1 & 2 run before the iteration loop
2. **Per-iteration**: Gates 3 & 4 run for each task
3. **Post-completion**: Compound review and report generation
4. **Failure handling**: Max 3 gate failures before blocking

## Troubleshooting

### Gate 1 Fails
- Check progress.txt has required sections:
  - `## Domain Classification`
  - `## ISO Controls Applied`
  - `## Codebase Patterns`
  - `## Iterations`

### Gate 2 Fails (QMS-008)
- Review acceptance criteria in Archon tasks
- Replace "exists/available" with "returns/passes/equals"
- Add specific expected values

### Gate 3/4 Fails
- Run `npm run typecheck` and fix errors
- Run `npm test` and fix failures
- Check for uncommitted changes

### Adversarial Review Issues
- Ensure Claude CLI is available
- Check `scripts/ralph/adversarial/` for review output

## Version History

- **v2.0** (2026-01-13): Initial ISO-aligned gate implementation
  - 4-gate architecture
  - QMS-008 anti-rubber-stamp detection
  - Domain-based adversarial review
  - Compliance report generation
