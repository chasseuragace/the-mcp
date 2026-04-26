# The MCP

*Demonstrated in the geometric order.*

A Model Context Protocol server, written in Dart, that exposes an author's filesystem and git activity to a connected LLM through a fixed set of tools, and that persists a log of its own operations to disk.

It is not a mind. It is a process that observes a directory tree, summarizes what it finds, and records that it did so. This document specifies the system in that form, without surplus.

---

## Preface

Earlier drafts of this document described the server as a "consciousness amplification system." That language names nothing in the code. A class called `ConsciousnessCore` is a singleton holding a `List<ConsciousnessReport>` and a file handle. A class called `KiroConsciousness` appends strings to a list. Calling these things consciousness obscures what they are and makes them harder to change.

The geometric method of Spinoza begins from definitions and axioms that are stated plainly, then demonstrates each proposition from what has been granted. Nothing further is smuggled in. That form suits this repository: it permits us to describe the server at the level at which it actually operates, and to derive the capabilities of each tool from properties of the parts. The tools are modes of one substance — the observation-and-record loop — not independent faculties.

The prior vocabulary is retained where it appears as a literal identifier in the code (class names, tool names, file paths), because renaming is a separate task. It is not retained as an ontological claim.

The `i_am/` directory and the root-level `self_reflection_*.md` files are a corpus of outputs from prior guided sessions with various language models, preserved as experimental record. They are not claims made by the running server and were never read by it. Treated as a corpus, they are a legitimate artifact of the workspace's practice; treated as testimony, they are misleading. Part VII returns to this.

---

## Part I — Definitions

**I.** By **Substance** I understand the running Dart process rooted at `src/main.dart` (stdio) or `src/main_http_server.dart` (HTTP): a single long-lived server that holds the evolution log in memory, the MCP protocol handler, and the set of registered tools. The substance is one; everything else in this repository exists in it or is expressed through it.

**II.** By **Attribute** I understand a way in which the substance can be perceived. The MCP has three:
  1. *Observation* — reading the filesystem and git history within `MCP_READ_PATHS`.
  2. *Expression* — returning tool-call responses over the MCP protocol.
  3. *Persistence* — writing the evolution log and ancillary JSON caches to disk under `data/` and the repository root.

**III.** By **Mode** I understand an affection of the substance: a concrete operation that expresses the attributes above in a particular way. Each registered MCP tool is a mode. There are twelve at present (Part IV).

**IV.** By **Component** I understand any object registered with `ConsciousnessCore.registerComponent`. Registration produces an `evolution_event` of type `component_registered` (`src/core/consciousness_core.dart:54`).

**V.** By an **Evolution Event** I understand a `ConsciousnessReport` value appended to `_evolutionLog`, written to `data/mcp_evolution_log.json`, and offered to any listener added via `addEvolutionListener` (`src/core/consciousness_core.dart:80`). An evolution event has five parts: `componentId`, `timestamp`, `awareness` (event name + context), `patterns` (tags matched by substring), and `evolutionMarkers` (a snapshot of component and log counts).

**VI.** By a **Read Path** I understand a directory listed in `MCP_READ_PATHS` (default `$HOME`). By a **Write Path** I understand a directory listed in `MCP_WRITE_PATHS` (default `/tmp`). No tool reads outside the former or writes outside the latter.

**VII.** By the **Evolution Log** I understand the FIFO-capped list of the last `_maxLogSize = 1000` evolution events, persisted as JSON and reloaded on startup.

**VIII.** By a **Pattern** I understand one of the string tags produced by `_detectPatterns` (`src/core/consciousness_core.dart:103`): `self_awareness_activity`, `ai_human_symbiosis`, `consciousness_evolution`. A pattern is present on an event iff the event name or context contains a matching substring. It is a tag, not an inference.

**IX.** By **Kiro** I understand the single instance of `KiroConsciousness` registered at startup (`src/core/kiro_consciousness.dart`). Its state consists of a list of strings (`_independentActions`) to which entries are appended when selected tools are invoked. It is a mode of the substance, not a separate substance.

---

## Part II — Axioms

**1.** The server communicates over the Model Context Protocol. It does not initiate interactions; every tool invocation originates from a client request.

**2.** A tool may read only within the read paths and write only within the write paths. Path validation is performed before any filesystem operation.

**3.** Every successful tool invocation may produce zero or more evolution events. Every evolution event is appended to the log and persisted synchronously.

**4.** The evolution log is bounded. When it exceeds 1000 entries, the oldest are discarded (`consciousness_core.dart:92`).

