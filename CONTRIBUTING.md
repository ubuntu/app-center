# Contributing

## Code of Conduct

This project is subject to the [Ubuntu Code of Conduct](https://ubuntu.com/community/code-of-conduct) to foster an open and welcoming place to contribute.
By participating in the project (in the form of code contributions, issues, comments, and other activities), you agree to abide by its terms.

## Bugs

Bugs are tracked as [GitHub issues](https://github.com/ubuntu-flutter-community/software/issues?q=is%3Aissue+label%3Abug).

## Pull requests

Changes to this project should be proposed as [pull requests on GitHub](https://github.com/ubuntu-flutter-community/software/pulls).
Make sure that the pull request is [linked to an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue). If there isn't an issue yet to track the bug or improvement you are working on, consider filing one.

## Contributor License Agreement

This project is subject to the [Canonical contributor license agreement](https://ubuntu.com/legal/contributors), please make sure you have [signed it](https://ubuntu.com/legal/contributors/agreement) before (or shortly after) submitting your first pull request.

## Translations

Translations are managed using [Weblate](https://hosted.weblate.org/projects/ubuntu-software/).
This project currently has one translation component:

- [ubuntu-software](https://hosted.weblate.org/projects/ubuntu-software/ubuntu-software/)

[![Translation status](https://hosted.weblate.org/widgets/ubuntu-software/-/287x66-white.png)](https://hosted.weblate.org/engage/ubuntu-software/)

**NOTE**: The Weblate project is integrated with the GitHub project. Weblate pushes changes daily and
opens a [pull request](https://github.com/ubuntu-flutter-community/software/pulls) on GitHub.


## Tests

Mock tests need to be re-generated when the signature of used methods changes.
Re-generate with

```
flutter pub run build_runner build --delete-conflicting-outputs
```