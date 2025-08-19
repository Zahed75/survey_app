// Needed for output file renaming
import com.android.build.gradle.internal.api.BaseVariantOutputImpl

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Must be applied after the Android & Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.shwapno.survey2"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.1.13356709"

    defaultConfig {
        applicationId = "com.shwapno.survey2"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    // ✅ Use the default debug keystore for both build types (so you don't need keystore.jks)
    signingConfigs {
        // default debug signing exists at ~/.android/debug.keystore
        getByName("debug")
        create("release") {
            storeFile = file(System.getProperty("user.home") + "/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "AndroidDebugKey"
            keyPassword = "android"
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isMinifyEnabled = false
            isShrinkResources = false
            // Sign debug with the same key → allows seamless updating during dev
            signingConfig = signingConfigs.getByName("release")
        }
    }

    buildFeatures {
        buildConfig = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // ✅ rename APK to include version for your backend
    applicationVariants.all {
        outputs.all {
            val output = this as BaseVariantOutputImpl
            val apkName = "app-${defaultConfig.versionName}+${defaultConfig.versionCode}.apk"
            output.outputFileName = apkName
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// This block must be at top level (not inside android {})
flutter {
    source = "../.."
}

// Optional: quiet a Kotlin compiler warning in some setups
tasks.withType<JavaCompile>().configureEach {
    options.compilerArgs.add("-Xlint:-options")
}
