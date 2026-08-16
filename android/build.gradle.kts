allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    plugins.withId("com.android.application") {
        configure<com.android.build.gradle.BaseExtension> {
            compileSdkVersion(36)
            ndkVersion = "27.0.12077973"
        }
    }
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.BaseExtension> {
            compileSdkVersion(36)
            ndkVersion = "27.0.12077973"
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}
