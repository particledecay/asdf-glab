<div align="center">

# asdf-glab [![Build](https://github.com/particledecay/asdf-glab/actions/workflows/build.yml/badge.svg)](https://github.com/particledecay/asdf-glab/actions/workflows/build.yml) [![Lint](https://github.com/particledecay/asdf-glab/actions/workflows/lint.yml/badge.svg)](https://github.com/particledecay/asdf-glab/actions/workflows/lint.yml)


[glab](https://github.com/particledecay/asdf-glab) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`: generic POSIX utilities.
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add glab
# or
asdf plugin add glab https://github.com/particledecay/asdf-glab.git
```

glab:

```shell
# Show all installable versions
asdf list-all glab

# Install specific version
asdf install glab latest

# Set a version globally (on your ~/.tool-versions file)
asdf global glab latest

# Now glab commands are available
glab version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/particledecay/asdf-glab/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Joey Espinosa](https://github.com/particledecay/)
