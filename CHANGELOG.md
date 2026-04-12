# Changelog

All notable changes to Agent Skills will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-04-12

### Fixed

- **README catalog links** — All skill category links now point to actual directories (`skills/google-ads/`, `skills/ai-agent-engineering/`, etc.) instead of non-existent paths
- **AGENTS.md and CLAUDE.md** — Updated category names to match real directory structure
- **Validation script** — `validate-skills.sh` now checks for `## Use When` (matching actual skills) instead of `## Use Cases`
- **Format spec** — `docs/skill-format.md` aligned with actual skill format: `## Use When`, `## Implementation`, `## Best Practices`

### Added

- **Developer-first README** — Complete restructure: inline skill example, format spec table, working Quick Start, visual assets
- **Hero banner image** — `assets/images/hero-banner.png` showing all 10 skill categories
- **Skill anatomy diagram** — `assets/images/skill-anatomy.png` annotated SKILL.md format reference
- **Related Skills** — All 73 skills now have `## Related Skills` section with cross-category links
- **Updated translations** — All 6 language READMEs (FR, ES, ZH, NL, RU, KO) updated to match restructured English version

### Changed

- README leads with "What Does a Skill Look Like?" (developer-first) instead of marketing copy
- Skills Catalog table uses correct directory names and counts
- Credits table shows verified star counts
- Quick Start removes unpublished `npx` command, focuses on working methods

## [1.0.0] - 2026-04-10

### Added

- Initial release of Agent Skills by googleadsagent.ai
- 73 production-ready skills across 10 categories
- Google Ads (12 skills)
- AI Agent Engineering (10 skills)
- Claude Mythos (10 skills)
- Software Development (8 skills)
- Scientific Research (8 skills)
- Web Frontend (6 skills)
- Productivity (6 skills)
- Infrastructure (6 skills)
- Security (4 skills)
- Media Creative (3 skills)
- Full documentation in 7 languages (English, French, Spanish, Chinese, Dutch, Russian, Korean)
- Standardized SKILL.md format specification
- CI/CD pipeline with skill validation
- Contributing guide with PR templates
- Buddy Agent architecture documentation
- API reference for tool calling and MCP server integration
