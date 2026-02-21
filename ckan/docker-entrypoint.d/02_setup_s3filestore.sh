#!/bin/bash

# Setup ckanext-s3filestore configuration
# This script runs at CKAN container startup via /docker-entrypoint.d/

if [[ $CKAN__PLUGINS == *"s3filestore"* ]]; then
    echo "Configuring ckanext-s3filestore for MinIO..."

    # Required settings
    ckan config-tool $CKAN_INI \
        "ckanext.s3filestore.aws_bucket_name=${CKANEXT__S3FILESTORE__AWS_BUCKET_NAME:-dataverse}" \
        "ckanext.s3filestore.aws_access_key_id=${CKANEXT__S3FILESTORE__AWS_ACCESS_KEY_ID}" \
        "ckanext.s3filestore.aws_secret_access_key=${CKANEXT__S3FILESTORE__AWS_SECRET_ACCESS_KEY}" \
        "ckanext.s3filestore.region_name=${CKANEXT__S3FILESTORE__REGION_NAME:-us-east-1}" \
        "ckanext.s3filestore.signature_version=${CKANEXT__S3FILESTORE__SIGNATURE_VERSION:-s3v4}"

    # MinIO-specific: host_name and addressing_style
    if [ -n "$CKANEXT__S3FILESTORE__HOST_NAME" ]; then
        ckan config-tool $CKAN_INI \
            "ckanext.s3filestore.host_name=${CKANEXT__S3FILESTORE__HOST_NAME}" \
            "ckanext.s3filestore.addressing_style=${CKANEXT__S3FILESTORE__ADDRESSING_STYLE:-path}"
    fi

    # Optional: ACL
    if [ -n "$CKANEXT__S3FILESTORE__ACL" ]; then
        ckan config-tool $CKAN_INI \
            "ckanext.s3filestore.acl=${CKANEXT__S3FILESTORE__ACL}"
    fi

    # Optional: download proxy (public CDN URL for serving files)
    if [ -n "$CKANEXT__S3FILESTORE__DOWNLOAD_PROXY" ]; then
        ckan config-tool $CKAN_INI \
            "ckanext.s3filestore.download_proxy=${CKANEXT__S3FILESTORE__DOWNLOAD_PROXY}"
    fi

    # Disable startup access check (useful when running in dev/behind proxy)
    ckan config-tool $CKAN_INI \
        "ckanext.s3filestore.check_access_on_startup=false"

    echo "ckanext-s3filestore configured -> bucket: ${CKANEXT__S3FILESTORE__AWS_BUCKET_NAME:-dataverse} @ ${CKANEXT__S3FILESTORE__HOST_NAME}"
else
    echo "s3filestore not in CKAN__PLUGINS, skipping configuration"
fi
