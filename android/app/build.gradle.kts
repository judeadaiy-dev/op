plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.judeadaiy.chat_app"
    compileSdk = 36 // تم التحديث إلى 36 كما طلب النظام

    defaultConfig {
        applicationId = "com.judeadaiy.chat_app"
        minSdk = 23
        targetSdk = 36 // تم التحديث إلى 36
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}

dependencies {
    // تم تحديث رقم النسخة إلى 2.1.4 بناءً على طلب النظام في الخطأ رقم 6
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
