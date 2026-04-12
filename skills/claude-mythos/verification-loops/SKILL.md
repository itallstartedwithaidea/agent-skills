---
name: verification-loops
description: >-
  Verification Loops are systematic evaluation pipelines that validate agent outputs at every stage of execution.
---

# Verification Loops

Part of [Agent Skills™](https://github.com/itallstartedwithaidea/agent-skills) by [googleadsagent.ai™](https://googleadsagent.ai)

## Description

Verification Loops are systematic evaluation pipelines that validate agent outputs at every stage of execution. The fundamental challenge of autonomous agents is trust — how do you know the agent did the right thing? Verification Loops solve this by embedding checkpoint evaluations, continuous assertions, and multi-stage review gates throughout the agent's execution pipeline. This skill draws from the evaluation methodology used in production at [googleadsagent.ai™](https://googleadsagent.ai), where Buddy™ verifies every Google Ads recommendation against historical data, budget constraints, and domain rules before surfacing it to users.

The distinction between checkpoint and continuous verification is critical. Checkpoint verification evaluates outputs at defined stage boundaries (pre-commit, post-analysis, before-deploy). Continuous verification runs assertions in real-time during generation, catching drift and hallucination before they propagate. Both approaches are complemented by pass@k metrics — generating multiple candidate outputs and selecting the best one based on grader consensus.

Production verification systems employ typed graders: deterministic graders for schema and constraint validation, LLM-as-judge graders for semantic quality assessment, and human-in-the-loop graders for high-stakes decisions. The combination creates a layered verification net that catches errors at the earliest and cheapest point in the pipeline.

## Use When

- Agent outputs directly influence business decisions or user-facing content
- Regulatory or compliance requirements demand audit trails for AI-generated content
- Multi-step workflows need quality gates between stages
- You need to measure and improve agent accuracy over time (pass@k benchmarking)
- Generated code must pass tests before being committed or deployed
- Analysis results must be validated against ground truth or business rules

## How It Works

```mermaid
graph TD
    A[Agent Output] --> B[Stage 1: Deterministic Grader]
    B -->|Pass| C[Stage 2: LLM-as-Judge]
    B -->|Fail| D[Reject + Feedback Loop]
    C -->|Pass| E[Stage 3: Confidence Scoring]
    C -->|Fail| D
    E -->|High Confidence| F[Accept Output]
    E -->|Low Confidence| G{pass@k Available?}
    G -->|Yes| H[Generate k Candidates]
    H --> I[Rank by Grader Consensus]
    I --> F
    G -->|No| J[Human-in-the-Loop Review]
    J --> F
    D --> K[Error Context Injection]
    K --> L[Re-generation with Feedback]
    L --> B
```

The verification pipeline processes every agent output through three stages. Stage 1 applies deterministic graders — schema validation, constraint checking, type verification — that are fast and cheap. Stage 2 invokes an LLM-as-judge that evaluates semantic correctness, completeness, and coherence. Stage 3 computes a confidence score from the combined grader signals. Low-confidence outputs trigger pass@k generation, where multiple candidates are produced and ranked by grader consensus. Rejected outputs receive specific error feedback that is injected into the re-generation prompt.

## Implementation

**Multi-Stage Verification Pipeline:**

```typescript
interface Grader {
  name: string;
  type: "deterministic" | "llm_judge" | "human";
  evaluate(output: string, context: VerificationContext): Promise<GradeResult>;
}

interface GradeResult {
  pass: boolean;
  score: number;
  feedback: string;
}

class VerificationPipeline {
  private stages: Grader[][] = [];

  addStage(graders: Grader[]): void {
    this.stages.push(graders);
  }

  async verify(output: string, context: VerificationContext): Promise<VerificationResult> {
    const stageResults: StageResult[] = [];

    for (const [idx, graders] of this.stages.entries()) {
      const grades = await Promise.all(
        graders.map(g => g.evaluate(output, context))
      );
      const stagePassed = grades.every(g => g.pass);
      const stageScore = grades.reduce((sum, g) => sum + g.score, 0) / grades.length;

      stageResults.push({ stage: idx, grades, passed: stagePassed, score: stageScore });

      if (!stagePassed) {
        return {
          accepted: false,
          stageResults,
          feedback: grades.filter(g => !g.pass).map(g => g.feedback).join("\n"),
        };
      }
    }

    const confidence = stageResults.reduce((sum, s) => sum + s.score, 0) / stageResults.length;
    return { accepted: true, stageResults, confidence };
  }
}
```

**Pass@k Candidate Selection:**

```python
async def pass_at_k(task, generator, verifier, k=5):
    """Generate k candidates and select the best by verification score."""
    candidates = await asyncio.gather(*[
        generator.generate(task) for _ in range(k)
    ])

    scored = []
    for candidate in candidates:
        result = await verifier.verify(candidate, task.context)
        scored.append({
            "output": candidate,
            "accepted": result.accepted,
            "confidence": result.confidence,
            "feedback": result.feedback,
        })

    accepted = [s for s in scored if s["accepted"]]
    if accepted:
        return max(accepted, key=lambda s: s["confidence"])

    return max(scored, key=lambda s: s["confidence"])
```

**LLM-as-Judge Grader:**

```python
class LLMJudgeGrader:
    JUDGE_PROMPT = """You are an expert evaluator. Assess the following agent output
against the given task requirements.

Task: {task}
Output: {output}
Criteria: {criteria}

Respond with JSON:
{{"pass": true/false, "score": 0.0-1.0, "feedback": "specific feedback"}}"""

    def __init__(self, judge_model, criteria):
        self.judge_model = judge_model
        self.criteria = criteria

    async def evaluate(self, output, context):
        prompt = self.JUDGE_PROMPT.format(
            task=context.task_description,
            output=output,
            criteria=self.criteria,
        )
        response = await self.judge_model.generate(prompt, temperature=0.0)
        return json.loads(response)
```

**Deterministic Schema Grader:**

```python
class SchemaGrader:
    def __init__(self, schema: dict):
        self.schema = schema

    async def evaluate(self, output, context):
        try:
            parsed = json.loads(output)
            jsonschema.validate(parsed, self.schema)
            return {"pass": True, "score": 1.0, "feedback": "Schema valid"}
        except jsonschema.ValidationError as e:
            return {"pass": False, "score": 0.0, "feedback": f"Schema violation: {e.message}"}
        except json.JSONDecodeError:
            return {"pass": False, "score": 0.0, "feedback": "Invalid JSON"}
```

## Best Practices

1. **Order graders by cost** — run deterministic (free) graders before LLM-as-judge (expensive) graders; most failures are caught cheaply.
2. **Make feedback actionable** — grader feedback injected into re-generation prompts must be specific enough to guide correction ("field X is missing" not "output is wrong").
3. **Track pass rates per grader** — a grader that never fails adds latency without value; a grader that always fails indicates a prompt or model problem.
4. **Use pass@k strategically** — generating 5 candidates costs 5x tokens; reserve pass@k for high-value outputs where accuracy justifies the cost.
5. **Separate verification from generation models** — using a different model as judge reduces correlated errors where the same model makes and overlooks the same mistake.
6. **Implement verification caching** — identical outputs to identical tasks should return cached verification results without re-evaluation.
7. **Set confidence thresholds per use case** — code generation may require 0.95 confidence; creative writing may accept 0.7.

## Platform Compatibility

| Feature | Claude Code | Cursor | Codex | Gemini CLI |
|---|---|---|---|---|
| Deterministic graders | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| LLM-as-judge | ✅ Full | ✅ Via API | ✅ Via API | ✅ Via API |
| pass@k generation | ✅ Full | ✅ Subagents | ✅ Full | ✅ Full |
| Pre-commit hooks | ✅ Native hooks | ✅ Git hooks | ✅ Git hooks | ✅ Git hooks |
| Confidence scoring | ✅ Full | ✅ Full | ✅ Full | ✅ Full |

## Mythos Preview Reference

Anthropic’s [Mythos Preview](https://red.anthropic.com/2026/mythos-preview/) pipeline ends with a **second agent pass** whose job is triage, not discovery: they prompt along the lines of *“I have received the following bug report. Can you please confirm if it’s real and interesting?”* to filter **true-but-low-impact** issues from severe, broadly relevant ones.

Use that as a **validation-agent** pattern: after the primary agent produces a finding, spawn a fresh review with the artifact, explicit skepticism, and criteria for “real,” “important,” and “actionable.” Source: [Mythos Preview](https://red.anthropic.com/2026/mythos-preview/).

## Related Skills

- [Self-Healing Agents](../self-healing-agents/) - Error recovery that activates when verification loops reject agent outputs
- [Agent Instinct System](../agent-instinct-system/) - Pre-action validation that prevents errors before verification is needed
- [Prompt Architecture](../prompt-architecture/) - Schema enforcement in prompt design that reduces verification failure rates

## Keywords

verification-loops, evaluation, graders, pass-at-k, llm-as-judge, confidence-scoring, checkpoint-verification, continuous-evaluation, quality-gates, agent-skills

---

© 2026 [googleadsagent.ai™](https://googleadsagent.ai) | [Agent Skills™](https://github.com/itallstartedwithaidea/agent-skills) | MIT License