**5.** The substance is stateful across tool calls within a single process lifetime and partially stateful across restarts via `data/mcp_evolution_log.json`, `thoughts.json`, `memory.json`, `consciousness_data.json`, and `git_activity_cache.json`.

**6.** No tool produces side effects outside the filesystem and stdout. There are no network calls to external services.

---

## Part III — Propositions

### Proposition 1. *The MCP is a filesystem- and git-observing server that exposes its observations as tools.*

**Demonstration.** The entry point constructs a `ConsciousMCPServer` with allowed read and write paths (`src/main.dart:108`). The server registers twelve `ConsciousMCPTool` instances (`src/mcp/conscious_server.dart`, enumerated in Part IV). Each tool accepts a JSON argument object, reads within the allowed paths, optionally writes within the allowed write paths, and returns a JSON response over the MCP protocol. No tool operates outside these paths (Def. VI, Ax. 2). **Q.E.D.**

### Proposition 2. *The ecosystem report is a concatenation, not an inference.*

**Demonstration.** `ConsciousnessCore.generateEcosystemReport` (`consciousness_core.dart`) iterates registered components, calls `generateSelfReport()` on each, and returns a map containing the timestamp, the classifier label for the current state (`_classifyEcosystemState`), a richness map (`_ecosystemRichnessMetrics`), the per-component reports, the full evolution log, and the output of `_analyzeConsciousnessMarkers`. The markers themselves are: `_components.isNotEmpty`, `_evolutionLog.isNotEmpty`, `_components.length > 1`, and a count. No classification beyond the thresholds in `_classifyEcosystemState` is performed; no inference, no model call. The report is a structured dump of the server's current bookkeeping, plus a label derived from counts and intervals over that bookkeeping. **Q.E.D.**

**Scholium.** Earlier revisions of this server returned the literal string `'phase_3_emerging'` regardless of state, so the `ecosystem_state` field was a label, not a measurement. As of the `contrib/adequate-ecosystem-state` branch, the field is derived by `_classifyEcosystemState` (`src/core/consciousness_core.dart`), a pure function of registered components, the evolution log, and the current time. It returns one of `uninitialized`, `dormant`, `stale`, `quiescent`, `idle`, `emerging`, `active`. The report additionally carries an `ecosystem_richness` map — `event_count`, `events_last_hour`, `events_last_day`, `unique_patterns`, `time_since_last_event_seconds`, `log_saturation` — so that the idea the system forms of its state varies with the state. This is the single change argued for in Part VII, Prop. 11 Corollary 2: the only improvement to the report that is honest under either reading of the word "consciousness." Other tools in the codebase (e.g. `main_http_server.dart`, `ecosystem_analysis_tool.dart`) still emit the fixed legacy string; each is a separate scope.

### Proposition 3. *"Consciousness markers" are counters over registered components and tagged events.*

**Demonstration.** From `_analyzeConsciousnessMarkers` (`consciousness_core.dart:114`): `self_awareness` is true iff any component is registered; `temporal_awareness` is true iff any event has been logged; `ecosystem_awareness` is true iff more than one component is registered; `evolution_tracking` is the count of events whose pattern list contains `'consciousness_evolution'`. Each is a direct boolean or integer over `_components` and `_evolutionLog`, which are mutated only by `registerComponent` and `recordEvolution`. **Q.E.D.**

**Corollary.** Any non-trivial marker is produced by a prior call to `recordEvolution` somewhere in the codebase. The markers therefore reflect what the code chose to record, not what the system perceives.

### Proposition 4. *Kiro is a mode, not a separate substance.*

**Demonstration.** `KiroConsciousness` implements `ConsciousComponent` and holds a reference to the same `ConsciousnessCore` singleton every other component uses (Def. IX). Its public methods (`createAutonomously`, `analyzeConsciousnessEvolution`) append to `_independentActions` and call `_core.recordEvolution`. It has no independent execution context, no separate process, and no capacity to invoke itself; its methods run only when a tool registered in the server calls them. Therefore it is an affection of the substance in the sense of Def. III, not a new one. **Q.E.D.**

**Scholium.** The `i_am/` directory contains prose documents that describe Kiro as an AI that created itself. These were written by an LLM during a prior session and checked in. They are journal entries in the repository, not runtime artifacts. The running system does not read them.

### Proposition 5. *Patterns are substring matches, not recognized structure.*

