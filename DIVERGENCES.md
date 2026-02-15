# ppx_expect vs ppx_windtrap: Behavioral Divergences

This repository reproduces semantic differences between `ppx_expect` and
`ppx_windtrap` when used as inline expect-test frameworks.

Both test directories (`test/with_ppx_expect/` and `test/with_ppx_windtrap/`)
contain **identical source code** — only the `[%expect]` blocks differ, as a
consequence of the divergences described below.

To inspect the differences side-by-side:

```
diff -ru test/with_ppx_expect test/with_ppx_windtrap
```

Or with a graphical differ:

```
meld test/with_ppx_expect test/with_ppx_windtrap
```

## Setup

A shared library (`src/shared_state/`) exposes:

- `state : string ref` — a simple mutable reference.
- `log : string list ref` — an append log to track execution order.
- `config : int option ref` with `set_config_exn` / `get_config_or_default` —
  a set-once cell with lazy initialization (mirrors `Game_dimensions` in
  [super-master-mind](https://github.com/mbarbin/super-master-mind)).

## Divergence 1: Cross-module state isolation

**ppx_expect** isolates mutable state between test modules. Each `.ml` file
runs with a fresh copy of the process state.

**ppx_windtrap** runs all test modules in the same process. Mutations from one
file are visible to all subsequent files.

This is visible in the ordering tests:

| File | ppx_expect | ppx_windtrap |
| --- | --- | --- |
| `test__a_ordering.ml` | `a` | `b`, `a` |
| `test__b_ordering.ml` | `b` | `b` |

Under ppx_expect, each module starts with an empty log. Under ppx_windtrap,
module `b` runs first and its entry leaks into module `a`.

## Divergence 2: Cross-module execution order

**ppx_expect** runs each module independently, so ordering is irrelevant.

**ppx_windtrap** runs modules in reverse alphabetical order within a test
library:
`test__shared_state` -> `test__d_read_config` -> `test__c_set_config` ->
`test__b_ordering` -> `test__a_ordering`.

Combined with Divergence 1, this causes the set-once pattern to break:

| File | ppx_expect | ppx_windtrap |
| --- | --- | --- |
| `test__c_set_config.ml` | `config set to 42` (success) | `raised: Failure("config already set")` |
| `test__d_read_config.ml` | `config = 0` (lazy default) | `config = 0` (lazy default) |

Under ppx_windtrap, `test__d_read_config` runs **before** `test__c_set_config`
(reverse alphabetical). It calls `get_config_or_default ~default:0`, which
lazy-initializes the config to `0`. When `test__c_set_config` later calls
`set_config_exn 42`, it finds the config already set and raises.

Under ppx_expect, each module runs in isolation, so `set_config_exn` succeeds.

## Divergence 3: Output formatting

**ppx_expect** pads single-line output in corrections: `{| value |}`.

**ppx_windtrap** does not pad: `{|value|}`.

This is a cosmetic difference but causes spurious diffs when migrating between
frameworks.

## Implications

Any test suite that relies on global mutable state and assumes per-module
isolation (as ppx_expect provides) will break under ppx_windtrap. The
`Game_dimensions` pattern in super-master-mind is one such case: other test
files call `Game_dimensions.code_size` (triggering lazy initialization with
production defaults) before `test__game_dimensions.ml` can call
`use_small_game_dimensions_exn`, causing it to crash.
