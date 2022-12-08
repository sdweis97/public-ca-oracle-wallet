# Oracle Wallet Generator
This project automates the process of creating an Oracle wallet that can be used to securely connect to an instance using a certificate signed by a public certificate authority (CA) or Amazon RDS.

I did this process by hand, initially, using the Mozilla CA bundle and decided to automate it so a new wallet could be generated as certificates change. 
This also will use Amazon's global bundle so that RDS databases will be trusted (documented here: https://aws.amazon.com/premiumsupport/knowledge-center/rds-connect-ssl-connection/).

## Why do I need this?

Oracle does not include a wallet with certificates by default, and for ODBC connections it is necessary to specify a wallet location in the `sqlnet.ora` file. This project makes it easy to generate a wallet that contains the necessary certificates, including the Mozilla CA bundle and the Amazon global bundle. It uses a GitHub action with Docker and Oracle Database XE to build the wallet file. This ensures that the connection will be trusted by any services that connect to a database with certificates from a public CA, included RDS databases.

## How do I use it?

Simply grab the pre-generated wallet file from the releases page which was built by the GitHub action in this repository or. I recommend that you fork this project and run the GitHub action on your fork and download the artifact file. That way you know what you're getting. It's not that I'm not trustworthy, but please do your due-diligence. Always exercise caution when managing certificates and securing connections to databases. Trusting a bad certificate could open you up to a man-in-the-middle attack.

In your `sqlnet.ora` file, make sure to specify the wallet location as a path to the `cwallet.sso` file, like so:

```
WALLET_LOCATION=
(SOURCE =
    (METHOD=FILE)
    (METHOD_DATA= (DIRECTORY=/some_path/oracle))
)
```
