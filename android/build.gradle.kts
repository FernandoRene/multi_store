allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

layout.buildDirectory.set(file("../build"))

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}