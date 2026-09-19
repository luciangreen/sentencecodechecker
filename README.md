# sentencecodechecker

Symbolic sentence/code reasoner in SWI-Prolog.

## Run tests

```bash
swipl -q -s /home/runner/work/sentencecodechecker/sentencecodechecker/tests/run_tests.pl
```

## CLI examples

```bash
swipl -s /home/runner/work/sentencecodechecker/sentencecodechecker/src/main.pl -- check "append joins two lists."
swipl -s /home/runner/work/sentencecodechecker/sentencecodechecker/src/main.pl -- connect "a" "b"
swipl -s /home/runner/work/sentencecodechecker/sentencecodechecker/src/main.pl -- explain /home/runner/work/sentencecodechecker/sentencecodechecker/examples/member_example.pl "member recursively searches a list."
```
