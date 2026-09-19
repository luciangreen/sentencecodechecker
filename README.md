# sentencecodechecker

Symbolic sentence/code reasoner in SWI-Prolog.

## Run tests

```bash
swipl -q -s tests/run_tests.pl
```

## Command showcase

```bash
swipl -s src/main.pl -- <command> <arguments>
```

The CLI exposes three commands:

- `check` validates a natural-language statement against the built-in ontology.
- `connect` finds the rule connection between two nodes.
- `explain` compares a Prolog source file with a natural-language claim and prints a full explanation.

### `check`

Use `check` when you want to ask whether a sentence is supported by the default rules loaded from `/home/runner/work/sentencecodechecker/sentencecodechecker/ontology/core_rules.pl`, `/home/runner/work/sentencecodechecker/sentencecodechecker/ontology/code_rules.pl`, and `/home/runner/work/sentencecodechecker/sentencecodechecker/ontology/language_rules.pl`.

**Syntax**

```bash
swipl -s src/main.pl -- check "sentence"
```

**Example**

```bash
swipl -s src/main.pl -- check "append joins two lists."
```

**What it prints**

- `correct(...)` when the sentence is supported
- `incorrect(...)` when the sentence conflicts with the loaded knowledge
- `unsupported(...)` when the system cannot prove the statement
- `ambiguous(...)` when the sentence can be interpreted in multiple ways

### `connect`

Use `connect` when you want the proof path between two rule graph nodes.

**Syntax**

```bash
swipl -s src/main.pl -- connect "from" "to"
```

**Example**

```bash
swipl -s src/main.pl -- connect "a" "b"
```

**What it prints**

- A proof term showing how the two nodes are connected

### `explain`

Use `explain` when you want the checker to read a Prolog file, compare its behavior with a sentence, and return a fully worded explanation.

**Syntax**

```bash
swipl -s src/main.pl -- explain path/to/file.pl "sentence"
```

**Example**

```bash
swipl -s src/main.pl -- explain examples/member_example.pl "member recursively searches a list."
```

**What it prints**

- `The statement is supported: ...` when the code matches the sentence
- `The statement is incorrect: ...` when the code contradicts the sentence
- `The statement is unsupported: ...` when evidence is missing
- `The statement is inconsistent. For: ... Against: ...` when both supporting and opposing evidence exist
- `Ambiguous sentence: ...` when the sentence has multiple interpretations

### Complete showcase

```bash
# Validate a natural-language claim against the built-in ontology
swipl -s src/main.pl -- check "append joins two lists."

# Show the connection between two graph nodes
swipl -s src/main.pl -- connect "a" "b"

# Explain whether a Prolog program matches a natural-language description
swipl -s src/main.pl -- explain examples/member_example.pl "member recursively searches a list."
```
