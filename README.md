# protoc-gen-validate-references (PGRI)

*This project is currently in **inception**. Feature suggestions are welcome as issues.*

PGRI is a protoc plugin to generate **R**eferential **I**ntegrity validations for your code. Protocol Buffers hierarchical data structure works well with strictly hierarchical data, but some data formats are non-hierarchical.  In these cases messages in one part of a tree may wish to implement references to data in a different branch of the tree.  Such data can be structured in a manner similar to SQL tables with messages having unique keys and referants using a foreign key to reference keyed messages.

PGRI provide a plugin to check references to make sure they are valid, including uniqueness checks for keys and reference matches for foreign keys.  In addition to supporting internal consistency, it enables checks of external references where data may reside in a sources external to a particular message.

Developers import the PGRI extension and annotate the messages and fields in their proto files with constraint rules:

```protobuf
syntax = "proto3";

package examplepb;

import "ri/ri_check.proto";
TODO - interesting example
```

## Usage

### Dependencies

- `go` toolchain (≥ v1.7)
- `protoc` compiler in `$PATH`
- `protoc-gen-validate-references` in `$PATH`
- official language-specific plugin for target language(s)

### Installation

TBD

### Parameters

- **`lang`**: specify the target language to generate. Currently, the only supported options are:
  - `go (planned)`
  - `cc (planned)`
  - `java (planned)`
  - `python (planned)`
- Note: Python works via runtime code generation. There's no compile-time generation. See the Python section for details.

### Examples

TBD

## Options and Constraint Rules

[The provided constraints](protobuf/refcheck.proto) are modeled around SQL referential integrity concepts.

Check the [constraint rule comparison matrix](rule_comparison.md) for language-specific constraint capabilities.

### Scope

- **key_anchor**: limits the scope of associated keys to a particular point in the hierarchy. By default, a key is considered global to the complete top level message.  There can be situations where this does not work for a particular data set. This annotation identifies a particular message as an anchor point for nested keys such that key uniqueness is enforced beneath the anchor point, rather than across the entire message.

  ```protobuf
  message Person {
    // create a scope at Person level.  Keys which reference this scope will be checked within this scope
    option (ri_check.key_scope) = "PersonScope";
    uint64 id    = 1 ;

    string email = 2 ;

    string name  = 3 ;

    repeated Location visited = 4 ;

    message Location {
      //define a primary key (pk) anchored at PersonScope.  Locations will be uniquely keyed per person.
      option(ri_check.pk).name = "LOCATION_KEY";
      option(ri_check.pk).scope = "PersonScope";
      uint32 id =1 [(ri_check.pk_element) = 1];
      double lat = 2 ;
      double lng = 3 
      string name=4;
    }
  }
  ```
- **external**: tbd - indicates that a field if set will cause the calculated key to be a fully qualified key, which in turn indicates the possibility that the key could be an external reference. See TBD

### Maps

TBD - I suspect their may be some special handling to get access to gain access to the map key.

## Development

PGRI is written in Go on top of the [protoc-gen-star][pg*] framework and compiles to a standalone binary.

### Roadmap

- [ ] Initial documentation (this file), roadmap, working extension definition
- [ ] Interface definitions and Guidance to language specific implementors
- [ ] Build and CI setup
- [ ] Test harness
- [ ] Tool build
- [ ] Language specific Template builds

### Dependencies

TBD

### Build Targets

TBD

### Run all tests

TBD### Credits

Many of the concepts and some of the code in PGVI were sourced from [protoc-gen-validate](https://github.com/envoyproxy/protoc-gen-validate) as templates or starting points.
