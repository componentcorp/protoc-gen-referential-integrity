# protoc-gen-referential-integrity (PGRI)

*This project is currently in **inception**. Feature suggestions are welcome as issues.*

PGRI is a protoc plugin to generate **R**eferential **I**ntegrity validations for your code. Protocol Buffers hierarchical data structure works well with strictly hierarchical data, but some data formats are non-hierarchical.  In these cases messages in one part of a tree may wish to implement references to data in a different branch of the tree.  Such data can be structured in a manner similar to SQL tables with messages having unique keys and referants using a foreign key to reference keyed messages.

PGRI provide a plugin to check references to make sure they are valid, including uniqueness checks for keys and reference matches for foreign keys.  In addition to supporting internal consistency, it enables checks of external references where data may reside in sources external to a particular message.

Developers import the PGRI extension and annotate the messages and fields in their proto files with constraint rules:

```protobuf
syntax = "proto3";

package examplepb;

import "ri/refcheck.proto";
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

## Concepts

PGRI is based around the concept of keys in SQL which provide uniqueness constraints between different records (of the same type) and referential integrity constrainsts where records refer to other records, ensuring that the reference is valid.  This concept discussion presupposes a good understanding of those concepts.  PGRI applies these concepts to messages where messages are analagous with records in SQL. The typical use case will see PGRI being used to validate an entire File or Stream for internal consistency, but PGRI can be extended to deal with references to external sources.

Because protobuf messages are _not_ SQL databases or tables, there are some differences and extensions.

### Key scope

Keys can be declared in various places in a message.  Unlike in SQL, key definition and declaration is separated in PGRI.  In SQL, both happen at the table (or in protobuf terms, the message).  In PGRI, the location keys are declared determines the keys **scope**.  The most common requirement will be for keys to be global in scope, in which case a key should be declared at the file level for a particular `.proto` file.  For example:

```protobuf
option blah blah blah
```

Sometimes, though, messages aren't uniquely identified across the entire message.  Some message types may be unique within a parent message type, but not globally unique.  In this case, the key should be declared as belonging to the parent message or field.  Such keys have either message or field scope, and provide uniqueness and reference checking within the scope of that message or field.

### Distributed keys

In most cases, keys will be defined by indicating one or more fields in a single message type as being members of a pre-declared key, as follows:

```protobuf
option blah blah blah
```

But because protobuf is a hierarchical structure, the hierarchy can be used to provide distributed keys.  In this way a key instance does not require data to be duplicated where it is found further up the hierarchy.  Foreign keys understand the hierarchy and can navigate to the required message for referential checking too.  An example:

```protobuf
option blah blah blah
```

Some rules follow from this design:

* key elements must be ordered from the highest field (in the message hierarchy) to the lowest.  Whilst not strictly necessary, this simplifies implementation and not having this rule provides no great advantage.
* the key definition will be "attached" to the message containing the last field in the key ordering.

### External References

Some protobuf formats are used to deliver data in slices or tiles or some other division.  In these cases, a particular foreign key may refer to external data.  PGRI is designed to support this case, either via ignoring such references, or by using a pluggable external reference checking mechanism.  The external reference mechanism is language agnostic, so in theory it could be used to check the validity of URLs embedded in protobuf data.

### Partial keys

In the case or tiled or sliced data, some foreign keys may be designed to be "optionally external".  A particular optional field may be supplied to turn the foreign key into an external reference.  When the optional field(s) are not supplied, the key is said to be partial, and implies a reference to the current top level message.

### Self referential message types and keys

In certain circumstances a message type may be defined to refer to itself.  This can pose problems if a key is declared within the message type as it is unclear where the key sits.

```
TBD
```


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

TBD

### Credits

Many of the concepts and some of the code in PGVI were sourced from [protoc-gen-validate](https://github.com/envoyproxy/protoc-gen-validate) as templates or starting points.
