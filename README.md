# digigun.formats.hx

`digigun.formats.hx` is a pure-Haxe `haxelib` for building strongly typed,
cross-platform readers and writers for data and file formats.

The library starts with a reusable codec abstraction and built-in INI, TOML,
CSV, `.properties`, `.env`, and YAML implementations. It is designed for
direct class usage rather than a global registry, keeping extension points
simple and type-safe.

## Features

- Pure Haxe, stdlib-only implementation
- Intended to compile across Haxe targets
- Strongly typed core interfaces
- Structured parse/write errors
- Deterministic INI serialization
- Deterministic TOML serialization for a typed subset
- CSV row and cell parsing with deterministic serialization
- Editable `.properties` and `.env` documents
- Writable YAML mappings and sequences for a supported subset

## Install

```sh
haxelib dev digigun.formats.hx .
```

## Development

```sh
haxe build.hxml
haxe test.hxml
```

## Basic usage

```haxe
import digigun.formats.FormatResult;
import digigun.formats.ini.IniDocument;
import digigun.formats.ini.IniReader;
import digigun.formats.ini.IniWriter;

class Example {
  static function main() {
    var reader = new IniReader();
    var result = reader.read("[app]\nname = digigun\nenabled = true");

    switch (result) {
      case Success(document):
        var writer = new IniWriter();
        trace(writer.write(document));
      case Failure(error):
        trace(error.toString());
    }
  }
}
```

Format values also support implicit conversion from regular Haxe literals, so
you can write code like:

```haxe
var iniEnabled = new digigun.formats.ini.IniProperty("enabled", true);
var tomlPorts = new digigun.formats.toml.TomlProperty("ports", [80, 443]);
```

## Extending with your own format

```haxe
import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

class PlainTextCodec implements FormatCodec<String, String, String> {
  public function new() {}

  public function read(input:String):FormatResult<String> {
    return Success(input);
  }

  public function write(value:String):FormatResult<String> {
    return Success(value);
  }
}
```

## INI support

The built-in INI codec supports:

- comments starting with `;` or `#`
- global properties before sections
- section headers like `[section]`
- scalar values inferred as `String`, `Int`, `Float`, or `Bool`
- deterministic serialization of the typed document model

The INI implementation intentionally targets a well-defined subset rather than
every variant in the wild.

## TOML support

The built-in TOML codec supports a practical typed subset:

- comments starting with `#`
- top-level key/value pairs
- named tables like `[server]`
- scalar values inferred as `String`, `Int`, `Float`, or `Bool`
- arrays with nested scalar and array values
- deterministic serialization of the typed document model

The TOML implementation intentionally does not yet cover every TOML feature,
such as inline tables, array-of-tables, dates, and multiline strings.

## CSV support

The built-in CSV codec supports:

- configurable delimiter
- quoted cells with escaped quotes
- mutable row and cell editing
- deterministic serialization

## `.properties` support

The built-in `.properties` codec supports:

- `key=value` and `key:value` entries
- `#` and `!` comments
- mutable property editing
- deterministic serialization

## `.env` support

The built-in `.env` codec supports:

- `KEY=value` entries
- optional `export KEY=value` syntax
- quoted and unquoted values
- mutable variable editing
- deterministic serialization

## YAML support

The built-in YAML codec supports a practical block-style subset:

- mappings with scalar or nested values
- sequences with scalar or nested values
- scalar values inferred as `String`, `Int`, `Float`, `Bool`, or `null`
- mutable object and array editing
- deterministic serialization with two-space indentation

The YAML implementation intentionally does not yet cover anchors, tags, flow
collections, multiline strings, or the full YAML specification.

## Status

This project is currently in early `0.1.x` development. The core API is
designed to be stable enough for experimentation, but some format-specific
details may still evolve as edge cases and additional use patterns are added.