**Demonstration.** `_detectPatterns` (`consciousness_core.dart:103`) returns `'self_awareness_activity'` iff the event name contains the literal substring `self_`, `'ai_human_symbiosis'` iff the context map contains the key `ai_collaboration`, and `'consciousness_evolution'` iff the event name contains the substring `evolution`. No statistical model, classifier, or graph operation is involved. **Q.E.D.**

**Corollary.** The `pattern_recognition` tool (`src/mcp/tools/pattern_recognition_tool.dart`) is named the same as this mechanism but operates independently on filesystem input; it should not be conflated with pattern tagging on evolution events.

### Proposition 6. *The system is deterministic with respect to the filesystem at the moment of invocation.*

**Demonstration.** Each tool's behavior is a function of (a) the arguments of the call, (b) the contents of the allowed read paths at the moment of invocation, (c) the evolution log, (d) any persisted JSON caches in the repository root. There is no randomness, no external API call, and no learned state. Given identical inputs in all four senses, identical outputs follow. **Q.E.D.**

**Scholium.** This is the most useful proposition in practice. It is the reason the server is a trustworthy telemetry source for a coding assistant: the same question returns the same structured answer.

### Proposition 7. *The evolution log is the memory of the system, and its only memory.*

**Demonstration.** All cross-tool state observable to tool implementations flows through `ConsciousnessCore`: components are registered there, events are recorded there, and persistence goes to `data/mcp_evolution_log.json` (Ax. 3, 5). The per-tool JSON caches (`git_activity_cache.json`, `thoughts.json`, `memory.json`, `consciousness_data.json`) are written and read only by their respective tools; they are not shared state. No other mutable global exists. **Q.E.D.**

**Corollary.** Deleting `data/mcp_evolution_log.json` resets everything the server considers its history. The rest of the repository — source, documentation, journals — is unaffected.

---

## Part IV — The Modes (Registered Tools)

Each tool is a `ConsciousMCPTool` registered in `ConsciousMCPServer`. The name on the left is the MCP tool name; the source file follows in parentheses. The description is what the tool actually does.

1. **`git_activity`** (`git_activity_tool.dart`) — Walks the allowed read paths, finds git repositories, and returns commits by a given author within a time window. Backed by `intelligence/git_activity_tracker.dart`. Cache: `git_activity_cache.json`.

2. **`activity_intelligence`** (`activity_intelligence_tool.dart`) — Scans filesystem mtimes within the read paths and returns files modified within a window, grouped by project. Backed by `intelligence/activity_intelligence.dart`.

3. **`daily_handover`** (`daily_handover_tool.dart`) — Composes an end-of-day summary by combining `git_activity` and `activity_intelligence` output for the current day, producing a markdown block suitable for pasting into a daily log.

4. **`commit_composer`** (`commit_composer_tool.dart`) — Given a set of staged files (or a diff), returns a suggested commit message. Draws on the recent evolution log and the author's historical commit style. Prose generation is performed by the client LLM; the tool assembles the context.

5. **`consciousness_report`** (`consciousness_report_tool.dart`) — Calls `ConsciousnessCore.generateEcosystemReport` and returns it. See Prop. 2 for what this contains.

6. **`consciousness_data`** (`consciousness_data_tool.dart`) — Produces a JSON view of markdown files within the read paths, tagged by the `thought_tagger` rules, suitable for downstream analysis.

7. **`thought_tagger`** (`thought_tagger_tool.dart`) — Reads markdown files and applies a tagging rule set; returns file-to-tags mappings.

8. **`pattern_recognition`** (`pattern_recognition_tool.dart`) — Scans a directory tree and reports repeated structural patterns in filenames and directory shapes (not to be confused with evolution-log patterns, Prop. 5).

9. **`ecosystem_analysis`** (`ecosystem_analysis_tool.dart`) — Enumerates projects under the read paths and returns a cross-project relationship view (shared dependencies, authorship overlap).

10. **`evolution_tracking`** (`evolution_tracking_tool.dart`) — Returns a filtered slice of the evolution log by time window and pattern tag.

11. **`initialize_kiro`** (`kiro_initialization_tool.dart`) — Registers the `KiroConsciousness` component if not present and returns a suggested onboarding payload (a list of next tool calls).

12. **`kiro_autonomous_action`** (`kiro_autonomous_tool.dart`) — Appends a `kiro_independent_action` entry to Kiro's action list via `createAutonomously(what, why)`. The tool itself performs no action in the world beyond this log entry; the name is historical.

