# SKILL.md Format Specification

> The standard format for Agent Skills™ by [googleadsagent.ai™](https://googleadsagent.ai)

## Overview

Every skill in the Agent Skills™ repository must include a `SKILL.md` file that conforms to this specification. The `SKILL.md` file is the single source of truth for a skill's purpose, behavior, compatibility, and usage. It is both human-readable documentation and machine-parseable configuration — the Buddy™ Agent's skill loader reads and interprets this file at runtime.

Adhering to this format ensures that skills are:

- **Discoverable** — Consistent headings enable automated indexing and search.
- **Portable** — Platform compatibility tables let agents load skills selectively.
- **Validatable** — CI scripts can verify format compliance before merge.
- **Composable** — Related Skills links enable skill chaining and recommendations.

---

## Required Sections

Every `SKILL.md` must include the following sections in this order.

### `# Skill Name`

The top-level heading. Must be a single `#` heading with the human-readable skill name. This is used as the display name in the Skills Registry.

**Rules:**
- Exactly one `#` heading per file.
- No special characters other than hyphens and spaces.
- Maximum 60 characters.

### `## Description`

A clear, concise paragraph (2–5 sentences) explaining what the skill does, what problem it solves, and who benefits from it. Avoid jargon where possible. This section is indexed for semantic search.

**Rules:**
- Must be prose (not a bullet list).
- Minimum 50 characters.
- Maximum 500 characters.

### `## Use Cases`

A bullet list of concrete scenarios where this skill is useful. Each bullet should describe a specific situation, user role, or workflow.

**Rules:**
- Minimum 3 bullet points.
- Each bullet must start with `- `.
- Use action-oriented language ("Analyze campaign performance...", "Generate ad copy...").

### `## Platform Compatibility`

A Markdown table indicating which AI coding platforms support this skill.

**Required format:**

```markdown
| Platform     | Supported |
|--------------|-----------|
| Cursor       | ✅ or ❌   |
| Claude Code  | ✅ or ❌   |
| Codex        | ✅ or ❌   |
| Gemini CLI   | ✅ or ❌   |
```

**Rules:**
- All four platforms must be listed.
- Use ✅ for supported, ❌ for unsupported.
- No additional columns.

### `## Examples`

One or more code blocks demonstrating how to invoke or use the skill. Examples should be realistic and runnable where possible.

**Rules:**
- At least one fenced code block.
- Code blocks must have a language tag (e.g., `bash`, `json`, `python`).
- Include both the command/input and expected output where applicable.

### `## Related Skills`

A list of links to other skills in the repository that are commonly used alongside this skill or serve a complementary purpose.

**Rules:**
- Minimum 1 link.
- Use relative paths: `[Skill Name](../category/skill-name/)`.
- Links must point to valid skill directories.

---

## Optional Sections

The following sections are encouraged but not required.

### `## Prerequisites`

Tools, APIs, credentials, or environment setup required before the skill can be used.

### `## Configuration`

Environment variables, configuration files, or settings that modify the skill's behavior.

### `## Limitations`

Known constraints, unsupported scenarios, edge cases, or platform-specific issues.

---

## Annotated Example

Below is a complete, annotated `SKILL.md` for a "Campaign Budget Optimizer" skill.

```markdown
# Campaign Budget Optimizer

## Description
Analyzes Google Ads campaign spending patterns and recommends budget
reallocations to maximize conversions within a fixed total budget. The skill
examines historical cost-per-conversion data, identifies underperforming
campaigns consuming disproportionate budget, and generates a reallocation
plan with projected impact estimates.

## Use Cases
- Redistribute monthly budget across 10+ campaigns to reduce wasted spend
- Identify campaigns with declining conversion rates that should receive
  reduced budget
- Generate a budget reallocation report for client review before month-end
- Automate weekly budget adjustments based on rolling 7-day performance data
- Compare current allocation against an optimal allocation model

## Platform Compatibility
| Platform     | Supported |
|--------------|-----------|
| Cursor       | ✅        |
| Claude Code  | ✅        |
| Codex        | ✅        |
| Gemini CLI   | ✅        |

## Prerequisites
- Google Ads API credentials with read access to campaign and budget data
- At least 30 days of historical campaign performance data
- `googleads` Python library installed (`pip install google-ads`)

## Configuration
| Variable                     | Description                          | Default  |
|------------------------------|--------------------------------------|----------|
| `GOOGLE_ADS_CUSTOMER_ID`     | Google Ads customer ID               | Required |
| `LOOKBACK_DAYS`              | Days of historical data to analyze   | `30`     |
| `MIN_CONVERSIONS`            | Minimum conversions to include       | `5`      |
| `REALLOCATION_STRATEGY`      | `proportional` or `top-performer`    | `proportional` |

## Examples
```bash
# Analyze and recommend budget reallocation
agent execute --skill campaign-budget-optimizer \
  --input "Optimize budget for customer 123-456-7890 with a $10,000 monthly cap"
```

```json
{
  "status": "success",
  "recommendations": [
    {
      "campaign": "Brand - Exact Match",
      "current_budget": 3000,
      "recommended_budget": 4200,
      "projected_conversion_lift": "+18%"
    },
    {
      "campaign": "Generic - Broad Match",
      "current_budget": 4000,
      "recommended_budget": 2800,
      "reason": "CPA 3.2x above account average"
    }
  ],
  "total_budget": 10000,
  "projected_overall_lift": "+12%"
}
```

## Limitations
- Requires a minimum of 30 days of conversion data for reliable recommendations.
- Does not account for seasonality or upcoming promotional events.
- Budget recommendations are directional — manual review is recommended before applying.

## Related Skills
- [Bid Strategy Analyzer](../optimization/bid-strategy-analyzer/)
- [Performance Report Generator](../analytics/performance-report-generator/)
- [Campaign Health Monitor](../advertising/campaign-health-monitor/)
```

---

## Validation Rules

The CI pipeline runs `scripts/validate-skills.sh` on every push and pull request. A `SKILL.md` file passes validation if it meets all of the following criteria:

| Rule | Check |
|------|-------|
| Has a top-level heading | File contains at least one line starting with `# ` |
| Has a Description section | File contains a line starting with `## Description` |
| Has a Use Cases section | File contains a line starting with `## Use Cases` |

Additional checks may be added in future iterations, including platform compatibility table validation, minimum bullet count enforcement, and related skills link verification.
