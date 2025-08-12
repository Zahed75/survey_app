#!/bin/bash

# Bump only the build number (after +)
version_line=$(grep '^version:' pubspec.yaml)
current_version=$(echo "$version_line" | cut -d '+' -f1 | cut -d ':' -f2 | xargs)
current_build=$(echo "$version_line" | cut -d '+' -f2)
new_build=$((current_build + 1))

new_version_line="version: $current_version+$new_build"

# Replace line in pubspec.yaml
sed -i.bak "s/^version: .*/$new_version_line/" pubspec.yaml && rm pubspec.yaml.bak

echo "✅ pubspec.yaml updated to: $new_version_line"
