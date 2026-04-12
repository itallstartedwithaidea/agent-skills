# SKILL.md Format Specification

> The standard format for Agent Skills™ by [googleadsagent.ai™](https://googleadsagent.ai)

## Overview

Every skill in Agent Skills™ must include a `SKILL.md` file that conforms to this specification. The `SKILL.md` file is the single source of truth for a skill's purpose, behavior, compatibility, and usage. It is both human-readable documentation and machine-parseable configuration — Buddy™ Agent loads and interprets this file at runtime.

---

## Required Sections

Every `SKILL.md` must include the following sections in this order.

### `# Skill Name`

The top-level heading. Single `#` heading with the human-readable skill name. Used as the display name in the Skills Registry.

- Exactly one `#` heading per file
- Maximum 60 characters

### `## Description`

A clear, concise paragraph (2–5 sentences) explaining what the skill does, what problem it solves, and who benefits from it. This section is indexed for semantic search.

- Must be prose (not a bullet list)
- Minimum 50 characters, maximum 500 characters

### `## Use When`

A bullet list of concrete scenarios where this skill should be invoked. Each bullet describes a specific user request, keyword trigger, or workflow context.

- Minimum 3 bullet points
- Each bullet starts with `- `
- Use action-oriented language

### `## Implementation`

Technical details: code snippets, algorithms, API calls, or step-by-step procedures that the agent executes when this skill is activated.

- At least one fenced code block with a language tag
- Code should be realistic and runnable where possible
- Include both input and expected output where applicable

### `## Platform Compatibility`

A Markdown table indicating which AI platforms support this skill.

```markdown
| Platform    | Supported |
|-------------|-----------|
| Cursor      | ✅ or ❌   |
| Claude Code | ✅ or ❌   |
| Codex       | ✅ or ❌   |
| Gemini CLI  | ✅ or ❌   |
```

### `## Related Skills`

Links to other skills commonly used alongside this one.

- Minimum 1 link
- Use relative paths: `[Skill Name](../category/skill-name/)`

---

## Optional Sections

### `## Prerequisites`

Tools, APIs, credentials, or environment setup required.

### `## Configuration`

Environment variables or settings that modify behavior.

### `## Best Practices`

Expert-level guidance for optimal use of this skill.

### `## Limitations`

Known constraints, unsupported scenarios, or edge cases.

### `## Keywords`

Comma-separated terms for discovery and search indexing.

---

## Annotated Example

```markdown
# Campaign Budget Optimizer

## Description

Analyzes Google Ads campaign spending patterns and recommends budget
reallocations to maximize conversions within a fixed total budget. Examines
historical cost-per-conversion data, identifies underperforming campaigns,
and generates a reallocation plan with projected impact.

## Use When

- User asks to "optimize my budget" or "reallocate spend"
- Monthly budget review is due and campaigns have 30+ days of data
- CPA varies significantly across campaigns (>2x spread)
- User wants to identify where budget is being wasted
- User asks "which campaigns should get more budget?"

## Implementation

```python
from google.ads.googleads.client import GoogleAdsClient

def analyze_budget_allocation(client, customer_id, lookback_days=30):
    query = """
        SELECT campaign.name, campaign.status,
               campaign_budget.amount_micros,
               metrics.cost_micros, metrics.conversions,
               metrics.cost_per_conversion
        FROM campaign
        WHERE segments.date DURING LAST_30_DAYS
          AND campaign.status = 'ENABLED'
        ORDER BY metrics.cost_micros DESC
    """
    response = client.get_service("GoogleAdsService").search(
        customer_id=customer_id, query=query
    )
    campaigns = []
    for row in response:
        spend = row.metrics.cost_micros / 1e6
        conv = row.metrics.conversions
        cpa = spend / conv if conv > 0 else float('inf')
        campaigns.append({
            "name": row.campaign.name,
            "spend": spend,
            "conversions": conv,
            "cpa": cpa,
            "budget": row.campaign_budget.amount_micros / 1e6
        })
    return recommend_reallocation(campaigns)
```

## Platform Compatibility

| Platform    | Supported |
|-------------|-----------|
| Cursor      | ✅        |
| Claude Code | ✅        |
| Codex       | ✅        |
| Gemini CLI  | ✅        |

## Best Practices

- Always require 30+ days of data before recommending reallocation
- Flag campaigns with CPA >2x the account average as candidates for reduction
- Never reduce budget to zero — set a minimum floor of 10% original budget
- Present changes as a before/after table for user review

## Related Skills

- [Quality Score Optimization](../google-ads/quality-score-optimization/)
- [Competitor Analysis](../google-ads/competitor-analysis/)
- [Conversion Tracking](../google-ads/conversion-tracking/)
```

---

## Validation Rules

The CI pipeline runs `scripts/validate-skills.sh` on every push. A `SKILL.md` passes validation if:

| Rule | Check |
|------|-------|
| Has a top-level heading | File contains at least one line starting with `# ` |
| Has a Description section | File contains `## Description` |
| Has a Use When section | File contains `## Use When` |
