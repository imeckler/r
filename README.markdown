# r

This is a program for easily making decisions randomly.

To build it run

```bash
make all
```

## Dependencies
This requires [opam](https://opam.ocaml.org/) and [dune](https://github.com/ocaml/dune).

## Commands

- `setup-tab-completion`: Run this command to easily set up tab-completion for `r`.

- `permute ITEM...`: This command outputs a random permutation of its arguments.
- `should i TEXT`: This command outputs a random decision for you.

- `alpha [QUANTITY]`: Generate random alphabetic characters, `QUANTITY` many.
- `bit [QUANTITY]`: Generate random bits, `QUANTITY` many.
- `digit [QUANTITY]`: Generate random digits, `QUANTITY` many.
- `direction [QUANTITY]`: Generate random directions (right or left), `QUANTITY` many.
- `geo [QUANTITY]`: Generate random directions (right or left), `QUANTITY` many.
- `yesno [QUANTITY]`: Generate random "yes" or "no", `QUANTITY` many.
- `all [QUANTITY]`: Generate `QUANTITY` many of of each of the above, all with the same seed.

`QUANTITY` is 1 by default in all commands.

All of the above commands take a flag `-seed SEED` to let you seed the randomness
when generating data.
