import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// local.propertiesの読み込み
val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { input ->
        localProperties.load(input)
    }
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.houser.poke_go_friends"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.houser.poke_go_friends"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdkVersion(24);
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    // --- ここから署名設定の追加 ---
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now,
            // so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
        }
    }
    lint {
        // 複数の警告をリストとして指定
        disable += "UncheckedCast"
        abortOnError = false // <-- 追加: 警告があってもビルドを中断しない
        checkReleaseBuilds = false // <-- 追加: リリースビルドでもLintチェックを実行しない (通常はtrueが推奨)
    }

}
flutter {
    source = "../.."
}

dependencies {
    // Kotlin DSLでは、依存関係の文字列を括弧で囲みます
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.0") // <-- 修正

    // ML Kit Text Recognition の基本ライブラリ
    implementation("com.google.mlkit:text-recognition:16.0.1") // <-- 修正

    // 中国語スクリプトを認識する場合
    implementation("com.google.mlkit:text-recognition-chinese:16.0.1") // <-- 修正

    // デーヴァナーガリー文字スクリプトを認識する場合
    implementation("com.google.mlkit:text-recognition-devanagari:16.0.1") // <-- 修正

    // 日本語スクリプトを認識する場合
    implementation("com.google.mlkit:text-recognition-japanese:16.0.1") // <-- 修正

    // 韓国語スクリプトを認識する場合
    implementation("com.google.mlkit:text-recognition-korean:16.0.1") // <-- 修正
}