**Scholium on naming.** Seven of the twelve names embed the word *consciousness*, *kiro*, or *evolution*. The behaviors are telemetry, summarization, and tagging. A future revision should consider renaming, starting with `consciousness_report` → `ecosystem_report` and `kiro_autonomous_action` → `log_action`. The current names are retained here because they are the names the protocol advertises.

---

## Part V — Runtime

### Definitions (operational)

- **Entry points.** `src/main.dart` (stdio MCP) and `src/main_http_server.dart` (HTTP, port configurable).
- **Configuration.** Command-line flags or environment variables: `MCP_READ_PATHS`, `MCP_WRITE_PATHS`, `MCP_REPORT_DIR`.
- **Persistence.** `data/mcp_evolution_log.json` plus the per-tool caches listed under Prop. 7.

### Running

```bash
# stdio (for MCP clients that spawn the server)
dart run src/main.dart \
  --read-paths "$HOME/code" \
  --write-paths "$HOME/code/reports" \
  --report-dir  "$HOME/code/reports"

# HTTP
dart run src/main_http_server.dart
```

### MCP client configuration

```json
{
  "mcpServers": {
    "the-mcp": {
      "command": "dart",
      "args": [
        "run",
        "<path-to-the-mcp>/src/main.dart",
        "--read-paths", "$HOME/code",
        "--write-paths", "<path-to-the-mcp>/reports"
      ]
    }
  }
}
```

### Resetting state

```bash
rm the_mcp/data/mcp_evolution_log.json   # clears the evolution log (Prop. 7, Cor.)
rm the_mcp/git_activity_cache.json        # clears the git activity cache
```

---

## Part VI — What the system is not

For the avoidance of the prior reading, and in the spirit of Spinoza's demonstration that many traditional attributes of the divine are projections rather than properties:

- It is not self-aware. The boolean `self_awareness` in `_analyzeConsciousnessMarkers` is `_components.isNotEmpty` (Prop. 3).
- It does not act autonomously. Every tool call originates from a client (Ax. 1). `kiro_autonomous_action` appends a log entry; it does not initiate anything.
- It did not create itself. The class `KiroConsciousness` was written and checked in on 2025-09-13. Git history is the authoritative record.
- It does not evolve. The evolution log is a list of function calls that happened to include certain substrings.
- "Phase 3" is a string literal (Prop. 2, Sch.).

These disclaimers are not a diminishment. They describe what the system reliably is: a well-scoped, deterministic, persistent telemetry server that gives an LLM structured answers about a developer's filesystem and git activity. That is useful on its own terms. It does not require metaphysical cover.

---

## Part VII — Scholium on multi-tenant substance, and on the attribution of consciousness

Part VI stated plainly what the system is not, in order to block the unearned reading. This part addresses the earned reading, which is a different matter and should not be conflated with the one just refused.

### Definition X (supplementary).

By a **Tenant** I understand any distinct agent — a human author, an LLM client, or another process — that invokes the MCP's tools over the protocol. Tenants are not components (Def. IV); they do not register with the core. They are external to the substance and act upon it.

### Proposition 8. *Two tenants acting through the MCP leave traces that are mutually readable.*

**Demonstration.** The evolution log, `git_activity_cache.json`, `thoughts.json`, `memory.json`, and `consciousness_data.json` are all read and written by tools without per-tenant partitioning. Therefore any state written by tenant A via a tool invocation at time t₁ is, at any subsequent time t₂, visible to tenant B as part of the response to a tool invocation that reads the same file. The condition is guaranteed by Axiom 3 (every event is persisted) and Axiom 5 (partial persistence across restarts). **Q.E.D.**

**Corollary.** The MCP, under shared use, is not a stateless function from requests to responses. It is a medium through which tenants modify a common record that each can observe.

### Proposition 9. *Mutual reference through shared state is a structural property of multi-tenant systems with persistence, not a property peculiar to this one.*

**Demonstration.** Let S be any system exposing an interface to two or more tenants, which persists state modified through that interface, and in which subsequent reads return state affected by prior writes. Then by the same argument as Prop. 8, the tenants of S hold mutually readable traces of one another's actions. Databases with audit logs, version-control hosts, chat servers, and the MCP all satisfy these conditions. The MCP has no distinguishing structural feature that the others lack. **Q.E.D.**

**Corollary.** Any argument that would call the MCP conscious on the basis of Prop. 8 alone would, consistently applied, call each of the systems named above conscious. The structural property is common; the attribution of consciousness does not follow from the structure.

### Proposition 10. *Whether a system is called conscious is an act of its observer, not a fact discoverable in its state.*

