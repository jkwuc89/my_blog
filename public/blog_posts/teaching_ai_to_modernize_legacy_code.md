For the last six months, I've been leading an AI-assisted rewrite of a legacy web application for an Improving client. Early on, I learned that the prompts I typed were not the product. The product was the **rules and skills** underneath them: 43 rules, 8 skills, and roughly 26,000 lines of Markdown that taught AI agents how to do this job the way the team needed it done.

This post is a tour of that corpus—what it contains, how it's wired together, and what I'd do the same (and differently) next time.

## The Job

The client runs a SaaS product built on a legacy stack: VBScript and XML page definitions sitting on top of a .NET Framework API. The target is a modern stack: an Angular single-page app on the front end and a layered .NET 10 back end (controllers → services → providers → models) on the back end. Both apps share the same database, which is owned by a separate team.

The engagement came with four non-negotiable constraints, and they shaped everything that followed:

* **1-to-1 rewrite:** match legacy behavior exactly—including the bugs.
* **Match existing patterns:** follow the screens already converted. Don't invent new ones.
* **No new features:** feature requests go to the backlog, not into the conversion PR.
* **Minimize client overhead:** exhaust the code, the docs, and our tooling before asking the client's team a question.

An AI agent will happily violate every one of these. It will "improve" a weird calculation, introduce a clever new abstraction, and add a feature nobody asked for—all in the same commit. Writing *"please don't do that"* in a prompt doesn't scale. Writing it into rules that load automatically does.

## By the Numbers

Here's the scale of the work, in aggregate:

* **43 rules and 8 skills**, roughly 26,000 lines of Markdown, plus a 1,500-line Python auditor with about 1,000 lines of tests.
* **About 2,100 commits** across the engagement's tickets over six months. I authored most of them, but my Improving teammates and the client's developers contributed too.
* **Roughly a dozen screens** converted.
* **Cycle time dropped from months to days.** The first screens took months. By September, smaller report screens were going from analysis to PR in three to four days.

That last number is the one that matters. It didn't come from a better model. It came from a corpus that got a little smarter after every screen.

## Rules vs. Skills

The corpus has two kinds of files, and the distinction is the most important design decision in the whole thing.

**Rules** are standing policy. They load automatically, either on every message (*always-on*) or only when the agent touches a file matching a glob (*path-scoped*). A rule about DevExtreme grids doesn't need to be in context while the agent writes a SQL provider, so it declares where it applies:

~~~ yaml
---
name: dx-editable-grid
description: >
  Editable DevExtreme DataGrid patterns — action column, soft delete, add row,
  save button + dirty indicator, totals row.
paths:
  - "ui/**/*.component.ts"
  - "ui/**/*.component.html"
  - "ui/**/*.component.scss"
---
~~~

**Skills** are on-demand procedures: *"modernize this screen"*, *"resolve these PR comments"*, *"walk this QA issue list."* They sit dormant until invoked, apart from their name and description.

Why does this matter? **Context is a budget.** The audit skill's check catalog puts it bluntly:

> *"What a file actually costs depends on when it loads, not how long it is: an always-on rule is resident on every message, a path-scoped rule only while matching files are open, and a skill body only once invoked."*

Only six of the 43 rules are always-on today, down from eight. Everything else earns its way into context by matching a file the agent is actually working on. Even skill descriptions have a character budget, because *"a description carrying implementation detail pays for that detail on every turn of every conversation."*

## What Became a Skill—and What Became a Rule

People have asked what actually goes into a corpus like this. Here are the general-purpose skills and a sample of the rules, with client-specific details removed.

### The Skills

| Skill | What it does |
|---|---|
| `lift-and-shift-modernization` | Converts one legacy screen end to end: analysis, plan, implementation, PR, QA signoff |
| `create-modernization-plan` | Writes the plan: analysis carry-forward, baseline conformance, work items ordered by layer |
| `build-export` | Adds PDF/Excel export to a converted screen, back end and front end |
| `resolve-pr-comments` | Walks a PR's review threads one at a time: fix, commit, reply, harvest |
| `resolve-qa-issues` | Triages a QA issue list, then fixes, verifies, and annotates each issue |
| `audit-rules-and-skills` | Lints the corpus itself |

The other two skills handle client-specific integrations that wouldn't carry over to another project.

### The Rules

