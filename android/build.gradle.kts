//allprojects {
//    // ... existing lines
//    repositories {
//        google()
//        mavenCentral()
//    }
//    dependencies {
//        // ... existing classpath lines (e.g., com.android.tools.build:gradle)
//        // ADD this line:
//        classpath 'com.google.gms:google-services:4.4.3' // Version may be newer, but this is fine for now
//    }
//}
//val newBuildDir: Directory =
//    rootProject.layout.buildDirectory
//        .dir("../../build")
//        .get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//subprojects {
//    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//    project.layout.buildDirectory.value(newSubprojectBuildDir)
//}
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)
//} =========================================

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// 1. Plugin Registration
// The versions here MUST match the version Gradle has already loaded (8.9.1).
plugins {
    // ⭐️ FIX: Updated AGP version to 8.9.1 to resolve the classpath conflict.
    id("com.android.application") version "8.9.1" apply false
    id("com.android.library") version "8.9.1" apply false

    // Kotlin version remains consistent (or updated to a recent stable version)
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false

    // Google Services plugin (version 4.4.3 remains as requested)
    id("com.google.gms.google-services") version "4.4.3" apply false
}

// 2. Custom Build Directory Configuration
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 3. Clean Task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}