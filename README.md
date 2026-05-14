# digigun.formats.hx

`digigun.formats.hx` is a pure-Haxe `haxelib` for building strongly typed,
cross-platform readers and writers for data and file formats.

The library currently focuses on a reusable codec abstraction and built-in INI,
EditorConfig, TOML, CSV, `.properties`, `.env`, YAML, MessagePack, NDJSON, and
HCL2 implementations. It is designed for direct class usage rather than a
global registry, keeping extension points simple and type-safe.

Text formats live under `digigun.formats.text.<format>`.

## Features

- Pure Haxe, stdlib-only implementation
- Intended to compile across Haxe targets
- Strongly typed core interfaces
- Structured parse/write errors
- Deterministic INI serialization
- Deterministic EditorConfig serialization on top of the INI document model
- Deterministic TOML serialization for a typed subset
- CSV row and cell parsing with deterministic serialization
- Editable `.properties` and `.env` documents
- Writable YAML mappings and sequences for a supported subset
- Binary MessagePack support for core scalar, array, map, and bytes types
- NDJSON read/write support built on top of `haxe.Json`
- HCL2 parsing and writing for a documented native syntax subset
- Image and texture support focused on GPU-ready containers and small
  uncompressed baselines

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
- `examples/ImageTextureRoundTripExample.hx` for a minimal texture round-trip
  and compression-planning example

## Basic usage

```haxe
import digigun.formats.FormatResult;
import digigun.formats.text.ini.IniDocument;
import digigun.formats.text.ini.IniReader;
import digigun.formats.text.ini.IniWriter;

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
var iniEnabled = new digigun.formats.text.ini.IniProperty("enabled", true);
var tomlPorts = new digigun.formats.text.toml.TomlProperty("ports", [80, 443]);
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
every variant in the wild. Writer output uses quoting when a string would
otherwise round-trip back as a boolean or numeric scalar.

Deferred: only concrete INI dialect features that appear in real fixtures and
still fit the current typed document model.

Out of scope for now: trying to normalize every historical INI dialect.

## EditorConfig support

The built-in EditorConfig codec is a thin specialization over the INI document
model and supports:

- `root = true` preamble handling
- `key = value` entries with lowercase keys
- `[`glob`]` section headers with escaped literal glob delimiters
- `#` and `;` comments
- escaped `#`, `;`, `=`, `:`, and `\` in keys, values, and section globs
- deterministic serialization of the typed document model

The EditorConfig implementation intentionally stays on the same practical subset
as the rest of the library and does not attempt to model every historical editor
variant.

Deferred: only clearly useful EditorConfig edge cases that still fit the thin
INI-specialization model.

Out of scope for now: broad compatibility work for every historical editor
variant.

## TOML support

The built-in TOML codec supports a practical typed subset:

- comments starting with `#`
- top-level key/value pairs with bare, quoted, or dotted keys
- named tables like `[server]`, including quoted and dotted table names
- scalar values inferred as `String`, `Int`, `Float`, or `Bool`
- arrays with nested scalar and array values
- inline tables such as `{ owner = "digigun", active = true }` with bare,
  quoted, or dotted keys
- deterministic serialization of the typed document model

The TOML implementation now covers the practical key-path features that show up
frequently in real configuration files, including quoted and dotted keys. The
current document model still intentionally leaves `array-of-tables`, date/time
values, and multiline strings for later work. Dotted keys are preserved as
canonical TOML key paths; they are not automatically expanded into nested table
objects inside the current document API. Malformed nested array and inline-table
delimiters are rejected instead of being recovered from implicitly.

Deferred: `array-of-tables`, date/time values, and multiline strings.

Out of scope for now: fully dynamic TOML model reshaping beyond the current
editable document API.

## CSV support

The built-in CSV codec supports:

- configurable delimiter
- quoted cells with escaped quotes
- mutable row and cell editing
- deterministic serialization

The CSV implementation intentionally uses a strict quoting subset: quotes must
start at the beginning of a cell, and no extra characters are accepted after a
closing quote before the delimiter or line ending.

Deferred: only compatibility relaxations that improve real-world CSV fixtures
without making serializer behavior ambiguous.

Out of scope for now: dialect auto-detection or permissive recovery from
malformed quoted cells.

