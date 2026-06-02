#!/bin/bash

# Script de diagnostic du build
echo "=== Diagnostic Build ShieldCheck ==="
echo ""
echo "1. Vérification des fichiers Kotlin..."
find android/app/src/main/kotlin -name "*.kt" -type f

echo ""
echo "2. Vérification du AndroidManifest..."
grep -n "android:name" android/app/src/main/AndroidManifest.xml | head -20

echo ""
echo "3. Vérification de pubspec.yaml..."
grep -A 10 "dependencies:" pubspec.yaml

echo ""
echo "4. Vérification des versions Gradle..."
cat android/gradle/wrapper/gradle-wrapper.properties

echo ""
echo "5. Configuration build.gradle..."
cat android/app/build.gradle | head -70
