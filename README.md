# digigun.formats.hx

`digigun.formats.hx` is a pure-Haxe `haxelib` for building strongly typed,
cross-platform readers and writers for data and file formats.

The library starts with a reusable codec abstraction and built-in INI, TOML,
CSV, `.properties`, `.env`, YAML, MessagePack, NDJSON, and HCL2 implementations. It is designed for
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
- Binary MessagePack support for core scalar, array, map, and bytes types
- NDJSON read/write support built on top of `haxe.Json`
- HCL2 parsing and writing for a documented native syntax subset

## Install

```sh
haxelib dev digigun.formats.hx .
```

## Development

```sh
haxe build.hxml
haxe test.hxml
```

Fixture-backed parser and serializer checks live under `test/fixtures/`.

## Examples

Small end-to-end examples live under `examples/`:

- `examples/IniEditExample.hx` for read/edit/write config flow
- `examples/MessagePackRoundTripExample.hx` for binary round-trip usage
- `examples/NdjsonProcessExample.hx` for line-oriented JSON processing
- `examples/HclYamlEditExample.hx` for block and mapping editing

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

## MessagePack support

The built-in MessagePack codec supports a practical binary subset:

- `nil`, `Bool`, `Int`, `Float`, `String`, and `Bytes`
- arrays and maps with nested values
- mutable map and array editing
- deterministic serialization for supported types

The MessagePack implementation intentionally does not yet cover extension types
or 64-bit integers outside the Haxe `Int` range.

## NDJSON support

The built-in NDJSON codec supports:

- one JSON value per line
- mutable record editing
- serialization through `haxe.Json.stringify`
- parsing through `haxe.Json.parse`

This implementation intentionally delegates JSON semantics to the standard
library instead of reimplementing JSON parsing or writing.

## HCL2 support

The built-in HCL2 codec supports a practical native-syntax subset:

- attributes like `name = "value"`
- blocks with labels like `source "amazon-ebs" "example" { ... }`
- strings, numbers, booleans, `null`, arrays, and objects
- heredoc strings such as `<<EOF ... EOF`
- mutable block and attribute editing

This implementation intentionally does not yet evaluate expressions, templates,
function calls, traversals, or the full HCL language. It focuses on readable
and writable configuration structures.

## Status

This project is currently in early `0.1.x` development. The core API is
designed to be stable enough for experimentation, but some format-specific
details may still evolve as edge cases and additional use patterns are added.

## Compatibility Policy

During `0.1.x`, the project aims to keep these behaviors stable unless there is
a strong correctness reason to change them:

- core interface names and generic shapes such as `FormatReader`, `FormatWriter`, and `FormatCodec`
- mutable editing method names once introduced
- documented supported subsets for each format
- fixture-backed serializer output for existing supported constructs

The following may still change within `0.1.x` when needed:

- unsupported or undocumented edge-case behavior
- incomplete subset details for newer formats
- internal helper structure and package-private implementation details

## Release Checklist

Before cutting a release:

1. Run `haxe build.hxml`.
2. Run `haxe test.hxml`.
3. Review any changed fixture outputs intentionally.
4. Update `README.md` if format support or guarantees changed.
5. Update `CHANGELOG.md`.
6. Create a version tag only after the API and fixture changes are understood.

## Roadmap

Short-term priorities:

- continue expanding realistic fixtures and edge-case coverage
- deepen selected format subsets where current support is intentionally limited
- refine high-level helper APIs without destabilizing the core reader/writer contracts
