These templates provided components that can be used to build a complete build pipeline using Screwdriver CD and Python.

The following example screwdriver.yaml will run all of the supported validations against the code in the package,
generate a version, package and publish the package to test.pypi.org, install the package published to test.pypi.org and
test it, then publish the package to pypi.org.  

This configuration should work out of the box for most Python applications:

```yaml
version: 4
shared:
    environment:
        PACKAGE_DIRECTORY: src/screwdrivercd

jobs:
    validate_test:
        template: python/validate_unittest
        requires: [~commit, ~pr]

    validate_lint:
        template: python/validate_lint
        requires: [~commit, ~pr]

    validate_codestyle:
        template: python/validate_codestyle
        requires: [~commit, ~pr]

    validate_dependencies:
        template: python/validate_dependencies
        requires: [~commit, ~pr]

    validate_security:
        template: python/validate_security
        requires: [~commit, ~pr]

    validate_documentation:
        template: python/documentation
        environment:
          DOCUMENTATION_PUBLISH: False
        requires: [~pr]
    
    generate_version:
        template: python/generate_version
        requires: [~commit]

    publish_test_pypi:
        template: python/package_python
        environment:
            PACKAGE_TAG: False
            PUBLISH: True
            TWINE_REPOSITORY_URL: https://test.pypi.org/legacy/
        requires: [generate_version, validate_test, validate_lint, validate_codestyle, validate_dependencies, validate_security]

    verify_test_package:
        template: python/validate_pypi_package
        environment:
            PYPI_INDEX_URL: https://test.pypi.org/simple
        requires: [publish_test_pypi]

    publish_pypi:
        template: python/package_python
        environment:
            PUBLISH: True
        requires: [verify_test_package]
 ```
