# Go Conventions

> Default values for Go projects when generating coding-spec.md.
> SDD uses these to fill in the generic template.

## Default Values

| Category | Key | Default Value |
|:---------|:----|:-------------|
| Naming | style | lowercase |
| Naming | aggregate_file | {context}.go |
| Naming | value_object_file | {name}.go |
| Naming | test_file | {source}_test.go |
| Layer | transport | server/ |
| Layer | application | app/ |
| Layer | cross_domain | kernel/ |
| Error | style | sentinel |
| Error | wrapping | once |
| Testing | framework | standard |
| Testing | mock_style | interface |

## Hard Constraints

These CANNOT be modified. See [_shared/domain-architecture-reference.md](../../_shared/domain-architecture-reference.md).

## Go Project Structure

For complete Go DDD project structure, see [full-ddd skill](../full-ddd/SKILL.md).
