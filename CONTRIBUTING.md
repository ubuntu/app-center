# Contributing to App Center

A big welcome and thank you for considering contributing to App Center and Ubuntu! It’s people like you that make it a reality for users in our community.

Reading and following these guidelines will help us make the contribution process easy and effective for everyone involved. It also communicates that you agree to respect the time of the developers managing and developing this project. In return, we will reciprocate that respect by addressing your issue, assessing changes, and helping you finalize your pull requests.

These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

## Quicklinks

- [Contributing to App Center](#contributing-to-app-center)
  - [Quicklinks](#quicklinks)
  - [Code of Conduct](#code-of-conduct)
  - [Getting Started](#getting-started)
    - [Issues](#issues)
    - [Pull Requests](#pull-requests)
  - [Translations](#translations)
  - [Contributing to the code](#contributing-to-the-code)
    - [Required dependencies](#required-dependencies)
    - [Building and running the binaries](#building-and-running-the-binaries)
    - [About the testsuite](#about-the-testsuite)
  - [Contributor License Agreement](#contributor-license-agreement)
  - [Getting Help](#getting-help)

## Code of Conduct

We take our community seriously and hold ourselves and other contributors to high standards of communication. By participating and contributing to this project, you agree to uphold our [Code of Conduct](https://ubuntu.com/community/code-of-conduct).

## Getting Started

Contributions are made to this project via Issues and Pull Requests (PRs). A few general guidelines that cover both:

* Search for existing Issues and PRs on this repository before creating your own.
* We work hard to makes sure issues are handled in a timely manner but, depending on the impact, it could take a while to investigate the root cause. A friendly ping in the comment thread to the submitter or a contributor can help draw attention if your issue is blocking.
* If you've never contributed before, see [this Ubuntu discourse post](https://discourse.ubuntu.com/t/contribute/26) for resources and tips on how to get started.

### Issues

Issues should be used to report problems with the software, request a new feature, or to discuss potential changes before a PR is created.

If you find an Issue that addresses the problem you're having, please add your own reproduction information to the existing issue rather than creating a new one. Adding a [reaction](https://github.blog/2016-03-10-add-reactions-to-pull-requests-issues-and-comments/) can also help be indicating to our maintainers that a particular problem is affecting more than just the reporter.

### Pull Requests

PRs to our project are always welcome and can be a quick way to get your fix or improvement slated for the next release. In general, PRs should:

* Only fix/add the functionality in question **OR** address wide-spread whitespace/style issues, not both.
* Add unit or integration tests for fixed or changed functionality.
* Address a single concern in the least number of changed lines as possible.

For changes that address core functionality or would require breaking changes (e.g. a major release), it's best to open an Issue to discuss your proposal first. This is not required but can save time creating and reviewing changes.

In general, we follow the ["fork-and-pull" Git workflow](https://github.com/susam/gitpr)

1. Fork the repository to your own GitHub account
2. Clone the project to your machine
3. Create a branch locally with a succinct but descriptive name
4. Commit changes to the branch
5. Following any formatting and testing guidelines specific to this repo
6. Push changes to your fork
7. Open a PR in our repository and follow the PR template so that we can efficiently review the changes.

PRs will trigger unit and integration tests with and without race detection, linting and formatting validations, static and security checks, freshness of generated files verification. All the tests must pass before merging in main branch.

## Translations

Translations are managed using [Weblate](https://hosted.weblate.org/projects/ubuntu-software/app-center/)

## Contributing to the code

### Required dependencies

[Install Flutter](https://flutter.dev/docs/get-started/install/linux) - the currently used version is specified in `.tool-versions`. If you're using [asdf](https://asdf-vm.com/) to manage your Flutter SDK, you can simply run `asdf install` to install the required version.

Even though this repo currently consists of only a single package we provide a [Melos](https://docs.page/invertase/melos) configuration to make it straightforward to execute common tasks.

Install Melos:
```
dart pub global activate melos
```

### Building and running the binaries

You can run the application with
```
flutter run
```

and build a release version with
```
melos build
```

### About the testsuite

The project includes a comprehensive test suite. All the tests must pass before the review is considered. If you have troubles with the testsuite, feel free to mention it on your PR description.

The test suite uses the [mockito](https://pub.dev/packages/mockito) framework to generate mocks. If you modify existing tests or add new ones, you might need to regenerate the mocks by running
```
melos generate
```

You can run the tests with
```
melos test
```

The test suite must pass before merging the PR to our main branch. Any new feature, change or fix must be covered by corresponding tests.

## Contributor License Agreement

It is required to sign the [Contributor License Agreement](https://ubuntu.com/legal/contributors) in order to contribute to this project.

An automated test is executed on PRs to check if it has been accepted.

This project is covered by the [GPL-3.0](LICENSE) license.

## Getting Help

Join us in the [Ubuntu Community](https://discourse.ubuntu.com/c/desktop/8) and post your question there with a descriptive tag.
