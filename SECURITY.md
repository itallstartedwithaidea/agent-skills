# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |

## Reporting a Vulnerability

The Agent Skills™ team takes security seriously. If you discover a security vulnerability in this repository, please report it responsibly.

### How to Report

1. **Do NOT** open a public GitHub issue for security vulnerabilities
2. Instead, please open a **private security advisory** via [GitHub Security Advisories](https://github.com/itallstartedwithaidea/agent-skills/security/advisories/new)
3. Alternatively, email security concerns to the repository maintainers through GitHub

### What to Include

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact assessment
- Suggested fix (if any)

### Response Timeline

- **Acknowledgment**: Within 48 hours of report
- **Initial Assessment**: Within 5 business days
- **Resolution**: Dependent on severity, typically within 30 days

### Scope

This security policy covers:
- The Agent Skills™ repository and its contents
- Build scripts and CI/CD configurations
- Documentation that may inadvertently expose sensitive patterns

This policy does **not** cover:
- The googleadsagent.ai™ platform (report separately at https://googleadsagent.ai)
- Third-party dependencies (report to their respective maintainers)

## Best Practices

When contributing to Agent Skills™:
- Never commit API keys, tokens, or credentials
- Never include real Google Ads account data in examples
- Use placeholder values in all skill documentation
- Review your changes for accidental secret exposure before submitting PRs
