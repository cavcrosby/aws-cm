#!/usr/bin/env python3
"""Bootstraps my main AWS account to be managed by OpenTofu."""

from __future__ import annotations

import argparse
import hashlib
import logging
import os
import secrets
import string
import sys
from typing import TYPE_CHECKING

import boto3
import botocore

if TYPE_CHECKING:
    from mypy_boto3_iam.service_resource import LoginProfile, User
    from mypy_boto3_s3.service_resource import Bucket

logger = logging.getLogger(__name__)


def main(args: argparse.Namespace) -> None:
    """Start the main program execution."""
    logging.basicConfig(level=os.getenv("LOGLEVEL", logging.INFO))
    opentofu_user: User = boto3.resource("iam").User("opentofu")
    admin_user: User = boto3.resource("iam").User("admin")
    login_profile: LoginProfile = admin_user.LoginProfile()
    ADMIN_ACCESS_POLICY_ARN = "arn:aws:iam::aws:policy/AdministratorAccess"
    bucket: Bucket = boto3.resource("s3").Bucket(
        f"{hashlib.sha256(b'cavcrosby').hexdigest()[:12]}-aws-cm"
    )

    if args.undo:
        bucket.object_versions.delete()
        bucket.delete()

        [access_key.delete() for access_key in admin_user.access_keys.all()]  # type: ignore[func-returns-value] # list expr used solely for inline iteration
        admin_user.detach_policy(PolicyArn=ADMIN_ACCESS_POLICY_ARN)
        login_profile.delete()
        admin_user.delete()

        [access_key.delete() for access_key in opentofu_user.access_keys.all()]  # type: ignore[func-returns-value] # list expr used solely for inline iteration
        opentofu_user.detach_policy(PolicyArn=ADMIN_ACCESS_POLICY_ARN)
        opentofu_user.delete()
    else:
        try:
            if "root" not in boto3.client("sts").get_caller_identity()["Arn"]:
                logger.error(
                    "aws-cli is not configured with a root account user access key"
                )
                sys.exit(1)
        except botocore.exceptions.ClientError:
            logger.error(
                "aws-cli is not configured with a root account user access key"
            )
            sys.exit(1)

        boto3.client("account").put_account_name(AccountName="main")

        opentofu_user.create()
        opentofu_user.attach_policy(PolicyArn=ADMIN_ACCESS_POLICY_ARN)
        access_key = opentofu_user.create_access_key_pair()
        logger.info(f"{opentofu_user.user_name} access key: {access_key.id}")
        logger.info(f"{opentofu_user.user_name} secret key: {access_key.secret}")

        password = "".join(
            secrets.choice(
                string.ascii_letters + string.digits + "!@#$%^&*()_+-=[]{}|'"
            )
            for _ in range(32)
        )

        admin_user.create()
        login_profile.create(Password=password)
        admin_user.attach_policy(PolicyArn=ADMIN_ACCESS_POLICY_ARN)
        logger.info(f"{admin_user.user_name} password: {password}")

        bucket.create()
        bucket.Versioning().enable()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description=__doc__,
        allow_abbrev=False,
    )
    parser.add_argument(
        "-u",
        "--undo",
        action="store_true",
        help="undoes changes made",
    )

    main(parser.parse_args())
    sys.exit(0)
