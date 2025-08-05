# Oracle Wallet Generator with Public CA Certificates

[![Build Wallet](https://github.com/sdweis97/public-ca-oracle-wallet/actions/workflows/build.yml/badge.svg)](https://github.com/sdweis97/public-ca-oracle-wallet/actions/workflows/build.yml)

This project automates the creation of Oracle wallets containing trusted certificates from public Certificate Authorities (CAs), enabling secure SSL/TLS connections to Oracle databases without certificate warnings. Compatible with Oracle 12c and later versions.

## 🎯 Purpose

Oracle clients require a wallet with trusted certificates to establish secure connections. This project generates comprehensive wallets containing:

- **Mozilla CA Bundle**: Standard public certificate authorities
- **Amazon RDS Global Bundle**: For AWS RDS Oracle instances
- **Amazon RDS Regional Bundles**: Region-specific certificates for optimal performance

## ✨ Features

- **Oracle 12c Compatible**: Built and tested with Oracle 12c tooling
- **Automated Certificate Management**: Monthly rebuilds ensure up-to-date certificates
- **Comprehensive Coverage**: Supports connections to most public CA-signed Oracle instances
- **AWS RDS Optimized**: Includes global and regional Amazon certificate bundles
- **Validation & Metadata**: Built-in certificate validation and detailed build information
- **CI/CD Ready**: GitHub Actions workflow with proper error handling

## 🚀 Quick Start

### Option 1: Download Pre-built Wallet (Recommended)

1. Go to the [Actions tab](../../actions/workflows/build.yml)
2. Click on the latest successful build
3. Download the `oracle-public-ca-wallet-*` artifact
4. Extract the wallet files to your Oracle configuration directory

### Option 2: Fork and Build Your Own

1. Fork this repository
2. The GitHub Action will automatically build a fresh wallet
3. Download the artifact from your fork's Actions tab

## 📋 Installation

### Step 1: Extract Wallet Files

```bash
# Extract downloaded artifact
unzip oracle-public-ca-wallet-*.zip

# Copy to your Oracle configuration directory
cp -r public_wallet/* /path/to/oracle/config/
```

### Step 2: Configure sqlnet.ora

Update your `sqlnet.ora` file to reference the wallet:

```ini
# Enable SSL authentication
SQLNET.AUTHENTICATION_SERVICES = (TCPS,NTS)

# Wallet location
WALLET_LOCATION=
(SOURCE =
    (METHOD=FILE)
    (METHOD_DATA=(DIRECTORY=/path/to/oracle/config))
)

# SSL settings
SSL_CLIENT_AUTHENICATION = FALSE
SSL_VERSION = 1.2

# Optional: Connection timeout
SQLNET.EXPIRE_TIME = 10
```

### Step 3: Update Connection Strings

Use `TCPS` protocol for SSL connections:

```bash
# Standard format
host:port:service_name

# SSL format
tcps://host:port/service_name
```

## 🔧 Troubleshooting

### Common Issues

| Error | Cause | Solution |
|-------|--------|----------|
| `TLS Handshake failure` | Wallet not found or invalid | Verify wallet path in `sqlnet.ora` |
| `Certificate not trusted` | Missing CA certificate | Rebuild wallet with latest certificates |
| `Connection timeout` | Wrong protocol or port | Use `TCPS` protocol and SSL port |
| `ORA-28759: failure to open file` | Incorrect wallet path | Check `WALLET_LOCATION` in `sqlnet.ora` |

### Oracle Version Compatibility

- **Oracle 12c**: Fully supported (primary target)
- **Oracle 18c/19c/21c**: Compatible
- **Oracle 11g**: May require older certificate formats

### Validation Commands

```bash
# Check wallet contents (Oracle 12c+)
orapki wallet display -wallet /path/to/wallet

# Test SSL connection
sqlplus user@"(DESCRIPTION=(ADDRESS=(PROTOCOL=TCPS)(HOST=hostname)(PORT=port))(CONNECT_DATA=(SERVICE_NAME=service)))"

# Verify certificate chain
openssl s_client -connect hostname:port -servername hostname
```

## 🏗️ Build Process

The automated build process:

1. **Creates Oracle Wallet**: Uses `orapki` to initialize an auto-login wallet
2. **Downloads Certificates**: Fetches latest CA bundles from Mozilla and Amazon
3. **Validates Bundles**: Ensures certificate integrity before processing
4. **Extracts Certificates**: Splits bundles into individual certificate files
5. **Adds to Wallet**: Imports each certificate as a trusted CA
6. **Validates Wallet**: Verifies wallet integrity and certificate count
7. **Creates Metadata**: Generates build information and usage instructions

## 📁 Wallet Contents

After building, your wallet directory contains:

```text
public_wallet/
├── cwallet.sso          # Auto-login wallet (main file)
├── ewallet.p12          # Password-protected wallet
└── wallet-info.txt      # Build metadata and instructions
```

## 🔐 Security Considerations

- **Verify Sources**: Always validate certificate sources and build logs
- **Regular Updates**: Certificates expire; rebuild monthly via scheduled actions
- **Access Control**: Protect wallet files with appropriate file permissions
- **Network Security**: Use SSL/TLS for all database connections
- **Audit Trail**: Review build metadata for certificate provenance

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/improvement`
3. Test your changes with the GitHub Action
4. Submit a pull request with detailed description

## 📊 Certificate Statistics

The wallet typically contains:

- **150+ Mozilla CA certificates**: Standard public certificate authorities
- **10+ Amazon RDS certificates**: Global and regional AWS certificates
- **Total**: 160+ trusted certificate authorities

## 📚 References

- [Oracle Wallet Management](https://docs.oracle.com/en/database/oracle/oracle-database/19/dbseg/configuring-secure-sockets-layer-authentication.html)
- [Amazon RDS SSL/TLS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html)
- [Mozilla CA Certificate Program](https://wiki.mozilla.org/CA)

## 📄 License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

---

⚠️ **Security Notice**: While this wallet is built from trusted public sources, always exercise caution with certificate management. Review the build process and validate certificates for your security requirements.