## `.properties` support

The built-in `.properties` codec supports:

- `key=value` and `key:value` entries
- `#` and `!` comments
- mutable property editing
- deterministic serialization

This implementation treats escaped `=` and `:` as literal key/value content and
escapes them again during writing so delimiter-bearing keys and values
round-trip correctly.

Deferred: only additional escaping or continuation behaviors that are common
enough to justify a stable contract.

Out of scope for now: trying to absorb every `.properties` dialect variant.

## `.env` support

The built-in `.env` codec supports:

- `KEY=value` entries
- optional `export KEY=value` syntax
- quoted and unquoted values
- mutable variable editing
- deterministic serialization

This implementation currently treats `#` as a comment only when it starts a
line. Inside unquoted values it is preserved literally, and the writer emits one
entry per line without a trailing newline.

Deferred: inline-comment handling or other shell-adjacent cases if they can be
specified narrowly and tested clearly.

Out of scope for now: turning `.env` into a shell parser.

## YAML support

The built-in YAML codec supports a practical block-style subset:

- mappings with scalar or nested values
- sequences with scalar or nested values
- flow-style arrays such as `[alpha, "beta:2", null]`
- flow-style objects such as `{ owner: digigun, active: true }`
- block scalars using `|` and `>` for multiline string content
- scalar values inferred as `String`, `Int`, `Float`, `Bool`, or `null`
- mutable object and array editing
- deterministic serialization with two-space indentation

The YAML implementation intentionally stays a practical subset. Anchors, tags,
arbitrary flow/block mixing beyond the documented subset, and the full YAML
specification are out of scope for now. Built-in multiline string writing uses
literal block-scalar output (`|`) for deterministic round trips, while malformed
nested flow delimiters are already rejected instead of being recovered from
implicitly.

Deferred: only pragmatic YAML additions such as more block-scalar niceties when
they fit the current deterministic document model.

Out of scope for now: anchors, tags, broad schema semantics, and full-spec YAML
compatibility.

## MessagePack support

The built-in MessagePack codec supports a practical binary subset:

- `nil`, `Bool`, `Int`, `Float`, `String`, and `Bytes`
- arrays and maps with nested values
- mutable map and array editing
- deterministic serialization for supported types

The MessagePack implementation intentionally leaves extension types and 64-bit
integers outside the Haxe `Int` range for later API work. Generic binary maps
may use non-string keys, but the convenience `getProperty`/`setProperty`
helpers are specifically for string-keyed entries.

Deferred: extension types and a deliberate 64-bit value story if the public API
can support them cleanly across Haxe targets.

Out of scope for now: ad hoc target-specific integer handling.

## NDJSON support

The built-in NDJSON codec supports:

- one JSON value per line
- blank lines are ignored during parsing
- mutable record editing
- serialization through `haxe.Json.stringify`
- parsing through `haxe.Json.parse`

This implementation intentionally delegates JSON semantics to the standard
library instead of reimplementing JSON parsing or writing. The writer emits one
record per line without a trailing newline.

Deferred: only line-oriented conveniences that stay within stdlib JSON
semantics.

Out of scope for now: custom JSON parsing behavior separate from `haxe.Json`.

## HCL2 support

The built-in HCL2 codec supports a practical native-syntax subset:

- attributes like `name = "value"`
- blocks with labels like `source "amazon-ebs" "example" { ... }`
- strings, numbers, booleans, `null`, arrays, and objects
- object fields using either `=` or `:`
- heredoc strings such as `<<EOF ... EOF`
- mutable block and attribute editing

This implementation intentionally keeps HCL on the literal-data side. It does
not evaluate expressions, templates, function calls, traversals, or the full
HCL language, and those are better treated as out of scope unless the library
ever grows into a real evaluator. It rejects malformed nested block and object
delimiters.

Deferred: only literal-data syntax improvements that do not require language
evaluation.

Out of scope for now: expression evaluation, templates, traversals, function
calls, and full HCL execution semantics.

## Text format status

The current text-format surface should now be treated as functionally mature for
the `0.3.x` line. Additional text-format work should happen only when there is
a concrete format need or a clear correctness gap, not just to chase broader
spec coverage for its own sake.

## Image support

The image branch focuses on a narrow, pure-Haxe texture subset:

