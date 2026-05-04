allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")

    // Prevent "already evaluated" error by skipping evaluated projects (like :app)
    if (!project.state.executed) {
        // Injects missing namespace for Isar and other older plugins (AGP 8.0+ fix)
        afterEvaluate {
            if (project.plugins.hasPlugin("com.android.library")) {
                val androidExt = project.extensions.findByName("android")
                if (androidExt != null) {
                    try {
                        val getNamespaceMethod = androidExt.javaClass.getMethod("getNamespace")
                        val namespace = getNamespaceMethod.invoke(androidExt)
                        if (namespace == null) {
                            val setNamespaceMethod = androidExt.javaClass.getMethod("setNamespace", String::class.java)
                            val groupName = project.group.toString()
                            val finalNamespace = if (groupName.isNotBlank()) groupName else "com.example.${project.name.replace("-", "_")}"
                            setNamespaceMethod.invoke(androidExt, finalNamespace)
                        }
                    } catch (e: Exception) {
                        // Safely ignore if the AGP version doesn't support these methods
                    }

                    // Force compileSdkVersion to 34 to resolve "android:attr/lStar not found" error
                    try {
                        val setCompileSdkMethod = androidExt.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType ?: Int::class.java)
                        setCompileSdkMethod.invoke(androidExt, 34)
                    } catch (e: Exception) {
                        try {
                            val compileSdkVersionMethod = androidExt.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType ?: Int::class.java)
                            compileSdkVersionMethod.invoke(androidExt, 34)
                        } catch (e2: Exception) {
                            // Safely ignore if neither method is found
                        }
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}