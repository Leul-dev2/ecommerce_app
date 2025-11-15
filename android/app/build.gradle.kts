plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lcommerce"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.lcommerce"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro")
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Enable core library desugaring
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    ndkVersion = "27.0.12077973"
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.stripe:stripe-android:11.5.0")

    // Use the required desugar_jdk_libs version
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

