# Why?

This will generate an Oracle wallet that can be used to connect to an instance with a certificate signed by a real public CA or Amazon RDS.
Oracle doesn't by default provide a wallet with certificates in it, and for ODBC connections it is necessary to provide one by declaring it in the sqlnet.ora file like so:

```
WALLET_LOCATION=
(SOURCE =
    (METHOD=FILE)
    (METHOD_DATA= (DIRECTORY=/some_path/oracle))
)
```

I did this process by hand, initially, using the Mozilla CA bundle and decided to automate it so a new wallet could be generated as certificates change. 
This also will use Amazon's global bundle so that RDS databases will be trusted (documented here: https://aws.amazon.com/premiumsupport/knowledge-center/rds-connect-ssl-connection/)
