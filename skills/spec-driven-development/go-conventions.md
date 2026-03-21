# Go Conventions

> Default values for Go projects when generating IDE rules.
> SDD uses these to fill in the generic template.

## Default Values

| Category | Key | Default Value |
|:---------|:----|:-------------|
| Naming | naming_style | lowercase |
| Naming | naming_style_example | order, payment |
| Naming | ext | go |
| Layer | dir_transport | server/ |
| Layer | dir_application | app/ |
| Layer | dir_domain | domain/ |
| Layer | dir_infra | infra/ |
| Layer | dir_infra_model | infra/model/ |
| Layer | dir_kernel | kernel/ |
| Layer | dir_config | internal/config/ |
| Config | dir_configs | configs/ |
| Config | config_ext | yaml |
| Error | error_style | sentinel |
| Error | error_style_example | var ErrNotFound = errors.New(...) |
| Error | error_wrapping | once |
| Testing | test_framework | Go standard library (testing package) |
| Testing | test_naming_pattern | TestFunctionName or TestType_Method |
| Testing | mock_style | interface |
| Testing | dir_tests | tests/ |

## Hard Constraints

These CANNOT be modified. See [_shared/domain-architecture-reference.md](../../_shared/domain-architecture-reference.md).

## Go Project Structure

For complete Go DDD project structure, see [full-ddd skill](../full-ddd/SKILL.md).
