# Buddy™ Agent API Reference

> API documentation for the Buddy™ Agent by [googleadsagent.ai™](https://googleadsagent.ai)

## Overview

The Buddy™ Agent exposes a RESTful API that enables programmatic interaction with the agent, its skills, and the underlying multi-model infrastructure. This API powers the googleadsagent.ai™ web application, IDE extensions (Cursor, Claude Code, Codex, Gemini CLI), and third-party integrations.

All API endpoints are served from Cloudflare Workers at the edge, providing low-latency responses worldwide. The API accepts and returns JSON unless otherwise specified. Streaming endpoints use Server-Sent Events (SSE).

**Base URL:**

```
https://api.googleadsagent.ai/v1
```

---

## Tool Calling Schema

The Buddy™ Agent uses a structured tool-calling schema compatible with the OpenAI function-calling convention. When the agent determines that a tool call is needed, it emits a tool call object in the following format:

```json
{
  "id": "call_abc123",
  "type": "function",
  "function": {
    "name": "google_ads_get_campaigns",
    "arguments": {
      "customer_id": "123-456-7890",
      "date_range": "LAST_30_DAYS",
      "metrics": ["impressions", "clicks", "conversions", "cost"],
      "filters": {
        "status": "ENABLED",
        "campaign_type": "SEARCH"
      }
    }
  }
}
```

### Tool Call Response Schema

```json
{
  "id": "call_abc123",
  "type": "function_result",
  "content": {
    "campaigns": [
      {
        "id": "11122233344",
        "name": "Brand - Exact Match",
        "status": "ENABLED",
        "impressions": 45200,
        "clicks": 3800,
        "conversions": 312,
        "cost": 4250.00
      }
    ],
    "metadata": {
      "customer_id": "123-456-7890",
      "date_range": "LAST_30_DAYS",
      "currency": "USD"
    }
  }
}
```

### Available Tools

| Tool Name | Description |
|-----------|-------------|
| `google_ads_get_campaigns` | Retrieve campaign data with metrics and filters |
| `google_ads_get_ad_groups` | Retrieve ad group data within a campaign |
| `google_ads_get_keywords` | Retrieve keyword performance data |
| `google_ads_update_budget` | Update campaign daily budget |
| `google_ads_update_bid` | Update keyword or ad group bids |
| `web_search` | Search the web for competitive intelligence or research |
| `page_scanner` | Scan and analyze a web page's content and structure |
| `skill_execute` | Execute an Agent Skill by name |

---

## MCP Server

The Buddy™ Agent is also available as a Model Context Protocol (MCP) server, enabling direct integration with MCP-compatible clients such as Cursor, Claude Code, and other IDE extensions.

### MCP Server Configuration

```json
{
  "mcpServers": {
    "buddy-agent": {
      "url": "https://mcp.googleadsagent.ai/sse",
      "transport": "sse"
    }
  }
}
```

### MCP Capabilities

The MCP server exposes the following capabilities:

- **Tools** — All tools listed in the Tool Calling Schema above are available as MCP tools.
- **Resources** — Campaign data, skill definitions, and account metadata are available as MCP resources.
- **Prompts** — Pre-built prompt templates for common Google Ads workflows (campaign audit, keyword research, ad copy generation).

---

## Endpoints

### `POST /api/agent/chat`

Send a conversational message to the Buddy™ Agent and receive a streamed response.

**Request:**

```json
{
  "message": "Analyze my top 5 campaigns by conversions this month",
  "session_id": "sess_abc123",
  "customer_id": "123-456-7890",
  "stream": true
}
```

**Response (SSE stream):**

```
event: message
data: {"type": "text", "content": "I'll analyze your top campaigns. Let me pull the data..."}

event: tool_call
data: {"type": "tool_call", "id": "call_001", "function": {"name": "google_ads_get_campaigns", "arguments": {...}}}

event: tool_result
data: {"type": "tool_result", "id": "call_001", "content": {...}}

event: message
data: {"type": "text", "content": "Here are your top 5 campaigns by conversions..."}

event: done
data: {"type": "done", "usage": {"prompt_tokens": 1240, "completion_tokens": 890}}
```

**Status Codes:**

| Code | Description |
|------|-------------|
| 200  | Success (streaming response) |
| 400  | Invalid request body |
| 401  | Unauthorized |
| 429  | Rate limit exceeded |

---

### `POST /api/agent/execute`

Execute a specific Agent Skill directly without conversational context.

**Request:**

```json
{
  "skill": "campaign-budget-optimizer",
  "input": {
    "customer_id": "123-456-7890",
    "monthly_budget": 10000,
    "lookback_days": 30
  },
  "customer_id": "123-456-7890"
}
```

**Response:**

```json
{
  "status": "success",
  "skill": "campaign-budget-optimizer",
  "result": {
    "recommendations": [...],
    "projected_overall_lift": "+12%"
  },
  "execution_time_ms": 2340,
  "model_used": "claude-sonnet"
}
```

**Status Codes:**

| Code | Description |
|------|-------------|
| 200  | Skill executed successfully |
| 400  | Invalid input or unknown skill |
| 401  | Unauthorized |
| 404  | Skill not found |
| 429  | Rate limit exceeded |
| 500  | Skill execution error |

---

### `GET /api/skills`

List all available Agent Skills with metadata.

**Query Parameters:**

| Parameter  | Type   | Description |
|------------|--------|-------------|
| `category` | string | Filter by category (e.g., `optimization`, `analytics`) |
| `platform` | string | Filter by platform compatibility (e.g., `cursor`, `claude-code`) |
| `search`   | string | Full-text search across skill names and descriptions |
| `page`     | int    | Page number (default: 1) |
| `per_page` | int    | Results per page (default: 20, max: 100) |

**Response:**

```json
{
  "skills": [
    {
      "id": "campaign-budget-optimizer",
      "name": "Campaign Budget Optimizer",
      "category": "optimization",
      "description": "Analyzes campaign spending patterns and recommends budget reallocations...",
      "platforms": ["cursor", "claude-code", "codex", "gemini-cli"],
      "path": "skills/optimization/campaign-budget-optimizer/"
    }
  ],
  "total": 47,
  "page": 1,
  "per_page": 20
}
```

---

### `GET /api/skills/:id`

Retrieve the full details and parsed `SKILL.md` content for a specific skill.

**Response:**

```json
{
  "id": "campaign-budget-optimizer",
  "name": "Campaign Budget Optimizer",
  "category": "optimization",
  "description": "Analyzes campaign spending patterns...",
  "use_cases": [
    "Redistribute monthly budget across 10+ campaigns",
    "Identify campaigns with declining conversion rates",
    "Generate a budget reallocation report for client review"
  ],
  "platforms": {
    "cursor": true,
    "claude_code": true,
    "codex": true,
    "gemini_cli": true
  },
  "examples": [...],
  "related_skills": [
    "bid-strategy-analyzer",
    "performance-report-generator"
  ],
  "raw_markdown": "# Campaign Budget Optimizer\n\n## Description\n..."
}
```

---

## Authentication

All API requests must include a valid API key in the `Authorization` header:

```
Authorization: Bearer sk_live_xxxxxxxxxxxxxxxxxxxx
```

API keys are scoped to a specific googleadsagent.ai™ account and can be generated from the dashboard at `https://app.googleadsagent.ai/settings/api-keys`.

### Key Types

| Key Type | Prefix | Permissions |
|----------|--------|-------------|
| Live     | `sk_live_` | Full access to all endpoints |
| Test     | `sk_test_` | Read-only access, no budget modifications |
| Webhook  | `whk_`     | Webhook signature verification only |

---

## Rate Limits

API requests are rate-limited per API key to ensure fair usage and platform stability.

| Plan       | Requests per minute | Requests per day | Concurrent streams |
|------------|--------------------|--------------------|---------------------|
| Free       | 10                 | 500                | 1                   |
| Pro        | 60                 | 10,000             | 5                   |
| Enterprise | 300                | 100,000            | 25                  |

Rate limit headers are included in every response:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 57
X-RateLimit-Reset: 1714320000
```

When a rate limit is exceeded, the API returns a `429 Too Many Requests` response with a `Retry-After` header indicating the number of seconds to wait.

---

## Error Codes

All error responses follow a consistent format:

```json
{
  "error": {
    "code": "INVALID_CUSTOMER_ID",
    "message": "The provided Google Ads customer ID is not valid or not linked to this account.",
    "status": 400
  }
}
```

### Error Code Reference

| Code | Status | Description |
|------|--------|-------------|
| `UNAUTHORIZED` | 401 | Missing or invalid API key |
| `FORBIDDEN` | 403 | API key does not have permission for this action |
| `NOT_FOUND` | 404 | Requested resource does not exist |
| `INVALID_REQUEST` | 400 | Request body is malformed or missing required fields |
| `INVALID_CUSTOMER_ID` | 400 | Google Ads customer ID is invalid or unlinked |
| `SKILL_NOT_FOUND` | 404 | The requested skill does not exist in the registry |
| `SKILL_EXECUTION_ERROR` | 500 | The skill encountered an error during execution |
| `MODEL_UNAVAILABLE` | 503 | The selected LLM is temporarily unavailable |
| `RATE_LIMITED` | 429 | Request rate limit exceeded |
| `QUOTA_EXCEEDED` | 429 | Daily request quota exhausted |
| `INTERNAL_ERROR` | 500 | An unexpected server error occurred |
| `STREAM_INTERRUPTED` | 500 | The SSE stream was interrupted before completion |
| `GOOGLE_ADS_API_ERROR` | 502 | The Google Ads API returned an error |
| `TIMEOUT` | 504 | The request exceeded the maximum execution time |
