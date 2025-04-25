# aws-cm

My approach to configuration management (cm) for my AWS infrastructure.

## Initialization

1. Create an AWS account.
2. Setup MFA for the `root` account user.
3. Create a `root` account user access key.
4. Setup `aws-cli` client with the `root` account user access key.
5. Run the `bootstrap.py` script.

   - Record the `admin` account user password created.
   - Record the `opentofu` account user access key created.

6. Delete the root account user access key.
7. Setup MFA for the `admin` account user.

- These changes can be undone by running `bootstrap.py --undo`. It is presumed
  at this point that the `aws-cli` client will be configured with another `root`
  account user access key.

## License

See LICENSE.