| Category | Count | Examples |
|---|---|---|
| **Always-on** | 6 | architecture guardrails, conversion workflow, git approval gates, naming conventions, commit markers, safe read-only commands |
| **Angular / UI** | 12 | component patterns, signals, routing, editable data grids, accessibility, design-system package policy |
| **.NET** | 9 | controllers, services, SQL providers, models, async, exception handling, logging |
| **Tests** | 7 | Angular unit tests, .NET unit and integration tests, mocking, Playwright end-to-end tests and page objects |
| **Database** | 3 | migrations, and a "shared database is read-only" rule |
| **Plans** | 3 | plan conventions, plan conformance, a digest of rules that apply at planning time |
| **Legacy analysis** | 2 | how to read the legacy XML page definitions, step by step |
| **Meta** | 1 | edit the corpus at its source, never through the symlinks |

### Rule or Skill?

The line I landed on:

* **It's a rule if it must always be true.** "Never call `.ToList()` on a provider result" and "controllers take a cancellation token last" are rules. They're triggered by the files being edited, not by a request.
* **It's a skill if it has a start, an end, and steps in between.** "Modernize this screen" or "walk these QA issues" are skills. You invoke them, they produce something, and they usually include human approval gates.
* **A reviewer comment usually becomes a rule. A task you keep repeating usually becomes a skill.** If you keep typing the same multi-step request, write it down once.
* **When a rule starts growing a procedure, split it.** The conversion workflow began as a 250-line rule and grew past 300. Now it's a 38-line always-on rule that points to the procedure inside the planning skill.

## Thin Orchestrators, Fat References

The always-on `conversion-workflow` rule is only 38 lines long. It declares the phase order—**Analyze → Build → Verify**, with the back end shipping before the front end—and then points to the skill's reference doc for the step-by-step procedure.

That pattern repeats throughout: a thin, always-loaded rule that states *what must be true*, backed by a detailed reference that loads only when it's needed. The lift-and-shift skill works the same way, loading each phase file only when that phase begins.

There's one exception, and it's deliberate. The skill's hard rules stay in the main file, always in context. In the skill's own words: **"Hard rules are never behind a pointer."** If a rule must never be broken, the agent must never have to go looking for it.

## The Lift-and-Shift Skill

The biggest skill—and the one that drove the cycle-time drop—is `lift-and-shift-modernization`. It runs a screen end to end:

1. **Analyze.** Query Improving's Code Explorer (a knowledge graph of the legacy codebase, exposed to the agent over MCP), read the legacy source, and fold in the SME spec and QA scenarios.
1. **Plan.** Generate a modernization plan: analysis carry-forward, baseline conformance, and numbered work items ordered by architecture layer (models → provider → service → controller → Angular service → UI → routing → export → end-to-end tests).
1. **⛔ Plan review.** A human approves the plan before any code is written.
1. **Implement.** One work item at a time, building and testing after each.
1. **⛔ Manual verification.** A human clicks through the screen side by side with the legacy one.
1. **Verify, PR, QA signoff.** Generate end-to-end scenarios, run the suites, and open the PR.

Two details made this work.

First, **the knowledge graph is a map, not the territory.** The analysis phase states it plainly: Code Explorer *"is structural... never authoritative for behavior... Where graph and [legacy] source disagree, [legacy] source wins."* The graph tells the agent which files to read. The files tell it what the screen actually does.

Second, **the skill learns.** Mid-engagement, the team voted to try a strict lift-and-shift approach to stop churning on redesigns. After every screen, whatever went wrong got folded back into the skill as a hard rule, a checklist item, or a known failure mode. The skill now has 24 numbered hard rules, and every one of them has a story behind it.

## Replicate the Bug

The 1-to-1 constraint means that when the agent finds something that looks wrong in the legacy code, it doesn't get to fix it. It gets to flag it, with a comment like this one:

~~~ csharp
// SUSPECTED LEGACY BUG: totals exclude voided rows only on the first page — replicated for parity, PO to investigate
~~~

The rule forbids silent workarounds. The bug is reproduced faithfully, labeled with a searchable marker, and handed to the product owner to decide on. That keeps the rewrite honest and gives the product team a ready-made list of legacy defects to triage later.

## Guardrails on Git

AI agents are very good at producing commits. So one of the six always-on rules, `git-confirm-before-mutating`, is about *not* letting them do that on their own:

> *"NEVER run any of the commands above unattended... even if the user previously approved an identical command in a prior turn. Each invocation requires fresh approval."*

A few other lines in that rule came from hard experience:

* **No `--no-verify`.** If a hook fails, fix the cause.
* **No git worktrees.** The primary checkout holds the installed packages, local config, and whatever the developer is running. Work in a second tree quietly diverges from what's being reviewed.
* **Some repos are read-only, full stop.** The legacy source and the shared database repo can't be modified, *even with approval*. Those changes belong in the owning team's PR.

