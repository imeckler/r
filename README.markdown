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

    ```bash
    # Choose a rotation of note-takers for meetings
    $ r permute Helga Muhammad Etta Dudley Chun
    Chun Helga Dudley Etta Muhammad
    ```

- `should i TEXT`: This command outputs a random decision for you.

    ```bash
    $ r should i eat a sandwich
    No, you shouldn't eat a sandwich.
    ```

- `alpha [QUANTITY]`: Generate random alphabetic characters, `QUANTITY` many.

    ```bash
    $ r alpha 10
    edhytsqctl
    ```

- `bit [QUANTITY]`: Generate random bits, `QUANTITY` many.

    ```bash
    $ r bit 8
    00100001
    ```

- `digit [QUANTITY]`: Generate random digits, `QUANTITY` many.

    ```bash
    $ r digit 9
    147132722
    ```

- `direction [QUANTITY]`: Generate random directions (right or left), `QUANTITY` many.

    ```bash
    $ r direction 5
    left right right left right
    ```

- `geo [QUANTITY]`: Generate random directions (right or left), `QUANTITY` many.

    ```bash
    $ r geo
    37.705078° S 105.292969° E
    ```

- `yesno [QUANTITY]`: Generate random "yes" or "no", `QUANTITY` many.

    ```bash
    $ r yesno 3
    yes yes yes
    ```

- `all [QUANTITY]`: Generate `QUANTITY` many of of each of the above, all with the same seed.

    ```bash
    $ r all
    yesno: no
    direction: right
    digit: 5
    bit: 0
    geo: 76.728516° N 77.519531° W
    alpha: l
    ```

`QUANTITY` is 1 by default in all commands.

All of the above commands take a flag `-seed SEED` to let you seed the randomness
when generating data.
