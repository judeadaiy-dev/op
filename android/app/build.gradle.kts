plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.judeadaiy.chat_app"
    compileSdk = 36
    ndkVersion = "28.2.13676358" // أضفنا هذا السطر كما طلب النظام

    defaultConfig {
        applicationId = "com.judeadaiy.chat_app"
        minSdk = 23
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }
    // ... بقية الكود كما هو (compileOptions و kotlin)
    }
  }
}   

dependencies {
    // تم تحديث رقم النسخة إلى 2.1.4 بناءً على طلب النظام في الخطأ رقم 6
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
