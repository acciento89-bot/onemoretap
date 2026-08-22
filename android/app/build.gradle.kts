plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.plugin.compose")
}

val releaseAdMobAppId = providers.gradleProperty("NAVOTAP_ADMOB_APP_ID")
    .orElse(providers.environmentVariable("NAVOTAP_ADMOB_APP_ID"))
    .getOrElse("")
val releaseRewardedId = providers.gradleProperty("NAVOTAP_REWARDED_AD_ID")
    .orElse(providers.environmentVariable("NAVOTAP_REWARDED_AD_ID"))
    .getOrElse("")
val releaseInterstitialId = providers.gradleProperty("NAVOTAP_INTERSTITIAL_AD_ID")
    .orElse(providers.environmentVariable("NAVOTAP_INTERSTITIAL_AD_ID"))
    .getOrElse("")

val uploadKeystorePath = System.getenv("ANDROID_UPLOAD_KEYSTORE_PATH")
val uploadStorePassword = System.getenv("ANDROID_UPLOAD_STORE_PASSWORD")
val uploadKeyAlias = System.getenv("ANDROID_UPLOAD_KEY_ALIAS")
val uploadKeyPassword = System.getenv("ANDROID_UPLOAD_KEY_PASSWORD")
val releaseSigningEnabled = listOf(uploadKeystorePath, uploadStorePassword, uploadKeyAlias, uploadKeyPassword)
    .all { !it.isNullOrBlank() }

val generatedIconResDir = layout.buildDirectory.dir("generated/navotapIcon/res").get().asFile
val generateNavoTapIcon by tasks.registering(Copy::class) {
    val sourceIcon = rootProject.file("../OneMoreTap/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
    from(sourceIcon)
    into(generatedIconResDir.resolve("drawable-nodpi"))
    rename { "navotap_app_icon.png" }
    doFirst {
        if (!sourceIcon.isFile) {
            throw GradleException("Canonical NavoTap AppIcon.png is missing: ${sourceIcon.path}")
        }
    }
}

android {
    namespace = "com.kamilunavo.onemoretap"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.kamilunavo.onemoretap"
        minSdk = 26
        targetSdk = 36
        versionCode = 3
        versionName = "1.0.2"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    sourceSets.getByName("main").res.srcDir(generatedIconResDir)

    buildFeatures {
        compose = true
        buildConfig = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    if (releaseSigningEnabled) {
        signingConfigs {
            create("release") {
                storeFile = file(requireNotNull(uploadKeystorePath))
                storePassword = requireNotNull(uploadStorePassword)
                keyAlias = requireNotNull(uploadKeyAlias)
                keyPassword = requireNotNull(uploadKeyPassword)
            }
        }
    }

    buildTypes {
        debug {
            manifestPlaceholders["admobAppId"] = "ca-app-pub-3940256099942544~3347511713"
            buildConfigField("String", "REWARDED_AD_ID", "\"ca-app-pub-3940256099942544/5224354917\"")
            buildConfigField("String", "INTERSTITIAL_AD_ID", "\"ca-app-pub-3940256099942544/1033173712\"")
            buildConfigField("boolean", "USES_TEST_ADS", "true")
        }
        release {
            // Crashfix 1.0.2 deliberately disables R8/minification. The previous Play-only
            // crash must be isolated before optimization is re-enabled in a later release.
            isMinifyEnabled = false
            manifestPlaceholders["admobAppId"] = releaseAdMobAppId.ifBlank { "MISSING_ANDROID_ADMOB_APP_ID" }
            buildConfigField("String", "REWARDED_AD_ID", "\"${releaseRewardedId}\"")
            buildConfigField("String", "INTERSTITIAL_AD_ID", "\"${releaseInterstitialId}\"")
            buildConfigField("boolean", "USES_TEST_ADS", "false")
            if (releaseSigningEnabled) signingConfig = signingConfigs.getByName("release")
        }
    }
}

tasks.named("preBuild").configure {
    dependsOn(generateNavoTapIcon)
}

gradle.taskGraph.whenReady {
    val buildsRelease = allTasks.any { it.name.contains("Release", ignoreCase = true) }
    if (buildsRelease && (releaseAdMobAppId.isBlank() || releaseRewardedId.isBlank() || releaseInterstitialId.isBlank())) {
        throw GradleException(
            "NavoTap release requires NAVOTAP_ADMOB_APP_ID, NAVOTAP_REWARDED_AD_ID and NAVOTAP_INTERSTITIAL_AD_ID."
        )
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("androidx.activity:activity-compose:1.12.4")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.10.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.10.0")

    implementation(platform("androidx.compose:compose-bom:2026.06.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3")

    implementation("com.android.billingclient:billing-ktx:9.1.0")
    implementation("com.google.android.gms:play-services-ads:25.4.0")
    implementation("com.google.android.ump:user-messaging-platform:4.0.0")

    testImplementation("junit:junit:4.13.2")
    debugImplementation("androidx.compose.ui:ui-tooling")
}