- `DDS`: 2D textures with BC1/BC3/BC4/BC5 payloads, plus practical 24-bit and 32-bit
  uncompressed input/output
- `KTX`: 2D single-face textures with RG8/RGB8/RGBA8 or BC1/BC3/BC4/BC5/ETC2/EAC payloads
- `PVR`: 2D single-surface PVRTC1 4bpp RGBA textures
- `BMP`: uncompressed `BI_RGB` 24-bit and 32-bit input/output
- `TIFF`: uncompressed, contiguous, 8-bit gray/RGB/RGBA input/output
- `TGA`: 8-bit grayscale and 24-bit/32-bit color, with optional simple RLE
- `PPM`/`PGM`: binary `P6`/`P5` input/output
- `RAW`: explicit byte-layout textures for direct buffer exchange

Texture block formats such as BC1, BC3, BC4, BC5, ETC2, EAC, ASTC, and PVRTC are modeled as
payload targets inside the supported containers. Fresh built-in encoding is
currently implemented for BC1/BC3/BC4/BC5 and ETC2/EAC. ASTC and PVRTC remain
useful upload and passthrough targets, but fresh built-in encoding for them is
still deferred. Anything that depends on general-purpose compression libraries,
such as PNG, stays deferred until the separate compression project is ready.
This keeps the image branch cross-target and stdlib-only.

In practical terms:

- `TextureFormatSupport.canUpload(...)` answers whether a GPU/API family can use
  a format.
- `TextureCompressionSupport.hasBuiltInEncoder(...)` answers whether the library
  can freshly encode that compression family today.
- `TextureCompressionSupport.buildPlan(...)` only auto-selects fresh encoding
  paths that are currently realizable, while still allowing passthrough for
  already-compressed ASTC/PVRTC inputs.

### Image subset matrix

| Status | Formats |
| --- | --- |
| Supported | DDS, KTX, PVR, BMP, TIFF, TGA, PPM/PGM, RAW |
| Supported subset | DDS 2D BC1/BC3/BC4/BC5 and uncompressed 24/32-bit, KTX 2D single-face RG8/RGB8/RGBA8/BC1/BC3/BC4/BC5/ETC2/EAC, PVR 2D single-surface PVRTC1, BMP `BI_RGB`, TIFF uncompressed contiguous 8-bit gray/RGB/RGBA, TGA 8/24/32-bit with optional RLE, PPM/PGM binary `P6`/`P5`, RAW explicit layout |
| Deferred inside supported families | Fresh ASTC and PVRTC block encoding, PNG and any format that depends on general-purpose compression libraries |
| Unsupported | TIFF compression, BMP compression, KTX arrays/cubemaps/3D, PVR multi-surface, TGA color-mapped input |

## Status

This project is currently in early `0.3.x` development. The `0.3.0` release
captures the stabilized text-format surface, the EditorConfig specialization,
the text namespace move, and the current image/texture subset including BC4/BC5,
RG8, and the ETC2/EAC family while keeping format-specific subsets explicit.

## Compatibility Policy

During `0.3.x`, the project aims to keep these behaviors stable unless there is
a strong correctness reason to change them:

- core interface names and generic shapes such as `FormatReader`,
  `FormatWriter`, and `FormatCodec`
- mutable editing method names once introduced
- documented supported subsets for each format
- fixture-backed serializer output for existing supported constructs

The following may still change within `0.3.x` when needed:

- unsupported or undocumented edge-case behavior
- incomplete subset details for specific formats
- internal helper structure and package-private implementation details

## Release Checklist

Before cutting a release:

1. Run `haxe build.hxml`.
2. Run `haxe test.hxml`.
3. Review any changed fixture outputs intentionally.
4. Update `README.md`, `CHANGELOG.md`, and `haxelib.json` if format support or
   guarantees changed.
5. Update the local project memory (`project.axl` or equivalent local-only
   notes) so future sessions can resume with the current assessment and
   decisions.
6. Bump the package version only after the API and fixture changes are
   understood.

## Roadmap

Short-term priorities:

- continue expanding realistic fixtures and edge-case coverage for text formats
- deepen selected text-format subsets where support is intentionally limited
- refine high-level helper APIs without destabilizing the core reader/writer
  contracts
