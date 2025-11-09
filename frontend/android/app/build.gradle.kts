import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.testik"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.testik"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

/* ===== Auto-generovanie launcher ikon pred buildom (fix: správny workingDir) ===== */
val flutterProjectRoot = rootProject.projectDir.parentFile   // .. z android/ do koreňa s pubspec.yaml

val generateLauncherIcons by tasks.register<Exec>("generateLauncherIcons") {
    workingDir = flutterProjectRoot
    if (System.getProperty("os.name").lowercase().contains("win")) {
        // jeden príkazový reťazec po /c, aby fungovalo &&
        commandLine("cmd", "/c", "flutter pub get && dart run flutter_launcher_icons -v")
    } else {
        commandLine("bash", "-lc", "flutter pub get && dart run flutter_launcher_icons -v")
    }
}

tasks.named("preBuild") {
    dependsOn(generateLauncherIcons)
}
