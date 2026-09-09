plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingDirectory = rootProject.file("../.signing")
val releaseKeyStore = signingDirectory.resolve("nur-release-key.jks")
val releasePasswordFile = signingDirectory.resolve("password.txt")
val releasePassword =
    if (releasePasswordFile.exists()) releasePasswordFile.readText().trim() else null

android {
    namespace = "com.nur.arabicmyanmardictionary"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.nur.arabicmyanmardictionary"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releasePassword != null && releaseKeyStore.exists()) {
            create("release") {
                keyAlias = "nur-release"
                keyPassword = releasePassword
                storeFile = releaseKeyStore
                storePassword = releasePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                if (signingConfigs.names.contains("release")) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}
