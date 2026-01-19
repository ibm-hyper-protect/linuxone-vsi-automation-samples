## A command-line tool for automating the provisioning and management of IBM Hyper Protect Confidential Computing workloads Examples.

## Supported Platforms
The CLI is available for the following operating systems and architectures:

| OS | Architecture | Binary |
|----|--------------|--------|
| Linux | amd64, arm64, s390x, ppc64le | `contract-cli-linux-*` |
| macOS | amd64, arm64 | `contract-cli-darwin-*` |
| Windows | amd64, arm64 | `contract-cli-windows-*.exe` |

## Preparation

1. Install OpenSSL
Ensure that the OpenSSL binary is installed on your system:
- On Linux: `apt-get install openssl` or `yum install openssl`
- On macOS: `brew install openssl`
- On Windows: [Download OpenSSL](https://slproweb.com/products/Win32OpenSSL.html)

Optional: Custom OpenSSL Path
- If OpenSSL is not in your system `PATH`, set the `OPENSSL_BIN` environment variable:

```
# Linux/macOS
export OPENSSL_BIN=/usr/bin/openssl
```

```
# Windows (PowerShell)
$env:OPENSSL_BIN="C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
```

- Verify OpenSSL Installation

```bash
openssl version
```

Expected output (example):

```text
OpenSSL 1.1.1q  19 Jan 2026
```

2. Download the HPVS CLI tool
Download the CLI binary for your operating system from the [HPVS CLI Tool](https://github.com/ibm-hyper-protect/contract-cli/releases)

3. Verify the CLI Installation

Run the following command:
```bash
./contract-cli-darwin-* version
```

Expected output (example):
```text
contract-cli version v1.0.0 Darwin ARM64 Mon Jan 19 hh:mm:ss UTC 2026
```

## Examples

Each example includes its own README with detailed instructions. See the following:

- [base64](base64/README.md) - Encode input as base64 example