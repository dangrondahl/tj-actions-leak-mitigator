# GitHub Actions Secret Exposure Detector

## Overview

This script automates the detection of potential secret leaks in GitHub Actions logs caused by the recent compromise of the `tj-actions/changed-files` GitHub Action. It helps security teams and developers identify affected workflow runs, count occurrences of potential leaks, and attempt to decode exposed secrets.

## Features

- Scans workflow runs for a specific GitHub repository and workflow name within a given date range.
- Checks for potential secret exposure in logs.
- Attempts to decode leaked secrets if found.
- Provides a simple command-line interface for easy execution.

## Prerequisites

Ensure you have the following installed:

- [GitHub CLI (`gh`)](https://cli.github.com/)
- `awk` and `base64` (available in most UNIX-based systems)

## Installation

Clone the repository and make the script executable:

```sh
$ git clone https://github.com/dangrondahl/tj-actions-leak-mitigator.git
$ cd github-actions-secret-detector
$ chmod +x check_secrets.sh
```

## Usage

Run the script with the following parameters:

```sh
$ ./check_secrets.sh <workflow_name> <repo> <date_range>
```

### Parameters:

- `<workflow_name>` – The name of the workflow YAML file (e.g., `ci.yml`).
- `<repo>` – The full repository name in `owner/repo` format.
- `<date_range>` – The date range for the scan (e.g., `2025-03-14..2025-03-15`).

### Example:

```bash
./check_secrets.sh "ci.yml" "owner/repo" "2025-03-14..2025-03-15"
Listing workflow runs for 'ci.yml' in repository 'owner/repo' from '2025-03-14..2025-03-15'...
Checking runs for potential secret exposure...
✅ Run ID <id> appears safe.
✅ Run ID <id> appears safe.
⚠️  Potential secret exposure detected in run ID: <id>
🔓 Decoded secret: <secret>
⚠️  Potential secret exposure detected in run ID: <id>
🔓 Decoded secret: <secret>
⚠️  Potential secret exposure detected in run ID: <id>
🔓 Decoded secret: <secret>
✅ Run ID <id> appears safe.
...
✅ Run ID <id> appears safe.
Scan complete.
```

## Interpreting Results

- ✅ **Run appears safe**: No secrets detected.
- ⚠️ **Potential secret exposure detected**: A secret may have been exposed in logs.
- 🔓 **Decoded secret**: The script attempts to decode the exposed secret if found.

## Limitations

- The script relies on GitHub CLI (`gh`), so authentication must be set up beforehand.
- The decoding step may fail if the secret is obfuscated or stored differently.
- Designed specifically for detecting the `tj-actions/changed-files` compromise; may not work for other leaks.

## Contributing

Contributions are welcome! Please submit an issue or pull request if you have improvements or additional security checks to suggest.

## License

This project is licensed under the MIT License.

## Acknowledgments

Special thanks to StepSecurity for detecting this issue. See their detailed analysis: [StepSecurity Blog](https://www.stepsecurity.io/blog/harden-runner-detection-tj-actions-changed-files-action-is-compromised).

Thanks to my colleagues @sivarama-p-raju and @ewelinawilkosz for the team work on it as well 🚀
