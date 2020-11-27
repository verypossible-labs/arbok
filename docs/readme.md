# Documentation

- [Concepts](concepts.md)
- [Examples](examples.md)

## Documenting Options

In various module and function docs it is common to document options like so:

> # Options
>
> - `:option1_name` - `type`. # since no default is specified, this option is required
> - `:option2_name` - `type`. Descriptive text. # since no default is specified, this option is required
> - `:option3_name` - `type`. `default`. # since a default is specified, this option is not required
> - `:option4_name` - `type`. `default`. Descriptive text. # since a default is specified, this option is not required
