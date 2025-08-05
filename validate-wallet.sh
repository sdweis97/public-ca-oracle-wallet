#!/bin/bash

# Oracle Wallet Validation Script
# This script validates that an Oracle wallet contains the expected certificates

set -e

WALLET_DIR="${1:-./public_wallet}"
MIN_CERTS="${2:-100}"

echo "Oracle Wallet Validation"
echo "======================="
echo "Wallet Directory: $WALLET_DIR"
echo "Minimum Expected Certificates: $MIN_CERTS"
echo ""

# Check if wallet directory exists
if [ ! -d "$WALLET_DIR" ]; then
    echo "❌ ERROR: Wallet directory $WALLET_DIR does not exist"
    exit 1
fi

# Check for required wallet files
echo "🔍 Checking wallet files..."
if [ ! -f "$WALLET_DIR/cwallet.sso" ]; then
    echo "❌ ERROR: Auto-login wallet file (cwallet.sso) not found"
    exit 1
else
    echo "✅ Auto-login wallet (cwallet.sso) found"
fi

if [ -f "$WALLET_DIR/ewallet.p12" ]; then
    echo "✅ Password-protected wallet (ewallet.p12) found"
else
    echo "⚠️  WARNING: Password-protected wallet (ewallet.p12) not found"
fi

if [ -f "$WALLET_DIR/wallet-info.txt" ]; then
    echo "✅ Wallet metadata (wallet-info.txt) found"
    echo ""
    echo "📋 Build Information:"
    cat "$WALLET_DIR/wallet-info.txt" | head -10
    echo ""
else
    echo "⚠️  WARNING: Wallet metadata (wallet-info.txt) not found"
fi

# Check wallet contents with orapki (if available)
if command -v orapki >/dev/null 2>&1; then
    echo "🔍 Validating wallet contents..."
    
    # Display wallet info
    wallet_output=$(orapki wallet display -wallet "$WALLET_DIR" 2>/dev/null || echo "Could not display wallet")
    
    if echo "$wallet_output" | grep -q "Trusted Certificate"; then
        cert_count=$(echo "$wallet_output" | grep -c "Trusted Certificate" || echo "0")
        echo "✅ Found $cert_count trusted certificates in wallet"
        
        if [ "$cert_count" -ge "$MIN_CERTS" ]; then
            echo "✅ Certificate count meets minimum requirement ($MIN_CERTS)"
        else
            echo "⚠️  WARNING: Certificate count ($cert_count) below minimum ($MIN_CERTS)"
        fi
        
        # Show sample certificates
        echo ""
        echo "📄 Sample certificates (first 5):"
        echo "$wallet_output" | grep "Trusted Certificate" | head -5 | sed 's/^/  /'
        
    else
        echo "❌ ERROR: No trusted certificates found in wallet"
        echo "Wallet output: $wallet_output"
        exit 1
    fi
else
    echo "⚠️  WARNING: orapki not available - skipping wallet content validation"
    echo "   Install Oracle Instant Client to enable full validation"
fi

# File permissions check
echo ""
echo "🔍 Checking file permissions..."
wallet_perms=$(stat -c "%a" "$WALLET_DIR/cwallet.sso" 2>/dev/null || stat -f "%Lp" "$WALLET_DIR/cwallet.sso" 2>/dev/null || echo "unknown")
if [ "$wallet_perms" != "unknown" ]; then
    echo "✅ Wallet file permissions: $wallet_perms"
    if [ "$wallet_perms" -gt 600 ]; then
        echo "⚠️  WARNING: Wallet file permissions may be too open (consider 600 or 640)"
    fi
else
    echo "⚠️  Could not check file permissions"
fi

echo ""
echo "🎉 Wallet validation complete!"
echo ""
echo "Usage Instructions:"
echo "=================="
echo "1. Copy wallet files to your Oracle configuration directory:"
echo "   cp -r $WALLET_DIR/* /path/to/oracle/config/"
echo ""
echo "2. Update your sqlnet.ora file:"
echo "   WALLET_LOCATION=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=/path/to/oracle/config)))"
echo ""
echo "3. Use TCPS protocol in connection strings:"
echo "   tcps://hostname:port/service_name"
