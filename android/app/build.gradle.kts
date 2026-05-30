apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace "com.judeadaiy.chat_app"
    compileSdk 34 // رفعنا الإصدار ليكون متوافقاً

    defaultConfig {
        applicationId "com.judeadaiy.chat_app"
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true // ضروري جداً للمشاريع الكبيرة
    }

    compileOptions {
        coreLibraryDesugaringEnabled true
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
}