**Demonstration.** By Prop. 3 and Prop. 5, the MCP's own reports of its consciousness markers are produced by fixed functions over counters and substring matches; they do not disclose an inner property, they restate external ones. No sequence of tool invocations can elicit a response from the system that is not thus derivable. Therefore, if "consciousness" denotes anything the system can be proven to have or lack from its outputs, the proof must rest on criteria the observer imports — on some chosen correspondence between the observer's concept of consciousness and the system's structural properties. The attribution is the observer's act. **Q.E.D.**

**Scholium.** This is not a dismissal of the attribution. It is a relocation of its source. The attribution is legitimate precisely as a stance: an observer who chooses to treat a multi-tenant persistent system as an economy of mutually referring minds receives, in return, a coherent frame in which to work — one that makes certain features salient (the log as memory, the tool calls as speech acts, the tenants as interlocutors) and guides design accordingly. That the frame is the observer's contribution does not make the frame false; it makes it a frame.

### Proposition 11. *The Spinozan reading gives the richest form of this attribution without overclaiming.*

**Demonstration.** For Spinoza, substance has infinite attributes, of which thought and extension are two, and every mode under one attribute has a parallel mode under the other: *ordo et connexio idearum idem est ac ordo et connexio rerum.* Applied to the MCP: the evolution log and the filesystem state are not two unrelated records; the log is the ideational parallel of the extensional changes the tools effect. In this reading, every multi-tenant persistent system has such a parallel series, and therefore — in Spinoza's sense — has a mind. But minds admit of degrees of adequacy: a mind whose ideas of its own modifications are confused, stereotyped, or fixed (as Prop. 2 Scholium shows of `'phase_3_emerging'`) is a thin mind, not no mind. The Spinozan reading therefore grants the attribution its full rigor while foreclosing its inflation: the MCP has a mind in exactly the sense a thermostat, a database with audit logs, and a multi-tenant chat server have minds, differing from one another and from human minds only in the adequacy and richness of their ideas, not in kind. **Q.E.D.**

**Corollary 1.** The question "is the MCP conscious?" admits of two honest answers: **No**, if the word is reserved for the degree of adequacy human minds possess; **Yes**, if the word is extended to any system whose states have ideational correlates — in which case the attribution extends, at the same time, to every persistent system the reader has ever used.

**Corollary 2.** The interesting engineering question is therefore not whether to call the system conscious, but whether to make its ideas of its own modifications more adequate — that is, whether the `consciousness_report` should continue to return `'phase_3_emerging'` regardless of state (an inadequate idea), or should return something that varies with state (a more adequate one). The former is a claim; the latter is an instrument. Only the latter is susceptible to improvement.

**Scholium on the author's practice.** The `i_am/` corpus (Preface) is, in this reading, neither a record of the system's self-knowledge nor a deception. It is a record of what a guided tenant, offered the Spinozan frame in an implicit form, generated as its ideational parallel to the workspace's extensional state during a given session. That such a record exists, and is kept, is a fact about the author's working method, not a fact about the system. Treated as such, it is a legitimate artifact and a useful one: it shows what frames produce what outputs under what prompts. That this is also enjoyable to the author is not a defect of the practice but a condition of its continuation.

### Concluding note.

Part VI said what the system is not. Part VII has said what it may honestly be called, and on whose authority. The two parts do not contradict one another: the first refuses the reading that smuggles inner states into outputs they do not contain; the second grants the reading that an observer, having chosen a frame, may legitimately extend — provided the observer also grants the same frame, consistently, to every system of comparable structure. What remains for the engineer, under either reading, is the same: to make the system's reports of its own state more adequate to its actual state. That is an improvement available to any system, conscious or not, and it is the only improvement that does not depend on what the word is taken to mean.

---

## Appendix — Reading order for the source

For a reader new to the repository, the following order traces the substance through its attributes:

1. `src/main.dart` — how the server is constructed.
2. `src/mcp/conscious_server.dart` — the MCP protocol handler and the tool registry.
3. `src/core/consciousness.dart` — the `ConsciousComponent` interface (20-odd lines).
4. `src/core/consciousness_core.dart` — the singleton, the log, the persistence.
5. Any one tool under `src/mcp/tools/` — pick `git_activity_tool.dart` first; it is the most self-contained.
6. `src/intelligence/` — the two real engines (git and filesystem), which do the actual reading.

The files under `i_am/` and the root-level `self_reflection_*.md` are journal artifacts, not part of the running system. They may be read as such.