Commits also carry a marker that says *who drove the change*:

| Marker | Used when | Approx. count |
|---|---|---|
| `Plan -` | Editing the plan, skills, or rules | 416 |
| `Plan Impl -` | Implementing a plan work item | 309 |
| `Fix -` | The implementer revising their own work | 581 |
| `PR Fix -` | A reviewer-requested fix to plan-delivered code | 193 |
| `PR -` | A reviewer-requested fix to anything else | 77 |

The reasoning, straight from the rule: *"git log becomes self-documenting... Conflating them hides who drove the change."* Even the ticket prefix is deterministic. The agent parses it from the branch name with a regex like `^(?:feature|bugfix|hotfix)/([A-Z]+-\d+)`, so `feature/PROJ-123-export` yields `PROJ-123`. If the branch doesn't match, it stops and asks instead of guessing.

## Closing the Loop: Feedback Becomes Rules

Two skills handle the feedback that comes back after a PR goes up.

**`resolve-pr-comments`** pulls the active review threads from a pull request and walks them one at a time: analyze the comment, make the fix, get approval, commit with the right marker, and draft the reply.

**`resolve-qa-issues`** takes a QA issue list and opens with a triage report grouped by difficulty, so I choose the processing order. Each issue then goes through analyze → fix → manual verification → annotate the issue list, and the fix and annotation land in one commit.

The most valuable step in both is the **harvest**. After a fix, the skill compares the diff against the rule corpus and asks: *should this become a rule?* That's how rules like *"never call `.ToList()` on a provider's query result"* and a ban on fire-and-forget HTTP subscriptions got written—each one after a reviewer caught it once.

The harvest has one strict limit. It only **proposes**:

> *"The skill never writes to [the rules] autonomously — not even behind an approval gate... Rule edits have broader downstream consequences than the fix that prompted them; the user owns the rule corpus."*

The agent can suggest policy. A human decides it.

## Linting the Prompts

Twenty-six thousand lines of Markdown rot just like code does. Globs stop matching after a folder rename, cross-references point to sections that moved, and a README claims "8 always-on rules" long after it became six.

So the corpus has its own linter. `audit-rules-and-skills` runs two layers of checks:

* **Per-file:** strict YAML frontmatter, schema, symlink integrity, encoding, names matching filenames, globs that still match something, and each skill's own test suite.
* **Corpus-wide:** citations resolve, count claims are true, section references exist, and the always-on context budget holds.

It's diff-scoped by default, with an opt-in full sweep, and it walks each auto-fixable issue behind an approval gate. The frontmatter parser follows one contract: **"reject rather than guess."** A false error is cheaper than a silent mis-parse that mis-reports the whole corpus.

## Six Months, Four Tool Setups

The corpus started life in **Windsurf**, moved to **Devin**, became a tool-agnostic `agents/` folder synced into each tool by a script, and finally landed in **Claude Code**. It's now wired in with two directory symlinks, `.claude/rules` and `.claude/skills`, pointing at the source of truth.

The surprising lesson came from the final migration. Before touching anything, I wrote a source-controlled refinement plan, and it turned up **tool limitations that had quietly hardened into "policy."** A 12,000-character file size cap was really just Windsurf's truncation point. Nine rules had been split in two purely to fit under it. Once I checked each inherited constraint against the new tool's documentation, those rules were merged back and the cap was deleted.

Keep your source of truth vendor-neutral, and periodically ask of each constraint: *is this ours, or is it just the last tool's limitation?*

## Lessons Learned

* **Treat prompts as code.** Version them, review them in PRs, test them, and lint them.
* **Humans own the gates.** The agent plans, implements, and proposes. A person approves the plan, verifies the screen, and approves every commit.
* **Encode constraints, not just instructions.** "Replicate the bug" and "never touch that repo" matter more than any how-to.
* **Budget your context.** Always-on is expensive. Make every rule justify when it loads.
* **Feed every correction back into the corpus.** A reviewer comment that becomes a rule is never made twice.
* **Source wins over summaries.** Knowledge graphs, specs, and AI-generated analysis point the way. The code itself is the authority.

## Final Thought

The model did a lot of typing on this project, but **the leverage came from the corpus**. Every PR comment, QA issue, and near-miss made the next screen faster, because the lesson was written down where the agent would find it. That's the real shift: the job is less about writing code and more about writing the rules the code gets written by.

If you're tackling a legacy modernization and want to talk about building a corpus like this, reach out to me here or through [Improving](https://improving.com).
